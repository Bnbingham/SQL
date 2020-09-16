-----------------------------User and grant privilages-----------------------------
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

-----------------------------Tables-----------------------------
exec drop_table_if_exists('login_info');
exec drop_table_if_exists('purchased_items');
exec drop_table_if_exists('purchase');
exec drop_table_if_exists('customer');
exec drop_table_if_exists('item');

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
    id number GENERATED AS IDENTITY PRIMARY KEY,
    customerID number REFERENCES customer(id) ON DELETE SET NULL,
    date_loaded TIMESTAMP(2) WITH TIME ZONE 
);
CREATE TABLE item(
    id number GENERATED AS IDENTITY PRIMARY KEY,
    product varchar2(30) UNIQUE NOT NULL,
    price number(*,2) NOT NULL
);
CREATE TABLE purchased_items(
    purchaseID number REFERENCES purchase (id) NOT NULL,
    itemID number REFERENCES item (id) NOT NULL,
    quantity number NOT NULL,
    PRIMARY KEY(purchaseID,itemID)
);

-----------------------------Views-----------------------------
CREATE OR REPLACE VIEW customers 
AS 
    SELECT customer.id, customer.first_name, customer.last_name,customer.email,login_info.username,login_info.password
    FROM customer
    INNER JOIN login_info ON customer.id = login_info.id;

CREATE OR REPLACE VIEW sold_items
AS
    SELECT * 
    FROM purchased_items 
    INNER JOIN item 
    ON itemID = purchased_items.itemid;

CREATE OR REPLACE VIEW purchases
AS
    SELECT 
        purchase.id, 
        (customer.first_name||' '||customer.last_name) AS customer_name,
        to_char(purchase.date_loaded, 'DD-Mon-YYYY') AS purchase_date,
        (SELECT COUNT(*) FROM sold_items WHERE purchaseID=purchase.id) as unique_items,
        (SELECT SUM(quantity) FROM sold_items WHERE purchaseID=purchase.id ) as total_items,
        (SELECT SUM(quantity * price) FROM sold_items WHERE purchaseID=purchase.id ) as total_price
    FROM purchase
    INNER JOIN customer ON purchase.customerid = customer.id;

-----------------------------Procedures-----------------------------
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

-- '-942' is the exception code specifically for "table not found"
CREATE OR REPLACE PROCEDURE drop_table_if_exists
(table_name varchar2)
AS
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ' || table_name;
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN 
         RAISE;
      END IF;
END;
/



----------------------------------------NOTES---------------------------------------------------
exec add_customer('Brad','Bing','email@emial.com','brad1','pass1');
select * from customers;
insert into purchase(customerID, date_loaded) 
    values(1,CURRENT_TIMESTAMP);
select * from purchase;
insert into item(product, price) values ('banana',.25);
insert into item(product, price) values ('apple',.35);
select * from item;
insert into purchased_items values(1,1,2);
insert into purchased_items values(1,2,3);


