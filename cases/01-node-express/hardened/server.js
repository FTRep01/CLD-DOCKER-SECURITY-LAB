const express = require("express");
const app = express();

// Segredos vêm de variáveis de ambiente injetadas em runtime pela
// orquestração (Kubernetes Secret, Docker secret, Vault, etc.), nunca
// hardcoded na imagem.
const apiKey = process.env.API_KEY;

app.get("/", (req, res) => {
  res.send("CLD-D01 hardened app running as non-root user");
});

app.get("/healthz", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Nenhum endpoint de debug que exponha process.env em produção.

app.listen(3000, () => console.log("Listening on 3000 as non-root"));
