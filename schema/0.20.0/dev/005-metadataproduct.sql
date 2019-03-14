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
