library(modelr)
library(tidyverse)
options(na.action = na.warn)


#Tarea 1
#test estadisitco

sim1 <-  sim1
mod1 <- lm(y~x, sim1)

grid <- data_grid(sim1, x) 
grid <- add_predictions(sim1, mod1) #ingreso de donde saco la data y aplico el mdoelo


ggplot(sim1, aes(x,y)) +
  geom_point()+
  geom_line(data = grid, aes(x=x, y=pred, color= "red"))+
  ggtitle(label='Datos simulados Sim1 y ajuste lineal')
#realizamos el ajsute de los datoss

#Calculo de residuos
grid_2 <- add_residuals(sim1, mod1)

ggplot(sim1, aes(x,y)) +
  geom_point(data = grid_2, aes(x=x, y=resid, color= "red"))

#analisis de residuos
plot(mod1)

#Vemos el valor de los coeficientes y de los estadisticos
summary(mod1)

#agreamos riudo a y 
ruido_y <-  rnorm(30, sd = 10) #sd variacion estandar
sim1_ruido <-  sim1
sim1_ruido$y <- sim1$y+ruido_y 
#realizamos el modelado de nuevo
mod1_ruido <- lm(y~x, sim1_ruido)

grid_ruido <- data_grid(sim1_ruido, x) 
grid_ruido <- add_predictions(sim1_ruido, mod1_ruido) #ingreso de donde saco la data y aplico el mdoelo
plot(sim1_ruido)
summary(mod1_ruido)


#compramos graficos

ggplot(sim1_ruido, aes(x,y)) +
  geom_point()+
  geom_line(data = grid_ruido, aes(x=x, y=pred, color= "red"))+
  ggtitle(label='Datos simulados Sim1 con ruido de SD=30 y ajuste lineal')
#realizamos el ajsute de los datoss

#Calculo de residuos

#ejercicio 2 terminos de interaccion

sim3<- sim3
glimpse(sim3)
#x2 factor 




ggplot (data= sim3)+ geom_point(aes(x=x2, y=y))

#diferencia en tre formula

mod1 <- lm(y~ x1+x2, sim3)
mod2 <- lm(y~ x1*x2, sim3)

matriz_m <- model_matrix(sim3, mod1)
matriz_m2 <- model_matrix(sim3, mod2)
view( matriz_m)
view( matriz_m2)

#ajustar modelos 
grilla<- sim3 %>%
  data_grid(x1, x2) %>%
  gather_predictions(mod1, mod2)

#grafico en facetas
ggplot(sim3, aes(x1, y, colour = x2)) +
  geom_point() +
  geom_line(data = grilla, aes(y = pred)) +
  facet_wrap(~model)

#casos para cada formula 









