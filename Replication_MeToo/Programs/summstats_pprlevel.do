


	
use "${data}MeToo_ppr_level.dta", clear

colorpalette viridis
return list
forvalues i = 1/15 {
	local vcolor`i' = r(p`i')
}

**# Figures B.1 and B.2
*---------- Single authored papers and number of coauthors per paper ----------*

preserve 
* all
collapse (sum) solo_ppr (mean) num_pprs_yr num_ca_paper, by(pub_year)
gen share_solo_ppr = solo_ppr/num_pprs_yr

tempfile solo_pprs_all
save `solo_pprs_all'
restore

preserve 
* with covid
keep if covid19_related==1
collapse (sum) solo_ppr (mean) num_pprs_yr_covy = num_pprs_yr_cov num_ca_paper_covy = num_ca_paper, by(pub_year)
gen share_solo_ppr_covy = solo_ppr/num_pprs_yr

tempfile solo_pprs_covy
save `solo_pprs_covy'
restore


preserve 
* without covid
keep if covid19_related==0 & pub_year==2020
collapse (sum) solo_ppr (mean) num_pprs_yr_covn = num_pprs_yr_cov num_ca_paper_covn=num_ca_paper, by(pub_year)
gen share_solo_ppr_covn = solo_ppr/num_pprs_yr

merge 1:1 pub_year using `solo_pprs_all', nogen
merge 1:1 pub_year using `solo_pprs_covy', nogen

gen covy_lab = "Covid" 
gen covn_lab = "No Covid" 
gen all_lab = "All"		

* Figure B.2 (a)
twoway (line num_pprs_yr pub_year, lw(medthick) lc(orange_red)) (scatter num_pprs_yr pub_year if pub_year==2020, mcolor(orange_red) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(orange_red)) (scatter num_pprs_yr_covn pub_year, mc(orange_red) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(orange_red) mlabposition(6)) (scatter num_pprs_yr_covy pub_year, mc(orange_red) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(orange_red) mlabposition(12)), xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Number of papers") legend(order(7 "{bf:Number of papers}, where in 2020, we separate them into" 2 "All papers" 7 " " 3 "Without Covid-related" 7 " " 4 "Covid-related papers") rows(3) position(6)) xsize(7) ysize(6) name(num_pprs_yr, replace)
graph export "${figures}num_pprs_yr.svg", replace			

* Figure B.2 (b)
twoway (line share_solo_ppr pub_year, lw(medthick) lc(ebblue)) (scatter share_solo_ppr pub_year if pub_year==2020, mcolor(ebblue) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(ebblue)) (scatter share_solo_ppr_covn pub_year, mc(ebblue) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(ebblue) mlabposition(6)) (scatter share_solo_ppr_covy pub_year, mc(ebblue) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(ebblue) mlabposition(12)), xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of single-authored papers") legend(order(7 "{bf:Single-authored papers}, where in 2020, we separate them into" 4 "Covid-related papers" 7 " " 2 "All papers" 7 " " 3 "Without Covid-related") rows(3) position(6)) xsize(7) ysize(6) name(solo_pprs_yr, replace)
graph export "${figures}solo_pprs_yr.svg", replace			

graph combine num_pprs_yr solo_pprs_yr, name(fig_num_solo_pprs_yr, replace)
graph display fig_num_solo_pprs_yr, xsize(8.5) ysize(4)
graph export "${figures}fig_num_solo_pprs_yr.svg", replace

restore





**# Figures 2 and 3
*------------------------------------------------------------------------------*
* Shares of: all female / male pprs, some women in the ppr, some men in the ppr

* restore
preserve 
* all
collapse (sum) all_men_ppr all_wom_ppr mixed_ppr (mean) num_pprs_yr, by(pub_year)
gen share_all_men = all_men_ppr/num_pprs_yr
gen share_all_wom = all_wom_ppr/num_pprs_yr
gen share_mixed = mixed_ppr/num_pprs_yr

tempfile shares_all
save `shares_all'
restore

preserve 
* with covid
keep if covid19_related==1
collapse (sum) all_men_ppr all_wom_ppr mixed_ppr  (mean) num_pprs_yr_covy = num_pprs_yr_cov , by(pub_year)
gen share_all_men_covy = all_men_ppr/num_pprs_yr
gen share_all_wom_covy = all_wom_ppr/num_pprs_yr
gen share_mixed_covy = mixed_ppr/num_pprs_yr

tempfile shares_covy
save `shares_covy'
restore


preserve 
* without covid
keep if covid19_related==0 & pub_year==2020
collapse (sum) all_men_ppr all_wom_ppr mixed_ppr  (mean) num_pprs_yr_covn = num_pprs_yr_cov , by(pub_year)
gen share_all_men_covn = all_men_ppr/num_pprs_yr
gen share_all_wom_covn = all_wom_ppr/num_pprs_yr
gen share_mixed_covn = mixed_ppr/num_pprs_yr

