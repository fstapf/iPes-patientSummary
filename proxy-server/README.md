# FHIR Proxy Server

Servidor proxy simples para resolver problemas de CORS ao acessar a API FHIR do iPes.

## Como usar localmente

### 1. Instalar dependências
```bash
cd proxy-server
npm install
```

### 2. Iniciar o servidor
```bash
npm start
```

O servidor estará rodando em `http://localhost:3000`

### 3. Configurar o Flutter para usar o proxy

No arquivo `lib/services/api_service.dart`, altere a URL base:

```dart
// Era:
static const String _baseUrl = 'https://dev.ipes.tech:9444';

// Muda para:
static const String _baseUrl = 'http://localhost:3000';
```

## Como hospedar (Deploy gratuito)

### Opção 1: Render (Recomendado)
1. Crie conta em https://render.com
2. New → Web Service
3. Conecte ao repositório GitHub
4. Configure:
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Deploy!

URL ficará: `https://seu-app.onrender.com`

### Opção 2: Railway
1. Crie conta em https://railway.app
2. New Project → Deploy from GitHub
3. Selecione o repositório
4. Railway detecta automaticamente Node.js e faz deploy

### Opção 3: Vercel
1. Crie conta em https://vercel.com
2. Import Project do GitHub
3. Configure Root Directory: `proxy-server`
4. Deploy

## Atualizar Flutter após deploy

No `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'https://seu-proxy.onrender.com';
```

## Ambiente de desenvolvimento

Para desenvolvimento com auto-reload:
```bash
npm run dev
```
