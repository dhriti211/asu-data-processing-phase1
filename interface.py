from neo4j import GraphDatabase

class Interface:
    def __init__(self, uri, user, password):
        self._driver = GraphDatabase.driver(uri, auth=(user, password), encrypted=False)
        self._driver.verify_connectivity()

    def close(self):
        self._driver.close()

    def bfs(self, start_node, last_node):
        # TODO: Implement this method
        with self._driver.session(database="neo4j") as session:
            # Drop existing graph projection if any
            session.run("CALL gds.graph.drop('graph', false) YIELD graphName")

            # Project the graph
            session.run("""
                CALL gds.graph.project(
                    'graph',
                    'Location',
                    {
                        TRIP: {
                            type: 'TRIP',
                            properties: ['distance'],
                            orientation: 'NATURAL'
                        }
                    }
                )
            """)

            # Compute shortest path from start_node to last_node
            cypher = """
                MATCH (start:Location {name: $start_node})
                MATCH (target:Location {name: $last_node})
                CALL gds.shortestPath.dijkstra.stream('graph', {
                    sourceNode: id(start),
                    targetNode: id(target),
                    relationshipWeightProperty: 'distance'
                })
                YIELD nodeIds
                RETURN [nodeId IN nodeIds | {name: gds.util.asNode(nodeId).name}] AS path
            """
            result = session.run(cypher, start_node=start_node, last_node=last_node)

            # Return list of dicts with 'path' key
            return [{"path": record["path"]} for record in result]

    def pagerank(self, max_iterations, weight_property):
        # TODO: Implement this method
        with self._driver.session(database="neo4j") as session:
            # Drop existing graph projection if it exists
            session.run("CALL gds.graph.drop('graph', false) YIELD graphName")

            # Project the graph
            session.run("""
                CALL gds.graph.project(
                    'graph',
                    'Location',
                    {
                        TRIP: {
                            type: 'TRIP',
                            properties: [$weight_property],
                            orientation: 'NATURAL'
                        }
                    }
                )
            """, weight_property=weight_property)

            # Run PageRank
            cypher = """
                CALL gds.pageRank.stream('graph', {
                    maxIterations: $max_iterations,
                    dampingFactor: 0.85,
                    relationshipWeightProperty: $weight_property
                })
                YIELD nodeId, score
                RETURN gds.util.asNode(nodeId).name AS location, score
                ORDER BY score DESC
            """
            result = session.run(cypher, max_iterations=max_iterations, weight_property=weight_property)
            scores = [{"name": record["location"], "score": record["score"]} for record in result]

            max_node = scores[0]
            min_node = scores[-1]
            return max_node, min_node
