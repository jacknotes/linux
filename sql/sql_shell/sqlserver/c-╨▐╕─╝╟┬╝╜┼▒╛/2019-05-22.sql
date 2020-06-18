--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='018353_20190401'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020278_20190401'

--匹配附件中销售单对应的数据
select * from Topway..HM_Reimbursementvouchers

select coupno,price,tax,totprice,totsprice,tickettype,isnull(RV_Cnname,'无')特殊票价,profit 
from Topway..tbcash c
left join Topway..HM_Reimbursementvouchers h on h.RV_id=c.baoxiaopz
where coupno in ('AS002377817',
'AS002378920',
'AS002378980',
'AS002379843',
'AS002380008',
'AS002382672',
'AS002384224',
'AS002384295',
'AS002385978',
'AS002386370',
'AS002399432',
'AS002362015',
'AS002365788',
'AS002365788',
'AS002367029',
'AS002367032',
'AS002371015',
'AS002374989',
'AS002375027',
'AS002375138',
'AS002386382',
'AS002389882')

--旅游预算单信息

SELECT Cmpid,Custinfo,CustomerType,* FROM Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Cmpid='',Custinfo='13621687168@臧超@UC020687@@臧超@13621687168@D629573',CustomerType='个人客户'
where TrvId='29637'

--机票业务顾问信息
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash  set SpareTC='周婧'
where coupno='AS002463265'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019808_20190401'

--匹配差旅目的
select coupno,Purpose from Topway..tbcash
where coupno in('AS002289528',
'AS002270665',
'AS002301748',
'AS002301750',
'AS002294879',
'AS002294881',
'AS002298672',
'AS002308465',
'AS002280474',
'AS002280466',
'AS002312349',
'AS002312370',
'AS002320281',
'AS002320283',
'AS002342748',
'AS002342757',
'AS002284689',
'AS002338010',
'AS002345773',
'AS002351136',
'AS002283257',
'AS002283264',
'AS002307693',
'AS002307697',
'AS002355952',
'AS002355957',
'AS002307495',
'AS002307503',
'AS002307507',
'AS002307540',
'AS002335997',
'AS002336037',
'AS002300190',
'AS002300192',
'AS002338829',
'AS002338831',
'AS002313988',
'AS002314006',
'AS002283139',
'AS002284486',
'AS002284625',
'AS002314034',
'AS002338049',
'AS002313117',
'AS002344099',
'AS002345259',
'AS002345746',
'AS002347271',
'AS002347387',
'AS002300505',
'AS002303523',
'AS002359399',
'AS002361721',
'AS002313042',
'AS002335817',
'AS002346989',
'AS002346999',
'AS002331552',
'AS002331556',
'AS002309416',
'AS002309418',
'AS002331544',
'AS002331548',
'AS002312551',
'AS002343609',
'AS002347361',
'AS002300507',
'AS002303529',
'AS002346276',
'AS002344068',
'AS002344072',
'AS002297462',
'AS002309329',
'AS002343485',
'AS002343489',
'AS002287476',
'AS002287492',
'AS002290493',
'AS002290497',
'AS002306935',
'AS002306937',
'AS002333280',
'AS002333287',
'AS002289528',
'AS002302512',
'AS002302514',
'AS002323417',
'AS002326363',
'AS002331690',
'AS002340787',
'AS002342869',
'AS002342871',
'AS002354166',
'AS002354168',
'AS002354201',
'AS002355925',
'AS002244861',
'AS002270665',
'AS002356545',
'AS002356549',
'AS002346343',
'AS002360398',
'AS002346343',
'AS002355019',
'AS002342226',
'AS002356535',
'AS002360569',
'AS002360593',
'AS002353197',
'AS002353205',
'AS002358773',
'AS002358775',
'AS002353249',
'AS002360398',
'AS002314417',
'AS002319814',
'AS002288414',
'AS002288418',
'AS002314417',
'AS002319811',
'AS002292829',
'AS002307182',
'AS002307186')

