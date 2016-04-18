Begin;

---- System ----


SET search_path TO '';

---- File: 001-mf.sql ----


--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.5
-- Dumped by pg_dump version 9.4.5
-- Started on 2016-04-12 14:04:58 AKDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = cvl, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 899 (class 1259 OID 82152)
-- Name: maintenancefrequency; Type: TABLE; Schema: cvl; Owner: bradley; Tablespace:
--

CREATE TABLE maintenancefrequency (
    maintenancefrequencyid integer NOT NULL,
    code character varying NOT NULL,
    codename character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE maintenancefrequency OWNER TO bradley;

--
-- TOC entry 5881 (class 0 OID 0)
-- Dependencies: 899
-- Name: TABLE maintenancefrequency; Type: COMMENT; Schema: cvl; Owner: bradley
--

COMMENT ON TABLE maintenancefrequency IS 'maintenance frequency intervals';


--
-- TOC entry 5882 (class 0 OID 0)
-- Dependencies: 899
-- Name: COLUMN maintenancefrequency.code; Type: COMMENT; Schema: cvl; Owner: bradley
--

COMMENT ON COLUMN maintenancefrequency.code IS 'code for maintenancefrequency';


--
-- TOC entry 898 (class 1259 OID 82150)
-- Name: maintenancefrequency_maintenancefrequencyid_seq; Type: SEQUENCE; Schema: cvl; Owner: bradley
--

CREATE SEQUENCE maintenancefrequency_maintenancefrequencyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maintenancefrequency_maintenancefrequencyid_seq OWNER TO bradley;

--
-- TOC entry 5884 (class 0 OID 0)
-- Dependencies: 898
-- Name: maintenancefrequency_maintenancefrequencyid_seq; Type: SEQUENCE OWNED BY; Schema: cvl; Owner: bradley
--

ALTER SEQUENCE maintenancefrequency_maintenancefrequencyid_seq OWNED BY maintenancefrequency.maintenancefrequencyid;


--
-- TOC entry 5472 (class 2604 OID 82155)
-- Name: maintenancefrequencyid; Type: DEFAULT; Schema: cvl; Owner: bradley
--

ALTER TABLE ONLY maintenancefrequency ALTER COLUMN maintenancefrequencyid SET DEFAULT nextval('maintenancefrequency_maintenancefrequencyid_seq'::regclass);


--
-- TOC entry 5876 (class 0 OID 82152)
-- Dependencies: 899
-- Data for Name: maintenancefrequency; Type: TABLE DATA; Schema: cvl; Owner: bradley
--

INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (1, '001', 'continual', 'data is repeatedly and frequently updated');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (2, '002', 'daily', 'data is updated each day');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (3, '003', 'weekly', 'data is updated on a weekly basis');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (4, '004', 'fortnightly', 'data is updated every two weeks');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (5, '005', 'monthly', 'data is updated each month');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (6, '006', 'quarterly', 'data is updated every three months');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (7, '007', 'biannually', 'data is updated twice each year');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (8, '008', 'annually', 'data is updated every year');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (9, '009', 'asNeeded', 'data is updated as deemed necessary');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (10, '010', 'irregular', 'data is updated in intervals that are uneven in duration');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (11, '011', 'notPlanned', 'there are no plans to update the data');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (12, '012', 'unknown', 'frequency of maintenance for the data is not known');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (13, '013', 'periodic', 'resource is updated at regular intervals');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (14, '014', 'semimonthly', 'resource updated twice monthly');
INSERT INTO maintenancefrequency (maintenancefrequencyid, code, codename, description) VALUES (15, '015', 'biennially', 'resource is updated every 2 years');


--
-- TOC entry 5885 (class 0 OID 0)
-- Dependencies: 898
-- Name: maintenancefrequency_maintenancefrequencyid_seq; Type: SEQUENCE SET; Schema: cvl; Owner: bradley
--

SELECT pg_catalog.setval('maintenancefrequency_maintenancefrequencyid_seq', 15, true);


--
-- TOC entry 5474 (class 2606 OID 82160)
-- Name: maintenancefrequency_pk; Type: CONSTRAINT; Schema: cvl; Owner: bradley; Tablespace:
--

ALTER TABLE ONLY maintenancefrequency
    ADD CONSTRAINT maintenancefrequency_pk PRIMARY KEY (maintenancefrequencyid);


--
-- TOC entry 5883 (class 0 OID 0)
-- Dependencies: 899
-- Name: maintenancefrequency; Type: ACL; Schema: cvl; Owner: bradley
--

REVOKE ALL ON TABLE maintenancefrequency FROM PUBLIC;
REVOKE ALL ON TABLE maintenancefrequency FROM bradley;
GRANT ALL ON TABLE maintenancefrequency TO bradley;
GRANT SELECT ON TABLE maintenancefrequency TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maintenancefrequency TO pts_write;
GRANT ALL ON TABLE maintenancefrequency TO pts_admin;


-- Completed on 2016-04-12 14:04:58 AKDT

--
-- PostgreSQL database dump complete
--

SET search_path TO '';

---- File: 002-productstepsq.sql ----


-- Sequence: common.productstep_productstepid_seq

-- DROP SEQUENCE common.productstep_productstepid_seq;

CREATE SEQUENCE common.productstep_productstepid_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE common.productstep_productstepid_seq
  OWNER TO bradley;
  GRANT SELECT, UPDATE ON SEQUENCE common.productstep_productstepid_seq TO pts_write;

SET search_path TO '';

---- Schema: dev ----


---- File: 001-productgroup.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN dev.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE dev.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES dev.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON dev.product(productgroupid);

-- Column: isgroup

-- ALTER TABLE dev.product DROP COLUMN isgroup;

ALTER TABLE dev.product ADD COLUMN isgroup boolean;
UPDATE dev.product
   SET
       isgroup=false
 WHERE isgroup IS NULL;
ALTER TABLE dev.product ALTER COLUMN isgroup SET NOT NULL;
ALTER TABLE dev.product ALTER COLUMN isgroup SET DEFAULT false;
COMMENT ON COLUMN dev.product.isgroup IS 'Identifies whether the item is a product group.';
---- File: 002-uselimitation.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.product
   ADD COLUMN uselimitation character varying;
COMMENT ON COLUMN dev.product.uselimitation
  IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';
---- File: 003-productgrouplist.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.product
   ALTER COLUMN projectid DROP NOT NULL;

   -- View: dev.productgrouplist

   -- DROP VIEW dev.productgrouplist;

   CREATE OR REPLACE VIEW dev.productgrouplist AS
    SELECT p.productid,
       p.projectid,
       common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
       p.uuid,
       p.title,
       p.isgroup,
       p.productgroupid
      FROM product p
        left JOIN project USING (projectid)
        left JOIN contactgroup ON project.orgid = contactgroup.contactid
        where isgroup;

   ALTER TABLE dev.productgrouplist
     OWNER TO bradley;
   GRANT ALL ON TABLE dev.productgrouplist TO bradley;
   GRANT SELECT ON TABLE dev.productgrouplist TO pts_read;
   GRANT ALL ON TABLE dev.productgrouplist TO pts_admin;
---- File: 004-product.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN dev.product.perioddescription
  IS 'Description of the time period';

ALTER TABLE dev.product
 ADD COLUMN maintenancefrequencyid integer;
ALTER TABLE dev.product
 ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency (maintenancefrequencyid)
  ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX fki_maintenancefrequency_product_fk
 ON dev.product(maintenancefrequencyid);

 -- Column: orgid

-- ALTER TABLE dev.product DROP COLUMN orgid;

ALTER TABLE dev.product ADD COLUMN orgid integer;
UPDATE dev.product SET orgid = ( SELECT groupschema.groupid
          FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false))));
