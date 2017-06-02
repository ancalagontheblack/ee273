* Reference Channel PRBS7 Data Eye *

*************************************************************************
*************************************************************************
*                                                                       *
*			Parameter Definitions				*
*                                                                       *
*	ADJUST THE FOLLOWING PARAMETERS TO SET SIMULATION RUN TIME	*
*	AND TO SET DRIVER PRE-EMPHASIS LEVELS.				*
*                                                                       *
*	PLOT THE SIGNAL rx_diff TO GET THE DIFFERENTIAL RECEIVE SIGNAL.	*
*                                                                       *
*************************************************************************
*************************************************************************
* Simulation Run Time *
*.PARAM simtime	= '60/bps'	* USE THIS RUNTIME FOR PULSE RESPONSE
 .PARAM simtime	= '512/bps'	* USE THIS RUNTIME FOR EYE DIAGRAM

* CTLE Settings *
 .PARAM az1     = 0.94g          * CTLE zero frequency, Hz
 .PARAM ap1     = 5g             * CTLE primary pole frequency, Hz
 .PARAM ap2     = 15g            * CTLE secondary pole frequency, Hz

* Driver Pre-emphasis *
 .PARAM pre1	= 0.166  	* Driver pre-cursor pre-emphasis
 .PARAM post1	= 0.034 	* Driver 1st post-cursor pre-emphasis
 .PARAM post2	= -0.11        * Driver 2nd post-cursor pre-emphasis

** Driver Pre-emphasis *
* .PARAM pre1	= 0.152		* Driver pre-cursor pre-emphasis
* .PARAM post1	= 0.2300	* Driver 1st post-cursor pre-emphasis
* .PARAM post2	= 0.0160	* Driver 2nd post-cursor pre-emphasis
* Driver Pre-emphasis *
* .PARAM pre1	= 0.0		* Driver pre-cursor pre-emphasis
* .PARAM post1	= 0.0		* Driver 1st post-cursor pre-emphasis
* .PARAM post2	= 0.0		* Driver 2nd post-cursor pre-emphasis

* Eye delay -- In awaves viewer, plot signal rx_diff against signal eye
*              then adjust parameter edui to center the data eye.
*
 .PARAM edui	= 0.00	 	* Eye diagram alignment delay.
 				* Units are fraction of 1 bit time.
				* Negative moves the eye rigth.
				* Positive moves the eye left.

* Single Pulse Signal Source *
*Vs  inp 0    PULSE (1 0 0 trise tfall '(1/bps)-trise' simtime)

* PRBS7 Signal Source *
 Xs  inp inn  (bitpattern) dc0=0 dc1=1 baud='1/bps' latency=0 tr=trise

*************************************************************************
*************************************************************************

* Driver Volatage and Timing *
 .PARAM vd	= 1250m		* Driver peak to peak diff drive, volts
 .PARAM trise	= 60p		* Driver rise time, seconds
 .PARAM tfall	= 60p		* Driver fall time, seconds
 .PARAM bps	= 10.7g		$6.25g	* Bit rate, bits per second

* PCB Line Lengths *
 .PARAM len1	= 9		* Line segment 1 length, inches
 .PARAM len2	= 12		* Line segment 2 length, inches
 .PARAM len3	= 6		* Line segment 3 length, inches
 .PARAM len4	= 6		* Line segment 4 length, inches

* Package Parameters *
* Package Parameters *
 .PARAM GENpkgZ = 47.5		* Typ GEN package trace impedance, ohms
 .PARAM GENpkgD = 100p		* Typ GEN package trace delay, sec
 *.PARAM GENpkgR = 0.337		* Typ GEN package trace resistance, ohms
 *.PARAM GENpkgL = 5.675n	* Typ GEN package trace induct., henries
 *.PARAM GENpkgC = 2.27p		* Typ GEN package trace capac., farads

* Receiver Parameters *
 .PARAM cload	= 2f		* Receiver input capacitance, farads
 .PARAM rterm	= 50		* Receiver input resistance, ohms


*************************************************************************
*                                                                       *
*			Main Circuit					*
*                                                                       *
*************************************************************************

* Behavioral Driver *
 Xf  inp in   (RCF) TDFLT='0.25*trise'
 Xd  in  ppad npad   (tx_4tap_diff) ppo=vd bps=bps a0=pre1 a2=post1 a3=post2
 Xpp1    ppad  jp1   (gen_pkg)				* Driver package model
 Xpn1    npad  jn1   (gen_pkg)				* Driver package model
 Xvn1    jn1   jn2   (via)				* Package via
 Xvp1    jp1   jp2   (via)				* Package via
 Xk jp2 jn2 jp3 jn3  (stripline6_fr4) length=len1	* Diff. Line Model 
 Xvp2    jp3   jp4   (via)				* Daughter card via
 Xvn2    jn3   jn4   (via)				* Daughter card via


*************************************************************************
*************************************************************************
************************************************************************


* 4x8 Orthogonal Midplane Interconnect *
Xk1  0  jp4   jn4   jp5  jn5  (conn)			* 4x8 Orthogonal connector
Tmp1    jp5 0 jp8 0 Z0=50 TD=40p			* Through-midplane via
Tmp2    jn5 0 jn8 0 Z0=50 TD=40p			* Through-midplane via
Xk2  0  jp9   jn9   jp8  jn8  (conn)			* 4x8 Orthogonal connector

