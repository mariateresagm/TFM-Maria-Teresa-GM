# Archivo: Cambio_mayor_resolucion.py
# Autora: María Teresa González Moreno
# Descripción: este script permite aumentar la resolución espacial de unos archivos raster por el método del vecino
# más próximo mediante la herramienta de ArcPy "Resample"

# Importación de módulos
import arcpy
from arcpy import env
import os

# Definición de rutas
rasters_originales = "ruta/directorio/trabajo"
raster_extension = "ruta/raster_extension/rasterextension.shp"
raster_alineacion = "ruta/raster_alineacion/rasteralineacion.shp"
rasters_remuestreados = "ruta/directorio/salida"

# Establecimiento del entorno de trabajo
env.workspace = rasters_originales

# Raster cuya extensión quiere aplicarse a los nuevos rasters
arcpy.env.extent = raster_extension

# Raster con cuyas celdas se quieren alinear las de los nuevos rasters
arcpy.env.snapRaster = raster_alineacion

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
        # Verificación de la existencia del archivo de extensión
        if not arcpy.Exists(raster_extension):
            print(f"No se encontró el archivo de extensión: {raster_extension}")
        else:
            # Verificación de la existencia del archivo raster de alineación
            if not arcpy.Exists(raster_alineacion):
                print(f"No se encontró el archivo de alineación: {raster_alineacion}")
            else:
                # Verificación de existencia del directorio de salida
                if not os.path.exists(rasters_remuestreados):
                    os.makedirs(rasters_remuestreados)
                    print(f"Directorio de salida creado: {rasters_remuestreados}")
                # Comprobación de disponibilidad de la extensión de ArcGIS Spatial Analyst
                try:
                    arcpy.CheckOutExtension("Spatial")

                    # Procesamiento de cada raster de la carpeta
                    for raster in rasters:
                        try:
                            # Definición del nombre del nuevo raster en la nueva ruta
                            raster_remuestreado = os.path.join(rasters_remuestreados, raster)
                            # Ejecución del remuestreo de cada raster usando la herramienta Resample
                            remuestreo = arcpy.Resample_management(raster, raster_remuestreado, 1000, "NEAREST")
                            print(f"Raster {raster} remuestreado como {raster_remuestreado}")

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
