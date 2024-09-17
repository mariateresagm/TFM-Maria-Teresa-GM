# Archivo: Correlaciones_SPEI_SSM_añoanterior.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los distintos SPEI y la Humedad Superficial del Suelo (SSM)

# Importación de la librería
library(raster)

# Directorios de archivos
dir_ssm <- "ruta/directorio/ssm"
dir_spei <- "ruta/directorio/spei"

# Listado de archivos ráster de SSM y SPEI
archivos_ssm <- list.files(dir_ssm, pattern = "SSMminverano(\\d{4})\\.tif$", full.names = TRUE)
archivos_spei <- list.files(dir_spei, pattern = "agosto_spei(3|6|12|24|36|48)roncal_(\\d{4})\\.tif$", full.names = TRUE)

# Extracción de años y tipos de archivos
obtener_año_y_tipo <- function(archivos, patron, tipo = NULL) {
  info <- sub(patron, "\\1_\\2", basename(archivos))
  partes <- strsplit(info, "_")
  if (!is.null(tipo)) {
    tipos <- rep(tipo, length(archivos))
    años <- sapply(partes, `[`, 1)  # Extraer los años correctamente para SSM
  } else {
    tipos <- sapply(partes, `[`, 1)
    años <- sapply(partes, `[`, 2)
  }
  names(archivos) <- paste(tipos, años, sep = "_")
  return(archivos)
}

archivos_ssm <- obtener_año_y_tipo(archivos_ssm, "SSMminverano(\\d{4})\\.tif$", tipo = "SSM")
archivos_spei <- obtener_año_y_tipo(archivos_spei, "agosto_spei(3|6|12|24|36|48)roncal_(\\d{4})\\.tif$")

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(
  Año = character(),
  SSM = character(),
  SPEI = character(),
  Correlación = numeric(),
  stringsAsFactors = FALSE
)

# Tipos de SPEI
tipos_spei <- c("3", "6", "12", "24", "36", "48")

# Procesamiento de tipos de SPEI y SSM
for (tipo_spei in tipos_spei) {
  # Filtrado de archivos SPEI por tipo
  archivos_spei_filtrados <- archivos_spei[grepl(tipo_spei, names(archivos_spei))]
  años_spei <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_spei_filtrados)))
  
  for (año in años_spei) {
    # Cálculo del año anterior de SSM
    año_anterior <- as.character(as.numeric(año) - 1)
    
    # Verificación de la existencia de un archivo de SSM del año anterior
    if (paste("SSM", año_anterior, sep = "_") %in% names(archivos_ssm)) {
      archivo_ssm <- archivos_ssm[paste("SSM", año_anterior, sep = "_")]
      archivo_spei <- archivos_spei_filtrados[paste(tipo_spei, año, sep = "_")]
      
      try({
        raster_ssm <- raster(archivo_ssm)
        raster_spei <- raster(archivo_spei)
        
        # Verificación de dimensiones y extensión de los rásters
        if (!compareRaster(raster_ssm, raster_spei, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
          warning(paste("Los rásters no tienen las mismas dimensiones o extensión para el año", año, ". Saltando esta comparación."))
          next
        }
        
        # Cálculo de correlación de Spearman entre rásters de SSM y tipos de SPEI
        resultado_correlacion <- cor(raster_ssm[], raster_spei[], method = "spearman", use = "pairwise.complete.obs")
        
        # Adición de resultados al data frame
        resultados_df <- rbind(resultados_df, data.frame(
          Año = año,
          SSM = paste("SSM", año_anterior, sep = "_"),
          SPEI = tipo_spei,
          Correlación = resultado_correlacion,
          stringsAsFactors = FALSE
        ))
      }, silent = TRUE)
    } else {
      warning(paste("No existe archivo de SSM para el año anterior", año_anterior, ". Saltando el año", año, "."))
    }
  }
}

# Impresión de resultados de correlaciones
print("Resultados de correlación:")
print(resultados_df)

# Ruta donde guardar archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_SPEI_SSM_añoanterior.csv"

# Exportación de resultados en archivo CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)
