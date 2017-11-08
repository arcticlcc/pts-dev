-- View: dev.metadatacontact

DROP VIEW dev.metadatacontact;

CREATE OR REPLACE VIEW dev.metadatacontact AS
 SELECT c.contactid AS "contactId",
    c.name,
    c."isOrganization",
    c."positionName",
    c.uri,
    ((((('+'::text || p.code::text) || ' '::text) || p.areacode) || ' '::text) || p.phnumber) || COALESCE(' x'::text || p.extension, ''::text) AS "officePhone",
    add.street1 AS "deliveryPoint1",
    add.street2 AS "deliveryPoint2",
    add.city,
    govunit.statename AS "administrativeArea",
    add.postalcode::text || COALESCE('-'::text || add.postal4, ''::text) AS "postalCode",
    govunit.countryname AS country,
    e.uri AS email,
    c.uuid,
    c.parentuuid,
    c.allids,
    add.addresstype,
    c.contacttype
   FROM ( SELECT person.contactid,
            con.uuid,
            ccg.contactid AS parentgroupid,
            cg.uuid AS parentuuid,
            array_append(cl.contactids, person.contactid) AS allids,
            false AS "isOrganization",
            (((person.firstname::text || COALESCE(' '::text || person.middlename::text, ''::text)) || ' '::text) || person.lastname::text) || COALESCE(', '::text || person.suffix::text, ''::text) AS name,
            pos.code AS "positionName",
            web.uri,
            ct.adiwg AS contacttype
           FROM person
             JOIN contact con ON person.contactid = con.contactid
             JOIN contacttype ct USING (contacttypeid)
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
             LEFT JOIN contactgrouplist cl ON cl.contactid = ccg.groupid
             LEFT JOIN contact cg ON ccg.contactid = cg.contactid
             LEFT JOIN "position" pos ON ccg.positionid = pos.positionid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = ccg.groupid
        UNION
         SELECT cg.contactid,
            con.uuid,
            cl.parentgroupid,
            pg.uuid AS parentuuid,
            cl.contactids,
            true AS "isOrganization",
            cl.name,
            NULL::character varying AS "positionName",
            web.uri,
            ct.adiwg AS contacttype
           FROM contactgroup cg
             LEFT JOIN contact con ON cg.contactid = con.contactid
             JOIN contacttype ct USING (contacttypeid)
             LEFT JOIN contactgrouplist cl ON cl.contactid = cg.contactid
             LEFT JOIN contact pg ON cl.parentgroupid = pg.contactid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri
                   FROM eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = cg.contactid) c
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            country.phone AS code,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM phone
             JOIN country USING (countryiso)
          WHERE phone.phonetypeid = 3) p ON c.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON c.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT address.addressid,
            address.contactid,
            address.addresstypeid,
            address.street1,
            address.street2,
            address.postalcode,
            address.postal4,
            address.stateid,
            address.countyid,
            address.countryiso,
            address.comment,
            address.latitude,
            address.longitude,
            address.priority,
            address.city,
            addresstype.adiwg AS addresstype,
            row_number() OVER (PARTITION BY address.contactid ORDER BY address.addresstypeid DESC, address.priority) AS rank
           FROM address
             JOIN addresstype USING (addresstypeid)) add ON c.contactid = add.contactid AND add.rank = 1
     LEFT JOIN govunit ON add.stateid = govunit.featureid;

ALTER TABLE dev.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE dev.metadatacontact TO bradley;
GRANT SELECT ON TABLE dev.metadatacontact TO pts_read;
GRANT ALL ON TABLE dev.metadatacontact TO pts_admin;
