#!/bin/bash

#Define the edgelist file
edgelist_file="citation_graph.edgelist"

#1. Script to find important connector nodes in the Citation Graph based on degree centrality
#Extract the top 10 nodes with high degrees
top_nodes=$(sort -k2 -nr "$edgelist_file" | awk '{print $1}' | uniq -c | sort -k1,1nr | head -n 10)

#Print the result
if [ -n "$top_nodes" ]; then
    echo "Important Connector Nodes (Top 10):"
    echo "$top_nodes"
else
    echo "No important connector nodes found."
fi

#2. Script to analyze the degree of citation in the Citation Graph
#Extract edges and source nodes from the edgelist file
edges=$(awk '{print $1, $2}' citation_graph.edgelist)

#Extract and count the degrees of each source node
node_degrees=$(echo "$edges" | awk '{print $1}' | sort | uniq -c | awk '{print $1}')

#Calculate descriptive statistics
mean_degree=$(echo "$node_degrees" | awk '{sum+=$1} END {print sum/NR}')
sorted_degrees=$(echo "$node_degrees" | sort -n)
median_index=$((NR / 2 + 1))
median_degree=$(echo "$sorted_degrees" | awk 'NR == '$median_index' {print $1}')
std_dev_degree=$(echo "$node_degrees" | awk -v mean=$mean_degree '{sum+=($1-mean)^2} END {print sqrt(sum/NR)}')

#Print the statistics
echo "Statistics to describe the variation of the degree of citation among the graph nodes:"
echo "- Mean Degree: $mean_degree"
echo "- Median Degree: $median_degree"
echo "- Standard Deviation of Degree: $std_dev_degree"

#3. Script to calculate the average shortest path length in the Citation Graph

#Calculate the average shortest path length for the largest strongly connected component
avg_shortest_path_length=$(awk '{print $1, $2}' $edgelist_file | sort -u | python3 -c "
import networkx as nx
import sys

#Read edges from stdin and create a directed graph
G = nx.DiGraph()
for line in sys.stdin:
    source, target = map(int, line.split())
    G.add_edge(source, target)

#Find the largest strongly connected component
largest_component = max(nx.strongly_connected_components(G), key=len)

#Create a subgraph with only the largest strongly connected component
G_largest_component = G.subgraph(largest_component)

#Calculate average shortest path length
avg_shortest_path_length = nx.average_shortest_path_length(G_largest_component)
print(f'{avg_shortest_path_length:.2f}')
")

#Print the result
echo "Average Shortest Path Length: $avg_shortest_path_length"
