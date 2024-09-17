# Archivo: Media_serietemporal_SPEI.py
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular la media de la serie temporal completa de los SPEI
# con la herramienta de ArcPy "Cell statistics"

# Importación de módulos
import os
import arcpy
from arcpy.sa import *

# Definición de rutas
rasters_originales = "ruta/directorio/trabajo"
directorio_salida = "ruta/directorio/salida"

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
        if not os.path.exists(directorio_salida):
            os.makedirs(directorio_salida)
            print(f"Directorio de salida creado: {directorio_salida}")

        # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
        try:
            arcpy.CheckOutExtension("Spatial")

            try:
                # Almacenamiento de rasters por tipo de SPEI en un diccionario
                tipos_spei = {'spei3': [], 'spei6': [], 'spei12': [], 'spei24': [], 'spei36': [], 'spei48': []}

                for raster in rasters:
                    # Obtención del nombre del raster
                    nombre_raster = os.path.basename(raster).lower()
                    # Verificación del tipo de SPEI correspondiente al raster
                    for spei in tipos_spei.keys():
                        # Verificación de que spei3 no incluya spei36 (por coincidencia parcial de nombres)
                        if spei in nombre_raster:
                            if spei == 'spei3' and 'spei36' in nombre_raster:
                                continue
                            # Ruta completa del raster
                            raster_path = os.path.join(arcpy.env.workspace, raster)
                            tipos_spei[spei].append(raster_path)
                            break

                # Procesamiento de cada tipo de SPEI
                for spei, rasters in tipos_spei.items():
                    if rasters:
                        print(f"Procesando {len(rasters)} rasters del tipo {spei}")
                        # Construcción de la ruta de salida del raster de media
                        ruta_raster_media = os.path.join(directorio_salida, f'media_{spei}_2017_2023.tif')
                        try:
                            # Cálculo del promedio de la serie temporal con la herramienta "Cell statistics"
                            media = CellStatistics(rasters, "MEAN", "DATA")
                            media.save(ruta_raster_media)
                            print(f'Archivo procesado: {ruta_raster_media}')

                        # Manejo de errores en el procesamiento del raster
                        except arcpy.ExecuteError:
                            print(f"Error al procesar el archivo: {ruta_raster_media}")
                            print(arcpy.GetMessages())
                        # Manejo de errores inesperados no relacionados con ArcPy
                        except Exception as e:
                            print(f"Error inesperado al procesar el archivo {ruta_raster_media}: {e}")
                            print(arcpy.GetMessages())
                print("Proceso completado para todos los rasters.")

            finally:
                # Liberación de la extensión Spatial Analyst
                arcpy.CheckInExtension("Spatial")

        # Error relacionado con la obtención de la licencia de Spatial Analyst
        except arcpy.ExecuteError:
            print("No se pudo obtener la extensión Spatial Analyst.")
            print(arcpy.GetMessages())