ALTER TABLE dev.product ALTER COLUMN orgid SET NOT NULL;
COMMENT ON COLUMN dev.product.orgid IS 'Identifies organization that owns the product';
---- File: 005-productlist.sql ----

SET search_path TO dev, public;

-- View: dev.productlist

-- DROP VIEW dev.productlist;

CREATE OR REPLACE VIEW dev.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid
   FROM dev.product p
     left JOIN dev.project USING (projectid)
     left JOIN dev.contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN dev.product pg ON p.productgroupid = pg.productid;
---- File: 006-productstep.sql ----

SET search_path TO dev, public;

-- Table: dev.productstep

-- DROP TABLE dev.productstep;

CREATE TABLE dev.productstep
(
  productstepid integer NOT NULL DEFAULT nextval('common.productstep_productstepid_seq'::regclass),
  productid integer NOT NULL, -- PK for PRODUCT
  productcontactid integer NOT NULL,
  description character varying NOT NULL,
  rationale character varying, -- Requirement or purpose for the process step.
  stepdate date NOT NULL, -- Date and time or date at which the process step occurred.
  priority integer NOT NULL DEFAULT 0, -- Order of the step
  CONSTRAINT productstep_pk PRIMARY KEY (productstepid),
  CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid)
        REFERENCES dev.productcontact (productcontactid) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT product_productstep_fk FOREIGN KEY (productid)
      REFERENCES dev.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE dev.productstep
  OWNER TO bradley;
