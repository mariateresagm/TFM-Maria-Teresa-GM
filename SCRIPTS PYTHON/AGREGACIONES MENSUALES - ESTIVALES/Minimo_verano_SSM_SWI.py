# Archivo: Minimo_verano_SSM_SWI.py
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular el mínimo de verano (de junio a agosto, excepto 2023, julio-agosto)
# de los productos Surface Soil Moisture (SSM) y Soil Water Index (SWI) de Sentinel-1,  a través de la
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
    rasters_mensuales = arcpy.ListRasters()

    # Verificación de existencia de rasters para procesar
    if not rasters_mensuales:
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
                # Creación de diccionario para agrupación de rasters por año
                ano_rasters = {}

                # Definición del año y mes de cada raster
                for raster in rasters_mensuales:
                    try:
                        # Extracción del nombre del archivo
                        nombre_raster = os.path.basename(raster)
                        # Extracción de año y mes del nombre del raster
                        ano = nombre_raster[3:7]  # Caracteres de año en posiciones 3-6
                        mes = nombre_raster[7:9]  # Caracteres de mes en posiciones 7-8

                        # Agregación de meses de junio, julio y agosto (para julio-agosto en 2023, quitar '06')
                        if mes in ['06', '07', '08']:
                            if ano not in ano_rasters:
                                ano_rasters[ano] = []
                            ano_rasters[ano].append(raster)
                    except Exception as e:
                        print(f"Error al procesar el nombre del raster {raster}: {e}")
                        continue

                # Procesamiento de cada grupo de rasters por año
                for ano, rasters_del_ano in ano_rasters.items():
                    # Definición del nombre y la ruta del raster de salida (SSM o SWI según corresponda)
                    rutarastersmensuales = os.path.join(rasters_procesados, f'SSMminverano{ano}.tif')
                    try:
                        # Cálculo del promedio de los meses de verano ya especificados con la herramienta de ArcPy
                        # "Estadísticas de celdas"
                        media_verano = CellStatistics(rasters_del_ano, "MINIMUM", "DATA")
                        media_verano.save(rutarastersmensuales)
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

        # Error relacionado con la obtención de la licencia de Spatial Analyst
        except arcpy.ExecuteError:
            print("No se pudo obtener la extensión Spatial Analyst.")
            print(arcpy.GetMessages())
