# Milestone 1: Batch data and configuring the EC2 Kafka Client

## Getting Started

To begin the tutorial, make sure to clone the repository and switch to the repository directory using the following code.

```bash
git clone https://github.com/elishagretton/pinterest-data-pipeline744.git
cd pinterest-data-pipeline744.git/
```

## About

I have downloaded the Pinterest infrastructure and signed into the AWS console using the credentials provided by AiCore.

In this section, we deal with **batch data**. This refers to a group of data points that are processed as a single unit. There are many advantages to processing batch data, such as:

- Being more computationally efficient than processing individual data points at a time.
- Cost-effective for large datasets as there is less need for continuous monitoring and immediate responsiveness.
- Consistency as the entire dataset is processed together with the same rules and algorithms.
- And many more!

Before extracting the pin-related data using batch processing, I first plan to create a EC2 instance to handle the data processing workload. I plan to achieve this by configuring a EC2 Kafka clinet to create the instance, and then connecting the instance to a MSK cluster. The cluster is used to create several Kafka topics to store the Pinterest posts data, geolocation data, and user data.

To view the whole script, please head to [`scripts/milestones/batch-data-ec2-kafka-client-configuration.sh.`](../scripts/milestones/batch-data-ec2-kafka-client-configuration.sh)

## Step 1: Connect to the EC2 instance

Before connecting to the EC2 instance, a `Key pair name.pem` file is created, which contains the authentication credentials given from AiCore to complete this project.

Using this information, open the terminal and locate to the folder for the repository and run:

```bash
ssh -i "Key pair name.pem" ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com
```

We connect to the EC2 instance on our local machine by using:

- `ssh`: the SSH client.
- `-i "Key pair name.pem"`: the private key for authentication of the EC2 instance.
- `ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com`: the username and the public IP address of the connected EC2 instance.

## Step 2: Set up Kafka on the EC2 instance

Now we are connected to the EC2 instance, we need to install Kafka on the client EC2 machine. This allows us to connect the instance to the MSK cluster.

First install Java on the EC2 instance.

```bash
sudo yum install java-1.8.0
```

Then download Apache Kafka 2.12-2.8.1 using the following code:

```bash
wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.12-2.8.1.tgz
tar -xzf kafka_2.12-2.8.1.tgz
```

Now there should be a directory called `kafka_2.12-2.8.1` in the EC2 client.

Locate into the `kafka_2.12-2.8.1/libs/` directory and install the IAM MSK authentication package. This ensures the MSK cluster can be connected to via IAM authentication.

```bash
cd kafka_2.12-2.8.1/libs/
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.5/aws-msk-iam-auth-1.1.5-all.jar
```

Now, we will create an environment variable called `CLASSPATH` to store the location of this jar file and make sure that the Amazon MSK IAM libraries are accessible to the Kafka client, regardless of the location where we will be running commands from.

To set up the `CLASSPATH` environment variable, you can use the following command:

```bash
export CLASSPATH=/home/ec2-user/kafka_2.12-2.8.1/libs/aws-msk-iam-auth-1.1.5-all.jar
```

Make sure that the specified path is the same as on your EC2 client machine.

Now we can configure the EC2 client to use AWS IAM for cluster authentication. We do this to provide control and security over who assesses the cluster. This is done in the AWS Management console with the following steps:

- Navigate to IAM console
- Select `Roles`
- Select role for my UserId: `12c0d092d679-ec2-access-role`
- Copy the `ARN` for the role
- Go to `Trust relationships` and select `Edit trust policy`.
- Click on `Add a principal` button and select `IAM roles` as the principal type.
- Replace `ARN` with the role name: `12c0d092d679-ec2-access-role`

Lastly, we configure the Kafka client to enable AWS IAM authentication to the cluster, using:

```bash
# Change to the bin folder
cd kafka_2.12-2.8.1/bin/
# Edit client.properties file
nano client.properties
```

In the `client.properties` file, copy and paste the following code:

```bash
# Sets up TLS for encryption and SASL for authN.
security.protocol = SASL_SSL

# Identifies the SASL mechanism to use.
sasl.mechanism = AWS_MSK_IAM

# Binds SASL client implementation.
sasl.jaas.config = software.amazon.msk.auth.iam.IAMLoginModule required awsRoleArn="arn:aws:iam::584739742957:role/12c0d092d679-ec2-access-role";

# Encapsulates constructing a SigV4 signature based on extracted credentials.
# The SASL client bound by "sasl.jaas.config" invokes this class.
sasl.client.callback.handler.class = software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

## Step 3: Create Kafka topics

Now the EC2 client is configured to use AWS IAM authentication to connect to the cluster, we then create Kafka topics to store the Pinterest posts data, geolocation data, and user data. We use Kafka topics as they organise and segregrate the data.

To do this, we use the AWS management console on the MSK cluster to note:

- `Bootstrap servers string`: `b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098`
- `Plaintext Apache Zookeeper connection string`: `z-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181`

Locate to the `kafka_2.12-2.8.1/bin/` folder.

```bash
cd kafka_2.12-2.8.1/bin/
```

Create the topic `12c0d092d679.pin` for the Pinterest posts data using the below code.

```bash
./kafka-topics.sh --bootstrap-server b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098 --command-config client.properties --create --topic 12c0d092d679.pin
```

Create the topic `12c0d092d679.geo` for the geolocation data using the below code.

```bash
./kafka-topics.sh --bootstrap-server b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098 --command-config client.properties --create --topic 12c0d092d679.geo
```

Create the topic `12c0d092d679.user` for the user data using the below code.

```bash
./kafka-topics.sh --bootstrap-server b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098 --command-config client.properties --create --topic 12c0d092d679.user
```

## Conclusion

Now we are all set with the configured EC2 Kafka client!

In this tutorial,

- we connected to the EC2 instance.
- We downloaded Kafka and the IAM MSK authentication package and configured the EC2 client to use AWS IAM for cluster authentication.
- We created topics for the Pinterest posts data, post geolocation data, and post user data, to organise and segragrate the data.

To see the whole script, please head to [`scripts/milestones/batch-data-ec2-kafka-client-configuration.sh.`](../scripts/milestones/batch-data-ec2-kafka-client-configuration.sh)

In the next milestone, we connect the MSK cluster to a S3 bucket. This ensures data in the cluster is automatically saved and stored in the dedicated S3 bucket. Please see the next milestone [here.](./batch-data-msk-s3-connection.md)
