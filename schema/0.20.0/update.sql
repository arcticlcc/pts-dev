Begin;

---- System ----


SET search_path TO '';

---- File: 001-contacttype.sql ----


UPDATE cvl.contacttype
   SET adiwg='lcc'
 WHERE code = 'LCC';

SET search_path TO '';

---- Schema: dev ----


---- File: 001-contact_uuid.sql ----

SET search_path TO dev, cvl, public;

-- Column: uuid

ALTER TABLE dev.contact ADD COLUMN uuid uuid;

UPDATE dev.contact SET uuid = uuid_generate_v4();

ALTER TABLE dev.contact ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE dev.contact ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
COMMENT ON COLUMN dev.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';
---- File: 002-metadatacontact.sql ----

SET search_path TO dev, cvl, public;

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
---- File: 003-allcontacts.sql ----

SET search_path TO dev, cvl, public;

-- View: dev.projectallcontacts

-- DROP VIEW dev.projectallcontacts;

CREATE OR REPLACE VIEW dev.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM dev.metadatacontact
             JOIN dev.projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE dev.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE dev.projectallcontacts TO bradley;
GRANT SELECT ON TABLE dev.projectallcontacts TO pts_read;
GRANT ALL ON TABLE dev.projectallcontacts TO pts_admin;

-- View: dev.productallcontacts

-- DROP VIEW dev.productallcontacts;

CREATE OR REPLACE VIEW dev.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM dev.metadatacontact
             JOIN dev.productcontact ON metadatacontact."contactId" = productcontact.contactid) dt(contactid, productid);

ALTER TABLE dev.productallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE dev.productallcontacts TO bradley;
GRANT SELECT ON TABLE dev.productallcontacts TO pts_read;
GRANT ALL ON TABLE dev.productallcontacts TO pts_admin;
---- File: 004-metadataproject.sql ----

SET search_path TO dev, cvl, public;

-- View: dev.metadataproject

-- DROP VIEW dev.metadataproject;

CREATE OR REPLACE VIEW dev.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "resourceIdentifier",
    project.shorttitle,
    project.exportmetadata,
    format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = common.project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
           FROM projectusertype
             JOIN usertype USING (usertypeid)
          GROUP BY projectusertype.projectid) ut USING (projectid)
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM projecttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY projecttopiccategory.projectid) tc USING (projectid)
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
           FROM projectprojectcategory
             JOIN projectcategory USING (projectcategoryid)
          GROUP BY projectprojectcategory.projectid) pc USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

ALTER TABLE dev.metadataproject
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.metadataproject TO pts_admin;
GRANT SELECT ON TABLE dev.metadataproject TO pts_read;
---- File: 005-metadataproduct.sql ----

SET search_path TO dev, cvl, public;

-- View: dev.metadataproduct

-- DROP VIEW dev.metadataproduct;

CREATE OR REPLACE VIEW dev.metadataproduct AS
 SELECT product.productid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    product.orgid,
    product.title,
    deliverabletype.isocodename AS resourcetype,
    product.projectid,
    product.startdate,
    product.enddate,
    product.description AS "shortAbstract",
    product.abstract,
    product.uuid AS "resourceIdentifier",
    product.exportmetadata,
    format(gschema.producturiformat::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN fea.features IS NOT NULL THEN to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)])
            ELSE NULL::json
        END AS bbox,
    fea.features,
    product.purpose,
    tc.topiccategory,
    product.metadataupdate,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency,
    product.sciencebaseid
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))) gschema,
    product
     LEFT JOIN project USING (projectid)
     JOIN deliverabletype USING (deliverabletypeid)
     LEFT JOIN maintenancefrequency mf USING (maintenancefrequencyid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid)
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM producttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY producttopiccategory.productid) tc USING (productid)
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
           FROM productspatialformat
             JOIN spatialformat USING (spatialformatid)
          GROUP BY productspatialformat.productid) sf USING (productid)
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid)
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid)
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            'point-'::text || productpoint.productpointid AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid);

ALTER TABLE dev.metadataproduct
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE dev.metadataproduct TO pts_read;
---- File: 006-metadatafunding.sql ----

SET search_path TO dev, cvl, public;

-- View: dev.metadatafunding

-- DROP VIEW dev.metadatafunding;

CREATE OR REPLACE VIEW dev.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fc.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN contact fc ON fun.contactid = fc.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;

ALTER TABLE dev.metadatafunding
  OWNER TO bradley;
GRANT ALL ON TABLE dev.metadatafunding TO bradley;
GRANT SELECT ON TABLE dev.metadatafunding TO pts_read;
GRANT ALL ON TABLE dev.metadatafunding TO pts_admin;

