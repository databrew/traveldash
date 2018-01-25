create or replace view pd_wbgtravel.view_trips_and_meetings as
 SELECT pe.is_wbg,
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
     LEFT JOIN pd_wbgtravel.people counterparts ON ((counterparts.person_id = tm.meeting_person_id)))