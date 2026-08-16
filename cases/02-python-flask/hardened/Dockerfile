# CLD-D02 :: Dockerfile CORRIGIDO (hardened) — Python/Flask
# Contramedidas:
#   1) Imagem slim + versão suportada (python:3.12-slim)
#   2) requirements.txt com versões travadas, instalado com --no-cache-dir
#   3) Nenhum segredo em ARG/ENV — injetado em runtime
#   4) Usuário não-root dedicado (appuser)
#   5) FLASK_DEBUG desabilitado, servidor WSGI de produção (gunicorn)
#   6) HEALTHCHECK definido
#   7) Multi-stage para não carregar ferramentas de build na imagem final

# ---- Etapa de build ----
FROM python:3.12-slim AS build
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Etapa final ----
FROM python:3.12-slim AS runtime
WORKDIR /app

RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

COPY --from=build /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

ENV PATH=/home/appuser/.local/bin:$PATH \
    FLASK_ENV=production \
    FLASK_DEBUG=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0) if urllib.request.urlopen('http://127.0.0.1:5000/healthz').status==200 else sys.exit(1)"

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
