--TMS���ÿ�
--��ȡ���ÿ���Ϣ
IF OBJECT_ID('tempdb.dbo.#p') IS NOT NULL DROP TABLE #p
select uc.cmpid,uc.Name as cmpname,h.name,LastName+'/'+firstname+' '+MiddleName as ename,cr.Type,cr.CredentialNo,h.NationID
into #p
from Trv_UnitPersons up
left join Trv_Human h on h.ID=up.ID
left join Trv_Credentials cr on cr.HumanID=h.ID
left join Trv_UnitCompanies uc on uc.ID=up.CompanyID
where --(h.CreateDate>='2018-05-13' and h.CreateDate<'2018-06-13')
--uc.CooperativeStatus in('1','2','3') and
 uc.Cmpid in ('018463',
'019885',
'018781',
'016477',
'018773',
'016602',
'019294',
'020113',
'016608',
'016689',
'020064',
'019361',
'017205',
'020016',
'018643',
'017739',
'018431',
'019688',
'019321',
'016497',
'017275',
'016426',
'016773',
'019259',
'019799',
'017210',
'019848',
'016402',
'020027')
--and  h.NationID='108D4176-167A-4B6D-8A2A-20EE2B1842EF'
  and IsDisplay=1 
--and cr.Type in (1,2)

select * from #p p

--��Ӣ������ֵ��������
update #p set name=ename where name=''
/*/// <summary>
        /// There are no comments for CredentialTypeOptions.���֤ in the schema.
        /// </summary>
        [EnumMember]
        ���֤ = 1,         
        ���� = 2,           
        ѧ��֤ = 3,          
        ����֤ = 4,          
        ����֤ = 5,          
        ��������þ���֤ = 6,          
        �۰�ͨ��֤ = 7,           
        ̨��ͨ��֤ = 8,           
        ���ʺ�Ա֤ = 9,          
        ̨��֤ = 10,           
        ���� = 11
*/
--���֤��
IF OBJECT_ID('tempdb.dbo.#sfz') IS NOT NULL DROP TABLE #sfz
select * 
into #sfz
from #p p
where type=1
--���ձ�
IF OBJECT_ID('tempdb.dbo.#hz') IS NOT NULL DROP TABLE #hz
select * 
into #hz
from #p p
where type=2
--ѧ��֤
IF OBJECT_ID('tempdb.dbo.#xsz') IS NOT NULL DROP TABLE #xsz
select * 
into #xsz
from #p p
where type=3
--����֤ = 4
IF OBJECT_ID('tempdb.dbo.#jrz') IS NOT NULL DROP TABLE #jrz
select * 
into #jrz
from #p p
where type=4
--����֤=5
IF OBJECT_ID('tempdb.dbo.#hxz') IS NOT NULL DROP TABLE #hxz
select * 
into #hxz
from #p p
where type=5
--��������þ���֤ = 6
IF OBJECT_ID('tempdb.dbo.#yjjz') IS NOT NULL DROP TABLE #yjjz
select * 
into #yjjz
from #p p
where type=6
--�۰�ͨ��֤ = 7
IF OBJECT_ID('tempdb.dbo.#gaz') IS NOT NULL DROP TABLE #gaz
select * 
into #gaz
from #p p
where type=7
--̨��ͨ��֤ = 8
IF OBJECT_ID('tempdb.dbo.#twz') IS NOT NULL DROP TABLE #twz
select * 
into #twz
from #p p
where type=8
--���ʺ�Ա֤ = 9
IF OBJECT_ID('tempdb.dbo.#hyz') IS NOT NULL DROP TABLE #hyz
select * 
into #hyz
from #p p
where type=9
--̨��֤ = 10
IF OBJECT_ID('tempdb.dbo.#tbz') IS NOT NULL DROP TABLE #tbz
select * 
into #tbz
from #p p
where type=10
--���� = 11
IF OBJECT_ID('tempdb.dbo.#qtz') IS NOT NULL DROP TABLE #qtz
select * 
into #qtz
from #p p
where type=11
--���ձ�
IF OBJECT_ID('tempdb.dbo.#p1') IS NOT NULL DROP TABLE #p1 
select p.cmpid as ��λ���,p.cmpname,p.name ,ISNULL(p.ename,'') as Ӣ����,ISNULL(sfz.credentialno,'') as ���֤,ISNULL(hz.credentialno,'') as ���� ,ISNULL(xsz.credentialno,'') as ѧ��֤,
ISNULL(jrz.credentialno,'') as ����֤,ISNULL(hxz.credentialno,'') as ����֤,ISNULL(yjjz.credentialno,'') as ��������þ���֤,ISNULL(gaz.credentialno,'') as �۰�ͨ��֤,ISNULL(twz.credentialno,'') as ̨��ͨ��֤,
ISNULL(hyz.credentialno,'') as ��Ա֤, ISNULL(tbz.credentialno,'') as ̨��֤, ISNULL(qtz.credentialno,'') as ����
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