USE core_test;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# Dump of table canvas
# ------------------------------------------------------------

DROP TABLE IF EXISTS `canvas`;

CREATE TABLE `canvas` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `adhoc` bit(1) NOT NULL,
  `date_created` datetime NOT NULL,
  `example` bit(1) NOT NULL,
  `has_exports` bit(1) NOT NULL,
  `json` longtext NOT NULL,
  `last_updated` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `request_url` varchar(255) DEFAULT NULL,
  `runner` varchar(255) DEFAULT NULL,
  `server` varchar(255) DEFAULT NULL,
  `state` varchar(255) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `serialization_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serialization_id` (`serialization_id`),
  UNIQUE KEY `serialization_id_uniq_1484920841951` (`serialization_id`),
  KEY `FKAE7A755860701D32` (`user_id`),
  KEY `runner_idx` (`runner`),
  KEY `FKAE7A755835F2A96E` (`serialization_id`),
  CONSTRAINT `FKAE7A755835F2A96E` FOREIGN KEY (`serialization_id`) REFERENCES `serialization` (`id`),
  CONSTRAINT `FKAE7A755860701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `canvas` WRITE;
/*!40000 ALTER TABLE `canvas` DISABLE KEYS */;

INSERT INTO `canvas` (`id`, `version`, `adhoc`, `date_created`, `example`, `has_exports`, `json`, `last_updated`, `name`, `request_url`, `runner`, `server`, `state`, `user_id`, `serialization_id`)
VALUES
	('CRhQEMbcRju0vzhUZI0wiw',0,b'0','2016-01-15 10:07:48',b'0',b'0','{\"name\":\"InputModuleLiveSpec\",\"settings\":{},\"uiChannel\":{\"id\":\"r7V-AZhCQCCETcnAo5NzZQ\",\"name\":\"Notifications\"},\"modules\":[{\"hash\":0,\"uiChannel\":{\"id\":\"_O3CZGOUSheD98bVeu_D0w\",\"name\":\"Button\"},\"params\":[{\"id\":\"myId_0_1452852408111\",\"canConnect\":true,\"name\":\"buttonName\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Button.buttonName\",\"value\":\"button\",\"type\":\"String\",\"defaultValue\":\"button\",\"acceptedTypes\":[\"String\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true,\"sourceId\":\"myId_2_1452852415490\"},{\"id\":\"myId_0_1452852408136\",\"canConnect\":true,\"name\":\"buttonValue\",\"connected\":false,\"drivingInput\":false,\"longName\":\"Button.buttonValue\",\"value\":\"0\",\"type\":\"Double\",\"defaultValue\":0,\"acceptedTypes\":[\"Double\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true}],\"type\":\"module\",\"id\":218,\"clearState\":false,\"inputs\":[],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"93px\",\"top\":\"12px\"}},\"name\":\"Button\",\"outputs\":[{\"id\":\"myId_0_1452852408150\",\"canConnect\":true,\"canBeNoRepeat\":false,\"name\":\"out\",\"connected\":true,\"longName\":\"Button.out\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_5_1452852434743\"]}],\"widget\":\"StreamrButton\",\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"InputModule\"},{\"hash\":1,\"uiChannel\":{\"id\":\"TmVFVyvgTz-etT-i1rQclQ\",\"name\":\"Switcher\"},\"params\":[],\"type\":\"module\",\"id\":219,\"clearState\":false,\"inputs\":[],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"99px\",\"top\":\"438px\"}},\"name\":\"Switcher\",\"outputs\":[{\"id\":\"myId_1_1452852409644\",\"canConnect\":true,\"canBeNoRepeat\":false,\"name\":\"out\",\"connected\":true,\"longName\":\"Switcher.out\",\"noRepeat\":true,\"type\":\"Double\",\"targets\":[\"myId_3_1452852431742\"]}],\"widget\":\"StreamrSwitcher\",\"switcherValue\":false,\"jsModule\":\"InputModule\",\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}},{\"hash\":2,\"textFieldValue\":\"\",\"uiChannel\":{\"id\":\"zgFu1U5vSvGC7daxWYdxIA\",\"name\":\"TextField\"},\"params\":[],\"type\":\"module\",\"id\":220,\"textFieldHeight\":76,\"clearState\":false,\"inputs\":[],\"textFieldWidth\":174,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"89px\",\"top\":\"203px\"}},\"name\":\"TextField\",\"outputs\":[{\"id\":\"myId_2_1452852415490\",\"canConnect\":true,\"name\":\"out\",\"connected\":true,\"longName\":\"TextField.out\",\"type\":\"String\",\"targets\":[\"myId_0_1452852408111\",\"myId_4_1452852433505\"]}],\"widget\":\"StreamrTextField\",\"jsModule\":\"InputModule\",\"options\":{\"uiResendLast\":{\"value\":1,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}},{\"hash\":3,\"tableConfig\":{\"headers\":[\"timestamp\",\"input1\"]},\"uiChannel\":{\"id\":\"vpLT1uAIRRePJGqCB8HknQ\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":142,\"clearState\":false,\"inputs\":[{\"id\":\"myId_3_1452852431742\",\"canConnect\":true,\"name\":\"input1\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Table.input1\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_1_1452852409644\"}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"551px\",\"top\":\"447px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"inputs\":{\"value\":1,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"},{\"hash\":4,\"tableConfig\":{\"headers\":[\"timestamp\",\"input1\"]},\"uiChannel\":{\"id\":\"Z7LELGrhQZaktQ5POnwHpw\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":142,\"clearState\":false,\"inputs\":[{\"id\":\"myId_4_1452852433505\",\"canConnect\":true,\"name\":\"input1\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Table.input1\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_2_1452852415490\"}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"557px\",\"top\":\"205px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"inputs\":{\"value\":1,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"},{\"hash\":5,\"tableConfig\":{\"headers\":[\"timestamp\",\"input1\"]},\"uiChannel\":{\"id\":\"H_beqzaHSvKPV7ShQy406w\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":142,\"clearState\":false,\"inputs\":[{\"id\":\"myId_5_1452852434743\",\"canConnect\":true,\"name\":\"input1\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Table.input1\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1452852408150\"}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"561px\",\"top\":\"31px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"inputs\":{\"value\":1,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"}]}','2016-01-15 10:09:29','InputModuleLiveSpec','http://192.168.10.150:8081/unifina-core/api/live/request','s-1452852468387','192.168.10.150','stopped',1,NULL),
	('eyescpGFRiKzr9WxU2k0Yw',165,b'0','2016-08-29 13:50:12',b'0',b'1','{\"name\":\"SubCanvasSpec-top\",\"modules\":[{\"hash\":1,\"textFieldValue\":\"\",\"uiChannel\":{\"id\":\"aBH9ZPAxTE2XvgJ7bKgQXg\",\"webcomponent\":\"streamr-text-field\",\"name\":\"TextField\"},\"params\":[],\"type\":\"module\",\"id\":220,\"textFieldHeight\":76,\"inputs\":[],\"textFieldWidth\":174,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"103px\",\"top\":\"118px\"}},\"name\":\"TextField\",\"outputs\":[{\"id\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"out\",\"connected\":true,\"longName\":\"TextField.out\",\"noRepeat\":true,\"type\":\"String\",\"targets\":[\"tfG-zZItTDmS4G7CdTzp7A\",\"32yzaprIS7S64pfbQOQFCg\",\"69oKfPEuQwayNbAuXv8TSw\",\"c24ESIiATW67SYdlSovPTw\",\"XwspREeeTAWeGL7HBKtzKQ\",\"dY7EH1ydQGaLoTemJnJrog\",\"fXZ1hpyRRFqy5MGLv8helg\",\"OF_aBTeNS76gR9hd_8sHGQ\",\"K5moEsdqSzyhMaeYnb5xNQ\"]}],\"widget\":\"StreamrTextField\",\"options\":{\"uiResendLast\":{\"value\":1,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"InputModule\"},{\"id\":223,\"canRefresh\":true,\"inputs\":[{\"canConnect\":true,\"connected\":true,\"canHaveInitialValue\":true,\"type\":\"String\",\"requiresConnection\":true,\"canToggleDrivingInput\":true,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"feedback\":false,\"id\":\"32yzaprIS7S64pfbQOQFCg\",\"canBeFeedback\":true,\"drivingInput\":true,\"initialValue\":null,\"name\":\"key\",\"longName\":\"ForEach.key\",\"value\":\"\\u00E4l\\u00E4l\\u00E4l\\u00E4l\\u00E4\",\"acceptedTypes\":[\"String\"]},{\"canConnect\":true,\"export\":true,\"connected\":true,\"type\":\"Object\",\"requiresConnection\":true,\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"id\":\"69oKfPEuQwayNbAuXv8TSw\",\"name\":\"label\",\"drivingInput\":true,\"value\":\"\\u00E4l\\u00E4l\\u00E4l\\u00E4l\\u00E4\",\"longName\":\"ForEach.label\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"export\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"id\":\"OF_aBTeNS76gR9hd_8sHGQ\",\"variadic\":{\"isLast\":false,\"index\":1},\"name\":\"endpoint-1472821604763\",\"drivingInput\":true,\"longName\":\"ForEach.endpoint-1472821604763\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]}],\"hash\":4,\"canClearState\":true,\"name\":\"ForEach\",\"layout\":{\"position\":{\"left\":\"612px\",\"top\":\"82px\"}},\"params\":[{\"canConnect\":true,\"updateOnChange\":true,\"possibleValues\":[{\"value\":\"eyescpGFRiKzr9WxU2k0Yw\",\"name\":\"SubCanvasSpec-top\"},{\"value\":\"VWo3BDECTASlAdtZk7QeeQ\",\"name\":\"SubCanvasSpec-sub\"}],\"connected\":false,\"type\":\"Canvas\",\"requiresConnection\":false,\"canToggleDrivingInput\":true,\"id\":\"_iIuDBrCSoqhuX_2Vf8_og\",\"drivingInput\":false,\"name\":\"canvas\",\"value\":\"VWo3BDECTASlAdtZk7QeeQ\",\"longName\":\"ForEach.canvas\",\"defaultValue\":\"VWo3BDECTASlAdtZk7QeeQ\",\"acceptedTypes\":[\"Canvas\"]}],\"canvasesByKey\":{},\"outputs\":[{\"canBeNoRepeat\":true,\"canConnect\":true,\"id\":\"mJs0o416T7ukb4jpyTs_Aw\",\"connected\":false,\"name\":\"key\",\"longName\":\"ForEach.key\",\"noRepeat\":true,\"type\":\"String\"},{\"canConnect\":true,\"id\":\"-iIT8BZ_T6ONKXmlRVIwxQ\",\"connected\":false,\"name\":\"map\",\"longName\":\"ForEach.map\",\"type\":\"Map\"}],\"type\":\"module\",\"jsModule\":\"ForEachModule\"},{\"hash\":5,\"tableConfig\":{\"headers\":[\"timestamp\",\"out\"]},\"uiChannel\":{\"id\":\"cny8lZ28TvKtZ-SLPs32VQ\",\"webcomponent\":\"streamr-table\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":527,\"inputs\":[{\"canConnect\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"id\":\"XwspREeeTAWeGL7HBKtzKQ\",\"variadic\":{\"isLast\":false,\"index\":1},\"name\":\"endpoint-1472545463031\",\"drivingInput\":true,\"longName\":\"Table.endpoint-1472545463031\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_5_1472545465692\",\"drivingInput\":true,\"name\":\"endpoint1472545465692\",\"variadic\":{\"isLast\":true,\"index\":2},\"longName\":\"Table.endpoint1472545465692\",\"displayName\":\"in2\",\"acceptedTypes\":[\"Object\"]}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"89px\",\"top\":\"344px\"}},\"name\":\"Table\",\"outputs\":[],\"jsModule\":\"TableModule\",\"options\":{\"uiResendLast\":{\"value\":20,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}},{\"hash\":7,\"uiChannel\":{\"id\":\"odob-JGMSz65Po9hWFaPfQ\",\"webcomponent\":null,\"name\":\"Notifications\"},\"params\":[{\"canConnect\":true,\"updateOnChange\":true,\"possibleValues\":[{\"value\":\"eyescpGFRiKzr9WxU2k0Yw\",\"name\":\"SubCanvasSpec-top\"},{\"value\":\"VWo3BDECTASlAdtZk7QeeQ\",\"name\":\"SubCanvasSpec-sub\"}],\"connected\":false,\"type\":\"Canvas\",\"requiresConnection\":false,\"canToggleDrivingInput\":true,\"id\":\"ep_UVwTVZN7STOJwIsLSsbhQQ\",\"drivingInput\":false,\"name\":\"canvas\",\"value\":\"VWo3BDECTASlAdtZk7QeeQ\",\"longName\":\"SubCanvasSpec-sub.canvas\",\"defaultValue\":\"VWo3BDECTASlAdtZk7QeeQ\",\"acceptedTypes\":[\"Canvas\"]}],\"type\":\"module\",\"id\":81,\"canRefresh\":true,\"inputs\":[{\"canConnect\":true,\"id\":\"fXZ1hpyRRFqy5MGLv8helg\",\"export\":true,\"drivingInput\":true,\"connected\":true,\"name\":\"label\",\"longName\":\"Label.label\",\"type\":\"Object\",\"requiresConnection\":true,\"acceptedTypes\":[\"Object\"],\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\"},{\"canConnect\":true,\"export\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"id\":\"K5moEsdqSzyhMaeYnb5xNQ\",\"variadic\":{\"isLast\":false,\"index\":1},\"name\":\"endpoint-1472821604763\",\"drivingInput\":true,\"longName\":\"Table.endpoint-1472821604763\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"618px\",\"top\":\"301px\"}},\"name\":\"SubCanvasSpec-sub\",\"modules\":[{\"id\":145,\"inputs\":[{\"canConnect\":true,\"id\":\"fXZ1hpyRRFqy5MGLv8helg\",\"export\":true,\"drivingInput\":true,\"connected\":true,\"name\":\"label\",\"longName\":\"Label.label\",\"type\":\"Object\",\"requiresConnection\":true,\"acceptedTypes\":[\"Object\"],\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\"}],\"hash\":5,\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"189px\",\"top\":\"94px\"}},\"name\":\"Label\",\"params\":[],\"uiChannel\":{\"id\":\"sLCW96ZzQQCCILQHwu35og\",\"webcomponent\":\"streamr-label\",\"name\":\"Label (TextField.out)\"},\"type\":\"module dashboard\",\"outputs\":[],\"jsModule\":\"LabelModule\"},{\"hash\":7,\"tableConfig\":{\"headers\":[\"timestamp\",\"out\"]},\"uiChannel\":{\"id\":\"_w0q24z1S-ebnfWbEmdQog\",\"webcomponent\":\"streamr-table\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":527,\"inputs\":[{\"canConnect\":true,\"export\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"3GAu-zgYTGOVpspmgIZBwQ\",\"id\":\"K5moEsdqSzyhMaeYnb5xNQ\",\"variadic\":{\"isLast\":false,\"index\":1},\"name\":\"endpoint-1472821604763\",\"drivingInput\":true,\"longName\":\"Table.endpoint-1472821604763\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"export\":false,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_7_1472821608592\",\"variadic\":{\"isLast\":true,\"index\":2},\"name\":\"endpoint1472821608591\",\"drivingInput\":true,\"longName\":\"Table.endpoint1472821608591\",\"displayName\":\"in2\",\"acceptedTypes\":[\"Object\"]}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"242px\",\"top\":\"255px\"}},\"name\":\"Table\",\"outputs\":[],\"jsModule\":\"TableModule\",\"options\":{\"uiResendLast\":{\"value\":20,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}}],\"outputs\":[],\"jsModule\":\"CanvasModule\",\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"uiResendAll\":{\"value\":true,\"type\":\"boolean\"}}}],\"settings\":{\"editorState\":{\"runTab\":\"#tab-realtime\"},\"speed\":\"0\",\"timeOfDayFilter\":{\"timeOfDayStart\":\"00:00:00\",\"timeOfDayEnd\":\"23:59:00\"},\"endDate\":\"2016-08-29\",\"beginDate\":\"2016-08-29\"},\"hasExports\":true,\"uiChannel\":{\"id\":\"V_GXmKCXTtOxMICLYhq4bg\",\"webcomponent\":null,\"name\":\"Notifications\"}}','2016-09-02 13:08:18','SubCanvasSpec-top','http://192.168.10.137:8081/unifina-core/api/v1/canvases/eyescpGFRiKzr9WxU2k0Yw','s-1472821655728','192.168.10.137','stopped',1,NULL),
	('heMwO-9QQayWxYZtja-ZCA',0,b'0','2015-11-15 18:09:59',b'0',b'0','{\"name\":\"LiveSpec\",\"settings\":{},\"uiChannel\":{\"id\":\"umJWtbPBQgS7Bo4ay1VQcQ\",\"name\":\"Notifications\"},\"modules\":[{\"id\":147,\"clearState\":false,\"inputs\":[],\"hash\":0,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"127px\",\"top\":\"116px\"}},\"name\":\"Stream\",\"params\":[{\"canConnect\":true,\"connected\":false,\"type\":\"Stream\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"streamName\":\"CanvasSpec\",\"id\":\"myId_0_1436337701326\",\"name\":\"stream\",\"drivingInput\":false,\"value\":\"c1_fiG6PTxmtnCYGU-mKuQ\",\"longName\":\"Stream.stream\",\"feed\":7,\"defaultValue\":{},\"acceptedTypes\":[\"Stream\",\"String\"],\"checkModuleId\":true}],\"type\":\"module\",\"outputs\":[{\"id\":\"myId_0_1436337701356\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"temperature\",\"connected\":true,\"longName\":\"Stream.temperature\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_1_1436337705676\",\"myId_2_1447610973136\",\"myId_3_1447610977595\"]},{\"id\":\"myId_0_1436337701366\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"rpm\",\"connected\":false,\"longName\":\"Stream.rpm\",\"noRepeat\":false,\"type\":\"Double\"},{\"id\":\"myId_0_1447610966097\",\"canConnect\":true,\"name\":\"text\",\"connected\":false,\"longName\":\"Stream.text\",\"type\":\"String\"}],\"jsModule\":\"GenericModule\"},{\"hash\":1,\"uiChannel\":{\"id\":\"jYRYTDoxSWu3vvDp_P9_xg\",\"webcomponent\":\"streamr-chart\",\"name\":\"Chart\"},\"params\":[],\"barify\":true,\"type\":\"chart dashboard\",\"id\":67,\"clearState\":false,\"inputs\":[{\"canConnect\":true,\"connected\":true,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1436337701356\",\"id\":\"myId_1_1436337705676\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in1\",\"longName\":\"Chart.in1\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705684\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in2\",\"longName\":\"Chart.in2\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705689\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in3\",\"longName\":\"Chart.in3\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705693\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in4\",\"longName\":\"Chart.in4\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705697\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in5\",\"longName\":\"Chart.in5\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705701\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in6\",\"longName\":\"Chart.in6\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705705\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in7\",\"longName\":\"Chart.in7\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705710\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in8\",\"longName\":\"Chart.in8\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705716\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in9\",\"longName\":\"Chart.in9\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1436337705722\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in10\",\"longName\":\"Chart.in10\",\"acceptedTypes\":[\"Double\"]}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"636px\",\"top\":\"79px\"},\"height\":\"500px\",\"width\":\"800px\",\"workspaces\":{\"normal\":{\"position\":{\"left\":\"636px\",\"top\":\"79px\"}}}},\"name\":\"Chart\",\"outputs\":[],\"options\":{\"ignoreBefore\":{\"value\":\"00:00:00\",\"type\":\"string\"},\"ignoreEnabled\":{\"value\":false,\"type\":\"boolean\"},\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"inputs\":{\"value\":10,\"type\":\"int\"},\"overnightBreak\":{\"value\":true,\"type\":\"boolean\"},\"ignoreAfter\":{\"value\":\"23:59:59\",\"type\":\"string\"},\"uiResendAll\":{\"value\":true,\"type\":\"boolean\"}},\"jsModule\":\"ChartModule\"},{\"id\":145,\"clearState\":false,\"inputs\":[{\"id\":\"myId_2_1447610973136\",\"canConnect\":true,\"name\":\"label\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Label.label\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":true,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1436337701356\"}],\"hash\":2,\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"322px\",\"top\":\"335px\"},\"workspaces\":{\"normal\":{\"position\":{\"left\":\"322px\",\"top\":\"335px\"}}}},\"name\":\"Label\",\"params\":[],\"uiChannel\":{\"id\":\"H9yVHbqIRbmIKtP3QTWjfA\",\"name\":\"Label\"},\"type\":\"module dashboard\",\"outputs\":[],\"jsModule\":\"LabelModule\"},{\"hash\":3,\"tableConfig\":{\"headers\":[\"timestamp\",\"input1\"]},\"uiChannel\":{\"id\":\"8X5-hJBySnOLL3U7KJPMrA\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":142,\"clearState\":false,\"inputs\":[{\"id\":\"myId_3_1447610977595\",\"canConnect\":true,\"name\":\"input1\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Table.input1\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1436337701356\"}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"300px\",\"top\":\"482px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":20,\"type\":\"int\"},\"inputs\":{\"value\":1,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"}]}','2016-02-02 12:32:50','DashboardSpec','http://192.168.10.21:8089/unifina-core/api/live/request','s-1454416162327','192.168.10.21','stopped',1,NULL),
	('Hu_MgbdESnq8XGsre3HLXw',0,b'0','2015-07-03 17:28:13',b'0',b'0','{\"name\":\"test-run-canvas\",\"modules\":[{\"id\":147,\"clearState\":false,\"inputs\":[],\"hash\":0,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"50px\",\"top\":\"31px\"}},\"name\":\"Stream\",\"params\":[{\"canConnect\":true,\"updateOnChange\":true,\"connected\":false,\"type\":\"Stream\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"streamName\":\"CanvasSpec\",\"id\":\"myId_0_1435944468832\",\"name\":\"stream\",\"drivingInput\":false,\"value\":\"c1_fiG6PTxmtnCYGU-mKuQ\",\"longName\":\"Stream.stream\",\"feed\":7,\"defaultValue\":null,\"acceptedTypes\":[\"Stream\",\"String\"],\"checkModuleId\":true}],\"type\":\"module\",\"outputs\":[{\"id\":\"myId_0_1435944468859\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"temperature\",\"connected\":true,\"longName\":\"Stream.temperature\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_2_1466066422878\"]},{\"id\":\"myId_0_1435944468868\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"rpm\",\"connected\":true,\"longName\":\"Stream.rpm\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_2_1466066428828\"]},{\"id\":\"myId_0_1449509264655\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"text\",\"connected\":true,\"longName\":\"Stream.text\",\"noRepeat\":false,\"type\":\"String\",\"targets\":[\"myId_2_1466066432635\"]}],\"jsModule\":\"StreamModule\"},{\"hash\":2,\"tableConfig\":{\"headers\":[\"timestamp\",\"temperature\",\"rpm\",\"text\"]},\"uiChannel\":{\"id\":\"HsEb38_mRKaAC7s2ElMJfQ\",\"webcomponent\":\"streamr-table\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":527,\"inputs\":[{\"canConnect\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1435944468859\",\"id\":\"myId_2_1466066422878\",\"variadic\":{\"isLast\":false,\"index\":1},\"drivingInput\":true,\"name\":\"endpoint-1466066422870\",\"longName\":\"Table.endpoint-1466066422870\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1435944468868\",\"id\":\"myId_2_1466066428828\",\"name\":\"endpoint1466066428827\",\"drivingInput\":true,\"variadic\":{\"isLast\":false,\"index\":2},\"longName\":\"Table.endpoint1466066428827\",\"displayName\":\"in2\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1449509264655\",\"id\":\"myId_2_1466066432635\",\"name\":\"endpoint1466066432634\",\"drivingInput\":true,\"variadic\":{\"isLast\":false,\"index\":3},\"longName\":\"Table.endpoint1466066432634\",\"displayName\":\"in3\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_2_1466066436245\",\"name\":\"endpoint1466066436243\",\"drivingInput\":true,\"variadic\":{\"isLast\":true,\"index\":4},\"longName\":\"Table.endpoint1466066436243\",\"displayName\":\"in4\",\"acceptedTypes\":[\"Object\"]}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"323px\",\"top\":\"53px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":20,\"type\":\"int\"},\"maxRows\":{\"value\":0,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"}],\"settings\":{\"editorState\":{\"runTab\":\"#tab-historical\"},\"speed\":\"10\",\"timeOfDayFilter\":{\"timeOfDayStart\":\"18:30:00\",\"timeOfDayEnd\":\"23:59:00\"},\"endDate\":\"2015-02-23\",\"beginDate\":\"2015-02-23\"},\"hasExports\":false,\"uiChannel\":{\"id\":\"0bAZFYMITtafcXFLCx5ILQ\",\"webcomponent\":null,\"name\":\"Notifications\"}}','2015-12-07 17:31:18','test-run-canvas',NULL,NULL,NULL,'stopped',1,NULL),
	('iaUL6FCrRzmq1xy50G9idg',0,b'0','2015-07-03 17:21:22',b'1',b'0','{\"name\":\"CanvasSpec test loading a SignalPath\",\"settings\":{\"speed\":\"0\",\"timeOfDayFilter\":{\"timeZoneOffset\":120,\"timeOfDayStart\":\"00:00:00\",\"timeZoneDst\":true,\"timeOfDayEnd\":\"23:59:00\",\"timeZone\":\"Europe/Minsk\"},\"endDate\":\"2015-07-03\",\"beginDate\":\"2015-07-02\"},\"uiChannel\":{},\"modules\":[{\"id\":100,\"clearState\":false,\"inputs\":[{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":true,\"type\":\"Double\",\"requiresConnection\":true,\"canToggleDrivingInput\":true,\"id\":\"myId_2_1435944051520\",\"feedback\":false,\"canBeFeedback\":true,\"drivingInput\":true,\"name\":\"in1\",\"longName\":\"Add.in1\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":true,\"type\":\"Double\",\"requiresConnection\":true,\"canToggleDrivingInput\":true,\"id\":\"myId_2_1435944051526\",\"feedback\":false,\"canBeFeedback\":true,\"drivingInput\":true,\"name\":\"in2\",\"longName\":\"Add.in2\",\"acceptedTypes\":[\"Double\"]}],\"hash\":2,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"10px\",\"top\":\"10px\"}},\"name\":\"Add\",\"params\":[],\"type\":\"module\",\"outputs\":[{\"id\":\"myId_2_1435944051530\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"sum\",\"connected\":false,\"longName\":\"Add.sum\",\"noRepeat\":true,\"type\":\"Double\"}],\"jsModule\":\"GenericModule\",\"options\":{\"inputs\":{\"value\":2,\"type\":\"int\"}}}]}','2015-07-03 17:29:24','ExampleSpec',NULL,NULL,NULL,'stopped',1,NULL),
	('ifyBd634Swiku1_einJ51g',0,b'0','2015-07-27 11:42:34',b'0',b'0','{\"name\":\"LiveSpec stopped\",\"settings\":{},\"uiChannel\":{\"id\":\"ybFY7KeiR1GxuA5Om3Wu4A\",\"name\":\"Notifications\"},\"modules\":[{\"id\":147,\"clearState\":false,\"inputs\":[],\"hash\":0,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"10px\",\"top\":\"10px\"}},\"name\":\"Stream\",\"params\":[{\"canConnect\":true,\"connected\":false,\"type\":\"Stream\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"streamName\":\"LiveSpec\",\"id\":\"myId_0_1437997327157\",\"name\":\"stream\",\"drivingInput\":false,\"value\":\"RUj6iJggS3iEKsUx5C07Ig\",\"longName\":\"Stream.stream\",\"feed\":7,\"defaultValue\":{},\"acceptedTypes\":[\"Stream\",\"String\"],\"checkModuleId\":true}],\"type\":\"module\",\"outputs\":[{\"id\":\"myId_0_1437997327170\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"rand\",\"connected\":true,\"longName\":\"Stream.rand\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_1_1437997329507\"]}],\"jsModule\":\"GenericModule\"},{\"id\":145,\"clearState\":false,\"inputs\":[{\"id\":\"myId_1_1437997329507\",\"canConnect\":true,\"name\":\"label\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Label.label\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":true,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1437997327170\"}],\"hash\":1,\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"245px\",\"top\":\"83px\"},\"workspaces\":{\"normal\":{\"position\":{\"left\":\"245px\",\"top\":\"83px\"}}}},\"name\":\"Label\",\"params\":[],\"uiChannel\":{\"id\":\"v64Rao_RSwydlPYqWKDl_A\",\"name\":\"Label\"},\"type\":\"module dashboard\",\"outputs\":[],\"jsModule\":\"LabelModule\"}]}','2015-07-28 08:18:14','LiveSpec stopped','http://192.168.10.137:8081/unifina-core/api/live/request','s-1438071491772','192.168.10.137','stopped',1,NULL),
	('Ix6zQ61lRyC-sxek4BjuNw',0,b'0','2015-07-03 17:21:22',b'0',b'0','{\"name\":\"CanvasSpec test loading a SignalPath\",\"modules\":[{\"id\":520,\"clearState\":false,\"inputs\":[{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":true,\"type\":\"Double\",\"requiresConnection\":true,\"canToggleDrivingInput\":true,\"id\":\"myId_3_1465818123072\",\"feedback\":false,\"canBeFeedback\":true,\"drivingInput\":true,\"name\":\"in1\",\"longName\":\"Add.in1\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":true,\"type\":\"Double\",\"requiresConnection\":true,\"canToggleDrivingInput\":true,\"id\":\"myId_3_1465818123081\",\"feedback\":false,\"canBeFeedback\":true,\"drivingInput\":true,\"name\":\"in2\",\"longName\":\"Add.in2\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"jsClass\":\"VariadicInput\",\"canHaveInitialValue\":true,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":true,\"id\":\"myId_3_1465818123087\",\"feedback\":false,\"canBeFeedback\":true,\"variadic\":{\"isLast\":true,\"index\":3},\"name\":\"endpoint-1465818123055\",\"drivingInput\":true,\"longName\":\"Add.endpoint-1465818123055\",\"displayName\":\"in3\",\"acceptedTypes\":[\"Double\"]}],\"hash\":3,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"48px\",\"top\":\"22px\"}},\"name\":\"Add\",\"params\":[],\"type\":\"module\",\"outputs\":[{\"id\":\"myId_3_1465818123092\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"sum\",\"connected\":false,\"longName\":\"Add.sum\",\"noRepeat\":true,\"type\":\"Double\"}],\"jsModule\":\"GenericModule\"}],\"settings\":{\"editorState\":{\"runTab\":\"#tab-historical\"},\"speed\":\"0\",\"timeOfDayFilter\":{\"timeOfDayStart\":\"00:00:00\",\"timeOfDayEnd\":\"23:59:00\"},\"endDate\":\"2015-07-03\",\"beginDate\":\"2015-07-02\"},\"hasExports\":false,\"uiChannel\":{\"id\":\"MEvHi5WKRUuBc3K6BZWXxA\",\"webcomponent\":null,\"name\":\"Notifications\"}}','2015-07-03 17:29:24','CanvasSpec test loading a SignalPath',NULL,NULL,NULL,'stopped',1,NULL),
	('jklads9812jlsdf09dfgjoaq',3,b'0','2015-11-15 18:09:59',b'0',b'0','{\"name\":\"BrokenSerialization\",\"settings\":{},\"modules\":[]}','2016-02-01 15:29:45','BrokenSerialization','http://192.168.11.42:8081/unifina-core/api/live/request','s-1454340584152','192.168.11.42','stopped',1,1),
	('k2aXga7bSD-6BTPs0cnDWg',0,b'0','2016-01-15 15:35:03',b'0',b'0','{\"name\":\"InputModuleDashboardSpec\",\"settings\":{},\"uiChannel\":{\"id\":\"qg8EFnnvS1WLwlRDaVxq_g\",\"name\":\"Notifications\"},\"modules\":[{\"hash\":0,\"uiChannel\":{\"id\":\"QKpOdY69TFmf_OIPfObXbg\",\"name\":\"Switcher\"},\"params\":[],\"type\":\"module\",\"id\":219,\"clearState\":false,\"inputs\":[],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"112px\",\"top\":\"28px\"}},\"name\":\"Switcher\",\"outputs\":[{\"id\":\"myId_0_1452872011627\",\"canConnect\":true,\"canBeNoRepeat\":false,\"name\":\"out\",\"connected\":true,\"longName\":\"Switcher.out\",\"noRepeat\":true,\"type\":\"Double\",\"targets\":[\"myId_3_1452872065677\"]}],\"widget\":\"StreamrSwitcher\",\"switcherValue\":false,\"jsModule\":\"InputModule\",\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}},{\"hash\":1,\"uiChannel\":{\"id\":\"ek5KpWJwQrmTrA_sPcWpAw\",\"name\":\"Button\"},\"params\":[{\"id\":\"myId_1_1452872027454\",\"canConnect\":true,\"name\":\"buttonName\",\"connected\":false,\"drivingInput\":true,\"longName\":\"Button.buttonName\",\"value\":\"buttonTest\",\"type\":\"String\",\"defaultValue\":\"button\",\"acceptedTypes\":[\"String\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true},{\"id\":\"myId_1_1452872027468\",\"canConnect\":true,\"name\":\"buttonValue\",\"connected\":false,\"drivingInput\":false,\"longName\":\"Button.buttonValue\",\"value\":\"10\",\"type\":\"Double\",\"defaultValue\":0,\"acceptedTypes\":[\"Double\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true}],\"type\":\"module\",\"id\":218,\"clearState\":false,\"inputs\":[],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"120px\",\"top\":\"208px\"}},\"name\":\"Button\",\"outputs\":[{\"id\":\"myId_1_1452872027491\",\"canConnect\":true,\"canBeNoRepeat\":false,\"name\":\"out\",\"connected\":true,\"longName\":\"Button.out\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_3_1452872072894\"]}],\"widget\":\"StreamrButton\",\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"InputModule\"},{\"hash\":2,\"textFieldValue\":\"textFieldTest\",\"uiChannel\":{\"id\":\"P5sIK762TQumoF1RRbgXkA\",\"name\":\"TextField\"},\"params\":[],\"type\":\"module\",\"id\":220,\"textFieldHeight\":76,\"clearState\":false,\"inputs\":[],\"textFieldWidth\":174,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"113px\",\"top\":\"401px\"}},\"name\":\"TextField\",\"outputs\":[{\"id\":\"myId_2_1452872029739\",\"canConnect\":true,\"name\":\"out\",\"connected\":true,\"longName\":\"TextField.out\",\"type\":\"String\",\"targets\":[\"myId_3_1452872072900\"]}],\"widget\":\"StreamrTextField\",\"jsModule\":\"InputModule\",\"options\":{\"uiResendLast\":{\"value\":1,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}},{\"hash\":3,\"tableConfig\":{\"headers\":[\"timestamp\",\"input1\",\"input2\",\"input3\"]},\"uiChannel\":{\"id\":\"dWeeZawoQKie_nx-XBOz9g\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":142,\"clearState\":false,\"inputs\":[{\"canConnect\":true,\"id\":\"myId_3_1452872065677\",\"drivingInput\":true,\"connected\":true,\"name\":\"input1\",\"longName\":\"Table.input1\",\"type\":\"Object\",\"requiresConnection\":false,\"acceptedTypes\":[\"Object\"],\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1452872011627\"},{\"id\":\"myId_3_1452872072894\",\"canConnect\":true,\"name\":\"input2\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Table.input2\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_1_1452872027491\"},{\"id\":\"myId_3_1452872072900\",\"canConnect\":true,\"name\":\"input3\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Table.input3\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_2_1452872029739\"}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"756px\",\"top\":\"246px\"}},\"name\":\"Table\",\"outputs\":[],\"jsModule\":\"TableModule\",\"options\":{\"uiResendLast\":{\"value\":20,\"type\":\"int\"},\"inputs\":{\"value\":3,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}}]}','2016-01-15 15:36:14','InputModuleDashboardSpec','http://192.168.10.150:8081/unifina-core/api/live/request','s-1452872103763','192.168.10.150','stopped',1,NULL),
	('kldfaj2309jr9wjf9ashjg9sdgu9',3,b'0','2015-11-15 18:09:59',b'0',b'0','{\"name\":\"StopCanvasApiSpec\",\"settings\":{},\"modules\":[]}','2016-02-01 15:29:45','StopCanvasApiSpec','http://192.168.10.21:8081/unifina-core/api/live/request','s-1454340584152','192.168.10.21','running',1,NULL),
	('ON876xeiSOSD2dXsGEQb_Q',0,b'0','2015-07-27 11:32:32',b'0',b'0','{\"name\":\"LiveSpec dead RunningSignalPath\",\"settings\":{},\"uiChannel\":{\"id\":\"WgLkPF3USxqG_TYxpd9hYg\",\"name\":\"Notifications\"},\"modules\":[{\"id\":147,\"clearState\":false,\"inputs\":[],\"hash\":0,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"10px\",\"top\":\"10px\"}},\"name\":\"Stream\",\"params\":[{\"canConnect\":true,\"connected\":false,\"type\":\"Stream\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"streamName\":\"LiveSpec\",\"id\":\"myId_0_1437996708316\",\"name\":\"stream\",\"drivingInput\":false,\"value\":\"RUj6iJggS3iEKsUx5C07Ig\",\"longName\":\"Stream.stream\",\"feed\":7,\"defaultValue\":{},\"acceptedTypes\":[\"Stream\",\"String\"],\"checkModuleId\":true}],\"type\":\"module\",\"outputs\":[{\"id\":\"myId_0_1437996708327\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"rand\",\"connected\":true,\"longName\":\"Stream.rand\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_1_1437996710549\"]}],\"jsModule\":\"GenericModule\"},{\"hash\":1,\"uiChannel\":{\"id\":\"ZcWPkfR3QTq6E24ye5ionA\",\"name\":\"Chart\"},\"params\":[],\"barify\":true,\"type\":\"chart dashboard\",\"id\":67,\"clearState\":false,\"inputs\":[{\"canConnect\":true,\"connected\":true,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"myId_0_1437996708327\",\"id\":\"myId_1_1437996710549\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in1\",\"longName\":\"Chart.in1\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710554\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in2\",\"longName\":\"Chart.in2\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710557\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in3\",\"longName\":\"Chart.in3\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710561\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in4\",\"longName\":\"Chart.in4\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710564\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in5\",\"longName\":\"Chart.in5\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710567\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in6\",\"longName\":\"Chart.in6\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710571\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in7\",\"longName\":\"Chart.in7\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710575\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in8\",\"longName\":\"Chart.in8\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710579\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in9\",\"longName\":\"Chart.in9\",\"acceptedTypes\":[\"Double\"]},{\"canConnect\":true,\"connected\":false,\"canHaveInitialValue\":false,\"type\":\"Double\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_1_1437996710582\",\"feedback\":false,\"yAxis\":0,\"canBeFeedback\":false,\"drivingInput\":true,\"name\":\"in10\",\"longName\":\"Chart.in10\",\"acceptedTypes\":[\"Double\"]}],\"canClearState\":false,\"layout\":{\"position\":{\"left\":\"249px\",\"top\":\"42px\"},\"height\":\"500px\",\"width\":\"800px\",\"workspaces\":{\"normal\":{\"position\":{\"left\":\"249px\",\"top\":\"42px\"}}}},\"name\":\"Chart\",\"outputs\":[],\"options\":{\"ignoreBefore\":{\"value\":\"00:00:00\",\"type\":\"string\"},\"ignoreEnabled\":{\"value\":false,\"type\":\"boolean\"},\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"inputs\":{\"value\":10,\"type\":\"int\"},\"overnightBreak\":{\"value\":true,\"type\":\"boolean\"},\"ignoreAfter\":{\"value\":\"23:59:59\",\"type\":\"string\"},\"uiResendAll\":{\"value\":true,\"type\":\"boolean\"}},\"jsModule\":\"ChartModule\"}]}','2016-02-02 12:32:50','LiveSpec dead','http://192.168.10.21:8089/unifina-core/api/live/request','s-1454416146004','192.168.10.21','running',1,NULL),
	('share-spec-canvas-uuid',0,b'0','2016-02-22 15:00:00',b'0',b'0','{\"name\":\"CanvasSpec test loading a SignalPath\",\"settings\":{\"speed\":\"0\",\"timeOfDayFilter\":{\"timeZoneOffset\":120,\"timeOfDayStart\":\"00:00:00\",\"timeZoneDst\":true,\"timeOfDayEnd\":\"23:59:00\",\"timeZone\":\"Europe/Helsinki\"},\"endDate\":\"2015-07-03\",\"beginDate\":\"2015-07-02\"},\"uiChannel\":{},\"modules\":[]}','2016-02-22 15:00:00','ShareSpec',NULL,NULL,NULL,'stopped',1,NULL),
	('TDl025VRQbqgY2DpQK4mRg',36,b'0','2016-09-28 13:35:27',b'0',b'0','{\"name\":\"LiveSpec-SendToStream\",\"modules\":[{\"id\":161,\"inputs\":[{\"id\":\"ep_qsg4iRdZSB-Pq0IcmxS_9A\",\"canConnect\":true,\"name\":\"in\",\"connected\":true,\"drivingInput\":true,\"longName\":\"Count.in\",\"type\":\"Object\",\"acceptedTypes\":[\"Object\"],\"requiresConnection\":true,\"canToggleDrivingInput\":true,\"sourceId\":\"ep_hSbwDnGTRd2t54CL_pBS-A\"}],\"hash\":1,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"338px\",\"top\":\"46px\"}},\"name\":\"Count\",\"params\":[{\"id\":\"ep_MEWPuw9DTGa88peQjYUyVw\",\"canConnect\":true,\"name\":\"windowLength\",\"connected\":false,\"drivingInput\":false,\"longName\":\"Count.windowLength\",\"value\":0,\"type\":\"Double\",\"defaultValue\":0,\"acceptedTypes\":[\"Double\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true},{\"id\":\"ep_0SRppr4tRKyErRy6C-7nNQ\",\"canConnect\":true,\"possibleValues\":[{\"name\":\"events\",\"value\":\"EVENTS\"},{\"name\":\"seconds\",\"value\":\"SECONDS\"},{\"name\":\"minutes\",\"value\":\"MINUTES\"},{\"name\":\"hours\",\"value\":\"HOURS\"},{\"name\":\"days\",\"value\":\"DAYS\"}],\"name\":\"windowType\",\"connected\":false,\"drivingInput\":false,\"longName\":\"Count.windowType\",\"value\":\"EVENTS\",\"type\":\"String\",\"defaultValue\":\"events\",\"acceptedTypes\":[\"String\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true},{\"id\":\"ep_3r7oc8dxQzquNpY_fUSzQw\",\"canConnect\":true,\"name\":\"minSamples\",\"connected\":false,\"drivingInput\":false,\"longName\":\"Count.minSamples\",\"value\":0,\"type\":\"Double\",\"defaultValue\":0,\"acceptedTypes\":[\"Double\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true}],\"type\":\"module\",\"outputs\":[{\"id\":\"ep_tYYg4QvzSQGOkr7wb-k0pw\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"count\",\"connected\":true,\"longName\":\"Count.count\",\"noRepeat\":true,\"type\":\"Double\",\"targets\":[\"ep_uBfpd87JSs2bVIhMJGTPAA\",\"ep_qnB2eF2XQNSbK9jsWUS-cQ\"]}],\"jsModule\":\"GenericModule\"},{\"hash\":2,\"tableConfig\":{\"headers\":[\"timestamp\",\"count\"]},\"uiChannel\":{\"id\":\"F8_rgQRDR-ODa8oeW_VWkA\",\"webcomponent\":\"streamr-table\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":527,\"inputs\":[{\"canConnect\":true,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"ep_tYYg4QvzSQGOkr7wb-k0pw\",\"id\":\"ep_qnB2eF2XQNSbK9jsWUS-cQ\",\"variadic\":{\"isLast\":false,\"index\":1},\"name\":\"endpoint-1475069711012\",\"drivingInput\":true,\"longName\":\"Table.endpoint-1475069711012\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"export\":false,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_2_1475069714722\",\"variadic\":{\"isLast\":true,\"index\":2},\"name\":\"endpoint1475069714721\",\"drivingInput\":true,\"longName\":\"Table.endpoint1475069714721\",\"displayName\":\"in2\",\"acceptedTypes\":[\"Object\"]}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"1218px\",\"top\":\"49px\"}},\"name\":\"Table\",\"outputs\":[],\"jsModule\":\"TableModule\",\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}}},{\"id\":209,\"inputs\":[],\"hash\":3,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"64px\",\"top\":\"58px\"}},\"name\":\"Clock\",\"params\":[{\"id\":\"ep_Rw1vfMtORdaajsIONqLrBQ\",\"canConnect\":true,\"name\":\"format\",\"connected\":false,\"drivingInput\":false,\"longName\":\"Clock.format\",\"value\":\"yyyy-MM-dd HH:mm:ss z\",\"type\":\"String\",\"defaultValue\":\"yyyy-MM-dd HH:mm:ss z\",\"acceptedTypes\":[\"String\"],\"requiresConnection\":false,\"canToggleDrivingInput\":true}],\"type\":\"module\",\"outputs\":[{\"id\":\"ep_hSbwDnGTRd2t54CL_pBS-A\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"date\",\"connected\":true,\"longName\":\"Clock.date\",\"noRepeat\":true,\"type\":\"String\",\"targets\":[\"ep_qsg4iRdZSB-Pq0IcmxS_9A\"]},{\"id\":\"ep_nLcbzr4vQS-gyEYhtAbxhQ\",\"canConnect\":true,\"canBeNoRepeat\":true,\"name\":\"timestamp\",\"connected\":false,\"longName\":\"Clock.timestamp\",\"noRepeat\":true,\"type\":\"Double\"}],\"jsModule\":\"GenericModule\"},{\"id\":197,\"inputs\":[{\"feedback\":false,\"canConnect\":true,\"id\":\"ep_uBfpd87JSs2bVIhMJGTPAA\",\"canBeFeedback\":false,\"drivingInput\":true,\"connected\":true,\"name\":\"count\",\"canHaveInitialValue\":false,\"longName\":\"SendToStream.count\",\"type\":\"Double\",\"requiresConnection\":false,\"acceptedTypes\":[\"Double\"],\"canToggleDrivingInput\":false,\"sourceId\":\"ep_tYYg4QvzSQGOkr7wb-k0pw\"}],\"hash\":4,\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"715px\",\"top\":\"162px\"}},\"name\":\"SendToStream\",\"params\":[{\"feedFilter\":7,\"canConnect\":true,\"updateOnChange\":true,\"connected\":false,\"type\":\"Stream\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"streamName\":\"LiveSpec-SendToStream\",\"id\":\"ep_B8lD1ohEQdyEWBzKuLKoCQ\",\"name\":\"stream\",\"drivingInput\":false,\"longName\":\"SendToStream.stream\",\"value\":\"4jFT4_yRSFyElSj9pHmovg\",\"feed\":7,\"defaultValue\":null,\"acceptedTypes\":[\"Stream\",\"String\"]}],\"type\":\"module\",\"outputs\":[],\"jsModule\":\"GenericModule\"},{\"hash\":6,\"tableConfig\":{\"headers\":[\"timestamp\",\"count\"]},\"uiChannel\":{\"id\":\"cQqKQ-NeTw6nHWmNRYp05g\",\"webcomponent\":\"streamr-table\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":527,\"inputs\":[{\"canConnect\":true,\"export\":false,\"connected\":true,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"sourceId\":\"ep_ml0N9ZBrTzetW6TP4gqStA\",\"id\":\"myId_6_1475071172798\",\"variadic\":{\"isLast\":false,\"index\":2},\"name\":\"endpoint1475071172797\",\"drivingInput\":true,\"longName\":\"Table.endpoint1475071172797\",\"displayName\":\"in2\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"export\":false,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_6_1475071182269\",\"variadic\":{\"isLast\":true,\"index\":3},\"name\":\"endpoint1475071182268\",\"drivingInput\":true,\"longName\":\"Table.endpoint1475071182268\",\"displayName\":\"in3\",\"acceptedTypes\":[\"Object\"]}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"471px\",\"top\":\"331px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":0,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"},{\"id\":147,\"inputs\":[],\"hash\":7,\"canClearState\":true,\"name\":\"Stream\",\"layout\":{\"position\":{\"left\":\"87px\",\"top\":\"335px\"}},\"params\":[{\"canConnect\":true,\"updateOnChange\":true,\"connected\":false,\"type\":\"Stream\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"streamName\":\"LiveSpec-SendToStream\",\"id\":\"ep_HHktPBVlSN-a61nTICFY6w\",\"name\":\"stream\",\"drivingInput\":false,\"value\":\"4jFT4_yRSFyElSj9pHmovg\",\"longName\":\"Stream.stream\",\"feed\":7,\"defaultValue\":null,\"acceptedTypes\":[\"Stream\",\"String\"],\"checkModuleId\":true}],\"outputs\":[{\"canBeNoRepeat\":true,\"canConnect\":true,\"id\":\"ep_ml0N9ZBrTzetW6TP4gqStA\",\"connected\":true,\"name\":\"count\",\"longName\":\"Stream.count\",\"noRepeat\":false,\"type\":\"Double\",\"targets\":[\"myId_6_1475071172798\"]}],\"type\":\"module\",\"jsModule\":\"StreamModule\"}],\"settings\":{\"editorState\":{\"runTab\":\"#tab-realtime\"},\"speed\":\"0\",\"timeOfDayFilter\":{\"timeOfDayStart\":\"00:00:00\",\"timeOfDayEnd\":\"23:59:00\"},\"endDate\":\"2016-04-12\",\"beginDate\":\"2016-04-11\"},\"hasExports\":false,\"uiChannel\":{\"id\":\"6mPRj-rITHyaimxbzr6LnQ\",\"webcomponent\":null,\"name\":\"Notifications\"}}','2016-09-29 08:25:56','LiveSpec-SendToStream','http://192.168.10.137:8081/unifina-core/api/v1/canvases/TDl025VRQbqgY2DpQK4mRg','s-1475137545525','192.168.10.137','stopped',1,NULL),
	('VWo3BDECTASlAdtZk7QeeQ',9,b'0','2016-08-29 13:49:09',b'0',b'1','{\"name\":\"SubCanvasSpec-sub\",\"modules\":[{\"id\":145,\"inputs\":[{\"canConnect\":true,\"id\":\"LUaoljnHRmC0i0AEYWO_Gw\",\"export\":true,\"drivingInput\":true,\"connected\":false,\"name\":\"label\",\"longName\":\"Label.label\",\"type\":\"Object\",\"requiresConnection\":true,\"acceptedTypes\":[\"Object\"],\"canToggleDrivingInput\":false}],\"hash\":5,\"canClearState\":false,\"name\":\"Label\",\"layout\":{\"position\":{\"left\":\"189px\",\"top\":\"94px\"}},\"uiChannel\":{\"id\":\"SqUC_6rBSVqLs9HHMPaSRg\",\"webcomponent\":\"streamr-label\",\"name\":\"Label\"},\"params\":[],\"outputs\":[],\"type\":\"module dashboard\",\"jsModule\":\"LabelModule\"},{\"hash\":7,\"tableConfig\":{\"headers\":[\"timestamp\",\"in1\"]},\"uiChannel\":{\"id\":\"FIwXENHwQye40m9IxV1TmA\",\"webcomponent\":\"streamr-table\",\"name\":\"Table\"},\"params\":[],\"type\":\"module event-table-module\",\"id\":527,\"inputs\":[{\"canConnect\":true,\"export\":true,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"ep_qMiYZPCeR3K1OJQIyP_GXA\",\"variadic\":{\"isLast\":false,\"index\":1},\"name\":\"endpoint-1472821604763\",\"drivingInput\":true,\"longName\":\"Table.endpoint-1472821604763\",\"displayName\":\"in1\",\"acceptedTypes\":[\"Object\"]},{\"canConnect\":true,\"export\":false,\"connected\":false,\"jsClass\":\"VariadicInput\",\"type\":\"Object\",\"requiresConnection\":false,\"canToggleDrivingInput\":false,\"id\":\"myId_7_1472821608592\",\"variadic\":{\"isLast\":true,\"index\":2},\"name\":\"endpoint1472821608591\",\"drivingInput\":true,\"displayName\":\"in2\",\"acceptedTypes\":[\"Object\"],\"longName\":\"Table.endpoint1472821608591\"}],\"canClearState\":true,\"layout\":{\"position\":{\"left\":\"242px\",\"top\":\"255px\"}},\"name\":\"Table\",\"outputs\":[],\"options\":{\"uiResendLast\":{\"value\":20,\"type\":\"int\"},\"maxRows\":{\"value\":20,\"type\":\"int\"},\"uiResendAll\":{\"value\":false,\"type\":\"boolean\"}},\"jsModule\":\"TableModule\"}],\"settings\":{\"editorState\":{\"runTab\":\"#tab-historical\"},\"speed\":\"0\",\"timeOfDayFilter\":{\"timeOfDayStart\":\"00:00:00\",\"timeOfDayEnd\":\"23:59:00\"},\"endDate\":\"2016-08-29\",\"beginDate\":\"2016-08-29\"},\"hasExports\":true,\"uiChannel\":{\"id\":\"4AOpGMe6SYecTgPrsDR4pQ\",\"webcomponent\":null,\"name\":\"Notifications\"}}','2016-09-02 13:06:55','SubCanvasSpec-sub',NULL,NULL,NULL,'stopped',1,NULL);

/*!40000 ALTER TABLE `canvas` ENABLE KEYS */;
UNLOCK TABLES;


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

LOCK TABLES `dashboard` WRITE;
/*!40000 ALTER TABLE `dashboard` DISABLE KEYS */;

INSERT INTO `dashboard` (`id`, `version`, `date_created`, `last_updated`, `name`, `user_id`)
VALUES
	(1,0,'2016-02-22 15:00:00','2016-02-22 15:00:00','ShareSpec',1),
	(456456,0,'2016-06-07 00:00:00','2016-06-07 00:00:00','DashboardSpecNotSharedDashboard',2),
	(567567,0,'2016-06-07 00:00:00','2016-06-07 00:00:00','DashboardSpecReadSharedDashboard',2),
	(678678,0,'2016-06-07 00:00:00','2016-06-07 00:00:00','DashboardSpecShareSharedDashboard',2);

/*!40000 ALTER TABLE `dashboard` ENABLE KEYS */;
UNLOCK TABLES;


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
  `canvas_id` varchar(255) NOT NULL,
  `module` int(11) NOT NULL,
  `webcomponent` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKF4B0C5DE70E281EB` (`dashboard_id`),
  KEY `FKF4B0C5DE3D649786` (`canvas_id`),
  CONSTRAINT `FKF4B0C5DE3D649786` FOREIGN KEY (`canvas_id`) REFERENCES `canvas` (`id`),
  CONSTRAINT `FKF4B0C5DE70E281EB` FOREIGN KEY (`dashboard_id`) REFERENCES `dashboard` (`id`)
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
	('1452621480175-9','admin (generated)','core/2016-01-12-initial-db-state.groovy','2016-01-12 18:06:15',15,'EXECUTED','3:c79769b52ad9640ff4e86cdc0134fac6','Create Table','',NULL,'2.0.5'),
	('1452621480180-100','aapeli','core/2016-02-04-rate-limit-module.groovy','2017-05-03 10:24:40',72,'EXECUTED','3:1a844ae9f11a063811ca4b586e17eb3c','Custom SQL','',NULL,'2.0.5'),
	('1452621480275-10','aapeli','core/2016-02-04-stream-module-js-module-change.groovy','2017-05-03 10:24:40',73,'EXECUTED','3:5382e678958658892af6352cf2273725','Custom SQL','',NULL,'2.0.5'),
	('1452621480375-1','aapeli','core/2016-02-04-scheduler-module-added.groovy','2017-05-03 10:25:15',148,'EXECUTED','3:345b0af252a998538e0aec4fe60528e9','Custom SQL','',NULL,'2.0.5'),
	('145262149000-36','aapeli','core/2016-01-28-streamr-map-module.groovy','2017-05-03 10:24:40',70,'EXECUTED','3:1bbd27f03622cf9ef6634d532f14e281','Custom SQL','',NULL,'2.0.5'),
	('145262149100-36','aapeli','core/2016-02-05-color-modules.groovy','2017-05-03 10:24:40',71,'EXECUTED','3:cfb2c485d6905029071acffa22b16655','Custom SQL (x2)','',NULL,'2.0.5'),
	('1452674923112-1','jtakalai (generated)','core/2016-01-13-permission-feature.groovy','2017-05-03 10:24:55',103,'EXECUTED','3:0d6d5cacc07751ab8984a5fee9db0ba7','Create Table','',NULL,'2.0.5'),
	('1452674923112-2','jtakalai (generated)','core/2016-01-13-permission-feature.groovy','2017-05-03 10:24:57',106,'EXECUTED','3:c70b9db19635a31b9b5e99f535b02314','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1452674923112-3','jtakalai (generated)','core/2016-01-13-permission-feature.groovy','2017-05-03 10:24:56',105,'EXECUTED','3:71d487a6c2e7e7ca2abc01d26564d80a','Create Index','',NULL,'2.0.5'),
	('1452674923112-4','jtakalai (generated)','core/2016-01-13-permission-feature.groovy','2017-05-03 10:24:55',104,'EXECUTED','3:6dfa90b95db7aa4f00858b98843d6ff5','Custom SQL (x2)','',NULL,'2.0.5'),
	('1452676788216-1','aapeli','core/2016-01-13-input-modules-added.groovy','2017-05-03 10:24:40',74,'EXECUTED','3:f5edc68e11dee6012a2aee0c13e93809','Custom SQL (x2)','',NULL,'2.0.5'),
	('1452696039238-1','eric','core/2016-01-13-api-feature.groovy','2017-05-03 10:24:41',75,'EXECUTED','3:7e196be5d8ce215ccb7f4d7db64e5f35','Add Column','',NULL,'2.0.5'),
	('1452696039238-2','eric','core/2016-01-13-api-feature.groovy','2017-05-03 10:24:42',76,'EXECUTED','3:9f75724f0e2be4f07ec143d644bafdc5','Rename Column','',NULL,'2.0.5'),
	('1452696039238-3','eric','core/2016-01-13-api-feature.groovy','2017-05-03 10:24:44',78,'EXECUTED','3:16c237552c361cb41e407f1b3e194184','Drop Index','',NULL,'2.0.5'),
	('1452696039238-4','eric','core/2016-01-13-api-feature.groovy','2017-05-03 10:24:43',77,'EXECUTED','3:1b19a3ec7669267dd60f756f884496a2','Drop Column','',NULL,'2.0.5'),
	('1452696039238-5','eric','core/2016-01-13-api-feature.groovy','2017-05-03 10:24:44',79,'EXECUTED','3:12ad4acb386dafda6a184f83a0e6ad28','Drop Column','',NULL,'2.0.5'),
	('14533384829304-16','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:52',95,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('1453384829304-1','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:44',80,'EXECUTED','3:4fd9d25c64e5bc7778a92de833785d19','Create Table','',NULL,'2.0.5'),
	('1453384829304-10','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:49',89,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('1453384829304-11','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:49',90,'EXECUTED','3:71cd416692eea67b2bdfdb10e26f7542','Drop Column','',NULL,'2.0.5'),
	('1453384829304-12','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:49',91,'EXECUTED','3:d1ffbb338a786ae711f9b5647510eccd','Drop Table','',NULL,'2.0.5'),
	('1453384829304-13','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:50',92,'EXECUTED','3:3ac67fa7614bcf476e1f656e90661aa6','Drop Table','',NULL,'2.0.5'),
	('1453384829304-14','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:51',93,'EXECUTED','3:4b19738ab03b4456f343f162f760f3f1','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1453384829304-15','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:52',94,'EXECUTED','3:ebeb8a7a1e5658f1f2b74e4c713dce0b','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1453384829304-2','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:45',81,'EXECUTED','3:f9209925806dc6e2cd36d2bf9b87378c','Add Column','',NULL,'2.0.5'),
	('1453384829304-3','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:45',82,'EXECUTED','3:05dec4c486d68ab142913a6bde58894b','Drop Foreign Key Constraint','',NULL,'2.0.5'),
	('1453384829304-4','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:46',83,'EXECUTED','3:a85238533b9f4e49ada938c15551ed9f','Drop Foreign Key Constraint','',NULL,'2.0.5'),
	('1453384829304-5','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:46',84,'EXECUTED','3:d160f5d73e30e0f8a131b176169ac60d','Drop Foreign Key Constraint','',NULL,'2.0.5'),
	('1453384829304-6','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:47',85,'EXECUTED','3:4fe656d340da8caf76a2e9eb40d8cf78','Drop Index','',NULL,'2.0.5'),
	('1453384829304-7','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:48',86,'EXECUTED','3:a26e152d3a90770695f1bd6e52a5b361','Create Index','',NULL,'2.0.5'),
	('1453384829304-8','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:48',87,'EXECUTED','3:0d3d60515df4ec9200b3ad54e9006df5','Create Index','',NULL,'2.0.5'),
	('1453384829304-9','eric','core/2016-01-21-replace-running-and-saved-signal-paths-with-canvas.groovy','2017-05-03 10:24:48',88,'EXECUTED','3:d3068216765024470b3f25b3b1446222','Create Index','',NULL,'2.0.5'),
	('1455013969117-1','jtakalai (generated)','core/2016-02-09-permissions-for-signupinvites.groovy','2017-05-03 10:24:58',107,'EXECUTED','3:32bf35bc16d7d75d92b05bc42cdc5505','Add Column','',NULL,'2.0.5'),
	('1455013969117-3','jtakalai (generated)','core/2016-02-09-permissions-for-signupinvites.groovy','2017-05-03 10:24:58',108,'EXECUTED','3:08401fd2e4ed455057bee438089299fa','Drop Not-Null Constraint','',NULL,'2.0.5'),
	('1455013969117-4','jtakalai (generated)','core/2016-02-09-permissions-for-signupinvites.groovy','2017-05-03 10:24:59',110,'EXECUTED','3:1704c3a168cccd38af27adca238ca633','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1455013969117-5','jtakalai (generated)','core/2016-02-09-permissions-for-signupinvites.groovy','2017-05-03 10:24:59',109,'EXECUTED','3:75048a98f1babc1bafe4b5ea0aaaa2af','Create Index','',NULL,'2.0.5'),
	('1455118124727-1','jtakalai','core/2016-02-10-remove-feeduser-modulepackageuser.groovy','2017-05-03 10:25:00',111,'EXECUTED','3:4d4832d3c892c975a74d3897ca5bb1f9','Drop Table','',NULL,'2.0.5'),
	('1455118124727-2','jtakalai','core/2016-02-10-remove-feeduser-modulepackageuser.groovy','2017-05-03 10:25:00',112,'EXECUTED','3:8ee75acaf2878f75d75d86b3f0e60a05','Drop Table','',NULL,'2.0.5'),
	('1456405093736-1','henripihkala (generated)','core/2016-02-25-feed-data-range-provider.groovy','2017-05-03 10:24:54',102,'EXECUTED','3:9c1e29ca6630a5efff5bb842383fe96e','Add Column, Custom SQL (x2)','',NULL,'2.0.5'),
	('1457014368299-1','jtakalai (generated)','core/2016-03-03-add-anonymous-access.groovy','2017-05-03 10:25:01',114,'EXECUTED','3:fbcce1d96e1619790b02acddc91a0b77','Add Column','',NULL,'2.0.5'),
	('1457514548258-1','jtakalai (generated)','core/2016-03-09-eliminate-canvas-shared.groovy','2017-05-03 10:25:03',116,'EXECUTED','3:3c7f328c1ffdcea7a230a977bc0351a5','Custom SQL, Drop Column','',NULL,'2.0.5'),
	('1458240759438-1','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:11',136,'EXECUTED','3:8a3e98580ddf52bc9d894d9d03df851a','Add Column','',NULL,'2.0.5'),
	('1458240759438-10','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:14',146,'EXECUTED','3:b3a7af94903e2f3ac17542e489ce76f7','Drop Table','',NULL,'2.0.5'),
	('1458240759438-2','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:11',137,'EXECUTED','3:1f86dda2ae4b437e14d316e503e9a086','Add Column','',NULL,'2.0.5'),
	('1458240759438-3','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:12',138,'EXECUTED','3:bb48a911874b2e62cd93c1a16816d6ee','Add Column','',NULL,'2.0.5'),
	('1458240759438-4','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:12',141,'EXECUTED','3:8d9efc7847635da2491dfce97b4cbb49','Drop Foreign Key Constraint','',NULL,'2.0.5'),
	('1458240759438-5','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:12',142,'EXECUTED','3:83ab7bb58652b0b1875e21c464a559a1','Drop Foreign Key Constraint','',NULL,'2.0.5'),
	('1458240759438-6','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:13',143,'EXECUTED','3:fc3edcfa031b60ddf711215209b991ef','Drop Foreign Key Constraint','',NULL,'2.0.5'),
	('1458240759438-7','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:15',147,'EXECUTED','3:1efbc2c77d459b674bf1321ce711144e','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1458240759438-8','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:13',144,'EXECUTED','3:a756b5d4c81666b2edfc01bacffb0086','Create Index','',NULL,'2.0.5'),
	('1458240759438-9','henripihkala (generated)','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:14',145,'EXECUTED','3:343b19f0394cf37523113c16075994f7','Drop Column','',NULL,'2.0.5'),
	('1462796936141-1','aapeli (generated)','core/2016-05-09-stream-date-created-and-last-updated.groovy','2017-05-03 10:25:16',153,'EXECUTED','3:ea05274c96e8adf175048d860fbeca60','Add Column','',NULL,'2.0.5'),
	('1462796936141-2','aapeli (generated)','core/2016-05-09-stream-date-created-and-last-updated.groovy','2017-05-03 10:25:16',154,'EXECUTED','3:d62046230f2457a1c7a4a7a9362909d1','Add Column','',NULL,'2.0.5'),
	('1462796936141-3','aapeli (generated)','core/2016-05-09-stream-date-created-and-last-updated.groovy','2017-05-03 10:25:17',155,'EXECUTED','3:e7398cd418a34e57f406704736b0b936','Drop Not-Null Constraint','',NULL,'2.0.5'),
	('1470681247023-1','admin (generated)','core/2016-08-08-drop-unique-constraint-on-signupinvite.groovy','2017-05-03 10:25:20',178,'EXECUTED','3:afccbfa31bf924a5b43488bc49bb53b9','Drop Index','',NULL,'2.0.5'),
	('1474977762795-1','new-data-pipeline-2','core/2016-09-29-new-data-pipeline.groovy','2017-05-03 10:25:25',217,'EXECUTED','3:111a6b923fa589450be802a39580362f','Add Column','',NULL,'2.0.5'),
	('1489340226120-1','admin (generated)','core/2017-03-12-ui-channel-streams.groovy','2017-05-03 10:25:26',219,'EXECUTED','3:945e087d6a981901422bda19cb660c9c','Add Column','',NULL,'2.0.5'),
	('1489340226120-2','admin (generated)','core/2017-03-12-ui-channel-streams.groovy','2017-05-03 10:25:27',220,'EXECUTED','3:6a0aff596c94a128e4428e5730a7986e','Add Column','',NULL,'2.0.5'),
	('1489340226120-3','admin (generated)','core/2017-03-12-ui-channel-streams.groovy','2017-05-03 10:25:27',221,'EXECUTED','3:2e5c4b12e63109d050967bb6053d2ba1','Add Column','',NULL,'2.0.5'),
	('1489340226120-4','admin (generated)','core/2017-03-12-ui-channel-streams.groovy','2017-05-03 10:25:29',224,'EXECUTED','3:f00698777b1a1c0032e90813aa219ec3','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('1489340226120-5','admin (generated)','core/2017-03-12-ui-channel-streams.groovy','2017-05-03 10:25:28',222,'EXECUTED','3:0a0995ea4f9a914e04317e88dadde402','Create Index','',NULL,'2.0.5'),
	('1489340226120-6','admin (generated)','core/2017-03-12-ui-channel-streams.groovy','2017-05-03 10:25:28',223,'EXECUTED','3:185919bd0e6c539db3f309bd4f377e93','Create Index','',NULL,'2.0.5'),
	('2016-07-06-twitter-feed-1','jtakalai','core/2016-07-06-twitter-feed.groovy','2017-05-03 10:25:20',177,'EXECUTED','3:092b718dc08b43d3733645b66c23e029','Insert Row','',NULL,'2.0.5'),
	('2016-08-19-foreach-module-js','henri','core/2016-08-19-foreach-module-js.groovy','2017-05-03 10:25:21',190,'EXECUTED','3:53959e629557c799324302ada6ea0fc4','Custom SQL','',NULL,'2.0.5'),
	('2016-08-30-test-fixtures-foreach-subcanvas','henri','core/2016-08-30-test-fixtures-foreach-subcanvas.groovy','2017-05-03 10:25:24',209,'EXECUTED','3:cb37c3f6c46678ed33d9f1c2a4ebef09','Custom SQL (x2)','',NULL,'2.0.5'),
	('2016-09-01-canvas-module-js','henri','core/2016-08-19-foreach-module-js.groovy','2017-05-03 10:25:22',191,'EXECUTED','3:f7729aa197a0f27824cbcacabffcb06a','Custom SQL','',NULL,'2.0.5'),
	('2016021931337-1','jtakalai','core/2016-02-19-add-sharespec-test-data.groovy','2017-05-03 10:25:01',113,'EXECUTED','3:e44cfe42a855d96031729f0aed6ea8b7','Insert Row (x3)','',NULL,'2.0.5'),
	('2016030700000-1','jtakalai','core/2016-03-07-replace-default-feed-mpkg-with-anonymous-permissions.groovy','2017-05-03 10:25:01',115,'EXECUTED','3:bcc313e73c7c90434c6010507874ea62','Insert Row (x2)','',NULL,'2.0.5'),
	('2016031801409-1','jtakalai','core/2016-03-18-add-http-module.groovy','2017-05-03 10:25:15',150,'EXECUTED','3:1ffff658fd88e8971c6462ed6ce669b7','Insert Row','',NULL,'2.0.5'),
	('2016031801409-2','jtakalai','core/2016-03-18-add-http-module.groovy','2017-05-03 10:25:15',151,'EXECUTED','3:cbd7c15d819b4b230c82f030bf709f1f','Insert Row','',NULL,'2.0.5'),
	('2016031801409-3','jtakalai','core/2016-03-18-add-http-module.groovy','2017-05-03 10:25:15',149,'EXECUTED','3:b07eb2b2d0d056b5bcf8c2784d3ecc4e','Insert Row','',NULL,'2.0.5'),
	('20160520-1406-1','jtakalai','core/2016-05-20-add-sql-module.groovy','2017-05-03 10:25:17',157,'EXECUTED','3:4cc94ff0eafab3a18c5e90481c91832a','Insert Row','',NULL,'2.0.5'),
	('20160523-1504-2','jtakalai','core/2016-05-23-add-list-table-module.groovy','2017-05-03 10:25:17',158,'EXECUTED','3:d8862856405531bef68bcd30ef887675','Insert Row','',NULL,'2.0.5'),
	('20160524-1226-1','jtakalai','core/2016-05-24-add-string-template-module.groovy','2017-05-03 10:25:21',186,'EXECUTED','3:6af86a96218b63e7434aa23eed24e50a','Insert Row','',NULL,'2.0.5'),
	('20160525-1713','jtakalai','core/2016-05-24-add-string-template-module.groovy','2017-05-03 10:25:21',187,'EXECUTED','3:427b0fa4ed8674c8447703c863ce92d8','Insert Row','',NULL,'2.0.5'),
	('20160822-1438-1','jtakalai','core/2016-08-22-get-from-list-module.groovy','2017-05-03 10:25:21',184,'EXECUTED','3:0ef47fe5754e65959d7e99937ff39047','Insert Row','',NULL,'2.0.5'),
	('870-add-list-to-events-module','jtakalai','core/2017-03-08-list-to-events-module.groovy','2017-05-03 10:25:36',243,'EXECUTED','3:393b109849565ccb53ce740ca9475011','Insert Row','',NULL,'2.0.5'),
	('add-convert-module-type-and-boolean-to-number-module','aapeli','core/2016-05-09-boolean-modules.groovy','2017-05-03 10:25:15',152,'EXECUTED','3:ece8537e4fc25e7aab1f7e455b4abae4','Custom SQL (x3)','',NULL,'2.0.5'),
	('add-key-domain-object-1','eric','core/2017-03-13-add-key-domain-object.groovy','2017-05-03 10:25:33',233,'EXECUTED','3:306f7f030c2990b2e4a16bfa774d47d2','Create Table','',NULL,'2.0.5'),
	('add-key-domain-object-2','eric','core/2017-03-13-add-key-domain-object.groovy','2017-05-03 10:25:33',234,'EXECUTED','3:917fdcfd59333cada4b1520b2550490c','Add Column','',NULL,'2.0.5'),
	('add-key-domain-object-3','eric','core/2017-03-13-add-key-domain-object.groovy','2017-05-03 10:25:34',235,'EXECUTED','3:54fa32da448c4982ca1e550266e9da76','Create Index','',NULL,'2.0.5'),
	('add-key-domain-object-4','eric','core/2017-03-13-add-key-domain-object.groovy','2017-05-03 10:25:34',236,'EXECUTED','3:ff42fd6351b278e8531fbc7ab896700f','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('add-key-domain-object-5','eric','core/2017-03-13-add-key-domain-object.groovy','2017-05-03 10:25:34',237,'EXECUTED','3:d6e27798b0fce98c5e7c4346ee98e599','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('add-stream-modules-1','eric','core/2016-08-03-add-stream-modules.groovy','2017-05-03 10:25:20',179,'EXECUTED','3:2b9f1c93cd324814740dc75f48a0c8a4','Insert Row','',NULL,'2.0.5'),
	('add-stream-modules-2','eric','core/2016-08-03-add-stream-modules.groovy','2017-05-03 10:25:20',180,'EXECUTED','3:476b99b6531dedf45f2ce02f50e87f72','Insert Row','',NULL,'2.0.5'),
	('add-stream-modules-3','eric','core/2016-08-03-add-stream-modules.groovy','2017-05-03 10:25:20',181,'EXECUTED','3:71d8183c4ffbcdb62c6b81abae50fd7e','Insert Row','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-1','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:05',126,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-10','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:10',135,'EXECUTED','3:dfba78fb5daaba3a317688f18e0941cc','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-2','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:06',127,'EXECUTED','3:c951bb710cfb2a749705e6daec47a807','Add Column','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-3','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:06',128,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-4','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:07',129,'EXECUTED','3:be144e10b12a8888d98f4c11b8ef792b','Drop Foreign Key Constraint, Drop Column','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-5','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:07',130,'EXECUTED','3:c10d25fbaa8a3d7ee18eba2554fa884e','Drop Column','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-6','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:08',131,'EXECUTED','3:f61fe7e9a886decdb50bdfda24ed7232','Rename Column, Add Primary Key','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-7','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:09',132,'EXECUTED','3:d09478c64e9dd5d675931f30f37a7ecd','Rename Column','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-8','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:10',133,'EXECUTED','3:e3cd44ea4c2a329e1f2e7ac37dab4516','Add Not-Null Constraint','',NULL,'2.0.5'),
	('change-canvas-stream-modules-id-9','eric','core/2016-03-29-change-canvas-stream-modules-id.groovy','2017-05-03 10:25:10',134,'EXECUTED','3:47351edd94c8b5138581fca32833a2fa','Create Index','',NULL,'2.0.5'),
	('clock-module-update','eric','core/2016-12-15-clock-module-update.groovy','2017-05-03 10:25:24',214,'EXECUTED','3:cddb0c8bcd382278888aa91fb8c6af5e','Update Data','',NULL,'2.0.5'),
	('collect-from-maps-module','eric','core/2016-06-14-collect-from-maps-module.groovy','2017-05-03 10:25:18',168,'EXECUTED','3:d2ac6d10d9c97ee9d76033e4984bebc7','Insert Row','',NULL,'2.0.5'),
	('consant-naming-coherence','henri','core/2016-03-28-constant-map.groovy','2017-05-03 10:25:05',125,'EXECUTED','3:e61bdef867714ac459906c4821f937ea','Custom SQL (x2)','',NULL,'2.0.5'),
	('constant-list','henri','core/2016-06-10-constant-list.groovy','2017-05-03 10:25:18',162,'EXECUTED','3:8adf2a9f8a0280257b5d9c16f4549222','Custom SQL (x2)','',NULL,'2.0.5'),
	('constant-map','henri','core/2016-03-28-constant-map.groovy','2017-05-03 10:25:05',124,'EXECUTED','3:95943dd9e63d15adfe4b1d70f3ce146d','Custom SQL','',NULL,'2.0.5'),
	('drop-ui-channel-updatedata-1','henripihkala','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:12',139,'EXECUTED','3:933e0c86898fcd2ad090fc396c312079','Custom SQL','',NULL,'2.0.5'),
	('drop-ui-channel-updatedata-2','henripihkala','core/2016-03-17-drop-ui-channel.groovy','2017-05-03 10:25:12',140,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('each-with-index-1','eric','core/2016-08-22-each-with-index-module.groovy','2017-05-03 10:25:21',185,'EXECUTED','3:2986898f5b724c589925bdc50b02a8a1','Insert Row','',NULL,'2.0.5'),
	('export-csv-module','eric','core/2016-12-10-export-csv-module.groovy','2017-05-03 10:25:24',213,'EXECUTED','3:c16f666ca5e876fda4edcb7721d2df99','Insert Row','',NULL,'2.0.5'),
	('expression-module-1','eric','core/2016-03-10-expression-module.groovy','2017-05-03 10:25:21',189,'EXECUTED','3:69ea7ba935998c80d1b3bebc55c782ef','Insert Row','',NULL,'2.0.5'),
	('filter-map-module','eric','core/2016-06-13-filter-map-module.groovy','2017-05-03 10:25:18',167,'EXECUTED','3:1224eddd6cc48135fc5abdb50c3d6d47','Insert Row','',NULL,'2.0.5'),
	('format-number-module-1','eric','core/2016-09-12-format-number-module.groovy','2017-05-03 10:25:24',210,'EXECUTED','3:87029b55db0fc6d5491151bd31ee7945','Insert Row','',NULL,'2.0.5'),
	('list-modules-1','eric','core/2016-08-22-list-modules.groovy','2017-05-03 10:25:20',182,'EXECUTED','3:5d55f2d08d0ac67fa0c46e82a66c0a2f','Insert Row','',NULL,'2.0.5'),
	('list-modules-2','eric','core/2016-08-22-list-modules.groovy','2017-05-03 10:25:21',183,'EXECUTED','3:0f492aca82f6f87686449cbe5411683e','Insert Row','',NULL,'2.0.5'),
	('map-modules-1','eric','core/2016-03-02-map-modules.groovy','2017-05-03 10:25:03',117,'EXECUTED','3:aa574c84f96def38308b81d8d88b4e33','Insert Row (x4)','',NULL,'2.0.5'),
	('map-modules-2-test','eric','core/2016-03-02-map-modules.groovy','2017-05-03 10:25:04',118,'EXECUTED','3:dba302cb8cf53f54bd3cd10eff390f18','Insert Row','',NULL,'2.0.5'),
	('map-modules-3','eric','core/2016-03-24-map-modules-3.groovy','2017-05-03 10:25:05',123,'EXECUTED','3:08f4afc549f0a29a555bf5570c13b9ab','Insert Row (x2)','',NULL,'2.0.5'),
	('migrate-stream-api-keys-to-key-domain-1','eric','core/2017-03-22-migrate-stream-api-keys-to-key-domain.groovy','2017-05-03 10:25:34',238,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('migrate-stream-api-keys-to-key-domain-2','eric','core/2017-03-22-migrate-stream-api-keys-to-key-domain.groovy','2017-05-03 10:25:35',239,'EXECUTED','3:96c08fb87eb22b3a32af303fff3e9813','Drop Column','',NULL,'2.0.5'),
	('migrate-user-api-keys-to-key-domain-1','eric','core/2017-03-23-migrate-user-api-keys-to-key-domain.groovy','2017-05-03 10:25:35',240,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('migrate-user-api-keys-to-key-domain-2','eric','core/2017-03-23-migrate-user-api-keys-to-key-domain.groovy','2017-05-03 10:25:36',241,'EXECUTED','3:6e334b645dc6da098f3212c7c554004e','Drop Index','',NULL,'2.0.5'),
	('migrate-user-api-keys-to-key-domain-3','eric','core/2017-03-23-migrate-user-api-keys-to-key-domain.groovy','2017-05-03 10:25:36',242,'EXECUTED','3:081980ecb93697871206484250d37ff4','Drop Column','',NULL,'2.0.5'),
	('mongodb-feed-1','eric','core/2016-02-02-mongodb-feed.groovy','2017-05-03 10:24:52',96,'EXECUTED','3:cd41ab873ec5fae76e2748afb4282547','Add Column','',NULL,'2.0.5'),
	('mongodb-feed-2','eric','core/2016-02-02-mongodb-feed.groovy','2017-05-03 10:24:53',97,'EXECUTED','3:0396b36262e833e1c3f16b572513afc8','Add Column','',NULL,'2.0.5'),
	('mongodb-feed-3','eric','core/2016-02-02-mongodb-feed.groovy','2017-05-03 10:24:53',98,'EXECUTED','3:fef79c7e52d47838d76071a643465191','Add Column','',NULL,'2.0.5'),
	('mongodb-feed-4','eric','core/2016-02-02-mongodb-feed.groovy','2017-05-03 10:24:54',99,'EXECUTED','3:d902753405c3edfb403eca825379ded4','Custom SQL','',NULL,'2.0.5'),
	('mongodb-feed-5','henri','core/2016-02-02-mongodb-feed.groovy','2017-05-03 10:24:54',100,'EXECUTED','3:55683dd6f28b226e79d84e6fb900ad87','Custom SQL (x2)','',NULL,'2.0.5'),
	('mongodb-feed-6-test','eric','core/2016-02-02-mongodb-feed.groovy','2017-05-03 10:24:54',101,'EXECUTED','3:7b91ead5b19a5eae330a8ed016b731a2','Custom SQL','',NULL,'2.0.5'),
	('moving-window-module','eric','core/2016-12-08-moving-window-module.groovy','2017-05-03 10:25:24',212,'EXECUTED','3:3ea4cfda7cae74c9b75617015869728f','Insert Row','',NULL,'2.0.5'),
	('new-data-pipeline-1','henri','core/2016-09-29-new-data-pipeline.groovy','2017-05-03 10:25:25',216,'EXECUTED','3:daeff1794a3e3623d1d642628e93fffc','Custom SQL','',NULL,'2.0.5'),
	('new-data-pipeline-test','henri','core/2016-09-29-new-data-pipeline.groovy','2017-05-03 10:25:25',218,'EXECUTED','3:090cbac82a73c429e60b7e13c85d3f75','Custom SQL (x2)','',NULL,'2.0.5'),
	('new-event-table-module-1','eric','core/2016-06-15-new-event-table-module.groovy','2017-05-03 10:25:19',175,'EXECUTED','3:4d6b90758e7ee4586dd521de23dc35cb','Custom SQL','',NULL,'2.0.5'),
	('new-event-table-module-2','eric','core/2016-06-15-new-event-table-module.groovy','2017-05-03 10:25:19',176,'EXECUTED','3:2d42727754dd4ff4190efd60c83ae473','Insert Row','',NULL,'2.0.5'),
	('new-moving-average-module-1','eric','core/2016-06-10-new-moving-average-module.groovy','2017-05-03 10:25:18',163,'EXECUTED','3:0bb4f8b1864bd967a7fa4d76bae1864f','Custom SQL','',NULL,'2.0.5'),
	('new-moving-average-module-2','eric','core/2016-06-10-new-moving-average-module.groovy','2017-05-03 10:25:18',164,'EXECUTED','3:610c887b564db4626f6e19259abc3c2f','Insert Row','',NULL,'2.0.5'),
	('new-variadic-modules-1','eric','core/2016-06-08-new-variadic-modules.groovy','2017-05-03 10:25:17',160,'EXECUTED','3:30ded32d2f889fd23051cd9d58c823f1','Custom SQL (x4)','',NULL,'2.0.5'),
	('new-variadic-modules-2','eric','core/2016-06-08-new-variadic-modules.groovy','2017-05-03 10:25:18',161,'EXECUTED','3:32a65739ff7bb9bb0d75b9e52f17b0d4','Insert Row (x4)','',NULL,'2.0.5'),
	('random-modules','eric','core/2016-03-21-random-modules.groovy','2017-05-03 10:25:24',211,'EXECUTED','3:0bcb058804def769f9612e09efae6d78','Insert Row (x5)','',NULL,'2.0.5'),
	('random-modules','eric','core/2016-03-22-fix-input-modules-json-help.groovy','2017-05-03 10:25:04',119,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('separate-serialization-domain-class-1','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:29',225,'EXECUTED','3:6e181ed64eb95e5e3ff0bc03abec7d2b','Create Table','',NULL,'2.0.5'),
	('separate-serialization-domain-class-2','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:29',226,'EXECUTED','3:9a7bb03058607acba53a9006d4a68848','Add Column','',NULL,'2.0.5'),
	('separate-serialization-domain-class-3','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:29',227,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('separate-serialization-domain-class-4','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:30',228,'EXECUTED','3:c7f17135b575be0287f76c9428fae076','Create Index','',NULL,'2.0.5'),
	('separate-serialization-domain-class-5','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:30',229,'EXECUTED','3:dbdc27b5f4958a21eb5682ac016b1c74','Create Index','',NULL,'2.0.5'),
	('separate-serialization-domain-class-6','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:30',230,'EXECUTED','3:c07135041eeaca569781c175a14e5eae','Drop Column','',NULL,'2.0.5'),
	('separate-serialization-domain-class-7','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:31',231,'EXECUTED','3:dacf9d9992734e2857965519e445da56','Drop Column','',NULL,'2.0.5'),
	('separate-serialization-domain-class-8','eric','core/2017-01-20-separate-serialization-domain-class.groovy','2017-05-03 10:25:32',232,'EXECUTED','3:a03d902e8c1a55ed895827d12445de75','Add Foreign Key Constraint','',NULL,'2.0.5'),
	('serialized-feed-to-blob-1','eric','core/2016-03-07-serialized-field-to-blob.groovy','2017-05-03 10:25:04',120,'EXECUTED','3:6f359fb9a61af8e84d0863e5a573eb8a','Custom SQL, Modify data type','',NULL,'2.0.5'),
	('serialized-feed-to-blob-1','eric','core/2016-03-08-map-modules-2.groovy','2017-05-03 10:25:05',122,'EXECUTED','3:c55244d1cb12a95a854d4edc261ca8c4','Insert Row (x13)','',NULL,'2.0.5'),
	('serialized-feed-to-blob-2','eric','core/2016-03-07-serialized-field-to-blob.groovy','2017-05-03 10:25:04',121,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('tester2-testing-dashboard','aapeli','core/2016-06-07-test-dashboard.groovy','2017-05-03 10:25:17',159,'EXECUTED','3:f1d2b5ac26d237fc15c095b5fd852e01','Insert Row (x6)','',NULL,'2.0.5'),
	('time-of-event-module','eric','core/2016-09-07-time-of-event-module.groovy','2017-05-03 10:25:21',188,'EXECUTED','3:028f50d8d8b3f7ca567a7fbdb71823ad','Insert Row','',NULL,'2.0.5'),
	('tour-resources-1','henri','core/2016-04-06-tours.groovy','2017-05-03 10:25:19',169,'EXECUTED','3:c31ab3aa91c017799bb9b50f4bef36d2','Grails Change','',NULL,'2.0.5'),
	('tour-resources-2','henri','core/2016-04-06-tours.groovy','2017-05-03 10:25:19',170,'EXECUTED','3:7cf8eb7e1f9f6d8af8c28d35aea13f9a','Insert Row','',NULL,'2.0.5'),
	('tour-resources-3','henri','core/2016-04-06-tours.groovy','2017-05-03 10:25:19',171,'EXECUTED','3:211a15c45cacd31b4e3ebfe0a10ddafe','Insert Row','',NULL,'2.0.5'),
	('tour-resources-4','henri','core/2016-04-06-tours.groovy','2017-05-03 10:25:19',172,'EXECUTED','3:1b60f1604b7a7cb7dfb1b88cd47b8bd5','Insert Row (x4)','',NULL,'2.0.5'),
	('tour-resources-5','henri','core/2016-04-06-tours.groovy','2017-05-03 10:25:19',173,'EXECUTED','3:3f5d4c3f99b4f6353707f55f8031630b','Update Data (x2)','',NULL,'2.0.5'),
	('tours-completed','henri','core/2016-04-06-tours.groovy','2017-05-03 10:25:19',174,'EXECUTED','3:4a75c2608b4c4bb1c5a9ae57b571f152','Insert Row (x9)','',NULL,'2.0.5'),
	('update-stream-dates-to-current-if-missing','aapeli','core/2016-05-09-stream-date-created-and-last-updated.groovy','2017-05-03 10:25:17',156,'EXECUTED','3:7a9111d1bf8db0a42eeab0f490355cea','Custom SQL','',NULL,'2.0.5'),
	('update-test-resources-1','aapeli','core/2016-06-13-update-test-resources.groovy','2017-05-03 10:25:18',165,'EXECUTED','3:9912d28b7467efb4700cd45df4f7ba49','Custom SQL','',NULL,'2.0.5'),
	('update-test-resources-2','henri','core/2016-06-13-update-test-resources.groovy','2017-05-03 10:25:18',166,'EXECUTED','3:746f22a5eb381c00756c64d617050af8','Custom SQL','',NULL,'2.0.5'),
	('useful-list-modules-1','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',192,'EXECUTED','3:a6899393bf081302703c0d233684671f','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-10','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',200,'EXECUTED','3:252e273e956297108fac4affd42a7fc1','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-11','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',201,'EXECUTED','3:3d9660ab55b0d872e3b9a55b82126e1a','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-12','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',202,'EXECUTED','3:aa61e76c554b8214c9beeb64d238caff','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-13','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',203,'EXECUTED','3:2b47caf065b95817feb9525311c1a267','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-14','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',204,'EXECUTED','3:ee764fa18af96d015dc9576b3aa82f64','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-15','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',205,'EXECUTED','3:bdb01b42b0d98384fc3ccde868bec403','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-16','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',206,'EXECUTED','3:fd7f89bb126031dd4314faa32cdb065c','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-17','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:24',207,'EXECUTED','3:2cdace4a46c4c34b2535b8cde733ab2b','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-18','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:24',208,'EXECUTED','3:14a549bfadd142948e2a6fbc855306ce','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-2','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',193,'EXECUTED','3:9ff8e784f81bd9817664bd6378edbfa3','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-3','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',194,'EXECUTED','3:70f486c052d3f586b39b1f29b6632a38','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-5','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',195,'EXECUTED','3:6a06cabd7c1dec259a1e51887aecb305','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-6','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',196,'EXECUTED','3:7b76416f9a1ae9c26ea54d11693b301e','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-7','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',197,'EXECUTED','3:177533b765d716b0a854c497da3e66e9','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-8','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:22',198,'EXECUTED','3:abba14744ac34b3f03121e98ed9ee1cb','Insert Row','',NULL,'2.0.5'),
	('useful-list-modules-9','eric','core/2016-08-29-useful-list-modules.groovy','2017-05-03 10:25:23',199,'EXECUTED','3:1a3f8547a9dac4430c3553f3c0727bb7','Insert Row','',NULL,'2.0.5'),
	('xor-module','eric','core/2017-01-17-xor-module.groovy','2017-05-03 10:25:25',215,'EXECUTED','3:15f65ee360d696cd2d05229f287f00a0','Insert Row','',NULL,'2.0.5');

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
  `stream_listener_class` varchar(255) NOT NULL,
  `stream_page_template` varchar(255) NOT NULL,
  `field_detector_class` varchar(255) DEFAULT NULL,
  `data_range_provider_class` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK2FE59EB6140F06` (`module_id`),
  CONSTRAINT `FK2FE59EB6140F06` FOREIGN KEY (`module_id`) REFERENCES `module` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `feed` WRITE;
/*!40000 ALTER TABLE `feed` DISABLE KEYS */;

INSERT INTO `feed` (`id`, `version`, `backtest_feed`, `bundled_feed_files`, `cache_class`, `cache_config`, `directory`, `discovery_util_class`, `discovery_util_config`, `event_recipient_class`, `feed_config`, `key_provider_class`, `message_source_class`, `message_source_config`, `module_id`, `name`, `parser_class`, `preprocessor`, `realtime_feed`, `start_on_demand`, `timezone`, `stream_listener_class`, `stream_page_template`, `field_detector_class`, `data_range_provider_class`)
VALUES
	(7,0,'com.unifina.feed.cassandra.CassandraHistoricalFeed',NULL,NULL,NULL,'core_test_streams',NULL,'{\r\n  \"pattern\": \".gz$\",\r\n  \"prefix\": \"user_stream\"\r\n}','com.unifina.feed.map.MapMessageEventRecipient','{ \"directory\": \"core_test_streams\" }','com.unifina.feed.StreamrBinaryMessageKeyProvider','com.unifina.feed.redis.MultipleRedisMessageSource',NULL,147,'API','com.unifina.feed.StreamrBinaryMessageParser','com.unifina.feed.NoOpFeedPreprocessor','com.unifina.feed.redis.RedisFeed',b'1','UTC','com.unifina.feed.cassandra.CassandraDeletingStreamListener','userStreamDetails','com.unifina.feed.cassandra.CassandraFieldDetector','com.unifina.feed.cassandra.CassandraDataRangeProvider'),
	(8,0,'com.unifina.feed.mongodb.MongoHistoricalFeed',NULL,NULL,NULL,NULL,NULL,NULL,'com.unifina.feed.map.MapMessageEventRecipient',NULL,'com.unifina.feed.mongodb.MongoKeyProvider','com.unifina.feed.mongodb.MongoMessageSource',NULL,147,'MongoDB','com.unifina.feed.NoOpMessageParser',NULL,'com.unifina.feed.mongodb.MongoFeed',b'1','UTC','com.unifina.feed.mongodb.MongoStreamListener','mongoStreamDetails','com.unifina.feed.mongodb.MongoFieldDetector','com.unifina.feed.mongodb.MongoDataRangeProvider'),
	(9,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'com.unifina.feed.twitter.TwitterEventRecipient',NULL,'com.unifina.feed.twitter.TwitterKeyProvider','com.unifina.feed.twitter.TwitterMessageSource',NULL,159,'Twitter','com.unifina.feed.twitter.TwitterMessageParser',NULL,'com.unifina.feed.twitter.TwitterFeed',b'1','UTC','com.unifina.feed.twitter.TwitterStreamListener','twitterStreamDetails',NULL,NULL);

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
  `stream_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK9DFF9B7D72507A49` (`feed_id`),
  KEY `stream_idx` (`stream_id`),
  CONSTRAINT `FK9DFF7A2F49034A50` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`id`),
  CONSTRAINT `FK9DFF9B7D72507A49` FOREIGN KEY (`feed_id`) REFERENCES `feed` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `feed_file` WRITE;
/*!40000 ALTER TABLE `feed_file` DISABLE KEYS */;

INSERT INTO `feed_file` (`id`, `begin_date`, `day`, `end_date`, `feed_id`, `format`, `name`, `process_task_created`, `processed`, `processing`, `stream_id`)
VALUES
	(1,'2015-02-23 00:00:00','2015-02-23 00:00:00','2015-02-23 21:58:30',7,NULL,'kafka.20150223.1.gz',b'0',b'1',b'0','c1_fiG6PTxmtnCYGU-mKuQ'),
	(2,'2015-02-24 00:00:00','2015-02-24 00:00:00','2015-02-25 21:59:40',7,NULL,'kafka.20150224.1.gz',b'0',b'1',b'0','c1_fiG6PTxmtnCYGU-mKuQ'),
	(3,'2015-02-25 00:00:00','2015-02-25 00:00:00','2015-02-26 21:59:14',7,NULL,'kafka.20150225.1.gz',b'0',b'1',b'0','c1_fiG6PTxmtnCYGU-mKuQ'),
	(4,'2015-02-26 00:00:00','2015-02-26 00:00:00','2015-02-27 21:59:42',7,NULL,'kafka.20150226.1.gz',b'0',b'1',b'0','c1_fiG6PTxmtnCYGU-mKuQ'),
	(5,'2015-02-27 00:00:00','2015-02-27 00:00:00','2015-02-27 22:49:59',7,NULL,'kafka.20150227.1.gz',b'0',b'1',b'0','c1_fiG6PTxmtnCYGU-mKuQ'),
	(6,'2016-04-11 00:00:00','2016-04-11 00:00:00','2016-04-11 23:59:59',7,NULL,'kafka.20160411.YpTAPDbvSAmj-iCUYz-dxA.gz',b'0',b'1',b'0','YpTAPDbvSAmj-iCUYz-dxA'),
	(7,'2016-04-12 00:00:00','2016-04-12 00:00:00','2016-04-12 23:59:59',7,NULL,'kafka.20160412.YpTAPDbvSAmj-iCUYz-dxA.gz',b'0',b'1',b'0','YpTAPDbvSAmj-iCUYz-dxA');

/*!40000 ALTER TABLE `feed_file` ENABLE KEYS */;
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



# Dump of table key
# ------------------------------------------------------------

DROP TABLE IF EXISTS `key`;

CREATE TABLE `key` (
  `id` varchar(255) NOT NULL,
  `version` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK19E5F60701D32` (`user_id`),
  CONSTRAINT `FK19E5F60701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `key` WRITE;
/*!40000 ALTER TABLE `key` DISABLE KEYS */;

INSERT INTO `key` (`id`, `version`, `name`, `user_id`)
VALUES
	('Byy0BTVCRcyWkYg0xKSf4Q',0,'Generated',NULL),
	('fAjduBGSTlCW31eXPXUe0A',0,'Generated',NULL),
	('K4FqWBmzTCmXbuCpR-h_YA',0,'Generated',NULL),
	('lpiZh47ySUus4B0TZ18zcw',0,'Generated',NULL),
	('m3CoiiUNQlami6NE8zucTw',0,'Generated',NULL),
	('mapmodulesspeckey-api-key',0,'Generated',NULL),
	('RYZ2idC0RZ2mGyRJARiBaQ',0,'Generated',NULL),
	('share-spec--stream-key',0,'Generated',NULL),
	('TaPRLN84RXqh8HXuFjQDLg',0,'Generated',NULL),
	('tester-admin-api-key',0,'Default',3),
	('tester1-api-key',0,'Default',1),
	('tester2-api-key',0,'Default',2),
	('vtgidzpWSOOrw4iZ7tesnA',0,'Generated',NULL),
	('XE_NoXVUTp-b5EIJY_lYHQ',0,'Generated',NULL);

/*!40000 ALTER TABLE `key` ENABLE KEYS */;
UNLOCK TABLES;


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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `module` WRITE;
/*!40000 ALTER TABLE `module` DISABLE KEYS */;

INSERT INTO `module` (`id`, `version`, `category_id`, `implementing_class`, `name`, `js_module`, `hide`, `type`, `module_package_id`, `json_help`, `alternative_names`, `webcomponent`)
VALUES
	(1,4,1,'com.unifina.signalpath.simplemath.Multiply','Multiply','GenericModule',NULL,'module',1,'{\"outputNames\":[\"A*B\"],\"inputs\":{\"A\":\"The first value to be multiplied\",\"B\":\"The second value to be multiplied\"},\"helpText\":\"<p>This module calculates the product of two numeric input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A*B\":\"The product of the inputs\"},\"paramNames\":[]}','Times',NULL),
	(2,4,2,'com.unifina.signalpath.filtering.SimpleMovingAverageEvents','MovingAverage (old)','GenericModule',b'1','module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module calculates the simple moving average (MA, SMA) of values arriving at the input. Each value is assigned equal weight. The moving average is calculated based on a sliding window of adjustable length.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of input values received before a value is output\",\"length\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\"},\"outputs\":{\"out\":\"The moving average\"},\"paramNames\":[\"length\",\"minSamples\"]}','SMA',NULL),
	(3,7,1,'com.unifina.signalpath.simplemath.Add','Add','GenericModule',b'1','module',5,'{\"outputNames\":[\"A+B\"],\"inputs\":{\"A\":\"First value to be added\",\"B\":\"Second value to be added\"},\"helpText\":\"<p>This module adds together two numeric input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A+B\":\"Sum of the two inputs\"},\"paramNames\":[]}','Plus',NULL),
	(4,4,1,'com.unifina.signalpath.simplemath.Subtract','Subtract','GenericModule',NULL,'module',1,'{\"outputNames\":[\"A-B\"],\"inputs\":{\"A\":\"Value to subtract from\",\"B\":\"Value to be subtracted\"},\"helpText\":\"<p>This module calculates the difference of its two input values.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A-B\":\"The difference\"},\"paramNames\":[]}','Minus',NULL),
	(5,5,3,'com.unifina.signalpath.utils.Constant','Constant','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>This module represents a constant numeric value that can be connected to any numeric input. The input will have that value during the whole execution.</p>\",\"inputNames\":[],\"params\":{\"constant\":\"The value to output\"},\"outputs\":{\"out\":\"The value of the parameter\"},\"paramNames\":[\"constant\"]}','Number',NULL),
	(6,5,1,'com.unifina.signalpath.simplemath.Divide','Divide','GenericModule',NULL,'module',1,'{\"outputNames\":[\"A/B\"],\"inputs\":{\"A\":\"The dividend, or numerator\",\"B\":\"The divisor, or denominator\"},\"helpText\":\"<p>This module calculates the quotient of its two input values. If the input <span class=\'highlight\'>B</span> is zero, the result is not defined and thus no output is produced.</p>\",\"inputNames\":[\"A\",\"B\"],\"params\":{},\"outputs\":{\"A/B\":\"The quotient: A divided by B\"},\"paramNames\":[]}',NULL,NULL),
	(7,7,19,'com.unifina.signalpath.utils.Delay','Delay','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Incoming values to be delayed\"},\"helpText\":\"<p>This module will delay the received values by a number of events. For example, if the <span class=\'highlight\'> delayEvents</span> parameter is set to 1, the module will always output the previous value received.\\n</p><p>\\nThe module will not produce output until the <span class=\'highlight\'>delayEvents+1</span>th event, at which point the first received value will be output. For example, if the parameter is set to 2, the following sequence would be produced:\\n</p><p>\\n<table>\\n<tr><th>Input<\\/th><th>Output<\\/th><\\/tr>\\n<tr><td>1<\\/td><td>(no value)<\\/td><\\/tr>\\n<tr><td>2<\\/td><td>(no value)<\\/td><\\/tr>\\n<tr><td>3<\\/td><td>1<\\/td><\\/tr>\\n<tr><td>4<\\/td><td>2<\\/td><\\/tr>\\n<tr><td>...<\\/td><td>...<\\/td><\\/tr>\\n<\\/table></p>\",\"inputNames\":[\"in\"],\"params\":{\"delayEvents\":\"Number of events to delay the incoming values\"},\"outputs\":{\"out\":\"The delayed values\"},\"paramNames\":[\"delayEvents\"]}',NULL,NULL),
	(11,6,1,'com.unifina.signalpath.simplemath.ChangeAbsolute','ChangeAbsolute','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>Outputs the difference between the received value and the previous received value, or <span class=\'highlight\'>in(t)&nbsp;-&nbsp;in(t-1)</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}','Difference',NULL),
	(16,6,19,'com.unifina.signalpath.utils.Barify','Barify','GenericModule',NULL,'module',1,'{\"outputNames\":[\"open\",\"high\",\"low\",\"close\",\"avg\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This is a utility for moving from event time to wall-clock time. This module outputs new values every <span class=\'highlight\'>barLength</span> seconds. You would use this module to sample a time series every 60 seconds, for example.</p>\",\"inputNames\":[\"in\"],\"params\":{\"barLength\":\"Length of the bar (time interval) in seconds\"},\"outputs\":{\"open\":\"Value at start of period\",\"high\":\"Maximum value during period\",\"avg\":\"Simple average of values received during the period\",\"low\":\"Minimum value during period\",\"close\":\"Value at end of period (the most recent value)\"},\"paramNames\":[\"barLength\"]}','Time',NULL),
	(19,4,27,'com.unifina.signalpath.text.ConstantString','ConstantText','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{},\"helpText\":\"<p>This module represents a constant text value that can be connected to any input that accepts text.</p>\",\"inputNames\":[],\"params\":{\"str\":\"The text constant\"},\"outputs\":{\"out\":\"Outputs the text constant\"},\"paramNames\":[\"str\"]}','TextConstant, ConstantString, StringConstant, String',NULL),
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
	(81,5,3,'com.unifina.signalpath.SignalPath','Canvas','CanvasModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to reuse a Canvas saved into the Archive as a module in your current Canvas. This enables reuse and abstraction of functionality and helps keep your Canvases tidy and modular.\\n</p><p>\\nAny parameters, inputs or outputs you export will be visible on the module. You can export endpoints by right-clicking on them and selecting \\\"Toggle export\\\".</p>\"}','Saved, Module',NULL),
	(84,4,7,'com.unifina.signalpath.trigger.FourZones','FourZones','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module waits for the input signal to reach either the <span class=\'highlight\'>highTrigger</span> or <span class=\'highlight\'>lowTrigger</span> level. Either 1 or -1 is output respectively. The triggered value is kept until it is set back to 0 at the corresponding release level.\\n</p><p>\\nIf you set <span class=\'highlight\'>mode</span> to <span class=\'highlight\'>exit</span>, the output will trigger when exiting the trigger level instead of entering it.</p>\",\"inputNames\":[\"in\"],\"params\":{\"lowRelease\":\"Low release level\",\"highTrigger\":\"High trigger level\",\"lowTrigger\":\"Low trigger level\",\"highRelease\":\"High release level\",\"mode\":\"Trigger on entering/exiting the high/low trigger level\"},\"outputs\":{\"out\":\"1 on high trigger, -1 on low trigger, 0 on release\"},\"paramNames\":[\"mode\",\"highTrigger\",\"highRelease\",\"lowRelease\",\"lowTrigger\"]}',NULL,NULL),
	(85,4,7,'com.unifina.signalpath.trigger.Sampler','Sampler','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module can be used to sample values from one timeseries upon events from another timeseries.\\n</p><p>\\nAn event arriving at the <span class=\'highlight\'>trigger</span> input will cause the module to send out whatever value the <span class=\'highlight\'>value</span> input has. The <span class=\'highlight\'>trigger</span> is the only <span class=\'highlight\'>driving input</span>.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(87,6,1,'com.unifina.signalpath.simplemath.ChangeLogarithmic','ChangeLogarithmic','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Outputs the logarithmic difference (log return) between the received value and the previous received value, or <span class=\\\"highlight\\\">log[in(t)]&nbsp;-&nbsp;log[in(t-1)]</span>.</p>\\n\"}',NULL,NULL),
	(90,4,19,'com.unifina.signalpath.utils.PassThrough','PassThrough (old)','GenericModule',b'1','module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module just sends out whatever it receives.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(96,9,2,'com.unifina.signalpath.filtering.ExponentialMovingAverage','MovingAverageExp','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Smooths the incoming time series by calculating an exponential moving average (EMA)</p>\\n\\n<ul>\\n\\t<li><span class=\\\"formula\\\">EMA(t) = a x&nbsp;<strong>in</strong>(t) + (1-a) x&nbsp;EMA(t-1)</span></li>\\n\\t<li><span class=\\\"formula\\\">a = <span class=\\\"math-tex\\\">\\\\(2 \\\\over \\\\text{length} + 1\\\\)</span></span></li>\\n</ul>\\n\"}','EMA',NULL),
	(98,5,11,'com.unifina.signalpath.modeling.ARIMA','ARIMA','GenericModule',NULL,'module',1,'{\"outputNames\":[\"pred\"],\"inputs\":{\"in\":\"Incoming time series\"},\"helpText\":\"<p>Evaluates an ARIMA prediction model with given parameters. Check the module options to set the number of autoregressive and moving average parameters. Model fitting is not (yet) implemented.</p>\",\"inputNames\":[\"in\"],\"params\":{},\"outputs\":{\"pred\":\"ARIMA prediction\"},\"paramNames\":[]}',NULL,NULL),
	(100,5,1,'com.unifina.signalpath.simplemath.AddMulti','Add (old)','GenericModule',b'1','module',1,'{\"outputNames\":[\"sum\"],\"inputs\":{},\"helpText\":\"<p>Adds together two or more numeric input values. The number of inputs can be adjusted in module options.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{\"sum\":\"Sum of inputs\"},\"paramNames\":[]}','Plus',NULL),
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
	(142,8,3,'com.unifina.signalpath.utils.EventTable','Table (old)','TableModule',b'1','module event-table-module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Displays a table of events arriving at the inputs along with their timestamps. The number of inputs can be adjusted in module options. Every input corresponds to a table column. Very useful for debugging and inspecting values. The inputs can be connected to all types of outputs.</p>\"}','Events','streamr-table'),
	(145,0,3,'com.unifina.signalpath.utils.Label','Label','LabelModule',NULL,'module dashboard',1,'',NULL,'streamr-label'),
	(147,0,25,'com.unifina.signalpath.utils.ConfigurableStreamModule','Stream','StreamModule',b'1','module',1,'',NULL,NULL),
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
	(181,1,3,'com.unifina.signalpath.utils.Filter','Filter (old)','GenericModule',b'1','module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"pass\":\"The filter condition. 1 (true) for letting the event pass, 0 (false) to filter it out\",\"in\":\"The incoming event (any type)\"},\"inputNames\":[\"pass\",\"in\"],\"outputs\":{\"out\":\"The event that came in, if passed. If filtered, nothing is sent\"},\"outputNames\":[\"out\"],\"helpText\":\"Only lets the incoming value through if the value at <span class=\'highlight\'>pass</span> is 1. If this condition is not met, no event is sent out.\"}','Select, Pick, Choose',NULL),
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
	(209,5,28,'com.unifina.signalpath.time.ClockModule','Clock','GenericModule',NULL,'module',1,'{\"params\":{\"format\":\"Format of the string date\",\"rate\":\"the rate of the interval\",\"unit\":\"the unit of the interval\"},\"paramNames\":[\"format\",\"rate\",\"unit\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"date\":\"String notation of the time and date\",\"timestamp\":\"unix timestamp\"},\"outputNames\":[\"date\",\"timestamp\"],\"helpText\":\"<p>Tells the time and date at fixed time intervals (by default every second). Outputs the time either in string notation of given format or as a timestamp (milliseconds from 1970-01-01 00:00:00.000).</p>\n\n<p>The time interval can be chosen with parameter&nbsp;<em>unit&nbsp;</em>and&nbsp;granularly controlled via parameter&nbsp;<em>rate</em>. For example,&nbsp;<em>unit=minute&nbsp;</em>and&nbsp;<em>rate=2</em>&nbsp;will tell the time every other minute.</p>\"}',NULL,NULL),
	(210,1,28,'com.unifina.signalpath.time.TimeBetweenEvents','TimeBetweenEvents','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"Any type event\"},\"inputNames\":[\"in\"],\"outputs\":{\"ms\":\"Time in milliseconds\"},\"outputNames\":[\"ms\"],\"helpText\":\"<p>Tells the time between two consecutive events in milliseconds.</p>\\n\"}',NULL,NULL),
	(211,3,28,'com.unifina.signalpath.time.DateConversion','DateConversion','GenericModule',NULL,'module',1,'{\"params\":{\"timezone\":\"Timezone of the outputs\",\"format\":\"Format of the input and output string notations\"},\"paramNames\":[\"timezone\",\"format\"],\"inputs\":{\"date\":\"Timestamp, string or Date\"},\"inputNames\":[\"date\"],\"outputs\":{\"date\":\"String notation\",\"ts\":\"Timestamp(ms)\",\"dayOfWeek\":\"In shortened form, e.g. \\\"Mon\\\"\"},\"outputNames\":[\"date\",\"ts\",\"dayOfWeek\"],\"helpText\":\"<p>Takes a date as an input in either in <a href=\\\"https://docs.oracle.com/javase/8/docs/api/java/util/Date.html\\\" target=\\\"_blank\\\">Date</a> object, timestamp(ms) or in string notation. If the input is in text form, is the given format used.</p>\\n\\n<p>Example:</p>\\n\\n<p>Parameters:</p>\\n\\n<ul>\\n\\t<li>Format &lt;- &quot;yyyy-MM-dd HH:mm:ss&quot;</li>\\n\\t<li>Timezone &lt;- Europe/Helsinki</li>\\n</ul>\\n\\n<p><br />\\nInputs:</p>\\n\\n<ul>\\n\\t<li>Date in &lt;- &quot;2015-07-15&nbsp;13:06:13&quot; or&nbsp;1436954773474</li>\\n</ul>\\n\\n<p>Outputs:&nbsp;</p>\\n\\n<ul>\\n\\t<li>Date out -&gt;&nbsp;2015-07-15&nbsp;13:06:13</li>\\n\\t<li>ts -&gt;&nbsp;1436954773474</li>\\n\\t<li>dayOfWeek -&gt; &quot;Wed&quot;</li>\\n\\t<li>years -&gt; 2015</li>\\n\\t<li>months -&gt; 7</li>\\n\\t<li>days -&gt; 15</li>\\n\\t<li>hours -&gt; 13</li>\\n\\t<li>minutes -&gt; 6</li>\\n\\t<li>seconds -&gt; 13</li>\\n\\t<li>milliseconds -&gt; 0</li>\\n</ul>\\n\"}',NULL,NULL),
	(213,1,1,'com.unifina.signalpath.simplemath.Modulo','Modulo','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Calculates the remainder of two values. Outputs ( divisor mod divider).</p>\\n\\n<p>E.g.</p>\\n\\n<ul>\\n\\t<li>3 mod 2 = 1</li>\\n</ul>\\n\"}',NULL,NULL),
	(214,1,13,'com.unifina.signalpath.charts.MapModule','Map','MapModule',NULL,'module',1,NULL,NULL,'streamr-map'),
	(215,1,50,'com.unifina.signalpath.color.ColorConstant','ConstantColor','GenericModule',NULL,'module',1,NULL,'ColorConstant, Color',NULL),
	(216,1,50,'com.unifina.signalpath.color.Gradient','Gradient','GenericModule',NULL,'module',1,NULL,NULL,NULL),
	(217,2,3,'com.unifina.signalpath.utils.RateLimit','RateLimit','GenericModule',NULL,'module',1,'{\"params\":{\"rate\":\"How many messages are let through in given time\",\"timeInMillis\":\"The time in milliseconds, in which the given number of messages are let through\"},\"paramNames\":[\"rate\",\"timeInMillis\"],\"inputs\":{\"in\":\"Input\"},\"inputNames\":[\"in\"],\"outputs\":{\"limitExceeded?\":\"Outputs 1 if the message was blocked and 0 if it wasn\'t\",\"out\":\"Outputs the input value if it wasn\'t blocked\"},\"outputNames\":[\"limitExceeded?\",\"out\"],\"helpText\":\"<p>The RateLimit module lets through n messages in t milliseconds. Then module just blocks the rest which do not fit in the window.</p>\\n\"}',NULL,NULL),
	(218,2,100,'com.unifina.signalpath.input.ButtonModule','Button','InputModule',NULL,'module',1,'{\"params\":{\"buttonName\":\"The name which the button gets\",\"outputValue\":\"Value which is outputted when the button is clicked\"},\"paramNames\":[\"buttonName\",\"outputValue\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The button module outputs the given value everytime the button is pressed. Module can be used any time, even during a run.</p>\"}',NULL,'streamr-button'),
	(219,2,100,'com.unifina.signalpath.input.SwitcherModule','Switcher','InputModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The module ouputs even 1 or 0 depending of the value of the switcher. The value can be changed during a run.</p>\"}',NULL,'streamr-switcher'),
	(220,3,100,'com.unifina.signalpath.input.TextFieldModule','TextField','InputModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>The module outputs the value of the text field every time &#39;send&#39; is pressed.</p>\"}',NULL,'streamr-text-field'),
	(221,0,51,'com.unifina.signalpath.map.CountByKey','CountByKey','GenericModule',NULL,'module',1,'{\"params\":{\"sort\":\"Whether key-count pairs should be order by count\",\"maxKeyCount\":\"Maximum number of (sorted) key-count pairs to keep. Everything else will be dropped.\"},\"paramNames\":[\"sort\",\"maxKeyCount\"],\"inputs\":{\"key\":\"The (string) key\"},\"inputNames\":[\"key\"],\"outputs\":{\"map\":\"Key-count pairs\",\"valueOfCurrentKey\":\"The occurrence count of the last key received. \"},\"outputNames\":[\"map\",\"valueOfCurrentKey\"],\"helpText\":\"<p>Keeps count of the occurrences of keys.</p>\"}',NULL,NULL),
	(222,0,51,'com.unifina.signalpath.map.SumByKey','SumByKey','GenericModule',NULL,'module',1,'{\"params\":{\"windowLength\":\"Limit moving window size of sum.\",\"sort\":\"Whether key-sum pairs should be order by sums\",\"maxKeyCount\":\"Maximum number of (sorted) key-sum pairs to keep. Everything else will be dropped.\"},\"paramNames\":[\"windowLength\",\"sort\",\"maxKeyCount\"],\"inputs\":{\"value\":\"The value to be added to aggregated sum.\",\"key\":\"The (string) key\"},\"inputNames\":[\"value\",\"key\"],\"outputs\":{\"map\":\"Key-sum pairs\",\"valueOfCurrentKey\":\"The aggregated sum of the last key received. \"},\"outputNames\":[\"map\",\"valueOfCurrentKey\"],\"helpText\":\"<p>Keeps aggregated sums of received key-value-pairs by key.</p>\"}',NULL,NULL),
	(223,0,51,'com.unifina.signalpath.map.ForEach','ForEach','ForEachModule',NULL,'module',1,'{\"params\":{\"canvas\":\"The \\\"sub\\\" canvas that implements the ForEach-loop \\\"body\\\"\"},\"paramNames\":[\"canvas\"],\"inputs\":{\"key\":\"Differentiate between canvas\"},\"inputNames\":[\"key\"],\"outputs\":{\"map\":\"The state of outputs of all distinct Canvases by key.\"},\"outputNames\":[\"map\"],\"helpText\":\"<p>This module allows you to reuse a Canvas saved into the Archive as a module in your current Canvas.</p><p>A separate Canvas instance will be created for each distinct key, which enables ForEach-like behavior to be implemented. The canvas instances will also retain state as expected.</p><p>Any parameters, inputs or outputs you export will be visible on the module. You can export endpoints by right-clicking on them and selecting \\\"Toggle export\\\".</p>\"}',NULL,NULL),
	(224,0,51,'com.unifina.signalpath.map.ContainsValue','ContainsValue','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\",\"value\":\"a value\"},\"inputNames\":[\"in\",\"value\"],\"outputs\":{\"found\":\"1.0 if found, else 0.0.\"},\"outputNames\":[\"found\"],\"helpText\":\"<p>Determine whether a map contains a value.</p>\"}',NULL,NULL),
	(225,0,51,'com.unifina.signalpath.map.GetFromMap','GetFromMap','GenericModule',NULL,'module',1,'{\"params\":{\"key\":\"a key\"},\"paramNames\":[\"key\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"found\":\"1.0 if key was present in map, 0.0 otherwise.\",\"out\":\"the corresponding value if key was found.\"},\"outputNames\":[\"found\",\"out\"],\"helpText\":\"<p>Retrieve a value from a map by key.</p>\"}',NULL,NULL),
	(226,0,51,'com.unifina.signalpath.map.HeadMap','HeadMap','GenericModule',NULL,'module',1,'{\"params\":{\"limit\":\"the number of entries to fetch\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a submap of the first entries of map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieve&nbsp;first (n=limit)&nbsp;entries of a map.</p>\"}',NULL,NULL),
	(227,0,51,'com.unifina.signalpath.map.KeysToList','KeysToList','GenericModule',NULL,'module',1,'{\"params\":{\"limit\":\"the number of entries to fetch\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a submap of the first entries of map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieve&nbsp;first (n=limit)&nbsp;entries of a map.</p>\"}',NULL,NULL),
	(228,0,51,'com.unifina.signalpath.map.PutToMap','PutToMap','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"key\":\"key to insert\",\"map\":\"a map\",\"value\":\"value to insert\"},\"inputNames\":[\"key\",\"map\",\"value\"],\"outputs\":{\"map\":\"a map with the key-value entry inserted\"},\"outputNames\":[\"map\"],\"helpText\":\"<p>Put a key-value-entry&nbsp;into a map.</p>\"}',NULL,NULL),
	(229,0,51,'com.unifina.signalpath.map.SortMap','SortMap','GenericModule',NULL,'module',1,'{\"params\":{\"byValue\":\"when false (default), sorts by key. when true, sorts by value\"},\"paramNames\":[\"byValue\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a sorted map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Sorts a map.</p>\"}',NULL,NULL),
	(230,0,51,'com.unifina.signalpath.map.TailMap','TailMap','GenericModule',NULL,'module',1,'{\"params\":{\"limit\":\"the number of entries to fetch\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a submap of the last entries of map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieve&nbsp;last (n=limit)&nbsp;entries of a map.</p>\"}',NULL,NULL),
	(231,0,51,'com.unifina.signalpath.map.ValuesToList','ValuesToList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"keys\":\"values as a list\"},\"outputNames\":[\"keys\"],\"helpText\":\"<p>Retrieves the values of a map.</p>\"}',NULL,NULL),
	(232,0,51,'com.unifina.signalpath.map.NewMap','NewMap','GenericModule',NULL,'module',1,'{\"params\":{\"alwaysNew\":\"When false (defult), same map is sent every time. When true, a new map is sent on each activation.\"},\"paramNames\":[\"alwaysNew\"],\"inputs\":{\"trigger\":\"used to activate module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"a map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Emit a map everytime trigger receives a value.</p>\"}',NULL,NULL),
	(233,0,51,'com.unifina.signalpath.map.MergeMap','MergeMap','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"leftMap\":\"a map to merge onto\",\"rightMap\":\"a map to be merged\"},\"inputNames\":[\"leftMap\",\"rightMap\"],\"outputs\":{\"out\":\"the resulting merged map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Merge&nbsp;<strong>rightMap</strong>&nbsp;onto&nbsp;<strong>leftMap</strong>&nbsp;resulting in a single map. In case of conflicting keys,&nbsp;entries of&nbsp;<strong>rightMap</strong>&nbsp;will replace those of <strong>leftMap</strong>.</p>\"}',NULL,NULL),
	(234,0,51,'com.unifina.signalpath.map.RemoveFromMap','RemoveFromMap','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\",\"key\":\"a key\"},\"inputNames\":[\"in\",\"key\"],\"outputs\":{\"out\":\"a map without the removed key\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Remove an entry for a map by key.</p>\"}',NULL,NULL),
	(235,0,51,'com.unifina.signalpath.map.MapSize','MapSize','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"a map\"},\"inputNames\":[\"in\"],\"outputs\":{\"size\":\"the number of entries\"},\"outputNames\":[\"size\"],\"helpText\":\"<p>Determine the number of entries in a map.</p>\"}',NULL,NULL),
	(236,0,3,'com.unifina.signalpath.utils.MapAsTable','MapAsTable','TableModule',NULL,'module event-table-module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"map\":\"a map\"},\"inputNames\":[\"map\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Display the entries of a map as a table.</p>\"}',NULL,'streamr-table'),
	(500,0,51,'com.unifina.signalpath.map.GetMultiFromMap','GetMultiFromMap (old)','GenericModule',b'1','module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input map\"},\"inputNames\":[\"in\"],\"outputs\":{\"founds\":\"an array indicating for each output with 0 (false) and (1) whether a value was found\",\"out-1\":\"a (default) value from map, output name is used as key\"},\"outputNames\":[\"founds\",\"out-1\"],\"helpText\":\"<p>Get multiple values&nbsp;from a Map. Number of outputs is specified via module options (wrench icon).&nbsp;<strong>The names of outputs are used as map keys so make sure to change them!</strong></p>\"}',NULL,NULL),
	(501,0,51,'com.unifina.signalpath.map.BuildMap','BuildMap','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in-1\":\"default single input, name used as key in Map\"},\"inputNames\":[\"in-1\"],\"outputs\":{\"map\":\"produced map\"},\"outputNames\":[\"map\"],\"helpText\":\"<p>Build a new Map from given inputs. Number of inputs is specified via module options (wrench icon).&nbsp;<strong>The names of input are used as map keys so make sure to change them!</strong></p>\"}',NULL,NULL),
	(520,0,1,'com.unifina.signalpath.simplemath.VariadicAddMulti','Add','GenericModule',NULL,'module',1,'{\"outputNames\":[\"sum\"],\"inputs\":{},\"helpText\":\"<p>Adds together two or more numeric input values.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{\"sum\":\"Sum of inputs\"},\"paramNames\":[]}','Plus',NULL),
	(521,0,19,'com.unifina.signalpath.utils.VariadicPassThrough','PassThrough','GenericModule',NULL,'module',1,'{\"outputNames\":[],\"inputs\":{},\"helpText\":\"<p>This module just sends out whatever it receives.</p>\",\"inputNames\":[],\"params\":{},\"outputs\":{},\"paramNames\":[]}',NULL,NULL),
	(522,0,3,'com.unifina.signalpath.utils.VariadicFilter','Filter','FilterModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"pass\":\"The filter condition. 1 (true) for letting the event pass, 0 (false) to filter it out\",\"in\":\"The incoming event (any type)\"},\"inputNames\":[\"pass\",\"in\"],\"outputs\":{\"out\":\"The event that came in, if passed. If filtered, nothing is sent\"},\"outputNames\":[\"out\"],\"helpText\":\"Only lets the incoming value through if the value at <span class=\'highlight\'>pass</span> is 1. If this condition is not met, no event is sent out.\"}','Select, Pick, Choose',NULL),
	(523,0,51,'com.unifina.signalpath.map.VariadicGetMultiFromMap','GetMultiFromMap','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input map\"},\"inputNames\":[\"in\"],\"outputs\":{\"founds\":\"an array indicating for each output with 0 (false) and (1) whether a value was found\",\"out-1\":\"a (default) value from map, output name is used as key\"},\"outputNames\":[\"founds\",\"out-1\"],\"helpText\":\"<p>Get multiple values&nbsp;from a Map. &nbsp;<strong>The names of outputs are used as map keys so make sure to change them!</strong></p>\"}',NULL,NULL),
	(524,0,2,'com.unifina.signalpath.filtering.MovingAverageModule','MovingAverage','GenericModule',NULL,'module',1,'{\"outputNames\":[\"out\"],\"inputs\":{\"in\":\"Input values\"},\"helpText\":\"<p>This module calculates the simple moving average (MA, SMA) of values arriving at the input. Each value is assigned equal weight. The moving average is calculated based on a sliding window of adjustable length.</p>\",\"inputNames\":[\"in\"],\"params\":{\"minSamples\":\"Minimum number of input values received before a value is output\",\"length\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\"},\"outputs\":{\"out\":\"The moving average\"},\"paramNames\":[\"length\",\"minSamples\"]}','SMA',NULL),
	(525,0,51,'com.unifina.signalpath.map.FilterMap','FilterMap','GenericModule',NULL,'module',1,'{\"params\":{\"keys\":\"if empty, keep all entries. otherwise filter by given keys.\"},\"paramNames\":[\"keys\"],\"inputs\":{\"in\":\"map to be filtered\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"filtered map\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Filter incoming maps by retaining entries with specified keys.</p>\"}',NULL,NULL),
	(526,0,51,'com.unifina.signalpath.map.CollectFromMaps','CollectFromMaps','GenericModule',NULL,'module',1,'{\"params\":{\"selector\":\"a map property name\"},\"paramNames\":[\"selector\"],\"inputs\":{\"listOrMap\":\"list or map to collect from\"},\"inputNames\":[\"listOrMap\"],\"outputs\":{\"listOrMap\":\"collected list or map\"},\"outputNames\":[\"listOrMap\"],\"helpText\":\"<p>Given a list/map of maps, selects from each an entry according to parameter&nbsp;<em>selector,&nbsp;</em>and then returns a list/map of the collected entry values.</p>\n\n<p>&nbsp;</p>\n\n<p>In case a map does not have an entry for <em>selector,&nbsp;</em>or the value is null, that entry will be simply skipped in the resulting output.</p>\n\n<p>&nbsp;</p>\n\n<p>Map entry <em>selector</em> supports dot and array notation for selecting from nested maps and lists, e.g. &quot;parents[1].name&quot; would return [&quot;Homer&quot;, &quot;Fred&quot;] for input [{name: &quot;Bart&quot;, parents: [{name: &quot;Marge&quot;}, {name: &quot;Homer&quot;}]}, {name: &quot;Pebbles&quot;, parents: [{name: &quot;Wilma}, {name: &quot;Fred&quot;}]}]</p>\"}',NULL,NULL),
	(527,0,3,'com.unifina.signalpath.utils.VariadicEventTable','Table','TableModule',NULL,'module event-table-module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Displays a table of events arriving at the inputs along with their timestamps. The number of inputs can be adjusted in module options. Every input corresponds to a table column. Very useful for debugging and inspecting values. The inputs can be connected to all types of outputs.</p>\"}','Events','streamr-table'),
	(528,0,53,'com.unifina.signalpath.streams.SearchStream','SearchStream','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"name\":\"stream to search for by name, must be exact\"},\"inputNames\":[\"name\"],\"outputs\":{\"found\":\"true if stream was found\",\"stream\":\"id of stream if found\"},\"outputNames\":[\"found\",\"stream\"],\"helpText\":\"<p>Search for a stream by name</p>\"}',NULL,NULL),
	(529,0,53,'com.unifina.signalpath.streams.CreateStream','CreateStream','GenericModule',NULL,'module',1,'{\"params\":{\"fields\":\"the fields to be assigned to the stream\"},\"paramNames\":[\"fields\"],\"inputs\":{\"name\":\"name of the stream\",\"description\":\"human-readable description\"},\"inputNames\":[\"name\",\"description\"],\"outputs\":{\"created\":\"true if stream was created, false if failed to create stream\",\"stream\":\"the id of the created stream\"},\"outputNames\":[\"created\",\"stream\"],\"helpText\":\"<p>Create a new stream.</p>\"}',NULL,NULL),
	(539,0,52,'com.unifina.signalpath.list.ForEachItem','ForEachItem','GenericModule',NULL,'module',1,'{\"params\":{\"keepState\":\"when false, sub-canvas state is cleared after lists have been processed  \",\"canvas\":\"the sub-canvas to be executed\"},\"paramNames\":[\"keepState\",\"canvas\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"numOfItems\":\"indicates how many times the sub-canvas was executed\"},\"outputNames\":[\"numOfItems\"],\"helpText\":\"<p>Execute a sub-canvas for each item of input lists.</p>\n\n<p>&nbsp;</p>\n\n<p>The&nbsp;exported inputs and outputs of sub-canvas <em>canvas</em>&nbsp;appear as list inputs and list outputs. The input lists are iterated element-wise, and the sub-canvas is executed every time a value is available for each input list. If input list sizes vary, the sub-canvas is executed as many times as the&nbsp;smallest list is of size. After the input lists have been iterated through,&nbsp;and the sub-canvas activated accordingly, lists of produced values are sent to output lists.</p>\n\n<p>&nbsp;</p>\n\n<p>The output&nbsp;<em>numOfItems</em>&nbsp;indicates how many times the sub-canvas was executed, i.e., the size of the smallest input list.</p>\n\n<p>&nbsp;</p>\n\n<p>You may want to look into the module&nbsp;<strong>RepeatItem</strong>&nbsp;when using this module to repeat parameter values etc.</p>\"}',NULL,NULL),
	(540,0,52,'com.unifina.signalpath.list.RepeatItem','RepeatItem','GenericModule',NULL,'module',1,'{\"params\":{\"times\":\"times to repeat the item\"},\"paramNames\":[\"times\"],\"inputs\":{\"item\":\"item to be repeated\"},\"inputNames\":[\"item\"],\"outputs\":{\"list\":\"the produced list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Make a list out of an&nbsp;item by repeating it <em>times&nbsp;</em>times.&nbsp;</p>\"}',NULL,NULL),
	(541,0,52,'com.unifina.signalpath.list.Indices','Indices','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"an input list\"},\"inputNames\":[\"list\"],\"outputs\":{\"indices\":\"a list of indices for the input list\",\"list\":\"the original input list\"},\"outputNames\":[\"indices\",\"list\"],\"helpText\":\"<p>Generates a list from <strong>[0,n-1]</strong>&nbsp;according to the size <strong>n</strong>&nbsp;of the given input list.&nbsp;</p>\"}','Indexes',NULL),
	(544,0,52,'com.unifina.signalpath.list.ListSize','ListSize','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"size\":\"number of items in list\"},\"outputNames\":[\"size\"],\"helpText\":\"<p>Determine size of list.</p>\"}',NULL,NULL),
	(545,0,52,'com.unifina.signalpath.list.Range','Range','GenericModule',NULL,'module',1,'{\"params\":{\"from\":\"start of sequence; included in sequence.\",\"step\":\"step size to add/subtract; sign is ignored; an empty sequence is produced if set to 0\",\"to\":\"upper bound of sequence; not necessarily included in sequence\"},\"paramNames\":[\"from\",\"step\",\"to\"],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"out\":\"the generated sequence\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generates a sequence&nbsp;of numbers increasing/decreasing according to a specified <em>step</em>.</p>\n\n<p>&nbsp;</p>\n\n<p>When&nbsp;<em>from &lt; to</em>&nbsp;a growing sequence is produced.&nbsp;Otherwise (<em>from &gt; to)</em>&nbsp;a decreasing sequence is produced. The sign of parameter&nbsp;<em>step</em>&nbsp;is ignored, and&nbsp;is automatically determined&nbsp;by the inequality relation between&nbsp;<em>from&nbsp;</em>and&nbsp;<em>to</em>.</p>\n\n<p>&nbsp;</p>\n\n<p>Parameter&nbsp;<em>to</em>&nbsp;acts as an upper bound which means that if sequence generation goes over&nbsp;<em>to</em>, the exceeding values are not included in the sequence. E.g., from=1, to=2, seq=0.3 results in [1, 1.3, 1.6, 1.9], with&nbsp;2.1 notably not included.</p>\"}',NULL,NULL),
	(546,0,52,'com.unifina.signalpath.list.SubList','SubList','GenericModule',NULL,'module',1,'{\"params\":{\"from\":\"start position (included)\",\"to\":\"end position (not included)\"},\"paramNames\":[\"from\",\"to\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"error\":\"error string in case error occurred\",\"out\":\"extracted sub list if successful\"},\"outputNames\":[\"error\",\"out\"],\"helpText\":\"<p>Extract a sub&nbsp;list from a list.</p>\n\n<p>&nbsp;</p>\n\n<p>This&nbsp;module is strict&nbsp;about correct indexing. If given incorrect indices, instead of a sub list being produced,&nbsp;an error will be produced in output <em>error</em>.&nbsp;</p>\"}',NULL,NULL),
	(548,0,52,'com.unifina.signalpath.list.AddToList','AddToList','GenericModule',NULL,'module',1,'{\"params\":{\"index\":\"index to add to, from 0 to length of list\"},\"paramNames\":[\"index\"],\"inputs\":{\"item\":\"item to add to list\",\"list\":\"the list to add to\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"error\":\"error string if given invalid index\",\"list\":\"the result if operation successful\"},\"outputNames\":[\"error\",\"list\"],\"helpText\":\"<p>Insert an item into&nbsp;an arbitrary position of a List. Unless adding to the very end of a list,&nbsp;items starting from&nbsp;<em>index </em>are&nbsp;all shifted to the right to allow insertion of new item.</p>\n\"}',NULL,NULL),
	(549,0,52,'com.unifina.signalpath.list.AppendToList','AppendToList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to append\",\"list\":\"list to append to\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"list\":\"resulting list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Append an item to the end of a List.</p>\n\"}',NULL,NULL),
	(550,0,52,'com.unifina.signalpath.list.BuildList','BuildList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Build a fixed-sized list from values at inputs.</p>\n\"}',NULL,NULL),
	(551,0,52,'com.unifina.signalpath.list.ContainsItem','ContainsItem','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to look for\",\"list\":\"list to look from\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"found\":\"true if found; false otherwise\"},\"outputNames\":[\"found\"],\"helpText\":\"<p>Checks whether a list contains an item.</p>\n\"}',NULL,NULL),
	(552,0,52,'com.unifina.signalpath.list.FlattenList','FlattenList','GenericModule',NULL,'module',1,'{\"params\":{\"deep\":\"whether to flatten recursively\"},\"paramNames\":[\"deep\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"flattened list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Flattens lists inside a list, e.g. [1, [2,3], [4, 5], 6, [7, 8], 9] -&gt; [1, 2, 3, 4, 5, 6, 7, 8, 9].</p>\n\n<p>&nbsp;</p>\n\n<p>If <em>deep&nbsp;= true</em>, flattening will be done recursively. E.g. [1, [2, [3, [4, 5, [6]]], 7], 8, 9] -&gt;&nbsp;[1, 2, 3, 4, 5, 6, 7, 8, 9]. Otherwise only one level of flattening will be perfomed.</p>\n\"}',NULL,NULL),
	(553,0,52,'com.unifina.signalpath.list.HeadList','HeadList','GenericModule',NULL,'module',1,'{\"params\":{\"limit\":\"the maximum number of items to include\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a list containing the first items of a list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Retrieves the first (a maximum of <em>limit</em>)&nbsp;items of a list.</p>\n\"}',NULL,NULL),
	(554,0,52,'com.unifina.signalpath.list.MergeList','MergeList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"head\":\"the first items of the merged list\",\"tail\":\"the last items of the merged list\"},\"inputNames\":[\"head\",\"tail\"],\"outputs\":{\"out\":\"merged list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Merge two lists (<em>head + tail)</em> together to form a singe list. Merging is simply done by adding items of&nbsp;<em>tail&nbsp;</em>to the end of&nbsp;<em>head&nbsp;</em>to form a single list.</p>\n\"}',NULL,NULL),
	(555,0,52,'com.unifina.signalpath.list.RemoveFromList','RemoveFromList','GenericModule',NULL,'module',1,'{\"params\":{\"index\":\"position to remove item from\"},\"paramNames\":[\"index\"],\"inputs\":{\"in\":\"list to remove item from\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"the list with the item removed\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Remove an item from a list by index. Given an invalid index, this module simply outputs&nbsp;the original&nbsp;input list.</p>\n\"}',NULL,NULL),
	(556,0,52,'com.unifina.signalpath.list.ReverseList','ReverseList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"reversed list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Reverses a list.</p>\n\"}',NULL,NULL),
	(557,0,52,'com.unifina.signalpath.list.SortList','SortList','GenericModule',NULL,'module',1,'{\"params\":{\"order\":\"ascending or descending\"},\"paramNames\":[\"order\"],\"inputs\":{\"in\":\"list to sort\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"sorted list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Sort a list.</p>\n\"}',NULL,NULL),
	(558,0,52,'com.unifina.signalpath.list.TailList','TailList','GenericModule',NULL,'module',1,'{\"params\":{\"limit\":\"the maximum number of items to include\"},\"paramNames\":[\"limit\"],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"a list containing the last items of a list\"},\"outputNames\":[\"out\"],\"helpText\":\"<p><br />\nRetrieves the last&nbsp;(a maximum of limit) items of a list.</p>\n\"}',NULL,NULL),
	(559,0,52,'com.unifina.signalpath.list.Unique','Unique','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"list with possible duplicates\"},\"inputNames\":[\"list\"],\"outputs\":{\"list\":\"list without duplicates\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Removes duplicate items from a list resulting in a list of unique items. The first occurrence of an item is kept&nbsp;and subsequent occurrences removed.</p>\n\"}',NULL,NULL),
	(560,0,52,'com.unifina.signalpath.list.IndexOfItem','IndexOfItem','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to look for\",\"list\":\"list to look in\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"index\":\"outputs the index of the first occurrence; does not output anything if no occurrences\"},\"outputNames\":[\"index\"],\"helpText\":\"<p>Finds the index of the first occurrence of an item in a list.</p>\n\"}',NULL,NULL),
	(561,0,52,'com.unifina.signalpath.list.IndexesOfItem','IndexesOfItem','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"item\":\"item to look for\",\"list\":\"item to look for\"},\"inputNames\":[\"item\",\"list\"],\"outputs\":{\"indexes\":\"list of indexes of occurrences; empty list if none\"},\"outputNames\":[\"indexes\"],\"helpText\":\"<p>Finds indexes of all&nbsp;occurrences of an item in a list.</p>\n\"}',NULL,NULL),
	(562,0,54,'com.unifina.signalpath.random.RandomNumber','RandomNumber','GenericModule',NULL,'module',1,'{\"params\":{\"min\":\"lower bound of interval to sample from\",\"max\":\"upper bound of interval to sample from\"},\"paramNames\":[\"min\",\"max\"],\"inputs\":{\"trigger\":\"when value is received, activates module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"the random number\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generate random numbers between [<em>min</em>, <em>max</em>] with uniform probability.</p>\"}',NULL,NULL),
	(563,0,54,'com.unifina.signalpath.random.RandomNumberGaussian','RandomNumberGaussian','GenericModule',NULL,'module',1,'{\"params\":{\"mean\":\"mean of normal distribution\",\"sd\":\"standard deviation of normal distribution\"},\"paramNames\":[\"mean\",\"sd\"],\"inputs\":{\"trigger\":\"when value is received, activates module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"the random number\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generate random numbers from normal (Gaussian) distribution with mean&nbsp;<em>mean</em>&nbsp;and standard deviation&nbsp;<em>sd</em>.</p>\"}',NULL,NULL),
	(564,0,27,'com.unifina.signalpath.random.RandomString','RandomString','GenericModule',NULL,'module',1,'{\"params\":{\"length\":\"length of strings to generate\"},\"paramNames\":[\"length\"],\"inputs\":{\"trigger\":\"when value is received, activates module\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"out\":\"the random string\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Generate fixed-length random strings from an equiprobable symbol pool. Allowed symbols can be configured from module settings.</p>\"}',NULL,NULL),
	(565,0,52,'com.unifina.signalpath.random.ShuffleList','ShuffleList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"in\":\"input list\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"input list randomly ordered\"},\"outputNames\":[\"out\"],\"helpText\":\"<p>Shuffle the items of a list.</p>\"}',NULL,NULL),
	(566,0,28,'com.unifina.signalpath.time.TimeOfEvent','TimeOfEvent','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"trigger\":\"any value; causes module to activate, i.e., produce output\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"timestamp\":\"time of the current event\"},\"outputNames\":[\"timestamp\"],\"helpText\":\"<p>Get timestamp for the event currently being processed. Similar to <strong>Clock,&nbsp;</strong>but instead of generating events,&nbsp;this&nbsp;module is triggered manually through input&nbsp;<em>trigger</em>.&nbsp;</p>\"}',NULL,NULL),
	(567,0,1,'com.unifina.signalpath.simplemath.Expression','Expression','GenericModule',NULL,'module',1,'{\"params\":{\"expression\":\"mathematical expression to evaluate\"},\"paramNames\":[\"expression\"],\"inputs\":{\"x\":\"variable for default expression\",\"y\":\"variable for default expression\"},\"inputNames\":[\"x\",\"y\"],\"outputs\":{\"out\":\"result if evaluation succeeded\",\"error\":\"error message if evaluation failed (e.g. syntax error in expression)\"},\"outputNames\":[\"out\",\"error\"],\"helpText\":\"<p>Evaluate arbitrary mathematical expressions containing operators, variables, and functions. Variables introduced in an&nbsp;expression&nbsp;will automatically appear as&nbsp;inputs.</p>\n\n<p>&nbsp;</p>\n\n<p>See&nbsp;<a href=https://github.com/uklimaschewski/EvalEx#supported-operators>https://github.com/uklimaschewski/EvalEx#supported-operators</a>&nbsp;for further detail about supported features.</p>\"}',NULL,NULL),
	(569,0,27,'com.unifina.signalpath.text.FormatNumber','FormatNumber','GenericModule',NULL,'module',1,'{\"params\":{\"decimalPlaces\":\"number of decimal places\"},\"paramNames\":[\"decimalPlaces\"],\"inputs\":{\"number\":\"number to format\"},\"inputNames\":[\"number\"],\"outputs\":{\"text\":\"number formatted as string\"},\"outputNames\":[\"text\"],\"helpText\":\"<p>Format a number into a string with a specified number of&nbsp;decimal places.</p>\"}',NULL,NULL),
	(570,0,3,'com.unifina.signalpath.utils.MovingWindow','MovingWindow','GenericModule',NULL,'module',1,'{\"params\":{\"windowLength\":\"Length of the sliding window, ie. the number of most recent input values to include in calculation\",\"windowType\":\"behavior of window\",\"minSamples\":\"Minimum number of input values received before a value is output\"},\"paramNames\":[\"windowLength\",\"windowType\",\"minSamples\"],\"inputs\":{\"in\":\"values of any type\"},\"inputNames\":[\"in\"],\"outputs\":{\"list\":\"the window\'s current state as a list\"},\"outputNames\":[\"list\"],\"helpText\":\"<p>Provides&nbsp;a moving window (list)&nbsp;for any types of values. Window size and behavior&nbsp;can be set via parameters.</p>\"}',NULL,NULL),
	(571,0,3,'com.unifina.signalpath.utils.ExportCSV','ExportCSV','ExportCSVModule',NULL,'module',1,NULL,NULL,NULL),
	(573,0,10,'com.unifina.signalpath.bool.Xor','Xor','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Implements the boolean XOR operation: outputs true&nbsp;if <span class=\\\"highlight\\\">one</span> of the inputs equal true, otherwise outputs false.</p>\"}',NULL,NULL),
	(800,1,51,'com.unifina.signalpath.map.ConstantMap','ConstantMap','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to enter a constant Map object, which is a set of key-value pairs. It can be connected to any Map input in Streamr - for example, to set headers on the HTTP module.</p>\\n\"}','MapConstant',NULL),
	(801,3,28,'com.unifina.signalpath.time.Scheduler','Scheduler','SchedulerModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{\"value\":\"The value from a active rule or the default value\"},\"outputNames\":[\"value\"],\"helpText\":\"<p>Outputs a certain value at a certain time.&nbsp;E.g. Every day from 10:00 to 14:00 the module outputs value 1&nbsp;and otherwise value 0.<br />\\nIf more than one rule are active at the same time, the value from the rule with the highest priority (the highest rule in the list) is sent.<br />\\nIf no rule is active,&nbsp;the default value will be sent out.&nbsp;</p>\\n\"}',NULL,NULL),
	(802,1,52,'com.unifina.signalpath.list.ConstantList','ConstantList','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{},\"inputNames\":[],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>This module allows you to manually enter a constant List object.</p>\\n\"}','ListConstant',NULL),
	(1000,0,1000,'com.unifina.signalpath.remote.SimpleHttp','Simple HTTP','GenericModule',NULL,'module',5,'{\"params\":{\"verb\":\"HTTP verb (e.g. GET, POST)\",\"URL\":\"URL to send the request to\"},\"paramNames\":[\"verb\",\"URL\"],\"inputs\":{\"trigger\":\"Send request when input arrives\"},\"inputNames\":[\"trigger\"],\"outputs\":{\"error\":\"Description of what went wrong\"},\"outputNames\":[\"error\"],\"helpText\":\"<p>HTTP Request module sends input values as HTTP request to given URL, parses the server response, and sends resulting values through named outputs.</p><p>Please rename inputs, outputs and headers using names that the target API requires. To pluck values nested deeper in response JSON, use square brackets and dot notation, e.g. naming output as <i>customers[2].name</i> would fetch \"Bob\" from <i>{\"customers\":[{\"name\":\"Rusty\"},{\"name\":\"Mack\"},{\"name\":\"</i><b>Bob</b><i>\"}]}</i> (array indices are <b>zero</b>-based, that is, first element is number <b>0</b>!)</p><p>For GET and DELETE requests, the input values are added to URL parameters:<br /><i>http://url?key1=value1&key2=value2&...</i></p><p>For other requests, the input values are sent in the body as JSON object:<br /><i>{\"key1\": \"value1\", \"key2\": \"value2\", ...}</i></p>\"}',NULL,NULL),
	(1001,0,1000,'com.unifina.signalpath.remote.Http','HTTP Request','GenericModule',NULL,'module',1,'{\"params\":{\"verb\":\"HTTP verb (e.g. GET, POST)\",\"URL\":\"URL to send the request to\",\"params\":\"Query parameters added to URL (?name=value)\",\"headers\":\"HTTP Request headers\"},\"paramNames\":[\"verb\",\"URL\",\"params\",\"headers\"],\"inputs\":{\"body\":\"Request body\",\"trigger\":\"Send request when input arrives\"},\"inputNames\":[\"body\",\"trigger\"],\"outputs\":{\"errors\":\"Empty list if all went correctly\",\"data\":\"Server response payload\",\"status code\":\"200..299 means all went correctly\",\"ping(ms)\":\"Round-trip response time in milliseconds\",\"headers\":\"HTTP Response headers\"},\"outputNames\":[\"errors\",\"data\",\"status code\",\"ping(ms)\",\"headers\"],\"helpText\":\"<p>HTTP Request module sends inputs as HTTP request to given URL, and returns server response.</p><p>Headers, query params and body should be Maps. Body can also be List or String.</p><p>Request body format can be changed in options (wrench icon). Default is JSON. Server is expected to return JSON formatted documents.</p><p>HTTP Request is asynchronous by default. Synchronized requests block the execution of the whole canvas until they receive the server response, but otherwise they work just like any other module; asynchronous requests on the other hand work like streams in that they activate modules they&#39;re connected to only when they receive data from the server. </p><ul><li>If a data path branches, and one branch passes through the HTTP Request module and another around it, if they also converge in a module, that latter module may experience multiple activations due to asynchronicity.</li><li>Asynchronicity also means that server responses may arrive in different order than they were sent.</li><li>If this kind of behaviour causes problems, you can try to fix it by changing sync mode to <i>synchronized</i> in options (wrench icon). <ul><li>Caveat: data throughput WILL be lower, and external servers may freeze your canvas simply by responding very slowly (or not at all).</li></ul></li><li>For simple data paths and somewhat stable response times, the two sync modes will yield precisely the same results.</li></ul>',NULL,NULL),
	(1002,0,10,'com.unifina.signalpath.convert.BooleanToNumber','BooleanToNumber','GenericModule',NULL,'module',1,'',NULL,NULL),
	(1003,0,10,'com.unifina.signalpath.bool.BooleanConstant','BooleanConstant','GenericModule',NULL,'module',1,'',NULL,NULL),
	(1010,0,1000,'com.unifina.signalpath.remote.Sql','SQL','GenericModule',NULL,'module',1,'{\"params\":{\"engine\":\"Database engine, e.g. MySQL\",\"host\":\"Database server to connect\",\"database\":\"Name of the database\",\"username\":\"Login username\",\"password\":\"Login password\"},\"paramNames\":[\"engine\",\"host\",\"database\",\"username\",\"password\"],\"inputs\":{\"sql\":\"SQL command to be executed\"},\"inputNames\":[\"sql\"],\"outputs\":{\"errors\":\"List of error strings\",\"result\":\"List of rows returned by the database\"},\"outputNames\":[\"errors\",\"result\"],\"helpText\":\"<p>The result is a list of map objects, e.g. <i>[{&quot;id&quot;:0, &quot;name&quot;:&quot;Me&quot;}, {&quot;id&quot;:1, &quot;name&quot;:&quot;You&quot;}]</i></p>\"}',NULL,NULL),
	(1011,0,3,'com.unifina.signalpath.utils.ListAsTable','ListAsTable','TableModule',NULL,'module event-table-module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"List to be shown\"},\"inputNames\":[\"list\"],\"outputs\":{},\"outputNames\":[],\"helpText\":\"<p>Display contents of a list as a table. If it\'s a list of maps, break maps into columns</p>\"}',NULL,'streamr-table'),
	(1012,0,52,'com.unifina.signalpath.list.GetFromList','GetFromList','GenericModule',NULL,'module',1,'{\"params\":{\"index\":\"Index in the list for the item to be fetched. Negative index counts from end of list.\"},\"paramNames\":[\"index\"],\"inputs\":{\"in\":\"List to be indexed\"},\"inputNames\":[\"in\"],\"outputs\":{\"out\":\"Item found at given index\",\"error\":\"Error message, e.g. <i>List is empty</i>\"},\"outputNames\":[\"out\",\"error\"],\"helpText\":\"<p>Fetch item from a list by index.</p><p>Indexing starts from zero, so the first item has index 0, second has index 1 etc.</p><p>Negative index counts from end of list, so that last item in the list has index -1, second-to-last has index -2 etc.</p>\"}',NULL,NULL),
	(1015,0,27,'com.unifina.signalpath.text.StringTemplate','StringTemplate','GenericModule',NULL,'module',1,'{\"params\":{\"template\":\"Text template\"},\"paramNames\":[\"template\"],\"inputs\":{\"args\":\"Map of arguments that will be substituted into the template\"},\"inputNames\":[\"args\"],\"outputs\":{\"errors\":\"List of error strings\",\"result\":\"Completed template string\"},\"outputNames\":[\"errors\", \"result\"],\"helpText\":\"<p>For template syntax, see <a href=\'https://github.com/antlr/stringtemplate4/blob/master/doc/cheatsheet.md\' target=\'_blank\'>StringTemplate cheatsheet</a>.</p><p>Values of the <strong>args</strong> map are added as substitutions in the template. For example, incoming map <strong>{name: &quot;Bernie&quot;, age: 50}</strong> substituted into template &quot;<strong>Hi, &lt;name&gt;!</strong>&quot;&nbsp;would produce string &quot;Hi, Bernie!&quot;</p><p>Nested maps can be accessed with dot notation:&nbsp;<strong>{name: &quot;Bernie&quot;, pet: {species: &quot;dog&quot;, age: 3}}</strong>&nbsp;substituted into &quot;<strong>What a cute &lt;pet.species&gt;!</strong>&quot; would result in &quot;What a cute dog!&quot;.</p><p>Lists will be smashed together: <strong>{pals:&nbsp;[&quot;Sam&quot;, &quot;Herb&quot;, &quot;Dud&quot;]}</strong>&nbsp;substituted into &quot;<strong>BFF: me, &lt;pals&gt;</strong>&quot; results in &quot;BFF: me, SamHerbDud&quot;. Separator must be explicitly given: &quot;<strong>BFF: me, &lt;pals; separator=&quot;, &quot;&gt;</strong>&quot; gives &quot;BFF: me, Sam, Herb, Dud&quot;.</p><p>Transforming list items can be done with <em>{ x | f(x) }</em> syntax, e.g. <strong>{pals:&nbsp;[&quot;Sam&quot;, &quot;Herb&quot;, &quot;Dud&quot;]}</strong> substituted into &quot;<strong>&lt;pals: { x | Hey &lt;x&gt;! }&gt; Hey y&#39;all!</strong>&quot; results in &quot;Hey Sam! Hey Herb! Hey Dud! Hey y&#39;all!&quot;.</p>\"}',NULL,NULL),
	(1016,0,27,'com.unifina.signalpath.text.JsonParser','JsonParser','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"json\":\"JSON string to parse\"},\"inputNames\":[\"json\"],\"outputs\":{\"errors\":\"List of error strings\",\"result\":\"Map, List or value that the JSON string represents\"},\"outputNames\":[\"errors\", \"result\"],\"helpText\":\"<p>JSON string should fulfill the <a href=\'http://json.org/\' target=\'_blank\'>JSON specification</a>.</p>\"}',NULL,NULL),
	(1030,0,52,'com.unifina.signalpath.list.ListToEvents','ListToEvents','GenericModule',NULL,'module',1,'{\"params\":{},\"paramNames\":[],\"inputs\":{\"list\":\"input list\"},\"inputNames\":[\"list\"],\"outputs\":{\"item\":\"input list items one by one as separate events\"},\"outputNames\":[\"item\"],\"helpText\":\"<p>Split input list into separate events. They will be sent out as separate events, one item at a time.</p><p>Each event causes activation of all modules where the output item is sent to.</p>\"}',NULL,NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `module_category` WRITE;
/*!40000 ALTER TABLE `module_category` DISABLE KEYS */;

INSERT INTO `module_category` (`id`, `version`, `name`, `sort_order`, `parent_id`, `module_package_id`, `hide`)
VALUES
	(1,0,'Simple Math',40,15,1,NULL),
	(2,0,'Filtering',30,15,1,NULL),
	(3,0,'Utils',100,NULL,1,NULL),
	(7,0,'Triggers',60,15,1,NULL),
	(10,0,'Boolean',45,NULL,1,NULL),
	(11,0,'Prediction',20,15,1,NULL),
	(12,0,'Statistics',42,15,1,NULL),
	(13,0,'Visualizations',80,NULL,1,NULL),
	(15,0,'Time Series',1,NULL,1,NULL),
	(18,0,'Custom Modules',70,NULL,1,NULL),
	(19,0,'Time Series Utils',70,15,1,NULL),
	(25,0,'Data Sources',0,NULL,1,b'1'),
	(27,0,'Text',2,NULL,1,NULL),
	(28,0,'Time & Date',3,NULL,1,NULL),
	(50,0,'Color',1,3,1,NULL),
	(51,0,'Map',141,NULL,1,NULL),
	(52,0,'List',142,NULL,1,NULL),
	(53,0,'Streams',143,NULL,1,NULL),
	(54,0,'Random',142,15,1,NULL),
	(100,0,'Input',140,NULL,1,NULL),
	(1000,0,'Integrations',130,NULL,1,NULL);

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
	(2,0,'trading',1),
	(3,0,'unifina',1),
	(4,0,'unsafe',1),
	(5,0,'deprecated',1);

/*!40000 ALTER TABLE `module_package` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table permission
# ------------------------------------------------------------

DROP TABLE IF EXISTS `permission`;

CREATE TABLE `permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `clazz` varchar(255) NOT NULL,
  `long_id` bigint(20) DEFAULT NULL,
  `operation` varchar(255) NOT NULL,
  `string_id` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `invite_id` bigint(20) DEFAULT NULL,
  `anonymous` bit(1) NOT NULL,
  `key_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKE125C5CF60701D32` (`user_id`),
  KEY `FKE125C5CF8377B94B` (`invite_id`),
  KEY `FKE125C5CF8EE35041` (`key_id`),
  CONSTRAINT `FKE125C5CF8EE35041` FOREIGN KEY (`key_id`) REFERENCES `key` (`id`),
  CONSTRAINT `FKE125C5CF60701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`),
  CONSTRAINT `FKE125C5CF8377B94B` FOREIGN KEY (`invite_id`) REFERENCES `signup_invite` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;

INSERT INTO `permission` (`id`, `version`, `clazz`, `long_id`, `operation`, `string_id`, `user_id`, `invite_id`, `anonymous`, `key_id`)
VALUES
	(1,0,'com.unifina.domain.signalpath.ModulePackage',1,'read',NULL,1,NULL,b'0',NULL),
	(2,0,'com.unifina.domain.signalpath.ModulePackage',1,'read',NULL,2,NULL,b'0',NULL),
	(3,0,'com.unifina.domain.signalpath.ModulePackage',1,'read',NULL,3,NULL,b'0',NULL),
	(4,0,'com.unifina.domain.data.Feed',7,'read',NULL,1,NULL,b'0',NULL),
	(5,0,'com.unifina.domain.data.Feed',8,'read',NULL,1,NULL,b'0',NULL),
	(7,0,'com.unifina.domain.signalpath.ModulePackage',1,'read',NULL,NULL,NULL,b'1',NULL),
	(8,0,'com.unifina.domain.data.Feed',7,'read',NULL,NULL,NULL,b'1',NULL),
	(9,0,'com.unifina.domain.signalpath.Canvas',NULL,'read','iaUL6FCrRzmq1xy50G9idg',NULL,NULL,b'1',NULL),
	(10,0,'com.unifina.domain.dashboard.Dashboard',567567,'read',NULL,1,NULL,b'0',NULL),
	(11,0,'com.unifina.domain.dashboard.Dashboard',678678,'share',NULL,1,NULL,b'0',NULL),
	(12,0,'com.unifina.domain.dashboard.Dashboard',678678,'read',NULL,1,NULL,b'0',NULL),
	(13,0,'com.unifina.domain.data.Stream',NULL,'read','YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,b'1',NULL),
	(14,0,'com.unifina.domain.data.Stream',NULL,'read','ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,b'1',NULL),
	(15,0,'com.unifina.domain.data.Stream',NULL,'read','4jFT4_yRSFyElSj9pHmovg',NULL,NULL,b'0','m3CoiiUNQlami6NE8zucTw'),
	(16,0,'com.unifina.domain.data.Stream',NULL,'write','4jFT4_yRSFyElSj9pHmovg',NULL,NULL,b'0','m3CoiiUNQlami6NE8zucTw'),
	(17,0,'com.unifina.domain.data.Stream',NULL,'read','4nxQHjdNQVmy551UB6S4cQ',NULL,NULL,b'0','vtgidzpWSOOrw4iZ7tesnA'),
	(18,0,'com.unifina.domain.data.Stream',NULL,'write','4nxQHjdNQVmy551UB6S4cQ',NULL,NULL,b'0','vtgidzpWSOOrw4iZ7tesnA'),
	(19,0,'com.unifina.domain.data.Stream',NULL,'read','c1_fiG6PTxmtnCYGU-mKuQ',NULL,NULL,b'0','XE_NoXVUTp-b5EIJY_lYHQ'),
	(20,0,'com.unifina.domain.data.Stream',NULL,'write','c1_fiG6PTxmtnCYGU-mKuQ',NULL,NULL,b'0','XE_NoXVUTp-b5EIJY_lYHQ'),
	(21,0,'com.unifina.domain.data.Stream',NULL,'read','IIkpufIYSBu9_Kfot2e78Q',NULL,NULL,b'0','Byy0BTVCRcyWkYg0xKSf4Q'),
	(22,0,'com.unifina.domain.data.Stream',NULL,'write','IIkpufIYSBu9_Kfot2e78Q',NULL,NULL,b'0','Byy0BTVCRcyWkYg0xKSf4Q'),
	(23,0,'com.unifina.domain.data.Stream',NULL,'read','JFXhMJjCQzK-SardC8faXQ',NULL,NULL,b'0','K4FqWBmzTCmXbuCpR-h_YA'),
	(24,0,'com.unifina.domain.data.Stream',NULL,'write','JFXhMJjCQzK-SardC8faXQ',NULL,NULL,b'0','K4FqWBmzTCmXbuCpR-h_YA'),
	(25,0,'com.unifina.domain.data.Stream',NULL,'read','ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,b'0','TaPRLN84RXqh8HXuFjQDLg'),
	(26,0,'com.unifina.domain.data.Stream',NULL,'write','ln2g8OKHSdi7BcL-bcnh2g',NULL,NULL,b'0','TaPRLN84RXqh8HXuFjQDLg'),
	(27,0,'com.unifina.domain.data.Stream',NULL,'read','mvGKMdDrTeaij6mmZsQliA',NULL,NULL,b'0','lpiZh47ySUus4B0TZ18zcw'),
	(28,0,'com.unifina.domain.data.Stream',NULL,'write','mvGKMdDrTeaij6mmZsQliA',NULL,NULL,b'0','lpiZh47ySUus4B0TZ18zcw'),
	(29,0,'com.unifina.domain.data.Stream',NULL,'read','pltRMd8rCfkij4mlZsQkJB',NULL,NULL,b'0','mapmodulesspeckey-api-key'),
	(30,0,'com.unifina.domain.data.Stream',NULL,'write','pltRMd8rCfkij4mlZsQkJB',NULL,NULL,b'0','mapmodulesspeckey-api-key'),
	(31,0,'com.unifina.domain.data.Stream',NULL,'read','RUj6iJggS3iEKsUx5C07Ig',NULL,NULL,b'0','fAjduBGSTlCW31eXPXUe0A'),
	(32,0,'com.unifina.domain.data.Stream',NULL,'write','RUj6iJggS3iEKsUx5C07Ig',NULL,NULL,b'0','fAjduBGSTlCW31eXPXUe0A'),
	(33,0,'com.unifina.domain.data.Stream',NULL,'read','share-spec-stream-uuid',NULL,NULL,b'0','share-spec--stream-key'),
	(34,0,'com.unifina.domain.data.Stream',NULL,'write','share-spec-stream-uuid',NULL,NULL,b'0','share-spec--stream-key'),
	(35,0,'com.unifina.domain.data.Stream',NULL,'read','YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,b'0','RYZ2idC0RZ2mGyRJARiBaQ'),
	(36,0,'com.unifina.domain.data.Stream',NULL,'write','YpTAPDbvSAmj-iCUYz-dxA',NULL,NULL,b'0','RYZ2idC0RZ2mGyRJARiBaQ');

/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
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

LOCK TABLES `registration_code` WRITE;
/*!40000 ALTER TABLE `registration_code` DISABLE KEYS */;

INSERT INTO `registration_code` (`id`, `date_created`, `token`, `username`)
VALUES
	(49,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(50,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(51,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(52,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(53,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(54,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(55,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(56,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(57,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(58,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(59,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(60,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(61,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(62,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(63,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(64,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(65,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(66,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(67,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(68,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(69,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(70,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(71,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(72,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(73,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(74,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(75,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(76,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(77,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(78,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(79,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(80,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(81,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(82,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(83,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(84,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(85,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(86,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(87,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(88,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(89,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(90,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(91,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(92,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(93,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(94,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(95,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(96,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(97,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(98,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(99,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(100,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(101,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(102,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(103,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(104,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(105,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(106,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(107,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(108,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(109,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(110,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(111,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(112,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(113,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(114,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(115,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(116,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(117,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(118,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(119,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(120,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(121,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(122,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(123,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(124,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(125,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(126,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(127,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com'),
	(128,'2015-11-23 00:00:00','ForgotPasswordSpec','tester1@streamr.com');

/*!40000 ALTER TABLE `registration_code` ENABLE KEYS */;
UNLOCK TABLES;


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
  `enabled` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `password_expired` bit(1) NOT NULL,
  `timezone` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `sec_user` WRITE;
/*!40000 ALTER TABLE `sec_user` DISABLE KEYS */;

INSERT INTO `sec_user` (`id`, `version`, `account_expired`, `account_locked`, `enabled`, `name`, `password`, `password_expired`, `timezone`, `username`)
VALUES
	(1,259,b'0',b'0',b'1','Tester One','$2a$10$SaCrIzK75rN/Jl8xPSKIm.l9MPC/mAww8t2CahX9GzamFCoklPr2G',b'0','Europe/Helsinki','tester1@streamr.com'),
	(2,0,b'0',b'0',b'1','Tester Two','$2a$04$pRVYUUEUC4gQH0Hs4oTjWOS/ldKDm54pSAmHxI.mht9LURLsYqL6y',b'0','Europe/Helsinki','tester2@streamr.com'),
	(3,0,b'0',b'0',b'1','Tester Admin','$2a$04$kUm3C39XUPpVvxKZCO.1I.mL0qQgLN.FRltFVcDjl1jap5W5AP7Te',b'0','Europe/Helsinki','tester-admin@streamr.com');

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


# Dump of table serialization
# ------------------------------------------------------------

DROP TABLE IF EXISTS `serialization`;

CREATE TABLE `serialization` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` bigint(20) NOT NULL,
  `bytes` longblob NOT NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `serialization` WRITE;
/*!40000 ALTER TABLE `serialization` DISABLE KEYS */;

INSERT INTO `serialization` (`id`, `version`, `bytes`, `date`)
VALUES
	(1,0,X'A86886A5D2978142DA2D8CF378EBC83CF5EA8ADB327F305122C74E759388BA8C13FA0056FB80B717412331343D0FDF03FEECCE587C98B474A34B089E78245B1A956365F2D90E3565020512043EAEFC3D7DCA12681E7BF37AE7CFDC11B5A329D545B9B00C962FED0771ED903DA12CEF04CA8E46C25DA8504D546C3E4319C49EC8DDEF0E4B34CFCBE1248290647D520E76220C04B594285ABCD3B48625A6726B313ACDF05E053E207A7898D8095F56E11524544385AFD9E2C05125B1E514FE53A8E068BFC131E77D110BEABA63C9B76A2E55C0F529B10DA80F409E46B24D194F99743C4F9733578DA340D9E9DDAEE924289C8AC95E2E799C6713F18B41EFAD92BD40C474385C928766BE45B3EEF8CCF914C6F59715D171322CC57C45D5CD7E78BAB2AF5C124FBB55D5F170115403FBBE83030640DBD87C3FEE53DAA1536E9A649ADCA189B983098F3688F243F71FE0003A67C9EFDA932D537F3D991DAD8D9D1790F6819949C50FCFDFF5BCE21911A626A16A301EC9E8539B0C090C722F97C51658D85B346DB3521E2AF0319D1B92EE388B6976B725D27AAF87C024E19530D3139781D0C6B3412F6729F446171CCF5DD572221A3EF3DDB6DD546F61709FAEBC7EC79316EA2C381131BEC1B996F8E7F418813C66E236ACC4D2CFA8C8E4B39C30ABA3D38A9B9BB2F91B86D85472A9703C8B73BD89D2537477B7B8FEF591A839E8337D','2017-05-03 10:25:04');

/*!40000 ALTER TABLE `serialization` ENABLE KEYS */;
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
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `signup_invite` WRITE;
/*!40000 ALTER TABLE `signup_invite` DISABLE KEYS */;

INSERT INTO `signup_invite` (`id`, `version`, `code`, `date_created`, `last_updated`, `sent`, `used`, `username`)
VALUES
	(1,0,'aapzu_iki.fi','2017-05-03 10:25:59','2017-05-03 10:25:59',b'1',b'0','aapzu@iki.fi');

/*!40000 ALTER TABLE `signup_invite` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table stream
# ------------------------------------------------------------

DROP TABLE IF EXISTS `stream`;

CREATE TABLE `stream` (
  `version` bigint(20) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `feed_id` bigint(20) NOT NULL,
  `first_historical_day` datetime DEFAULT NULL,
  `last_historical_day` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `config` longtext,
  `user_id` bigint(20) DEFAULT NULL,
  `id` varchar(255) NOT NULL DEFAULT '',
  `class` varchar(255) NOT NULL,
  `date_created` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `partitions` int(11) NOT NULL DEFAULT '1',
  `ui_channel` bit(1) NOT NULL DEFAULT b'0',
  `ui_channel_canvas_id` varchar(255) DEFAULT NULL,
  `ui_channel_path` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKCAD54F8060701D32` (`user_id`),
  KEY `FKCAD54F8072507A49` (`feed_id`),
  KEY `name_idx` (`name`),
  KEY `uuid_idx` (`id`),
  KEY `FKCAD54F8052E2E25F` (`ui_channel_canvas_id`),
  KEY `ui_channel_path_idx` (`ui_channel_path`(255)),
  CONSTRAINT `FKCAD54F8052E2E25F` FOREIGN KEY (`ui_channel_canvas_id`) REFERENCES `canvas` (`id`),
  CONSTRAINT `FKCAD54F8060701D32` FOREIGN KEY (`user_id`) REFERENCES `sec_user` (`id`),
  CONSTRAINT `FKCAD54F8072507A49` FOREIGN KEY (`feed_id`) REFERENCES `feed` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `stream` WRITE;
/*!40000 ALTER TABLE `stream` DISABLE KEYS */;

INSERT INTO `stream` (`version`, `description`, `feed_id`, `first_historical_day`, `last_historical_day`, `name`, `config`, `user_id`, `id`, `class`, `date_created`, `last_updated`, `partitions`, `ui_channel`, `ui_channel_canvas_id`, `ui_channel_path`)
VALUES
	(1,NULL,7,NULL,NULL,'LiveSpec-SendToStream','{\"fields\":[{\"name\":\"count\",\"type\":\"number\"}]}',1,'4jFT4_yRSFyElSj9pHmovg','com.unifina.domain.data.Stream','2016-09-28 13:53:58','2016-09-28 13:59:07',1,b'0',NULL,NULL),
	(0,'Used to test that users can not access each others\' streams',7,NULL,NULL,'AccessControlCoreSpec','{\"fields\":[],\"topic\":\"4nxQHjdNQVmy551UB6S4cQ\"}',1,'4nxQHjdNQVmy551UB6S4cQ','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(7,'Used by CanvasSpec to test running canvases',7,'2015-02-23 00:00:00','2015-02-27 22:49:59','CanvasSpec','{\"topic\":\"c1_fiG6PTxmtnCYGU-mKuQ\",\"fields\":[{\"name\":\"temperature\",\"type\":\"number\"},{\"name\":\"rpm\",\"type\":\"number\"},{\"name\":\"text\",\"type\":\"string\"}]}',1,'c1_fiG6PTxmtnCYGU-mKuQ','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(567,NULL,7,'2015-02-23 00:00:00','2015-05-03 13:15:17','CSVImporterFuncSpec','{\"topic\":\"IIkpufIYSBu9_Kfot2e78Q\",\"fields\":[]}',1,'IIkpufIYSBu9_Kfot2e78Q','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(0,'foo xyzzy bar',7,NULL,NULL,'ModuleBuildSpec','{\"fields\":[],\"topic\":\"JFXhMJjCQzK-SardC8faXQ\"}',1,'JFXhMJjCQzK-SardC8faXQ','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(0,'Bitcoin mentions on Twitter',7,NULL,NULL,'Twitter-Bitcoin','{\"fields\":[{\"name\":\"text\",\"type\":\"string\"},{\"name\":\"user\",\"type\":\"object\"},{\"name\":\"retweet_count\",\"type\":\"number\"},{\"name\":\"favorite_count\",\"type\":\"number\"},{\"name\":\"lang\",\"type\":\"string\"}]}',1,'ln2g8OKHSdi7BcL-bcnh2g','com.unifina.domain.data.Stream','2016-05-31 18:16:00','2016-05-31 18:16:00',1,b'0',NULL,NULL),
	(0,'Stream for serialization specification/test',7,NULL,NULL,'SerializationSpec','{\"topic\":\"mvGKMdDrTeaij6mmZsQliA\",\"fields\":[{\"name\":\"a\",\"type\":\"number\"},{\"name\":\"b\",\"type\":\"number\"}]}',1,'mvGKMdDrTeaij6mmZsQliA','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(0,'Stream for MapModulesSpec functional test',7,NULL,NULL,'MapModulesSpec','{\"topic\":\"pltRMd8rCfkij4mlZsQkJB\",\"fields\":[{\"name\":\"key\",\"type\":\"string\"},{\"name\":\"value\",\"type\":\"number\"}]}',1,'pltRMd8rCfkij4mlZsQkJB','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(1,NULL,7,NULL,NULL,'LiveSpec','{\"topic\":\"RUj6iJggS3iEKsUx5C07Ig\",\"fields\":[{\"name\":\"rand\",\"type\":\"number\"}]}',1,'RUj6iJggS3iEKsUx5C07Ig','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(0,'Test share buttons and dialogs',7,NULL,NULL,'ShareSpec','{\"fields\":[],\"topic\":\"4nxQHjdNQVmy551UB6S4cQ\"}',1,'share-spec-stream-uuid','com.unifina.domain.data.Stream','2017-05-03 10:25:17','2017-05-03 10:25:17',1,b'0',NULL,NULL),
	(0,'Helsinki tram locations etc.',7,NULL,NULL,'Public transport demo','{\"fields\":[{\"name\":\"veh\",\"type\":\"string\"},{\"name\":\"lat\",\"type\":\"number\"},{\"name\":\"long\",\"type\":\"number\"},{\"name\":\"spd\",\"type\":\"number\"},{\"name\":\"hdg\",\"type\":\"number\"},{\"name\":\"odo\",\"type\":\"number\"},{\"name\":\"dl\",\"type\":\"number\"},{\"name\":\"desi\",\"type\":\"string\"}]}',1,'YpTAPDbvSAmj-iCUYz-dxA','com.unifina.domain.data.Stream','2016-05-18 18:06:00','2016-05-18 18:06:00',1,b'0',NULL,NULL);

/*!40000 ALTER TABLE `stream` ENABLE KEYS */;
UNLOCK TABLES;


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

LOCK TABLES `tour_user` WRITE;
/*!40000 ALTER TABLE `tour_user` DISABLE KEYS */;

INSERT INTO `tour_user` (`user_id`, `tour_number`, `completed_at`)
VALUES
	(1,0,'2016-04-11 15:00:00'),
	(1,1,'2016-04-11 15:00:00'),
	(1,2,'2016-04-11 15:00:00'),
	(2,0,'2016-04-11 15:00:00'),
	(2,1,'2016-04-11 15:00:00'),
	(2,2,'2016-04-11 15:00:00'),
	(3,0,'2016-04-11 15:00:00'),
	(3,1,'2016-04-11 15:00:00'),
	(3,2,'2016-04-11 15:00:00');

/*!40000 ALTER TABLE `tour_user` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
