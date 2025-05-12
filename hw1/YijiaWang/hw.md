# 9.7 Approximate knapsack packing

**Proof:**
Let $x^{\text{truncated}}$ be the solution to the problem with truncated $\textbf{v}$, and $x$ be the solution to the original problem, (where $x_i=1$ if $i$ is selected, $x_i=0$ if $i$ is not selected). Then we have:

$$
\begin{aligned}
F^{\text{truncated}} &= \sum_{i=1}^{n} x_i^{\text{truncated}} \cdot v_i \\
& \geq k \cdot \sum_{i=1}^{n} x_i^{\text{truncated}} \cdot \lfloor\frac{v_i}{k} \rfloor \\
& \geq k \cdot \sum_{i=1}^{n} x_i \cdot \lfloor\frac{v_i}{k} \rfloor \\
& \geq k \cdot \sum_{i=1}^{n} x_i \cdot (\frac{v_i}{k} - 1) \\
& = \sum_{i=1}^{n} x_i \cdot v_i - \sum_{i=1}^{n} x_i \cdot k \\
& \geq F - l \cdot k 
\end{aligned}
$$

Therefore:

$$
\begin{aligned}
1 \geq \frac{F^{\text{truncated}}}{F} & \geq 1 - \frac{l \cdot k}{F}
\end{aligned}
$$

Which means:

$$
\begin{aligned}
\epsilon \leq \frac{l \cdot k}{F} \leq \frac{l \cdot k}{v_{\text{max}}}
\end{aligned}
$$

Thus, by setting $k = \frac{\epsilon \cdot v_{\text{max}}}{l}$, we can obtain a $(1-\epsilon)$-approximation. The algorithm complexity in this case is $O(l^2 \cdot \frac{1}{k})=O(l^3 \cdot \epsilon^{-1})$.

∎

# 9.16 Jumpstart for LP

**Constructed LP problem：**

$$
\begin{aligned}
\text{Minimize   }  \textbf{1}^T \textbf{z} = \sum_{i=1}^{n} z_i \\
\text{s.t. } \textbf{A} \textbf{x} + \textbf{I} \textbf{z} = \textbf{b}, \\
\textbf{x} \geq 0,  \textbf{z} \geq 0
\end{aligned}
$$
, where $\textbf{I}$ is $m \times m$ identity matrix.

**Trivial feasible solution:**

$$
\textbf{x} = \textbf{0}, \textbf{z} = \textbf{b}
$$

**Optimal solution's feasibility:**

If $\min \sum_{i=1}^{n} z_i = 0$: $\textbf{A} \textbf{x} = \textbf{b} \rightarrow \textbf{x}$ is a feasible solution of the original LP.

If $\min \sum_{i=1}^{n} z_i > 0$: there is no $\textbf{x}$ that satisfies $\textbf{A} \textbf{x}= \textbf{b} \rightarrow$  the original LP is infeasible.






