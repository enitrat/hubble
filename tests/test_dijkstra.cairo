%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.uint256 import Uint256, uint256_lt
from starkware.cairo.common.alloc import alloc

from cairo_graphs.graph.graph import Graph
from cairo_graphs.graph.dijkstra import Dijkstra
from cairo_graphs.data_types.data_types import Edge, Vertex

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

const PAIR_A_B = 12345
const PAIR_A_C = 13345
const PAIR_B_C = 23456
const PAIR_D_C = 43567
const PAIR_D_B = 42567

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

    # see details in test_dfs.cairo
    let (local parsed_pairs : Edge*) = alloc()
    # let (parsed_pairs_len) = parse_all_pairs(all_pairs_len, all_pairs, parsed_pairs, 0)
    tempvar parsed_pairs_len = 5
    assert parsed_pairs[0] = Edge(TOKEN_A, TOKEN_B, 1)
    assert parsed_pairs[1] = Edge(TOKEN_A, TOKEN_C, 1)
    assert parsed_pairs[2] = Edge(TOKEN_B, TOKEN_C, 1)
    assert parsed_pairs[3] = Edge(TOKEN_D, TOKEN_C, 1)
    assert parsed_pairs[4] = Edge(TOKEN_D, TOKEN_B, 1)

    let (graph_len, graph, adj_vertices_count) = Graph.build_undirected_graph_from_edges(
        parsed_pairs_len, parsed_pairs
    )

    let (path_len, path, distance) = Dijkstra.shortest_path(
        graph_len, graph, adj_vertices_count, TOKEN_A, TOKEN_D
    )

    %{
        print(ids.path_len)
        for i in range(ids.path_len):
            print(memory[ids.path+i])
    %}

    # let amount_in = Uint256(1000,0)

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

# func test_get_best_route{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
#     alloc_locals
#     before_each()
#     %{ stop_mock = mock_call(ids.JEDI_FACTORY,"get_all_pairs", [5,ids.PAIR_A_B, ids.PAIR_A_C,ids.PAIR_B_C,ids.PAIR_D_C,ids.PAIR_D_B]) %}
#     let (all_pairs_len, all_pairs) = AmmWrapper.get_all_pairs()
#     %{ stop_mock() %}
#     assert all_pairs_len = 5
#     assert all_pairs[0] = PAIR_A_B
#     assert all_pairs[1] = PAIR_A_C
#     assert all_pairs[2] = PAIR_B_C
#     assert all_pairs[3] = PAIR_D_C
#     assert all_pairs[4] = PAIR_D_B

# %{
#         stop_mock_ab_0 = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A])
#         stop_mock_ab_1 = mock_call(ids.PAIR_A_B,"token1", [ids.TOKEN_B])
#         stop_mock_ac_0 = mock_call(ids.PAIR_A_C,"token0", [ids.TOKEN_A])
#         stop_mock_ac_1 = mock_call(ids.PAIR_A_C,"token1", [ids.TOKEN_C])
#         stop_mock_bc_0 = mock_call(ids.PAIR_B_C,"token0", [ids.TOKEN_B])
#         stop_mock_bc_1 = mock_call(ids.PAIR_B_C,"token1", [ids.TOKEN_C])
#         stop_mock_dc_0 = mock_call(ids.PAIR_D_C,"token0", [ids.TOKEN_D])
#         stop_mock_dc_1 = mock_call(ids.PAIR_D_C,"token1", [ids.TOKEN_C])
#         stop_mock_db_0 = mock_call(ids.PAIR_D_B,"token0", [ids.TOKEN_D])
#         stop_mock_db_1 = mock_call(ids.PAIR_D_B,"token1", [ids.TOKEN_B])
#     %}
#     return ()
# end
