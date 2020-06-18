--TMS常旅客
--拉取常旅客信息
IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
select uc.cmpid,uc.Name as cmpname,h.name,(isnull(LastName,'')+'/'+isnull(firstname,'')+' '+isnull(MiddleName,'')) as ename,cr.Type,cr.CredentialNo,h.NationID
--into #p
from Trv_UnitPersons up
left join Trv_Human h on h.ID=up.ID
left join Trv_Credentials cr on cr.HumanID=h.ID
left join Trv_UnitCompanies uc on uc.ID=up.CompanyID
where --(h.CreateDate>='2018-05-13' and h.CreateDate<'2018-06-13')
uc.CooperativeStatus in('1','2','3')
--and uc.Cmpid in ('017947','018766','018131')
--and  h.NationID='108D4176-167A-4B6D-8A2A-20EE2B1842EF'
  and IsDisplay=1 
--and cr.Type in (1,2)

select * from #p p

--将英文名赋值到中文名
update #p set name=ename where name=''
/*/// <summary>
        /// There are no comments for CredentialTypeOptions.身份证 in the schema.
        /// </summary>
        [EnumMember]
        身份证 = 1,         
        护照 = 2,           
        学生证 = 3,          
        军人证 = 4,          
        回乡证 = 5,          
        外国人永久居留证 = 6,          
        港澳通行证 = 7,           
        台湾通行证 = 8,           
        国际海员证 = 9,          
        台胞证 = 10,           
        其他 = 11
*/
--身份证表
IF OBJECT_ID('tempdb.dbo.#sfz') IS NOT NULL DROP TABLE #sfz
select * 
into #sfz
from #p p
where type=1
--护照表
IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select * 
into #hz
from #p p
where type=2
--学生证
IF OBJECT_ID('tempdb.dbo.#xsz') IS NOT NULL DROP TABLE #xsz
select * 
into #xsz
from #p p
where type=3
--军人证 = 4
IF OBJECT_ID('tempdb.dbo.#jrz') IS NOT NULL DROP TABLE #jrz
select * 
into #jrz
from #p p
where type=4
--回乡证=5
IF OBJECT_ID('tempdb.dbo.#hxz') IS NOT NULL DROP TABLE #hxz
select * 
into #hxz
from #p p
where type=5
--外国人永久居留证 = 6
IF OBJECT_ID('tempdb.dbo.#yjjz') IS NOT NULL DROP TABLE #yjjz
select * 
into #yjjz
from #p p
where type=6
--港澳通行证 = 7
IF OBJECT_ID('tempdb.dbo.#gaz') IS NOT NULL DROP TABLE #gaz
select * 
into #gaz
from #p p
where type=7
--台湾通行证 = 8
IF OBJECT_ID('tempdb.dbo.#twz') IS NOT NULL DROP TABLE #twz
select * 
into #twz
from #p p
where type=8
--国际海员证 = 9
IF OBJECT_ID('tempdb.dbo.#hyz') IS NOT NULL DROP TABLE #hyz
select * 
into #hyz
from #p p
where type=9
--台胞证 = 10
IF OBJECT_ID('tempdb.dbo.#tbz') IS NOT NULL DROP TABLE #tbz
select * 
into #tbz
from #p p
where type=10
--其他 = 11
IF OBJECT_ID('tempdb.dbo.#qtz') IS NOT NULL DROP TABLE #qtz
select * 
into #qtz
from #p p
where type=11
--最终表
IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1 
select p.cmpid as 单位编号,p.cmpname as 单位名称,p.name ,p.ename as 英文名,sfz.credentialno as 身份证,hz.credentialno as 护照 ,xsz.credentialno as 学生证,
jrz.credentialno as 军人证,hxz.credentialno as 回乡证,yjjz.credentialno as 外国人永久居留证,gaz.credentialno as 港澳通行证,twz.credentialno as 台湾通行证,
hyz.credentialno as 海员证, tbz.credentialno as 台胞证, qtz.credentialno as 其他
into #p1
from #p p
left join #sfz sfz on sfz.cmpid=p.cmpid and sfz.name=p.name and sfz.credentialno=p.credentialno
left join #hz hz on hz.cmpid=p.cmpid and hz.name=p.name and hz.credentialno=p.credentialno
left join #xsz xsz on xsz.cmpid=p.cmpid and xsz.name=p.name and xsz.credentialno=p.credentialno
left join #jrz jrz on jrz.cmpid=p.cmpid and jrz.name=p.name and jrz.credentialno=p.credentialno
left join #hxz hxz on hxz.cmpid=p.cmpid and hxz.name=p.name and hxz.credentialno=p.credentialno
left join #yjjz yjjz on yjjz.cmpid=p.cmpid and yjjz.name=p.name and yjjz.credentialno=p.credentialno
left join #gaz gaz on gaz.cmpid=p.cmpid and gaz.name=p.name and gaz.credentialno=p.credentialno
left join #twz twz on twz.cmpid=p.cmpid and twz.name=p.name and twz.credentialno=p.credentialno
left join #hyz hyz on hyz.cmpid=p.cmpid and hyz.name=p.name and hyz.credentialno=p.credentialno
left join #tbz tbz on tbz.cmpid=p.cmpid and tbz.name=p.name and tbz.credentialno=p.credentialno
left join #qtz qtz on qtz.cmpid=p.cmpid and qtz.name=p.name and qtz.credentialno=p.credentialno

select * from #p1

--2018年1月1日-2019年1月9日出过票的名单
--匹配
select 单位编号,单位名称,name,英文名,身份证,护照
from #p1 v1
left join Topway..V_TicketInfo v on v.pasname=v1.name and v.cmpcode=v1.单位编号
where  v.datetime>='2018-01-01' and v.datetime<'2019-01-01'
--消费数据
select c.cmpcode,t.cmpname,pasname,idno from Topway..tbcash c
left join Topway..tbCompanyM t on t.cmpid=c.cmpcode
where c.datetime>='2018-01-01' and c.datetime<'2019-01-01' and c.cmpcode<>'00003'

--账单撤销

select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState='1'
where CompanyCode='019948 ' and BillNumber='019948_20181201'

--拉取退票信息（冒退票）
select c.tcode+c.ticketno as 票号,c.coupno as 销售单号,c.t_source as 供应商来源,r.reno as 退票单号,
r.edatetime as 提交日期,r.ExamineDate as 审核日期,r.scount2 as 航空公司退票费,r.rtprice as 收客户退票金额,r.info as 备注
from Topway..tbReti r
left join Topway..tbcash c on c.reti=r.reno
where ExamineDate>='2018-12-24' and ExamineDate<'2019-01-07' and r.info='冒退票'

--结算价差额

select totsprice,profit from Topway..tbcash 
--update Topway..tbcash set totsprice='8475',profit='265'
where coupno='AS002194953'