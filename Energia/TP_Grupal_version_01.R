#file: trabjo grupal.r
#date = 19/10/2022
#@authors: grupo 8

##LIBRERIAS
#####
library(tidyverse)
library(modelr)
options(na.action= na.warn)

#####

#Dataset
#####
df_a <- read.csv('WorldEnergyConsumption.csv') %>% 
  filter(year>=1985)

df_iso <- read.csv('./Energia/iso_3_continents.csv')
df_iso <- df_iso %>% 
  rename_at('alpha.3', ~ 'iso_code') 
df_iso <- df_iso %>% 
  rename_at('name', ~ 'country') 

df <- right_join(df_a, df_iso, by=c('iso_code','country'))

df <- merge(x=df, y = df_iso, by = c('iso_code', 'sub.region','region'))
df <- df %>% 
  rename_at('country.x', ~ 'country') 

#LIMPIEZA DE DATOS

#Busco la cantidad de datos distintos que hay
df_check <- df %>% summarise(distintos= n_distinct(df), total = n())

df %>% summarise(cant_datos= n(),
                 na_renewables_electricity= sum(is.na(renewables_electricity)),
                 na_electricity_generation= sum(is.na(electricity_generation)),
                 na_iso_code = sum(is.na(iso_code)),
                 na_year = sum(is.na(year)),
                 
)
#FALTANTES:
#renewables_electricity = 1821
#electricity_generation = 1821
#yaer = 53
error_check <- df %>% group_by(iso_code, year,renewables_electricity,electricity_generation) %>%  summarise()
#LIMPIEZA
df <- df[!is.na(df$renewables_electricity),]
df <- df[!is.na(df$electricity_generation),]
df <- df[!is.na(df$year),]

#df$iso_code <- as.factor(df$iso_code)
#df$sub.region <- as.factor(df$sub.region)


######

#EUROPA
#####

df_europa <- df %>% filter(region == 'Europe')

#SE RETIRA ALANDS ISALANDS, ES UNA PROVINCIA AUTONOMA DE FILANDIA
#ARMENIA NO ESTA INCLUIDO SE CONSIDERA PAIS DE ASIA
#GILBRART NO ES UN PAIS SEGUN LA ONU
#segun wiki Guernsey no es un pais de euro sorry not sorry
#ISLA OF MAN dependencia british igual que jersey
#Svalbard and Jan Mayen son de noruega


df_europa <- subset(df_europa, iso_code !="ALA" & 
                      iso_code !="GIB" & 
                      iso_code !="GGY" & 
                      iso_code !="IMN" & 
                      iso_code !="JEY" & 
                      iso_code !="SJM")


#Graficos
#grafico de la produccion de electricidad total de segun las regiones de europa 
europa <- ggplot(data = df_europa, aes(x=year, y = electricity_generation, color=iso_code))+
  geom_point()+theme(legend.position = "none")+facet_wrap(~sub.region)

#ajuste europa
mod_eu <- lm(renewables_electricity ~ year * iso_code, df_europa)
grid_eu <- data_grid(data = df_europa, iso_code, year, renewables_electricity) %>% #VER BIEN PARAMETROS QUE PASAMOS
  add_predictions(mod_eu) %>% unique()

#europa + ajuste
europa +
  geom_line(data=grid_eu, aes(x=year, y=pred))+ 
  theme(legend.position = "none")



#PROBAR ESTO

ggplot(data=df_europa, aes(x=year, y=electricity_generation)) +geom_point(aes(color = iso_code)) +
  geom_line(data= grid_eu, aes(x=year, y =pred, color = iso_code)) + facet_wrap(~iso_code) + 
  theme(legend.position =  "none")



#definicion de calidad
#Calcular media de europa para luego poder definir si las pendientes
#de cada país es mejor igual o peor 


mod_eu_summary <-summary(mod_eu)
data_euro_coeficientes <- data.frame(coefficients(mod_eu))
mean(mod_eu$residuals^2)#MSE Error Cuadrático Medio 
mod_eu_summary$r.squared # Coeficiente de Determinación R2
sqrt(mean(mod_eu_summary$residuals^2)) #RMSE Raíz del Error Cuadrático 


#####

#AMERICA
#####
df_america <- df %>% filter(region == 'Americas')

#graficos
america <- ggplot(data = df_america, aes(x=year, y = electricity_generation, color=iso_code))+
  geom_point()+theme(legend.position = "none")

#ajuste america
mod_americas <- lm(renewables_electricity ~ year + iso_code, df_america)
grid_americas <- data_grid(data = df_america, iso_code, year, renewables_electricity) %>% #VER BIEN PARAMETROS QUE PASAMOS
  add_predictions(mod_americas)

#plot + ajuste
america +
  geom_line(data=grid_americas, aes(x=year, y=pred))+ 
  theme(legend.position = "none")

#####

df_total_europa <- df_a %>% filter(country=="Europe") %>% 
  group_by(country, year, renewables_electricity,electricity_generation) %>% summarise()

df_total_europa_b <- df_a %>% filter(country==c("Europe","Europe other")) %>% 
  group_by(country, year, renewables_electricity,electricity_generation) %>% summarise()


df_suma_europa <- df_europa %>%
  group_by(year) %>%
  summarise(suma_renewables_electricity= sum(renewables_electricity),
            suma_electricity_generation = sum(electricity_generation))

#suma de la electricidad total( top x paises)
### ordenamiento top  FUNCIONA
df_top <- df_europa %>% group_by(country) %>% 
  mutate(total = sum(electricity_generation, na.rm =T)) %>% 
  summarise(country,total)
df_top <- df_top %>% group_by(country, total) %>% summarise()
df_top <- df_top[order(df_top$total, decreasing = TRUE),] %>% head(n=5)

top_5 = right_join(df_europa, df_top, by ='country')

#ajuste top 5
mod_top_5 <- lm(renewables_electricity ~ year * iso_code, top_5)
grid_top_5 <- data_grid(data = top_5, iso_code, year, renewables_electricity) %>% #VER BIEN PARAMETROS QUE PASAMOS
  add_predictions(mod_top_5) %>% unique()


europa_top_5 <- ggplot(data=top_5) +geom_point(aes(x=year, y=electricity_generation)) 

europa_top_5 <- geom_line(data= grid_top_5, aes(x=year, y =pred, color = iso_code)) + 
  facet_wrap(~iso_code) + 
  theme(legend.position =  "none")
