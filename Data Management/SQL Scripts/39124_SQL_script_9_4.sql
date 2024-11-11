use Chapter3;
SELECT count(studentID) FROM student
	WHERE state="GA";
    
SELECT count(studentID), state FROM student
	WHERE state="GA" OR state="SC"
    GROUP BY state;
    
use ClassicModels;
SELECT count(customerNumber) as NumCustomers, avg(creditLimit) as AvgLimit, city 
	FROM Customers
	GROUP BY city;

SELECT count(customerNumber) as NumCustomers, avg(creditLimit) as AvgLimit, city 
	FROM Customers
	GROUP BY city
    HAVING count(customerNumber)>=5;

SELECT count(customerNumber) as NumCustomers, avg(creditLimit) as AvgLimit, city 
	FROM Customers
	GROUP BY city
    HAVING NumCustomers>=5;
    
# List out the names of customers whose credit limit is greater than the average credit limit.
SELECT customerName FROM Customers
	WHERE creditLimit>(SELECT avg(creditLimit) FROM Customers)
    LIMIT 10;
    
SELECT avg(creditLimit) FROM Customers;

# List out the name of the customer who has the greatest credit limit.
SELECT customerName FROM Customers
	WHERE creditLimit=(SELECT max(creditLimit) FROM Customers);
    
SELECT max(creditLimit) FROM Customers;

SELECT customerName FROM Customers
	ORDER BY creditLimit DESC
    LIMIT 1;
    
# CREATE TABLE
use lx_try;
DROP TABLE Ship;
CREATE TABLE Ship(
	shpName Varchar(40),
    shpCode INT,
    shpGrsTon DECIMAL (6,2),
    shpYear Year,
    shpType ENUM('Commercial','Cargo') DEFAULT 'Commercial',
		PRIMARY KEY(shpCode)
);

DESC Ship;

INSERT INTO Ship VALUES ('Courage',123,3.2,2024,'Commercial');
SELECT * FROM Ship;

INSERT INTO Ship (shpName, shpCode) VALUES ('MayFlower',124);

INSERT INTO Ship VALUES ('SunFlower',125,NULL,NULL,NULL);

SELECT * FROM share;
INSERT INTO share VALUES ('FC1','Freedonia Copper',27.5,10529,1.84,16);

DELETE FROM share
	WHERE shrcode='FC1';
    
UPDATE share 
	SET shrprice=shrprice*1.1
	WHERE shrcode='FC';
    
# DDL
ALTER TABLE Ship
	ADD COLUMN shrAction Varchar(25);
    
DESC Ship;  

ALTER TABLE Ship
	MODIFY COLUMN shrAction Varchar(30) DEFAULT 'No Action';  
    
ALTER TABLE Ship
	DROP COLUMN shrAction;

# Constaints
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE TABLE_NAME = 'Ship' AND 
		TABLE_SCHEMA = 'lx_try';

ALTER TABLE Ship DROP PRIMARY KEY;
ALTER TABLE Ship ADD PRIMARY KEY (shpCode);


