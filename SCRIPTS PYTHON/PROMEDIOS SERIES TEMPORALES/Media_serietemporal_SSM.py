# Archivo: Media_serietemporal_SSM.py
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular la media de la serie temporal completa de SSM
# con la herramienta de ArcPy "Estadísticas de celdas"

# Importación de módulos
import os
import arcpy
from arcpy.sa import *

# Definición de rutas
rasters_originales = "ruta/a/tu/directorio/trabajo"
rasters_promediados = "ruta/a/tu/directorio/salida"

# Establecimiento del entorno de trabajo
arcpy.env.workspace = rasters_originales

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
        # Verificación de la existencia del directorio de salida
        if not os.path.exists(rasters_promediados):
            os.makedirs(rasters_promediados)
            print(f"Directorio de salida creado: {rasters_promediados}")

        # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
        try:
            arcpy.CheckOutExtension("Spatial")

            try:
                # Almacenamiento de rasters SSM en una lista
                rasters_ssm = [os.path.join(arcpy.env.workspace, raster) for raster in rasters]
                if rasters_ssm:
                    print(f"Procesando {len(rasters_ssm)} rasters de SSM")
                    # Construcción de la ruta de salida del raster de media
                    ruta_raster_media = os.path.join(rasters_promediados, 'media_ssm_2017_2023.tif')
                    try:
                        # Cálculo del promedio de la serie temporal con la herramienta "Estadísticas de celdas"
                        media = CellStatistics(rasters_ssm, "MEAN", "DATA")
                        media.save(ruta_raster_media)
                        print(f'Archivo procesado: {ruta_raster_media}')

                    # Manejo de errores en el procesamiento del raster
                    except arcpy.ExecuteError:
                        print(f"Error al procesar el archivo: {ruta_raster_media}")
                        print(arcpy.GetMessages())
                    # Manejo de errores inesperados no relacionados con ArcPy
                    except Exception as e:
                        print(f"Error inesperado al procesar el archivo: {ruta_raster_media}: {e}")
                        print(arcpy.GetMessages())
                else:
                    print("No se encontraron rasters válidos para SSM.")

            finally:
                # Liberación de la extensión Spatial Analyst
                arcpy.CheckInExtension("Spatial")

        # Error relacionado con la obtención de la licencia de Spatial Analyst
        except arcpy.ExecuteError:
            print("No se pudo obtener la extensión Spatial Analyst.")
            print(arcpy.GetMessages())
