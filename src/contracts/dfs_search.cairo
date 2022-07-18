from src.data_types.data_types import Node
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.dict import dict_write, dict_update, dict_read

const MAX_FELT = 2 ** 251 - 1
const MAX_HOPS = 4

func init_dict() -> (dict_ptr : DictAccess*):
    alloc_locals

    let (local dict_start) = default_dict_new(default_value=7)
    let dict_end = dict_start
    return (dict_end)
end

func init_dfs(
    graph_len : felt,
    graph : Node*,
    neighbors : felt*,
    start_node : Node,
    destination_node : Node,
    max_hops : felt,
) -> ():
    alloc_locals
    let (dict_ptr : DictAccess*) = init_dict()
    let (my_stack : felt*) = alloc()
    let (saved_paths : felt*) = alloc()
    let (current_path : felt*) = alloc()
    current_path[0] = start_node.index

    DFS_rec{dict_ptr=dict_ptr}(
        graph_len,
        graph,
        neighbors,
        start_node,
        destination_node,
        4,
        1,
        current_path,
        0,
        saved_paths,
    )
    return ()
end

func DFS_rec{dict_ptr : DictAccess*}(
    graph_len : felt,
    graph : Node*,
    neighbors : felt*,
    current_node : Node,
    destination_node : Node,
    max_hops : felt,
    current_path_len : felt,
    current_path : felt*,
    saved_paths_len : felt,
    saved_paths : felt*,
) -> (all_paths_len : felt, all_paths : Node**):
    dict_write{dict_ptr=dict_ptr}(key=current_node.index, new_value=1)
    # let node_successors_len = neighbors[current_node.index]
    # let node_successors = current_node.neighbor_nodes
    visit_successors{dict_ptr=dict_ptr}(
        graph_len,
        graph,
        neighbors,
        current_node,
        destination_node,
        max_hops,
        neighbors[current_node.index],
        current_path_len,
        current_path,
        saved_paths_len,
        saved_paths
    )
    return ()
end

func visit_successors{dict_ptr : DictAccess*}(
    graph_len : felt,
    graph : felt*,
    neighbors : felt*,
    current_node : Node,
    destination_node : Node,
    remaining_hops : felt,
    successors_len : felt,
    current_path_len : felt,
    current_path : felt*,
    saved_paths_len:felt,
    saved_paths:felt*
):
    alloc_locals
    if successors_len == 0:
        return ()
    end

    let successor = current_node[successors_len - 1]
    let (successor_index) = successor.index
    let (successor_visit_state) = dict_read{dict_ptr=dict_ptr}(key=successor_index)

    local saved_paths_len
    if successor_visit_state == 0:
        current_path[current_path_len] = successor_index
        DFS_rec(
            graph_len=graph_len,
            graph=graph,
            neighbors=neighbors,
            current_node=successor,
            destination_node=destination_node,
            max_hops = remaining_hops - 1,
            neighbors[successor.index],
            current_path_len + 1,
            current_path,
            saved_paths_len,
            saved_paths
        )
    end

    return visit_successors(
        graph_len=graph_len,
        graph=graph,
        neighbors=neighbors,
        current_node=current_node,
        destination_node=destination_node,
        remaining_hops = remaining_hops,
        successors_len = successors_len - 1,
        current_path_len=current_path_len,
        current_path=current_path,
        saved_paths_len=saved_paths_len,
        saved_paths=saved_paths
    )

    return ()
end
