# Configuración para Equipos IP - Servidor SIP Asterisk

## Configuración para Cámaras Dahua

### Parámetros SIP para Dahua:
- **Servidor SIP**: IP_DEL_SERVIDOR:5060
- **Usuario SIP**: 2001 o 2002
- **Contraseña**: dahua2001 o dahua2002
- **Dominio**: asterisk
- **Protocolo de Transporte**: UDP
- **Intervalo de Registro**: 60 segundos
- **Códec de Audio**: PCMU (ulaw) o PCMA (alaw)

### Configuración paso a paso Dahua:
1. Acceder a la interfaz web de la cámara
2. Ir a **Network → SIP**
3. Habilitar SIP
4. Configurar:
   - SIP Server: `IP_DEL_SERVIDOR`
   - SIP Server Port: `5060`
   - SIP User ID: `2001`
   - Authentication ID: `2001`
   - Password: `dahua2001`
   - SIP Domain: `asterisk`
   - Registration Expiry: `60`
   - Transport Protocol: `UDP`
   - Audio Compression: `PCMU`

## Configuración para Cámaras Hikvision

### Parámetros SIP para Hikvision:
- **Servidor SIP**: IP_DEL_SERVIDOR:5060
- **Número SIP**: 3001 o 3002
- **Nombre de Usuario**: 3001 o 3002
- **Contraseña**: hikvision3001 o hikvision3002
- **Dominio del Servidor**: asterisk
- **Protocolo**: UDP
- **Tiempo de Registro**: 60 segundos
- **Códec de Audio**: G.711U o G.711A

### Configuración paso a paso Hikvision:
1. Acceder a la interfaz web de la cámara
2. Ir a **Configuration → Network → Advanced Settings → SIP**
3. Habilitar SIP
4. Configurar:
   - SIP Server IP: `IP_DEL_SERVIDOR`
   - SIP Server Port: `5060`
   - SIP Number: `3001`
   - SIP Username: `3001`
   - SIP Password: `hikvision3001`
   - Server Domain: `asterisk`
   - Registration Validity Period: `60`
   - Transport Protocol: `UDP`
   - Audio Encoding: `G.711U`

## Configuración para Zoiper (Softphone)

### Parámetros para Zoiper:
- **Usuario**: 1001, 1002, o 1003
- **Contraseña**: zoiper1001, zoiper1002, o zoiper1003
- **Dominio**: IP_DEL_SERVIDOR
- **Puerto**: 5060
- **Protocolo de Transporte**: UDP
- **STUN**: Habilitado (stun.l.google.com:19302)

### Configuración paso a paso Zoiper:
1. Abrir Zoiper
2. Crear nueva cuenta SIP
3. Configurar:
   - Username: `1001`
   - Password: `zoiper1001`
   - Host: `IP_DEL_SERVIDOR:5060`
   - Transport: `UDP`
   - Enable STUN: `Yes`
   - STUN Server: `stun.l.google.com:19302`

## Plan de Numeración

### Extensiones Zoiper (Softphones):
- **1001**: Zoiper Usuario 1
- **1002**: Zoiper Usuario 2  
- **1003**: Zoiper Usuario 3

### Extensiones Cámaras Dahua:
- **2001**: Cámara Dahua 01
- **2002**: Cámara Dahua 02

### Extensiones Cámaras Hikvision:
- **3001**: Cámara Hikvision 01
- **3002**: Cámara Hikvision 02

### Extensiones Especiales:
- **8888**: Test de audio
- **9998**: Echo test
- **9999**: Administrador

## Funcionalidades

### Llamadas Permitidas:
- Zoiper puede llamar a cualquier extensión (1XXX, 2XXX, 3XXX)
- Cámaras pueden llamar a Zoiper (1XXX)
- Cámaras pueden llamar entre sí (2XXX, 3XXX)
- Administrador (9999) tiene acceso completo

### Comandos Administrativos (desde extensión 9999):
- ***100**: Ver status del sistema
- ***101**: Recargar configuración SIP

## Troubleshooting

### Verificaciones básicas:
1. Comprobar conectividad de red
2. Verificar que los puertos 5060 y 10000-10100 estén abiertos
3. Confirmar que el firewall permita el tráfico SIP/RTP
4. Revisar logs en `/var/log/asterisk/`

### Comandos útiles de Asterisk:
```bash
# Ver peers SIP registrados
asterisk -rx "sip show peers"

# Ver canales activos
asterisk -rx "core show channels"

# Habilitar debug SIP
asterisk -rx "sip set debug on"

# Ver status general
asterisk -rx "core show version"
```