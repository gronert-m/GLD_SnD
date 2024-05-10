/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				PHL_2020_GLD_LFS.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group </_Author(s)_>
<_Date created_>				2024-03-08 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Philippines (PHL) </_Country_>
<_Survey Title_>				Labor Force Survey </_Survey Title_>
<_Survey Year_>					2020 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		[01/2020] </_Data collection from_>
<_Data collection to_>			[12/2020] </_Data collection to_>
<_Source of dataset_> 			Philippine Statistical Authority </_Source of dataset_>
<_Sample size (HH)_> 			 </_Sample size (HH)_>
<_Sample size (IND)_> 			 </_Sample size (IND)_>
<_Sampling method_> 			Geographic pufregions divided into PSUs of ~100-400 Households for further processing </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					[Currency used for wages] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				[Version of ICLS for Labor Questions] </_ISCED Version_>
<_ISCO Version_>				ISCO 08 </_ISCO Version_>
<_OCCUP National_>				PSOC 12 </_OCCUP National_>
<_ISIC Version_>				ISIC 4 </_ISIC Version_>
<_INDUS National_>				PSIC 2009 </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

</_Version Control_>

-------------------------------------------------------------------------*/



/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m
set varabbrev off

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD-Harmonization/510859_AS"
local country "PHL"
local year    "2020"
local survey  "LFS"
local vermast "V01"
local veralt  "V01"

* From the definitions, set path chunks
local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

* From chunks, define path_in, path_output folder
local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"


* Define Output file name
local out_file "`level_2_harm'_ALL.dta"

* Define Output file name
local out_file "`level_2_harm'_ALL.dta"

*----------1.3: Database assembly------------------------------*
* Files were originally downloaded as a set of zip files representing each survey month
* Convert each csv file into Stata, rename then append

