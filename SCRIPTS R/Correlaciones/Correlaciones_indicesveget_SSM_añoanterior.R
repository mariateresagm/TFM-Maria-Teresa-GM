# Archivo: Correlaciones_indicesveget_SSM_añoanterior.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los índices de vegetación y la Humedad Superficial del Suelo (SSM) del año anterior

# Importación de la librería
library(raster)

# Directorios de archivos
dir_indices_veget <- "ruta/directorio/indicesveget"
dir_ssm <- "ruta/directorio/ssm"

# Listado de archivos raster de índices de vegetación y SSM
archivos_indices_veget <- list.files(dir_indices_veget, pattern = "(ndvi|ndmi|ndre)_s2_(\\d{4})_1kmmedverano\\.tif$", full.names = TRUE)
archivos_ssm <- list.files(dir_ssm, pattern = "SSMminverano(\\d{4})\\.tif$", full.names = TRUE)

# Extracción de años y tipos de índices de vegetación
obtener_año_y_tipo_veget <- function(archivos, patrón) {
  info <- sub(patrón, "\\1_\\2", basename(archivos))
  partes <- strsplit(info, "_")
  tipos <- sapply(partes, `[`, 1)
  años <- sapply(partes, `[`, 2)
  names(archivos) <- paste(tipos, años, sep = "_")
  return(archivos)
}

# Extracción de años de SSM
obtener_año_ssm <- function(archivos, patrón) {
  años <- sub(patrón, "\\1", basename(archivos))
  names(archivos) <- paste("SSM", años, sep = "_")
  return(archivos)
}
archivos_indices_veget <- obtener_año_y_tipo_veget(archivos_indices_veget, "(ndvi|ndmi|ndre)_s2_(\\d{4})_1kmmedverano\\.tif$")
archivos_ssm <- obtener_año_ssm(archivos_ssm, "SSMminverano(\\d{4})\\.tif$")

# Verificación de nombres asignados a los archivos
print("Archivos de índices de vegetación con nombres asignados:")
print(names(archivos_indices_veget))
print("Archivos SSM con nombres asignados:")
print(names(archivos_ssm))

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(
  Año = character(),
  ÍndiceVeget = character(),
  SSM = character(),
  Correlación = numeric(),
  stringsAsFactors = FALSE
)

# Tipos de índices de vegetación
tipos_veget <- c("ndvi", "ndmi", "ndre")

# Procesamiento de tipos de índices de vegetación
for (tipo_veget in tipos_veget) {
  # Filtrado de archivos de índice de vegetación por tipo
  archivos_veget_filtrados <- archivos_indices_veget[grepl(tipo_veget, names(archivos_indices_veget))]
  años_veget <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_veget_filtrados)))  
  años_ssm <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_ssm)))  
  # Adición de un año a SSM para buscar el año siguiente de los índices de vegetación
  años_anterior <- as.character(as.numeric(años_ssm) + 1)
  años_comunes <- intersect(años_veget, años_anterior)  
  print(paste("Años comunes para", tipo_veget, "y SSM:", paste(años_comunes, collapse = ", ")))  
  for (año in años_comunes) {
    archivo_veget <- archivos_veget_filtrados[paste(tipo_veget, año, sep = "_")]
    archivo_ssm <- archivos_ssm[paste("SSM", as.character(as.numeric(año) - 1), sep = "_")]    
    try({
      raster_veget <- raster(archivo_veget)
      raster_ssm <- raster(archivo_ssm)      
      # Verificación de dimensiones y extensión de los rasters
      if (!compareRaster(raster_veget, raster_ssm, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
        warning(paste("Los rásters no tienen las mismas dimensiones o extensión para el año", año, ". Saltando esta comparación."))
        next
      }      
      # Cálculo de correlación de Spearman entre rasters de índice de vegetación y SSM
      resultado_correlacion <- cor(raster_veget[], raster_ssm[], method = "spearman", use = "pairwise.complete.obs")      
      # Adición de resultados al data frame
      resultados_df <- rbind(resultados_df, data.frame(
        Año = año,
        ÍndiceVeget = tipo_veget,
        SSM = "SSM",
        Correlación = resultado_correlacion,
        stringsAsFactors = FALSE
      ))
    }, silent = TRUE)
  }
}

# Impresión de resultados de correlaciones
print("Resultados de correlación:")
print(resultados_df)

# Ruta donde guardar archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_indicesveget_SSM_añoanterior.csv"

# Exportación del CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)
