# -*- coding: utf-8 -*-
"""
Created on Mon Oct 10 20:27:35 2022

@author: Julián
"""
import numpy as np
sdv=np.array([26.25,23.99, 13.88,15])
medias=np.array([281.15,260.64,267.39, 265.95])


promPesado=np.average(medias, weights=1/sdv)
def weighted_avg_and_std(values, weights):
    """
    Return the weighted average and standard deviation.

    values, weights -- Numpy ndarrays with the same shape.
    """
    average = np.average(values, weights=weights)
    # Fast and numerically precise:
    variance = np.average((values-average)**2, weights=weights)
    return (average, np.sqrt(variance))
weighted_avg_and_std(medias, 1/sdv)
(281+26.25-(260-24))
ordenadas=np.array([30558.13,11503.36,-2029.05,-2118.37])
ordenadas_sdv=np.array([1093.04,962.92,598.59,609.43])
weighted_avg_and_std(ordenadas, 1/ordenadas_sdv)
sdv/medias
ordenadas_sdv/ordenadas
