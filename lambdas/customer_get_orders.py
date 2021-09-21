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
    data = jwt.decode(token, options={"verify_signature": False})
    customer_email = data["email"]
    user_type = event['user']

    order_data = []
    if user_type == 'customer':
        with conn.cursor() as cur:
            sql = "SELECT * FROM `order_details` where `customer_email` = %s"
            cur.execute(sql, customer_email)
            for row in cur:
                order_data.append(row)
        conn.commit()

    else:
        with conn.cursor() as cur:
            sql = "SELECT * FROM `order_details` where farmer_email = %s"
            cur.execute(sql, customer_email)
            for row in cur:
                order_data.append(row)
        conn.commit()

    return{
        "order_data": order_data,
        "data": data
    }
