--Create 3 tables Students, Courses, Enrollments
CREATE TABLE Students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    major VARCHAR(50)
);

CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(50),
    department VARCHAR(50),
    max_capacity INT
);

CREATE TABLE Enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES Students(student_id),
    course_id INT REFERENCES Courses(course_id),
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Check tables creation
Select * from Students;
Select * from Courses;
Select * from Enrollments;

--1. Stored Procedure
--Stored procedure for student enrollment
CREATE OR REPLACE PROCEDURE EnrollStudent(p_student_id INT, p_course_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    course_capacity INT;
    current_enrollment INT;
BEGIN
    -- Check if student exists
    IF NOT EXISTS (SELECT 1 FROM Students WHERE student_id = p_student_id) THEN
        RAISE EXCEPTION 'Enrollment failed: Student ID % does not exist', p_student_id;
    END IF;

    -- Check if course exists
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE course_id = p_course_id) THEN
        RAISE EXCEPTION 'Enrollment failed: Course ID % does not exist', p_course_id;
    END IF;
	
    -- Check if student is already enrolled
    IF EXISTS (SELECT 1 FROM Enrollments WHERE student_id = p_student_id AND course_id = p_course_id) THEN
        RAISE EXCEPTION 'Student ID % is already enrolled in Course ID %', p_student_id, p_course_id;
    END IF;
   
    -- Get course capacity and current enrollment
    SELECT max_capacity INTO course_capacity FROM Courses WHERE course_id = p_course_id;
    SELECT COUNT(*) INTO current_enrollment FROM Enrollments WHERE course_id = p_course_id;

    -- Check if course is full
    IF current_enrollment >= course_capacity THEN
        RAISE EXCEPTION 'Enrollment failed: Course at full capacity';
    ELSE
        -- Enroll student
        INSERT INTO Enrollments (student_id, course_id) VALUES (p_student_id, p_course_id);
        RAISE NOTICE 'Enrollment successful for student % in course %', p_student_id, p_course_id;
    END IF;
END;
$$;

--2. Views
--2a. Student Course View
CREATE VIEW StudentCourseView AS
SELECT 
    s.student_id, 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    c.course_name,
    e.enrollment_date
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id;

--To confirm Student Course View display expected data
SELECT * FROM StudentCourseView;

--2b. Course Capacity View
CREATE VIEW CourseCapacityView AS
SELECT 
    c.course_id,
    c.course_name,
    c.department,
    COUNT(e.enrollment_id) AS current_enrollment,
    (c.max_capacity - COUNT(e.enrollment_id)) AS remaining_capacity
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.department, c.max_capacity;

--To confirm Course Capacity View display expected data
SELECT * FROM CourseCapacityView;

--3. Triggers
--3a. Trigger to update capacity
-- Add remaining_capacity column to Courses
ALTER TABLE Courses
ADD remaining_capacity INT;

-- Initialize remaining_capacity to match max_capacity for existing courses
UPDATE Courses SET remaining_capacity = max_capacity;

-- Add unique constraint to prevent duplicate enrollments
ALTER TABLE Enrollments
ADD CONSTRAINT unique_enrollment UNIQUE (student_id, course_id);

-- Trigger function to update remaining_capacity
CREATE OR REPLACE FUNCTION update_remaining_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Decrease remaining capacity by 1 when a student enrolls
        UPDATE Courses SET remaining_capacity = remaining_capacity - 1 
        WHERE course_id = NEW.course_id;
    ELSIF (TG_OP = 'DELETE') THEN
        -- Increase remaining capacity by 1 when a student drops the course
        UPDATE Courses SET remaining_capacity = remaining_capacity + 1 
        WHERE course_id = OLD.course_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the update_remaining_capacity function after insert or delete on Enrollments
CREATE TRIGGER trigger_update_remaining_capacity
AFTER INSERT OR DELETE ON Enrollments
FOR EACH ROW
EXECUTE FUNCTION update_remaining_capacity();

--3b. Trigger to log enrollment events
CREATE TABLE EnrollmentLog (
    log_id SERIAL PRIMARY KEY,
    action VARCHAR(10),
    student_id INT,
    course_id INT,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_enrollment_event()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO EnrollmentLog (action, student_id, course_id) VALUES ('ENROLL', NEW.student_id, NEW.course_id);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO EnrollmentLog (action, student_id, course_id) VALUES ('DROP', OLD.student_id, OLD.course_id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_enrollment
AFTER INSERT OR DELETE ON Enrollments
FOR EACH ROW EXECUTE FUNCTION log_enrollment_event();


--Populate 2 tables with data
--Insert data into Students table
INSERT INTO Students (first_name, last_name, major)
VALUES 
    ('Ngoc Huyen', 'Truong', 'Data Science'), --My real info
    ('John', 'Doe', 'Computer Science'),
    ('Jane', 'Smith', 'Mechanical Engineering'),
    ('Alice', 'Brown', 'Electrical Engineering'),
    ('Robert', 'Johnson', 'Business Administration');

--Check Students table after populating
Select * from Students;

--Insert data into Courses table
INSERT INTO Courses (course_name, department, max_capacity)
VALUES 
    ('Data Structures', 'Computer Science', 5),
    ('Linear Algebra', 'Mathematics', 4),
    ('Physics', 'Physics', 5),
    ('Marketing Principles', 'Business Administration', 6);
--Check Courses table after populating
Select * from Courses;