import json
import boto3
from decimal import Decimal

# Custom JSON encoder to handle Decimal objects
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return str(o)  # Convert Decimal to string
        return super(DecimalEncoder, self).default(o)

#Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('latechanista_counter')

#Increment view count
def lambda_handler(event, context):
    try:
        response = table.get_item(
            Key={'id':'1'})
        
        views_count = response['Item']['views_count']
        views_count = views_count + 1
        print(views_count)
        response = table.put_item(Item={'id':'1', 'views_count': views_count})
        
        return {
            'statusCode': 200,
            'body': json.dumps({'data': views_count}, cls=DecimalEncoder),
            'headers': {
                'Content-Type': 'application/json'}
        }
        
    except Exception as e:
        print(f"An error occurred:{e}")
        
        return {
            'statusCode': 500,
            'body': json.dumps('Error Occurred')
        }