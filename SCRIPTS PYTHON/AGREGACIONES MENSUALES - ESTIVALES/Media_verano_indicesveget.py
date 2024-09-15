# Archivo: Media_verano_indicesveget.py
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular el promedio de verano (de junio a agosto, excepto 2023, julio-agosto)
# de unos índices de vegetación compuestos por 12 bandas, cada una correspondiente a un mes del año, a través de la
# herramienta de ArcPy "Estadísticas de celdas"

# Importación de módulos
import arcpy
from arcpy.sa import *
import os

# Definición de rutas
rasters_originales = "ruta/a/tu/directorio/trabajo"
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
        print(f"No se encontraron archivos raster en el directorio: {rasters_originales}")
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
                        # Lectura del número de bandas del raster
                        info_raster = arcpy.Describe(raster)
                        num_bandas = info_raster.bandCount
                        # Obtención del nombre del raster
                        nombre_entrada = os.path.basename(raster)
                        # Extracción del año del nombre del raster
                        try:
                            year = int(nombre_entrada.split('_')[2])  # Año en los nombres de archivos tras la segunda _
                        except (IndexError, ValueError):
                            print(
                                f"Error al extraer el año del raster: {nombre_entrada}. Se omitirá este raster.")
                            continue

                        # Verificación del número de bandas del raster
                        if num_bandas >= 8:
                            if year == 2023:
                                # Extracción de las bandas de julio y agosto del año 2023
                                banda_7 = arcpy.Raster(raster + "/Band_7")
                                banda_8 = arcpy.Raster(raster + "/Band_8")
                                # Cálculo del promedio de dichas bandas con la herramienta de ArcPy
                                # "Estadísticas de celdas"
                                promedio_verano = CellStatistics([banda_7, banda_8], "MEAN", "DATA")
                            else:
                                # Extracción de las bandas de junio, julio y agosto para los demás años
                                banda_6 = arcpy.Raster(raster + "/Band_6")
                                banda_7 = arcpy.Raster(raster + "/Band_7")
                                banda_8 = arcpy.Raster(raster + "/Band_8")
                                # Cálculo del promedio de dichas bandas con la herramienta de ArcPy
                                # "Estadísticas de celdas"
                                promedio_verano = CellStatistics([banda_6, banda_7, banda_8], "MEAN", "DATA")

                            # Modificación del nombre del raster de salida
                            nombre_salida = nombre_entrada.replace("roncal", "medverano")
                            # Creación de la ruta completa del raster de salida
                            ruta_salida = os.path.join(rasters_procesados, nombre_salida)
                            # Guardado del raster procesado
                            promedio_verano.save(ruta_salida)
                            print(f"Archivo procesado y guardado en: {ruta_salida}")
                        else:
                            print(f"El raster {raster} tiene menos de 8 bandas. Se omite este raster.")

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
