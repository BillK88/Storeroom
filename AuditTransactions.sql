--===========================================================
Select TH.TransactionID, TH.TransType, TH.TransDateTime, TH.RecordDateTime, TH.MaterialSID, TH.MaterialUID, TH.PartNumber, TH.Personnel, TH.PersonnelSID, TH.UnitCost, TH.Comments,
MA.StoreRM AuditStoreRM, MA.OldQuant AuditOldQuant, MA.NewQuant AuditNewQuant, Ma.OldQuant - MA.NewQuant QuantDiff, MA.OldUnitCost AuditOldUC, MA.NewUnitCost AuditNewUC, MA.OldUnitCost - MA.NewUnitCost UCostDiff, MA.CostDiff AuditCostDiff, --MA.AcctNum AuditAcctNum, MA.Reason AuditReason,
Rcv.TransactionID RcvTransID, Rcv.Comments RcvComments, Rcv.UnitCost RcvUnitCost, Rcv.Quantity RcvQuant, Rcv.Destination RcvDestination, Rcv.AcctNum RcvAcctNum,
Iss.TransactionID IssTransID, Iss.Comments IssComments, Iss.Source IssSource, Iss.Quantity IssQuantity --, Iss.EmpName
from azteca.TransHistory TH
inner join azteca.MatAudit MA on TH.TransactionID = MA.TransactionID
left outer join 
( select th1.TransactionID, th1.Comments, r.MaterialSID, r.UnitCost, r.Quantity, r.Destination, r.AcctNum
from azteca.TransHistory th1 
inner join azteca.Receive r on th1.TransactionID = r.TransactionID
where th1.TransType = 'RECEIVE' 
and th1.Comments like 'Received from Trash by Audit%') Rcv 
on th.TransactionId= Convert(int,SubString(Rcv.Comments, CharIndex('(',Rcv.Comments) + 1, (CharIndex(')',Rcv.Comments) -1 )- CharIndex('(',Rcv.Comments) ) )
left outer join 
( select th1.TransactionID, th1.Comments, I.MaterialSID, I.Source, I.Quantity, I.EmpName
from azteca.TransHistory th1
inner join azteca.Issue I on th1.TransactionID = I.TransactionID
where th1.TransType = 'ISSUE' 
and th1.Comments like 'Issued to Trash by Audit%') Iss 
on th.TransactionId= Convert(int,SubString(Iss.Comments, CharIndex('(',Iss.Comments) + 1, (CharIndex(')',Iss.Comments) -1 )- CharIndex('(',Iss.Comments) ) )
where 1 = 1
and Personnel like 'Levine%'
and TransDateTime >= '2022-09-13'
and TransDateTime < '2022-09-14'
and th.TransType = 'AUDIT'
order by 1
