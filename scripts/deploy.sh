#!/bin/bash

# Crea el directorio de datos si no existe
mkdir -p data

# Levantar contenedores con Docker Compose
echo "Levantando los contenedores con Docker Compose..."
docker compose up -d

# Esperar a que los contenedores inicien completamente
echo "Esperando a que los contenedores estén listos..."
sleep 30

# Ejecutar inicialización de la base de datos (si es necesario)
echo "Inicializando la base de datos con el archivo init.sql..."
docker exec -i pxc1 mysql -uroot -proot < /scripts/init.sql

# Verificar el estado de los contenedores
echo "Verificando el estado de los contenedores..."
docker ps

# Mensaje final
echo "¡Todo listo! Los contenedores están levantados y funcionando."
echo "Puedes conectarte a la base de datos a través de HAProxy en el puerto 3307."