select coupno,Purpose from Topway..tbcash
where coupno in('AS002426510',
'AS002426510',
'AS002369747',
'AS002404729',
'AS002439895',
'AS002426512',
'AS002426516',
'AS002439899',
'AS002439901',
'AS002369749',
'AS002391977',
'AS002439897',
'AS002391599',
'AS002398249',
'AS002426512',
'AS002426516',
'AS002438516',
'AS002438518',
'AS002362930',
'AS002362934',
'AS002373636',
'AS002384621',
'AS002384627',
'AS002400274',
'AS002400280',
'AS002401146',
'AS002401153',
'AS002420568',
'AS002429988',
'AS002430017',
'AS002435203',
'AS002435205',
'AS002373807',
'AS002373819',
'AS002411744',
'AS002411748',
'AS002435751',
'AS002435763',
'AS002365070',
'AS002365072',
'AS002382056',
'AS002382065',
'AS002421367',
'AS002421369',
'AS002436403',
'AS002436405',
'AS002364641',
'AS002364651',
'AS002374768',
'AS002374771',
'AS002415968',
'AS002415970',
'AS002417075',
'AS002417161',
'AS002417181',
'AS002424054',
'AS002424056',
'AS002368148',
'AS002368150',
'AS002384920',
'AS002384926',
'AS002364400',
'AS002364402',
'AS002366937',
'AS002380592',
'AS002365139',
'AS002361721',
'AS002436692',
'AS002415546',
'AS002415549',
'AS002380597',
'AS002392548',
'AS002412372',
'AS002412374',
'AS002380689',
'AS002386131',
'AS002388907',
'AS002389266',
'AS002389844',
'AS002388893',
'AS002389264',
'AS002389846',
'AS002435280',
'AS002435744',
'AS002391712',
'AS002391714',
'AS002411900',
'AS002436451',
'AS002436453',
'AS002374297',
'AS002374309',
'AS002435280',
'AS002435744',
'AS002381091',
'AS002381868',
'AS002405371',
'AS002416242',
'AS002416244',
'AS002373779',
'AS002373787',
'AS002411781',
'AS002411783',
'AS002435267',
'AS002435269',
'AS002380585',
'AS002385943',
'AS002368479',
'AS002413454',
'AS002424660',
'AS002437913',
'AS002437915',
'AS002378693',
'AS002378695',
'AS002365024',
'AS002365026',
'AS002384699',
'AS002392767',
'AS002362001',
'AS002362003',
'AS002380237',
'AS002385842',
'AS002408888',
'AS002408890',
'AS002411374',
'AS002413189',
'AS002389032',
'AS002393908',
'AS002373767',
'AS002373769',
'AS002384697',
'AS002390790',
'AS002435866',
'AS002435868',
'AS002361866',
'AS002361868',
'AS002423770',
'AS002423772')

