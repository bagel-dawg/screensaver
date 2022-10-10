import uuid
import boto3
import base64
import os
import logging

logger = logging.getLogger(__name__)
# Remove any default log handlers
# since we only want to log to stdout
for handler in logger.handlers:
    logger.removeHandler(handler)
# Set the log stream handlers for stdout
handler = logging.StreamHandler()
# Grab the logging level from environment var
# if not found, et log level to warning
log_level = os.environ.get('LOG_LEVEL', 'WARNING').upper()
logger.setLevel(log_level)
# Configure the format of the logs
formatter = logging.Formatter('{%(asctime)s:%(pathname)s:%(lineno)d} %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S')
handler.setFormatter(formatter)
logger.addHandler(handler)



def lambda_handler(event, context):
    logger.debug(event)
    logger.debug(context)
    
    if os.environ.get("TOKEN") != event["headers"]["screensaver-api-token"]:
        return { 'statusCode': 403, 'body': 'Unauthorized' }

    body = event['body']
    logger.debug(body)

    generated_name = uuid.uuid4()
    s3_bucket      = os.environ.get("S3_BUCKET")
    base_url       = os.environ.get("BASE_URL")

    logger.debug("writing snapshot to s")
    f = open('/tmp/ss.png', 'wb')
    f.write(base64.b64decode(body))
    f.close()

    client = boto3.client('s3')
    client.put_object(
        Body=open('/tmp/ss.png', 'rb'),
        Bucket=s3_bucket, Key='images/{}.png'.format(generated_name),
        ContentType='image/png'
    )
    return_body = "{base_url}/{ss_name}.png".format( base_url=base_url, ss_name=generated_name)
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/plain'},
        'body': return_body 
    }