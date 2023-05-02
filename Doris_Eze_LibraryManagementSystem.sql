-- Task 1: Design and normalize into 3NF
-- We first start by creating a database for the Library
CREATE DATABASE LibraryManagementSystem;
---------------------------------------------
USE LibraryManagementSystem; 
---------------------------------------------
-- Creating a user to access the database
CREATE LOGIN lms_user WITH PASSWORD = 'MyPassword123';
CREATE USER lms_user FOR LOGIN lms_user;

-- Granting permissions to the user
GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE::LibraryManagementSystem TO lms_user;

EXEC sp_helpuser 'library_admin';



-- Proceeding to the next step by creating tables based off the client's requirement --
--- Creating the members table
CREATE TABLE Member (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20)
);

-- It is good practice to to split the username and password columns
-- into a separate table to ensure security and protect sensitive information.
--- Creating the member authentication table
CREATE TABLE MemberAuth (
    member_auth_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT UNIQUE NOT NULL,
    username VARCHAR(50) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    CONSTRAINT FK_MemberAuth_Member FOREIGN KEY (member_id) REFERENCES Member(member_id)
);

--- Creating the member address table
CREATE TABLE MemberAddress (
    member_address_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    Post_code VARCHAR(10) NOT NULL,
    CONSTRAINT FK_MemberAddress_Member FOREIGN KEY (member_id) REFERENCES Member(member_id)
);

--- Creating the membership table
CREATE TABLE Membership (
    membership_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE,
    CONSTRAINT FK_Membership_Member FOREIGN KEY (member_id) REFERENCES Member(member_id)
);


-- Creating the catalogue of items table
CREATE TABLE Catalogue (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    item_title VARCHAR(100) NOT NULL,
    item_type VARCHAR(20) NOT NULL,
    author VARCHAR(50) NOT NULL,
    year_of_publication INT NOT NULL,
    date_added_to_collection DATE NOT NULL,
    date_lost_removed DATE,
    isbn VARCHAR(20),
    item_status VARCHAR(20) NOT NULL,
    CONSTRAINT CK_Catalogue_ItemType CHECK (item_type IN ('Book', 'Journal', 'DVD', 'Other Media')),
    CONSTRAINT CK_Catalogue_ItemStatus CHECK (item_status IN ('On Loan', 'Overdue', 'Available', 'Lost/Removed'))
);

-- Creating the loans table
CREATE TABLE Loan (
  loan_id INT IDENTITY(1,1) PRIMARY KEY,
  member_id INT NOT NULL,
  item_id INT NOT NULL,
  loan_date DATE NOT NULL,
  due_date DATE NOT NULL,
  return_date DATE,
  overdue_fee DECIMAL(6,2),
  CONSTRAINT FK_Loan_Member FOREIGN KEY (member_id) REFERENCES Member(member_id),
  CONSTRAINT FK_Loan_Catalogue FOREIGN KEY (item_id) REFERENCES Catalogue(item_id),
  CONSTRAINT CK_Loan_OverdueFee CHECK ((overdue_fee IS NULL) OR (overdue_fee >= 0)),
  CONSTRAINT CK_Loan_Dates CHECK (loan_date <= due_date AND (return_date IS NULL OR return_date <= GETDATE()))
);


--- Creating the overdue fines table
CREATE TABLE OverdueFine (
    overdue_fine_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    total_fine DECIMAL(5,2) NOT NULL,
    repaid_amount DECIMAL(5,2) NOT NULL,
    outstanding_balance DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_OverdueFine_Member FOREIGN KEY (member_id) REFERENCES Member(member_id)
);

-- Creating the repayment table
CREATE TABLE Repayment (
    repayment_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    repayment_date DATE NOT NULL,
    repayment_amount DECIMAL(5,2) NOT NULL,
    repayment_method VARCHAR(10) NOT NULL,
    CONSTRAINT FK_Repayment_Member FOREIGN KEY (member_id) REFERENCES Member(member_id)
);

