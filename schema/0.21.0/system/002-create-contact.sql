INSERT INTO sciapp.contact(contactid, contacttypeid)
VALUES (nextval('contact_contactid_seq'::regclass),
        3);

INSERT INTO sciapp.contactgroup(contactid, organization, name, acronym)
VALUES (currval('contact_contactid_seq'::regclass),
        TRUE,
        'Science Applications',
        'OSA');

INSERT INTO groupschema(groupschemaid, groupid, displayname, sciencebaseid)
VALUES ('sciapp',
        currval('contact_contactid_seq'::regclass),
        'Science Applications',
        '5b646a2fe4b006a11f73390c');
