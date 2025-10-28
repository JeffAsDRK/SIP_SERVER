# Dockerfile para Servidor SIP Asterisk con Ubuntu 22.04
FROM ubuntu:22.04

LABEL maintainer="SIP Server"
LABEL description="Asterisk SIP Server compatible con Zoiper, Dahua y Hikvision"

# Evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Lima

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    asterisk \
    asterisk-modules \
    asterisk-config \
    asterisk-core-sounds-en \
    asterisk-core-sounds-es \
    asterisk-moh-opsound-wav \
    tzdata \
    nano \
    net-tools \
    iputils-ping \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

# Configurar zona horaria
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Crear directorios necesarios
RUN mkdir -p /var/lib/asterisk/sounds/custom \
    && mkdir -p /var/log/asterisk \
    && mkdir -p /var/spool/asterisk \
    && mkdir -p /etc/asterisk/keys

# Configurar permisos
RUN chown -R asterisk:asterisk /var/lib/asterisk \
    && chown -R asterisk:asterisk /var/log/asterisk \
    && chown -R asterisk:asterisk /var/spool/asterisk \
    && chown -R asterisk:asterisk /etc/asterisk

# Copiar archivos de configuración
COPY config/ /etc/asterisk/

# Exponer puertos necesarios
# 5060 - SIP UDP/TCP
# 10000-10100 - RTP (media)
# 4569 - IAX2
EXPOSE 5060/udp 5060/tcp 10000-10100/udp 4569/udp

# Volúmenes para persistencia
VOLUME ["/var/log/asterisk", "/var/spool/asterisk", "/etc/asterisk"]

# Usuario no root para seguridad
USER asterisk

# Comando de inicio
CMD ["/usr/sbin/asterisk", "-f", "-vvv", "-g", "-c"]