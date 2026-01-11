CREATE DATABASE Library_Project;
USE Library_Project;

-- Change Column Types to VARCHAR

-- Fix Branch Table
ALTER TABLE branch
MODIFY branch_id VARCHAR(10);

-- Fix Employees Table
ALTER TABLE employees
MODIFY emp_id VARCHAR(10),
MODIFY branch_id VARCHAR(10); -- Needs to match branch table for Foreign Key later

-- Fix Members Table
ALTER TABLE members
MODIFY member_id VARCHAR(10);

-- Fix Books Table
ALTER TABLE books
MODIFY isbn VARCHAR(20);  -- ISBNs are usually 13 chars, 20 is safe

-- Fix Issued Status Table
ALTER TABLE issued_status
MODIFY issued_id VARCHAR(10),
MODIFY issued_member_id VARCHAR(10), -- Must match members(member_id)
MODIFY issued_book_isbn VARCHAR(20), -- Must match books(isbn)
MODIFY issued_emp_id VARCHAR(10);    -- Must match employees(emp_id)

-- Fix Return Status Table
ALTER TABLE return_status
MODIFY return_id VARCHAR(10),
MODIFY issued_id VARCHAR(10),
MODIFY return_book_isbn VARCHAR(20);

-- Add Primarykey
ALTER TABLE branch
ADD PRIMARY KEY (branch_id);

ALTER TABLE employees
ADD PRIMARY KEY (emp_id);

ALTER TABLE members
ADD PRIMARY KEY (member_id);

ALTER TABLE books
ADD PRIMARY KEY (isbn);

ALTER TABLE issued_status
ADD PRIMARY KEY (issued_id);

ALTER TABLE return_status
ADD PRIMARY KEY (return_id);

-- Update Manager ID
ALTER TABLE branch
MODIFY manager_id VARCHAR(10);

-- Add ForeignKey
-- Link Branch to Employees (Manager)
ALTER TABLE branch
ADD CONSTRAINT fk_branch_manager
FOREIGN KEY (manager_id) REFERENCES employees(emp_id);

-- Link Employees to Branch
ALTER TABLE employees
ADD CONSTRAINT fk_employee_branch
FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

-- Link Issued Status to Members, Books, and Employees
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_member
FOREIGN KEY (issued_member_id) REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_book
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_employee
FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id);

-- Link Return Status to Issued Status and Books
ALTER TABLE return_status
ADD CONSTRAINT fk_return_issued
FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_return_book
FOREIGN KEY (return_book_isbn) REFERENCES books(isbn);


SET FOREIGN_KEY_CHECKS = 1;

DESCRIBE issued_status;

SHOW CREATE TABLE issued_status;

-- Problem 1
SELECT 
    m.member_id, 
    m.member_name, 
    i.issued_book_name, 
    i.issued_date,
    DATEDIFF('2025-12-22', i.issued_date) - 30 AS days_overdue,
    (DATEDIFF('2025-12-22', i.issued_date) - 30) * 0.50 AS fine_amount
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
JOIN members m ON i.issued_member_id = m.member_id
WHERE r.return_id IS NULL 
AND DATEDIFF('2025-12-22', i.issued_date) > 30;

SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    -- Step 1: Calculate the Due Date (30 days after issue)
    DATE_ADD(ist.issued_date, INTERVAL 30 DAY) AS due_date,
    -- Step 2: Calculate Days Overdue (Today - Due Date)
    DATEDIFF(CURRENT_DATE, DATE_ADD(ist.issued_date, INTERVAL 30 DAY)) AS days_overdue,
    -- Step 3: Calculate Fine ($0.50 per overdue day)
    (DATEDIFF(CURRENT_DATE, DATE_ADD(ist.issued_date, INTERVAL 30 DAY)) * 0.50) AS fine_amount
FROM 
    issued_status ist
JOIN 
    members m ON ist.issued_member_id = m.member_id
JOIN 
    books b ON ist.issued_book_isbn = b.isbn
LEFT JOIN 
    return_status rs ON ist.issued_id = rs.issued_id
WHERE 
    rs.return_id IS NULL -- Filter: Book has NOT been returned
    AND 
    (ist.issued_date + INTERVAL 30 DAY) < CURRENT_DATE -- Filter: It is past the 30-day limit
ORDER BY 
    days_overdue DESC;
    
-- Problem 3
SELECT 
    b.branch_id,
    m.emp_name AS manager_name,
    COUNT(ist.issued_id) AS total_books_issued,
    COUNT(rs.return_id) AS total_books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM 
    issued_status ist
JOIN 
    employees e ON ist.issued_emp_id = e.emp_id   -- Link Issue to Employee
JOIN 
    branch b ON e.branch_id = b.branch_id         -- Link Employee to Branch
LEFT JOIN 
    return_status rs ON ist.issued_id = rs.issued_id -- Link Issue to Return (Left Join to count returns)
JOIN 
    books bk ON ist.issued_book_isbn = bk.isbn    -- Link Issue to Book (to get Price)
JOIN 
    employees m ON b.manager_id = m.emp_id        -- Link Branch to Manager (just for the name)
GROUP BY 
    b.branch_id, m.emp_name
ORDER BY 
    total_revenue DESC;
    
SELECT 
    b.branch_id,
    m.emp_name AS manager_name,
    COUNT(ist.issued_id) AS total_books_issued,
    COUNT(rs.return_id) AS total_books_returned,
    ROUND(SUM(bk.rental_price), 2) AS total_revenue
FROM 
    issued_status ist
JOIN 
    employees e ON ist.issued_emp_id = e.emp_id   
JOIN 
    branch b ON e.branch_id = b.branch_id         
LEFT JOIN 
    return_status rs ON ist.issued_id = rs.issued_id 
