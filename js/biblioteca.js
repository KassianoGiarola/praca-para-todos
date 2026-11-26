
const API_URL = "https://praca-para-todos-api.onrender.com";

// Elementos da página.
const lista = document.getElementById("biblioteca-lista");
const modal = document.getElementById("modal-visualizador");
const tituloModal = document.getElementById("modal-titulo");
const botaoFechar = document.getElementById("fechar-visualizador");

let viewer = null;
let viewerInicializado = false;
let modelos = [];

/**
 * Cria o card de cada projeto.
 */
function criarCard(modelo) {
  const article = document.createElement("article");
  article.className = "card-material";

  // Área da miniatura.
  const visualizacao = document.createElement("div");
  visualizacao.className = "visualizacao-material";

  const imagem = document.createElement("img");

  imagem.src =
    `${API_URL}/api/models/${encodeURIComponent(modelo.id)}/thumbnail`;

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

  // Informações do projeto.
  const informacoes = document.createElement("div");
  informacoes.className = "informacoes-material";

  const etiqueta = document.createElement("span");
  etiqueta.className = "tipo-material";
  etiqueta.textContent = "PROJETO TÉCNICO • DWG";

  const titulo = document.createElement("h2");
  titulo.textContent = modelo.nome;

  const descricao = document.createElement("p");
  descricao.textContent = modelo.descricao;

  // Botões.
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
    `${API_URL}/api/models/${encodeURIComponent(modelo.id)}/download`;

  linkDownload.textContent = "Baixar DWG";

  acoes.append(botaoVisualizar, linkDownload);

  informacoes.append(
    etiqueta,
    titulo,
    descricao,
    acoes
  );

  article.append(
    visualizacao,
    informacoes
  );

  return article;
}

/**
 * Carrega os projetos da API.
 */
async function carregarBiblioteca() {
  try {
    const resposta = await fetch(
      `${API_URL}/api/models`
    );

    if (!resposta.ok) {
      const detalhe = await resposta.text();

      throw new Error(
        `Erro ${resposta.status}: ${detalhe}`
      );
    }

    modelos = await resposta.json();

    lista.replaceChildren();

    if (!Array.isArray(modelos) || modelos.length === 0) {
      lista.textContent =
        "Nenhum projeto disponível no momento.";

      return;
    }

    modelos.forEach(modelo => {
      lista.appendChild(criarCard(modelo));
    });

  } catch (erro) {
    console.error("Erro ao carregar biblioteca:", erro);

    lista.replaceChildren();

    const mensagem = document.createElement("p");
    mensagem.className = "mensagem-erro";
    mensagem.textContent =
      "Não foi possível carregar os projetos técnicos. Tente novamente mais tarde.";

    lista.appendChild(mensagem);
  }
}

/**
 * Obtém o token temporário para o Viewer.
 */
async function obterToken() {
  const resposta = await fetch(
    `${API_URL}/api/token`
  );

  if (!resposta.ok) {
    const detalhe = await resposta.text();

    throw new Error(
      `Erro ao obter token: ${resposta.status} - ${detalhe}`
    );
  }

  return resposta.json();
}

/**
 * Inicializa o Autodesk Viewer.
 */
async function inicializarViewer() {
  if (viewerInicializado && viewer) {
    return;
  }

  if (!window.Autodesk || !Autodesk.Viewing) {
    throw new Error(
      "A biblioteca do Autodesk Viewer não foi carregada."
    );
  }

  await new Promise((resolve, reject) => {
    Autodesk.Viewing.Initializer(
      {
        env: "AutodeskProduction2",
        api: "streamingV2",
        language: "pt-BR",

        getAccessToken: async (onTokenReady) => {
          try {
            const dados = await obterToken();

            onTokenReady(
              dados.access_token,
              dados.expires_in
            );

          } catch (erro) {
            console.error(
              "Erro ao obter token do Viewer:",
              erro
            );

            reject(erro);
          }
        }

      },

      () => {
        try {
          const elemento = document.getElementById(
            "autodesk-viewer"
          );

          if (!elemento) {
            throw new Error(
              "Elemento autodesk-viewer não encontrado no HTML."
            );
          }

          viewer = new Autodesk.Viewing.GuiViewer3D(
            elemento
          );

          const resultado = viewer.start();

          if (resultado > 0) {
            viewer = null;

            throw new Error(
              `Falha ao iniciar o Viewer. Código: ${resultado}`
            );
          }

          viewerInicializado = true;

          resolve();

        } catch (erro) {
          reject(erro);
        }
      }
    );
  });
}

/**
 * Abre um projeto no Autodesk Viewer.
 */
async function abrirVisualizador(modelo) {
  modal.classList.add("ativo");
  modal.setAttribute("aria-hidden", "false");

  document.body.classList.add("modal-aberto");

  tituloModal.textContent = modelo.nome;

  try {
    await inicializarViewer();

    // Aguarda o modal atualizar seu tamanho.
    await new Promise(resolve => {
      requestAnimationFrame(resolve);
    });

    viewer.resize();

    viewer.setLightPreset(0);

    // Remove o projeto anterior, se existir.
    if (viewer.model) {
      viewer.unloadModel(viewer.model);
    }

    // Carrega o documento Autodesk.
    const documento = await new Promise(
      (resolve, reject) => {
        Autodesk.Viewing.Document.load(
          `urn:${modelo.urn}`,
          resolve,
          reject
        );
      }
    );

    // Obtém a geometria padrão pela raiz do documento.
    const raiz = documento.getRoot();

    const geometria = raiz.getDefaultGeometry();

    if (!geometria) {
      throw new Error(
        "Não foi encontrada uma geometria padrão para este projeto."
      );
    }

    // Carrega a geometria no Viewer.
    await viewer.loadDocumentNode(
      documento,
      geometria
    );

    viewer.resize();

  } catch (erro) {
    console.error(
      `Erro ao abrir ${modelo.nome}:`,
      erro
    );

    const mensagem = erro?.message || String(erro);

    alert(
      `Não foi possível abrir ${modelo.nome}.\n\nDetalhes: ${mensagem}\n\nConsulte o Console (F12) para mais informações.`
    );

    fecharVisualizador();
  }
}

/**
 * Fecha o modal e descarrega o modelo.
 */
function fecharVisualizador() {
  modal.classList.remove("ativo");
  modal.setAttribute("aria-hidden", "true");

  document.body.classList.remove("modal-aberto");

  if (viewer && viewer.model) {
    viewer.unloadModel(viewer.model);
  }
}

/**
 * Eventos do modal.
 */
botaoFechar.addEventListener(
  "click",
  fecharVisualizador
);

modal.addEventListener("click", evento => {
  if (evento.target === modal) {
    fecharVisualizador();
  }
});

document.addEventListener("keydown", evento => {
  if (
    evento.key === "Escape" &&
    modal.classList.contains("ativo")
  ) {
    fecharVisualizador();
  }
});

// Inicia o carregamento da biblioteca.
carregarBiblioteca();
