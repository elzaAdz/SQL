--SQL Project - Database for Salary Managment

CREATE DATABASE Project_SQL
GO

USE Project_SQL
GO
------------------------------------------------------

--Seniority Level Table

CREATE TABLE dbo.[SeniorityLevel](
	ID int IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(100) NOT NULL,
	CONSTRAINT PK_SeniorityLevel PRIMARY KEY CLUSTERED (ID)
)
GO

INSERT INTO dbo.SeniorityLevel([Name])
VALUES	('Junior'),
		('Intermediate'),
		('Senor'),
		('Lead'),
		('Project Manager'),
		('Division Manager'),
		('Office manager'),
		('CEO'),
		('CTO'),
		('CIO')
GO

SELECT * FROM dbo.SeniorityLevel

------------------------------------------------------

--Location table

CREATE TABLE dbo.[Location](
	Id int IDENTITY(1,1) NOT NULL,
	CountryName nvarchar(100) NOT NULL,
	Continent nvarchar(100) NOT NULL,
	Region nvarchar(100) NOT NULL,
	CONSTRAINT PK_Location PRIMARY KEY CLUSTERED (Id)
);
GO


INSERT INTO 
	dbo.[Location](CountryName, Continent, Region)
SELECT 
	CountryName, Continent, Region
FROM 
	WideWorldImporters.Application.Countries
GO

SELECT * FROM dbo.[Location]
GO

---------------------------------------------------------

--Department table

CREATE TABLE dbo.Department(
	Id int IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(100) NOT NULL,
	CONSTRAINT PK_Department PRIMARY KEY CLUSTERED (Id)
)
GO

INSERT INTO dbo.Department([Name])
VALUES 
	('Personal Banking & Operations'),
	('Digital Banking Department'),
	('Retail Banking & Marketing Department'),
	('Wealth Managment & Third Party Products'),
	('International Banking Division & DFB'),
	('Treasury'),
	('Information Techology'),
	('Corporate Communications'),
	('Support Services & Branch Expansion'),
	('Human Resources')
GO

SELECT * FROM dbo.Department
-----------------------------------------------------------

--Employee table

CREATE TABLE dbo.Employee(
	Id int IDENTITY(1,1) NOT NULL,
	FirstName nvarchar(100) NOT NULL,
	LastName nvarchar(100) NOT NULL,
	LocationId int NULL,
	SeniorityLevel int NULL,
	Department int NULL,
	CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (Id),
	CONSTRAINT FK_Employee_Location FOREIGN KEY (LocationId) REFERENCES dbo.[Location](Id),
	CONSTRAINT FK_Employee_SeniorityLevel FOREIGN KEY (SeniorityLevel) REFERENCES dbo.SeniorityLevel(Id),
	CONSTRAINT FK_Employee_Department FOREIGN KEY (Department) REFERENCES dbo.Department(Id)
)
GO

INSERT INTO 
	dbo.Employee(FirstName, LastName)
SELECT 
	LEFT(FullName, CHARINDEX(' ', FullName ) - 1),
	RIGHT(FullName, LEN(FullName) - CHARINDEX(' ',FullName))
FROM 
	WideWorldImporters.Application.People
ORDER BY 
	PersonID
GO


UPDATE 
	dbo.Employee
SET
	SeniorityLevel = ( Id % 10 + 1 ),   --these are two ways to make the division
	Department = ( Id % 10 + 1 ),            
	LocationID = CEILING ( Id / 6.0 ) % 190;
GO


--SELECT SeniorityLevel,COUNT(*)    --Testing the updates
--from dbo.Employee
--group by SeniorityLevel

--SELECT Department,COUNT(*)
--from dbo.Employee
--group by Department 

--SELECT LocationId,COUNT(*)
--from dbo.Employee
--group by LocationId 

SELECT * FROM dbo.Employee

--------------------------------------------------------------

--Salary table

TRUNCATE TABLE dbo.Salary;

