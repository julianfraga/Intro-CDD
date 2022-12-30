# -*- coding: utf-8 -*-
"""
Created on Sun Nov  6 20:41:25 2022

@author: Julián
"""

import imageio
import matplotlib.pyplot as plt
import numpy as np
#cargamos la imagen a analizar
imagen = imageio.imread('energia_eu.png')


#layer de la imagen como matriz con valores de 0-255
# A = AA[:,:,1]

#grafica la imagen original
plt.figure(figsize = (30, 30))
plt.imshow(imagen)
pasada=0
puntos=41
n=10
lista = []
while pasada < n:
    coordenadas = plt.ginput(puntos, timeout=0)
    lista.append(coordenadas)
    pasada+=1


# coso=np.array([[(1,1), (0,1), (10,1)], [(4,1), (5,1), (6,1)]])
# np.mean(coso, axis=0)
tensor=np.array(lista)
coord_medias=np.mean(tensor, axis=0)
# np.save('data_grafico', tensor)
# np.save('coordenadas_grafico', coord_medias)
#%%
plt.figure(figsize = (30, 30))
plt.imshow(imagen)
n=5
vueltas=0
calibracion_x=[]
while vueltas<n:
    x=plt.ginput(2, timeout=0)
    calibracion_x.append(x)
    vueltas+=1
#%%
def calibrar_x(data, refe_ini, refe_fin):
    delta_pixel = []
    for i in range(len(data)):
        x_ini = data[i][0][0]
        x_fin = data[i][0][1]
        delta_pixel.append(x_fin-x_ini)
    
    delta_refe = refe_fin - refe_ini
    
    pix_por_refe = np.mean(delta_pixel)/delta_refe
    
    return(pix_por_refe)
factor_x=calibrar_x(calibracion_x, 2010, 2050)
#%%
plt.figure(figsize = (20, 20))
plt.imshow(imagen)
n=5
vueltas=0
calibracion_y=[]
while vueltas<n:
    y=plt.ginput(2, timeout=0)
    calibracion_y.append(y)
    vueltas+=1
 #%%
# np.save('calibracion_y', calibracion_y)

