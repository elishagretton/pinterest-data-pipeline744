# Pinterest Data Pipeline

## Table of Contents

1. [Introduction](#introduction)
2. [Installation Instructions](#installation-instructions)
3. [Usage Instructions](#usage-instructions)
4. [File Structure](#file-structure)
5. [License Information](#license-information)

## Introduction

Pinterest crunches billions of data points every day to decide how to provide more value to their users. In this project, a similar system is created using the AWS Cloud.

The key tools in this project include:

- **Apache Kafka**: to analyse and streamline the Pinterest data pipeline.
- **AWS EC2**: to create an EC2 client machine.
- **AWS IAM**: to use IAM User authentication on the MSK Cluster.
- **AWS MSK**: to manage the cluster, create custom plugins and connectors, and many more.
- More to come as I develop the project.

In this project, we learn:

1. How to connect to AWS
2. How to configure a EC2 Kafka client using an EC2 instance, an authorised IAM user, and MSK to manage the cluster.
3. How to create a custom plugin in MSK Connect and connect the plugin to the cluster.
4. The list will grow as I develop the project!

TODO: Create a flow-chart/diagram of the data pipeline/process. Insert and explain here.

## Installation Instructions

To get started with the project, first clone the repository onto your local machine.

```bash
git clone https://github.com/elishagretton/pinterest-data-pipeline744.git
cd pinterest-data-pipeline744.git/
```

## Usage Instructions

This is the final project for the Software Engineering bootcamp with AiCore.

I have been given a temporary AWS account with access to MSK Connect. This AWS feature is a paid service.

To use the project and leverage the MSK Connect features, I suggest reading more on AWS pricing options for MSK Connect [here.](https://aws.amazon.com/msk/pricing/)

## File Structure

The project is structured as follows:

- **/docs**: Contains documentation files on each milestone of the project.

  - `milestone_1.md`: Configures the EC2 Kafka client machine.
  - `milestone_2.md`: Connects a MSK cluster to a S3 bucket
  - `milestone_3.md`: Configures an API in API Gateway.

- **/scripts**: Contains complete script files for the corresponding documentation file.

  - `milestone_1.sh`: Script file for `milestone_1.md`
  - `milestone_2.sh`: Script file for `milestone_2.md`

- **.gitignore**: Specifies files and directories to ignore in version control.

- **README.md**: Documentation file with essential information.

- **user_posting_emulation.py**: Login credentials for a RDS database, containing three tables with data resembling data received by the Pinterest API when a POST request is made by a user uploading data to Pinterest.

- **LICENSE.txt**: File containing information on MIT License used in this project.

## License Information

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
