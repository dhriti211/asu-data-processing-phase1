<<<<<<< HEAD
# asu-data-processing-phase1
=======
﻿ASU Data Processing at Scale — Phase 1
>>>>>>> cbe826f (Initial import: Phase 1 project files and sample data)
# ASU — Data Processing at Scale (Phase 1)

**Project:** Graph Data Processing for NYC Taxi Trips  
**Course:** Data Processing at Scale — ASU

## One-line summary
Containerized Neo4j-based pipeline that loads NYC taxi trip data, builds a graph of locations and trips, and runs graph algorithms (PageRank, BFS) using the Neo4j Graph Data Science library.

## Quick start (local)
1. Build the Docker image:
   ```bash
   docker build -t asu-phase1:latest .
