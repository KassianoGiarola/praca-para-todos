
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

const APS_BASE = "https://developer.api.autodesk.com";

app.use(cors({
  origin: process.env.FRONTEND_ORIGIN,
  methods: ["GET"]
}));

app.use(express.json());

// Cache separado para cada conjunto de permissões.
const tokenCache = new Map();

async function getApsToken(scope) {
  const cached = tokenCache.get(scope);

  if (cached && Date.now() < cached.expiresAt) {
    return cached.accessToken;
  }

  const credentials = Buffer.from(
    `${process.env.APS_CLIENT_ID}:${process.env.APS_CLIENT_SECRET}`
  ).toString("base64");

  const response = await fetch(
    `${APS_BASE}/authentication/v2/token`,
    {
      method: "POST",
      headers: {
        Authorization: `Basic ${credentials}`,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        scope
      })
    }
  );

  const data = await response.json();

  if (!response.ok) {
    console.error("Erro de autenticação APS:", data);
    throw new Error("Falha na autenticação Autodesk.");
  }

  const expiresAt = Date.now() + (data.expires_in - 120) * 1000;

  tokenCache.set(scope, {
    accessToken: data.access_token,
    expiresAt
  });

  return data.access_token;
}

async function carregarModelos() {
  const file = path.join(__dirname, "models.json");
  const content = await fs.readFile(file, "utf8");
  return JSON.parse(content);
}

// Token de leitura para o Autodesk Viewer.
app.get("/api/token", async (req, res) => {
  try {
    const scope = "viewables:read";
    const token = await getApsToken(scope);

    const cached = tokenCache.get(scope);

    res.json({
      access_token: token,
      expires_in: Math.max(
        0,
        Math.floor((cached.expiresAt - Date.now()) / 1000)
      )
    });
  } catch (error) {
    console.error("Erro /api/token:", error);

    res.status(500).json({
      error: "Não foi possível obter autorização para visualizar os projetos."
    });
  }
});

// Lista de modelos.
app.get("/api/models", async (req, res) => {
  try {
    const modelos = await carregarModelos();
    res.json(modelos);
  } catch (error) {
    console.error("Erro /api/models:", error);

    res.status(500).json({
      error: "Não foi possível carregar os modelos."
    });
  }
});

// Miniaturas dos modelos.
app.get("/api/models/:id/thumbnail", async (req, res) => {
  try {
    const modelos = await carregarModelos();

    const modelo = modelos.find(
      item => item.id === req.params.id
    );

    if (!modelo) {
      return res.status(404).json({
        error: "Modelo não encontrado."
      });
    }

    const token = await getApsToken("viewables:read");

    const response = await fetch(
      `${APS_BASE}/modelderivative/v2/designdata/${modelo.urn}/thumbnail?width=600&height=450`,
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    );

    if (!response.ok) {
      const detalhe = await response.text();

      console.error("Erro na miniatura APS:", response.status, detalhe);

      return res.status(response.status).json({
        error: "Miniatura ainda não está disponível."
      });
    }

    const image = Buffer.from(await response.arrayBuffer());

    res.setHeader(
      "Content-Type",
      response.headers.get("content-type") || "image/png"
    );

    res.setHeader("Cache-Control", "public, max-age=86400");

    res.send(image);

  } catch (error) {
    console.error("Erro na miniatura:", error);

    res.status(500).json({
      error: "Erro ao carregar a miniatura."
    });
  }
});

// Download do arquivo DWG original.
app.get("/api/models/:id/download", async (req, res) => {
  try {
    const modelos = await carregarModelos();

    const modelo = modelos.find(
      item => item.id === req.params.id
    );

    if (!modelo) {
      return res.status(404).json({
        error: "Modelo não encontrado."
      });
    }

    const bucket = process.env.APS_BUCKET;

    if (!bucket || !modelo.objectKey) {
      return res.status(500).json({
        error: "Configuração do arquivo não encontrada."
      });
    }

    // A permissão data:read fica somente no backend.
    const token = await getApsToken("data:read");

    const objectKey = encodeURIComponent(modelo.objectKey);

    const url =
      `${APS_BASE}/oss/v2/buckets/${bucket}/objects/${objectKey}`;

    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    if (!response.ok) {
      const detalhe = await response.text();

      console.error(
        "Erro no download APS:",
        response.status,
        detalhe
      );

      return res.status(response.status).json({
        error: "Não foi possível baixar o arquivo original."
      });
    }

    const arquivo = Buffer.from(await response.arrayBuffer());

    const nomeArquivo = modelo.arquivo || `${modelo.id}.dwg`;

    res.setHeader(
      "Content-Type",
      "application/octet-stream"
    );

    res.setHeader(
      "Content-Disposition",
      `attachment; filename*=UTF-8''${encodeURIComponent(nomeArquivo)}`
    );

    res.setHeader("Content-Length", arquivo.length);

    res.send(arquivo);

  } catch (error) {
    console.error("Erro no download:", error);

    res.status(500).json({
      error: "Erro interno ao baixar o arquivo."
    });
  }
});

app.get("/", (req, res) => {
  res.send("API Praça para Todos — Autodesk Viewer");
});

app.listen(PORT, () => {
  console.log(`Servidor iniciado na porta ${PORT}`);
});
