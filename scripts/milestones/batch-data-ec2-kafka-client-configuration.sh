cd pinterest-data-pipeline744.git/

# Connect to EC2 instance
ssh -i "Key pair name.pem" ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com

# Install Java
sudo yum install java-1.8.0

# Install Apache Kafka 2.12_-2.8.1
wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.12-2.8.1.tgz
tar -xzf kafka_2.12-2.8.1.tgz

# Change to kafka_2.12-2.8.1/libs/ 
cd kafka_2.12-2.8.1/libs/

# Download IAM MSK authentication package
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.5/aws-msk-iam-auth-1.1.5-all.jar

# Set CLASSPATH so MSK IAM libraries are always accessible by Kafka client
export CLASSPATH=/home/ec2-user/kafka_2.12-2.8.1/libs/aws-msk-iam-auth-1.1.5-all.jar

# Use AWS Management console to add AWS IAM cluster authentication for EC2 client.

# Change to bin folder
cd kafka_2.12-2.8.1/bin/

# Edit client.properties file
nano client.properties

# Add these contents to client.properties
# Sets up TLS for encryption and SASL for authN.
security.protocol = SASL_SSL

# Identifies the SASL mechanism to use.
sasl.mechanism = AWS_MSK_IAM

# Binds SASL client implementation.
sasl.jaas.config = software.amazon.msk.auth.iam.IAMLoginModule required awsRoleArn="arn:aws:iam::584739742957:role/12c0d092d679-ec2-access-role";

# Encapsulates constructing a SigV4 signature based on extracted credentials.
# The SASL client bound by "sasl.jaas.config" invokes this class.
sasl.client.callback.handler.class = software.amazon.msk.auth.iam.IAMClientCallbackHandler

# Locate to the `kafka_2.12-2.8.1/bin/` folder.
cd kafka_2.12-2.8.1/bin/

# Create the topic 12c0d092d679.pin for the Pinterest posts data using the below code.
./kafka-topics.sh --bootstrap-server b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098 --command-config client.properties --create --topic 12c0d092d679.pin

# Create the topic 12c0d092d679.geo for the post geolocation data using the below code.
./kafka-topics.sh --bootstrap-server b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098 --command-config client.properties --create --topic 12c0d092d679.geo

# Create the topic 12c0d092d679.user for the post user data using the below code.
./kafka-topics.sh --bootstrap-server b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098 --command-config client.properties --create --topic 12c0d092d679.user