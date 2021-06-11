/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	PHILIPPINES
** COUNTRY ISO CODE	PHL
** YEAR	2016
** SURVEY NAME	Labor Force Survey
** SURVEY AGENCY	National Statistical Office
** SURVEY SOURCE	EAP Manilla Team
** UNIT OF ANALYSIS	Household and Individual
** INPUT DATABASES	LFS JAN2016
** RESPONSIBLE	Arianna Zapanta + Tom Mosher
** Created	4/4/2012
** Modified	24/5/2021
** NUMBER OF HOUSEHOLDS	39273
** NUMBER OF INDIVIDUALS	202738
** EXPANDED POPULATION	70741993
** NUMBER OF SURVEY ROUNDS: 4
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close
	clear
	set more off
	set mem 800m

** DIRECTORY

	local 	cty3 	"PHL" 	// set this to the three letter country/economy abbreviation
	local 	usr		`"551206_TM"' // set this to whatever Mario named your folder
	local 	surv_yr `"2016"'	// set this to the survey year

** RUN SETTINGS
	local 	cb_pause = 1	// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	local 	append 	 = 1	// 1 to run iecodebook append, 0 if file is already appended.


	local 	year 		"${GLD}:\GLD-Harmonization\\`usr'\\`cty3'\\`cty3'_`surv_yr'_LFS" // top data folder

	local 	main		"`year'\\`cty3'_`surv_yr'_LFS_v01_M"
	local 	 stata		"`main'\data\stata"
	local 	gld 		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v01_A_GLD"
	local 	i2d2		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v01_A_I2D2"
	local 	 code 		"`i2d2'\Programs"
	local 	 id_data 	"`i2d2'\Data\Harmonized"

	local 	lb_mod_age	15	// labor module minimun age (inclusive)
	local 	ed_mod_age	5	// labor module minimun age (inclusive)


** LOG FILE
	log using `"`id_data'\\`cty3'_`surv_yr'_I2D2_LFS.log"', replace


** FILES
	local round1 `"`stata'\LFS JAN2016.dta"'
	local round2 `"`stata'\LFS APR2016.dta"'
	local round3 `"`stata'\LFS JUL2016.dta"'
	local round4 `"`stata'\LFS OCT2016.dta"'

** VALUES
	local n_round 	4			// numer of survey rounds



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

** HARMONIZE VARIABLE NAMES, LABELS

if (`append' == 1) {
*** set up the codebook template
	iecodebook template ///
		`"`round1'"' `"`round2'"' `"`round3'"' `"`round4'"' /// survey files
		using `"`i2d2'\Doc\\`cty3'_`surv_yr'_append_template.xlsx"' /// output excel command makes
		, clear replace surveys(JAN2016 APR2016 JUL2016 OCT2016) /// survey names
		match // atuo match the same-named variables

if (`cb_pause' == 1) {
		pause on
		pause pausing while you edit your codebook. Save aligned codebook with suffix "-IN.xlsx" in the same directory as the output. press 'q' to continue.
	}


*** append the dataset
	iecodebook append ///
		`"`round1'"' `"`round2'"' `"`round3'"' `"`round4'"' /// survey files
		using `"`i2d2'\Doc\\`cty3'_`surv_yr'_append_template-IN.xlsx"' /// output just created above
		, clear surveys(JAN2016 APR2016 JUL2016 OCT2016) // survey names
	}
	else {
*** use the single file
	use `"`round1'"', clear

	}



** SAMPLE
	gen str7 sample = `"`cty3'"' + `"`surv_yr'"'

** COUNTRY
	gen str4 ccode=`"`cty3'"'
	label var ccode "Country code"


