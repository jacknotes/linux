select TicketOperationRemark,* 
from homsomDB..Trv_DomesticTicketRecord
where RecordNumber in (Select coupno from tbcash where coupno in ('AS001453417'))

update homsomDB..Trv_DomesticTicketRecord set TicketOperationRemark='' where RecordNumber in (Select coupno from tbcash where coupno in ('AS001453417'))