select datetime as ��Ʊ����,coupno as ���۵���,totprice as ���ۼ�,sales as ����ҵ�����
from Topway..tbcash where pform='�½�' and status=0  --and trvYsId<>'0' or ConventionYsId<>'0' 
and  datetime>'2016-01-01' and datetime<'2019-01-01'
order by datetime