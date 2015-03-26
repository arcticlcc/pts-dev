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
