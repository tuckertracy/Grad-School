use ClassicModels; 
# Write a query to list out the names of products, their product line and the number of customers that have purchased them.
SELECT productName, productLine, count(DISTINCT customerNumber) as CusNum FROM Products 
	JOIN OrderDetails 
	ON (Products.productCode=OrderDetails.productCode)
	JOIN Orders ON (OrderDetails.orderNumber=Orders.orderNumber)
    GROUP BY Products.productCode;
    
# Write a query to list out the product vendor and the number of different customers they have shipped orders to.
SELECT productVendor, count(distinct customerNumber) as CusNum FROM Products 
	JOIN OrderDetails 
	ON (Products.productCode=OrderDetails.productCode)
	JOIN Orders ON (OrderDetails.orderNumber=Orders.orderNumber)
    GROUP BY productVendor;
    
SELECT productVendor, count(distinct customerNumber) as CusNum FROM Products as P 
	JOIN OrderDetails as OD
	ON (P.productCode=OD.productCode)
	JOIN Orders as O ON (OD.orderNumber=O.orderNumber)
    GROUP BY productVendor;
    
# EXISTS
use Text;
SELECT itemname, itemcolor FROM item
	WHERE itemtype = 'C'
		AND EXISTS (SELECT * FROM lineitem WHERE lineitem.itemno = item.itemno);
        
# Alternative: INNER JOIN 
SELECT itemname, itemcolor FROM item JOIN lineitem ON (lineitem.itemno = item.itemno)
	WHERE itemtype='C';
    
# Alternative: Subquery
SELECT itemname, itemcolor FROM item
	WHERE itemtype = 'C'
		AND (SELECT COUNT(*) FROM lineitem WHERE lineitem.itemno = item.itemno)>0;

SELECT itemname, itemcolor FROM item
	WHERE itemtype = 'C'
		AND itemno IN (SELECT lineitem.itemno FROM lineitem WHERE lineitem.itemno = item.itemno);        
      
# NOT EXISTS
SELECT itemname, itemcolor FROM item
		 WHERE itemtype = 'C'
			 AND NOT EXISTS
				(SELECT * FROM lineitem
					WHERE item.itemno = lineitem.itemno);

# Alternative: OUTER JOIN 
SELECT itemname, itemcolor, lineitem.itemno as LineItemTableNo, item.itemno as ItemTableNo
	FROM item LEFT JOIN lineitem ON (lineitem.itemno = item.itemno)
	WHERE itemtype='C'; 
    
# Alternative: Subquery
SELECT itemname, itemcolor FROM item
	WHERE itemtype = 'C'
		AND (SELECT COUNT(*) FROM lineitem WHERE lineitem.itemno = item.itemno)=0;

# Practice
# List the first and last name of employees with the title ‘Sales Rep’ that do not serve any Customers. 
use ClassicModels;
SELECT lastName, firstName FROM Employees
	WHERE jobTitle="Sales Rep"
		AND NOT EXISTS 
        (SELECT * FROM Customers WHERE Employees.employeeNumber=Customers.salesRepEmployeeNumber);
 
#List the names of products that have not been ordered.
SELECT productName FROM Products
	WHERE NOT EXISTS 
		(SELECT * FROM OrderDetails WHERE OrderDetails.productCode=Products.productCode);
        
# UNION
use Text;
SELECT itemname FROM item JOIN lineitem
	ON item.itemno = lineitem.itemno
	JOIN sale ON lineitem.saleno = sale.saleno
	WHERE saledate = '2011-01-16'
UNION
	SELECT itemname FROM item WHERE itemcolor = 'Brown';

# Alternative: Wrong
SELECT distinct itemname FROM item JOIN lineitem
	ON item.itemno = lineitem.itemno
	JOIN sale ON lineitem.saleno = sale.saleno
	WHERE saledate = '2011-01-16' OR itemcolor = 'Brown'; 

# Alternative: INNER JOIN
SELECT distinct itemname, itemcolor as ItemTableItemNo 
		FROM item, lineitem, sale
		WHERE (item.itemno = lineitem.itemno AND lineitem.saleno = sale.saleno 
				AND saledate = '2011-01-16') OR itemcolor = 'Brown';
        
# INTERSECT: Not working for MySQL
SELECT itemname FROM item JOIN lineitem
	ON item.itemno = lineitem.itemno
	JOIN sale ON lineitem.saleno = sale.saleno
	WHERE saledate = '2011-01-16'
INTERSECT
	SELECT itemname FROM item WHERE itemcolor = 'Brown';

# Alternative: INNER JOIN
SELECT distinct itemname, itemcolor, lineitem.itemno, item.itemno as ItemTableItemNo 
		FROM item, lineitem, sale
		WHERE item.itemno = lineitem.itemno AND lineitem.saleno = sale.saleno 
				AND saledate = '2011-01-16' AND itemcolor = 'Brown';        

SELECT distinct itemname, itemcolor FROM item
	WHERE itemcolor = 'Brown' 
		AND itemno IN (SELECT item.itemno FROM item JOIN lineitem 
						ON item.itemno = lineitem.itemno JOIN sale
                        ON lineitem.saleno = sale.saleno
                        WHERE saledate = '2011-01-16');	
                        