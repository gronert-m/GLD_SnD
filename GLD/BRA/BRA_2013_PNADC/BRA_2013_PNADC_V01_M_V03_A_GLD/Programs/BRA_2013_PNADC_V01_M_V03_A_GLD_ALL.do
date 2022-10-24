
/*%%============================================================================
      0: GLD Harmonization Preamble
============================================================================%%*/

/* -----------------------------------------------------------------------------

<_Program name_> 			BRA_2013_PNADC_v01_M_v03_A_GLD_ALL.do </_Program name_>
<_Application_> 			STATA 17.0 <_Application_>
<_Author(s)_> 				World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_> 			2022-04-01 </_Date created_>

-------------------------------------------------------------------------------- 

<_Country_> 				BRA </_Country_> 
<_Survey Title_> 			PNADC </_Survey Title_> 
<_Survey Year_> 			2013 </_Survey Year_>
<_Study ID_> 				BRA_2013_PNAD_v01_M </_Study ID_>
<_Data collection from_> 	2013 </_Data collection from_>
<_Data collection to_> 		2013 </_Data collection to_>
<_Source of dataset_> 		https://www.ibge.gov.br/estatisticas/sociais/trabalho/9127-pesquisa-nacional-por-amostra-de-domicilios.html?=&t=downloads </_Source of dataset_>
<_Sample size (HH)_> 		145,074 </_Sample size (HH)_>
<_Sample size (IND)_> 		461,033 </_Sample size (IND)_>
<_Sampling method_> 		Probabilistic sampling of households obtained in 
three selection stages: primary units - municipalities; secondary units - 
census sectors; tertiary units - domicile units </_Sampling method_>
<_Geographic coverage_> 	Metropolitan Area </_Geographic coverage_>
<_Currency_> 				Brazilian Real (R$) </_Currency_>

--------------------------------------------------------------------------------

<_ICLS Version_> 			ICLS-19 </_ICLS Version_>
<_ISCED Version_> 			isced_2011 </_ISCED Version_>
<_ISCO Version_> 			ISCO 2008 </_ISCO Version_>
<_OCCUP National_> 			COD </_OCCUP National_>
<_ISIC Version_> 			ISIC Rev. 4 </_ISIC Version_>
<_INDUS National_> 			CNAE Domiciliar </_INDUS National_>

--------------------------------------------------------------------------------
<_Version Control_>

* Date: [2022-08-13] - Changed industry, occup info from ISIC Rev 3 to Rev 4 
and ISCO-88 to ISCO-08 respectively. Kept one off the old matchings just in case.

* Date 2022/10/24 - Update educat7, subnatidsurvey

</_Version Control_>
 
------------------------------------------------------------------------------*/


/*%%============================================================================
   1: Setting up of program environment, dataset
============================================================================%%*/

*----------1.1: Initial commands-----------------------------------------------*

	clear
	set more 1

*----------1.2 Set directories-------------------------------------------------*
	
	local path_input "Y:\GLD\BRA\BRA_2013_PNADC\BRA_2013_PNADC_v01_M\Data\Stata"
	local path_output "Y:\GLD\BRA\BRA_2013_PNADC\BRA_2013_PNADC_V01_M_V03_A_GLD\Data\Harmonized"

*----------1.3 Read People file--------------------------------*

	use "`path_input'\pnadc2013.dta", clear
	
*----------1.4.1: People file IDs & adjustments--------------------------------*
{
*----------1.4.1.1: Comparing weights------------------------------------------*
	
	gen count = 1
	tab count [iweight = V1032]
	
	* 0 instances where HH weight is missing
	count if V1032 == . 
	

*----------2.2.1.2: Checking person id-----------------------------------------*
	*  0 non-distinct individual identifiers
	tostring UPA, format("%14.0f") gen(str_UPA)
	tostring V1008, format("%02.0f") gen(str_V1008)
	tostring V1014, format("%02.0f") gen(str_V1014)
	egen id_dom = concat(str_UPA str_V1008 str_V1014)
	gen id_pes = string(V2003, "%03.0f")
	distinct id_dom id_pes, joint
	
}
*----------2.2.2: Remove auxiliary variables-----------------------------------*
{
	drop count str_UPA V1008 str_V1008 V1014 str_V1014 V2003 
}	
	
/*%%============================================================================
   2: Survey & ID
============================================================================%%*/

{

*<_countrycode_>
	gen countrycode = "BRA"
	label variable countrycode "Country code"
*</_countrycode_>

*<_survname_>
	gen survname  = "PNADC"
	label variable survname "Survey acronym"
*</_survname_>

*<_survey_>
	gen survey = "Other Household Survey" // https://microdatalib.worldbank.org/index.php/catalog/3342
	label variable survey "Survey type" 
*</_survey_>

*<_icls_v_>
	gen icls_v = "ICLS-19"
	label variable icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
	gen isced_version = "isced_2001"
	label variable isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>

*<_isco_version_>
	gen isco_version = "isco_2008"
	label variable isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
	gen isic_version = "isic_4"
	label variable isic_version "Version of ISIC used"
*</_isic_version_>

*<_year_>
/* <_year_note>
	
	1980's: didn't exist
	1990's: had only 2-digits
	
	1980's: V0101 represents HH number
	1983 & 1990: doesn't exist
	
</_year_note> */
	rename Ano year
	label variable year "Year of survey"
*</_year_>

*<_vermast_>
	gen vermast = "v01"
	label variable vermast "Version of master data"
*</_vermast_>

*<_veralt_>
	gen veralt = "V03"
	label variable veralt "version of the alt/harmonized data"
*</_veralt_>

*<_harmonization_>
	gen harmonization = "GLD"
	label variable harmonization "Type of harmonization"
*</_harmonization_>

*<_int_year_>
	gen int_year = year
	label variable int_year "Year of interview"
*</_int_year_>

*<_int_month_>
	rename Trimestre int_month
	label define int_month_lab 1 "March" 2 "June" 3 "September" 4 "December"
	label value int_month int_month_lab
	label variable int_month "Month of interview"
*</_int_month_>

*<_int_quarter_>
	gen int_quarter = int_month
	label define int_quarter_lab 1 "First Quarter" 2 "Second Quarter" 3 "Third Quarter" 4 "Fourth Quarter"
	label value int_quarter int_quarter_lab
	label variable int_month "Quarter of interview"
*</_int_quarter_>

*<_hhid_>
/* <_hhid_note>
	
	1980's: V0101 is hhid
	1983 & 1990: V0101 doesn't exist; V0102 & V0103 do
	1992-2013: V0102 has 6-digits rather than 8-digits (lacking UF digits at begining)
	
	If inexists: avoid creating a sequential index (hhid = _n)
	
</_hhid_note> */
	rename id_dom hhid
	label variable hhid "Household ID"
*</_hhid_>

*<_pid_> 
/* <_pid_note>

	1980's: doesn't exist
	As of 1992: name change
	
</_pid_note> */
	egen pid = concat(hhid id_pes)
	label variable pid "Individual ID"
*</_pid_> 

*<_weight_>
/* <_weight_note>
	
	1992-2001: contains "-1", which should be changed to missing (.)
	
</_weight_note> */
	*gen count = 1
	*tab count [iweight = V4611] // dom
	*tab count [iweight = V4729] // pes
	*tab count [iweight = V4732] // fam
	*egen tag1 = diff(V4611 V4732)
	*tab tag1, missing
	*egen tag2 = diff(V4729 V4732)
	*tab tag2, missing
	*egen tag3 = diff(V4611 V4729)
	*tab tag3, missing
	
	rename V1032 weight
	label variable weight "Household sampling weight"
*</_weight_>

*<_psu_>
	rename UPA psu
	tostring psu, replace
	label variable psu "Primary sampling units"
*</_psu_>

*<_strata_>
	rename Estrato strata
	tostring strata, replace
	label variable strata "Strata"
*</_strata_>

*<_wave_>
/* <_wave_note>

	Exists in PNADc
	
</_wave_note> */
	gen wave = 1
	tostring wave, replace
	label variable wave "Survey wave"
*</_wave_>

}


