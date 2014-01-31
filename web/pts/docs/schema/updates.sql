-- Version 0.11.2

-- View: modificationlist

-- DROP VIEW modificationlist;

CREATE OR REPLACE VIEW modificationlist AS
 SELECT m.modificationid, m.projectid, m.personid, m.modtypeid, m.title, m.description, m.modificationcode, m.effectivedate, m.startdate, m.enddate, m.datecreated, m.parentmodificationid, mt.type AS typetext, mt.code AS typecode, (EXISTS ( SELECT 1
           FROM modification mod
          WHERE m.modificationid = mod.parentmodificationid)) AS ismodified, p.modificationcode AS parentcode, m.shorttitle
   FROM modification m
   JOIN modtype mt USING (modtypeid)
   LEFT JOIN modification p ON p.modificationid = m.parentmodificationid;

-- View: grouppersonlist

-- DROP VIEW grouppersonlist;

CREATE OR REPLACE VIEW grouppersonlist AS
 SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, contactcontactgroup.groupid, contactgroup.acronym, contactgroup.name, contactcontactgroup.positionid, contact.inactive
   FROM contactcontactgroup
   JOIN contact USING (contactid)
   JOIN contactgroup ON contactgroup.contactid = contactcontactgroup.groupid
   JOIN person ON person.contactid = contactcontactgroup.contactid;
