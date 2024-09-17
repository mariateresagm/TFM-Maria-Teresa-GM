# Archivo: Minimo_mensual_SPEI.py
# Autora: María Teresa González Moreno
# Descripción: este script permite calcular el mínimo mensual de rasters SPEI,  a través de la
# # herramienta de ArcPy "Cell statistics"

# Importación de módulos
import os
import arcpy
from arcpy.sa import *

# Establecimiento del entorno de trabajo
rasters_originales = "ruta/directorio/trabajo"
arcpy.env.workspace = rasters_originales

# Verificación de la existencia del directorio de trabajo
if not os.path.exists(rasters_originales):
    print(f"No se encontró el directorio de trabajo: {rasters_originales}")

else:
    # Creación de listado de archivos raster del directorio de trabajo
    rasters_semanales = arcpy.ListRasters()

    # Verificación de existencia de rasters para procesar
    if not rasters_semanales:
        print(f"No se encontraron archivos raster en el directorio: {rasters_originales}")

    else:
        # Verificación de disponibilidad de la extensión de ArcGIS Spatial Analyst
        try:
            arcpy.CheckOutExtension("Spatial")

            try:
                # Procesamiento de los rasters semanales de SPEI por grupos de 4 (4 semanas cada mes)
                for i in range(0, len(rasters_semanales), 4):
                    cuatrorasterssemanales = rasters_semanales[i:i + 4]
                    if cuatrorasterssemanales:
                        primerasemana = cuatrorasterssemanales[0]
                        nombreprimerasemana = os.path.basename(primerasemana)
                        try:
                            # Extracción de año y mes del nombre del raster de la primera semana del mes
                            ano_mes = nombreprimerasemana.split('_')[1][:6]  # Formato YYYYMM
                        except IndexError:
                            print(f"Error al extraer año y mes del raster {nombreprimerasemana}. Se omite este raster.")
                            continue
                        # Definición del nombre y la ruta del raster de salida
                        rutarastersmensuales = os.path.join(arcpy.env.workspace, f'spei3_{ano_mes}.tif')

                        try:
                            # Cálculo del mínimo mensual con la herramienta de ArcPy "Cell statistics"
                            minimomensual = CellStatistics(cuatrorasterssemanales, "MINIMUM", "DATA")
                            minimomensual.save(rutarastersmensuales)
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
