
import dotenv from "dotenv";
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const BASE = "https://developer.api.autodesk.com";
const BUCKET = process.env.APS_BUCKET;

const arquivos = [
  {
    id: "banco",
    nome: "Banco acessível",
    arquivo: "DWG MOBILIÁRIOS URBANOS - BANCO.dwg",
    descricao: "Desenho técnico de banco para espaços públicos."
  },
  {
    id: "lixeira",
    nome: "Lixeira acessível",
    arquivo: "DWG MOBILIÁRIOS URBANOS - LIXEIRA.dwg",
    descricao: "Desenho técnico de lixeira para espaços públicos."
  },
  {
    id: "emissor-sonoro",
    nome: "Emissor sonoro acessível",
    arquivo: "EMISSOR SONORO ACESSIVEL DWG.dwg",
    descricao: "Projeto de equipamento emissor de sinalização sonora."
  },
  {
    id: "mapa-tatil",
    nome: "Mapa tátil acessível",
    arquivo: "MAPA TATIL ACESSIVEL DWG.dwg",
    descricao: "Desenho técnico de mapa tátil para orientação."
  },
  {
    id: "placa-acessivel",
    nome: "Placa acessível",
    arquivo: "PLACA ACESSIVEL DWG.dwg",
    descricao: "Projeto de sinalização acessível."
  },
  {
    id: "bebedouro",
    nome: "Bebedouro acessível",
    arquivo: "DWG MOBILIÁRIOS URBANOS - BEBEDOURO.dwg",
    descricao: "Desenho técnico de bebedouro acessível."
  },
  {
    id: "mesa",
    nome: "Mesa acessível",
    arquivo: "DWG MOBILIÁRIOS URBANOS - MESA.dwg",
    descricao: "Desenho técnico de mesa para espaços públicos."
  },
  {
    id: "piso-tatil",
    nome: "Piso tátil",
    arquivo: "PISO TÁTIL DWG.dwg",
    descricao: "Desenho técnico de piso tátil."
  },
  {
    id: "balanco",
    nome: "Balanço",
    arquivo: "BALANÇO.dwg",
    descricao: "Desenho técnico de equipamento de balanço para espaços públicos."
  },
  {
    id: "cavalgada",
    nome: "Cavalgada",
    arquivo: "CAVALGADA.dwg",
    descricao: "Desenho técnico de equipamento recreativo para espaços públicos."
  },
  {
    id: "gira-gira",
    nome: "Gira-gira",
    arquivo: "GIRA-GIRA.dwg",
    descricao: "Desenho técnico de equipamento recreativo giratório."
  },
  {
    id: "playground",
    nome: "Playground",
    arquivo: "PLAYGROUND.dwg",
    descricao: "Projeto técnico de espaço e equipamentos recreativos infantis."
  }
];

async function apsRequest(url, token, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(options.headers || {})
    }
  });

  const text = await response.text();
  let data = {};

  try {
    data = text ? JSON.parse(text) : {};
  } catch {
    data = { message: text };
  }

  if (!response.ok) {
    throw new Error(
      `${response.status} - ${JSON.stringify(data)}`
    );
  }

  return data;
}

async function obterToken() {
  const credentials = Buffer.from(
    `${process.env.APS_CLIENT_ID}:${process.env.APS_CLIENT_SECRET}`
  ).toString("base64");

  const response = await fetch(`${BASE}/authentication/v2/token`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${credentials}`,
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body: new URLSearchParams({
      grant_type: "client_credentials",
      scope: "data:read data:write data:create bucket:create bucket:read viewables:read"
    })
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(JSON.stringify(data));
  }

  return data.access_token;
}

async function criarBucket(token) {
  try {
    await apsRequest(`${BASE}/oss/v2/buckets`, token, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-ads-region": process.env.APS_REGION || "US"
      },
      body: JSON.stringify({
        bucketKey: BUCKET,
        policyKey: "persistent",
        access: "full"
      })
    });

    console.log("Bucket criado:", BUCKET);
  } catch (error) {
    if (String(error).includes("409")) {
      console.log("Bucket já existe:", BUCKET);
      return;
    }

    throw error;
  }
}

function codificarUrn(urn) {
  return Buffer.from(urn)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

async function enviarArquivo(token, item) {
  const caminho = path.join(__dirname, "dwg", item.arquivo);
  const conteudo = await fs.readFile(caminho);
  const objectKey = `${item.id}.dwg`;

  console.log(`\nEnviando: ${item.nome}`);

  // Solicita uma URL temporária de upload.
  const signed = await apsRequest(
    `${BASE}/oss/v2/buckets/${BUCKET}/objects/${encodeURIComponent(objectKey)}/signeds3upload?minutesExpiration=30`,
    token
  );

  // Envia o arquivo para a URL assinada.
  const uploadResponse = await fetch(signed.urls[0], {
    method: "PUT",
    headers: {
      "Content-Type": "application/octet-stream"
    },
    body: conteudo
  });

  if (!uploadResponse.ok) {
    throw new Error(`Falha no envio de ${item.nome}`);
  }

  // Finaliza o upload na Autodesk.
  const finalizado = await apsRequest(
    `${BASE}/oss/v2/buckets/${BUCKET}/objects/${encodeURIComponent(objectKey)}/signeds3upload`,
    token,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        ossbucketKey: BUCKET,
        ossSourceFileObjectKey: objectKey,
        access: "full",
        uploadKey: signed.uploadKey
      })
    }
  );

  const urn = codificarUrn(finalizado.objectId);

  console.log("Arquivo enviado. Iniciando conversão...");

  // Solicita conversão para SVF2.
  await apsRequest(
    `${BASE}/modelderivative/v2/designdata/job`,
    token,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        input: {
          urn
        },
        output: {
          destination: {
            region: process.env.APS_REGION || "US"
          },
          formats: [
            {
              type: "svf2",
              views: ["2d", "3d"]
            }
          ]
        }
      })
    }
  );

  // Aguarda a conversão.
  let concluido = false;

  for (let tentativa = 0; tentativa < 60; tentativa++) {
    await new Promise(resolve => setTimeout(resolve, 10000));

    const status = await apsRequest(
      `${BASE}/modelderivative/v2/designdata/${urn}/manifest`,
      token
    );

    console.log(
      `${item.nome}: ${status.status} - ${status.progress || ""}`
    );

    if (status.status === "success") {
      concluido = true;
      break;
    }

    if (status.status === "failed") {
      throw new Error(
        `A conversão falhou para ${item.nome}: ${JSON.stringify(status)}`
      );
    }
  }

  if (!concluido) {
    throw new Error(`Tempo de conversão excedido: ${item.nome}`);
  }

  return {
    id: item.id,
    nome: item.nome,
    descricao: item.descricao,
    arquivo: item.arquivo,
    urn,
    objectKey
  };
}

async function main() {
  if (!BUCKET || !process.env.APS_CLIENT_ID || !process.env.APS_CLIENT_SECRET) {
    throw new Error("Confira as variáveis de ambiente no arquivo .env");
  }

  const token = await obterToken();

  await criarBucket(token);

  const modelos = [];

  for (const item of arquivos) {
    const modelo = await enviarArquivo(token, item);
    modelos.push(modelo);
  }

  await fs.writeFile(
    path.join(__dirname, "models.json"),
    JSON.stringify(modelos, null, 2)
  );

  console.log("\nTodos os arquivos foram enviados e convertidos!");
  console.log("Arquivo models.json atualizado.");
}

main().catch(error => {
  console.error("\nERRO:", error);
  process.exit(1);
});
