/*
 Navicat Premium Data Transfer

 Source Server         : opsmysql
 Source Server Type    : MySQL
 Source Server Version : 50731
 Source Host           : mysql.hs.com:3306
 Source Schema         : ops

 Target Server Type    : MySQL
 Target Server Version : 50731
 File Encoding         : 65001

 Date: 15/07/2021 14:18:56
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for virtualmachine
-- ----------------------------
DROP TABLE IF EXISTS `virtualmachine`;
CREATE TABLE `virtualmachine`  (
  `Id` int(10) NOT NULL AUTO_INCREMENT,
  `MachineName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '机器名称',
  `MachineModel` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '机器型号',
  `ServiceNumber` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '服务编号',
  `QuickServiceCode` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '快速服务代码',
  `Rack` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属机柜',
  `ManagerPort` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理端口',
  `ManagerIP` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理IP',
  `ManagerIPVlan` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理IP所属VLAN',
  `ManagerUser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理用户',
  `ManagerPassword` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理密码',
  `RAIDType` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '陈列类型',
  `DiskType` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘类型',
  `DiskFormat` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘规格',
  `DiskBusType` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘总线类型',
  `DiskCapacity` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘容量',
  `DiskNumber` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘数量',
  `DiskTransferSpeed` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘传输速率',
  `DiskManufacturer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '硬盘厂商',
  `IDRACVersion` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'IDRAC版本',
  `MemoryModel` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内存型号',
  `MemoryFrequency` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内存频率',
  `MemorySize` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内存大小',
  `MemoryNumber` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '内存数量',
  `CPUModel` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'CPU型号',
  `CPUNumber` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'CPU颗数',
  `updatetime` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of virtualmachine
-- ----------------------------
INSERT INTO `virtualmachine` VALUES (2, 'XEN05', 'R710', '8HNHD3X', '18481624989', 'RACK6', 'Port1', '192.168.0.201', '30', 'root', 'calvin', 'RAID-5', 'HDD', '3.5', 'SAS', '300GB', '4', '6Gbps', 'SEAGATE', '6', 'DDR-3', '1333MHz', '16G', '4', 'Xeon X5650', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (4, 'XEN08', 'R720', '3BQ3G42', '7239305810', 'RACK6', 'Port1', '192.168.0.202', '30', 'root', 'calvin', 'RAID-5', 'HDD', '3.5', 'SAS', '600GB', '6+1', '6Gbps', 'SEAGATE', '7', 'DDR-3', '1600MHz', '16G', '4', 'Xeon E5-2650 ', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (6, 'XEN03', 'R720', 'F15PMZ1', '32721795469', 'RACK6', 'Port1', '192.168.0.203', '30', 'root', 'calvin', 'RAID-10', 'HDD', '2.5/3.5', 'SAS', '600GB', '6', '6Gbps', 'SEAGATE&HITACH', '7', 'DDR-3', '1333MHz', '16G+8G', '4+2', 'Xeon E5-2650 ', '1', '2021-07-15 14:16:53');
INSERT INTO `virtualmachine` VALUES (8, 'XEN02', 'R720', '415PMZ1', '8777189773', 'RACK5', 'Port1', '192.168.0.204', '30', 'root', 'calvin', 'RAID-50', 'HDD', '2.5/3.5', 'SAS', '600GB', '6', '6Gbps', 'SEAGATE&HITACH', '7', 'DDR-3', '1333MHz', '4G', '12', 'Xeon E5-2650 ', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (10, 'XEN06', 'R720', 'DS65F22', '30001553786', 'RACK6', 'Port1', '192.168.0.205', '30', 'root', 'calvin', 'RAID-1&RAID-5', 'HDD', '3.5', 'SAS', '146GB&600GB', '2&4', '3Gbps&6Gbps', 'SEAGATE&HITACH', '7', 'DDR-3', '1333MHz', '16G', '4', 'Xeon E5-2650 ', '1', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (12, 'XEN09', 'R730', 'H3G52M2', '37213808762', 'RACK6', 'PortIDRAC', '192.168.0.206', '30', 'root', 'calvin', 'RAID-5', 'HDD', '3.5', 'SAS', '2000GB', '8', '6Gbps', 'ATA', '8', 'DDR-4', '2133MHz', '16G', '4', 'Xeon E5-2620 ', '1', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (14, 'SQLSERVER107', 'R720', 'D0W8Q52', '28352325206', 'RACK5', 'Port1', '192.168.0.207', '30', 'root', 'calvin', 'RAID-10', 'HDD', '3.5', 'SAS', '600GB&300GB', '4', '6Gbps', 'SEAGATE&TOSHIBA', '7', 'DDR-3', '1600MHz', '16G', '4', 'Xeon E5-2630 ', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (16, 'SQLSERVER108', 'R720', 'C6G8Q52', '26511466070', 'RACK5', 'Port1', '192.168.0.208', '30', 'root', 'calvin', 'RAID-10', 'HDD', '3.5', 'SAS', '300GB', '4+1', '6Gbps', 'SEAGATE', '7', 'DDR-3', '1600MHz', '16G', '4', 'Xeon E5-2630 ', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (18, 'XEN07', 'R730', 'CJX5YK2', '27325950770', 'RACK5', 'PortIDRAC', '192.168.0.209', '30', 'root', 'calvin', 'RAID-10', 'HDD', '2.5', 'SAS', '300GB', '8', '12Gbps', 'SEAGATE', '8', 'DDR-4', '2133MHz', '16G', '4', 'Xeon E5-2680 ', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (20, 'XEN10', 'R740', '1R3JJ23', '3815319099', 'RACK5', 'PortIDRAC', '192.168.0.210', '30', 'root', 'password@calvin', 'RAID-5', 'SSD', '2.5', 'SATA', '480GB', '5', '6Gbps', 'MICRON', '9', 'DDR-4', '2400MHz', '16G', '4', 'Xeon Silver-4100', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (22, '192.168.13.229', 'R440', '1GYHYW2', '3202186466', 'RACK5', 'PortIDRAC', '192.168.0.211', '30', 'root', 'password@calvin', 'RAID-10', 'HDD', '2.5', 'SAS', '1200GB', '4', '12Gbps', 'HGST', '9', 'DDR-4', '2133MHz', '8G', '2', 'Xeon Bronze-3106', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (24, '192.168.13.228', 'R440', 'GCC1ST2', '35574350870', 'RACK5', 'PortIDRAC', '192.168.0.212', '30', 'root', 'password@calvin', 'RAID-1', 'SSD', '2.5', 'SATA', '480GB', '2', '6Gbps', 'ATA', '9', 'DDR-4', '2133MHz', '8G', '2', 'Xeon Bronze-3104', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (26, '192.168.13.160', 'R440', '8LSG5T2', '18731831654', 'RACK5', 'PortIDRAC', '192.168.0.213', '30', 'root', 'password@calvin', 'RAID-1', 'SSD', '2.5', 'SATA', '480GB', '2', '6Gbps', 'ATA', '9', 'DDR-4', '2133MHz', '8G', '2', 'Xeon Bronze-3104', '2', '2021-07-15 14:09:31');
INSERT INTO `virtualmachine` VALUES (28, 'ESXI01', 'R740', '81RT393', '17521431735', 'RACK5', 'PortIDRAC', '192.168.0.214', '30', 'root', 'password@calvin', 'RAID-5', 'SSD', '2.5', 'SATA', '480GB', '5', '6Gbps', 'MICRON', '9', 'DDR-4', '2400MHz', '32G', '2', 'Xeon Silver-4210R', '2', '2021-07-15 14:09:31');

SET FOREIGN_KEY_CHECKS = 1;