--Checking if the tables were created successfully
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('Member', 'MemberAuth', 'MemberAddress', 'Membership', 'Catalogue', 'Loan', 'OverdueFine', 'Repayment');



--Next is to populate the tables with some sample data to just enable us test our queries
-- Insert into the members table 
INSERT INTO Member (first_name, last_name, date_of_birth, email, phone)
VALUES
('John', 'Doe', '1990-05-15', 'johndoe@example.com', '555-1234'),
('Jane', 'Doe', '1992-11-08', 'janedoe@example.com', '555-5678'),
('Bob', 'Smith', '1985-02-22', 'bobsmith@example.com', '555-9012'),
('Alice', 'Johnson', '1978-09-03', 'alicejohnson@example.com', '555-3456'),
('Charlie', 'Brown', '1995-12-01', 'charliebrown@example.com', '555-7890');

-- Inserting into the member auth table 
INSERT INTO MemberAuth (member_id, username, hashed_password)
VALUES (1, 'johndoe', 'a1b2c3d4e5f6'),
       (2, 'janedoe', 'f6e5d4c3b2a1'),
       (3, 'bobsmith', '1a2b3c4d5e6f'),
       (4, 'maryjones', '6f5e4d3c2b1a'),
       (5, 'peterparker', 'a1b2c3d4e5f6');

-- Inserting into the member address table 
INSERT INTO MemberAddress (member_id, street, city, state, post_code)
VALUES 
       (1, '10 Downing Street', 'London', '', 'SW1A 2AA'),
       (2, 'Buckingham Palace', 'London', '', 'SW1A 1AA'),
       (3, '10-12 Theobalds Road', 'London', '', 'WC1X 8PN'),
       (4, 'Westminster Abbey', 'London', '', 'SW1P 3PA'),
	   (5, 'Royal Albert Hall', 'London', '', 'SW7 2AP');

-- Inserting data into the Membership table
INSERT INTO Membership (member_id, membership_start_date, membership_end_date)
VALUES 
        (1, '2022-01-01', '2023-01-01'),
        (2, '2022-02-01', '2023-02-01'),
        (3, '2022-03-01', '2023-03-01'),
        (4, '2022-04-01', '2023-04-01'),
        (5, '2022-05-01', '2023-05-01');

-- Inserting data into the Catalogue table
INSERT INTO Catalogue (item_title, item_type, author, year_of_publication, date_added_to_collection, isbn, item_status)
VALUES 
		('The Catcher in the Rye', 'Book', 'J.D. Salinger', 1951, '1951-07-16', '9780316769174', 'Available'),
		('The New Yorker', 'Journal', 'Conde Nast', 1925, '1925-02-21', NULL, 'On Loan'),
		('Inception', 'DVD', 'Christopher Nolan', 2010, '2010-07-13', '883929082994', 'Available'),
		('The Dark Knight', 'DVD', 'Christopher Nolan', 2008, '2008-07-18', '085391189960', 'Overdue'),
		('The Shawshank Redemption', 'Other Media', 'Frank Darabont', 1994, '1994-09-23', NULL, 'Available');

-- Inserting data into the Loan table
INSERT INTO Loan (member_id, item_id, loan_date, due_date, return_date, overdue_fee)
VALUES 
		(1, 1, '2023-04-01', '2023-04-08', '2023-04-08', 30.5),
		(2, 2, '2023-04-02', '2023-04-09', '2023-04-09', 40),
		(3, 3, '2023-04-03', '2023-04-10', NULL, NULL),
		(4, 4, '2023-04-04', '2023-04-11', NULL, NULL),
		(5, 5, '2023-04-05', '2023-04-12', '2023-04-15', 10.30);

