import json
import urllib.parse
import boto3
import sys,os
import smtplib, ssl


s3 = boto3.client('s3')

def lambda_handler(event, context):
    
    customer_email = event['customer_email']
    farmer_emails = event['farmer_email']
    
    smtp_server = "smtp.gmail.com"
    port = 587  # For starttls
    sender_email = "mockgroup4.q@gmail.com"
    password = "Abcd@123"
    
    # Create a secure SSL context
    context = ssl.create_default_context()
    server = smtplib.SMTP(smtp_server,port)    
    # Try to log in to server and send email
    try:

        server.ehlo() # Can be omitted
        server.starttls(context=context) # Secure the connection
        server.ehlo() # Can be omitted
        server.login(sender_email, password)
        
        # TODO: Send email here
        email_body = 'Your order has been confirmed'
        server.sendmail(sender_email, customer_email, email_body)
        for farmer_email in farmer_emails:
            farmer_email_body = "You have a new order. Login to portal and check order"
            server.sendmail(sender_email, farmer_email, farmer_email_body)
            
    except Exception as e:
        # Print any error messages to stdout
        print(e)
    finally:
        server.quit()
    
    return{
        "body" : "Email was sent successfully"
    }