ALTER TABLE dev.deliverable
   ADD COLUMN code character varying;
COMMENT ON COLUMN dev.deliverable.code
  IS 'Code associated with the deliverable.';
