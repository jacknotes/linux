--����֧����ʽ���Ը����渶��
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,* from homsomDB..Trv_TktBookings
--update homsomDB..Trv_TktBookings set TCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,CustomerPayDate=null
where ID in (select b.ItktBookingID from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber in('AS002610600'))
--��Ʊ֧����Ϣ
select PayNo,TCPayNo,PayStatus,AdvanceStatus,CustomerPayWay,TcPayWay,CustomerPayDate,TcPayDate,dzhxDate,status,owe,vpay,vpayinf,* from Topway..tbcash 
--update Topway..tbcash set TCPayNoTCPayNo=PayNo,PayNo=null,AdvanceStatus=PayStatus,PayStatus=0,TcPayWay=CustomerPayWay,CustomerPayWay=0,TcPayDate=CustomerPayDate,dzhxDate=TcPayDate,CustomerPayDate=null,status=0,owe=totprice,vpay=0,vpayinf=''
where coupno in('AS002610600')

select payperson,* from topway..PayDetail
--update  topway..PayDetail set payperson=2 
where ysid in (select cast(b.ItktBookingID as varchar(40)) from homsomDB..Trv_DomesticTicketRecord as a left join homsomDB..Trv_PnrInfos as b on a.PnrInfoID=b.ID 
where a.RecordNumber='AS002610600')


/*
���ҿ���016448���ʻ�Ʊ��������ֻҪ������˰��
2017.07.01-2018.06.30
2018.07.01-2019.06.30

��Ҫ�˵���ϸ
*/
select sum(��������˰-isnull(��Ʊ��,0)) ��������˰ from (
select SUM(price) ��������˰,reti from Topway..tbcash 
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1
group by reti) t1
left join (
select SUM(totprice) ��Ʊ��,reno from Topway..tbReti
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1
group by reno
)  t2 on t1.reti=t2.reno

--2017.07.01-2018.06.30��ϸ
select convert(varchar(10),datetime,120) ��Ʊ����,convert(varchar(20),begdate,120) �������,coupno ���۵���,pasname �˻���,case when tickettype like '%����%' or tickettype like '%����%' then '��������'
when route like '%����%' or route like '%����%' then '��������' when reti<>'' then '��Ʊ' else tickettype end ҵ������,
route �г�,tcode+ticketno Ʊ��,ride+flightno �����,'--' ȫ��,'--' �ۿ���,price ���۵���,tax ˰��,totprice ���ۼ�,Department ����,isnull(CostCenter,'') �ɱ�����,DATEDIFF(DD,datetime,begdate)��ǰ��Ʊ����,
reti ��Ʊ����,nclass ��λ����,'--' ԭ��,'--' Э���Ż�,xfprice ��Ӷ���
from Topway..tbcash 
where cmpcode='016448'
and datetime>='2018-07-01'
and datetime<'2019-07-01'
and inf=1
order by ��Ʊ����

select reno,totprice from Topway..tbReti
where reno in(select reti from Topway..tbcash 
where cmpcode='016448'
and datetime>='2017-07-01'
and datetime<'2018-07-01'
and inf=1)


--����Ʒר�ã����ս������Ϣ
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=2.2,totsprice=2.2
where coupno in ('AS002595748','AS002595754','AS002595770','AS002595808',
'AS002595818','AS002608060','AS002623545','AS002623495') 

select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash  set sprice1=3.3,totsprice=3.3
where coupno in ('AS002596784','AS002596788','AS002596787',
'AS002597236','AS002598858','AS002599210','AS002599211',
'AS002602272','AS002602274','AS002602842','AS002604463',
'AS002607748','AS002608529','AS002612027','AS002612030',
'AS002612031','AS002612028','AS002612029','AS002614919',
'AS002616929','AS002617366','AS002618637','AS002621045',
'AS002621352','AS002621330','AS002620070','AS002624200',
'AS002624201','AS002624204','AS002624210','AS002625985',
'AS002627886','AS002627887','AS002628783','AS002629627',
'AS002629631','AS002631451','AS002631699','AS002631700',
'AS002632094','AS002633594','AS002633602') 

--����۽�λ
select totsprice,profit,* from Topway..tbcash
--update Topway..tbcash set totsprice=totsprice+1,profit=profit-1
where coupno in('AS002629146','AS002630524','AS002633527')

--����Ԥ�㵥��Ϣ
select Custid,Custinfo,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Custinfo='13916023939@�ƴ��t@UC@@�ƴ��t@13916023939@D183010'
where TrvId='29993'

--�޸�ע����UC020444
select indate,depdate0,* from Topway..tbCompanyM 
--update Topway..tbCompanyM  set indate='2019-07-15'
where cmpid='020444'

select RegisterMonth,AdditionMonthA,* from homsomDB..Trv_UnitCompanies 
--update homsomDB..Trv_UnitCompanies  set RegisterMonth='07 15 2019 11:58AM'
where Cmpid='020444'

--���������պ����ͱ��� ��λ��ϸ�� UC����λ���ơ�TC����Ӫ����
select top 100 * from homsomDB..Trv_UCSettings

select 'UC'+u.Cmpid UC ,u.Name ��λ����,ss.Name TC,h.MaintainName ��Ӫ����,
case when BindAccidentIntInsurance in('20','22') then '�󶨹��ʱ���' when IsFreeIntInsurance=1 then '���͹��ʱ���'  else '' end ����
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_UCSettings s on u.UCSettingID=s.ID
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=u.Cmpid and MaintainType=9 and h.IsDisplay=1
left join homsomDB..SSO_Users ss on ss.ID=t.TktTCID
where isnull(BindAccidentIntInsurance,'')<>''
or s.IsFreeIntInsurance=1
and CooperativeStatus in('1','2','3')
order by ��Ӫ����