merge 1:1 pub_year using `shares_all', nogen
merge 1:1 pub_year using `shares_covy', nogen

gen covy_lab = "Covid" 
gen covn_lab = "No Covid" 
gen all_lab = "All"

* Figure 2 (a)
twoway (line share_all_men pub_year, lw(medthick) lc(blue)) (scatter share_all_men pub_year if pub_year==2020, mcolor(blue) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(blue)) (scatter share_all_men_covn pub_year, mc(blue) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(blue) mlabposition(6)) (scatter share_all_men_covy pub_year, mc(blue) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(blue) mlabposition(12)), ylabel(0.5(0.05)0.7) xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of all men papers") legend(order(7 "{bf:Share of single-gendered papers}, where in 2020, we separate them into" 2 "All papers" 7 " " 3 "Without Covid-related" 7 " " 4 "Covid-related papers") rows(3) position(6)) title("All men") name(sh_all_men, replace)

* Figure 2 (b)
twoway (line share_all_wom pub_year, lw(medthick) lc(midgreen)) (scatter share_all_wom pub_year if pub_year==2020, mcolor(midgreen) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(midgreen)) (scatter share_all_wom_covn pub_year, mc(midgreen) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(midgreen) mlabposition(12)) (scatter share_all_wom_covy pub_year, mc(midgreen) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(midgreen) mlabposition(6)), ylabel(0.0(0.05)0.2) xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of all women papers") legend(order(7 "{bf:Share of single-gendered papers}, where in 2020, we separate them into" 2 "All papers" 7 " " 3 "Without Covid-related" 7 " " 4 "Covid-related papers") rows(3) position(6)) title("All women") name(sh_all_wom, replace)

grc1leg sh_all_men sh_all_wom, title("Share of single-gendered papers") graphregion(color(white)) name(single_sex, replace)
graph display single_sex, xsize(11) ysize(5)
graph export "${figures}single_sex.svg", replace	

* Figure 3
twoway (line share_mixed pub_year, lw(medthick) lc(green)) (scatter share_mixed pub_year if pub_year==2020, mcolor(green) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(green)) (scatter share_mixed_covn pub_year, mc(green) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(green) mlabposition(12)) (scatter share_mixed_covy pub_year, mc(green) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(green) mlabposition(6)), ylabel(0.25(0.05)0.45) xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of mixed-gendered papers") legend(order(7 "{bf:Share of mixed papers}, where in 2020, we separate them into" 2 "All papers" 7 " " 3 "Without Covid-related" 7 " " 4 "Covid-related papers") rows(3) position(6)) name(sh_mixed, replace)
graph export "${figures}sh_mixed.pdf", replace			

restore



**# Figures B.3 and B.4
*------------------------------------------------------------------------------*
* Shares of: cross-seniority pprs
preserve 
collapse (sum) cross_sen_ppr mixd_sens mixd_mids mixd_juns mixd_oths some_jun_sen (mean) num_pprs_yr, by(pub_year)
gen share_xsen_ppr = cross_sen_ppr/num_pprs_yr
gen share_ssen_ppr = mixd_sens/num_pprs_yr
gen share_smid_ppr = mixd_mids/num_pprs_yr
gen share_sjun_ppr = mixd_juns/num_pprs_yr
gen share_soth_ppr = mixd_oths/num_pprs_yr
gen share_junsen_ppr = some_jun_sen/num_pprs_yr

tempfile shares_all
save `shares_all'
restore

preserve 
* with covid
keep if covid19_related==1
collapse (sum) cross_sen_ppr mixd_sens mixd_mids mixd_juns mixd_oths some_jun_sen (mean) num_pprs_yr_covy = num_pprs_yr_cov , by(pub_year)
gen share_xsen_ppr_covy = cross_sen_ppr/num_pprs_yr
gen share_ssen_ppr_covy = mixd_sens/num_pprs_yr
gen share_smid_ppr_covy = mixd_mids/num_pprs_yr
gen share_sjun_ppr_covy = mixd_juns/num_pprs_yr
gen share_soth_ppr_covy = mixd_oths/num_pprs_yr
gen share_junsen_ppr_covy = some_jun_sen/num_pprs_yr

tempfile shares_covy
save `shares_covy'
restore


preserve 
* without covid
keep if covid19_related==0 & pub_year==2020
collapse (sum) cross_sen_ppr mixd_sens mixd_mids mixd_juns mixd_oths some_jun_sen (mean) num_pprs_yr_covn = num_pprs_yr_cov , by(pub_year)
gen share_xsen_ppr_covn = cross_sen_ppr/num_pprs_yr
gen share_ssen_ppr_covn = mixd_sens/num_pprs_yr
gen share_smid_ppr_covn = mixd_mids/num_pprs_yr
gen share_sjun_ppr_covn = mixd_juns/num_pprs_yr
gen share_soth_ppr_covn = mixd_oths/num_pprs_yr
gen share_junsen_ppr_covn = some_jun_sen/num_pprs_yr

