

qui {
set        seed  987654321

*Exclude   gestational age of less than 7 monts
************************************************
drop       if gest<7    /* including all gestational age */

* Analayis windocalendar of conception *    
**************************
gen        u_l_end=v008-preg_st+1
gen        win1=1
replace    win1=0 if  u_l_end>66 | u_l_end<7    /* conception between month  7 and 66 of the calendar FIVE years */

* outcomes of pregnancy
***********************
gen        abortion=0
replace    abortion=1          if preg_out==2 & gest<7

gen        stillbirth=0
replace    stillbirth=1        if preg_out==2  & abortion==0

gen        currently_preg=0
replace    currently_preg=1    if preg_out==1

gen        livebirth=0
replace    livebirth=1         if preg_out==3 

drop       if livebirth==1 & gest<6    /* livebirth with gestational age<6 month excluded -extreme preterm birth*/ 
 
* RISK of Death  
****************
gen        e_neo=.
replace    e_neo=0  if livebirth==1
replace    e_neo=1  if livebirth==1 & b6<107
           
gen        l_neo=.
replace    l_neo=0  if livebirth==1 
replace    l_neo=1  if livebirth==1 & (b6>106 & b6<128)
replace    l_neo=.  if e_neo==1
           
gen        neonate=.
replace    neonate=0  if livebirth==1
replace    neonate=1  if e_neo==1 | l_neo==1
           
gen        perinatal=0
replace    perinatal=1 if stillbirth==1 | e_neo==1
           
gen        infant=0
replace    infant=1  if livebirth==1 & b7<12     
replace    infant=.  if livebirth==0

gen        p_neo=0
replace    p_neo=1 if  infant==1 & neonate==0
replace    p_neo=.  if livebirth==0


gen        year_2=0
replace    year_2=1  if livebirth==1 & (b7>=12 &b7<24)     
replace    year_2=.  if livebirth==0

gen        year_3=0
replace    year_3=1  if livebirth==1 & (b7>=24 &b7<36)     
replace    year_3=.  if livebirth==0


*Preterm is defined as babies born alive before 37 weeks of pregnancy are completed. There are sub-categories of preterm birth, based on gestational age:
		*3= extremely preterm (less than 28 weeks)      6months
		*2= very preterm (28 to 32 weeks)               7months
		*1= moderate to late preterm (32 to 37 weeks).  8months
		*0= full term                                   9-10 months
		*.= nonlivebirth or current pregnancy 
		
gen        preterm=1
replace    preterm=0 if gest>=9
replace    preterm=. if preg_out<3 

gen        sev_preterm=0
replace    sev_preterm=3  if gest==6
replace    sev_preterm=2  if gest==7
replace    sev_preterm=1  if gest==8
replace    sev_preterm=.  if preg_out<3


* extended neontal and infant mortality
***************************************
gen        new_neo=neonate
replace    new_neo=1 if stillbirth==1
           
gen        new_inf=infant
replace    new_inf=1 if still==1

gen        death=0
replace    death=1 if   stillbirth==1
replace    death=1 if   e_neo     ==1
replace    death=1 if   l_neo     ==1
replace    death=1 if   p_neo     ==1
replace    death=1 if   year_2    ==1
replace    death=1 if   year_3    ==1

*corrections
replace    b6=floor(runiform()*14)+114 if b6>127 & b7==0  
          /* imputing  age at death greater than 27 days and also equal to zero month to be between 14-27 dasy */

*Age at death or current age
****************************
gen        age0=gest

*age starting from 1
gen         age=1                                                                /* time during gestation 7- 10 months 1=montg*/

*age at death after birth
replace     age=age+(b6-100)+1                         if (b5==0 & b7==0)        /* age at death during 0-27days--- day zero=2,...,27=29 */
replace     age=b7+29                                  if (b5==0 & b7>0 )        /* age after day 27 day 30- months*/ 

*current age 
replace     age=floor(runiform()*14)+16                 if (b5==1 & v008==b3)     /* current age one month old in days 11-27       */ 
replace     age=(v008-b3)           +29                if (b5==1 & v008>b3 )     /* current age older tha one month         */
         
gen         tot=1
#delimit ;
lab        def age_lbl		
			1	"month 7-9"
			2	"day     0"
			3	"day     1"
			4	"day     2"
			5	"day     3"
			6	"day     4"
			7	"day     5"
			8	"day     6"
			9	"day     7"
			10	"day     8"
			11	"day     9"
			12	"day    10"
			13	"day    11"
			14	"day    12"
			15	"day    13"
			16	"day    14"
			17	"day    15"
			18	"day    16"
			19	"day    17"
			20	"day    18"
			21	"day    19"
			22	"day    20"
			23	"day    21"
			24	"day    22"
			25	"day    23"
			26	"day    24"
			27	"day    25"
			28	"day    26"
			29	"day    27"
			30	"month   1"
			31	"month   2"
			32	"month   3"
			33	"month   4"
	        34	"month   5"
	        35	"month   6"
	        36	"month   7"
	        37	"month   8"
	        38	"month   9"
	        39	"month  10"
	        40	"month  11"
	        41	"month  12"
	        42	"month  13"
	        43	"month  14"
	        44	"month  15"
	        45	"month  16"
	        46	"month  17"
	        47	"month  18"
	        48	"month  19"
	        49	"month  20"
	        50	"month  21"
	        51	"month  22"
	        52	"month  23"
	        53	"month  24"
	        54	"month  25"
	        55	"month  26"
	        56	"month  27"
	        57	"month  28"
	        58	"month  29"
	        59	"month  30"
	        60	"month  31"
	        61	"month  32"
	        62	"month  33"
	        63	"month  34"
	        64	"month  35"
	        65	"month  36"
	        66	"month  37"
	        67	"month  38"
	        68	"month  39"
	        69	"month  40"
	        70	"month  41"
	        71	"month  42"
	        72	"month  43"
	        73	"month  44"
	        74	"month  45"
	        75	"month  46"
	        76	"month  47"
	        77	"month  48"
	        78	"month  49"
	        79 	"month  50"
	        80 	"month  51"
	        81 	"month  52"
	        82 	"month  53"
	        83 	"month  54"
	        84 	"month  55"
	        85 	"month  56"
	        86 	"month  57"
	        87 	"month  58"
	        88 	"month  59"

;

#delimit cr		
lab val age age_lbl
compress


drop       if age==1 & preg_o==3
drop       if age>1 & preg_o==2


recode     v106 8/9= 0 .=0 3/6=2 
recode     livchd (4/40=4 "4+"), g(num_livebirth)

keep       if win1==1
drop       cal_begn win1
replace    death=1 if b5==0 & death==0 & livebirth==1


replace    v007=2000+v007 if v007<10
replace    v007=1900+v007 if v007<100
replace    v007=2006 if  v000=="NP5"
replace    v007=2011 if  v000=="NP6"
replace    v007=2016 if  v000=="NP7"

gsort      coun dhs, g(survey)

lab        var survey          "Survey unique ID"        
lab        var u_l_end         "Analysis window: 7-66 month before survey"
lab        var e_neo           "Early neonatal mortality"
lab        var l_neo           "Late neonatal mortality"
lab        var neonate         "Neonatal mortality"
lab        var perinatal       "Perinatal mortality"
lab        var p_neo           "Post-neonatal mortality"
lab        var new_neo         "Extended neonatal mortality"
lab        var new_inf         "Extended infant mortality"
lab        var abortion        "Pregnancy loss of less than 7 momths"
lab        var stillbirth      "Stillbirth 7+ months"
lab        var currently_preg  "Currently pregnany 7+"
lab        var livebirth       "Live birth"
lab        var infant          "Infant mortality"
lab        var preterm         "Preterm live birth" 
lab        var age0            "Gestational age"
lab        var age             "Current age/age at death"
lab        var year_2          "Age 2 years"
lab        var year_3          "Age 3 years"
lab        var death           "Survival status"
lab        var sev_preterm     "Sever preterm"
lab        var tot             "value ONE for summary statistics"

cap      drop month_st month _preg_b3_birth_b3_match u_l_end win2 year_2 year_3 abortion 


}
