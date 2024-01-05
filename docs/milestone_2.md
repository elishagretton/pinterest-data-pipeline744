# Milestone 2: Connect a MSK cluster to a S3 bucket

Previously, we set up a EC2 instance and connected it to a MSK cluster. Three Kafka topics were created by the cluster to store the pin-related data.

In this section, we connect the MSK cluster to a S3 bucket. This ensures any data passing through the cluster will be automatically saved and stored in a dedicated S3 bucket.

There are many positives to storing data in this way, for example:

- **Data Backup and Recovery:** data stored in S3 can easily be recovered if lost, making it reliable.
- **Data Sharing:** S3 allows data to be shared easily with others.
- **Scalability:** data stored in S3 can be scaled horizontally to handle growing amounts of data.
- And many more!

To connect the cluster to the S3 bucket, we will complete the following steps:

- Create a custom plugin with MSK Connect using the `Confluent.io Amazon S3 Connector`
- Create a connector to ensure data passing through the IAM authenticated cluster is automatically stored in the designated S3 bucket.

To view the whole script, please head to [`scripts/milestones/milestone_2.sh.`](../scripts/milestones/milestone_2.sh)

## Step 1: Create a custom plugin with MSK Connect

A plugin is created to define the logic of a connector, which will export data from the Kafka topics to S3 objects. We do this by downloading the `Confluent.io Amazon S3 Connector` and copying it to a designated S3 bucket.

First, assume admin user privileges.

```bash
sudo -u ec2-user -i
```

Then create a directory, which will contain the connector.

```bash
mkdir kafka-connect-s3 && cd kafka-connect-s3
```

Download the connector from Confluent using the following code.

```bash
wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-s3/versions/10.0.3/confluentinc-kafka-connect-s3-10.0.3.zip
```

Copy the connector to the S3 bucket where the bucket name is `user-12c0d092d679-bucket`.

```bash
aws s3 cp ./confluentinc-kafka-connect-s3-10.0.3.zip s3://user-12c0d092d679-bucket/kafka-connect-s3/
```

The connector has been downloaded and now copied to the S3 bucket.

## Step 2: Create a connector with MSK Connect

In the AWS Management console, we will now create a connector. We do this to ensure data passing through the IAM authenticated cluster is automatically stored in the designated S3 bucket.

Follow these steps:

- Locate to the `MSK` console in `AWS`
- Locate to `MSK Connect` and select `Custom plugins`
- Choose `Create custom plugin` and upload the `Confluent connector ZIP file` with the name `12c0d092d679-plugin`.
- Locate to `Connectors` in the main `MSK` console.
- Choose `Create connector` and select the plugin you have created and click `Next`.

In the connector configuration settings, use the below configuration:

```bash
connector.class=io.confluent.connect.s3.S3SinkConnector
# same region as our bucket and cluster
s3.region=us-east-1
flush.size=1
schema.compatibility=NONE
tasks.max=3
# include nomeclature of topic name, given here as an example will read all data from topic names starting with msk.topic....
topics.regex=12c0d092d679.*
format.class=io.confluent.connect.s3.format.json.JsonFormat
partitioner.class=io.confluent.connect.storage.partitioner.DefaultPartitioner
value.converter.schemas.enable=false
value.converter=org.apache.kafka.connect.json.JsonConverter
storage.class=io.confluent.connect.s3.storage.S3Storage
key.converter=org.apache.kafka.connect.storage.StringConverter
s3.bucket.name=user-12c0d092d679-bucket
```

The other configurations are set to default besides:

- `Connector type`: Provisioned and MCU count per worker and Number of workers are set to 1
- `Worker Configuration`: confluent-worker
- `Access permissions`: 12c0d092d679-ec2-access-role (IAM role)

The connector is now created. Data passing through the MSK cluster is automatically saved to the S3 bucket, `user-12c0d092d679-bucket`.

## Conclusion

We have successfully created a plugin and a connector using the Confluent.io Amazon S3 Connector and AWS.

To see the full script of this section, please see [scripts/milestones/milestone_2.sh.](../scripts/milestones/milestone_2.sh)

In the next milestone, we build an API to send data to the MSK cluster and store the data in the S3 bucket using the connector. Please see the next milestone [here.](./milestone_3.md)
