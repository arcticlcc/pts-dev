ALTER TABLE dev.product
   ADD COLUMN uselimitation character varying;
COMMENT ON COLUMN dev.product.uselimitation
  IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';