GRANT ALL ON TABLE dev.productstep TO bradley;
GRANT SELECT ON TABLE dev.productstep TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productstep TO pts_write;
GRANT ALL ON TABLE dev.productstep TO pts_admin;
COMMENT ON TABLE dev.productstep
  IS 'Identifies the steps taken when during processing of the product.';
COMMENT ON COLUMN dev.productstep.productid IS 'PK for PRODUCT';
COMMENT ON COLUMN dev.productstep.rationale IS 'Requirement or purpose for the process step.';
COMMENT ON COLUMN dev.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';
COMMENT ON COLUMN dev.productstep.priority IS 'Order of the step';
---- File: 007-metadataproduct.sql ----

SET search_path TO dev, public;

CREATE OR REPLACE VIEW metadataproduct AS
 SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((product
     LEFT JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

---- Schema: alcc ----


---- File: 001-productgroup.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN alcc.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE alcc.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES alcc.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON alcc.product(productgroupid);

-- Column: isgroup

-- ALTER TABLE alcc.product DROP COLUMN isgroup;

ALTER TABLE alcc.product ADD COLUMN isgroup boolean;
UPDATE alcc.product
   SET
       isgroup=false
 WHERE isgroup IS NULL;
ALTER TABLE alcc.product ALTER COLUMN isgroup SET NOT NULL;
ALTER TABLE alcc.product ALTER COLUMN isgroup SET DEFAULT false;
COMMENT ON COLUMN alcc.product.isgroup IS 'Identifies whether the item is a product group.';
---- File: 002-uselimitation.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.product
   ADD COLUMN uselimitation character varying;
COMMENT ON COLUMN alcc.product.uselimitation
  IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';
---- File: 003-productgrouplist.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.product
   ALTER COLUMN projectid DROP NOT NULL;

   -- View: alcc.productgrouplist

   -- DROP VIEW alcc.productgrouplist;

   CREATE OR REPLACE VIEW alcc.productgrouplist AS
    SELECT p.productid,
       p.projectid,
       common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
       p.uuid,
       p.title,
       p.isgroup,
       p.productgroupid
      FROM product p
        left JOIN project USING (projectid)
        left JOIN contactgroup ON project.orgid = contactgroup.contactid
        where isgroup;

   ALTER TABLE alcc.productgrouplist
     OWNER TO bradley;
   GRANT ALL ON TABLE alcc.productgrouplist TO bradley;
   GRANT SELECT ON TABLE alcc.productgrouplist TO pts_read;
   GRANT ALL ON TABLE alcc.productgrouplist TO pts_admin;
---- File: 004-product.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN alcc.product.perioddescription
  IS 'Description of the time period';

ALTER TABLE alcc.product
 ADD COLUMN maintenancefrequencyid integer;
ALTER TABLE alcc.product
 ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency (maintenancefrequencyid)
  ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX fki_maintenancefrequency_product_fk
 ON alcc.product(maintenancefrequencyid);

 -- Column: orgid

-- ALTER TABLE alcc.product DROP COLUMN orgid;

ALTER TABLE alcc.product ADD COLUMN orgid integer;
UPDATE alcc.product SET orgid = ( SELECT groupschema.groupid
          FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false))));
ALTER TABLE alcc.product ALTER COLUMN orgid SET NOT NULL;
COMMENT ON COLUMN alcc.product.orgid IS 'Identifies organization that owns the product';
---- File: 005-productlist.sql ----

SET search_path TO alcc, public;

-- View: alcc.productlist

