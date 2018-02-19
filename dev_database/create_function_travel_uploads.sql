drop function if exists pd_wbgtravel.travel_uploads(int);
CREATE OR REPLACE FUNCTION pd_wbgtravel.travel_uploads(v_user_id int) RETURNS table(
change int2,
up_id int4,
"Person" varchar(50),
"Organization" varchar(50),
"City" varchar(50),
"Country" varchar(50),
"Start" date,
"End" date,
"Trip Group" varchar(25),
"Venue" varchar(100),
"Meeting" varchar(50),
"Agenda" varchar(100),
"STATUS" varchar(200)
)
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
$$ LANGUAGE plpgsql;
