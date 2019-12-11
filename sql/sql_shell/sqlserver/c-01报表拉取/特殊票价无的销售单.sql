/*
UC017888 出票日期2019年4月1号至2019年4月22号，国内机票中特殊票价是无的销售单号请拉出来，具体数据如下：
 
出票日期， 电子销售单号 销售单类型 供应商来源 PNR 票号  乘客姓名 航程  舱位  销售单价 税收 销售利润 销售价 服务费 
*/
select baoxiaopz,* from Topway..tbcash 
where cmpcode='017888'
and datetime>='2019-04-01'
and baoxiaopz=0 --特殊票价无
and inf=0