---- Schema: alcc ----


---- File: 001-contact_uuid.sql ----

SET search_path TO alcc, cvl, public;

-- Column: uuid

ALTER TABLE alcc.contact ADD COLUMN uuid uuid;

UPDATE alcc.contact SET uuid = uuid_generate_v4();

ALTER TABLE alcc.contact ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE alcc.contact ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
COMMENT ON COLUMN alcc.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';
---- File: 002-metadatacontact.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.metadatacontact

DROP VIEW alcc.metadatacontact;

CREATE OR REPLACE VIEW alcc.metadatacontact AS
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

ALTER TABLE alcc.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.metadatacontact TO bradley;
GRANT SELECT ON TABLE alcc.metadatacontact TO pts_read;
GRANT ALL ON TABLE alcc.metadatacontact TO pts_admin;
---- File: 003-allcontacts.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.projectallcontacts

-- DROP VIEW alcc.projectallcontacts;

CREATE OR REPLACE VIEW alcc.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM alcc.metadatacontact
             JOIN alcc.projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE alcc.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.projectallcontacts TO bradley;
GRANT SELECT ON TABLE alcc.projectallcontacts TO pts_read;
GRANT ALL ON TABLE alcc.projectallcontacts TO pts_admin;

-- View: alcc.productallcontacts

-- DROP VIEW alcc.productallcontacts;

CREATE OR REPLACE VIEW alcc.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM alcc.metadatacontact
             JOIN alcc.productcontact ON metadatacontact."contactId" = productcontact.contactid) dt(contactid, productid);

ALTER TABLE alcc.productallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.productallcontacts TO bradley;
GRANT SELECT ON TABLE alcc.productallcontacts TO pts_read;
GRANT ALL ON TABLE alcc.productallcontacts TO pts_admin;
---- File: 004-metadataproject.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.metadataproject

-- DROP VIEW alcc.metadataproject;

CREATE OR REPLACE VIEW alcc.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "resourceIdentifier",
    project.shorttitle,
    project.exportmetadata,
    format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = common.project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
           FROM projectusertype
             JOIN usertype USING (usertypeid)
          GROUP BY projectusertype.projectid) ut USING (projectid)
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM projecttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY projecttopiccategory.projectid) tc USING (projectid)
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
           FROM projectprojectcategory
             JOIN projectcategory USING (projectcategoryid)
          GROUP BY projectprojectcategory.projectid) pc USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

ALTER TABLE alcc.metadataproject
  OWNER TO pts_admin;
GRANT ALL ON TABLE alcc.metadataproject TO pts_admin;
GRANT SELECT ON TABLE alcc.metadataproject TO pts_read;
---- File: 005-metadataproduct.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.metadataproduct

-- DROP VIEW alcc.metadataproduct;

CREATE OR REPLACE VIEW alcc.metadataproduct AS
 SELECT product.productid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    product.orgid,
    product.title,
    deliverabletype.isocodename AS resourcetype,
    product.projectid,
    product.startdate,
    product.enddate,
    product.description AS "shortAbstract",
    product.abstract,
    product.uuid AS "resourceIdentifier",
    product.exportmetadata,
    format(gschema.producturiformat::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN fea.features IS NOT NULL THEN to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)])
            ELSE NULL::json
        END AS bbox,
    fea.features,
    product.purpose,
    tc.topiccategory,
    product.metadataupdate,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency,
    product.sciencebaseid
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))) gschema,
    product
     LEFT JOIN project USING (projectid)
     JOIN deliverabletype USING (deliverabletypeid)
     LEFT JOIN maintenancefrequency mf USING (maintenancefrequencyid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid)
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM producttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY producttopiccategory.productid) tc USING (productid)
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
           FROM productspatialformat
             JOIN spatialformat USING (spatialformatid)
          GROUP BY productspatialformat.productid) sf USING (productid)
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid)
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid)
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            'point-'::text || productpoint.productpointid AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid);

ALTER TABLE alcc.metadataproduct
  OWNER TO pts_admin;
GRANT ALL ON TABLE alcc.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE alcc.metadataproduct TO pts_read;
---- File: 006-metadatafunding.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.metadatafunding

-- DROP VIEW alcc.metadatafunding;

CREATE OR REPLACE VIEW alcc.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fc.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN contact fc ON fun.contactid = fc.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;

ALTER TABLE alcc.metadatafunding
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.metadatafunding TO bradley;
GRANT SELECT ON TABLE alcc.metadatafunding TO pts_read;
GRANT ALL ON TABLE alcc.metadatafunding TO pts_admin;

