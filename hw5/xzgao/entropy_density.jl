using GenericMessagePassing
using CSV, DataFrames

function main(n, k, ms, n_samples)
    df = CSV.write("data/entropy_density_n$(n)_k$(k).csv", DataFrame(alpha=Float64[], i = Int[], s=Float64[]))
    for m in ms
        for i in 1:n_samples
            k_sat = random_k_sat(n, k, m)
            tn = tn_model(k_sat)
            S = entropy_bp(tn.code, tn.tensors, BPConfig())
            CSV.write(df, DataFrame(alpha=m/n, i = i, s=S/n), append=true)
        end
    end
end

main(100, 3, 10:10:450, 10)