
import amplpy
import pandas as pd
import math

from amplpy import AMPL, tools
tools.modules.load()
ampl = amplpy.AMPL()

ampl.read('C:\\TRANMISSAO\\1_FluxoPotenciaNaoLinear_LarissaRocha\\1_FluxoPotenciaNaoLinear.mod')
ampl.read_data('C:\\TRANMISSAO\\1_FluxoPotenciaNaoLinear_LarissaRocha\\1_Sistema_69_Barras.dat')

ampl.setOption('solver', 'knitro')
ampl.solve()

Ol = ampl.getSet("Ol").getValues().toPandas().index
Ol_1,Ol_2 = zip(*Ol)
Ob = ampl.getSet("Ob").getValues().toPandas().index
V =  ampl.get_variable("V").get_values().toPandas()
Vnom = ampl.get_parameter("Vnom").get_values().toPandas()
R = ampl.get_parameter("R").get_values().toPandas()
X = ampl.get_parameter("X").get_values().toPandas()
I = ampl.get_variable("I").get_values().toPandas()
P = ampl.get_variable("P").get_values().toPandas()
Q = ampl.get_variable("Q").get_values().toPandas()
solve = "FuncaoObjetivo"

Vpu = {}


for i in Ob:
    Vpu[i] = V.at[i, 'V.val'] / Vnom.loc[0]




print ('\n\n')
print ('------------------------------------|\n')
print ('| Solução do Fluxo de potência para |\n')
print ('| Sistema de distribuição de energia|\n')
print ('|-----------------------------------|\n')

print ( 'Tensões \n')
print ('|-----------|-----------|------------|\n')
print ('|   Barra   |   V[kV]   |   V[p.u]   |\n')
print ('|-----------|-----------|------------|\n')



for i in Ob:
	print ('%8d  %12.4f %11.4f \n' % (i,V.at[i, 'V.val'], Vpu[i]))


print ('|-----------|-----------|------------|\n')

#-------------------------------------------------------


Pperdas = {} # Perdas  de potencia ativa nas linhas 
Qperdas = {} # Perdas de potencia reativa nas linhas 

for i,j in zip(Ol_1, Ol_2):
    Pperdas[(i,j)] = R.at[(i,j), 'R']*I.at[(i,j), 'I.val']**2
    Qperdas[(i,j)] = X.at[(i,j), 'X']*I.at[(i,j), 'I.val']**2

print ('\n\n Resultados Linhas: \n')
print ('|-------|--------|------------|------------|--------------|---------------|----------------|\n')
print ('|   i   |    j   |   I [Amp]  |   P [kW]   |   Q [kVAr]   |  Pperdas[kW]  | Qperdas [kVAr] |\n') 
print ('|-------|--------|------------|------------|--------------|---------------|----------------|\n')


for i,j in zip(Ol_1, Ol_2):
 print ('%5d %8d %13.4f %13.4f %13.4f %13.4f %15.4f\n' % (i,j, I.at[(i,j), 'I.val'], P.at[(i,j), 'P.val'], Q.at[(i,j), 'Q.val'], Pperdas[i,j], Qperdas[i,j]))



