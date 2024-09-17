# Archivo: Definicion_royeccion.py
# Autora: María Teresa González Moreno
# Descripción: este script permite definir la proyección de unos archivos raster a través de la herramienta de
# ArcPy "Define projection"

# Importación de módulos del sistema
import arcpy
from arcpy import env
import os

# Definición de rutas
rasters_originales = "ruta/a/tu/directorio/trabajo"

# Establecimiento del entorno de trabajo
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
        # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
        try:
            arcpy.CheckOutExtension("Spatial")

            # Procesamiento de cada raster de la carpeta
            for raster in rasters:
                try:
                    # Definición de la proyección con la herramienta "Define projection"
                    src_origen = arcpy.SpatialReference(23030)
                    arcpy.management.DefineProjection(raster, src_origen)
                    print(f"Proyección definida del archivo: {raster}")

                # Manejo de errores en el procesamiento del raster
                except arcpy.ExecuteError:
                    print(f"Error al definir la proyección para el archivo: {raster}")
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
