library(modelr)
library(tidyverse)
library(ggplot2)
view(diamonds)

df=diamonds
ggplot(data=df, aes(x=carat, y=price))+geom_point()

modelin<- lm(price~carat, data=df)
g<- data_grid(df, price)
g<- add_residuals(df, modelin)

ggplot(data = g)+geom_point(aes(x=carat, y=resid))

#
modelin_2<- lm(log2(price)~log2(carat), data=df)
g_2<-data_grid(df, log2(price))
g_2<- add_predictions(df, modelin_2)
ggplot(data=g_2)+geom_point(aes(x=carat, y=pred))

summary(modelin_2)      



#Tarea 4
#dependencia del precio de variables como color


diamonds %>% 
  filter(color=="D") %>% 
  ggplot(aes(x = clarity, y = price, fill = color)) +
  geom_boxplot()


#modelado

df_2 <-  diamonds %>%  
  mutate(buenaCalidad = if_else(diamonds$clarity %in% c("VS1", "VVS2", "VVS1", "IF"), T, F))
  
  
mod_price <- lm(price ~ buenaCalidad, data = df_2)

grid <- data_grid(df_2, mod_price)