-- DROP VIEW alcc.productlist;

CREATE OR REPLACE VIEW alcc.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid
   FROM alcc.product p
     left JOIN alcc.project USING (projectid)
     left JOIN alcc.contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN alcc.product pg ON p.productgroupid = pg.productid;
---- File: 006-productstep.sql ----

SET search_path TO alcc, public;

-- Table: alcc.productstep

-- DROP TABLE alcc.productstep;

CREATE TABLE alcc.productstep
(
  productstepid integer NOT NULL DEFAULT nextval('common.productstep_productstepid_seq'::regclass),
  productid integer NOT NULL, -- PK for PRODUCT
  productcontactid integer NOT NULL,
  description character varying NOT NULL,
  rationale character varying, -- Requirement or purpose for the process step.
  stepdate date NOT NULL, -- Date and time or date at which the process step occurred.
  priority integer NOT NULL DEFAULT 0, -- Order of the step
  CONSTRAINT productstep_pk PRIMARY KEY (productstepid),
  CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid)
        REFERENCES alcc.productcontact (productcontactid) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT product_productstep_fk FOREIGN KEY (productid)
      REFERENCES alcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE alcc.productstep
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.productstep TO bradley;
GRANT SELECT ON TABLE alcc.productstep TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productstep TO pts_write;
GRANT ALL ON TABLE alcc.productstep TO pts_admin;
COMMENT ON TABLE alcc.productstep
  IS 'Identifies the steps taken when during processing of the product.';
COMMENT ON COLUMN alcc.productstep.productid IS 'PK for PRODUCT';
COMMENT ON COLUMN alcc.productstep.rationale IS 'Requirement or purpose for the process step.';
COMMENT ON COLUMN alcc.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';
COMMENT ON COLUMN alcc.productstep.priority IS 'Order of the step';
---- File: 007-metadataproduct.sql ----

SET search_path TO alcc, public;

CREATE OR REPLACE VIEW metadataproduct AS
 SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((product
     LEFT JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

---- Schema: walcc ----


---- File: 001-productgroup.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN walcc.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE walcc.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES walcc.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON walcc.product(productgroupid);

-- Column: isgroup

-- ALTER TABLE walcc.product DROP COLUMN isgroup;

ALTER TABLE walcc.product ADD COLUMN isgroup boolean;
UPDATE walcc.product
   SET
       isgroup=false
 WHERE isgroup IS NULL;
ALTER TABLE walcc.product ALTER COLUMN isgroup SET NOT NULL;
ALTER TABLE walcc.product ALTER COLUMN isgroup SET DEFAULT false;
COMMENT ON COLUMN walcc.product.isgroup IS 'Identifies whether the item is a product group.';
---- File: 002-uselimitation.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.product
   ADD COLUMN uselimitation character varying;
COMMENT ON COLUMN walcc.product.uselimitation
  IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';
---- File: 003-productgrouplist.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.product
   ALTER COLUMN projectid DROP NOT NULL;

   -- View: walcc.productgrouplist

   -- DROP VIEW walcc.productgrouplist;

   CREATE OR REPLACE VIEW walcc.productgrouplist AS
    SELECT p.productid,
       p.projectid,
       common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
       p.uuid,
       p.title,
       p.isgroup,
       p.productgroupid
      FROM product p
        left JOIN project USING (projectid)
        left JOIN contactgroup ON project.orgid = contactgroup.contactid
        where isgroup;

   ALTER TABLE walcc.productgrouplist
     OWNER TO bradley;
   GRANT ALL ON TABLE walcc.productgrouplist TO bradley;
   GRANT SELECT ON TABLE walcc.productgrouplist TO pts_read;
   GRANT ALL ON TABLE walcc.productgrouplist TO pts_admin;
---- File: 004-product.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN walcc.product.perioddescription
  IS 'Description of the time period';

ALTER TABLE walcc.product
 ADD COLUMN maintenancefrequencyid integer;
ALTER TABLE walcc.product
 ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency (maintenancefrequencyid)
  ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX fki_maintenancefrequency_product_fk
 ON walcc.product(maintenancefrequencyid);

 -- Column: orgid

-- ALTER TABLE walcc.product DROP COLUMN orgid;

ALTER TABLE walcc.product ADD COLUMN orgid integer;
UPDATE walcc.product SET orgid = ( SELECT groupschema.groupid
          FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false))));
