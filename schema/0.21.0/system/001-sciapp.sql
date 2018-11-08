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
-- Name: sciapp; Type: SCHEMA; Schema: -; Owner: bradley
--

CREATE SCHEMA sciapp;


ALTER SCHEMA sciapp OWNER TO bradley;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 567 (class 1259 OID 61841)
-- Name: address; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.address (
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


ALTER TABLE sciapp.address OWNER TO bradley;

--
-- TOC entry 6750 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.street1; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.street1 IS 'address line 1';


--
-- TOC entry 6751 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.street2; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.street2 IS 'address line 2';


--
-- TOC entry 6752 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.postalcode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.postalcode IS 'varchar for Canadian postal code';


--
-- TOC entry 6753 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.postal4; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.postal4 IS '4 digit zip extension';


--
-- TOC entry 6754 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.stateid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.stateid IS 'state GNIS feature id or GEOnet Names Server Geopolitical Codes id';


--
-- TOC entry 6755 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.countyid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.countyid IS 'county GNIS feature or GEOnet Names Server Geopolitical Codes id';


--
-- TOC entry 6756 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.latitude; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.latitude IS 'WGS84';


--
-- TOC entry 6757 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.longitude; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.longitude IS 'WGS84';


--
-- TOC entry 6758 (class 0 OID 0)
-- Dependencies: 567
-- Name: COLUMN address.priority; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.address.priority IS 'primary, secondary, etc.';


--
-- TOC entry 568 (class 1259 OID 61849)
-- Name: contact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.contact (
    contactid integer DEFAULT nextval('common.contact_contactid_seq'::regclass) NOT NULL,
    comment character varying(250),
    dunsnumber character varying,
    contacttypeid integer NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


ALTER TABLE sciapp.contact OWNER TO bradley;

--
-- TOC entry 6760 (class 0 OID 0)
-- Dependencies: 568
-- Name: COLUMN contact.contacttypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contact.contacttypeid IS 'hatchery, refuge, park, military base';


--
-- TOC entry 6761 (class 0 OID 0)
-- Dependencies: 568
-- Name: COLUMN contact.inactive; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contact.inactive IS 'Indicates the contact status.';


--
-- TOC entry 6762 (class 0 OID 0)
-- Dependencies: 568
-- Name: COLUMN contact.uuid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';


--
-- TOC entry 569 (class 1259 OID 61858)
-- Name: contactcontactgroup; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.contactcontactgroup (
    groupid integer NOT NULL,
    contactid integer NOT NULL,
    positionid integer NOT NULL,
    contactcontactgroupid integer DEFAULT nextval('common.contactcontactgroup_contactcontactgroupid_seq'::regclass) NOT NULL,
    priority smallint NOT NULL,
    CONSTRAINT contactcontactgroup_check CHECK ((NOT (groupid = contactid)))
);


ALTER TABLE sciapp.contactcontactgroup OWNER TO bradley;

--
-- TOC entry 6764 (class 0 OID 0)
-- Dependencies: 569
-- Name: COLUMN contactcontactgroup.positionid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contactcontactgroup.positionid IS 'PK for POSITION';


--
-- TOC entry 6765 (class 0 OID 0)
-- Dependencies: 569
-- Name: COLUMN contactcontactgroup.contactcontactgroupid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contactcontactgroup.contactcontactgroupid IS 'PK';


--
-- TOC entry 570 (class 1259 OID 61863)
-- Name: contactgroup; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.contactgroup (
    contactid integer NOT NULL,
    organization boolean,
    name character varying(100) NOT NULL,
    acronym character varying(7) NOT NULL
);


ALTER TABLE sciapp.contactgroup OWNER TO bradley;

--
-- TOC entry 6767 (class 0 OID 0)
-- Dependencies: 570
-- Name: TABLE contactgroup; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.contactgroup IS 'info for organizations, agencies and their subunits';


--
-- TOC entry 6768 (class 0 OID 0)
-- Dependencies: 570
-- Name: COLUMN contactgroup.organization; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contactgroup.organization IS 'Sepecifies whether contact is considered an organization as defined by business rules';


--
-- TOC entry 6769 (class 0 OID 0)
-- Dependencies: 570
-- Name: COLUMN contactgroup.acronym; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contactgroup.acronym IS 'short acronym identifying unit';


--
-- TOC entry 571 (class 1259 OID 61866)
-- Name: eaddress; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.eaddress (
    eaddressid integer DEFAULT nextval('common.electadd_electaddid_seq'::regclass) NOT NULL,
    contactid integer NOT NULL,
    eaddresstypeid integer NOT NULL,
    uri character varying(250) NOT NULL,
    priority smallint NOT NULL,
    comment character varying(250)
);


ALTER TABLE sciapp.eaddress OWNER TO bradley;

--
-- TOC entry 6771 (class 0 OID 0)
-- Dependencies: 571
-- Name: TABLE eaddress; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.eaddress IS 'electronic address';


--
-- TOC entry 6772 (class 0 OID 0)
-- Dependencies: 571
-- Name: COLUMN eaddress.uri; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.eaddress.uri IS 'uniform resource identifier, e.g. website address';


--
-- TOC entry 572 (class 1259 OID 61873)
-- Name: person; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.person (
    contactid integer NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    middlename character varying,
    suffix character varying,
    jobtitleid integer,
    positionid integer
);


ALTER TABLE sciapp.person OWNER TO bradley;

--
-- TOC entry 6774 (class 0 OID 0)
-- Dependencies: 572
-- Name: COLUMN person.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.person.contactid IS 'PK for PERSON';


--
-- TOC entry 6775 (class 0 OID 0)
-- Dependencies: 572
-- Name: COLUMN person.positionid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.person.positionid IS 'Primary position description for this person';


--
-- TOC entry 573 (class 1259 OID 61879)
-- Name: phone; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.phone (
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


ALTER TABLE sciapp.phone OWNER TO bradley;

--
-- TOC entry 6777 (class 0 OID 0)
-- Dependencies: 573
-- Name: TABLE phone; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.phone IS 'phone numbers, stored without punctuation';


--
-- TOC entry 6778 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.phonetypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.phone.phonetypeid IS 'FK for PHONETYPE';


--
-- TOC entry 6779 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.countryiso; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.phone.countryiso IS 'country code';


--
-- TOC entry 6780 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.areacode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.phone.areacode IS 'area or city code';


--
-- TOC entry 6781 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.phnumber; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.phone.phnumber IS 'main body of phone number';


--
-- TOC entry 6782 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.extension; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.phone.extension IS 'phone number extension';


--
-- TOC entry 6783 (class 0 OID 0)
-- Dependencies: 573
-- Name: COLUMN phone.priority; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.phone.priority IS 'primary,secondary,etc.';


--
-- TOC entry 574 (class 1259 OID 61884)
-- Name: alccstaff; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.alccstaff AS
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
   FROM ((((((sciapp.person
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN sciapp.contactcontactgroup sc ON (((person.contactid = sc.contactid) AND (sc.groupid = 42))))
     JOIN sciapp.contact ON (((contact.contactid = person.contactid) AND (contact.contacttypeid = 5))))
  ORDER BY person.lastname;


ALTER TABLE sciapp.alccstaff OWNER TO bradley;

--
-- TOC entry 575 (class 1259 OID 61889)
-- Name: alccsteeringcommittee; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.alccsteeringcommittee AS
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
   FROM ((((((sciapp.person
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN sciapp.contactcontactgroup sc ON (((person.contactid = sc.contactid) AND (sc.groupid = 42) AND (sc.positionid = ANY (ARRAY[85, 96])))))
     JOIN cvl."position" ON ((sc.positionid = "position".positionid)))
  ORDER BY person.lastname;


ALTER TABLE sciapp.alccsteeringcommittee OWNER TO bradley;

--
-- TOC entry 576 (class 1259 OID 61894)
-- Name: deliverablemod; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.deliverablemod (
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    duedate date NOT NULL,
    receiveddate date,
    sciappinterval interval,
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


ALTER TABLE sciapp.deliverablemod OWNER TO bradley;

--
-- TOC entry 6787 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6788 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6789 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.duedate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.duedate IS 'The date the deliverable is due';


--
-- TOC entry 6790 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.receiveddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.receiveddate IS '***Deprecated use DELIVERABLEMODSTATUS*** Date the deliverable is delivered';


--
-- TOC entry 6791 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.sciappinterval; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.sciappinterval IS 'Interval of recurrent deliverables.';


--
-- TOC entry 6792 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.invalid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.invalid IS 'DEPRECATED, Indicates whether deliverable is valid';


--
-- TOC entry 6793 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.publish; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.publish IS 'Designates whether the product may be distributed';


--
-- TOC entry 6794 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.accessdescription; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.accessdescription IS 'Description of constraints to be met when publishing the delivered product';


--
-- TOC entry 6795 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.parentmodificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.parentmodificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6796 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.parentdeliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.parentdeliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6797 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.personid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.personid IS 'FK for person, identifies user responsible for deliverablemod';


--
-- TOC entry 6798 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.startdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.startdate IS 'Starting date for interval in which the deliverable is applicable, i.e. reporting period.';


--
-- TOC entry 6799 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.enddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.enddate IS 'Ending date for interval in which the deliverable is applicable, i.e. reporting period.';


--
-- TOC entry 6800 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.reminder; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.reminder IS 'Whether to enable automated reminders.';


--
-- TOC entry 6801 (class 0 OID 0)
-- Dependencies: 576
-- Name: COLUMN deliverablemod.staffonly; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemod.staffonly IS 'Whether to limit reminders to staff.';


--
-- TOC entry 577 (class 1259 OID 61905)
-- Name: funding; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.funding (
    fundingid integer DEFAULT nextval('common.funding_fundingid_seq'::regclass) NOT NULL,
    fundingtypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    amount numeric NOT NULL,
    modificationid integer NOT NULL,
    projectcontactid integer NOT NULL,
    fundingrecipientid integer
);


ALTER TABLE sciapp.funding OWNER TO bradley;

--
-- TOC entry 6803 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.funding.title IS 'User identifier for funding';


--
-- TOC entry 6804 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.amount; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.funding.amount IS 'Amount of funding associated with modification';


--
-- TOC entry 6805 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.funding.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6806 (class 0 OID 0)
-- Dependencies: 577
-- Name: COLUMN funding.fundingrecipientid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.funding.fundingrecipientid IS 'Entity receiving funds';


--
-- TOC entry 578 (class 1259 OID 61912)
-- Name: invoice; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.invoice (
    invoiceid integer DEFAULT nextval('common.invoice_invoiceid_seq'::regclass) NOT NULL,
    datereceived date NOT NULL,
    title character varying(250) NOT NULL,
    dateclosed date,
    amount numeric NOT NULL,
    fundingid integer NOT NULL,
    projectcontactid integer NOT NULL
);


ALTER TABLE sciapp.invoice OWNER TO bradley;

--
-- TOC entry 6808 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.datereceived; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.invoice.datereceived IS 'date invoice was received';


--
-- TOC entry 6809 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.invoice.title IS 'User identifier for invoice';


--
-- TOC entry 6810 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.dateclosed; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.invoice.dateclosed IS 'Date invoice was processed';


--
-- TOC entry 6811 (class 0 OID 0)
-- Dependencies: 578
-- Name: COLUMN invoice.amount; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.invoice.amount IS 'Totla amount for invoice';


--
-- TOC entry 579 (class 1259 OID 61919)
-- Name: moddocstatus; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.moddocstatus (
    moddocstatusid integer DEFAULT nextval('common.moddocstatus_moddocstatusid_seq'::regclass) NOT NULL,
    modificationid integer,
    moddoctypeid integer,
    moddocstatustypeid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying,
    effectivedate date NOT NULL
);


ALTER TABLE sciapp.moddocstatus OWNER TO bradley;

--
-- TOC entry 6813 (class 0 OID 0)
-- Dependencies: 579
-- Name: TABLE moddocstatus; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.moddocstatus IS 'History of processing status for a modification document';


--
-- TOC entry 6814 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.moddocstatusid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.moddocstatus.moddocstatusid IS 'PK for MODDOCSTATUS';


--
-- TOC entry 6815 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.moddocstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6816 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.moddoctypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.moddocstatus.moddoctypeid IS 'PK for MODDOCTYPE';


--
-- TOC entry 6817 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.moddocstatustypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.moddocstatus.moddocstatustypeid IS 'FK for MODDOCSTATUSTYPE';


--
-- TOC entry 6818 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.moddocstatus.contactid IS 'PK for PERSON';


--
-- TOC entry 6819 (class 0 OID 0)
-- Dependencies: 579
-- Name: COLUMN moddocstatus.effectivedate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.moddocstatus.effectivedate IS 'Date status became effective.';


--
-- TOC entry 580 (class 1259 OID 61926)
-- Name: modification; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.modification (
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


ALTER TABLE sciapp.modification OWNER TO bradley;

--
-- TOC entry 6821 (class 0 OID 0)
-- Dependencies: 580
-- Name: TABLE modification; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.modification IS 'Tracks all modifications to projects,including proposals and agreements';


--
-- TOC entry 6822 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6823 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.personid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.personid IS 'FK for person, identifies user responsible for modification';


--
-- TOC entry 6824 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.title IS 'Short description of modification';


--
-- TOC entry 6825 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.description; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.description IS 'Summary of modification appropriate for publication';


--
-- TOC entry 6826 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.modificationcode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.modificationcode IS 'user identifier for modification, e.g. agreement number';


--
-- TOC entry 6827 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.effectivedate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.effectivedate IS 'Date modification takes effect';


--
-- TOC entry 6828 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.startdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.startdate IS 'Expected Start date of MODIFICATION';


--
-- TOC entry 6829 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.enddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.enddate IS 'Expected End date of MODIFICATION';


--
-- TOC entry 6830 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.datecreated; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.datecreated IS 'Date the modification is created in the database.';


--
-- TOC entry 6831 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.parentmodificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.parentmodificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6832 (class 0 OID 0)
-- Dependencies: 580
-- Name: COLUMN modification.shorttitle; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modification.shorttitle IS 'Truncated title for display';


--
-- TOC entry 581 (class 1259 OID 61934)
-- Name: modstatus; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.modstatus (
    modificationid integer NOT NULL,
    statusid integer NOT NULL,
    effectivedate date NOT NULL,
    modstatusid integer DEFAULT nextval('common.modstatus_modstatusid_seq'::regclass) NOT NULL,
    comment character varying
);


ALTER TABLE sciapp.modstatus OWNER TO bradley;

--
-- TOC entry 6834 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6835 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.statusid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modstatus.statusid IS 'PK for STATUS';


--
-- TOC entry 6836 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.effectivedate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 6837 (class 0 OID 0)
-- Dependencies: 581
-- Name: COLUMN modstatus.modstatusid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modstatus.modstatusid IS 'PK for MODSTATUS, created for convenience when using client applications';


--
-- TOC entry 582 (class 1259 OID 61941)
-- Name: modificationstatus; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.modificationstatus AS
 SELECT modification.modificationid,
    modstatus.modstatusid,
    modstatus.statusid,
    modstatus.effectivedate,
    modstatus.comment,
    modstatus.weight,
    modstatus.status,
    (( SELECT count(deliverablemod.deliverableid) AS count
           FROM sciapp.deliverablemod
          WHERE ((deliverablemod.modificationid = modification.modificationid) AND ((common.deliverable_statusid(deliverablemod.deliverableid) < 40) OR (common.deliverable_statusid(deliverablemod.deliverableid) IS NULL)))))::integer AS incdeliverables
   FROM (sciapp.modification
     JOIN ( SELECT modstatus_1.modificationid,
            modstatus_1.statusid,
            modstatus_1.effectivedate,
            modstatus_1.modstatusid,
            modstatus_1.comment,
            status.weight,
            status.status,
            row_number() OVER (PARTITION BY modstatus_1.modificationid ORDER BY modstatus_1.effectivedate DESC, status.weight DESC) AS rank
           FROM (sciapp.modstatus modstatus_1
             JOIN cvl.status USING (statusid))) modstatus USING (modificationid))
  WHERE (modstatus.rank = 1)
  ORDER BY
        CASE modstatus.statusid
            WHEN 4 THEN 1
            WHEN 8 THEN 2
            WHEN 5 THEN 3
            ELSE 4
        END;


ALTER TABLE sciapp.modificationstatus OWNER TO bradley;

--
-- TOC entry 6839 (class 0 OID 0)
-- Dependencies: 582
-- Name: COLUMN modificationstatus.incdeliverables; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modificationstatus.incdeliverables IS 'Indicates if this modification has incomplete deliverables.';


--
-- TOC entry 583 (class 1259 OID 61946)
-- Name: project; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.project (
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


ALTER TABLE sciapp.project OWNER TO bradley;

--
-- TOC entry 6841 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.orgid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.orgid IS 'Identifies organization that owns the project';


--
-- TOC entry 6842 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.title IS 'Name of project';


--
-- TOC entry 6843 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.fiscalyear; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.fiscalyear IS 'Fiscal year of project code';


--
-- TOC entry 6844 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.number; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.number IS 'Project number component of project code';


--
-- TOC entry 6845 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.startdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.startdate IS 'Date of expected start';


--
-- TOC entry 6846 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.enddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.enddate IS 'Date of expected end';


--
-- TOC entry 6847 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.description; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.description IS 'Short project description';


--
-- TOC entry 6848 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.abstract; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.abstract IS 'Long description of project';


--
-- TOC entry 6849 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.uuid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.uuid IS 'Universally unique identifier for project (from ADiwg specification)';


--
-- TOC entry 6850 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.shorttitle; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.shorttitle IS 'Truncated title. Used in factsheets and other outreach materials.';


--
-- TOC entry 6851 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.exportmetadata; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.exportmetadata IS 'Specifies whether project metadata should be exported.';


--
-- TOC entry 6852 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.supplemental; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.supplemental IS 'Additional information about the project that is not included in the abstract.';


--
-- TOC entry 6853 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.metadataupdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.metadataupdate IS 'Date when metadata was last updated (published).';


--
-- TOC entry 6854 (class 0 OID 0)
-- Dependencies: 583
-- Name: COLUMN project.sciencebaseid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.project.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


--
-- TOC entry 584 (class 1259 OID 61956)
-- Name: projectlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectlist AS
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
   FROM ((((((sciapp.project
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN sciapp.modification USING (projectid))
     LEFT JOIN sciapp.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((sciapp.invoice invoice_1
             JOIN sciapp.funding funding_1 USING (fundingid))
             JOIN sciapp.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (sciapp.funding funding_1
             JOIN sciapp.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid));


ALTER TABLE sciapp.projectlist OWNER TO bradley;

--
-- TOC entry 585 (class 1259 OID 61961)
-- Name: allmoddocstatus; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.allmoddocstatus AS
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
           FROM (((((sciapp.modification m
             LEFT JOIN sciapp.modificationstatus ms USING (modificationid))
             JOIN cvl.modtype mt USING (modtypeid))
             JOIN cvl.modtypemoddoctype USING (modtypeid))
             LEFT JOIN sciapp.moddocstatus mds USING (modificationid, moddoctypeid))
             LEFT JOIN cvl.moddocstatustype mdst USING (moddocstatustypeid))
          WHERE (NOT modtypemoddoctype.inactive)) q
     JOIN sciapp.projectlist p USING (projectid))
  WHERE (q.rank = 1)
  ORDER BY q.modificationid, q.moddoctypeid;


ALTER TABLE sciapp.allmoddocstatus OWNER TO bradley;

--
-- TOC entry 586 (class 1259 OID 61966)
-- Name: audit; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.audit (
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


ALTER TABLE sciapp.audit OWNER TO bradley;

--
-- TOC entry 6858 (class 0 OID 0)
-- Dependencies: 586
-- Name: TABLE audit; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.audit IS 'Tracks changes to data tables';


--
-- TOC entry 6859 (class 0 OID 0)
-- Dependencies: 586
-- Name: COLUMN audit.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.audit.contactid IS 'PK for PERSON';


--
-- TOC entry 587 (class 1259 OID 61973)
-- Name: catalogprojectcategory; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.catalogprojectcategory (
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


ALTER TABLE sciapp.catalogprojectcategory OWNER TO bradley;

--
-- TOC entry 6861 (class 0 OID 0)
-- Dependencies: 587
-- Name: TABLE catalogprojectcategory; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.catalogprojectcategory IS 'Project Categories for the Simple National Project Catalog';


--
-- TOC entry 6862 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.usertype1; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.catalogprojectcategory.usertype1 IS 'Who will benefit from this project.';


--
-- TOC entry 6863 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.usertype2; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.catalogprojectcategory.usertype2 IS 'Who will benefit from this project.';


--
-- TOC entry 6864 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.usertype3; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.catalogprojectcategory.usertype3 IS 'Who will benefit from this project.';


--
-- TOC entry 6865 (class 0 OID 0)
-- Dependencies: 587
-- Name: COLUMN catalogprojectcategory.endusers; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.catalogprojectcategory.endusers IS 'Target Audience/End Users';


--
-- TOC entry 588 (class 1259 OID 61979)
-- Name: contactcostcode; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.contactcostcode (
    costcode character varying NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE sciapp.contactcostcode OWNER TO bradley;

--
-- TOC entry 6867 (class 0 OID 0)
-- Dependencies: 588
-- Name: TABLE contactcostcode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.contactcostcode IS 'List of common costcodes';


--
-- TOC entry 6868 (class 0 OID 0)
-- Dependencies: 588
-- Name: COLUMN contactcostcode.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.contactcostcode.contactid IS 'PK of organization that chargecode belongs to';


--
-- TOC entry 589 (class 1259 OID 61985)
-- Name: contactgrouplist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.contactgrouplist AS
 WITH RECURSIVE grouptree AS (
         SELECT contactgroup.contactid,
            contactgroup.organization,
            contactgroup.name,
            contactgroup.acronym,
            contactcontactgroup.groupid,
            (contactgroup.name)::text AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup.contactid] AS contactids
           FROM (sciapp.contactgroup
             LEFT JOIN sciapp.contactcontactgroup USING (contactid))
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
           FROM ((sciapp.contactgroup cg
             JOIN sciapp.contactcontactgroup ccg USING (contactid))
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


ALTER TABLE sciapp.contactgrouplist OWNER TO bradley;

--
-- TOC entry 590 (class 1259 OID 61990)
-- Name: contactprimaryinfo; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.contactprimaryinfo AS
 SELECT person.contactid,
    (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS name,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM ((sciapp.person
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
UNION
 SELECT cg.contactid,
    cg.name,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM ((sciapp.contactgroup cg
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((cg.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((cg.contactid = e.contactid) AND (e.rank = 1))));


ALTER TABLE sciapp.contactprimaryinfo OWNER TO bradley;

--
-- TOC entry 591 (class 1259 OID 61995)
-- Name: projectcontact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectcontact (
    projectid integer NOT NULL,
    contactid integer NOT NULL,
    roletypeid integer NOT NULL,
    priority smallint NOT NULL,
    contactprojectcode character varying,
    partner boolean DEFAULT false NOT NULL,
    projectcontactid integer DEFAULT nextval('common.projectcontact_projectcontactid_seq'::regclass) NOT NULL,
    reminder boolean
);


ALTER TABLE sciapp.projectcontact OWNER TO bradley;

--
-- TOC entry 6872 (class 0 OID 0)
-- Dependencies: 591
-- Name: TABLE projectcontact; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.projectcontact IS 'Identifies project contacts and roles';


--
-- TOC entry 6873 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.roletypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcontact.roletypeid IS 'PK for ROLETYPE';


--
-- TOC entry 6874 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.contactprojectcode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcontact.contactprojectcode IS 'Project identifier assigned by contact';


--
-- TOC entry 6875 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.projectcontactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcontact.projectcontactid IS 'PK for PROJECTCONTACT';


--
-- TOC entry 6876 (class 0 OID 0)
-- Dependencies: 591
-- Name: COLUMN projectcontact.reminder; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcontact.reminder IS 'Indicates whether the contact is included on reminders notices.';


--
-- TOC entry 592 (class 1259 OID 62003)
-- Name: contactprojectslist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.contactprojectslist AS
 WITH projectcode AS (
         SELECT project.projectid,
            common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS code
           FROM (sciapp.project
             JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
        )
 SELECT (((person.lastname)::text || ', '::text) || (person.firstname)::text) AS name,
    string_agg((projectcode.code)::text, ','::text ORDER BY (projectcode.*)::text) AS projects,
    'no'::text AS isgroup
   FROM ((sciapp.person
     LEFT JOIN sciapp.projectcontact USING (contactid))
     LEFT JOIN projectcode USING (projectid))
  GROUP BY projectcontact.contactid, person.lastname, person.firstname
UNION
 SELECT contactgrouplist.fullname AS name,
    string_agg((projectcode.code)::text, ','::text ORDER BY (projectcode.*)::text) AS projects,
    'yes'::text AS isgroup
   FROM ((sciapp.contactgrouplist
     LEFT JOIN sciapp.projectcontact USING (contactid))
     LEFT JOIN projectcode USING (projectid))
  GROUP BY projectcontact.contactid, contactgrouplist.fullname
  ORDER BY 1;


ALTER TABLE sciapp.contactprojectslist OWNER TO bradley;

--
-- TOC entry 593 (class 1259 OID 62008)
-- Name: costcode; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.costcode (
    costcodeid integer DEFAULT nextval('common.costcode_costcodeid_seq'::regclass) NOT NULL,
    fundingid integer NOT NULL,
    costcode character varying NOT NULL,
    startdate date NOT NULL,
    enddate date
);


ALTER TABLE sciapp.costcode OWNER TO bradley;

--
-- TOC entry 6879 (class 0 OID 0)
-- Dependencies: 593
-- Name: TABLE costcode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.costcode IS 'Costcode associated with funding';


--
-- TOC entry 6880 (class 0 OID 0)
-- Dependencies: 593
-- Name: COLUMN costcode.costcode; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.costcode.costcode IS 'Cost code associated with FUNDING';


--
-- TOC entry 6881 (class 0 OID 0)
-- Dependencies: 593
-- Name: COLUMN costcode.startdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.costcode.startdate IS 'Date from which costcode is active';


--
-- TOC entry 6882 (class 0 OID 0)
-- Dependencies: 593
-- Name: COLUMN costcode.enddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.costcode.enddate IS 'Date after which costcode is invalid';


--
-- TOC entry 594 (class 1259 OID 62015)
-- Name: costcodeinvoice; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.costcodeinvoice (
    costcodeid integer NOT NULL,
    invoiceid integer NOT NULL,
    amount numeric NOT NULL,
    datecharged date NOT NULL,
    costcodeinvoiceid integer DEFAULT nextval('common.costcodeinvoice_costcodeinvoiceid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.costcodeinvoice OWNER TO bradley;

--
-- TOC entry 6884 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN costcodeinvoice.amount; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.costcodeinvoice.amount IS 'Amount charged to specific code';


--
-- TOC entry 6885 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN costcodeinvoice.datecharged; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.costcodeinvoice.datecharged IS 'Date invoice charged to code';


--
-- TOC entry 6886 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN costcodeinvoice.costcodeinvoiceid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.costcodeinvoice.costcodeinvoiceid IS 'PK for costcodeinvoice, created to ease client implementation';


--
-- TOC entry 595 (class 1259 OID 62022)
-- Name: countylist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.countylist AS
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


ALTER TABLE sciapp.countylist OWNER TO bradley;

--
-- TOC entry 596 (class 1259 OID 62026)
-- Name: deliverable; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.deliverable (
    deliverableid integer DEFAULT nextval('common.deliverable_deliverableid_seq'::regclass) NOT NULL,
    deliverabletypeid integer NOT NULL,
    title character varying(250) NOT NULL,
    description character varying NOT NULL,
    code character varying
);


ALTER TABLE sciapp.deliverable OWNER TO bradley;

--
-- TOC entry 6889 (class 0 OID 0)
-- Dependencies: 596
-- Name: TABLE deliverable; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.deliverable IS 'Project deliverables';


--
-- TOC entry 6890 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverable.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6891 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.deliverabletypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverable.deliverabletypeid IS 'PK of DELIVERABLETYPE';


--
-- TOC entry 6892 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverable.title IS 'Short title of sciappliverable';


--
-- TOC entry 6893 (class 0 OID 0)
-- Dependencies: 596
-- Name: COLUMN deliverable.code; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverable.code IS 'Code associated with the deliverable.';


--
-- TOC entry 597 (class 1259 OID 62033)
-- Name: deliverablemodstatus; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.deliverablemodstatus (
    deliverablemodstatusid integer DEFAULT nextval('common.deliverablemodstatus_deliverablemodstatusid_seq'::regclass) NOT NULL,
    deliverablestatusid integer NOT NULL,
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    effectivedate date NOT NULL,
    comment character varying,
    contactid integer NOT NULL
);


ALTER TABLE sciapp.deliverablemodstatus OWNER TO bradley;

--
-- TOC entry 6895 (class 0 OID 0)
-- Dependencies: 597
-- Name: TABLE deliverablemodstatus; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.deliverablemodstatus IS 'Links DELIVERABLEMOD to DELIVERABLESTATUS';


--
-- TOC entry 6896 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.deliverablemodstatusid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemodstatus.deliverablemodstatusid IS 'PK for MODSTATUS, created for convenience when using client applications';


--
-- TOC entry 6897 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.deliverablestatusid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemodstatus.deliverablestatusid IS 'PK for DELIVERABLESTATUS';


--
-- TOC entry 6898 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemodstatus.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6899 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemodstatus.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6900 (class 0 OID 0)
-- Dependencies: 597
-- Name: COLUMN deliverablemodstatus.effectivedate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablemodstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 598 (class 1259 OID 62040)
-- Name: deliverableall; Type: VIEW; Schema: sciapp; Owner: pts_admin
--

CREATE VIEW sciapp.deliverableall AS
 SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.sciappinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dm
          WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly,
    deliverable.code
   FROM (((sciapp.deliverablemod
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN sciapp.deliverable USING (deliverableid));


ALTER TABLE sciapp.deliverableall OWNER TO pts_admin;

--
-- TOC entry 599 (class 1259 OID 62045)
-- Name: deliverablecalendar; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.deliverablecalendar AS
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
   FROM ((((((((sciapp.deliverablemod
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN sciapp.modification USING (modificationid))
     JOIN sciapp.project USING (projectid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN sciapp.deliverable USING (deliverableid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN sciapp.person ON ((deliverablemod.personid = person.contactid)))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dm
          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))));


ALTER TABLE sciapp.deliverablecalendar OWNER TO bradley;

--
-- TOC entry 600 (class 1259 OID 62050)
-- Name: deliverablecomment; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.deliverablecomment (
    deliverableid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    deliverablecommentid integer DEFAULT nextval('common.deliverablecomment_deliverablecommentid_seq'::regclass) NOT NULL,
    datemodified date NOT NULL
);


ALTER TABLE sciapp.deliverablecomment OWNER TO bradley;

--
-- TOC entry 6904 (class 0 OID 0)
-- Dependencies: 600
-- Name: COLUMN deliverablecomment.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablecomment.deliverableid IS 'FK for DELIVERABLE';


--
-- TOC entry 6905 (class 0 OID 0)
-- Dependencies: 600
-- Name: COLUMN deliverablecomment.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablecomment.contactid IS 'FK for PERSON';


--
-- TOC entry 6906 (class 0 OID 0)
-- Dependencies: 600
-- Name: COLUMN deliverablecomment.datemodified; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablecomment.datemodified IS 'Date that the comment was modified.';


--
-- TOC entry 601 (class 1259 OID 62057)
-- Name: deliverablecontact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.deliverablecontact (
    deliverableid integer NOT NULL,
    contactid integer NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    roletypeid integer
);


ALTER TABLE sciapp.deliverablecontact OWNER TO bradley;

--
-- TOC entry 6908 (class 0 OID 0)
-- Dependencies: 601
-- Name: TABLE deliverablecontact; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.deliverablecontact IS 'Identifies contacts for each deliverable.';


--
-- TOC entry 6909 (class 0 OID 0)
-- Dependencies: 601
-- Name: COLUMN deliverablecontact.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablecontact.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6910 (class 0 OID 0)
-- Dependencies: 601
-- Name: COLUMN deliverablecontact.roletypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablecontact.roletypeid IS 'FK for ROLETYPE';


--
-- TOC entry 602 (class 1259 OID 62061)
-- Name: personlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.personlist AS
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
   FROM ((((sciapp.person
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
  ORDER BY person.lastname, person.contactid;


ALTER TABLE sciapp.personlist OWNER TO bradley;

--
-- TOC entry 603 (class 1259 OID 62066)
-- Name: deliverabledue; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM sciapp.deliverablecomment
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
   FROM (((((((((sciapp.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN sciapp.deliverablemod dm USING (deliverableid))
     JOIN sciapp.modification USING (modificationid))
     JOIN sciapp.project USING (projectid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM sciapp.projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN sciapp.personlist ON ((personlist.contactid = projectcontact.contactid)))
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;


ALTER TABLE sciapp.deliverabledue OWNER TO bradley;

--
-- TOC entry 604 (class 1259 OID 62071)
-- Name: deliverablelist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.deliverablelist AS
 SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.sciappinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    modification.projectid
   FROM (((sciapp.deliverablemod
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN sciapp.deliverable USING (deliverableid))
     JOIN sciapp.modification USING (modificationid))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dm
          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))));


ALTER TABLE sciapp.deliverablelist OWNER TO bradley;

--
-- TOC entry 6914 (class 0 OID 0)
-- Dependencies: 604
-- Name: VIEW deliverablelist; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON VIEW sciapp.deliverablelist IS 'List of all valid, non-modified deliverables';


--
-- TOC entry 605 (class 1259 OID 62076)
-- Name: deliverablenotice; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.deliverablenotice (
    deliverablenoticeid integer DEFAULT nextval('common.deliverablenotice_deliverablenoticeid_seq'::regclass) NOT NULL,
    modificationid integer NOT NULL,
    deliverableid integer NOT NULL,
    noticeid integer NOT NULL,
    recipientid integer NOT NULL,
    contactid integer NOT NULL,
    datesent date NOT NULL,
    comment character varying
);


ALTER TABLE sciapp.deliverablenotice OWNER TO bradley;

--
-- TOC entry 6916 (class 0 OID 0)
-- Dependencies: 605
-- Name: TABLE deliverablenotice; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.deliverablenotice IS 'Tracks notices sent to deliverable contacts';


--
-- TOC entry 6917 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.deliverablenoticeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.deliverablenoticeid IS 'DELIVERABLENOTICE PK';


--
-- TOC entry 6918 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6919 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6920 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.noticeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.noticeid IS 'PK for NOTICE';


--
-- TOC entry 6921 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.recipientid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.recipientid IS 'The person that the notice was sent to.';


--
-- TOC entry 6922 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.contactid IS 'PERSON that sent the notice.';


--
-- TOC entry 6923 (class 0 OID 0)
-- Dependencies: 605
-- Name: COLUMN deliverablenotice.datesent; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.deliverablenotice.datesent IS 'Date that the notice was sent.';


--
-- TOC entry 606 (class 1259 OID 62083)
-- Name: modificationcontact; Type: TABLE; Schema: sciapp; Owner: pts_admin
--

CREATE TABLE sciapp.modificationcontact (
    modificationid integer NOT NULL,
    projectcontactid integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE sciapp.modificationcontact OWNER TO pts_admin;

--
-- TOC entry 6925 (class 0 OID 0)
-- Dependencies: 606
-- Name: TABLE modificationcontact; Type: COMMENT; Schema: sciapp; Owner: pts_admin
--

COMMENT ON TABLE sciapp.modificationcontact IS 'Associates project contacts with a modification';


--
-- TOC entry 6926 (class 0 OID 0)
-- Dependencies: 606
-- Name: COLUMN modificationcontact.modificationid; Type: COMMENT; Schema: sciapp; Owner: pts_admin
--

COMMENT ON COLUMN sciapp.modificationcontact.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6927 (class 0 OID 0)
-- Dependencies: 606
-- Name: COLUMN modificationcontact.projectcontactid; Type: COMMENT; Schema: sciapp; Owner: pts_admin
--

COMMENT ON COLUMN sciapp.modificationcontact.projectcontactid IS 'PK for PROJECTCONTACT';


--
-- TOC entry 6928 (class 0 OID 0)
-- Dependencies: 606
-- Name: COLUMN modificationcontact.priority; Type: COMMENT; Schema: sciapp; Owner: pts_admin
--

COMMENT ON COLUMN sciapp.modificationcontact.priority IS 'Priority of the contact';


--
-- TOC entry 607 (class 1259 OID 62086)
-- Name: deliverablereminder; Type: VIEW; Schema: sciapp; Owner: pts_admin
--

CREATE VIEW sciapp.deliverablereminder AS
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
           FROM ((sciapp.modification m
             JOIN sciapp.modificationcontact mc USING (modificationid))
             JOIN sciapp.projectcontact pmc USING (projectcontactid))
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
           FROM (((sciapp.modification m
             LEFT JOIN sciapp.modificationcontact mc USING (modificationid))
             LEFT JOIN sciapp.projectcontact pmc USING (projectcontactid))
             JOIN sciapp.projectcontact pc ON (((m.projectid = pc.projectid) AND (mc.projectcontactid IS NULL))))
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
   FROM ((((((((((((((((sciapp.deliverable d
     JOIN sciapp.deliverablemod dm USING (deliverableid))
     JOIN cvl.deliverabletype dt USING (deliverabletypeid))
     JOIN sciapp.modification USING (modificationid))
     JOIN sciapp.project USING (projectid))
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
             JOIN sciapp.contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[6, 7])))) piemail USING (modificationid))
     LEFT JOIN sciapp.contactprimaryinfo USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (modcontact projectcontact_1
             JOIN sciapp.contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (NOT (projectcontact_1.roletypeid = ANY (ARRAY[6, 7, 5, 13]))))
          GROUP BY projectcontact_1.modificationid) ccemail USING (modificationid))
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (modcontact projectcontact_1
             JOIN sciapp.contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[5, 13])))
          GROUP BY projectcontact_1.modificationid) adminemail USING (modificationid))
     LEFT JOIN sciapp.projectcontact poc ON (((poc.projectid = project.projectid) AND (poc.roletypeid = 12))))
     LEFT JOIN sciapp.person po ON ((poc.contactid = po.contactid)))
     LEFT JOIN sciapp.contactprimaryinfo man ON ((man.contactid = dm.personid)))
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN common.groupschema ON (((project.orgid = groupschema.groupid) AND (NOT ((groupschema.groupschemaid)::text = 'sciapp'::text)) AND ((groupschema.groupschemaid)::name = ANY (current_schemas(false))))))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;


ALTER TABLE sciapp.deliverablereminder OWNER TO pts_admin;

--
-- TOC entry 608 (class 1259 OID 62091)
-- Name: deliverablestatuslist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.deliverablestatuslist AS
 SELECT d.title,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    COALESCE(status.deliverablestatusid, '-1'::integer) AS deliverablestatusid,
    d.deliverableid,
    dm.modificationid
   FROM ((sciapp.deliverable d
     JOIN sciapp.deliverablemod dm USING (deliverableid))
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))));


ALTER TABLE sciapp.deliverablestatuslist OWNER TO bradley;

--
-- TOC entry 609 (class 1259 OID 62096)
-- Name: sciappsteeringcommittee; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.sciappsteeringcommittee AS
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
   FROM ((((((sciapp.person
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN sciapp.contactcontactgroup sc ON (((person.contactid = sc.contactid) AND (sc.groupid = 42) AND (sc.positionid = ANY (ARRAY[85, 96])))))
     JOIN cvl."position" ON ((sc.positionid = "position".positionid)))
  ORDER BY person.lastname;


ALTER TABLE sciapp.sciappsteeringcommittee OWNER TO bradley;

--
-- TOC entry 610 (class 1259 OID 62101)
-- Name: fact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.fact (
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


ALTER TABLE sciapp.fact OWNER TO bradley;

--
-- TOC entry 6933 (class 0 OID 0)
-- Dependencies: 610
-- Name: TABLE fact; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.fact IS 'Data primarily intended for project factsheet';


--
-- TOC entry 6934 (class 0 OID 0)
-- Dependencies: 610
-- Name: COLUMN fact.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fact.title IS 'Condensed title of project';


--
-- TOC entry 611 (class 1259 OID 62108)
-- Name: factfile; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.factfile (
    factid integer NOT NULL,
    fileid integer NOT NULL,
    priority smallint DEFAULT 1 NOT NULL,
    caption character varying
);


ALTER TABLE sciapp.factfile OWNER TO bradley;

--
-- TOC entry 6936 (class 0 OID 0)
-- Dependencies: 611
-- Name: TABLE factfile; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.factfile IS 'Associates logos and images with FACTsheets';


--
-- TOC entry 6937 (class 0 OID 0)
-- Dependencies: 611
-- Name: COLUMN factfile.fileid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.factfile.fileid IS 'PK for FILE';


--
-- TOC entry 6938 (class 0 OID 0)
-- Dependencies: 611
-- Name: COLUMN factfile.caption; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.factfile.caption IS 'Caption associated with document';


--
-- TOC entry 612 (class 1259 OID 62115)
-- Name: file; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.file (
    fileid integer NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    product boolean DEFAULT false NOT NULL
);


ALTER TABLE sciapp.file OWNER TO bradley;

--
-- TOC entry 6940 (class 0 OID 0)
-- Dependencies: 612
-- Name: TABLE file; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.file IS 'File';


--
-- TOC entry 6941 (class 0 OID 0)
-- Dependencies: 612
-- Name: COLUMN file.fileid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.file.fileid IS 'PK for FILE';


--
-- TOC entry 6942 (class 0 OID 0)
-- Dependencies: 612
-- Name: COLUMN file.name; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.file.name IS 'name of document';


--
-- TOC entry 6943 (class 0 OID 0)
-- Dependencies: 612
-- Name: COLUMN file.product; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.file.product IS 'Specifies whether document is a product.';


--
-- TOC entry 613 (class 1259 OID 62122)
-- Name: filecomment; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.filecomment (
    fileid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    datemodified date NOT NULL,
    filecommentid integer DEFAULT nextval('common.filecomment_filecommentid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.filecomment OWNER TO bradley;

--
-- TOC entry 6945 (class 0 OID 0)
-- Dependencies: 613
-- Name: COLUMN filecomment.fileid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.filecomment.fileid IS 'PK for DOCUMENT';


--
-- TOC entry 6946 (class 0 OID 0)
-- Dependencies: 613
-- Name: COLUMN filecomment.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.filecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 614 (class 1259 OID 62129)
-- Name: fileversion; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.fileversion (
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


ALTER TABLE sciapp.fileversion OWNER TO bradley;

--
-- TOC entry 6948 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.fileid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fileversion.fileid IS 'PK for FILE';


--
-- TOC entry 6949 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fileversion.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 6950 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fileversion.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 6951 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.uri; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fileversion.uri IS 'Electronic address of document';


--
-- TOC entry 6952 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.current; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fileversion.current IS 'Identifies current document';


--
-- TOC entry 6953 (class 0 OID 0)
-- Dependencies: 614
-- Name: COLUMN fileversion.uploadstamp; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fileversion.uploadstamp IS 'Timestamp document was uploaded';


--
-- TOC entry 615 (class 1259 OID 62136)
-- Name: fundingcomment; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.fundingcomment (
    fundingcommentid integer DEFAULT nextval('common.fundingcomment_fundingcommentid_seq'::regclass) NOT NULL,
    contactid integer NOT NULL,
    fundingid integer NOT NULL,
    datemodified date NOT NULL,
    comment character varying NOT NULL
);


ALTER TABLE sciapp.fundingcomment OWNER TO bradley;

--
-- TOC entry 6955 (class 0 OID 0)
-- Dependencies: 615
-- Name: COLUMN fundingcomment.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fundingcomment.contactid IS 'FK for PERSON';


--
-- TOC entry 6956 (class 0 OID 0)
-- Dependencies: 615
-- Name: COLUMN fundingcomment.fundingid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fundingcomment.fundingid IS 'FK for FUNDING';


--
-- TOC entry 6957 (class 0 OID 0)
-- Dependencies: 615
-- Name: COLUMN fundingcomment.datemodified; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.fundingcomment.datemodified IS 'Date that the comment was modified.';


--
-- TOC entry 616 (class 1259 OID 62143)
-- Name: fundingtotals; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.fundingtotals AS
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
           FROM sciapp.modification) mod
     LEFT JOIN sciapp.funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(invoice_1.amount) AS amount
           FROM ((sciapp.invoice invoice_1
             JOIN sciapp.funding funding_1 USING (fundingid))
             JOIN sciapp.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY (common.getfiscalyear(modification_1.startdate))) invoice USING (fiscalyear))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(funding_1.amount) AS leveraged
           FROM (sciapp.funding funding_1
             JOIN sciapp.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))
          GROUP BY (common.getfiscalyear(modification_1.startdate))) leveraged USING (fiscalyear))
  ORDER BY mod.fiscalyear;


ALTER TABLE sciapp.fundingtotals OWNER TO bradley;

--
-- TOC entry 617 (class 1259 OID 62148)
-- Name: groupmemberlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.groupmemberlist AS
 SELECT ccg.groupid,
    ccg.contactid,
    ccg.positionid,
    ccg.contactcontactgroupid,
    concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
    ccg.priority
   FROM (sciapp.contactcontactgroup ccg
     JOIN sciapp.person USING (contactid));


ALTER TABLE sciapp.groupmemberlist OWNER TO bradley;

--
-- TOC entry 618 (class 1259 OID 62152)
-- Name: grouppersonfull; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.grouppersonfull AS
 WITH RECURSIVE grouptree AS (
         SELECT contactgroup.contactid AS groupid,
            (contactgroup.name)::text AS fullname,
            contactgroup.acronym,
            contactgroup.name,
            ARRAY[contactgroup.contactid] AS groupids
           FROM (sciapp.contactgroup
             LEFT JOIN sciapp.contactcontactgroup contactcontactgroup_1 USING (contactid))
          WHERE (contactcontactgroup_1.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            ((gt.fullname || ' -> '::text) || (cg.name)::text) AS full_name,
            cg.acronym,
            cg.name,
            array_append(gt.groupids, cg.contactid) AS array_append
           FROM ((sciapp.contactgroup cg
             JOIN sciapp.contactcontactgroup ccg USING (contactid))
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
     JOIN sciapp.contactcontactgroup USING (groupid))
     JOIN cvl."position" USING (positionid))
     JOIN sciapp.person ON ((person.contactid = contactcontactgroup.contactid)));


ALTER TABLE sciapp.grouppersonfull OWNER TO bradley;

--
-- TOC entry 619 (class 1259 OID 62157)
-- Name: grouppersonlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.grouppersonlist AS
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
   FROM (((sciapp.contactcontactgroup
     JOIN sciapp.contact USING (contactid))
     JOIN sciapp.contactgroup ON ((contactgroup.contactid = contactcontactgroup.groupid)))
     JOIN sciapp.person ON ((person.contactid = contactcontactgroup.contactid)));


ALTER TABLE sciapp.grouppersonlist OWNER TO bradley;

--
-- TOC entry 620 (class 1259 OID 62162)
-- Name: invoicecomment; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.invoicecomment (
    invoiceid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    invoicecommentid integer DEFAULT nextval('common.invoicecomment_invoicecommentid_seq'::regclass) NOT NULL,
    datemodified date NOT NULL
);


ALTER TABLE sciapp.invoicecomment OWNER TO bradley;

--
-- TOC entry 6963 (class 0 OID 0)
-- Dependencies: 620
-- Name: COLUMN invoicecomment.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.invoicecomment.contactid IS 'PK for PERSON';


--
-- TOC entry 621 (class 1259 OID 62169)
-- Name: invoicelist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.invoicelist AS
 SELECT costcode.fundingid,
    i.invoiceid,
    i.projectcontactid,
    i.datereceived,
    i.title,
    i.dateclosed,
    i.amount
   FROM ((sciapp.invoice i
     JOIN sciapp.costcodeinvoice USING (invoiceid))
     JOIN sciapp.costcode USING (costcodeid));


ALTER TABLE sciapp.invoicelist OWNER TO bradley;

--
-- TOC entry 622 (class 1259 OID 62173)
-- Name: longprojectsummary; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.longprojectsummary AS
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
           FROM ((((((sciapp.project project_1
             LEFT JOIN sciapp.modification USING (projectid))
             LEFT JOIN sciapp.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
             LEFT JOIN ( SELECT modification_1.projectid,
                    sum(invoice_1.amount) AS amount
                   FROM ((sciapp.invoice invoice_1
                     JOIN sciapp.funding funding_1 USING (fundingid))
                     JOIN sciapp.modification modification_1 USING (modificationid))
                  WHERE (funding_1.fundingtypeid = 1)
                  GROUP BY modification_1.projectid) invoice USING (projectid))
             LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
                    sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
                   FROM (sciapp.funding funding_1
                     JOIN sciapp.modification modification_1 USING (modificationid))
                  WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
             JOIN cvl.status ON ((common.project_status(project_1.projectid) = status.statusid)))
             JOIN sciapp.contactgroup ON ((project_1.orgid = contactgroup.contactid)))) project
     LEFT JOIN ( SELECT projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.projectcontactid,
            row_number() OVER (PARTITION BY projectcontact.projectid, projectcontact.roletypeid ORDER BY projectcontact.priority) AS rank
           FROM sciapp.projectcontact) pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid,
                    contactgroup.organization,
                    contactgroup.name,
                    contactgroup.acronym,
                    contactcontactgroup.groupid,
                    (contactgroup.name)::text AS fullname,
                    NULL::text AS parentname,
                    ARRAY[contactgroup.contactid] AS contactids
                   FROM (sciapp.contactgroup
                     LEFT JOIN sciapp.contactcontactgroup USING (contactid))
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
                   FROM ((sciapp.contactgroup cg_1
                     JOIN sciapp.contactcontactgroup ccg_1 USING (contactid))
                     JOIN grouptree gt ON ((ccg_1.groupid = gt.contactid)))
                )
         SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || cg.fullname), ''::text)) AS fullname
           FROM ((sciapp.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN grouptree cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE sciapp.longprojectsummary OWNER TO bradley;

--
-- TOC entry 623 (class 1259 OID 62178)
-- Name: membergrouplist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.membergrouplist AS
 SELECT ccg.groupid,
    ccg.contactid,
    ccg.positionid,
    ccg.contactcontactgroupid,
    contactgroup.name,
    ccg.priority
   FROM (sciapp.contactcontactgroup ccg
     JOIN sciapp.contactgroup ON ((ccg.groupid = contactgroup.contactid)))
  ORDER BY ccg.priority;


ALTER TABLE sciapp.membergrouplist OWNER TO bradley;

--
-- TOC entry 624 (class 1259 OID 62182)
-- Name: metadatacontact; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.metadatacontact AS
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
           FROM (((((((sciapp.person
             JOIN sciapp.contact con ON ((person.contactid = con.contactid)))
             JOIN cvl.contacttype ct USING (contacttypeid))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN sciapp.contactgrouplist cl ON ((cl.contactid = ccg.groupid)))
             LEFT JOIN sciapp.contact cg ON ((ccg.groupid = cg.contactid)))
             LEFT JOIN cvl."position" pos ON ((ccg.positionid = pos.positionid)))
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM sciapp.eaddress
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
           FROM (((((sciapp.contactgroup cg
             LEFT JOIN sciapp.contact con ON ((cg.contactid = con.contactid)))
             JOIN cvl.contacttype ct USING (contacttypeid))
             LEFT JOIN sciapp.contactgrouplist cl ON ((cl.contactid = cg.contactid)))
             LEFT JOIN sciapp.contact pg ON ((cl.parentgroupid = pg.contactid)))
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri
                   FROM sciapp.eaddress
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
           FROM (sciapp.phone
             JOIN cvl.country USING (countryiso))
          WHERE (phone.phonetypeid = 3)) p ON (((c.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
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
           FROM (sciapp.address
             JOIN cvl.addresstype USING (addresstypeid))) add ON (((c.contactid = add.contactid) AND (add.rank = 1))))
     LEFT JOIN cvl.govunit ON ((add.stateid = govunit.featureid)));


ALTER TABLE sciapp.metadatacontact OWNER TO bradley;

--
-- TOC entry 625 (class 1259 OID 62187)
-- Name: metadatafunding; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.metadatafunding AS
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
   FROM ((((((sciapp.funding f
     JOIN sciapp.modification m USING (modificationid))
     JOIN cvl.fundingtype ft USING (fundingtypeid))
     LEFT JOIN sciapp.projectcontact fun ON ((f.projectcontactid = fun.projectcontactid)))
     JOIN sciapp.contact fc ON ((fun.contactid = fc.contactid)))
     LEFT JOIN sciapp.projectcontact rec ON ((rec.projectcontactid = f.fundingrecipientid)))
     JOIN sciapp.contact rc ON ((rec.contactid = rc.contactid)));


ALTER TABLE sciapp.metadatafunding OWNER TO bradley;

--
-- TOC entry 626 (class 1259 OID 62192)
-- Name: product; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.product (
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


ALTER TABLE sciapp.product OWNER TO bradley;

--
-- TOC entry 6970 (class 0 OID 0)
-- Dependencies: 626
-- Name: TABLE product; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.product IS 'A distributable product produced by a project.';


--
-- TOC entry 6971 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.productid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.productid IS 'PK for PRODUCT';


--
-- TOC entry 6972 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.uuid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.uuid IS 'Universally unique identifier for product';


--
-- TOC entry 6973 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.title IS 'Title of Product';


--
-- TOC entry 6974 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.description; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.description IS 'Short description of product';


--
-- TOC entry 6975 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.abstract; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.abstract IS 'Long description of product';


--
-- TOC entry 6976 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.purpose; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.purpose IS 'A summary of intentions for which the product was created.';


--
-- TOC entry 6977 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.startdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.startdate IS 'Start date for period of validity or relevance';


--
-- TOC entry 6978 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.enddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.enddate IS 'End date for period of validity or relevance';


--
-- TOC entry 6979 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.exportmetadata; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.exportmetadata IS 'Specifies whether product metadata should be exported.';


--
-- TOC entry 6980 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.metadataupdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.metadataupdate IS 'Date when metadata was last updated (published).';


--
-- TOC entry 6981 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.productgroupid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.productgroupid IS 'Identifies the group to which this product belongs.';


--
-- TOC entry 6982 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.isgroup; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.isgroup IS 'Identifies whether the item is a product group.';


--
-- TOC entry 6983 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.uselimitation; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.uselimitation IS 'Limitation affecting the fitness for use of the product. For example, "not to be used for navigation".';


--
-- TOC entry 6984 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.perioddescription; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.perioddescription IS 'Description of the time period';


--
-- TOC entry 6985 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.orgid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.orgid IS 'Identifies organization that owns the product';


--
-- TOC entry 6986 (class 0 OID 0)
-- Dependencies: 626
-- Name: COLUMN product.sciencebaseid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.product.sciencebaseid IS 'The id of the corresponding ScienceBase item.';


--
-- TOC entry 627 (class 1259 OID 62202)
-- Name: productepsg; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productepsg (
    productid integer NOT NULL,
    srid integer NOT NULL
);


ALTER TABLE sciapp.productepsg OWNER TO bradley;

--
-- TOC entry 628 (class 1259 OID 62205)
-- Name: productkeyword; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productkeyword (
    productkeywordid integer DEFAULT nextval('common.productkeyword_productkeywordid_seq'::regclass) NOT NULL,
    keywordid uuid NOT NULL,
    productid integer NOT NULL
);


ALTER TABLE sciapp.productkeyword OWNER TO bradley;

--
-- TOC entry 6989 (class 0 OID 0)
-- Dependencies: 628
-- Name: TABLE productkeyword; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.productkeyword IS 'Identifies product GCMD concepts(keywords).';


--
-- TOC entry 6990 (class 0 OID 0)
-- Dependencies: 628
-- Name: COLUMN productkeyword.productkeywordid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productkeyword.productkeywordid IS 'PK for PRODUCTKEYWORD';


--
-- TOC entry 6991 (class 0 OID 0)
-- Dependencies: 628
-- Name: COLUMN productkeyword.keywordid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productkeyword.keywordid IS 'GCMD concept UUID';


--
-- TOC entry 6992 (class 0 OID 0)
-- Dependencies: 628
-- Name: COLUMN productkeyword.productid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productkeyword.productid IS 'PK for PRODUCT';


--
-- TOC entry 629 (class 1259 OID 62209)
-- Name: productline; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productline (
    productid integer NOT NULL,
    productlineid integer DEFAULT nextval('common.productline_productlineid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE sciapp.productline OWNER TO bradley;

--
-- TOC entry 630 (class 1259 OID 62219)
-- Name: productpoint; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productpoint (
    productid integer NOT NULL,
    productpointid integer DEFAULT nextval('common.productpoint_productpointid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE sciapp.productpoint OWNER TO bradley;

--
-- TOC entry 631 (class 1259 OID 62229)
-- Name: productpolygon; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productpolygon (
    productid integer NOT NULL,
    productpolygonid integer DEFAULT nextval('common.productpolygon_productpolygonid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE sciapp.productpolygon OWNER TO bradley;

--
-- TOC entry 632 (class 1259 OID 62239)
-- Name: productspatialformat; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productspatialformat (
    productid integer NOT NULL,
    spatialformatid integer NOT NULL
);


ALTER TABLE sciapp.productspatialformat OWNER TO bradley;

--
-- TOC entry 633 (class 1259 OID 62242)
-- Name: producttopiccategory; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.producttopiccategory (
    productid integer NOT NULL,
    topiccategoryid integer NOT NULL
);


ALTER TABLE sciapp.producttopiccategory OWNER TO bradley;

--
-- TOC entry 634 (class 1259 OID 62245)
-- Name: productwkt; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productwkt (
    productid integer NOT NULL,
    wkt character varying NOT NULL
);


ALTER TABLE sciapp.productwkt OWNER TO bradley;

--
-- TOC entry 635 (class 1259 OID 62251)
-- Name: metadataproduct; Type: VIEW; Schema: sciapp; Owner: pts_admin
--

CREATE VIEW sciapp.metadataproduct AS
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
    (((((((((((sciapp.product
     LEFT JOIN sciapp.project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg((productkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM (sciapp.productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid))
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (sciapp.producttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((spatialformat.codename)::text, '|'::text) AS spatialformat
           FROM (sciapp.productspatialformat
             JOIN cvl.spatialformat USING (spatialformatid))
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, '|'::text) AS epsgcode
           FROM sciapp.productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '|'::text) AS wkt
           FROM sciapp.productwkt
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
                           FROM sciapp.productpoint
                        UNION
                         SELECT productpolygon.productid,
                            ('polygon-'::text || productpolygon.productpolygonid) AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM sciapp.productpolygon
                        UNION
                         SELECT productline.productid,
                            ('line-'::text || productline.productlineid) AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM sciapp.productline) lg) f
          GROUP BY f.productid) fea USING (productid));


ALTER TABLE sciapp.metadataproduct OWNER TO pts_admin;

--
-- TOC entry 636 (class 1259 OID 62256)
-- Name: projectkeyword; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectkeyword (
    projectid integer NOT NULL,
    keywordid uuid NOT NULL,
    projectkeywordid integer DEFAULT nextval('common.projectkeyword_projectkeywordid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.projectkeyword OWNER TO bradley;

--
-- TOC entry 7001 (class 0 OID 0)
-- Dependencies: 636
-- Name: TABLE projectkeyword; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.projectkeyword IS 'Identify project GCMD concepts(keywords)';


--
-- TOC entry 7002 (class 0 OID 0)
-- Dependencies: 636
-- Name: COLUMN projectkeyword.keywordid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectkeyword.keywordid IS 'GCMD concept UUID';


SET default_with_oids = true;

--
-- TOC entry 637 (class 1259 OID 62260)
-- Name: projectline; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectline (
    projectid integer NOT NULL,
    projectlineid integer DEFAULT nextval('common.projectline_projectlineid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE sciapp.projectline OWNER TO bradley;

--
-- TOC entry 638 (class 1259 OID 62270)
-- Name: projectpoint; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectpoint (
    projectid integer NOT NULL,
    projectpointid integer DEFAULT nextval('common.projectpoint_projectpointid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE sciapp.projectpoint OWNER TO bradley;

--
-- TOC entry 639 (class 1259 OID 62280)
-- Name: projectpolygon; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectpolygon (
    projectid integer NOT NULL,
    projectpolygonid integer DEFAULT nextval('common.projectpolygon_projectpolygonid_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    comment character varying,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857))
);


ALTER TABLE sciapp.projectpolygon OWNER TO bradley;

SET default_with_oids = false;

--
-- TOC entry 640 (class 1259 OID 62290)
-- Name: projectprojectcategory; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectprojectcategory (
    projectid integer NOT NULL,
    projectcategoryid integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE sciapp.projectprojectcategory OWNER TO bradley;

--
-- TOC entry 641 (class 1259 OID 62293)
-- Name: projecttopiccategory; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projecttopiccategory (
    projectid integer NOT NULL,
    topiccategoryid integer NOT NULL
);


ALTER TABLE sciapp.projecttopiccategory OWNER TO bradley;

--
-- TOC entry 642 (class 1259 OID 62296)
-- Name: projectusertype; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectusertype (
    projectid integer DEFAULT nextval('common.project_projectid_seq'::regclass) NOT NULL,
    usertypeid integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE sciapp.projectusertype OWNER TO bradley;

--
-- TOC entry 643 (class 1259 OID 62300)
-- Name: metadataproject; Type: VIEW; Schema: sciapp; Owner: pts_admin
--

CREATE VIEW sciapp.metadataproject AS
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
           FROM sciapp.modification m
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
    (((((((sciapp.project
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((status.statusid = common.project_status(project.projectid))))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((projectkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM (sciapp.projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((usertype.usertype)::text, '|'::text) AS usertype
           FROM (sciapp.projectusertype
             JOIN cvl.usertype USING (usertypeid))
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (sciapp.projecttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectcategory.category)::text, '|'::text) AS projectcategory
           FROM (sciapp.projectprojectcategory
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
                           FROM sciapp.projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            ('polygon-'::text || projectpolygon.projectpolygonid) AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM sciapp.projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            ('line-'::text || projectline.projectlineid) AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM sciapp.projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid));


ALTER TABLE sciapp.metadataproject OWNER TO pts_admin;

--
-- TOC entry 644 (class 1259 OID 62305)
-- Name: modcomment; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.modcomment (
    modificationid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    datemodified date NOT NULL,
    modcommentid integer DEFAULT nextval('common.modcomment_modcommentid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.modcomment OWNER TO bradley;

--
-- TOC entry 7011 (class 0 OID 0)
-- Dependencies: 644
-- Name: COLUMN modcomment.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modcomment.modificationid IS 'FK for MODIFICATION';


--
-- TOC entry 7012 (class 0 OID 0)
-- Dependencies: 644
-- Name: COLUMN modcomment.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modcomment.contactid IS 'PK for PERSON';


--
-- TOC entry 7013 (class 0 OID 0)
-- Dependencies: 644
-- Name: COLUMN modcomment.publish; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modcomment.publish IS 'Indicates whether comment should be included with data exports or displayed in public documents';


--
-- TOC entry 645 (class 1259 OID 62313)
-- Name: modcontact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.modcontact (
    contactid integer NOT NULL,
    modificationid integer NOT NULL,
    modcontacttypeid integer NOT NULL,
    priority smallint NOT NULL
);


ALTER TABLE sciapp.modcontact OWNER TO bradley;

--
-- TOC entry 7015 (class 0 OID 0)
-- Dependencies: 645
-- Name: TABLE modcontact; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.modcontact IS 'Tracks contacts associated with modifications';


--
-- TOC entry 7016 (class 0 OID 0)
-- Dependencies: 645
-- Name: COLUMN modcontact.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modcontact.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 7017 (class 0 OID 0)
-- Dependencies: 645
-- Name: COLUMN modcontact.modcontacttypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.modcontact.modcontacttypeid IS 'Indicates type of contact(internal/external admin,contractor, etc.)';


--
-- TOC entry 646 (class 1259 OID 62316)
-- Name: moddocstatuslist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.moddocstatuslist AS
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
   FROM (sciapp.moddocstatus
     JOIN cvl.moddocstatustype USING (moddocstatustypeid))
  ORDER BY moddocstatus.modificationid, moddocstatus.moddoctypeid, moddocstatus.effectivedate DESC, moddocstatustype.weight DESC;


ALTER TABLE sciapp.moddocstatuslist OWNER TO bradley;

--
-- TOC entry 647 (class 1259 OID 62320)
-- Name: modificationcontactlist; Type: VIEW; Schema: sciapp; Owner: pts_admin
--

CREATE VIEW sciapp.modificationcontactlist AS
 SELECT modification.modificationid,
    string_agg((q.projectcontactid)::text, ','::text) AS modificationcontact
   FROM (sciapp.modification
     LEFT JOIN ( SELECT modificationcontact.modificationid,
            modificationcontact.projectcontactid,
            modificationcontact.priority
           FROM sciapp.modificationcontact
          ORDER BY modificationcontact.modificationid, modificationcontact.priority) q USING (modificationid))
  GROUP BY modification.modificationid;


ALTER TABLE sciapp.modificationcontactlist OWNER TO pts_admin;

--
-- TOC entry 648 (class 1259 OID 62325)
-- Name: modificationlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.modificationlist AS
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
           FROM sciapp.modification mod
          WHERE (m.modificationid = mod.parentmodificationid))) AS ismodified,
    p.modificationcode AS parentcode,
    m.shorttitle
   FROM ((sciapp.modification m
     JOIN cvl.modtype mt USING (modtypeid))
     LEFT JOIN sciapp.modification p ON ((p.modificationid = m.parentmodificationid)));


ALTER TABLE sciapp.modificationlist OWNER TO bradley;

--
-- TOC entry 649 (class 1259 OID 62330)
-- Name: modstatuslist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.modstatuslist AS
 SELECT modification.modificationid,
    modstatus.modstatusid,
    modstatus.statusid,
    modstatus.effectivedate,
    modstatus.comment,
    modstatus.weight
   FROM (sciapp.modification
     JOIN ( SELECT modstatus_1.modificationid,
            modstatus_1.statusid,
            modstatus_1.effectivedate,
            modstatus_1.modstatusid,
            modstatus_1.comment,
            status.weight
           FROM (sciapp.modstatus modstatus_1
             JOIN cvl.status USING (statusid))) modstatus USING (modificationid))
  ORDER BY modstatus.effectivedate DESC, modstatus.weight DESC;


ALTER TABLE sciapp.modstatuslist OWNER TO bradley;

--
-- TOC entry 7022 (class 0 OID 0)
-- Dependencies: 649
-- Name: VIEW modstatuslist; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON VIEW sciapp.modstatuslist IS 'Lists all statuses for each modification with status weight.';


--
-- TOC entry 650 (class 1259 OID 62335)
-- Name: noticesent; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.noticesent AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM sciapp.deliverablecomment
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
   FROM ((((((((((((sciapp.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN ( SELECT deliverablemod.modificationid,
            deliverablemod.deliverableid,
            deliverablemod.duedate,
            deliverablemod.receiveddate,
            deliverablemod.sciappinterval,
            deliverablemod.publish,
            deliverablemod.restricted,
            deliverablemod.accessdescription,
            deliverablemod.parentmodificationid,
            deliverablemod.parentdeliverableid,
            deliverablemod.personid,
            deliverablemod.startdate,
            deliverablemod.enddate
           FROM sciapp.deliverablemod
          WHERE (NOT (EXISTS ( SELECT 1
                   FROM sciapp.deliverablemod dp
                  WHERE ((dp.modificationid = dp.parentmodificationid) AND (dp.deliverableid = dp.parentdeliverableid)))))) dm USING (deliverableid))
     JOIN sciapp.modification USING (modificationid))
     JOIN sciapp.projectlist USING (projectid))
     JOIN sciapp.project USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM sciapp.projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[7]))) projectcontact USING (projectid))
     LEFT JOIN sciapp.personlist USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM sciapp.projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = 5)
          ORDER BY projectcontact_1.priority) focontact USING (projectid))
     LEFT JOIN sciapp.personlist folist ON ((focontact.contactid = folist.contactid)))
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN sciapp.deliverablenotice USING (deliverableid))
     LEFT JOIN cvl.notice USING (noticeid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT COALESCE((status.deliverablestatusid >= 10), false)) AND (
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN (status.deliverablestatusid = 0) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END > '-30'::integer) AND (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod d_1
          WHERE ((dm.modificationid = d_1.parentmodificationid) AND (dm.deliverableid = d_1.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;


ALTER TABLE sciapp.noticesent OWNER TO bradley;

--
-- TOC entry 651 (class 1259 OID 62340)
-- Name: onlineresource; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.onlineresource (
    onlineresourceid integer DEFAULT nextval('common.onlineresource_onlineresourceid_seq'::regclass) NOT NULL,
    onlinefunctionid integer NOT NULL,
    productid integer NOT NULL,
    uri character varying NOT NULL,
    title character varying NOT NULL,
    description character varying(300) NOT NULL
);


ALTER TABLE sciapp.onlineresource OWNER TO bradley;

--
-- TOC entry 7025 (class 0 OID 0)
-- Dependencies: 651
-- Name: TABLE onlineresource; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.onlineresource IS 'Information about accessing on-line resources and services. This may be a website, profile page, GitHub page, etc.';


--
-- TOC entry 7026 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.onlineresourceid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.onlineresource.onlineresourceid IS 'PK for ONLINERESOURCE';


--
-- TOC entry 7027 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.onlinefunctionid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.onlineresource.onlinefunctionid IS 'PK for ONLINEFUNCTION';


--
-- TOC entry 7028 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.productid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.onlineresource.productid IS 'PK for PRODUCT';


--
-- TOC entry 7029 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.uri; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.onlineresource.uri IS 'Location (address) for on-line access using a Uniform Resource Identifier, usually in the form of a Uniform Resource Locator (URL).';


--
-- TOC entry 7030 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.title; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.onlineresource.title IS 'Descriptive title for onlineresource.';


--
-- TOC entry 7031 (class 0 OID 0)
-- Dependencies: 651
-- Name: COLUMN onlineresource.description; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.onlineresource.description IS 'Short description of onlineresource';


--
-- TOC entry 652 (class 1259 OID 62347)
-- Name: personpositionlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.personpositionlist AS
 SELECT "position".positionid,
    "position".title,
    "position".code
   FROM cvl."position"
  WHERE ("position".positionid > 0);


ALTER TABLE sciapp.personpositionlist OWNER TO bradley;

--
-- TOC entry 653 (class 1259 OID 62351)
-- Name: postalcodelist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.postalcodelist AS
 SELECT postalcode.countryiso,
    postalcode.postalcode,
    postalcode.placename,
    postalcode.state,
    postalcode.statecode,
    postalcode.postalcodeid,
    govunit.featureid AS stateid
   FROM (cvl.postalcode
     JOIN cvl.govunit ON (((govunit.countryalpha = postalcode.countryiso) AND (govunit.statealpha = (postalcode.statecode)::bpchar) AND ((govunit.unittype)::text = 'STATE'::text))));


ALTER TABLE sciapp.postalcodelist OWNER TO bradley;

--
-- TOC entry 654 (class 1259 OID 62356)
-- Name: productcontact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productcontact (
    productid integer NOT NULL,
    contactid integer NOT NULL,
    isoroletypeid integer NOT NULL,
    productcontactid integer DEFAULT nextval('common.productcontact_productcontactid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.productcontact OWNER TO bradley;

--
-- TOC entry 7035 (class 0 OID 0)
-- Dependencies: 654
-- Name: TABLE productcontact; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.productcontact IS 'Identifies product contacts and roles';


--
-- TOC entry 7036 (class 0 OID 0)
-- Dependencies: 654
-- Name: COLUMN productcontact.isoroletypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productcontact.isoroletypeid IS 'PK for ISOROLETYPE';


--
-- TOC entry 7037 (class 0 OID 0)
-- Dependencies: 654
-- Name: COLUMN productcontact.productcontactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productcontact.productcontactid IS 'PK for PRODUCTCONTACT';


--
-- TOC entry 655 (class 1259 OID 62360)
-- Name: productallcontacts; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM (sciapp.metadatacontact
             JOIN sciapp.productcontact ON ((metadatacontact."contactId" = productcontact.contactid)))) dt(contactid, productid);


ALTER TABLE sciapp.productallcontacts OWNER TO bradley;

--
-- TOC entry 656 (class 1259 OID 62364)
-- Name: productcontactlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productcontactlist AS
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
           FROM (sciapp.productcontact
             JOIN sciapp.person USING (contactid))
        UNION
         SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            contactgroup.name
           FROM (sciapp.productcontact
             JOIN sciapp.contactgroup USING (contactid))) pc
     JOIN cvl.isoroletype USING (isoroletypeid))
  ORDER BY isoroletype.code;


ALTER TABLE sciapp.productcontactlist OWNER TO bradley;

--
-- TOC entry 657 (class 1259 OID 62369)
-- Name: productfeature; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productfeature AS
 SELECT productpoint.productid,
    ('Point-'::text || productpoint.productpointid) AS id,
    productpoint.name,
    productpoint.comment,
    public.st_asgeojson(productpoint.the_geom, 8) AS geom
   FROM sciapp.productpoint
UNION
 SELECT productpolygon.productid,
    ('Polygon-'::text || productpolygon.productpolygonid) AS id,
    productpolygon.name,
    productpolygon.comment,
    public.st_asgeojson(productpolygon.the_geom, 8) AS geom
   FROM sciapp.productpolygon
UNION
 SELECT productline.productid,
    ('LineString-'::text || productline.productlineid) AS id,
    productline.name,
    productline.comment,
    public.st_asgeojson(productline.the_geom, 8) AS geom
   FROM sciapp.productline;


ALTER TABLE sciapp.productfeature OWNER TO bradley;

--
-- TOC entry 658 (class 1259 OID 62374)
-- Name: productgrouplist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productgrouplist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.isgroup,
    p.productgroupid
   FROM ((sciapp.product p
     LEFT JOIN sciapp.project USING (projectid))
     LEFT JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  WHERE p.isgroup;


ALTER TABLE sciapp.productgrouplist OWNER TO bradley;

--
-- TOC entry 659 (class 1259 OID 62379)
-- Name: productkeywordlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productkeywordlist AS
 SELECT productkeyword.keywordid,
    productkeyword.productid,
    productkeyword.productkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (sciapp.productkeyword
     JOIN gcmd.keyword USING (keywordid));


ALTER TABLE sciapp.productkeywordlist OWNER TO bradley;

--
-- TOC entry 660 (class 1259 OID 62383)
-- Name: productlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productlist AS
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
   FROM (((((sciapp.product p
     LEFT JOIN sciapp.project USING (projectid))
     LEFT JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN sciapp.product pg ON ((p.productgroupid = pg.productid)));


ALTER TABLE sciapp.productlist OWNER TO bradley;

--
-- TOC entry 661 (class 1259 OID 62388)
-- Name: productmetadata; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.productmetadata AS
 SELECT product.productid,
    tc.topiccategory,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt
   FROM ((((sciapp.product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM sciapp.producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((productspatialformat.spatialformatid)::text, ','::text) AS spatialformat
           FROM sciapp.productspatialformat
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, ','::text) AS epsgcode
           FROM sciapp.productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '
|
'::text) AS wkt
           FROM sciapp.productwkt
          GROUP BY productwkt.productid) wkt USING (productid));


ALTER TABLE sciapp.productmetadata OWNER TO bradley;

--
-- TOC entry 662 (class 1259 OID 62393)
-- Name: productstatus; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productstatus (
    productstatusid integer DEFAULT nextval('common.productstatus_productstatusid_seq'::regclass) NOT NULL,
    productid integer NOT NULL,
    datetypeid integer NOT NULL,
    contactid integer NOT NULL,
    effectivedate date NOT NULL,
    comment character varying
);


ALTER TABLE sciapp.productstatus OWNER TO bradley;

--
-- TOC entry 7046 (class 0 OID 0)
-- Dependencies: 662
-- Name: TABLE productstatus; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.productstatus IS 'Status of product';


--
-- TOC entry 7047 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.productstatusid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstatus.productstatusid IS 'PK for PRODUCTSTATUS';


--
-- TOC entry 7048 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.productid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstatus.productid IS 'PK for PRODUCT';


--
-- TOC entry 7049 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.datetypeid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstatus.datetypeid IS 'PK for DATETYPE';


--
-- TOC entry 7050 (class 0 OID 0)
-- Dependencies: 662
-- Name: COLUMN productstatus.effectivedate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstatus.effectivedate IS 'Date of status change';


--
-- TOC entry 663 (class 1259 OID 62400)
-- Name: productstep; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.productstep (
    productstepid integer DEFAULT nextval('common.productstep_productstepid_seq'::regclass) NOT NULL,
    productid integer NOT NULL,
    productcontactid integer NOT NULL,
    description character varying NOT NULL,
    rationale character varying,
    stepdate date NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


ALTER TABLE sciapp.productstep OWNER TO bradley;

--
-- TOC entry 7052 (class 0 OID 0)
-- Dependencies: 663
-- Name: TABLE productstep; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.productstep IS 'Identifies the steps taken when during processing of the product.';


--
-- TOC entry 7053 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.productid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstep.productid IS 'PK for PRODUCT';


--
-- TOC entry 7054 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.rationale; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstep.rationale IS 'Requirement or purpose for the process step.';


--
-- TOC entry 7055 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.stepdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstep.stepdate IS 'Date and time or date at which the process step occurred.
';


--
-- TOC entry 7056 (class 0 OID 0)
-- Dependencies: 663
-- Name: COLUMN productstep.priority; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.productstep.priority IS 'Order of the step';


--
-- TOC entry 664 (class 1259 OID 62408)
-- Name: progress; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.progress (
    progressid integer DEFAULT nextval('common.progress_progressid_seq'::regclass) NOT NULL,
    deliverableid integer NOT NULL,
    percent integer NOT NULL,
    reportdate date NOT NULL,
    comment character varying
);


ALTER TABLE sciapp.progress OWNER TO bradley;

--
-- TOC entry 7058 (class 0 OID 0)
-- Dependencies: 664
-- Name: TABLE progress; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.progress IS 'Indicates progress toward delivery of deliverable';


--
-- TOC entry 7059 (class 0 OID 0)
-- Dependencies: 664
-- Name: COLUMN progress.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.progress.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 7060 (class 0 OID 0)
-- Dependencies: 664
-- Name: COLUMN progress.percent; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.progress.percent IS 'Percent of deliverable completed';


--
-- TOC entry 7061 (class 0 OID 0)
-- Dependencies: 664
-- Name: COLUMN progress.reportdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.progress.reportdate IS 'Date progress reported';


--
-- TOC entry 665 (class 1259 OID 62415)
-- Name: projectadmin; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectadmin AS
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
   FROM (((((((sciapp.person
     JOIN sciapp.contact USING (contactid))
     JOIN sciapp.projectcontact pc ON ((person.contactid = pc.contactid)))
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
           FROM sciapp.phone
          WHERE (phone.phonetypeid = 3)) p ON (((person.contactid = p.contactid) AND (p.rank = 1))))
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM sciapp.eaddress
          WHERE (eaddress.eaddresstypeid = 1)) e ON (((person.contactid = e.contactid) AND (e.rank = 1))))
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
     LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
     JOIN cvl.roletype USING (roletypeid))
  WHERE ((pc.roletypeid = ANY (ARRAY[7, 5, 13, 6])) AND (NOT contact.inactive))
  ORDER BY person.lastname, person.contactid;


ALTER TABLE sciapp.projectadmin OWNER TO bradley;

--
-- TOC entry 7063 (class 0 OID 0)
-- Dependencies: 665
-- Name: VIEW projectadmin; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON VIEW sciapp.projectadmin IS 'Contacts serving in an admin role for projects (i.e. Financial Officer, Primary Contact, Principal Investigator, Grants Admin).';


--
-- TOC entry 666 (class 1259 OID 62420)
-- Name: projectagreementnumbers; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectagreementnumbers AS
 SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    modification.modificationcode AS agreementnumber,
    modification.title AS agreementtitle,
    modification.startdate,
    modification.enddate
   FROM ((sciapp.project
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN sciapp.modification USING (projectid))
  WHERE ((modification.modificationcode IS NOT NULL) AND (modification.modtypeid <> ALL (ARRAY[4, 9, 10])))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE sciapp.projectagreementnumbers OWNER TO bradley;

--
-- TOC entry 667 (class 1259 OID 62425)
-- Name: projectallcontacts; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM (sciapp.metadatacontact
             JOIN sciapp.projectcontact ON ((metadatacontact."contactId" = projectcontact.contactid)))) dt(contactid, projectid);


ALTER TABLE sciapp.projectallcontacts OWNER TO bradley;

--
-- TOC entry 668 (class 1259 OID 62430)
-- Name: projectawardinfo; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectawardinfo AS
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
   FROM (((((((((((((sciapp.project p
     LEFT JOIN sciapp.contactgroup ON ((p.orgid = contactgroup.contactid)))
     LEFT JOIN sciapp.modification USING (projectid))
     LEFT JOIN cvl.status ON ((status.statusid = common.project_status(p.projectid))))
     LEFT JOIN sciapp.funding USING (modificationid))
     LEFT JOIN sciapp.projectcontact pc USING (projectcontactid))
     LEFT JOIN sciapp.projectcontact rpc ON ((rpc.projectcontactid = funding.fundingrecipientid)))
     JOIN sciapp.contactgrouplist rpg ON ((rpc.contactid = rpg.contactid)))
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
           FROM ((((sciapp.projectcontact
             JOIN sciapp.personlist pl USING (contactid))
             JOIN sciapp.contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN sciapp.contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = 7)) pi ON (((p.projectid = pi.projectid) AND (pi.rank = 1) AND (rpg.contactids[1] = pi.contactids[1]))))
     LEFT JOIN sciapp.address add ON (((add.contactid = pi.contactid) AND (add.addresstypeid = 1))))
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
           FROM ((((sciapp.projectcontact
             JOIN sciapp.personlist pl USING (contactid))
             JOIN sciapp.contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN sciapp.contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = ANY (ARRAY[5, 13]))) fc ON (((p.projectid = fc.projectid) AND (fc.rank = 1) AND (rpg.contactids[1] = fc.contactids[1]))))
     LEFT JOIN sciapp.address fadd ON (((fadd.contactid = fc.contactid) AND (fadd.addresstypeid = 1))))
     LEFT JOIN cvl.govunit fg ON ((fg.featureid = fadd.stateid)))
  WHERE ((modification.parentmodificationid IS NULL) AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5])) AND (status.weight >= 30) AND (status.weight <= 60) AND (pc.contactid = p.orgid))
  ORDER BY (common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym));


ALTER TABLE sciapp.projectawardinfo OWNER TO bradley;

--
-- TOC entry 7067 (class 0 OID 0)
-- Dependencies: 668
-- Name: VIEW projectawardinfo; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON VIEW sciapp.projectawardinfo IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';


--
-- TOC entry 669 (class 1259 OID 62435)
-- Name: projectcatalog; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectcatalog AS
 WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (sciapp.contactgroup contactgroup_1
             LEFT JOIN sciapp.contactcontactgroup USING (contactid))
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
           FROM ((sciapp.contactgroup cg
             JOIN sciapp.contactcontactgroup ccg USING (contactid))
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
           FROM (((sciapp.modification
             JOIN sciapp.funding USING (modificationid))
             JOIN sciapp.projectcontact USING (projectcontactid))
             JOIN grouptree USING (contactid))
          WHERE (NOT (funding.fundingtypeid = 4))
          GROUP BY modification.projectid, (common.getfiscalyear(modification.startdate)), grouptree.fullname, projectcontact.contactid
        ), cofund AS (
         SELECT projectcontact.projectid,
            grouptree.fullname,
            row_number() OVER (PARTITION BY projectcontact.projectid) AS rank
           FROM gschema gschema_1,
            (((sciapp.projectcontact
             JOIN sciapp.contactgroup contactgroup_1 USING (contactid))
             JOIN sciapp.contact USING (contactid))
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
                   FROM (((sciapp.deliverablemod
                     JOIN sciapp.deliverable USING (deliverableid))
                     JOIN cvl.deliverabletype USING (deliverabletypeid))
                     JOIN sciapp.modification USING (modificationid))
                  WHERE (((NOT deliverablemod.invalid) OR (NOT (EXISTS ( SELECT 1
                           FROM sciapp.deliverablemod dm
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
           FROM ((sciapp.projectcontact
             JOIN sciapp.contactgroup contactgroup_1 USING (contactid))
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
    ((((((((((sciapp.project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((sciapp.projectcontact pc_1
             JOIN sciapp.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 7))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM sciapp.eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pi USING (projectid))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((sciapp.projectcontact pc_1
             JOIN sciapp.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 6))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM sciapp.eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pc USING (projectid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
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
                   FROM (sciapp.modification
                     JOIN sciapp.funding USING (modificationid))
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
           FROM (sciapp.projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text), ','::text, ''::text) AS name,
            projectpolygon.projectid
           FROM sciapp.projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN sciapp.catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY (common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym));


ALTER TABLE sciapp.projectcatalog OWNER TO bradley;

--
-- TOC entry 670 (class 1259 OID 62440)
-- Name: projectcomment; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectcomment (
    projectid integer NOT NULL,
    contactid integer NOT NULL,
    comment character varying NOT NULL,
    publish boolean NOT NULL,
    stamp timestamp with time zone DEFAULT now() NOT NULL,
    datemodified date NOT NULL,
    projectcommentid integer DEFAULT nextval('common.projectcomment_projectcommentid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.projectcomment OWNER TO bradley;

--
-- TOC entry 7070 (class 0 OID 0)
-- Dependencies: 670
-- Name: TABLE projectcomment; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.projectcomment IS 'Comments for Project';


--
-- TOC entry 7071 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.projectid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcomment.projectid IS 'FK for PROJECT';


--
-- TOC entry 7072 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.contactid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcomment.contactid IS 'PK for PERSON';


--
-- TOC entry 7073 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.publish; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcomment.publish IS 'Indicates whether comment should be included with data exports or displayed in public documents';


--
-- TOC entry 7074 (class 0 OID 0)
-- Dependencies: 670
-- Name: COLUMN projectcomment.stamp; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectcomment.stamp IS 'Timestamp of comment';


--
-- TOC entry 671 (class 1259 OID 62448)
-- Name: projectcontactfull; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectcontactfull AS
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
           FROM (sciapp.projectcontact
             JOIN sciapp.person USING (contactid))
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
           FROM (sciapp.projectcontact
             JOIN sciapp.contactgrouplist USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
     JOIN sciapp.project USING (projectid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY pc.priority;


ALTER TABLE sciapp.projectcontactfull OWNER TO bradley;

--
-- TOC entry 672 (class 1259 OID 62453)
-- Name: projectcontactlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectcontactlist AS
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
           FROM (sciapp.projectcontact
             JOIN sciapp.person USING (contactid))
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
           FROM (sciapp.projectcontact
             JOIN sciapp.contactgroup USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
  ORDER BY pc.priority;


ALTER TABLE sciapp.projectcontactlist OWNER TO bradley;

--
-- TOC entry 673 (class 1259 OID 62458)
-- Name: projectfeature; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectfeature AS
 SELECT projectpoint.projectid,
    ('Point-'::text || projectpoint.projectpointid) AS id,
    projectpoint.name,
    projectpoint.comment,
    public.st_asgeojson(projectpoint.the_geom, 8) AS geom
   FROM sciapp.projectpoint
UNION
 SELECT projectpolygon.projectid,
    ('Polygon-'::text || projectpolygon.projectpolygonid) AS id,
    projectpolygon.name,
    projectpolygon.comment,
    public.st_asgeojson(projectpolygon.the_geom, 8) AS geom
   FROM sciapp.projectpolygon
UNION
 SELECT projectline.projectid,
    ('LineString-'::text || projectline.projectlineid) AS id,
    projectline.name,
    projectline.comment,
    public.st_asgeojson(projectline.the_geom, 8) AS geom
   FROM sciapp.projectline;


ALTER TABLE sciapp.projectfeature OWNER TO bradley;

--
-- TOC entry 674 (class 1259 OID 62463)
-- Name: projectfunderlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectfunderlist AS
 SELECT projectcontactlist.projectcontactid,
    projectcontactlist.projectid,
    projectcontactlist.contactid,
    projectcontactlist.roletypeid,
    projectcontactlist.priority,
    projectcontactlist.contactprojectcode,
    projectcontactlist.partner,
    projectcontactlist.name
   FROM sciapp.projectcontactlist
  WHERE (projectcontactlist.roletypeid = 4)
  ORDER BY projectcontactlist.name;


ALTER TABLE sciapp.projectfunderlist OWNER TO bradley;

--
-- TOC entry 675 (class 1259 OID 62467)
-- Name: projectfunding; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectfunding AS
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
   FROM ((((((sciapp.project
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN sciapp.modification USING (projectid))
     LEFT JOIN sciapp.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((sciapp.invoice invoice_1
             JOIN sciapp.funding funding_1 USING (fundingid))
             JOIN sciapp.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (sciapp.funding funding_1
             JOIN sciapp.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE sciapp.projectfunding OWNER TO bradley;

--
-- TOC entry 676 (class 1259 OID 62472)
-- Name: projectgnis; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectgnis (
    projectid integer NOT NULL,
    gnisid integer NOT NULL
);


ALTER TABLE sciapp.projectgnis OWNER TO bradley;

--
-- TOC entry 7081 (class 0 OID 0)
-- Dependencies: 676
-- Name: TABLE projectgnis; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.projectgnis IS 'Links GNIS to projects';


--
-- TOC entry 677 (class 1259 OID 62475)
-- Name: projectitis; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.projectitis (
    tsn integer NOT NULL,
    projectid integer NOT NULL
);


ALTER TABLE sciapp.projectitis OWNER TO bradley;

--
-- TOC entry 7083 (class 0 OID 0)
-- Dependencies: 677
-- Name: TABLE projectitis; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.projectitis IS 'Links taxonomic identifiers to projects';


--
-- TOC entry 7084 (class 0 OID 0)
-- Dependencies: 677
-- Name: COLUMN projectitis.tsn; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectitis.tsn IS 'FK for ITIS';


--
-- TOC entry 7085 (class 0 OID 0)
-- Dependencies: 677
-- Name: COLUMN projectitis.projectid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.projectitis.projectid IS 'PK for PROJECT';


--
-- TOC entry 678 (class 1259 OID 62478)
-- Name: projectkeywordlist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectkeywordlist AS
 SELECT projectkeyword.keywordid,
    projectkeyword.projectid,
    projectkeyword.projectkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (sciapp.projectkeyword
     JOIN gcmd.keyword USING (keywordid));


ALTER TABLE sciapp.projectkeywordlist OWNER TO bradley;

--
-- TOC entry 679 (class 1259 OID 62482)
-- Name: projectkeywords; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectkeywords AS
 SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    kw.keywords,
    kw.joined
   FROM ((sciapp.project
     JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, ', '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), ', '::text) AS joined
           FROM (sciapp.projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE sciapp.projectkeywords OWNER TO bradley;

--
-- TOC entry 680 (class 1259 OID 62487)
-- Name: projectmetadata; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.projectmetadata AS
 SELECT project.projectid,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory
   FROM (((sciapp.project
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((projectusertype.usertypeid)::text, ','::text) AS usertype
           FROM sciapp.projectusertype
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((projecttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM sciapp.projecttopiccategory
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectprojectcategory.projectcategoryid)::text, ','::text) AS projectcategory
           FROM sciapp.projectprojectcategory
          GROUP BY projectprojectcategory.projectid) pc USING (projectid));


ALTER TABLE sciapp.projectmetadata OWNER TO bradley;

--
-- TOC entry 681 (class 1259 OID 62492)
-- Name: purchaserequest; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.purchaserequest (
    purchaserequest character varying NOT NULL,
    modificationid integer NOT NULL,
    comment character varying,
    purchaserequestid integer DEFAULT nextval('common.purchaserequest_purchaserequestid_seq'::regclass) NOT NULL
);


ALTER TABLE sciapp.purchaserequest OWNER TO bradley;

--
-- TOC entry 7090 (class 0 OID 0)
-- Dependencies: 681
-- Name: TABLE purchaserequest; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.purchaserequest IS 'purchade requests associated with modification';


--
-- TOC entry 7091 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN purchaserequest.purchaserequest; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.purchaserequest.purchaserequest IS 'number of purchase request';


--
-- TOC entry 7092 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN purchaserequest.modificationid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.purchaserequest.modificationid IS 'PK for MODIFICATION';


--
-- TOC entry 682 (class 1259 OID 62499)
-- Name: reminder; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.reminder (
    reminderid integer DEFAULT nextval('common.reminder_reminderid_seq'::regclass) NOT NULL,
    deliverableid integer NOT NULL,
    senddate date NOT NULL,
    message character varying NOT NULL,
    sentdate date NOT NULL,
    dayinterval smallint NOT NULL
);


ALTER TABLE sciapp.reminder OWNER TO bradley;

--
-- TOC entry 7094 (class 0 OID 0)
-- Dependencies: 682
-- Name: TABLE reminder; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.reminder IS 'Tracks notifications to be sent with respect to deilverables';


--
-- TOC entry 7095 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.reminderid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.reminder.reminderid IS 'PK for REMINDER';


--
-- TOC entry 7096 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.deliverableid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.reminder.deliverableid IS 'PK for DELIVERABLE';


--
-- TOC entry 7097 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.senddate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.reminder.senddate IS 'The date to send the reminder';


--
-- TOC entry 7098 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.message; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.reminder.message IS 'Text to be sent as body of the reminder';


--
-- TOC entry 7099 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.sentdate; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.reminder.sentdate IS 'Date the reminder was actually sent';


--
-- TOC entry 7100 (class 0 OID 0)
-- Dependencies: 682
-- Name: COLUMN reminder.dayinterval; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.reminder.dayinterval IS 'Interval in days to repeat reminder';


--
-- TOC entry 683 (class 1259 OID 62506)
-- Name: remindercontact; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.remindercontact (
    reminderid integer NOT NULL,
    contactid integer NOT NULL
);


ALTER TABLE sciapp.remindercontact OWNER TO bradley;

--
-- TOC entry 7102 (class 0 OID 0)
-- Dependencies: 683
-- Name: TABLE remindercontact; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.remindercontact IS 'Contacts associated with a reminder';


--
-- TOC entry 7103 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN remindercontact.reminderid; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.remindercontact.reminderid IS 'PK for REMINDER';


--
-- TOC entry 684 (class 1259 OID 62509)
-- Name: shortprojectsummary; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.shortprojectsummary AS
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
   FROM ((((sciapp.project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN sciapp.projectcontact pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || (cg.name)::text), ''::text)) AS fullname
           FROM ((sciapp.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM sciapp.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN sciapp.contactgroup cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
     JOIN sciapp.contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY project.fiscalyear, project.number;


ALTER TABLE sciapp.shortprojectsummary OWNER TO bradley;

--
-- TOC entry 685 (class 1259 OID 62514)
-- Name: statelist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.statelist AS
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


ALTER TABLE sciapp.statelist OWNER TO bradley;

--
-- TOC entry 686 (class 1259 OID 62518)
-- Name: statuslist; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.statuslist AS
 SELECT s.statusid,
    m.modtypeid,
    s.code,
    s.status,
    s.description,
    s.weight
   FROM (cvl.status s
     JOIN cvl.modtypestatus m USING (statusid));


ALTER TABLE sciapp.statuslist OWNER TO bradley;

--
-- TOC entry 687 (class 1259 OID 62522)
-- Name: task; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.task AS
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
   FROM ((((((sciapp.deliverablemod
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
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.taskstatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (modificationid, deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (sciapp.deliverablemodstatus
             JOIN cvl.taskstatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (modificationid, deliverableid))
     JOIN sciapp.deliverable USING (deliverableid))
     JOIN sciapp.person ON ((deliverablemod.personid = person.contactid)))
     JOIN sciapp.modification USING (modificationid))
     JOIN sciapp.projectlist USING (projectid))
  WHERE ((deliverable.deliverabletypeid = ANY (ARRAY[4, 7])) AND (NOT (EXISTS ( SELECT 1
           FROM sciapp.deliverablemod dm
          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))))
  ORDER BY deliverablemod.duedate DESC;


ALTER TABLE sciapp.task OWNER TO bradley;

--
-- TOC entry 7108 (class 0 OID 0)
-- Dependencies: 687
-- Name: VIEW task; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON VIEW sciapp.task IS 'Lists all tasks that are not invalid or modified';


--
-- TOC entry 688 (class 1259 OID 62527)
-- Name: timeline; Type: TABLE; Schema: sciapp; Owner: bradley
--

CREATE TABLE sciapp.timeline (
    timelineid integer DEFAULT nextval('common.timeline_timelineid_seq'::regclass) NOT NULL,
    factid integer NOT NULL,
    description character varying NOT NULL,
    startdate date NOT NULL,
    enddate date
);


ALTER TABLE sciapp.timeline OWNER TO bradley;

--
-- TOC entry 7110 (class 0 OID 0)
-- Dependencies: 688
-- Name: TABLE timeline; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON TABLE sciapp.timeline IS 'Project timeline associated with factsheet';


--
-- TOC entry 7111 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN timeline.description; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON COLUMN sciapp.timeline.description IS 'Timeline entry';


--
-- TOC entry 689 (class 1259 OID 62534)
-- Name: userinfo; Type: VIEW; Schema: sciapp; Owner: bradley
--

CREATE VIEW sciapp.userinfo AS
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
     JOIN sciapp.contactgroup ON ((groupschema.groupid = contactgroup.contactid)))
     JOIN sciapp.person ON ((logingroupschema.contactid = person.contactid)))
  WHERE ((logingroupschema.groupschemaid)::name = ANY (current_schemas(false)));


ALTER TABLE sciapp.userinfo OWNER TO bradley;

--
-- TOC entry 6023 (class 2606 OID 64674)
-- Name: address_contactid_addresstypeid_priority_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.address
    ADD CONSTRAINT address_contactid_addresstypeid_priority_key UNIQUE (contactid, addresstypeid, priority);


--
-- TOC entry 7114 (class 0 OID 0)
-- Dependencies: 6023
-- Name: CONSTRAINT address_contactid_addresstypeid_priority_key ON address; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON CONSTRAINT address_contactid_addresstypeid_priority_key ON sciapp.address IS 'Combination of addresstype and priority must be unique for each contact';


--
-- TOC entry 6072 (class 2606 OID 64676)
-- Name: audit_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.audit
    ADD CONSTRAINT audit_pk PRIMARY KEY (auditid);


--
-- TOC entry 6074 (class 2606 OID 64678)
-- Name: catalogprojectcategory_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.catalogprojectcategory
    ADD CONSTRAINT catalogprojectcategory_pkey PRIMARY KEY (projectid);


--
-- TOC entry 6076 (class 2606 OID 64680)
-- Name: chargecode_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcostcode
    ADD CONSTRAINT chargecode_pk PRIMARY KEY (costcode);


--
-- TOC entry 6030 (class 2606 OID 64682)
-- Name: contactcontactgroup_groupid_contactid_positionid_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcontactgroup
    ADD CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key UNIQUE (groupid, contactid, positionid);


--
-- TOC entry 7115 (class 0 OID 0)
-- Dependencies: 6030
-- Name: CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key ON contactcontactgroup; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON CONSTRAINT contactcontactgroup_groupid_contactid_positionid_key ON sciapp.contactcontactgroup IS 'Right now we are not allowing contacts to be assigned multiple positions within a group.';


--
-- TOC entry 6032 (class 2606 OID 64684)
-- Name: contactcontactgroup_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcontactgroup
    ADD CONSTRAINT contactcontactgroup_pk PRIMARY KEY (contactcontactgroupid);


--
-- TOC entry 6083 (class 2606 OID 64686)
-- Name: costcode_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.costcode
    ADD CONSTRAINT costcode_pk PRIMARY KEY (costcodeid);


--
-- TOC entry 6085 (class 2606 OID 64688)
-- Name: costcodeinvoice_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.costcodeinvoice
    ADD CONSTRAINT costcodeinvoice_pk PRIMARY KEY (costcodeinvoiceid);


--
-- TOC entry 6087 (class 2606 OID 64690)
-- Name: deliverable_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverable
    ADD CONSTRAINT deliverable_pk PRIMARY KEY (deliverableid);


--
-- TOC entry 6091 (class 2606 OID 64692)
-- Name: deliverablecomment_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecomment
    ADD CONSTRAINT deliverablecomment_pkey PRIMARY KEY (deliverablecommentid);


--
-- TOC entry 6093 (class 2606 OID 64694)
-- Name: deliverablecontact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecontact
    ADD CONSTRAINT deliverablecontact_pk PRIMARY KEY (deliverableid, contactid);


--
-- TOC entry 6047 (class 2606 OID 64696)
-- Name: deliverablemod_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemod
    ADD CONSTRAINT deliverablemod_pk PRIMARY KEY (modificationid, deliverableid);


--
-- TOC entry 6089 (class 2606 OID 64698)
-- Name: deliverablemodstatus_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemodstatus
    ADD CONSTRAINT deliverablemodstatus_pk PRIMARY KEY (deliverablemodstatusid);


--
-- TOC entry 6095 (class 2606 OID 64700)
-- Name: deliverablenotice_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablenotice
    ADD CONSTRAINT deliverablenotice_pk PRIMARY KEY (deliverablenoticeid);


--
-- TOC entry 6036 (class 2606 OID 64702)
-- Name: electadd_contactid_electaddtypeid_priority_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.eaddress
    ADD CONSTRAINT electadd_contactid_electaddtypeid_priority_key UNIQUE (contactid, eaddresstypeid, priority);


--
-- TOC entry 7116 (class 0 OID 0)
-- Dependencies: 6036
-- Name: CONSTRAINT electadd_contactid_electaddtypeid_priority_key ON eaddress; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON CONSTRAINT electadd_contactid_electaddtypeid_priority_key ON sciapp.eaddress IS 'Combination of electaddtype and priority must be unique for each contact';


--
-- TOC entry 6038 (class 2606 OID 64704)
-- Name: electadd_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.eaddress
    ADD CONSTRAINT electadd_pkey PRIMARY KEY (eaddressid);


--
-- TOC entry 6100 (class 2606 OID 64706)
-- Name: fact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fact
    ADD CONSTRAINT fact_pk PRIMARY KEY (factid);


--
-- TOC entry 6102 (class 2606 OID 64708)
-- Name: factfile_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.factfile
    ADD CONSTRAINT factfile_pk PRIMARY KEY (factid, fileid);


--
-- TOC entry 6104 (class 2606 OID 64710)
-- Name: file_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.file
    ADD CONSTRAINT file_pk PRIMARY KEY (fileid);


--
-- TOC entry 6106 (class 2606 OID 64712)
-- Name: filecomment_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.filecomment
    ADD CONSTRAINT filecomment_pkey PRIMARY KEY (filecommentid);


--
-- TOC entry 6111 (class 2606 OID 64714)
-- Name: fileversion_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT fileversion_pk PRIMARY KEY (fileversionid);


--
-- TOC entry 6051 (class 2606 OID 64716)
-- Name: funding_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.funding
    ADD CONSTRAINT funding_pk PRIMARY KEY (fundingid);


--
-- TOC entry 6115 (class 2606 OID 64718)
-- Name: fundingcomment_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fundingcomment
    ADD CONSTRAINT fundingcomment_pk PRIMARY KEY (fundingcommentid);


--
-- TOC entry 6053 (class 2606 OID 64720)
-- Name: invoice_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.invoice
    ADD CONSTRAINT invoice_pk PRIMARY KEY (invoiceid);


--
-- TOC entry 6117 (class 2606 OID 64722)
-- Name: invoicecomment_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.invoicecomment
    ADD CONSTRAINT invoicecomment_pkey PRIMARY KEY (invoicecommentid);


--
-- TOC entry 6155 (class 2606 OID 64724)
-- Name: modcomment_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcomment
    ADD CONSTRAINT modcomment_pkey PRIMARY KEY (modcommentid);


--
-- TOC entry 6157 (class 2606 OID 64726)
-- Name: modcontact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcontact
    ADD CONSTRAINT modcontact_pk PRIMARY KEY (contactid, modificationid);


--
-- TOC entry 6055 (class 2606 OID 64728)
-- Name: moddocstatus_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.moddocstatus
    ADD CONSTRAINT moddocstatus_pk PRIMARY KEY (moddocstatusid);


--
-- TOC entry 6058 (class 2606 OID 64730)
-- Name: modification_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modification
    ADD CONSTRAINT modification_pk PRIMARY KEY (modificationid);


--
-- TOC entry 6098 (class 2606 OID 64732)
-- Name: modificationcontact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: pts_admin
--

ALTER TABLE ONLY sciapp.modificationcontact
    ADD CONSTRAINT modificationcontact_pk PRIMARY KEY (modificationid, projectcontactid);


--
-- TOC entry 6061 (class 2606 OID 64734)
-- Name: modstatus_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modstatus
    ADD CONSTRAINT modstatus_pk PRIMARY KEY (modstatusid);


--
-- TOC entry 6159 (class 2606 OID 64736)
-- Name: onlineresourceid_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.onlineresource
    ADD CONSTRAINT onlineresourceid_pk PRIMARY KEY (onlineresourceid);


--
-- TOC entry 6040 (class 2606 OID 64738)
-- Name: personid_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.person
    ADD CONSTRAINT personid_pk PRIMARY KEY (contactid);


--
-- TOC entry 6043 (class 2606 OID 64740)
-- Name: phone_contactid_phonetypeid_priority_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.phone
    ADD CONSTRAINT phone_contactid_phonetypeid_priority_key UNIQUE (contactid, phonetypeid, priority);


--
-- TOC entry 7117 (class 0 OID 0)
-- Dependencies: 6043
-- Name: CONSTRAINT phone_contactid_phonetypeid_priority_key ON phone; Type: COMMENT; Schema: sciapp; Owner: bradley
--

COMMENT ON CONSTRAINT phone_contactid_phonetypeid_priority_key ON sciapp.phone IS 'Combination of phonetype and priority must be unique for each contact';


--
-- TOC entry 6045 (class 2606 OID 64742)
-- Name: phone_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.phone
    ADD CONSTRAINT phone_pk PRIMARY KEY (phoneid);


--
-- TOC entry 6026 (class 2606 OID 64744)
-- Name: pk_address; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.address
    ADD CONSTRAINT pk_address PRIMARY KEY (addressid);


--
-- TOC entry 6028 (class 2606 OID 64746)
-- Name: pk_contact; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contact
    ADD CONSTRAINT pk_contact PRIMARY KEY (contactid);


--
-- TOC entry 6034 (class 2606 OID 64748)
-- Name: pk_unit; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactgroup
    ADD CONSTRAINT pk_unit PRIMARY KEY (contactid);


--
-- TOC entry 6121 (class 2606 OID 64750)
-- Name: product_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT product_pk PRIMARY KEY (productid);


--
-- TOC entry 6123 (class 2606 OID 64752)
-- Name: product_sciencebaseid_uidx; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT product_sciencebaseid_uidx UNIQUE (sciencebaseid);


--
-- TOC entry 6162 (class 2606 OID 64754)
-- Name: productcontact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productcontact
    ADD CONSTRAINT productcontact_pk PRIMARY KEY (productcontactid);


--
-- TOC entry 6164 (class 2606 OID 64756)
-- Name: productcontact_productid_roletypeid_contactid_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productcontact
    ADD CONSTRAINT productcontact_productid_roletypeid_contactid_key UNIQUE (productid, isoroletypeid, contactid);


--
-- TOC entry 6125 (class 2606 OID 64758)
-- Name: productepsg_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productepsg
    ADD CONSTRAINT productepsg_pk PRIMARY KEY (productid, srid);


--
-- TOC entry 6127 (class 2606 OID 64760)
-- Name: productkeyword_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productkeyword
    ADD CONSTRAINT productkeyword_pk PRIMARY KEY (productkeywordid);


--
-- TOC entry 6129 (class 2606 OID 64762)
-- Name: productline_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productline
    ADD CONSTRAINT productline_pk PRIMARY KEY (productlineid);


--
-- TOC entry 6131 (class 2606 OID 64764)
-- Name: productpoint_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productpoint
    ADD CONSTRAINT productpoint_pk PRIMARY KEY (productpointid);


--
-- TOC entry 6133 (class 2606 OID 64766)
-- Name: productpolygon_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productpolygon
    ADD CONSTRAINT productpolygon_pk PRIMARY KEY (productpolygonid);


--
-- TOC entry 6135 (class 2606 OID 64768)
-- Name: productspatialformat_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productspatialformat
    ADD CONSTRAINT productspatialformat_pk PRIMARY KEY (productid, spatialformatid);


--
-- TOC entry 6166 (class 2606 OID 64770)
-- Name: productstatus_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productstatus
    ADD CONSTRAINT productstatus_pk PRIMARY KEY (productstatusid);


--
-- TOC entry 6168 (class 2606 OID 64772)
-- Name: productstep_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productstep
    ADD CONSTRAINT productstep_pk PRIMARY KEY (productstepid);


--
-- TOC entry 6137 (class 2606 OID 64774)
-- Name: producttopiccategory_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.producttopiccategory
    ADD CONSTRAINT producttopiccategory_pk PRIMARY KEY (productid, topiccategoryid);


--
-- TOC entry 6170 (class 2606 OID 64776)
-- Name: progress_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.progress
    ADD CONSTRAINT progress_pkey PRIMARY KEY (progressid);


--
-- TOC entry 6064 (class 2606 OID 64778)
-- Name: project_orgid_fiscalyear_number_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.project
    ADD CONSTRAINT project_orgid_fiscalyear_number_key UNIQUE (orgid, fiscalyear, number);


--
-- TOC entry 6066 (class 2606 OID 64780)
-- Name: project_sciencebaseid_uidx; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.project
    ADD CONSTRAINT project_sciencebaseid_uidx UNIQUE (sciencebaseid);


--
-- TOC entry 6172 (class 2606 OID 64782)
-- Name: projectcomment_pkey; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcomment
    ADD CONSTRAINT projectcomment_pkey PRIMARY KEY (projectcommentid);


--
-- TOC entry 6139 (class 2606 OID 64784)
-- Name: projectconcept_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectkeyword
    ADD CONSTRAINT projectconcept_pk PRIMARY KEY (projectkeywordid);


--
-- TOC entry 6079 (class 2606 OID 64786)
-- Name: projectcontact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcontact
    ADD CONSTRAINT projectcontact_pk PRIMARY KEY (projectcontactid);


--
-- TOC entry 6081 (class 2606 OID 64788)
-- Name: projectcontact_projectid_roletypeid_contactid_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcontact
    ADD CONSTRAINT projectcontact_projectid_roletypeid_contactid_key UNIQUE (projectid, roletypeid, contactid);


--
-- TOC entry 6174 (class 2606 OID 64790)
-- Name: projectgnis_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectgnis
    ADD CONSTRAINT projectgnis_pk PRIMARY KEY (projectid);


--
-- TOC entry 6069 (class 2606 OID 64792)
-- Name: projectid; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.project
    ADD CONSTRAINT projectid PRIMARY KEY (projectid);


--
-- TOC entry 6176 (class 2606 OID 64794)
-- Name: projectitis_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectitis
    ADD CONSTRAINT projectitis_pk PRIMARY KEY (tsn, projectid);


--
-- TOC entry 6141 (class 2606 OID 64796)
-- Name: projectkeyword_conceptid_projectid_key; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectkeyword
    ADD CONSTRAINT projectkeyword_conceptid_projectid_key UNIQUE (keywordid, projectid);


--
-- TOC entry 6143 (class 2606 OID 64798)
-- Name: projectline_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectline
    ADD CONSTRAINT projectline_pk PRIMARY KEY (projectlineid);


--
-- TOC entry 6145 (class 2606 OID 64800)
-- Name: projectpoint_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectpoint
    ADD CONSTRAINT projectpoint_pk PRIMARY KEY (projectpointid);


--
-- TOC entry 6147 (class 2606 OID 64802)
-- Name: projectpolygon_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectpolygon
    ADD CONSTRAINT projectpolygon_pk PRIMARY KEY (projectpolygonid);


--
-- TOC entry 6149 (class 2606 OID 64804)
-- Name: projectprojectcategory_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectprojectcategory
    ADD CONSTRAINT projectprojectcategory_pk PRIMARY KEY (projectid, projectcategoryid);


--
-- TOC entry 6151 (class 2606 OID 64806)
-- Name: projecttopiccategory_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projecttopiccategory
    ADD CONSTRAINT projecttopiccategory_pk PRIMARY KEY (projectid, topiccategoryid);


--
-- TOC entry 6153 (class 2606 OID 64808)
-- Name: projectusertype_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectusertype
    ADD CONSTRAINT projectusertype_pk PRIMARY KEY (projectid, usertypeid);


--
-- TOC entry 6178 (class 2606 OID 64810)
-- Name: purchaserequest_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.purchaserequest
    ADD CONSTRAINT purchaserequest_pk PRIMARY KEY (purchaserequestid);


--
-- TOC entry 6180 (class 2606 OID 64812)
-- Name: reminder_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.reminder
    ADD CONSTRAINT reminder_pk PRIMARY KEY (reminderid);


--
-- TOC entry 6182 (class 2606 OID 64814)
-- Name: remindercontact_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.remindercontact
    ADD CONSTRAINT remindercontact_pk PRIMARY KEY (reminderid, contactid);


--
-- TOC entry 6184 (class 2606 OID 64816)
-- Name: timeline_pk; Type: CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.timeline
    ADD CONSTRAINT timeline_pk PRIMARY KEY (timelineid);


--
-- TOC entry 6107 (class 1259 OID 65155)
-- Name: fileversion_deliverable_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_deliverable_idx ON sciapp.fileversion USING btree (fileid, deliverableid);


--
-- TOC entry 6108 (class 1259 OID 65156)
-- Name: fileversion_invoice_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_invoice_idx ON sciapp.fileversion USING btree (fileid, invoiceid);


--
-- TOC entry 6109 (class 1259 OID 65157)
-- Name: fileversion_modification_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_modification_idx ON sciapp.fileversion USING btree (fileid, modificationid);


--
-- TOC entry 6112 (class 1259 OID 65158)
-- Name: fileversion_progress_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_progress_idx ON sciapp.fileversion USING btree (fileid, progressid);


--
-- TOC entry 6113 (class 1259 OID 65159)
-- Name: fileversion_project_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX fileversion_project_idx ON sciapp.fileversion USING btree (fileid, projectid);


--
-- TOC entry 6062 (class 1259 OID 65160)
-- Name: fki_contactgroup_project_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_contactgroup_project_fk ON sciapp.project USING btree (orgid);


--
-- TOC entry 6041 (class 1259 OID 65161)
-- Name: fki_country_phone_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_country_phone_fk ON sciapp.phone USING btree (countryiso);


--
-- TOC entry 6048 (class 1259 OID 65162)
-- Name: fki_deliverable_deliverablemod_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_deliverable_deliverablemod_fk ON sciapp.deliverablemod USING btree (deliverableid);


--
-- TOC entry 6049 (class 1259 OID 65163)
-- Name: fki_deliverablemod_deliverablemod_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_deliverablemod_deliverablemod_fk ON sciapp.deliverablemod USING btree (parentmodificationid, parentdeliverableid);


--
-- TOC entry 6024 (class 1259 OID 65164)
-- Name: fki_govunit_address_state_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_govunit_address_state_fk ON sciapp.address USING btree (stateid);


--
-- TOC entry 6160 (class 1259 OID 65165)
-- Name: fki_isoroletype_productcontact_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_isoroletype_productcontact_fk ON sciapp.productcontact USING btree (isoroletypeid);


--
-- TOC entry 6118 (class 1259 OID 65166)
-- Name: fki_maintenancefrequency_product_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_maintenancefrequency_product_fk ON sciapp.product USING btree (maintenancefrequencyid);


--
-- TOC entry 6096 (class 1259 OID 65167)
-- Name: fki_person_deliverablenotice_user_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_person_deliverablenotice_user_fk ON sciapp.deliverablenotice USING btree (recipientid);


--
-- TOC entry 6119 (class 1259 OID 65168)
-- Name: fki_productgroup_product_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_productgroup_product_fk ON sciapp.product USING btree (productgroupid);


--
-- TOC entry 6056 (class 1259 OID 65169)
-- Name: fki_project_modification_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_project_modification_fk ON sciapp.modification USING btree (projectid);


--
-- TOC entry 6077 (class 1259 OID 65170)
-- Name: fki_roletype_projectcontact_fk; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE INDEX fki_roletype_projectcontact_fk ON sciapp.projectcontact USING btree (roletypeid);


--
-- TOC entry 6059 (class 1259 OID 65171)
-- Name: modstatus_modificationid_statusid_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX modstatus_modificationid_statusid_idx ON sciapp.modstatus USING btree (modificationid, statusid, effectivedate);


--
-- TOC entry 6067 (class 1259 OID 65172)
-- Name: projectcode_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX projectcode_idx ON sciapp.project USING btree (fiscalyear, number, orgid);


--
-- TOC entry 6070 (class 1259 OID 65173)
-- Name: uuid_idx; Type: INDEX; Schema: sciapp; Owner: bradley
--

CREATE UNIQUE INDEX uuid_idx ON sciapp.project USING btree (uuid);


--
-- TOC entry 6316 (class 2620 OID 65223)
-- Name: delete_deliverablemod; Type: TRIGGER; Schema: sciapp; Owner: bradley
--

CREATE TRIGGER delete_deliverablemod AFTER DELETE ON sciapp.deliverablemod FOR EACH ROW EXECUTE PROCEDURE common.delete_deliverable();


--
-- TOC entry 6198 (class 2606 OID 66571)
-- Name: address_phone_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.phone
    ADD CONSTRAINT address_phone_fk FOREIGN KEY (addressid) REFERENCES sciapp.address(addressid);


--
-- TOC entry 6185 (class 2606 OID 66576)
-- Name: addresstype_address_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.address
    ADD CONSTRAINT addresstype_address_fk FOREIGN KEY (addresstypeid) REFERENCES cvl.addresstype(addresstypeid);


--
-- TOC entry 6281 (class 2606 OID 66581)
-- Name: concept_projectconcept_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectkeyword
    ADD CONSTRAINT concept_projectconcept_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);


--
-- TOC entry 6186 (class 2606 OID 66586)
-- Name: contact_address_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.address
    ADD CONSTRAINT contact_address_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6224 (class 2606 OID 66591)
-- Name: contact_contactcostcode_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcostcode
    ADD CONSTRAINT contact_contactcostcode_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6193 (class 2606 OID 66596)
-- Name: contact_contactgroup_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactgroup
    ADD CONSTRAINT contact_contactgroup_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6190 (class 2606 OID 66601)
-- Name: contact_contactunit_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcontactgroup
    ADD CONSTRAINT contact_contactunit_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6237 (class 2606 OID 66606)
-- Name: contact_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecontact
    ADD CONSTRAINT contact_deliverablecontact_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6240 (class 2606 OID 66611)
-- Name: contact_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablenotice
    ADD CONSTRAINT contact_deliverablenotice_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid);


--
-- TOC entry 6194 (class 2606 OID 66616)
-- Name: contact_electadd_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.eaddress
    ADD CONSTRAINT contact_electadd_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6294 (class 2606 OID 66621)
-- Name: contact_modcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcontact
    ADD CONSTRAINT contact_modcontact_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6196 (class 2606 OID 66626)
-- Name: contact_person_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.person
    ADD CONSTRAINT contact_person_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6199 (class 2606 OID 66631)
-- Name: contact_phone_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.phone
    ADD CONSTRAINT contact_phone_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6299 (class 2606 OID 66636)
-- Name: contact_productcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productcontact
    ADD CONSTRAINT contact_productcontact_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6225 (class 2606 OID 66641)
-- Name: contact_projectcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcontact
    ADD CONSTRAINT contact_projectcontact_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6313 (class 2606 OID 66646)
-- Name: contact_remindercontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.remindercontact
    ADD CONSTRAINT contact_remindercontact_fk FOREIGN KEY (contactid) REFERENCES sciapp.contact(contactid) ON DELETE CASCADE;


--
-- TOC entry 6191 (class 2606 OID 66651)
-- Name: contactgroup_contactunit_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcontactgroup
    ADD CONSTRAINT contactgroup_contactunit_fk FOREIGN KEY (groupid) REFERENCES sciapp.contactgroup(contactid);


--
-- TOC entry 6251 (class 2606 OID 66656)
-- Name: contactgroup_fileversion_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT contactgroup_fileversion_fk FOREIGN KEY (contactid) REFERENCES sciapp.contactgroup(contactid);


--
-- TOC entry 6221 (class 2606 OID 66661)
-- Name: contactgroup_project_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.project
    ADD CONSTRAINT contactgroup_project_fk FOREIGN KEY (orgid) REFERENCES sciapp.contactgroup(contactid);


--
-- TOC entry 6189 (class 2606 OID 66666)
-- Name: contacttype_contact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contact
    ADD CONSTRAINT contacttype_contact_fk FOREIGN KEY (contacttypeid) REFERENCES cvl.contacttype(contacttypeid);


--
-- TOC entry 6229 (class 2606 OID 66671)
-- Name: costcode_costcodeinvoice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.costcodeinvoice
    ADD CONSTRAINT costcode_costcodeinvoice_fk FOREIGN KEY (costcodeid) REFERENCES sciapp.costcode(costcodeid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6200 (class 2606 OID 66676)
-- Name: country_phone_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.phone
    ADD CONSTRAINT country_phone_fk FOREIGN KEY (countryiso) REFERENCES cvl.country(countryiso);


--
-- TOC entry 6302 (class 2606 OID 66681)
-- Name: datetype_productstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productstatus
    ADD CONSTRAINT datetype_productstatus_fk FOREIGN KEY (datetypeid) REFERENCES cvl.datetype(datetypeid);


--
-- TOC entry 6235 (class 2606 OID 66686)
-- Name: deliverable_deliverablecomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecomment
    ADD CONSTRAINT deliverable_deliverablecomment_fk FOREIGN KEY (deliverableid) REFERENCES sciapp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6238 (class 2606 OID 66691)
-- Name: deliverable_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecontact
    ADD CONSTRAINT deliverable_deliverablecontact_fk FOREIGN KEY (deliverableid) REFERENCES sciapp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6202 (class 2606 OID 66696)
-- Name: deliverable_deliverablemod_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemod
    ADD CONSTRAINT deliverable_deliverablemod_fk FOREIGN KEY (deliverableid) REFERENCES sciapp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6252 (class 2606 OID 66701)
-- Name: deliverable_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT deliverable_file_fk FOREIGN KEY (deliverableid) REFERENCES sciapp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6306 (class 2606 OID 66706)
-- Name: deliverable_progress_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.progress
    ADD CONSTRAINT deliverable_progress_fk FOREIGN KEY (deliverableid) REFERENCES sciapp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6312 (class 2606 OID 66711)
-- Name: deliverable_reminder_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.reminder
    ADD CONSTRAINT deliverable_reminder_fk FOREIGN KEY (deliverableid) REFERENCES sciapp.deliverable(deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6203 (class 2606 OID 66716)
-- Name: deliverablemod_deliverablemod_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemod
    ADD CONSTRAINT deliverablemod_deliverablemod_fk FOREIGN KEY (parentmodificationid, parentdeliverableid) REFERENCES sciapp.deliverablemod(modificationid, deliverableid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6232 (class 2606 OID 66721)
-- Name: deliverablemod_deliverablemodstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemodstatus
    ADD CONSTRAINT deliverablemod_deliverablemodstatus_fk FOREIGN KEY (modificationid, deliverableid) REFERENCES sciapp.deliverablemod(modificationid, deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6241 (class 2606 OID 66726)
-- Name: deliverablemod_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablenotice
    ADD CONSTRAINT deliverablemod_deliverablenotice_fk FOREIGN KEY (modificationid, deliverableid) REFERENCES sciapp.deliverablemod(modificationid, deliverableid) ON DELETE CASCADE;


--
-- TOC entry 6233 (class 2606 OID 66731)
-- Name: deliverablestatus_deliverablemodstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemodstatus
    ADD CONSTRAINT deliverablestatus_deliverablemodstatus_fk FOREIGN KEY (deliverablestatusid) REFERENCES cvl.deliverablestatus(deliverablestatusid);


--
-- TOC entry 6231 (class 2606 OID 66736)
-- Name: deliverabletype_deliverable_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverable
    ADD CONSTRAINT deliverabletype_deliverable_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);


--
-- TOC entry 6264 (class 2606 OID 66741)
-- Name: deliverabletype_product_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT deliverabletype_product_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);


--
-- TOC entry 6195 (class 2606 OID 66746)
-- Name: electaddtype_electadd_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.eaddress
    ADD CONSTRAINT electaddtype_electadd_fk FOREIGN KEY (eaddresstypeid) REFERENCES cvl.eaddresstype(eaddresstypeid);


--
-- TOC entry 6269 (class 2606 OID 66751)
-- Name: epsg_productepsg_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productepsg
    ADD CONSTRAINT epsg_productepsg_fk FOREIGN KEY (srid) REFERENCES public.spatial_ref_sys(srid);


--
-- TOC entry 6247 (class 2606 OID 66756)
-- Name: fact_factfile_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.factfile
    ADD CONSTRAINT fact_factfile_fk FOREIGN KEY (factid) REFERENCES sciapp.fact(factid) ON DELETE CASCADE;


--
-- TOC entry 6315 (class 2606 OID 66761)
-- Name: fact_timeline_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.timeline
    ADD CONSTRAINT fact_timeline_fk FOREIGN KEY (factid) REFERENCES sciapp.fact(factid) ON DELETE CASCADE;


--
-- TOC entry 6248 (class 2606 OID 66766)
-- Name: file_factfile_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.factfile
    ADD CONSTRAINT file_factfile_fk FOREIGN KEY (fileid) REFERENCES sciapp.file(fileid) ON DELETE CASCADE;


--
-- TOC entry 6249 (class 2606 OID 66771)
-- Name: file_filecomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.filecomment
    ADD CONSTRAINT file_filecomment_fk FOREIGN KEY (fileid) REFERENCES sciapp.file(fileid) ON DELETE CASCADE;


--
-- TOC entry 6253 (class 2606 OID 66776)
-- Name: filetype_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT filetype_file_fk FOREIGN KEY (filetypeid) REFERENCES cvl.filetype(filetypeid);


--
-- TOC entry 6254 (class 2606 OID 66781)
-- Name: fileversion_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT fileversion_file_fk FOREIGN KEY (fileid) REFERENCES sciapp.file(fileid);


--
-- TOC entry 6255 (class 2606 OID 66786)
-- Name: format_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT format_file_fk FOREIGN KEY (formatid) REFERENCES cvl.format(formatid);


--
-- TOC entry 6228 (class 2606 OID 66791)
-- Name: funding_chargecode_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.costcode
    ADD CONSTRAINT funding_chargecode_fk FOREIGN KEY (fundingid) REFERENCES sciapp.funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 6260 (class 2606 OID 66796)
-- Name: funding_fundingcomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fundingcomment
    ADD CONSTRAINT funding_fundingcomment_fk FOREIGN KEY (fundingid) REFERENCES sciapp.funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 6209 (class 2606 OID 66801)
-- Name: funding_invoice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.invoice
    ADD CONSTRAINT funding_invoice_fk FOREIGN KEY (fundingid) REFERENCES sciapp.funding(fundingid) ON DELETE CASCADE;


--
-- TOC entry 6206 (class 2606 OID 66806)
-- Name: fundingtype_funding_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.funding
    ADD CONSTRAINT fundingtype_funding_fk FOREIGN KEY (fundingtypeid) REFERENCES cvl.fundingtype(fundingtypeid);


--
-- TOC entry 6187 (class 2606 OID 66811)
-- Name: govunit_address_county_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.address
    ADD CONSTRAINT govunit_address_county_fk FOREIGN KEY (countyid) REFERENCES cvl.govunit(featureid);


--
-- TOC entry 6188 (class 2606 OID 66816)
-- Name: govunit_address_state_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.address
    ADD CONSTRAINT govunit_address_state_fk FOREIGN KEY (stateid) REFERENCES cvl.govunit(featureid);


--
-- TOC entry 6230 (class 2606 OID 66821)
-- Name: invoice_costcodeinvoice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.costcodeinvoice
    ADD CONSTRAINT invoice_costcodeinvoice_fk FOREIGN KEY (invoiceid) REFERENCES sciapp.invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 6256 (class 2606 OID 66826)
-- Name: invoice_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT invoice_file_fk FOREIGN KEY (invoiceid) REFERENCES sciapp.invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 6262 (class 2606 OID 66831)
-- Name: invoice_invoicecomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.invoicecomment
    ADD CONSTRAINT invoice_invoicecomment_fk FOREIGN KEY (invoiceid) REFERENCES sciapp.invoice(invoiceid) ON DELETE CASCADE;


--
-- TOC entry 6265 (class 2606 OID 66836)
-- Name: isoprogresstype_product_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT isoprogresstype_product_fk FOREIGN KEY (isoprogresstypeid) REFERENCES cvl.isoprogresstype(isoprogresstypeid);


--
-- TOC entry 6300 (class 2606 OID 66841)
-- Name: isoroletype_productcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productcontact
    ADD CONSTRAINT isoroletype_productcontact_fk FOREIGN KEY (isoroletypeid) REFERENCES cvl.isoroletype(isoroletypeid);


--
-- TOC entry 6271 (class 2606 OID 66846)
-- Name: keyword_productkeyword_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productkeyword
    ADD CONSTRAINT keyword_productkeyword_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);


--
-- TOC entry 6266 (class 2606 OID 66851)
-- Name: maintenancefrequency_product_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT maintenancefrequency_product_fk FOREIGN KEY (maintenancefrequencyid) REFERENCES cvl.maintenancefrequency(maintenancefrequencyid);


--
-- TOC entry 6295 (class 2606 OID 66856)
-- Name: modcontacttype_modcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcontact
    ADD CONSTRAINT modcontacttype_modcontact_fk FOREIGN KEY (modcontacttypeid) REFERENCES cvl.modcontacttype(modcontacttypeid);


--
-- TOC entry 6211 (class 2606 OID 66861)
-- Name: moddocstatustype_moddocstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.moddocstatus
    ADD CONSTRAINT moddocstatustype_moddocstatus_fk FOREIGN KEY (moddocstatustypeid) REFERENCES cvl.moddocstatustype(moddocstatustypeid);


--
-- TOC entry 6212 (class 2606 OID 66866)
-- Name: moddoctype_moddocstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.moddocstatus
    ADD CONSTRAINT moddoctype_moddocstatus_fk FOREIGN KEY (moddoctypeid) REFERENCES cvl.moddoctype(moddoctypeid);


--
-- TOC entry 6204 (class 2606 OID 66871)
-- Name: modification_deliverablemod_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemod
    ADD CONSTRAINT modification_deliverablemod_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6257 (class 2606 OID 66876)
-- Name: modification_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT modification_file_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6207 (class 2606 OID 66881)
-- Name: modification_funding_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.funding
    ADD CONSTRAINT modification_funding_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6292 (class 2606 OID 66886)
-- Name: modification_modcomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcomment
    ADD CONSTRAINT modification_modcomment_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6296 (class 2606 OID 66891)
-- Name: modification_modcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcontact
    ADD CONSTRAINT modification_modcontact_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6213 (class 2606 OID 66896)
-- Name: modification_moddocstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.moddocstatus
    ADD CONSTRAINT modification_moddocstatus_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6215 (class 2606 OID 66901)
-- Name: modification_modification_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modification
    ADD CONSTRAINT modification_modification_fk FOREIGN KEY (parentmodificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6244 (class 2606 OID 66906)
-- Name: modification_modificationcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: pts_admin
--

ALTER TABLE ONLY sciapp.modificationcontact
    ADD CONSTRAINT modification_modificationcontact_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid);


--
-- TOC entry 6219 (class 2606 OID 66911)
-- Name: modification_modstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modstatus
    ADD CONSTRAINT modification_modstatus_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6311 (class 2606 OID 66916)
-- Name: modification_purchaserequest_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.purchaserequest
    ADD CONSTRAINT modification_purchaserequest_fk FOREIGN KEY (modificationid) REFERENCES sciapp.modification(modificationid) ON DELETE CASCADE;


--
-- TOC entry 6216 (class 2606 OID 66921)
-- Name: modtype_modification_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modification
    ADD CONSTRAINT modtype_modification_fk FOREIGN KEY (modtypeid) REFERENCES cvl.modtype(modtypeid);


--
-- TOC entry 6242 (class 2606 OID 66926)
-- Name: notice_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablenotice
    ADD CONSTRAINT notice_deliverablenotice_fk FOREIGN KEY (noticeid) REFERENCES cvl.notice(noticeid);


--
-- TOC entry 6297 (class 2606 OID 66931)
-- Name: onlinefunction_onlineresource_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.onlineresource
    ADD CONSTRAINT onlinefunction_onlineresource_fk FOREIGN KEY (onlinefunctionid) REFERENCES cvl.onlinefunction(onlinefunctionid);


--
-- TOC entry 6223 (class 2606 OID 66936)
-- Name: person_audit_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.audit
    ADD CONSTRAINT person_audit_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid);


--
-- TOC entry 6236 (class 2606 OID 66941)
-- Name: person_deliverablecomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecomment
    ADD CONSTRAINT person_deliverablecomment_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6205 (class 2606 OID 66946)
-- Name: person_deliverablemod_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemod
    ADD CONSTRAINT person_deliverablemod_fk FOREIGN KEY (personid) REFERENCES sciapp.person(contactid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6234 (class 2606 OID 66951)
-- Name: person_deliverablemodstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablemodstatus
    ADD CONSTRAINT person_deliverablemodstatus_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6250 (class 2606 OID 66956)
-- Name: person_filecomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.filecomment
    ADD CONSTRAINT person_filecomment_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6261 (class 2606 OID 66961)
-- Name: person_fundingcomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fundingcomment
    ADD CONSTRAINT person_fundingcomment_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6263 (class 2606 OID 66966)
-- Name: person_invoicecomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.invoicecomment
    ADD CONSTRAINT person_invoicecomment_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6293 (class 2606 OID 66971)
-- Name: person_modcomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modcomment
    ADD CONSTRAINT person_modcomment_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6214 (class 2606 OID 66976)
-- Name: person_moddocstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.moddocstatus
    ADD CONSTRAINT person_moddocstatus_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid);


--
-- TOC entry 6217 (class 2606 OID 66981)
-- Name: person_modification_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modification
    ADD CONSTRAINT person_modification_fk FOREIGN KEY (personid) REFERENCES sciapp.person(contactid);


--
-- TOC entry 6307 (class 2606 OID 66986)
-- Name: person_projectcomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcomment
    ADD CONSTRAINT person_projectcomment_fk FOREIGN KEY (contactid) REFERENCES sciapp.person(contactid) ON DELETE CASCADE;


--
-- TOC entry 6201 (class 2606 OID 66991)
-- Name: phonetype_phone_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.phone
    ADD CONSTRAINT phonetype_phone_fk FOREIGN KEY (phonetypeid) REFERENCES cvl.phonetype(phonetypeid);


--
-- TOC entry 6192 (class 2606 OID 66996)
-- Name: postion_groupcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.contactcontactgroup
    ADD CONSTRAINT postion_groupcontact_fk FOREIGN KEY (positionid) REFERENCES cvl."position"(positionid);


--
-- TOC entry 6197 (class 2606 OID 67001)
-- Name: postion_person_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.person
    ADD CONSTRAINT postion_person_fk FOREIGN KEY (positionid) REFERENCES cvl."position"(positionid);


--
-- TOC entry 6298 (class 2606 OID 67006)
-- Name: product_onlineresource_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.onlineresource
    ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6301 (class 2606 OID 67011)
-- Name: product_productcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productcontact
    ADD CONSTRAINT product_productcontact_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6270 (class 2606 OID 67016)
-- Name: product_productepsg_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productepsg
    ADD CONSTRAINT product_productepsg_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6272 (class 2606 OID 67021)
-- Name: product_productkeyword_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productkeyword
    ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6273 (class 2606 OID 67026)
-- Name: product_productline_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productline
    ADD CONSTRAINT product_productline_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6274 (class 2606 OID 67031)
-- Name: product_productpoint_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productpoint
    ADD CONSTRAINT product_productpoint_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6275 (class 2606 OID 67036)
-- Name: product_productpolygon_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productpolygon
    ADD CONSTRAINT product_productpolygon_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6276 (class 2606 OID 67041)
-- Name: product_productspatialformat_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productspatialformat
    ADD CONSTRAINT product_productspatialformat_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6303 (class 2606 OID 67046)
-- Name: product_productstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productstatus
    ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6304 (class 2606 OID 67051)
-- Name: product_productstep_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productstep
    ADD CONSTRAINT product_productstep_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid);


--
-- TOC entry 6278 (class 2606 OID 67056)
-- Name: product_producttopiccategory_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.producttopiccategory
    ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6280 (class 2606 OID 67061)
-- Name: product_productwkt_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productwkt
    ADD CONSTRAINT product_productwkt_fk FOREIGN KEY (productid) REFERENCES sciapp.product(productid) ON DELETE CASCADE;


--
-- TOC entry 6305 (class 2606 OID 67066)
-- Name: productcontact_productstep_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productstep
    ADD CONSTRAINT productcontact_productstep_fk FOREIGN KEY (productcontactid) REFERENCES sciapp.productcontact(productcontactid);


--
-- TOC entry 6267 (class 2606 OID 67071)
-- Name: productgroup_product_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT productgroup_product_fk FOREIGN KEY (productgroupid) REFERENCES sciapp.product(productid);


--
-- TOC entry 6258 (class 2606 OID 67076)
-- Name: progress_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT progress_file_fk FOREIGN KEY (progressid) REFERENCES sciapp.progress(progressid) ON DELETE CASCADE;


--
-- TOC entry 6246 (class 2606 OID 67081)
-- Name: project_fact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fact
    ADD CONSTRAINT project_fact_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6259 (class 2606 OID 67086)
-- Name: project_file_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.fileversion
    ADD CONSTRAINT project_file_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6218 (class 2606 OID 67091)
-- Name: project_modification_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modification
    ADD CONSTRAINT project_modification_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6268 (class 2606 OID 67096)
-- Name: project_product_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.product
    ADD CONSTRAINT project_product_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid);


--
-- TOC entry 6222 (class 2606 OID 67101)
-- Name: project_project_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.project
    ADD CONSTRAINT project_project_fk FOREIGN KEY (parentprojectid) REFERENCES sciapp.project(projectid) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 6308 (class 2606 OID 67106)
-- Name: project_projectcomment_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcomment
    ADD CONSTRAINT project_projectcomment_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6282 (class 2606 OID 67111)
-- Name: project_projectconcept_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectkeyword
    ADD CONSTRAINT project_projectconcept_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6226 (class 2606 OID 67116)
-- Name: project_projectcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcontact
    ADD CONSTRAINT project_projectcontact_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6309 (class 2606 OID 67121)
-- Name: project_projectgnis_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectgnis
    ADD CONSTRAINT project_projectgnis_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6310 (class 2606 OID 67126)
-- Name: project_projectitis_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectitis
    ADD CONSTRAINT project_projectitis_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6283 (class 2606 OID 67131)
-- Name: project_projectline_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectline
    ADD CONSTRAINT project_projectline_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6284 (class 2606 OID 67136)
-- Name: project_projectpoint_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectpoint
    ADD CONSTRAINT project_projectpoint_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6285 (class 2606 OID 67141)
-- Name: project_projectpolygon_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectpolygon
    ADD CONSTRAINT project_projectpolygon_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6286 (class 2606 OID 67146)
-- Name: project_projectprojectcategory_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectprojectcategory
    ADD CONSTRAINT project_projectprojectcategory_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6288 (class 2606 OID 67151)
-- Name: project_projecttopiccategory_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projecttopiccategory
    ADD CONSTRAINT project_projecttopiccategory_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6290 (class 2606 OID 67156)
-- Name: project_projectusertype_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectusertype
    ADD CONSTRAINT project_projectusertype_fk FOREIGN KEY (projectid) REFERENCES sciapp.project(projectid) ON DELETE CASCADE;


--
-- TOC entry 6287 (class 2606 OID 67161)
-- Name: projectcategory_projectprojectcategory_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectprojectcategory
    ADD CONSTRAINT projectcategory_projectprojectcategory_fk FOREIGN KEY (projectcategoryid) REFERENCES cvl.projectcategory(projectcategoryid);


--
-- TOC entry 6208 (class 2606 OID 67166)
-- Name: projectcontact_funding_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.funding
    ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid) REFERENCES sciapp.projectcontact(projectcontactid) ON DELETE CASCADE;


--
-- TOC entry 6210 (class 2606 OID 67171)
-- Name: projectcontact_invoice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.invoice
    ADD CONSTRAINT projectcontact_invoice_fk FOREIGN KEY (projectcontactid) REFERENCES sciapp.projectcontact(projectcontactid) ON DELETE CASCADE;


--
-- TOC entry 6245 (class 2606 OID 67176)
-- Name: projectcontact_modificationcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: pts_admin
--

ALTER TABLE ONLY sciapp.modificationcontact
    ADD CONSTRAINT projectcontact_modificationcontact_fk FOREIGN KEY (projectcontactid) REFERENCES sciapp.projectcontact(projectcontactid);


--
-- TOC entry 6243 (class 2606 OID 67181)
-- Name: recipient_deliverablenotice_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablenotice
    ADD CONSTRAINT recipient_deliverablenotice_fk FOREIGN KEY (recipientid) REFERENCES sciapp.contact(contactid);


--
-- TOC entry 6314 (class 2606 OID 67186)
-- Name: reminder_remindercontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.remindercontact
    ADD CONSTRAINT reminder_remindercontact_fk FOREIGN KEY (reminderid) REFERENCES sciapp.reminder(reminderid) ON DELETE CASCADE;


--
-- TOC entry 6239 (class 2606 OID 67191)
-- Name: roletype_deliverablecontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.deliverablecontact
    ADD CONSTRAINT roletype_deliverablecontact_fk FOREIGN KEY (roletypeid) REFERENCES cvl.roletype(roletypeid);


--
-- TOC entry 6227 (class 2606 OID 67196)
-- Name: roletype_projectcontact_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectcontact
    ADD CONSTRAINT roletype_projectcontact_fk FOREIGN KEY (roletypeid) REFERENCES cvl.roletype(roletypeid);


--
-- TOC entry 6277 (class 2606 OID 67201)
-- Name: spatialformat_productspatialformat_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.productspatialformat
    ADD CONSTRAINT spatialformat_productspatialformat_fk FOREIGN KEY (spatialformatid) REFERENCES cvl.spatialformat(spatialformatid);


--
-- TOC entry 6220 (class 2606 OID 67206)
-- Name: status_modstatus_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.modstatus
    ADD CONSTRAINT status_modstatus_fk FOREIGN KEY (statusid) REFERENCES cvl.status(statusid);


--
-- TOC entry 6279 (class 2606 OID 67211)
-- Name: topiccategory_producttopiccategory_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.producttopiccategory
    ADD CONSTRAINT topiccategory_producttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);


--
-- TOC entry 6289 (class 2606 OID 67216)
-- Name: topiccategory_projecttopiccategory_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projecttopiccategory
    ADD CONSTRAINT topiccategory_projecttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);


--
-- TOC entry 6291 (class 2606 OID 67221)
-- Name: usertype_projectusertype_fk; Type: FK CONSTRAINT; Schema: sciapp; Owner: bradley
--

ALTER TABLE ONLY sciapp.projectusertype
    ADD CONSTRAINT usertype_projectusertype_fk FOREIGN KEY (usertypeid) REFERENCES cvl.usertype(usertypeid);


--
-- TOC entry 6749 (class 0 OID 0)
-- Dependencies: 17
-- Name: SCHEMA sciapp; Type: ACL; Schema: -; Owner: bradley
--

REVOKE ALL ON SCHEMA sciapp FROM PUBLIC;
REVOKE ALL ON SCHEMA sciapp FROM bradley;
GRANT ALL ON SCHEMA sciapp TO bradley;
GRANT USAGE ON SCHEMA sciapp TO pts_read;
GRANT ALL ON SCHEMA sciapp TO pts_admin;

--
-- TOC entry 6759 (class 0 OID 0)
-- Dependencies: 567
-- Name: TABLE address; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.address FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.address FROM bradley;
GRANT ALL ON TABLE sciapp.address TO bradley;
GRANT SELECT ON TABLE sciapp.address TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.address TO pts_write;
GRANT ALL ON TABLE sciapp.address TO pts_admin;


--
-- TOC entry 6763 (class 0 OID 0)
-- Dependencies: 568
-- Name: TABLE contact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contact FROM bradley;
GRANT ALL ON TABLE sciapp.contact TO bradley;
GRANT SELECT ON TABLE sciapp.contact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.contact TO pts_write;
GRANT ALL ON TABLE sciapp.contact TO pts_admin;


--
-- TOC entry 6766 (class 0 OID 0)
-- Dependencies: 569
-- Name: TABLE contactcontactgroup; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contactcontactgroup FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contactcontactgroup FROM bradley;
GRANT ALL ON TABLE sciapp.contactcontactgroup TO bradley;
GRANT SELECT ON TABLE sciapp.contactcontactgroup TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.contactcontactgroup TO pts_write;
GRANT ALL ON TABLE sciapp.contactcontactgroup TO pts_admin;


--
-- TOC entry 6770 (class 0 OID 0)
-- Dependencies: 570
-- Name: TABLE contactgroup; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contactgroup FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contactgroup FROM bradley;
GRANT ALL ON TABLE sciapp.contactgroup TO bradley;
GRANT SELECT ON TABLE sciapp.contactgroup TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.contactgroup TO pts_write;
GRANT ALL ON TABLE sciapp.contactgroup TO pts_admin;


--
-- TOC entry 6773 (class 0 OID 0)
-- Dependencies: 571
-- Name: TABLE eaddress; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.eaddress FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.eaddress FROM bradley;
GRANT ALL ON TABLE sciapp.eaddress TO bradley;
GRANT SELECT ON TABLE sciapp.eaddress TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.eaddress TO pts_write;
GRANT ALL ON TABLE sciapp.eaddress TO pts_admin;


--
-- TOC entry 6776 (class 0 OID 0)
-- Dependencies: 572
-- Name: TABLE person; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.person FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.person FROM bradley;
GRANT ALL ON TABLE sciapp.person TO bradley;
GRANT SELECT ON TABLE sciapp.person TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.person TO pts_write;
GRANT ALL ON TABLE sciapp.person TO pts_admin;


--
-- TOC entry 6784 (class 0 OID 0)
-- Dependencies: 573
-- Name: TABLE phone; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.phone FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.phone FROM bradley;
GRANT ALL ON TABLE sciapp.phone TO bradley;
GRANT SELECT ON TABLE sciapp.phone TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.phone TO pts_write;
GRANT ALL ON TABLE sciapp.phone TO pts_admin;


--
-- TOC entry 6785 (class 0 OID 0)
-- Dependencies: 574
-- Name: TABLE alccstaff; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.alccstaff FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.alccstaff FROM bradley;
GRANT ALL ON TABLE sciapp.alccstaff TO bradley;
GRANT SELECT ON TABLE sciapp.alccstaff TO pts_read;
GRANT ALL ON TABLE sciapp.alccstaff TO pts_admin;


--
-- TOC entry 6786 (class 0 OID 0)
-- Dependencies: 575
-- Name: TABLE alccsteeringcommittee; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.alccsteeringcommittee FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.alccsteeringcommittee FROM bradley;
GRANT ALL ON TABLE sciapp.alccsteeringcommittee TO bradley;
GRANT SELECT ON TABLE sciapp.alccsteeringcommittee TO pts_read;
GRANT ALL ON TABLE sciapp.alccsteeringcommittee TO pts_admin;


--
-- TOC entry 6802 (class 0 OID 0)
-- Dependencies: 576
-- Name: TABLE deliverablemod; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablemod FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablemod FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablemod TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablemod TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.deliverablemod TO pts_write;
GRANT ALL ON TABLE sciapp.deliverablemod TO pts_admin;


--
-- TOC entry 6807 (class 0 OID 0)
-- Dependencies: 577
-- Name: TABLE funding; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.funding FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.funding FROM bradley;
GRANT ALL ON TABLE sciapp.funding TO bradley;
GRANT SELECT ON TABLE sciapp.funding TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.funding TO pts_write;
GRANT ALL ON TABLE sciapp.funding TO pts_admin;


--
-- TOC entry 6812 (class 0 OID 0)
-- Dependencies: 578
-- Name: TABLE invoice; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.invoice FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.invoice FROM bradley;
GRANT ALL ON TABLE sciapp.invoice TO bradley;
GRANT SELECT ON TABLE sciapp.invoice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.invoice TO pts_write;
GRANT ALL ON TABLE sciapp.invoice TO pts_admin;


--
-- TOC entry 6820 (class 0 OID 0)
-- Dependencies: 579
-- Name: TABLE moddocstatus; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.moddocstatus FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.moddocstatus FROM bradley;
GRANT ALL ON TABLE sciapp.moddocstatus TO bradley;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.moddocstatus TO pts_write;
GRANT SELECT ON TABLE sciapp.moddocstatus TO pts_read;
GRANT ALL ON TABLE sciapp.moddocstatus TO pts_admin;


--
-- TOC entry 6833 (class 0 OID 0)
-- Dependencies: 580
-- Name: TABLE modification; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modification FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modification FROM bradley;
GRANT ALL ON TABLE sciapp.modification TO bradley;
GRANT SELECT ON TABLE sciapp.modification TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.modification TO pts_write;
GRANT ALL ON TABLE sciapp.modification TO pts_admin;


--
-- TOC entry 6838 (class 0 OID 0)
-- Dependencies: 581
-- Name: TABLE modstatus; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modstatus FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modstatus FROM bradley;
GRANT ALL ON TABLE sciapp.modstatus TO bradley;
GRANT SELECT ON TABLE sciapp.modstatus TO pts_read;
GRANT INSERT,DELETE,UPDATE ON TABLE sciapp.modstatus TO pts_write;
GRANT ALL ON TABLE sciapp.modstatus TO pts_admin;


--
-- TOC entry 6840 (class 0 OID 0)
-- Dependencies: 582
-- Name: TABLE modificationstatus; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modificationstatus FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modificationstatus FROM bradley;
GRANT ALL ON TABLE sciapp.modificationstatus TO bradley;
GRANT SELECT ON TABLE sciapp.modificationstatus TO pts_read;
GRANT ALL ON TABLE sciapp.modificationstatus TO pts_admin;


--
-- TOC entry 6855 (class 0 OID 0)
-- Dependencies: 583
-- Name: TABLE project; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.project FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.project FROM bradley;
GRANT ALL ON TABLE sciapp.project TO bradley;
GRANT SELECT ON TABLE sciapp.project TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.project TO pts_write;
GRANT ALL ON TABLE sciapp.project TO pts_admin;


--
-- TOC entry 6856 (class 0 OID 0)
-- Dependencies: 584
-- Name: TABLE projectlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectlist FROM bradley;
GRANT ALL ON TABLE sciapp.projectlist TO bradley;
GRANT SELECT ON TABLE sciapp.projectlist TO pts_read;
GRANT SELECT ON TABLE sciapp.projectlist TO pts_write;
GRANT ALL ON TABLE sciapp.projectlist TO pts_admin;


--
-- TOC entry 6857 (class 0 OID 0)
-- Dependencies: 585
-- Name: TABLE allmoddocstatus; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.allmoddocstatus FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.allmoddocstatus FROM bradley;
GRANT ALL ON TABLE sciapp.allmoddocstatus TO bradley;
GRANT SELECT ON TABLE sciapp.allmoddocstatus TO pts_read;
GRANT ALL ON TABLE sciapp.allmoddocstatus TO pts_admin;


--
-- TOC entry 6860 (class 0 OID 0)
-- Dependencies: 586
-- Name: TABLE audit; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.audit FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.audit FROM bradley;
GRANT ALL ON TABLE sciapp.audit TO bradley;
GRANT SELECT ON TABLE sciapp.audit TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.audit TO pts_write;
GRANT ALL ON TABLE sciapp.audit TO pts_admin;


--
-- TOC entry 6866 (class 0 OID 0)
-- Dependencies: 587
-- Name: TABLE catalogprojectcategory; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.catalogprojectcategory FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.catalogprojectcategory FROM bradley;
GRANT ALL ON TABLE sciapp.catalogprojectcategory TO bradley;
GRANT ALL ON TABLE sciapp.catalogprojectcategory TO pts_admin;


--
-- TOC entry 6869 (class 0 OID 0)
-- Dependencies: 588
-- Name: TABLE contactcostcode; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contactcostcode FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contactcostcode FROM bradley;
GRANT ALL ON TABLE sciapp.contactcostcode TO bradley;
GRANT SELECT ON TABLE sciapp.contactcostcode TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.contactcostcode TO pts_write;
GRANT ALL ON TABLE sciapp.contactcostcode TO pts_admin;


--
-- TOC entry 6870 (class 0 OID 0)
-- Dependencies: 589
-- Name: TABLE contactgrouplist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contactgrouplist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contactgrouplist FROM bradley;
GRANT ALL ON TABLE sciapp.contactgrouplist TO bradley;
GRANT SELECT ON TABLE sciapp.contactgrouplist TO pts_read;
GRANT ALL ON TABLE sciapp.contactgrouplist TO pts_admin;


--
-- TOC entry 6871 (class 0 OID 0)
-- Dependencies: 590
-- Name: TABLE contactprimaryinfo; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contactprimaryinfo FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contactprimaryinfo FROM bradley;
GRANT ALL ON TABLE sciapp.contactprimaryinfo TO bradley;
GRANT SELECT ON TABLE sciapp.contactprimaryinfo TO pts_read;
GRANT ALL ON TABLE sciapp.contactprimaryinfo TO pts_admin;


--
-- TOC entry 6877 (class 0 OID 0)
-- Dependencies: 591
-- Name: TABLE projectcontact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectcontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectcontact FROM bradley;
GRANT ALL ON TABLE sciapp.projectcontact TO bradley;
GRANT SELECT ON TABLE sciapp.projectcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectcontact TO pts_write;
GRANT ALL ON TABLE sciapp.projectcontact TO pts_admin;


--
-- TOC entry 6878 (class 0 OID 0)
-- Dependencies: 592
-- Name: TABLE contactprojectslist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.contactprojectslist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.contactprojectslist FROM bradley;
GRANT ALL ON TABLE sciapp.contactprojectslist TO bradley;
GRANT SELECT ON TABLE sciapp.contactprojectslist TO pts_read;
GRANT ALL ON TABLE sciapp.contactprojectslist TO pts_admin;


--
-- TOC entry 6883 (class 0 OID 0)
-- Dependencies: 593
-- Name: TABLE costcode; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.costcode FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.costcode FROM bradley;
GRANT ALL ON TABLE sciapp.costcode TO bradley;
GRANT SELECT ON TABLE sciapp.costcode TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.costcode TO pts_write;
GRANT ALL ON TABLE sciapp.costcode TO pts_admin;


--
-- TOC entry 6887 (class 0 OID 0)
-- Dependencies: 594
-- Name: TABLE costcodeinvoice; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.costcodeinvoice FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.costcodeinvoice FROM bradley;
GRANT ALL ON TABLE sciapp.costcodeinvoice TO bradley;
GRANT SELECT ON TABLE sciapp.costcodeinvoice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.costcodeinvoice TO pts_write;
GRANT ALL ON TABLE sciapp.costcodeinvoice TO pts_admin;


--
-- TOC entry 6888 (class 0 OID 0)
-- Dependencies: 595
-- Name: TABLE countylist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.countylist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.countylist FROM bradley;
GRANT ALL ON TABLE sciapp.countylist TO bradley;
GRANT SELECT ON TABLE sciapp.countylist TO pts_read;
GRANT ALL ON TABLE sciapp.countylist TO pts_admin;


--
-- TOC entry 6894 (class 0 OID 0)
-- Dependencies: 596
-- Name: TABLE deliverable; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverable FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverable FROM bradley;
GRANT ALL ON TABLE sciapp.deliverable TO bradley;
GRANT SELECT ON TABLE sciapp.deliverable TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.deliverable TO pts_write;
GRANT ALL ON TABLE sciapp.deliverable TO pts_admin;


--
-- TOC entry 6901 (class 0 OID 0)
-- Dependencies: 597
-- Name: TABLE deliverablemodstatus; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablemodstatus FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablemodstatus FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablemodstatus TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablemodstatus TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.deliverablemodstatus TO pts_write;
GRANT ALL ON TABLE sciapp.deliverablemodstatus TO pts_admin;


--
-- TOC entry 6902 (class 0 OID 0)
-- Dependencies: 598
-- Name: TABLE deliverableall; Type: ACL; Schema: sciapp; Owner: pts_admin
--

REVOKE ALL ON TABLE sciapp.deliverableall FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverableall FROM pts_admin;
GRANT ALL ON TABLE sciapp.deliverableall TO pts_admin;
GRANT SELECT ON TABLE sciapp.deliverableall TO pts_read;


--
-- TOC entry 6903 (class 0 OID 0)
-- Dependencies: 599
-- Name: TABLE deliverablecalendar; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablecalendar FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablecalendar FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablecalendar TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablecalendar TO pts_read;
GRANT ALL ON TABLE sciapp.deliverablecalendar TO pts_admin;


--
-- TOC entry 6907 (class 0 OID 0)
-- Dependencies: 600
-- Name: TABLE deliverablecomment; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablecomment FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablecomment FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablecomment TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.deliverablecomment TO pts_write;
GRANT ALL ON TABLE sciapp.deliverablecomment TO pts_admin;


--
-- TOC entry 6911 (class 0 OID 0)
-- Dependencies: 601
-- Name: TABLE deliverablecontact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablecontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablecontact FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablecontact TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablecontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.deliverablecontact TO pts_write;
GRANT ALL ON TABLE sciapp.deliverablecontact TO pts_admin;


--
-- TOC entry 6912 (class 0 OID 0)
-- Dependencies: 602
-- Name: TABLE personlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.personlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.personlist FROM bradley;
GRANT ALL ON TABLE sciapp.personlist TO bradley;
GRANT SELECT ON TABLE sciapp.personlist TO pts_read;
GRANT ALL ON TABLE sciapp.personlist TO pts_admin;


--
-- TOC entry 6913 (class 0 OID 0)
-- Dependencies: 603
-- Name: TABLE deliverabledue; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverabledue FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverabledue FROM bradley;
GRANT ALL ON TABLE sciapp.deliverabledue TO bradley;
GRANT SELECT ON TABLE sciapp.deliverabledue TO pts_read;
GRANT ALL ON TABLE sciapp.deliverabledue TO pts_admin;


--
-- TOC entry 6915 (class 0 OID 0)
-- Dependencies: 604
-- Name: TABLE deliverablelist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablelist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablelist FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablelist TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablelist TO pts_read;
GRANT ALL ON TABLE sciapp.deliverablelist TO pts_admin;


--
-- TOC entry 6924 (class 0 OID 0)
-- Dependencies: 605
-- Name: TABLE deliverablenotice; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablenotice FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablenotice FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablenotice TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablenotice TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.deliverablenotice TO pts_write;
GRANT ALL ON TABLE sciapp.deliverablenotice TO pts_admin;


--
-- TOC entry 6929 (class 0 OID 0)
-- Dependencies: 606
-- Name: TABLE modificationcontact; Type: ACL; Schema: sciapp; Owner: pts_admin
--

REVOKE ALL ON TABLE sciapp.modificationcontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modificationcontact FROM pts_admin;
GRANT ALL ON TABLE sciapp.modificationcontact TO pts_admin;
GRANT SELECT ON TABLE sciapp.modificationcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.modificationcontact TO pts_write;


--
-- TOC entry 6930 (class 0 OID 0)
-- Dependencies: 607
-- Name: TABLE deliverablereminder; Type: ACL; Schema: sciapp; Owner: pts_admin
--

REVOKE ALL ON TABLE sciapp.deliverablereminder FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablereminder FROM pts_admin;
GRANT ALL ON TABLE sciapp.deliverablereminder TO pts_admin;
GRANT SELECT ON TABLE sciapp.deliverablereminder TO pts_read;


--
-- TOC entry 6931 (class 0 OID 0)
-- Dependencies: 608
-- Name: TABLE deliverablestatuslist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.deliverablestatuslist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.deliverablestatuslist FROM bradley;
GRANT ALL ON TABLE sciapp.deliverablestatuslist TO bradley;
GRANT SELECT ON TABLE sciapp.deliverablestatuslist TO pts_read;
GRANT ALL ON TABLE sciapp.deliverablestatuslist TO pts_admin;


--
-- TOC entry 6932 (class 0 OID 0)
-- Dependencies: 609
-- Name: TABLE sciappsteeringcommittee; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.sciappsteeringcommittee FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.sciappsteeringcommittee FROM bradley;
GRANT ALL ON TABLE sciapp.sciappsteeringcommittee TO bradley;
GRANT ALL ON TABLE sciapp.sciappsteeringcommittee TO pts_admin;


--
-- TOC entry 6935 (class 0 OID 0)
-- Dependencies: 610
-- Name: TABLE fact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.fact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.fact FROM bradley;
GRANT ALL ON TABLE sciapp.fact TO bradley;
GRANT SELECT ON TABLE sciapp.fact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.fact TO pts_write;
GRANT ALL ON TABLE sciapp.fact TO pts_admin;


--
-- TOC entry 6939 (class 0 OID 0)
-- Dependencies: 611
-- Name: TABLE factfile; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.factfile FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.factfile FROM bradley;
GRANT ALL ON TABLE sciapp.factfile TO bradley;
GRANT SELECT ON TABLE sciapp.factfile TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.factfile TO pts_write;
GRANT ALL ON TABLE sciapp.factfile TO pts_admin;


--
-- TOC entry 6944 (class 0 OID 0)
-- Dependencies: 612
-- Name: TABLE file; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.file FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.file FROM bradley;
GRANT ALL ON TABLE sciapp.file TO bradley;
GRANT SELECT ON TABLE sciapp.file TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.file TO pts_write;
GRANT ALL ON TABLE sciapp.file TO pts_admin;


--
-- TOC entry 6947 (class 0 OID 0)
-- Dependencies: 613
-- Name: TABLE filecomment; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.filecomment FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.filecomment FROM bradley;
GRANT ALL ON TABLE sciapp.filecomment TO bradley;
GRANT SELECT ON TABLE sciapp.filecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.filecomment TO pts_write;
GRANT ALL ON TABLE sciapp.filecomment TO pts_admin;


--
-- TOC entry 6954 (class 0 OID 0)
-- Dependencies: 614
-- Name: TABLE fileversion; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.fileversion FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.fileversion FROM bradley;
GRANT ALL ON TABLE sciapp.fileversion TO bradley;
GRANT SELECT ON TABLE sciapp.fileversion TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.fileversion TO pts_write;
GRANT ALL ON TABLE sciapp.fileversion TO pts_admin;


--
-- TOC entry 6958 (class 0 OID 0)
-- Dependencies: 615
-- Name: TABLE fundingcomment; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.fundingcomment FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.fundingcomment FROM bradley;
GRANT ALL ON TABLE sciapp.fundingcomment TO bradley;
GRANT SELECT ON TABLE sciapp.fundingcomment TO pts_read;
GRANT INSERT,DELETE,UPDATE ON TABLE sciapp.fundingcomment TO pts_write;
GRANT ALL ON TABLE sciapp.fundingcomment TO pts_admin;


--
-- TOC entry 6959 (class 0 OID 0)
-- Dependencies: 616
-- Name: TABLE fundingtotals; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.fundingtotals FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.fundingtotals FROM bradley;
GRANT ALL ON TABLE sciapp.fundingtotals TO bradley;
GRANT SELECT ON TABLE sciapp.fundingtotals TO pts_read;
GRANT ALL ON TABLE sciapp.fundingtotals TO pts_admin;


--
-- TOC entry 6960 (class 0 OID 0)
-- Dependencies: 617
-- Name: TABLE groupmemberlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.groupmemberlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.groupmemberlist FROM bradley;
GRANT ALL ON TABLE sciapp.groupmemberlist TO bradley;
GRANT SELECT ON TABLE sciapp.groupmemberlist TO pts_read;
GRANT ALL ON TABLE sciapp.groupmemberlist TO pts_admin;


--
-- TOC entry 6961 (class 0 OID 0)
-- Dependencies: 618
-- Name: TABLE grouppersonfull; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.grouppersonfull FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.grouppersonfull FROM bradley;
GRANT ALL ON TABLE sciapp.grouppersonfull TO bradley;
GRANT SELECT ON TABLE sciapp.grouppersonfull TO pts_read;
GRANT ALL ON TABLE sciapp.grouppersonfull TO pts_admin;


--
-- TOC entry 6962 (class 0 OID 0)
-- Dependencies: 619
-- Name: TABLE grouppersonlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.grouppersonlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.grouppersonlist FROM bradley;
GRANT ALL ON TABLE sciapp.grouppersonlist TO bradley;
GRANT SELECT ON TABLE sciapp.grouppersonlist TO pts_read;
GRANT ALL ON TABLE sciapp.grouppersonlist TO pts_admin;


--
-- TOC entry 6964 (class 0 OID 0)
-- Dependencies: 620
-- Name: TABLE invoicecomment; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.invoicecomment FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.invoicecomment FROM bradley;
GRANT ALL ON TABLE sciapp.invoicecomment TO bradley;
GRANT SELECT ON TABLE sciapp.invoicecomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.invoicecomment TO pts_write;
GRANT ALL ON TABLE sciapp.invoicecomment TO pts_admin;


--
-- TOC entry 6965 (class 0 OID 0)
-- Dependencies: 621
-- Name: TABLE invoicelist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.invoicelist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.invoicelist FROM bradley;
GRANT ALL ON TABLE sciapp.invoicelist TO bradley;
GRANT SELECT ON TABLE sciapp.invoicelist TO pts_read;
GRANT ALL ON TABLE sciapp.invoicelist TO pts_admin;


--
-- TOC entry 6966 (class 0 OID 0)
-- Dependencies: 622
-- Name: TABLE longprojectsummary; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.longprojectsummary FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.longprojectsummary FROM bradley;
GRANT ALL ON TABLE sciapp.longprojectsummary TO bradley;
GRANT SELECT ON TABLE sciapp.longprojectsummary TO pts_read;
GRANT ALL ON TABLE sciapp.longprojectsummary TO pts_admin;


--
-- TOC entry 6967 (class 0 OID 0)
-- Dependencies: 623
-- Name: TABLE membergrouplist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.membergrouplist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.membergrouplist FROM bradley;
GRANT ALL ON TABLE sciapp.membergrouplist TO bradley;
GRANT SELECT ON TABLE sciapp.membergrouplist TO pts_read;
GRANT ALL ON TABLE sciapp.membergrouplist TO pts_admin;


--
-- TOC entry 6968 (class 0 OID 0)
-- Dependencies: 624
-- Name: TABLE metadatacontact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.metadatacontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.metadatacontact FROM bradley;
GRANT ALL ON TABLE sciapp.metadatacontact TO bradley;
GRANT SELECT ON TABLE sciapp.metadatacontact TO pts_read;
GRANT ALL ON TABLE sciapp.metadatacontact TO pts_admin;


--
-- TOC entry 6969 (class 0 OID 0)
-- Dependencies: 625
-- Name: TABLE metadatafunding; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.metadatafunding FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.metadatafunding FROM bradley;
GRANT ALL ON TABLE sciapp.metadatafunding TO bradley;
GRANT SELECT ON TABLE sciapp.metadatafunding TO pts_read;
GRANT ALL ON TABLE sciapp.metadatafunding TO pts_admin;


--
-- TOC entry 6987 (class 0 OID 0)
-- Dependencies: 626
-- Name: TABLE product; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.product FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.product FROM bradley;
GRANT ALL ON TABLE sciapp.product TO bradley;
GRANT SELECT ON TABLE sciapp.product TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.product TO pts_write;
GRANT ALL ON TABLE sciapp.product TO pts_admin;


--
-- TOC entry 6988 (class 0 OID 0)
-- Dependencies: 627
-- Name: TABLE productepsg; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productepsg FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productepsg FROM bradley;
GRANT ALL ON TABLE sciapp.productepsg TO bradley;
GRANT SELECT ON TABLE sciapp.productepsg TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productepsg TO pts_write;
GRANT ALL ON TABLE sciapp.productepsg TO pts_admin;


--
-- TOC entry 6993 (class 0 OID 0)
-- Dependencies: 628
-- Name: TABLE productkeyword; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productkeyword FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productkeyword FROM bradley;
GRANT ALL ON TABLE sciapp.productkeyword TO bradley;
GRANT SELECT ON TABLE sciapp.productkeyword TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productkeyword TO pts_write;
GRANT ALL ON TABLE sciapp.productkeyword TO pts_admin;


--
-- TOC entry 6994 (class 0 OID 0)
-- Dependencies: 629
-- Name: TABLE productline; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productline FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productline FROM bradley;
GRANT ALL ON TABLE sciapp.productline TO bradley;
GRANT SELECT ON TABLE sciapp.productline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productline TO pts_write;
GRANT ALL ON TABLE sciapp.productline TO pts_admin;


--
-- TOC entry 6995 (class 0 OID 0)
-- Dependencies: 630
-- Name: TABLE productpoint; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productpoint FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productpoint FROM bradley;
GRANT ALL ON TABLE sciapp.productpoint TO bradley;
GRANT SELECT ON TABLE sciapp.productpoint TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productpoint TO pts_write;
GRANT ALL ON TABLE sciapp.productpoint TO pts_admin;


--
-- TOC entry 6996 (class 0 OID 0)
-- Dependencies: 631
-- Name: TABLE productpolygon; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productpolygon FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productpolygon FROM bradley;
GRANT ALL ON TABLE sciapp.productpolygon TO bradley;
GRANT SELECT ON TABLE sciapp.productpolygon TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productpolygon TO pts_write;
GRANT ALL ON TABLE sciapp.productpolygon TO pts_admin;


--
-- TOC entry 6997 (class 0 OID 0)
-- Dependencies: 632
-- Name: TABLE productspatialformat; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productspatialformat FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productspatialformat FROM bradley;
GRANT ALL ON TABLE sciapp.productspatialformat TO bradley;
GRANT SELECT ON TABLE sciapp.productspatialformat TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productspatialformat TO pts_write;
GRANT ALL ON TABLE sciapp.productspatialformat TO pts_admin;


--
-- TOC entry 6998 (class 0 OID 0)
-- Dependencies: 633
-- Name: TABLE producttopiccategory; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.producttopiccategory FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.producttopiccategory FROM bradley;
GRANT ALL ON TABLE sciapp.producttopiccategory TO bradley;
GRANT SELECT ON TABLE sciapp.producttopiccategory TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.producttopiccategory TO pts_write;
GRANT ALL ON TABLE sciapp.producttopiccategory TO pts_admin;


--
-- TOC entry 6999 (class 0 OID 0)
-- Dependencies: 634
-- Name: TABLE productwkt; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productwkt FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productwkt FROM bradley;
GRANT ALL ON TABLE sciapp.productwkt TO bradley;
GRANT SELECT ON TABLE sciapp.productwkt TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productwkt TO pts_write;
GRANT ALL ON TABLE sciapp.productwkt TO pts_admin;


--
-- TOC entry 7000 (class 0 OID 0)
-- Dependencies: 635
-- Name: TABLE metadataproduct; Type: ACL; Schema: sciapp; Owner: pts_admin
--

REVOKE ALL ON TABLE sciapp.metadataproduct FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.metadataproduct FROM pts_admin;
GRANT ALL ON TABLE sciapp.metadataproduct TO pts_admin;
GRANT SELECT ON TABLE sciapp.metadataproduct TO pts_read;


--
-- TOC entry 7003 (class 0 OID 0)
-- Dependencies: 636
-- Name: TABLE projectkeyword; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectkeyword FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectkeyword FROM bradley;
GRANT ALL ON TABLE sciapp.projectkeyword TO bradley;
GRANT SELECT ON TABLE sciapp.projectkeyword TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectkeyword TO pts_write;
GRANT ALL ON TABLE sciapp.projectkeyword TO pts_admin;


--
-- TOC entry 7004 (class 0 OID 0)
-- Dependencies: 637
-- Name: TABLE projectline; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectline FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectline FROM bradley;
GRANT ALL ON TABLE sciapp.projectline TO bradley;
GRANT SELECT ON TABLE sciapp.projectline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectline TO pts_write;
GRANT ALL ON TABLE sciapp.projectline TO pts_admin;


--
-- TOC entry 7005 (class 0 OID 0)
-- Dependencies: 638
-- Name: TABLE projectpoint; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectpoint FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectpoint FROM bradley;
GRANT ALL ON TABLE sciapp.projectpoint TO bradley;
GRANT SELECT ON TABLE sciapp.projectpoint TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectpoint TO pts_write;
GRANT ALL ON TABLE sciapp.projectpoint TO pts_admin;


--
-- TOC entry 7006 (class 0 OID 0)
-- Dependencies: 639
-- Name: TABLE projectpolygon; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectpolygon FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectpolygon FROM bradley;
GRANT ALL ON TABLE sciapp.projectpolygon TO bradley;
GRANT SELECT ON TABLE sciapp.projectpolygon TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectpolygon TO pts_write;
GRANT ALL ON TABLE sciapp.projectpolygon TO pts_admin;


--
-- TOC entry 7007 (class 0 OID 0)
-- Dependencies: 640
-- Name: TABLE projectprojectcategory; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectprojectcategory FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectprojectcategory FROM bradley;
GRANT ALL ON TABLE sciapp.projectprojectcategory TO bradley;
GRANT SELECT ON TABLE sciapp.projectprojectcategory TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectprojectcategory TO pts_write;
GRANT ALL ON TABLE sciapp.projectprojectcategory TO pts_admin;


--
-- TOC entry 7008 (class 0 OID 0)
-- Dependencies: 641
-- Name: TABLE projecttopiccategory; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projecttopiccategory FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projecttopiccategory FROM bradley;
GRANT ALL ON TABLE sciapp.projecttopiccategory TO bradley;
GRANT SELECT ON TABLE sciapp.projecttopiccategory TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projecttopiccategory TO pts_write;
GRANT ALL ON TABLE sciapp.projecttopiccategory TO pts_admin;


--
-- TOC entry 7009 (class 0 OID 0)
-- Dependencies: 642
-- Name: TABLE projectusertype; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectusertype FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectusertype FROM bradley;
GRANT ALL ON TABLE sciapp.projectusertype TO bradley;
GRANT SELECT ON TABLE sciapp.projectusertype TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectusertype TO pts_write;
GRANT ALL ON TABLE sciapp.projectusertype TO pts_admin;


--
-- TOC entry 7010 (class 0 OID 0)
-- Dependencies: 643
-- Name: TABLE metadataproject; Type: ACL; Schema: sciapp; Owner: pts_admin
--

REVOKE ALL ON TABLE sciapp.metadataproject FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.metadataproject FROM pts_admin;
GRANT ALL ON TABLE sciapp.metadataproject TO pts_admin;
GRANT SELECT ON TABLE sciapp.metadataproject TO pts_read;


--
-- TOC entry 7014 (class 0 OID 0)
-- Dependencies: 644
-- Name: TABLE modcomment; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modcomment FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modcomment FROM bradley;
GRANT ALL ON TABLE sciapp.modcomment TO bradley;
GRANT SELECT ON TABLE sciapp.modcomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.modcomment TO pts_write;
GRANT ALL ON TABLE sciapp.modcomment TO pts_admin;


--
-- TOC entry 7018 (class 0 OID 0)
-- Dependencies: 645
-- Name: TABLE modcontact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modcontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modcontact FROM bradley;
GRANT ALL ON TABLE sciapp.modcontact TO bradley;
GRANT SELECT ON TABLE sciapp.modcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.modcontact TO pts_write;
GRANT ALL ON TABLE sciapp.modcontact TO pts_admin;


--
-- TOC entry 7019 (class 0 OID 0)
-- Dependencies: 646
-- Name: TABLE moddocstatuslist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.moddocstatuslist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.moddocstatuslist FROM bradley;
GRANT ALL ON TABLE sciapp.moddocstatuslist TO bradley;
GRANT SELECT ON TABLE sciapp.moddocstatuslist TO pts_read;
GRANT ALL ON TABLE sciapp.moddocstatuslist TO pts_admin;


--
-- TOC entry 7020 (class 0 OID 0)
-- Dependencies: 647
-- Name: TABLE modificationcontactlist; Type: ACL; Schema: sciapp; Owner: pts_admin
--

REVOKE ALL ON TABLE sciapp.modificationcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modificationcontactlist FROM pts_admin;
GRANT ALL ON TABLE sciapp.modificationcontactlist TO pts_admin;
GRANT SELECT ON TABLE sciapp.modificationcontactlist TO pts_read;


--
-- TOC entry 7021 (class 0 OID 0)
-- Dependencies: 648
-- Name: TABLE modificationlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modificationlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modificationlist FROM bradley;
GRANT ALL ON TABLE sciapp.modificationlist TO bradley;
GRANT SELECT ON TABLE sciapp.modificationlist TO pts_read;
GRANT ALL ON TABLE sciapp.modificationlist TO pts_admin;


--
-- TOC entry 7023 (class 0 OID 0)
-- Dependencies: 649
-- Name: TABLE modstatuslist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.modstatuslist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.modstatuslist FROM bradley;
GRANT ALL ON TABLE sciapp.modstatuslist TO bradley;
GRANT SELECT ON TABLE sciapp.modstatuslist TO pts_read;
GRANT ALL ON TABLE sciapp.modstatuslist TO pts_admin;


--
-- TOC entry 7024 (class 0 OID 0)
-- Dependencies: 650
-- Name: TABLE noticesent; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.noticesent FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.noticesent FROM bradley;
GRANT ALL ON TABLE sciapp.noticesent TO bradley;
GRANT SELECT ON TABLE sciapp.noticesent TO pts_read;
GRANT ALL ON TABLE sciapp.noticesent TO pts_admin;


--
-- TOC entry 7032 (class 0 OID 0)
-- Dependencies: 651
-- Name: TABLE onlineresource; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.onlineresource FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.onlineresource FROM bradley;
GRANT ALL ON TABLE sciapp.onlineresource TO bradley;
GRANT SELECT ON TABLE sciapp.onlineresource TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.onlineresource TO pts_write;
GRANT ALL ON TABLE sciapp.onlineresource TO pts_admin;


--
-- TOC entry 7033 (class 0 OID 0)
-- Dependencies: 652
-- Name: TABLE personpositionlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.personpositionlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.personpositionlist FROM bradley;
GRANT ALL ON TABLE sciapp.personpositionlist TO bradley;
GRANT SELECT ON TABLE sciapp.personpositionlist TO pts_read;
GRANT ALL ON TABLE sciapp.personpositionlist TO pts_admin;


--
-- TOC entry 7034 (class 0 OID 0)
-- Dependencies: 653
-- Name: TABLE postalcodelist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.postalcodelist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.postalcodelist FROM bradley;
GRANT ALL ON TABLE sciapp.postalcodelist TO bradley;
GRANT SELECT ON TABLE sciapp.postalcodelist TO pts_read;
GRANT ALL ON TABLE sciapp.postalcodelist TO pts_admin;


--
-- TOC entry 7038 (class 0 OID 0)
-- Dependencies: 654
-- Name: TABLE productcontact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productcontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productcontact FROM bradley;
GRANT ALL ON TABLE sciapp.productcontact TO bradley;
GRANT SELECT ON TABLE sciapp.productcontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productcontact TO pts_write;
GRANT ALL ON TABLE sciapp.productcontact TO pts_admin;


--
-- TOC entry 7039 (class 0 OID 0)
-- Dependencies: 655
-- Name: TABLE productallcontacts; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productallcontacts FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productallcontacts FROM bradley;
GRANT ALL ON TABLE sciapp.productallcontacts TO bradley;
GRANT SELECT ON TABLE sciapp.productallcontacts TO pts_read;
GRANT ALL ON TABLE sciapp.productallcontacts TO pts_admin;


--
-- TOC entry 7040 (class 0 OID 0)
-- Dependencies: 656
-- Name: TABLE productcontactlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productcontactlist FROM bradley;
GRANT ALL ON TABLE sciapp.productcontactlist TO bradley;
GRANT SELECT ON TABLE sciapp.productcontactlist TO pts_read;
GRANT ALL ON TABLE sciapp.productcontactlist TO pts_admin;


--
-- TOC entry 7041 (class 0 OID 0)
-- Dependencies: 657
-- Name: TABLE productfeature; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productfeature FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productfeature FROM bradley;
GRANT ALL ON TABLE sciapp.productfeature TO bradley;
GRANT SELECT ON TABLE sciapp.productfeature TO pts_read;
GRANT ALL ON TABLE sciapp.productfeature TO pts_admin;


--
-- TOC entry 7042 (class 0 OID 0)
-- Dependencies: 658
-- Name: TABLE productgrouplist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productgrouplist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productgrouplist FROM bradley;
GRANT ALL ON TABLE sciapp.productgrouplist TO bradley;
GRANT SELECT ON TABLE sciapp.productgrouplist TO pts_read;
GRANT ALL ON TABLE sciapp.productgrouplist TO pts_admin;


--
-- TOC entry 7043 (class 0 OID 0)
-- Dependencies: 659
-- Name: TABLE productkeywordlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productkeywordlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productkeywordlist FROM bradley;
GRANT ALL ON TABLE sciapp.productkeywordlist TO bradley;
GRANT SELECT ON TABLE sciapp.productkeywordlist TO pts_read;
GRANT ALL ON TABLE sciapp.productkeywordlist TO pts_admin;


--
-- TOC entry 7044 (class 0 OID 0)
-- Dependencies: 660
-- Name: TABLE productlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productlist FROM bradley;
GRANT ALL ON TABLE sciapp.productlist TO bradley;
GRANT SELECT ON TABLE sciapp.productlist TO pts_read;
GRANT ALL ON TABLE sciapp.productlist TO pts_admin;


--
-- TOC entry 7045 (class 0 OID 0)
-- Dependencies: 661
-- Name: TABLE productmetadata; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productmetadata FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productmetadata FROM bradley;
GRANT ALL ON TABLE sciapp.productmetadata TO bradley;
GRANT SELECT ON TABLE sciapp.productmetadata TO pts_read;
GRANT ALL ON TABLE sciapp.productmetadata TO pts_admin;


--
-- TOC entry 7051 (class 0 OID 0)
-- Dependencies: 662
-- Name: TABLE productstatus; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productstatus FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productstatus FROM bradley;
GRANT ALL ON TABLE sciapp.productstatus TO bradley;
GRANT SELECT ON TABLE sciapp.productstatus TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productstatus TO pts_write;
GRANT ALL ON TABLE sciapp.productstatus TO pts_admin;


--
-- TOC entry 7057 (class 0 OID 0)
-- Dependencies: 663
-- Name: TABLE productstep; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.productstep FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.productstep FROM bradley;
GRANT ALL ON TABLE sciapp.productstep TO bradley;
GRANT SELECT ON TABLE sciapp.productstep TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.productstep TO pts_write;
GRANT ALL ON TABLE sciapp.productstep TO pts_admin;


--
-- TOC entry 7062 (class 0 OID 0)
-- Dependencies: 664
-- Name: TABLE progress; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.progress FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.progress FROM bradley;
GRANT ALL ON TABLE sciapp.progress TO bradley;
GRANT SELECT ON TABLE sciapp.progress TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.progress TO pts_write;
GRANT ALL ON TABLE sciapp.progress TO pts_admin;


--
-- TOC entry 7064 (class 0 OID 0)
-- Dependencies: 665
-- Name: TABLE projectadmin; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectadmin FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectadmin FROM bradley;
GRANT ALL ON TABLE sciapp.projectadmin TO bradley;
GRANT SELECT ON TABLE sciapp.projectadmin TO pts_read;
GRANT ALL ON TABLE sciapp.projectadmin TO pts_admin;


--
-- TOC entry 7065 (class 0 OID 0)
-- Dependencies: 666
-- Name: TABLE projectagreementnumbers; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectagreementnumbers FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectagreementnumbers FROM bradley;
GRANT ALL ON TABLE sciapp.projectagreementnumbers TO bradley;
GRANT SELECT ON TABLE sciapp.projectagreementnumbers TO pts_read;
GRANT ALL ON TABLE sciapp.projectagreementnumbers TO pts_admin;


--
-- TOC entry 7066 (class 0 OID 0)
-- Dependencies: 667
-- Name: TABLE projectallcontacts; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectallcontacts FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectallcontacts FROM bradley;
GRANT ALL ON TABLE sciapp.projectallcontacts TO bradley;
GRANT SELECT ON TABLE sciapp.projectallcontacts TO pts_read;
GRANT ALL ON TABLE sciapp.projectallcontacts TO pts_admin;


--
-- TOC entry 7068 (class 0 OID 0)
-- Dependencies: 668
-- Name: TABLE projectawardinfo; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectawardinfo FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectawardinfo FROM bradley;
GRANT ALL ON TABLE sciapp.projectawardinfo TO bradley;
GRANT SELECT ON TABLE sciapp.projectawardinfo TO pts_read;
GRANT ALL ON TABLE sciapp.projectawardinfo TO pts_admin;


--
-- TOC entry 7069 (class 0 OID 0)
-- Dependencies: 669
-- Name: TABLE projectcatalog; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectcatalog FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectcatalog FROM bradley;
GRANT ALL ON TABLE sciapp.projectcatalog TO bradley;
GRANT SELECT ON TABLE sciapp.projectcatalog TO pts_read;
GRANT ALL ON TABLE sciapp.projectcatalog TO pts_admin;


--
-- TOC entry 7075 (class 0 OID 0)
-- Dependencies: 670
-- Name: TABLE projectcomment; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectcomment FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectcomment FROM bradley;
GRANT ALL ON TABLE sciapp.projectcomment TO bradley;
GRANT SELECT ON TABLE sciapp.projectcomment TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectcomment TO pts_write;
GRANT ALL ON TABLE sciapp.projectcomment TO pts_admin;


--
-- TOC entry 7076 (class 0 OID 0)
-- Dependencies: 671
-- Name: TABLE projectcontactfull; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectcontactfull FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectcontactfull FROM bradley;
GRANT ALL ON TABLE sciapp.projectcontactfull TO bradley;
GRANT SELECT ON TABLE sciapp.projectcontactfull TO pts_read;
GRANT ALL ON TABLE sciapp.projectcontactfull TO pts_admin;


--
-- TOC entry 7077 (class 0 OID 0)
-- Dependencies: 672
-- Name: TABLE projectcontactlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectcontactlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectcontactlist FROM bradley;
GRANT ALL ON TABLE sciapp.projectcontactlist TO bradley;
GRANT SELECT ON TABLE sciapp.projectcontactlist TO pts_read;
GRANT ALL ON TABLE sciapp.projectcontactlist TO pts_admin;


--
-- TOC entry 7078 (class 0 OID 0)
-- Dependencies: 673
-- Name: TABLE projectfeature; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectfeature FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectfeature FROM bradley;
GRANT ALL ON TABLE sciapp.projectfeature TO bradley;
GRANT SELECT ON TABLE sciapp.projectfeature TO pts_read;
GRANT ALL ON TABLE sciapp.projectfeature TO pts_admin;


--
-- TOC entry 7079 (class 0 OID 0)
-- Dependencies: 674
-- Name: TABLE projectfunderlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectfunderlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectfunderlist FROM bradley;
GRANT ALL ON TABLE sciapp.projectfunderlist TO bradley;
GRANT SELECT ON TABLE sciapp.projectfunderlist TO pts_read;
GRANT ALL ON TABLE sciapp.projectfunderlist TO pts_admin;


--
-- TOC entry 7080 (class 0 OID 0)
-- Dependencies: 675
-- Name: TABLE projectfunding; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectfunding FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectfunding FROM bradley;
GRANT ALL ON TABLE sciapp.projectfunding TO bradley;
GRANT SELECT ON TABLE sciapp.projectfunding TO pts_read;
GRANT SELECT ON TABLE sciapp.projectfunding TO pts_write;
GRANT ALL ON TABLE sciapp.projectfunding TO pts_admin;


--
-- TOC entry 7082 (class 0 OID 0)
-- Dependencies: 676
-- Name: TABLE projectgnis; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectgnis FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectgnis FROM bradley;
GRANT ALL ON TABLE sciapp.projectgnis TO bradley;
GRANT SELECT ON TABLE sciapp.projectgnis TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectgnis TO pts_write;
GRANT ALL ON TABLE sciapp.projectgnis TO pts_admin;


--
-- TOC entry 7086 (class 0 OID 0)
-- Dependencies: 677
-- Name: TABLE projectitis; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectitis FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectitis FROM bradley;
GRANT ALL ON TABLE sciapp.projectitis TO bradley;
GRANT SELECT ON TABLE sciapp.projectitis TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.projectitis TO pts_write;
GRANT ALL ON TABLE sciapp.projectitis TO pts_admin;


--
-- TOC entry 7087 (class 0 OID 0)
-- Dependencies: 678
-- Name: TABLE projectkeywordlist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectkeywordlist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectkeywordlist FROM bradley;
GRANT ALL ON TABLE sciapp.projectkeywordlist TO bradley;
GRANT SELECT ON TABLE sciapp.projectkeywordlist TO pts_read;
GRANT ALL ON TABLE sciapp.projectkeywordlist TO pts_admin;


--
-- TOC entry 7088 (class 0 OID 0)
-- Dependencies: 679
-- Name: TABLE projectkeywords; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectkeywords FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectkeywords FROM bradley;
GRANT ALL ON TABLE sciapp.projectkeywords TO bradley;
GRANT SELECT ON TABLE sciapp.projectkeywords TO pts_read;
GRANT ALL ON TABLE sciapp.projectkeywords TO pts_admin;


--
-- TOC entry 7089 (class 0 OID 0)
-- Dependencies: 680
-- Name: TABLE projectmetadata; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.projectmetadata FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.projectmetadata FROM bradley;
GRANT ALL ON TABLE sciapp.projectmetadata TO bradley;
GRANT SELECT ON TABLE sciapp.projectmetadata TO pts_read;
GRANT ALL ON TABLE sciapp.projectmetadata TO pts_admin;


--
-- TOC entry 7093 (class 0 OID 0)
-- Dependencies: 681
-- Name: TABLE purchaserequest; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.purchaserequest FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.purchaserequest FROM bradley;
GRANT ALL ON TABLE sciapp.purchaserequest TO bradley;
GRANT SELECT ON TABLE sciapp.purchaserequest TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.purchaserequest TO pts_write;
GRANT ALL ON TABLE sciapp.purchaserequest TO pts_admin;


--
-- TOC entry 7101 (class 0 OID 0)
-- Dependencies: 682
-- Name: TABLE reminder; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.reminder FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.reminder FROM bradley;
GRANT ALL ON TABLE sciapp.reminder TO bradley;
GRANT SELECT ON TABLE sciapp.reminder TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.reminder TO pts_write;
GRANT ALL ON TABLE sciapp.reminder TO pts_admin;


--
-- TOC entry 7104 (class 0 OID 0)
-- Dependencies: 683
-- Name: TABLE remindercontact; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.remindercontact FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.remindercontact FROM bradley;
GRANT ALL ON TABLE sciapp.remindercontact TO bradley;
GRANT SELECT ON TABLE sciapp.remindercontact TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.remindercontact TO pts_write;
GRANT ALL ON TABLE sciapp.remindercontact TO pts_admin;


--
-- TOC entry 7105 (class 0 OID 0)
-- Dependencies: 684
-- Name: TABLE shortprojectsummary; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.shortprojectsummary FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.shortprojectsummary FROM bradley;
GRANT ALL ON TABLE sciapp.shortprojectsummary TO bradley;
GRANT SELECT ON TABLE sciapp.shortprojectsummary TO pts_read;
GRANT ALL ON TABLE sciapp.shortprojectsummary TO pts_admin;


--
-- TOC entry 7106 (class 0 OID 0)
-- Dependencies: 685
-- Name: TABLE statelist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.statelist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.statelist FROM bradley;
GRANT ALL ON TABLE sciapp.statelist TO bradley;
GRANT SELECT ON TABLE sciapp.statelist TO pts_read;
GRANT ALL ON TABLE sciapp.statelist TO pts_admin;


--
-- TOC entry 7107 (class 0 OID 0)
-- Dependencies: 686
-- Name: TABLE statuslist; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.statuslist FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.statuslist FROM bradley;
GRANT ALL ON TABLE sciapp.statuslist TO bradley;
GRANT SELECT ON TABLE sciapp.statuslist TO pts_read;
GRANT ALL ON TABLE sciapp.statuslist TO pts_admin;


--
-- TOC entry 7109 (class 0 OID 0)
-- Dependencies: 687
-- Name: TABLE task; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.task FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.task FROM bradley;
GRANT ALL ON TABLE sciapp.task TO bradley;
GRANT SELECT ON TABLE sciapp.task TO pts_read;
GRANT ALL ON TABLE sciapp.task TO pts_admin;


--
-- TOC entry 7112 (class 0 OID 0)
-- Dependencies: 688
-- Name: TABLE timeline; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.timeline FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.timeline FROM bradley;
GRANT ALL ON TABLE sciapp.timeline TO bradley;
GRANT SELECT ON TABLE sciapp.timeline TO pts_read;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sciapp.timeline TO pts_write;
GRANT ALL ON TABLE sciapp.timeline TO pts_admin;


--
-- TOC entry 7113 (class 0 OID 0)
-- Dependencies: 689
-- Name: TABLE userinfo; Type: ACL; Schema: sciapp; Owner: bradley
--

REVOKE ALL ON TABLE sciapp.userinfo FROM PUBLIC;
REVOKE ALL ON TABLE sciapp.userinfo FROM bradley;
GRANT ALL ON TABLE sciapp.userinfo TO bradley;
GRANT SELECT ON TABLE sciapp.userinfo TO pts_read;
GRANT ALL ON TABLE sciapp.userinfo TO pts_admin;


-- Completed on 2018-11-07 16:22:52 AKST

--
-- PostgreSQL database dump complete
--
