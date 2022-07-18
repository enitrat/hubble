%lang starknet
from src.contracts.graph import (
    build_graph,
)

from src.contracts.dfs_search import init_dfs

from src.data_types.data_types import Pair, Node
from starkware.cairo.common.alloc import alloc

const TOKEN_A = 123
const TOKEN_B = 456
const TOKEN_C = 990
const TOKEN_D = 982

@external
func test_dfs():
    let pairs : Pair* = alloc()
    assert pairs[0] = Pair(TOKEN_A, TOKEN_B)
    assert pairs[1] = Pair(TOKEN_A, TOKEN_C)
    assert pairs[2] = Pair(TOKEN_B, TOKEN_C)
    
    let expected_paths: felt* = alloc()
    # asse

    let (graph_len, graph, neighbors) = build_graph(pairs_len=3, pairs=pairs)

    let node_a = graph[0]
    let node_b = graph[1]
    init_dfs(graph_len, graph, neighbors,node_a,node_b,4)

    return ()
end
