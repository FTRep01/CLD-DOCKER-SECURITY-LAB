import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def index():
    return "CLD-D02 vulnerable Flask app (root, debug mode on)"

@app.route("/config")
def config():
    # Vaza variáveis sensíveis de ambiente
    return {"DB_PASSWORD": os.environ.get("DB_PASSWORD")}

if __name__ == "__main__":
    # debug=True habilita o console interativo do Werkzeug: se exposto,
    # permite execução remota de código arbitrário.
    app.run(host="0.0.0.0", port=5000, debug=True)