--机型
--select * from ehomsom..tbPlanetype
update ehomsom..tbPlanetype set ltype=aname where aname='319'
update ehomsom..tbPlanetype set ltype=aname where aname='320'
update ehomsom..tbPlanetype set ltype=aname where aname='321'
update ehomsom..tbPlanetype set ltype=aname where aname='330'
update ehomsom..tbPlanetype set ltype=aname where aname='332'
update ehomsom..tbPlanetype set ltype=aname where aname='333'
update ehomsom..tbPlanetype set ltype=aname where aname='340'
update ehomsom..tbPlanetype set ltype=aname where aname='733'
update ehomsom..tbPlanetype set ltype=aname where aname='734'
update ehomsom..tbPlanetype set ltype=aname where aname='737'
update ehomsom..tbPlanetype set ltype=aname where aname='738'
update ehomsom..tbPlanetype set ltype=aname where aname='744'
update ehomsom..tbPlanetype set ltype=aname where aname='747'
update ehomsom..tbPlanetype set ltype=aname where aname='757'
update ehomsom..tbPlanetype set ltype=aname where aname='763'
update ehomsom..tbPlanetype set ltype=aname where aname='767'
update ehomsom..tbPlanetype set ltype=aname where aname='772'
update ehomsom..tbPlanetype set ltype=aname where aname='777'
update ehomsom..tbPlanetype set ltype=aname where aname='739'
update ehomsom..tbPlanetype set ltype=aname where aname='73G'
update ehomsom..tbPlanetype set ltype=aname where aname='73E'
update ehomsom..tbPlanetype set ltype=aname where aname='AB6'
update ehomsom..tbPlanetype set ltype=aname where aname='343'
update ehomsom..tbPlanetype set ltype=aname where aname='75B'
update ehomsom..tbPlanetype set ltype=aname where aname='76A'
update ehomsom..tbPlanetype set ltype=aname where aname='CRJ'
update ehomsom..tbPlanetype set ltype=aname where aname='CR2'
update ehomsom..tbPlanetype set ltype=aname where aname='75A'
update ehomsom..tbPlanetype set ltype=aname where aname='76B'
update ehomsom..tbPlanetype set ltype=aname where aname='773'
update ehomsom..tbPlanetype set ltype=aname where aname='73H'
update ehomsom..tbPlanetype set ltype=aname where aname='325'
update ehomsom..tbPlanetype set ltype=aname where aname='33A'
update ehomsom..tbPlanetype set ltype=aname where aname='77S'
update ehomsom..tbPlanetype set ltype=aname where aname='787'
update ehomsom..tbPlanetype set ltype=aname where aname='300'
update ehomsom..tbPlanetype set ltype=aname where aname='33E'
update ehomsom..tbPlanetype set ltype=aname where aname='77L'
update ehomsom..tbPlanetype set ltype=aname where aname='346'
update ehomsom..tbPlanetype set ltype=aname where aname='73C'
update ehomsom..tbPlanetype set ltype=aname where aname='789'
update ehomsom..tbPlanetype set ltype=aname where aname='73L'
update ehomsom..tbPlanetype set ltype=aname where aname='73V'
update ehomsom..tbPlanetype set ltype=aname where aname='32A'
update ehomsom..tbPlanetype set ltype=aname where aname='78A'
update ehomsom..tbPlanetype set ltype=aname where aname='73K'
update ehomsom..tbPlanetype set ltype=aname where aname='33L'
update ehomsom..tbPlanetype set ltype=aname where aname='77B'
update ehomsom..tbPlanetype set ltype=aname where aname='323'
update ehomsom..tbPlanetype set ltype=aname where aname='77A'
update ehomsom..tbPlanetype set ltype=aname where aname='75C'
update ehomsom..tbPlanetype set ltype=aname where aname='32L'
update ehomsom..tbPlanetype set ltype=aname where aname='77W'
update ehomsom..tbPlanetype set ltype=aname where aname='350'
update ehomsom..tbPlanetype set ltype=aname where aname='32B'
update ehomsom..tbPlanetype set ltype=aname where aname='32Z'
update ehomsom..tbPlanetype set ltype=aname where aname='3NE'
update ehomsom..tbPlanetype set ltype=aname where aname='322'
update ehomsom..tbPlanetype set ltype=aname where aname='31Z'
update ehomsom..tbPlanetype set ltype=aname where aname='7LX'
update ehomsom..tbPlanetype set ltype=aname where aname='32H'
update ehomsom..tbPlanetype set ltype=aname where aname='31A'
update ehomsom..tbPlanetype set ltype=aname where aname='33N'
update ehomsom..tbPlanetype set ltype=aname where aname='31E'
update ehomsom..tbPlanetype set ltype=aname where aname='B738'
update ehomsom..tbPlanetype set ltype=aname where aname='A320'
update ehomsom..tbPlanetype set ltype=aname where aname='A320_186'
update ehomsom..tbPlanetype set ltype=aname where aname='JET100'
update ehomsom..tbPlanetype set ltype=aname where aname='73R'
update ehomsom..tbPlanetype set ltype=aname where aname='32Y'
update ehomsom..tbPlanetype set ltype=aname where aname='32M'
update ehomsom..tbPlanetype set ltype=aname where aname='32G'
update ehomsom..tbPlanetype set ltype=aname where aname='730'
update ehomsom..tbPlanetype set ltype=aname where aname='7HH'
update ehomsom..tbPlanetype set ltype=aname where aname='32R'
update ehomsom..tbPlanetype set ltype=aname where aname='7MA'
update ehomsom..tbPlanetype set ltype=aname where aname='78B'
update ehomsom..tbPlanetype set ltype=aname where aname='33C'
update ehomsom..tbPlanetype set ltype=aname where aname='73M'
update ehomsom..tbPlanetype set ltype=aname where aname='32C'
update ehomsom..tbPlanetype set ltype=aname where aname='338'
update ehomsom..tbPlanetype set ltype=aname where aname='73N'
update ehomsom..tbPlanetype set ltype=aname where aname='73T'
update ehomsom..tbPlanetype set ltype=aname where aname='33B'
update ehomsom..tbPlanetype set ltype=aname where aname='32F'
update ehomsom..tbPlanetype set ltype=aname where aname='337'
update ehomsom..tbPlanetype set ltype=aname where aname='33W'
update ehomsom..tbPlanetype set ltype=aname where aname='78W'
update ehomsom..tbPlanetype set ltype=aname where aname='33H'
update ehomsom..tbPlanetype set ltype=aname where aname='73D'
update ehomsom..tbPlanetype set ltype=aname where aname='195'
update ehomsom..tbPlanetype set ltype=aname where aname='7M8'
update ehomsom..tbPlanetype set ltype=aname where aname='32D'
update ehomsom..tbPlanetype set ltype=aname where aname='73S'
update ehomsom..tbPlanetype set ltype=aname where aname='ARJ'
update ehomsom..tbPlanetype set ltype=aname where aname='735'
update ehomsom..tbPlanetype set ltype=aname where aname='190'
update ehomsom..tbPlanetype set ltype=aname where aname='33G'
update ehomsom..tbPlanetype set ltype=aname where aname='32N'
update ehomsom..tbPlanetype set ltype=aname where aname='331'
update ehomsom..tbPlanetype set ltype=aname where aname='CR9'
update ehomsom..tbPlanetype set ltype=aname where aname='32E'
update ehomsom..tbPlanetype set ltype=aname where aname='359'
update ehomsom..tbPlanetype set ltype=aname where aname='73F'
update ehomsom..tbPlanetype set ltype=aname where aname='33D'
update ehomsom..tbPlanetype set ltype=aname where aname='336'
update ehomsom..tbPlanetype set ltype=aname where aname='73U'
update ehomsom..tbPlanetype set ltype=aname where aname='32U'
update ehomsom..tbPlanetype set ltype=aname where aname='380'
update ehomsom..tbPlanetype set ltype=aname where aname='E90'
update ehomsom..tbPlanetype set ltype=aname where aname='788'
update ehomsom..tbPlanetype set ltype=aname where aname='31G'
update ehomsom..tbPlanetype set ltype=aname where aname='31C'
update ehomsom..tbPlanetype set ltype=aname where aname='32J'
update ehomsom..tbPlanetype set ltype=aname where aname='73B'
update ehomsom..tbPlanetype set ltype=aname where aname='736'
update ehomsom..tbPlanetype set ltype=aname where aname='73A'
update ehomsom..tbPlanetype set ltype=aname where aname='73Q'
update ehomsom..tbPlanetype set ltype=aname where aname='78L'
update ehomsom..tbPlanetype set ltype=aname where aname='JET'
update ehomsom..tbPlanetype set ltype=aname where aname='32I'
update ehomsom..tbPlanetype set ltype=aname where aname='MA6'
update ehomsom..tbPlanetype set ltype=aname where aname='38M'
update ehomsom..tbPlanetype set ltype=aname where aname='32T'
update ehomsom..tbPlanetype set ltype=aname where aname='31L'
update ehomsom..tbPlanetype set ltype=aname where aname='191'
update ehomsom..tbPlanetype set ltype=aname where aname='351'
update ehomsom..tbPlanetype set ltype=aname where aname='3HH'
update ehomsom..tbPlanetype set ltype=aname where aname='32Q'


