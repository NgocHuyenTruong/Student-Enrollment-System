# Simplified University Enrollment System  

This project demonstrates a university enrollment system that integrates SQL and Python to manage enrollments efficiently. The system ensures data integrity, handles edge cases like full courses or duplicate enrollments, and logs significant events automatically.  

---

## Project Features  

### SQL Development  

1. **Table Creation**:  
   - `Students`: Stores student details (ID, name, major).  
   - `Courses`: Maintains course information (ID, name, department, capacity).  
   - `Enrollments`: Links students and courses with timestamps.  

2. **Stored Procedure**:  
   - Enrolls students into courses while ensuring:  
     - Students and courses exist in the database.  
     - The course has available capacity.  
     - The student is not already enrolled in the course.  

3. **Views**:  
   - `StudentCourseView`: Displays enrollment details, including student names, course names, and enrollment dates.  
   - `CourseCapacityView`: Shows the current enrollment and remaining capacity for each course.  

4. **Triggers**:  
   - Dynamically update course capacity whenever students enroll or drop courses.  
   - Log enrollment events (e.g., enrollments or drops) into an `EnrollmentLog` table.  

5. **Populate Tables with Data**:  
   - Seeded the `Students`, `Courses`, and `Enrollments` tables with sample data for testing and demonstration purposes.  

---

### Python Integration  

1. **Stored Procedure Integration**:  
   - Python script to enroll students using the SQL stored procedure.  
   - Handles exceptions like full courses or duplicate enrollments.  

2. **View Queries**:  
   - Scripts to fetch and display data from:  
     - `StudentCourseView` (enrollment details).  
     - `CourseCapacityView` (current capacity of courses).  

3. **Trigger Tests**:  
   - Scripts to insert and delete enrollment records.  
   - Validate triggers by verifying updates to course capacity and log entries in the `EnrollmentLog` table.  

---

### Testing  

The project includes seven test cases to validate various scenarios:  

1. **Successful Enrollment**: A student enrolls in a course with available capacity.  
2. **Course Capacity Update After Multiple Enrollments**: Confirm that the system accurately updates the remaining course capacity as students enroll.
3. **Full Course Enrollment**: Attempting to enroll in a course that has reached its maximum capacity.  
4. **Duplicate Enrollment Prevention**: Prevent a student from enrolling in the same course multiple times.  
5. **Event Logging for Enrollment**: Verify that each enrollment action is logged in the EnrollmentLog table  
6. **Successful Unenrollment**: Verify that a student can successfully unenroll from a course and the system updates capacity accordingly.
7. **Invalid Student ID**: Handle cases where the student ID does not exist.  
8. **Invalid Course ID**: Handle cases where the course ID does not exist.  

---

## How to Use  

1. **Database Setup**:  
   - Run the SQL scripts to create tables, stored procedure, views, and triggers.  
   - Populate the tables with sample data.  

2. **Python Execution**:  
   - Execute the Python scripts to interact with the database.  
   - Test enrollment functionality, view queries, and triggers.  

3. **Validation**:  
   - Use the output from the Python scripts and database queries to validate the system's behavior.  

---

This project showcases the integration of SQL and Python to build a robust database-backed application. It is a practical demonstration of database management and interaction techniques.  
