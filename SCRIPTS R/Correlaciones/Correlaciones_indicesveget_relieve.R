# Archivo: Correlaciones_indicesveget_relieve.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los índices de vegetación y las variables de relieve

# Importación de la librería
library(raster)

# Directorios de archivos
dir_relieve <- "ruta/directorio/relieve"
dir_indices <- "ruta/directorio/indicesveget"

# Listado de archivos ráster de índices
patrones_indices <- c("ndmi_s2_(\\d{4})_25mmedverano\\.tif$", 
                      "ndvi_s2_(\\d{4})_25mmedverano\\.tif$", 
                      "ndre_s2_(\\d{4})_25mmedverano\\.tif$")
archivos_indices <- lapply(patrones_indices, function(patron) {
  list.files(dir_indices, pattern = patron, full.names = TRUE)
})

# Extracción de años de los nombres de los rásters y emparejamiento
obtener_año <- function(archivos, patron) {
  años <- sub(patron, "\\1", basename(archivos))
  names(archivos) <- años
  return(archivos)
}

archivos_indices <- lapply(patrones_indices, function(patron) obtener_año(list.files(dir_indices, pattern = patron, full.names = TRUE), patron))

# Carga de rásters de relieve
archivos_relieve <- list.files(dir_relieve, pattern = "\\.tif$", full.names = TRUE)
rasters_relieve <- lapply(archivos_relieve, raster)
names(rasters_relieve) <- sub("\\.tif$", "", basename(archivos_relieve))

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(
  ArchivoIndice = character(),
  ArchivoRelieve = character(),
  Correlación = numeric(),
  stringsAsFactors = FALSE
)

# Procesamiento de índices de vegetación y relieve
for (tipo_indice in seq_along(archivos_indices)) {
  for (archivo_indice in archivos_indices[[tipo_indice]]) {
    raster_indice <- raster(archivo_indice)
    
    for (nombre_relieve in names(rasters_relieve)) {
      raster_relieve <- rasters_relieve[[nombre_relieve]]
      
      # Verificación de dimensiones y extensión de los rásters
      if (!compareRaster(raster_relieve, raster_indice, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
        warning(paste("Los rásters no tienen las mismas dimensiones o extensión."))
        next
      }
      
      # Cálculo de correlación de Spearman entre rásters de relieve e índices
      resultado_correlacion <- cor(raster_relieve[], raster_indice[], method = "spearman", use = "pairwise.complete.obs")
      
      # Adición de los resultados al dataframe
      resultados_df <- rbind(resultados_df, data.frame(
        ArchivoIndice = basename(archivo_indice),
        ArchivoRelieve = nombre_relieve,
        Correlación = resultado_correlacion,
        stringsAsFactors = FALSE
      ))
    }
  }
}

# Orden del dataframe por variable de relieve y tipo de índice
resultados_df <- resultados_df[order(resultados_df$ArchivoRelieve, resultados_df$ArchivoIndice), ]

# Ruta donde guardar el archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_INDICES_RELIEVE.csv"

# Exportación de los resultados en un archivo CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)

# Impresión de los resultados de correlaciones
print(resultados_df)
