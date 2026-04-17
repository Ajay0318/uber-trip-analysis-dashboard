# Key Insights

## 1) Uber usage is overwhelmingly business-focused
- 93.3% of all trips belong to the **Business** category.
- Only 6.7% of trips are marked as **Personal**.
- This makes the dataset a strong fit for a **business travel / trip behavior** case study rather than a consumer ride-booking revenue model.

## 2) The trip log is dense and operationally meaningful
- Total trips analyzed: **1,155**
- Total miles covered: **12,204.7**
- Total recorded travel time: **447.4 hours**
- Average trip length: **10.6 miles**
- Average trip duration: **23.2 minutes**

## 3) Travel intensity rises sharply late in the year
Top months by trip count:
- **Dec**: 146 trips
- **Aug**: 133 trips
- **Nov**: 122 trips

This suggests heavier trip activity during the last quarter, especially in **November and December**.

## 4) Friday is the busiest weekday
Top weekdays by trip count:
- **Friday**: 206 trips
- **Tuesday**: 176 trips
- **Monday**: 174 trips

This hints at heavier business movement toward the end of the workweek.

## 5) Afternoon hours dominate
Top hours by trip count:
- **15:00**: 98 trips
- **17:00**: 95 trips
- **18:00**: 94 trips
- **13:00**: 94 trips
- **14:00**: 89 trips

The afternoon and early evening windows show the strongest trip concentration.

## 6) Meetings and customer visits drive the most structured work travel
Top purposes by mileage:
- **Meeting**: 2,851.3 miles
- **Customer Visit**: 2,089.5 miles
- **Meal/Entertain**: 911.7 miles
- **Temporary Site**: 523.7 miles
- **Errand/Supplies**: 508.0 miles

A large **43.5%** of records have missing purpose values (filled as `Unknown` in the cleaned dataset), which is a useful data-quality talking point in interviews.

## 7) Cary and Morrisville appear as the strongest travel cluster
Top identified routes:
- **Morrisville → Cary**: 75 trips
- **Cary → Morrisville**: 67 trips
- **Cary → Cary**: 53 trips
- **Cary → Durham**: 36 trips
- **Durham → Cary**: 32 trips

This indicates recurring movement across a small operational hub rather than random one-off trips.

## 8) Data quality caveat should be mentioned confidently
- **18.3%** of records include `Unknown Location` as either start or stop.
- A few rows had zero travel duration, so speed analysis was handled carefully.
- The case study is still strong because the location, time, category, and mileage fields are rich enough for pattern analysis.

## Suggested interview positioning
> I used a real Uber trip-log dataset and turned it into a business travel analytics case study.  
> I cleaned mixed datetime formats, derived duration and speed metrics, analyzed trip behavior by month, weekday, hour, purpose, and route, and then packaged the insights into a GitHub-ready analytics project.
