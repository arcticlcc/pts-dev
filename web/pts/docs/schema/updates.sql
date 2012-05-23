-- Foreign Key: contactcostcode_costcode_fk

 ALTER TABLE costcode DROP CONSTRAINT contactcostcode_costcode_fk;

/*ALTER TABLE costcode
  ADD CONSTRAINT contactcostcode_costcode_fk FOREIGN KEY (costcode)
      REFERENCES contactcostcode (costcode) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;*/
