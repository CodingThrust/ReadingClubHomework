using CSV, DataFrames, CairoMakie
using Statistics

df = CSV.read("data/entropy_density_n100_k3.csv", DataFrame)

fig = Figure()
ax = Axis(fig[1, 1], xlabel="α", ylabel="s")

alphas = unique(df.alpha)
lines!(ax, alphas, [mean(df.s[df.alpha .== alpha]) for alpha in alphas], label="BP entropy density")

xlims!(ax, 0.0, 5.0)
ylims!(ax, 0.0, 0.7)

save("data/entropy_density_n100_k3.png", fig)