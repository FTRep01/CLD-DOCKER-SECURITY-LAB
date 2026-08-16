# CLD-D03 :: Dockerfile INSEGURO — Nginx estático
# Problemas intencionais:
#   1) Tag "latest" (build não reprodutível, versão desconhecida/pode mudar)
#   2) Roda como root, exposto na porta privilegiada 80 dentro do container
#   3) Copia todo o contexto de build (inclusive arquivos de config sensíveis
#      e o .git do projeto do site) para dentro da imagem
#   4) Sem HEALTHCHECK
#   5) Server tokens do Nginx habilitados (vaza versão exata para atacantes)

FROM nginx:latest

COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
