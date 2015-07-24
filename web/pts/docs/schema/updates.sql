-- Version 0.17.0

-- Sequence: cvl.spatialformat_spatialformatid_seq

-- DROP SEQUENCE cvl.spatialformat_spatialformatid_seq;

CREATE SEQUENCE cvl.spatialformat_spatialformatid_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 6
  CACHE 1;
ALTER TABLE cvl.spatialformat_spatialformatid_seq
  OWNER TO bradley;

-- Table: cvl.spatialformat

-- DROP TABLE cvl.spatialformat;

CREATE TABLE cvl.spatialformat
(
  spatialformatid integer NOT NULL DEFAULT nextval('spatialformat_spatialformatid_seq'::regclass),
  code character varying NOT NULL,
  codename character varying NOT NULL,
  description character varying NOT NULL,
  CONSTRAINT spatialformat_pk PRIMARY KEY (spatialformatid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.spatialformat
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.spatialformat TO bradley;
GRANT SELECT ON TABLE cvl.spatialformat TO pts_read;
COMMENT ON TABLE cvl.spatialformat
  IS 'List of spatial types, corresponds to ADIwg mdCodes types(https://github.com/adiwg/mdCodes/blob/master/resources/iso_spatialRepresentation.yml)';


-- View: cvl.epsg

-- DROP VIEW cvl.epsg;

CREATE OR REPLACE VIEW cvl.epsg AS
 SELECT spatial_ref_sys.auth_srid AS srid,
    "substring"(spatial_ref_sys.srtext::text, '[A-Z]+?\[\"(.*?)\"'::text) AS name,
    spatial_ref_sys.auth_srid::text AS srid_text
   FROM spatial_ref_sys
  WHERE spatial_ref_sys.auth_name::text = 'EPSG'::text;

ALTER TABLE cvl.epsg
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.epsg TO bradley;
GRANT SELECT ON TABLE cvl.epsg TO pts_read;

SET search_path = cvl, pg_catalog;

ALTER SEQUENCE spatialformat_spatialformatid_seq
	OWNED BY spatialformat.spatialformatid;

SET search_path = dev, pg_catalog;

CREATE TABLE productepsg (
	productid integer NOT NULL,
	srid integer NOT NULL
);

CREATE TABLE productspatialformat (
	productid integer NOT NULL,
	spatialformatid integer NOT NULL
);

CREATE TABLE productwkt (
	productid integer NOT NULL,
	wkt character varying NOT NULL
);

ALTER TABLE productepsg
	ADD CONSTRAINT productepsg_pk PRIMARY KEY (productid, srid);

ALTER TABLE productspatialformat
	ADD CONSTRAINT productspatialformat_pk PRIMARY KEY (productid, spatialformatid);

ALTER TABLE productepsg
	ADD CONSTRAINT epsg_productepsg_fk FOREIGN KEY (srid) REFERENCES public.spatial_ref_sys(srid);

ALTER TABLE productepsg
	ADD CONSTRAINT product_productepsg_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productspatialformat
	ADD CONSTRAINT product_productspatialformat_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productspatialformat
	ADD CONSTRAINT spatialformat_productspatialformat_fk FOREIGN KEY (spatialformatid) REFERENCES cvl.spatialformat(spatialformatid);

ALTER TABLE productwkt
	ADD CONSTRAINT product_productwkt_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

REVOKE ALL ON TABLE productepsg FROM PUBLIC;
REVOKE ALL ON TABLE productepsg FROM bradley;
GRANT ALL ON TABLE productepsg TO bradley;
GRANT SELECT ON TABLE productepsg TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productepsg TO pts_write;

REVOKE ALL ON TABLE productspatialformat FROM PUBLIC;
REVOKE ALL ON TABLE productspatialformat FROM bradley;
GRANT ALL ON TABLE productspatialformat TO bradley;
GRANT SELECT ON TABLE productspatialformat TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productspatialformat TO pts_write;

REVOKE ALL ON TABLE productwkt FROM PUBLIC;
REVOKE ALL ON TABLE productwkt FROM bradley;
GRANT ALL ON TABLE productwkt TO bradley;
GRANT SELECT ON TABLE productwkt TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productwkt TO pts_write;


CREATE OR REPLACE VIEW metadataproduct AS
	SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.producturiformat)::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN (fea.features IS NOT NULL) THEN to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)])
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
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    ((((((((((product
     JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg((productkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM (productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid))
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (producttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((spatialformat.codename)::text, '|'::text) AS spatialformat
           FROM (productspatialformat
             JOIN cvl.spatialformat USING (spatialformatid))
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid))
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            ('point-'::text || productpoint.productpointid) AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            ('polygon-'::text || productpolygon.productpolygonid) AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            ('line-'::text || productline.productlineid) AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid));

CREATE OR REPLACE VIEW productmetadata AS
	SELECT product.productid,
    tc.topiccategory,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt
   FROM ((((product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((productspatialformat.spatialformatid)::text, ','::text) AS spatialformat
           FROM productspatialformat
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, ','::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '
|
'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid));

--alcc
SET search_path = alcc, pg_catalog;

CREATE TABLE productepsg (
	productid integer NOT NULL,
	srid integer NOT NULL
);

CREATE TABLE productspatialformat (
	productid integer NOT NULL,
	spatialformatid integer NOT NULL
);

CREATE TABLE productwkt (
	productid integer NOT NULL,
	wkt character varying NOT NULL
);

ALTER TABLE productepsg
	ADD CONSTRAINT productepsg_pk PRIMARY KEY (productid, srid);

ALTER TABLE productspatialformat
	ADD CONSTRAINT productspatialformat_pk PRIMARY KEY (productid, spatialformatid);

ALTER TABLE productepsg
	ADD CONSTRAINT epsg_productepsg_fk FOREIGN KEY (srid) REFERENCES public.spatial_ref_sys(srid);

ALTER TABLE productepsg
	ADD CONSTRAINT product_productepsg_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productspatialformat
	ADD CONSTRAINT product_productspatialformat_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productspatialformat
	ADD CONSTRAINT spatialformat_productspatialformat_fk FOREIGN KEY (spatialformatid) REFERENCES cvl.spatialformat(spatialformatid);

ALTER TABLE productwkt
	ADD CONSTRAINT product_productwkt_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

REVOKE ALL ON TABLE productepsg FROM PUBLIC;
REVOKE ALL ON TABLE productepsg FROM bradley;
GRANT ALL ON TABLE productepsg TO bradley;
GRANT SELECT ON TABLE productepsg TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productepsg TO pts_write;

REVOKE ALL ON TABLE productspatialformat FROM PUBLIC;
REVOKE ALL ON TABLE productspatialformat FROM bradley;
GRANT ALL ON TABLE productspatialformat TO bradley;
GRANT SELECT ON TABLE productspatialformat TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productspatialformat TO pts_write;

REVOKE ALL ON TABLE productwkt FROM PUBLIC;
REVOKE ALL ON TABLE productwkt FROM bradley;
GRANT ALL ON TABLE productwkt TO bradley;
GRANT SELECT ON TABLE productwkt TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productwkt TO pts_write;


CREATE OR REPLACE VIEW metadataproduct AS
	SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.producturiformat)::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN (fea.features IS NOT NULL) THEN to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)])
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
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    ((((((((((product
     JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg((productkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM (productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid))
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (producttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((spatialformat.codename)::text, '|'::text) AS spatialformat
           FROM (productspatialformat
             JOIN cvl.spatialformat USING (spatialformatid))
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid))
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            ('point-'::text || productpoint.productpointid) AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            ('polygon-'::text || productpolygon.productpolygonid) AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            ('line-'::text || productline.productlineid) AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid));

CREATE OR REPLACE VIEW productmetadata AS
	SELECT product.productid,
    tc.topiccategory,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt
   FROM ((((product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((productspatialformat.spatialformatid)::text, ','::text) AS spatialformat
           FROM productspatialformat
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, ','::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '
|
'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid));

--walcc
SET search_path = walcc, pg_catalog;

CREATE TABLE productepsg (
	productid integer NOT NULL,
	srid integer NOT NULL
);

CREATE TABLE productspatialformat (
	productid integer NOT NULL,
	spatialformatid integer NOT NULL
);

CREATE TABLE productwkt (
	productid integer NOT NULL,
	wkt character varying NOT NULL
);

ALTER TABLE productepsg
	ADD CONSTRAINT productepsg_pk PRIMARY KEY (productid, srid);

ALTER TABLE productspatialformat
	ADD CONSTRAINT productspatialformat_pk PRIMARY KEY (productid, spatialformatid);

ALTER TABLE productepsg
	ADD CONSTRAINT epsg_productepsg_fk FOREIGN KEY (srid) REFERENCES public.spatial_ref_sys(srid);

ALTER TABLE productepsg
	ADD CONSTRAINT product_productepsg_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productspatialformat
	ADD CONSTRAINT product_productspatialformat_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productspatialformat
	ADD CONSTRAINT spatialformat_productspatialformat_fk FOREIGN KEY (spatialformatid) REFERENCES cvl.spatialformat(spatialformatid);

ALTER TABLE productwkt
	ADD CONSTRAINT product_productwkt_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

REVOKE ALL ON TABLE productepsg FROM PUBLIC;
REVOKE ALL ON TABLE productepsg FROM bradley;
GRANT ALL ON TABLE productepsg TO bradley;
GRANT SELECT ON TABLE productepsg TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productepsg TO pts_write;

REVOKE ALL ON TABLE productspatialformat FROM PUBLIC;
REVOKE ALL ON TABLE productspatialformat FROM bradley;
GRANT ALL ON TABLE productspatialformat TO bradley;
GRANT SELECT ON TABLE productspatialformat TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productspatialformat TO pts_write;

REVOKE ALL ON TABLE productwkt FROM PUBLIC;
REVOKE ALL ON TABLE productwkt FROM bradley;
GRANT ALL ON TABLE productwkt TO bradley;
GRANT SELECT ON TABLE productwkt TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE productwkt TO pts_write;


CREATE OR REPLACE VIEW metadataproduct AS
	SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.producturiformat)::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN (fea.features IS NOT NULL) THEN to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)])
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
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    ((((((((((product
     JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg((productkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM (productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid))
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (producttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((spatialformat.codename)::text, '|'::text) AS spatialformat
           FROM (productspatialformat
             JOIN cvl.spatialformat USING (spatialformatid))
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid))
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            ('point-'::text || productpoint.productpointid) AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            ('polygon-'::text || productpolygon.productpolygonid) AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            ('line-'::text || productline.productlineid) AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid));

CREATE OR REPLACE VIEW productmetadata AS
	SELECT product.productid,
    tc.topiccategory,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt
   FROM ((((product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((productspatialformat.spatialformatid)::text, ','::text) AS spatialformat
           FROM productspatialformat
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, ','::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '
|
'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid));
