%lang starknet
from src.contracts.graph import build_graph

from src.contracts.dfs_search import init_dfs

from src.data_types.data_types import Pair, Node
from starkware.cairo.common.alloc import alloc

const TOKEN_A = 123
const TOKEN_B = 456
const TOKEN_C = 990
const TOKEN_D = 982

# works, 2 ways
@external
func test_dfs{range_check_ptr}():
    let pairs : Pair* = alloc()
    assert pairs[0] = Pair(TOKEN_A, TOKEN_B)
    assert pairs[1] = Pair(TOKEN_A, TOKEN_C)
    assert pairs[2] = Pair(TOKEN_B, TOKEN_C)

    # let expected_paths: felt* = alloc()
    # assert expected_paths[0] = Pair(TOKEN_A, TOKEN_B)

    let (graph_len, graph, neighbors) = build_graph(pairs_len=3, pairs=pairs)

    let node_a = graph[0]
    let node_b = graph[1]
    let (saved_paths_len, saved_paths) = init_dfs(graph_len, graph, neighbors, node_a, node_b, 4)
    %{
        print(ids.saved_paths_len)
        for i in range(ids.saved_paths_len):
            print(memory[ids.saved_paths+i])
    %}

    return ()
end

# works, 3 ways
@external
func test_dfs_2{range_check_ptr}():
    let pairs : Pair* = alloc()
    assert pairs[0] = Pair(TOKEN_A, TOKEN_B)
    assert pairs[1] = Pair(TOKEN_A, TOKEN_C)
    assert pairs[2] = Pair(TOKEN_B, TOKEN_C)
    assert pairs[3] = Pair(TOKEN_D, TOKEN_C)
    assert pairs[4] = Pair(TOKEN_D, TOKEN_B)

    let (graph_len, graph, neighbors) = build_graph(pairs_len=5, pairs=pairs)

    let node_a = graph[0]
    let node_c = graph[2]
    let (saved_paths_len, saved_paths) = init_dfs(graph_len, graph, neighbors, node_a, node_c, 4)
    %{
        print(ids.saved_paths_len)
        for i in range(ids.saved_paths_len):
            print(memory[ids.saved_paths+i])
    %}

    return ()
end
