# Archivo: Promedios_SSM.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular el promedio de SSM (Surface Soil
# Moisture) de Sentinel-1 por año

# Importación de librería
library(raster)

# Establecimiento del directorio de trabajo
directorio <- "ruta/a/tu/directorio/trabajo"

# Listado de años para los que se quieren calcular sus promedios
anos <- 2017:2023

# Creación de un dataframe para el almacenamiento de resultados
resultados_df <- data.frame(
  Ano = integer(),
  Media = numeric(),
  stringsAsFactors = FALSE
)

# Procesamiento por cada año
for (ano in anos) {
  # Construcción del nombre del archivo
  nombre_raster <- sprintf("SSMminverano%d.tif", ano)
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
      Media = media_valores,
      stringsAsFactors = FALSE
    ))
  } else {
    cat("El archivo", nombre_raster, "no existe.\n")
  }
}

# Impresión del dataframe
print(resultados_df)

# Ruta donde guardar archivo CSV con los resultados
output_csv_path <- "ruta/a/tu/directorio/salida/promedios_ssm.csv"

# Exportación de resultados en archivo CSV
write.csv(resultados_df, output_csv_path, row.names = FALSE)
