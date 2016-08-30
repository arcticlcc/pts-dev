Begin;

---- System ----


SET search_path TO '';

---- File: 001-sciencebaseid.sql ----


ALTER TABLE common.groupschema
   ADD COLUMN sciencebaseid character varying;
COMMENT ON COLUMN common.groupschema.sciencebaseid
  IS 'The root ScienceBase identifier for the group. Any child metadata will reference this id as the parentId in ScienceBase.';

SET search_path TO '';

---- Schema: dev ----


---- File: 001-projectawardinfo.sql ----

SET search_path TO dev, public;

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
---- File: 002-sciencebaseid.sql ----

SET search_path TO dev, public;

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
FROM
    (SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE))) gschema,
                                                                           product
LEFT JOIN project USING (projectid)
JOIN cvl.deliverabletype USING (deliverabletypeid)
LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid)
LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid)
LEFT JOIN
    (SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT productkeyword_1.productid,
                 keyword.preflabel
          FROM productkeyword productkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY productkeyword_1.productid,
                   keyword.preflabel) productkeyword
     GROUP BY productkeyword.productid) kw USING (productid)
LEFT JOIN
    (SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM producttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY producttopiccategory.productid) tc USING (productid)
LEFT JOIN
    (SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
     FROM productspatialformat
     JOIN cvl.spatialformat USING (spatialformatid)
     GROUP BY productspatialformat.productid) sf USING (productid)
LEFT JOIN
    (SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
     FROM productepsg
     GROUP BY productepsg.productid) ep USING (productid)
LEFT JOIN
    (SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
     FROM productwkt
     GROUP BY productwkt.productid) wkt USING (productid)
LEFT JOIN
    (SELECT f.productid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.type, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.productid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT productpoint.productid,
                      'point-'::text || productpoint.productpointid AS id,
                                        productpoint.name,
                                        productpoint.comment,
                                        productpoint.the_geom
               FROM productpoint
               UNION SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                                                productpolygon.name,
                                                productpolygon.comment,
                                                productpolygon.the_geom
               FROM productpolygon
               UNION SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                                             productline.name,
                                             productline.comment,
                                             productline.the_geom
               FROM productline) lg) f
     GROUP BY f.productid) fea USING (productid);

 -- View: dev.metadataproject
 -- DROP VIEW dev.metadataproject;

CREATE OR REPLACE VIEW dev.metadataproject AS WITH gschema AS
    ( SELECT groupschema.groupschemaid,
             groupschema.groupid,
             groupschema.displayname,
             groupschema.deliverablecalendarid,
             groupschema.projecturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE)) )
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
       format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double PRECISION, '999909'::text))) AS uri,

    (SELECT m.datecreated
     FROM modification m
     WHERE m.projectid = project.projectid
     ORDER BY m.datecreated LIMIT 1) AS datecreated,
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
JOIN cvl.status ON status.statusid = common.project_status(project.projectid)
LEFT JOIN
    (SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT projectkeyword_1.projectid,
                 keyword.preflabel
          FROM projectkeyword projectkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY projectkeyword_1.projectid,
                   keyword.preflabel) projectkeyword
     GROUP BY projectkeyword.projectid) kw USING (projectid)
LEFT JOIN
    (SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
     FROM projectusertype
     JOIN cvl.usertype USING (usertypeid)
     GROUP BY projectusertype.projectid) ut USING (projectid)
LEFT JOIN
    (SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM projecttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY projecttopiccategory.projectid) tc USING (projectid)
LEFT JOIN
    (SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
     FROM projectprojectcategory
     JOIN cvl.projectcategory USING (projectcategoryid)
     GROUP BY projectprojectcategory.projectid) pc USING (projectid)
LEFT JOIN
    (SELECT f.projectid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.TYPE, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.projectid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT projectpoint.projectid,
                      'point-'::text || projectpoint.projectpointid AS id,
                                        projectpoint.name,
                                        projectpoint.comment,
                                        projectpoint.the_geom
               FROM projectpoint
               UNION SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                                                projectpolygon.name,
                                                projectpolygon.comment,
                                                projectpolygon.the_geom
               FROM projectpolygon
               UNION SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                                             projectline.name,
                                             projectline.comment,
                                             projectline.the_geom
               FROM projectline) lg) f
     GROUP BY f.projectid) fea USING (projectid);

