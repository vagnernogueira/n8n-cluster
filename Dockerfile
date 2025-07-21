# Arquivo Dockerfile de exemplo, para casos em que seja necessário
# instalação de módulos da comunidade direto na imagem.
# Este arquivo não está sendo utilizado na execução padrão.
# Para utilizar este arquivo altere o Makefile na goal 'deploy'
# conforme está comentado no arquivo Makefile nessa goal.

FROM n8nio/n8n:latest

USER root

RUN mkdir -p /home/node/.n8n/nodes && \
    chown -R node:node /home/node/.n8n

USER node

WORKDIR /home/node/.n8n/nodes

# Exemplo de módulo a ser instalado na imagem
RUN npm install n8n-nodes-tavily
