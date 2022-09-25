%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.uint256 import Uint256

from src.contracts.hubble_library import Hubble, _get_best_route

@external
func test_get_best_route{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let amount_in = Uint256(10, 0);
    let all_routes_len = 11;
    local all_routes: felt* = new (3, 2087021424722619777119509474943472645767659996348769578120564519014510906823, 532397201989021057129723162801779565748209832652056542886951046986376101206, 159707947995249021625440365289670166666892266109381225273086299925265990694, 3, 2087021424722619777119509474943472645767659996348769578120564519014510906823, 1767481910113252210994791615708990276342505294349567333924577048691453030089, 159707947995249021625440365289670166666892266109381225273086299925265990694, 2, 2087021424722619777119509474943472645767659996348769578120564519014510906823, 159707947995249021625440365289670166666892266109381225273086299925265990694);

    let (best_route: felt*) = alloc();
    // all routes[0] is the length of the first route, which starts at index = 1
    // TODO
    let current_best_route_len = 0;
    let current_best_route = best_route;
    let current_best_amount = Uint256(0, 0);
    let (this) = get_contract_address();
    %{ stop_mock = mock_call(0, "get_amounts_out", [2,10,0,100,0]) %}
    with amount_in, all_routes_len, all_routes, current_best_route_len, current_best_route, current_best_amount {
        let (best_route_len, best_route, amount_out) = _get_best_route(0);
    }

    // We expect the best route to be the first in the array, because uint256_lt will always return false except for the first route which is compared to an output of 0
    %{
        print(ids.best_route_len)
        for i in range(ids.best_route_len):
            print(memory[ids.best_route+i])
        print(ids.amount_out.low)
    %}

    assert best_route_len = 3;
    assert best_route[0] = 2087021424722619777119509474943472645767659996348769578120564519014510906823;
    assert best_route[1] = 532397201989021057129723162801779565748209832652056542886951046986376101206;
    assert best_route[2] = 159707947995249021625440365289670166666892266109381225273086299925265990694;
    return ();
}