ALTER TABLE walcc.product ALTER COLUMN orgid SET NOT NULL;
COMMENT ON COLUMN walcc.product.orgid IS 'Identifies organization that owns the product';
---- File: 005-productlist.sql ----

SET search_path TO walcc, public;

-- View: walcc.productlist

-- DROP VIEW walcc.productlist;

CREATE OR REPLACE VIEW walcc.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid
   FROM walcc.product p
     left JOIN walcc.project USING (projectid)
     left JOIN walcc.contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN walcc.product pg ON p.productgroupid = pg.productid;
---- File: 006-productstep.sql ----

SET search_path TO walcc, public;

-- Table: walcc.productstep

-- DROP TABLE walcc.productstep;

CREATE TABLE walcc.productstep
(
  productstepid integer NOT NULL DEFAULT nextval('common.productstep_productstepid_seq'::regclass),
  productid integer NOT NULL, -- PK for PRODUCT
  productcontactid integer NOT NULL,
  description character varying NOT NULL,
  rationale character varying, -- Requirement or purpose for the process step.
  stepdate date NOT NULL, -- Date and time or date at which the process step occurred.
  priority integer NOT NULL DEFAULT 0, -- Order of the step
  CONSTRAINT productstep_pk PRIMARY KEY (productstepid),
  CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid)
        REFERENCES walcc.productcontact (productcontactid) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT product_productstep_fk FOREIGN KEY (productid)
      REFERENCES walcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE walcc.productstep
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.productstep TO bradley;
GRANT SELECT ON TABLE walcc.productstep TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productstep TO pts_write;
GRANT ALL ON TABLE walcc.productstep TO pts_admin;
COMMENT ON TABLE walcc.productstep
  IS 'Identifies the steps taken when during processing of the product.';
COMMENT ON COLUMN walcc.productstep.productid IS 'PK for PRODUCT';
COMMENT ON COLUMN walcc.productstep.rationale IS 'Requirement or purpose for the process step.';
COMMENT ON COLUMN walcc.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';
COMMENT ON COLUMN walcc.productstep.priority IS 'Order of the step';
---- File: 007-metadataproduct.sql ----

SET search_path TO walcc, public;

CREATE OR REPLACE VIEW metadataproduct AS
 SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((product
     LEFT JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

---- Schema: absi ----


---- File: 001-productgroup.sql ----

SET search_path TO absi, public;

ALTER TABLE absi.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN absi.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE absi.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES absi.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON absi.product(productgroupid);

-- Column: isgroup

-- ALTER TABLE absi.product DROP COLUMN isgroup;

ALTER TABLE absi.product ADD COLUMN isgroup boolean;
UPDATE absi.product
   SET
       isgroup=false
 WHERE isgroup IS NULL;
ALTER TABLE absi.product ALTER COLUMN isgroup SET NOT NULL;
ALTER TABLE absi.product ALTER COLUMN isgroup SET DEFAULT false;
COMMENT ON COLUMN absi.product.isgroup IS 'Identifies whether the item is a product group.';
---- File: 002-uselimitation.sql ----

SET search_path TO absi, public;

ALTER TABLE absi.product
   ADD COLUMN uselimitation character varying;
COMMENT ON COLUMN absi.product.uselimitation
  IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';
---- File: 003-productgrouplist.sql ----

SET search_path TO absi, public;

ALTER TABLE absi.product
   ALTER COLUMN projectid DROP NOT NULL;

   -- View: absi.productgrouplist

   -- DROP VIEW absi.productgrouplist;

   CREATE OR REPLACE VIEW absi.productgrouplist AS
    SELECT p.productid,
       p.projectid,
       common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
       p.uuid,
       p.title,
       p.isgroup,
       p.productgroupid
      FROM product p
        left JOIN project USING (projectid)
        left JOIN contactgroup ON project.orgid = contactgroup.contactid
        where isgroup;

   ALTER TABLE absi.productgrouplist
     OWNER TO bradley;
   GRANT ALL ON TABLE absi.productgrouplist TO bradley;
   GRANT SELECT ON TABLE absi.productgrouplist TO pts_read;
   GRANT ALL ON TABLE absi.productgrouplist TO pts_admin;
---- File: 004-product.sql ----

SET search_path TO absi, public;

ALTER TABLE absi.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN absi.product.perioddescription
  IS 'Description of the time period';

ALTER TABLE absi.product
 ADD COLUMN maintenancefrequencyid integer;
ALTER TABLE absi.product
 ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency (maintenancefrequencyid)
  ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX fki_maintenancefrequency_product_fk
 ON absi.product(maintenancefrequencyid);

 -- Column: orgid

-- ALTER TABLE absi.product DROP COLUMN orgid;

ALTER TABLE absi.product ADD COLUMN orgid integer;
UPDATE absi.product SET orgid = ( SELECT groupschema.groupid
          FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false))));