update ehomsom..tbPlanetype set btype='A350系列',manufacturer='空客' where aname='350'
update ehomsom..tbPlanetype set btype='A350系列',manufacturer='空客' where aname='359'
update ehomsom..tbPlanetype set btype='A330系列',manufacturer='空客' where aname='336'
update ehomsom..tbPlanetype set btype='A380系列',manufacturer='空客' where aname='380'
update ehomsom..tbPlanetype set btype='A350系列',manufacturer='空客' where aname='351'


--匹配差旅目的
select coupno,Purpose from Topway..tbcash
where coupno in('AS002223390',
'AS002235969',
'AS002235971',
'AS002186900',
'AS002186913',
'AS002175293',
'AS002175295',
'AS002220068',
'AS002220161',
'AS002168818',
'AS002168822',
'AS002192641',
'AS002192774',
'AS002235539',
'AS002174633',
'AS002174637',
'AS002182917',
'AS002195629',
'AS002195631',
'AS002205109',
'AS002227082',
'AS002227084',
'AS002197932',
'AS002197934',
'AS002176654',
'AS002181703',
'AS002212724',
'AS002212756',
'AS002217101',
'AS002217103',
'AS002227086',
'AS002227088',
'AS002182885',
'AS002182893',
'AS002212915',
'AS002212925',
'AS002227080',
'AS002174224',
'AS002174230',
'AS002170012',
'AS002170014',
'AS002188411',
'AS002195616',
'AS002204632',
'AS002204634',
'AS002210528',
'AS002210547',
'AS002204029',
'AS002204033',
'AS002217901',
'AS002177648',
'AS002177653',
'AS002199387',
'AS002200270',
'AS002211300',
'AS002231202',
'AS002231217',
'AS002205097',
'AS002205107',
'AS002171314',
'AS002171316',
'AS002228859',
'AS002228861',
'AS002195361',
'AS002199657',
'AS002218851',
'AS002229870',
'AS002210503',
'AS002210517',
'AS002202791',
'AS002209483',
'AS002209487',
'AS002214291',
'AS002193185',
'AS002193193',
'AS002210503',
'AS002210515',
'AS002180102',
'AS002193319',
'AS002194510',
'AS002194514',
'AS002226496',
'AS002231661',
'AS002202461',
'AS002182575',
'AS002182586',
'AS002196143',
'AS002196157',
'AS002210867',
'AS002197361',
'AS002197363',
'AS002169221',
'AS002169223',
'AS002173774',
'AS002173776',
'AS002178251',
'AS002178255',
'AS002174643',
'AS002174667',
'AS002178059',
'AS002178063',
'AS002182913',
'AS002197940',
'AS002197942',
'AS002209391',
'AS002213159',
'AS002222001',
'AS002222003',
'AS002193931',
'AS002194076',
'AS002195409',
'AS002195429',
'AS002204443',
'AS002204449',
'AS002204451',
'AS002227998',
'AS002228000',
'AS002220183',
'AS002220422',
'AS002173644',
'AS002173648',
'AS002190936',
'AS002190938',
'AS002233935',
'AS002234854',
'AS002211343',
'AS002211428',
'AS002174011',
'AS002174013',
'AS002189088',
'AS002210186',
'AS002210195',
'AS002200861',
'AS002208570',
'AS002181648',
'AS002204855',
'AS002204857',
'AS002176266',
'AS002176268')

