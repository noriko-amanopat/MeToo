/*------------------------------------------------------------------------------
 Date created: Mar 13, 2025
 Author: Noriko Amano-Pati\~{n}o
 
 Notes: This code runs the relevant do-files for the paper 
		Economics Coauthorships in the Aftermath of MeToo
		by Noriko Amano-Patiño, Elisa Faraglia, Chryssi Giannitsarou
------------------------------------------------------------------------------*/

* Choose a location to save all files related to the paper
global project_dir "/{choose the correct path here}/Replication_MeToo/"
/*
* To create the folders to save the output from codes below, run the following loop the first time you run the code to create the folders tables_`sample' in the output file
foreach folder in Tables Figures TempOuput_Regressions { 
	local dir "${project_dir}/`folder'"
	mkdir "`dir'"
}
*/ 

global programs    "${project_dir}Programs/"
global data 	   "${project_dir}Data/"
global output      "${project_dir}Tables/"
global figures     "${project_dir}Figures/"
global intdata     "${project_dir}TempOuput_Regressions/"

*------------------------------------------------------------------------------*
* Constructing the data
*------------------------------------------------------------------------------*

* This do file takes the whole sample for each cutoff and period definitions and creates the three types of samples, all, senior, and junior authors
do "${programs}create_subsamples.do"
* Inputs:  - ${data}MeToo_author_ppr.dta
* Outputs: + ${data}MeToo_author_ppr_allaut.dta
*          + ${data}MeToo_author_ppr_senior.dta
*          + ${data}MeToo_author_ppr_onlyju.dta

*-----------------------------------------------------------------------------*
* Summary statistics
*-----------------------------------------------------------------------------*

/*
* To create the folders to save the output from codes below, run the following loop the first time you run the code to create the folders tables_`sample' in the output file
foreach sample in allaut onlyju senior { 
	local dir "${output}tables_`sample'"
	mkdir "`dir'"
}
*/ 

* This do-file creates tables with summary statistics for Table 1
do "${programs}summstats_table.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
* Outputs: + ${output}tables_`sample'/summstats_`sample'.xls

* This do-file creates tables with summary statistics for Table 1
do "${programs}summstats_pprlevel.do"
* Inputs:  - ${data}MeToo_ppr_level.dta
* Outputs: + Figures B.1 and B.2
*          + Figures 2 and 3
*          + Figures B.3 and B.4
*          + Figure B.1

* this do-file does Figure 1
do "${programs}google_trends.do"
* Inputs:  - ${data}external/MeToo_USgoogletrends.csv
*          - ${data}external/MeToo_worldgoogletrends.csv
* Outputs: + ${figures}google_trends.png

*-----------------------------------------------------------------------------*
* Analysis
*-----------------------------------------------------------------------------*


**# Main
* This code runs the main regressions in the paper (specification (2)), saves the coefficients and SEs in dta's for each sample and each dep variable. It also exports the estimate tables for each sample which can be used to construct tables 2 (ALL) and 3 (NEW).
do "${programs}regressions_main.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
* Outputs: + ${intdata}`sample'_`var'.dta where sample = allaut onlyju senior
*            var = new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper
*                  new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper
*                  sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper
*                  women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper
*          + ${output}tables_`sample'/`sample'_ALL_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_ALL.csv
*          + ${output}tables_`sample'/`sample'_NEW_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_NEW.csv

* This code constructs the 3 panels of Figure 4
do "${programs}figures_main.do"
* Inputs:  - ${intdata}allaut_women_prop_paper.dta
*          - ${intdata}onlyju_jun_wom_prop_paper.dta
*          - ${intdata}senior_sen_wom_prop_paper.dta
*          - ${intdata}onlyju_sen.dta
*          - ${intdata}onlyju_sen_wom_prop_paper.dta
*          - ${intdata}senior_jun.dta
*          - ${intdata}senior_jun_wom_prop_paper.dta
*          - ${intdata}allaut_new_prop_paper.dta
*          - ${intdata}onlyju_new_sen_prop_paper.dta
*          - ${intdata}senior_new_jun_prop_paper.dta
* Outputs: + ${figures}figure1_main.svg
*          + ${figures}figure2_main.svg
*          + ${figures}figure3_main.svg



**# By outlet
* This code estimates specification (2) separately by outlet, saves the coefficients and SEs in dta's for each sample and each dep variable. It also exports the estimate tables for each sample which can be used to construct tables D.1, D.3 (ALL) and D.2, D.4 (NEW).
do "${programs}regressions_outlet.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
* Outputs: + ${intdata}`sample'_`inst'_`var'.dta where sample = allaut onlyju senior, inst = nber, cepr
*            var = new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper
*                  new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper
*                  sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper
*                  women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper
*          + ${output}tables_`sample'/`sample'_`inst'_ALL_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_`inst'_ALL.csv
*          + ${output}tables_`sample'/`sample'_`inst'_NEW_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_`inst'_NEW.csv


* This code constructs the 3 panels of Figure 5
do "${programs}figures_outlet.do"
* Inputs:  - ${intdata}allaut_`inst'_women_prop_paper.dta
*          - ${intdata}onlyju_`inst'_jun_wom_prop_paper.dta
*          - ${intdata}senior_`inst'_sen_wom_prop_paper.dta
*          - ${intdata}onlyju_`inst'_sen.dta
*          - ${intdata}onlyju_`inst'_sen_wom_prop_paper.dta
*          - ${intdata}senior_`inst'_jun.dta
*          - ${intdata}senior_`inst'_jun_wom_prop_paper.dta
*          - ${intdata}allaut_`inst'_new_prop_paper.dta
*          - ${intdata}onlyju_`inst'_new_sen_prop_paper.dta
*          - ${intdata}senior_`inst'_new_jun_prop_paper.dta
* Outputs: + ${figures}figure1_outlets.svg
*          + ${figures}figure2_outlets.svg
*          + ${figures}figure3_outlets.svg
* inst = nber, cepr


