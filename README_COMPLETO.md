# 🚀 Servidor SIP Asterisk con Panel Web Administrativo

Sistema completo de comunicaciones SIP basado en Asterisk con Ubuntu 22.04 y panel web de administración en tiempo real.

## ✨ Características Principales

### 📞 Servidor SIP Asterisk
- **Sistema Base**: Ubuntu 22.04 LTS
- **Asterisk**: Versión estable con módulos optimizados
- **Compatibilidad**: Zoiper, equipos Dahua y Hikvision
- **Codecs**: G.711 (ULAW/ALAW), G.722, GSM, G.726
- **Protocolo**: SIP sobre UDP/TCP
- **Puertos RTP**: 10000-10100 configurados
- **NAT Traversal**: Configurado para redes complejas

### 🌐 Panel Web Administrativo
- **Framework**: Node.js + Express + Socket.IO
- **Interface**: Bootstrap 5 con diseño responsivo y gradientes
- **Tiempo Real**: WebSockets para monitoreo en vivo
- **Gestión**: Añadir/eliminar usuarios SIP dinámicamente
- **Monitoreo**: Dashboard con gráficos y estadísticas
- **Puerto**: 3000 (HTTP)
- **Características**:
  - Dashboard en tiempo real
  - Gestión de usuarios SIP
  - Monitor de conexiones activas
  - Gráficos de actividad
  - Log de eventos en tiempo real
  - Configuración automática por tipo de equipo

## 📁 Estructura del Proyecto

```
SIP_SERVER/
├── docker-compose.yml          # Orquestación de servicios
├── Dockerfile                  # Imagen Asterisk
├── config/                     # Configuraciones Asterisk
│   ├── asterisk.conf
│   ├── sip.conf               # Usuarios y configuración SIP
│   ├── extensions.conf        # Plan de marcado
│   ├── rtp.conf              # Configuración RTP
│   ├── modules.conf          # Módulos cargados
│   └── logger.conf           # Configuración de logs
├── web-admin/                 # Panel Web Administrativo
│   ├── Dockerfile            # Imagen Node.js
│   ├── server.js            # Servidor Express + Socket.IO
│   ├── package.json         # Dependencias Node.js
│   ├── views/               # Vistas EJS
│   │   ├── layout.ejs       # Layout principal
│   │   ├── dashboard.ejs    # Dashboard principal
│   │   ├── users.ejs        # Gestión de usuarios
│   │   └── monitoring.ejs   # Monitoreo en tiempo real
│   └── public/              # Archivos estáticos
│       └── styles.css       # CSS personalizado
├── docs/                    # Documentación
│   └── CONFIGURACION_EQUIPOS.md
├── test_simple.ps1         # Script de verificación
└── ESTADO_SERVIDOR.md      # Estado y configuración actual
```

## 🚀 Instalación y Despliegue

### 1. Clonar y Preparar
```bash
git clone <este-repositorio>
cd SIP_SERVER
```

### 2. Construir Imágenes
```bash
docker-compose build
```

### 3. Iniciar Servicios
```bash
docker-compose up -d
```

### 4. Verificar Estado
```bash
docker-compose ps
```

## 🌐 Acceso al Sistema

### Panel Web Administrativo
- **URL**: http://localhost:3000
- **Dashboard**: http://localhost:3000
- **Gestión de Usuarios**: http://localhost:3000/users
- **Monitoreo**: http://localhost:3000/monitoring

### Servidor SIP
- **Puerto**: 5060 (UDP/TCP)
- **RTP**: 10000-10100 (UDP)
- **IAX2**: 4569 (UDP)

## 👥 Usuarios Preconfigurados

### Usuarios Zoiper (Softphones)
| Usuario | Contraseña | Descripción |
|---------|-----------|-------------|
| 1001    | secret1001| Usuario general |
| 1002    | secret1002| Usuario general |

### Usuarios Dahua (Equipos IP)
| Usuario | Contraseña | Descripción |
|---------|-----------|-------------|
| 2001    | secret2001| Equipo Dahua |
| 2002    | secret2002| Equipo Dahua |

### Usuarios Hikvision (Equipos IP)
| Usuario | Contraseña | Descripción |
|---------|-----------|-------------|
| 3001    | secret3001| Equipo Hikvision |
| 3002    | secret3002| Equipo Hikvision |

## 🔧 Configuración de Clientes

### Para Zoiper
```
Servidor: <IP_SERVIDOR>:5060
Transporte: UDP
Usuario: 1001 o 1002
Contraseña: secret1001 / secret1002
Codecs: G.711, G.722
```

