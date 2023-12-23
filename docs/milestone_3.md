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
- Select `HTTP ANY` method and set the `Endpoint URL` as `http://ec2-3-81-111-233.compute-1.amazonaws.com/`
- Select `Create integration` and select `Deploy API`.

The proxy integration has now been created for the API.

## Step 2: Set up the Kafka REST policy on the EC2 client.
