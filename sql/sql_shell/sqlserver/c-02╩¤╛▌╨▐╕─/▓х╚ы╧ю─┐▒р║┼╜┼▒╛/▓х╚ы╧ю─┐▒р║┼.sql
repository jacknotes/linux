--删除备注
select Remark from homsomDB..Trv_Customizations 
--update homsomDB..Trv_Customizations set Remark=''
where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') 

--插入项目编号
select Code,* from homsomDB..Trv_Customizations 
--="update homsomDB..Trv_Customizations set Code='" &B2&"' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='" &B2&"'"
update homsomDB..Trv_Customizations set Code='Warehouse' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='TPI-S'
update homsomDB..Trv_Customizations set Code='Admin' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='Admin'
update homsomDB..Trv_Customizations set Code='CPI TFK-S-China' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='BCO07-SAT'
update homsomDB..Trv_Customizations set Code='CPI Lotes-S-China' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='TPI-SAT'
update homsomDB..Trv_Customizations set Code='HIS MEGA-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP18B-SAT'
update homsomDB..Trv_Customizations set Code='HIS JGP-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='BCO-S'
update homsomDB..Trv_Customizations set Code='HST MEGA-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP17MP-W'
update homsomDB..Trv_Customizations set Code='BCO06-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP17GMP-W'
update homsomDB..Trv_Customizations set Code='BCO07-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMPGMP-S'
update homsomDB..Trv_Customizations set Code='BCO08-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='SGI07-W'
update homsomDB..Trv_Customizations set Code='BCO08-SAT' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='FOX-GL'
update homsomDB..Trv_Customizations set Code='Brazil-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='ANT-S'
update homsomDB..Trv_Customizations set Code='SGI07-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='CPI-S'
update homsomDB..Trv_Customizations set Code='SGI-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='MPS-S'
update homsomDB..Trv_Customizations set Code='ACI-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='TPN-W'
update homsomDB..Trv_Customizations set Code='TPI FXLH-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP-S'
update homsomDB..Trv_Customizations set Code='TPI21-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP18MP-SAT'
update homsomDB..Trv_Customizations set Code='TPI22-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='HST-S'
update homsomDB..Trv_Customizations set Code='TPI24-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP18GMP-SAT'
update homsomDB..Trv_Customizations set Code='TPI25-SAT' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='HSB-S'
update homsomDB..Trv_Customizations set Code='TPI QSMC-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='BCO-W'
update homsomDB..Trv_Customizations set Code='TPI FXCD-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='STO-S'
update homsomDB..Trv_Customizations set Code='TPI SUNREX-SAT' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP18MP-W'
update homsomDB..Trv_Customizations set Code='TPN05-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMPMP-S'
update homsomDB..Trv_Customizations set Code='HNI-S-China' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='Brazil-S'
update homsomDB..Trv_Customizations set Code='UMPG-S-China' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='HNI-S'
update homsomDB..Trv_Customizations set Code='UMP18MP-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP-Conversion'
update homsomDB..Trv_Customizations set Code='UMP18GMP-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP19B-SAT'
update homsomDB..Trv_Customizations set Code='UMP19MP-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='HIS-S'
update homsomDB..Trv_Customizations set Code='UMP19-SAT' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='BCO'
update homsomDB..Trv_Customizations set Code='UMP19-Conversion' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='UMP19B-Conversion'
update homsomDB..Trv_Customizations set Code='UMP19GMP-SAT' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='TFH-SAT'
update homsomDB..Trv_Customizations set Code='UMP19GMP-W' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='TFH-W'
update homsomDB..Trv_Customizations set Code='UMP19GMP-S' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='TFH-S'
update homsomDB..Trv_Customizations set Code='UMP-S-China' where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code='SGI-S'


--删除多余行
delete from homsomDB..Trv_Customizations 
where UnitCompanyID in  (SELECT ID FROM homsomDB..Trv_UnitCompanies WHERE Cmpid='019333') and Code in('ACI-S',
'Warehouse',
'UMP18B-W',
'India-S',
'UMP18GMP-W',
'UMP19MP',
'office')