---- Schema: walcc ----


---- File: 001-contact_uuid.sql ----

SET search_path TO walcc, cvl, public;

-- Column: uuid

ALTER TABLE walcc.contact ADD COLUMN uuid uuid;

UPDATE walcc.contact SET uuid = uuid_generate_v4();

ALTER TABLE walcc.contact ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE walcc.contact ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
COMMENT ON COLUMN walcc.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';
---- File: 002-metadatacontact.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.metadatacontact

DROP VIEW walcc.metadatacontact;

CREATE OR REPLACE VIEW walcc.metadatacontact AS
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

ALTER TABLE walcc.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.metadatacontact TO bradley;
GRANT SELECT ON TABLE walcc.metadatacontact TO pts_read;
GRANT ALL ON TABLE walcc.metadatacontact TO pts_admin;
---- File: 003-allcontacts.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.projectallcontacts

-- DROP VIEW walcc.projectallcontacts;

CREATE OR REPLACE VIEW walcc.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM walcc.metadatacontact
             JOIN walcc.projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE walcc.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.projectallcontacts TO bradley;
GRANT SELECT ON TABLE walcc.projectallcontacts TO pts_read;
GRANT ALL ON TABLE walcc.projectallcontacts TO pts_admin;

-- View: walcc.productallcontacts

-- DROP VIEW walcc.productallcontacts;

CREATE OR REPLACE VIEW walcc.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM walcc.metadatacontact
             JOIN walcc.productcontact ON metadatacontact."contactId" = productcontact.contactid) dt(contactid, productid);

ALTER TABLE walcc.productallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.productallcontacts TO bradley;
GRANT SELECT ON TABLE walcc.productallcontacts TO pts_read;
GRANT ALL ON TABLE walcc.productallcontacts TO pts_admin;
---- File: 004-metadataproject.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.metadataproject

-- DROP VIEW walcc.metadataproject;

CREATE OR REPLACE VIEW walcc.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "resourceIdentifier",
    project.shorttitle,
    project.exportmetadata,
    format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = common.project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
           FROM projectusertype
             JOIN usertype USING (usertypeid)
          GROUP BY projectusertype.projectid) ut USING (projectid)
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM projecttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY projecttopiccategory.projectid) tc USING (projectid)
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
           FROM projectprojectcategory
             JOIN projectcategory USING (projectcategoryid)
          GROUP BY projectprojectcategory.projectid) pc USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

ALTER TABLE walcc.metadataproject
  OWNER TO pts_admin;
GRANT ALL ON TABLE walcc.metadataproject TO pts_admin;
GRANT SELECT ON TABLE walcc.metadataproject TO pts_read;
---- File: 005-metadataproduct.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.metadataproduct

-- DROP VIEW walcc.metadataproduct;

CREATE OR REPLACE VIEW walcc.metadataproduct AS
 SELECT product.productid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    product.orgid,
    product.title,
    deliverabletype.isocodename AS resourcetype,
    product.projectid,
    product.startdate,
    product.enddate,
    product.description AS "shortAbstract",
    product.abstract,
    product.uuid AS "resourceIdentifier",
    product.exportmetadata,
    format(gschema.producturiformat::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN fea.features IS NOT NULL THEN to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)])
            ELSE NULL::json
        END AS bbox,
    fea.features,
    product.purpose,
    tc.topiccategory,
    product.metadataupdate,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency,
    product.sciencebaseid
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))) gschema,
    product
     LEFT JOIN project USING (projectid)
     JOIN deliverabletype USING (deliverabletypeid)
     LEFT JOIN maintenancefrequency mf USING (maintenancefrequencyid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid)
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM producttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY producttopiccategory.productid) tc USING (productid)
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
           FROM productspatialformat
             JOIN spatialformat USING (spatialformatid)
          GROUP BY productspatialformat.productid) sf USING (productid)
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid)
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid)
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            'point-'::text || productpoint.productpointid AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid);

ALTER TABLE walcc.metadataproduct
  OWNER TO pts_admin;
GRANT ALL ON TABLE walcc.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE walcc.metadataproduct TO pts_read;
---- File: 006-metadatafunding.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.metadatafunding

-- DROP VIEW walcc.metadatafunding;

CREATE OR REPLACE VIEW walcc.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fc.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN contact fc ON fun.contactid = fc.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;

ALTER TABLE walcc.metadatafunding
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.metadatafunding TO bradley;
GRANT SELECT ON TABLE walcc.metadatafunding TO pts_read;
GRANT ALL ON TABLE walcc.metadatafunding TO pts_admin;

