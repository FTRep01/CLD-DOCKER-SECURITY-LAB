# Demonstração: detectando uma cadeia de ataque (CLD-D-CHAIN-01)

> Objetivo didático: mostrar como más práticas de containerização,
> isoladamente pequenas, se encadeiam até um comprometimento do host —
> e como cada estágio é detectado por scanners antes do deploy.

## Cenário

Alvo: `docker-compose.vulnerable.yml`, especificamente `python-flask-vuln`
com `node-express-vuln` como pivô.

```
[1] Reconhecimento              [2] Execução remota de código
 /debug/env e /config      --->  Flask debug=True exposto
 vazam segredos (CLD-D02)        (console Werkzeug -> RCE) (CLD-D02)
        |                                    |
        v                                    v
[3] Confirmação de privilégios       [4] Fuga de container
 processo roda como root       --->  container iniciado com
 dentro do container (CLD-D01)       --privileged (CLD-D01) permite
                                      montar /dev do host e escalar
                                      para o host Docker
        |
        v
[5] Persistência não detectada
 imagem base desatualizada (node:14 / python:3.9) sem inventário de
 CVEs conhecido -> equipe de segurança não tinha visibilidade prévia
 do risco (CLD-D03)
```

## Passo a passo

1. **Reconhecimento (CLD-D02).** O endpoint `/config` do serviço Flask
   vazador retorna `DB_PASSWORD` diretamente em JSON — nenhuma autenticação
   é exigida.

2. **Execução remota de código (CLD-D02).** Com `FLASK_DEBUG=1`, se o
   serviço Flask ficar acessível externamente (ex.: atrás de um proxy mal
   configurado), o console interativo do Werkzeug pode ser abusado para
   executar código Python arbitrário dentro do container.

3. **Confirmação de privilégios (CLD-D01).** O atacante roda `id` dentro do
   shell obtido e confirma que está como `root` (UID 0) — nenhuma instrução
   `USER` foi definida no Dockerfile do serviço Node.

4. **Fuga de container (CLD-D01).** O serviço Node foi iniciado com a flag
   `--privileged` (ver `docker-compose.vulnerable.yml`). Combinado com root
   dentro do container, isso permite montar dispositivos do host e, em
   cenários reais, escalar para controle total do host Docker.

5. **Persistência não detectada (CLD-D03).** As imagens base (`node:14`,
   `python:3.9`) já estão fora do ciclo de suporte, com dezenas de CVEs
   conhecidas nunca corrigidas — sem um pipeline de scan contínuo, esse
   débito técnico fica invisível até ser explorado.

## Como este repositório detecta cada estágio

| Estágio | Ferramenta | Resultado esperado |
|---|---|---|
| 1 – Vazamento de segredo em endpoint | `trivy image` (secret scanning na imagem/ENV) | Finding `secret` no relatório vulnerável |
| 2 – Debug mode / RCE | `hadolint` (DL3000 series) + revisão manual do relatório CLD-D0X | Comentado no relatório de remediação |
| 3 – Root no container | `trivy config` / `hadolint` (missing USER) | Finding de misconfiguration |
| 4 – `--privileged` | Revisão de `docker-compose.vulnerable.yml` (nunca usar em produção) | Documentado explicitamente no compose |
| 5 – Imagem base desatualizada | `trivy image` (CVE scanning de SO) | Dezenas de CRITICAL/HIGH no relatório vulnerável |

Rodando os mesmos scanners contra `docker-compose.hardened.yml` — imagens
`alpine`/`slim` atualizadas, usuários não-root, `cap_drop: ALL`,
`read_only: true`, sem `--privileged` — a cadeia inteira deixa de existir
porque cada elo foi corrigido individualmente (ver
`docs/remediation-reports/`).

## Reproduzindo localmente

```bash
# 1. Build e scan do stack vulnerável
docker compose -f docker-compose.vulnerable.yml build
bash scanning/run-trivy.sh

# 2. Compare com o stack hardened
docker compose -f docker-compose.hardened.yml build
bash scanning/run-trivy.sh

# 3. Lint estático dos Dockerfiles
bash tests/run-hadolint.sh
```