/*%%============================================================================
   3: Geography
============================================================================%%*/

{

*<_urban_>
/* <_urban_note>

	
</_urban_note> */
	rename V1022 urban
	recode urban (2 = 0)
	label variable urban "Location is urban"
	label define urban_lab 0 "Rural" 1 "Urban"
	label values urban urban_lab
*</_urban_>

*<_subnatid1_>
/* <_subnatid1_note>

	Until 1992: not standardised
	
	1st digit of "UF" variable
	
</_subnatid1_note> */
	gen subnatid1 = .
	replace subnatid1 = 1 if substr(string(UF), 1, 1) == "1"
	replace subnatid1 = 2 if substr(string(UF), 1, 1) == "2"
	replace subnatid1 = 3 if substr(string(UF), 1, 1) == "3"
	replace subnatid1 = 4 if substr(string(UF), 1, 1) == "4"
	replace subnatid1 = 5 if substr(string(UF), 1, 1) == "5"
	recast byte subnatid1
	label variable subnatid1 "Subnational ID at First Administrative Level"
	label define subnatid1_lab 1 "1 - North" 2 "2 - Northeast" 3 "3 - Southeast" 4 "4 - South" 5 "5 - Central-West"
	label values subnatid1 subnatid1_lab
*</_subnatid1_>

*<_subnatid2_>
/* <_subnatid2_note>

	Until 1992: not standardised
	Until 1992: TO (17) part of GO (52), though created in 1988 (changes region/subnatid1)
	
	2nd digit of "UF" variable
	
</_subnatid2_note> */
	gen subnatid2 = UF
	recast byte subnatid2
	label variable subnatid2 "Subnational ID at Second Administrative Level"
	label define subnatid2_lab	11 "11 - Rondonia" 12 "12 - Acre" 13 "13 - Amazonas" 14 "14 - Roraima" 15 "15 - Pará" 16 "16 - Amapa" 17 "17 - Tocantins" 21 "21 - Maranhao" 22 "22 - Piaui" 23 "23 - Ceara" 24 "24 - Rio Grande do Norte" 25 "25 - Paraiba" 26 "26 - Pernambuco" 27 "27 - Alagoas" 28 "28 - Sergipe" 29 "29 - Bahia" 31 "31 - Minas Gerais" 32 "32 - Espirito Santo" 33 "33 - Rio de Janeiro" 35 "35 - Sao Paulo" 41 "41 - Parana" 42 "42 - Santa Catarina" 43 "43 - Rio Grande do Sul" 50 "50 - Mato Grosso do Sul" 51 "51 - Mato Grosso" 52 "52 - Goias" 53 "53 - Distrito Federal"
	label values subnatid2 subnatid2_lab
*</_subnatid2_>
	
*<_subnatid3_>
/* <_subnatid3_note>

	1022: Census area code
	1 = Capital
	2 = Rest of the Metropolitan area
	3 = Rest of the State
	
	
</_subnatid3_note> */
	gen subnatid3 = .
	replace subnatid3 = Capital 
	recast byte subnatid3
	label variable subnatid3 "Subnational ID at Third Administrative Level"
	label define subnatid3_lab 11 "11 - Porto Velho" 12 " 12 - Rio Branco" 13 " 13 - Manaus" 14 "14 - Boa Vista" 15 "15 - Belem" 16 "16 - Macapa" 17 "17 - Palmas" 21 "21 - São Luis" 22 "22 - Teresina" 23 "23 - Fortaleza" 24 "24 - Natal" 25 "25 - João Pessoa" 26 "26 - Recife" 27 "27 - Maceió" 28 "28 - Aracaju" 29 "29 - Salvador" 31 "31 - Belo Horizonte" 32 "32 - Vitória" 33 "33 - Rio de Janeiro" 35 "35 - São Paulo" 41 "41 - Curitiba" 42 "42 - Florianópolis" 43 "43 - Porto Alegre" 50 "50 - Campo Grande" 51 "51 - Cuiabá" 52 "52 - Goiânia" 53 "53 - Brasilia"
	label values subnatid3 subnatid3_lab
*</_subnatid3_>

*<_subnatidsurvey_>
	gen subnatidsurvey = ""
	decode subnatid2, gen(helper_1)
	decode subnatid3, gen(helper_2)
	replace subnatidsurvey = helper_1 + " - Urban" if urban == 1 & missing(subnatid3)
	replace subnatidsurvey = helper_1 + " - Rural" if urban == 0 & missing(subnatid3)
	replace subnatidsurvey = helper_2 + " (City)" if !missing(subnatid3)
	drop helper_1 helper_2
*</_subnatidsurvey_>

*<_subnatid1_prev_>
	gen subnatid1_prev = .
	label variable subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid2_prev_>

*<_subnatid2_prev_>
	gen subnatid2_prev = .
	label variable subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>

*<_subnatid3_prev_>
	gen subnatid3_prev = .
	label variable subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>

*<_gen gaul_adm1_code_>
/* <_gaul_adm1_code_note>

	Brazil 37
		
</_gaul_adm1_code_note> */
	gen gaul_adm1_code = .
	label variable gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gen gaul_adm1_code_>

*<_gen gaul_adm2_code_>
	gen gaul_adm2_code = subnatid2
	recode gaul_adm2_code (11 = 686) (12 = 665) (13 = 668) (14 = 687) (15 = 678) (16 = 667) (17 = 691) (21 = 674) (22 = 682) (23 = 670) (24 = 684) (25 = 679) (26 = 681) (27 = 666) (28 = 690) (29 = 669) (31 = 677) (32 = 672) (33 = 683) (35 = 689) (41 = 680) (42 = 688) (43 = 685) (50 = 676) (51 = 675) (52 = 673) (53 = 671) 
	label variable gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
	label define gaul_adm2_code_lab	686 "686 - Rondonia" 665 "665 - Acre" 668 "668 - Amazonas" 687 "687 - Roraima" 678 "678 - Pará" 667 "667 - Amapa" 691 "691 - Tocantins" 674 "674 - Maranhao"682 "682 - Piaui" 670 "670 - Ceara" 684 "684 - Rio Grande do Norte" 679 "679 - Paraiba" 681 "681 - Pernambuco" 666 "666 - Alagoas" 690 "690 - Sergipe" 669 "669 - Bahia" 677 "677 - Minas Gerais" 672 "672 - Espirito Santo" 683 "683 - Rio de Janeiro" 689 "689 - Sao Paulo" 680 "680 - Parana" 688 "688 - Santa Catarina" 685 "685 - Rio Grande do Sul" 676 "676 - Mato Grosso do Sul" 675 "675 - Mato Grosso" 673 "673 - Goias" 671 "671 - Distrito Federal"
	label values gaul_adm2_code gaul_adm2_code_lab
*</_gen gaul_adm2_code_>

*<_gen gaul_adm3_code_>
	gen gaul_adm3_code = .
	label variable gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gen gaul_adm3_code_>

}


/*%%============================================================================
   4: Demography
============================================================================%%*/



*<_hsize_>
/* <_hsize_note>

	1992-2001: contains "-1", which should be changed to missing (.)
	
</_hsize_note> */
	rename V2001 hsize
	label variable hsize "Household size"
*</_hsize_>

*<_age_>
/* <_age_note>

	Check: <=5 years, age registered with decimals
	
	1980's: simetimes age and YoB are switched
	Contains 999", which should be changed to missing (.)
	
	Until 2000: YoB registered with only 3-digits
	DoB = "00", MoB = "20" | "30" and YoB = "0"-"98" mean "deduced/estimated"
	
</_age_note> */
	rename V2009 age
	replace age = . if age == 999
	label variable age "Individual age"
