--�ɱ��ֶ� ��Ʊʱ��� ��λ��� ����
select convert(varchar(6),datetime,112) m,sum(amount) as ����,count(1) ����
,sum(amount)*1.0/count(1)
 ,AVG(CASE WHEN ISNULL(priceinfo,0)=0 THEN 0 ELSE	price/priceinfo END) AS ƽ���ۿ���
FROM    V_TicketInfo
WHERE   ( cmpcode = '016448' )
        
		AND ( datetime BETWEEN '2017-01-01' AND '2018-10-31' )
        AND ( reti = '' )
        AND ( inf = 0 )
        and route in ('����-�Ϻ�����')
group by convert(varchar(6),datetime,112)
order by m