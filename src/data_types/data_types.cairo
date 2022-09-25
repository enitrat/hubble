// A node has an identifier (token address) and a list of neighbor nodes
struct Node {
    index: felt,
    identifier: felt,
    neighbor_nodes: Node*,
}

// A pair containing 2 token identified by their address
struct Pair {
    token_0: felt,
    token_1: felt,
}
