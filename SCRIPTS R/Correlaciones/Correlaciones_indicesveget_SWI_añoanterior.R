# Archivo: Correlaciones_indicesveget_SWI_añoanterior.R
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular correlaciones de Spearman entre
# los índices de vegetación y el Índice de Agua en Suelo (SWI) del año anterior

# Importación de la librería
library(raster)

# Directorios de archivos
dir_indices_veg <- "ruta/directorio/indicesveget"
dir_swi <- "ruta/directorio/swi"

# Listado de archivos raster de índices de vegetación y SWI
archivos_indices_veg <- list.files(dir_indices_veg, pattern = "(ndvi|ndmi|ndre)_s2_(\\d{4})_1kmmedverano\\.tif$", full.names = TRUE)
archivos_swi <- list.files(dir_swi, pattern = "SWI(002|005|010|015|020|040|060|100)minverano(\\d{4})\\.tif$", full.names = TRUE)

# Extracción de años y tipos de archivos
obtener_año_y_tipo <- function(archivos, patrón) {
  info <- sub(patrón, "\\1_\\2", basename(archivos))
  partes <- strsplit(info, "_")
  tipos <- sapply(partes, `[`, 1)
  años <- sapply(partes, `[`, 2)
  names(archivos) <- paste(tipos, años, sep = "_")
  return(archivos)
}
archivos_indices_veg <- obtener_año_y_tipo(archivos_indices_veg, "(ndvi|ndmi|ndre)_s2_(\\d{4})_1kmmedverano\\.tif$")
archivos_swi <- obtener_año_y_tipo(archivos_swi, "SWI(002|005|010|015|020|040|060|100)minverano(\\d{4})\\.tif$")

# Verificación de nombres asignados a los archivos
print("Archivos de índices de vegetación con nombres asignados:")
print(names(archivos_indices_veg))
print("Archivos SWI con nombres asignados:")
print(names(archivos_swi))

# Creación de un listado para almacenar los resultados de correlaciones
resultados_df <- data.frame(
  Año = character(),
  IndiceVegetacion = character(),
  SWI = character(),
  Correlación = numeric(),
  stringsAsFactors = FALSE
)

# Tipos de índices de vegetación y SWI
tipos_indices_veg <- c("ndvi", "ndmi", "ndre")
tipos_swi <- c("002", "005", "010", "015", "020", "040", "060", "100")

# Procesamiento de los tipos de índices de vegetación y SWI
for (tipo_veg in tipos_indices_veg) {
  # Filtrado de archivos de índice de vegetación por tipo
  archivos_indices_veg_filtrados <- archivos_indices_veg[grepl(tipo_veg, names(archivos_indices_veg))]
  años_indices_veg <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_indices_veg_filtrados)))  
  for (tipo_swi in tipos_swi) {
    # Filtrado de archivos SWI por tipo
    archivos_swi_filtrados <- archivos_swi[grepl(tipo_swi, names(archivos_swi))]
    años_swi <- unique(sub(".*_(\\d{4})$", "\\1", names(archivos_swi_filtrados)))    
    # Adición de un año a los años de SWI para buscar el año siguiente en los índices de vegetación
    años_siguientes <- as.character(as.numeric(años_swi) + 1)
    años_comunes <- intersect(años_indices_veg, años_siguientes)    
    print(paste("Años comunes para", tipo_veg, "y SWI", tipo_swi, ":", paste(años_comunes, collapse = ", ")))    
    for (año in años_comunes) {
      archivo_veg <- archivos_indices_veg_filtrados[paste(tipo_veg, año, sep = "_")]
      archivo_swi <- archivos_swi_filtrados[paste(tipo_swi, as.character(as.numeric(año) - 1), sep = "_")]      
      try({
        raster_veg <- raster(archivo_veg)
        raster_swi <- raster(archivo_swi)        
        # Verificación de dimensiones y extensión de los rasters
        if (!compareRaster(raster_veg, raster_swi, extent = TRUE, rowcol = TRUE, crs = TRUE, stopiffalse = FALSE)) {
          warning(paste("Los rásters no tienen las mismas dimensiones o extensión para el año", año, ". Saltando esta comparación."))
          next
        }        
        # Cálculo de correlación de Spearman entre rasters de índice de vegetación y SWI
        resultado_correlacion <- cor(raster_veg[], raster_swi[], method = "spearman", use = "pairwise.complete.obs")        
        # Adición de resultados al data frame
        resultados_df <- rbind(resultados_df, data.frame(
          Año = año,
          IndiceVegetacion = tipo_veg,
          SWI = tipo_swi,
          Correlación = resultado_correlacion,
          stringsAsFactors = FALSE
        ))
      }, silent = TRUE)
    }
  }
}

# Impresión de resultados de correlaciones
print("Resultados de correlación:")
print(resultados_df)

# Ruta donde guardar archivo CSV con los resultados
ruta_salida_csv <- "ruta/directorio/salida/COR_indicesveget_SWI_añoanterior.csv"

# Exportación del CSV
write.csv(resultados_df, ruta_salida_csv, row.names = FALSE)
