install.packages("tidyverse")
install.packages('nycflights13')
library(tidyverse)
library(nycflights13)

#Histogramas----
agrupado<-group_by(flights, carrier)
view(flights)
nrow(flights)
colnames(flights)
unique(flights['carrier'])
unique(select(flights, carrier))
unique(flights$carrier)
agrupado<-group_by(flights, carrier)
summarize(agrupado, n_vuelos=n())

agrupado<-mutate(agrupado, n_vuelos=n())
flights_carrier <-ungroup(agrupado)
flights_carrier_mil <-filter(flights_carrier, n_vuelos>1000)
vuelos_aerolineas<-summarize(agrupado, n_vuelos=n())
aerolinea_filtrada <- filter(flights_carrier_mil, carrier=='EV')
ggplot(aerolinea_filtrada, aes(x=arr_delay))+geom_histogram()
ggplot(aerolinea_filtrada, aes(x=arr_delay))+geom_histogram(binwidth = 60)
ggplot(aerolinea_filtrada, aes(x=arr_delay))+geom_histogram(binwidth = 10)+labs(title='Histograma de vuelos con demora', subtitle='EV', x='Demora en la llegada (min)', y='Cantidad de vuelos')
#media mediana std IQR----
retrasos <- summarize(aerolinea_filtrada, mean(arr_delay, na.rm=TRUE))
retrasos <- summarize(aerolinea_filtrada, mean(arr_delay, na.rm=TRUE), median (arr_delay, na.rm=TRUE), sd(arr_delay, na.rm=TRUE), IQR(arr_delay, na.rm=TRUE))
View(retrasos)
#tiempo recuperado ----
aerolinea_filtrada$mes_cat<-as.factor(ifelse(aerolinea_filtrada['month']==1, 'enero', 
ifelse(aerolinea_filtrada['month']==2, 'febrero', 
ifelse(aerolinea_filtrada['month']==3,  'marzo',
ifelse(aerolinea_filtrada['month']==4,  'abril',
ifelse(aerolinea_filtrada['month']==5,  'mayo',
ifelse(aerolinea_filtrada['month']==6,  'junio',
ifelse(aerolinea_filtrada['month']==7,  'julio',
ifelse(aerolinea_filtrada['month']==8,  'agosto',
ifelse(aerolinea_filtrada['month']==9,  'septiembre',
ifelse(aerolinea_filtrada['month']==10,  'octubre',
ifelse(aerolinea_filtrada['month']==11,'noviembre', 'diciembre'))))))))))))

#Nota: el tiempo ganado no quiere decir una corrección en el horario. Si sale
#temprano el avión y llega más temprano aún va a tener un tiempo ganado positivo
#lo mismo si sale tarde pero llega sobre la hora o antes de lo esperado
aerolinea_filtrada<-mutate(aerolinea_filtrada, t_ganado = dep_delay-arr_delay) 

enero_julio<-filter(aerolinea_filtrada, mes_cat %in% list('julio','diciembre'))
ggplot(enero_julio, aes(x=dep_delay, fill=mes_cat))+geom_histogram(alpha=0.7)+labs(title='Retrasos de partida', subtitle='de la aerolínea EV durante los meses de Julio y Diciembre', x='Retraso de partida (min)', y='')+xlim(-20, +70)
#-----
recuperacion<- mutate(aerolinea1, T_recuperado = dep_delay-arr_delay) 
ggplot(recuperacion, aes(x=T_recuperado))+geom_histogram()+labs(title='tiempo recuperdao en el aire', subtitle='EV', x='recuperacion (min)', y='Cantidad de vuelos')+xlim(-50, +50)
demora_llegada<-vector()
tiempo_ganado<-vector()

fecha<-group_by(flights, month)
fecha<- mutate(fecha, T_recuperado = dep_delay-arr_delay) 

for (i in 1:12){
  mes<-filter(fecha, month==i)  
  demora_llegada <- append(demora_llegada, summarize(mes, mean(arr_delay, na.rm=TRUE)))
  tiempo_ganado<- append(tiempo_ganado, summarize(mes, mean(T_recuperado, na.rm=TRUE)))
  
}
fecha$mes_cat<-as.factor(ifelse(fecha['month']==1, 'enero', 
                          ifelse(fecha['month']==2, 'febrero', 
                          ifelse(fecha['month']==3,  'marzo',
                          ifelse(fecha['month']==4,  'abril',
                          ifelse(fecha['month']==5,  'mayo',
                          ifelse(fecha['month']==6,  'junio',
                          ifelse(fecha['month']==7,  'julio',
                          ifelse(fecha['month']==8,  'agosto',
                          ifelse(fecha['month']==9,  'septiembre',
                          ifelse(fecha['month']==10,  'octubre',
                          ifelse(fecha['month']==11,'noviembre', 'diciembre')))))))))))) 
tabla<-summarise(fecha, demora_llegada=mean(arr_delay, na.rm=TRUE), tiempo_ganado=mean(T_recuperado, na.rm=TRUE))

#histogramas de demoras----
df_demoras<-filter(fecha, mes_cat=='noviembre')
ggplot(df_demoras, aes(x=arr_delay))+geom_histogram()+xlim(-100,200)
