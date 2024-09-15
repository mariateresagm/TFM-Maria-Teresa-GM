# Archivo: Media_mensual_SSM_SWI.py
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular la media mensual de rasters SSM/SWI de Sentinel-1, a través de la
# # herramienta de ArcPy "Estadísticas de celdas"

# Importación de módulos
import os
import arcpy
from arcpy.sa import *

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
        print("No se encontraron archivos raster en el directorio especificado.")

    else:
        # Verificación de existencia de la carpeta de salida
        if not os.path.exists(rasters_procesados):
            os.makedirs(rasters_procesados)
            print(f"Directorio de salida creado: {rasters_procesados}")

        # Verificación de disponibilidad de la extensión de ArcGIS Spatial Analyst
        try:
            arcpy.CheckOutExtension("Spatial")

            try:
                # Creación de diccionario para agrupar rasters por año y mes
                rasters_por_ano_mes = {}

                for raster in rasters:
                    # Extracción del año y mes del nombre del raster
                    nombre_raster = os.path.basename(raster)
                    ano_mes = nombre_raster.split('_')[1][:6]  # Año y mes tras _ en formato YYYYMM

                    # Agregación de cada combinación de año-mes como lista en el diccionario
                    if ano_mes not in rasters_por_ano_mes:
                        rasters_por_ano_mes[ano_mes] = []
                    rasters_por_ano_mes[ano_mes].append(raster)

                # Procesamiento de rasters por grupos año-mes
                for ano_mes, rasters_del_mes in rasters_por_ano_mes.items():
                    # Definición del nombre y la ruta del raster de salida (SSM o SWI según corresponda)
                    rutarastersmensuales = os.path.join(rasters_procesados, f'SSM{ano_mes}.tif')

                    try:
                        # Cálculo de promedio mensual con la herramienta de ArcPy "Estadísticas de celdas"
                        mediamensual = CellStatistics(rasters_del_mes, "MEAN", "DATA")
                        mediamensual.save(rutarastersmensuales)
                        print(f'Raster procesado: {rutarastersmensuales}')

                    # Manejo de errores en el procesamiento del raster
                    except arcpy.ExecuteError:
                        print(f"Error al procesar el raster: {rutarastersmensuales}")
                        print(arcpy.GetMessages())

                    # Manejo de errores inesperados no relacionados con ArcPy
                    except Exception as e:
                        print(f"Error inesperado al procesar el raster: {rutarastersmensuales}: {e}")
                        print(arcpy.GetMessages())

                print("Proceso completado para todos los rasters.")

            finally:
                # Liberación de la extensión Spatial Analyst
                arcpy.CheckInExtension("Spatial")

        # Manejo de errores relacionados con la licencia de Spatial Analyst
        except arcpy.ExecuteError:
            print("No se pudo obtener la extensión Spatial Analyst.")
            print(arcpy.GetMessages())