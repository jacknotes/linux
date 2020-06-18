--能否拉一下UC020432（佳能光学）下在homsomDB..trv_human与topway..tbcusthoderM中存在差异的常旅客数据

if OBJECT_ID('tempdb..#hom')is not null drop table #hom
SELECT CustID,cr.CredentialNo,h.Mobile 
into #hom
FROM homsomDB..Trv_Human h
left join homsomDB..Trv_UnitPersons u on u.ID=h.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=u.CompanyID
LEFT join homsomDB..Trv_Credentials cr on cr.HumanID=h.ID
where Cmpid='020432' and IsDisplay=1

if OBJECT_ID('tempdb..#top') is not null drop table #top
select custid,idno,mobilephone 
into #top
from Topway..tbCusholderM 
where EmployeeStatus<>0 and cmpid='020432'

select h.custid homsomdbID,isnull(h.CredentialNo,'') homsomdb证件,h.Mobile homsomdb手机,isnull(t.custid,'') topwayID ,
isnull(idno,'')topway证件,isnull(mobilephone,'')topway手机
from #hom h 
left join #top t on t.custid=h.custid
order by homsomdbID


--机票审批人
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002421018',
'AS002421026',
'AS002421045',
'AS002421095',
'AS002423071',
'AS002423927',
'AS002423971',
'AS002424331',
'AS002424698',
'AS002426031',
'AS002426918',
'AS002427391',
'AS002427442',
'AS002427444',
'AS002427620',
'AS002427926',
'AS002428409',
'AS002428444',
'AS002429073',
'AS002429466',
'AS002429957',
'AS002429985',
'AS002430576',
'AS002439830',
'AS002439832',
'AS002441254',
'AS002441256',
'AS002441593',
'AS002441926',
'AS002449164',
'AS002449165',
'AS002449183',
'AS002449184',
'AS002449185',
'AS002452676',
'AS002452678',
'AS002455663',
'AS002455851',
'AS002455959',
'AS002455976',
'AS002456255',
'AS002456260',
'AS002456315',
'AS002456317',
'AS002456321',
'AS002456329',
'AS002456331',
'AS002456333',
'AS002456337',
'AS002456341',
'AS002456348',
'AS002456358',
'AS002456360',
'AS002456362',
'AS002457589',
'AS002458389',
'AS002458393',
'AS002458730',
'AS002459782',
'AS002459888',
'AS002460012',
'AS002460779',
'AS002460781',
'AS002460785',
'AS002460787',
'AS002460791',
'AS002460793',
'AS002460795',
'AS002460803',
'AS002460812',
'AS002461218',
'AS002462006',
'AS002462171',
'AS002462425',
'AS002462428',
'AS002462435',
'AS002462871',
'AS002466273',
'AS002470640',
'AS002470733',
'AS002471009',
'AS002474967',
'AS002477398',
'AS002477791',
'AS002480270',
'AS002482406',
'AS002482633',
'AS002483330',
'AS002485130',
'AS002485223',
'AS002487916') and NodeType=110 and NodeID=111

--一级 NodeType=110 and NodeID=110
--二级 NodeType=110 and NodeID=111

--航司两舱及Y舱2018年度统计分析
--总数据
select ride,SUM(totprice)销量,SUM(profit)-sum(Mcost)利润,COUNT(1)张数
from Topway..tbcash 
where inf=0
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='电子票'
group by ride
order by 销量 desc

--Y舱
select ride,SUM(totprice)销量,SUM(profit)-sum(Mcost)利润,COUNT(1)张数
from Topway..tbcash 
where inf=0
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and tickettype='电子票'
and nclass='Y'
group by ride
order by 销量 desc


