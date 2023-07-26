Declare @asOfDate varchar(10) = '2023-03-01'
Declare @StoreRoom varchar(20) = 'SW-BWAS'

--Net = All Receives from Supplier  - All Issues - Return from Work Order - Transfers From + Transfers To
--===========================================================================================================================
--Excluding Audits
Select Storeroom.Code StoreRoom, Case Storeroom.IsActive When 1 Then 'Yes' Else 'No' End IsActive, Domain.DomainName, ML.MaterialUID
--Quantity
,IsNull(ReceiveQuantity,0) ReceiveQuantity
,IsNull(IssueQuantity,0) IssueQuantity
,IsNull(ReturnQuantity,0) ReturnWOQuantity
,IsNull(TransferFromQuantity,0) FromQuantity
,IsNull(TransferToQuantity,0) ToQuantity
,IsNull(ReceiveQuantity,0) - IsNull(IssueQuantity,0) - IsNull(ReturnQuantity, 0) - IsNull(TransferFromQuantity,0) + IsNull(TransferToQuantity,0) NetQuantity
--PointInTimeQuantity = Current Quantity - Net Quantity
,IsNull(SRS.StockOnHand, 0)  - (IsNull(ReceiveQuantity,0) - IsNull(IssueQuantity,0) - IsNull(ReturnQuantity, 0) - IsNull(TransferFromQuantity,0) + IsNull(TransferToQuantity,0) ) PrevQuantity 
--,IsNull(CntItems, 0) CntItems
,IsNull(SRS.StockOnHand, 0) CurrentQOnHand
,ML.UnitCost CurrentUnitCost
,IsNull(SRS.StockOnHand, 0) * ML.UnitCost CurrentValue
--Value
,IsNull(ReceiveValue,0) ReceiveValue
, IsNull(IssueValue,0) IssueValue
, IsNull(ReturnValue,0) ReturnWOValue
,IsNull(TransferFromValue,0) FromValue
,IsNull(TransferToValue,0) ToValue
,IsNull(ReceiveValue,0) - IsNull(IssueValue,0) - IsNull(ReturnValue, 0) - IsNull(TransferFromValue,0) + IsNull(TransferToValue,0) NetValue
,IsNull(SRS.StockOnHand, 0) * ML.UnitCost - (IsNull(ReceiveValue,0) - IsNull(IssueValue,0) - IsNull(ReturnValue, 0) - IsNull(TransferFromValue,0) + IsNull(TransferToValue,0) ) PrevValue --PointInTimeValue
--Transactions
,IsNull(CntReceive,0) ReceiveTrans
,IsNull(CntIssue,0) IssueTrans
,IsNull(CntReturn,0) ReturnTrans
,IsNull(CntTransferFrom,0) FromTrans
,IsNull(CntTransferTo,0) ToTrans
from StoreRMStock SRS inner join 
(select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom on SRS.StoreRM = Storeroom.Code
inner join MaterialLeaf ML on ML.MaterialSID = SRS.MaterialSID
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
--left outer join (select StoreRM, Count(MaterialSID) CntItems, Sum(StockOnHand) QOH from azteca.StoreRMStock group by StoreRM) SRS on Storeroom.Code = SRS.StoreRM
left outer join --Receives from Supplier
(select TH.MaterialSID, Destination ReceiveStoreroom, Sum(RCV.Quantity) ReceiveQuantity, Sum(RCV.UnitCost * RCV.Quantity) ReceiveValue, Count(*) CntReceive
from azteca.Receive RCV inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null)
and Len(SupplierUID) > 0
and Cast(TransDateTime as Date) >= @asOfDate
group by TH.MaterialSID, Destination
) Treturn on Storeroom.Code = Treturn.ReceiveStoreroom and Treturn.MaterialSID = ML.MaterialSID
left outer join --Issues
(select TH.MaterialSID, Source IssueStoreroom, Sum(ISS.Quantity) IssueQuantity, Sum(ISS.Quantity * TH.UnitCost) IssueValue, Count(*) CntIssue
from azteca.Issue ISS inner join azteca.TransHistory TH on ISS.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null)
and Cast(TransDateTime as Date) >= @asOfDate
group by TH.MaterialSID, Source
) Tissue on Storeroom.Code = Tissue.IssueStoreroom and Tissue.MaterialSID = ML.MaterialSID
left outer join --Return from Work Order
(select TH.MaterialSID, Destination ReturnStoreroom, Sum(RCV.Quantity) ReturnQuantity, Sum(RCV.UnitCost * RCV.Quantity) ReturnValue, Count(*) CntReturn
from azteca.Receive RCV inner join azteca.TransHistory TH on RCV.TransactionID = TH.TransactionID
where Len(WorkOrderID) > 0
and Cast(TransDateTime as Date) >= @asOfDate
group by TH.MaterialSID, Destination
) Tworeturn on Storeroom.Code = Tworeturn.ReturnStoreroom and Tworeturn.MaterialSID = ML.MaterialSID
left outer join --Transfer From
(select TH.MaterialSID, Source FromStoreroom, Sum(TRN.Quantity) TransferFromQuantity, Sum(TRN.Quantity * TH.UnitCost) TransferFromValue, Count(*) CntTransferFrom
from azteca.Transfer TRN inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null) -- no Trash records for Transfers
and Cast(TransDateTime as Date) >= @asOfDate
group by TH.MaterialSID, Source
) Tfrom on Storeroom.Code = Tfrom.FromStoreroom and Tfrom.MaterialSID = ML.MaterialSID
left outer join --Transfer To
(select TH.MaterialSID, Destination ToStoreroom, Sum(TRN.Quantity) TransferToQuantity, Sum(TRN.Quantity * TH.UnitCost) TransferToValue, Count(*) CntTransferTo
from azteca.Transfer TRN inner join azteca.TransHistory TH on TRN.TransactionID = TH.TransactionID
where (AcctNum <> 'TRASH' or AcctNum is null) -- no Trash records for Transfers
and Cast(TransDateTime as Date) >= @asOfDate
group by TH.MaterialSID, Destination
) Tto on Storeroom.Code = Tto.ToStoreroom and Tto.MaterialSID = ML.MaterialSID
where Storeroom.Code = @StoreRoom
--group by  Storeroom.Code, Storeroom.IsActive, Domain.DomainName, ML.MaterialUID
order by  ML.MaterialUID, Storeroom.Code
