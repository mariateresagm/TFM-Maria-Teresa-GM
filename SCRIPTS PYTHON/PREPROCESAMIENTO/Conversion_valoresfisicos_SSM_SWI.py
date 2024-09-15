# Archivo: Conversion_valoresfisicos_SSM_SWI.py
# Autora: María Teresa González Moreno
# Descripción: este script permite aplicar una máscara binaria a unos archivos raster convirtiendo los valores 0 de
# la primera en NoData en los segundos y dividir los valores de los rasters por 2. Se trata de las operaciones
# necesarias para convertir los números digitales de SSM y SWI de Sentinel-1 en valores físicos

# Importación de módulos
import arcpy
import os
from arcpy.sa import *

# Definición de rutas
rasters_originales = "ruta/a/tu/directorio/trabajo"
mascara = "ruta/a/tu/archivo_mascara/mascara.shp"
rasters_procesados = "ruta/a/tu/directorio/salida"

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
        print("No se encontraron archivos raster en el directorio especificado.")
    else:
        # Verificación de la existencia del archivo de máscara de recorte
        if not arcpy.Exists(mascara):
            print(f"No se encontró el archivo de máscara: {mascara}")
        else:
            # Verificación de existencia del directorio de salida
            if not os.path.exists(rasters_procesados):
                os.makedirs(rasters_procesados)
                print(f"Directorio de salida creado: {rasters_procesados}")
            # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
            try:
                arcpy.CheckOutExtension("Spatial")

                # Procesamiento de cada raster de la carpeta
                for raster in rasters:
                    try:
                        # Carga del raster
                        rast = arcpy.Raster(raster)
                        # Carga de la máscara
                        mask = arcpy.Raster(mascara)
                        # Conversión de valores 0 de la máscara en NoData en el ráster original
                        rast_mascara = SetNull(mask == 0, rast)
                        # División por 2 de todos los valores del raster
                        raster_dividido = rast_mascara / 2
                        # Guardado del raster
                        raster_dividido.save(os.path.join(rasters_procesados, os.path.basename(raster)))
                        print(f"Proceso completado para {raster}. El raster dividido se ha guardado en {rasters_procesados}")

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
