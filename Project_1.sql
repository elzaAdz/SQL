--H1-1

--Insert new Customer in the system
INSERT INTO dbo.Customer(FirstName, LastName, Gender, NationalIDNumber, DateOfBirth, City, RegionName, PhoneNumber, isActive)
VALUES ('Elza','Adzija','F','7695100','2003-09-26','Skopje','Macedonia','077897625',1);
--SELECT * FROM dbo.Customer 


--Insert new Employee in the system. Use your friend name
INSERT INTO dbo.Employee(FirstName,LastName,NationalIDNumber,DateOfBirth,Gender,HireDate)
VALUES ('Elena','Stojanovska','7322200','2000-09-22','F','2015-01-01');
--SELECT * FROM dbo.Employee


--Insert 2 accounts for the new customer (EUR, USD) 
INSERT INTO dbo.Account(AccountNumber, CustomerId, CurrencyId, AllowedOverdraft, CurrentBalance, EmployeeId)
VALUES ('210123456789613', 301, 5, 70100, 0, 101),
       ('210123456789614', 301, 6, 70200, 0, 1);
--SELECT * FROM dbo.Account 


--Insert new location type in the database (Terminal)
INSERT INTO dbo.LocationType([Name],[Description])
VALUES ('Terminal','Payment Terminal');
--SELECT * FROM dbo.LocationType


--Insert new location from type Terminal (e.g. Zara City mall post terminal)
INSERT INTO dbo.[Location](LocationTypeId, [Name])
VALUES (6, 'Zara City mall post terminal');
--SELECT * FROM dbo.Location


--Insert 1 transaction for each account we created in bullet 3 (income)
INSERT INTO dbo.AccountDetails(AccountId,LocationId,EmployeeId,TransactionDate,Amount,PurposeCode,PurposeDescription)
VALUES (601, 75, 101, GETDATE(), 5200, 101, 'plata'),
       (602, 75, 100, DATEADD(MINUTE, 5, GETDATE()), 5800, 101, 'plata');
--SELECT * FROM dbo.AccountDetails


--Insert 2 transactions for each account (outcome) as the transactions were performed from the Zara City Mall post terminal
INSERT INTO dbo.AccountDetails(AccountId,LocationId,EmployeeId,TransactionDate,Amount,PurposeCode,PurposeDescription)
VALUES (601, 75, 101, DATEADD(MINUTE,10,GETDATE()),-5200, 930, 'isplata'),
	   (601, 75, 101, DATEADD(MINUTE,15,GETDATE()),-10500, 930, 'isplata'),
	   (602, 75, 100, DATEADD(MINUTE,20,GETDATE()),-3000, 930, 'isplata'),
	   (602, 75, 50, DATEADD(MINUTE,25,GETDATE()),-9040, 930, 'isplata');     --DATEADD to make the transactions in different time
--SELECT * FROM dbo.AccountDetails


--Change the Allowed overdraft on EUR account to be 10.000
ALTER TABLE dbo.Account
ALTER COLUMN AllowedOverdraft decimal(10,3);   --change the column to represent the number with 3 decimals

UPDATE dbo.Account                             --change the value
SET AllowedOverdraft = 10
WHERE AccountNumber='210123456789613';

--SELECT * FROM dbo.Account 
-------------------------------------------------------------------------------------------------------------

--H1-2

--Add default constraint with value = 930 on PurposeCode column in AccountDetails table
ALTER TABLE dbo.AccountDetails
ADD CONSTRAINT DF_AccountDetails_PurposeCode
DEFAULT 930 FOR PurposeCode;


--Add Unique constraint on Name column in Location table
ALTER TABLE dbo.[Location] WITH CHECK
ADD CONSTRAINT UC_Location_Name
UNIQUE ([Name]);


--Add Check constraint on Account table to prevent inserting negative values in AllowedOverdraft column
ALTER TABLE dbo.Account 
ADD CONSTRAINT CH_Account_AllowedOverdraft
CHECK (AllowedOverdraft >= 0);

--test for the CHECK
--INSERT INTO dbo.Account(AccountNumber, CustomerId, CurrencyId, AllowedOverdraft, CurrentBalance, EmployeeId)
--VALUES ('210123456789613', 301, 5, -70100, 0, 101);               

----------------------------------------------------------------------------------------------

--H1-3

--List all Customers with FirstName = ‘Aleksandra’
SELECT * 
FROM dbo.Customer as c
WHERE c.FirstName='Aleksandra';


--List all Customers with FirstName = ‘Aleksandra’ and LastName starting with letter B
SELECT * 
FROM dbo.Customer as c
WHERE (c.FirstName='Aleksandra' AND c.LastName LIKE 'B%');


--Order the results by the LastName
SELECT * 
FROM dbo.Customer as c
WHERE (c.FirstName='Aleksandra' AND c.LastName LIKE 'B%')
ORDER BY LastName ASC;


--Provide information about the total number of Customers with FirstName = ‘Aleksandra’ OR LastName starting with ‘B;
SELECT count(*) as Total
FROM dbo.Customer as c
WHERE (c.FirstName='Aleksandra' OR c.LastName LIKE 'B%')


--List all Customers that are born in February (any year)
SELECT *
FROM dbo.Customer
WHERE MONTH(DateOfBirth)=2


--List all Customers that are born in February (any year) or their last name starts with B
SELECT *
FROM dbo.Customer 
WHERE (MONTH(DateOfBirth)=2 OR LastName LIKE 'B%');


--Provide total number of Female customers from Ohrid
SELECT count(*) as FemaleOhrid
FROM dbo.Customer
WHERE City='Ohrid' AND Gender='F'


--Provide total number of customers born in Odd months in any year
SELECT count(*) as OddMonths
FROM dbo.Customer
WHERE MONTH(DateOfBirth) % 2 = 0;

-----------------------------------------------------------------------------------------------------------
--H1-4

--Calculate how many customers from each city are in the system
SELECT c.City, count(*) as NumberOfCustomers
FROM dbo.Customer as c
Group by c.City;


--Calculate how many male and female customers from each city are in the system
SELECT c.City, c.Gender, count(*) as Total
FROM dbo.Customer as c
GROUP BY c.City, c.Gender;


--List only cities having more then 25 Female customers. Provide City name and total number of Female customers
SELECT c.City,count(*) as FemaleCustomers
FROM dbo.Customer as c
WHERE Gender='F'
GROUP BY c.City
HAVING count(*) > 25;