JOIN 
    books bk ON ist.issued_book_isbn = bk.isbn    
JOIN 
    employees m ON b.manager_id = m.emp_id        
GROUP BY 
    b.branch_id, m.emp_name
ORDER BY 
    total_revenue DESC;

-- Problem 2
DELIMITER //




CREATE TRIGGER Update_Book_Status_On_Return
AFTER INSERT ON return_status
FOR EACH ROW
BEGIN
    UPDATE books
    SET status = 'yes'
    WHERE isbn = NEW.return_book_isbn;
END;
//

DELIMITER ;

-- Check a book's current status
SELECT * FROM books WHERE isbn = '978-0-306-30887-4';
-- Result should show status = 'no' (if it's rented) or 'yes'.
-- If it says 'yes', update it to 'no' manually just for this test:
-- UPDATE books SET status = 'no' WHERE isbn = '978-0-306-30887-4';

-- Return" the book.
INSERT INTO return_status (return_id, issued_id, return_book_name, return_date, return_book_isbn, book_quality)
VALUES ('RS9999', 'IS9999', 'Test Book', CURRENT_DATE, '978-0-306-30887-4', 'Good');

INSERT INTO issued_status (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES ('IS9999', 'C101', 'Test Book', CURRENT_DATE - INTERVAL 1 DAY, '978-0-306-30887-4', 'E101');

INSERT INTO return_status (return_id, issued_id, return_book_name, return_date, return_book_isbn, book_quality)
VALUES ('RS9999', 'IS9999', 'Test Book', CURRENT_DATE, '978-0-306-30887-4', 'Good');

SELECT * FROM books WHERE isbn = '978-0-306-30887-4';
SELECT 
    rs.return_id,
    rs.return_book_isbn,
    rs.return_book_name,
    rs.book_quality,
    b.status AS current_status_in_books_table
FROM 
    return_status rs
JOIN 
    books b ON rs.return_book_isbn = b.isbn
ORDER BY 
    rs.return_id DESC
LIMIT 5;

-- Problem 4
SELECT 
    m.member_id,
    m.member_name,
    m.member_address,
    MAX(ist.issued_date) AS last_book_issued_date,
    CASE 
        WHEN MAX(ist.issued_date) >= DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY) THEN 'Active'
        ELSE 'Inactive'
    END AS member_status
FROM 
    members m
LEFT JOIN 
    issued_status ist ON m.member_id = ist.issued_member_id
GROUP BY 
    m.member_id, m.member_name, m.member_address
ORDER BY 
    member_status ASC, -- Shows 'Active' members first
    last_book_issued_date DESC;
    
-- Problem 5
SELECT 
    e.emp_id,
    e.emp_name,
    e.branch_id,
    COUNT(ist.issued_id) AS total_books_issued
FROM 
    issued_status ist
JOIN 
    employees e ON ist.issued_emp_id = e.emp_id
GROUP BY 
    e.emp_id, e.emp_name, e.branch_id
ORDER BY 
    total_books_issued DESC;
    
-- Problem 6
SELECT 
    m.member_id,
    m.member_name,
    m.member_address,
    COUNT(rs.return_id) AS damaged_book_count
FROM 
    return_status rs
JOIN 
    issued_status ist ON rs.issued_id = ist.issued_id
JOIN 
    members m ON ist.issued_member_id = m.member_id
WHERE 
    rs.book_quality = 'Damaged'
GROUP BY 
    m.member_id, m.member_name, m.member_address
HAVING 
    COUNT(rs.return_id) > 2 -- The "More than twice" rule
ORDER BY 
    damaged_book_count DESC;

-- Problem 7
DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(10),
    IN p_issued_book_isbn VARCHAR(25),
    IN p_issued_emp_id VARCHAR(10),
    IN p_issued_book_name VARCHAR(80)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Step 1: Check the current status of the book in the database
    SELECT status INTO v_status 
    FROM books 
    WHERE isbn = p_issued_book_isbn;

    -- Step 2: The Logic Check (If... Then...)
    IF v_status = 'yes' THEN
        -- A. If available: Create the Issue Record
        INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, p_issued_book_name, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        
        -- B. Immediately mark the book as 'no' (Unavailable)
        UPDATE books 
        SET status = 'no' 
        WHERE isbn = p_issued_book_isbn;
        
        -- C. Give a Success Message
        SELECT CONCAT('Success: Book issued to member ', p_issued_member_id) AS result_message;

    ELSE
        -- D. If NOT available: Stop and give an Error Message
        SELECT CONCAT('Error: Book ', p_issued_book_isbn, ' is already issued/unavailable!') AS result_message;
    END IF;
END;
//

DELIMITER ;

CALL issue_book('IS_TEST_55', 'C108', '978-0-553-29335-7', 'E104', 'Foundation');

SELECT isbn, book_title 
FROM books 
WHERE status = 'yes' 
LIMIT 1;

-- Replace the ISBN below with the one you just found
CALL issue_book('IS_TEST_100', 'C108', 'YOUR_FRESH_ISBN', 'E104', 'New Test Book');

-- "Success" Test (ID is now 9 characters, so it fits)
CALL issue_book('IS_TEST_1', 'C108', 'YOUR_FRESH_ISBN', 'E104', 'New Test Book');

-- "Failure" Test (Testing double-booking)
CALL issue_book('IS_TEST_2', 'C108', 'YOUR_FRESH_ISBN', 'E104', 'New Test Book');

-- Replace the ISBN below with the one you just found
CALL issue_book('IS_TEST_100', 'C108', 'YOUR_FRESH_ISBN', 'E104', 'New Test Book');

-- Use the SAME ISBN as above
CALL issue_book('IS_TEST_101', 'C108', 'YOUR_FRESH_ISBN', 'E104', 'New Test Book');