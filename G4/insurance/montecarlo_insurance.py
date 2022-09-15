# -*- coding: utf-8 -*-
"""
Created on Mon Sep  5 20:09:44 2022

@author: Julián
"""
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
df= pd.read_csv('insurance_SE.csv', sep=',')
poblacion=1e4
alcance=0.175
poblacion_alcanzada=poblacion*alcance
n=10000
gasto=np.zeros(n)
for i in range(n):
  compradores=df.sample(frac=alcance)
  gasto_med=np.mean(compradores['charges'])

  gasto[i]=gasto_med

gasto_prom=np.mean(gasto)
ganancia=gasto_prom*poblacion_alcanzada
desv=np.std(gasto)

hombres=df[df['sex']=='male']
mujeres=df[df['sex']=='female']


gasto_h=np.zeros(int(n*0.75))
gasto_m=np.zeros(int(n*0.25))
for i in range(int(n*0.75)):
  compradores_h=hombres.sample(frac=alcance*0.75, replace=True)
  gasto_h_med=np.mean(compradores_h['charges'])
  gasto_h[i]=gasto_h_med
  if i<int(n*0.25):
        compradores_m=mujeres.sample(frac=alcance*0.25, replace=True)
        gasto_m_med= np.mean(compradores_m['charges'])
        gasto_m[i]=gasto_m_med

   
gasto_h_prom, gasto_m_prom=np.mean(gasto_h), np.mean(gasto_m)
gasto_h_std, gasto_m_std=np.std(gasto_h), np.std(gasto_m)
desv_disc=np.std(np.concatenate([gasto_h, gasto_m]))
ganancia_disc=gasto_h_prom*int(poblacion_alcanzada*0.75)+gasto_m_prom*int(poblacion_alcanzada*0.25)

print(f'Después de {n} campañas simuladas')
print(f'El promedio del gasto total por persona es de ${gasto_prom:.0f}')
print(f'La ganancia estimada es de $ {ganancia:.0f} +- {200*desv/ganancia:.3f}% si no se discrimina por sexo')
print('')
print('Discriminando por sexo se obtiene en promedio un gasto de')
print(f'${gasto_h_prom:.0f} por hombre y de ${gasto_m_prom:.0f} por mujer')
print(f'dejando una ganancia estimada de ${ganancia_disc:.0f} +- {2*100*desv_disc/ganancia_disc:.3f}%')
#%%
prom_burdo=np.mean(mujeres['charges'])/2+np.mean(hombres['charges'])/2
prom_burdo*10000*0.175
25706875/26748103

