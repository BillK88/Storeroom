WITH TMP_TRANS AS(SELECT * FROM azteca.TRANSHISTORY
WHERE TRANSTYPE='AUDIT'
)
SELECT DISTINCT
M.UNITOFMEASURE AS UM
,M.PARTNUMBER
,S.STORERM
,M.DESCRIPTION
,s.BINLOCATION
,TRANSDATETIME
,A.OLDQUANT AS SYSTEM_QTY
,A.NEWQUANT AS COUNT_QTY
,A.NEWQUANT-A.OLDQUANT AS VARIANCE
,M.UNITCOST AS UNIT_VALUE
,M.UNITCOST * A.OLDQUANT AS SYSTEM_TOTAL
,(A.NEWQUANT-A.OLDQUANT)*M.UNITCOST AS VARIANCE_TOTAL

 FROM azteca.MATERIALLEAF M

 JOIN azteca.STORERMSTOCK S
ON S.MATERIALSID=M.MATERIALSID

JOIN TMP_TRANS T
ON T.MATERIALUID=M.MATERIALUID
AND T.MATERIALSID=M.MATERIALSID

JOIN azteca.MATAUDIT A
ON A.TRANSACTIONID=T.TRANSACTIONID
AND A.MATERIALSID=M.MATERIALSID
AND A.STORERM=S.STORERM

WHERE 1=1
--38,612
--38,614 without DISTINCT

--===============================================================================
select count(*)
from MatAudit
--41,825

select count(*)
from MatAudit MA inner join TransHistory TH on MA.TransactionID = TH.TransactionID
--41,825

select count(*)
from MatAudit MA 
inner join TransHistory TH on MA.TransactionID = TH.TransactionID
inner join MaterialLeaf ML on MA.MaterialSID = ML.MaterialSID 
--41,823

select count(*)
from MatAudit MA 
inner join TransHistory TH on MA.TransactionID = TH.TransactionID
inner join MaterialLeaf ML on MA.MaterialSID = ML.MaterialSID 
inner join StoreRMStock SRS on MA.MaterialSID = SRS.MaterialSID and MA.StoreRM = SRS.StoreRM
--38,614

select *
from MatAudit
where MaterialSID in (
select MaterialSID
from MatAudit
except
select MaterialSID
from MaterialLeaf)
--MaterialSID = 7634, 2 audits


select MaterialSID, StoreRM
from MatAudit
except
select MaterialSID, StoreRM
from StoreRMStock
--1186 records

--================================================================================================
--difference between Edin's 38,612 and my 38,614 caused by 2 duplicate Audits
select count(*) DupeAudits, ML.MaterialUID,
ML.UnitOfMeasure, ML.PartNumber, MA.StoreRM, ML.Description, 
SRS.BinLocation, 
TH.TransDateTime, 
MA.OldQuant SystemQty, MA.NewQuant CountQty, 
ML.UnitCost UnitValue
from MatAudit MA 
inner join MaterialLeaf ML on MA.MaterialSID = ML.MaterialSID 
inner join StoreRMStock SRS on MA.MaterialSID = SRS.MaterialSID and MA.StoreRM = SRS.StoreRM
inner join TransHistory TH on MA.TransactionID = TH.TransactionID
group by 
ML.MaterialUID,
ML.UnitOfMeasure, ML.PartNumber, MA.StoreRM, ML.Description, 
SRS.BinLocation, 
TH.TransDateTime, 
MA.OldQuant, MA.NewQuant,  
ML.UnitCost
having count(*) > 1

--Without StoreRMStock inner join  get 41,823 records
select TH.TransactionID,
ML.MaterialUID,
ML.UnitOfMeasure, ML.PartNumber, MA.StoreRM, ML.Description, 
--SRS.BinLocation, 
TH.TransDateTime, 
MA.OldQuant SystemQty, MA.NewQuant CountQty, MA.NewQuant - MA.OldQuant  Variance, 
ML.UnitCost UnitValue,
ML.UnitCost * MA.OldQuant SystemTotal,
(MA.NewQuant - MA.OldQuant) * ML.UnitCost VarianceTotal
from MatAudit MA 
inner join MaterialLeaf ML on MA.MaterialSID = ML.MaterialSID 
--inner join StoreRMStock SRS on MA.MaterialSID = SRS.MaterialSID and MA.StoreRM = SRS.StoreRM
inner join TransHistory TH on MA.TransactionID = TH.TransactionID
--41,823 without StoreRMStock join

--================================================================================================
--================================================================================================
--StoreRMStock outer join
select TH.TransactionID,TH.TransType, TH.UnitCost TransUnitCost, TH.Comments,
ML.MaterialUID,
ML.UnitOfMeasure, ML.PartNumber, MA.StoreRM, ML.Description, 
SRS.BinLocation, 
TH.TransDateTime, 
MA.OldQuant OldQty, 
MA.NewQuant NewCountQty, 
MA.NewQuant - MA.OldQuant  VarianceQTY,
MA.OldUnitcost OldAuditUnitCost,
MA.NewUnitCost NewAuditUnitCost,
MA.OldQuant * MA.OldUnitCost AuditOldValue,
MA.NewQuant * MA.NewUnitCost AuditNewValue,
(MA.NewQuant * MA.NewUnitCost) - (MA.OldQuant * MA.OldUnitCost) AuditValueVariance,
MA.CostDiff AuditCostDiff,
ML.UnitCost MaterialUnitCost,
ML.UnitCost * MA.OldQuant MaterialSystemValue,
MA.OldUnitCost * MA.OldQuant OldAuditSystemValue,
MA.NewUnitCost * MA.NewQuant NewAuditSystemValue,
(MA.NewQuant - MA.OldQuant) * ML.UnitCost MaterialVarianceValue
from MatAudit MA 
inner join MaterialLeaf ML on MA.MaterialSID = ML.MaterialSID 
left outer join StoreRMStock SRS on MA.MaterialSID = SRS.MaterialSID and MA.StoreRM = SRS.StoreRM
inner join TransHistory TH on MA.TransactionID = TH.TransactionID
--41,823

