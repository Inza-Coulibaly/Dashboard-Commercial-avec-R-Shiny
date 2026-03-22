
install.packages(c("shiny", "shinydashboard", "ggplot2", "dplyr", "DT", "lubridate"))

# Charger les bibliothèques
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)
library(lubridate)

# 1. GÉNÉRATION DES DONNÉES COMMERCIALES (Fictives)
set.seed(123)
dates <- as.Date("2023-01-01") + sample(0:364, 500, replace = TRUE)
categories <- sample(c("Électronique", "Vêtements", "Meubles", "Alimentaire"), 500, replace = TRUE)
regions <- sample(c("Nord", "Sud", "Est", "Ouest"), 500, replace = TRUE)
ventes <- round(runif(500, 50, 1500), 2)
profit <- round(ventes * runif(500, 0.1, 0.4), 2) # Profit entre 10% et 40%

data_ventes <- data.frame(
  Date = dates,
  Mois = floor_date(dates, "month"),
  Categorie = categories,
  Region = regions,
  Ventes = ventes,
  Profit = profit
)

# 2. INTERFACE UTILISATEUR (UI)
ui <- dashboardPage(
  skin = "blue",
  
  # En-tête
  dashboardHeader(title = "Dashboard Commercial"),
  
  # Barre latérale (Filtres)
  dashboardSidebar(
    sidebarMenu(
      menuItem("Vue d'ensemble", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Données brutes", tabName = "data", icon = icon("table"))
    ),
    br(),
    h4(" Filtres", style = "margin-left: 15px; color: white;"),
    
    dateRangeInput("date_filter", "Période :", 
                   start = min(data_ventes$Date), 
                   end = max(data_ventes$Date)),
    
    selectInput("region_filter", "Région :", 
                choices = c("Toutes", unique(data_ventes$Region)), 
                selected = "Toutes"),
    
    selectInput("cat_filter", "Catégorie :", 
                choices = c("Toutes", unique(data_ventes$Categorie)), 
                selected = "Toutes")
  ),
  
  # Corps du Dashboard
  dashboardBody(
    tabItems(
      # Onglet 1: Vue d'ensemble
      tabItem(tabName = "dashboard",
              # Ligne des indicateurs clés (KPIs)
              fluidRow(
                valueBoxOutput("box_ventes", width = 4),
                valueBoxOutput("box_profit", width = 4),
                valueBoxOutput("box_commandes", width = 4)
              ),
              # Ligne des graphiques
              fluidRow(
                box(title = "Évolution des ventes (Mensuel)", status = "primary", solidHeader = TRUE, 
                    plotOutput("plot_tendance"), width = 8),
                box(title = "Ventes par Catégorie", status = "warning", solidHeader = TRUE, 
                    plotOutput("plot_categorie"), width = 4)
              ),
              fluidRow(
                box(title = "Ventes par Région", status = "success", solidHeader = TRUE,
                    plotOutput("plot_region"), width = 12)
              )
      ),
      
      # Onglet 2: Table des données
      tabItem(tabName = "data",
              box(title = "Détail des transactions", status = "info", solidHeader = TRUE, width = 12,
                  DTOutput("table_donnees"))
      )
    )
  )
)

# 3. LOGIQUE SERVEUR (Server)
server <- function(input, output) {
  
  # Création d'un dataset réactif basé sur les filtres de la sidebar
  filtered_data <- reactive({
    df <- data_ventes %>%
      filter(Date >= input$date_filter[1] & Date <= input$date_filter[2])
    
    if (input$region_filter != "Toutes") {
      df <- df %>% filter(Region == input$region_filter)
    }
    
    if (input$cat_filter != "Toutes") {
      df <- df %>% filter(Categorie == input$cat_filter)
    }
    
    return(df)
  })
  
  # KPI 1: Chiffre d'Affaires Total
  output$box_ventes <- renderValueBox({
    total_ventes <- sum(filtered_data()$Ventes)
    valueBox(
      paste0(formatC(total_ventes, format = "f", big.mark = " ", digits = 0), " €"),
      "Chiffre d'Affaires", icon = icon("credit-card"), color = "aqua"
    )
  })
  
  # KPI 2: Profit Total
  output$box_profit <- renderValueBox({
    total_profit <- sum(filtered_data()$Profit)
    valueBox(
      paste0(formatC(total_profit, format = "f", big.mark = " ", digits = 0), " €"),
      "Marge Générée", icon = icon("chart-line"), color = "green"
    )
  })
  
  # KPI 3: Nombre de commandes
  output$box_commandes <- renderValueBox({
    nb_commandes <- nrow(filtered_data())
    valueBox(
      nb_commandes,
      "Nombre de Commandes", icon = icon("shopping-cart"), color = "yellow"
    )
  })
  
  # Graphique 1 : Tendance mensuelle
  output$plot_tendance <- renderPlot({
    df_trend <- filtered_data() %>%
      group_by(Mois) %>%
      summarise(Ventes_Totales = sum(Ventes))
    
    ggplot(df_trend, aes(x = Mois, y = Ventes_Totales)) +
      geom_line(color = "#3c8dbc", size = 1.5) +
      geom_point(color = "#3c8dbc", size = 3) +
      theme_minimal() +
      labs(x = "Mois", y = "Ventes (€)") +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Graphique 2 : Répartition par Catégorie
  output$plot_categorie <- renderPlot({
    df_cat <- filtered_data() %>%
      group_by(Categorie) %>%
      summarise(Ventes = sum(Ventes))
    
    ggplot(df_cat, aes(x = reorder(Categorie, Ventes), y = Ventes, fill = Categorie)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      theme_minimal() +
      scale_fill_brewer(palette = "Set2") +
      labs(x = "", y = "Ventes (€)")
  })
  
  # Graphique 3 : Répartition par Région
  output$plot_region <- renderPlot({
    df_reg <- filtered_data() %>%
      group_by(Region) %>%
      summarise(Ventes = sum(Ventes))
    
    ggplot(df_reg, aes(x = Region, y = Ventes, fill = Region)) +
      geom_bar(stat = "identity", show.legend = FALSE, width = 0.5) +
      theme_minimal() +
      scale_fill_brewer(palette = "Pastel1") +
      labs(x = "Région", y = "Ventes (€)")
  })
  
  # Table des données avec DT
  output$table_donnees <- renderDT({
    datatable(filtered_data() %>% select(-Mois), 
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE) %>%
      formatCurrency(columns = c('Ventes', 'Profit'), currency = " €", before = FALSE)
  })
}

# 4. LANCEMENT DE L'APPLICATION
shinyApp(ui, server)
