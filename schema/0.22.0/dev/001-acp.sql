--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.14
-- Dumped by pg_dump version 9.5.14

-- Started on 2018-11-07 16:22:51 AKST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 17 (class 2615 OID 58531)
-- Name: acp; Type: SCHEMA; Schema: -; Owner: bradley
--

CREATE SCHEMA acp;


ALTER SCHEMA acp OWNER TO bradley;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 567 (class 1259 OID 61841)
-- Name: address; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.address (
    addressid integer DEFAULT nextval('common.address_addressid_seq'::regclass) NOT NULL,
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


ALTER TABLE acp.address OWNER TO bradley;

--
-- TOC entry 6750 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.street1; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.street1 IS 'address line 1';


--
-- TOC entry 6751 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.street2; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.street2 IS 'address line 2';


--
-- TOC entry 6752 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.postalcode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.postalcode IS 'varchar for Canadian postal code';


--
-- TOC entry 6753 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.postal4; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.postal4 IS '4 digit zip extension';


--
-- TOC entry 6754 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.stateid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.stateid IS 'state GNIS feature id or GEOnet Names Server Geopolitical Codes id';


--
-- TOC entry 6755 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.countyid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.countyid IS 'county GNIS feature or GEOnet Names Server Geopolitical Codes id';


--
-- TOC entry 6756 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.latitude; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.latitude IS 'WGS84';


--
-- TOC entry 6757 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.longitude; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.longitude IS 'WGS84';


--
-- TOC entry 6758 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.priority; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.address.priority IS 'primary, secondary, etc.';


--
-- TOC entry 568 (class 1259 OID 61849)
-- Name: contact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.contact (
    contactid integer DEFAULT nextval('common.contact_contactid_seq'::regclass) NOT NULL,
    comment character varying(250),
    dunsnumber character varying,
    contacttypeid integer NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


ALTER TABLE acp.contact OWNER TO bradley;

--
-- TOC entry 6760 (class 0 OID 0)
-- Dependencies: 568
-- Name: COLUMN contact.contacttypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contact.contacttypeid IS 'hatchery, refuge, park, military base';


--
-- TOC entry 6761 (class 0 OID 0)
-- Dependencies: 568
-- Name: COLUMN contact.inactive; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contact.inactive IS 'Indicates the contact status.';


--
-- TOC entry 6762 (class 0 OID 0)
-- Dependencies: 568
-- Name: COLUMN contact.uuid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';


--
-- TOC entry 569 (class 1259 OID 61858)
-- Name: contactcontactgroup; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.contactcontactgroup (
    groupid integer NOT NULL,
    contactid integer NOT NULL,
    positionid integer NOT NULL,
    contactcontactgroupid integer DEFAULT nextval('common.contactcontactgroup_contactcontactgroupid_seq'::regclass) NOT NULL,
    priority smallint NOT NULL,
    CONSTRAINT contactcontactgroup_check CHECK ((NOT (groupid = contactid)))
);


ALTER TABLE acp.contactcontactgroup OWNER TO bradley;

--
-- TOC entry 6764 (class 0 OID 0)
-- Dependencies: 569
-- Name: COLUMN contactcontactgroup.positionid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contactcontactgroup.positionid IS 'PK for POSITION';


--
-- TOC entry 6765 (class 0 OID 0)
-- Dependencies: 569
-- Name: COLUMN contactcontactgroup.contactcontactgroupid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contactcontactgroup.contactcontactgroupid IS 'PK';


--
-- TOC entry 570 (class 1259 OID 61863)
-- Name: contactgroup; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.contactgroup (
    contactid integer NOT NULL,
    organization boolean,
    name character varying(100) NOT NULL,
    acronym character varying(7) NOT NULL
);


ALTER TABLE acp.contactgroup OWNER TO bradley;

--
-- TOC entry 6767 (class 0 OID 0)
-- Dependencies: 570
-- Name: TABLE contactgroup; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.contactgroup IS 'info for organizations, agencies and their subunits';


--
-- TOC entry 6768 (class 0 OID 0)
-- Dependencies: 570
-- Name: COLUMN contactgroup.organization; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contactgroup.organization IS 'Sepecifies whether contact is considered an organization as defined by business rules';


--
-- TOC entry 6769 (class 0 OID 0)
-- Dependencies: 570
-- Name: COLUMN contactgroup.acronym; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contactgroup.acronym IS 'short acronym identifying unit';


--
-- TOC entry 571 (class 1259 OID 61866)
-- Name: eaddress; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.eaddress (
    eaddressid integer DEFAULT nextval('common.electadd_electaddid_seq'::regclass) NOT NULL,
    contactid integer NOT NULL,
    eaddresstypeid integer NOT NULL,
    uri character varying(250) NOT NULL,
    priority smallint NOT NULL,
    comment character varying(250)
);


ALTER TABLE acp.eaddress OWNER TO bradley;

--
-- TOC entry 6771 (class 0 OID 0)
-- Dependencies: 571
-- Name: TABLE eaddress; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.eaddress IS 'electronic address';


--
-- TOC entry 6772 (class 0 OID 0)
-- Dependencies: 571
-- Name: COLUMN eaddress.uri; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.eaddress.uri IS 'uniform resource identifier, e.g. website address';


--
-- TOC entry 572 (class 1259 OID 61873)
-- Name: person; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.person (
    contactid integer NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    middlename character varying,
    suffix character varying,
    jobtitleid integer,
    positionid integer
);


ALTER TABLE acp.person OWNER TO bradley;

--
-- TOC entry 6774 (class 0 OID 0)
-- Dependencies: 572
-- Name: COLUMN person.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.person.contactid IS 'PK for PERSON';


--
-- TOC entry 6775 (class 0 OID 0)
-- Dependencies: 572
-- Name: COLUMN person.positionid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.person.positionid IS 'Primary position description for this person';


--
-- TOC entry 573 (class 1259 OID 61879)
-- Name: phone; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.phone (
    phoneid integer DEFAULT nextval('common.phone_phoneid_seq'::regclass) NOT NULL,
    contactid integer NOT NULL,
    addressid integer,
    phonetypeid integer NOT NULL,
    countryiso character(2) NOT NULL,
    areacode smallint NOT NULL,
    phnumber integer NOT NULL,
    extension integer,
    priority smallint DEFAULT 1 NOT NULL
);


ALTER TABLE acp.phone OWNER TO bradley;

--
-- TOC entry 6777 (class 0 OID 0)
-- Dependencies: 573
-- Name: TABLE phone; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.phone IS 'phone numbers, stored without punctuation';


--
-- TOC entry 6778 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.phonetypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.phone.phonetypeid IS 'FK for PHONETYPE';


--
-- TOC entry 6779 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.countryiso; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.phone.countryiso IS 'country code';


--
-- TOC entry 6780 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.areacode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.phone.areacode IS 'area or city code';


--
-- TOC entry 6781 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.phnumber; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.phone.phnumber IS 'main body of phone number';


--
-- TOC entry 6782 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.extension; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.phone.extension IS 'phone number extension';


--
-- TOC entry 6783 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.priority; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.phone.priority IS 'primary,secondary,etc.';


--
-- TOC entry 574 (class 1259 OID 61884)
-- Name: alccstaff; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.alccstaff AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM ((((((acp.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN acp.contactcontactgroup sc ON (((person.contactid = sc.contactid) AND (sc.groupid = 42))))
     JOIN acp.contact ON (((contact.contactid = person.contactid) AND (contact.contacttypeid = 5))))
  ORDER BY person.lastname;


ALTER TABLE acp.alccstaff OWNER TO bradley;

--
-- TOC entry 575 (class 1259 OID 61889)
-- Name: alccsteeringcommittee; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.alccsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM ((((((acp.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN acp.contactcontactgroup sc ON (((person.contactid = sc.contactid) AND (sc.groupid = 42) AND (sc.positionid = ANY (ARRAY[85, 96])))))
     JOIN cvl."position" ON ((sc.positionid = "position".positionid)))
  ORDER BY person.lastname;


ALTER TABLE acp.alccsteeringcommittee OWNER TO bradley;

--
-- TOC entry 576 (class 1259 OID 61894)
-- Name: deliverablemod; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.deliverablemod (
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    duedate date NOT NULL,
    receiveddate date,
    acpinterval interval,
    invalid boolean DEFAULT false,
    publish boolean DEFAULT false NOT NULL,
    restricted boolean DEFAULT true NOT NULL,
    accessdescription character varying,
    parentmodificationid integer,
    parentdeliverableid integer,
    personid integer NOT NULL,
    startdate date,
    enddate date,
    reminder boolean DEFAULT true,
    staffonly boolean DEFAULT false
);


ALTER TABLE acp.deliverablemod OWNER TO bradley;

--
-- TOC entry 6787 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6788 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6789 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.duedate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.duedate IS 'The date the deliverable is due';


--
-- TOC entry 6790 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.receiveddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.receiveddate IS '***Deprecated use DELIVERABLEMODSTATUS*** Date the deliverable is delivered';


--
-- TOC entry 6791 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.acpinterval; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.acpinterval IS 'Interval of recurrent deliverables.';


--
-- TOC entry 6792 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.invalid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.invalid IS 'DEPRECATED, Indicates whether deliverable is valid';


--
-- TOC entry 6793 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.publish; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.publish IS 'Designates whether the product may be distributed';


--
-- TOC entry 6794 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.accessdescription; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.accessdescription IS 'Description of constraints to be met when publishing the delivered product';


--
-- TOC entry 6795 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.parentmodificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.parentmodificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6796 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.parentdeliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.parentdeliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6797 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.personid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.personid IS 'FK for person, identifies user responsible for deliverablemod';


--
-- TOC entry 6798 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.startdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.startdate IS 'Starting date for interval in which the deliverable is applicable, i.e. reporting period.';


--
-- TOC entry 6799 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.enddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.enddate IS 'Ending date for interval in which the deliverable is applicable, i.e. reporting period.';


--
-- TOC entry 6800 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.reminder; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.reminder IS 'Whether to enable automated reminders.';


--
-- TOC entry 6801 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.staffonly; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemod.staffonly IS 'Whether to limit reminders to staff.';


--
-- TOC entry 577 (class 1259 OID 61905)
-- Name: funding; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.funding (
    fundingid integer DEFAULT nextval('common.funding_fundingid_seq'::regclass) NOT NULL,
    fundingtypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    amount numeric NOT NULL,
    modificationid integer NOT NULL,
    projectcontactid integer NOT NULL,
    fundingrecipientid integer
);


ALTER TABLE acp.funding OWNER TO bradley;

--
-- TOC entry 6803 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.funding.title IS 'User identifier for funding';


--
-- TOC entry 6804 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.amount; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.funding.amount IS 'Amount of funding associated with modification';


--
-- TOC entry 6805 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.funding.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6806 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.fundingrecipientid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.funding.fundingrecipientid IS 'Entity receiving funds';


--
-- TOC entry 578 (class 1259 OID 61912)
-- Name: invoice; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.invoice (
    invoiceid integer DEFAULT nextval('common.invoice_invoiceid_seq'::regclass) NOT NULL,
    datereceived date NOT NULL,
    title character varying(250) NOT NULL,
    dateclosed date,
    amount numeric NOT NULL,
    fundingid integer NOT NULL,
    projectcontactid integer NOT NULL
);


ALTER TABLE acp.invoice OWNER TO bradley;

--
-- TOC entry 6808 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.datereceived; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.invoice.datereceived IS 'date invoice was received';


--
-- TOC entry 6809 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.invoice.title IS 'User identifier for invoice';


--
-- TOC entry 6810 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.dateclosed; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.invoice.dateclosed IS 'Date invoice was processed';


--
-- TOC entry 6811 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.amount; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.invoice.amount IS 'Totla amount for invoice';


--
-- TOC entry 579 (class 1259 OID 61919)
-- Name: moddocstatus; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.moddocstatus (
    moddocstatusid integer DEFAULT nextval('common.moddocstatus_moddocstatusid_seq'::regclass) NOT NULL,
    modificationid integer,
    moddoctypeid integer,
    moddocstatustypeid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying,
    effectivedate date NOT NULL
);


ALTER TABLE acp.moddocstatus OWNER TO bradley;

--
-- TOC entry 6813 (class 0 OID 0)
-- Dependencies: 579
-- Name: TABLE moddocstatus; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.moddocstatus IS 'History of processing status for a modification document';


--
-- TOC entry 6814 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.moddocstatusid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.moddocstatus.moddocstatusid IS 'PK for MODDOCSTATUS';


--
-- TOC entry 6815 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.moddocstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6816 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.moddoctypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.moddocstatus.moddoctypeid IS 'PK for MODDOCTYPE';


--
-- TOC entry 6817 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.moddocstatustypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.moddocstatus.moddocstatustypeid IS 'FK for MODDOCSTATUSTYPE';


--
-- TOC entry 6818 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.moddocstatus.contactid IS 'PK for PERSON';


--
-- TOC entry 6819 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.effectivedate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.moddocstatus.effectivedate IS 'Date status became effective.';


--
-- TOC entry 580 (class 1259 OID 61926)
-- Name: modification; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.modification (
    modificationid integer DEFAULT nextval('common.modification_modificationid_seq'::regclass) NOT NULL,
    projectid integer NOT NULL,
    personid integer NOT NULL,
    modtypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    description character varying NOT NULL,
    modificationcode character varying,
    effectivedate date,
    startdate date,
    enddate date,
    datecreated date DEFAULT now() NOT NULL,
    parentmodificationid integer,
    shorttitle character varying(60)
);


ALTER TABLE acp.modification OWNER TO bradley;

--
-- TOC entry 6821 (class 0 OID 0)
-- Dependencies: 580
-- Name: TABLE modification; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.modification IS 'Tracks all modifications to projects,including proposals and agreements';


--
-- TOC entry 6822 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6823 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.personid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.personid IS 'FK for person, identifies user responsible for modification';


--
-- TOC entry 6824 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.title IS 'Short description of modification';


--
-- TOC entry 6825 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.description; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.description IS 'Summary of modification appropriate for publication';


--
-- TOC entry 6826 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.modificationcode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.modificationcode IS 'user identifier for modification, e.g. agreement number';


--
-- TOC entry 6827 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.effectivedate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.effectivedate IS 'Date modification takes effect';


--
-- TOC entry 6828 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.startdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.startdate IS 'Expected Start date of MODIFICATION';


--
-- TOC entry 6829 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.enddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.enddate IS 'Expected End date of MODIFICATION';


--
-- TOC entry 6830 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.datecreated; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.datecreated IS 'Date the modification is created in the database.';


--
-- TOC entry 6831 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.parentmodificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.parentmodificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6832 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.shorttitle; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modification.shorttitle IS 'Truncated title for display';


--
-- TOC entry 581 (class 1259 OID 61934)
-- Name: modstatus; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.modstatus (
    modificationid integer NOT NULL,
    statusid integer NOT NULL,
    effectivedate date NOT NULL,
    modstatusid integer DEFAULT nextval('common.modstatus_modstatusid_seq'::regclass) NOT NULL,
    comment character varying
);


ALTER TABLE acp.modstatus OWNER TO bradley;

--
-- TOC entry 6834 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6835 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.statusid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modstatus.statusid IS 'PK for STATUS';


--
-- TOC entry 6836 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.effectivedate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 6837 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.modstatusid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modstatus.modstatusid IS 'PK for MODSTATUS, created for convenience when using client applications';


--
-- TOC entry 582 (class 1259 OID 61941)
-- Name: modificationstatus; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.modificationstatus AS
 SELECT modification.modificationid,
    modstatus.modstatusid,
    modstatus.statusid,
    modstatus.effectivedate,
    modstatus.comment,
    modstatus.weight,
    modstatus.status,
    (( SELECT count(deliverablemod.deliverableid) AS count
           FROM acp.deliverablemod
          WHERE ((deliverablemod.modificationid = modification.modificationid) AND ((common.deliverable_statusid(deliverablemod.deliverableid) < 40) OR (common.deliverable_statusid(deliverablemod.deliverableid) IS NULL)))))::integer AS incdeliverables
   FROM (acp.modification
     JOIN ( SELECT modstatus_1.modificationid,
            modstatus_1.statusid,
            modstatus_1.effectivedate,
            modstatus_1.modstatusid,
            modstatus_1.comment,
            status.weight,
            status.status,
            row_number() OVER (PARTITION BY modstatus_1.modificationid ORDER BY modstatus_1.effectivedate DESC, status.weight DESC) AS rank
           FROM (acp.modstatus modstatus_1
             JOIN cvl.status USING (statusid))) modstatus USING (modificationid))
  WHERE (modstatus.rank = 1)
  ORDER BY
        CASE modstatus.statusid
            WHEN 4 THEN 1
            WHEN 8 THEN 2
            WHEN 5 THEN 3
            ELSE 4
        END;


ALTER TABLE acp.modificationstatus OWNER TO bradley;

--
-- TOC entry 6839 (class 0 OID 0)
-- Dependencies: 582
-- Name: COLUMN modificationstatus.incdeliverables; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modificationstatus.incdeliverables IS 'Indicates if this modification has incomplete deliverables.';


--
-- TOC entry 583 (class 1259 OID 61946)
-- Name: project; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.project (
    projectid integer DEFAULT nextval('common.project_projectid_seq'::regclass) NOT NULL,
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
    shorttitle character varying(60) NOT NULL,
    exportmetadata boolean DEFAULT false NOT NULL,
    supplemental character varying,
    metadataupdate timestamp with time zone,
    sciencebaseid character varying
);


ALTER TABLE acp.project OWNER TO bradley;

--
-- TOC entry 6841 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.orgid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.orgid IS 'Identifies organization that owns the project';


--
-- TOC entry 6842 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.title IS 'Name of project';


--
-- TOC entry 6843 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.fiscalyear; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.fiscalyear IS 'Fiscal year of project code';


--
-- TOC entry 6844 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.number; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.number IS 'Project number component of project code';


--
-- TOC entry 6845 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.startdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.startdate IS 'Date of expected start';


--
-- TOC entry 6846 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.enddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.enddate IS 'Date of expected end';


--
-- TOC entry 6847 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.description; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.description IS 'Short project description';


--
-- TOC entry 6848 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.abstract; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.abstract IS 'Long description of project';


--
-- TOC entry 6849 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.uuid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.uuid IS 'Universally unique identifier for project (from ADiwg specification)';


--
-- TOC entry 6850 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.shorttitle; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.shorttitle IS 'Truncated title. Used in factsheets and other outreach materials.';


--
-- TOC entry 6851 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.exportmetadata; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.exportmetadata IS 'Specifies whether project metadata should be exported.';


--
-- TOC entry 6852 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.supplemental; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.supplemental IS 'Additional information about the project that is not included in the abstract.';


--
-- TOC entry 6853 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.metadataupdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.metadataupdate IS 'Date when metadata was last updated (published).';


--
-- TOC entry 6854 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.sciencebaseid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


--
-- TOC entry 584 (class 1259 OID 61956)
-- Name: projectlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectlist AS
 SELECT DISTINCT project.projectid,
    project.orgid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    project.shorttitle,
    status.status,
    project.exportmetadata,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged
   FROM ((((((acp.project
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN acp.modification USING (projectid))
     LEFT JOIN acp.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((acp.invoice invoice_1
             JOIN acp.funding funding_1 USING (fundingid))
             JOIN acp.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (acp.funding funding_1
             JOIN acp.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid));


ALTER TABLE acp.projectlist OWNER TO bradley;

--
-- TOC entry 585 (class 1259 OID 61961)
-- Name: allmoddocstatus; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.allmoddocstatus AS
 SELECT q.modificationid,
    q.projectid,
    q.modificationcode,
    p.shorttitle,
    p.projectcode,
    q.modtype,
    q.moddoctypeid,
    q.code,
    q.status,
    q.weight,
    q.title
   FROM (( SELECT m.modificationid,
            modtypemoddoctype.moddoctypeid,
            m.projectid,
            mt.code AS modtype,
            m.title,
            COALESCE(mdst.code, 'Not Started'::character varying) AS code,
            m.modificationcode,
            rank() OVER (PARTITION BY m.modificationid, modtypemoddoctype.moddoctypeid ORDER BY mds.effectivedate DESC, mdst.weight DESC) AS rank,
            ms.status,
            ms.weight
           FROM (((((acp.modification m
             LEFT JOIN acp.modificationstatus ms USING (modificationid))
             JOIN cvl.modtype mt USING (modtypeid))
             JOIN cvl.modtypemoddoctype USING (modtypeid))
             LEFT JOIN acp.moddocstatus mds USING (modificationid, moddoctypeid))
             LEFT JOIN cvl.moddocstatustype mdst USING (moddocstatustypeid))
          WHERE (NOT modtypemoddoctype.inactive)) q
     JOIN acp.projectlist p USING (projectid))
  WHERE (q.rank = 1)
  ORDER BY q.modificationid, q.moddoctypeid;


ALTER TABLE acp.allmoddocstatus OWNER TO bradley;

--
-- TOC entry 586 (class 1259 OID 61966)
-- Name: audit; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.audit (
    auditid integer DEFAULT nextval('common.audit_auditid_seq'::regclass) NOT NULL,
    newval character varying NOT NULL,
    oldval character varying NOT NULL,
    action character varying NOT NULL,
    model character varying NOT NULL,
    field character varying NOT NULL,
    stamp timestamp without time zone NOT NULL,
    contactid integer NOT NULL,
    modelid integer NOT NULL
);


ALTER TABLE acp.audit OWNER TO bradley;

--
-- TOC entry 6858 (class 0 OID 0)
-- Dependencies: 586
-- Name: TABLE audit; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.audit IS 'Tracks changes to data tables';


--
-- TOC entry 6859 (class 0 OID 0)
-- Dependencies: 586
-- Name: COLUMN audit.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.audit.contactid IS 'PK for PERSON';


--
-- TOC entry 587 (class 1259 OID 61973)
-- Name: catalogprojectcategory; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.catalogprojectcategory (
    projectcode character varying,
    category1 character varying,
    category2 character varying,
    category3 character varying,
    projectid integer NOT NULL,
    usertype1 character varying,
    usertype2 character varying,
    usertype3 character varying,
    endusers character varying
);


ALTER TABLE acp.catalogprojectcategory OWNER TO bradley;

--
-- TOC entry 6861 (class 0 OID 0)
-- Dependencies: 587
-- Name: TABLE catalogprojectcategory; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.catalogprojectcategory IS 'Project Categories for the Simple National Project Catalog';


--
-- TOC entry 6862 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.usertype1; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.catalogprojectcategory.usertype1 IS 'Who will benefit from this project.';


--
-- TOC entry 6863 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.usertype2; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.catalogprojectcategory.usertype2 IS 'Who will benefit from this project.';


--
-- TOC entry 6864 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.usertype3; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.catalogprojectcategory.usertype3 IS 'Who will benefit from this project.';


--
-- TOC entry 6865 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.endusers; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.catalogprojectcategory.endusers IS 'Target Audience/End Users';


--
-- TOC entry 588 (class 1259 OID 61979)
-- Name: contactcostcode; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.contactcostcode (
    costcode character varying NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE acp.contactcostcode OWNER TO bradley;

--
-- TOC entry 6867 (class 0 OID 0)
-- Dependencies: 588
-- Name: TABLE contactcostcode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.contactcostcode IS 'List of common costcodes';


--
-- TOC entry 6868 (class 0 OID 0)
-- Dependencies: 588
-- Name: COLUMN contactcostcode.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.contactcostcode.contactid IS 'PK of organization that chargecode belongs to';


--
-- TOC entry 589 (class 1259 OID 61985)
-- Name: contactgrouplist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.contactgrouplist AS
 WITH RECURSIVE grouptree AS (
         SELECT contactgroup.contactid,
            contactgroup.organization,
            contactgroup.name,
            contactgroup.acronym,
            contactcontactgroup.groupid,
            (contactgroup.name)::text AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup.contactid] AS contactids
           FROM (acp.contactgroup
             LEFT JOIN acp.contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            cg.name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' -> '::text) || (cg.name)::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((acp.contactgroup cg
             JOIN acp.contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        )
 SELECT grouptree.contactid,
    grouptree.groupid AS parentgroupid,
    grouptree.organization,
    grouptree.name,
    grouptree.acronym,
    grouptree.fullname,
    grouptree.parentname,
    grouptree.contactids
   FROM grouptree;


ALTER TABLE acp.contactgrouplist OWNER TO bradley;

--
-- TOC entry 590 (class 1259 OID 61990)
-- Name: contactprimaryinfo; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.contactprimaryinfo AS
 SELECT person.contactid,
    (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS name,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM ((acp.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
UNION
 SELECT cg.contactid,
    cg.name,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM ((acp.contactgroup cg
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((cg.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((cg.contactid = e.contactid) AND (e.rank = 1))));


ALTER TABLE acp.contactprimaryinfo OWNER TO bradley;

--
-- TOC entry 591 (class 1259 OID 61995)
-- Name: projectcontact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectcontact (
    projectid integer NOT NULL,
    contactid integer NOT NULL,
    roletypeid integer NOT NULL,
    priority smallint NOT NULL,
    contactprojectcode character varying,
    partner boolean DEFAULT false NOT NULL,
    projectcontactid integer DEFAULT nextval('common.projectcontact_projectcontactid_seq'::regclass) NOT NULL,
    reminder boolean
);


ALTER TABLE acp.projectcontact OWNER TO bradley;

--
-- TOC entry 6872 (class 0 OID 0)
-- Dependencies: 591
-- Name: TABLE projectcontact; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.projectcontact IS 'Identifies project contacts and roles';


--
-- TOC entry 6873 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.roletypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcontact.roletypeid IS 'PK for ROLETYPE';


--
-- TOC entry 6874 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.contactprojectcode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcontact.contactprojectcode IS 'Project identifier assigned by contact';


--
-- TOC entry 6875 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.projectcontactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcontact.projectcontactid IS 'PK for PROJECTCONTACT';


--
-- TOC entry 6876 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.reminder; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcontact.reminder IS 'Indicates whether the contact is included on reminders notices.';


--
-- TOC entry 592 (class 1259 OID 62003)
-- Name: contactprojectslist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.contactprojectslist AS
 WITH projectcode AS (
         SELECT project.projectid,
            common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS code
           FROM (acp.project
             JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
        )
 SELECT (((person.lastname)::text || ', '::text) || (person.firstname)::text) AS name,
    string_agg((projectcode.code)::text, ','::text ORDER BY (projectcode.*)::text) AS projects,
    'no'::text AS isgroup
   FROM ((acp.person
     LEFT JOIN acp.projectcontact USING (contactid))
     LEFT JOIN projectcode USING (projectid))
  GROUP BY projectcontact.contactid, person.lastname, person.firstname
UNION
 SELECT contactgrouplist.fullname AS name,
    string_agg((projectcode.code)::text, ','::text ORDER BY (projectcode.*)::text) AS projects,
    'yes'::text AS isgroup
   FROM ((acp.contactgrouplist
     LEFT JOIN acp.projectcontact USING (contactid))
     LEFT JOIN projectcode USING (projectid))
  GROUP BY projectcontact.contactid, contactgrouplist.fullname
  ORDER BY 1;


ALTER TABLE acp.contactprojectslist OWNER TO bradley;

--
-- TOC entry 593 (class 1259 OID 62008)
-- Name: costcode; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.costcode (
    costcodeid integer DEFAULT nextval('common.costcode_costcodeid_seq'::regclass) NOT NULL,
    fundingid integer NOT NULL,
    costcode character varying NOT NULL,
    startdate date NOT NULL,
    enddate date
);


ALTER TABLE acp.costcode OWNER TO bradley;

--
-- TOC entry 6879 (class 0 OID 0)
-- Dependencies: 593
-- Name: TABLE costcode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.costcode IS 'Costcode associated with funding';


--
-- TOC entry 6880 (class 0 OID 0)
-- Dependencies: 593
-- Name: COLUMN costcode.costcode; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.costcode.costcode IS 'Cost code associated with FUNDING';


--
-- TOC entry 6881 (class 0 OID 0)
-- Dependencies: 593
-- Name: COLUMN costcode.startdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.costcode.startdate IS 'Date from which costcode is active';


--
-- TOC entry 6882 (class 0 OID 0)
-- Dependencies: 593
-- Name: COLUMN costcode.enddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.costcode.enddate IS 'Date after which costcode is invalid';


--
-- TOC entry 594 (class 1259 OID 62015)
-- Name: costcodeinvoice; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.costcodeinvoice (
    costcodeid integer NOT NULL,
    invoiceid integer NOT NULL,
    amount numeric NOT NULL,
    datecharged date NOT NULL,
    costcodeinvoiceid integer DEFAULT nextval('common.costcodeinvoice_costcodeinvoiceid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.costcodeinvoice OWNER TO bradley;

--
-- TOC entry 6884 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN costcodeinvoice.amount; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.costcodeinvoice.amount IS 'Amount charged to specific code';


--
-- TOC entry 6885 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN costcodeinvoice.datecharged; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.costcodeinvoice.datecharged IS 'Date invoice charged to code';


--
-- TOC entry 6886 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN costcodeinvoice.costcodeinvoiceid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.costcodeinvoice.costcodeinvoiceid IS 'PK for costcodeinvoice, created to ease client implementation';


--
-- TOC entry 595 (class 1259 OID 62022)
-- Name: countylist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.countylist AS
 SELECT govunit.featureid AS countyid,
    govunit.unittype,
    govunit.countynumeric,
    govunit.countyname,
    govunit.statenumeric,
    govunit.statealpha,
    govunit.statename,
    govunit.countryalpha,
    govunit.countryname,
    govunit.featurename
   FROM cvl.govunit
  WHERE ((govunit.unittype)::text = 'COUNTY'::text)
  ORDER BY govunit.countyname;


ALTER TABLE acp.countylist OWNER TO bradley;

--
-- TOC entry 596 (class 1259 OID 62026)
-- Name: deliverable; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.deliverable (
    deliverableid integer DEFAULT nextval('common.deliverable_deliverableid_seq'::regclass) NOT NULL,
    deliverabletypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    description character varying NOT NULL,
    code character varying
);


ALTER TABLE acp.deliverable OWNER TO bradley;

--
-- TOC entry 6889 (class 0 OID 0)
-- Dependencies: 596
-- Name: TABLE deliverable; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.deliverable IS 'Project deliverables';


--
-- TOC entry 6890 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverable.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6891 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.deliverabletypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverable.deliverabletypeid IS 'PK of DELIVERABLETYPE';


--
-- TOC entry 6892 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverable.title IS 'Short title of acpliverable';


--
-- TOC entry 6893 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.code; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverable.code IS 'Code associated with the deliverable.';


--
-- TOC entry 597 (class 1259 OID 62033)
-- Name: deliverablemodstatus; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.deliverablemodstatus (
    deliverablemodstatusid integer DEFAULT nextval('common.deliverablemodstatus_deliverablemodstatusid_seq'::regclass) NOT NULL,
    deliverablestatusid integer NOT NULL,
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    effectivedate date NOT NULL,
    comment character varying,
    contactid integer NOT NULL
);


ALTER TABLE acp.deliverablemodstatus OWNER TO bradley;

--
-- TOC entry 6895 (class 0 OID 0)
-- Dependencies: 597
-- Name: TABLE deliverablemodstatus; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.deliverablemodstatus IS 'Links DELIVERABLEMOD to DELIVERABLESTATUS';


--
-- TOC entry 6896 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.deliverablemodstatusid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemodstatus.deliverablemodstatusid IS 'PK for MODSTATUS, created for convenience when using client applications';


--
-- TOC entry 6897 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.deliverablestatusid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemodstatus.deliverablestatusid IS 'PK for DELIVERABLESTATUS';


--
-- TOC entry 6898 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemodstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6899 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemodstatus.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6900 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.effectivedate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablemodstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 598 (class 1259 OID 62040)
-- Name: deliverableall; Type: VIEW; Schema: acp; Owner: pts_admin
--

CREATE VIEW acp.deliverableall AS
 SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.acpinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    (EXISTS ( SELECT 1
           FROM acp.deliverablemod dm
          WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly,
    deliverable.code
   FROM (((acp.deliverablemod
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN acp.deliverable USING (deliverableid));


ALTER TABLE acp.deliverableall OWNER TO pts_admin;

--
-- TOC entry 599 (class 1259 OID 62045)
-- Name: deliverablecalendar; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.deliverablecalendar AS
 SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverable.title,
    deliverable.description,
    (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS manager,
    deliverabletype.type,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    modification.projectid,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - deliverablemod.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    project.shorttitle
   FROM ((((((((acp.deliverablemod
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN acp.modification USING (modificationid))
     JOIN acp.project USING (projectid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN acp.deliverable USING (deliverableid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN acp.person ON ((deliverablemod.personid = person.contactid)))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod dm
          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))));


ALTER TABLE acp.deliverablecalendar OWNER TO bradley;

--
-- TOC entry 600 (class 1259 OID 62050)
-- Name: deliverablecomment; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.deliverablecomment (
    deliverableid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    deliverablecommentid integer DEFAULT nextval('common.deliverablecomment_deliverablecommentid_seq'::regclass) NOT NULL,
    datemodified date NOT NULL
);


ALTER TABLE acp.deliverablecomment OWNER TO bradley;

--
-- TOC entry 6904 (class 0 OID 0)
-- Dependencies: 600
-- Name: COLUMN deliverablecomment.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablecomment.deliverableid IS 'FK for DELIVERABLE';


--
-- TOC entry 6905 (class 0 OID 0)
-- Dependencies: 600
-- Name: COLUMN deliverablecomment.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablecomment.contactid IS 'FK for PERSON';


--
-- TOC entry 6906 (class 0 OID 0)
-- Dependencies: 600
-- Name: COLUMN deliverablecomment.datemodified; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablecomment.datemodified IS 'Date that the comment was modified.';


--
-- TOC entry 601 (class 1259 OID 62057)
-- Name: deliverablecontact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.deliverablecontact (
    deliverableid integer NOT NULL,
    contactid integer NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    roletypeid integer
);


ALTER TABLE acp.deliverablecontact OWNER TO bradley;

--
-- TOC entry 6908 (class 0 OID 0)
-- Dependencies: 601
-- Name: TABLE deliverablecontact; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.deliverablecontact IS 'Identifies contacts for each deliverable.';


--
-- TOC entry 6909 (class 0 OID 0)
-- Dependencies: 601
-- Name: COLUMN deliverablecontact.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablecontact.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6910 (class 0 OID 0)
-- Dependencies: 601
-- Name: COLUMN deliverablecontact.roletypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablecontact.roletypeid IS 'FK for ROLETYPE';


--
-- TOC entry 602 (class 1259 OID 62061)
-- Name: personlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.personlist AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM ((((acp.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
  ORDER BY person.lastname, person.contactid;


ALTER TABLE acp.personlist OWNER TO bradley;

--
-- TOC entry 603 (class 1259 OID 62066)
-- Name: deliverabledue; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM acp.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
    (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact,
    personlist.priemail AS email,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM (((((((((acp.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN acp.deliverablemod dm USING (deliverableid))
     JOIN acp.modification USING (modificationid))
     JOIN acp.project USING (projectid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM acp.projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN acp.personlist ON ((personlist.contactid = projectcontact.contactid)))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;


ALTER TABLE acp.deliverabledue OWNER TO bradley;

--
-- TOC entry 604 (class 1259 OID 62071)
-- Name: deliverablelist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.deliverablelist AS
 SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.acpinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    modification.projectid
   FROM (((acp.deliverablemod
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN acp.deliverable USING (deliverableid))
     JOIN acp.modification USING (modificationid))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod dm
          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))));


ALTER TABLE acp.deliverablelist OWNER TO bradley;

--
-- TOC entry 6914 (class 0 OID 0)
-- Dependencies: 604
-- Name: VIEW deliverablelist; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON VIEW acp.deliverablelist IS 'List of all valid, non-modified deliverables';


--
-- TOC entry 605 (class 1259 OID 62076)
-- Name: deliverablenotice; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.deliverablenotice (
    deliverablenoticeid integer DEFAULT nextval('common.deliverablenotice_deliverablenoticeid_seq'::regclass) NOT NULL,
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    noticeid integer NOT NULL,
    recipientid integer NOT NULL,
    contactid integer NOT NULL,
    datesent date NOT NULL,
    comment character varying
);


ALTER TABLE acp.deliverablenotice OWNER TO bradley;

--
-- TOC entry 6916 (class 0 OID 0)
-- Dependencies: 605
-- Name: TABLE deliverablenotice; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.deliverablenotice IS 'Tracks notices sent to deliverable contacts';


--
-- TOC entry 6917 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.deliverablenoticeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.deliverablenoticeid IS 'DELIVERABLENOTICE PK';


--
-- TOC entry 6918 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6919 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6920 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.noticeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.noticeid IS 'PK for NOTICE';


--
-- TOC entry 6921 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.recipientid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.recipientid IS 'The person that the notice was sent to.';


--
-- TOC entry 6922 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.contactid IS 'PERSON that sent the notice.';


--
-- TOC entry 6923 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.datesent; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.deliverablenotice.datesent IS 'Date that the notice was sent.';


--
-- TOC entry 606 (class 1259 OID 62083)
-- Name: modificationcontact; Type: TABLE; Schema: acp; Owner: pts_admin
--

CREATE TABLE acp.modificationcontact (
    modificationid integer NOT NULL,
    projectcontactid integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE acp.modificationcontact OWNER TO pts_admin;

--
-- TOC entry 6925 (class 0 OID 0)
-- Dependencies: 606
-- Name: TABLE modificationcontact; Type: COMMENT; Schema: acp; Owner: pts_admin
--

COMMENT ON TABLE acp.modificationcontact IS 'Associates project contacts with a modification';


--
-- TOC entry 6926 (class 0 OID 0)
-- Dependencies: 606
-- Name: COLUMN modificationcontact.modificationid; Type: COMMENT; Schema: acp; Owner: pts_admin
--

COMMENT ON COLUMN acp.modificationcontact.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6927 (class 0 OID 0)
-- Dependencies: 606
-- Name: COLUMN modificationcontact.projectcontactid; Type: COMMENT; Schema: acp; Owner: pts_admin
--

COMMENT ON COLUMN acp.modificationcontact.projectcontactid IS 'PK for PROJECTCONTACT';


--
-- TOC entry 6928 (class 0 OID 0)
-- Dependencies: 606
-- Name: COLUMN modificationcontact.priority; Type: COMMENT; Schema: acp; Owner: pts_admin
--

COMMENT ON COLUMN acp.modificationcontact.priority IS 'Priority of the contact';


--
-- TOC entry 607 (class 1259 OID 62086)
-- Name: deliverablereminder; Type: VIEW; Schema: acp; Owner: pts_admin
--

CREATE VIEW acp.deliverablereminder AS
 WITH modcontact AS (
         SELECT m.modificationid,
            pmc.projectid,
            pmc.contactid,
            pmc.roletypeid,
            pmc.priority,
            pmc.contactprojectcode,
            pmc.partner,
            pmc.projectcontactid,
            pmc.reminder
           FROM ((acp.modification m
             JOIN acp.modificationcontact mc USING (modificationid))
             JOIN acp.projectcontact pmc USING (projectcontactid))
        UNION
         SELECT m.modificationid,
            pc.projectid,
            pc.contactid,
            pc.roletypeid,
            pc.priority,
            pc.contactprojectcode,
            pc.partner,
            pc.projectcontactid,
            pc.reminder
           FROM (((acp.modification m
             LEFT JOIN acp.modificationcontact mc USING (modificationid))
             LEFT JOIN acp.projectcontact pmc USING (projectcontactid))
             JOIN acp.projectcontact pc ON (((m.projectid = pc.projectid) AND (mc.projectcontactid IS NULL))))
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    d.deliverabletypeid,
    status.deliverablestatusid,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.contactid
            WHEN (piemail.email IS NOT NULL) THEN projectcontact.contactid
            ELSE project.orgid
        END AS contactid,
    efd.effectivedate AS receiveddate,
    d.title,
    dt.type,
    d.description,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.name
            ELSE contactprimaryinfo.name
        END AS contact,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN (man.priemail)::text
            WHEN (piemail.email IS NOT NULL) THEN piemail.email
            ELSE (groupschema.email)::text
        END AS email,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN ccemail.email
            ELSE NULL::text
        END AS ccemail,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN adminemail.email
            ELSE NULL::text
        END AS adminemail,
    (((po.firstname)::text || ' '::text) || (po.lastname)::text) AS projectofficer,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM ((((((((((((((((acp.deliverable d
     JOIN acp.deliverablemod dm USING (deliverableid))
     JOIN cvl.deliverabletype dt USING (deliverabletypeid))
     JOIN acp.modification USING (modificationid))
     JOIN acp.project USING (projectid))
     JOIN ( SELECT projectcontact_1.modificationid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM modcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (modificationid))
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) OVER (PARTITION BY projectcontact_1.modificationid ORDER BY projectcontact_1.roletypeid DESC, projectcontact_1.priority ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS email
           FROM (modcontact projectcontact_1
             JOIN acp.contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[6, 7])))) piemail USING (modificationid))
     LEFT JOIN acp.contactprimaryinfo USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (modcontact projectcontact_1
             JOIN acp.contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (NOT (projectcontact_1.roletypeid = ANY (ARRAY[6, 7, 5, 13]))))
          GROUP BY projectcontact_1.modificationid) ccemail USING (modificationid))
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (modcontact projectcontact_1
             JOIN acp.contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[5, 13])))
          GROUP BY projectcontact_1.modificationid) adminemail USING (modificationid))
     LEFT JOIN acp.projectcontact poc ON (((poc.projectid = project.projectid) AND (poc.roletypeid = 12))))
     LEFT JOIN acp.person po ON ((poc.contactid = po.contactid)))
     LEFT JOIN acp.contactprimaryinfo man ON ((man.contactid = dm.personid)))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN common.groupschema ON (((project.orgid = groupschema.groupid) AND (NOT ((groupschema.groupschemaid)::text = 'acp'::text)) AND ((groupschema.groupschemaid)::name = ANY (current_schemas(false))))))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;


ALTER TABLE acp.deliverablereminder OWNER TO pts_admin;

--
-- TOC entry 608 (class 1259 OID 62091)
-- Name: deliverablestatuslist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.deliverablestatuslist AS
 SELECT d.title,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    COALESCE(status.deliverablestatusid, '-1'::integer) AS deliverablestatusid,
    d.deliverableid,
    dm.modificationid
   FROM ((acp.deliverable d
     JOIN acp.deliverablemod dm USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))));


ALTER TABLE acp.deliverablestatuslist OWNER TO bradley;

--
-- TOC entry 609 (class 1259 OID 62096)
-- Name: acpsteeringcommittee; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.acpsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM ((((((acp.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN acp.contactcontactgroup sc ON (((person.contactid = sc.contactid) AND (sc.groupid = 42) AND (sc.positionid = ANY (ARRAY[85, 96])))))
     JOIN cvl."position" ON ((sc.positionid = "position".positionid)))
  ORDER BY person.lastname;


ALTER TABLE acp.acpsteeringcommittee OWNER TO bradley;

--
-- TOC entry 610 (class 1259 OID 62101)
-- Name: fact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.fact (
    factid integer DEFAULT nextval('common.fact_factid_seq'::regclass) NOT NULL,
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


ALTER TABLE acp.fact OWNER TO bradley;

--
-- TOC entry 6933 (class 0 OID 0)
-- Dependencies: 610
-- Name: TABLE fact; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.fact IS 'Data primarily intended for project factsheet';


--
-- TOC entry 6934 (class 0 OID 0)
-- Dependencies: 610
-- Name: COLUMN fact.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fact.title IS 'Condensed title of project';


--
-- TOC entry 611 (class 1259 OID 62108)
-- Name: factfile; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.factfile (
    factid integer NOT NULL,
    fileid integer NOT NULL,
    priority smallint DEFAULT 1 NOT NULL,
    caption character varying
);


ALTER TABLE acp.factfile OWNER TO bradley;

--
-- TOC entry 6936 (class 0 OID 0)
-- Dependencies: 611
-- Name: TABLE factfile; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.factfile IS 'Associates logos and images with FACTsheets';


--
-- TOC entry 6937 (class 0 OID 0)
-- Dependencies: 611
-- Name: COLUMN factfile.fileid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.factfile.fileid IS 'PK for FILE';


--
-- TOC entry 6938 (class 0 OID 0)
-- Dependencies: 611
-- Name: COLUMN factfile.caption; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.factfile.caption IS 'Caption associated with document';


--
-- TOC entry 612 (class 1259 OID 62115)
-- Name: file; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.file (
    fileid integer NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    product boolean DEFAULT false NOT NULL
);


ALTER TABLE acp.file OWNER TO bradley;

--
-- TOC entry 6940 (class 0 OID 0)
-- Dependencies: 612
-- Name: TABLE file; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.file IS 'File';


--
-- TOC entry 6941 (class 0 OID 0)
-- Dependencies: 612
-- Name: COLUMN file.fileid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.file.fileid IS 'PK for FILE';


--
-- TOC entry 6942 (class 0 OID 0)
-- Dependencies: 612
-- Name: COLUMN file.name; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.file.name IS 'name of document';


--
-- TOC entry 6943 (class 0 OID 0)
-- Dependencies: 612
-- Name: COLUMN file.product; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.file.product IS 'Specifies whether document is a product.';


--
-- TOC entry 613 (class 1259 OID 62122)
-- Name: filecomment; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.filecomment (
    fileid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    datemodified date NOT NULL,
    filecommentid integer DEFAULT nextval('common.filecomment_filecommentid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.filecomment OWNER TO bradley;

--
-- TOC entry 6945 (class 0 OID 0)
-- Dependencies: 613
-- Name: COLUMN filecomment.fileid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.filecomment.fileid IS 'PK for DOCUMENT';


--
-- TOC entry 6946 (class 0 OID 0)
-- Dependencies: 613
-- Name: COLUMN filecomment.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.filecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 614 (class 1259 OID 62129)
-- Name: fileversion; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.fileversion (
    fileversionid integer DEFAULT nextval('common.fileversion_fileversionid_seq'::regclass) NOT NULL,
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


ALTER TABLE acp.fileversion OWNER TO bradley;

--
-- TOC entry 6948 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.fileid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fileversion.fileid IS 'PK for FILE';


--
-- TOC entry 6949 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fileversion.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6950 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fileversion.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6951 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.uri; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fileversion.uri IS 'Electronic address of document';


--
-- TOC entry 6952 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.current; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fileversion.current IS 'Identifies current document';


--
-- TOC entry 6953 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.uploadstamp; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fileversion.uploadstamp IS 'Timestamp document was uploaded';


--
-- TOC entry 615 (class 1259 OID 62136)
-- Name: fundingcomment; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.fundingcomment (
    fundingcommentid integer DEFAULT nextval('common.fundingcomment_fundingcommentid_seq'::regclass) NOT NULL,
    contactid integer NOT NULL,
    fundingid integer NOT NULL,
    datemodified date NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE acp.fundingcomment OWNER TO bradley;

--
-- TOC entry 6955 (class 0 OID 0)
-- Dependencies: 615
-- Name: COLUMN fundingcomment.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fundingcomment.contactid IS 'FK for PERSON';


--
-- TOC entry 6956 (class 0 OID 0)
-- Dependencies: 615
-- Name: COLUMN fundingcomment.fundingid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fundingcomment.fundingid IS 'FK for FUNDING';


--
-- TOC entry 6957 (class 0 OID 0)
-- Dependencies: 615
-- Name: COLUMN fundingcomment.datemodified; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.fundingcomment.datemodified IS 'Date that the comment was modified.';


--
-- TOC entry 616 (class 1259 OID 62143)
-- Name: fundingtotals; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.fundingtotals AS
 SELECT DISTINCT mod.fiscalyear,
    COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00)) AS total
   FROM (((( SELECT modification.modificationid,
            modification.projectid,
            modification.personid,
            modification.modtypeid,
            modification.title,
            modification.description,
            modification.modificationcode,
            modification.effectivedate,
            modification.startdate,
            modification.enddate,
            modification.datecreated,
            modification.parentmodificationid,
            modification.shorttitle,
            common.getfiscalyear(modification.startdate) AS fiscalyear
           FROM acp.modification) mod
     LEFT JOIN acp.funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(invoice_1.amount) AS amount
           FROM ((acp.invoice invoice_1
             JOIN acp.funding funding_1 USING (fundingid))
             JOIN acp.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY (common.getfiscalyear(modification_1.startdate))) invoice USING (fiscalyear))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(funding_1.amount) AS leveraged
           FROM (acp.funding funding_1
             JOIN acp.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))
          GROUP BY (common.getfiscalyear(modification_1.startdate))) leveraged USING (fiscalyear))
  ORDER BY mod.fiscalyear;


ALTER TABLE acp.fundingtotals OWNER TO bradley;

--
-- TOC entry 617 (class 1259 OID 62148)
-- Name: groupmemberlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.groupmemberlist AS
 SELECT ccg.groupid,
    ccg.contactid,
    ccg.positionid,
    ccg.contactcontactgroupid,
    concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
    ccg.priority
   FROM (acp.contactcontactgroup ccg
     JOIN acp.person USING (contactid));


ALTER TABLE acp.groupmemberlist OWNER TO bradley;

--
-- TOC entry 618 (class 1259 OID 62152)
-- Name: grouppersonfull; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.grouppersonfull AS
 WITH RECURSIVE grouptree AS (
         SELECT contactgroup.contactid AS groupid,
            (contactgroup.name)::text AS fullname,
            contactgroup.acronym,
            contactgroup.name,
            ARRAY[contactgroup.contactid] AS groupids
           FROM (acp.contactgroup
             LEFT JOIN acp.contactcontactgroup contactcontactgroup_1 USING (contactid))
          WHERE (contactcontactgroup_1.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            ((gt.fullname || ' -> '::text) || (cg.name)::text) AS full_name,
            cg.acronym,
            cg.name,
            array_append(gt.groupids, cg.contactid) AS array_append
           FROM ((acp.contactgroup cg
             JOIN acp.contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.groupid)))
        )
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    grouptree.groupid,
    grouptree.fullname AS groupfullname,
    grouptree.acronym,
    grouptree.name AS groupname,
    "position".code AS "position",
    contactcontactgroup.positionid,
    grouptree.groupids
   FROM (((grouptree
     JOIN acp.contactcontactgroup USING (groupid))
     JOIN cvl."position" USING (positionid))
     JOIN acp.person ON ((person.contactid = contactcontactgroup.contactid)));


ALTER TABLE acp.grouppersonfull OWNER TO bradley;

--
-- TOC entry 619 (class 1259 OID 62157)
-- Name: grouppersonlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.grouppersonlist AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    contactcontactgroup.groupid,
    contactgroup.acronym,
    contactgroup.name,
    contactcontactgroup.positionid,
    contact.inactive
   FROM (((acp.contactcontactgroup
     JOIN acp.contact USING (contactid))
     JOIN acp.contactgroup ON ((contactgroup.contactid = contactcontactgroup.groupid)))
     JOIN acp.person ON ((person.contactid = contactcontactgroup.contactid)));


ALTER TABLE acp.grouppersonlist OWNER TO bradley;

--
-- TOC entry 620 (class 1259 OID 62162)
-- Name: invoicecomment; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.invoicecomment (
    invoiceid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    invoicecommentid integer DEFAULT nextval('common.invoicecomment_invoicecommentid_seq'::regclass) NOT NULL,
    datemodified date NOT NULL
);


ALTER TABLE acp.invoicecomment OWNER TO bradley;

--
-- TOC entry 6963 (class 0 OID 0)
-- Dependencies: 620
-- Name: COLUMN invoicecomment.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.invoicecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 621 (class 1259 OID 62169)
-- Name: invoicelist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.invoicelist AS
 SELECT costcode.fundingid,
    i.invoiceid,
    i.projectcontactid,
    i.datereceived,
    i.title,
    i.dateclosed,
    i.amount
   FROM ((acp.invoice i
     JOIN acp.costcodeinvoice USING (invoiceid))
     JOIN acp.costcode USING (costcodeid));


ALTER TABLE acp.invoicelist OWNER TO bradley;

--
-- TOC entry 622 (class 1259 OID 62173)
-- Name: longprojectsummary; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.longprojectsummary AS
 SELECT DISTINCT project.projectid,
    project.orgid,
    project.projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators,
    project.shorttitle,
    project.abstract,
    project.description,
    project.status,
    project.allocated,
    project.invoiced,
    project.difference,
    project.leveraged,
    project.total
   FROM ((( SELECT DISTINCT project_1.projectid,
            project_1.orgid,
            common.form_projectcode((project_1.number)::integer, (project_1.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
            project_1.title,
            project_1.parentprojectid,
            project_1.fiscalyear,
            project_1.number,
            project_1.startdate,
            project_1.enddate,
            project_1.uuid,
            project_1.shorttitle,
            project_1.abstract,
            project_1.description,
            status.status,
            COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) AS allocated,
            COALESCE(invoice.amount, 0.00) AS invoiced,
            (COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
            COALESCE(leveraged.leveraged, 0.00) AS leveraged,
            (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00)) AS total
           FROM ((((((acp.project project_1
             LEFT JOIN acp.modification USING (projectid))
             LEFT JOIN acp.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
             LEFT JOIN ( SELECT modification_1.projectid,
                    sum(invoice_1.amount) AS amount
                   FROM ((acp.invoice invoice_1
                     JOIN acp.funding funding_1 USING (fundingid))
                     JOIN acp.modification modification_1 USING (modificationid))
                  WHERE (funding_1.fundingtypeid = 1)
                  GROUP BY modification_1.projectid) invoice USING (projectid))
             LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
                    sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
                   FROM (acp.funding funding_1
                     JOIN acp.modification modification_1 USING (modificationid))
                  WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
             JOIN cvl.status ON ((common.project_status(project_1.projectid) = status.statusid)))
             JOIN acp.contactgroup ON ((project_1.orgid = contactgroup.contactid)))) project
     LEFT JOIN ( SELECT projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.projectcontactid,
            row_number() OVER (PARTITION BY projectcontact.projectid, projectcontact.roletypeid ORDER BY projectcontact.priority) AS rank
           FROM acp.projectcontact) pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid,
                    contactgroup.organization,
                    contactgroup.name,
                    contactgroup.acronym,
                    contactcontactgroup.groupid,
                    (contactgroup.name)::text AS fullname,
                    NULL::text AS parentname,
                    ARRAY[contactgroup.contactid] AS contactids
                   FROM (acp.contactgroup
                     LEFT JOIN acp.contactcontactgroup USING (contactid))
                  WHERE (contactcontactgroup.groupid IS NULL)
                UNION ALL
                 SELECT ccg_1.contactid,
                    cg_1.organization,
                    cg_1.name,
                    cg_1.acronym,
                    gt.contactid,
                    (((gt.acronym)::text || ' -> '::text) || (cg_1.name)::text) AS full_name,
                    gt.name,
                    array_append(gt.contactids, cg_1.contactid) AS array_append
                   FROM ((acp.contactgroup cg_1
                     JOIN acp.contactcontactgroup ccg_1 USING (contactid))
                     JOIN grouptree gt ON ((ccg_1.groupid = gt.contactid)))
                )
         SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || cg.fullname), ''::text)) AS fullname
           FROM ((acp.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN grouptree cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE acp.longprojectsummary OWNER TO bradley;

--
-- TOC entry 623 (class 1259 OID 62178)
-- Name: membergrouplist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.membergrouplist AS
 SELECT ccg.groupid,
    ccg.contactid,
    ccg.positionid,
    ccg.contactcontactgroupid,
    contactgroup.name,
    ccg.priority
   FROM (acp.contactcontactgroup ccg
     JOIN acp.contactgroup ON ((ccg.groupid = contactgroup.contactid)))
  ORDER BY ccg.priority;


ALTER TABLE acp.membergrouplist OWNER TO bradley;

--
-- TOC entry 624 (class 1259 OID 62182)
-- Name: metadatacontact; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.metadatacontact AS
 SELECT c.contactid AS "contactId",
    c.name,
    c."isOrganization",
    c."positionName",
    c.uri,
    (((((('+'::text || (p.code)::text) || ' '::text) || p.areacode) || ' '::text) || p.phnumber) || COALESCE((' x'::text || p.extension), ''::text)) AS "officePhone",
    add.street1 AS "deliveryPoint1",
    add.street2 AS "deliveryPoint2",
    add.city,
    govunit.statename AS "administrativeArea",
    ((add.postalcode)::text || COALESCE(('-'::text || add.postal4), ''::text)) AS "postalCode",
    govunit.countryname AS country,
    e.uri AS email,
    c.uuid,
    c.parentuuid,
    c.allids,
    add.addresstype,
    c.contacttype
   FROM ((((( SELECT person.contactid,
            con.uuid,
            ccg.contactid AS parentgroupid,
            cg.uuid AS parentuuid,
            array_append(cl.contactids, person.contactid) AS allids,
            false AS "isOrganization",
            (((((person.firstname)::text || COALESCE((' '::text || (person.middlename)::text), ''::text)) || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || (person.suffix)::text), ''::text)) AS name,
            pos.code AS "positionName",
            web.uri,
            ct.adiwg AS contacttype
           FROM (((((((acp.person
             JOIN acp.contact con ON ((person.contactid = con.contactid)))
             JOIN cvl.contacttype ct USING (contacttypeid))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN acp.contactgrouplist cl ON ((cl.contactid = ccg.groupid)))
             LEFT JOIN acp.contact cg ON ((ccg.groupid = cg.contactid)))
             LEFT JOIN cvl."position" pos ON ((ccg.positionid = pos.positionid)))
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM acp.eaddress
                  WHERE (eaddress.eaddresstypeid = 2)
                  ORDER BY eaddress.priority) web ON ((web.contactid = ccg.groupid)))
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
           FROM (((((acp.contactgroup cg
             LEFT JOIN acp.contact con ON ((cg.contactid = con.contactid)))
             JOIN cvl.contacttype ct USING (contacttypeid))
             LEFT JOIN acp.contactgrouplist cl ON ((cl.contactid = cg.contactid)))
             LEFT JOIN acp.contact pg ON ((cl.parentgroupid = pg.contactid)))
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri
                   FROM acp.eaddress
                  WHERE (eaddress.eaddresstypeid = 2)
                  ORDER BY eaddress.priority) web ON ((web.contactid = cg.contactid)))) c
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
           FROM (acp.phone
             JOIN cvl.country USING (countryiso))
          WHERE (phone.phonetypeid = 3)) p ON (((c.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((c.contactid = e.contactid) AND (e.rank = 1))))
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
           FROM (acp.address
             JOIN cvl.addresstype USING (addresstypeid))) add ON (((c.contactid = add.contactid) AND (add.rank = 1))))
     LEFT JOIN cvl.govunit ON ((add.stateid = govunit.featureid)));


ALTER TABLE acp.metadatacontact OWNER TO bradley;

--
-- TOC entry 625 (class 1259 OID 62187)
-- Name: metadatafunding; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.metadatafunding AS
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
   FROM ((((((acp.funding f
     JOIN acp.modification m USING (modificationid))
     JOIN cvl.fundingtype ft USING (fundingtypeid))
     LEFT JOIN acp.projectcontact fun ON ((f.projectcontactid = fun.projectcontactid)))
     JOIN acp.contact fc ON ((fun.contactid = fc.contactid)))
     LEFT JOIN acp.projectcontact rec ON ((rec.projectcontactid = f.fundingrecipientid)))
     JOIN acp.contact rc ON ((rec.contactid = rc.contactid)));


ALTER TABLE acp.metadatafunding OWNER TO bradley;

--
-- TOC entry 626 (class 1259 OID 62192)
-- Name: product; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.product (
    productid integer DEFAULT nextval('common.product_productid_seq'::regclass) NOT NULL,
    projectid integer,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying(150) NOT NULL,
    description character varying(300) NOT NULL,
    abstract character varying NOT NULL,
    purpose character varying,
    startdate date,
    enddate date,
    exportmetadata boolean DEFAULT false NOT NULL,
    deliverabletypeid integer NOT NULL,
    isoprogresstypeid integer NOT NULL,
    metadataupdate timestamp with time zone,
    productgroupid integer,
    isgroup boolean DEFAULT false NOT NULL,
    uselimitation character varying,
    perioddescription character varying,
    maintenancefrequencyid integer,
    orgid integer NOT NULL,
    sciencebaseid character varying
);


ALTER TABLE acp.product OWNER TO bradley;

--
-- TOC entry 6970 (class 0 OID 0)
-- Dependencies: 626
-- Name: TABLE product; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.product IS 'A distributable product produced by a project.';


--
-- TOC entry 6971 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.productid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.productid IS 'PK for PRODUCT';


--
-- TOC entry 6972 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.uuid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.uuid IS 'Universally unique identifier for product';


--
-- TOC entry 6973 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.title IS 'Title of Product';


--
-- TOC entry 6974 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.description; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.description IS 'Short description of product';


--
-- TOC entry 6975 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.abstract; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.abstract IS 'Long description of product';


--
-- TOC entry 6976 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.purpose; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.purpose IS 'A summary of intentions for which the product was created.';


--
-- TOC entry 6977 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.startdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.startdate IS 'Start date for period of validity or relevance';


--
-- TOC entry 6978 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.enddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.enddate IS 'End date for period of validity or relevance';


--
-- TOC entry 6979 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.exportmetadata; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.exportmetadata IS 'Specifies whether product metadata should be exported.';


--
-- TOC entry 6980 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.metadataupdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.metadataupdate IS 'Date when metadata was last updated (published).';


--
-- TOC entry 6981 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.productgroupid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.productgroupid IS 'Identifies the group to which this product belongs.';


--
-- TOC entry 6982 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.isgroup; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.isgroup IS 'Identifies whether the item is a product group.';


--
-- TOC entry 6983 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.uselimitation; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.uselimitation IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';


--
-- TOC entry 6984 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.perioddescription; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.perioddescription IS 'Description of the time period';


--
-- TOC entry 6985 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.orgid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.orgid IS 'Identifies organization that owns the product';


--
-- TOC entry 6986 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.sciencebaseid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


--
-- TOC entry 627 (class 1259 OID 62202)
-- Name: productepsg; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productepsg (
    productid integer NOT NULL,
    srid integer NOT NULL
);


ALTER TABLE acp.productepsg OWNER TO bradley;

--
-- TOC entry 628 (class 1259 OID 62205)
-- Name: productkeyword; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productkeyword (
    productkeywordid integer DEFAULT nextval('common.productkeyword_productkeywordid_seq'::regclass) NOT NULL,
    keywordid uuid NOT NULL,
    productid integer NOT NULL
);


ALTER TABLE acp.productkeyword OWNER TO bradley;

--
-- TOC entry 6989 (class 0 OID 0)
-- Dependencies: 628
-- Name: TABLE productkeyword; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.productkeyword IS 'Identifies product GCMD concepts(keywords).';


--
-- TOC entry 6990 (class 0 OID 0)
-- Dependencies: 628
-- Name: COLUMN productkeyword.productkeywordid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productkeyword.productkeywordid IS 'PK for PRODUCTKEYWORD';


--
-- TOC entry 6991 (class 0 OID 0)
-- Dependencies: 628
-- Name: COLUMN productkeyword.keywordid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productkeyword.keywordid IS 'GCMD concept UUID';


--
-- TOC entry 6992 (class 0 OID 0)
-- Dependencies: 628
-- Name: COLUMN productkeyword.productid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productkeyword.productid IS 'PK for PRODUCT';


--
-- TOC entry 629 (class 1259 OID 62209)
-- Name: productline; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productline (
    productid integer NOT NULL,
    productlineid integer DEFAULT nextval('common.productline_productlineid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE acp.productline OWNER TO bradley;

--
-- TOC entry 630 (class 1259 OID 62219)
-- Name: productpoint; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productpoint (
    productid integer NOT NULL,
    productpointid integer DEFAULT nextval('common.productpoint_productpointid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE acp.productpoint OWNER TO bradley;

--
-- TOC entry 631 (class 1259 OID 62229)
-- Name: productpolygon; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productpolygon (
    productid integer NOT NULL,
    productpolygonid integer DEFAULT nextval('common.productpolygon_productpolygonid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE acp.productpolygon OWNER TO bradley;

--
-- TOC entry 632 (class 1259 OID 62239)
-- Name: productspatialformat; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productspatialformat (
    productid integer NOT NULL,
    spatialformatid integer NOT NULL
);


ALTER TABLE acp.productspatialformat OWNER TO bradley;

--
-- TOC entry 633 (class 1259 OID 62242)
-- Name: producttopiccategory; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.producttopiccategory (
    productid integer NOT NULL,
    topiccategoryid integer NOT NULL
);


ALTER TABLE acp.producttopiccategory OWNER TO bradley;

--
-- TOC entry 634 (class 1259 OID 62245)
-- Name: productwkt; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productwkt (
    productid integer NOT NULL,
    wkt character varying NOT NULL
);


ALTER TABLE acp.productwkt OWNER TO bradley;

--
-- TOC entry 635 (class 1259 OID 62251)
-- Name: metadataproduct; Type: VIEW; Schema: acp; Owner: pts_admin
--

CREATE VIEW acp.metadataproduct AS
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
    mf.codename AS frequency,
    product.sciencebaseid
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((acp.product
     LEFT JOIN acp.project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg((productkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM (acp.productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid))
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (acp.producttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((spatialformat.codename)::text, '|'::text) AS spatialformat
           FROM (acp.productspatialformat
             JOIN cvl.spatialformat USING (spatialformatid))
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, '|'::text) AS epsgcode
           FROM acp.productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '|'::text) AS wkt
           FROM acp.productwkt
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
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS name,
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            ('point-'::text || productpoint.productpointid) AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM acp.productpoint
                        UNION
                         SELECT productpolygon.productid,
                            ('polygon-'::text || productpolygon.productpolygonid) AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM acp.productpolygon
                        UNION
                         SELECT productline.productid,
                            ('line-'::text || productline.productlineid) AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM acp.productline) lg) f
          GROUP BY f.productid) fea USING (productid));


ALTER TABLE acp.metadataproduct OWNER TO pts_admin;

--
-- TOC entry 636 (class 1259 OID 62256)
-- Name: projectkeyword; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectkeyword (
    projectid integer NOT NULL,
    keywordid uuid NOT NULL,
    projectkeywordid integer DEFAULT nextval('common.projectkeyword_projectkeywordid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.projectkeyword OWNER TO bradley;

--
-- TOC entry 7001 (class 0 OID 0)
-- Dependencies: 636
-- Name: TABLE projectkeyword; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.projectkeyword IS 'Identify project GCMD concepts(keywords)';


--
-- TOC entry 7002 (class 0 OID 0)
-- Dependencies: 636
-- Name: COLUMN projectkeyword.keywordid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectkeyword.keywordid IS 'GCMD concept UUID';


SET default_with_oids = true;

--
-- TOC entry 637 (class 1259 OID 62260)
-- Name: projectline; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectline (
    projectid integer NOT NULL,
    projectlineid integer DEFAULT nextval('common.projectline_projectlineid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE acp.projectline OWNER TO bradley;

--
-- TOC entry 638 (class 1259 OID 62270)
-- Name: projectpoint; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectpoint (
    projectid integer NOT NULL,
    projectpointid integer DEFAULT nextval('common.projectpoint_projectpointid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE acp.projectpoint OWNER TO bradley;

--
-- TOC entry 639 (class 1259 OID 62280)
-- Name: projectpolygon; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectpolygon (
    projectid integer NOT NULL,
    projectpolygonid integer DEFAULT nextval('common.projectpolygon_projectpolygonid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE acp.projectpolygon OWNER TO bradley;

SET default_with_oids = false;

--
-- TOC entry 640 (class 1259 OID 62290)
-- Name: projectprojectcategory; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectprojectcategory (
    projectid integer NOT NULL,
    projectcategoryid integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE acp.projectprojectcategory OWNER TO bradley;

--
-- TOC entry 641 (class 1259 OID 62293)
-- Name: projecttopiccategory; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projecttopiccategory (
    projectid integer NOT NULL,
    topiccategoryid integer NOT NULL
);


ALTER TABLE acp.projecttopiccategory OWNER TO bradley;

--
-- TOC entry 642 (class 1259 OID 62296)
-- Name: projectusertype; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectusertype (
    projectid integer DEFAULT nextval('common.project_projectid_seq'::regclass) NOT NULL,
    usertypeid integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE acp.projectusertype OWNER TO bradley;

--
-- TOC entry 643 (class 1259 OID 62300)
-- Name: metadataproject; Type: VIEW; Schema: acp; Owner: pts_admin
--

CREATE VIEW acp.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
        )
 SELECT project.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM acp.modification m
          WHERE (m.projectid = project.projectid)
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    (((((((acp.project
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((status.statusid = common.project_status(project.projectid))))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((projectkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM (acp.projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((usertype.usertype)::text, '|'::text) AS usertype
           FROM (acp.projectusertype
             JOIN cvl.usertype USING (usertypeid))
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (acp.projecttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectcategory.category)::text, '|'::text) AS projectcategory
           FROM (acp.projectprojectcategory
             JOIN cvl.projectcategory USING (projectcategoryid))
          GROUP BY projectprojectcategory.projectid) pc USING (projectid))
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS name,
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            ('point-'::text || projectpoint.projectpointid) AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM acp.projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            ('polygon-'::text || projectpolygon.projectpolygonid) AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM acp.projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            ('line-'::text || projectline.projectlineid) AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM acp.projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid));


ALTER TABLE acp.metadataproject OWNER TO pts_admin;

--
-- TOC entry 644 (class 1259 OID 62305)
-- Name: modcomment; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.modcomment (
    modificationid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    datemodified date NOT NULL,
    modcommentid integer DEFAULT nextval('common.modcomment_modcommentid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.modcomment OWNER TO bradley;

--
-- TOC entry 7011 (class 0 OID 0)
-- Dependencies: 644
-- Name: COLUMN modcomment.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modcomment.modificationid IS 'FK for MODIFICATION';


--
-- TOC entry 7012 (class 0 OID 0)
-- Dependencies: 644
-- Name: COLUMN modcomment.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modcomment.contactid IS 'PK for PERSON';


--
-- TOC entry 7013 (class 0 OID 0)
-- Dependencies: 644
-- Name: COLUMN modcomment.publish; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modcomment.publish IS 'Indicates whether comment should be included with data exports or displayed in public documents';


--
-- TOC entry 645 (class 1259 OID 62313)
-- Name: modcontact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.modcontact (
    contactid integer NOT NULL,
    modificationid integer NOT NULL,
    modcontacttypeid integer NOT NULL,
    priority smallint NOT NULL
);


ALTER TABLE acp.modcontact OWNER TO bradley;

--
-- TOC entry 7015 (class 0 OID 0)
-- Dependencies: 645
-- Name: TABLE modcontact; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.modcontact IS 'Tracks contacts associated with modifications';


--
-- TOC entry 7016 (class 0 OID 0)
-- Dependencies: 645
-- Name: COLUMN modcontact.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modcontact.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 7017 (class 0 OID 0)
-- Dependencies: 645
-- Name: COLUMN modcontact.modcontacttypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.modcontact.modcontacttypeid IS 'Indicates type of contact(internal/external admin,contractor, etc.)';


--
-- TOC entry 646 (class 1259 OID 62316)
-- Name: moddocstatuslist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.moddocstatuslist AS
 SELECT moddocstatus.moddocstatustypeid,
    moddocstatus.moddocstatusid,
    moddocstatus.modificationid,
    moddocstatus.moddoctypeid,
    moddocstatus.contactid,
    moddocstatus.comment,
    moddocstatus.effectivedate,
    moddocstatustype.status,
    moddocstatustype.code,
    moddocstatustype.description,
    moddocstatustype.weight
   FROM (acp.moddocstatus
     JOIN cvl.moddocstatustype USING (moddocstatustypeid))
  ORDER BY moddocstatus.modificationid, moddocstatus.moddoctypeid, moddocstatus.effectivedate DESC, moddocstatustype.weight DESC;


ALTER TABLE acp.moddocstatuslist OWNER TO bradley;

--
-- TOC entry 647 (class 1259 OID 62320)
-- Name: modificationcontactlist; Type: VIEW; Schema: acp; Owner: pts_admin
--

CREATE VIEW acp.modificationcontactlist AS
 SELECT modification.modificationid,
    string_agg((q.projectcontactid)::text, ','::text) AS modificationcontact
   FROM (acp.modification
     LEFT JOIN ( SELECT modificationcontact.modificationid,
            modificationcontact.projectcontactid,
            modificationcontact.priority
           FROM acp.modificationcontact
          ORDER BY modificationcontact.modificationid, modificationcontact.priority) q USING (modificationid))
  GROUP BY modification.modificationid;


ALTER TABLE acp.modificationcontactlist OWNER TO pts_admin;

--
-- TOC entry 648 (class 1259 OID 62325)
-- Name: modificationlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.modificationlist AS
 SELECT m.modificationid,
    m.projectid,
    m.personid,
    m.modtypeid,
    m.title,
    m.description,
    m.modificationcode,
    m.effectivedate,
    m.startdate,
    m.enddate,
    m.datecreated,
    m.parentmodificationid,
    mt.type AS typetext,
    mt.code AS typecode,
    (EXISTS ( SELECT 1
           FROM acp.modification mod
          WHERE (m.modificationid = mod.parentmodificationid))) AS ismodified,
    p.modificationcode AS parentcode,
    m.shorttitle
   FROM ((acp.modification m
     JOIN cvl.modtype mt USING (modtypeid))
     LEFT JOIN acp.modification p ON ((p.modificationid = m.parentmodificationid)));


ALTER TABLE acp.modificationlist OWNER TO bradley;

--
-- TOC entry 649 (class 1259 OID 62330)
-- Name: modstatuslist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.modstatuslist AS
 SELECT modification.modificationid,
    modstatus.modstatusid,
    modstatus.statusid,
    modstatus.effectivedate,
    modstatus.comment,
    modstatus.weight
   FROM (acp.modification
     JOIN ( SELECT modstatus_1.modificationid,
            modstatus_1.statusid,
            modstatus_1.effectivedate,
            modstatus_1.modstatusid,
            modstatus_1.comment,
            status.weight
           FROM (acp.modstatus modstatus_1
             JOIN cvl.status USING (statusid))) modstatus USING (modificationid))
  ORDER BY modstatus.effectivedate DESC, modstatus.weight DESC;


ALTER TABLE acp.modstatuslist OWNER TO bradley;

--
-- TOC entry 7022 (class 0 OID 0)
-- Dependencies: 649
-- Name: VIEW modstatuslist; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON VIEW acp.modstatuslist IS 'Lists all statuses for each modification with status weight.';


--
-- TOC entry 650 (class 1259 OID 62335)
-- Name: noticesent; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.noticesent AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM acp.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    d.title,
    d.description,
    notice.code AS lastnotice,
    deliverablenotice.datesent,
    projectlist.projectcode,
    project.shorttitle AS project,
    (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact,
    personlist.priemail AS email,
    (((folist.firstname)::text || ' '::text) || (folist.lastname)::text) AS fofficer,
    folist.priemail AS foemail,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN (status.deliverablestatusid = 0) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
    COALESCE(status.status, 'Not Received'::character varying) AS status,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate
   FROM ((((((((((((acp.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN ( SELECT deliverablemod.modificationid,
            deliverablemod.deliverableid,
            deliverablemod.duedate,
            deliverablemod.receiveddate,
            deliverablemod.acpinterval,
            deliverablemod.publish,
            deliverablemod.restricted,
            deliverablemod.accessdescription,
            deliverablemod.parentmodificationid,
            deliverablemod.parentdeliverableid,
            deliverablemod.personid,
            deliverablemod.startdate,
            deliverablemod.enddate
           FROM acp.deliverablemod
          WHERE (NOT (EXISTS ( SELECT 1
                   FROM acp.deliverablemod dp
                  WHERE ((dp.modificationid = dp.parentmodificationid) AND (dp.deliverableid = dp.parentdeliverableid)))))) dm USING (deliverableid))
     JOIN acp.modification USING (modificationid))
     JOIN acp.projectlist USING (projectid))
     JOIN acp.project USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM acp.projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[7]))) projectcontact USING (projectid))
     LEFT JOIN acp.personlist USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM acp.projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = 5)
          ORDER BY projectcontact_1.priority) focontact USING (projectid))
     LEFT JOIN acp.personlist folist ON ((focontact.contactid = folist.contactid)))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN acp.deliverablenotice USING (deliverableid))
     LEFT JOIN cvl.notice USING (noticeid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT COALESCE((status.deliverablestatusid >= 10), false)) AND (
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN (status.deliverablestatusid = 0) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END > '-30'::integer) AND (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod d_1
          WHERE ((dm.modificationid = d_1.parentmodificationid) AND (dm.deliverableid = d_1.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;


ALTER TABLE acp.noticesent OWNER TO bradley;

--
-- TOC entry 651 (class 1259 OID 62340)
-- Name: onlineresource; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.onlineresource (
    onlineresourceid integer DEFAULT nextval('common.onlineresource_onlineresourceid_seq'::regclass) NOT NULL,
    onlinefunctionid integer NOT NULL,
    productid integer NOT NULL,
    uri character varying NOT NULL,
    title character varying NOT NULL,
    description character varying(300) NOT NULL
);


ALTER TABLE acp.onlineresource OWNER TO bradley;

--
-- TOC entry 7025 (class 0 OID 0)
-- Dependencies: 651
-- Name: TABLE onlineresource; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.onlineresource IS 'Information about accessing on-line resources and services. This may be a website, profile page, GitHub page, etc.';


--
-- TOC entry 7026 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.onlineresourceid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.onlineresource.onlineresourceid IS 'PK for ONLINERESOURCE';


--
-- TOC entry 7027 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.onlinefunctionid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.onlineresource.onlinefunctionid IS 'PK for ONLINEFUNCTION';


--
-- TOC entry 7028 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.productid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.onlineresource.productid IS 'PK for PRODUCT';


--
-- TOC entry 7029 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.uri; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.onlineresource.uri IS 'Location (address) for on-line access using a Uniform Resource Identifier, usually in the form of a Uniform Resource Locator (URL).';


--
-- TOC entry 7030 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.title; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.onlineresource.title IS 'Descriptive title for onlineresource.';


--
-- TOC entry 7031 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.description; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.onlineresource.description IS 'Short description of onlineresource';


--
-- TOC entry 652 (class 1259 OID 62347)
-- Name: personpositionlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.personpositionlist AS
 SELECT "position".positionid,
    "position".title,
    "position".code
   FROM cvl."position"
  WHERE ("position".positionid > 0);


ALTER TABLE acp.personpositionlist OWNER TO bradley;

--
-- TOC entry 653 (class 1259 OID 62351)
-- Name: postalcodelist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.postalcodelist AS
 SELECT postalcode.countryiso,
    postalcode.postalcode,
    postalcode.placename,
    postalcode.state,
    postalcode.statecode,
    postalcode.postalcodeid,
    govunit.featureid AS stateid
   FROM (cvl.postalcode
     JOIN cvl.govunit ON (((govunit.countryalpha = postalcode.countryiso) AND (govunit.statealpha = (postalcode.statecode)::bpchar) AND ((govunit.unittype)::text = 'STATE'::text))));


ALTER TABLE acp.postalcodelist OWNER TO bradley;

--
-- TOC entry 654 (class 1259 OID 62356)
-- Name: productcontact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productcontact (
    productid integer NOT NULL,
    contactid integer NOT NULL,
    isoroletypeid integer NOT NULL,
    productcontactid integer DEFAULT nextval('common.productcontact_productcontactid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.productcontact OWNER TO bradley;

--
-- TOC entry 7035 (class 0 OID 0)
-- Dependencies: 654
-- Name: TABLE productcontact; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.productcontact IS 'Identifies product contacts and roles';


--
-- TOC entry 7036 (class 0 OID 0)
-- Dependencies: 654
-- Name: COLUMN productcontact.isoroletypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productcontact.isoroletypeid IS 'PK for ISOROLETYPE';


--
-- TOC entry 7037 (class 0 OID 0)
-- Dependencies: 654
-- Name: COLUMN productcontact.productcontactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productcontact.productcontactid IS 'PK for PRODUCTCONTACT';


--
-- TOC entry 655 (class 1259 OID 62360)
-- Name: productallcontacts; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM (acp.metadatacontact
             JOIN acp.productcontact ON ((metadatacontact."contactId" = productcontact.contactid)))) dt(contactid, productid);


ALTER TABLE acp.productallcontacts OWNER TO bradley;

--
-- TOC entry 656 (class 1259 OID 62364)
-- Name: productcontactlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productcontactlist AS
 SELECT pc.productcontactid,
    pc.productid,
    pc.contactid,
    pc.isoroletypeid,
    pc.name,
    isoroletype.codename AS role
   FROM (( SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name
           FROM (acp.productcontact
             JOIN acp.person USING (contactid))
        UNION
         SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            contactgroup.name
           FROM (acp.productcontact
             JOIN acp.contactgroup USING (contactid))) pc
     JOIN cvl.isoroletype USING (isoroletypeid))
  ORDER BY isoroletype.code;


ALTER TABLE acp.productcontactlist OWNER TO bradley;

--
-- TOC entry 657 (class 1259 OID 62369)
-- Name: productfeature; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productfeature AS
 SELECT productpoint.productid,
    ('Point-'::text || productpoint.productpointid) AS id,
    productpoint.name,
    productpoint.comment,
    public.st_asgeojson(productpoint.the_geom, 8) AS geom
   FROM acp.productpoint
UNION
 SELECT productpolygon.productid,
    ('Polygon-'::text || productpolygon.productpolygonid) AS id,
    productpolygon.name,
    productpolygon.comment,
    public.st_asgeojson(productpolygon.the_geom, 8) AS geom
   FROM acp.productpolygon
UNION
 SELECT productline.productid,
    ('LineString-'::text || productline.productlineid) AS id,
    productline.name,
    productline.comment,
    public.st_asgeojson(productline.the_geom, 8) AS geom
   FROM acp.productline;


ALTER TABLE acp.productfeature OWNER TO bradley;

--
-- TOC entry 658 (class 1259 OID 62374)
-- Name: productgrouplist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productgrouplist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.isgroup,
    p.productgroupid
   FROM ((acp.product p
     LEFT JOIN acp.project USING (projectid))
     LEFT JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  WHERE p.isgroup;


ALTER TABLE acp.productgrouplist OWNER TO bradley;

--
-- TOC entry 659 (class 1259 OID 62379)
-- Name: productkeywordlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productkeywordlist AS
 SELECT productkeyword.keywordid,
    productkeyword.productid,
    productkeyword.productkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (acp.productkeyword
     JOIN gcmd.keyword USING (keywordid));


ALTER TABLE acp.productkeywordlist OWNER TO bradley;

--
-- TOC entry 660 (class 1259 OID 62383)
-- Name: productlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    p.maintenancefrequencyid,
    p.sciencebaseid
   FROM (((((acp.product p
     LEFT JOIN acp.project USING (projectid))
     LEFT JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN acp.product pg ON ((p.productgroupid = pg.productid)));


ALTER TABLE acp.productlist OWNER TO bradley;

--
-- TOC entry 661 (class 1259 OID 62388)
-- Name: productmetadata; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.productmetadata AS
 SELECT product.productid,
    tc.topiccategory,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt
   FROM ((((acp.product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM acp.producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((productspatialformat.spatialformatid)::text, ','::text) AS spatialformat
           FROM acp.productspatialformat
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, ','::text) AS epsgcode
           FROM acp.productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '
|
'::text) AS wkt
           FROM acp.productwkt
          GROUP BY productwkt.productid) wkt USING (productid));


ALTER TABLE acp.productmetadata OWNER TO bradley;

--
-- TOC entry 662 (class 1259 OID 62393)
-- Name: productstatus; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productstatus (
    productstatusid integer DEFAULT nextval('common.productstatus_productstatusid_seq'::regclass) NOT NULL,
    productid integer NOT NULL,
    datetypeid integer NOT NULL,
    contactid integer NOT NULL,
    effectivedate date NOT NULL,
    comment character varying
);


ALTER TABLE acp.productstatus OWNER TO bradley;

--
-- TOC entry 7046 (class 0 OID 0)
-- Dependencies: 662
-- Name: TABLE productstatus; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.productstatus IS 'Status of product';


--
-- TOC entry 7047 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.productstatusid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstatus.productstatusid IS 'PK for PRODUCTSTATUS';


--
-- TOC entry 7048 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.productid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstatus.productid IS 'PK for PRODUCT';


--
-- TOC entry 7049 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.datetypeid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstatus.datetypeid IS 'PK for DATETYPE';


--
-- TOC entry 7050 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.effectivedate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 663 (class 1259 OID 62400)
-- Name: productstep; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.productstep (
    productstepid integer DEFAULT nextval('common.productstep_productstepid_seq'::regclass) NOT NULL,
    productid integer NOT NULL,
    productcontactid integer NOT NULL,
    description character varying NOT NULL,
    rationale character varying,
    stepdate date NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


ALTER TABLE acp.productstep OWNER TO bradley;

--
-- TOC entry 7052 (class 0 OID 0)
-- Dependencies: 663
-- Name: TABLE productstep; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.productstep IS 'Identifies the steps taken when during processing of the product.';


--
-- TOC entry 7053 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.productid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstep.productid IS 'PK for PRODUCT';


--
-- TOC entry 7054 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.rationale; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstep.rationale IS 'Requirement or purpose for the process step.';


--
-- TOC entry 7055 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.stepdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';


--
-- TOC entry 7056 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.priority; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.productstep.priority IS 'Order of the step';


--
-- TOC entry 664 (class 1259 OID 62408)
-- Name: progress; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.progress (
    progressid integer DEFAULT nextval('common.progress_progressid_seq'::regclass) NOT NULL,
    deliverableid integer NOT NULL,
    percent integer NOT NULL,
    reportdate date NOT NULL,
    comment character varying
);


ALTER TABLE acp.progress OWNER TO bradley;

--
-- TOC entry 7058 (class 0 OID 0)
-- Dependencies: 664
-- Name: TABLE progress; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.progress IS 'Indicates progress toward delivery of deliverable';


--
-- TOC entry 7059 (class 0 OID 0)
-- Dependencies: 664
-- Name: COLUMN progress.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.progress.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 7060 (class 0 OID 0)
-- Dependencies: 664
-- Name: COLUMN progress.percent; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.progress.percent IS 'Percent of deliverable completed';


--
-- TOC entry 7061 (class 0 OID 0)
-- Dependencies: 664
-- Name: COLUMN progress.reportdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.progress.reportdate IS 'Date progress reported';


--
-- TOC entry 665 (class 1259 OID 62415)
-- Name: projectadmin; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectadmin AS
 SELECT DISTINCT ON (person.lastname, person.contactid) person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
        CASE
            WHEN (common.project_status(pc.projectid) = ANY (ARRAY[1, 2, 5])) THEN 'No'::text
            ELSE 'Yes'::text
        END AS active
   FROM (((((((acp.person
     JOIN acp.contact USING (contactid))
     JOIN acp.projectcontact pc ON ((person.contactid = pc.contactid)))
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM acp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM acp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN cvl.roletype USING (roletypeid))
  WHERE ((pc.roletypeid = ANY (ARRAY[7, 5, 13, 6])) AND (NOT contact.inactive))
  ORDER BY person.lastname, person.contactid;


ALTER TABLE acp.projectadmin OWNER TO bradley;

--
-- TOC entry 7063 (class 0 OID 0)
-- Dependencies: 665
-- Name: VIEW projectadmin; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON VIEW acp.projectadmin IS 'Contacts serving in an admin role for projects (i.e. Financial Officer, Primary Contact, Principal Investigator, Grants Admin).';


--
-- TOC entry 666 (class 1259 OID 62420)
-- Name: projectagreementnumbers; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectagreementnumbers AS
 SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    modification.modificationcode AS agreementnumber,
    modification.title AS agreementtitle,
    modification.startdate,
    modification.enddate
   FROM ((acp.project
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN acp.modification USING (projectid))
  WHERE ((modification.modificationcode IS NOT NULL) AND (modification.modtypeid <> ALL (ARRAY[4, 9, 10])))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE acp.projectagreementnumbers OWNER TO bradley;

--
-- TOC entry 667 (class 1259 OID 62425)
-- Name: projectallcontacts; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM (acp.metadatacontact
             JOIN acp.projectcontact ON ((metadatacontact."contactId" = projectcontact.contactid)))) dt(contactid, projectid);


ALTER TABLE acp.projectallcontacts OWNER TO bradley;

--
-- TOC entry 668 (class 1259 OID 62430)
-- Name: projectawardinfo; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectawardinfo AS
 SELECT common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (((pi.firstname)::text || ' '::text) || (pi.lastname)::text) AS piname,
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
    (((fc.firstname)::text || ' '::text) || (fc.lastname)::text) AS admincontact,
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
    fadd.countryiso AS admincountryiso,
    status.status,
    regexp_replace(array_to_string(ARRAY[pi.priemail, fc.priemail], ','::text, ''::text), ',$'::text, ''::text) AS allemail
   FROM (((((((((((((acp.project p
     LEFT JOIN acp.contactgroup ON ((p.orgid = contactgroup.contactid)))
     LEFT JOIN acp.modification USING (projectid))
     LEFT JOIN cvl.status ON ((status.statusid = common.project_status(p.projectid))))
     LEFT JOIN acp.funding USING (modificationid))
     LEFT JOIN acp.projectcontact pc USING (projectcontactid))
     LEFT JOIN acp.projectcontact rpc ON ((rpc.projectcontactid = funding.fundingrecipientid)))
     JOIN acp.contactgrouplist rpg ON ((rpc.contactid = rpg.contactid)))
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
           FROM ((((acp.projectcontact
             JOIN acp.personlist pl USING (contactid))
             JOIN acp.contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN acp.contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = 7)) pi ON (((p.projectid = pi.projectid) AND (pi.rank = 1) AND (rpg.contactids[1] = pi.contactids[1]))))
     LEFT JOIN acp.address add ON (((add.contactid = pi.contactid) AND (add.addresstypeid = 1))))
     LEFT JOIN cvl.govunit ON ((govunit.featureid = add.stateid)))
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
           FROM ((((acp.projectcontact
             JOIN acp.personlist pl USING (contactid))
             JOIN acp.contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN acp.contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = ANY (ARRAY[5, 13]))) fc ON (((p.projectid = fc.projectid) AND (fc.rank = 1) AND (rpg.contactids[1] = fc.contactids[1]))))
     LEFT JOIN acp.address fadd ON (((fadd.contactid = fc.contactid) AND (fadd.addresstypeid = 1))))
     LEFT JOIN cvl.govunit fg ON ((fg.featureid = fadd.stateid)))
  WHERE ((modification.parentmodificationid IS NULL) AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5])) AND (status.weight >= 30) AND (status.weight <= 60) AND (pc.contactid = p.orgid))
  ORDER BY (common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym));


ALTER TABLE acp.projectawardinfo OWNER TO bradley;

--
-- TOC entry 7067 (class 0 OID 0)
-- Dependencies: 668
-- Name: VIEW projectawardinfo; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON VIEW acp.projectawardinfo IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';


--
-- TOC entry 669 (class 1259 OID 62435)
-- Name: projectcatalog; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectcatalog AS
 WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (acp.contactgroup contactgroup_1
             LEFT JOIN acp.contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace((cg.name)::text, ','::text, ''::text) AS name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace((cg.name)::text, ','::text, ''::text)) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((acp.contactgroup cg
             JOIN acp.contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
        ), funds AS (
         SELECT modification.projectid,
            common.getfiscalyear(modification.startdate) AS fiscalyear,
            grouptree.fullname,
            projectcontact.contactid,
            sum(funding.amount) AS funds
           FROM (((acp.modification
             JOIN acp.funding USING (modificationid))
             JOIN acp.projectcontact USING (projectcontactid))
             JOIN grouptree USING (contactid))
          WHERE (NOT (funding.fundingtypeid = 4))
          GROUP BY modification.projectid, (common.getfiscalyear(modification.startdate)), grouptree.fullname, projectcontact.contactid
        ), cofund AS (
         SELECT projectcontact.projectid,
            grouptree.fullname,
            row_number() OVER (PARTITION BY projectcontact.projectid) AS rank
           FROM gschema gschema_1,
            (((acp.projectcontact
             JOIN acp.contactgroup contactgroup_1 USING (contactid))
             JOIN acp.contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid)) AND (contact.contacttypeid = 5))
          ORDER BY projectcontact.projectid, projectcontact.priority
        ), deltype AS (
         SELECT d.projectid,
            d.catalog,
            d.type,
            row_number() OVER (PARTITION BY d.projectid) AS rank
           FROM ( SELECT DISTINCT modification.projectid,
                    deliverabletype.catalog,
                        CASE
                            WHEN (deliverabletype.catalog IS NOT NULL) THEN NULL::character varying
                            ELSE deliverabletype.type
                        END AS type
                   FROM (((acp.deliverablemod
                     JOIN acp.deliverable USING (deliverableid))
                     JOIN cvl.deliverabletype USING (deliverabletypeid))
                     JOIN acp.modification USING (modificationid))
                  WHERE (((NOT deliverablemod.invalid) OR (NOT (EXISTS ( SELECT 1
                           FROM acp.deliverablemod dm
                          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))))) AND (deliverable.deliverabletypeid <> ALL (ARRAY[4, 6, 7, 13])))
                  ORDER BY modification.projectid, deliverabletype.catalog) d
        )
 SELECT DISTINCT replace((contactgroup.name)::text, ' Landscape Conservation Cooperative'::text, ''::text) AS lccname,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS id,
    project.title AS ptitle,
    project.description,
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((acp.projectcontact
             JOIN acp.contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (projectcontact.partner AND (projectcontact.projectid = project.projectid) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
    catalogprojectcategory.endusers,
    fy.fiscalyears,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 1))) AS cofundlcc1,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 2))) AS cofundlcc2,
    NULL::text AS scibaseq,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
          GROUP BY funds.projectid) AS matchfundall,
    matchfundby.matchfundby,
    NULL::text AS matchfundnote,
    catalogprojectcategory.category1,
    catalogprojectcategory.category2,
    catalogprojectcategory.category3,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 1))) AS deliver1,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 2))) AS deliver2,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 3))) AS deliver3,
    lower(subject.keywords) AS subject,
    ('arctic'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((acp.project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((acp.projectcontact pc_1
             JOIN acp.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 7))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM acp.eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pi USING (projectid))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((acp.projectcontact pc_1
             JOIN acp.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 6))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM acp.eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pc USING (projectid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN ( SELECT mod.projectid,
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
           FROM ( SELECT DISTINCT ON (modification.projectid, (common.getfiscalyear(modification.startdate))) modification.modificationid,
                    modification.projectid,
                    modification.personid,
                    modification.modtypeid,
                    modification.title,
                    modification.description,
                    modification.modificationcode,
                    modification.effectivedate,
                    modification.startdate,
                    modification.enddate,
                    modification.datecreated,
                    modification.parentmodificationid,
                    modification.shorttitle,
                    funding.fundingid,
                    funding.fundingtypeid,
                    funding.title,
                    funding.amount,
                    funding.projectcontactid,
                    funding.fundingrecipientid
                   FROM (acp.modification
                     JOIN acp.funding USING (modificationid))
                  WHERE (modification.startdate IS NOT NULL)) mod(modificationid, projectid, personid, modtypeid, title, description, modificationcode, effectivedate, startdate, enddate, datecreated, parentmodificationid, shorttitle, fundingid, fundingtypeid, title_1, amount, projectcontactid, fundingrecipientid)
          GROUP BY mod.projectid) fy ON ((fy.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg(((((funds.funds)::text || ','::text) || funds.fiscalyear) || ',USFWS'::text), '; '::text) AS lccfundby
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (acp.projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text), ','::text, ''::text) AS name,
            projectpolygon.projectid
           FROM acp.projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN acp.catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY (common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym));


ALTER TABLE acp.projectcatalog OWNER TO bradley;

--
-- TOC entry 670 (class 1259 OID 62440)
-- Name: projectcomment; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectcomment (
    projectid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    publish boolean NOT NULL,
    stamp timestamp with time zone DEFAULT now() NOT NULL,
    datemodified date NOT NULL,
    projectcommentid integer DEFAULT nextval('common.projectcomment_projectcommentid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.projectcomment OWNER TO bradley;

--
-- TOC entry 7070 (class 0 OID 0)
-- Dependencies: 670
-- Name: TABLE projectcomment; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.projectcomment IS 'Comments for Project';


--
-- TOC entry 7071 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.projectid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcomment.projectid IS 'FK for PROJECT';


--
-- TOC entry 7072 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.contactid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcomment.contactid IS 'PK for PERSON';


--
-- TOC entry 7073 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.publish; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcomment.publish IS 'Indicates whether comment should be included with data exports or displayed in public documents';


--
-- TOC entry 7074 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.stamp; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectcomment.stamp IS 'Timestamp of comment';


--
-- TOC entry 671 (class 1259 OID 62448)
-- Name: projectcontactfull; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectcontactfull AS
 SELECT pc.projectcontactid,
    pc.projectid,
    pc.contactid,
    pc.roletypeid,
    pc.priority,
    pc.contactprojectcode,
    pc.partner,
    pc.name,
    roletype.code AS role,
    pc.type,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    pc.contactids,
    pc.reminder
   FROM (((( SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
            'person'::text AS type,
            ARRAY[person.contactid] AS contactids
           FROM (acp.projectcontact
             JOIN acp.person USING (contactid))
        UNION
         SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            contactgrouplist.fullname,
            'group'::text AS type,
            contactgrouplist.contactids
           FROM (acp.projectcontact
             JOIN acp.contactgrouplist USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
     JOIN acp.project USING (projectid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY pc.priority;


ALTER TABLE acp.projectcontactfull OWNER TO bradley;

--
-- TOC entry 672 (class 1259 OID 62453)
-- Name: projectcontactlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectcontactlist AS
 SELECT pc.projectcontactid,
    pc.projectid,
    pc.contactid,
    pc.roletypeid,
    pc.priority,
    pc.contactprojectcode,
    pc.partner,
    pc.name,
    roletype.code AS role,
    pc.reminder
   FROM (( SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
            projectcontact.reminder
           FROM (acp.projectcontact
             JOIN acp.person USING (contactid))
        UNION
         SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            contactgroup.name,
            projectcontact.reminder
           FROM (acp.projectcontact
             JOIN acp.contactgroup USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
  ORDER BY pc.priority;


ALTER TABLE acp.projectcontactlist OWNER TO bradley;

--
-- TOC entry 673 (class 1259 OID 62458)
-- Name: projectfeature; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectfeature AS
 SELECT projectpoint.projectid,
    ('Point-'::text || projectpoint.projectpointid) AS id,
    projectpoint.name,
    projectpoint.comment,
    public.st_asgeojson(projectpoint.the_geom, 8) AS geom
   FROM acp.projectpoint
UNION
 SELECT projectpolygon.projectid,
    ('Polygon-'::text || projectpolygon.projectpolygonid) AS id,
    projectpolygon.name,
    projectpolygon.comment,
    public.st_asgeojson(projectpolygon.the_geom, 8) AS geom
   FROM acp.projectpolygon
UNION
 SELECT projectline.projectid,
    ('LineString-'::text || projectline.projectlineid) AS id,
    projectline.name,
    projectline.comment,
    public.st_asgeojson(projectline.the_geom, 8) AS geom
   FROM acp.projectline;


ALTER TABLE acp.projectfeature OWNER TO bradley;

--
-- TOC entry 674 (class 1259 OID 62463)
-- Name: projectfunderlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectfunderlist AS
 SELECT projectcontactlist.projectcontactid,
    projectcontactlist.projectid,
    projectcontactlist.contactid,
    projectcontactlist.roletypeid,
    projectcontactlist.priority,
    projectcontactlist.contactprojectcode,
    projectcontactlist.partner,
    projectcontactlist.name
   FROM acp.projectcontactlist
  WHERE (projectcontactlist.roletypeid = 4)
  ORDER BY projectcontactlist.name;


ALTER TABLE acp.projectfunderlist OWNER TO bradley;

--
-- TOC entry 675 (class 1259 OID 62467)
-- Name: projectfunding; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectfunding AS
 SELECT DISTINCT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.fiscalyear,
    project.number,
    project.title,
    project.shorttitle,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00)) AS total,
    status.status
   FROM ((((((acp.project
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN acp.modification USING (projectid))
     LEFT JOIN acp.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((acp.invoice invoice_1
             JOIN acp.funding funding_1 USING (fundingid))
             JOIN acp.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (acp.funding funding_1
             JOIN acp.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE acp.projectfunding OWNER TO bradley;

--
-- TOC entry 676 (class 1259 OID 62472)
-- Name: projectgnis; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectgnis (
    projectid integer NOT NULL,
    gnisid integer NOT NULL
);


ALTER TABLE acp.projectgnis OWNER TO bradley;

--
-- TOC entry 7081 (class 0 OID 0)
-- Dependencies: 676
-- Name: TABLE projectgnis; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.projectgnis IS 'Links GNIS to projects';


--
-- TOC entry 677 (class 1259 OID 62475)
-- Name: projectitis; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.projectitis (
    tsn integer NOT NULL,
    projectid integer NOT NULL
);


ALTER TABLE acp.projectitis OWNER TO bradley;

--
-- TOC entry 7083 (class 0 OID 0)
-- Dependencies: 677
-- Name: TABLE projectitis; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.projectitis IS 'Links taxonomic identifiers to projects';


--
-- TOC entry 7084 (class 0 OID 0)
-- Dependencies: 677
-- Name: COLUMN projectitis.tsn; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectitis.tsn IS 'FK for ITIS';


--
-- TOC entry 7085 (class 0 OID 0)
-- Dependencies: 677
-- Name: COLUMN projectitis.projectid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.projectitis.projectid IS 'PK for PROJECT';


--
-- TOC entry 678 (class 1259 OID 62478)
-- Name: projectkeywordlist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectkeywordlist AS
 SELECT projectkeyword.keywordid,
    projectkeyword.projectid,
    projectkeyword.projectkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (acp.projectkeyword
     JOIN gcmd.keyword USING (keywordid));


ALTER TABLE acp.projectkeywordlist OWNER TO bradley;

--
-- TOC entry 679 (class 1259 OID 62482)
-- Name: projectkeywords; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectkeywords AS
 SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    kw.keywords,
    kw.joined
   FROM ((acp.project
     JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, ', '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), ', '::text) AS joined
           FROM (acp.projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE acp.projectkeywords OWNER TO bradley;

--
-- TOC entry 680 (class 1259 OID 62487)
-- Name: projectmetadata; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.projectmetadata AS
 SELECT project.projectid,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory
   FROM (((acp.project
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((projectusertype.usertypeid)::text, ','::text) AS usertype
           FROM acp.projectusertype
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((projecttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM acp.projecttopiccategory
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectprojectcategory.projectcategoryid)::text, ','::text) AS projectcategory
           FROM acp.projectprojectcategory
          GROUP BY projectprojectcategory.projectid) pc USING (projectid));


ALTER TABLE acp.projectmetadata OWNER TO bradley;

--
-- TOC entry 681 (class 1259 OID 62492)
-- Name: purchaserequest; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.purchaserequest (
    purchaserequest character varying NOT NULL,
    modificationid integer NOT NULL,
    comment character varying,
    purchaserequestid integer DEFAULT nextval('common.purchaserequest_purchaserequestid_seq'::regclass) NOT NULL
);


ALTER TABLE acp.purchaserequest OWNER TO bradley;

--
-- TOC entry 7090 (class 0 OID 0)
-- Dependencies: 681
-- Name: TABLE purchaserequest; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.purchaserequest IS 'purchade requests associated with modification';


--
-- TOC entry 7091 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN purchaserequest.purchaserequest; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.purchaserequest.purchaserequest IS 'number of purchase request';


--
-- TOC entry 7092 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN purchaserequest.modificationid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.purchaserequest.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 682 (class 1259 OID 62499)
-- Name: reminder; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.reminder (
    reminderid integer DEFAULT nextval('common.reminder_reminderid_seq'::regclass) NOT NULL,
    deliverableid integer NOT NULL,
    senddate date NOT NULL,
    message character varying NOT NULL,
    sentdate date NOT NULL,
    dayinterval smallint NOT NULL
);


ALTER TABLE acp.reminder OWNER TO bradley;

--
-- TOC entry 7094 (class 0 OID 0)
-- Dependencies: 682
-- Name: TABLE reminder; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.reminder IS 'Tracks notifications to be sent with respect to deilverables';


--
-- TOC entry 7095 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.reminderid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.reminder.reminderid IS 'PK for REMINDER';


--
-- TOC entry 7096 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.deliverableid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.reminder.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 7097 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.senddate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.reminder.senddate IS 'The date to send the reminder';


--
-- TOC entry 7098 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.message; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.reminder.message IS 'Text to be sent as body of the reminder';


--
-- TOC entry 7099 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.sentdate; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.reminder.sentdate IS 'Date the reminder was actually sent';


--
-- TOC entry 7100 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.dayinterval; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.reminder.dayinterval IS 'Interval in days to repeat reminder';


--
-- TOC entry 683 (class 1259 OID 62506)
-- Name: remindercontact; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.remindercontact (
    reminderid integer NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE acp.remindercontact OWNER TO bradley;

--
-- TOC entry 7102 (class 0 OID 0)
-- Dependencies: 683
-- Name: TABLE remindercontact; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.remindercontact IS 'Contacts associated with a reminder';


--
-- TOC entry 7103 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN remindercontact.reminderid; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.remindercontact.reminderid IS 'PK for REMINDER';


--
-- TOC entry 684 (class 1259 OID 62509)
-- Name: shortprojectsummary; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.shortprojectsummary AS
 SELECT DISTINCT project.projectid,
    project.orgid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators,
    project.shorttitle,
    project.abstract,
    project.description,
    status.status
   FROM ((((acp.project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN acp.projectcontact pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || (cg.name)::text), ''::text)) AS fullname
           FROM ((acp.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM acp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN acp.contactgroup cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
     JOIN acp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE acp.shortprojectsummary OWNER TO bradley;

--
-- TOC entry 685 (class 1259 OID 62514)
-- Name: statelist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.statelist AS
 SELECT govunit.featureid AS stateid,
    govunit.unittype,
    govunit.statenumeric,
    govunit.statealpha,
    govunit.statename,
    govunit.countryalpha,
    govunit.countryname,
    govunit.featurename
   FROM cvl.govunit
  WHERE ((govunit.unittype)::text = 'STATE'::text)
  ORDER BY govunit.statename;


ALTER TABLE acp.statelist OWNER TO bradley;

--
-- TOC entry 686 (class 1259 OID 62518)
-- Name: statuslist; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.statuslist AS
 SELECT s.statusid,
    m.modtypeid,
    s.code,
    s.status,
    s.description,
    s.weight
   FROM (cvl.status s
     JOIN cvl.modtypestatus m USING (statusid));


ALTER TABLE acp.statuslist OWNER TO bradley;

--
-- TOC entry 687 (class 1259 OID 62522)
-- Name: task; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.task AS
 SELECT deliverablemod.duedate,
    deliverable.title,
    efd.effectivedate AS receiveddate,
    (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS assignee,
    deliverable.description,
    deliverablemod.deliverableid,
    person.contactid,
    modification.projectid,
    deliverablemod.modificationid,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - deliverablemod.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - deliverablemod.duedate)
        END AS dayspastdue,
        CASE
            WHEN ((status.code IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - deliverablemod.duedate) < 0)))) THEN status.code
            ELSE 'Not Started'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    projectlist.projectcode,
    projectlist.shorttitle
   FROM ((((((acp.deliverablemod
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            taskstatus.code,
            taskstatus.status,
            taskstatus.description,
            taskstatus.comment
           FROM (acp.deliverablemodstatus
             JOIN cvl.taskstatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (modificationid, deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (acp.deliverablemodstatus
             JOIN cvl.taskstatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (modificationid, deliverableid))
     JOIN acp.deliverable USING (deliverableid))
     JOIN acp.person ON ((deliverablemod.personid = person.contactid)))
     JOIN acp.modification USING (modificationid))
     JOIN acp.projectlist USING (projectid))
  WHERE ((deliverable.deliverabletypeid = ANY (ARRAY[4, 7])) AND (NOT (EXISTS ( SELECT 1
           FROM acp.deliverablemod dm
          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))))
  ORDER BY deliverablemod.duedate DESC;


ALTER TABLE acp.task OWNER TO bradley;

--
-- TOC entry 7108 (class 0 OID 0)
-- Dependencies: 687
-- Name: VIEW task; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON VIEW acp.task IS 'Lists all tasks that are not invalid or modified';


--
-- TOC entry 688 (class 1259 OID 62527)
-- Name: timeline; Type: TABLE; Schema: acp; Owner: bradley
--

CREATE TABLE acp.timeline (
    timelineid integer DEFAULT nextval('common.timeline_timelineid_seq'::regclass) NOT NULL,
    factid integer NOT NULL,
    description character varying NOT NULL,
    startdate date NOT NULL,
    enddate date
);


ALTER TABLE acp.timeline OWNER TO bradley;

--
-- TOC entry 7110 (class 0 OID 0)
-- Dependencies: 688
-- Name: TABLE timeline; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON TABLE acp.timeline IS 'Project timeline associated with factsheet';


--
-- TOC entry 7111 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN timeline.description; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON COLUMN acp.timeline.description IS 'Timeline entry';


--
-- TOC entry 689 (class 1259 OID 62534)
-- Name: userinfo; Type: VIEW; Schema: acp; Owner: bradley
--

CREATE VIEW acp.userinfo AS
 SELECT login.loginid,
    logingroupschema.contactid,
    groupschema.groupid,
    login.username,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    contactgroup.name AS groupname,
    contactgroup.acronym,
    groupschema.projecturiformat,
    groupschema.email AS groupemail,
    login.config
   FROM ((((common.login
     JOIN common.logingroupschema USING (loginid))
     JOIN common.groupschema USING (groupschemaid))
     JOIN acp.contactgroup ON ((groupschema.groupid = contactgroup.contactid)))
     JOIN acp.person ON ((logingroupschema.contactid = person.contactid)))
  WHERE ((logingroupschema.groupschemaid)::name = ANY (current_schemas(false)));


ALTER TABLE acp.userinfo OWNER TO bradley;

--
-- TOC entry 6023 (class 2606 OID 64674)
-- Name: address_contactid_addresstypeid_priority_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.address
    ADD CONSTRAINT address_contactid_addresstypeid_priority_key UNIQUE (contactid, addresstypeid, priority);


--
-- TOC entry 7114 (class 0 OID 0)
-- Dependencies: 6023
-- Name: CONSTRAINT address_contactid_addresstypeid_priority_key ON address; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON CONSTRAINT address_contactid_addresstypeid_priority_key ON acp.address IS 'Combination of addresstype and priority must be unique for each contact';


--
-- TOC entry 6072 (class 2606 OID 64676)
-- Name: audit_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.audit
    ADD CONSTRAINT audit_pk PRIMARY KEY (auditid);


--
-- TOC entry 6074 (class 2606 OID 64678)
-- Name: catalogprojectcategory_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.catalogprojectcategory
    ADD CONSTRAINT catalogprojectcategory_pkey PRIMARY KEY (projectid);


--
-- TOC entry 6076 (class 2606 OID 64680)
-- Name: chargecode_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcostcode
    ADD CONSTRAINT chargecode_pk PRIMARY KEY (costcode);


--
-- TOC entry 6030 (class 2606 OID 64682)
-- Name: contactcontactgroup_groupid_contactid_positionid_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcontactgroup
    ADD CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key UNIQUE (groupid, contactid, positionid);


--
-- TOC entry 7115 (class 0 OID 0)
-- Dependencies: 6030
-- Name: CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key ON contactcontactgroup; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key ON acp.contactcontactgroup IS 'Right now we are not allowing contacts to be assigned multiple positions within a group.';


--
-- TOC entry 6032 (class 2606 OID 64684)
-- Name: contactcontactgroup_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcontactgroup
    ADD CONSTRAINT contactcontactgroup_pk PRIMARY KEY (contactcontactgroupid);


--
-- TOC entry 6083 (class 2606 OID 64686)
-- Name: costcode_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.costcode
    ADD CONSTRAINT costcode_pk PRIMARY KEY (costcodeid);


--
-- TOC entry 6085 (class 2606 OID 64688)
-- Name: costcodeinvoice_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.costcodeinvoice
    ADD CONSTRAINT costcodeinvoice_pk PRIMARY KEY (costcodeinvoiceid);


--
-- TOC entry 6087 (class 2606 OID 64690)
-- Name: deliverable_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverable
    ADD CONSTRAINT deliverable_pk PRIMARY KEY (deliverableid);


--
-- TOC entry 6091 (class 2606 OID 64692)
-- Name: deliverablecomment_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecomment
    ADD CONSTRAINT deliverablecomment_pkey PRIMARY KEY (deliverablecommentid);


--
-- TOC entry 6093 (class 2606 OID 64694)
-- Name: deliverablecontact_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecontact
    ADD CONSTRAINT deliverablecontact_pk PRIMARY KEY (deliverableid, contactid);


--
-- TOC entry 6047 (class 2606 OID 64696)
-- Name: deliverablemod_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemod
    ADD CONSTRAINT deliverablemod_pk PRIMARY KEY (modificationid, deliverableid);


--
-- TOC entry 6089 (class 2606 OID 64698)
-- Name: deliverablemodstatus_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemodstatus
    ADD CONSTRAINT deliverablemodstatus_pk PRIMARY KEY (deliverablemodstatusid);


--
-- TOC entry 6095 (class 2606 OID 64700)
-- Name: deliverablenotice_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablenotice
    ADD CONSTRAINT deliverablenotice_pk PRIMARY KEY (deliverablenoticeid);


--
-- TOC entry 6036 (class 2606 OID 64702)
-- Name: electadd_contactid_electaddtypeid_priority_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.eaddress
    ADD CONSTRAINT electadd_contactid_electaddtypeid_priority_key UNIQUE (contactid, eaddresstypeid, priority);


--
-- TOC entry 7116 (class 0 OID 0)
-- Dependencies: 6036
-- Name: CONSTRAINT electadd_contactid_electaddtypeid_priority_key ON eaddress; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON CONSTRAINT electadd_contactid_electaddtypeid_priority_key ON acp.eaddress IS 'Combination of electaddtype and priority must be unique for each contact';


--
-- TOC entry 6038 (class 2606 OID 64704)
-- Name: electadd_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.eaddress
    ADD CONSTRAINT electadd_pkey PRIMARY KEY (eaddressid);


--
-- TOC entry 6100 (class 2606 OID 64706)
-- Name: fact_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fact
    ADD CONSTRAINT fact_pk PRIMARY KEY (factid);


--
-- TOC entry 6102 (class 2606 OID 64708)
-- Name: factfile_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.factfile
    ADD CONSTRAINT factfile_pk PRIMARY KEY (factid, fileid);


--
-- TOC entry 6104 (class 2606 OID 64710)
-- Name: file_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.file
    ADD CONSTRAINT file_pk PRIMARY KEY (fileid);


--
-- TOC entry 6106 (class 2606 OID 64712)
-- Name: filecomment_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.filecomment
    ADD CONSTRAINT filecomment_pkey PRIMARY KEY (filecommentid);


--
-- TOC entry 6111 (class 2606 OID 64714)
-- Name: fileversion_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT fileversion_pk PRIMARY KEY (fileversionid);


--
-- TOC entry 6051 (class 2606 OID 64716)
-- Name: funding_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.funding
    ADD CONSTRAINT funding_pk PRIMARY KEY (fundingid);


--
-- TOC entry 6115 (class 2606 OID 64718)
-- Name: fundingcomment_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fundingcomment
    ADD CONSTRAINT fundingcomment_pk PRIMARY KEY (fundingcommentid);


--
-- TOC entry 6053 (class 2606 OID 64720)
-- Name: invoice_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.invoice
    ADD CONSTRAINT invoice_pk PRIMARY KEY (invoiceid);


--
-- TOC entry 6117 (class 2606 OID 64722)
-- Name: invoicecomment_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.invoicecomment
    ADD CONSTRAINT invoicecomment_pkey PRIMARY KEY (invoicecommentid);


--
-- TOC entry 6155 (class 2606 OID 64724)
-- Name: modcomment_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcomment
    ADD CONSTRAINT modcomment_pkey PRIMARY KEY (modcommentid);


--
-- TOC entry 6157 (class 2606 OID 64726)
-- Name: modcontact_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcontact
    ADD CONSTRAINT modcontact_pk PRIMARY KEY (contactid, modificationid);


--
-- TOC entry 6055 (class 2606 OID 64728)
-- Name: moddocstatus_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.moddocstatus
    ADD CONSTRAINT moddocstatus_pk PRIMARY KEY (moddocstatusid);


--
-- TOC entry 6058 (class 2606 OID 64730)
-- Name: modification_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modification
    ADD CONSTRAINT modification_pk PRIMARY KEY (modificationid);


--
-- TOC entry 6098 (class 2606 OID 64732)
-- Name: modificationcontact_pk; Type: CONSTRAINT; Schema: acp; Owner: pts_admin
--

ALTER TABLE ONLY acp.modificationcontact
    ADD CONSTRAINT modificationcontact_pk PRIMARY KEY (modificationid, projectcontactid);


--
-- TOC entry 6061 (class 2606 OID 64734)
-- Name: modstatus_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modstatus
    ADD CONSTRAINT modstatus_pk PRIMARY KEY (modstatusid);


--
-- TOC entry 6159 (class 2606 OID 64736)
-- Name: onlineresourceid_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.onlineresource
    ADD CONSTRAINT onlineresourceid_pk PRIMARY KEY (onlineresourceid);


--
-- TOC entry 6040 (class 2606 OID 64738)
-- Name: personid_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.person
    ADD CONSTRAINT personid_pk PRIMARY KEY (contactid);


--
-- TOC entry 6043 (class 2606 OID 64740)
-- Name: phone_contactid_phonetypeid_priority_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.phone
    ADD CONSTRAINT phone_contactid_phonetypeid_priority_key UNIQUE (contactid, phonetypeid, priority);


--
-- TOC entry 7117 (class 0 OID 0)
-- Dependencies: 6043
-- Name: CONSTRAINT phone_contactid_phonetypeid_priority_key ON phone; Type: COMMENT; Schema: acp; Owner: bradley
--

COMMENT ON CONSTRAINT phone_contactid_phonetypeid_priority_key ON acp.phone IS 'Combination of phonetype and priority must be unique for each contact';


--
-- TOC entry 6045 (class 2606 OID 64742)
-- Name: phone_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.phone
    ADD CONSTRAINT phone_pk PRIMARY KEY (phoneid);


--
-- TOC entry 6026 (class 2606 OID 64744)
-- Name: pk_address; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.address
    ADD CONSTRAINT pk_address PRIMARY KEY (addressid);


--
-- TOC entry 6028 (class 2606 OID 64746)
-- Name: pk_contact; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contact
    ADD CONSTRAINT pk_contact PRIMARY KEY (contactid);


--
-- TOC entry 6034 (class 2606 OID 64748)
-- Name: pk_unit; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactgroup
    ADD CONSTRAINT pk_unit PRIMARY KEY (contactid);


--
-- TOC entry 6121 (class 2606 OID 64750)
-- Name: product_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT product_pk PRIMARY KEY (productid);


--
-- TOC entry 6123 (class 2606 OID 64752)
-- Name: product_sciencebaseid_uidx; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);


--
-- TOC entry 6162 (class 2606 OID 64754)
-- Name: productcontact_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productcontact
    ADD CONSTRAINT productcontact_pk PRIMARY KEY (productcontactid);


--
-- TOC entry 6164 (class 2606 OID 64756)
-- Name: productcontact_productid_roletypeid_contactid_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productcontact
    ADD CONSTRAINT productcontact_productid_roletypeid_contactid_key UNIQUE (productid, isoroletypeid, contactid);


--
-- TOC entry 6125 (class 2606 OID 64758)
-- Name: productepsg_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productepsg
    ADD CONSTRAINT productepsg_pk PRIMARY KEY (productid, srid);


--
-- TOC entry 6127 (class 2606 OID 64760)
-- Name: productkeyword_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productkeyword
    ADD CONSTRAINT productkeyword_pk PRIMARY KEY (productkeywordid);


--
-- TOC entry 6129 (class 2606 OID 64762)
-- Name: productline_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productline
    ADD CONSTRAINT productline_pk PRIMARY KEY (productlineid);


--
-- TOC entry 6131 (class 2606 OID 64764)
-- Name: productpoint_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productpoint
    ADD CONSTRAINT productpoint_pk PRIMARY KEY (productpointid);


--
-- TOC entry 6133 (class 2606 OID 64766)
-- Name: productpolygon_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productpolygon
    ADD CONSTRAINT productpolygon_pk PRIMARY KEY (productpolygonid);


--
-- TOC entry 6135 (class 2606 OID 64768)
-- Name: productspatialformat_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productspatialformat
    ADD CONSTRAINT productspatialformat_pk PRIMARY KEY (productid, spatialformatid);


--
-- TOC entry 6166 (class 2606 OID 64770)
-- Name: productstatus_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productstatus
    ADD CONSTRAINT productstatus_pk PRIMARY KEY (productstatusid);


--
-- TOC entry 6168 (class 2606 OID 64772)
-- Name: productstep_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productstep
    ADD CONSTRAINT productstep_pk PRIMARY KEY (productstepid);


--
-- TOC entry 6137 (class 2606 OID 64774)
-- Name: producttopiccategory_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.producttopiccategory
    ADD CONSTRAINT producttopiccategory_pk PRIMARY KEY (productid, topiccategoryid);


--
-- TOC entry 6170 (class 2606 OID 64776)
-- Name: progress_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.progress
    ADD CONSTRAINT progress_pkey PRIMARY KEY (progressid);


--
-- TOC entry 6064 (class 2606 OID 64778)
-- Name: project_orgid_fiscalyear_number_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.project
    ADD CONSTRAINT project_orgid_fiscalyear_number_key UNIQUE (orgid, fiscalyear, number);


--
-- TOC entry 6066 (class 2606 OID 64780)
-- Name: project_sciencebaseid_uidx; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.project
    ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


--
-- TOC entry 6172 (class 2606 OID 64782)
-- Name: projectcomment_pkey; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcomment
    ADD CONSTRAINT projectcomment_pkey PRIMARY KEY (projectcommentid);


--
-- TOC entry 6139 (class 2606 OID 64784)
-- Name: projectconcept_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectkeyword
    ADD CONSTRAINT projectconcept_pk PRIMARY KEY (projectkeywordid);


--
-- TOC entry 6079 (class 2606 OID 64786)
-- Name: projectcontact_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcontact
    ADD CONSTRAINT projectcontact_pk PRIMARY KEY (projectcontactid);


--
-- TOC entry 6081 (class 2606 OID 64788)
-- Name: projectcontact_projectid_roletypeid_contactid_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcontact
    ADD CONSTRAINT projectcontact_projectid_roletypeid_contactid_key UNIQUE (projectid, roletypeid, contactid);


--
-- TOC entry 6174 (class 2606 OID 64790)
-- Name: projectgnis_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectgnis
    ADD CONSTRAINT projectgnis_pk PRIMARY KEY (projectid);


--
-- TOC entry 6069 (class 2606 OID 64792)
-- Name: projectid; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.project
    ADD CONSTRAINT projectid PRIMARY KEY (projectid);


--
-- TOC entry 6176 (class 2606 OID 64794)
-- Name: projectitis_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectitis
    ADD CONSTRAINT projectitis_pk PRIMARY KEY (tsn, projectid);


--
-- TOC entry 6141 (class 2606 OID 64796)
-- Name: projectkeyword_conceptid_projectid_key; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectkeyword
    ADD CONSTRAINT projectkeyword_conceptid_projectid_key UNIQUE (keywordid, projectid);


--
-- TOC entry 6143 (class 2606 OID 64798)
-- Name: projectline_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectline
    ADD CONSTRAINT projectline_pk PRIMARY KEY (projectlineid);


--
-- TOC entry 6145 (class 2606 OID 64800)
-- Name: projectpoint_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectpoint
    ADD CONSTRAINT projectpoint_pk PRIMARY KEY (projectpointid);


--
-- TOC entry 6147 (class 2606 OID 64802)
-- Name: projectpolygon_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectpolygon
    ADD CONSTRAINT projectpolygon_pk PRIMARY KEY (projectpolygonid);


--
-- TOC entry 6149 (class 2606 OID 64804)
-- Name: projectprojectcategory_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectprojectcategory
    ADD CONSTRAINT projectprojectcategory_pk PRIMARY KEY (projectid, projectcategoryid);


--
-- TOC entry 6151 (class 2606 OID 64806)
-- Name: projecttopiccategory_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projecttopiccategory
    ADD CONSTRAINT projecttopiccategory_pk PRIMARY KEY (projectid, topiccategoryid);


--
-- TOC entry 6153 (class 2606 OID 64808)
-- Name: projectusertype_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectusertype
    ADD CONSTRAINT projectusertype_pk PRIMARY KEY (projectid, usertypeid);


--
-- TOC entry 6178 (class 2606 OID 64810)
-- Name: purchaserequest_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.purchaserequest
    ADD CONSTRAINT purchaserequest_pk PRIMARY KEY (purchaserequestid);


--
-- TOC entry 6180 (class 2606 OID 64812)
-- Name: reminder_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.reminder
    ADD CONSTRAINT reminder_pk PRIMARY KEY (reminderid);


--
-- TOC entry 6182 (class 2606 OID 64814)
-- Name: remindercontact_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.remindercontact
    ADD CONSTRAINT remindercontact_pk PRIMARY KEY (reminderid, contactid);


--
-- TOC entry 6184 (class 2606 OID 64816)
-- Name: timeline_pk; Type: CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.timeline
    ADD CONSTRAINT timeline_pk PRIMARY KEY (timelineid);


--
-- TOC entry 6107 (class 1259 OID 65155)
-- Name: fileversion_deliverable_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_deliverable_idx ON acp.fileversion USING btree (fileid, deliverableid);


--
-- TOC entry 6108 (class 1259 OID 65156)
-- Name: fileversion_invoice_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_invoice_idx ON acp.fileversion USING btree (fileid, invoiceid);


--
-- TOC entry 6109 (class 1259 OID 65157)
-- Name: fileversion_modification_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_modification_idx ON acp.fileversion USING btree (fileid, modificationid);


--
-- TOC entry 6112 (class 1259 OID 65158)
-- Name: fileversion_progress_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_progress_idx ON acp.fileversion USING btree (fileid, progressid);


--
-- TOC entry 6113 (class 1259 OID 65159)
-- Name: fileversion_project_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_project_idx ON acp.fileversion USING btree (fileid, projectid);


--
-- TOC entry 6062 (class 1259 OID 65160)
-- Name: fki_contactgroup_project_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_contactgroup_project_fk ON acp.project USING btree (orgid);


--
-- TOC entry 6041 (class 1259 OID 65161)
-- Name: fki_country_phone_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_country_phone_fk ON acp.phone USING btree (countryiso);


--
-- TOC entry 6048 (class 1259 OID 65162)
-- Name: fki_deliverable_deliverablemod_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_deliverable_deliverablemod_fk ON acp.deliverablemod USING btree (deliverableid);


--
-- TOC entry 6049 (class 1259 OID 65163)
-- Name: fki_deliverablemod_deliverablemod_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_deliverablemod_deliverablemod_fk ON acp.deliverablemod USING btree (parentmodificationid, parentdeliverableid);


--
-- TOC entry 6024 (class 1259 OID 65164)
-- Name: fki_govunit_address_state_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_govunit_address_state_fk ON acp.address USING btree (stateid);


--
-- TOC entry 6160 (class 1259 OID 65165)
-- Name: fki_isoroletype_productcontact_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_isoroletype_productcontact_fk ON acp.productcontact USING btree (isoroletypeid);


--
-- TOC entry 6118 (class 1259 OID 65166)
-- Name: fki_maintenancefrequency_product_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_maintenancefrequency_product_fk ON acp.product USING btree (maintenancefrequencyid);


--
-- TOC entry 6096 (class 1259 OID 65167)
-- Name: fki_person_deliverablenotice_user_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_person_deliverablenotice_user_fk ON acp.deliverablenotice USING btree (recipientid);


--
-- TOC entry 6119 (class 1259 OID 65168)
-- Name: fki_productgroup_product_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_productgroup_product_fk ON acp.product USING btree (productgroupid);


--
-- TOC entry 6056 (class 1259 OID 65169)
-- Name: fki_project_modification_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_project_modification_fk ON acp.modification USING btree (projectid);


--
-- TOC entry 6077 (class 1259 OID 65170)
-- Name: fki_roletype_projectcontact_fk; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE INDEX fki_roletype_projectcontact_fk ON acp.projectcontact USING btree (roletypeid);


--
-- TOC entry 6059 (class 1259 OID 65171)
-- Name: modstatus_modificationid_statusid_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX modstatus_modificationid_statusid_idx ON acp.modstatus USING btree (modificationid, statusid, effectivedate);


--
-- TOC entry 6067 (class 1259 OID 65172)
-- Name: projectcode_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX projectcode_idx ON acp.project USING btree (fiscalyear, number, orgid);


--
-- TOC entry 6070 (class 1259 OID 65173)
-- Name: uuid_idx; Type: INDEX; Schema: acp; Owner: bradley
--

CREATE UNIQUE INDEX uuid_idx ON acp.project USING btree (uuid);


--
-- TOC entry 6316 (class 2620 OID 65223)
-- Name: delete_deliverablemod; Type: TRIGGER; Schema: acp; Owner: bradley
--

CREATE TRIGGER delete_deliverablemod AFTER DELETE ON acp.deliverablemod FOR EACH ROW EXECUTE PROCEDURE common.delete_deliverable();


--
-- TOC entry 6198 (class 2606 OID 66571)
-- Name: address_phone_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.phone
    ADD CONSTRAINT address_phone_fk FOREIGN KEY (addressid) REFERENCES acp.address(addressid);


--
-- TOC entry 6185 (class 2606 OID 66576)
-- Name: addresstype_address_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.address
    ADD CONSTRAINT addresstype_address_fk FOREIGN KEY (addresstypeid) REFERENCES cvl.addresstype(addresstypeid);


--
-- TOC entry 6281 (class 2606 OID 66581)
-- Name: concept_projectconcept_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectkeyword
    ADD CONSTRAINT concept_projectconcept_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);


--
-- TOC entry 6186 (class 2606 OID 66586)
-- Name: contact_address_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.address
    ADD CONSTRAINT contact_address_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6224 (class 2606 OID 66591)
-- Name: contact_contactcostcode_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcostcode
    ADD CONSTRAINT contact_contactcostcode_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6193 (class 2606 OID 66596)
-- Name: contact_contactgroup_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactgroup
    ADD CONSTRAINT contact_contactgroup_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6190 (class 2606 OID 66601)
-- Name: contact_contactunit_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcontactgroup
    ADD CONSTRAINT contact_contactunit_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6237 (class 2606 OID 66606)
-- Name: contact_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecontact
    ADD CONSTRAINT contact_deliverablecontact_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6240 (class 2606 OID 66611)
-- Name: contact_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablenotice
    ADD CONSTRAINT contact_deliverablenotice_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid);


--
-- TOC entry 6194 (class 2606 OID 66616)
-- Name: contact_electadd_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.eaddress
    ADD CONSTRAINT contact_electadd_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6294 (class 2606 OID 66621)
-- Name: contact_modcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcontact
    ADD CONSTRAINT contact_modcontact_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6196 (class 2606 OID 66626)
-- Name: contact_person_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.person
    ADD CONSTRAINT contact_person_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6199 (class 2606 OID 66631)
-- Name: contact_phone_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.phone
    ADD CONSTRAINT contact_phone_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6299 (class 2606 OID 66636)
-- Name: contact_productcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productcontact
    ADD CONSTRAINT contact_productcontact_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6225 (class 2606 OID 66641)
-- Name: contact_projectcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcontact
    ADD CONSTRAINT contact_projectcontact_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6313 (class 2606 OID 66646)
-- Name: contact_remindercontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.remindercontact
    ADD CONSTRAINT contact_remindercontact_fk FOREIGN KEY (contactid) REFERENCES acp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6191 (class 2606 OID 66651)
-- Name: contactgroup_contactunit_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcontactgroup
    ADD CONSTRAINT contactgroup_contactunit_fk FOREIGN KEY (groupid) REFERENCES acp.contactgroup(contactid);


--
-- TOC entry 6251 (class 2606 OID 66656)
-- Name: contactgroup_fileversion_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT contactgroup_fileversion_fk FOREIGN KEY (contactid) REFERENCES acp.contactgroup(contactid);


--
-- TOC entry 6221 (class 2606 OID 66661)
-- Name: contactgroup_project_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.project
    ADD CONSTRAINT contactgroup_project_fk FOREIGN KEY (orgid) REFERENCES acp.contactgroup(contactid);


--
-- TOC entry 6189 (class 2606 OID 66666)
-- Name: contacttype_contact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contact
    ADD CONSTRAINT contacttype_contact_fk FOREIGN KEY (contacttypeid) REFERENCES cvl.contacttype(contacttypeid);


--
-- TOC entry 6229 (class 2606 OID 66671)
-- Name: costcode_costcodeinvoice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.costcodeinvoice
    ADD CONSTRAINT costcode_costcodeinvoice_fk FOREIGN KEY (costcodeid) REFERENCES acp.costcode(costcodeid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6200 (class 2606 OID 66676)
-- Name: country_phone_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.phone
    ADD CONSTRAINT country_phone_fk FOREIGN KEY (countryiso) REFERENCES cvl.country(countryiso);


--
-- TOC entry 6302 (class 2606 OID 66681)
-- Name: datetype_productstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productstatus
    ADD CONSTRAINT datetype_productstatus_fk FOREIGN KEY (datetypeid) REFERENCES cvl.datetype(datetypeid);


--
-- TOC entry 6235 (class 2606 OID 66686)
-- Name: deliverable_deliverablecomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecomment
    ADD CONSTRAINT deliverable_deliverablecomment_fk FOREIGN KEY (deliverableid) REFERENCES acp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6238 (class 2606 OID 66691)
-- Name: deliverable_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecontact
    ADD CONSTRAINT deliverable_deliverablecontact_fk FOREIGN KEY (deliverableid) REFERENCES acp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6202 (class 2606 OID 66696)
-- Name: deliverable_deliverablemod_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemod
    ADD CONSTRAINT deliverable_deliverablemod_fk FOREIGN KEY (deliverableid) REFERENCES acp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6252 (class 2606 OID 66701)
-- Name: deliverable_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT deliverable_file_fk FOREIGN KEY (deliverableid) REFERENCES acp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6306 (class 2606 OID 66706)
-- Name: deliverable_progress_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.progress
    ADD CONSTRAINT deliverable_progress_fk FOREIGN KEY (deliverableid) REFERENCES acp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6312 (class 2606 OID 66711)
-- Name: deliverable_reminder_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.reminder
    ADD CONSTRAINT deliverable_reminder_fk FOREIGN KEY (deliverableid) REFERENCES acp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6203 (class 2606 OID 66716)
-- Name: deliverablemod_deliverablemod_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemod
    ADD CONSTRAINT deliverablemod_deliverablemod_fk FOREIGN KEY (parentmodificationid, parentdeliverableid) REFERENCES acp.deliverablemod(modificationid, deliverableid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6232 (class 2606 OID 66721)
-- Name: deliverablemod_deliverablemodstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemodstatus
    ADD CONSTRAINT deliverablemod_deliverablemodstatus_fk FOREIGN KEY (modificationid, deliverableid) REFERENCES acp.deliverablemod(modificationid, deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6241 (class 2606 OID 66726)
-- Name: deliverablemod_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablenotice
    ADD CONSTRAINT deliverablemod_deliverablenotice_fk FOREIGN KEY (modificationid, deliverableid) REFERENCES acp.deliverablemod(modificationid, deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6233 (class 2606 OID 66731)
-- Name: deliverablestatus_deliverablemodstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemodstatus
    ADD CONSTRAINT deliverablestatus_deliverablemodstatus_fk FOREIGN KEY (deliverablestatusid) REFERENCES cvl.deliverablestatus(deliverablestatusid);


--
-- TOC entry 6231 (class 2606 OID 66736)
-- Name: deliverabletype_deliverable_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverable
    ADD CONSTRAINT deliverabletype_deliverable_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);


--
-- TOC entry 6264 (class 2606 OID 66741)
-- Name: deliverabletype_product_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT deliverabletype_product_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);


--
-- TOC entry 6195 (class 2606 OID 66746)
-- Name: electaddtype_electadd_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.eaddress
    ADD CONSTRAINT electaddtype_electadd_fk FOREIGN KEY (eaddresstypeid) REFERENCES cvl.eaddresstype(eaddresstypeid);


--
-- TOC entry 6269 (class 2606 OID 66751)
-- Name: epsg_productepsg_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productepsg
    ADD CONSTRAINT epsg_productepsg_fk FOREIGN KEY (srid) REFERENCES public.spatial_ref_sys(srid);


--
-- TOC entry 6247 (class 2606 OID 66756)
-- Name: fact_factfile_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.factfile
    ADD CONSTRAINT fact_factfile_fk FOREIGN KEY (factid) REFERENCES acp.fact(factid) ON DELETE CASCADE;


--
-- TOC entry 6315 (class 2606 OID 66761)
-- Name: fact_timeline_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.timeline
    ADD CONSTRAINT fact_timeline_fk FOREIGN KEY (factid) REFERENCES acp.fact(factid) ON DELETE CASCADE;


--
-- TOC entry 6248 (class 2606 OID 66766)
-- Name: file_factfile_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.factfile
    ADD CONSTRAINT file_factfile_fk FOREIGN KEY (fileid) REFERENCES acp.file(fileid) ON DELETE CASCADE;


--
-- TOC entry 6249 (class 2606 OID 66771)
-- Name: file_filecomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.filecomment
    ADD CONSTRAINT file_filecomment_fk FOREIGN KEY (fileid) REFERENCES acp.file(fileid) ON DELETE CASCADE;


--
-- TOC entry 6253 (class 2606 OID 66776)
-- Name: filetype_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT filetype_file_fk FOREIGN KEY (filetypeid) REFERENCES cvl.filetype(filetypeid);


--
-- TOC entry 6254 (class 2606 OID 66781)
-- Name: fileversion_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT fileversion_file_fk FOREIGN KEY (fileid) REFERENCES acp.file(fileid);


--
-- TOC entry 6255 (class 2606 OID 66786)
-- Name: format_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT format_file_fk FOREIGN KEY (formatid) REFERENCES cvl.format(formatid);


--
-- TOC entry 6228 (class 2606 OID 66791)
-- Name: funding_chargecode_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.costcode
    ADD CONSTRAINT funding_chargecode_fk FOREIGN KEY (fundingid) REFERENCES acp.funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 6260 (class 2606 OID 66796)
-- Name: funding_fundingcomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fundingcomment
    ADD CONSTRAINT funding_fundingcomment_fk FOREIGN KEY (fundingid) REFERENCES acp.funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 6209 (class 2606 OID 66801)
-- Name: funding_invoice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.invoice
    ADD CONSTRAINT funding_invoice_fk FOREIGN KEY (fundingid) REFERENCES acp.funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 6206 (class 2606 OID 66806)
-- Name: fundingtype_funding_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.funding
    ADD CONSTRAINT fundingtype_funding_fk FOREIGN KEY (fundingtypeid) REFERENCES cvl.fundingtype(fundingtypeid);


--
-- TOC entry 6187 (class 2606 OID 66811)
-- Name: govunit_address_county_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.address
    ADD CONSTRAINT govunit_address_county_fk FOREIGN KEY (countyid) REFERENCES cvl.govunit(featureid);


--
-- TOC entry 6188 (class 2606 OID 66816)
-- Name: govunit_address_state_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.address
    ADD CONSTRAINT govunit_address_state_fk FOREIGN KEY (stateid) REFERENCES cvl.govunit(featureid);


--
-- TOC entry 6230 (class 2606 OID 66821)
-- Name: invoice_costcodeinvoice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.costcodeinvoice
    ADD CONSTRAINT invoice_costcodeinvoice_fk FOREIGN KEY (invoiceid) REFERENCES acp.invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 6256 (class 2606 OID 66826)
-- Name: invoice_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT invoice_file_fk FOREIGN KEY (invoiceid) REFERENCES acp.invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 6262 (class 2606 OID 66831)
-- Name: invoice_invoicecomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.invoicecomment
    ADD CONSTRAINT invoice_invoicecomment_fk FOREIGN KEY (invoiceid) REFERENCES acp.invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 6265 (class 2606 OID 66836)
-- Name: isoprogresstype_product_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT isoprogresstype_product_fk FOREIGN KEY (isoprogresstypeid) REFERENCES cvl.isoprogresstype(isoprogresstypeid);


--
-- TOC entry 6300 (class 2606 OID 66841)
-- Name: isoroletype_productcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productcontact
    ADD CONSTRAINT isoroletype_productcontact_fk FOREIGN KEY (isoroletypeid) REFERENCES cvl.isoroletype(isoroletypeid);


--
-- TOC entry 6271 (class 2606 OID 66846)
-- Name: keyword_productkeyword_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productkeyword
    ADD CONSTRAINT keyword_productkeyword_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);


--
-- TOC entry 6266 (class 2606 OID 66851)
-- Name: maintenancefrequency_product_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency(maintenancefrequencyid);


--
-- TOC entry 6295 (class 2606 OID 66856)
-- Name: modcontacttype_modcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcontact
    ADD CONSTRAINT modcontacttype_modcontact_fk FOREIGN KEY (modcontacttypeid) REFERENCES cvl.modcontacttype(modcontacttypeid);


--
-- TOC entry 6211 (class 2606 OID 66861)
-- Name: moddocstatustype_moddocstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.moddocstatus
    ADD CONSTRAINT moddocstatustype_moddocstatus_fk FOREIGN KEY (moddocstatustypeid) REFERENCES cvl.moddocstatustype(moddocstatustypeid);


--
-- TOC entry 6212 (class 2606 OID 66866)
-- Name: moddoctype_moddocstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.moddocstatus
    ADD CONSTRAINT moddoctype_moddocstatus_fk FOREIGN KEY (moddoctypeid) REFERENCES cvl.moddoctype(moddoctypeid);


--
-- TOC entry 6204 (class 2606 OID 66871)
-- Name: modification_deliverablemod_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemod
    ADD CONSTRAINT modification_deliverablemod_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6257 (class 2606 OID 66876)
-- Name: modification_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT modification_file_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6207 (class 2606 OID 66881)
-- Name: modification_funding_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.funding
    ADD CONSTRAINT modification_funding_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6292 (class 2606 OID 66886)
-- Name: modification_modcomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcomment
    ADD CONSTRAINT modification_modcomment_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6296 (class 2606 OID 66891)
-- Name: modification_modcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcontact
    ADD CONSTRAINT modification_modcontact_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6213 (class 2606 OID 66896)
-- Name: modification_moddocstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.moddocstatus
    ADD CONSTRAINT modification_moddocstatus_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6215 (class 2606 OID 66901)
-- Name: modification_modification_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modification
    ADD CONSTRAINT modification_modification_fk FOREIGN KEY (parentmodificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6244 (class 2606 OID 66906)
-- Name: modification_modificationcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: pts_admin
--

ALTER TABLE ONLY acp.modificationcontact
    ADD CONSTRAINT modification_modificationcontact_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid);


--
-- TOC entry 6219 (class 2606 OID 66911)
-- Name: modification_modstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modstatus
    ADD CONSTRAINT modification_modstatus_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6311 (class 2606 OID 66916)
-- Name: modification_purchaserequest_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.purchaserequest
    ADD CONSTRAINT modification_purchaserequest_fk FOREIGN KEY (modificationid) REFERENCES acp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6216 (class 2606 OID 66921)
-- Name: modtype_modification_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modification
    ADD CONSTRAINT modtype_modification_fk FOREIGN KEY (modtypeid) REFERENCES cvl.modtype(modtypeid);


--
-- TOC entry 6242 (class 2606 OID 66926)
-- Name: notice_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablenotice
    ADD CONSTRAINT notice_deliverablenotice_fk FOREIGN KEY (noticeid) REFERENCES cvl.notice(noticeid);


--
-- TOC entry 6297 (class 2606 OID 66931)
-- Name: onlinefunction_onlineresource_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.onlineresource
    ADD CONSTRAINT onlinefunction_onlineresource_fk FOREIGN KEY (onlinefunctionid) REFERENCES cvl.onlinefunction(onlinefunctionid);


--
-- TOC entry 6223 (class 2606 OID 66936)
-- Name: person_audit_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.audit
    ADD CONSTRAINT person_audit_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid);


--
-- TOC entry 6236 (class 2606 OID 66941)
-- Name: person_deliverablecomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecomment
    ADD CONSTRAINT person_deliverablecomment_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6205 (class 2606 OID 66946)
-- Name: person_deliverablemod_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemod
    ADD CONSTRAINT person_deliverablemod_fk FOREIGN KEY (personid) REFERENCES acp.person(contactid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6234 (class 2606 OID 66951)
-- Name: person_deliverablemodstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablemodstatus
    ADD CONSTRAINT person_deliverablemodstatus_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6250 (class 2606 OID 66956)
-- Name: person_filecomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.filecomment
    ADD CONSTRAINT person_filecomment_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6261 (class 2606 OID 66961)
-- Name: person_fundingcomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fundingcomment
    ADD CONSTRAINT person_fundingcomment_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6263 (class 2606 OID 66966)
-- Name: person_invoicecomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.invoicecomment
    ADD CONSTRAINT person_invoicecomment_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6293 (class 2606 OID 66971)
-- Name: person_modcomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modcomment
    ADD CONSTRAINT person_modcomment_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6214 (class 2606 OID 66976)
-- Name: person_moddocstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.moddocstatus
    ADD CONSTRAINT person_moddocstatus_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid);


--
-- TOC entry 6217 (class 2606 OID 66981)
-- Name: person_modification_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modification
    ADD CONSTRAINT person_modification_fk FOREIGN KEY (personid) REFERENCES acp.person(contactid);


--
-- TOC entry 6307 (class 2606 OID 66986)
-- Name: person_projectcomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcomment
    ADD CONSTRAINT person_projectcomment_fk FOREIGN KEY (contactid) REFERENCES acp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6201 (class 2606 OID 66991)
-- Name: phonetype_phone_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.phone
    ADD CONSTRAINT phonetype_phone_fk FOREIGN KEY (phonetypeid) REFERENCES cvl.phonetype(phonetypeid);


--
-- TOC entry 6192 (class 2606 OID 66996)
-- Name: postion_groupcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.contactcontactgroup
    ADD CONSTRAINT postion_groupcontact_fk FOREIGN KEY (positionid) REFERENCES cvl."position"(positionid);


--
-- TOC entry 6197 (class 2606 OID 67001)
-- Name: postion_person_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.person
    ADD CONSTRAINT postion_person_fk FOREIGN KEY (positionid) REFERENCES cvl."position"(positionid);


--
-- TOC entry 6298 (class 2606 OID 67006)
-- Name: product_onlineresource_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.onlineresource
    ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6301 (class 2606 OID 67011)
-- Name: product_productcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productcontact
    ADD CONSTRAINT product_productcontact_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6270 (class 2606 OID 67016)
-- Name: product_productepsg_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productepsg
    ADD CONSTRAINT product_productepsg_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6272 (class 2606 OID 67021)
-- Name: product_productkeyword_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productkeyword
    ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6273 (class 2606 OID 67026)
-- Name: product_productline_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productline
    ADD CONSTRAINT product_productline_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6274 (class 2606 OID 67031)
-- Name: product_productpoint_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productpoint
    ADD CONSTRAINT product_productpoint_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6275 (class 2606 OID 67036)
-- Name: product_productpolygon_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productpolygon
    ADD CONSTRAINT product_productpolygon_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6276 (class 2606 OID 67041)
-- Name: product_productspatialformat_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productspatialformat
    ADD CONSTRAINT product_productspatialformat_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6303 (class 2606 OID 67046)
-- Name: product_productstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productstatus
    ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6304 (class 2606 OID 67051)
-- Name: product_productstep_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productstep
    ADD CONSTRAINT product_productstep_fk FOREIGN KEY (productid) REFERENCES acp.product(productid);


--
-- TOC entry 6278 (class 2606 OID 67056)
-- Name: product_producttopiccategory_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.producttopiccategory
    ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6280 (class 2606 OID 67061)
-- Name: product_productwkt_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productwkt
    ADD CONSTRAINT product_productwkt_fk FOREIGN KEY (productid) REFERENCES acp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6305 (class 2606 OID 67066)
-- Name: productcontact_productstep_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productstep
    ADD CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid) REFERENCES acp.productcontact(productcontactid);


--
-- TOC entry 6267 (class 2606 OID 67071)
-- Name: productgroup_product_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT productgroup_product_fk FOREIGN KEY (productgroupid) REFERENCES acp.product(productid);


--
-- TOC entry 6258 (class 2606 OID 67076)
-- Name: progress_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT progress_file_fk FOREIGN KEY (progressid) REFERENCES acp.progress(progressid) ON DELETE CASCADE;


--
-- TOC entry 6246 (class 2606 OID 67081)
-- Name: project_fact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fact
    ADD CONSTRAINT project_fact_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6259 (class 2606 OID 67086)
-- Name: project_file_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.fileversion
    ADD CONSTRAINT project_file_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6218 (class 2606 OID 67091)
-- Name: project_modification_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modification
    ADD CONSTRAINT project_modification_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6268 (class 2606 OID 67096)
-- Name: project_product_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.product
    ADD CONSTRAINT project_product_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid);


--
-- TOC entry 6222 (class 2606 OID 67101)
-- Name: project_project_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.project
    ADD CONSTRAINT project_project_fk FOREIGN KEY (parentprojectid) REFERENCES acp.project(projectid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6308 (class 2606 OID 67106)
-- Name: project_projectcomment_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcomment
    ADD CONSTRAINT project_projectcomment_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6282 (class 2606 OID 67111)
-- Name: project_projectconcept_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectkeyword
    ADD CONSTRAINT project_projectconcept_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6226 (class 2606 OID 67116)
-- Name: project_projectcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcontact
    ADD CONSTRAINT project_projectcontact_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6309 (class 2606 OID 67121)
-- Name: project_projectgnis_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectgnis
    ADD CONSTRAINT project_projectgnis_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6310 (class 2606 OID 67126)
-- Name: project_projectitis_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectitis
    ADD CONSTRAINT project_projectitis_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6283 (class 2606 OID 67131)
-- Name: project_projectline_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectline
    ADD CONSTRAINT project_projectline_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6284 (class 2606 OID 67136)
-- Name: project_projectpoint_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectpoint
    ADD CONSTRAINT project_projectpoint_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6285 (class 2606 OID 67141)
-- Name: project_projectpolygon_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectpolygon
    ADD CONSTRAINT project_projectpolygon_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6286 (class 2606 OID 67146)
-- Name: project_projectprojectcategory_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectprojectcategory
    ADD CONSTRAINT project_projectprojectcategory_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6288 (class 2606 OID 67151)
-- Name: project_projecttopiccategory_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projecttopiccategory
    ADD CONSTRAINT project_projecttopiccategory_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6290 (class 2606 OID 67156)
-- Name: project_projectusertype_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectusertype
    ADD CONSTRAINT project_projectusertype_fk FOREIGN KEY (projectid) REFERENCES acp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6287 (class 2606 OID 67161)
-- Name: projectcategory_projectprojectcategory_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectprojectcategory
    ADD CONSTRAINT projectcategory_projectprojectcategory_fk FOREIGN KEY (projectcategoryid) REFERENCES cvl.projectcategory(projectcategoryid);


--
-- TOC entry 6208 (class 2606 OID 67166)
-- Name: projectcontact_funding_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.funding
    ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid) REFERENCES acp.projectcontact(projectcontactid) ON DELETE CASCADE;


--
-- TOC entry 6210 (class 2606 OID 67171)
-- Name: projectcontact_invoice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.invoice
    ADD CONSTRAINT projectcontact_invoice_fk FOREIGN KEY (projectcontactid) REFERENCES acp.projectcontact(projectcontactid) ON DELETE CASCADE;


--
-- TOC entry 6245 (class 2606 OID 67176)
-- Name: projectcontact_modificationcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: pts_admin
--

ALTER TABLE ONLY acp.modificationcontact
    ADD CONSTRAINT projectcontact_modificationcontact_fk FOREIGN KEY (projectcontactid) REFERENCES acp.projectcontact(projectcontactid);


--
-- TOC entry 6243 (class 2606 OID 67181)
-- Name: recipient_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablenotice
    ADD CONSTRAINT recipient_deliverablenotice_fk FOREIGN KEY (recipientid) REFERENCES acp.contact(contactid);


--
-- TOC entry 6314 (class 2606 OID 67186)
-- Name: reminder_remindercontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.remindercontact
    ADD CONSTRAINT reminder_remindercontact_fk FOREIGN KEY (reminderid) REFERENCES acp.reminder(reminderid) ON DELETE CASCADE;


--
-- TOC entry 6239 (class 2606 OID 67191)
-- Name: roletype_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.deliverablecontact
    ADD CONSTRAINT roletype_deliverablecontact_fk FOREIGN KEY (roletypeid) REFERENCES cvl.roletype(roletypeid);


--
-- TOC entry 6227 (class 2606 OID 67196)
-- Name: roletype_projectcontact_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectcontact
    ADD CONSTRAINT roletype_projectcontact_fk FOREIGN KEY (roletypeid) REFERENCES cvl.roletype(roletypeid);


--
-- TOC entry 6277 (class 2606 OID 67201)
-- Name: spatialformat_productspatialformat_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.productspatialformat
    ADD CONSTRAINT spatialformat_productspatialformat_fk FOREIGN KEY (spatialformatid) REFERENCES cvl.spatialformat(spatialformatid);


--
-- TOC entry 6220 (class 2606 OID 67206)
-- Name: status_modstatus_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.modstatus
    ADD CONSTRAINT status_modstatus_fk FOREIGN KEY (statusid) REFERENCES cvl.status(statusid);


--
-- TOC entry 6279 (class 2606 OID 67211)
-- Name: topiccategory_producttopiccategory_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.producttopiccategory
    ADD CONSTRAINT topiccategory_producttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);


--
-- TOC entry 6289 (class 2606 OID 67216)
-- Name: topiccategory_projecttopiccategory_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projecttopiccategory
    ADD CONSTRAINT topiccategory_projecttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);


--
-- TOC entry 6291 (class 2606 OID 67221)
-- Name: usertype_projectusertype_fk; Type: FK CONSTRAINT; Schema: acp; Owner: bradley
--

ALTER TABLE ONLY acp.projectusertype
    ADD CONSTRAINT usertype_projectusertype_fk FOREIGN KEY (usertypeid) REFERENCES cvl.usertype(usertypeid);


--
-- TOC entry 6749 (class 0 OID 0)
-- Dependencies: 17
-- Name: SCHEMA acp; Type: ACL; Schema: -; Owner: bradley
--

REVOKE ALL ON SCHEMA acp FROM PUBLIC;
REVOKE ALL ON SCHEMA acp FROM bradley;
GRANT ALL ON SCHEMA acp TO bradley;
GRANT USAGE ON SCHEMA acp TO pts_read;
GRANT ALL ON SCHEMA acp TO pts_admin;

--
-- TOC entry 6759 (class 0 OID 0)
-- Dependencies: 567
-- Name: TABLE address; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.address FROM PUBLIC;
REVOKE ALL ON TABLE acp.address FROM bradley;
GRANT ALL ON TABLE acp.address TO bradley;
GRANT SELECT ON TABLE acp.address TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.address TO pts_write;
GRANT ALL ON TABLE acp.address TO pts_admin;


--
-- TOC entry 6763 (class 0 OID 0)
-- Dependencies: 568
-- Name: TABLE contact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contact FROM PUBLIC;
REVOKE ALL ON TABLE acp.contact FROM bradley;
GRANT ALL ON TABLE acp.contact TO bradley;
GRANT SELECT ON TABLE acp.contact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.contact TO pts_write;
GRANT ALL ON TABLE acp.contact TO pts_admin;


--
-- TOC entry 6766 (class 0 OID 0)
-- Dependencies: 569
-- Name: TABLE contactcontactgroup; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contactcontactgroup FROM PUBLIC;
REVOKE ALL ON TABLE acp.contactcontactgroup FROM bradley;
GRANT ALL ON TABLE acp.contactcontactgroup TO bradley;
GRANT SELECT ON TABLE acp.contactcontactgroup TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.contactcontactgroup TO pts_write;
GRANT ALL ON TABLE acp.contactcontactgroup TO pts_admin;


--
-- TOC entry 6770 (class 0 OID 0)
-- Dependencies: 570
-- Name: TABLE contactgroup; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contactgroup FROM PUBLIC;
REVOKE ALL ON TABLE acp.contactgroup FROM bradley;
GRANT ALL ON TABLE acp.contactgroup TO bradley;
GRANT SELECT ON TABLE acp.contactgroup TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.contactgroup TO pts_write;
GRANT ALL ON TABLE acp.contactgroup TO pts_admin;


--
-- TOC entry 6773 (class 0 OID 0)
-- Dependencies: 571
-- Name: TABLE eaddress; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.eaddress FROM PUBLIC;
REVOKE ALL ON TABLE acp.eaddress FROM bradley;
GRANT ALL ON TABLE acp.eaddress TO bradley;
GRANT SELECT ON TABLE acp.eaddress TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.eaddress TO pts_write;
GRANT ALL ON TABLE acp.eaddress TO pts_admin;


--
-- TOC entry 6776 (class 0 OID 0)
-- Dependencies: 572
-- Name: TABLE person; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.person FROM PUBLIC;
REVOKE ALL ON TABLE acp.person FROM bradley;
GRANT ALL ON TABLE acp.person TO bradley;
GRANT SELECT ON TABLE acp.person TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.person TO pts_write;
GRANT ALL ON TABLE acp.person TO pts_admin;


--
-- TOC entry 6784 (class 0 OID 0)
-- Dependencies: 573
-- Name: TABLE phone; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.phone FROM PUBLIC;
REVOKE ALL ON TABLE acp.phone FROM bradley;
GRANT ALL ON TABLE acp.phone TO bradley;
GRANT SELECT ON TABLE acp.phone TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.phone TO pts_write;
GRANT ALL ON TABLE acp.phone TO pts_admin;


--
-- TOC entry 6785 (class 0 OID 0)
-- Dependencies: 574
-- Name: TABLE alccstaff; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.alccstaff FROM PUBLIC;
REVOKE ALL ON TABLE acp.alccstaff FROM bradley;
GRANT ALL ON TABLE acp.alccstaff TO bradley;
GRANT SELECT ON TABLE acp.alccstaff TO pts_read;
GRANT ALL ON TABLE acp.alccstaff TO pts_admin;


--
-- TOC entry 6786 (class 0 OID 0)
-- Dependencies: 575
-- Name: TABLE alccsteeringcommittee; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.alccsteeringcommittee FROM PUBLIC;
REVOKE ALL ON TABLE acp.alccsteeringcommittee FROM bradley;
GRANT ALL ON TABLE acp.alccsteeringcommittee TO bradley;
GRANT SELECT ON TABLE acp.alccsteeringcommittee TO pts_read;
GRANT ALL ON TABLE acp.alccsteeringcommittee TO pts_admin;


--
-- TOC entry 6802 (class 0 OID 0)
-- Dependencies: 576
-- Name: TABLE deliverablemod; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablemod FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablemod FROM bradley;
GRANT ALL ON TABLE acp.deliverablemod TO bradley;
GRANT SELECT ON TABLE acp.deliverablemod TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.deliverablemod TO pts_write;
GRANT ALL ON TABLE acp.deliverablemod TO pts_admin;


--
-- TOC entry 6807 (class 0 OID 0)
-- Dependencies: 577
-- Name: TABLE funding; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.funding FROM PUBLIC;
REVOKE ALL ON TABLE acp.funding FROM bradley;
GRANT ALL ON TABLE acp.funding TO bradley;
GRANT SELECT ON TABLE acp.funding TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.funding TO pts_write;
GRANT ALL ON TABLE acp.funding TO pts_admin;


--
-- TOC entry 6812 (class 0 OID 0)
-- Dependencies: 578
-- Name: TABLE invoice; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.invoice FROM PUBLIC;
REVOKE ALL ON TABLE acp.invoice FROM bradley;
GRANT ALL ON TABLE acp.invoice TO bradley;
GRANT SELECT ON TABLE acp.invoice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.invoice TO pts_write;
GRANT ALL ON TABLE acp.invoice TO pts_admin;


--
-- TOC entry 6820 (class 0 OID 0)
-- Dependencies: 579
-- Name: TABLE moddocstatus; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.moddocstatus FROM PUBLIC;
REVOKE ALL ON TABLE acp.moddocstatus FROM bradley;
GRANT ALL ON TABLE acp.moddocstatus TO bradley;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.moddocstatus TO pts_write;
GRANT SELECT ON TABLE acp.moddocstatus TO pts_read;
GRANT ALL ON TABLE acp.moddocstatus TO pts_admin;


--
-- TOC entry 6833 (class 0 OID 0)
-- Dependencies: 580
-- Name: TABLE modification; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modification FROM PUBLIC;
REVOKE ALL ON TABLE acp.modification FROM bradley;
GRANT ALL ON TABLE acp.modification TO bradley;
GRANT SELECT ON TABLE acp.modification TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.modification TO pts_write;
GRANT ALL ON TABLE acp.modification TO pts_admin;


--
-- TOC entry 6838 (class 0 OID 0)
-- Dependencies: 581
-- Name: TABLE modstatus; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modstatus FROM PUBLIC;
REVOKE ALL ON TABLE acp.modstatus FROM bradley;
GRANT ALL ON TABLE acp.modstatus TO bradley;
GRANT SELECT ON TABLE acp.modstatus TO pts_read;
GRANT INSERT,DELETE,UPDATE ON TABLE acp.modstatus TO pts_write;
GRANT ALL ON TABLE acp.modstatus TO pts_admin;


--
-- TOC entry 6840 (class 0 OID 0)
-- Dependencies: 582
-- Name: TABLE modificationstatus; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modificationstatus FROM PUBLIC;
REVOKE ALL ON TABLE acp.modificationstatus FROM bradley;
GRANT ALL ON TABLE acp.modificationstatus TO bradley;
GRANT SELECT ON TABLE acp.modificationstatus TO pts_read;
GRANT ALL ON TABLE acp.modificationstatus TO pts_admin;


--
-- TOC entry 6855 (class 0 OID 0)
-- Dependencies: 583
-- Name: TABLE project; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.project FROM PUBLIC;
REVOKE ALL ON TABLE acp.project FROM bradley;
GRANT ALL ON TABLE acp.project TO bradley;
GRANT SELECT ON TABLE acp.project TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.project TO pts_write;
GRANT ALL ON TABLE acp.project TO pts_admin;


--
-- TOC entry 6856 (class 0 OID 0)
-- Dependencies: 584
-- Name: TABLE projectlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectlist FROM bradley;
GRANT ALL ON TABLE acp.projectlist TO bradley;
GRANT SELECT ON TABLE acp.projectlist TO pts_read;
GRANT SELECT ON TABLE acp.projectlist TO pts_write;
GRANT ALL ON TABLE acp.projectlist TO pts_admin;


--
-- TOC entry 6857 (class 0 OID 0)
-- Dependencies: 585
-- Name: TABLE allmoddocstatus; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.allmoddocstatus FROM PUBLIC;
REVOKE ALL ON TABLE acp.allmoddocstatus FROM bradley;
GRANT ALL ON TABLE acp.allmoddocstatus TO bradley;
GRANT SELECT ON TABLE acp.allmoddocstatus TO pts_read;
GRANT ALL ON TABLE acp.allmoddocstatus TO pts_admin;


--
-- TOC entry 6860 (class 0 OID 0)
-- Dependencies: 586
-- Name: TABLE audit; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.audit FROM PUBLIC;
REVOKE ALL ON TABLE acp.audit FROM bradley;
GRANT ALL ON TABLE acp.audit TO bradley;
GRANT SELECT ON TABLE acp.audit TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.audit TO pts_write;
GRANT ALL ON TABLE acp.audit TO pts_admin;


--
-- TOC entry 6866 (class 0 OID 0)
-- Dependencies: 587
-- Name: TABLE catalogprojectcategory; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.catalogprojectcategory FROM PUBLIC;
REVOKE ALL ON TABLE acp.catalogprojectcategory FROM bradley;
GRANT ALL ON TABLE acp.catalogprojectcategory TO bradley;
GRANT ALL ON TABLE acp.catalogprojectcategory TO pts_admin;


--
-- TOC entry 6869 (class 0 OID 0)
-- Dependencies: 588
-- Name: TABLE contactcostcode; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contactcostcode FROM PUBLIC;
REVOKE ALL ON TABLE acp.contactcostcode FROM bradley;
GRANT ALL ON TABLE acp.contactcostcode TO bradley;
GRANT SELECT ON TABLE acp.contactcostcode TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.contactcostcode TO pts_write;
GRANT ALL ON TABLE acp.contactcostcode TO pts_admin;


--
-- TOC entry 6870 (class 0 OID 0)
-- Dependencies: 589
-- Name: TABLE contactgrouplist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contactgrouplist FROM PUBLIC;
REVOKE ALL ON TABLE acp.contactgrouplist FROM bradley;
GRANT ALL ON TABLE acp.contactgrouplist TO bradley;
GRANT SELECT ON TABLE acp.contactgrouplist TO pts_read;
GRANT ALL ON TABLE acp.contactgrouplist TO pts_admin;


--
-- TOC entry 6871 (class 0 OID 0)
-- Dependencies: 590
-- Name: TABLE contactprimaryinfo; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contactprimaryinfo FROM PUBLIC;
REVOKE ALL ON TABLE acp.contactprimaryinfo FROM bradley;
GRANT ALL ON TABLE acp.contactprimaryinfo TO bradley;
GRANT SELECT ON TABLE acp.contactprimaryinfo TO pts_read;
GRANT ALL ON TABLE acp.contactprimaryinfo TO pts_admin;


--
-- TOC entry 6877 (class 0 OID 0)
-- Dependencies: 591
-- Name: TABLE projectcontact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectcontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectcontact FROM bradley;
GRANT ALL ON TABLE acp.projectcontact TO bradley;
GRANT SELECT ON TABLE acp.projectcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectcontact TO pts_write;
GRANT ALL ON TABLE acp.projectcontact TO pts_admin;


--
-- TOC entry 6878 (class 0 OID 0)
-- Dependencies: 592
-- Name: TABLE contactprojectslist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.contactprojectslist FROM PUBLIC;
REVOKE ALL ON TABLE acp.contactprojectslist FROM bradley;
GRANT ALL ON TABLE acp.contactprojectslist TO bradley;
GRANT SELECT ON TABLE acp.contactprojectslist TO pts_read;
GRANT ALL ON TABLE acp.contactprojectslist TO pts_admin;


--
-- TOC entry 6883 (class 0 OID 0)
-- Dependencies: 593
-- Name: TABLE costcode; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.costcode FROM PUBLIC;
REVOKE ALL ON TABLE acp.costcode FROM bradley;
GRANT ALL ON TABLE acp.costcode TO bradley;
GRANT SELECT ON TABLE acp.costcode TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.costcode TO pts_write;
GRANT ALL ON TABLE acp.costcode TO pts_admin;


--
-- TOC entry 6887 (class 0 OID 0)
-- Dependencies: 594
-- Name: TABLE costcodeinvoice; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.costcodeinvoice FROM PUBLIC;
REVOKE ALL ON TABLE acp.costcodeinvoice FROM bradley;
GRANT ALL ON TABLE acp.costcodeinvoice TO bradley;
GRANT SELECT ON TABLE acp.costcodeinvoice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.costcodeinvoice TO pts_write;
GRANT ALL ON TABLE acp.costcodeinvoice TO pts_admin;


--
-- TOC entry 6888 (class 0 OID 0)
-- Dependencies: 595
-- Name: TABLE countylist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.countylist FROM PUBLIC;
REVOKE ALL ON TABLE acp.countylist FROM bradley;
GRANT ALL ON TABLE acp.countylist TO bradley;
GRANT SELECT ON TABLE acp.countylist TO pts_read;
GRANT ALL ON TABLE acp.countylist TO pts_admin;


--
-- TOC entry 6894 (class 0 OID 0)
-- Dependencies: 596
-- Name: TABLE deliverable; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverable FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverable FROM bradley;
GRANT ALL ON TABLE acp.deliverable TO bradley;
GRANT SELECT ON TABLE acp.deliverable TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.deliverable TO pts_write;
GRANT ALL ON TABLE acp.deliverable TO pts_admin;


--
-- TOC entry 6901 (class 0 OID 0)
-- Dependencies: 597
-- Name: TABLE deliverablemodstatus; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablemodstatus FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablemodstatus FROM bradley;
GRANT ALL ON TABLE acp.deliverablemodstatus TO bradley;
GRANT SELECT ON TABLE acp.deliverablemodstatus TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.deliverablemodstatus TO pts_write;
GRANT ALL ON TABLE acp.deliverablemodstatus TO pts_admin;


--
-- TOC entry 6902 (class 0 OID 0)
-- Dependencies: 598
-- Name: TABLE deliverableall; Type: ACL; Schema: acp; Owner: pts_admin
--

REVOKE ALL ON TABLE acp.deliverableall FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverableall FROM pts_admin;
GRANT ALL ON TABLE acp.deliverableall TO pts_admin;
GRANT SELECT ON TABLE acp.deliverableall TO pts_read;


--
-- TOC entry 6903 (class 0 OID 0)
-- Dependencies: 599
-- Name: TABLE deliverablecalendar; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablecalendar FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablecalendar FROM bradley;
GRANT ALL ON TABLE acp.deliverablecalendar TO bradley;
GRANT SELECT ON TABLE acp.deliverablecalendar TO pts_read;
GRANT ALL ON TABLE acp.deliverablecalendar TO pts_admin;


--
-- TOC entry 6907 (class 0 OID 0)
-- Dependencies: 600
-- Name: TABLE deliverablecomment; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablecomment FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablecomment FROM bradley;
GRANT ALL ON TABLE acp.deliverablecomment TO bradley;
GRANT SELECT ON TABLE acp.deliverablecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.deliverablecomment TO pts_write;
GRANT ALL ON TABLE acp.deliverablecomment TO pts_admin;


--
-- TOC entry 6911 (class 0 OID 0)
-- Dependencies: 601
-- Name: TABLE deliverablecontact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablecontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablecontact FROM bradley;
GRANT ALL ON TABLE acp.deliverablecontact TO bradley;
GRANT SELECT ON TABLE acp.deliverablecontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.deliverablecontact TO pts_write;
GRANT ALL ON TABLE acp.deliverablecontact TO pts_admin;


--
-- TOC entry 6912 (class 0 OID 0)
-- Dependencies: 602
-- Name: TABLE personlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.personlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.personlist FROM bradley;
GRANT ALL ON TABLE acp.personlist TO bradley;
GRANT SELECT ON TABLE acp.personlist TO pts_read;
GRANT ALL ON TABLE acp.personlist TO pts_admin;


--
-- TOC entry 6913 (class 0 OID 0)
-- Dependencies: 603
-- Name: TABLE deliverabledue; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverabledue FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverabledue FROM bradley;
GRANT ALL ON TABLE acp.deliverabledue TO bradley;
GRANT SELECT ON TABLE acp.deliverabledue TO pts_read;
GRANT ALL ON TABLE acp.deliverabledue TO pts_admin;


--
-- TOC entry 6915 (class 0 OID 0)
-- Dependencies: 604
-- Name: TABLE deliverablelist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablelist FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablelist FROM bradley;
GRANT ALL ON TABLE acp.deliverablelist TO bradley;
GRANT SELECT ON TABLE acp.deliverablelist TO pts_read;
GRANT ALL ON TABLE acp.deliverablelist TO pts_admin;


--
-- TOC entry 6924 (class 0 OID 0)
-- Dependencies: 605
-- Name: TABLE deliverablenotice; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablenotice FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablenotice FROM bradley;
GRANT ALL ON TABLE acp.deliverablenotice TO bradley;
GRANT SELECT ON TABLE acp.deliverablenotice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.deliverablenotice TO pts_write;
GRANT ALL ON TABLE acp.deliverablenotice TO pts_admin;


--
-- TOC entry 6929 (class 0 OID 0)
-- Dependencies: 606
-- Name: TABLE modificationcontact; Type: ACL; Schema: acp; Owner: pts_admin
--

REVOKE ALL ON TABLE acp.modificationcontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.modificationcontact FROM pts_admin;
GRANT ALL ON TABLE acp.modificationcontact TO pts_admin;
GRANT SELECT ON TABLE acp.modificationcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.modificationcontact TO pts_write;


--
-- TOC entry 6930 (class 0 OID 0)
-- Dependencies: 607
-- Name: TABLE deliverablereminder; Type: ACL; Schema: acp; Owner: pts_admin
--

REVOKE ALL ON TABLE acp.deliverablereminder FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablereminder FROM pts_admin;
GRANT ALL ON TABLE acp.deliverablereminder TO pts_admin;
GRANT SELECT ON TABLE acp.deliverablereminder TO pts_read;


--
-- TOC entry 6931 (class 0 OID 0)
-- Dependencies: 608
-- Name: TABLE deliverablestatuslist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.deliverablestatuslist FROM PUBLIC;
REVOKE ALL ON TABLE acp.deliverablestatuslist FROM bradley;
GRANT ALL ON TABLE acp.deliverablestatuslist TO bradley;
GRANT SELECT ON TABLE acp.deliverablestatuslist TO pts_read;
GRANT ALL ON TABLE acp.deliverablestatuslist TO pts_admin;


--
-- TOC entry 6932 (class 0 OID 0)
-- Dependencies: 609
-- Name: TABLE acpsteeringcommittee; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.acpsteeringcommittee FROM PUBLIC;
REVOKE ALL ON TABLE acp.acpsteeringcommittee FROM bradley;
GRANT ALL ON TABLE acp.acpsteeringcommittee TO bradley;
GRANT ALL ON TABLE acp.acpsteeringcommittee TO pts_admin;


--
-- TOC entry 6935 (class 0 OID 0)
-- Dependencies: 610
-- Name: TABLE fact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.fact FROM PUBLIC;
REVOKE ALL ON TABLE acp.fact FROM bradley;
GRANT ALL ON TABLE acp.fact TO bradley;
GRANT SELECT ON TABLE acp.fact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.fact TO pts_write;
GRANT ALL ON TABLE acp.fact TO pts_admin;


--
-- TOC entry 6939 (class 0 OID 0)
-- Dependencies: 611
-- Name: TABLE factfile; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.factfile FROM PUBLIC;
REVOKE ALL ON TABLE acp.factfile FROM bradley;
GRANT ALL ON TABLE acp.factfile TO bradley;
GRANT SELECT ON TABLE acp.factfile TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.factfile TO pts_write;
GRANT ALL ON TABLE acp.factfile TO pts_admin;


--
-- TOC entry 6944 (class 0 OID 0)
-- Dependencies: 612
-- Name: TABLE file; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.file FROM PUBLIC;
REVOKE ALL ON TABLE acp.file FROM bradley;
GRANT ALL ON TABLE acp.file TO bradley;
GRANT SELECT ON TABLE acp.file TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.file TO pts_write;
GRANT ALL ON TABLE acp.file TO pts_admin;


--
-- TOC entry 6947 (class 0 OID 0)
-- Dependencies: 613
-- Name: TABLE filecomment; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.filecomment FROM PUBLIC;
REVOKE ALL ON TABLE acp.filecomment FROM bradley;
GRANT ALL ON TABLE acp.filecomment TO bradley;
GRANT SELECT ON TABLE acp.filecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.filecomment TO pts_write;
GRANT ALL ON TABLE acp.filecomment TO pts_admin;


--
-- TOC entry 6954 (class 0 OID 0)
-- Dependencies: 614
-- Name: TABLE fileversion; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.fileversion FROM PUBLIC;
REVOKE ALL ON TABLE acp.fileversion FROM bradley;
GRANT ALL ON TABLE acp.fileversion TO bradley;
GRANT SELECT ON TABLE acp.fileversion TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.fileversion TO pts_write;
GRANT ALL ON TABLE acp.fileversion TO pts_admin;


--
-- TOC entry 6958 (class 0 OID 0)
-- Dependencies: 615
-- Name: TABLE fundingcomment; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.fundingcomment FROM PUBLIC;
REVOKE ALL ON TABLE acp.fundingcomment FROM bradley;
GRANT ALL ON TABLE acp.fundingcomment TO bradley;
GRANT SELECT ON TABLE acp.fundingcomment TO pts_read;
GRANT INSERT,DELETE,UPDATE ON TABLE acp.fundingcomment TO pts_write;
GRANT ALL ON TABLE acp.fundingcomment TO pts_admin;


--
-- TOC entry 6959 (class 0 OID 0)
-- Dependencies: 616
-- Name: TABLE fundingtotals; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.fundingtotals FROM PUBLIC;
REVOKE ALL ON TABLE acp.fundingtotals FROM bradley;
GRANT ALL ON TABLE acp.fundingtotals TO bradley;
GRANT SELECT ON TABLE acp.fundingtotals TO pts_read;
GRANT ALL ON TABLE acp.fundingtotals TO pts_admin;


--
-- TOC entry 6960 (class 0 OID 0)
-- Dependencies: 617
-- Name: TABLE groupmemberlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.groupmemberlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.groupmemberlist FROM bradley;
GRANT ALL ON TABLE acp.groupmemberlist TO bradley;
GRANT SELECT ON TABLE acp.groupmemberlist TO pts_read;
GRANT ALL ON TABLE acp.groupmemberlist TO pts_admin;


--
-- TOC entry 6961 (class 0 OID 0)
-- Dependencies: 618
-- Name: TABLE grouppersonfull; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.grouppersonfull FROM PUBLIC;
REVOKE ALL ON TABLE acp.grouppersonfull FROM bradley;
GRANT ALL ON TABLE acp.grouppersonfull TO bradley;
GRANT SELECT ON TABLE acp.grouppersonfull TO pts_read;
GRANT ALL ON TABLE acp.grouppersonfull TO pts_admin;


--
-- TOC entry 6962 (class 0 OID 0)
-- Dependencies: 619
-- Name: TABLE grouppersonlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.grouppersonlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.grouppersonlist FROM bradley;
GRANT ALL ON TABLE acp.grouppersonlist TO bradley;
GRANT SELECT ON TABLE acp.grouppersonlist TO pts_read;
GRANT ALL ON TABLE acp.grouppersonlist TO pts_admin;


--
-- TOC entry 6964 (class 0 OID 0)
-- Dependencies: 620
-- Name: TABLE invoicecomment; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.invoicecomment FROM PUBLIC;
REVOKE ALL ON TABLE acp.invoicecomment FROM bradley;
GRANT ALL ON TABLE acp.invoicecomment TO bradley;
GRANT SELECT ON TABLE acp.invoicecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.invoicecomment TO pts_write;
GRANT ALL ON TABLE acp.invoicecomment TO pts_admin;


--
-- TOC entry 6965 (class 0 OID 0)
-- Dependencies: 621
-- Name: TABLE invoicelist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.invoicelist FROM PUBLIC;
REVOKE ALL ON TABLE acp.invoicelist FROM bradley;
GRANT ALL ON TABLE acp.invoicelist TO bradley;
GRANT SELECT ON TABLE acp.invoicelist TO pts_read;
GRANT ALL ON TABLE acp.invoicelist TO pts_admin;


--
-- TOC entry 6966 (class 0 OID 0)
-- Dependencies: 622
-- Name: TABLE longprojectsummary; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.longprojectsummary FROM PUBLIC;
REVOKE ALL ON TABLE acp.longprojectsummary FROM bradley;
GRANT ALL ON TABLE acp.longprojectsummary TO bradley;
GRANT SELECT ON TABLE acp.longprojectsummary TO pts_read;
GRANT ALL ON TABLE acp.longprojectsummary TO pts_admin;


--
-- TOC entry 6967 (class 0 OID 0)
-- Dependencies: 623
-- Name: TABLE membergrouplist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.membergrouplist FROM PUBLIC;
REVOKE ALL ON TABLE acp.membergrouplist FROM bradley;
GRANT ALL ON TABLE acp.membergrouplist TO bradley;
GRANT SELECT ON TABLE acp.membergrouplist TO pts_read;
GRANT ALL ON TABLE acp.membergrouplist TO pts_admin;


--
-- TOC entry 6968 (class 0 OID 0)
-- Dependencies: 624
-- Name: TABLE metadatacontact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.metadatacontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.metadatacontact FROM bradley;
GRANT ALL ON TABLE acp.metadatacontact TO bradley;
GRANT SELECT ON TABLE acp.metadatacontact TO pts_read;
GRANT ALL ON TABLE acp.metadatacontact TO pts_admin;


--
-- TOC entry 6969 (class 0 OID 0)
-- Dependencies: 625
-- Name: TABLE metadatafunding; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.metadatafunding FROM PUBLIC;
REVOKE ALL ON TABLE acp.metadatafunding FROM bradley;
GRANT ALL ON TABLE acp.metadatafunding TO bradley;
GRANT SELECT ON TABLE acp.metadatafunding TO pts_read;
GRANT ALL ON TABLE acp.metadatafunding TO pts_admin;


--
-- TOC entry 6987 (class 0 OID 0)
-- Dependencies: 626
-- Name: TABLE product; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.product FROM PUBLIC;
REVOKE ALL ON TABLE acp.product FROM bradley;
GRANT ALL ON TABLE acp.product TO bradley;
GRANT SELECT ON TABLE acp.product TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.product TO pts_write;
GRANT ALL ON TABLE acp.product TO pts_admin;


--
-- TOC entry 6988 (class 0 OID 0)
-- Dependencies: 627
-- Name: TABLE productepsg; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productepsg FROM PUBLIC;
REVOKE ALL ON TABLE acp.productepsg FROM bradley;
GRANT ALL ON TABLE acp.productepsg TO bradley;
GRANT SELECT ON TABLE acp.productepsg TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productepsg TO pts_write;
GRANT ALL ON TABLE acp.productepsg TO pts_admin;


--
-- TOC entry 6993 (class 0 OID 0)
-- Dependencies: 628
-- Name: TABLE productkeyword; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productkeyword FROM PUBLIC;
REVOKE ALL ON TABLE acp.productkeyword FROM bradley;
GRANT ALL ON TABLE acp.productkeyword TO bradley;
GRANT SELECT ON TABLE acp.productkeyword TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productkeyword TO pts_write;
GRANT ALL ON TABLE acp.productkeyword TO pts_admin;


--
-- TOC entry 6994 (class 0 OID 0)
-- Dependencies: 629
-- Name: TABLE productline; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productline FROM PUBLIC;
REVOKE ALL ON TABLE acp.productline FROM bradley;
GRANT ALL ON TABLE acp.productline TO bradley;
GRANT SELECT ON TABLE acp.productline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productline TO pts_write;
GRANT ALL ON TABLE acp.productline TO pts_admin;


--
-- TOC entry 6995 (class 0 OID 0)
-- Dependencies: 630
-- Name: TABLE productpoint; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productpoint FROM PUBLIC;
REVOKE ALL ON TABLE acp.productpoint FROM bradley;
GRANT ALL ON TABLE acp.productpoint TO bradley;
GRANT SELECT ON TABLE acp.productpoint TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productpoint TO pts_write;
GRANT ALL ON TABLE acp.productpoint TO pts_admin;


--
-- TOC entry 6996 (class 0 OID 0)
-- Dependencies: 631
-- Name: TABLE productpolygon; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productpolygon FROM PUBLIC;
REVOKE ALL ON TABLE acp.productpolygon FROM bradley;
GRANT ALL ON TABLE acp.productpolygon TO bradley;
GRANT SELECT ON TABLE acp.productpolygon TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productpolygon TO pts_write;
GRANT ALL ON TABLE acp.productpolygon TO pts_admin;


--
-- TOC entry 6997 (class 0 OID 0)
-- Dependencies: 632
-- Name: TABLE productspatialformat; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productspatialformat FROM PUBLIC;
REVOKE ALL ON TABLE acp.productspatialformat FROM bradley;
GRANT ALL ON TABLE acp.productspatialformat TO bradley;
GRANT SELECT ON TABLE acp.productspatialformat TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productspatialformat TO pts_write;
GRANT ALL ON TABLE acp.productspatialformat TO pts_admin;


--
-- TOC entry 6998 (class 0 OID 0)
-- Dependencies: 633
-- Name: TABLE producttopiccategory; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.producttopiccategory FROM PUBLIC;
REVOKE ALL ON TABLE acp.producttopiccategory FROM bradley;
GRANT ALL ON TABLE acp.producttopiccategory TO bradley;
GRANT SELECT ON TABLE acp.producttopiccategory TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.producttopiccategory TO pts_write;
GRANT ALL ON TABLE acp.producttopiccategory TO pts_admin;


--
-- TOC entry 6999 (class 0 OID 0)
-- Dependencies: 634
-- Name: TABLE productwkt; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productwkt FROM PUBLIC;
REVOKE ALL ON TABLE acp.productwkt FROM bradley;
GRANT ALL ON TABLE acp.productwkt TO bradley;
GRANT SELECT ON TABLE acp.productwkt TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productwkt TO pts_write;
GRANT ALL ON TABLE acp.productwkt TO pts_admin;


--
-- TOC entry 7000 (class 0 OID 0)
-- Dependencies: 635
-- Name: TABLE metadataproduct; Type: ACL; Schema: acp; Owner: pts_admin
--

REVOKE ALL ON TABLE acp.metadataproduct FROM PUBLIC;
REVOKE ALL ON TABLE acp.metadataproduct FROM pts_admin;
GRANT ALL ON TABLE acp.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE acp.metadataproduct TO pts_read;


--
-- TOC entry 7003 (class 0 OID 0)
-- Dependencies: 636
-- Name: TABLE projectkeyword; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectkeyword FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectkeyword FROM bradley;
GRANT ALL ON TABLE acp.projectkeyword TO bradley;
GRANT SELECT ON TABLE acp.projectkeyword TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectkeyword TO pts_write;
GRANT ALL ON TABLE acp.projectkeyword TO pts_admin;


--
-- TOC entry 7004 (class 0 OID 0)
-- Dependencies: 637
-- Name: TABLE projectline; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectline FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectline FROM bradley;
GRANT ALL ON TABLE acp.projectline TO bradley;
GRANT SELECT ON TABLE acp.projectline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectline TO pts_write;
GRANT ALL ON TABLE acp.projectline TO pts_admin;


--
-- TOC entry 7005 (class 0 OID 0)
-- Dependencies: 638
-- Name: TABLE projectpoint; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectpoint FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectpoint FROM bradley;
GRANT ALL ON TABLE acp.projectpoint TO bradley;
GRANT SELECT ON TABLE acp.projectpoint TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectpoint TO pts_write;
GRANT ALL ON TABLE acp.projectpoint TO pts_admin;


--
-- TOC entry 7006 (class 0 OID 0)
-- Dependencies: 639
-- Name: TABLE projectpolygon; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectpolygon FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectpolygon FROM bradley;
GRANT ALL ON TABLE acp.projectpolygon TO bradley;
GRANT SELECT ON TABLE acp.projectpolygon TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectpolygon TO pts_write;
GRANT ALL ON TABLE acp.projectpolygon TO pts_admin;


--
-- TOC entry 7007 (class 0 OID 0)
-- Dependencies: 640
-- Name: TABLE projectprojectcategory; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectprojectcategory FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectprojectcategory FROM bradley;
GRANT ALL ON TABLE acp.projectprojectcategory TO bradley;
GRANT SELECT ON TABLE acp.projectprojectcategory TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectprojectcategory TO pts_write;
GRANT ALL ON TABLE acp.projectprojectcategory TO pts_admin;


--
-- TOC entry 7008 (class 0 OID 0)
-- Dependencies: 641
-- Name: TABLE projecttopiccategory; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projecttopiccategory FROM PUBLIC;
REVOKE ALL ON TABLE acp.projecttopiccategory FROM bradley;
GRANT ALL ON TABLE acp.projecttopiccategory TO bradley;
GRANT SELECT ON TABLE acp.projecttopiccategory TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projecttopiccategory TO pts_write;
GRANT ALL ON TABLE acp.projecttopiccategory TO pts_admin;


--
-- TOC entry 7009 (class 0 OID 0)
-- Dependencies: 642
-- Name: TABLE projectusertype; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectusertype FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectusertype FROM bradley;
GRANT ALL ON TABLE acp.projectusertype TO bradley;
GRANT SELECT ON TABLE acp.projectusertype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectusertype TO pts_write;
GRANT ALL ON TABLE acp.projectusertype TO pts_admin;


--
-- TOC entry 7010 (class 0 OID 0)
-- Dependencies: 643
-- Name: TABLE metadataproject; Type: ACL; Schema: acp; Owner: pts_admin
--

REVOKE ALL ON TABLE acp.metadataproject FROM PUBLIC;
REVOKE ALL ON TABLE acp.metadataproject FROM pts_admin;
GRANT ALL ON TABLE acp.metadataproject TO pts_admin;
GRANT SELECT ON TABLE acp.metadataproject TO pts_read;


--
-- TOC entry 7014 (class 0 OID 0)
-- Dependencies: 644
-- Name: TABLE modcomment; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modcomment FROM PUBLIC;
REVOKE ALL ON TABLE acp.modcomment FROM bradley;
GRANT ALL ON TABLE acp.modcomment TO bradley;
GRANT SELECT ON TABLE acp.modcomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.modcomment TO pts_write;
GRANT ALL ON TABLE acp.modcomment TO pts_admin;


--
-- TOC entry 7018 (class 0 OID 0)
-- Dependencies: 645
-- Name: TABLE modcontact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modcontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.modcontact FROM bradley;
GRANT ALL ON TABLE acp.modcontact TO bradley;
GRANT SELECT ON TABLE acp.modcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.modcontact TO pts_write;
GRANT ALL ON TABLE acp.modcontact TO pts_admin;


--
-- TOC entry 7019 (class 0 OID 0)
-- Dependencies: 646
-- Name: TABLE moddocstatuslist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.moddocstatuslist FROM PUBLIC;
REVOKE ALL ON TABLE acp.moddocstatuslist FROM bradley;
GRANT ALL ON TABLE acp.moddocstatuslist TO bradley;
GRANT SELECT ON TABLE acp.moddocstatuslist TO pts_read;
GRANT ALL ON TABLE acp.moddocstatuslist TO pts_admin;


--
-- TOC entry 7020 (class 0 OID 0)
-- Dependencies: 647
-- Name: TABLE modificationcontactlist; Type: ACL; Schema: acp; Owner: pts_admin
--

REVOKE ALL ON TABLE acp.modificationcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.modificationcontactlist FROM pts_admin;
GRANT ALL ON TABLE acp.modificationcontactlist TO pts_admin;
GRANT SELECT ON TABLE acp.modificationcontactlist TO pts_read;


--
-- TOC entry 7021 (class 0 OID 0)
-- Dependencies: 648
-- Name: TABLE modificationlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modificationlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.modificationlist FROM bradley;
GRANT ALL ON TABLE acp.modificationlist TO bradley;
GRANT SELECT ON TABLE acp.modificationlist TO pts_read;
GRANT ALL ON TABLE acp.modificationlist TO pts_admin;


--
-- TOC entry 7023 (class 0 OID 0)
-- Dependencies: 649
-- Name: TABLE modstatuslist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.modstatuslist FROM PUBLIC;
REVOKE ALL ON TABLE acp.modstatuslist FROM bradley;
GRANT ALL ON TABLE acp.modstatuslist TO bradley;
GRANT SELECT ON TABLE acp.modstatuslist TO pts_read;
GRANT ALL ON TABLE acp.modstatuslist TO pts_admin;


--
-- TOC entry 7024 (class 0 OID 0)
-- Dependencies: 650
-- Name: TABLE noticesent; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.noticesent FROM PUBLIC;
REVOKE ALL ON TABLE acp.noticesent FROM bradley;
GRANT ALL ON TABLE acp.noticesent TO bradley;
GRANT SELECT ON TABLE acp.noticesent TO pts_read;
GRANT ALL ON TABLE acp.noticesent TO pts_admin;


--
-- TOC entry 7032 (class 0 OID 0)
-- Dependencies: 651
-- Name: TABLE onlineresource; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.onlineresource FROM PUBLIC;
REVOKE ALL ON TABLE acp.onlineresource FROM bradley;
GRANT ALL ON TABLE acp.onlineresource TO bradley;
GRANT SELECT ON TABLE acp.onlineresource TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.onlineresource TO pts_write;
GRANT ALL ON TABLE acp.onlineresource TO pts_admin;


--
-- TOC entry 7033 (class 0 OID 0)
-- Dependencies: 652
-- Name: TABLE personpositionlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.personpositionlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.personpositionlist FROM bradley;
GRANT ALL ON TABLE acp.personpositionlist TO bradley;
GRANT SELECT ON TABLE acp.personpositionlist TO pts_read;
GRANT ALL ON TABLE acp.personpositionlist TO pts_admin;


--
-- TOC entry 7034 (class 0 OID 0)
-- Dependencies: 653
-- Name: TABLE postalcodelist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.postalcodelist FROM PUBLIC;
REVOKE ALL ON TABLE acp.postalcodelist FROM bradley;
GRANT ALL ON TABLE acp.postalcodelist TO bradley;
GRANT SELECT ON TABLE acp.postalcodelist TO pts_read;
GRANT ALL ON TABLE acp.postalcodelist TO pts_admin;


--
-- TOC entry 7038 (class 0 OID 0)
-- Dependencies: 654
-- Name: TABLE productcontact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productcontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.productcontact FROM bradley;
GRANT ALL ON TABLE acp.productcontact TO bradley;
GRANT SELECT ON TABLE acp.productcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productcontact TO pts_write;
GRANT ALL ON TABLE acp.productcontact TO pts_admin;


--
-- TOC entry 7039 (class 0 OID 0)
-- Dependencies: 655
-- Name: TABLE productallcontacts; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productallcontacts FROM PUBLIC;
REVOKE ALL ON TABLE acp.productallcontacts FROM bradley;
GRANT ALL ON TABLE acp.productallcontacts TO bradley;
GRANT SELECT ON TABLE acp.productallcontacts TO pts_read;
GRANT ALL ON TABLE acp.productallcontacts TO pts_admin;


--
-- TOC entry 7040 (class 0 OID 0)
-- Dependencies: 656
-- Name: TABLE productcontactlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.productcontactlist FROM bradley;
GRANT ALL ON TABLE acp.productcontactlist TO bradley;
GRANT SELECT ON TABLE acp.productcontactlist TO pts_read;
GRANT ALL ON TABLE acp.productcontactlist TO pts_admin;


--
-- TOC entry 7041 (class 0 OID 0)
-- Dependencies: 657
-- Name: TABLE productfeature; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productfeature FROM PUBLIC;
REVOKE ALL ON TABLE acp.productfeature FROM bradley;
GRANT ALL ON TABLE acp.productfeature TO bradley;
GRANT SELECT ON TABLE acp.productfeature TO pts_read;
GRANT ALL ON TABLE acp.productfeature TO pts_admin;


--
-- TOC entry 7042 (class 0 OID 0)
-- Dependencies: 658
-- Name: TABLE productgrouplist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productgrouplist FROM PUBLIC;
REVOKE ALL ON TABLE acp.productgrouplist FROM bradley;
GRANT ALL ON TABLE acp.productgrouplist TO bradley;
GRANT SELECT ON TABLE acp.productgrouplist TO pts_read;
GRANT ALL ON TABLE acp.productgrouplist TO pts_admin;


--
-- TOC entry 7043 (class 0 OID 0)
-- Dependencies: 659
-- Name: TABLE productkeywordlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productkeywordlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.productkeywordlist FROM bradley;
GRANT ALL ON TABLE acp.productkeywordlist TO bradley;
GRANT SELECT ON TABLE acp.productkeywordlist TO pts_read;
GRANT ALL ON TABLE acp.productkeywordlist TO pts_admin;


--
-- TOC entry 7044 (class 0 OID 0)
-- Dependencies: 660
-- Name: TABLE productlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.productlist FROM bradley;
GRANT ALL ON TABLE acp.productlist TO bradley;
GRANT SELECT ON TABLE acp.productlist TO pts_read;
GRANT ALL ON TABLE acp.productlist TO pts_admin;


--
-- TOC entry 7045 (class 0 OID 0)
-- Dependencies: 661
-- Name: TABLE productmetadata; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productmetadata FROM PUBLIC;
REVOKE ALL ON TABLE acp.productmetadata FROM bradley;
GRANT ALL ON TABLE acp.productmetadata TO bradley;
GRANT SELECT ON TABLE acp.productmetadata TO pts_read;
GRANT ALL ON TABLE acp.productmetadata TO pts_admin;


--
-- TOC entry 7051 (class 0 OID 0)
-- Dependencies: 662
-- Name: TABLE productstatus; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productstatus FROM PUBLIC;
REVOKE ALL ON TABLE acp.productstatus FROM bradley;
GRANT ALL ON TABLE acp.productstatus TO bradley;
GRANT SELECT ON TABLE acp.productstatus TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productstatus TO pts_write;
GRANT ALL ON TABLE acp.productstatus TO pts_admin;


--
-- TOC entry 7057 (class 0 OID 0)
-- Dependencies: 663
-- Name: TABLE productstep; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.productstep FROM PUBLIC;
REVOKE ALL ON TABLE acp.productstep FROM bradley;
GRANT ALL ON TABLE acp.productstep TO bradley;
GRANT SELECT ON TABLE acp.productstep TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.productstep TO pts_write;
GRANT ALL ON TABLE acp.productstep TO pts_admin;


--
-- TOC entry 7062 (class 0 OID 0)
-- Dependencies: 664
-- Name: TABLE progress; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.progress FROM PUBLIC;
REVOKE ALL ON TABLE acp.progress FROM bradley;
GRANT ALL ON TABLE acp.progress TO bradley;
GRANT SELECT ON TABLE acp.progress TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.progress TO pts_write;
GRANT ALL ON TABLE acp.progress TO pts_admin;


--
-- TOC entry 7064 (class 0 OID 0)
-- Dependencies: 665
-- Name: TABLE projectadmin; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectadmin FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectadmin FROM bradley;
GRANT ALL ON TABLE acp.projectadmin TO bradley;
GRANT SELECT ON TABLE acp.projectadmin TO pts_read;
GRANT ALL ON TABLE acp.projectadmin TO pts_admin;


--
-- TOC entry 7065 (class 0 OID 0)
-- Dependencies: 666
-- Name: TABLE projectagreementnumbers; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectagreementnumbers FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectagreementnumbers FROM bradley;
GRANT ALL ON TABLE acp.projectagreementnumbers TO bradley;
GRANT SELECT ON TABLE acp.projectagreementnumbers TO pts_read;
GRANT ALL ON TABLE acp.projectagreementnumbers TO pts_admin;


--
-- TOC entry 7066 (class 0 OID 0)
-- Dependencies: 667
-- Name: TABLE projectallcontacts; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectallcontacts FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectallcontacts FROM bradley;
GRANT ALL ON TABLE acp.projectallcontacts TO bradley;
GRANT SELECT ON TABLE acp.projectallcontacts TO pts_read;
GRANT ALL ON TABLE acp.projectallcontacts TO pts_admin;


--
-- TOC entry 7068 (class 0 OID 0)
-- Dependencies: 668
-- Name: TABLE projectawardinfo; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectawardinfo FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectawardinfo FROM bradley;
GRANT ALL ON TABLE acp.projectawardinfo TO bradley;
GRANT SELECT ON TABLE acp.projectawardinfo TO pts_read;
GRANT ALL ON TABLE acp.projectawardinfo TO pts_admin;


--
-- TOC entry 7069 (class 0 OID 0)
-- Dependencies: 669
-- Name: TABLE projectcatalog; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectcatalog FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectcatalog FROM bradley;
GRANT ALL ON TABLE acp.projectcatalog TO bradley;
GRANT SELECT ON TABLE acp.projectcatalog TO pts_read;
GRANT ALL ON TABLE acp.projectcatalog TO pts_admin;


--
-- TOC entry 7075 (class 0 OID 0)
-- Dependencies: 670
-- Name: TABLE projectcomment; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectcomment FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectcomment FROM bradley;
GRANT ALL ON TABLE acp.projectcomment TO bradley;
GRANT SELECT ON TABLE acp.projectcomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectcomment TO pts_write;
GRANT ALL ON TABLE acp.projectcomment TO pts_admin;


--
-- TOC entry 7076 (class 0 OID 0)
-- Dependencies: 671
-- Name: TABLE projectcontactfull; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectcontactfull FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectcontactfull FROM bradley;
GRANT ALL ON TABLE acp.projectcontactfull TO bradley;
GRANT SELECT ON TABLE acp.projectcontactfull TO pts_read;
GRANT ALL ON TABLE acp.projectcontactfull TO pts_admin;


--
-- TOC entry 7077 (class 0 OID 0)
-- Dependencies: 672
-- Name: TABLE projectcontactlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectcontactlist FROM bradley;
GRANT ALL ON TABLE acp.projectcontactlist TO bradley;
GRANT SELECT ON TABLE acp.projectcontactlist TO pts_read;
GRANT ALL ON TABLE acp.projectcontactlist TO pts_admin;


--
-- TOC entry 7078 (class 0 OID 0)
-- Dependencies: 673
-- Name: TABLE projectfeature; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectfeature FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectfeature FROM bradley;
GRANT ALL ON TABLE acp.projectfeature TO bradley;
GRANT SELECT ON TABLE acp.projectfeature TO pts_read;
GRANT ALL ON TABLE acp.projectfeature TO pts_admin;


--
-- TOC entry 7079 (class 0 OID 0)
-- Dependencies: 674
-- Name: TABLE projectfunderlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectfunderlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectfunderlist FROM bradley;
GRANT ALL ON TABLE acp.projectfunderlist TO bradley;
GRANT SELECT ON TABLE acp.projectfunderlist TO pts_read;
GRANT ALL ON TABLE acp.projectfunderlist TO pts_admin;


--
-- TOC entry 7080 (class 0 OID 0)
-- Dependencies: 675
-- Name: TABLE projectfunding; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectfunding FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectfunding FROM bradley;
GRANT ALL ON TABLE acp.projectfunding TO bradley;
GRANT SELECT ON TABLE acp.projectfunding TO pts_read;
GRANT SELECT ON TABLE acp.projectfunding TO pts_write;
GRANT ALL ON TABLE acp.projectfunding TO pts_admin;


--
-- TOC entry 7082 (class 0 OID 0)
-- Dependencies: 676
-- Name: TABLE projectgnis; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectgnis FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectgnis FROM bradley;
GRANT ALL ON TABLE acp.projectgnis TO bradley;
GRANT SELECT ON TABLE acp.projectgnis TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectgnis TO pts_write;
GRANT ALL ON TABLE acp.projectgnis TO pts_admin;


--
-- TOC entry 7086 (class 0 OID 0)
-- Dependencies: 677
-- Name: TABLE projectitis; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectitis FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectitis FROM bradley;
GRANT ALL ON TABLE acp.projectitis TO bradley;
GRANT SELECT ON TABLE acp.projectitis TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.projectitis TO pts_write;
GRANT ALL ON TABLE acp.projectitis TO pts_admin;


--
-- TOC entry 7087 (class 0 OID 0)
-- Dependencies: 678
-- Name: TABLE projectkeywordlist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectkeywordlist FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectkeywordlist FROM bradley;
GRANT ALL ON TABLE acp.projectkeywordlist TO bradley;
GRANT SELECT ON TABLE acp.projectkeywordlist TO pts_read;
GRANT ALL ON TABLE acp.projectkeywordlist TO pts_admin;


--
-- TOC entry 7088 (class 0 OID 0)
-- Dependencies: 679
-- Name: TABLE projectkeywords; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectkeywords FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectkeywords FROM bradley;
GRANT ALL ON TABLE acp.projectkeywords TO bradley;
GRANT SELECT ON TABLE acp.projectkeywords TO pts_read;
GRANT ALL ON TABLE acp.projectkeywords TO pts_admin;


--
-- TOC entry 7089 (class 0 OID 0)
-- Dependencies: 680
-- Name: TABLE projectmetadata; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.projectmetadata FROM PUBLIC;
REVOKE ALL ON TABLE acp.projectmetadata FROM bradley;
GRANT ALL ON TABLE acp.projectmetadata TO bradley;
GRANT SELECT ON TABLE acp.projectmetadata TO pts_read;
GRANT ALL ON TABLE acp.projectmetadata TO pts_admin;


--
-- TOC entry 7093 (class 0 OID 0)
-- Dependencies: 681
-- Name: TABLE purchaserequest; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.purchaserequest FROM PUBLIC;
REVOKE ALL ON TABLE acp.purchaserequest FROM bradley;
GRANT ALL ON TABLE acp.purchaserequest TO bradley;
GRANT SELECT ON TABLE acp.purchaserequest TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.purchaserequest TO pts_write;
GRANT ALL ON TABLE acp.purchaserequest TO pts_admin;


--
-- TOC entry 7101 (class 0 OID 0)
-- Dependencies: 682
-- Name: TABLE reminder; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.reminder FROM PUBLIC;
REVOKE ALL ON TABLE acp.reminder FROM bradley;
GRANT ALL ON TABLE acp.reminder TO bradley;
GRANT SELECT ON TABLE acp.reminder TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.reminder TO pts_write;
GRANT ALL ON TABLE acp.reminder TO pts_admin;


--
-- TOC entry 7104 (class 0 OID 0)
-- Dependencies: 683
-- Name: TABLE remindercontact; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.remindercontact FROM PUBLIC;
REVOKE ALL ON TABLE acp.remindercontact FROM bradley;
GRANT ALL ON TABLE acp.remindercontact TO bradley;
GRANT SELECT ON TABLE acp.remindercontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.remindercontact TO pts_write;
GRANT ALL ON TABLE acp.remindercontact TO pts_admin;


--
-- TOC entry 7105 (class 0 OID 0)
-- Dependencies: 684
-- Name: TABLE shortprojectsummary; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.shortprojectsummary FROM PUBLIC;
REVOKE ALL ON TABLE acp.shortprojectsummary FROM bradley;
GRANT ALL ON TABLE acp.shortprojectsummary TO bradley;
GRANT SELECT ON TABLE acp.shortprojectsummary TO pts_read;
GRANT ALL ON TABLE acp.shortprojectsummary TO pts_admin;


--
-- TOC entry 7106 (class 0 OID 0)
-- Dependencies: 685
-- Name: TABLE statelist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.statelist FROM PUBLIC;
REVOKE ALL ON TABLE acp.statelist FROM bradley;
GRANT ALL ON TABLE acp.statelist TO bradley;
GRANT SELECT ON TABLE acp.statelist TO pts_read;
GRANT ALL ON TABLE acp.statelist TO pts_admin;


--
-- TOC entry 7107 (class 0 OID 0)
-- Dependencies: 686
-- Name: TABLE statuslist; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.statuslist FROM PUBLIC;
REVOKE ALL ON TABLE acp.statuslist FROM bradley;
GRANT ALL ON TABLE acp.statuslist TO bradley;
GRANT SELECT ON TABLE acp.statuslist TO pts_read;
GRANT ALL ON TABLE acp.statuslist TO pts_admin;


--
-- TOC entry 7109 (class 0 OID 0)
-- Dependencies: 687
-- Name: TABLE task; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.task FROM PUBLIC;
REVOKE ALL ON TABLE acp.task FROM bradley;
GRANT ALL ON TABLE acp.task TO bradley;
GRANT SELECT ON TABLE acp.task TO pts_read;
GRANT ALL ON TABLE acp.task TO pts_admin;


--
-- TOC entry 7112 (class 0 OID 0)
-- Dependencies: 688
-- Name: TABLE timeline; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.timeline FROM PUBLIC;
REVOKE ALL ON TABLE acp.timeline FROM bradley;
GRANT ALL ON TABLE acp.timeline TO bradley;
GRANT SELECT ON TABLE acp.timeline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE acp.timeline TO pts_write;
GRANT ALL ON TABLE acp.timeline TO pts_admin;


--
-- TOC entry 7113 (class 0 OID 0)
-- Dependencies: 689
-- Name: TABLE userinfo; Type: ACL; Schema: acp; Owner: bradley
--

REVOKE ALL ON TABLE acp.userinfo FROM PUBLIC;
REVOKE ALL ON TABLE acp.userinfo FROM bradley;
GRANT ALL ON TABLE acp.userinfo TO bradley;
GRANT SELECT ON TABLE acp.userinfo TO pts_read;
GRANT ALL ON TABLE acp.userinfo TO pts_admin;


-- Completed on 2018-11-07 16:22:52 AKST

--
-- PostgreSQL database dump complete
--
