--User and grant privilages
CREATE USER sampleDatabase
    IDENTIFIED BY Pa55word
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA 10M ON users;

GRANT connect to sampleDatabase;
GRANT resource to sampleDatabase;
GRANT create session TO sampleDatabase;
GRANT create table TO sampleDatabase;
GRANT create view TO sampleDatabase;

conn sampleDatabase/Pa55word
----------------------------
--Tables
--Customer/Login_info are seperate to demonstrate how to work with a one-to-one relationship
CREATE TABLE customer(
    id number GENERATED AS IDENTITY PRIMARY KEY,
    first_name varchar2(30) NOT NULL,
    last_name varchar2(30) NOT NULL,
    email varchar2(50) UNIQUE,
    CONSTRAINT person_ck_email_lower_case CHECK (email = LOWER(email))
);

CREATE TABLE login_info(
    id number REFERENCES customer(id) ON DELETE CASCADE PRIMARY KEY,
    username varchar2(30) NOT NULL UNIQUE,
    password varchar2(30) NOT NULL
);

--purchase, item and purchasedItems to demonstrate one-to-many and many-to-many relationship
CREATE TABLE purchase(
    id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    customerID REFERENCES customer(id) ON DELETE SET NULL,
    date_loaded TIMESTAMP(6) WITH TIME ZONE
);
CREATE TABLE item(
    id number GENERATED AS IDENTITY PRIMARY KEY,
    product varchar2(30),
    price number(*,2)
);
CREATE TABLE purchased_items(
    purchaseID number REFERENCES purchase (id),
    itemID number REFERENCES item (id),
    quantity number NOT NULL,
    PRIMARY KEY(purchaseID,itemID)
);

--Views
CREATE OR REPLACE VIEW customers 
AS 
    SELECT customer.id, customer.first_name, customer.last_name,customer.email,login_info.username,login_info.password
    FROM customer
    INNER JOIN login_info ON customer.id = login_info.id;

CREATE OR REPLACE VIEW purchases
AS
    SELECT 
        purchase.id, 
        (customer.first_name||' '||customer.last_name) AS customer_name,
        to_char(purchase.date_loaded, 'DD-Mon-YYYY') AS purchase_date,
        (SELECT COUNT(*) FROM purchased_items WHERE purchaseID=purchase.id) as unique_items,
        (SELECT SUM(quantity) FROM purchased_items INNER JOIN item ON itemID = id WHERE purchaseID=purchase.id ) as total_items,
        (SELECT SUM(quantity * price) FROM purchased_items INNER JOIN item ON itemID = id WHERE purchaseID=purchase.id ) as total_price
    FROM purchase
    INNER JOIN customer ON purchase.customerid = customer.id;

--Procedures
CREATE OR REPLACE PROCEDURE add_customer
(fName varchar2, lName varchar2,email varchar2, username varchar2, password varchar2)
AS
BEGIN
    DECLARE
        cID NUMBER;
    BEGIN
        INSERT INTO customer (first_name, last_name, email)VALUES(fName,lName,email) RETURNING id INTO cID;
        INSERT INTO login_info VALUES(cID,username,password);
    END;
    COMMIT;
END;
/



-------------------------------------------------------------------------------------------------------
--need to make
--function
--something that uses cursors
--trigger
--%TYPE attribute

