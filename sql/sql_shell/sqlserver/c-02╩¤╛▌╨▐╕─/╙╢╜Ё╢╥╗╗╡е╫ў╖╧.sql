select * from tbcash where syjpriceinfo in (74510)
update tbcash set syjpriceinfo='',syjprice='0' where syjpriceinfo in (74510)

select * from tbReti where syjpriceinfo in (74510)
update tbReti set syjpriceinfo='',syjprice='0' where syjpriceinfo in (74510)

select * from tbExchangeCommission where id in (72158)
update tbExchangeCommission set CommissionStatus='4' where id in (74510)
