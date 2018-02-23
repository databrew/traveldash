--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

-- Started on 2018-02-23 17:59:01

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE dev;
--
-- TOC entry 3837 (class 1262 OID 40489)
-- Name: dev; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE dev WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE dev OWNER TO postgres;

\connect dev

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 27 (class 2615 OID 40490)
-- Name: pd_portfolio; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pd_portfolio;


ALTER SCHEMA pd_portfolio OWNER TO postgres;

--
-- TOC entry 4 (class 2615 OID 40491)
-- Name: pd_wbgtravel; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pd_wbgtravel;


ALTER SCHEMA pd_wbgtravel OWNER TO postgres;

--
-- TOC entry 43 (class 2615 OID 40492)
-- Name: portfolio; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA portfolio;


ALTER SCHEMA portfolio OWNER TO postgres;

--
-- TOC entry 1 (class 3079 OID 13792)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 266 (class 1255 OID 43172)
-- Name: grant_default_privileges_for_arl_team_applications(text); Type: FUNCTION; Schema: pd_wbgtravel; Owner: postgres
--

CREATE FUNCTION grant_default_privileges_for_arl_team_applications(sch_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin

execute 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || sch_name || '" GRANT ALL ON TABLES TO "ARLTeam", "Applications";';
execute 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || sch_name || '" GRANT ALL ON SEQUENCES TO "ARLTeam", "Applications";';
execute 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || sch_name || '" GRANT ALL ON FUNCTIONS TO "ARLTeam", "Applications";';
execute 'GRANT ALL ON ALL TABLES IN SCHEMA "' || sch_name || '" TO "Applications","ARLTeam";';
execute 'GRANT USAGE, UPDATE, SELECT ON ALL SEQUENCES IN SCHEMA "' || sch_name || '" TO "Applications","ARLTeam";';
execute 'GRANT ALL ON ALL FUNCTIONS IN SCHEMA "' || sch_name || '" TO "Applications","ARLTeam";';
end
$$;


ALTER FUNCTION pd_wbgtravel.grant_default_privileges_for_arl_team_applications(sch_name text) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 45224)
-- Name: init_database(); Type: FUNCTION; Schema: pd_wbgtravel; Owner: postgres
--

CREATE FUNCTION init_database() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
insert into pd_wbgtravel.users(user_id,user_role,user_password,can_login,last_login,note)
select 0,'SYSTEM','',false,NULL,'System account: updates automated data, where deemed relevant'
where not exists(select * from pd_wbgtravel.users where user_id = 0);

insert into pd_wbgtravel.users(user_role,user_password,can_login,last_login,note)
select 'MEL','FIGSSAMEL',true,NULL,'Team account for MEL team, developer account'
where not exists(select * from pd_wbgtravel.users where user_role = 'MEL');

insert into pd_wbgtravel.users(user_role,user_password,can_login,last_login,note)
select 'CEOSI','CEOSI2018',true,NULL,'Team account for unit CEOSI, Strategic Initiatives'
where not exists(select * from pd_wbgtravel.users where user_role = 'CEOSI');

insert into pd_wbgtravel.venue_types(venue_type_id,type_name,is_temporal_venue)
select 0,'Unknown',false
where not exists(select * from pd_wbgtravel.venue_types where venue_type_id = 0);

insert into pd_wbgtravel.venue_types(type_name,is_temporal_venue)
select 'Organization',false
where not exists(select * from pd_wbgtravel.venue_types where type_name='Organization');

insert into pd_wbgtravel.venue_types(type_name,is_temporal_venue)
select 'Client',false
where not exists(select * from pd_wbgtravel.venue_types where type_name='Client');

insert into pd_wbgtravel.venue_types(type_name,is_temporal_venue)
select 'Donor',false
where not exists(select * from pd_wbgtravel.venue_types where type_name='Donor');

insert into pd_wbgtravel.venue_types(type_name,is_temporal_venue)
select 'Government',false
where not exists(select * from pd_wbgtravel.venue_types where type_name='Government');

insert into pd_wbgtravel.venue_types(type_name,is_temporal_venue)
select 'Small Event',true
where not exists(select * from pd_wbgtravel.venue_types where type_name='Small Event');

insert into pd_wbgtravel.venue_types(type_name,is_temporal_venue)
select 'Major Event',true
where not exists(select * from pd_wbgtravel.venue_types where type_name='Major Event');

insert into pd_wbgtravel.venue_events(venue_id,venue_name,venue_short_name,venue_type_id)
select 0,'Unspecified Venue','Unspecified',0
where not exists(select * from pd_wbgtravel.venue_events where venue_id = 0);

return true;

end$$;


ALTER FUNCTION pd_wbgtravel.init_database() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 43173)
-- Name: remove_abandoned_people_and_places(integer); Type: FUNCTION; Schema: pd_wbgtravel; Owner: postgres
--

CREATE FUNCTION remove_abandoned_people_and_places(v_user_id integer) RETURNS TABLE(abandoned_log_id integer)
    LANGUAGE plpgsql
    AS $$BEGIN

create temp table if not exists _temp_user_action_log(log_id int);

-- Cities that have no trips
with delete_abandoned_cities as
(
	delete from pd_wbgtravel.cities
	where not exists (select * from pd_wbgtravel.trips where trips.city_id = cities.city_id)
	returning city_id,city_name,country_name
),
log_abandoned_cities as
(
	insert into pd_wbgtravel.user_action_log(user_id,user_action_id,table_name,table_ids,note)
	select v_user_id,-1,'cities',ARRAY[city_id],'REMOVING UNREFERENCED CITY: ' || city_name || ', ' || country_name
	from delete_abandoned_cities
	returning log_id
)
insert into _temp_user_action_log(log_id) select log_id from log_abandoned_cities;

-- Venues that have no cities
with delete_abandoned_venues as
(
	delete from pd_wbgtravel.venue_events
	where venue_id <> 0 and
			  (
					not exists (select * from pd_wbgtravel.cities where cities.city_id = venue_events.venue_city_id) or 
					not exists (select * from pd_wbgtravel.trip_meetings where trip_meetings.meeting_venue_id = venue_events.venue_id) or 
					venue_city_id is null
				)
	returning venue_id,venue_name
),
log_abandoned_venues as
(
	insert into pd_wbgtravel.user_action_log(user_id,user_action_id,table_name,table_ids,note)
	select v_user_id,-1,'venue_events',ARRAY[venue_id],'REMOVING UNREFERENCED VENUE: ' || venue_name
	from delete_abandoned_venues
	returning log_id
)
insert into _temp_user_action_log(log_id) select log_id from log_abandoned_venues;

/*
-- Meetings that have no trips (this shouldn't exist as trip_meetings cascades foreign key on delete of trip
with delete_abandoned_meetings as
(
	delete from pd_wbgtravel.trip_meetings
	where not exists (select * from pd_wbgtravel.trips where trips.trip_id = trip_meetings.travelers_trip_id)
	returning meeting_person_id,travelers_trip_id,topic
),
log_abandoned_meetings as
(
	insert into pd_wbgtravel.user_action_log(user_id,user_action_id,table_name,table_ids,note)
	select v_user_id,-1,'trip_meetings',ARRAY[meeting_person_id,travelers_trip_id],
	'REMOVING UNREFERENCED MEETING: ' || coalesce(topic,'Unkown Topic')
	from delete_abandoned_meetings
	returning log_id
)
insert into _temp_user_action_log(log_id) select log_id from log_abandoned_meetings;
*/
-- People that have no trips or meetings

/* Do we want to identify/remove stag meetings if/when they're no longer stag at an event?
with unstag_meetings as
(
	select travelers_trip_id,meeting_venue_id,count(distinct meeting_person_id),sum(stag_flag::int) 
	from trip_meetings 
	group by travelers_trip_id,meeting_venue_id
	having sum(stag_flag::int) >=1 and count(distinct meeting_person_id) >= 2
)
select pe1.short_name,* from trip_meetings tm
inner join trips tr on tr.trip_id = tm.travelers_trip_id
inner join people pe1 on pe1.person_id = tr.person_id
inner join people pe on pe.person_id = tm.meeting_person_id
where exists(select * from unstag_meetings um where um.travelers_trip_id = tm.travelers_trip_id)
*/
with delete_abandoned_people as
(
	delete from pd_wbgtravel.people
	where not exists (select * from pd_wbgtravel.trips where trips.person_id = people.person_id)
	and not exists(select * from pd_wbgtravel.trip_meetings where trip_meetings.meeting_person_id = people.person_id)
	returning person_id,short_name,organization
),
log_abandoned_people as
(
	insert into pd_wbgtravel.user_action_log(user_id,user_action_id,table_name,table_ids,note)
	select v_user_id,-1,'people',ARRAY[person_id],'REMOVING UNREFERENCED PERSON: ' || short_name || ', ' || organization
	from delete_abandoned_people
	returning log_id
)
insert into _temp_user_action_log(log_id) select log_id from log_abandoned_people;

return query
select log_id as abandoned_log_id from _temp_user_action_log;

drop table if exists _temp_user_action_log;

END;$$;


ALTER FUNCTION pd_wbgtravel.remove_abandoned_people_and_places(v_user_id integer) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 45386)
-- Name: travel_uploads(integer); Type: FUNCTION; Schema: pd_wbgtravel; Owner: postgres
--

CREATE FUNCTION travel_uploads(v_user_id integer) RETURNS TABLE(change smallint, up_id integer, "Person" character varying, "Organization" character varying, "City" character varying, "Country" character varying, "Start" date, "End" date, "Trip Group" character varying, "Venue" character varying, "Meeting" character varying, "Agenda" character varying, "STATUS" character varying)
    LANGUAGE plpgsql
    AS $$
--DECLARE
-- items record;
--	v_log_time timestamp;
BEGIN

IF not exists(select * from pd_wbgtravel.users where users.user_id = v_user_id) THEN
		raise notice 'Unknown User!  Cancelling request';
    return ;
END IF;

create temp table if not exists _user_action_log (
  log_id serial4,
  user_id int4,
  user_action_id int4,
  "table_name" varchar(50),
  table_ids int4[],
  action_time timestamp(6) NOT NULL DEFAULT now(),
	up_ids int4[],
	note varchar(255),
  CONSTRAINT "_user_action_log_pkey" PRIMARY KEY ("log_id")
);

CREATE INDEX _user_action_log_user_action_id_table_name_action_time_idx ON _user_action_log USING btree (
  "user_action_id" "pg_catalog"."int4_ops" ASC NULLS LAST,
  "table_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "action_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);



---------------
--START CMDs --
---------------
raise notice 'Executing DELETE and UPDATE commands';

-- This will remove trips.
-- People, meetings, venues, etc referneced elsewere will remain
-- Abandoned people and places will be cleaned up afterward so they do not linger
-- UPDATE and DELETE both delete the trip, whereas UPDATE will re-create the entry
-- This is useful for an UPDATE entry to, for example, fix a person's name (perhaps to someone who already exists)
-- Can delete all trip info associated with the wrong-named person and re-create the trip with the correctly named person
-- and without worrying about creating a conflict to update the wrong-named person and duplicating a right-named person who 
-- already exists in the database.
update public._temp_travel_uploads
	SET "CMD" = NULL, "ID" = NULL
	where "ID" is not null and not exists(select * from pd_wbgtravel.trips where trips.trip_uid = "ID");

with delete_update_trips as
(
	delete from pd_wbgtravel.trips
	where exists (select * from public._temp_travel_uploads ttu 
								where upper(coalesce(ttu."CMD",'INSERT')) in ('DELETE','UPDATE') and ttu."ID" = trips.trip_uid)
	returning trip_id,person_id,city_id,trip_start_date,trip_uid,created_by_user_id
)
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,-1,'trips',ARRAY[trip_id],'Removing Trip: ' || people.short_name || ' [TO] ' || cities.city_name || ' [ON] ' || trip_start_date || ' {' || users.user_role || ':' || trip_uid || '}'
from delete_update_trips
left join pd_wbgtravel.cities on cities.city_id = delete_update_trips.city_id
left join pd_wbgtravel.people on people.person_id = delete_update_trips.person_id
left join pd_wbgtravel.users on users.user_id = delete_update_trips.created_by_user_id;

-- Where CMD='UPDATE' let's re-create these entries with corrected info (after deleting old info)
-- And where CMD='DELETE' but no delete record returned from 'delete_update_trips' user entered a wrong ID; so reset
-- Or if they enter a bad command.
update public._temp_travel_uploads tz
	SET "CMD" = NULL, "ID" = NULL
	where upper(coalesce("CMD",'INSERT')) <> 'DELETE';

update public._temp_travel_uploads ttu
	SET "CMD" = 'ERROR'
	where ttu."Person" is null or char_length(ttu."Person") <3 or
				ttu."Organization" is null or char_length(ttu."Organization") <3 or
				ttu."City" is null or char_length(ttu."City") <3 or
				ttu."Country" is null or char_length(ttu."Country") <2 or
				ttu."Start" is null or ttu."End" is null;


raise notice 'Looking for abandoned entries';
create temp table _temp_abandoned_log(log_id int);
insert into _temp_abandoned_log(log_id)
select abandoned_log_id from pd_wbgtravel.remove_abandoned_people_and_places(v_user_id);


-------------
--END CMDs --
-------------

-------------------
--START NEW PEOPLE --
---------------------
raise notice 'Adding New People';
--Create a temp table to store new people to track which up_ids are added and report back to user on upload results
create temp table if not exists _temp_people(up_id int4, short_name varchar(40), organization varchar(50), is_wbg int2); 
delete from _temp_people;
-- New people from travelers list
insert into _temp_people(up_id,short_name,organization,is_wbg)
select distinct 
	ttu.up_id,
	left(initcap(trim(ttu."Person")),40),
	left(trim(ttu."Organization"),50),0
from public._temp_travel_uploads ttu 
where coalesce(ttu."CMD",'INSERT') = 'INSERT' and 
	ttu."Person" is not null and 
	ttu."Organization" is not null and
	not exists(select * from pd_wbgtravel.people where (lower(people.short_name) = lower(trim(ttu."Person")) or 
	                                                    lower(people.full_name) = lower(trim(ttu."Person"))));

-- New people from counterparts list (people travelers are meeting with)
-- Meetings permit csv lists of people who are meeting
with multi_meetings as
(
	select distinct 
		ttu.up_id,
		left(initcap(trim(unnest(string_to_array(ttu."Meeting",',')))),40) as "Meeting"
	from public._temp_travel_uploads ttu 
	where coalesce(ttu."CMD",'INSERT') = 'INSERT' and ttu."Meeting" is not null
)
insert into _temp_people(up_id,short_name,organization,is_wbg)
select mm.up_id,mm."Meeting",'Unknown',0 from multi_meetings mm
where not exists(select * from pd_wbgtravel.people where (lower(people.short_name) = lower(mm."Meeting") or 
                                                          lower(people.full_name) = lower(mm."Meeting")));

with people_insert as
(
	-- Add new people into table from temporary table
	insert into pd_wbgtravel.people(short_name,organization,is_wbg)
	select distinct short_name,organization,is_wbg
	from _temp_people
	where not exists(select * from pd_wbgtravel.people 
	                 where lower(people.short_name) = lower(_temp_people.short_name) or 
									       lower(people.full_name) = lower(_temp_people.short_name))
	returning person_id,short_name
)
-- Log who did what 1=insert,0=update,-1=delete
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,1,'people',ARRAY[person_id],'Adding Person: ' || short_name
from people_insert;


-- Let's guess who's WBG=1 based on their organization.  Only auto-update where SYSTEM user was last updater (eg, don't overwrite a user-generated input)
with people_update as
(
	update pd_wbgtravel.people
	SET is_wbg=1
	where 
	--we only want to auto-update for the recently inserted users -- these are logged in the temp _user_action_log
  exists(select * from _user_action_log ual where ual.table_name = 'people' and ual.table_ids[1] = people.person_id) and
	(
		lower(organization) like '%world bank%' or lower(organization) = 'ifc' or lower(organization) = 'ibrd' or
		lower(organization) = 'miga' or lower(organization) like '%international finance corporation%'
	)
	returning person_id,short_name
)
-- user_id=0=SYSTEM
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select 0,0,'people',ARRAY[person_id],'Upadting Person: ' || short_name || ': is_wbg=YES'
from people_update;

-- Match inserted people to upload data -- so we know which people are added for status report
update _user_action_log
	set up_ids = ups.up_ids
	from
	(
		select pe.person_id,array_agg(distinct tp.up_id) as up_ids
		from _user_action_log ual
		inner join pd_wbgtravel.people pe on pe.person_id = ual.table_ids[1]
		inner join _temp_people tp on tp.short_name = pe.short_name
		where ual.table_name = 'people'
		group by pe.person_id
  ) ups
	where ups.person_id = _user_action_log.table_ids[1] and _user_action_log.table_name = 'people';

-------------------
--END NEW PEOPLE --
-------------------

---------------------
--START NEW CITIES --
---------------------
raise notice 'Adding New Cities';

create temp table if not exists _temp_cities(up_id int4, city_name varchar(50), country_name varchar(50)); 
delete from _temp_cities;

insert into _temp_cities(up_id,city_name,country_name)
select distinct ttu.up_id,
	left(ttu."City",50),
	left(ttu."Country",50)
from public._temp_travel_uploads ttu 
where coalesce(ttu."CMD",'INSERT') = 'INSERT' and 
	ttu."City" is not null and 
	ttu."Country" is not null and 
	not exists(select * from pd_wbgtravel.cities where lower(cities.city_name) = lower(ttu."City") and 
	                                                   lower(cities.country_name) = lower(ttu."Country"));

with cities_insert as
(
	insert into pd_wbgtravel.cities(city_name,country_name)
	select distinct city_name,country_name
	from _temp_cities
	where not exists(select * from pd_wbgtravel.cities where lower(cities.city_name) = lower(_temp_cities.city_name) and 
	                                                         lower(cities.country_name) = lower(_temp_cities.country_name))
	returning city_id,city_name,country_name
)
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,1,'cities',ARRAY[city_id],'Adding City: ' || city_name || ', ' || country_name
from cities_insert;

-- Match inserted people to upload data -- so we know which people are added for status report
update _user_action_log
	set up_ids = ups.up_ids
	from
	(
		select ci.city_id,array_agg(distinct tc.up_id) as up_ids
		from _user_action_log ual
		inner join pd_wbgtravel.cities ci on ci.city_id = ual.table_ids[1]
		inner join _temp_cities tc on tc.city_name = ci.city_name and tc.country_name = ci.country_name
		where ual.table_name = 'cities'
		group by ci.city_id
  ) ups
	where ups.city_id = _user_action_log.table_ids[1] and _user_action_log.table_name = 'cities';
-------------------
--END NEW CITIES --
-------------------

--------------------
--START NEW TRIPS --
--------------------
raise notice 'Adding New Trips';

create temp table if not exists _temp_trips(up_id int4, person_id int4, city_id int4, trip_start_date date, trip_end_date date, trip_group varchar(75)); 

delete from _temp_trips;

insert into _temp_trips(up_id,person_id,city_id,trip_start_date,trip_end_date,trip_group)
select distinct ttu.up_id,pe.person_id,ci.city_id,ttu."Start",ttu."End",left(ttu."Trip Group",75)
from public._temp_travel_uploads ttu 
inner join pd_wbgtravel.people pe on (
                                      lower(trim(pe.short_name)) = lower(trim(ttu."Person")) or 
                                      lower(trim(pe.full_name)) = lower(trim(ttu."Person"))
																		 ) and 
																		 lower(trim(pe.organization)) = lower(trim(ttu."Organization"))
inner join pd_wbgtravel.cities ci on lower(trim(ci.city_name)) = lower(trim(ttu."City")) and 
                                     lower(trim(ci.country_name)) = lower(trim(ttu."Country"))
where coalesce(ttu."CMD",'INSERT') = 'INSERT' and
	ttu."Start" is not null and ttu."End" is not null and ttu."Person" is not null and ttu."Organization" is not null and
	ttu."City" is not null and ttu."Country" is not null and
	not exists(select * from pd_wbgtravel.trips where trips.person_id = pe.person_id and 
	                                                  trips.city_id = ci.city_id and 
																										trips.trip_start_date = ttu."Start" and trip_end_date = ttu."End");

with trips_insert as
(
	insert into pd_wbgtravel.trips(person_id,city_id,trip_start_date,trip_end_date,trip_group,created_by_user_id)
	select distinct person_id,city_id,trip_start_date,trip_end_date,
		left(array_to_string(array_agg(distinct trip_group),','),75),v_user_id
	from _temp_trips
	where not exists(select * from pd_wbgtravel.trips where trips.person_id = _temp_trips.person_id and trips.city_id = _temp_trips.city_id 
		and trips.trip_start_date = _temp_trips.trip_start_date and trips.trip_end_date = _temp_trips.trip_end_date)
	group by person_id,city_id,trip_start_date,trip_end_date
	returning trip_id,person_id,city_id,trip_start_date,trip_uid,created_by_user_id
)
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,1,'trips',ARRAY[trip_id],'Adding Trip: ' || people.short_name || ' [TO] ' || cities.city_name || ' [ON] ' || trip_start_date || ' {' || users.user_role || ':' || trip_uid || '}'
from trips_insert
left join pd_wbgtravel.cities on cities.city_id = trips_insert.city_id
left join pd_wbgtravel.people on people.person_id = trips_insert.person_id
left join pd_wbgtravel.users on users.user_id = trips_insert.created_by_user_id;

-- Match inserted people to upload data -- so we know which people are added for status report
update _user_action_log
	set up_ids = ups.up_ids
	from
	(
		select tr.trip_id,array_agg(distinct tt.up_id) as up_ids
		from _user_action_log ual
		inner join pd_wbgtravel.trips tr on tr.trip_id = ual.table_ids[1]
		inner join _temp_trips tt on tt.person_id = tr.person_id and tt.city_id = tr.city_id and
																 tt.trip_start_date = tr.trip_start_date and tt.trip_end_date = tr.trip_end_date
		where ual.table_name = 'trips'
		group by tr.trip_id
  ) ups
	where ups.trip_id = _user_action_log.table_ids[1] and _user_action_log.table_name = 'trips';
------------------
--END NEW TRIPS --
------------------

---------------------
--START NEW VENUES --
---------------------
raise notice 'Adding New Venues';

create temp table if not exists _temp_venues(
up_id int4, 
venue_id int4 default null, 
venue_name varchar(100), 
venue_type_id int default null, 
venue_city_id int4, 
event_title varchar(100) default null, 
event_start_date date, 
event_end_date date, 
display_flag boolean);

-- Venues will only be recognized when new trips are also created due to the join on _temp_travel_uploads
insert into _temp_venues(	up_id,	venue_name,	venue_city_id,	event_start_date,	event_end_date,	display_flag)
select distinct ttu.up_id, left(ttu."Venue",100),	tt.city_id,	tt.trip_start_date,	tt.trip_end_date,	false
from public._temp_travel_uploads ttu
inner join _temp_trips tt on tt.up_id = ttu.up_id
where coalesce(ttu."CMD",'INSERT') = 'INSERT' and ttu."Venue" is not null;


-- Where there's a similarly named event within +/- 7 days of a venue already defined, assume it's the same venue
-- If ve.venue_id is set, the event already exists -- basically excempts it from further updates
update _temp_venues
	SET venue_id = ve.venue_id
	from pd_wbgtravel.venue_events ve
	where 
	(
		lower(_temp_venues.venue_name) like '%' || lower(ve.venue_name) || '%' or
		lower(_temp_venues.venue_name) like '%' || lower(ve.venue_short_name) || '%' or
		lower(_temp_venues.venue_name) = lower(ve.event_title)
	)		
	and -- similar name
	(
		(
			abs((_temp_venues.event_start_date - ve.event_start_date)) <= 5 and -- similar time
			abs((_temp_venues.event_start_date - ve.event_start_date)) <= 5 and
			ve.venue_type_id in (select venue_type_id from pd_wbgtravel.venue_types where is_temporal_venue = true) -- is temporal
		)
		or
		(
			ve.event_start_date is null and ve.event_end_date is null -- or not a time
		)
	);

-- Guess if the venue is a temporal event venue by key words in the name; and the size of the event, which will flag for display in 
-- timelines.
update _temp_venues
	set venue_type_id = case
		when lower(venue_name) like '%summit%' or
				 lower(venue_name) like '%forum%' or
				 lower(venue_name) like '%congress%' or		 
				 lower(venue_name) like '%ceremony%' or			 
				 lower(venue_name) like '%symposium%' or 
 				 lower(venue_name) like '%olympics%' or
				 lower(venue_name) like '%world cup%' or 
 				 lower(venue_name) like '%annual%' or 
 				 lower(venue_name) like '%centennial%' or
 				 lower(venue_name) like '%anniversary%' then 
 				 (select venue_type_id from pd_wbgtravel.venue_types where type_name = 'Major Event')
 		when lower(venue_name) like '%conference%' or
				 lower(venue_name) like '%meeting%' or
 				 lower(venue_name) like '%committee%' or 
 				 lower(venue_name) like '%convocation%' or
				 lower(venue_name) like '%seminar%' or
 				 lower(venue_name) like '%session%' or 
 				 lower(venue_name) like '%fundraiser%' or 
				 lower(venue_name) like '%discussion%' or
 				 lower(venue_name) like '%retreat%' or
				 lower(venue_name) like '%launch%' or
				 lower(venue_name) like '%party%' or
 				 lower(venue_name) like '%training%' or
				 lower(venue_name) like '%show%' or
 				 lower(venue_name) like '%fair%' or
				 lower(venue_name) like '%performance%' or				 
				 lower(venue_name) like '%tour%' or			 
				 lower(venue_name) like '%event%' or
				 lower(venue_name) like '%weekly%' or 				 
				 lower(venue_name) like '%monthly%' or
				 lower(venue_name) like '%dinner%' or 				 
				 lower(venue_name) like '%lunch%' or 
 				 lower(venue_name) like '%breakfast%' or 
 				 lower(venue_name) like '%banquet%' or 
				 lower(venue_name) like '%cocktail%' then 				 			 
				 (select venue_type_id from pd_wbgtravel.venue_types where type_name = 'Small Event')
		else (select venue_type_id from pd_wbgtravel.venue_types where type_name = 'Organization') end
	where venue_id is null;

-- Upload file may have multiple trips and multiple dates for the same venue event.  It's a guess...but consolitate to ensure unique 
-- event start and end date entered into pd.wbgtravel.venue_events
-- Events already entered with a venue_id will have been already set, even if travel dates mismatch across event dates
-- Setting to max/min of whatever travel dates are entered will make as long as possible the event period and increase the liklihood that other
-- people attending events that match by the uploaded name according to +/- 5 days will select the event to find venue_id
update _temp_venues
	set event_start_date = evts.event_start_date, event_end_date = evts.event_end_date
	from 
	(
		select tv.venue_name,tv.venue_type_id,min(tv.event_start_date) as event_start_date,max(tv.event_end_date) as event_end_date
		from _temp_venues tv
		where tv.venue_id is null
		and venue_type_id in (select venue_type_id from pd_wbgtravel.venue_types where is_temporal_venue=true)
		group by tv.venue_name,tv.venue_type_id
	) evts
	where venue_id is null and evts.venue_name = _temp_venues.venue_name;

-- With consolidated dates, we can set temporal venue events to a unique name for the month and year of the event
-- this will prevent future conflicts with same-named events being entered later in the future as the same-named events will have
-- auto-created a unique name based on month of when the temporal event occurs.   "Event Title" is set to the generic name on insert
update _temp_venues
	set event_title = venue_name,
			venue_name = venue_name || ' - ' || initcap(to_char(event_start_date,'mon')) || ' ' || date_part('year',event_start_date)
	where venue_id is null and venue_type_id in (select venue_type_id from pd_wbgtravel.venue_types where is_temporal_venue=true);

update _temp_venues
	set display_flag = true
	where venue_id is null and venue_type_id in (select venue_type_id from pd_wbgtravel.venue_types where type_name = 'Major Event');
update _temp_venues
	set event_title = NULL, event_start_date = NULL, event_end_date = NULL, display_flag = false
	where venue_id is null and venue_type_id in (select venue_type_id from pd_wbgtravel.venue_types where is_temporal_venue=false);

with venue_events_insert as
(
	insert into pd_wbgtravel.venue_events(venue_name,venue_type_id,venue_city_id,event_title,event_start_date,event_end_date,display_flag)
	select distinct venue_name,venue_type_id,venue_city_id,event_title,event_start_date,event_end_date,display_flag
	from _temp_venues
	where venue_id is null
	returning venue_id,venue_name,venue_type_id,venue_city_id
)
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,1,'venue_events',ARRAY[venue_id],'Adding Venue: ' || venue_name || ' [AS] ' || venue_types.type_name || ' [IN] ' || cities.city_name
from venue_events_insert
left join pd_wbgtravel.venue_types on venue_types.venue_type_id = venue_events_insert.venue_type_id
left join pd_wbgtravel.cities on cities.city_id = venue_events_insert.venue_city_id;

update _user_action_log
	set up_ids = ups.up_ids
	from
	(
		select ve.venue_id,array_agg(distinct tv.up_id) as up_ids
		from _user_action_log ual
		inner join pd_wbgtravel.venue_events ve on ve.venue_id = ual.table_ids[1]
		inner join _temp_venues tv on tv.venue_name = ve.venue_name
		where ual.table_name = 'venue_events'
		group by ve.venue_id
  ) ups
	where ups.venue_id = _user_action_log.table_ids[1] and _user_action_log.table_name = 'venue_events';

--##Need to update guess on event start-end dates
--##Need display flag is true if lots of people attend
--##Clean up venue_events that nobody goes to and meetings that are alienated (may happen when data is updated/corrected)
-------------------
--END NEW VENUES --
-------------------


-----------------------
--START NEW MEETINGS --
-----------------------
raise notice 'Adding New Meetings';

create temp table if not exists _temp_meetings(up_id int4, travelers_trip_id int4, 
                                               meeting_person_id int4, agenda varchar(100), 
																							 meeting_venue_id int, stag_flag bool not null default false); 
delete from _temp_meetings;

-- Meetings are with a person at a place
-- Sometimes upload specifies a venue with no meeting (maybe they hope to meet people there opportunistically?)
with multi_meetings as
(
	select distinct 
		ttu.up_id,
		ualt.table_ids[1] as travelers_trip_id,
		trim(unnest(string_to_array(ttu."Meeting",','))) as meeting_person_name,
		left(ttu."Agenda",100) as agenda,
		coalesce(ualv.table_ids[1],0) as meeting_venue_id
	from public._temp_travel_uploads ttu 
	inner join _user_action_log ualt on ualt.table_name = 'trips' and ttu.up_id = any(ualt.up_ids)
	left join _user_action_log ualv on ualv.table_name = 'venue_events' and ttu.up_id = any(ualv.up_ids)
	where coalesce(ttu."CMD",'INSERT') = 'INSERT' and ttu."Meeting" is not null
)
insert into _temp_meetings(up_id,travelers_trip_id,meeting_person_id,agenda,meeting_venue_id) 
select distinct mm.up_id,mm.travelers_trip_id,people.person_id,mm.agenda,mm.meeting_venue_id
from multi_meetings mm
inner join pd_wbgtravel.people on lower(people.short_name) = lower(mm.meeting_person_name)
where not exists(select * from pd_wbgtravel.trip_meetings 
								 where trip_meetings.meeting_person_id = people.person_id and 
											 trip_meetings.travelers_trip_id = mm.travelers_trip_id and
											 trip_meetings.meeting_venue_id = mm.meeting_venue_id);

-- Stag meetings are where an upload entry specified a trip at a venue with on meeting counterpart
-- This condition requires creating a self-meeting so that a venue does not appear as an abandoned venue 
-- (meetings happen at venues -- and without a meeting, no venue to link to a trip)

with stag_meetings as (
	select distinct 
		ttu.up_id,
		ualt.table_ids[1] as travelers_trip_id,
		left(ttu."Meeting",40) as meeting_person_name,
		left(ttu."Agenda",100) as agenda,
		coalesce(ualv.table_ids[1],0) as meeting_venue_id
	from public._temp_travel_uploads ttu 
	inner join _user_action_log ualt on ualt.table_name = 'trips' and ttu.up_id = any(ualt.up_ids)
	inner join _user_action_log ualv on ualv.table_name = 'venue_events' and ttu.up_id = any(ualv.up_ids)
	where coalesce(ttu."CMD",'INSERT') = 'INSERT' and ttu."Meeting" is null and ualv.table_ids[1] is not null
)
insert into _temp_meetings(up_id,travelers_trip_id,meeting_person_id,agenda,meeting_venue_id,stag_flag) 
select distinct sm.up_id,sm.travelers_trip_id,trips.person_id,sm.agenda,sm.meeting_venue_id,true
from stag_meetings sm
inner join pd_wbgtravel.trips on trips.trip_id = sm.travelers_trip_id
where not exists(select * from pd_wbgtravel.trip_meetings 
								 where trip_meetings.meeting_person_id = trips.person_id and 
								       trip_meetings.travelers_trip_id = sm.travelers_trip_id and
											 trip_meetings.meeting_venue_id = sm.meeting_venue_id);

with meetings_insert as
(
insert into pd_wbgtravel.trip_meetings(meeting_person_id,travelers_trip_id,agenda,meeting_venue_id,stag_flag)
select meeting_person_id,travelers_trip_id,left(array_to_string(array_agg(distinct agenda),','),100),meeting_venue_id,stag_flag
from _temp_meetings
where not exists(select * from pd_wbgtravel.trip_meetings 
                 where trip_meetings.meeting_person_id = _temp_meetings.meeting_person_id and 
								       trip_meetings.travelers_trip_id = _temp_meetings.travelers_trip_id and 
											 trip_meetings.meeting_venue_id = _temp_meetings.meeting_venue_id)
group by meeting_person_id,travelers_trip_id,meeting_venue_id,stag_flag
			 
returning meeting_person_id,travelers_trip_id,meeting_venue_id,stag_flag
)
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,1,'trip_meetings',ARRAY[mi.meeting_person_id,mi.travelers_trip_id],
	'Adding Meeting: ' || p1.short_name || ' [AND] ' || p2.short_name || 
	case when mi.meeting_venue_id = 0 then ' [IN] ' || ci.city_name else ' [AT] ' || ve.venue_name end
from meetings_insert mi
left join pd_wbgtravel.trips tr on tr.trip_id = mi.travelers_trip_id
left join pd_wbgtravel.cities ci on ci.city_id = tr.city_id
left join pd_wbgtravel.people p1 on p1.person_id = mi.meeting_person_id
left join pd_wbgtravel.people p2 on p2.person_id = tr.person_id
left join pd_wbgtravel.venue_events ve on ve.venue_id = mi.meeting_venue_id;

update _user_action_log
	set up_ids = ups.up_ids
	from
	(
		select tm.meeting_person_id,tm.travelers_trip_id,array_agg(distinct tm.up_id) as up_ids
		from _user_action_log ual
		inner join _temp_meetings tm on tm.meeting_person_id = ual.table_ids[1] and tm.travelers_trip_id = ual.table_ids[2]
		where ual.table_name = 'trip_meetings'
		group by tm.meeting_person_id,tm.travelers_trip_id	
	) ups
	where _user_action_log.table_name = 'trip_meetings' and
	      ups.meeting_person_id = _user_action_log.table_ids[1] and ups.travelers_trip_id = _user_action_log.table_ids[2];

---------------------
--END NEW MEETINGS --
---------------------

-----------------
--START STATUS --
-----------------

raise notice 'Recording action log';
insert into pd_wbgtravel.user_action_log(user_id,user_action_id,table_name,table_ids,action_time,note)
select user_id,user_action_id,"table_name",table_ids,action_time,note
from _user_action_log;

insert into _user_action_log(user_id,user_action_id,table_name,table_ids,up_ids,note)
select v_user_id,1,'trip_uploads',ARRAY[_temp_travel_uploads.up_id],
	ARRAY[_temp_travel_uploads.up_id],'>ERROR< Missing Field or under 3 characters'
from public._temp_travel_uploads where "CMD" = 'ERROR';

raise notice 'Returning Results of Upload';

RETURN QUERY 
select * --q.change,q."Person",q."Organization",q."City",q."Country",q."Start",q."End",q."Venue",q."Meeting",q."Agenda",q."STATUS"
from
(
select distinct case when lbu.up_id is null then 0 else 1 end::int2 as change,
			 ttu.up_id,ttu."Person",ttu."Organization",ttu."City",ttu."Country",ttu."Start",
       ttu."End",ttu."Trip Group",ttu."Venue",ttu."Meeting",ttu."Agenda",COALESCE(lbu.note,'<SKIPPED>')::varchar as STATUS
from public._temp_travel_uploads ttu
left join (select distinct unnest(up_ids) as up_id,note from _user_action_log) lbu on lbu.up_id = ttu.up_id

union all

select distinct 1::int2 as change, -1 as up_id, null as "Person", null as "Organization", null as "City", null as "Country", null::date as "Start",
	null::date as "End", null as "Trip Group",null as "Venue", null as "Meeting", null as "Agenda", ual.note::varchar as STATUS
from _temp_abandoned_log tal inner join pd_wbgtravel.user_action_log ual on ual.log_id = tal.log_id
) q
order by q.up_id desc,"STATUS";

raise notice 'Cleaning Up Temp Tables';

drop table if exists _temp_people;
drop table if exists _temp_cities;
drop table if exists _temp_trips;
drop table if exists _temp_meetings;
drop table if exists _temp_status;
drop table if exists _temp_venues;
drop table if exists _temp_abandoned_log;
drop table if exists _user_action_log;

END;
$$;


ALTER FUNCTION pd_wbgtravel.travel_uploads(v_user_id integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 43176)
-- Name: trip_uid_trigger(); Type: FUNCTION; Schema: pd_wbgtravel; Owner: postgres
--

CREATE FUNCTION trip_uid_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
   NEW.trip_uid = md5(NEW.trip_id::varchar)::varchar;
   RETURN NEW;
END;$$;


ALTER FUNCTION pd_wbgtravel.trip_uid_trigger() OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 255 (class 1255 OID 40494)
-- Name: grant_default_privileges_for_arl_team_applications(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION grant_default_privileges_for_arl_team_applications(sch_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin

execute 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || sch_name || '" GRANT ALL ON TABLES TO "ARLTeam", "Applications";';
execute 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || sch_name || '" GRANT ALL ON SEQUENCES TO "ARLTeam", "Applications";';
execute 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || sch_name || '" GRANT ALL ON FUNCTIONS TO "ARLTeam", "Applications";';
execute 'GRANT ALL ON ALL TABLES IN SCHEMA "' || sch_name || '" TO "Applications","ARLTeam";';
execute 'GRANT USAGE, UPDATE, SELECT ON ALL SEQUENCES IN SCHEMA "' || sch_name || '" TO "Applications","ARLTeam";';
execute 'GRANT ALL ON ALL FUNCTIONS IN SCHEMA "' || sch_name || '" TO "Applications","ARLTeam";';
end
$$;


ALTER FUNCTION public.grant_default_privileges_for_arl_team_applications(sch_name text) OWNER TO postgres;

SET search_path = pd_wbgtravel, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 238 (class 1259 OID 40536)
-- Name: cities; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE cities (
    city_id integer NOT NULL,
    city_name character varying(50) NOT NULL,
    country_name character varying(50) NOT NULL,
    latitude numeric(12,9),
    longitude numeric(12,9)
);


ALTER TABLE cities OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 40534)
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE cities_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cities_city_id_seq OWNER TO postgres;

--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 237
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE cities_city_id_seq OWNED BY cities.city_id;


--
-- TOC entry 234 (class 1259 OID 40512)
-- Name: people; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE people (
    person_id integer NOT NULL,
    full_name character varying(50),
    short_name character varying(40) NOT NULL,
    title character varying(20),
    organization character varying(50) NOT NULL,
    sub_organization character varying(20),
    image_file character varying(255),
    is_wbg smallint,
    time_created timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE people OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 40510)
-- Name: people_person_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE people_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE people_person_id_seq OWNER TO postgres;

--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 233
-- Name: people_person_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE people_person_id_seq OWNED BY people.person_id;


--
-- TOC entry 239 (class 1259 OID 40646)
-- Name: trip_meetings; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE trip_meetings (
    meeting_person_id integer NOT NULL,
    travelers_trip_id integer NOT NULL,
    description text,
    meeting_venue_id integer DEFAULT 0 NOT NULL,
    agenda character varying(100),
    stag_flag boolean DEFAULT false NOT NULL
);


ALTER TABLE trip_meetings OWNER TO postgres;

--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN trip_meetings.meeting_person_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.meeting_person_id IS 'ID of person I am meeting';


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN trip_meetings.travelers_trip_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.travelers_trip_id IS 'ID of my trip';


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN trip_meetings.meeting_venue_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.meeting_venue_id IS 'Zero defaults to ''Unspecified Venue'' which must be pre-filled in venue_events, such as through init_database()';


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN trip_meetings.stag_flag; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.stag_flag IS 'Flag for when meeting_person_id is the same as traveler on travelers_trip_id -- stag meetings are creatd to enable meetingless trips to record a venue';


--
-- TOC entry 236 (class 1259 OID 40525)
-- Name: trips; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE trips (
    trip_id integer NOT NULL,
    person_id integer NOT NULL,
    city_id integer NOT NULL,
    trip_start_date date NOT NULL,
    trip_end_date date NOT NULL,
    time_created timestamp without time zone DEFAULT now() NOT NULL,
    created_by_user_id integer,
    trip_group_id integer,
    trip_group character varying(75),
    trip_uid character varying(50) NOT NULL
);


ALTER TABLE trips OWNER TO postgres;

--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN trips.created_by_user_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trips.created_by_user_id IS 'Who created the trip?  For user access segmentation; eg display trips and all associated table information only to users/groups who created the trip';


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN trips.trip_group_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trips.trip_group_id IS 'For segmenting, eg by departments or filtering at a high level of UI';


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN trips.trip_uid; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trips.trip_uid IS 'A unique ID to provide/display to users for updating and deleting and prevent accidental changes due to number swaps, typos; eg delete ID=123 vs delete ID=132 accidents';


--
-- TOC entry 235 (class 1259 OID 40523)
-- Name: trips_trip_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE trips_trip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trips_trip_id_seq OWNER TO postgres;

--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 235
-- Name: trips_trip_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE trips_trip_id_seq OWNED BY trips.trip_id;


--
-- TOC entry 247 (class 1259 OID 42551)
-- Name: user_action_log; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE user_action_log (
    log_id integer NOT NULL,
    user_id integer,
    user_action_id integer,
    table_name character varying(50),
    table_ids integer[],
    action_time timestamp without time zone DEFAULT now() NOT NULL,
    note character varying(255)
);


ALTER TABLE user_action_log OWNER TO postgres;

--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN user_action_log.user_action_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN user_action_log.user_action_id IS '1=insert,0=update,-1=delete';


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN user_action_log.table_ids; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN user_action_log.table_ids IS 'array of ID(s) for table';


--
-- TOC entry 246 (class 1259 OID 42549)
-- Name: user_action_log_log_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE user_action_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_action_log_log_id_seq OWNER TO postgres;

--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 246
-- Name: user_action_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE user_action_log_log_id_seq OWNED BY user_action_log.log_id;


--
-- TOC entry 245 (class 1259 OID 42532)
-- Name: users; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE users (
    user_id integer NOT NULL,
    user_role character varying(255) NOT NULL,
    user_password character varying(255),
    can_login boolean DEFAULT true NOT NULL,
    last_login timestamp(6) without time zone,
    note text
);


ALTER TABLE users OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 42530)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_user_id_seq OWNER TO postgres;

--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 244
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;


--
-- TOC entry 241 (class 1259 OID 42370)
-- Name: venue_events; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE venue_events (
    venue_id integer NOT NULL,
    venue_name character varying(100) NOT NULL,
    venue_short_name character varying(50),
    venue_type_id integer DEFAULT 1 NOT NULL,
    venue_city_id integer,
    event_title character varying(100) DEFAULT ''::character varying,
    event_start_date date,
    event_end_date date,
    display_flag boolean DEFAULT false NOT NULL
);


ALTER TABLE venue_events OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 42368)
-- Name: venue_events_venue_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE venue_events_venue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE venue_events_venue_id_seq OWNER TO postgres;

