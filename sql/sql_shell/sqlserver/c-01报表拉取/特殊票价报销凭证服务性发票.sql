/*
��Ҫ����Ϣ��
UC����λ���ơ����ù��ʡ���Ӫ����
 
ɸѡ������
1.�����������Ʊ��Ϊ����
2.���ڻ�Ʊ����ƾ֤Ϊ���г̵�
3.����Ʊ�۱���ƾ֤Ϊ�������Է�Ʊ
*/

select u.Cmpid,u.Name,isnull(s.Name,'') ���ù���,isnull(MaintainName,'') ��Ӫ����
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs a on a.TktUnitCompanyID=u.ID 
LEFT JOIN homsomDB..SSO_Users s ON s.ID=a.TktTCID
left join Topway..HM_ThePreservationOfHumanInformation t on t.CmpId=u.Cmpid and MaintainType=9 and t.IsDisplay=1
where CertificateD=1
and IsSepPrice=1
and InvoiceType=2
and CooperativeStatus in ('1','2','3')
and u.Cmpid not in ('000003','000006')