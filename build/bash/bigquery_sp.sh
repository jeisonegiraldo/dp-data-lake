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
echo "bigquery_sql_build"
file_list=$(jq -r '.bigquery_sp[]' ./datapath-lake/deploy/deploy_$env.json)
echo $file_list
for file in $file_list; do
  if [ -f ".$file" ]; then
    echo "Ejecutando .$file en BigQuery"
    bq query --use_legacy_sql=false < .$file
  else
    echo "El archivo .$file no existe"
    exit 1
  fi
done