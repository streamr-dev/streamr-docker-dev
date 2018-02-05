USE core_dev;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# Dump of table dashboard
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dashboard`;

CREATE TABLE `dashboard` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKC18AEA9460701D32` (`user_id`),
  CONSTRAINT `FKC18AEA9460701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table dashboard_item
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dashboard_item`;

CREATE TABLE `dashboard_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `dashboard_id` bigint(20) NOT NULL,
  `ord` int(11) NOT NULL,
  `size` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `ui_channel_id` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKF4B0C5DE8A8883E5` (`ui_channel_id`),
  KEY `FKF4B0C5DE70E281EB` (`dashboard_id`),
  CONSTRAINT `FKF4B0C5DE70E281EB` FOREIGN KEY (`dashboard_id`) REFERENCES `dashboard` (`id`),
  CONSTRAINT `FKF4B0C5DE8A8883E5` FOREIGN KEY (`ui_channel_id`) REFERENCES `ui_channel` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table DATABASECHANGELOG
# ------------------------------------------------------------

DROP TABLE IF EXISTS `DATABASECHANGELOG`;

CREATE TABLE `DATABASECHANGELOG` (
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

LOCK TABLES `DATABASECHANGELOG` WRITE;
/*!40000 ALTER TABLE `DATABASECHANGELOG` DISABLE KEYS */;

INSERT INTO `DATABASECHANGELOG` (`ID`, `AUTHOR`, `FILENAME`, `DATEEXECUTED`, `ORDEREXECUTED`, `EXECTYPE`, `MD5SUM`, `DESCRIPTION`, `COMMENTS`, `TAG`, `LIQUIBASE`)
VALUES
	('1452618584552-1','admin (generated)','core/2015-01-12-initial-database.groovy','2016-01-12 17:14:09',1,'EXECUTED',NULL,'Add Not-Null Constraint','',NULL,'2.0.5'),
	('1452618584552-2','admin (generated)','core/2015-01-12-initial-database.groovy','2016-01-12 17:14:09',2,'EXECUTED',NULL,'Add Not-Null Constraint','',NULL,'2.0.5'),
	('1452618584552-3','admin (generated)','core/2015-01-12-initial-database.groovy','2016-01-12 17:14:10',3,'EXECUTED',NULL,'Add Not-Null Constraint','',NULL,'2.0.5'),
	('1452618584552-4','admin (generated)','core/2015-01-12-initial-database.groovy','2016-01-12 17:14:10',4,'EXECUTED',NULL,'Create Index','',NULL,'2.0.5'),
	('1452618584552-5','admin (generated)','core/2015-01-12-initial-database.groovy','2016-01-12 17:14:11',5,'EXECUTED',NULL,'Drop Column','',NULL,'2.0.5'),
	('1452618584552-6','admin (generated)','core/2015-01-12-initial-database.groovy','2016-01-12 17:14:11',6,'EXECUTED',NULL,'Drop Column','',NULL,'2.0.5'),
	('1452621480175-1','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',7,'EXECUTED','3:b2b2d7e24f2a16295f8bd08a0eedf65f','Create Table','',NULL,'2.0.5'),
	('1452621480175-10','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',16,'EXECUTED','3:3c4a3d84d03be09f6397f8ad987611e3','Create Table','',NULL,'2.0.5'),
	('1452621480175-11','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',17,'EXECUTED','3:b376189579b86897da90888bb1a16934','Create Table','',NULL,'2.0.5'),
	('1452621480175-12','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',18,'EXECUTED','3:0651020f7f7592be6fd028c661a41e81','Create Table','',NULL,'2.0.5'),
	('1452621480175-13','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',19,'EXECUTED','3:a156caec84bcfb0cd7ff0e02b0213ff1','Create Table','',NULL,'2.0.5'),
	('1452621480175-14','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',20,'EXECUTED','3:a0a0888a9cb5ccb1a9c8fd603f445f5a','Create Table','',NULL,'2.0.5'),
	('1452621480175-15','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',21,'EXECUTED','3:dac4a7dcd33e94be045cb3768c9d3b20','Create Table','',NULL,'2.0.5'),
	('1452621480175-16','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',22,'EXECUTED','3:e2dacf8eac6734cc8adaae557e5fb875','Create Table','',NULL,'2.0.5'),
	('1452621480175-17','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',23,'EXECUTED','3:5e379b0e61e1ce4dd07919880bb26442','Create Table','',NULL,'2.0.5'),
	('1452621480175-18','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',24,'EXECUTED','3:c3563126837b47adfc2ea02128c97206','Create Table','',NULL,'2.0.5'),
	('1452621480175-19','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',25,'EXECUTED','3:3930afe6d78226872bdbd09cf6659e5f','Create Table','',NULL,'2.0.5'),
	('1452621480175-2','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',8,'EXECUTED','3:de5f6195080e0680f0573a97783c9f4a','Create Table','',NULL,'2.0.5'),
	('1452621480175-20','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',26,'EXECUTED','3:2bdb1f820ccf5b54ef44c96a5292da1f','Create Table','',NULL,'2.0.5'),
	('1452621480175-21','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',27,'EXECUTED','3:fe4e81cb05df66e55845e415b73a81ae','Create Table','',NULL,'2.0.5'),
	('1452621480175-22','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',28,'EXECUTED','3:4bbd0e95ed31d3bef3d0e061e1a05b7c','Add Primary Key','',NULL,'2.0.5'),
	('1452621480175-23','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',29,'EXECUTED','3:6be02aa5110964a623bc1dcabf4bf813','Add Primary Key','',NULL,'2.0.5'),
	('1452621480175-24','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',30,'EXECUTED','3:3ad019ea3784e14a15621a13ed680f10','Add Primary Key','',NULL,'2.0.5'),
	('1452621480175-25','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',31,'EXECUTED','3:c596c19635be96e4f71d57916dd35210','Add Primary Key','',NULL,'2.0.5'),
	('1452621480175-26','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',32,'EXECUTED','3:7b7992cfa71b7d0b7237e057b5fa22bc','Add Primary Key','',NULL,'2.0.5'),
	('1452621480175-27','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',45,'EXECUTED','3:9fa56e34dc406c29c8fb86f07a8a6922','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-28','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',46,'EXECUTED','3:11dac7535e0e73d4c970fc5736b02872','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-29','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',47,'EXECUTED','3:6f59d0236c6417cabebea236bc040a3c','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-3','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',9,'EXECUTED','3:f1e26317b7a9040de779e9b558488b77','Create Table','',NULL,'2.0.5'),
	('1452621480175-30','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',48,'EXECUTED','3:252c9826d4cd5584431e1ad5bbc37caa','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-31','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',49,'EXECUTED','3:63a42ed699f8f7743602c659c6e7c3f7','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-32','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',50,'EXECUTED','3:a07b7fb8dc8705befdfb12939e3b03f2','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-33','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',51,'EXECUTED','3:0bd78e22bfe2f3331ec5f5d5d5ec8bc7','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-34','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',52,'EXECUTED','3:4949be6d72d63a8bc3a4d9188d145397','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-35','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',53,'EXECUTED','3:9e629cb5e2fb22636d7ba9f4d336e0b7','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-36','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',54,'EXECUTED','3:254c1caa2afb371cc642bac26ab18261','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-37','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',55,'EXECUTED','3:ab27a79f7070fe54a51777b2e896abef','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-38','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',56,'EXECUTED','3:7df0325fada928abd561197818cb130d','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-39','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',57,'EXECUTED','3:27fbc060d5790074ebe80e5422cd445b','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-4','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',10,'EXECUTED','3:100e33a3530d297342baffe45f7e27eb','Create Table','',NULL,'2.0.5'),
	('1452621480175-40','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',58,'EXECUTED','3:cfc124633dfd4ac805fbc4d86837aa49','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-41','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',59,'EXECUTED','3:1a9eeca59ca6c7f53b94e309a9acbccb','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-42','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',60,'EXECUTED','3:6af8f7b0175b37d120902978f21dd2e5','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-43','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',61,'EXECUTED','3:057b7e135f7672510eae79c0b4115c6a','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-44','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:18',62,'EXECUTED','3:3a1f8a3a680b394f94fd68268a1e24cf','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-45','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',63,'EXECUTED','3:1b253d07ac604613750771b9a820be45','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-46','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',64,'EXECUTED','3:f221a0ff36b963987cdbd922faa558cb','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-47','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',65,'EXECUTED','3:81a104bea3e9d1a9b5fa8471fa10d3b8','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-48','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',66,'EXECUTED','3:a65b220252450a2eb6cf7d15f469a1d1','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-49','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',67,'EXECUTED','3:08dddce09f4c80d99e5b83473eae8a00','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-5','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',11,'EXECUTED','3:4a41e808998af876fee0d88dad26f20c','Create Table','',NULL,'2.0.5'),
	('1452621480175-50','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',68,'EXECUTED','3:faff6fb17b642b6f540f081aa1ac71c2','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-51','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:19',69,'EXECUTED','3:f12cc628c18d5f2edd64ef82577f61e3','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452621480175-52','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',33,'EXECUTED','3:f26d1407d377e14f6bad8904b1042b9a','Create Index','',NULL,'2.0.5'),
	('1452621480175-53','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',34,'EXECUTED','3:909a924feb27444bb1463f7ad8c180b1','Create Index','',NULL,'2.0.5'),
	('1452621480175-54','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',35,'EXECUTED','3:f69d2e295a03f85dd065d6e542bd7419','Create Index','',NULL,'2.0.5'),
	('1452621480175-55','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',36,'EXECUTED','3:f32bf5446d9e06b9fb9a989ae38155f0','Create Index','',NULL,'2.0.5'),
	('1452621480175-56','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:16',37,'EXECUTED','3:d0bbb449a2a88e7762bbc66dc5601f91','Create Index','',NULL,'2.0.5'),
	('1452621480175-57','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',38,'EXECUTED','3:e217e5c318a00e4f18a8f8592c1a2e57','Create Index','',NULL,'2.0.5'),
	('1452621480175-58','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',39,'EXECUTED','3:8ef9a3a2775a9c173a474353cba1a73d','Create Index','',NULL,'2.0.5'),
	('1452621480175-59','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',40,'EXECUTED','3:2e54070dfd0075bcd616d84bdbdfacc9','Create Index','',NULL,'2.0.5'),
	('1452621480175-6','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',12,'EXECUTED','3:1858f0e1ffe21c81ebb1c89a4fc7477b','Create Table','',NULL,'2.0.5'),
	('1452621480175-60','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',41,'EXECUTED','3:081a744bdb270d423ab26389f6aa0d55','Create Index','',NULL,'2.0.5'),
	('1452621480175-61','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',42,'EXECUTED','3:50fba8f52796c9e04824ed64729347c2','Create Index','',NULL,'2.0.5'),
	('1452621480175-62','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',43,'EXECUTED','3:d23f2f753096c355b57b249872fd14c0','Create Index','',NULL,'2.0.5'),
	('1452621480175-63','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:17',44,'EXECUTED','3:6f0764a12d55858f1e1ab4135f5cc4b4','Create Index','',NULL,'2.0.5'),
	('1452621480175-7','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:14',13,'EXECUTED','3:7bed1e54b247e9f20d66ce44dfd0889a','Create Table','',NULL,'2.0.5'),
	('1452621480175-8','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',14,'EXECUTED','3:fb3fca294e3eb9621cace2921b8de500','Create Table','',NULL,'2.0.5'),
	('1452621480175-9','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',15,'EXECUTED','3:c79769b52ad9640ff4e86cdc0134fac6','Create Table','',NULL,'2.0.5');

/*!40000 ALTER TABLE `DATABASECHANGELOG` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table DATABASECHANGELOGLOCK
# ------------------------------------------------------------

DROP TABLE IF EXISTS `DATABASECHANGELOGLOCK`;

CREATE TABLE `DATABASECHANGELOGLOCK` (
  `ID` int(11) NOT NULL,
  `LOCKED` tinyint(1) NOT NULL,
  `LOCKGRANTED` datetime DEFAULT NULL,
  `LOCKEDBY` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `DATABASECHANGELOGLOCK` WRITE;
/*!40000 ALTER TABLE `DATABASECHANGELOGLOCK` DISABLE KEYS */;

INSERT INTO `DATABASECHANGELOGLOCK` (`ID`, `LOCKED`, `LOCKGRANTED`, `LOCKEDBY`)
VALUES
	(1,0,NULL,NULL);

/*!40000 ALTER TABLE `DATABASECHANGELOGLOCK` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table feed
# ------------------------------------------------------------

DROP TABLE IF EXISTS `feed`;

CREATE TABLE `feed` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `backtest_feed` varchar(255) DEFAULT NULL,
  `bundled_feed_files` bit(1) DEFAULT NULL,
  `cache_class` varchar(255) DEFAULT NULL,
  `cache_config` varchar(255) DEFAULT NULL,
  `directory` varchar(255) DEFAULT NULL,
  `discovery_util_class` varchar(255) DEFAULT NULL,
  `discovery_util_config` varchar(255) DEFAULT NULL,
  `event_recipient_class` varchar(255) NOT NULL,
  `feed_config` varchar(255) DEFAULT NULL,
  `key_provider_class` varchar(255) NOT NULL,
  `message_source_class` varchar(255) NOT NULL,
  `message_source_config` varchar(255) DEFAULT NULL,
  `module_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `parser_class` varchar(255) NOT NULL,
  `preprocessor` varchar(255) DEFAULT NULL,
  `realtime_feed` varchar(255) DEFAULT NULL,
  `start_on_demand` bit(1) DEFAULT NULL,
  `timezone` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK2FE59EB6140F06` (`module_id`),
  CONSTRAINT `FK2FE59EB6140F06` FOREIGN KEY (`module_id`) REFERENCES `module` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `feed` WRITE;
/*!40000 ALTER TABLE `feed` DISABLE KEYS */;

INSERT INTO `feed` (`id`, `version`, `backtest_feed`, `bundled_feed_files`, `cache_class`, `cache_config`, `directory`, `discovery_util_class`, `discovery_util_config`, `event_recipient_class`, `feed_config`, `key_provider_class`, `message_source_class`, `message_source_config`, `module_id`, `name`, `parser_class`, `preprocessor`, `realtime_feed`, `start_on_demand`, `timezone`)
VALUES
	(7,0,'com.unifina.feed.kafka.KafkaHistoricalFeed',NULL,NULL,NULL,'core_test_streams','com.unifina.feed.kafka.KafkaFeedFileDiscoveryUtil','{\r\n  \"pattern\": \".gz$\",\r\n  \"prefix\": \"user_stream\"\r\n}','com.unifina.feed.map.MapMessageEventRecipient','{ \"directory\": \"core_test_streams\" }','com.unifina.feed.kafka.KafkaKeyProvider','com.unifina.feed.kafka.KafkaMessageSource',NULL,147,'User Stream','com.unifina.feed.kafka.KafkaMessageParser','com.unifina.feed.NoOpFeedPreprocessor','com.unifina.feed.kafka.KafkaFeed',b'1','UTC');

/*!40000 ALTER TABLE `feed` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table feed_file
# ------------------------------------------------------------

DROP TABLE IF EXISTS `feed_file`;

CREATE TABLE `feed_file` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `begin_date` datetime NOT NULL,
  `day` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `feed_id` bigint(20) NOT NULL,
  `format` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `process_task_created` bit(1) DEFAULT NULL,
  `processed` bit(1) NOT NULL,
  `processing` bit(1) DEFAULT NULL,
  `stream_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK9DFF9B7D86527F49` (`stream_id`),
  KEY `FK9DFF9B7D72507A49` (`feed_id`),
  CONSTRAINT `FK9DFF9B7D72507A49` FOREIGN KEY (`feed_id`) REFERENCES `feed` (`id`),
  CONSTRAINT `FK9DFF9B7D86527F49` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table feed_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `feed_user`;

CREATE TABLE `feed_user` (
  `user_id` bigint(20) NOT NULL,
  `feed_id` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`,`feed_id`),
  KEY `FK9E0691CC60701D32` (`user_id`),
  KEY `FK9E0691CC72507A49` (`feed_id`),
  CONSTRAINT `FK9E0691CC60701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`),
  CONSTRAINT `FK9E0691CC72507A49` FOREIGN KEY (`feed_id`) REFERENCES `feed` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `feed_user` WRITE;
/*!40000 ALTER TABLE `feed_user` DISABLE KEYS */;

INSERT INTO `feed_user` (`user_id`, `feed_id`)
VALUES
	(1,7);

/*!40000 ALTER TABLE `feed_user` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table host_config
# ------------------------------------------------------------

DROP TABLE IF EXISTS `host_config`;

CREATE TABLE `host_config` (
  `host` varchar(255) NOT NULL,
  `parameter` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`host`,`parameter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table module
# ------------------------------------------------------------

DROP TABLE IF EXISTS `module`;

CREATE TABLE `module` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `implementing_class` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `js_module` varchar(255) NOT NULL,
  `hide` bit(1) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `module_package_id` bigint(20) DEFAULT NULL,
  `json_help` longtext,
  `alternative_names` varchar(255) DEFAULT NULL,
  `webcomponent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKC04BA66C28AB0672` (`category_id`),
  KEY `FKC04BA66C96E04B35` (`module_package_id`),
  CONSTRAINT `FKC04BA66C28AB0672` FOREIGN KEY (`category_id`) REFERENCES `module_category` (`id`),
  CONSTRAINT `FKC04BA66C96E04B35` FOREIGN KEY (`module_package_id`) REFERENCES `module_package` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `module` WRITE;
/*!40000 ALTER TABLE `module` DISABLE KEYS */;

INSERT INTO `module` (`id`, `version`, `category_id`, `implementing_class`, `name`, `js_module`, `hide`, `type`, `module_package_id`, `json_help`, `alternative_names`, `webcomponent`)
VALUES
	(1,4,1,'com.unifina.signalpath.simplemath.Multiply','Multiply','GenericModule',NULL,'module',1,'{\"outputNames\":[\"A*B\"],\"inputs\":{\"A\":\"The first value to be multiplied\",\"B\":\"The second value to be multiplied\"},\"helpText\":\"<p>This module calculates the product of two numeric input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A*B\":\"The product of the inputs\"},\"paramNames\":[]}','Times',NULL),
	(2,4,2,'com.unifina.signalpath.filtering.SimpleMovingAverageEvents','MovingAverage','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module calculates the simple moving average (MA, SMA) of values arriving at the input. Each value is assigned equal weight. The moving average is calculated based on a sliding window of adjustable length.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of input values received before a value is output\",\"length\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\"},\"outputs\":{\"out\":\"The moving average\"},\"paramNames\":[\"length\",\"minSamples\"]}','SMA',NULL),
	(3,7,1,'com.unifina.signalpath.simplemath.Add','Add','GenericModule',b'1','module',5,'{\"outputNames\":[\"A+B\"],\"inputs\":{\"A\":\"First value to be added\",\"B\":\"Second value to be added\"},\"helpText\":\"<p>This module adds together two numeric input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A+B\":\"Sum of the two inputs\"},\"paramNames\":[]}','Plus',NULL),
	(4,4,1,'com.unifina.signalpath.simplemath.Subtract','Subtract','GenericModule',NULL,'module',1,'{\"outputNames\":[\"A-B\"],\"inputs\":{\"A\":\"Value to subtract from\",\"B\":\"Value to be subtracted\"},\"helpText\":\"<p>This module calculates the difference of its two input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A-B\":\"The difference\"},\"paramNames\":[]}','Minus',NULL),
	(5,5,3,'com.unifina.signalpath.utils.Constant','Constant','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>This module represents a constant numeric value that can be connected to any numeric input. The input will have that value during the whole execution.</p>\",\"inputNames\":[],\"params\":{\"constant\":\"The value to output\"},\"outputs\":{\"out\":\"The value of the parameter\"},\"paramNames\":[\"constant\"]}','Number',NULL),
	(6,5,1,'com.unifina.signalpath.simplemath.Divide','Divide','GenericModule',NULL,'module',1,'{\"outputNames\":[\"A/B\"],\"inputs\":{\"A\":\"The dividend, or numerator\",\"B\":\"The divisor, or denominator\"},\"helpText\":\"<p>This module calculates the quotient of its two input values. If the input <span class=\'highlight\'>B</span> is zero, the result is not defined and thus no output is produced.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A/B\":\"The quotient: A divided by B\"},\"paramNames\":[]}',NULL,NULL),
	(7,7,19,'com.unifina.signalpath.utils.Delay','Delay','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Incoming values to be delayed\"},\"helpText\":\"<p>This module will delay the received values by a number of events. For example, if the <span class=\'highlight\'> delayEvents</span> parameter is set to 1, the module will always output the previous value received.\\n</p><p>\\nThe module will not produce output until the <span class=\'highlight\'>delayEvents+1</span>th event, at which point the first received value will be output. For example, if the parameter is set to 2, the following sequence would be produced:\\n</p><p>\\n<table>\\n<tr><th>Input<\\/th><th>Output<\\/th><\\/tr>\\n<tr><td>1<\\/td><td>(no value)<\\/td><\\/tr>\\n<tr><td>2<\\/td><td>(no value)<\\/td><\\/tr>\\n<tr><td>3<\\/td><td>1<\\/td><\\/tr>\\n<tr><td>4<\\/td><td>2<\\/td><\\/tr>\\n<tr><td>...<\\/td><td>...<\\/td><\\/tr>\\n<\\/table></p>\",\"inputNames\":[\"in\"],\"params\":{\"delayEvents\":\"Number of events to delay the incoming values\"},\"outputs\":{\"out\":\"The delayed values\"},\"paramNames\":[\"delayEvents\"]}',NULL,NULL),
	(11,6,1,'com.unifina.signalpath.simplemath.ChangeAbsolute','ChangeAbsolute','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the difference between the received value and the previous received value, or <span class=\'highlight\'>in(t)&nbsp;-&nbsp;in(t-1)</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Difference',NULL),
	(16,6,19,'com.unifina.signalpath.utils.Barify','Barify','GenericModule',NULL,'module',1,'{\"outputNames\":[\"open\",\"high\",\"low\",\"close\",\"avg\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This is a utility for moving from event time to wall-clock time. This module outputs new values every <span class=\'highlight\'>barLength</span> seconds. You would use this module to sample a time series every 60 seconds, for example.</p>\",\"inputNames\":[\"in\"],\"params\":{\"barLength\":\"Length of the bar (time interval) in seconds\"},\"outputs\":{\"open\":\"Value at start of period\",\"high\":\"Maximum value during period\",\"avg\":\"Simple average of values received during the period\",\"low\":\"Minimum value during period\",\"close\":\"Value at end of period (the most recent value)\"},\"paramNames\":[\"barLength\"]}','Time',NULL),
	(19,4,27,'com.unifina.signalpath.text.ConstantString','ConstantText','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>This module represents a constant text value that can be connected to any input that accepts text.</p>\",\"inputNames\":[],\"params\":{\"str\":\"The text constant\"},\"outputs\":{\"out\":\"Outputs the text constant\"},\"paramNames\":[\"str\"]}','ConstantString, String',NULL),
	(24,4,7,'com.unifina.signalpath.trigger.ZeroCross','ZeroCross','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module is used to detect when a time series crosses the zero line. It outputs -1 when below zero (minus threshold) and +1 when above zero (plus threshold).</p>\",\"inputNames\":[\"in\"],\"params\":{\"strictMode\":\"In strict mode, the incoming series actually needs to cross the trigger line before an output is produced. Otherwise a value is produced on the first event above or below the trigger line.\",\"threshold\":\"Zero or a positive value indicating the distance beyond zero that the incoming series must reach before a different output is triggered\"},\"outputs\":{\"out\":\"-1 or +1\"},\"paramNames\":[\"strictMode\",\"threshold\"]}',NULL,NULL),
	(25,4,7,'com.unifina.signalpath.trigger.ThreeZones','ThreeZones','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Incoming value\"},\"helpText\":\"<p>This module outputs -1, 0 or +1 depending on whether the input value is below <span class=\'highlight\'>lowZone</span>, between <span class=\'highlight\'>lowZone</span> and <span class=\'highlight\'>highZone</span>, or above <span class=\'highlight\'>highZone</span> respectively.</p>\",\"inputNames\":[\"in\"],\"params\":{\"highZone\":\"The high limit\",\"lowZone\":\"The low limit\"},\"outputs\":{\"out\":\"-1, 0 or +1 depending on which zone the input value is in\"},\"paramNames\":[\"highZone\",\"lowZone\"]}',NULL,NULL),
	(27,12,1,'com.unifina.signalpath.simplemath.Abs','Abs','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"The original value\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"The absolute value of the original value\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Outputs the absolute value (positive value with original sign stripped) of the input.</p>\\n\"}','Absolute',NULL),
	(28,5,1,'com.unifina.signalpath.simplemath.Negate','Negate','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the negated input value <span class=\'highlight\'>-1 * in</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Negation',NULL),
	(29,5,1,'com.unifina.signalpath.simplemath.Invert','Invert','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"<span></span>\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"<span></span>\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Outputs the multiplicative inverse (reciprocal) of the input (1/in, in^-1).</p>\"}','Reciprocal, Inverse',NULL),
	(30,5,10,'com.unifina.signalpath.bool.And','And','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Implements the boolean AND operation: outputs 1 if <span class=\'highlight\'>both</span> inputs equal 1, otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(31,4,10,'com.unifina.signalpath.bool.Or','Or','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Implements the boolean OR operation: outputs 1 if <span class=\'highlight\'>at least one</span> of the inputs equal 1, otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(32,4,10,'com.unifina.signalpath.bool.Not','Not','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Implements the boolean NOT operation: outputs 0 if the input equals 1, otherwise outputs 1.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(33,4,10,'com.unifina.signalpath.bool.SameSign','SameSign','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 0 unless both inputs have the same sign. If both inputs are positive, the output is 1. If both are negative, the output is -1.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(34,4,1,'com.unifina.signalpath.simplemath.Sign','Sign','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the sign of the input: -1 if the input is negative, 0 if the input is zero, and 1 if the input is positive.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(35,4,1,'com.unifina.signalpath.simplemath.ChangeRelative','ChangeRelative','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the received value divided by the previous received value, or <span class=\'highlight\'>in(t)&nbsp;/&nbsp;in(t-1)</span>. If the previous received value is zero, the result is undefined and no output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Return',NULL),
	(45,6,10,'com.unifina.signalpath.bool.Equals','Equals','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if the inputs are equal within the specified <span class=\'highlight\'>tolerance</span>, that is, if abs(A-B)&nbsp;&le;&nbsp;tolerance. Otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','=',NULL),
	(46,6,10,'com.unifina.signalpath.bool.GreaterThan','GreaterThan','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if <span class=\'highlight\'>A</span> is greater than <span class=\'highlight\'>B</span> (A&gt;B). If <span class=\'highlight\'>equality</span> is set to true, outputs 1 if A&ge;B. Otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','>',NULL),
	(47,4,10,'com.unifina.signalpath.bool.LessThan','LessThan','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if <span class=\'highlight\'>A</span> is less than <span class=\'highlight\'>B</span> (A&lt;B). If <span class=\'highlight\'>equality</span> is set to true, outputs 1 if A&le;B. Otherwise outputs 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','<',NULL),
	(48,4,10,'com.unifina.signalpath.bool.IfThenElse','IfThenElse','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>If the value at the <span class=\'highlight\'>if</span> input is 1, then outputs the value present at the <span class=\'highlight\'>then</span> input. Otherwise outputs the value at <span class=\'highlight\'>else</span> input.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Condition',NULL),
	(49,5,7,'com.unifina.signalpath.trigger.PeakDetect','Peak','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input time series\"},\"helpText\":\"<p>Attempts to detect upward turns below <span class=\'highlight\'>lowZone</span> (outputs 1) and downward turns below <span class=\'highlight\'>highZone</span> (outputs -1).\\n</p><p>\\nFor an upward turn to be registered, the change between subsequent input values must be larger than <span class=\'highlight\'>threshold</span>. For a downward turn the change must be less than <span class=\'highlight\'>-threshold</span>.</p>\",\"inputNames\":[\"in\"],\"params\":{\"highZone\":\"The level above which a downward turn can occur\",\"lowZone\":\"The level below which an upward turn can occur\",\"threshold\":\"The minimum change in the correct direction between subsequent input values that is allowed to trigger a turn\"},\"outputs\":{\"out\":\"1 for upward turn and -1 for downward turn\"},\"paramNames\":[\"highZone\",\"lowZone\",\"threshold\"]}',NULL,NULL),
	(51,5,12,'com.unifina.signalpath.statistics.LinearRegressionXY','UnivariateLinearRegression','GenericModule',NULL,'module',1,'{\"outputNames\":[\"slope\",\"intercept\",\"error\",\"R^2\"],\"inputs\":{\"inX\":\"Input X values\",\"inY\":\"Input Y values\"},\"helpText\":\"<p>Performs a least-squares linear regression on a sliding window of input data. The model is <span class=\'highlight\'>y&nbsp;=&nbsp;slope*X&nbsp;+&nbsp;intercept.</p>\",\"inputNames\":[\"inX\",\"inY\"],\"params\":{\"windowLength\":\"Length of the sliding window as number of samples\"},\"outputs\":{\"error\":\"Mean square error (MSE) of the fit\",\"intercept\":\"Intercept of the linear fit\",\"slope\":\"Slope of the linear fit\",\"R^2\":\"R-squared value of the fit\"},\"paramNames\":[\"windowLength\"]}',NULL,NULL),
	(53,4,1,'com.unifina.signalpath.simplemath.Sum','Sum','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Values to be summed\"},\"helpText\":\"<p>Calculates the (optionally rolling) sum of incoming values. For an infinite sum, enter a <span class=\'highlight\'>windowLength</span> of 0.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"How many values must exist in the window before outputting a value\",\"windowLength\":\"Length of the sliding window of values to be summed, or 0 for infinite\"},\"outputs\":{\"out\":\"Sum of values in the window\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),
	(54,4,12,'com.unifina.signalpath.statistics.PearsonsCorrelation','Correlation','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates (Pearson\'s) correlation between two input variables in a sliding window of length <span class=\'highlight\'>windowLength</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(55,4,12,'com.unifina.signalpath.statistics.SpearmansRankCorrelation','SpearmansRankCorrelation','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates Spearman\'s Rank correlation between two input variables in a sliding window of length <span class=\'highlight\'>windowLength</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(56,4,12,'com.unifina.signalpath.statistics.Covariance','Covariance','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the covariance of two input variables in a sliding window of length <span class=\'highlight\'>windowLength</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(60,4,28,'com.unifina.signalpath.time.TimeOfDay','TimeOfDay','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>Outputs 1 if the current time of day (in the time zone your user account is set to) is between <span class=\'highlight\'>startTime</span> and <span class=\'highlight\'>endTime</span> (both inclusive). At other times outputs 0.\\n</p>\",\"inputNames\":[],\"params\":{\"startTime\":\"24 hour format HH:MM:SS\",\"endTime\":\"24 hour format HH:MM:SS\"},\"outputs\":{\"out\":\"1 between the given times, otherwise 0\"},\"paramNames\":[\"startTime\",\"endTime\"]}',NULL,NULL),
	(61,5,1,'com.unifina.signalpath.simplemath.Min','Min','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the lesser one of the two input values. For finding the minimum in a window of values, see the <span class=\'highlight\'>Min (window)</span> module.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Minimum, Smallest',NULL),
	(62,5,1,'com.unifina.signalpath.simplemath.Max','Max','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the greater one of the two input values. For finding the maximum in a window of values, see the <span class=\\\"highlight\\\">Max (window)</span> module.</p>\"}','Maximum, Largest',NULL),
	(67,11,13,'com.unifina.signalpath.charts.TimeSeriesChart','Chart','ChartModule',NULL,'chart dashboard',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module is the main tool for visualizing time series. The chart is updated on fly as new data becomes available. You can zoom the chart by dragging over the area you want to zoom to. To pan the chart while zoomed, use the <span class=\'highlight\'>navigator</span> below the chart. Individual series can be toggled on or off by clicking on the series name in the <span class=\'highlight\'>legend</span>. Also note that the chart module can be resized by dragging from its lower right corner.\\n</p><p>\\nEach input series is drawn on y-axis 1 by default. You can edit y-axis assignments by clicking the button beside the input endpoint.\\n</p><p>\\nThe number of inputs is adjustable in the module <span class=\'highlight\'>options</span> (the wrench icon). Other options include ignoring data points outside a certain time of day.\\n</p><p>\\nThe module can also produce a downloadable CSV file containing whatever data points are sent to the chart. To use this feature, run in CSV export mode by selecting that option from the Run button dropdown menu.</p>\"}','Plot, Graph','streamr-chart'),
	(70,5,2,'com.unifina.signalpath.filtering.FastMODWT','MODWT','GenericModule',NULL,'module',1,'{\"params\":{\"wavelet\":\"<span>Chosen wavelet filter</span>\",\"level\":\"<span>Transform level (1..N)</span>\"},\"paramNames\":[\"wavelet\",\"level\"],\"inputs\":{\"in\":\"<span>Input time series</span>\"},\"inputNames\":[\"in\"],\"outputs\":{\"details\":\"<span>The wavelet detail</span>\",\"energy\":\"<span>Energy at this level</span>\",\"smooth\":\"<span>The wavelet smooth</span>\"},\"outputNames\":[\"details\",\"energy\",\"smooth\"],\"helpText\":\"<p>This module implements a realtime maximal overlap discrete wavelet transform (MODWT). A number of different wavelets are available.\\n</p><p>\\nNote that, like all filters, the MODWT introduces increasing amounts of delay with higher levels of smoothing. No additional delay is added to any level - this means that a multi-level decomposition is not aligned at a given time. Reconstructing the original signal would require adding delay to all but the last level.</p>\"}','Wavelet',NULL),
	(81,5,3,'com.unifina.signalpath.SignalPath','Canvas','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to reuse a Canvas saved into the Archive as a module in your current Canvas. This enables reuse and abstraction of functionality and helps keep your Canvases tidy and modular.\\n</p><p>\\nAny parameters, inputs or outputs you export will be visible on the module. You can export endpoints by right-clicking on them and selecting \\\"Toggle export\\\".</p>\"}','Saved, Module',NULL),
	(84,4,7,'com.unifina.signalpath.trigger.FourZones','FourZones','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module waits for the input signal to reach either the <span class=\'highlight\'>highTrigger</span> or <span class=\'highlight\'>lowTrigger</span> level. Either 1 or -1 is output respectively. The triggered value is kept until it is set back to 0 at the corresponding release level.\\n</p><p>\\nIf you set <span class=\'highlight\'>mode</span> to <span class=\'highlight\'>exit</span>, the output will trigger when exiting the trigger level instead of entering it.</p>\",\"inputNames\":[\"in\"],\"params\":{\"lowRelease\":\"Low release level\",\"highTrigger\":\"High trigger level\",\"lowTrigger\":\"Low trigger level\",\"highRelease\":\"High release level\",\"mode\":\"Trigger on entering/exiting the high/low trigger level\"},\"outputs\":{\"out\":\"1 on high trigger, -1 on low trigger, 0 on release\"},\"paramNames\":[\"mode\",\"highTrigger\",\"highRelease\",\"lowRelease\",\"lowTrigger\"]}',NULL,NULL),
	(85,4,7,'com.unifina.signalpath.trigger.Sampler','Sampler','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module can be used to sample values from one timeseries upon events from another timeseries.\\n</p><p>\\nAn event arriving at the <span class=\'highlight\'>trigger</span> input will cause the module to send out whatever value the <span class=\'highlight\'>value</span> input has. The <span class=\'highlight\'>trigger</span> is the only <span class=\'highlight\'>driving input</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(87,6,1,'com.unifina.signalpath.simplemath.ChangeLogarithmic','ChangeLogarithmic','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the logarithmic difference (log return) between the received value and the previous received value, or <span class=\\\"highlight\\\">log[in(t)]&nbsp;-&nbsp;log[in(t-1)]</span>.</p>\\n\"}',NULL,NULL),
	(90,4,19,'com.unifina.signalpath.utils.PassThrough','PassThrough','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module just sends out whatever it receives.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(96,9,2,'com.unifina.signalpath.filtering.ExponentialMovingAverage','MovingAverageExp','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Smooths the incoming time series by calculating an exponential moving average (EMA)</p>\\n\\n<ul>\\n\\t<li><span class=\\\"formula\\\">EMA(t) = a x&nbsp;<strong>in</strong>(t) + (1-a) x&nbsp;EMA(t-1)</span></li>\\n\\t<li><span class=\\\"formula\\\">a = <span class=\\\"math-tex\\\">\\\\(2 \\\\over \\\\text{length} + 1\\\\)</span></span></li>\\n</ul>\\n\"}','EMA',NULL),
	(98,5,11,'com.unifina.signalpath.modeling.ARIMA','ARIMA','GenericModule',NULL,'module',1,'{\"outputNames\":[\"pred\"],\"inputs\":{\"in\":\"Incoming time series\"},\"helpText\":\"<p>Evaluates an ARIMA prediction model with given parameters. Check the module options to set the number of autoregressive and moving average parameters. Model fitting is not (yet) implemented.</p>\",\"inputNames\":[\"in\"],\"params\":{},\"outputs\":{\"pred\":\"ARIMA prediction\"},\"paramNames\":[]}',NULL,NULL),
	(100,5,1,'com.unifina.signalpath.simplemath.AddMulti','Add','GenericModule',NULL,'module',1,'{\"outputNames\":[\"sum\"],\"inputs\":{},\"helpText\":\"<p>Adds together two or more numeric input values. The number of inputs can be adjusted in module options.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{\"sum\":\"Sum of inputs\"},\"paramNames\":[]}','Plus',NULL),
	(115,4,1,'com.unifina.signalpath.simplemath.Ln','LogNatural','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the natural logarithm of the input value.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(116,7,1,'com.unifina.signalpath.simplemath.LinearMapper','LinearMapper','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Linearly transforms a range of incoming (x) values to a range of outgoing (y) values. For example, this could be used to transform the input range of -1...1 (<span class=\'highlight\'>xMin</span>...<span class=\'highlight\'>xMax</span>) into an output range of 0...1000 (<span class=\'highlight\'>yMin</span>...<span class=\'highlight\'>yMax</span>).\\n</p><p>\\nIncoming values outside the x range will just output the min/max y value.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(119,7,3,'com.unifina.signalpath.utils.Comment','Comment','CommentModule',NULL,'comment',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Just a text box for comments. Commenting what you build is a good idea, as it helps you and others understand what is going on.</p>\"}',NULL,NULL),
	(120,4,1,'com.unifina.signalpath.simplemath.RoundToStep','RoundToStep','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Rounds incoming values to given precision/step. The direction of rounding can be set with the <span class=\'highlight\'>mode</span> parameter.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(125,4,7,'com.unifina.signalpath.trigger.SamplerConditional','SampleIf','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module can be used to sample values from one timeseries upon events from another timeseries, just like the Sampler module.\\n</p><p>\\nHowever the <span class=\'highlight\'>triggerIf</span> value must be equal to 1 for the value at <span class=\'highlight\'>value</span> input to be sent out. Trigger events with other values than 1 will produce no effect.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(129,4,27,'com.unifina.signalpath.text.StringContains','Contains','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Tests whether the input string contains the substring given as the <span class=\'highlight\'>search</span> parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Substring, Find',NULL),
	(131,4,27,'com.unifina.signalpath.text.StringConcatenate','Concatenate','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Concatenates (appends) the given strings. For example if input <span class=\'highlight\'>A</span> is \\\"foo\\\" and input <span class=\'highlight\'>B</span> is \\\"bar\\\", the output is \\\"foobar\\\".</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Join, Append',NULL),
	(136,6,18,'com.unifina.signalpath.custom.SimpleJavaCodeWrapper','JavaModule','CustomModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to implement custom functionality by writing code in the Java programming language directly in your browser.\\n</p><p>\\nClick the <span class=\'highlight\'>Edit code</span> button to open the code editor. The code you write will be dynamically compiled and executed.\\n</p><p>\\nSee the User Guide for more information on programmable modules.</p>\"}',NULL,NULL),
	(138,4,12,'com.unifina.signalpath.statistics.StandardDeviation','StandardDeviation','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input time series\"},\"helpText\":\"<p>Calculates the standard deviation in a sliding window of the input time series.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of observations for producing output\",\"windowLength\":\"Length of the sliding window (number of observations)\"},\"outputs\":{\"out\":\"Standard deviation\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),
	(141,7,3,'com.unifina.signalpath.utils.Merge','Merge','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Merges two event streams into one. Whatever arrives at inputs <span class=\'highlight\'>A</span> or <span class=\'highlight\'>B</span> is sent out from the single output. The inputs and the output can be connected to all types of endpoints. A runtime error may occur if there is a type conflict.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(142,8,3,'com.unifina.signalpath.utils.EventTable','Table','TableModule',NULL,'module event-table-module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Displays a table of events arriving at the inputs along with their timestamps. The number of inputs can be adjusted in module options. Every input corresponds to a table column. Very useful for debugging and inspecting values. The inputs can be connected to all types of outputs.</p>\"}','Events','streamr-table'),
	(145,0,3,'com.unifina.signalpath.utils.Label','Label','LabelModule',NULL,'module dashboard',1,'',NULL,'streamr-label'),
	(147,0,25,'com.unifina.signalpath.utils.ConfigurableStreamModule','Stream','GenericModule',b'1','module',1,'',NULL,NULL),
	(149,5,12,'com.unifina.signalpath.statistics.MinSliding','Min (window)','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the minimum value in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least </span>minSamples</span> values must be received before an output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Minimum, Smallest',NULL),
	(150,4,12,'com.unifina.signalpath.statistics.MaxSliding','Max (window)','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the maximum value in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least </span>minSamples</span> values must be received before an output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Maximum, Largest',NULL),
	(151,4,12,'com.unifina.signalpath.statistics.GeometricMean','GeometricMean','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the geometric mean of incoming values in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least </span>minSamples</span> values must be received before an output is produced.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(152,9,12,'com.unifina.signalpath.statistics.Kurtosis','Kurtosis','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input random variable\"},\"helpText\":\"<p>Calculates the kurtosis (or fourth standardized moment) of a distribution of values in a sliding window. Kurtosis is a measure of the \\\"peakedness\\\" of a distribution.\\n</p><p>\\nNote that at least 4 samples is required to calculate kurtosis.\\n</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Number of samples required to produce output. At least 4 samples are required to calculate kurtosis\",\"windowLength\":\"Length of the sliding window of values\"},\"outputs\":{\"out\":\"Kurtosis\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),
	(153,7,12,'com.unifina.signalpath.statistics.Percentile','Percentile','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"The input values\"},\"helpText\":\"<p>Calculates the value below which a given <span class=\'highlight\'>percentage</span> of values fall in a sliding window of observations.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of observations for producing output\",\"windowLength\":\"Length of the sliding window\",\"percentage\":\"This percentage (0-100) of observations fall under the output of this module\"},\"outputs\":{\"out\":\"The value under which <span class=\'highlight\'>percentage</span> % of input values fall\"},\"paramNames\":[\"windowLength\",\"minSamples\",\"percentage\"]}',NULL,NULL),
	(154,4,12,'com.unifina.signalpath.statistics.PopulationVariance','PopulationVariance','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the non-bias-corrected population variance. See the <span class=\'highlight\'>Variance</span> module or bias-corrected variance.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(155,4,12,'com.unifina.signalpath.statistics.Variance','Variance','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the bias-corrected sample variance (with N-1 in the denominator). Use the <span class=\'highlight\'>PopulationVariance</span> module for the non-bias-corrected population variance.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(156,6,12,'com.unifina.signalpath.statistics.Skewness','Skewness','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input random variable\"},\"helpText\":\"<p>Calculates the skewness (or third standardized moment) of a distribution of values in a sliding window. Skewness is a measure of the asymmetry of a distribution.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Number of samples required to produce output\",\"windowLength\":\"Length of the sliding window of values\"},\"outputs\":{\"out\":\"Skewness\"},\"paramNames\":[\"windowLength\",\"minSamples\"]}',NULL,NULL),
	(157,4,12,'com.unifina.signalpath.statistics.SumOfSquares','SumOfSquares','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Calculates the sum of squared input values in a sliding window of length <span class=\'highlight\'>windowLength</span>. At least <span class=\'highlight\'>minSamples</span> values are collected before producing output.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(158,5,19,'com.unifina.signalpath.utils.FlexBarify','FlexBarify','GenericModule',NULL,'module',1,'{\"outputNames\":[\"open\",\"high\",\"low\",\"close\",\"avg\"],\"inputs\":{\"value\":\"Value to be sampled into the bar\",\"valueLength\":\"Length of each event, contributes to <span class=\'highlight\'>barLength</span>\"},\"helpText\":\"<p>Similar to the <span class=\'highlight\'>Barify</span> module, which creates open-high-low-close bars equally long in <span class=\'highlight\'>time</span>, this module creates bars equally long in an arbitrary variable passed into the <span class=\'highlight\'>valueLength</span> input.\\n</p><p>\\nIncoming <span class=\'highlight\'>valueLength</span> is summed for the current bar until <span class=\'highlight\'>barLength</span> is reached, at which point the outputs are sent and the bar is reset.\\n</p><p>\\nNote that if multiple bars would be filled on the same event, only one is output. To avoid this situation you may want to keep <span class=\'highlight\'>barLength</span> substantially larger than incoming <span class=\'highlight\'>valueLength</span>. </p>\",\"inputNames\":[\"valueLength\",\"value\"],\"params\":{\"barLength\":\"Length of each bar (in <span class=\'highlight\'>valueLength</span> units)\"},\"outputs\":{\"open\":\"Value at start of period\",\"high\":\"Maximum value during period\",\"avg\":\"Average of values received during the period, weighted by <span class=\'highlight\'>valueLength</span>\",\"low\":\"Minimum value during period\",\"close\":\"Value at end of period (the most recent value)\"},\"paramNames\":[\"barLength\"]}',NULL,NULL),
	(159,1,25,'com.unifina.signalpath.twitter.TwitterModule','Twitter','GenericModule',b'1','module',1,'{\"params\":{\"stream\":\"Selected Twitter stream\"},\"paramNames\":[\"stream\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"tweet\":\"Tweet text\",\"username\":\"Screen name of the user\",\"name\":\"Full name of the user\",\"language\":\"Language code\",\"followers\":\"Number of followers\",\"retweet?\":\"1 if this is a retweet, 0 otherwise\",\"reply?\":\"1 if this is a reply, 0 otherwise\"},\"outputNames\":[\"tweet\",\"username\",\"name\",\"language\",\"followers\",\"retweet?\",\"reply?\"],\"helpText\":\"This is a source module for tweets. Twitter streams are tweets that match a group of keywords that define the stream.\"}',NULL,NULL),
	(161,2,1,'com.unifina.signalpath.simplemath.Count','Count','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"Counts the number of incoming events.\"}','number',NULL),
	(162,1,1,'com.unifina.signalpath.simplemath.SquareRoot','SquareRoot','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"Calculates the square root of the input.\"}','sqrt',NULL),
	(181,1,3,'com.unifina.signalpath.utils.Filter','Filter','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"pass\":\"The filter condition. 1 (true) for letting the event pass, 0 (false) to filter it out\",\"in\":\"The incoming event (any type)\"},\"inputNames\":[\"pass\",\"in\"],\"outputs\":{\"out\":\"The event that came in, if passed. If filtered, nothing is sent\"},\"outputNames\":[\"out\"],\"helpText\":\"Only lets the incoming value through if the value at <span class=\'highlight\'>pass</span> is 1. If this condition is not met, no event is sent out.\"}','Select, Pick, Choose',NULL),
	(195,9,3,'com.unifina.signalpath.messaging.EmailModule','Email','GenericModule',NULL,'module',1,'{\"params\":{\"subject\":\"Email Subject\",\"message\":\"Custom message to include in the email, optional\"},\"paramNames\":[\"subject\",\"message\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The Email module can be used to send notifications to your email address. Just like any module, it activates when an event is received at any driving input. The number of inputs can be set in module options, and the values at the inputs will be included in the email content. The inputs can be renamed to give them more descriptive names.</p>\\n\\n<p>When running against historical data, emails are not actually sent. Instead, a notification is shown representing the would-be email. Emails are capped at one per minute to avoid accidental self-spamming.</p>\\n\\n<p>Here\'s an example of email content:</p>\\n\\n<p>\\nMessage:<BR>\\n(your custom message)\\n<BR><BR>\\nEvent Timestamp:<BR>\\n2014-11-18 10:30:00.124\\n<BR><BR>\\nInput Values:<BR>\\nvalue1: 7357<BR>\\nvalue2: test value\\n</p>\"}','Message Notification Notify',NULL),
	(196,0,13,'com.unifina.signalpath.charts.Heatmap','Heatmap','HeatmapModule',NULL,'module',1,NULL,NULL,'streamr-heatmap'),
	(197,0,3,'com.unifina.signalpath.kafka.SendToStream','SendToStream','GenericModule',NULL,'module',1,NULL,'Produce Feedback',NULL),
	(198,2,27,'com.unifina.signalpath.text.StringEndsWith','EndsWith','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Tests whether the input string ends with the substring given as the&nbsp;search&nbsp;parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\\n\"}',NULL,NULL),
	(199,1,27,'com.unifina.signalpath.text.StringEquals','TextEquals','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Tests whether the input string equals with the string&nbsp;given as the&nbsp;search&nbsp;parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\\n\"}',NULL,NULL),
	(200,1,27,'com.unifina.signalpath.text.StringLength','TextLength','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Ouputs the length of the input text (all characters including).</p>\\n\"}','Length',NULL),
	(201,3,27,'com.unifina.signalpath.text.StringRegex','Regex','GenericModule',NULL,'module',1,'{\"params\":{\"pattern\":\"Regex pattern\"},\"paramNames\":[\"pattern\"],\"inputs\":{\"text\":\"Text to be analyzed.\"},\"inputNames\":[\"text\"],\"outputs\":{\"match?\":\"1 if in the text is something that matches with the pattern. Else 0.\",\"matchCount\":\"How many matches there are in the text.\",\"matchList\":\"A list of the matches. An empty list if there aren\'t any.\"},\"outputNames\":[\"match?\",\"matchCount\",\"matchList\"],\"helpText\":\"<p>Module for analyzing text with a&nbsp;Regular Expression (Regex) pattern. <a href=\\\"http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html\\\" target=\\\"_blank\\\">Pattern</a> is given in java format, without the starting and ending slashes.</p>\\n\"}',NULL,NULL),
	(202,1,27,'com.unifina.signalpath.text.StringReplace','Replace','GenericModule',NULL,'module',1,'{\"params\":{\"search\":\"The substring to be replaced\",\"replaceWith\":\"The replacer\"},\"paramNames\":[\"search\",\"replaceWith\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"out\":\"The output, with replaced texts\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Searches the input text by the <strong>search&nbsp;</strong>parameter, and if it is found, replaces it with the <strong>replaceWith&nbsp;</strong>parameter and outputs the result.</p>\\n\"}',NULL,NULL),
	(203,1,27,'com.unifina.signalpath.text.StringSplit','Split','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"text\":\"The text to be splitted\"},\"inputNames\":[\"text\"],\"outputs\":{\"list\":\"Splitted output as list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Splits the text by a given separator and outputs a list with the results</p>\\n\\n<p>Examples:</p>\\n\\n<ul>\\n\\t<li>Separator: &quot;&nbsp;&quot;(empty space),Text: &quot;Two Words&quot;\\n\\t<ul>\\n\\t\\t<li>Output: Two, Words</li>\\n\\t</ul>\\n\\t</li>\\n</ul>\\n\"}',NULL,NULL),
	(204,1,27,'com.unifina.signalpath.text.StringStartsWith','StartsWith','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Tests whether the input string starts with the substring given as the&nbsp;search&nbsp;parameter. If it does, 1 is sent out. Otherwise the output is 0.</p>\\n\"}','Beginswith',NULL),
	(205,2,27,'com.unifina.signalpath.text.StringTrim','Trim','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Removes the whitespace in front of and behind the input text.</p>\\n\\n<p>E.g.&nbsp; &quot; &nbsp; &nbsp; &nbsp; &nbsp; example with a space &nbsp; &nbsp; &nbsp; &quot; -&gt; &quot;example with a space&quot;</p>\\n\"}','whitespace',NULL),
	(206,1,27,'com.unifina.signalpath.text.ToLowerCase','ToLowerCase','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the input text in lower case.</p>\\n\"}','',NULL),
	(207,1,27,'com.unifina.signalpath.text.ToUpperCase','ToUpperCase','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the input text in upper case.</p>\\n\"}','capital',NULL),
	(208,2,27,'com.unifina.signalpath.text.ValueAsText','ValueAsText','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"Any Object\"},\"inputNames\":[\"in\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Transforms the input value (which can be any value) into text.</p>\\n\"}','toString',NULL),
	(209,5,28,'com.unifina.signalpath.time.ClockModule','Clock','GenericModule',NULL,'module',1,'{\"params\":{\"format\":\"Format of the string date\"},\"paramNames\":[\"format\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"date\":\"String notation of the time and date\"},\"outputNames\":[\"date\"],\"helpText\":\"<p>Tells the time and date every second. Outputs it either in string notation in the given format or in timestamp (milliseconds from 1970-01-01 00:00:00.000).</p>\\n\"}',NULL,NULL),
	(210,1,28,'com.unifina.signalpath.time.TimeBetweenEvents','TimeBetweenEvents','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"Any type event\"},\"inputNames\":[\"in\"],\"outputs\":{\"ms\":\"Time in milliseconds\"},\"outputNames\":[\"ms\"],\"helpText\":\"<p>Tells the time between two consecutive events in milliseconds.</p>\\n\"}',NULL,NULL),
	(211,3,28,'com.unifina.signalpath.time.DateConversion','DateConversion','GenericModule',NULL,'module',1,'{\"params\":{\"timezone\":\"Timezone of the outputs\",\"format\":\"Format of the input and output string notations\"},\"paramNames\":[\"timezone\",\"format\"],\"inputs\":{\"date\":\"Timestamp, string or Date\"},\"inputNames\":[\"date\"],\"outputs\":{\"date\":\"String notation\",\"ts\":\"Timestamp(ms)\",\"dayOfWeek\":\"In shortened form, e.g. \\\"Mon\\\"\"},\"outputNames\":[\"date\",\"ts\",\"dayOfWeek\"],\"helpText\":\"<p>Takes a date as an input in either in <a href=\\\"https://docs.oracle.com/javase/8/docs/api/java/util/Date.html\\\" target=\\\"_blank\\\">Date</a> object, timestamp(ms) or in string notation. If the input is in text form, is the given format used.</p>\\n\\n<p>Example:</p>\\n\\n<p>Parameters:</p>\\n\\n<ul>\\n\\t<li>Format &lt;- &quot;yyyy-MM-dd HH:mm:ss&quot;</li>\\n\\t<li>Timezone &lt;- Europe/Helsinki</li>\\n</ul>\\n\\n<p><br />\\nInputs:</p>\\n\\n<ul>\\n\\t<li>Date in &lt;- &quot;2015-07-15&nbsp;13:06:13&quot; or&nbsp;1436954773474</li>\\n</ul>\\n\\n<p>Outputs:&nbsp;</p>\\n\\n<ul>\\n\\t<li>Date out -&gt;&nbsp;2015-07-15&nbsp;13:06:13</li>\\n\\t<li>ts -&gt;&nbsp;1436954773474</li>\\n\\t<li>dayOfWeek -&gt; &quot;Wed&quot;</li>\\n\\t<li>years -&gt; 2015</li>\\n\\t<li>months -&gt; 7</li>\\n\\t<li>days -&gt; 15</li>\\n\\t<li>hours -&gt; 13</li>\\n\\t<li>minutes -&gt; 6</li>\\n\\t<li>seconds -&gt; 13</li>\\n\\t<li>milliseconds -&gt; 0</li>\\n</ul>\\n\"}',NULL,NULL),
	(213,1,1,'com.unifina.signalpath.simplemath.Modulo','Modulo','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Calculates the remainder of two values. Outputs ( divisor mod divider).</p>\\n\\n<p>E.g.</p>\\n\\n<ul>\\n\\t<li>3 mod 2 = 1</li>\\n</ul>\\n\"}',NULL,NULL);

/*!40000 ALTER TABLE `module` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table module_category
# ------------------------------------------------------------

DROP TABLE IF EXISTS `module_category`;

CREATE TABLE `module_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `module_package_id` bigint(20) DEFAULT NULL,
  `hide` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1AD2C17148690B46` (`parent_id`),
  KEY `FK1AD2C17196E04B35` (`module_package_id`),
  CONSTRAINT `FK1AD2C17148690B46` FOREIGN KEY (`parent_id`) REFERENCES `module_category` (`id`),
  CONSTRAINT `FK1AD2C17196E04B35` FOREIGN KEY (`module_package_id`) REFERENCES `module_package` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `module_category` WRITE;
/*!40000 ALTER TABLE `module_category` DISABLE KEYS */;

INSERT INTO `module_category` (`id`, `version`, `name`, `sort_order`, `parent_id`, `module_package_id`, `hide`)
VALUES
	(1,0,'Simple Math',40,15,1,NULL),
	(2,0,'Filtering',30,15,1,NULL),
	(3,0,'Utils',100,NULL,1,NULL),
	(7,0,'Triggers',60,15,1,NULL),
	(10,0,'Boolean',45,15,1,NULL),
	(11,0,'Prediction',20,15,1,NULL),
	(12,0,'Statistics',42,15,1,NULL),
	(13,0,'Charts',80,NULL,1,NULL),
	(15,0,'Time Series',1,NULL,1,NULL),
	(18,0,'Custom Modules',70,NULL,1,NULL),
	(19,0,'Time Series Utils',70,15,1,NULL),
	(25,0,'Data Sources',0,NULL,1,b'1'),
	(27,0,'Text',2,NULL,1,NULL),
	(28,0,'Time & Date',3,NULL,1,NULL);

/*!40000 ALTER TABLE `module_category` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table module_package
# ------------------------------------------------------------

DROP TABLE IF EXISTS `module_package`;

CREATE TABLE `module_package` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK8E99557360701D32` (`user_id`),
  CONSTRAINT `FK8E99557360701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `module_package` WRITE;
/*!40000 ALTER TABLE `module_package` DISABLE KEYS */;

INSERT INTO `module_package` (`id`, `version`, `name`, `user_id`)
VALUES
	(1,0,'core',1),
	(5,0,'deprecated',1);

/*!40000 ALTER TABLE `module_package` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table module_package_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `module_package_user`;

CREATE TABLE `module_package_user` (
  `user_id` bigint(20) NOT NULL,
  `module_package_id` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`,`module_package_id`),
  KEY `FK7EA2BF1760701D32` (`user_id`),
  KEY `FK7EA2BF17FEDA9555` (`module_package_id`),
  CONSTRAINT `FK7EA2BF1760701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`),
  CONSTRAINT `FK7EA2BF17FEDA9555` FOREIGN KEY (`module_package_id`) REFERENCES `module_package` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `module_package_user` WRITE;
/*!40000 ALTER TABLE `module_package_user` DISABLE KEYS */;

INSERT INTO `module_package_user` (`user_id`, `module_package_id`)
VALUES
	(1,1),
	(2,1),
	(3,1);

/*!40000 ALTER TABLE `module_package_user` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table registration_code
# ------------------------------------------------------------

DROP TABLE IF EXISTS `registration_code`;

CREATE TABLE `registration_code` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date_created` datetime NOT NULL,
  `token` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table running_signal_path
# ------------------------------------------------------------

DROP TABLE IF EXISTS `running_signal_path`;

CREATE TABLE `running_signal_path` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `adhoc` bit(1) DEFAULT NULL,
  `date_created` datetime NOT NULL,
  `json` longtext NOT NULL,
  `last_updated` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `request_url` varchar(255) DEFAULT NULL,
  `runner` varchar(255) DEFAULT NULL,
  `server` varchar(255) DEFAULT NULL,
  `shared` bit(1) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  `serialized` longtext,
  `serialization_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKE44264DC60701D32` (`user_id`),
  KEY `runner_idx` (`runner`),
  CONSTRAINT `FKE44264DC60701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table saved_signal_path
# ------------------------------------------------------------

DROP TABLE IF EXISTS `saved_signal_path`;

CREATE TABLE `saved_signal_path` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `date_created` datetime NOT NULL,
  `has_exports` bit(1) NOT NULL,
  `json` longtext NOT NULL,
  `last_updated` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK6A6ED1A460701D32` (`user_id`),
  CONSTRAINT `FK6A6ED1A460701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table sec_role
# ------------------------------------------------------------

DROP TABLE IF EXISTS `sec_role`;

CREATE TABLE `sec_role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `authority` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `authority` (`authority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `sec_role` WRITE;
/*!40000 ALTER TABLE `sec_role` DISABLE KEYS */;

INSERT INTO `sec_role` (`id`, `version`, `authority`)
VALUES
	(1,0,'ROLE_USER'),
	(2,0,'ROLE_LIVE'),
	(3,0,'ROLE_ADMIN');

/*!40000 ALTER TABLE `sec_role` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table sec_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `sec_user`;

CREATE TABLE `sec_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `account_expired` bit(1) NOT NULL,
  `account_locked` bit(1) NOT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `api_secret` varchar(255) DEFAULT NULL,
  `enabled` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `password_expired` bit(1) NOT NULL,
  `timezone` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `api_key_uniq_1452618583160` (`api_key`),
  KEY `apiKey_index` (`api_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `sec_user` WRITE;
/*!40000 ALTER TABLE `sec_user` DISABLE KEYS */;

INSERT INTO `sec_user` (`id`, `version`, `account_expired`, `account_locked`, `api_key`, `api_secret`, `enabled`, `name`, `password`, `password_expired`, `timezone`, `username`)
VALUES
	(1,255,b'0',b'0','tester1-api-key','tester1-api-secret',b'1','Tester One','$2a$10$z0HZdlGT7tvG6TSw4r/3Z.kqxJO4yM/ON4zX1pQ4TR1Kj3aidO/6q',b'0','Europe/Helsinki','tester1@streamr.com'),
	(2,0,b'0',b'0','tester2-api-key','tester2-api-secret',b'1','Tester Two','$2a$04$pRVYUUEUC4gQH0Hs4oTjWOS/ldKDm54pSAmHxI.mht9LURLsYqL6y',b'0','Europe/Helsinki','tester2@streamr.com'),
	(3,0,b'0',b'0','tester-admin-api-key','tester-admin-api-secret',b'1','Tester Admin','$2a$04$kUm3C39XUPpVvxKZCO.1I.mL0qQgLN.FRltFVcDjl1jap5W5AP7Te',b'0','Europe/Helsinki','tester-admin@streamr.com');

/*!40000 ALTER TABLE `sec_user` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table sec_user_sec_role
# ------------------------------------------------------------

DROP TABLE IF EXISTS `sec_user_sec_role`;

CREATE TABLE `sec_user_sec_role` (
  `sec_role_id` bigint(20) NOT NULL,
  `sec_user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sec_role_id`,`sec_user_id`),
  KEY `FK6630E2A872C9F44` (`sec_user_id`),
  KEY `FK6630E2AE201DB64` (`sec_role_id`),
  CONSTRAINT `FK6630E2A872C9F44` FOREIGN KEY (`sec_user_id`) REFERENCES `sec_user` (`id`),
  CONSTRAINT `FK6630E2AE201DB64` FOREIGN KEY (`sec_role_id`) REFERENCES `sec_role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `sec_user_sec_role` WRITE;
/*!40000 ALTER TABLE `sec_user_sec_role` DISABLE KEYS */;

INSERT INTO `sec_user_sec_role` (`sec_role_id`, `sec_user_id`)
VALUES
	(1,1),
	(2,1),
	(1,2),
	(1,3),
	(2,3),
	(3,3);

/*!40000 ALTER TABLE `sec_user_sec_role` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table signup_invite
# ------------------------------------------------------------

DROP TABLE IF EXISTS `signup_invite`;

CREATE TABLE `signup_invite` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `code` varchar(255) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `sent` bit(1) NOT NULL,
  `used` bit(1) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table stream
# ------------------------------------------------------------

DROP TABLE IF EXISTS `stream`;

CREATE TABLE `stream` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `feed_id` bigint(20) NOT NULL,
  `first_historical_day` datetime DEFAULT NULL,
  `last_historical_day` datetime DEFAULT NULL,
  `local_id` varchar(255) DEFAULT '',
  `name` varchar(255) NOT NULL,
  `stream_config` longtext,
  `user_id` bigint(20) DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `class` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKCAD54F8060701D32` (`user_id`),
  KEY `FKCAD54F8072507A49` (`feed_id`),
  KEY `name_idx` (`name`),
  KEY `uuid_idx` (`uuid`),
  KEY `localId_idx` (`local_id`),
  CONSTRAINT `FKCAD54F8060701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`),
  CONSTRAINT `FKCAD54F8072507A49` FOREIGN KEY (`feed_id`) REFERENCES `feed` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table task
# ------------------------------------------------------------

DROP TABLE IF EXISTS `task`;

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
  CONSTRAINT `FK36358560701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table tour_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tour_user`;

CREATE TABLE `tour_user` (
  `user_id` bigint(20) NOT NULL,
  `tour_number` int(11) NOT NULL,
  `completed_at` datetime NOT NULL,
  PRIMARY KEY (`user_id`,`tour_number`),
  KEY `FK2ED7F15260701D32` (`user_id`),
  CONSTRAINT `FK2ED7F15260701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table ui_channel
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ui_channel`;

CREATE TABLE `ui_channel` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `hash` varchar(255) DEFAULT NULL,
  `module_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `running_signal_path_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK2E3D5E58B6140F06` (`module_id`),
  KEY `FK2E3D5E58E9AA551E` (`running_signal_path_id`),
  CONSTRAINT `FK2E3D5E58B6140F06` FOREIGN KEY (`module_id`) REFERENCES `module` (`id`),
  CONSTRAINT `FK2E3D5E58E9AA551E` FOREIGN KEY (`running_signal_path_id`) REFERENCES `running_signal_path` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
