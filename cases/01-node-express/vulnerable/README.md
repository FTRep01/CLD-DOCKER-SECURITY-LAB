# Caso CLD-D01 — Node/Express vulnerável

Build e execução (apenas para observação/scan em ambiente isolado):

```bash
docker build -t cld-d01-vulnerable .
docker run -p 3000:3000 --privileged cld-d01-vulnerable
```

Observe: `docker exec -it <container> whoami` retorna `root`.
Observe: `curl localhost:3000/debug/env` vaza `API_KEY` e `DB_PASSWORD`.