** YEAR
	gen int year=svyyr
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year=`surv_yr'
	label var intv_year "Year of the interview"


** MONTH OF INTERVIEW
	gen byte month=svymo
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	loc idhvars 	reg  prov hhnum 	// store idh vars in local


	ds `idhvars',  	has(type numeric)					// filter out numeric variables in local
	loc numlist 	= r(varlist)						// store numeric vars in local
	loc stringlist 	: list idhvars - numlist			// non-numeric vars in stringlist

	* starting locals
	loc len = 6											// declare the length of each element in digits
	loc idh_els ""										// start with empty local list

	* make each numeric var string, including leading zeros
	foreach var of local numlist {
		tostring `var'	///								// make the numeric vars strings
			, generate(idh_`var') ///					// gen a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idh_els 	`idh_els' idh_`var'				// add each variable to the local list

	}

	* make each string variable numeric (as it should be), then string again with correct format
	foreach var of local stringlist {
		destring `var' /// 								// destring variable, make numeric version
			, gen(num_`var') ///						//
			force 										// force obs to num that are non numeric, ie to missing

		tostring num_`var'	///							// make the numeric vars strings
			, generate(idh_`var') ///					// gen a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idh_els 	`idh_els' idh_`var'				// add each variable to the local list

	}


	* concatenate all elements to form idh: hosehold id
	egen idh=concat( `idh_els' )						// concatenate vars we just made. code drops vars @ end

	label var idh "Household id"




** INDIVIDUAL IDENTIFICATION NUMBER
	bys idh: gen n_fam = _n								// generate family member number

	* repeat same process from above, but only with n_fam.
	* 	note, assuming that the only necessary individaul identifier is family member, which is numeric
	*	so, not following processing for sorting numeric/non-numeric variables.

	loc idpvars 	n_fam 								// store relevant idp vars in local
	ds `idpvars',  	has(type numeric)					// filter out numeric variables in local
	loc rlist 		= r(varlist)						// store numeric vars in local

	* make new values with desired length of each variable
	loc len = 2											// declare the length of each element in digits
	loc idp_els ""										// start with empty local list

	foreach var of local idpvars {
		tostring `var'	///								// make numeric variables strings
			, generate(idp_`var') ///					// generate a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idp_els 	`idp_els' idp_`var'				// add each variable to the local list

	}

	* concatenate to form idp: individual id
	egen idp=concat( `idp_els' )						// concatenate vars we just made. code drops vars @ end

	sort idh idp
	label var idp "Individual id"

** ID CHECKS
	isid idh idp 										// household and individual id uniquely identify



** HOUSEHOLD WEIGHTS
	/* The weight variable will be divided by the number of rounds per year to ensure the
	   weighting factor does not over-mutliply*/
	gen double wgt= pwgt/(10000 * `n_round')
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	/*Survey includes psu variable*/
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
    gen byte urb=urb2k70
    label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen byte reg01=reg		// not recoding region for now, but needs to be addressed in #12
    la de lblreg01  1 "Ilocos" 2 "Cagayan Valley" 3 "Central Luzon" 5 "Bicol" 6 "Western Visayas" 7 "Central Visayas" ///
                    8 "Eastern Visayas" 9 "Zamboanga Peninsula" 10 "Northern Mindanao" 11 "Davao" 12 "Soccsksargen" ///
                    13 "National Capital Region" 14 "Cordillera Administrative Region" ///
                    15 "Autonomous Region in Muslim Mindana" 16 "Caraga" 41 "Calabarzon" 42 "Mimaropa"
    label var reg01 "Macro regional areas"
    label values reg01 lblreg01


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte reg02=prov
	label var reg02 "Region at 1 digit (ADMN1)"


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03= .
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN3)
	gen reg04= .
	label var reg04 "Region at 3 digits (ADMN3)"


** HOUSE OWNERSHIP
	gen byte ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CELL PHONE
	gen byte cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen byte internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	sort idh
	by idh: egen hhsize= count(c05_rel <= 8 | c05_rel == 11)
	* restrict by family role var, include all non-family members but not boarders/workers
	label var hhsize "Household size"

	* check
	mdesc hhsize
	assert r(miss) == 0


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte head=c05_rel				//  "head", "spouse", and children not recoded
	recode head 	(4 5 6 8  	= 5)	/// siblings, children in law, grandchildren, other relatives of hh head = "other relatives"
					(7 			= 4)	/// parents of hh head become "parents"
					(9 10 11 	= 6) 	// boarders and domestic workers become "other/non-relatives"

	replace ownhouse=. if head==6
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead
	gen jh=(head==1)
	bys idh: egen hh=sum(jh) // hh is the count of hh heads per family

	/*Note: if number of Household Heads is >1, all relevant HH head info is set to missing.
			In this case the only relevant variable is head*/
	replace head=. if hh>1

	*drop if hh==0


** GENDER
	gen byte gender=c06_sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen byte age = c07_age
	label var age "Individual age"
	replace age=98 if age>=98 & age!=.


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=c08_ms
	recode marital (1=2) (2=1) (3=5)(5 6=.)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age= `ed_mod_age'				// minimum incluse attending school age is 5
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=.
	replace atschool=1 if a02_csch == 1
	replace atschool=0 if a02_csch == 2
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	*no related variable in survey
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	*no related variable in survey
	gen byte educy=.
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen byte edulevel1=.
	replace edulevel1=1 if c09_grd==0
	replace edulevel1=2 if c09_grd==1
	replace edulevel1=3 if c09_grd==2
	replace edulevel1=4 if c09_grd==3
	replace edulevel1=5 if c09_grd==4
	replace edulevel1=7 if c09_grd==5 | ( c09_grd>=60 & c09_grd<=78)
	* note, according to the PSA, codes 60-78 refer to bachelors degrees, (for 2009, assuming same)

	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1
	replace edulevel1=. if age < ed_mod_age // restrict universe to students at or above primary school age


** EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 (4=3) (5=4)  (6/7=5) (8=.) (9=.)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2
	replace edulevel2=. if age < ed_mod_age // restrict universe to students at or above primary school age


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 (2 3 =2) (4 5 =3) (6/7 =4) (8=.) (9=.)
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3
	replace edulevel3=. if age < ed_mod_age // restrict universe to students at or above primary school age



** EVER ATTENDED SCHOOL
	/*Note, ever attend will be true=1 if student if of school age and has completed at least grade 1 or is
		currently attending*/

	gen byte everattend=.
	replace everattend=1 if age >= ed_mod_age & (atschool==1 | (2 <= edulevel1 <= 8 ))
	replace everattend=0 if age >= ed_mod_age & atschool==0 & edulevel1==0
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend



/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/

** LABOR MODULE AGE
	gen byte lb_mod_age=`lb_mod_age'
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	/*Changing by using newempst to determine lstatus, not work
	Note: creating own label, not using label from newempst	*/
	gen byte lstatus=.
	replace lstatus=1 if newempst==1
	replace lstatus=2 if newempst==2
	replace lstatus=3 if newempst==3
	replace lstatus=. if age < lb_mod_age // restrict universe to only those of working age
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed"
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen byte empstat=.
	replace empstat=1 if c19pclas==0 | c19pclas==1 | c19pclas==2 | c19pclas==5
	replace empstat=2 if c19pclas==6
	replace empstat=3 if c19pclas==4
	replace empstat=4 if c19pclas==3
	replace empstat=. if lstatus!=1 	// includes universe restriction
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1 // includes universe restriction
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=a03_jobs
	label var njobs "Number of total jobs"
	replace njobs=. if age < lb_mod_age // restrict universe to working age


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1 // restricts universe
	label var njobs_year "Number of total jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	replace ocusec=1 if c19pclas==2
	replace ocusec=2 if c19pclas!=2
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1  	// restrict universe to employed only
	replace ocusec=. if age < lb_mod_age // restrict universe to working age



** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
	replace nlfreason=1 if c42_wynt==8
	replace nlfreason=2 if c42_wynt==7
	replace nlfreason=3 if c42_wynt==6
	replace nlfreason=4 if c42_wynt==3
	replace nlfreason=5 if c42_wynt==1 | c42_wynt==2 | c42_wynt==4 | c42_wynt==5 | c42_wynt==9
	replace nlfreason=. if lstatus!=3 	// restricts universe to non-labor force
	replace nlfreason=. if age < lb_mod_age // restrict universe to working age
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l= c40_wks/4.2
	label var unempldur_l "Unemployment duration (months) lower bracket"
	replace unempldur_l=. if age < lb_mod_age // restrict universe to working age
	replace unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only

	gen byte unempldur_u= c40_wks/4.2
	label var unempldur_u "Unemployment duration (months) upper bracket"
	replace unempldur_l=. if age < lb_mod_age // restrict universe to working age
	replace unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only

** INDUSTRY CLASSIFICATION
	gen byte industry=.
	replace industry=1 if (c18_pkb>=1& c18_pkb<=4)		// to Agriculture
	replace industry=2 if (c18_pkb>=5 & c18_pkb<=9)		// to Mining
	replace industry=3 if (c18_pkb>=10 & c18_pkb<=32)	// to Manufacturing
	replace industry=4 if (c18_pkb>=33 & c18_pkb<=39)	// to Public utility
	replace industry=5 if (c18_pkb>=41 &  c18_pkb<=43)	// to Construction
	replace industry=6 if (c18_pkb>=45 & c18_pkb<=47) | c18_pkb==56	// to Commerce
	replace industry=7 if (c18_pkb>=49 & c18_pkb<=55)| (c18_pkb>=58 & c18_pkb<=63) // to Transport/coms
	replace industry=8 if (c18_pkb>=64 & c18_pkb<=82) 	// to financial/business services
	replace industry=9 if (c18_pkb==84) 				// to public administration
	replace industry=10 if  (c18_pkb>=91 & c18_pkb<=99) // to other
	replace industry=10 if industry==. & c18_pkb!=.
	replace industry=. if lstatus~=1

* Comments include UN International Standard Industrial Classification associated categories (version 3.1)
	label var industry "1 digit industry classification"
	la de lblindustry 	1 "Agriculture" 	/// (01-05)
						2 "Mining" 			/// (10-14)
						3 "Manufacturing" 	/// (15-37)
						4 "Public Utility Services" /// (40-41)
						5 "Construction"  	/// (45)
						6 "Commerce" 	/// (50-55)
						7 "Transport and Communication" /// (60-64)
						8 "Financial and Business Services" /// (65-74)
						9 "Public Administration" /// (75)
						10 "Other Services, Unspecified" // (80-99)
	label values industry lblindustry
	replace industry=. if age < lb_mod_age // restrict universe to working age
	replace industry=. if lstatus!=1 		// restrict universe to employed only

** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1
	replace industry1=. if age < lb_mod_age // restrict universe to working age
	replace industry1=. if lstatus!=1 		// restrict universe to employed only

**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=c18_pkb
	replace industry_orig=. if lstatus!=1 		// restrict universe to employed only
	replace industry_orig=. if age < lb_mod_age // restrict universe to working age
	label var industry_orig "Original Industry Codes"


** OCCUPATION CLASSIFICATION
	* in 2016, raw variable is numeric

	* generate occupation variable
	gen byte occup=floor(c16_proc/10)		// this handles most of recoding automatically.
	recode occup 0 = 10	if 	c16_proc==1 	// recode "armed forces" to appropriate label
	recode occup 0 = 99	if 	(c16_proc>=2 & c16_proc <=9) ///
							| (c16_proc >=94 & c16_proc <= 99) // recode "Not classifiable occupations"


	replace occup=. if lstatus!=1 		// restrict universe to employed only
	replace occup=. if age < lb_mod_age	// restrict universe to working age
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and sales workers" 6 "Skilled agricultural, forestry, and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations"  99 "Others"
	label values occup lbloccups


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig=c16_proc
	replace occup_orig=. if lstatus!=1 			// restrict universe to employed only
	replace occup_orig=. if age < lb_mod_age	// restrict universe to working age
	label var occup_orig "Original Occupational Codes"


** FIRM SIZE
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1 			// restrict universe to employed only
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1 			// restrict universe to employed only
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours= c22_phrs
	replace whours=. if lstatus!=1 			// restrict universe to employed only
	replace whours=. if age < lb_mod_age	// restrict universe to working age
	label var whours "Hours of work in last week"
	replace whours=. if lstatus!=1


** WAGES
	gen double wage= c27_pbsc
	replace wage=. if lstatus!=1 			// restrict universe to employed only
	replace wage=. if age < lb_mod_age		// restrict universe to working age
	replace wage=. if empstat==1			// restrict universe to wage earners
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=1
	replace unitwage=. if lstatus!=1 			// restrict universe to employed only
	replace unitwage=. if age < lb_mod_age		// restrict universe to working age
	replace unitwage=. if empstat==1			// restrict universe to wage earners
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=.

	replace empstat_2=. if lstatus!=1 			// restrict universe to employed only
	replace empstat_2=. if age < lb_mod_age		// restrict universe to working age
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2


** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	gen byte empstat_2_year=.

	replace empstat_2_year=. if lstatus!=1 				// restrict universe to employed only
	replace empstat_2_year=. if age < lb_mod_age		// restrict universe to working age
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year  lblempstat_2_year


** INDUSTRY CLASSIFICATION - SECOND JOB
	gen byte industry_2=.
	replace industry_2=1 if (j03_okb>=1& j03_okb<=4)		// to Agriculture
	replace industry_2=2 if (j03_okb>=5 & j03_okb<=9)		// to Mining
	replace industry_2=3 if (j03_okb>=10 & j03_okb<=32)	// to Manufacturing
	replace industry_2=4 if (j03_okb>=33 & j03_okb<=39)	// to Public utility
	replace industry_2=5 if (j03_okb>=41 &  j03_okb<=43)	// to Construction
	replace industry_2=6 if (j03_okb>=45 & j03_okb<=47) | j03_okb==56	// to Commerce
	replace industry_2=7 if (j03_okb>=49 & j03_okb<=55)| (j03_okb>=58 & j03_okb<=63) // to Transport/coms
	replace industry_2=8 if (j03_okb>=64 & j03_okb<=82) 	// to financial/business services
	replace industry_2=9 if (j03_okb==84) 				// to public administration
	replace industry_2=10 if  (j03_okb>=91 & j03_okb<=99) // to other
	replace industry_2=10 if industry_2==. & j03_okb!=.
	replace industry_2=. if lstatus~=1

	label var industry_2 "1 digit industry_2 classification"
	label values industry_2 lblindustry 		// use same value/factor label as industry
	replace industry_2=. if age < lb_mod_age // restrict universe to working age
	replace industry_2=. if lstatus!=1 		// restrict universe to employed only


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=industry_2
	recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1_2=. if lstatus!=1 				// restrict universe to employed only
	replace industry1_2=. if age < lb_mod_age			// restrict universe to working age
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=j03_okb
	replace industry_orig_2=. if lstatus!=1 				// restrict universe to employed only
	replace industry_orig_2=. if age < lb_mod_age			// restrict universe to working age
	label var industry_orig_2 "Original Industry Codes - Second job"


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen byte occup_2=floor(j02_otoc/10)		// this handles most of recoding automatically.
	recode occup_2 0 = 10	if 	j02_otoc==1 	// recode "armed forces" to appropriate label
	recode occup_2 0 = 99	if 	j02_otoc==9 	// recode "Not classifiable occupations" to appropriate label

	replace occup_2=. if lstatus!=1 		// restrict universe to employed only
	replace occup_2=. if age < lb_mod_age	// restrict universe to working age

	replace occup_2=. if lstatus!=1 				// restrict universe to employed only
	replace occup_2=. if age < lb_mod_age			// restrict universe to working age
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2=c36_obic
	replace wage_2=. if lstatus!=1 			// restrict universe to employed only
	replace wage_2=. if age < lb_mod_age		// restrict universe to working age
	replace wage_2=. if empstat==1			// restrict universe to wage earners
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen byte unitwage_2=1
	replace unitwage_2=. if lstatus!=1 			// restrict universe to employed only
	replace unitwage_2=. if age < lb_mod_age		// restrict universe to working age
	replace unitwage_2=. if empstat==1			// restrict universe to wage earners
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2


** CONTRACT
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract=. if lstatus!=1 				// restrict universe to employed only
	replace contract=. if age < lb_mod_age			// restrict universe to working age


** HEALTH INSURANCE
	gen byte healthins=.
	replace healthins=. if lstatus!=1 				// restrict universe to employed only
	replace healthins=. if age < lb_mod_age			// restrict universe to working age
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1 				// restrict universe to employed only
	replace socialsec=. if age < lb_mod_age			// restrict universe to working age
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	replace union=. if lstatus!=1 				// restrict universe to employed only
	replace union=. if age < lb_mod_age			// restrict universe to working age
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris


**REGION OF BIRTH
	gen rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
	gen rprevious=.
	label var rprevious "Region of Previous residence"


** YEAR OF MOST RECENT MOVE
	gen int yrmove=.
	label var yrmove "Year of most recent move"


**TIME REFERENCE OF MIGRATION
	gen byte rprevious_time_ref=.
	label var rprevious_time_ref "Time reference of migration"
	la de lblrprevious_time_ref 99 "Previous migration"
	label values rprevious_time_ref lblrprevious_time_ref


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** INCOME PER CAPITA
	gen double pci=.
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen pcc_d=.
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep sample ccode year intv_year month idh idp wgt strata psu urb ///
				reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
				cellphone computer internet hhsize head gender age soc marital ed_mod_age ///
				everattend atschool literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age ///
				lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason ///
				unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig ///
				firmsize_l firmsize_u whours wage unitwage contract  empstat_2 ///
				empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious ///
				yrmove rprevious_time_ref pci pci_d pcc pcc_d


** ORDER VARIABLES
	order sample ccode year intv_year month idh idp wgt strata psu urb	///
				reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone ///
				cellphone computer internet hhsize head gender age soc marital ///
				ed_mod_age everattend atschool literacy educy edulevel1 edulevel2 ///
				edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year ///
				njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry ///
				industry1 industry_orig occup occup_orig firmsize_l firmsize_u ///
				whours wage unitwage contract empstat_2 empstat_2_year ///
				industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris ///
				rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d

	compress


** DELETE MISSING VARIABLES // why would we not use missings here?
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - pcc_d {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep sample ccode year intv_year month  idh idp wgt strata psu `keep'



** MISSING VALUES
	*Declare varlist which cannot contain missings
	loc	nomissvars sample ccode year intv_year month idh idp wgt strata psu hhsize ed_mod_age lb_mod_age

	foreach var of local nomissvars {
		qui mdesc `var'
		loc nmiss = r(miss)
		cap assert r(miss) == 0
		if _rc {
			display as txt "Variable " as result "`var'" as txt " has `nmiss' observations."
		}
		else {
			display as txt "Variable " as result "`var'" as txt " has no missing observations."
		}
	}


	save `"`id_data'\\`cty3'_`surv_yr'_I2D2_LFS.dta"', replace

	log close








******************************  END OF DO-FILE  *****************************************************/
