--##--
--TESTING SCRIPT
--##--

--delete from pd_wbgtravel.trips cascade;
--delete from pd_wbgtravel.user_action_log;

--delete from pd_wbgtravel.people cascade;
--delete from pd_wbgtravel.venue_events cascade;
--insert into pd_wbgtravel.people(short_name,organization) values('Jane Doe','Nowhere');
--update public."_temp_travel_uploads" set "CMD"=NULL,"ID"=NULL;
/*
with jk as 
(
	select short_name,city_name,country_name,trip_start_date,trip_end_date,trip_uid
	from pd_wbgtravel.trips
	inner join pd_wbgtravel.people on people.person_id = trips.person_id
	inner join pd_wbgtravel.cities on cities.city_id = trips.city_id
	where people.short_name = 'Jim Kim'
)
update public._temp_travel_uploads
  set "CMD" = 'UPDATE', "ID" = jk.trip_uid, "Person" = 'JYK'
	from jk
		where 
		jk.short_name = _temp_travel_uploads."Person" and
		jk.city_name = _temp_travel_uploads."City" and
		jk.country_name = _temp_travel_uploads."Country" and
		jk.trip_start_date = _temp_travel_uploads."Start" and
		jk.trip_end_date = _temp_travel_uploads."End";

--delete from public.__user_action_log;
--delete from public.__temp_meetings
*/
--update public._temp_travel_uploads set "CMD" = NULL, "ID" = NULL;

select 
msg."Person",
msg."Organization",
msg."City",
msg."Country",
msg."Start",
msg."End",
msg."Trip Group",
msg."Venue",
msg."Meeting",
msg."Agenda",
msg."STATUS" 
from pd_wbgtravel.travel_uploads(1) msg;