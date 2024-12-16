--HOMEWORK 2

--TEST---------------------
SELECT * FROM dbo.Employee
SELECT * FROM dbo.Customer
SELECT * FROM dbo.Account
SELECT * FROM dbo.AccountDetails
SELECT * FROM dbo.[Location]
SELECT * FROM dbo.Currency
-----------------------------
--H2-1

--List all customers in the database having any transactions in Cities 
--different then the Cities where they belong to.

SELECT DISTINCT
	c.*
FROM
	dbo.AccountDetails as ad
	INNER JOIN dbo.[Location] as l ON ad.LocationId = l.id	 
	INNER JOIN dbo.Account as a ON ad.AccountId = a.id
	INNER JOIN dbo.Customer as c ON a.CustomerId = c.id		
WHERE 
	c.CityId <> l.CityId								
ORDER BY 
	c.ID;

-----------------------------------------------------------
--H2-2

--1.Create query that will contain All possible combinations between 
--Customer First Names and Employee last names. 

SELECT 
	c.FirstName,e.LastName
FROM 
	dbo.Customer as c
	CROSS JOIN 
	dbo.Employee as e;

--2.Put the resultset in new table variable called MyNames.
--Table variable should have only 1 column – MyFullName

DECLARE @MyNames TABLE(
MyFullName nvarchar(200)); 

INSERT INTO @MyNames(MyFullName)
SELECT 
	CONCAT(c.FirstName,' ',e.LastName)
FROM 
	dbo.Customer as c
	CROSS JOIN 
	dbo.Employee as e;

SELECT * FROM @MyNames;

--3.Prepare query that will read the data stored in MyNames table 
--and provide 2 columns as resultset – FirstName and LastName 
--(EXECUTE THE CODE FROM ABOVE TO CREATE THE TABLE VARIABLE)

SELECT 
	LEFT(m.MyFullName, CHARINDEX(' ',m.MyFullName) - 1) as FirstName,
	RIGHT(m.MyFullName, (LEN( m.MyFullName ) - CHARINDEX(' ', m.MyFullName))) as LastName
FROM 
	@MyNames as m;

-------------------------------------------------------------
--H2-3

--Calculate the total Outflow amount for all ATM’s in Resen and 
--Kumanovo performed by customers born after 1905.12.01 

CREATE TABLE #Customers(     --Customers table 
CustomerID int );

DECLARE @DateOfBirth date='1905-12-01'

INSERT INTO #Customers(CustomerID)
SELECT c.Id
FROM 
	dbo.Customer as c
WHERE
	c.DateOfBirth>@DateOfBirth;

SELECT * FROM #Customers;

DECLARE @Locations TABLE(    --Location table
LocationID int);

INSERT INTO @Locations(LocationID)
SELECT 
	l.Id
FROM 
	dbo.[Location] as l
WHERE 
	l.LocationTypeId = 4 
	AND (l.CityId IN(2,5));

SELECT * FROM @Locations

SELECT SUM(ad.Amount)
FROM 
	dbo.AccountDetails as ad
	INNER JOIN @Locations as l ON ad.LocationId=l.LocationID
	INNER JOIN dbo.Account as a ON ad.AccountId=a.Id
	INNER JOIN #Customers as c ON c.CustomerID=a.CustomerId
WHERE 
	CurrencyId=1