ALTER TABLE absi.product ALTER COLUMN orgid SET NOT NULL;
COMMENT ON COLUMN absi.product.orgid IS 'Identifies organization that owns the product';
---- File: 005-productlist.sql ----

SET search_path TO absi, public;

-- View: absi.productlist

-- DROP VIEW absi.productlist;

CREATE OR REPLACE VIEW absi.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid
   FROM absi.product p
     left JOIN absi.project USING (projectid)
     left JOIN absi.contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN absi.product pg ON p.productgroupid = pg.productid;
---- File: 006-productstep.sql ----

SET search_path TO absi, public;

-- Table: absi.productstep

-- DROP TABLE absi.productstep;

CREATE TABLE absi.productstep
(
  productstepid integer NOT NULL DEFAULT nextval('common.productstep_productstepid_seq'::regclass),
  productid integer NOT NULL, -- PK for PRODUCT
  productcontactid integer NOT NULL,
  description character varying NOT NULL,
  rationale character varying, -- Requirement or purpose for the process step.
  stepdate date NOT NULL, -- Date and time or date at which the process step occurred.
  priority integer NOT NULL DEFAULT 0, -- Order of the step
  CONSTRAINT productstep_pk PRIMARY KEY (productstepid),
  CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid)
        REFERENCES absi.productcontact (productcontactid) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT product_productstep_fk FOREIGN KEY (productid)
      REFERENCES absi.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE absi.productstep
  OWNER TO bradley;
GRANT ALL ON TABLE absi.productstep TO bradley;
GRANT SELECT ON TABLE absi.productstep TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE absi.productstep TO pts_write;
GRANT ALL ON TABLE absi.productstep TO pts_admin;
COMMENT ON TABLE absi.productstep
  IS 'Identifies the steps taken when during processing of the product.';
COMMENT ON COLUMN absi.productstep.productid IS 'PK for PRODUCT';
COMMENT ON COLUMN absi.productstep.rationale IS 'Requirement or purpose for the process step.';
COMMENT ON COLUMN absi.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';
COMMENT ON COLUMN absi.productstep.priority IS 'Order of the step';
---- File: 007-metadataproduct.sql ----

SET search_path TO absi, public;

