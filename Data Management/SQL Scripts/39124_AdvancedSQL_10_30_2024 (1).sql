use lx_try;

CREATE TABLE nation (
	 natcode		CHAR(3),
	 natname		VARCHAR(20),
	 exchrate	DECIMAL(9,5),
		PRIMARY KEY (natcode));
CREATE TABLE stock (
	 stkcode		CHAR(3),
	 stkfirm		VARCHAR(20),
	 stkprice		DECIMAL(6,2),
	 stkqty		DECIMAL(8),
	 stkdiv		DECIMAL(5,2),
	 stkpe		DECIMAL(5),
	 natcode		CHAR(3),
	PRIMARY KEY(stkcode),
	CONSTRAINT fk_has_nation FOREIGN KEY(natcode) 
	REFERENCES nation(natcode) ON DELETE RESTRICT);

CREATE VIEW stkvalue
	(nation, firm, price, qty, exchrate, value)
	AS SELECT natname, stkfirm, stkprice, stkqty, exchrate,
		stkprice*stkqty*exchrate
	        FROM stock JOIN nation
	        ON stock.natcode = nation.natcode;

# Create another view
CREATE VIEW EMPDEPT(s_emp_id, last_name, first_name, s_dept_id, dept_name)
	AS SELECT s_emp_id, last_name, first_name, s_dept_id, name
		FROM s_emp JOIN s_dept ON s_emp.dept_id=s_dept.s_dept_id
        WHERE name="Sales";
        
SELECT * FROM EMPDEPT;

# CREATE FUNCTION
DELIMITER //
CREATE FUNCTION km_to_mile(km REAL) RETURNS REAL
DETERMINISTIC
BEGIN 
	DECLARE miles REAL; 
	SET miles=0.6213712*km; 
	RETURN miles;
END //

SELECT FORMAT(km_to_mile(100),0);

# Another function
DELIMITER //
CREATE FUNCTION salaryraise (salary REAL)  
RETURNS REAL 
DETERMINISTIC
BEGIN    
	DECLARE newsalary REAL;    
	SET newsalary=salary*1.1;    
	RETURN newsalary;
END //
DELIMITER ; 

SELECT s_emp_id, salary, salaryraise(salary) as NewSalary FROM s_emp; 

# Build another function
DELIMITER //
CREATE FUNCTION Natcode_Lookup (LookUpNatname VARCHAR(20)) 
RETURNS VARCHAR(3)
READS SQL DATA
BEGIN
	DECLARE TheValue VARCHAR(3);
    SET TheValue=(SELECT Natcode FROM nation_view WHERE Natname=LookUpNatname);
    RETURN (RTRIM(LTRIM(TheValue)));
END //
DELIMITER ;

CREATE VIEW nation_view
AS SELECT * FROM Text.nation; 

SELECT * FROM nation_view;
SELECT Natcode_Lookup("Australia");

# Stored Procedures
CREATE TABLE account (
acctno INTEGER,
acctbalance DECIMAL(9,2),
primary key (acctno));

CREATE TABLE transaction (
transid INTEGER,
transamt DECIMAL(9,2),
transdate DATE,
PRIMARY KEY(transid));

CREATE TABLE entry (
transid INTEGER,
acctno INTEGER,
entrytype CHAR(2),
PRIMARY KEY(acctno, transid),
CONSTRAINT fk_account FOREIGN KEY(acctno) REFERENCES account(acctno),
CONSTRAINT fk_transaction FOREIGN KEY(transid) REFERENCES transaction(transid));

INSERT INTO account VALUES (1,1000);
INSERT INTO account VALUES (2,1000);

DELIMITER //
CREATE PROCEDURE transfer (
IN cracct INTEGER, 
IN dbacct INTEGER, 
IN amt DECIMAL(9,2),
IN transno INTEGER)
LANGUAGE SQL
DETERMINISTIC
BEGIN
INSERT INTO transaction VALUES (transno, amt, CURRENT_DATE);
UPDATE account
	SET acctbalance = acctbalance + amt
	WHERE acctno = cracct;
