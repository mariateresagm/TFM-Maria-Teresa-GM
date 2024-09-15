# Archivo: Promedios_SWI.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular los promedios de cada profundidad
# de SWI (Soil Water Index) de Sentinel-1 por año

# Importación de librería
library(raster)

# Establecimiento del directorio de trabajo
directorio <- "ruta/a/tu/directorio/trabajo"

# Listado de años para los que se quieren calcular sus promedios
anos <- 2017:2023

# Listado de profundidades de SWI
profundidades_swi <- c("002", "005", "010", "015", "020", "040", "060", "100")

# Creación de un dataframe para el almacenamiento de resultados
resultados_df <- data.frame(
  Ano = integer(),
  ProfundidadSWI = character(),
  Media = numeric(),
  stringsAsFactors = FALSE
)

# Procesamiento por cada profundidad de SWI y año
for (profundidad in profundidades_swi) {
  for (ano in anos) {
    # Construcción del nombre del archivo
    nombre_raster <- sprintf("SWI%sminverano%d.tif", profundidad, ano)
    ruta_raster <- file.path(directorio, nombre_raster)
    
    # Verificación de la existencia del raster
    if (file.exists(ruta_raster)) {
      # Lectura del raster
      raster_actual <- raster(ruta_raster)
      
      # Cálculo de promedios
      media_valores <- mean(raster_actual[], na.rm = TRUE)

      # Agregación de resultados al dataframe
      resultados_df <- rbind(resultados_df, data.frame(
        Ano = ano,
        ProfundidadSWI = profundidad,
        Media = media_valores,
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
output_csv_path <- "ruta/a/tu/directorio/salida/promedios_swi.csv"

# Exportación de resultados en archivo CSV
write.csv(resultados_df, output_csv_path, row.names = FALSE)
