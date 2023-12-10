# PREFIX ----------------------------------------------------------------------
using UrlDownload, DataFrames, Chain, CSV, Plots

tidytuesday_url = "https://raw.githubusercontent.com/rfordatascience/" * 
                  "tidytuesday/master/data"

dfs = map(urldownload,
           [tidytuesday_url * "/2023/2023-08-08/episodes.csv", 
            tidytuesday_url * "/2023/2023-08-08/sauces.csv", 
            tidytuesday_url * "/2023/2023-08-08/seasons.csv"])

dfs = map(DataFrame, dfs)

# List who did not finished the spiciesed sauce -------------------------------
hottest_sauces = sort(dfs[2][:, :scoville], rev = true)[1:15]

@chain dfs[1] begin
    leftjoin(dfs[2], on = :season)
    filter(:scoville => x -> x in hottest_sauces, _)
    filter(:finished => ==(false), _)
end

# Plot the spiciness level across seasons -------------------------------------
colours = cgrad(:roma, 21, categorical = true)

#= This code does not work
plot(dfs[2].sauce_number, 
     dfs[2].scoville,
     group = dfs[2].season,
     color = colours,
     legend = false)
scatter!(dfs[2].sauce_number, 
         dfs[2].scoville,
         group = dfs[2].season,
         pointcolor = colours)
yaxis!(:log10)
=#
plot(legend = :outertopright)

for i in 1:21
    temp = subset(dfs[2], :season => ByRow(==(i)))
    plot!(temp.sauce_number, temp.scoville,
          color = colours[i],
          marker = :dot)
end

# Add title
title!("Spiciness by Sauce Number and Season")

# Changes axes
yaxis!(:log10)
ylabel!("log(Scoville)")
xticks!(1:10)
xlabel!("Sauce Number")

# save plot
savefig(joinpath(@__DIR__, "spiciness_and_seasons.pdf"))

# /////////////////////////////////////////////////////////////////////////////
# END OF FILE