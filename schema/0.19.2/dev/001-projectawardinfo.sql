CREATE OR REPLACE VIEW dev.projectawardinfo AS
 SELECT common.form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (pi.firstname::text || ' '::text) || pi.lastname::text AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (fc.firstname::text || ' '::text) || fc.lastname::text AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso,status,
    regexp_replace(array_to_string(array[pi.priemail,fc.priemail], ',' , ''),',$','') as allemail
   FROM project p
     LEFT JOIN contactgroup ON p.orgid = contactgroup.contactid
     LEFT JOIN modification USING (projectid)
     LEFT JOIN cvl.status ON status.statusid = common.project_status(p.projectid)
     LEFT JOIN funding USING (modificationid)
     LEFT JOIN projectcontact pc USING (projectcontactid)
     LEFT JOIN projectcontact rpc ON rpc.projectcontactid = funding.fundingrecipientid
     JOIN contactgrouplist rpg ON rpc.contactid = rpg.contactid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM projectcontact
             JOIN personlist pl USING (contactid)
             JOIN contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN cvl."position" USING (positionid)
          WHERE projectcontact.roletypeid = 7) pi ON p.projectid = pi.projectid AND pi.rank = 1 AND rpg.contactids[1] = pi.contactids[1]
     LEFT JOIN address add ON add.contactid = pi.contactid AND add.addresstypeid = 1
     LEFT JOIN cvl.govunit ON govunit.featureid = add.stateid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM projectcontact
             JOIN personlist pl USING (contactid)
             JOIN contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN cvl."position" USING (positionid)
          WHERE projectcontact.roletypeid = ANY (ARRAY[5, 13])) fc ON p.projectid = fc.projectid AND fc.rank = 1 AND rpg.contactids[1] = fc.contactids[1]
     LEFT JOIN address fadd ON fadd.contactid = fc.contactid AND fadd.addresstypeid = 1
     LEFT JOIN cvl.govunit fg ON fg.featureid = fadd.stateid
  WHERE modification.parentmodificationid IS NULL AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5])) AND status.weight >= 30 AND status.weight <= 60 AND pc.contactid = p.orgid
  ORDER BY common.form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym);
