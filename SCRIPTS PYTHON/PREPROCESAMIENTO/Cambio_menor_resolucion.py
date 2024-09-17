# Archivo: Cambio_menor_resolucion.py
# Autora: María Teresa González Moreno
# Descripción: este script permite reducir la resolución espacial de unos archivos raster a través de la media
# mediante la herramienta de ArcPy "Aggregate"

import arcpy
from arcpy import env
from arcpy.sa import *
import os

# Definición de rutas
rasters_originales = "ruta/directorio/trabajo"
raster_alineacion = "ruta/raster_alineacion/rasteralineacion.shp"
rasters_agregados = "ruta/directorio/salida"

# Establecimiento del entorno de trabajo
env.workspace = rasters_originales

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
        print("No se encontraron archivos raster en el directorio especificado.")
    else:
        # Verificación de la existencia del archivo raster de alineación
        if not arcpy.Exists(raster_alineacion):
            print(f"No se encontró el archivo de alineación: {raster_alineacion}")
        else:
            # Verificación de existencia del directorio de salida
            if not os.path.exists(rasters_agregados):
                os.makedirs(rasters_agregados)
                print(f"Directorio de salida creado: {rasters_agregados}")
            # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
            try:
                arcpy.CheckOutExtension("Spatial")

                # Procesamiento de cada raster de la carpeta
                for raster in rasters:
                    try:
                        # Ejecución de la reducción de resolución espacial de cada raster usando la herramienta "Aggregate"
                        # En este caso, mediante la media usando 40 como factor de celda (usado para pasar de 25m a 1km)
                        agregacion = Aggregate(raster, 40, "MEAN")
                        # Definición del nombre del raster en la nueva ruta
                        guardadorasters = os.path.join(rasters_agregados, raster.replace("25m", "1km"))
                        # Guardado del raster
                        agregacion.save(guardadorasters)
                        print(f"Raster {raster} remuestreado y guardado como {guardadorasters}.")

                    # Manejo de errores en el procesamiento del raster
                    except arcpy.ExecuteError:
                        print(f"Error al procesar el raster: {raster}")
                        print(arcpy.GetMessages())
                    # Manejo de errores inesperados no relacionados con ArcPy
                    except Exception as e:
                        print(f"Error inesperado al procesar el raster {raster}: {e}")
                        print(arcpy.GetMessages())

                print("Proceso completado para todos los rasters.")

            # Error relacionado con la obtención de la licencia de Spatial Analyst
            except arcpy.ExecuteError:
                print("No se pudo obtener la extensión Spatial Analyst.")
                print(arcpy.GetMessages())
            finally:
                # Liberación de la extensión Spatial Analyst
                arcpy.CheckInExtension("Spatial")
