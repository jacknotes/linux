select yf.cmpid as ��λ���,m.cmpname as ��λ����,hotel as �Ƶ�����,pasname as ��ס��,beg_date as ��ס����,end_date as �˷�����,yf.fwprice as �����,CostCenter as �ɱ�����
,nights*pcs as ��ҹ,prdate as ��ӡ����,price as ���ۼ�,f.totprice as Ӧ�ս��
from tbHtlcoupYf yf
inner join tbCompanyM m on m.cmpid=yf.cmpid
inner join tbhtlyfchargeoff f on f.coupid=yf.id
where yf.cmpid in ('')
and (prdate>='' and prdate<'')

