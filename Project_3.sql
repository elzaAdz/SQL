--HOMEWORK 3

--All accounts that are not open from Employee with NationalIdNumber 7137597.
--For those accounts additionally show how many accounts in total has the owner (customer) of the account

SELECT
    a.*,
(
SELECT COUNT(*) 
    FROM 
		dbo.Account AS a2
	WHERE 
		a2.CustomerId = a.CustomerId
)AS TotalAccounts
FROM 
	dbo.Account AS a
	INNER JOIN dbo.Employee AS e ON a.EmployeeId = e.ID
WHERE 
	e.NationalIdNumber <> '7137597';

--JOINS
--List all transactions for AccountId  = 1 that were performed by any employee

SELECT 
	ad.*
FROM 
	dbo.AccountDetails as ad
	INNER JOIN dbo.Employee as e ON ad.EmployeeId=e.ID
WHERE 
ad.AccountId=1

--Calculate how many male Employees opened accounts for Female customers and vice versa

SELECT 
	e.Gender as EmployeeGender,c.Gender as CustomerGender ,COUNT(DISTINCT e.ID)
FROM 
	dbo.Account as a
	INNER JOIN dbo.Employee as e ON a.EmployeeId=e.ID
	INNER JOIN dbo.Customer as c ON a.CustomerId=c.Id
WHERE 
	e.Gender<>c.Gender
GROUP BY 
	e.Gender,c.Gender

--Prepare query with 2 most often used locations for transactions for the male customers and for the female customers.

;WITH MyCTE
AS
(
SELECT c.Gender, l.[Name] AS LocationName,
    COUNT(*) AS [Total Transactions],
    DENSE_RANK() OVER (PARTITION BY c.Gender ORDER BY COUNT(*) DESC) AS Ranking
FROM 
	dbo.AccountDetails AS ad
	INNER JOIN dbo.Account AS a ON ad.AccountId = a.ID
	INNER JOIN dbo.Customer AS c ON a.CustomerId=c.Id
	INNER JOIN dbo.[Location] AS l ON ad.LocationId = l.Id
GROUP BY 
	c.Gender, l.[Name]
)
SELECT 
	m.Gender, m.LocationName, m.[Total Transactions]
FROM 
	MyCTE as m
WHERE 
	Ranking <= 2

--or with ROW_NUMBER to get exactly two locations

;WITH MyCTE
AS
(
SELECT c.Gender, l.[Name] AS LocationName,
    COUNT(*) AS [Total Transactions],
    ROW_NUMBER() OVER (PARTITION BY c.Gender ORDER BY COUNT(*) DESC) AS Ranking
FROM 
	dbo.AccountDetails AS ad
	INNER JOIN dbo.Account AS a ON ad.AccountId = a.ID
	INNER JOIN dbo.Customer AS c ON a.CustomerId=c.Id
	INNER JOIN dbo.[Location] AS l ON ad.LocationId = l.Id
GROUP BY 
	c.Gender, l.[Name]
)
SELECT 
	m.Gender, m.LocationName, m.[Total Transactions]
FROM 
	MyCTE as m
WHERE 
	Ranking <= 2