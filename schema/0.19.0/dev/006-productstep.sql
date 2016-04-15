-- Table: dev.productstep

-- DROP TABLE dev.productstep;

CREATE TABLE dev.productstep
(
  productstepid integer NOT NULL DEFAULT nextval('productstep_productstepid_seq'::regclass),
  productid integer NOT NULL, -- PK for PRODUCT
  productcontactid integer NOT NULL,
  description character varying NOT NULL,
  rationale character varying, -- Requirement or purpose for the process step.
  stepdate date NOT NULL, -- Date and time or date at which the process step occurred.
  priority integer NOT NULL DEFAULT 0, -- Order of the step
  CONSTRAINT productstep_pk PRIMARY KEY (productstepid),
  CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid)
        REFERENCES dev.productcontact (productcontactid) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT product_productstep_fk FOREIGN KEY (productid)
      REFERENCES dev.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE dev.productstep
  OWNER TO bradley;
GRANT ALL ON TABLE dev.productstep TO bradley;
GRANT SELECT ON TABLE dev.productstep TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productstep TO pts_write;
GRANT ALL ON TABLE dev.productstep TO pts_admin;
COMMENT ON TABLE dev.productstep
  IS 'Identifies the steps taken when during processing of the product.';
COMMENT ON COLUMN dev.productstep.productid IS 'PK for PRODUCT';
COMMENT ON COLUMN dev.productstep.rationale IS 'Requirement or purpose for the process step.';
COMMENT ON COLUMN dev.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';
COMMENT ON COLUMN dev.productstep.priority IS 'Order of the step';
