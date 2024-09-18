# Archivo: Correlaciones_SPEI_SWI_añoanterior.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los distintos SPEI y el Índice de Agua en Suelo (SWI) del año anterior

# Importación de la librería
library(raster)

# Directorios de archivos
dir_swi <- "ruta/directorio/swi"
dir_spei <- "ruta/directorio/spei"

# Listado de archivos raster de SWI y SPEI
archivos_swi <- list.files(dir_swi, pattern = "SWI(002|005|010|015|020|040|060|100)minverano(\\d{4})\\.tif$", full.names = TRUE)
archivos_spei <- list.files(dir_spei, pattern = "agosto_spei(3|6|12|24|36|48)roncal_(\\d{4})\\.tif$", full.names = TRUE)

# Extracción de años y tipos de archivos
obtener_año_y_tipo <- function(archivos, patrón) {
  info <- sub(patrón, "\\1_\\2", basename(archivos))
  partes <- strsplit(info, "_")
  tipos <- sapply(partes, `[`, 1)
  años <- sapply(partes, `[`, 2)
  names(archivos) <- paste(tipos, años, sep = "_")
  return(archivos)
}
archivos_swi <- obtener_año_y_tipo(archivos_swi, "SWI(002|005|010|015|020|040|060|100)minverano(\\d{4})\\.tif$")
archivos_spei <- obtener_año_y_tipo(archivos_spei, "agosto_spei(3|6|12|24|36|48)roncal_(\\d{4})\\.tif$")

# Verificación de nombres asignados a los archivos
print("Archivos SWI con nombres asignados:")
print(names(archivos_swi))
print("Archivos SPEI con nombres asignados:")
print(names(archivos_spei))

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(
  Año = character(),
  SWI = character(),
  SPEI = character(),
  Correlación = numeric(),
  stringsAsFactors = FALSE
)

# Tipos de SWI y SPEI
tipos_swi <- c("002", "005", "010", "015", "020", "040", "060", "100")
tipos_spei <- c("3", "6", "12", "24", "36", "48")

# Procesamiento de tipos de SWI y SPEI
for (tipo_swi in tipos_swi) {
  # Filtrado de archivos SWI por tipo
  archivos_swi_filtrados <- archivos_swi[grepl(tipo_swi, names(archivos_swi))]
  años_swi <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_swi_filtrados)))  
  for (tipo_spei in tipos_spei) {
    # Filtrado de archivos SPEI por tipo
    archivos_spei_filtrados <- archivos_spei[grepl(tipo_spei, names(archivos_spei))]
    años_spei <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_spei_filtrados)))    
    for (año in años_spei) {
      # Cálculo del año anterior de SWI
      año_anterior <- as.character(as.numeric(año) - 1)      
      # Verificación de si existe un archivo de SWI del año anterior
      if (paste(tipo_swi, año_anterior, sep = "_") %in% names(archivos_swi_filtrados)) {
        archivo_swi <- archivos_swi_filtrados[paste(tipo_swi, año_anterior, sep = "_")]
        archivo_spei <- archivos_spei_filtrados[paste(tipo_spei, año, sep = "_")]        
        try({
          raster_swi <- raster(archivo_swi)
          raster_spei <- raster(archivo_spei)          
          # Verificación de dimensiones y extensión de los rasters
          if (!compareRaster(raster_swi, raster_spei, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
            warning(paste("Los rásters no tienen las mismas dimensiones o extensión para el año", año, ". Saltando esta comparación."))
            next
          }          
          # Cálculo de correlación de Spearman entre rasters de SWI y SPEI
          resultado_correlacion <- cor(raster_swi[], raster_spei[], method = "spearman", use = "pairwise.complete.obs")          
          # Adición de resultados al data frame
          resultados_df <- rbind(resultados_df, data.frame(
            Año = año,
            SWI = tipo_swi,
            SPEI = tipo_spei,
            Correlación = resultado_correlacion,
            stringsAsFactors = FALSE
          ))
        }, silent = TRUE)
      } else {
        warning(paste("No existe archivo de SWI para el año anterior", año_anterior, ". Saltando el año", año, "."))
      }
    }
  }
}

# Impresión de resultados de correlaciones
print("Resultados de correlación:")
print(resultados_df)

# Ruta donde guardar archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_SPEI_SWI_añoanterior.csv"

# Exportación del CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)
