# CLD-D01 :: Dockerfile CORRIGIDO (hardened) — Node/Express
# Contramedidas aplicadas (ver docs/remediation-reports/CLD-D01-root-user.md):
#   1) Multi-stage build + imagem base mínima (alpine), versão LTS atual
#      Em produção, recomenda-se fixar por digest:
#      FROM node:20-alpine@sha256:<digest-obtido-via-docker-pull-e-inspect>
#   2) Usuário não-root dedicado (USER node, já presente na imagem oficial)
#   3) Nenhum segredo na imagem — injetado em runtime via secret manager
#   4) .dockerignore evita copiar .git, node_modules, .env
#   5) npm ci com lockfile (build determinístico) e --omit=dev
#   6) HEALTHCHECK definido
#   7) Filesystem somente leitura + capabilities dropadas (ver docker-compose.hardened.yml)

# ---- Etapa de build (contém devDependencies, ferramentas de build) ----
FROM node:20-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY --chown=node:node . .
# Caso houvesse etapa de transpilação/build, entraria aqui:
# RUN npm run build

# ---- Etapa final (somente runtime, sem ferramentas de build) ----
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build --chown=node:node /app/server.js ./server.js

# (2) Usuário não-root explícito
USER node

EXPOSE 3000

# (6) Healthcheck ativo
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:3000/healthz', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "server.js"]
