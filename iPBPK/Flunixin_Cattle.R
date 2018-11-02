{ 
  Flunixin PBPK model for Cattle (flow-limited model, linear metabolism equation, plasma protein binding)
  The PBPK model code is based on the penicillin G model from Li et al. 2017
}

METHOD RK4
STARTTIME = 0
STOPTIME= 400		; h
DT = 0.00025
DTOUT = 0.1

{Physiological Parameters}
; Blood Flow Rates
QCC = 5.970 			; L/h/kg, Cardiac Output (1960 Doyle)

; Fracion of blood flow to organs (unitless) 
QLC =  0.405			; Fraction of blood flow to the liver (1996 Lescoat, 1960 Dlyle)
QKC = 0.090			; Fraction of blood flow to the kidneys (2016 Lin)
QMC = 0.180			; Fraction of blood flow to the muscle (2016 Lin)
QFC = 0.080			; Fraction of blood flow to the fat (2016 Lin)
QrestC = 1-QLC-QKC-QFC-QMC	; Fraction of blood flow to the rest of body (total sum equals to 1)
QrestC1 = 1-QLC-QKC

; Tissue Volumes 
BW = 300			; Body Weight (kg) 

; Fractional organ tissue volumes (unitless)
VLC = 0.014			; Fractional liver tissue (1933 Swett)
VKC = 0.002			; Fractional kidney tissue (1933 Swett)
VFC = 0.150			; Fractional fat tissue (2016 Lin, 2014 Leavens)
VMC = 0.270			; Fractional muscle tissue (2016 Lin, 2014 Leavens)
VvenC = 0.037			; Venous blood volume, fraction of blood volume (2016 Lin; 2008 Leavens)
VartC = 0.012			; Arterial blood volume, fraction of blood volume (2016 Lin; 2008 Leavens)
VbloodC = VvenC+VartC
VrestC = 1-VLC-VKC-VFC-VMC-VvenC-VartC; Fractional rest of body (total sum equals to 1)
VrestC1 = 1-VLC-VKC-VvenC-VartC

{Mass Transfer Parameters (Chemical-Specific Parameters) prediction}
; Flunixin and 5OH Flunixin Molecular Weight
MW = 296.24			; mg/mmol
MW1 = 312.24 			; mg/mmol

; Partition Coefficients for FLU (PC, tissue:plasma)
PL = 10.52			; Liver:plasma PC 
PK = 4				; Kidney:plasma PC 
PM = 0.5			; Muscle:plasma PC 
PF = 0.6			; Fat:plasma PC 
Prest = 13			; Rest of body:plasma PC (average from all other partition coefficients)

; Partition Coefficients for 5OH FLU (PC, tissue:plasma)
PL1 = 9.26			; Liver:plasma PC 
PK1 = 13.49			; Kidney:plasma PC 
Prest1 = 5			; Rest of body:plasma PC

{Kinetic Constants}
; Rate Constants in GI compartments
Kint = 1				; /h, intestinal transit rate constant
Kfeces = 0.01			; /h, fecal elimination rate constant

; IM Absorption Rate Constants
Kim = 0.070			; /h, IM absorption rate constant 

; SC Absorption Rate Constants
Ksc = 0.020 			; /h, SC absorption rate constant

; Percentage Plasma Protein Binding unitless
PB = 0.99			; Percentage of drug bound to plasma proteins
Free = 1-PB

PB1 = 0.99
Free1 = 1-PB1

{Metabolic Rate Constant}
KmetC1 = 0.050			; /h/kg, metabolic rate constant for 5OH FLU
KehcC = 0.0001			; /h/kg, rate constant for the enterohepatic circulation

; Urinary Elimination Rate Constants
KurineC = 0.450			; L/h/kg 
KurineC1 = 0.200		; L/h/kg

; Biliary Elimination Rate Constats
KbileC = 0.100			; L/h/kg
KbileC1 = 0.100			; L/h/kg

