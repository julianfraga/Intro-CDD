library(tidyverse)
library(ggridges)
library(dplyr)
df_seguros<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/Insurance.csv',dec=",")

#la lista de regiones
regiones <- unique(df_seguros['region']) #esto es un dataframe, ojo

#un par de gráficos, uno para cada región
df_seguros$smoker = as.factor(df_seguros$smoker)
df_seguros$sex=as.factor(df_seguros$sex)
df_seguros<-mutate(df_seguros, sobrepeso=bmi>=25) 
df_seguros <- unique(df_seguros)
glimpse(df_seguros)
#bmi >25=sobrepeso

#la lista de regiones
regiones <- unique(df_seguros['region']) #esto es un dataframe, ojo

#un par de gráficos, uno para cada región
df_ne<-filter(df_seguros, region=='northeast')
ggplot(data = df_ne, aes(x=charges)) + 
  geom_density_ridges(aes(y=smoker, color=sex), alpha=0.5)+
  labs(title="north-east",x ="Gasto anual")

ggplot(data = df_ne, aes(x=charges)) + 
  geom_density_ridges(aes(y = sobrepeso, color=sex), alpha=0.5)+
  labs(title="north-east",x ="Gasto anual")



df_se<-filter(df_seguros, region=='southeast')
ggplot(data = df_se, aes(x=charges)) + 
  geom_density_ridges(aes(y=smoker, color=sex), alpha=0.5)+
  labs(title="south-east",x ="Gasto anual")

df_nw<-filter(df_seguros, region=='northwest')
ggplot(data = df_nw, aes(x=charges)) +
  geom_density_ridges(aes(y=smoker, color=sex), alpha=0.5)+
  labs(title="north-west",x ="Gasto anual")

df_sw<-filter(df_seguros, region=='southwest')
ggplot(data = df_sw, aes(x=charges)) +
  geom_density_ridges(aes(y=smoker, color=sex), alpha=0.5)+
  labs(title="south-west",x ="Gasto anual")

#Clave este Pipeline. Quiero métricas discriminadas por sexo para cada región
metricas <-df_seguros%>% group_by(region, sex) %>% 
  summarise(media=mean(charges),desviacion=sd(charges), mediana=median(charges), IQR=IQR(charges))

metricas['desv_relativa']<-metricas['desviacion']/metricas['media']

metricas%>%group_by(media, desv_relativa)%>%arrange(desc(media))

write.csv(df_se,"D:/Documentos/UNSAM/Intro CDD/G4/insurance_SE.csv", row.names = FALSE)



