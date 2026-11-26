
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(cors({
  origin: process.env.FRONTEND_ORIGIN,
  methods: ["GET"]
}));

app.use(express.json());

const APS_BASE = "https://developer.api.autodesk.com";

let cachedToken = null;
let tokenExpiresAt = 0;

async function getApsToken() {
  if (cachedToken && Date.now() < tokenExpiresAt) {
    return cachedToken;
  }

  const credentials = Buffer.from(
    `${process.env.APS_CLIENT_ID}:${process.env.APS_CLIENT_SECRET}`
  ).toString("base64");

  const response = await fetch(
    `${APS_BASE}/authentication/v2/token`,
    {
      method: "POST",
      headers: {
        "Authorization": `Basic ${credentials}`,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        scope: "data:read data:write data:create bucket:create bucket:read viewables:read"
      })
    }
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(
      data.error_description || "Erro na autenticação Autodesk"
    );
  }

  cachedToken = data.access_token;
  tokenExpiresAt = Date.now() + (data.expires_in - 120) * 1000;

  return cachedToken;
}

// Token temporário para o Autodesk Viewer.
app.get("/api/token", async (req, res) => {
  try {
    const token = await getApsToken();

    res.json({
      access_token: token,
      expires_in: Math.max(
        0,
        Math.floor((tokenExpiresAt - Date.now()) / 1000)
      )
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Não foi possível obter o token Autodesk."
    });
  }
});

// Lista de modelos já enviados e convertidos.
app.get("/api/models", async (req, res) => {
  try {
    const file = path.join(__dirname, "models.json");
    const content = await fs.readFile(file, "utf8");
    res.json(JSON.parse(content));
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Não foi possível carregar os modelos."
    });
  }
});

// Miniatura gerada pela Autodesk.
app.get("/api/models/:id/thumbnail", async (req, res) => {
  try {
    const file = path.join(__dirname, "models.json");
    const models = JSON.parse(await fs.readFile(file, "utf8"));

    const model = models.find(item => item.id === req.params.id);

    if (!model) {
      return res.status(404).json({ error: "Modelo não encontrado." });
    }

    const token = await getApsToken();

    const response = await fetch(
      `${APS_BASE}/modelderivative/v2/designdata/${model.urn}/thumbnail?width=600&height=450`,
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    );

    if (!response.ok) {
      return res.status(response.status).json({
        error: "Miniatura ainda não está disponível."
      });
    }

    res.setHeader(
      "Content-Type",
      response.headers.get("content-type") || "image/png"
    );

    res.setHeader("Cache-Control", "public, max-age=86400");

    const image = Buffer.from(await response.arrayBuffer());
    res.send(image);

  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: "Erro ao carregar a miniatura."
    });
  }
});

app.get("/", (req, res) => {
  res.send("API Praça para Todos — Autodesk Viewer");
});

app.listen(PORT, () => {
  console.log(`Servidor iniciado na porta ${PORT}`);
});
