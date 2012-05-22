--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.3
-- Dumped by pg_dump version 9.1.3
-- Started on 2012-05-22 17:02:30 AKDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 10 (class 2615 OID 32532)
-- Name: pts; Type: SCHEMA; Schema: -; Owner: bradley
--

CREATE SCHEMA pts;


ALTER SCHEMA pts OWNER TO bradley;

SET search_path = pts, pg_catalog;

--
-- TOC entry 1093 (class 1255 OID 32533)
-- Dependencies: 1765 10
-- Name: form_projectcode(integer, date, character varying); Type: FUNCTION; Schema: pts; Owner: bradley
--

CREATE FUNCTION form_projectcode(pnum integer, initdate date, org character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
fy varchar;
BEGIN
IF EXTRACT(MONTH FROM initdate) BETWEEN 1 AND 9
THEN fy = EXTRACT(YEAR FROM initdate );
ELSE fy = EXTRACT(YEAR FROM initdate ) + 1;
END IF;
IF pnum < 10
THEN RETURN org || fy || '-0'|| pnum;
ELSE RETURN org || fy || '-'||pnum;
END IF;
END
$$;


ALTER FUNCTION pts.form_projectcode(pnum integer, initdate date, org character varying) OWNER TO bradley;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 1093
-- Name: FUNCTION form_projectcode(pnum integer, initdate date, org character varying); Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON FUNCTION form_projectcode(pnum integer, initdate date, org character varying) IS 'Returns a formatted project identifier formed from organization acronym, project number, and initdate(derives fiscal year), e.g. ARCT03-125';


--
-- TOC entry 1094 (class 1255 OID 32534)
-- Dependencies: 1765 10
-- Name: form_projectcode(integer, integer, character varying); Type: FUNCTION; Schema: pts; Owner: bradley
--

CREATE FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
IF pnum < 10
THEN RETURN org || initdate || '-0'|| pnum;
ELSE RETURN org || initdate || '-'||pnum;
END IF;
END
$$;


ALTER FUNCTION pts.form_projectcode(pnum integer, initdate integer, org character varying) OWNER TO bradley;

--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 1094
-- Name: FUNCTION form_projectcode(pnum integer, initdate integer, org character varying); Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) IS 'Returns a formatted project identifier formed from organization acronym, project number, and initdate(fiscal year), e.g. ARCT03-125';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 173 (class 1259 OID 32547)
-- Dependencies: 3252 10
-- Name: address; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE address (
    addressid integer NOT NULL,
    contactid integer NOT NULL,
    addresstypeid integer NOT NULL,
    street1 character varying(100) NOT NULL,
    street2 character varying(100),
    postalcode character varying(10),
    postal4 smallint,
    stateid integer NOT NULL,
    countyid integer,
    countryiso character varying NOT NULL,
    comment character varying(250),
    latitude numeric(6,4),
    longitude numeric(7,4),
    priority smallint DEFAULT 0 NOT NULL,
    city character varying(200)
);


ALTER TABLE pts.address OWNER TO bradley;

--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.street1; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.street1 IS 'address line 1';


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.street2; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.street2 IS 'address line 2';


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.postalcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.postalcode IS 'varchar for Canadian postal code';


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.postal4; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.postal4 IS '4 digit zip extension';


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.stateid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.stateid IS 'state GNIS feature id or GEOnet Names Server Geopolitical Codes id';


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.countyid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.countyid IS 'county GNIS feature or GEOnet Names Server Geopolitical Codes id';


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.latitude; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.latitude IS 'WGS84';


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.longitude; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.longitude IS 'WGS84';


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN address.priority; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN address.priority IS 'primary, secondary, etc.';


--
-- TOC entry 174 (class 1259 OID 32554)
-- Dependencies: 10 173
-- Name: address_addressid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE address_addressid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.address_addressid_seq OWNER TO bradley;

--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 174
-- Name: address_addressid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE address_addressid_seq OWNED BY address.addressid;


--
-- TOC entry 175 (class 1259 OID 32556)
-- Dependencies: 10
-- Name: addresstype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE addresstype (
    addresstypeid integer NOT NULL,
    code character varying NOT NULL,
    title character varying NOT NULL
);


ALTER TABLE pts.addresstype OWNER TO bradley;

--
-- TOC entry 176 (class 1259 OID 32562)
-- Dependencies: 10
-- Name: audit; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE audit (
    auditid integer NOT NULL,
    newval character varying NOT NULL,
    oldval character varying NOT NULL,
    action character varying NOT NULL,
    model character varying NOT NULL,
    field character varying NOT NULL,
    stamp timestamp without time zone NOT NULL,
    contactid integer NOT NULL,
    modelid integer NOT NULL
);


ALTER TABLE pts.audit OWNER TO bradley;

--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE audit; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE audit IS 'Tracks changes to data tables';


--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN audit.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN audit.contactid IS 'PK for PERSON';


--
-- TOC entry 177 (class 1259 OID 32568)
-- Dependencies: 10 176
-- Name: audit_auditid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE audit_auditid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.audit_auditid_seq OWNER TO bradley;

--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 177
-- Name: audit_auditid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE audit_auditid_seq OWNED BY audit.auditid;


--
-- TOC entry 178 (class 1259 OID 32570)
-- Dependencies: 3255 10
-- Name: contact; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE contact (
    contactid integer NOT NULL,
    comment character varying(250),
    dunsnumber character varying,
    contacttypeid integer NOT NULL,
    inactive boolean DEFAULT false NOT NULL
);


ALTER TABLE pts.contact OWNER TO bradley;

--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN contact.contacttypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contact.contacttypeid IS 'hatchery, refuge, park, military base';


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN contact.inactive; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contact.inactive IS 'Indicates the contact status.';


--
-- TOC entry 179 (class 1259 OID 32577)
-- Dependencies: 178 10
-- Name: contact_contactid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE contact_contactid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.contact_contactid_seq OWNER TO bradley;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 179
-- Name: contact_contactid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE contact_contactid_seq OWNED BY contact.contactid;


--
-- TOC entry 180 (class 1259 OID 32579)
-- Dependencies: 10
-- Name: contactcontactgroup; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE contactcontactgroup (
    groupid integer NOT NULL,
    contactid integer NOT NULL,
    positionid integer NOT NULL,
    contactcontactgroupid integer NOT NULL,
    priority smallint NOT NULL
);


ALTER TABLE pts.contactcontactgroup OWNER TO bradley;

--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN contactcontactgroup.positionid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contactcontactgroup.positionid IS 'PK for POSITION';


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN contactcontactgroup.contactcontactgroupid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contactcontactgroup.contactcontactgroupid IS 'PK';


--
-- TOC entry 181 (class 1259 OID 32582)
-- Dependencies: 10 180
-- Name: contactcontactgroup_contactcontactgroupid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE contactcontactgroup_contactcontactgroupid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.contactcontactgroup_contactcontactgroupid_seq OWNER TO bradley;

--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 181
-- Name: contactcontactgroup_contactcontactgroupid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE contactcontactgroup_contactcontactgroupid_seq OWNED BY contactcontactgroup.contactcontactgroupid;


