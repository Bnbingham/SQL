Use sampleDatabase;
GO
-----------------------------------Tables-----------------------------------
CREATE TABLE customer (
	id int NOT NULL IDENTITY PRIMARY KEY,
	first_name varchar(30) NOT NULL,
	last_name varchar(30) NOT NULL,
	email varchar(50) UNIQUE CHECK (email = LOWER(email))
); 

CREATE TABLE login_info(
	id int REFERENCES customer (id) ON DELETE CASCADE,
	username varchar(30) UNIQUE NOT NULL,
	password varchar(30) NOT NULL
);

CREATE TABLE purchase(
    id int IDENTITY PRIMARY KEY,
    customerID int REFERENCES customer(id) ON DELETE SET NULL,
    date_loaded datetime default GETDATE()
);
CREATE TABLE item(
    id int IDENTITY PRIMARY KEY,
    product varchar(30) UNIQUE NOT NULL,
    price smallmoney NOT NULL --debates on money/smallmoney vs decimal being more precise with rounding
);
CREATE TABLE purchased_items(
    purchaseID int REFERENCES purchase (id) NOT NULL,
    itemID int REFERENCES item (id) NOT NULL,
    quantity int NOT NULL,
    PRIMARY KEY(purchaseID,itemID)
);
GO

-------------------------Views-----------------------------
/*
SQL Server only allows one CREATE TRIGGER statement per batch.
Batches are seperated by the GO keyword
*/
CREATE VIEW customers 
AS
	SELECT customer.id, first_name, last_name, email, username, password
	FROM customer 
	INNER JOIN login_info 
	ON customer.id = login_info.id
	
GO

CREATE VIEW sold_items
AS
	SELECT * 
	FROM purchased_items 
	INNER JOIN item 
	ON purchased_items.itemID = item.id;
GO

CREATE VIEW purchases
AS
	SELECT 
		purchase.id,
		CONCAT(customer.first_name,' ', customer.last_name) AS cutomer_name,
		FORMAT(purchase.date_loaded,'dd/MM/yyyy', 'en-US') AS purchase_date,
		(SELECT COUNT(*) FROM sold_items WHERE purchaseID = purchase.id) AS unique_items,
		(SELECT SUM(quantity) FROM sold_items WHERE purchaseID=purchase.id ) as total_items,
		(SELECT SUM(quantity * price) FROM sold_items WHERE purchaseID=purchase.id ) as total_price
	FROM purchase 
	INNER JOIN customer 
	ON purchase.customerID = customer.id;
GO

-----------------------------------Procedures-------------------------
/*
@ is convention denoting a variable, call with EXEC add_customer @fName = 'name', @lName = ...
*/
CREATE PROCEDURE add_customer
	@fName varchar(30), 
	@lName varchar(30),
	@email varchar(30), 
	@username varchar(30), 
	@password varchar(30)
AS
BEGIN
	INSERT INTO customer (first_name, last_name, email) 
	VALUES(@fName, @lName, @email) 
	
	INSERT INTO login_info 
	VALUES(@@IDENTITY, @username, @password);
END
GO

-----------------------------------NOTES------------------------------
insert into purchase(customerID) values(2);
select * from purchase;
insert into item(product, price) values('banana',.25);
insert into item(product, price) values('apple',.35);
select * from item;
insert into purchased_items values(4,1,10);
insert into purchased_items values(2,2,4);
select * from purchased_items;
select * from customers;
select * from purchases;
select * from sold_items;

-- for _ denotes wildcard single character/numbers, % denotes wildcard any amount of characters/numbers
select * from customers where first_name LIKE '%d';

SELECT customer.id, first_name, last_name, email, username, password
	FROM customer 
	INNER JOIN login_info 
	ON customer.id = login_info.id
	GROUP BY last_name
	ORDER BY first_name DESC;
GO

drop procedure if exists testing_transactions; 
GO


CREATE PROCEDURE testing_transactions
@id int
AS
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE login_info SET login_info.username='user1' WHERE login_info.id = @id;
		COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
	SELECT 'error';
END CATCH
GO

EXEC testing_transactions @id = 1;
select * from login_info;
GO

drop function if exists most_frequent_customer_by_item;
GO

CREATE FUNCTION most_frequent_customer_by_item
(@itemID int)
RETURNS table 
AS
RETURN
	(SELECT TOP 1 
		customerID,
		COUNT(customerID) as 'frequency' 
	FROM sold_items 
	INNER JOIN purchase 
	ON sold_items.purchaseID = purchase.id 
	WHERE itemID = @itemID 
	GROUP BY CustomerID
	ORDER BY frequency DESC
);
GO

select * from most_frequent_customer_by_item(1);