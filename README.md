# iPES Patient Summary

Sistema de visualização de sumário de pacientes usando FHIR API.

## 🚀 Demo Online

- **Frontend**: https://fstapf.github.io/iPes-patientSummary/
- **Proxy Server**: https://ipes-proxy-server.onrender.com

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

### Deploy no GitHub Pages

O deploy é feito automaticamente usando git subtree:

```bash
flutter build web --release
git add patient_summary_flutter/build/web
git commit -m "Update web build"
git push origin main
git subtree push --prefix patient_summary_flutter/build/web origin gh-pages
```

O site estará disponível em: `https://SEU_USUARIO.github.io/iPes-patientSummary/`

## ⚙️ Configuração GitHub Pages

Para ativar o GitHub Pages:

1. Acesse: `https://github.com/SEU_USUARIO/iPes-patientSummary/settings/pages`
2. Em **Source**, selecione a branch `gh-pages`
3. Clique em **Save**
4. Aguarde alguns minutos para o deploy

## Credenciais

As credenciais OAuth estão configuradas no código. Para produção, considere usar variáveis de ambiente.

## 📝 Notas Importantes

- O Render (plano gratuito) hiberna após 15min de inatividade
- A primeira requisição após hibernar pode demorar ~30s
- O GitHub Pages pode levar alguns minutos para atualizar após o push