{Parameters for Various Exposure Scenarios}
PDOSEiv = 0			; (mg/kg)
PDOSEsc = 0			; (mg/kg)
PDOSEim = 24			; (mg/kg)
F = 20

{Cardiac output and blood flow to tissues (L/h)}
QC = QCC*BW 			; Cardiac output
QL = QLC*QC 			; Liver
QK = QKC*QC 			; Kidney
QF = QFC*QC 			; Fat
QM = QMC*QC 			; Muscle
Qrest = QrestC*QC 		; Rest of body
Qrest1 = QrestC1*QC

{Tissue volumes (L)}
VL = VLC*BW 			; Liver
VK = VKC*BW 			; Kidney
VF = VFC*BW 			; Fat
VM = VMC*BW 		; Muscle
Vrest = VrestC*BW 		; Rest of body
Vven = VvenC*BW 		; Venous Blood
Vart = VartC*BW 		; Arterial Blood
Vblood = VbloodC*BW
Vrest1 = VrestC1*BW

; Metabolic rate constant
Kmet1 = KmetC1*BW		; Metabolic rate constant for 5OH FLU
Kehc = KehcC*BW

; Urinary Elimination Rate Constants
Kurine = KurineC*BW
Kurine1 = KurineC1*BW

; Biliary Elimination Rate Constants
Kbile = KbileC*BW
Kbile1 = KbileC1*BW

{Dosing}
; Dosing caculation based on BW
DOSEiv = PDOSEiv*BW*F		; (mg)
DOSEsc = PDOSEsc*BW*F 	; (mg)
DOSEim = PDOSEim*BW*F 	; (mg)

; Dosing, repeated doses
tinterval = 24			; Varied dependent on the exposure paradigm (h)
Tdoses = 5 			; times for multiple oral gavage
Timeim = 0.003			; IM injection time (h)
Timesc = 0.003			; SC injection time (h)
Timeiv = 0.002			; IV infusion time (h)

Fmultiple = if time < Tdoses*tinterval then 1 else 0

; Dosing, IM, intramuscular
IMR = DOSEim/(MW*Timeim)					; mmol/h
Fim = IF MOD(time, tinterval) <= Timeim then 1 else 0
Rdoseim = IMR*Fim*Fmultiple					; mmol/h
Rim = Kim*Amtsiteim 						; Rim drug absorption rate of intramuscular route (mg/h)
Rsiteim = RdoseIM -Rim 					; Rsiteim changing rate of drug at the intramuscular injection site (mg/h) 
d/dt(Amtsiteim) = Rsiteim					; Amtsiteim amounts of the drug at the intramuscular injection site (mg)
init Amtsiteim = 0						; DOSEim amounts of the drug injected through intramuscular injection (mg)
d/dt(Absorbim) = Rim						; Absorbim amount of drug absorbed by intramuscular injection (mg)
init Absorbim = 0 


; Dosing, SC, subcutaneous
SCR = DOSEsc/(MW*Timesc)					; mmol/h
Fsc = IF MOD(time, tinterval) <= Timesc then 1 else 0
Rdosesc = SCR*Fsc*Fmultiple					; mmol/h
Rsc = Ksc*Amtsitesc						; Rsc drug absorption rate of subcutaneous route (mg/h)
Rsitesc =Rdosesc -Rsc						; Rsitesc changing rate of drug at the subcutaneous injection site (mg/h)
d/dt(Amtsitesc) = Rsitesc					; Amtsitesc amounts of the drug at the subcutaneous injection site (mg)
init Amtsitesc = 0						; DOSEsc amounts of the drug injected through subcutaneous injection (mg)
d/dt(Absorbsc) = Rsc						; bsorbsc amount of drug absorbed by subcutaneous injection (mg)
init Absorbsc = 0

; Dosing, IV, injection to the venous
IVR = DOSEiv/(MW*Timeiv)					; mmol/h, IVR rate of the drug through iv, Timeiv iv exposure time
Fiv = IF MOD(time, tinterval) <= Timeiv then 1 else 0
Riv = IVR*Fiv*Fmultiple
d/dt(Aiv) = Riv
init Aiv = 0 

