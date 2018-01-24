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

 Date: 24/01/2018 12:51:26
*/


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
-- Table structure for cities
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."cities";
CREATE TABLE "pd_wbgtravel"."cities" (
  "city_id" int4 NOT NULL DEFAULT nextval('"pd_wbgtravel".cities_city_id_seq'::regclass),
  "city_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "country_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "country_ISO3" varchar(3) COLLATE "pg_catalog"."default",
  "latitude" numeric(12,9),
  "longitude" numeric(12,9)
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
INSERT INTO "pd_wbgtravel"."cities" VALUES (233, 'Cairo', 'Egypt', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (235, 'Jerusalem', 'Israel', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (238, 'Seoul', 'Republic of Korea', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (239, 'Munich', 'Germany', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (240, 'Dubai', 'UAE', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (259, 'Paris', 'France', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (261, 'Warsaw', 'Poland', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (262, 'Monrovia', 'Liberia', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (266, 'London', 'UK', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (267, 'Amman', 'Jordan', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (268, 'Washington, DC', 'United States', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (269, 'Tashkent', 'Uzbekistan', NULL, NULL, NULL);
INSERT INTO "pd_wbgtravel"."cities" VALUES (270, 'Davos', 'Switzerland', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for people
-- ----------------------------
DROP TABLE IF EXISTS "pd_wbgtravel"."people";
CREATE TABLE "pd_wbgtravel"."people" (
  "person_id" int4 NOT NULL DEFAULT nextval('"pd_wbgtravel".people_person_id_seq'::regclass),
  "full_name" varchar(50) COLLATE "pg_catalog"."default",
  "short_name" varchar(35) COLLATE "pg_catalog"."default" NOT NULL,
  "title" varchar(20) COLLATE "pg_catalog"."default",
  "organization" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
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
INSERT INTO "pd_wbgtravel"."people" VALUES (60, NULL, 'Donald Trump', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (61, NULL, 'Jim Kim', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (62, NULL, 'Jim Kim', NULL, 'World Bank', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (63, NULL, 'John Sullivan', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (64, NULL, 'Mark Green', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (65, NULL, 'Mike Pence', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (66, NULL, 'Rex Tillerson', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (67, NULL, 'Tom Shannon', NULL, 'US Government', NULL, NULL, 0, '2018-01-23 18:48:51.430671');
INSERT INTO "pd_wbgtravel"."people" VALUES (143, NULL, 'Abdel Fattah el-Sisi', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (144, NULL, 'Ali bin Al Hussein', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (145, NULL, 'Steven Mnuchin', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (146, NULL, 'Madeline Albright', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (147, NULL, 'Djamshid Kuchkarov', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (148, NULL, 'Sukhrob Kholmurodov', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (149, NULL, 'Shavkat Mirziyoyev', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (150, NULL, 'Bill Morneau', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (151, NULL, 'George Soros', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (152, NULL, 'Mark Suzman', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (153, NULL, 'Queen Mathilde of Belgium', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (154, NULL, 'Hasssan Ali Khaire', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (155, NULL, 'Dara Khosrowshahi', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (156, NULL, 'Joachim Wenning', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (157, NULL, 'Frans van Houten', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (158, NULL, 'Nursultan Nazarbayev', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (159, NULL, 'David Miliband', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (160, NULL, 'Abdulaziz Kamilov', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (161, NULL, 'Lim Sing-Nam', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (162, NULL, 'Petri Gormiztka', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');
INSERT INTO "pd_wbgtravel"."people" VALUES (163, NULL, 'Adel al-Jubeir', NULL, 'Unknown', NULL, NULL, 0, '2018-01-24 04:57:49.227892');

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
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (162, 647, 'Bilateral Meeting with OECD DAC Chair', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (152, 635, 'Meeting with Bill & Melinda Gates Representative', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (149, 633, 'Bilateral Meetings with PM', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (151, 634, 'Lunch', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (143, 648, 'Bilateral Meetings', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (144, 651, 'Bilateral Meetings', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (159, 658, 'Bilateral Meeting with International Rescue Commit', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (163, 655, 'Bilateral Meeting with Saudi Foreign Minister', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (154, 636, 'Bilateral Meeting with Somali PM', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (147, 633, 'Bilateral Meetings with Finance Minister', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (153, 635, 'Bilateral Meeting with Queen of Belgium', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (161, 646, 'Bilateral Meeting with Korean Vice Foreign Ministe', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (160, 658, 'Bilateral Meeting with Uzbek Foreign Minister', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (156, 645, 'Bilateral Meeting with Chairman of Munich Re', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (146, 632, 'Meeting with Madeline Albright', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (145, 639, 'World Economic Forum', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (148, 633, 'Bilateral Meetings with Deputy PM', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (150, 634, 'Bilateral Meetings with Canadian Finance Minister', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (157, 645, 'Bilateral Meeting with Royal Philips CEO', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (155, 644, 'Bilateral Meeting with Uber CEO', NULL);
INSERT INTO "pd_wbgtravel"."trip_meetings" VALUES (158, 637, 'Bilateral Meeting with Kazakh President', NULL);

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
INSERT INTO "pd_wbgtravel"."trips" VALUES (632, 31, 268, '2018-03-08', '2018-03-08', 'Meeting with Madeline Albright', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (633, 31, 269, '2018-01-18', '2018-01-18', 'Bilateral Meetings with Deputy PM,Bilateral Meetings with Finance Minister,', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (634, 31, 270, '2018-01-23', '2018-01-23', 'Bilateral Meetings with Canadian Finance Minister,Lunch', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (635, 31, 270, '2018-01-24', '2018-01-24', 'Bilateral Meeting with Queen of Belgium,Meeting with Bill & Melinda Gates R', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (636, 31, 270, '2018-01-25', '2018-01-25', 'Bilateral Meeting with Somali PM', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (637, 60, 268, '2018-01-17', '2018-01-17', 'Bilateral Meeting with Kazakh President', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (638, 60, 270, '2018-01-23', '2018-01-26', 'World Economic Forum', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (639, 61, 270, '2018-01-23', '2018-01-26', 'World Economic Forum', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (640, 62, 239, '2018-02-16', '2018-02-16', 'Munich Security Conference', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (641, 62, 240, '2018-02-15', '2018-02-15', 'Bilateral Meetings', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (642, 62, 267, '2018-02-16', '2018-02-16', 'Bilateral Meetings', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (643, 62, 268, '2018-02-23', '2018-02-23', 'Council on Foreign Relations ', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (644, 62, 270, '2018-01-23', '2018-01-23', 'Bilateral Meeting with Uber CEO', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (645, 62, 270, '2018-01-25', '2018-01-25', 'Bilateral Meeting with Chairman of Munich Re,Bilateral Meeting with Royal P', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (646, 63, 268, '2018-01-17', '2018-01-17', 'Bilateral Meeting with Korean Vice Foreign Minister', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (647, 64, 268, '2018-01-17', '2018-01-17', 'Bilateral Meeting with OECD DAC Chair', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (648, 65, 233, '2018-01-20', '2018-01-20', 'Bilateral Meetings', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (649, 65, 235, '2018-01-22', '2018-01-22', 'Bilateral Meetings', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (650, 65, 238, '2018-02-09', '2018-02-09', 'Olympics and Bilateral Meetings', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (651, 65, 267, '2018-01-21', '2018-01-21', 'Bilateral Meetings', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (652, 66, 259, '2018-01-22', '2018-01-23', 'Bilateral Meetings with French Government', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (653, 66, 261, '2018-01-26', '2018-01-27', '', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (654, 66, 266, '2018-01-21', '2018-01-22', 'Bilateral Meeting with UK Foreign Secretary Boris Johnson', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (655, 66, 268, '2018-01-12', '2018-01-12', 'Bilateral Meeting with Saudi Foreign Minister', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (656, 66, 270, '2018-01-24', '2018-01-26', 'World Economic Forum', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (657, 67, 262, '2018-01-23', '2018-01-26', 'Bilateral Meetings with Liberian Government', '2018-01-24 06:49:09.141849');
INSERT INTO "pd_wbgtravel"."trips" VALUES (658, 67, 268, '2018-01-17', '2018-01-17', 'Bilateral Meeting with International Rescue Committee Chair,Bilateral Meeti', '2018-01-24 06:49:09.141849');

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
-- Function structure for travel_uploads
-- ----------------------------
DROP FUNCTION IF EXISTS "pd_wbgtravel"."travel_uploads"();
CREATE OR REPLACE FUNCTION "pd_wbgtravel"."travel_uploads"()
  RETURNS TABLE("change" int4, "up_id" int4, "Person" varchar, "Organization" varchar, "City" varchar, "Country" varchar, "Start" date, "End" date, "Reason" varchar, "Meeting" varchar, "Topic" varchar, "STATUS" varchar) AS $BODY$
BEGIN
---------------------
--START NEW PEOPLE --
---------------------
raise notice 'Adding New People';
--Create a temp table to store new people to track which up_ids are added and report back to user on upload results
create temp table if not exists _temp_people(up_id int4, short_name varchar(50), organization varchar(50), is_wbg int2); 

-- New people from travelers list
insert into _temp_people(up_id,short_name,organization,is_wbg)
select distinct ttu.up_id,ttu."Person",ttu."Organization",0
from public._temp_travel_uploads ttu 
where ttu.person_id is null and ttu."Person" is not null and ttu."Organization" is not null and
not exists(select * from pd_wbgtravel.people where (people.short_name = ttu."Person" or people.full_name = ttu."Person"));

-- New people from counterparts list (people travelers are meeting with)
insert into _temp_people(up_id,short_name,organization,is_wbg)
select distinct ttu.up_id,ttu."Meeting",'Unknown',0
from public._temp_travel_uploads ttu 
where ttu.meeting_person_id is null and ttu."Meeting" is not null and
not exists(select * from pd_wbgtravel.people where (people.short_name = ttu."Meeting" or people.full_name = ttu."Meeting"));

-- Add new people into table from temporary table
insert into pd_wbgtravel.people(short_name,organization,is_wbg)
select short_name,organization,is_wbg
from _temp_people
where not exists(select * from pd_wbgtravel.people where people.short_name = _temp_people.short_name or people.full_name = _temp_people.short_name);
-------------------
--END NEW PEOPLE --
-------------------

---------------------
--START NEW CITIES --
---------------------
raise notice 'Adding New Cities';

create temp table if not exists _temp_cities(up_id int4, city_name varchar(50), country_name varchar(50)); 

insert into _temp_cities(up_id,city_name,country_name)
select distinct ttu.up_id,ttu."City",ttu."Country"
from public._temp_travel_uploads ttu 
where ttu.city_id is null and ttu."City" is not null and ttu."Country" is not null and 
not exists(select * from pd_wbgtravel.cities where lower(cities.city_name) = lower(ttu."City") and lower(cities.country_name) = lower(ttu."Country"));

insert into pd_wbgtravel.cities(city_name,country_name)
select distinct city_name,country_name
from _temp_cities
where not exists(select * from pd_wbgtravel.cities where lower(cities.city_name) = lower(_temp_cities.city_name) and lower(cities.country_name) = lower(_temp_cities.country_name));

-------------------
--END NEW CITIES --
-------------------

--------------------
--START NEW TRIPS --
--------------------
raise notice 'Adding New Trips';

create temp table if not exists _temp_trips(up_id int4, person_id int4, city_id int4, trip_start_date date, trip_end_date date, trip_reason varchar(75)); 

delete from _temp_trips;

insert into _temp_trips(up_id,person_id,city_id,trip_start_date,trip_end_date,trip_reason)
select distinct ttu.up_id,pe.person_id,ci.city_id,ttu."Start",ttu."End",ttu."Reason"
from public._temp_travel_uploads ttu 
inner join pd_wbgtravel.people pe on (pe.short_name = ttu."Person" or pe.full_name = ttu."Person") and pe.organization = ttu."Organization"
inner join pd_wbgtravel.cities ci on ci.city_name = ttu."City" and ci.country_name = ttu."Country"
where ttu."Start" is not null and ttu."End" is not null and ttu."Person" is not null and ttu."Organization" is not null and
ttu."City" is not null and ttu."Country" is not null and ttu.trip_id is null and
not exists(select * from pd_wbgtravel.trips where trips.person_id = pe.person_id and trips.city_id = ci.city_id and trips.trip_start_date = ttu."Start" and trip_end_date = ttu."End");

insert into pd_wbgtravel.trips(person_id,city_id,trip_start_date,trip_end_date,trip_reason)
select person_id,city_id,trip_start_date,trip_end_date,substring(array_to_string(array_agg(distinct trip_reason),',') from 1 for 75)
from _temp_trips
where not exists(select * from pd_wbgtravel.trips where trips.person_id = _temp_trips.person_id and trips.city_id = _temp_trips.city_id 
	and trips.trip_start_date = _temp_trips.trip_start_date and trips.trip_end_date = _temp_trips.trip_end_date)
group by person_id,city_id,trip_start_date,trip_end_date;
--save new IDs
--for later RETURNING trip_id int new_trips_ids;

------------------
--END NEW TRIPS --
------------------

-----------------------
--START NEW MEETINGS --
-----------------------
raise notice 'Adding New Meetings';

create temp table if not exists _temp_meetings(up_id int4, meeting_person_id int4, travelers_trip_id int4, topic varchar(75)); 

insert into _temp_meetings(up_id,meeting_person_id,travelers_trip_id,topic)
select distinct _temp_trips.up_id,people.person_id,trips.trip_id,ttu."Reason"
from _temp_trips
inner join public._temp_travel_uploads ttu on ttu.up_id = _temp_trips.up_id
inner join pd_wbgtravel.trips on trips.person_id = _temp_trips.person_id and trips.city_id = _temp_trips.city_id and trips.trip_start_date = _temp_trips.trip_start_date and trips.trip_end_date = _temp_trips.trip_end_date
inner join pd_wbgtravel.people on people.short_name = ttu."Meeting" or people.full_name = ttu."Meeting"
where not exists(select * from pd_wbgtravel.trip_meetings where trip_meetings.meeting_person_id = people.person_id and trip_meetings.travelers_trip_id = trips.trip_id);

insert into pd_wbgtravel.trip_meetings(meeting_person_id,travelers_trip_id,topic)
select distinct meeting_person_id,travelers_trip_id,substring(topic from 1 for 50)
from _temp_meetings
where not exists(select * from pd_wbgtravel.trip_meetings where trip_meetings.meeting_person_id = _temp_meetings.meeting_person_id and trip_meetings.travelers_trip_id = _temp_meetings.travelers_trip_id);

---------------------
--END NEW MEETINGS --
---------------------

-----------------
--START STATUS --
-----------------
raise notice 'Setting Statuses';

create temp table _temp_status(up_id int, sort int, message varchar(200));

insert into _temp_status(up_id,sort,message)
select _temp_people.up_id,1 as sort,'Person Added: (is_wbg=' || _temp_people.is_wbg || ') ' || _temp_people.short_name
from _temp_people;

insert into _temp_status(up_id,sort,message)
select _temp_cities.up_id,2 as sort,'City Added: ' || _temp_cities.city_name || ', ' || _temp_cities.country_name
from _temp_cities;

insert into _temp_status(up_id,sort,message)
select _temp_trips.up_id,3 as sort,'Trip Added: ' || people.short_name || ' TO ' || cities.city_name || ', ' || cities.country_name || ' ON ' || _temp_trips.trip_start_date
from _temp_trips
inner join pd_wbgtravel.people on people.person_id = _temp_trips.person_id
inner join pd_wbgtravel.cities on cities.city_id = _temp_trips.city_id;

insert into _temp_status(up_id,sort,message)
select _temp_meetings.up_id,4 as sort,'Meeting Added: ' || people.short_name || ' MEETS ' || meetings.short_name || ' IN ' || cities.city_name
from _temp_meetings
inner join pd_wbgtravel.trips on trips.trip_id = _temp_meetings.travelers_trip_id
inner join pd_wbgtravel.cities on cities.city_id = trips.city_id
inner join pd_wbgtravel.people on people.person_id = trips.person_id
inner join pd_wbgtravel.people meetings on meetings.person_id = _temp_meetings.meeting_person_id;

update public._temp_travel_uploads 
SET "STATUS" = 'SKIPPED: Already Exists or Data Entry Error'
where not exists(select * from _temp_status where _temp_status.up_id = _temp_travel_uploads.up_id);

raise notice 'Returning Result';

RETURN QUERY select distinct msg.sort,msg.up_id,msg."Person",msg."Organization",msg."City",msg."Country",msg."Start",msg."End",msg."Reason",msg."Meeting",msg."Topic",msg."STATUS"
from (
select 0 as sort, ttu1.up_id,ttu1."Person",ttu1."Organization",ttu1."City",ttu1."Country",ttu1."Start",ttu1."End",ttu1."Reason",ttu1."Meeting",ttu1."Topic",ttu1."STATUS" 
from public._temp_travel_uploads ttu1

union all

select _temp_status.sort,ttu2.up_id,ttu2."Person",ttu2."Organization",ttu2."City",ttu2."Country",ttu2."Start",ttu2."End",ttu2."Reason",ttu2."Meeting",ttu2."Topic",_temp_status.message as "STATUS"
from public._temp_travel_uploads ttu2
inner join _temp_status on _temp_status.up_id = ttu2.up_id)
msg
order by msg.sort,msg.up_id;

---------------
--END STATUS --
---------------
raise notice 'Cleaning Up Temp Tables';

drop table if exists _temp_people;
drop table if exists _temp_cities;
drop table if exists _temp_trips;
drop table if exists _temp_meetings;
drop table if exists _temp_status;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "pd_wbgtravel"."cities_city_id_seq"
OWNED BY "pd_wbgtravel"."cities"."city_id";
SELECT setval('"pd_wbgtravel"."cities_city_id_seq"', 271, true);
ALTER SEQUENCE "pd_wbgtravel"."people_person_id_seq"
OWNED BY "pd_wbgtravel"."people"."person_id";
SELECT setval('"pd_wbgtravel"."people_person_id_seq"', 164, true);
ALTER SEQUENCE "pd_wbgtravel"."trips_trip_id_seq"
OWNED BY "pd_wbgtravel"."trips"."trip_id";
SELECT setval('"pd_wbgtravel"."trips_trip_id_seq"', 659, true);

-- ----------------------------
-- Indexes structure for table cities
-- ----------------------------
CREATE UNIQUE INDEX "cities_city_name_country_name_idx" ON "pd_wbgtravel"."cities" USING btree (
  "city_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "country_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table cities
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."cities" ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("city_id");

-- ----------------------------
-- Indexes structure for table people
-- ----------------------------
CREATE UNIQUE INDEX "people_short_name_organization_idx" ON "pd_wbgtravel"."people" USING btree (
  "short_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "organization" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table people
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."people" ADD CONSTRAINT "people_pkey" PRIMARY KEY ("person_id");

-- ----------------------------
-- Primary Key structure for table trip_meetings
-- ----------------------------
ALTER TABLE "pd_wbgtravel"."trip_meetings" ADD CONSTRAINT "trip_meetings_pkey" PRIMARY KEY ("meeting_person_id", "travelers_trip_id");

-- ----------------------------
-- Indexes structure for table trips
-- ----------------------------
CREATE UNIQUE INDEX "trips_person_id_city_id_trip_start_date_trip_end_date_idx" ON "pd_wbgtravel"."trips" USING btree (
  "person_id" "pg_catalog"."int4_ops" ASC NULLS LAST,
  "city_id" "pg_catalog"."int4_ops" ASC NULLS LAST,
  "trip_start_date" "pg_catalog"."date_ops" ASC NULLS LAST,
  "trip_end_date" "pg_catalog"."date_ops" ASC NULLS LAST
);

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
