--�޸���ҵ���ù��ʺ���Ӫ����
select t.Cmpid as ��λ���,Name as ��λ����,t1.TcName as ���ù���,t2.MaintainName as ��Ӫ����
from homsomDB..Trv_UnitCompanies t
left join Topway..HM_AgreementCompanyTC t1 on t1.Cmpid=t.Cmpid and t1.TcName='�ų�'
left join Topway..HM_ThePreservationOfHumanInformation t2 on t2.CmpId=t.Cmpid and t2.MaintainName='��ѩ÷'
where t1.TcName='�ų�' and t2.MaintainName='��ѩ÷' and t2.IsDisplay='1' and t1.isDisplay='0'
and t.CooperativeStatus in('1','2','3')