--*************************************************************************--
-- Title: Assignment06
-- Author: SBhosale
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-11-19,SBhosale,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SBhosale')
	 Begin 
	  Alter Database [Assignment06DB_SBhosale] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SBhosale;
	 End
	Create Database Assignment06DB_SBhosale;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SBhosale;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW vCategories 
WITH SCHEMABINDING
	AS
	SELECT CategoryID, CategoryName
FROM dbo.Categories;
GO

CREATE VIEW vProducts
WITH SCHEMABINDING
	AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM dbo.Products;
GO

CREATE VIEW vEmployees
WITH SCHEMABINDING
	AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees;
GO

CREATE VIEW vInventories
WITH SCHEMABINDING
	AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, COUNT
	FROM dbo.Inventories;
GO



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO Public;
DENY SELECT ON Products TO Public;
DENY SELECT ON Employees TO Public;
DENY SELECT ON Inventories TO Public;
GO
GRANT SELECT ON vCategories TO Public;
GRANT SELECT ON vProducts TO Public;
GRANT SELECT ON vEmployees TO Public;
GRANT SELECT ON vInventories TO Public;
GO



-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories
AS
SELECT TOP 100000
	c.CategoryName,
	p.ProductName,
	p.UnitPrice
FROM vCategories AS c
	INNER JOIN vProducts as p
	ON c.CategoryID = p.CategoryID
ORDER BY 1,2,3;
GO



-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByDates 
AS
SELECT TOP 100000
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM vInventories AS i
	INNER JOIN vProducts AS p
	ON i.ProductID = p.ProductID
ORDER BY 1,2,3;
GO



-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDates
AS
SELECT DISTINCT TOP 100000
	i.InventoryDate, 
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
FROM vInventories as i
	INNER JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
ORDER BY 1;
GO


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories
AS
SELECT TOP 1000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM vCategories AS c
	INNER JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i
	ON p.ProductID = i.ProductID
ORDER BY 1,2,3,4;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees
AS
SELECT TOP 100000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	e.EmployeeFirstName +' '+ e.EmployeeLastName AS EmployeeName
FROM vCategories AS c
	INNER JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees AS e
	ON e.EmployeeID = i.EmployeeID
ORDER BY 3,1,2,4;
GO



-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 100000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM vCategories AS c
	INNER JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees AS e
	ON i.EmployeeID = e.EmployeeID
WHERE p.ProductID IN (SELECT ProductID FROM vProducts WHERE ProductName in ('CHAI' , 'Chang'))
ORDER BY 3,2;
GO



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManager
AS
SELECT TOP 100000
	m.EmployeeFirstName +' '+ m.EmployeeLastName AS ManagerName,
	e.EmployeeFirstName +' '+ e.EmployeeLastName AS EmployeeName
FROM vEmployees AS e
	INNER JOIN vEmployees as m
	ON e.ManagerID = m.EmployeeID
ORDER BY 1;
GO



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 100000
	c.CategoryID,
	c.CategoryName,
	p.ProductID,
	p.ProductName,
	p.UnitPrice,
	i.InventoryID,
	i.Count,
	e.EmployeeID,
	e.EmployeeFirstName +' '+ e.EmployeeLastName AS EmployeeName,
	m.EmployeeFirstName +' '+ m.EmployeeLastName AS ManagerName
FROM vCategories AS c
	INNER JOIN vProducts as p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i 
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees AS e
	ON i.EmployeeID = e.EmployeeID
	INNER JOIN vEmployees AS m
	ON e.ManagerID = m.EmployeeID
ORDER BY 2,4,6,8;
GO




-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/