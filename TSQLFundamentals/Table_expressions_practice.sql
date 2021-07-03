use TSQLV4;
DROP VIEW if EXISTS Sales.USACusts;
GO
CREATE VIEW Sales.USACusts
AS
SELECT
  custid, companyname,contactname,contacttitle,address,city,region, postalcode, country, phone, fax 
FROM Sales.Customers
WHERE country =N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'))

EXEC sp_helptext 'Sales.USACusts';

ALTER VIEW Sales.USACusts WITH Encryption
AS
SELECT
  custid, companyname,contactname,contacttitle,address,city,region, postalcode, country, phone, fax 
FROM Sales.Customers
WHERE country =N'USA';
GO

DROP VIEW IF EXISTS Sales.USACusts;

DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO
CREATE FUNCTION dbo.GetCustOrders
  (@cid AS INT) RETURNS TABLE
AS
RETURN
  SELECT orderid,custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry
  FROM Sales.Orders
  WHERE custid=@cid;
GO

SELECT orderid,custid 
FROM dbo.GetCustOrders(1)

SELECT O.orderid, O.custid, OD.productid,OD.qty
FROM dbo.getcustorders(1) as O
  INNER JOIN Sales.OrderDetails as OD 
  ON O.orderid=OD.orderid;

DROP FUNCTION IF EXISTS dbo.GetCustOrders;