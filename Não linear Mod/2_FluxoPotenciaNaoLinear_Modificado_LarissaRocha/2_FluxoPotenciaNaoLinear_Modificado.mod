# ------------------ fluxo de potencia n linear --------------


# ------------------ definir conjuntos -----------------------

set Ob;
set Ol within Ob cross Ob;

# --------- definindo parametos -----------

param Tb{Ob}; 	# para (1: barra SE, 2: BARRA DE LINHA DE TRANSMISSÃO
param PD{Ob};  	# potencia ativa
param QD{Ob}; 	#potencia reativa
param QC{Ob}; 	#capacitor existente 


# def parametros ds linhas

param R{Ol}; 	#RESISTENCIA
param X{Ol} ;	#reatancia indutiva
param Imax{Ol};	# corrente maxima
param Z2{Ol}; 

param Vnom;
param Vmin; 
param Vmax;

# DEF VARIAVEIS
 var PS{Ob};
 var QS{Ob}; #potenci areativa d asubestação
 var P{Ol};
 
 var Q{Ol}; 
 var Isqr{Ol}; 
 var Vsqr{Ob};
 
 
 # Função objetivo 
 
 minimize FuncaoObjetivo: sum{(i,j) in Ol} (R[i,j] * Isqr[i,j]);
 
 # balanco de potencia ativa
 
  subject to BalancoPotenciaAtiva{i in Ob}:
 	sum{(k,i) in Ol} (P[k,i])-sum{(i,j)in Ol}(P[i,j] + R[i,j]*Isqr[i,j]) + PS[i] = PD[i];
 	
 	
 #balanco de potencia reativa 
 
 subject to BalancoPotenciaReativa{i in Ob}:
 	sum{(k,i) in Ol} (Q[k,i]) - sum{(i,j) in Ol} (Q[i,j] + X[i,j] *Isqr[i,j]) + QS[i] = QD[i];

 # queda de tensao no circuito 
 
 subject to QuedaTensao{(i,j) in Ol}: 
 	Vsqr[i] - 2*(R[i,j] * P[i,j] + X[i,j]*Q[i,j]) - Z2[i,j] * Isqr[i,j] -Vsqr[j] = 0; 
 	
 	
 	
 # Potencia aparente (kVA)  	
 
 subject to PotenciaAparente{(i,j) in Ol}:
 	Vsqr[j] * Isqr[i,j] = P[i,j]^2+ Q[i,j]^2;
 	
 	
 # Limite de corrente 
 
 subject to LimiteCorrente{(i,j) in Ol}:
 	0 <= Isqr[i,j] <= Imax[i,j]^2;
 	
#Limite das tensoes 
 subject to LimiteTensao{ i in Ob}:
 	Vmin^2 <= Vsqr[i] <= Vmax^2; 
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	