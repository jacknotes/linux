--�ึ�����Ʊ�������뵥�޸�/����
select IsEnable,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set IsEnable=0
where Id='51649'

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='����',SpareTC='����'
where coupno='AS002592779'

--�޸�UC�ţ���Ʊ��
--select * from Topway..tbcash where cmpcode='020561' and datetime>'2019-06-01'

select custid,cmpcode,ModifyBillNumber,OriginalBillNumber,pform,* from Topway..tbcash 
--update Topway..tbcash  set custid='D607658',cmpcode='020561',ModifyBillNumber='020561_20190601',OriginalBillNumber='020561_20190601',pform='�½�(����)'
where coupno='AS002523046'

--�޸�˰��
select stax,tax,totsprice,totprice,owe,amount,* from Topway..tbcash 
--update Topway..tbcash  set stax=tax
where coupno='AS002591854'

select stax,tax,totsprice,totprice,owe,amount,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=250
where coupno='AS002591854'

--�ึ�����Ʊ�������뵥�޸�
select Remarks,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set Remarks='AS002479818�ึ��7690'
where Id='51648'


--�ึ��޸Ľ��
select Total,TotalB,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set Total=7690,TotalB='��Ǫ½�۾�ʰԪ'
where Id='51648'


--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Ա���渶���������п���'
where CoupNo='PTW085700'

--�ؿ���ӡ
select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30139' and Id='228615'

select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30058' and Id='228464'

--���۵����11��
 select * from topway..tbFiveCoupInfosub
--update topway..tbFiveCoupInfosub set MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='11',Department='��,��,��,��,��,��,��,��,��,��,��' 
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002599744')

--�ؿ���ӡ
select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30139' and Id='228615'

select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,Prdate='1900-01-01'
where TrvId='30219' and Id='228618'


--�Ƶ�REASON CODE��Ԥ���ˣ�����Ŀ��

select  h.CoupNo as ���۵���,Purpose as ����Ŀ��,m.custname,ReasonDescription  FROM [HotelOrderDB].[dbo].[HTL_Orders] h
left join Topway..tbHtlcoupYf t on t.CoupNo=h.CoupNo
left join Topway..tbCusholderM m on m.custid=t.custid 
where h.CoupNo in ('PTW083934',
'PTW084009',
'PTW084063',
'-PTW083934',
'PTW084265',
'PTW084698',
'PTW084714',
'PTW084759',
'PTW084799',
'PTW085064',
'PTW085704',
'PTW085706',
'PTW085708',
'PTW085709')

--��Ʊ���۵�ƥ��REASON CODE��Ԥ���ˣ�����Ŀ��
select coupno,isnull(UnChoosedReason,'') REASONCODE,m.custname Ԥ����,isnull(Purpose,'')����Ŀ��  from Topway..tbcash c
left join homsomDB..Trv_DomesticTicketRecord d on d.RecordNumber=c.coupno
left join homsomDB..Trv_ItktBookingSegments_PnrInfos t on d.PnrInfoID=t.PnrInfoID
left join homsomDB..Trv_LowerstPrices l on l.ItktBookingSegID=t.ItktBookingSegID
left join Topway..tbCusholderM m on m.custid=c.custid
where coupno in ('AS002530836',
'AS002530955',
'AS002530958',
'AS002531256',
'AS002531262',
'AS002533754',
'AS002539359',
'AS002541969',
'AS002541969',
'AS002547206',
'AS002549493',
'AS002549493',
'AS002549493',
'AS002554628',
'AS002554972',
'AS002556067',
'AS002556886',
'AS002556888',
'AS002563109',
'AS002563109',
'AS002564536',
'AS002567897',
'AS002569252',
'AS002569252',
'AS002570239',
'AS002571884',
'AS002572745',
'AS002583350',
'AS002583352',
'AS002583965',
'AS002593327',
'AS002593327',
'AS002593327',
'AS002593344',
'AS002593344',
'AS002593345',
'AS002593388',
'AS002593388',
'AS002593433',
'AS002593568',
'AS002593571',
'AS002593573',
'AS002593576',
'AS002512694',
'AS002512710',
'AS002512944')

--�Ƶ����۵���Ӧ����Դ
select profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Ա���渶���������п���'
where CoupNo='PTW085700'

--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='009005_20190501'

--�Ƶ����۵��ؿ���ӡȨ��
select prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set prdate='2019-06-30'
where CoupNo in('PTW085733','PTW085749')

--�Ƶ����۵���Ӧ����Դ
select profitsource ��Ӧ����Դ,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set profitsource='Ա���渶���������п���'
where CoupNo='PTW085844'

--�����տ��Ϣ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus=0,PrDate='1900-01-01'
where TrvId='30369'

--�����տ��Ϣ
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30396'

select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='30139' and Id='228616'


--�ึ��ؿ���ӡ
select PrintTime,CustDate,CustId,CustStat,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment  set PrintTime='1900-01-01',CustDate='1900-01-01',CustId='',CustStat=''
where Id='51648'