---- Schema: alcc ----


---- File: 001-projectawardinfo.sql ----

SET search_path TO alcc, public;

CREATE OR REPLACE VIEW alcc.projectawardinfo AS
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
---- File: 002-sciencebaseid.sql ----

SET search_path TO alcc, public;

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
FROM
    (SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE))) gschema,
                                                                           product
LEFT JOIN project USING (projectid)
JOIN cvl.deliverabletype USING (deliverabletypeid)
LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid)
LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid)
LEFT JOIN
    (SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT productkeyword_1.productid,
                 keyword.preflabel
          FROM productkeyword productkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY productkeyword_1.productid,
                   keyword.preflabel) productkeyword
     GROUP BY productkeyword.productid) kw USING (productid)
LEFT JOIN
    (SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM producttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY producttopiccategory.productid) tc USING (productid)
LEFT JOIN
    (SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
     FROM productspatialformat
     JOIN cvl.spatialformat USING (spatialformatid)
     GROUP BY productspatialformat.productid) sf USING (productid)
LEFT JOIN
    (SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
     FROM productepsg
     GROUP BY productepsg.productid) ep USING (productid)
LEFT JOIN
    (SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
     FROM productwkt
     GROUP BY productwkt.productid) wkt USING (productid)
LEFT JOIN
    (SELECT f.productid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.type, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.productid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT productpoint.productid,
                      'point-'::text || productpoint.productpointid AS id,
                                        productpoint.name,
                                        productpoint.comment,
                                        productpoint.the_geom
               FROM productpoint
               UNION SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                                                productpolygon.name,
                                                productpolygon.comment,
                                                productpolygon.the_geom
               FROM productpolygon
               UNION SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                                             productline.name,
                                             productline.comment,
                                             productline.the_geom
               FROM productline) lg) f
     GROUP BY f.productid) fea USING (productid);

 -- View: alcc.metadataproject
 -- DROP VIEW alcc.metadataproject;

CREATE OR REPLACE VIEW alcc.metadataproject AS WITH gschema AS
    ( SELECT groupschema.groupschemaid,
             groupschema.groupid,
             groupschema.displayname,
             groupschema.deliverablecalendarid,
             groupschema.projecturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE)) )
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
       format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double PRECISION, '999909'::text))) AS uri,

    (SELECT m.datecreated
     FROM modification m
     WHERE m.projectid = project.projectid
     ORDER BY m.datecreated LIMIT 1) AS datecreated,
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
JOIN cvl.status ON status.statusid = common.project_status(project.projectid)
LEFT JOIN
    (SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT projectkeyword_1.projectid,
                 keyword.preflabel
          FROM projectkeyword projectkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY projectkeyword_1.projectid,
                   keyword.preflabel) projectkeyword
     GROUP BY projectkeyword.projectid) kw USING (projectid)
LEFT JOIN
    (SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
     FROM projectusertype
     JOIN cvl.usertype USING (usertypeid)
     GROUP BY projectusertype.projectid) ut USING (projectid)
LEFT JOIN
    (SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM projecttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY projecttopiccategory.projectid) tc USING (projectid)
LEFT JOIN
    (SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
     FROM projectprojectcategory
     JOIN cvl.projectcategory USING (projectcategoryid)
     GROUP BY projectprojectcategory.projectid) pc USING (projectid)
LEFT JOIN
    (SELECT f.projectid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.TYPE, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.projectid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT projectpoint.projectid,
                      'point-'::text || projectpoint.projectpointid AS id,
                                        projectpoint.name,
                                        projectpoint.comment,
                                        projectpoint.the_geom
               FROM projectpoint
               UNION SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                                                projectpolygon.name,
                                                projectpolygon.comment,
                                                projectpolygon.the_geom
               FROM projectpolygon
               UNION SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                                             projectline.name,
                                             projectline.comment,
                                             projectline.the_geom
               FROM projectline) lg) f
     GROUP BY f.projectid) fea USING (projectid);

---- Schema: walcc ----


---- File: 001-projectawardinfo.sql ----

SET search_path TO walcc, public;

CREATE OR REPLACE VIEW walcc.projectawardinfo AS
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
---- File: 002-sciencebaseid.sql ----

SET search_path TO walcc, public;

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
FROM
    (SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE))) gschema,
                                                                           product
