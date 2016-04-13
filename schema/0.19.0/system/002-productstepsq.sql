-- Sequence: cvl.productstep_productstepid_seq

-- DROP SEQUENCE cvl.productstep_productstepid_seq;

CREATE SEQUENCE cvl.productstep_productstepid_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE cvl.productstep_productstepid_seq
  OWNER TO bradley;
  GRANT SELECT, UPDATE ON SEQUENCE cvl.productstep_productstepid_seq TO pts_write;
