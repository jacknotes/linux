--��������
--2019-03-20
--select * from ehomsom..tbPlanetype where aname='B738'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('132','����','737ϵ��','787','b738','162-189','խ��')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('133','�տ�','A320ϵ��','A320','A320','123-180','խ��')
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('134','�տ�','A320ϵ��','A320','A320_186','123-180','խ��')

--2019-03-21
--��������
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('135','�տ�','A320ϵ��','A320','JET100','123-180','խ��')
select ltype,* from ehomsom..tbPlanetype 
--update ehomsom..tbPlanetype set ltype=737
where aname='B738'

select aname,* from ehomsom..tbPlanetype 
--update ehomsom..tbPlanetype set aname='B738'
where aname='B738'

--2019-03-29
--select * from ehomsom..tbPlanetype where   aname='78B'
insert into ehomsom..tbPlanetype (id,manufacturer,btype,ltype,aname,maxseat,intro) values ('138','����','787ϵ��','787','78B','210-290','����')