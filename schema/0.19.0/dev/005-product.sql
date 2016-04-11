ALTER TABLE dev.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN dev.product.perioddescription
  IS 'Description of the time period';
