select *
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
where TransDateTime > '2023-01-01'
and TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
order by TransDateTime desc
--7124 with Audit Transactions
--6713 without Audit Transactions

--Issues
select Domain.DomainName, Storeroom.Code
,ISS.MaterialSID, TH.MaterialUID, ISS.Quantity, TH.UnitCost
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on ISS.Source = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
order by 4
--6713

--Return from Work Order
select Domain.DomainName, Storeroom.Code
,RCV.MaterialSID, TH.MaterialUID, RCV.Quantity, RCV.UnitCost, TH.UnitCost, RCV.WorkOrderID, TH.Comments
from azteca.Receive RCV
inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on RCV.Destination = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (RCV.AcctNum <> 'TRASH' or RCV.AcctNum is null)
and Len(WorkOrderID) > 0
order by 4

--=============================================================================
--=============================================================================
--Issues 
--No Audits (TRASH)
--By MaterialUID, IssueValue
select Domain.DomainName, Storeroom.Code IssueStoreroom
,ISS.MaterialSID, TH.MaterialUID, Sum(Quantity) IssueQuantity, Sum(Quantity * UnitCost) IssueValue, count(*) CntIssueTrans
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on ISS.Source = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
group by Domain.DomainName, Storeroom.Code, ISS.MaterialSID, TH.MaterialUID
order by 4
--1038

--Returns from Work Order
--By MaterialUID, ReturnValue
select Domain.DomainName, Storeroom.Code ReturnStoreroom
,RCV.MaterialSID, TH.MaterialUID, Sum(RCV.Quantity) * -1  ReturnQuantity, Sum(RCV.UnitCost * RCV.Quantity)* -1 ReturnValue, Count(*) CntReturnTrans
from azteca.Receive RCV
inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on RCV.Destination = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (RCV.AcctNum <> 'TRASH' or RCV.AcctNum is null)
and Len(WorkOrderID) > 0
group by Domain.DomainName, Storeroom.Code, RCV.MaterialSID, TH.MaterialUID
order by 4
--130

select *
from azteca.Receive
where Len(WorkOrderID) > 0 or FromEmployeeSID > 0
--==================================================================
--==================================================================
--Net Value Issues minus Returns from Work Order minus Returns from Employee
--Storeroom / Material
--No Audits (TRASH)
--By MaterialUID, IssueValue
Select Issues.DomainName, Issues.IssueStoreroom, Issues.MaterialSID, Issues.MaterialUID, Issues.IssueValue, WOReturns.ReturnValue, Issues.IssueValue + IsNull(WOReturns.ReturnValue,0) NetIssue
from ( --Issues
select Domain.DomainName, Storeroom.Code IssueStoreroom
,ISS.MaterialSID, TH.MaterialUID, Sum(Quantity) IssueQuantity, Sum(Quantity * UnitCost) IssueValue, count(*) CntIssueTrans
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on ISS.Source = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
group by Domain.DomainName, Storeroom.Code, ISS.MaterialSID, TH.MaterialUID
) Issues left outer join 
(--Returns from Work Order and Returns from Employee
select Domain.DomainName, Storeroom.Code ReturnStoreroom
,RCV.MaterialSID, TH.MaterialUID, Sum(RCV.Quantity) * -1  ReturnQuantity, Sum(RCV.UnitCost * RCV.Quantity)* -1 ReturnValue, Count(*) CntReturnTrans
from azteca.Receive RCV
inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on RCV.Destination = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (RCV.AcctNum <> 'TRASH' or RCV.AcctNum is null)
and (Len(WorkOrderID) > 0 or FromEmployeeSID > 0)
group by Domain.DomainName, Storeroom.Code, RCV.MaterialSID, TH.MaterialUID
) WOReturns on Issues.IssueStoreroom = WOReturns.ReturnStoreroom and Issues.MaterialSID = WOReturns.MaterialSID and Issues.MaterialUID = WOReturns.MaterialUID
order by 4

--==================================================================
--==================================================================
--Net Value Issues minus Returns from Work Order minus Returns from Employee
--Storerooms with Transactions
--No Audits (TRASH)
--By Storeroom, IssueValue

Select SRIssues.DomainName, SRIssues.IssueStoreroom, Sum(NetIssue) SRNetIssue
from (
Select Issues.DomainName, Issues.IssueStoreroom, Issues.MaterialSID, Issues.MaterialUID, Issues.IssueValue, WOReturns.ReturnValue, Issues.IssueValue + IsNull(WOReturns.ReturnValue,0) NetIssue
from ( --Issues
select Domain.DomainName, Storeroom.Code IssueStoreroom
,ISS.MaterialSID, TH.MaterialUID, Sum(Quantity) IssueQuantity, Sum(Quantity * UnitCost) IssueValue, count(*) CntIssueTrans
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on ISS.Source = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
group by Domain.DomainName, Storeroom.Code, ISS.MaterialSID, TH.MaterialUID
) Issues left outer join 
(--Returns from Work Order and Returns from Employee
select Domain.DomainName, Storeroom.Code ReturnStoreroom
,RCV.MaterialSID, TH.MaterialUID, Sum(RCV.Quantity) * -1  ReturnQuantity, Sum(RCV.UnitCost * RCV.Quantity)* -1 ReturnValue, Count(*) CntReturnTrans
from azteca.Receive RCV
inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on RCV.Destination = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (RCV.AcctNum <> 'TRASH' or RCV.AcctNum is null)
and (Len(WorkOrderID) > 0 or FromEmployeeSID > 0)
group by Domain.DomainName, Storeroom.Code, RCV.MaterialSID, TH.MaterialUID
) WOReturns on Issues.IssueStoreroom = WOReturns.ReturnStoreroom and Issues.MaterialSID = WOReturns.MaterialSID and Issues.MaterialUID = WOReturns.MaterialUID
) SRIssues
group by SRIssues.DomainName, SRIssues.IssueStoreroom
order by 2

