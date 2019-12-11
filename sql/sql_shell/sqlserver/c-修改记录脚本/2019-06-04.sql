/*
帮我拉下所有国内机票特殊票价为否的单位名单（只要运营经理为邵雪梅和王静雯） 国内特殊票价：否
字段：UC号、单位名称、差旅顾问，客户经理，运营经理
*/

select u.Cmpid UC号,u.Name 单位名称,s.Name 差旅顾问,h1.MaintainName 客户经理,h.MaintainName 运营经理,
case when IsSepPrice=0 then '否' else '' end  申请国内特殊票价
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=u.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
left join Topway..HM_ThePreservationOfHumanInformation h on h.CmpId=u.Cmpid and MaintainType=9 and IsDisplay=1
left join Topway..HM_ThePreservationOfHumanInformation h1 on h1.CmpId=u.Cmpid and h1.MaintainType=1 and h1.IsDisplay=1
where IsSepPrice=0
and h.MaintainName in ('邵雪梅','王静雯')
and u.CooperativeStatus in ('1','2','3')

--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印中文行程单'
where coupno in('AS002481094','AS002481123')

select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno in('AS002462423')


select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno in('AS002500150','AS002500261')


--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState=1
where BillNumber='020797_20190501'


select * from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
where Cmpid='020797'
and IsDisplay=1


--修改退票录入人
select opername,operDep,* from Topway..tbReti 
--update Topway..tbReti  set opername='钟韵',operDep='运营部'
where reno in ('0436534','0436535')

--修改销售单价
select price,* from Topway..tbcash where coupno='AS002441175'
update Topway..tbcash set price=2470,profit=profit-110,totprice=2520,owe=2520,amount=2520  where coupno='AS002441175'
update Topway..tbcash set price=930,profit=profit-30,totprice=980,owe=980,amount=980  where coupno='AS002441681'
update Topway..tbcash set price=2190,profit=profit-20,totprice=2240,owe=2240,amount=2240  where coupno='AS002441794'
update Topway..tbcash set price=1470,profit=profit-90,totprice=1520,owe=1520,amount=1520  where coupno='AS002442798'
update Topway..tbcash set price=2190,profit=profit-80,totprice=2240,owe=2240,amount=2240  where coupno='AS002448578'
update Topway..tbcash set price=2190,profit=profit-50,totprice=2240,owe=2240,amount=2240  where coupno='AS002449094'
update Topway..tbcash set price=1900,profit=profit-100,totprice=1950,owe=1950,amount=1950  where coupno='AS002449347'
update Topway..tbcash set price=1500,profit=profit-50,totprice=1550,owe=1550,amount=1550  where coupno='AS002450142'
update Topway..tbcash set price=1060,profit=profit-10,totprice=1110,owe=1110,amount=1110  where coupno='AS002450372'
update Topway..tbcash set price=1190,profit=profit-60,totprice=1240,owe=1240,amount=1240  where coupno='AS002453494'
update Topway..tbcash set price=800,profit=profit-40,totprice=850,owe=850,amount=850  where coupno='AS002454385'
update Topway..tbcash set price=930,profit=profit-10,totprice=980,owe=980,amount=980  where coupno='AS002464119'
update Topway..tbcash set price=830,profit=profit-10,totprice=880,owe=880,amount=880  where coupno='AS002465599'
update Topway..tbcash set price=1080,profit=profit-10,totprice=1130,owe=1130,amount=1130  where coupno='AS002465617'
update Topway..tbcash set price=1460,profit=profit-80,totprice=1510,owe=1510,amount=1510  where coupno='AS002470491'
update Topway..tbcash set price=890,profit=profit-20,totprice=940,owe=940,amount=940  where coupno='AS002471083'
update Topway..tbcash set price=900,profit=profit-60,totprice=950,owe=950,amount=950  where coupno='AS002474161'
update Topway..tbcash set price=1290,profit=profit-40,totprice=1340,owe=1340,amount=1340  where coupno='AS002474647'
update Topway..tbcash set price=960,profit=profit-30,totprice=1010,owe=1010,amount=1010  where coupno='AS002475662'
update Topway..tbcash set price=1510,profit=profit-80,totprice=1560,owe=1560,amount=1560  where coupno='AS002476624'
update Topway..tbcash set price=1470,profit=profit-120,totprice=1520,owe=1520,amount=1520  where coupno='AS002476626'
update Topway..tbcash set price=1050,profit=profit-120,totprice=1100,owe=1100,amount=1100  where coupno='AS002476697'
update Topway..tbcash set price=1540,profit=profit-120,totprice=1590,owe=1590,amount=1590  where coupno='AS002482005'
update Topway..tbcash set price=650,profit=profit-20,totprice=700,owe=700,amount=700  where coupno='AS002482883'
update Topway..tbcash set price=1810,profit=profit-140,totprice=1860,owe=1860,amount=1860  where coupno='AS002483025'
update Topway..tbcash set price=1100,profit=profit-40,totprice=1150,owe=1150,amount=1150  where coupno='AS002483170'
update Topway..tbcash set price=1470,profit=profit-120,totprice=1520,owe=1520,amount=1520  where coupno='AS002483450'
update Topway..tbcash set price=1040,profit=profit-30,totprice=1090,owe=1090,amount=1090  where coupno='AS002483828'
update Topway..tbcash set price=1700,profit=profit-20,totprice=1750,owe=1750,amount=1750  where coupno='AS002485728'
update Topway..tbcash set price=1080,profit=profit-10,totprice=1130,owe=1130,amount=1130  where coupno='AS002487382'
update Topway..tbcash set price=560,profit=profit-30,totprice=610,owe=610,amount=610  where coupno='AS002489165'
update Topway..tbcash set price=1510,profit=profit-80,totprice=1560,owe=1560,amount=1560  where coupno='AS002489183'


 --UC019392 导入项目编号
 --select * from homsomDB..Trv_Customizations where UnitCompanyID=(Select ID from homsomDB..Trv_UnitCompanies where Cmpid='019392')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:MarkvanBruchem','0','一级审批:MarkvanBruchem','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：Mobility.china','0','一级审批：Mobility.china','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：白永森','0','一级审批：白永森','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：蔡绍源','0','一级审批：蔡绍源','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：陈晨','0','一级审批：陈晨','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：陈军','0','一级审批：陈军','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：陈勇','0','一级审批：陈勇','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：程能沅','0','一级审批：程能沅','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：杜拥平','0','一级审批：杜拥平','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:费宗香','0','一级审批:费宗香','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：傅俊犇','0','一级审批：傅俊犇','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：管祥松','0','一级审批：管祥松','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：何少明','0','一级审批：何少明','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：何泳辉','0','一级审批：何泳辉','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：何中金','0','一级审批：何中金','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：胡辰子','0','一级审批：胡辰子','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：黄玉麟','0','一级审批：黄玉麟','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：纪珊','0','一级审批：纪珊','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：蒋充','0','一级审批：蒋充','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李本明','0','一级审批：李本明','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李超','0','一级审批：李超','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李平','0','一级审批：李平','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李欣','0','一级审批：李欣','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李延军','0','一级审批：李延军','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李玉东','0','一级审批：李玉东','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：李子鹏','0','一级审批：李子鹏','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:刘江涛','0','一级审批:刘江涛','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：刘君','0','一级审批：刘君','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：陆舜尧','0','一级审批：陆舜尧','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:陆璇','0','一级审批:陆璇','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：吕霄霄','0','一级审批：吕霄霄','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：马海豹','0','一级审批：马海豹','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：马师来','0','一级审批：马师来','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:裴俊岭','0','一级审批:裴俊岭','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：谈嘉君','0','一级审批：谈嘉君','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:田伟卿','0','一级审批:田伟卿','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:仝彩宾','0','一级审批:仝彩宾','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：王宏','0','一级审批：王宏','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:王金玲','0','一级审批:王金玲','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：王良帅','0','一级审批：王良帅','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：王姗姗','0','一级审批：王姗姗','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:王騊','0','一级审批:王騊','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：徐欢','0','一级审批：徐欢','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:徐荣华','0','一级审批:徐荣华','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：许东亮','0','一级审批：许东亮','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:许晶','0','一级审批:许晶','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：杨晨亮','0','一级审批：杨晨亮','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：姚雅萍','0','一级审批：姚雅萍','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：叶建栋','0','一级审批：叶建栋','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：张达光','0','一级审批：张达光','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：张灏','0','一级审批：张灏','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：张羽飞','0','一级审批：张羽飞','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批:赵洪杰','0','一级审批:赵洪杰','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：赵龙江','0','一级审批：赵龙江','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：朱驰','0','一级审批：朱驰','8733D8C2-EA46-4087-92AC-A541011086C4')
 INSERT INTO homsomDB..Trv_Customizations (ID,Ver,ModifyDate,CreateBy,CreateDate,Code,NeedVetting,Remark,UnitCompanyID) values (NEWID(),GETDATE(),GETDATE(),'homsom',GETDATE(),'一级审批：朱德华','0','一级审批：朱德华','8733D8C2-EA46-4087-92AC-A541011086C4')

