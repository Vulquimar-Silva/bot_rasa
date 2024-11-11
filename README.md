
# Rasa Training Project

Este README foi desenvolvido para orientar desenvolvedores que estão trabalhando com a ferramenta Rasa pela primeira vez. Ele abrange todos os passos desde a configuração inicial, passando pelo treinamento e execução do bot, até a definição de ações personalizadas.

---

## O que é o Rasa?

O Rasa é uma plataforma de código aberto para construir chatbots e assistentes virtuais inteligentes. Ele permite que você crie e treine modelos de compreensão de linguagem natural (NLU) para interpretar intenções e extrair entidades, além de gerenciar fluxos de diálogo personalizados com políticas e histórias.

---

## Estrutura de Pastas

```plaintext
├── data/
│   ├── nlu.yml               # Dados de treinamento para reconhecimento de intenções e entidades
│   ├── rule.yml              # Regras para respostas específicas e ações diretas
│   └── story.yml             # Histórias de diálogo para aprendizado sequencial de conversas
│
├── models/                   # Modelos treinados são salvos automaticamente nesta pasta
│
├── actions/
│   └── actions.py            # Definições de ações personalizadas do Rasa
│
├── config.yml                # Configura o pipeline de processamento (tokenizer, featurizer, etc.)
├── docker-compose.yml        # Arquivo para execução do projeto com Docker
├── Dockerfile                # Define a imagem Docker com dependências e configuração do ambiente
├── domain.yml                # Define intents, respostas, ações, slots e entidades do bot
├── endpoints.yml             # Configurações de endpoints, como banco de dados e ações personalizadas
└── requirements.txt          # Lista de dependências Python para o projeto
```

## Pré-requisitos

1. **Python**: Certifique-se de estar usando **Python 3.8**. Versões superiores podem causar incompatibilidades com as dependências do projeto.
2. **Docker** e **Docker Compose**: O projeto é configurado para ser executado em contêineres, facilitando a padronização do ambiente.
3. **Rasa**: A versão especificada no projeto é **Rasa 3.6.20** e **Rasa SDK 3.6.2**. Essas versões são essenciais para garantir compatibilidade.
4. **psycopg2-binary**: Versão para integração com PostgreSQL

## Banco de Dados

O projeto utiliza o **PostgreSQL** como banco de dados para armazenamento do tracker (rastreamento de conversas e sessões). A conexão com o banco de dados é configurada no arquivo `endpoints.yml` e utiliza variáveis de ambiente no `docker-compose.yml` para facilitar a configuração. É possível adaptar para outros bancos SQL e NOSQL se necessário, desde que sejam feitas as devidas configurações.

### Configuração do Banco de Dados no `docker-compose.yml`

```yaml
- `DB_HOST`: Configurado como `postgres` (nome do serviço do banco)
- `DB_PORT`: Porta do banco de dados, definida como `5432`
- `DB_USER`: Usuário do banco (`rasa_training`)
- `DB_PASSWORD`: Senha do banco (`L8Rasa2024`)
- `DB_DATABASE`: Nome do banco de dados (`rasa_db`)
```

### Configurações do PostgreSQL no `endpoints.yml`

```yaml
tracker_store:
  type: SQL
  dialect: "postgresql"          # Dialeto usado pelo SQLAlchemy
  url: ${DB_HOST}                # Nome do serviço PostgreSQL (definido no docker-compose.yml)
  port: ${DB_PORT}               # Porta padrão do PostgreSQL (5432)
  username: ${DB_USER}           # Usuário do banco de dados
  password: ${DB_PASSWORD}       # Senha do banco de dados
  db: ${DB_DATABASE}             # Nome do banco de dados
  login_db: "postgres"           # Banco de login padrão
```

## Serviços Iniciados pelo Docker

Quando você inicia o projeto, três serviços são criados automaticamente pelo Docker Compose:

1. **Rasa**: Serviço principal do chatbot, configurado para treinar e executar o modelo.
2. **PostgreSQL**: Banco de dados para armazenamento do tracker, utilizado para rastreamento e gerenciamento de sessões.
3. **Action Server**: Servidor de ações personalizadas (`actions/`), que permite ao bot realizar operações customizadas, como chamadas a APIs ou operações de lógica de negócios.

