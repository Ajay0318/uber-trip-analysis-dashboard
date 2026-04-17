import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# 1) Load the raw dataset
df = pd.read_csv("dataset/UberDataset.csv")

# 2) Parse datetime columns
# `format='mixed'` handles multiple date formats found in the file.
for col in ["START_DATE", "END_DATE"]:
    df[col] = pd.to_datetime(df[col], errors="coerce", format="mixed")

# 3) Drop rows where core fields are missing
df = df.dropna(subset=["START_DATE", "END_DATE", "CATEGORY", "START", "STOP"]).copy()

# 4) Fill missing PURPOSE values for easier aggregation
df["PURPOSE"] = df["PURPOSE"].fillna("Unknown")

# 5) Create derived metrics
df["duration_min"] = (df["END_DATE"] - df["START_DATE"]).dt.total_seconds() / 60
df["month_num"] = df["START_DATE"].dt.month
df["month"] = df["START_DATE"].dt.month_name().str[:3]
df["weekday"] = df["START_DATE"].dt.day_name()
df["hour"] = df["START_DATE"].dt.hour
df["trip_type"] = np.where(df["CATEGORY"].eq("Business"), "Business", "Personal")
df["distance_band"] = pd.cut(
    df["MILES"],
    bins=[0, 3, 10, 25, 1000],
    labels=["Short (0-3)", "Medium (3-10)", "Long (10-25)", "Very Long (25+)"],
    include_lowest=True,
)

# Avoid divide-by-zero for speed
df["avg_speed_mph"] = np.where(
    df["duration_min"] > 0,
    df["MILES"] / (df["duration_min"] / 60),
    np.nan
)

# 6) Save cleaned dataset
df.to_csv("dataset/uber_trip_analysis_cleaned.csv", index=False)

# 7) KPI summary
print("Total trips:", len(df))
print("Total miles:", round(df["MILES"].sum(), 1))
print("Business share %:", round((df["CATEGORY"].eq("Business").mean() * 100), 1))

# 8) Example analysis tables
monthly = df.groupby(["month_num", "month"]).agg(
    trips=("MILES", "size"),
    miles=("MILES", "sum")
).reset_index().sort_values("month_num")

purpose = df.groupby("PURPOSE").agg(
    trips=("MILES", "size"),
    miles=("MILES", "sum")
).sort_values("trips", ascending=False)

routes = (
    df.groupby(["START", "STOP"])
      .size()
      .reset_index(name="trips")
      .sort_values("trips", ascending=False)
)

print(monthly.head())
print(purpose.head())
print(routes.head())

# 9) Simple chart example
plt.figure(figsize=(10, 5))
plt.bar(monthly["month"], monthly["trips"])
plt.title("Trips by Month")
plt.xlabel("Month")
plt.ylabel("Trips")
plt.tight_layout()
plt.savefig("screenshots/sample_monthly_chart.png")
