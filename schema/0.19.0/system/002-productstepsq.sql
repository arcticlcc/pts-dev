-- Sequence: common.productstep_productstepid_seq

-- DROP SEQUENCE common.productstep_productstepid_seq;

CREATE SEQUENCE common.productstep_productstepid_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE common.productstep_productstepid_seq
  OWNER TO bradley;
  GRANT SELECT, UPDATE ON SEQUENCE common.productstep_productstepid_seq TO pts_write;
