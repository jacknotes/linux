select c.cmpcode as ��λ���,m.cmpname as ��λ����,c.pasname as �˻���,c.idno as ֤����
,SUM(totsprice) as ����ۺϼ�
,case uc.IsSepPrice when 0 then '��������' when 1 then '��������' else '' end as ����Ʊ��
from topway..tbcash c
left join topway..tbCompanyM m on m.cmpid=c.cmpcode
left join homsomDB..Trv_UnitCompanies uc on uc.Cmpid=c.cmpcode
where c.datetime>='2018-01-01' and c.datetime<'2018-12-18'
and tickettype='����Ʊ'
and m.hztype not in (0,4)
and inf=0
group by c.cmpcode,m.cmpname,c.pasname,c.idno,uc.IsSepPrice 
order by c.cmpcode
