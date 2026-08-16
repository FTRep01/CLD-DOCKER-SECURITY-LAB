# CLD-D02 :: Dockerfile INSEGURO — Python/Flask
# Problemas intencionais:
#   1) Imagem base "python:3.9" (EOL próximo, muitas CVEs de SO acumuladas)
#   2) pip install sem hash pinning, sem requirements travado por versão exata
#   3) Segredo de banco de dados hardcoded na imagem via ARG->ENV (fica no histórico)
#   4) Roda como root
#   5) Debug mode do Flask habilitado (permite RCE via console Werkzeug se exposto)
#   6) Sem HEALTHCHECK, sem limite de recursos

FROM python:3.9

WORKDIR /app

ARG DB_PASSWORD=SuperSecret123
ENV DB_PASSWORD=${DB_PASSWORD}
ENV FLASK_DEBUG=1
ENV FLASK_ENV=development

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
