# Checklist de hardening de containers (resumo aplicado neste repositório)

- [ ] Imagem base fixada por versão (idealmente por digest SHA256), nunca `latest`.
- [ ] Usar variantes `alpine`/`slim`/distroless quando possível.
- [ ] `USER` não-root definido explicitamente.
- [ ] Nenhum segredo em `ENV`/`ARG`/camadas da imagem — injetar em runtime.
- [ ] `.dockerignore` presente, excluindo `.git`, `node_modules`, `.env`.
- [ ] Multi-stage build: ferramentas de build não chegam à imagem final.
- [ ] Dependências instaladas com lockfile determinístico
      (`npm ci`, `pip install -r requirements.txt` com versões travadas).
- [ ] `HEALTHCHECK` definido.
- [ ] Sem flags de debug/desenvolvimento habilitadas em produção.
- [ ] Runtime: `--read-only`, `--cap-drop=ALL`, `--security-opt=no-new-privileges`.
- [ ] Nunca usar `--privileged` fora de casos excepcionais e documentados.
- [ ] Scan de vulnerabilidades (Trivy/Grype) integrado ao pipeline de CI.
- [ ] Lint estático de Dockerfile (hadolint) integrado ao pipeline de CI.
