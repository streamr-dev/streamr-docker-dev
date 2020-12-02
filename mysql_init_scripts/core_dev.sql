USE core_dev;
-- MySQL dump 10.13  Distrib 5.7.21, for macos10.13 (x86_64)
--
-- Host: 127.0.0.1    Database: core_dev
-- ------------------------------------------------------
-- Server version	5.7.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `canvas`
--

DROP TABLE IF EXISTS `canvas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `canvas` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `adhoc` bit(1) NOT NULL,
  `date_created` datetime NOT NULL,
  `has_exports` bit(1) NOT NULL,
  `json` longtext NOT NULL,
  `last_updated` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `request_url` varchar(255) DEFAULT NULL,
  `runner` varchar(255) DEFAULT NULL,
  `server` varchar(255) DEFAULT NULL,
  `state` varchar(255) NOT NULL,
  `serialization_id` bigint(20) DEFAULT NULL,
  `started_by_id` bigint(20) DEFAULT NULL,
  `example_type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `serialization_id` (`serialization_id`),
  UNIQUE KEY `serialization_id_uniq_1484920841951` (`serialization_id`),
  KEY `runner_idx` (`runner`),
  KEY `FKAE7A755835F2A96E` (`serialization_id`),
  KEY `started_by_id_idx` (`started_by_id`),
  KEY `example_type_idx` (`example_type`),
  CONSTRAINT `FKAE7A755835F2A96E` FOREIGN KEY (`serialization_id`) REFERENCES `serialization` (`id`),
  CONSTRAINT `FKAE7A7558BA6E1FE8` FOREIGN KEY (`started_by_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canvas`
--

LOCK TABLES `canvas` WRITE;
/*!40000 ALTER TABLE `canvas` DISABLE KEYS */;
/*!40000 ALTER TABLE `canvas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `id` varchar(255) NOT NULL,
  `image_url` varchar(2048) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES ('advertising',NULL,'Advertising'),('business-intelligence',NULL,'Business Intelligence'),('communications',NULL,'Communications'),('crypto',NULL,'Crypto'),('energy',NULL,'Energy'),('entertainment',NULL,'Entertainment'),('environment',NULL,'Environment'),('finance',NULL,'Finance'),('health',NULL,'Health'),('industrial',NULL,'Industrial'),('iot',NULL,'IoT'),('other',NULL,'Other'),('retail',NULL,'Retail'),('smart-cities',NULL,'Smart Cities'),('social-media',NULL,'Social Media'),('sports',NULL,'Sports'),('transportation',NULL,'Transportation'),('weather',NULL,'Weather');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard`
--

DROP TABLE IF EXISTS `dashboard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `layout` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard`
--

LOCK TABLES `dashboard` WRITE;
/*!40000 ALTER TABLE `dashboard` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_item`
--

DROP TABLE IF EXISTS `dashboard_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_item` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `dashboard_id` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `canvas_id` varchar(255) NOT NULL,
  `module` int(11) NOT NULL,
  `webcomponent` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKF4B0C5DE3D649786` (`canvas_id`),
  KEY `fk_dashboard_item_dashboard_id` (`dashboard_id`),
  CONSTRAINT `FKF4B0C5DE3D649786` FOREIGN KEY (`canvas_id`) REFERENCES `canvas` (`id`),
  CONSTRAINT `fk_dashboard_item_dashboard_id` FOREIGN KEY (`dashboard_id`) REFERENCES `dashboard` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_item`
--

LOCK TABLES `dashboard_item` WRITE;
/*!40000 ALTER TABLE `dashboard_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_union_join_request`
--

DROP TABLE IF EXISTS `data_union_join_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_union_join_request` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `contract_address` varchar(255) NOT NULL DEFAULT '',
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `member_address` varchar(255) NOT NULL,
  `state` int(11) NOT NULL DEFAULT '0',
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_idx` (`user_id`),
  KEY `state_idx` (`state`),
  CONSTRAINT `joinreq_user_idx` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_union_join_request`
--

LOCK TABLES `data_union_join_request` WRITE;
/*!40000 ALTER TABLE `data_union_join_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_union_join_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_union_secret`
--

DROP TABLE IF EXISTS `data_union_secret`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_union_secret` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `contract_address` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL,
  `secret` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_union_secret`
--

LOCK TABLES `data_union_secret` WRITE;
/*!40000 ALTER TABLE `data_union_secret` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_union_secret` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `databasechangelog`
--

DROP TABLE IF EXISTS `databasechangelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `databasechangelog` (
  `ID` varchar(63) NOT NULL,
  `AUTHOR` varchar(63) NOT NULL,
  `FILENAME` varchar(200) NOT NULL,
  `DATEEXECUTED` datetime NOT NULL,
  `ORDEREXECUTED` int(11) NOT NULL,
  `EXECTYPE` varchar(10) NOT NULL,
  `MD5SUM` varchar(35) DEFAULT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `COMMENTS` varchar(255) DEFAULT NULL,
  `TAG` varchar(255) DEFAULT NULL,
  `LIQUIBASE` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID`,`AUTHOR`,`FILENAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `databasechangelog`
--

LOCK TABLES `databasechangelog` WRITE;
/*!40000 ALTER TABLE `databasechangelog` DISABLE KEYS */;
/*!40000 ALTER TABLE `databasechangelog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `databasechangeloglock`
--

DROP TABLE IF EXISTS `databasechangeloglock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `databasechangeloglock` (
  `ID` int(11) NOT NULL,
  `LOCKED` tinyint(1) NOT NULL,
  `LOCKGRANTED` datetime DEFAULT NULL,
  `LOCKEDBY` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `databasechangeloglock`
--

LOCK TABLES `databasechangeloglock` WRITE;
/*!40000 ALTER TABLE `databasechangeloglock` DISABLE KEYS */;
INSERT INTO `databasechangeloglock` VALUES (1,0,NULL,NULL);
/*!40000 ALTER TABLE `databasechangeloglock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `host_config`
--

DROP TABLE IF EXISTS `host_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `host_config` (
  `host` varchar(255) NOT NULL,
  `parameter` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`host`,`parameter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `host_config`
--

LOCK TABLES `host_config` WRITE;
/*!40000 ALTER TABLE `host_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `host_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integration_key`
--

DROP TABLE IF EXISTS `integration_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `integration_key` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `json` longtext NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `service` varchar(255) NOT NULL,
  `id_in_service` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_in_service_uniq_1559553159638` (`id_in_service`),
  KEY `fk_user_integration_key` (`user_id`),
  KEY `id_in_service_and_service_idx` (`id_in_service`,`service`),
  CONSTRAINT `fk_user_integration_key` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integration_key`
--

LOCK TABLES `integration_key` WRITE;
/*!40000 ALTER TABLE `integration_key` DISABLE KEYS */;
INSERT INTO `integration_key` VALUES ('0ptV-cx7SieVhghnaBv12QlrLICgz5SUiHCShQvd83Zg',0,'Converted from API key: Generated','2020-11-23 23:00:46','2020-11-23 23:00:46','{\"address\":\"0x605fecc0053f7cf08aeb5ad0a14d6456840fd0d9\"}',5,'ETHEREUM_ID','0x605fecc0053f7cf08aeb5ad0a14d6456840fd0d9'),('mAQzRmqcTw6i12vcY1tIoguHSJKKztQD6cSn_6VWZqVw',0,'Converted from API key: Default','2020-11-23 23:00:46','2020-11-23 23:00:46','{\"address\":\"0x0f6e10214b8e6c9c2e244ad25607a427ed275ea4\"}',2,'ETHEREUM_ID','0x0f6e10214b8e6c9c2e244ad25607a427ed275ea4'),('mhKYdXiHRB6Oqz6kbgfokwVpZupmczQmmdSGKdwntxng',0,'Converted from API key: Generated','2020-11-23 23:00:46','2020-11-23 23:00:46','{\"address\":\"0x8ee4945ee4b51af308fd9b87c9bfc9b309a1ef5c\"}',4,'ETHEREUM_ID','0x8ee4945ee4b51af308fd9b87c9bfc9b309a1ef5c'),('seLkRwaMQl62XR8urnHXEwEb85Xb1jRZOXG8nLV5IDpQ',0,'Converted from API key: Default','2020-11-23 23:00:46','2020-11-23 23:00:46','{\"address\":\"0xb3a3eefdffb19c155928eb41a18b0c12b07d7cde\"}',3,'ETHEREUM_ID','0xb3a3eefdffb19c155928eb41a18b0c12b07d7cde'),('_Lg-qrxnRkaxJu5tfDxzowTIxCdAA1QnS9-UGTzKd54Q',0,'Converted from API key: Default','2020-11-23 23:00:46','2020-11-23 23:00:46','{\"address\":\"0xadb88a496199365b69b2a12816b6b6bba27cc4c1\"}',1,'ETHEREUM_ID','0xadb88a496199365b69b2a12816b6b6bba27cc4c1');
/*!40000 ALTER TABLE `integration_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `module`
--

DROP TABLE IF EXISTS `module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `module` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `implementing_class` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `js_module` varchar(255) NOT NULL,
  `hide` bit(1) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `json_help` longtext,
  `alternative_names` varchar(255) DEFAULT NULL,
  `webcomponent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKC04BA66C28AB0672` (`category_id`),
  CONSTRAINT `FKC04BA66C28AB0672` FOREIGN KEY (`category_id`) REFERENCES `module_category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6002 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `module`
--

LOCK TABLES `module` WRITE;
/*!40000 ALTER TABLE `module` DISABLE KEYS */;
INSERT INTO `module` VALUES (1,4,1,'com.unifina.signalpath.simplemath.Multiply','Multiply','GenericModule',NULL,'module','{\"outputNames\":[\"A*B\"],\"inputs\":{\"A\":\"The first value to be multiplied\",\"B\":\"The second value to be multiplied\"},\"helpText\":\"<p>This module calculates the product of two numeric input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A*B\":\"The product of the inputs\"},\"paramNames\":[]}','Times',NULL),(2,4,2,'com.unifina.signalpath.filtering.SimpleMovingAverageEvents','MovingAverage (old)','GenericModule','','module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module calculates the simple moving average (MA, SMA) of values arriving at the input. Each value is assigned equal weight. The moving average is calculated based on a sliding window of adjustable length.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of input values received before a value is output\",\"length\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\"},\"outputs\":{\"out\":\"The moving average\"},\"paramNames\":[\"length\",\"minSamples\"]}','SMA',NULL),(3,7,1,'com.unifina.signalpath.simplemath.Add','Add','GenericModule','','module','{\"outputNames\":[\"A+B\"],\"inputs\":{\"A\":\"First value to be added\",\"B\":\"Second value to be added\"},\"helpText\":\"<p>This module adds together two numeric input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A+B\":\"Sum of the two inputs\"},\"paramNames\":[]}','Plus',NULL),(4,4,1,'com.unifina.signalpath.simplemath.Subtract','Subtract','GenericModule',NULL,'module','{\"outputNames\":[\"A-B\"],\"inputs\":{\"A\":\"Value to subtract from\",\"B\":\"Value to be subtracted\"},\"helpText\":\"<p>This module calculates the difference of its two input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A-B\":\"The difference\"},\"paramNames\":[]}','Minus',NULL),(5,5,3,'com.unifina.signalpath.utils.Constant','Constant','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>This module represents a constant numeric value that can be connected to any numeric input. The input will have that value during the whole execution.</p>\",\"inputNames\":[],\"params\":{\"constant\":\"The value to output\"},\"outputs\":{\"out\":\"The value of the parameter\"},\"paramNames\":[\"constant\"]}','Number',NULL),(6,5,1,'com.unifina.signalpath.simplemath.Divide','Divide','GenericModule',NULL,'module','{\"outputNames\":[\"A/B\"],\"inputs\":{\"A\":\"The dividend, or numerator\",\"B\":\"The divisor, or denominator\"},\"helpText\":\"<p>This module calculates the quotient of its two input values. If the input <span class=\'highlight\'>B</span> is zero, the result is not defined and thus no output is produced.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A/B\":\"The quotient: A divided by B\"},\"paramNames\":[]}',NULL,NULL),(7,7,19,'com.unifina.signalpath.utils.Delay','Delay','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Incoming values to be delayed\"},\"helpText\":\"<p>This module will delay the received values by a number of events. For example, if the <span class=\'highlight\'> delayEvents</span> parameter is set to 1, the module will always output the previous value received.\\n</p><p>\\nThe module will not produce output until the <span class=\'highlight\'>delayEvents+1</span>th event, at which point the first received value will be output. For example, if the parameter is set to 2, the following sequence would be produced:\\n</p><p>\\n<table>\\n<tr><th>Input<\\/th><th>Output<\\/th><\\/tr>\\n<tr><td>1<\\/td><td>(no value)<\\/td><\\/tr>\\n<tr><td>2<\\/td><td>(no value)<\\/td><\\/tr>\\n<tr><td>3<\\/td><td>1<\\/td><\\/tr>\\n<tr><td>4<\\/td><td>2<\\/td><\\/tr>\\n<tr><td>...<\\/td><td>...<\\/td><\\/tr>\\n<\\/table></p>\",\"inputNames\":[\"in\"],\"params\":{\"delayEvents\":\"Number of events to delay the incoming values\"},\"outputs\":{\"out\":\"The delayed values\"},\"paramNames\":[\"delayEvents\"]}',NULL,NULL),(11,6,1,'com.unifina.signalpath.simplemath.ChangeAbsolute','ChangeAbsolute','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the difference between the received value and the previous received value, or <span class=\'highlight\'>in(t)&nbsp;-&nbsp;in(t-1)</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Difference',NULL),(16,6,19,'com.unifina.signalpath.utils.Barify','Barify','GenericModule',NULL,'module','{\"outputNames\":[\"open\",\"high\",\"low\",\"close\",\"avg\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This is a utility for moving from event time to wall-clock time. This module outputs new values every <span class=\'highlight\'>barLength</span> seconds. You would use this module to sample a time series every 60 seconds, for example.</p>\",\"inputNames\":[\"in\"],\"params\":{\"barLength\":\"Length of the bar (time interval) in seconds\"},\"outputs\":{\"open\":\"Value at start of period\",\"high\":\"Maximum value during period\",\"avg\":\"Simple average of values received during the period\",\"low\":\"Minimum value during period\",\"close\":\"Value at end of period (the most recent value)\"},\"paramNames\":[\"barLength\"]}','Time',NULL),(19,4,27,'com.unifina.signalpath.text.ConstantString','ConstantText','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>This module represents a constant text value that can be connected to any input that accepts text.</p>\",\"inputNames\":[],\"params\":{\"str\":\"The text constant\"},\"outputs\":{\"out\":\"Outputs the text constant\"},\"paramNames\":[\"str\"]}','TextConstant, ConstantString, StringConstant, String',NULL),(24,4,7,'com.unifina.signalpath.trigger.ZeroCross','ZeroCross','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module is used to detect when a time series crosses the zero line. It outputs -1 when below zero (minus threshold) and +1 when above zero (plus threshold).</p>\",\"inputNames\":[\"in\"],\"params\":{\"strictMode\":\"In strict mode, the incoming series actually needs to cross the trigger line before an output is produced. Otherwise a value is produced on the first event above or below the trigger line.\",\"threshold\":\"Zero or a positive value indicating the distance beyond zero that the incoming series must reach before a different output is triggered\"},\"outputs\":{\"out\":\"-1 or +1\"},\"paramNames\":[\"strictMode\",\"threshold\"]}',NULL,NULL),(25,4,7,'com.unifina.signalpath.trigger.ThreeZones','ThreeZones','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Incoming value\"},\"helpText\":\"<p>This module outputs -1, 0 or +1 depending on whether the input value is below <span class=\'highlight\'>lowZone</span>, between <span class=\'highlight\'>lowZone</span> and <span class=\'highlight\'>highZone</span>, or above <span class=\'highlight\'>highZone</span> respectively.</p>\",\"inputNames\":[\"in\"],\"params\":{\"highZone\":\"The high limit\",\"lowZone\":\"The low limit\"},\"outputs\":{\"out\":\"-1, 0 or +1 depending on which zone the input value is in\"},\"paramNames\":[\"highZone\",\"lowZone\"]}',NULL,NULL),(27,12,1,'com.unifina.signalpath.simplemath.Abs','Abs','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"The original value\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"The absolute value of the original value\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Outputs the absolute value (positive value with original sign stripped) of the input.</p>\\n\"}','Absolute',NULL),(28,5,1,'com.unifina.signalpath.simplemath.Negate','Negate','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the negated input value <span class=\'highlight\'>-1 * in</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Negation',NULL),(29,5,1,'com.unifina.signalpath.simplemath.Invert','Invert','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"<span></span>\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"<span></span>\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Outputs the multiplicative inverse (reciprocal) of the input (1/in, in^-1).</p>\"}','Reciprocal, Inverse',NULL),(30,5,10,'com.unifina.signalpath.bool.And','And','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Implements the boolean AND operation: outputs 1 if <span class=\'highlight\'>both</span> inputs equal 1, otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(31,4,10,'com.unifina.signalpath.bool.Or','Or','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Implements the boolean OR operation: outputs 1 if <span class=\'highlight\'>at least one</span> of the inputs equal 1, otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(32,4,10,'com.unifina.signalpath.bool.Not','Not','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Implements the boolean NOT operation: outputs 0 if the input equals 1, otherwise outputs 1.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(33,4,10,'com.unifina.signalpath.bool.SameSign','SameSign','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 0 unless both inputs have the same sign. If both inputs are positive, the output is 1. If both are negative, the output is -1.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(34,4,1,'com.unifina.signalpath.simplemath.Sign','Sign','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the sign of the input: -1 if the input is negative, 0 if the input is zero, and 1 if the input is positive.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(35,4,1,'com.unifina.signalpath.simplemath.ChangeRelative','ChangeRelative','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the received value divided by the previous received value, or <span class=\'highlight\'>in(t)&nbsp;/&nbsp;in(t-1)</span>. If the previous received value is zero, the result is undefined and no output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Return',NULL),(45,6,10,'com.unifina.signalpath.bool.Equals','Equals','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if the inputs are equal within the specified <span class=\'highlight\'>tolerance</span>, that is, if abs(A-B)&nbsp;&le;&nbsp;tolerance. Otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','=',NULL),(46,6,10,'com.unifina.signalpath.bool.GreaterThan','GreaterThan','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if <span class=\'highlight\'>A</span> is greater than <span class=\'highlight\'>B</span> (A&gt;B). If <span class=\'highlight\'>equality</span> is set to true, outputs 1 if A&ge;B. Otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','>',NULL),(47,4,10,'com.unifina.signalpath.bool.LessThan','LessThan','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if <span class=\'highlight\'>A</span> is less than <span class=\'highlight\'>B</span> (A&lt;B). If <span class=\'highlight\'>equality</span> is set to true, outputs 1 if A&le;B. Otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','<',NULL),(48,4,10,'com.unifina.signalpath.bool.IfThenElse','IfThenElse','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>If the value at the <span class=\'highlight\'>if</span> input is 1, then outputs the value present at the <span class=\'highlight\'>then</span> input. Otherwise outputs the value at <span class=\'highlight\'>else</span> input.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Condition',NULL),(49,5,7,'com.unifina.signalpath.trigger.PeakDetect','Peak','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input time series\"},\"helpText\":\"<p>Attempts to detect upward turns below <span class=\'highlight\'>lowZone</span> (outputs 1) and downward turns below <span class=\'highlight\'>highZone</span> (outputs -1).\\n</p><p>\\nFor an upward turn to be registered, the change between subsequent input values must be larger than <span class=\'highlight\'>threshold</span>. For a downward turn the change must be less than <span class=\'highlight\'>-threshold</span>.</p>\",\"inputNames\":[\"in\"],\"params\":{\"highZone\":\"The level above which a downward turn can occur\",\"lowZone\":\"The level below which an upward turn can occur\",\"threshold\":\"The minimum change in the correct direction between subsequent input values that is allowed to trigger a turn\"},\"outputs\":{\"out\":\"1 for upward turn and -1 for downward turn\"},\"paramNames\":[\"highZone\",\"lowZone\",\"threshold\"]}',NULL,NULL),(51,5,12,'com.unifina.signalpath.statistics.LinearRegressionXY','UnivariateLinearRegression','GenericModule',NULL,'module','{\"outputNames\":[\"slope\",\"intercept\",\"error\",\"R^2\"],\"inputs\":{\"inX\":\"Input X values\",\"inY\":\"Input Y values\"},\"helpText\":\"<p>Performs a least-squares linear regression on a sliding window of input data. The model is <span class=\'highlight\'>y&nbsp;=&nbsp;slope*X&nbsp;+&nbsp;intercept.</p>\",\"inputNames\":[\"inX\",\"inY\"],\"params\":{\"windowLength\":\"Length of the sliding window as number of samples\"},\"outputs\":{\"error\":\"Mean square error (MSE) of the fit\",\"intercept\":\"Intercept of the linear fit\",\"slope\":\"Slope of the linear fit\",\"R^2\":\"R-squared value of the fit\"},\"paramNames\":[\"windowLength\"]}',NULL,NULL),(53,4,1,'com.unifina.signalpath.simplemath.Sum','Sum','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Values to be summed\"},\"helpText\":\"<p>Calculates the (optionally rolling) sum of incoming values. For an infinite sum, enter a <span class=\'highlight\'>windowLength</span> of 0.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"How many values must exist in the window before outputting a value\",\"windowLength\":\"Length of the sliding window of values to be summed, or 0 for infinite\"},\"outputs\":{\"out\":\"Sum of values in the window\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),(54,4,12,'com.unifina.signalpath.statistics.PearsonsCorrelation','Correlation','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates (Pearson\'s) correlation between two input variables in a sliding window of length <span class=\'highlight\'>windowLength</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(55,4,12,'com.unifina.signalpath.statistics.SpearmansRankCorrelation','SpearmansRankCorrelation','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates Spearman\'s Rank correlation between two input variables in a sliding window of length <span class=\'highlight\'>windowLength</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(56,4,12,'com.unifina.signalpath.statistics.Covariance','Covariance','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the covariance of two input variables in a sliding window of length <span class=\'highlight\'>windowLength</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(60,4,28,'com.unifina.signalpath.time.TimeOfDay','TimeOfDay','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if the current time of day (in the time zone your user account is set to) is between <span class=\'highlight\'>startTime</span> and <span class=\'highlight\'>endTime</span> (both inclusive). At other times outputs 0.\\n</p>\",\"inputNames\":[],\"params\":{\"startTime\":\"24 hour format HH:MM:SS\",\"endTime\":\"24 hour format HH:MM:SS\"},\"outputs\":{\"out\":\"1 between the given times, otherwise 0\"},\"paramNames\":[\"startTime\",\"endTime\"]}',NULL,NULL),(61,5,1,'com.unifina.signalpath.simplemath.Min','Min','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the lesser one of the two input values. For finding the minimum in a window of values, see the <span class=\'highlight\'>Min (window)</span> module.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Minimum, Smallest',NULL),(62,5,1,'com.unifina.signalpath.simplemath.Max','Max','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the greater one of the two input values. For finding the maximum in a window of values, see the <span class=\\\"highlight\\\">Max (window)</span> module.</p>\"}','Maximum, Largest',NULL),(67,11,13,'com.unifina.signalpath.charts.TimeSeriesChart','Chart','ChartModule',NULL,'chart dashboard','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module is the main tool for visualizing time series. The chart is updated on fly as new data becomes available. You can zoom the chart by dragging over the area you want to zoom to. To pan the chart while zoomed, use the <span class=\'highlight\'>navigator</span> below the chart. Individual series can be toggled on or off by clicking on the series name in the <span class=\'highlight\'>legend</span>. Also note that the chart module can be resized by dragging from its lower right corner.\\n</p><p>\\nEach input series is drawn on y-axis 1 by default. You can edit y-axis assignments by clicking the button beside the input endpoint.\\n</p><p>\\nThe number of inputs is adjustable in the module <span class=\'highlight\'>options</span> (the wrench icon). Other options include ignoring data points outside a certain time of day.\\n</p><p>\\nThe module can also produce a downloadable CSV file containing whatever data points are sent to the chart. To use this feature, run in CSV export mode by selecting that option from the Run button dropdown menu.</p>\"}','Plot, Graph','streamr-chart'),(81,5,3,'com.unifina.signalpath.SignalPath','Canvas','CanvasModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to reuse a Canvas saved into the Archive as a module in your current Canvas. This enables reuse and abstraction of functionality and helps keep your Canvases tidy and modular.\\n</p><p>\\nAny parameters, inputs or outputs you export will be visible on the module. You can export endpoints by right-clicking on them and selecting \\\"Toggle export\\\".</p>\"}','Saved, Module',NULL),(84,4,7,'com.unifina.signalpath.trigger.FourZones','FourZones','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module waits for the input signal to reach either the <span class=\'highlight\'>highTrigger</span> or <span class=\'highlight\'>lowTrigger</span> level. Either 1 or -1 is output respectively. The triggered value is kept until it is set back to 0 at the corresponding release level.\\n</p><p>\\nIf you set <span class=\'highlight\'>mode</span> to <span class=\'highlight\'>exit</span>, the output will trigger when exiting the trigger level instead of entering it.</p>\",\"inputNames\":[\"in\"],\"params\":{\"lowRelease\":\"Low release level\",\"highTrigger\":\"High trigger level\",\"lowTrigger\":\"Low trigger level\",\"highRelease\":\"High release level\",\"mode\":\"Trigger on entering/exiting the high/low trigger level\"},\"outputs\":{\"out\":\"1 on high trigger, -1 on low trigger, 0 on release\"},\"paramNames\":[\"mode\",\"highTrigger\",\"highRelease\",\"lowRelease\",\"lowTrigger\"]}',NULL,NULL),(85,4,7,'com.unifina.signalpath.trigger.Sampler','Sampler','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module can be used to sample values from one timeseries upon events from another timeseries.\\n</p><p>\\nAn event arriving at the <span class=\'highlight\'>trigger</span> input will cause the module to send out whatever value the <span class=\'highlight\'>value</span> input has. The <span class=\'highlight\'>trigger</span> is the only <span class=\'highlight\'>driving input</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(87,6,1,'com.unifina.signalpath.simplemath.ChangeLogarithmic','ChangeLogarithmic','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the logarithmic difference (log return) between the received value and the previous received value, or <span class=\\\"highlight\\\">log[in(t)]&nbsp;-&nbsp;log[in(t-1)]</span>.</p>\\n\"}',NULL,NULL),(90,4,19,'com.unifina.signalpath.utils.PassThrough','PassThrough (old)','GenericModule','','module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module just sends out whatever it receives.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(96,9,2,'com.unifina.signalpath.filtering.ExponentialMovingAverage','MovingAverageExp','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Smooths the incoming time series by calculating an exponential moving average (EMA)</p>\\n\\n<ul>\\n\\t<li><span class=\\\"formula\\\">EMA(t) = a x&nbsp;<strong>in</strong>(t) + (1-a) x&nbsp;EMA(t-1)</span></li>\\n\\t<li><span class=\\\"formula\\\">a = <span class=\\\"math-tex\\\">\\\\(2 \\\\over \\\\text{length} + 1\\\\)</span></span></li>\\n</ul>\\n\"}','EMA',NULL),(98,5,11,'com.unifina.signalpath.modeling.ARIMA','ARIMA','GenericModule',NULL,'module','{\"outputNames\":[\"pred\"],\"inputs\":{\"in\":\"Incoming time series\"},\"helpText\":\"<p>Evaluates an ARIMA prediction model with given parameters. Check the module options to set the number of autoregressive and moving average parameters. Model fitting is not (yet) implemented.</p>\",\"inputNames\":[\"in\"],\"params\":{},\"outputs\":{\"pred\":\"ARIMA prediction\"},\"paramNames\":[]}',NULL,NULL),(100,5,1,'com.unifina.signalpath.simplemath.AddMulti','Add (old)','GenericModule','','module','{\"outputNames\":[\"sum\"],\"inputs\":{},\"helpText\":\"<p>Adds together two or more numeric input values. The number of inputs can be adjusted in module options.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{\"sum\":\"Sum of inputs\"},\"paramNames\":[]}','Plus',NULL),(115,4,1,'com.unifina.signalpath.simplemath.Ln','LogNatural','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the natural logarithm of the input value.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(116,7,1,'com.unifina.signalpath.simplemath.LinearMapper','LinearMapper','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Linearly transforms a range of incoming (x) values to a range of outgoing (y) values. For example, this could be used to transform the input range of -1...1 (<span class=\'highlight\'>xMin</span>...<span class=\'highlight\'>xMax</span>) into an output range of 0...1000 (<span class=\'highlight\'>yMin</span>...<span class=\'highlight\'>yMax</span>).\\n</p><p>\\nIncoming values outside the x range will just output the min/max y value.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(119,7,3,'com.unifina.signalpath.utils.Comment','Comment','CommentModule',NULL,'comment','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Just a text box for comments. Commenting what you build is a good idea, as it helps you and others understand what is going on.</p>\"}',NULL,NULL),(120,4,1,'com.unifina.signalpath.simplemath.RoundToStep','RoundToStep','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Rounds incoming values to given precision/step. The direction of rounding can be set with the <span class=\'highlight\'>mode</span> parameter.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(125,4,7,'com.unifina.signalpath.trigger.SamplerConditional','SampleIf','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module can be used to sample values from one timeseries upon events from another timeseries, just like the Sampler module.\\n</p><p>\\nHowever the <span class=\'highlight\'>triggerIf</span> value must be equal to 1 for the value at <span class=\'highlight\'>value</span> input to be sent out. Trigger events with other values than 1 will produce no effect.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(129,4,27,'com.unifina.signalpath.text.StringContains','Contains','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Tests whether the input string contains the substring given as the <span class=\'highlight\'>search</span> parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Substring, Find',NULL),(131,4,27,'com.unifina.signalpath.text.StringConcatenate','Concatenate','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Concatenates (appends) the given strings. For example if input <span class=\'highlight\'>A</span> is \\\"foo\\\" and input <span class=\'highlight\'>B</span> is \\\"bar\\\", the output is \\\"foobar\\\".</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Join, Append',NULL),(136,6,18,'com.unifina.signalpath.custom.SimpleJavaCodeWrapper','JavaModule','CustomModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to implement custom functionality by writing code in the Java programming language directly in your browser.\\n</p><p>\\nClick the <span class=\'highlight\'>Edit code</span> button to open the code editor. The code you write will be dynamically compiled and executed.\\n</p><p>\\nSee the User Guide for more information on programmable modules.</p>\"}',NULL,NULL),(138,4,12,'com.unifina.signalpath.statistics.StandardDeviation','StandardDeviation','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input time series\"},\"helpText\":\"<p>Calculates the standard deviation in a sliding window of the input time series.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of observations for producing output\",\"windowLength\":\"Length of the sliding window (number of observations)\"},\"outputs\":{\"out\":\"Standard deviation\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),(141,7,3,'com.unifina.signalpath.utils.Merge','Merge','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Merges two event streams into one. Whatever arrives at inputs <span class=\'highlight\'>A</span> or <span class=\'highlight\'>B</span> is sent out from the single output. The inputs and the output can be connected to all types of endpoints. A runtime error may occur if there is a type conflict.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(142,8,3,'com.unifina.signalpath.utils.EventTable','Table (old)','TableModule','','module event-table-module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Displays a table of events arriving at the inputs along with their timestamps. The number of inputs can be adjusted in module options. Every input corresponds to a table column. Very useful for debugging and inspecting values. The inputs can be connected to all types of outputs.</p>\"}','Events','streamr-table'),(145,0,3,'com.unifina.signalpath.utils.Label','Label','LabelModule',NULL,'module dashboard','',NULL,'streamr-label'),(147,0,53,'com.unifina.signalpath.utils.ConfigurableStreamModule','Stream','StreamModule',NULL,'module','',NULL,NULL),(149,5,12,'com.unifina.signalpath.statistics.MinSliding','Min (window)','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the minimum value in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least </span>minSamples</span> values must be received before an output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Minimum, Smallest',NULL),(150,4,12,'com.unifina.signalpath.statistics.MaxSliding','Max (window)','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the maximum value in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least </span>minSamples</span> values must be received before an output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Maximum, Largest',NULL),(151,4,12,'com.unifina.signalpath.statistics.GeometricMean','GeometricMean','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the geometric mean of incoming values in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least </span>minSamples</span> values must be received before an output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(152,9,12,'com.unifina.signalpath.statistics.Kurtosis','Kurtosis','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input random variable\"},\"helpText\":\"<p>Calculates the kurtosis (or fourth standardized moment) of a distribution of values in a sliding window. Kurtosis is a measure of the \\\"peakedness\\\" of a distribution.\\n</p><p>\\nNote that at least 4 samples is required to calculate kurtosis.\\n</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Number of samples required to produce output. At least 4 samples are required to calculate kurtosis\",\"windowLength\":\"Length of the sliding window of values\"},\"outputs\":{\"out\":\"Kurtosis\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),(153,7,12,'com.unifina.signalpath.statistics.Percentile','Percentile','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"The input values\"},\"helpText\":\"<p>Calculates the value below which a given <span class=\'highlight\'>percentage</span> of values fall in a sliding window of observations.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of observations for producing output\",\"windowLength\":\"Length of the sliding window\",\"percentage\":\"This percentage (0-100) of observations fall under the output of this module\"},\"outputs\":{\"out\":\"The value under which <span class=\'highlight\'>percentage</span> % of input values fall\"},\"paramNames\":[\"windowLength\",\"minSamples\",\"percentage\"]}',NULL,NULL),(154,4,12,'com.unifina.signalpath.statistics.PopulationVariance','PopulationVariance','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the non-bias-corrected population variance. See the <span class=\'highlight\'>Variance</span> module or bias-corrected variance.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(155,4,12,'com.unifina.signalpath.statistics.Variance','Variance','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the bias-corrected sample variance (with N-1 in the denominator). Use the <span class=\'highlight\'>PopulationVariance</span> module for the non-bias-corrected population variance.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(156,6,12,'com.unifina.signalpath.statistics.Skewness','Skewness','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input random variable\"},\"helpText\":\"<p>Calculates the skewness (or third standardized moment) of a distribution of values in a sliding window. Skewness is a measure of the asymmetry of a distribution.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Number of samples required to produce output\",\"windowLength\":\"Length of the sliding window of values\"},\"outputs\":{\"out\":\"Skewness\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),(157,4,12,'com.unifina.signalpath.statistics.SumOfSquares','SumOfSquares','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the sum of squared input values in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least <span class=\'highlight\'>minSamples</span> values are collected before producing output.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(158,5,19,'com.unifina.signalpath.utils.FlexBarify','FlexBarify','GenericModule',NULL,'module','{\"outputNames\":[\"open\",\"high\",\"low\",\"close\",\"avg\"],\"inputs\":{\"value\":\"Value to be sampled into the bar\",\"valueLength\":\"Length of each event, contributes to <span class=\'highlight\'>barLength</span>\"},\"helpText\":\"<p>Similar to the <span class=\'highlight\'>Barify</span> module, which creates open-high-low-close bars equally long in <span class=\'highlight\'>time</span>, this module creates bars equally long in an arbitrary variable passed into the <span class=\'highlight\'>valueLength</span> input.\\n</p><p>\\nIncoming <span class=\'highlight\'>valueLength</span> is summed for the current bar until <span class=\'highlight\'>barLength</span> is reached, at which point the outputs are sent and the bar is reset.\\n</p><p>\\nNote that if multiple bars would be filled on the same event, only one is output. To avoid this situation you may want to keep <span class=\'highlight\'>barLength</span> substantially larger than incoming <span class=\'highlight\'>valueLength</span>. </p>\",\"inputNames\":[\"valueLength\",\"value\"],\"params\":{\"barLength\":\"Length of each bar (in <span class=\'highlight\'>valueLength</span> units)\"},\"outputs\":{\"open\":\"Value at start of period\",\"high\":\"Maximum value during period\",\"avg\":\"Average of values received during the period, weighted by <span class=\'highlight\'>valueLength</span>\",\"low\":\"Minimum value during period\",\"close\":\"Value at end of period (the most recent value)\"},\"paramNames\":[\"barLength\"]}',NULL,NULL),(159,1,25,'com.unifina.signalpath.twitter.TwitterModule','Twitter','GenericModule','','module','{\"params\":{\"stream\":\"Selected Twitter stream\"},\"paramNames\":[\"stream\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"tweet\":\"Tweet text\",\"username\":\"Screen name of the user\",\"name\":\"Full name of the user\",\"language\":\"Language code\",\"followers\":\"Number of followers\",\"retweet?\":\"1 if this is a retweet, 0 otherwise\",\"reply?\":\"1 if this is a reply, 0 otherwise\"},\"outputNames\":[\"tweet\",\"username\",\"name\",\"language\",\"followers\",\"retweet?\",\"reply?\"],\"helpText\":\"This is a source module for tweets. Twitter streams are tweets that match a group of keywords that define the stream.\"}',NULL,NULL),(161,2,1,'com.unifina.signalpath.simplemath.Count','Count','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"Counts the number of incoming events.\"}','number',NULL),(162,1,1,'com.unifina.signalpath.simplemath.SquareRoot','SquareRoot','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"Calculates the square root of the input.\"}','sqrt',NULL),(181,1,3,'com.unifina.signalpath.utils.Filter','Filter (old)','GenericModule','','module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"pass\":\"The filter condition. 1 (true) for letting the event pass, 0 (false) to filter it out\",\"in\":\"The incoming event (any type)\"},\"inputNames\":[\"pass\",\"in\"],\"outputs\":{\"out\":\"The event that came in, if passed. If filtered, nothing is sent\"},\"outputNames\":[\"out\"],\"helpText\":\"Only lets the incoming value through if the value at <span class=\'highlight\'>pass</span> is 1. If this condition is not met, no event is sent out.\"}','Select, Pick, Choose',NULL),(195,9,3,'com.unifina.signalpath.messaging.EmailModule','Email','GenericModule',NULL,'module','{\"params\":{\"subject\":\"Email Subject\",\"message\":\"Custom message to include in the email, optional\"},\"paramNames\":[\"subject\",\"message\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The Email module can be used to send notifications to your email address. Just like any module, it activates when an event is received at any driving input. The number of inputs can be set in module options, and the values at the inputs will be included in the email content. The inputs can be renamed to give them more descriptive names.</p>\\n\\n<p>When running against historical data, emails are not actually sent. Instead, a notification is shown representing the would-be email. Emails are capped at one per minute to avoid accidental self-spamming.</p>\\n\\n<p>Here\'s an example of email content:</p>\\n\\n<p>\\nMessage:<BR>\\n(your custom message)\\n<BR><BR>\\nEvent Timestamp:<BR>\\n2014-11-18 10:30:00.124\\n<BR><BR>\\nInput Values:<BR>\\nvalue1: 7357<BR>\\nvalue2: test value\\n</p>\"}','Message Notification Notify',NULL),(196,0,13,'com.unifina.signalpath.charts.Heatmap','Heatmap','HeatmapModule',NULL,'module',NULL,NULL,'streamr-heatmap'),(197,0,3,'com.unifina.signalpath.kafka.SendToStream','SendToStream','GenericModule',NULL,'module',NULL,'Produce Feedback',NULL),(198,2,27,'com.unifina.signalpath.text.StringEndsWith','EndsWith','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Tests whether the input string ends with the substring given as the&nbsp;search&nbsp;parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\\n\"}',NULL,NULL),(199,1,27,'com.unifina.signalpath.text.StringEquals','TextEquals','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Tests whether the input string equals with the string&nbsp;given as the&nbsp;search&nbsp;parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\\n\"}',NULL,NULL),(200,1,27,'com.unifina.signalpath.text.StringLength','TextLength','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Ouputs the length of the input text (all characters including).</p>\\n\"}','Length',NULL),(201,3,27,'com.unifina.signalpath.text.StringRegex','Regex','GenericModule',NULL,'module','{\"params\":{\"pattern\":\"Regex pattern\"},\"paramNames\":[\"pattern\"],\"inputs\":{\"text\":\"Text to be analyzed.\"},\"inputNames\":[\"text\"],\"outputs\":{\"match?\":\"1 if in the text is something that matches with the pattern. Else 0.\",\"matchCount\":\"How many matches there are in the text.\",\"matchList\":\"A list of the matches. An empty list if there aren\'t any.\"},\"outputNames\":[\"match?\",\"matchCount\",\"matchList\"],\"helpText\":\"<p>Module for analyzing text with a&nbsp;Regular Expression (Regex) pattern. <a href=\\\"http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html\\\" target=\\\"_blank\\\">Pattern</a> is given in java format, without the starting and ending slashes.</p>\\n\"}',NULL,NULL),(202,1,27,'com.unifina.signalpath.text.StringReplace','Replace','GenericModule',NULL,'module','{\"params\":{\"search\":\"The substring to be replaced\",\"replaceWith\":\"The replacer\"},\"paramNames\":[\"search\",\"replaceWith\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"out\":\"The output, with replaced texts\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Searches the input text by the <strong>search&nbsp;</strong>parameter, and if it is found, replaces it with the <strong>replaceWith&nbsp;</strong>parameter and outputs the result.</p>\\n\"}',NULL,NULL),(203,1,27,'com.unifina.signalpath.text.StringSplit','Split','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"text\":\"The text to be splitted\"},\"inputNames\":[\"text\"],\"outputs\":{\"list\":\"Splitted output as list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Splits the text by a given separator and outputs a list with the results</p>\\n\\n<p>Examples:</p>\\n\\n<ul>\\n\\t<li>Separator: &quot;&nbsp;&quot;(empty space),Text: &quot;Two Words&quot;\\n\\t<ul>\\n\\t\\t<li>Output: Two, Words</li>\\n\\t</ul>\\n\\t</li>\\n</ul>\\n\"}',NULL,NULL),(204,1,27,'com.unifina.signalpath.text.StringStartsWith','StartsWith','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Tests whether the input string starts with the substring given as the&nbsp;search&nbsp;parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\\n\"}','Beginswith',NULL),(205,2,27,'com.unifina.signalpath.text.StringTrim','Trim','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Removes the whitespace in front of and behind the input text.</p>\\n\\n<p>E.g.&nbsp; &quot; &nbsp; &nbsp; &nbsp; &nbsp; example with a space &nbsp; &nbsp; &nbsp; &quot; -&gt; &quot;example with a space&quot;</p>\\n\"}','whitespace',NULL),(206,1,27,'com.unifina.signalpath.text.ToLowerCase','ToLowerCase','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the input text in lower case.</p>\\n\"}','',NULL),(207,1,27,'com.unifina.signalpath.text.ToUpperCase','ToUpperCase','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the input text in upper case.</p>\\n\"}','capital',NULL),(208,2,27,'com.unifina.signalpath.text.ValueAsText','ValueAsText','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"Any Object\"},\"inputNames\":[\"in\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Transforms the input value (which can be any value) into text.</p>\\n\"}','toString',NULL),(209,5,28,'com.unifina.signalpath.time.ClockModule','Clock','GenericModule',NULL,'module','{\"params\":{\"format\":\"Format of the string date\",\"rate\":\"the rate of the interval\",\"unit\":\"the unit of the interval\"},\"paramNames\":[\"format\",\"rate\",\"unit\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"date\":\"String notation of the time and date\",\"timestamp\":\"unix timestamp\"},\"outputNames\":[\"date\",\"timestamp\"],\"helpText\":\"<p>Tells the time and date at fixed time intervals (by default every second). Outputs the time either in string notation of given format or as a timestamp (milliseconds from 1970-01-01 00:00:00.000).</p>\n\n<p>The time interval can be chosen with parameter&nbsp;<em>unit&nbsp;</em>and&nbsp;granularly controlled via parameter&nbsp;<em>rate</em>. For example,&nbsp;<em>unit=minute&nbsp;</em>and&nbsp;<em>rate=2</em>&nbsp;will tell the time every other minute.</p>\"}',NULL,NULL),(210,1,28,'com.unifina.signalpath.time.TimeBetweenEvents','TimeBetweenEvents','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"Any type event\"},\"inputNames\":[\"in\"],\"outputs\":{\"ms\":\"Time in milliseconds\"},\"outputNames\":[\"ms\"],\"helpText\":\"<p>Tells the time between two consecutive events in milliseconds.</p>\\n\"}',NULL,NULL),(211,3,28,'com.unifina.signalpath.time.DateConversion','DateConversion','GenericModule',NULL,'module','{\"params\":{\"timezone\":\"Timezone of the outputs\",\"format\":\"Format of the input and output string notations\"},\"paramNames\":[\"timezone\",\"format\"],\"inputs\":{\"date\":\"Timestamp, string or Date\"},\"inputNames\":[\"date\"],\"outputs\":{\"date\":\"String notation\",\"ts\":\"Timestamp(ms)\",\"dayOfWeek\":\"In shortened form, e.g. \\\"Mon\\\"\"},\"outputNames\":[\"date\",\"ts\",\"dayOfWeek\"],\"helpText\":\"<p>Takes a date as an input in either in <a href=\\\"https://docs.oracle.com/javase/8/docs/api/java/util/Date.html\\\" target=\\\"_blank\\\">Date</a> object, timestamp(ms) or in string notation. If the input is in text form, is the given format used.</p>\\n\\n<p>Example:</p>\\n\\n<p>Parameters:</p>\\n\\n<ul>\\n\\t<li>Format &lt;- &quot;yyyy-MM-dd HH:mm:ss&quot;</li>\\n\\t<li>Timezone &lt;- Europe/Helsinki</li>\\n</ul>\\n\\n<p><br />\\nInputs:</p>\\n\\n<ul>\\n\\t<li>Date in &lt;- &quot;2015-07-15&nbsp;13:06:13&quot; or&nbsp;1436954773474</li>\\n</ul>\\n\\n<p>Outputs:&nbsp;</p>\\n\\n<ul>\\n\\t<li>Date out -&gt;&nbsp;2015-07-15&nbsp;13:06:13</li>\\n\\t<li>ts -&gt;&nbsp;1436954773474</li>\\n\\t<li>dayOfWeek -&gt; &quot;Wed&quot;</li>\\n\\t<li>years -&gt; 2015</li>\\n\\t<li>months -&gt; 7</li>\\n\\t<li>days -&gt; 15</li>\\n\\t<li>hours -&gt; 13</li>\\n\\t<li>minutes -&gt; 6</li>\\n\\t<li>seconds -&gt; 13</li>\\n\\t<li>milliseconds -&gt; 0</li>\\n</ul>\\n\"}',NULL,NULL),(213,1,1,'com.unifina.signalpath.simplemath.Modulo','Modulo','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Calculates the remainder of two values. Outputs ( divisor mod divider).</p>\\n\\n<p>E.g.</p>\\n\\n<ul>\\n\\t<li>3 mod 2 = 1</li>\\n</ul>\\n\"}',NULL,NULL),(214,1,13,'com.unifina.signalpath.charts.GeographicalMapModule','Map (geo)','MapModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"id\":\"Id of the marker to place. Will also be displayed on hover over the marker.\",\"latitude\":\"Latitude coordinate for the marker\",\"longitude\":\"Longitude coordinate for the marker\"},\"inputNames\":[\"id\",\"latitude\",\"longitude\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module displays a world map. Markers can be drawn on the map at WGS84 coordinates given to the inputs&nbsp;<strong>latitude</strong>&nbsp;and&nbsp;<strong>longitude</strong>&nbsp;as&nbsp;decimal numbers (degrees). Markers also have an&nbsp;<strong>id</strong>. To draw multiple markers, connect the <b>id</b> input. Coordinates for the same id will move the marker, and coordinates for a new id will create a new marker.</p>\n\n<p>In module options, you can enable directional markers to expose an additional&nbsp;<strong>heading</strong>&nbsp;input, which controls marker heading (e.g. vehicles on the street or ships at sea). Other options include marker coloring, autozoom behavior etc.</p>\n\"}',NULL,'streamr-map'),(215,1,50,'com.unifina.signalpath.color.ColorConstant','ConstantColor','GenericModule',NULL,'module',NULL,'ColorConstant, Color',NULL),(216,1,50,'com.unifina.signalpath.color.Gradient','Gradient','GenericModule',NULL,'module',NULL,NULL,NULL),(217,2,3,'com.unifina.signalpath.utils.RateLimit','RateLimit','GenericModule',NULL,'module','{\"params\":{\"rate\":\"How many messages are let through in given time\",\"timeInMillis\":\"The time in milliseconds, in which the given number of messages are let through\"},\"paramNames\":[\"rate\",\"timeInMillis\"],\"inputs\":{\"in\":\"Input\"},\"inputNames\":[\"in\"],\"outputs\":{\"limitExceeded?\":\"Outputs 1 if the message was blocked and 0 if it wasn\'t\",\"out\":\"Outputs the input value if it wasn\'t blocked\"},\"outputNames\":[\"limitExceeded?\",\"out\"],\"helpText\":\"<p>The RateLimit module lets through n messages in t milliseconds. Then module just blocks the rest which do not fit in the window.</p>\\n\"}',NULL,NULL),(218,2,100,'com.unifina.signalpath.input.ButtonModule','Button','InputModule',NULL,'module','{\"params\":{\"buttonName\":\"The name which the button gets\",\"outputValue\":\"Value which is outputted when the button is clicked\"},\"paramNames\":[\"buttonName\",\"outputValue\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The button module outputs the given value everytime the button is pressed. Module can be used any time, even during a run.</p>\"}',NULL,'streamr-button'),(219,2,100,'com.unifina.signalpath.input.SwitcherModule','Switcher','InputModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The module ouputs even 1 or 0 depending of the value of the switcher. The value can be changed during a run.</p>\"}',NULL,'streamr-switcher'),(220,3,100,'com.unifina.signalpath.input.TextFieldModule','TextField','InputModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The module outputs the value of the text field every time &#39;send&#39; is pressed.</p>\"}',NULL,'streamr-text-field'),(221,0,51,'com.unifina.signalpath.map.CountByKey','CountByKey','GenericModule',NULL,'module','{\"params\":{\"sort\":\"Whether key-count pairs should be order by count\",\"maxKeyCount\":\"Maximum number of (sorted) key-count pairs to keep. Everything else will be dropped.\"},\"paramNames\":[\"sort\",\"maxKeyCount\"],\"inputs\":{\"key\":\"The (string) key\"},\"inputNames\":[\"key\"],\"outputs\":{\"map\":\"Key-count pairs\",\"valueOfCurrentKey\":\"The occurrence count of the last key received. \"},\"outputNames\":[\"map\",\"valueOfCurrentKey\"],\"helpText\":\"<p>Keeps count of the occurrences of keys.</p>\"}',NULL,NULL),(222,0,51,'com.unifina.signalpath.map.SumByKey','SumByKey','GenericModule',NULL,'module','{\"params\":{\"windowLength\":\"Limit moving window size of sum.\",\"sort\":\"Whether key-sum pairs should be order by sums\",\"maxKeyCount\":\"Maximum number of (sorted) key-sum pairs to keep. Everything else will be dropped.\"},\"paramNames\":[\"windowLength\",\"sort\",\"maxKeyCount\"],\"inputs\":{\"value\":\"The value to be added to aggregated sum.\",\"key\":\"The (string) key\"},\"inputNames\":[\"value\",\"key\"],\"outputs\":{\"map\":\"Key-sum pairs\",\"valueOfCurrentKey\":\"The aggregated sum of the last key received. \"},\"outputNames\":[\"map\",\"valueOfCurrentKey\"],\"helpText\":\"<p>Keeps aggregated sums of received key-value-pairs by key.</p>\"}',NULL,NULL),(223,0,51,'com.unifina.signalpath.map.ForEach','ForEach','ForEachModule',NULL,'module','{\"params\":{\"canvas\":\"The \\\"sub\\\" canvas that implements the ForEach-loop \\\"body\\\"\"},\"paramNames\":[\"canvas\"],\"inputs\":{\"key\":\"Differentiate between canvas\"},\"inputNames\":[\"key\"],\"outputs\":{\"map\":\"The state of outputs of all distinct Canvases by key.\"},\"outputNames\":[\"map\"],\"helpText\":\"<p>This module allows you to reuse a Canvas saved into the Archive as a module in your current Canvas.</p><p>A separate Canvas instance will be created for each distinct key, which enables ForEach-like behavior to be implemented. The canvas instances will also retain state as expected.</p><p>Any parameters, inputs or outputs you export will be visible on the module. You can export endpoints by right-clicking on them and selecting \\\"Toggle export\\\".</p>\"}',NULL,NULL),(224,0,51,'com.unifina.signalpath.map.ContainsValue','ContainsValue','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\",\"value\":\"a value\"},\"inputNames\":[\"in\",\"value\"],\"outputs\":{\"found\":\"1.0 if found, else 0.0.\"},\"outputNames\":[\"found\"],\"helpText\":\"<p>Determine whether a map contains a value.</p>\"}',NULL,NULL),(225,0,51,'com.unifina.signalpath.map.GetFromMap','GetFromMap','GenericModule',NULL,'module','{\"params\":{\"key\":\"a key\"},\"paramNames\":[\"key\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"found\":\"1.0 if key was present in map, 0.0 otherwise.\",\"out\":\"the corresponding value if key was found.\"},\"outputNames\":[\"found\",\"out\"],\"helpText\":\"<p>Retrieve a value from a map by key.</p>\"}',NULL,NULL),(226,0,51,'com.unifina.signalpath.map.HeadMap','HeadMap','GenericModule',NULL,'module','{\"params\":{\"limit\":\"the number of entries to fetch\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a submap of the first entries of map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieve&nbsp;first (n=limit)&nbsp;entries of a map.</p>\"}',NULL,NULL),(227,0,51,'com.unifina.signalpath.map.KeysToList','KeysToList','GenericModule',NULL,'module','{\"params\":{\"limit\":\"the number of entries to fetch\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a submap of the first entries of map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieve&nbsp;first (n=limit)&nbsp;entries of a map.</p>\"}',NULL,NULL),(228,0,51,'com.unifina.signalpath.map.PutToMap','PutToMap','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"key\":\"key to insert\",\"map\":\"a map\",\"value\":\"value to insert\"},\"inputNames\":[\"key\",\"map\",\"value\"],\"outputs\":{\"map\":\"a map with the key-value entry inserted\"},\"outputNames\":[\"map\"],\"helpText\":\"<p>Put a key-value-entry&nbsp;into a map.</p>\"}',NULL,NULL),(229,0,51,'com.unifina.signalpath.map.SortMap','SortMap','GenericModule',NULL,'module','{\"params\":{\"byValue\":\"when false (default), sorts by key. when true, sorts by value\"},\"paramNames\":[\"byValue\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a sorted map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Sorts a map.</p>\"}',NULL,NULL),(230,0,51,'com.unifina.signalpath.map.TailMap','TailMap','GenericModule',NULL,'module','{\"params\":{\"limit\":\"the number of entries to fetch\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a submap of the last entries of map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieve&nbsp;last (n=limit)&nbsp;entries of a map.</p>\"}',NULL,NULL),(231,0,51,'com.unifina.signalpath.map.ValuesToList','ValuesToList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"keys\":\"values as a list\"},\"outputNames\":[\"keys\"],\"helpText\":\"<p>Retrieves the values of a map.</p>\"}',NULL,NULL),(232,0,51,'com.unifina.signalpath.map.NewMap','NewMap','GenericModule',NULL,'module','{\"params\":{\"alwaysNew\":\"When false (defult), same map is sent every time. When true, a new map is sent on each activation.\"},\"paramNames\":[\"alwaysNew\"],\"inputs\":{\"trigger\":\"used to activate module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"a map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Emit a map everytime trigger receives a value.</p>\"}',NULL,NULL),(233,0,51,'com.unifina.signalpath.map.MergeMap','MergeMap','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"leftMap\":\"a map to merge onto\",\"rightMap\":\"a map to be merged\"},\"inputNames\":[\"leftMap\",\"rightMap\"],\"outputs\":{\"out\":\"the resulting merged map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Merge&nbsp;<strong>rightMap</strong>&nbsp;onto&nbsp;<strong>leftMap</strong>&nbsp;resulting in a single map. In case of conflicting keys,&nbsp;entries of&nbsp;<strong>rightMap</strong>&nbsp;will replace those of <strong>leftMap</strong>.</p>\"}',NULL,NULL),(234,0,51,'com.unifina.signalpath.map.RemoveFromMap','RemoveFromMap','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\",\"key\":\"a key\"},\"inputNames\":[\"in\",\"key\"],\"outputs\":{\"out\":\"a map without the removed key\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Remove an entry for a map by key.</p>\"}',NULL,NULL),(235,0,51,'com.unifina.signalpath.map.MapSize','MapSize','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"size\":\"the number of entries\"},\"outputNames\":[\"size\"],\"helpText\":\"<p>Determine the number of entries in a map.</p>\"}',NULL,NULL),(236,0,3,'com.unifina.signalpath.utils.MapAsTable','MapAsTable','TableModule',NULL,'module event-table-module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"map\":\"a map\"},\"inputNames\":[\"map\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Display the entries of a map as a table.</p>\"}',NULL,'streamr-table'),(500,0,51,'com.unifina.signalpath.map.GetMultiFromMap','GetMultiFromMap (old)','GenericModule','','module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input map\"},\"inputNames\":[\"in\"],\"outputs\":{\"founds\":\"an array indicating for each output with 0 (false) and (1) whether a value was found\",\"out-1\":\"a (default) value from map, output name is used as key\"},\"outputNames\":[\"founds\",\"out-1\"],\"helpText\":\"<p>Get multiple values&nbsp;from a Map. Number of outputs is specified via module options (wrench icon).&nbsp;<strong>The names of outputs are used as map keys so make sure to change them!</strong></p>\"}',NULL,NULL),(501,0,51,'com.unifina.signalpath.map.BuildMap','BuildMap','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in-1\":\"default single input, name used as key in Map\"},\"inputNames\":[\"in-1\"],\"outputs\":{\"map\":\"produced map\"},\"outputNames\":[\"map\"],\"helpText\":\"<p>Build a new Map from given inputs. Number of inputs is specified via module options (wrench icon).&nbsp;<strong>The names of input are used as map keys so make sure to change them!</strong></p>\"}',NULL,NULL),(520,0,1,'com.unifina.signalpath.simplemath.VariadicAddMulti','Add','GenericModule',NULL,'module','{\"outputNames\":[\"sum\"],\"inputs\":{},\"helpText\":\"<p>Adds together two or more numeric input values.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{\"sum\":\"Sum of inputs\"},\"paramNames\":[]}','Plus',NULL),(521,0,19,'com.unifina.signalpath.utils.VariadicPassThrough','PassThrough','GenericModule',NULL,'module','{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module just sends out whatever it receives.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),(522,0,3,'com.unifina.signalpath.utils.VariadicFilter','Filter','FilterModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"pass\":\"The filter condition. 1 (true) for letting the event pass, 0 (false) to filter it out\",\"in\":\"The incoming event (any type)\"},\"inputNames\":[\"pass\",\"in\"],\"outputs\":{\"out\":\"The event that came in, if passed. If filtered, nothing is sent\"},\"outputNames\":[\"out\"],\"helpText\":\"Only lets the incoming value through if the value at <span class=\'highlight\'>pass</span> is 1. If this condition is not met, no event is sent out.\"}','Select, Pick, Choose',NULL),(523,0,51,'com.unifina.signalpath.map.VariadicGetMultiFromMap','GetMultiFromMap','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input map\"},\"inputNames\":[\"in\"],\"outputs\":{\"founds\":\"an array indicating for each output with 0 (false) and (1) whether a value was found\",\"out-1\":\"a (default) value from map, output name is used as key\"},\"outputNames\":[\"founds\",\"out-1\"],\"helpText\":\"<p>Get multiple values&nbsp;from a Map. &nbsp;<strong>The names of outputs are used as map keys so make sure to change them!</strong></p>\"}',NULL,NULL),(524,0,2,'com.unifina.signalpath.filtering.MovingAverageModule','MovingAverage','GenericModule',NULL,'module','{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module calculates the simple moving average (MA, SMA) of values arriving at the input. Each value is assigned equal weight. The moving average is calculated based on a sliding window of adjustable length.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of input values received before a value is output\",\"length\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\"},\"outputs\":{\"out\":\"The moving average\"},\"paramNames\":[\"length\",\"minSamples\"]}','SMA',NULL),(525,0,51,'com.unifina.signalpath.map.FilterMap','FilterMap','GenericModule',NULL,'module','{\"params\":{\"keys\":\"if empty, keep all entries. otherwise filter by given keys.\"},\"paramNames\":[\"keys\"],\"inputs\":{\"in\":\"map to be filtered\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"filtered map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Filter incoming maps by retaining entries with specified keys.</p>\"}',NULL,NULL),(526,0,51,'com.unifina.signalpath.map.CollectFromMaps','CollectFromMaps','GenericModule',NULL,'module','{\"params\":{\"selector\":\"a map property name\"},\"paramNames\":[\"selector\"],\"inputs\":{\"listOrMap\":\"list or map to collect from\"},\"inputNames\":[\"listOrMap\"],\"outputs\":{\"listOrMap\":\"collected list or map\"},\"outputNames\":[\"listOrMap\"],\"helpText\":\"<p>Given a list/map of maps, selects from each an entry according to parameter&nbsp;<em>selector,&nbsp;</em>and then returns a list/map of the collected entry values.</p>\n\n<p>&nbsp;</p>\n\n<p>In case a map does not have an entry for <em>selector,&nbsp;</em>or the value is null, that entry will be simply skipped in the resulting output.</p>\n\n<p>&nbsp;</p>\n\n<p>Map entry <em>selector</em> supports dot and array notation for selecting from nested maps and lists, e.g. &quot;parents[1].name&quot; would return [&quot;Homer&quot;, &quot;Fred&quot;] for input [{name: &quot;Bart&quot;, parents: [{name: &quot;Marge&quot;}, {name: &quot;Homer&quot;}]}, {name: &quot;Pebbles&quot;, parents: [{name: &quot;Wilma}, {name: &quot;Fred&quot;}]}]</p>\"}',NULL,NULL),(527,0,3,'com.unifina.signalpath.utils.VariadicEventTable','Table','TableModule',NULL,'module event-table-module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Displays a table of events arriving at the inputs along with their timestamps. The number of inputs can be adjusted in module options. Every input corresponds to a table column. Very useful for debugging and inspecting values. The inputs can be connected to all types of outputs.</p>\"}','Events','streamr-table'),(528,0,53,'com.unifina.signalpath.streams.SearchStream','SearchStream','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"name\":\"stream to search for by name, must be exact\"},\"inputNames\":[\"name\"],\"outputs\":{\"found\":\"true if stream was found\",\"stream\":\"id of stream if found\"},\"outputNames\":[\"found\",\"stream\"],\"helpText\":\"<p>Search for a stream by name</p>\"}',NULL,NULL),(529,0,53,'com.unifina.signalpath.streams.CreateStream','CreateStream','GenericModule',NULL,'module','{\"params\":{\"fields\":\"the fields to be assigned to the stream\"},\"paramNames\":[\"fields\"],\"inputs\":{\"name\":\"name of the stream\",\"description\":\"human-readable description\"},\"inputNames\":[\"name\",\"description\"],\"outputs\":{\"created\":\"true if stream was created, false if failed to create stream\",\"stream\":\"the id of the created stream\"},\"outputNames\":[\"created\",\"stream\"],\"helpText\":\"<p>Create a new stream.</p>\"}',NULL,NULL),(539,0,52,'com.unifina.signalpath.list.ForEachItem','ForEachItem','GenericModule',NULL,'module','{\"params\":{\"keepState\":\"when false, sub-canvas state is cleared after lists have been processed  \",\"canvas\":\"the sub-canvas to be executed\"},\"paramNames\":[\"keepState\",\"canvas\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"numOfItems\":\"indicates how many times the sub-canvas was executed\"},\"outputNames\":[\"numOfItems\"],\"helpText\":\"<p>Execute a sub-canvas for each item of input lists.</p>\n\n<p>&nbsp;</p>\n\n<p>The&nbsp;exported inputs and outputs of sub-canvas <em>canvas</em>&nbsp;appear as list inputs and list outputs. The input lists are iterated element-wise, and the sub-canvas is executed every time a value is available for each input list. If input list sizes vary, the sub-canvas is executed as many times as the&nbsp;smallest list is of size. After the input lists have been iterated through,&nbsp;and the sub-canvas activated accordingly, lists of produced values are sent to output lists.</p>\n\n<p>&nbsp;</p>\n\n<p>The output&nbsp;<em>numOfItems</em>&nbsp;indicates how many times the sub-canvas was executed, i.e., the size of the smallest input list.</p>\n\n<p>&nbsp;</p>\n\n<p>You may want to look into the module&nbsp;<strong>RepeatItem</strong>&nbsp;when using this module to repeat parameter values etc.</p>\"}',NULL,NULL),(540,0,52,'com.unifina.signalpath.list.RepeatItem','RepeatItem','GenericModule',NULL,'module','{\"params\":{\"times\":\"times to repeat the item\"},\"paramNames\":[\"times\"],\"inputs\":{\"item\":\"item to be repeated\"},\"inputNames\":[\"item\"],\"outputs\":{\"list\":\"the produced list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Make a list out of an&nbsp;item by repeating it <em>times&nbsp;</em>times.&nbsp;</p>\"}',NULL,NULL),(541,0,52,'com.unifina.signalpath.list.Indices','Indices','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"an input list\"},\"inputNames\":[\"list\"],\"outputs\":{\"indices\":\"a list of indices for the input list\",\"list\":\"the original input list\"},\"outputNames\":[\"indices\",\"list\"],\"helpText\":\"<p>Generates a list from <strong>[0,n-1]</strong>&nbsp;according to the size <strong>n</strong>&nbsp;of the given input list.&nbsp;</p>\"}','Indexes',NULL),(544,0,52,'com.unifina.signalpath.list.ListSize','ListSize','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"size\":\"number of items in list\"},\"outputNames\":[\"size\"],\"helpText\":\"<p>Determine size of list.</p>\"}',NULL,NULL),(545,0,52,'com.unifina.signalpath.list.Range','Range','GenericModule',NULL,'module','{\"params\":{\"from\":\"start of sequence; included in sequence.\",\"step\":\"step size to add/subtract; sign is ignored; an empty sequence is produced if set to 0\",\"to\":\"upper bound of sequence; not necessarily included in sequence\"},\"paramNames\":[\"from\",\"step\",\"to\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"out\":\"the generated sequence\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generates a sequence&nbsp;of numbers increasing/decreasing according to a specified <em>step</em>.</p>\n\n<p>&nbsp;</p>\n\n<p>When&nbsp;<em>from &lt; to</em>&nbsp;a growing sequence is produced.&nbsp;Otherwise (<em>from &gt; to)</em>&nbsp;a decreasing sequence is produced. The sign of parameter&nbsp;<em>step</em>&nbsp;is ignored, and&nbsp;is automatically determined&nbsp;by the inequality relation between&nbsp;<em>from&nbsp;</em>and&nbsp;<em>to</em>.</p>\n\n<p>&nbsp;</p>\n\n<p>Parameter&nbsp;<em>to</em>&nbsp;acts as an upper bound which means that if sequence generation goes over&nbsp;<em>to</em>, the exceeding values are not included in the sequence. E.g., from=1, to=2, seq=0.3 results in [1, 1.3, 1.6, 1.9], with&nbsp;2.1 notably not included.</p>\"}',NULL,NULL),(546,0,52,'com.unifina.signalpath.list.SubList','SubList','GenericModule',NULL,'module','{\"params\":{\"from\":\"start position (included)\",\"to\":\"end position (not included)\"},\"paramNames\":[\"from\",\"to\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"error\":\"error string in case error occurred\",\"out\":\"extracted sub list if successful\"},\"outputNames\":[\"error\",\"out\"],\"helpText\":\"<p>Extract a sub&nbsp;list from a list.</p>\n\n<p>&nbsp;</p>\n\n<p>This&nbsp;module is strict&nbsp;about correct indexing. If given incorrect indices, instead of a sub list being produced,&nbsp;an error will be produced in output <em>error</em>.&nbsp;</p>\"}',NULL,NULL),(548,0,52,'com.unifina.signalpath.list.AddToList','AddToList','GenericModule',NULL,'module','{\"params\":{\"index\":\"index to add to, from 0 to length of list\"},\"paramNames\":[\"index\"],\"inputs\":{\"item\":\"item to add to list\",\"list\":\"the list to add to\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"error\":\"error string if given invalid index\",\"list\":\"the result if operation successful\"},\"outputNames\":[\"error\",\"list\"],\"helpText\":\"<p>Insert an item into&nbsp;an arbitrary position of a List. Unless adding to the very end of a list,&nbsp;items starting from&nbsp;<em>index </em>are&nbsp;all shifted to the right to allow insertion of new item.</p>\n\"}',NULL,NULL),(549,0,52,'com.unifina.signalpath.list.AppendToList','AppendToList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to append\",\"list\":\"list to append to\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"list\":\"resulting list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Append an item to the end of a List.</p>\n\"}',NULL,NULL),(550,0,52,'com.unifina.signalpath.list.BuildList','BuildList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Build a fixed-sized list from values at inputs.</p>\n\"}',NULL,NULL),(551,0,52,'com.unifina.signalpath.list.ContainsItem','ContainsItem','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to look for\",\"list\":\"list to look from\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"found\":\"true if found; false otherwise\"},\"outputNames\":[\"found\"],\"helpText\":\"<p>Checks whether a list contains an item.</p>\n\"}',NULL,NULL),(552,0,52,'com.unifina.signalpath.list.FlattenList','FlattenList','GenericModule',NULL,'module','{\"params\":{\"deep\":\"whether to flatten recursively\"},\"paramNames\":[\"deep\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"flattened list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Flattens lists inside a list, e.g. [1, [2,3], [4, 5], 6, [7, 8], 9] -&gt; [1, 2, 3, 4, 5, 6, 7, 8, 9].</p>\n\n<p>&nbsp;</p>\n\n<p>If <em>deep&nbsp;= true</em>, flattening will be done recursively. E.g. [1, [2, [3, [4, 5, [6]]], 7], 8, 9] -&gt;&nbsp;[1, 2, 3, 4, 5, 6, 7, 8, 9]. Otherwise only one level of flattening will be perfomed.</p>\n\"}',NULL,NULL),(553,0,52,'com.unifina.signalpath.list.HeadList','HeadList','GenericModule',NULL,'module','{\"params\":{\"limit\":\"the maximum number of items to include\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a list containing the first items of a list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieves the first (a maximum of <em>limit</em>)&nbsp;items of a list.</p>\n\"}',NULL,NULL),(554,0,52,'com.unifina.signalpath.list.MergeList','MergeList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"head\":\"the first items of the merged list\",\"tail\":\"the last items of the merged list\"},\"inputNames\":[\"head\",\"tail\"],\"outputs\":{\"out\":\"merged list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Merge two lists (<em>head + tail)</em> together to form a singe list. Merging is simply done by adding items of&nbsp;<em>tail&nbsp;</em>to the end of&nbsp;<em>head&nbsp;</em>to form a single list.</p>\n\"}',NULL,NULL),(555,0,52,'com.unifina.signalpath.list.RemoveFromList','RemoveFromList','GenericModule',NULL,'module','{\"params\":{\"index\":\"position to remove item from\"},\"paramNames\":[\"index\"],\"inputs\":{\"in\":\"list to remove item from\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"the list with the item removed\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Remove an item from a list by index. Given an invalid index, this module simply outputs&nbsp;the original&nbsp;input list.</p>\n\"}',NULL,NULL),(556,0,52,'com.unifina.signalpath.list.ReverseList','ReverseList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"reversed list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Reverses a list.</p>\n\"}',NULL,NULL),(557,0,52,'com.unifina.signalpath.list.SortList','SortList','GenericModule',NULL,'module','{\"params\":{\"order\":\"ascending or descending\"},\"paramNames\":[\"order\"],\"inputs\":{\"in\":\"list to sort\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"sorted list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Sort a list.</p>\n\"}',NULL,NULL),(558,0,52,'com.unifina.signalpath.list.TailList','TailList','GenericModule',NULL,'module','{\"params\":{\"limit\":\"the maximum number of items to include\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a list containing the last items of a list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p><br />\nRetrieves the last&nbsp;(a maximum of limit) items of a list.</p>\n\"}',NULL,NULL),(559,0,52,'com.unifina.signalpath.list.Unique','Unique','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"list with possible duplicates\"},\"inputNames\":[\"list\"],\"outputs\":{\"list\":\"list without duplicates\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Removes duplicate items from a list resulting in a list of unique items. The first occurrence of an item is kept&nbsp;and subsequent occurrences removed.</p>\n\"}',NULL,NULL),(560,0,52,'com.unifina.signalpath.list.IndexOfItem','IndexOfItem','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to look for\",\"list\":\"list to look in\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"index\":\"outputs the index of the first occurrence; does not output anything if no occurrences\"},\"outputNames\":[\"index\"],\"helpText\":\"<p>Finds the index of the first occurrence of an item in a list.</p>\n\"}',NULL,NULL),(561,0,52,'com.unifina.signalpath.list.IndexesOfItem','IndexesOfItem','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to look for\",\"list\":\"item to look for\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"indexes\":\"list of indexes of occurrences; empty list if none\"},\"outputNames\":[\"indexes\"],\"helpText\":\"<p>Finds indexes of all&nbsp;occurrences of an item in a list.</p>\n\"}',NULL,NULL),(562,0,54,'com.unifina.signalpath.random.RandomNumber','RandomNumber','GenericModule',NULL,'module','{\"params\":{\"min\":\"lower bound of interval to sample from\",\"max\":\"upper bound of interval to sample from\"},\"paramNames\":[\"min\",\"max\"],\"inputs\":{\"trigger\":\"when value is received, activates module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"the random number\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generate random numbers between [<em>min</em>, <em>max</em>] with uniform probability.</p>\"}',NULL,NULL),(563,0,54,'com.unifina.signalpath.random.RandomNumberGaussian','RandomNumberGaussian','GenericModule',NULL,'module','{\"params\":{\"mean\":\"mean of normal distribution\",\"sd\":\"standard deviation of normal distribution\"},\"paramNames\":[\"mean\",\"sd\"],\"inputs\":{\"trigger\":\"when value is received, activates module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"the random number\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generate random numbers from normal (Gaussian) distribution with mean&nbsp;<em>mean</em>&nbsp;and standard deviation&nbsp;<em>sd</em>.</p>\"}',NULL,NULL),(564,0,27,'com.unifina.signalpath.random.RandomString','RandomString','GenericModule',NULL,'module','{\"params\":{\"length\":\"length of strings to generate\"},\"paramNames\":[\"length\"],\"inputs\":{\"trigger\":\"when value is received, activates module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"the random string\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generate fixed-length random strings from an equiprobable symbol pool. Allowed symbols can be configured from module settings.</p>\"}',NULL,NULL),(565,0,52,'com.unifina.signalpath.random.ShuffleList','ShuffleList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"input list randomly ordered\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Shuffle the items of a list.</p>\"}',NULL,NULL),(566,0,28,'com.unifina.signalpath.time.TimeOfEvent','TimeOfEvent','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"trigger\":\"any value; causes module to activate, i.e., produce output\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"timestamp\":\"time of the current event\"},\"outputNames\":[\"timestamp\"],\"helpText\":\"<p>Get timestamp for the event currently being processed. Similar to <strong>Clock,&nbsp;</strong>but instead of generating events,&nbsp;this&nbsp;module is triggered manually through input&nbsp;<em>trigger</em>.&nbsp;</p>\"}',NULL,NULL),(567,0,1,'com.unifina.signalpath.simplemath.Expression','Expression','GenericModule',NULL,'module','{\"params\":{\"expression\":\"mathematical expression to evaluate\"},\"paramNames\":[\"expression\"],\"inputs\":{\"x\":\"variable for default expression\",\"y\":\"variable for default expression\"},\"inputNames\":[\"x\",\"y\"],\"outputs\":{\"out\":\"result if evaluation succeeded\",\"error\":\"error message if evaluation failed (e.g. syntax error in expression)\"},\"outputNames\":[\"out\",\"error\"],\"helpText\":\"<p>Evaluate arbitrary mathematical expressions containing operators, variables, and functions. Variables introduced in an&nbsp;expression&nbsp;will automatically appear as&nbsp;inputs.</p>\n\n<p>&nbsp;</p>\n\n<p>See&nbsp;<a href=https://github.com/uklimaschewski/EvalEx#supported-operators>https://github.com/uklimaschewski/EvalEx#supported-operators</a>&nbsp;for further detail about supported features.</p>\"}','Formula, Evaluate',NULL),(569,0,27,'com.unifina.signalpath.text.FormatNumber','FormatNumber','GenericModule',NULL,'module','{\"params\":{\"decimalPlaces\":\"number of decimal places\"},\"paramNames\":[\"decimalPlaces\"],\"inputs\":{\"number\":\"number to format\"},\"inputNames\":[\"number\"],\"outputs\":{\"text\":\"number formatted as string\"},\"outputNames\":[\"text\"],\"helpText\":\"<p>Format a number into a string with a specified number of&nbsp;decimal places.</p>\"}',NULL,NULL),(570,0,3,'com.unifina.signalpath.utils.MovingWindow','MovingWindow','GenericModule',NULL,'module','{\"params\":{\"windowLength\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\",\"windowType\":\"behavior of window\",\"minSamples\":\"Minimum number of input values received before a value is output\"},\"paramNames\":[\"windowLength\",\"windowType\",\"minSamples\"],\"inputs\":{\"in\":\"values of any type\"},\"inputNames\":[\"in\"],\"outputs\":{\"list\":\"the window\'s current state as a list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Provides&nbsp;a moving window (list)&nbsp;for any types of values. Window size and behavior&nbsp;can be set via parameters.</p>\"}',NULL,NULL),(571,0,3,'com.unifina.signalpath.utils.ExportCSV','ExportCSV','ExportCSVModule',NULL,'module',NULL,NULL,NULL),(572,0,3,'com.unifina.signalpath.utils.RequireAll','RequireAll','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Simply passes the values of inputs&nbsp;to corresponding outputs, but only&nbsp;if <strong>all</strong> inputs receive a value on the same event. If one or more inputs do not receive a value on an event, none of the values are sent forward.</p>\"}',NULL,NULL),(573,0,10,'com.unifina.signalpath.bool.Xor','Xor','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Implements the boolean XOR operation: outputs true&nbsp;if <span class=\\\"highlight\\\">one</span> of the inputs equal true, otherwise outputs false.</p>\"}',NULL,NULL),(574,0,1001,'com.unifina.signalpath.blockchain.VerifySignature','VerifySignature','GenericModule',NULL,'module','{\"helpText\":\"Given message and signature get Ethereum address of signee.\"}','GetSignature',NULL),(583,0,13,'com.unifina.signalpath.charts.ImageMapModule','Map (image)','ImageMapModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"id\":\"Id of the marker to draw\",\"x\":\"Horizontal coordinate of the marker between 0 and 1\",\"y\":\"Vertical coordinate of the marker between 0 and 1\"},\"inputNames\":[\"id\",\"x\",\"y\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module displays a map based on an user-defined image. The image is loaded from a&nbsp;<strong>URL</strong>&nbsp;given in module options.&nbsp;The map automatically scales <strong>x</strong> and <strong>y</strong> coordinates between 0..1&nbsp;to image dimensions.&nbsp;This means&nbsp;that regardless of image size in pixels&nbsp;(x,y) = (0,0) is the top left corner of the image, and (1,1) is the bottom right corner.</p>\n\n<p>Markers also have an&nbsp;<strong>id</strong>. To draw multiple markers, connect the <b>id</b> input. Coordinates for the same id will move the marker, and coordinates for a new id will create a new marker.</p>\n\n<p>In module options, you can enable directional markers to expose an additional&nbsp;<strong>heading</strong>&nbsp;input, which controls marker heading (e.g. direction in which people are facing in a space). Other options include marker coloring, autozoom behavior etc.</p>\n\"}',NULL,'streamr-map'),(800,1,51,'com.unifina.signalpath.map.ConstantMap','ConstantMap','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to enter a constant Map object, which is a set of key-value pairs. It can be connected to any Map input in Streamr - for example, to set headers on the HTTP module.</p>\\n\"}','MapConstant',NULL),(801,3,28,'com.unifina.signalpath.time.Scheduler','Scheduler','SchedulerModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"value\":\"The value from a active rule or the default value\"},\"outputNames\":[\"value\"],\"helpText\":\"<p>Outputs a certain value at a certain time.&nbsp;E.g. Every day from 10:00 to 14:00 the module outputs value 1&nbsp;and otherwise value 0.<br />\\nIf more than one rule are active at the same time, the value from the rule with the highest priority (the highest rule in the list) is sent.<br />\\nIf no rule is active,&nbsp;the default value will be sent out.&nbsp;</p>\\n\"}',NULL,NULL),(802,1,52,'com.unifina.signalpath.list.ConstantList','ConstantList','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to manually enter a constant List object.</p>\\n\"}','ListConstant',NULL),(1000,0,1000,'com.unifina.signalpath.remote.SimpleHttp','Simple HTTP','GenericModule',NULL,'module','{\"params\":{\"verb\":\"HTTP verb (e.g. GET, POST)\",\"URL\":\"URL to send the request to\"},\"paramNames\":[\"verb\",\"URL\"],\"inputs\":{\"trigger\":\"Send request when input arrives\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"error\":\"Description of what went wrong\"},\"outputNames\":[\"error\"],\"helpText\":\"<p>HTTP Request module sends input values as HTTP request to given URL, parses the server response, and sends resulting values through named outputs.</p><p>Please rename inputs, outputs and headers using names that the target API requires. To pluck values nested deeper in response JSON, use square brackets and dot notation, e.g. naming output as <i>customers[2].name</i> would fetch \"Bob\" from <i>{\"customers\":[{\"name\":\"Rusty\"},{\"name\":\"Mack\"},{\"name\":\"</i><b>Bob</b><i>\"}]}</i> (array indices are <b>zero</b>-based, that is, first element is number <b>0</b>!)</p><p>For GET and DELETE requests, the input values are added to URL parameters:<br /><i>http://url?key1=value1&key2=value2&...</i></p><p>For other requests, the input values are sent in the body as JSON object:<br /><i>{\"key1\": \"value1\", \"key2\": \"value2\", ...}</i></p>\"}',NULL,NULL),(1001,0,1000,'com.unifina.signalpath.remote.Http','HTTP Request','GenericModule',NULL,'module','{\"params\":{\"verb\":\"HTTP verb (e.g. GET, POST)\",\"URL\":\"URL to send the request to\",\"params\":\"Query parameters added to URL (?name=value)\",\"headers\":\"HTTP Request headers\"},\"paramNames\":[\"verb\",\"URL\",\"params\",\"headers\"],\"inputs\":{\"body\":\"Request body\",\"trigger\":\"Send request when input arrives\"},\"inputNames\":[\"body\",\"trigger\"],\"outputs\":{\"errors\":\"Empty list if all went correctly\",\"data\":\"Server response payload\",\"status code\":\"200..299 means all went correctly\",\"ping(ms)\":\"Round-trip response time in milliseconds\",\"headers\":\"HTTP Response headers\"},\"outputNames\":[\"errors\",\"data\",\"status code\",\"ping(ms)\",\"headers\"],\"helpText\":\"<p>HTTP Request module sends inputs as HTTP request to given URL, and returns server response.</p><p>Headers, query params and body should be Maps. Body can also be List or String.</p><p>Request body format can be changed in options (wrench icon). Default is JSON. Server is expected to return JSON formatted documents.</p><p>HTTP Request is asynchronous by default. Synchronized requests block the execution of the whole canvas until they receive the server response, but otherwise they work just like any other module; asynchronous requests on the other hand work like streams in that they activate modules they&#39;re connected to only when they receive data from the server. </p><ul><li>If a data path branches, and one branch passes through the HTTP Request module and another around it, if they also converge in a module, that latter module may experience multiple activations due to asynchronicity.</li><li>Asynchronicity also means that server responses may arrive in different order than they were sent.</li><li>If this kind of behaviour causes problems, you can try to fix it by changing sync mode to <i>synchronized</i> in options (wrench icon). <ul><li>Caveat: data throughput WILL be lower, and external servers may freeze your canvas simply by responding very slowly (or not at all).</li></ul></li><li>For simple data paths and somewhat stable response times, the two sync modes will yield precisely the same results.</li></ul>',NULL,NULL),(1002,0,10,'com.unifina.signalpath.convert.BooleanToNumber','BooleanToNumber','GenericModule',NULL,'module','',NULL,NULL),(1003,0,10,'com.unifina.signalpath.bool.BooleanConstant','BooleanConstant','GenericModule',NULL,'module','',NULL,NULL),(1010,0,1000,'com.unifina.signalpath.remote.Sql','SQL','GenericModule',NULL,'module','{\"params\":{\"engine\":\"Database engine, e.g. MySQL\",\"host\":\"Database server to connect\",\"database\":\"Name of the database\",\"username\":\"Login username\",\"password\":\"Login password\"},\"paramNames\":[\"engine\",\"host\",\"database\",\"username\",\"password\"],\"inputs\":{\"sql\":\"SQL command to be executed\"},\"inputNames\":[\"sql\"],\"outputs\":{\"errors\":\"List of error strings\",\"result\":\"List of rows returned by the database\"},\"outputNames\":[\"errors\",\"result\"],\"helpText\":\"<p>The result is a list of map objects, e.g. <i>[{&quot;id&quot;:0, &quot;name&quot;:&quot;Me&quot;}, {&quot;id&quot;:1, &quot;name&quot;:&quot;You&quot;}]</i></p>\"}',NULL,NULL),(1011,0,3,'com.unifina.signalpath.utils.ListAsTable','ListAsTable','TableModule',NULL,'module event-table-module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"List to be shown\"},\"inputNames\":[\"list\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Display contents of a list as a table. If it\'s a list of maps, break maps into columns</p>\"}',NULL,'streamr-table'),(1012,0,52,'com.unifina.signalpath.list.GetFromList','GetFromList','GenericModule',NULL,'module','{\"params\":{\"index\":\"Index in the list for the item to be fetched. Negative index counts from end of list.\"},\"paramNames\":[\"index\"],\"inputs\":{\"in\":\"List to be indexed\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"Item found at given index\",\"error\":\"Error message, e.g. <i>List is empty</i>\"},\"outputNames\":[\"out\",\"error\"],\"helpText\":\"<p>Fetch item from a list by index.</p><p>Indexing starts from zero, so the first item has index 0, second has index 1 etc.</p><p>Negative index counts from end of list, so that last item in the list has index -1, second-to-last has index -2 etc.</p>\"}',NULL,NULL),(1015,0,27,'com.unifina.signalpath.text.StringTemplate','StringTemplate','GenericModule',NULL,'module','{\"params\":{\"template\":\"Text template\"},\"paramNames\":[\"template\"],\"inputs\":{\"args\":\"Map of arguments that will be substituted into the template\"},\"inputNames\":[\"args\"],\"outputs\":{\"errors\":\"List of error strings\",\"result\":\"Completed template string\"},\"outputNames\":[\"errors\", \"result\"],\"helpText\":\"<p>For template syntax, see <a href=\'https://github.com/antlr/stringtemplate4/blob/master/doc/cheatsheet.md\' target=\'_blank\'>StringTemplate cheatsheet</a>.</p><p>Values of the <strong>args</strong> map are added as substitutions in the template. For example, incoming map <strong>{name: &quot;Bernie&quot;, age: 50}</strong> substituted into template &quot;<strong>Hi, &lt;name&gt;!</strong>&quot;&nbsp;would produce string &quot;Hi, Bernie!&quot;</p><p>Nested maps can be accessed with dot notation:&nbsp;<strong>{name: &quot;Bernie&quot;, pet: {species: &quot;dog&quot;, age: 3}}</strong>&nbsp;substituted into &quot;<strong>What a cute &lt;pet.species&gt;!</strong>&quot; would result in &quot;What a cute dog!&quot;.</p><p>Lists will be smashed together: <strong>{pals:&nbsp;[&quot;Sam&quot;, &quot;Herb&quot;, &quot;Dud&quot;]}</strong>&nbsp;substituted into &quot;<strong>BFF: me, &lt;pals&gt;</strong>&quot; results in &quot;BFF: me, SamHerbDud&quot;. Separator must be explicitly given: &quot;<strong>BFF: me, &lt;pals; separator=&quot;, &quot;&gt;</strong>&quot; gives &quot;BFF: me, Sam, Herb, Dud&quot;.</p><p>Transforming list items can be done with <em>{ x | f(x) }</em> syntax, e.g. <strong>{pals:&nbsp;[&quot;Sam&quot;, &quot;Herb&quot;, &quot;Dud&quot;]}</strong> substituted into &quot;<strong>&lt;pals: { x | Hey &lt;x&gt;! }&gt; Hey y&#39;all!</strong>&quot; results in &quot;Hey Sam! Hey Herb! Hey Dud! Hey y&#39;all!&quot;.</p>\"}',NULL,NULL),(1016,0,27,'com.unifina.signalpath.text.JsonParser','JsonParser','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"json\":\"JSON string to parse\"},\"inputNames\":[\"json\"],\"outputs\":{\"errors\":\"List of error strings\",\"result\":\"Map, List or value that the JSON string represents\"},\"outputNames\":[\"errors\", \"result\"],\"helpText\":\"<p>JSON string should fulfill the <a href=\'http://json.org/\' target=\'_blank\'>JSON specification</a>.</p>\"}',NULL,NULL),(1023,0,1001,'com.unifina.signalpath.blockchain.GetEthereumContractAt','GetContractAt','GenericModule',NULL,'module','{\"helpText\":\"Ethereum contract that has been deployed in the blockchain\"}','ContractAtAddress,GetEthereumContract,GetEthereumContractAt',NULL),(1030,0,52,'com.unifina.signalpath.list.ListToEvents','ListToEvents','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"input list\"},\"inputNames\":[\"list\"],\"outputs\":{\"item\":\"input list items one by one as separate events\"},\"outputNames\":[\"item\"],\"helpText\":\"<p>Split input list into separate events. They will be sent out as separate events, one item at a time.</p><p>Each event causes activation of all modules where the output item is sent to.</p>\"}',NULL,NULL),(1031,0,27,'com.unifina.signalpath.text.StringToNumber','StringToNumber','GenericModule',NULL,'module','{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input string\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"number parsed from input string\",\"error\":\"Error if input can\'t be parsed\"},\"outputNames\":[\"out\",\"error\"],\"helpText\":\"<p>Parse a number from the input string.</p><p>Examples of valid floating-point numbers:</p><ul><li>&quot;1&quot;</li><li>&quot;3.14159&quot;</li><li>&quot;-.234e4&quot; (outputs -2340)</li><li>&quot;+3.e1&quot; (outputs 30)</li></ul>\"}','Parse',NULL),(1032,0,1001,'com.unifina.signalpath.blockchain.GetEvents','GetEvents','GenericModule',NULL,'module','{\"helpText\":\"Get events sent out by given contract in the given transaction\"}','EthereumEvents',NULL),(1033,0,53,'com.unifina.signalpath.streams.GetOrCreateStream','GetOrCreateStream','GenericModule',NULL,'module','{\"params\":{\"fields\":\"the fields to be assigned to the stream if a new stream is created\"},\"paramNames\":[\"fields\"],\"inputs\":{\"name\":\"name of the stream\",\"description\":\"human-readable description if a new stream is created\"},\"inputNames\":[\"name\",\"description\"],\"outputs\":{\"created\":\"true if stream was created, false if existing stream was found\",\"stream\":\"the id of the found or created stream\"},\"outputNames\":[\"created\",\"stream\"],\"helpText\":\"<p>Find existing stream by name, or create a new stream if a stream by that name doesn\'t exist yet. If a stream is found, <i>fields</i> and <i>description</i> inputs are <b>ignored</b>.</p>\"}','StreamByName',NULL),(1034,0,1000,'com.unifina.signalpath.remote.Mqtt','MQTT','GenericModule',NULL,'module','{\"params\":{\"URL\":\"URL of MQTT broker to listen to\",\"topic\":\"MQTT topic\",\"username\":\"MQTT username (optional)\",\"password\":\"MQTT password (optional)\",\"certType\":\"MQTT certificate type\"},\"paramNames\":[\"URL\",\"topic\",\"username\",\"password\",\"certType\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"message\":\"MQTT message string\"},\"outputNames\":[\"message\"],\"helpText\":\"<p>Listen to MQTT messages, output them as strings. If message is JSON, a JsonParser module can be used to transform the string into a map, and GetMultiFromMap module to extract values from the map.</p><h2>Examples:</h2><h3>Connecting to MQTT service without certificate</h3><p>Give URL address as</p><pre>mqtt://service.com</pre><p>or</p><pre>tcp://service.com</pre><p>Add topic and username and password if needed.</p><h3>Connecting to MQTT with certificate</h3><p>Give URL address as</p><pre>ssl://service.com</pre><p>Add topic and username and password if needed.</p><p>Select certificate type to be .crt and paste your certificate to text area.</p>\"}',NULL,NULL),(1100,0,1001,'com.unifina.signalpath.blockchain.templates.PayByUse','PayByUse','SolidityModule',NULL,'module','{\"helpText\":\"PayByUse Ethereum contract\"}',NULL,NULL),(1101,0,1001,'com.unifina.signalpath.blockchain.templates.BinaryBetting','BinaryBetting','SolidityModule',NULL,'module','{\"helpText\":\"BinaryBetting Ethereum contract\"}',NULL,NULL),(1150,0,1001,'com.unifina.signalpath.blockchain.SendEthereumTransaction','EthereumCall','GenericModule',NULL,'module','{\"params\":{\"ethAccount\":\"The account used to make transaction or call\", \"function\":\"The contract function to invoke\"},\"paramNames\":[\"ethAccount\",\"function\"],\"inputs\":{\"contract\":\"Ethereum contract\", \"trigger\":\"Send call (for functions that have no inputs)\", \"ether\":\"ETH to send with the function call (for <i>payable</i> functions)\"},\"inputNames\":[\"contract\", \"trigger\", \"ether\"],\"outputs\":{\"errors\":\"List of error messages\"},\"outputNames\":[\"errors\"],\"helpText\":\"<p>Call Ethereum smart contract.</p><p>First, connect Ethereum contract into <strong>contract</strong>&nbsp;input. You can write your own using SolidityModule, or pick a template such as PayByUse.</p><p>Second, choose the <strong>function</strong> you want to call from the dropdown. There are two kinds of functions calls:</p><ul><li>constant function calls that return results directly, and</li><li>transactions that return values through events that the function call invokes.</li></ul><p>The contract must be deployed before this module can activate.</p>\"}',NULL,NULL),(1151,0,1001,'com.unifina.signalpath.blockchain.SolidityCompileDeploy','SolidityCompileDeploy','SolidityModule',NULL,'module','{\"params\":{\"ethAccount\":\"The account used to deploy contract\", \"initial ETH\":\"initial ETH amount to be deployed with contract\"},\"paramNames\":[\"ethAccount\", \"initial ETH\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"contract\":\"Ethereum contract\"},\"outputNames\":[\"contract\"],\"helpText\":\"<p>Compile and deploy Ethereum smart contract. Edit the code in text window, close window and then contract will be compiled. Enter constructor args and initial ETH (if applicable) and press deploy. Deployed address will be displayed in bottom text field.  You can connect the contract output to SendEthereumTransaction module.</p>\"}',NULL,NULL),(1152,0,1001,'com.unifina.signalpath.blockchain.GetEthBalance','GetEthBalance','GenericModule',NULL,'module','{\"inputs\":{\"address\":\"The address whose ETH balance should be checked\"},\"inputNames\":[\"address\"],\"outputs\":{\"balance\":\"The ETH balance in Ether\"},\"outputNames\":[\"balance\"],\"helpText\":\"check the ETH balance of an Ethereum address\"}',NULL,NULL),(6000,0,27,'com.unifina.signalpath.text.DecodeStringToByteArray','DecodeStringToByteArray','GenericModule',NULL,'module','',NULL,NULL),(6001,0,27,'com.unifina.signalpath.text.DecodeByteArrayToString','DecodeByteArrayToString','GenericModule',NULL,'module','',NULL,NULL);
/*!40000 ALTER TABLE `module` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `module_category`
--

DROP TABLE IF EXISTS `module_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `module_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `hide` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1AD2C17148690B46` (`parent_id`),
  CONSTRAINT `FK1AD2C17148690B46` FOREIGN KEY (`parent_id`) REFERENCES `module_category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1002 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `module_category`
--

LOCK TABLES `module_category` WRITE;
/*!40000 ALTER TABLE `module_category` DISABLE KEYS */;
INSERT INTO `module_category` VALUES (1,0,'Simple Math',40,15,NULL),(2,0,'Filtering',30,15,NULL),(3,0,'Utils',100,NULL,NULL),(7,0,'Triggers',60,15,NULL),(10,0,'Boolean',45,NULL,NULL),(11,0,'Prediction',20,15,NULL),(12,0,'Statistics',42,15,NULL),(13,0,'Visualizations',80,NULL,NULL),(15,0,'Time Series',1,NULL,NULL),(18,0,'Custom Modules',70,NULL,NULL),(19,0,'Time Series Utils',70,15,NULL),(25,0,'Data Sources',0,NULL,''),(27,0,'Text',2,NULL,NULL),(28,0,'Time & Date',3,NULL,NULL),(50,0,'Color',1,3,NULL),(51,0,'Map',141,NULL,NULL),(52,0,'List',142,NULL,NULL),(53,0,'Streams',143,NULL,NULL),(54,0,'Random',142,15,NULL),(100,0,'Input',140,NULL,NULL),(1000,0,'Integrations',130,NULL,NULL),(1001,0,'Ethereum',0,1000,NULL);
/*!40000 ALTER TABLE `module_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `operation` varchar(255) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `invite_id` bigint(20) DEFAULT NULL,
  `anonymous` bit(1) NOT NULL,
  `canvas_id` varchar(255) DEFAULT NULL,
  `dashboard_id` varchar(255) DEFAULT NULL,
  `stream_id` varchar(255) DEFAULT NULL,
  `product_id` varchar(255) DEFAULT NULL,
  `subscription_id` bigint(20) DEFAULT NULL,
  `ends_at` datetime DEFAULT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKE125C5CF60701D32` (`user_id`),
  KEY `FKE125C5CF8377B94B` (`invite_id`),
  KEY `FKE125C5CF3D649786` (`canvas_id`),
  KEY `FKE125C5CF70E281EB` (`dashboard_id`),
  KEY `FKE125C5CF86527F49` (`stream_id`),
  KEY `anonymous_idx` (`anonymous`),
  KEY `fk_permission_product` (`product_id`),
  KEY `subscription_idx` (`subscription_id`),
  KEY `parent_idx` (`parent_id`),
  CONSTRAINT `FKE125C5CF3D649786` FOREIGN KEY (`canvas_id`) REFERENCES `canvas` (`id`),
  CONSTRAINT `FKE125C5CF60701D32` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `FKE125C5CF70E281EB` FOREIGN KEY (`dashboard_id`) REFERENCES `dashboard` (`id`),
  CONSTRAINT `FKE125C5CF8377B94B` FOREIGN KEY (`invite_id`) REFERENCES `signup_invite` (`id`),
  CONSTRAINT `FKE125C5CF86527F49` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`id`),
  CONSTRAINT `fk_parent` FOREIGN KEY (`parent_id`) REFERENCES `permission` (`id`),
  CONSTRAINT `fk_permission_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  CONSTRAINT `permission_to_subscription_fk` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES (4,0,'read',1,NULL,'\0',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(6,0,'read',NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(25,0,'stream_get',NULL,NULL,'',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(26,0,'stream_subscribe',NULL,NULL,'',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(27,0,'stream_get',NULL,NULL,'',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(28,0,'stream_subscribe',NULL,NULL,'',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(29,0,'stream_get',5,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(30,0,'stream_subscribe',5,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(31,0,'stream_get',4,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(32,0,'stream_subscribe',4,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(33,0,'stream_get',1,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(34,0,'stream_subscribe',1,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(35,0,'stream_get',1,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(36,0,'stream_subscribe',1,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(38,0,'stream_publish',5,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(41,0,'stream_publish',4,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(43,0,'stream_edit',1,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(44,0,'stream_publish',1,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(45,0,'stream_delete',1,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(46,0,'stream_edit',1,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(47,0,'stream_publish',1,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(48,0,'stream_delete',1,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL),(49,0,'stream_share',1,NULL,'\0',NULL,NULL,'ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,NULL,NULL),(50,0,'stream_share',1,NULL,'\0',NULL,NULL,'YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `beneficiary_address` varchar(255) DEFAULT NULL,
  `category_id` varchar(255) DEFAULT NULL,
  `date_created` datetime NOT NULL,
  `description` longtext,
  `image_url` varchar(2048) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `minimum_subscription_in_seconds` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `owner_address` varchar(255) DEFAULT NULL,
  `preview_config_json` longtext,
  `preview_stream_id` varchar(255) DEFAULT NULL,
  `price_currency` varchar(255) NOT NULL,
  `price_per_second` bigint(20) NOT NULL,
  `state` varchar(255) NOT NULL,
  `block_index` bigint(20) NOT NULL,
  `block_number` bigint(20) NOT NULL,
  `score` int(11) NOT NULL,
  `thumbnail_url` varchar(2048) DEFAULT NULL,
  `owner_id` bigint(20) NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `pending_changes` text,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_social1` varchar(2048) DEFAULT NULL,
  `contact_social2` varchar(2048) DEFAULT NULL,
  `contact_social3` varchar(2048) DEFAULT NULL,
  `contact_social4` varchar(2048) DEFAULT NULL,
  `contact_url` varchar(2048) DEFAULT NULL,
  `terms_of_use_commercial_use` bit(1) NOT NULL,
  `terms_of_use_redistribution` bit(1) NOT NULL,
  `terms_of_use_reselling` bit(1) NOT NULL,
  `terms_of_use_storage` bit(1) NOT NULL,
  `terms_of_use_terms_name` varchar(100) DEFAULT NULL,
  `terms_of_use_terms_url` varchar(2048) DEFAULT NULL,
  `data_union_version` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_product_category` (`category_id`),
  KEY `fk_product_previewstream` (`preview_stream_id`),
  KEY `beneficiary_address_idx` (`beneficiary_address`),
  KEY `owner_address_idx` (`owner_address`),
  KEY `score_idx` (`score`),
  KEY `product_owner_id_idx` (`owner_id`),
  KEY `type_idx` (`type`),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`),
  CONSTRAINT `fk_product_previewstream` FOREIGN KEY (`preview_stream_id`) REFERENCES `stream` (`id`),
  CONSTRAINT `fk_product_user` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_streams`
--

DROP TABLE IF EXISTS `product_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_streams` (
  `stream_id` varchar(255) NOT NULL,
  `product_id` varchar(255) NOT NULL,
  PRIMARY KEY (`product_id`,`stream_id`),
  KEY `fk_productstreams_stream` (`stream_id`),
  KEY `fk_productstreams_product` (`product_id`),
  CONSTRAINT `fk_productstreams_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  CONSTRAINT `fk_productstreams_stream` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_streams`
--

LOCK TABLES `product_streams` WRITE;
/*!40000 ALTER TABLE `product_streams` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registration_code`
--

DROP TABLE IF EXISTS `registration_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registration_code` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date_created` datetime NOT NULL,
  `token` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registration_code`
--

LOCK TABLES `registration_code` WRITE;
/*!40000 ALTER TABLE `registration_code` DISABLE KEYS */;
/*!40000 ALTER TABLE `registration_code` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `authority` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `authority` (`authority`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,0,'ROLE_USER'),(2,0,'ROLE_LIVE'),(3,0,'ROLE_ADMIN'),(7,0,'ROLE_DEV_OPS');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `serialization`
--

DROP TABLE IF EXISTS `serialization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `serialization` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `bytes` longblob NOT NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `serialization`
--

LOCK TABLES `serialization` WRITE;
/*!40000 ALTER TABLE `serialization` DISABLE KEYS */;
/*!40000 ALTER TABLE `serialization` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `signup_invite`
--

DROP TABLE IF EXISTS `signup_invite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `signup_invite` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `code` varchar(255) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `sent` bit(1) NOT NULL,
  `used` bit(1) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `signup_invite`
--

LOCK TABLES `signup_invite` WRITE;
/*!40000 ALTER TABLE `signup_invite` DISABLE KEYS */;
/*!40000 ALTER TABLE `signup_invite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream`
--

DROP TABLE IF EXISTS `stream`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stream` (
  `version` bigint(20) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `first_historical_day` datetime DEFAULT NULL,
  `last_historical_day` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `config` longtext,
  `id` varchar(255) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `partitions` int(11) NOT NULL DEFAULT '1',
  `ui_channel` bit(1) NOT NULL DEFAULT b'0',
  `ui_channel_canvas_id` varchar(255) DEFAULT NULL,
  `ui_channel_path` varchar(1024) DEFAULT NULL,
  `require_signed_data` bit(1) NOT NULL,
  `auto_configure` bit(1) NOT NULL,
  `storage_days` int(11) NOT NULL,
  `example_type` int(11) NOT NULL DEFAULT '0',
  `inactivity_threshold_hours` int(11) NOT NULL,
  `require_encrypted_data` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name_idx` (`name`),
  KEY `uuid_idx` (`id`),
  KEY `FKCAD54F8052E2E25F` (`ui_channel_canvas_id`),
  KEY `ui_channel_path_idx` (`ui_channel_path`),
  KEY `example_type_idx` (`example_type`),
  CONSTRAINT `FKCAD54F8052E2E25F` FOREIGN KEY (`ui_channel_canvas_id`) REFERENCES `canvas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream`
--

LOCK TABLES `stream` WRITE;
/*!40000 ALTER TABLE `stream` DISABLE KEYS */;
INSERT INTO `stream` VALUES (0,'Bitcoin mentions on Twitter',NULL,NULL,'Twitter-Bitcoin','{\"fields\":[{\"name\":\"text\",\"type\":\"string\"},{\"name\":\"user\",\"type\":\"object\"},{\"name\":\"retweet_count\",\"type\":\"number\"},{\"name\":\"favorite_count\",\"type\":\"number\"},{\"name\":\"lang\",\"type\":\"string\"}]}','ln2g8OKHSdi7BcL-bcnh2g','2016-05-31 18:16:00','2016-05-31 18:16:00',1,'\0',NULL,NULL,'\0','',365,0,48,'\0'),(0,'Helsinki tram locations etc.',NULL,NULL,'Public transport demo','{\"fields\":[{\"name\":\"veh\",\"type\":\"string\"},{\"name\":\"lat\",\"type\":\"number\"},{\"name\":\"long\",\"type\":\"number\"},{\"name\":\"spd\",\"type\":\"number\"},{\"name\":\"hdg\",\"type\":\"number\"},{\"name\":\"odo\",\"type\":\"number\"},{\"name\":\"dl\",\"type\":\"number\"},{\"name\":\"desi\",\"type\":\"string\"}]}','YpTAPDbvSAmj-iCUYz-dxA','2016-05-18 18:06:00','2016-05-18 18:06:00',1,'\0',NULL,NULL,'\0','',365,0,48,'\0');
/*!40000 ALTER TABLE `stream` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream_storage_node`
--

DROP TABLE IF EXISTS `stream_storage_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stream_storage_node` (
  `stream_id` varchar(255) NOT NULL,
  `storage_node_address` varchar(255) NOT NULL,
  `date_created` datetime NOT NULL,
  `version` bigint(20) NOT NULL,
  PRIMARY KEY (`stream_id`,`storage_node_address`),
  KEY `stream_storage_node_stream_idx` (`stream_id`),
  KEY `stream_storage_node_storage_node_address_idx` (`storage_node_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream_storage_node`
--

LOCK TABLES `stream_storage_node` WRITE;
/*!40000 ALTER TABLE `stream_storage_node` DISABLE KEYS */;
/*!40000 ALTER TABLE `stream_storage_node` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `class` varchar(255) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_address_and_product_id` (`product_id`,`address`),
  UNIQUE KEY `unique_user_id_and_product_id` (`user_id`,`product_id`),
  KEY `product_idx` (`product_id`),
  KEY `address_idx` (`address`),
  KEY `user_idx` (`user_id`),
  CONSTRAINT `fk_subscription_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `subscription_to_product_fk` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription`
--

LOCK TABLES `subscription` WRITE;
/*!40000 ALTER TABLE `subscription` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task`
--

DROP TABLE IF EXISTS `task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `available` bit(1) NOT NULL,
  `category` varchar(255) NOT NULL,
  `complete` bit(1) NOT NULL,
  `complexity` int(11) NOT NULL DEFAULT '0',
  `config` varchar(1000) NOT NULL,
  `date_created` datetime NOT NULL,
  `error` varchar(1000) DEFAULT NULL,
  `implementing_class` varchar(255) NOT NULL,
  `last_updated` datetime NOT NULL,
  `progress` int(11) NOT NULL DEFAULT '0',
  `run_after` datetime DEFAULT NULL,
  `server_ip` varchar(255) DEFAULT NULL,
  `skip` bit(1) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `task_group_id` varchar(255) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK36358560701D32` (`user_id`),
  KEY `available_idx` (`available`),
  KEY `task_group_id_idx` (`task_group_id`),
  CONSTRAINT `FK36358560701D32` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task`
--

LOCK TABLES `task` WRITE;
/*!40000 ALTER TABLE `task` DISABLE KEYS */;
/*!40000 ALTER TABLE `task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `account_expired` bit(1) NOT NULL,
  `account_locked` bit(1) NOT NULL,
  `enabled` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `password_expired` bit(1) NOT NULL,
  `username` varchar(255) NOT NULL,
  `date_created` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `image_url_large` varchar(255) DEFAULT NULL,
  `image_url_small` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `signup_method` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,255,'\0','\0','','Tester One','$2a$10$z0HZdlGT7tvG6TSw4r/3Z.kqxJO4yM/ON4zX1pQ4TR1Kj3aidO/6q','\0','tester1@streamr.com',NULL,NULL,NULL,NULL,'tester1@streamr.com','UNKNOWN'),(2,0,'\0','\0','','Tester Two','$2a$04$pRVYUUEUC4gQH0Hs4oTjWOS/ldKDm54pSAmHxI.mht9LURLsYqL6y','\0','tester2@streamr.com',NULL,NULL,NULL,NULL,'tester2@streamr.com','UNKNOWN'),(3,0,'\0','\0','','Tester Admin','$2a$04$kUm3C39XUPpVvxKZCO.1I.mL0qQgLN.FRltFVcDjl1jap5W5AP7Te','\0','tester-admin@streamr.com',NULL,NULL,NULL,NULL,'tester-admin@streamr.com','UNKNOWN'),(4,0,'\0','\0','','Anonymous User','R9yySEZXDVW3JHxwAujcMmV4sEGau8yS','\0','0x8ee4945ee4b51af308fd9b87c9bfc9b309a1ef5c',NULL,NULL,NULL,NULL,NULL,'MIGRATED'),(5,0,'\0','\0','','Anonymous User','BkgYispzjLNwdjWBk9XahkkSGghJof2J','\0','0x605fecc0053f7cf08aeb5ad0a14d6456840fd0d9',NULL,NULL,NULL,NULL,NULL,'MIGRATED');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role` (
  `role_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`role_id`,`user_id`),
  KEY `FK6630E2A872C9F44` (`user_id`),
  KEY `FK6630E2AE201DB64` (`role_id`),
  CONSTRAINT `FK6630E2A872C9F44` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `FK6630E2AE201DB64` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
INSERT INTO `user_role` VALUES (1,1),(2,1),(1,2),(1,3),(2,3),(3,3);
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-11-25 16:05:00