*</_age_>

*<_male_>
	rename V2007 male
	recode male (2 = 0)
	label variable male "Sex - Ind is male"
	label define male_lab 0 "Female" 1 "Male"
	label values male male_lab
*</_male_>

*<_relationcs_>
	rename V2005 relationcs
	recast byte relationcs
	label variable relationcs "Relationship to the head of household - Country original"
	label define relationcs_lab 1 "Pessoa responsável pelo domicílio " 2 "Cônjuge ou companheiro(a) de sexo diferente" 3 "Cônjuge ou companheiro(a) do mesmo sexo" 4 "Filho(a) do responsável e do cônjuge" 5 "Filho(a) somente do responsável" 6	"Enteado(a)" 7 "Genro ou nora" 8	"Pai, mãe, padrasto ou madrasta" 9	"Sogro(a)" 10	"Neto(a)" 11 "Bisneto(a)"  12	"Irmão ou irmã" 13	"Avô ou avó" 14	"Outro parente" 15	"Agregado(a) - Não parente que não compartilha despesas" 16	"Convivente - Não parente que compartilha despesas" 17 "Pensionista" 18	"Empregado(a) doméstico(a)" 19	"Parente do(a) empregado(a) doméstico(a)"

	label values relationcs relationcs_lab
*</_relationcs_>

*<_relationharm_>
/* <_relationharm_note>

	If "head" not around, then "spouse" = "head"; if "spouse" not around, oldest member around = "hear"
	GLD category 4 "Parents" does not exist
	
</_relationharm_note> */
	gen relationharm = relationcs
	recode relationharm (1 = 1) (2/3 = 2) (4/5 = 3) (8/9 = 4) (6/7 10/14 = 5) (15/19 = 6)
	recast byte relationharm
	label variable relationharm "Relationship to the head of household - Harmonized"
	label define relationharm_lab 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm relationharm_lab
*</_relationharm_>

*<_marital_>
/* <_marital_note>

	Asked only to people 10 years or older
	Children (age?) should be category 2 "never married"... but go with survey (Mario)
	
</_marital_note> */
	gen marital = .
	label variable marital "Marital status"
	label define marital_lab 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital marital_lab
*</_marital_>

*<_eye_dsablty_>
	gen eye_dsablty = . 
	recast byte eye_dsablty
	label variable eye_dsablty "Difficulty related to eyesight"
	label define eye_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty eye_dsablty_lab
*</_eye_dsablty_>

*<_hear_dsablty_>
	gen hear_dsablty = .
	recast byte hear_dsablty
	label variable hear_dsablty "Difficulty related to hearing"
	label define hear_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all"
	label values hear_dsablty hear_dsablty_lab
*</_hear_dsablty_>

*<_walk_dsablty_>
	gen walk_dsablty = .
	recast byte walk_dsablty
	label variable walk_dsablty "Difficulty related to climbing stairs"
	label define walk_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all"
	label values walk_dsablty walk_dsablty_lab
*</_walk_dsablty_>

*<_conc_dsord_>
	gen conc_dsord = .
	recast byte conc_dsord
	label variable conc_dsord "Difficulty related to concentration or remembering"
	label define conc_dsord_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all"
	label values conc_dsord conc_dsord_lab
*</_conc_dsord_>

*<_slfcre_dsablty_>
	gen slfcre_dsablty = .
	recast byte slfcre_dsablty
	label variable slfcre_dsablty "Difficulty related to selfcare"
	label define slfcre_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all" 5 "Cannot at all"
	label values slfcre_dsablty slfcre_dsablty_lab
*</_slfcre_dsablty_>

*<_comm_dsablty_>
	gen comm_dsablty = .
	recast byte comm_dsablty
	label variable comm_dsablty "Difficulty related to communicating"
	label define comm_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all" 5 "Cannot at all"
	label values comm_dsablty comm_dsablty_lab
*</_comm_dsablty_>




/*%%============================================================================
   5: Migration
============================================================================%%*/


{

/* <__note>

	1992: Introduced
	
</__note> */


*<_migrated_mod_age_>
/* <_migrated_mod_age_note>

	Exists in PNADc
	
</_migrated_mod_age_note> */
	gen migrated_mod_age = .
	label variable migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>

*<_migrated_ref_time_>
/* <_migrated_ref_time_note>

	Time-reference: [1-9] years and "10 or more"
	
</_migrated_ref_time_note> */
	gen migrated_ref_time = .
	label variable migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>

*<_migrated_binary_>
	gen migrated_binary = .
	recast byte migrated_binary
	label variable migrated_binary "Individual has migrated"
	label define migrated_binary_lab 0 "No" 1 "Yes"
	label values migrated_binary migrated_binary_lab
*</_migrated_binary_>

*<_migrated_years_>
/* <_migrated_years_note>

	0 = Less than a year ago; 1-9, years ago; 10 = 10 or more years ago (Mario)
	For those people who migrated at different times from different administrative regions, we consider the most recent one!
	
</_migrated_years_note> */
	gen migrated_years = .
	label variable migrated_years "Years since latest migration"
*</_migrated_years_>

*<_migrated_from_urban_>
	gen migrated_from_urban = .
	recast byte migrated_from_urban
	label variable migrated_from_urban "Migrated from area"
	label define migrated_from_urban_lab 0 "Rural" 1 "Urban"
	label values migrated_from_urban migrated_from_urban_lab
*</_migrated_from_>

*<_migrated_from_cat_>
/* <_migrated_from_cat_note>

	admin1 = Region
	admin2 = State
	admin3 = Municipality !!!
	
</_migrated_from_cat_note> */
	gen migrated_from_cat = .
	recast byte migrated_from_cat
	label variable migrated_from_cat "Category of migration area"
	label define migrated_from_cat_lab 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat migrated_from_cat_lab
*</_migrated_from_cat_>

*<_migrated_from_code_>
/* <_migrated_from_code_note>

	subnatid1 = Region
	subnatid2 = State
	subnatid3 = Municipality
	
</_migrated_from_code_note> */
	gen migrated_from_code = .
	recast byte migrated_from_code
	label variable migrated_from_code "Code of migration area as subnatid level of migrated_from-cat"
	label define migrated_from_code_lab 1 "1 - North" 2 "2 - Northeast" 3 "3 - Southeast" 4 "4 - South" 5 "5 - Central-West"	11 "11 - Rondonia" 12 "12 - Acre" 13 "13 - Amazonas" 14 "14 - Roraima" 15 "15 - Pará" 16 "16 - Amapa" 17 "17 - Tocantins" 21 "21 - Maranhao" 22 "22 - Piaui" 23 "23 - Ceara" 24 "24 - Rio Grande do Norte" 25 "25 - Paraiba" 26 "26 - Pernambuco" 27 "27 - Alagoas" 28 "28 - Sergipe" 29 "29 - Bahia" 31 "31 - Minas Gerais" 32 "32 - Espirito Santo" 33 "33 - Rio de Janeiro" 35 "35 - Sao Paulo" 41 "41 - Parana" 42 "42 - Santa Catarina" 43 "43 - Rio Grande do Sul" 50 "50 - Mato Grosso do Sul" 51 "51 - Mato Grosso" 52 "52 - Goias" 53 "53 - Distrito Federal"
	label values migrated_from_code migrated_from_code_lab
*</_migrated_from_code_>

*<_migrated_from_country_>
	gen migrated_from_country = ""
	label variable migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>

*<_migrated_reason_>
	gen migrated_reason = .
	recast byte migrated_reason
	label variable migrated_reason "Reason for migrating"
	label define migrated_reason_lab 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, ...)" 5 "Other reason"
	label values migrated_reason migrated_reason_lab