select coupno,Purpose from Topway..tbcash
where coupno in('AS002270665',
'AS002270668',
'AS002273284',
'AS002280466',
'AS002280474',
'AS002280640',
'AS002280781',
'AS002269450',
'AS002269453',
'AS002276503',
'AS002278431',
'AS002278437',
'AS002278439',
'AS002280696',
'AS002280823',
'AS002254752',
'AS002254754',
'AS002272362',
'AS002272366',
'AS002272368',
'AS002261923',
'AS002267524',
'AS002266444',
'AS002266448',
'AS002246497',
'AS002262940',
'AS002245803',
'AS002263478',
'AS002279529',
'AS002279584',
'AS002270271',
'AS002272821',
'AS002254185',
'AS002254193',
'AS002254128',
'AS002254926',
'AS002262164',
'AS002254154',
'AS002254258',
'AS002268978',
'AS002272706',
'AS002245402',
'AS002260548',
'AS002268787',
'AS002280239',
'AS002259932',
'AS002266825',
'AS002265181',
'AS002265185',
'AS002272336',
'AS002272339',
'AS002250184',
'AS002250198',
'AS002280640',
'AS002280781',
'AS002244861',
'AS002250137',
'AS002261233',
'AS002265956',
'AS002267548',
'AS002270665',
'AS002270668',
'AS002273284',
'AS002277915',
'AS002278012',
'AS002278900',
'AS002278906',
'AS002272172',
'AS002272184',
'AS002240357',
'AS002240371',
'AS002244071',
'AS002244075',
'AS002277567',
'AS002264519',
'AS002268666',
'AS002263081',
'AS002281022',
'AS002279825',
'AS002272865',
'AS002273724',
'AS002280843',
'AS002280845',
'AS002280875',
'AS002262694',
'AS002281022',
'AS002277069',
'AS002277071')


--旅游退款单信息
select * from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk set AcountInfo='2019051622001459971038698634'
where TrvId='30096'

select * from Topway..tbTrvKhTk 
--update Topway..tbTrvKhTk set AcountInfo='2019051622001459971038972677'
where TrvId='30097'

--旅游收款单信息
select Skstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Skstatus=2
where TrvId='29725' and Id in ('228006','228005','228004','228000','227999','227998')

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002414528'

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno='AS002486881'

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印中文行程单'
where coupno='AS002474227'

--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1 
where BillNumber='019563_20190401'

--（产品部专用）机票供应商来源（国内）
select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETD'
where coupno in('AS002482996','AS002485952','AS002485892','AS002488057')

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HS易商慕韬志悦I'
where coupno in('AS002449635')

select t_source,* from Topway..tbcash 
--update Topway..tbcash set t_source='HSBSPETI'
where coupno in('AS002478877')

--修改退票状态
select status2,* from Topway..tbReti 
--update Topway..tbReti  set status2=3
where reno='0435495'

--（产品专用）保险结算价信息
select sprice1,totsprice,* from Topway..tbcash 
--update Topway..tbcash  set  sprice1=12,totsprice=12
where coupno='AS002475163'

--结算单作废
select settleStatus,* from topway..tbSettlementApp
--update topway..tbSettlementApp set settleStatus='3' 
where id='112138'

select * from topway..tbcash
--update topway..tbcash set wstatus='0',settleno='0' 
where settleno='112138'

select Status,* from topway..Tab_WF_Instance
--update topway..Tab_WF_Instance set Status='4' 
where BusinessID='112138'

--匹配差旅目的
select coupno,Purpose from Topway..tbcash 
where coupno in ('AS002150421',
'AS002150408',
'AS002043128',
'AS002043118',
'AS001966821',
'AS001966338',
'AS001966313',
'AS001858302',
'AS001855677',
'AS001855669',
'AS001836071',
'AS001836067',
'AS001827742',
'AS001827739',
'AS001718758',
'AS001597399',
'AS001597397',
'AS001543913',
'AS001476591',
'AS001476587',
'AS001410950')

--修改退票状态
select status2,* from Topway..tbReti 
--update Topway..tbReti set status2=7
where reno='9258169'

--UC019830提前7天内出票数据 2018年
select  coupno,DATEDIFF(DD,[datetime],begdate)提前出票天数,pasname,datetime,begdate
from Topway..tbcash 
where DATEDIFF(DD,datetime,begdate)<=7
--and begdate>=[datetime]
and datetime>='2018-01-01'
and datetime<'2019-01-01'
and cmpcode='019830'
AND tickettype='电子票'
order by 提前出票天数 desc



--常旅客手机号码异常查询
select Name,Mobile 手机,id from homsomDB..Trv_Human 
where Mobile like'%[%]%'
and IsDisplay=1
order by 手机

