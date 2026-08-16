const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("CLD-D01 vulnerable app running as root, exposing API_KEY env var");
});

// Endpoint de debug deixado ligado em "produção" (más práticas adicionais)
app.get("/debug/env", (req, res) => {
  res.json(process.env);
});

app.listen(3000, () => console.log("Listening on 3000"));
