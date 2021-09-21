import json
import sys
import logging
import pymysql
import hashlib
import jwt
from datetime import date

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
    token = event['token']
    # TODO implement
    data = []
    data1 = jwt.decode(token, options={"verify_signature": False})
    farmer_email = data1["email"]
    item_count = 0
    with conn.cursor() as cur:
        sql = "select * from `products` where `farmer_email`=%s"
        cur.execute(sql, farmer_email)
        for row in cur:
            item_count += 1
            logger.info(row)
            data.append(row)
    conn.commit()

    return {
        'statusCode': 200,
        'body': data
    }
