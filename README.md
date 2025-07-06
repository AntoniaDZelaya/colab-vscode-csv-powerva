# 📊 Aplicación de Predicción de Rentabilidad

Esta aplicación en R Shiny permite predecir el porcentaje de rentabilidad de una venta, utilizando un modelo de `Random Forest` previamente entrenado. El usuario ingresa los datos a través de un formulario intuitivo y agrupado en secciones, y obtiene como resultado la rentabilidad estimada.

---

## 🔧 Requisitos

Antes de ejecutar la aplicación, asegúrese de tener instalado:

- R (versión ≥ 4.2.0 recomendada)
- RStudio (opcional, pero recomendado)
- Las siguientes librerías de R:

```r
install.packages(c("shiny", "randomForest", "dplyr", "shinythemes"))
```

---

## 📁 Archivos necesarios

Asegúrese de tener en la misma carpeta de trabajo los siguientes archivos:

- `app.R` → Contiene el código de la aplicación.
- `modelo_rf.rds` → Modelo Random Forest entrenado.
- `dataset_final_para_visual_studio_code_limpio.csv` → Dataset de entrada para extraer los niveles de los factores.

---

## ▶️ Cómo ejecutar la app

1. Abrir RStudio o R.
2. Establecer el directorio de trabajo donde se encuentran los archivos:

```r
setwd("ruta/donde/guardaste/los/archivos")  # Cambia esto por tu ruta real
```

3. Ejecutar la aplicación:

```r
shiny::runApp("app.R")
```

Esto abrirá automáticamente tu navegador con la interfaz de la aplicación.

---

## 🧠 ¿Qué hace la aplicación?

- Recibe entradas del usuario como precio, cantidad, región, categoría, etc.
- Calcula automáticamente:
  - Margen vs Precio Unitario
  - Ratio Descuento/Costo
  - Descuento promedio por categoría
- Realiza la predicción con el modelo Random Forest y muestra el resultado.

---

## 🧪 Modelo

El modelo `modelo_rf.rds` fue previamente entrenado con el dataset entregado, aplicando técnicas de preprocesamiento y selección de variables. Está preparado para recibir nuevas entradas estructuradas como las del formulario.

---
