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
    cart_data = event['cart']
    token = event['token']
    data = jwt.decode(token, options={"verify_signature": False})
    print(cart_data)
    print(data)
    customer_email = data["email"]
    total_cost = 0

    # Getting total cost of the order
    whole_cart = []
    farmer_emails = []
    for cart_item in cart_data:
        cart_itm = []
        product_cost = int(cart_item["count"])*int(cart_item["price"])
        total_cost += product_cost
        cart_itm.append(cart_item["name"])
        cart_itm.append(int(cart_item["price"]))
        cart_itm.append(int(cart_item["count"]))
        cart_itm.append(int(cart_item["product_id"]))
        cart_itm.append(customer_email)
        cart_itm.append(cart_item["farmer_email"])
        whole_cart.append(cart_itm)
        farmer_emails.append(cart_item["farmer_email"])
    print(total_cost)

    set_farmers = set(farmer_emails)
    final_list = list(set_farmers)

    # Getting the order date
    today = str(date.today())
    order_date = today

    with conn.cursor() as cur:
        sql = "SELECT customer_id FROM `customer` WHERE `email`=%s"
        customer_id = cur.execute(sql, (customer_email))
        print(customer_id)

        sql = "INSERT INTO `orders` (`customer_id`, `order_date`, `total_cost`) values(%s, %s, %s)"
        cur.execute(sql, (customer_id, order_date, total_cost))
        current_order_id = cur.lastrowid

        for cart_itm in whole_cart:
            cart_itm.append(int(current_order_id))
        print(whole_cart)
        sql = "INSERT INTO `order_details` (`product_name`, `cost`, `qty`, `product_id`, `customer_email`, `farmer_email`, `order_id`) values(%s, %s, %s, %s, %s, %s, %s)"
        cur.executemany(sql, whole_cart)

        for cart_item in cart_data:
            final_qty = int(cart_item['quantity']) - int(cart_item['count'])
            sql = "UPDATE `products` SET `qty` = %s WHERE product_id = %s"
            cur.execute(sql, (final_qty, cart_item['product_id']))

    conn.commit()

    return {
        "data": data,
        "status": 200,
        "customer_id": customer_id,
        "total_cost": total_cost,
        "farmer_emails": final_list
    }
