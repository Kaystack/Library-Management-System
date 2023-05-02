# Library-Management-System
This is a database schema for a library management system. The schema includes normalized tables for members, catalogue of items, loans, overdue fines and repayments.
It tracks members, items, loans, fines, and repayments. The system is built using SQL Server and follows the Third Normal Form (3NF) for database design.

# Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

# Prerequisites
SQL Server
SQL Server Management Studio

# Tables
The following tables are included in this schema:

Member: stores details of library members such as their name, date of birth, email and phone number.

MemberAuth: stores the username and hashed password for each member.

MemberAddress: stores the address details for each member.

Membership: stores the membership start and end dates for each member.

Catalogue: stores details of all items in the library such as the title, author, publication year and status.

Loan: stores details of all loans including the member who borrowed the item, the item borrowed, the loan date, due date and return date.

OverdueFine: stores details of all overdue fines including the member who owes the fine, the total fine amount, the repaid amount and the outstanding balance.

Repayment: stores details of all repayments made by members to settle their overdue fines.

# Usage
To use this schema, create a new database in your preferred RDBMS (e.g. MySQL, PostgreSQL) and run the SQL script to create the tables. You can then insert data into the tables to test the schema.

# Contributing
Contributions to this project are welcome. Feel free to fork this repository and submit a pull request if you would like to make any improvements.
