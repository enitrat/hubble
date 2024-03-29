%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256, uint256_lt

from cairo_graphs.graph.graph import GraphMethods
from cairo_graphs.graph.dijkstra import Dijkstra
from cairo_graphs.data_types.data_types import Edge, Vertex, Graph
from cairo_graphs.graph.dfs_all_paths import init_dfs

from src.data_types.data_types import Pair, Node
from src.interfaces.i_amm_wrapper import IAmmWrapper

@storage_var
func Hubble_amm_wrapper_address() -> (address: felt) {
}

namespace Hubble {
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        amm_wrapper_contract: felt
    ) {
        Hubble_amm_wrapper_address.write(amm_wrapper_contract);
        return ();
    }

    func get_all_pairs{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        pairs_len: felt, pairs: Edge*
    ) {
        alloc_locals;
        let (amm_wrapper_address) = Hubble_amm_wrapper_address.read();
        let (all_pairs_len, all_pairs: felt*) = IAmmWrapper.get_all_pairs(amm_wrapper_address);
        let (local parsed_pairs: Edge*) = alloc();
        let (parsed_pairs_len) = parse_all_pairs(all_pairs_len, all_pairs, parsed_pairs, 0);
        return (parsed_pairs_len, parsed_pairs);
    }

    func get_minimal_route{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_from: felt, token_to: felt
    ) -> (path_len: felt, path: felt*, distance: felt) {
        alloc_locals;
        let (amm_wrapper_address) = Hubble_amm_wrapper_address.read();

        let (all_pairs_len, all_pairs: felt*) = IAmmWrapper.get_all_pairs(amm_wrapper_address);
        let (local parsed_pairs: Edge*) = alloc();
        let (parsed_pairs_len) = parse_all_pairs(all_pairs_len, all_pairs, parsed_pairs, 0);

        let graph = GraphMethods.build_undirected_graph_from_edges(parsed_pairs_len, parsed_pairs);

        let (path_len, path, distance) = Dijkstra.shortest_path(graph, token_from, token_to);
        return (path_len, path, distance);
    }

    func get_all_routes{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_from: felt, token_to: felt, max_hops: felt
    ) -> (routes_len: felt, routes: felt*) {
        alloc_locals;
        let (amm_wrapper_address) = Hubble_amm_wrapper_address.read();

        let (all_pairs_len, all_pairs: felt*) = IAmmWrapper.get_all_pairs(amm_wrapper_address);
        let (local parsed_pairs: Edge*) = alloc();
        let (parsed_pairs_len) = parse_all_pairs(all_pairs_len, all_pairs, parsed_pairs, 0);

        let graph = GraphMethods.build_undirected_graph_from_edges(parsed_pairs_len, parsed_pairs);

        let (saved_paths_len, saved_paths) = init_dfs(graph, token_from, token_to, max_hops);
        return (saved_paths_len, saved_paths);
    }

    func get_best_route{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        amount_in: Uint256, token_from: felt, token_to: felt, max_hops: felt
    ) -> (route_len: felt, route: felt*, amount_out: Uint256) {
        let (amm_wrapper_address) = Hubble_amm_wrapper_address.read();
        let (all_routes_len, all_routes) = get_all_routes(token_from, token_to, max_hops);

        let (best_route: felt*) = alloc();
        let current_best_route_len = 0;
        let current_best_route = best_route;
        let current_best_amount = Uint256(0, 0);
        with amount_in, all_routes_len, all_routes, current_best_route_len, current_best_route, current_best_amount {
            let (best_route_len, best_route, amount_out) = _get_best_route(0);
        }
        return (best_route_len, best_route, amount_out);
    }
}

func parse_all_pairs{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    pairs_addresses_len: felt, pairs_addresses: felt*, parsed_pairs: Edge*, parsed_pairs_len: felt
) -> (parsed_pairs_len: felt) {
    let (amm_wrapper_address) = Hubble_amm_wrapper_address.read();
    if (pairs_addresses_len == 0) {
        return (parsed_pairs_len,);
    }
    let (token_0) = IAmmWrapper.get_pair_token0(amm_wrapper_address, [pairs_addresses]);
    let (token_1) = IAmmWrapper.get_pair_token1(amm_wrapper_address, [pairs_addresses]);
    assert [parsed_pairs] = Edge(token_0, token_1, 1);
    return parse_all_pairs(
        pairs_addresses_len - 1, pairs_addresses + 1, parsed_pairs + Edge.SIZE, parsed_pairs_len + 1
    );
}

func _get_best_route{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    amount_in: Uint256,
    all_routes_len: felt,
    all_routes: felt*,
    current_best_route_len: felt,
    current_best_route: felt*,
    current_best_amount: Uint256,
}(index: felt) -> (best_route_len: felt, best_route: felt*, best_amount_out: Uint256) {
    alloc_locals;

    if (index == all_routes_len) {
        return (current_best_route_len, current_best_route, current_best_amount);
    }

    // evaluate current route
    let route_to_eval_len = all_routes[index];  // first element of the route is its length
    let route_to_eval = all_routes + index + 1;  // route_to_eval is a pointer to the first element of the path sub-array
    let next_route_index = index + route_to_eval_len + 1;  // index of the next route length

    let (local amounts_len, local amounts, output_tokens) = evaluate_current_route(
        amount_in, route_to_eval_len, route_to_eval
    );
    let (is_new_route_better) = uint256_lt(current_best_amount, output_tokens);
    if (is_new_route_better == 1) {
        // update best route
        return _get_best_route{
            current_best_route_len=route_to_eval_len,
            current_best_route=route_to_eval,
            current_best_amount=output_tokens,
        }(next_route_index);
    }
    return _get_best_route(next_route_index);
}

func evaluate_current_route{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount_in: Uint256, route_len: felt, route: felt*
) -> (amounts_len: felt, amounts: Uint256*, output_tokens: Uint256) {
    alloc_locals;
    let (amm_wrapper_address) = Hubble_amm_wrapper_address.read();
    let (amounts_len, amounts) = IAmmWrapper.get_amounts_out(
        amm_wrapper_address, amount_in, route_len, route
    );
    let output_tokens = amounts[amounts_len - 1];
    return (amounts_len, amounts, output_tokens);
}
