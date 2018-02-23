CREATE OR REPLACE FUNCTION pd_wbgtravel.init_database() RETURNS boolean 
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

end$$ LANGUAGE plpgsql;