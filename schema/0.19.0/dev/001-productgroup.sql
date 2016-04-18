ALTER TABLE dev.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN dev.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE dev.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES dev.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON dev.product(productgroupid);

-- Column: isgroup

-- ALTER TABLE dev.product DROP COLUMN isgroup;

ALTER TABLE dev.product ADD COLUMN isgroup boolean;
UPDATE dev.product
   SET
       isgroup=false
 WHERE isgroup IS NULL;
ALTER TABLE dev.product ALTER COLUMN isgroup SET NOT NULL;
ALTER TABLE dev.product ALTER COLUMN isgroup SET DEFAULT false;
COMMENT ON COLUMN dev.product.isgroup IS 'Identifies whether the item is a product group.';
