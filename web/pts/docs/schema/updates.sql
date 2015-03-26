-- Version 0.15.3

--add weight to statuslist
CREATE OR REPLACE VIEW dev.statuslist AS
 SELECT s.statusid,
    m.modtypeid,
    s.code,
    s.status,
    s.description,
    weight
   FROM status s
     JOIN modtypestatus m USING (statusid);
CREATE OR REPLACE VIEW alcc.statuslist AS
 SELECT s.statusid,
    m.modtypeid,
    s.code,
    s.status,
    s.description,
    weight
   FROM status s
     JOIN modtypestatus m USING (statusid);
CREATE OR REPLACE VIEW walcc.statuslist AS
 SELECT s.statusid,
    m.modtypeid,
    s.code,
    s.status,
    s.description,
    weight
   FROM status s
     JOIN modtypestatus m USING (statusid);

--set modification.datecreated default to now()

ALTER TABLE dev.modification
   ALTER COLUMN datecreated SET DEFAULT now();
COMMENT ON COLUMN dev.modification.datecreated
  IS 'Date the modification is created in the database.';

ALTER TABLE alcc.modification
   ALTER COLUMN datecreated SET DEFAULT now();
COMMENT ON COLUMN alcc.modification.datecreated
  IS 'Date the modification is created in the database.';

ALTER TABLE walcc.modification
   ALTER COLUMN datecreated SET DEFAULT now();
COMMENT ON COLUMN walcc.modification.datecreated
  IS 'Date the modification is created in the database.';