select ride  航司,SUM(c.totprice) 销量,SUM(c.profit)-sum(Mcost) 利润,COUNT(1) 张数
from Topway..tbcash c with (nolock)
inner join ehomsom..tbInfCabincode t on t.cabin=c.nclass and t.code2=c.ride
and datetime>=t.begdate and datetime<=t.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or 
(c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or 
(c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or 
(c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=0
and tickettype='电子票'
and (t.cabintype like'%头等%' or t.cabintype like'%公务%')
group by ride
order by 销量 desc


/*
   1、业务类型：国际
     2、承运人及舱位：见附件
     3、供应商来源：不限
     4、出票日期：2018年1月1日-2018年12月31日
     5、扣除退票
*/
--CA
select (case  when nclass in ('F','A') then '头等舱' when nclass in ('J','C','D','Z','R') then '公务舱' when nclass in ('G','E') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='ca'
group by (case  when nclass in ('F','A') then '头等舱' when nclass in ('J','C','D','Z','R') then '公务舱' 
when nclass in ('G','E') then '超经舱' else '经济舱' end)
order by 销量 desc

--MU
select (case  when nclass in ('P','F','A') then '头等舱' when nclass in ('U','J','C','D','Q','I')  then '公务舱' when nclass in ('W') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='MU'
group by (case  when nclass in ('P','F','A') then '头等舱' when nclass in ('U','J','C','D','Q','I')  then '公务舱' when nclass in ('W') 
then '超经舱' else '经济舱' end)
order by 销量 desc

--FM
select (case  when nclass in ('P','F','A') then '头等舱' when nclass in ('U','J','C','D','Q','I')  then '公务舱' when nclass in ('W') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='FM'
group by (case  when nclass in ('P','F','A') then '头等舱' when nclass in ('U','J','C','D','Q','I')  then '公务舱' when nclass in ('W') 
then '超经舱' else '经济舱' end)
order by 销量 desc

--CZ
select (case  when nclass in ('F','A') then '头等舱' when nclass in ('J','D','R','I')  then '公务舱' when nclass in ('W','P') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='CZ'
group by (case  when nclass in ('F','A') then '头等舱' when nclass in ('J','D','R','I')  then '公务舱' when nclass in ('W','P') then '超经舱' else '经济舱' end)
order by 销量 desc

--hu
select (case   when nclass in ('C','D','Z','I')  then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='hu'
group by (case   when nclass in ('C','D','Z','I')  then '公务舱'  else '经济舱' end)
order by 销量 desc

--ho
select (case  when nclass in ('F') then '头等舱' when nclass in ('C','J','D','R','I')  then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='ho'
group by (case  when nclass in ('F') then '头等舱' when nclass in ('C','J','D','R','I')  then '公务舱'  else '经济舱' end)
order by 销量 desc

--AF
select (case  when nclass in ('P','F') then '头等舱' when nclass in ('J','C','D','I','Z','O')  then '公务舱' when nclass in ('W','S','A') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AF'
group by (case  when nclass in ('P','F') then '头等舱' when nclass in ('J','C','D','I','Z','O')  then '公务舱' when nclass in ('W','S','A') then '超经舱' else '经济舱' end)
order by 销量 desc

--AA
select (case   when nclass in ('J','D','R','I') then '公务舱' when nclass in ('W','P') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AA'
group by (case   when nclass in ('J','D','R','I') then '公务舱' when nclass in ('W','P') then '超经舱' else '经济舱' end)
order by 销量 desc

--AY
select (case   when nclass in ('J','D','R','I') then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AY'
group by (case   when nclass in ('J','D','R','I') then '公务舱' else '经济舱' end)
order by 销量 desc

--AC
select (case   when nclass in ('J','C','D','Z','P') then '公务舱' when nclass in ('O','E','N') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='AC'
group by (case   when nclass in ('J','C','D','Z','P') then '公务舱' when nclass in ('O','E','N') then '超经舱'  else '经济舱' end)
order by 销量 desc

--BA
select (case when nclass in ('F','A') then '头等舱'  when nclass in ('J','C','D','R','I') then '公务舱' when nclass in ('W','E','T') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='BA'
group by (case when nclass in ('F','A') then '头等舱'  when nclass in ('J','C','D','R','I') then '公务舱' when nclass in ('W','E','T') then '超经舱'  else '经济舱' end)
order by 销量 desc


--BR
select (case  when nclass in ('J','C','D') then '公务舱' when nclass in ('K','L','T','P') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='BR'
group by (case  when nclass in ('J','C','D') then '公务舱' when nclass in ('K','L','T','P') then '超经舱'  else '经济舱' end)
order by 销量 desc

--CI
select (case  when nclass in ('J','C','D') then '公务舱' when nclass in ('W','U','A','E') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='CI'
group by (case  when nclass in ('J','C','D') then '公务舱' when nclass in ('W','U','A','E') then '超经舱'  else '经济舱' end)
order by 销量 desc

--CX
select (case when nclass in ('F') then '头等舱' when nclass in ('J','C','D','I') then '公务舱' when nclass in ('W','R','E') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='CX'
group by (case when nclass in ('F') then '头等舱' when nclass in ('J','C','D','I') then '公务舱' when nclass in ('W','R','E') then '超经舱'  else '经济舱' end)
order by 销量 desc

--DL
select (case  when nclass in ('J','C','D','I','Z') then '公务舱' when nclass in ('P','A','G') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='DL'
group by (case  when nclass in ('J','C','D','I','Z') then '公务舱' when nclass in ('P','A','G') then '超经舱'  else '经济舱' end)
order by 销量 desc

--EK
select (case when nclass in ('F','A') then '头等舱' when nclass in ('J','C','O','I') then '公务舱'   else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='EK'
group by (case when nclass in ('F','A') then '头等舱' when nclass in ('J','C','O','I') then '公务舱'   else '经济舱' end)
order by 销量 desc

--JL
select (case  when nclass in ('D','C','X','I') then '公务舱'   else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='JL'
group by (case  when nclass in ('D','C','X','I') then '公务舱'   else '经济舱' end)
order by 销量 desc

--KA
select (case when nclass in ('F') then '头等舱' when nclass in ('D','C','J','I') then '公务舱'  when nclass in ('W','R','E') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='KA'
group by (case when nclass in ('F') then '头等舱' when nclass in ('D','C','J','I') then '公务舱'  when nclass in ('W','R','E') then '超经舱'  else '经济舱' end)
order by 销量 desc

--KE
select (case when nclass in ('F','P') then '头等舱' when nclass in ('D','C','J','I') then '公务舱'    else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='KE'
group by (case when nclass in ('F','P') then '头等舱' when nclass in ('D','C','J','I') then '公务舱'    else '经济舱' end)
order by 销量 desc

--KL
select (case  when nclass in ('D','C','J','I','Z','O') then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='KL'
group by (case  when nclass in ('D','C','J','I','Z','O') then '公务舱'   else '经济舱' end)
order by 销量 desc

--LH
select (case when nclass in ('F','A') then '头等舱'  when nclass in ('D','C','J','Z','P') then '公务舱' when nclass in ('G','E','N') then '超经舱' else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='LH'
group by (case when nclass in ('F','A') then '头等舱'  when nclass in ('D','C','J','Z','P') then '公务舱' when nclass in ('G','E','N') then '超经舱' else '经济舱' end)
order by 销量 desc

--NH
select (case   when nclass in ('D','G','Z','P') then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='NH'
group by (case   when nclass in ('D','G','Z','P') then '公务舱'  else '经济舱' end)
order by 销量 desc

--OZ
select (case when nclass in ('F','A') then '头等舱'  when nclass in ('D','J','Z','C','U') then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='OZ'
group by (case when nclass in ('F','A') then '头等舱'  when nclass in ('D','J','Z','C','U') then '公务舱'  else '经济舱' end)
order by 销量 desc

--TK
select (case   when nclass in ('D','J','Z','C','K') then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='TK'
group by (case   when nclass in ('D','J','Z','C','K') then '公务舱'  else '经济舱' end)
order by 销量 desc

--TG
select (case   when nclass in ('D','J','C') then '公务舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='TG'
group by (case   when nclass in ('D','J','C') then '公务舱'  else '经济舱' end)
order by 销量 desc


--SQ
select (case  when nclass in ('F','A') then '头等舱' when nclass in ('D','J','C','Z','U') then '公务舱' when nclass in ('S','T','P','R') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='SQ'
group by (case  when nclass in ('F','A') then '头等舱' when nclass in ('D','J','C','Z','U') then '公务舱' when nclass in ('S','T','P','R') then '超经舱'  else '经济舱' end)
order by 销量 desc

--SU
select (case   when nclass in ('D','J','C','Z','I') then '公务舱' when nclass in ('S','W','A') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='SU'
group by (case   when nclass in ('D','J','C','Z','I') then '公务舱' when nclass in ('S','W','A') then '超经舱'  else '经济舱' end)
order by 销量 desc

--UA
select (case   when nclass in ('D','J','C','Z','P') then '公务舱' when nclass in ('O','R','A') then '超经舱'  else '经济舱' end) 舱位,
COUNT(1)张数,SUM(totprice)销量,SUM(profit)利润,SUM(Mcost)资金费用 
from Topway..tbcash 
where datetime>='2018-01-01'
and datetime<'2019-01-01'
and inf=1
and reti=''
and ride='UA'
group by (case   when nclass in ('D','J','C','Z','P') then '公务舱' when nclass in ('O','R','A') then '超经舱'  else '经济舱' end)
order by 销量 desc

--根据销售单号匹配预订人，差旅目的，REASONXCODE

select o.CoupNo,h.Name,isnull(Purpose,'')差旅目的,isnull(ReasonDescription,'')REASONXCODE
from HotelOrderDB..HTL_Orders o
left join Topway..tbHtlcoupYf y on y.CoupNo=o.CoupNo
left join homsomDB..Trv_UnitPersons u on u.CustID=y.custid
left join homsomDB..Trv_Human h on h.ID=u.ID
where o.CoupNo in('PTW081681',
'PTW081971',
'PTW082030',
'PTW082121',
'PTW082251',
'PTW082367',
'PTW082449',
'PTW082448',
'PTW082447',
'PTW082439',
'PTW082539',
'PTW082659',
'PTW082640')

--旅游预算单
select TrvId 预算单号,SUM(YujPrice) 预计价格销量 FROM Topway..tbTravelBudget 
where OperDate>='2018-01-01'
and OperDate<'2019-05-01'
--and  having SUM(YujPrice)>1000000
 group by TrvId
 order by 预计价格销量 desc
 
 --改票号
 select * from Topway..tbcash 
 --update Topway..tbcash  set tcode='205',ticketno='2412644415'
 where coupno='AS002327279'
 
 --行程单、特殊票价
 select info3,* from Topway..tbcash 
 --update Topway..tbcash set info3='需打印行程单'
 where coupno='AS002408952'
 
  select info3,* from Topway..tbcash 
 --update Topway..tbcash set info3='需打印行程单'
 where coupno in('AS002452095','AS002478435','AS002453772','AS002453778')
 
 --火车票销售价信息
 select TotPrice,TotFuprice,TotPrintPrice,* from Topway..tbTrainTicketInfo 
 --update Topway..tbTrainTicketInfo  set TotPrice='58.50',TotFuprice=0,TotPrintPrice=0
 where CoupNo='RS000023812'
 
 select Fuprice,PrintPrice,* from Topway..tbTrainUser 
 --update Topway..tbTrainUser set Fuprice=0,PrintPrice=0
 where TrainTicketNo=(Select ID from Topway..tbTrainTicketInfo where CoupNo='RS000023812')
 
 --财务到账改成未认领
 select state,* from Topway..FinanceERP_ClientBankRealIncomeDetail 
 --update Topway..FinanceERP_ClientBankRealIncomeDetail set state=5
 where money='264601' and date='2019-05-21'
 
 select  Payee, * from Topway..AccountStatementItem 
 --update Topway..AccountStatementItem set Payee=''
 where FinanceERP_ClientBankRealIncomeDetail_id='4877F1E4-8EB8-44B1-B0D5-CA6DA3AA6A20'
 
 select * from Topway..AccountStatement
 update Topway..AccountStatement set SX_TotalCreditLine='50000' where BillNumber='000006_20190501'