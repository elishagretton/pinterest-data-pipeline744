# Milestone 4: Databricks

In the previous milestone, we built an API to allow data to be transmitted to the MSK cluster. This transferred the various types of Pinterest data (`pin_data`, `geo_data`, `user_data`) to the corresponding Kafka topics.

Now, we use Databricks to take a closer look at the data in these topics. In this milestone, we learn:

- How to set up a Databricks account
- How to mount an S3 bucket on Databricks to be authorised to retrieve the data
- How to read the data in the Kafka topics (`df_pin`, `df_geo`, `df_user`)
- How to clean and transform each dataframe in Spark
- How to query the dataframes to gain insights on the Pinterest-related data.

To see the full Spark script for this section, please see [batch-data-processing-databricks.ipynb](../scripts/milestones/batch-data-processing-databricks.ipynb).

The full Spark script is split into **four** tasks:

- **Task 1:** Setting up Databricks and mounting the S3 bucket to Databricks.
- **Task 2:** Reading the dataframes (`df_pin`, `df_geo`, `df_user`) containing the pin-related data, geo-location data, and user data.
- **Task 3:** Cleaning each dataframe.
- **Task 4:** Querying the dataframes to generate insights.

The first three tasks are self-explanatory from the script. In this documentation, I will not go into detail for the first three tasks, but I will discuss the fourth task in more detail.

## Side Note

As a side note, I wanted to add that I have been given a Databricks account from the Software Engineering bootcamp at AiCore.

Databricks is a platform for big data analytics and machine learning. It supports Apache Spark, which is used in this project to process the Pinterest-related data. It is also used to perform data cleaning and to query the data.

The account has access to the authentication credentials to be able to mount the S3 bucket in Databricks.

