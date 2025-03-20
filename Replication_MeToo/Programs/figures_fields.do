

colorpalette viridis
return list
forvalues i = 1/15 {
	local vcolor`i' = r(p`i')
}

************************************************************************************
local fieldVars "applied_auth macro_auth theory_auth"
local titles "Applied-Micro Macro-Related Theory"


local t = 1
foreach field in `fieldVars' {
	local title : word `t' of `titles'
**# Figure 1 

	use "$intdata/allaut_`field'_women_prop_paper.dta", clear
	merge 1:1 sex using "$intdata/onlyju_`field'_jun_wom_prop_paper.dta", nogen
	merge 1:1 sex using "$intdata/senior_`field'_sen_wom_prop_paper.dta", nogen
	
	local o 0
	foreach var in women_prop_paper jun_wom_prop_paper sen_wom_prop_paper {
		ren me_`var' me_`o'
		ren se_`var' se_`o'
		local o = `o' + 1
	}
	reshape long  me_ se_, i(sex) j(dep_var)
	label define dep_label 0 "allaut women_prop" 1 "onlyju jun_wom_prop" 2 "senior sen_wom_prop"
	label value dep_var dep_label
	
	gen lb = me_ - 1.64 * se_
	gen ub = me_ + 1.64 * se_
	
	
	gen xaxis = dep_var if sex==1 
	replace xaxis = dep_var + 0.15 if sex==0
	
	twoway (scatter me_ xaxis if sex==1 & dep_var==0, color("`vcolor13'") msymbol(D) msize(medlarge)) (rcapsym ub lb xaxis if sex==1 & dep_var==0, color("`vcolor13'%30") msymbol(d) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==0 & dep_var==0, color("`vcolor13'") msymbol(S) msize(medlarge)) (rcapsym ub lb xaxis if sex==0 & dep_var==0, color("`vcolor13'%30") msymbol(s) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==1 & dep_var==1, color("`vcolor7'") msymbol(D) msize(medlarge)) (rcapsym ub lb xaxis if sex==1 & dep_var==1, color("`vcolor7'%30") msymbol(d) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==0 & dep_var==1, color("`vcolor7'") msymbol(S) msize(medlarge)) (rcapsym ub lb xaxis if sex==0 & dep_var==1, color("`vcolor7'%30") msymbol(s) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==1 & dep_var==2, color("`vcolor3'") msymbol(D) msize(medlarge)) (rcapsym ub lb xaxis if sex==1 & dep_var==2, color("`vcolor3'%30") msymbol(d) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==0 & dep_var==2, color("`vcolor3'") msymbol(S) msize(medlarge)) (rcapsym ub lb xaxis if sex==0 & dep_var==2, color("`vcolor3'%30") msymbol(s) msize(vsmall) lw(medthick)), yline(0, lp(-) lcolor(gs13)) xlabel(-0.1 " " 0.1 "{stSerif:{it:All}}" 1.1 "{stSerif:{it:Junior}}" 2.1 "{stSerif:{it:Senior}}" 2.2 " ") xtitle("{stSerif:{it:Authors' sample}}", size(medlarge)) ytitle("{stSerif:Predicted marginal effects}", size(medlarge)) legend(order(18 "{stSerif:Share of women coauthors by sample:}" 1 "{stSerif:women}" 19 " " 3 "{stSerif:men}") row(2) pos(6) size(medium) symxsize(4) region(lwidth(none))) title("{stSerif:`title' fields}") xsize(12) ysize(9) graphregion(col(white)) name(fig_1_`field', replace)	

	
	**# Figure 2 
	
	use "$intdata/onlyju_`field'_sen.dta", clear
	merge 1:1 sex using "$intdata/onlyju_`field'_sen_wom_prop_paper.dta", nogen
	merge 1:1 sex using "$intdata/senior_`field'_jun.dta", nogen
	merge 1:1 sex using "$intdata/senior_`field'_jun_wom_prop_paper.dta", nogen
	
	local o 0
	foreach var in sen sen_wom_prop_paper jun jun_wom_prop_paper {
		ren me_`var' me_`o'
		ren se_`var' se_`o'
		local o = `o' + 1
	}
	reshape long  me_ se_, i(sex) j(dep_var)
	label define dep_label 0 "onlyju sen_prop" 1 "onlyju sen_wom_prop" 2 "senior jun_prop" 3 "senior jun_wom_prop"
	label value dep_var dep_label
	
	gen lb = me_ - 1.64 * se_
	gen ub = me_ + 1.64 * se_
	
	gen xaxis = 1 if dep_var==0 & sex==2
	replace xaxis = 1.5 if dep_var==1 & sex==2	
	replace xaxis = 2.5 if dep_var==2 & sex==2
	replace xaxis = 3 if dep_var==3 & sex==2
	
	twoway (scatter me_ xaxis if sex==2 & dep_var==0, color("`vcolor7'") msymbol(O) msize(medlarge)) (rcapsym ub lb xaxis if sex==2 & dep_var==0, color("`vcolor7'%30") msymbol(o) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==2 & dep_var==1, color("`vcolor7'") msymbol(D) msize(medlarge)) (rcapsym ub lb xaxis if sex==2 & dep_var==1, color("`vcolor7'%30") msymbol(d) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==2 & dep_var==2, color("`vcolor3'") msymbol(O) msize(medlarge)) (rcapsym ub lb xaxis if sex==2 & dep_var==2, color("`vcolor3'%30") msymbol(o) msize(vsmall) lw(medthick)) (scatter me_ xaxis if sex==2 & dep_var==3, color("`vcolor3'") msymbol(D) msize(medlarge)) (rcapsym ub lb xaxis if sex==2 & dep_var==3, color("`vcolor3'%30") msymbol(d) msize(vsmall) lw(medthick)), yline(0, lp(-) lcolor(gs13)) xtitle("{stSerif:{it:Authors' sample}}", size(medlarge)) xlabel(0.75 " " 1.25 "{stSerif:{it:Junior}}" 2.75 "{stSerif:{it:Senior}}" 3.25 " ") ytitle("{stSerif:Predicted marginal effects}", size(medlarge)) legend(order(9 "{stSerif:Juniors':}" 1 "{stSerif:Senior coauthors}" 9 "{stSerif:Seniors':}" 5 "{stSerif:Junior coauthors}" 9 " " 3 "{stSerif:Senior women coauthors}" 9 " " 7 "{stSerif:Junior women coauthors}") row(2) pos(6) symxsize(4) region(lwidth(none))) title("{stSerif:`title' fields}") xsize(12) ysize(9) graphregion(col(white)) name(fig_2_`field', replace)
	
			
			
			
	**# Figure 3
	
	use "$intdata/allaut_`field'_new_prop_paper.dta", replace
	ren me_new_prop_paper me_allaut_new
	ren se_new_prop_paper se_allaut_new
	merge 1:1 sex using "$intdata/onlyju_`field'_new_sen_prop_paper.dta", nogen
	ren me_new_sen_prop_paper me_onlyju_newsen
	ren se_new_sen_prop_paper se_onlyju_newsen
	merge 1:1 sex using "$intdata/senior_`field'_new_jun_prop_paper.dta", nogen
	ren me_new_jun_prop_paper me_senior_newjun
	ren se_new_jun_prop_paper se_senior_newjun
	local o 0
	foreach var in allaut_new onlyju_newsen senior_newjun {
		ren me_`var' me_`o'
		ren se_`var' se_`o'
		local o = `o' + 1
	}
	reshape long  me_ se_, i(sex) j(dep_var)
	label define dep_label 0 "allaut newall" 1 "onlyju newsen" 2 "senior newjun"
	label value dep_var dep_label
	
	gen lb = me_ - 1.64 * se_
	gen ub = me_ + 1.64 * se_
	
	gen xaxis = 1 if dep_var==0 & sex==2
	replace xaxis = 2 if dep_var==1 & sex==2
	replace xaxis = 3 if dep_var==2 & sex==2
	
	
	twoway (scatter me_ xaxis if xaxis==1, color("`vcolor13'") msymbol(Oh) msize(medlarge) mlw(medthick)) (rcapsym ub lb xaxis if xaxis==1, color("`vcolor13'%30") msymbol(oh) msize(vsmall) lw(medthick)) (scatter me_ xaxis if xaxis==2, color("`vcolor7'") msymbol(Oh) msize(medlarge) mlw(medthick)) (rcapsym ub lb xaxis if xaxis==2, color("`vcolor7'%30") msymbol(oh) msize(vsmall) lw(medthick) lw(medthick)) (scatter me_ xaxis if xaxis==3, color("`vcolor3'") msymbol(Oh) msize(medlarge) mlw(medthick)) (rcapsym ub lb xaxis if xaxis==3, color("`vcolor3'%30") msymbol(oh) msize(vsmall) lw(medthick)), yline(0, lp(-) lcolor(gs13)) xlabel(0.85 " " 1 "{stSerif:{it:All}}" 2 "{stSerif:{it:Junior}}" 3 "{stSerif:{it:Senior}}" 3.15 " ") xtitle("{stSerif:{it:Authors' sample}}", size(medlarge)) ytitle("{stSerif:Predicted marginal effects}", size(medlarge)) legend(order(9 "{stSerif:Share of new coauthors by sample:}" 1 "{stSerif:all new coauthors}" 9 " " 3 "{stSerif:senior new coauthors for juniors}" 9 " " 5 "{stSerif:junior new coauthors for seniors}") col(2) pos(6) symxsize(4) region(lwidth(none))) title("{stSerif:`title' fields}") xsize(12) ysize(9) graphregion(col(white)) name(fig_3_`field', replace)

	local t = `t' + 1
}


grc1leg fig_1_applied_auth fig_1_macro_auth fig_1_theory_auth, rows(1) name(fig_1_x_fieldgps, replace)
graph display fig_1_x_fieldgps, xsize(11) ysize(4)
graph export "${figures}/figure1_fields.svg", replace


grc1leg fig_2_applied_auth fig_2_macro_auth fig_2_theory_auth, rows(1) name(fig_2_x_fieldgps, replace)
graph display fig_2_x_fieldgps, xsize(11) ysize(4)
graph export "${figures}/figure2_fields.svg", replace


grc1leg fig_3_applied_auth fig_3_macro_auth fig_3_theory_auth, rows(1) name(fig_3_x_fieldgps, replace)
graph display fig_3_x_fieldgps, xsize(11) ysize(4)
graph export "${figures}/figure3_fields.svg", replace







