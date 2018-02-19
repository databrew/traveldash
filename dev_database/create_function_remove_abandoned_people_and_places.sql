CREATE OR REPLACE FUNCTION pd_wbgtravel.remove_abandoned_people_and_places(v_user_id int) RETURNS table(abandoned_log_id int)
LANGUAGE plpgsql AS
$$BEGIN

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