/*
local months January April July October

tempfile master

foreach month of local months {
    local filename "LFS PUF `month' 2020"
    
	capture confirm file "`path_in_other'/`filename'.csv"
	
	if _rc==0 {
	display "`filename' exists"
    * Import the CSV file
    import delimited "`path_in_other'/`filename'.csv", clear stringcols(_all)
	
	}
	
	else {
	display "use alternative filename"
	import delimited "`path_in_other'/`filename' - HHMEM.csv", clear stringcols(_all)

	}
	capture confirm variable pufc09a_work
	if _rc == 0 {
		ren pufc09a_work pufc09a_arrangement
	}
	* Loop over all variables in the dataset
	foreach var of varlist _all {
		* Check if the variable name contains an underscore
		if strpos("`var'", "_") > 0 {
			* Extract the part of the variable name after the underscore
			local newname = substr("`var'", strpos("`var'", "_") + 1, .)
			
			capture confirm variable `newname'
        
			* If the variable exists (_rc is 0), append "1" to the new variable name
			if _rc == 0 {
				local newname = "`newname'1"
			}
			* Rename the variable to this new name
			rename `var' `newname'
		}
		* If no underscore is found, do nothing (retain the original name)
	}
	
	    
    * Append the data to a master dataset
    if "`month'" == "January" {
        * If this is the first file, simply rename it to the master dataset
        save `master'
    }
    else {
        * For subsequent files, append them to the master dataset
        append using `master'
		save `master', replace
    }

	display "`month' appended"
}

foreach var of varlist pufreg pufurb2015-pufsvyyr pufnewempstat pufrpl-wqtr{
	destring `var', replace
}

* Label the variables
* Variable: pufurb2015_vs1 - 2015Urban-RuralFIES

label variable pufurb2015 "2015Urban-RuralFIES"
label define pufurb2015lbl 1 "Urban" 2 "Rural" 
label values pufurb2015 pufurb2015lbl

* Variable: pufsvymo_vs1 - Survey Month
label variable pufsvymo "Survey Month"
label define pufsvymolbl 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August"  9 "September" 10 "October" 11 "November" 12 "December"
label values pufsvymo pufsvymolbl

* Variable: pufc01_lno_vs1 - C101-Line Number
label variable lno "C101-Line Number"

*Label definitions for 'wynot'
label variable wynot "C26-Reason for not Looking for Work"

label define wynot_lbl 0 "ECQ/Lockdown/Covid-19 Pandemic" ///
1 "Tired/Believe no Work Available" ///
2 "Awaiting Results of Previous Job Application" ///
3 "Temporary Illness/Disability" ///
4 "Bad Weather" ///
5 "Wait for rehire/Job Recall" ///
61 "Too young/old" ///
62 "Retired" ///
63 "Permanent disability" ///
7 "Household, family duties" ///
8 "Schooling" ///
9 "Others"

label values wynot wynot_lbl

label var pocc "Previous occupation"
label var procc "Present occupation"
label var pkb "Present industry"
label var qkb "Previous industry"
* Variable: sex
label variable sex "C04-Sex"
label define sex 1 "Male" 2 "Female" 
label values sex sex


* Variable: pufc06_mstat_vs1 - C06-Marital Status
label variable mstat "C06-Marital Status"
label define mstat 1 "Single" 2 "Married" 3 "Widowed" 4 "Divorce/Separate" 5 "Annulled" 6 "Unknown" 
label values mstat mstat

* Variable: pufc10_conwr_vs1 - C10-Overseas Filipino Indicator
label variable conwr "C10-Overseas Filipino Indicator"
label define conwr 1 "Overseas Contract Workers" 2 "Workers other than OCW" 3 "Employees in Philippine Embassy, Consulates & other Missions" 4 "Students abroad/Tourists" 5 "Resident" 
label values conwr conwr


* Variable: pufc11_work_vs1 - C11-Work Indicator
label variable work "C11-Work Indicator"
label define work 1 "YES" 2 "NO" 
label values work work

* Variable: pufc17_natem_vs1 - C17-Nature of Employment (Primary Occupation)
label variable natem "C17-Nature of Employment (Primary Occupation)"
label define natem 1 "Permanent Job/Business/Unpaid Family Work" 2 "Short-Term/Seasonal Job/Business/Unpaid Family Work" 3 "Worked for Different Employers on Day to Day or Week to Week Basis" 
label values natem natem

* Variable: pufc12_job_vs1 - C12-Job Indicator
label variable job "C12-Job Indicator"
label define job 1 "yes" 2 "no" 3 "no, temporarily" 
label values job job

* Variable: pufc20_pwmore_vs1 - C20-Want More Hours of Work
label variable pwmore "C20-Want More Hours of Work"
label define pwmore 1 "yes" 2 "no" 
label values pwmore pwmore

* Variable: pufc21_pladdw_vs1 - C21-Look for Additional Work
label variable pladdw "C21-Look for Additional Work"
label define pladdw 1 "yes" 2 "no" 
label values pladdw pladdw

* Variable: pufc08_cursch_vs1 - C08-Currently Attending School
label variable cursch "C08-Currently Attending School"
label define cursch 1 "yes" 2 "no" 
label values cursch cursch

* Variable: pufc09_gradtech_vs1 - C09-Graduate of technical/vocational course
label variable gradtech "C09-Graduate of technical/vocational course"
label define gradtech 1 "yes" 2 "no" 
label values gradtech gradtech

* Variable: pufc09a_nformal_vs1 - C09a - Currently Attending Non-formal Training for Skills Development
label variable nformal "C09a - Currently Attending Non-formal Training for Skills Development"
label define nformal 1 "Yes" 2 "No" 
label values nformal nformal

* Label definitions for 'wwm48h'
label variable wwm48h "C29-Reasons for Working More than 48 Hours during the past week"

label define wwm48h_lbl 11 "Wanted more earnings" ///
12 "Requirements of the job" ///
13 "Exceptional week" ///
14 "Ambition, passion for job" ///
15 "ECQ/Lockdown/Covid-19 Pandemic" ///
19 "Other reasons" ///
20 "Variable working time / nature of work" ///
21 "Holidays" ///
22 "Poor business condition" ///
23 "Reduction in clients / work" ///
24 "Low or off season" ///
25 "Bad weather, natural disaster" ///
26 "Strike or labour dispute" ///
27 "Start / end / change of job" ///
28 "Could only find part time work" ///
29 "School training" ///
30 "Personal / family reasons" ///
31 "Health / medical limitations" ///
32 "ECQ/Lockdown/Covid-19 Pandemic" ///
39 "Other reasons, specify"

label values wwm48h wwm48h_lbl

* Variable: pufc22_pfwrk_vs1 - C22-First Time to Work
label variable pfwrk "C22-First Time to Work"
label define pfwrk 1 "yes" 2 "no" 
label values pfwrk pfwrk

* Variable: pufc19_phours_vs3 - Total Hours Worked
label variable phours "Total Hours Worked in the past week"

* Variable: pufc23_pclass_vs1 - C23-Class of Worker (Primary Occupation)
label variable pclass "C23-Class of Worker (Primary Occupation)"
label define pclass 0 "Private Household" 1 "Private Establishment" 2 "Gov't/Gov't Corporation" 3 "Self Employed" 4 "Employer" 5 "With pay (Family owned Business)" 6 "Without Pay (Family owned Business)" 
label values pclass pclass

* Variable: pufc26_ojob_vs1 - C26-Other Job Indicator
label variable ojob "C26-Other Job Indicator"
label define ojob 1 "Yes" 2 "No" 
label values ojob ojob

* Variable: pufc24_pbasis_vs1 - C24-Basis of Payment (Primary Occupation)
label variable pbasis "C24-Basis of Payment (Primary Occupation)"
label define pbasis 0 "In Kind only" 1 "Per piece" 2 "Per Hour" 3 "Per Day" 4 "Monthly" 5 "Pakyaw" 6 "Other S./Wages" 7 "Not salaries/wages(Commission Basis)" 
label values pbasis pbasis

* Variable: pufc30_lookw_vs1 - C30-Looked for Work or Tried to Establish Business during the past week
label variable lookw "C30-Looked for Work or Tried to Establish Business during the past week"
label define lookw 1 "yes" 2 "no" 
label values lookw lookw

* Variable: pufc36_avail_vs1 - C36-Available for Work
label variable avail "C36-Available for Work"
label define avail 1 "yes available" 2 "not available" 
label values avail avail

* Variable: pufc38_prevjob_vs1 - C38-Previous Job Indicator
label variable prevjob "C38-Previous Job Indicator"
label define prevjob 1 "yes" 2 "no" 
label values prevjob pufc38_prevjob_vs1_lbl

* Variable: pufnewempstat_vs1 - New Employment Criteria (jul 05, 2005)
label variable pufnewempstat "New Employment Criteria (jul 05, 2005)"
label define pufnewempstat 1 "EMPLOYED" 2 "UNEMPLOYED" 3 "NOT IN THE LABOR FORCE" 
label values pufnewempstat pufnewempstat

* Variable: pufc35_ltlookw_vs1 - C35-When Last Looked for Work
label variable ltlookw "C35-When Last Looked for Work"
label define ltlookw 1 "Within last month" 2 "One to six months ago" 3 "More than six months ago" 
label values ltlookw ltlookw

* Variable: pufc37_willing_vs1 - C37-Willingness to take up work during the past week or withing two weeks
label variable willing "C37-Willingness to take up work during the past week or withing two weeks"
label define willing 1 "yes" 2 "no" 
label values willing willing

* Variable: pufc27_njobs_vs1 - C27-Number of Jobs during the past week
label variable njobs "C27-Number of Jobs during the past week"
label define njobs 0 "valid" 
label values njobs njobs

* Variable: pufc28_thours_vs1 - C28-Total Hours Worked for all Jobs
label variable thours "C28-Total Hours Worked for all Jobs"

* Variable: pufc31_flwrk_vs1 - C31-First Time to Look for Work
label variable flwrk "C31-First Time to Look for Work"
label define ftwork1 1 "yes" 2 "no" 
label values flwrk ftwork1

* Variable: pufc32_jobsm_vs1 - C32-Job Search Method
label variable jobsm "C32-Job Search Method"
label define jobsm 1 "registered in public employment agency" 2 "registered in private employment agency" 3 "approached employer directly" 4 "approached relatives or friends" 5 "placed or answered advertisements" 6 "others" 
label values jobsm jobsm

* Variable: weeks - Number of Weeks Looking for Work
label variable weeks "Number of Weeks Looking for Work"
label define weeks 1 "less than 4" 4 "4  to  9" 10 "10 to 19" 20 "20 and over" 
label values weeks weeks

* Region
label variable pufreg "Region"

label define pufreg_lbl 1 "Region I (Ilocos Region)" ///
2 "Region II (Cagayan Valley)" 3 "Region III (Central Luzon)" ///
4 "Region IV-A (CALABARZON)" 5 "Region V (Bicol Region)" ///
6 "Region VI (Western Visayas)" 7 "Region VII (Central Visayas)" ///
8 "Region VIII (Eastern Visayas)" 9 "Region IX (Zamboanga Peninsula)" ///
10 "Region X (Northern Mindanao)" 11 "Region XI (Davao Region)" ///
12 "Region XII (SOCCSKSARGEN)" 13 "National Capital Region (NCR)" ///
14 "Cordillera Administrative Region (CAR)" 15 "Autonomous Region in Muslim Mindanao (ARMM)" ///
16 "Region XIII (Caraga)" 17 "MIMAROPA Region"

label values pufreg pufreg_lbl

* Label definitions for 'rel'
label variable rel "C03-Relationship to Household Head"
label define rel_lbl 1 "Head" 2 "Wife/Spouse" 3 "Son/daughter" ///
4 "Brothers/sisters" 5 "Son/daughter_law" 6 "Grandchildren" ///
7 "Father/Mother" 8 "Other Relative" 9 "Boarder" 10 "Domestic Helper" ///
11 "Non_Relative"
label values rel rel_lbl


save "`path_in_stata'/PHL_LFS_2020.dta", replace
*/

