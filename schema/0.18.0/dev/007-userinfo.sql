-- View: dev.userinfo

-- DROP VIEW dev.userinfo;

CREATE OR REPLACE VIEW dev.userinfo AS 
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
   FROM login
     JOIN logingroupschema USING (loginid)
     JOIN groupschema USING (groupschemaid)
     JOIN contactgroup ON groupschema.groupid = contactgroup.contactid
     JOIN person ON logingroupschema.contactid = person.contactid
  WHERE logingroupschema.groupschemaid::name = ANY (current_schemas(false));