**# By research group
* This code estimates specification (2) separately by outlet, saves the coefficients and SEs in dta's for each sample and each dep variable. It also exports the estimate tables for each sample which can be used to construct tables D.1, D.3 (ALL) and D.2, D.4 (NEW).
do "${programs}regressions_fields.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
* Outputs: + ${intdata}`sample'_`field'_`var'.dta where sample = allaut onlyju senior, field = allfields applied_auth macro_auth theory_auth
*            var = new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper
*                  new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper
*                  sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper
*                  women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper
*          + ${output}tables_`sample'/`sample'_`field'_ALL_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_`field'_ALL.csv
*          + ${output}tables_`sample'/`sample'_`field'_NEW_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_`field'_NEW.csv
* The code runs ${programs}define_fieldgps.do

* This code constructs the 3 panels of Figure D.1
do "${programs}figures_fields.do"
* Inputs:  - ${intdata}allaut_`field'_women_prop_paper.dta
*          - ${intdata}onlyju_`field'_jun_wom_prop_paper.dta
*          - ${intdata}senior_`field'_sen_wom_prop_paper.dta
*          - ${intdata}onlyju_`field'_sen.dta
*          - ${intdata}onlyju_`field'_sen_wom_prop_paper.dta
*          - ${intdata}senior_`field'_jun.dta
*          - ${intdata}senior_`field'_jun_wom_prop_paper.dta
*          - ${intdata}allaut_`field'_new_prop_paper.dta
*          - ${intdata}onlyju_`field'_new_sen_prop_paper.dta
*          - ${intdata}senior_`field'_new_jun_prop_paper.dta
* Outputs: + ${figures}figure1_fields.svg
*          + ${figures}figure2_fields.svg
*          + ${figures}figure3_fields.svg
* field = applied_auth macro_auth theory_auth


**# Excluding fast papers or slower papers
* This code estimates specification (2) excluding faster or slower papers, saves the coefficients and SEs in dta's for each sample and each dep variable. It also exports the estimate tables for each sample which can be used to construct tables C.3, C.5 (ALL) and C.4, C.6 (NEW).
do "${programs}regressions_pprspeeds.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
*          - ${data}pprs_speed_classification.dta <-- these data are merged in to classify papers' speed
* Outputs: + ${intdata}`sample'_`subsample'_`var'.dta where sample = allaut onlyju senior, field = allfields applied_auth macro_auth theory_auth
*            var = new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper
*                  new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper
*                  sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper
*                  women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper
*          + ${output}tables_`sample'/`sample'_`subsample'_ALL_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_`subsample'_ALL.csv
*          + ${output}tables_`sample'/`sample'_`subsample'_NEW_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_`subsample'_NEW.csv
* The code runs ${programs}define_fieldgps.do

* No figures are made with the coefficients of these regressions

**# Changing the starting date of the MeToo movement in 3 month intervals 
* This code estimates specification (2) changing the starting date of MeToo. It saves the coefficients and SEs in dta's for each sample and each dep variable. 
do "${programs}regressions_chnging_metoo_date.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
* Outputs: + ${intdata}rolling_`sample'_c_`depVar'.dta where sample = allaut onlyju senior, 
*            var = new_prop_paper new_sen_prop_paper new_mid_prop_paper new_jun_prop_paper new_oth_prop_paper
*                  new_wom_prop_paper new_wom_sen_prop_paper new_wom_mid_prop_paper new_wom_jun_prop_paper new_wom_oth_prop_paper
*                  sen_prop_paper mid_prop_paper jun_prop_paper oth_prop_paper
*                  women_prop_paper sen_wom_prop_paper mid_wom_prop_paper jun_wom_prop_paper oth_wom_prop_paper
*          
* Intermediary files are deleted in lines 580-end

* This code plots Figure C.1
do "${programs}figures_chnging_metoo_date.do"
* Inputs:  - ${intdata}rolling_senior_c_jun_prop_paper.dta
*          - ${intdata}rolling_senior_new_jun_prop_paper.dta
*          - ${intdata}rolling_senior_d_jun_wom_prop_paper.dta
*          - ${intdata}rolling_senior_b_new_wom_jun_prop_paper.dta
* Outputs: + ${figures}rolling_senior_jun_newjun_3m.png
*          + ${figures}rolling_senior_junwom_newjunwom_3m.png


**# Changing the start and end date of the MeToo movement to an uneventful period
* This code estimates specification (2) changing the starting date of MeToo. It exports the estimate tables for each sample which can be used to construct tables C.1 (ALL) and C.2 (NEW).
do "${programs}regressions_placebo_dates.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
* Outputs: + ${output}tables_`sample'/`sample'_placebo_ALL_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_placebo_ALL.csv
*          + ${output}tables_`sample'/`sample'_placebo_NEW_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_placebo_NEW.csv



**# Using simple OLS
* This code estimates specification (2) but using OLS. It exports the estimate tables for each sample which can be used to construct tables C.1 (ALL) and C.2 (NEW).
do "${programs}regressions_ols.do"
* Inputs:  - ${data}MeToo_author_ppr_`sample'.dta
*          - ${data}MeToo_ppr_level.dta <-- this is the input for ${programs}define_relevant_shares.do, called before running regressions
* Outputs: + ${output}tables_`sample'/`sample'_ols_ALL_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_ols_ALL.csv
*          + ${output}tables_`sample'/`sample'_ols_NEW_sexinteractions.csv
*          + ${output}tables_`sample'/`sample'_ols_NEW.csv






















