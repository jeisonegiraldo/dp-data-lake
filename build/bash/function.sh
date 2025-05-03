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

echo "Deploy cloud function $env Start"
echo "Proyecto: $PROJECT_ID"
echo "SA: $SERVICE_ACCOUNT_ID"

# Leer el archivo deploy_prd.json
functions_list=$(jq -r '.function[]' ./deploy/deploy_$env.json)

# Iterar sobre cada función y desplegarla
for function_path in $functions_list; do
  # Obtener el nombre de la función a partir de la ruta
  function_base_name=$(basename $function_path)
  function_name=$env-${function_base_name//_/-}

   # Define el entry-point basado en el nombre de la función
  entry_point="${function_name//-/_}"

  # Verificar si se ha encontrado una función principal
  main_file="${function_path}/main.py"
  entry_point=$(grep -oP 'def \K\w+' ".$main_file" | head -n 1)
  if [[ -z "$function_name" ]]; then
    echo "No se encontró una función principal en el archivo $main_file"
    exit 1
  fi

  # Desplegar la Cloud Function
  echo "Executing gcloud command"
  echo "Desplegando Cloud Function: $function_name"
  echo "Source path: .$function_path"
  echo "Entry point: $entry_point"

  deploy_log=$(gcloud functions deploy $function_name \
    --region=$REGION \
    --entry-point="$entry_point" \
    --trigger-http \
    --runtime=python39 \
    --source=.$function_path \
    --no-allow-unauthenticated \
    --max-instances=10 \
    --memory=512MB \
    --timeout=540s \
    --project=$PROJECT_ID \
    --service-account=$SERVICE_ACCOUNT_ID 2>&1)

  # Mostrar el log de la ejecución del comando
  echo "Result:"
  echo "$deploy_log"
  echo "$iam_invoker_log"
  # Verificar si el comando fue exitoso y buscar la palabra "error" en el log
  if [[ "$deploy_log" =~ [eE][rR][rR][oO][rR] ]]; then
  echo "Function deploy with errors"
    exit 1
  fi
  echo "Function deploy success."

done