### Para Equipos Dahua
```
SIP Server: <IP_SERVIDOR>:5060
User ID: 2001 o 2002
Password: secret2001 / secret2002
Transport: UDP
Codec: G.711 (ULAW/ALAW), G.726
```

### Para Equipos Hikvision
```
SIP Server IP: <IP_SERVIDOR>
SIP Server Port: 5060
SIP User ID: 3001 o 3002
SIP Password: secret3001 / secret3002
Transport Protocol: UDP
Audio Encoding: G.711U / G.711A
```

## 🛠️ Gestión del Sistema

### Comandos Docker Compose
```bash
# Ver estado de servicios
docker-compose ps

# Ver logs del servidor SIP
docker-compose logs asterisk-sip

# Ver logs del panel web
docker-compose logs web-admin

# Reiniciar servicios
docker-compose restart

# Parar servicios
docker-compose down

# Iniciar servicios
docker-compose up -d

# Reconstruir imágenes
docker-compose build --no-cache
```

### Gestión de Usuarios via Web
1. Acceder a http://localhost:3000/users
2. Hacer clic en "Añadir Usuario"
3. Completar formulario:
   - Usuario: Número de 4 dígitos (1xxx=Zoiper, 2xxx=Dahua, 3xxx=Hikvision)
   - Contraseña: Contraseña segura
   - Tipo: Seleccionar tipo de cliente
   - Descripción: Descripción opcional
4. Hacer clic en "Crear Usuario"

### Monitoreo en Tiempo Real
- Acceder a http://localhost:3000/monitoring
- Ver usuarios conectados en tiempo real
- Gráfico de conexiones históricas
- Log de actividad automático
- Estadísticas del sistema

## 📊 Características del Panel Web

### Dashboard Principal
- Estadísticas en tiempo real
- Usuarios totales y online
- Estado del servidor
- Acciones rápidas
- Lista de usuarios conectados

### Gestión de Usuarios
- Añadir usuarios dinámicamente
- Eliminar usuarios existentes
- Configuración automática por tipo
- Estados de conexión en tiempo real

### Monitoreo Avanzado
- Gráfico de conexiones en tiempo real
- Log de eventos automático
- Estado detallado de cada usuario
- Información del sistema
- Actualizaciones vía WebSocket

## 🔍 Verificación y Testing

### Script de Verificación Automática
```powershell
.\test_simple.ps1
```

### Verificación Manual
```bash
# Estado de contenedores
docker-compose ps

# Puerto SIP abierto
docker exec asterisk-sip-server netstat -tuln | grep 5060

# Proceso Asterisk activo
docker exec asterisk-sip-server ps aux | grep asterisk
```

## 🚨 Solución de Problemas

### Servidor SIP no inicia
```bash
# Ver logs detallados
docker logs asterisk-sip-server

# Verificar configuración
docker exec asterisk-sip-server cat /etc/asterisk/sip.conf
```

### Panel Web no accesible
```bash
# Verificar logs del servidor web
docker logs asterisk-web-admin

# Verificar puerto 3000
netstat -an | findstr 3000
```

### Usuarios no se conectan
1. Verificar usuarios en el panel web
2. Revisar configuración del cliente
3. Verificar conectividad de red
4. Consultar logs en tiempo real

## 🔐 Seguridad

- Contraseñas seguras por defecto
- Configuración NAT para redes privadas
- Logs de actividad completos
- Usuarios separados por tipo de equipo
- Proceso no privilegiado en contenedores

## 📈 Escalabilidad

- Fácil añadir nuevos usuarios via web
- Configuración modular de Asterisk
- Logs persistentes en volúmenes
- Monitoreo en tiempo real
- API REST para integraciones futuras

## 🎯 Casos de Uso

- **Hogar Inteligente**: Videoporteros con Zoiper
- **Oficinas**: Sistema de intercomunicación
- **Seguridad**: Integración cámaras IP
- **Hoteles**: Comunicación con habitaciones
- **Industria**: Comunicación en plantas

## ✅ Estado Actual

**Sistema completamente funcional y listo para producción**

- ✅ Servidor SIP Asterisk ejecutándose
- ✅ Panel Web Administrativo operativo
- ✅ Usuarios preconfigurados
- ✅ Monitoreo en tiempo real
- ✅ Gestión dinámica de usuarios
- ✅ Compatible con equipos Dahua/Hikvision
- ✅ Optimizado para Zoiper

---

## 📞 Soporte

Para soporte técnico o consultas, revisar:
- Logs del sistema via panel web
- Documentación en `docs/`
- Estado actual en `ESTADO_SERVIDOR.md`