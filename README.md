# iPES Patient Summary

Sistema de visualização de sumário de pacientes usando FHIR API.

## Estrutura do Projeto

- **patient_summary_flutter/** - Aplicação Flutter (frontend)
- **proxy-server/** - Servidor proxy Node.js para resolver CORS

## Proxy Server

### Desenvolvimento Local

```bash
cd proxy-server
npm install
npm start
```

O servidor rodará em `http://localhost:3000`

### Deploy no Render

1. Crie uma conta em [Render](https://render.com)
2. Clique em "New +" → "Web Service"
3. Conecte seu repositório GitHub
4. Configure:
   - **Name**: ipes-proxy-server
   - **Root Directory**: proxy-server
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
5. Clique em "Create Web Service"

Após o deploy, você receberá uma URL como: `https://ipes-proxy-server.onrender.com`

### Configurar Flutter para usar o proxy hospedado

No arquivo `patient_summary_flutter/lib/services/api_service.dart`, altere:

```dart
static const String baseUrl = 'https://ipes-proxy-server.onrender.com';
```

## Flutter App

### Desenvolvimento

```bash
cd patient_summary_flutter
flutter pub get
flutter run -d chrome
```

### Build para Web

```bash
cd patient_summary_flutter
flutter build web
```

Os arquivos gerados estarão em `build/web/`

## Credenciais

As credenciais OAuth estão configuradas no código. Para produção, considere usar variáveis de ambiente.
