#!/bin/bash

# Iniciar los contenedores con Docker Compose
echo "Iniciando el clúster Galera..."
docker compose up -d

# Función para verificar si el contenedor está en ejecución
wait_for_container() {
  local container_name=$1
  echo "Esperando a que el contenedor $container_name esté en ejecución..."
  while ! docker ps --filter "name=$container_name" --format '{{.Names}}' | grep -q "$container_name"; do
    sleep 1
  done
  echo "$container_name está en ejecución."
}

# Esperar a que los contenedores se inicien
wait_for_container "mysql-galera-cluster_mysql-node1_1"
wait_for_container "mysql-galera-cluster_mysql-node2_1"
wait_for_container "mysql-galera-cluster_mysql-node3_1"
wait_for_container "mysql-galera-cluster_haproxy_1"

# Configurar el primer nodo (mysql-node1) como nodo inicial
echo "Configurando el primer nodo (mysql-node1) como nodo inicial..."
docker exec -it mysql-galera-cluster_mysql-node1_1 mysql -u root -proot -e "SET GLOBAL wsrep_cluster_address='gcomm://';"

# Esperar que el primer nodo se una al clúster
echo "Esperando a que el primer nodo se una al clúster..."
sleep 10

# Configurar los otros nodos (mysql-node2 y mysql-node3) para unirse al clúster
echo "Configurando los nodos restantes para unirse al clúster..."
docker exec -it mysql-galera-cluster_mysql-node2_1 mysql -u root -proot -e "SET GLOBAL wsrep_cluster_address='gcomm://mysql-node1';"
docker exec -it mysql-galera-cluster_mysql-node3_1 mysql -u root -proot -e "SET GLOBAL wsrep_cluster_address='gcomm://mysql-node1';"

# Esperar unos segundos para que todos los nodos se conecten
echo "Esperando a que todos los nodos se conecten..."
sleep 10

# Verificar el estado del clúster
echo "Verificando el estado del clúster..."
docker exec -it mysql-galera-cluster_mysql-node1_1 mysql -u root -proot -e "SHOW STATUS LIKE 'wsrep%';"

echo "Clúster Galera iniciado y verificado correctamente."
