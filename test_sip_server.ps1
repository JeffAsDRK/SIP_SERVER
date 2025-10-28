# Script de verificación del servidor SIP Asterisk para Windows PowerShell
# Uso: .\test_sip_server.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN SERVIDOR SIP ASTERISK" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

function Print-Status {
    param($success, $message)
    if ($success) {
        Write-Host "✓ $message" -ForegroundColor Green
    } else {
        Write-Host "✗ $message" -ForegroundColor Red
    }
}

function Print-Warning {
    param($message)
    Write-Host "⚠ $message" -ForegroundColor Yellow
}

function Print-Info {
    param($message)
    Write-Host "ℹ $message" -ForegroundColor Blue
}

# 1. Verificar que Docker esté corriendo
Write-Host "`n1. Verificando Docker..." -ForegroundColor White
try {
    $dockerVersion = docker --version 2>$null
    Print-Status $true "Docker está instalado y funcionando"
} catch {
    Print-Status $false "Docker no está disponible"
    return
}

# 2. Verificar que el contenedor esté corriendo
Write-Host "`n2. Verificando contenedor Asterisk..." -ForegroundColor White
$containerRunning = docker ps --format "table {{.Names}}" | Select-String "asterisk-sip-server"
if ($containerRunning) {
    Print-Status $true "Contenedor asterisk-sip-server está corriendo"
    $CONTAINER_RUNNING = $true
} else {
    Print-Status $false "Contenedor asterisk-sip-server NO está corriendo"
    $CONTAINER_RUNNING = $false
    Print-Warning "Iniciando contenedor..."
    docker-compose up -d
    Start-Sleep -Seconds 10
}

# 3. Verificar que Asterisk esté respondiendo
Write-Host "`n3. Verificando servicio Asterisk..." -ForegroundColor White
if ($CONTAINER_RUNNING -or (docker ps --format "table {{.Names}}" | Select-String "asterisk-sip-server")) {
    try {
        $asteriskVersion = docker exec asterisk-sip-server asterisk -rx "core show version" 2>$null
        Print-Status $true "Asterisk está respondiendo a comandos CLI"
    } catch {
        Print-Status $false "Asterisk no está respondiendo"
    }
} else {
    Print-Status $false "No se puede verificar Asterisk - contenedor no está corriendo"
}

# 4. Verificar puertos de red
Write-Host "`n4. Verificando puertos de red..." -ForegroundColor White

# Puerto SIP 5060
$sipPort = netstat -an | Select-String ":5060"
if ($sipPort) {
    Print-Status $true "Puerto SIP 5060 está abierto y escuchando"
} else {
    Print-Status $false "Puerto SIP 5060 no está escuchando"
}

# Verificar algún puerto RTP
$rtpPort = netstat -an | Select-String ":10000"
if ($rtpPort) {
    Print-Status $true "Puerto RTP 10000 está disponible"
} else {
    Print-Info "Puerto RTP 10000 no está actualmente en uso (normal si no hay llamadas)"
}

# 5. Verificar configuración SIP
Write-Host "`n5. Verificando configuración SIP..." -ForegroundColor White
if (docker ps --format "table {{.Names}}" | Select-String "asterisk-sip-server") {
    try {
        $sipPeers = docker exec asterisk-sip-server asterisk -rx "sip show peers" 2>$null
        if ($sipPeers -match "(1001|2001|3001)") {
            Print-Status $true "Peers SIP están configurados correctamente"
        } else {
            Print-Status $false "No se encontraron peers SIP configurados"
        }
        
        # Mostrar peers configurados
        Write-Host "`n   Peers SIP configurados:" -ForegroundColor Gray
        $sipPeers | Select-String "(Name|1001|1002|1003|2001|2002|3001|3002|admin)" | Select-Object -First 10 | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    } catch {
        Print-Status $false "Error al obtener información de peers SIP"
    }
}

# 6. Verificar logs
Write-Host "`n6. Verificando logs..." -ForegroundColor White
if (docker ps --format "table {{.Names}}" | Select-String "asterisk-sip-server") {
    try {
        $errorCount = docker exec asterisk-sip-server grep -c "ERROR" /var/log/asterisk/full 2>$null
        $warningCount = docker exec asterisk-sip-server grep -c "WARNING" /var/log/asterisk/full 2>$null
        
        if ($errorCount -and [int]$errorCount -lt 5) {
            Print-Status $true "Logs muestran pocos errores ($errorCount)"
        } elseif ($errorCount -and [int]$errorCount -ge 5) {
            Print-Status $false "Logs muestran muchos errores ($errorCount)"
        }
        
        if ($warningCount) {
            Print-Info "Warnings en logs: $warningCount"
        }
    } catch {
        Print-Info "No se pudieron verificar los logs"
    }
}

# 7. Test de conectividad básica
Write-Host "`n7. Test de conectividad..." -ForegroundColor White

try {
    $containerIP = docker inspect asterisk-sip-server --format="{{.NetworkSettings.IPAddress}}" 2>$null
    if ($containerIP) {
        Print-Info "IP del contenedor: $containerIP"
        
        # Test ping al contenedor
        $pingResult = Test-Connection -ComputerName $containerIP -Count 1 -Quiet 2>$null
        Print-Status $pingResult "Ping al contenedor exitoso"
    }
} catch {
    Print-Info "No se pudo obtener IP del contenedor"
}

# 8. Verificar salud del contenedor
Write-Host "`n8. Verificando salud del contenedor..." -ForegroundColor White
try {
    $healthStatus = docker inspect asterisk-sip-server --format="{{.State.Health.Status}}" 2>$null
    if ($healthStatus -eq "healthy") {
        Print-Status $true "Healthcheck del contenedor: $healthStatus"
    } elseif ($healthStatus -eq "starting") {
        Print-Warning "Healthcheck del contenedor: $healthStatus (esperando...)"
    } else {
        Print-Status $false "Healthcheck del contenedor: $healthStatus"
    }
} catch {
    Print-Info "No se pudo verificar el healthcheck del contenedor"
}

# Resumen final
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE VERIFICACIÓN" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if (docker ps --format "table {{.Names}}" | Select-String "asterisk-sip-server") {
    Write-Host "✓ Servidor SIP Asterisk está funcionando" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Configurar equipos Zoiper con extensiones 1001-1003"
    Write-Host "2. Configurar cámaras Dahua con extensiones 2001-2002"  
    Write-Host "3. Configurar cámaras Hikvision con extensiones 3001-3002"
    Write-Host "4. Realizar llamadas de prueba"
    Write-Host ""
    Write-Host "Para más detalles ver: docs/CONFIGURACION_EQUIPOS.md" -ForegroundColor Blue
} else {
    Write-Host "✗ Hay problemas con el servidor SIP" -ForegroundColor Red
    Write-Host ""
    Write-Host "Acciones recomendadas:" -ForegroundColor Yellow
    Write-Host "1. docker-compose logs -f"
    Write-Host "2. docker-compose down; docker-compose up -d"
    Write-Host "3. Verificar configuración de red y firewall"
}

Write-Host ""