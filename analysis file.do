
clear

qui        { 
use        "$drv_dta\XXX_preg3.dta", clear 

*Data quality statified by covariate
************************************
global     covar "tot"   /*tot is oveall DQ: you can also use other varaibles such as v102 v106 wi3 etc  */
do         "$drv_dta\DQ_covar.do"
sort       country  $covar
cap        save   "$drv_dta\DQ_$covar", replace

          }
		  
	  

qui {

use        "$drv_dta\XXX_preg3.dta",clear 	

drop       if age==1 & preg_o==3
drop       if age>1 & preg_o==2


recode     v106 8/9= 0 .=0 3/6=2 

replace    death=1 if b5==0 & death==0 & livebirth==1


replace    v007=2000+v007 if v007<10
replace    v007=1900+v007 if v007<100
replace    v007=2006 if  v000=="NP5"
replace    v007=2011 if  v000=="NP6"
replace    v007=2016 if  v000=="NP7"

recode     country (101/199=1 "Sub-Saharan Africa") (201/299=2 "North Africa Western Asia and Europe")( 301/309=3 "Central Asia")(311/399=4 "South & Southeast Asia")(401/499=5 "Latin America & Caribbean"),g(region)
gen        cal_birth=floor(b3/12)+1900

recode     cal_birth (1984/1989=1 "1985/89") (1990/1994=2 "1990/94")(1995/1999=3 "1995/99")(2000/2004=4 "2000/04")(2005/2009=5 "2005/09")(2010/2014=6 "2010/14")(2015/2019=7 "2015/19") (2020/2024=8 "2020/24"), g(cal_group)


lab        var survey          "Survey unique ID"
lab        var cal_birth       "Year of birth " 
lab        var cal_group       "Year of birth-Grouped" 
lab        var e_neo           "Early neonatal mortality"
lab        var l_neo           "Late neonatal mortality"
lab        var neonate         "Neonatal mortality"
lab        var perinatal       "Perinatal mortality"
lab        var p_neo           "Post-neonatal mortality"
lab        var new_neo         "Extended neonatal mortality"
lab        var new_inf         "extendedinfant mortality"
lab        var stillbirth      "Stillbirth 7+ months"
lab        var currently_preg  "Currently pregnany 7+"
lab        var livebirth       "Live birth"
lab        var infant          "Infant mortality"
lab        var preterm         "Preterm live birth" 
lab        var age0            "Gestational age"
lab        var age             "Current age/age at death"
lab        var tot             "value ONE for summary statistics"

cap        drop month_st month _preg_b3_birth_b3_match u_l_end win2 year_2 year_3 abortion 

sort       country $covar
merge      m:1 country $covar using  "$drv_dta\DQ_$covar"
cap        drop _m 
cap        save  "$drv_dta\Analysis_file.dta", replace

}

