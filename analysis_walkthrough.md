# Line-by-Line Analysis Explanation

This file explains exactly how the project analysis was done.

## Step 1: Load the CSV
```python
df = pd.read_csv("dataset/UberDataset.csv")
```
This reads the raw Uber dataset into a pandas DataFrame.

## Step 2: Convert date columns into proper datetime format
```python
for col in ["START_DATE", "END_DATE"]:
    df[col] = pd.to_datetime(df[col], errors="coerce", format="mixed")
```
Why this matters:
- The dataset contains mixed date formats like `01-01-2016 21:11` and `1/13/2016 13:54`.
- `format="mixed"` allows pandas to parse both.
- `errors="coerce"` converts invalid rows to null instead of crashing.

## Step 3: Remove incomplete rows for core trip analysis
```python
df = df.dropna(subset=["START_DATE", "END_DATE", "CATEGORY", "START", "STOP"]).copy()
```
Why:
- We need valid trip time, category, and route fields for analysis.
- `.copy()` avoids chained-assignment issues later.

## Step 4: Fill missing purpose values
```python
df["PURPOSE"] = df["PURPOSE"].fillna("Unknown")
```
Why:
- Almost half the rows have blank purpose.
- Filling them lets us group and count them clearly.
- This also becomes a useful data-quality insight.

## Step 5: Engineer new features
### Duration in minutes
```python
df["duration_min"] = (df["END_DATE"] - df["START_DATE"]).dt.total_seconds() / 60
```
We subtract end time from start time to get trip duration.

### Month number and month label
```python
df["month_num"] = df["START_DATE"].dt.month
df["month"] = df["START_DATE"].dt.month_name().str[:3]
```
Why:
- `month_num` helps sort Jan → Dec correctly.
- `month` gives chart-friendly labels.

### Weekday and hour
```python
df["weekday"] = df["START_DATE"].dt.day_name()
df["hour"] = df["START_DATE"].dt.hour
```
Why:
- This helps identify peak weekdays and peak hours.

### Business vs personal helper field
```python
df["trip_type"] = np.where(df["CATEGORY"].eq("Business"), "Business", "Personal")
```
Why:
- It standardizes the category into a simpler reporting dimension.

### Distance bands
```python
df["distance_band"] = pd.cut(
    df["MILES"],
    bins=[0, 3, 10, 25, 1000],
    labels=["Short (0-3)", "Medium (3-10)", "Long (10-25)", "Very Long (25+)"],
    include_lowest=True,
)
```
Why:
- Segmenting trips into short/medium/long makes the story stronger than only using raw miles.

### Average speed
```python
df["avg_speed_mph"] = np.where(
    df["duration_min"] > 0,
    df["MILES"] / (df["duration_min"] / 60),
    np.nan
)
```
Why:
- We calculate speed only when duration is greater than 0.
- This avoids divide-by-zero errors.

## Step 6: Save the cleaned dataset
```python
df.to_csv("dataset/uber_trip_analysis_cleaned.csv", index=False)
```
This creates a reusable cleaned file for SQL, BI tools, or future projects.

## Step 7: Build KPI metrics
Examples:
```python
len(df)
df["MILES"].sum()
(df["CATEGORY"].eq("Business").mean() * 100)
```
What these do:
- Count total trips
- Sum total miles
- Compute the business-trip share

## Step 8: Group and aggregate for analysis
### Monthly analysis
```python
monthly = df.groupby(["month_num", "month"]).agg(
    trips=("MILES", "size"),
    miles=("MILES", "sum")
).reset_index().sort_values("month_num")
```
Why:
- `groupby` creates monthly buckets
- `size` counts rows
- `sum` adds total miles

### Purpose analysis
```python
purpose = df.groupby("PURPOSE").agg(
    trips=("MILES", "size"),
    miles=("MILES", "sum")
).sort_values("trips", ascending=False)
```
Why:
- This shows which purposes appear most frequently and which consume the most travel distance.

### Route analysis
```python
routes = (
    df.groupby(["START", "STOP"])
      .size()
      .reset_index(name="trips")
      .sort_values("trips", ascending=False)
)
```
Why:
- It identifies repeated start-stop combinations.
- This reveals route concentration and travel hubs.

## Step 9: Visualize results
Example:
```python
plt.bar(monthly["month"], monthly["trips"])
```
Why:
- Visualization turns grouped summaries into recruiter-friendly insights.

## Final story you can say in interview
1. I took a real Uber trip dataset.
2. I cleaned inconsistent datetime formats and missing values.
3. I engineered trip duration, month, weekday, hour, speed, and distance bands.
4. I analyzed trip concentration by time, purpose, and route.
5. I turned it into a GitHub-ready analytics case study with visuals and insights.
