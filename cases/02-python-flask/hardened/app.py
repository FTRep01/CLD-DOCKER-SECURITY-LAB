import os
from flask import Flask

app = Flask(__name__)

# Segredos injetados via variável de ambiente em runtime (Docker secret,
# Kubernetes Secret ou Vault), nunca embutidos na imagem.
db_password = os.environ.get("DB_PASSWORD")

@app.route("/")
def index():
    return "CLD-D02 hardened Flask app (non-root, gunicorn, debug off)"

@app.route("/healthz")
def healthz():
    return {"status": "ok"}, 200

# Nenhum endpoint expõe variáveis de ambiente.
