--���������������Ʊ�����޹��ڻ�Ʊ������·���ں�����
select u.Cmpid as UC ,u.Name as ��λ���� from homsomDB..Trv_UnitCompanies u
left join Topway..tbCompanyM t on t.cmpid=u.Cmpid
where t.hztype  not in (0,4)
and u.ID not in (SELECT UnitCompanyID FROM homsomDB..Trv_FlightAdvancedPolicies WHERE   Name='���ڻ�Ʊ������·')
and u.IsSepPrice=1