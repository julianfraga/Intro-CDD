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

ggplot(top_ten, aes(x=reorder(name, -goles), y=goles))+
  geom_bar(stat="Identity", width=0.6,fill='steelblue')+
  geom_text(aes(label=goles), vjust=1.6, color="white")+
  theme(axis.text.x = element_text(angle = 60, hjust=1))+
  xlab('Equipo')+ylab('Goles')+ggtitle('Goles totales durante las temporadas 2014-2020')
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

#----
#Espacio de prueba
goles<-shots%>% filter(shotResult=='Goal') %>% left_join(teamstats,by='gameID',all.x=TRUE) 
glimpse(goles)
goleadores <- players %>% left_join()
glimpse(goles_equipo)
as.data.frame(table(goles_equipo$teamID))
