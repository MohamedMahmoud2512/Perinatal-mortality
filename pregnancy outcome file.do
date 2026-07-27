qui     {
*pregnancy outcome- no gestational age
****************************************
         use      "$drv_dta\XXX_preg0.dta", clear
         keep     if  c1_>49 & c1_<59
         gen      cp_f=0
         by       caseid: replace cp_f=1 if month==v019 & c1_==50
         gen      ab_f=0
         replace  ab_f=2 if c1_==51
         gen      lb_f=0
         replace  lb_f=3 if c1_==52
         gen      preg_out=max(cp_f, ab_f, lb_f)
         drop     c1_ v019 cp_f  ab_f lb_f
         sort     caseid month
         drop     if preg_out==0

	     lab      def preg_out_lbl 1 "Currently pregnant" 2 "Termination"  3"Live birth"
	     lab      val preg_out preg_out_lbl
	     lab      var month "month pregnancy ended"
	     lab      var preg_out "pregnancy outcome "
         keep     caseid month preg_out  
         cap      save   "$drv_dta\XXX_preg1.dta", replace 	   

********************	   
         use       "$drv_dta\XXX_preg0.dta", clear
	 
	     lab      var month "month pregnancy ended"
         sort     caseid month
		 
         gen      ptp=0		 
         by       caseid: replace ptp=1 if _n>2 & c1_==50 & (c1_[_n-1]==51 | c1_[_n-1]==52) & c1_[_n-2]==c1_[_n]
		 by       caseid: replace ptp=1 if _n>2 & c1_==50 & (c1_[_n-1]==51 | c1_[_n-1]==52) & c1_[_n-2]==0
		 by       caseid: replace ptp=1 if _n>2 & c1_==51 & (c1_[_n-1]==51 | c1_[_n-1]==52) & c1_[_n-2]==50
         replace  c1_=50 if c1_>50  & c1_<60
		 by       caseid: replace  ptp=ptp[_n-1]+ptp if _n>1  & c1_[_n]==50 		  

         replace  c1_=c1_+ptp*10   /*Note: 50 & 60 ,70 , 80 , to avoid ter=51 birht=52 */
         sort     caseid month
    
         *adding  pregnancy outcome 
         **************************
         merge    1:1 caseid month using  "$drv_dta\XXX_preg1.dta"
         drop     _m 
         sort     caseid month   

         *Gestational period  
         *******************
         gen      f1=0
         qui      by caseid: replace f1=1 if c1_!=c1_[_n-1] 
         qui      by caseid: gen f2=sum(f1)
         sort     caseid  f2
         by       caseid f2: gen time=_N
	     lab      var time "gestational age"

         gen      last=0
         by       caseid f2: replace last=1 if _n==_N
         drop     if last==0
         drop     f1 f2 last

         drop     if preg_out==.
         gen      cal_begn=0
         replace  cal_begn=1 if month==time  
         replace  cal_begn=0 if (time>=9 & preg_out==3 & cal_begn==1) |(time>=7 & preg_out==2 & cal_begn==1)  
		 /* include all gestational age of 7+ months  */

         sort     caseid
         mer      m:1 caseid using "$drv_dta\XXX_cal0.dta"
         gen      swt=v005/1000000
         keep     caseid  month time  preg_out v017 v018 v019 v008 cal_begn swt

         gen      epi_st  =v017+month-time
         gen      b3      =v017+month-1
         gen      cal     =int((v008-epi_st)/12)
		 
	     gen      month_st=month-time+1
         drop     if preg==.  
         compress 
         sort     caseid b3
         cap      save   "$drv_dta\XXX_preg2.dta", replace   

         ***************
		 use      "$drv_dta\XXX_bht0.dta", clear
		 sort     caseid b3
		 mer      m:1 caseid b3 using   "$drv_dta\XXX_preg2.dta"
		 drop     if _m==1
 		 sort     caseid b3
		  
		 qui by   caseid: gen inter_p=b3[_n]-b3[_n-1] if _n>1		   
		 replace  inter_p=inter_p-time
		 replace  inter_p=. if inter_p<0   
 
	     sort     caseid b3
         qui      by caseid: gen pord=_n
		 drop     if _m==1
		   
         cap      drop     _m
		 drop     v008  
		 merg     m:1 caseid using "$drv_dta\XXX_bgk0.dta"
         keep     if _m==3	
         drop     _m
		   
		 drop     if cal_begn==1  
	     *housekeeping
	     **************
	     rename   time gest
	     rename   epi_st preg_st
         sort     caseid month
	   
         *Background charactristics
         **************************
         gen      conc_age=floor((preg_st-v011)/12)
         recode   conc_age (0/24=1)(25/29=2)(30/50=3) , g(conc_age_GRP)

         lab      def  v102_lbl  1 "Urban" 2 "Rural"
         lab      val  v102 v102_lbl

         lab      def cage_lbl 1 "<25" 2 "25-29" 3 "30+"
         lab      val conc_age cage_lbl 

         lab      def wi_lbl 1 "Poor" 2 "Middle"  3 "Rich"
         lab      val wi3 wi_lbl
	   
         gen      country=$cont	     
         gen      dhs=$dhs       

         #delimit ;
         keep     country dhs caseid 
	              v000 v001 v002 v003  v007 v008 v011 v012   
		   		  v020 v021 v022 v023 
				  v102 v106 v190 
				  v210 
				  v501 v502 v504 v509 
				  preg_st month_st b3 month gest preg_out inter_p b11 b12 bord pord cal_begn
				  b0 b4 b5 b6 b7 b8 
				  swt wi3 conc_age*
       ;
	   
	   order      country dhs caseid 
	              v000 v001 v002 v003 v007 v008 v011 v012   
				  v020 v021 v022 v023 
				  v102 v106 v190 
				  v210 
				  v501 v502 v504 v509
				  cal_begn preg_st month_st b3 month gest preg_out inter_p b11 b12 bord pord 
				  b0 b4 b5 b6 b7 b8
				  swt wi3 conc_age*
       ;

	   #delimit cr
	   lab      var country  "country code"
	   lab      var dhs      "DHS round"
	   lab      var preg_st  "start of conception (CMC)"
	   lab      var b3       "end of conception (CMC)"
	   lab      var month_st "Month of Calendar conception started"
	   lab      var b0       "child is twin"
	   lab      var b4       "sex of child"
	   lab      var b5       "child is alive"
	   lab      var b6       "age at death"
	   lab      var b7       "age at death (months-imputed)"
	   lab      var b8       "current age of child"
	   lab      var wi3      "wealth tertiles"
	   lab      var conc_age "Age at conception (group)"
	   lab      var swt      "normalized weight"
	   lab      var inter_p  "Inter-pregnancy Interval"
	   lab      var b11       "Precceding birth interval"
	   lab      var b12       "Succeeding birth interval"
	   lab      var bord      "Birth order"
	   lab      var pord      "pregnancy order in the calendar"


	   sort     caseid 
       gen      cmc_evn=b3    
       appen    using  "$drv_dta\XXX_lch0" 
       sort     caseid cmc_evn
       gen      t=livchd
       by       caseid: replace t=t[_n-1] if t==.
       drop     if     b3==.
       replace  livchd =t
       recode   livchd .=0
       drop     t cmc_evn    	   
       order    country - month_st month-b0 b3  
       ***	   

	   drop     if preg_out==3 & gest<6
	   recode   gest (10=9)
	   drop     if gest>9
       do       "C:\GitHub\prg_history.do"
	   cap      save    "$drv_dta\XXX_preg3.dta", replace
	   
       }
  
/*
cap      erase "$drv_dta\XXX_bht0.dta" 
cap      erase "$drv_dta\parity.dta"
cap      erase "$drv_dta\deaths.dta"
cap      erase "$drv_dta\XXX_lch0.dta"
cap      erase "$drv_dta\XXX_hlt0.dta"
cap      erase  "$drv_dta\XXX_cal0.dta"
  

cap      erase  "$drv_dta\XXX_preg0.dta"  
cap      erase  "$drv_dta\XXX_preg1.dta" 
cap      erase  "$drv_dta\XXX_preg2.dta" 


*/