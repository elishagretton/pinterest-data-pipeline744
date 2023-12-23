# Milestone 3: Configuring an API on API Gateway

Previously, we established an MSK cluster and created a connector to store data in the S3 bucket. In this milestone, we will build an API to allow data transmission to the MSK cluster.

In this milestone, we learn:

- How to create a proxy API, create a GET integration, and deploy an API in API Gateway.
- More to come

## Step 1: Build a Kafka REST proxy integration method for the API

An API named `12c0d092d679` (my AWS username) has been provided by AiCore for the purpose of this project.

First, locate to the API Gateway in the AWS Management console. We will begin with creating a proxy integration for the API.

Proxy integrations provide the selected integration access to many resources and features at once, without specifying multiple resource paths using the greedy parameter, {proxy+}. This is simple solution to providing the integration with access to all available resources without having to specify all available paths as the API grows.

In the AWS Management console, follow these steps:

- Locate to the `API Gateway`
- Select `Create Resource`
- Select `proxy` resource and specify `Resource Name` as `{myProxy+}`. Click `Create Resource`.
- Locate to the `ANY` method and select and click `Edit Integration`.
- Select `HTTP ANY` method and set the `Endpoint URL` as `http://ec2-3-81-111-233.compute-1.amazonaws.com/{myProxy}`
- Select `Create integration` and select `Deploy API`.

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

In the `kafka-rest.properties` file, update the `bootstrap.servers` and the `zookeeper.connect` variables with the `Bootstrap server string` and `Plaintext Apache Zookeeper connection string` of the MSK cluster. These were found previously in [Milestone 1.](./milestone_1.md)

The IAM authentication is also added to the file, similar to in [Milestone 1](./milestone_1.md) where the `client.properties` file is created.

The `kafka-rest.properties` file should contain the information as follows:

```bash
zookeeper.connect=z-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181

bootstrap.servers=b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098

# Same as previous IAM authentication
security.protocol = SASL_SSL
sasl.mechanism = AWS_MSK_IAM
sasl.jaas.config = software.amazon.msk.auth.iam.IAMLoginModule required awsRoleArn="arn:aws:iam::584739742957:role/12c0d092d679-ec2-access-role";
sasl.client.callback.handler.class = software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

Before sending messages to the API, in order to make sure they are consumed in MSK, the REST proxy is started by running the following commands:

```bash
cd confluent-7.2.0/bin
./kafka-rest-start /home/ec2-user/confluent-7.2.0/etc/kafka-rest/kafka-rest.properties
```

The proxy is set up correctly when it is clear an INFO server has started and is listening for requests.

## Step 3: Send data to the API

To send data to the API, the plugin-connector (created in [Milestone 2](./milestone_2.md)) is used to send data to the MSK Cluster.

To be continued....