--==================================================================
--==================================================================
--Net Value Issues minus Returns from Work Order minus Returns from Employee
--ALL Storerooms
--No Audits (TRASH)
--By Storeroom, IssueValue

Select StoreDomainName.DomainName, StoreRM.Storeroom, StoreRM.IsActive,IsNull(Sum(NetIssue), 0) SRNetIssue
from 
 (select Code Storeroom, IsActive from azteca.PWCode where CodeType = 'STORERM') StoreRM
inner join azteca.StoreDomainStore StoreDomain on StoreRM.Storeroom = StoreDomain.Storeroom
inner join azteca.StoreDomain StoreDomainName on StoreDomain.DomainID = StoreDomainName.DomainID
left outer join (
Select Issues.DomainName, Issues.IssueStoreroom, Issues.MaterialSID, Issues.MaterialUID, Issues.IssueValue, WOReturns.ReturnValue, Issues.IssueValue + IsNull(WOReturns.ReturnValue,0) NetIssue
from (--Issues
select Domain.DomainName, Storeroom.Code IssueStoreroom
,ISS.MaterialSID, TH.MaterialUID, Sum(Quantity) IssueQuantity, Sum(Quantity * UnitCost) IssueValue, count(*) CntIssueTrans
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on ISS.Source = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
group by Domain.DomainName, Storeroom.Code, ISS.MaterialSID, TH.MaterialUID
) Issues left outer join 
(--Returns from Work Order and Returns from Employee
select Domain.DomainName, Storeroom.Code ReturnStoreroom
,RCV.MaterialSID, TH.MaterialUID, Sum(RCV.Quantity) * -1  ReturnQuantity, Sum(RCV.UnitCost * RCV.Quantity)* -1 ReturnValue, Count(*) CntReturnTrans
from azteca.Receive RCV
inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on RCV.Destination = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (RCV.AcctNum <> 'TRASH' or RCV.AcctNum is null)
and (Len(WorkOrderID) > 0 or FromEmployeeSID > 0)
group by Domain.DomainName, Storeroom.Code, RCV.MaterialSID, TH.MaterialUID
) WOReturns on Issues.IssueStoreroom = WOReturns.ReturnStoreroom and Issues.MaterialSID = WOReturns.MaterialSID and Issues.MaterialUID = WOReturns.MaterialUID
) SRIssues on StoreRM.Storeroom = SRIssues.IssueStoreroom
group by StoreDomainName.DomainName, StoreRM.Storeroom, StoreRM.IsActive
order by 2

--==================================================================
--==================================================================
--Net Value Issues minus Returns from Work Order minus Returns from Employee
--SR Domain
--No Audits (TRASH)
--By Storeroom Domain, IssueValue

Select StoreDomainName.DomainName, IsNull(Sum(NetIssue), 0) SRNetIssue
from 
 (select Code Storeroom, IsActive from azteca.PWCode where CodeType = 'STORERM') StoreRM
inner join azteca.StoreDomainStore StoreDomain on StoreRM.Storeroom = StoreDomain.Storeroom
inner join azteca.StoreDomain StoreDomainName on StoreDomain.DomainID = StoreDomainName.DomainID
left outer join (
Select Issues.DomainName, Issues.IssueStoreroom, Issues.MaterialSID, Issues.MaterialUID, Issues.IssueValue, WOReturns.ReturnValue, Issues.IssueValue + IsNull(WOReturns.ReturnValue,0) NetIssue
from (--Issues
select Domain.DomainName, Storeroom.Code IssueStoreroom
,ISS.MaterialSID, TH.MaterialUID, Sum(Quantity) IssueQuantity, Sum(Quantity * UnitCost) IssueValue, count(*) CntIssueTrans
from azteca.Issue ISS
inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on ISS.Source = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (ISS.AcctNum <> 'TRASH' or ISS.AcctNum is null)
group by Domain.DomainName, Storeroom.Code, ISS.MaterialSID, TH.MaterialUID
) Issues left outer join 
(--Returns from Work Order and Returns from Employee
select Domain.DomainName, Storeroom.Code ReturnStoreroom
,RCV.MaterialSID, TH.MaterialUID, Sum(RCV.Quantity) * -1  ReturnQuantity, Sum(RCV.UnitCost * RCV.Quantity)* -1 ReturnValue, Count(*) CntReturnTrans
from azteca.Receive RCV
inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
inner join (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on RCV.Destination = Storeroom.Code
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
where TH.TransDateTime > '2023-01-01'
and TH.TransDateTime < DateAdd(day, 1, '2023-01-31')
and (RCV.AcctNum <> 'TRASH' or RCV.AcctNum is null)
and (Len(WorkOrderID) > 0 or FromEmployeeSID > 0)
group by Domain.DomainName, Storeroom.Code, RCV.MaterialSID, TH.MaterialUID
) WOReturns on Issues.IssueStoreroom = WOReturns.ReturnStoreroom and Issues.MaterialSID = WOReturns.MaterialSID and Issues.MaterialUID = WOReturns.MaterialUID
) SRIssues on StoreRM.Storeroom = SRIssues.IssueStoreroom
group by StoreDomainName.DomainName
order by 2