---- Schema: absi ----


---- File: 001-contact_uuid.sql ----

SET search_path TO absi, cvl, public;

-- Column: uuid

ALTER TABLE absi.contact ADD COLUMN uuid uuid;

UPDATE absi.contact SET uuid = uuid_generate_v4();

ALTER TABLE absi.contact ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE absi.contact ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
COMMENT ON COLUMN absi.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';
---- File: 002-metadatacontact.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.metadatacontact

DROP VIEW absi.metadatacontact;

CREATE OR REPLACE VIEW absi.metadatacontact AS
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

ALTER TABLE absi.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE absi.metadatacontact TO bradley;
GRANT SELECT ON TABLE absi.metadatacontact TO pts_read;
GRANT ALL ON TABLE absi.metadatacontact TO pts_admin;
---- File: 003-allcontacts.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.projectallcontacts

-- DROP VIEW absi.projectallcontacts;

CREATE OR REPLACE VIEW absi.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM absi.metadatacontact
             JOIN absi.projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE absi.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE absi.projectallcontacts TO bradley;
GRANT SELECT ON TABLE absi.projectallcontacts TO pts_read;
GRANT ALL ON TABLE absi.projectallcontacts TO pts_admin;

-- View: absi.productallcontacts

-- DROP VIEW absi.productallcontacts;

CREATE OR REPLACE VIEW absi.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM absi.metadatacontact
             JOIN absi.productcontact ON metadatacontact."contactId" = productcontact.contactid) dt(contactid, productid);

ALTER TABLE absi.productallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE absi.productallcontacts TO bradley;
GRANT SELECT ON TABLE absi.productallcontacts TO pts_read;
GRANT ALL ON TABLE absi.productallcontacts TO pts_admin;
---- File: 004-metadataproject.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.metadataproject

-- DROP VIEW absi.metadataproject;

CREATE OR REPLACE VIEW absi.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "resourceIdentifier",
    project.shorttitle,
    project.exportmetadata,
    format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = common.project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
           FROM projectusertype
             JOIN usertype USING (usertypeid)
          GROUP BY projectusertype.projectid) ut USING (projectid)
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM projecttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY projecttopiccategory.projectid) tc USING (projectid)
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
           FROM projectprojectcategory
             JOIN projectcategory USING (projectcategoryid)
          GROUP BY projectprojectcategory.projectid) pc USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

ALTER TABLE absi.metadataproject
  OWNER TO pts_admin;
GRANT ALL ON TABLE absi.metadataproject TO pts_admin;
GRANT SELECT ON TABLE absi.metadataproject TO pts_read;
---- File: 005-metadataproduct.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.metadataproduct

-- DROP VIEW absi.metadataproduct;

CREATE OR REPLACE VIEW absi.metadataproduct AS
 SELECT product.productid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    product.orgid,
    product.title,
    deliverabletype.isocodename AS resourcetype,
    product.projectid,
    product.startdate,
    product.enddate,
    product.description AS "shortAbstract",
    product.abstract,
    product.uuid AS "resourceIdentifier",
    product.exportmetadata,
    format(gschema.producturiformat::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN fea.features IS NOT NULL THEN to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)])
            ELSE NULL::json
        END AS bbox,
    fea.features,
    product.purpose,
    tc.topiccategory,
    product.metadataupdate,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency,
    product.sciencebaseid
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))) gschema,
    product
     LEFT JOIN project USING (projectid)
     JOIN deliverabletype USING (deliverabletypeid)
     LEFT JOIN maintenancefrequency mf USING (maintenancefrequencyid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid)
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM producttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY producttopiccategory.productid) tc USING (productid)
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
           FROM productspatialformat
             JOIN spatialformat USING (spatialformatid)
          GROUP BY productspatialformat.productid) sf USING (productid)
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid)
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid)
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            'point-'::text || productpoint.productpointid AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid);

ALTER TABLE absi.metadataproduct
  OWNER TO pts_admin;
GRANT ALL ON TABLE absi.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE absi.metadataproduct TO pts_read;
---- File: 006-metadatafunding.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.metadatafunding

-- DROP VIEW absi.metadatafunding;

CREATE OR REPLACE VIEW absi.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fc.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN contact fc ON fun.contactid = fc.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;

ALTER TABLE absi.metadatafunding
  OWNER TO bradley;
GRANT ALL ON TABLE absi.metadatafunding TO bradley;
GRANT SELECT ON TABLE absi.metadatafunding TO pts_read;
GRANT ALL ON TABLE absi.metadatafunding TO pts_admin;

---- Schema: nwb ----


---- File: 001-contact_uuid.sql ----