--
-- TOC entry 182 (class 1259 OID 32584)
-- Dependencies: 10
-- Name: contactcostcode; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE contactcostcode (
    costcode character varying NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE pts.contactcostcode OWNER TO bradley;

--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE contactcostcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE contactcostcode IS 'List of common costcodes';


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN contactcostcode.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contactcostcode.contactid IS 'PK of organization that chargecode belongs to';


--
-- TOC entry 183 (class 1259 OID 32590)
-- Dependencies: 10
-- Name: contactgroup; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE contactgroup (
    contactid integer NOT NULL,
    organization boolean,
    name character varying(100) NOT NULL,
    acronym character varying(7)
);


ALTER TABLE pts.contactgroup OWNER TO bradley;

--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 183
-- Name: TABLE contactgroup; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE contactgroup IS 'info for organizations, agencies and their subunits';


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN contactgroup.organization; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contactgroup.organization IS 'Sepecifies whether contact is considered an organization as defined by business rules';


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN contactgroup.acronym; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN contactgroup.acronym IS 'short acronym identifying unit';


--
-- TOC entry 184 (class 1259 OID 32593)
-- Dependencies: 10
-- Name: contacttype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE contacttype (
    contacttypeid integer NOT NULL,
    code character varying NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.contacttype OWNER TO bradley;

--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE contacttype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE contacttype IS 'type of contact, e.g. federal,state,etc';


--
-- TOC entry 185 (class 1259 OID 32599)
-- Dependencies: 184 10
-- Name: contacttype_contacttypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE contacttype_contacttypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.contacttype_contacttypeid_seq OWNER TO bradley;

--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 185
-- Name: contacttype_contacttypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE contacttype_contacttypeid_seq OWNED BY contacttype.contacttypeid;


--
-- TOC entry 186 (class 1259 OID 32601)
-- Dependencies: 10
-- Name: costcode; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE costcode (
    costcodeid integer NOT NULL,
    fundingid integer NOT NULL,
    costcode character varying NOT NULL,
    startdate date NOT NULL,
    enddate date
);


ALTER TABLE pts.costcode OWNER TO bradley;

--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE costcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE costcode IS 'Costcode associated with funding';


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN costcode.costcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN costcode.costcode IS 'Cost code associated with FUNDING';


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN costcode.startdate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN costcode.startdate IS 'Date from which costcode is active';


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN costcode.enddate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN costcode.enddate IS 'Date after which costcode is invalid';


--
-- TOC entry 187 (class 1259 OID 32607)
-- Dependencies: 10 186
-- Name: costcode_costcodeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE costcode_costcodeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.costcode_costcodeid_seq OWNER TO bradley;

--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 187
-- Name: costcode_costcodeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE costcode_costcodeid_seq OWNED BY costcode.costcodeid;


--
-- TOC entry 188 (class 1259 OID 32609)
-- Dependencies: 10
-- Name: costcodeinvoice; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE costcodeinvoice (
    costcodeid integer NOT NULL,
    invoiceid integer NOT NULL,
    amount numeric NOT NULL,
    datecharged date NOT NULL,
    costcodeinvoiceid integer NOT NULL
);


ALTER TABLE pts.costcodeinvoice OWNER TO bradley;

--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN costcodeinvoice.amount; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN costcodeinvoice.amount IS 'Amount charged to specific code';


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN costcodeinvoice.datecharged; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN costcodeinvoice.datecharged IS 'Date invoice charged to code';


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN costcodeinvoice.costcodeinvoiceid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN costcodeinvoice.costcodeinvoiceid IS 'PK for costcodeinvoice, created to ease client implementation';


--
-- TOC entry 189 (class 1259 OID 32615)
-- Dependencies: 10 188
-- Name: costcodeinvoice_costcodeinvoiceid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE costcodeinvoice_costcodeinvoiceid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.costcodeinvoice_costcodeinvoiceid_seq OWNER TO bradley;

--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 189
-- Name: costcodeinvoice_costcodeinvoiceid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE costcodeinvoice_costcodeinvoiceid_seq OWNED BY costcodeinvoice.costcodeinvoiceid;


--
-- TOC entry 171 (class 1259 OID 32535)
-- Dependencies: 10
-- Name: country; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE country (
    countryiso character varying(2) NOT NULL,
    iso3 character varying(3),
    isonumeric character varying(3),
    fips character varying(2),
    country character varying,
    capital character varying,
    area numeric,
    population integer,
    continent character varying,
    tld character varying,
    currencycode character varying,
    currencyname character varying,
    phone character varying,
    postalcodeformat character varying,
    postalcoderegex character varying,
    languages character varying,
    geonameid character varying,
    neighbours character varying,
    equivalentfipscode character varying
);


ALTER TABLE pts.country OWNER TO bradley;

--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE country; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE country IS 'List of world countries';


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN country.countryiso; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN country.countryiso IS 'ISO two-letter code';


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN country.iso3; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN country.iso3 IS 'ISO three-letter code';


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN country.isonumeric; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN country.isonumeric IS 'Numeric ISO code';


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN country.country; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN country.country IS 'country name';


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN country.area; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN country.area IS 'Area in sq km';


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN country.languages; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN country.languages IS 'Lists the languages spoken in a country ordered by the number of speakers. The language code is a ''locale'' where any two-letter primary-tag is an ISO-639 language abbreviation and any two-letter initial subtag is an ISO-3166 country code.';


--
-- TOC entry 190 (class 1259 OID 32617)
-- Dependencies: 10
-- Name: govunit; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE govunit (
    featureid integer NOT NULL,
    unittype character varying,
    countynumeric character varying,
    countyname character varying,
    statenumeric character(2),
    statealpha character(2),
    statename character varying,
    countryalpha character(2),
    countryname character varying,
    featurename character varying
);


ALTER TABLE pts.govunit OWNER TO bradley;

--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE govunit; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE govunit IS 'US states and counties. http://geonames.usgs.gov/domestic/download_data.htm';


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.featureid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.featureid IS 'The Feature ID number for the governmental unit.';


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.unittype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.unittype IS 'The type of government unit. Values are County, State, Country. ';


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.countynumeric; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.countynumeric IS 'The unique three number code for a county or county equivalent as specified in INCITS 31:200x, (Formerly FIPS 6-4) Codes for the Identification of Counties and Equivalent Entities of the United States, its Possessions, and Insular Areas';


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.countyname; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.countyname IS 'The unique name for a county or county equivalent as specified in INCITS 31:200x, (Formerly FIPS 6-4) Codes for the Identification of Counties and Equivalent Entities of the United States, its Possessions, and Insular Areas';


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.statenumeric; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.statenumeric IS '1) The unique two number code for a US State as specified in INCITS 38:200x, (Formerly FIPS 5-2) Codes for the Identification of the States, the District of Columbia, Puerto Rico, and the Insular Areas of the United States, or 2) The unique two number code for a principle administrative division of countries other than the United States as specified in FIPS PUB 10-4, Countries, Dependencies, Areas Of Special Sovereignty, And Their Principal Administrative Divisions.';


--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.statealpha; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.statealpha IS 'The unique two letter code for a US State as specified in INCITS 38:200x, (Formerly FIPS 5-2) Codes for the Identification of the States, the District of Columbia, Puerto Rico, and the Insular Areas of the United States.';


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.statename; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.statename IS '1) The name of a US State as specified in INCITS 38:200x, (Formerly FIPS 5-2) Codes for the Identification of the States, the District of Columbia, Puerto Rico, and the Insular Areas of the United States, or 2) The name of a principle administrative division of countries other than the United States as specified in FIPS PUB 10-4, Countries, Dependencies, Areas Of Special Sovereignty, And Their Principal Administrative Divisions.';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.countryalpha; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.countryalpha IS 'The unique two letter code of a country as specified in Federal Information Processing Standards Publication (FIPS PUB) 10-4, Countries, Dependencies, Areas of Special Sovereignty, And Their Principal Administrative Divisions.';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.countryname; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.countryname IS 'The unique name of a country as specified in Federal Information Processing Standards Publication (FIPS PUB) 10-4, Countries, Dependencies, Areas of Special Sovereignty, And Their Principal Administrative Divisions.';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN govunit.featurename; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN govunit.featurename IS 'Official feature name';


--
-- TOC entry 191 (class 1259 OID 32623)
-- Dependencies: 3233 10
-- Name: countylist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW countylist AS
    SELECT govunit.featureid AS countyid, govunit.unittype, govunit.countynumeric, govunit.countyname, govunit.statenumeric, govunit.statealpha, govunit.statename, govunit.countryalpha, govunit.countryname, govunit.featurename FROM govunit WHERE ((govunit.unittype)::text = 'COUNTY'::text) ORDER BY govunit.countyname;


ALTER TABLE pts.countylist OWNER TO bradley;

--
-- TOC entry 192 (class 1259 OID 32627)
-- Dependencies: 10
-- Name: deliverable; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE deliverable (
    deliverableid integer NOT NULL,
    deliverabletypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.deliverable OWNER TO bradley;

--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE deliverable; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE deliverable IS 'Project deliverables';


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN deliverable.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverable.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN deliverable.deliverabletypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverable.deliverabletypeid IS 'PK of DELIVERABLETYPE';


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN deliverable.title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverable.title IS 'Short title of devliverable';


--
-- TOC entry 193 (class 1259 OID 32633)
-- Dependencies: 10 192
-- Name: deliverable_deliverableid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE deliverable_deliverableid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.deliverable_deliverableid_seq OWNER TO bradley;

--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 193
-- Name: deliverable_deliverableid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE deliverable_deliverableid_seq OWNED BY deliverable.deliverableid;


--
-- TOC entry 194 (class 1259 OID 32635)
-- Dependencies: 3262 3263 3264 10
-- Name: deliverablemod; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE deliverablemod (
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    duedate date NOT NULL,
    receiveddate date,
    devinterval interval,
    invalid boolean DEFAULT false NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    restricted boolean DEFAULT true NOT NULL,
    accessdescription character varying,
    parentmodificationid integer,
    parentdeliverableid integer,
    personid integer NOT NULL
);


ALTER TABLE pts.deliverablemod OWNER TO bradley;

--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.duedate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.duedate IS 'The date the deliverable is due';


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.receiveddate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.receiveddate IS 'Date the deliverable is delivered';


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.devinterval; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.devinterval IS 'Interval of recurrent deliverables.';


--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.invalid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.invalid IS 'Indicates whether deliverable is valid';


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.publish; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.publish IS 'Designates whether the product may be distributed';


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.accessdescription; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.accessdescription IS 'Description of constraints to be met when publishing the delivered product';


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.parentmodificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.parentmodificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.parentdeliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.parentdeliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN deliverablemod.personid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablemod.personid IS 'FK for person, identifies user responsible for deliverablemod';


--
-- TOC entry 195 (class 1259 OID 32644)
-- Dependencies: 3234 10
-- Name: deliverableall; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW deliverableall AS
    SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, deliverablemod.receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description, (EXISTS (SELECT dm.modificationid, dm.deliverableid, dm.duedate, dm.receiveddate, dm.devinterval, dm.invalid, dm.publish, dm.restricted, dm.accessdescription, dm.parentmodificationid, dm.parentdeliverableid, dm.personid FROM deliverablemod dm WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified FROM (deliverablemod JOIN deliverable USING (deliverableid));


ALTER TABLE pts.deliverableall OWNER TO bradley;

--
-- TOC entry 196 (class 1259 OID 32649)
-- Dependencies: 10
-- Name: deliverabletype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE deliverabletype (
    deliverabletypeid integer NOT NULL,
    type character varying NOT NULL,
    description character varying NOT NULL,
    code character varying NOT NULL
);


ALTER TABLE pts.deliverabletype OWNER TO bradley;

--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE deliverabletype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE deliverabletype IS 'types of deliverables';


--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN deliverabletype.deliverabletypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverabletype.deliverabletypeid IS 'PK of DELIVERABLETYPE';


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN deliverabletype.code; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverabletype.code IS 'code for deliverabletype';


--
-- TOC entry 197 (class 1259 OID 32655)
-- Dependencies: 10
-- Name: modification; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modification (
    modificationid integer NOT NULL,
    projectid integer NOT NULL,
    personid integer NOT NULL,
    modtypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    description character varying NOT NULL,
    modificationcode character varying,
    effectivedate date,
    startdate date,
    enddate date,
    datecreated date NOT NULL,
    parentmodificationid integer,
    shorttitle character varying(60)
);


ALTER TABLE pts.modification OWNER TO bradley;

--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE modification; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE modification IS 'Tracks all modifications to projects,including proposals and agreements';


--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.personid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.personid IS 'FK for person, identifies user responsible for modification';


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.title IS 'Short description of modification';


--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.description; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.description IS 'Summary of modification appropriate for publication';


--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.modificationcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.modificationcode IS 'user identifier for modification, e.g. agreement number';


--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.effectivedate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.effectivedate IS 'Date modification takes effect';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.startdate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.startdate IS 'Expected Start date of MODIFICATION';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.enddate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.enddate IS 'Expected End date of MODIFICATION';


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.datecreated; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.datecreated IS 'Date the modification is created.';


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.parentmodificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.parentmodificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN modification.shorttitle; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modification.shorttitle IS 'Truncated title for display';


--
-- TOC entry 198 (class 1259 OID 32661)
-- Dependencies: 10
-- Name: person; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE person (
    contactid integer NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    middlename character varying,
    suffix character varying,
    jobtitleid integer,
    positionid integer
);


ALTER TABLE pts.person OWNER TO bradley;

--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN person.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN person.contactid IS 'PK for PERSON';


--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN person.positionid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN person.positionid IS 'Primary position description for this person';


--
-- TOC entry 199 (class 1259 OID 32667)
-- Dependencies: 3266 3267 10
-- Name: project; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE project (
    projectid integer NOT NULL,
    orgid integer DEFAULT 1 NOT NULL,
    title character varying(150) NOT NULL,
    parentprojectid integer,
    fiscalyear smallint NOT NULL,
    number smallint NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    description character varying(300) NOT NULL,
    abstract character varying,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    shorttitle character varying(60) NOT NULL
);


ALTER TABLE pts.project OWNER TO bradley;

--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.orgid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.orgid IS 'Identifies organization that owns the project';


--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.title IS 'Name of project';


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.fiscalyear; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.fiscalyear IS 'Fiscal year of project code';


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.number; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.number IS 'Project number component of project code';


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.startdate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.startdate IS 'Date of expected start';


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.enddate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.enddate IS 'Date of expected end';


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.description; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.description IS 'Short project description';


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.abstract; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.abstract IS 'Long description of project';


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.uuid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.uuid IS 'Universally unique identifier for project (from ADiwg specification)';


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN project.shorttitle; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN project.shorttitle IS 'Truncated title. Used in factsheets and other outreach materials.';


--
-- TOC entry 200 (class 1259 OID 32675)
-- Dependencies: 3235 10
-- Name: deliverablecalendar; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW deliverablecalendar AS
    SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, deliverablemod.receiveddate, deliverable.title, deliverable.description, (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS manager, deliverabletype.type, form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode, modification.projectid FROM ((((((deliverablemod JOIN modification USING (modificationid)) JOIN project USING (projectid)) JOIN contactgroup ON ((project.orgid = contactgroup.contactid))) JOIN deliverable USING (deliverableid)) JOIN deliverabletype USING (deliverabletypeid)) JOIN person ON ((deliverablemod.personid = person.contactid))) WHERE ((NOT deliverablemod.invalid) OR (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))));


ALTER TABLE pts.deliverablecalendar OWNER TO bradley;

--
-- TOC entry 201 (class 1259 OID 32680)
-- Dependencies: 10
-- Name: deliverablecomment; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE deliverablecomment (
    deliverableid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE pts.deliverablecomment OWNER TO bradley;

--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN deliverablecomment.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablecomment.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN deliverablecomment.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 202 (class 1259 OID 32686)
-- Dependencies: 3269 10
-- Name: deliverablecontact; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE deliverablecontact (
    deliverableid integer NOT NULL,
    contactid integer NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    roletypeid integer
);


ALTER TABLE pts.deliverablecontact OWNER TO bradley;

--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE deliverablecontact; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE deliverablecontact IS 'Identifies contacts for each deliverable.';


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN deliverablecontact.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablecontact.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN deliverablecontact.roletypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN deliverablecontact.roletypeid IS 'FK for ROLETYPE';


--
-- TOC entry 203 (class 1259 OID 32690)
-- Dependencies: 3236 10
-- Name: deliverablelist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW deliverablelist AS
    SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, deliverablemod.receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description FROM (deliverablemod JOIN deliverable USING (deliverableid)) WHERE ((NOT deliverablemod.invalid) OR (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))));


ALTER TABLE pts.deliverablelist OWNER TO bradley;

--
-- TOC entry 204 (class 1259 OID 32695)
-- Dependencies: 196 10
-- Name: deliverabletype_deliverabletypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE deliverabletype_deliverabletypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.deliverabletype_deliverabletypeid_seq OWNER TO bradley;

--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 204
-- Name: deliverabletype_deliverabletypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE deliverabletype_deliverabletypeid_seq OWNED BY deliverabletype.deliverabletypeid;


--
-- TOC entry 205 (class 1259 OID 32697)
-- Dependencies: 10
-- Name: eaddress; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE eaddress (
    eaddressid integer NOT NULL,
    contactid integer NOT NULL,
    eaddresstypeid integer NOT NULL,
    uri character varying(250) NOT NULL,
    priority smallint NOT NULL,
    comment character varying(250)
);


ALTER TABLE pts.eaddress OWNER TO bradley;

--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE eaddress; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE eaddress IS 'electronic address';


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN eaddress.uri; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN eaddress.uri IS 'uniform resource identifier, e.g. website address';


--
-- TOC entry 206 (class 1259 OID 32703)
-- Dependencies: 10
-- Name: eaddresstype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE eaddresstype (
    eaddresstypeid integer NOT NULL,
    type character varying NOT NULL,
    code character varying
);


ALTER TABLE pts.eaddresstype OWNER TO bradley;

--
-- TOC entry 207 (class 1259 OID 32709)
-- Dependencies: 10 205
-- Name: electadd_electaddid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE electadd_electaddid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.electadd_electaddid_seq OWNER TO bradley;

--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 207
-- Name: electadd_electaddid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE electadd_electaddid_seq OWNED BY eaddress.eaddressid;


--
-- TOC entry 208 (class 1259 OID 32711)
-- Dependencies: 10 206
-- Name: electaddtype_electaddtypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE electaddtype_electaddtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.electaddtype_electaddtypeid_seq OWNER TO bradley;

--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 208
-- Name: electaddtype_electaddtypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE electaddtype_electaddtypeid_seq OWNED BY eaddresstype.eaddresstypeid;


--
-- TOC entry 209 (class 1259 OID 32713)
-- Dependencies: 10
-- Name: fact; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE fact (
    factid integer NOT NULL,
    projectid integer NOT NULL,
    title character varying NOT NULL,
    headliner character varying,
    bigpicture character varying,
    description character varying,
    interest character varying,
    whatdone character varying,
    outcome character varying,
    funfact character varying,
    editdate date NOT NULL
);


ALTER TABLE pts.fact OWNER TO bradley;

--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE fact; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE fact IS 'Data primarily intended for project factsheet';


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN fact.title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fact.title IS 'Condensed title of project';


--
-- TOC entry 210 (class 1259 OID 32719)
-- Dependencies: 209 10
-- Name: fact_factid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE fact_factid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.fact_factid_seq OWNER TO bradley;

--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 210
-- Name: fact_factid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE fact_factid_seq OWNED BY fact.factid;


--
-- TOC entry 211 (class 1259 OID 32721)
-- Dependencies: 3273 10
-- Name: factfile; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE factfile (
    factid integer NOT NULL,
    fileid integer NOT NULL,
    priority smallint DEFAULT 1 NOT NULL,
    caption character varying
);


ALTER TABLE pts.factfile OWNER TO bradley;

--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE factfile; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE factfile IS 'Associates logos and images with FACTsheets';


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN factfile.fileid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN factfile.fileid IS 'PK for FILE';


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN factfile.caption; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN factfile.caption IS 'Caption associated with document';


--
-- TOC entry 212 (class 1259 OID 32728)
-- Dependencies: 3274 10
-- Name: file; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE file (
    fileid integer NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    product boolean DEFAULT false NOT NULL
);


ALTER TABLE pts.file OWNER TO bradley;

--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE file; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE file IS 'File';


--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN file.fileid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN file.fileid IS 'PK for FILE';


--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN file.name; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN file.name IS 'name of document';


--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN file.product; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN file.product IS 'Specifies whether document is a product.';


--
-- TOC entry 213 (class 1259 OID 32735)
-- Dependencies: 10
-- Name: filecomment; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE filecomment (
    fileid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE pts.filecomment OWNER TO bradley;

--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN filecomment.fileid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN filecomment.fileid IS 'PK for DOCUMENT';


--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN filecomment.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN filecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 214 (class 1259 OID 32741)
-- Dependencies: 10
-- Name: filetype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE filetype (
    filetypeid integer NOT NULL,
    type character varying NOT NULL
);


ALTER TABLE pts.filetype OWNER TO bradley;

--
-- TOC entry 215 (class 1259 OID 32747)
-- Dependencies: 214 10
-- Name: filetype_filetypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE filetype_filetypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.filetype_filetypeid_seq OWNER TO bradley;

--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 215
-- Name: filetype_filetypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE filetype_filetypeid_seq OWNED BY filetype.filetypeid;


--
-- TOC entry 216 (class 1259 OID 32749)
-- Dependencies: 10
-- Name: fileversion; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE fileversion (
    fileversionid integer NOT NULL,
    fileid integer NOT NULL,
    projectid integer,
    modificationid integer,
    deliverableid integer,
    invoiceid integer,
    progressid integer,
    filetypeid integer NOT NULL,
    formatid integer NOT NULL,
    uri character varying NOT NULL,
    current boolean NOT NULL,
    uploadstamp timestamp without time zone NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE pts.fileversion OWNER TO bradley;

--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN fileversion.fileid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fileversion.fileid IS 'PK for FILE';


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN fileversion.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fileversion.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN fileversion.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fileversion.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN fileversion.uri; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fileversion.uri IS 'Electronic address of document';


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN fileversion.current; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fileversion.current IS 'Identifies current document';


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN fileversion.uploadstamp; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fileversion.uploadstamp IS 'Timestamp document was uploaded';


--
-- TOC entry 217 (class 1259 OID 32755)
-- Dependencies: 10 216
-- Name: fileversion_fileversionid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE fileversion_fileversionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.fileversion_fileversionid_seq OWNER TO bradley;

--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 217
-- Name: fileversion_fileversionid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE fileversion_fileversionid_seq OWNED BY fileversion.fileversionid;


--
-- TOC entry 218 (class 1259 OID 32757)
-- Dependencies: 10
-- Name: format; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE format (
    formatid integer NOT NULL,
    format character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.format OWNER TO bradley;

--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE format; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE format IS 'Format of document';


--
-- TOC entry 219 (class 1259 OID 32763)
-- Dependencies: 218 10
-- Name: format_formatid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE format_formatid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.format_formatid_seq OWNER TO bradley;

--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 219
-- Name: format_formatid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE format_formatid_seq OWNED BY format.formatid;


--
-- TOC entry 220 (class 1259 OID 32765)
-- Dependencies: 10
-- Name: funding; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE funding (
    fundingid integer NOT NULL,
    fundingtypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    amount numeric NOT NULL,
    modificationid integer NOT NULL,
    projectcontactid integer NOT NULL
);


ALTER TABLE pts.funding OWNER TO bradley;

--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN funding.title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN funding.title IS 'User identifier for funding';


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN funding.amount; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN funding.amount IS 'Amount of funding associated with modification';


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN funding.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN funding.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 221 (class 1259 OID 32771)
-- Dependencies: 220 10
-- Name: funding_fundingid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE funding_fundingid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.funding_fundingid_seq OWNER TO bradley;

--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 221
-- Name: funding_fundingid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE funding_fundingid_seq OWNED BY funding.fundingid;


--
-- TOC entry 222 (class 1259 OID 32773)
-- Dependencies: 10
-- Name: fundingtype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE fundingtype (
    fundingtypeid integer NOT NULL,
    type character varying NOT NULL,
    code character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.fundingtype OWNER TO bradley;

--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE fundingtype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE fundingtype IS 'type of funding';


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN fundingtype.code; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN fundingtype.code IS 'code for fundingtype';


--
-- TOC entry 223 (class 1259 OID 32779)
-- Dependencies: 10 222
-- Name: fundingtype_fundingtypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE fundingtype_fundingtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.fundingtype_fundingtypeid_seq OWNER TO bradley;

--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 223
-- Name: fundingtype_fundingtypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE fundingtype_fundingtypeid_seq OWNED BY fundingtype.fundingtypeid;


--
-- TOC entry 224 (class 1259 OID 32781)
-- Dependencies: 3237 10
-- Name: groupmemberlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW groupmemberlist AS
    SELECT ccg.groupid, ccg.contactid, ccg.positionid, ccg.contactcontactgroupid, pg_catalog.concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name, ccg.priority FROM (contactcontactgroup ccg JOIN person USING (contactid)) UNION SELECT ccg.groupid, ccg.contactid, ccg.positionid, ccg.contactcontactgroupid, contactgroup.name, ccg.priority FROM (contactcontactgroup ccg JOIN contactgroup USING (contactid)) ORDER BY 5, 3;


ALTER TABLE pts.groupmemberlist OWNER TO bradley;

--
-- TOC entry 225 (class 1259 OID 32786)
-- Dependencies: 3238 10
-- Name: grouppersonlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW grouppersonlist AS
    SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, contactcontactgroup.groupid, contactgroup.acronym, contactgroup.name FROM ((contactcontactgroup JOIN contactgroup ON ((contactgroup.contactid = contactcontactgroup.groupid))) JOIN person ON ((person.contactid = contactcontactgroup.contactid)));


ALTER TABLE pts.grouppersonlist OWNER TO bradley;

--
-- TOC entry 226 (class 1259 OID 32790)
-- Dependencies: 10
-- Name: invoice; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE invoice (
    invoiceid integer NOT NULL,
    datereceived date NOT NULL,
    title character varying(250) NOT NULL,
    dateclosed date,
    amount numeric NOT NULL,
    fundingid integer NOT NULL,
    projectcontactid integer NOT NULL
);


ALTER TABLE pts.invoice OWNER TO bradley;

--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN invoice.datereceived; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN invoice.datereceived IS 'date invoice was received';


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN invoice.title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN invoice.title IS 'User identifier for invoice';


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN invoice.dateclosed; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN invoice.dateclosed IS 'Date invoice was processed';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN invoice.amount; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN invoice.amount IS 'Totla amount for invoice';


--
-- TOC entry 227 (class 1259 OID 32796)
-- Dependencies: 10 226
-- Name: invoice_invoiceid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE invoice_invoiceid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.invoice_invoiceid_seq OWNER TO bradley;

--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 227
-- Name: invoice_invoiceid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE invoice_invoiceid_seq OWNED BY invoice.invoiceid;


--
-- TOC entry 228 (class 1259 OID 32798)
-- Dependencies: 10
-- Name: invoicecomment; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE invoicecomment (
    invoiceid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE pts.invoicecomment OWNER TO bradley;

--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN invoicecomment.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN invoicecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 229 (class 1259 OID 32804)
-- Dependencies: 3239 10
-- Name: invoicelist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW invoicelist AS
    SELECT costcode.fundingid, i.invoiceid, i.projectcontactid, i.datereceived, i.title, i.dateclosed, i.amount FROM ((invoice i JOIN costcodeinvoice USING (invoiceid)) JOIN costcode USING (costcodeid));


ALTER TABLE pts.invoicelist OWNER TO bradley;

--
-- TOC entry 230 (class 1259 OID 32808)
-- Dependencies: 10
-- Name: line; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE line (
    fid integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE pts.line OWNER TO bradley;

--
-- TOC entry 231 (class 1259 OID 32814)
-- Dependencies: 10 230
-- Name: line_fid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE line_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.line_fid_seq OWNER TO bradley;

--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 231
-- Name: line_fid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE line_fid_seq OWNED BY line.fid;


--
-- TOC entry 232 (class 1259 OID 32816)
-- Dependencies: 10
-- Name: login; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE login (
    loginid integer NOT NULL,
    contactid integer NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    groupid integer NOT NULL
);


ALTER TABLE pts.login OWNER TO bradley;

--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE login; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE login IS 'Stores usernames and passwords for web client';


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN login.loginid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN login.loginid IS 'PK for LOGIN';


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN login.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN login.contactid IS 'PK for PERSON';


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN login.password; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN login.password IS 'Hashed password';


--
-- TOC entry 233 (class 1259 OID 32822)
-- Dependencies: 10 232
-- Name: login_loginid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE login_loginid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.login_loginid_seq OWNER TO bradley;

--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 233
-- Name: login_loginid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE login_loginid_seq OWNED BY login.loginid;


--
-- TOC entry 234 (class 1259 OID 32824)
-- Dependencies: 3240 10
-- Name: membergrouplist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW membergrouplist AS
    SELECT ccg.groupid, ccg.contactid, ccg.positionid, ccg.contactcontactgroupid, contactgroup.name, ccg.priority FROM (contactcontactgroup ccg JOIN contactgroup ON ((ccg.groupid = contactgroup.contactid))) ORDER BY ccg.priority;


ALTER TABLE pts.membergrouplist OWNER TO bradley;

--
-- TOC entry 235 (class 1259 OID 32828)
-- Dependencies: 3283 10
-- Name: modcomment; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modcomment (
    modificationid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    publish boolean DEFAULT false NOT NULL
);


ALTER TABLE pts.modcomment OWNER TO bradley;

--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN modcomment.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modcomment.modificationid IS 'FK for MODIFICATION';


--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN modcomment.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modcomment.contactid IS 'PK for PERSON';


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN modcomment.publish; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modcomment.publish IS 'Indicates whether comment should be included with data exports or displayed in public documents';


--
-- TOC entry 236 (class 1259 OID 32835)
-- Dependencies: 10
-- Name: modcontact; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modcontact (
    contactid integer NOT NULL,
    modificationid integer NOT NULL,
    modcontacttypeid integer NOT NULL,
    priority smallint NOT NULL
);


ALTER TABLE pts.modcontact OWNER TO bradley;

--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE modcontact; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE modcontact IS 'Tracks contacts associated with modifications';


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN modcontact.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modcontact.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN modcontact.modcontacttypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modcontact.modcontacttypeid IS 'Indicates type of contact(internal/external admin,contractor, etc.)';


--
-- TOC entry 237 (class 1259 OID 32838)
-- Dependencies: 10
-- Name: modcontacttype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modcontacttype (
    modcontacttypeid integer NOT NULL,
    modcontacttype character varying NOT NULL
);


ALTER TABLE pts.modcontacttype OWNER TO bradley;

--
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE modcontacttype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE modcontacttype IS 'Lists type of contacts associated with a modification';


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN modcontacttype.modcontacttypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modcontacttype.modcontacttypeid IS 'Indicates type of contact(internal/external admin,contractor, etc.)';


--
-- TOC entry 238 (class 1259 OID 32844)
-- Dependencies: 237 10
-- Name: modcontacttype_modcontacttypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE modcontacttype_modcontacttypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.modcontacttype_modcontacttypeid_seq OWNER TO bradley;

--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 238
-- Name: modcontacttype_modcontacttypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE modcontacttype_modcontacttypeid_seq OWNED BY modcontacttype.modcontacttypeid;


--
-- TOC entry 239 (class 1259 OID 32846)
-- Dependencies: 197 10
-- Name: modification_modificationid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE modification_modificationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.modification_modificationid_seq OWNER TO bradley;

--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 239
-- Name: modification_modificationid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE modification_modificationid_seq OWNED BY modification.modificationid;


--
-- TOC entry 240 (class 1259 OID 32848)
-- Dependencies: 10
-- Name: modtype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modtype (
    modtypeid integer NOT NULL,
    type character varying NOT NULL,
    code character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.modtype OWNER TO bradley;

--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN modtype.code; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modtype.code IS 'code for modtype';


--
-- TOC entry 241 (class 1259 OID 32854)
-- Dependencies: 3241 10
-- Name: modificationlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW modificationlist AS
    SELECT m.modificationid, m.projectid, m.personid, m.modtypeid, m.title, m.description, m.modificationcode, m.effectivedate, m.startdate, m.enddate, m.datecreated, m.parentmodificationid, mt.type AS typetext, mt.code AS typecode FROM (modification m JOIN modtype mt USING (modtypeid));


ALTER TABLE pts.modificationlist OWNER TO bradley;

--
-- TOC entry 242 (class 1259 OID 32858)
-- Dependencies: 10
-- Name: modstatus; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modstatus (
    modificationid integer NOT NULL,
    statusid integer NOT NULL,
    effectivedate date NOT NULL,
    modstatusid integer NOT NULL,
    comment character varying
);


ALTER TABLE pts.modstatus OWNER TO bradley;

--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN modstatus.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN modstatus.statusid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modstatus.statusid IS 'PK for STATUS';


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN modstatus.effectivedate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN modstatus.modstatusid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modstatus.modstatusid IS 'PK for MODSTATUS, created for convenience when using client applications';


--
-- TOC entry 243 (class 1259 OID 32864)
-- Dependencies: 242 10
-- Name: modstatus_modstatusid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE modstatus_modstatusid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.modstatus_modstatusid_seq OWNER TO bradley;

--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 243
-- Name: modstatus_modstatusid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE modstatus_modstatusid_seq OWNED BY modstatus.modstatusid;


--
-- TOC entry 244 (class 1259 OID 32866)
-- Dependencies: 10 240
-- Name: modtype_modtypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE modtype_modtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.modtype_modtypeid_seq OWNER TO bradley;

--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 244
-- Name: modtype_modtypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE modtype_modtypeid_seq OWNED BY modtype.modtypeid;


--
-- TOC entry 245 (class 1259 OID 32868)
-- Dependencies: 10
-- Name: modtypestatus; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE modtypestatus (
    modtypeid integer NOT NULL,
    statusid integer NOT NULL
);


ALTER TABLE pts.modtypestatus OWNER TO bradley;

--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE modtypestatus; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE modtypestatus IS 'Identifies the valid status options for each modtype.';


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN modtypestatus.statusid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN modtypestatus.statusid IS 'PK for STATUS';


--
-- TOC entry 246 (class 1259 OID 32871)
-- Dependencies: 3287 10
-- Name: phone; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE phone (
    phoneid integer NOT NULL,
    contactid integer NOT NULL,
    addressid integer,
    phonetypeid integer NOT NULL,
    countryiso character(2) NOT NULL,
    areacode smallint NOT NULL,
    phnumber integer NOT NULL,
    extension smallint,
    priority smallint DEFAULT 1 NOT NULL
);


ALTER TABLE pts.phone OWNER TO bradley;

--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE phone; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE phone IS 'phone numbers, stored without punctuation';


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN phone.phonetypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN phone.phonetypeid IS 'FK for PHONETYPE';


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN phone.countryiso; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN phone.countryiso IS 'country code';


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN phone.areacode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN phone.areacode IS 'area or city code';


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN phone.phnumber; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN phone.phnumber IS 'main body of phone number';


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN phone.extension; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN phone.extension IS 'phone number extension';


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN phone.priority; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN phone.priority IS 'primary,secondary,etc.';


--
-- TOC entry 247 (class 1259 OID 32875)
-- Dependencies: 3242 10
-- Name: personlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW personlist AS
    SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, ccg.groupid AS prigroupid, cg.acronym AS priacronym, cg.name AS prigroupname, p.areacode AS priareacode, p.phnumber AS priphnumber, p.extension AS priextension, p.countryiso AS pricountryiso, e.uri AS priemail FROM ((((person LEFT JOIN (SELECT phone.phoneid, phone.contactid, phone.addressid, phone.phonetypeid, phone.countryiso, phone.areacode, phone.phnumber, phone.extension, phone.priority, row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank FROM phone WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1)))) LEFT JOIN (SELECT eaddress.eaddressid, eaddress.contactid, eaddress.eaddresstypeid, eaddress.uri, eaddress.priority, eaddress.comment, row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank FROM eaddress WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1)))) LEFT JOIN (SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank FROM contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1)))) LEFT JOIN contactgroup cg ON ((cg.contactid = ccg.groupid))) ORDER BY person.lastname;


ALTER TABLE pts.personlist OWNER TO bradley;

--
-- TOC entry 248 (class 1259 OID 32880)
-- Dependencies: 10 246
-- Name: phone_phoneid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE phone_phoneid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.phone_phoneid_seq OWNER TO bradley;

--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 248
-- Name: phone_phoneid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE phone_phoneid_seq OWNED BY phone.phoneid;


--
-- TOC entry 249 (class 1259 OID 32882)
-- Dependencies: 10
-- Name: phonetype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE phonetype (
    phonetypeid integer NOT NULL,
    type character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.phonetype OWNER TO bradley;

--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE phonetype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE phonetype IS 'type of number, e.g. phone,cell,fax';


--
-- TOC entry 250 (class 1259 OID 32888)
-- Dependencies: 10 249
-- Name: phonetype_phonetypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE phonetype_phonetypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.phonetype_phonetypeid_seq OWNER TO bradley;

--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 250
-- Name: phonetype_phonetypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE phonetype_phonetypeid_seq OWNED BY phonetype.phonetypeid;


--
-- TOC entry 251 (class 1259 OID 32890)
-- Dependencies: 10
-- Name: point; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE point (
    fid integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE pts.point OWNER TO bradley;

--
-- TOC entry 252 (class 1259 OID 32896)
-- Dependencies: 10 251
-- Name: point_fid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE point_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.point_fid_seq OWNER TO bradley;

--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 252
-- Name: point_fid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE point_fid_seq OWNED BY point.fid;


--
-- TOC entry 253 (class 1259 OID 32898)
-- Dependencies: 10
-- Name: polygon; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE polygon (
    fid integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE pts.polygon OWNER TO bradley;

--
-- TOC entry 254 (class 1259 OID 32904)
-- Dependencies: 10 253
-- Name: polygon_fid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE polygon_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.polygon_fid_seq OWNER TO bradley;

--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 254
-- Name: polygon_fid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE polygon_fid_seq OWNED BY polygon.fid;


--
-- TOC entry 255 (class 1259 OID 32906)
-- Dependencies: 10
-- Name: position; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE "position" (
    positionid integer NOT NULL,
    title character varying NOT NULL,
    code character varying NOT NULL
);


ALTER TABLE pts."position" OWNER TO bradley;

--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "position".positionid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN "position".positionid IS 'PK for POSITION';


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "position".title; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN "position".title IS 'Group position(e.g. biologist,chair)';


--
-- TOC entry 256 (class 1259 OID 32912)
-- Dependencies: 10 255
-- Name: position_positionid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE position_positionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.position_positionid_seq OWNER TO bradley;

--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 256
-- Name: position_positionid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE position_positionid_seq OWNED BY "position".positionid;


--
-- TOC entry 172 (class 1259 OID 32541)
-- Dependencies: 10
-- Name: postalcode; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE postalcode (
    countryiso character(2),
    postalcode character varying(20),
    placename character varying(180),
    state character varying(100),
    statecode character varying(20),
    county character varying(100),
    countycode character varying(20),
    community character varying(100),
    communitycode character varying(20),
    latitude numeric,
    longitude numeric,
    accuracy smallint,
    postalcodeid integer NOT NULL
);


ALTER TABLE pts.postalcode OWNER TO bradley;

--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 172
-- Name: TABLE postalcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE postalcode IS 'Postal codes for the world. The codes were obtained from: http://download.geonames.org/export/zip/
Canadian codes obtained from: http://drupal.org/node/255995 (http://www.freeformsolutions.ca/en/sites/default/files/downloads/zipcodes.ca.mysql.zip). The full UK dataset was not loaded, only three character codes.';


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.countryiso; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.countryiso IS 'iso country code, 2 characters';


--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.state; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.state IS 'geonames admin name1, 1st order subdivision';


--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.statecode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.statecode IS 'geonames admin code1, 1st order subdivision';


--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.county; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.county IS 'geonames admin name2, 2nd order subdivision';


--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.countycode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.countycode IS 'geonames admin code2, 2nd order subdivision';


--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.community; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.community IS 'geonames admin name3, 3rd order subdivision';


--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.communitycode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.communitycode IS 'geonames admin name3, 3rd order subdivision';


--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.latitude; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.latitude IS 'estimated latitude (wgs84)';


--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.longitude; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.longitude IS 'estimated longitude (wgs84)';


--
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN postalcode.accuracy; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN postalcode.accuracy IS 'accuracy of lat/lng from 1=estimated to 6=centroid';


--
-- TOC entry 257 (class 1259 OID 32914)
-- Dependencies: 10 172
-- Name: postalcode_postalcodeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE postalcode_postalcodeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.postalcode_postalcodeid_seq OWNER TO bradley;

--
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 257
-- Name: postalcode_postalcodeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE postalcode_postalcodeid_seq OWNED BY postalcode.postalcodeid;


--
-- TOC entry 258 (class 1259 OID 32916)
-- Dependencies: 3243 10
-- Name: postalcodelist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW postalcodelist AS
    SELECT postalcode.countryiso, postalcode.postalcode, postalcode.placename, postalcode.state, postalcode.statecode, postalcode.postalcodeid, govunit.featureid AS stateid FROM (postalcode JOIN govunit ON ((((govunit.countryalpha = postalcode.countryiso) AND (govunit.statealpha = (postalcode.statecode)::bpchar)) AND ((govunit.unittype)::text = 'STATE'::text))));


ALTER TABLE pts.postalcodelist OWNER TO bradley;

--
-- TOC entry 259 (class 1259 OID 32920)
-- Dependencies: 10
-- Name: progress; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE progress (
    progressid integer NOT NULL,
    deliverableid integer NOT NULL,
    percent integer NOT NULL,
    reportdate date NOT NULL,
    comment character varying
);


ALTER TABLE pts.progress OWNER TO bradley;

--
-- TOC entry 3821 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE progress; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE progress IS 'Indicates progress toward delivery of deliverable';


--
-- TOC entry 3822 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN progress.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN progress.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3823 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN progress.percent; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN progress.percent IS 'Percent of deliverable completed';


--
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN progress.reportdate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN progress.reportdate IS 'Date progress reported';


--
-- TOC entry 260 (class 1259 OID 32926)
-- Dependencies: 10 259
-- Name: progress_progressid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE progress_progressid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.progress_progressid_seq OWNER TO bradley;

--
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 260
-- Name: progress_progressid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE progress_progressid_seq OWNED BY progress.progressid;


--
-- TOC entry 261 (class 1259 OID 32928)
-- Dependencies: 199 10
-- Name: project_projectid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE project_projectid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.project_projectid_seq OWNER TO bradley;

--
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 261
-- Name: project_projectid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE project_projectid_seq OWNED BY project.projectid;


--
-- TOC entry 262 (class 1259 OID 32930)
-- Dependencies: 10
-- Name: projectcomment; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectcomment (
    projectid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    publish boolean NOT NULL,
    stamp timestamp without time zone NOT NULL
);


ALTER TABLE pts.projectcomment OWNER TO bradley;

--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE projectcomment; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE projectcomment IS 'Comments for Project';


--
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN projectcomment.projectid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcomment.projectid IS 'FK for PROJECT';


--
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN projectcomment.contactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcomment.contactid IS 'PK for PERSON';


--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN projectcomment.publish; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcomment.publish IS 'Indicates whether comment should be included with data exports or displayed in public documents';


--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN projectcomment.stamp; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcomment.stamp IS 'Timestamp of comment';


--
-- TOC entry 263 (class 1259 OID 32936)
-- Dependencies: 3294 10
-- Name: projectcontact; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectcontact (
    projectid integer NOT NULL,
    contactid integer NOT NULL,
    roletypeid integer NOT NULL,
    priority smallint NOT NULL,
    contactprojectcode character varying,
    partner boolean DEFAULT false NOT NULL,
    projectcontactid integer NOT NULL
);


ALTER TABLE pts.projectcontact OWNER TO bradley;

--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE projectcontact; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE projectcontact IS 'Identifies project contacts and roles';


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN projectcontact.roletypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcontact.roletypeid IS 'PK for ROLETYPE';


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN projectcontact.contactprojectcode; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcontact.contactprojectcode IS 'Project identifier assigned by contact';


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN projectcontact.projectcontactid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectcontact.projectcontactid IS 'PK for PROJECTCONTACT';


--
-- TOC entry 264 (class 1259 OID 32943)
-- Dependencies: 263 10
-- Name: projectcontact_projectcontactid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE projectcontact_projectcontactid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.projectcontact_projectcontactid_seq OWNER TO bradley;

--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 264
-- Name: projectcontact_projectcontactid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE projectcontact_projectcontactid_seq OWNED BY projectcontact.projectcontactid;


--
-- TOC entry 265 (class 1259 OID 32945)
-- Dependencies: 3244 10
-- Name: projectcontactlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW projectcontactlist AS
    SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, pg_catalog.concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name FROM (projectcontact JOIN person USING (contactid)) UNION SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, contactgroup.name FROM (projectcontact JOIN contactgroup USING (contactid)) ORDER BY 5;


ALTER TABLE pts.projectcontactlist OWNER TO bradley;

--
-- TOC entry 266 (class 1259 OID 32950)
-- Dependencies: 3245 10
-- Name: projectfunderlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW projectfunderlist AS
    SELECT projectcontactlist.projectcontactid, projectcontactlist.projectid, projectcontactlist.contactid, projectcontactlist.roletypeid, projectcontactlist.priority, projectcontactlist.contactprojectcode, projectcontactlist.partner, projectcontactlist.name FROM projectcontactlist WHERE (projectcontactlist.roletypeid = 4) ORDER BY projectcontactlist.name;


ALTER TABLE pts.projectfunderlist OWNER TO bradley;

--
-- TOC entry 267 (class 1259 OID 32954)
-- Dependencies: 10
-- Name: projectgnis; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectgnis (
    projectid integer NOT NULL,
    gnisid integer NOT NULL
);


ALTER TABLE pts.projectgnis OWNER TO bradley;

--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE projectgnis; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE projectgnis IS 'Links GNIS to projects';


--
-- TOC entry 268 (class 1259 OID 32957)
-- Dependencies: 10
-- Name: projectitis; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectitis (
    tsn integer NOT NULL,
    projectid integer NOT NULL
);


ALTER TABLE pts.projectitis OWNER TO bradley;

--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE projectitis; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE projectitis IS 'Links taxonomic identifiers to projects';


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN projectitis.tsn; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectitis.tsn IS 'FK for ITIS';


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 268
-- Name: COLUMN projectitis.projectid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN projectitis.projectid IS 'PK for PROJECT';


--
-- TOC entry 269 (class 1259 OID 32960)
-- Dependencies: 10
-- Name: projectline; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectline (
    projectid integer NOT NULL,
    fid integer NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE pts.projectline OWNER TO bradley;

--
-- TOC entry 3348 (class 2606 OID 32967)
-- Dependencies: 199 199
-- Name: projectid; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY project
    ADD CONSTRAINT projectid PRIMARY KEY (projectid);


--
-- TOC entry 270 (class 1259 OID 32968)
-- Dependencies: 3246 10
-- Name: projectlist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW projectlist AS
    SELECT DISTINCT project.projectid, project.orgid, form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(sum(funding.amount), (0)::numeric) AS allocated, COALESCE(sum(invoice.amount), (0)::numeric) AS invoiced, (COALESCE(sum(funding.amount), (0)::numeric) - COALESCE(sum(invoice.amount), (0)::numeric)) AS difference FROM ((((project JOIN contactgroup ON ((project.orgid = contactgroup.contactid))) LEFT JOIN modification USING (projectid)) LEFT JOIN funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1)))) LEFT JOIN invoice USING (fundingid)) GROUP BY project.projectid, contactgroup.acronym;


ALTER TABLE pts.projectlist OWNER TO bradley;

--
-- TOC entry 271 (class 1259 OID 32973)
-- Dependencies: 10
-- Name: projectpoint; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectpoint (
    projectid integer NOT NULL,
    fid integer NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE pts.projectpoint OWNER TO bradley;

--
-- TOC entry 272 (class 1259 OID 32979)
-- Dependencies: 10
-- Name: projectpolygon; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE projectpolygon (
    projectid integer NOT NULL,
    fid integer NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE pts.projectpolygon OWNER TO bradley;

--
-- TOC entry 273 (class 1259 OID 32985)
-- Dependencies: 10
-- Name: purchaserequest; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE purchaserequest (
    purchaserequest character varying NOT NULL,
    modificationid integer NOT NULL,
    comment character varying,
    purchaserequestid integer NOT NULL
);


ALTER TABLE pts.purchaserequest OWNER TO bradley;

--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE purchaserequest; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE purchaserequest IS 'purchade requests associated with modification';


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN purchaserequest.purchaserequest; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN purchaserequest.purchaserequest IS 'number of purchase request';


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN purchaserequest.modificationid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN purchaserequest.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 274 (class 1259 OID 32991)
-- Dependencies: 10 273
-- Name: purchaserequest_purchaserequestid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE purchaserequest_purchaserequestid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.purchaserequest_purchaserequestid_seq OWNER TO bradley;

--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 274
-- Name: purchaserequest_purchaserequestid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE purchaserequest_purchaserequestid_seq OWNED BY purchaserequest.purchaserequestid;


--
-- TOC entry 275 (class 1259 OID 32993)
-- Dependencies: 10
-- Name: reminder; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE reminder (
    reminderid integer NOT NULL,
    deliverableid integer NOT NULL,
    senddate date NOT NULL,
    message character varying NOT NULL,
    sentdate date NOT NULL,
    dayinterval smallint NOT NULL
);


ALTER TABLE pts.reminder OWNER TO bradley;

--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE reminder; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE reminder IS 'Tracks notifications to be sent with respect to deilverables';


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN reminder.reminderid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN reminder.reminderid IS 'PK for REMINDER';


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN reminder.deliverableid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN reminder.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN reminder.senddate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN reminder.senddate IS 'The date to send the reminder';


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN reminder.message; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN reminder.message IS 'Text to be sent as body of the reminder';


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN reminder.sentdate; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN reminder.sentdate IS 'Date the reminder was actually sent';


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN reminder.dayinterval; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN reminder.dayinterval IS 'Interval in days to repeat reminder';


--
-- TOC entry 276 (class 1259 OID 32999)
-- Dependencies: 10 275
-- Name: reminder_reminderid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE reminder_reminderid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.reminder_reminderid_seq OWNER TO bradley;

--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 276
-- Name: reminder_reminderid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE reminder_reminderid_seq OWNED BY reminder.reminderid;


--
-- TOC entry 277 (class 1259 OID 33001)
-- Dependencies: 10
-- Name: remindercontact; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE remindercontact (
    reminderid integer NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE pts.remindercontact OWNER TO bradley;

--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE remindercontact; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE remindercontact IS 'Contacts associated with a reminder';


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN remindercontact.reminderid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN remindercontact.reminderid IS 'PK for REMINDER';


--
-- TOC entry 278 (class 1259 OID 33004)
-- Dependencies: 10
-- Name: roletype; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE roletype (
    roletypeid integer NOT NULL,
    code character varying NOT NULL,
    roletype character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE pts.roletype OWNER TO bradley;

--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN roletype.roletypeid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN roletype.roletypeid IS 'PK for ROLETYPE';


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN roletype.code; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN roletype.code IS 'code for roletype';


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN roletype.roletype; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN roletype.roletype IS 'type of role';


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN roletype.description; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN roletype.description IS 'description of roletype';


--
-- TOC entry 279 (class 1259 OID 33010)
-- Dependencies: 10 278
-- Name: roletype_roletypeid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE roletype_roletypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.roletype_roletypeid_seq OWNER TO bradley;

--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 279
-- Name: roletype_roletypeid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE roletype_roletypeid_seq OWNED BY roletype.roletypeid;


--
-- TOC entry 280 (class 1259 OID 33012)
-- Dependencies: 3247 10
-- Name: statelist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW statelist AS
    SELECT govunit.featureid AS stateid, govunit.unittype, govunit.statenumeric, govunit.statealpha, govunit.statename, govunit.countryalpha, govunit.countryname, govunit.featurename FROM govunit WHERE ((govunit.unittype)::text = 'STATE'::text) ORDER BY govunit.statename;


ALTER TABLE pts.statelist OWNER TO bradley;

--
-- TOC entry 281 (class 1259 OID 33016)
-- Dependencies: 10
-- Name: status; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE status (
    statusid integer NOT NULL,
    code character varying NOT NULL,
    status character varying NOT NULL,
    description character varying NOT NULL,
    comment character varying
);


ALTER TABLE pts.status OWNER TO bradley;

--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE status; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE status IS 'status of PROJECT';


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN status.statusid; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN status.statusid IS 'PK for STATUS';


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN status.code; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN status.code IS 'code for status';


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN status.status; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN status.status IS 'status of PROJECT';


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 281
-- Name: COLUMN status.description; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN status.description IS 'description of status';


--
-- TOC entry 282 (class 1259 OID 33022)
-- Dependencies: 10 281
-- Name: status_statusid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE status_statusid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.status_statusid_seq OWNER TO bradley;

--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 282
-- Name: status_statusid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE status_statusid_seq OWNED BY status.statusid;


--
-- TOC entry 283 (class 1259 OID 33024)
-- Dependencies: 3248 10
-- Name: statuslist; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW statuslist AS
    SELECT s.statusid, m.modtypeid, s.code, s.status, s.description FROM (status s JOIN modtypestatus m USING (statusid));


ALTER TABLE pts.statuslist OWNER TO bradley;

--
-- TOC entry 284 (class 1259 OID 33028)
-- Dependencies: 3249 10
-- Name: task; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW task AS
    SELECT deliverablemod.deliverableid, person.contactid, deliverable.title, deliverablemod.duedate, deliverablemod.receiveddate, (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS assignee, deliverable.description FROM ((deliverablemod JOIN deliverable USING (deliverableid)) JOIN person ON ((deliverablemod.personid = person.contactid))) WHERE ((deliverable.deliverabletypeid = ANY (ARRAY[4, 7])) AND ((NOT deliverablemod.invalid) OR (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))))) ORDER BY deliverablemod.duedate DESC;


ALTER TABLE pts.task OWNER TO bradley;

--
-- TOC entry 285 (class 1259 OID 33033)
-- Dependencies: 10
-- Name: timeline; Type: TABLE; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE TABLE timeline (
    timelineid integer NOT NULL,
    factid integer NOT NULL,
    description character varying NOT NULL,
    startdate date NOT NULL,
    enddate date
);


ALTER TABLE pts.timeline OWNER TO bradley;

--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE timeline; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON TABLE timeline IS 'Project timeline associated with factsheet';


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN timeline.description; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON COLUMN timeline.description IS 'Timeline entry';


--
-- TOC entry 286 (class 1259 OID 33039)
-- Dependencies: 10 285
-- Name: timeline_timelineid_seq; Type: SEQUENCE; Schema: pts; Owner: bradley
--

CREATE SEQUENCE timeline_timelineid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pts.timeline_timelineid_seq OWNER TO bradley;

--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 286
-- Name: timeline_timelineid_seq; Type: SEQUENCE OWNED BY; Schema: pts; Owner: bradley
--

ALTER SEQUENCE timeline_timelineid_seq OWNED BY timeline.timelineid;


--
-- TOC entry 287 (class 1259 OID 33041)
-- Dependencies: 3250 10
-- Name: userinfo; Type: VIEW; Schema: pts; Owner: bradley
--

CREATE VIEW userinfo AS
    SELECT login.loginid, login.contactid, login.groupid, login.username, person.firstname, person.lastname, person.middlename, person.suffix, contactgroup.name AS groupname, contactgroup.acronym FROM ((login JOIN contactgroup ON ((login.groupid = contactgroup.contactid))) JOIN person ON ((login.contactid = person.contactid)));


ALTER TABLE pts.userinfo OWNER TO bradley;

--
-- TOC entry 3253 (class 2604 OID 33045)
-- Dependencies: 174 173
-- Name: addressid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY address ALTER COLUMN addressid SET DEFAULT nextval('address_addressid_seq'::regclass);


--
-- TOC entry 3254 (class 2604 OID 33046)
-- Dependencies: 177 176
-- Name: auditid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY audit ALTER COLUMN auditid SET DEFAULT nextval('audit_auditid_seq'::regclass);


--
-- TOC entry 3256 (class 2604 OID 33047)
-- Dependencies: 179 178
-- Name: contactid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contact ALTER COLUMN contactid SET DEFAULT nextval('contact_contactid_seq'::regclass);


--
-- TOC entry 3257 (class 2604 OID 33048)
-- Dependencies: 181 180
-- Name: contactcontactgroupid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contactcontactgroup ALTER COLUMN contactcontactgroupid SET DEFAULT nextval('contactcontactgroup_contactcontactgroupid_seq'::regclass);


--
-- TOC entry 3258 (class 2604 OID 33049)
-- Dependencies: 185 184
-- Name: contacttypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contacttype ALTER COLUMN contacttypeid SET DEFAULT nextval('contacttype_contacttypeid_seq'::regclass);


--
-- TOC entry 3259 (class 2604 OID 33050)
-- Dependencies: 187 186
-- Name: costcodeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY costcode ALTER COLUMN costcodeid SET DEFAULT nextval('costcode_costcodeid_seq'::regclass);


--
-- TOC entry 3260 (class 2604 OID 33051)
-- Dependencies: 189 188
-- Name: costcodeinvoiceid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY costcodeinvoice ALTER COLUMN costcodeinvoiceid SET DEFAULT nextval('costcodeinvoice_costcodeinvoiceid_seq'::regclass);


--
-- TOC entry 3261 (class 2604 OID 33052)
-- Dependencies: 193 192
-- Name: deliverableid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverable ALTER COLUMN deliverableid SET DEFAULT nextval('deliverable_deliverableid_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 33053)
-- Dependencies: 207 205
-- Name: eaddressid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY eaddress ALTER COLUMN eaddressid SET DEFAULT nextval('electadd_electaddid_seq'::regclass);


--
-- TOC entry 3271 (class 2604 OID 33054)
-- Dependencies: 208 206
-- Name: eaddresstypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY eaddresstype ALTER COLUMN eaddresstypeid SET DEFAULT nextval('electaddtype_electaddtypeid_seq'::regclass);


--
-- TOC entry 3272 (class 2604 OID 33055)
-- Dependencies: 210 209
-- Name: factid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fact ALTER COLUMN factid SET DEFAULT nextval('fact_factid_seq'::regclass);


--
-- TOC entry 3275 (class 2604 OID 33056)
-- Dependencies: 215 214
-- Name: filetypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY filetype ALTER COLUMN filetypeid SET DEFAULT nextval('filetype_filetypeid_seq'::regclass);


--
-- TOC entry 3276 (class 2604 OID 33057)
-- Dependencies: 217 216
-- Name: fileversionid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion ALTER COLUMN fileversionid SET DEFAULT nextval('fileversion_fileversionid_seq'::regclass);


--
-- TOC entry 3277 (class 2604 OID 33058)
-- Dependencies: 219 218
-- Name: formatid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY format ALTER COLUMN formatid SET DEFAULT nextval('format_formatid_seq'::regclass);


--
-- TOC entry 3278 (class 2604 OID 33059)
-- Dependencies: 221 220
-- Name: fundingid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY funding ALTER COLUMN fundingid SET DEFAULT nextval('funding_fundingid_seq'::regclass);


--
-- TOC entry 3279 (class 2604 OID 33060)
-- Dependencies: 223 222
-- Name: fundingtypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fundingtype ALTER COLUMN fundingtypeid SET DEFAULT nextval('fundingtype_fundingtypeid_seq'::regclass);


--
-- TOC entry 3280 (class 2604 OID 33061)
-- Dependencies: 227 226
-- Name: invoiceid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY invoice ALTER COLUMN invoiceid SET DEFAULT nextval('invoice_invoiceid_seq'::regclass);


--
-- TOC entry 3281 (class 2604 OID 33062)
-- Dependencies: 231 230
-- Name: fid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY line ALTER COLUMN fid SET DEFAULT nextval('line_fid_seq'::regclass);


--
-- TOC entry 3282 (class 2604 OID 33063)
-- Dependencies: 233 232
-- Name: loginid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY login ALTER COLUMN loginid SET DEFAULT nextval('login_loginid_seq'::regclass);


--
-- TOC entry 3284 (class 2604 OID 33064)
-- Dependencies: 238 237
-- Name: modcontacttypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modcontacttype ALTER COLUMN modcontacttypeid SET DEFAULT nextval('modcontacttype_modcontacttypeid_seq'::regclass);


--
-- TOC entry 3265 (class 2604 OID 33065)
-- Dependencies: 239 197
-- Name: modificationid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modification ALTER COLUMN modificationid SET DEFAULT nextval('modification_modificationid_seq'::regclass);


--
-- TOC entry 3286 (class 2604 OID 33066)
-- Dependencies: 243 242
-- Name: modstatusid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modstatus ALTER COLUMN modstatusid SET DEFAULT nextval('modstatus_modstatusid_seq'::regclass);


--
-- TOC entry 3285 (class 2604 OID 33067)
-- Dependencies: 244 240
-- Name: modtypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modtype ALTER COLUMN modtypeid SET DEFAULT nextval('modtype_modtypeid_seq'::regclass);


--
-- TOC entry 3288 (class 2604 OID 33068)
-- Dependencies: 248 246
-- Name: phoneid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY phone ALTER COLUMN phoneid SET DEFAULT nextval('phone_phoneid_seq'::regclass);


--
-- TOC entry 3289 (class 2604 OID 33069)
-- Dependencies: 250 249
-- Name: phonetypeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY phonetype ALTER COLUMN phonetypeid SET DEFAULT nextval('phonetype_phonetypeid_seq'::regclass);


--
-- TOC entry 3290 (class 2604 OID 33070)
-- Dependencies: 252 251
-- Name: fid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY point ALTER COLUMN fid SET DEFAULT nextval('point_fid_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 33071)
-- Dependencies: 254 253
-- Name: fid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY polygon ALTER COLUMN fid SET DEFAULT nextval('polygon_fid_seq'::regclass);


--
-- TOC entry 3292 (class 2604 OID 33072)
-- Dependencies: 256 255
-- Name: positionid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY "position" ALTER COLUMN positionid SET DEFAULT nextval('position_positionid_seq'::regclass);


--
-- TOC entry 3251 (class 2604 OID 33073)
-- Dependencies: 257 172
-- Name: postalcodeid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY postalcode ALTER COLUMN postalcodeid SET DEFAULT nextval('postalcode_postalcodeid_seq'::regclass);


--
-- TOC entry 3293 (class 2604 OID 33074)
-- Dependencies: 260 259
-- Name: progressid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY progress ALTER COLUMN progressid SET DEFAULT nextval('progress_progressid_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 33075)
-- Dependencies: 261 199
-- Name: projectid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY project ALTER COLUMN projectid SET DEFAULT nextval('project_projectid_seq'::regclass);


--
-- TOC entry 3295 (class 2604 OID 33076)
-- Dependencies: 264 263
-- Name: projectcontactid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectcontact ALTER COLUMN projectcontactid SET DEFAULT nextval('projectcontact_projectcontactid_seq'::regclass);


--
-- TOC entry 3296 (class 2604 OID 33077)
-- Dependencies: 274 273
-- Name: purchaserequestid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY purchaserequest ALTER COLUMN purchaserequestid SET DEFAULT nextval('purchaserequest_purchaserequestid_seq'::regclass);


--
-- TOC entry 3297 (class 2604 OID 33078)
-- Dependencies: 276 275
-- Name: reminderid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY reminder ALTER COLUMN reminderid SET DEFAULT nextval('reminder_reminderid_seq'::regclass);


--
-- TOC entry 3298 (class 2604 OID 33079)
-- Dependencies: 286 285
-- Name: timelineid; Type: DEFAULT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY timeline ALTER COLUMN timelineid SET DEFAULT nextval('timeline_timelineid_seq'::regclass);


--
-- TOC entry 3306 (class 2606 OID 33081)
-- Dependencies: 173 173 173 173
-- Name: address_contactid_addresstypeid_priority_key; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_contactid_addresstypeid_priority_key UNIQUE (contactid, addresstypeid, priority);


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 3306
-- Name: CONSTRAINT address_contactid_addresstypeid_priority_key ON address; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON CONSTRAINT address_contactid_addresstypeid_priority_key ON address IS 'Combination of addresstype and priority must be unique for each contact';


--
-- TOC entry 3311 (class 2606 OID 33083)
-- Dependencies: 175 175
-- Name: addresstype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY addresstype
    ADD CONSTRAINT addresstype_pk PRIMARY KEY (addresstypeid);


--
-- TOC entry 3313 (class 2606 OID 33085)
-- Dependencies: 176 176
-- Name: audit_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY audit
    ADD CONSTRAINT audit_pk PRIMARY KEY (auditid);


--
-- TOC entry 3321 (class 2606 OID 33087)
-- Dependencies: 182 182
-- Name: chargecode_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY contactcostcode
    ADD CONSTRAINT chargecode_pk PRIMARY KEY (costcode);


--
-- TOC entry 3317 (class 2606 OID 33089)
-- Dependencies: 180 180 180 180
-- Name: contactcontactgroup_groupid_contactid_positionid_key; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY contactcontactgroup
    ADD CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key UNIQUE (groupid, contactid, positionid);


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 3317
-- Name: CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key ON contactcontactgroup; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key ON contactcontactgroup IS 'Right now we are not allowing contacts to be assigned multiple positions within a group.';


--
-- TOC entry 3319 (class 2606 OID 33091)
-- Dependencies: 180 180
-- Name: contactcontactgroup_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY contactcontactgroup
    ADD CONSTRAINT contactcontactgroup_pk PRIMARY KEY (contactcontactgroupid);


--
-- TOC entry 3325 (class 2606 OID 33093)
-- Dependencies: 184 184
-- Name: contacttype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY contacttype
    ADD CONSTRAINT contacttype_pk PRIMARY KEY (contacttypeid);


--
-- TOC entry 3327 (class 2606 OID 33095)
-- Dependencies: 186 186
-- Name: costcode_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY costcode
    ADD CONSTRAINT costcode_pk PRIMARY KEY (costcodeid);


--
-- TOC entry 3329 (class 2606 OID 33097)
-- Dependencies: 188 188
-- Name: costcodeinvoice_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY costcodeinvoice
    ADD CONSTRAINT costcodeinvoice_pk PRIMARY KEY (costcodeinvoiceid);


--
-- TOC entry 3300 (class 2606 OID 33099)
-- Dependencies: 171 171
-- Name: country_pkey; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (countryiso);


--
-- TOC entry 3334 (class 2606 OID 33101)
-- Dependencies: 192 192
-- Name: deliverable_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY deliverable
    ADD CONSTRAINT deliverable_pk PRIMARY KEY (deliverableid);


--
-- TOC entry 3351 (class 2606 OID 33103)
-- Dependencies: 201 201 201
-- Name: deliverablecomment_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY deliverablecomment
    ADD CONSTRAINT deliverablecomment_pk PRIMARY KEY (deliverableid, contactid);


--
-- TOC entry 3353 (class 2606 OID 33105)
-- Dependencies: 202 202 202
-- Name: deliverablecontact_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY deliverablecontact
    ADD CONSTRAINT deliverablecontact_pk PRIMARY KEY (deliverableid, contactid);


--
-- TOC entry 3336 (class 2606 OID 33107)
-- Dependencies: 194 194 194
-- Name: deliverablemod_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY deliverablemod
    ADD CONSTRAINT deliverablemod_pk PRIMARY KEY (modificationid, deliverableid);


--
-- TOC entry 3338 (class 2606 OID 33109)
-- Dependencies: 196 196
-- Name: deliverabletype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY deliverabletype
    ADD CONSTRAINT deliverabletype_pk PRIMARY KEY (deliverabletypeid);


--
-- TOC entry 3355 (class 2606 OID 33111)
-- Dependencies: 205 205 205 205
-- Name: electadd_contactid_electaddtypeid_priority_key; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY eaddress
    ADD CONSTRAINT electadd_contactid_electaddtypeid_priority_key UNIQUE (contactid, eaddresstypeid, priority);


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 3355
-- Name: CONSTRAINT electadd_contactid_electaddtypeid_priority_key ON eaddress; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON CONSTRAINT electadd_contactid_electaddtypeid_priority_key ON eaddress IS 'Combination of electaddtype and priority must be unique for each contact';


--
-- TOC entry 3357 (class 2606 OID 33113)
-- Dependencies: 205 205
-- Name: electadd_pkey; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY eaddress
    ADD CONSTRAINT electadd_pkey PRIMARY KEY (eaddressid);


--
-- TOC entry 3359 (class 2606 OID 33115)
-- Dependencies: 206 206
-- Name: electaddtype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY eaddresstype
    ADD CONSTRAINT electaddtype_pk PRIMARY KEY (eaddresstypeid);


--
-- TOC entry 3361 (class 2606 OID 33117)
-- Dependencies: 209 209
-- Name: fact_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY fact
    ADD CONSTRAINT fact_pk PRIMARY KEY (factid);


--
-- TOC entry 3363 (class 2606 OID 33119)
-- Dependencies: 211 211 211
-- Name: factfile_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY factfile
    ADD CONSTRAINT factfile_pk PRIMARY KEY (factid, fileid);


--
-- TOC entry 3365 (class 2606 OID 33121)
-- Dependencies: 212 212
-- Name: file_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_pk PRIMARY KEY (fileid);


--
-- TOC entry 3367 (class 2606 OID 33123)
-- Dependencies: 213 213 213
-- Name: filecomment_pkey; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY filecomment
    ADD CONSTRAINT filecomment_pkey PRIMARY KEY (fileid, contactid);


--
-- TOC entry 3369 (class 2606 OID 33125)
-- Dependencies: 214 214
-- Name: filetype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY filetype
    ADD CONSTRAINT filetype_pk PRIMARY KEY (filetypeid);


--
-- TOC entry 3374 (class 2606 OID 33127)
-- Dependencies: 216 216
-- Name: fileversion_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT fileversion_pk PRIMARY KEY (fileversionid);


--
-- TOC entry 3378 (class 2606 OID 33129)
-- Dependencies: 218 218
-- Name: format_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY format
    ADD CONSTRAINT format_pk PRIMARY KEY (formatid);


--
-- TOC entry 3380 (class 2606 OID 33131)
-- Dependencies: 220 220
-- Name: funding_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT funding_pk PRIMARY KEY (fundingid);


--
-- TOC entry 3382 (class 2606 OID 33133)
-- Dependencies: 222 222
-- Name: fundingtype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY fundingtype
    ADD CONSTRAINT fundingtype_pk PRIMARY KEY (fundingtypeid);


--
-- TOC entry 3331 (class 2606 OID 33135)
-- Dependencies: 190 190
-- Name: govunit_pkey; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY govunit
    ADD CONSTRAINT govunit_pkey PRIMARY KEY (featureid);


--
-- TOC entry 3384 (class 2606 OID 33137)
-- Dependencies: 226 226
-- Name: invoice_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT invoice_pk PRIMARY KEY (invoiceid);


--
-- TOC entry 3386 (class 2606 OID 33139)
-- Dependencies: 228 228 228
-- Name: invoicecomment_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY invoicecomment
    ADD CONSTRAINT invoicecomment_pk PRIMARY KEY (invoiceid, contactid);


--
-- TOC entry 3388 (class 2606 OID 33141)
-- Dependencies: 230 230
-- Name: line_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_pk PRIMARY KEY (fid);


--
-- TOC entry 3391 (class 2606 OID 33143)
-- Dependencies: 232 232
-- Name: loginid; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY login
    ADD CONSTRAINT loginid PRIMARY KEY (loginid);


--
-- TOC entry 3393 (class 2606 OID 33145)
-- Dependencies: 235 235 235
-- Name: modcomment_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modcomment
    ADD CONSTRAINT modcomment_pk PRIMARY KEY (modificationid, contactid);


--
-- TOC entry 3395 (class 2606 OID 33147)
-- Dependencies: 236 236 236
-- Name: modcontact_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modcontact
    ADD CONSTRAINT modcontact_pk PRIMARY KEY (contactid, modificationid);


--
-- TOC entry 3397 (class 2606 OID 33149)
-- Dependencies: 237 237
-- Name: modcontacttype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modcontacttype
    ADD CONSTRAINT modcontacttype_pk PRIMARY KEY (modcontacttypeid);


--
-- TOC entry 3340 (class 2606 OID 33151)
-- Dependencies: 197 197
-- Name: modification_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modification
    ADD CONSTRAINT modification_pk PRIMARY KEY (modificationid);


--
-- TOC entry 3402 (class 2606 OID 33153)
-- Dependencies: 242 242
-- Name: modstatus_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modstatus
    ADD CONSTRAINT modstatus_pk PRIMARY KEY (modstatusid);


--
-- TOC entry 3399 (class 2606 OID 33155)
-- Dependencies: 240 240
-- Name: modtype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modtype
    ADD CONSTRAINT modtype_pk PRIMARY KEY (modtypeid);


--
-- TOC entry 3404 (class 2606 OID 33157)
-- Dependencies: 245 245 245
-- Name: modtypestatus_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY modtypestatus
    ADD CONSTRAINT modtypestatus_pk PRIMARY KEY (modtypeid, statusid);


--
-- TOC entry 3342 (class 2606 OID 33159)
-- Dependencies: 198 198
-- Name: personid_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY person
    ADD CONSTRAINT personid_pk PRIMARY KEY (contactid);


--
-- TOC entry 3407 (class 2606 OID 33161)
-- Dependencies: 246 246 246 246
-- Name: phone_contactid_phonetypeid_priority_key; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY phone
    ADD CONSTRAINT phone_contactid_phonetypeid_priority_key UNIQUE (contactid, phonetypeid, priority);


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 3407
-- Name: CONSTRAINT phone_contactid_phonetypeid_priority_key ON phone; Type: COMMENT; Schema: pts; Owner: bradley
--

COMMENT ON CONSTRAINT phone_contactid_phonetypeid_priority_key ON phone IS 'Combination of phonetype and priority must be unique for each contact';


--
-- TOC entry 3409 (class 2606 OID 33163)
-- Dependencies: 246 246
-- Name: phone_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY phone
    ADD CONSTRAINT phone_pk PRIMARY KEY (phoneid);


--
-- TOC entry 3411 (class 2606 OID 33165)
-- Dependencies: 249 249
-- Name: phonetype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY phonetype
    ADD CONSTRAINT phonetype_pk PRIMARY KEY (phonetypeid);


--
-- TOC entry 3309 (class 2606 OID 33167)
-- Dependencies: 173 173
-- Name: pk_address; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT pk_address PRIMARY KEY (addressid);


--
-- TOC entry 3315 (class 2606 OID 33169)
-- Dependencies: 178 178
-- Name: pk_contact; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT pk_contact PRIMARY KEY (contactid);


--
-- TOC entry 3323 (class 2606 OID 33171)
-- Dependencies: 183 183
-- Name: pk_unit; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY contactgroup
    ADD CONSTRAINT pk_unit PRIMARY KEY (contactid);


--
-- TOC entry 3413 (class 2606 OID 33173)
-- Dependencies: 251 251
-- Name: point_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY point
    ADD CONSTRAINT point_pk PRIMARY KEY (fid);


--
-- TOC entry 3415 (class 2606 OID 33175)
-- Dependencies: 253 253
-- Name: polygon_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY polygon
    ADD CONSTRAINT polygon_pk PRIMARY KEY (fid);


--
-- TOC entry 3417 (class 2606 OID 33177)
-- Dependencies: 255 255
-- Name: position_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY "position"
    ADD CONSTRAINT position_pk PRIMARY KEY (positionid);


--
-- TOC entry 3304 (class 2606 OID 33179)
-- Dependencies: 172 172
-- Name: postalcode_pkey; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY postalcode
    ADD CONSTRAINT postalcode_pkey PRIMARY KEY (postalcodeid);


--
-- TOC entry 3419 (class 2606 OID 33181)
-- Dependencies: 259 259
-- Name: progress_pkey; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY progress
    ADD CONSTRAINT progress_pkey PRIMARY KEY (progressid);


--
-- TOC entry 3345 (class 2606 OID 33183)
-- Dependencies: 199 199 199 199
-- Name: project_orgid_fiscalyear_number_key; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_orgid_fiscalyear_number_key UNIQUE (orgid, fiscalyear, number);


--
-- TOC entry 3421 (class 2606 OID 33185)
-- Dependencies: 262 262 262
-- Name: projectcomment_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectcomment
    ADD CONSTRAINT projectcomment_pk PRIMARY KEY (projectid, contactid);


--
-- TOC entry 3423 (class 2606 OID 33187)
-- Dependencies: 263 263
-- Name: projectcontact_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectcontact
    ADD CONSTRAINT projectcontact_pk PRIMARY KEY (projectcontactid);


--
-- TOC entry 3425 (class 2606 OID 33189)
-- Dependencies: 263 263 263 263
-- Name: projectcontact_projectid_roletypeid_contactid_key; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectcontact
    ADD CONSTRAINT projectcontact_projectid_roletypeid_contactid_key UNIQUE (projectid, roletypeid, contactid);


--
-- TOC entry 3427 (class 2606 OID 33191)
-- Dependencies: 267 267
-- Name: projectgnis_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectgnis
    ADD CONSTRAINT projectgnis_pk PRIMARY KEY (projectid);


--
-- TOC entry 3429 (class 2606 OID 33193)
-- Dependencies: 268 268 268
-- Name: projectitis_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectitis
    ADD CONSTRAINT projectitis_pk PRIMARY KEY (tsn, projectid);


--
-- TOC entry 3431 (class 2606 OID 33195)
-- Dependencies: 269 269 269
-- Name: projectline_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectline
    ADD CONSTRAINT projectline_pk PRIMARY KEY (projectid, fid);


--
-- TOC entry 3433 (class 2606 OID 33197)
-- Dependencies: 271 271 271
-- Name: projectpoint_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectpoint
    ADD CONSTRAINT projectpoint_pk PRIMARY KEY (projectid, fid);


--
-- TOC entry 3435 (class 2606 OID 33199)
-- Dependencies: 272 272 272
-- Name: projectpolygon_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY projectpolygon
    ADD CONSTRAINT projectpolygon_pk PRIMARY KEY (projectid, fid);


--
-- TOC entry 3437 (class 2606 OID 33201)
-- Dependencies: 273 273
-- Name: purchaserequest_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY purchaserequest
    ADD CONSTRAINT purchaserequest_pk PRIMARY KEY (purchaserequestid);


--
-- TOC entry 3439 (class 2606 OID 33203)
-- Dependencies: 275 275
-- Name: reminder_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY reminder
    ADD CONSTRAINT reminder_pk PRIMARY KEY (reminderid);


--
-- TOC entry 3441 (class 2606 OID 33205)
-- Dependencies: 277 277 277
-- Name: remindercontact_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY remindercontact
    ADD CONSTRAINT remindercontact_pk PRIMARY KEY (reminderid, contactid);


--
-- TOC entry 3443 (class 2606 OID 33207)
-- Dependencies: 278 278
-- Name: roletype_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY roletype
    ADD CONSTRAINT roletype_pk PRIMARY KEY (roletypeid);


--
-- TOC entry 3445 (class 2606 OID 33209)
-- Dependencies: 281 281
-- Name: status_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY status
    ADD CONSTRAINT status_pk PRIMARY KEY (statusid);


--
-- TOC entry 3447 (class 2606 OID 33211)
-- Dependencies: 285 285
-- Name: timeline_pk; Type: CONSTRAINT; Schema: pts; Owner: bradley; Tablespace: 
--

ALTER TABLE ONLY timeline
    ADD CONSTRAINT timeline_pk PRIMARY KEY (timelineid);


--
-- TOC entry 3370 (class 1259 OID 33212)
-- Dependencies: 216 216
-- Name: fileversion_deliverable_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX fileversion_deliverable_idx ON fileversion USING btree (fileid, deliverableid);


--
-- TOC entry 3371 (class 1259 OID 33213)
-- Dependencies: 216 216
-- Name: fileversion_invoice_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX fileversion_invoice_idx ON fileversion USING btree (fileid, invoiceid);


--
-- TOC entry 3372 (class 1259 OID 33214)
-- Dependencies: 216 216
-- Name: fileversion_modification_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX fileversion_modification_idx ON fileversion USING btree (fileid, modificationid);


--
-- TOC entry 3375 (class 1259 OID 33215)
-- Dependencies: 216 216
-- Name: fileversion_progress_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX fileversion_progress_idx ON fileversion USING btree (fileid, progressid);


--
-- TOC entry 3376 (class 1259 OID 33216)
-- Dependencies: 216 216
-- Name: fileversion_project_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX fileversion_project_idx ON fileversion USING btree (fileid, projectid);


--
-- TOC entry 3343 (class 1259 OID 33217)
-- Dependencies: 199
-- Name: fki_contactgroup_project_fk; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE INDEX fki_contactgroup_project_fk ON project USING btree (orgid);


--
-- TOC entry 3405 (class 1259 OID 33218)
-- Dependencies: 246
-- Name: fki_country_phone_fk; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE INDEX fki_country_phone_fk ON phone USING btree (countryiso);


--
-- TOC entry 3301 (class 1259 OID 33219)
-- Dependencies: 172
-- Name: fki_country_postalcode_fk; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE INDEX fki_country_postalcode_fk ON postalcode USING btree (countryiso);


--
-- TOC entry 3307 (class 1259 OID 33221)
-- Dependencies: 173
-- Name: fki_govunit_address_state_fk; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE INDEX fki_govunit_address_state_fk ON address USING btree (stateid);


--
-- TOC entry 3332 (class 1259 OID 33222)
-- Dependencies: 190
-- Name: govunit_unittype_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE INDEX govunit_unittype_idx ON govunit USING btree (unittype);


--
-- TOC entry 3389 (class 1259 OID 33223)
-- Dependencies: 232
-- Name: login_username_uidx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX login_username_uidx ON login USING btree (username);


--
-- TOC entry 3400 (class 1259 OID 33224)
-- Dependencies: 242 242
-- Name: modstatus_modificationid_statusid_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX modstatus_modificationid_statusid_idx ON modstatus USING btree (modificationid, statusid);


--
-- TOC entry 3302 (class 1259 OID 33225)
-- Dependencies: 172
-- Name: postalcode_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE INDEX postalcode_idx ON postalcode USING btree (postalcode);


--
-- TOC entry 3346 (class 1259 OID 33226)
-- Dependencies: 199 199 199
-- Name: projectcode_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX projectcode_idx ON project USING btree (fiscalyear, number, orgid);


--
-- TOC entry 3349 (class 1259 OID 33227)
-- Dependencies: 199
-- Name: uuid_idx; Type: INDEX; Schema: pts; Owner: bradley; Tablespace: 
--

CREATE UNIQUE INDEX uuid_idx ON project USING btree (uuid);


--
-- TOC entry 3515 (class 2606 OID 33228)
-- Dependencies: 246 3308 173
-- Name: address_phone_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY phone
    ADD CONSTRAINT address_phone_fk FOREIGN KEY (addressid) REFERENCES address(addressid);


--
-- TOC entry 3449 (class 2606 OID 33233)
-- Dependencies: 3310 173 175
-- Name: addresstype_address_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY address
    ADD CONSTRAINT addresstype_address_fk FOREIGN KEY (addresstypeid) REFERENCES addresstype(addresstypeid);


--
-- TOC entry 3450 (class 2606 OID 33238)
-- Dependencies: 3314 173 178
-- Name: contact_address_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY address
    ADD CONSTRAINT contact_address_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3458 (class 2606 OID 33243)
-- Dependencies: 182 178 3314
-- Name: contact_contactcostcode_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contactcostcode
    ADD CONSTRAINT contact_contactcostcode_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3459 (class 2606 OID 33248)
-- Dependencies: 183 3314 178
-- Name: contact_contactgroup_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contactgroup
    ADD CONSTRAINT contact_contactgroup_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3455 (class 2606 OID 33253)
-- Dependencies: 178 3314 180
-- Name: contact_contactunit_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contactcontactgroup
    ADD CONSTRAINT contact_contactunit_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3478 (class 2606 OID 33258)
-- Dependencies: 178 202 3314
-- Name: contact_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablecontact
    ADD CONSTRAINT contact_deliverablecontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3481 (class 2606 OID 33263)
-- Dependencies: 3314 178 205
-- Name: contact_electadd_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY eaddress
    ADD CONSTRAINT contact_electadd_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3508 (class 2606 OID 33268)
-- Dependencies: 178 236 3314
-- Name: contact_modcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modcontact
    ADD CONSTRAINT contact_modcontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3472 (class 2606 OID 33273)
-- Dependencies: 178 3314 198
-- Name: contact_person_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY person
    ADD CONSTRAINT contact_person_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3516 (class 2606 OID 33278)
-- Dependencies: 246 178 3314
-- Name: contact_phone_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY phone
    ADD CONSTRAINT contact_phone_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3522 (class 2606 OID 33283)
-- Dependencies: 3314 263 178
-- Name: contact_projectcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectcontact
    ADD CONSTRAINT contact_projectcontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3535 (class 2606 OID 33288)
-- Dependencies: 3314 178 277
-- Name: contact_remindercontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY remindercontact
    ADD CONSTRAINT contact_remindercontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 3456 (class 2606 OID 33298)
-- Dependencies: 3322 180 183
-- Name: contactgroup_contactunit_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contactcontactgroup
    ADD CONSTRAINT contactgroup_contactunit_fk FOREIGN KEY (groupid) REFERENCES contactgroup(contactid);


--
-- TOC entry 3488 (class 2606 OID 33303)
-- Dependencies: 3322 216 183
-- Name: contactgroup_fileversion_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT contactgroup_fileversion_fk FOREIGN KEY (contactid) REFERENCES contactgroup(contactid);


--
-- TOC entry 3504 (class 2606 OID 33308)
-- Dependencies: 232 183 3322
-- Name: contactgroup_login_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY login
    ADD CONSTRAINT contactgroup_login_fk FOREIGN KEY (groupid) REFERENCES contactgroup(contactid);


--
-- TOC entry 3474 (class 2606 OID 33313)
-- Dependencies: 183 3322 199
-- Name: contactgroup_project_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY project
    ADD CONSTRAINT contactgroup_project_fk FOREIGN KEY (orgid) REFERENCES contactgroup(contactid);


--
-- TOC entry 3454 (class 2606 OID 33318)
-- Dependencies: 3324 178 184
-- Name: contacttype_contact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contacttype_contact_fk FOREIGN KEY (contacttypeid) REFERENCES contacttype(contacttypeid);


--
-- TOC entry 3461 (class 2606 OID 33323)
-- Dependencies: 188 186 3326
-- Name: costcode_costcodeinvoice_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY costcodeinvoice
    ADD CONSTRAINT costcode_costcodeinvoice_fk FOREIGN KEY (costcodeid) REFERENCES costcode(costcodeid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3517 (class 2606 OID 33328)
-- Dependencies: 246 171 3299
-- Name: country_phone_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY phone
    ADD CONSTRAINT country_phone_fk FOREIGN KEY (countryiso) REFERENCES country(countryiso);


--
-- TOC entry 3448 (class 2606 OID 33333)
-- Dependencies: 171 3299 172
-- Name: country_postalcode_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY postalcode
    ADD CONSTRAINT country_postalcode_fk FOREIGN KEY (countryiso) REFERENCES country(countryiso);


--
-- TOC entry 3476 (class 2606 OID 33338)
-- Dependencies: 3333 201 192
-- Name: deliverable_deliverablecomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablecomment
    ADD CONSTRAINT deliverable_deliverablecomment_fk FOREIGN KEY (deliverableid) REFERENCES deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 3479 (class 2606 OID 33343)
-- Dependencies: 202 3333 192
-- Name: deliverable_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablecontact
    ADD CONSTRAINT deliverable_deliverablecontact_fk FOREIGN KEY (deliverableid) REFERENCES deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 3464 (class 2606 OID 33348)
-- Dependencies: 192 3333 194
-- Name: deliverable_deliverablemod_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablemod
    ADD CONSTRAINT deliverable_deliverablemod_fk FOREIGN KEY (deliverableid) REFERENCES deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 3489 (class 2606 OID 33353)
-- Dependencies: 3333 216 192
-- Name: deliverable_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT deliverable_file_fk FOREIGN KEY (deliverableid) REFERENCES deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 3519 (class 2606 OID 33358)
-- Dependencies: 3333 192 259
-- Name: deliverable_progress_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY progress
    ADD CONSTRAINT deliverable_progress_fk FOREIGN KEY (deliverableid) REFERENCES deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 3534 (class 2606 OID 33363)
-- Dependencies: 192 275 3333
-- Name: deliverable_reminder_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY reminder
    ADD CONSTRAINT deliverable_reminder_fk FOREIGN KEY (deliverableid) REFERENCES deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 3465 (class 2606 OID 33368)
-- Dependencies: 194 194 194 194 3335
-- Name: deliverablemod_deliverablemod_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablemod
    ADD CONSTRAINT deliverablemod_deliverablemod_fk FOREIGN KEY (parentmodificationid, parentdeliverableid) REFERENCES deliverablemod(modificationid, deliverableid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3463 (class 2606 OID 33373)
-- Dependencies: 196 192 3337
-- Name: deliverabletype_deliverable_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverable
    ADD CONSTRAINT deliverabletype_deliverable_fk FOREIGN KEY (deliverabletypeid) REFERENCES deliverabletype(deliverabletypeid);


--
-- TOC entry 3482 (class 2606 OID 33378)
-- Dependencies: 3358 205 206
-- Name: electaddtype_electadd_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY eaddress
    ADD CONSTRAINT electaddtype_electadd_fk FOREIGN KEY (eaddresstypeid) REFERENCES eaddresstype(eaddresstypeid);


--
-- TOC entry 3484 (class 2606 OID 33383)
-- Dependencies: 3360 211 209
-- Name: fact_factfile_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY factfile
    ADD CONSTRAINT fact_factfile_fk FOREIGN KEY (factid) REFERENCES fact(factid) ON DELETE CASCADE;


--
-- TOC entry 3537 (class 2606 OID 33388)
-- Dependencies: 3360 285 209
-- Name: fact_timeline_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY timeline
    ADD CONSTRAINT fact_timeline_fk FOREIGN KEY (factid) REFERENCES fact(factid) ON DELETE CASCADE;


--
-- TOC entry 3485 (class 2606 OID 33393)
-- Dependencies: 3364 212 211
-- Name: file_factfile_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY factfile
    ADD CONSTRAINT file_factfile_fk FOREIGN KEY (fileid) REFERENCES file(fileid) ON DELETE CASCADE;


--
-- TOC entry 3486 (class 2606 OID 33398)
-- Dependencies: 212 213 3364
-- Name: file_filecomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY filecomment
    ADD CONSTRAINT file_filecomment_fk FOREIGN KEY (fileid) REFERENCES file(fileid) ON DELETE CASCADE;


--
-- TOC entry 3490 (class 2606 OID 33403)
-- Dependencies: 3368 214 216
-- Name: filetype_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT filetype_file_fk FOREIGN KEY (filetypeid) REFERENCES filetype(filetypeid);


--
-- TOC entry 3491 (class 2606 OID 33408)
-- Dependencies: 212 3364 216
-- Name: fileversion_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT fileversion_file_fk FOREIGN KEY (fileid) REFERENCES file(fileid);


--
-- TOC entry 3492 (class 2606 OID 33413)
-- Dependencies: 218 216 3377
-- Name: format_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT format_file_fk FOREIGN KEY (formatid) REFERENCES format(formatid);


--
-- TOC entry 3460 (class 2606 OID 33418)
-- Dependencies: 186 3379 220
-- Name: funding_chargecode_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY costcode
    ADD CONSTRAINT funding_chargecode_fk FOREIGN KEY (fundingid) REFERENCES funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 3500 (class 2606 OID 33423)
-- Dependencies: 3379 226 220
-- Name: funding_invoice_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT funding_invoice_fk FOREIGN KEY (fundingid) REFERENCES funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 3497 (class 2606 OID 33428)
-- Dependencies: 220 222 3381
-- Name: fundingtype_funding_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT fundingtype_funding_fk FOREIGN KEY (fundingtypeid) REFERENCES fundingtype(fundingtypeid);


--
-- TOC entry 3527 (class 2606 OID 33433)
-- Dependencies: 269 230 3387
-- Name: geometry_projectline_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectline
    ADD CONSTRAINT geometry_projectline_fk FOREIGN KEY (fid) REFERENCES line(fid);


--
-- TOC entry 3529 (class 2606 OID 33438)
-- Dependencies: 271 3412 251
-- Name: geometry_projectpoint_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectpoint
    ADD CONSTRAINT geometry_projectpoint_fk FOREIGN KEY (fid) REFERENCES point(fid);


--
-- TOC entry 3531 (class 2606 OID 33443)
-- Dependencies: 272 3414 253
-- Name: geometry_projectpolygon_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectpolygon
    ADD CONSTRAINT geometry_projectpolygon_fk FOREIGN KEY (fid) REFERENCES polygon(fid);


--
-- TOC entry 3451 (class 2606 OID 33448)
-- Dependencies: 173 190 3330
-- Name: govunit_address_county_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY address
    ADD CONSTRAINT govunit_address_county_fk FOREIGN KEY (countyid) REFERENCES govunit(featureid);


--
-- TOC entry 3452 (class 2606 OID 33453)
-- Dependencies: 3330 190 173
-- Name: govunit_address_state_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY address
    ADD CONSTRAINT govunit_address_state_fk FOREIGN KEY (stateid) REFERENCES govunit(featureid);


--
-- TOC entry 3462 (class 2606 OID 33458)
-- Dependencies: 3383 226 188
-- Name: invoice_costcodeinvoice_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY costcodeinvoice
    ADD CONSTRAINT invoice_costcodeinvoice_fk FOREIGN KEY (invoiceid) REFERENCES invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 3493 (class 2606 OID 33463)
-- Dependencies: 3383 226 216
-- Name: invoice_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT invoice_file_fk FOREIGN KEY (invoiceid) REFERENCES invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 3502 (class 2606 OID 33468)
-- Dependencies: 228 226 3383
-- Name: invoice_invoicecomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY invoicecomment
    ADD CONSTRAINT invoice_invoicecomment_fk FOREIGN KEY (invoiceid) REFERENCES invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 3509 (class 2606 OID 33473)
-- Dependencies: 3396 237 236
-- Name: modcontacttype_modcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modcontact
    ADD CONSTRAINT modcontacttype_modcontact_fk FOREIGN KEY (modcontacttypeid) REFERENCES modcontacttype(modcontacttypeid);


--
-- TOC entry 3466 (class 2606 OID 33478)
-- Dependencies: 194 197 3339
-- Name: modification_deliverablemod_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablemod
    ADD CONSTRAINT modification_deliverablemod_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3494 (class 2606 OID 33483)
-- Dependencies: 3339 216 197
-- Name: modification_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT modification_file_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3498 (class 2606 OID 33488)
-- Dependencies: 197 220 3339
-- Name: modification_funding_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT modification_funding_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3506 (class 2606 OID 33493)
-- Dependencies: 3339 197 235
-- Name: modification_modcomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modcomment
    ADD CONSTRAINT modification_modcomment_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3510 (class 2606 OID 33498)
-- Dependencies: 236 3339 197
-- Name: modification_modcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modcontact
    ADD CONSTRAINT modification_modcontact_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3468 (class 2606 OID 33503)
-- Dependencies: 197 3339 197
-- Name: modification_modification_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modification
    ADD CONSTRAINT modification_modification_fk FOREIGN KEY (parentmodificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3511 (class 2606 OID 33508)
-- Dependencies: 197 242 3339
-- Name: modification_modstatus_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modstatus
    ADD CONSTRAINT modification_modstatus_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3533 (class 2606 OID 33513)
-- Dependencies: 273 197 3339
-- Name: modification_purchaserequest_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY purchaserequest
    ADD CONSTRAINT modification_purchaserequest_fk FOREIGN KEY (modificationid) REFERENCES modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 3469 (class 2606 OID 33518)
-- Dependencies: 240 197 3398
-- Name: modtype_modification_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modification
    ADD CONSTRAINT modtype_modification_fk FOREIGN KEY (modtypeid) REFERENCES modtype(modtypeid);


--
-- TOC entry 3513 (class 2606 OID 33523)
-- Dependencies: 3398 240 245
-- Name: modtype_modtypestatus_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modtypestatus
    ADD CONSTRAINT modtype_modtypestatus_fk FOREIGN KEY (modtypeid) REFERENCES modtype(modtypeid);


--
-- TOC entry 3453 (class 2606 OID 33528)
-- Dependencies: 176 3341 198
-- Name: person_audit_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY audit
    ADD CONSTRAINT person_audit_fk FOREIGN KEY (contactid) REFERENCES person(contactid);


--
-- TOC entry 3477 (class 2606 OID 33533)
-- Dependencies: 3341 198 201
-- Name: person_deliverablecomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablecomment
    ADD CONSTRAINT person_deliverablecomment_fk FOREIGN KEY (contactid) REFERENCES person(contactid) ON DELETE CASCADE;


--
-- TOC entry 3467 (class 2606 OID 33538)
-- Dependencies: 3341 198 194
-- Name: person_deliverablemod_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablemod
    ADD CONSTRAINT person_deliverablemod_fk FOREIGN KEY (personid) REFERENCES person(contactid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3487 (class 2606 OID 33543)
-- Dependencies: 3341 213 198
-- Name: person_filecomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY filecomment
    ADD CONSTRAINT person_filecomment_fk FOREIGN KEY (contactid) REFERENCES person(contactid) ON DELETE CASCADE;


--
-- TOC entry 3503 (class 2606 OID 33548)
-- Dependencies: 3341 228 198
-- Name: person_invoicecomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY invoicecomment
    ADD CONSTRAINT person_invoicecomment_fk FOREIGN KEY (contactid) REFERENCES person(contactid) ON DELETE CASCADE;


--
-- TOC entry 3505 (class 2606 OID 33553)
-- Dependencies: 198 3341 232
-- Name: person_login_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY login
    ADD CONSTRAINT person_login_fk FOREIGN KEY (contactid) REFERENCES person(contactid);


--
-- TOC entry 3507 (class 2606 OID 33558)
-- Dependencies: 3341 198 235
-- Name: person_modcomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modcomment
    ADD CONSTRAINT person_modcomment_fk FOREIGN KEY (contactid) REFERENCES person(contactid) ON DELETE CASCADE;


--
-- TOC entry 3470 (class 2606 OID 33563)
-- Dependencies: 198 3341 197
-- Name: person_modification_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modification
    ADD CONSTRAINT person_modification_fk FOREIGN KEY (personid) REFERENCES person(contactid);


--
-- TOC entry 3520 (class 2606 OID 33568)
-- Dependencies: 3341 198 262
-- Name: person_projectcomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectcomment
    ADD CONSTRAINT person_projectcomment_fk FOREIGN KEY (contactid) REFERENCES person(contactid) ON DELETE CASCADE;


--
-- TOC entry 3518 (class 2606 OID 33573)
-- Dependencies: 246 249 3410
-- Name: phonetype_phone_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY phone
    ADD CONSTRAINT phonetype_phone_fk FOREIGN KEY (phonetypeid) REFERENCES phonetype(phonetypeid);


--
-- TOC entry 3457 (class 2606 OID 33578)
-- Dependencies: 180 255 3416
-- Name: postion_groupcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY contactcontactgroup
    ADD CONSTRAINT postion_groupcontact_fk FOREIGN KEY (positionid) REFERENCES "position"(positionid);


--
-- TOC entry 3473 (class 2606 OID 33583)
-- Dependencies: 198 255 3416
-- Name: postion_person_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY person
    ADD CONSTRAINT postion_person_fk FOREIGN KEY (positionid) REFERENCES "position"(positionid);


--
-- TOC entry 3495 (class 2606 OID 33588)
-- Dependencies: 3418 216 259
-- Name: progress_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT progress_file_fk FOREIGN KEY (progressid) REFERENCES progress(progressid) ON DELETE CASCADE;


--
-- TOC entry 3483 (class 2606 OID 33593)
-- Dependencies: 199 209 3347
-- Name: project_fact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fact
    ADD CONSTRAINT project_fact_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3496 (class 2606 OID 33598)
-- Dependencies: 3347 216 199
-- Name: project_file_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY fileversion
    ADD CONSTRAINT project_file_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3471 (class 2606 OID 33603)
-- Dependencies: 197 3347 199
-- Name: project_modification_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modification
    ADD CONSTRAINT project_modification_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3475 (class 2606 OID 33608)
-- Dependencies: 199 3347 199
-- Name: project_project_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_project_fk FOREIGN KEY (parentprojectid) REFERENCES project(projectid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3521 (class 2606 OID 33613)
-- Dependencies: 262 199 3347
-- Name: project_projectcomment_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectcomment
    ADD CONSTRAINT project_projectcomment_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3523 (class 2606 OID 33618)
-- Dependencies: 199 3347 263
-- Name: project_projectcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectcontact
    ADD CONSTRAINT project_projectcontact_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3525 (class 2606 OID 33623)
-- Dependencies: 3347 267 199
-- Name: project_projectgnis_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectgnis
    ADD CONSTRAINT project_projectgnis_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3526 (class 2606 OID 33628)
-- Dependencies: 268 199 3347
-- Name: project_projectitis_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectitis
    ADD CONSTRAINT project_projectitis_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3528 (class 2606 OID 33633)
-- Dependencies: 3347 269 199
-- Name: project_projectline_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectline
    ADD CONSTRAINT project_projectline_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3530 (class 2606 OID 33638)
-- Dependencies: 199 271 3347
-- Name: project_projectpoint_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectpoint
    ADD CONSTRAINT project_projectpoint_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3532 (class 2606 OID 33643)
-- Dependencies: 199 3347 272
-- Name: project_projectpolygon_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectpolygon
    ADD CONSTRAINT project_projectpolygon_fk FOREIGN KEY (projectid) REFERENCES project(projectid) ON DELETE CASCADE;


--
-- TOC entry 3499 (class 2606 OID 33648)
-- Dependencies: 263 220 3422
-- Name: projectcontact_funding_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid) REFERENCES projectcontact(projectcontactid) ON DELETE CASCADE;


--
-- TOC entry 3501 (class 2606 OID 33653)
-- Dependencies: 3422 263 226
-- Name: projectcontact_invoice_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT projectcontact_invoice_fk FOREIGN KEY (projectcontactid) REFERENCES projectcontact(projectcontactid) ON DELETE CASCADE;


--
-- TOC entry 3536 (class 2606 OID 33658)
-- Dependencies: 3438 277 275
-- Name: reminder_remindercontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY remindercontact
    ADD CONSTRAINT reminder_remindercontact_fk FOREIGN KEY (reminderid) REFERENCES reminder(reminderid) ON DELETE CASCADE;


--
-- TOC entry 3480 (class 2606 OID 33663)
-- Dependencies: 278 3442 202
-- Name: roletype_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY deliverablecontact
    ADD CONSTRAINT roletype_deliverablecontact_fk FOREIGN KEY (roletypeid) REFERENCES roletype(roletypeid);


--
-- TOC entry 3524 (class 2606 OID 33668)
-- Dependencies: 263 3442 278
-- Name: roletype_projectcontact_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY projectcontact
    ADD CONSTRAINT roletype_projectcontact_fk FOREIGN KEY (roletypeid) REFERENCES roletype(roletypeid);


--
-- TOC entry 3512 (class 2606 OID 33673)
-- Dependencies: 242 3444 281
-- Name: status_modstatus_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modstatus
    ADD CONSTRAINT status_modstatus_fk FOREIGN KEY (statusid) REFERENCES status(statusid);


--
-- TOC entry 3514 (class 2606 OID 33678)
-- Dependencies: 3444 245 281
-- Name: status_modtypestatus_fk; Type: FK CONSTRAINT; Schema: pts; Owner: bradley
--

ALTER TABLE ONLY modtypestatus
    ADD CONSTRAINT status_modtypestatus_fk FOREIGN KEY (statusid) REFERENCES status(statusid);


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 10
-- Name: pts; Type: ACL; Schema: -; Owner: bradley
--

REVOKE ALL ON SCHEMA pts FROM PUBLIC;
REVOKE ALL ON SCHEMA pts FROM bradley;
GRANT ALL ON SCHEMA pts TO bradley;
GRANT USAGE ON SCHEMA pts TO pts_read;
GRANT USAGE ON SCHEMA pts TO pts_write;


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 1093
-- Name: form_projectcode(integer, date, character varying); Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON FUNCTION form_projectcode(pnum integer, initdate date, org character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION form_projectcode(pnum integer, initdate date, org character varying) FROM bradley;
GRANT ALL ON FUNCTION form_projectcode(pnum integer, initdate date, org character varying) TO bradley;
GRANT ALL ON FUNCTION form_projectcode(pnum integer, initdate date, org character varying) TO PUBLIC;
GRANT ALL ON FUNCTION form_projectcode(pnum integer, initdate date, org character varying) TO pts_read;


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 1094
-- Name: form_projectcode(integer, integer, character varying); Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) FROM bradley;
GRANT ALL ON FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) TO bradley;
GRANT ALL ON FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) TO PUBLIC;
GRANT ALL ON FUNCTION form_projectcode(pnum integer, initdate integer, org character varying) TO pts_read;


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 173
-- Name: address; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE address FROM PUBLIC;
REVOKE ALL ON TABLE address FROM bradley;
GRANT ALL ON TABLE address TO bradley;
GRANT SELECT ON TABLE address TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE address TO pts_write;


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 174
-- Name: address_addressid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE address_addressid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE address_addressid_seq FROM bradley;
GRANT ALL ON SEQUENCE address_addressid_seq TO bradley;
GRANT SELECT ON SEQUENCE address_addressid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE address_addressid_seq TO pts_write;


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 175
-- Name: addresstype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE addresstype FROM PUBLIC;
REVOKE ALL ON TABLE addresstype FROM bradley;
GRANT ALL ON TABLE addresstype TO bradley;
GRANT SELECT ON TABLE addresstype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE addresstype TO pts_write;


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 176
-- Name: audit; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE audit FROM PUBLIC;
REVOKE ALL ON TABLE audit FROM bradley;
GRANT ALL ON TABLE audit TO bradley;
GRANT SELECT ON TABLE audit TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE audit TO pts_write;


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 177
-- Name: audit_auditid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE audit_auditid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE audit_auditid_seq FROM bradley;
GRANT ALL ON SEQUENCE audit_auditid_seq TO bradley;
GRANT SELECT ON SEQUENCE audit_auditid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE audit_auditid_seq TO pts_write;


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 178
-- Name: contact; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE contact FROM PUBLIC;
REVOKE ALL ON TABLE contact FROM bradley;
GRANT ALL ON TABLE contact TO bradley;
GRANT SELECT ON TABLE contact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE contact TO pts_write;


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 179
-- Name: contact_contactid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE contact_contactid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE contact_contactid_seq FROM bradley;
GRANT ALL ON SEQUENCE contact_contactid_seq TO bradley;
GRANT SELECT ON SEQUENCE contact_contactid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE contact_contactid_seq TO pts_write;


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 180
-- Name: contactcontactgroup; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE contactcontactgroup FROM PUBLIC;
REVOKE ALL ON TABLE contactcontactgroup FROM bradley;
GRANT ALL ON TABLE contactcontactgroup TO bradley;
GRANT SELECT ON TABLE contactcontactgroup TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE contactcontactgroup TO pts_write;


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 181
-- Name: contactcontactgroup_contactcontactgroupid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE contactcontactgroup_contactcontactgroupid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE contactcontactgroup_contactcontactgroupid_seq FROM bradley;
GRANT ALL ON SEQUENCE contactcontactgroup_contactcontactgroupid_seq TO bradley;
GRANT SELECT,UPDATE ON SEQUENCE contactcontactgroup_contactcontactgroupid_seq TO pts_write;


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 182
-- Name: contactcostcode; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE contactcostcode FROM PUBLIC;
REVOKE ALL ON TABLE contactcostcode FROM bradley;
GRANT ALL ON TABLE contactcostcode TO bradley;
GRANT SELECT ON TABLE contactcostcode TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE contactcostcode TO pts_write;


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 183
-- Name: contactgroup; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE contactgroup FROM PUBLIC;
REVOKE ALL ON TABLE contactgroup FROM bradley;
GRANT ALL ON TABLE contactgroup TO bradley;
GRANT SELECT ON TABLE contactgroup TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE contactgroup TO pts_write;


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 184
-- Name: contacttype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE contacttype FROM PUBLIC;
REVOKE ALL ON TABLE contacttype FROM bradley;
GRANT ALL ON TABLE contacttype TO bradley;
GRANT SELECT ON TABLE contacttype TO pts_read;


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 185
-- Name: contacttype_contacttypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE contacttype_contacttypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE contacttype_contacttypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE contacttype_contacttypeid_seq TO bradley;


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 186
-- Name: costcode; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE costcode FROM PUBLIC;
REVOKE ALL ON TABLE costcode FROM bradley;
GRANT ALL ON TABLE costcode TO bradley;
GRANT SELECT ON TABLE costcode TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE costcode TO pts_write;


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 187
-- Name: costcode_costcodeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE costcode_costcodeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE costcode_costcodeid_seq FROM bradley;
GRANT ALL ON SEQUENCE costcode_costcodeid_seq TO bradley;
GRANT SELECT,UPDATE ON SEQUENCE costcode_costcodeid_seq TO pts_write;


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 188
-- Name: costcodeinvoice; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE costcodeinvoice FROM PUBLIC;
REVOKE ALL ON TABLE costcodeinvoice FROM bradley;
GRANT ALL ON TABLE costcodeinvoice TO bradley;
GRANT SELECT ON TABLE costcodeinvoice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE costcodeinvoice TO pts_write;


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 189
-- Name: costcodeinvoice_costcodeinvoiceid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE costcodeinvoice_costcodeinvoiceid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE costcodeinvoice_costcodeinvoiceid_seq FROM bradley;
GRANT ALL ON SEQUENCE costcodeinvoice_costcodeinvoiceid_seq TO bradley;
GRANT SELECT,UPDATE ON SEQUENCE costcodeinvoice_costcodeinvoiceid_seq TO pts_read;


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 171
-- Name: country; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE country FROM PUBLIC;
REVOKE ALL ON TABLE country FROM bradley;
GRANT ALL ON TABLE country TO bradley;
GRANT SELECT ON TABLE country TO pts_read;


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 191
-- Name: countylist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE countylist FROM PUBLIC;
REVOKE ALL ON TABLE countylist FROM bradley;
GRANT ALL ON TABLE countylist TO bradley;
GRANT SELECT ON TABLE countylist TO pts_read;


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 192
-- Name: deliverable; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverable FROM PUBLIC;
REVOKE ALL ON TABLE deliverable FROM bradley;
GRANT ALL ON TABLE deliverable TO bradley;
GRANT SELECT ON TABLE deliverable TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE deliverable TO pts_write;


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 193
-- Name: deliverable_deliverableid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE deliverable_deliverableid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE deliverable_deliverableid_seq FROM bradley;
GRANT ALL ON SEQUENCE deliverable_deliverableid_seq TO bradley;
GRANT SELECT ON SEQUENCE deliverable_deliverableid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE deliverable_deliverableid_seq TO pts_write;


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 194
-- Name: deliverablemod; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverablemod FROM PUBLIC;
REVOKE ALL ON TABLE deliverablemod FROM bradley;
GRANT ALL ON TABLE deliverablemod TO bradley;
GRANT SELECT ON TABLE deliverablemod TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE deliverablemod TO pts_write;


--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 195
-- Name: deliverableall; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverableall FROM PUBLIC;
REVOKE ALL ON TABLE deliverableall FROM bradley;
GRANT ALL ON TABLE deliverableall TO bradley;
GRANT SELECT ON TABLE deliverableall TO pts_read;


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 196
-- Name: deliverabletype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverabletype FROM PUBLIC;
REVOKE ALL ON TABLE deliverabletype FROM bradley;
GRANT ALL ON TABLE deliverabletype TO bradley;
GRANT SELECT ON TABLE deliverabletype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE deliverabletype TO pts_write;


--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 197
-- Name: modification; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modification FROM PUBLIC;
REVOKE ALL ON TABLE modification FROM bradley;
GRANT ALL ON TABLE modification TO bradley;
GRANT SELECT ON TABLE modification TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE modification TO pts_write;


--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 198
-- Name: person; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE person FROM PUBLIC;
REVOKE ALL ON TABLE person FROM bradley;
GRANT ALL ON TABLE person TO bradley;
GRANT SELECT ON TABLE person TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE person TO pts_write;


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 199
-- Name: project; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE project FROM PUBLIC;
REVOKE ALL ON TABLE project FROM bradley;
GRANT ALL ON TABLE project TO bradley;
GRANT SELECT ON TABLE project TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE project TO pts_write;


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 200
-- Name: deliverablecalendar; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverablecalendar FROM PUBLIC;
REVOKE ALL ON TABLE deliverablecalendar FROM bradley;
GRANT ALL ON TABLE deliverablecalendar TO bradley;
GRANT SELECT ON TABLE deliverablecalendar TO pts_read;


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 201
-- Name: deliverablecomment; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverablecomment FROM PUBLIC;
REVOKE ALL ON TABLE deliverablecomment FROM bradley;
GRANT ALL ON TABLE deliverablecomment TO bradley;
GRANT SELECT ON TABLE deliverablecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE deliverablecomment TO pts_write;


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 202
-- Name: deliverablecontact; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverablecontact FROM PUBLIC;
REVOKE ALL ON TABLE deliverablecontact FROM bradley;
GRANT ALL ON TABLE deliverablecontact TO bradley;
GRANT SELECT ON TABLE deliverablecontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE deliverablecontact TO pts_write;


--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 203
-- Name: deliverablelist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE deliverablelist FROM PUBLIC;
REVOKE ALL ON TABLE deliverablelist FROM bradley;
GRANT ALL ON TABLE deliverablelist TO bradley;
GRANT SELECT ON TABLE deliverablelist TO pts_read;


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 204
-- Name: deliverabletype_deliverabletypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE deliverabletype_deliverabletypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE deliverabletype_deliverabletypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE deliverabletype_deliverabletypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE deliverabletype_deliverabletypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE deliverabletype_deliverabletypeid_seq TO pts_write;


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 205
-- Name: eaddress; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE eaddress FROM PUBLIC;
REVOKE ALL ON TABLE eaddress FROM bradley;
GRANT ALL ON TABLE eaddress TO bradley;
GRANT SELECT ON TABLE eaddress TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE eaddress TO pts_write;


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 206
-- Name: eaddresstype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE eaddresstype FROM PUBLIC;
REVOKE ALL ON TABLE eaddresstype FROM bradley;
GRANT ALL ON TABLE eaddresstype TO bradley;
GRANT SELECT ON TABLE eaddresstype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE eaddresstype TO pts_write;


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 207
-- Name: electadd_electaddid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE electadd_electaddid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE electadd_electaddid_seq FROM bradley;
GRANT ALL ON SEQUENCE electadd_electaddid_seq TO bradley;
GRANT SELECT ON SEQUENCE electadd_electaddid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE electadd_electaddid_seq TO pts_write;


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 208
-- Name: electaddtype_electaddtypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE electaddtype_electaddtypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE electaddtype_electaddtypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE electaddtype_electaddtypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE electaddtype_electaddtypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE electaddtype_electaddtypeid_seq TO pts_write;


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 209
-- Name: fact; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE fact FROM PUBLIC;
REVOKE ALL ON TABLE fact FROM bradley;
GRANT ALL ON TABLE fact TO bradley;
GRANT SELECT ON TABLE fact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE fact TO pts_write;


--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 210
-- Name: fact_factid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE fact_factid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE fact_factid_seq FROM bradley;
GRANT ALL ON SEQUENCE fact_factid_seq TO bradley;
GRANT SELECT ON SEQUENCE fact_factid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE fact_factid_seq TO pts_write;


--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 211
-- Name: factfile; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE factfile FROM PUBLIC;
REVOKE ALL ON TABLE factfile FROM bradley;
GRANT ALL ON TABLE factfile TO bradley;
GRANT SELECT ON TABLE factfile TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE factfile TO pts_write;


--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 212
-- Name: file; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE file FROM PUBLIC;
REVOKE ALL ON TABLE file FROM bradley;
GRANT ALL ON TABLE file TO bradley;
GRANT SELECT ON TABLE file TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE file TO pts_write;


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 213
-- Name: filecomment; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE filecomment FROM PUBLIC;
REVOKE ALL ON TABLE filecomment FROM bradley;
GRANT ALL ON TABLE filecomment TO bradley;
GRANT SELECT ON TABLE filecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE filecomment TO pts_write;


--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 214
-- Name: filetype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE filetype FROM PUBLIC;
REVOKE ALL ON TABLE filetype FROM bradley;
GRANT ALL ON TABLE filetype TO bradley;
GRANT SELECT ON TABLE filetype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE filetype TO pts_write;


--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 215
-- Name: filetype_filetypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE filetype_filetypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE filetype_filetypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE filetype_filetypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE filetype_filetypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE filetype_filetypeid_seq TO pts_write;


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 216
-- Name: fileversion; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE fileversion FROM PUBLIC;
REVOKE ALL ON TABLE fileversion FROM bradley;
GRANT ALL ON TABLE fileversion TO bradley;
GRANT SELECT ON TABLE fileversion TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE fileversion TO pts_write;


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 218
-- Name: format; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE format FROM PUBLIC;
REVOKE ALL ON TABLE format FROM bradley;
GRANT ALL ON TABLE format TO bradley;
GRANT SELECT ON TABLE format TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE format TO pts_write;


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 219
-- Name: format_formatid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE format_formatid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE format_formatid_seq FROM bradley;
GRANT ALL ON SEQUENCE format_formatid_seq TO bradley;
GRANT SELECT ON SEQUENCE format_formatid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE format_formatid_seq TO pts_write;


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 220
-- Name: funding; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE funding FROM PUBLIC;
REVOKE ALL ON TABLE funding FROM bradley;
GRANT ALL ON TABLE funding TO bradley;
GRANT SELECT ON TABLE funding TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE funding TO pts_write;


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 221
-- Name: funding_fundingid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE funding_fundingid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE funding_fundingid_seq FROM bradley;
GRANT ALL ON SEQUENCE funding_fundingid_seq TO bradley;
GRANT SELECT ON SEQUENCE funding_fundingid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE funding_fundingid_seq TO pts_write;


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 222
-- Name: fundingtype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE fundingtype FROM PUBLIC;
REVOKE ALL ON TABLE fundingtype FROM bradley;
GRANT ALL ON TABLE fundingtype TO bradley;
GRANT SELECT ON TABLE fundingtype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE fundingtype TO pts_write;


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 223
-- Name: fundingtype_fundingtypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE fundingtype_fundingtypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE fundingtype_fundingtypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE fundingtype_fundingtypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE fundingtype_fundingtypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE fundingtype_fundingtypeid_seq TO pts_write;


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 224
-- Name: groupmemberlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE groupmemberlist FROM PUBLIC;
REVOKE ALL ON TABLE groupmemberlist FROM bradley;
GRANT ALL ON TABLE groupmemberlist TO bradley;
GRANT SELECT ON TABLE groupmemberlist TO pts_read;


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 225
-- Name: grouppersonlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE grouppersonlist FROM PUBLIC;
REVOKE ALL ON TABLE grouppersonlist FROM bradley;
GRANT ALL ON TABLE grouppersonlist TO bradley;
GRANT SELECT ON TABLE grouppersonlist TO pts_read;


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 226
-- Name: invoice; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE invoice FROM PUBLIC;
REVOKE ALL ON TABLE invoice FROM bradley;
GRANT ALL ON TABLE invoice TO bradley;
GRANT SELECT ON TABLE invoice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE invoice TO pts_write;


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 227
-- Name: invoice_invoiceid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE invoice_invoiceid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE invoice_invoiceid_seq FROM bradley;
GRANT ALL ON SEQUENCE invoice_invoiceid_seq TO bradley;
GRANT SELECT ON SEQUENCE invoice_invoiceid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE invoice_invoiceid_seq TO pts_write;


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 228
-- Name: invoicecomment; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE invoicecomment FROM PUBLIC;
REVOKE ALL ON TABLE invoicecomment FROM bradley;
GRANT ALL ON TABLE invoicecomment TO bradley;
GRANT SELECT ON TABLE invoicecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE invoicecomment TO pts_write;


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 229
-- Name: invoicelist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE invoicelist FROM PUBLIC;
REVOKE ALL ON TABLE invoicelist FROM bradley;
GRANT ALL ON TABLE invoicelist TO bradley;
GRANT SELECT ON TABLE invoicelist TO pts_read;


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 230
-- Name: line; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE line FROM PUBLIC;
REVOKE ALL ON TABLE line FROM bradley;
GRANT ALL ON TABLE line TO bradley;
GRANT SELECT ON TABLE line TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE line TO pts_write;


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 231
-- Name: line_fid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE line_fid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE line_fid_seq FROM bradley;
GRANT ALL ON SEQUENCE line_fid_seq TO bradley;
GRANT SELECT ON SEQUENCE line_fid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE line_fid_seq TO pts_write;


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 232
-- Name: login; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE login FROM PUBLIC;
REVOKE ALL ON TABLE login FROM bradley;
GRANT ALL ON TABLE login TO bradley;
GRANT SELECT ON TABLE login TO pts_read;


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 234
-- Name: membergrouplist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE membergrouplist FROM PUBLIC;
REVOKE ALL ON TABLE membergrouplist FROM bradley;
GRANT ALL ON TABLE membergrouplist TO bradley;
GRANT SELECT ON TABLE membergrouplist TO pts_read;


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 235
-- Name: modcomment; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modcomment FROM PUBLIC;
REVOKE ALL ON TABLE modcomment FROM bradley;
GRANT ALL ON TABLE modcomment TO bradley;
GRANT SELECT ON TABLE modcomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE modcomment TO pts_write;


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 236
-- Name: modcontact; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modcontact FROM PUBLIC;
REVOKE ALL ON TABLE modcontact FROM bradley;
GRANT ALL ON TABLE modcontact TO bradley;
GRANT SELECT ON TABLE modcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE modcontact TO pts_write;


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 237
-- Name: modcontacttype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modcontacttype FROM PUBLIC;
REVOKE ALL ON TABLE modcontacttype FROM bradley;
GRANT ALL ON TABLE modcontacttype TO bradley;
GRANT SELECT ON TABLE modcontacttype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE modcontacttype TO pts_write;


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 238
-- Name: modcontacttype_modcontacttypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE modcontacttype_modcontacttypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE modcontacttype_modcontacttypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE modcontacttype_modcontacttypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE modcontacttype_modcontacttypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE modcontacttype_modcontacttypeid_seq TO pts_write;


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 239
-- Name: modification_modificationid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE modification_modificationid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE modification_modificationid_seq FROM bradley;
GRANT ALL ON SEQUENCE modification_modificationid_seq TO bradley;
GRANT SELECT ON SEQUENCE modification_modificationid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE modification_modificationid_seq TO pts_write;


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 240
-- Name: modtype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modtype FROM PUBLIC;
REVOKE ALL ON TABLE modtype FROM bradley;
GRANT ALL ON TABLE modtype TO bradley;
GRANT SELECT ON TABLE modtype TO pts_read;


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 241
-- Name: modificationlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modificationlist FROM PUBLIC;
REVOKE ALL ON TABLE modificationlist FROM bradley;
GRANT ALL ON TABLE modificationlist TO bradley;
GRANT SELECT ON TABLE modificationlist TO pts_read;


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 242
-- Name: modstatus; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE modstatus FROM PUBLIC;
REVOKE ALL ON TABLE modstatus FROM bradley;
GRANT ALL ON TABLE modstatus TO bradley;
GRANT SELECT ON TABLE modstatus TO pts_read;
GRANT INSERT,DELETE,UPDATE ON TABLE modstatus TO pts_write;


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 243
-- Name: modstatus_modstatusid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE modstatus_modstatusid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE modstatus_modstatusid_seq FROM bradley;
GRANT ALL ON SEQUENCE modstatus_modstatusid_seq TO bradley;
GRANT SELECT,UPDATE ON SEQUENCE modstatus_modstatusid_seq TO pts_write;


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 244
-- Name: modtype_modtypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE modtype_modtypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE modtype_modtypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE modtype_modtypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE modtype_modtypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE modtype_modtypeid_seq TO pts_write;


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 246
-- Name: phone; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE phone FROM PUBLIC;
REVOKE ALL ON TABLE phone FROM bradley;
GRANT ALL ON TABLE phone TO bradley;
GRANT SELECT ON TABLE phone TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE phone TO pts_write;


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 247
-- Name: personlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE personlist FROM PUBLIC;
REVOKE ALL ON TABLE personlist FROM bradley;
GRANT ALL ON TABLE personlist TO bradley;
GRANT SELECT ON TABLE personlist TO pts_read;


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 248
-- Name: phone_phoneid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE phone_phoneid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE phone_phoneid_seq FROM bradley;
GRANT ALL ON SEQUENCE phone_phoneid_seq TO bradley;
GRANT SELECT ON SEQUENCE phone_phoneid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE phone_phoneid_seq TO pts_write;


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 249
-- Name: phonetype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE phonetype FROM PUBLIC;
REVOKE ALL ON TABLE phonetype FROM bradley;
GRANT ALL ON TABLE phonetype TO bradley;
GRANT SELECT ON TABLE phonetype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE phonetype TO pts_write;


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 250
-- Name: phonetype_phonetypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE phonetype_phonetypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE phonetype_phonetypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE phonetype_phonetypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE phonetype_phonetypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE phonetype_phonetypeid_seq TO pts_write;


--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 251
-- Name: point; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE point FROM PUBLIC;
REVOKE ALL ON TABLE point FROM bradley;
GRANT ALL ON TABLE point TO bradley;
GRANT SELECT ON TABLE point TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE point TO pts_write;


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 252
-- Name: point_fid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE point_fid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE point_fid_seq FROM bradley;
GRANT ALL ON SEQUENCE point_fid_seq TO bradley;
GRANT SELECT ON SEQUENCE point_fid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE point_fid_seq TO pts_write;


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 253
-- Name: polygon; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE polygon FROM PUBLIC;
REVOKE ALL ON TABLE polygon FROM bradley;
GRANT ALL ON TABLE polygon TO bradley;
GRANT SELECT ON TABLE polygon TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE polygon TO pts_write;


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 254
-- Name: polygon_fid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE polygon_fid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE polygon_fid_seq FROM bradley;
GRANT ALL ON SEQUENCE polygon_fid_seq TO bradley;
GRANT SELECT ON SEQUENCE polygon_fid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE polygon_fid_seq TO pts_write;


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 255
-- Name: position; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE "position" FROM PUBLIC;
REVOKE ALL ON TABLE "position" FROM bradley;
GRANT ALL ON TABLE "position" TO bradley;
GRANT SELECT ON TABLE "position" TO pts_read;


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 256
-- Name: position_positionid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE position_positionid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE position_positionid_seq FROM bradley;
GRANT ALL ON SEQUENCE position_positionid_seq TO bradley;
GRANT SELECT ON SEQUENCE position_positionid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE position_positionid_seq TO pts_write;


--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 172
-- Name: postalcode; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE postalcode FROM PUBLIC;
REVOKE ALL ON TABLE postalcode FROM bradley;
GRANT ALL ON TABLE postalcode TO bradley;
GRANT SELECT ON TABLE postalcode TO pts_read;


--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 258
-- Name: postalcodelist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE postalcodelist FROM PUBLIC;
REVOKE ALL ON TABLE postalcodelist FROM bradley;
GRANT ALL ON TABLE postalcodelist TO bradley;
GRANT SELECT ON TABLE postalcodelist TO pts_read;


--
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 259
-- Name: progress; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE progress FROM PUBLIC;
REVOKE ALL ON TABLE progress FROM bradley;
GRANT ALL ON TABLE progress TO bradley;
GRANT SELECT ON TABLE progress TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE progress TO pts_write;


--
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 260
-- Name: progress_progressid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE progress_progressid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE progress_progressid_seq FROM bradley;
GRANT ALL ON SEQUENCE progress_progressid_seq TO bradley;
GRANT SELECT ON SEQUENCE progress_progressid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE progress_progressid_seq TO pts_write;


--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 261
-- Name: project_projectid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE project_projectid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE project_projectid_seq FROM bradley;
GRANT ALL ON SEQUENCE project_projectid_seq TO bradley;
GRANT SELECT ON SEQUENCE project_projectid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE project_projectid_seq TO pts_write;


--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 262
-- Name: projectcomment; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectcomment FROM PUBLIC;
REVOKE ALL ON TABLE projectcomment FROM bradley;
GRANT ALL ON TABLE projectcomment TO bradley;
GRANT SELECT ON TABLE projectcomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectcomment TO pts_write;


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 263
-- Name: projectcontact; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectcontact FROM PUBLIC;
REVOKE ALL ON TABLE projectcontact FROM bradley;
GRANT ALL ON TABLE projectcontact TO bradley;
GRANT SELECT ON TABLE projectcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectcontact TO pts_write;


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 264
-- Name: projectcontact_projectcontactid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE projectcontact_projectcontactid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE projectcontact_projectcontactid_seq FROM bradley;
GRANT ALL ON SEQUENCE projectcontact_projectcontactid_seq TO bradley;
GRANT SELECT ON SEQUENCE projectcontact_projectcontactid_seq TO pts_read;
GRANT USAGE ON SEQUENCE projectcontact_projectcontactid_seq TO pts_write;


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 265
-- Name: projectcontactlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE projectcontactlist FROM bradley;
GRANT ALL ON TABLE projectcontactlist TO bradley;
GRANT SELECT ON TABLE projectcontactlist TO pts_read;


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 266
-- Name: projectfunderlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectfunderlist FROM PUBLIC;
REVOKE ALL ON TABLE projectfunderlist FROM bradley;
GRANT ALL ON TABLE projectfunderlist TO bradley;
GRANT SELECT ON TABLE projectfunderlist TO pts_read;


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 267
-- Name: projectgnis; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectgnis FROM PUBLIC;
REVOKE ALL ON TABLE projectgnis FROM bradley;
GRANT ALL ON TABLE projectgnis TO bradley;
GRANT SELECT ON TABLE projectgnis TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectgnis TO pts_write;


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 268
-- Name: projectitis; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectitis FROM PUBLIC;
REVOKE ALL ON TABLE projectitis FROM bradley;
GRANT ALL ON TABLE projectitis TO bradley;
GRANT SELECT ON TABLE projectitis TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectitis TO pts_write;


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 269
-- Name: projectline; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectline FROM PUBLIC;
REVOKE ALL ON TABLE projectline FROM bradley;
GRANT ALL ON TABLE projectline TO bradley;
GRANT SELECT ON TABLE projectline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectline TO pts_write;


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 270
-- Name: projectlist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectlist FROM PUBLIC;
REVOKE ALL ON TABLE projectlist FROM bradley;
GRANT ALL ON TABLE projectlist TO bradley;
GRANT SELECT ON TABLE projectlist TO pts_read;
GRANT SELECT ON TABLE projectlist TO pts_write;


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 271
-- Name: projectpoint; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectpoint FROM PUBLIC;
REVOKE ALL ON TABLE projectpoint FROM bradley;
GRANT ALL ON TABLE projectpoint TO bradley;
GRANT SELECT ON TABLE projectpoint TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectpoint TO pts_write;


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 272
-- Name: projectpolygon; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE projectpolygon FROM PUBLIC;
REVOKE ALL ON TABLE projectpolygon FROM bradley;
GRANT ALL ON TABLE projectpolygon TO bradley;
GRANT SELECT ON TABLE projectpolygon TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE projectpolygon TO pts_write;


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 273
-- Name: purchaserequest; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE purchaserequest FROM PUBLIC;
REVOKE ALL ON TABLE purchaserequest FROM bradley;
GRANT ALL ON TABLE purchaserequest TO bradley;
GRANT SELECT ON TABLE purchaserequest TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE purchaserequest TO pts_write;


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 274
-- Name: purchaserequest_purchaserequestid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE purchaserequest_purchaserequestid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE purchaserequest_purchaserequestid_seq FROM bradley;
GRANT ALL ON SEQUENCE purchaserequest_purchaserequestid_seq TO bradley;
GRANT SELECT,UPDATE ON SEQUENCE purchaserequest_purchaserequestid_seq TO pts_write;


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 275
-- Name: reminder; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE reminder FROM PUBLIC;
REVOKE ALL ON TABLE reminder FROM bradley;
GRANT ALL ON TABLE reminder TO bradley;
GRANT SELECT ON TABLE reminder TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE reminder TO pts_write;


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 276
-- Name: reminder_reminderid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE reminder_reminderid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE reminder_reminderid_seq FROM bradley;
GRANT ALL ON SEQUENCE reminder_reminderid_seq TO bradley;
GRANT SELECT ON SEQUENCE reminder_reminderid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE reminder_reminderid_seq TO pts_write;


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 277
-- Name: remindercontact; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE remindercontact FROM PUBLIC;
REVOKE ALL ON TABLE remindercontact FROM bradley;
GRANT ALL ON TABLE remindercontact TO bradley;
GRANT SELECT ON TABLE remindercontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE remindercontact TO pts_write;


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 278
-- Name: roletype; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE roletype FROM PUBLIC;
REVOKE ALL ON TABLE roletype FROM bradley;
GRANT ALL ON TABLE roletype TO bradley;
GRANT SELECT ON TABLE roletype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE roletype TO pts_write;


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 279
-- Name: roletype_roletypeid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE roletype_roletypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE roletype_roletypeid_seq FROM bradley;
GRANT ALL ON SEQUENCE roletype_roletypeid_seq TO bradley;
GRANT SELECT ON SEQUENCE roletype_roletypeid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE roletype_roletypeid_seq TO pts_write;


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 280
-- Name: statelist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE statelist FROM PUBLIC;
REVOKE ALL ON TABLE statelist FROM bradley;
GRANT ALL ON TABLE statelist TO bradley;
GRANT SELECT ON TABLE statelist TO pts_read;


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 281
-- Name: status; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE status FROM PUBLIC;
REVOKE ALL ON TABLE status FROM bradley;
GRANT ALL ON TABLE status TO bradley;
GRANT SELECT ON TABLE status TO pts_read;


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 282
-- Name: status_statusid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE status_statusid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE status_statusid_seq FROM bradley;
GRANT ALL ON SEQUENCE status_statusid_seq TO bradley;
GRANT SELECT ON SEQUENCE status_statusid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE status_statusid_seq TO pts_write;


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 283
-- Name: statuslist; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE statuslist FROM PUBLIC;
REVOKE ALL ON TABLE statuslist FROM bradley;
GRANT ALL ON TABLE statuslist TO bradley;
GRANT SELECT ON TABLE statuslist TO pts_read;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 284
-- Name: task; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE task FROM PUBLIC;
REVOKE ALL ON TABLE task FROM bradley;
GRANT ALL ON TABLE task TO bradley;
GRANT SELECT ON TABLE task TO pts_read;


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 285
-- Name: timeline; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE timeline FROM PUBLIC;
REVOKE ALL ON TABLE timeline FROM bradley;
GRANT ALL ON TABLE timeline TO bradley;
GRANT SELECT ON TABLE timeline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE timeline TO pts_write;


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 286
-- Name: timeline_timelineid_seq; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON SEQUENCE timeline_timelineid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE timeline_timelineid_seq FROM bradley;
GRANT ALL ON SEQUENCE timeline_timelineid_seq TO bradley;
GRANT SELECT ON SEQUENCE timeline_timelineid_seq TO pts_read;
GRANT SELECT,UPDATE ON SEQUENCE timeline_timelineid_seq TO pts_write;


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 287
-- Name: userinfo; Type: ACL; Schema: pts; Owner: bradley
--

REVOKE ALL ON TABLE userinfo FROM PUBLIC;
REVOKE ALL ON TABLE userinfo FROM bradley;
GRANT ALL ON TABLE userinfo TO bradley;
GRANT SELECT ON TABLE userinfo TO pts_read;


-- Completed on 2012-05-22 17:02:30 AKDT

--
-- PostgreSQL database dump complete
--

