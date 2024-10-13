# INSTALLATION DES PACKAGES
#install.packages(c("shiny","dplyr","ggplot2","plotly","lubridate","sf","leaflet","DT","shinydashboard","scales","fontawesome","shinythemes","shinyjs","rsconnect","curl"))
library(readr)
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(bslib)
library(lubridate)
library(leaflet)
library(sf)
library(DT)
library(shinydashboard)  
library(scales)
library(fontawesome)
library(shinythemes)
library(shinyjs)
library(rsconnect)
library(curl)
library(tibble)
library(shinyauthr)


options(repos = c(CRAN = "https://cran.rstudio.com"))

my_dir = "C:/Users/delbo/OneDrive/Documents/PROJET SHINY"

setwd(my_dir)


# Vérifie si le DataFrame est déja dans l'environnement, si il ne l'est pas, on le charge
if (!is.data.frame(df)) { 
  df <- read_csv("new_df.csv") 
}
   
# Liste des utilisateurs autorisés à accéder à l'app

user_base <- tibble::tibble(
  user = c("Monsieur svp", "user2"),
  password = c("mettez une bonne note", "pass2"),
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)



# INTERFACE UTILISATEUR
ui <- # INTERFACE UTILISATEUR
  ui <- fluidPage(  
    # add logout button UI
    div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
    # add login panel UI function
    shinyauthr::loginUI(id = "login"),
    # setup table output to show user info after login
    tableOutput("user_table"),
    
    
    div(
      id = "show-page-content",
      dashboardPage(
  
  # En-tête 
  dashboardHeader(
    # Ajouter Logo ENEDIS sur l'en-tête
    title = tags$div(
      tags$img(src = "https://www.soignolles14.fr/wp-content/uploads/2019/03/Logo-ENEDIS.png", height = "75px"),
                    )
   ),
  
  
  # Menu des onglets
  dashboardSidebar(
    sidebarMenu(
      
      # Onglet 1
      menuItem(
        "Étiquettes DPE", 
        tabName = "etiquettes_dpe",
        icon = icon("chart-bar")  

      ),
      
      # Onglet 2
      menuItem("Variables explicatives", 
               tabName = "var_explicatives",
               icon = icon("lightbulb")
               ),
      
      # Onglet 3
      menuItem("Carte ", 
               tabName = "carte_dpe",
               icon = icon("map")
               ),
      
      # Onglet 4
      menuItem("Contexte",
               tabName = "contexte",
               icon = icon("file-alt") 
               )                   
    )
  ),
  
  
  # Corps du dashboard
  dashboardBody(
    # Utiliser le style contenu dans le fichier css (ne fonctionne pas)
    # tags$head(
    #   tags$link(rel = "stylesheet", href ="www/style.css"
    #            )
    # ),
    
    # Page 1
    tabItems(
      tabItem(tabName = "etiquettes_dpe",
              fluidRow(
                box(width = 3,
                    selectInput("theme_choice", "Choisissez un thème :", 
                                choices = c("Default", "Cyborg", "Flatly", "Darkly", "Minty")
                                ),
                    actionButton("refresh_btn", "Rafraîchir les données"),br(),br(),  #interroge l'API pour cécupérer les données les plus récentes
                    
                    uiOutput("themed_ui"),  # On applique le thème choisi par l'utilisateur
                    box(width = 12,
                    h3("Filtres : "),
                    sliderInput("plage_annee", "Année(s) :", min = 2021, max = 2024, value = c(2021, 2024), sep = ""),br(), # L'utilisateur choisi une plage entre deux années
                    selectInput("commune", "Commune(s) :", choices = c("Toutes", unique(df$`Nom__commune_(BAN)`))) # L'utilisateur choisi une commune spécifique (ou non)
                      )
                ),
                
                
                box(
                  width = 9,
                  plotlyOutput("etiquette_dpe"),  # Graphique des étiquettes DPE
                  downloadButton("download_etiquette_dpe", "Exporter Graphique (.png)")  # Bouton pour télécharger le graphique
                )
              ),
              
              fluidRow(
                box(
                  width = 4,
                  selectInput("choix_etiquette", h3("Étiquette :"), choices = c("A", "B", "C", "D", "E", "F", "G")),
                  tags$hr(),
                  box(
                    width = 12,
                    tags$div(
                      style = "font-size: 40px;display: flex; align-items: center; color:green",  # Mise en forme de ce qui est contenu dans " tags$div "
                      icon("arrow-up"),                                                           # Icone d'une flèche qui pointe vers le haut
                      tags$h3(textOutput("kpi_evo_eti")),br(),br(),                               # Affichage dynamique de l'indicateur d'évolution d'étiquette DPE
                      tags$img(src="https://cdn-icons-png.flaticon.com/256/3563/3563393.png", height="100px") # Image compteur DPE à coté du précédent indicateur
                    )
                  ),br(),br(),br(),br(),br()  
                ),
                
                box(
                  width = 8,
                  plotlyOutput("evolution_DPE"),  # Graphique du nombre de nouveaux logements DPE par mois
                  downloadButton("download_evolution_DPE", "Exporter Graphique (.png)"),
                ),

              )
              

              

              
      ),
      
      # Page 2
      tabItem(tabName = "var_explicatives",   
              fluidRow(
                box(width = 12,
                    plotlyOutput("diag_type_energie"),  # Graphique des types d'énergie par étiquette DPE
                    downloadButton("download_diag_type_energie", "Exporter Graphique (.png)")
                )
              ),
              
              fluidRow(
                box(width = 12,
                    plotlyOutput("diag_empile_100_murs"),  # Diagramme empilé 100% de la qualité d'isolation
                    downloadButton("download_diag_empile_100_murs", "Exporter Graphique (.png)")
                )
              ),
              
              fluidRow(
                box(width = 12, title = "Calculez la corrélation de votre choix",
                    selectInput("variable1", "Variable n°1 :", choices = c("Besoin_refroidissement","Conso_ECS_é_finale","Conso_5_usages_é_finale","Surface_habitable_logement","Emission_GES_5_usages","Conso_chauffage_é_finale","Production_électricité_PV_(kWhep/an)","Besoin_chauffage","Conso_5_usages/m²_é_finale","Coût_total_5_usages","Emission_GES_5_usages_par_m²","Surface_totale_capteurs_photovoltaïque")),
                    selectInput("variable2", "Variable n°2 :", choices = c("Besoin_refroidissement","Conso_ECS_é_finale","Conso_5_usages_é_finale","Surface_habitable_logement","Emission_GES_5_usages","Conso_chauffage_é_finale","Production_électricité_PV_(kWhep/an)","Besoin_chauffage","Conso_5_usages/m²_é_finale","Coût_total_5_usages","Emission_GES_5_usages_par_m²","Surface_totale_capteurs_photovoltaïque"))
                )
              ),
              fluidRow(
                box(width = 12,
                    tags$div(
                        style = "color : blue",
                        h2(textOutput("coeff_cor"))
                          ),
                    plotlyOutput("nuage"),
                    downloadButton("download_nuage", "Exporter Graphique (.png)")
                )
              )
      ),
      
      # Page 3
      tabItem(tabName = "carte_dpe",
              fluidRow(
                box(width = 12, title = h3("Localisation des logements du Rhône selon leur étiquette DPE"), 
                    leafletOutput("carte")  # Graphique de la qualité d'isolation
                )
              )
      ),
      # Page 4
      tabItem(tabName = "contexte",
              fluidRow(
                box(width = 12, title = h3("Données provenant de l'Agence de la transition écologique et répertoriées depuis Juillet 2021"),
                    DTOutput("tableau"),
                    downloadButton("download_data", "Exporter Données (.csv)")  # Bouton pour exporter les données
                )
              )
      )
    )
  )
)
) %>% shinyjs::hidden()
)
  
  # BACK END
  server <- function(input, output, session) {
    
    shiny::observe({  
      shiny::req(credentials()$user_auth)
      shinyjs::show(id = "show-page-content")
    })
    
    
    # call login module supplying data frame, 
    # user and password cols and reactive trigger
    credentials <- shinyauthr::loginServer(
      id = "login",
      data = user_base,
      user_col = user,
      pwd_col = password,
      log_out = reactive(logout_init())
    )
    
    # call the logout module with reactive trigger to hide/show
    logout_init <- shinyauthr::logoutServer(
      id = "logout",
      active = reactive(credentials()$user_auth)
    )
    
    output$user_table <- renderTable({
      # use req to only render results when credentials()$user_auth is TRUE
      req(credentials()$user_auth)
      credentials()$info
    })
    
    

    
    
    
    # Création du graphique étiquette DPE selon l'année et d'autres critères  
    output$etiquette_dpe <- renderPlotly({
      
      filtered_data <- df %>%
        dplyr::filter(
          (as.numeric(format(as.Date(Date_réception_DPE), "%Y")) >= input$plage_annee[1] & 
             as.numeric(format(as.Date(Date_réception_DPE), "%Y")) <= input$plage_annee[2]) &
            (input$commune == "Toutes" | `Nom__commune_(BAN)` == input$commune)
        )
      
      
      etiquette_counts <- as.data.frame(table(filtered_data$Etiquette_DPE))    # Tableau de fréquence des étiquettes DPE dans les données filtrées
      
      # Renommez les colonnes pour ggplot
      colnames(etiquette_counts) <- c("Etiquette_DPE", "Nombre")
      
      # Création du graphique avec ggplot2
      p <- ggplot(etiquette_counts, aes(x = Etiquette_DPE, y = Nombre, fill = Etiquette_DPE)) +
        geom_bar(stat = "identity", show.legend = FALSE) +   # Utilise les valeurs de fréquence directement pour la hauteur des barres
        scale_fill_manual(values = c("#3ABEF9", "#36A0E9", "#3382DA", "#2F65CA", "#2C47BB", "#2829AB","#250C9C")) +   # On spécifie manuellement les couleurs car sinon palette renvoie des couleurs trop claires
        theme_minimal() +   # Personnalise l'apparence du graphique (titres, axes, grilles)
        labs(title = "Distribution des logements par Étiquettes DPE",
             y = "Effectif",
             x = "Étiquette DPE") +
        theme(
          legend.position = "none",    # Pas de légende
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          axis.title = element_text(size = 12),
          panel.grid.major = element_blank(),  # Supprime la grille majeure
          panel.grid.minor = element_blank()   # Supprime la grille mineure
        ) 
      
      # Convertir le graphique ggplot en graphique interactif
      ggplotly(p, tooltip = "Nombre")   
    })
    
    
   
    
    output$evolution_DPE <- renderPlotly({
      
      filtered_data <- df %>%
        dplyr::filter(
          (as.numeric(format(as.Date(Date_réception_DPE), "%Y")) >= input$plage_annee[1] & 
             as.numeric(format(as.Date(Date_réception_DPE), "%Y")) <= input$plage_annee[2]) &
            (input$commune == "Toutes" | `Nom__commune_(BAN)` == input$commune) &
            (input$choix_etiquette == Etiquette_DPE)   
        )
      
      
      
      # Transformation des données
      a = table(filtered_data$Date_réception_DPE,filtered_data$Etiquette_DPE)
      data = as.data.frame(a)[, c("Var1", "Freq")]
      colnames(data) = c("Date", "Effectif")
      data$Date = as.Date(data$Date)
      
      # Calcul des effectifs mensuels
      data_monthly = data %>%
        mutate(Mois = floor_date(Date, "month")) %>%
        group_by(Mois) %>%
        summarize(Effectif = sum(Effectif)) %>%
        ungroup()
      
      # Ajout d'une colonne avec le format Mois/Année
      data_monthly$Mois_Annee = format(data_monthly$Mois, "%B %Y")
      
      # Création du graphique avec ggplot2
      p = ggplot(data = data_monthly, aes(x = Mois, y = Effectif)) +
        geom_line(size = 1.2, color = "#3FA2F6") +  # Ligne de la courbe
        geom_point(size = 2, color = "#008DDA") +  # Points
        labs(title = paste("Nombre de nouveaux logements notés",input$choix_etiquette,"par mois"), 
             x = "Date", 
             y = "Effectif") +
        theme_minimal() +  # Choisir un thème minimaliste
        theme(
          panel.grid.major = element_blank(),  # Enlever les grilles majeures
          panel.grid.minor = element_blank(),  # Enlever les grilles mineures
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold")  # Centrer le titre
        )
      
      # Convertir le graphique ggplot en graphique interactif
      ggplotly(p, tooltip = c("Mois","Effectif"))
    })
  
  
  
  
  
  
    output$kpi_evo_eti <- renderText({
      
      filtered_data <- df %>%
        dplyr::filter(
          (as.numeric(format(as.Date(Date_réception_DPE), "%Y")) >= input$plage_annee[1] & 
             as.numeric(format(as.Date(Date_réception_DPE), "%Y")) <= input$plage_annee[2]) & 
            ( input$choix_etiquette == Etiquette_DPE)   
        )
      
      a = table(filtered_data$Date_réception_DPE,filtered_data$Etiquette_DPE)
      data = as.data.frame(a)[, c("Var1", "Freq")]
      colnames(data) = c("Date", "Effectif")
      data$Date = as.Date(data$Date)
      
      # Calcul des effectifs mensuels
      data_monthly = data %>%
        mutate(Mois = floor_date(Date, "month")) %>%
        group_by(Mois) %>%
        summarize(Effectif = sum(Effectif)) %>%
        ungroup()
      
      # Ajout d'une colonne avec le format Mois/Année
      data_monthly$Mois_Annee = format(data_monthly$Mois, "%B %Y")
      total = sum(data_monthly$Effectif)
      total = format(total, big.mark = " ", scientific = FALSE)  # Séparateur de milliers

      
      paste(total," nouveaux logements notés ",input$choix_etiquette)
    })
    
    
  
    output$diag_type_energie<- renderPlotly({
      
      diag_type_energie = data.frame(Etiquette_DPE = df$Etiquette_DPE,
                                 Type_energie = df$`Type_énergie_n°2`) %>%   # Création du df  count(Etiquette_DPE, Type_energie, name = "Effectif")
        na.omit() %>%
        count(Etiquette_DPE, Type_energie, name = "Effectif") %>%
        group_by(Etiquette_DPE) %>%         # Regroupement par Etiquette_DPE
        slice_max(order_by = Effectif, n = 3, with_ties = FALSE) %>%  # Garde les 3 lignes avec le plus d'occurrences par groupe
        mutate(Type_energie = factor(Type_energie, levels = rev(unique(Type_energie)))) %>%   # Permet de trier par order decroissant l'apparition des remplissages dans le diagramme empilé 100%
        ungroup() %>%
        
        group_by(Etiquette_DPE) %>%
        mutate(Total = sum(Effectif),
               Proportion = round(Effectif / Total * 100, 0),  # Arrondir à 0 décimal
               Proportion_text = paste(Proportion, " %", sep = "")) %>%  # Ajouter le symbole % dans les remplissages des barres du diagremme
        ungroup()
      
      
      p = ggplot(diag_type_energie, aes(x = Etiquette_DPE, y = Effectif, fill = Type_energie)) +  #la variable Etiquette_DPE sera utilisée pour remplir les éléments du graphique. Cela signifie que chaque étiquette DPE ("A", "B", "C", etc.) aura une couleur distincte.
        geom_bar(stat = "identity", position = "fill") +  # "fill" pour un empilage à 100%
        geom_text(aes(label = Proportion_text), 
                  position = position_fill(vjust = 0.5),  # Positionne le texte au milieu de chaque segment
                  color = "white",  # Couleur du texte
                  size = 4) +  # Taille du texte
        
        scale_fill_manual(values = c("#3ABEF9", "#3572EF", "#250C9C")) +   # On spécifie manuellement les couleurs car sinon palette renvoie des couleurs trop claires
        scale_y_continuous(labels = scales::percent) +    # Convertir l'axe Y en pourcentage
        labs(
          title = "Répartition des Type d'energie utilisées par étiquette DPE",
          x = "Etiquette DPE",
          y = "Proportion (%)",
          fill = "Type d'énergie"
        ) +
        theme_minimal()+
        
        theme(legend.spacing.y = unit(0.5 ,"cm"),
              plot.title = element_text(size = 15, face = "bold"),
              panel.grid.major = element_blank(),  # Enlever les grilles majeures
              panel.grid.minor = element_blank(),  # Enlever les grilles mineures  # espace les éléments de la légende
        )
      ggplotly(p, tooltip = c("Type_energie"))
      
    })
  
    
    
    
    output$diag_empile_100_murs <- renderPlotly({
      
      df_iso_murs = data.frame(Etiquette_DPE = df$Etiquette_DPE,
                               Qualite_iso_murs = as.factor(df$Qualité_isolation_murs)) %>%   # Création du df  count(Etiquette_DPE, Qualité_isolation_murs, name = "Effectif")
        na.omit() %>%
        count(Etiquette_DPE, Qualite_iso_murs, name = "Effectif") %>%
        group_by(Etiquette_DPE) %>%         # Regroupement par Etiquette_DPE
        mutate(Qualite_iso_murs = factor(Qualite_iso_murs, levels = c("insuffisante", "moyenne", "bonne" ,"très bonne"))) %>%   # Permet de trier par order decroissant l'apparition des remplissages dans le diagramme empilé 100%
        ungroup() %>%
        
        group_by(Etiquette_DPE) %>%
        mutate(Total = sum(Effectif),
               Proportion = round(Effectif / Total * 100, 0),  # Arrondir à 0 décimal
               Proportion_text = paste(Proportion, " %", sep = "")) %>%  # Ajouter le symbole % dans les remplissages des barres du diagremme
        ungroup()
      
      
      p = ggplot(df_iso_murs, aes(x = Etiquette_DPE, y = Effectif, fill = Qualite_iso_murs)) +  #la variable Etiquette_DPE sera utilisée pour remplir les éléments du graphique. Cela signifie que chaque étiquette DPE ("A", "B", "C", etc.) aura une couleur distincte.
        geom_bar(stat = "identity", position = "fill") +  # "fill" pour un empilage à 100%
        geom_text(aes(label = Proportion_text), 
                  position = position_fill(vjust = 0.5),  # Positionne le texte au milieu de chaque segment
                  color = "white",  # Couleur du texte
                  size = 3) +  # Taille du texte
        
        scale_fill_manual(values = c( "#A7E6FF", "#3ABEF9", "#3572EF", "#250C9C")) +   # On spécifie manuellement les couleurs car sinon palette renvoie des couleurs trop claires
        
        scale_y_continuous(labels = scales::percent) +    # Convertir l'axe Y en pourcentage
        labs(
          title = "Répartition de la qualité d'isolation des murs par étiquette DPE",
          x = "Etiquette DPE",
          y = "Proportion (%)",
          fill = "Qualité d'isolation"
        ) +
        theme_minimal()+
        
        theme(legend.spacing.y = unit(0.5 ,"cm"),
              plot.title = element_text(size = 15, face = "bold"),
              panel.grid.major = element_blank(),  # Enlever les grilles majeures
              panel.grid.minor = element_blank(),  # Enlever les grilles mineures  # espace les éléments de la légende
        )
      ggplotly(p, tooltip = c("Qualite_iso_murs"))
      
      
    })
    
    
    
    output$coeff_cor <- renderText({
      paste("Coefficent de corrélation : ",round(cor(df[[input$variable1]], df[[input$variable2]], use = "complete.obs"),2)
        
           )
    })
    
    
    
    output$nuage <- renderPlotly({
       
       var1 = input$variable1
       var2 = input$variable2
       

       
       # Création du nuage de points
       ggplot(subset(df,Date_réception_DPE >= as.Date("2024-05-01")), aes_string(x = var1, y = var2)) +  # Spécifiez les variables x et y
         geom_point(color = "blue", size = 2) +  # Ajoutez les points
         geom_smooth(method = "lm", se = FALSE, color = "#3ABEF9")+
         labs(title = paste("Corrélation entre ",var1," et ",var2),
              x = var1,
              y = var2) +  # Titres des axes et du graphique
         theme_minimal() + # Utilisez un thème minimal
         scale_x_continuous(labels = number_format(accuracy = 1)) +  # Enlever l'écriture scientifique sur l'axe X
         scale_y_continuous(labels = number_format(accuracy = 1))   # Enlever l'écriture scientifique sur l'axe Y
     })
    
    output$carte <- output$carte <- renderLeaflet({
      df_carte = df[, c("Coordonnée_cartographique_X_(BAN)", "Coordonnée_cartographique_Y_(BAN)","Etiquette_DPE")]
      
      
      year(df$Date_réception_DPE)
      
      df_carte <- df_carte %>%
        mutate(couleur = case_when(
          Etiquette_DPE == "A" ~ "#004D00",
          Etiquette_DPE == "B" ~ "#1A7E1A",
          Etiquette_DPE == "C" ~ "#4CAF50",
          Etiquette_DPE == "D" ~ "#FFD54F",
          Etiquette_DPE == "E" ~ "#FF9800",
          Etiquette_DPE == "F" ~ "#FF5722",
          Etiquette_DPE == "G" ~ "#B71C1C"
        ))
      
      
      # Transformer le dataframe en un objet sf
      df_sf <- st_as_sf(df_carte, coords = c("Coordonnée_cartographique_X_(BAN)", "Coordonnée_cartographique_Y_(BAN)"), crs = 2154)  # EPSG:2154 est le code pour Lambert 93
      
      # Reprojeter les coordonnées en WGS84 (latitude/longitude)
      df_sf_wgs84 <- st_transform(df_sf, crs = 4326)
      
      # Extraire les coordonnées transformées en latitude et longitude
      df_carte$longitude <- st_coordinates(df_sf_wgs84)[,1]  # Longitude
      df_carte$latitude <- st_coordinates(df_sf_wgs84)[,2]   # Latitude
      
      
      
      
      
      # Afficher la carte avec les coordonnées en WGS84
      Carte <- leaflet(df_carte) %>% 
        addTiles() %>% 
        addCircleMarkers(
          lng = ~longitude,
          lat = ~latitude,
          clusterOptions = markerClusterOptions(
            maxClusterRadius = 100,  # Limite à 100 pixels pour le clustering
            spiderfyOnMaxZoom = TRUE,  # Active le spiderfy quand on est au maximum du zoom
            animate = TRUE,
            disableClusteringAtZoom = 15   # Désactive le clustering a un niveau de zoom
          ),  
          
          
          color = ~couleur,  
          radius = 8,  # Taille du marqueur
          stroke = FALSE,  # Ne pas afficher la bordure
          fillOpacity = 1,  # Opacité du remplissage
          label = ~Etiquette_DPE  # Afficher l'étiquette DPE sur le marqueur
        ) %>%
        
        addLegend(
          position = "bottomright",  # Position de la légende
          colors = c("#004D00", "#1A7E1A", "#4CAF50", "#FFD54F", "#FF9800", "#FF5722", "#B71C1C"),  # Couleurs des marques
          labels = c("A", "B","C","D","E","F","G")  # Labels correspondants
        )  %>%
        
        
        setView(4.85, 45.85, 9) 
      
    })
    
    
    
    
    output$tableau <- renderDT({
      datatable(
        df,  # Exemple de jeu de données, remplacez par vos données
        options = list(
          scrollX = TRUE,       # Activer le défilement horizontal
          autoWidth = TRUE,     # Ajuster automatiquement la largeur des colonnes
          pageLength = 9,      # Nombre de lignes à afficher par page
          dom = 't<"bottom"lp>' # Positionnement de la pagination
        ),
        class = 'display'       # Utilisation d'une classe CSS standard
      )
    })
    
    # Exporter les graphiques en PNG
    output$download_etiquette_dpe <- downloadHandler(
      filename = function() { paste("etiquette_dpe_", Sys.Date(), ".png", sep = "") },
      content = function(file) {
        p <- ggplotly(output$etiquette_dpe())  # Récupérer le graphique ggplot
        saveWidget(p, file, selfcontained = TRUE)  # Sauvegarder en tant que fichier HTML
        webshot::webshot(file, file = file, vwidth = 800, vheight = 600)  # Convertir en PNG
      }
    )
    
    output$download_evolution_DPE <- downloadHandler(
      filename = function() { paste("evolution_DPE_", Sys.Date(), ".png", sep = "") },
      content = function(file) {
        p <- ggplotly(output$evolution_DPE())  # Récupérer le graphique ggplot
        saveWidget(p, file, selfcontained = TRUE)  # Sauvegarder en tant que fichier HTML
        webshot::webshot(file, file = file, vwidth = 800, vheight = 600)  # Convertir en PNG
      }
    )
    
    output$download_diag_type_energie <- downloadHandler(
      filename = function() { paste("diag_type_energie_", Sys.Date(), ".png", sep = "") },
      content = function(file) {
        p <- ggplotly(output$diag_type_energie())  # Récupérer le graphique ggplot
        saveWidget(p, file, selfcontained = TRUE)  # Sauvegarder en tant que fichier HTML
        webshot::webshot(file, file = file, vwidth = 800, vheight = 600)  # Convertir en PNG
      }
    )
    
    output$download_diag_empile_100_murs <- downloadHandler(
      filename = function() { paste("diag_empile_100_murs_", Sys.Date(), ".png", sep = "") },
      content = function(file) {
        p <- ggplotly(output$diag_empile_100_murs())  # Récupérer le graphique ggplot
        saveWidget(p, file, selfcontained = TRUE)  # Sauvegarder en tant que fichier HTML
        webshot::webshot(file, file = file, vwidth = 800, vheight = 600)  # Convertir en PNG
      }
    )
    
    output$download_nuage <- downloadHandler(
      filename = function() { paste("nuage_", Sys.Date(), ".png", sep = "") },
      content = function(file) {
        p <- ggplotly(output$nuage())  # Récupérer le graphique ggplot
        saveWidget(p, file, selfcontained = TRUE)  # Sauvegarder en tant que fichier HTML
        webshot::webshot(file, file = file, vwidth = 800, vheight = 600)  # Convertir en PNG
      }
    )
    
    # Exporter les données sélectionnées au format CSV
    output$download_data <- downloadHandler(
      filename = function() { paste("data_export_", Sys.Date(), ".csv", sep = "") },
      content = function(file) {
        write.csv(df, file, row.names = FALSE)  # Exporter le dataframe df
      }
    )
    
    output$tableau <- renderDT({
      datatable(df)  # Affichage des données
    })


      }
  # Run the application 
  shinyApp(ui = ui, server = server)