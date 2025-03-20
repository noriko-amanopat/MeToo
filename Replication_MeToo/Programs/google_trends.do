

import delimited "${data}external/MeToo_USgoogletrends.csv", clear 
drop if _n<3
ren v1 dates
destring v2, gen(US_searches) force
replace US_searches = 0 if v2=="<1"

split dates, parse("-") generate(year_month)
gen str_date = year_month2 + year_month1
gen daten = date(str_date, "MY")
format %tdMon_CCYY daten

keep dates US_search daten

tempfile US_trends
save `US_trends'


import delimited "${data}external/MeToo_worldgoogletrends.csv", clear 
drop if _n<3
ren v1 dates
destring v2, gen(world_search)

split dates, parse("-") generate(year_month)
gen str_date = year_month2 + year_month1
gen daten = date(str_date, "MY")
format %tdMon_CCYY daten

keep dates world_search daten
merge 1:1 dates daten using `US_trends', nogen


colorpalette viridis
return list
forvalues i = 1/15 {
	local vcolor`i' = r(p`i')
}

twoway (line world_search daten, color("`vcolor5'") lw(medthick)) (line US_search daten, color("`vcolor13'") lw(medthick)), ylabel(, labsize(small)) xlabel(19997 20362 20728 21093 21366 21519 21823 21975 22189 22554 22919 23284, angle(45) labsize(small)) ytitle("{stSerif:Relative search interest}", size(medlarge)) xtitle(" ") xline(21093 21366 21975, lp(-) lcolor(gs13)) legend(order(9 "{stSerif:Popularity of MeToo searches in google:}" 1 "{stSerif:Worldwide}" 2 "{stSerif:In the US}") row(1) pos(6) symxsize(4) size(medlarge) region(lwidth(none))) 

graph export "${figures}google_trends.pdf", replace
