--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 240
-- Name: venue_events_venue_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE venue_events_venue_id_seq OWNED BY venue_events.venue_id;


--
-- TOC entry 243 (class 1259 OID 42387)
-- Name: venue_types; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE venue_types (
    venue_type_id integer NOT NULL,
    type_name character varying(100),
    is_temporal_venue boolean DEFAULT false NOT NULL
);


ALTER TABLE venue_types OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 42385)
-- Name: venue_types_venue_type_id_seq; Type: SEQUENCE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE SEQUENCE venue_types_venue_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE venue_types_venue_type_id_seq OWNER TO postgres;

--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 242
-- Name: venue_types_venue_type_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE venue_types_venue_type_id_seq OWNED BY venue_types.venue_type_id;


--
-- TOC entry 249 (class 1259 OID 44948)
-- Name: view_trip_coincidences; Type: VIEW; Schema: pd_wbgtravel; Owner: postgres
--

CREATE VIEW view_trip_coincidences AS
 WITH trips_cities_people AS (
         SELECT tr.created_by_user_id,
            tr.trip_id,
            tr.person_id,
            pe.short_name,
            pe.is_wbg,
            pe.organization,
            tr.city_id,
            tr.trip_start_date,
            tr.trip_end_date,
            tr.trip_group,
            ci.latitude,
            ci.longitude,
            ci.city_name,
            ci.country_name
           FROM ((trips tr
             JOIN cities ci ON ((ci.city_id = tr.city_id)))
             JOIN people pe ON ((pe.person_id = tr.person_id)))
        ), trip_coincidences AS (
         SELECT t1.created_by_user_id,
            t1.trip_id,
            t1.city_id,
            t1.person_id,
            t1.short_name AS person_name,
            t1.is_wbg,
            t1.organization,
            t1.city_name,
            t1.country_name,
            t1.trip_start_date,
            t1.trip_end_date,
            t1.trip_group,
            t2.trip_id AS coincidence_trip_id,
            t2.city_id AS coincidence_city_id,
            t2.person_id AS coincidence_person_id,
            t2.short_name AS coincidence_person_name,
            t2.is_wbg AS coincidence_is_wbg,
            t2.organization AS coincidence_organization,
            t2.city_name AS coincidence_city_name,
            t2.country_name AS coincidence_country_name,
            t2.trip_group AS coincidence_trip_group
           FROM (trips_cities_people t1
             JOIN trips_cities_people t2 ON (((t1.created_by_user_id = t2.created_by_user_id) AND (t1.trip_id <> t2.trip_id) AND (t1.person_id <> t2.person_id) AND ((((t2.trip_start_date >= t1.trip_start_date) AND (t2.trip_start_date <= t1.trip_end_date)) OR ((t2.trip_end_date >= t1.trip_start_date) AND (t2.trip_end_date <= t1.trip_end_date))) AND (((((t1.latitude - t2.latitude) ^ (2)::numeric) + ((t1.longitude - t2.longitude) ^ (2)::numeric)) ^ 0.5) < (1)::numeric)))))
        ), trip_coincidence_meetings AS (
         SELECT tc.created_by_user_id,
            tc.trip_id,
            tc.city_id,
            tc.person_id,
            tc.person_name,
            tc.is_wbg,
            tc.organization,
            tc.city_name,
            tc.country_name,
            tc.trip_start_date,
            tc.trip_end_date,
            tc.trip_group,
            tc.coincidence_trip_id,
            tc.coincidence_city_id,
            tc.coincidence_person_id,
            tc.coincidence_person_name,
            tc.coincidence_is_wbg,
            tc.coincidence_organization,
            tc.coincidence_city_name,
            tc.coincidence_country_name,
            tc.coincidence_trip_group,
            'YES'::character varying(3) AS has_coincidence,
            (
                CASE
                    WHEN (lower(btrim((tc.organization)::text)) = lower(btrim((tc.coincidence_organization)::text))) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS is_colleague_coincidence,
            (
                CASE
                    WHEN (tm.meeting_person_id IS NOT NULL) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS has_meeting,
            (
                CASE
                    WHEN (tm.stag_flag = true) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS is_stag_meeting,
                CASE
                    WHEN (tm.meeting_person_id IS NOT NULL) THEN tc.coincidence_person_name
                    ELSE NULL::character varying
                END AS meeting_person_name,
                CASE
                    WHEN (ve.venue_id IS NULL) THEN tc.city_name
                    ELSE COALESCE(ve.event_title, ve.venue_name)
                END AS meeting_venue,
                CASE
                    WHEN (vt.venue_type_id IS NULL) THEN 'City'::character varying
                    ELSE vt.type_name
                END AS meeting_venue_type,
            tm.agenda
           FROM (((trip_coincidences tc
             LEFT JOIN trip_meetings tm ON ((((tm.travelers_trip_id = tc.trip_id) AND (tm.meeting_person_id = tc.coincidence_person_id)) OR ((tm.travelers_trip_id = tc.coincidence_trip_id) AND (tm.meeting_person_id = tc.person_id)))))
             LEFT JOIN venue_events ve ON ((ve.venue_id = tm.meeting_venue_id)))
             LEFT JOIN venue_types vt ON ((vt.venue_type_id = ve.venue_type_id)))
        ), all_trips_meetings_coincidences AS (
         SELECT tcp.created_by_user_id,
            tcp.trip_id,
            tcp.city_id,
            tcp.person_id,
            tcp.short_name AS person_name,
            tcp.is_wbg,
            tcp.organization,
            tcp.city_name,
            tcp.country_name,
            tcp.trip_start_date,
            tcp.trip_end_date,
            tcp.trip_group,
            NULL::integer AS coincidence_trip_id,
            NULL::integer AS coincidence_city_id,
            NULL::integer AS coincidence_person_id,
            NULL::character varying AS coincidence_person_name,
            NULL::smallint AS coincidence_is_wbg,
            NULL::character varying AS coincidence_organization,
            NULL::character varying AS coincidence_city_name,
            NULL::character varying AS coincidence_country_name,
            NULL::character varying AS coincidence_trip_group,
            'NO'::character varying(3) AS has_coincidence,
            'NO'::character varying(3) AS is_colleague_coincidence,
            (
                CASE
                    WHEN (tm.meeting_person_id IS NOT NULL) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS has_meeting,
            (
                CASE
                    WHEN (tm.stag_flag = true) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS is_stag_meeting,
            pe.short_name AS meeting_person_name,
                CASE
                    WHEN (ve.venue_id IS NULL) THEN tcp.city_name
                    ELSE COALESCE(ve.event_title, ve.venue_name)
                END AS meeting_venue,
                CASE
                    WHEN (vt.venue_type_id IS NULL) THEN 'City'::character varying
                    ELSE vt.type_name
                END AS meeting_venue_type,
            tm.agenda AS meeting_agenda
           FROM ((((trips_cities_people tcp
             LEFT JOIN trip_meetings tm ON ((tm.travelers_trip_id = tcp.trip_id)))
             LEFT JOIN people pe ON ((pe.person_id = tm.meeting_person_id)))
             LEFT JOIN venue_events ve ON ((ve.venue_id = tm.meeting_venue_id)))
             LEFT JOIN venue_types vt ON ((vt.venue_type_id = ve.venue_type_id)))
          WHERE (NOT (EXISTS ( SELECT tcm.created_by_user_id,
                    tcm.trip_id,
                    tcm.city_id,
                    tcm.person_id,
                    tcm.person_name,
                    tcm.is_wbg,
                    tcm.organization,
                    tcm.city_name,
                    tcm.country_name,
                    tcm.trip_start_date,
                    tcm.trip_end_date,
                    tcm.trip_group,
                    tcm.coincidence_trip_id,
                    tcm.coincidence_city_id,
                    tcm.coincidence_person_id,
                    tcm.coincidence_person_name,
                    tcm.coincidence_is_wbg,
                    tcm.coincidence_organization,
                    tcm.coincidence_city_name,
                    tcm.coincidence_country_name,
                    tcm.coincidence_trip_group,
                    tcm.has_coincidence,
                    tcm.is_colleague_coincidence,
                    tcm.has_meeting,
                    tcm.is_stag_meeting,
                    tcm.meeting_person_name,
                    tcm.meeting_venue,
                    tcm.meeting_venue_type,
                    tcm.agenda
                   FROM trip_coincidence_meetings tcm
                  WHERE ((tcm.trip_id = tcp.trip_id) AND (tcm.coincidence_person_id = tm.meeting_person_id)))))
        UNION ALL
         SELECT tcm.created_by_user_id,
            tcm.trip_id,
            tcm.city_id,
            tcm.person_id,
            tcm.person_name,
            tcm.is_wbg,
            tcm.organization,
            tcm.city_name,
            tcm.country_name,
            tcm.trip_start_date,
            tcm.trip_end_date,
            tcm.trip_group,
            tcm.coincidence_trip_id,
            tcm.coincidence_city_id,
            tcm.coincidence_person_id,
            tcm.coincidence_person_name,
            tcm.coincidence_is_wbg,
            tcm.coincidence_organization,
            tcm.coincidence_city_name,
            tcm.coincidence_country_name,
            tcm.coincidence_trip_group,
            tcm.has_coincidence,
            tcm.is_colleague_coincidence,
            tcm.has_meeting,
            tcm.is_stag_meeting,
            tcm.meeting_person_name,
            tcm.meeting_venue,
            tcm.meeting_venue_type,
            tcm.agenda AS meeting_agenda
           FROM trip_coincidence_meetings tcm
        )
 SELECT atcm.created_by_user_id,
    atcm.trip_id,
    atcm.city_id,
    atcm.person_id,
    atcm.person_name,
    atcm.is_wbg,
    atcm.organization,
    atcm.city_name,
    atcm.country_name,
    atcm.trip_start_date,
    atcm.trip_end_date,
    atcm.trip_group,
    atcm.coincidence_trip_id,
    atcm.coincidence_city_id,
    atcm.coincidence_person_id,
    atcm.coincidence_person_name,
    atcm.coincidence_is_wbg,
    atcm.coincidence_organization,
    atcm.coincidence_city_name,
    atcm.coincidence_country_name,
    atcm.coincidence_trip_group,
    atcm.has_coincidence,
    atcm.is_colleague_coincidence,
    atcm.has_meeting,
    atcm.is_stag_meeting,
    atcm.meeting_person_name,
    atcm.meeting_venue,
    atcm.meeting_venue_type,
    atcm.meeting_agenda,
    (dense_rank() OVER (ORDER BY atcm.trip_id, atcm.meeting_venue, atcm.meeting_agenda) *
        CASE
            WHEN ((atcm.has_meeting)::text = 'YES'::text) THEN 1
            ELSE NULL::integer
        END) AS trip_meeting_agenda_id
   FROM all_trips_meetings_coincidences atcm;


ALTER TABLE view_trip_coincidences OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 44943)
-- Name: view_trips_and_meetings; Type: VIEW; Schema: pd_wbgtravel; Owner: postgres
--

CREATE VIEW view_trips_and_meetings AS
 SELECT pe.is_wbg,
    pe.short_name,
    pe.organization,
    pe.title,
    pe.sub_organization,
    ci.country_name,
    ci.city_name,
    tr.trip_group,
    tr.trip_start_date,
    tr.trip_end_date,
    counterparts.short_name AS meeting_with,
    tm.agenda AS meeting_agenda
   FROM ((((trips tr
     JOIN cities ci ON ((ci.city_id = tr.city_id)))
     JOIN people pe ON ((pe.person_id = tr.person_id)))
     LEFT JOIN trip_meetings tm ON ((tm.travelers_trip_id = tr.trip_id)))
     LEFT JOIN people counterparts ON ((counterparts.person_id = tm.meeting_person_id)));


ALTER TABLE view_trips_and_meetings OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 250 (class 1259 OID 45388)
-- Name: _temp_travel_uploads; Type: TABLE; Schema: public; Owner: rscript
--

CREATE TABLE _temp_travel_uploads (
    up_id integer NOT NULL,
    "Person" character varying(50),
    "Organization" character varying(50),
    "City" character varying(50),
    "Country" character varying(50),
    "Start" date,
    "End" date,
    "Trip Group" character varying(100),
    "Venue" character varying(100),
    "Meeting" character varying(50),
    "Agenda" character varying(100),
    "CMD" character varying(50),
    "ID" character varying(50)
);


ALTER TABLE _temp_travel_uploads OWNER TO rscript;

SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3646 (class 2604 OID 40539)
-- Name: cities city_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY cities ALTER COLUMN city_id SET DEFAULT nextval('cities_city_id_seq'::regclass);


--
-- TOC entry 3642 (class 2604 OID 40515)
-- Name: people person_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY people ALTER COLUMN person_id SET DEFAULT nextval('people_person_id_seq'::regclass);


--
-- TOC entry 3644 (class 2604 OID 40528)
-- Name: trips trip_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips ALTER COLUMN trip_id SET DEFAULT nextval('trips_trip_id_seq'::regclass);


--
-- TOC entry 3657 (class 2604 OID 42554)
-- Name: user_action_log log_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY user_action_log ALTER COLUMN log_id SET DEFAULT nextval('user_action_log_log_id_seq'::regclass);


--
-- TOC entry 3655 (class 2604 OID 42535)
-- Name: users user_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);


--
-- TOC entry 3649 (class 2604 OID 42373)
-- Name: venue_events venue_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events ALTER COLUMN venue_id SET DEFAULT nextval('venue_events_venue_id_seq'::regclass);


--
-- TOC entry 3653 (class 2604 OID 42390)
-- Name: venue_types venue_type_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_types ALTER COLUMN venue_type_id SET DEFAULT nextval('venue_types_venue_type_id_seq'::regclass);


--
-- TOC entry 3822 (class 0 OID 40536)
-- Dependencies: 238
-- Data for Name: cities; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO cities VALUES (1425, 'Junkcity', 'JunkCountry', NULL, NULL);
INSERT INTO cities VALUES (1464, 'Kyiv', 'Ukraine', 50.450107100, 30.524050100);
INSERT INTO cities VALUES (1465, 'Brussels', 'Belgium', 50.846557300, 4.351697000);
INSERT INTO cities VALUES (1466, 'Rome', 'Italy', 41.893320300, 12.482932100);
INSERT INTO cities VALUES (1467, 'Dubai', 'UAE', 25.075009500, 55.188760882);
INSERT INTO cities VALUES (1468, 'Riga', 'Latvia', 56.971656200, 24.166598602);
INSERT INTO cities VALUES (1411, 'Bogota', 'Colombia', 7.877695600, -72.486618200);
INSERT INTO cities VALUES (1412, 'London', 'UK', 51.507321900, -0.127647400);
INSERT INTO cities VALUES (1413, 'Amman', 'Jordan', 31.951569400, 35.923962500);
INSERT INTO cities VALUES (1414, 'Garmisch', 'Germany', 47.490186400, 11.096061500);
INSERT INTO cities VALUES (1415, 'Dakar', 'Senegal', 14.693425000, -17.447938000);
INSERT INTO cities VALUES (1416, 'Washington, DC', 'United States', 38.894954900, -77.036645600);
INSERT INTO cities VALUES (1417, 'Tokyo', 'Japan', 34.696864200, 139.404903300);
INSERT INTO cities VALUES (1418, 'Munich', 'Germany', 48.137107900, 11.575382200);
INSERT INTO cities VALUES (1419, 'Tashkent', 'Uzbekistan', 40.480071200, 68.758595838);
INSERT INTO cities VALUES (1420, 'Jakarta', 'Indonesia', -6.175394200, 106.827183000);
INSERT INTO cities VALUES (1421, 'Jerusalem', 'Israel', 31.789117650, 35.222973014);
INSERT INTO cities VALUES (1422, 'Seoul', 'Republic of Korea', 37.566679100, 126.978291400);
INSERT INTO cities VALUES (1423, 'Cairo', 'Egypt', 30.048819000, 31.243666000);
INSERT INTO cities VALUES (1424, 'Vancouver', 'Canada', 49.260872400, -123.113952900);
INSERT INTO cities VALUES (1426, 'Sydney', 'Australia', -33.854815700, 151.216453900);
INSERT INTO cities VALUES (1427, 'Mexico City', 'Mexico', 19.432600900, -99.133341600);
INSERT INTO cities VALUES (1428, 'Kingston', 'Jamaica', 17.971214800, -76.792812800);
INSERT INTO cities VALUES (1429, 'Warsaw', 'Poland', 52.231923700, 21.006726500);
INSERT INTO cities VALUES (1430, 'Seoul', 'South Korea', 37.566679100, 126.978291400);
INSERT INTO cities VALUES (1431, 'Monrovia', 'Liberia', 6.328034000, -10.797788000);
INSERT INTO cities VALUES (1432, 'Beirut', 'Lebanon', 33.895920300, 35.478430000);
INSERT INTO cities VALUES (1433, 'Paris', 'France', 48.856610100, 2.351499200);
INSERT INTO cities VALUES (1434, 'Ankara', 'Turkey', 39.921521900, 32.853792900);
INSERT INTO cities VALUES (1435, 'Buenos Aires', 'Argentina', -34.645238400, -58.393096900);
INSERT INTO cities VALUES (1436, 'Davos', 'Switzerland', 46.796174400, 9.823726600);
INSERT INTO cities VALUES (1437, 'Kuwait City', 'Kuwait', 29.379709100, 47.973562900);
INSERT INTO cities VALUES (1438, 'Lima', 'Peru', -12.062106500, -77.036525600);


--
-- TOC entry 3818 (class 0 OID 40512)
-- Dependencies: 234
-- Data for Name: people; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO people VALUES (6218, NULL, 'Abdel Fattah El-Sisi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6219, NULL, 'Abdulaziz Kamilov', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6220, NULL, 'Abdullah Il Ibn Al-Hussein', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6221, NULL, 'Adel Al-Jubeir', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6222, NULL, 'Ali Bin Al Hussein', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6223, NULL, 'Andrew Holness', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6224, NULL, 'Ayman Al-Safadi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6225, NULL, 'Bill Morneau', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6226, NULL, 'Cayetana Alijovin', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6227, NULL, 'Dara Khosrowshahi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6228, NULL, 'David Miliband', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6229, NULL, 'Djamshid Kuchkarov', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6230, NULL, 'Donald Trump', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6231, NULL, 'Emmanuel Macron', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6232, NULL, 'Enrique Pena Nieto', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6233, NULL, 'Frans Van Houten', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6234, NULL, 'Gary Cohen', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6235, NULL, 'George Soros', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6236, NULL, 'Haider Al-Abadi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6237, NULL, 'Hasssan Ali Khaire', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6238, NULL, 'H.R. Mcmaster', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6239, NULL, 'Jared Kushner', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6241, NULL, 'Jimmy Morales', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6242, NULL, 'Joachim Wenning', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6243, NULL, 'John Kelly', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6244, NULL, 'John Sullivan', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6245, NULL, 'Jorge Faurie', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6246, NULL, 'Juan Manuel Santos', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6247, NULL, 'Kamina Johnson Smith', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6248, NULL, 'Kirstjen Nielsen', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6250, NULL, 'Lim Sing-Nam', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6251, NULL, 'Luis Videgaray', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6252, NULL, 'Machy Sall', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6253, NULL, 'Madeline Albright', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6254, NULL, 'Maria Angela Holguin', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6255, NULL, 'Mark Green', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6256, NULL, 'Mark Suzman', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6257, NULL, 'Mauricio Marci', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6258, NULL, 'Michel Aoun', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6259, NULL, 'Mike Pence', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6260, NULL, 'Nursultan Nazarbayev', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6261, NULL, 'Pedro Pablo Kuczynski', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6262, NULL, 'Perry Acosta', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6263, NULL, 'Petri Gormiztka', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6264, NULL, 'Queen Mathilde Of Belgium', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6265, NULL, 'Rex Tillerson', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6266, NULL, 'Roch Marc Christian Kabore', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6267, NULL, 'Saad Hariri', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6268, NULL, 'Sabah Al-Khalid-Sabah', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6269, NULL, 'Sameh Shoukry', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6270, NULL, 'Shavkat Mirziyoyev', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6271, NULL, 'Sheikh Sabah Al-Ahmad Al-Sabah', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6272, NULL, 'Steve Mnuchin', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6273, NULL, 'Sukhrob Kholmurodov', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6274, NULL, 'Tom Shannon', NULL, 'US Government', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6275, NULL, 'Yang Jiechi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6249, NULL, 'Kristalina Georgieva', NULL, 'World Bank', NULL, NULL, 1, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6240, NULL, 'Jim Kim', NULL, 'World Bank', NULL, NULL, 1, '2018-02-23 09:42:47.962485');
INSERT INTO people VALUES (6303, NULL, 'G5 Sahel Donors', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 12:48:20.694672');
INSERT INTO people VALUES (6304, NULL, 'Nato Conference', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 12:48:20.694672');
INSERT INTO people VALUES (6305, NULL, ' U.S.-Uk Strategic Dialogue On Developme', NULL, 'Unknown', NULL, NULL, 0, '2018-02-23 12:48:20.694672');


--
-- TOC entry 3823 (class 0 OID 40646)
-- Dependencies: 239
-- Data for Name: trip_meetings; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO trip_meetings VALUES (6249, 6143, NULL, 640, 'Munich Security Conference', true);
INSERT INTO trip_meetings VALUES (6233, 6092, NULL, 644, 'Bilateral Meeting with Royal Philips CEO', false);
INSERT INTO trip_meetings VALUES (6266, 6091, NULL, 642, 'Bilateral Meeting with Burkinabe President', false);
INSERT INTO trip_meetings VALUES (6255, 6134, NULL, 640, 'Munich Security Conference', true);
INSERT INTO trip_meetings VALUES (6236, 6139, NULL, 639, 'Bilateral Meeting with Iraqi Prime Minister', false);
INSERT INTO trip_meetings VALUES (6256, 6112, NULL, 644, 'Meeting with Bill & Melinda Gates Representative', false);
INSERT INTO trip_meetings VALUES (6252, 6091, NULL, 642, 'Bilateral Meeting with Senegalese President', false);
INSERT INTO trip_meetings VALUES (6239, 6141, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6231, 6091, NULL, 642, 'Bilateral Meeting with French President', false);
INSERT INTO trip_meetings VALUES (6238, 6125, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6243, 6090, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6265, 6133, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6237, 6114, NULL, 644, 'Bilateral Meeting with Somali PM', false);
INSERT INTO trip_meetings VALUES (6248, 6097, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6241, 6123, NULL, 641, 'National Prayer Breakfast with Guatamalan Presiden', false);
INSERT INTO trip_meetings VALUES (6264, 6112, NULL, 644, 'Bilateral Meeting with Queen of Belgium', false);
INSERT INTO trip_meetings VALUES (6240, 6108, NULL, 640, 'Munich Security Conference', true);
INSERT INTO trip_meetings VALUES (6235, 6122, NULL, 644, 'Lunch', false);
INSERT INTO trip_meetings VALUES (6230, 6095, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6255, 6093, NULL, 638, 'Africa Strategic Integration Conference', true);
INSERT INTO trip_meetings VALUES (6227, 6099, NULL, 644, 'Bilateral Meeting with Uber CEO', false);
INSERT INTO trip_meetings VALUES (6234, 6128, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6265, 6139, NULL, 639, 'Participates in Iraqi Reconstruction Conference', true);
INSERT INTO trip_meetings VALUES (6225, 6122, NULL, 644, 'Bilateral Meetings with Canadian Finance Minister', false);
INSERT INTO trip_meetings VALUES (6262, 6115, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6272, 6104, NULL, 644, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6242, 6092, NULL, 644, 'Bilateral Meeting with Chairman of Munich Re', false);
INSERT INTO trip_meetings VALUES (6259, 6107, NULL, 643, 'Olympics and Bilateral Meetings', true);
INSERT INTO trip_meetings VALUES (6270, 6111, NULL, 0, 'Bilateral Meetings with PM', false);
INSERT INTO trip_meetings VALUES (6269, 6117, NULL, 0, 'Bilateral Meetings with Egyptian Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6219, 6126, NULL, 0, 'Bilateral Meeting with Uzbek Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6224, 6098, NULL, 0, 'Bilateral Meeting with Jordanian Minister of Forei', false);
INSERT INTO trip_meetings VALUES (6251, 6113, NULL, 0, 'Bilateral Meeting with Mexico Foreign Secretary', false);
INSERT INTO trip_meetings VALUES (6241, 6094, NULL, 0, 'Bilateral Meeting with Guatamalan President', false);
INSERT INTO trip_meetings VALUES (6253, 6102, NULL, 0, 'Meeting with Madeline Albright', false);
INSERT INTO trip_meetings VALUES (6228, 6126, NULL, 0, 'Bilateral Meeting with International Rescue Commit', false);
INSERT INTO trip_meetings VALUES (6258, 6120, NULL, 0, 'Bilateral Meeting with Lebanese President', false);
INSERT INTO trip_meetings VALUES (6223, 6101, NULL, 0, 'Bilateral Meeting with Jamaican Prime Minister', false);
INSERT INTO trip_meetings VALUES (6218, 6136, NULL, 0, 'Bilateral Meetings', false);
INSERT INTO trip_meetings VALUES (6247, 6101, NULL, 0, 'Bilateral Meetings with Jamaican Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6257, 6124, NULL, 0, 'Bilateral Meeting Argentine President ', false);
INSERT INTO trip_meetings VALUES (6275, 6094, NULL, 0, 'Bilateral Meetings with Chinese State Councilor', false);
INSERT INTO trip_meetings VALUES (6220, 6098, NULL, 0, 'Working Lunch with King of Jordan', false);
INSERT INTO trip_meetings VALUES (6261, 6110, NULL, 0, 'Bilateral Meeting with Peruvian President', false);
INSERT INTO trip_meetings VALUES (6267, 6120, NULL, 0, 'Bilateral Meeting with Lebanese Prime Minister', false);
INSERT INTO trip_meetings VALUES (6273, 6111, NULL, 0, 'Bilateral Meetings with Deputy PM', false);
INSERT INTO trip_meetings VALUES (6222, 6137, NULL, 0, 'Bilateral Meetings', false);
INSERT INTO trip_meetings VALUES (6268, 6119, NULL, 0, 'Working Dinner with Kuwaiti Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6263, 6138, NULL, 0, 'Bilateral Meeting with OECD DAC Chair', false);
INSERT INTO trip_meetings VALUES (6221, 6116, NULL, 0, 'Bilateral Meeting with Saudi Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6226, 6100, NULL, 0, 'Bilateral Meeting with Peruvian Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6250, 6131, NULL, 0, 'Bilateral Meeting with Korean Vice Foreign Ministe', false);
INSERT INTO trip_meetings VALUES (6271, 6139, NULL, 0, 'Bilateral Meeting with Kuwaiti Amir ', false);
INSERT INTO trip_meetings VALUES (6246, 6142, NULL, 0, 'Bilateral Meeting with Colombian President ', false);
INSERT INTO trip_meetings VALUES (6260, 6089, NULL, 0, 'Bilateral Meeting with Kazakh President', false);
INSERT INTO trip_meetings VALUES (6232, 6113, NULL, 0, 'Bilateral Meeting with Mexico President', false);
INSERT INTO trip_meetings VALUES (6229, 6111, NULL, 0, 'Bilateral Meetings with Finance Minister', false);
INSERT INTO trip_meetings VALUES (6254, 6142, NULL, 0, 'Bilateral Meeting with Colombian Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6218, 6117, NULL, 0, 'Bilateral Meetings with Egyptian President', false);
INSERT INTO trip_meetings VALUES (6245, 6124, NULL, 0, 'Bilateral Meeting Argentine Foreign Minister', false);


--
-- TOC entry 3820 (class 0 OID 40525)
-- Dependencies: 236
-- Data for Name: trips; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO trips VALUES (6088, 6265, 1433, '2088-01-24', '2088-01-25', '2018-02-23 09:42:47.962485', 1, NULL, '', 'c4bca428211c2b48b81fd3b12afd2aa1');
INSERT INTO trips VALUES (6089, 6230, 1416, '2088-01-19', '2088-01-19', '2018-02-23 09:42:47.962485', 1, NULL, '', '3bd318565e4adbe5f4b6abf2ffebf3a0');
INSERT INTO trips VALUES (6090, 6243, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', '0fcee95cc7b4f2067da8ba1e330de18e');
INSERT INTO trips VALUES (6091, 6240, 1415, '2088-02-03', '2088-02-06', '2018-02-23 09:42:47.962485', 1, NULL, '', 'a4e858c15255e55d5e1e221bd151154f');
INSERT INTO trips VALUES (6092, 6240, 1436, '2088-01-27', '2088-01-27', '2018-02-23 09:42:47.962485', 1, NULL, '', '265c2b6a26807154013753637b68d01d');
INSERT INTO trips VALUES (6093, 6255, 1414, '2088-02-17', '2088-02-18', '2018-02-23 09:42:47.962485', 1, NULL, '', '1438ecb8cb1f6fadfee2190700789d7b');
INSERT INTO trips VALUES (6094, 6265, 1416, '2088-02-10', '2088-02-10', '2018-02-23 09:42:47.962485', 1, NULL, '', 'ce5193a069bea027a60e06c57a106eb6');
INSERT INTO trips VALUES (6095, 6230, 1436, '2088-01-25', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', '000c076c390a4c357313fca29e390ece');
INSERT INTO trips VALUES (6096, 6265, 1429, '2088-01-28', '2088-01-29', '2018-02-23 09:42:47.962485', 1, NULL, '', 'e7dfca01f394755c11f853602cb2608a');
INSERT INTO trips VALUES (6097, 6248, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', 'afb79a9be5cd9762572a008088d3153e');
INSERT INTO trips VALUES (6098, 6265, 1413, '2088-02-16', '2088-02-16', '2018-02-23 09:42:47.962485', 1, NULL, '', '34e420f6e47d96669897a45586997a57');
INSERT INTO trips VALUES (6099, 6240, 1436, '2088-01-25', '2088-01-25', '2018-02-23 09:42:47.962485', 1, NULL, '', '80c0e8c4457441901351e4abbcf8c75c');
INSERT INTO trips VALUES (6100, 6265, 1438, '2088-02-07', '2088-02-07', '2018-02-23 09:42:47.962485', 1, NULL, 'LAC Travel', '802a5fd4efb36391dfa8f1991fd0f849');
INSERT INTO trips VALUES (6101, 6265, 1428, '2088-02-09', '2088-02-09', '2018-02-23 09:42:47.962485', 1, NULL, 'LAC Travel', '2cfa47a65809ea0496bbf9aa363dc5da');
INSERT INTO trips VALUES (6102, 6249, 1416, '2088-03-09', '2088-03-09', '2018-02-23 09:42:47.962485', 1, NULL, '', '7bec7e63a493e2d61891b1e4051ef75a');
INSERT INTO trips VALUES (6103, 6274, 1424, '2088-02-10', '2088-02-12', '2018-02-23 09:42:47.962485', 1, NULL, 'G7', '56880339cfb8fe04c2d17c6160d0512f');
INSERT INTO trips VALUES (6104, 6272, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', '46384036044a604b6b3316fc167fc15f');
INSERT INTO trips VALUES (6105, 6259, 1420, '2088-04-20', '2088-04-22', '2018-02-23 09:42:47.962485', 1, NULL, '', 'c1d53b7a97707b5cd1815c8d228d8ef1');
INSERT INTO trips VALUES (6106, 6274, 1431, '2088-01-25', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', '6933b5648c59d618bbb30986c84080fe');
INSERT INTO trips VALUES (6107, 6259, 1422, '2088-02-11', '2088-02-11', '2018-02-23 09:42:47.962485', 1, NULL, '', '29586cb449c90e249f1f09a0a4ee245a');
INSERT INTO trips VALUES (6108, 6240, 1418, '2088-02-18', '2088-02-19', '2018-02-23 09:42:47.962485', 1, NULL, '', 'c09b1eadea0efc7914f73ac698494b5e');
INSERT INTO trips VALUES (6109, 6255, 1412, '2088-02-20', '2088-02-21', '2018-02-23 09:42:47.962485', 1, NULL, '', '27b09e189a405b6cca6ddd7ec869c143');
INSERT INTO trips VALUES (6110, 6265, 1438, '2088-02-08', '2088-02-08', '2018-02-23 09:42:47.962485', 1, NULL, 'LAC Travel', '5460b9ea1986ec386cb64df22dff37be');
INSERT INTO trips VALUES (6111, 6249, 1419, '2088-01-20', '2088-01-20', '2018-02-23 09:42:47.962485', 1, NULL, '', '721e049e9903c3a740c4902878c99923');
INSERT INTO trips VALUES (6112, 6249, 1436, '2088-01-26', '2088-01-26', '2018-02-23 09:42:47.962485', 1, NULL, '', '0b6a27e2bfcb010e762109f0d2e042dc');
INSERT INTO trips VALUES (6113, 6265, 1427, '2088-02-03', '2088-02-04', '2018-02-23 09:42:47.962485', 1, NULL, 'LAC Travel', '0af854284f4ab0cfea8fcfd889cbb41a');
INSERT INTO trips VALUES (6114, 6249, 1436, '2088-01-27', '2088-01-27', '2018-02-23 09:42:47.962485', 1, NULL, '', '75c58d36157505a600e0695ed0b3a22d');
INSERT INTO trips VALUES (6115, 6262, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', 'c77cfd5563c8ec4bfcde94c09098ba84');
INSERT INTO trips VALUES (6116, 6265, 1416, '2088-01-14', '2088-01-14', '2018-02-23 09:42:47.962485', 1, NULL, '', '082a8bbf2c357c09f26675f9cf5bcba3');
INSERT INTO trips VALUES (6117, 6265, 1423, '2088-02-14', '2088-02-14', '2018-02-23 09:42:47.962485', 1, NULL, 'MENA Travel', '84e2d85ac232c681a641da1ec663888c');
INSERT INTO trips VALUES (6118, 6265, 1412, '2088-01-23', '2088-01-24', '2018-02-23 09:42:47.962485', 1, NULL, '', '1755c118e8859eb000eb6eca25369407');
INSERT INTO trips VALUES (6119, 6265, 1437, '2088-02-14', '2088-02-14', '2018-02-23 09:42:47.962485', 1, NULL, 'Defeat Isis Ministerial', '7bb7a62681a8a0f94ab424b06d172ca3');
INSERT INTO trips VALUES (6120, 6265, 1432, '2088-02-18', '2088-02-18', '2018-02-23 09:42:47.962485', 1, NULL, '', 'cfa258af990f9cb188d36ddb5c6eb650');
INSERT INTO trips VALUES (6121, 6259, 1421, '2088-01-24', '2088-01-24', '2018-02-23 09:42:47.962485', 1, NULL, '', '03fcd68e5673f08be96d2b6bb5be8261');
INSERT INTO trips VALUES (6122, 6249, 1436, '2088-01-25', '2088-01-25', '2018-02-23 09:42:47.962485', 1, NULL, '', '8aa2c95dc0a6833d2d0cb944555739cc');
INSERT INTO trips VALUES (6123, 6230, 1416, '2088-02-10', '2088-02-10', '2018-02-23 09:42:47.962485', 1, NULL, '', '4ca82b2a861f70cd15d83085b000dbde');
INSERT INTO trips VALUES (6124, 6265, 1435, '2088-02-05', '2088-02-07', '2018-02-23 09:42:47.962485', 1, NULL, 'LAC Travel', 'b16e8712b35e498857df08af3944b127');
INSERT INTO trips VALUES (6125, 6238, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', '6e3b0bf8b7d5956ae572b15cd7ddb0e1');
INSERT INTO trips VALUES (6126, 6274, 1416, '2088-01-19', '2088-01-19', '2018-02-23 09:42:47.962485', 1, NULL, '', '421740375847b6249d9383615831c23b');
INSERT INTO trips VALUES (6127, 6240, 1416, '2088-02-25', '2088-02-25', '2018-02-23 09:42:47.962485', 1, NULL, '', '9570efef719d705326f0ff817ef084e6');
INSERT INTO trips VALUES (6128, 6234, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', 'b72a5a099433a2099fc3d92f6ad3accf');
INSERT INTO trips VALUES (6129, 6265, 1434, '2088-02-17', '2088-02-17', '2018-02-23 09:42:47.962485', 1, NULL, '', 'acc21473c4525b922286130ffbfe00b5');
INSERT INTO trips VALUES (6130, 6259, 1430, '2088-04-16', '2088-04-19', '2018-02-23 09:42:47.962485', 1, NULL, '', '7b99efbc101a6013d2c710028bca5cbf');
INSERT INTO trips VALUES (6131, 6244, 1416, '2088-01-19', '2088-01-19', '2018-02-23 09:42:47.962485', 1, NULL, '', '392526094bcba21af9fd4102ce5ed092');
INSERT INTO trips VALUES (6132, 6240, 1425, '2088-02-11', '2088-02-12', '2018-02-23 09:42:47.962485', 1, NULL, '', '36d5ef2a011f0b3e0e0fa139228bbe18');
INSERT INTO trips VALUES (6133, 6265, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', 'c5df4f4eabf1cbcfeb50fbbf97c5289f');
INSERT INTO trips VALUES (6134, 6255, 1418, '2088-02-18', '2088-02-19', '2018-02-23 09:42:47.962485', 1, NULL, '', '1ca5c750a30312d1919ae6a4d636dcc4');
INSERT INTO trips VALUES (6135, 6259, 1426, '2088-04-22', '2088-04-26', '2018-02-23 09:42:47.962485', 1, NULL, '', '4cc5400e63624c44fadeda99f57588a6');
INSERT INTO trips VALUES (6136, 6259, 1423, '2088-01-22', '2088-01-22', '2018-02-23 09:42:47.962485', 1, NULL, '', 'c1285fcadc52c0d3dc8813fc2c2e2b2a');
INSERT INTO trips VALUES (6137, 6259, 1413, '2088-01-23', '2088-01-23', '2018-02-23 09:42:47.962485', 1, NULL, '', 'b8c8c63d4b8856c7872b225e53a6656c');
INSERT INTO trips VALUES (6138, 6255, 1416, '2088-01-19', '2088-01-19', '2018-02-23 09:42:47.962485', 1, NULL, '', 'b2ead76dfdc4ae56a2abd1896ec46291');
INSERT INTO trips VALUES (6139, 6265, 1437, '2088-02-15', '2088-02-15', '2018-02-23 09:42:47.962485', 1, NULL, 'Defeat Isis Ministerial', '618faa1728eb2ef6e3733645273ab145');
INSERT INTO trips VALUES (6140, 6259, 1417, '2088-04-19', '2088-04-20', '2018-02-23 09:42:47.962485', 1, NULL, '', '3d7d9461075eb7c37fbbfcad1d7042c1');
INSERT INTO trips VALUES (6141, 6239, 1436, '2088-01-26', '2088-01-28', '2018-02-23 09:42:47.962485', 1, NULL, '', '13d2b7361a27dbc9960ae158598a6a96');
INSERT INTO trips VALUES (6142, 6265, 1411, '2088-02-08', '2088-02-08', '2018-02-23 09:42:47.962485', 1, NULL, 'LAC Travel', '7d4ba7006351436c35e283b0be8ff56c');
INSERT INTO trips VALUES (6143, 6249, 1418, '2088-02-17', '2088-02-19', '2018-02-23 09:42:47.962485', 1, NULL, '', 'de9621d4c6fa69ce8aaa90f00e9110c5');
INSERT INTO trips VALUES (6144, 6240, 1413, '2088-02-13', '2088-02-14', '2018-02-23 09:42:47.962485', 1, NULL, '', '197f76fe309657064dbec74d9eea4be4');
INSERT INTO trips VALUES (6170, 6240, 1467, '2088-02-11', '2088-02-12', '2018-02-23 11:46:02.251492', 1, NULL, '', '2ccc2826b445aebac6f6b3f8013e7931');
INSERT INTO trips VALUES (6171, 6244, 1466, '2088-02-20', '2088-02-22', '2018-02-23 11:46:02.251492', 1, NULL, '', 'b5d3ad899f70013367f24e0b1fa75944');
INSERT INTO trips VALUES (6172, 6244, 1468, '2088-02-24', '2088-02-24', '2018-02-23 11:46:02.251492', 1, NULL, 'Nato Conference', 'c5ef831f5d34faafc22a23a602cf6e40');
INSERT INTO trips VALUES (6173, 6244, 1465, '2088-02-25', '2088-02-25', '2018-02-23 11:46:02.251492', 1, NULL, 'G5 Sahel Donors', '4ccb2d64b8159636a44b29fe2e62a841');
INSERT INTO trips VALUES (6174, 6244, 1464, '2088-02-23', '2088-02-23', '2018-02-23 11:46:02.251492', 1, NULL, '', '65b0df23fd2d449ae1e4b2d27151d73b');


--
-- TOC entry 3831 (class 0 OID 42551)
-- Dependencies: 247
-- Data for Name: user_action_log; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO user_action_log VALUES (16887, 1, 1, 'trips', '{6030}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Kuwait City [ON] 2088-02-14 {MEL:3a24b25a7b092a252166a1641ae953e7}');
INSERT INTO user_action_log VALUES (16888, 1, 1, 'trips', '{6031}', '2018-02-22 18:10:12.822358', 'Adding Trip: Tom Shannon [TO] Washington, DC [ON] 2088-01-19 {MEL:b56ea7b6aa77f6f9008bc9362fab3597}');
INSERT INTO user_action_log VALUES (16889, 1, 1, 'trips', '{6032}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Jerusalem [ON] 2088-01-24 {MEL:fb3a30a2e3e8abdcbf63f0aaaadb06e4}');
INSERT INTO user_action_log VALUES (16890, 1, 1, 'trips', '{6033}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2088-01-25 {MEL:317d17f10845da500bcf49780b7f35bf}');
INSERT INTO user_action_log VALUES (16891, 1, 1, 'trips', '{6034}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Cairo [ON] 2088-02-14 {MEL:78421a2e0e1168e5cd1b7a8d23773ce6}');
INSERT INTO user_action_log VALUES (16892, 1, 1, 'trips', '{6035}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Munich [ON] 2088-02-18 {MEL:4639475d6782a08c1e964f9a4329a254}');
INSERT INTO user_action_log VALUES (16893, 1, 1, 'trips', '{6036}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kirstjen Nielsen [TO] Davos [ON] 2088-01-26 {MEL:567b8f5f423af15818a068235807edc0}');
INSERT INTO user_action_log VALUES (16894, 1, 1, 'trips', '{6037}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kristalina Georgieva [TO] Washington, DC [ON] 2088-03-09 {MEL:8b2a9c176d358811a479f771a5874c1b}');
INSERT INTO user_action_log VALUES (16895, 1, 1, 'trips', '{6038}', '2018-02-22 18:10:12.822358', 'Adding Trip: John Sullivan [TO] Washington, DC [ON] 2088-01-19 {MEL:6bb56208f672af0dd65451f869fedfd9}');
INSERT INTO user_action_log VALUES (16896, 1, 1, 'trips', '{6039}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Dubai [ON] 2088-02-11 {MEL:eb2e9dffe58d635b7d72e99c8e61b5f2}');
INSERT INTO user_action_log VALUES (16897, 1, 1, 'trips', '{6040}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Washington, DC [ON] 2088-01-14 {MEL:4c9d1fbce4890fc2731b6a61262313b1}');
INSERT INTO user_action_log VALUES (16898, 1, 1, 'trips', '{6041}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mark Green [TO] Garmisch [ON] 2088-02-17 {MEL:58ee2794cc87707943624dc8db2ff5a0}');
INSERT INTO user_action_log VALUES (16899, 1, 1, 'trips', '{6042}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2088-01-27 {MEL:838aac83e00e8c5ca0f839c96d6cb3be}');
INSERT INTO user_action_log VALUES (16900, 1, 1, 'trips', '{6043}', '2018-02-22 18:10:12.822358', 'Adding Trip: Tom Shannon [TO] Vancouver [ON] 2088-02-10 {MEL:2e9777b99786a3ef6e5d786e2bc2e16f}');
INSERT INTO user_action_log VALUES (16901, 1, 1, 'trips', '{6044}', '2018-02-22 18:10:12.822358', 'Adding Trip: H.R. Mcmaster [TO] Davos [ON] 2088-01-26 {MEL:6b39183e7053a0106e4376f4e9c5c74d}');
INSERT INTO user_action_log VALUES (16902, 1, 1, 'trips', '{6045}', '2018-02-22 18:10:12.822358', 'Adding Trip: John Kelly [TO] Davos [ON] 2088-01-26 {MEL:f449d27f42a9b2a25b247ac15989090f}');
INSERT INTO user_action_log VALUES (16903, 1, 1, 'trips', '{6046}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Kuwait City [ON] 2088-02-15 {MEL:73a427badebe0e32caa2e1fc7530b7f3}');
INSERT INTO user_action_log VALUES (16904, 1, 1, 'trips', '{6047}', '2018-02-22 18:10:12.822358', 'Adding Trip: Steve Mnuchin [TO] Davos [ON] 2088-01-26 {MEL:98baeb82b676b662e12a7af8ad9212f6}');
INSERT INTO user_action_log VALUES (16905, 1, 1, 'trips', '{6048}', '2018-02-22 18:10:12.822358', 'Adding Trip: Gary Cohen [TO] Davos [ON] 2088-01-26 {MEL:6646b06b90bd13dabc11ddba01270d23}');
INSERT INTO user_action_log VALUES (16906, 1, 1, 'trips', '{6049}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] London [ON] 2088-01-23 {MEL:fe45e3227f3805b1314414203c4e5206}');
INSERT INTO user_action_log VALUES (16907, 1, 1, 'trips', '{6050}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Buenos Aires [ON] 2088-02-05 {MEL:6687cb56cc090abcaedefca26a8e6606}');
INSERT INTO user_action_log VALUES (16908, 1, 1, 'trips', '{6051}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mark Green [TO] London [ON] 2088-02-20 {MEL:1d0932d7f57ce74d9d9931a2c6db8a06}');
INSERT INTO user_action_log VALUES (16909, 1, 1, 'trips', '{6052}', '2018-02-22 18:10:12.822358', 'Adding Trip: Donald Trump [TO] Washington, DC [ON] 2088-01-19 {MEL:d2a10b0bd670e442b1d3caa3fbf9e695}');
INSERT INTO user_action_log VALUES (16910, 1, 1, 'trips', '{6053}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Beirut [ON] 2088-02-18 {MEL:4e55139e019a58e0084f194f758ffdea}');
INSERT INTO user_action_log VALUES (16911, 1, 1, 'trips', '{6054}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kristalina Georgieva [TO] Tashkent [ON] 2088-01-20 {MEL:417fbbf2e9d5a28a855a11894b2e795a}');
INSERT INTO user_action_log VALUES (16912, 1, 1, 'trips', '{6055}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Amman [ON] 2088-02-13 {MEL:5cd7edbe7a1a668fdc63c138002cc43a}');
INSERT INTO user_action_log VALUES (16913, 1, 1, 'trips', '{6056}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Amman [ON] 2088-01-23 {MEL:ee1abc6b5f7c6acb34ad076b05d40815}');
INSERT INTO user_action_log VALUES (16914, 1, 1, 'trips', '{6057}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Mexico City [ON] 2088-02-03 {MEL:177db6acfe388526a4c7bff88e1feb15}');
INSERT INTO user_action_log VALUES (16915, 1, 1, 'trips', '{6058}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Dakar [ON] 2088-02-03 {MEL:5b8e9841e87fb8fc590434f5d933c92c}');
INSERT INTO user_action_log VALUES (16916, 1, 1, 'trips', '{6059}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Seoul [ON] 2088-02-11 {MEL:18b91b19f6a289e7708da7f778b2c609}');
INSERT INTO user_action_log VALUES (16917, 1, 1, 'trips', '{6060}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Washington, DC [ON] 2088-02-10 {MEL:ba347fcc9a79fb74e95670b24848164f}');
INSERT INTO user_action_log VALUES (16918, 1, 1, 'trips', '{6061}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Davos [ON] 2088-01-26 {MEL:a775361d1fd47a9823a91aabf2a28a35}');
INSERT INTO user_action_log VALUES (16919, 1, 1, 'trips', '{6062}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mark Green [TO] Washington, DC [ON] 2088-01-19 {MEL:09ccf3183d9e90e5ae1f425d5f9b2c00}');
INSERT INTO user_action_log VALUES (16920, 1, 1, 'trips', '{6063}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Warsaw [ON] 2088-01-28 {MEL:ae2a2db40a12ec0131d48acc1218d2ef}');
INSERT INTO user_action_log VALUES (16921, 1, 1, 'trips', '{6064}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Paris [ON] 2088-01-24 {MEL:fb5c2bc1aa847f387022607d16adc510}');
INSERT INTO user_action_log VALUES (16922, 1, 1, 'trips', '{6065}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Sydney [ON] 2088-04-22 {MEL:dfd786998e082758be12670d856df755}');
INSERT INTO user_action_log VALUES (16923, 1, 1, 'trips', '{6066}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Kingston [ON] 2088-02-09 {MEL:2be5f9c2e3620eb73c2972d7552b6cb5}');
INSERT INTO user_action_log VALUES (16924, 1, 1, 'trips', '{6067}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jared Kushner [TO] Davos [ON] 2088-01-26 {MEL:024d2d699e6c1a82c9ba986386f4d824}');
INSERT INTO user_action_log VALUES (16925, 1, 1, 'trips', '{6068}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Washington, DC [ON] 2088-02-25 {MEL:b5ecbbf5782cc7fe9e453f3a2f26f24b}');
INSERT INTO user_action_log VALUES (16926, 1, 1, 'trips', '{6069}', '2018-02-22 18:10:12.822358', 'Adding Trip: Donald Trump [TO] Davos [ON] 2088-01-25 {MEL:55312eec654a75a08dc83de96adde735}');
INSERT INTO user_action_log VALUES (16927, 1, 1, 'trips', '{6070}', '2018-02-22 18:10:12.822358', 'Adding Trip: Tom Shannon [TO] Monrovia [ON] 2088-01-25 {MEL:a4df48d0b71376788fee0b92746fd7d5}');
INSERT INTO user_action_log VALUES (16928, 1, 1, 'trips', '{6071}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Davos [ON] 2088-01-25 {MEL:7fa1575cbd7027c9a799983a485c3c2f}');
INSERT INTO user_action_log VALUES (16929, 1, 1, 'trips', '{6072}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Lima [ON] 2088-02-08 {MEL:3ffebb08d23c609875d7177ee769a3e9}');
INSERT INTO user_action_log VALUES (16930, 1, 1, 'trips', '{6073}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kristalina Georgieva [TO] Munich [ON] 2088-02-17 {MEL:6c442e0e996fa84f344a14927703a8c1}');
INSERT INTO user_action_log VALUES (16931, 1, 1, 'trips', '{6074}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Seoul [ON] 2088-04-16 {MEL:2281f5c898351dbc6dace2ba201e7948}');
INSERT INTO user_action_log VALUES (16932, 1, 1, 'trips', '{6075}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Cairo [ON] 2088-01-22 {MEL:4a3fd911279cd8bc597fa13222ef83be}');
INSERT INTO user_action_log VALUES (16933, 1, 1, 'trips', '{6076}', '2018-02-22 18:10:12.822358', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2088-01-26 {MEL:beb22abb9ec56c0cf7ec7d811dd91a56}');
INSERT INTO user_action_log VALUES (16934, 1, 1, 'trips', '{6077}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Bogota [ON] 2088-02-08 {MEL:58182b82110146887c02dbd78719e3d5}');
INSERT INTO user_action_log VALUES (16935, 1, 1, 'trips', '{6078}', '2018-02-22 18:10:12.822358', 'Adding Trip: Perry Acosta [TO] Davos [ON] 2088-01-26 {MEL:5f8a7deb15235a128fcd99ad6bfde11e}');
INSERT INTO user_action_log VALUES (16936, 1, 1, 'trips', '{6079}', '2018-02-22 18:10:12.822358', 'Adding Trip: Donald Trump [TO] Washington, DC [ON] 2088-02-10 {MEL:b1b20d09041289e6c3fbb81850c5da54}');
INSERT INTO user_action_log VALUES (16937, 1, 1, 'trips', '{6080}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Tokyo [ON] 2088-04-19 {MEL:940392f5f32a7ade1cc201767cf83e31}');
INSERT INTO user_action_log VALUES (16938, 1, 1, 'trips', '{6081}', '2018-02-22 18:10:12.822358', 'Adding Trip: Jim Kim [TO] Davos [ON] 2088-01-27 {MEL:adf854f418fc96fb01ad92a2ed2fc35c}');
INSERT INTO user_action_log VALUES (16939, 1, 1, 'trips', '{6082}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Lima [ON] 2088-02-07 {MEL:a6e38981ecdd65fe9dcdfcd8d1f58f05}');
INSERT INTO user_action_log VALUES (16940, 1, 1, 'trips', '{6083}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mike Pence [TO] Jakarta [ON] 2088-04-20 {MEL:add5efc3f8de35d6208dc6fc154b59d3}');
INSERT INTO user_action_log VALUES (16941, 1, 1, 'trips', '{6084}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Amman [ON] 2088-02-16 {MEL:0d770c496aa3da6d2c3f2bd19e7b9d6b}');
INSERT INTO user_action_log VALUES (16942, 1, 1, 'trips', '{6085}', '2018-02-22 18:10:12.822358', 'Adding Trip: Rex Tillerson [TO] Ankara [ON] 2088-02-17 {MEL:3413ce14d52b87557e87e2c1518c2cbe}');
INSERT INTO user_action_log VALUES (16943, 1, 1, 'trips', '{6086}', '2018-02-22 18:10:12.822358', 'Adding Trip: Mark Green [TO] Munich [ON] 2088-02-18 {MEL:95e1533eb1b20a97777749fb94fdb944}');
INSERT INTO user_action_log VALUES (16944, 1, 1, 'venue_events', '{631}', '2018-02-22 18:10:12.822358', 'Adding Venue: Africa Strategic Integration Conference - Feb 2088 [AS] Small Event [IN] Garmisch');
INSERT INTO user_action_log VALUES (16945, 1, 1, 'venue_events', '{635}', '2018-02-22 18:10:12.822358', 'Adding Venue: One Planet Summit - Feb 2088 [AS] Major Event [IN] Dakar');
INSERT INTO user_action_log VALUES (16946, 1, 1, 'venue_events', '{634}', '2018-02-22 18:10:12.822358', 'Adding Venue: National Prayer Breakfast - Feb 2088 [AS] Small Event [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16947, 1, 1, 'venue_events', '{633}', '2018-02-22 18:10:12.822358', 'Adding Venue: Munich Security Conference - Feb 2088 [AS] Small Event [IN] Munich');
INSERT INTO user_action_log VALUES (16948, 1, 1, 'venue_events', '{636}', '2018-02-22 18:10:12.822358', 'Adding Venue: Winter Olympics - Feb 2088 [AS] Major Event [IN] Seoul');
INSERT INTO user_action_log VALUES (16949, 1, 1, 'venue_events', '{637}', '2018-02-22 18:10:12.822358', 'Adding Venue: World Economic Forum - Jan 2088 [AS] Major Event [IN] Davos');
INSERT INTO user_action_log VALUES (16950, 1, 1, 'venue_events', '{632}', '2018-02-22 18:10:12.822358', 'Adding Venue: Iraqi Reconstruction Conference - Feb 2088 [AS] Small Event [IN] Kuwait City');
INSERT INTO user_action_log VALUES (16951, 1, 1, 'trip_meetings', '{6161,6031}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Abdulaziz Kamilov [AND] Tom Shannon [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16952, 1, 1, 'trip_meetings', '{6199,6050}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Mauricio Marci [AND] Rex Tillerson [IN] Buenos Aires');
INSERT INTO user_action_log VALUES (16953, 1, 1, 'trip_meetings', '{6160,6075}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Abdel Fattah El-Sisi [AND] Mike Pence [IN] Cairo');
INSERT INTO user_action_log VALUES (16954, 1, 1, 'trip_meetings', '{6163,6040}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Adel Al-Jubeir [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16955, 1, 1, 'trip_meetings', '{6209,6053}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Saad Hariri [AND] Rex Tillerson [IN] Beirut');
INSERT INTO user_action_log VALUES (16956, 1, 1, 'trip_meetings', '{6183,6079}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Jimmy Morales [AND] Donald Trump [AT] National Prayer Breakfast - Feb 2088');
INSERT INTO user_action_log VALUES (16957, 1, 1, 'trip_meetings', '{6197,6086}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Mark Green [AND] Mark Green [AT] Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (16958, 1, 1, 'trip_meetings', '{6200,6053}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Michel Aoun [AND] Rex Tillerson [IN] Beirut');
INSERT INTO user_action_log VALUES (16959, 1, 1, 'trip_meetings', '{6165,6066}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Andrew Holness [AND] Rex Tillerson [IN] Kingston');
INSERT INTO user_action_log VALUES (16960, 1, 1, 'trip_meetings', '{6214,6047}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Steve Mnuchin [AND] Steve Mnuchin [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16961, 1, 1, 'trip_meetings', '{6198,6076}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Mark Suzman [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16962, 1, 1, 'trip_meetings', '{6211,6034}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Sameh Shoukry [AND] Rex Tillerson [IN] Cairo');
INSERT INTO user_action_log VALUES (16963, 1, 1, 'trip_meetings', '{6207,6046}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Rex Tillerson [AND] Rex Tillerson [AT] Iraqi Reconstruction Conference - Feb 2088');
INSERT INTO user_action_log VALUES (16964, 1, 1, 'trip_meetings', '{6205,6062}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Petri Gormiztka [AND] Mark Green [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16965, 1, 1, 'trip_meetings', '{6179,6042}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Hasssan Ali Khaire [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16966, 1, 1, 'trip_meetings', '{6174,6057}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Enrique Pena Nieto [AND] Rex Tillerson [IN] Mexico City');
INSERT INTO user_action_log VALUES (16967, 1, 1, 'trip_meetings', '{6169,6071}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Dara Khosrowshahi [AND] Jim Kim [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16968, 1, 1, 'trip_meetings', '{6184,6081}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Joachim Wenning [AND] Jim Kim [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16969, 1, 1, 'trip_meetings', '{6207,6061}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Rex Tillerson [AND] Rex Tillerson [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16970, 1, 1, 'trip_meetings', '{6196,6077}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Maria Angela Holguin [AND] Rex Tillerson [IN] Bogota');
INSERT INTO user_action_log VALUES (16971, 1, 1, 'trip_meetings', '{6217,6060}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Yang Jiechi [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16972, 1, 1, 'trip_meetings', '{6213,6046}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Sheikh Sabah Al-Ahmad Al-Sabah [AND] Rex Tillerson [IN] Kuwait City');
INSERT INTO user_action_log VALUES (16973, 1, 1, 'trip_meetings', '{6215,6054}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Sukhrob Kholmurodov [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (16974, 1, 1, 'trip_meetings', '{6202,6052}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Nursultan Nazarbayev [AND] Donald Trump [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16975, 1, 1, 'trip_meetings', '{6164,6056}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Ali Bin Al Hussein [AND] Mike Pence [IN] Amman');
INSERT INTO user_action_log VALUES (16976, 1, 1, 'trip_meetings', '{6168,6082}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Cayetana Alijovin [AND] Rex Tillerson [IN] Lima');
INSERT INTO user_action_log VALUES (16977, 1, 1, 'trip_meetings', '{6175,6081}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Frans Van Houten [AND] Jim Kim [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16978, 1, 1, 'trip_meetings', '{6189,6066}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Kamina Johnson Smith [AND] Rex Tillerson [IN] Kingston');
INSERT INTO user_action_log VALUES (16979, 1, 1, 'trip_meetings', '{6194,6058}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Machy Sall [AND] Jim Kim [AT] One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (16980, 1, 1, 'trip_meetings', '{6162,6084}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Abdullah Il Ibn Al-Hussein [AND] Rex Tillerson [IN] Amman');
INSERT INTO user_action_log VALUES (16981, 1, 1, 'trip_meetings', '{6190,6036}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Kirstjen Nielsen [AND] Kirstjen Nielsen [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16982, 1, 1, 'trip_meetings', '{6204,6078}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Perry Acosta [AND] Perry Acosta [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16983, 1, 1, 'trip_meetings', '{6192,6038}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Lim Sing-Nam [AND] John Sullivan [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16984, 1, 1, 'trip_meetings', '{6197,6041}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Mark Green [AND] Mark Green [AT] Africa Strategic Integration Conference - Feb 2088');
INSERT INTO user_action_log VALUES (16985, 1, 1, 'trip_meetings', '{6203,6072}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Pedro Pablo Kuczynski [AND] Rex Tillerson [IN] Lima');
INSERT INTO user_action_log VALUES (16986, 1, 1, 'trip_meetings', '{6160,6034}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Abdel Fattah El-Sisi [AND] Rex Tillerson [IN] Cairo');
INSERT INTO user_action_log VALUES (16987, 1, 1, 'trip_meetings', '{6176,6048}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Gary Cohen [AND] Gary Cohen [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16988, 1, 1, 'trip_meetings', '{6182,6035}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Jim Kim [AND] Jim Kim [AT] Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (16989, 1, 1, 'trip_meetings', '{6201,6059}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Mike Pence [AND] Mike Pence [AT] Winter Olympics - Feb 2088');
INSERT INTO user_action_log VALUES (16990, 1, 1, 'trip_meetings', '{6185,6045}', '2018-02-22 18:10:12.822358', 'Adding Meeting: John Kelly [AND] John Kelly [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16991, 1, 1, 'trip_meetings', '{6167,6033}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Bill Morneau [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16992, 1, 1, 'trip_meetings', '{6171,6054}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Djamshid Kuchkarov [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (16993, 1, 1, 'trip_meetings', '{6181,6067}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Jared Kushner [AND] Jared Kushner [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16994, 1, 1, 'trip_meetings', '{6187,6050}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Jorge Faurie [AND] Rex Tillerson [IN] Buenos Aires');
INSERT INTO user_action_log VALUES (16995, 1, 1, 'trip_meetings', '{6206,6076}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Queen Mathilde Of Belgium [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (16996, 1, 1, 'trip_meetings', '{6195,6037}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Madeline Albright [AND] Kristalina Georgieva [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16997, 1, 1, 'trip_meetings', '{6188,6077}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Juan Manuel Santos [AND] Rex Tillerson [IN] Bogota');
INSERT INTO user_action_log VALUES (16998, 1, 1, 'trip_meetings', '{6208,6058}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Roch Marc Christian Kabore [AND] Jim Kim [AT] One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (16999, 1, 1, 'trip_meetings', '{6183,6060}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Jimmy Morales [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17000, 1, 1, 'trip_meetings', '{6177,6033}', '2018-02-22 18:10:12.822358', 'Adding Meeting: George Soros [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17001, 1, 1, 'trip_meetings', '{6178,6046}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Haider Al-Abadi [AND] Rex Tillerson [AT] Iraqi Reconstruction Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17002, 1, 1, 'trip_meetings', '{6193,6057}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Luis Videgaray [AND] Rex Tillerson [IN] Mexico City');
INSERT INTO user_action_log VALUES (17003, 1, 1, 'trip_meetings', '{6212,6054}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Shavkat Mirziyoyev [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (17004, 1, 1, 'trip_meetings', '{6170,6031}', '2018-02-22 18:10:12.822358', 'Adding Meeting: David Miliband [AND] Tom Shannon [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17005, 1, 1, 'trip_meetings', '{6166,6084}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Ayman Al-Safadi [AND] Rex Tillerson [IN] Amman');
INSERT INTO user_action_log VALUES (17006, 1, 1, 'trip_meetings', '{6180,6044}', '2018-02-22 18:10:12.822358', 'Adding Meeting: H.R. Mcmaster [AND] H.R. Mcmaster [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17007, 1, 1, 'trip_meetings', '{6191,6073}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Kristalina Georgieva [AND] Kristalina Georgieva [AT] Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17008, 1, 1, 'trip_meetings', '{6173,6058}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Emmanuel Macron [AND] Jim Kim [AT] One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (17009, 1, 1, 'trip_meetings', '{6172,6069}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Donald Trump [AND] Donald Trump [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17010, 1, 1, 'trip_meetings', '{6210,6030}', '2018-02-22 18:10:12.822358', 'Adding Meeting: Sabah Al-Khalid-Sabah [AND] Rex Tillerson [IN] Kuwait City');
INSERT INTO user_action_log VALUES (17037, 1, -1, 'cities', '{1405}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Ankara, Turkey');
INSERT INTO user_action_log VALUES (17038, 1, -1, 'cities', '{1406}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Buenos Aires, Argentina');
INSERT INTO user_action_log VALUES (17039, 1, -1, 'cities', '{1407}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Davos, Switzerland');
INSERT INTO user_action_log VALUES (17040, 1, -1, 'cities', '{1408}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Kuwait City, Kuwait');
INSERT INTO user_action_log VALUES (17041, 1, -1, 'cities', '{1409}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Lima, Peru');
INSERT INTO user_action_log VALUES (17042, 1, -1, 'venue_events', '{624}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Africa Strategic Integration Conference - Feb 2018');
INSERT INTO user_action_log VALUES (17043, 1, -1, 'venue_events', '{631}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Africa Strategic Integration Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17044, 1, -1, 'venue_events', '{628}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: One Planet Summit - Feb 2018');
INSERT INTO user_action_log VALUES (17045, 1, -1, 'venue_events', '{635}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (17046, 1, -1, 'venue_events', '{627}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: National Prayer Breakfast - Feb 2018');
INSERT INTO user_action_log VALUES (17047, 1, -1, 'venue_events', '{634}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: National Prayer Breakfast - Feb 2088');
INSERT INTO user_action_log VALUES (16698, 1, 1, 'people', '{6183}', '2018-02-19 07:14:15.503244', 'Adding Person: Jimmy Morales');
INSERT INTO user_action_log VALUES (17048, 1, -1, 'venue_events', '{626}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Munich Security Conference - Feb 2018');
INSERT INTO user_action_log VALUES (17049, 1, -1, 'venue_events', '{633}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17011, 1, 1, 'cities', '{1410}', '2018-02-22 18:37:07.264989', 'Adding City: Junkcity, JunkCountry');
INSERT INTO user_action_log VALUES (17012, 1, 1, 'trips', '{6087}', '2018-02-22 18:37:07.264989', 'Adding Trip: Jim Kim [TO] Junkcity [ON] 2088-02-11 {MEL:5a2a330b175fe588c2551b78d18d3207}');
INSERT INTO user_action_log VALUES (17050, 1, -1, 'venue_events', '{629}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Winter Olympics - Feb 2018');
INSERT INTO user_action_log VALUES (17051, 1, -1, 'venue_events', '{636}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Winter Olympics - Feb 2088');
INSERT INTO user_action_log VALUES (17052, 1, -1, 'venue_events', '{630}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (17053, 1, -1, 'venue_events', '{637}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17054, 1, -1, 'venue_events', '{625}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Iraqi Reconstruction Conference - Feb 2018');
INSERT INTO user_action_log VALUES (17055, 1, -1, 'venue_events', '{632}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED VENUE: Iraqi Reconstruction Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17056, 1, -1, 'people', '{6160}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Abdel Fattah El-Sisi, Unknown');
INSERT INTO user_action_log VALUES (17057, 1, -1, 'people', '{6161}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Abdulaziz Kamilov, Unknown');
INSERT INTO user_action_log VALUES (17058, 1, -1, 'people', '{6162}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Abdullah Il Ibn Al-Hussein, Unknown');
INSERT INTO user_action_log VALUES (17059, 1, -1, 'people', '{6163}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Adel Al-Jubeir, Unknown');
INSERT INTO user_action_log VALUES (17060, 1, -1, 'people', '{6164}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Ali Bin Al Hussein, Unknown');
INSERT INTO user_action_log VALUES (17061, 1, -1, 'people', '{6165}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Andrew Holness, Unknown');
INSERT INTO user_action_log VALUES (17062, 1, -1, 'people', '{6166}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Ayman Al-Safadi, Unknown');
INSERT INTO user_action_log VALUES (17063, 1, -1, 'people', '{6167}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Bill Morneau, Unknown');
INSERT INTO user_action_log VALUES (17064, 1, -1, 'people', '{6168}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Cayetana Alijovin, Unknown');
INSERT INTO user_action_log VALUES (17065, 1, -1, 'people', '{6169}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Dara Khosrowshahi, Unknown');
INSERT INTO user_action_log VALUES (17066, 1, -1, 'people', '{6170}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: David Miliband, Unknown');
INSERT INTO user_action_log VALUES (17067, 1, -1, 'people', '{6171}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Djamshid Kuchkarov, Unknown');
INSERT INTO user_action_log VALUES (17068, 1, -1, 'people', '{6172}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Donald Trump, US Government');
INSERT INTO user_action_log VALUES (17069, 1, -1, 'people', '{6173}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Emmanuel Macron, Unknown');
INSERT INTO user_action_log VALUES (17070, 1, -1, 'people', '{6174}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Enrique Pena Nieto, Unknown');
INSERT INTO user_action_log VALUES (17071, 1, -1, 'people', '{6175}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Frans Van Houten, Unknown');
INSERT INTO user_action_log VALUES (17072, 1, -1, 'people', '{6176}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Gary Cohen, US Government');
INSERT INTO user_action_log VALUES (17073, 1, -1, 'people', '{6177}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: George Soros, Unknown');
INSERT INTO user_action_log VALUES (17074, 1, -1, 'people', '{6178}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Haider Al-Abadi, Unknown');
INSERT INTO user_action_log VALUES (17075, 1, -1, 'people', '{6179}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Hasssan Ali Khaire, Unknown');
INSERT INTO user_action_log VALUES (17076, 1, -1, 'people', '{6180}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: H.R. Mcmaster, US Government');
INSERT INTO user_action_log VALUES (17077, 1, -1, 'people', '{6181}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Jared Kushner, US Government');
INSERT INTO user_action_log VALUES (17078, 1, -1, 'people', '{6183}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Jimmy Morales, Unknown');
INSERT INTO user_action_log VALUES (17079, 1, -1, 'people', '{6184}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Joachim Wenning, Unknown');
INSERT INTO user_action_log VALUES (17080, 1, -1, 'people', '{6185}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: John Kelly, US Government');
INSERT INTO user_action_log VALUES (17081, 1, -1, 'people', '{6186}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: John Sullivan, US Government');
INSERT INTO user_action_log VALUES (17082, 1, -1, 'people', '{6187}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Jorge Faurie, Unknown');
INSERT INTO user_action_log VALUES (17083, 1, -1, 'people', '{6188}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Juan Manuel Santos, Unknown');
INSERT INTO user_action_log VALUES (17084, 1, -1, 'people', '{6189}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Kamina Johnson Smith, Unknown');
INSERT INTO user_action_log VALUES (17085, 1, -1, 'people', '{6190}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Kirstjen Nielsen, US Government');
INSERT INTO user_action_log VALUES (17086, 1, -1, 'people', '{6192}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Lim Sing-Nam, Unknown');
INSERT INTO user_action_log VALUES (17087, 1, -1, 'people', '{6193}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Luis Videgaray, Unknown');
INSERT INTO user_action_log VALUES (17088, 1, -1, 'people', '{6194}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Machy Sall, Unknown');
INSERT INTO user_action_log VALUES (17089, 1, -1, 'people', '{6195}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Madeline Albright, Unknown');
INSERT INTO user_action_log VALUES (17090, 1, -1, 'people', '{6196}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Maria Angela Holguin, Unknown');
INSERT INTO user_action_log VALUES (17091, 1, -1, 'people', '{6197}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Mark Green, US Government');
INSERT INTO user_action_log VALUES (17092, 1, -1, 'people', '{6198}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Mark Suzman, Unknown');
INSERT INTO user_action_log VALUES (17093, 1, -1, 'people', '{6199}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Mauricio Marci, Unknown');
INSERT INTO user_action_log VALUES (16699, 1, 1, 'people', '{6184}', '2018-02-19 07:14:15.503244', 'Adding Person: Joachim Wenning');
INSERT INTO user_action_log VALUES (17094, 1, -1, 'people', '{6200}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Michel Aoun, Unknown');
INSERT INTO user_action_log VALUES (17095, 1, -1, 'people', '{6201}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Mike Pence, US Government');
INSERT INTO user_action_log VALUES (17096, 1, -1, 'people', '{6191}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Kristalina Georgieva, World Bank');
INSERT INTO user_action_log VALUES (17097, 1, -1, 'people', '{6182}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Jim Kim, World Bank');
INSERT INTO user_action_log VALUES (17098, 1, -1, 'people', '{6202}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Nursultan Nazarbayev, Unknown');
INSERT INTO user_action_log VALUES (17099, 1, -1, 'people', '{6203}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Pedro Pablo Kuczynski, Unknown');
INSERT INTO user_action_log VALUES (17100, 1, -1, 'people', '{6204}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Perry Acosta, US Government');
INSERT INTO user_action_log VALUES (17101, 1, -1, 'people', '{6205}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Petri Gormiztka, Unknown');
INSERT INTO user_action_log VALUES (17102, 1, -1, 'people', '{6206}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Queen Mathilde Of Belgium, Unknown');
INSERT INTO user_action_log VALUES (17013, 1, -1, 'cities', '{1392}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Jerusalem, Israel');
INSERT INTO user_action_log VALUES (16582, 1, -1, 'cities', '{1354}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Bogota, Colombia');
INSERT INTO user_action_log VALUES (16583, 1, -1, 'cities', '{1355}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: London, UK');
INSERT INTO user_action_log VALUES (16584, 1, -1, 'cities', '{1356}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Amman, Jordan');
INSERT INTO user_action_log VALUES (16585, 1, -1, 'cities', '{1357}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Garmisch, Germany');
INSERT INTO user_action_log VALUES (16586, 1, -1, 'cities', '{1358}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Dakar, Senegal');
INSERT INTO user_action_log VALUES (16587, 1, -1, 'cities', '{1359}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Washington, DC, United States');
INSERT INTO user_action_log VALUES (16588, 1, -1, 'cities', '{1360}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Tokyo, Japan');
INSERT INTO user_action_log VALUES (16589, 1, -1, 'cities', '{1361}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Munich, Germany');
INSERT INTO user_action_log VALUES (16590, 1, -1, 'cities', '{1362}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Tashkent, Uzbekistan');
INSERT INTO user_action_log VALUES (16591, 1, -1, 'cities', '{1363}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Jakarta, Indonesia');
INSERT INTO user_action_log VALUES (16592, 1, -1, 'cities', '{1364}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Jerusalem, Israel');
INSERT INTO user_action_log VALUES (16593, 1, -1, 'cities', '{1365}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Seoul, Republic of Korea');
INSERT INTO user_action_log VALUES (16594, 1, -1, 'cities', '{1366}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Cairo, Egypt');
INSERT INTO user_action_log VALUES (16595, 1, -1, 'cities', '{1367}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Vancouver, Canada');
INSERT INTO user_action_log VALUES (16596, 1, -1, 'cities', '{1368}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Sydney, Australia');
INSERT INTO user_action_log VALUES (16597, 1, -1, 'cities', '{1369}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Mexico City, Mexico');
INSERT INTO user_action_log VALUES (16598, 1, -1, 'cities', '{1370}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Kingston, Jamaica');
INSERT INTO user_action_log VALUES (16599, 1, -1, 'cities', '{1371}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Warsaw, Poland');
INSERT INTO user_action_log VALUES (16600, 1, -1, 'cities', '{1372}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Seoul, South Korea');
INSERT INTO user_action_log VALUES (16601, 1, -1, 'cities', '{1373}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Monrovia, Liberia');
INSERT INTO user_action_log VALUES (16602, 1, -1, 'cities', '{1374}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Beirut, Lebanon');
INSERT INTO user_action_log VALUES (16603, 1, -1, 'cities', '{1375}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Dubai, UAE');
INSERT INTO user_action_log VALUES (16604, 1, -1, 'cities', '{1376}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Paris, France');
INSERT INTO user_action_log VALUES (16605, 1, -1, 'cities', '{1377}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Ankara, Turkey');
INSERT INTO user_action_log VALUES (16606, 1, -1, 'cities', '{1378}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Buenos Aires, Argentina');
INSERT INTO user_action_log VALUES (16607, 1, -1, 'cities', '{1379}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Davos, Switzerland');
INSERT INTO user_action_log VALUES (16608, 1, -1, 'cities', '{1380}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Kuwait City, Kuwait');
INSERT INTO user_action_log VALUES (16609, 1, -1, 'cities', '{1381}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED CITY: Lima, Peru');
INSERT INTO user_action_log VALUES (16610, 1, -1, 'venue_events', '{617}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: Africa Strategic Integration Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16611, 1, -1, 'venue_events', '{621}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: One Planet Summit - Feb 2018');
INSERT INTO user_action_log VALUES (16612, 1, -1, 'venue_events', '{620}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: National Prayer Breakfast - Feb 2018');
INSERT INTO user_action_log VALUES (16613, 1, -1, 'venue_events', '{619}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: Munich Security Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16614, 1, -1, 'venue_events', '{622}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: Winter Olympics - Feb 2018');
INSERT INTO user_action_log VALUES (16615, 1, -1, 'venue_events', '{623}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16616, 1, -1, 'venue_events', '{618}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED VENUE: Iraqi Reconstruction Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16617, 1, -1, 'people', '{6102}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Abdel Fattah El-Sisi, Unknown');
INSERT INTO user_action_log VALUES (16618, 1, -1, 'people', '{6103}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Abdulaziz Kamilov, Unknown');
INSERT INTO user_action_log VALUES (16619, 1, -1, 'people', '{6104}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Abdullah Il Ibn Al-Hussein, Unknown');
INSERT INTO user_action_log VALUES (16620, 1, -1, 'people', '{6105}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Adel Al-Jubeir, Unknown');
INSERT INTO user_action_log VALUES (16621, 1, -1, 'people', '{6106}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Ali Bin Al Hussein, Unknown');
INSERT INTO user_action_log VALUES (16622, 1, -1, 'people', '{6107}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Andrew Holness, Unknown');
INSERT INTO user_action_log VALUES (16623, 1, -1, 'people', '{6108}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Ayman Al-Safadi, Unknown');
INSERT INTO user_action_log VALUES (16624, 1, -1, 'people', '{6109}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Bill Morneau, Unknown');
INSERT INTO user_action_log VALUES (16625, 1, -1, 'people', '{6110}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Cayetana Alijovin, Unknown');
INSERT INTO user_action_log VALUES (16626, 1, -1, 'people', '{6111}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Dara Khosrowshahi, Unknown');
INSERT INTO user_action_log VALUES (16627, 1, -1, 'people', '{6112}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: David Miliband, Unknown');
INSERT INTO user_action_log VALUES (16628, 1, -1, 'people', '{6113}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Djamshid Kuchkarov, Unknown');
INSERT INTO user_action_log VALUES (16629, 1, -1, 'people', '{6114}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Donald Trump, US Government');
INSERT INTO user_action_log VALUES (16630, 1, -1, 'people', '{6115}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Emmanuel Macron, Unknown');
INSERT INTO user_action_log VALUES (16631, 1, -1, 'people', '{6116}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Enrique Pena Nieto, Unknown');
INSERT INTO user_action_log VALUES (16632, 1, -1, 'people', '{6117}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Frans Van Houten, Unknown');
INSERT INTO user_action_log VALUES (16633, 1, -1, 'people', '{6118}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Gary Cohen, US Government');
INSERT INTO user_action_log VALUES (16634, 1, -1, 'people', '{6119}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: George Soros, Unknown');
INSERT INTO user_action_log VALUES (16635, 1, -1, 'people', '{6120}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Haider Al-Abadi, Unknown');
INSERT INTO user_action_log VALUES (16636, 1, -1, 'people', '{6121}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Hasssan Ali Khaire, Unknown');
INSERT INTO user_action_log VALUES (16637, 1, -1, 'people', '{6122}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: H.R. Mcmaster, US Government');
INSERT INTO user_action_log VALUES (17014, 1, -1, 'cities', '{1382}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Bogota, Colombia');
INSERT INTO user_action_log VALUES (16638, 1, -1, 'people', '{6123}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Jared Kushner, US Government');
INSERT INTO user_action_log VALUES (16639, 1, -1, 'people', '{6125}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Jimmy Morales, Unknown');
INSERT INTO user_action_log VALUES (16640, 1, -1, 'people', '{6126}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Joachim Wenning, Unknown');
INSERT INTO user_action_log VALUES (16641, 1, -1, 'people', '{6127}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: John Kelly, US Government');
INSERT INTO user_action_log VALUES (16642, 1, -1, 'people', '{6128}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: John Sullivan, US Government');
INSERT INTO user_action_log VALUES (16643, 1, -1, 'people', '{6129}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Jorge Faurie, Unknown');
INSERT INTO user_action_log VALUES (16644, 1, -1, 'people', '{6130}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Juan Manuel Santos, Unknown');
INSERT INTO user_action_log VALUES (16645, 1, -1, 'people', '{6131}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Kamina Johnson Smith, Unknown');
INSERT INTO user_action_log VALUES (16646, 1, -1, 'people', '{6132}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Kirstjen Nielsen, US Government');
INSERT INTO user_action_log VALUES (16647, 1, -1, 'people', '{6134}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Lim Sing-Nam, Unknown');
INSERT INTO user_action_log VALUES (16648, 1, -1, 'people', '{6135}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Luis Videgaray, Unknown');
INSERT INTO user_action_log VALUES (16649, 1, -1, 'people', '{6136}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Machy Sall, Unknown');
INSERT INTO user_action_log VALUES (16650, 1, -1, 'people', '{6137}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Madeline Albright, Unknown');
INSERT INTO user_action_log VALUES (16651, 1, -1, 'people', '{6138}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Maria Angela Holguin, Unknown');
INSERT INTO user_action_log VALUES (16652, 1, -1, 'people', '{6139}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Mark Green, US Government');
INSERT INTO user_action_log VALUES (16653, 1, -1, 'people', '{6140}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Mark Suzman, Unknown');
INSERT INTO user_action_log VALUES (16654, 1, -1, 'people', '{6141}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Mauricio Marci, Unknown');
INSERT INTO user_action_log VALUES (16655, 1, -1, 'people', '{6142}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Michel Aoun, Unknown');
INSERT INTO user_action_log VALUES (16656, 1, -1, 'people', '{6143}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Mike Pence, US Government');
INSERT INTO user_action_log VALUES (16657, 1, -1, 'people', '{6144}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Nursultan Nazarbayev, Unknown');
INSERT INTO user_action_log VALUES (16658, 1, -1, 'people', '{6145}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Pedro Pablo Kuczynski, Unknown');
INSERT INTO user_action_log VALUES (16659, 1, -1, 'people', '{6146}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Perry Acosta, US Government');
INSERT INTO user_action_log VALUES (16660, 1, -1, 'people', '{6147}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Petri Gormiztka, Unknown');
INSERT INTO user_action_log VALUES (16661, 1, -1, 'people', '{6148}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Queen Mathilde Of Belgium, Unknown');
INSERT INTO user_action_log VALUES (16662, 1, -1, 'people', '{6149}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Rex Tillerson, US Government');
INSERT INTO user_action_log VALUES (16663, 1, -1, 'people', '{6150}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Roch Marc Christian Kabore, Unknown');
INSERT INTO user_action_log VALUES (16664, 1, -1, 'people', '{6151}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Saad Hariri, Unknown');
INSERT INTO user_action_log VALUES (16665, 1, -1, 'people', '{6152}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Sabah Al-Khalid-Sabah, Unknown');
INSERT INTO user_action_log VALUES (16666, 1, -1, 'people', '{6153}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Sameh Shoukry, Unknown');
INSERT INTO user_action_log VALUES (16667, 1, -1, 'people', '{6154}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Shavkat Mirziyoyev, Unknown');
INSERT INTO user_action_log VALUES (16668, 1, -1, 'people', '{6155}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Sheikh Sabah Al-Ahmad Al-Sabah, Unknown');
INSERT INTO user_action_log VALUES (16669, 1, -1, 'people', '{6156}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Steve Mnuchin, US Government');
INSERT INTO user_action_log VALUES (16670, 1, -1, 'people', '{6157}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Sukhrob Kholmurodov, Unknown');
INSERT INTO user_action_log VALUES (16671, 1, -1, 'people', '{6158}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Tom Shannon, US Government');
INSERT INTO user_action_log VALUES (16672, 1, -1, 'people', '{6159}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Yang Jiechi, Unknown');
INSERT INTO user_action_log VALUES (16673, 1, -1, 'people', '{6133}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Kristalina Georgieva, World Bank');
INSERT INTO user_action_log VALUES (16674, 1, -1, 'people', '{6124}', '2018-02-19 07:14:15.503244', 'REMOVING UNREFERENCED PERSON: Jim Kim, World Bank');
INSERT INTO user_action_log VALUES (16675, 1, 1, 'people', '{6160}', '2018-02-19 07:14:15.503244', 'Adding Person: Abdel Fattah El-Sisi');
INSERT INTO user_action_log VALUES (16676, 1, 1, 'people', '{6161}', '2018-02-19 07:14:15.503244', 'Adding Person: Abdulaziz Kamilov');
INSERT INTO user_action_log VALUES (16677, 1, 1, 'people', '{6162}', '2018-02-19 07:14:15.503244', 'Adding Person: Abdullah Il Ibn Al-Hussein');
INSERT INTO user_action_log VALUES (16678, 1, 1, 'people', '{6163}', '2018-02-19 07:14:15.503244', 'Adding Person: Adel Al-Jubeir');
INSERT INTO user_action_log VALUES (16679, 1, 1, 'people', '{6164}', '2018-02-19 07:14:15.503244', 'Adding Person: Ali Bin Al Hussein');
INSERT INTO user_action_log VALUES (16680, 1, 1, 'people', '{6165}', '2018-02-19 07:14:15.503244', 'Adding Person: Andrew Holness');
INSERT INTO user_action_log VALUES (16681, 1, 1, 'people', '{6166}', '2018-02-19 07:14:15.503244', 'Adding Person: Ayman Al-Safadi');
INSERT INTO user_action_log VALUES (16682, 1, 1, 'people', '{6167}', '2018-02-19 07:14:15.503244', 'Adding Person: Bill Morneau');
INSERT INTO user_action_log VALUES (16683, 1, 1, 'people', '{6168}', '2018-02-19 07:14:15.503244', 'Adding Person: Cayetana Alijovin');
INSERT INTO user_action_log VALUES (16684, 1, 1, 'people', '{6169}', '2018-02-19 07:14:15.503244', 'Adding Person: Dara Khosrowshahi');
INSERT INTO user_action_log VALUES (16685, 1, 1, 'people', '{6170}', '2018-02-19 07:14:15.503244', 'Adding Person: David Miliband');
INSERT INTO user_action_log VALUES (16686, 1, 1, 'people', '{6171}', '2018-02-19 07:14:15.503244', 'Adding Person: Djamshid Kuchkarov');
INSERT INTO user_action_log VALUES (16687, 1, 1, 'people', '{6172}', '2018-02-19 07:14:15.503244', 'Adding Person: Donald Trump');
INSERT INTO user_action_log VALUES (16688, 1, 1, 'people', '{6173}', '2018-02-19 07:14:15.503244', 'Adding Person: Emmanuel Macron');
INSERT INTO user_action_log VALUES (16689, 1, 1, 'people', '{6174}', '2018-02-19 07:14:15.503244', 'Adding Person: Enrique Pena Nieto');
INSERT INTO user_action_log VALUES (16690, 1, 1, 'people', '{6175}', '2018-02-19 07:14:15.503244', 'Adding Person: Frans Van Houten');
INSERT INTO user_action_log VALUES (16691, 1, 1, 'people', '{6176}', '2018-02-19 07:14:15.503244', 'Adding Person: Gary Cohen');
INSERT INTO user_action_log VALUES (16692, 1, 1, 'people', '{6177}', '2018-02-19 07:14:15.503244', 'Adding Person: George Soros');
INSERT INTO user_action_log VALUES (16693, 1, 1, 'people', '{6178}', '2018-02-19 07:14:15.503244', 'Adding Person: Haider Al-Abadi');
INSERT INTO user_action_log VALUES (16694, 1, 1, 'people', '{6179}', '2018-02-19 07:14:15.503244', 'Adding Person: Hasssan Ali Khaire');
INSERT INTO user_action_log VALUES (16695, 1, 1, 'people', '{6180}', '2018-02-19 07:14:15.503244', 'Adding Person: H.R. Mcmaster');
INSERT INTO user_action_log VALUES (16696, 1, 1, 'people', '{6181}', '2018-02-19 07:14:15.503244', 'Adding Person: Jared Kushner');
INSERT INTO user_action_log VALUES (16697, 1, 1, 'people', '{6182}', '2018-02-19 07:14:15.503244', 'Adding Person: Jim Kim');
INSERT INTO user_action_log VALUES (16700, 1, 1, 'people', '{6185}', '2018-02-19 07:14:15.503244', 'Adding Person: John Kelly');
INSERT INTO user_action_log VALUES (16701, 1, 1, 'people', '{6186}', '2018-02-19 07:14:15.503244', 'Adding Person: John Sullivan');
INSERT INTO user_action_log VALUES (16702, 1, 1, 'people', '{6187}', '2018-02-19 07:14:15.503244', 'Adding Person: Jorge Faurie');
INSERT INTO user_action_log VALUES (16703, 1, 1, 'people', '{6188}', '2018-02-19 07:14:15.503244', 'Adding Person: Juan Manuel Santos');
INSERT INTO user_action_log VALUES (16704, 1, 1, 'people', '{6189}', '2018-02-19 07:14:15.503244', 'Adding Person: Kamina Johnson Smith');
INSERT INTO user_action_log VALUES (16705, 1, 1, 'people', '{6190}', '2018-02-19 07:14:15.503244', 'Adding Person: Kirstjen Nielsen');
INSERT INTO user_action_log VALUES (16706, 1, 1, 'people', '{6191}', '2018-02-19 07:14:15.503244', 'Adding Person: Kristalina Georgieva');
INSERT INTO user_action_log VALUES (16707, 1, 1, 'people', '{6192}', '2018-02-19 07:14:15.503244', 'Adding Person: Lim Sing-Nam');
INSERT INTO user_action_log VALUES (16708, 1, 1, 'people', '{6193}', '2018-02-19 07:14:15.503244', 'Adding Person: Luis Videgaray');
INSERT INTO user_action_log VALUES (16709, 1, 1, 'people', '{6194}', '2018-02-19 07:14:15.503244', 'Adding Person: Machy Sall');
INSERT INTO user_action_log VALUES (16710, 1, 1, 'people', '{6195}', '2018-02-19 07:14:15.503244', 'Adding Person: Madeline Albright');
INSERT INTO user_action_log VALUES (16711, 1, 1, 'people', '{6196}', '2018-02-19 07:14:15.503244', 'Adding Person: Maria Angela Holguin');
INSERT INTO user_action_log VALUES (16712, 1, 1, 'people', '{6197}', '2018-02-19 07:14:15.503244', 'Adding Person: Mark Green');
INSERT INTO user_action_log VALUES (16713, 1, 1, 'people', '{6198}', '2018-02-19 07:14:15.503244', 'Adding Person: Mark Suzman');
INSERT INTO user_action_log VALUES (16714, 1, 1, 'people', '{6199}', '2018-02-19 07:14:15.503244', 'Adding Person: Mauricio Marci');
INSERT INTO user_action_log VALUES (16715, 1, 1, 'people', '{6200}', '2018-02-19 07:14:15.503244', 'Adding Person: Michel Aoun');
INSERT INTO user_action_log VALUES (16716, 1, 1, 'people', '{6201}', '2018-02-19 07:14:15.503244', 'Adding Person: Mike Pence');
INSERT INTO user_action_log VALUES (16717, 1, 1, 'people', '{6202}', '2018-02-19 07:14:15.503244', 'Adding Person: Nursultan Nazarbayev');
INSERT INTO user_action_log VALUES (16718, 1, 1, 'people', '{6203}', '2018-02-19 07:14:15.503244', 'Adding Person: Pedro Pablo Kuczynski');
INSERT INTO user_action_log VALUES (16719, 1, 1, 'people', '{6204}', '2018-02-19 07:14:15.503244', 'Adding Person: Perry Acosta');
INSERT INTO user_action_log VALUES (16720, 1, 1, 'people', '{6205}', '2018-02-19 07:14:15.503244', 'Adding Person: Petri Gormiztka');
INSERT INTO user_action_log VALUES (16721, 1, 1, 'people', '{6206}', '2018-02-19 07:14:15.503244', 'Adding Person: Queen Mathilde Of Belgium');
INSERT INTO user_action_log VALUES (16722, 1, 1, 'people', '{6207}', '2018-02-19 07:14:15.503244', 'Adding Person: Rex Tillerson');
INSERT INTO user_action_log VALUES (16723, 1, 1, 'people', '{6208}', '2018-02-19 07:14:15.503244', 'Adding Person: Roch Marc Christian Kabore');
INSERT INTO user_action_log VALUES (16724, 1, 1, 'people', '{6209}', '2018-02-19 07:14:15.503244', 'Adding Person: Saad Hariri');
INSERT INTO user_action_log VALUES (16725, 1, 1, 'people', '{6210}', '2018-02-19 07:14:15.503244', 'Adding Person: Sabah Al-Khalid-Sabah');
INSERT INTO user_action_log VALUES (16726, 1, 1, 'people', '{6211}', '2018-02-19 07:14:15.503244', 'Adding Person: Sameh Shoukry');
INSERT INTO user_action_log VALUES (16727, 1, 1, 'people', '{6212}', '2018-02-19 07:14:15.503244', 'Adding Person: Shavkat Mirziyoyev');
INSERT INTO user_action_log VALUES (16728, 1, 1, 'people', '{6213}', '2018-02-19 07:14:15.503244', 'Adding Person: Sheikh Sabah Al-Ahmad Al-Sabah');
INSERT INTO user_action_log VALUES (16729, 1, 1, 'people', '{6214}', '2018-02-19 07:14:15.503244', 'Adding Person: Steve Mnuchin');
INSERT INTO user_action_log VALUES (16730, 1, 1, 'people', '{6215}', '2018-02-19 07:14:15.503244', 'Adding Person: Sukhrob Kholmurodov');
INSERT INTO user_action_log VALUES (16731, 1, 1, 'people', '{6216}', '2018-02-19 07:14:15.503244', 'Adding Person: Tom Shannon');
INSERT INTO user_action_log VALUES (16732, 1, 1, 'people', '{6217}', '2018-02-19 07:14:15.503244', 'Adding Person: Yang Jiechi');
INSERT INTO user_action_log VALUES (16733, 0, 0, 'people', '{6191}', '2018-02-19 07:14:15.503244', 'Upadting Person: Kristalina Georgieva: is_wbg=YES');
INSERT INTO user_action_log VALUES (16734, 0, 0, 'people', '{6182}', '2018-02-19 07:14:15.503244', 'Upadting Person: Jim Kim: is_wbg=YES');
INSERT INTO user_action_log VALUES (16735, 1, 1, 'cities', '{1382}', '2018-02-19 07:14:15.503244', 'Adding City: Bogota, Colombia');
INSERT INTO user_action_log VALUES (16736, 1, 1, 'cities', '{1383}', '2018-02-19 07:14:15.503244', 'Adding City: London, UK');
INSERT INTO user_action_log VALUES (16737, 1, 1, 'cities', '{1384}', '2018-02-19 07:14:15.503244', 'Adding City: Amman, Jordan');
INSERT INTO user_action_log VALUES (16738, 1, 1, 'cities', '{1385}', '2018-02-19 07:14:15.503244', 'Adding City: Garmisch, Germany');
INSERT INTO user_action_log VALUES (16739, 1, 1, 'cities', '{1386}', '2018-02-19 07:14:15.503244', 'Adding City: Dakar, Senegal');
INSERT INTO user_action_log VALUES (16740, 1, 1, 'cities', '{1387}', '2018-02-19 07:14:15.503244', 'Adding City: Washington, DC, United States');
INSERT INTO user_action_log VALUES (16741, 1, 1, 'cities', '{1388}', '2018-02-19 07:14:15.503244', 'Adding City: Tokyo, Japan');
INSERT INTO user_action_log VALUES (16742, 1, 1, 'cities', '{1389}', '2018-02-19 07:14:15.503244', 'Adding City: Munich, Germany');
INSERT INTO user_action_log VALUES (16743, 1, 1, 'cities', '{1390}', '2018-02-19 07:14:15.503244', 'Adding City: Tashkent, Uzbekistan');
INSERT INTO user_action_log VALUES (16744, 1, 1, 'cities', '{1391}', '2018-02-19 07:14:15.503244', 'Adding City: Jakarta, Indonesia');
INSERT INTO user_action_log VALUES (16745, 1, 1, 'cities', '{1392}', '2018-02-19 07:14:15.503244', 'Adding City: Jerusalem, Israel');
INSERT INTO user_action_log VALUES (16746, 1, 1, 'cities', '{1393}', '2018-02-19 07:14:15.503244', 'Adding City: Seoul, Republic of Korea');
INSERT INTO user_action_log VALUES (16747, 1, 1, 'cities', '{1394}', '2018-02-19 07:14:15.503244', 'Adding City: Cairo, Egypt');
INSERT INTO user_action_log VALUES (16748, 1, 1, 'cities', '{1395}', '2018-02-19 07:14:15.503244', 'Adding City: Vancouver, Canada');
INSERT INTO user_action_log VALUES (16749, 1, 1, 'cities', '{1396}', '2018-02-19 07:14:15.503244', 'Adding City: Sydney, Australia');
INSERT INTO user_action_log VALUES (16750, 1, 1, 'cities', '{1397}', '2018-02-19 07:14:15.503244', 'Adding City: Mexico City, Mexico');
INSERT INTO user_action_log VALUES (16751, 1, 1, 'cities', '{1398}', '2018-02-19 07:14:15.503244', 'Adding City: Kingston, Jamaica');
INSERT INTO user_action_log VALUES (16752, 1, 1, 'cities', '{1399}', '2018-02-19 07:14:15.503244', 'Adding City: Warsaw, Poland');
INSERT INTO user_action_log VALUES (16753, 1, 1, 'cities', '{1400}', '2018-02-19 07:14:15.503244', 'Adding City: Seoul, South Korea');
INSERT INTO user_action_log VALUES (16754, 1, 1, 'cities', '{1401}', '2018-02-19 07:14:15.503244', 'Adding City: Monrovia, Liberia');
INSERT INTO user_action_log VALUES (16755, 1, 1, 'cities', '{1402}', '2018-02-19 07:14:15.503244', 'Adding City: Beirut, Lebanon');
INSERT INTO user_action_log VALUES (16756, 1, 1, 'cities', '{1403}', '2018-02-19 07:14:15.503244', 'Adding City: Dubai, UAE');
INSERT INTO user_action_log VALUES (16757, 1, 1, 'cities', '{1404}', '2018-02-19 07:14:15.503244', 'Adding City: Paris, France');
INSERT INTO user_action_log VALUES (16758, 1, 1, 'cities', '{1405}', '2018-02-19 07:14:15.503244', 'Adding City: Ankara, Turkey');
INSERT INTO user_action_log VALUES (16759, 1, 1, 'cities', '{1406}', '2018-02-19 07:14:15.503244', 'Adding City: Buenos Aires, Argentina');
INSERT INTO user_action_log VALUES (16760, 1, 1, 'cities', '{1407}', '2018-02-19 07:14:15.503244', 'Adding City: Davos, Switzerland');
INSERT INTO user_action_log VALUES (16761, 1, 1, 'cities', '{1408}', '2018-02-19 07:14:15.503244', 'Adding City: Kuwait City, Kuwait');
INSERT INTO user_action_log VALUES (16762, 1, 1, 'cities', '{1409}', '2018-02-19 07:14:15.503244', 'Adding City: Lima, Peru');
INSERT INTO user_action_log VALUES (16763, 1, 1, 'trips', '{5973}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] London [ON] 2018-01-21 {MEL:6de59d960d3bb8a6346c058930f3cd28}');
INSERT INTO user_action_log VALUES (16764, 1, 1, 'trips', '{5974}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Buenos Aires [ON] 2018-02-03 {MEL:7e1cacfb27da22fb243ff2debf4443a0}');
INSERT INTO user_action_log VALUES (16765, 1, 1, 'trips', '{5975}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Mexico City [ON] 2018-02-01 {MEL:32cfdce9631d8c7906e8e9d6e68b514b}');
INSERT INTO user_action_log VALUES (16766, 1, 1, 'trips', '{5976}', '2018-02-19 07:14:15.503244', 'Adding Trip: Gary Cohen [TO] Davos [ON] 2018-01-24 {MEL:e10534dd65cf727692c0f9c44ba613f8}');
INSERT INTO user_action_log VALUES (16767, 1, 1, 'trips', '{5977}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mark Green [TO] Munich [ON] 2018-02-16 {MEL:7eb532aef980c36170c0b4426f082b87}');
INSERT INTO user_action_log VALUES (16768, 1, 1, 'trips', '{5978}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kristalina Georgieva [TO] Washington, DC [ON] 2018-03-08 {MEL:e5ae7b1f180083e8a49e55e4d488bbec}');
INSERT INTO user_action_log VALUES (16769, 1, 1, 'trips', '{5979}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Jakarta [ON] 2018-04-19 {MEL:6d7d394c9d0c886e9247542e06ebb705}');
INSERT INTO user_action_log VALUES (16770, 1, 1, 'trips', '{5980}', '2018-02-19 07:14:15.503244', 'Adding Trip: Tom Shannon [TO] Vancouver [ON] 2018-02-08 {MEL:63dfdeb1ff9ff09ecc3f05d2d7221ffa}');
INSERT INTO user_action_log VALUES (16771, 1, 1, 'trips', '{5981}', '2018-02-19 07:14:15.503244', 'Adding Trip: Steve Mnuchin [TO] Davos [ON] 2018-01-24 {MEL:abb9d15b3293a96a3ea116867b2b16d5}');
INSERT INTO user_action_log VALUES (16772, 1, 1, 'trips', '{5982}', '2018-02-19 07:14:15.503244', 'Adding Trip: Tom Shannon [TO] Washington, DC [ON] 2018-01-17 {MEL:c23497bd62a8f8a0981fdc9cbd3c30d9}');
INSERT INTO user_action_log VALUES (16773, 1, 1, 'trips', '{5983}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Washington, DC [ON] 2018-02-08 {MEL:0cb82dbdcda47e2ad7b7aaf69573906e}');
INSERT INTO user_action_log VALUES (16774, 1, 1, 'trips', '{5984}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Warsaw [ON] 2018-01-26 {MEL:7f2cba89a7116c7c6b0a769572d5fad9}');
INSERT INTO user_action_log VALUES (16775, 1, 1, 'trips', '{5985}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Amman [ON] 2018-01-21 {MEL:fccc64972a9468a11f125cadb090e89e}');
INSERT INTO user_action_log VALUES (16776, 1, 1, 'trips', '{5986}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Davos [ON] 2018-01-25 {MEL:fd45c64e026040dbcb83395829d2aea5}');
INSERT INTO user_action_log VALUES (16777, 1, 1, 'trips', '{5987}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Amman [ON] 2018-02-11 {MEL:7f9d88fe83d3e7fce3136e510b0a9a38}');
INSERT INTO user_action_log VALUES (16778, 1, 1, 'trips', '{5988}', '2018-02-19 07:14:15.503244', 'Adding Trip: John Sullivan [TO] Washington, DC [ON] 2018-01-17 {MEL:dfbfa7ddcfffeb581f50edcf9a0204bb}');
INSERT INTO user_action_log VALUES (16779, 1, 1, 'trips', '{5989}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Davos [ON] 2018-01-23 {MEL:1ae6464c6b5d51b363d7d96f97132c75}');
INSERT INTO user_action_log VALUES (16780, 1, 1, 'trips', '{5990}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Kuwait City [ON] 2018-02-12 {MEL:3cba81c5c6cac4ce77157631fc2dc277}');
INSERT INTO user_action_log VALUES (16781, 1, 1, 'trips', '{5991}', '2018-02-19 07:14:15.503244', 'Adding Trip: John Kelly [TO] Davos [ON] 2018-01-24 {MEL:c0356641f421b381e475776b602a5da8}');
INSERT INTO user_action_log VALUES (16782, 1, 1, 'trips', '{5992}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Seoul [ON] 2018-02-09 {MEL:675f9820626f5bc0afb47b57890b466e}');
INSERT INTO user_action_log VALUES (16783, 1, 1, 'trips', '{5993}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Tokyo [ON] 2018-04-18 {MEL:32e0bd1497aa43e02a42f47d9d6515ad}');
INSERT INTO user_action_log VALUES (16784, 1, 1, 'trips', '{5994}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kristalina Georgieva [TO] Tashkent [ON] 2018-01-18 {MEL:edb446b67d69adbfe9a21068982000c2}');
INSERT INTO user_action_log VALUES (16785, 1, 1, 'trips', '{5995}', '2018-02-19 07:14:15.503244', 'Adding Trip: H.R. Mcmaster [TO] Davos [ON] 2018-01-24 {MEL:fcd4c889d516a54d5371f00e3fdd70dc}');
INSERT INTO user_action_log VALUES (16786, 1, 1, 'trips', '{5996}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Cairo [ON] 2018-02-12 {MEL:8d3215ae97598264ad6529613774a038}');
INSERT INTO user_action_log VALUES (16787, 1, 1, 'trips', '{5997}', '2018-02-19 07:14:15.503244', 'Adding Trip: Donald Trump [TO] Washington, DC [ON] 2018-01-17 {MEL:077fd57e57aab32087b0466fe6ebcca8}');
INSERT INTO user_action_log VALUES (16788, 1, 1, 'trips', '{5998}', '2018-02-19 07:14:15.503244', 'Adding Trip: Donald Trump [TO] Washington, DC [ON] 2018-02-08 {MEL:b98a3773ecf715751d3cf0fb6dcba424}');
INSERT INTO user_action_log VALUES (16789, 1, 1, 'trips', '{5999}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kristalina Georgieva [TO] Munich [ON] 2018-02-15 {MEL:cca289d2a4acd14c1cd9a84ffb41dd29}');
INSERT INTO user_action_log VALUES (16790, 1, 1, 'trips', '{6000}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Washington, DC [ON] 2018-01-12 {MEL:a8c6dd982010fce8701ce1aef8a2d40a}');
INSERT INTO user_action_log VALUES (16791, 1, 1, 'trips', '{6001}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Dubai [ON] 2018-02-09 {MEL:ea1818cbe59c23b20f1a10a8aa083a82}');
INSERT INTO user_action_log VALUES (16792, 1, 1, 'trips', '{6002}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kirstjen Nielsen [TO] Davos [ON] 2018-01-24 {MEL:4b01078e96f65f2ad6573ce6fecc944d}');
INSERT INTO user_action_log VALUES (16793, 1, 1, 'trips', '{6003}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Kingston [ON] 2018-02-07 {MEL:7acba01022004f2ce03bf56ca56ec6f4}');
INSERT INTO user_action_log VALUES (16794, 1, 1, 'trips', '{6004}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Ankara [ON] 2018-02-15 {MEL:636efd4f9aeb5781e9ea815cdd633e52}');
INSERT INTO user_action_log VALUES (16795, 1, 1, 'trips', '{6005}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2018-01-23 {MEL:50c1f44e426560f3f2cdcb3e19e39903}');
INSERT INTO user_action_log VALUES (16796, 1, 1, 'trips', '{6006}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2018-01-24 {MEL:91ba4a4478a66bee9812b0804b6f9d1b}');
INSERT INTO user_action_log VALUES (16797, 1, 1, 'trips', '{6007}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Sydney [ON] 2018-04-21 {MEL:bacadc62d6e67d7897cef027fa2d416c}');
INSERT INTO user_action_log VALUES (16798, 1, 1, 'trips', '{6008}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Cairo [ON] 2018-01-20 {MEL:569ff987c643b4bedf504efda8f786c2}');
INSERT INTO user_action_log VALUES (16799, 1, 1, 'trips', '{6009}', '2018-02-19 07:14:15.503244', 'Adding Trip: Donald Trump [TO] Davos [ON] 2018-01-23 {MEL:37d7902cb2d3de686e497e31624d82e0}');
INSERT INTO user_action_log VALUES (16800, 1, 1, 'trips', '{6010}', '2018-02-19 07:14:15.503244', 'Adding Trip: Tom Shannon [TO] Monrovia [ON] 2018-01-23 {MEL:c4c455df3c54f292ae22f6791fd2553e}');
INSERT INTO user_action_log VALUES (16801, 1, 1, 'trips', '{6011}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Paris [ON] 2018-01-22 {MEL:e3b80d30a727c738f3cff0941f6bc55a}');
INSERT INTO user_action_log VALUES (16802, 1, 1, 'trips', '{6012}', '2018-02-19 07:14:15.503244', 'Adding Trip: Perry Acosta [TO] Davos [ON] 2018-01-24 {MEL:4c4c937b67cc8d785cea1e42ccea185c}');
INSERT INTO user_action_log VALUES (16803, 1, 1, 'trips', '{6013}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mark Green [TO] Washington, DC [ON] 2018-01-17 {MEL:8fd7f981e10b41330b618129afcaab2d}');
INSERT INTO user_action_log VALUES (16804, 1, 1, 'trips', '{6014}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jared Kushner [TO] Davos [ON] 2018-01-24 {MEL:3f68928ec5b6fae14708854b8fd0cf08}');
INSERT INTO user_action_log VALUES (16805, 1, 1, 'trips', '{6015}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Seoul [ON] 2018-04-15 {MEL:5a378f8490c8d6af8647a753812f6e31}');
INSERT INTO user_action_log VALUES (16806, 1, 1, 'trips', '{6016}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Bogota [ON] 2018-02-06 {MEL:593906af0d138e69f49d251d3e7cbed0}');
INSERT INTO user_action_log VALUES (16807, 1, 1, 'trips', '{6017}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Dakar [ON] 2018-02-01 {MEL:fef6f971605336724b5e6c0c12dc2534}');
INSERT INTO user_action_log VALUES (16808, 1, 1, 'trips', '{6018}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Amman [ON] 2018-02-14 {MEL:8d2a5f7d4afa5d0530789d3066945330}');
INSERT INTO user_action_log VALUES (16809, 1, 1, 'trips', '{6019}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Lima [ON] 2018-02-06 {MEL:5218f316b3f85b751c613a06aa18010d}');
INSERT INTO user_action_log VALUES (17015, 1, -1, 'cities', '{1410}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Junkcity, JunkCountry');
INSERT INTO user_action_log VALUES (16810, 1, 1, 'trips', '{6020}', '2018-02-19 07:14:15.503244', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2018-01-25 {MEL:ac2a728f9f17b5d860b6dabd80a5162f}');
INSERT INTO user_action_log VALUES (16811, 1, 1, 'trips', '{6021}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Washington, DC [ON] 2018-02-23 {MEL:b075703bbe07a50ddcccfaac424bb6d9}');
INSERT INTO user_action_log VALUES (16812, 1, 1, 'trips', '{6022}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Beirut [ON] 2018-02-16 {MEL:da54dd5a0398011cdfa50d559c2c0ef8}');
INSERT INTO user_action_log VALUES (16813, 1, 1, 'trips', '{6023}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mark Green [TO] London [ON] 2018-02-18 {MEL:3ba9af181751761d3b387f74ded2d783}');
INSERT INTO user_action_log VALUES (16814, 1, 1, 'trips', '{6024}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Kuwait City [ON] 2018-02-13 {MEL:3bd8fdb090f1f5eb66a00c84dbc5ad51}');
INSERT INTO user_action_log VALUES (16815, 1, 1, 'trips', '{6025}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Lima [ON] 2018-02-05 {MEL:5eed6c6e569d984796ebca9c1169451e}');
INSERT INTO user_action_log VALUES (16816, 1, 1, 'trips', '{6026}', '2018-02-19 07:14:15.503244', 'Adding Trip: Jim Kim [TO] Munich [ON] 2018-02-16 {MEL:a70dab11c90d06b809d0be230731762a}');
INSERT INTO user_action_log VALUES (16817, 1, 1, 'trips', '{6027}', '2018-02-19 07:14:15.503244', 'Adding Trip: Rex Tillerson [TO] Davos [ON] 2018-01-24 {MEL:30f48cd3c7e73511070b95ee0a884c23}');
INSERT INTO user_action_log VALUES (16818, 1, 1, 'trips', '{6028}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mike Pence [TO] Jerusalem [ON] 2018-01-22 {MEL:2c60e40b399dc55d8b755ec6b5d09f8a}');
INSERT INTO user_action_log VALUES (16819, 1, 1, 'trips', '{6029}', '2018-02-19 07:14:15.503244', 'Adding Trip: Mark Green [TO] Garmisch [ON] 2018-02-15 {MEL:7f3ad9c65beb20ccbd34a05041b4420b}');
INSERT INTO user_action_log VALUES (16820, 1, 1, 'venue_events', '{624}', '2018-02-19 07:14:15.503244', 'Adding Venue: Africa Strategic Integration Conference - Feb 2018 [AS] Small Event [IN] Garmisch');
INSERT INTO user_action_log VALUES (16821, 1, 1, 'venue_events', '{625}', '2018-02-19 07:14:15.503244', 'Adding Venue: Iraqi Reconstruction Conference - Feb 2018 [AS] Small Event [IN] Kuwait City');
INSERT INTO user_action_log VALUES (16822, 1, 1, 'venue_events', '{626}', '2018-02-19 07:14:15.503244', 'Adding Venue: Munich Security Conference - Feb 2018 [AS] Small Event [IN] Munich');
INSERT INTO user_action_log VALUES (16823, 1, 1, 'venue_events', '{627}', '2018-02-19 07:14:15.503244', 'Adding Venue: National Prayer Breakfast - Feb 2018 [AS] Small Event [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16824, 1, 1, 'venue_events', '{628}', '2018-02-19 07:14:15.503244', 'Adding Venue: One Planet Summit - Feb 2018 [AS] Major Event [IN] Dakar');
INSERT INTO user_action_log VALUES (16825, 1, 1, 'venue_events', '{629}', '2018-02-19 07:14:15.503244', 'Adding Venue: Winter Olympics - Feb 2018 [AS] Major Event [IN] Seoul');
INSERT INTO user_action_log VALUES (16826, 1, 1, 'venue_events', '{630}', '2018-02-19 07:14:15.503244', 'Adding Venue: World Economic Forum - Jan 2018 [AS] Major Event [IN] Davos');
INSERT INTO user_action_log VALUES (16827, 1, 1, 'trip_meetings', '{6194,6017}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Machy Sall [AND] Jim Kim [AT] One Planet Summit - Feb 2018');
INSERT INTO user_action_log VALUES (16828, 1, 1, 'trip_meetings', '{6172,6009}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Donald Trump [AND] Donald Trump [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16829, 1, 1, 'trip_meetings', '{6197,6029}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Mark Green [AND] Mark Green [AT] Africa Strategic Integration Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16830, 1, 1, 'trip_meetings', '{6180,5995}', '2018-02-19 07:14:15.503244', 'Adding Meeting: H.R. Mcmaster [AND] H.R. Mcmaster [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16831, 1, 1, 'trip_meetings', '{6193,5975}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Luis Videgaray [AND] Rex Tillerson [IN] Mexico City');
INSERT INTO user_action_log VALUES (16832, 1, 1, 'trip_meetings', '{6183,5983}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Jimmy Morales [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16833, 1, 1, 'trip_meetings', '{6214,5981}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Steve Mnuchin [AND] Steve Mnuchin [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16834, 1, 1, 'trip_meetings', '{6165,6003}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Andrew Holness [AND] Rex Tillerson [IN] Kingston');
INSERT INTO user_action_log VALUES (16835, 1, 1, 'trip_meetings', '{6209,6022}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Saad Hariri [AND] Rex Tillerson [IN] Beirut');
INSERT INTO user_action_log VALUES (16836, 1, 1, 'trip_meetings', '{6160,5996}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Abdel Fattah El-Sisi [AND] Rex Tillerson [IN] Cairo');
INSERT INTO user_action_log VALUES (16837, 1, 1, 'trip_meetings', '{6182,6026}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Jim Kim [AND] Jim Kim [AT] Munich Security Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16838, 1, 1, 'trip_meetings', '{6206,6006}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Queen Mathilde Of Belgium [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16839, 1, 1, 'trip_meetings', '{6200,6022}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Michel Aoun [AND] Rex Tillerson [IN] Beirut');
INSERT INTO user_action_log VALUES (16840, 1, 1, 'trip_meetings', '{6208,6017}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Roch Marc Christian Kabore [AND] Jim Kim [AT] One Planet Summit - Feb 2018');
INSERT INTO user_action_log VALUES (16841, 1, 1, 'trip_meetings', '{6183,5998}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Jimmy Morales [AND] Donald Trump [AT] National Prayer Breakfast - Feb 2018');
INSERT INTO user_action_log VALUES (16842, 1, 1, 'trip_meetings', '{6215,5994}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Sukhrob Kholmurodov [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (16843, 1, 1, 'trip_meetings', '{6176,5976}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Gary Cohen [AND] Gary Cohen [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16844, 1, 1, 'trip_meetings', '{6210,5990}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Sabah Al-Khalid-Sabah [AND] Rex Tillerson [IN] Kuwait City');
INSERT INTO user_action_log VALUES (16845, 1, 1, 'trip_meetings', '{6169,5989}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Dara Khosrowshahi [AND] Jim Kim [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16846, 1, 1, 'trip_meetings', '{6187,5974}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Jorge Faurie [AND] Rex Tillerson [IN] Buenos Aires');
INSERT INTO user_action_log VALUES (16847, 1, 1, 'trip_meetings', '{6181,6014}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Jared Kushner [AND] Jared Kushner [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16848, 1, 1, 'trip_meetings', '{6170,5982}', '2018-02-19 07:14:15.503244', 'Adding Meeting: David Miliband [AND] Tom Shannon [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16849, 1, 1, 'trip_meetings', '{6173,6017}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Emmanuel Macron [AND] Jim Kim [AT] One Planet Summit - Feb 2018');
INSERT INTO user_action_log VALUES (16850, 1, 1, 'trip_meetings', '{6175,5986}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Frans Van Houten [AND] Jim Kim [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16851, 1, 1, 'trip_meetings', '{6204,6012}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Perry Acosta [AND] Perry Acosta [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16852, 1, 1, 'trip_meetings', '{6207,6027}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Rex Tillerson [AND] Rex Tillerson [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16853, 1, 1, 'trip_meetings', '{6196,6016}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Maria Angela Holguin [AND] Rex Tillerson [IN] Bogota');
INSERT INTO user_action_log VALUES (16854, 1, 1, 'trip_meetings', '{6205,6013}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Petri Gormiztka [AND] Mark Green [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16855, 1, 1, 'trip_meetings', '{6207,6024}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Rex Tillerson [AND] Rex Tillerson [AT] Iraqi Reconstruction Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16856, 1, 1, 'trip_meetings', '{6184,5986}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Joachim Wenning [AND] Jim Kim [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16857, 1, 1, 'trip_meetings', '{6195,5978}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Madeline Albright [AND] Kristalina Georgieva [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16858, 1, 1, 'trip_meetings', '{6203,6019}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Pedro Pablo Kuczynski [AND] Rex Tillerson [IN] Lima');
INSERT INTO user_action_log VALUES (16859, 1, 1, 'trip_meetings', '{6197,5977}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Mark Green [AND] Mark Green [AT] Munich Security Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16860, 1, 1, 'trip_meetings', '{6212,5994}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Shavkat Mirziyoyev [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (16861, 1, 1, 'trip_meetings', '{6164,5985}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Ali Bin Al Hussein [AND] Mike Pence [IN] Amman');
INSERT INTO user_action_log VALUES (16862, 1, 1, 'trip_meetings', '{6174,5975}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Enrique Pena Nieto [AND] Rex Tillerson [IN] Mexico City');
INSERT INTO user_action_log VALUES (16863, 1, 1, 'trip_meetings', '{6166,6018}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Ayman Al-Safadi [AND] Rex Tillerson [IN] Amman');
INSERT INTO user_action_log VALUES (16864, 1, 1, 'trip_meetings', '{6185,5991}', '2018-02-19 07:14:15.503244', 'Adding Meeting: John Kelly [AND] John Kelly [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16865, 1, 1, 'trip_meetings', '{6201,5992}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Mike Pence [AND] Mike Pence [AT] Winter Olympics - Feb 2018');
INSERT INTO user_action_log VALUES (16866, 1, 1, 'trip_meetings', '{6198,6006}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Mark Suzman [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16867, 1, 1, 'trip_meetings', '{6161,5982}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Abdulaziz Kamilov [AND] Tom Shannon [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16868, 1, 1, 'trip_meetings', '{6188,6016}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Juan Manuel Santos [AND] Rex Tillerson [IN] Bogota');
INSERT INTO user_action_log VALUES (16869, 1, 1, 'trip_meetings', '{6189,6003}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Kamina Johnson Smith [AND] Rex Tillerson [IN] Kingston');
INSERT INTO user_action_log VALUES (16870, 1, 1, 'trip_meetings', '{6163,6000}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Adel Al-Jubeir [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16871, 1, 1, 'trip_meetings', '{6190,6002}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Kirstjen Nielsen [AND] Kirstjen Nielsen [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16872, 1, 1, 'trip_meetings', '{6213,6024}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Sheikh Sabah Al-Ahmad Al-Sabah [AND] Rex Tillerson [IN] Kuwait City');
INSERT INTO user_action_log VALUES (16873, 1, 1, 'trip_meetings', '{6217,5983}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Yang Jiechi [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16874, 1, 1, 'trip_meetings', '{6167,6005}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Bill Morneau [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16875, 1, 1, 'trip_meetings', '{6168,6025}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Cayetana Alijovin [AND] Rex Tillerson [IN] Lima');
INSERT INTO user_action_log VALUES (16876, 1, 1, 'trip_meetings', '{6179,6020}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Hasssan Ali Khaire [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16877, 1, 1, 'trip_meetings', '{6162,6018}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Abdullah Il Ibn Al-Hussein [AND] Rex Tillerson [IN] Amman');
INSERT INTO user_action_log VALUES (16878, 1, 1, 'trip_meetings', '{6160,6008}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Abdel Fattah El-Sisi [AND] Mike Pence [IN] Cairo');
INSERT INTO user_action_log VALUES (16879, 1, 1, 'trip_meetings', '{6171,5994}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Djamshid Kuchkarov [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (16880, 1, 1, 'trip_meetings', '{6177,6005}', '2018-02-19 07:14:15.503244', 'Adding Meeting: George Soros [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2018');
INSERT INTO user_action_log VALUES (16881, 1, 1, 'trip_meetings', '{6199,5974}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Mauricio Marci [AND] Rex Tillerson [IN] Buenos Aires');
INSERT INTO user_action_log VALUES (16882, 1, 1, 'trip_meetings', '{6192,5988}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Lim Sing-Nam [AND] John Sullivan [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16883, 1, 1, 'trip_meetings', '{6202,5997}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Nursultan Nazarbayev [AND] Donald Trump [IN] Washington, DC');
INSERT INTO user_action_log VALUES (16884, 1, 1, 'trip_meetings', '{6191,5999}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Kristalina Georgieva [AND] Kristalina Georgieva [AT] Munich Security Conference - Feb 2018');
INSERT INTO user_action_log VALUES (16885, 1, 1, 'trip_meetings', '{6211,5996}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Sameh Shoukry [AND] Rex Tillerson [IN] Cairo');
INSERT INTO user_action_log VALUES (16886, 1, 1, 'trip_meetings', '{6178,6024}', '2018-02-19 07:14:15.503244', 'Adding Meeting: Haider Al-Abadi [AND] Rex Tillerson [AT] Iraqi Reconstruction Conference - Feb 2018');
INSERT INTO user_action_log VALUES (17016, 1, -1, 'cities', '{1383}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: London, UK');
INSERT INTO user_action_log VALUES (17017, 1, -1, 'cities', '{1384}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Amman, Jordan');
INSERT INTO user_action_log VALUES (17018, 1, -1, 'cities', '{1385}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Garmisch, Germany');
INSERT INTO user_action_log VALUES (17019, 1, -1, 'cities', '{1386}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Dakar, Senegal');
INSERT INTO user_action_log VALUES (17020, 1, -1, 'cities', '{1387}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Washington, DC, United States');
INSERT INTO user_action_log VALUES (17021, 1, -1, 'cities', '{1388}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Tokyo, Japan');
INSERT INTO user_action_log VALUES (17022, 1, -1, 'cities', '{1389}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Munich, Germany');
INSERT INTO user_action_log VALUES (17023, 1, -1, 'cities', '{1390}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Tashkent, Uzbekistan');
INSERT INTO user_action_log VALUES (17024, 1, -1, 'cities', '{1391}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Jakarta, Indonesia');
INSERT INTO user_action_log VALUES (17025, 1, -1, 'cities', '{1393}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Seoul, Republic of Korea');
INSERT INTO user_action_log VALUES (17026, 1, -1, 'cities', '{1394}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Cairo, Egypt');
INSERT INTO user_action_log VALUES (17027, 1, -1, 'cities', '{1395}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Vancouver, Canada');
INSERT INTO user_action_log VALUES (17028, 1, -1, 'cities', '{1396}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Sydney, Australia');
INSERT INTO user_action_log VALUES (17029, 1, -1, 'cities', '{1397}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Mexico City, Mexico');
INSERT INTO user_action_log VALUES (17030, 1, -1, 'cities', '{1398}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Kingston, Jamaica');
INSERT INTO user_action_log VALUES (17031, 1, -1, 'cities', '{1399}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Warsaw, Poland');
INSERT INTO user_action_log VALUES (17032, 1, -1, 'cities', '{1400}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Seoul, South Korea');
INSERT INTO user_action_log VALUES (17033, 1, -1, 'cities', '{1401}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Monrovia, Liberia');
INSERT INTO user_action_log VALUES (17034, 1, -1, 'cities', '{1402}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Beirut, Lebanon');
INSERT INTO user_action_log VALUES (17035, 1, -1, 'cities', '{1403}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Dubai, UAE');
INSERT INTO user_action_log VALUES (17036, 1, -1, 'cities', '{1404}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED CITY: Paris, France');
INSERT INTO user_action_log VALUES (17103, 1, -1, 'people', '{6207}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Rex Tillerson, US Government');
INSERT INTO user_action_log VALUES (17104, 1, -1, 'people', '{6208}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Roch Marc Christian Kabore, Unknown');
INSERT INTO user_action_log VALUES (17105, 1, -1, 'people', '{6209}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Saad Hariri, Unknown');
INSERT INTO user_action_log VALUES (17106, 1, -1, 'people', '{6210}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Sabah Al-Khalid-Sabah, Unknown');
INSERT INTO user_action_log VALUES (17107, 1, -1, 'people', '{6211}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Sameh Shoukry, Unknown');
INSERT INTO user_action_log VALUES (17108, 1, -1, 'people', '{6212}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Shavkat Mirziyoyev, Unknown');
INSERT INTO user_action_log VALUES (17109, 1, -1, 'people', '{6213}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Sheikh Sabah Al-Ahmad Al-Sabah, Unknown');
INSERT INTO user_action_log VALUES (17110, 1, -1, 'people', '{6214}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Steve Mnuchin, US Government');
INSERT INTO user_action_log VALUES (17111, 1, -1, 'people', '{6215}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Sukhrob Kholmurodov, Unknown');
INSERT INTO user_action_log VALUES (17112, 1, -1, 'people', '{6216}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Tom Shannon, US Government');
INSERT INTO user_action_log VALUES (17113, 1, -1, 'people', '{6217}', '2018-02-23 05:02:20.67945', 'REMOVING UNREFERENCED PERSON: Yang Jiechi, Unknown');
INSERT INTO user_action_log VALUES (17114, 1, 1, 'people', '{6218}', '2018-02-23 09:42:47.962485', 'Adding Person: Abdel Fattah El-Sisi');
INSERT INTO user_action_log VALUES (17115, 1, 1, 'people', '{6219}', '2018-02-23 09:42:47.962485', 'Adding Person: Abdulaziz Kamilov');
INSERT INTO user_action_log VALUES (17116, 1, 1, 'people', '{6220}', '2018-02-23 09:42:47.962485', 'Adding Person: Abdullah Il Ibn Al-Hussein');
INSERT INTO user_action_log VALUES (17117, 1, 1, 'people', '{6221}', '2018-02-23 09:42:47.962485', 'Adding Person: Adel Al-Jubeir');
INSERT INTO user_action_log VALUES (17118, 1, 1, 'people', '{6222}', '2018-02-23 09:42:47.962485', 'Adding Person: Ali Bin Al Hussein');
INSERT INTO user_action_log VALUES (17119, 1, 1, 'people', '{6223}', '2018-02-23 09:42:47.962485', 'Adding Person: Andrew Holness');
INSERT INTO user_action_log VALUES (17120, 1, 1, 'people', '{6224}', '2018-02-23 09:42:47.962485', 'Adding Person: Ayman Al-Safadi');
INSERT INTO user_action_log VALUES (17121, 1, 1, 'people', '{6225}', '2018-02-23 09:42:47.962485', 'Adding Person: Bill Morneau');
INSERT INTO user_action_log VALUES (17122, 1, 1, 'people', '{6226}', '2018-02-23 09:42:47.962485', 'Adding Person: Cayetana Alijovin');
INSERT INTO user_action_log VALUES (17123, 1, 1, 'people', '{6227}', '2018-02-23 09:42:47.962485', 'Adding Person: Dara Khosrowshahi');
INSERT INTO user_action_log VALUES (17124, 1, 1, 'people', '{6228}', '2018-02-23 09:42:47.962485', 'Adding Person: David Miliband');
INSERT INTO user_action_log VALUES (17125, 1, 1, 'people', '{6229}', '2018-02-23 09:42:47.962485', 'Adding Person: Djamshid Kuchkarov');
INSERT INTO user_action_log VALUES (17126, 1, 1, 'people', '{6230}', '2018-02-23 09:42:47.962485', 'Adding Person: Donald Trump');
INSERT INTO user_action_log VALUES (17127, 1, 1, 'people', '{6231}', '2018-02-23 09:42:47.962485', 'Adding Person: Emmanuel Macron');
INSERT INTO user_action_log VALUES (17128, 1, 1, 'people', '{6232}', '2018-02-23 09:42:47.962485', 'Adding Person: Enrique Pena Nieto');
INSERT INTO user_action_log VALUES (17129, 1, 1, 'people', '{6233}', '2018-02-23 09:42:47.962485', 'Adding Person: Frans Van Houten');
INSERT INTO user_action_log VALUES (17130, 1, 1, 'people', '{6234}', '2018-02-23 09:42:47.962485', 'Adding Person: Gary Cohen');
INSERT INTO user_action_log VALUES (17131, 1, 1, 'people', '{6235}', '2018-02-23 09:42:47.962485', 'Adding Person: George Soros');
INSERT INTO user_action_log VALUES (17132, 1, 1, 'people', '{6236}', '2018-02-23 09:42:47.962485', 'Adding Person: Haider Al-Abadi');
INSERT INTO user_action_log VALUES (17133, 1, 1, 'people', '{6237}', '2018-02-23 09:42:47.962485', 'Adding Person: Hasssan Ali Khaire');
INSERT INTO user_action_log VALUES (17134, 1, 1, 'people', '{6238}', '2018-02-23 09:42:47.962485', 'Adding Person: H.R. Mcmaster');
INSERT INTO user_action_log VALUES (17135, 1, 1, 'people', '{6239}', '2018-02-23 09:42:47.962485', 'Adding Person: Jared Kushner');
INSERT INTO user_action_log VALUES (17136, 1, 1, 'people', '{6240}', '2018-02-23 09:42:47.962485', 'Adding Person: Jim Kim');
INSERT INTO user_action_log VALUES (17137, 1, 1, 'people', '{6241}', '2018-02-23 09:42:47.962485', 'Adding Person: Jimmy Morales');
INSERT INTO user_action_log VALUES (17138, 1, 1, 'people', '{6242}', '2018-02-23 09:42:47.962485', 'Adding Person: Joachim Wenning');
INSERT INTO user_action_log VALUES (17139, 1, 1, 'people', '{6243}', '2018-02-23 09:42:47.962485', 'Adding Person: John Kelly');
INSERT INTO user_action_log VALUES (17140, 1, 1, 'people', '{6244}', '2018-02-23 09:42:47.962485', 'Adding Person: John Sullivan');
INSERT INTO user_action_log VALUES (17141, 1, 1, 'people', '{6245}', '2018-02-23 09:42:47.962485', 'Adding Person: Jorge Faurie');
INSERT INTO user_action_log VALUES (17142, 1, 1, 'people', '{6246}', '2018-02-23 09:42:47.962485', 'Adding Person: Juan Manuel Santos');
INSERT INTO user_action_log VALUES (17143, 1, 1, 'people', '{6247}', '2018-02-23 09:42:47.962485', 'Adding Person: Kamina Johnson Smith');
INSERT INTO user_action_log VALUES (17144, 1, 1, 'people', '{6248}', '2018-02-23 09:42:47.962485', 'Adding Person: Kirstjen Nielsen');
INSERT INTO user_action_log VALUES (17145, 1, 1, 'people', '{6249}', '2018-02-23 09:42:47.962485', 'Adding Person: Kristalina Georgieva');
INSERT INTO user_action_log VALUES (17146, 1, 1, 'people', '{6250}', '2018-02-23 09:42:47.962485', 'Adding Person: Lim Sing-Nam');
INSERT INTO user_action_log VALUES (17147, 1, 1, 'people', '{6251}', '2018-02-23 09:42:47.962485', 'Adding Person: Luis Videgaray');
INSERT INTO user_action_log VALUES (17148, 1, 1, 'people', '{6252}', '2018-02-23 09:42:47.962485', 'Adding Person: Machy Sall');
INSERT INTO user_action_log VALUES (17149, 1, 1, 'people', '{6253}', '2018-02-23 09:42:47.962485', 'Adding Person: Madeline Albright');
INSERT INTO user_action_log VALUES (17150, 1, 1, 'people', '{6254}', '2018-02-23 09:42:47.962485', 'Adding Person: Maria Angela Holguin');
INSERT INTO user_action_log VALUES (17151, 1, 1, 'people', '{6255}', '2018-02-23 09:42:47.962485', 'Adding Person: Mark Green');
INSERT INTO user_action_log VALUES (17152, 1, 1, 'people', '{6256}', '2018-02-23 09:42:47.962485', 'Adding Person: Mark Suzman');
INSERT INTO user_action_log VALUES (17153, 1, 1, 'people', '{6257}', '2018-02-23 09:42:47.962485', 'Adding Person: Mauricio Marci');
INSERT INTO user_action_log VALUES (17154, 1, 1, 'people', '{6258}', '2018-02-23 09:42:47.962485', 'Adding Person: Michel Aoun');
INSERT INTO user_action_log VALUES (17155, 1, 1, 'people', '{6259}', '2018-02-23 09:42:47.962485', 'Adding Person: Mike Pence');
INSERT INTO user_action_log VALUES (17156, 1, 1, 'people', '{6260}', '2018-02-23 09:42:47.962485', 'Adding Person: Nursultan Nazarbayev');
INSERT INTO user_action_log VALUES (17157, 1, 1, 'people', '{6261}', '2018-02-23 09:42:47.962485', 'Adding Person: Pedro Pablo Kuczynski');
INSERT INTO user_action_log VALUES (17158, 1, 1, 'people', '{6262}', '2018-02-23 09:42:47.962485', 'Adding Person: Perry Acosta');
INSERT INTO user_action_log VALUES (17159, 1, 1, 'people', '{6263}', '2018-02-23 09:42:47.962485', 'Adding Person: Petri Gormiztka');
INSERT INTO user_action_log VALUES (17160, 1, 1, 'people', '{6264}', '2018-02-23 09:42:47.962485', 'Adding Person: Queen Mathilde Of Belgium');
INSERT INTO user_action_log VALUES (17161, 1, 1, 'people', '{6265}', '2018-02-23 09:42:47.962485', 'Adding Person: Rex Tillerson');
INSERT INTO user_action_log VALUES (17162, 1, 1, 'people', '{6266}', '2018-02-23 09:42:47.962485', 'Adding Person: Roch Marc Christian Kabore');
INSERT INTO user_action_log VALUES (17163, 1, 1, 'people', '{6267}', '2018-02-23 09:42:47.962485', 'Adding Person: Saad Hariri');
INSERT INTO user_action_log VALUES (17164, 1, 1, 'people', '{6268}', '2018-02-23 09:42:47.962485', 'Adding Person: Sabah Al-Khalid-Sabah');
INSERT INTO user_action_log VALUES (17165, 1, 1, 'people', '{6269}', '2018-02-23 09:42:47.962485', 'Adding Person: Sameh Shoukry');
INSERT INTO user_action_log VALUES (17166, 1, 1, 'people', '{6270}', '2018-02-23 09:42:47.962485', 'Adding Person: Shavkat Mirziyoyev');
INSERT INTO user_action_log VALUES (17167, 1, 1, 'people', '{6271}', '2018-02-23 09:42:47.962485', 'Adding Person: Sheikh Sabah Al-Ahmad Al-Sabah');
INSERT INTO user_action_log VALUES (17168, 1, 1, 'people', '{6272}', '2018-02-23 09:42:47.962485', 'Adding Person: Steve Mnuchin');
INSERT INTO user_action_log VALUES (17169, 1, 1, 'people', '{6273}', '2018-02-23 09:42:47.962485', 'Adding Person: Sukhrob Kholmurodov');
INSERT INTO user_action_log VALUES (17170, 1, 1, 'people', '{6274}', '2018-02-23 09:42:47.962485', 'Adding Person: Tom Shannon');
INSERT INTO user_action_log VALUES (17171, 1, 1, 'people', '{6275}', '2018-02-23 09:42:47.962485', 'Adding Person: Yang Jiechi');
INSERT INTO user_action_log VALUES (17172, 0, 0, 'people', '{6249}', '2018-02-23 09:42:47.962485', 'Upadting Person: Kristalina Georgieva: is_wbg=YES');
INSERT INTO user_action_log VALUES (17173, 0, 0, 'people', '{6240}', '2018-02-23 09:42:47.962485', 'Upadting Person: Jim Kim: is_wbg=YES');
INSERT INTO user_action_log VALUES (17174, 1, 1, 'cities', '{1411}', '2018-02-23 09:42:47.962485', 'Adding City: Bogota, Colombia');
INSERT INTO user_action_log VALUES (17175, 1, 1, 'cities', '{1412}', '2018-02-23 09:42:47.962485', 'Adding City: London, UK');
INSERT INTO user_action_log VALUES (17176, 1, 1, 'cities', '{1413}', '2018-02-23 09:42:47.962485', 'Adding City: Amman, Jordan');
INSERT INTO user_action_log VALUES (17177, 1, 1, 'cities', '{1414}', '2018-02-23 09:42:47.962485', 'Adding City: Garmisch, Germany');
INSERT INTO user_action_log VALUES (17178, 1, 1, 'cities', '{1415}', '2018-02-23 09:42:47.962485', 'Adding City: Dakar, Senegal');
INSERT INTO user_action_log VALUES (17179, 1, 1, 'cities', '{1416}', '2018-02-23 09:42:47.962485', 'Adding City: Washington, DC, United States');
INSERT INTO user_action_log VALUES (17180, 1, 1, 'cities', '{1417}', '2018-02-23 09:42:47.962485', 'Adding City: Tokyo, Japan');
INSERT INTO user_action_log VALUES (17181, 1, 1, 'cities', '{1418}', '2018-02-23 09:42:47.962485', 'Adding City: Munich, Germany');
INSERT INTO user_action_log VALUES (17182, 1, 1, 'cities', '{1419}', '2018-02-23 09:42:47.962485', 'Adding City: Tashkent, Uzbekistan');
INSERT INTO user_action_log VALUES (17183, 1, 1, 'cities', '{1420}', '2018-02-23 09:42:47.962485', 'Adding City: Jakarta, Indonesia');
INSERT INTO user_action_log VALUES (17184, 1, 1, 'cities', '{1421}', '2018-02-23 09:42:47.962485', 'Adding City: Jerusalem, Israel');
INSERT INTO user_action_log VALUES (17185, 1, 1, 'cities', '{1422}', '2018-02-23 09:42:47.962485', 'Adding City: Seoul, Republic of Korea');
INSERT INTO user_action_log VALUES (17186, 1, 1, 'cities', '{1423}', '2018-02-23 09:42:47.962485', 'Adding City: Cairo, Egypt');
INSERT INTO user_action_log VALUES (17187, 1, 1, 'cities', '{1424}', '2018-02-23 09:42:47.962485', 'Adding City: Vancouver, Canada');
INSERT INTO user_action_log VALUES (17188, 1, 1, 'cities', '{1425}', '2018-02-23 09:42:47.962485', 'Adding City: Junkcity, JunkCountry');
INSERT INTO user_action_log VALUES (17189, 1, 1, 'cities', '{1426}', '2018-02-23 09:42:47.962485', 'Adding City: Sydney, Australia');
INSERT INTO user_action_log VALUES (17190, 1, 1, 'cities', '{1427}', '2018-02-23 09:42:47.962485', 'Adding City: Mexico City, Mexico');
INSERT INTO user_action_log VALUES (17191, 1, 1, 'cities', '{1428}', '2018-02-23 09:42:47.962485', 'Adding City: Kingston, Jamaica');
INSERT INTO user_action_log VALUES (17192, 1, 1, 'cities', '{1429}', '2018-02-23 09:42:47.962485', 'Adding City: Warsaw, Poland');
INSERT INTO user_action_log VALUES (17193, 1, 1, 'cities', '{1430}', '2018-02-23 09:42:47.962485', 'Adding City: Seoul, South Korea');
INSERT INTO user_action_log VALUES (17194, 1, 1, 'cities', '{1431}', '2018-02-23 09:42:47.962485', 'Adding City: Monrovia, Liberia');
INSERT INTO user_action_log VALUES (17195, 1, 1, 'cities', '{1432}', '2018-02-23 09:42:47.962485', 'Adding City: Beirut, Lebanon');
INSERT INTO user_action_log VALUES (17196, 1, 1, 'cities', '{1433}', '2018-02-23 09:42:47.962485', 'Adding City: Paris, France');
INSERT INTO user_action_log VALUES (17197, 1, 1, 'cities', '{1434}', '2018-02-23 09:42:47.962485', 'Adding City: Ankara, Turkey');
INSERT INTO user_action_log VALUES (17198, 1, 1, 'cities', '{1435}', '2018-02-23 09:42:47.962485', 'Adding City: Buenos Aires, Argentina');
INSERT INTO user_action_log VALUES (17199, 1, 1, 'cities', '{1436}', '2018-02-23 09:42:47.962485', 'Adding City: Davos, Switzerland');
INSERT INTO user_action_log VALUES (17200, 1, 1, 'cities', '{1437}', '2018-02-23 09:42:47.962485', 'Adding City: Kuwait City, Kuwait');
INSERT INTO user_action_log VALUES (17201, 1, 1, 'cities', '{1438}', '2018-02-23 09:42:47.962485', 'Adding City: Lima, Peru');
INSERT INTO user_action_log VALUES (17202, 1, 1, 'trips', '{6088}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Paris [ON] 2088-01-24 {MEL:c4bca428211c2b48b81fd3b12afd2aa1}');
INSERT INTO user_action_log VALUES (17203, 1, 1, 'trips', '{6089}', '2018-02-23 09:42:47.962485', 'Adding Trip: Donald Trump [TO] Washington, DC [ON] 2088-01-19 {MEL:3bd318565e4adbe5f4b6abf2ffebf3a0}');
INSERT INTO user_action_log VALUES (17204, 1, 1, 'trips', '{6090}', '2018-02-23 09:42:47.962485', 'Adding Trip: John Kelly [TO] Davos [ON] 2088-01-26 {MEL:0fcee95cc7b4f2067da8ba1e330de18e}');
INSERT INTO user_action_log VALUES (17205, 1, 1, 'trips', '{6091}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Dakar [ON] 2088-02-03 {MEL:a4e858c15255e55d5e1e221bd151154f}');
INSERT INTO user_action_log VALUES (17206, 1, 1, 'trips', '{6092}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Davos [ON] 2088-01-27 {MEL:265c2b6a26807154013753637b68d01d}');
INSERT INTO user_action_log VALUES (17207, 1, 1, 'trips', '{6093}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mark Green [TO] Garmisch [ON] 2088-02-17 {MEL:1438ecb8cb1f6fadfee2190700789d7b}');
INSERT INTO user_action_log VALUES (17208, 1, 1, 'trips', '{6094}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Washington, DC [ON] 2088-02-10 {MEL:ce5193a069bea027a60e06c57a106eb6}');
INSERT INTO user_action_log VALUES (17209, 1, 1, 'trips', '{6095}', '2018-02-23 09:42:47.962485', 'Adding Trip: Donald Trump [TO] Davos [ON] 2088-01-25 {MEL:000c076c390a4c357313fca29e390ece}');
INSERT INTO user_action_log VALUES (17210, 1, 1, 'trips', '{6096}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Warsaw [ON] 2088-01-28 {MEL:e7dfca01f394755c11f853602cb2608a}');
INSERT INTO user_action_log VALUES (17211, 1, 1, 'trips', '{6097}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kirstjen Nielsen [TO] Davos [ON] 2088-01-26 {MEL:afb79a9be5cd9762572a008088d3153e}');
INSERT INTO user_action_log VALUES (17212, 1, 1, 'trips', '{6098}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Amman [ON] 2088-02-16 {MEL:34e420f6e47d96669897a45586997a57}');
INSERT INTO user_action_log VALUES (17213, 1, 1, 'trips', '{6099}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Davos [ON] 2088-01-25 {MEL:80c0e8c4457441901351e4abbcf8c75c}');
INSERT INTO user_action_log VALUES (17214, 1, 1, 'trips', '{6100}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Lima [ON] 2088-02-07 {MEL:802a5fd4efb36391dfa8f1991fd0f849}');
INSERT INTO user_action_log VALUES (17215, 1, 1, 'trips', '{6101}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Kingston [ON] 2088-02-09 {MEL:2cfa47a65809ea0496bbf9aa363dc5da}');
INSERT INTO user_action_log VALUES (17216, 1, 1, 'trips', '{6102}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kristalina Georgieva [TO] Washington, DC [ON] 2088-03-09 {MEL:7bec7e63a493e2d61891b1e4051ef75a}');
INSERT INTO user_action_log VALUES (17217, 1, 1, 'trips', '{6103}', '2018-02-23 09:42:47.962485', 'Adding Trip: Tom Shannon [TO] Vancouver [ON] 2088-02-10 {MEL:56880339cfb8fe04c2d17c6160d0512f}');
INSERT INTO user_action_log VALUES (17218, 1, 1, 'trips', '{6104}', '2018-02-23 09:42:47.962485', 'Adding Trip: Steve Mnuchin [TO] Davos [ON] 2088-01-26 {MEL:46384036044a604b6b3316fc167fc15f}');
INSERT INTO user_action_log VALUES (17219, 1, 1, 'trips', '{6105}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Jakarta [ON] 2088-04-20 {MEL:c1d53b7a97707b5cd1815c8d228d8ef1}');
INSERT INTO user_action_log VALUES (17220, 1, 1, 'trips', '{6106}', '2018-02-23 09:42:47.962485', 'Adding Trip: Tom Shannon [TO] Monrovia [ON] 2088-01-25 {MEL:6933b5648c59d618bbb30986c84080fe}');
INSERT INTO user_action_log VALUES (17221, 1, 1, 'trips', '{6107}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Seoul [ON] 2088-02-11 {MEL:29586cb449c90e249f1f09a0a4ee245a}');
INSERT INTO user_action_log VALUES (17222, 1, 1, 'trips', '{6108}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Munich [ON] 2088-02-18 {MEL:c09b1eadea0efc7914f73ac698494b5e}');
INSERT INTO user_action_log VALUES (17223, 1, 1, 'trips', '{6109}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mark Green [TO] London [ON] 2088-02-20 {MEL:27b09e189a405b6cca6ddd7ec869c143}');
INSERT INTO user_action_log VALUES (17224, 1, 1, 'trips', '{6110}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Lima [ON] 2088-02-08 {MEL:5460b9ea1986ec386cb64df22dff37be}');
INSERT INTO user_action_log VALUES (17225, 1, 1, 'trips', '{6111}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kristalina Georgieva [TO] Tashkent [ON] 2088-01-20 {MEL:721e049e9903c3a740c4902878c99923}');
INSERT INTO user_action_log VALUES (17226, 1, 1, 'trips', '{6112}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2088-01-26 {MEL:0b6a27e2bfcb010e762109f0d2e042dc}');
INSERT INTO user_action_log VALUES (17227, 1, 1, 'trips', '{6113}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Mexico City [ON] 2088-02-03 {MEL:0af854284f4ab0cfea8fcfd889cbb41a}');
INSERT INTO user_action_log VALUES (17228, 1, 1, 'trips', '{6114}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2088-01-27 {MEL:75c58d36157505a600e0695ed0b3a22d}');
INSERT INTO user_action_log VALUES (17229, 1, 1, 'trips', '{6115}', '2018-02-23 09:42:47.962485', 'Adding Trip: Perry Acosta [TO] Davos [ON] 2088-01-26 {MEL:c77cfd5563c8ec4bfcde94c09098ba84}');
INSERT INTO user_action_log VALUES (17230, 1, 1, 'trips', '{6116}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Washington, DC [ON] 2088-01-14 {MEL:082a8bbf2c357c09f26675f9cf5bcba3}');
INSERT INTO user_action_log VALUES (17231, 1, 1, 'trips', '{6117}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Cairo [ON] 2088-02-14 {MEL:84e2d85ac232c681a641da1ec663888c}');
INSERT INTO user_action_log VALUES (17232, 1, 1, 'trips', '{6118}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] London [ON] 2088-01-23 {MEL:1755c118e8859eb000eb6eca25369407}');
INSERT INTO user_action_log VALUES (17233, 1, 1, 'trips', '{6119}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Kuwait City [ON] 2088-02-14 {MEL:7bb7a62681a8a0f94ab424b06d172ca3}');
INSERT INTO user_action_log VALUES (17234, 1, 1, 'trips', '{6120}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Beirut [ON] 2088-02-18 {MEL:cfa258af990f9cb188d36ddb5c6eb650}');
INSERT INTO user_action_log VALUES (17235, 1, 1, 'trips', '{6121}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Jerusalem [ON] 2088-01-24 {MEL:03fcd68e5673f08be96d2b6bb5be8261}');
INSERT INTO user_action_log VALUES (17236, 1, 1, 'trips', '{6122}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kristalina Georgieva [TO] Davos [ON] 2088-01-25 {MEL:8aa2c95dc0a6833d2d0cb944555739cc}');
INSERT INTO user_action_log VALUES (17237, 1, 1, 'trips', '{6123}', '2018-02-23 09:42:47.962485', 'Adding Trip: Donald Trump [TO] Washington, DC [ON] 2088-02-10 {MEL:4ca82b2a861f70cd15d83085b000dbde}');
INSERT INTO user_action_log VALUES (17238, 1, 1, 'trips', '{6124}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Buenos Aires [ON] 2088-02-05 {MEL:b16e8712b35e498857df08af3944b127}');
INSERT INTO user_action_log VALUES (17239, 1, 1, 'trips', '{6125}', '2018-02-23 09:42:47.962485', 'Adding Trip: H.R. Mcmaster [TO] Davos [ON] 2088-01-26 {MEL:6e3b0bf8b7d5956ae572b15cd7ddb0e1}');
INSERT INTO user_action_log VALUES (17240, 1, 1, 'trips', '{6126}', '2018-02-23 09:42:47.962485', 'Adding Trip: Tom Shannon [TO] Washington, DC [ON] 2088-01-19 {MEL:421740375847b6249d9383615831c23b}');
INSERT INTO user_action_log VALUES (17241, 1, 1, 'trips', '{6127}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Washington, DC [ON] 2088-02-25 {MEL:9570efef719d705326f0ff817ef084e6}');
INSERT INTO user_action_log VALUES (17242, 1, 1, 'trips', '{6128}', '2018-02-23 09:42:47.962485', 'Adding Trip: Gary Cohen [TO] Davos [ON] 2088-01-26 {MEL:b72a5a099433a2099fc3d92f6ad3accf}');
INSERT INTO user_action_log VALUES (17243, 1, 1, 'trips', '{6129}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Ankara [ON] 2088-02-17 {MEL:acc21473c4525b922286130ffbfe00b5}');
INSERT INTO user_action_log VALUES (17244, 1, 1, 'trips', '{6130}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Seoul [ON] 2088-04-16 {MEL:7b99efbc101a6013d2c710028bca5cbf}');
INSERT INTO user_action_log VALUES (17245, 1, 1, 'trips', '{6131}', '2018-02-23 09:42:47.962485', 'Adding Trip: John Sullivan [TO] Washington, DC [ON] 2088-01-19 {MEL:392526094bcba21af9fd4102ce5ed092}');
INSERT INTO user_action_log VALUES (17246, 1, 1, 'trips', '{6132}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Junkcity [ON] 2088-02-11 {MEL:36d5ef2a011f0b3e0e0fa139228bbe18}');
INSERT INTO user_action_log VALUES (17247, 1, 1, 'trips', '{6133}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Davos [ON] 2088-01-26 {MEL:c5df4f4eabf1cbcfeb50fbbf97c5289f}');
INSERT INTO user_action_log VALUES (17248, 1, 1, 'trips', '{6134}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mark Green [TO] Munich [ON] 2088-02-18 {MEL:1ca5c750a30312d1919ae6a4d636dcc4}');
INSERT INTO user_action_log VALUES (17249, 1, 1, 'trips', '{6135}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Sydney [ON] 2088-04-22 {MEL:4cc5400e63624c44fadeda99f57588a6}');
INSERT INTO user_action_log VALUES (17250, 1, 1, 'trips', '{6136}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Cairo [ON] 2088-01-22 {MEL:c1285fcadc52c0d3dc8813fc2c2e2b2a}');
INSERT INTO user_action_log VALUES (17251, 1, 1, 'trips', '{6137}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Amman [ON] 2088-01-23 {MEL:b8c8c63d4b8856c7872b225e53a6656c}');
INSERT INTO user_action_log VALUES (17252, 1, 1, 'trips', '{6138}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mark Green [TO] Washington, DC [ON] 2088-01-19 {MEL:b2ead76dfdc4ae56a2abd1896ec46291}');
INSERT INTO user_action_log VALUES (17253, 1, 1, 'trips', '{6139}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Kuwait City [ON] 2088-02-15 {MEL:618faa1728eb2ef6e3733645273ab145}');
INSERT INTO user_action_log VALUES (17254, 1, 1, 'trips', '{6140}', '2018-02-23 09:42:47.962485', 'Adding Trip: Mike Pence [TO] Tokyo [ON] 2088-04-19 {MEL:3d7d9461075eb7c37fbbfcad1d7042c1}');
INSERT INTO user_action_log VALUES (17255, 1, 1, 'trips', '{6141}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jared Kushner [TO] Davos [ON] 2088-01-26 {MEL:13d2b7361a27dbc9960ae158598a6a96}');
INSERT INTO user_action_log VALUES (17256, 1, 1, 'trips', '{6142}', '2018-02-23 09:42:47.962485', 'Adding Trip: Rex Tillerson [TO] Bogota [ON] 2088-02-08 {MEL:7d4ba7006351436c35e283b0be8ff56c}');
INSERT INTO user_action_log VALUES (17257, 1, 1, 'trips', '{6143}', '2018-02-23 09:42:47.962485', 'Adding Trip: Kristalina Georgieva [TO] Munich [ON] 2088-02-17 {MEL:de9621d4c6fa69ce8aaa90f00e9110c5}');
INSERT INTO user_action_log VALUES (17258, 1, 1, 'trips', '{6144}', '2018-02-23 09:42:47.962485', 'Adding Trip: Jim Kim [TO] Amman [ON] 2088-02-13 {MEL:197f76fe309657064dbec74d9eea4be4}');
INSERT INTO user_action_log VALUES (17259, 1, 1, 'venue_events', '{641}', '2018-02-23 09:42:47.962485', 'Adding Venue: National Prayer Breakfast - Feb 2088 [AS] Small Event [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17260, 1, 1, 'venue_events', '{640}', '2018-02-23 09:42:47.962485', 'Adding Venue: Munich Security Conference - Feb 2088 [AS] Small Event [IN] Munich');
INSERT INTO user_action_log VALUES (17261, 1, 1, 'venue_events', '{639}', '2018-02-23 09:42:47.962485', 'Adding Venue: Iraqi Reconstruction Conference - Feb 2088 [AS] Small Event [IN] Kuwait City');
INSERT INTO user_action_log VALUES (17262, 1, 1, 'venue_events', '{638}', '2018-02-23 09:42:47.962485', 'Adding Venue: Africa Strategic Integration Conference - Feb 2088 [AS] Small Event [IN] Garmisch');
INSERT INTO user_action_log VALUES (17263, 1, 1, 'venue_events', '{644}', '2018-02-23 09:42:47.962485', 'Adding Venue: World Economic Forum - Jan 2088 [AS] Major Event [IN] Davos');
INSERT INTO user_action_log VALUES (17264, 1, 1, 'venue_events', '{643}', '2018-02-23 09:42:47.962485', 'Adding Venue: Winter Olympics - Feb 2088 [AS] Major Event [IN] Seoul');
INSERT INTO user_action_log VALUES (17265, 1, 1, 'venue_events', '{642}', '2018-02-23 09:42:47.962485', 'Adding Venue: One Planet Summit - Feb 2088 [AS] Major Event [IN] Dakar');
INSERT INTO user_action_log VALUES (17266, 1, 1, 'trip_meetings', '{6270,6111}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Shavkat Mirziyoyev [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (17267, 1, 1, 'trip_meetings', '{6249,6143}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Kristalina Georgieva [AND] Kristalina Georgieva [AT] Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17268, 1, 1, 'trip_meetings', '{6233,6092}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Frans Van Houten [AND] Jim Kim [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17269, 1, 1, 'trip_meetings', '{6266,6091}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Roch Marc Christian Kabore [AND] Jim Kim [AT] One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (17270, 1, 1, 'trip_meetings', '{6269,6117}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Sameh Shoukry [AND] Rex Tillerson [IN] Cairo');
INSERT INTO user_action_log VALUES (17271, 1, 1, 'trip_meetings', '{6255,6134}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Mark Green [AND] Mark Green [AT] Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17272, 1, 1, 'trip_meetings', '{6219,6126}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Abdulaziz Kamilov [AND] Tom Shannon [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17273, 1, 1, 'trip_meetings', '{6224,6098}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Ayman Al-Safadi [AND] Rex Tillerson [IN] Amman');
INSERT INTO user_action_log VALUES (17274, 1, 1, 'trip_meetings', '{6251,6113}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Luis Videgaray [AND] Rex Tillerson [IN] Mexico City');
INSERT INTO user_action_log VALUES (17275, 1, 1, 'trip_meetings', '{6241,6094}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Jimmy Morales [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17276, 1, 1, 'trip_meetings', '{6253,6102}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Madeline Albright [AND] Kristalina Georgieva [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17277, 1, 1, 'trip_meetings', '{6236,6139}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Haider Al-Abadi [AND] Rex Tillerson [AT] Iraqi Reconstruction Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17278, 1, 1, 'trip_meetings', '{6256,6112}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Mark Suzman [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17279, 1, 1, 'trip_meetings', '{6228,6126}', '2018-02-23 09:42:47.962485', 'Adding Meeting: David Miliband [AND] Tom Shannon [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17280, 1, 1, 'trip_meetings', '{6258,6120}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Michel Aoun [AND] Rex Tillerson [IN] Beirut');
INSERT INTO user_action_log VALUES (17281, 1, 1, 'trip_meetings', '{6223,6101}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Andrew Holness [AND] Rex Tillerson [IN] Kingston');
INSERT INTO user_action_log VALUES (17282, 1, 1, 'trip_meetings', '{6218,6136}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Abdel Fattah El-Sisi [AND] Mike Pence [IN] Cairo');
INSERT INTO user_action_log VALUES (17283, 1, 1, 'trip_meetings', '{6252,6091}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Machy Sall [AND] Jim Kim [AT] One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (17284, 1, 1, 'trip_meetings', '{6247,6101}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Kamina Johnson Smith [AND] Rex Tillerson [IN] Kingston');
INSERT INTO user_action_log VALUES (17285, 1, 1, 'trip_meetings', '{6239,6141}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Jared Kushner [AND] Jared Kushner [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17286, 1, 1, 'trip_meetings', '{6231,6091}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Emmanuel Macron [AND] Jim Kim [AT] One Planet Summit - Feb 2088');
INSERT INTO user_action_log VALUES (17287, 1, 1, 'trip_meetings', '{6257,6124}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Mauricio Marci [AND] Rex Tillerson [IN] Buenos Aires');
INSERT INTO user_action_log VALUES (17288, 1, 1, 'trip_meetings', '{6238,6125}', '2018-02-23 09:42:47.962485', 'Adding Meeting: H.R. Mcmaster [AND] H.R. Mcmaster [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17289, 1, 1, 'trip_meetings', '{6275,6094}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Yang Jiechi [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17290, 1, 1, 'trip_meetings', '{6220,6098}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Abdullah Il Ibn Al-Hussein [AND] Rex Tillerson [IN] Amman');
INSERT INTO user_action_log VALUES (17291, 1, 1, 'trip_meetings', '{6243,6090}', '2018-02-23 09:42:47.962485', 'Adding Meeting: John Kelly [AND] John Kelly [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17292, 1, 1, 'trip_meetings', '{6265,6133}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Rex Tillerson [AND] Rex Tillerson [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17293, 1, 1, 'trip_meetings', '{6237,6114}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Hasssan Ali Khaire [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17294, 1, 1, 'trip_meetings', '{6261,6110}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Pedro Pablo Kuczynski [AND] Rex Tillerson [IN] Lima');
INSERT INTO user_action_log VALUES (17295, 1, 1, 'trip_meetings', '{6248,6097}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Kirstjen Nielsen [AND] Kirstjen Nielsen [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17296, 1, 1, 'trip_meetings', '{6267,6120}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Saad Hariri [AND] Rex Tillerson [IN] Beirut');
INSERT INTO user_action_log VALUES (17297, 1, 1, 'trip_meetings', '{6273,6111}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Sukhrob Kholmurodov [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (17298, 1, 1, 'trip_meetings', '{6222,6137}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Ali Bin Al Hussein [AND] Mike Pence [IN] Amman');
INSERT INTO user_action_log VALUES (17299, 1, 1, 'trip_meetings', '{6268,6119}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Sabah Al-Khalid-Sabah [AND] Rex Tillerson [IN] Kuwait City');
INSERT INTO user_action_log VALUES (17300, 1, 1, 'trip_meetings', '{6263,6138}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Petri Gormiztka [AND] Mark Green [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17301, 1, 1, 'trip_meetings', '{6241,6123}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Jimmy Morales [AND] Donald Trump [AT] National Prayer Breakfast - Feb 2088');
INSERT INTO user_action_log VALUES (17302, 1, 1, 'trip_meetings', '{6264,6112}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Queen Mathilde Of Belgium [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17303, 1, 1, 'trip_meetings', '{6221,6116}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Adel Al-Jubeir [AND] Rex Tillerson [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17304, 1, 1, 'trip_meetings', '{6240,6108}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Jim Kim [AND] Jim Kim [AT] Munich Security Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17305, 1, 1, 'trip_meetings', '{6235,6122}', '2018-02-23 09:42:47.962485', 'Adding Meeting: George Soros [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17306, 1, 1, 'trip_meetings', '{6226,6100}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Cayetana Alijovin [AND] Rex Tillerson [IN] Lima');
INSERT INTO user_action_log VALUES (17307, 1, 1, 'trip_meetings', '{6230,6095}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Donald Trump [AND] Donald Trump [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17308, 1, 1, 'trip_meetings', '{6250,6131}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Lim Sing-Nam [AND] John Sullivan [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17309, 1, 1, 'trip_meetings', '{6271,6139}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Sheikh Sabah Al-Ahmad Al-Sabah [AND] Rex Tillerson [IN] Kuwait City');
INSERT INTO user_action_log VALUES (17310, 1, 1, 'trip_meetings', '{6246,6142}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Juan Manuel Santos [AND] Rex Tillerson [IN] Bogota');
INSERT INTO user_action_log VALUES (17311, 1, 1, 'trip_meetings', '{6255,6093}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Mark Green [AND] Mark Green [AT] Africa Strategic Integration Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17312, 1, 1, 'trip_meetings', '{6227,6099}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Dara Khosrowshahi [AND] Jim Kim [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17313, 1, 1, 'trip_meetings', '{6234,6128}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Gary Cohen [AND] Gary Cohen [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17314, 1, 1, 'trip_meetings', '{6260,6089}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Nursultan Nazarbayev [AND] Donald Trump [IN] Washington, DC');
INSERT INTO user_action_log VALUES (17315, 1, 1, 'trip_meetings', '{6265,6139}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Rex Tillerson [AND] Rex Tillerson [AT] Iraqi Reconstruction Conference - Feb 2088');
INSERT INTO user_action_log VALUES (17316, 1, 1, 'trip_meetings', '{6232,6113}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Enrique Pena Nieto [AND] Rex Tillerson [IN] Mexico City');
INSERT INTO user_action_log VALUES (17317, 1, 1, 'trip_meetings', '{6229,6111}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Djamshid Kuchkarov [AND] Kristalina Georgieva [IN] Tashkent');
INSERT INTO user_action_log VALUES (17318, 1, 1, 'trip_meetings', '{6225,6122}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Bill Morneau [AND] Kristalina Georgieva [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17319, 1, 1, 'trip_meetings', '{6262,6115}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Perry Acosta [AND] Perry Acosta [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17320, 1, 1, 'trip_meetings', '{6254,6142}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Maria Angela Holguin [AND] Rex Tillerson [IN] Bogota');
INSERT INTO user_action_log VALUES (17321, 1, 1, 'trip_meetings', '{6272,6104}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Steve Mnuchin [AND] Steve Mnuchin [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17322, 1, 1, 'trip_meetings', '{6242,6092}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Joachim Wenning [AND] Jim Kim [AT] World Economic Forum - Jan 2088');
INSERT INTO user_action_log VALUES (17323, 1, 1, 'trip_meetings', '{6259,6107}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Mike Pence [AND] Mike Pence [AT] Winter Olympics - Feb 2088');
INSERT INTO user_action_log VALUES (17324, 1, 1, 'trip_meetings', '{6218,6117}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Abdel Fattah El-Sisi [AND] Rex Tillerson [IN] Cairo');
INSERT INTO user_action_log VALUES (17325, 1, 1, 'trip_meetings', '{6245,6124}', '2018-02-23 09:42:47.962485', 'Adding Meeting: Jorge Faurie [AND] Rex Tillerson [IN] Buenos Aires');
INSERT INTO user_action_log VALUES (17346, 1, -1, 'venue_events', '{660}', '2018-02-23 12:48:20.694672', 'REMOVING UNREFERENCED VENUE: Pavlo Klimkin');
INSERT INTO user_action_log VALUES (17347, 1, -1, 'venue_events', '{661}', '2018-02-23 12:48:20.694672', 'REMOVING UNREFERENCED VENUE: Petro Poroshenko');
INSERT INTO user_action_log VALUES (17348, 1, -1, 'venue_events', '{662}', '2018-02-23 12:48:20.694672', 'REMOVING UNREFERENCED VENUE: Volodymyr Groysman');
INSERT INTO user_action_log VALUES (17349, 1, -1, 'people', '{6294}', '2018-02-23 12:48:20.694672', 'REMOVING UNREFERENCED PERSON: G5 Sahel Donors, Unknown');
INSERT INTO user_action_log VALUES (17350, 1, -1, 'people', '{6295}', '2018-02-23 12:48:20.694672', 'REMOVING UNREFERENCED PERSON: Nato Conference, Unknown');
INSERT INTO user_action_log VALUES (17351, 1, -1, 'people', '{6296}', '2018-02-23 12:48:20.694672', 'REMOVING UNREFERENCED PERSON:  U.S.-Uk Strategic Dialogue On Developme, Unknown');
INSERT INTO user_action_log VALUES (17352, 1, 1, 'people', '{6303}', '2018-02-23 12:48:20.694672', 'Adding Person: G5 Sahel Donors');
INSERT INTO user_action_log VALUES (17353, 1, 1, 'people', '{6304}', '2018-02-23 12:48:20.694672', 'Adding Person: Nato Conference');
INSERT INTO user_action_log VALUES (17354, 1, 1, 'people', '{6305}', '2018-02-23 12:48:20.694672', 'Adding Person:  U.S.-Uk Strategic Dialogue On Developme');


--
-- TOC entry 3829 (class 0 OID 42532)
-- Dependencies: 245
-- Data for Name: users; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO users VALUES (2, 'CEOSI', 'CEOSI2018', true, NULL, 'Team account for unit CEOSI, Strategic Initiatives');
INSERT INTO users VALUES (1, 'MEL', 'FIGSSAMEL', true, NULL, 'Team account for MEL team, developer''s account');
INSERT INTO users VALUES (0, 'SYSTEM', '', false, NULL, 'System account: updates automated data, where deemed relevant');


--
-- TOC entry 3825 (class 0 OID 42370)
-- Dependencies: 241
-- Data for Name: venue_events; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO venue_events VALUES (0, 'Unspecified Venue', 'Unspecified', 0, NULL, '', NULL, NULL, false);
INSERT INTO venue_events VALUES (638, 'Africa Strategic Integration Conference - Feb 2088', NULL, 5, 1414, 'Africa Strategic Integration Conference', '2088-02-17', '2088-02-18', false);
INSERT INTO venue_events VALUES (639, 'Iraqi Reconstruction Conference - Feb 2088', NULL, 5, 1437, 'Iraqi Reconstruction Conference', '2088-02-15', '2088-02-15', false);
INSERT INTO venue_events VALUES (640, 'Munich Security Conference - Feb 2088', NULL, 5, 1418, 'Munich Security Conference', '2088-02-17', '2088-02-19', false);
INSERT INTO venue_events VALUES (641, 'National Prayer Breakfast - Feb 2088', NULL, 5, 1416, 'National Prayer Breakfast', '2088-02-10', '2088-02-10', false);
INSERT INTO venue_events VALUES (642, 'One Planet Summit - Feb 2088', NULL, 6, 1415, 'One Planet Summit', '2088-02-03', '2088-02-06', true);
INSERT INTO venue_events VALUES (643, 'Winter Olympics - Feb 2088', NULL, 6, 1422, 'Winter Olympics', '2088-02-11', '2088-02-11', true);
INSERT INTO venue_events VALUES (644, 'World Economic Forum - Jan 2088', NULL, 6, 1436, 'World Economic Forum', '2088-01-25', '2088-01-28', true);


--
-- TOC entry 3827 (class 0 OID 42387)
-- Dependencies: 243
-- Data for Name: venue_types; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO venue_types VALUES (1, 'Organization', false);
INSERT INTO venue_types VALUES (2, 'Client', false);
INSERT INTO venue_types VALUES (3, 'Donor', false);
INSERT INTO venue_types VALUES (4, 'Government', false);
INSERT INTO venue_types VALUES (5, 'Small Event', true);
INSERT INTO venue_types VALUES (6, 'Major Event', true);
INSERT INTO venue_types VALUES (0, 'Unknown', false);


SET search_path = public, pg_catalog;

--
-- TOC entry 3832 (class 0 OID 45388)
-- Dependencies: 250
-- Data for Name: _temp_travel_uploads; Type: TABLE DATA; Schema: public; Owner: rscript
--

INSERT INTO _temp_travel_uploads VALUES (33, 'Rex Tillerson', 'US Government', 'Warsaw', 'Poland', '2088-01-28', '2088-01-29', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (1, 'Rex Tillerson', 'US Government', 'Washington, DC', 'United States', '2088-01-14', '2088-01-14', NULL, NULL, 'Adel al-Jubeir', 'Bilateral Meeting with Saudi Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (2, 'Donald Trump', 'US Government', 'Washington, DC', 'United States', '2088-01-19', '2088-01-19', NULL, NULL, 'Nursultan Nazarbayev', 'Bilateral Meeting with Kazakh President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (3, 'John Sullivan', 'US Government', 'Washington, DC', 'United States', '2088-01-19', '2088-01-19', NULL, NULL, 'Lim Sing-Nam', 'Bilateral Meeting with Korean Vice Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (4, 'Mark Green', 'US Government', 'Washington, DC', 'United States', '2088-01-19', '2088-01-19', NULL, NULL, 'Petri Gormiztka', 'Bilateral Meeting with OECD DAC Chair', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (5, 'Tom Shannon', 'US Government', 'Washington, DC', 'United States', '2088-01-19', '2088-01-19', NULL, NULL, 'David Miliband', 'Bilateral Meeting with International Rescue Committee Chair', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (6, 'Tom Shannon', 'US Government', 'Washington, DC', 'United States', '2088-01-19', '2088-01-19', NULL, NULL, 'Abdulaziz Kamilov', 'Bilateral Meeting with Uzbek Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (7, 'Kristalina Georgieva', 'World Bank', 'Tashkent', 'Uzbekistan', '2088-01-20', '2088-01-20', NULL, NULL, 'Djamshid Kuchkarov', 'Bilateral Meetings with Finance Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (8, 'Kristalina Georgieva', 'World Bank', 'Tashkent', 'Uzbekistan', '2088-01-20', '2088-01-20', NULL, NULL, 'Sukhrob Kholmurodov', 'Bilateral Meetings with Deputy PM', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (9, 'Kristalina Georgieva', 'World Bank', 'Tashkent', 'Uzbekistan', '2088-01-20', '2088-01-20', NULL, NULL, 'Shavkat Mirziyoyev', 'Bilateral Meetings with PM', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (10, 'Mike Pence', 'US Government', 'Cairo', 'Egypt', '2088-01-22', '2088-01-22', NULL, NULL, 'Abdel Fattah el-Sisi', 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (11, 'Mike Pence', 'US Government', 'Amman', 'Jordan', '2088-01-23', '2088-01-23', NULL, NULL, 'Ali bin Al Hussein', 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (12, 'Rex Tillerson', 'US Government', 'London', 'UK', '2088-01-23', '2088-01-24', NULL, NULL, NULL, 'Bilateral Meeting with UK Foreign Secretary Boris Johnson', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (13, 'Mike Pence', 'US Government', 'Jerusalem', 'Israel', '2088-01-24', '2088-01-24', NULL, NULL, NULL, 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (14, 'Rex Tillerson', 'US Government', 'Paris', 'France', '2088-01-24', '2088-01-25', NULL, NULL, NULL, 'Bilateral Meetings with French Government', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (15, 'Donald Trump', 'US Government', 'Davos', 'Switzerland', '2088-01-25', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (16, 'Jim Kim', 'World Bank', 'Davos', 'Switzerland', '2088-01-25', '2088-01-25', NULL, 'World Economic Forum', 'Dara Khosrowshahi', 'Bilateral Meeting with Uber CEO', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (17, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2088-01-25', '2088-01-25', NULL, 'World Economic Forum', 'Bill Morneau', 'Bilateral Meetings with Canadian Finance Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (18, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2088-01-25', '2088-01-25', NULL, 'World Economic Forum', 'George Soros', 'Lunch', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (19, 'Tom Shannon', 'US Government', 'Monrovia', 'Liberia', '2088-01-25', '2088-01-28', NULL, NULL, NULL, 'Bilateral Meetings with Liberian Government', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (20, 'Gary Cohen', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (21, 'H.R. McMaster', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (22, 'Jared Kushner', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (23, 'John Kelly', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (24, 'Kirstjen Nielsen', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (25, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2088-01-26', '2088-01-26', NULL, 'World Economic Forum', 'Mark Suzman', 'Meeting with Bill & Melinda Gates Representative', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (26, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2088-01-26', '2088-01-26', NULL, 'World Economic Forum', 'Queen Mathilde of Belgium', 'Bilateral Meeting with Queen of Belgium', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (27, 'Perry Acosta', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (28, 'Rex Tillerson', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (29, 'Steve Mnuchin', 'US Government', 'Davos', 'Switzerland', '2088-01-26', '2088-01-28', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (30, 'Jim Kim', 'World Bank', 'Davos', 'Switzerland', '2088-01-27', '2088-01-27', NULL, 'World Economic Forum', 'Joachim Wenning', 'Bilateral Meeting with Chairman of Munich Re', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (31, 'Jim Kim', 'World Bank', 'Davos', 'Switzerland', '2088-01-27', '2088-01-27', NULL, 'World Economic Forum', 'Frans van Houten', 'Bilateral Meeting with Royal Philips CEO', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (32, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2088-01-27', '2088-01-27', NULL, 'World Economic Forum', 'Hasssan Ali Khaire', 'Bilateral Meeting with Somali PM', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (34, 'Jim Kim', 'World Bank', 'Dakar', 'Senegal', '2088-02-03', '2088-02-06', NULL, 'One Planet Summit', 'Emmanuel Macron', 'Bilateral Meeting with French President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (35, 'Jim Kim', 'World Bank', 'Dakar', 'Senegal', '2088-02-03', '2088-02-06', NULL, 'One Planet Summit', 'Machy Sall', 'Bilateral Meeting with Senegalese President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (36, 'Jim Kim', 'World Bank', 'Dakar', 'Senegal', '2088-02-03', '2088-02-06', NULL, 'One Planet Summit', 'Roch Marc Christian Kabore', 'Bilateral Meeting with Burkinabe President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (37, 'Rex Tillerson', 'US Government', 'Mexico City', 'Mexico', '2088-02-03', '2088-02-04', 'LAC Travel', NULL, 'Luis Videgaray', 'Bilateral Meeting with Mexico Foreign Secretary', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (38, 'Rex Tillerson', 'US Government', 'Mexico City', 'Mexico', '2088-02-03', '2088-02-04', 'LAC Travel', NULL, 'Enrique Pena Nieto', 'Bilateral Meeting with Mexico President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (39, 'Rex Tillerson', 'US Government', 'Buenos Aires', 'Argentina', '2088-02-05', '2088-02-07', 'LAC Travel', NULL, 'Jorge Faurie', 'Bilateral Meeting Argentine Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (40, 'Rex Tillerson', 'US Government', 'Buenos Aires', 'Argentina', '2088-02-05', '2088-02-07', 'LAC Travel', NULL, 'Mauricio Marci', 'Bilateral Meeting Argentine President ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (41, 'Rex Tillerson', 'US Government', 'Lima', 'Peru', '2088-02-07', '2088-02-07', 'LAC Travel', NULL, 'Cayetana Alijovin', 'Bilateral Meeting with Peruvian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (42, 'Rex Tillerson', 'US Government', 'Lima', 'Peru', '2088-02-08', '2088-02-08', 'LAC Travel', NULL, 'Pedro Pablo Kuczynski', 'Bilateral Meeting with Peruvian President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (43, 'Rex Tillerson', 'US Government', 'Bogota', 'Colombia', '2088-02-08', '2088-02-08', 'LAC Travel', NULL, 'Juan Manuel Santos', 'Bilateral Meeting with Colombian President ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (44, 'Rex Tillerson', 'US Government', 'Bogota', 'Colombia', '2088-02-08', '2088-02-08', 'LAC Travel', NULL, 'Maria Angela Holguin', 'Bilateral Meeting with Colombian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (45, 'Rex Tillerson', 'US Government', 'Kingston', 'Jamaica', '2088-02-09', '2088-02-09', NULL, NULL, 'Andrew Holness', 'Bilateral Meeting with Jamaican Prime Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (46, 'Rex Tillerson', 'US Government', 'Kingston', 'Jamaica', '2088-02-09', '2088-02-09', 'LAC Travel', NULL, 'Kamina Johnson Smith', 'Bilateral Meetings with Jamaican Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (47, 'Donald Trump', 'US Government', 'Washington, DC', 'United States', '2088-02-10', '2088-02-10', NULL, 'National Prayer Breakfast', 'Jimmy Morales', 'National Prayer Breakfast with Guatamalan President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (48, 'Rex Tillerson', 'US Government', 'Washington, DC', 'United States', '2088-02-10', '2088-02-10', NULL, NULL, 'Jimmy Morales', 'Bilateral Meeting with Guatamalan President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (49, 'Rex Tillerson', 'US Government', 'Washington, DC', 'United States', '2088-02-10', '2088-02-10', NULL, NULL, 'Yang Jiechi', 'Bilateral Meetings with Chinese State Councilor', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (50, 'Tom Shannon', 'US Government', 'Vancouver', 'Canada', '2088-02-10', '2088-02-12', 'G7', NULL, NULL, 'G7 Political Directors Meeting', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (51, 'Jim Kim', 'World Bank', 'Dubai', 'UAE', '2088-02-11', '2088-02-12', NULL, NULL, NULL, 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (52, 'Mike Pence', 'US Government', 'Seoul', 'Republic of Korea', '2088-02-11', '2088-02-11', NULL, 'Winter Olympics', NULL, 'Olympics and Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (53, 'Jim Kim', 'World Bank', 'Amman', 'Jordan', '2088-02-13', '2088-02-14', NULL, NULL, NULL, 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (54, 'Rex Tillerson', 'US Government', 'Cairo', 'Egypt', '2088-02-14', '2088-02-14', NULL, NULL, 'Sameh Shoukry', 'Bilateral Meetings with Egyptian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (55, 'Rex Tillerson', 'US Government', 'Cairo', 'Egypt', '2088-02-14', '2088-02-14', 'MENA Travel', NULL, 'Abdel Fattah el-Sisi', 'Bilateral Meetings with Egyptian President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (56, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2088-02-14', '2088-02-14', 'Defeat Isis Ministerial', NULL, 'Sabah al-Khalid-Sabah', 'Working Dinner with Kuwaiti Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (58, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2088-02-15', '2088-02-15', 'Defeat Isis Ministerial', NULL, NULL, 'Participates in Defeat Isis Ministerial', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (59, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2088-02-15', '2088-02-15', NULL, NULL, 'Sheikh Sabah Al-Ahmad Al-Sabah', 'Bilateral Meeting with Kuwaiti Amir ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (60, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2088-02-15', '2088-02-15', NULL, 'Iraqi Reconstruction Conference', 'Haider al-Abadi', 'Bilateral Meeting with Iraqi Prime Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (61, 'Rex Tillerson', 'US Government', 'Amman', 'Jordan', '2088-02-16', '2088-02-16', NULL, NULL, 'Abdullah Il ibn Al-Hussein', 'Working Lunch with King of Jordan', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (62, 'Rex Tillerson', 'US Government', 'Amman', 'Jordan', '2088-02-16', '2088-02-16', NULL, NULL, 'Ayman Al-Safadi', 'Bilateral Meeting with Jordanian Minister of Foreign Affairs', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (63, 'Kristalina Georgieva', 'World Bank', 'Munich', 'Germany', '2088-02-17', '2088-02-19', NULL, 'Munich Security Conference', NULL, 'Munich Security Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (64, 'Mark Green', 'US Government', 'Garmisch', 'Germany', '2088-02-17', '2088-02-18', NULL, 'Africa Strategic Integration Conference', NULL, 'Africa Strategic Integration Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (65, 'Rex Tillerson', 'US Government', 'Ankara', 'Turkey', '2088-02-17', '2088-02-17', NULL, NULL, NULL, 'Bilateral Meetings with Senior Officials', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (66, 'Jim Kim', 'World Bank', 'Munich', 'Germany', '2088-02-18', '2088-02-19', NULL, 'Munich Security Conference', NULL, 'Munich Security Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (67, 'Mark Green', 'US Government', 'Munich', 'Germany', '2088-02-18', '2088-02-19', NULL, 'Munich Security Conference', NULL, 'Munich Security Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (68, 'Rex Tillerson', 'US Government', 'Beirut', 'Lebanon', '2088-02-18', '2088-02-18', NULL, NULL, 'Michel Aoun', 'Bilateral Meeting with Lebanese President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (69, 'Rex Tillerson', 'US Government', 'Beirut', 'Lebanon', '2088-02-18', '2088-02-18', NULL, NULL, 'Saad Hariri', 'Bilateral Meeting with Lebanese Prime Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (71, 'Mark Green', 'US Government', 'London', 'UK', '2088-02-20', '2088-02-21', NULL, NULL, NULL, ' U.S.-UK Strategic Dialogue on Development', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (72, 'Mark Green', 'US Government', 'London', 'UK', '2088-02-20', '2088-02-21', ' U.S.-UK Strategic Dialogue on Development', NULL, ' U.S.-UK Strategic Dialogue on Development', NULL, NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (73, 'John Sullivan', 'US Government', 'Rome', 'Italy', '2088-02-20', '2088-02-22', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (74, 'John Sullivan', 'US Government', 'Kyiv', 'Ukraine', '2088-02-23', '2088-02-23', NULL, 'Petro Poroshenko', NULL, 'Bilateral Meeting with Ukrainian President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (57, 'Jim Kim', 'World Bank', NULL, 'Morocco', '2088-02-15', '2088-02-17', NULL, NULL, NULL, 'Bilateral Meetings', 'ERROR', NULL);
INSERT INTO _temp_travel_uploads VALUES (75, 'John Sullivan', 'US Government', 'Kyiv', 'Ukraine', '2088-02-23', '2088-02-23', NULL, 'Volodymyr Groysman', NULL, 'Bilateral Meeting with Ukrainian Prime Minster', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (76, 'John Sullivan', 'US Government', 'Kyiv', 'Ukraine', '2088-02-23', '2088-02-23', NULL, 'Pavlo Klimkin', NULL, 'Bilateral Meeting with Ukrainian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (77, 'John Sullivan', 'US Government', 'Riga', 'Latvia', '2088-02-24', '2088-02-24', 'Nato Conference', NULL, 'Nato Conference', NULL, NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (78, 'Jim Kim', 'World Bank', 'Washington, DC', 'United States', '2088-02-25', '2088-02-25', NULL, NULL, NULL, 'Council on Foreign Relations ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (79, 'John Sullivan', 'US Government', 'Brussels', 'Belgium', '2088-02-25', '2088-02-25', 'G5 Sahel Donors', NULL, 'G5 Sahel Donors', NULL, NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (80, 'Kristalina Georgieva', 'World Bank', 'Washington, DC', 'United States', '2088-03-09', '2088-03-09', NULL, NULL, 'Madeline Albright', 'Meeting with Madeline Albright', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (81, 'Mike Pence', 'US Government', 'Seoul', 'South Korea', '2088-04-16', '2088-04-19', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (82, 'Mike Pence', 'US Government', 'Tokyo', 'Japan', '2088-04-19', '2088-04-20', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (83, 'Mike Pence', 'US Government', 'Jakarta', 'Indonesia', '2088-04-20', '2088-04-22', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (84, 'Mike Pence', 'US Government', 'Sydney', 'Australia', '2088-04-22', '2088-04-26', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (70, 'Jim Kim', 'World Bank', NULL, 'Spain', '2088-02-20', '2088-02-21', NULL, NULL, NULL, 'Bilateral Meetings', 'ERROR', NULL);


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 237
-- Name: cities_city_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('cities_city_id_seq', 1468, true);


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 233
-- Name: people_person_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('people_person_id_seq', 6305, true);


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 235
-- Name: trips_trip_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('trips_trip_id_seq', 6174, true);


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 246
-- Name: user_action_log_log_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('user_action_log_log_id_seq', 17354, true);


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 244
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('users_user_id_seq', 2, true);


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 240
-- Name: venue_events_venue_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('venue_events_venue_id_seq', 662, true);


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 242
-- Name: venue_types_venue_type_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('venue_types_venue_type_id_seq', 6, true);


--
-- TOC entry 3669 (class 2606 OID 40541)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- TOC entry 3660 (class 2606 OID 40521)
-- Name: people people_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (person_id);


--
-- TOC entry 3671 (class 2606 OID 45228)
-- Name: trip_meetings trip_meetings_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_pkey PRIMARY KEY (meeting_person_id, travelers_trip_id, meeting_venue_id);


--
-- TOC entry 3665 (class 2606 OID 40533)
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (trip_id);


--
-- TOC entry 3680 (class 2606 OID 42559)
-- Name: user_action_log user_action_log_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY user_action_log
    ADD CONSTRAINT user_action_log_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3678 (class 2606 OID 42537)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3674 (class 2606 OID 42377)
-- Name: venue_events venue_id_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events
    ADD CONSTRAINT venue_id_pkey PRIMARY KEY (venue_id);


--
-- TOC entry 3676 (class 2606 OID 42392)
-- Name: venue_types venue_types_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_types
    ADD CONSTRAINT venue_types_pkey PRIMARY KEY (venue_type_id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3683 (class 2606 OID 45395)
-- Name: _temp_travel_uploads _temp_travel_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: rscript
--

ALTER TABLE ONLY _temp_travel_uploads
    ADD CONSTRAINT _temp_travel_uploads_pkey PRIMARY KEY (up_id);


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3667 (class 1259 OID 40856)
-- Name: cities_city_name_country_name_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX cities_city_name_country_name_idx ON cities USING btree (city_name, country_name);


--
-- TOC entry 3661 (class 1259 OID 44817)
-- Name: people_short_name_organization_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX people_short_name_organization_idx ON people USING btree (short_name, organization);


--
-- TOC entry 3662 (class 1259 OID 43338)
-- Name: trips_created_by_user_id_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE INDEX trips_created_by_user_id_idx ON trips USING btree (created_by_user_id);


--
-- TOC entry 3663 (class 1259 OID 40839)
-- Name: trips_person_id_city_id_trip_start_date_trip_end_date_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX trips_person_id_city_id_trip_start_date_trip_end_date_idx ON trips USING btree (person_id, city_id, trip_start_date, trip_end_date);


--
-- TOC entry 3666 (class 1259 OID 43202)
-- Name: trips_trip_uid_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX trips_trip_uid_idx ON trips USING btree (trip_uid);


--
-- TOC entry 3681 (class 1259 OID 42620)
-- Name: user_action_log_user_action_id_table_name_action_time_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE INDEX user_action_log_user_action_id_table_name_action_time_idx ON user_action_log USING btree (user_action_id, table_name, action_time);


--
-- TOC entry 3672 (class 1259 OID 43116)
-- Name: venue_events_venue_name_event_title_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX venue_events_venue_name_event_title_idx ON venue_events USING btree (venue_name);


--
-- TOC entry 3693 (class 2620 OID 43203)
-- Name: trips trip_uid_trigger; Type: TRIGGER; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TRIGGER trip_uid_trigger BEFORE INSERT OR UPDATE ON trips FOR EACH ROW EXECUTE PROCEDURE trip_uid_trigger();


--
-- TOC entry 3687 (class 2606 OID 43127)
-- Name: trip_meetings trip_meetings_meeting_venue_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_meeting_venue_id_fkey FOREIGN KEY (meeting_venue_id) REFERENCES venue_events(venue_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3688 (class 2606 OID 43132)
-- Name: trip_meetings trip_meetings_person_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_person_id_fkey FOREIGN KEY (meeting_person_id) REFERENCES people(person_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3689 (class 2606 OID 43137)
-- Name: trip_meetings trip_meetings_trip_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_trip_id_fkey FOREIGN KEY (travelers_trip_id) REFERENCES trips(trip_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3684 (class 2606 OID 43142)
-- Name: trips trips_city_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(city_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3685 (class 2606 OID 43147)
-- Name: trips trips_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3686 (class 2606 OID 43152)
-- Name: trips trips_person_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_person_id_fkey FOREIGN KEY (person_id) REFERENCES people(person_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3692 (class 2606 OID 43157)
-- Name: user_action_log user_action_log_user_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY user_action_log
    ADD CONSTRAINT user_action_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3690 (class 2606 OID 43162)
-- Name: venue_events venue_events_venue_city_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events
    ADD CONSTRAINT venue_events_venue_city_id_fkey FOREIGN KEY (venue_city_id) REFERENCES cities(city_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3691 (class 2606 OID 43167)
-- Name: venue_events venue_events_venue_type_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events
    ADD CONSTRAINT venue_events_venue_type_fkey FOREIGN KEY (venue_type_id) REFERENCES venue_types(venue_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 4
-- Name: pd_wbgtravel; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA pd_wbgtravel TO "Applications";
GRANT ALL ON SCHEMA pd_wbgtravel TO "ARLTeam";


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 26
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 266
-- Name: grant_default_privileges_for_arl_team_applications(text); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION grant_default_privileges_for_arl_team_applications(sch_name text) TO "ARLTeam";
GRANT ALL ON FUNCTION grant_default_privileges_for_arl_team_applications(sch_name text) TO "Applications";


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 254
-- Name: init_database(); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION init_database() TO "ARLTeam";
GRANT ALL ON FUNCTION init_database() TO "Applications";


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 256
-- Name: remove_abandoned_people_and_places(integer); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION remove_abandoned_people_and_places(v_user_id integer) TO "ARLTeam";
GRANT ALL ON FUNCTION remove_abandoned_people_and_places(v_user_id integer) TO "Applications";


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 252
-- Name: travel_uploads(integer); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION travel_uploads(v_user_id integer) TO "ARLTeam";
GRANT ALL ON FUNCTION travel_uploads(v_user_id integer) TO "Applications";


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 253
-- Name: trip_uid_trigger(); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION trip_uid_trigger() TO "ARLTeam";
GRANT ALL ON FUNCTION trip_uid_trigger() TO "Applications";


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 238
-- Name: cities; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE cities TO "ARLTeam";
GRANT ALL ON TABLE cities TO "Applications";


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 237
-- Name: cities_city_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE cities_city_id_seq TO "Applications";
GRANT ALL ON SEQUENCE cities_city_id_seq TO "ARLTeam";


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 234
-- Name: people; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE people TO "ARLTeam";
GRANT ALL ON TABLE people TO "Applications";


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 233
-- Name: people_person_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE people_person_id_seq TO "Applications";
GRANT ALL ON SEQUENCE people_person_id_seq TO "ARLTeam";


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 239
-- Name: trip_meetings; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE trip_meetings TO "ARLTeam";
GRANT ALL ON TABLE trip_meetings TO "Applications";


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 236
-- Name: trips; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE trips TO "ARLTeam";
GRANT ALL ON TABLE trips TO "Applications";


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 235
-- Name: trips_trip_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE trips_trip_id_seq TO "Applications";
GRANT ALL ON SEQUENCE trips_trip_id_seq TO "ARLTeam";


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 247
-- Name: user_action_log; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE user_action_log TO "ARLTeam";
GRANT ALL ON TABLE user_action_log TO "Applications";


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 246
-- Name: user_action_log_log_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE user_action_log_log_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE user_action_log_log_id_seq TO "Applications";


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 245
-- Name: users; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE users TO "ARLTeam";
GRANT ALL ON TABLE users TO "Applications";


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 244
-- Name: users_user_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE users_user_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE users_user_id_seq TO "Applications";


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 241
-- Name: venue_events; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE venue_events TO "ARLTeam";
GRANT ALL ON TABLE venue_events TO "Applications";


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 240
-- Name: venue_events_venue_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE venue_events_venue_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE venue_events_venue_id_seq TO "Applications";


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 243
-- Name: venue_types; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE venue_types TO "ARLTeam";
GRANT ALL ON TABLE venue_types TO "Applications";


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 242
-- Name: venue_types_venue_type_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE venue_types_venue_type_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE venue_types_venue_type_id_seq TO "Applications";


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 249
-- Name: view_trip_coincidences; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE view_trip_coincidences TO "ARLTeam";
GRANT ALL ON TABLE view_trip_coincidences TO "Applications";


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 248
-- Name: view_trips_and_meetings; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE view_trips_and_meetings TO "ARLTeam";
GRANT ALL ON TABLE view_trips_and_meetings TO "Applications";


SET search_path = pd_portfolio, pg_catalog;

--
-- TOC entry 1769 (class 826 OID 40508)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pd_portfolio; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON SEQUENCES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON SEQUENCES  TO "Applications";


--
-- TOC entry 1770 (class 826 OID 40509)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pd_portfolio; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON FUNCTIONS  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON FUNCTIONS  TO "Applications";


--
-- TOC entry 1768 (class 826 OID 40496)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pd_portfolio; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON TABLES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON TABLES  TO "Applications";


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 1772 (class 826 OID 41372)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pd_wbgtravel; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON SEQUENCES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON SEQUENCES  TO "Applications";


--
-- TOC entry 1773 (class 826 OID 41373)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pd_wbgtravel; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON FUNCTIONS  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON FUNCTIONS  TO "Applications";


--
-- TOC entry 1771 (class 826 OID 40495)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pd_wbgtravel; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON TABLES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON TABLES  TO "Applications";


-- Completed on 2018-02-23 18:00:12

--
-- PostgreSQL database dump complete
--

