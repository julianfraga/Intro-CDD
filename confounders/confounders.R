library(tidyverse)
library(ggridges)
library(dplyr)
library(grid)

df_completo<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/insurance/Insurance.csv',dec=",") %>% drop_na()
df_completo$smoker<-as.factor(df_completo$smoker)
df_completo$sobrepeso<-df_completo$bmi>=30
ggplot(data=df_completo, aes(x=age, y=charges,gropup=smoker))+
  geom_point(aes(color=smoker))+
  labs(title='Gasto médico vs edad de toda la población', 
     subtitle='discriminando Fumador/No Fumador')+xlab('Edad')+ 
  ylab('Gasto médico anual [U$D]')


#----

p1 <- ggplot(data=df_completo, aes(x=age, y=charges,gropup=smoker))+
  geom_point(aes(color=smoker))+
  labs(title='Gasto médico vs edad de toda la población', 
       subtitle='discriminando Fumador/No Fumador')+xlab('Edad')+ 
  ylab('Gasto médico anual [U$D]')

p2 <- ggplot(data=df_completo, aes(x=age, y=charges,gropup=sobrepeso))+
  geom_point(aes(color=sobrepeso))+
  labs(title='Gasto médico vs edad de toda la población', 
       subtitle='discriminando BMI>=30')+xlab('Edad')+ 
  ylab('Gasto médico anual [U$D]')

grid.arrange(p1, p2, ncol = 2)

#----



df <- filter(df_completo, df_completo$smoker=='yes'&df_completo$bmi>=30)
#df<- df_completo
modelin<- lm(charges~age, data=df)
summary(modelin)
grid<-data_grid(df, charges)


grid <- add_predictions(df, modelin)
ggplot(grid, aes(x=age))+geom_point(aes(y=charges))+
  geom_line(aes(y=pred), color='red')+
  labs(title='Gasto médico vs edad para población fumadora con BMI>=30', 
       subtitle='Pend.= 260; Ord. Origen= 11503; R^2= 0.477; p-valor< 2.2e-16')+xlab('Edad')+ 
  ylab('Gasto médico anual')



grid<- add_residuals(df, modelin)
ggplot(data = grid)+geom_point(aes(x=age, y=resid))

#----
resultados <- read.csv(file='D:/Documentos/UNSAM/Intro CDD/confounders/resultados_confounders.csv',dec=",")%>% drop_na()
resultados$Categoria=as.factor(resultados$Categoria)
resultados$Pendiente=as.double(resultados$Pendiente)
resultados$pendienteSd=as.double(resultados$pendienteSd)
resultados$Ordenada=as.double(resultados$Ordenada)
resultados$ordenadaSD=as.double(resultados$ordenadaSD)



ggplot(data=resultados, aes(x=Categoria, y=Ordenada))+geom_point(size=2)+
  geom_errorbar(aes(ymin=Ordenada-ordenadaSD, ymax=Ordenada+ordenadaSD), width=.2,
                position=position_dodge(.9))+
  labs(title='Ordenadas al origen predichas según subgrupo', 
       subtitle='y pendientes predichas')+xlab('Subgrupo')+ 
  ylab('Ordenada al origen predicha [U$D]')+

glimpse(resultados)
