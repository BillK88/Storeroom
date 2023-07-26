
--===========================================================================================================================
--All Issues
--===========================================================================================================================
--Excluding Audits
Select Storeroom.Code StoreRoom, Case Storeroom.IsActive When 1 Then 'Yes' Else 'No' End IsActive, Domain.DomainName
,IsNull(IssueQuantity,0) IssueQuantity
,IsNull(IssueValue,0) IssueValue
,IsNull(CntIssue,0) IssueTrans
from (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom 
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
left outer join --ALL Issues
(select Source IssueStoreroom, Sum(ISS.Quantity) IssueQuantity, Sum(ISS.Quantity * TH.UnitCost) IssueValue, Count(*) CntIssue
from azteca.Issue ISS inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null)
group by Source
) Tissue on Storeroom.Code = Tissue.IssueStoreroom
order by Storeroom.Code


--===========================================================================================================================
--All Receives
--===========================================================================================================================
--Excluding Audits
Select Storeroom.Code StoreRoom, Case Storeroom.IsActive When 1 Then 'Yes' Else 'No' End IsActive, Domain.DomainName
,IsNull(ReceiveQuantity,0) ReceiveQuantity
,IsNull(ReceiveValue,0) ReceiveValue
,IsNull(CntReceive,0) ReceiveTrans
from (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom 
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
left outer join --All Receives
(select Destination ReceiveStoreroom, Sum(Quantity) ReceiveQuantity, Sum(UnitCost * Quantity) ReceiveValue, Count(*) CntReceive
from azteca.Receive
where (AcctNum <> 'TRASH' or AcctNum is null)
group by Destination
) Treturn on Storeroom.Code = Treturn.ReceiveStoreroom
order by Storeroom.Code

--===========================================================================================================================
--All Transfers From/To
--===========================================================================================================================
Select Storeroom.Code StoreRoom, Case Storeroom.IsActive When 1 Then 'Yes' Else 'No' End IsActive, Domain.DomainName
,IsNull(TransferFromQuantity,0) FromQuantity
,IsNull(TransferFromValue,0) FromValue
,IsNull(CntTransferFrom,0) FromTrans
,IsNull(TransferToQuantity,0) ToQuantity
,IsNull(TransferToValue,0) ToValue
,IsNull(CntTransferTo,0) ToTrans
,IsNull(TransferFromQuantity,0) - IsNull(TransferToQuantity,0) NetFromToQuantity
,IsNull(TransferFromValue,0) - IsNull(TransferToValue,0) NetFromToValue
,IsNull(CntTransferFrom,0) - IsNull(CntTransferTo,0) NetFromToTrans
from (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom 
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
left outer join --Transfer From
(select Source FromStoreroom, Sum(TRN.Quantity) TransferFromQuantity, Sum(TRN.Quantity * TH.UnitCost) TransferFromValue, Count(*) CntTransferFrom
from azteca.Transfer TRN inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null) -- no Trash records for Transfers
group by Source
) Tfrom on Storeroom.Code = Tfrom.FromStoreroom
left outer join --Transfer To
(select Destination ToStoreroom, Sum(TRN.Quantity) TransferToQuantity, Sum(TRN.Quantity * TH.UnitCost) TransferToValue, Count(*) CntTransferTo
from azteca.Transfer TRN inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null) -- no Trash records for Transfers
group by Destination
) Tto on Storeroom.Code = Tto.ToStoreroom
order by Storeroom.Code

select *
from azteca.Transfer TRN
inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID

--===========================================================================================================================
--Net = All Receives from Supplier  - All Issues - Return from Work Order - Transfers From + Transfers To
--===========================================================================================================================
--Excluding Audits
Select Storeroom.Code StoreRoom, Case Storeroom.IsActive When 1 Then 'Yes' Else 'No' End IsActive, Domain.DomainName
--Quantity
,IsNull(ReceiveQuantity,0) ReceiveQuantity
,IsNull(IssueQuantity,0) IssueQuantity
,IsNull(ReturnQuantity,0) ReturnWOQuantity
,IsNull(TransferFromQuantity,0) FromQuantity
,IsNull(TransferToQuantity,0) ToQuantity
,IsNull(ReceiveQuantity,0) - IsNull(IssueQuantity,0) - IsNull(ReturnQuantity, 0) - IsNull(TransferFromQuantity,0) + IsNull(TransferToQuantity,0) NetQuantity
,IsNull(CntItems, 0) CntItems
,IsNull(QOH, 0) QOnHand
--Value
,IsNull(ReceiveValue,0) ReceiveValue
, IsNull(IssueValue,0) IssueValue
, IsNull(ReturnValue,0) ReturnWOValue
,IsNull(TransferFromValue,0) FromValue
,IsNull(TransferToValue,0) ToValue
,IsNull(ReceiveValue,0) - IsNull(IssueValue,0) - IsNull(ReturnValue, 0) - IsNull(TransferFromValue,0) + IsNull(TransferToValue,0) NetValue
--Transactions
,IsNull(CntReceive,0) ReceiveTrans
,IsNull(CntIssue,0) IssueTrans
,IsNull(CntReturn,0) ReturnTrans
,IsNull(CntTransferFrom,0) FromTrans
,IsNull(CntTransferTo,0) ToTrans
from (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom 
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
left outer join (select StoreRM, Count(MaterialSID) CntItems, Sum(StockOnHand) QOH from azteca.StoreRMStock group by StoreRM) SRS on Storeroom.Code = SRS.StoreRM
left outer join --Receives from Supplier
(select Destination ReceiveStoreroom, Sum(Quantity) ReceiveQuantity, Sum(UnitCost * Quantity) ReceiveValue, Count(*) CntReceive
from azteca.Receive
where (AcctNum <> 'TRASH' or AcctNum is null)
and Len(SupplierUID) > 0
group by Destination
) Treturn on Storeroom.Code = Treturn.ReceiveStoreroom
left outer join --Issues
(select Source IssueStoreroom, Sum(ISS.Quantity) IssueQuantity, Sum(ISS.Quantity * TH.UnitCost) IssueValue, Count(*) CntIssue
from azteca.Issue ISS inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null)
group by Source
) Tissue on Storeroom.Code = Tissue.IssueStoreroom
left outer join --Return from Work Order
(select Destination ReturnStoreroom, Sum(Quantity) ReturnQuantity, Sum(UnitCost * Quantity) ReturnValue, Count(*) CntReturn
from azteca.Receive
where Len(WorkOrderID) > 0
group by Destination
) Tworeturn on Storeroom.Code = Tworeturn.ReturnStoreroom
left outer join --Transfer From
(select Source FromStoreroom, Sum(TRN.Quantity) TransferFromQuantity, Sum(TRN.Quantity * TH.UnitCost) TransferFromValue, Count(*) CntTransferFrom
from azteca.Transfer TRN inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null) -- no Trash records for Transfers
group by Source
) Tfrom on Storeroom.Code = Tfrom.FromStoreroom
left outer join --Transfer To
(select Destination ToStoreroom, Sum(TRN.Quantity) TransferToQuantity, Sum(TRN.Quantity * TH.UnitCost) TransferToValue, Count(*) CntTransferTo
from azteca.Transfer TRN inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null) -- no Trash records for Transfers
group by Destination
) Tto on Storeroom.Code = Tto.ToStoreroom
order by Storeroom.Code