update homsomdb..Trv_Human  set Mobile=REPLACE(Mobile,'%2013061654528','13061654528') where ID='9ABDE480-2DF2-41E2-AD56-A937011A1C98'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'%2018121295351','18121295351') where ID='8700DCA2-E7BD-4431-82B5-A8B700A76E61'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'+81%2090-6053-4708','+8190-6053-4708') where ID='7F1ABBA3-2025-4290-9D81-FF206C671478'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'113901917088%20','113901917088') where ID='2BD007CB-95B8-41B0-8D27-A96800E88DDC'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13501738508%20','13501738508') where ID='D5BB53FF-7857-4D8B-A71A-A63B009E7AB1'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13501764900%20','13501764900') where ID='0EB355DC-EC6A-4FA8-B7A7-A95400EEDEF2'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13524243356%20','13524243356') where ID='58918367-9E84-4F3C-B8E2-A81D011CBCAF'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13585788360%20','13585788360') where ID='A743A259-159D-452F-AA15-A51A0117EA90'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13585811962%20','13585811962') where ID='BBE515D5-FB49-4387-B43E-A69001128765'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13601887008%20','13601887008') where ID='B7B7C850-78A4-40F1-A627-A973010EC7C4'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13636390662%20','13636390662') where ID='7428A787-52DA-4E93-B8EA-A8C501203B53'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13651673061%20','13651673061') where ID='28D84C01-8115-4718-A0E8-A97E00F94814'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13761189267%20','13761189267') where ID='98BF2634-1733-4907-8A90-A98A00E40513'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13761189267%20','13761189267') where ID='940BF3B4-3EB9-46A5-9BF9-AA3200C3A866'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13766702711%20','13766702711') where ID='B01043D7-BE5C-458B-A62F-A744010027BD'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='4280C280-4748-45B2-AC7E-253EE4AFC522'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='FD2080DC-2B9E-47B1-9CF7-308938F22E3E'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='2D6543BA-AE53-4465-B55B-436797DE2A6A'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='66728F81-ABA4-4CDE-A2DB-5140EFD9F759'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='336F61C5-B390-49F4-8E0D-551A0F738793'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='EC3640A3-E47D-4DD3-AA00-5E6BFDD54A29'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='9EF70B25-3912-4982-9662-6F184BA00D9C'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='AD2E7B54-1667-469A-80C1-8AEA2A26457E'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='839C07B1-6D98-4F54-B057-AF50FD570ECD'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='8980F2AC-DB06-48A6-B63E-D033F34711C4'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13795315168%20','13795315168') where ID='4291CC9C-9A44-4DAE-8A1C-FA4029FC7AA8'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13816885758%20','13816885758') where ID='19A2546C-92F6-452A-9096-A5480105E8E9'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13817035350%20','13817035350') where ID='676BEE41-402A-4BAF-86DD-844EC60A1F90'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13817035350%20','13817035350') where ID='38D9BF04-0170-4C79-8577-A98301006B68'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13818836482%20','13818836482') where ID='B3676566-3983-43B4-BB46-0B5A5F6D4558'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'139%206179%208727','13961798727') where ID='25C10731-275B-409F-BAE8-A61800C512C4'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='BA8075BA-F61E-46C3-AC47-559754E2B915'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='FE80EE8E-18C3-4AA1-8900-A2D1011FE1A0'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='D9D75BF6-9A48-4D12-A858-A3F401170886'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='93952F2F-77E4-466A-A316-A41A00F42934'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='A5C43887-90FE-407E-90D9-A45E00C56D66'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='AEDA379A-EE6B-4587-82D2-A4F2010D496A'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='1294D6FF-5D22-4CB0-A53E-A50E010F0BCB'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='DAA58B24-7675-473E-B668-A52A012256B5'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='B322A89E-BD45-4E7D-BA07-A5D801066059'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='35FA3429-D592-4BDD-A8FB-A5FD01172D82'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='A02E0384-FBAA-4CD6-99FE-A67A00D77823'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='63D28E70-FC65-4D60-A095-A7D200F462E6'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='ED5F1E07-AA03-4D09-84FA-A7E400AB3389'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='B65267F4-39EC-4FA0-A685-A7F600DE6D6C'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='FACDEAB4-13D7-415D-84EA-A81D00E12684'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='22AA7CF1-DF5E-4A4F-8EC7-A8BF00F0D700'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='CA4184F7-92E6-4521-BAC3-A918010C8E32'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='E40CC2D6-FCD3-4F18-B20B-A95700EC9D73'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='C732D2E9-72A8-4CC2-9FDE-A95B00F98646'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='B0BF4F00-D4C2-4D8B-AA54-A95E0098DF10'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='307EE5C2-2A04-48F2-AC01-A96100952F31'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='B62C27C2-1EF8-4A27-B624-A96900CF161D'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20','13901917088') where ID='E0F87BBB-AEC5-4688-8167-AA2201256EA0'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901917088%20,15801936408','1.3901917088,15801936408') where ID='0063FE6D-9047-4959-9C52-A3C500AD115E'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13901956004%20','13901956004') where ID='70F4FC4F-655B-40CF-9856-A73600A79EE1'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'13916379347%20','13916379347') where ID='10CE881B-8827-4E11-97A9-A6FA00A7E8D3'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'15019492770%20','15019492770') where ID='DE0E57BD-2D3D-48D9-98A1-A93100C84812'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'17717328805%20','17717328805') where ID='A5A3AAB1-C05F-4076-A5DA-A55900DC22AD'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'18221754962%20%20','18221754962') where ID='F14B0A74-A234-4AA3-BCF6-A51701192D3E'
update homsomDB..Trv_Human  set Mobile=REPLACE(Mobile,'18621131812%20%20%20','18621131812') where ID='3922CF88-135D-4C96-B405-A56400E62751'

