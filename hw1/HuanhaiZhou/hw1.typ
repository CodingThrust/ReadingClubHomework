#show smallcaps: set text(font: "linux libertine")

#let bA = $bold(A)$
#let bb = $bold(b)$
#let bc = $bold(c)$
#let bs = $bold(s)$
#let bx = $bold(x)$

#let setmin = $#smallcaps[Setmin]$
#let knapsack = $#smallcaps[Knapsack]$
#let approximateknapsack = $#smallcaps[Approximate-Knapsack]$

== Problem 9.6
Let $setmin(A,B)$ be a function with two input sets $A$ and $B$ and output $
setmin(A,B) = cases(
  A quad "if" abs(A) <= abs(B) "and" A != emptyset,
  B quad "otherwise"
)
$
where $abs(dot)$ denotes the cardinality of a set.

We could write down the following state transition equations:
$
S_(i, v) = cases(S_(i-1, v) &quad "if" v < v_i,
{i} &quad "if" v = v_i,
setmin(S_(i-1, v), S_(i-1, v-v_i) union {i}) &quad "if" v > v_i
) 
$
with initial conditions $
S_(1, v) = cases({1} &quad "if" v = v_1,
emptyset &quad "otherwise"
)
$

There are $l times l v_max = l^2 v_max$ such $S_(i,v)$ in all and for each one we need constant overhead to calulcate. So the overall time complexity is $O(l^2 v_max)$.

One need $log(v_max)$ bits to record the input data, hence the complexity is exponential in the input scale.

== Problem 9.7
Let $v_i^prime = floor(v_i\/K)$ be the scaled and truncated value. Note that $K omega_i <= v_i < (K+1) omega_i$, which means that picking up an object with value $v_i$ introduces error $epsilon < K$ in the overall value.

Let $bold(sigma)^star in{0,1}^l$ be the optimal solution to the original $knapsack$ and $v_"opt"=sum sigma_i v_i$ be the associated max value.

We here construct an solution to $approximateknapsack$ and require it to be an $(1-epsilon)$-approximation to $v_"opt"$.

Let $abs(bold(sigma)^star)$ be the number of $1$'s in $bold(sigma)$ and $v_"trunc" equiv max_(w_i <= W) v_i. $

$
"total error" <= abs(sigma^star)K <= l K <= epsilon v_min <= epsilon v_"opt"
$

For the third inequality to hold, one must have $
  K <= (epsilon v_"trunc")/l
$ and we choose $
  K = (epsilon v_"trunc")/l
$ where $v_"trunc" equiv max_(w_i <= W) v_i$.

== Problem 9.16

To the linear program $
max_bx (bc^T bx) quad "subject to" quad bA bx=bb "and" bx >= bold(0),
$
we associate an auxillary one $
min_(bx,bs) sum s_i quad "subject to" quad bA bx+bs=bb, bx>=bold(0) "and" bs>= bold(0)
$

Choose $bx=bold(0), bs=bb$ as the initial solution and try solving the auxillary program.

If the original program has a feasible solution that $bA bx=bb$ and $bx >= bold(0)$, the auxillary one should reach an optimal solution where $bs=bold(0), bA bx=bb$ and $bx >= bold(0)$. That is exactly an feasible solution of the original program.
