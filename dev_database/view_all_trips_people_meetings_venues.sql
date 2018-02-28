create or replace view view_all_trips_people_meetings_venues as
select 
users.user_id,
users.user_role,
pe_t.person_id,
pe_t.short_name,
pe_t.organization,
ci.city_id,
ci.city_name,
ci.country_name,
tr.trip_start_date,
tr.trip_end_date,
tr.trip_group,
tr.trip_uid,
array_to_string(array_agg(distinct pe_m.person_id order by pe_m.person_id),',') as meeting_person_ids,
array_to_string(array_agg(distinct pe_m.short_name order by pe_m.short_name),',') as meeting_person_short_names,
pe_m.organization as meeting_person_organization,
tm.agenda,
tm.stag_flag,
ve.venue_id,
ve.venue_name,
vt.type_name,
ve.display_flag,
ve.event_title,
ve.event_start_date,
ve.event_end_date

from pd_wbgtravel.users
inner join pd_wbgtravel.trips tr on tr.created_by_user_id = users.user_id
inner join pd_wbgtravel.people pe_t on pe_t.person_id = tr.person_id
inner join pd_wbgtravel.cities ci on ci.city_id = tr.city_id
left join pd_wbgtravel.trip_meetings tm on tm.travelers_trip_id = tr.trip_id
left join pd_wbgtravel.people pe_m on pe_m.person_id = tm.meeting_person_id
left join pd_wbgtravel.venue_events ve on ve.venue_id = tm.meeting_venue_id
left join pd_wbgtravel.venue_types vt on vt.venue_type_id = ve.venue_type_id
where users.can_login=true 
group by
users.user_id,
users.user_role,
pe_t.person_id,
pe_t.short_name,
pe_t.organization,
ci.city_id,
ci.city_name,
ci.country_name,
tr.trip_start_date,
tr.trip_end_date,
tr.trip_group,
tr.trip_uid,
pe_m.organization,
tm.agenda,
tm.stag_flag,
ve.venue_id,
ve.venue_short_name,
vt.type_name,
ve.display_flag,
ve.event_title,
ve.event_start_date,
ve.event_end_date

