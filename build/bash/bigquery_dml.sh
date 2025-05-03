#!/bin/bash

# Instalar jq si no está instalado
if ! command -v jq &> /dev/null
then
    echo "install jq"
    apt-get update && apt-get install -y jq
fi
# Verificar si se ha pasado el parámetro de ambiente (dev, prd, etc.)
if [ -z "$1" ]; then
  echo "Debe especificar el ambiente (por ejemplo, dev, prd) como parámetro."
  exit 1
fi
env=$1
echo "bigquery_dml_build"
file_list=$(jq -r '.bigquery_dml[]' ./deploy/deploy_$env.json)
echo $file_list
for file in $file_list; do
  if [ -f ".$file" ]; then
    echo "Ejecutando .$file en BigQuery"
    #bq query --use_legacy_sql=false < .$file
    deploy_log=$(bq query --use_legacy_sql=false < .$file)

      # Mostrar el log de la ejecución del comando
    echo "Result:"
    echo "$deploy_log"
    # Verificar si el comando fue exitoso y buscar la palabra "error" en el log
    if [[ "$deploy_log" =~ [eE][rR][rR][oO][rR] ]]; then
    echo "bq deploy with errors"
      exit 1
    fi
    echo "bq deploy success."

  else
    echo "El archivo .$file no existe"
    exit 1
  fi
done