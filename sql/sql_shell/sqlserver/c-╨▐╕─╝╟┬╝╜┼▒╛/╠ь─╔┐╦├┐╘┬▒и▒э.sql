--��һ�ű�
--�����з�Ӷ����˰�յ��� 
select convert(varchar(6),datetime,112) as �·�,SUM(totprice) as ����,SUM(xfprice) as ��Ӷ,SUM(tax) as ˰��,COUNT(1) as ����,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS ƽ���ۿ���
from Topway..tbcash
where cmpcode='016448'
and (datetime between '2018-01-01' and '2018-12-31')
and reti=''
and inf=0
and xfprice<>0
and tickettype='����Ʊ'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)

--�ڶ���
--���ڵ�λ�ͻ���˾�¾�����
select convert(varchar(6),datetime,112) as �·�,sum(totprice) as ����,SUM(tax) as ˰��,count(1) ����,
sum(totprice)*1.0/count(1) as ƽ��Ʊ��,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS ƽ���ۿ���
FROM Topway..tbcash
WHERE cmpcode='016448'
and (datetime between '2019-01-01' and '2019-12-31')
and reti=''
and inf=0
and tickettype='����Ʊ'
and ride in('mu','fm')--mu��fmһ����
--and ride='cz'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order by �·�

--������
--���ڵ�λ�ͻ������¾�����
select top 5 convert(varchar(6),datetime,112) as �·�,sum(totprice-tax) as ����,SUM(tax) as ˰��,count(1) ����,
sum(totprice)*1.0/count(1) as ƽ��Ʊ��,
AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS ƽ���ۿ���
FROM Topway..tbcash
WHERE cmpcode='016448'
and (datetime between '2019-01-01' and '2019-12-31')
and reti=''
and inf=0
and tickettype='����Ʊ'
and route='�Ϻ�����-�����׶�'
and CostCenter='ca'
group by convert(varchar(6),datetime,112)
order by �·�
