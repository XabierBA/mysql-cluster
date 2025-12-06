#!/bin/bash

echo "Levantando los contenedores con Docker Compose..."

# Levantar los contenedores con Docker Compose
sudo docker-compose up -d

# Esperar a que los contenedores estén listos
echo "Esperando a que los contenedores estén listos..."
sleep 30  # Ajusta este tiempo según la carga y el rendimiento de tu sistema

# Verificar que los contenedores estén funcionando correctamente
echo "Verificando el estado de los contenedores..."
sudo docker ps

# Inicializar la base de datos con un archivo init.sql
echo "Inicializando la base de datos con el archivo init.sql..."
if [ -f ./scripts/init.sql ]; then
    sudo docker exec -i mysql-cluster-pxc1-1 mysql -uroot -proot < sinit.sql
else
    echo "Error: No se encontró el archivo init.sql en ./scripts."
    exit 1
fi

# Verificar el estado de la base de datos en el primer nodo
echo "Verificando el estado de la base de datos en el nodo 1 (pxc1)..."
STATUS_1=$(sudo docker exec -it mysql-cluster-pxc1-1 mysql -uroot -proot -e "SHOW STATUS LIKE 'wsrep%';")
echo "$STATUS_1"
if echo "$STATUS_1" | grep -q "wsrep_cluster_size"; then
    echo "Cluster size en pxc1: $(echo "$STATUS_1" | grep 'wsrep_cluster_size')"
else
    echo "Error: El nodo 1 no está conectado correctamente al cluster."
    exit 1
fi

# Verificar el estado de la base de datos en el segundo nodo
echo "Verificando el estado de la base de datos en el nodo 2 (pxc2)..."
STATUS_2=$(sudo docker exec -it mysql-cluster-pxc2-1 mysql -uroot -proot -e "SHOW STATUS LIKE 'wsrep%';")
echo "$STATUS_2"
if echo "$STATUS_2" | grep -q "wsrep_cluster_size"; then
    echo "Cluster size en pxc2: $(echo "$STATUS_2" | grep 'wsrep_cluster_size')"
else
    echo "Error: El nodo 2 no está conectado correctamente al cluster."
    exit 1
fi

# Verificar el estado de la base de datos en el tercer nodo
echo "Verificando el estado de la base de datos en el nodo 3 (pxc3)..."
STATUS_3=$(sudo docker exec -it mysql-cluster-pxc3-1 mysql -uroot -proot -e "SHOW STATUS LIKE 'wsrep%';")
echo "$STATUS_3"
if echo "$STATUS_3" | grep -q "wsrep_cluster_size"; then
    echo "Cluster size en pxc3: $(echo "$STATUS_3" | grep 'wsrep_cluster_size')"
else
    echo "Error: El nodo 3 no está conectado correctamente al cluster."
    exit 1
fi

# Verificar si el cluster está en estado Primary
echo "Verificando que el cluster esté en estado Primary..."
PRIMARY_NODE=$(echo "$STATUS_1" | grep 'wsrep_cluster_status' | awk '{print $2}')
if [ "$PRIMARY_NODE" == "Primary" ]; then
    echo "El cluster está en estado Primary."
else
    echo "Error: El cluster no está en estado Primary."
    exit 1
fi

echo "¡Todo listo! Los contenedores están levantados y funcionando."

# Mensaje final para indicar cómo conectarse a la base de datos
echo "Puedes conectarte a la base de datos a través de HAProxy en el puerto 3307."
