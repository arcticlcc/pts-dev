Begin;

---- Schema: dev ----


---- File: 001-productgroup.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN dev.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE dev.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES dev.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON dev.product(productgroupid);

---- Schema: alcc ----


---- File: 001-productgroup.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN alcc.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE alcc.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES alcc.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON alcc.product(productgroupid);

---- Schema: walcc ----


---- File: 001-productgroup.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN walcc.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE walcc.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES walcc.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON walcc.product(productgroupid);

---- Schema: absi ----


---- File: 001-productgroup.sql ----

SET search_path TO absi, public;

ALTER TABLE absi.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN absi.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE absi.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES absi.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON absi.product(productgroupid);

---- Schema: nwb ----


---- File: 001-productgroup.sql ----

SET search_path TO nwb, public;

ALTER TABLE nwb.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN nwb.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE nwb.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES nwb.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON nwb.product(productgroupid);

