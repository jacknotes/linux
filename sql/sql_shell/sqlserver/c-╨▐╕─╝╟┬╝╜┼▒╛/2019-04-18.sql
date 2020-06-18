select coupno 销售单号,indate 出票日期,begdate 起飞日期, route 航线,ride 航司代码,totprice 销售价,profit 利润,sales 差旅顾问,e.team 所属小组,
(case tickettype when '电子票' then '' when '改期费' then '改期费' when '升舱费' then '升舱费' else '' end)  是否有改期,reti 退票单号
,t_source 供应商来源
from Topway..tbcash c
left join Topway..Emppwd e on e.empname=c.sales
where t_source='平台蜗牛D'
order by indate

select * from Topway..Emppwd

--重开打印
select pstatus,prdate,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set pstatus=0,prdate='1900-01-01'
where CoupNo='PTW080416'

--更新原票号
select oldrecno,OldTicketNo,* from Topway..tbcash where coupno='AS002395621'

--退票审核日期
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti set ExamineDate='2019-04-17'
where reno='0432441'

--票号
update Topway..tbcash  set pasname = REPLACE(pasname,' ','') where coupno in('AS002406146','AS002406007')
--select pasname,tcode,ticketno,* from Topway..tbcash where coupno='AS002406146' and pasname='祁 昂'
update Topway..tbcash set tcode='479',ticketno='2131679204' where pasname='蔡晨成' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679205' where pasname='陈辉东' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679206' where pasname='陈睿' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679207' where pasname='单雯' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679208' where pasname='丁俊阳' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679209' where pasname='顾骏' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679210' where pasname='郭婷' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679211' where pasname='季蔼勤' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679212' where pasname='吕佳庆' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679213' where pasname='施夏明' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679214' where pasname='孙晶' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679215' where pasname='孙伊君' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679216' where pasname='唐沁' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679217' where pasname='陶一春' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679218' where pasname='吴婷蓉' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679219' where pasname='严文君' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679220' where pasname='张静芝' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679221' where pasname='张书雯' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679222' where pasname='朱虹' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679223' where pasname='朱贤哲' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679240' where pasname='陈浩' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679241' where pasname='陈铸' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679242' where pasname='戴敬平' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679243' where pasname='丁航' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679244' where pasname='高博' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679245' where pasname='刘佳' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679246' where pasname='刘思华' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679247' where pasname='刘嫣然' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679248' where pasname='李翔' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679249' where pasname='缪向明' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679250' where pasname='倪峥' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679251' where pasname='潘中琦' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679252' where pasname='祁昂' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679253' where pasname='唐颖' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679254' where pasname='王旭东' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679255' where pasname='肖亚君' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679256' where pasname='许玲莉' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679257' where pasname='姚琦' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679258' where pasname='姚小风' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679259' where pasname='尹梅' and coupno='AS002406146'
update Topway..tbcash set tcode='479',ticketno='2131679260' where pasname='张瑶' and coupno='AS002406146'


--select pasname,tcode,ticketno,* from Topway..tbcash where coupno='AS002406007'

update Topway..tbcash set tcode='479',ticketno='2131679261' where pasname='包正明' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679262' where pasname='曹友顺' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679263' where pasname='畅鸣宇' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679264' where pasname='杜磊' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679265' where pasname='郭云峰' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679266' where pasname='郭智瑄' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679267' where pasname='洪亮' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679268' where pasname='侯大俊' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679269' where pasname='吕金春' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679270' where pasname='邵伟奇' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679271' where pasname='石善明' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679272' where pasname='邰卓佳' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679273' where pasname='王志夫' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679274' where pasname='王中青' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679275' where pasname='岳瑞红' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679276' where pasname='赵于涛' and coupno='AS002406007'
update Topway..tbcash set tcode='479',ticketno='2131679277' where pasname='庄培成' and coupno='AS002406007'



select IsJoinRank,* from Topway..Emppwd 
--update Topway..Emppwd  set IsJoinRank=0
where idnumber='0709'

--退票审核日期
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-04-12'
where reno='0432508'
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-04-17'
where reno='0432507'