INSERT INTO entry VALUES (transno, cracct, 'cr');
UPDATE account
	SET acctbalance = acctbalance - amt
WHERE acctno = dbacct;
INSERT INTO entry VALUES (transno, dbacct, 'db');
END//
DELIMITER ;

SELECT * FROM account; 
SELECT * FROM transaction;
SELECT * FROM entry order by transid;

CALL transfer(1,2,100,1005);
CALL transfer(2,1,500,1010);

# IN, OUT, INOUT parameters
DELIMITER //
CREATE PROCEDURE CountProduct_Inventory (IN ProdName VARCHAR(50),
					OUT ProductInv INT,
                    INOUT TotalInv INT, INOUT InvString VARCHAR(255))
BEGIN
	SELECT SUM(amount_in_stock) INTO ProductInv 
		FROM s_product JOIN s_inventory ON s_product.s_product_id=s_inventory.product_id
		WHERE s_product.name=ProdName
        GROUP BY s_product.name;
	
    SET TotalInv=TotalInv+ProductInv;
    SET InvString=CONCAT(InvString,ProdName,"=",ProductInv,"    ");
END //
DELIMITER ;

SET @TotalInv=0;
SET @ProductInv=0;
SET @InvString="Product/Inventory:- "; 

CALL CountProduct_Inventory("Bunny Boot",@ProductInv,@TotalInv,@InvString);
SELECT @ProductInv,@TotalInv,@InvString;
CALL CountProduct_Inventory("Junior Soccer Ball",@ProductInv,@TotalInv,@InvString);
SELECT @ProductInv,@TotalInv,@InvString;
CALL CountProduct_Inventory("Ace Ski Pole",@ProductInv,@TotalInv,@InvString);
SELECT @ProductInv,@TotalInv,@InvString;

# Trigger
CREATE TABLE stock
	AS SELECT * FROM Text.stock; 
SELECT * FROM stock;

CREATE TABLE stock_log (
   stkcode		CHAR(3),
   old_stkprice	DECIMAL(6,2),
   new_stkprice	DECIMAL(6,2),
   old_stkqty		DECIMAL(8),
   new_stkqty		DECIMAL(8),
   update_stktime	TIMESTAMP NOT NULL,
   	PRIMARY KEY(update_stktime));

DELIMITER //
CREATE TRIGGER stock_update
AFTER UPDATE ON stock
FOR EACH ROW BEGIN
INSERT INTO stock_log VALUES 
	(OLD.stkcode, OLD.stkprice, NEW.stkprice, OLD.stkqty, NEW.stkqty, CURRENT_TIMESTAMP);
END//
DELIMITER ;

SELECT * FROM stock_log; 

UPDATE stock SET stkprice=40 WHERE stkcode="AR";

SELECT * FROM stock;
UPDATE stock SET stkprice=50 WHERE stkcode="BD";
UPDATE stock SET stkprice=50 WHERE stkcode="BD";

# Excercise: Store Procedure
DROP PROCEDURE IF EXISTS GetProductLevel;

DELIMITER //
CREATE PROCEDURE GetProductLevel(IN ProdID INT,
	OUT ProdLevel VARCHAR(20),
    INOUT ProdCheckedCount INT)
BEGIN
	DECLARE whlsl_price DECIMAL(10,2) DEFAULT 0;
    
    SELECT suggested_whlsl_price INTO whlsl_price 
		FROM s_product WHERE s_product_id=ProdID;
	
    IF (whlsl_price>=500) THEN
		SET ProdLevel="Premium";
    ELSE
		SET ProdLevel="Regular";
    END IF;
    
    SET ProdCheckedCount=ProdCheckedCount+1;
END; //
DELIMITER ;

SET @ProdLevel=""; 
SET @ProdCheckedCount=0;

