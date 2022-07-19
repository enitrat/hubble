%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starknet.contracts.graph import build_graph
from starknet.contracts.dfs_search import init_dfs
from starknet.data_types.data_types import Pair, Node
from starknet.contracts.hubble_library import Hubble

const JEDI_ROUTER = 19876081725
const JEDI_FACTORY = 1786125

const TOKEN_A = 123
const TOKEN_B = 456
const TOKEN_C = 990
const TOKEN_D = 982

const RESERVE_A_B_0_LOW = 27890
const RESERVE_A_B_1_LOW = 26789

const PAIR_A_B = 12345
const PAIR_A_C = 13345
const PAIR_B_C = 23456
const PAIR_D_C = 43567
const PAIR_D_B = 42567

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    amm_wrapper_contract : felt
):
    Hubble.initializer(amm_wrapper_contract)
    return ()
end

@view
func get_all_routes{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_from : felt, token_to : felt, max_hops : felt
) -> (routes_len : felt, routes : felt*):
    return Hubble.get_all_routes(token_from, token_to, max_hops)
end

@view
func get_all_routes_mock{range_check_ptr}(token_from : felt, token_to : felt, max_hops : felt) -> (
    routes_len : felt, routes : felt*
):
    alloc_locals
    let (local parsed_pairs : Pair*) = alloc()
    let parsed_pairs_len = 5
    assert parsed_pairs[0] = Pair(TOKEN_A, TOKEN_B)
    assert parsed_pairs[1] = Pair(TOKEN_A, TOKEN_C)
    assert parsed_pairs[2] = Pair(TOKEN_B, TOKEN_C)
    assert parsed_pairs[3] = Pair(TOKEN_D, TOKEN_C)
    assert parsed_pairs[4] = Pair(TOKEN_D, TOKEN_B)
    let (graph_len, graph, neighbors) = build_graph(pairs_len=parsed_pairs_len, pairs=parsed_pairs)
    let node_a = graph[0]
    let node_c = graph[2]
    let (saved_paths_len, saved_paths) = init_dfs(graph_len, graph, neighbors, node_a, node_c, 4)
    return (saved_paths_len, saved_paths)
end

@view
func get_best_route{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    amount_in : Uint256, token_from : felt, token_to : felt, max_hops : felt
) -> (route_len : felt, route : Uint256*, amount_out : Uint256):
    return Hubble.get_best_route(amount_in, token_from, token_to, max_hops)
end

# @view
# func get_best_route_mock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     amount_in : Uint256, token_from : felt, token_to : felt, max_hops : felt
# ) -> (route_len : felt, route : felt*):
#     alloc_locals
#     let (local parsed_pairs : Pair*) = alloc()
#     let parsed_pairs_len = 5
#     assert parsed_pairs[0] = Pair(TOKEN_A, TOKEN_B)
#     assert parsed_pairs[1] = Pair(TOKEN_A, TOKEN_C)
#     assert parsed_pairs[2] = Pair(TOKEN_B, TOKEN_C)
#     assert parsed_pairs[3] = Pair(TOKEN_D, TOKEN_C)
#     assert parsed_pairs[4] = Pair(TOKEN_D, TOKEN_B)
#     let (graph_len, graph, neighbors) = build_graph(pairs_len=parsed_pairs_len, pairs=parsed_pairs)
#     let node_a = graph[0]
#     let node_c = graph[2]
#     let (saved_paths_len, saved_paths) = init_dfs(graph_len, graph, neighbors, node_a, node_c, 4)
#     let (best_route : Uint256*) = alloc()
#     let best_route_len = 0

# # all routes[0] is the length of the first route, which starts at index = 1
#     let (best_route_len, best_route, amount_out) = Hubble._get_best_route(
#         amount_in, saved_paths_len, saved_paths, 0, best_route
#     )
#     return (best_route_len, best_route, amount_out)
# end
