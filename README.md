## End-to-End Customer Churn Analytics 




![dbt](https://img.shields.io/badge/dbt-analytics_engineering-FF694B?logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-data_warehouse-29B5E8?logo=snowflake&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-visualization-E97627?logo=tableau&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![uv](https://img.shields.io/badge/uv-package_manager-DE5FE9)
![SQLFluff](https://img.shields.io/badge/SQLFluff-SQL_linting-4B8BBE)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)


#### What is it ?

The goal of this project is to build a Full automated production analytics pipeline for analyzing customer churn.

The pipeline ingests telecom customer data into Snowflake, transforms it using dbt, validates data quality through automated tests, and exposes analytics-ready models for Tableau dashboards. automation part By GitHub Actions CI/CD.


## Project Objectives

This project focuses on applying analytics engineering practices rather than only building SQL transformations.

Key objectives include:

- Build modular dbt models
- Implement dimensional data modeling
- Create customer churn fact tables
- Use incremental models for efficient processing
- Preserve historical customer data
- Implement automated data-quality tests
- Apply SQL linting
- Manage dependencies with `uv`
- Build isolated CI environments
- Automate validation using GitHub Actions
- Publish analytics-ready data for Tableau

---

## Architecture

```text
                        ┌─────────────────────┐
                        │     externel source │
                        └──────────┬──────────┘
         producing Monthly data    │ 
                                   |
                                   ▼
                        ┌─────────────────────┐  
                        | Data quality checks |
                        └──────────┬──────────┘
 Then get loaded to                |
 snowflake By a Py Script          |
                                   |
                                   ▼
                        ┌─────────────────────┐
                        │      Snowflake      │
                        │        RAW          │
                        └──────────┬──────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │     dbt Sources     │
                        └──────────┬──────────┘
  implement incremental models     |
   macros,ninja templates          │
                                   ▼
                     ┌──────────────────────────┐
                     │      Staging Layer       │
                     │                          │
                     └────────────┬─────────────┘
                                  │
                                  ▼
                     ┌──────────────────────────┐
                     │   Intermediate Layer     │
                     │                          │
                     │ customer transformations │
                     │ churn calculations       │
                     └────────────┬─────────────┘
                                  │
                                  ▼
                     ┌──────────────────────────┐
                     │        Data Marts        |
                     └────────────┬─────────────┘
                                  │
                                  ▼
                        ┌─────────────────────┐
                        │       Tableau       │
                        │     Dashboards      │
                        └─────────────────────┘
```


# Data Modeling

## Staging Layer

The staging layer performs lightweight transformations on raw Snowflake data.

Typical responsibilities include:

- Renaming source columns
- Standardizing data types
- Handling invalid values
- Normalizing boolean fields
- Cleaning text fields
- Preparing data for downstream models


---

## Fact Tables

Fact models contain measurable business events and metrics.

An example grain for the monthly customer fact table is:

```text
customer_id + date
```
 

This allows customer behavior to be analyzed over time.

---

# Incremental Processing

Large fact tables are processed incrementally instead of being rebuilt completely on every dbt run.

Example configuration:

```sql
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['customer_id', 'date']
    )
}}
```

Incremental filtering can be applied using:

```sql
{% if is_incremental() %}

and "Date" >= (
    select coalesce(max(date), '190001')
    from {{ this }}
)

{% endif %}
```

Using `merge` allows dbt to:

```text
Existing key
    ↓
UPDATE

New key
    ↓
INSERT
```

This helps support both new monthly data and late-arriving records.

---

# Data Quality

Data quality is enforced through dbt tests.

Examples include:

```yaml
models:
  - name: fct_customer_monthly

    columns:
      - name: customer_id
        data_tests:
          - not_null

      - name: date
        data_tests:
          - not_null

      - name: monthly_charges
        data_tests:
          - not_null
```

The project can also include custom business-rule tests such as:

```text
monthly_charges >= 0

tenure >= 0

customer_id must exist

customer_id + date must be unique

total_charges >= 0
```

Tests are executed using:

```bash
uv run dbt test
```

or as part of:

```bash
uv run dbt build
```

---

# SQL Linting

SQLFluff is used to enforce SQL quality and consistent formatting.

Run linting locally with:

```bash
uv run sqlfluff lint models/
```

Automatically fix supported issues with:

```bash
uv run sqlfluff fix models/
```


- make sure to change .sqlfluff configuration

---

# Environment Management

Python dependencies are managed using `uv`.

Install dependencies:

```bash
uv sync --locked
```

Run dbt commands:

```bash
uv run dbt debug
```

```bash
uv run dbt build
```

Run SQLFluff:

```bash
uv run sqlfluff lint models/
```

Using `uv.lock` ensures reproducible dependency installation in both local development and CI environments.

---

# Snowflake Configuration

Snowflake credentials are loaded through environment variables.

Example `profiles.yml`:

```yaml
subscription_churn:

  target: dev

  outputs:

    dev:
      type: snowflake
      account: "{{ env_var('DBT_SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('DBT_SNOWFLAKE_USER') }}"
      password: "{{ env_var('DBT_SNOWFLAKE_PASSWORD') }}"
      role: "{{ env_var('DBT_SNOWFLAKE_ROLE') }}"
      database: "{{ env_var('DBT_SNOWFLAKE_DATABASE') }}"
      warehouse: "{{ env_var('DBT_SNOWFLAKE_WAREHOUSE') }}"
      schema: "{{ env_var('DBT_SCHEMA') }}"
      threads: 4

    ci:
      type: snowflake
      account: "{{ env_var('DBT_SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('DBT_SNOWFLAKE_USER') }}"
      password: "{{ env_var('DBT_SNOWFLAKE_PASSWORD') }}"
      role: "{{ env_var('DBT_SNOWFLAKE_ROLE') }}"
      database: "{{ env_var('DBT_SNOWFLAKE_DATABASE') }}"
      warehouse: "{{ env_var('DBT_SNOWFLAKE_WAREHOUSE') }}"
      schema: "{{ env_var('DBT_SCHEMA') }}"
      threads: 4
```

Sensitive credentials are never committed directly to Git.

---

# Local Setup

## 1. Clone the repository

```bash
git clone <repository-url>
cd <repository-name>
```

## 2. Install dependencies

```bash
uv sync --locked
```

## 3. Configure environment variables

Create a local `.env` file:

```env
DBT_SNOWFLAKE_ACCOUNT=<account>
DBT_SNOWFLAKE_USER=<user>
DBT_SNOWFLAKE_PASSWORD=<password>
DBT_SNOWFLAKE_ROLE=<role>
DBT_SNOWFLAKE_DATABASE=<database>
DBT_SNOWFLAKE_WAREHOUSE=<warehouse>
DBT_SCHEMA=<development_schema>
```

Do not commit `.env`.

Add it to `.gitignore`:

```text
.env
```

## 4. Test the dbt connection

```bash
uv run dbt debug
```

## 5. Install dbt packages

If the project uses packages:

```bash
uv run dbt deps
```

## 6. Build the project

```bash
uv run dbt build
```

---

# CI/CD

GitHub Actions is used to automatically validate changes.

The CI workflow runs when a pull request targets `main`.

```text
Developer
   │
   ▼
Feature / Dev Branch
   │
   ▼
Pull Request
   │
   ▼
GitHub Actions
   │
   ├── Install dependencies
   ├── SQLFluff lint
   ├── dbt debug
   ├── dbt compile
   └── dbt build
           │
           ▼
      Merge allowed
```

---

## CI Workflow

Example:

```yaml
name: dbt CI

on:
  pull_request:
    branches:
      - main

jobs:
  dbt-ci:
    runs-on: ubuntu-latest

    env:
      DBT_SNOWFLAKE_ACCOUNT: ${{ secrets.DBT_SNOWFLAKE_ACCOUNT }}
      DBT_SNOWFLAKE_USER: ${{ secrets.DBT_SNOWFLAKE_USER }}
      DBT_SNOWFLAKE_PASSWORD: ${{ secrets.DBT_SNOWFLAKE_PASSWORD }}
      DBT_SNOWFLAKE_ROLE: ${{ secrets.DBT_SNOWFLAKE_ROLE }}
      DBT_SNOWFLAKE_DATABASE: ${{ secrets.DBT_SNOWFLAKE_DATABASE }}
      DBT_SNOWFLAKE_WAREHOUSE: ${{ secrets.DBT_SNOWFLAKE_WAREHOUSE }}

      DBT_SCHEMA: CI_PR_${{ github.event.pull_request.number }}

    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Install uv
        uses: astral-sh/setup-uv@v10.2.0

      - name: Install Python
        run: uv python install 3.12

      - name: Install dependencies
        run: uv sync --locked

      - name: SQL lint
        run: uv run sqlfluff lint models/

      - name: dbt debug
        run: uv run dbt debug --target ci

      - name: dbt compile
        run: uv run dbt compile --target ci

      - name: dbt build
        run: uv run dbt build --target ci
```

Each pull request can use an isolated Snowflake schema:

```text
CI_PR_10
CI_PR_11
CI_PR_12
```

This prevents CI runs from modifying production tables.

---

# CI Validation Strategy

The current validation process is:

```text
SQLFluff
    ↓
Validate SQL style

dbt debug
    ↓
Validate configuration and Snowflake connection

dbt compile
    ↓
Validate SQL + Jinja compilation

dbt build
    ↓
Build models + execute tests
```

If any step fails, the GitHub Actions workflow fails.

---

# Deployment Strategy

Production deployment can be triggered when changes are merged into `main`.

Recommended flow:

```text
Pull Request
     │
     ▼
CI Validation
     │
     ▼
Merge
     │
     ▼
main
     │
     ▼
CD Workflow
     │
     ▼
dbt build --target prod
     │
     ▼
Snowflake Production Models
```

CI and production should use different Snowflake schemas and ideally different roles.

---

# Analytics

The transformed models are consumed by Tableau.

The dashboard can be used to analyse metrics such as:

- Customer count
- Churned customers
- Churn rate
- Monthly churn evolution
- Customer tenure
- Monthly charges
- Total charges
- Contract type
- Payment method
- Internet service
- Senior-citizen segmentation
- Active vs churned customers
- Month-over-month KPI changes

## Dashboards:
Overview: KPI cards with red/teal deltas, four churn and revenue bar charts with the highest bar highlighted, key findings and a definition footer.

![Overview](Tableau%20reports/1-Overview.png)


Churn Drivers: the two heatmaps with readable headers ("No partner | Partner", "No phone service | Phone service") and % labels, the three household bars, payment method, price band and findings.

![Churn Drivers](Tableau%20reports/2-Churn%20Drivers.png)


Revenue Impact: revenue per churned customer ($618, which is $18.45M ÷ 29,869), revenue loss by contract, tenure and internet service, the top 10 segments as a ranked list, and the share of churned customers vs share of revenue lost.

![Revenue Impact](Tableau%20reports/3-Revenue%20Impact.png)

Methodology: data flow, star schema, definitions and dbt tests
![Methodology](Tableau%20reports/4-Methodology.png)

---

# Example Churn Metrics

Churn rate:

```text
Churn Rate =
Churned Customers
──────────────────
 Total Customers
```

Month-over-month variation:

```text
Current Month - Previous Month
──────────────────────────────
       Previous Month
```

---

# Current Engineering Features

The project currently covers several analytics-engineering concepts:

- dbt source definitions
- Staging models
- Fact and dimension modeling
- Snowflake transformations
- Incremental models
- Merge-based incremental strategy
- Composite unique keys
- Data-quality testing
- SQL linting
- Git version control
- GitHub Actions CI
- Isolated CI schemas
- Environment-variable-based credentials
- Reproducible Python environments using `uv`
- Tableau integration

---

# Planned Improvements

Future improvements include:

- dbt snapshots for Slowly Changing Dimensions
- Custom generic dbt tests
- Source freshness checks
- Model contracts
- dbt model versions
- Surrogate-key macros
- Reusable Jinja macros
- Separate Snowflake CI and production roles
- Automatic cleanup of PR-specific schemas
- Production deployment workflow
- GitHub branch protection
- Slim CI
- `state:modified+`
- dbt state comparison
- `--defer`
- Production `manifest.json` artifact management
- Automated dbt documentation publishing

---


# Security

Sensitive information must not be committed to the repository.

The following values are stored as GitHub Actions secrets:

```text
DBT_SNOWFLAKE_ACCOUNT
DBT_SNOWFLAKE_USER
DBT_SNOWFLAKE_PASSWORD
DBT_SNOWFLAKE_ROLE
DBT_SNOWFLAKE_DATABASE
DBT_SNOWFLAKE_WAREHOUSE
```

Local credentials should be stored in `.env`.

Files containing credentials should be excluded using `.gitignore`.

---

# Development Workflow

Recommended workflow:

```bash
git checkout -b feature/<feature-name>
```

Make changes and validate locally:

```bash
uv run sqlfluff lint models/
uv run dbt build
```

Commit:

```bash
git add .
git commit -m "describe the change"
```

Push:

```bash
git push origin feature/<feature-name>
```

Then open a pull request targeting `main`.

GitHub Actions validates the dbt project before the code is merged.
