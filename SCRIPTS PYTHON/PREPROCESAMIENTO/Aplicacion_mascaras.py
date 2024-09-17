# Archivo: Aplicacion_mascaras.py
# Autora: María Teresa González Moreno
# Descripción: este script permite aplicar una máscara binaria a unos archivos raster convirtiendo los valores 0 de
# la primera en NoData en los segundos

# Importación de móduloss
import arcpy
from arcpy.sa import *
import os

# Definición de rutas
rasters_originales = "ruta/directorio/trabajo"
mascara = "ruta/archivo_mascara/mascara.shp"
raster_alineacion = "ruta/raster_alineacion/rasteralineacion.shp"
rasters_procesados = "ruta/directorio/salida"

# Establecimiento del entorno de trabajo
arcpy.env.workspace = rasters_originales

# Raster con cuyas celdas se quieren alinear las de los nuevos rasters
arcpy.env.snapRaster = raster_alineacion

# Definición de las coordenadas de la extensión de los rasters del entorno de trabajo
xmin = 663971.954487
ymin = 4736461.22199
xmax = 670971.954487
ymax = 4743461.22199

# Creación de objeto arcpy Extent a partir de dichas coordenadas
extent = arcpy.Extent(xmin, ymin, xmax, ymax)
# Asignación del extent al entorno de arcpy
arcpy.env.extent = extent

# Verificación de la existencia del directorio de trabajo
if not os.path.exists(rasters_originales):
    print(f"No se encontró el directorio de trabajo: {rasters_originales}")

else:
    # Creación de listado de archivos raster del directorio de trabajo
    rasters = arcpy.ListRasters()

    # Verificación de existencia de rasters para procesar
    if not rasters:
        print(f"No se encontraron archivos raster en el directorio: {rasters_originales}")
    else:
        # Verificación de la existencia del archivo de máscara
        if not arcpy.Exists(mascara):
            print(f"No se encontró el archivo de máscara: {mascara}")
        else:
            # Verificación de la existencia del archivo raster de alineación
            if not arcpy.Exists(raster_alineacion):
                print(f"No se encontró el archivo de raster de alineación: {raster_alineacion}")
            else:
                # Verificación de existencia del directorio de salida
                if not os.path.exists(rasters_procesados):
                    os.makedirs(rasters_procesados)
                    print(f"Directorio de salida creado: {rasters_procesados}")
                # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
                try:
                    arcpy.CheckOutExtension("Spatial")

                    try:
                        # Procesamiento de cada raster de la carpeta
                        for raster in rasters:
                            try:
                                # Lectura de cada archivo raster
                                raster_multibanda = arcpy.Raster(raster)
                                # Creación de lista de bandas del raster
                                bandas_procesadas = []
                                # Aplicación de la máscara en cada banda del raster
                                for i in range(1, raster_multibanda.bandCount + 1):
                                    banda = arcpy.Raster(raster_multibanda, i)
                                    # Conversión de valores 0 de la máscara en NoData en la banda del raster original
                                    banda_mascara = SetNull(Raster(mascara) == 0, banda)
                                    bandas_procesadas.append(banda_mascara)
                                # Combinación de bandas para la creación de un nuevo raster multibanda y su guardado
                                raster_salida = arcpy.CompositeBands_management(bandas_procesadas,
                                                                                os.path.join(rasters_procesados,
                                                                                             os.path.basename(raster)))
                                print(f"Máscara aplicada al archivo raster {raster}. Guardado como {raster_salida}")

                            # Manejo de errores en el procesamiento del raster
                            except arcpy.ExecuteError:
                                print(f"Error al procesar el raster: {raster}")
                                print(arcpy.GetMessages())
                            # Manejo de errores inesperados no relacionados con ArcPy
                            except Exception as e:
                                print(f"Error inesperado al procesar el raster {raster}: {e}")
                        print("Proceso completado para todos los rasters.")

                    finally:
                        # Liberación de la extensión Spatial Analyst
                        arcpy.CheckInExtension("Spatial")

                # Error relacionado con la obtención de la licencia de Spatial Analyst
                except arcpy.ExecuteError:
                    print("No se pudo obtener la extensión Spatial Analyst.")
                    print(arcpy.GetMessages())
