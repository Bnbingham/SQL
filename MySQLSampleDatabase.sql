use mysqldb;
drop table customer;
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







------------------------------------------------------------------------------------------------------------------------
insert into customer values (NULL,'Brad','Bingham',NULL);
select * from customer;

SHOW TABLE STATUS FROM `mysqldb` WHERE `name` LIKE 'customer';

SELECT `AUTO_INCREMENT`
FROM  INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'mysqldb'
AND   TABLE_NAME   = 'customer';

SELECT last_insert_id();

/*
CREATE PROCEDURE `new_procedure` (fName varchar(30), lName varchar(30),email varchar(50),username varchar(30),password varchar(30))
BEGIN
	insert into customer values(NULL,fName,lName,email);
	insert into login_info values(last_insert_id(),username, password);
END 
*/
