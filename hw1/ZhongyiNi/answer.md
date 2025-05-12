## 9.6
Follow the hints, we can easily get a $O(l^2v_{max})$ algorithm. But $v_{max}$ can be exponentially large with respect to the input size. Therefore, this will not imply P=NP.

## 9.7
Let $S$ denote the optimal set.
$$
    v = \sum_{i \in S} v_i
$$
Let $S'$ denote the optimal set of problem $[v_i/K]$.
$$
v' = \sum_{i \in S'} v_i
$$
We have $v' \leq v$ and
$$
\sum_{i \in S} [\frac{v_i}{K}] \leq \sum_{i \in S'} [\frac{v_i}{K}]
$$
Since
$$
x-1 < [x] \leq x
$$
we have
$$
v/K-|S|=\sum_{i \in S} \frac{v_i}{K} - |S|<\sum_{i \in S} [\frac{v_i}{K}] \leq \sum_{i \in S'} [\frac{v_i}{K}]\leq \sum_{i \in S'} \frac{v_i}{K} = v'/K
$$

Thus,
$$
\frac{v'}{v} > 1 - K|S|/v > 1 - Kl/v
$$

I don't know how to decide $K$ with respect to $\epsilon$.