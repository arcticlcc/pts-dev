-- Column: metadataupdate

DROP VIEW dev.metadataproduct;
ALTER TABLE dev.product ALTER COLUMN metadataupdate SET DATA TYPE timestamp with time zone;
-- View: dev.metadataproduct

-- DROP VIEW dev.metadataproduct;

CREATE OR REPLACE VIEW dev.metadataproduct AS 
 SELECT product.productid,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
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
    wkt.wkt
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))) gschema,
    product
     JOIN project USING (projectid)
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg(productkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM productkeyword productkeyword_1
                     JOIN keyword USING (keywordid)
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
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
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
GRANT SELECT ON TABLE dev.metadataproduct TO pts_read;
GRANT ALL ON TABLE dev.metadataproduct TO pts_admin;


DROP VIEW dev.metadataproject;
ALTER TABLE dev.project ALTER COLUMN metadataupdate SET DATA TYPE timestamp with time zone;

-- View: dev.metadataproject

-- DROP VIEW dev.metadataproject;

CREATE OR REPLACE VIEW dev.metadataproject AS 
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
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
    project.metadataupdate
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN keyword USING (keywordid)
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
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
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
GRANT SELECT ON TABLE dev.metadataproject TO pts_read;
GRANT ALL ON TABLE dev.metadataproject TO pts_admin;

