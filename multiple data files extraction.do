clear

global     DHS_IR   "C:\DHS\IR\ASIA\IA\IAIR74FL.DTA"    /* DHS individual record file */
global     drv_dta  "c:\GitHub"                         /* analysis file folder       */

global     cont=1                                       /* country code               */
global     dhs=1                                        /* DHS survey round           */


  
* 1- Background characteristcs
******************************
qui        {
use        "$DHS_IR", clear
#delimi    ;
keep       caseid 
v000       v001	v002  v003  v004	v005	v006	v007	v008	v011	v012	v013	v020	v021	v022	v023	v026	v028
v101	   v102	v103 v106	v107	v133	v136	v137	v149													
v190       v191
v201	   v208	v209	v210	v211	v212	v213	v214	v215	v216	v217	v218	v221	v222	v225	v226	v227	v228       v231	    v232	v235
v301	   v302	v310	v312	v313	v317	v319	v320	v321	v322	v326	v327	v337	
v359       v360 
v361	   v362	v363	v364	v367
v501	   v502	v503	v504	v505	v506	v507	v508	v509 v525 v531
v613
v701	   v705 awfactt
;
#delimit cr
sort       caseid
egen       wi3=cut(v191), group (3) icodes
replace    wi3=wi3+1
cap        save "$drv_dta\XXX_bgk0.dta", replace
           }
		   
* 2- Birth History
******************
qui        {
use        "$DHS_IR", clear	
keep       caseid v201-v235 bidx_* bord_* b0_* b1_* b2_* b3_* b4_* b5_* b6_* b7_* b8_* b9_* b10_* b11_* b12_* b13_*
rename     b*_0* b*_*

sort       caseid 
reshape    long  bidx_ bord_ b0_ b1_ b2_ b3_ b4_ b5_ b6_ b7_ b8_ b9_ b10_ b11_ b12_ b13_  , i(caseid) j(child)
drop       if  bidx_==.
drop       child 
sort       caseid 
rename     b*_ b*
cap        save "$drv_dta\XXX_bht0.dta", replace

* parity
**********
use      "$drv_dta\XXX_bht0.dta", clear
keep     case bi bo b0 b3 
sort     case b3
collapse (max) parity=b0 , by(caseid b3)
replace  parity=1 if parity==0

sort     case b3
gen      outcome=parity
gen      cmc_evn=b3

cap      save "$drv_dta\parity", replace

*Deaths
********
use      "$drv_dta\XXX_bht0.dta", clear
replace  b5=0 if b5==. & b6!=.   
keep     case   b3 b5 b7
keep     if b5==0

gen      cmc_dod=b3+b7
keep     caseid cmc_dod
sort     case cmc_dod
qui      by caseid cmc_dod: gen b0=_n

collapse (max) deaths=b0 , by(caseid cmc_dod)
sort     case cmc_dod
gen      outcome=-deaths
gen      cmc_evn=cmc_dod
cap      save "$drv_dta\deaths", replace

*append  parity  & death
************************
appen    using  "$drv_dta\parity"
order    caseid cmc_evn outcome b3 cmc_dod 
gsort     +caseid +cmc_evn -outcome
qui      by caseid: gen livchd=sum(outcome)
drop     b3 parity cmc_dod
collapse (min) livchd, by(caseid cmc_evn)
cap      save "$drv_dta\XXX_lch0" , replace

         }



* 3 Health 
***********
qui        { 
use        "$DHS_IR", clear
keep       caseid   midx_* m4_*    m5_*    m6_*    m7_* m8_*    m9_*    m10_*   m11_*   m15_* v602  v603  v604  v605  v613  v614  v616  v621
reshape    long  midx_ m4_ m5_ m6_ m7_ m8_ m9_ m10_ m11_ m15_, i(caseid) j(child)
rename     midx bidx
drop       if  bidx==. | bidx==0
drop       child 
sort       caseid  bidx
rename     m*_   m*
recode     m15 (10/19=1)( 20/29=2) (30/39=3)(90/99=4)
*1 home, 2 govn facility, 3 private facility 4=others 

cap        save "$drv_dta\XXX_hlt0.dta", replace
           } 


*4 Calendar
**********
qui        { 
use        "$DHS_IR", clear
keep       caseid  v005 v008 v017 v018 v019 v020 v312 v359 v360 vcal_1
sort       caseid
cap        save "$drv_dta\XXX_cal0.dta", replace
drop       if v005==0
drop	   if	vcal_1==""
sort       caseid
keep       caseid v019 vcal_1

cap       prog drop cal_1
prog      def      cal_1

qui       {
           local i=1
           while `i'<=80 {
                  cap drop t1_`i'
                  gen str1 t1_`i' =substr(vcal_1,80-`i'+1,1)
                  local i=`i'+1          
          }
          drop     vcal_1
          sort     caseid
          reshape  long t1_ , i(caseid) j(month)
          drop     if month>v019  
       
          }
end
cal_1

lab        var month "Month calendar begins 5+ years ago"
sort       caseid month
replace    t1_="50" if  t1_=="P"
replace    t1_="51" if  t1_=="T"
replace    t1_="52" if  t1_=="B"
cap        drop c1_      
gen        byte c1_ =real(t1_)
drop       if c1_==0 |c1_==. | c1_<50
cap        drop t1_ 
cap        save "$drv_dta\XXX_preg0.dta", replace 
		   }		