{FLU and 5OH FLU distribution in each compartment}
; FLU and 5OH FLU in venous blood compartment
CV = ((QL*CVL+QK*CVK+QF*CVF+QM*CVM+Qrest*CVrest+Rsc+Rim+Riv)/QC) ; mmol/L
RA = QC*(CV-CAfree)
d/dt(AA) = RA
init AA = 0
CA = AA/Vblood
d/dt(AUCCV) = CV
init AUCCV = 0
CAfree = CA*Free
CVppm = CV*MW					; mg/L

CV1 = ((QL*CVL1+QK*CVK1+Qrest1*CVrest1)/QC) 
RA1 = QC*(CV1-CAfree1)
d/dt(AA1) = RA1
init AA1 = 0
CA1 = AA1/Vblood
d/dt(AUCCV1) = CV1
init AUCCV1 = 0
CAfree1 = CA1*Free1
CV1ppm = CV1*MW					; mg/L

; FLU and 5OH FLU in liver compartment, flow-limited model
RL = QL*(CAfree-CVL)-Rmet1-Rbile+Rehc	; RL the changing rate of the amount of drug in liver (mmol/h)
d/dt(AL) = RL 					; AL amount of drug in liver (mmol) 
init AL = 0  
CL = AL/VL					; CL drug concentration in liver (mmol/L)
CVL= AL/(VL*PL)				; CVL drug concentration in venous blood from liver (mmol/L)
d/dt(AUCCL) = CL				; AUCCL area under the curve of drug concentration in liver (mmol*h/L)
init AUCCL = 0
CLppm = CL*MW				; mg/L

RL1 = QL*(CAfree1-CVL1)-Rbile1	+Rmet1	; RL the changing rate of the amount of drug in liver (mmol/h)
d/dt(AL1) = RL1 			; AL amount of drug in liver (mmol) 
init AL1 = 0  
CL1 = AL1/VL				; CL drug concentration in liver (mmol/L)
CVL1= AL1/(VL*PL1)			; CVL drug concentration in venous blood from liver (mmol/L)
d/dt(AUCCL1) = CL1			; AUCCL area under the curve of drug concentration in liver (mmol*h/L)
init AUCCL1 = 0
CL1ppm = CL1*MW			; mg/L

Rehc = Kehc*AI
d/dt(Aehc) =  Rehc
init Aehc = 0

; GI compartments and Enterohepatic Circulation
Rcolon = Kint*AI			; Rcolon the changing rate of the amount drug into colon (mg/h)
d/dt(Acolon) = Rcolon			; Acolon amounts of the drug into the colon (mg)
init Acolon = 0
RAI = Rbile+Rbile1-Kint*AI-Kehc*AI	; AI amount of the drug in the intestine (mg)
d/dt(AI) = RAI				; RAI the change rate of the amount of drug in intestine (mg/h)
init AI = 0
Rfeces = Kfeces*Acolon
d/dt(Afeces) = Rfeces
init Afeces = 0

; Metabolism of FLU in liver compartment
Rmet1 = Kmet1*CL*VL 		; Rmet the metabolic rate of 5OH Flunixin in liver (mmol/h)
d/dt(Amet1) = Rmet1		; Amet the amount of 5OH FLU metabolized in liver (mmol)
init Amet1 = 0

Rbile = Kbile*CVL
d/dt(Abile) = Rbile
init Abile = 0

Rbile1 = Kbile1*CVL1
d/dt(Abile1) = Rbile1
init Abile1 = 0

; FLU and 5OH FLU in kidney compartment, flow-limited model
RK = QK*(CAfree-CVK)-Rurine	; RK the changing rate of the amount of drug in kidney (mmol/h)
d/dt(AK) = RK			; AK amount of drug in kidney (mmol)
init AK = 0  
CK = AK/VK			; CK drug concentration in kidney (mmol/L)
CVK = AK/(VK*PK)
d/dt(AUCCK) = CK		; AUCCK AUC of drug concentration in kidney (mmol*h/L)
init AUCCK = 0
CKppm = CK*MW		; mg/L	

