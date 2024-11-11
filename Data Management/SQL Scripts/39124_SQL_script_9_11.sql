use Text;
SELECT natname, SUM(stkprice*stkqty*exchrate) AS stkvalue
	FROM stock JOIN nation ON stock.natcode = nation.natcode
		GROUP BY natname;

SELECT natname, SUM(stkprice*stkqty*exchrate) AS stkvalue
	FROM stock JOIN nation ON stock.natcode = nation.natcode	
    GROUP BY natname		
    HAVING COUNT(*) >= 2;

# Report the total dividend payment for each country that has three or more stocks in the portfolio
SELECT natname, SUM(stkdiv*exchrate) AS Totstkdiv
	FROM stock JOIN nation ON stock.natcode = nation.natcode	
    GROUP BY natname		
    HAVING COUNT(stkcode) >= 3;
    
# Display each department and the number of faculty members in it, for those departments that have 2 or fewer faculty members
use Chapter4;
SELECT deptName, count(facID) as NumProfessor FROM Department JOIN Professor
	ON Department.deptID=Professor.deptID
    GROUP BY Professor.deptID
    HAVING count(facID)<=2; 

# Write a query to list the customer name and total values of payments made by the customer.
use ClassicModels;
SELECT customerName, SUM(Payments.amount) FROM Customers JOIN Payments
		ON Customers.customerNumber=Payments.customerNumber
        GROUP BY Customers.customerNumber;
        
SELECT customerName, SUM(Payments.amount) as TotPayment, 
		100*SUM(Payments.amount)/(SELECT SUM(Payments.amount) FROM Payments) as PercentagePayment
		FROM Customers JOIN Payments
		ON Customers.customerNumber=Payments.customerNumber
        GROUP BY Customers.customerNumber;

SELECT SUM(Payments.amount) FROM Payments; 

# INNER JOIN
SELECT customerName, checkNumber, amount 
	FROM Customers JOIN Payments	
	ON Customers.customerNumber=Payments.customerNumber;
      
# LEFT JOIN 
SELECT customerName, checkNumber, amount 
	FROM Customers LEFT JOIN Payments	
	ON Customers.customerNumber=Payments.customerNumber;

# RIGHT JOIN
SELECT customerName, checkNumber, amount 
	FROM Customers RIGHT JOIN Payments	
	ON Customers.customerNumber=Payments.customerNumber;
    
SELECT customerName, checkNumber, amount 
	FROM Payments RIGHT JOIN Customers	
	ON Customers.customerNumber=Payments.customerNumber;
    
use Chapter4;
SELECT deptName, count(facID) as NumberProfessor 
	FROM Department JOIN Professor	
	ON Department.deptID=Professor.deptID
    GROUP BY Department.deptID;

SELECT deptName, count(facID) as NumberProfessor 
	FROM Department LEFT JOIN Professor	
	ON Department.deptID=Professor.deptID
    GROUP BY Department.deptID; 


use Text;    
# Find those stocks where the quantity is greater than the average for that country.
SELECT natname, stkfirm, stkqty FROM stock JOIN nation
	ON stock.natcode = nation.natcode
	WHERE stkqty > 
		(SELECT AVG(stkqty) FROM stock
		WHERE  stock.natcode = nation.natcode);
    
SELECT AVG(stkqty) FROM stock
		WHERE  stock.natcode = nation.natcode;    


# Report the country, firm, and stock holding for the maximum quantity of stock held for each country
SELECT natname, stkfirm, stkqty FROM stock JOIN nation
	ON stock.natcode = nation.natcode
	WHERE stkqty = 
		(SELECT MAX(stkqty) FROM stock
		WHERE  stock.natcode = nation.natcode);

SELECT natName, MAX(stkqty) FROM stock JOIN nation
		WHERE  stock.natcode = nation.natcode
        GROUP BY natName;

# Display the recipe name, prep time and source website for those recipes whose prep time is less than the average prep time for all recipes.
use Chapter4;
SELECT Rec_name, Rec_prep_time, Source_website
	FROM Recipe JOIN Source ON (Recipe.Source_ID=Source.Source_ID)
    WHERE Rec_prep_time<(SELECT avg(Rec_prep_time) FROM Recipe); 
    
SELECT avg(Rec_prep_time) FROM Recipe;

# Display the recipe name, prep time, and source website for those recipes whose prep time is less than the average prep time of the recipes from that same source.
SELECT Rec_name, Rec_prep_time, Source_website
	FROM Recipe JOIN Source ON (Recipe.Source_ID=Source.Source_ID)
    WHERE Rec_prep_time<(SELECT avg(Rec_prep_time) FROM Recipe
			WHERE Recipe.Source_ID=Source.Source_ID);
    
SELECT avg(Rec_prep_time) FROM Recipe
	WHERE Recipe.Source_ID=Source.Source_ID;
    
# Print out customer name, contact information, check number and amount for those checks that were greater than the average amount of the check payments for that customer
use ClassicModels; 
SELECT customerName, contactLastName, contactFirstName, amount FROM Customers JOIN Payments 
	ON (Customers.customerNumber=Payments.customerNumber)
    WHERE amount>(SELECT avg(amount) FROM Payments
	WHERE Customers.customerNumber=Payments.customerNumber);
    
SELECT avg(amount) FROM Payments
	WHERE Customers.customerNumber=Payments.customerNumber;






    