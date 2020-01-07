ALTER TABLE dev.project
   ADD COLUMN purpose character varying;
COMMENT ON COLUMN dev.project.purpose
  IS 'The purpose of the project';