*</_migrated_reason_>

}


/*%%============================================================================
   6: Education
============================================================================%%*/




*<_ed_mod_age_>
/* <_ed_mod_age_note>

	Exists in PNADc
	Until 1994: only asked to people 5 years or older
	As of 1995: asked to all ages
	
	Comparability throughout the years is compromised:
	1992: skip pattern introduced
	
</_ed_mod_age_note> */
	gen ed_mod_age = 0
	label variable ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
/* <_school_note>
	
	Comparability throughout the years is compromised:
	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 2001: "Pre-school" and "School" are considered separately

</_school_note> */
	gen school = V3002
	recode school (2 = 0)
	label variable school "Attending school"
	label define school_lab 0 "No" 1 "Yes"
	label values school school_lab
*</_school_>

*<_literacy_>
	recode V3001 (2 = 0)
	rename V3001 literacy
	label variable literacy "Individual can read & write"
	label define literacy_lab 0 "No" 1 "Yes"
	label values literacy literacy_lab
*</_literacy_>

*<_educy_>
/* <_educy_note>

	PNAD: 1 = no or < 1y instruction
	2-15 = 1-14y, 16 = 15+y; 17 = undetermined
	[1 ignored and "1" subtracted]
		
	Unti 1992: one set of values for each of 0-8, 9-11 and 12+
	As of 1992: 0-16
	
	PNADC: 0 (no literacy) - 16 (university degree+)
	
</_educy_note> */
	gen educy = VD3005 
	recast float educy
	label variable educy "Years of education"
	drop VD3005
	
	replace educy = 18 if V3009 == 11
	replace educy = 20 if V3009 == 12
*</_educy_>

*<_educat7_>
/* <_educat7_note>
 
	Using the derived (but survey own, created by survey producer) VD3004

</_educat7_note> */
	gen educat7 = .
	replace educat7 = 1 if VD3004 == 1
	replace educat7 = 2 if VD3004 == 2
	replace educat7 = 3 if VD3004 == 3
	replace educat7 = 4 if VD3004 == 4
	replace educat7 = 5 if VD3004 == 5
	replace educat7 = 7 if inrange(VD3004, 6, 7)
	label variable educat7 "Level of education 1"
	label define educat7_lab 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7"University incomplete or complete"
	label values educat7 educat7_lab
                *</_educat7_>

*<_educat5_>
/* <_educat5_note>
	
	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 2001: "Pre-school" and "School" are considered separately
	
	As of 2001: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists
	
</_educat5_note> */
	gen educat5 = educat7
	recode educat5 (1 = 1) (2 = 2) (3/4 = 3) (5 = 4) (6/7 = 5) (8 = .)
	recast byte educat5
	label variable educat5 "Level of education 2"
	label define educat5_lab 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 educat5_lab
*</_edycat5_>

*<_educat4_>
/* <_educat4_note>
	
	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 2001: "Pre-school" and "School" are considered separately
	
	As of 2001: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists
	
</_educat4_note> */
	gen educat4 = educat7
	recode educat4 (1 = 1) (2/4 = 2) (5 = 3) (6/7 = 4) (8 = .)
	recast byte educat4
	label variable educat4 "Level of education 3"
	label define educat4_lab 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 educat4_lab
*</_educat4_>

*<_educat_isced_>
	gen educat_isced = educat7
	recode educat_isced (1 8 = .) (2 = 102) (3 = 104) (4 = 302) (5 = 304) (6 = 602) (7 = 604)
	recast float educat_isced
	label variable educat_isced "ISCED 2001 standardised level of education"
	label define educat_isced_lab 102 "Primary education, not further defined, recognised successful completion of programme is sufficient for partial completion of ISCED level but without direct access to programmes at higher ISCED levels" 104 "Primary education, not further defined, recognised successful completion of programme is sufficient for completion of ISCED level and with direct access to programmes at higher ISCED levels" 302 "Upper secondary education, not further defined, recognised successful completion of programme is sufficient for partial completion of ISCED level but without direct access to programmes at higher ISCED levels" 304 "Upper secondary education, not further defined, recognised successful completion of programme is sufficient for completion of ISCED level and with direct access to programmes at higher ISCED levels" 602 "Bachelor's or equivalent level, not further defined, recognised successful completion of programme is sufficient for partial completion of ISCED level but without direct access to programmes at higher ISCED levels" 604 "Bachelor's or equivalent level, not further defined, recognised successful completion of programme is sufficient for completion of ISCED level and with direct access to programmes at higher ISCED levels"
	label values educat_isced educat_isced_lab
*</_educat_isced_>

*<_educat_orig_>
/* <_educat_orig_note>
	
	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 2001: "Pre-school" and "School" are considered separately
	
	2001: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists
	
	1980's: old nomenclature ("primeiro grau", instead of "ensino fundamental")
	
</_educat_orig_note> */
	gen educat_orig = .
*	rename V4745 educat_orig
*	recode educat_orig (8 = .)
*	recast byte educat_orig
*	label variable educat_orig "Original survey education code"
*	label define educat_orig_lab 1 "Sem instrução" 2 "Fundamental incompleto ou equivalente" 3 "Fundamental completo ou equivalente" 4 "Médio incompleto ou equivalente" 5 "Médio completo ou equivalente" 6 "Superior incompleto ou equivalente"	7 "Superior completo"
*	label values educat_orig educat_orig_lab
*</_educat_orig_>




/*%%============================================================================
   7: Training
============================================================================%%*/


{

*<_vocational_>
	gen vocational = .
	recast byte vocational
	label variable vocational "Ever received vocational training"
	label define vocational_lab 0 "No" 1 "Yes"
	label values vocational vocational_lab
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = .
	recast byte vocational_type
	label variable vocational_type "Type of vocational training"
	label define vocational_type_lab 1 "Inside Enterprise" 2 "External"
	label values vocational_type vocational_type_lab
*</_vocational_type_>

*<_vocational_length_l_>
	gen vocational_length_l = .
	recast float vocational_length_l
	label variable vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = .
	recast float vocational_length_u
	label variable vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>

*<_vocational_field_>
	gen vocational_field = .
	label variable vocational_field "Field of training"
*</_vocational_field_>

*<_vocational_financed_>
	gen vocational_financed = .
	recast byte vocational_financed
	label variable vocational_financed "How training was financed"
	label define vocational_financed_lab 1 "Employer" 2 "Government" 3 "Mixed Emploer/Government" 4 "Own funds" 5 "Other"
	label values vocational_financed vocational_financed_lab
*</_vocational_financed_>

}


/*%%============================================================================
   8: Labour
============================================================================%%*/




/* <__note>

	1992: A broader definition of "work" was adopted, that includes 
	"production for own consumption" and "construction for own use"
	
	1992: skip pattern introduced
	
</__note> */


*<_minlaborage_>
/* <_minlaborage_note>

	2001: 5
	PNADc: 14
	
</_minlaborage_note> */
	gen minlaborage = 14
	label variable minlaborage "Labor module application age"
*</_minlaborage_>

*----------8.1: 7 day reference overall----------------------------------------*

*<_lstatus_>
/* <_lstatus_note>
	
	Comparability throughout the years is compromised:
	"Trabalhou" (V9001) is compatible throughout, but "estava afastado" is not,
	due to skip pattern introduction and order change (V9004 in 1990's and V9002 in 2000's);
	With both, we get "tinha trabalho", which indicates employment/unemployment
	
	Until 2006: V4764 was V4755
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older
	
	2001: V4754 is V4754
	
</_lstatus_note> */
	gen lstatus = .
	replace lstatus = 1 if VD4002 == 1 & age >= minlaborage
	replace lstatus = 2 if VD4002 == 2 & age >= minlaborage
	replace lstatus = 3 if VD4001 == 2 & age >= minlaborage
	recast byte lstatus
	label variable lstatus "Labor status"
	label define lstatus_lab 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lstatus_lab
	drop VD4002 VD4001
