select *
from StoreGroup

select *
from StoreDomain

select *
from StoreDomainStore

select *
from StoreDomainGroup

select *
from StoreGroupPermission

select *
from StoreGroupRight

select *
from PWCode
where CodeType = 'STORERM'

--==========================================================================
select t1.DomainID, DomainName, LoginName, FullName
from StoreDomainSuperUser t1 inner join StoreDomain t2 on t1.DomainID = t2.DomainID

select t5.DomainName As StoreDomain,
t3.GroupName, t2.UniqueName, LoginName, (select DomainName from CWDomain where DomainID = t2.DomainID) As EmpDomain
from StoreGroupUser t1 
inner join Employee t2 on t1.EmployeeSID = t2.EmployeeSID 
inner join StoreGroup t3 on t1.GroupID = t3.GroupID
inner join StoreDomainGroup t4 on t3.GroupID = t4.GroupID
inner join StoreDomain t5 on t4.DomainID = t5.DomainID

select t6.DomainName As StoreDomain, t2.GroupName, t2.Description As GroupDescription, t1.StoreRoom, t3.StoreRMDescription, t3.IsActive, t1.CanAudit, t1.CanIssue, t1.CanReceive, t1.CanTransfer
from StoreGroupRight t1 
inner join StoreGroup t2 on t1.GroupID = t2.GroupID 
inner join StoreDomainGroup t5 on t1.GroupID = t5.GroupID inner join StoreDomain t6 on t5.DomainID = t6.DomainID
left outer join (select Code, Description As StoreRMDescription, IsActive from PWCode where CodeType = 'STORERM' )t3 on t1.StoreRoom = t3.Code

--Materials
select MaterialSID, MaterialUID, Replace(Description,Char(9),'') Description, Category, Model, Manufacturer, Detail, '', PartNumber, UnitOfMeasure, 
UnitCost, null Keywords, LGTID, case Viewable when 1 then 1 else 0 End Viewable, Custom4, case Splittable when 1 then 1 else 0 End Splittable
from azteca.MaterialLeaf ML
where ML.MaterialUID like 'PCR-%'
order by 2

--Storeroom Materials
select StoreRM, MaterialUID, Description, StockOnHand
from StoreRMStock SRS
inner join MaterialLeaf ML
on SRS.MaterialSID = ML.MaterialSID
where ML.MaterialUID like 'PCR-%'
order by 1,2

--Storerooms
select t1.StoreRoom, t3.StoreRMDescription, t3.IsActive, t2.DomainName As StoreDomain
from StoreDomainStore t1
inner join StoreDomain t2 on t1.DomainID = t2.DomainID
left outer join (select Code, Description As StoreRMDescription, IsActive from PWCode where CodeType = 'STORERM' )t3 on t1.StoreRoom = t3.Code
where DomainName = 'PCR STOREROOM'

--MaterialNode
select *
from MaterialNode
where DomainID = 6
order by 1,2

--===================================
select *
from StoreDomain

select *
from StoreGroupPermission

--Emps not assigned to ANY Group
Select EmployeeSID, EmployeeID, UniqueName, Title, LoginName, IsActive, (select DomainName from CWDomain where DomainID = t1.DomainID) As EmpDomain
from Employee t1
where EmployeeSID not in (select EmployeeSID from StoreGroupUser)
and Len(LoginName ) > 0
order by 3
