--�г̵�
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='���ӡ�г̵�'
where coupno='AS002234920'

--��λ�ͻ����Ŷ�ȵ���
SELECT SX_BaseCreditLine,SX_TomporaryCreditLine, SX_TotalCreditLine FROM Topway..AccountStatement
--update Topway..AccountStatement set SX_TotalCreditLine='80000'
WHERE CompanyCode='016278' and BillNumber='016278_20190101'

--�޸�UC�ţ���Ʊ���������۵��ţ�AS002217693 ��Ʊ���ڣ�2019-1-19 ���ۼۣ�3890Ԫ ԭUC�ţ�UC017735 ��UC�ţ�UC016888 ������Ϣ����
select cmpcode,OriginalBillNumber,ModifyBillNumber,pform,totprice,custid,datetime,* from Topway..tbcash 
--update Topway..tbcash set cmpcode='016888',OriginalBillNumber='016888_20190126',custid='D172032'
where coupno='AS002217693'

select custid AS �ֻ�Ա���,* from tbCusholderM where cmpid ='016888' 
select SettleMentManner AS �ֽ��㷽ʽ,* from HM_SetCompanySettleMentManner where CmpId='016888' and Type=0 and Status=1
select OriginalBillNumber AS ���˵���,ModifyBillNumber AS ���˵���,cmpcode,custid,datetime,* from tbcash where coupno in ('AS002217693')
select HSLastPaymentDate,* from AccountStatement where CompanyCode='016888' order by BillNumber desc

--��˾
SELECT top 10 * FROM ehomsom..tbInfAirCompany where code2='TO'
INSERT INTO ehomsom..tbInfAirCompany (ID,airname,sx1,sx,code2,http,ntype,modifyDate,enairname,sortNo) values (400,'������պ���','��պ���','��պ���','TO','www.Transavia.com','1','2019-01-30','Transavia France','1')
insert INTO ehomsom..tbInfAirCompany (airname ,
          sx1 ,
          sx ,
          code2 ,
          http ,
          ntype ,
          modifyDate ,
          enairname ,
          IsDeleted ,
          sortNo ,
          phone1 ,
          phone2 ,
          introinf
        )
values('������պ���','��պ���','��պ���','TO','www.Transavia.com','1','2019-01-30','Transavia France',NULL,'1',NULL,NULL,NULL)

--��14��
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno='��,��,��,��,��,��,��,��,��,��,��,��,��,��',MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='14',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��',Pasname='�˿�1,�˿�2,�˿�3,�˿�4,�˿�5,�˿�6,�˿�7,�˿�8,�˿�9,�˿�10,�˿�11,�˿�12,�˿�13,�˿�14',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002235342')

--������
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='23500',profit='7814'
where coupno='AS002234254'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice='4392',profit='191'
where coupno='AS002235066'

--�����ȡ1/29���ù�����ӵĳ����ÿ�����

SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
h.Mobile AS �ֻ�����,
ISNULL((SELECT TOP 1 empname FROM Topway..Emppwd WHERE idnumber=h.CreateBy),'') AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-01-29' AND h.CreateDate<'2019-01-30' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT idnumber FROM Topway..Emppwd WHERE dep='��Ӫ��' AND idnumber NOT IN('00002','00003','0421'))
UNION ALL

SELECT 
ISNULL(c.Cmpid,'') AS ��λ���,
ISNULL(c.Name,'') AS ��λ����,
ISNULL(h.Name,'') AS ������,
ISNULL((h.LastName+'/'+h.FirstName+' '+h.MiddleName),'')  AS Ӣ����,
ISNULL(h.Mobile,'') AS �ֻ�����,
h.CreateBy AS ���ù���,
ISNULL((SELECT TOP 1 MaintainName FROM Topway..HM_ThePreservationOfHumanInformation WHERE MaintainType=9 AND IsDisplay=1 AND c.Cmpid=CmpId),'') AS ��Ӫ����
FROM homsomDB..Trv_Human h 
LEFT JOIN homsomDB..Trv_UnitPersons u ON u.ID = h.ID
LEFT JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID 
WHERE h.CreateDate>='2019-01-29' AND h.CreateDate<'2019-01-30' AND h.IsDisplay=1
AND h.CreateBy IN(SELECT empname FROM Topway..Emppwd WHERE dep='��Ӫ��' AND empname NOT IN('homsom','��˳����','��Ӫ��ѵ����'))

--��ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set Pstatus='0',PrDate='1900-01-01'
where TrvId='29519' and Id='226898'

--�Ϻ�����
select CostCenter,priceinfo,* from Topway..tbcash where cmpcode='019358' and datetime>='2018-01-01' and datetime<'2019-01-01' and inf=1  and priceinfo>'0'

 --�Ϻ�����2018����
 select t.datetime as ��Ʊ����,t.begdate as �������,t.coupno as ���۵���,t.pasname as �˿�����,t.route as ��·,t.ride+t.flightno as �����,t2.airname as ���չ�˾,t.tcode+t.ticketno as Ʊ��,(case t.priceinfo when '0' then t.price else priceinfo end) as ȫ��,