-- Inserting into the overdue fine table
INSERT INTO OverdueFine (member_id, total_fine, repaid_amount, outstanding_balance)
VALUES
		(1, 12.50, 5.00, 7.50),
		(2, 7.00, 0.00, 7.00),
		(3, 25.00, 12.00, 13.00),
		(4, 3.75, 3.75, 0.00),
		(5, 15.20, 0.00, 15.20);


-- Inserting data into the Repayment table
INSERT INTO Repayment (member_id, repayment_date, repayment_amount, repayment_method)
VALUES 
		(1, '2022-01-01', 10.50, 'cash'),
		(2, '2022-02-15', 5.00, 'card'),
		(3, '2022-03-20', 8.25, 'cash'),
		(4, '2022-04-05', 12.75, 'card'),
		(5, '2022-05-10', 3.50, 'cash');



-- Some SELECT queries to test the database 
-- 1. Joining two tables and filtering results based on a sub-query:
SELECT c.item_title, c.item_type, l.loan_date, l.due_date
FROM Catalogue c
JOIN Loan l ON c.item_id = l.item_id
WHERE c.item_type = 'Book'
AND l.loan_date IN (SELECT MAX(loan_date) FROM Loan WHERE item_id = c.item_id);


--2. Retrieve a list of loans that are currently overdue::
SELECT l.loan_id, m.first_name, m.last_name, c.item_title, l.due_date, l.return_date
FROM Loan l
INNER JOIN Member m ON l.member_id = m.member_id
INNER JOIN Catalogue c ON l.item_id = c.item_id
WHERE l.due_date < GETDATE()
AND l.return_date IS NULL;


--3. Using a sub-query to filter results based on the maximum value of a column:
SELECT c.item_title, c.author, l.return_date
FROM Catalogue c
JOIN Loan l ON c.item_id = l.item_id
WHERE l.return_date = (SELECT MAX(return_date) FROM Loan WHERE item_id = c.item_id);


-- Problem 2: Stored procedures or User-defined functions

-- 2a)To create a stored procedure that searches the catalogue for matching character strings 
-- by title and sorts the results with most recent publication date first (I'll be using user-defined function for this implementation)
CREATE PROCEDURE SearchCatalogueByTitle
    @title VARCHAR(100)
AS
BEGIN
    SELECT *
    FROM Catalogue
    WHERE item_title LIKE '%' + @title + '%'
    ORDER BY year_of_publication DESC
END
-- To test the stored procedure SearchCatalogueByTitle, 
--you can execute it using the EXEC command and pass a parameter value for @title:

-- Declare variable to hold parameter value
DECLARE @title VARCHAR(100)
SET @title = 'The New Yorker'

-- Execute stored procedure
EXEC SearchCatalogueByTitle @title


-- 2b)To create a stored procedure that returns a full list of all items currently on loan which have a due date of less than five days 
CREATE PROCEDURE GetOverdueLoans
    @num_days INT = 5
AS
BEGIN
SELECT l.loan_id, c.item_title, CONCAT(m.first_name, ' ', m.last_name) as full_name, l.due_date
FROM Loan l
INNER JOIN Catalogue c ON l.item_id = c.item_id
INNER JOIN Member m ON l.member_id = m.member_id
-- You can also modify the stored procedure to add a parameter for the number of days to check for due items
WHERE l.return_date IS NULL AND l.due_date <= DATEADD(day, @num_days, GETDATE())
END

-- To test the stored procedure
EXEC GetOverdueLoans

-- You can pass a different value for @num_days to test the stored procedure with different input
EXEC GetOverdueLoans @num_days = 9



