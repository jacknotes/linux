/*����=1
�ֹ�����=2
�绰Ԥ��=3
�հ׵���=4
app=5
����=7
����=6
�����ڲ�=8
�����ڲ�=9
΢��Ԥ��=10
wapԤ��=11
*/
--PC�� ����

select sum(price) ����,COUNT(c.id) ���� from Topway..tbcash  c
left join homsomDB..Trv_ItktBookings i on c.BaokuID=i.ID
where (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and custid not in('D618538')))
--and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and inf=0
and tickettype='����Ʊ'

--PC�� ����
select sum(price) ����,COUNT(c.id) ���� from Topway..tbcash  c
--inner join homsomDB..Intl_BookingOrders i on c.recno=i.PNR
where (ModifyBillNumber in ('020459_20180701','020459_20180801','020459_20180901','020459_20181001','020459_20181201') or (ModifyBillNumber='020459_20181101' and c.custid not in('D618538')))
and cmpcode='020459'
--and i.BookingSource='1'
--and i.BookingSource in ('5','10','11')
--and i.BookingSource in ('2','3','4')
and tickettype='����Ʊ'
AND tickettype NOT IN ('���ڷ�', '���շ�','��������')
AND c.route NOT LIKE '%����%' 
AND c.route NOT LIKE '%����%'
and inf=1