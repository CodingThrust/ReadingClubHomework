### 9.6
The algorithm and test refers to [algorithm 9.6](9.6.jl)

$n$ objects, $v_{max}$ values and each entry needs $O(n)$ comparisons. So the time complexity is $T = O(n^2v_{max})$.

Why not "P=NP": this $T$ depends on $v_{max}$, which may be much larger than $n$.

### 9.7
The algorithm and test refers to [algorithm 9.7](9.7.jl)

Proof: consider the scaling factor $c = \frac{n}{\epsilon v_{max}}$
$$T = O(n^2v_{max}') = O(\frac{n^3}{\epsilon})$$

And the error is not more than (assume that $v_{max}\leq V$)
$$1*1/c*n = \epsilon v_{max}\leq \epsilon V$$

QED.

### 9.16
original form:
$$\max(c^Tx)\\
Ax \leq b\\x \geq 0$$

standard form:
$$\max(c^Tx)\\
[A,I]\left[\begin{array}{c}x\\s\end{array}\right] = b\\x \geq 0, s \geq 0$$