library(shiny)
library(randomForest)
library(dplyr)
library(shinythemes)

# Cargar el modelo
modelo_rf <- readRDS("modelo_rf.rds")

# Cargar dataset solo para extraer niveles de los factores
df <- read.csv("dataset_final_para_visual_studio_code_limpio.csv")

# Diccionario de subcategorías por categoría
subcategorias_por_categoria <- list(
  "Furniture" = c("Chairs", "Tables", "Bookcases", "Furnishings"),
  "Office Supplies" = c("Binders", "Paper", "Labels", "Storage", "Supplies", "Art"),
  "Technology" = c("Phones", "Accessories", "Machines", "Copiers")
)

# Diccionario con promedio de descuento por categoría
promedio_descuento_categoria <- c(
  "Furniture" = 0.1425221,
  "Office Supplies" = 0.1060498,
  "Technology" = 0.1091221
)

ui <- fluidPage(
  theme = shinytheme("darkly"),

  tags$style(HTML("
    body {
      font-family: 'Segoe UI', sans-serif;
    }
    .box-group {
      background-color: #3f44d1;
      padding: 20px;
      border-radius: 12px;
      margin-bottom: 25px;
    }
    .box-group h4 {
      font-size: 20px;
      font-weight: bold;
      color: #ecf0f1;
      margin-bottom: 15px;
    }
    .submit-btn {
      background-color: #6570f0;
      color: white;
      border: none;
      padding: 10px 30px;
      font-size: 16px;
      border-radius: 8px;
      margin: 20px auto;
      display: block;
    }
  ")),

  titlePanel("🔮 Predicción de Rentabilidad (%)"),

  fluidRow(
    column(12,
           
      # 🟦 Caja 1: Datos numéricos principales
div(class = "box-group",
  h4("📥 Datos de la venta"),
  fluidRow(
    column(3, 
      numericInput("Costo_envio", "Costo de envío:", 2000),
      numericInput("Cantidad", "Cantidad:", 8)
    ),
    column(3, numericInput("Descuento", "Descuento:", 0.18, min = 0, max = 1, step = 0.01)),
    column(3, numericInput("Precio_unitario", "Precio unitario:", 150)),
    column(3, numericInput("Costo_total", "Costo total:", 40000))
  )
),


      
      # 🟩 Caja 2: Clasificación
      div(class = "box-group",
        h4("🗂️ Clasificación del producto"),
        fluidRow(
          column(6, selectInput("Región", "Región:", choices = levels(as.factor(df$Región)))),
          column(6, selectInput("Categoría", "Categoría:", choices = levels(as.factor(df$Categoría))))
        ),
        fluidRow(
          column(6, selectInput("Sub_Categoría", "Sub-categoría:", choices = NULL)),
          column(6, selectInput("Prioridad", "Prioridad:", choices = levels(as.factor(df$Prioridad))))
        )
      ),
      
      # 🧠 Caja 3: Variables derivadas automáticas
      div(class = "box-group",
        h4("🔍 Variables calculadas automáticamente"),
        fluidRow(
          column(4, numericInput("Margen_vs_Precio_unitario", "Margen vs Precio unitario:", value = NA, step = 0.01)),
          column(4, numericInput("Ratio_descuento_costo", "Ratio Descuento/Costo:", value = NA, step = 0.0001)),
          column(4, numericInput("Desc_por_categoria", "Descuento promedio por categoría:", value = NA, step = 0.0001))
        )
      ),
      
      # 🔘 Botón
      actionButton("predecir", "🔎 Predecir Rentabilidad", class = "submit-btn"),
      
      # 🔮 Resultado
      uiOutput("resultado_ui")
    )
  )
)

server <- function(input, output) {
  observe({
    req(input$Precio_unitario, input$Cantidad, input$Costo_total, input$Costo_envio, input$Descuento)

    margen <- (input$Costo_total - input$Costo_envio) / (input$Precio_unitario * input$Cantidad)
    ratio <- ifelse(input$Costo_envio == 0, 0, input$Descuento / input$Costo_envio)

    updateNumericInput(inputId = "Margen_vs_Precio_unitario", value = round(margen, 4))
    updateNumericInput(inputId = "Ratio_descuento_costo", value = round(ratio, 6))
  })

  observeEvent(input$Categoría, {
    nuevas_subs <- subcategorias_por_categoria[[input$Categoría]]

    updateSelectInput(inputId = "Sub_Categoría", choices = nuevas_subs)
    updateNumericInput(
      inputId = "Desc_por_categoria",
      value = promedio_descuento_categoria[[input$Categoría]]
    )
  })

  output$resultado_ui <- renderUI({
    req(input$predecir)

    isolate({
      nuevo_dato <- data.frame(
        Costo_envio = input$Costo_envio,
        Descuento = input$Descuento,
        Precio_unitario = input$Precio_unitario,
        Costo_total = input$Costo_total,
        Cantidad = input$Cantidad,
        Región = factor(input$Región, levels = levels(as.factor(df$Región))),
        Categoría = factor(input$Categoría, levels = levels(as.factor(df$Categoría))),
        Sub_Categoría = factor(input$Sub_Categoría, levels = levels(as.factor(df$Sub_Categoría))),
        Prioridad = factor(input$Prioridad, levels = levels(as.factor(df$Prioridad))),
        Margen_vs_Precio_unitario = input$Margen_vs_Precio_unitario,
        Ratio_descuento_costo = input$Ratio_descuento_costo,
        Desc_por_categoria = input$Desc_por_categoria
      )

      pred <- predict(modelo_rf, newdata = nuevo_dato)

      tags$div(
        style = "background-color: #1b1e23; padding: 30px; border-radius: 12px; margin-top: 30px; text-align: center;",
        tags$h3("🔮 Resultado de la Predicción"),
        tags$h1(paste0(round(pred, 2), " %"),
                style = "color: #00e676; font-size: 50px; font-weight: bold;")
      )
    })
  })
}

shinyApp(ui = ui, server = server)
