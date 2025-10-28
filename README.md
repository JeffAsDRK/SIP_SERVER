# Servidor SIP Asterisk Dockerizado

Servidor SIP basado en Asterisk 18+ con Ubuntu 22.04, optimizado para trabajar con softphones Zoiper y equipos de videovigilancia IP Dahua y Hikvision.

## Características

- ✅ **Asterisk** sobre Ubuntu 22.04 LTS
- ✅ **Compatible con Zoiper** (softphones)
- ✅ **Compatible con Dahua** (cámaras IP)
- ✅ **Compatible con Hikvision** (cámaras IP)
- ✅ **Configuración optimizada** para equipos IP
- ✅ **Códecs múltiples** (G.711, G.722, G.726, G.729, GSM)
- ✅ **NAT traversal** configurado
- ✅ **Logs persistentes**
- ✅ **Healthcheck** incluido

## Requisitos Previos

- Docker y Docker Compose instalados
- Puertos disponibles:
  - `5060/udp` y `5060/tcp` (SIP)
  - `10000-10100/udp` (RTP Media)
  - `4569/udp` (IAX2, opcional)

## Instalación Rápida

### 1. Clonar y construir

```bash
# Construir la imagen
docker-compose build

# Iniciar el servicio
docker-compose up -d
```

### 2. Verificar funcionamiento

```bash
# Ver logs del contenedor
docker-compose logs -f asterisk-sip

# Verificar que Asterisk esté corriendo
docker exec asterisk-sip-server asterisk -rx "core show version"

# Ver peers SIP registrados
docker exec asterisk-sip-server asterisk -rx "sip show peers"
```

## Configuración de Equipos

### Softphones Zoiper

| Usuario | Contraseña | Extensión |
|---------|------------|-----------|
| 1001    | zoiper1001 | 1001      |
| 1002    | zoiper1002 | 1002      |
| 1003    | zoiper1003 | 1003      |

**Configuración Zoiper:**
- Servidor: `IP_DEL_SERVIDOR:5060`
- Protocolo: UDP
- STUN: `stun.l.google.com:19302`

### Cámaras Dahua

| Usuario | Contraseña  | Extensión |
|---------|-------------|-----------|
| 2001    | dahua2001   | 2001      |
| 2002    | dahua2002   | 2002      |

**Configuración Dahua:**
- SIP Server: `IP_DEL_SERVIDOR:5060`
- SIP Domain: `asterisk`
- Audio Codec: `PCMU` o `PCMA`

### Cámaras Hikvision

| Usuario | Contraseña      | Extensión |
|---------|-----------------|-----------|
| 3001    | hikvision3001   | 3001      |
| 3002    | hikvision3002   | 3002      |

**Configuración Hikvision:**
- SIP Server: `IP_DEL_SERVIDOR:5060`
- Server Domain: `asterisk`
- Audio Encoding: `G.711U` o `G.711A`

## Plan de Numeración

- **1XXX**: Softphones Zoiper
- **2XXX**: Cámaras Dahua
- **3XXX**: Cámaras Hikvision
- **8888**: Test de audio
- **9998**: Echo test
- **9999**: Administrador (admin123)

## Comandos de Verificación

### Verificar conectividad SIP

```bash
# Desde el host, verificar puerto SIP
netstat -an | grep :5060

# Verificar RTP ports
netstat -an | grep ":1000[0-9]"
```

### Comandos Asterisk útiles

```bash
# Acceder a consola CLI de Asterisk
docker exec -it asterisk-sip-server asterisk -r

# Ver peers registrados
docker exec asterisk-sip-server asterisk -rx "sip show peers"

# Ver canales activos
docker exec asterisk-sip-server asterisk -rx "core show channels"

# Habilitar debug SIP
docker exec asterisk-sip-server asterisk -rx "sip set debug on"

# Ver estadísticas RTP
docker exec asterisk-sip-server asterisk -rx "rtp show stats"
```

## Testing y Verificación

### Test básico con softphone

1. Configurar Zoiper con extensión 1001
2. Registrarse en el servidor
3. Llamar a 8888 para test de audio
4. Llamar a 9998 para echo test

### Test con cámaras IP

1. Configurar cámara Dahua como extensión 2001
2. Desde Zoiper 1001, llamar a 2001
3. Verificar audio bidireccional
4. Repetir con cámara Hikvision 3001

### Verificar logs

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs específicos de SIP
docker exec asterisk-sip-server tail -f /var/log/asterisk/sip_history.log

# Ver todos los logs de Asterisk
docker exec asterisk-sip-server tail -f /var/log/asterisk/full
```

## Troubleshooting

### Problemas comunes

**1. No se registran los equipos:**
- Verificar conectividad de red
- Comprobar credenciales SIP
- Revisar firewall

**2. No hay audio en las llamadas:**
- Verificar puertos RTP (10000-10100)
- Revisar configuración NAT
- Comprobar códecs compatibles

**3. Llamadas se cortan:**
- Verificar qualify settings
- Revisar timeout de sesión
- Comprobar estabilidad de red

### Logs importantes

```bash
# Ver errores
docker exec asterisk-sip-server grep ERROR /var/log/asterisk/full

# Ver warnings
docker exec asterisk-sip-server grep WARNING /var/log/asterisk/full

# Ver actividad SIP específica
docker exec asterisk-sip-server grep "SIP/" /var/log/asterisk/full
```

## Personalización

### Agregar más usuarios

Editar `config/sip.conf` y agregar:

```ini
[1004](softphone-template)
secret=zoiper1004
callerid="Zoiper 1004" <1004>
```

### Cambiar códecs

Editar la sección `disallow/allow` en `config/sip.conf`:

```ini
disallow=all
allow=ulaw
allow=alaw
allow=g722
```

### Configurar NAT externa

Editar `config/rtp.conf`:

```ini
externaddr=TU_IP_PUBLICA
localnet=192.168.1.0/255.255.255.0
```

## Seguridad

- Cambiar todas las contraseñas por defecto
- Usar fail2ban para proteger contra ataques de fuerza bruta
- Configurar firewall restrictivo
- Considerar usar TLS para SIP (puerto 5061)

## Soporte

Para más detalles de configuración de equipos específicos, ver:
- `docs/CONFIGURACION_EQUIPOS.md`

## Licencia

Este proyecto está bajo licencia MIT.