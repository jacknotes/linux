--��Ʊ���ۼ���Ϣ
select TotPrice,TotFuprice,TotUnitprice,TotSprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotPrice=TotPrice-380,TotUnitprice=TotUnitprice-380,TotSprice=TotSprice-380
where CoupNo='RS000026052'

select RealPrice,Fuprice,SettlePrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set RealPrice=RealPrice-380,SettlePrice=SettlePrice-380
where TrainTicketNo=(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000026052')

--��Ʊ���ۼ���Ϣ
select TotPrice,TotFuprice,TotUnitprice,TotSprice,* from Topway..tbTrainTicketInfo 
--update Topway..tbTrainTicketInfo  set TotFuprice=TotFuprice+10,TotPrice=TotPrice+10
where CoupNo in('RS000025244','RS000025245','RS000025246','RS000025248','RS000025247')

select RealPrice,Fuprice,SettlePrice,* from Topway..tbTrainUser 
--update Topway..tbTrainUser  set Fuprice=Fuprice+10
where TrainTicketNo in(Select ID from Topway..tbTrainTicketInfo 
where CoupNo in('RS000025244','RS000025245','RS000025246','RS000025248','RS000025247'))

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Ա���渶�����깤�п���'
where CoupNo in('PTW085611','PTW085613','PTW085614','PTW085615','PTW085616','PTW085617')

/*
UC017415�Ÿ���Ϻ�����ҵ���޹�˾ 
2019 1��--5��  MU/FM ���ڻ�Ʊ ԭ�� ���۵��� ˰�� �����ܼ� ����� �Żݽ��
2019 1��---5�� ���й��ʻ�Ʊ�����۵��� ˰�� �����ܼ� ����� ǰ�����
*/
select cmpcode UC��,coupno ���۵���,originalprice ԭ��,price ���۵���,tax ˰��,totprice �����ܼ�,fuprice �����,originalprice-price �Żݽ��
from Topway..tbcash 
where cmpcode='017415'
and datetime>='2019-01-01'
and datetime<'2019-06-01'
and ride in('mu','fm')
and inf=0
order by datetime

select cmpcode UC��,coupno ���۵���,price ���۵���,tax ˰��,totprice �����ܼ�,fuprice �����,xfprice ǰ�����
from Topway..tbcash 
where cmpcode='017415'
and datetime>='2019-01-01'
and datetime<'2019-06-01'
and inf=1
order by datetime

--�Ƶ����۵��ؿ���ӡȨ��
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate-'1900-01-01'
where CoupNo='PTW085398'


select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank=1
where idnumber in('0738','0739','0740')

select employeeId,* from Topway..Emppwd 
--update Topway..Emppwd  set employeeId=136
where idnumber in('0740')


--�鷳��� �˻��ˣ�������� ��· ��λ���� �ۿ���
select coupno,pasname �˻���,begdate �������,route ��·,nclass ��λ����,price/priceinfo  �ۿ���
from Topway..tbcash
where coupno in('AS002169827',
'AS002178346',
'AS002220532',
'AS002228321',
'AS002261871',
'AS002261873',
'AS002305549',
'AS002305551',
'AS002323290',
'AS002331243',
'AS002344920',
'AS002344922',
'AS002350639',
'AS002350643',
'AS002385912',
'AS002401047',
'AS002401049',
'AS002404962',
'AS002422427',
'AS002424897',
'AS002437537',
'AS002515185',
'AS002515185',
'AS002515185')
order by coupno

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='016500_20190501'

--�ؿ���ӡ
select SettleStatus,Pstatus,PrDate,PrName,* from Topway..tbTrvSettleApp 
--update Topway..tbTrvSettleApp  set SettleStatus=1,Pstatus=0,PrDate='1900-01-01',PrName=''
where Id='27618'

select SettleStatus,Pstatus,PrDate,PrName,* from Topway..tbConventionSettleApp 
--update Topway..tbConventionSettleApp  set SettleStatus=1,Pstatus=0,PrDate='1900-01-01',PrName=''
where Id='3948'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='������',SpareTC='������' 
where coupno in('AS001750117','AS001782332')

/*
    �鷳����ȡ��ۺ������ݣ�лл 
 
    ��Ʊ���ڣ�2018��1��-2018��12�� ��2019��1��-2019��6��
    ���չ�˾��HX
    
    ����Ҫ��: ���ڡ����۵��š�Ʊ�š����̡���λ
*/
select convert(varchar(10),datetime,120) ��Ʊ����,coupno ���۵���,tcode+ticketno Ʊ��,route ����,nclass ��λ,reti ��Ʊ����
from Topway..tbcash 
where ride='hx'
and datetime>='2018-01-01'
order by ��Ʊ����

--��Ʊҵ�������Ϣ
SELECT Sales,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set Sales='��ӱ'
where coupno in('PTW084575','PTW084460','PTW083761','PTW084110','PTW084707')

--��Ʊ���
select Pstatus,PrintDate,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent  set Pstatus=1,PrintDate=GETDATE()
where Id='703830'

--�����տ���Ϣ
select vpayinfo,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set vpayinfo='΢��'
where TrvId='30336' and Id='228487'

--���۵����16��
select MobileList,CostCenter,pcs,Department,* from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='16',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002592758')


--��Ʊ��
--select pasname,* from Topway..tbcash where coupno='AS002592758'
--update Topway..tbcash set pasname='',tcode='',ticketno='' where coupno='' and pasname=''

