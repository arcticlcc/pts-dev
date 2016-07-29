ALTER TABLE dev.product ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN dev.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE dev.project ADD COLUMN sciencebaseid character varying;

 COMMENT ON COLUMN dev.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


ALTER TABLE dev.project ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


ALTER TABLE dev.product ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);
