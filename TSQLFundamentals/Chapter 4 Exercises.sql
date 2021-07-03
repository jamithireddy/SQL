use TSQLV4;

-- Exercise 1
select orderid,orderdate,custid,empid
from sales.Orders
where orderdate=(select max(orderdate) from sales.orders);

-- Exercise 2
SELECT custid,orderid,orderdate,empid
from Sales.Orders
WHERE custid IN(
                select top (1) with ties O.custid
                from Sales.Orders as O 
                group by O.custid 
                order by count(O.orderid) DESC
              );

-- Exercise 3
SELECT E.empid,E.firstname,E.lastname
FROM HR.employees as E
WHERE E.empid not IN(
                      select distinct O.empid
                      FROM Sales.Orders as O
                      WHERE O.orderdate>='20160501'
                    )

-- Exercise 4
SELECT distinct C.country
FROM Sales.Customers as C
WHERE C.country not in (
                  SELECT distinct E.country
                  FROM HR.Employees as E
                )
ORDER BY C.country;

-- Exercise 5
SELECT O.custid, O.orderid, O.orderdate, O.empid
FROM Sales.Orders as O
WHERE O.orderdate= (
                    SELECT max(O1.orderdate)
                    FROM Sales.Orders as O1
                    WHERE O1.custid=O.custid)
ORDER BY O.custid;

-- Exercise 6
SELECT C.custid, C.companyname
FROM Sales.Customers as C
WHERE exists(
                select *
                FROM Sales.Orders as O
                where O.custid=C.custid
                  AND O.orderdate>='20150101'
                  AND O.orderdate<'20160101')
      and not exists(
                Select * from Sales.Orders as O
                where O.custid=C.custid
                  AND O.orderdate>='20160101'
                  AND O.orderdate<'20170101'
      )


-- Exercise 7
SELECT C.custid, C.companyname
FROM Sales.Customers as C
WHERE C.custid in
        (SELECT O.custid
        FROM Sales.Orders as O
        WHERE O.orderid IN
                (
                  select OD.orderid
                  FROM Sales.Orderdetails as OD
                  where OD.productid= 12
                )
        )

-- Alternative way using correlated Subquery
SELECT custid, companyname
FROM Sales.Customers as C
WHERE exists
  (Select * 
  from Sales.Orders as O
  where O.custid=C.custid
    and exists 
      (Select *
      FROM Sales.OrderDetails as OD
      WHERE OD.orderid=O.orderid
        and OD.productid=12));

-- Exercise 8
SELECT C1.custid, C1.ordermonth, C1.qty,
  (select sum(C2.qty)
  FROM Sales.CustOrders as C2
  WHERE C2.custid=C1.custid
    and C2.ordermonth<=C1.ordermonth) as runqty
FROM Sales.CustOrders as C1
ORDER BY C1.custid, C1.ordermonth;

--Exercise 9
/* What is the difference between IN and EXISTS?

IN is a three pronged logic (TRUE, FALSE, UNKNOWN) as it has NULL values considered. EXISTS isa two pronged logic.. TRUE or FALSE */

-- Exercise 10
SELECT O1.custid, O1.orderdate, O1.orderid,
  DATEDIFF(day,(select Top(1)O2.orderdate
  FROM Sales.Orders as O2
  where (O2.custid=O1.custid) and ((O2.orderdate=O1.orderdate and O2.orderid<O1.orderid) or(O2.orderdate<O1.orderdate) ) 
  order by O2.orderdate desc, O2.orderid desc),O1.orderdate) as diff
FROM Sales.Orders as O1
ORDER BY O1.custid,O1.orderdate,O1.orderid;
