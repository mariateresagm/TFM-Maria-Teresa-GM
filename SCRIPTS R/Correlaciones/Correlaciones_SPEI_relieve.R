# Archivo: Correlaciones_SPEI_relieve.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los distintos SPEI y las variables de relieve

# Importación de la librería
library(raster)

# Directorios de archivos
dir_relieve <- "ruta/directorio/relieve"
dir_spei <- "ruta/directorio/spei"

# Listado de archivos raster de SPEI
patrones_spei <- c("agosto_spei3roncal_(\\d{4})\\.tif$", 
                   "agosto_spei6roncal_(\\d{4})\\.tif$", 
                   "agosto_spei12roncal_(\\d{4})\\.tif$", 
                   "agosto_spei24roncal_(\\d{4})\\.tif$", 
                   "agosto_spei36roncal_(\\d{4})\\.tif$", 
                   "agosto_spei48roncal_(\\d{4})\\.tif$")
archivos_spei <- lapply(patrones_spei, function(patron) {
  list.files(dir_spei, pattern = patron, full.names = TRUE)
})

# Extracción de los años de los nombres de los rasters y emparejamiento
obtener_año <- function(archivos, patron) {
  años <- sub(patron, "\\1", basename(archivos))
  names(archivos) <- años
  return(archivos)
}
archivos_spei <- lapply(patrones_spei, function(patron) obtener_año(list.files(dir_spei, pattern = patron, full.names = TRUE), patron))

# Carga de rasters de relieve
archivos_relieve <- list.files(dir_relieve, pattern = "\\.tif$", full.names = TRUE)
rasters_relieve <- lapply(archivos_relieve, raster)
names(rasters_relieve) <- sub("\\.tif$", "", basename(archivos_relieve))

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(
  ArchivoSPEI = character(),
  ArchivoRelieve = character(),
  Correlación = numeric(),
  stringsAsFactors = FALSE
)

# Procesamiento de SPEI y relieve
for (tipo_spei in seq_along(archivos_spei)) {
  for (archivo_spei in archivos_spei[[tipo_spei]]) {
    raster_spei <- raster(archivo_spei)    
    for (nombre_relieve in names(rasters_relieve)) {
      raster_relieve <- rasters_relieve[[nombre_relieve]]      
      # Verificación de dimensiones y extensión de los rásters
      if (!compareRaster(raster_relieve, raster_spei, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
        warning(paste("Los rásters no tienen las mismas dimensiones o extensión. Saltando esta comparación."))
        next
      }      
      # Cálculo de correlación de Spearman entre rasters de SPEI y de relieve
      resultado_correlacion <- cor(raster_relieve[], raster_spei[], method = "spearman", use = "pairwise.complete.obs")      
      # Adición de los resultados al dataframe
      resultados_df <- rbind(resultados_df, data.frame(
        ArchivoSPEI = basename(archivo_spei),
        ArchivoRelieve = nombre_relieve,
        Correlación = resultado_correlacion,
        stringsAsFactors = FALSE
      ))
    }
  }
}

# Orden del dataframe por variable de relieve y tipo de SPEI
resultados_df <- resultados_df[order(resultados_df$ArchivoRelieve, resultados_df$ArchivoSPEI), ]

# Ruta donde guardar el archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_SPEI_RELIEVE.csv"

# Exportación del CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)

# Impresión de los resultados de correlaciones
print(resultados_df)
