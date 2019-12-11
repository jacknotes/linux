--（产品部专用）修改退票状态（国际）
select opername,operDep,* from Topway..tbReti 
--update Topway..tbReti set opername='孙艳',operDep=''
where reno in ('9265666','9265667')

--修改座位数
select Top 10 * from ehomsom..tbPlanetype 
--update ehomsom..tbPlanetype  set maxseat='162-178'
where aname='7M8'

--（产品专用）申请费来源/金额信息（国际）
select feiyong,* from Topway..tbcash 
--update Topway..tbcash set feiyong='920'
where coupno='AS002212993'

--补票号
select pasname,tcode,ticketno,* from topway..tbcash where coupno in ('AS002214736')
update topway..tbcash set pasname='CAI/JIAHUI',tcode='018',ticketno='2102363597' where coupno in ('AS002214736') and pasname='XU/XIAOYE'
update topway..tbcash set pasname='DING/HUIXIAN',tcode='018',ticketno='2102363598' where coupno in ('AS002214736') and pasname='XU/JING'
update topway..tbcash set pasname='LI/SHANGRONG',tcode='018',ticketno='2102363599' where coupno in ('AS002214736') and pasname='SHAN/JIAJUN'
update topway..tbcash set pasname='PENG/ZHONG',tcode='018',ticketno='2102363600' where coupno in ('AS002214736') and pasname='PENG/ZHONG'
update topway..tbcash set pasname='SHAN/JIAJUN ',tcode='018',ticketno='2102363601' where coupno in ('AS002214736') and pasname='LI/SHANGRONG'
update topway..tbcash set pasname='SHAO/DALEI',tcode='018',ticketno='2102363602' where coupno in ('AS002214736') and pasname='ZHANG/LU'
update topway..tbcash set pasname='XU/JING',tcode='018',ticketno='2102363603' where coupno in ('AS002214736') and pasname='ZHANG/YAN'
update topway..tbcash set pasname='XU/XIAO',tcode='018',ticketno='2102363604' where coupno in ('AS002214736') and pasname='YANG/WEI'
update topway..tbcash set pasname='XU/XIAOYE',tcode='018',ticketno='2102363605' where coupno in ('AS002214736') and pasname='CAI/JIAHUI'
update topway..tbcash set pasname='YANG/WEI',tcode='018',ticketno='2102363606' where coupno in ('AS002214736') and pasname='DING/HUIXIAN'
update topway..tbcash set pasname='ZHANG/LU ',tcode='018',ticketno='2102363607' where coupno in ('AS002214736') and pasname='XU/XIAO'
update topway..tbcash set pasname='ZHANG/YAN',tcode='018',ticketno='2102363608' where coupno in ('AS002214736') and pasname='SHAO/DALEI'

--多付款单、退票付款申请单修改/作废
select IsEnable,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment set IsEnable='0'
where Id='51560'

--分单15人
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from topway..tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='15',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',Pasname='乘客1,乘客2,乘客3,乘客4,乘客5,乘客6,乘客7,乘客8,乘客9,乘客10,乘客11,乘客12,乘客13,乘客14,乘客15',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002215490')
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from topway..tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='15',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',Pasname='乘客1,乘客2,乘客3,乘客4,乘客5,乘客6,乘客7,乘客8,乘客9,乘客10,乘客11,乘客12,乘客13,乘客14,乘客15',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002215665')

--（产品部专用）修改退票状态（国内）
select opername,* from Topway..tbReti 
--update Topway..tbReti set opername='何洁'
where reno='0425138'

--修改服务费
select coupno,fuprice,totprice,amount,owe from Topway..tbcash 
where cmpcode='018735' and coupno in('AS002046444','AS002046468','AS002047784','AS002047788','AS002047823','AS002059523','AS002059524','AS002059543','AS002059544')

update Topway..tbcash set fuprice='0' where cmpcode='018735' and coupno in('AS002046444','AS002046468','AS002047784','AS002047788','AS002047823','AS002059523','AS002059524','AS002059543','AS002059544')
update Topway..tbcash set totprice='2256',amount='2256',owe='2256' where coupno='AS002046444'
update Topway..tbcash set totprice='1376',amount='1376',owe='1376' where coupno='AS002046468'
update Topway..tbcash set totprice='2256',amount='2256',owe='2256' where coupno='AS002047784'
update Topway..tbcash set totprice='2256',amount='2256',owe='2256' where coupno='AS002047788'
update Topway..tbcash set totprice='1376',amount='1376',owe='1376' where coupno='AS002047823'
update Topway..tbcash set totprice='1606',amount='1606',owe='1606' where coupno='AS002059523'
update Topway..tbcash set totprice='2256',amount='2256',owe='2256' where coupno='AS002059524'
update Topway..tbcash set totprice='1376',amount='1376',owe='1376' where coupno='AS002059543'
update Topway..tbcash set totprice='1206',amount='1206',owe='1206' where coupno='AS002059544'

