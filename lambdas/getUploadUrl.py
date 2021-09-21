import boto3
import base64

def lambda_handler(event, context):
    s3 = boto3.resource(u's3')
    bucket = s3.Bucket(u'mock-group-4')
    path_test = '/tmp/output'         # temp path in lambda.
    key = event['ImageName']          # assign filename to 'key' variable
    data = event['img64']             # assign base64 of an image to data variable 
    data1 = data
    img = base64.b64decode(data1)     # decode the encoded image data (base64)
    with open(path_test, 'wb') as data:
        #data.write(data1)
        data.write(img)
        bucket.upload_file(path_test, key)   # Upload image directly inside bucket
        #bucket.upload_file(path_test, 'FOLDERNAME-IN-YOUR-BUCKET /{}'.format(key))    # Upload image inside folder of your s3 bucket.
    print('res---------------->',path_test)
    print('key---------------->',key)

    return {
        'status': 'True',
       'statusCode': 200,
       'body': 'Image Uploaded'
      }