select Mobile,Cmpid,* from homsomDB..Trv_Human h 
left join homsomDB..Trv_UnitPersons un on un.ID=h.ID
left join homsomDB..Trv_UnitCompanies u on u.ID=un.CompanyID
where CustID='d694293'

--（产品专用）申请费来源
select feiyong,feiyonginfo,* from Topway..tbcash 
--update Topway..tbcash  set feiyong=0,feiyonginfo=''
where coupno='AS002526497'

--UC019392删除常旅客
select * from homsomDB..Trv_Human
--update  homsomDB..Trv_Human set IsDisplay=0
where ID in(Select ID from homsomDB..Trv_UnitPersons where 
companyid=(Select  ID from homsomDB..Trv_UnitCompanies where Cmpid='019392'))
and IsDisplay=1


--行程单
select info3,* from Topway..tbcash 
--update Topway..tbcash  set info3='需打印行程单'
where coupno in('AS002456884')

--UC020105更名 英克若普（上海）财务咨询有限公司

select CompanyNameCN,* from Topway..AccountStatement 
--update Topway..AccountStatement  set CompanyNameCN='英克若普（上海）财务咨询有限公司'
where BillNumber='020105_20190601'

--旅游收款单信息
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
where TrvId='29989' and Id='228256'

--账单撤销
select TrainBillStatus,* from Topway..AccountStatement 
--update Topway..AccountStatement  set TrainBillStatus=1
where BillNumber='019394_20190501'

--UC017969欧励隆0501账单  行程单号
select detr_rp from Topway..tbcash where ModifyBillNumber='017969_20190501' and DETR_RP<>'' order by detr_rp

