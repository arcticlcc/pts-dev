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
