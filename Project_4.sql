--H4-1

--Create table valued function that for input parameter @NationalIDNumber  
--will return resultset with CurrencyName and current balance
CREATE FUNCTION GetID
(
@NationalIDNumber NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT c.[Name], a.CurrentBalance
    FROM 
		dbo.Account as a
		INNER JOIN dbo.Currency as c ON a.CurrencyID = c.id
    WHERE 
        a.AccountNumber= @NationalIDNumber
)

SELECT * 
FROM GetID('210123456789613');

SELECT * FROM dbo.Account

--H4-2
--Create procedure that will list all transactions for specific customer in and specific date interval

CREATE PROCEDURE GetTransactions
(
    @CustomerId INT,
    @ValidFrom DATE,
    @ValidTo DATE
)
AS
BEGIN
    SELECT 
        c.FirstName +' '+ c.LastName AS FullName,
        l.[Name],
        ad.Amount,
        curr.[Name]
    FROM dbo.AccountDetails as ad
    INNER JOIN dbo.Account as a ON ad.AccountId= a.Id
	INNER JOIN dbo.Customer as c ON a.CustomerId=c.Id
    INNER JOIN dbo.Location as l ON ad.LocationId = l.id
    INNER JOIN dbo.Currency as curr ON a.CurrencyId = curr.Id
    WHERE 
        a.CustomerId = @CustomerId
        AND ad.TransactionDate BETWEEN @ValidFrom AND @ValidTo
    ORDER BY 
        ad.TransactionDate
END

EXEC GetTransactions 
    @CustomerId = 1, 
    @ValidFrom = '2019-01-01', 
    @ValidTo = '2019-12-31';


--Extend the procedure to add input parameter @EmployeeId for the employee that generates the 
--report for the list of transactions.

CREATE TABLE Transactions
(
    LogId INT IDENTITY(1,1), 
    EmployeeId INT NOT NULL,             
    CustomerId INT NOT NULL,             
    ValidFrom DATE NOT NULL,             
    ValidTo DATE NOT NULL,               
    ExecutionTime DATETIME DEFAULT GETDATE(),
	CONSTRAINT PK_Transaction PRIMARY KEY CLUSTERED(LogId)
);

CREATE PROCEDURE GetTransactionsExt
(
    @CustomerId INT,
    @ValidFrom DATE,
    @ValidTo DATE,
    @EmployeeId INT 
)
AS
BEGIN
    INSERT INTO Transactions(EmployeeId, CustomerId, ValidFrom, ValidTo)
    VALUES (@EmployeeId, @CustomerId, @ValidFrom, @ValidTo);

    SELECT 
        c.FirstName +' '+ c.LastName AS FullName,
        l.[Name] AS LocationName,
        ad.Amount,
        curr.[Name] AS CurrencyName
    FROM dbo.AccountDetails AS ad
    INNER JOIN dbo.Account AS a ON ad.AccountId = a.Id
    INNER JOIN dbo.Customer AS c ON a.CustomerId = c.Id
    INNER JOIN dbo.Location AS l ON ad.LocationId = l.Id
    INNER JOIN dbo.Currency AS curr ON a.CurrencyId = curr.Id
    WHERE 
        a.CustomerId = @CustomerId
        AND ad.TransactionDate BETWEEN @ValidFrom AND @ValidTo
    ORDER BY 
        ad.TransactionDate;
END


EXEC GetTransactionsExt
    @CustomerId = 1, 
    @ValidFrom = '2019-01-01', 
    @ValidTo = '2024-11-11', 
    @EmployeeId = 1;

SELECT * FROM Transactions  --Test

--Prepare new procedure for reading the logged data

CREATE PROCEDURE GetSummary
(
    @ValidFrom DATE,
    @ValidTo DATE
)
AS
BEGIN
    SELECT 
        e.FirstName+' '+e.LastName AS EmployeeName, 
        c.FirstName+' '+c.LastName AS CustomerName, 
        COUNT(*) AS ExecutionCount 
    FROM Transactions AS t
    INNER JOIN Employee AS e ON t.EmployeeId = e.Id 
    INNER JOIN Customer AS c ON t.CustomerId = c.Id 
    WHERE 
        t.ExecutionTime BETWEEN @ValidFrom AND @ValidTo 
    GROUP BY 
        e.FirstName, e.LastName, c.FirstName, c.LastName 
    ORDER BY 
        ExecutionCount DESC
END

EXEC GetSummary 
    @ValidFrom = '2024-01-01', 
    @ValidTo = '2024-12-31';