LEFT JOIN project USING (projectid)
JOIN cvl.deliverabletype USING (deliverabletypeid)
LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid)
LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid)
LEFT JOIN
    (SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT productkeyword_1.productid,
                 keyword.preflabel
          FROM productkeyword productkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY productkeyword_1.productid,
                   keyword.preflabel) productkeyword
     GROUP BY productkeyword.productid) kw USING (productid)
LEFT JOIN
    (SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM producttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY producttopiccategory.productid) tc USING (productid)
LEFT JOIN
    (SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
     FROM productspatialformat
     JOIN cvl.spatialformat USING (spatialformatid)
     GROUP BY productspatialformat.productid) sf USING (productid)
LEFT JOIN
    (SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
     FROM productepsg
     GROUP BY productepsg.productid) ep USING (productid)
LEFT JOIN
    (SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
     FROM productwkt
     GROUP BY productwkt.productid) wkt USING (productid)
LEFT JOIN
    (SELECT f.productid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.type, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.productid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT productpoint.productid,
                      'point-'::text || productpoint.productpointid AS id,
                                        productpoint.name,
                                        productpoint.comment,
                                        productpoint.the_geom
               FROM productpoint
               UNION SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                                                productpolygon.name,
                                                productpolygon.comment,
                                                productpolygon.the_geom
               FROM productpolygon
               UNION SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                                             productline.name,
                                             productline.comment,
                                             productline.the_geom
               FROM productline) lg) f
     GROUP BY f.productid) fea USING (productid);

 -- View: walcc.metadataproject
 -- DROP VIEW walcc.metadataproject;

CREATE OR REPLACE VIEW walcc.metadataproject AS WITH gschema AS
    ( SELECT groupschema.groupschemaid,
             groupschema.groupid,
             groupschema.displayname,
             groupschema.deliverablecalendarid,
             groupschema.projecturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE)) )
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
       format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double PRECISION, '999909'::text))) AS uri,

    (SELECT m.datecreated
     FROM modification m
     WHERE m.projectid = project.projectid
     ORDER BY m.datecreated LIMIT 1) AS datecreated,
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
JOIN cvl.status ON status.statusid = common.project_status(project.projectid)
LEFT JOIN
    (SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT projectkeyword_1.projectid,
                 keyword.preflabel
          FROM projectkeyword projectkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY projectkeyword_1.projectid,
                   keyword.preflabel) projectkeyword
     GROUP BY projectkeyword.projectid) kw USING (projectid)
LEFT JOIN
    (SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
     FROM projectusertype
     JOIN cvl.usertype USING (usertypeid)
     GROUP BY projectusertype.projectid) ut USING (projectid)
LEFT JOIN
    (SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM projecttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY projecttopiccategory.projectid) tc USING (projectid)
LEFT JOIN
    (SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
     FROM projectprojectcategory
     JOIN cvl.projectcategory USING (projectcategoryid)
     GROUP BY projectprojectcategory.projectid) pc USING (projectid)
LEFT JOIN
    (SELECT f.projectid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.TYPE, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.projectid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT projectpoint.projectid,
                      'point-'::text || projectpoint.projectpointid AS id,
                                        projectpoint.name,
                                        projectpoint.comment,
                                        projectpoint.the_geom
               FROM projectpoint
               UNION SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                                                projectpolygon.name,
                                                projectpolygon.comment,
                                                projectpolygon.the_geom
               FROM projectpolygon
               UNION SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                                             projectline.name,
                                             projectline.comment,
                                             projectline.the_geom
               FROM projectline) lg) f
     GROUP BY f.projectid) fea USING (projectid);

---- Schema: absi ----


---- File: 001-projectawardinfo.sql ----

SET search_path TO absi, public;

CREATE OR REPLACE VIEW absi.projectawardinfo AS
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
---- File: 002-sciencebaseid.sql ----

SET search_path TO absi, public;

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
FROM
    (SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE))) gschema,
                                                                           product
LEFT JOIN project USING (projectid)
JOIN cvl.deliverabletype USING (deliverabletypeid)
LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid)
LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid)
LEFT JOIN
    (SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT productkeyword_1.productid,
                 keyword.preflabel
          FROM productkeyword productkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY productkeyword_1.productid,
                   keyword.preflabel) productkeyword
     GROUP BY productkeyword.productid) kw USING (productid)
