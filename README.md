# 🛒 Customer Segmentation Using RFM Analysis
### Brazilian E-Commerce (Olist) | MySQL

---

## 📌 Business Problem

Olist's marketing team allocates budget equally across all customers regardless of their
purchase behaviour. This is inefficient — spending the same on a one-time low-value buyer
as on a high-value loyal customer wastes marketing budget.

**Goal:** Segment 93,000+ customers by Recency and Monetary behaviour to identify who
to retain, reward, and re-engage — enabling targeted, cost-effective marketing campaigns.

---

## 🗂️ Dataset

| Detail | Info |
|---|---|
| Source | Kaggle — Brazilian E-Commerce Public Dataset by Olist |
| Link | kaggle.com/datasets/olistbr/brazilian-ecommerce |
| Tables Used | orders, order_items, customers, order_reviews |
| Time Period | September 2016 – October 2018 |
| Total Records | ~100,000 orders |
| Delivered Orders Analysed | ~96,500 orders |

---

## 🔍 Data Quality & Profiling Findings

| Finding | Detail |
|---|---|
| NULL delivery dates | Present — excluded using WHERE clause |
| Duplicate customer_ids | Resolved using customer_unique_id instead of customer_id |
| Order filter applied | Only status = 'delivered' orders included |
| Date range confirmed | Sept 2016 to Oct 2018 — 2 full years of data |

### ⚠️ Critical Data Limitation Discovered

```
97% of Olist customers placed exactly ONE order:
  - 1 order  : 90,557 customers (97.00%)
  - 2 orders :  2,573 customers  (2.76%)
  - 3+ orders:    228 customers  (0.24%)
```

Standard 3-dimension RFM was adapted to a **Recency + Monetary (RM) model**
because Frequency cannot differentiate a customer base where 97% bought once.
This itself is a key business insight — Olist's core challenge is converting
first-time buyers into repeat customers.

---

## ❓ Key Business Questions Answered

1. What percentage of revenue comes from our highest-value customers?
2. How many customers are at risk of permanent churn?
3. Which customer segments should receive loyalty vs win-back campaigns?
4. Does late delivery directly impact customer review scores?
5. What is the month-over-month revenue growth trend?

---

## 📊 RFM Segmentation Results

| Segment | Customers | % of Customers | Avg Spend | Total Revenue | % of Revenue | Avg Days Since Purchase |
|---|---|---|---|---|---|---|
| **Champion** | 15,396 | 16.49% | R$306.56 | R$4,719,724 | 30.61% | 140 days |
| At Risk - High Value | 14,529 | 15.56% | R$310.42 | R$4,510,105 | 29.25% | 442 days |
| Loyal Customer | 11,147 | 11.94% | R$225.24 | R$2,510,714 | 16.28% | 269 days |
| At Risk | 15,347 | 16.44% | R$89.06 | R$1,366,761 | 8.86% | 442 days |
| Promising | 14,632 | 15.67% | R$89.92 | R$1,315,701 | 8.53% | 138 days |
| Needs Attention | 18,408 | 19.72% | R$45.73 | R$841,829 | 5.46% | 235 days |
| **Lost** | 3,899 | 4.18% | R$39.74 | R$154,936 | 1.00% | 524 days |

---

## 💡 Key Findings

- **Champions (16.5% of customers) drive 30.6% of total revenue** — classic Pareto pattern
- **At Risk - High Value segment is critical:** 14,529 customers who spent R$310 avg but haven't bought in 442 days — highest priority for win-back campaigns
- **59.86% of revenue** comes from just Champion + At Risk High Value combined
- **Lost customers** (524 avg days, R$39 avg spend) — minimal re-engagement value
- Champions and Promising segments have similar recency (140 vs 138 days) but vastly different spend — acquisition vs monetisation gap

---

## 💼 Business Recommendations

| Priority | Segment | Recommended Action |
|---|---|---|
| 🔴 Urgent | At Risk - High Value | Win-back campaign — personalised offer within 30 days |
| 🟢 Invest | Champion | VIP loyalty programme — early access, exclusive rewards |
| 🟡 Nurture | Promising | Product recommendation emails — increase basket size |
| 🟡 Nurture | Loyal Customer | Retention offers — prevent recency from declining |
| ⚫ Minimal | Lost | Only re-engage if cost per contact is under R$5 |

---

## 🐛 Bugs Found & Fixed During Development

Documenting bugs shows analytical rigour — this is what real analysts do.

| Bug | Root Cause | Fix |
|---|---|---|
| Champions showed lowest avg spend | NTILE ORDER BY monetary DESC assigned score 5 to lowest spenders | Changed to ASC |
| Lost customers showed most recent dates | NTILE ORDER BY recency_days ASC assigned score 1 to most recent buyers | Changed to DESC |
| All segments had equal customer counts | Frequency = 1 for 97% of customers — NTILE split was arbitrary | Removed frequency, used R+M only |

**Rule learned:**
```
Recency   → ORDER BY recency_days DESC  (score 5 = most recent = best)
Monetary  → ORDER BY monetary ASC       (score 5 = highest spend = best)
Frequency → ORDER BY frequency ASC      (score 5 = most orders = best)
```

---

## 🛠️ SQL Concepts Used

```
✅ Multi-table JOINs (4 tables)       ✅ CTEs — chained 5 levels deep
✅ Window Functions — NTILE()          ✅ Window Functions — LAG()
✅ Window Functions — RANK()           ✅ CASE statements
✅ Date functions — DATEDIFF()         ✅ Aggregate functions — SUM, AVG, COUNT
✅ Subqueries                          ✅ Data profiling queries
✅ NULL handling                       ✅ HAVING clause
✅ PERCENT_RANK()                      ✅ SUM() OVER() for totals
```

---

## 📁 Project Files

```
olist-rfm-segmentation/
│
├── README.md
├── sql/
│   ├── 01_table_setup.sql
│   ├── 02_data_profiling.sql
│   ├── 03_basic_analysis.sql
│   ├── 04_intermediate_analysis.sql
│   └── 05_rfm_segmentation.sql
└── findings/
    └── key_findings.md
```

---

## 📚 What I Learned

- How to adapt a standard model (RFM) when data does not support one of its dimensions
- How to use CTEs to build complex multi-step queries in readable, logical stages
- How NTILE direction (ASC vs DESC) completely changes what a score means
- How to debug unexpected query output by comparing expected vs actual patterns
- How to treat data limitations as findings rather than failures

---

## 🔗 Tools Used

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Query%20Language-F29111?style=for-the-badge&logo=databricks&logoColor=white)
![DBeaver](https://img.shields.io/badge/DBeaver-Database%20Client-382923?style=for-the-badge&logo=dbeaver&logoColor=white)
![Kaggle](https://img.shields.io/badge/Kaggle-Dataset-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)

---

## 👤 Author

**Nisha**
Process Analyst transitioning into Data Analytics
[LinkedIn](https://www.linkedin.com/in/niishayadav) | [GitHub](https://github.com/niishayadav12)

*Part of a 10-project SQL + Excel + Power BI portfolio.*

