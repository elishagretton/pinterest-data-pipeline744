# Milestone 5: AWS MWAA

Now the data has been cleaned and queried in Databricks, we can next create a schedule of tasks (also known as **_jobs_**) to process the data.

In this milestone we learn:

- What a DAG is
- What AWS MWAA is and how to use it
- and more to come

To give a quick overview:

1. There are a number of jobs that need to occur to process the data.
2. The order and execution of these jobs are represented in a DAG (Directed Acyclic Graph). It's like a flowchart that shows the order in which tasks should be executed. Tasks must be completed before moving onto the following task.
3. The jobs are managed by the Databricks' Jobs API (a set of tools for developers) or the user interface (UI) to create, monitor, and manage these jobs.
4. Then, AWS MWAA is used to oversee and schedule the jobs, providing a centralized way to monitor and manage the workflow.

In summary, this setup allows you to use the powerful job orchestration capabilities of Databricks to run tasks, and AWS MWAA helps coordinate and monitor the overall workflow, providing a unified way to manage the execution of tasks organized in a DAG.

# Step 1: Set up the DAG

The DAG can be seen in the file [scripts/12c0d092d679_dag.py](../scripts/12c0d092d679_dag.py).

For this DAG, the parameters are as follows:

- `notebook_path`: path to the Databricks file created in Milestone 4 (`/Users/elishagretton@gmail.com/databricks`)
- `start_date`: the date the DAG begins (here it begins on 30/12/23, `datetime(2023, 12, 30)`)
- `schedule_interval`: the DAG is ran daily (`'@daily'`)
- `existing_cluster_id`: cluster id of Databricks cluster (`1108-162752-8okw8dgg`)

The DAG file is then loaded to the `mwaa-dags-bucket/dags/` in the S3 bucket under the name `12c0d092d679_dag`.

# Step 2: Trigger the DAG

To trigger the DAG, locate to the MWAA section of the AWS console.

On the right, click the Open Airflow UI button.

Find the DAG `12c0d092d679_dag` and click the play button.

This moves the DAG to the Active section and unpauses it.

# Conclusion

Now the DAG has been created!