CREATE OR REPLACE VIEW metadataproduct AS
 SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((product
     LEFT JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

---- Schema: nwb ----


---- File: 001-productgroup.sql ----

SET search_path TO nwb, public;

ALTER TABLE nwb.product ADD COLUMN productgroupid integer;

COMMENT ON COLUMN nwb.product.productgroupid IS 'Identifies the group to which this product belongs.';


ALTER TABLE nwb.product ADD CONSTRAINT productgroup_product_fk
FOREIGN KEY (productgroupid) REFERENCES nwb.product (productid) ON
UPDATE NO action ON
DELETE NO action;

CREATE INDEX fki_productgroup_product_fk ON nwb.product(productgroupid);

-- Column: isgroup

-- ALTER TABLE nwb.product DROP COLUMN isgroup;

ALTER TABLE nwb.product ADD COLUMN isgroup boolean;
UPDATE nwb.product
   SET
       isgroup=false
 WHERE isgroup IS NULL;
ALTER TABLE nwb.product ALTER COLUMN isgroup SET NOT NULL;
ALTER TABLE nwb.product ALTER COLUMN isgroup SET DEFAULT false;
COMMENT ON COLUMN nwb.product.isgroup IS 'Identifies whether the item is a product group.';
---- File: 002-uselimitation.sql ----

SET search_path TO nwb, public;

ALTER TABLE nwb.product
   ADD COLUMN uselimitation character varying;
COMMENT ON COLUMN nwb.product.uselimitation
  IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';
---- File: 003-productgrouplist.sql ----

SET search_path TO nwb, public;

ALTER TABLE nwb.product
   ALTER COLUMN projectid DROP NOT NULL;

   -- View: nwb.productgrouplist

   -- DROP VIEW nwb.productgrouplist;

   CREATE OR REPLACE VIEW nwb.productgrouplist AS
    SELECT p.productid,
       p.projectid,
       common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
       p.uuid,
       p.title,
       p.isgroup,
       p.productgroupid
      FROM product p
        left JOIN project USING (projectid)
        left JOIN contactgroup ON project.orgid = contactgroup.contactid
        where isgroup;

   ALTER TABLE nwb.productgrouplist
     OWNER TO bradley;
   GRANT ALL ON TABLE nwb.productgrouplist TO bradley;
   GRANT SELECT ON TABLE nwb.productgrouplist TO pts_read;
   GRANT ALL ON TABLE nwb.productgrouplist TO pts_admin;
---- File: 004-product.sql ----

SET search_path TO nwb, public;

ALTER TABLE nwb.product
   ADD COLUMN perioddescription character varying;
COMMENT ON COLUMN nwb.product.perioddescription
  IS 'Description of the time period';

ALTER TABLE nwb.product
 ADD COLUMN maintenancefrequencyid integer;
ALTER TABLE nwb.product
 ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency (maintenancefrequencyid)
  ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX fki_maintenancefrequency_product_fk
 ON nwb.product(maintenancefrequencyid);

 -- Column: orgid

-- ALTER TABLE nwb.product DROP COLUMN orgid;

ALTER TABLE nwb.product ADD COLUMN orgid integer;
UPDATE nwb.product SET orgid = ( SELECT groupschema.groupid
          FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false))));
ALTER TABLE nwb.product ALTER COLUMN orgid SET NOT NULL;
COMMENT ON COLUMN nwb.product.orgid IS 'Identifies organization that owns the product';
---- File: 005-productlist.sql ----

SET search_path TO nwb, public;

-- View: nwb.productlist

-- DROP VIEW nwb.productlist;

CREATE OR REPLACE VIEW nwb.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid
   FROM nwb.product p
     left JOIN nwb.project USING (projectid)
     left JOIN nwb.contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN nwb.product pg ON p.productgroupid = pg.productid;
---- File: 006-productstep.sql ----

SET search_path TO nwb, public;

-- Table: nwb.productstep

-- DROP TABLE nwb.productstep;

CREATE TABLE nwb.productstep
(
  productstepid integer NOT NULL DEFAULT nextval('common.productstep_productstepid_seq'::regclass),
  productid integer NOT NULL, -- PK for PRODUCT
  productcontactid integer NOT NULL,
  description character varying NOT NULL,
  rationale character varying, -- Requirement or purpose for the process step.
  stepdate date NOT NULL, -- Date and time or date at which the process step occurred.
  priority integer NOT NULL DEFAULT 0, -- Order of the step
  CONSTRAINT productstep_pk PRIMARY KEY (productstepid),
  CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid)
        REFERENCES nwb.productcontact (productcontactid) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT product_productstep_fk FOREIGN KEY (productid)
      REFERENCES nwb.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE nwb.productstep
  OWNER TO bradley;
GRANT ALL ON TABLE nwb.productstep TO bradley;
GRANT SELECT ON TABLE nwb.productstep TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE nwb.productstep TO pts_write;
GRANT ALL ON TABLE nwb.productstep TO pts_admin;
COMMENT ON TABLE nwb.productstep
  IS 'Identifies the steps taken when during processing of the product.';
COMMENT ON COLUMN nwb.productstep.productid IS 'PK for PRODUCT';
COMMENT ON COLUMN nwb.productstep.rationale IS 'Requirement or purpose for the process step.';
COMMENT ON COLUMN nwb.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';
COMMENT ON COLUMN nwb.productstep.priority IS 'Order of the step';
---- File: 007-metadataproduct.sql ----

SET search_path TO nwb, public;

CREATE OR REPLACE VIEW metadataproduct AS
 SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((product
     LEFT JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

