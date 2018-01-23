/*
 Navicat Premium Data Transfer

 Source Server         : ARL PostGreSQL VM (w0lxsfigssa01 )
 Source Server Type    : PostgreSQL
 Source Server Version : 100001
 Source Host           : w0lxsfigssa01:5432
 Source Catalog        : dev
 Source Schema         : pd_wbgtravel

 Target Server Type    : PostgreSQL
 Target Server Version : 100001
 File Encoding         : 65001

 Date: 23/01/2018 13:23:31
*/


-- ----------------------------
-- Sequence structure for agendas_agenda_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "pd_wbgtravel"."agendas_agenda_id_seq";
CREATE SEQUENCE "pd_wbgtravel"."agendas_agenda_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for cities_city_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "pd_wbgtravel"."cities_city_id_seq";
CREATE SEQUENCE "pd_wbgtravel"."cities_city_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for dev_events_event_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "pd_wbgtravel"."dev_events_event_id_seq";
CREATE SEQUENCE "pd_wbgtravel"."dev_events_event_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 32767
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for people_person_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "pd_wbgtravel"."people_person_id_seq";
CREATE SEQUENCE "pd_wbgtravel"."people_person_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for trips_trip_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "pd_wbgtravel"."trips_trip_id_seq";
CREATE SEQUENCE "pd_wbgtravel"."trips_trip_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for agendas
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."agendas";
CREATE TABLE "pd_wbgtravel"."agendas" (
  "agenda_id" int4 NOT NULL DEFAULT nextval('"pd_wbgtravel".agendas_agenda_id_seq'::regclass),
  "agenda_type" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "short_title" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "long_title" varchar(50) COLLATE "pg_catalog"."default",
  "topics" varchar(50) COLLATE "pg_catalog"."default",
  "calendar_schedule" timestamptz(6)[],
  "location" varchar(255) COLLATE "pg_catalog"."default",
  "description" text COLLATE "pg_catalog"."default",
  "time_created" timestamp(6) DEFAULT now()
)
;
COMMENT ON COLUMN "pd_wbgtravel"."agendas"."agenda_type" IS 'mission, meeting, event';
COMMENT ON COLUMN "pd_wbgtravel"."agendas"."short_title" IS 'eg, SoFI 2017';
COMMENT ON COLUMN "pd_wbgtravel"."agendas"."long_title" IS 'eg, Mastercard Symposium on Financial Inclusion 2017';
COMMENT ON COLUMN "pd_wbgtravel"."agendas"."topics" IS 'csv strings or keywords';
COMMENT ON COLUMN "pd_wbgtravel"."agendas"."calendar_schedule" IS 'Date, Time, Timezone of Agenda.  Array[Start,End]';

