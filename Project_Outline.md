### 1. Data Cleaning
- filter for recent years (or months?)
- determine irrelevant/repetitive columns and drop
- drop rows that have NaN/empty cell in a critical feature
- encode vars where needed
- feature engineering:
    - response_time = On Scene - Received
    - dispatch_time = Dispatch - Received
    - transport_time = Hospital - On Scene
    - day of week, time of day, etc.
- check for heteroskedasticity

### 2. Exploratory Data Analysis

### 3. Main Analysis
- linear regression to predict response time w/ features like call type, priority, time of day, day of week, neighborhood
  - try quantile regression - see slowest response times
  - try interaction terms
- which incident types are most common in which neighborhoods?
  - k-means clustering
- SHINY!
  - which areas of SF (i.e.) by neighborhood have worst/best response times (or another var)
  - visualize avg response times/most common incident by neighborhood
      - interactive - drop down where you can select by neighborhood, groups of lat longs..
      - slider - can slide through diff times of day to see how avg response time + most common incident changes 

### 4. Explain Results