merge 1:1 pub_year using `shares_all', nogen
merge 1:1 pub_year using `shares_covy', nogen

gen covy_lab = "Covid" 
gen covn_lab = "No Covid" 
gen all_lab = "All"

* Figure B.3 (a)
twoway (line share_xsen_ppr pub_year, lw(medthick) lc(black) lp(-)) (scatter share_xsen_ppr pub_year if pub_year==2020, mcolor(black) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(black)) (scatter share_xsen_ppr_covn pub_year, mc(black) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(black) mlabposition(12)) (scatter share_xsen_ppr_covy pub_year, mc(black) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(black) mlabposition(6)), xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of mixed-seniority papers") legend(order(7 "{bf:Share of mixed papers}, where in 2020, we separate them into" 2 "All papers" 7 " " 3 "Without Covid-related" 7 " " 4 "Covid-related papers") rows(3) position(6)) name(sh_mixed_sen, replace)
graph export "${figures}sh_mixed_sen.svg", replace	

* Figure B.3 (b)
twoway (line share_ssen_ppr pub_year, lw(medthick) lc("`vcolor3'")) (scatter share_ssen_ppr pub_year if pub_year==2020, mcolor("`vcolor3'") ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor("`vcolor3'")) (scatter share_ssen_ppr_covy pub_year, mc("`vcolor3'") ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor("`vcolor3'") mlabposition(6)) (line share_smid_ppr pub_year, lw(medthick) lc("`vcolor6'")) (scatter share_smid_ppr pub_year if pub_year==2020, mcolor("`vcolor6'") ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor("`vcolor6'")) (scatter share_smid_ppr_covy pub_year, mc("`vcolor6'") ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor("`vcolor6'") mlabposition(3)) (line share_sjun_ppr pub_year, lw(medthick) lc("`vcolor11'")) (scatter share_sjun_ppr pub_year if pub_year==2020, mcolor("`vcolor11'") ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor("`vcolor11'")) (line share_soth_ppr pub_year, lw(medthick) lc("`vcolor14'")) (scatter share_soth_ppr pub_year if pub_year==2020, mcolor("`vcolor14'") ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor("`vcolor14'")) (scatter share_soth_ppr_covy pub_year, mc("`vcolor14'") ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor("`vcolor14'") mlabposition(6)), xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of mixed seniority papers") legend(order(13 "{bf:Share of mixed papers with:}" 1 "a senior" 13 " " 4 "a midcareer" 13 " " 7 "a junior" 13 " " 9 "an early career") col(2) position(6)) xsize(6) ysize(5) name(sh_mixed_sen_all, replace)
graph export "${figures}sh_mixed_sen_all_legend.svg", replace	

*grc1leg sh_mixed_sen sh_mixed_sen_all, rows(1) name(sh_mixed_sen_all, replace)
*graph display sh_mixed_sen_all, xsize(8.5) ysize(4)
*graph export "${figures}sh_mixed_sen_all_fig.svg", replace

* Figure B.4
twoway (line share_junsen_ppr pub_year, lw(medthick) lc(black) lp(-)) (scatter share_junsen_ppr pub_year if pub_year==2020, mcolor(black) ms(o) mlab(all_lab) mlabsize(vsmall) mlabcolor(black)) (scatter share_junsen_ppr_covn pub_year, mc(black) ms(s) mlab(covn_lab) mlabsize(vsmall) mlabcolor(black) mlabposition(6)) (scatter share_junsen_ppr_covy pub_year, mc(black) ms(d) mlab(covy_lab) mlabsize(vsmall) mlabcolor(black) mlabposition(12)), xtitle("Year") xlabel(2004(4)2020) xline(2018.5, lc(gs12)) ytitle("Share of mixed senior-junior papers") legend(order(7 "{bf:Share of mixed senior-junior papers}, where in 2020, we separate them into" 2 "All papers" 7 " " 3 "Without Covid-related" 7 " " 4 "Covid-related papers") rows(3) position(6)) name(sh_mixed_senjun, replace)
graph export "${figures}ssh_mixed_senjun.pdf", replace	
graph export "${figures}ssh_mixed_senjun.svg", replace	

restore




**# Figure B.1
*------------------------------------------------------------------------------*
* Shares of: women authors

* Shares of all male papers
preserve 
* all
collapse num_wom_yr num_auth_yr num_pprs_yr, by(pub_year)
gen share_wom_auth = num_wom_yr/num_auth_yr

twoway (line share_wom_auth pub_year, lw(medthick) lc(ebblue)), xtitle("Year") xlabel(2004(4)2020) ylabel(0.1(0.1)0.4) xline(2018.5, lc(gs12)) ytitle("Share of women") name(share_wom, replace)
graph export "${figures}share_wom_auth_yr.svg", replace
* we manually added the graph from \citet*{Ductor2021}

restore



















