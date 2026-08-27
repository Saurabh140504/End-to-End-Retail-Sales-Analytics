# End-to-End Retail Sales Analytics

> A retail sales analysis built across **Python** (cleaning, feature engineering, EDA), **MySQL** (business KPI queries), and **Power BI** (interactive dashboards) — with every KPI on the dashboard re-derived independently in Python and SQL before being called final.

---

## Business Problem

A retail company selling across three product categories — Electronics, Clothing, and Beauty — was facing a familiar set of problems:

- Sales performance fluctuated month to month with no clear explanation why
- Some product categories were clearly underperforming, but nobody had quantified by how much
- Management couldn't say which customers actually generated the most revenue
- There was no visibility into which age group or gender drove more sales
- No centralized dashboard existed — reporting was manual and business decisions were delayed as a result

The goal of this project was to turn 1,000 raw sales transactions into a validated set of KPIs and an interactive dashboard the business could actually use to make decisions.

### Objectives

- Clean and prepare the raw transaction data, and engineer the features needed for time-based and demographic analysis
- Answer a fixed set of business KPI questions in SQL and confirm those same numbers independently in Python
- Segment customers by spend (Premium/Regular) and transactions by size (Low/Medium/High)
- Build a Power BI dashboard that replaces manual reporting with something the business can filter and explore on its own

### Who This Would Matter To (Stakeholders)

- **Sales Manager** — wants to know which categories and months are driving or dragging revenue
- **Marketing Manager** — wants to know which age group and gender to target
- **Customer Relationship Manager** — wants a working definition of a "premium" customer
- **Senior Management** — wants one dashboard instead of manually assembled reports

---

## Table of Contents

