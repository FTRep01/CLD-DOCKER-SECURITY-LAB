# Caso CLD-D02 — Python/Flask hardened

```bash
docker build -t cld-d02-hardened .
docker run -p 5000:5000 \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  -e DB_PASSWORD="${DB_PASSWORD}" \
  cld-d02-hardened
```

Observe: `docker exec -it <container> whoami` retorna `appuser`.
Servidor de produção (`gunicorn`) substitui o servidor de desenvolvimento
do Flask; `FLASK_DEBUG=0` desabilita o console interativo do Werkzeug.
