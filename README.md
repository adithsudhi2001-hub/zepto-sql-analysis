# 🛒 Zepto Quick-Commerce Catalog & Inventory Analysis (SQL)

A comprehensive SQL-based exploratory data analysis and inventory health assessment on 3,700+ retail SKUs from Zepto. This project analyzes catalog pricing health, discount strategies, stockout vulnerabilities, and capital lockup across retail categories.

---

## 📌 Executive Summary
Quick-commerce platforms rely on rapid fulfillment and high stock availability. This project audits catalog consistency, evaluates price-per-gram unit economics, quantifies capital tied up in unsold inventory, and calculates revenue exposure resulting from out-of-stock items.

---

## 🛠️ Tech Stack & Database Features
* **Database Engine:** PostgreSQL 18
* **SQL Techniques Applied:**
  * **DDL & Schema Constraints:** Primary keys, auto-incrementing serials, numeric precision
  * **Data Auditing & Cleaning:** NULL handling, zero/anomaly removal, currency unit conversion (paise to INR)
  * **Aggregate Metrics:** Inventory valuation, category-level stockout rates, average discount spread
  * **Advanced Analytics:** Window functions (`DENSE_RANK() OVER (PARTITION BY ...)`), conditional aggregation (`CASE WHEN`), safe division (`NULLIF`)

---

## 📂 Repository Structure
```text
├── README.md               # Executive summary and business insights
├── zepto_analysis.sql      # Complete SQL script (DDL, Data Cleaning, Analytics)
└── zepto_v2.csv            # Raw dataset
