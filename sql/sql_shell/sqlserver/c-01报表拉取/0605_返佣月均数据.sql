
--�з�Ӷ���޷�Ӷ�¾�����
--�ɱ��ֶ� ��Ʊʱ��� �Ƿ��з�Ӷ
select convert(varchar(6),datetime,112) m,sum(amount) as ����,SUM(xfprice) as ��Ӷ,SUM(tax) ˰��,count(1) ����
--,sum(amount)*1.0/count(1)
 ,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS ƽ���ۿ���
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448' )
        
		AND ( datetime BETWEEN '2017-01-01' AND '2018-10-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and xfprice<>0
group by convert(varchar(6),datetime,112)
order by m


--����
--UNION ALL
--select convert(varchar(4),datetime,112) m,SUM(xfprice),SUM(tax),sum(amount),count(1) num,--sum(amount)*1.0/count(1),
-- AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS zkpercent
--FROM    V_TicketInfo
--WHERE   ( cmpcode = '016448' )
       
--		AND ( datetime BETWEEN '2017-01-01' AND '2018-10-31' )
--        AND ( reti = '' )
--        AND ( inf = 0 )
--        and xfprice<>0
--group by convert(varchar(4),datetime,112)
--order by m