CALL GetProductLevel(30321,@ProdLevel,@ProdCheckedCount);
SELECT @ProdLevel,@ProdCheckedCount;
CALL GetProductLevel(10011,@ProdLevel,@ProdCheckedCount);
SELECT @ProdLevel,@ProdCheckedCount;
CALL GetProductLevel(10012,@ProdLevel,@ProdCheckedCount);
SELECT @ProdLevel,@ProdCheckedCount;


# CASE WHEN
DROP PROCEDURE IF EXISTS GetProductLevel;

DELIMITER //
CREATE PROCEDURE GetProductLevel(IN ProdID INT,
	OUT ProdLevel VARCHAR(20),
    INOUT ProdCheckedCount INT)
BEGIN
	DECLARE whlsl_price DECIMAL(10,2) DEFAULT 0;
    
    SELECT suggested_whlsl_price INTO whlsl_price 
		FROM s_product WHERE s_product_id=ProdID;
	
	CASE
		WHEN whlsl_price>=500 THEN SET ProdLevel="Premium";
        WHEN whlsl_price<500 AND whlsl_price>=100 THEN SET ProdLevel="Regular";
        WHEN whlsl_price<100 THEN SET ProdLevel="Discount";
    END CASE;
    
    SET ProdCheckedCount=ProdCheckedCount+1;
END; //
DELIMITER ;

SET @ProdLevel=""; 
SET @ProdCheckedCount=0;

CALL GetProductLevel(30326,@ProdLevel,@ProdCheckedCount);
SELECT @ProdLevel,@ProdCheckedCount;
CALL GetProductLevel(20201,@ProdLevel,@ProdCheckedCount);
SELECT @ProdLevel,@ProdCheckedCount;
CALL GetProductLevel(10022,@ProdLevel,@ProdCheckedCount);
SELECT @ProdLevel,@ProdCheckedCount;


# CASE WHEN in SELECT
SELECT itemno, itemname,
CASE
	when itemtype = "E" then "Equipment" 
	when itemtype = "C" then "Clothing"
	when itemtype = "N" then "Navigation"
	when itemtype = "F" then "Furniture"
		else "UNKNOWN" end as "TYPE OF ITEM"
FROM Text.item;

SELECT
   SUM(CASE WHEN productCode REGEXP '^S10' THEN quantityOrdered END) AS qty_ordered_S10,
    SUM(CASE WHEN productCode REGEXP '^S12' THEN quantityOrdered END) AS qty_ordered_S12,
    SUM(CASE WHEN productCode NOT REGEXP '^S12' AND productCode NOT REGEXP '^S10' THEN quantityOrdered END) AS qty_ordered_SXX
FROM ClassicModels.OrderDetails;

# Exercise: Trigger as Validation 
CREATE TABLE emp AS SELECT * FROM Text.emp;

DROP TRIGGER IF EXISTS tr_emp_dept_check;
DELIMITER //
CREATE TRIGGER tr_emp_dept_check
BEFORE INSERT ON emp
FOR EACH ROW
BEGIN
	DECLARE Mtext Text;
    
    IF (SELECT COUNT(*) FROM dept WHERE deptname=NEW.deptname)=0 THEN
		SET Mtext=CONCAT("invalid department name: ",NEW.deptname);
        SIGNAL SQLSTATE "HY000" SET MYSQL_ERRNO=1525, MESSAGE_TEXT=Mtext;
    END IF;
END; //
DELIMITER ;

SELECT * FROM emp;
DELETE FROM emp WHERE empno=50000;
INSERT INTO emp VALUES(50000,"Daniel",40000,"Management",1);
INSERT INTO emp VALUES(60000,"John",50000,"QB",1);

# Cursor Example
DROP PROCEDURE IF EXISTS ExampleCursorProcedure;
DELIMITER //
CREATE PROCEDURE ExampleCursorProcedure()
BEGIN	
DECLARE done INT DEFAULT FALSE;    
DECLARE col1 INT;    
DECLARE col2 VARCHAR(25);
DECLARE Dynamic_Dept_Cursor CURSOR FOR 		
	SELECT s_dept.s_dept_id, s_dept.name FROM s_dept ORDER BY s_dept.name; #Open the Cursor	
