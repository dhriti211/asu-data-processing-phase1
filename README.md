# Data Processing at Scale — Phase 1  
**Graph Data Processing with Neo4j (NYC Taxi Data)**

## Overview
This project implements a **scalable graph-based data processing pipeline** using **Neo4j** and the **Graph Data Science (GDS) library**.  
It ingests NYC Yellow Taxi trip data, models it as a graph, and applies classic graph algorithms such as **PageRank** and **Breadth-First Search (BFS)** to analyze connectivity and importance of locations.

The entire system is **containerized with Docker**, ensuring full reproducibility and ease of deployment.

---

## 🔍 Problem Statement
Large-scale transportation datasets are difficult to analyze using traditional relational approaches when relationships between entities are central.

This project demonstrates how **graph databases** can:
- Model real-world relationships naturally
- Enable efficient traversal and ranking algorithms
- Scale analytics using specialized graph engines

---

## 🧠 What This Project Does
- Ingests **NYC Yellow Taxi data (March 2022)** into Neo4j
- Models:
  - **Nodes:** Taxi pickup/dropoff locations
  - **Edges:** Trips between locations
- Executes graph algorithms:
  - **PageRank** — identifies the most influential locations
  - **BFS** — explores reachability from Bronx locations
- Ensures reproducibility via Docker
- Passes an automated grading/test harness

---

## 🛠️ Tech Stack
- **Graph Database:** Neo4j
- **Graph Algorithms:** Neo4j Graph Data Science (GDS)
- **Language:** Python
- **Data Processing:** Pandas, PyArrow
- **Containerization:** Docker
- **Testing:** Automated Python test harness
- **Dataset:** NYC Yellow Taxi Trip Records

---

## 📊 Graph Model
- **Node Label:** `Location`
- **Relationship Type:** `TRIP`
- **Direction:** Pickup → Dropoff
- **Properties:**
  - Trip count
  - Aggregated metrics derived from trip data

This schema enables efficient traversal, ranking, and connectivity analysis.

---

## 🖥️ Neo4j Browser View
> 📌 *Add a screenshot here after running the container*

1. Open Neo4j Browser:  
   `http://localhost:7474`
2. Run a sample query:
   ```cypher
   MATCH (l:Location)-[t:TRIP]->(m:Location)
   RETURN l, t, m
   LIMIT 25;
