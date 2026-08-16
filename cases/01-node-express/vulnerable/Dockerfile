# CLD-D01 :: Dockerfile INSEGURO — Node/Express
# Problemas intencionais (ver docs/remediation-reports/CLD-D01-root-user.md e
# CLD-D03-outdated-base-image.md):
#   1) Imagem base genérica e desatualizada (node:14) com dezenas de CVEs conhecidas
#   2) Roda como root (usuário padrão da imagem)
#   3) Segredo hardcoded na imagem (ficará em uma layer do histórico)
#   4) COPY . . copia tudo, incluindo .git, .env, node_modules locais
#   5) Sem HEALTHCHECK
#   6) npm install (não usa lockfile -> builds não reprodutíveis) e sem --production
#   7) Container roda com --privileged nas instruções de uso (ver README)

FROM node:14

WORKDIR /app

# (3) Segredo hardcoded — nunca faça isso, mesmo em ENV
ENV API_KEY="sk_live_51Hxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
ENV DB_PASSWORD="SuperSecret123"

# (4) Copia tudo, sem .dockerignore
COPY . .

# (6) install genérico, sem lockfile determinístico, inclui devDependencies
RUN npm install

EXPOSE 3000

# (2) Nenhum USER definido -> processo roda como root (UID 0) dentro do container
CMD ["node", "server.js"]
