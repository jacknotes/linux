--�޸���Ӫ����
select MaintainName,* from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation  set MaintainName='������'
where CmpId in ('019437','019773','018387','019841','020279') and IsDisplay=1 and MaintainType=9

--�޸���Ӫ����
select MaintainName,MaintainNumber,* from Topway..HM_ThePreservationOfHumanInformation 
--update Topway..HM_ThePreservationOfHumanInformation  set MaintainName='������',MaintainNumber='0665'
where CmpId in ('019437','019773','018387','019841','020279') and IsDisplay=1 and MaintainType=9

--ɾ���Ƶ����۵�

select * from Topway..tbTrvJS where TrvId='029206' and JsPrice='23888'
delete from Topway..tbHtlcoupYf where CoupNo='PTW075468'

--�ĵ���ʱ��
select * 
--update topway..FinanceERP_ClientBankRealIncomeDetail set date='2019-1-23'
from topway..FinanceERP_ClientBankRealIncomeDetail where money='196295.00' and date='2019-1-22'
 
--���ν��㵥��Ϣ��Ӧ�����Ƹ���
select GysSource,* from topway..tbTrvJS 
--update topway..tbTrvJS  set GysSource='�����Ƽ�����ʿ�����ʣ�'
where TrvId='29000' and Id='143029'

--UC019788��UC019786�ϼ�����
--��Ʊ
select SUM(totprice) as �ϼ����� from topway..tbcash 
where cmpcode in ('019788','019786') and datetime>='2018-01-01' and datetime<'2019-01-01'
and reti=''

--�Ƶ�
select SUM(price) as �ϼ����� from topway..tbHtlcoupYf 
where prdate>='2018-01-01' and prdate<'2019-01-01' and cmpid in('019788','019786')
--2018��ȣ���2018��1��1��-2018��12��31�գ�UC019788������������ʵҵ���޹�˾��UC019786�������������豸���޹�˾���ҹ�˾�ϲ��������������а�����Ʊ���Ƶ꣬��Ʊ��Ʊ���⣩

--�Ƶ����۵��ؿ���ӡȨ��
select pstatus,prdate,* from topway..tbHtlcoupYf 
--update topway..tbHtlcoupYf set pstatus='0',prdate='1900-01-01'
where CoupNo='PTW075453'

--�޸Ĵ�����
select disct,* from topway..tbcash  
--update topway..tbcash set disct='2200'
where coupno='AS002226288'

--����������ѯ
select * from ehomsom..tbPlanetype  where aname='32H'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('124','�տ�','A320ϵ��','A320','32H','150-180','խ��')

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ
select t_source,* from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002218771'

--��Ʊ���
select TrainServiceCharge,TrainSpecialInvoiceUsedAmount,TrainOrdinaryInvoiceUsedAmount,* from topway..AccountStatement 
--update topway..AccountStatement set TrainServiceCharge='0',TrainOrdinaryInvoiceUsedAmount='30'
where BillNumber='020507_20190101'
4 
--����
select DeptCode,DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptCode='�����з�����'
where DeptCode='������'
select DeptName,* from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з�����'
where ID='8'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з����� ϵͳ��ά��'
where ID='9'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з����� ���������'
where ID='10'
select * from ApproveBase..App_BaseDept 
--update ApproveBase..App_BaseDept set DeptName='�����з����� ���ά����'
where ID='11'

--��Ա��
select Department,* from ApproveBase..HR_Employee 
--update ApproveBase..HR_Employee set DeptCode='�����з�����',Department='�����з�����'
where DeptCode='������'

--��ٱ�

select * from ApproveBase..HR_AskForLeave_Signer 
---update ApproveBase..HR_AskForLeave_Signer set DeptCode='�����з�����'
where DeptCode='������'
	

--�������뵥�޸�
select pstatus,prdate,CommissionStatus,* from topway..tbDisctCommission 
--update topway..tbDisctCommission  set pstatus='0',prdate='1900-01-01',CommissionStatus='0'
where id='56170'

