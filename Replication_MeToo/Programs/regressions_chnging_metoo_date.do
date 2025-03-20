
clear all

* changing the starting date of metoo in 3 month intervals
global metoolist nov2017 feb2018 may2018 aug2018 nov2018 feb2019 may2019 aug2019 nov2019


foreach sample in senior  { 
	
	use "${data}MeToo_author_ppr_`sample'.dta", clear
	
	do "${programs}define_relevant_shares.do"

	* controls for full regressions
	
	gl exper_time av_num_ca_paper_yr num_ca_paper experience_evolve experience_2 i.period 
	* network characteristics
	gl network degree_lag clustering_self_lag
	* author productivity
	gl prodty author_period_papers author_cumulative_papers
	* paper fields
	gl fields wfield_1 - wfield_20
	** weights
	gen in_regression = period !=. & experience_evolve !=. & num_ca_paper !=. & degree_lag !=. & clustering_self_lag !=. & author_period_papers !=. & author_cumulative_papers !=. & wfield_1 !=.
	egen num_authors_in_sample = total(in_regression), by(unique_paper_id)
	gen inv_weight = 1/num_authors_in_sample
	gl weight [aw = inv_weight]
	
		
	**********************************
	* Date loop
	foreach metoo_date in $metoolist  { 
		local tempdate = date("`metoo_date'", "MY")
		replace metoo = (min_date>=`tempdate' & min_date<=td(31dec2020)) 

		* =================
		* NEW COAUTHORSHIPS
		* =================
		
		*--------------------------------------------------------------
		* Regressions with NEW authors and broken down by seniority
		** Regressions (1): New coauthors
		** Regressions (2): New senior ca
		** Regressions (3): New mid ca
		** Regressions (4): New junior ca
		** Regressions (5): New other ca
		*--------------------------------------------------------------
		
		* Define the list of dependent variables for regressions 1–5
		local depVars "new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper"
		local list_relev_shares "nothing share_sen share_mid share_jun share_oth"
	
		
		local j = 1
		foreach var in `depVars' {
			if `j'==1 {
				qui glm `var' i.metoo##i.sex i.sex##i.covid_period $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) at(sex=(0 1)) post
				{
					matrix list r(table)
					matrix m_frac = r(table)
					
					gen me_frac_`metoo_date' = .
					gen se_frac_`metoo_date' = .
					forval i = 0/1 {
						local k = `i' + 3
						replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
						replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
					}
				}
				qui glm `var' i.metoo i.sex i.covid_period $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) post
				{
					matrix list r(table)
					matrix m_all = r(table)
					
					gen me_all_`metoo_date' = .
					gen se_all_`metoo_date' = .
					replace me_all_`metoo_date' = m_all[1,2]
					replace se_all_`metoo_date' = m_all[2,2] 
					
					preserve
					collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
					ren me_frac_`metoo_date' me_`metoo_date'
					ren se_frac_`metoo_date' se_`metoo_date'
					tempfile frac_`var'
					save `frac_`var''
					restore
					preserve
					keep me_all_`metoo_date' se_all_`metoo_date' 
					duplicates drop
					ren me_all_`metoo_date' me_`metoo_date'
					ren se_all_`metoo_date' se_`metoo_date'
					gen sex = 2
					append using `frac_`var''
					order sex
					sort sex
					
					save "${intdata}rolling_`sample'_`j'_`metoo_date'.dta", replace
					restore
					
					drop me_frac* se_frac* me_all* se_all*
				}
			}
			else if `j'!=1 {
				local relevant_share : word `j' of `list_relev_shares'
				* Regression by gender
				qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) at(sex=(0 1)) post
				{
					matrix list r(table)
					matrix m_frac = r(table)
					
					gen me_frac_`metoo_date' = .
					gen se_frac_`metoo_date' = .
					forval i = 0/1 {
						local k = `i' + 3
						replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
						replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
					}
				}
				qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) post
				{
					matrix list r(table)
					matrix m_all = r(table)
					
					gen me_all_`metoo_date' = .
					gen se_all_`metoo_date' = .
					replace me_all_`metoo_date' = m_all[1,2]
					replace se_all_`metoo_date' = m_all[2,2] 
					
					preserve
					collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
					ren me_frac_`metoo_date' me_`metoo_date'
					ren se_frac_`metoo_date' se_`metoo_date'
					tempfile frac_`var'
					save `frac_`var''
					restore
					preserve
					keep me_all_`metoo_date' se_all_`metoo_date' 
					duplicates drop
					ren me_all_`metoo_date' me_`metoo_date'
					ren se_all_`metoo_date' se_`metoo_date'
					gen sex = 2
					append using `frac_`var''
					order sex
					sort sex
					
					save "${intdata}rolling_`sample'_`j'_`metoo_date'.dta", replace
					restore
					
					drop me_frac* se_frac* me_all* se_all*
				}
			}
			local j = `j' + 1
		}
		
		*--------------------------------------------------------------
		* Regressions with NEW WOMEN authors and broken down by seniority
		** Regressions (1b): New women ca
		** Regressions (2b): New senior women coauthors
		** Regressions (3b): New mid women ca
		** Regressions (4b): New junior ca
		** Regressions (5b): New other ca
		* --------------------------------------------------------------
		
		* Define the list of dependent variables for regressions 1–5
		local depVars "new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper"
		local list_relev_shares "share_wom share_sen_wom share_mid_wom share_jun_wom share_oth_wom"
		local list_relev_shares_b "nothing share_sen_wom_b share_mid_wom_b share_jun_wom_b share_oth_wom_b"
		
		
		local j = 1
		foreach var in `depVars' {
			local relevant_share : word `j' of `list_relev_shares'
			if `j' == 1 {
				* Regression by gender
				qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) at(sex=(0 1)) post
				{
					matrix list r(table)
					matrix m_frac = r(table)
					
					gen me_frac_`metoo_date' = .
					gen se_frac_`metoo_date' = .
					forval i = 0/1 {
						local k = `i' + 3
						replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
						replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
					}
				}
				qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) post
				{
					matrix list r(table)
					matrix m_all = r(table)
					
					gen me_all_`metoo_date' = .
					gen se_all_`metoo_date' = .
					replace me_all_`metoo_date' = m_all[1,2]
					replace se_all_`metoo_date' = m_all[2,2] 
					
					preserve
					collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
					ren me_frac_`metoo_date' me_`metoo_date'
					ren se_frac_`metoo_date' se_`metoo_date'
					tempfile frac_`var'
					save `frac_`var''
					restore
					preserve
					keep me_all_`metoo_date' se_all_`metoo_date' 
					duplicates drop
					ren me_all_`metoo_date' me_`metoo_date'
					ren se_all_`metoo_date' se_`metoo_date'
					gen sex = 2
					append using `frac_`var''
					order sex
					sort sex
					
					save "${intdata}rolling_`sample'_b`j'_`metoo_date'.dta", replace
					restore
					
					drop me_frac* se_frac* me_all* se_all*
				}
			}
			else if `j'!=1 {
				local relevant_share_b : word `j' of `list_relev_shares_b'
				* Regression by gender
				qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) at(sex=(0 1)) post
				{
					matrix list r(table)
					matrix m_frac = r(table)
					
					gen me_frac_`metoo_date' = .
					gen se_frac_`metoo_date' = .
					forval i = 0/1 {
						local k = `i' + 3
						replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
						replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
					}
				}
				qui glm `var' i.metoo i.sex i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) post
				{
					matrix list r(table)
					matrix m_all = r(table)
					
					gen me_all_`metoo_date' = .
					gen se_all_`metoo_date' = .
					replace me_all_`metoo_date' = m_all[1,2]
					replace se_all_`metoo_date' = m_all[2,2] 
					
					preserve
					collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
					ren me_frac_`metoo_date' me_`metoo_date'
					ren se_frac_`metoo_date' se_`metoo_date'
					tempfile frac_`var'
					save `frac_`var''
					restore
					preserve
					keep me_all_`metoo_date' se_all_`metoo_date' 
					duplicates drop
					ren me_all_`metoo_date' me_`metoo_date'
					ren se_all_`metoo_date' se_`metoo_date'
					gen sex = 2
					append using `frac_`var''
					order sex
					sort sex
					
					save "${intdata}rolling_`sample'_b`j'_`metoo_date'.dta", replace
					restore
					
					drop me_frac* se_frac* me_all* se_all*
				}
			}
			local j = `j' + 1
		}
		
		
		*--------------------------------------------------------------
		* Regressions with proportions of ALL authors broken down by seniority
		** Regressions (1c): All authors (no regressions!)
		** Regressions (2c): All senior coauthors
		** Regressions (3c): All mid-career cauthors
		** Regressions (4c): All junior coauthors
		** Regressions (5c): All other coauthors
		*--------------------------------------------------------------
		
		* Define the list of dependent variables for regressions 2–5
		local depVars "sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper"
		local list_relev_shares "nothing share_sen share_mid share_jun share_oth"
		
		
		local j = 2
		
		foreach var in `depVars' {
			* Regression by gender
			local relevant_share : word `j' of `list_relev_shares'
			qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			margins, dydx(metoo) at(sex=(0 1)) post
			{
				matrix list r(table)
				matrix m_frac = r(table)
				
				gen me_frac_`metoo_date' = .
				gen se_frac_`metoo_date' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
					replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
				}
			}
			qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			margins, dydx(metoo) post
			{
				matrix list r(table)
				matrix m_all = r(table)
				
				gen me_all_`metoo_date' = .
				gen se_all_`metoo_date' = .
				replace me_all_`metoo_date' = m_all[1,2]
				replace se_all_`metoo_date' = m_all[2,2] 
				
				preserve
				collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
				ren me_frac_`metoo_date' me_`metoo_date'
				ren se_frac_`metoo_date' se_`metoo_date'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_all_`metoo_date' se_all_`metoo_date' 
				duplicates drop
				ren me_all_`metoo_date' me_`metoo_date'
				ren se_all_`metoo_date' se_`metoo_date'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}rolling_`sample'_c`j'_`metoo_date'.dta", replace
				restore
				
				drop me_frac* se_frac* me_all* se_all*
			}
			local j = `j' + 1
		}
		
		*--------------------------------------------------------------
		* Regressions with proportions of ALL women authors broken down by seniority
		** Regressions (1d): All women authors 
		** Regressions (2d): All senior women coauthors
		** Regressions (3d): All mid-career women cauthors
		** Regressions (4d): All junior women cauthors
		** Regressions (5d): All other women coauthors
		*--------------------------------------------------------------
		
		local depVars "women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper"
		local list_relev_shares "share_wom share_sen_wom share_mid_wom share_jun_wom share_oth_wom"
		local list_relev_shares_b "nothing share_sen_wom_b share_mid_wom_b share_jun_wom_b share_oth_wom_b"
		
		
		local j = 1

		foreach var in `depVars' {
			* Regression with weights
			local relevant_share : word `j' of `list_relev_shares'
			if `j' == 1 {
				qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) at(sex=(0 1)) post
				{
					matrix list r(table)
					matrix m_frac = r(table)
					
					gen me_frac_`metoo_date' = .
					gen se_frac_`metoo_date' = .
					forval i = 0/1 {
						local k = `i' + 3
						replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
						replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
					}
				}
				qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) post
				{
					matrix list r(table)
					matrix m_all = r(table)
					
					gen me_all_`metoo_date' = .
					gen se_all_`metoo_date' = .
					replace me_all_`metoo_date' = m_all[1,2]
					replace se_all_`metoo_date' = m_all[2,2] 
					
					preserve
					collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
					ren me_frac_`metoo_date' me_`metoo_date'
					ren se_frac_`metoo_date' se_`metoo_date'
					tempfile frac_`var'
					save `frac_`var''
					restore
					preserve
					keep me_all_`metoo_date' se_all_`metoo_date' 
					duplicates drop
					ren me_all_`metoo_date' me_`metoo_date'
					ren se_all_`metoo_date' se_`metoo_date'
					gen sex = 2
					append using `frac_`var''
					order sex
					sort sex
					
					save "${intdata}rolling_`sample'_d`j'_`metoo_date'.dta", replace
					restore
					
					drop me_frac* se_frac* me_all* se_all*
				}
				
			}	
			else if `j'!=1 {
				local relevant_share_b : word `j' of `list_relev_shares_b'
				qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) at(sex=(0 1)) post
				{
					matrix list r(table)
					matrix m_frac = r(table)
					
					gen me_frac_`metoo_date' = .
					gen se_frac_`metoo_date' = .
					forval i = 0/1 {
						local k = `i' + 3
						replace me_frac_`metoo_date' = m_frac[1,`k'] if sex==`i'
						replace se_frac_`metoo_date' = m_frac[2,`k'] if sex==`i'
					}
				}
				qui glm `var' i.metoo i.sex i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
				margins, dydx(metoo) post
				{
					matrix list r(table)
					matrix m_all = r(table)
					
					gen me_all_`metoo_date' = .
					gen se_all_`metoo_date' = .
					replace me_all_`metoo_date' = m_all[1,2]
					replace se_all_`metoo_date' = m_all[2,2] 
					
					preserve
					collapse me_frac_`metoo_date' se_frac_`metoo_date' , by(sex)
					ren me_frac_`metoo_date' me_`metoo_date'
					ren se_frac_`metoo_date' se_`metoo_date'
					tempfile frac_`var'
					save `frac_`var''
					restore
					preserve
					keep me_all_`metoo_date' se_all_`metoo_date' 
					duplicates drop
					ren me_all_`metoo_date' me_`metoo_date'
					ren se_all_`metoo_date' se_`metoo_date'
					gen sex = 2
					append using `frac_`var''
					order sex
					sort sex
					
					save "${intdata}rolling_`sample'_d`j'_`metoo_date'.dta", replace
					restore
					
					drop me_frac* se_frac* me_all* se_all*
				}
				
			}
			local j = `j' + 1
		}
		
	}
	*------------------- End of regressions
	*
}	
	

	
	
	
	
	
*------------------- Save data for figures	
	
foreach sample in senior { 
		
	* Append all varying MeToo years for each outcome
	local remaining_dates
		local n : word count $metoolist
		forvalues i = 2/`n' {
			local date : word `i' of $metoolist
			local remaining_dates "`remaining_dates' `date'"
	}
	*** Regressions 1-5
	
	local depVars "new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper"
	clear
	
	forvalues j = 1/5 {
		* local j 1
		local depVar : word `j' of `depVars'
		local base_date : word 1 of $metoolist
		use "${intdata}rolling_`sample'_`j'_`base_date'.dta", clear
		
		foreach metoo_date in `remaining_dates' {
			merge 1:1 sex using "${intdata}rolling_`sample'_`j'_`metoo_date'.dta", nogen
		}
		reshape long me_ se_, i(sex) j(date) string
		save "${intdata}rolling_`sample'_`depVar'.dta", replace
		
	}
	
	
	*** Regressions 1b-5b
	local depVars "new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper"
	clear
	forvalues j = 1/5 {
		* local j 5
		local depVar : word `j' of `depVars'
		local base_date : word 1 of $metoolist
		use "${intdata}rolling_`sample'_b`j'_`base_date'.dta", clear
		foreach metoo_date in `remaining_dates' {
			merge 1:1 sex using "${intdata}rolling_`sample'_b`j'_`metoo_date'.dta", nogen
		}
		reshape long me_ se_, i(sex) j(date) string
		save "${intdata}rolling_`sample'_b_`depVar'.dta", replace
	}
	

	*** Regressions 2c-5c
	local depVars "sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper"
	clear
	forvalues j = 2/5 {
		* local j 4
		local k = `j'-1
		local depVar : word `k' of `depVars'
		local base_date : word 1 of $metoolist
		use "${intdata}rolling_`sample'_c`j'_`base_date'.dta", clear
		foreach metoo_date in `remaining_dates' {
			merge 1:1 sex using "${intdata}rolling_`sample'_c`j'_`metoo_date'.dta", nogen
		}
		reshape long me_ se_, i(sex) j(date) string
		save "${intdata}rolling_`sample'_c_`depVar'.dta", replace
	}
	
	
	*** Regressions 1d-5d
	local depVars "women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper"
	clear
	forvalues j = 1/5 {
		* local j 1
		local depVar : word `j' of `depVars'
		local base_date : word 1 of $metoolist
		use "${intdata}rolling_`sample'_d`j'_`base_date'.dta", clear
		foreach metoo_date in `remaining_dates' {
			merge 1:1 sex using "${intdata}rolling_`sample'_d`j'_`metoo_date'.dta", nogen
		}
		reshape long me_ se_, i(sex) j(date) string
		save "${intdata}rolling_`sample'_d_`depVar'.dta", replace
	}
	
}


foreach sample in senior { 
	foreach metoo_date in $metoolist  { 
		forvalues j = 1/5 {
				erase "${intdata}rolling_`sample'_`j'_`metoo_date'.dta"
				erase "${intdata}rolling_`sample'_b`j'_`metoo_date'.dta"
				erase "${intdata}rolling_`sample'_d`j'_`metoo_date'.dta"
		}
		forvalues j = 2/5 {
			erase "${intdata}rolling_`sample'_c`j'_`metoo_date'.dta"
		}
	}
}

