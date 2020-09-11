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
insert into customer values (NULL,'Brad','Bingham',NULL);
select * from customer;