--2018年1月1日至今所有国际机票出票明细  
--姓名 出票日期 起飞日期 航程 价格  航班号 票号 销售总价 结算总价
select cmpcode UC,pasname 姓名,indate 出票日期,begdate 起飞日期,route 航程,price 销售单价,ride+flightno 航班号,
tcode+ticketno 票号,totprice 销售总价,totsprice 结算总价
from Topway..tbcash 
where inf=1
and cmpcode in('017692','017690','017691','017694','019767','019768','017693')
and datetime>='2018-01-01'
order by cmpcode

select ID from homsomDB..Trv_Cities where Code in ('BGG')
select ID from homsomDB..Trv_Cities where Code in ('GNI')
select ID from homsomDB..Trv_Cities where Code in ('JNS')
select ID from homsomDB..Trv_Cities where Code in ('AAD')
select ID from homsomDB..Trv_Cities where Code in ('SIC')
select ID from homsomDB..Trv_Cities where Code in ('KEW')
select ID from homsomDB..Trv_Cities where Code in ('KCK')
select ID from homsomDB..Trv_Cities where Code in ('NAH')
select ID from homsomDB..Trv_Cities where Code in ('ETE')
select ID from homsomDB..Trv_Cities where Code in ('SSS') --删除
select ID from homsomDB..Trv_Cities where Code in ('BEM')
select ID from homsomDB..Trv_Cities where Code in ('CAT')
select * from homsomDB..Trv_Airport where CityID in(select ID from homsomDB..Trv_Cities where Code='SSS')


select * from homsomDB..Trv_Cities

select c.Code,a.Code,c.Name,a.Name,a.EnglishName, CountryCode from homsomDB..Trv_Cities c
left join homsomDB..Trv_Airport a on a.CityID=c.ID
where c.Code in ('BGG','GNI','JNS','AAD','SIC','KEW','KCK','NAH','ETE','BEM','CAT')


--删除多余城市
select * from homsomDB..Trv_Airport where CityID='C4376314-AB67-4159-A67C-D025E62A9DD7'
select * 
--delete
from homsomDB..Trv_Cities where Code='SSS'

--旅游结算单信息
select * 
--delete
from Topway..tbTrvJS where TrvId='29892' and Id='144931'

select status,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set status=-2
where CoupNo='PTW080656'



--撤销闭团
select * 
--delete
from Topway..tbTrvCoup where TrvId='11563'

select Status,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget  set Status='12'
where TrvId='11563'

--修改预算单号
--select * from Topway..tbTravelBudget where TrvId='29887'
select * from Topway..tbTrvJS 
--update Topway..tbTrvJS  set TrvId='29887'
where TrvId='11563' and Id in 
(select  trvYsId from Topway..tbcash where coupno in
('AS002395386','AS002395442','AS002395900','AS002395909','AS002395935','AS002395941'))




--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='章志强',SpareTC='章志强'
where coupno ='AS001760572'

--结算价差额
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=4317,profit='-90'
where coupno='AS002407364'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=7102,profit='1545'
where coupno='AS002400172' and id='4290681'

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5763,profit='1495'
where coupno='AS002402361' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=5763,profit='1495'
where coupno='AS002403620' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=14119,profit='874'
where coupno='AS002399257' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=13629,profit='864'
where coupno='AS002399287' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=24333,profit='567'
where coupno='AS002402852' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=24333,profit='567'
where coupno='AS002402862' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=8499,profit='687'
where coupno='AS002406266' 

select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2154,profit='142'
where coupno='AS002408690' 


--单位特殊线路中设置了S舱，98折的单位数据
select distinct un.Cmpid UC,un.Name 单位名称,(100-f1.Discount)*0.01 折扣,FlightEndDate  from homsomDB..Trv_FlightAdvancedPolicies f1
left join homsomDB..Trv_FlightAdvancedPolicyItems f2 on f2.FlightAdvancedPolicyID=f1.ID
left join homsomDB..Trv_UnitCompanies un on un.ID=f1.UnitCompanyID
where f2.Cabin like '%S%'
and f1.Discount=2
order by FlightEndDate