*</_lstatus_>

*<_potential_lf_>
	gen potential_lf = VD4003
	recode potential_lf (2 = 0)
	recast byte potential_lf
	label variable potential_lf "Potential labour force status"
	label define potential_lf_lab 0 "No" 1 "Yes"
	label values potential_lf potential_lf_lab
*</_potential_lf_>

*<_underemployment_>
	gen underemployment = . // Check
	recast byte underemployment
	label variable underemployment "Underemployment status"
	label define underemployment_lab 0 "No" 1 "Yes"
	label values underemployment underemployment_lab
*</_underemployment_>

*<_nlfreason_>
	gen nlfreason = VD4023 
	recode nlfreason (2 = 1) (1 = 2) (4 = 3) (3 = 4) (5/6 = 5)
	recast byte nlfreason
	label variable nlfreason "Reason not in the labor force"
	label define nlfreason_lab 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason nlfreason_lab
*</_nlfreason_>

*<_unempldur_l_>
	gen unempldur_l = .
	label variable unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen unempldur_u = unempldur_l
	label variable unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>



*----------8.2: 7 day reference main job---------------------------------------*



*<_empstat_>
/* <_empstat_note>

	For all individuals
	
	Comparability throughout the years is compromised:
	Until 1992: "funcionários públicos estatutários" (public servants) and "militares" (army) could not be identified
	Until 1992: "trabalhadores domésticos" (domestic workers) inexisted
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)
	As of 1992: "production for own consumption" and "construction for own use" exist
	As of 2001: "empregado sem declaração de carteira" (probably) became "empregados sem carteira"
	As of 2001: "trabalhador doméstico sem declaração de carteira" (probably) became "trabalhadores domésticos sem carteira"
	
	2001: V4756 is V4756
	
</_empstat_note> */
	rename VD4008 empstat
	recode empstat (1/3 = 1) (6 = 2) (4 = 3) (5 = 4)
	replace empstat = . if lstatus != 1
	recast byte empstat
	label variable empstat "Employment status during past week primary 7 day recall"
	label define empstat_lab 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classified by status"
	label values empstat empstat_lab
*</_empstat_>

*<_industry_orig_>
/* <_industry_orig_note>

	CNAE-Domiciliar
	*Classificação Nacional de Atividades Econômicas (CNAE)
	
	Until 2006: V9907? was ?
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older?
	
	Comparability throughout the years is compromised:
	Until 2000: one set of codes (all throughout)
	2002: Adopted standardised set of codes (CNAE)
	
</_industry_orig_note> */
	gen str5 industry_orig = string(V4013, "%05.0f")
	replace industry_orig = "" if lstatus != 1 | age < minlaborage | industry_orig == "."
	label variable industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>

*</_industrycat_isic_>
	gen industrycat_isic = substr(industry_orig,1,2) + "00" if !missing(V4013)
	replace industrycat_isic = "4600" if inlist(industry_orig, "48010", "48020", "48076", "48078")
	replace industrycat_isic = "4700" if industrycat_isic == "4800"
	label variable industrycat_isic "ISIC code of primary job 7 day recall)"
*</_industrycat_isic_>

 
*</_industrycat_isic_30_>
	drop V4013
	gen V4013 = industry_orig

	merge m:1 V4013 using  "`path_input'\Ind_Corresp_2010s.dta" , nogen keep(1 3)

	gen industrycat_isic_30 = floor(v9997/10)*100
	label variable industrycat_isic_30 "ISIC rev 3.0 code of primary job 7 day recall)"
	tostring industrycat_isic_30, replace format(%05.0f)
	replace industrycat_isic_30 = substr(industrycat_isic_30,2,4)
	replace industrycat_isic_30 = "5000" if industry_orig == "48060"
	replace industrycat_isic_30 = "5100" if inlist(industry_orig, "48010", "48020", "48076", "48078")
	replace industrycat_isic_30 = "5200" if industrycat_isic_30 == "5300"
	drop v9997 V4013
*</_ industrycat_isic_30_>


*<_industrycat10_>
	gen industrycat10 = substr((industrycat_isic), 1, 2)
	destring industrycat10, replace
	replace industrycat10 =  1 if inrange(industrycat10,1,3)
	replace industrycat10 =  2 if inrange(industrycat10,5,9)
	replace industrycat10 =  3 if inrange(industrycat10,10,33)
	replace industrycat10 =  4 if inrange(industrycat10,35,39)
	replace industrycat10 =  5 if inrange(industrycat10,41,43)
	replace industrycat10 =  6 if inrange(industrycat10,45,47) | inrange(industrycat10,55,56)
	replace industrycat10 =  7 if inrange(industrycat10,49,53) | inrange(industrycat10,58,63)
	replace industrycat10 =  8 if inrange(industrycat10,64,75)
	replace industrycat10 =  9 if inrange(industrycat10,84,84)
	replace industrycat10 = 10 if inrange(industrycat10,85,99)
	recast int industrycat10
    replace industrycat10 = . if !inrange(industrycat10,1,10)
	label variable industrycat10 "1 digit industry classification, primary job 7 day recall"
	label define industrycat10_lab 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utility" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 industrycat10_lab
*</_industrycat10_>

*<_industrycat4_>
	gen industrycat4 = .
	replace industrycat4 = 1 if industrycat10 == 1
	replace industrycat4 = 2 if (industrycat10 == 2 | industrycat10 == 3 | industrycat10 == 4 | industrycat10 == 5)
	replace industrycat4 = 3 if (industrycat10 == 6 | industrycat10 == 7 | industrycat10 == 8 | industrycat10 == 9)
	replace industrycat4 = 4 if industrycat10 == 10
	label variable industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	label define industrycat4_lab 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 industrycat4_lab
*</_industrycat4_>

*<_occup_orig_>
	gen str4 occup_orig = string(V4010, "%04.0f") if !missing(V4010)
	replace occup_orig = "" if lstatus != 1 | age < minlaborage
	label variable occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = substr(occup_orig,1,2) + "00" if !missing(occup_orig)
	label variable occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_isco_88_>
	drop V4010
	gen V4010 = occup_orig
	merge m:1 V4010 using "`path_input'\isco_88_cod_DD.dta", nogen keep(1 3)
	gen occup_isco_88 = isco_88 + "00" if !missing(isco_88)
	label variable occup_isco_88 "ISCO-88 code of primary job 7 day recall"
	drop V4010 isco_88
*</_occup_isco_88_>

*<_occup_skill_>

	gen occup_skill = .
	replace occup_skill = 3 if lstatus == 1 & (substr(occup_isco, 1, 1) == "1" | substr(occup_isco, 1, 1) == "2" | substr(occup_isco, 1, 1) == "3")
	replace occup_skill = 2 if lstatus == 1 & (substr(occup_isco, 1, 1) == "4" | substr(occup_isco, 1, 1) == "5" | substr(occup_isco, 1, 1) == "6" | substr(occup_isco, 1, 1) == "7" | substr(occup_isco, 1, 1) == "8")
	replace occup_skill = 1 if lstatus == 1 & substr(occup_isco, 1, 1) == "9"
	recast byte occup_skill
	label variable occup_skill "Skill based on ISCO standard primary job 7 day recall"
	label define occup_skill_lab 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill occup_skill_lab
*</_occup_skill_>


