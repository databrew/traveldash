create or replace view pd_wbgtravel.view_trip_coincidences as 
with trip_cities_people as
(
	select 
	tr.trip_id,
	tr.person_id,
	pe.short_name,
	pe.is_wbg,
	tr.city_id,
	tr.trip_start_date,
	tr.trip_end_date,
	tr.trip_reason,
	ci.latitude,
	ci.longitude,
	ci.city_name,
	ci.country_name
	from pd_wbgtravel.trips tr
	inner join pd_wbgtravel.cities ci on ci.city_id = tr.city_id
	inner join pd_wbgtravel.people pe on pe.person_id = tr.person_id
),

trip_coincidences as
(
	select 
	t1.trip_id,
	t1.city_id,
	t1.person_id,
	t1.short_name as person_name,
	t1.is_wbg,
	t1.city_name,
	t1.country_name,
	t1.trip_start_date,
	t1.trip_end_date,
	t1.trip_reason,
	t2.trip_id as coincidence_trip_id,
	t2.city_id as coincidence_city_id,
	t2.person_id as coincidence_person_id,
	t2.short_name as coincidence_person_name,
	t2.is_wbg as coincidence_is_wbg,
	t2.city_name as coincidence_city_name,
	t2.country_name as coincidence_country_name,
	t2.trip_reason as coincidence_trip_reason
	from trip_cities_people t1 
	-- Join logic:
	-- For someone else's trip (ie, don't match my own trip)
	-- The dates of their trip overlap with the dates of my trip
	-- We're within 100km of each other
	-- See https://en.wikipedia.org/wiki/Decimal_degrees; note degrees are radial so this is approximate.  But objective is approximate.
	-- Value differene <1 is approximately less than 100km. 
	inner join trip_cities_people t2 on t1.trip_id <> t2.trip_id and
															 (
																 (t2.trip_start_date between t1.trip_start_date and t1.trip_end_date or
																	t2.trip_end_date between t1.trip_start_date and t1.trip_end_date)
																	and
																	((t1.latitude - t2.latitude)^2 + (t1.longitude - t2.longitude)^2)^.5 < 1 --
																)
)
select * 
from trip_coincidences tc
order by city_name,person_name
--To do: add-in meetings that are established.  Note that user data entry may include overlapping trips, but not overlapping meetings.
--Eg, Jim Kim travels to Davos to meet with Donald Trip is entered
--Elsewhere, Donald Trump travels to Davos is entered.
--Need to recognize that the meeting is reciprocal between Donald Trump and Jim Kim even if it's only explicitly entered in one trip
--Also need to pull in meetings that have no conicidences.
--Eg, Jim Kim travels to Davos to meet with Prince Ali.  But nobody entered Prince Ali's trip, so no coincidence is found.  A regular trip and meeting
--need to be pulled in.