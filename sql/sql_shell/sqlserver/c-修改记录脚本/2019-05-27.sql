--UC020758和铂医药从恒顺这里出具的机票（公务舱与经济舱）明细，我们想做一下费用比较和分析，如果将公务舱改为经济舱，费用可以节省多少

select coupno,datetime,route,c.begdate,t.cabintype,tickettype,ride,nclass,totprice
from Topway..tbcash c with (nolock)
left join ehomsom..tbInfCabincode t on t.cabin=c.nclass and t.code2=c.ride
and [datetime]>=t.begdate and [datetime]<=t.enddate
and ((c.begdate>=flightbegdate and c.begdate<=flightenddate) or
(c.begdate>=flightbegdate2 and c.begdate<=flightenddate2) or 
(c.begdate>=flightbegdate3 and c.begdate<=flightenddate3) or 
(c.begdate>=flightbegdate4 and c.begdate<=flightenddate4))
where  cmpcode='020758'
and isnull(cabintype,'')=''
order by datetime



--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash set info3='需打印行程单'
where coupno='AS002495360'

select * from Topway..tbFiveCoupInfo where CoupNo='AS002504121'

select convert(varchar(10),HolidayDate,120) 日期, case when HolidayName like'%星期%' then '3' else '4' end 日期类型,HolidayName 节假名称 from Topway..T_HolidayDate
where HolidayDate>='2019-05-01'
order by 日期

--修改出票状态
select status,* from Topway..tbFiveCoupInfo where CoupNo='AS002504121'

--修改退票审核日期
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-05-06'
where reno='9267033'

--重开打印
select Prdate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Prdate='1900-01-01',Pstatus=0
where TrvId='29805'

--（产品专用）申请费来源/金额信息
select feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='申请座位ZYI'
where coupno='AS002496616'

select feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash set feiyonginfo='申请座位ZYI'
where coupno='AS002493359'

--修改单位注册月
select indate,* from Topway..tbCompanyM 
--update  Topway..tbCompanyM set indate='2019-05-27'
where cmpid='019707'

select RegisterMonth,* from homsomDB..Trv_UnitCompanies 
update homsomDB..Trv_UnitCompanies  set RegisterMonth='05 27 2019 10:36AM'
where Cmpid='019707'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=11269,profit=2277
where coupno='AS002500136'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=7967,profit='-1'
where coupno='AS002496127'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set  totsprice=8731,profit='966'
where coupno='AS002500775'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019658_20190301'

--（产品部专用）机票供应商来源
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='垫付殷招行I'
where coupno='AS002501509'

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='垫付临时信用卡I'
where coupno='AS002501508'


--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set  sales='黄怡丽',SpareTC='黄怡丽'
where coupno='AS001655480'

select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set  sales='汤凯杰',SpareTC='汤凯杰'
where coupno='AS001661426'





