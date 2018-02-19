--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

-- Started on 2018-02-19 12:44:11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 19 (class 2615 OID 40490)
-- Name: pd_portfolio; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pd_portfolio;


ALTER SCHEMA pd_portfolio OWNER TO postgres;

--
-- TOC entry 5 (class 2615 OID 40491)
-- Name: pd_wbgtravel; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pd_wbgtravel;


ALTER SCHEMA pd_wbgtravel OWNER TO postgres;

--
-- TOC entry 29 (class 2615 OID 40492)
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
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 253 (class 1255 OID 43172)
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
-- TOC entry 242 (class 1255 OID 43173)
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
	where not exists (select * from pd_wbgtravel.cities where cities.city_id = venue_events.venue_city_id) or 
				not exists (select * from pd_wbgtravel.trip_meetings where trip_meetings.meeting_venue_id = venue_events.venue_id) or 
				venue_city_id is null
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
-- TOC entry 247 (class 1255 OID 43318)
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
create temp table if not exists _temp_people(up_id int4, short_name varchar(50), organization varchar(50), is_wbg int2); 
delete from _temp_people;
-- New people from travelers list
insert into _temp_people(up_id,short_name,organization,is_wbg)
select distinct ttu.up_id,initcap(trim(ttu."Person")),trim(ttu."Organization"),0
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
	select distinct ttu.up_id,initcap(trim(unnest(string_to_array(ttu."Meeting",',')))) as "Meeting"
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
select distinct ttu.up_id,ttu."City",ttu."Country"
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
select distinct ttu.up_id,pe.person_id,ci.city_id,ttu."Start",ttu."End",ttu."Trip Group"
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
		substring(array_to_string(array_agg(distinct trip_group),',') from 1 for 75),v_user_id
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
select distinct ttu.up_id,	ttu."Venue",	tt.city_id,	tt.trip_start_date,	tt.trip_end_date,	false
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
                                               meeting_person_id int4, agenda varchar(75), 
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
		ttu."Agenda" as agenda,
		ualv.table_ids[1] as meeting_venue_id
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
								 where trip_meetings.meeting_person_id = people.person_id and trip_meetings.travelers_trip_id = mm.travelers_trip_id);

-- Stag meetings are where an upload entry specified a trip at a venue with on meeting counterpart
-- This condition requires creating a self-meeting so that a venue does not appear as an abandoned venue 
-- (meetings happen at venues -- and without a meeting, no venue to link to a trip)

with stag_meetings as (
	select distinct 
		ttu.up_id,
		ualt.table_ids[1] as travelers_trip_id,
		ttu."Meeting" as meeting_person_name,
		ttu."Agenda" as agenda,
		ualv.table_ids[1] as meeting_venue_id
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
								 where trip_meetings.meeting_person_id = trips.person_id and trip_meetings.travelers_trip_id = sm.travelers_trip_id);


with meetings_insert as
(
insert into pd_wbgtravel.trip_meetings(meeting_person_id,travelers_trip_id,agenda,meeting_venue_id,stag_flag)
select distinct meeting_person_id,travelers_trip_id,substring(agenda from 1 for 50),meeting_venue_id,stag_flag
from _temp_meetings
where not exists(select * from pd_wbgtravel.trip_meetings 
                 where trip_meetings.meeting_person_id = _temp_meetings.meeting_person_id and 
								       trip_meetings.travelers_trip_id = _temp_meetings.travelers_trip_id)
returning meeting_person_id,travelers_trip_id,meeting_venue_id,stag_flag
)
insert into _user_action_log(user_id,user_action_id,table_name,table_ids,note)
select v_user_id,1,'trip_meetings',ARRAY[mi.meeting_person_id,mi.travelers_trip_id],
	'Adding Meeting: ' || p1.short_name || ' [AND] ' || p2.short_name || 
	case when mi.meeting_venue_id is NULL then ' [IN] ' || ci.city_name else ' [AT] ' || ve.venue_name end
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
-- TOC entry 240 (class 1255 OID 43176)
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
-- TOC entry 241 (class 1255 OID 40494)
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
-- TOC entry 224 (class 1259 OID 40536)
-- Name: cities; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE cities (
    city_id integer NOT NULL,
    city_name character varying(50) NOT NULL,
    country_name character varying(50) NOT NULL,
    "country_ISO3" character varying(3),
    latitude numeric(12,9),
    longitude numeric(12,9)
);


ALTER TABLE cities OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 40534)
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
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 223
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE cities_city_id_seq OWNED BY cities.city_id;


--
-- TOC entry 220 (class 1259 OID 40512)
-- Name: people; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE people (
    person_id integer NOT NULL,
    full_name character varying(50),
    short_name character varying(35) NOT NULL,
    title character varying(20),
    organization character varying(20) NOT NULL,
    sub_organization character varying(20),
    image_file character varying(255),
    is_wbg smallint,
    time_created timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE people OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 40646)
-- Name: trip_meetings; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE trip_meetings (
    meeting_person_id integer NOT NULL,
    travelers_trip_id integer NOT NULL,
    description text,
    meeting_venue_id integer,
    agenda character varying(50),
    stag_flag boolean DEFAULT false NOT NULL
);


ALTER TABLE trip_meetings OWNER TO postgres;

--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN trip_meetings.meeting_person_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.meeting_person_id IS 'ID of person I am meeting';


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN trip_meetings.travelers_trip_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.travelers_trip_id IS 'ID of my trip';


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN trip_meetings.stag_flag; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trip_meetings.stag_flag IS 'Flag for when meeting_person_id is the same as traveler on travelers_trip_id -- stag meetings are creatd to enable meetingless trips to record a venue';


--
-- TOC entry 222 (class 1259 OID 40525)
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
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN trips.created_by_user_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trips.created_by_user_id IS 'Who created the trip?  For user access segmentation; eg display trips and all associated table information only to users/groups who created the trip';


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN trips.trip_group_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trips.trip_group_id IS 'For segmenting, eg by departments or filtering at a high level of UI';


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN trips.trip_uid; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN trips.trip_uid IS 'A unique ID to provide/display to users for updating and deleting and prevent accidental changes due to number swaps, typos; eg delete ID=123 vs delete ID=132 accidents';


--
-- TOC entry 236 (class 1259 OID 43187)
-- Name: events; Type: VIEW; Schema: pd_wbgtravel; Owner: postgres
--

CREATE VIEW events AS
 SELECT pe.is_wbg,
    pe.short_name,
    pe.organization,
    pe.title,
    pe.sub_organization,
    ci.country_name,
    ci.city_name,
    ci.longitude,
    ci.latitude,
    tr.trip_group AS trip_reason,
    tr.trip_start_date,
    tr.trip_end_date,
    counterparts.short_name AS meeting_with,
    tm.agenda AS meeting_topic
   FROM ((((trips tr
     JOIN cities ci ON ((ci.city_id = tr.city_id)))
     JOIN people pe ON ((pe.person_id = tr.person_id)))
     LEFT JOIN trip_meetings tm ON ((tm.travelers_trip_id = tr.trip_id)))
     LEFT JOIN people counterparts ON ((counterparts.person_id = tm.meeting_person_id)));


ALTER TABLE events OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 40510)
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
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 219
-- Name: people_person_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE people_person_id_seq OWNED BY people.person_id;


--
-- TOC entry 221 (class 1259 OID 40523)
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
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 221
-- Name: trips_trip_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE trips_trip_id_seq OWNED BY trips.trip_id;


--
-- TOC entry 233 (class 1259 OID 42551)
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
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN user_action_log.user_action_id; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN user_action_log.user_action_id IS '1=insert,0=update,-1=delete';


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN user_action_log.table_ids; Type: COMMENT; Schema: pd_wbgtravel; Owner: postgres
--

COMMENT ON COLUMN user_action_log.table_ids IS 'array of ID(s) for table';


--
-- TOC entry 232 (class 1259 OID 42549)
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
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 232
-- Name: user_action_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE user_action_log_log_id_seq OWNED BY user_action_log.log_id;


--
-- TOC entry 231 (class 1259 OID 42532)
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
-- TOC entry 230 (class 1259 OID 42530)
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
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 230
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;


--
-- TOC entry 227 (class 1259 OID 42370)
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
-- TOC entry 226 (class 1259 OID 42368)
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
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 226
-- Name: venue_events_venue_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE venue_events_venue_id_seq OWNED BY venue_events.venue_id;


--
-- TOC entry 229 (class 1259 OID 42387)
-- Name: venue_types; Type: TABLE; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TABLE venue_types (
    venue_type_id integer NOT NULL,
    type_name character varying(100),
    is_temporal_venue boolean DEFAULT false NOT NULL
);


ALTER TABLE venue_types OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 42385)
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
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 228
-- Name: venue_types_venue_type_id_seq; Type: SEQUENCE OWNED BY; Schema: pd_wbgtravel; Owner: postgres
--

ALTER SEQUENCE venue_types_venue_type_id_seq OWNED BY venue_types.venue_type_id;


--
-- TOC entry 237 (class 1259 OID 43192)
-- Name: view_trip_coincidences; Type: VIEW; Schema: pd_wbgtravel; Owner: postgres
--

