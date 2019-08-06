-- iç içe alt sorgular oluþturma 
--tekil degerler döndüren iç içe sorgular

select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader

select  SOH.OrderDate as SiparisT ,SOD.ProductID as UrunNo  

from Sales.SalesOrderHeader as SOH 
join Sales.SalesOrderDetail as SOD  

on SOH.SalesOrderID= sod.SalesOrderID 

where SOH.OrderDate='2008-07-31'



--ilk deger min tarhi olarak alýndý daha sonra bu tarihe göre listeleme yapýldý
declare @ilksiparsitarihi smalldatetime;
select @ilksiparsitarihi=min(OrderDate) from Sales.SalesOrderHeader;

select distinct SOD.ProductID as UrunNO,  SOH.OrderDate as siparistarihi 
from Sales.SalesOrderHeader as SOH 
join Sales.SalesOrderDetail as SOD 
on SOH.SalesOrderID=SOD.SalesOrderID
where OrderDate=@ilksiparsitarihi;




select distinct SOD.ProductID as UrunNO,  SOH.OrderDate as siparistarihi 
from Sales.SalesOrderHeader as SOH 
join Sales.SalesOrderDetail as SOD 
on SOH.SalesOrderID=SOD.SalesOrderID
where OrderDate=(select min(OrderDate) from Sales.SalesOrderHeader);


--çoklu sonuc döndürme
-- Production.ProductCategory
-- Production.ProductSubcategory

select * from Production.ProductCategory
select * from Production.ProductSubcategory

-- select   * from tablo ismi as öneki join tabloismi2 as öneki on tablo1 öneki.sutun = tablo2.öneki .sutun

select top 2 pc.Name as Ana_Kategori ,psc.Name as Alt_katageri,* from Production.ProductCategory as  pc 
join Production.ProductSubcategory as psc 
on pc.ProductCategoryID =psc.ProductCategoryID where pc.Name in('Bikes')  order by psc.Name

select * from Person.Person;
select * from Person.PersonPhone;

select pp.BusinessEntityID ,pp.FirstName, pp.LastName ,p.PhoneNumber 
from Person.Person as pp 
join Person.PersonPhone as p
on pp.BusinessEntityID=p.BusinessEntityID
where p.BusinessEntityID in (select distinct BusinessEntityID from HumanResources.JobCandidate where BusinessEntityID is not null);

--türetilmiþ tablolar

select * from Production.ProductCategory
select * from Production.ProductSubcategory

select   max(bul.KategoriAdet)  from  (Select  pc.ProductCategoryID, COUNT(*) as KategoriAdet  from Production.ProductCategory as PC
inner join Production.ProductSubcategory as PS  on PC.ProductCategoryID=ps.ProductSubcategoryID group by pc.ProductCategoryID
) bul


-- alt sorgu

select  ProductID,Name,ListPrice, (Select Name from Production.ProductSubcategory as PSC where psc.ProductSubcategoryID=p.ProductSubcategoryID   ) as kategori from  Production.Product as P  



select * from Sales.SalesOrderHeader

---alt sorgu iki where ifasedesinin kullanýmý

select  SOH1.CustomerID ,SOH1.SalesOrderID,soh1.OrderDate
from Sales.SalesOrderHeader as SOH1 
where SOH1.OrderDate = (
						select min(soh2.OrderDate) 
									from Sales.SalesOrderHeader as SOH2  
									where SOH2.CustomerID=SOH1.CustomerID
						)

order by SOH1.CustomerID;


----

select *  from Person.Person;

select * from Person.PersonPhone;
select * from HumanResources.JobCandidate

select  pp.BusinessEntityID , pp.FirstName,PP.LastName,p.PhoneNumber  from    Person.Person as PP
join Person.PersonPhone as P on p.BusinessEntityID =pp.BusinessEntityID

where  exists (Select BusinessEntityID from HumanResources.JobCandidate as JC  where JC.BusinessEntityID=pp.BusinessEntityID);

select  pp.BusinessEntityID , pp.FirstName,PP.LastName,p.PhoneNumber  from    Person.Person as PP
join Person.PersonPhone as P on p.BusinessEntityID =pp.BusinessEntityID

where not exists (Select BusinessEntityID from HumanResources.JobCandidate as JC  where JC.BusinessEntityID=pp.BusinessEntityID);

--- veri tpileri cast ve convert 

select 'ürün kodu:'  +cast(p.ProductID as varchar) + '-'+  Name  from  Production.Product as p 

--convert iþlemi
declare @deger decimal(5,2);
set @deger=15.53

select cast(cast(@deger as varbinary(20) ) as decimal(9,2));

select convert(decimal (10,5),convert  (varbinary (6) ,@deger));

--common table expressions
with CTEProduct1(UrunNo,UrunAdý,Renk ,Dayof) as  
(
 select  ProductID,Name,Color ,DaysToManufacture from Production.Product where ProductID>300 and Color is not null --and DaysToManufacture>0


) select * from CTEProduct1;


select * from Production.Product

--productID,ProductNumer,   DaysToManufacture þart 0 nodan buyuk null haric

