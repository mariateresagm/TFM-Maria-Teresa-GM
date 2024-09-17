# Archivo: Estadisticas_indices_veget.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular el mínimo, el máximo y la media
# anuales de cada uno de los índices de vegetación

# Importación de librería
library(raster)

# Establecimiento del directorio de trabajo
directorio <- "ruta/directorio/trabajo"

# Listado de años para los que se quieren calcular las estadísticas
anos <- 2017:2023

# Listado de tipos de índices de vegetación
indices_veget <- c("ndvi", "ndmi", "ndre")

# Creación de un dataframe para el almacenamiento de resultados
resultados_df <- data.frame(
  Ano = integer(),
  IndiceVegetacion = character(),
  Media = numeric(),
  Minimo = numeric(),
  Maximo = numeric(),
  stringsAsFactors = FALSE
)

# Procesamiento por índice de vegetación y año
for (indice in indices_veget) {
  for (ano in anos) {
    # Construcción del nombre del archivo
    nombre_raster <- sprintf("%s_s2_%d_25mmedverano.tif", indice, ano)
    ruta_raster <- file.path(directorio, nombre_raster)    
    # Verificación de la existencia del raster
    if (file.exists(ruta_raster)) {
      # Lectura del raster
      raster_actual <- raster(ruta_raster)      
      # Cálculo de estadísticas
      media_valores <- mean(raster_actual[], na.rm = TRUE)
      minimo_valores <- min(raster_actual[], na.rm = TRUE)
      maximo_valores <- max(raster_actual[], na.rm = TRUE)      
      # Agregación de resultados al dataframe
      resultados_df <- rbind(resultados_df, data.frame(
        Ano = ano,
        IndiceVegetacion = indice,
        Media = media_valores,
        Minimo = minimo_valores,
        Maximo = maximo_valores,
        stringsAsFactors = FALSE
      ))
    } else {
      cat("El archivo", nombre_raster, "no existe.\n")
    }
  }
}

# Impresión del dataframe
print(resultados_df)

# Ruta donde guardar archivo CSV con los resultados
output_csv_path <- "ruta/directorio/salida/estadisticas_indicesveget.csv"

# Exportación de resultados en archivo CSV
write.csv(resultados_df, output_csv_path, row.names = FALSE)
