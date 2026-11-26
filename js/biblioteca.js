
const API_URL = "praca-para-todos-api.onrender.com";

const lista = document.getElementById("biblioteca-lista");
const modal = document.getElementById("modal-visualizador");
const tituloModal = document.getElementById("modal-titulo");
const botaoFechar = document.getElementById("fechar-visualizador");

let viewer = null;
let viewerInicializado = false;
let modelos = [];

function criarCard(modelo) {
  const article = document.createElement("article");
  article.className = "card-material";

  const visualizacao = document.createElement("div");
  visualizacao.className = "visualizacao-material";

  const imagem = document.createElement("img");
  imagem.src = `${API_URL}/api/models/${modelo.id}/thumbnail`;
  imagem.alt = `Pré-visualização de ${modelo.nome}`;
  imagem.loading = "lazy";

  imagem.onerror = () => {
    imagem.remove();
    visualizacao.classList.add("sem-miniatura");

    const mensagem = document.createElement("span");
    mensagem.textContent = "Prévia disponível ao abrir o projeto";
    visualizacao.appendChild(mensagem);
  };

  visualizacao.appendChild(imagem);

  const informacoes = document.createElement("div");
  informacoes.className = "informacoes-material";

  const etiqueta = document.createElement("span");
  etiqueta.className = "tipo-material";
  etiqueta.textContent = "PROJETO TÉCNICO • DWG";

  const titulo = document.createElement("h2");
  titulo.textContent = modelo.nome;

  const descricao = document.createElement("p");
  descricao.textContent = modelo.descricao;

  const acoes = document.createElement("div");
  acoes.className = "acoes-material";

  const botaoVisualizar = document.createElement("button");
  botaoVisualizar.type = "button";
  botaoVisualizar.className = "botao botao-primario";
  botaoVisualizar.textContent = "Visualizar projeto";
  botaoVisualizar.addEventListener("click", () => {
    abrirVisualizador(modelo);
  });

  const linkDownload = document.createElement("a");
  linkDownload.className = "botao botao-secundario";
  linkDownload.href =
    `${API_URL}/api/models/${modelo.id}/download`;
  linkDownload.textContent = "Baixar DWG";
  linkDownload.setAttribute("download", "");

  acoes.append(botaoVisualizar, linkDownload);

  informacoes.append(etiqueta, titulo, descricao, acoes);
  article.append(visualizacao, informacoes);

  return article;
}

async function carregarBiblioteca() {
  try {
    const resposta = await fetch(`${API_URL}/api/models`);

    if (!resposta.ok) {
      throw new Error("Falha ao consultar a biblioteca.");
    }

    modelos = await resposta.json();

    lista.replaceChildren();

    if (!modelos.length) {
      lista.textContent = "Nenhum projeto disponível no momento.";
      return;
    }

    modelos.forEach(modelo => {
      lista.appendChild(criarCard(modelo));
    });

  } catch (erro) {
    console.error(erro);
    lista.textContent =
      "Não foi possível carregar os projetos. Tente novamente mais tarde.";
  }
}

async function obterToken() {
  const resposta = await fetch(`${API_URL}/api/token`);

  if (!resposta.ok) {
    throw new Error("Não foi possível obter autorização para o Viewer.");
  }

  return resposta.json();
}

async function inicializarViewer() {
  if (viewerInicializado) return;

  await new Promise((resolve, reject) => {
    Autodesk.Viewing.Initializer(
      {
        env: "AutodeskProduction2",
        api: "streamingV2",
        language: "pt-BR",

        getAccessToken: async (onTokenReady) => {
          try {
            const dados = await obterToken();
            onTokenReady(dados.access_token, dados.expires_in);
          } catch (erro) {
            console.error(erro);
            reject(erro);
          }
        }
      },
      () => {
        const elemento = document.getElementById("autodesk-viewer");

        viewer = new Autodesk.Viewing.GuiViewer3D(elemento);

        const resultado = viewer.start();

        if (resultado > 0) {
          reject(new Error("Não foi possível iniciar o Viewer."));
          return;
        }

        viewerInicializado = true;
        resolve();
      }
    );
  });
}

async function abrirVisualizador(modelo) {
  modal.classList.add("ativo");
  modal.setAttribute("aria-hidden", "false");
  document.body.classList.add("modal-aberto");

  tituloModal.textContent = modelo.nome;

  try {
    await inicializarViewer();

    // Aguarda o navegador atualizar o tamanho da janela.
    await new Promise(resolve => requestAnimationFrame(resolve));

    viewer.resize();

    viewer.setLightPreset(0);

    const documento = await new Promise((resolve, reject) => {
      Autodesk.Viewing.Document.load(
        `urn:${modelo.urn}`,
        resolve,
        reject
      );
    });

    const geometria =
      Autodesk.Viewing.Document.getDefaultGeometry(documento);

    if (!geometria) {
      throw new Error("Não foi encontrada uma vista para este projeto.");
    }

    await viewer.loadDocumentNode(documento, geometria);

  } catch (erro) {
    console.error(erro);
    alert(
      "Não foi possível abrir o projeto. Verifique se a conversão do DWG terminou."
    );
    fecharVisualizador();
  }
}

function fecharVisualizador() {
  modal.classList.remove("ativo");
  modal.setAttribute("aria-hidden", "true");
  document.body.classList.remove("modal-aberto");

  if (viewer && viewer.model) {
    viewer.unloadModel(viewer.model);
  }
}

botaoFechar.addEventListener("click", fecharVisualizador);

modal.addEventListener("click", evento => {
  if (evento.target === modal) {
    fecharVisualizador();
  }
});

document.addEventListener("keydown", evento => {
  if (evento.key === "Escape" && modal.classList.contains("ativo")) {
    fecharVisualizador();
  }
});

carregarBiblioteca();