RK1 = QK*(CAfree1-CVK1)-Rurine1	; RK the changing rate of the amount of drug in kidney (mmol/h)
d/dt(AK1) = RK1			; AK amount of drug in kidney (mmol)
init AK1 = 0  
CK1 = AK1/VK				; CK drug concentration in kidney (mmol/L)
CVK1 = AK1/(VK*PK1)
d/dt(AUCCK1) = CK1			; AUCCK AUC of drug concentration in kidney (mmol*h/L)
init AUCCK1 = 0
CK1ppm = CK1*MW			; mg/L

; FLU and 5OH FLU urinary excretion
Rurine = Kurine*CVK
d/dt(Aurine) = Rurine
init Aurine = 0

Rurine1 = Kurine1*CVK1
d/dt(Aurine1) = Rurine1
init Aurine1 = 0

; FLU and 5OH FLU in muscle compartment, flow-limited model
RM = QM*(CAfree-CVM) 	; RM the changing rate of the amount of drug in muscle (mmol/h) 
d/dt(AM) = RM			; AM amount of the drug in muscle (mmol)
init AM = 0
CM = AM/VM			; CM drug concentration in muscle (mmol/L)
CVM = AM/(VM*PM)
d/dt(AUCCM) = CM
init AUCCM = 0
CMppm = CM*MW		; mg/L

; FLU and 5OH FLU in fat compartment, flow-limited model
RF = QF*(CAfree-CVF) 		; RF the changing rate of the amount of drug in fat (mmol/h)
d/dt(AF) = RF			; AF amount of the drug in fat (mmol)
init AF = 0
CF = AF/VF			; CF drug concentration in fat (mmol/L)
CVF = AF/(VF*PF)
d/dt(AUCCF) = CF		; AUCCF AUC of drug concentration in fat (mmol*h/L)
init AUCCF = 0
CFppm = CF*MW		; mg/L

; FLU and 5OH FLU in the compartment of rest of body, flow-limited model
Rrest = Qrest*(CAfree-CVrest) 	; Rrest the changing rate of the amount of drug in the rest of the body (mmol/h)
d/dt(Arest) = Rrest		; Arest amount of the drug in the rest of the body (mmol)
init Arest = 0
Crest = Arest/Vrest		; Crest drug concentration in the rest of the body (mmol/L)
CVrest = Arest/(Vrest*Prest)
d/dt(AUCCrest) = Crest		; AUCCrest AUC of drug concentration in the rest of the body (mmol*h/L)
init AUCCrest = 0
Crestppm = Crest*MW		; mg/L

Rrest1 = Qrest1*(CAfree1-CVrest1) 	; Rrest the changing rate of the amount of drug in the rest of the body (mmol/h)
d/dt(Arest1) = Rrest1			; Arest amount of the drug in the rest of the body (mmol)
init Arest1 = 0
Crest1 = Arest1/Vrest1			; Crest drug concentration in the rest of the body (mmol/L)
CVrest1 = Arest1/(Vrest1*Prest1)
d/dt(AUCCrest1) = Crest1		; AUCCrest AUC of drug concentration in the rest of the body (mmol*h/L)
init AUCCrest1 = 0
Crest1ppm = Crest1*MW		; mg/L

{Mass balance equations}
; Mass balance equations for FLU
Qbal = QC-QM-Qrest-QF-QK-QL
Tmass = AA+AM+Arest+AF+AK+AL+Aurine+Amet1+Abile
Input = Aiv+Absorbim+Absorbsc+Aehc
Bal = Input-Tmass

; Mass balance equations for 5OH FLU
Qbal1 = QC-QL-QK-Qrest1
Tmass1 = AA1+Arest1+AK1+AL1+Aurine1+Abile1
Input1 = Amet1
Bal1 = Input1-Tmass1
