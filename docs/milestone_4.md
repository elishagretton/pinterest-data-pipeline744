# Milestone 4: Databricks

In the previous milestone, we built an API to allow data to be transmitted to the MSK cluster. This transferred the various types of Pinterest data (`pin_data`, `geo_data`, `user_data`) to the corresponding Kafka topics.

Now, we will use Databricks to take a closer look at the data in these topics. In this milestone, we learn:

- How to set up a Databricks account
- How to mount an S3 bucket on Databricks to be authorised to retrieve the data
- How to read the data in the Kafka topics (`df_pin`, `df_geo`, `df_user`)
- How to clean and transform each dataframe in Spark
- How to query the dataframes to gain insights on the Pinterest-related data.

To see the full Spark script for this section, please see [scripts/milestone_4.ipynb](../scripts/milestone_4.ipynb).

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

The most popular category in Algeria is beauty, having a category_count of 3. This was also the highest category_count in the dataframe.

The category_count of 3 is quite low, which is probably due to only having 131 entries in the dataframes. To get a more insightful result, I would run the `user_posting_emulation.py` (where the data is being sent to the Kafka topics) for a lot longer.

All of the results can be seen in the full script.

**B: Find out the most popular category for each year between 2018-2022**

The results are as follows:

- In 2018, the most popular category was art (category_count 5).
- In 2019, the most popular category was diy and crafts (category_count 6).
- In 2020, the most popular category was christmas (category_count 4).
- In 2021, the most popular category was tattoos (category_count 4).
- In 2022, the most popular categories were beauty, quotes, and art (category_count 3).

**C: Find user with the most followers in each country**

The full list can be seen in the script. For the top 3 users with the most followers in their countries, the results are as follows:

- In Azerbaijan, the user with the most followers is called Style Me Pretty, with 6000000 followers.
- In American Samoa, the user with the most followers is called BuzzFeed, with 5000000 followers.
- In Bangladesh, the user with the most followers is called Architectural Digest, with 3000000 followers.

It would be interesting to see which parts of the world have users with higher followings. This could determine which audiences to

**D: Find the most popular category for each age group**

Given the age groups, `18-24`, `25-35`, `36-50` and `50+`. The most popular categories for each age group are as follows:

- `18-24`: christmas and tattoos
- `25-35`: mens-fashion
- `36-50`: diy and crafts
- `50+`: beauty

**E: Find the median follower count for different age groups**

With the same age groups, the median follower count for each group is as follows:

- `18-24`: 92000
- `25-35`: 42000
- `36-50`: 6000
- `50+`: 5000

Younger age groups have a higher median follower count. This could be for many reasons:

- Perhaps there are more users in younger age groups that are using the platform and interacting with the content.
- Perhaps younger age groups have been using Pinterest for longer and therefore have higher median follower counts as they have had more time to build their following.

**F: Find how many users joined each year from 2015-2020**

The results are as follows:

- In year 2015, 51 users joined.
- In year 2016, 60 users joined.
- In year 2017, 20 users joined.
- In years 2018-2020, no users joined.

In recent years, there have been less users signing up to Pinterest (no users in 2018-2020!). This is not good and could be something to be investigated e.g. why have less users signed up? is this due to a new feature?...

There seems to be a small increase in year 2016, however to gain more insights, I would suggest a larger dataframe.

**G: Find the median follower count of users based on joining year**

The results are as follows:

- The users that joined in 2015 had a median follower count of 92000.
- The users that joined in 2016 had a median follower count of 27000.
- The users that joined in 2017 had a median follower count of 6000.

TODO: I'm not sure if these are really right/make sense. Is this follower count currently?

**H: Find the median follower count of users that have joined between 2015 and 2020, based on which age group they are part of**

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