open Dynamic_Dept_Cursor; 	
#More Fetch Practices	
FETCH Dynamic_Dept_Cursor INTO col1,col2;  #fetch the first row    
SELECT col1, col2;	
FETCH Dynamic_Dept_Cursor INTO col1,col2;  #fetch the next row    
SELECT col1, col2;    
CLOSE Dynamic_Dept_Cursor;    
END;// 
DELIMITER ;
    
SELECT s_dept.s_dept_id, s_dept.name FROM s_dept ORDER BY s_dept.name; 
CALL ExampleCursorProcedure; 

# Another Exercise: Cursor
DROP PROCEDURE IF EXISTS CursorDeptName;
DELIMITER //
CREATE PROCEDURE CursorDeptName(INOUT dept_names_list VARCHAR(200))
BEGIN
	DECLARE done INT DEFAULT 0;
    DECLARE dept_name VARCHAR(25) DEFAULT "";
    DECLARE Dynamic_Dept_Cursor CURSOR FOR
		SELECT distinct dept.deptname FROM dept ORDER BY deptname;
	# DECLARE NOT FOUND handler
    DECLARE CONTINUE HANDLER FOR
		NOT FOUND SET done=1; 
        
    # Open the Cursor    
    OPEN Dynamic_Dept_Cursor;
    # Fetch and list
    process_department: LOOP
		FETCH Dynamic_Dept_Cursor INTO dept_name;
        
        IF (done=1) THEN
			LEAVE process_department;
        END IF;
        
        SET dept_names_list=CONCAT(dept_names_list, "; ", dept_name);
    END LOOP;
    
    CLOSE Dynamic_Dept_Cursor;
END;//
DELIMITER ;

SET @dept_names_list="List of unique department name: ";
SELECT distinct dept.deptname FROM dept ORDER BY deptname;
CALL CursorDeptName(@dept_names_list);
SELECT @dept_names_list;

# Transaction
SELECT * FROM emp;
DELETE FROM emp WHERE empno=3000 OR empno=4000;
BEGIN;
	INSERT INTO emp VALUES (3000, "Carson", 100000, "Marketing", 1);
    INSERT INTO emp VALUES (5000, "Becky", 200000, "Management", 1);
    SELECT * FROM emp;
END;
#ROLLBACK;
COMMIT;
SELECT * FROM emp;

# EVENT
DROP TABLE IF EXISTS mark_log; 
CREATE TABLE mark_log(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    message VARCHAR(20)
);

CREATE EVENT mark_insert
ON SCHEDULE EVERY 5 second
DO INSERT INTO mark_log(message) VALUES ("---MARK---");
 
SELECT * FROM mark_log; 

DROP EVENT mark_log; 

CREATE EVENT mark_expire
ON SCHEDULE EVERY 1 day
DO DELETE FROM mark_log WHERE ts<NOW()-INTERVAL 2 DAY;

DROP EVENT mark_expire;
SELECT * FROM information_schema.EVENTS;

# PARTITION BY
SELECT
    s_emp_id,
    last_name,
    first_name,
    dept_id,
    AVG(salary) OVER() AS 'overall average salary',
    AVG(salary) OVER (PARTITION BY dept_id) AS 'department average salary'
FROM s_emp;

# Write a query to obtain the employee with the second highest salary in each department.
SELECT s_emp_id, last_name, first_name, dept_id, salary 
FROM (
	SELECT s_emp_id, last_name, first_name, dept_id, salary, 
		ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS row_num
    FROM s_emp) AS ranked_dept
WHERE row_num=2;

# WITH 
WITH temporaryTable (averageValue) AS (
    SELECT AVG(salary)
    FROM s_emp
)
SELECT s_emp_id,last_name, first_name,salary 
        FROM s_emp, temporaryTable 
        WHERE s_emp.salary > temporaryTable.averageValue;

# Subquery
SELECT s_emp_id,last_name, first_name,salary 
        FROM s_emp 
        WHERE s_emp.salary > (SELECT AVG(salary) FROM s_emp);