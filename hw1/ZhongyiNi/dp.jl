struct Knapsack{T<:Integer}
    W::T
    w::Vector{T}
    v::Vector{T}
end

function dp(kp::Knapsack{T}) where T
    l = length(kp.w)
    vmax = maximum(kp.v)
    wbound = sum(kp.w)+1
    @assert l == length(kp.v)
    Sw = zeros(T,l,l*vmax)
    Sset = Matrix{Vector{Int}}(undef,l,l*vmax)
    for v in 1:l*vmax
        for j in l:(-1):1
            if j == l
                if kp.v[j] == v
                    Sw[j,v] = kp.w[j]
                    Sset[j,v] = [j]
                else
                    Sw[j,v] = wbound
                    Sset[j,v] = Int[]
                end
            else
                if v - kp.v[j] < 0
                    Sw[j,v] = Sw[j+1,v]
                    Sset[j,v] = Sset[j+1,v]
                else
                    if v == kp.v[j]
                        w_temp = kp.w[j]
                        set_temp = [j]
                    else
                        w_temp = kp.w[j] + Sw[j+1,v - kp.v[j]] 
                        set_temp = [j] ∪ Sset[j+1,v - kp.v[j]]
                    end
                    if w_temp <  Sw[j+1,v] 
                        Sw[j,v] = w_temp
                        Sset[j,v] = set_temp
                    else
                        Sw[j,v] = Sw[j+1,v]
                        Sset[j,v] = Sset[j+1,v]
                    end
                end
            end
        end
    end
    W = min(kp.W, wbound-1)
    pos = findfirst(i->Sw[1,i] <= W ,l*vmax:(-1):1)
    if isnothing(pos)
        return zero(T),Int[]
    else
        optv = l*vmax-pos+1
        return Sw[1,optv],Sset[1,optv],optv
    end
end

function rescale_kp(kp::Knapsack{T},K) where T
    return Knapsack(kp.W,kp.w,floor.(T,kp.v ./ K))
end

function _rescale_dp(kp::Knapsack,K)
    kp2 = rescale_kp(kp,K)
    w,set,_ = dp(kp2)
    return w,set,sum(i -> kp.v[i], set)
end

function rescale_dp(kp::Knapsack,ϵ)
    

end