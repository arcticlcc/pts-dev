INSERT INTO acp.contact(contactid, contacttypeid)
VALUES (nextval('contact_contactid_seq'::regclass),
        3);

INSERT INTO acp.contactgroup(contactid, organization, name, acronym)
VALUES (currval('contact_contactid_seq'::regclass),
        TRUE,
        'Arctic Coastal Plain',
        'ACP');

INSERT INTO groupschema(groupschemaid, groupid, displayname)
VALUES ('acp',
        currval('contact_contactid_seq'::regclass),
        'Arctic Coastal Plain'
        );
