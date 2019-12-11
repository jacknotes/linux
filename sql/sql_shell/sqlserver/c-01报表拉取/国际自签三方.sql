/*
提取国际自签三方，产品系统中维护的三方协议后信息，谢谢
 
  报表格式：  UC号、单位名称、航司2字码 、三方协议号中的内容 
*/

select t.CmpId,un.Name,AirCompany,SfxyInfo from ehomsom..tbCompanyXY t
left join homsomDB..Trv_UnitCompanies  un on t.CmpId=un.Cmpid
where t.Type=2 --国际
and IsSelfRv=1 --自签