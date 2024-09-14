
/*
Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
*/

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

-- Task 2: Update an C103 Member's Address to 125 Oka st

-- To check 
SELECT * FROM members
WHERE member_id = 'C103';

-- Main query
UPDATE members
SET member_address = '125 Oka st'
WHERE member_id = 'C103';



-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

-- To check
SELECT * FROM issued_status
WHERE issued_id = 'IS121';

-- Main query
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

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

/*
Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
each book and total issued count
*/

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

-- Task 7. Retrieve All Books in a Specific Category 'Classic'

SELECT * FROM books;

-- Main query
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books AS b
JOIN issued_status ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category
ORDER BY SUM(b.rental_price) DESC;

-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'; 

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

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

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold (7 rupees)

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7 ;

SELECT * FROM expensive_books;

-- Task 12:  Retrieve the List of Books Not Yet Returned

SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS ret
ON ist.issued_id = ret.return_id
WHERE ret.return_id IS NULL;

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

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

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
ontaining members who have issued at least one book in the last 6 months.
*/

SELECT * FROM members
WHERE member_id IN(
	SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '6 months'
	)
;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch details.
*/

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


/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

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

/*
Task 19: Stored Procedure 
Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_isbn as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that 
the book is currently not available.
*/

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

/*
Task 20: Create Table As Select (CTAS) 
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member 
and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books.
The total fines- with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/

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

	