*<_occup_>
	gen occup = .
	replace occup = 1 if lstatus == 1 & substr(occup_isco, 1, 1) == "1"
	replace occup = 2 if lstatus == 1 & substr(occup_isco, 1, 1) == "2"
	replace occup = 3 if lstatus == 1 & substr(occup_isco, 1, 1) == "3"
	replace occup = 4 if lstatus == 1 & substr(occup_isco, 1, 1) == "4"
	replace occup = 5 if lstatus == 1 & substr(occup_isco, 1, 1) == "5"
	replace occup = 6 if lstatus == 1 & substr(occup_isco, 1, 1) == "6"
	replace occup = 7 if lstatus == 1 & substr(occup_isco, 1, 1) == "7"
	replace occup = 8 if lstatus == 1 & substr(occup_isco, 1, 1) == "8"
	replace occup = 9 if lstatus == 1 & substr(occup_isco, 1, 1) == "9"
	replace occup = 0 if lstatus == 1 & substr(occup_isco, 1, 1) == "10"
	recast byte occup
	label variable occup "1 digit occupational classification, primary job 7 day recall"
	label define occup_lab 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces" 99 "Others"
	label values occup occup_lab
*</_occup_>

*<_ocusec_>
/* <_ocusec_note>

	Do NOT code basis of occupation (ISCO) or industry (ISIC) code
	
</_ocusec_note> */
	rename V4012 ocusec
	recode ocusec (2 = 1) (1 3 5/7 = 2) (4 = 4)
	recast byte ocusec
	label variable ocusec "Sector of activity primary job 7 day recall"
	label define ocusec_lab 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec ocusec_lab
*</_ocusec_>

*<_wage_no_compen_>
/* <_wage_no_compen_note>
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist

</_wage_no_compen_note> */
	rename V403412 wage_no_compen
	replace wage_no_compen = . if lstatus != 1 | age < minlaborage
	replace wage_no_compen = 0 if empstat == 2
	replace wage_no_compen = . if wage_no_compen > 999000000000
	format wage_no_compen %12.0f
	label variable wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>

*<_unitwage_>
	gen unitwage = 5
	replace unitwage = . if lstatus != 1
	recast byte unitwage
	label variable unitwage "Last wage's time unit primary job 7 day recall"
	label define unitwage_lab 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonths" 5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage unitwage_lab
*</_unitwage_>

*<_whours_>
	rename V4039 whours
	replace whours = . if lstatus != 1
	label variable whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wmonths_>
	gen wmonths = . // V9612 + 12*V9611
	*replace wmonth = . if lstatus != 1 | wmonths > 12
	label variable wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>

*<_contract_>
/* <_contract_note>
	
	Comparability throughout the years is compromised:
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)
</_contract_note> */
	gen contract = 0
	replace contract = 1 if VD4009 == 1 | VD4009 == 3 | VD4009 == 5 | VD4009 == 7
	replace contract = . if lstatus != 1
	label variable contract "Employment has contract primary job 7 day recall"
	label define contract_lab 0 "Without contract" 1 "With contract"
	label values contract contract_lab
*</_contract_>

*<_wage_total_>
/* <_wage_total_note>

	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
	2001: V4718 is V4768
	
	13º salário
	
</_wage_total_note> */
	gen wage_total = . //wage_no_compen*wmonths
	*replace wage_total = wage_total + wage_no_compen if wmonths == 12 & contract == 1
	label variable wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>

*<_healthins_>
	gen healthins = . 
	label variable healthins "Employment has health insurance primary job 7 day recall"
	label define healthins_lab 0 "Without health insurance" 1 "With health insurance"
	label values healthins healthins_lab
*</_healthins_>

*<_socialsec_>
	rename V4032 socialsec // [2001: 4761]
	recode socialsec (2 = 0) (1 = 1)
	replace socialsec = . if lstatus != 1
	label variable socialsec "Employment has social security insurance primary job 7 day recall"
	label define socialsec_lab 0 "With social security" 1 "Without social security"
	label values socialsec socialsec_lab
*</_socialsec_>

*<_union_>
	gen union = .
	label variable union "Union membership at primary job 7 day recall"
	label define union_lab 0 "Not union member" 1 "Union member"
	label values union union_lab
*</_union_>

*<_firmsize_l_>
	gen firmsize_l = .
	recast byte firmsize_l
	label variable firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>

*<_firmsize_u_>
	gen firmsize_u = firmsize_l
	label variable firmsize_u "Firm size (upperr bracket) primary job 7 day recall"
*</_firmsize_u_>



*----------8.3: 7 day reference secondary job----------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
/* <_empstat_2_note>

	For all individuals
	
</_empstat_2_note> */
	gen empstat_2 = V4043
	recode empstat_2 (1/4 = 1) (5 = 3) (6 = 4) (7 = 2)
	replace empstat_2 = . if lstatus != 1
	recast byte empstat_2
	label variable empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 empstat_lab
*</_empstat_2_>

*<_industry_orig_2_>
/* <_industry_orig_2_note>

	CNAE-Domiciliar
	*Classificação Nacional de Atividades Econômicas (CNAE)
	
</_industry_orig_2_note> */
	gen str5 industry_orig_2 = string(V4044, "%05.0f")
	replace industry_orig_2 = "" if lstatus != 1 | age < minlaborage | industry_orig_2 == "."
	label variable industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>

*</_industrycat_isic_2_>
	gen industrycat_isic_2 = substr(industry_orig_2,1,2) + "00" if !missing(V4044)
	replace industrycat_isic_2 = "4600" if inlist(industry_orig_2, "48010", "48020", "48076", "48078")
	replace industrycat_isic_2 = "4700" if industrycat_isic_2 == "4800"
	label variable industrycat_isic_2 "ISIC code of secondary job 7 day recall)"
*</_industrycat_isic_2_>

 
*</_industrycat_isic_30_2_>
	gen V4013 = industry_orig_2

	merge m:1 V4013 using  "`path_input'\Ind_Corresp_2010s.dta" , nogen keep(1 3)

	gen industrycat_isic_30_2= floor(v9997/10)*100
	label variable industrycat_isic_30_2 "ISIC rev 3.0 code of primary job 7 day recall)"
	tostring industrycat_isic_30_2, replace format(%05.0f)
	replace industrycat_isic_30_2 = substr(industrycat_isic_30_2,2,4)
	replace industrycat_isic_30_2 = "5000" if industry_orig_2 == "48060"
	replace industrycat_isic_30_2 = "5100" if inlist(industry_orig_2, "48010", "48020", "48076", "48078")
	replace industrycat_isic_30_2 = "5200" if industrycat_isic_30_2 == "5300"
	drop v9997 V4013
*</_industrycat_isic_30_2_>


*<_industrycat10_2_>
	gen industrycat10_2 = substr((industrycat_isic_2), 1, 2)
	destring industrycat10_2, replace
	replace industrycat10_2 =  1 if inrange(industrycat10_2,1,3)
	replace industrycat10_2 =  2 if inrange(industrycat10_2,5,9)
	replace industrycat10_2 =  3 if inrange(industrycat10_2,10,33)
	replace industrycat10_2 =  4 if inrange(industrycat10_2,35,39)
	replace industrycat10_2 =  5 if inrange(industrycat10_2,41,43)
	replace industrycat10_2 =  6 if inrange(industrycat10_2,45,47) | inrange(industrycat10_2,55,56)
	replace industrycat10_2 =  7 if inrange(industrycat10_2,49,53) | inrange(industrycat10_2,58,63)
	replace industrycat10_2 =  8 if inrange(industrycat10_2,64,75)
	replace industrycat10_2 =  9 if inrange(industrycat10_2,84,84)
	replace industrycat10_2 = 10 if inrange(industrycat10_2,85,99)
	recast int industrycat10_2
    replace industrycat10_2 = . if !inrange(industrycat10_2,1,10)
	label variable industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 industrycat10_lab
*</_industrycat10_2_>