* Daughter Card 2 Interconnect *
 Xvp5    jp9   jp10  (via)				* Daughter card via
 Xvn5    jn9   jn10  (via)				* Daughter card via
 Xl3     jp10  jn10  jp11 jn11 (stripline6_fr4)	length=len3  * Line seg 3
 Xvp6    jp11  jp12  (via) 		Cvia=1.4p	* DC blocking cap vias
 Xvn6    jn11  jn12  (via) 		Cvia=1.4p	* DC blocking cap vias
 Xl4     jp12  jn12  jp13 jn13 (stripline6_fr4)	length=len4  * Line seg 4
 Xvp7    jp13  jp14  (via)				* Package via
 Xvn7    jn13  jn14  (via)				* Package via
 Xpp2    jp14  jrp   (gen_pkg)				* Recvr package model
 Xpn2    jn14  jrn   (gen_pkg)				* Recvr package model

* Behavioral Receiver *
 Rrp1  jrp 0  rterm
 Rrn1  jrn 0  rterm
 Crp1  jrp 0  cload
 Crn1  jrn 0  cload


* Differential Receive Voltage *
 Xctle jrp jrn outp outn  (rx_eq_diff) az1=az1 ap1=ap1 ap2=ap2
 Ex  rx_diff 0  (outp,outn) 1
 *Ex  rx_diff 0  (jrp,jrn) 1
 Rx  rx_diff 0  1G

* Eye Diagram Horizontal Source *
 Veye1 eye 0 PWL (0,0 '1./bps',1 R TD='edui/bps')
 Reye  eye 0 1G

*************************************************************************
*                                                                       *
*			Libraries and Included Files			*
*                                                                       *
*************************************************************************
 .INCLUDE './rx_eq_diff.inc'
 .INCLUDE '../stripline6_fr4.inc'
 .INCLUDE './prbs7.inc'
 .INCLUDE './tx_4tap_diff.inc'
 .INCLUDE './filter.inc'
 .INCLUDE './connector_24.inc'


*************************************************************************
*                                                                       *
*                       Sub-Circuit Definitions                         *
*                                                                       *
*************************************************************************

* Daughter Card Via Sub-circuit -- typical values for 0.093" thick PCBs *
* .SUBCKT (via) in out  Rvia=1m Lvia = 0.5n Cvia = 0.7f
*     X1  in 1    (section_t) R_sec='0.25*Rvia' L_sec='0.25*Lvia' C_sec='0.25*Cvia'
*     X2  1  out  (section_t) R_sec='0.25*Rvia' L_sec='0.25*Lvia' C_sec='0.25*Cvia'
* .ENDS (via)
 .SUBCKT (via) in out  Z_via=30 TD_via=20p
    Tvia  in 0 out 0  Z0=Z_via TD=TD_via
 .ENDS (via)

* Motherboard Via Sub-circuit *
*     zvia    = via impedance, ohms
*     len1via = active via length, inches
*     len2via = via stub length, inches
*     prop    = propagation time, seconds/inch
*
 .SUBCKT (mvia) in out  zvia=50 len1via=0.09 len2via=0.03 prop=180p
    T1  in  0 out 0  Z0=zvia TD='len1via*prop'
    T2  out 0 2   0  Z0=zvia TD='len2via*prop'
 .ENDS (mvia)

* Generic 5-section Package Model *
 .SUBCKT (gen_pkg)  in out  Z_pkg=GENpkgZ Td_pkg=GENpkgD
    Tpkg in 0 out 0 Z0=Z_pkg TD=Td_pkg
 .ENDS (gen_pkg)


* .SUBCKT (gen_pkg)  in out  R_pkg=GENpkgR L_pkg=GENpkgL C_pkg=GENpkgC
*     X1  in 1    (section_t) R_sec='0.25*R_pkg' L_sec='0.25*L_pkg' C_sec='0.25*C_pkg'
*     X2  1  2    (section_t) R_sec='0.25*R_pkg' L_sec='0.25*L_pkg' C_sec='0.25*C_pkg'
*     X3  2  3    (section_t) R_sec='0.25*R_pkg' L_sec='0.25*L_pkg' C_sec='0.25*C_pkg'
*     X4  3  out  (section_t) R_sec='0.25*R_pkg' L_sec='0.25*L_pkg' C_sec='0.25*C_pkg'
* .ENDS (gen_pkg)

* Generic "T" Section *
 .SUBCKT (section_t) in out  R_sec=1m L_sec=5n C_sec=2p
     Rs1  in 1    '0.5*R_sec'
     Ls1  1  2    '0.5*L_sec'
     Cs1  2  0     C_sec
     Ls2  2  3    '0.5*L_sec'
     Rs2  3  out  '0.5*R_sec'
 .ENDS (section_t)
 
*.SUBCKT (conn) ref inp inn outp outn					
*     T1  inp ref outp ref Z0=50 TD=150p					
*     T2  inn ref outn ref Z0=50 TD=150p					
* .ENDS (conn)	

* Simplistic Behavioral Connector Model *
* .SUBCKT (conn) ref in out
*     T1  in ref out ref Z0=50 TD=150p
* .ENDS (conn)


*************************************************************************
*                                                                       *
*			Simulation Controls and Alters			*
*                                                                       *
*************************************************************************
 .OPTIONS post
 .OPTIONS ACCURATE 
.TRAN 5p simtime *SWEEP DATA=plens
 .DATA	plens
+	pre1	post1	post2
+	0.0	0.0	0.0
+	0.0	0.28	0.0
+	0.17	0.21	0.01
 .ENDDATA
 .END

