import json
import sys
import logging
import pymysql
import hashlib
# rds setting
rds_host = "<<RDS_HOST_ENDPOINT>>"
name = "<<RDS_HOST_USERNAME>>"
password = "<<RDS_PASSWORD>>"
db_name = "<<DB_NAME>>"

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(host=rds_host, user=name,
                           passwd=password, db=db_name, connect_timeout=5)
except pymysql.MySQLError as e:
    logger.error(
        "ERROR: Unexpected error: Could not connect to MySQL instance.")
    logger.error(e)
    sys.exit()
print("Success")
logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")


def lambda_handler(event, context):
    # TODO implement
    fname = event['fname']
    lname = event['lname']
    email = event['email']
    phone_number = event["phone_number"]
    password = event['password']
    data = []
    item_count = 0
    with conn.cursor() as cur:
        sql = "INSERT INTO `customer` (`fname`, `lname`, `email`, `phone_number`, `password`) values(%s, %s, %s, %s, MD5(%s))"
        cur.execute(sql, (fname, lname, email, phone_number, password))
        cur.execute("select * from customer")
        for row in cur:
            item_count += 1
            logger.info(row)
            data.append(row)
            print(row)
    conn.commit()

    return{
        'status': 200,
        'body': data
    }
