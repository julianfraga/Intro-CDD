library(tidyverse)
library(ggridges)
library(dplyr)

appearances<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/appearances.csv',dec=",")
games<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/games.csv',dec=",")
leagues<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/leagues.csv',dec=",")
shots<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/shots.csv',dec=",")
teams<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/teams.csv',dec=",")
teamstats<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/teamstats.csv',dec=",")
players<-read.csv(file='D:/Documentos/UNSAM/Intro CDD/G4/furbo/players.csv',dec=",")

colnames(appearances)
colnames(games)
colnames(leagues)
colnames(shots)
colnames(teams)
colnames(teamstats)
colnames(players)

appearances%>% count(gameID, playerID, time) %>% filter(n>1)
shots %>% count(gameID,shooterID,positionX, positionY) %>% filter(n>1)
#no encuentro conjunto de claves primarias para shots
teamstats %>% count(gameID, teamID) %>% filter(n>1)
unique(shots$shotResult)


goles_equipo<-teamstats %>% ungroup()%>% group_by(teamID) %>% filter(goals>0) %>% left_join(teams, by="teamID")
goles_equipo<-ungroup(goles_equipo) %>% group_by(teamID)
tally<-goles_equipo %>% summarise(teamID, goles=sum(goals)) %>% unique()

teams<-left_join(teams, tally)
n<-10/nrow(teams)
top_ten<-teams[teams$goles > quantile(teams$goles,prob=1-n),]

shots_equipo<-teamstats %>% ungroup()%>% group_by(teamID) %>% filter(shots>0) %>% left_join(teams, by="teamID")
tally_shots<-shots_equipo %>% summarize(teamID, shots=sum(shots)) %>% unique()
teams<-left_join(teams, tally_shots)
top_ten<-teams[teams$shots > quantile(teams$shots,prob=1-n),]

ggplot(top_ten, aes(x=reorder(name, -goles), y=goles))+
  geom_bar(stat="Identity", width=0.6,fill='steelblue')+
  geom_text(aes(label=goles), vjust=1.6, color="white")+
  theme(axis.text.x = element_text(angle = 60, hjust=1))+
  xlab('Equipo')+ylab('Goles')+ggtitle('Goles totales durante las temporadas 2014-2020')

ggplot(top_ten, aes(x=reorder(name, -shots), y=shots))+
  geom_bar(stat="Identity", width=0.8,fill='steelblue')+
  geom_text(aes(label=shots), vjust=1.6, color="white")+
  theme(axis.text.x = element_text(angle = 60, hjust=1))+
  xlab('Equipo')+ylab('Tiros al arco')+ggtitle('Tiros al arco durante las temporadas 2014-2020')

#----
#busco tiros al arco rival por equipo
colnames(teamstats)
tiros_equipo<-teamstats %>% ungroup()%>% group_by(teamID) %>% filter(shots>0) %>% left_join(teams, by="teamID")
colnames(tiros_equipo)
tiros_equipo<-ungroup(goles_equipo) %>% group_by(teamID)
tally_tiros<-tiros_equipo %>% summarise(teamID, tiros=sum(shots)) %>% unique()

#teams<-mutate(teams, tiros=tally_tiros$tiros)
teams<- left_join(teams, tally_tiros)
top_ten<-left_join(top_ten, tally_tiros)
top_ten<- arrange(top_ten, goles)
ggplot(top_ten, aes(x=tiros, y=goles))+
  geom_point()+
  geom_text(aes(label=name),vjust=1, hjust=0.5, angle=45,color="black")+
  ylim(440,750)+
  xlab('Tiros al arco')+ylab('Goles convertidos')+ggtitle('Goles en función de los tiros al arco rival')
#----
#lo hago para todoslos equipos
teams$tiros<- as.numeric(teams$tiros)
teams$goles<- as.numeric(teams$goles)
ggplot(teams, aes(x=tiros, y=goles))+
  geom_point()+
  #geom_text(aes(label=name),vjust=1, hjust=0.5, angle=60,color="black")+
  #ylim(440,750)+
  xlab('Tiros al arco')+ylab('Goles convertidos')+ggtitle('Goles en función de los tiros al arco rival')
teams<- arrange(teams, goles)
#----- 
#liga italia serie A, niño Icardi buena vida
serie_a<-left_join(games, leagues, by='leagueID')
serie_a<-filter(serie_a, name=='Serie A')
goles_jugador<-appearances %>% ungroup()%>% group_by(playerID) %>% filter(goals>0) %>% right_join(serie_a, by="gameID")
goleadores<-goles_jugador %>% summarise(playerID, goles=sum(goals)) %>% unique() %>% left_join(players, by='playerID')

goleadores<-arrange(goleadores$goles, decreasing=TRUE)
nombres_topfive<-c('Ciro Immobile','Gonzalo Higua<ed>n','Fabio Quagliarella','Mauro Icardi','Andrea Belotti')
id_topfive<-c(1209,1230,1293,1513,1186)
topfive<-subset(goleadores, goleadores$playerID %in% id_topfive)
goles_topfive <- subset(shots, shooterID %in% id_topfive) %>% 
    filter(shotResult=='Goal') %>%
    left_join(players, by=c('shooterID'='playerID')) %>%
    group_by(name)
#MIRÁ LA VUELTA QUE TENGO QUE HACER PORQUE A R NO LE GUSTAN LOS CARACTERES ESPECIALES
goles_topfive$name[goles_topfive$shooterID==1293]<-'Gonzalo Higuain'
 
unique(goles_topfive$name)
ggplot(data = goles_topfive, aes(x=minute)) +
  geom_density_ridges(aes(y=name), alpha=0.7)+
  labs(title="Goles anotados - Serie A temporadas '14 a '20",x ="Tiempo de partido (min)", y='Jugador')

#(goles_topfive, aes(x=minute, y=factor(name)))+geom_violin(draw_quantiles = c(0.25, 0.5, 0.75))+
 # coord_flip()

metricas <-goles_topfive%>% group_by(name) %>% 
  summarise(media=mean(minute),desviacion=sd(minute), mediana=median(minute), IQR=IQR(minute))

metricas_pt <-filter(goles_topfive, minute<=45)%>% group_by(name) %>% 
  summarise(media=mean(minute),desviacion=sd(minute), mediana=median(minute), IQR=IQR(minute))
metricas_st <-filter(goles_topfive, minute>45)%>% group_by(name) %>% 
  summarise(media=mean(minute),desviacion=sd(minute), mediana=median(minute), IQR=IQR(minute))

#----
#Espacio de prueba
goles<-shots%>% filter(shotResult=='Goal') %>% left_join(teamstats,by='gameID',all.x=TRUE) 
glimpse(goles)
goleadores <- players %>% left_join()
glimpse(goles_equipo)
as.data.frame(table(goles_equipo$teamID))
