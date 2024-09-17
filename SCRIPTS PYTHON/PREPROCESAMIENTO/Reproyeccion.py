# Archivo: Reproyeccion.py
# Autora: María Teresa González Moreno
# Descripción: este script permite reproyectar unos archivos raster usando la herramienta de ArcPy
# "Project raster"

# Importación de módulos
import arcpy
from arcpy import env
import os

# Definición de rutas
rasters_originales = "ruta/directorio/trabajo"
rasters_reproyectados = "ruta/directorio/salida"

# Establecimiento del entorno de trabajo
env.workspace = rasters_originales

# Sistema de coordenadas de salida
sistcoord_salida = arcpy.SpatialReference(25830)

# Verificación de la existencia del directorio de trabajo
if not os.path.exists(rasters_originales):
    print(f"No se encontró el directorio de trabajo: {rasters_originales}")

else:
    # Creación de listado de archivos raster del directorio de trabajo
    rasters = arcpy.ListRasters()

    # Verificación de existencia de rasters
    if not rasters:
        print("No se encontraron archivos raster en el directorio especificado.")
    else:
        # Verificación de la existencia del directorio de salida
        if not os.path.exists(rasters_reproyectados):
            os.makedirs(rasters_reproyectados)
            print(f"Directorio de salida creado: {rasters_reproyectados}")
            
        # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
        try:
            arcpy.CheckOutExtension("Spatial")
            
            try:
                # Proceso de reproyección para cada raster
                for raster in rasters:
                    try:
                        # Generación de la ruta completa del raster de entrada
                        rutainicial = os.path.join(env.workspace, raster)

                        # Generación del nombre y la ruta del raster reproyectado
                        rutafinal = os.path.join(rasters_reproyectados, f'{raster}_25830.tif')

                        # Ejecución de la reproyección con la herramienta de ArcPy "Project raster"
                        arcpy.ProjectRaster_management(
                            rutainicial, rutafinal, sistcoord_salida,
                            "NEAREST", "1000",
                            "ED_1950_To_ETRS_1989_NTv2_Peninsula"
                        )
                        print(f"Reproyección completada para {raster} a 25830.")

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
