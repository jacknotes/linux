
select fiveno from tbFiveCoupInfo where CoupNo='AS001566210'

select * from tbFiveCoupInfosub where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS000434501')

update tbFiveCoupInfosub set MobileList=',,,,,,,,,',CostCenter=',,,,,,,,,',pcs='10',Department='��,��,��,��,��,��,��,��,��,��' where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS001936182')

update tbFiveCoupInfosub set MobileList=',,,,,,,,,,,,,,,,,,,',CostCenter=',,,,,,,,,,,,,,,,,,,',pcs='20',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS001693598')

update tbFiveCoupInfosub set MobileList=',,,,,,,,,,,,,,,,,,,,,,,,,,,,,',CostCenter=',,,,,,,,,,,,,,,,,,,,,,,,,,,,,',pcs='30',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS001621954')

update tbFiveCoupInfosub set MobileList=',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',CostCenter=',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',pcs='40',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS001478879')

update tbFiveCoupInfosub set MobileList=',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',CostCenter=',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',pcs='50',Department='��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��,��' where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS001478879')
