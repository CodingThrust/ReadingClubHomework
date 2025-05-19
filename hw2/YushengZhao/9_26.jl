# according to hint, when formula is satisfied, we have 1/2 - y_0/3 <= y_i <= 1/2 +y_0
# and to minimize f(x) need to maximize (y_i-1/2)^2, which is y_i at its upper bound and gives (y_i - 1/2)^2 = y_0^2, that gives lower bound of f(x) = -1/2y_0^2
# on the other hand if the formula is not satisfied, the bound of at least one y_i is 1/2 - y_0/3 <= y_i <= 1/2 +y_0, and the min f(x) is  num unsat * y_0^2 - y_0^2/9 + sum_(sat clause) (y_0^2 - y_0^2) - y_0^2/2 + num_unsat * y_0^ / 2*n*9 which is at least 7/18 y_0^2 

# using hint, if formula is satisfied, y^* cannot be local minimum because can slide over y_0 axis a little bit, epsilon, and get lower. this is in the neighborhood of y^* because y_i' 's difference from y_i = 1/2 is bounded by the epsilon. And f(x)'s min is -y_0^2/2 when formula is satisfied. This min is smaller than f(y^*) = 0. 

# so x_i means is y_i >= 1/2 - y_0/3 ?