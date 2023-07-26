--Added a comment
select *
from azteca.MatAudit AUD inner join azteca.TransHistory TRN on AUD.TransactionID = TRN.TransactionID
left outer join (select StoreRM, Count(MaterialSID) CntItems, Sum(StockOnHand) QOH from azteca.StoreRMStock group by StoreRM) SRS on AUD.StoreRM = SRS.StoreRM
where AUD.StoreRM = 'N-GMD'

--48,877

select StoreRM, TransDateTime, RecordDateTime
,OldQuant, OldUnitCost, OldQuant * OldUnitCost OldValue
,NewQuant, NewUnitCost, NewQuant * NewUnitCost NewValue
,NewQuant - OldQuant NetQuant
,NewQuant * NewUnitCost - OldQuant * OldUnitCost NetValue
,CostDiff
from (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom 
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
left outer join 
(select StoreRM,
azteca.MatAudit AUD 
) AUD on AUD.StoreRM = Storeroom.Code 
where StoreRM = 'FIELD SERVICES'

Select Storeroom.Code StoreRoom, Case Storeroom.IsActive When 1 Then 'Yes' Else 'No' End IsActive, Domain.DomainName
,OldQuant, OldValue
,NewQuant, NewValue
,NetQuant, NetValue
,CntTrans
,CntAuditItems
,CntItems
,QOH QOnHand
from (select Code, IsActive from azteca.PWCode where CodeType = 'STORERM') Storeroom 
inner join azteca.StoreDomainStore SRDomain on Storeroom.Code = SRDomain.Storeroom
inner join azteca.StoreDomain Domain on SRDomain.DomainID = Domain.DomainID
left outer join (select StoreRM, Count(MaterialSID) CntItems, Sum(StockOnHand) QOH from azteca.StoreRMStock group by StoreRM) SRS on Storeroom.Code = SRS.StoreRM
left outer join --Audit
(select StoreRM
,Sum(OldQuant) OldQuant, Sum(OldQuant * OldUnitCost) OldValue
,Sum(NewQuant) NewQuant, Sum(NewQuant * NewUnitCost) NewValue
,Sum(NewQuant - OldQuant) NetQuant
,Sum(NewQuant * NewUnitCost - OldQuant * OldUnitCost) NetValue
,Sum(CostDiff) CostDiff
,Count(*) CntTrans
,Count(distinct MaterialSID) CntAuditItems
from azteca.MatAudit
group by StoreRM ) AUD on Storeroom.Code = AUD.StoreRM
order by 1