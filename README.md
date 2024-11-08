
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

## Documentação Adicional

Para mais detalhes sobre as funcionalidades avançadas do Rasa, consulte a [Documentação Oficial do Rasa](https://rasa.com/docs/rasa).

---
