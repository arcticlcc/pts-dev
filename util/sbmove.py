#!/usr/bin/python
#
# Script to move published product items on ScienceBase
#

import psycopg2
import yaml
import time
#import getpass
import pysb #https://my.usgs.gov/bitbucket/projects/SBE/repos/pysb/browse

with open('../config/db.yml', 'r') as f:
    dbconfig = yaml.load(f)

psql = dbconfig['dbOptions']['psql']

try:
    conn = psycopg2.connect("dbname='{dbname}' user='{user}' host='{host}' password='{password}' port='{port}'".format(
        dbname=psql["dbname"],
        host=psql["host"],
        user=psql["user"],
        password=psql["password"],
        port=psql["port"]
    ))
except:
    print "I am unable to connect to the database"

schema = raw_input("Please enter the schema: ") or 'dev'

cur = conn.cursor()
cur.execute("""SELECT pd.sciencebaseid,
       COALESCE(pg.sciencebaseid, pj.sciencebaseid) AS parent--,
       --pg.sciencebaseid pgid,
       --pj.sciencebaseid pjid,
       --pg.productid AS pgpid
FROM {schema}.product pd
JOIN {schema}.project pj USING (projectid)
LEFT JOIN
  (SELECT *
   FROM {schema}.product
   WHERE sciencebaseid IS NOT NULL) pg ON pd.productgroupid = pg.productid
WHERE pd.sciencebaseid IS NOT NULL
   AND COALESCE(pg.sciencebaseid, pj.sciencebaseid) IS NOT NULL;""".format(schema=schema))

rows = cur.fetchall()

sb = pysb.SbSession()

sbuser = raw_input("Please enter your ScienceBase id: ")
#pswd = getpass.getpass('SB Password:')

sb.loginc(str(sbuser))
# Need to wait a bit after the login or errors can occur
time.sleep(5)

print "\nMoving items:\n"
for row in rows:
    print "    ","Moving {item} under {parent}".format(item = row[0], parent=row[1])
    #move_item(item_id, parent_id) Move the ScienceBase Item with the given item_id under the ScienceBase Item with the given parent_id.
    sb.move_item(row[0],row[1])
print "\nDone!\n"
