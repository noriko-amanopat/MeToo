/*
* To create the folders to save the output, run the following lines the first time you run the code
foreach sample in allaut onlyju senior { 
	local dir "${output}/tables_`sample'"
	mkdir "`dir'"
}
*/ 



foreach sample in allaut senior onlyju {
	
	use "${data}MeToo_author_ppr_`sample'.dta", clear
	
	preserve
	egen seq = seq(), by(unique_paper_id)
	keep if seq==1
	gen num_papers = seq
	collapse (sum) num_papers , by(seq)
	ren seq sex
	replace sex = -1
	tempfile summ_stats_table0
	save `summ_stats_table0'
	restore

	preserve
	egen seq = seq(), by(temp_name_orig)
	keep if seq==1
	gen num_authors = seq
	collapse (sum) num_authors , by(sex)
	tempfile summ_stats_table1
	save `summ_stats_table1'
	restore

	preserve
	egen seq = seq(), by(temp_name_orig)
	keep if seq==1
	gen num_authors = seq
	collapse (sum) num_authors , by(seq)
	ren seq sex
	replace sex = -1
	append using `summ_stats_table1'
	label define sexl -1 "All" 0 "Men" 1 "Women"
	label values sex sexl
	merge 1:1 sex using `summ_stats_table0', nogen
	order sex num_papers num_authors
	tempfile summ_stats_table2
	save `summ_stats_table2'
	restore

	preserve
	egen seq = seq(), by(temp_name_orig)
	* the following just takes the mean of num_ca_paper = authors per paper
	* all other variables are already at the author-period level, but this loop renames them
	foreach var of varlist degree_lag clustering_self_lag experience_evolve num_ca_paper author_period_papers author_cumulative_papers {
		by temp_name_orig , sort: egen av_`var' = mean(`var')
	}
	keep if seq==1
	collapse (mean) av_* , by(sex)
	foreach var in degree_lag clustering_self_lag experience_evolve num_ca_paper author_period_papers author_cumulative_papers {
		* local var degree_lag
		gen sav_`var' = string(av_`var', "%3.2f")
		drop av_`var'
		ren sav_`var' av_`var'
	}
	order sex *clustering_self_lag *degree_lag *experience_evolve *num_ca_paper *author_period_papers *author_cumulative_papers
	tempfile summ_stats_table3
	save `summ_stats_table3'
	restore

	preserve
	egen seq = seq(), by(temp_name_orig)
	foreach var of varlist degree_lag clustering_self_lag experience_evolve num_ca_paper author_period_papers author_cumulative_papers {
		by temp_name_orig , sort: egen av_`var' = mean(`var')
	}
	keep if seq==1
	collapse (mean) av_* , by(seq)
	ren seq sex
	replace sex = -1
	foreach var in degree_lag clustering_self_lag experience_evolve num_ca_paper author_period_papers author_cumulative_papers {
		* local var degree_lag
		gen sav_`var' = string(av_`var', "%3.2f")
		drop av_`var'
		ren sav_`var' av_`var'
	}
	order sex *clustering_self_lag *degree_lag *experience_evolve *num_ca_paper *author_period_papers *author_cumulative_papers
	append using `summ_stats_table3'
	label define sexl -1 "All" 0 "Men" 1 "Women"
	label values sex sexl
	tempfile summ_stats_table4
	save `summ_stats_table4'
	restore

	preserve
	bys temp_name_orig: egen seniorities = mode(seniority_orig), maxmode
	egen seq = seq(), by(temp_name_orig)
	gen num_authors = seq==1
	collapse (sum) num_authors , by(seniorities sex)
	replace seniorities = 9 if seniorities==-1 
	reshape wide num_authors, i(sex) j(seniorities)

	if "`sample'" == "allaut" {
		ren num_authors0 num_students
		ren num_authors1 num_junior
		ren num_authors2 num_midcareer
		ren num_authors3 num_senior
		ren num_authors9 num_unknown	
	}
	else if "`sample'" == "senior" {
		gen num_students = 0
		gen num_junior = 0
		gen num_midcareer = 0
		ren num_authors3 num_senior
		gen num_unknown  = 0
	}
	else if "`sample'" == "onlyju" {
		gen num_students = 0
		ren num_authors1 num_junior
		gen num_midcareer = 0
		gen num_senior = 0
		gen num_unknown  = 0
	}

	tempfile summ_stats_table5
	save `summ_stats_table5'
	restore


	preserve
	bys temp_name_orig: egen seniorities = mode(seniority_orig), maxmode
	egen seq = seq(), by(temp_name_orig)
	keep if seq==1
	gen num_authors = 1
	collapse (sum) num_authors , by(seniorities seq)
	ren seq sex
	replace sex = -1
	replace seniorities = 9 if seniorities==-1 
	reshape wide num_authors, i(sex) j(seniorities)
	if "`sample'" == "allaut" {
		ren num_authors0 num_students
		ren num_authors1 num_junior
		ren num_authors2 num_midcareer
		ren num_authors3 num_senior
		ren num_authors9 num_unknown	
	}
	else if "`sample'" == "senior" {
		gen num_students = 0
		gen num_junior = 0
		gen num_midcareer = 0
		ren num_authors3 num_senior
		gen num_unknown  = 0
	}
	else if "`sample'" == "onlyju" {
		gen num_students = 0
		ren num_authors1 num_junior
		gen num_midcareer = 0
		gen num_senior = 0
		gen num_unknown  = 0
	}
	append using `summ_stats_table5'
	label define sexl -1 "All" 0 "Men" 1 "Women"
	label values sex sexl
	tempfile summ_stats_table6
	save `summ_stats_table6'
	restore

	preserve
	use `summ_stats_table2', clear
	merge 1:1 sex using `summ_stats_table4', nogen
	merge 1:1 sex using `summ_stats_table6', nogen
	export excel using "${output}tables_`sample'/summstats_`sample'.xls", firstrow(variables) replace
	restore
}










