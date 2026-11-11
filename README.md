# Netflix Analytics Engineering Project

An end-to-end analytics engineering project built with **Snowflake and dbt Core**, transforming raw netflix data into structured analytical models for movie ratings, user engagement, genre analysis and tag relevance.

The project demonstrates data transformation, dimensional modeling, incremental processing, snapshotting, reusable macros and data quality testing within a modern cloud data warehouse.

---

## Project Overview

The  dataset contains information about movies, user ratings, user-generated tags, movie links, and the Tag Genome dataset.

This project uses dbt to transform the raw data into an organized analytical data model in Snowflake.

The objective is to create reliable, reusable datasets that support analytical queries and downstream reporting.

### Key Features

- **Data transformation:** Clean and standardize raw MovieLens data using modular dbt models.
- **Dimensional modeling:** Organize transformed data into dimension and fact tables.
- **Incremental processing:** Use incremental materialization to process new rating records.
- **Snapshotting:** Implement timestamp-based snapshots to track changes in user-generated tags.
- **Reusable macros:** Use Jinja and dbt macros to generate reusable SQL logic.
- **Data quality:** Apply schema tests and custom SQL tests.
- **Analytical models:** Build a mart combining rating data with supplementary movie release information.



## Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data warehouse |
| dbt Core | Data transformation and modeling |
| SQL | Data manipulation and transformation |
| Jinja | Dynamic SQL generation |
| Python | Supporting development environment |
| Git & GitHub | Version control and project documentation |

---

## Architecture

The project follows a layered transformation approach.

```text
                 MOVIELENS DATASET
                         |
                         v
                SNOWFLAKE RAW LAYER
                         |
                         v
                  STAGING MODELS
               (Source preparation)
                         |
                         v
                 TRANSFORMATION
                         |
              +----------+----------+
              |                     |
              v                     v
        DIMENSION MODELS       FACT MODELS
              |                     |
              +----------+----------+
                         |
                         v
                    MART LAYER
                         |
                         v
                 ANALYTICAL QUERIES
```

### Data Layers

| Layer | Purpose |
|---|---|
| Raw | Stores the ingested MovieLens source data. |
| Staging | References and prepares raw source data for transformation. |
| Dimensions | Provides descriptive entities such as movies, users, and genome tags. |
| Facts | Stores measurable events and relationships, including ratings and genome scores. |
| Mart | Combines transformed data for specific analytical use cases. |

---

## Dataset

The project uses the MovieLens dataset, which includes the following source entities:

| Dataset | Description |
|---|---|
| Movies | Movie identifiers, titles, and genres. |
| Ratings | User ratings assigned to movies, including timestamps. |
| Tags | User-generated tags associated with movies. |
| Links | External identifiers associated with movies. |
| Genome Tags | Descriptive tag identifiers and names. |
| Genome Scores | Relevance scores connecting movies to genome tags. |

A supplementary CSV seed containing movie release-date information is also used in the project.

---

## Data Models

The project uses modular dbt models organized by transformation layer.

### 1. Staging Models

Staging models provide the initial transformation layer between raw source tables and downstream analytical models.

| Model | Source |
|---|---|
| `src_movies` | Raw movies |
| `src_ratings` | Raw ratings |
| `src_tags` | Raw tags |
| `src_links` | Raw links |
| `src_genome_tags` | Raw genome tags |
| `src_genome_score` | Raw genome scores |

These models are referenced by downstream transformations using dbt's `ref()` function.

### 2. Dimension Models

| Model | Description |
|---|---|
| `dim_movies` | Standardizes movie titles and transforms pipe-separated genres into an array. |
| `dim_users` | Consolidates distinct users appearing in ratings and tags. |
| `dim_genome_tags` | Standardizes genome tag names. |
| `dim_movies_with_tags` | Combines movie information with genome tags and relevance scores. |

`dim_movies_with_tags` uses ephemeral materialization, allowing dbt to incorporate its SQL into downstream models rather than creating a standalone warehouse table.

### 3. Fact Models

| Model | Description | Materialization |
|---|---|---|
| `fct_ratings` | Stores user ratings, movie identifiers, and rating timestamps. | Incremental |
| `fct_genome_score` | Stores movie-tag relevance scores, filtered to positive values and rounded to four decimal places. | Table |

#### Incremental Processing

The `fct_ratings` model uses incremental materialization with a timestamp-based filter.

On subsequent incremental runs, it selects records with a `rating_timestamp` greater than the maximum timestamp already present in the target model.

The model also uses `on_schema_change='fail'` to prevent automatic acceptance of schema changes.

### 4. Mart Model

| Model | Description | Materialization |
|---|---|---|
| `mart_movie_releases` | Combines rating records with supplementary movie release-date information and adds a release-information availability flag. | Table |

