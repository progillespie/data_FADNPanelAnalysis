*hist fdratio, by(country, note("")) xsize(4) saving(output/graphs/feed/fdratio, replace)
hist fdratio if grassregion < ., by(region, note("")) xsize(4) saving("output/graphs/feed/fdratio.gph", replace)
graph export output/graphs/feed/fdratio.pdf, replace

hist fdratio if grassregion < ., by(grassregion, note("")) xsize(4) saving("output/graphs/feed/fdratio_greg.gph", replace)
graph export output/graphs/feed/fdratio_greg.pdf, replace
