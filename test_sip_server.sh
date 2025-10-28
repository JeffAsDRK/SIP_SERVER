#!/bin/bash

# Script de verificación automática del servidor SIP Asterisk
# Uso: ./test_sip_server.sh

echo "=========================================="
echo "  VERIFICACIÓN SERVIDOR SIP ASTERISK"
echo "=========================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# 1. Verificar que Docker esté corriendo
echo -e "\n1. Verificando Docker..."
docker --version > /dev/null 2>&1
print_status $? "Docker está instalado y funcionando"

# 2. Verificar que el contenedor esté corriendo
echo -e "\n2. Verificando contenedor Asterisk..."
docker ps | grep asterisk-sip-server > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status 0 "Contenedor asterisk-sip-server está corriendo"
    CONTAINER_RUNNING=1
else
    print_status 1 "Contenedor asterisk-sip-server NO está corriendo"
    CONTAINER_RUNNING=0
    print_warning "Iniciando contenedor..."
    docker-compose up -d
    sleep 10
fi

# 3. Verificar que Asterisk esté respondiendo
echo -e "\n3. Verificando servicio Asterisk..."
if [ $CONTAINER_RUNNING -eq 1 ] || docker ps | grep asterisk-sip-server > /dev/null 2>&1; then
    docker exec asterisk-sip-server asterisk -rx "core show version" > /dev/null 2>&1
    print_status $? "Asterisk está respondiendo a comandos CLI"
else
    print_status 1 "No se puede verificar Asterisk - contenedor no está corriendo"
fi

# 4. Verificar puertos de red
echo -e "\n4. Verificando puertos de red..."

# Puerto SIP 5060
netstat -an 2>/dev/null | grep ":5060" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status 0 "Puerto SIP 5060 está abierto y escuchando"
else
    # En Windows usar netstat diferente
    netstat -an 2>/dev/null | findstr ":5060" > /dev/null 2>&1
    print_status $? "Puerto SIP 5060 está abierto y escuchando"
fi

# Verificar algún puerto RTP
netstat -an 2>/dev/null | grep ":10000" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status 0 "Puerto RTP 10000 está disponible"
else
    netstat -an 2>/dev/null | findstr ":10000" > /dev/null 2>&1
    print_status $? "Puerto RTP 10000 está disponible"
fi

# 5. Verificar configuración SIP
echo -e "\n5. Verificando configuración SIP..."
if docker ps | grep asterisk-sip-server > /dev/null 2>&1; then
    # Verificar que se pueden cargar los peers
    docker exec asterisk-sip-server asterisk -rx "sip show peers" | grep -E "(1001|2001|3001)" > /dev/null 2>&1
    print_status $? "Peers SIP están configurados correctamente"
    
    # Mostrar peers configurados
    echo -e "\n   Peers SIP configurados:"
    docker exec asterisk-sip-server asterisk -rx "sip show peers" 2>/dev/null | grep -E "(Name|1001|1002|1003|2001|2002|3001|3002|admin)" | head -10
fi

# 6. Verificar logs
echo -e "\n6. Verificando logs..."
if docker ps | grep asterisk-sip-server > /dev/null 2>&1; then
    # Verificar que no hay errores críticos recientes
    ERROR_COUNT=$(docker exec asterisk-sip-server grep -c "ERROR" /var/log/asterisk/full 2>/dev/null | tail -1)
    WARNING_COUNT=$(docker exec asterisk-sip-server grep -c "WARNING" /var/log/asterisk/full 2>/dev/null | tail -1)
    
    if [ ! -z "$ERROR_COUNT" ]; then
        if [ $ERROR_COUNT -lt 5 ]; then
            print_status 0 "Logs muestran pocos errores ($ERROR_COUNT)"
        else
            print_status 1 "Logs muestran muchos errores ($ERROR_COUNT)"
        fi
    fi
    
    if [ ! -z "$WARNING_COUNT" ]; then
        print_info "Warnings en logs: $WARNING_COUNT"
    fi
fi

# 7. Test de conectividad básica
echo -e "\n7. Test de conectividad..."

# Obtener IP del contenedor
CONTAINER_IP=$(docker inspect asterisk-sip-server 2>/dev/null | grep '"IPAddress"' | tail -1 | cut -d'"' -f4)
if [ ! -z "$CONTAINER_IP" ]; then
    print_info "IP del contenedor: $CONTAINER_IP"
    
    # Test ping al contenedor
    ping -c 1 $CONTAINER_IP > /dev/null 2>&1
    print_status $? "Ping al contenedor exitoso"
fi

# 8. Verificar salud del contenedor
echo -e "\n8. Verificando salud del contenedor..."
HEALTH_STATUS=$(docker inspect asterisk-sip-server 2>/dev/null | grep '"Status"' | grep -o '"[^"]*"' | head -1 | tr -d '"')
if [ "$HEALTH_STATUS" = "healthy" ]; then
    print_status 0 "Healthcheck del contenedor: $HEALTH_STATUS"
elif [ "$HEALTH_STATUS" = "starting" ]; then
    print_warning "Healthcheck del contenedor: $HEALTH_STATUS (esperando...)"
else
    print_status 1 "Healthcheck del contenedor: $HEALTH_STATUS"
fi

# Resumen final
echo -e "\n=========================================="
echo "  RESUMEN DE VERIFICACIÓN"
echo "=========================================="

if docker ps | grep asterisk-sip-server > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Servidor SIP Asterisk está funcionando${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. Configurar equipos Zoiper con extensiones 1001-1003"
    echo "2. Configurar cámaras Dahua con extensiones 2001-2002"  
    echo "3. Configurar cámaras Hikvision con extensiones 3001-3002"
    echo "4. Realizar llamadas de prueba"
    echo ""
    echo "Para más detalles ver: docs/CONFIGURACION_EQUIPOS.md"
else
    echo -e "${RED}✗ Hay problemas con el servidor SIP${NC}"
    echo ""
    echo "Acciones recomendadas:"
    echo "1. docker-compose logs -f"
    echo "2. docker-compose down && docker-compose up -d"
    echo "3. Verificar configuración de red y firewall"
fi

echo ""