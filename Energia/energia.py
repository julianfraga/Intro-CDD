# -*- coding: utf-8 -*-
"""
Created on Sat Oct 15 15:29:17 2022

@author: Julián
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def ajuste_region(df, nom_region,col_region='region',col_iso='iso_code', x='year', y='renewables_share_elec',plot=False):
    '''
    Toma un dataframe y devuelve una lista de diccionarios.
    
        Itera entre países de una dada región con la columna correspondiente
    al código iso y hace el ajuste lineal sobre las variables x e y 
    especificadas. Los parámetros del ajuste los guarda como diccionario junto 
    con el ISO correspondiente y todo eso en una lista. 
    
    Opcionalmente, grafica los ajustes.
    '''
    region = df[df[col_region]==nom_region]
    data = region[[col_iso, x, y]]
    ajustes = []
    
    if plot:
        plt.clf()

    for iso in pd.unique(region[col_iso]):
        data_ = data[ data[col_iso] == iso ]
        if not data_.empty:
            try:
                ajuste = np.polyfit(data_[x], data_[y], 1)
                reg = {'iso':iso,'pendiente':ajuste[0], 'ordenada':ajuste[1]}
                ajustes.append(reg)
                
                if plot:
                    y_ = ajuste[0] * data_[x] + ajuste[1]
                    plt.plot(data_[x], y_, label=iso)
                    plt.grid()
                    plt.legend()
            
            except Exception as e:
                print(f'No se realizar ajuste para {iso}')
                print(e)
                print('')
            
    return(ajustes)



def to_csv(lista,nombre, lista_de_diccionarios=True, tiene_header=True):
    ''' 
    guarda una lista como csv. Por default toma una lista de diccionarios
    donde los headers son las keys del primer diccionario.
    
    '''
    
    import csv
    
    if lista_de_diccionarios:
        headers = list(lista[0].keys())
    
    else:
        if tiene_header:
            headers = lista[0]
        else:
            print('no hay headers')
    
    with open(nombre+'.csv', 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = headers)
        writer.writeheader()
        writer.writerows(lista)

#%%
df_energia = pd.read_csv('WorldEnergyConsumption.csv')
df=df_energia[['iso_code', 'year', 'renewables_share_elec']]
df.dropna(inplace=True)

iso_regiones = pd.read_csv('iso_3_continents.csv')
iso_regiones = iso_regiones.rename(columns={'alpha-3':'iso_code'})
iso_regiones = iso_regiones[['name','iso_code', 'region', 'sub-region', 'intermediate-region']]

df= pd.merge(df, iso_regiones, on='iso_code', how='left')


for region in pd.unique(df['region']):
    if type(region)==str:
        ajustes=ajuste_region(df, nom_region=region, plot=True)
        to_csv(ajustes, 'ajuste_'+region)

