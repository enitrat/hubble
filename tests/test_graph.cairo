%lang starknet
from cairo_graphs.graph.graph import GraphMethods
from cairo_graphs.data_types.data_types import Edge, Graph
from starkware.cairo.common.alloc import alloc

const TOKEN_A = 123;
const TOKEN_B = 456;
const TOKEN_C = 990;
const TOKEN_D = 982;

@external
func test_build_graph() {
    let edges: Edge* = alloc();
    assert edges[0] = Edge(TOKEN_A, TOKEN_B, 1);
    assert edges[1] = Edge(TOKEN_A, TOKEN_C, 1);
    assert edges[2] = Edge(TOKEN_B, TOKEN_C, 1);

    let graph = GraphMethods.build_undirected_graph_from_edges(
        3, edges
    );
    assert graph.length = 3;
    assert graph.vertices[0].identifier = TOKEN_A;
    assert graph.vertices[1].identifier = TOKEN_B;
    assert graph.vertices[2].identifier = TOKEN_C;
    assert graph.adjacent_vertices_count[0] = 2;
    assert graph.adjacent_vertices_count[1] = 2;
    assert graph.adjacent_vertices_count[2] = 2;
    return ();
}
