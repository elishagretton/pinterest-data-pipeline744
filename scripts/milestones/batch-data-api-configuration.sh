# Follow Step 1 in docs/milestone_3.md to create a Kafka REST policy in AWS Management console

# Step 2: To set up the REST policy on the EC2 Client

# Connect to the EC2 client machine with the command
ssh -i "Key pair name.pem" ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com

# Download the package and extract its contents
sudo wget https://packages.confluent.io/archive/7.2/confluent-7.2.0.tar.gz
tar -xvzf confluent-7.2.0.tar.gz

# Edit kafka-rest.properties file to configure the REST proxy to communicate with the desired MSK cluster, and to perform IAM authentication
cd confluent-7.2.0/etc/kafka-rest
nano kafka-rest.properties

# In the kafka-rest.properties file:
zookeeper.connect=z-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181,z-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:2181

bootstrap.servers=b-1.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-3.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098,b-2.pinterestmskcluster.w8g8jt.c12.kafka.us-east-1.amazonaws.com:9098

client.security.protocol = SASL_SSL
client.sasl.mechanism = AWS_MSK_IAM
client.sasl.jaas.config = software.amazon.msk.auth.iam.IAMLoginModule required awsRoleArn="arn:aws:iam::584739742957:role/12c0d092d679-ec2-access-role";
client.sasl.client.callback.handler.class = software.amazon.msk.auth.iam.IAMClientCallbackHandler

# Start REST proxy
cd confluent-7.2.0/bin
./kafka-rest-start /home/ec2-user/confluent-7.2.0/etc/kafka-rest/kafka-rest.properties

# Send data to MSK cluster using plugin-connector
python user_posting_emulation.py
