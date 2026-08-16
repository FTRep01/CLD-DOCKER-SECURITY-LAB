# CLD-D03 :: Dockerfile CORRIGIDO (hardened) — Nginx estático
# Contramedidas:
#   1) Versão fixada (nginx:1.27-alpine), não "latest"
#   2) Imagem "unprivileged" oficial do Nginx (roda como usuário nginx, porta 8080)
#   3) .dockerignore evita copiar .git e arquivos irrelevantes
#   4) server_tokens off (não vaza versão do Nginx)
#   5) HEALTHCHECK definido
#   6) Filesystem somente leitura possível em runtime (ver docker-compose.hardened.yml)

FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/index.html

# A imagem "nginx-unprivileged" já roda como usuário nginx (não-root)
# e escuta na porta 8080 por padrão.
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
