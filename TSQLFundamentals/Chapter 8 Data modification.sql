USE TSQLV4;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid INT NOT NULL
    CONSTRAINT PK_Orders PRIMARY KEY,
  orderdate DATE  NOT NULL 
    CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),
  empid INT NOT NULL,
  custid VARCHAR(10)  NOT NULL
);

--Inserting a Single line of data
INSERT INTO dbo.Orders(orderid,orderdate,empid,custid)
  VALUES(1001,'20160212',3,'A');

INSERT INTO dbo.Orders(orderid,empid,custid)
  VALUES(1002,5,'B');

--INSERT SELECT Statement

INSERT INTO dbo.Orders (orderid,orderdate,empid,custid)
  SELECT orderid,orderdate,empid,custid
  FROM Sales.Orders
  WHERE shipcountry=N'UK';

--INSERT EXEC Statement
--INSERT EXEC is similar to INSERT SELECT. However, the only difference is the former gets executed on Tables. The later gets executed on Stored procedures.

DROP PROC IF EXISTS Sales.GetOrders;
GO
CREATE PROC SAles.GetOrders
  @country AS NVARCHAR(40)
AS
SELECT orderid,orderdate,empid,custid
FROM Sales.Orders
WHERE shipcountry=@country;
GO

INSERT INTO dbo.Orders(orderid,orderdate,empid,custid)
  EXEC Sales.GetOrders @country=N'France';

DROP TABLE IF EXISTS dbo.Orders;

SELECT orderid,orderdate,empid,custid
INTO dbo.Orders
FROM Sales.Orders;

DROP TABLE IF EXISTS dbo.Locations;
SELECT country, region,city
INTO dbo.Locations
FROM Sales.Customers
EXCEPT
SELECT country, region,city
FROM HR.Employees;

--Identity

DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1
(
  keycol INT NOT NULL IDENTITY(1,1)
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
    CONSTRAINT CCK_T1_datacol CHECk(datacol LIKE '[A-Z]%')
);

INSERT INTO dbo.T1(datacol) VALUES('AAAA'),('BBBB'),('CCCC'),('DDDD');
SELECT $identity FROM dbo.T1;

--@@identity and SCOPE_IDENTITY

DECLARE @new_key AS INT;
INSERT INTO dbo.T1(datacol) VALUES('AAAA');
SET @new_key=SCOPE_IDENTITY();
SELECt @new_key as New_KEY;


DROP TABLE IF EXISTS dbo.T1;

--Deleting Data

DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid       INT          NOT NULL,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES dbo.Customers(custid)
);
GO

INSERT INTO dbo.Customers SELECT * FROM Sales.Customers;
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

DELETE FROM dbo.Orders
WHERE orderdate<'20150101';