-- 2c)To create a stored procedure that inserts a new member into the database
CREATE PROCEDURE InsertMember
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @date_of_birth DATE,
    @email VARCHAR(100),
    @phone VARCHAR(20),
    @username VARCHAR(50),
    @hashed_password CHAR(60),
    @street VARCHAR(50),
    @city VARCHAR(50),
    @state VARCHAR(50),
    @Post_code VARCHAR(10),
    @membership_start_date DATE,
    @membership_end_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @member_id INT;

    -- Insert into Member table
    INSERT INTO Member (first_name, last_name, date_of_birth, email, phone)
    VALUES (@first_name, @last_name, @date_of_birth, @email, @phone);

    -- Retrieve the member_id value generated by the IDENTITY column
    SET @member_id = SCOPE_IDENTITY();

    -- Insert into MemberAuth table
    INSERT INTO MemberAuth (member_id, username, hashed_password)
    VALUES (@member_id, @username, @hashed_password);

    -- Insert into MemberAddress table
    INSERT INTO MemberAddress (member_id, street, city, state, Post_code)
    VALUES (@member_id, @street, @city, @state, @Post_code);

    -- Insert into Membership table
    INSERT INTO Membership (member_id, membership_start_date, membership_end_date)
    VALUES (@member_id, @membership_start_date, @membership_end_date);

END;


-- Calling this procedure with the appropriate parameters to insert a new member into the database, like so:
EXEC InsertMember 'John', 'Doe', '1990-01-01', 'john.doe@example.com', '123-456-7890', 
'johndoe', 'password123', '123 Main St', 'Anytown', 'CA', '12345', '2023-04-02', '2024-04-01';


-- 2d)To create a stored procedure that updates the details for an existing member
CREATE PROCEDURE UpdateMember
    @member_id INT,
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @date_of_birth DATE,
    @email VARCHAR(100),
    @phone VARCHAR(20),
    @username VARCHAR(50),
    @hashed_password CHAR(60),
    @street VARCHAR(50),
    @city VARCHAR(50),
    @state VARCHAR(50),
    @post_code VARCHAR(10),
    @membership_start_date DATE,
    @membership_end_date DATE
AS
BEGIN
    UPDATE Member
    SET first_name = @first_name,
        last_name = @last_name,
        date_of_birth = @date_of_birth,
        email = @email,
        phone = @phone
    WHERE member_id = @member_id;

    UPDATE MemberAuth
    SET username = @username,
        hashed_password = @hashed_password
    WHERE member_id = @member_id;

    UPDATE MemberAddress
    SET street = @street,
        city = @city,
        state = @state,
        post_code = @post_code
    WHERE member_id = @member_id;

    UPDATE Membership
    SET membership_start_date = @membership_start_date,
        membership_end_date = @membership_end_date
    WHERE member_id = @member_id;
END

-- Calling this procedure to update the recently inserted member using UK Credentials:
EXEC UpdateMember 
    @member_id = 6,
    @first_name = 'Peter',
    @last_name = 'Parker',
    @date_of_birth = '1990-01-01',
    @email = 'Peter.Park@example.com',
    @phone = '555-1190',
    @username = 'PeterParker',
    @hashed_password = 'password123',
    @street = '456 High St',
    @city = 'London',
    @state = '',
    @post_code = 'SW1A 2AA',
    @membership_start_date = '2023-04-02',
    @membership_end_date = '2024-04-01';

SELECT *
FROM Member

-- Problem 3: The library wants be able to view the loan history, showing all previous and currentloans,
-- and including details of the item borrowed, borrowed date, due date and anyassociated fines for each loan.
CREATE VIEW LoanHistory
AS
SELECT 
    l.loan_id, 
    l.member_id, 
    m.first_name + ' ' + m.last_name AS Borrower_Name, 
    l.item_id, 
    i.item_title AS ItemTitle, 
    l.loan_date, 
    l.due_date, 
    l.return_date, 
    CASE
        WHEN l.return_date IS NULL AND l.due_date < GETDATE() THEN DATEDIFF(DAY, l.due_date, GETDATE()) * 0.5
        WHEN l.return_date IS NOT NULL AND l.return_date > l.due_date THEN DATEDIFF(DAY, l.due_date, l.return_date) * 0.5
        ELSE 0
    END AS Fines
