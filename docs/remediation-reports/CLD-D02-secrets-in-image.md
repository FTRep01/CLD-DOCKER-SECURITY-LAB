# CLD-D02 — Segredos embutidos na imagem (ENV/ARG) e debug mode habilitado

**Severidade:** Crítica
**Caso:** `cases/02-python-flask`
**CWE relacionado:** CWE-798 (Use of Hard-coded Credentials), CWE-489 (Active Debug Code)
**Mapeamento:** CIS Docker Benchmark 4.10 · OWASP Docker Top 10 D08

## Descrição
O Dockerfile vulnerável define `DB_PASSWORD` via `ARG`/`ENV` com valor
hardcoded, que fica permanentemente gravado no histórico de layers da
imagem — visível via `docker history` mesmo que a variável não seja mais
usada em runtime. Adicionalmente, a aplicação Flask roda com
`debug=True`, expondo o console interativo do Werkzeug.

## Evidência
```dockerfile
ARG DB_PASSWORD=SuperSecret123
ENV DB_PASSWORD=${DB_PASSWORD}
ENV FLASK_DEBUG=1
```
```bash
$ docker history --no-trunc cld-02-python-flask-vulnerable | grep DB_PASSWORD
# valor aparece em texto plano na layer correspondente
```

## Impacto
- Qualquer pessoa com acesso à imagem (registry, `docker save`, etc.) lê o
  segredo, mesmo sem rodar o container.
- Debug mode ativo pode permitir execução remota de código via console
  Werkzeug, caso o serviço seja exposto acidentalmente.

## Correção aplicada
1. Remoção completa de `ARG`/`ENV` com segredos do Dockerfile.
2. Segredos passam a ser injetados exclusivamente em runtime, via variável
   de ambiente vinda de um secret manager (`docker run -e DB_PASSWORD=...`
   apontando para Vault/Secrets Manager/Kubernetes Secret na prática real).
3. `FLASK_DEBUG=0` e `FLASK_ENV=production` fixados na imagem.
4. Substituição do servidor de desenvolvimento do Flask por `gunicorn`.

## Validação
- `trivy image` (secret scanning): 0 segredos detectados na imagem hardened.
- `docker history --no-trunc cld-02-python-flask-hardened`: nenhuma
  credencial visível.
- Requisição a qualquer rota não retorna mais `process.env`/`os.environ`.

## Referências
- CIS Docker Benchmark, seção 4.10 ("Ensure secrets are not stored in Dockerfiles").
- OWASP Docker Top 10 — D08: Insecure Secrets Management.
