const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
const PORT = process.env.PORT || 3000;

// Configurar CORS para permitir requisições do Flutter Web
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// URL base da API FHIR
const FHIR_BASE_URL = 'https://dev.ipes.tech';

// Log de requisições
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Endpoint de health check
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'FHIR Proxy Server is running',
    timestamp: new Date().toISOString()
  });
});

// Proxy para OAuth token (suporta /token e /oauth2/token)
app.post(['/token', '/oauth2/token'], async (req, res) => {
  try {
    console.log('🔑 OAuth request received');
    console.log('Headers:', req.headers);
    console.log('Body:', req.body);

    // Obter o body como string
    let bodyData = 'grant_type=client_credentials';
    if (req.body && typeof req.body === 'object') {
      bodyData = Object.keys(req.body).map(key => `${key}=${req.body[key]}`).join('&');
    } else if (typeof req.body === 'string') {
      bodyData = req.body;
    }

    console.log('📤 Sending to FHIR:', bodyData);

    const response = await fetch(`${FHIR_BASE_URL}/token`, {
      method: 'POST',
      headers: {
        'Authorization': req.headers.authorization,
        'Accept': '*/*',
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'Dart/Flutter',
      },
      body: bodyData,
    });

    const data = await response.json();
    console.log('✅ Response from FHIR:', response.status);
    res.status(response.status).json(data);
  } catch (error) {
    console.error('❌ Error in OAuth token:', error);
    res.status(500).json({ error: error.message });
  }
});

// Proxy para requisições FHIR
app.get('/ehrrunner/fhir/*', async (req, res) => {
  try {
    const path = req.path;
    const url = `${FHIR_BASE_URL}${path}`;

    console.log(`Proxying to: ${url}`);
    console.log(`Headers received:`, req.headers);
    console.log(`subject-id: ${req.headers['subject-id']}`);

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': req.headers.authorization,
        'Accept': 'application/fhir+json',
        'subject-id': req.headers['subject-id'],
      },
    });

    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    console.error('Error in FHIR request:', error);
    res.status(500).json({ error: error.message });
  }
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying requests to: ${FHIR_BASE_URL}`);
});
