--��������
SELECT  T1.[route] �г�,avg(price) ƽ�����ۼ�,SUM(price)/SUM(CAST(priceinfo AS DECIMAL)) ���ò�ƽ���ۿ���
FROM Topway..tbcash T1 WITH (NOLOCK)
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=T1.coupno
left join homsomDB..Trv_PnrInfos pn on pn.ID=d.PnrInfoID
left join homsomDB..Trv_ItktBookingSegs it on it.ItktBookingID=pn.ItktBookingID and T1.ride+T1.flightno=it.Flight
WHERE --T1.cmpcode = '020459'
it.FlightClass like'%����%'
AND T1.inf=0
AND T1.tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND ISNULL(T1.ModifyBillNumber,'') <> ''
and datetime>='2018-07-01'
and datetime<'2019-01-01'
and T1.[route] in('�����׶�-�Ϻ�����','�Ϻ�����-�����׶�','�Ϻ�����-�ɶ�','̫ԭ-�Ϻ�����','�ɶ�-�Ϻ�����')
--and (t1.ModifyBillNumber in('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (T1.ModifyBillNumber='020459_20181101' and T1.custid not in('D618538')))
GROUP BY T1.[route] 