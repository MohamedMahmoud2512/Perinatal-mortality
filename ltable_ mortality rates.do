

*1- total
*********
global     det  "region country dhs survey  tot"



qui        { 
use        "$drv_dta\Analysis_file.dta"

lab        def Cage_lbl 1 "<25" 2 "25-29" 3 "30+"
lab        val   conc_age_GRP Cage_lbl 

recode     num_livebirth (0/1=1) (2/10=2)

*recode     cal_group (2021/2023=7)
recode     cal_group (1/4=1) (5/6=2)(7/8=3)
lab        def cal_group 1 "<2005" 2 "2005-2014" 3 "<2015+", modify

keep      $det  swt age0 age  stillbirth livebirth e_neo l_neo neonate perinatal infant new_inf  new_neo death
sort      $det
cap       save $drv_dta\lt_data, replace 


*1- still birth:-life table rates
*********************************
use       $drv_dta\lt_data, clear 
qui       stset     age [iw=swt], failure(stillbirth==1)
sts       gen       f=s , by($det)
keep      $det   _t f

sort      $det _t
replace   f=(1-f)*1000 
keep      if _t==9
qui       by $det : keep if _n==_N

gen       lt=1
cap       save $drv_dta\lt_result, replace 


*2- Death at day zero
*********************
use       $drv_dta\lt_data, clear
drop      if livebirth==0
qui       stset     age [iw=swt], failure(e_neo==1)
sts       gen       f=s , by($det)
keep      $det  _t f

replace   f=(1-f)*1000 
sort      $det _t
keep      if _t<=2
qui       by $det  : keep if _n==_N

gen       lt=2
append    using  $drv_dta\lt_result 
cap       save $drv_dta\lt_result, replace 


*3- stillbirth and death on day zero and day 1
**********************************************
use       $drv_dta\lt_data, clear 
qui       stset     age [iw=swt], failure(perinatal==1)
sts       gen       f=s , by($det)
keep      $det   _t f

sort      $det _t
replace   f=(1-f)*1000 
keep      if _t<=3
qui       by $det : keep if _n==_N

gen       lt=3
append    using  $drv_dta\lt_result 
cap       save $drv_dta\lt_result, replace 



*4- Death at day 0 and 1
************************
use       $drv_dta\lt_data, clear
drop      if livebirth==0
qui       stset     age [iw=swt], failure(e_neo==1)
sts       gen       f=s , by($det)
keep      $det  _t f

replace   f=(1-f)*1000 
sort      $det _t
keep      if _t<=3
qui       by $det  : keep if _n==_N

gen       lt=4
append    using  $drv_dta\lt_result 
cap       save $drv_dta\lt_result, replace 

*5- Death at day 2 and 6
************************
use       $drv_dta\lt_data, clear
drop      if livebirth==0
drop      if age<=3 & e_neo==1

qui       stset     age [iw=swt], failure(e_neo==1)
sts       gen       f=s , by($det)
keep      $det  _t f

replace   f=(1-f)*1000 
sort      $det _t
keep      if _t<=8
qui       by $det  : keep if _n==_N

gen       lt=5
append    using  $drv_dta\lt_result 
cap       save $drv_dta\lt_result, replace 


*7- perinatal mortality
***********************
use       $drv_dta\lt_data, clear
qui       stset     age [iw=swt], failure(perinatal==1)
sts       gen       f=s , by($det)
keep      $det  _t f

replace   f=(1-f)*1000 
sort      $det _t
keep      if _t<=8
qui       by $det  : keep if _n==_N

gen       lt=7
append    using  $drv_dta\lt_result 
cap       save $drv_dta\lt_result, replace 

*6- Early neonatal mortality
****************************
use       $drv_dta\lt_data, clear
drop      if livebirth==0
qui       stset     age [iw=swt], failure(e_neo==1)
sts       gen       f=s , by($det)
keep      $det  _t f

replace   f=(1-f)*1000 
sort      $det _t
keep      if _t<=8
qui       by $det  : keep if _n==_N

gen       lt=6
append    using  $drv_dta\lt_result 
cap       save $drv_dta\lt_result, replace 



drop      _t
sort     $det
reshape   wide f , i($det) j(lt)


sort      survey 
lab       var   f1  "Stillbirth rate" 
lab       var   f2  "Death day 0 rate" 
lab       var   f3  "Stillbirth & death day 0-1 rate"
lab       var   f4  "Death day 0-1 rate" 
lab       var   f5  "Death day 2-6 rate"
lab       var   f6  "Early neonatal rate" 
lab       var   f7  "Perinatal rate" 

rename    f* rate*

}


cap        save  "$drv_dta\lt_result_all.dta", replace
cap        erase "$drv_dta\lt_result.dta" 
cap        erase  "$drv_dta\lt_data.dta" 


