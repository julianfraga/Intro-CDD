# -*- coding: utf-8 -*-
"""
Created on Sun Nov 13 15:23:23 2022

@author: Julián
"""
import numpy as np
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
calibracion_y=np.load('calibracion_y.npy')
factor_y = calibrar_y(calibracion_y, 0, 5000)
tensor=np.load('data_grafico.npy')
coord_medias=np.mean(tensor, axis=0)

escala, offset=calibrar_y(calibracion_y, 0, 5000)

x=np.arange(2010, 2051)
y=(np.transpose(coord_medias)[1]-offset)/escala

import pandas as pd
data= pd.DataFrame(np.transpose(np.array([x,y])), columns=['year','electricity_generation'])
data.to_csv('data_grafico_brainpool.csv', sep=',')


