--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='016344_20190601'

--销售单改成未付
select bpay,status,opernum,oper2,oth2,totprice,dzhxDate,owe,vpay,vpayinf,dzhxDate
--update Topway..tbcash set bpay=0,status=0,opernum=0,oper2='',owe=totprice,dzhxDate='1900-1-1'
from Topway..tbcash where coupno in ('AS002583160','AS002583321','AS002582581')

--插入连续票号
--select pasname,* from Topway..tbcash where coupno='AS002645860'
update Topway..tbcash set pasname='CHEN/WENNA MS',tcode='160',ticketno='2376003141' where coupno='AS002645860' and pasname='乘客0'
update Topway..tbcash set pasname='CHEN/YONGHAO MR',tcode='160',ticketno='2376003143' where coupno='AS002645860' and pasname='乘客1'
update Topway..tbcash set pasname='CHU/YUNYING MS',tcode='160',ticketno='2376003145' where coupno='AS002645860' and pasname='乘客2'
update Topway..tbcash set pasname='GAI/XUE MS',tcode='160',ticketno='2376003147' where coupno='AS002645860' and pasname='乘客3'
update Topway..tbcash set pasname='HUI/YIQING MS',tcode='160',ticketno='2376003149' where coupno='AS002645860' and pasname='乘客4'
update Topway..tbcash set pasname='JIANG/GUOCHUN MS',tcode='160',ticketno='2376003151' where coupno='AS002645860' and pasname='乘客5'
update Topway..tbcash set pasname='JIN/XIAOHAN MS',tcode='160',ticketno='2376003153' where coupno='AS002645860' and pasname='乘客6'
update Topway..tbcash set pasname='LI/CAIWEI MS',tcode='160',ticketno='2376003155' where coupno='AS002645860' and pasname='乘客7'
update Topway..tbcash set pasname='LIN/YIFEI MS',tcode='160',ticketno='2376003157' where coupno='AS002645860' and pasname='乘客8'
update Topway..tbcash set pasname='LIU/JIAYU MS',tcode='160',ticketno='2376003159' where coupno='AS002645860' and pasname='乘客9'
update Topway..tbcash set pasname='LIU/ZINING MS',tcode='160',ticketno='2376003161' where coupno='AS002645860' and pasname='乘客10'
update Topway..tbcash set pasname='OUYANG/YING MS',tcode='160',ticketno='2376003163' where coupno='AS002645860' and pasname='乘客11'
update Topway..tbcash set pasname='PAN/YU MS',tcode='160',ticketno='2376003165' where coupno='AS002645860' and pasname='乘客12'
update Topway..tbcash set pasname='QIAN/JINGYI MS',tcode='160',ticketno='2376003167' where coupno='AS002645860' and pasname='乘客13'
update Topway..tbcash set pasname='QIN/YUAN MS',tcode='160',ticketno='2376003169' where coupno='AS002645860' and pasname='乘客14'
update Topway..tbcash set pasname='XU/GUANHUA MR',tcode='160',ticketno='2376003171' where coupno='AS002645860' and pasname='乘客15'
update Topway..tbcash set pasname='ZHANG/YIJIE MS',tcode='160',ticketno='2376003173' where coupno='AS002645860' and pasname='乘客16'
update Topway..tbcash set pasname='ZHAO/KEXUAN MS',tcode='160',ticketno='2376003175' where coupno='AS002645860' and pasname='乘客17'
update Topway..tbcash set pasname='ZHENG/HANYUE MS',tcode='160',ticketno='2376003177' where coupno='AS002645860' and pasname='乘客18'
update Topway..tbcash set pasname='ZHENG/SHUANG MS',tcode='160',ticketno='2376003179' where coupno='AS002645860' and pasname='乘客19'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018482_20190501'

--单位客户授信额度调整
select SX_TotalCreditLine,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SX_TotalCreditLine='400000'
where BillNumber='019371_20190701'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set sales='汤凯杰',SpareTC='汤凯杰'
where coupno='AS001786721'

