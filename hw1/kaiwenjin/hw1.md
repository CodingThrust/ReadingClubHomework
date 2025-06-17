### 9.6
The algorithm and test refer to [algorithm 9.6](9.6.jl)

$n$ objects, $v_{max}$ values and each entry needs $O(n)$ comparisons. So the time complexity is $T = O(n^2v_{max})$.

Why "P≠NP": this $T$ depends on $v_{max}$, which may be much larger than $n$.

### 9.7
The algorithm and test refer to [algorithm 9.7](9.7.jl)

Proof: consider the scaling factor $c = \frac{n}{\epsilon v_{max}}$
$$T = O(n^2v_{max}') = O(\frac{n^3}{\epsilon})$$

And the error is not more than (assuming that $v_{max}\leq V$)
$$1*1/c*n = \epsilon v_{max}\leq \epsilon V$$

QED.

### 9.16
Original form:
$$\max(c^Tx)\\
Ax \leq b\\x \geq 0$$

Standard form $L$:
$$\max(c^Tx)\\
[A,I]\left[\begin{array}{c}x\\s\end{array}\right] = b\\x \geq 0, s \geq 0$$

Without loss of generality, assume that $b \geq 0$. Then we get an LP with a trivial feasible solution whose optimal solution is feasible for $L$:
$$\min e^T s\\
[A,I]\left[\begin{array}{c}x\\s\end{array}\right] = b\\x \geq 0, s \geq 0$$

A feasible solution is $x = 0, s = b$. Its optimal solution must exist and is a feasible solution for $L$.
