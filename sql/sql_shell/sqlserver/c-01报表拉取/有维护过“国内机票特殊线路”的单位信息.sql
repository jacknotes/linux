
--���е�λ�ͻ��У���ƱӶ�������ά���������ڻ�Ʊ������·���ĵ�λ��Ϣ��
--����Ҫ�أ� ��λ���ơ��õ�λ�µĳ��ÿ���������

select up.Cmpid,up.Name,COUNT(*)
from homsomdb..Trv_UnitCompanies up
inner join Topway..tbCompanyM m on m.cmpid=up.Cmpid
inner join homsomdb..Trv_UnitPersons p on p.CompanyID=up.ID
inner join homsomdb..Trv_Human h on h.ID=p.ID and IsDisplay=1
where p.CompanyID in (SELECT UnitCompanyID FROM homsomDB..Trv_FlightAdvancedPolicies WHERE   Name='���ڻ�Ʊ������·') and up.Cmpid='020530'
and m.hztype not in (0,4)
group by Up.cmpid,up.Name



--������ǩ���ߣ��������������������������ߵĿͻ�����
select uc.Cmpid,Name from homsomDB..Trv_UnitCompanies uc
inner join Topway..tbCompanyM m on m.cmpid=uc.Cmpid
where m.hztype not in (0,4) and  uc.ID in(
select UnitCompanyID from homsomDB..Trv_FlightAdvancedPolicies where (getdate() between StartTime and EndTime) group by UnitCompanyID
) and uc.ID in (
select UnitCompanyID from homsomDB..Trv_FlightTripartitePolicies where (convert(date,getdate()) between CONVERT(varchar(100),SUBSTRING (NewStartTime,0, CHARINDEX(',', NewStartTime)),23) and CONVERT(varchar(100),SUBSTRING (NewendTime,0, CHARINDEX(',', NewendTime)),23)) group by UnitCompanyID
) group by uc.ID,uc.Cmpid,Name