--修改退票状态
select status2,ModifyBillNumber,dzhxDate,* from Topway..tbReti 
--update Topway..tbReti  set status2=7,dzhxDate='2019-07-19'
where reno in('0345460')

select status2,ModifyBillNumber,dzhxDate,* from Topway..tbReti 
--update Topway..tbReti  set status2=7,dzhxDate='2019-07-19'
where reno in('0346696','0354732','0359999')

--旅游收款单作废
select Skstatus,* from Topway..tbTrvKhSk 
--update  Topway..tbTrvKhSk set Skstatus=2
where TrvId='30135' and Id='228361'

select Skstatus,* from Topway..tbTrvKhSk 
--update  Topway..tbTrvKhSk set Skstatus=2
where TrvId='30135' and Id='228094'

--重开打印
select PrintDate,Pstatus,* from topway..HM_tbReti_tbReFundPayMent 
--update topway..HM_tbReti_tbReFundPayMent  set PrintDate='1900-01-01',Pstatus=0
where Id='703884'

select PrintDate,Pstatus,* from topway..HM_tbReti_tbReFundPayMent 
--update topway..HM_tbReti_tbReFundPayMent  set PrintDate='1900-01-01',Pstatus=0
where Id='703881'

select id,COUNT(1)次数 from homsomDB..Trv_Cities group by id order by 次数 desc
select ID,Code,Name,EnglishName,AbbreviatedName from homsomDB..Trv_Cities where Code='SWA'
select * from homsomDB..Trv_Airport where CityID='23324672-8999-687B-C775-8636AFF3854D'
select * from homsomDB..Trv_Cities
--update homsomDB..Trv_Cities set EnglishName='Saratov' 
 where ID='3E6071F7-0C37-4876-8D2B-FFF1A292130E'
 
 select * from homsomDB..Trv_Airport
 --update homsomDB..Trv_Airport 
where CityID='5F28B699-AF9E-48D5-B020-093488D7F055'
 
update homsomDB..Trv_Airport set EnglishName='Ijui' where CityID='D28A3926-9200-4BDD-996E-00BD081D88E0'
update homsomDB..Trv_Airport set EnglishName='Guantanamo' where CityID='5F28B699-AF9E-48D5-B020-093488D7F055'
update homsomDB..Trv_Airport set EnglishName='Breckenridge' where CityID='7FC8B901-7045-48B7-9EDA-0BA81B5BCF1C'
update homsomDB..Trv_Airport set EnglishName='Marsh Harbour' where CityID='D432AA23-8DFE-486B-A0B4-0E92616CDCD7'
update homsomDB..Trv_Airport set EnglishName='Mardel Plata' where CityID='832B1AC0-ABD9-4070-943B-2182EA6C3EEF'
update homsomDB..Trv_Airport set EnglishName='Coatesville' where CityID='95BFFF86-EC0A-4C1D-AD5D-29DFCAAD3507'


--UC020350

select COUNT(1)出票张数
from Topway..tbcash 
where cmpcode='020350'
and datetime>='2019-07-13'
and inf=1
and reti=''
and tickettype='电子票'
and route not like '%改期%' 
and route not like '%升舱%'

select COUNT(1)退票张数
from Topway..tbcash 
where cmpcode='020350'
and datetime>='2019-07-13'
and inf=1
and reti<>''
and tickettype='电子票'
and route not like '%改期%' 
and route not like '%升舱%'

select COUNT(1)改期张数
from Topway..tbcash 
where cmpcode='020350'
and datetime>='2019-07-13'
and inf=1
and (tickettype like'%改期%' or tickettype like'%升舱%'
or route not like '%改期%' or route not like '%升舱%')

select COUNT(1) 酒店预订次数 from Topway..tbHtlcoupYf
where cmpid='020350'
and prdate>='2019-07-13'