* Variable label for 'pufreg'
* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file
*/
use "`path_in_stata'/PHL_LFS_2020.dta", clear

* Note, this incldues overseas filipino workers -- explains missing lstatus values

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "PHL"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "LFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	* there is "year" which represents year of last employment. Not a GLD vble anyway
	gen year = 2020
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year= 2020
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = pufsvymo
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.

</_hhid_note> */
	gen month_string = string(pufsvymo, "%02.0f")
	egen hhid = concat(pufpsu pufhhnum month_string)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
* There is re-use in line number within the household. Sort this out
	gen neg_age = - age
	sort hhid rel neg_age sex
	
	bys hhid: gen lno_alt = _n
	gen string_lno_alt = string(lno_alt, "%02.0f")

	gen  pid = hhid + string_lno_alt
	isid pid
	
	drop neg_age lno_alt string_lno_alt
	label var pid "Individual ID"
*</_pid_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen weight_q = pufpwgtprv
	replace weight_q = . if !inlist(int_month, 1, 4, 7, 10)
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_weight_>
	gen weight = pufpwgtprv/4
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu = pufpsu
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = .
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = .
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	gen panel = ""
	label var panel "Panel individual belongs to"
*</_panel_>


*<_visit_no_>
	gen visit_no = .
	label var visit_no "Visit number in panel"
