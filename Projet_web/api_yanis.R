# INSTALLATION DES PACKAGES
# install.packages(c("httr","jsonlite","shiny","dplyr"))
# library(httr)
# library(jsonlite)
# library(shiny)
# library(dplyr)


# RÉCUPÉRATION DES CODES POSTAUX 
adresses=read.csv2(file="adresses-69.csv",header=T,sep =";",dec="." )
Code_postal=sort(unique(adresses$code_postal))


# CREATION DU DATAFRAME DF QUI CONTIENDRA LES DONNÉES REQUETÉES SUR L'API
df=data.frame()

# SPÉCIFICATION DE L'URL DE L'API 
url = "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"

for (cp in Code_postal){
     base_url = url
     # Paramètres de la requête
     params = list(
       select = "N°DPE,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE,Date_établissement_DPE,Date_visite_diagnostiqueur,Modèle_DPE,Date_fin_validité_DPE,Version_DPE,N°_DPE_immeuble_associé,Type_énergie_n°2,Type_énergie_n°3,Méthode_application_DPE,Etiquette_DPE,Année_construction,Type_bâtiment,Type_installation_chauffage,Surface_habitable_logement,Adresse_(BAN),Code_postal_(BAN),Nom__rue_(BAN),Coordonnée_cartographique_X_(BAN),Coordonnée_cartographique_Y_(BAN),N°_étage_appartement,Nom_résidence,Conso_5_usages_é_finale,Conso_5_usages/m²_é_finale,Emission_GES_5_usages,Emission_GES_5_usages_par_m²,Coût_total_5_usages,Qualité_isolation_murs,Isolation_toiture_(0/1),Besoin_refroidissement,Besoin_chauffage,Type_énergie_principale_chauffage,Conso_chauffage_é_finale,Type_installation_chauffage,Type_installation_ECS,Conso_ECS_é_finale,Type_installation_solaire,Description_installation_chauffage_n°1,Description_installation_ECS,Présence_production_PV_(0/1),Production_électricité_PV_(kWhep/an),Electricité_PV_autoconsommée,Surface_totale_capteurs_photovoltaïque,Catégorie_ENR,Nom__commune_(BAN)",
       size=10000,
       q=cp,
       q_fields="Code_postal_(BAN)",
       qs="Date_réception_DPE:[2021-01-01 TO 2024-12-31]")
     
     print(paste("CP : ", cp))
     #Date_établissement_DPE, Date_visite_diagnostiqueur, Modèle_DPE, Date_fin_validité_DPE, Version_DPE, N°_DPE_immeuble_associé, Type_énergie_n°1,
     # Type_énergie_n°2, Type_énergie_n°3, Méthode_application_DPE, Etiquette_DPE, Année_construction, Type_bâtiment, Type_installation_chauffage,
     # Surface_habitable_logement, Adresse_(BAN), Code_postal_(BAN), Nom__rue_(BAN), Coordonnée_cartographique_X_(BAN), Coordonnée_cartographique_Y_(BAN),
     # N°_étage_appartement, Nom_résidence, Conso_5_usages_é_finale, Conso_5_usages/m²_é_finale, Emission_GES_5_usages, Emission_GES_5_usages_par_m²,
     # Coût_total_5_usages, Qualité_isolation_murs, Isolation_toiture_(0/1), Besoin_refroidissement, Besoin_chauffage, Type_énergie_principale_chauffage, Conso_chauffage_é_finale,
     # Type_installation_chauffage, Type_installation_ECS, Conso_ECS_é_finale, Type_installation_solaire, Description_installation_chauffage_n°1,
     # Description_installation_ECS, Présence_production_PV_(0/1), Production_électricité_PV_(kWhep/an), Electricité_PV_autoconsommée,
     # Surface_totale_capteurs_photovoltaïque, Catégorie_ENR
     
     
     # Encodage des paramètres
     url_encoded = modify_url(base_url, query = params)
     #print(url_encoded)
     
     # Effectuer la requête
     response = GET(url_encoded)
     
     # Afficher le statut de la réponse
     print(status_code(response))
     
     # On convertit le contenu brut (octets) en une chaîne de caractères (texte). Cela permet de transformer les données reçues de l'API, qui sont généralement au format JSON, en une chaîne lisible par R
     content = fromJSON(rawToChar(response$content), flatten = FALSE)
     
     # Afficher le nombre total de ligne dans la base de données
     # Affichage de la taille du data frame
     taille_requete = content$total
     print(paste("taille =", taille_requete))
     
   
     
     
     # SI LE NOMBRE DE LOGEMENTS AU SEIN D'UN CP EST >= 10 000, ON LES RÉCUPERE ANNÉE PAR ANNÉE  
     if(taille_requete >= 10000){
       
         for (annee in c("2021","2022","2023","2024")){
         
         base_url = url
         # Paramètres de la requête
         params = list(
           select = "N°DPE,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE,Date_établissement_DPE,Date_visite_diagnostiqueur,Modèle_DPE,Date_fin_validité_DPE,Version_DPE,N°_DPE_immeuble_associé,Type_énergie_n°2,Type_énergie_n°3,Méthode_application_DPE,Etiquette_DPE,Année_construction,Type_bâtiment,Type_installation_chauffage,Surface_habitable_logement,Adresse_(BAN),Code_postal_(BAN),Nom__rue_(BAN),Coordonnée_cartographique_X_(BAN),Coordonnée_cartographique_Y_(BAN),N°_étage_appartement,Nom_résidence,Conso_5_usages_é_finale,Conso_5_usages/m²_é_finale,Emission_GES_5_usages,Emission_GES_5_usages_par_m²,Coût_total_5_usages,Qualité_isolation_murs,Isolation_toiture_(0/1),Besoin_refroidissement,Besoin_chauffage,Type_énergie_principale_chauffage,Conso_chauffage_é_finale,Type_installation_chauffage,Type_installation_ECS,Conso_ECS_é_finale,Type_installation_solaire,Description_installation_chauffage_n°1,Description_installation_ECS,Présence_production_PV_(0/1),Production_électricité_PV_(kWhep/an),Electricité_PV_autoconsommée,Surface_totale_capteurs_photovoltaïque,Catégorie_ENR,Nom__commune_(BAN)",
           size=10000,
           q=cp,                                            
           q_fields="Code_postal_(BAN)",
           qs=paste("Date_réception_DPE:[",annee,"-01-01 TO ",annee,"-12-31]",sep = ""))
         
         print(paste("CP2 : ", cp))
         print(paste("Année : ", annee))
         #,Date_réception_DPE,Date_établissement_DPE,Code_postal_(BAN),Date_établissement_DPE,Date_visite,Date_visite_diagnostiqueur,Modèle_DPE,N°DPE_remplacé,Date_fin_validité_DPE,Version_DPE,N°DPE_immeuble_associé,   Méthode_application_DPE,Etiquette_DPE,Année_construction,Type_bâtiment, Type_installation_chauffage,Surface_habitable_logement,Adresse_(BAN),Code_postal_(BAN),Nom__rue_(BAN),Coordonnée_cartographique_X_(BAN), Coordonnée_cartographique_Y_(BAN)
         
         # Encodage des paramètres
         url_encoded = modify_url(base_url, query = params)
         print(url_encoded)
         
         # Effectuer la requête
         response = GET(url_encoded)
         
         # Afficher le statut de la réponse
         print(status_code(response))
         
         # On convertit le contenu brut (octets) en une chaîne de caractères (texte). Cela permet de transformer les données reçues de l'API, qui sont généralement au format JSON, en une chaîne lisible par R
         content = fromJSON(rawToChar(response$content), flatten = FALSE)
         
         # Afficher le nombre total de ligne dans la base de données
         # Affichage de la taille du data frame
         taille_requete2 = content$total
         print(paste("taille 2 = ", taille_requete2))
         
         # AJOUTE LES MINI REQUETES AU DF CONTENANT LES PRÉCÉDENTES
         print(dim(content$results))
         df = bind_rows(df,content$result)
       
         }
     } 
     else {
       print(dim(content$results))
       
       df = bind_rows(df,content$result)
       }
     
     
     
     
}
dim(df)
# Supprimer les doublons
df=distinct(df)
  
# Afficher les données récupérées
paste("lignes : ",dim(df)[1],"colonnes : ",dim(df)[2])
View(df)
  
write.csv(df, file = "df.csv", row.names = FALSE)
