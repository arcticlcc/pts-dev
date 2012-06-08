-- View: deliverabledue

-- DROP VIEW deliverabledue;

CREATE OR REPLACE VIEW deliverabledue AS
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,receiveddate, d.title, d.description, projectlist.projectcode, project.shorttitle AS project,
  (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact, personlist.priemail AS email,
   CASE WHEN receiveddate IS NOT NULL THEN 0 ELSE 'now'::text::date - dm.duedate END AS dayspastdue,
    modification.projectid, dm.modificationid, d.deliverableid
   FROM deliverable d
   JOIN deliverablemod dm USING (deliverableid)
   JOIN modification USING (modificationid)
   JOIN projectlist USING (projectid)
   JOIN project USING (projectid)
   LEFT JOIN (SELECT * from projectcontact WHERE roletypeid IN (6,7)) as projectcontact USING (projectid)
   LEFT JOIN personlist USING (contactid)
  WHERE NOT dm.invalid OR NOT (EXISTS ( SELECT 1
      FROM deliverablemod dp
     WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, roletypeid, projectcontact.priority;

ALTER TABLE deliverabledue
  OWNER TO bradley;
GRANT ALL ON TABLE deliverabledue TO bradley;
GRANT SELECT ON TABLE deliverabledue TO pts_read;

-- View: task

 DROP VIEW task;

CREATE OR REPLACE VIEW task AS
 SELECT deliverablemod.duedate, deliverable.title, deliverablemod.receiveddate, (person.firstname::text || ' '::text) || person.lastname::text AS assignee, deliverable.description,
deliverablemod.deliverableid, person.contactid, projectid, modificationid
   FROM deliverablemod
   JOIN deliverable USING (deliverableid)
   JOIN person ON deliverablemod.personid = person.contactid
   join modification using (modificationid)
join projectlist using (projectid)
  WHERE (deliverable.deliverabletypeid = ANY (ARRAY[4, 7])) AND (NOT deliverablemod.invalid OR NOT (EXISTS ( SELECT 1
   FROM deliverablemod dm
  WHERE deliverablemod.modificationid = dm.parentmodificationid AND deliverablemod.deliverableid = dm.parentdeliverableid)))
  ORDER BY deliverablemod.duedate DESC;

ALTER TABLE task
  OWNER TO bradley;
GRANT ALL ON TABLE task TO bradley;
GRANT SELECT ON TABLE task TO pts_read;