- [Dataset Overview](#dataset-overview)
- [Part 1 — Python: Cleaning, Feature Engineering & EDA](#part-1--python-cleaning-feature-engineering--eda)
- [Part 2 — SQL: Business KPI Analysis](#part-2--sql-business-kpi-analysis)
- [Part 3 — Power BI: Dashboard](#part-3--power-bi-dashboard)
- [Cross-Tool Validation](#cross-tool-validation)
- [Key Insights & Recommendations](#key-insights--recommendations)
- [Repository Structure](#repository-structure)
- [Tools Used](#tools-used)

---

## Dataset Overview

**File:** `retail_sales_dataset.csv` — one row per transaction.

| Field | Value |
|---|---:|
| Total transactions | 1,000 |
| Unique customers | 1,000 |
| Date range | Jan 1, 2023 – Jan 1, 2024 |
| Categories | Electronics, Clothing, Beauty |
| Missing values | 0 |
| Duplicate rows | 0 |

Raw columns: `Transaction ID`, `Date`, `Customer ID`, `Gender`, `Age`, `Product Category`, `Quantity`, `Price per Unit`, `Total Amount`.

**Important scoping note, found during this review:** every one of the 1,000 `Customer ID` values appears in **exactly one** transaction row — there are zero customers with more than one purchase in this dataset. That means "Top Customers by Revenue" here is really "customers with the single largest transaction," not repeat buyers, and the `Repeat Customers` query in the SQL file will correctly return an empty result set.

---

## Part 1 — Python: Cleaning, Feature Engineering & EDA

**Notebook:** [`Retail Sales/Retail_sales_analysis.ipynb`](./Retail%20Sales/Retail_sales_analysis.ipynb)

**Flow:** Load → understand → clean → engineer features → explore → visualize → export → load into MySQL

### Data Cleaning

| Check | Result |
|---|---:|
| Missing values | 0 across all columns |
| Duplicate rows | 0 |
| `Date` column | Converted from text to datetime |
| Negative sales amounts | 0 found |
| Invalid ages (<8 or >100) | 0 found |

### Feature Engineering

- **`Year`, `Month`, `Quarter`, `Day_Name`** — extracted from the `Date` column
- **`Age_Group`** — Teen (≤19), Young Adult (20–35), Adult (36–55), Senior (56+)
- **`Profit_Estimate`** — a flat 30% of `Total Amount`, used as a proxy since no actual cost data exists
- **`Revenue_Segment`** — Low (<$100), Medium ($100–499), High ($500+), applied per transaction
- **`Customer_Type`** — Premium if a customer's total spend exceeds $1,500, otherwise Regular

### Exploratory Data Analysis

Computed directly in pandas, then charted with Matplotlib/Seaborn: total revenue and average order value, monthly and quarterly sales trends, category and gender breakdowns, age-group revenue, top 10 customers by spend, weekend vs. weekday sales, and a category-vs-gender revenue heatmap. The cleaned DataFrame is exported to `cleaned_retail_sales.csv` and then loaded into MySQL (table `sales_transactions`) via SQLAlchemy for the SQL stage below.

✅ **Python stage complete** — zero missing values, zero duplicates, and zero invalid records confirmed before moving to SQL.

---

## Part 2 — SQL: Business KPI Analysis

**File:** [`Retail Sales/MySql/retail_sales.sql`](./Retail%20Sales/MySql/retail_sales.sql)

**Database:** MySQL, database `retail_sales_analysis`, table `sales` (renamed from `sales_transactions`, with columns standardized after load)

Queries grouped into five sections:

1. **Revenue KPIs** — total revenue, highest/lowest revenue category, highest-quantity category
2. **Time Trends** — monthly sales trend, highest revenue month, highest revenue quarter, running monthly revenue total (window function)
3. **Customer Analytics** — highest-spending customer, top 10 customers by revenue, repeat customers, customer segmentation (High/Medium/Low value via `CASE`)
4. **Sales & Order Analysis** — average order value, highest single transaction, weekend vs. weekday sales
5. **Product & Profitability** — category revenue contribution %, category sales ranking (`RANK()` window function), category profit, total business profit

**SQL concepts used:** `GROUP BY`, `ORDER BY`, aggregate functions, `CASE`, subqueries, `RANK()` and `SUM() OVER()` window functions.

✅ **SQL stage complete** — every KPI above was independently re-computed in pandas (see [Cross-Tool Validation](#cross-tool-validation)) and matched exactly.

---

## Part 3 — Power BI: Dashboard

**File:** [`Retail Sales/Power BI/Retail Sales Analysis.pbix`](./Retail%20Sales/Power%20BI/Retail%20Sales%20Analysis.pbix)

Two report pages, built on the same cleaned dataset used in Python and SQL.

### Page 1 — Executive Sales Overview

KPI cards for total revenue, total orders, average order value, and total customers, plus monthly revenue trend, revenue by quarter, revenue by gender, revenue by product category, revenue by age group, and revenue by customer type — filterable by category, gender, and month.

![Retail Sales Analysis Dashboard - Executive Overview](./Retail%20Sales/Power%20BI/retail%201%20(2).png)

### Page 2 — Product & Time Analysis

Quantity sold by category, profit estimate by category, revenue by quarter and category, and weekend vs. weekday revenue split — filterable by quarter, revenue segment, and category.

![Retail Sales Analysis Dashboard - Product & Time Analysis](./Retail%20Sales/Power%20BI/retail%202%20(1).png)

---

## Cross-Tool Validation

The dashboard's headline numbers, re-derived independently in pandas straight from the raw CSV:

| Metric | Dashboard | Python (independent check) |
|---|---:|---:|
| Total Revenue | 456K | $456,000 ✅ |
| Total Orders | 1K | 1,000 ✅ |
| Average Order Value | 456.00 | $456.00 ✅ |
| Total Customers | 1K | 1,000 ✅ |
| Revenue by Gender — Male / Female | 223K / 233K | $223,160 / $232,840 ✅ |
| Revenue by Quarter — Q1/Q2/Q3/Q4 | 110K / 124K / 96K / 126K | $110,030 / $123,735 / $96,045 / $126,190 ✅ |
| Revenue by Category — Electronics/Clothing/Beauty | 157K / 156K / 144K | $156,905 / $155,580 / $143,515 ✅ |
| Revenue by Age Group — Adult/Young Adult/Senior/Teen | 193K / 157K / 80K / 26K | $192,560 / $156,945 / $80,410 / $26,085 ✅ |
| Revenue by Customer Type — Premium/Regular | 98K / 358K | $98,000 / $358,000 ✅ |
| Revenue by Weekend — True/False | 137K / 319K | $137,415 / $318,585 ✅ |
| Quantity Sold — Clothing/Electronics/Beauty | 0.89K / 0.85K / 0.77K | 894 / 849 / 771 ✅ |
| Profit Estimate — Electronics/Clothing/Beauty | 47K / 47K / 43K | $47,071.50 / $46,674.00 / $43,054.50 ✅ |

Every headline number on the dashboard matches the independent Python calculation.

---

## Key Insights & Recommendations

**1. Revenue is close to evenly split across all three categories** — Electronics ($156,905), Clothing ($155,580), and Beauty ($143,515) are all within about 9% of each other. → There isn't a single underperforming category dragging the business down; if anything, Beauty is only modestly behind, not failing.

**2. "Premium" customers (>$1,500 lifetime spend) are just 4.9% of the customer base but drive 21.5% of total revenue** (98,000 of 456,000). → A small group is disproportionately valuable — worth a dedicated retention or loyalty approach rather than treating all customers the same.

**3. Weekday sales (69.9% of revenue) heavily outweigh weekend sales (30.1%)** — the opposite of what many retail intuitions assume. → Worth checking whether this is a real customer behavior pattern or a byproduct of how this dataset was generated, before basing a staffing or promotion decision on it.

**4. Adults (36–55) generate more revenue than any other age group** ($192,560, well ahead of Young Adults at $156,945), while Teens contribute the least by a wide margin ($26,085). → Marketing spend aimed at the Adult segment looks better justified by this data than a broad, all-ages campaign.

**5. There are no repeat customers in this dataset** — every customer appears in exactly one transaction. → "Top Customers by Revenue" and "Repeat Customers" should be read as *largest single purchases*, not loyalty or retention indicators; a genuine retention analysis would need a dataset with multiple transactions per customer.

---

## Repository Structure

```text
End-to-End-Retail-Sales-Analytics/
├── README.md
└── Retail Sales/
    ├── Dataset/
    │   ├── retail_sales_dataset.csv      # Raw dataset (1,000 transactions)
    │   └── cleaned_retail_sales.xls      # Cleaned & feature-engineered export
    ├── MySql/
    │   └── retail_sales.sql              # Business KPI queries
    ├── Power BI/
    │   ├── Retail Sales Analysis.pbix    # Power BI dashboard
    │   ├── retail 1 (2).png              # Executive Overview screenshot
    │   └── retail 2 (1).png              # Product & Time Analysis screenshot
    └── Retail_sales_analysis.ipynb       # Data cleaning, feature engineering & EDA (Python)
```

---

## Tools Used

| Stage | Tools & Techniques |
|---|---|
| Python | pandas, NumPy, Matplotlib, Seaborn, SQLAlchemy, Jupyter Notebook |
| SQL | MySQL, `CASE`, subqueries, `RANK()`, `SUM() OVER()` window functions |
| Visualization | Power BI (2 report pages, cross-filtered by category/gender/month/quarter) |

---

**Author:** Saurabh Gopal Chaudhari
**Connect:** [LinkedIn](https://www.linkedin.com/in/saurabh-chaudhari-ds/)