(case t.priceinfo when '0' then '1' else t.price/t.priceinfo end) as �ۿ���, t.price as ���۵���,t.tax as ˰��,t.fuprice as �����,t.totprice as ���ۼ�,t.reti as ��Ʊ����,t.CostCenter as �ɱ�����,t1.rtprice as ��Ʊ��,
(Select c.totprice from Topway..tbcash c where c.coupno=t.coupno and c.ticketno=t.ticketno and (c.route like'%����%' or c.tickettype like'%����%') and c.cmpcode='019358' and c.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201')) as �������շ�
  ,t.nclass as ��λ����
  from Topway..tbcash t
  left join Topway..tbReti t1 on t1.reno=t.reti
  left join ehomsom..tbInfAirCompany t2 on t2.code2=t.ride
 where t.ModifyBillNumber in('019358_20180101','019358_20180201','019358_20180301','019358_20180401','019358_20180501','019358_20180601','019358_20180701','019358_20180801','019358_20180901','019358_20181001','019358_20181101','019358_20181201') 
 and t.cmpcode='019358' and t.inf=1  
 order by t.ModifyBillNumber
 
 --�ɱ�����
 select DISTINCT pasname,CostCenter from Topway..tbcash where cmpcode='019358' and CostCenter is not null and CostCenter<>'undefined'
 
 
 
 --����Ʊ��
 select pasname,* from Topway..tbcash where coupno='AS002235779'
 update topway..tbcash set pasname='CHEN/WENXIN',tcode='781',ticketno='2318173779' where coupno in ('AS002235342') and pasname='�˿�1'
update topway..tbcash set pasname='DAI/RUIQI',tcode='781',ticketno='2318173780' where coupno in ('AS002235342') and pasname='�˿�2'
update topway..tbcash set pasname='FU/ZIRAN',tcode='781',ticketno='2318173781' where coupno in ('AS002235342') and pasname='�˿�3'
update topway..tbcash set pasname='HU/HAIYING',tcode='781',ticketno='2318173782' where coupno in ('AS002235342') and pasname='�˿�4'
update topway..tbcash set pasname='LAN/PU',tcode='781',ticketno='2318173783' where coupno in ('AS002235342') and pasname='�˿�5'
update topway..tbcash set pasname='LI/HANBO',tcode='781',ticketno='2318173784' where coupno in ('AS002235342') and pasname='�˿�6'
update topway..tbcash set pasname='SUN/YANXUN',tcode='781',ticketno='2318173785' where coupno in ('AS002235342') and pasname='�˿�7'
update topway..tbcash set pasname='TANG/MIAOMIAO',tcode='781',ticketno='2318173786' where coupno in ('AS002235342') and pasname='�˿�8'
update topway..tbcash set pasname='WANG/SHUNI',tcode='781',ticketno='2318173787' where coupno in ('AS002235342') and pasname='�˿�9'
update topway..tbcash set pasname='WANG/YAOZHEN',tcode='781',ticketno='2318173788' where coupno in ('AS002235342') and pasname='�˿�10'
update topway..tbcash set pasname='WENG/ZHENZHEN',tcode='781',ticketno='2318173789' where coupno in ('AS002235342') and pasname='�˿�11'
update topway..tbcash set pasname='XU/JIAHUI',tcode='781',ticketno='2318173790' where coupno in ('AS002235342') and pasname='�˿�12'
update topway..tbcash set pasname='ZHAO/RUIJING',tcode='781',ticketno='2318173791' where coupno in ('AS002235342') and pasname='�˿�13'
update topway..tbcash set pasname='ZHAO/WENJUN',tcode='781',ticketno='2318173792' where coupno in ('AS002235342') and pasname='�˿�14'
update topway..tbcash set pasname='WANG/SHUNI',tcode='781',ticketno='2318463163' where coupno in ('AS002235779') and pasname='HE/ZHENZHEN'

--���㵥��Ϣ
select settleStatus,* from topway..tbSettlementApp
 --update topway..tbSettlementApp set settleStatus='3' 
 where id='108510'
select wstatus,settleno,* from topway..tbcash
--update topway..tbcash set wstatus='0',settleno='0' 
where settleno='108510'
select inf2,settleno,* from Topway..tbReti
--update topway..tbReti set inf2='0',settleno='0' 
where settleno='108510'
select Status,* from Topway..Tab_WF_Instance
--update topway..Tab_WF_Instance set Status='4' 
where BusinessID='108510'

delete from  topway..Tab_WF_Instance_Node where InstanceID in (select id from topway..Tab_WF_Instance where BusinessID='108510') and Status='0'