LEFT JOIN
    (SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM producttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY producttopiccategory.productid) tc USING (productid)
LEFT JOIN
    (SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
     FROM productspatialformat
     JOIN cvl.spatialformat USING (spatialformatid)
     GROUP BY productspatialformat.productid) sf USING (productid)
LEFT JOIN
    (SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
     FROM productepsg
     GROUP BY productepsg.productid) ep USING (productid)
LEFT JOIN
    (SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
     FROM productwkt
     GROUP BY productwkt.productid) wkt USING (productid)
LEFT JOIN
    (SELECT f.productid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.type, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.productid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT productpoint.productid,
                      'point-'::text || productpoint.productpointid AS id,
                                        productpoint.name,
                                        productpoint.comment,
                                        productpoint.the_geom
               FROM productpoint
               UNION SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                                                productpolygon.name,
                                                productpolygon.comment,
                                                productpolygon.the_geom
               FROM productpolygon
               UNION SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                                             productline.name,
                                             productline.comment,
                                             productline.the_geom
               FROM productline) lg) f
     GROUP BY f.productid) fea USING (productid);

 -- View: absi.metadataproject
 -- DROP VIEW absi.metadataproject;

CREATE OR REPLACE VIEW absi.metadataproject AS WITH gschema AS
    ( SELECT groupschema.groupschemaid,
             groupschema.groupid,
             groupschema.displayname,
             groupschema.deliverablecalendarid,
             groupschema.projecturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE)) )
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
       format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double PRECISION, '999909'::text))) AS uri,

    (SELECT m.datecreated
     FROM modification m
     WHERE m.projectid = project.projectid
     ORDER BY m.datecreated LIMIT 1) AS datecreated,
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
JOIN cvl.status ON status.statusid = common.project_status(project.projectid)
LEFT JOIN
    (SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT projectkeyword_1.projectid,
                 keyword.preflabel
          FROM projectkeyword projectkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY projectkeyword_1.projectid,
                   keyword.preflabel) projectkeyword
     GROUP BY projectkeyword.projectid) kw USING (projectid)
LEFT JOIN
    (SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
     FROM projectusertype
     JOIN cvl.usertype USING (usertypeid)
     GROUP BY projectusertype.projectid) ut USING (projectid)
LEFT JOIN
    (SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM projecttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY projecttopiccategory.projectid) tc USING (projectid)
LEFT JOIN
    (SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
     FROM projectprojectcategory
     JOIN cvl.projectcategory USING (projectcategoryid)
     GROUP BY projectprojectcategory.projectid) pc USING (projectid)
LEFT JOIN
    (SELECT f.projectid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.TYPE, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.projectid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT projectpoint.projectid,
                      'point-'::text || projectpoint.projectpointid AS id,
                                        projectpoint.name,
                                        projectpoint.comment,
                                        projectpoint.the_geom
               FROM projectpoint
               UNION SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                                                projectpolygon.name,
                                                projectpolygon.comment,
                                                projectpolygon.the_geom
               FROM projectpolygon
               UNION SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                                             projectline.name,
                                             projectline.comment,
                                             projectline.the_geom
               FROM projectline) lg) f
     GROUP BY f.projectid) fea USING (projectid);

---- Schema: nwb ----


---- File: 001-projectawardinfo.sql ----

SET search_path TO nwb, public;

CREATE OR REPLACE VIEW nwb.projectawardinfo AS
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
---- File: 002-sciencebaseid.sql ----

SET search_path TO nwb, public;

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
FROM
    (SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE))) gschema,
                                                                           product
LEFT JOIN project USING (projectid)
JOIN cvl.deliverabletype USING (deliverabletypeid)
LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid)
LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid)
LEFT JOIN
    (SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT productkeyword_1.productid,
                 keyword.preflabel
          FROM productkeyword productkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY productkeyword_1.productid,
                   keyword.preflabel) productkeyword
     GROUP BY productkeyword.productid) kw USING (productid)
LEFT JOIN
    (SELECT producttopiccategory.productid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM producttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY producttopiccategory.productid) tc USING (productid)