--���Ͳ���737MAX,���пⶼ��Ҫ����
select * from ehomsom..tbPlanetype  where aname='7MA'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('125','����','737ϵ��','737','7MA','150-180','խ��')

/*UC019333 2018�������
1��	����Ŀ���Ϊ׼������ÿһ����Ŀ������棬ÿ���µķ����Ƕ��٣���ȵ��ܷ����Ƕ��٣�
2��	�Ե�����ԱΪ׼������ÿһ��ÿ���µĻ�Ʊ�����Ƕ��٣�����ܼƶ��٣�
*/
--��Ŀ���
select convert(varchar(6),datetime,112) �·�,ProjectNo as ��Ŀ���,SUM(totprice) as '����(���ۼ�)' from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='019333' and reti=''
group by ProjectNo,datetime

--������Ա
select convert(varchar(6),datetime,112) �·�,pasname as �˿�����,SUM(totprice) as '����(���ۼ�)' from Topway..tbcash 
where datetime>='2018-01-01' and datetime<'2019-01-01' and cmpcode='019333' and reti=''
group by pasname,datetime

--��ҵ�����ר�ã����ν��㵥��Ӧ����Դ
select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤'
where TrvId='029347'

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤'
where TrvId='029305'

--�޸���������
select bpprice,* from Topway..tbcash 
--update Topway..tbcash set bpprice='30'
where coupno in('AS002139471','AS002155554')

select convert(varchar(6),ExamineDate,112) �·�,SUM(rtprice-profit-scount2) as ��Ʊ�� from Topway..tbReti 
where ExamineDate>='2018-01-01' and ExamineDate<'2019-01-01' and cmpcode='019333'   
AND NOT (totprice=0 AND ISNULL(operDep,'')='��Ʊ��Ʒ��')        
and status2 not in (1,3,4) --and len(cmpcode)=6        
and CASE WHEN coupno LIKE '000000%' OR coupno = 'AS000000000' OR trvYsId<>0 OR ConventionYsId<>0 THEN '' ELSE cmpcode END <>''
group by ExamineDate



--����Ԥ�㵥��Ϣ
select Sales,OperName,ModifyName,introducer,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Sales='��һ��',OperName='0656��һ��',ModifyName='0656��һ��',introducer='��һ��-0581-��Ӫ��'
where ConventionId='955'


--���ۼ���Ϣ
select totprice,disct,* from Topway..tbcash 
--update Topway..tbcash set totprice='1025',disct='500'
where coupno='AS002170978'
select totprice,disct,* from Topway..tbcash 
--update Topway..tbcash set totprice='1105',disct='500'
where coupno='AS002170984'
select totprice,disct,* from Topway..tbcash 
--update Topway..tbcash set totprice='1235',disct='500'
where coupno='AS002204136'

--�����տɾ��
delete
from Topway..tbTrvKhSk 
where TrvId='028950' and Id in('226697','226698')

/*
UC018309ʤ�ƣ��й���Ͷ�����޹�˾   ��2018��7��1������
������������ǳ���Ʊ���˵����Ƶꡢ��Ʊ������Ʊ�ĵص����Ϻ��йصģ������磺�Ϻ�-����|����-�Ϻ�|����-�Ϻ�|�Ϻ�-�����ȣ�
��Ʊ���Ϻ������͵����Ϻ������к��Ϻ�վ���Ϻ�����վ��
�Ƶ꣺�Ϻ��ľƵ�
*/
--��Ʊ
select OutBegdate as ��������,t.CoupNo as ���۵���,t1.Name as �˿�����,OutStroke as ��·,OutTrainNo as �г����,TotUnitprice as Ʊ��,t.TotPrice as ���ۼ�,TotFuprice as �����,
t1.ReturnTicketID as ��Ʊ����,CostCenter as �ɱ�����
 from Topway..tbTrainTicketInfo t
left join Topway..tbTrainUser t1 on t1.TrainTicketNo=t.ID
where OutBegdate>='2018-07-01' and OutStroke like'%�Ϻ�%' and CmpId='018309'
order by OutBegdate

