
* This code creates the three types of samples, all, senior, and junior authors


use "${data}MeToo_author_ppr.dta", clear

gen metoo = (min_date>=td(01jul2018) & min_date<=td(31dec2020))

* average number of women coauthors over total coauthors per period (this is a period specific variable that can replace period FEs)
by period, sort: egen share_women = mean(women_prop_paper)

* covid period
gen quarter = quarter(min_date)
gen q2_2020 = (quarter == 2 & pub_year == 2020)
gen covid_period = (quarter > 1 & pub_year == 2020)

* clean experience and sex
replace experience_evolve = pub_year - yearPhDgraduation_orig - 0.5
replace experience_evolve = round(experience_evolve)

* bottom and top code experience
replace experience_evolve = -5 if experience_evolve < -5
replace experience_evolve = experience_evolve + 5
replace experience_evolve = 55 if experience_evolve> 55

gen experience_2 = experience_evolve^2
gen period_sq    = period^2

* generate "unclassified" field (due to missing JEL codes)
gen wfield_21 = wfield_1==.
foreach fie of numlist 1(1)20 {
	replace wfield_`fie'= 0 if wfield_`fie'==.
}

*---------------------- All authors' sample ----------------------*

preserve
* drop the first observation per author (or equivalently within the new threshold)
* define the threshold
sort temp_name_orig, stable
by temp_name_orig: egen first_date = min(min_date)
forvalues i = 0(3)9 {
	gen cutoff_`i' = first_date + (91 * `i'/3)
	format cutoff_`i' %td
}

* remove the papers that are below the cutoff relative to the authors first paper, and drop period 0
drop if min_date <= cutoff_3
drop if period == 0			

save "${data}MeToo_author_ppr_allaut.dta", replace

restore


*---------------------- Senior authors' sample ----------------------*

preserve
*drop the first observation per author (or equivalently within the new threshold)
*define the threshold
sort temp_name_orig, stable
by temp_name_orig: egen first_date = min(min_date)
forvalues i = 0(3)9 {
	gen cutoff_`i' = first_date + (91 * `i'/3)
	format cutoff_`i' %td
}

*remove those papers and drop period 0
drop if min_date <= cutoff_3
drop if period == 0

* drop non seniors 
keep if seniority_orig==3

save "${data}MeToo_author_ppr_senior.dta", replace
restore

*---------------------- Junior authors' sample ----------------------*

preserve
*drop the first observation per author (or equivalently within the new threshold)
*define the threshold
sort temp_name_orig, stable
by temp_name_orig: egen first_date = min(min_date)
forvalues i = 0(3)9 {
	gen cutoff_`i' = first_date + (91 * `i'/3)
	format cutoff_`i' %td
}

* remove those papers and drop period 0
drop if min_date <= cutoff_3
drop if period == 0

* keep juniors only
keep if seniority_orig==1 			

save "${data}MeToo_author_ppr_onlyju.dta", replace
restore
	



	
	
	
	