#!/bin/bash

# Función para verificar si una tabla existe en BigQuery
table_exists() {
  local table_name=$3
  local exists=$(bq --project_id=$1 ls -d $2 | grep -w $table_name)
  if [[ -z $exists ]]; then
    echo "false"
  else
    echo "true"
  fi
}
echo "bigquery_ddl_build"
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
pwd
ls
echo "repository: $URL_REPO"
#cd $(basename $URL_REPO)

# Variables
file_list=$(jq -r '.bigquery_ddl[]' ./deploy/deploy_$env.json)

# Compilar los store procedures
for file in $file_list; do
  file_path=".$file"
  echo $file_path
  if [ -f ".$file" ]; then
    # Leer el contenido del archivo
    #sp_content=$(cat $file_path)

    file_content=$(<"$file_path")
    file_content_lower=$(echo "$file_content" | tr '[:upper:]' '[:lower:]')
    #Verificar si el archivo contiene sentencias DROP TABLE en minúsculas
    if echo "$file_content_lower" | grep -qE "drop\s+table|truncate\s+table"; then
      echo "ERROR: File $file has DROP or TRUNCATE TABLE sentences."
      exit 1
    fi
    #Verificar si el archivo contiene sentencias CREATE TABLE o ALTER TABLE en minúsculas

    #if echo "$file_content_lower" | grep -qE "create\s+table|alter\s+table"; then
    #if echo "$file_content_lower" | grep -iqE 'create\s+table|create\s+or\s+replace\s+table|create\s+view|alter\s+table'; then

      #Obtener el nombre de la tabla creada
      #table_name=$(echo "$sp_content" | grep -ioP '(?<=CREATE OR REPLACE TABLE `).+?(?=`)')

      ddl_file=$file_path

      # Leer la primera línea del archivo
      first_line=$(head -n 1 $ddl_file)
      echo $first_line


      echo "Executing create table $file..."
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

      echo "Executed DDl table $file..."
    

  else
    echo "File $file_path does not exist. Skipping..."
    exit 1
  fi
done