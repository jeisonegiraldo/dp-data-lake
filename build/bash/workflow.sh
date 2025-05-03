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


echo "Deploy workflow $env Start"
echo "Proyecto: $PROJECT_ID"
echo "SA: $SERVICE_ACCOUNT_ID"

# Leer el archivo JSON y desplegar los workflows listados
workflow_list=$(jq -r '.workflow[]' ./deploy/deploy_$env.json)
# Encuentra todas las claves de desarrollo y las reeemplaza por claves productivas
replace_file="./build/config/env.json"

for file in $workflow_list; do
  wf_base_name=$(basename $file .yaml)
  wf_name=$env-${wf_base_name//_/-}
  # Reemplazar "_" por "-"
  #wf_name=${$env-$wf_base_name//_/-}

  echo "workflow name: $wf_name"
  echo "workflow file: $file"


  replacements=$(jq -r '.project[] | to_entries[] | .key + ":" + .value' "$replace_file")
  # Realizar los reemplazos en el archivo
  echo "replacement by environment file: $file"
  for replacement in $replacements; do
    old_value=$(echo "$replacement" | cut -d':' -f1)
    new_value=$(echo "$replacement" | cut -d':' -f2)
    sed -i "s/$old_value/$new_value/g" ".$file"
  done
  # Comando para desplegar el workflow y capturar la salida
  #deploy_log=$(gcloud workflows deploy my-workflow --source="$workflow_file" 2>&1)
  echo "Executing gcloud command"
  deploy_log=$(gcloud workflows deploy $wf_name --source=.$file --project=$env-intercorp-data-operation \
    --location=us-central1 --service-account=$SERVICE_ACCOUNT_ID 2>&1)

  # Mostrar el log de la ejecución del comando
  echo "Result:"
  echo "$deploy_log"
  # Verificar si el comando fue exitoso y buscar la palabra "error" en el log
  if [[ "$deploy_log" =~ [eE][rR][rR][oO][rR] ]]; then
  echo "Workflow deploy with errors"
    exit 1
  fi
  echo "Workflow deploy success."

done

echo "Deploy workflow $env finished!"