LEFT JOIN
    (SELECT productspatialformat.productid,
            string_agg(spatialformat.codename::text, '|'::text) AS spatialformat
     FROM productspatialformat
     JOIN cvl.spatialformat USING (spatialformatid)
     GROUP BY productspatialformat.productid) sf USING (productid)
LEFT JOIN
    (SELECT productepsg.productid,
            string_agg(productepsg.srid::text, '|'::text) AS epsgcode
     FROM productepsg
     GROUP BY productepsg.productid) ep USING (productid)
LEFT JOIN
    (SELECT productwkt.productid,
            string_agg(productwkt.wkt::text, '|'::text) AS wkt
     FROM productwkt
     GROUP BY productwkt.productid) wkt USING (productid)
LEFT JOIN
    (SELECT f.productid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.type, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.productid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT productpoint.productid,
                      'point-'::text || productpoint.productpointid AS id,
                                        productpoint.name,
                                        productpoint.comment,
                                        productpoint.the_geom
               FROM productpoint
               UNION SELECT productpolygon.productid,
                            'polygon-'::text || productpolygon.productpolygonid AS id,
                                                productpolygon.name,
                                                productpolygon.comment,
                                                productpolygon.the_geom
               FROM productpolygon
               UNION SELECT productline.productid,
                            'line-'::text || productline.productlineid AS id,
                                             productline.name,
                                             productline.comment,
                                             productline.the_geom
               FROM productline) lg) f
     GROUP BY f.productid) fea USING (productid);

 -- View: nwb.metadataproject
 -- DROP VIEW nwb.metadataproject;

CREATE OR REPLACE VIEW nwb.metadataproject AS WITH gschema AS
    ( SELECT groupschema.groupschemaid,
             groupschema.groupid,
             groupschema.displayname,
             groupschema.deliverablecalendarid,
             groupschema.projecturiformat
     FROM common.groupschema
     WHERE groupschema.groupschemaid::name = ANY (current_schemas(FALSE)) )
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
       format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double PRECISION, '999909'::text))) AS uri,

    (SELECT m.datecreated
     FROM modification m
     WHERE m.projectid = project.projectid
     ORDER BY m.datecreated LIMIT 1) AS datecreated,
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
JOIN cvl.status ON status.statusid = common.project_status(project.projectid)
LEFT JOIN
    (SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
     FROM
         (SELECT projectkeyword_1.projectid,
                 keyword.preflabel
          FROM projectkeyword projectkeyword_1
          JOIN gcmd.keyword USING (keywordid)
          GROUP BY projectkeyword_1.projectid,
                   keyword.preflabel) projectkeyword
     GROUP BY projectkeyword.projectid) kw USING (projectid)
LEFT JOIN
    (SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
     FROM projectusertype
     JOIN cvl.usertype USING (usertypeid)
     GROUP BY projectusertype.projectid) ut USING (projectid)
LEFT JOIN
    (SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
     FROM projecttopiccategory
     JOIN cvl.topiccategory USING (topiccategoryid)
     GROUP BY projecttopiccategory.projectid) tc USING (projectid)
LEFT JOIN
    (SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
     FROM projectprojectcategory
     JOIN cvl.projectcategory USING (projectcategoryid)
     GROUP BY projectprojectcategory.projectid) pc USING (projectid)
LEFT JOIN
    (SELECT f.projectid,
            array_to_json(array_agg(
                                        (SELECT fj.*::record AS fj
                                         FROM
                                             (SELECT f.TYPE, f.id, f.geometry, f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
     FROM
         (SELECT lg.projectid,
                 lg.the_geom,
                 'Feature' AS TYPE,
                 lg.id,
                 st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                 row_to_json(
                                 (SELECT l.*::record AS l
                                  FROM
                                      (SELECT COALESCE(lg.name, ''::character varying) AS "featureName", COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
          FROM
              (SELECT projectpoint.projectid,
                      'point-'::text || projectpoint.projectpointid AS id,
                                        projectpoint.name,
                                        projectpoint.comment,
                                        projectpoint.the_geom
               FROM projectpoint
               UNION SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                                                projectpolygon.name,
                                                projectpolygon.comment,
                                                projectpolygon.the_geom
               FROM projectpolygon
               UNION SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                                             projectline.name,
                                             projectline.comment,
                                             projectline.the_geom
               FROM projectline) lg) f
     GROUP BY f.projectid) fea USING (projectid);

