# Task 9.6

In `knapsack.jl`, `knapsack_dp` realizes an exact algorithom with the complexity $O(lV)=O(l^2 v_\text{max})$, where $V=lv_\text{max}$ is the upper bound of the maximum value.

This doesn't mean $\mathbf{P}=\mathbf{NP}$. Because although the algorithm runs in polynomial time with respect to the numeric values of the inputs (namely, the number of items $l$ and the maximum item value $v_{\text{max}}$), it is not polynomial in the size of the input, which is measured in **bits**. And this algorithm is exponential in the bit size of the input.


# Task 9.7

In this task,we need to design a FPTAS version of the algorithm in Task 9.6 with approximation ratio $1-\epsilon$ and time complexity $\text{poly}(l, \frac{1}{\epsilon})$.

The main idea is to scale down the item values by a factor of $K$, i.e. $v'_i = \lfloor v_i / K \rfloor$.

However, in this process, $K v'_i \leq v_i < K (v'_i + 1)$, so for the whole problem, the maximum value loss is $lK$.

Considering the scaled-down problem, we apply the exact dynamic programming algorithm from Task 9.6 to the instance with scaled values $v'_i$, and denote the result of this algorithm as $\text{APX}$. Then we have 

$\text{APX} \ge \text{OPT} - lK$,

where $\text{OPT}$ is the optimal value of the original problem.

To ensure the approximation ratio is $1-\epsilon$, i.e.

$\text{APX} \ge (1-\epsilon) \text{OPT}$,

we can simply let 

$\text{OPT}-l K \geq (1-\epsilon) \text{OPT}$,

which is equivalent to

$l K \leq \epsilon \text{OPT}$.

Since the optimal solution must at least match the best item that fits into the knapsack, we have $\text{OPT} \ge v^*$, where $v^* = \max \{ v_i \mid w_i \le W \}$. We can simply assume for all $i$, $w_i \le W$ (otherwise, we can remove it from the problem).

Therefore, we have the sufficient condition

$l K \leq \epsilon v_\text{max}$.

Thus, for any $\epsilon > 0$, by choosing $K = \frac{\epsilon v_\text{max}}{l}$, we can ensure the approximation ratio is $1-\epsilon$.

For the time complexity, the dynamic programming algorithm is still $O(lV')=O(l^2 v'_\text{max}) = O(l^3 \frac{1}{\epsilon})$, which is polynomial of $l$ and $\frac{1}{\epsilon}$.