## Como Executar o Projeto

1. Clone o repositório para sua máquina local.

   ```bash
   git clone <URL_DO_REPOSITORIO>
   ```

2. Navegue até o diretório do projeto.

3. Execute o comando para iniciar o ambiente Docker, que configura todos os serviços:

   ```bash
   docker-compose up -d --build
   ```

4. Para treinar o modelo, execute:

   ```bash
   docker-compose exec rasa rasa train
   ```

5. Para interagir com o bot, utilize o comando:

   ```bash
   docker-compose exec rasa rasa shell
   ```

## Configuração de Ações Personalizadas

O diretório `actions/` contém o arquivo `actions.py`, onde você pode definir ações personalizadas para o bot. Ações personalizadas permitem que o bot execute código Python para responder a intenções específicas ou realizar operações complexas, como interagir com APIs externas ou acessar bancos de dados.

### Exemplo de uma Ação Personalizada

No arquivo `actions.py`, você pode definir uma ação personalizada da seguinte forma:

```python
from rasa_sdk import Action
from rasa_sdk.events import SlotSet

class ActionExample(Action):
    def name(self):
        return "action_example"

    def run(self, dispatcher, tracker, domain):
        dispatcher.utter_message(text="Esta é uma ação personalizada!")
        return [SlotSet("example_slot", "valor_exemplo")]
```

Após definir as ações personalizadas, certifique-se de listar `action_example` no arquivo `domain.yml` para que o bot possa reconhecê-la.

## Estrutura dos Arquivos Principais

- **domain.yml**: Define as intents, respostas, ações e entidades do bot.

  ```yaml
  intents:
    - greet
    - goodbye
  responses:
    utter_greet:
      - text: "Olá! Como posso ajudar?"
  ```

- **nlu.yml**: Contém exemplos de intenções e entidades para o modelo de NLU.

  ```yaml
  version: "3.1"
  nlu:
    - intent: greet
      examples: |
        - olá
        - oi
        - bom dia
  ```

- **rule.yml**: Define regras específicas para respostas automáticas.

  ```yaml
  version: "3.1"
  rules:
    - rule: Responder a um cumprimento
      steps:
        - intent: greet
        - action: utter_greet
  ```

- **story.yml**: Histórias que treinam o bot em diálogos mais complexos.

  ```yaml
  version: "3.1"
  stories:
    - story: saudação
      steps:
        - intent: greet
        - action: utter_greet
  ```

- **config.yml**: Configura o pipeline de processamento e políticas do modelo.

  ```yaml
  language: "pt"
  pipeline:
    - name: "WhitespaceTokenizer"
    - name: "CountVectorsFeaturizer"
    - name: "DIETClassifier"
  policies:
    - name: "MemoizationPolicy"
  ```

- **endpoints.yml**: Configura os endpoints do projeto, incluindo o servidor de ações.

## Consumindo a API do Rasa

O Rasa oferece uma API HTTP REST que permite interagir com o chatbot de maneira programática, possibilitando o envio de mensagens, gerenciamento de sessões e rastreamento de eventos de conversa. Abaixo estão as instruções detalhadas para o consumo da API, com exemplos práticos e profissionais.

### Endereço da API

Por padrão, a API do Rasa estará disponível em `http://localhost:5006` quando o contêiner Docker estiver em execução, conforme configurado no `docker-compose.yml`.

### Endpoints Principais

1. **Enviar Mensagens para o Chatbot**

   Este endpoint permite o envio de mensagens ao chatbot para obter respostas em tempo real, sendo ideal para testes de fluxo de conversação.

   - **Método**: `POST`
   - **Endpoint**: `/webhooks/rest/webhook`
   - **Exemplo de Requisição**:

     ```json
     {
       "sender": "usuario_123",
       "message": "Oi, tudo bem?"
     }
     ```

   - **Exemplo de Resposta**:

     ```json
     [
       {
         "recipient_id": "usuario_123",
         "text": "Olá! Como posso ajudar?"
       }
     ]
     ```

