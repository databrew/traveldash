--

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

select distinct short_name,organization,is_wbg

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

select distinct person_id,city_id,trip_start_date,trip_end_date,substring(array_to_string(array_agg(distinct trip_reason),',') from 1 for 75)

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

--