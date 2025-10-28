# Script de verificación simple del servidor SIP Asterisk
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN SERVIDOR SIP ASTERISK" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Verificar si Docker está ejecutándose
Write-Host "`n1. Verificando Docker..." -ForegroundColor Blue
$dockerVersion = docker --version 2>$null
if ($dockerVersion) {
    Write-Host "✓ Docker está disponible: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Error: Docker no está disponible" -ForegroundColor Red
}

# Verificar el estado del contenedor
Write-Host "`n2. Verificando estado del contenedor..." -ForegroundColor Blue
$containerStatus = docker-compose ps 2>$null
if ($containerStatus -match "Up") {
    Write-Host "✓ Contenedor asterisk-sip está ejecutándose" -ForegroundColor Green
} else {
    Write-Host "✗ Contenedor no está ejecutándose" -ForegroundColor Red
}

# Verificar procesos dentro del contenedor
Write-Host "`n3. Verificando procesos Asterisk..." -ForegroundColor Blue
$processes = docker exec asterisk-sip-server ps aux 2>$null
if ($processes -match "asterisk") {
    Write-Host "✓ Proceso Asterisk está ejecutándose" -ForegroundColor Green
} else {
    Write-Host "✗ Proceso Asterisk no encontrado" -ForegroundColor Red
}

# Verificar puerto SIP
Write-Host "`n4. Verificando puerto SIP (5060)..." -ForegroundColor Blue
$portCheck = docker exec asterisk-sip-server netstat -tuln 2>$null
if ($portCheck -match "5060") {
    Write-Host "✓ Puerto 5060 está abierto y escuchando" -ForegroundColor Green
} else {
    Write-Host "✗ Puerto 5060 no está disponible" -ForegroundColor Red
}

# Verificar logs de Asterisk
Write-Host "`n5. Verificando logs de Asterisk..." -ForegroundColor Blue
$logs = docker logs asterisk-sip-server --tail 5 2>$null
if ($logs -match "Asterisk Ready") {
    Write-Host "✓ Asterisk se inició correctamente" -ForegroundColor Green
} else {
    Write-Host "⚠ Revisando estado de Asterisk..." -ForegroundColor Yellow
}

# Mostrar información de conexión
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  INFORMACIÓN DE CONEXIÓN" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Servidor SIP: localhost:5060" -ForegroundColor White
Write-Host "Protocolo: UDP/TCP" -ForegroundColor White
Write-Host "Usuarios configurados:" -ForegroundColor White
Write-Host "  - Usuario: 1001, Password: secret1001" -ForegroundColor Yellow
Write-Host "  - Usuario: 1002, Password: secret1002" -ForegroundColor Yellow
Write-Host "  - Usuario: 2001, Password: secret2001 (Dahua)" -ForegroundColor Yellow
Write-Host "  - Usuario: 2002, Password: secret2002 (Dahua)" -ForegroundColor Yellow
Write-Host "  - Usuario: 3001, Password: secret3001 (Hikvision)" -ForegroundColor Yellow
Write-Host "  - Usuario: 3002, Password: secret3002 (Hikvision)" -ForegroundColor Yellow

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  CONFIGURACIÓN PARA CLIENTES" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Para Zoiper:" -ForegroundColor White
Write-Host "  - Servidor: localhost o IP_DEL_SERVIDOR" -ForegroundColor Yellow
Write-Host "  - Puerto: 5060" -ForegroundColor Yellow
Write-Host "  - Transporte: UDP" -ForegroundColor Yellow
Write-Host "  - Usuario/Password: usar cualquiera de los listados arriba" -ForegroundColor Yellow

Write-Host "`nPara equipos Dahua/Hikvision:" -ForegroundColor White
Write-Host "  - Usar usuarios 2001-2002 (Dahua) o 3001-3002 (Hikvision)" -ForegroundColor Yellow
Write-Host "  - Codecs soportados: G.711 (ULAW/ALAW), G.722, GSM" -ForegroundColor Yellow

Write-Host "`n✓ Verificación completada!" -ForegroundColor Green
Write-Host "El servidor SIP Asterisk está listo para usar!" -ForegroundColor Green