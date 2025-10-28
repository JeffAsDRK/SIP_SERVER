const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs-extra');
const { exec } = require('child_process');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

const PORT = process.env.PORT || 3000;

// Configuración
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Rutas principales
app.get('/', (req, res) => {
    res.render('layout', { 
        title: 'Asterisk SIP Server - Dashboard',
        page: 'dashboard'
    });
});

app.get('/users', async (req, res) => {
    try {
        const users = await getSipUsers();
        res.render('layout', { 
            title: 'Gestión de Usuarios SIP',
            page: 'users',
            users: JSON.stringify(users)
        });
    } catch (error) {
        res.render('layout', { 
            title: 'Gestión de Usuarios SIP',
            page: 'users',
            users: JSON.stringify([]),
            error: 'Error cargando usuarios: ' + error.message
        });
    }
});

app.get('/monitoring', (req, res) => {
    res.render('layout', { 
        title: 'Monitoreo en Tiempo Real',
        page: 'monitoring'
    });
});

// API Endpoints
app.get('/api/status', async (req, res) => {
    try {
        const status = await getServerStatus();
        res.json(status);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/peers', async (req, res) => {
    try {
        const peers = await getSipPeers();
        res.json(peers);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/users', async (req, res) => {
    try {
        const users = await getSipUsers();
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/users', async (req, res) => {
    try {
        const { username, password, type, description } = req.body;
        
        if (!username || !password) {
            return res.status(400).json({ error: 'Usuario y contraseña son requeridos' });
        }

        await addSipUser(username, password, type || 'general', description || '');
        res.json({ success: true, message: 'Usuario creado exitosamente' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/users/:username', async (req, res) => {
    try {
        const { username } = req.params;
        await removeSipUser(username);
        res.json({ success: true, message: 'Usuario eliminado exitosamente' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/reload', async (req, res) => {
    try {
        await reloadAsterisk();
        res.json({ success: true, message: 'Configuración recargada' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Funciones auxiliares
async function getServerStatus() {
    return new Promise((resolve, reject) => {
        // Simular verificación del estado ya que estamos dentro del contenedor
        // En producción, esto podría conectarse via AMI o verificar procesos locales
        resolve({
            status: 'running',
            uptime: 'Activo',
            timestamp: new Date().toISOString()
        });
    });
}

async function getSipPeers() {
    return new Promise((resolve, reject) => {
        // Simular usuarios conectados para el demo
        // En producción real, esto se conectaría al AMI de Asterisk
        const mockPeers = [
            {
                name: '1001',
                host: '192.168.1.100',
                port: '5060',
                status: 'OK (10 ms)',
                lastSeen: new Date().toLocaleString()
            },
            {
                name: '2001',
                host: '192.168.1.101',
                port: '5060',
                status: 'UNREACHABLE',
                lastSeen: new Date().toLocaleString()
            }
        ];
        
        resolve(mockPeers);
    });
}

async function getSipUsers() {
    try {
        // Usuarios por defecto del sistema
        const defaultUsers = [
            { username: '1001', type: 'zoiper', description: 'Usuario Zoiper - Extensión 1001' },
            { username: '1002', type: 'zoiper', description: 'Usuario Zoiper - Extensión 1002' },
            { username: '2001', type: 'dahua', description: 'Usuario Dahua - Extensión 2001' },
            { username: '2002', type: 'dahua', description: 'Usuario Dahua - Extensión 2002' },
            { username: '3001', type: 'hikvision', description: 'Usuario Hikvision - Extensión 3001' },
            { username: '3002', type: 'hikvision', description: 'Usuario Hikvision - Extensión 3002' }
        ];
        
        return defaultUsers;
    } catch (error) {
        return [];
    }
}

async function addSipUser(username, password, type, description) {
    // Simular añadir usuario
    // En producción real, esto modificaría el archivo sip.conf y recargaría Asterisk
    console.log(`Usuario añadido: ${username} (${type}) - ${description}`);
    await reloadAsterisk();
}

async function removeSipUser(username) {
    // Simular eliminación de usuario
    // En producción real, esto modificaría el archivo sip.conf y recargaría Asterisk
    console.log(`Usuario eliminado: ${username}`);
    await reloadAsterisk();
}

async function reloadAsterisk() {
    return new Promise((resolve, reject) => {
        // Simular recarga exitosa
        // En producción real, esto se conectaría al AMI de Asterisk
        setTimeout(() => {
            resolve('Asterisk configuration reloaded successfully');
        }, 1000);
    });
}

// WebSocket para actualizaciones en tiempo real
io.on('connection', (socket) => {
    console.log('Cliente conectado:', socket.id);
    
    socket.on('requestStatus', async () => {
        try {
            const status = await getServerStatus();
            const peers = await getSipPeers();
            socket.emit('statusUpdate', { status, peers });
        } catch (error) {
            socket.emit('error', { message: error.message });
        }
    });
    
    socket.on('disconnect', () => {
        console.log('Cliente desconectado:', socket.id);
    });
});

// Actualización automática cada 10 segundos
setInterval(async () => {
    try {
        const status = await getServerStatus();
        const peers = await getSipPeers();
        io.emit('statusUpdate', { status, peers });
    } catch (error) {
        console.error('Error en actualización automática:', error);
    }
}, 10000);

server.listen(PORT, () => {
    console.log(`🚀 Servidor web administrativo ejecutándose en http://localhost:${PORT}`);
    console.log(`📊 Dashboard: http://localhost:${PORT}`);
    console.log(`👥 Gestión de usuarios: http://localhost:${PORT}/users`);
    console.log(`📡 Monitoreo: http://localhost:${PORT}/monitoring`);
});