*</_visit_no_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban = (pufurb2015 == 1)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>

	gen byte subnatid1_temp = pufreg
	* Calarbazon is 41 in some quarters, 4 in others
	replace subnatid1_temp = 41 if pufreg == 4
	* Mimarropa is 42 in some quarters, 17 in others
	replace subnatid1_temp = 42 if pufreg == 17
	
	* Use codes same as 2019
	label de 		lblsubnatid1 	///
					 1   "01 - Ilocos"			///
					 2	 "02 - Cagayan Valley"	///
					 3   "03 - Central Luzon"	///
	 						/// Southern Tagalog has been split into Calabarzon and Mimaropa
					 5   "05 - Bicol"			///
					 6	 "06 - Western Visayas"	///
					 7   "07 - Central Visayas"	///
					 8	 "08 - Eastern Visayas"	///
					 9   "09 - Zamboanga Peninsula"	///
					 10  "10 - Northern Mindanao"	///
					 11  "11 - Davao"	///
					 12  "12 - Soccsksargen"		///
					 13  "13 - National Capital pufregion"				///
					 14  "14 - Cordillera Administrative pufregion"		///
					 15  "15 - Autonomous pufregion of Muslim Mindanao"	///
					 16  "16 - Caraga" ///
					 /// value 17 exists only in raw data, not in recoded version
					 18  "18 - Negros Island pufregion" /// this pufregion appears occasionally in data
				 	 							///
				 	 41	 "41 - Calabarzon"	/// formerly part of Southern Tagalog
				 	 42  "42 - Mimaropa"		// formerly part of Southern Tagalog

	label values 	subnatid1_temp lblsubnatid1
	sdecode subnatid1_temp, gen(subnatid1)

	label var 		subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>



*<_subnatid2_>
* No province information
	gen str subnatid2 = ""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen str subnatidsurvey = subnatid1
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.

</_subnatid1_prev_note> */
	gen subnatid1_prev = .
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	gen subnatid2_prev = .
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	gen subnatid3_prev = .
	label var subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>


*<_gaul_adm1_code_>
	gen gaul_adm1_code = .
	label var gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gaul_adm1_code_>


*<_gaul_adm2_code_>
	gen gaul_adm2_code = .
	label var gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
