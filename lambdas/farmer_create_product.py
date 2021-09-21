import json
import sys
import logging
import pymysql
import base64
import boto3
import jwt


sns = boto3.client('sns')

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
    token = event['token']
    data = jwt.decode(token, options={"verify_signature": False})
    farmer_email = data["email"]
    name = event['name']
    qty = event['qty']
    price = event["price"]
    image = event["image"]
    data = []
    item_count = 0
    with conn.cursor() as cur:
        sql = "select `farmer_id` from `farmer` where `email` = %s"
        id = cur.execute(sql, farmer_email)
    conn.commit()
    with conn.cursor() as cur:
        sql = "INSERT INTO `products` (`name`, `farmer_id`, `qty`, `price`, `image`, `farmer_email`) values(%s, %s, %s, %s, %s, %s)"
        cur.execute(sql, (name, id, qty, price, image, farmer_email))
        cur.execute("select * from products")
        for row in cur:
            item_count += 1
            logger.info(row)
            data.append(row)
            print(row)
    conn.commit()

    sns.publish(TopicArn='<<Topic ARN>>',
                Message="We are having a sale on 30 September 2021", Subject='Promotional Email')

    return{
        'status': 200,
        'event': event
    }
