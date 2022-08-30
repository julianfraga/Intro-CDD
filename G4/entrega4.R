library(tidyverse)
library(ggridges)
df_seguros<-read.csv(file='/home/datascience/Descargas/Insurance.csv',dec=",")
df_southeast <-filter(df_seguros, region=='southeast')

ggplot(data = df_southeast, aes(x=charges)) +
  geom_freqpoly(aes(color=sex, linetype=smoker))

ggplot(data = df_southeast, aes(x=charges)) +
  geom_density_ridges(aes(y=smoker, color=sex), alpha=0.5)


df_sexo <- group_by(df_southeast, sex=='male')
metrica_southeast <- summarise(df_sexo, mean(charges), median(charges))
df_sexo_fumadores <- group_by(df_sexo, smoker=='yes')
metrica_fumadores <- summarise(df_sexo_fumadores, mean(charges), median(charges))

if (df_sexo_fumadores[sexbooleano]==TRUE){ #& df_sexo_fumadores['smoker=="yes"']==TRUE)
  hombresfumadores <-summarise(df_sexo_fumadores, mean(charges), median(charges))}
else if 
  sex==FALSE and smoker==TRUE:
  mujeresfumadoras <- summarise(df_sexo_fumadores, mean(charges), median(charges))
else if 
  sex==TRUE and smoker==FALSE:
  hombresnofumadores <- summarise(df_sexo_fumadores, mean(charges), median(charges))
else 
  mujeresnofumadoras <- summarise(df_sexo_fumadores, mean(charges), median(charges))