-- ----------------------------
-- Records of agendas
-- ----------------------------
INSERT INTO "pd_wbgtravel"."agendas" VALUES (143, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2017-03-30 00:00:00-04","2017-04-05 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (144, 'event', 'World Finance Summit', 'World Finance Summit', NULL, '{"2018-02-07 00:00:00-05","2018-02-10 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (145, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2018-04-03 00:00:00-04","2018-04-23 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (146, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2017-02-13 00:00:00-05","2017-02-14 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (147, 'meeting', 'Private meeting', 'Private meeting', NULL, '{"2017-09-19 00:00:00-04","2017-09-27 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (148, 'meeting', 'G20 sub meeting', 'G20 sub meeting', NULL, '{"2018-03-23 00:00:00-04","2018-04-05 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (149, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2018-03-09 00:00:00-05","2018-03-14 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (150, 'event', 'World Finance Summit', 'World Finance Summit', NULL, '{"2017-05-15 00:00:00-04","2017-05-25 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (151, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-02-12 00:00:00-05","2017-02-22 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (152, 'event', 'International Develo', 'International Development Summit', NULL, '{"2017-01-21 00:00:00-05","2017-01-31 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (153, 'event', 'International Develo', 'International Development Summit', NULL, '{"2017-03-25 00:00:00-04","2017-04-07 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (154, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2018-01-21 00:00:00-05","2018-01-23 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (155, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2018-03-19 00:00:00-04","2018-04-04 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (156, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2018-02-18 00:00:00-05","2018-03-08 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (157, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2017-01-11 00:00:00-05","2017-01-21 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (158, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-10-30 00:00:00-04","2017-11-05 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (159, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-12-23 00:00:00-05","2017-12-27 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (160, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2017-10-30 00:00:00-04","2017-11-18 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (161, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2017-08-18 00:00:00-04","2017-08-28 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (162, 'event', 'World Finance Summit', 'World Finance Summit', NULL, '{"2017-09-04 00:00:00-04","2017-09-18 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (163, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-03-17 00:00:00-04","2017-03-27 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (164, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-02-20 00:00:00-05","2017-02-25 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (165, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2017-06-05 00:00:00-04","2017-06-11 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (166, 'meeting', 'IFC meeting', 'IFC meeting', NULL, '{"2017-04-14 00:00:00-04","2017-04-24 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (167, 'meeting', 'IFC meeting', 'IFC meeting', NULL, '{"2017-06-08 00:00:00-04","2017-06-17 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (168, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2017-02-23 00:00:00-05","2017-03-11 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (169, 'meeting', 'Private meeting', 'Private meeting', NULL, '{"2018-01-15 00:00:00-05","2018-01-18 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (170, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2018-04-01 00:00:00-04","2018-04-05 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (171, 'meeting', 'G20 sub meeting', 'G20 sub meeting', NULL, '{"2017-07-31 00:00:00-04","2017-08-19 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (172, 'meeting', 'IFC meeting', 'IFC meeting', NULL, '{"2017-01-02 00:00:00-05","2017-01-15 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (173, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2017-11-09 00:00:00-05","2017-11-23 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (174, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-11-09 00:00:00-05","2017-11-28 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (175, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-10-17 00:00:00-04","2017-10-31 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (176, 'meeting', 'Private meeting', 'Private meeting', NULL, '{"2017-03-10 00:00:00-05","2017-03-13 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (177, 'meeting', 'IFC meeting', 'IFC meeting', NULL, '{"2018-04-08 00:00:00-04","2018-04-24 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (178, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-07-19 00:00:00-04","2017-07-25 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (179, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-07-17 00:00:00-04","2017-07-27 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (180, 'meeting', 'G20 sub meeting', 'G20 sub meeting', NULL, '{"2017-01-22 00:00:00-05","2017-01-23 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (181, 'meeting', 'IFC meeting', 'IFC meeting', NULL, '{"2017-02-26 00:00:00-05","2017-03-01 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (182, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-02-04 00:00:00-05","2017-02-20 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (183, 'event', 'International Develo', 'International Development Summit', NULL, '{"2017-09-19 00:00:00-04","2017-09-29 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (184, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2017-07-24 00:00:00-04","2017-08-11 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (185, 'event', 'Trade summit', 'Trade summit', NULL, '{"2018-01-15 00:00:00-05","2018-01-19 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (186, 'event', 'Trade summit', 'Trade summit', NULL, '{"2018-01-18 00:00:00-05","2018-01-29 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (187, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2017-03-15 00:00:00-04","2017-03-18 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (188, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2017-09-22 00:00:00-04","2017-09-25 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (189, 'meeting', 'G20 sub meeting', 'G20 sub meeting', NULL, '{"2017-02-16 00:00:00-05","2017-03-06 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (190, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2018-03-25 00:00:00-04","2018-04-14 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (191, 'event', 'Trade summit', 'Trade summit', NULL, '{"2018-02-18 00:00:00-05","2018-02-28 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (192, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-05-20 00:00:00-04","2017-05-21 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (193, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2017-10-12 00:00:00-04","2017-10-13 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (194, 'meeting', 'Private meeting', 'Private meeting', NULL, '{"2018-02-03 00:00:00-05","2018-02-10 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (195, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-04-15 00:00:00-04","2017-04-25 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (196, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-01-28 00:00:00-05","2017-02-13 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (197, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2017-08-27 00:00:00-04","2017-09-04 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (198, 'meeting', 'Private meeting', 'Private meeting', NULL, '{"2017-06-16 00:00:00-04","2017-06-26 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (199, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2017-08-12 00:00:00-04","2017-08-27 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (200, 'event', 'Trade summit', 'Trade summit', NULL, '{"2017-07-17 00:00:00-04","2017-07-29 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (201, 'event', 'Trade summit', 'Trade summit', NULL, '{"2018-02-05 00:00:00-05","2018-02-25 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (202, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2018-03-23 00:00:00-04","2018-04-10 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (203, 'event', 'International Develo', 'International Development Summit', NULL, '{"2017-07-16 00:00:00-04","2017-07-28 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (204, 'meeting', 'World Bank internal ', 'World Bank internal meeting', NULL, '{"2017-12-30 00:00:00-05","2018-01-12 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (205, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2017-12-22 00:00:00-05","2018-01-10 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (206, 'event', 'International Develo', 'International Development Summit', NULL, '{"2017-02-06 00:00:00-05","2017-02-24 00:00:00-05"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (207, 'meeting', 'Private meeting', 'Private meeting', NULL, '{"2017-07-12 00:00:00-04","2017-07-13 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (208, 'event', 'Technology and Devel', 'Technology and Development Symposium', NULL, '{"2017-03-13 00:00:00-04","2017-03-23 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (209, 'event', 'Bi-national conferen', 'Bi-national conference', NULL, '{"2017-09-11 00:00:00-04","2017-09-24 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (210, 'meeting', 'Non-official event', 'Non-official event', NULL, '{"2017-07-18 00:00:00-04","2017-08-06 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');
INSERT INTO "pd_wbgtravel"."agendas" VALUES (211, 'event', 'International Develo', 'International Development Summit', NULL, '{"2017-04-26 00:00:00-04","2017-05-14 00:00:00-04"}', NULL, NULL, '2018-01-23 02:23:34.444123');

-- ----------------------------
-- Table structure for cities
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."cities";
CREATE TABLE "pd_wbgtravel"."cities" (
  "city_id" int4 NOT NULL DEFAULT nextval('"pd_wbgtravel".cities_city_id_seq'::regclass),
  "city_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "country_name" varchar(50) COLLATE "pg_catalog"."default",
  "country_ISO3" varchar(3) COLLATE "pg_catalog"."default",
  "latitude" numeric(12,9) NOT NULL,
  "longitude" numeric(12,9) NOT NULL
)
;

-- ----------------------------
-- Records of cities
-- ----------------------------
INSERT INTO "pd_wbgtravel"."cities" VALUES (137, 'Muscat', 'Oman', NULL, 24.000000000, 59.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (138, 'Pyatigorsk', 'Russia', NULL, 44.000000000, 43.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (139, 'Biu', 'Nigeria', NULL, 11.000000000, 12.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (140, 'Kedougou', 'Senegal', NULL, 13.000000000, -12.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (141, 'Taoudenni', 'Mali', NULL, 23.000000000, -4.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (142, 'Ferrenafe', 'Peru', NULL, -7.000000000, -80.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (143, 'Kanyato', 'Tanzania', NULL, -4.000000000, 30.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (144, 'Adelaide', 'Australia', NULL, -35.000000000, 139.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (145, 'Nyac', 'United States of America', NULL, 61.000000000, -160.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (146, 'Chiromo', 'Malawi', NULL, -17.000000000, 35.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (147, 'Ghadamis', 'Libya', NULL, 30.000000000, 10.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (148, 'Grand Island', 'United States of America', NULL, 41.000000000, -98.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (149, 'Satipo', 'Peru', NULL, -11.000000000, -75.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (150, 'San Carlos de Bariloche', 'Argentina', NULL, -41.000000000, -71.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (151, 'Caxito', 'Angola', NULL, -9.000000000, 14.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (152, 'New York', 'United States', NULL, 41.000000000, -74.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (153, 'Walla Walla', 'United States of America', NULL, 46.000000000, -118.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (154, 'Cabinda', 'Angola', NULL, -6.000000000, 12.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (155, 'Wollongong', 'Australia', NULL, -34.000000000, 151.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (156, 'Kibungo', 'Rwanda', NULL, -2.000000000, 31.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (157, 'Fresno', 'United States of America', NULL, 37.000000000, -120.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (158, 'Qasserine', 'Tunisia', NULL, 35.000000000, 9.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (159, 'Sumy', 'Ukraine', NULL, 51.000000000, 35.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (160, 'Swakopmund', 'Namibia', NULL, -23.000000000, 15.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (161, 'Bataysk', 'Russia', NULL, 47.000000000, 40.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (162, 'Antsirabe', 'Madagascar', NULL, -20.000000000, 47.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (163, 'Kumi', 'Uganda', NULL, 1.000000000, 34.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (164, 'Yamba', 'Australia', NULL, -29.000000000, 153.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (165, 'Richmond', 'Australia', NULL, -21.000000000, 143.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (166, 'Qoqon', 'Uzbekistan', NULL, 41.000000000, 71.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (167, 'Cleveland', 'United States of America', NULL, 41.000000000, -82.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (168, 'Kendu Bay', 'Kenya', NULL, 0.000000000, 35.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (169, 'Kinshasa', 'Dem. Rep. Congo', NULL, -4.000000000, 15.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (170, 'Szekesfehervar', 'Hungary', NULL, 47.000000000, 18.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (171, 'Bajram Curri', 'Albania', NULL, 42.000000000, 20.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (172, 'Witu', 'Kenya', NULL, -2.000000000, 40.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (173, 'Kimhyonggwon', 'North Korea', NULL, 41.000000000, 128.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (174, 'Scottsdale', 'United States of America', NULL, 34.000000000, -112.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (175, 'Johannesburg', 'South Africa', NULL, -26.000000000, 28.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (176, 'Elista', 'Russia', NULL, 46.000000000, 44.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (177, 'Tongue', 'Guinea', NULL, 11.000000000, -12.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (178, 'London', 'United Kingdom', NULL, 52.000000000, 0.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (179, 'Ndele', 'Central African Republic', NULL, 8.000000000, 21.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (180, 'Nola', 'Central African Republic', NULL, 4.000000000, 16.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (181, 'Moroto', 'Uganda', NULL, 3.000000000, 35.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (182, 'Moanda', 'Congo (Kinshasa)', NULL, -6.000000000, 12.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (183, 'Houston', 'United States of America', NULL, 30.000000000, -95.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (184, 'Brasilia', 'Brazil', NULL, -16.000000000, -48.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (185, 'Erzincan', 'Turkey', NULL, 40.000000000, 39.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (186, 'Berlin', 'Germany', NULL, 53.000000000, 13.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (187, 'Blida', 'Algeria', NULL, 36.000000000, 3.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (188, 'Jullundur', 'India', NULL, 31.000000000, 76.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (189, 'Childress', 'United States of America', NULL, 34.000000000, -100.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (190, 'Tolanaro', 'Madagascar', NULL, -25.000000000, 47.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (191, 'Moscow', 'Russia', NULL, 56.000000000, 38.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (192, 'Argentia', 'Canada', NULL, 47.000000000, -54.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (193, 'Agua Prieta', 'Mexico', NULL, 31.000000000, -110.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (194, 'Fort Collins', 'United States of America', NULL, 41.000000000, -105.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (195, 'Atherton', 'Australia', NULL, -17.000000000, 145.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (196, 'Nakasongola', 'Uganda', NULL, 1.000000000, 32.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (197, 'Green Bay', 'United States of America', NULL, 45.000000000, -88.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (198, 'Shashemene', 'Ethiopia', NULL, 7.000000000, 39.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (199, 'Beijing', 'China', NULL, 40.000000000, 116.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (200, 'Ntungamo', 'Uganda', NULL, -1.000000000, 30.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (201, 'San Marcos', 'Guatemala', NULL, 15.000000000, -92.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (202, 'Phnum Tbeng Meanchey', 'Cambodia', NULL, 14.000000000, 105.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (203, 'Kakata', 'Liberia', NULL, 7.000000000, -10.000000000);
INSERT INTO "pd_wbgtravel"."cities" VALUES (204, 'Kropotkin', 'Russia', NULL, 45.000000000, 41.000000000);

-- ----------------------------
-- Table structure for dev_events
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."dev_events";
CREATE TABLE "pd_wbgtravel"."dev_events" (
  "Person" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "Organization" varchar(255) COLLATE "pg_catalog"."default",
  "City of visit" varchar(255) COLLATE "pg_catalog"."default",
  "Country of visit" varchar(255) COLLATE "pg_catalog"."default",
  "Counterpart" varchar(255) COLLATE "pg_catalog"."default",
  "Visit start" date,
  "Visit end" date,
  "Visit month" varchar(255) COLLATE "pg_catalog"."default",
  "Lat" numeric(255),
  "Long" numeric(255),
  "Event" varchar(255) COLLATE "pg_catalog"."default",
  "file" varchar(255) COLLATE "pg_catalog"."default",
  "event_id" int2 NOT NULL DEFAULT nextval('"pd_wbgtravel".dev_events_event_id_seq'::regclass)
)
;

-- ----------------------------
-- Records of dev_events
-- ----------------------------
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Brasilia', 'Brazil', 'Michel Temer', '2017-06-16', '2017-06-26', 'June', -16, -48, 'Private meeting', 'headshots/circles/Joaquim Levy.png', 74);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Brasilia', 'Brazil', 'Michel Temer', '2017-07-17', '2017-07-27', 'July', -16, -48, 'Bi-national conference', 'headshots/circles/Joaquim Levy.png', 75);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Berlin', 'Germany', 'Angela Merkel', '2017-02-12', '2017-02-22', 'February', 53, 13, 'Trade summit', 'headshots/circles/Kristalina Georgieva.png', 76);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Johannesburg', 'South Africa', 'Jacob Zuma', '2017-08-18', '2017-08-28', 'August', -26, 28, 'Non-official event', 'headshots/circles/Kristalina Georgieva.png', 77);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Kinshasa', 'Dem. Rep. Congo', 'Antonio Guterres', '2017-04-14', '2017-04-24', 'April', -4, 15, 'IFC meeting', 'headshots/circles/Paul Romer.png', 78);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'London', 'United Kingdom', 'Theresa May', '2017-09-19', '2017-09-29', 'September', 52, 0, 'International Development Summit', 'headshots/circles/Paul Romer.png', 79);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Beijing', 'China', 'Xi Jinping', '2017-03-13', '2017-03-23', 'March', 40, 116, 'Technology and Development Symposium', 'headshots/circles/Philippe Le Houerou.png', 80);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Nola', 'Central African Republic', 'Emmanuel Macron', '2017-10-30', '2017-11-18', 'October', 4, 16, 'Technology and Development Symposium', 'headshots/circles/Jim Yong Kim.png', 81);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Qasserine', 'Tunisia', 'Xi Jinping', '2018-01-21', '2018-01-23', 'January', 35, 9, 'Technology and Development Symposium', 'headshots/circles/Jim Yong Kim.png', 82);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Ghadamis', 'Libya', 'Angela Merkel', '2018-04-01', '2018-04-05', 'April', 30, 10, 'Bi-national conference', 'headshots/circles/Jim Yong Kim.png', 83);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Kanyato', 'Tanzania', 'Emmanuel Macron', '2017-03-10', '2017-03-13', 'March', -4, 30, 'Private meeting', 'headshots/circles/Paul Romer.png', 84);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Qoqon', 'Uzbekistan', 'Michel Temer', '2017-07-19', '2017-07-25', 'July', 41, 71, 'Trade summit', 'headshots/circles/Jim Yong Kim.png', 85);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Kumi', 'Uganda', 'Donald Trump', '2017-07-17', '2017-07-29', 'July', 1, 34, 'Trade summit', 'headshots/circles/Kristalina Georgieva.png', 86);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Nyac', 'United States of America', 'Theresa May', '2017-03-15', '2017-03-18', 'March', 61, -160, 'Technology and Development Symposium', 'headshots/circles/Jim Yong Kim.png', 87);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Kedougou', 'Senegal', 'Donald Trump', '2017-03-25', '2017-04-07', 'March', 13, -12, 'International Development Summit', 'headshots/circles/Jim Yong Kim.png', 88);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Kendu Bay', 'Kenya', 'Theresa May', '2017-02-13', '2017-02-14', 'February', 0, 35, 'World Bank internal meeting', 'headshots/circles/Philippe Le Houerou.png', 89);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Biu', 'Nigeria', 'Donald Trump', '2017-04-15', '2017-04-25', 'April', 11, 12, 'Trade summit', 'headshots/circles/Paul Romer.png', 90);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Richmond', 'Australia', 'Xi Jinping', '2017-08-12', '2017-08-27', 'August', -21, 143, 'World Bank internal meeting', 'headshots/circles/Joaquim Levy.png', 91);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Fresno', 'United States of America', 'Emmanuel Macron', '2017-07-24', '2017-08-11', 'July', 37, -120, 'Technology and Development Symposium', 'headshots/circles/Jim Yong Kim.png', 92);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Argentia', 'Canada', 'Xi Jinping', '2017-09-19', '2017-09-27', 'September', 47, -54, 'Private meeting', 'headshots/circles/Joaquim Levy.png', 93);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Phnum Tbeng Meanchey', 'Cambodia', 'Vladimir Putin', '2017-10-17', '2017-10-31', 'October', 14, 105, 'Trade summit', 'headshots/circles/Joaquim Levy.png', 94);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Adelaide', 'Australia', 'Jacob Zuma', '2017-12-23', '2017-12-27', 'December', -35, 139, 'Bi-national conference', 'headshots/circles/Jim Yong Kim.png', 95);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Ntungamo', 'Uganda', 'Vladimir Putin', '2017-01-21', '2017-01-31', 'January', -1, 30, 'International Development Summit', 'headshots/circles/Jim Yong Kim.png', 96);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Kibungo', 'Rwanda', 'Antonio Guterres', '2018-03-25', '2018-04-14', 'March', -2, 31, 'Non-official event', 'headshots/circles/Kristalina Georgieva.png', 97);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Tongue', 'Guinea', 'Vladimir Putin', '2017-09-04', '2017-09-18', 'September', 11, -12, 'World Finance Summit', 'headshots/circles/Joaquim Levy.png', 98);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Jullundur', 'India', 'Antonio Guterres', '2018-01-15', '2018-01-18', 'January', 31, 76, 'Private meeting', 'headshots/circles/Joaquim Levy.png', 99);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Shashemene', 'Ethiopia', 'Emmanuel Macron', '2018-02-18', '2018-03-08', 'February', 7, 39, 'World Bank internal meeting', 'headshots/circles/Joaquim Levy.png', 100);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Cleveland', 'United States of America', 'Antonio Guterres', '2017-07-31', '2017-08-19', 'July', 41, -82, 'G20 sub meeting', 'headshots/circles/Joaquim Levy.png', 101);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Antsirabe', 'Madagascar', 'Angela Merkel', '2018-01-15', '2018-01-19', 'January', -20, 47, 'Trade summit', 'headshots/circles/Kristalina Georgieva.png', 102);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Swakopmund', 'Namibia', 'Michel Temer', '2017-11-09', '2017-11-23', 'November', -23, 15, 'World Bank internal meeting', 'headshots/circles/Joaquim Levy.png', 103);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Grand Island', 'United States of America', 'Theresa May', '2018-02-03', '2018-02-10', 'February', 41, -98, 'Private meeting', 'headshots/circles/Joaquim Levy.png', 104);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Szekesfehervar', 'Hungary', 'Emmanuel Macron', '2018-03-19', '2018-04-04', 'March', 47, 18, 'World Bank internal meeting', 'headshots/circles/Kristalina Georgieva.png', 105);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'San Marcos', 'Guatemala', 'Donald Trump', '2017-05-20', '2017-05-21', 'May', 15, -92, 'Bi-national conference', 'headshots/circles/Jim Yong Kim.png', 106);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Sumy', 'Ukraine', 'Theresa May', '2018-03-09', '2018-03-14', 'March', 51, 35, 'Technology and Development Symposium', 'headshots/circles/Philippe Le Houerou.png', 107);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Atherton', 'Australia', 'Donald Trump', '2017-07-16', '2017-07-28', 'July', -17, 145, 'International Development Summit', 'headshots/circles/Jim Yong Kim.png', 108);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Elista', 'Russia', 'Theresa May', '2017-02-06', '2017-02-24', 'February', 46, 44, 'International Development Summit', 'headshots/circles/Jim Yong Kim.png', 109);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Tolanaro', 'Madagascar', 'Jacob Zuma', '2017-10-12', '2017-10-13', 'October', -25, 47, 'Technology and Development Symposium', 'headshots/circles/Joaquim Levy.png', 110);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Moanda', 'Congo (Kinshasa)', 'Antonio Guterres', '2017-06-08', '2017-06-17', 'June', -6, 12, 'IFC meeting', 'headshots/circles/Jim Yong Kim.png', 111);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Muscat', 'Oman', 'Michel Temer', '2017-10-30', '2017-11-05', 'October', 24, 59, 'Bi-national conference', 'headshots/circles/Kristalina Georgieva.png', 112);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Taoudenni', 'Mali', 'Angela Merkel', '2017-12-30', '2018-01-12', 'December', 23, -4, 'World Bank internal meeting', 'headshots/circles/Joaquim Levy.png', 113);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Chiromo', 'Malawi', 'Michel Temer', '2017-01-28', '2017-02-13', 'January', -17, 35, 'Trade summit', 'headshots/circles/Jim Yong Kim.png', 114);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Ferrenafe', 'Peru', 'Jacob Zuma', '2017-02-23', '2017-03-11', 'February', -7, -80, 'Non-official event', 'headshots/circles/Paul Romer.png', 115);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Blida', 'Algeria', 'Angela Merkel', '2017-06-05', '2017-06-11', 'June', 36, 3, 'Non-official event', 'headshots/circles/Jim Yong Kim.png', 116);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Bajram Curri', 'Albania', 'Xi Jinping', '2018-04-03', '2018-04-23', 'April', 42, 20, 'Technology and Development Symposium', 'headshots/circles/Jim Yong Kim.png', 117);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Ndele', 'Central African Republic', 'Theresa May', '2017-02-04', '2017-02-20', 'February', 8, 21, 'Bi-national conference', 'headshots/circles/Paul Romer.png', 118);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Childress', 'United States of America', 'Donald Trump', '2018-02-18', '2018-02-28', 'February', 34, -100, 'Trade summit', 'headshots/circles/Philippe Le Houerou.png', 119);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Wollongong', 'Australia', 'Jacob Zuma', '2017-02-16', '2017-03-06', 'February', -34, 151, 'G20 sub meeting', 'headshots/circles/Paul Romer.png', 120);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Scottsdale', 'United States of America', 'Donald Trump', '2018-03-23', '2018-04-10', 'March', 34, -112, 'Bi-national conference', 'headshots/circles/Philippe Le Houerou.png', 121);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Caxito', 'Angola', 'Theresa May', '2017-02-26', '2017-03-01', 'February', -9, 14, 'IFC meeting', 'headshots/circles/Jim Yong Kim.png', 122);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Houston', 'United States of America', 'Jacob Zuma', '2017-08-27', '2017-09-04', 'August', 30, -95, 'Technology and Development Symposium', 'headshots/circles/Jim Yong Kim.png', 123);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Erzincan', 'Turkey', 'Michel Temer', '2018-02-07', '2018-02-10', 'February', 40, 39, 'World Finance Summit', 'headshots/circles/Kristalina Georgieva.png', 124);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Kakata', 'Liberia', 'Antonio Guterres', '2017-01-22', '2017-01-23', 'January', 7, -10, 'G20 sub meeting', 'headshots/circles/Jim Yong Kim.png', 125);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Green Bay', 'United States of America', 'Xi Jinping', '2017-03-17', '2017-03-27', 'March', 45, -88, 'Bi-national conference', 'headshots/circles/Jim Yong Kim.png', 126);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Agua Prieta', 'Mexico', 'Antonio Guterres', '2017-11-09', '2017-11-28', 'November', 31, -110, 'Trade summit', 'headshots/circles/Philippe Le Houerou.png', 127);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'San Carlos de Bariloche', 'Argentina', 'Antonio Guterres', '2017-07-12', '2017-07-13', 'July', -41, -71, 'Private meeting', 'headshots/circles/Jim Yong Kim.png', 128);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Walla Walla', 'United States of America', 'Michel Temer', '2017-12-22', '2018-01-10', 'December', 46, -118, 'Non-official event', 'headshots/circles/Kristalina Georgieva.png', 129);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Moroto', 'Uganda', 'Michel Temer', '2018-03-23', '2018-04-05', 'March', 3, 35, 'G20 sub meeting', 'headshots/circles/Joaquim Levy.png', 130);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Cabinda', 'Angola', 'Emmanuel Macron', '2017-09-22', '2017-09-25', 'September', -6, 12, 'World Bank internal meeting', 'headshots/circles/Joaquim Levy.png', 131);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Fort Collins', 'United States of America', 'Emmanuel Macron', '2017-01-02', '2017-01-15', 'January', 41, -105, 'IFC meeting', 'headshots/circles/Joaquim Levy.png', 132);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Philippe Le Houerou', 'IFC', 'Bataysk', 'Russia', 'Xi Jinping', '2017-03-30', '2017-04-05', 'March', 47, 40, 'Non-official event', 'headshots/circles/Philippe Le Houerou.png', 133);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Yamba', 'Australia', 'Angela Merkel', '2018-04-08', '2018-04-24', 'April', -29, 153, 'IFC meeting', 'headshots/circles/Kristalina Georgieva.png', 134);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Kristalina Georgieva', 'World Bank', 'Kimhyonggwon', 'North Korea', 'Jacob Zuma', '2017-02-20', '2017-02-25', 'February', 41, 128, 'Trade summit', 'headshots/circles/Kristalina Georgieva.png', 135);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Kropotkin', 'Russia', 'Emmanuel Macron', '2017-04-26', '2017-05-14', 'April', 45, 41, 'International Development Summit', 'headshots/circles/Joaquim Levy.png', 136);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Pyatigorsk', 'Russia', 'Michel Temer', '2017-09-11', '2017-09-24', 'September', 44, 43, 'Bi-national conference', 'headshots/circles/Paul Romer.png', 137);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Satipo', 'Peru', 'Angela Merkel', '2018-01-18', '2018-01-29', 'January', -11, -75, 'Trade summit', 'headshots/circles/Paul Romer.png', 138);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Joaquim Levy', 'World Bank', 'Nakasongola', 'Uganda', 'Jacob Zuma', '2018-02-05', '2018-02-25', 'February', 1, 32, 'Trade summit', 'headshots/circles/Joaquim Levy.png', 139);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Paul Romer', 'World Bank', 'Witu', 'Kenya', 'Antonio Guterres', '2017-07-18', '2017-08-06', 'July', -2, 40, 'Non-official event', 'headshots/circles/Paul Romer.png', 140);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'Moscow', 'Russia', 'Vladimir Putin', '2017-01-11', '2017-01-21', 'January', 56, 38, 'World Bank internal meeting', 'headshots/circles/Jim Yong Kim.png', 73);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'New York', 'United States', 'Donald Trump', '2017-05-15', '2017-05-25', 'May', 41, -74, 'World Finance Summit', 'headshots/circles/Jim Yong Kim.png', 146);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'New York', 'United States', 'Donald Trump', '2017-05-15', '2017-05-25', 'May', 41, -74, 'World Finance Summit', 'headshots/circles/Jim Yong Kim.png', 147);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'New York', 'United States', 'Donald Trump', '2017-05-15', '2017-05-25', 'May', 41, -74, 'World Finance Summit', 'headshots/circles/Jim Yong Kim.png', 148);
INSERT INTO "pd_wbgtravel"."dev_events" VALUES ('Jim Yong Kim', 'World Bank', 'New York', 'United States', 'Donald Trump', '2017-05-15', '2017-05-25', 'May', 41, -74, 'World Finance Summit', 'headshots/circles/Jim Yong Kim.png', 149);

-- ----------------------------
-- Table structure for people
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."people";
CREATE TABLE "pd_wbgtravel"."people" (
  "person_id" int4 NOT NULL DEFAULT nextval('"pd_wbgtravel".people_person_id_seq'::regclass),
  "full_name" varchar(50) COLLATE "pg_catalog"."default",
  "short_name" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "title" varchar(20) COLLATE "pg_catalog"."default",
  "organization" varchar(20) COLLATE "pg_catalog"."default",
  "sub_organization" varchar(20) COLLATE "pg_catalog"."default",
  "image_file" varchar(255) COLLATE "pg_catalog"."default",
  "is_wbg" int2,
  "time_created" timestamp(6) NOT NULL DEFAULT now()
)
;

-- ----------------------------
-- Records of people
-- ----------------------------
INSERT INTO "pd_wbgtravel"."people" VALUES (30, NULL, 'Paul Romer', NULL, 'World Bank', NULL, 'headshots/circles/Paul Romer.png', 1, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (31, NULL, 'Kristalina Georgieva', NULL, 'World Bank', NULL, 'headshots/circles/Kristalina Georgieva.png', 1, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (32, NULL, 'Jim Yong Kim', NULL, 'World Bank', NULL, 'headshots/circles/Jim Yong Kim.png', 1, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (33, NULL, 'Philippe Le Houerou', NULL, 'IFC', NULL, 'headshots/circles/Philippe Le Houerou.png', 1, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (34, NULL, 'Joaquim Levy', NULL, 'World Bank', NULL, 'headshots/circles/Joaquim Levy.png', 1, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (35, NULL, 'Theresa May', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (36, NULL, 'Jacob Zuma', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (37, NULL, 'Vladimir Putin', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (38, NULL, 'Xi Jinping', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (39, NULL, 'Angela Merkel', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (40, NULL, 'Donald Trump', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (41, NULL, 'Michel Temer', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (42, NULL, 'Emmanuel Macron', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');
INSERT INTO "pd_wbgtravel"."people" VALUES (43, NULL, 'Antonio Guterres', NULL, 'Unknown', NULL, NULL, 0, '2018-01-23 02:23:34.018005');

-- ----------------------------
-- Table structure for trip_agendas
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."trip_agendas";
CREATE TABLE "pd_wbgtravel"."trip_agendas" (
  "trip_id" int4 NOT NULL,
  "agenda_id" int4 NOT NULL,
  "display_rank_order" int2 NOT NULL DEFAULT 0
)
;

-- ----------------------------
-- Records of trip_agendas
-- ----------------------------
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (265, 172, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (203, 172, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (225, 157, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (177, 157, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (180, 152, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (226, 152, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (276, 180, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (182, 180, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (163, 196, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (252, 196, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (215, 182, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (148, 182, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (172, 206, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (213, 206, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (159, 151, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (240, 151, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (212, 146, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (185, 146, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (144, 189, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (218, 189, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (219, 164, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (156, 164, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (216, 168, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (141, 168, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (166, 181, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (210, 181, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (260, 176, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (142, 176, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (189, 208, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (234, 208, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (162, 187, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (208, 187, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (179, 163, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (233, 163, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (243, 153, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (160, 153, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (184, 143, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (229, 143, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (145, 166, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (271, 166, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (242, 195, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (140, 195, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (267, 211, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (207, 211, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (244, 150, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (167, 150, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (181, 192, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (249, 192, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (241, 165, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (176, 165, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (174, 167, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (273, 167, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (198, 198, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (257, 198, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (165, 207, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (268, 207, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (248, 203, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (178, 203, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (258, 179, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (199, 179, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (245, 200, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (153, 200, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (146, 210, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (272, 210, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (255, 178, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (170, 178, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (262, 184, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (168, 184, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (195, 171, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (270, 171, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (194, 199, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (230, 199, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (220, 161, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (157, 161, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (221, 197, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (175, 197, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (196, 162, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (224, 162, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (139, 209, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (251, 209, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (232, 147, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (202, 147, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (214, 183, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (147, 183, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (192, 188, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (261, 188, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (201, 193, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (222, 193, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (206, 175, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (227, 175, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (250, 158, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (149, 158, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (173, 160, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (264, 160, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (254, 173, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (193, 173, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (275, 174, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (188, 174, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (150, 205, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (253, 205, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (217, 159, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (161, 159, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (235, 204, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (190, 204, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (274, 169, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (200, 169, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (152, 185, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (238, 185, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (143, 186, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (237, 186, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (169, 154, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (228, 154, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (209, 194, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (191, 194, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (204, 201, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (223, 201, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (259, 144, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (158, 144, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (247, 191, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (187, 191, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (205, 156, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (266, 156, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (211, 149, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (183, 149, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (155, 155, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (263, 155, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (256, 148, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (197, 148, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (186, 202, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (246, 202, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (269, 190, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (151, 190, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (236, 170, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (164, 170, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (171, 145, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (231, 145, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (154, 177, 0);
INSERT INTO "pd_wbgtravel"."trip_agendas" VALUES (239, 177, 0);

-- ----------------------------
-- Table structure for trip_meetings
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."trip_meetings";
CREATE TABLE "pd_wbgtravel"."trip_meetings" (
  "meeting_person_id" int4 NOT NULL,
  "travelers_trip_id" int4 NOT NULL,
  "topic" varchar(50) COLLATE "pg_catalog"."default",
  "description" text COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "pd_wbgtravel"."trip_meetings"."meeting_person_id" IS 'ID of person I am meeting';
COMMENT ON COLUMN "pd_wbgtravel"."trip_meetings"."travelers_trip_id" IS 'ID of my trip';

-- ----------------------------
-- Records of trip_meetings
-- ----------------------------
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 147, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 148, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 162, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 166, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 172, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 183, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 185, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (35, 191, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 141, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 144, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 156, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 157, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 161, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 175, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 201, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (36, 204, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (37, 177, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (37, 180, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (37, 196, 'World Finance Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (37, 206, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 169, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 171, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 179, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 184, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 189, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 194, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (38, 202, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 143, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 152, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 154, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 159, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 164, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 176, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (39, 190, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 140, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 153, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 160, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 167, 'World Finance Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 178, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 181, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 186, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (40, 187, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 139, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 149, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 150, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 158, 'World Finance Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 163, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 170, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 193, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 197, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 198, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (41, 199, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 142, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 155, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 168, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 173, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 192, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 203, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 205, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (42, 207, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 145, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 146, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 151, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 165, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 174, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 182, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 188, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 195, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (43, 200, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 214, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 215, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 216, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 218, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 237, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 242, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 251, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 260, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 271, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (30, 272, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 219, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 220, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 238, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 239, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 240, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 245, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 250, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 253, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 259, 'World Finance Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 263, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (31, 269, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 208, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 210, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 213, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 217, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 221, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 225, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 226, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 228, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 231, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 233, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 236, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 241, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 243, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 244, 'World Finance Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 248, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 249, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 252, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 255, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 262, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 264, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 268, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 273, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (32, 276, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 211, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 212, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 229, 'Non-official event', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 234, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 246, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 247, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (33, 275, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 209, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 222, 'Technology and Development Symposium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 223, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 224, 'World Finance Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 227, 'Trade summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 230, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 232, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 235, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 254, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 256, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 257, 'Private meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 258, 'Bi-national conference', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 261, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 265, 'IFC meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 266, 'World Bank internal meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 267, 'International Development Summit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 270, 'G20 sub meeting', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (34, 274, 'Private meeting', NULL);

-- ----------------------------
-- Table structure for trips
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."trips";
CREATE TABLE "pd_wbgtravel"."trips" (
  "trip_id" int4 NOT NULL DEFAULT nextval('"pd_wbgtravel".trips_trip_id_seq'::regclass),
  "person_id" int4 NOT NULL,
  "city_id" int4 NOT NULL,
  "trip_start_date" date NOT NULL,
  "trip_end_date" date NOT NULL,
  "trip_reason" varchar(75) COLLATE "pg_catalog"."default",
  "time_created" timestamp(6) NOT NULL DEFAULT now()
)
;

-- ----------------------------
-- Records of trips
-- ----------------------------
INSERT INTO "pd_wbgtravel"."trips" VALUES (139, 30, 138, '2017-09-11', '2017-09-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (140, 30, 139, '2017-04-15', '2017-04-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (141, 30, 142, '2017-02-23', '2017-03-11', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (142, 30, 143, '2017-03-10', '2017-03-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (143, 30, 149, '2018-01-18', '2018-01-29', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (144, 30, 155, '2017-02-16', '2017-03-06', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (145, 30, 169, '2017-04-14', '2017-04-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (146, 30, 172, '2017-07-18', '2017-08-06', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (147, 30, 178, '2017-09-19', '2017-09-29', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (148, 30, 179, '2017-02-04', '2017-02-20', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (149, 31, 137, '2017-10-30', '2017-11-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (150, 31, 153, '2017-12-22', '2018-01-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (151, 31, 156, '2018-03-25', '2018-04-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (152, 31, 162, '2018-01-15', '2018-01-19', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (153, 31, 163, '2017-07-17', '2017-07-29', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (154, 31, 164, '2018-04-08', '2018-04-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (155, 31, 170, '2018-03-19', '2018-04-04', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (156, 31, 173, '2017-02-20', '2017-02-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (157, 31, 175, '2017-08-18', '2017-08-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (158, 31, 185, '2018-02-07', '2018-02-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (159, 31, 186, '2017-02-12', '2017-02-22', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (160, 32, 140, '2017-03-25', '2017-04-07', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (161, 32, 144, '2017-12-23', '2017-12-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (162, 32, 145, '2017-03-15', '2017-03-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (163, 32, 146, '2017-01-28', '2017-02-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (164, 32, 147, '2018-04-01', '2018-04-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (165, 32, 150, '2017-07-12', '2017-07-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (166, 32, 151, '2017-02-26', '2017-03-01', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (167, 32, 152, '2017-05-15', '2017-05-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (168, 32, 157, '2017-07-24', '2017-08-11', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (169, 32, 158, '2018-01-21', '2018-01-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (170, 32, 166, '2017-07-19', '2017-07-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (171, 32, 171, '2018-04-03', '2018-04-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (172, 32, 176, '2017-02-06', '2017-02-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (173, 32, 180, '2017-10-30', '2017-11-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (174, 32, 182, '2017-06-08', '2017-06-17', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (175, 32, 183, '2017-08-27', '2017-09-04', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (176, 32, 187, '2017-06-05', '2017-06-11', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (177, 32, 191, '2017-01-11', '2017-01-21', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (178, 32, 195, '2017-07-16', '2017-07-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (179, 32, 197, '2017-03-17', '2017-03-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (180, 32, 200, '2017-01-21', '2017-01-31', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (181, 32, 201, '2017-05-20', '2017-05-21', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (182, 32, 203, '2017-01-22', '2017-01-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (183, 33, 159, '2018-03-09', '2018-03-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (184, 33, 161, '2017-03-30', '2017-04-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (185, 33, 168, '2017-02-13', '2017-02-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (186, 33, 174, '2018-03-23', '2018-04-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (187, 33, 189, '2018-02-18', '2018-02-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (188, 33, 193, '2017-11-09', '2017-11-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (189, 33, 199, '2017-03-13', '2017-03-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (190, 34, 141, '2017-12-30', '2018-01-12', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (191, 34, 148, '2018-02-03', '2018-02-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (192, 34, 154, '2017-09-22', '2017-09-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (193, 34, 160, '2017-11-09', '2017-11-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (194, 34, 165, '2017-08-12', '2017-08-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (195, 34, 167, '2017-07-31', '2017-08-19', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (196, 34, 177, '2017-09-04', '2017-09-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (197, 34, 181, '2018-03-23', '2018-04-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (198, 34, 184, '2017-06-16', '2017-06-26', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (199, 34, 184, '2017-07-17', '2017-07-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (200, 34, 188, '2018-01-15', '2018-01-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (201, 34, 190, '2017-10-12', '2017-10-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (202, 34, 192, '2017-09-19', '2017-09-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (203, 34, 194, '2017-01-02', '2017-01-15', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (204, 34, 196, '2018-02-05', '2018-02-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (205, 34, 198, '2018-02-18', '2018-03-08', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (206, 34, 202, '2017-10-17', '2017-10-31', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (207, 34, 204, '2017-04-26', '2017-05-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (208, 35, 145, '2017-03-15', '2017-03-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (209, 35, 148, '2018-02-03', '2018-02-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (210, 35, 151, '2017-02-26', '2017-03-01', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (211, 35, 159, '2018-03-09', '2018-03-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (212, 35, 168, '2017-02-13', '2017-02-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (213, 35, 176, '2017-02-06', '2017-02-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (214, 35, 178, '2017-09-19', '2017-09-29', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (215, 35, 179, '2017-02-04', '2017-02-20', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (216, 36, 142, '2017-02-23', '2017-03-11', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (217, 36, 144, '2017-12-23', '2017-12-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (218, 36, 155, '2017-02-16', '2017-03-06', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (219, 36, 173, '2017-02-20', '2017-02-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (220, 36, 175, '2017-08-18', '2017-08-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (221, 36, 183, '2017-08-27', '2017-09-04', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (222, 36, 190, '2017-10-12', '2017-10-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (223, 36, 196, '2018-02-05', '2018-02-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (224, 37, 177, '2017-09-04', '2017-09-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (225, 37, 191, '2017-01-11', '2017-01-21', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (226, 37, 200, '2017-01-21', '2017-01-31', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (227, 37, 202, '2017-10-17', '2017-10-31', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (228, 38, 158, '2018-01-21', '2018-01-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (229, 38, 161, '2017-03-30', '2017-04-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (230, 38, 165, '2017-08-12', '2017-08-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (231, 38, 171, '2018-04-03', '2018-04-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (232, 38, 192, '2017-09-19', '2017-09-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (233, 38, 197, '2017-03-17', '2017-03-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (234, 38, 199, '2017-03-13', '2017-03-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (235, 39, 141, '2017-12-30', '2018-01-12', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (236, 39, 147, '2018-04-01', '2018-04-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (237, 39, 149, '2018-01-18', '2018-01-29', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (238, 39, 162, '2018-01-15', '2018-01-19', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (239, 39, 164, '2018-04-08', '2018-04-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (240, 39, 186, '2017-02-12', '2017-02-22', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (241, 39, 187, '2017-06-05', '2017-06-11', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (242, 40, 139, '2017-04-15', '2017-04-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (243, 40, 140, '2017-03-25', '2017-04-07', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (244, 40, 152, '2017-05-15', '2017-05-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (245, 40, 163, '2017-07-17', '2017-07-29', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (246, 40, 174, '2018-03-23', '2018-04-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (247, 40, 189, '2018-02-18', '2018-02-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (248, 40, 195, '2017-07-16', '2017-07-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (249, 40, 201, '2017-05-20', '2017-05-21', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (250, 41, 137, '2017-10-30', '2017-11-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (251, 41, 138, '2017-09-11', '2017-09-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (252, 41, 146, '2017-01-28', '2017-02-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (253, 41, 153, '2017-12-22', '2018-01-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (254, 41, 160, '2017-11-09', '2017-11-23', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (255, 41, 166, '2017-07-19', '2017-07-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (256, 41, 181, '2018-03-23', '2018-04-05', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (257, 41, 184, '2017-06-16', '2017-06-26', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (258, 41, 184, '2017-07-17', '2017-07-27', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (259, 41, 185, '2018-02-07', '2018-02-10', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (260, 42, 143, '2017-03-10', '2017-03-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (261, 42, 154, '2017-09-22', '2017-09-25', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (262, 42, 157, '2017-07-24', '2017-08-11', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (263, 42, 170, '2018-03-19', '2018-04-04', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (264, 42, 180, '2017-10-30', '2017-11-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (265, 42, 194, '2017-01-02', '2017-01-15', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (266, 42, 198, '2018-02-18', '2018-03-08', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (267, 42, 204, '2017-04-26', '2017-05-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (268, 43, 150, '2017-07-12', '2017-07-13', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (269, 43, 156, '2018-03-25', '2018-04-14', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (270, 43, 167, '2017-07-31', '2017-08-19', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (271, 43, 169, '2017-04-14', '2017-04-24', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (272, 43, 172, '2017-07-18', '2017-08-06', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (273, 43, 182, '2017-06-08', '2017-06-17', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (274, 43, 188, '2018-01-15', '2018-01-18', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (275, 43, 193, '2017-11-09', '2017-11-28', 'test trip', '2018-01-23 02:23:34.300814');
INSERT INTO "pd_wbgtravel"."trips" VALUES (276, 43, 203, '2017-01-22', '2017-01-23', 'test trip', '2018-01-23 02:23:34.300814');

-- ----------------------------
-- Function structure for next_trip_agenda_rank_order
-- ----------------------------
DROP FUNCTION IF EXISTS "pd_wbgtravel"."next_trip_agenda_rank_order"("var_trip_id" int4, "var_agenda_id" int4);
CREATE OR REPLACE FUNCTION "pd_wbgtravel"."next_trip_agenda_rank_order"("var_trip_id" int4, "var_agenda_id" int4)
  RETURNS "pg_catalog"."int2" AS $BODY$
	declare current_rank int2;
BEGIN
	select count(*) into current_rank
	from pd_wbgtravel.trip_agendas ta where ta.trip_id = var_trip_id and ta.agenda_id = var_agenda_id;
	select coalesce(current_rank,0)+1 into current_rank;
	return current_rank;

	RETURN 1234;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- View structure for view_trips_and_meetings
-- ----------------------------
DROP VIEW IF EXISTS "pd_wbgtravel"."view_trips_and_meetings";
CREATE VIEW "pd_wbgtravel"."view_trips_and_meetings" AS  SELECT pe.is_wbg,
    pe.short_name,
    pe.organization,
    pe.title,
    pe.sub_organization,
    ci.country_name,
    ci.city_name,
    tr.trip_reason,
    tr.trip_start_date,
    tr.trip_end_date,
    counterparts.short_name AS meeting_with,
    tm.topic AS meeting_topic
   FROM ((((pd_wbgtravel.trips tr
     JOIN pd_wbgtravel.cities ci ON ((ci.city_id = tr.city_id)))
     JOIN pd_wbgtravel.people pe ON ((pe.person_id = tr.person_id)))
     LEFT JOIN pd_wbgtravel.trip_meetings tm ON ((tm.travelers_trip_id = tr.trip_id)))
     LEFT JOIN pd_wbgtravel.people counterparts ON ((counterparts.person_id = tm.meeting_person_id)));

-- ----------------------------
-- View structure for trips_and_counterparts
-- ----------------------------
DROP VIEW IF EXISTS "pd_wbgtravel"."trips_and_counterparts";
CREATE VIEW "pd_wbgtravel"."trips_and_counterparts" AS  WITH all_trip_agendas AS (
         SELECT ta_1.trip_id,
            ag.agenda_id,
            ag.agenda_type,
            ag.short_title,
            ag.long_title,
            ag.topics,
            ag.calendar_schedule,
            ag.location,
            ag.description,
            ag.time_created
           FROM (pd_wbgtravel.trip_agendas ta_1
             JOIN pd_wbgtravel.agendas ag ON ((ag.agenda_id = ta_1.agenda_id)))
        ), all_trips AS (
         SELECT tr.trip_id,
            pe.person_id,
            ci.city_id,
            ata.agenda_id,
            pe.short_name,
            pe.title,
            pe.organization,
            pe.sub_organization,
            pe.is_wbg,
            tr.trip_start_date,
            tr.trip_end_date,
            tr.trip_reason AS trip_title,
            ci.country_name,
            ci.city_name,
            ci.latitude,
            ci.longitude,
            ata.agenda_type,
            ata.short_title,
            ata.calendar_schedule
           FROM (((pd_wbgtravel.trips tr
             JOIN pd_wbgtravel.people pe ON ((pe.person_id = tr.person_id)))
             LEFT JOIN pd_wbgtravel.cities ci ON ((ci.city_id = tr.city_id)))
             LEFT JOIN all_trip_agendas ata ON ((ata.trip_id = tr.trip_id)))
        )
 SELECT trips.trip_id,
    trips.person_id,
    trips.city_id,
    trips.agenda_id,
    trips.short_name,
    trips.title,
    trips.organization,
    trips.sub_organization,
    trips.is_wbg,
    trips.trip_start_date,
    trips.trip_end_date,
    trips.trip_title,
    trips.country_name,
    trips.city_name,
    trips.latitude,
    trips.longitude,
    trips.agenda_type,
    trips.short_title,
    trips.calendar_schedule,
    pe2.short_name AS counterpart_name
   FROM (((all_trips trips
     LEFT JOIN pd_wbgtravel.trip_agendas ta ON (((ta.agenda_id = trips.agenda_id) AND (ta.trip_id <> trips.trip_id))))
     LEFT JOIN pd_wbgtravel.trips tr2 ON ((tr2.trip_id = ta.trip_id)))
     LEFT JOIN pd_wbgtravel.people pe2 ON ((pe2.person_id = tr2.person_id)))
  ORDER BY trips.agenda_id;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "pd_wbgtravel"."agendas_agenda_id_seq"
OWNED BY "pd_wbgtravel"."agendas"."agenda_id";
SELECT setval('"pd_wbgtravel"."agendas_agenda_id_seq"', 212, true);
ALTER SEQUENCE "pd_wbgtravel"."cities_city_id_seq"
OWNED BY "pd_wbgtravel"."cities"."city_id";
SELECT setval('"pd_wbgtravel"."cities_city_id_seq"', 205, true);
ALTER SEQUENCE "pd_wbgtravel"."dev_events_event_id_seq"
OWNED BY "pd_wbgtravel"."dev_events"."event_id";
SELECT setval('"pd_wbgtravel"."dev_events_event_id_seq"', 150, true);
ALTER SEQUENCE "pd_wbgtravel"."people_person_id_seq"
OWNED BY "pd_wbgtravel"."people"."person_id";
SELECT setval('"pd_wbgtravel"."people_person_id_seq"', 44, true);
ALTER SEQUENCE "pd_wbgtravel"."trips_trip_id_seq"
OWNED BY "pd_wbgtravel"."trips"."trip_id";
SELECT setval('"pd_wbgtravel"."trips_trip_id_seq"', 277, true);

-- ----------------------------
-- Primary Key structure for table agendas
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."agendas" ADD CONSTRAINT "agendas_pkey" PRIMARY KEY ("agenda_id");

-- ----------------------------
-- Primary Key structure for table cities
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."cities" ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("city_id");

-- ----------------------------
-- Primary Key structure for table dev_events
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."dev_events" ADD CONSTRAINT "dev_events_pkey" PRIMARY KEY ("event_id");

-- ----------------------------
-- Indexes structure for table people
-- ----------------------------
CREATE UNIQUE INDEX "people_short_name_idx" ON "pd_wbgtravel"."people" USING btree (
  "short_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table people
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."people" ADD CONSTRAINT "people_pkey" PRIMARY KEY ("person_id");

-- ----------------------------
-- Primary Key structure for table trip_agendas
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."trip_agendas" ADD CONSTRAINT "trip_agendas_pkey" PRIMARY KEY ("trip_id", "agenda_id");

-- ----------------------------
-- Primary Key structure for table trip_meetings
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."trip_meetings" ADD CONSTRAINT "trip_meetings_pkey" PRIMARY KEY ("meeting_person_id", "travelers_trip_id");

-- ----------------------------
-- Primary Key structure for table trips
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."trips" ADD CONSTRAINT "trips_pkey" PRIMARY KEY ("trip_id");

-- ----------------------------
-- Foreign Keys structure for table trip_meetings
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."trip_meetings" ADD CONSTRAINT "trip_meetings_person_id_fkey" FOREIGN KEY ("meeting_person_id") REFERENCES "people" ("person_id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "pd_wbgtravel"."trip_meetings" ADD CONSTRAINT "trip_meetings_trip_id_fkey" FOREIGN KEY ("travelers_trip_id") REFERENCES "trips" ("trip_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table trips
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."trips" ADD CONSTRAINT "trips_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("city_id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "pd_wbgtravel"."trips" ADD CONSTRAINT "trips_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "people" ("person_id") ON DELETE CASCADE ON UPDATE CASCADE;
