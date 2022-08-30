import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
os.chdir(r'D:\Documentos\UNSAM\Intro CDD\G1')
cwd= os.getcwd()
#%%
df_raw=pd.read_excel('insurance.xlsx')
df= df_raw.dropna()
df.head(10)
columns=list(df.columns)
#%%
df['sex'].unique()
mujeres=df.groupby('sex').get_group('female')
hombres=df.groupby('sex').get_group('male')
fumadores=df.groupby('smoker').get_group('yes')
no_fumadores=df.groupby('smoker').get_group('no')
#%%
from matplotlib.ticker import PercentFormatter

no_fuma=no_fumadores['charges']
fuma=fumadores['charges']
fuma_mu, fuma_sigma= np.mean(fuma), np.std(fuma)
no_fuma_mu, no_fuma_sigma= np.mean(no_fuma), np.std(no_fuma)
label_fuma='Fumadores \n $\mu=%.2f$k \n $\sigma=%.2f$k' % (fuma_mu/10e2, fuma_sigma/10e2)
label_no_fuma='No fumadores \n $\mu=%.2f$k \n $\sigma=%.2f$k' % (no_fuma_mu/10e2, no_fuma_sigma/10e2)

plt.clf()
plt.hist(no_fuma,weights=np.ones(len(no_fuma)) / len(no_fuma), alpha=0.5, label=label_no_fuma)
plt.hist(fuma,weights=np.ones(len(fuma)) / len(fuma), alpha=0.5, label= label_fuma)
plt.legend()
plt.xlabel('Gastos médicos (U$D)')
plt.xticks(ticks=np.array([0,0.5,1, 2, 3, 4, 5, 6])*10e3, labels=['0', '5k', '10k', '20k', '30k', '40k', '50k', '60k'])
plt.ylabel('Porcentaje de los individuos registrados')
plt.gca().yaxis.set_major_formatter(PercentFormatter(1))
plt.grid(axis='y', alpha=0.35)
plt.show()
#%%
subcat='bmi (body-mass-index)'
threshold=30.0
sobrepeso=df[subcat]>=30
no_sobrepeso=df[subcat]<30
no_fumadores_sobrepeso=no_fumadores[sobrepeso]
no_fumadores_no_sobrepeso=no_fumadores[no_sobrepeso]
fumadores_sobrepeso=fumadores[sobrepeso]
fumadores_no_sobrepeso=fumadores[no_sobrepeso]

no_fuma_no_sobrepeso=no_fumadores_no_sobrepeso['charges']
no_fuma_sobrepeso=no_fumadores_sobrepeso['charges']
fuma_no_sobrepeso=fumadores_no_sobrepeso['charges']
fuma_sobrepeso=fumadores_sobrepeso['charges']


fuma_sbp_mu, fuma_sbp_sigma= np.mean(fuma_sobrepeso), np.std(fuma_sobrepeso)
no_fuma_sbp_mu, no_fuma_sbp_sigma= np.mean(no_fuma_sobrepeso), np.std(no_fuma_sobrepeso)

fuma_no_sbp_mu, fuma_no_sbp_sigma= np.mean(fuma_no_sobrepeso), np.std(fuma_no_sobrepeso)
no_fuma_no_sbp_mu, no_fuma_no_sbp_sigma= np.mean(no_fuma_no_sobrepeso), np.std(no_fuma_no_sobrepeso)

label_fuma_sbp='Fumadores con sbp.\n $\mu=%.2f$k \n $\sigma=%.2f$k' % (fuma_sbp_mu/10e2, fuma_sbp_sigma/10e2)
label_no_fuma_sbp='No fumadores con sbp\n $\mu=%.2f$k \n $\sigma=%.2f$k' % (no_fuma_sbp_mu/10e2, no_fuma_sbp_sigma/10e2)

label_fuma_no_sbp='Fumadores sin sbp.\n $\mu=%.2f$k \n $\sigma=%.2f$k' % (fuma_no_sbp_mu/10e2, fuma_no_sbp_sigma/10e2)
label_no_fuma_no_sbp='No fumadores sin sbp\n $\mu=%.2f$k \n $\sigma=%.2f$k' % (no_fuma_no_sbp_mu/10e2, no_fuma_no_sbp_sigma/10e2)



plt.clf()
plt.hist(fuma_sobrepeso,weights=np.ones(len(fuma_sobrepeso)) / len(fuma_sobrepeso), alpha=0.5, label= label_fuma_sbp)
plt.hist(no_fuma_sobrepeso,weights=np.ones(len(no_fuma_sobrepeso)) / len(no_fuma_sobrepeso), alpha=0.5, label= label_no_fuma_sbp)
plt.hist(fuma_no_sobrepeso,weights=np.ones(len(fuma_no_sobrepeso)) / len(fuma_no_sobrepeso), alpha=0.5, label=label_fuma_no_sbp)
plt.hist(no_fuma_no_sobrepeso,weights=np.ones(len(no_fuma_no_sobrepeso)) / len(no_fuma_no_sobrepeso), alpha=0.5, label=label_no_fuma_no_sbp)

plt.legend()
plt.xlabel('Gastos médicos (U$D)')
plt.xticks(ticks=np.array([0,0.5,1, 2, 3, 4, 5, 6])*10e3, labels=['0', '5k', '10k', '20k', '30k', '40k', '50k', '60k'])
plt.ylabel('Porcentaje de los individuos registrados')
plt.gca().yaxis.set_major_formatter(PercentFormatter(1))
plt.grid(axis='y', alpha=0.35)
plt.show()



#%%
categoria='sex'
grupos=list(df[categoria].unique())
grupos.sort()
print(grupos)

grupo_a=df.groupby(categoria).get_group(grupos[0])
grupo_b=df.groupby(categoria).get_group(grupos[1])

a=grupo_a['charges']
b=grupo_b['charges']
a_mu, a_sigma= np.mean(a), np.std(a)
b_mu, b_sigma= np.mean(b), np.std(b)
label_a=str(grupos[0])+' \n $\mu=%.2f$k \n $\sigma=%.2f$k' % (a_mu/10e2, a_sigma/10e2)
label_b=str(grupos[1])+' \n $\mu=%.2f$k \n $\sigma=%.2f$k' % (b_mu/10e2, b_sigma/10e2)

plt.clf()
plt.title('Gastos médicos discriminados por '+str(categoria))
plt.hist(a,weights=np.ones(len(a)) / len(a), alpha=0.5, label=label_a)
plt.hist(b,weights=np.ones(len(b)) / len(b), alpha=0.5, label= label_b)
plt.legend()
plt.xlabel('Gastos médicos (U$D)')
plt.xticks(ticks=np.array([0,0.5,1, 2, 3, 4, 5, 6])*10e3, labels=['0', '5k', '10k', '20k', '30k', '40k', '50k', '60k'])
plt.ylabel('Porcentaje de los individuos registrados')
plt.gca().yaxis.set_major_formatter(PercentFormatter(1))
plt.grid(axis='y', alpha=0.35)
plt.show()


#%%
# =============================================================================
# Sección BMI
# =============================================================================
