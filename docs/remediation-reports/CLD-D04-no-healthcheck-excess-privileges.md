# CLD-D04 — Ausência de HEALTHCHECK e privilégios de runtime excessivos

**Severidade:** Média
**Casos:** todos
**CWE relacionado:** CWE-250 (Execution with Unnecessary Privileges), CWE-1188 (Insecure Default Initialization)
**Mapeamento:** CIS Docker Benchmark 4.6 / 5.3 / 5.4 · NIST SP 800-190 seção 4.4

## Descrição
Nenhum Dockerfile vulnerável define `HEALTHCHECK`, dificultando a detecção
automática de containers comprometidos ou travados. Além disso, o stack
vulnerável (`docker-compose.vulnerable.yml`) roda o serviço Node com
`privileged: true` e nenhum serviço restringe capabilities Linux.

## Impacto
- Sem healthcheck, orquestradores (Docker Swarm, Kubernetes) não conseguem
  reiniciar automaticamente um container comprometido/travado, nem
  removê-lo do load balancing.
- `--privileged` concede todas as capabilities Linux e acesso a dispositivos
  do host, viabilizando fuga de container em caso de RCE.

## Correção aplicada
1. `HEALTHCHECK` definido em todos os três Dockerfiles hardened, validando
   um endpoint `/healthz` (ou equivalente) real da aplicação.
2. Remoção total de `privileged: true` do stack hardened.
3. `cap_drop: ALL` em todos os serviços do `docker-compose.hardened.yml`
   (nenhuma capability é reconcedida, pois nenhum serviço precisa dela).
4. `security_opt: no-new-privileges:true` em todos os serviços.
5. `read_only: true` no filesystem raiz do container, com `tmpfs` apenas
   para diretórios que realmente precisam de escrita (`/tmp`, cache do nginx).

## Validação
- `docker inspect` nos containers hardened confirma `Privileged: false` e
  `CapDrop: ["ALL"]`.
- `docker ps` mostra status `healthy` após o `start-period` do healthcheck.

## Referências
- CIS Docker Benchmark, seções 4.6, 5.3 e 5.4.
- NIST SP 800-190, seção 4.4 — Container Runtime Countermeasures.