CREATE VIEW view_trip_coincidences AS
 WITH trips_cities_people AS (
         SELECT tr.trip_id,
            tr.person_id,
            pe.short_name,
            pe.is_wbg,
            tr.city_id,
            tr.trip_start_date,
            tr.trip_end_date,
            tr.trip_group AS trip_reason,
            ci.latitude,
            ci.longitude,
            ci.city_name,
            ci.country_name
           FROM ((trips tr
             JOIN cities ci ON ((ci.city_id = tr.city_id)))
             JOIN people pe ON ((pe.person_id = tr.person_id)))
        ), trip_coincidences AS (
         SELECT t1.trip_id,
            t1.city_id,
            t1.person_id,
            t1.short_name AS person_name,
            t1.is_wbg,
            t1.city_name,
            t1.country_name,
            t1.trip_start_date,
            t1.trip_end_date,
            t1.trip_reason,
            t2.trip_id AS coincidence_trip_id,
            t2.city_id AS coincidence_city_id,
            t2.person_id AS coincidence_person_id,
            t2.short_name AS coincidence_person_name,
            t2.is_wbg AS coincidence_is_wbg,
            t2.city_name AS coincidence_city_name,
            t2.country_name AS coincidence_country_name,
            t2.trip_reason AS coincidence_trip_reason
           FROM (trips_cities_people t1
             JOIN trips_cities_people t2 ON (((t1.trip_id <> t2.trip_id) AND ((((t2.trip_start_date >= t1.trip_start_date) AND (t2.trip_start_date <= t1.trip_end_date)) OR ((t2.trip_end_date >= t1.trip_start_date) AND (t2.trip_end_date <= t1.trip_end_date))) AND (((((t1.latitude - t2.latitude) ^ (2)::numeric) + ((t1.longitude - t2.longitude) ^ (2)::numeric)) ^ 0.5) < (1)::numeric)))))
        ), trip_coincidence_meetings AS (
         SELECT tc.trip_id,
            tc.city_id,
            tc.person_id,
            tc.person_name,
            tc.is_wbg,
            tc.city_name,
            tc.country_name,
            tc.trip_start_date,
            tc.trip_end_date,
            tc.trip_reason,
            tc.coincidence_trip_id,
            tc.coincidence_city_id,
            tc.coincidence_person_id,
            tc.coincidence_person_name,
            tc.coincidence_is_wbg,
            tc.coincidence_city_name,
            tc.coincidence_country_name,
            tc.coincidence_trip_reason,
            'YES'::character varying(3) AS has_coincidence,
            (
                CASE
                    WHEN (tm.meeting_person_id IS NOT NULL) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS has_meeting,
                CASE
                    WHEN (tm.meeting_person_id IS NOT NULL) THEN tc.coincidence_person_name
                    ELSE NULL::character varying
                END AS meeting_person_name,
            tm.agenda AS topic
           FROM (trip_coincidences tc
             LEFT JOIN trip_meetings tm ON ((((tm.travelers_trip_id = tc.trip_id) AND (tm.meeting_person_id = tc.coincidence_person_id)) OR ((tm.travelers_trip_id = tc.coincidence_trip_id) AND (tm.meeting_person_id = tc.person_id)))))
        ), all_trips_meetings_coincidences AS (
         SELECT tcp.trip_id,
            tcp.city_id,
            tcp.person_id,
            tcp.short_name AS person_name,
            tcp.is_wbg,
            tcp.city_name,
            tcp.country_name,
            tcp.trip_start_date,
            tcp.trip_end_date,
            tcp.trip_reason,
            NULL::integer AS coincidence_trip_id,
            NULL::integer AS coincidence_city_id,
            NULL::integer AS coincidence_person_id,
            NULL::character varying AS coincidence_person_name,
            NULL::smallint AS coincidence_is_wbg,
            NULL::character varying AS coincidence_city_name,
            NULL::character varying AS coincidence_country_name,
            NULL::character varying AS coincidence_trip_reason,
            'NO'::character varying(3) AS has_coincidence,
            (
                CASE
                    WHEN (tm.meeting_person_id IS NOT NULL) THEN 'YES'::text
                    ELSE 'NO'::text
                END)::character varying(3) AS has_meeting,
            pe.short_name AS meeting_person_name,
            tm.agenda AS topic
           FROM ((trips_cities_people tcp
             LEFT JOIN trip_meetings tm ON ((tm.travelers_trip_id = tcp.trip_id)))
             LEFT JOIN people pe ON ((pe.person_id = tm.meeting_person_id)))
          WHERE (NOT (EXISTS ( SELECT tcm.trip_id,
                    tcm.city_id,
                    tcm.person_id,
                    tcm.person_name,
                    tcm.is_wbg,
                    tcm.city_name,
                    tcm.country_name,
                    tcm.trip_start_date,
                    tcm.trip_end_date,
                    tcm.trip_reason,
                    tcm.coincidence_trip_id,
                    tcm.coincidence_city_id,
                    tcm.coincidence_person_id,
                    tcm.coincidence_person_name,
                    tcm.coincidence_is_wbg,
                    tcm.coincidence_city_name,
                    tcm.coincidence_country_name,
                    tcm.coincidence_trip_reason,
                    tcm.has_coincidence,
                    tcm.has_meeting,
                    tcm.meeting_person_name,
                    tcm.topic
                   FROM trip_coincidence_meetings tcm
                  WHERE ((tcm.trip_id = tcp.trip_id) AND (tcm.coincidence_person_id = tm.meeting_person_id)))))
        UNION ALL
         SELECT tcm.trip_id,
            tcm.city_id,
            tcm.person_id,
            tcm.person_name,
            tcm.is_wbg,
            tcm.city_name,
            tcm.country_name,
            tcm.trip_start_date,
            tcm.trip_end_date,
            tcm.trip_reason,
            tcm.coincidence_trip_id,
            tcm.coincidence_city_id,
            tcm.coincidence_person_id,
            tcm.coincidence_person_name,
            tcm.coincidence_is_wbg,
            tcm.coincidence_city_name,
            tcm.coincidence_country_name,
            tcm.coincidence_trip_reason,
            tcm.has_coincidence,
            tcm.has_meeting,
            tcm.meeting_person_name,
            tcm.topic
           FROM trip_coincidence_meetings tcm
        )
 SELECT atcm.trip_id,
    atcm.city_id,
    atcm.person_id,
    atcm.person_name,
    atcm.is_wbg,
    atcm.city_name,
    atcm.country_name,
    atcm.trip_start_date,
    atcm.trip_end_date,
    atcm.trip_reason,
    atcm.coincidence_trip_id,
    atcm.coincidence_city_id,
    atcm.coincidence_person_id,
    atcm.coincidence_person_name,
    atcm.coincidence_is_wbg,
    atcm.coincidence_city_name,
    atcm.coincidence_country_name,
    atcm.coincidence_trip_reason,
    atcm.has_coincidence,
    atcm.has_meeting,
    atcm.meeting_person_name,
    atcm.topic,
    (dense_rank() OVER (ORDER BY atcm.trip_id, atcm.topic) *
        CASE
            WHEN ((atcm.has_meeting)::text = 'YES'::text) THEN 1
            ELSE NULL::integer
        END) AS trip_meeting_group_id
   FROM all_trips_meetings_coincidences atcm;


ALTER TABLE view_trip_coincidences OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 43197)
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
    tr.trip_group AS trip_reason,
    tr.trip_start_date,
    tr.trip_end_date,
    counterparts.short_name AS meeting_with,
    tm.agenda AS meeting_topic
   FROM ((((trips tr
     JOIN cities ci ON ((ci.city_id = tr.city_id)))
     JOIN people pe ON ((pe.person_id = tr.person_id)))
     LEFT JOIN trip_meetings tm ON ((tm.travelers_trip_id = tr.trip_id)))
     LEFT JOIN people counterparts ON ((counterparts.person_id = tm.meeting_person_id)));


ALTER TABLE view_trips_and_meetings OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 235 (class 1259 OID 42888)
-- Name: _temp_travel_uploads; Type: TABLE; Schema: public; Owner: postgres
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
    "Venue" character varying(150),
    "Meeting" character varying(50),
    "Agenda" character varying(150),
    "CMD" character varying(50),
    "ID" character varying(50)
);


ALTER TABLE _temp_travel_uploads OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 42886)
-- Name: _temp_travel_uploads_up_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE _temp_travel_uploads_up_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE _temp_travel_uploads_up_id_seq OWNER TO postgres;

--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 234
-- Name: _temp_travel_uploads_up_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE _temp_travel_uploads_up_id_seq OWNED BY _temp_travel_uploads.up_id;


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3637 (class 2604 OID 40539)
-- Name: cities city_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY cities ALTER COLUMN city_id SET DEFAULT nextval('cities_city_id_seq'::regclass);


--
-- TOC entry 3633 (class 2604 OID 40515)
-- Name: people person_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY people ALTER COLUMN person_id SET DEFAULT nextval('people_person_id_seq'::regclass);


--
-- TOC entry 3635 (class 2604 OID 40528)
-- Name: trips trip_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips ALTER COLUMN trip_id SET DEFAULT nextval('trips_trip_id_seq'::regclass);


--
-- TOC entry 3647 (class 2604 OID 42554)
-- Name: user_action_log log_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY user_action_log ALTER COLUMN log_id SET DEFAULT nextval('user_action_log_log_id_seq'::regclass);


