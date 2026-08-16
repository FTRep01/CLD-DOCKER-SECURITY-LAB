# Caso CLD-D02 — Python/Flask vulnerável

```bash
docker build -t cld-d02-vulnerable .
docker run -p 5000:5000 cld-d02-vulnerable
```

Observe: `curl localhost:5000/config` vaza `DB_PASSWORD`.
Observe: `docker history cld-d02-vulnerable` revela o valor do `ARG DB_PASSWORD`
mesmo que a variável não fosse usada em runtime — segredos em build args
persistem no histórico de layers.