CREATE TABLE dbo.Salary(
	Id int IDENTITY(1,1) NOT NULL,
	EmployeeId int NOT NULL,
	[Month] smallint NOT NULL,
	[Year] smallint NOT NULL,
	GrossAmount decimal(18,2) NOT NULL,
	NetAmount decimal(18,2) NOT NULL,
	RegularWorkAmount decimal(18,2) NOT NULL,
	BonusAmount decimal(18,2) NOT NULL,
	OvertimeAmount decimal(18,2) NOT NULL,
	VacationDays smallint NOT NULL,
	SickLeaveDays smallint NOT NULL,
	CONSTRAINT PK_Salary PRIMARY KEY CLUSTERED (Id),
	CONSTRAINT FK_Salary_Employee FOREIGN KEY (EmployeeId) REFERENCES dbo.Employee(id)
)
GO

SELECT * FROM dbo.Salary
ORDER BY EmployeeId, [Year]

DECLARE @YearStart INT = 2001;
DECLARE @YearEnd INT = 2020;
DECLARE @Month INT;
DECLARE @EmployeeCounter INT;

--Salary data for the past 20 years, starting from 01.2001 to 12.2020
WHILE @YearStart<=@YearEnd
BEGIN
    SET @Month=1;
    WHILE @Month<=12
    BEGIN
        INSERT INTO dbo.Salary(EmployeeId, [Month], [Year], GrossAmount, NetAmount, RegularWorkAmount, BonusAmount, OvertimeAmount, VacationDays, SickLeaveDays)
        SELECT 
            e.Id, @Month, @YearStart, 
            ROUND(RAND(CHECKSUM(NEWID())) * (60000 - 30000) + 30000, 2) as GrossAmount,  --Gross amount should be random data between 30.000 and 60.000 
            0 as NetAmount, 0 as RegularWorkAmount, 0 as BonusAmount, 0 as OvertimeAmount, 0 as VacationDays, 0 as SickLeaveDays --theu are NOT NULL
        FROM dbo.Employee e;

        SET @Month = @Month + 1;
    END

    SET @YearStart = @YearStart + 1;
END;

--Net amount should be 90% of the gross amount
UPDATE dbo.Salary
SET NetAmount = GrossAmount * 0.9;

--RegularWorkAmount sould be 80% of the total Net amount for all employees and months
UPDATE dbo.Salary
SET RegularWorkAmount = NetAmount * 0.8;

--Bonus amount should be the difference between the NetAmount and RegularWorkAmount for every Odd month (January,March,..)
UPDATE dbo.Salary
SET BonusAmount = CASE 
    WHEN [Month] % 2 = 1 THEN NetAmount - RegularWorkAmount 
    ELSE 0 
END;

--OvertimeAmount  should be the difference between the NetAmount and RegularWorkAmount for every Even month (February,April,…)
UPDATE dbo.Salary
SET OvertimeAmount = CASE 
     WHEN [Month] % 2 = 0 THEN NetAmount - RegularWorkAmount 
     ELSE 0 
END;

--All employees use 10 vacation days in July and 10 Vacation days in December
UPDATE dbo.Salary
SET VacationDays = CASE 
                    WHEN [Month] IN (7, 12) THEN 10
                    ELSE VacationDays
                  END;

--Additionally random vacation days and sickLeaveDays should be generated with the following script:
UPDATE dbo.Salary 
SET VacationDays = VacationDays + (EmployeeId % 2)
WHERE (EmployeeId + [Month] + [Year]) % 5 = 1;

UPDATE dbo.Salary 
SET SickLeaveDays = EmployeeId % 8, 
    VacationDays = VacationDays + (EmployeeId % 3)
WHERE 
	(EmployeeId + [Month] + [Year]) % 5 = 2;


SELECT * 
FROM 
	dbo.Salary 
WHERE 
	NetAmount <> (RegularWorkAmount + BonusAmount + OvertimeAmount);

--Checking sum of vacation days to be in range of 20-30
SELECT 
	EmployeeId, Year, 
	SUM(VacationDays) as SumOfDays
FROM
	dbo.Salary
GROUP BY 
	EmployeeId, Year
HAVING 
	SUM(VacationDays)<20 OR 
	SUM(VacationDays)>30
ORDER BY 
	EmployeeId,Year


