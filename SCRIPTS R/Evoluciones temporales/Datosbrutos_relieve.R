# Archivo: Datosbrutos_relieve.R
# Autora: María Teresa González Moreno
# Descripción: este script permite guardar los datos brutos, es decir, por 
# píxel, de las variables de relieve, utilizados para la elaboración de 
# sus diagramas de cajas y bigotes

# Importación de librería
library(raster)

# Establecimiento del directorio de trabajo
directorio <- "ruta/a/tu/directorio/trabajo"

# Listado de rasters del directorio
archivos_raster <- list.files(directorio, pattern = "\\.tif$", full.names = TRUE)

# Creación de un dataframe para el almacenamiento de los datos brutos
datos_brutos_df <- data.frame()

# Procesamiento de cada raster
for (ruta_raster in archivos_raster) {
  # Lectura del raster
  raster_actual <- raster(ruta_raster)
  
  # Verificación de existencia de datos en el raster
  if (all(is.na(raster_actual[]))) {
    cat("El archivo", basename(ruta_raster), "solo contiene valores NA.\n")
  } else {
    # Extracción de valores de cada píxel, omitiendo los "sin dato"
    valores_pixeles <- values(raster_actual)
    valores_pixeles <- valores_pixeles[!is.na(valores_pixeles)]
    
    # Creación de dataframe temporal con los valores de los píxeles
    datos_temporales_df <- data.frame(
      NombreArchivo = basename(ruta_raster),
      ValorPixel = valores_pixeles
    )
    
    # Agregación de datos temporales al dataframe principal
    datos_brutos_df <- rbind(datos_brutos_df, datos_temporales_df)
  }
}

# Impresión de parte del dataframe
print(head(datos_brutos_df))

# Ruta donde guardar archivo CSV con los datos
output_csv_path <- "ruta/a/tu/directorio/salida/datosbrutos_relieve.csv"

# Exportación de datos en archivo CSV
write.csv(datos_brutos_df, output_csv_path, row.names = FALSE)