--��Ʊ��
--update Topway..tbcash set pasname='',tcode='781',ticketno='' where coupno='AS002599744' and pasname=''
update Topway..tbcash set pasname='DU/JING',tcode='781',ticketno='2401216167' where coupno='AS002599744' and pasname='�˿�0'
update Topway..tbcash set pasname='FANG/YAO',tcode='781',ticketno='2401216168' where coupno='AS002599744' and pasname='�˿�1'
update Topway..tbcash set pasname='GUO/LONG',tcode='781',ticketno='2401216169' where coupno='AS002599744' and pasname='�˿�2'
update Topway..tbcash set pasname='HAN/CHAOWEI',tcode='781',ticketno='2401216170' where coupno='AS002599744' and pasname='�˿�3'
update Topway..tbcash set pasname='LIU/LINLING',tcode='781',ticketno='2401216171' where coupno='AS002599744' and pasname='�˿�4'
update Topway..tbcash set pasname='LIU/RUOXI',tcode='781',ticketno='2401216172' where coupno='AS002599744' and pasname='�˿�5'
update Topway..tbcash set pasname='LU/QIANG',tcode='781',ticketno='2401216173' where coupno='AS002599744' and pasname='�˿�6'
update Topway..tbcash set pasname='QIN/MEI',tcode='781',ticketno='2401216174' where coupno='AS002599744' and pasname='�˿�7'
update Topway..tbcash set pasname='TANG/GUANGZHI',tcode='781',ticketno='2401216175' where coupno='AS002599744' and pasname='�˿�8'
update Topway..tbcash set pasname='WANG/ZHENG',tcode='781',ticketno='2401216176' where coupno='AS002599744' and pasname='�˿�9'
update Topway..tbcash set pasname='ZHANG/BO',tcode='781',ticketno='2401216177' where coupno='AS002599744' and pasname='�˿�10'

--���ɿ����� ���ݲ������˸ģ�˰��
--�з�Ӷ
select * from 
(select cmpcode UC��,u.Name ��λ����,SUM(price) ����,SUM(xfprice) ��Ӷ��� from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice<>0
and cmpcode in('020665')
group by cmpcode,u.Name) t1
left join
--�޷�Ӷ
(select cmpcode UC��,u.Name ��λ����,SUM(price) ���� from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and cmpcode in('020665')
group by cmpcode,u.Name)t2 on t1.UC��=t2.UC��
left join 
(select cmpcode UC��,u.Name ��λ����,SUM(price) MUUFJY�յ����� from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='MU'
and nclass in('U','F','J','Y')
and cmpcode in('020665')
group by cmpcode,u.Name)t3 on t1.UC��=t3.UC��
left join

(select cmpcode UC��,u.Name ��λ����,SUM(price) MU������λ���� from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='MU'
and nclass not in('U','F','J','Y')
and cmpcode in('020665')
group by cmpcode,u.Name) t4 on t1.UC��=t4.UC��
left join 

(select cmpcode UC��,u.Name ��λ����,SUM(price) CZ���� from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='cz'
and cmpcode in('020665')
group by cmpcode,u.Name) t5 on t1.UC��=t5.UC��
left join 
(select cmpcode UC��,u.Name ��λ����,SUM(price) HO���� from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=0
and reti=''
and tickettype='����Ʊ'
and xfprice=0
and ride='ho'
and cmpcode in('020665')
group by cmpcode,u.Name) t6 on t1.UC��=t6.UC��

select cmpcode UC��,u.Name ��λ����,SUM(price) HO����,SUM(xfprice) from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies u on u.Cmpid=c.cmpcode
where datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
and reti=''
and tickettype='����Ʊ'
and xfprice<>0
and cmpcode in('020665')
group by cmpcode,u.Name

--UC018308ɾ��Ա��
select IsDisplay,* from homsomDB..Trv_Human 
--update homsomDB..Trv_Human  set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons 
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='018308'))
and Name in('���⣨��ְ��','����ٻ����ְ��','���ף���ְ��')

select EmployeeStatus,* from Topway..tbCusholderM
--update Topway..tbCusholderM set EmployeeStatus=0
where cmpid='018308'
and custname  in('���⣨��ְ��','����ٻ����ְ��','���ף���ְ��')

--UC018308ɾ��Ա����ɫȨ��
select UPRoleID,* from homsomDB..Trv_UnitPersons 
--update homsomDB..Trv_UnitPersons  set UPRoleID=null
where CompanyID=(Select ID from homsomDB..Trv_UnitCompanies 
where Cmpid='018308')
and ID in('B1C1AC34-1F98-402E-A2F7-A6DC0122BB62','8FABCE0E-EAC3-4D47-BA3E-A9E500C9C9C9','48DD1488-79EA-4F15-A1D0-A91100BB7DAA')

