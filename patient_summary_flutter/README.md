# Patient Summary Flutter - SPDATA SGH iPes

Aplicação Flutter convertida do projeto original HTML/CSS/JavaScript, mantendo todos os estilos, cores, formas e funcionalidades.

## 📱 Sobre o Projeto

Sistema de visualização de sumários de pacientes usando o padrão FHIR (Fast Healthcare Interoperability Resources). A aplicação permite buscar e visualizar dados completos de atendimentos médicos, incluindo diagnósticos, alergias, procedimentos, prescrições e planos de cuidado.

## 🎨 Design Original Preservado

Este projeto Flutter foi convertido mantendo fielmente:

- ✅ **Cores**: Sistema de cores completo baseado no CSS original
- ✅ **Tipografia**: Fonte Inter com os mesmos pesos e tamanhos
- ✅ **Espaçamentos**: Padding, margins e gaps idênticos
- ✅ **Bordas e sombras**: Border-radius e box-shadows preservados
- ✅ **Animações**: Transições e efeitos mantidos
- ✅ **Ícones**: Material Icons como no original
- ✅ **Imagens**: Logo e background preservados

## 🚀 Funcionalidades

### Autenticação
- Tela de login com validação
- Credenciais armazenadas localmente
- Proteção de rotas

**Credenciais de teste:**
- Usuário: `SPDATA`
- Senha: `Spdata@260788#`

### Busca de Pacientes
- Busca por CPF (11 dígitos)
- Validação de entrada
- Indicador de carregamento
- Tratamento de erros

### Visualização de Dados
- **Cards expandíveis** com informações completas
- **Dashboard de estatísticas** (Total de atendimentos, diagnósticos, alergias, procedimentos)
- **Informações do atendimento**: Status, modalidade, datas
- **Diagnósticos**: Código CID-10, descrição, data de registro
- **Alergias**: Substância, categoria, criticidade (alta/média/baixa)
- **Procedimentos**: Código, descrição, data de realização
- **Prescrições**: Medicamentos e dosagens organizadas
- **Evolução clínica**: Resumo do atendimento
- **Plano de cuidados**: Instruções e recomendações

## 🛠️ Tecnologias Utilizadas

- **Flutter 3.32.8**: Framework principal
- **Dart 3.8.1**: Linguagem de programação
- **http**: Requisições HTTP para API FHIR
- **shared_preferences**: Armazenamento local de autenticação
- **provider**: Gerenciamento de estado
- **intl**: Formatação de datas
- **material_design_icons_flutter**: Ícones estendidos

## 📦 Estrutura do Projeto

```
lib/
├── constants/
│   ├── app_colors.dart      # Sistema de cores (baseado no CSS original)
│   └── app_theme.dart        # Tema da aplicação
├── models/
│   └── patient_data.dart     # Modelos de dados FHIR
├── screens/
│   ├── login_screen.dart     # Tela de login
│   └── patient_summary_screen.dart  # Tela principal
├── services/
│   ├── api_service.dart      # Serviço de API FHIR
│   └── auth_service.dart     # Serviço de autenticação
├── widgets/
│   └── patient_card.dart     # Card expandível do paciente
└── main.dart                 # Ponto de entrada da aplicação
```

## 🔧 Instalação e Execução

### Pré-requisitos

- Flutter SDK 3.0 ou superior
- Dart SDK 3.0 ou superior
- Android Studio / VS Code com extensões Flutter
- Emulador Android/iOS ou dispositivo físico

### Passos

1. **Navegue para o diretório do projeto:**
```bash
cd patient_summary_flutter
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Execute a aplicação:**
```bash
flutter run
```

Para executar em um dispositivo específico:
```bash
flutter devices  # Lista dispositivos disponíveis
flutter run -d <device_id>
```

### Compilação

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

## 🔌 Configuração da API

A aplicação está configurada para usar a API FHIR em:
- **Base URL**: `https://dev.ipes.tech`
- **Endpoint**: `/ehrrunner/fhir/1.0.1/Patient/{identifier}/$patientsummary`

As credenciais da API estão configuradas em `lib/services/api_service.dart`.

## 🎨 Sistema de Cores

Baseado no CSS original (`../style.css`):

| Cor | Hex | Uso |
|-----|-----|-----|
| Primary | `#007AFF` | Botões, links, destaques |
| Success | `#28CD59` | Status positivo, confirmações |
| Warning | `#FF9500` | Alertas, pendências |
| Error | `#FF3B30` | Erros, ações destrutivas |
| Info | `#5B55D6` | Informações adicionais |
| Gray 50-1000 | `#EEEEEE` - `#2B2B2B` | Escala de cinzas |

## 📱 Responsividade

A aplicação é totalmente responsiva e se adapta a diferentes tamanhos de tela:
- 📱 **Mobile**: Layout otimizado para smartphones
- 📱 **Tablet**: Aproveita o espaço adicional
- 💻 **Desktop**: Layout expandido com melhor uso do espaço

## 🧪 Testando com Dados Reais

Para testar com um CPF específico:
1. Faça login com as credenciais fornecidas
2. Digite um CPF válido de 11 dígitos (apenas números)
3. Clique em "Buscar"

**Exemplo de CPF para teste:** `36275558806`

## 📝 Notas de Desenvolvimento

### Diferenças do Original HTML

1. **State Management**: Usado `StatefulWidget` ao invés de JavaScript state
2. **Navegação**: Usado `Navigator` do Flutter ao invés de href
3. **Armazenamento**: `shared_preferences` ao invés de `sessionStorage`
4. **HTTP**: Package `http` ao invés de `fetch API`
5. **Animações**: `AnimationController` ao invés de CSS animations

### Melhorias Implementadas

- ✨ Animações suaves nativas do Flutter
- 🔄 Hot reload para desenvolvimento rápido
- 📦 Compilação nativa para melhor performance
- 🎯 Type safety com Dart
- 🧩 Componentização com widgets reutilizáveis

## 🔗 Projeto Original

- Arquivos HTML/CSS/JS originais localizados em: `../`
- `index.html`: Tela de login
- `patient_summary.html`: Tela principal
- `style.css`: Estilos originais

## 📄 Licença

Este projeto mantém a mesma licença do projeto original SPDATA SGH - iPes.

---

**Desenvolvido com Flutter 💙**
