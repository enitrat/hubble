# Hubble

Hubble is an onchain solver aggregating different DEXs in order to provide the best swap route. It builds a graph with edges representing tokens and vertices representing the existent pairs. When all possible routes are indentified, the propagates getAmountOut() calls through all routes in order to find the maximum output one. In new versions swap split will be implemented to be able to split the order. Next, other DEXs will be added (only JediSwap is supported currently).

### Installation
```
yarn && yarn dev
```
### Testing
```
protostar test
```