To learn more about Databricks, visit the site [here.](https://www.databricks.com/)

## Task 4: Querying the data

**A: Find the most popular category in each country**

The query:

```python
# Combine df_geo and df_pin with 'ind' column
df_combined = df_geo.alias("geo").join(df_pin.alias("pin"), col("geo.ind") == col("pin.ind"), 'inner')

# Groups data by country and category and counts occurences.
df_aggregated = df_combined.groupBy("geo.country", "pin.category").agg(count("geo.ind").alias("category_count"))

# Find the most popular category for each country
df_result = df_aggregated.groupBy("geo.country").agg(
    first("pin.category").alias("category"),
    max("category_count").alias("category_count") # max category count
)
# Order the result DataFrame by category_count in descending order
df_result_ordered = df_result.orderBy(desc("category_count"))

# Show the DataFrame with the most popular category for each country
df_result_ordered.show()
```

**Results:** The most popular category in Algeria is beauty, having a category_count of 3. This was also the highest category_count in the dataframe.

The category_count of 3 is quite low, which is probably due to only having 131 entries in the dataframes. To get a more insightful result, I would run the `user_posting_emulation.py` (where the data is being sent to the Kafka topics) for a lot longer.

All of the results can be seen in the full script.

**B: Find out the most popular category for each year between 2018-2022**

The query:

```python
# Extract the year from the timestamp column (2018-2022)
df_geo_with_year = df_geo.withColumn("post_year", year("timestamp")).filter((col("post_year") >= 2018) & (col("post_year") <= 2022))

# Perform the necessary transformations and aggregations
df_combined = df_geo_with_year.alias("geo").join(df_pin.alias("pin"), col("geo.ind") == col("pin.ind"), 'inner')
df_aggregated = df_combined.groupBy("post_year", "pin.category").agg(count("geo.ind").alias("category_count"))

# Show the DataFrame with the desired output
df_result = df_aggregated.select("post_year", "pin.category", "category_count")

# Order the result DataFrame by category_count in descending order
df_result_ordered = df_result.orderBy(desc("category_count"))

# Show the DataFrame with ALL category_count for each country
df_result_ordered.show()

# Create a window specification over post_year, ordering by category_count in descending order
window_spec = Window.partitionBy("post_year").orderBy(desc("category_count"))

# Assign a rank to each category within each year based on its count
df_ranked = df_aggregated.withColumn("rank", dense_rank().over(window_spec))

# Filter for rows with rank 1 (highest category_count) for each post_year
df_result = df_ranked.filter(col("rank") == 1).select("post_year", "pin.category", "category_count")

# Show the DataFrame with the highest category_count for each post_year (2018-2022)
df_result.show()
```

**Results:**

- In 2018, the most popular category was art (category_count 5).
- In 2019, the most popular category was diy and crafts (category_count 6).
- In 2020, the most popular category was christmas (category_count 4).
- In 2021, the most popular category was tattoos (category_count 4).
- In 2022, the most popular categories were beauty, quotes, and art (category_count 3).

**C: Find user with the most followers in each country**

The query:

```python
# Step 1: For each country, find the user with the most followers
df_combined_step1 = df_geo.alias("geo").join(df_pin.alias("pin"), col("geo.ind") == col("pin.ind"), 'inner')
df_aggregated_step1 = df_combined_step1.groupBy("geo.country", "pin.poster_name").agg(max("pin.follower_count").alias("follower_count"))

# Show the DataFrame with the desired output for Step 1
df_result_step1 = df_aggregated_step1.select("country", "poster_name", "follower_count")
df_result_step1_ordered = df_result_step1.orderBy(desc("follower_count"))
df_result_step1_ordered.show()

# Step 2: Find the country with the user having the most followers
df_aggregated_step2 = df_aggregated_step1.groupBy("country").agg(max("follower_count").alias("max_follower_count"))

# Step 3: Filter for the entry with the maximum follower count
max_entry = df_aggregated_step2.orderBy(col("max_follower_count").desc()).limit(1)

# Show the DataFrame with the desired output
max_entry.show()
```

**Results:**
The full list can be seen in the script. For the top 3 users with the most followers in their countries, the results are as follows:

- In Azerbaijan, the user with the most followers is called Style Me Pretty, with 6000000 followers.
- In American Samoa, the user with the most followers is called BuzzFeed, with 5000000 followers.
- In Bangladesh, the user with the most followers is called Architectural Digest, with 3000000 followers.

It would be interesting to visualise where the most popular accounts come from as perhaps Pinterest is more popular in some regions in the world.

**D: Find the most popular category for each age group**

The query:

```python
# Define age groups
df_user_age = df_user.withColumn(
    "age_group",
    when(col("age").between(18, 24), "18-24")
    .when(col("age").between(25, 35), "25-35")
    .when(col("age").between(36, 50), "36-50")
    .otherwise("+50")
)
# Join on 'ind' column
df_combined = df_user_age.alias("user").join(df_pin.alias("pin"), col("user.ind") == col("pin.ind"), 'inner')

# Group by age group and category, and count the occurrences
df_aggregated = df_combined.groupBy("age_group", "pin.category").agg(count("user.ind").alias("category_count"))

# Create a window specification over age_group, ordering by category_count in descending order
window_spec = Window.partitionBy("age_group").orderBy(desc("category_count"))

# Assign a rank to each category within each age group based on its count
df_ranked = df_aggregated.withColumn("rank", dense_rank().over(window_spec))

# Filter for rows with rank 1 (highest category_count) for each age_group
df_result = df_ranked.filter(col("rank") == 1).select("age_group", "pin.category", "category_count")

age_group_order = ["18-24", "25-35", "36-50", "+50"]
df_result_ordered = df_result.orderBy(expr("array_position(array('" + "','".join(age_group_order) + "'), age_group)"), desc("category_count"))

# Show the DataFrame with the highest category_count for each age_group
df_result_ordered.show()
```

**Results:** Given the age groups, `18-24`, `25-35`, `36-50` and `50+`. The most popular categories for each age group are as follows:

- `18-24`: christmas and tattoos
- `25-35`: mens-fashion
- `36-50`: diy and crafts
- `50+`: beauty

It's interesting how Christmas is one of the most popular categories for 18-24 year olds!

**E: Find the median follower count for different age groups**

The query:

```python
# Define age groups
df_user_age = df_user.withColumn(
    "age_group",
    when(col("age").between(18, 24), "18-24")
    .when(col("age").between(25, 35), "25-35")
    .when(col("age").between(36, 50), "36-50")
    .otherwise("+50")
)
# Join on 'ind' column
df_combined = df_user_age.alias("user").join(df_pin.alias("pin"), col("user.ind") == col("pin.ind"), 'inner')

# Group by age group and calculate the median follower count
df_aggregated = df_combined.groupBy("age_group").agg(F.expr("percentile_approx(pin.follower_count, 0.5)").alias("median_follower_count"))

# Show the DataFrame with the desired output
df_result = df_aggregated.select("age_group", "median_follower_count")
age_group_order = ["18-24", "25-35", "36-50", "+50"]
df_result_ordered = df_result.orderBy(expr("array_position(array('" + "','".join(age_group_order) + "'), age_group)"), desc("median_follower_count"))

# Show the DataFrame with the median follower_count for each age_group
df_result_ordered.show()
```

**Results:** With the same age groups, the median follower count for each group is as follows:

- `18-24`: 92000
- `25-35`: 42000
- `36-50`: 6000
- `50+`: 5000

Younger age groups have a higher median follower count. This could be for many reasons:

- Perhaps there are more users in younger age groups that are using the platform and interacting with content from people of a similar age.
- Perhaps younger age groups have been using Pinterest for longer and therefore have higher median follower counts as they have had more time to build their following.
- There may be many reasons for this trend. To be able to form an accurate analysis, further analysis needs to be done to identify trends in the data.

**F: Find how many users joined each year from 2015-2020**

The query:

```python
# Extract the year from the timestamp column in df_user
df_user_with_year = df_user.withColumn("date_joined", year("date_joined"))

# Filter for users who joined between 2015 and 2020
df_filtered_users = df_user_with_year.filter((col("date_joined") >= 2015) & (col("date_joined") <= 2020))

# Count the number of users joined for each date_joined
df_result = df_filtered_users.groupBy("date_joined").agg(count("ind").alias("number_users_joined"))

# Show the DataFrame with the desired output
df_result.show()
```

**Results:**

- In year 2015, 51 users joined.
- In year 2016, 60 users joined.
- In year 2017, 20 users joined.
- In years 2018-2020, no users joined.

In recent years, there have been less users signing up to Pinterest (no users in 2018-2020!). This is not good and could be something to be investigated e.g. why have less users signed up? is this due to a new feature?...

There seems to be a small increase in year 2016, however to gain more insights, I would suggest a larger dataframe.

**G: Find the median follower count of users based on joining year**

The query:

```python
# Extract the year from the date_joined column in df_user
df_user_with_year = df_user.withColumn("join_year", year("date_joined"))

# Filter for users who joined between 2015 and 2020
df_filtered_users = df_user_with_year.filter((col("join_year") >= 2015) & (col("join_year") <= 2020))

# Join on 'ind' column
df_combined = df_filtered_users.alias("user").join(df_pin.alias("pin"), col("user.ind") == col("pin.ind"), 'inner')

# Group by join_year and calculate the median follower count
df_result = df_combined.groupBy("join_year").agg(expr("percentile_approx(pin.follower_count, 0.5)").alias("median_follower_count"))

# Show the DataFrame with the desired output
df_result.show()
```

**Results:**

- The users that joined in 2015 had a median follower count of 92000.
- The users that joined in 2016 had a median follower count of 27000.
- The users that joined in 2017 had a median follower count of 6000.

**H: Find the median follower count of users that have joined between 2015 and 2020, based on which age group they are part of**

The query:

```python
# Define age groups
df_user_age = df_user.withColumn(
    "age_group",
    when(col("age").between(18, 24), "18-24")
    .when(col("age").between(25, 35), "25-35")
    .when(col("age").between(36, 50), "36-50")
    .otherwise("+50")
)

# Extract the year from the date_joined column in df_user
df_user_with_year = df_user_age.withColumn("join_year", year("date_joined"))

# Filter for users who joined between 2015 and 2020
df_filtered_users = df_user_with_year.filter((col("join_year") >= 2015) & (col("join_year") <= 2020))

# Join on 'ind' column
df_combined = df_filtered_users.alias("user").join(df_pin.alias("pin"), col("user.ind") == col("pin.ind"), 'inner')

# Group by age_group and join_year, calculate the median follower count
df_result = df_combined.groupBy("user.age_group", "user.join_year").agg(
    percentile_approx("pin.follower_count", 0.5).alias("median_follower_count")
)

# Show the DataFrame with the desired output
df_result = df_result.select('age_group', 'join_year', 'median_follower_count')

# Order the result DataFrame by age_group and join_year
df_result_ordered = df_result.orderBy("user.age_group", "user.join_year")

df_result_ordered.show()
```

**Results:**
For the age group `18-24`,

- the users that joined in 2015 have a median follower count of 190000.
- the users that joined in 2016 have a median follower count of 40000.
- the users that joined in 2017 have a median follower count of 10000.

For the age group `25-35`,

- the users that joined in 2015 have a median follower count of 42000.
- the users that joined in 2016 have a median follower count of 27000.
- the users that joined in 2017 have a median follower count of 8000.

For the age group `36-50`,

- the users that joined in 2015 have a median follower count of 13000.
- the users that joined in 2016 have a median follower count of 9000.
- the users that joined in 2017 have a median follower count of 314.

For the age group `50+`,

- no users that were 50+ joined in 2015.
- the users that joined in 2016 have a median follower count of 1000.
- the users that joined in 2017 have a median follower count of 9000.

From the data, we can notice some patterns:

Users that have an earlier join year have a higher median follower count. This may be because users have been able to grow their following for a longer time.

This is true for all age groups besides people aged 50+. No users who were 50+ joined in 2015 and we see a low median follower count in 2016 of 1000 for people 50+. However in 2017, the median follower count increased to 9000. Perhaps we could guess users aged 50+ are starting to increase in popularity, whereas other age groups' are struggling to gain more followers.

We can also notice the age group for 18-24 year olds have an overall higher median follower count. Some ideas behind this popularly could be:

- Perhaps the age group are better at marketing themselves on the platform.
- The content by 18-24 years olds is favoured by the platform algorithm.
- It could be due to the majority of Pinterest users being in this age bracket (this is not facts, but could be something that is true and to be investigated.)
- The content 18-25 year olds are posting is popular with many different types of users, not just people in the same age range (to be investigated).

We could investigate this further by performing further queries to answer some of these questions.

# Conclusion

In this milestone, we mounted the S3 bucket to Databricks to read the three pin-related dataframes. Each dataframe was cleaned and then queried to generate insights.

If I had more time to complete this project, I would create a larger dataset by giving the `user_posting_emulation.py` more time to send data to Kafka topics. The dataframes were very small (131 entries), which have not given the most insightful results.
