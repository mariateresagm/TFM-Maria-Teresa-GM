# Archivo: Recorte_zonaestudio.py
# Autora: María Teresa González Moreno
# Descripción: este script permite recortar archivos raster usando un archivo shapefile como máscara mediante la
# herramienta de ArcPy "Extract by mask"

# Importación de módulos
import arcpy
from arcpy import env
from arcpy.sa import *
import os

# Definición de rutas
rasters_originales = "ruta/directorio/trabajo"
mascara = "ruta/archivo_mascara/mascara.shp"
rasters_recortados = "ruta/directorio/salida"

# Establecimiento del directorio de trabajo
env.workspace = rasters_originales

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
            if not os.path.exists(rasters_recortados):
                os.makedirs(rasters_recortados)
                print(f"Directorio de salida creado: {rasters_recortados}")
                
            # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
            try:
                arcpy.CheckOutExtension("Spatial")

                # Procesamiento de cada raster de la carpeta
                for raster in rasters:
                    try:
                        # Establecimiento de la ruta de los rasters procesados
                        raster_recortado = os.path.join(rasters_recortados, raster)
                        print(f"Recortando {raster}.")
                        # Ejecución del recorte de cada raster usando la herramienta "ExtractByMask"
                        outExtractByMask = ExtractByMask(raster, mascara)
                        # Guardado del raster recortado
                        outExtractByMask.save(raster_recortado)
                        print(f"Guardado como: {raster_recortado}.")

                    # Manejo de errores en el procesamiento del raster
                    except arcpy.ExecuteError:
                        print(f"Error al recortar el archivo: {raster}")
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