--多付款单、退票付款申请单修改/作废
select IsEnable,* from Topway..tbExtraPayment 
--update Topway..tbExtraPayment set IsEnable='0'
where Id='51559'

--分单17人
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from topway..tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='17',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',Pasname='乘客1,乘客2,乘客3,乘客4,乘客5,乘客6,乘客7,乘客8,乘客9,乘客10,乘客11,乘客12,乘客13,乘客14,乘客15,乘客16,乘客17',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002215863')

--分单18人
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from topway..tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',MobileList='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='18',Department='无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无,无',Pasname='乘客1,乘客2,乘客3,乘客4,乘客5,乘客6,乘客7,乘客8,乘客9,乘客10,乘客11,乘客12,乘客13,乘客14,乘客15,乘客16,乘客17,乘客18',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from topway..tbFiveCoupInfo where CoupNo='AS002215896')

--补票号
select pasname,tcode,ticketno,* from topway..tbcash where coupno in ('AS002215665')
--AS002215863
update topway..tbcash set pasname='UAN/XIUMEI',tcode='784',ticketno='1418050072' where coupno in ('AS002215863') and pasname='乘客1'
update topway..tbcash set pasname='ZHANG/ANCAI',tcode='784',ticketno='1418050074' where coupno in ('AS002215863') and pasname='乘客2'
update topway..tbcash set pasname='ZHANG/XINGYUE',tcode='784',ticketno='1418050076' where coupno in ('AS002215863') and pasname='乘客3'
update topway..tbcash set pasname='ZHENG/QIANG',tcode='784',ticketno='1418050078' where coupno in ('AS002215863') and pasname='乘客4'
update topway..tbcash set pasname='CAO/JING',tcode='784',ticketno='1418050080' where coupno in ('AS002215863') and pasname='乘客5'
update topway..tbcash set pasname='CHEN/YEYAN',tcode='784',ticketno='1418050081' where coupno in ('AS002215863') and pasname='乘客6'
update topway..tbcash set pasname='HUANG/ZANYANG',tcode='784',ticketno='1418050086' where coupno in ('AS002215863') and pasname='乘客7'
update topway..tbcash set pasname='JIANG/ZHENNI',tcode='784',ticketno='1418050088' where coupno in ('AS002215863') and pasname='乘客8'
update topway..tbcash set pasname='LI/YAN',tcode='784',ticketno='1418050089' where coupno in ('AS002215863') and pasname='乘客9'
update topway..tbcash set pasname='LIU/KE',tcode='784',ticketno='1418050090' where coupno in ('AS002215863') and pasname='乘客10'
update topway..tbcash set pasname='LIU/YING',tcode='784',ticketno='1418050091' where coupno in ('AS002215863') and pasname='乘客11'
update topway..tbcash set pasname='LIU/ZHIHUA',tcode='784',ticketno='1418050093' where coupno in ('AS002215863') and pasname='乘客12'
update topway..tbcash set pasname='LU/QIN',tcode='784',ticketno='1418050094' where coupno in ('AS002215863') and pasname='乘客13'
update topway..tbcash set pasname='WANG/BEI',tcode='784',ticketno='1418050097' where coupno in ('AS002215863') and pasname='乘客14'
update topway..tbcash set pasname='WEI/LINGLI',tcode='784',ticketno='1418050101' where coupno in ('AS002215863') and pasname='乘客15'
update topway..tbcash set pasname='XU/DEWEI',tcode='784',ticketno='1418050104' where coupno in ('AS002215863') and pasname='乘客16'
update topway..tbcash set pasname='YAN/YUAN',tcode='784',ticketno='1418050106' where coupno in ('AS002215863') and pasname='乘客17'
--AS002215896
update topway..tbcash set pasname='YANG/RONGHUACHD',tcode='784',ticketno='1418050071' where coupno in ('AS002215896') and pasname='乘客1'
update topway..tbcash set pasname='ZHA/RUIYANGCHD',tcode='784',ticketno='1418050073' where coupno in ('AS002215896') and pasname='乘客2'
update topway..tbcash set pasname='ZHANG/RUIYANCHD',tcode='784',ticketno='1418050075' where coupno in ('AS002215896') and pasname='乘客3'
update topway..tbcash set pasname='ZHENG/LIZHICHD',tcode='784',ticketno='1418050077' where coupno in ('AS002215896') and pasname='乘客4'
update topway..tbcash set pasname='CUI/XINGJICHD',tcode='784',ticketno='1418050082' where coupno in ('AS002215896') and pasname='乘客5'
update topway..tbcash set pasname='FU/YINGXICHD',tcode='784',ticketno='1418050083' where coupno in ('AS002215896') and pasname='乘客6'
update topway..tbcash set pasname='HUANG/SHIYANCHD',tcode='784',ticketno='1418050084' where coupno in ('AS002215896') and pasname='乘客7'
update topway..tbcash set pasname='HUANG/YUETONGCHD',tcode='784',ticketno='1418050085' where coupno in ('AS002215896') and pasname='乘客8'
update topway..tbcash set pasname='JIANG/XIZECHD',tcode='784',ticketno='1418050087' where coupno in ('AS002215896') and pasname='乘客9'
update topway..tbcash set pasname='LIU/YIXICHD',tcode='784',ticketno='1418050092' where coupno in ('AS002215896') and pasname='乘客10'
update topway..tbcash set pasname='TANG/ENXINCHD',tcode='784',ticketno='1418050095' where coupno in ('AS002215896') and pasname='乘客11'
update topway..tbcash set pasname='TANG/HAOZHECHD',tcode='784',ticketno='1418050096' where coupno in ('AS002215896') and pasname='乘客12'
update topway..tbcash set pasname='WANG/SHUYANGCHD',tcode='784',ticketno='1418050098' where coupno in ('AS002215896') and pasname='乘客13'
update topway..tbcash set pasname='WANG/XINTINGCHD',tcode='784',ticketno='1418050099' where coupno in ('AS002215896') and pasname='乘客14'
update topway..tbcash set pasname='WANG/ZICENCHD',tcode='784',ticketno='1418050100' where coupno in ('AS002215896') and pasname='乘客15'
update topway..tbcash set pasname='WU/YIHENGCHD',tcode='784',ticketno='1418050102' where coupno in ('AS002215896') and pasname='乘客16'
update topway..tbcash set pasname='WU/YUCHENCHD',tcode='784',ticketno='1418050103' where coupno in ('AS002215896') and pasname='乘客17'
update topway..tbcash set pasname='XU/TAORANCHD',tcode='784',ticketno='1418050105' where coupno in ('AS002215896') and pasname='乘客18'
--AS002215490
update topway..tbcash set pasname='CHEN/YUAN',tcode='784',ticketno='1418050039' where coupno in ('AS002215490') and pasname='乘客1'
update topway..tbcash set pasname='CHEN/YUE',tcode='784',ticketno='1418050040' where coupno in ('AS002215490') and pasname='乘客2'
update topway..tbcash set pasname='LI/SU',tcode='784',ticketno='1418050044' where coupno in ('AS002215490') and pasname='乘客3'
update topway..tbcash set pasname='LIU/DONGMEI',tcode='784',ticketno='1418050045' where coupno in ('AS002215490') and pasname='乘客4'
update topway..tbcash set pasname='WANG/YIFEI',tcode='784',ticketno='1418050052' where coupno in ('AS002215490') and pasname='乘客5'
update topway..tbcash set pasname='WANG/YONGSHENG',tcode='784',ticketno='1418050053' where coupno in ('AS002215490') and pasname='乘客6'
update topway..tbcash set pasname='WU/YILING',tcode='784',ticketno='1418050055' where coupno in ('AS002215490') and pasname='乘客7'
update topway..tbcash set pasname='XIONG/CHUYU',tcode='784',ticketno='1418050056' where coupno in ('AS002215490') and pasname='乘客8'
update topway..tbcash set pasname='XU/JIAN',tcode='784',ticketno='1418050058' where coupno in ('AS002215490') and pasname='乘客9'
update topway..tbcash set pasname='YU/HAO',tcode='784',ticketno='1418050059' where coupno in ('AS002215490') and pasname='乘客10'
update topway..tbcash set pasname='YU/XINGTONG',tcode='784',ticketno='1418050061' where coupno in ('AS002215490') and pasname='乘客11'
update topway..tbcash set pasname='YU/XUE',tcode='784',ticketno='1418050062' where coupno in ('AS002215490') and pasname='乘客12'
update topway..tbcash set pasname='ZHANG/FAN',tcode='784',ticketno='1418050063' where coupno in ('AS002215490') and pasname='乘客13'
update topway..tbcash set pasname='ZHANG/JIANQIN',tcode='784',ticketno='1418050064' where coupno in ('AS002215490') and pasname='乘客14'
update topway..tbcash set pasname='ZHANG/YAN',tcode='784',ticketno='1418050066' where coupno in ('AS002215490') and pasname='乘客15'
--AS002215665
update topway..tbcash set pasname='CHEN/QIANYUCHD',tcode='784',ticketno='1418050038' where coupno in ('AS002215665') and pasname='乘客1'
update topway..tbcash set pasname='CUI/JIAMINGCHD',tcode='784',ticketno='1418050041' where coupno in ('AS002215665') and pasname='乘客2'
update topway..tbcash set pasname='JU/JIAZHANGCHD',tcode='784',ticketno='1418050042' where coupno in ('AS002215665') and pasname='乘客3'
update topway..tbcash set pasname='LEI/QIANRUCHD',tcode='784',ticketno='1418050043' where coupno in ('AS002215665') and pasname='乘客4'
update topway..tbcash set pasname='LIU/WENYUCHD',tcode='784',ticketno='1418050046' where coupno in ('AS002215665') and pasname='乘客5'
update topway..tbcash set pasname='LIU/YAJIECHD',tcode='784',ticketno='1418050047' where coupno in ('AS002215665') and pasname='乘客6'
update topway..tbcash set pasname='LONG/QIANRUNCHD',tcode='784',ticketno='1418050048' where coupno in ('AS002215665') and pasname='乘客7'
update topway..tbcash set pasname='SAN/XINERCHD',tcode='784',ticketno='1418050049' where coupno in ('AS002215665') and pasname='乘客8'
update topway..tbcash set pasname='SHANG/XINYICHD',tcode='784',ticketno='1418050050' where coupno in ('AS002215665') and pasname='乘客9'
update topway..tbcash set pasname='TAO/LEYANGCHD',tcode='784',ticketno='1418050051' where coupno in ('AS002215665') and pasname='乘客10'
update topway..tbcash set pasname='WANG/ZIQICHD',tcode='784',ticketno='1418050054' where coupno in ('AS002215665') and pasname='乘客11'
update topway..tbcash set pasname='XU/HANYICHD',tcode='784',ticketno='1418050057' where coupno in ('AS002215665') and pasname='乘客12'
update topway..tbcash set pasname='YU/MINXICHD',tcode='784',ticketno='1418050060' where coupno in ('AS002215665') and pasname='乘客13'
update topway..tbcash set pasname='ZHANG/MINGZHUCHD',tcode='784',ticketno='1418050065' where coupno in ('AS002215665') and pasname='乘客14'
update topway..tbcash set pasname='ZHU/RUIYICHD',tcode='784',ticketno='1418050067' where coupno in ('AS002215665') and pasname='乘客15'

----旅游预算单信息
--select * from Topway..tbTravelBudget where Sales='边洁静'
select Sales,OperName,ModifyName,introducer,* from Topway..tbTravelBudget 
--update Topway..tbTravelBudget set Sales='边洁静',OperName='117边洁静',ModifyName='117边洁静',introducer=''
where TrvId in ('029309','029457','029263','029292','029268','029100') 

--财务到账状态

select state,AuditARop,AuditARopid,* from topway..FinanceERP_ClientBankRealIncomeDetail 
--update topway..FinanceERP_ClientBankRealIncomeDetail set AuditARop='周玥玲',AuditARopid='0614'
where money='19190' and id='35D69C95-3364-494E-9EF5-20A27B8B69EF' 



--打印权限
select Pstatus,Prdate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus='0',Prdate='1900-01-01'
where TrvId='029342'

--修改账单抬头
select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='乐金商事（中国）贸易有限公司'
where CompanyCode='016724' and BillNumber='016724_20190101'

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='翃润（上海）贸易有限公司'
where CompanyCode='017944' and BillNumber='017944_20190101'
