# Pego a imagem do docker hub, padrão de imagens
FROM node:20-slim

# Cria um diretório para a aplicação na minha máquina
WORKDIR /usr/src/app

COPY package.json yarn.lock ./
COPY .yarn ./.yarn

#  Dá permissão nas pastas para o usuário node
RUN chown -R node:node /usr/src/app

# Instala o yarn
RUN yarn 

# Copia todos os arquivos da minha máquina para a pasta da aplicação
COPY . .

# Roda o build da aplicação
RUN yarn run build

# Expõe a porta 3000
EXPOSE 3000

# Roda o comando start
CMD ["yarn", "run", "start"]
