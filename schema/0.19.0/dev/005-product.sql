ALTER TABLE dev.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN dev.product.perioddescription
  IS 'Description of the time period';

ALTER TABLE dev.product
 ADD COLUMN maintenancefrequencyid integer;
ALTER TABLE dev.product
 ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency (maintenancefrequencyid)
  ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX fki_maintenancefrequency_product_fk
 ON dev.product(maintenancefrequencyid);
