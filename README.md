# PrecedentIA - Interface Mobile

Interface mobile do sistema **PrecedentIA**, desenvolvida em
Flutter, responsável por fornecer uma experiência rápida e intuitiva
para busca e visualização de precedentes jurídicos.

## 🚀 Tecnologias Utilizadas

O projeto utiliza as seguintes tecnologias e bibliotecas:

- **Flutter** - Framework para desenvolvimento mobile multiplataforma
- **Flutter Animate** - Pacote para criação de animações modernas e fluidas na interface
- **Bloc** - Gerenciamento de estado baseado em arquitetura reativa
- **Dio** - Cliente HTTP robusto para comunicação com a API
- **Flutter Secure Storage** - Armazenamento seguro de dados
 sensíveis
- **Hive** - Banco de dados NoSQL leve para armazenamento local
- **Flutter Test** - Suite de testes nativa do Flutter para testes unitários e de widget

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture**, utilizando **Bloc** para gerenciamento de estado. Essa abordagem separa o sistema em camadas bem definidas, garantindo
baixo acoplamento, alta testabilidade e facilidade de
manutenção

A estrutura do projeto é organizada da seguinte forma:

    lib/
     ├── core/
     ├── data/
     │   ├── datasources/
     │   ├── models/
     │   └── repositories/
     ├── domain/
     │   ├── entities/
     │   ├── repositories/
     │   └── usecases/
     ├── presentation/
     │   ├── blocs/
     │   ├── screens/
     │   └── widgets/
     ├── app.dart
     └── main.dart
     

### Camadas da Arquitetura

**Core** - Contém as configurações globais, utilidades e constantes

**Domain** - Contém as regras de negócio da aplicação, define entidades, contratos de repositórios e casos de uso, não depende de nenhuma outra camada

**Data** - Implementa os contratos definidos na camada Domain, responsável pela comunicação com APIs, banco local (Hive) ou outras fontes de dados

**Presentation** - Responsável pela interface do usuário, gerenciamento de estado utilizando Bloc, contém telas, widgets e lógica de interação com o usuário

Essa separação garante que a lógica de negócio permaneça independente da interface e das implementações externas tornando o projeto mais escalável e fácil de testar

## ⚙️ Rodando o Projeto

### 1️⃣ Verifique o ambiente Flutter

Execute o comando abaixo para garantir que todas as dependências estão configuradas corretamente:

``` bash
flutter doctor -v
```

### 2️⃣ Instale as dependências

``` bash
flutter pub get
```

### 3️⃣ Execute o aplicativo

``` bash
flutter run
```

O Flutter irá compilar e executar o aplicativo no emulador ou
dispositivo conectado.

## 🧪 Rodando os testes

Para executar a suite de testes do projeto:

``` bash
flutter test
```

## 📦 Build do aplicativo

### Android

``` bash
flutter build apk
```

ou

``` bash
flutter build appbundle
```

### iOS

``` bash
flutter build ios
```