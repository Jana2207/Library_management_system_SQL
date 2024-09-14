# 📚 Library Management System

This project demonstrates database optimization techniques for a **Library Management System** using **PostgreSQL**. It includes SQL tasks such as managing book records, updating member information, deleting data, creating stored procedures, and generating performance reports.

## 📑 Table of Contents
- [Project Overview](#project-overview)
- [Data Base Setup](#Data-base-setup)
- [Tasks and Solutions](#tasks-and-solutions)
  1. [Create a New Book Record](#create-a-new-book-record)
  2. [Update Member's Address](#update-members-address)
  3. [Delete a Record from Issued Status](#delete-a-record-from-issued-status)
  4. [Retrieve All Books Issued by an Employee](#retrieve-all-books-issued-by-an-employee)
  5. [List Members Who Have Issued More Than One Book](#list-members-who-have-issued-more-than-one-book)
  6. [Create Summary Tables](#create-summary-tables)
  7. [Retrieve All Books in a Specific Category](#retrieve-all-books-in-a-specific-category)
  8. [Find Total Rental Income by Category](#find-total-rental-income-by-category)
  9. [List Members Who Registered in the Last 180 Days](#list-members-who-registered-in-the-last-180-days)
  10. [List Employees with Their Branch Manager's Name](#list-employees-with-their-branch-managers-name)
  11. [Create a Table of Books Above a Certain Price](#create-a-table-of-books-above-a-certain-price)
  12. [Retrieve List of Books Not Yet Returned](#retrieve-list-of-books-not-yet-returned)
  13. [Identify Members with Overdue Books](#identify-members-with-overdue-books)
  14. [Update Book Status on Return](#update-book-status-on-return)
  15. [Branch Performance Report](#branch-performance-report)
  16. [Create a Table of Active Members](#create-a-table-of-active-members)
  17. [Find Employees Who Have Processed the Most Books](#find-employees-who-have-processed-the-most-books)
  18. [Identify Members Issuing High-Risk Books](#identify-members-issuing-high-risk-books)
  19. [Create Stored Procedure to Manage Book Issuance](#create-stored-procedure-to-manage-book-issuance)
  20. [CTAS Query for Overdue Books and Fines](#ctas-query-for-overdue-books-and-fines)
- [Conclusion](#Conclusion)

---

## 🚀 Project Overview

This project focuses on performing SQL tasks on a **Library Management System** to manage:
- Book and member records.
- Book issuance and return.
- Member overdue fines and book availability.
- Employee and branch performance.

![library management](library_management.jpg)


The tasks and solutions are structured to achieve the objectives efficiently using SQL queries and stored procedures.

---

## 💾 Data Base Setup

![Data model](https://raw.githubusercontent.com/Jana2207/Library_management_system_SQL/main/data_model.png)



- Database Creation: Created a database named ```library management ```.
- Table Creation: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

``` sql
-- Library Management

-- Create a table branch
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
	branch_id VARCHAR(25) PRIMARY KEY,
	manager_id VARCHAR(25),
	branch_address VARCHAR(50),
	contact_no VARCHAR(20)

);

-- Create a table books
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10)
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10)
            
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50)           
);

-- Checking data whether imported succefully or not
select * from books;
select * from branch;
select * from books;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

-- Creating FOREGIN KEYS to prepare data model

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_book
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_return_book
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);
```
---

## 🛠️ Tasks and Solutions
### Task 1
### Create a New Book Record
**Objective:** Insert a new book into the books table.

```sql
INSERT INTO books
VALUES (
    '978-1-60129-456-2',
    'To Kill a Mockingbird',
    'Classic',
    6.00,
    'yes',
    'Harper Lee',
    'J.B. Lippincott & Co.'
);

SELECT * FROM books;
```
### Task 2
### Update Member's Address
**Objective:** Update the address of a specific member (C103) in the members table.

```sql
-- To check 
SELECT * FROM members
WHERE member_id = 'C103';

-- Main query
UPDATE members
SET member_address = '125 Oka st'
WHERE member_id = 'C103';
```

### Task 3
### Delete a Record from Issued Status
**Objective:** Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
-- To check
SELECT * FROM issued_status
WHERE issued_id = 'IS121';

-- Main query
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

### Task 4
### Delete a Record from Issued Status
**Objective:** Select all books issued by the employee with emp_id = 'E101'.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

### Task 5
### List Members Who Have Issued More Than One Book
**Objective:** Use GROUP BY to find members who have issued more than one book.

```sql
SELECT * FROM issued_status;

-- Main query

SELECT 
	ist.issued_emp_id,
	e.emp_name,
	COUNT(ist.issued_emp_id) AS count
FROM issued_status as ist
JOIN employees as e
ON ist.issued_emp_id = e.emp_id
GROUP BY ist.issued_emp_id, e.emp_name 
HAVING COUNT(ist.issued_emp_id) > 1
ORDER BY COUNT(ist.issued_emp_id);
```

### Task 6
### Create Summary Tables
**Objective:** Generate a new table showing each book and the total issued count.

```sql
CREATE TABLE books_issued_count AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS issued_count
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title
ORDER BY COUNT(ist.issued_id);

-- Check
SELECT * FROM books_issued_count;
```

### Task 7
### Retrieve All Books in a Specific Category
**Objective:** Retrieve all books in the 'Classic' category.

```sql
SELECT * FROM books;

-- Main query
SELECT * FROM books
WHERE category = 'Classic';
```

### Task 8
### Find Total Rental Income by Category
**Objective:** Calculate the total rental income and the number of books issued per category.

```sql
SELECT
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books AS b
JOIN issued_status ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category
ORDER BY SUM(b.rental_price) DESC;
```

### Task 9
### List Members Who Registered in the Last 180 Days
**Objective:** List all members who registered in the last 180 days.

```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'; 
```

### Task 10
### List Employees with Their Branch Manager's Name
**Objective:**  List employees along with their branch manager's name and details.

```sql
SELECT 
	e.emp_id,
	e.emp_name,
	e.position,
	e.salary,
	b.*
FROM employees AS e
JOIN branch AS b
ON e.branch_id = b.branch_id
JOIN employees AS e2
ON e2.emp_id = b.manager_id;
```

### Task 11
### Create a Table of Books Above a Certain Price
**Objective:** Create a table for books priced above 7 rupees.

```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7 ;

SELECT * FROM expensive_books;
```

### Task 12
### Retrieve List of Books Not Yet Returned
**Objective:** List all books that have not yet been returned.

```sql
SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS ret
ON ist.issued_id = ret.return_id
WHERE ret.return_id IS NULL;
```

### Task 13
### Identify Members with Overdue Books
**Objective:** Identify members with overdue books (assume a 30-day return period).

```sql
SELECT 
	ist.issued_member_id,
	me.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date - 30 AS Over_due
FROM issued_status AS ist
JOIN books AS b
ON b.isbn = ist.issued_book_isbn
JOIN members AS me
ON 	me.member_id = ist.issued_member_id
LEFT JOIN return_status AS ret
ON ret.issued_id = ist.issued_id
WHERE 
	ret.return_date IS NULL
	AND
	CURRENT_DATE - ist.issued_date > 0
ORDER BY ist.issued_date;
```

### Task 14
### Update Book Status on Return
**Objective:** Update the status of a book to 'yes' when returned.

```sql
-- Main query
CREATE OR REPLACE PROCEDURE add_return_record( u_return_id VARCHAR(10), u_issued_id VARCHAR(30))
LANGUAGE plpgsql
AS $$
DECLARE
	book_name VARCHAR(80);
	book_isbn VARCHAR(50);
BEGIN
	-- Getting book name and isbn number based in issued_id of returning book
	SELECT 
		issued_book_name,
		issued_book_isbn
		INTO
		book_name,
		book_isbn
	FROM issued_status
	WHERE issued_id = u_issued_id;

	-- Inserting return status of book
	INSERT INTO return_status (return_id, issued_id, return_book_name, return_date, return_book_isbn)
	VALUES (u_return_id, u_issued_id, book_name, CURRENT_DATE, book_isbn);

	-- Updating book availability status to yes
	UPDATE books
	SET status = 'yes'
	WHERE isbn = book_isbn;

	-- Diplaying notice
	RAISE NOTICE 'Thank for returning book: %', book_name;
	
END; $$

-- Testiing Function

-- Observe and select a book_isbn which status is no
SELECT * FROM books;

-- Check whether the books is issed or not and check its issued_id
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-375-41398-8';

-- Check whether the book is return or not (should return empty)
SELECT * FROM return_status
WHERE issued_id = 'IS134';

-- Inserting return records and updating book status using function (function calling)
CALL add_return_record('RS134','IS134');

-- Check whether the record is inserted or not (should return record)
SELECT * FROM return_status
WHERE issued_id = 'IS134';

-- Checking whether the status is updated to yes 
SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';
```

### Task 15
### Branch Performance Report
**Objective:** Create a report showing the number of books issued by each branch.

```sql
CREATE TABLE branch_reports AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS isuued_count,
	COUNT(ret.return_id) AS return_count,
	SUM(bo.rental_price) AS revenue_generated
FROM issued_status AS ist
JOIN employees AS e
ON e.emp_id = issued_emp_id
JOIN branch AS b
ON b.branch_id = e.branch_id
LEFT JOIN return_status AS ret
ON ret.issued_id = ist.issued_id
JOIN books as bo
ON bo.isbn = ist.issued_book_isbn
GROUP BY b.branch_id;

SELECT * FROM branch_reports;
```

### Task 16
### Create a Table of Active Members
**Objective:** Create a table of active members who have issued books in the last 30 days.

```sql
SELECT * FROM members
WHERE member_id IN(
	SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '6 months'
	)
;
```

### Task 17
### Find Employees Who Have Processed the Most Books
**Objective:** Find top 3 employees who have issued the most books.

```sql
SELECT 
	ist.issued_emp_id,
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) AS books_processed
FROM issued_status AS ist
JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
LEFT JOIN branch AS b
ON b.branch_id = e.branch_id
GROUP BY ist.issued_emp_id, e.emp_name, b.branch_id
ORDER BY COUNT(ist.issued_id) DESC
LIMIT 3 ;
```

### Task 18
### Identify Members Issuing High-Risk Books
**Objective:** List members who issued 2 or more high-risk books (e.g., status = damage).

```sql
SELECT 
	ist.issued_emp_id,
	e.emp_name,
	b.book_title,
	b.isbn,
	COUNT(ist.issued_id) AS No_of_times_issued
FROM issued_status AS ist
JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN books AS b
ON b.isbn = ist.issued_book_isbn
WHERE 
	b.status = 'damaged'
GROUP BY ist.issued_emp_id, e.emp_name, b.book_title, b.isbn
HAVING
	COUNT(ist.issued_id) >= 2;
```

### Task 19
### Create Stored Procedure to Manage Book Issuance
**Objective:** Create a stored procedure to manage the status of books in a library system. 
**Description:** Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_isbn as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that 
the book is currently not available.

```sql
-- Creating a stored procedure

CREATE OR REPLACE PROCEDURE issue_book( 
	book_isbn VARCHAR(80), p_issued_id VARCHAR(10), 
	member_id VARCHAR(30),emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
	book_name VARCHAR(80);
	v_status VARCHAR(10);
BEGIN
	-- Check the status of the book
	SELECT 
		book_title,
		status
		INTO
		book_name,
		v_status
	FROM books
	WHERE isbn = book_isbn;

	-- Insert into issed_status table or give error message
	IF v_status = 'yes' THEN
		-- Insert record into issued_status table
		INSERT INTO issued_status (
			issued_id, issued_member_id, 
			issued_book_name, issued_date,
			issued_book_isbn, issued_emp_id)
		VALUES(
			p_issued_id, member_id,
			book_name, CURRENT_DATE,
			book_isbn, emp_id);

		-- Update books table status to no
		UPDATE books
		SET status = 'no'
		WHERE isbn = book_isbn;

		RAISE NOTICE 'Book records added successfully for book % with isbn %', book_name, book_isbn;
	ELSE
		RAISE NOTICE 'Sorry to inform you that % with isbn % is not availabele', book_name, book_isbn;
	END IF;
END;
$$

-- Testing procedure

-- Select a book to issue status (yes) '978-1-60129-456-2'
SELECT * FROM books;

-- select an employee and member 'E108', 'C108'
SELECT * FROM issued_status;

-- issed book 978-1-60129-456-2
CALL issue_book('978-1-60129-456-2', 'IS141', 'C108', 'E108');


-- Check whether the record was inserted or not
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-1-60129-456-2'

-- Check whether its status was updated to no or not
SELECT * FROM books
WHERE isbn = '978-1-60129-456-2';

-- -- Select a book to issue status (no) '978-1-60129-456-2'
-- select an employee and member 'E109', 'C109'
-- issed book 978-1-60129-456-2
CALL issue_book('978-1-60129-456-2', 'IS141', 'C109', 'E109'); -- Sorry statement
```

### Task 20
### CTAS Query for Overdue Books and Fines
**Objective:** Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
**Description:** Write a CTAS query to create a new table that lists each member 
and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books.
The total fines- with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines

```sql
CREATE TABLE fines
AS
SELECT
	issued_member_id,
	over_due,
	CASE 
		WHEN over_due > 0 THEN
			over_due * 0.5
		ELSE
			0
	END AS fine_in_$
FROM(
	SELECT
		ist.issued_member_id,
	   CASE 
	        WHEN rst.return_date IS NULL THEN
				CURRENT_DATE - ist.issued_date - 30
	        ELSE 
				rst.return_date - ist.issued_date - 30
	    END AS over_due
	FROM issued_status AS ist
	LEFT JOIN return_status rst
	ON rst.issued_id = ist.issued_id
)
WHERE over_due > 0
ORDER BY over_due DESC;

SELECT * FROM fines;
```

---

## 🔚 Conclusion
- This project demonstrates the application of SQL skills in creating and managing a library management system.
 It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
