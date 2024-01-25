# Assume admin user privileges.
sudo -u ec2-user -i

# Then create a directory, which will contain the connector.
mkdir kafka-connect-s3 && cd kafka-connect-s3

# Download the connector from Confluent using the following code.
wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-s3/versions/10.0.3/confluentinc-kafka-connect-s3-10.0.3.zip

# Copy the connector to the S3 bucket where the bucket name is user-12c0d092d679-bucket.
aws s3 cp ./confluentinc-kafka-connect-s3-10.0.3.zip s3://user-12c0d092d679-bucket/kafka-connect-s3/

# Use the AWS Managent console to create a connector, see milestone_2.md.
