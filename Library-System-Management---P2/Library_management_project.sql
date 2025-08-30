Create Table branch
(
     branch_id VARCHAR(10) PRIMARY KEY,
	 manager_id VARCHAR(10),
	 branch_address VARCHAR(30),
	 contact_no VARCHAR(15)
);

-- DROP TABLE IF EXISTS employees;
CREATE TABLE Employees
(
   emp_id VARCHAR(10) PRIMARY KEY,
   emp_name VARCHAR(30),
   position VARCHAR(20),
   salary DECIMAL(10,2),
   branch_id VARCHAR(10),
   foreign key (branch_id) REFERENCES branch(branch_id)
);

Create table members
(
  member_id VARCHAR(10) PRIMARY KEY,
  member_name VARCHAR(30),
  member_address VARCHAR(30),
  reg_date DATE
);

-- Create table BOOKS

CREATE table Books
(
  isbn VARCHAR(30) PRIMARY KEY,
  book_title VARCHAR(80),
  category VARCHAR(20),
  rental_price DECIMAL(10,2),
  status VARCHAR(10),
  author VARCHAR(20),
  publisher VARCHAR(30)
);

-- Create Table 'IssueStatus'
Create table issued_status
(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(30),
issued_book_name VARCHAR(80),
issued_date DATE,
issued_emp_id VARCHAR(10),
issued_book_isbn VARCHAR(50),
FOREIGN KEY(issued_member_id) REFERENCES members(member_id),
FOREIGN KEY(issued_emp_id) REFERENCES employees(emp_id),
FOREIGN KEY(issued_book_isbn) REFERENCES books(isbn)
);

-- Create table 'ReturnStatus'
CREATE TABLE return_status
(
    return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(30),
	return_book_name VARCHAR(20),
	return_date DATE,
	return_book_isbn VARCHAR(50) NULL 
);

select * from books;

INSERT INTO BOOKS
(
isbn,book_title, category,rental_price,status,author,publisher

)VALUES('978-1-60129-456-2','Mahabharath','self_development',23,'issued','Vyasa Bhagavan','gorathpur')


INSERT INTO BOOKS
VALUES('978-1-60129-456-3','Vedas','self_development',1000,'issued','Maharshi Manu','gorathpur')

select * from BOOKS;

-- Tack 2 Update an Existing Member's Address
Update members
set member_address = '125 Oak St'
Where member_id = 'C103';

Update Books
set status = 'pending'
where isbn = '978-1-60129-456-3';
select * from Books;

-- Task 3 Delete a Record from the Issued Status Table
delete from members where member_id = 'C103';
delete from books where isbn = '978-1-60129-456-2';
delete from books where isbn = '978-1-60129-456-3';

-- Task 4 Retrieve all books issued by a specific Employee
select * from issued_status
where issued_emp_id = 'E101'

select * from issued_status;

-- Task 5 List Members who have issued More then One Book.

select 
issued_book_name,count(*)
from issued_status
Group by 1
having count(*) > 1;

-- Task 6 CTAS(Create Table as Select)
Create Table book_issued_cnt as 
select b.isbn,b.book_title,count(ist.issued_id) AS issue_count
from issued_status as ist
join books as b
on ist.issued_book_isbn = b.isbn
group by b.isbn, b.book_title;

 -- Data Analysis & Findings

 -- Task 7. Retrieve All Books in a specific Category

 Select * from books
 where category = 'Classic';

 -- Task 8: Select top 3 most rented books by category and it's sum of rented amount.
 
 select category,sum(rental_price) as sum from
 books 
 group by category
 order by sum DESC
 limit 3;

 -- List Members Who Registered in the last 480 days.
 select * from members
 where reg_date >= CURRENT_DATE - INTERVAL '480 days';


-- Task 10: List Employees with their Branch Manager's Name and their branch details.
Select
e1.emp_id,
e1.emp_name,
e1.position,
e1.salary,
e2.emp_name as manager
from employees as e1
join
branch as b
on e1.branch_id = b.branch_id
join
employees as e2
on e2.emp_id = b.manager_id;

-- Task 11 Create a Table of Books with Rental Price Above a Certain Threshold.
CREATE TABLE expensive_books as
select * from books
where rental_price > 7.00;

-- Task 12 Retrieve the List of Books Not yet Returned
select * from issued_status as ist
LEFT JOIN 
return_status as rs
on rs.issued_id = ist.issued_id
where rs.return_id IS NULL;


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books
-- (assume a 30-day return period). Display the member's_id,
-- member's name,book title,issue date, and days overdue.
select 
ist.issued_member_id,
m.member_name,
bk.book_title,
--rs.return_date,
CURRENT_DATE - ist.issued_date as over_dues_days
from issued_status as ist
join
members as m
on m.member_id = ist.issued_member_id
join
books as bk
on bk.isbn = ist.issued_book_isbn
left join
return_status as rs
on rs.issued_id = ist.issued_id
where
 rs.return_date IS NULL
 AND
 (CURRENT_DATE - ist.issued_date) > 400
 order by 1

--- Task 14 Update Book Status on Return

-- write a query to update the status of books in the books table to 'yes'
-- when they are returned(based on entries in the return_status table)


-- Task 15: Branch Performance Report
-- Create a query that generate a performance report for each branch,showing the number
--- the number of books issued, the number of books returned and the total generated from book rentals.

Create TABLE branch_reports
AS 
select 
b.branch_id,
b.manager_id,
count(ist.issued_id) as number_book_issued,
count(rs.return_id) as number_of_book_return,
SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
join
branch b
on e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
on rs.issued_id = ist.issued_id
JOIN
books as bk
on ist.issued_book_isbn = bk.isbn
group by 1,2;

select total_revenue from branch_reports;


--- Task 16 CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create 
-- a new table active_members containing members who have issued at
-- least one book in the last 2 months

CREATE TABLE  active_members
AS 
SELECT * FROM members

WHERE member_id IN(
SELECT DISTINCT issued_member_id
FROM issued_status
WHERE 
issued_date >= current_date - INTERVAL '460 days'
);

select * from active_members;

-- Task 17 Find Employees with the Most Book Issues Processed
select 
e.emp_name,
b.*,
count(ist.issued_id) as no_book_issued
from issued_status as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
join
branch as b 
on e.branch_id = b.branch_id
group by 1,2;