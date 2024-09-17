# Archivo: Correlaciones_indicesveget_SSM.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los índices de vegetación y la Humedad Superficial del Suelo (SSM)

# Importación de la librería
library(raster)

# Directorios de archivos
dir_ssm <- "ruta/directorio/ssm"
dir_indices_veget <- "ruta/directorio/indicesveget"

# Listado de archivos ráster de SSM e índices de vegetación
archivos_ssm <- list.files(dir_ssm, pattern = "SSMminverano(\\d{4})\\.tif$", full.names = TRUE)
archivos_indices_veget <- list.files(dir_indices_veget, pattern = "(ndvi|ndmi|ndre)_s2_(\\d{4})_1kmmedverano\\.tif$", full.names = TRUE)

# Extracción de años de SSM y asignación de nombres
obtener_años_ssm <- function(archivos) {
  años <- sub("SSMminverano(\\d{4})\\.tif$", "\\1", basename(archivos))
  names(archivos) <- paste("SSM", años, sep = "_")
  return(archivos)
}

# Extracción de años y tipos de índices de vegetación y asignación de nombres
obtener_años_indices_veget <- function(archivos) {
  tipos <- sub("_s2_\\d{4}_1kmmedverano\\.tif$", "", basename(archivos))
  años <- sub(".*_(\\d{4})_1kmmedverano\\.tif$", "\\1", basename(archivos))
  names(archivos) <- paste(tipos, años, sep = "_")
  return(archivos)
}

# Asignación de nombres a los archivos
archivos_ssm <- obtener_años_ssm(archivos_ssm)
archivos_indices_veget <- obtener_años_indices_veget(archivos_indices_veget)

# Verificación de nombres asignados a los archivos
print("Archivos SSM con nombres asignados:")
print(names(archivos_ssm))

print("Archivos de índices de vegetación con nombres asignados:")
print(names(archivos_indices_veget))

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
  
  # Extracción de años de los archivos filtrados
  años_veget <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_veget_filtrados)))
  
  print(paste("Procesando tipo de índice:", tipo_veget))
  print(paste("Años disponibles para", tipo_veget, ":", paste(años_veget, collapse = ", ")))
  
  for (año in años_veget) {
    # Obtención de archivos de índice de vegetación y SSM para el año actual
    archivo_veget <- archivos_veget_filtrados[paste(tipo_veget, año, sep = "_")]
    archivo_ssm <- archivos_ssm[paste("SSM", año, sep = "_")]
    
    if (length(archivo_veget) == 0 || length(archivo_ssm) == 0) {
      print(paste("No se encontró archivo para el año", año, "y tipo de índice", tipo_veget))
      next
    }
    
    print(paste("Comparando año:", año))
    print(paste("Archivo índice de vegetación:", archivo_veget))
    print(paste("Archivo SSM:", archivo_ssm))
    
    try({
      raster_veget <- raster(archivo_veget)
      raster_ssm <- raster(archivo_ssm)
      
      # Verificación de dimensiones y extensión de los rásters
      if (!compareRaster(raster_veget, raster_ssm, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
        warning(paste("Los rásters no tienen las mismas dimensiones o extensión para el año", año, ". Saltando esta comparación."))
        next
      }
      
      # Cálculo de correlación de Spearman entre rásters de índices de vegetación y SSM
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
ruta_salida_csv <- "ruta/directorio/salida/COR_INDICESVEGET_SSM.csv"

# Exportación de resultados en archivo CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)