--
-- TOC entry 3645 (class 2604 OID 42535)
-- Name: users user_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);


--
-- TOC entry 3639 (class 2604 OID 42373)
-- Name: venue_events venue_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events ALTER COLUMN venue_id SET DEFAULT nextval('venue_events_venue_id_seq'::regclass);


--
-- TOC entry 3643 (class 2604 OID 42390)
-- Name: venue_types venue_type_id; Type: DEFAULT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_types ALTER COLUMN venue_type_id SET DEFAULT nextval('venue_types_venue_type_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 3649 (class 2604 OID 42891)
-- Name: _temp_travel_uploads up_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY _temp_travel_uploads ALTER COLUMN up_id SET DEFAULT nextval('_temp_travel_uploads_up_id_seq'::regclass);


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3813 (class 0 OID 40536)
-- Dependencies: 224
-- Data for Name: cities; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO cities VALUES (1382, 'Bogota', 'Colombia', NULL, NULL, NULL);
INSERT INTO cities VALUES (1383, 'London', 'UK', NULL, NULL, NULL);
INSERT INTO cities VALUES (1384, 'Amman', 'Jordan', NULL, NULL, NULL);
INSERT INTO cities VALUES (1385, 'Garmisch', 'Germany', NULL, NULL, NULL);
INSERT INTO cities VALUES (1386, 'Dakar', 'Senegal', NULL, NULL, NULL);
INSERT INTO cities VALUES (1387, 'Washington, DC', 'United States', NULL, NULL, NULL);
INSERT INTO cities VALUES (1388, 'Tokyo', 'Japan', NULL, NULL, NULL);
INSERT INTO cities VALUES (1389, 'Munich', 'Germany', NULL, NULL, NULL);
INSERT INTO cities VALUES (1390, 'Tashkent', 'Uzbekistan', NULL, NULL, NULL);
INSERT INTO cities VALUES (1391, 'Jakarta', 'Indonesia', NULL, NULL, NULL);
INSERT INTO cities VALUES (1392, 'Jerusalem', 'Israel', NULL, NULL, NULL);
INSERT INTO cities VALUES (1393, 'Seoul', 'Republic of Korea', NULL, NULL, NULL);
INSERT INTO cities VALUES (1394, 'Cairo', 'Egypt', NULL, NULL, NULL);
INSERT INTO cities VALUES (1395, 'Vancouver', 'Canada', NULL, NULL, NULL);
INSERT INTO cities VALUES (1396, 'Sydney', 'Australia', NULL, NULL, NULL);
INSERT INTO cities VALUES (1397, 'Mexico City', 'Mexico', NULL, NULL, NULL);
INSERT INTO cities VALUES (1398, 'Kingston', 'Jamaica', NULL, NULL, NULL);
INSERT INTO cities VALUES (1399, 'Warsaw', 'Poland', NULL, NULL, NULL);
INSERT INTO cities VALUES (1400, 'Seoul', 'South Korea', NULL, NULL, NULL);
INSERT INTO cities VALUES (1401, 'Monrovia', 'Liberia', NULL, NULL, NULL);
INSERT INTO cities VALUES (1402, 'Beirut', 'Lebanon', NULL, NULL, NULL);
INSERT INTO cities VALUES (1403, 'Dubai', 'UAE', NULL, NULL, NULL);
INSERT INTO cities VALUES (1404, 'Paris', 'France', NULL, NULL, NULL);
INSERT INTO cities VALUES (1405, 'Ankara', 'Turkey', NULL, NULL, NULL);
INSERT INTO cities VALUES (1406, 'Buenos Aires', 'Argentina', NULL, NULL, NULL);
INSERT INTO cities VALUES (1407, 'Davos', 'Switzerland', NULL, NULL, NULL);
INSERT INTO cities VALUES (1408, 'Kuwait City', 'Kuwait', NULL, NULL, NULL);
INSERT INTO cities VALUES (1409, 'Lima', 'Peru', NULL, NULL, NULL);


--
-- TOC entry 3809 (class 0 OID 40512)
-- Dependencies: 220
-- Data for Name: people; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO people VALUES (6160, NULL, 'Abdel Fattah El-Sisi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6161, NULL, 'Abdulaziz Kamilov', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6162, NULL, 'Abdullah Il Ibn Al-Hussein', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6163, NULL, 'Adel Al-Jubeir', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6164, NULL, 'Ali Bin Al Hussein', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6165, NULL, 'Andrew Holness', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6166, NULL, 'Ayman Al-Safadi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6167, NULL, 'Bill Morneau', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6168, NULL, 'Cayetana Alijovin', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6169, NULL, 'Dara Khosrowshahi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6170, NULL, 'David Miliband', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6171, NULL, 'Djamshid Kuchkarov', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6172, NULL, 'Donald Trump', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6173, NULL, 'Emmanuel Macron', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6174, NULL, 'Enrique Pena Nieto', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6175, NULL, 'Frans Van Houten', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6176, NULL, 'Gary Cohen', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6177, NULL, 'George Soros', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6178, NULL, 'Haider Al-Abadi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6179, NULL, 'Hasssan Ali Khaire', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6180, NULL, 'H.R. Mcmaster', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6181, NULL, 'Jared Kushner', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6183, NULL, 'Jimmy Morales', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6184, NULL, 'Joachim Wenning', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6185, NULL, 'John Kelly', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6186, NULL, 'John Sullivan', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6187, NULL, 'Jorge Faurie', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6188, NULL, 'Juan Manuel Santos', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6189, NULL, 'Kamina Johnson Smith', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6190, NULL, 'Kirstjen Nielsen', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6192, NULL, 'Lim Sing-Nam', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6193, NULL, 'Luis Videgaray', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6194, NULL, 'Machy Sall', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6195, NULL, 'Madeline Albright', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6196, NULL, 'Maria Angela Holguin', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6197, NULL, 'Mark Green', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6198, NULL, 'Mark Suzman', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6199, NULL, 'Mauricio Marci', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6200, NULL, 'Michel Aoun', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6201, NULL, 'Mike Pence', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6191, NULL, 'Kristalina Georgieva', NULL, 'World Bank', NULL, NULL, 1, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6182, NULL, 'Jim Kim', NULL, 'World Bank', NULL, NULL, 1, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6202, NULL, 'Nursultan Nazarbayev', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6203, NULL, 'Pedro Pablo Kuczynski', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6204, NULL, 'Perry Acosta', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6205, NULL, 'Petri Gormiztka', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6206, NULL, 'Queen Mathilde Of Belgium', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6207, NULL, 'Rex Tillerson', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6208, NULL, 'Roch Marc Christian Kabore', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6209, NULL, 'Saad Hariri', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6210, NULL, 'Sabah Al-Khalid-Sabah', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6211, NULL, 'Sameh Shoukry', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6212, NULL, 'Shavkat Mirziyoyev', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6213, NULL, 'Sheikh Sabah Al-Ahmad Al-Sabah', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6214, NULL, 'Steve Mnuchin', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6215, NULL, 'Sukhrob Kholmurodov', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6216, NULL, 'Tom Shannon', NULL, 'US Government', NULL, NULL, 0, '2018-02-19 07:14:15.503244');
INSERT INTO people VALUES (6217, NULL, 'Yang Jiechi', NULL, 'Unknown', NULL, NULL, 0, '2018-02-19 07:14:15.503244');


--
-- TOC entry 3814 (class 0 OID 40646)
-- Dependencies: 225
-- Data for Name: trip_meetings; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO trip_meetings VALUES (6194, 6017, NULL, 628, 'Bilateral Meeting with Senegalese President', false);
INSERT INTO trip_meetings VALUES (6172, 6009, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6197, 6029, NULL, 624, 'Africa Strategic Integration Conference', true);
INSERT INTO trip_meetings VALUES (6180, 5995, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6193, 5975, NULL, NULL, 'Bilateral Meeting with Mexico Foreign Secretary', false);
INSERT INTO trip_meetings VALUES (6183, 5983, NULL, NULL, 'Bilateral Meeting with Guatamalan President', false);
INSERT INTO trip_meetings VALUES (6214, 5981, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6165, 6003, NULL, NULL, 'Bilateral Meeting with Jamaican Prime Minister', false);
INSERT INTO trip_meetings VALUES (6209, 6022, NULL, NULL, 'Bilateral Meeting with Lebanese Prime Minister', false);
INSERT INTO trip_meetings VALUES (6160, 5996, NULL, NULL, 'Bilateral Meetings with Egyptian President', false);
INSERT INTO trip_meetings VALUES (6182, 6026, NULL, 626, 'Munich Security Conference', true);
INSERT INTO trip_meetings VALUES (6206, 6006, NULL, 630, 'Bilateral Meeting with Queen of Belgium', false);
INSERT INTO trip_meetings VALUES (6200, 6022, NULL, NULL, 'Bilateral Meeting with Lebanese President', false);
INSERT INTO trip_meetings VALUES (6208, 6017, NULL, 628, 'Bilateral Meeting with Burkinabe President', false);
INSERT INTO trip_meetings VALUES (6183, 5998, NULL, 627, 'National Prayer Breakfast with Guatamalan Presiden', false);
INSERT INTO trip_meetings VALUES (6215, 5994, NULL, NULL, 'Bilateral Meetings with Deputy PM', false);
INSERT INTO trip_meetings VALUES (6176, 5976, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6210, 5990, NULL, NULL, 'Working Dinner with Kuwaiti Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6169, 5989, NULL, 630, 'Bilateral Meeting with Uber CEO', false);
INSERT INTO trip_meetings VALUES (6187, 5974, NULL, NULL, 'Bilateral Meeting Argentine Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6181, 6014, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6170, 5982, NULL, NULL, 'Bilateral Meeting with International Rescue Commit', false);
INSERT INTO trip_meetings VALUES (6173, 6017, NULL, 628, 'Bilateral Meeting with French President', false);
INSERT INTO trip_meetings VALUES (6175, 5986, NULL, 630, 'Bilateral Meeting with Royal Philips CEO', false);
INSERT INTO trip_meetings VALUES (6204, 6012, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6207, 6027, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6196, 6016, NULL, NULL, 'Bilateral Meeting with Colombian Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6205, 6013, NULL, NULL, 'Bilateral Meeting with OECD DAC Chair', false);
INSERT INTO trip_meetings VALUES (6207, 6024, NULL, 625, 'Participates in Iraqi Reconstruction Conference', true);
INSERT INTO trip_meetings VALUES (6184, 5986, NULL, 630, 'Bilateral Meeting with Chairman of Munich Re', false);
INSERT INTO trip_meetings VALUES (6195, 5978, NULL, NULL, 'Meeting with Madeline Albright', false);
INSERT INTO trip_meetings VALUES (6203, 6019, NULL, NULL, 'Bilateral Meeting with Peruvian President', false);
INSERT INTO trip_meetings VALUES (6197, 5977, NULL, 626, 'Munich Security Conference', true);
INSERT INTO trip_meetings VALUES (6212, 5994, NULL, NULL, 'Bilateral Meetings with PM', false);
INSERT INTO trip_meetings VALUES (6164, 5985, NULL, NULL, 'Bilateral Meetings', false);
INSERT INTO trip_meetings VALUES (6174, 5975, NULL, NULL, 'Bilateral Meeting with Mexico President', false);
INSERT INTO trip_meetings VALUES (6166, 6018, NULL, NULL, 'Bilateral Meeting with Jordanian Minister of Forei', false);
INSERT INTO trip_meetings VALUES (6185, 5991, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6201, 5992, NULL, 629, 'Olympics and Bilateral Meetings', true);
INSERT INTO trip_meetings VALUES (6198, 6006, NULL, 630, 'Meeting with Bill & Melinda Gates Representative', false);
INSERT INTO trip_meetings VALUES (6161, 5982, NULL, NULL, 'Bilateral Meeting with Uzbek Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6188, 6016, NULL, NULL, 'Bilateral Meeting with Colombian President ', false);
INSERT INTO trip_meetings VALUES (6189, 6003, NULL, NULL, 'Bilateral Meetings with Jamaican Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6163, 6000, NULL, NULL, 'Bilateral Meeting with Saudi Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6190, 6002, NULL, 630, 'World Economic Forum', true);
INSERT INTO trip_meetings VALUES (6213, 6024, NULL, NULL, 'Bilateral Meeting with Kuwaiti Amir ', false);
INSERT INTO trip_meetings VALUES (6217, 5983, NULL, NULL, 'Bilateral Meetings with Chinese State Councilor', false);
INSERT INTO trip_meetings VALUES (6167, 6005, NULL, 630, 'Bilateral Meetings with Canadian Finance Minister', false);
INSERT INTO trip_meetings VALUES (6168, 6025, NULL, NULL, 'Bilateral Meeting with Peruvian Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6179, 6020, NULL, 630, 'Bilateral Meeting with Somali PM', false);
INSERT INTO trip_meetings VALUES (6162, 6018, NULL, NULL, 'Working Lunch with King of Jordan', false);
INSERT INTO trip_meetings VALUES (6160, 6008, NULL, NULL, 'Bilateral Meetings', false);
INSERT INTO trip_meetings VALUES (6171, 5994, NULL, NULL, 'Bilateral Meetings with Finance Minister', false);
INSERT INTO trip_meetings VALUES (6177, 6005, NULL, 630, 'Lunch', false);
INSERT INTO trip_meetings VALUES (6199, 5974, NULL, NULL, 'Bilateral Meeting Argentine President ', false);
INSERT INTO trip_meetings VALUES (6192, 5988, NULL, NULL, 'Bilateral Meeting with Korean Vice Foreign Ministe', false);
INSERT INTO trip_meetings VALUES (6202, 5997, NULL, NULL, 'Bilateral Meeting with Kazakh President', false);
INSERT INTO trip_meetings VALUES (6191, 5999, NULL, 626, 'Munich Security Conference', true);
INSERT INTO trip_meetings VALUES (6211, 5996, NULL, NULL, 'Bilateral Meetings with Egyptian Foreign Minister', false);
INSERT INTO trip_meetings VALUES (6178, 6024, NULL, 625, 'Bilateral Meeting with Iraqi Prime Minister', false);


--
-- TOC entry 3811 (class 0 OID 40525)
-- Dependencies: 222
-- Data for Name: trips; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO trips VALUES (5973, 6207, 1383, '2018-01-21', '2018-01-22', '2018-02-19 07:14:15.503244', 1, NULL, '', '6de59d960d3bb8a6346c058930f3cd28');
INSERT INTO trips VALUES (5974, 6207, 1406, '2018-02-03', '2018-02-05', '2018-02-19 07:14:15.503244', 1, NULL, 'LAC Travel', '7e1cacfb27da22fb243ff2debf4443a0');
INSERT INTO trips VALUES (5975, 6207, 1397, '2018-02-01', '2018-02-02', '2018-02-19 07:14:15.503244', 1, NULL, 'LAC Travel', '32cfdce9631d8c7906e8e9d6e68b514b');
INSERT INTO trips VALUES (5976, 6176, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', 'e10534dd65cf727692c0f9c44ba613f8');
INSERT INTO trips VALUES (5977, 6197, 1389, '2018-02-16', '2018-02-17', '2018-02-19 07:14:15.503244', 1, NULL, '', '7eb532aef980c36170c0b4426f082b87');
INSERT INTO trips VALUES (5978, 6191, 1387, '2018-03-08', '2018-03-08', '2018-02-19 07:14:15.503244', 1, NULL, '', 'e5ae7b1f180083e8a49e55e4d488bbec');
INSERT INTO trips VALUES (5979, 6201, 1391, '2018-04-19', '2018-04-21', '2018-02-19 07:14:15.503244', 1, NULL, '', '6d7d394c9d0c886e9247542e06ebb705');
INSERT INTO trips VALUES (5980, 6216, 1395, '2018-02-08', '2018-02-10', '2018-02-19 07:14:15.503244', 1, NULL, 'G7', '63dfdeb1ff9ff09ecc3f05d2d7221ffa');
INSERT INTO trips VALUES (5981, 6214, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', 'abb9d15b3293a96a3ea116867b2b16d5');
INSERT INTO trips VALUES (5982, 6216, 1387, '2018-01-17', '2018-01-17', '2018-02-19 07:14:15.503244', 1, NULL, '', 'c23497bd62a8f8a0981fdc9cbd3c30d9');
INSERT INTO trips VALUES (5983, 6207, 1387, '2018-02-08', '2018-02-08', '2018-02-19 07:14:15.503244', 1, NULL, '', '0cb82dbdcda47e2ad7b7aaf69573906e');
INSERT INTO trips VALUES (5984, 6207, 1399, '2018-01-26', '2018-01-27', '2018-02-19 07:14:15.503244', 1, NULL, '', '7f2cba89a7116c7c6b0a769572d5fad9');
INSERT INTO trips VALUES (5985, 6201, 1384, '2018-01-21', '2018-01-21', '2018-02-19 07:14:15.503244', 1, NULL, '', 'fccc64972a9468a11f125cadb090e89e');
INSERT INTO trips VALUES (5986, 6182, 1407, '2018-01-25', '2018-01-25', '2018-02-19 07:14:15.503244', 1, NULL, '', 'fd45c64e026040dbcb83395829d2aea5');
INSERT INTO trips VALUES (5987, 6182, 1384, '2018-02-11', '2018-02-12', '2018-02-19 07:14:15.503244', 1, NULL, '', '7f9d88fe83d3e7fce3136e510b0a9a38');
INSERT INTO trips VALUES (5988, 6186, 1387, '2018-01-17', '2018-01-17', '2018-02-19 07:14:15.503244', 1, NULL, '', 'dfbfa7ddcfffeb581f50edcf9a0204bb');
INSERT INTO trips VALUES (5989, 6182, 1407, '2018-01-23', '2018-01-23', '2018-02-19 07:14:15.503244', 1, NULL, '', '1ae6464c6b5d51b363d7d96f97132c75');
INSERT INTO trips VALUES (5990, 6207, 1408, '2018-02-12', '2018-02-12', '2018-02-19 07:14:15.503244', 1, NULL, 'Defeat Isis Ministerial', '3cba81c5c6cac4ce77157631fc2dc277');
INSERT INTO trips VALUES (5991, 6185, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', 'c0356641f421b381e475776b602a5da8');
INSERT INTO trips VALUES (5992, 6201, 1393, '2018-02-09', '2018-02-09', '2018-02-19 07:14:15.503244', 1, NULL, '', '675f9820626f5bc0afb47b57890b466e');
INSERT INTO trips VALUES (5993, 6201, 1388, '2018-04-18', '2018-04-19', '2018-02-19 07:14:15.503244', 1, NULL, '', '32e0bd1497aa43e02a42f47d9d6515ad');
INSERT INTO trips VALUES (5994, 6191, 1390, '2018-01-18', '2018-01-18', '2018-02-19 07:14:15.503244', 1, NULL, '', 'edb446b67d69adbfe9a21068982000c2');
INSERT INTO trips VALUES (5995, 6180, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', 'fcd4c889d516a54d5371f00e3fdd70dc');
INSERT INTO trips VALUES (5996, 6207, 1394, '2018-02-12', '2018-02-12', '2018-02-19 07:14:15.503244', 1, NULL, 'MENA Travel', '8d3215ae97598264ad6529613774a038');
INSERT INTO trips VALUES (5997, 6172, 1387, '2018-01-17', '2018-01-17', '2018-02-19 07:14:15.503244', 1, NULL, '', '077fd57e57aab32087b0466fe6ebcca8');
INSERT INTO trips VALUES (5998, 6172, 1387, '2018-02-08', '2018-02-08', '2018-02-19 07:14:15.503244', 1, NULL, '', 'b98a3773ecf715751d3cf0fb6dcba424');
INSERT INTO trips VALUES (5999, 6191, 1389, '2018-02-15', '2018-02-17', '2018-02-19 07:14:15.503244', 1, NULL, '', 'cca289d2a4acd14c1cd9a84ffb41dd29');
INSERT INTO trips VALUES (6000, 6207, 1387, '2018-01-12', '2018-01-12', '2018-02-19 07:14:15.503244', 1, NULL, '', 'a8c6dd982010fce8701ce1aef8a2d40a');
INSERT INTO trips VALUES (6001, 6182, 1403, '2018-02-09', '2018-02-10', '2018-02-19 07:14:15.503244', 1, NULL, '', 'ea1818cbe59c23b20f1a10a8aa083a82');
INSERT INTO trips VALUES (6002, 6190, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', '4b01078e96f65f2ad6573ce6fecc944d');
INSERT INTO trips VALUES (6003, 6207, 1398, '2018-02-07', '2018-02-07', '2018-02-19 07:14:15.503244', 1, NULL, 'LAC Travel', '7acba01022004f2ce03bf56ca56ec6f4');
INSERT INTO trips VALUES (6004, 6207, 1405, '2018-02-15', '2018-02-15', '2018-02-19 07:14:15.503244', 1, NULL, '', '636efd4f9aeb5781e9ea815cdd633e52');
INSERT INTO trips VALUES (6005, 6191, 1407, '2018-01-23', '2018-01-23', '2018-02-19 07:14:15.503244', 1, NULL, '', '50c1f44e426560f3f2cdcb3e19e39903');
INSERT INTO trips VALUES (6006, 6191, 1407, '2018-01-24', '2018-01-24', '2018-02-19 07:14:15.503244', 1, NULL, '', '91ba4a4478a66bee9812b0804b6f9d1b');
INSERT INTO trips VALUES (6007, 6201, 1396, '2018-04-21', '2018-04-25', '2018-02-19 07:14:15.503244', 1, NULL, '', 'bacadc62d6e67d7897cef027fa2d416c');
INSERT INTO trips VALUES (6008, 6201, 1394, '2018-01-20', '2018-01-20', '2018-02-19 07:14:15.503244', 1, NULL, '', '569ff987c643b4bedf504efda8f786c2');
INSERT INTO trips VALUES (6009, 6172, 1407, '2018-01-23', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', '37d7902cb2d3de686e497e31624d82e0');
INSERT INTO trips VALUES (6010, 6216, 1401, '2018-01-23', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', 'c4c455df3c54f292ae22f6791fd2553e');
INSERT INTO trips VALUES (6011, 6207, 1404, '2018-01-22', '2018-01-23', '2018-02-19 07:14:15.503244', 1, NULL, '', 'e3b80d30a727c738f3cff0941f6bc55a');
INSERT INTO trips VALUES (6012, 6204, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', '4c4c937b67cc8d785cea1e42ccea185c');
INSERT INTO trips VALUES (6013, 6197, 1387, '2018-01-17', '2018-01-17', '2018-02-19 07:14:15.503244', 1, NULL, '', '8fd7f981e10b41330b618129afcaab2d');
INSERT INTO trips VALUES (6014, 6181, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', '3f68928ec5b6fae14708854b8fd0cf08');
INSERT INTO trips VALUES (6015, 6201, 1400, '2018-04-15', '2018-04-18', '2018-02-19 07:14:15.503244', 1, NULL, '', '5a378f8490c8d6af8647a753812f6e31');
INSERT INTO trips VALUES (6016, 6207, 1382, '2018-02-06', '2018-02-06', '2018-02-19 07:14:15.503244', 1, NULL, 'LAC Travel', '593906af0d138e69f49d251d3e7cbed0');
INSERT INTO trips VALUES (6017, 6182, 1386, '2018-02-01', '2018-02-04', '2018-02-19 07:14:15.503244', 1, NULL, '', 'fef6f971605336724b5e6c0c12dc2534');
INSERT INTO trips VALUES (6018, 6207, 1384, '2018-02-14', '2018-02-14', '2018-02-19 07:14:15.503244', 1, NULL, '', '8d2a5f7d4afa5d0530789d3066945330');
INSERT INTO trips VALUES (6019, 6207, 1409, '2018-02-06', '2018-02-06', '2018-02-19 07:14:15.503244', 1, NULL, 'LAC Travel', '5218f316b3f85b751c613a06aa18010d');
INSERT INTO trips VALUES (6020, 6191, 1407, '2018-01-25', '2018-01-25', '2018-02-19 07:14:15.503244', 1, NULL, '', 'ac2a728f9f17b5d860b6dabd80a5162f');
INSERT INTO trips VALUES (6021, 6182, 1387, '2018-02-23', '2018-02-23', '2018-02-19 07:14:15.503244', 1, NULL, '', 'b075703bbe07a50ddcccfaac424bb6d9');
INSERT INTO trips VALUES (6022, 6207, 1402, '2018-02-16', '2018-02-16', '2018-02-19 07:14:15.503244', 1, NULL, '', 'da54dd5a0398011cdfa50d559c2c0ef8');
INSERT INTO trips VALUES (6023, 6197, 1383, '2018-02-18', '2018-02-19', '2018-02-19 07:14:15.503244', 1, NULL, '', '3ba9af181751761d3b387f74ded2d783');
INSERT INTO trips VALUES (6024, 6207, 1408, '2018-02-13', '2018-02-13', '2018-02-19 07:14:15.503244', 1, NULL, 'Defeat Isis Ministerial', '3bd8fdb090f1f5eb66a00c84dbc5ad51');
INSERT INTO trips VALUES (6025, 6207, 1409, '2018-02-05', '2018-02-05', '2018-02-19 07:14:15.503244', 1, NULL, 'LAC Travel', '5eed6c6e569d984796ebca9c1169451e');
INSERT INTO trips VALUES (6026, 6182, 1389, '2018-02-16', '2018-02-17', '2018-02-19 07:14:15.503244', 1, NULL, '', 'a70dab11c90d06b809d0be230731762a');
INSERT INTO trips VALUES (6027, 6207, 1407, '2018-01-24', '2018-01-26', '2018-02-19 07:14:15.503244', 1, NULL, '', '30f48cd3c7e73511070b95ee0a884c23');
INSERT INTO trips VALUES (6028, 6201, 1392, '2018-01-22', '2018-01-22', '2018-02-19 07:14:15.503244', 1, NULL, '', '2c60e40b399dc55d8b755ec6b5d09f8a');
INSERT INTO trips VALUES (6029, 6197, 1385, '2018-02-15', '2018-02-16', '2018-02-19 07:14:15.503244', 1, NULL, '', '7f3ad9c65beb20ccbd34a05041b4420b');


--
-- TOC entry 3822 (class 0 OID 42551)
-- Dependencies: 233
-- Data for Name: user_action_log; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO user_action_log VALUES (16698, 1, 1, 'people', '{6183}', '2018-02-19 07:14:15.503244', 'Adding Person: Jimmy Morales');
INSERT INTO user_action_log VALUES (16699, 1, 1, 'people', '{6184}', '2018-02-19 07:14:15.503244', 'Adding Person: Joachim Wenning');
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


--
-- TOC entry 3820 (class 0 OID 42532)
-- Dependencies: 231
-- Data for Name: users; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO users VALUES (2, 'CEOSI', 'CEOSI2018', true, NULL, 'Team account for unit CEOSI, Strategic Initiatives');
INSERT INTO users VALUES (1, 'MEL', 'FIGSSAMEL', true, NULL, 'Team account for MEL team, developer''s account');
INSERT INTO users VALUES (0, 'SYSTEM', '', false, NULL, 'System account: updates automated data, where deemed relevant');


--
-- TOC entry 3816 (class 0 OID 42370)
-- Dependencies: 227
-- Data for Name: venue_events; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO venue_events VALUES (624, 'Africa Strategic Integration Conference - Feb 2018', NULL, 5, 1385, 'Africa Strategic Integration Conference', '2018-02-15', '2018-02-16', false);
INSERT INTO venue_events VALUES (625, 'Iraqi Reconstruction Conference - Feb 2018', NULL, 5, 1408, 'Iraqi Reconstruction Conference', '2018-02-13', '2018-02-13', false);
INSERT INTO venue_events VALUES (626, 'Munich Security Conference - Feb 2018', NULL, 5, 1389, 'Munich Security Conference', '2018-02-15', '2018-02-17', false);
INSERT INTO venue_events VALUES (627, 'National Prayer Breakfast - Feb 2018', NULL, 5, 1387, 'National Prayer Breakfast', '2018-02-08', '2018-02-08', false);
INSERT INTO venue_events VALUES (628, 'One Planet Summit - Feb 2018', NULL, 6, 1386, 'One Planet Summit', '2018-02-01', '2018-02-04', true);
INSERT INTO venue_events VALUES (629, 'Winter Olympics - Feb 2018', NULL, 6, 1393, 'Winter Olympics', '2018-02-09', '2018-02-09', true);
INSERT INTO venue_events VALUES (630, 'World Economic Forum - Jan 2018', NULL, 6, 1407, 'World Economic Forum', '2018-01-23', '2018-01-26', true);


--
-- TOC entry 3818 (class 0 OID 42387)
-- Dependencies: 229
-- Data for Name: venue_types; Type: TABLE DATA; Schema: pd_wbgtravel; Owner: postgres
--

INSERT INTO venue_types VALUES (1, 'Organization', false);
INSERT INTO venue_types VALUES (2, 'Client', false);
INSERT INTO venue_types VALUES (3, 'Donor', false);
INSERT INTO venue_types VALUES (4, 'Government', false);
INSERT INTO venue_types VALUES (5, 'Small Event', true);
INSERT INTO venue_types VALUES (6, 'Major Event', true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3824 (class 0 OID 42888)
-- Dependencies: 235
-- Data for Name: _temp_travel_uploads; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO _temp_travel_uploads VALUES (126, 'Rex Tillerson', 'US Government', 'Warsaw', 'Poland', '2018-01-26', '2018-01-27', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (79, 'Donald Trump', 'US Government', 'Davos', 'Switzerland', '2018-01-23', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (80, 'Donald Trump', 'US Government', 'Washington, DC', 'United States', '2018-01-17', '2018-01-17', NULL, NULL, 'Nursultan Nazarbayev', 'Bilateral Meeting with Kazakh President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (81, 'Donald Trump', 'US Government', 'Washington, DC', 'United States', '2018-02-08', '2018-02-08', NULL, 'National Prayer Breakfast', 'Jimmy Morales', 'National Prayer Breakfast with Guatamalan President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (82, 'Gary Cohen', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (83, 'H.R. McMaster', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (84, 'Jared Kushner', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (85, 'Jim Kim', 'World Bank', 'Munich', 'Germany', '2018-02-16', '2018-02-17', NULL, 'Munich Security Conference', NULL, 'Munich Security Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (86, 'Jim Kim', 'World Bank', 'Dubai', 'UAE', '2018-02-09', '2018-02-10', NULL, NULL, NULL, 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (87, 'Jim Kim', 'World Bank', 'Amman', 'Jordan', '2018-02-11', '2018-02-12', NULL, NULL, NULL, 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (90, 'Jim Kim', 'World Bank', 'Washington, DC', 'United States', '2018-02-23', '2018-02-23', NULL, NULL, NULL, 'Council on Foreign Relations ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (91, 'Jim Kim', 'World Bank', 'Davos', 'Switzerland', '2018-01-23', '2018-01-23', NULL, 'World Economic Forum', 'Dara Khosrowshahi', 'Bilateral Meeting with Uber CEO', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (92, 'Jim Kim', 'World Bank', 'Davos', 'Switzerland', '2018-01-25', '2018-01-25', NULL, 'World Economic Forum', 'Joachim Wenning', 'Bilateral Meeting with Chairman of Munich Re', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (93, 'Jim Kim', 'World Bank', 'Davos', 'Switzerland', '2018-01-25', '2018-01-25', NULL, 'World Economic Forum', 'Frans van Houten', 'Bilateral Meeting with Royal Philips CEO', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (94, 'Jim Kim', 'World Bank', 'Dakar', 'Senegal', '2018-02-01', '2018-02-04', NULL, 'One Planet Summit', 'Emmanuel Macron', 'Bilateral Meeting with French President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (95, 'Jim Kim', 'World Bank', 'Dakar', 'Senegal', '2018-02-01', '2018-02-04', NULL, 'One Planet Summit', 'Machy Sall', 'Bilateral Meeting with Senegalese President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (96, 'Jim Kim', 'World Bank', 'Dakar', 'Senegal', '2018-02-01', '2018-02-04', NULL, 'One Planet Summit', 'Roch Marc Christian Kabore', 'Bilateral Meeting with Burkinabe President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (97, 'John Kelly', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (98, 'John Sullivan', 'US Government', 'Washington, DC', 'United States', '2018-01-17', '2018-01-17', NULL, NULL, 'Lim Sing-Nam', 'Bilateral Meeting with Korean Vice Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (99, 'Kirstjen Nielsen', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (100, 'Kristalina Georgieva', 'World Bank', 'Washington, DC', 'United States', '2018-03-08', '2018-03-08', NULL, NULL, 'Madeline Albright', 'Meeting with Madeline Albright', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (101, 'Kristalina Georgieva', 'World Bank', 'Tashkent', 'Uzbekistan', '2018-01-18', '2018-01-18', NULL, NULL, 'Djamshid Kuchkarov', 'Bilateral Meetings with Finance Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (102, 'Kristalina Georgieva', 'World Bank', 'Tashkent', 'Uzbekistan', '2018-01-18', '2018-01-18', NULL, NULL, 'Sukhrob Kholmurodov', 'Bilateral Meetings with Deputy PM', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (103, 'Kristalina Georgieva', 'World Bank', 'Tashkent', 'Uzbekistan', '2018-01-18', '2018-01-18', NULL, NULL, 'Shavkat Mirziyoyev', 'Bilateral Meetings with PM', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (104, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2018-01-23', '2018-01-23', NULL, 'World Economic Forum', 'Bill Morneau', 'Bilateral Meetings with Canadian Finance Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (105, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2018-01-23', '2018-01-23', NULL, 'World Economic Forum', 'George Soros', 'Lunch', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (107, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2018-01-24', '2018-01-24', NULL, 'World Economic Forum', 'Queen Mathilde of Belgium', 'Bilateral Meeting with Queen of Belgium', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (106, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2018-01-24', '2018-01-24', NULL, 'World Economic Forum', 'Mark Suzman', 'Meeting with Bill & Melinda Gates Representative', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (108, 'Kristalina Georgieva', 'World Bank', 'Davos', 'Switzerland', '2018-01-25', '2018-01-25', NULL, 'World Economic Forum', 'Hasssan Ali Khaire', 'Bilateral Meeting with Somali PM', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (109, 'Kristalina Georgieva', 'World Bank', 'Munich', 'Germany', '2018-02-15', '2018-02-17', NULL, 'Munich Security Conference', NULL, 'Munich Security Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (110, 'Mark Green', 'US Government', 'Washington, DC', 'United States', '2018-01-17', '2018-01-17', NULL, NULL, 'Petri Gormiztka', 'Bilateral Meeting with OECD DAC Chair', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (111, 'Mark Green', 'US Government', 'Munich', 'Germany', '2018-02-16', '2018-02-17', NULL, 'Munich Security Conference', NULL, 'Munich Security Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (112, 'Mark Green', 'US Government', 'Garmisch', 'Germany', '2018-02-15', '2018-02-16', NULL, 'Africa Strategic Integration Conference', NULL, 'Africa Strategic Integration Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (113, 'Mark Green', 'US Government', 'London', 'UK', '2018-02-18', '2018-02-19', NULL, NULL, NULL, ' U.S.-UK Strategic Dialogue on Development', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (114, 'Mike Pence', 'US Government', 'Cairo', 'Egypt', '2018-01-20', '2018-01-20', NULL, NULL, 'Abdel Fattah el-Sisi', 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (115, 'Mike Pence', 'US Government', 'Amman', 'Jordan', '2018-01-21', '2018-01-21', NULL, NULL, 'Ali bin Al Hussein', 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (116, 'Mike Pence', 'US Government', 'Jerusalem', 'Israel', '2018-01-22', '2018-01-22', NULL, NULL, NULL, 'Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (117, 'Mike Pence', 'US Government', 'Seoul', 'Republic of Korea', '2018-02-09', '2018-02-09', NULL, 'Winter Olympics', NULL, 'Olympics and Bilateral Meetings', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (118, 'Mike Pence', 'US Government', 'Seoul', 'South Korea', '2018-04-15', '2018-04-18', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (119, 'Mike Pence', 'US Government', 'Tokyo', 'Japan', '2018-04-18', '2018-04-19', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (120, 'Mike Pence', 'US Government', 'Jakarta', 'Indonesia', '2018-04-19', '2018-04-21', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (121, 'Mike Pence', 'US Government', 'Sydney', 'Australia', '2018-04-21', '2018-04-25', NULL, NULL, NULL, 'Bilateral Meetings (TBD)', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (122, 'Perry Acosta', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (123, 'Rex Tillerson', 'US Government', 'London', 'UK', '2018-01-21', '2018-01-22', NULL, NULL, NULL, 'Bilateral Meeting with UK Foreign Secretary Boris Johnson', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (124, 'Rex Tillerson', 'US Government', 'Paris', 'France', '2018-01-22', '2018-01-23', NULL, NULL, NULL, 'Bilateral Meetings with French Government', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (125, 'Rex Tillerson', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (127, 'Rex Tillerson', 'US Government', 'Washington, DC', 'United States', '2018-01-12', '2018-01-12', NULL, NULL, 'Adel al-Jubeir', 'Bilateral Meeting with Saudi Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (128, 'Rex Tillerson', 'US Government', 'Mexico City', 'Mexico', '2018-02-01', '2018-02-02', 'LAC Travel', NULL, 'Luis Videgaray', 'Bilateral Meeting with Mexico Foreign Secretary', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (129, 'Rex Tillerson', 'US Government', 'Mexico City', 'Mexico', '2018-02-01', '2018-02-02', 'LAC Travel', NULL, 'Enrique Pena Nieto', 'Bilateral Meeting with Mexico President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (130, 'Rex Tillerson', 'US Government', 'Buenos Aires', 'Argentina', '2018-02-03', '2018-02-05', 'LAC Travel', NULL, 'Jorge Faurie', 'Bilateral Meeting Argentine Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (131, 'Rex Tillerson', 'US Government', 'Buenos Aires', 'Argentina', '2018-02-03', '2018-02-05', 'LAC Travel', NULL, 'Mauricio Marci', 'Bilateral Meeting Argentine President ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (132, 'Rex Tillerson', 'US Government', 'Lima', 'Peru', '2018-02-05', '2018-02-05', 'LAC Travel', NULL, 'Cayetana Alijovin', 'Bilateral Meeting with Peruvian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (133, 'Rex Tillerson', 'US Government', 'Lima', 'Peru', '2018-02-06', '2018-02-06', 'LAC Travel', NULL, 'Pedro Pablo Kuczynski', 'Bilateral Meeting with Peruvian President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (134, 'Rex Tillerson', 'US Government', 'Bogota', 'Colombia', '2018-02-06', '2018-02-06', 'LAC Travel', NULL, 'Juan Manuel Santos', 'Bilateral Meeting with Colombian President ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (135, 'Rex Tillerson', 'US Government', 'Bogota', 'Colombia', '2018-02-06', '2018-02-06', 'LAC Travel', NULL, 'Maria Angela Holguin', 'Bilateral Meeting with Colombian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (136, 'Rex Tillerson', 'US Government', 'Kingston', 'Jamaica', '2018-02-07', '2018-02-07', NULL, NULL, 'Andrew Holness', 'Bilateral Meeting with Jamaican Prime Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (137, 'Rex Tillerson', 'US Government', 'Kingston', 'Jamaica', '2018-02-07', '2018-02-07', 'LAC Travel', NULL, 'Kamina Johnson Smith', 'Bilateral Meetings with Jamaican Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (138, 'Rex Tillerson', 'US Government', 'Washington, DC', 'United States', '2018-02-08', '2018-02-08', NULL, NULL, 'Jimmy Morales', 'Bilateral Meeting with Guatamalan President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (139, 'Rex Tillerson', 'US Government', 'Washington, DC', 'United States', '2018-02-08', '2018-02-08', NULL, NULL, 'Yang Jiechi', 'Bilateral Meetings with Chinese State Councilor', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (140, 'Rex Tillerson', 'US Government', 'Cairo', 'Egypt', '2018-02-12', '2018-02-12', NULL, NULL, 'Sameh Shoukry', 'Bilateral Meetings with Egyptian Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (141, 'Rex Tillerson', 'US Government', 'Cairo', 'Egypt', '2018-02-12', '2018-02-12', 'MENA Travel', NULL, 'Abdel Fattah el-Sisi', 'Bilateral Meetings with Egyptian President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (142, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2018-02-12', '2018-02-12', 'Defeat Isis Ministerial', NULL, 'Sabah al-Khalid-Sabah', 'Working Dinner with Kuwaiti Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (143, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2018-02-13', '2018-02-13', 'Defeat Isis Ministerial', NULL, NULL, 'Participates in Defeat Isis Ministerial', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (144, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2018-02-13', '2018-02-13', NULL, NULL, 'Sheikh Sabah Al-Ahmad Al-Sabah', 'Bilateral Meeting with Kuwaiti Amir ', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (145, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2018-02-13', '2018-02-13', NULL, 'Iraqi Reconstruction Conference', 'Haider al-Abadi', 'Bilateral Meeting with Iraqi Prime Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (146, 'Rex Tillerson', 'US Government', 'Kuwait City', 'Kuwait', '2018-02-13', '2018-02-13', NULL, 'Iraqi Reconstruction Conference', NULL, 'Participates in Iraqi Reconstruction Conference', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (147, 'Rex Tillerson', 'US Government', 'Amman', 'Jordan', '2018-02-14', '2018-02-14', NULL, NULL, 'Abdullah Il ibn Al-Hussein', 'Working Lunch with King of Jordan', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (148, 'Rex Tillerson', 'US Government', 'Amman', 'Jordan', '2018-02-14', '2018-02-14', NULL, NULL, 'Ayman Al-Safadi', 'Bilateral Meeting with Jordanian Minister of Foreign Affairs', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (149, 'Rex Tillerson', 'US Government', 'Ankara', 'Turkey', '2018-02-15', '2018-02-15', NULL, NULL, NULL, 'Bilateral Meetings with Senior Officials', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (150, 'Rex Tillerson', 'US Government', 'Beirut', 'Lebanon', '2018-02-16', '2018-02-16', NULL, NULL, 'Michel Aoun', 'Bilateral Meeting with Lebanese President', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (151, 'Rex Tillerson', 'US Government', 'Beirut', 'Lebanon', '2018-02-16', '2018-02-16', NULL, NULL, 'Saad Hariri', 'Bilateral Meeting with Lebanese Prime Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (152, 'Steve Mnuchin', 'US Government', 'Davos', 'Switzerland', '2018-01-24', '2018-01-26', NULL, 'World Economic Forum', NULL, 'World Economic Forum', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (153, 'Tom Shannon', 'US Government', 'Washington, DC', 'United States', '2018-01-17', '2018-01-17', NULL, NULL, 'David Miliband', 'Bilateral Meeting with International Rescue Committee Chair', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (154, 'Tom Shannon', 'US Government', 'Washington, DC', 'United States', '2018-01-17', '2018-01-17', NULL, NULL, 'Abdulaziz Kamilov', 'Bilateral Meeting with Uzbek Foreign Minister', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (155, 'Tom Shannon', 'US Government', 'Monrovia', 'Liberia', '2018-01-23', '2018-01-26', NULL, NULL, NULL, 'Bilateral Meetings with Liberian Government', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (156, 'Tom Shannon', 'US Government', 'Vancouver', 'Canada', '2018-02-08', '2018-02-10', 'G7', NULL, NULL, 'G7 Political Directors Meeting', NULL, NULL);
INSERT INTO _temp_travel_uploads VALUES (88, 'Jim Kim', 'World Bank', NULL, 'Morocco', '2018-02-13', '2018-02-15', NULL, NULL, NULL, 'Bilateral Meetings', 'ERROR', NULL);
INSERT INTO _temp_travel_uploads VALUES (89, 'Jim Kim', 'World Bank', NULL, 'Spain', '2018-02-18', '2018-02-19', NULL, NULL, NULL, 'Bilateral Meetings', 'ERROR', NULL);


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 223
-- Name: cities_city_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('cities_city_id_seq', 1409, true);


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 219
-- Name: people_person_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('people_person_id_seq', 6217, true);


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 221
-- Name: trips_trip_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('trips_trip_id_seq', 6029, true);


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 232
-- Name: user_action_log_log_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('user_action_log_log_id_seq', 16886, true);


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 230
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('users_user_id_seq', 2, true);


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 226
-- Name: venue_events_venue_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('venue_events_venue_id_seq', 630, true);


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 228
-- Name: venue_types_venue_type_id_seq; Type: SEQUENCE SET; Schema: pd_wbgtravel; Owner: postgres
--

SELECT pg_catalog.setval('venue_types_venue_type_id_seq', 6, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 234
-- Name: _temp_travel_uploads_up_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('_temp_travel_uploads_up_id_seq', 156, true);


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3659 (class 2606 OID 40541)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- TOC entry 3651 (class 2606 OID 40521)
-- Name: people people_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (person_id);


--
-- TOC entry 3661 (class 2606 OID 40684)
-- Name: trip_meetings trip_meetings_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_pkey PRIMARY KEY (meeting_person_id, travelers_trip_id);


--
-- TOC entry 3655 (class 2606 OID 40533)
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (trip_id);


--
-- TOC entry 3670 (class 2606 OID 42559)
-- Name: user_action_log user_action_log_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY user_action_log
    ADD CONSTRAINT user_action_log_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3668 (class 2606 OID 42537)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3664 (class 2606 OID 42377)
-- Name: venue_events venue_id_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events
    ADD CONSTRAINT venue_id_pkey PRIMARY KEY (venue_id);


--
-- TOC entry 3666 (class 2606 OID 42392)
-- Name: venue_types venue_types_pkey; Type: CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_types
    ADD CONSTRAINT venue_types_pkey PRIMARY KEY (venue_type_id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3673 (class 2606 OID 43205)
-- Name: _temp_travel_uploads _temp_travel_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY _temp_travel_uploads
    ADD CONSTRAINT _temp_travel_uploads_pkey PRIMARY KEY (up_id);


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 3657 (class 1259 OID 40856)
-- Name: cities_city_name_country_name_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX cities_city_name_country_name_idx ON cities USING btree (city_name, country_name);


--
-- TOC entry 3652 (class 1259 OID 40782)
-- Name: people_short_name_organization_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX people_short_name_organization_idx ON people USING btree (short_name, organization);


--
-- TOC entry 3653 (class 1259 OID 40839)
-- Name: trips_person_id_city_id_trip_start_date_trip_end_date_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX trips_person_id_city_id_trip_start_date_trip_end_date_idx ON trips USING btree (person_id, city_id, trip_start_date, trip_end_date);


--
-- TOC entry 3656 (class 1259 OID 43202)
-- Name: trips_trip_uid_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX trips_trip_uid_idx ON trips USING btree (trip_uid);


--
-- TOC entry 3671 (class 1259 OID 42620)
-- Name: user_action_log_user_action_id_table_name_action_time_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE INDEX user_action_log_user_action_id_table_name_action_time_idx ON user_action_log USING btree (user_action_id, table_name, action_time);


--
-- TOC entry 3662 (class 1259 OID 43116)
-- Name: venue_events_venue_name_event_title_idx; Type: INDEX; Schema: pd_wbgtravel; Owner: postgres
--

CREATE UNIQUE INDEX venue_events_venue_name_event_title_idx ON venue_events USING btree (venue_name);


--
-- TOC entry 3683 (class 2620 OID 43203)
-- Name: trips trip_uid_trigger; Type: TRIGGER; Schema: pd_wbgtravel; Owner: postgres
--

CREATE TRIGGER trip_uid_trigger BEFORE INSERT OR UPDATE ON trips FOR EACH ROW EXECUTE PROCEDURE trip_uid_trigger();


--
-- TOC entry 3677 (class 2606 OID 43127)
-- Name: trip_meetings trip_meetings_meeting_venue_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_meeting_venue_id_fkey FOREIGN KEY (meeting_venue_id) REFERENCES venue_events(venue_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3678 (class 2606 OID 43132)
-- Name: trip_meetings trip_meetings_person_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_person_id_fkey FOREIGN KEY (meeting_person_id) REFERENCES people(person_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3679 (class 2606 OID 43137)
-- Name: trip_meetings trip_meetings_trip_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trip_meetings
    ADD CONSTRAINT trip_meetings_trip_id_fkey FOREIGN KEY (travelers_trip_id) REFERENCES trips(trip_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3674 (class 2606 OID 43142)
-- Name: trips trips_city_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(city_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3675 (class 2606 OID 43147)
-- Name: trips trips_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3676 (class 2606 OID 43152)
-- Name: trips trips_person_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_person_id_fkey FOREIGN KEY (person_id) REFERENCES people(person_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3682 (class 2606 OID 43157)
-- Name: user_action_log user_action_log_user_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY user_action_log
    ADD CONSTRAINT user_action_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3680 (class 2606 OID 43162)
-- Name: venue_events venue_events_venue_city_id_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events
    ADD CONSTRAINT venue_events_venue_city_id_fkey FOREIGN KEY (venue_city_id) REFERENCES cities(city_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3681 (class 2606 OID 43167)
-- Name: venue_events venue_events_venue_type_fkey; Type: FK CONSTRAINT; Schema: pd_wbgtravel; Owner: postgres
--

ALTER TABLE ONLY venue_events
    ADD CONSTRAINT venue_events_venue_type_fkey FOREIGN KEY (venue_type_id) REFERENCES venue_types(venue_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 5
-- Name: pd_wbgtravel; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA pd_wbgtravel TO "Applications";
GRANT ALL ON SCHEMA pd_wbgtravel TO "ARLTeam";


--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 253
-- Name: grant_default_privileges_for_arl_team_applications(text); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION grant_default_privileges_for_arl_team_applications(sch_name text) TO "ARLTeam";
GRANT ALL ON FUNCTION grant_default_privileges_for_arl_team_applications(sch_name text) TO "Applications";


--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 242
-- Name: remove_abandoned_people_and_places(integer); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION remove_abandoned_people_and_places(v_user_id integer) TO "ARLTeam";
GRANT ALL ON FUNCTION remove_abandoned_people_and_places(v_user_id integer) TO "Applications";


--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 247
-- Name: travel_uploads(integer); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION travel_uploads(v_user_id integer) TO "ARLTeam";
GRANT ALL ON FUNCTION travel_uploads(v_user_id integer) TO "Applications";


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 240
-- Name: trip_uid_trigger(); Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON FUNCTION trip_uid_trigger() TO "ARLTeam";
GRANT ALL ON FUNCTION trip_uid_trigger() TO "Applications";


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 224
-- Name: cities; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE cities TO "ARLTeam";
GRANT ALL ON TABLE cities TO "Applications";


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 223
-- Name: cities_city_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE cities_city_id_seq TO "Applications";
GRANT ALL ON SEQUENCE cities_city_id_seq TO "ARLTeam";


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 220
-- Name: people; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE people TO "ARLTeam";
GRANT ALL ON TABLE people TO "Applications";


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 225
-- Name: trip_meetings; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE trip_meetings TO "ARLTeam";
GRANT ALL ON TABLE trip_meetings TO "Applications";


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 222
-- Name: trips; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE trips TO "ARLTeam";
GRANT ALL ON TABLE trips TO "Applications";


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 236
-- Name: events; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE events TO "ARLTeam";
GRANT ALL ON TABLE events TO "Applications";


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 219
-- Name: people_person_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE people_person_id_seq TO "Applications";
GRANT ALL ON SEQUENCE people_person_id_seq TO "ARLTeam";


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 221
-- Name: trips_trip_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE trips_trip_id_seq TO "Applications";
GRANT ALL ON SEQUENCE trips_trip_id_seq TO "ARLTeam";


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 233
-- Name: user_action_log; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE user_action_log TO "ARLTeam";
GRANT ALL ON TABLE user_action_log TO "Applications";


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 232
-- Name: user_action_log_log_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE user_action_log_log_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE user_action_log_log_id_seq TO "Applications";


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 231
-- Name: users; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE users TO "ARLTeam";
GRANT ALL ON TABLE users TO "Applications";


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 230
-- Name: users_user_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE users_user_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE users_user_id_seq TO "Applications";


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 227
-- Name: venue_events; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE venue_events TO "ARLTeam";
GRANT ALL ON TABLE venue_events TO "Applications";


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 226
-- Name: venue_events_venue_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE venue_events_venue_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE venue_events_venue_id_seq TO "Applications";


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 229
-- Name: venue_types; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE venue_types TO "ARLTeam";
GRANT ALL ON TABLE venue_types TO "Applications";


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 228
-- Name: venue_types_venue_type_id_seq; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON SEQUENCE venue_types_venue_type_id_seq TO "ARLTeam";
GRANT ALL ON SEQUENCE venue_types_venue_type_id_seq TO "Applications";


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 237
-- Name: view_trip_coincidences; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE view_trip_coincidences TO "ARLTeam";
GRANT ALL ON TABLE view_trip_coincidences TO "Applications";


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 238
-- Name: view_trips_and_meetings; Type: ACL; Schema: pd_wbgtravel; Owner: postgres
--

GRANT ALL ON TABLE view_trips_and_meetings TO "ARLTeam";
GRANT ALL ON TABLE view_trips_and_meetings TO "Applications";


SET search_path = pd_portfolio, pg_catalog;

--
-- TOC entry 1760 (class 826 OID 40508)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pd_portfolio; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON SEQUENCES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON SEQUENCES  TO "Applications";


--
-- TOC entry 1761 (class 826 OID 40509)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pd_portfolio; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON FUNCTIONS  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON FUNCTIONS  TO "Applications";


--
-- TOC entry 1759 (class 826 OID 40496)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pd_portfolio; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON TABLES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_portfolio GRANT ALL ON TABLES  TO "Applications";


SET search_path = pd_wbgtravel, pg_catalog;

--
-- TOC entry 1763 (class 826 OID 41372)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pd_wbgtravel; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON SEQUENCES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON SEQUENCES  TO "Applications";


--
-- TOC entry 1764 (class 826 OID 41373)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pd_wbgtravel; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON FUNCTIONS  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON FUNCTIONS  TO "Applications";


--
-- TOC entry 1762 (class 826 OID 40495)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pd_wbgtravel; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON TABLES  TO "ARLTeam";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pd_wbgtravel GRANT ALL ON TABLES  TO "Applications";


-- Completed on 2018-02-19 12:45:25

--
-- PostgreSQL database dump complete
--