FROM 
    Loan l
    JOIN Member m ON l.member_id = m.member_id
    JOIN Catalogue i ON l.item_id = i.item_id;

-- Querying the LoanHistory to test the View
SELECT * 
FROM LoanHistory;


--Problem 4: Create a trigger so that the current status of an item automatically updates to Available when the book is returned
CREATE TRIGGER update_item_status
ON Loan
AFTER UPDATE
AS
BEGIN
  IF UPDATE(return_date)
  BEGIN
    UPDATE Catalogue
    SET item_status = 'Avaiable'
    FROM Catalogue c
    INNER JOIN inserted i ON c.item_id = i.item_id
    WHERE i.return_date IS NOT NULL;
  END
END


-- To test the functionality of the trigger
-- Borrowing an item and recording the loan
DECLARE @item_id INT = 1;
DECLARE @member_id INT = 1;

UPDATE Catalogue SET item_status = 'On Loan' WHERE item_id = @item_id;

INSERT INTO Loan (member_id, item_id, loan_date, due_date)
VALUES (@member_id, @item_id, GETDATE(), DATEADD(day, 14, GETDATE()));

-- Returning the item to trigger the status update
UPDATE Loan SET return_date = GETDATE() WHERE item_id = @item_id;

-- Checking if the trigger worked
SELECT item_status FROM Catalogue WHERE item_id = @item_id;


-- Problem 5: To provide the library with the total number of loans made on a specified date
-- Using  a Function --
CREATE FUNCTION TotalLoansOnDate (@loan_date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @total_loans INT;
    
    SELECT @total_loans = COUNT(*) 
    FROM Loan 
    WHERE loan_date = @loan_date;
    
    RETURN @total_loans;
END;
-- Using the function to get the total number of loans made on a specific date, like this
SELECT dbo.TotalLoansOnDate('2023-04-16') AS 'Total Loans'

--Problem 5b: Using a View that allow the library to identify the total number of loans made on a specified date:
CREATE VIEW LoansOnDate AS
SELECT loan_date, COUNT(*) AS num_loans
FROM Loan
GROUP BY loan_date

-- To test that the view was stored successfully --
SELECT num_loans
FROM LoansOnDate
WHERE loan_date = '2023-04-16'


--Problem 5c: Using a Select Query that allow the library to identify the total number of loans made on a specified date: --
SELECT COUNT(*) AS num_loans
FROM Loan
WHERE loan_date = '2023-04-16'



-- For additional database object that may be relevant to the library
-- The client may want to consider a limit on the number of items that can be borrowed by a member at a time

-- I'll first update my catalogue table columns to include item count
ALTER TABLE Catalogue
ADD item_count INT NOT NULL DEFAULT 0;

-- This stored procedure checks if a member has reached their borrowing limit before allowing them to borrow more items
CREATE PROCEDURE CheckBorrowingLimit
    @member_id INT,
    @item_count INT
AS
BEGIN
    DECLARE @current_borrowed INT;
    DECLARE @borrowing_limit INT;
    
    -- Get the number of items currently borrowed by the member
    SELECT @current_borrowed = COUNT(*) 
    FROM Loan 
    WHERE member_id = @member_id AND return_date IS NULL;
    
    -- Get the borrowing limit for the member
    SELECT @borrowing_limit = item_count 
    FROM Catalogue 
    WHERE item_id = @member_id;
    
    -- Check if the member has reached their borrowing limit
    IF @current_borrowed + @item_count > @borrowing_limit
    BEGIN
        -- Throw an error if the member has reached their borrowing limit
        RAISERROR('Member has reached their borrowing limit', 16, 1);
        RETURN;
    END
    
    -- Otherwise, allow the member to borrow more items
    PRINT 'Member is within borrowing limit';
END


-- Test the CheckBorrowingLimit stored procedure
DECLARE @member_id INT = 5;
DECLARE @item_count INT = 0;

EXEC CheckBorrowingLimit @member_id, @item_count;


