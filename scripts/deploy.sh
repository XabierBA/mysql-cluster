#!/bin/bash

echo "🚀 Iniciando Cluster MySQL con HAProxy..."

# Crear volumenes si no existen
echo "📦 Preparando volúmenes..."
docker volume create mysql1-data 2>/dev/null || true
docker volume create mysql2-data 2>/dev/null || true
docker volume create mysql3-data 2>/dev/null || true

# Iniciar contenedores
echo "🐳 Levantando contenedores..."
docker compose up -d

echo "⏳ Esperando inicialización del cluster..."
sleep 30

# Verificar estado
echo "🔍 Verificando estado..."
docker compose ps

echo ""
echo "✅ Cluster desplegado!"
echo "📊 Acceso HAProxy Stats: http://localhost:8404/stats"
echo "🔌 Conexión balanceada: localhost:3309"
echo "🗄️  Nodos directos:"
echo "   - Nodo 1: localhost:3306"
echo "   - Nodo 2: localhost:3307"
echo "   - Nodo 3: localhost:3308"