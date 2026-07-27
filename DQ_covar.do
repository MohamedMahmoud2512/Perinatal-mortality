
qui        {
	
keep       if age <30
replace    neo=1 if still==1   /* including stillbirth */
drop       if neo!=1           /* keep neonatal and stillbirth deaths */

collapse   (sum) neo [pw=swt], by($covar  dhs country survey age)

reshape    wide neo , i($covar survey country ) j(age)
recode     neonate1- neonate29 (.=0)

rename     neonate1   stillbirth
lab        var stillbirth "Stillbirth"

forvalues  i=2/29 {
                  local j=`i'-2
                  rename      neonate`i' d`j'
                  lab         var d`j'         "Deaths on day  `j'"
           }

*Number of deaths  		   
egen       d_0_1=rowtotal(d0-d1)
egen       d_0_2=rowtotal(d0-d2)
egen       d_2_6=rowtotal(d2-d6)
egen       d_3_6=rowtotal(d3-d6)

egen       ENN  =rowtotal(d0-d6)
egen       LNM  =rowtotal(d7-d27)
egen       NNM  =rowtotal(d0-d27)

lab        var d_0_1   "Deaths between  day 0-1"
lab        var d_0_2   "Deaths between  day 0-2"
lab        var d_2_6   "Deaths between  day 2-6"
lab        var d_3_6   "Deaths between  day 3-6"
lab        var ENN     "Early  Neonatal day 0-6"
lab        var LNM     "Late   Neonatal day 7-27"
lab        var NNM     "Neonatal        day 0-27"

*Ratios******************************* 
gen        stb_d_01    =stillbirth/d_0_1
gen        stb_d_02    =stillbirth/d_0_2
gen        stb_d_06    =stillbirth/ENN
gen        stb_d_027   =stillbirth/NNM

lab        var  stb_d_01       "Ratio of Stillbirth to D0-1"
lab        var  stb_d_02       "Ratio of Stillbirth to D0-2"
lab        var  stb_d_06       "Ratio of Stillbirth to ENN"
lab        var  stb_d_027      "Ratio of Stillbirth to NNM"

gen        d0_d1       =d0/d1
gen        d01_d26     =d_0_1/d_2_6
gen        d02_d36     =d_0_2/d_3_6

lab        var  d0_d1          "Ratio of D0 to D1"
lab        var  d01_d26        "Ratio of D0-1 to D2-6"
lab        var  d02_d36        "Ratio of D0-2 to D3-6"


*Proportions************************
gen        d0_d01      =d0/d_0_1
lab        var  d0_d01         "Prop. of D0 out of D0-1"

gen        d01_ENN     =d_0_1/ENN
gen        d02_ENN     =d_0_2/ENN
lab        var  d01_ENN        "Prop. of D0-1 out of ENN"
lab        var  d02_ENN        "Prop. of D0-2 out of ENN"

gen        d01_NNM     =d_0_1/NNM
gen        d02_NNM     =d_0_2/NNM
lab        var  d01_NNM        "Prop. of D0-1 out of NNM"
lab        var  d02_NNM        "Prop. of D0-2 out of NNM"

gen        ENN_NNM     =ENN/NNM 
lab        var  ENN_NNM        "Prop. of ENM out of NNM"

*Heaping
gen        heaping_index =5*d7/(d5+d6+d7+d8+d9)
lab        var heaping_index   "Heaping Index at day 7"
recode     heaping_index (0/.59999=0 "<0.60") (.6/.79999=1 "0.60-0.79")(.8/1.29999=2 "0.8-1.29") (1.3/1.49999=1 "1.3-1.49")(1.5/100=0 "1.5+"), g(P_heaping)

*Thresholds for data quality assessment
***************************************
*1 STB:D0-1
gen        vr_dq1=cond(stb_d_01<1.89,1,0)    /*first correction factor */

*2: STB:D0-6
gen        vr_dq2=cond(stb_d_06<1.0  | stb_d_06>1.8 ,1,0)

*3- d0:d1
gen        vr_dq3=cond(d0_d1   <2.57 | d0_d1   >3.38,1,0)

*4- d0_1: d2_6
gen        vr_dq4=cond(d01_d26 <2.40 ,1,0)                         /* second correction factor */

lab        var 	vr_dq1		"1: STB:D0-1	"
lab        var 	vr_dq2		"2: STB:D0-6	"
lab        var 	vr_dq3		"3: d0:d1	    "
lab        var 	vr_dq4		"4: d0_1: d2_6  "


*DQ index
gen        dq_index=vr_dq1+vr_dq2+vr_dq3+vr_dq4
lab        var 	dq_index	"Overal DQ index"


*Factor 1
*********
gen        fact1=stb_d_01
replace    fact1=1.89   if vr_dq1==1   /* adjusted with a single value if it outside the range 1.0-4.0 */
lab        var fact1	 "Constrain of Stb/D0-1 ratio transferance and omission	"

gen        vr_fact1=0
replace    vr_fact1=-1  if stb_d_01<1.0
replace    vr_fact1=1   if stb_d_01>4.0

lab        var 	vr_fact1	"Factor 1 ranges"
lab        def  range_lbl  -1 "below 1.0"  0 "within probable and plausable ranges" 1 "above 4.0"
lab        val  vr_fact1 range_lbl

recode     stb_d_01 (0/.9999=-1 "very low-Improbable" )(1/1.69999=1 "low-Probable") (1.7/2.9999=2 "Plausible")(3/3.9999=3 "hig-Probable")(4/1000=4 "very high-Improbable" ), g(P_fact1)

*Factor 2
*********
gen        fact2=1
replace    fact2=2.4    if vr_dq4==1   /* adjusted with a single value if it less than 2.4 */
lab        var fact2	 "Weight to death on day 0-1  Omission of ENN"

gen        vr_fact2=0
replace    vr_fact2=1  if d01_d26<2.4

lab        var 	vr_fact2	"Factor 2 ranges"
lab        def  range_lb2   0 ">=2.4" 1 "<2.4"
lab        val  vr_fact2 range_lb2
recode     d01_d26 (0/2.39999=0 "<2.4")(2.4/100=1 "2.4+"), g(P_fact2)

sort       survey
drop       d0- d27
}


 


