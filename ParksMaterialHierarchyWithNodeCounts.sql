--Parks Material Hierarchy
--Leaf Nodes do not display
--Instead, Node Counts do display
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
Select MT.ParentSID, MT.NodeSID, 
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
Level, NodeType, IsNull(NodeCnt,0) NodeCnt
    From MaterialTree MT
    Left Outer Join (select ParentSID, Count(*) NodeCnt from MaterialNode Group By ParentSID ) MNCnt on MT.NodeSID = MNCnt.ParentSID 
  where NodeType <> 'L'
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