--�Ƶ�Ԥ��
select prdate as Ԥ��ʱ��,hotel as �Ƶ�����,CityName as ����,price as ���ۼ�,yhprice as �Żݽ��,yf.nights*pcs as ��ҹ��,pasname as ��ס��
from tbHtlcoupYf yf
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=yf.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where prdate>='2018-07-01' 
and yf.status<>'-2' and CityName like'%�Ϻ�%' and yf.cmpid='018309'
order by prdate

--�Ƶ��Ը�
select datetime as Ԥ��ʱ��,hotel as �Ƶ�����,CityName as ����,price as ���ۼ�,'' as �Żݽ��,coup.nights*pcs as ��ҹ��,pasname as ��ס��
from tbHotelcoup coup
inner join HotelOrderDB..HTL_Orders od on od.CoupNo=coup.CoupNo
inner join HotelOrderDB..HTL_OrderHotels oh on oh.OrderID=od.OrderID
inner join Emppwd d on d.empname=opername1
where datetime>='2018-07-01' and CityName like'%�Ϻ�%' and coup.cmpid='018309'
and coup.status<>'-2'
order by datetime

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤'
where TrvId='029258'

--TW������30%�����뼼������

 
select Status,ModifyDate,* from topway..tbTravelBudget 
--update topway..tbTravelBudget set Status='14'
where trvid='28096'

/*�޸�UC��
ԭUC016448 ��UC016713 AS002220450 AS002204208 AS002202607 AS002202584 AS002192940 AS002192876 AS002181643 AS002181572
*/
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='016713'

select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='016713' and Type=0 and Status=1

select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from topway..tbcash 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016713' order by BillNumber desc

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,pform,* from topway..tbcash
--update tbcash set cmpcode='016713',OriginalBillNumber='016448_20181226',ModifyBillNumber='NULL',custid='�ֻ�Ա���',pform='�½�(�������))' 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

/*�޸�UC��
ԭUC016448 ��UC016713 AS002220450 AS002204208 AS002202607 AS002202584 AS002192940 AS002192876 AS002181643 AS002181572 �ɽ�
*/
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='016713'

select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='016713' and Type=0 and Status=1

select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from topway..tbcash 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

select HSLastPaymentDate,* from topway..AccountStatement where CompanyCode='016713' order by BillNumber desc

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,pform,* from topway..tbcash
--update tbcash set cmpcode='016713',OriginalBillNumber='016448_20181226',ModifyBillNumber='NULL',custid='D174912',pform='�½�(�������))' 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�����г̵�'
where coupno='AS002155795'

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002206933'

--�޸Ľ��㹩Ӧ����Դ
select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤)'
where TrvId='029305'

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤)'
where TrvId='029347'
/*�޸�UC��
ԭUC016448 ��UC016713 AS002220450 AS002204208 AS002202607 AS002202584 AS002192940 AS002192876 AS002181643 AS002181572 �ɽ�
*/
select custid AS �ֻ�Ա���,* from topway..tbCusholderM where cmpid ='016713'

select SettleMentManner AS �ֽ��㷽ʽ,* from topway..HM_SetCompanySettleMentManner where CmpId='016713' and Type=0 and Status=1

select OriginalBillNumber ,ModifyBillNumber,cmpcode,custid,datetime,* from topway..tbcash 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')

select BillNumber as ���˵��� ,* from topway..AccountStatement where CompanyCode='016713' order by BillNumber desc

select cmpcode,OriginalBillNumber,ModifyBillNumber,custid,pform,* from topway..tbcash
--update tbcash set cmpcode='016713',OriginalBillNumber='016713_20190101',ModifyBillNumber='NULL',custid='D174912',pform='�½�(�������))' 
where coupno in ('AS002220450','AS002204208','AS002202607','AS002202584','AS002192940','AS002192876', 'AS002181643','AS002181572')


--�г̵�������Ʊ��
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�����г̵�'
where coupno='AS002155795'

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002206933'

--�޸Ľ��㹩Ӧ����Դ
select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤)'
where TrvId='029305'

select GysSource from Topway..tbTrvJS 
--update Topway..tbTrvJS set GysSource='�Ϻ�˶����ã�ǩ֤)'
where TrvId='029347'
