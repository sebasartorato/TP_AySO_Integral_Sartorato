#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista Dominios y URL
#
#  Tareas:
#  - Se debera generar la estructura de directorio pedida con 1 solo comando con las tecnicas enseñadas en clases
#  - Generar los archivos de logs requeridos.
#
###############################
LISTA=$1

LOG_FILE="/var/log/status_url.log"

sudo touch "$LOG_FILE"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: No se pudo crear el archivo de log en $LOG_FILE"
  exit 1
fi

ANT_IFS=$IFS
IFS=$'\n'

sudo mkdir -p /tmp/head-check/{Error/{cliente,servidor},ok}

#---- Dentro del bucle ----#
for LINEA in `cat $LISTA |  grep -v ^#`
do
	# Obtener el código de estado HTTP
  	URL=$(echo $LINEA | awk '{print $2}')
  	DOMINIO=$(echo $LINEA | awk '{print $1}')
  	STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

  	# Fecha y hora actual en formato yyyymmdd_hhmmss
  	TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

 	# Registrar en el archivo /var/log/status_url.log
  	echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee -a  "$LOG_FILE"

 	# Registro dominio.log
  	if [[ "$STATUS_CODE" -eq 200 ]]; then
	  	sudo touch "/tmp/head-check/ok/$DOMINIO.log"
  	elif [[ "$STATUS_CODE" -ge 400 && "$STATUS_CODE" -le 499 ]]; then
	  	sudo touch "/tmp/head-check/Error/cliente/$DOMINIO.log"
  	elif [[ "$STATUS_CODE" -ge 500 && "$STATUS_CODE" -le 599 ]]; then
	  	sudo touch "/tmp/head-check/Error/servidor/$DOMINIO.log"
  	else
	  	echo "El código de estado HTTP no coincide con las condiciones especificadas."
  	fi
done

#-------------------------#

IFS=$ANT_IFS