2. **Obter o Histórico de Conversas**

   Esse endpoint permite a recuperação do histórico completo de conversas de um usuário específico, permitindo o rastreamento dos eventos de interação.

   - **Método**: `GET`
   - **Endpoint**: `/conversations/<sender_id>/tracker`
   - **Exemplo de URL Completa**: `http://localhost:5006/conversations/usuario_123/tracker`
   - **Uso**: Substitua `<sender_id>` pelo identificador único do usuário.

3. **Resetar a Conversa**

   Este endpoint redefine o histórico de conversas de um usuário específico, limpando o estado atual entre sessões de interação.

   - **Método**: `POST`
   - **Endpoint**: `/conversations/<sender_id>/tracker/events`
   - **Corpo da Requisição**:

     ```json
     {
       "event": "restart"
     }
     ```

4. **Servidor de Ações Personalizadas**

   O servidor de ações personalizadas permite que o chatbot execute código adicional para responder a intenções específicas ou realizar operações complexas. Abaixo estão as instruções para configurar e acessar o servidor de ações em dois contextos: localmente e no Docker.

   #### Acesso Local (Fora do Docker)

   Quando o projeto é executado localmente, o servidor de actions é acessível em `http://localhost:5055/webhook`.

   - **URL do Servidor de Ações**: `http://localhost:5055/webhook`
   - **Uso**: Esse endpoint é usado internamente pelo Rasa para executar ações personalizadas definidas no arquivo `actions.py`. Geralmente, você não precisa interagir diretamente com o servidor de actions via API REST, pois ele é chamado automaticamente durante as interações do chatbot.

   #### Acesso no Docker (Comunicação entre Contêineres)

   No contexto do Docker, o serviço de actions é configurado para ser acessível pelo nome do serviço no `docker-compose.yml`, que geralmente é `action_server`. Isso permite a comunicação entre o contêiner do Rasa e o servidor de actions.

   - **URL do Servidor de Ações no Docker**: `http://action_server:5055/webhook`
   - **Uso**: Dentro do contêiner do Rasa, configure o endpoint do servidor de actions como `http://action_server:5055/webhook` no arquivo `endpoints.yml`. Esse endereço usa o nome do serviço configurado no `docker-compose.yml`, permitindo que o Rasa se conecte ao servidor de actions sem necessidade de um endereço de rede externo.

   - **Exemplo de Configuração no `endpoints.yml`**:

     ```yaml
     action_endpoint:
       url: "http://action_server:5055/webhook"
     ```

   Essa configuração garante que o contêiner do Rasa possa se comunicar com o servidor de actions usando o nome do serviço `action_server`, evitando problemas de rede no ambiente Docker.

### Exemplo de Consumo da API Usando `curl`

Aqui estão exemplos de comandos `curl` para interagir com a API do Rasa:

```bash
# Enviar uma mensagem para o chatbot
curl -X POST http://localhost:5006/webhooks/rest/webhook      -H "Content-Type: application/json"      -d '{"sender": "usuario_123", "message": "Oi, tudo bem?"}'

# Obter o histórico de conversa
curl -X GET http://localhost:5006/conversations/usuario_123/tracker

# Resetar a conversa
curl -X POST http://localhost:5006/conversations/usuario_123/tracker/events      -H "Content-Type: application/json"      -d '{"event": "restart"}'
```

### Consumindo a API com Postman

Para uma experiência mais amigável, recomendamos o uso do **Postman** para consumir a API:

1. **Configurar a URL Base**: Defina `http://localhost:5006` como URL base no Postman.
2. **Enviar Mensagens**: Crie uma requisição `POST` para o endpoint `/webhooks/rest/webhook`, configure o corpo com o JSON conforme o exemplo e envie a mensagem para o chatbot.
3. **Recuperar Histórico de Conversas**: Crie uma requisição `GET` para o endpoint `/conversations/<sender_id>/tracker` para obter o histórico completo de interação de um usuário.
4. **Resetar Conversa**: Crie uma requisição `POST` para `/conversations/<sender_id>/tracker/events`, com o corpo contendo o evento de `restart` para limpar o estado da conversa.

---

## Documentação Adicional

Para mais detalhes sobre as funcionalidades avançadas do Rasa, consulte a [Documentação Oficial do Rasa](https://rasa.com/docs/rasa).

---
