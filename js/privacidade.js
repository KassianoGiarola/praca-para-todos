/* Nenhum serviço externo é carregado por este módulo sem escolha específica. */
(() => {
    "use strict";

    const CHAVE = "praca-privacidade";
    const VERSAO = 1;
    const VALIDADE = 180 * 24 * 60 * 60 * 1000;
    let servicoSolicitado = false;
    let focoAnterior = null;
    let aberturaAutomatica = false;
    let temporizador;

    function lerEscolha() {
        try {
            const valor = JSON.parse(localStorage.getItem(CHAVE));
            const agora = Date.now();
            if (
                valor && valor.versao === VERSAO &&
                typeof valor.vlibras === "boolean" &&
                Number.isFinite(valor.atualizadoEm) &&
                Number.isFinite(valor.expiraEm) &&
                valor.atualizadoEm <= agora && valor.expiraEm > agora &&
                valor.expiraEm - valor.atualizadoEm === VALIDADE
            ) {
                return valor;
            }
            localStorage.removeItem(CHAVE);
        } catch {
            // Armazenamento bloqueado ou inválido: o padrão permanece desativado.
            try { localStorage.removeItem(CHAVE); } catch { /* Sem acesso ao armazenamento. */ }
        }
        return null;
    }

    let escolha = lerEscolha();
    const dialogo = document.createElement("dialog");
    dialogo.className = "privacidade-dialogo";
    dialogo.id = "privacidade-preferencias";
    dialogo.setAttribute("aria-labelledby", "privacidade-titulo");
    dialogo.setAttribute("aria-describedby", "privacidade-resumo");
    dialogo.innerHTML = `
        <div class="privacidade-topo">
            <h2 id="privacidade-titulo" tabindex="-1">Preferências de privacidade</h2>
            <button type="button" class="botao botao-secundario" id="privacidade-fechar"
                aria-label="Fechar sem alterar">Fechar</button>
        </div>
        <p id="privacidade-resumo">O VLibras é opcional. O site não usa cookies próprios
            de publicidade ou medição de audiência.</p>
        <label class="privacidade-opcao" for="privacidade-vlibras">
            <input type="checkbox" id="privacidade-vlibras" aria-describedby="privacidade-vlibras-detalhe">
            <strong>Ativar tradução em Libras com VLibras</strong>
        </label>
        <p id="privacidade-vlibras-detalhe">Ao ativar, o navegador se conecta ao VLibras e à
            rede jsDelivr, expondo dados como IP e informações do navegador. O texto solicitado
            pode ser enviado para tradução. A escolha vale por até 180 dias.</p>
        <div class="privacidade-acoes">
            <button type="button" class="botao botao-secundario" id="privacidade-rejeitar">
                Continuar sem VLibras
            </button>
            <button type="button" class="botao botao-secundario" id="privacidade-salvar">
                Salvar escolhas
            </button>
        </div>
        <p class="privacidade-estado" id="privacidade-estado" role="status"></p>
        <p><a href="cookies.html">Cookies e serviços externos</a> ·
            <a href="privacidade.html">Política de privacidade (minuta)</a></p>
    `;
    document.body.appendChild(dialogo);
    const opcao = dialogo.querySelector("input");
    const estado = document.getElementById("privacidade-estado");

    function abrir(evento) {
        // Sem suporte a dialog, o link continua para as instruções em HTML.
        if (typeof dialogo.showModal !== "function") return;
        evento?.preventDefault();
        if (dialogo.open) return;
        aberturaAutomatica = !evento;
        focoAnterior = document.activeElement;
        opcao.checked = escolha?.vlibras === true;
        estado.textContent = "";
        dialogo.showModal();
        document.getElementById("privacidade-titulo").focus();
    }

    document.querySelectorAll("[data-privacidade-abrir]").forEach(link => {
        link.addEventListener("click", abrir);
    });

    dialogo.addEventListener("close", () => {
        if (focoAnterior?.isConnected) focoAnterior.focus();
    });
    document.getElementById("privacidade-fechar").addEventListener("click", () => dialogo.close());

    function identificarVLibras() {
        const wrapper = document.getElementById("vlibras-access-wrapper");
        if (!wrapper) return false;
        wrapper.setAttribute("role", "complementary");
        wrapper.setAttribute("aria-label", "Tradução em Libras com VLibras");
        return true;
    }

    function carregarVLibras() {
        if (servicoSolicitado) return;
        servicoSolicitado = true;
        const area = document.createElement("div");
        area.setAttribute("vw", "");
        area.className = "enabled";
        area.innerHTML = `<div vw-access-button class="active"></div>
            <div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div>`;
        document.body.appendChild(area);

        const observador = new MutationObserver(() => {
            if (identificarVLibras()) observador.disconnect();
        });
        observador.observe(document.body, { childList: true, subtree: true });
        window.addEventListener("pagehide", () => observador.disconnect(), { once: true });

        const script = document.createElement("script");
        script.src = "https://vlibras.gov.br/app/vlibras-plugin.js";
        script.async = true;
        const falha = () => {
            estado.textContent = "Não foi possível carregar o VLibras. Verifique sua conexão e recarregue a página para tentar novamente. Os demais recursos continuam disponíveis.";
            document.querySelectorAll("[data-vlibras-estado]").forEach(item => {
                item.textContent = estado.textContent;
            });
        };
        script.addEventListener("load", () => {
            if (typeof window.VLibras?.Widget !== "function") {
                falha();
                return;
            }
            try {
                new window.VLibras.Widget("https://vlibras.gov.br/app");
                identificarVLibras();
            } catch {
                falha();
            }
        });
        script.addEventListener("error", falha);
        document.body.appendChild(script);
    }

    function atualizarEstado() {
        document.querySelectorAll("[data-vlibras-estado]").forEach(item => {
            item.textContent = escolha?.vlibras === true
                ? "VLibras autorizado neste navegador. Você pode desativá-lo em Preferências de privacidade."
                : "VLibras desativado. Nenhuma conexão com esse serviço é iniciada pelo site.";
        });
    }

    function salvar(permitir) {
        const agora = Date.now();
        escolha = { versao: VERSAO, vlibras: permitir, atualizadoEm: agora, expiraEm: agora + VALIDADE };
        let persistiu = true;
        try {
            localStorage.setItem(CHAVE, JSON.stringify(escolha));
        } catch {
            persistiu = false;
            // Em caso de quota cheia, apagar a autorização antiga ainda deve funcionar.
            if (!permitir) {
                try { localStorage.removeItem(CHAVE); } catch { /* O acesso pode estar bloqueado. */ }
            }
        }
        acompanharValidade();
        atualizarEstado();
        if (!permitir && servicoSolicitado) {
            // Código de terceiros já executado não pode ser descarregado com segurança.
            // A recarga interrompe a instância atual e aplica a recusa desde o início.
            window.location.reload();
            return;
        }
        estado.textContent = persistiu
            ? "Escolhas salvas neste navegador. Você pode alterá-las a qualquer momento."
            : "Escolha aplicada somente nesta página: o navegador bloqueou o armazenamento. Ao sair, o VLibras volta a ficar desativado.";
        if (permitir) carregarVLibras();
        if (persistiu && aberturaAutomatica) dialogo.close();
    }

    document.getElementById("privacidade-salvar").addEventListener("click", () => salvar(opcao.checked));
    document.getElementById("privacidade-rejeitar").addEventListener("click", () => {
        opcao.checked = false;
        salvar(false);
    });

    window.addEventListener("storage", evento => {
        if (evento.key !== CHAVE && evento.key !== null) return;
        escolha = lerEscolha();
        acompanharValidade();
        atualizarEstado();
        if (servicoSolicitado && escolha?.vlibras !== true) window.location.reload();
        // Uma autorização em outra aba não inicia serviços nesta página sem recarga.
    });

    function acompanharValidade() {
        window.clearTimeout(temporizador);
        if (!escolha) return;
        const restante = escolha.expiraEm - Date.now();
        if (restante <= 0) {
            escolha = null;
            try { localStorage.removeItem(CHAVE); } catch { /* Padrão desativado. */ }
            atualizarEstado();
            if (servicoSolicitado) window.location.reload();
            return;
        }
        // O limite dos temporizadores do navegador é menor que 180 dias.
        temporizador = window.setTimeout(acompanharValidade, Math.min(restante, 2147483647));
    }

    document.addEventListener("visibilitychange", () => {
        if (!document.hidden) acompanharValidade();
    });

    // Uma página restaurada do histórico pode ter perdido eventos de outra aba.
    window.addEventListener("pageshow", evento => {
        if (!evento.persisted) return;
        escolha = lerEscolha();
        acompanharValidade();
        atualizarEstado();
        if (servicoSolicitado && escolha?.vlibras !== true) window.location.reload();
    });

    atualizarEstado();
    acompanharValidade();
    if (escolha?.vlibras === true) carregarVLibras();
    if (!escolha && !document.body.hasAttribute("data-privacidade-sem-aviso")) abrir();
})();
