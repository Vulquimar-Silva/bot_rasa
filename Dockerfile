# Use a imagem oficial do Rasa
FROM rasa/rasa:3.6.20

# Defina o diretório de trabalho
WORKDIR /app

# Copie todos os arquivos necessários
COPY . /app

# Utilize o usuário root para instalar os requisitos e configurar permissões
USER root

# Ajuste permissões para os arquivos de configuração e diretórios de dados
RUN chmod -R 755 /app && \
    chmod 666 /app/config.yml && \
    chmod 666 /app/endpoints.yml

# Instale as dependências do arquivo requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Retorne ao usuário padrão
USER 1001

# Comando padrão para iniciar o Rasa
CMD ["rasa", "run", "--enable-api", "--cors", "*"]
