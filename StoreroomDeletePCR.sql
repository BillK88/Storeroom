--Delete Storeroom data from TEST for PCR only

delete StoreRMStock
from StoreRMStock SRS
inner join MaterialLeaf ML
on SRS.MaterialSID = ML.MaterialSID
where ML.MaterialUID like 'PCR-%'

delete from MaterialLeaf
where MaterialUID like 'PCR-%'

delete from MaterialNode
where DomainID = 6

