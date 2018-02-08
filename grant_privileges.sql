CREATE USER worlbank WITH PASSWORD 'jimkim';
ALTER ROLE "worldbank" WITH LOGIN;

REVOKE ALL ON DATABASE dev FROM public;  -- shut out the general pd_wbgtravel
CREATE GROUP mygrp;
GRANT CONNECT ON DATABASE dev TO mygrp;  -- since we revoked from pd_wbgtravel

GRANT USAGE ON SCHEMA pd_wbgtravel TO mygrp;
/*To assign a user all privileges to all tables:
*/
GRANT ALL ON ALL TABLES IN SCHEMA pd_wbgtravel TO mygrp;
GRANT ALL ON ALL SEQUENCES IN SCHEMA pd_wbgtravel TO mygrp; -- don't forget those
/*To set default privileges for future objects, run for every role that creates objects in this schema:
*/
ALTER DEFAULT PRIVILEGES FOR ROLE worldbank IN SCHEMA pd_wbgtravel
GRANT ALL ON TABLES TO mygrp;

ALTER DEFAULT PRIVILEGES FOR ROLE worldbank IN SCHEMA pd_wbgtravel
GRANT ALL ON SEQUENCES TO mygrp;

/*-- more roles?
Now, grant the group to the user:*/

GRANT mygrp TO worldbank;