
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

// Cache de tokens separado por permissões.
const tokenCache = new Map();

/**
 * Obtém um token Autodesk com os escopos solicitados.
 * Os tokens ficam armazenados somente no backend.
 */
async function getApsToken(scope) {
  const cached = tokenCache.get(scope);

  if (cached && Date.now() < cached.expiresAt) {
    return cached.accessToken;
  }

  const clientId = process.env.APS_CLIENT_ID;
  const clientSecret = process.env.APS_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    throw new Error("Credenciais Autodesk não configuradas.");
  }

  const credentials = Buffer.from(
    `${clientId}:${clientSecret}`
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
    console.error("Erro de autenticação Autodesk:", data);
    throw new Error("Não foi possível autenticar na Autodesk.");
  }

  const expiresAt =
    Date.now() + Math.max(0, data.expires_in - 120) * 1000;

  tokenCache.set(scope, {
    accessToken: data.access_token,
    expiresAt
  });

  return data.access_token;
}

/**
 * Lê o arquivo models.json.
 */
async function carregarModelos() {
  const arquivo = path.join(__dirname, "models.json");
  const conteudo = await fs.readFile(arquivo, "utf8");

  return JSON.parse(conteudo);
}

/**
 * Rota inicial.
 */
app.get("/", (req, res) => {
  res.send("API Praça para Todos — Autodesk Viewer");
});

/**
 * Token com permissão somente de visualização.
 * Utilizado pelo Autodesk Viewer no navegador.
 */
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
    console.error("Erro em /api/token:", error);

    res.status(500).json({
      error: "Não foi possível obter autorização para visualizar os projetos."
    });
  }
});

/**
 * Lista todos os projetos cadastrados.
 */
app.get("/api/models", async (req, res) => {
  try {
    const modelos = await carregarModelos();

    res.json(modelos);

  } catch (error) {
    console.error("Erro em /api/models:", error);

    res.status(500).json({
      error: "Não foi possível carregar os modelos."
    });
  }
});

/**
 * Retorna a miniatura de um projeto.
 */
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

    const resposta = await fetch(
      `${APS_BASE}/modelderivative/v2/designdata/${modelo.urn}/thumbnail?width=600&height=450`,
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    );

    if (!resposta.ok) {
      const detalhe = await resposta.text();

      console.error("Erro na miniatura Autodesk:", {
        status: resposta.status,
        detalhe
      });

      return res.status(resposta.status).json({
        error: "Miniatura ainda não está disponível."
      });
    }

    const imagem = Buffer.from(
      await resposta.arrayBuffer()
    );

    res.setHeader(
      "Content-Type",
      resposta.headers.get("content-type") || "image/png"
    );

    res.setHeader(
      "Cache-Control",
      "public, max-age=86400"
    );

    res.send(imagem);

  } catch (error) {
    console.error("Erro ao carregar miniatura:", error);

    res.status(500).json({
      error: "Erro ao carregar a miniatura."
    });
  }
});

/**
 * Gera uma URL temporária e redireciona
 * o navegador para o arquivo DWG original.
 */
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

    const token = await getApsToken("data:read");

    const bucketKey = encodeURIComponent(bucket);
    const objectKey = encodeURIComponent(modelo.objectKey);

    const parametros = new URLSearchParams({
      minutesExpiration: "5",
      "response-content-type": "application/octet-stream",
      "response-content-disposition":
        `attachment; filename="${modelo.id}.dwg"`
    });

    const url =
      `${APS_BASE}/oss/v2/buckets/${bucketKey}` +
      `/objects/${objectKey}/signeds3download?${parametros}`;

    const resposta = await fetch(url, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    const dados = await resposta.json();

    if (!resposta.ok) {
      console.error("Erro ao gerar URL de download:", {
        status: resposta.status,
        detalhes: dados
      });

      return res.status(resposta.status).json({
        error: "A Autodesk não autorizou o download.",
        detalhe: dados
      });
    }

    if (dados.status !== "complete" || !dados.url) {
      console.error("Arquivo não está pronto para download:", dados);

      return res.status(409).json({
        error: "O arquivo ainda não está disponível.",
        status: dados.status
      });
    }

    // A URL é temporária e não contém o token OAuth.
    return res.redirect(302, dados.url);

  } catch (error) {
    console.error("Erro na rota de download:", error);

    res.status(500).json({
      error: "Erro interno ao baixar o arquivo."
    });
  }
});

// Inicialização do servidor.
app.listen(PORT, () => {
  console.log(`Servidor iniciado na porta ${PORT}`);
});
