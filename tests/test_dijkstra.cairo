%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.uint256 import Uint256, uint256_lt
from starkware.cairo.common.alloc import alloc

from src.interfaces.i_router import IRouter

from cairo_graphs.graph.graph import Graph
from cairo_graphs.graph.dijkstra import Dijkstra
from cairo_graphs.data_types.data_types import Edge, Vertex
from cairo_graphs.graph.dfs_all_paths import init_dfs

from src.contracts.amm_wrapper_library import AmmWrapper
from src.contracts.hubble_library import Hubble, parse_all_pairs

const JEDI_ROUTER = 19876081725
const JEDI_FACTORY = 1786125

const TOKEN_A = 123
const TOKEN_B = 234
const TOKEN_C = 345
const TOKEN_D = 456

const RESERVE_A_B_0_LOW = 27890
const RESERVE_A_B_1_LOW = 26789

# Pair addresses
const PAIR_A_B = 12345
const PAIR_A_C = 13345
const PAIR_B_C = 23456
const PAIR_D_C = 43567
const PAIR_D_B = 42567

const MAX_HOPS = 4

func before_each{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (contract_address) = get_contract_address()

    # Store values in contract storage
    %{ store(ids.contract_address, "AmmWrapper_jediswap_router", [ids.JEDI_ROUTER]) %}
    %{ store(ids.contract_address, "AmmWrapper_jediswap_factory", [ids.JEDI_FACTORY]) %}
    return ()
end

@external
func test_e2e{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    before_each()
    %{ stop_mock = mock_call(ids.JEDI_FACTORY,"get_all_pairs", [4,ids.PAIR_A_B, ids.PAIR_A_C,ids.PAIR_B_C,ids.PAIR_D_C]) %}
    let (all_pairs_len, all_pairs) = AmmWrapper.get_all_pairs()
    %{ stop_mock() %}
    assert all_pairs_len = 4
    assert all_pairs[0] = PAIR_A_B
    assert all_pairs[1] = PAIR_A_C
    assert all_pairs[2] = PAIR_B_C
    assert all_pairs[3] = PAIR_D_C

    %{
        stop_mock_ab_0 = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
        stop_mock_ab_1 = mock_call(ids.PAIR_A_B,"token1", [ids.TOKEN_B])
        stop_mock_ac_0 = mock_call(ids.PAIR_A_C,"token0", [ids.TOKEN_A])
        stop_mock_ac_1 = mock_call(ids.PAIR_A_C,"token1", [ids.TOKEN_C])
        stop_mock_bc_0 = mock_call(ids.PAIR_B_C,"token0", [ids.TOKEN_B])
        stop_mock_bc_1 = mock_call(ids.PAIR_B_C,"token1", [ids.TOKEN_C])
        stop_mock_dc_0 = mock_call(ids.PAIR_D_C,"token0", [ids.TOKEN_D])
        stop_mock_dc_1 = mock_call(ids.PAIR_D_C,"token1", [ids.TOKEN_C])
    %}

    # see details in test_dfs.cairo
    let (local parsed_pairs : Edge*) = alloc()
    # let (parsed_pairs_len) = parse_all_pairs(all_pairs_len, all_pairs, parsed_pairs, 0)
    tempvar parsed_pairs_len = 4
    assert parsed_pairs[0] = Edge(TOKEN_A, TOKEN_B, 1)
    assert parsed_pairs[1] = Edge(TOKEN_A, TOKEN_C, 1)
    assert parsed_pairs[2] = Edge(TOKEN_B, TOKEN_C, 1)
    assert parsed_pairs[3] = Edge(TOKEN_D, TOKEN_C, 1)

    let (graph_len, graph, adj_vertices_count) = Graph.build_undirected_graph_from_edges(
        parsed_pairs_len, parsed_pairs
    )

    let (all_routes : felt*) = alloc()
    let (all_routes_len, all_routes) = init_dfs(
        graph_len, graph, adj_vertices_count, TOKEN_A, TOKEN_D, MAX_HOPS
    )

    assert all_routes_len = 9

    # Allocate an array.
    let (route_1) = alloc()
    let (route_2) = alloc()

    # Populate some values in the array.
    # assert [route_1] = TOKEN_A
    # assert [route_1 + 1] = TOKEN_B
    # assert [route_1 + 2] = TOKEN_C
    # assert [route_1 + 3] = TOKEN_D

    # assert [route_2] = TOKEN_A
    # assert [route_2 + 2] = TOKEN_C
    # assert [route_2 + 3] = TOKEN_D

    # assert all_routes = route_1
    # assert all_routes[1] = route_2

    %{
        print(ids.all_routes_len)
        for i in range(ids.all_routes_len):
            print(memory[ids.all_routes+i])
    %}

    let amount_in = Uint256(1000, 0)

    let path_1 = all_routes + 1
    let path_2 = all_routes + 4

    let (local amounts_out_1 : Uint256*) = alloc()
    assert amounts_out_1[0] = Uint256(25, 0)
    let (local amounts_out_2 : Uint256*) = alloc()

    %{ stop_mock = mock_call(ids.JEDI_ROUTER,"get_amounts_out", [1,ids.amounts_out_1.low, ids.amounts_out_1.high]) %}
    let (amounts_len : felt, amounts : Uint256*) = AmmWrapper.get_amounts_out(amount_in, 3, path_1)
    %{ stop_mock() %}

    # %{ stop_mock = mock_call(ids.JEDI_ROUTER,"get_amounts_out", [2,ids.amount_out_2]) %}
    # let (amounts_len : felt, amounts : Uint256*) = AmmWrapper.get_amounts_out(amount_in, 4, path_2)
    # %{ stop_mock() %}

    # let (best_route : Uint256*) = alloc()
    # let (best_route_len, best_route, amount_out) = Hubble._get_best_route(
    #     amount_in,
    #     all_routes_len,
    #     all_routes,
    #     current_best_route_len=0,
    #     current_best_route=best_route,
    # )

    # %{
    #     print(amount_out)
    #     print(best_route_len)
    #     for i in range(best_route_len):
    #         print(memory[best_route+i])
    # %}

    # %{
    #     stop_mock_ab_out = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
    #     stop_mock_ac_out = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
    #     stop_mock_bc_out = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
    #     stop_mock_dc_out = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
    #     stop_mock_db_out= mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
    # %}

    # now that we have the paths -> we need to run IJediswapRouter.get_amounts_out with each path :)

    return ()
end

func test_get_best_route{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    before_each()
    %{ stop_mock = mock_call(ids.JEDI_FACTORY,"get_all_pairs", [5,ids.PAIR_A_B, ids.PAIR_A_C,ids.PAIR_B_C,ids.PAIR_D_C,ids.PAIR_D_B]) %}
    let (all_pairs_len, all_pairs) = AmmWrapper.get_all_pairs()
    %{ stop_mock() %}
    assert all_pairs_len = 5
    assert all_pairs[0] = PAIR_A_B
    assert all_pairs[1] = PAIR_A_C
    assert all_pairs[2] = PAIR_B_C
    assert all_pairs[3] = PAIR_D_C
    assert all_pairs[4] = PAIR_D_B

    %{
        stop_mock_ab_0 = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
        stop_mock_ab_1 = mock_call(ids.PAIR_A_B,"token1", [ids.TOKEN_B])
        stop_mock_ac_0 = mock_call(ids.PAIR_A_C,"token0", [ids.TOKEN_A])
        stop_mock_ac_1 = mock_call(ids.PAIR_A_C,"token1", [ids.TOKEN_C])
        stop_mock_bc_0 = mock_call(ids.PAIR_B_C,"token0", [ids.TOKEN_B])
        stop_mock_bc_1 = mock_call(ids.PAIR_B_C,"token1", [ids.TOKEN_C])
        stop_mock_dc_0 = mock_call(ids.PAIR_D_C,"token0", [ids.TOKEN_D])
        stop_mock_dc_1 = mock_call(ids.PAIR_D_C,"token1", [ids.TOKEN_C])
        stop_mock_db_0 = mock_call(ids.PAIR_D_B,"token0", [ids.TOKEN_D])
        stop_mock_db_1 = mock_call(ids.PAIR_D_B,"token1", [ids.TOKEN_B])
    %}
    return ()
end
