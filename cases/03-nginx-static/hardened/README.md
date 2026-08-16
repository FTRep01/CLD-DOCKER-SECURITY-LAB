# Caso CLD-D03 — Nginx estático hardened

```bash
docker build -t cld-d03-hardened .
docker run -p 8080:8080 \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  cld-d03-hardened
```

Observe: `curl -I localhost:8080` não expõe a versão do Nginx
(`server_tokens off`).
Observe: `docker exec -it <container> whoami` retorna `nginx` (não-root).
