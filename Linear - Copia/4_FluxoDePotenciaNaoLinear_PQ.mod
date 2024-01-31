#------------------------------#
# Fluxo de Potencia Nao Linear #
#------------------------------#

#-- Definir os Conjuntos --#

set Ob;
set Ol within Ob cross Ob; #Conjunto das linhas, que depende de Ob

#-- Definir os Parametros --#

# Dados das barras
param Tb{Ob};	#Tipo de barra (1: SE, 0: Carga)
param PD{Ob};	#Potencia ativa demandada
param QD{Ob};	#Potencia Reativa Demandada
param QC{Ob};	#Pot Reativa dos capacitores na barra

param Vnom;
param Vmin;
param Vmax;

# Dados das linhas
param R{Ol};	#Resistencia
param X{Ol};	#Reatancia indutiva
param Imax{Ol};	#Corrente maxima
param Z2{Ol};	#Z^2 = R^2 + X^2


#-- Definir as Variaveis --#

# Vars das barras
var PS{Ob};		#Potencia ativa
var QS{Ob};		#Potencia reativa

# Vars das linhas
var P{Ol};		#Potencia ativa na linha
var Q{Ol};		#Potencia reativa na linha

# Tensoes e correntes
var Isqr{Ol};		#corrente nas linhas
var Vsqr{Ob};		#tensões nas barras

# variávl auxiliar 
var b{Ol};		
var ymax{Ol}, binary; 
var ymin{Ol}, binary;

param N = card(Ob);
#----------------------------------------

# Para a linearização Vsqr * Isqr

param S = 7;
param DeltaV = (Vmax^2-Vmin^2)/(S+1);
var xv{Ob, s in 1..S}, binary;
var Pc{Ob, s in 1..S};

#----------------------------------------

# Dados para a Linearizacao P^2 Q^2

param Y = 50;
param DS{Ol};
param ms{Ol, y in 1..Y};

var DP{Ol, y in 1..Y} >= 0;
var DQ{Ol, y in 1..Y} >= 0;

var Pmax{Ol}>= 0;
var Pmin{Ol}>= 0;
var Qmax{Ol}>= 0;
var Qmin{Ol}>= 0;
#----------------------------------------

# 
param ke = 168;

#-- Funcao Objetivo --#

minimize FuncaoObjetivo: ke *(sum{(i, j) in Ol}(R[i, j] * Isqr[i, j]));

#-- Restricoes --#

#Balanco de Potencia Ativa
subject to BalancoPotenciaAtiva{i in Ob}:
	sum{(k,i) in Ol}(P[k,i]) - sum{(i,j) in Ol}( P[i,j] + R[i,j]*Isqr[i,j] ) + PS[i] = PD[i];

#Balanco de Potencia Reativa
subject to BalancoPotenciaReativa{i in Ob}:
	sum{(k,i) in Ol}(Q[k,i]) - sum{(i,j) in Ol}( Q[i,j] + X[i,j] * Isqr[i,j] ) + QS[i] = QD[i];
	
#Queda de Tensao no circuito
subject to QuedaTensao{(i,j) in Ol}:
	Vsqr[i] - 2*(R[i,j] * P[i,j] + X[i,j]*Q[i,j]) - Z^2[i,j] * Isqr[i,j] - Vsqr[j] - b[i,j] = 0;
	
#Potencia aparente (kVA)
subject to PotenciaAparente{(i,j) in Ol}:
	(Vmin^2 + 0.5 * DeltaV) * Isqr[i,j] + sum{s in 1..S}(Pc[j,s]) = sum{y in 1..Y}(ms[i,j,y]*DP[i,j,y]) + sum{y in 1..Y}(ms[i,j,y]*DQ[i,j,y]);
	
#-------------------------------------------------------------------------------	
# Limite de corrente colocar variaiveis 33 ate 40 
subject to LimiteCorrente{(i,j) in Ol}:
	0 <= Isqr[i,j];

#---------------------------------------------------------------
# Limite das tensoes

subject to LimiteTensao{i in Ob}:
	Vmin^2 <= Vsqr[i] <= Vmax^2;

subject to LinearizacaoP1_1{j in Ob}:
	Vmin^2 + sum{s in 1..S}(xv[j,s] * DeltaV) <= Vsqr[j];

subject to LinearizacaoP1_2{j in Ob}:
	Vsqr[j] <= Vmin^2 + DeltaV + sum{s in 1..S}(xv[j,s] * DeltaV);

#---------------------------------------------------------------
# Potencia de correcao

subject to LinearizacaoP2_1{(i,j) in Ol, s in 1..S}:
	0 <= DeltaV * Isqr[i,j] - Pc[j,s];

subject to LinearizacaoP2_2{(i,j) in Ol, s in 1..S}:
	DeltaV * Isqr[i,j] - Pc[j,s] <= DeltaV * Imax[i,j]^2 * (1 - xv[j,s]);

subject to linearizacaoP3_1{(i,j) in Ol, s in 1..S}:
	0 <= Pc[j,s];

subject to linearizacaoP3_2{(i,j) in Ol, s in 1..S}:
	Pc[j,s] <= DeltaV * Imax[i,j]^2 * xv[j,s];

#---------------------------------------------------------------
# Variavel binaria
subject to LinearizacaoP4{j in Ob, s in 2..S}:
	xv[j,s] <= xv[j,s-1];
	

	
#---------------------------------------------------------------	
subject to LinearizacaoP1{(i,j) in Ol}:
 Pmax[i,j] - Pmin[i,j] = P[i,j];
 
 
subject to LinearizacaoQ1{(i,j) in Ol}:
 Qmax[i,j] - Qmin[i,j] = Q[i,j];
 
 
subject to LinearizacaoP2{(i,j) in Ol}:
 Pmax[i,j] + Pmin[i,j] = sum{y in 1..Y}(DP[i,j,y]);
 
subject to LinearizacaoQ2{(i,j) in Ol}:
 Qmax[i,j] + Qmin[i,j] =  sum{y in 1..Y}(DQ[i,j,y]);
 
 
subject to LinearizacaoP3{(i,j) in Ol, y in 1..Y}:
  DP[i,j,y]<= DS[i,j];
 
 subject to LinearizacaoQ3{(i,j) in Ol, y in 1..Y}:
  DQ[i,j,y]<= DS[i,j];
 
 