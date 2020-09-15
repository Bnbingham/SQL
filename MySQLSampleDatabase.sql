use mysqldb;

DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS login_info;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS purchased_item;

#-----------------------------tables------------------------------------
CREATE TABLE customer(
	id int AUTO_INCREMENT PRIMARY KEY,
    first_name varchar(30) NOT NULL,
    last_name varchar(30) NOT NULL,
    email varchar(50) UNIQUE CHECK (email = lower(email))
);
CREATE TABLE login_info(
	id int PRIMARY KEY
		REFERENCES customer(id) ON UPDATE CASCADE ON DELETE CASCADE ,
    username varchar(30) UNIQUE NOT NULL,
    password varchar(30) NOT NULL
);

CREATE TABLE purchase(
	id int AUTO_INCREMENT PRIMARY KEY,
    customerID int 
		REFERENCES customer (id) ON UPDATE CASCADE ON DELETE SET NULL,
    date_loaded datetime
);

CREATE TABLE item(
	id int AUTO_INCREMENT PRIMARY KEY,
    product varchar(30) NOT NULL UNIQUE,
    price decimal(4,2) NOT NULL
);

CREATE TABLE purchased_items(
	purchaseID int REFERENCES purchase (id),
    itemID int REFERENCES item (id),
    quantity int NOT NULL,
    PRIMARY KEY(purchaseID,itemID)
);

#-------------------------------------views------------------------------------
CREATE OR REPLACE VIEW customers
AS
	SELECT customer.id, first_name, last_name, email, username, password
	FROM customer
	INNER JOIN login_info ON customer.id = login_info.id;
    
CREATE OR REPLACE VIEW sold_items
AS
	SELECT * FROM purchased_items INNER JOIN item ON purchased_items.itemID = item.id;
    
CREATE OR REPLACE VIEW purchases
AS
	SELECT 
		purchase.id,
		CONCAT(customer.first_name, ' ', customer.last_name) AS 'customer_name',
		date(purchase.date_loaded) AS 'purchase_date',
		(SELECT COUNT(*) FROM purchased_items WHERE purchaseID = purchase.id) AS 'unique_items',
		(SELECT SUM(quantity) FROM sold_items WHERE purchaseID = purchase.id) AS 'total_items',
		(SELECT SUM(quantity * price) FROM sold_items WHERE purchaseID = purchase.id) AS 'total_price'
	FROM purchase
	INNER JOIN customer ON purchase.id = customer.id;
    

#----------------------------proceedures---------------------------------
drop procedure if exists add_customer;
DELIMITER $$
CREATE PROCEDURE `add_customer` (fName varchar(30), lName varchar(30),email varchar(50),username varchar(30),password varchar(30))
BEGIN
	insert into customer values(NULL,fName,lName,email);
	insert into login_info values(last_insert_id(),username, password);
END $$
DELIMITER ;




#------------------------------Notes--------------------------------------
select now(); #2020-09-15 12:04:24
select curdate(); #2020-09-15
select date('2020-09-15 23:01:00 +3:00'); #2020-09-15
select adddate('2020-09-15',4); #2020-09-19
select curtime(); #12:12:09
select timediff('12:12:09','01:00:00'); #11:12:09
select time('211344'); #21:13:44
select dayname('2020_09@15'); #Tuesday

#---for pagination---
select * from customers 
where id >= 1 #may be a faster way than using offset when querying larger data souces
order by id 
limit 20;
