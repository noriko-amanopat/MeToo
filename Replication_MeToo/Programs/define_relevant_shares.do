

preserve 
use "${data}MeToo_ppr_level.dta", clear

collapse (sum) all_men_ppr all_wom_ppr (mean) av_num_ca_paper_yr = num_ca_paper num_oth_yr num_jun_yr num_mid_yr num_sen_yr num_wom_yr num_oth_wom_yr num_jun_wom_yr num_mid_wom_yr num_sen_wom_yr num_auth_yr num_pprs_yr, by(pub_year)
gen share_all_men = all_men_ppr/num_pprs_yr
gen share_all_wom = all_wom_ppr/num_pprs_yr

foreach var in oth jun mid sen {
	gen share_`var' = num_`var'_yr / num_auth_yr
	gen share_`var'_wom = num_`var'_wom_yr / num_auth_yr
	gen share_`var'_wom_b = num_`var'_wom_yr / num_wom_yr
}
gen share_wom = num_wom_yr/num_auth_yr

keep pub_year av_num_ca_paper_yr share_*

tempfile aggr_comp_chngs
save `aggr_comp_chngs'
restore

merge m:1 pub_year using `aggr_comp_chngs', keep(master match) nogen