The mart uses a left join to retain rating records even when supplementary release-date information is unavailable.

---

## Advanced dbt Features

### Snapshots

The project includes a snapshot model named `snap_tags`.

It uses:

- Timestamp-based snapshot strategy.
- `tag_timestamp` as the update timestamp.
- A composite user/movie/tag key.
- Hard-delete invalidation.

This demonstrates how dbt snapshots can preserve historical versions of records when tracked changes are detected.

### Seeds

The project includes:

`seed_movie_release_date.csv`

This seed supplements the MovieLens dataset with movie release-date information.

It is referenced by the `mart_movie_releases` model.

### Custom Macros

The project includes a reusable macro:

`no_nulls_in_columns`

The macro uses dbt's adapter functionality to dynamically retrieve column metadata and generate SQL intended to identify records containing NULL values.

This demonstrates the use of Jinja and reusable SQL generation in dbt.

### Data Quality Testing

The project includes:

- Schema-level `not_null` tests.
- Schema-level `unique` tests.
- Referential integrity testing using `relationships`.
- A custom SQL test intended to identify NULL values across model columns.

---

## Analytical Use Cases

The project includes exploratory SQL analyses designed to answer questions about movie ratings and user behavior.

| Analysis | Business Question |
|---|---|
| Top-Rated Movies | Which movies have the highest average ratings among movies with sufficient rating volume? |
| Genre Analysis | How do average ratings differ across movie genres? |
| User Engagement | Which users contribute the most ratings? |
| Release Trends | How many movies were released in each year? |
| Tag Relevance | Which genome tags have the highest average relevance scores? |

These analyses demonstrate how the transformed models can support downstream analytical work.

---

## Project Structure

```text
netflix/
│
├── analyses/
│   └── movie_analysis.sql
│
├── macros/
│   └── no_null_in_columns.sql
│
├── models/
│   ├── dim/
│   │   ├── dim_genome_tags.sql
│   │   ├── dim_movies.sql
│   │   ├── dim_movies_with_tags.sql
│   │   └── dim_users.sql
│   │
│   ├── fct/
│   │   ├── fct_genome_score.sql
│   │   └── fct_ratings.sql
│   │
│   ├── mart/
│   │   └── mart_movie_releases.sql
│   │
│   ├── staging/
│   │   ├── src_genome_score.sql
│   │   ├── src_genome_tags.sql
│   │   ├── src_links.sql
│   │   ├── src_movies.sql
│   │   ├── src_ratings.sql
│   │   └── src_tags.sql
│   │
│   ├── schema.yml
│   └── sources.yml
│
├── seeds/
│   └── seed_movie_release_date.csv
│
├── snapshots/
│   └── snap_tags.sql
│
├── tests/
│   └── relevance_score_test.sql
│
├── dbt_project.yml
├── packages.yml
├── package-lock.yml
└── README.md
```

---

## Getting Started

### Prerequisites

Before running the project, ensure you have:

- Python installed.
- dbt Core installed.
- The dbt Snowflake adapter installed.
- A Snowflake account.
- A configured dbt profile with access to the relevant Snowflake database and schemas.
- The raw MovieLens source tables available in Snowflake.

### Installation

Clone the repository:

```bash
git clone <repository-url>
```

Navigate into the project directory:

```bash
cd netflix
```

Install dbt dependencies:

```bash
dbt deps
```

Verify the Snowflake connection:

```bash
dbt debug
```

Load the project seed:

```bash
dbt seed
```

Build the dbt project:

```bash
dbt build
```

Run snapshots separately if needed:

```bash
dbt snapshot
```

Generate documentation:

```bash
dbt docs generate
```

Start the local documentation server:

```bash
dbt docs serve
```

---

## Learning Outcomes

This project provided practical experience with:

- Building modular transformation pipelines using dbt.
- Working with Snowflake as a cloud data warehouse.
- Structuring analytical data using dimensional modeling concepts.
- Implementing incremental models.
- Managing historical data using snapshots.
- Loading supplementary datasets through dbt seeds.
- Writing reusable Jinja macros.
- Implementing schema and custom data quality tests.
- Using dbt's dependency management through `ref()` and source definitions.
- Organizing analytical SQL for downstream use cases.

---

## Future Improvements

Potential areas for further development include:

- Strengthening incremental processing to handle late-arriving records and updates.
- Improving snapshot key design and expanding historical coverage.
- Extending data quality tests to cover referential integrity and business rules across all fact models.
- Refining analytical queries for Snowflake compatibility and validating aggregation grain.
- Adding automated CI checks through GitHub Actions.
- Extending the mart layer to support additional analytical use cases.

---

**Project Focus:** Analytics Engineering | Snowflake | dbt Core | SQL | Data Modeling
