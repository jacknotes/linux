/*
��ȡ������ǩ��������Ʒϵͳ��ά��������Э�����Ϣ��лл
 
  �����ʽ��  UC�š���λ���ơ���˾2���� ������Э����е����� 
*/

select t.CmpId,un.Name,AirCompany,SfxyInfo from ehomsom..tbCompanyXY t
left join homsomDB..Trv_UnitCompanies  un on t.CmpId=un.Cmpid
where t.Type=2 --����
and IsSelfRv=1 --��ǩ