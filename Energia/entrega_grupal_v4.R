##LIBRERIAS
#####
library(tidyverse)
library(modelr)
options(na.action= na.warn)
#####
#Dataset
#####
df <- read.csv('World Energy Consumption.csv') %>% 
  filter(year>=1985)

df_iso <- read.csv('iso_3_continents.csv')
df_iso <- df_iso %>% 
  rename_at('alpha.3', ~ 'iso_code') 
df_iso <- df_iso %>% 
  rename_at('name', ~ 'country') 

df <- right_join(df, df_iso, by=c('iso_code','country'))

df <- merge(x=df, y = df_iso, by = c('iso_code', 'sub.region','region'))
df <- df %>% 
  rename_at('country.x', ~ 'country') 

#LIMPIEZA DE DATOS

#Busco la cantidad de datos distintos que hay
#df_check <- df %>% summarise(distintos= n_distinct(df), total = n())

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
#error_check <- df %>% group_by(iso_code, year,renewables_electricity,electricity_generation) %>%  
#  summarise()
#LIMPIEZA
df <- df[!is.na(df$renewables_electricity),]
df <- df[!is.na(df$electricity_generation),]
df <- df[!is.na(df$year),]

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
#toda EU
df_eu_energy <- df_europa %>% group_by(year) %>%
  mutate(total_energy = sum(electricity_generation, na.rm =T)) %>%
  mutate(total_renewable = sum(renewables_electricity, na.rm =T))%>%
  summarise(total_energy,total_renewable, year)

#Grilla EU y ajuste EU
df_eu_energy <- df_eu_energy %>% group_by(year,total_renewable, total_energy) %>% summarise()

mod_eu_total <-lm(total_energy ~ year, df_eu_energy)

#Grilla + pred 
df_eu_total <- df_eu_energy %>%
  add_predictions(mod_eu_total) 

#Graficos 
graf1 <- ggplot()+ geom_point(data= df_eu_total, aes(x=year, y=total_energy),shape = "\U26A1", size =4)+
  geom_line(data= df_eu_total, aes(x=year, y= pred),color = "orange")+
  labs(title="Tendencia de la energia producida",
       subtitle = "En Europa",
       x = "A??o",
       y="Energia (TWh)",
  )+
  theme(plot.title = element_text(size=25),
        plot.subtitle = element_text(size = 22),
        axis.title.x = element_text(color="black", size=21),
        axis.text.x = element_text(color="black", size=20),
        axis.title.y = element_text(color="black", size=21),
        axis.text.y = element_text(color="black", size=20),
  )

#Stats 
mod_eu_summary <-summary(mod_eu_total)
data_euro_coeficientes <- data.frame(coefficients(mod_eu_total))
mean(mod_eu_total$residuals^2)           #MSE Error Cuadr??tico Medio 
mod_eu_summary$r.squared              #Coeficiente de Determinaci??n R2
sqrt(mean(mod_eu_summary$residuals^2))


#energias renovables ----

mod_eu_renew <-lm(total_renewable ~ year, df_eu_energy)

df_eu_renew <- df_eu_energy %>%
  add_predictions(mod_eu_renew) 

graf2 <- graf1 + geom_point(data= df_eu_renew, aes(x=year, y=total_renewable),shape = "\U1F7E2")+
  geom_line(data= df_eu_renew, aes(x=year, y= pred), color = "dark green")


# hasta el 2030

coef_reno <- coefficients(mod_eu_renew) #se indexa a partir del 1
#(Intercept)         year 
#-51502.69176     26.17508 

coef_tot <- coefficients(mod_eu_total)
#(Intercept)         year 
#-49149.79497     26.69736

#a mano 
#pendiente por a??o + ordenada 
#Y <- coef_reno[2] * year + coef_reno[1]

######
#TOP 5 EN EUROPA-----

#suma de la electricidad total( top x paises)
# ordenamiento top  FUNCIONA
df_top_elec <- df_europa %>% group_by(country) %>% 
  mutate(total_elec = sum(electricity_generation, na.rm =T)) %>% 
  summarise(country,total_elec)

df_top_elec <- df_top_elec %>% group_by(country, total_elec) %>% summarise()
df_top_elec <- df_top_elec[order(df_top_elec$total_elec, decreasing = TRUE),] %>% head(n=5)


#top 5 renovables----
df_top_renew <- df_europa %>% group_by(country) %>% 
  mutate(total_renew = sum(renewables_electricity, na.rm =T)) %>% 
  summarise(country,total_renew)

df_top_renew <- df_top_renew %>% group_by(country, total_renew) %>% summarise()
df_top_renew <- df_top_renew[order(df_top_renew$total_renew, decreasing = TRUE),] %>% head(n=5)

#Porcentaje verdolaga----
df_eu_renew<- df_eu_renew %>% rename_at('pred', ~ 'pred_renew') 
df_eu_total<- df_eu_total %>% rename_at('pred', ~ 'pred_total')

df_pred<- inner_join(df_eu_total, df_eu_renew, by=c('year', 'total_renewable', 'total_energy'))
df_pred$green_share<- df_pred$total_renewable/df_pred$total_energy

modelo_verde_eu=lm(green_share~year+I(poly(year, 5)), data=df_pred)
summary(modelo_verde_eu)
#???-log(1-green_share)
#green_share ~ year + I(1-exp(-year))
df_pred<-df_pred %>% add_predictions(modelo_verde_eu) %>%
  rename_at('pred', ~'green_share_pred')


ggplot(data=df_pred, aes(x=year))+
  geom_point(aes(y=green_share))+
  geom_point(aes(y=green_share_pred, color=''))


#Graficos----
#grafico de la produccion de electricidad total de segun las regiones de eu 
eu <- ggplot(data = df_europa, aes(x=year, y = electricity_generation, color=iso_code))+
  geom_point()+theme(legend.position = "none")+facet_wrap(~sub.region)

###BORRADOR DE TOP 5

top_5 = right_join(df_europa, df_top, by ='country')



