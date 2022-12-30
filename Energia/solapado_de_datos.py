# -*- coding: utf-8 -*-
"""
Created on Thu Nov 10 15:20:58 2022

@author: Julián
"""

import matplotlib.pyplot as plt
import numpy as np
# Cargo data de calibración sacada a mano y defino función de escala
calibracion_y=np.load('calibracion_y.npy')
def calibrar_y(data, refe_ini, refe_fin):
    
    delta_pixel = []
    offset= []
    for medicion in range(len(data)):
        y_ini = data[medicion][0][1]
        y_fin = data[medicion][1][1]
        delta_pixel.append(y_fin-y_ini)
        offset.append(y_ini)
    
    delta_refe = refe_fin - refe_ini
    
    escala = np.mean(delta_pixel)/delta_refe
    
    offset=np.mean(offset)
    
    return(escala, offset)


factor_y = calibrar_y(calibracion_y, 0, 5000)
tensor=np.load('data_grafico.npy')

coord_medias=np.mean(tensor, axis=0)

escala, offset=calibrar_y(calibracion_y, 0, 5000)

x=np.arange(2010, 2051)
y=(np.transpose(coord_medias)[1]-offset)/escala
#%%
# Calculo producción en europa omitiendo rusia y gran bretaña

import pandas as pd
df_energia = pd.read_csv('World Energy Consumption.csv')

iso_regiones = pd.read_csv('iso_3_continents.csv')
iso_regiones = iso_regiones.rename(columns={'alpha-3':'iso_code'})
iso_regiones = iso_regiones[['name','iso_code', 'region', 'sub-region', 'intermediate-region']]

df_energia = pd.merge(df_energia, iso_regiones, on='iso_code', how='left')
df_energia = df_energia.rename(columns={'low_carbon_share_elec':'lce_share'})

columnas=['iso_code', 'low_carbon_electricity', 'electricity_generation', 'lce_share', 'renewables_electricity', 'renewables_share_elec','region','year']

df=df_energia[columnas]
df.dropna(inplace=True)

df=df[df['region']=='Europe'] # Selecciono europa
df=df[df['iso_code']!='GBR'] # Tiro UK
df=df[df['iso_code']!='RUS'] # Tiro Rusia


df_sum=df[columnas[:-2]].groupby(['iso_code']).sum()

df_sum_anual=df[columnas[1:]].groupby(['year']).sum()
df_sum_anual['lce_share']=df_sum_anual['low_carbon_electricity']/df_sum_anual['electricity_generation']*100
df_sum_anual['renewables_share_elec'] = df_sum_anual['renewables_share_elec']/ len(df_sum)
productores=df_sum.sort_values('electricity_generation',ascending = False).head(20)

verdes=df_sum.sort_values(['low_carbon_electricity','lce_share'],ascending = False).head(10)

anos=np.arange(1985,2050)

df_elec=df_sum_anual['electricity_generation']
df_lowca=df_sum_anual['low_carbon_electricity']

maximo=max(df_elec)

# plt.plot(anos, modelo(anos,2030, 0.059)+0.05, label='prediccion a ojimetro')
plt.plot(df_sum_anual['electricity_generation'], label='producción total')
plt.plot(df_sum_anual['low_carbon_electricity'], label='producción de verde')
plt.plot(df_sum_anual['renewables_electricity'], label='producción de renovables')

plt.grid()
plt.legend()
plt.xlabel('Año')
plt.ylabel('Producción energética anual (TWh)')

#%%
#saco los índices correspondientes a los puntos entre 2010 y 2022

indices_pre= []
indices_pos = []
for indice, valor in enumerate(x):
    if valor<2022:
        indices_pre.append(indice)
    if valor>=2021:
        indices_pos.append(indice)
#%%

#Hago un modelito y trato de ajustar a ojo (spoiler el modelo no sirve para estos datos)

from scipy.optimize import curve_fit

# def modelo(x, x_0,A, b, c):
#     y= A/(1+np.exp(-b*(x-x_0)))+c
#     return y

plt.figure(figsize=(12, 6), dpi=100)
plt.title('Producción energética según Data Frame$^{1}$ y $\it{energybrainpool.com^2}$', loc='left', fontsize=18)
plt.plot(df_sum_anual['electricity_generation'], label=('Producción total$^{1}$'), color='C1', linewidth=2)
# plt.plot(df_sum_anual['low_carbon_electricity'], label='Prod. Ener. verdes$^{1}$', color='C2', linewidth=2)
plt.plot(df_sum_anual['renewables_electricity'], label='Prod. Ener. renovables$^{1}$', color='C0', linewidth=2)
plt.plot(x, y, label="Prod. total 2010 - 2021 y proyección al 2050 $^{2}$", color='red', linestyle='dashdot',linewidth=2)
# plt.plot(x[indices_pos], y[indices_pos], label="P $^{2}$", color='C1', linestyle='dashdot',linewidth=2)
plt.grid()
plt.xlabel('Año', fontsize=15)
plt.ylabel('Producción (TWh)',fontsize=15)
plt.legend()
plt.xlim(1985, 2050)

plt.savefig('energia_1985.png')
#%%
#•Trato de hacer un ajuste pero se clava en 45 porciento. Al menos ajusta
parametros_ini=[2030,130 , 0.1,9]
bounds=((-np.inf, 0,-np.inf,-np.inf ),(np.inf, 200, np.inf, np.inf))
popt, pcov = curve_fit(modelo,xdata=range(1985, 2021), ydata=df_sum_anual['renewables_share_elec'], p0=parametros_ini, bounds=bounds)

escala_porcentual=100/max(df_sum_anual['electricity_generation'])

plt.clf()
plt.plot(df_sum_anual['electricity_generation']*escala_porcentual, label='producción total')
plt.plot(df_sum_anual['lce_share'], label='producción de verde')
plt.plot(df_sum_anual['renewables_share_elec'], label='producción de renovables')
# plt.plot(anos, modelo(anos,*parametros_ini), label='prediccion a ojimetro')

plt.plot(anos, modelo(anos,*popt), label='prediccion')
plt.plot(x[indices_pre], y[indices_pre], label="Producción 2010 - 2021 (grafico)")

plt.plot(x[indices_pos], y[indices_pos], label="Proyección al 2050")

plt.grid()
plt.xlabel('Año')
plt.ylabel('Consumo (TWh)')
plt.legend()
#%%

# promedio datos entre 2010 y 2021 
# df_graf= pd.DataFrame(y, index=x, columns=['electricity_generation'])
# df_graf.index.name = 'year'

# datos_promedio=[]
# for anio in range(2010, 2021):
#     dato_df = float(df_sum_anual['electricity_generation'].loc[[anio]])
#     dato_graf = float(df_graf['electricity_generation'].loc[[anio]])
#     promedio=(dato_df+dato_graf)/2
#     datos_promedio.append(promedio)
#%%

