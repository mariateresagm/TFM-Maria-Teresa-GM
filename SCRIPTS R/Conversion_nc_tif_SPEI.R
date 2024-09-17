# Archivo: Conversion_nc_tif_SPEI.R
# Autora: María Teresa González Moreno
# Fuente base: https://medium.com/@wenzhao.li1989/netcdf-to-tiff-tools-5287db171309
# Descripción: este script permite guardar como archivos .tif individuales las
# capas que componen un archivo .nc de SPEI

# Importación de librerías
library(ncdf4)
library(raster)

# Establecimiento del directorio de trabajo
setwd("ruta/directorio/trabajo")

# Listado de archivos .nc del directorio
lista_archivos <- list.files(pattern = "\\.nc$")
print(paste("Nº de archivos .nc a procesar:", length(lista_archivos)))

# Extracción de capas de un archivo .nc y guardado como .tif
nc_a_tif <- function(archivo_nc) {
  print(paste("Procesando archivo:", archivo_nc))
  # Apertura del archivo .nc como un brick (objeto multicapa)
  nc_brick <- brick(archivo_nc)
  capas <- length(names(nc_brick))  
  # Iteración sobre cada capa (con distinta fecha) del brick
  for (capax in 1:capas) {
    capa <- nc_brick[[capax]]
    fecha <- names(capa)    
    # Corrección del formato de fecha
    fecha <- gsub('X', '', fecha)
    fecha <- gsub('\\.', '', fecha)    
    # Creación de los archivos .tif (ejemplo con SPEI-3)
    nombretif <- paste0('ruta/a/tu/directorio/salida/spei3_', fecha, '.tif')
    writeRaster(capa, nombretif, bylayer=TRUE, overwrite=TRUE)
    print(paste("  - Capa", capax, "de", capas, "guardada como", nombretif))
  }
}

# Información sobre éxito o fracaso de la conversión
ocurrencia_error <- FALSE
for (archivo in lista_archivos) {
  tryCatch({
    nc_a_tif(archivo)
  }, error = function(e) {
    ocurrencia_error <<- TRUE
    print(paste("Error al procesar el archivo", archivo, ":", e$message))
  })
}
if (!ocurrencia_error) {
  print("Procesamiento finalizado.")
}
