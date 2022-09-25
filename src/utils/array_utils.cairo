from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy

namespace Stack {
    // Removes the last element from an array and returns it
    func pop(stack_len: felt, stack: felt*) -> (
        new_stack_len: felt, new_stack: felt*, last_elem: felt
    ) {
        alloc_locals;

        let (local res: felt*) = alloc();
        memcpy(res, stack, stack_len - 1);
        return (stack_len - 1, res, stack[stack_len - 1]);
    }

    func put(stack_len: felt, stack: felt*, element: felt) -> (
        new_stack_len: felt, new_stack: felt*
    ) {
        alloc_locals;

        assert stack[stack_len] = element;
        let new_stack_len = stack_len + 1;
        return (new_stack_len, stack);
    }
}
