


local indices_applied "8 9 10 12 14 15 16"
local indices_macro "5 6 7"
local indices_theory "3 4" 


* Loop through each field and generate the variables
foreach field in applied macro theory {
	di "`field'"
    * Initialize the field variable
    gen `field' = 0
    
	display "`indices_`field''"
	tokenize "`indices_`field''"  
	local n: word count `indices_`field'' 
	forvalues i = 1/`n' {
		local idx : word `i' of `indices_`field''
		di `idx'
		replace `field' = `field' + wfield_`idx'
	}
	
    * Round the field variable
    replace `field' = round(`field')
    
    * Generate the author-level variable
    bys temp_name_orig: egen `field'_auth = mode(`field'), max
}

gen allfields = 1
