


*------------------------ Rolling dates figures


**# Figure C.1 (a)
use "${intdata}rolling_senior_c_jun_prop_paper.dta", clear 
ren me_ me_jun
ren se_ se_jun
merge 1:1 sex date using "${intdata}rolling_senior_new_jun_prop_paper.dta", nogen
ren me_ me_new_jun
ren se_ se_new_jun				
				
foreach gp in jun new_jun {
	gen lb_`gp' = me_`gp' - 1.96 * se_`gp'
	gen ub_`gp' = me_`gp' + 1.96 * se_`gp'
}

generate daten = date(date, "MY")
format %tdMon_CCYY daten
tostring daten, gen(date_string)
egen date_numeric = group(daten)
labmask date_numeric, values(date)

gen xaxis = daten + 10

twoway (scatter me_jun daten if sex==2, color(blue) msymbol(o)) (rcapsym ub_jun lb_jun daten if sex==2, color(blue%30) msymbol(o) msize(vsmall)) (scatter me_new_jun xaxis if sex==2, color(blue) msymbol(oh)) (rcapsym ub_new_jun lb_new_jun xaxis if sex==2, color(blue%30) msymbol(oh) msize(vsmall) lp(-)), yline(0, lp(-) lcolor(gs13)) xline(21366, lp(-) lcolor(gs13)) ylabel(, labsize(small)) xlabel(21275 21640 21397 21762 21154 21519 21884 21216 21581 21336 21701 21093 21458 21823, valuelabel angle(45) labsize(small)) xtitle(" ") ytitle("Estimated marginal effects of MeToo" " ", size(medium)) legend(order(9 "Share of coauthors of seniors who are:" 1 "juniors" 9 " " 3 "new and junior") row(2) pos(6) size(medium) symxsize(4) region(lwidth(none))) xsize(12) ysize(9) graphregion(col(white))name(senior_junnewjun_`field', replace)
graph export "${figures}rolling_senior_jun_newjun_3m.pdf", replace	

**# Figure C.1 (b)
use "${intdata}rolling_senior_d_jun_wom_prop_paper.dta", clear 
ren me_ me_jun_wom
ren se_ se_jun_wom
merge 1:1 sex date using "${intdata}rolling_senior_b_new_wom_jun_prop_paper.dta", nogen
ren me_ me_new_jun_wom
ren se_ se_new_jun_wom				
				
foreach gp in jun_wom new_jun_wom {
	gen lb_`gp' = me_`gp' - 1.96 * se_`gp'
	gen ub_`gp' = me_`gp' + 1.96 * se_`gp'
}

generate daten = date(date, "MY")
format %tdMon_CCYY daten
tostring daten, gen(date_string)
egen date_numeric = group(daten)
labmask date_numeric, values(date)

gen xaxis = daten + 10

twoway (scatter me_jun_wom daten if sex==0, color(blue) msymbol(d)) (rcapsym ub_jun_wom lb_jun_wom daten if sex==0, color(blue%30) msymbol(d) msize(vsmall)) (scatter me_new_jun_wom xaxis if sex==0, color(blue) msymbol(dh)) (rcapsym ub_new_jun_wom lb_new_jun_wom xaxis if sex==0, color(blue%30) msymbol(dh) msize(vsmall) lp(-)), yline(0, lp(-) lcolor(gs13)) xline(21366, lp(-) lcolor(gs13)) ylabel(, labsize(small)) xlabel(21275 21640 21397 21762 21154 21519 21884 21216 21581 21336 21701 21093 21458 21823, valuelabel angle(45) labsize(small)) xtitle(" ") ytitle("Estimated marginal effects of MeToo" " ", size(medium)) legend(order(9 "Share of coauthors of seniors who are:" 1 "junior women" 9 " " 3 "new and junior women") row(2) pos(6) size(medium) symxsize(4) region(lwidth(none))) xsize(12) ysize(9) graphregion(col(white))name(senior_junnewjunwom_`field', replace)
graph export "${figures}rolling_senior_junwom_newjunwom_3m.pdf", replace		
graph export "${figures}rolling_senior_junwom_newjunwom_3m.svg", replace			



	
	
	






