# floor division of K rounds some weights to 0, such weights maybe added in correctly to solution
# very roughly
# ϵ ∝ Σ_i floor(v_i / K)
# ϵ ∝ floor(v_i / K) * l
# K ∝ l/ϵ
# but also need to supress v_max to be small, let 
# K = v_max * l / ϵ
