Begin;

---- Schema: dev ----


---- File: 001-project_purpose.sql ----

SET search_path TO dev, cvl, public;

ALTER TABLE dev.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN dev.project.purpose
  IS 'The purpose of the project';

---- Schema: alcc ----


---- File: 001-project_purpose.sql ----

SET search_path TO alcc, cvl, public;

ALTER TABLE alcc.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN alcc.project.purpose
  IS 'The purpose of the project';

---- Schema: walcc ----


---- File: 001-project_purpose.sql ----

SET search_path TO walcc, cvl, public;

ALTER TABLE walcc.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN walcc.project.purpose
  IS 'The purpose of the project';

---- Schema: absi ----


---- File: 001-project_purpose.sql ----

SET search_path TO absi, cvl, public;

ALTER TABLE absi.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN absi.project.purpose
  IS 'The purpose of the project';

---- Schema: nwb ----


---- File: 001-project_purpose.sql ----

SET search_path TO nwb, cvl, public;

ALTER TABLE nwb.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN nwb.project.purpose
  IS 'The purpose of the project';

---- Schema: sciapp ----


---- File: 001-project_purpose.sql ----

SET search_path TO sciapp, cvl, public;

ALTER TABLE sciapp.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN sciapp.project.purpose
  IS 'The purpose of the project';

---- Schema: acp ----


---- File: 001-project_purpose.sql ----

SET search_path TO acp, cvl, public;

ALTER TABLE acp.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN acp.project.purpose
  IS 'The purpose of the project';