*<_industrycat4_2_>
	gen industrycat4_2 = .
	replace industrycat4_2 = 1 if industrycat10_2 == 1
	replace industrycat4_2 = 2 if (industrycat10_2 == 2 | industrycat10_2 == 3 | industrycat10_2 == 4 | industrycat10_2 == 5)
	replace industrycat4_2 = 3 if (industrycat10_2 == 6 | industrycat10_2 == 7 | industrycat10_2 == 8 | industrycat10_2 == 9)
	replace industrycat4_2 = 4 if industrycat10_2 == 10
	label variable industrycat4_2 "Broad Economic Activity classification, secondary job 7 day recall"
	label values industrycat4_2 industrycat4_lab
*</_industrycat4_2_>

*<_occup_orig_2_>
	gen str4 occup_orig_2 = string(V4041, "%04.0f") if !missing(V4041)	
	replace occup_orig_2 = "" if lstatus != 1 | age < minlaborage
	label variable occup_orig_2 "Original occupational record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = substr(occup_orig_2,1,2) + "00" if !missing(occup_orig_2)	
	label variable occup_isco_2 "ISCO code of seconday job 7 day recall"
*</_occup_isco_2_>

*<_occup_isco_88_2_>
	gen V4010 = occup_orig_2
	merge m:1 V4010 using "`path_input'\isco_88_cod_DD.dta", nogen keep(1 3)
	gen occup_isco_88_2 = isco_88 + "00" if !missing(isco_88)
	label variable occup_isco_88_2 "ISCO-88 code of secondary job 7 day recall"
	drop V4041 isco_88
*</_occup_isco_88_2_>

*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 3 if lstatus == 1 & (substr(occup_isco_2, 1, 1) == "1" | substr(occup_isco_2, 1, 1) == "2" | substr(occup_isco_2, 1, 1) == "3")
	replace occup_skill_2 = 2 if lstatus == 1 & (substr(occup_isco_2, 1, 1) == "4" | substr(occup_isco_2, 1, 1) == "5" | substr(occup_isco_2, 1, 1) == "6" | substr(occup_isco_2, 1, 1) == "7" | substr(occup_isco_2, 1, 1) == "8")
	replace occup_skill_2 = 1 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "9"
	recast byte occup_skill_2
	label variable occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
	label values occup_skill_2 occup_skill_lab
*</_occup_skill_2_>


*<_occup_2_>

	gen occup_2 = .
	replace occup_2 = 1 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "1"
	replace occup_2 = 2 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "2"
	replace occup_2 = 3 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "3"
	replace occup_2 = 4 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "4"
	replace occup_2 = 5 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "5"
	replace occup_2 = 6 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "6"
	replace occup_2 = 7 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "7"
	replace occup_2 = 8 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "8"
	replace occup_2 = 9 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "9"
	replace occup_2 = 0 if lstatus == 1 & substr(occup_isco_2, 1, 1) == "10"
	recast byte occup_2
	label variable occup_2 "1 digit occupational classification, secondary job 7 day recall"
	label values occup_2 occup_lab
*</_occup_2_>

*<_ocusec_2_>
/* <_ocusec_2_note>

	Do NOT code basis of occupation (ISCO) or industry (ISIC) code
	
</_ocusec_2_note> */
	rename V4043 ocusec_2
	recode ocusec_2 (2 = 1) (1 3 5/7 = 2) (4 = 4)
	recast byte ocusec_2
	label variable ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 ocusec_lab
*</_ocusec_2_>

*<_wage_no_compen_2_>
/* <_wage_no_compen_2_note>
	
	Prefer using gross wages, rather than net wages
	
	1980's: doesn't exist (only "Primary" and "All Other" jobs do)
	
</_wage_no_compen_2_note> */
	rename V405012 wage_no_compen_2
	replace wage_no_compen_2 = . if lstatus != 1 | age < minlaborage
	replace wage_no_compen_2 = 0 if empstat == 2
	replace wage_no_compen_2 = . if wage_no_compen_2 > 999000000000
	format wage_no_compen_2 %12.0f
	label variable wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>

*<_unitwage_2_>
	gen unitwage_2 = 5
	replace unitwage_2 = . if lstatus != 1
	recast byte unitwage_2
	label variable  unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 unitwage_lab
*</_unitwage_2_>

*<_whours_2_>
	rename V4056 whours_2
	replace whours_2 = . if lstatus != 1
	label variable whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>

*<_wmonths_2_>
	gen wmonths_2 = .
	label variable wmonths_2 "Months of work in the past 12 months secondary job 7 day recall"
*</_wmonths_2_>

*<_wage_total_2_>
/* <_wage_total_2_note>

	1980's: doesn't exist (only "Primary" and "All Other" jobs do)
	
	Prefer using gross wages, rather than net wages
	
</_wage_total_2_note> */
	gen wage_total_2 = . // wage_no_compen_2*wmonths_2
	*replace wage_total_2 = wage_total_2 + wage_no_compen_2 if wmonth_2s == 12 & contract_2 == 1
	label variable wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>

*<_firmsize_l_2_>/
	gen firmsize_l_2 = .
	recast byte firmsize_l_2
	label variable firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>

*<_firmsize_u_2_>
	gen firmsize_u_2 = firmsize_l_2
	label variable firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>
}

*----------8.4: 7 day reference additional jobs--------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_t_hours_others_>
	gen t_hours_others = 52*V4062
	replace t_hours_others = . if lstatus != 1
	label variable t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
	drop V4062
*</_t_hours_others_>

*<_t_wage_nocompen_others_>
/* <_t_wage_nocompen_others_note>

	There are no wmonths_others and empstat_others
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_t_wage_nocompen_others_note> */
	replace V405922 = . if lstatus != 1 | age < minlaborage
*	replace V1022 = 0 if empstat_others == 2	
	gen t_wage_nocompen_others = . // wmonths_others*V1022
	label variable t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>

*<_t_wage_others_>
/* <_t_wage_others_note>

	There are no wmonths_others and empstat_others
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_t_wage_others_note> */
	replace V405912 = . if lstatus != 1 | age < minlaborage
*	replace V1025 = 0 if empstat_others == 2
	gen t_wage_others = . // wmonths_others*V1025 + t_wage_nocompen_others
	label variable t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>
}

*----------8.5: 7 day reference total summary----------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_t_hours_total_>
	gen t_hours_total = 52*(whours + whours_2) + t_hours_others
	replace t_hours_total = . if lstatus != 1
	label variable t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>

*<_t_wage_nocompen_total_>
/* <_t_wage_nocompen_total_note>

	There are no wmonths_total and empstat_total
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_nocompen_total_note> */
	gen t_wage_nocompen_total = . // wage_no_compen + wage_no_compen_2 + t_wage_nocompen_others
	label variable t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>

*<_t_wage_total_>
/* <_t_wage_total_note>

	There are no wmonths_total and empstat_total
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
	2001: 4719 is 4769
	
</_t_wage_total_note> */
	gen t_wage_total = . // (wage_total + wage_total_2 + t_wage_others)*wmonths_total or V4769*wmonths_total?
	label variable t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>
}

*----------8.6: 12 month reference overall-------------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


/* <__note>

	1992: A broader definition of "work" was adopted, that includes 
	"production for own consumption" and "construction for own use"
	
	1992: skip pattern introduced
	
</__note> */

*<_lstatus_year_>
/* <_lstatus_year_note>
	
	Comparability throughout the years is compromised:
	"Trabalhou" (V9001) is compatible throughout, but "estava afastado" is not,
	due to skip pattern introduction and order change (V9004 in 1990's and V9002 in 2000's);
	With both, we get "tinha trabalho", which indicates employment/unemployment
	
	Until 2006: V4764 was V4764
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older
	
	2001: V4763 is V4763
	
</_lstatus_year_note> */
	gen lstatus_year = .
	recast byte lstatus
	label variable lstatus_year "Labor status during last year"
	label values lstatus_year lstatus_lab
