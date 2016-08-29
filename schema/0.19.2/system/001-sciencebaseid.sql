ALTER TABLE common.groupschema
   ADD COLUMN sciencebaseid character varying;
COMMENT ON COLUMN common.groupschema.sciencebaseid
  IS 'The root ScienceBase identifier for the group. Any child metadata will reference this id as the parentId in ScienceBase.';
