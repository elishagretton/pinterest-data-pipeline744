# Milestone 3: Configuring an API on API Gateway

Previously, we established an MSK cluster and created a connector to store data in the S3 bucket. In this milestone, we build an API to allow data to be transmitted to the cluster, which is then stored in the bucket.

In this milestone, we learn:

- How to create a proxy API and create a GET integration
- How to deploy an API in API Gateway.
- How to configure the Kafka REST Proxy on the EC2 client machine by downloading the Confluent package
- How to add IAM authentication to the MSK cluster and begin the REST proxy on the EC2 machine.
- How to modify the `user_posting_emulation.py` to send data to the Kafka topics using the API Invoke URL and how to check this.

To view the whole script, please head to [`scripts/milestones/batch-data-api-configuration.sh.`](../scripts/milestones/batch-data-api-configuration.sh)

## Step 1: Build a Kafka REST proxy integration method for the API

An API named `12c0d092d679` (my AWS username) has been provided by AiCore for the purpose of this project.

First, locate to the API Gateway in the AWS Management console. We will begin with creating a proxy integration for the API.

Proxy integrations provide the selected integration access to many resources and features at once, without specifying multiple resource paths using the greedy parameter, {proxy+}. This is simple solution to providing the integration with access to all available resources without having to specify all available paths as the API grows.

In the AWS Management console, follow these steps:

- Locate to the `API Gateway`
- Select `Create Resource`
- Turn on the `Proxy Configuration` toggle and specify `Resource Name` as `{proxy+}`. Also `Enable CORS.` Click `Create Resource`.
- Locate to the `ANY` method and select and click `Edit Integration`.
- Select a `HTTP` method, turn the `HTTP Proxy` toggle on, select `HTTP ANY` method and set the `Endpoint URL` as `http://ec2-3-81-111-233.compute-1.amazonaws.com:8082/{proxy}`. Select `Create integration`.
- Finally select `Deploy API`, and create a new stage called `test`.

The proxy integration has now been created for the API.

## Step 2: Set up the Kafka REST policy on the EC2 client.

Now that the Kafka REST Proxy integration is set up for the API, the Kafka REST Proxy needs to be set on the EC2 client machine.

To do this, we begin with installing the appropriate Confluent package.

First, connect to the EC2 client machine with the command:

```bash
ssh -i "Key pair name.pem" ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com
```

Then, download the package and extract its contents.

```bash
sudo wget https://packages.confluent.io/archive/7.2/confluent-7.2.0.tar.gz
tar -xvzf confluent-7.2.0.tar.gz
```

A new directory called `confluent-7.2.0` should be present on the EC2 instance.

To configure the REST proxy to communicate with the desired MSK cluster, and to perform IAM authentication, first locate to `confluent-7.2.0/etc/kafka-rest` and modify the kafka-rest.properties file:

```bash
cd confluent-7.2.0/etc/kafka-rest
nano kafka-rest.properties
```

In the `kafka-rest.properties` file, update the `bootstrap.servers` and the `zookeeper.connect` variables with the `Bootstrap server string` and `Plaintext Apache Zookeeper connection string` of the MSK cluster. These were found previously in [`batch-data-ec2-kafka-client.md.`](./batch-data-ec2-kafka-client.md)

The IAM authentication is also added to the file, similar to in [`batch-data-ec2-kafka-client-configuration.md`](./batch-data-ec2-kafka-client-configuration.md) where the `client.properties` file is created.

The `kafka-rest.properties` file should contain the information as follows:

```bash
zookeeper.connect=z-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181

bootstrap.servers=b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098

# Same as previous IAM authentication
client.security.protocol = SASL_SSL
client.sasl.mechanism = AWS_MSK_IAM
client.sasl.jaas.config = software.amazon.msk.auth.iam.IAMLoginModule required awsRoleArn="arn:aws:iam::584739742957:role/12c0d092d679-ec2-access-role";
client.sasl.client.callback.handler.class = software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

Before sending messages to the API, in order to make sure they are consumed in MSK, the REST proxy is started by running the following commands:

```bash
cd confluent-7.2.0/bin
./kafka-rest-start /home/ec2-user/confluent-7.2.0/etc/kafka-rest/kafka-rest.properties
```

The proxy is set up correctly when it is clear an INFO server has started and is listening for requests.

## Step 3: Send data to the API

To send data to the API, the plugin-connector (created in [`batch-data-msk-s3-connection.md`](./batch-data-msk-s3-connection.md)) is used to send the batch data to the MSK Cluster.

First, ensure the up-to-date API has been deployed and the REST proxy is started on the EC2 client machine.

Now, run the `user_posting_emulation.py` file:

```bash
cd scripts/processing/
python user_posting_emulation.py
```

Make sure to run this file for multiple iterations (5-10 minutes) as this ensures enough data is sent to the Kafka topics to be investigated later in Databricks.

To discuss the `user_posting_emulation.py` file, a `send_to_kafka(records, topic_name)` function is created to take the data (`records`) and send it to its corresponding Kafka topic (`topic_name`).

The invoke URL comes in the format `https://YourAPIInvokeURL/test/topics/<AllYourTopics>`.

For this example, the invoke URL is `https://t5v6ab37u9.execute-api.us-east-1.amazonaws.com/test/topics/ + topic_name`, where the topic names are: `12c0d092d679.pin`, `12c0d092d679.geo`, `12c0d092d679.user`.

The `records` do contain some `datetime` data which caused as error when serialising the Python dictionaries to JSON format. Consequently, the `serialize_datetime(obj)` function is created to serialise `datetime` objects to ISO format. This format is a common practise when working with JSON files as it represents the date and time in a standardised format e.g. `YYYY-MM-DDTHH:MM:SS.sssZ`.

Please see [user_posting_emulation.py](../scripts/processing/user_posting_emulation.py) for a closer look at the code.

To check if the topics have been created correctly, head to the S3 section of the AWS Management console. Locate to the bucket and notice how the connector has created the corresponding topics: `topics/<your_UserId>.pin/partition=0/`, `topics/<your_UserId>.geo/partition=0/`, and `topics/<your_UserId>.user/partition=0/`.

## Conclusion

We have successfully configured an API that receives data, which is then sent to the MSK Cluster using the plugin-connector pair previously created.

To see the full script of this section, please see [`batch-data-api-configuration.sh.`](../scripts/milestones/batch-data-api-configuration.sh)

In the next milestone, we set up a Databricks account to read information from AWS. We mount the S3 bucket to Databricks in order to clean and query your batch data. Please see the next milestone [here.](./batch-data-workflow-management.md)
