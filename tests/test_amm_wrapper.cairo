%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address
from src.contracts.amm_wrapper_library import AmmWrapper
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc

const JEDI_ROUTER = 19876081725;
const JEDI_FACTORY = 1786125;

const TOKEN_A = 123;
const TOKEN_B = 456;
const TOKEN_C = 990;
const TOKEN_D = 982;

const RESERVE_A_B_0_LOW = 27890;
const RESERVE_A_B_1_LOW = 26789;

const PAIR_A_B = 90174089;
const PAIR_A_C = 90182194;
const PAIR_A_D = 90712441;

// TODO remove these useless tests

func before_each{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (contract_address) = get_contract_address();

    // Store values in contract storage
    %{ store(ids.contract_address, "AmmWrapper_jediswap_router", [ids.JEDI_ROUTER]) %}
    %{ store(ids.contract_address, "AmmWrapper_jediswap_factory", [ids.JEDI_FACTORY]) %}
    return ();
}

@external
func test_get_pair{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    before_each();
    %{ stop_mock = mock_call(ids.JEDI_FACTORY,"get_pair", [ids.PAIR_A_B]) %}
    let (pair_a_b) = AmmWrapper.get_pair(TOKEN_A, TOKEN_B);
    %{ stop_mock() %}
    assert pair_a_b = PAIR_A_B;
    return ();
}

@external
func test_get_all_pairs{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    before_each();
    %{ stop_mock = mock_call(ids.JEDI_FACTORY,"get_all_pairs", [3,ids.PAIR_A_B,ids.PAIR_A_C,ids.PAIR_A_D]) %}
    let (all_pairs_len, all_pairs) = AmmWrapper.get_all_pairs();
    %{ stop_mock() %}
    assert all_pairs_len = 3;
    assert all_pairs[0] = PAIR_A_B;
    assert all_pairs[1] = PAIR_A_C;
    assert all_pairs[2] = PAIR_A_D;
    return ();
}

@external
func test_get_token_0{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    before_each();
    %{ stop_mock = mock_call(ids.PAIR_A_B,"token0", [ids.TOKEN_A]) %}
    let (token0) = AmmWrapper.get_pair_token0(PAIR_A_B);
    %{ stop_mock() %}
    assert token0 = TOKEN_A;
    return ();
}

@external
func test_get_token_1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    before_each();
    %{ stop_mock = mock_call(ids.PAIR_A_B,"token1", [ids.TOKEN_B]) %}
    let (token1) = AmmWrapper.get_pair_token1(PAIR_A_B);
    %{ stop_mock() %}
    assert token1 = TOKEN_B;
    return ();
}

@external
func test_get_reserves{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    before_each();
    %{ stop_mock = mock_call(ids.PAIR_A_B,"get_reserves", [ids.RESERVE_A_B_0_LOW, 0, ids.RESERVE_A_B_1_LOW, 0, 1]) %}
    let res = AmmWrapper.get_pair_reserves(PAIR_A_B);
    %{ stop_mock() %}
    assert res[0] = Uint256(RESERVE_A_B_0_LOW, 0);
    assert res[1] = Uint256(RESERVE_A_B_1_LOW, 0);
    return ();
}