update homsomdb..Trv_Human  set Mobile='18512166271' where ID='5D4BACF1-55CE-48B4-8D55-A55D00E805B5'
update homsomdb..Trv_Human  set Mobile='13601511224' where ID='ABC1975A-6517-4A21-89F7-A73100EA7563'
update homsomdb..Trv_Human  set Mobile='13818038827' where ID='85A45A8A-EAE8-4272-B2E8-A4BB00BC1E96'
update homsomdb..Trv_Human  set Mobile='13906005757' where ID='EC381CF8-67D2-482D-8AE7-A91F00BDFBDB'
update homsomdb..Trv_Human  set Mobile='17749787177' where ID='C4D58D97-D1BA-4F41-B464-1C3AFFB245A7'
update homsomdb..Trv_Human  set Mobile='18635596338' where ID='9A19F7CB-50EB-435E-8ECA-A7C800B968B6'
update homsomdb..Trv_Human  set Mobile='13551705128' where ID='0FC964F9-302B-41D9-ADA2-A60A0110D55E'
update homsomdb..Trv_Human  set Mobile='13674889636' where ID='BC6BBF52-032F-4640-B3FD-A9BA009A044E'
update homsomdb..Trv_Human  set Mobile='13704788072' where ID='DD3C9B71-A58A-4607-9572-A9BA0099F4E5'
update homsomdb..Trv_Human  set Mobile='15804504342' where ID='2B30249E-4AF4-444E-ABC7-A85101277032'
update homsomdb..Trv_Human  set Mobile='18512185582' where ID='C7464CBD-117A-4A83-AF95-A71400A2E3AC'

--机票业务顾问信息
select SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='翁景超'
where coupno='AS002463208'

