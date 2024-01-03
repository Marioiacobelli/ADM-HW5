#!/bin/bash

#Script for analyzing the Citation Graph

#Start the Python interpreter and open an interactive script
python3 <<EOF

import networkx as nx

#Load the graph from the GML representation
citation_graph = nx.read_gml('citation_graph.gml')

#Extract the largest component (strongly connected)
largest_component = max(nx.strongly_connected_components(citation_graph), key=len)
citation_graph_largest_component = citation_graph.subgraph(largest_component)

#Find the central nodes that connect different parts of the graph
central_nodes = nx.center(citation_graph_largest_component)
print("The Central Nodes (important connectors) are:", central_nodes)

#Calculate the degree centrality for each node
degree_centrality = nx.degree_centrality(citation_graph_largest_component)
print("\nDegree Centrality for Each Node:")
for node, centrality in degree_centrality.items():
    print(f"Node {node}: {centrality}")

#Calculate the average shortest path length between nodes
avg_shortest_path_length = nx.average_shortest_path_length(citation_graph_largest_component)
print("\nThe Average Shortest Path Length is:", avg_shortest_path_length)

EOF