*</_gaul_adm2_code_>


*<_gaul_adm3_code_>
	gen gaul_adm3_code = .
	label var gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gaul_adm3_code_>

}


/*%%=============================================================================================
	4: Demography
==============================================================================================%%*/

{

*<_hsize_>
	sort hhid
	by hhid: egen hsize= count(rel <= 8 | rel == 11) // includes non-family members, not boarders or domestic workers.
	label var 	hsize "Household size"

	* check
	qui mdesc 	hsize
	assert 		r(miss) == 0

*</_hsize_>

*<_age_>
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = (sex == 1)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = rel
	recode relationharm (4 5 6 8 = 5) (7 = 4) (9 10 11 = 6)
	
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = rel
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = mstat
	recode marital (1 = 2) (2 = 1) (3 = 5) (4 5 = 4) (6 = .)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values comm_dsablty dsablty
	label var comm_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
==============================================================================================%%*/


{

*<_migrated_mod_age_>
	gen migrated_mod_age = .
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = .
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = .
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = .
	*label de lblmigrated_from_code
	*label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = .
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
==============================================================================================%%*/


{

*<_ed_mod_age_>

/* <_ed_mod_age_note>

Education module is only asked to those 5 and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 5
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school= cursch
	recode school (2 = 0) (3 4 = .)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	/*Please refer to the "Education_Levels.md" for a detailed discussion on classificition of how each level is classified and why,
		available in github repository. */

	gen byte educat7=.
	replace educat7 = 1 if grade <= 2000 		// less than primary to "no education"
	replace educat7 = 2 if inrange(grade, 10000, 10018)
	replace educat7 = 3 if inrange(grade, 10020, 24002)
	replace educat7 = 4 if inrange(grade, 24010, 24015)
	replace educat7 = 5 if inrange(grade, 24020, 35013)
	replace educat7 = 6 if inrange(grade, 40000, 59999)
	replace educat7 = 7 if inrange(grade, 60000, 99999)

	* for 2019, replace educat7 == missing if the rounds/month is July or October.
	* this is because there is not enough information for these rounds, which differ from the first two.
	replace educat7=.	if pufsvymo == 7 | pufsvymo == 10 		// if july or october

	label var educat7 "Level of education 1"
	la de lbleducat7 	1 "No education" ///
						2 "Primary incomplete" ///
						3 "Primary complete" ///
						4 "Secondary incomplete" ///
						5 "Secondary complete" ///
						6 "Higher than secondary but not university" ///
						7 "University incomplete or complete"
	label values educat7 lbleducat7
	replace educat7=. if age < ed_mod_age // restrict universe to students at or above primary school age

*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4) (6 7=5)
	label var educat5 "Level of education 2"
	la de lbleducat5 	1 "No education" ///
						2 "Primary incomplete"  ///
						3 "Primary complete but secondary incomplete" ///
						4 "Secondary complete" ///
						5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
	replace educat5=. if age < ed_mod_age // restrict universe to students at or above primary school age
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
	replace educat4=. if age < ed_mod_age // restrict universe to students at or above primary school age
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = grade
	label var educat_orig "Original survey education code"
*</_educat_orig_>




*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var "school literacy educy educat7 educat5 educat4 educat_isced"
foreach v of local ed_var {
	replace `v'=. if ( age < ed_mod_age & !missing(age) )
}

*</_% Correction min age_>


}

/*%%=============================================================================================
	7: Training
==============================================================================================%%*/


{

*<_vocational_>
	gen vocational = (gradtech == 1)
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	gen vocational_length_l = .
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u = .
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	gen str vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	gen vocational_financed = .
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/



*<_minlaborage_>
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>



*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte 		lstatus = pufnewempstat
	replace 		lstatus = . if age < minlaborage
	label var 		lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF" // raw values always same as new
	label values 	lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte 		potential_lf = 0

	replace 		potential_lf = 1 if (avail == 1 & lookw == 2) ///
										| (avail == 2 & lookw == 1)
	replace 		potential_lf = . if age < minlaborage & age != .
	replace 		potential_lf = . if lstatus != 3
	label var 		potential_lf "Potential labour force status"
	la de 			lblpotential_lf 0 "No" 1 "Yes"
	label values 	potential_lf lblpotential_lf
*</_potential_lf_>

*<_underemployment_>
	gen byte 		underemployment = 0

	replace 		underemployment = 1 if pwmore == 1
	replace 		underemployment = . if age < minlaborage & age != .
	replace 		underemployment = . if lstatus != 1
	label var 		underemployment "Underemployment status"
	la de 			lblunderemployment 0 "No" 1 "Yes"
	label values 	underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte 		nlfreason= .
	replace 		nlfreason=1 	if wynot==8
	replace 		nlfreason=2 	if wynot==7
	replace 		nlfreason=3 	if wynot==62
	replace 		nlfreason=4 	if wynot==3 | wynot == 63
	replace 		nlfreason=5 	if wynot==1 | wynot==2 | wynot==4 | wynot==5 | wynot==9 | wynot == 0 | wynot == 61
	replace 		nlfreason=. 	if lstatus!=3 		// restricts universe to non-labor force
	label var 		nlfreason "Reason not in the labor force"
	la de 			lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values 	nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte 		unempldur_l=weeks/4.3
	label var 		unempldur_l "Unemployment duration (months) lower bracket"
	replace 		unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only

*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u= unempldur_l
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte 		empstat=.
	replace 		empstat=1 	if pclass==0 | pclass==1 | pclass==2 | pclass==5
	replace 		empstat=2 	if pclass==6
	replace 		empstat=3	if pclass==4
	replace 		empstat=4 	if pclass==3
	replace 		empstat=. 	if lstatus!=1 	// includes universe restriction
	label var 		empstat 	"Employment status during past week primary job 7 day recall"
	la de 			lblempstat 	1 "Paid employee" ///
								2 "Non-paid employee" ///
								3 "Employer" ///
								4 "Self-employed" ///
								5 "Other, workers not classifiable by status"
	label values 	empstat lblempstat
*</_empstat_>



*<_ocusec_>
	gen byte 		ocusec = .
	replace 		ocusec = 1 	if pclass == 2
	replace 		ocusec = 2 	if inlist(pclass, 0, 1, 3, 4, 5, 6)

	label var 		ocusec 		"Sector of activity primary job 7 day recall"
	la de 			lblocusec 	1 "Public Sector, Central Government, Army" ///
								2 "Private, NGO" ///
								3 "State owned" ///
								4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = pkb
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	* PSIC seems consistent with ISIC 4 at the two digit level
	gen industrycat_isic = string(pkb, "%02.0f") if !missing(pkb)
	replace industrycat_isic = industrycat_isic + "00" if !missing(pkb)
	label var 	industrycat_isic "ISIC code of primary job 7 day recall"
	*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10=.

	replace 	industrycat10=1 if (pkb>=1 & pkb<=4)		// to Agriculture
	replace 	industrycat10=2 if (pkb>=5 & pkb<=9)		// to Mining
	replace 	industrycat10=3 if (pkb>=10 & pkb<=33)	// to Manufacturing
	replace 	industrycat10=4 if (pkb>=35 & pkb<=39)	// to Public utility
	replace 	industrycat10=5 if (pkb>=41 &  pkb<=43)	// to Construction
	replace 	industrycat10=6 if (pkb>=45 & pkb<=47) | (pkb>=55 & pkb<=56)	// to Commerce
	replace 	industrycat10=7 if (pkb>=49 & pkb<=53) | (pkb>=58 & pkb<=63) // to Transport/coms
	replace 	industrycat10=8 if (pkb>=64 & pkb<=82) 	// to financial/business services
	replace 	industrycat10=9 if (pkb==84) 				// to public administration
	replace 	industrycat10=10 if  (pkb>=91 & pkb<=99) // to other
	replace 	industrycat10=10 if industrycat10==. & pkb!=.


	label var 		industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de 			lblindustrycat10 	///
					1 "Agriculture" 	2 "Mining" ///
					3 "Manufacturing"	4 "Public utilities" ///
					5 "Construction"  	6 "Commerce" ///
					7 "Transport and Comnunications" ///
					8 "Financial and Business Services" ///
					9 "Public Administration" ///
					10 "Other Services, Unspecified"
	label values 	industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>



*<_occup_orig_>
	gen 			occup_orig = procc
	label var 		occup_orig "Original occupation record primary job 7 day recall"
	replace 		occup_orig=. if lstatus!=1 			// restrict universe to employed only
	replace 		occup_orig=. if age < minlaborage	// restrict universe to working age
*</_occup_orig_>


*<_occup_isco_>
* This is consistent with ISCO 08 at the two digits
	gen occup_isco = string(procc, "%02.0f") if !missing(procc)
	replace occup_isco = occup_isco + "00" if !missing(procc)
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup=floor(procc/10)							// this handles most of recoding automatically.
	recode occup 0 = 10	if 	(procc >=1 & procc <=3)	// recode "armed forces" to appropriate label


	label var 		occup "1 digit occupational classification, primary job 7 day recall"
	la de 			lbloccup 	///
					1 "Managers" 	2 "Professionals" ///
					3 "Technicians" 4 "Clerks" ///
					5 "Service and market sales workers" ///
					6 "Skilled agricultural" ///
					7 "Craft workers" ///
					8 "Machine operators" ///
					9 "Elementary occupations" ///
					10 "Armed forces"  ///
					99 "Others"

	label values 	occup lbloccup
	replace 		occup=. if lstatus!=1 		// restrict universe to employed only
	replace 		occup=. if age < minlaborage	// restrict universe to working age
*</_occup_>



*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen = pbasic
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

	gen byte unitwage = 1
	replace unitwage = . if lstatus!=1
	
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>

*<_whours_>
	gen whours 		= phours
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */
	gen wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = .
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = .
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = .
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = .
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = .
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u= .
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = .
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = .
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = .
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = .
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = ""
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2 = .
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
	gen double wage_no_compen_2 = .
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = .
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = .
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = .
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen t_hours_others = .
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen t_wage_nocompen_others = .
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	gen t_hours_total = .
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = .
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen byte lstatus_year = .
	replace lstatus_year=. if age < minlaborage & age != .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	replace potential_lf_year=. if age < minlaborage & age != .
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = . if age < minlaborage & age != .
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte nlfreason_year=.
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year=.
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year=.
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year = .
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = .
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = .

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic_year)
	*int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 

	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year=industrycat10_year
	recode industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = .
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = ""

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco_year)
	*int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore

	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen byte occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_> --- this var has the same name as other and when quoted in the keep and order codes is repeated.
	gen double wage_no_compen_year = .
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte unitwage_year = .
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen whours_year = .
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen wmonths_year = .
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen wage_total_year = .
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen byte contract_year = .
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen byte healthins_year = .
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen byte socialsec_year = .
	label var socialsec_year "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social secturity"
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen byte union_year = .
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen firmsize_u_year = .
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen byte empstat_2_year = .
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>



*<_industry_orig_2_year_>
	gen industry_orig_2_year = .
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = .
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte industrycat10_2_year = .
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen occup_isco_2_year = ""
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen byte occup_2_year = .
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	gen double wage_no_compen_2_year = .
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen byte unitwage_2_year = .
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen whours_2_year = .
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen wmonths_2_year = .
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen wage_total_2_year = .
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = .
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen t_hours_others_year = .
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year = .
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen t_wage_others_year = .
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen t_hours_total_year = .
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year = .
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year = .
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = .
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = t_wage_total_year
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_var "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach v of local lab_var {
		cap confirm numeric variable `v'
		if _rc == 0 { // is indeed numeric
			replace `v'=. if ( age < minlaborage & !missing(age) )
		}
		else { // is not
			replace `v'= "" if ( age < minlaborage & !missing(age) )
		}

	}

*</_% Correction min age_>
}


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight_m weight_q weight psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight_m weight_q weight psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% ORDER VARIABLES_>

*<_% DROP UNUSED LABELS_>

	* Store all labels in data
	label dir
	local all_lab `r(names)'

	* Store all variables with a label, extract value label names
	local used_lab = ""
	ds, has(vallabel)

	local labelled_vars `r(varlist)'

	foreach varName of local labelled_vars {
		local y : value label `varName'
		local used_lab `"`used_lab' `y'"'
	}

	* Compare lists, `notused' is list of labels in directory but not used in final variables
	local notused 		: list all_lab - used_lab 		// local `notused' defines value labs not in remaining vars
	local notused_len 	: list sizeof notused 			// store size of local

	* drop labels if the length of the notused vector is 1 or greater, otherwise nothing to drop
	if `notused_len' >= 1 {
		label drop `notused'
	}
	else {
		di "There are no unused labels to drop. No value labels dropped."
	}


*</_% DROP UNUSED LABELS_>

}


*<_% DELETE MISSING VARIABLES_>

quietly: describe, varlist
local kept_vars `r(varlist)'

foreach var of local kept_vars {
   capture assert missing(`var')
   if !_rc drop `var'
}

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>