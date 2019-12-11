SELECT SX_BaseCreditLine,SX_TomporaryCreditLine, SX_TotalCreditLine
FROM Topway..AccountStatement
--update Topway..AccountStatement set SX_BaseCreditLine=60000,SX_TomporaryCreditLine=60000,SX_TotalCreditLine=60000
WHERE (CompanyCode = '017865') and BillNumber='017865_20181201'