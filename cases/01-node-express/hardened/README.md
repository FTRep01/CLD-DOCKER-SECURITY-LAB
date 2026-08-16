# Caso CLD-D01 — Node/Express hardened

```bash
docker build -t cld-d01-hardened .
docker run -p 3000:3000 \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  -e API_KEY="${API_KEY}" \
  cld-d01-hardened
```

Observe: `docker exec -it <container> whoami` retorna `node` (não-root).
Não existe endpoint que exponha `process.env`.