SET search_path TO nwb, cvl, public;

-- Column: uuid

ALTER TABLE nwb.contact ADD COLUMN uuid uuid;

UPDATE nwb.contact SET uuid = uuid_generate_v4();

ALTER TABLE nwb.contact ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE nwb.contact ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
COMMENT ON COLUMN nwb.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';
---- File: 002-metadatacontact.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.metadatacontact

DROP VIEW nwb.metadatacontact;

CREATE OR REPLACE VIEW nwb.metadatacontact AS
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

ALTER TABLE nwb.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE nwb.metadatacontact TO bradley;
GRANT SELECT ON TABLE nwb.metadatacontact TO pts_read;
GRANT ALL ON TABLE nwb.metadatacontact TO pts_admin;
---- File: 003-allcontacts.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.projectallcontacts

-- DROP VIEW nwb.projectallcontacts;

CREATE OR REPLACE VIEW nwb.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM nwb.metadatacontact
             JOIN nwb.projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE nwb.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE nwb.projectallcontacts TO bradley;
GRANT SELECT ON TABLE nwb.projectallcontacts TO pts_read;
GRANT ALL ON TABLE nwb.projectallcontacts TO pts_admin;

-- View: nwb.productallcontacts

-- DROP VIEW nwb.productallcontacts;

CREATE OR REPLACE VIEW nwb.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM nwb.metadatacontact
             JOIN nwb.productcontact ON metadatacontact."contactId" = productcontact.contactid) dt(contactid, productid);

ALTER TABLE nwb.productallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE nwb.productallcontacts TO bradley;
GRANT SELECT ON TABLE nwb.productallcontacts TO pts_read;
GRANT ALL ON TABLE nwb.productallcontacts TO pts_admin;
---- File: 004-metadataproject.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.metadataproject

-- DROP VIEW nwb.metadataproject;

CREATE OR REPLACE VIEW nwb.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "resourceIdentifier",
    project.shorttitle,
    project.exportmetadata,
    format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = common.project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
           FROM projectusertype
             JOIN usertype USING (usertypeid)
          GROUP BY projectusertype.projectid) ut USING (projectid)
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM projecttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY projecttopiccategory.projectid) tc USING (projectid)
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
           FROM projectprojectcategory
             JOIN projectcategory USING (projectcategoryid)
          GROUP BY projectprojectcategory.projectid) pc USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

ALTER TABLE nwb.metadataproject
  OWNER TO pts_admin;
GRANT ALL ON TABLE nwb.metadataproject TO pts_admin;
GRANT SELECT ON TABLE nwb.metadataproject TO pts_read;
---- File: 005-metadataproduct.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.metadataproduct

-- DROP VIEW nwb.metadataproduct;

CREATE OR REPLACE VIEW nwb.metadataproduct AS
 SELECT product.productid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    product.orgid,
    product.title,
    deliverabletype.isocodename AS resourcetype,
    product.projectid,
    product.startdate,
    product.enddate,
    product.description AS "shortAbstract",
    product.abstract,
    product.uuid AS "resourceIdentifier",
    product.exportmetadata,
    format(gschema.producturiformat::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN fea.features IS NOT NULL THEN to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)])
            ELSE NULL::json
        END AS bbox,
    fea.features,
    product.purpose,
    tc.topiccategory,
    product.metadataupdate,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency,
    product.sciencebaseid
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))) gschema,
    product
     LEFT JOIN project USING (projectid)
     JOIN deliverabletype USING (deliverabletypeid)
     LEFT JOIN maintenancefrequency mf USING (maintenancefrequencyid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid)
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid)
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM producttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY producttopiccategory.productid) tc USING (productid)
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
           FROM productspatialformat
             JOIN spatialformat USING (spatialformatid)
          GROUP BY productspatialformat.productid) sf USING (productid)
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid)
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid)
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            'point-'::text || productpoint.productpointid AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid);

ALTER TABLE nwb.metadataproduct
  OWNER TO pts_admin;
GRANT ALL ON TABLE nwb.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE nwb.metadataproduct TO pts_read;
---- File: 006-metadatafunding.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.metadatafunding

-- DROP VIEW nwb.metadatafunding;

CREATE OR REPLACE VIEW nwb.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fc.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN contact fc ON fun.contactid = fc.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;

ALTER TABLE nwb.metadatafunding
  OWNER TO bradley;
GRANT ALL ON TABLE nwb.metadatafunding TO bradley;
GRANT SELECT ON TABLE nwb.metadatafunding TO pts_read;
GRANT ALL ON TABLE nwb.metadatafunding TO pts_admin;

