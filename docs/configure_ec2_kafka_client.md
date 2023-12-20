# Batch Processing: Configure the EC2 Kafka Client

## Introduction

I have downloaded the Pinterest infrastructure and signed into the AWS console using the credentials provided by AiCore.

In this section, I plan to configure a EC2 Kafka client by creating a EC2 instance and connecting it to the Kafka cluster. An EC2 instance is used as they are scalable, cost-effective, and easy to configure.

Following this, several Kafka topics are created to store the Pinterest posts data, post geolocation data, and post user data.

## Step 1: Connect to the EC2 instance

Before connecting to the EC2 instance, a `Key pair name.pem` file is created, which contains the contents of my `KeyPairId` given from AiCore.

Using this information, open the terminal and locate to the folder for the repository and run:

```bash
ssh -i "Key pair name.pem" ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com
```

We connect to the EC2 instance using:

- `ssh`: the SSH client.
- `-i "Key pair name.pem"`: the private key for authentication of the EC2 instance.
- `ec2-user@ec2-3-81-111-233.compute-1.amazonaws.com`: the username and the public IP address of the connected EC2 instance.
