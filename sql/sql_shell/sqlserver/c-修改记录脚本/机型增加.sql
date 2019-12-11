--新增机型
--2019-03-20
--select * from ehomsom..tbPlanetype where aname='B738'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('132','波音','737系列','787','b738','162-189','窄体')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('133','空客','A320系列','A320','A320','123-180','窄体')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('134','空客','A320系列','A320','A320_186','123-180','窄体')

--2019-03-21
--机型新增
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('135','空客','A320系列','A320','JET100','123-180','窄体')
select ltype,* from ehomsom..tbPlanetype 
--update ehomsom..tbPlanetype set ltype=737
where aname='B738'

select aname,* from ehomsom..tbPlanetype 
--update ehomsom..tbPlanetype set aname='B738'
where aname='B738'

--2019-03-29
--select * from ehomsom..tbPlanetype where   aname='78B'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('138','波音','787系列','787','78B','210-290','宽体')