*</_lstatus_year_>

*<_potential_lf_year_>
	gen potential_lf_year = .
	recast byte potential_lf_year
	label variable potential_lf_year "Potential labour force status during last year"
	label values potential_lf_year potential_lf_lab
*</_potential_lf_year_>

*<_underemployment_year_>
	gen underemployment_year = .
	recast byte underemployment_year
	label variable underemployment_year "Underemployment status during last year"
	label values underemployment_year underemployment_lab
*</_underemployment_year_>

*<_nlfreason_year_>
	gen nlfreason_year = .
	recast byte nlfreason_year
	label variable nlfreason_year "Reason not in the labor force during last year"
	label values nlfreason_year nlfreason_lab
*</_nlfreason_year_>

*<_unempldur_l_year_>
	gen unempldur_l_year = .
	label variable unempldur_l_year "Unemployment duration (months) during last year lower bracket"
*</_unempldur_l_year_>

*<_unempldur_u_year_>
	gen unempldur_u_year = unempldur_l_year
	label variable unempldur_u_year "Unemployment duration (months) during last year upper bracket"
*</_unempldur_u_year_>


*----------8.7: 12 month reference main job------------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_empstat_year_>
	gen empstat_year = .
	replace empstat_year = . if lstatus_year != 1
	label variable empstat_year "Employment status during past week primary job 12 month recall"
	label values empstat_year empstat_lab
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


*<_wage_no_compen_year_> 
	gen double wage_no_compen_year = .
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen unitwage_year = .
	recast byte unitwage_year
	label variable unitwage_year "Last wage's time unit primary job 12 month recall"
	label values unitwage_year unitwage_lab
*</_unitwage_year_>

*<_whours_year_>
	gen whours_year = .
	label variable whours_year "Hours of work in last week primary job 12 mon recall"
*</_whours_year_>

*<_wmonths_year_>
	gen wmonths_year = .
	label variable wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>

*<_wage_total_year_>
/* <_wage_total_year_note>

	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_wage_total_year_note> */
	gen wage_total_year = .
	label variable wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>

*<_contract_year_>
/* <_contract_year_note>
	
	Comparability throughout the years is compromised:
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)
	
</_contract_year_note> */
	gen contract_year =.
	label variable contract_year "Employment has contract primary job 12 month recall"
	label values contract_year contract_lab
*</_contract_year_>

*<_healthins_year_>
	gen healthins_year = .
	label variable healthins_year "Employment has health insurance primary job 12 month recall"
	label values healthins_year healthins_lab
*</_healthins_year_>

*<_socialsec_year_>
	gen socialsec_year = .
	label variable socialsec_year "Employment has social security insurance primary job 12 month recall"
	label values socialsec_year socialsec_lab
*</_socialsec_year_>

*<_union_year_>
	gen union_year =.
	replace union_year = . if lstatus_year != 1
	label variable union_year "Union membership at primary job 12 month recall"
	label values union_year union_lab
*</_union_year_>

*<_firmsize_l_year_>
	gen firmsize_l_year = .
	recast byte firmsize_l_year
	label variable firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>

*<_firmsize_u_year_>
	gen firmsize_u_year = firmsize_l_year
	label variable firmsize_u_year "Firm size (upper bracket), primary job 12 month recall"
*</_firmsize_u_year_>	


*----------8.8: 12 month reference secondary job-------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


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
	gen unitwage_2_year = .
	recast byte unitwage_2_year
	label variable unitwage_2_year "Last wage' time unit secondary job 12 month recall"
	label values unitwage_2_year unitwage_lab
*</_unitwage_2_year_>

*<_whours_2_year_>
	gen whours_2_year = .
	label variable whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>

*<_wmonths_2_year_>
	gen wmonths_2_year = .
	label variable wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>

*<_wage_total_2_year_>
/* <_wage_total_2_year_note>

	1980's: doesn't exist (only "Primary" and "All Other" jobs do)
	
	Prefer using gross wages, rather than net wages
	
</_wage_total_2_year_note> */
	gen wage_total_2_year = .
	label variable wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	recast byte firmsize_l_2_year
	label variable firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = firmsize_l_2_year
	label variable firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>


*----------8.9: 12 month reference additional jobs-----------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_t_hours_others_year_>
	gen t_hours_others_year = .
	label variable t_hours_others_year "Annualized hours worked in all but primary and secondary job 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
/* <_t_wage_nocompen_others_year_note>

	There are no wmonths_others_year and empstat_others_year
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_t_wage_nocompen_others_year_note> */
	gen t_wage_nocompen_others_year = .
	label variable t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
/* <_t_wage_others_year_note>

	There are no wmonths_others_year and empstat_others_year
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_t_wage_others_year_note> */
	gen t_wage_others_year = .
	label variable t_wage_others_year "Annualized wage in all but primary and secondary job 12 month recall"
*</_t_wage_others_year_>
}

*----------8.10: 12 month total summary----------------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_t_hours_total_year_>
	gen t_hours_total_year = .
	label variable t_hours_total_year "Annualized hours worked in all job 12 month recall"
*</_t_hours_total_year_>

*<_t_wage_nocompen_total_year_>
/* <_t_wage_nocompen_total_year_note>

	There are no wmonths_total_year and empstat_total_year
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_t_wage_nocompen_total_year_note> */
	gen t_wage_nocompen_total_year = .
	label variable t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>

*<_t_wage_total_year_>
/* <_t_wage_total_year_note>

	There are no wmonths_total_year and empstat_total_year
	
	Prefer using gross wages, rather than net wages
	
	1980's: only "Primary" and "All Other" jobs exist
	
</_t_wage_total_year_note> */
	gen t_wage_total_year = .
	label variable t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>
}

*----------8.11: Overall across reference periods------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_njobs_>
/* <_njobs_note>

	1 = one; 3 = two; 5 = 3 or more
	
</_njobs_note> */
	rename V4009 njobs
	recode njobs (1 = 1) (3 = 2) (5 = 3) // 3 = 3+
	label variable njobs "Total number of jobs"
*</_njobs_>

*<_t_hours_annual_>
	gen t_hours_annual = .
	label variable t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>

*<_linc_nc_>
	gen linc_nc = .
	label variable linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>

*<_laborincome_>
	gen laborincome = .
	label variable laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
 *</_laborincome_>
}

*----------8.13: Labour cleanup------------------------------------------------*

{
*<_% Correction min age_> 

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_var "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach v of local lab_var {
		cap confirm numeric variable `v'
		if _rc == 0 { // is indeed numeric
			replace `v'= . if (age < minlaborage & !missing(age))
		}
		else { // is not
			replace `v'= "" if (age < minlaborage & !missing(age))
		}

	}

*</_% Correction min age_>
}


/*%%============================================================================
   9: Final steps
============================================================================%%*/


quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat_isic_30 industrycat10 industrycat4 occup_orig occup_isco occup_isco_88 occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat_isic_30_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_isco_88_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat_isic_30 industrycat10 industrycat4 occup_orig occup_isco occup_isco_88 occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat_isic_30_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_isco_88_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

	set trace on
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
	set trace off


*</_% DROP UNUSED LABELS_>

}


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% DELETE MISSING VARIABLES_>

quietly: describe, varlist
local kept_vars `r(varlist)'

foreach var of local kept_vars {
   capture assert missing(`var')
   if !_rc drop `var'
}

*</_% DELETE MISSING VARIABLES_>


*<_% SAVE_>

	save "`path_output'\BRA_2013_PNADC_V01_M_V03_A_GLD_ALL.dta", replace
	clear

*</_% SAVE_>



*-------------------------------------------------------------------------------