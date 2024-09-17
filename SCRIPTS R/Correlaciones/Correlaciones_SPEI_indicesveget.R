# Archivo: Correlaciones_SPEI_indicesveget.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los distintos SPEI e índices de vegetación

# Importación de la librería
library(raster)

# Directorios de archivos
dir_spei <- "ruta/directorio/spei"
dir_indices_veg <- "ruta/directorio/indicesveget"

# Listado de archivos ráster de SPEI e índices de vegetación
archivos_spei <- list.files(dir_spei, pattern = "agosto_spei\\d+roncal_\\d{4}\\.tif$", full.names = TRUE)
archivos_indices_veg <- list.files(dir_indices_veg, pattern = "(ndvi|ndmi|ndre)_s2_\\d{4}_1kmmedverano\\.tif$", full.names = TRUE)

# Extracción de años y tipos de archivos
obtener_año_y_tipo <- function(archivos, patron) {
  info <- sub(patron, "\\1 \\2", basename(archivos))
  partes <- strsplit(info, " ")
  años <- sapply(partes, `[`, 2)
  tipos <- sapply(partes, `[`, 1)
  names(archivos) <- paste(tipos, años, sep = "_")
  return(archivos)
}

archivos_spei <- obtener_año_y_tipo(archivos_spei, "agosto_spei(\\d+)roncal_(\\d{4})\\.tif$")
archivos_indices_veg <- obtener_año_y_tipo(archivos_indices_veg, "(ndvi|ndmi|ndre)_s2_(\\d{4})_1kmmedverano\\.tif$")

# Verificación de nombres asignados a los archivos
print("Archivos SPEI con nombres asignados:")
print(names(archivos_spei))

print("Archivos de índices de vegetación con nombres asignados:")
print(names(archivos_indices_veg))

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(Año = character(), IndiceVeget = character(), SPEI = character(), Correlación = numeric(), stringsAsFactors = FALSE)

# Tipos de índices de vegetación y SPEI
tipos_indices_veg <- c("ndvi", "ndmi", "ndre")
tipos_spei <- c("3", "6", "12", "24", "36", "48")

# Procesamiento de tipos de índices de vegetación y SPEI
for (tipo_indice_veg in tipos_indices_veg) {
  archivos_veg_filtrados <- archivos_indices_veg[grepl(tipo_indice_veg, names(archivos_indices_veg))]
  años_veg <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_veg_filtrados)))
  
  for (tipo_spei in tipos_spei) {
    archivos_spei_filtrados <- archivos_spei[grepl(tipo_spei, names(archivos_spei))]
    años_spei <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_spei_filtrados)))
    
    años_comunes <- intersect(años_veg, años_spei)
    
    print(paste("Años comunes para", tipo_indice_veg, "y", tipo_spei, ":", paste(años_comunes, collapse = ", ")))
    
    for (año in años_comunes) {
      archivo_veg <- archivos_veg_filtrados[paste(tipo_indice_veg, año, sep = "_")]
      archivo_spei <- archivos_spei_filtrados[paste(tipo_spei, año, sep = "_")]
      
      try({
        raster_veg <- raster(archivo_veg)
        raster_spei <- raster(archivo_spei)
        
        resultado_correlacion <- cor(raster_veg[], raster_spei[], method = "spearman", use = "pairwise.complete.obs")
        
        resultados_df <- rbind(resultados_df, data.frame(Año = año, IndiceVeget = tipo_indice_veg, SPEI = tipo_spei, Correlación = resultado_correlacion, stringsAsFactors = FALSE))
      }, silent = TRUE)
    }
  }
}

# Impresión de los resultados de correlación
print("Resultados de correlación:")
print(resultados_df)

# Ruta donde guardar el archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_INDICES_SPEI.csv"

# Exportación de los resultados a un archivo CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)
