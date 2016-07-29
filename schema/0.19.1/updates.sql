Begin;

---- System ----


SET search_path TO '';

---- Schema: dev ----


---- File: 001-sciencebaseid.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.product ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN dev.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE dev.project ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN dev.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE dev.project ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


ALTER TABLE dev.product ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);

---- Schema: alcc ----


---- File: 001-sciencebaseid.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.product ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN alcc.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE alcc.project ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN alcc.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE alcc.project ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


ALTER TABLE alcc.product ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);

---- Schema: walcc ----


---- File: 001-sciencebaseid.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.product ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN walcc.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE walcc.project ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN walcc.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE walcc.project ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


ALTER TABLE walcc.product ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);

---- Schema: absi ----


---- File: 001-sciencebaseid.sql ----

SET search_path TO absi, public;

ALTER TABLE absi.product ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN absi.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE absi.project ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN absi.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE absi.project ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


ALTER TABLE absi.product ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);

---- Schema: nwb ----


---- File: 001-sciencebaseid.sql ----

SET search_path TO nwb, public;

ALTER TABLE nwb.product ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN nwb.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE nwb.project ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN nwb.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE nwb.project ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


ALTER TABLE nwb.product ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);