with CTEProduct(UrunNo,UrunAdý,Renk,Dayof ) as  
(
 select  ProductID,Name,Color,DaysToManufacture  from Production.Product where ProductID>300 and Color is not null 


) update  CTEProduct set UrunAdý= 'Atký' where UrunNo=317 

select  ProductID,Name,Color  from Production.Product where ProductID=317



-- enucuz ve en pahalý urunu bulunuz tablo ismi Proction.Product  sutunadý ListPrice 


union; --select ifadesinde eþ zamnlý kullaným


with enpahaliurunCTE as ( select top 1  ProductID,Name,ListPrice from Production.Product where ListPrice>0 order by ListPrice ),

 enucuzurunCTE as ( select top 1 ProductID,Name,ListPrice from Production.Product order by ListPrice desc 
)
select * from enpahaliurunCTE 
union 
select * from enucuzurunCTE;

--row_number ()
select ROW_NUMBER() over (order by ProductId) as satýrno ,ProductID,Name,ListPrice   from Production.Product


--rank

select * from Production.ProductInventory
select *from Production.Location

select  PInv.ProductID,p.Name,PInv.LocationID,PInv.Quantity, rank() over(partition by PInv.LocationID order by PInv.Quantity desc) as 'rank'   from Production.ProductInventory as  PInv inner join Production.Product as p on PInv.ProductID=p.ProductID


select  PInv.ProductID,p.Name,PInv.LocationID,PInv.Quantity, dense_rank() over(partition by PInv.LocationID order by PInv.Quantity desc) as 'rank'   from Production.ProductInventory as  PInv inner join Production.Product as p on PInv.ProductID=p.ProductID


--tablesample

select top 20 Name, p.ProductNumber ,p.ReorderPoint from Production.Product as p 
order by NEWID()

select * from  Production.Product Tablesample(9 percent)

select * from Production.Product TableSample(300 ROWS)


---pivot table
select Color from Production.Product  where not exists Color

select * from  ( 
select psc.Name,p.Color,Envanter.Quantity   
from Production.Product as p 
inner join Production.ProductSubcategory as psc 
on psc.ProductSubcategoryID=p.ProductSubcategoryID   
left join Production.ProductInventory as Envanter 
on p.ProductID=Envanter.ProductID 
)tablo

pivot (

sum(Quantity) for Color in( [Black],[Red],[Multi],[Silver],[Grey],[White],[Yellow],[Silver/Black])) tablo;


--Yeni tablolar züzerinden çalýþma

select  BusinessEntityID,FirstName,MiddleName,LastName into #personel from Person.Person

select * from #personel

--stored procedure 
create table  Personeller3(
 BusinessEntityID int,
 FirstName varchar(50),
 MiddleName varchar(50),
 LastName varchar(50)
);

--store procedure 
create proc pr_GitAlPersonel2
as begin

select BusinessEntityID,FirstName,MiddleName,LastName  from Person.Person


end ;


insert into Personeller ( BusinessEntityID,FirstName,MiddleName,LastName) exec pr_GitAlPersonel2

insert into Personeller3( BusinessEntityID,FirstName,MiddleName,LastName) select BusinessEntityID,FirstName,MiddleName,LastName from Person.Person

select * from Personeller

-- update iþlemi   production.product    sales.salesorderdetail   listprice* 5.40

update Production.Product set ListPrice=ListPrice* 5.40;

select *from Personeller3


delete  from  Personeller3   where  MiddleName=Null

delete top (2)  from Personeller3;


delete top (2.2) percent  from Personeller3;

--silinen bir kaydýn Deleted  içindekileri görütülenmesi

delete Sales.ShoppingCartItem output  deleted.* where ShoppingCartID=14951

create table person (

PersonelID  int not null identity(1,1),
personelGUID uniqueidentifier rowguidcol unique not null,
PersonelSubID int not null,
firstName varchar(30)

)

insert into person(personelGUID,PersonelSubID,firstName)  values ( NEWID(),123,'demo' )

drop table person

select * from person

select   s.ProductID,COUNT (s.ProductID) as [Toplamsatýlanurun]  from Sales.SalesOrderDetail as s group by ProductID order by Toplamsatýlanurun desc


select ProductID,COUNT(ProductID) as Toplamsatýlanurun   from  Sales.SalesOrderDetail  group by ProductID having count (ProductID)>50
order by Toplamsatýlanurun desc


select AVG( StandardCost) from Production.Product


select* from Production.Product

select 
sum(distinct p.ListPrice) as total_listprice ,
Sum( p.SafetyStockLevel    ) as seviye     from Production.Product as p 


-- listele -rek kýsmý null olmayan listpriceücreti 0 olmayan ve  yada ürün adaýnda ' Mountain%' olamyan rekleri gruplayýn   gorup by order by


select 

Color,sum(ListPrice)

from  Production.Product as pp where Color is not null and ListPrice !=0  or Name='Mountain%'
group by Color order by Color 



select  HRD.Name, COUNT(*) as [Çalýþan_sayýsý]  from HumanResources.EmployeeDepartmentHistory as EDH inner join HumanResources.Department as HRD  on EDH.DepartmentID =HRD.DepartmentID 
group by cube (hrd.Name) order by Çalýþan_sayýsý;
--bosta kalanlarý gösterme---null







































print @ilksiparsitarihi
