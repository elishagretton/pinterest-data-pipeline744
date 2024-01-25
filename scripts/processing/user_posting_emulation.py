import requests
from time import sleep
import random
from multiprocessing import Process
import boto3
import json
import sqlalchemy
from sqlalchemy import text
from datetime import datetime

random.seed(100)

class AWSDBConnector:
    """
    A class for creating a MySQL database connector for the Pinterest project.

    Attributes:
    - HOST (str): The hostname of the MySQL database server.
    - USER (str): The username for connecting to the database.
    - PASSWORD (str): The password for connecting to the database.
    - DATABASE (str): The name of the database to connect to.
    - PORT (int): The port number to use for the database connection.

    Methods:
    - create_db_connector(): Creates and returns a SQLAlchemy engine for connecting to the MySQL database.
    """
    def __init__(self):
        """
        Initializes the AWSDBConnector with default values for database connection.
        """
        self.HOST = "pinterestdbreadonly.cq2e8zno855e.eu-west-1.rds.amazonaws.com"
        self.USER = 'project_user'
        self.PASSWORD = ':t%;yCY3Yjg'
        self.DATABASE = 'pinterest_data'
        self.PORT = 3306
        
    def create_db_connector(self):
        """
        Creates and returns a SQLAlchemy engine for connecting to the MySQL database.

        Returns:
        - engine (sqlalchemy.engine.base.Engine): SQLAlchemy engine object for database connection.
        """
        engine = sqlalchemy.create_engine(f"mysql+pymysql://{self.USER}:{self.PASSWORD}@{self.HOST}:{self.PORT}/{self.DATABASE}?charset=utf8mb4")
        return engine

def serialize_datetime(obj):
    """
    Serialize datetime objects to ISO format.

    Parameters:
    - obj (datetime): The datetime object to be serialized.

    Returns:
    - str: The serialized datetime in ISO format.

    Raises:
    - TypeError: If the input object is not a datetime object.

    Example:
    >>> dt = datetime(2022, 1, 1, 12, 0, 0)
    >>> serialize_datetime(dt)
    '2022-01-01T12:00:00'
    """

    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError("Type not serializable")

def send_to_kafka(records, topic_name):
    """
    Sends data to the corresponding Kafka topic.

    Parameters:
    - records (dict): The data records to be written to the topic.
    - topic_name (str): The name of the corresponding Kafka topic.
    """
    # Construct API endpoint URL for Kafka topics
    invoke_url = "https://t5v6ab37u9.execute-api.us-east-1.amazonaws.com/test/topics/" + topic_name
    
    # Serialize datetime objects using the custom serializer
    payload = json.dumps({"records": [{"value": records}]}, default=serialize_datetime)
    
    # Set request headers
    headers = {'Content-Type': 'application/vnd.kafka.json.v2+json'}
    
    # Make a POST request to the specified API endpoint
    response = requests.post(invoke_url, headers=headers, data=payload)

    # Check the HTTP response status code
    if response.status_code == 200:
        print(f"Data sent to Kafka topic {topic_name}")
    else:
        print(f"Failed to send data to Kafka topic {topic_name}. Status code: {response.status_code}")

new_connector = AWSDBConnector()
def run_infinite_post_data_loop():
    """
    Run an infinite loop to fetch random rows from Pinterest posts, geolocation, and user data tables,
    and send the selected data to corresponding Kafka topics.

    This function uses a MySQL database connector, selects a random row from each table in the database,
    and sends the data to Kafka topics "12c0d092d679.pin", "12c0d092d679.geo", and "12c0d092d679.user" respectively.

    Note:
    The function will run indefinitely until manually interrupted.

    Returns:
    None
    """
    while True:
        sleep(random.randrange(0, 2))
        random_row = random.randint(0, 11000)

        # Connect to engine
        engine = new_connector.create_db_connector()

        # Retrieve post, geolocation, and user data
        with engine.connect() as connection:

            pin_string = text(f"SELECT * FROM pinterest_data LIMIT {random_row}, 1")
            pin_selected_row = connection.execute(pin_string)
            
            for row in pin_selected_row:
                pin_result = dict(row._mapping)

            geo_string = text(f"SELECT * FROM geolocation_data LIMIT {random_row}, 1")
            geo_selected_row = connection.execute(geo_string)
            
            for row in geo_selected_row:
                geo_result = dict(row._mapping)

            user_string = text(f"SELECT * FROM user_data LIMIT {random_row}, 1")
            user_selected_row = connection.execute(user_string)
            
            for row in user_selected_row:
                user_result = dict(row._mapping)

            # Send data to Kafka
            send_to_kafka(pin_result, "12c0d092d679.pin")
            send_to_kafka(geo_result, "12c0d092d679.geo")
            send_to_kafka(user_result, "12c0d092d679.user")

if __name__ == "__main__":
    run_infinite_post_data_loop()
    print('Working')