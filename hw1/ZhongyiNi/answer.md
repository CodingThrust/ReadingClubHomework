Let $S$ denote the optimal set.
$$
    v = \sum_{i \in S} v_i
$$
$$
v' = \sum_{i \in S'} v_i
$$
$v' \leq v$
$$
\sum_{i \in S} [\frac{v_i}{K}] \leq \sum_{i \in S'} [\frac{v_i}{K}]
$$
$$
v/K-|S|=\sum_{i \in S} \frac{v_i}{K} - |S|<\sum_{i \in S} [\frac{v_i}{K}] \leq \sum_{i \in S'} [\frac{v_i}{K}]\leq \sum_{i \in S'} \frac{v_i}{K} = v'/K
$$
$$
x-1 < [x] \leq x
$$

$$
\frac{v'}{v} > 1 - K|S|/v > 1 - Kl/v
$$

$$
vmin < v/|S| < vmax
$$
for i in 1:n
K=vmax/2^i