-- 020278 ŷʿ����Ҫ��ȡ2019�������⼮�ÿ͵Ĺ��ʻ�Ʊ��Ϣ
select coupno ���۵���,convert(varchar(10),datetime,120) ��Ʊ����,begdate �������,pasname �˻���,idno ֤����,route �г�
,price ���۵���,totprice ���ۼ�,tcode+ticketno  Ʊ��,tickettype ����
from Topway..tbcash 
where cmpcode='020278'
and begdate>='2019-01-01'
and inf=1
order by �������


--�Ƶ����۵��ؿ���ӡȨ��
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set pstatus=0,prdate='1900-01-01'
where CoupNo='-PTW083551'

select DETR_RP,sales,SpareTC,* from Topway..tbcash where DETR_RP in('5098452430','5098452429')

/*
��Ӧ����Դ��HSBSPETD ��Ʊ������ڣ�2019-06-01��2019-06-30
��λ��F/A/J/C/D/Z/R/G/Y/W/S/T/L/P/N/K
�أ�Ʊ�š����۵��š���Ӧ����Դ����Ʊ���š��ύ���ڡ�������ڡ�Ʊ��ۡ����չ�˾��Ʊ�ѡ��տͻ���Ʊ����Ʊ����ҵ����ʡ���Ʊҵ����ʡ��ύ��Ʊҵ����ʡ���ע
*/
select distinct tcode+c.ticketno Ʊ��,t.coupno ���۵���,t_source ��Ӧ����Դ,reno ��Ʊ����,edatetime �ύ����,ExamineDate �������,sprice1+sprice2+sprice3+sprice4 Ʊ���,
 scount2 ���չ�˾��Ʊ��,rtprice �տͻ���Ʊ���,SpareTC ��Ʊ����ҵ�����,sales ��Ʊҵ�����,opername �ύ��Ʊҵ�����,t.info ��ע,nclass
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno and c.coupno=t.coupno
where ExamineDate>='2019-06-01'
and ExamineDate<'2019-07-01'
and t_source='HSBSPETD'
and nclass in('F','A','J','C','D','Z','R','G','Y','W','S','T','L','P','N','K')
and t.ride='ca'
order by �ύ����

--����۲��
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=totsprice+1,profit=profit-1
where coupno ='AS002598386'

--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETD'
where coupno in('AS002583747','AS002583754','AS002583777','AS002590002')

select t_source,* from Topway..tbcash 
--update Topway..tbcash  set t_source='HSBSPETI'
where coupno in('AS002585166','AS002584496','AS002584528','AS002585316','AS002579241')

--�����ȡ�������ݣ�ע��2019��1��1��ǰע��ĵ�λ�ͻ�Ϊ�Ͽͻ���  ά���˵�λ���ݷ���
select u.cmpid uc��,u.cmpname ��λ����,isnull(s.Name,'')ά����,indate ע��,un.Type ���� from Topway..tbCompanyM u
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=u.cmpid
left join homsomDB..Trv_UnitCompanies_KeyAccountManagers k on k.UnitCompanyID=un.ID
left join homsomDB..SSO_Users s on s.ID=k.EmployeeID
where hztype in ('1','2','3')
and s.Name is not null



/*
��Ӧ����Դ��HSBSPETD ��Ʊ������ڣ�2019-06-01��2019-06-30
��λ��F/A/J/C/D/Z/R/G/Y/W/S/T/L/P/N/K
����ţ�CA��ͷ
�أ�Ʊ�š����۵��š���Ӧ����Դ����Ʊ���š��ύ���ڡ�������ڡ�Ʊ��ۡ����չ�˾��Ʊ�ѡ��տͻ���Ʊ����Ʊ����ҵ����ʡ���Ʊҵ����ʡ��ύ��Ʊҵ����ʡ���ע
�ٰ����������º����µģ��ֿ���
��λ��Ҫ��������Ŷ*/
select distinct tcode+c.ticketno Ʊ��,t.coupno ���۵���,t_source ��Ӧ����Դ,reno ��Ʊ����,edatetime �ύ����,ExamineDate �������,sprice1+sprice2+sprice3+sprice4 Ʊ���,
 scount2 ���չ�˾��Ʊ��,rtprice �տͻ���Ʊ���,SpareTC ��Ʊ����ҵ�����,sales ��Ʊҵ�����,opername �ύ��Ʊҵ�����,t.info ��ע,nclass
from Topway..tbReti t
left join Topway..tbcash c on c.reti=t.reno and c.coupno=t.coupno
where ExamineDate>='2019-05-01'
and ExamineDate<'2019-06-01'
and t_source='HSBSPETD'
and nclass in('F','A','J','C','D','Z','R','G','Y','W','S','T','L','P','N','K')
and t.ride='ca'
order by �ύ����


--�޸ľƵ����۵�����
select ModifyBillNumber,OriginalBillNumber,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set OriginalBillNumber='017674_20190601'
where CoupNo='PTW085733'

select ModifyBillNumber,OriginalBillNumber,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set OriginalBillNumber='020552_20190601'
where CoupNo='PTW085749'