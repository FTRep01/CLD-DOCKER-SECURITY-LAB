# CLD-D01 — Container executando como root, sem usuário dedicado

**Severidade:** Alta
**Caso:** `cases/01-node-express`
**CWE relacionado:** CWE-250 (Execution with Unnecessary Privileges)
**Mapeamento:** CIS Docker Benchmark 4.1 · NIST SP 800-190 seção 4.4.1

## Descrição
O Dockerfile vulnerável não define nenhuma instrução `USER`, então o
processo principal roda como `root` (UID 0) dentro do container. Combinado
com a flag `--privileged` sugerida no README do caso, isso amplia
drasticamente o impacto de qualquer RCE na aplicação.

## Evidência
```dockerfile
FROM node:14
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "server.js"]
# nenhuma linha "USER ..."
```
```bash
$ docker exec -it cld-01-node-express-vulnerable whoami
root
```

## Impacto
- Um RCE na aplicação (ex.: dependência vulnerável) resulta em root dentro
  do container.
- Combinado com `--privileged` ou capabilities excessivas, viabiliza fuga
  de container e comprometimento do host.

## Correção aplicada
1. Multi-stage build; etapa final usa `USER node` (usuário não-root já
   presente na imagem oficial `node:20-alpine`).
2. Recomendação de runtime: `--cap-drop=ALL`, `--security-opt=no-new-privileges`,
   `--read-only` (aplicado em `docker-compose.hardened.yml`).
3. Nenhuma flag `--privileged` em nenhum lugar da stack hardened.

## Validação
- `docker exec -it cld-01-node-express-hardened whoami` → `node`.
- `trivy config` / `hadolint`: nenhum finding de "missing USER instruction".

## Referências
- CIS Docker Benchmark, seção 4.1 ("Ensure a user for the container has been created").
- NIST SP 800-190 — Application Container Security Guide.
