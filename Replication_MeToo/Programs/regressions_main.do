

clear all

foreach sample in allaut onlyju senior {
	
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
	gen in_regression = period !=. & num_ca_paper !=. & experience_evolve !=. & degree_lag !=. & clustering_self_lag !=. & author_period_papers !=. & author_cumulative_papers !=. & wfield_1 !=.
	egen num_authors_in_sample = total(in_regression), by(unique_paper_id)
	gen inv_weight = 1/num_authors_in_sample
	gl weight [aw = inv_weight]
	
	
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

	* Loop over each dependent variable
	foreach var in `depVars' {
		if `j'==1 {
			* glm with interactons with sex
			eststo reg`j'_frac:			qui glm `var' i.metoo##i.sex i.sex##i.covid_period $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'_mef_fr:	margins, dydx(metoo) at(sex=(0 1)) post
			{			
				matrix list r(table)
				matrix m_w = r(table)
								
				gen me_w_`var' = .
				gen se_w_`var' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_w_`var' = m_w[1,`k'] if sex==`i'
					replace se_w_`var' = m_w[2,`k'] if sex==`i'
				}
			}
			
			* glm without interactions with sex
			eststo reg`j'_all:          qui glm `var' i.metoo i.sex i.covid_period $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'_mef_all:  margins, dydx(metoo) post
			{			
				matrix list r(table)
				matrix m_a = r(table)
								
				gen me_a_`var' = m_a[1,2]
				gen se_a_`var' = m_a[2,2] 
				
				preserve
				collapse me_w_`var' se_w_`var' , by(sex)
				ren me_w_`var' me_`var'
				ren se_w_`var' se_`var'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_a_`var' se_a_`var'
				duplicates drop
				ren me_a_`var' me_`var'
				ren se_a_`var' se_`var'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}`sample'_`var'.dta", replace
				restore
				drop me_w_* se_w_* me_a_* se_a_* 
			}
		}
		else if `j'!=1 {
			local relevant_share : word `j' of `list_relev_shares'
			* glm with interactons with sex
			eststo reg`j'_frac:			qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'_mef_fr:	margins, dydx(metoo) at(sex=(0 1)) post
			{			
				matrix list r(table)
				matrix m_w = r(table)
								
				gen me_w_`var' = .
				gen se_w_`var' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_w_`var' = m_w[1,`k'] if sex==`i'
					replace se_w_`var' = m_w[2,`k'] if sex==`i'
				}
			}
			
			* glm without interactions with sex
			eststo reg`j'_all:          qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'_mef_all:  margins, dydx(metoo) post
			
			{			
				matrix list r(table)
				matrix m_a = r(table)
								
				gen me_a_`var' = m_a[1,2]
				gen se_a_`var' = m_a[2,2] 
				
				preserve
				collapse me_w_`var' se_w_`var' , by(sex)
				ren me_w_`var' me_`var'
				ren se_w_`var' se_`var'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_a_`var' se_a_`var'
				duplicates drop
				ren me_a_`var' me_`var'
				ren se_a_`var' se_`var'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}`sample'_`var'.dta", replace
				restore
				drop me_w_* se_w_* me_a_* se_a_* 
			}
		}
		local j = `j' + 1
	}

	
	**--------------------------------------------------------------
	* Regressions with NEW WOMEN authors and broken down by seniority
	** Regressions (1b): New women ca
	** Regressions (2b): New senior women coauthors
	** Regressions (3b): New mid women ca
	** Regressions (4b): New junior women ca
	** Regressions (5b): New other women ca
	**--------------------------------------------------------------
	
	* Define the list of dependent variables for regressions 1–5
	local depVars "new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper"
	local list_relev_shares "share_wom share_sen_wom share_mid_wom share_jun_wom share_oth_wom"
	local list_relev_shares_b "nothing share_sen_wom_b share_mid_wom_b share_jun_wom_b share_oth_wom_b"
	
	local j = 1

	* Loop over each dependent variable
	foreach var in `depVars' {
		* Regression with weights
		*local var new_prop_paper
		local relevant_share : word `j' of `list_relev_shares'
		if `j' == 1 {
			eststo reg`j'b_frac:			qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'b_mef_fr:		margins, dydx(metoo) at(sex=(0 1)) post
			{			
				matrix list r(table)
				matrix m_w = r(table)
								
				gen me_w_`var' = .
				gen se_w_`var' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_w_`var' = m_w[1,`k'] if sex==`i'
					replace se_w_`var' = m_w[2,`k'] if sex==`i'
				}
			}
			
			* glm without interactions with sex
			eststo reg`j'b_all:             qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'b_mef_all:     margins, dydx(metoo) post
			{			
				matrix list r(table)
				matrix m_a = r(table)
								
				gen me_a_`var' = m_a[1,2]
				gen se_a_`var' = m_a[2,2] 
				
				preserve
				collapse me_w_`var' se_w_`var' , by(sex)
				ren me_w_`var' me_`var'
				ren se_w_`var' se_`var'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_a_`var' se_a_`var'
				duplicates drop
				ren me_a_`var' me_`var'
				ren se_a_`var' se_`var'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}`sample'_`var'.dta", replace
				restore
				drop me_w_* se_w_* me_a_* se_a_* 
			}
		}
		else if `j'!=1 {
			local relevant_share_b : word `j' of `list_relev_shares_b'
			eststo reg`j'b_frac:			qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'b_mef_fr:		margins, dydx(metoo) at(sex=(0 1)) post
			{			
				matrix list r(table)
				matrix m_w = r(table)
								
				gen me_w_`var' = .
				gen se_w_`var' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_w_`var' = m_w[1,`k'] if sex==`i'
					replace se_w_`var' = m_w[2,`k'] if sex==`i'
				}
			}
			
			* glm without interactions with sex
			eststo reg`j'b_all:             qui glm `var' i.metoo i.sex i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'b_mef_all:     margins, dydx(metoo) post
			{			
				matrix list r(table)
				matrix m_a = r(table)
								
				gen me_a_`var' = m_a[1,2]
				gen se_a_`var' = m_a[2,2] 
				
				preserve
				collapse me_w_`var' se_w_`var' , by(sex)
				ren me_w_`var' me_`var'
				ren se_w_`var' se_`var'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_a_`var' se_a_`var'
				duplicates drop
				ren me_a_`var' me_`var'
				ren se_a_`var' se_`var'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}`sample'_`var'.dta", replace
				restore
				drop me_w_* se_w_* me_a_* se_a_* 
			}
		}	
		local j = `j' + 1
	}


	**--------------------------------------------------------------
	*Regressions with proportions of ALL authors broken down by seniority
	** Regressions (1c): All authors (no regressions!)
	** Regressions (2c): All senior coauthors
	** Regressions (3c): All mid-career cauthors
	** Regressions (4c): All junior cauthors
	** Regressions (5c): All other coauthors
	**--------------------------------------------------------------
	
	* Define the list of dependent variables for regressions 2–5
	local depVars "sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper"
	local list_relev_shares "nothing share_sen share_mid share_jun share_oth"
	
	local j = 2

	foreach var in sen mid jun oth {
		* glm with interactons with sex
		*local var new_prop_paper
		local relevant_share : word `j' of `list_relev_shares'
		eststo reg`j'c_frac:			qui glm `var'_prop_paper i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
		eststo mar_reg`j'c_mef_fr:		margins, dydx(metoo) at(sex=(0 1)) post
		{			
			matrix list r(table)
			matrix m_w = r(table)
							
			gen me_w_`var' = .
			gen se_w_`var' = .
			forval i = 0/1 {
				local k = `i' + 3
				replace me_w_`var' = m_w[1,`k'] if sex==`i'
				replace se_w_`var' = m_w[2,`k'] if sex==`i'
			}
		}
		
		* glm without interactions with sex
		eststo reg`j'c_all: 			qui glm `var'_prop_paper i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
		eststo mar_reg`j'c_mef_all: 	margins, dydx(metoo) post
		{			
			matrix list r(table)
			matrix m_a = r(table)
							
			gen me_a_`var' = m_a[1,2]
			gen se_a_`var' = m_a[2,2] 
			
			preserve
			collapse me_w_`var' se_w_`var' , by(sex)
			ren me_w_`var' me_`var'
			ren se_w_`var' se_`var'
			tempfile frac_`var'
			save `frac_`var''
			restore
			preserve
			keep me_a_`var' se_a_`var'
			duplicates drop
			ren me_a_`var' me_`var'
			ren se_a_`var' se_`var'
			gen sex = 2
			append using `frac_`var''
			order sex
			sort sex
			
			save "${intdata}`sample'_`var'.dta", replace
			restore
			drop me_w_* se_w_* me_a_* se_a_* 
		}
			
		local j = `j' + 1
	}
	
	**--------------------------------------------------------------
	*Regressions with proportions of ALL women authors broken down by seniority
	** Regressions (1d): All women authors 
	** Regressions (2d): All senior women coauthors
	** Regressions (3d): All mid-career women cauthors
	** Regressions (4d): All junior women coauthors
	** Regressions (5d): All other women coauthors
	*--------------------------------------------------------------
	
	local depVars "women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper"
	local list_relev_shares "share_wom share_sen_wom share_mid_wom share_jun_wom share_oth_wom"
	local list_relev_shares_b "nothing share_sen_wom_b share_mid_wom_b share_jun_wom_b share_oth_wom_b"
	
	local j = 1

	* Loop over each dependent variable
	foreach var in `depVars' {
		local relevant_share : word `j' of `list_relev_shares'
		* Regression with weights
		* local j 2
		*local var sen_wom_prop_paper
		if `j' == 1 {
			eststo reg`j'd_frac:			qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'd_mef_fr:		margins, dydx(metoo) at(sex=(0 1)) post
			{			
				matrix list r(table)
				matrix m_w = r(table)
								
				gen me_w_`var' = .
				gen se_w_`var' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_w_`var' = m_w[1,`k'] if sex==`i'
					replace se_w_`var' = m_w[2,`k'] if sex==`i'
				}
			}
			
			* glm without interactions with sex
			eststo reg`j'd_all:             qui glm `var' i.metoo i.sex i.covid_period `relevant_share' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'd_mef_all:     margins, dydx(metoo) post
			{			
				matrix list r(table)
				matrix m_a = r(table)
								
				gen me_a_`var' = m_a[1,2]
				gen se_a_`var' = m_a[2,2] 
				
				preserve
				collapse me_w_`var' se_w_`var' , by(sex)
				ren me_w_`var' me_`var'
				ren se_w_`var' se_`var'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_a_`var' se_a_`var'
				duplicates drop
				ren me_a_`var' me_`var'
				ren se_a_`var' se_`var'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}`sample'_`var'.dta", replace
				restore
				drop me_w_* se_w_* me_a_* se_a_* 
			}
		}
		else if `j'!=1 {
			local relevant_share_b : word `j' of `list_relev_shares_b'
			eststo reg`j'd_frac:			qui glm `var' i.metoo##i.sex i.sex##i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'd_mef_fr:		margins, dydx(metoo) at(sex=(0 1)) post
			{			
				matrix list r(table)
				matrix m_w = r(table)
								
				gen me_w_`var' = .
				gen se_w_`var' = .
				forval i = 0/1 {
					local k = `i' + 3
					replace me_w_`var' = m_w[1,`k'] if sex==`i'
					replace se_w_`var' = m_w[2,`k'] if sex==`i'
				}
			}
			
			* glm without interactions with sex
			eststo reg`j'd_all:             qui glm `var' i.metoo i.sex i.covid_period `relevant_share' `relevant_share_b' $exper_time $network $prodty $fields [aw = inv_weight], family(binomial) link(logit) vce(cluster temp_name_orig)
			eststo mar_reg`j'd_mef_all:     margins, dydx(metoo) post
			{			
				matrix list r(table)
				matrix m_a = r(table)
								
				gen me_a_`var' = m_a[1,2]
				gen se_a_`var' = m_a[2,2] 
				
				preserve
				collapse me_w_`var' se_w_`var' , by(sex)
				ren me_w_`var' me_`var'
				ren se_w_`var' se_`var'
				tempfile frac_`var'
				save `frac_`var''
				restore
				preserve
				keep me_a_`var' se_a_`var'
				duplicates drop
				ren me_a_`var' me_`var'
				ren se_a_`var' se_`var'
				gen sex = 2
				append using `frac_`var''
				order sex
				sort sex
				
				save "${intdata}`sample'_`var'.dta", replace
				restore
				drop me_w_* se_w_* me_a_* se_a_* 
			}
		}
		local j = `j' + 1
	}

	*---------------------------------------------------------------------------*
	
	* Table with MEF of GLM of ALL COAUTHORS (2c-5c and 1d-5d)
	esttab mar_reg2c_mef_fr mar_reg3c_mef_fr mar_reg4c_mef_fr mar_reg5c_mef_fr mar_reg1d_mef_fr mar_reg2d_mef_fr mar_reg3d_mef_fr mar_reg4d_mef_fr mar_reg5d_mef_fr using "${output}tables_`sample'/`sample'_ALL_sexinteractions.csv", star(* 0.10 ** 0.05 *** 0.01) replace style(html) cells(b(fmt(4) star) se(fmt(4) par)) title("Sample `sample', marginal effects: Shares of ALL coauthors") mlabels("Senior" "Mid-career" "Junior" "Other" "Women" "Senior women" "Mid-career women" "Junior women" "Other women")

	* Table with MEF of GLM of ALL COAUTHORS, all genders (2c-5c and 1d-5d)
	esttab mar_reg2c_mef_all mar_reg3c_mef_all mar_reg4c_mef_all mar_reg5c_mef_all mar_reg1d_mef_all mar_reg2d_mef_all mar_reg3d_mef_all mar_reg4d_mef_all mar_reg5d_mef_all using "${output}tables_`sample'/`sample'_ALL.csv", star(* 0.10 ** 0.05 *** 0.01) replace style(html) cells(b(fmt(4) star) se(fmt(4) par)) title("Sample `sample', marginal effects: Shares of ALL coauthors, all genders") mlabels("Senior" "Mid-career" "Junior" "Other" "Women" "Senior women" "Mid-career women" "Junior women" "Other women")

	* Table with MEF of GLM of NEW COAUTHORS (1-5 and 1b-5b)
	esttab mar_reg1_mef_fr mar_reg2_mef_fr mar_reg3_mef_fr mar_reg4_mef_fr mar_reg5_mef_fr mar_reg1b_mef_fr mar_reg2b_mef_fr mar_reg3b_mef_fr mar_reg4b_mef_fr mar_reg5b_mef_fr using "${output}tables_`sample'/`sample'_NEW_sexinteractions.csv", star(* 0.10 ** 0.05 *** 0.01) replace style(html) cells(b(fmt(4) star) se(fmt(4) par)) title("Sample `sample', marginal effects: Shares of NEW coauthors") mlabels("New coauthors" "New senior" "New mid-career" "New junior" "New other" "New women" "New senior women" "New mid-career women" "New junior women" "New other women")

	* Table with MEF of GLM of NEW COAUTHORS, all genders (1-5 and 1b-5b)
	esttab mar_reg1_mef_all mar_reg2_mef_all mar_reg3_mef_all mar_reg4_mef_all mar_reg5_mef_all mar_reg1b_mef_all mar_reg2b_mef_all mar_reg3b_mef_all mar_reg4b_mef_all mar_reg5b_mef_all using "${output}tables_`sample'/`sample'_NEW.csv", star(* 0.10 ** 0.05 *** 0.01) replace style(html) cells(b(fmt(4) star) se(fmt(4) par)) title("Sample `sample', marginal effects: Shares of NEW coauthors, all genders") mlabels("New coauthors" "New senior" "New mid-career" "New junior" "New other" "New women" "New senior women" "New mid-career women" "New junior women" "New other women")
	
}

				
				