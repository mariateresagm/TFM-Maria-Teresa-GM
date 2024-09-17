# Archivo: Promedios_SPEI.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular el promedio de cada tipo de SPEI
# por cada año

# Importación de librería
library(raster)

# Establecimiento del directorio de trabajo
directorio <- "ruta/directorio/trabajo"

# Listado de años para los que se quieren calcular sus promedios
años <- 2017:2023

# Listado de tipos de SPEI
tipos_spei <- c("3", "6", "12", "24", "36", "48")

# Creación de un dataframe para el almacenamiento de resultados
resultados_df <- data.frame(
  Año = integer(),
  TipoSPEI = character(),
  Media = numeric(),
  stringsAsFactors = FALSE
)

# Procesamiento por tipo de SPEI y año
for (tipo in tipos_spei) {
  for (año in años) {
    # Construcción del nombre del archivo
    nombre_raster <- sprintf("agosto_spei%sroncal_%d.tif", tipo, año)
    ruta_raster <- file.path(directorio, nombre_raster)    
    # Verificación de la existencia del raster
    if (file.exists(ruta_raster)) {
      # Lectura del raster
      raster_actual <- raster(ruta_raster)      
      # Cálculo de promedios
      media_valores <- mean(raster_actual[], na.rm = TRUE)
      # Agregación de resultados al dataframe
      resultados_df <- rbind(resultados_df, data.frame(
        Año = año,
        TipoSPEI = tipo,
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
output_csv_path <- "ruta/directorio/salida/promedios_spei.csv"

# Exportación de resultados en archivo CSV
write.csv(resultados_df, output_csv_path, row.names = FALSE)
