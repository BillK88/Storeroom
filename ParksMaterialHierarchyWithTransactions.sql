--Parks Material Hierarchy
--with Transaction Totals
;WITH MaterialTree (ParentSID, NodeSID, NodeName, NodeType, Level)
    AS
    (
        Select MN.ParentSID, MN.NodeSID, MN.NodeName, MN.NodeType, 0 AS Level
        From MaterialNode As MN
        Where NodeType = 'R'
        and MN.DomainID = (select DomainId from CWDomain where DomainName = 'PCR')
        UNION ALL
        Select MN.ParentSID, MN.NodeSID, MN.NodeName, MN.NodeType, Level + 1
        From MaterialNode As MN
        Inner Join MaterialTree As MT on MN.ParentSID = MT.NodeSID
        where DomainID = (select DomainId from CWDomain where DomainName = 'PCR')
    )
Select ParentSID, NodeSID, 
    Case When Level = 0 Then NodeName
	  Else Case When Level = 1 Then (select NodeName from MaterialNode where NodeSID = MT.ParentSID) + ' | ' + NodeName
      Else Case When Level = 2 Then (select t2.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + (select NodeName from MaterialNode where NodeSID = MT.ParentSID) + ' | ' + NodeName
      Else Case When Level = 3 Then (select t3.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID inner join MaterialNode t3 on t2.ParentSID = t3.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t2.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t1.NodeName from MaterialNode t1 where t1.NodeSID = MT.ParentSID) + ' | ' + NodeName
      Else Case When Level = 4 Then (select t4.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID inner join MaterialNode t3 on t2.ParentSID = t3.NodeSID inner join MaterialNode t4 on t3.ParentSID = t4.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t3.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID inner join MaterialNode t3 on t2.ParentSID = t3.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t2.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' +
		(select t1.NodeName from MaterialNode t1 where t1.NodeSID = MT.ParentSID)+  ' | ' + NodeName
End End End End End As NodeName, 
Level, NodeType,
ML.MaterialUID, ML.Description As MaterialDescription, ML.UnitCost
,Case NodeType When 'L' Then IsNull(Tissue.CntIssue,0) End IssueCount
,Case NodeType When 'L' Then Format(IsNull(Tissue.IssueValue,0), 'C', 'en-us') End IssueValue
,Case NodeType When 'L' Then Format(IsNull(Tissue.IssueValue/Tissue.CntIssue,0), 'C', 'en-us') End IssueCostPer
,Case NodeType When 'L' Then IsNull(Ttransfer.CntTransfer,0) End TransferCount
,Case NodeType When 'L' Then Format(IsNull(Ttransfer.TransferValue,0), 'C', 'en-us') End TransferValue
,Case NodeType When 'L' Then Format(IsNull(Ttransfer.TransferValue/Ttransfer.CntTransfer,0), 'C', 'en-us') End TransferCostPer
From MaterialTree MT
Left Outer Join MaterialLeaf ML on MT.NodeSID = ML.MaterialSID 
Left Outer Join (  --Issues
select TH.MaterialUID, Count(*) CntIssue
,Sum(ISS.Quantity * TH.UnitCost) IssueValue
from TransHistory TH inner join Issue ISS on TH.TransactionID = ISS.TransactionID group by TH.MaterialUID) Tissue
    on ML.MaterialUID = Tissue.MaterialUID
Left Outer Join ( --Transfer
select TH.MaterialUID, Count(*) CntTransfer
,Sum(TRN.Quantity * TH.UnitCost) TransferValue
from TransHistory TH inner join Transfer TRN on TH.TransactionID = TRN.TransactionID group by TH.MaterialUID) Ttransfer
    on ML.MaterialUID = Ttransfer.MaterialUID
	--where MaterialUID = 'PCR-1TMA2'
	--where MaterialUID = 'PCR-1N956'
	--where MaterialUID = 'PCR-1UFN1'
--	where MaterialUID = 'PCR-1UFP1'
--	where MaterialUID = 'PCR-8888A'
	--where MaterialUID = 'PCR-8888B'
	--where MaterialUID = 'PCR-1WE76'
--  where NodeType <> 'L'
Order By
    Case When Level = 0 Then NodeName
	  Else Case When Level = 1 Then (select NodeName from MaterialNode where NodeSID = MT.ParentSID) + ' | ' + NodeName
      Else Case When Level = 2 Then (select t2.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + (select NodeName from MaterialNode where NodeSID = MT.ParentSID) + ' | ' + NodeName
      Else Case When Level = 3 Then (select t3.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID inner join MaterialNode t3 on t2.ParentSID = t3.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t2.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t1.NodeName from MaterialNode t1 where t1.NodeSID = MT.ParentSID) + ' | ' + NodeName
      Else Case When Level = 4 Then (select t4.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID inner join MaterialNode t3 on t2.ParentSID = t3.NodeSID inner join MaterialNode t4 on t3.ParentSID = t4.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t3.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID inner join MaterialNode t3 on t2.ParentSID = t3.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' + 
		(select t2.NodeName from MaterialNode t1 inner join MaterialNode t2 on t1.ParentSID = t2.NodeSID where t1.NodeSID = MT.ParentSID) + ' | ' +
		(select t1.NodeName from MaterialNode t1 where t1.NodeSID = MT.ParentSID)+  ' | ' + NodeName
End End End End End