# Stage 1 - Build
FROM node:20 AS build

# Habilitar Corepack para Yarn Berry (v4)
RUN corepack enable

# Forçar o uso de node_modules (em vez de Plug'n'Play)
RUN yarn config set nodeLinker node-modules

# Limpar o cache do Yarn para evitar problemas com dependências
RUN yarn cache clean

# Cria um diretório para a aplicação na máquina
WORKDIR /usr/src/app

# Copiar todos os arquivos necessários para a build (incluindo package.json, yarn.lock, etc.)
COPY . .

# Ajusta as permissões para o usuário 'node'
RUN chown -R node:node /usr/src/app

# Instala todas as dependências usando Yarn v4
RUN yarn install --immutable --check-cache --inline-builds

# Verificar se o node_modules foi corretamente criado
RUN ls -la node_modules

# Executa o build da aplicação
RUN yarn run build

# Instala todas as dependências usando Yarn v4
RUN yarn workspaces focus --production && yarn cache clean

# Stage 2 - Produção
FROM node:20-alpine3.20

# Habilitar Corepack para Yarn Berry (v4)
RUN corepack enable

# Cria o diretório de trabalho no ambiente de produção
WORKDIR /usr/src/app

# Copia os arquivos de build e as dependências de produção do estágio anterior
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

# Expõe a porta 3000
EXPOSE 3000

# Inicia a aplicação
CMD ["yarn", "run", "start:prod"]