--销售单匹配供应商来源
select coupno,t_source from Topway..tbcash 
where coupno in ('AS002441055',
'AS002441057',
'AS002441059',
'AS002441165',
'AS002441260',
'AS002441272',
'AS002441436',
'AS002441810',
'AS002441834',
'AS002442628',
'AS002442632',
'AS002442711',
'AS002442750',
'AS002443321',
'AS002444129',
'AS002444131',
'AS002444133',
'AS002444135',
'AS002444413',
'AS002444475',
'AS002444477',
'AS002444628',
'AS002444771',
'AS002444775',
'AS002445270',
'AS002445277',
'AS002445299',
'AS002446052',
'AS002446258',
'AS002446262',
'AS002446917',
'AS002447098',
'AS002447102',
'AS002447107',
'AS002447988',
'AS002449014',
'AS002449018',
'AS002449022',
'AS002449024',
'AS002449030',
'AS002449032',
'AS002449191',
'AS002449245',
'AS002449251',
'AS002450233',
'AS002450670',
'AS002451993',
'AS002452001',
'AS002452316',
'AS002452917',
'AS002452919',
'AS002453247',
'AS002453249',
'AS002453259',
'AS002453278',
'AS002454039',
'AS002454067',
'AS002454069',
'AS002454076',
'AS002454231',
'AS002454233',
'AS002454235',
'AS002454237',
'AS002454455',
'AS002454891',
'AS002454916',
'AS002454922',
'AS002455065',
'AS002455094',
'AS002455153',
'AS002455386',
'AS002455704',
'AS002455866',
'AS002455873',
'AS002455878',
'AS002456393',
'AS002456395',
'AS002456538',
'AS002456876',
'AS002456878',
'AS002457083',
'AS002457108',
'AS002457114',
'AS002457252',
'AS002457254',
'AS002457275',
'AS002457277',
'AS002457536',
'AS002457560',
'AS002457576',
'AS002457581',
'AS002457713',
'AS002457998',
'AS002458027',
'AS002458035',
'AS002458221',
'AS002458290',
'AS002458411',
'AS002458413',
'AS002458419',
'AS002458431',
'AS002458435',
'AS002458441',
'AS002458476',
'AS002458489',
'AS002458491',
'AS002458782',
'AS002459075',
'AS002459874',
'AS002459908',
'AS002459960',
'AS002460236',
'AS002460240',
'AS002460675',
'AS002461456',
'AS002462044',
'AS002462054',
'AS002462541',
'AS002462860',
'AS002462966',
'AS002463202',
'AS002463206',
'AS002463240',
'AS002463242',
'AS002463453',
'AS002463457',
'AS002463731',
'AS002463735',
'AS002463745',
'AS002463747',
'AS002463845',
'AS002464165',
'AS002464333',
'AS002464339',
'AS002464879',
'AS002466387',
'AS002466389',
'AS002466825',
'AS002467212',
'AS002467266',
'AS002467350',
'AS002467871',
'AS002468091',
'AS002468305',
'AS002468309',
'AS002468429',
'AS002468763',
'AS002468931',
'AS002469249',
'AS002469624',
'AS002469732',
'AS002469738',
'AS002469882',
'AS002470182',
'AS002470444',
'AS002470865',
'AS002470880',
'AS002471006',
'AS002471117',
'AS002471134',
'AS002471143',
'AS002471157',
'AS002471159',
'AS002471314',
'AS002471319',
'AS002471334',
'AS002471489',
'AS002471496',
'AS002471498',
'AS002471505',
'AS002471524',
'AS002471539',
'AS002471563',
'AS002471563',
'AS002471586',
'AS002471590',
'AS002471627',
'AS002471667',
'AS002471667',
'AS002471667',
'AS002471667',
'AS002471667',
'AS002471667',
'AS002471717',
'AS002471717',
'AS002471717',
'AS002471717',
'AS002471717',
'AS002471717',
'AS002471752',
'AS002471983',
'AS002471995',
'AS002472032',
'AS002472034',
'AS002472079',
'AS002472081',
'AS002472473',
'AS002472550',
'AS002472571',
'AS002472763',
'AS002472773',
'AS002472789',
'AS002472953',
'AS002472965',
'AS002473148',
'AS002473435',
'AS002473439',
'AS002473794',
'AS002473829',
'AS002473961',
'AS002473997',
'AS002474042',
'AS002474044',
'AS002474105',
'AS002474184',
'AS002474204',
'AS002474255',
'AS002474423',
'AS002474450',
'AS002474492',
'AS002474516',
'AS002474523',
'AS002474843',
'AS002474988',
'AS002474996',
'AS002475024',
'AS002475355',
'AS002475366',
'AS002475416',
'AS002475417',
'AS002475418',
'AS002475431',
'AS002475438',
'AS002475443',
'AS002476436',
'AS002476571',
'AS002476586',
'AS002476746',
'AS002476754',
'AS002476759',
'AS002476810',
'AS002476842',
'AS002476938',
'AS002476943',
'AS002477281',
'AS002477290',
'AS002477297',
'AS002477303',
'AS002477306',
'AS002477312',
'AS002477383',
'AS002477383',
'AS002477395',
'AS002477395',
'AS002477400',
'AS002477404',
'AS002477418',
'AS002477430',
'AS002477472',
'AS002477850',
'AS002477975',
'AS002478175',
'AS002478464',
'AS002478493',
'AS002478599',
'AS002478636',
'AS002479447',
'AS002479643',
'AS002479643',
'AS002479861',
'AS002479863',
'AS002479953',
'AS002480027',
'AS002480041',
'AS002480262',
'AS002480268',
'AS002480275',
'AS002480276',
'AS002480291',
'AS002480491',
'AS002480499',
'AS002480644',
'AS002480765',
'AS002480765',
'AS002480999',
'AS002480999',
'AS002481006',
'AS002481006',
'AS002481031',
'AS002481341',
'AS002481365',
'AS002481587',
'AS002481592',
'AS002481740',
'AS002481745',
'AS002481865',
'AS002481883',
'AS002481901',
'AS002481901',
'AS002481901',
'AS002481916',
'AS002481916',
'AS002481916',
'AS002481998',
'AS002481998',
'AS002481998',
'AS002481998',
'AS002481998',
'AS002481998',
'AS002481999',
'AS002482062',
'AS002482062',
'AS002482062',
'AS002482062',
'AS002482062',
'AS002482140',
'AS002482140',
'AS002482164',
'AS002482164',
'AS002482164',
'AS002482189',
'AS002482189',
'AS002482189',
'AS002482189',
'AS002482189',
'AS002483209',
'AS002483434',
'AS002484108',
'AS002484566',
'AS002484576',
'AS002484623',
'AS002484747',
'AS002484922',
'AS002484973',
'AS002485421',
'AS002485435',
'AS002485547',
'AS002485856',
'AS002486018',
'AS002486029',
'AS002486043',
'AS002486052',
'AS002486063',
'AS002486065',
'AS002486076',
'AS002486093',
'AS002486171',
'AS002486234',
'AS002486234',
'AS002486234',
'AS002486263',
'AS002486263',
'AS002486272',
'AS002486272',
'AS002486347',
'AS002486353',
'AS002486477',
'AS002486556',
'AS002486559',
'AS002486564',
'AS002486584',
'AS002486597',
'AS002486614',
'AS002486630',
'AS002486667',
'AS002486667',
'AS002486726',
'AS002486738',
'AS002486748',
'AS002486782',
'AS002486867',
'AS002486870',
'AS002486883',
'AS002486891',
'AS002486962',
'AS002487031',
'AS002487121',
'AS002487161',
'AS002487167',
'AS002487175',
'AS002487188',
'AS002487216',
'AS002487223',
'AS002487232',
'AS002487236',
'AS002487248',
'AS002487334',
'AS002487334',
'AS002487334',
'AS002487354',
'AS002487354',
'AS002487354',
'AS002487367',
'AS002487413',
'AS002487435',
'AS002487440',
'AS002487464',
'AS002487466',
'AS002487513',
'AS002487627',
'AS002487627',
'AS002487630',
'AS002487630',
'AS002487673',
'AS002487686',
'AS002487686',
'AS002487693',
'AS002487767',
'AS002487769',
'AS002487803',
'AS002487950',
'AS002487966',
'AS002488302',
'AS002488706',
'AS002488713',
'AS002489001',
'AS002489785',
'AS002489793',
'AS002490402',
'AS002490412',
'AS002491643',
'AS002491832')