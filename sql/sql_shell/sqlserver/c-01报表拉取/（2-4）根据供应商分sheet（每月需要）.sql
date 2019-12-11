select cmpcode as ��λ���,m.cmpname as ��λ����,c.pasname as �˻���,c.idno as ֤����, t_source as ��Ӧ����Դ,COUNT(*)
from tbcash c
inner join tbCompanyM m on m.cmpid=c.cmpcode
where (datetime>='2017-11-13' and datetime<'2017-12-12')
and inf=1
and ride in ('MU','FM')
and pasname not like ('%CHD%')
and pasname not like ('%MSRT%')
and pasname not like ('%MISS%')
and pasname not like ('%INF%')
group by cmpcode,m.cmpname,c.pasname,c.idno,t_source
order by t_source

/*
1.EXCEL��������͸�ӱ�ѡ��ȫ��
2.����Ӧ����Դ����ɸѡ��������������
3.�˵�����ơ����������ѡ�񡾲���ʾ������ܡ�
�˵�����ơ���������ѡ���Ա����ʽ��ʾ��
����-ѡ��-��ʾ����ɸѡҳ-����Ӧ����Դ��ȷ��
*/

select cmpcode as ��λ���,m.cmpname as ��λ����,c.pasname as �˻���,c.idno as ֤����, t_source as ��Ӧ����Դ
from tbcash c
inner join tbCompanyM m on m.cmpid=c.cmpcode
where (datetime>='2017-11-13' and datetime<'2017-12-12')
and inf=1
and ride in ('MU','FM')
and (pasname like ('%CHD%')
or pasname like ('%MSRT%')
or pasname like ('%MISS%')
or pasname like ('%INF%'))
order by t_source