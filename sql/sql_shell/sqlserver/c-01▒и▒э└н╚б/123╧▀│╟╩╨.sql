 SELECT c.Name,* from homsomDB..Trv_CityClassifieds_CitiyHotels f
   LEFT JOIN homsomDB..Trv_CityHotels c ON f.ID=c.ID
   WHERE CityClassifiedID='2CC4710B-E51D-4E06-B900-A62800C3F7EE'--
   /*
   EF2B7AA3-A4E6-4599-9DE0-A62800C3F7EE  һ�߳���
4A1AFB3A-C99E-4F23-9F18-A62800C3F7EE ���߳���
2CC4710B-E51D-4E06-B900-A62800C3F7EE ���߳���
   */