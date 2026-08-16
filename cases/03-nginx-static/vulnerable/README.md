# Caso CLD-D03 — Nginx estático vulnerável

```bash
docker build -t cld-d03-vulnerable .
docker run -p 8080:80 cld-d03-vulnerable
```

Observe: `curl -I localhost:8080` retorna o cabeçalho `Server: nginx/<versão exata>`.
Observe: `docker exec -it <container> whoami` retorna `root`.
