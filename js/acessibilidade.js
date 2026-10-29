
/* ==========================================
   CENTRAL DE ACESSIBILIDADE GLOBAL
   PROJETO PRAÇA PARA TODOS
========================================== */

(() => {
    "use strict";

    if (document.getElementById("a11y-barra")) return;

    // ==========================================
    // CONFIGURAÇÕES
    // ==========================================

    const STORAGE = "praca-acessibilidade";

    const padrao = {
        fonte: 0,
        letras: 0,
        linhas: 0,
        contraste: false,
        links: false,
        imagens: false,
        animacoes: false,
        cursor: false
    };

    let config = { ...padrao };

    try {
        const salvo = JSON.parse(localStorage.getItem(STORAGE));

        if (salvo && typeof salvo === "object") {
            Object.keys(padrao).forEach(chave => {
                if (typeof salvo[chave] === typeof padrao[chave]) {
                    config[chave] = salvo[chave];
                }
            });
        }
    } catch (erro) {
        console.warn("Erro ao carregar preferências:", erro);
    }

    config.fonte = Math.max(-2, Math.min(5, config.fonte));
    config.letras = Math.max(0, Math.min(3, config.letras));
    config.linhas = Math.max(0, Math.min(3, config.linhas));

    // ==========================================
    // ÍCONES SVG
    // ==========================================

    const icones = {
        acessibilidade: `
            <circle cx="16" cy="4" r="1"/>
            <path d="m18 19 1-7-6 1"/>
            <path d="m5 8 3-3 5.5 3-2.36 3.5"/>
            <path d="M4.24 14.5a5 5 0 0 0 6.88 6"/>
            <path d="M13.76 17.5a5 5 0 0 0-6.88-6"/>
        `,
        fechar: `
            <path d="M18 6 6 18"/>
            <path d="m6 6 12 12"/>
        `,
        fonte: `
            <path d="m3 15 4-8 4 8"/>
            <path d="M4 13h6"/>
            <path d="m13 19 5-14 5 14"/>
            <path d="M15 14h6"/>
        `,
        letras: `
            <path d="M4 7h16"/>
            <path d="M4 17h16"/>
            <path d="m7 11-3 2 3 2"/>
            <path d="m17 11 3 2-3 2"/>
        `,
        linhas: `
            <path d="M9 6h12M9 12h12M9 18h12"/>
            <path d="m3 8 2-2 2 2"/>
            <path d="M5 6v12"/>
            <path d="m3 16 2 2 2-2"/>
        `,
        contraste: `
            <circle cx="12" cy="12" r="10"/>
            <path d="M12 2a10 10 0 0 1 0 20Z"/>
        `,
        links: `
            <path d="M10 13a5 5 0 0 0 7.5.5l3-3a5 5 0 0 0-7.1-7.1l-1.7 1.7"/>
            <path d="M14 11a5 5 0 0 0-7.5-.5l-3 3a5 5 0 0 0 7.1 7.1l1.7-1.7"/>
        `,
        imagens: `
            <rect x="3" y="3" width="18" height="18" rx="2"/>
            <circle cx="9" cy="9" r="2"/>
            <path d="m3 17 5-5 4 4 3-3 6 6"/>
            <path d="M2 2 22 22"/>
        `,
        animacoes: `
            <circle cx="12" cy="12" r="10"/>
            <path d="M10 8v8M14 8v8"/>
        `,
        cursor: `
            <path d="m5 3 14 9-7 1-3 7-4-17Z"/>
        `,
        volume: `
            <path d="M11 5 6 9H3v6h3l5 4V5Z"/>
            <path d="M15.5 8.5a5 5 0 0 1 0 7"/>
            <path d="M19 5a10 10 0 0 1 0 14"/>
        `,
        reproduzir: `
            <path d="m8 5 12 7-12 7V5Z"/>
        `,
        pausar: `
            <rect x="6" y="4" width="4" height="16" rx="1"/>
            <rect x="14" y="4" width="4" height="16" rx="1"/>
        `,
        parar: `
            <rect x="5" y="5" width="14" height="14" rx="2"/>
        `,
        selecionar: `
            <path d="M4 7V4h3"/>
            <path d="M17 4h3v3"/>
            <path d="M20 17v3h-3"/>
            <path d="M7 20H4v-3"/>
            <path d="M8 10h8M8 14h6"/>
        `
    };

    function svg(nome) {
        return `
            <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
            >
                ${icones[nome]}
            </svg>
        `;
    }

    // ==========================================
    // RECURSOS DISPONÍVEIS
    // ==========================================

    const recursos = [
        {
            titulo: "Controle de fonte",
            itens: [
                ["fonteMais", "Aumentar fonte", "fonte"],
                ["fonteMenos", "Diminuir fonte", "fonte"],
                ["letras", "Espaçar letras", "letras"],
                ["linhas", "Espaçar linhas", "linhas"]
            ]
        },
        {
            titulo: "Controle visual",
            itens: [
                ["contraste", "Alto contraste", "contraste"],
                ["links", "Destacar links", "links"],
                ["imagens", "Ocultar imagens", "imagens"],
                ["animacoes", "Pausar animações", "animacoes"],
                ["cursor", "Cursor destacado", "cursor"]
            ]
        }
    ];

    // ==========================================
    // CRIAÇÃO DOS ELEMENTOS
    // ==========================================

    const barra = document.createElement("div");
    barra.id = "a11y-barra";
    barra.className = "a11y-barra";

    barra.innerHTML = `
        <button
            type="button"
            class="a11y-atalho"
            id="a11y-abrir"
            aria-label="Abrir recursos assistivos"
            aria-haspopup="dialog"
            aria-controls="a11y-painel"
            aria-expanded="false"
        >
            ${svg("acessibilidade")}
            <span>Recursos assistivos</span>
        </button>
    `;

    const fundo = document.createElement("div");
    fundo.className = "a11y-fundo";
    fundo.hidden = true;

    const painel = document.createElement("section");
    painel.id = "a11y-painel";
    painel.className = "a11y-painel";
    painel.setAttribute("role", "dialog");
    painel.setAttribute("aria-modal", "true");
    painel.setAttribute("aria-labelledby", "a11y-titulo");
    painel.hidden = true;

    const gruposHTML = recursos.map(grupo => `
        <div class="a11y-grupo">
            <h3>${grupo.titulo}</h3>

            <div class="a11y-grade">
                ${grupo.itens.map(([acao, nome, icone]) => `
                    <button
                        type="button"
                        class="a11y-opcao"
                        data-acao="${acao}"
                    >
                        ${svg(icone)}
                        <span>${nome}</span>
                    </button>
                `).join("")}
            </div>
        </div>
    `).join("");

    painel.innerHTML = `
        <div class="a11y-topo">
            <h2 id="a11y-titulo">Recursos assistivos</h2>

            <button
                type="button"
                class="a11y-fechar"
                id="a11y-fechar"
                aria-label="Fechar recursos assistivos"
            >
                ${svg("fechar")}
            </button>
        </div>

        <div class="a11y-conteudo">
            ${gruposHTML}

            <div class="a11y-grupo a11y-grupo-leitor">
                <h3>Leitura de texto</h3>

                <p class="a11y-leitor-descricao">
                    Ouça o conteúdo da página ou um trecho selecionado.
                </p>

                <div class="a11y-leitor-controles">
                    <button
                        type="button"
                        class="a11y-leitor-botao"
                        data-leitor="pagina"
                    >
                        ${svg("volume")}
                        <span>Ler página</span>
                    </button>

                    <button
                        type="button"
                        class="a11y-leitor-botao"
                        data-leitor="selecao"
                    >
                        ${svg("selecionar")}
                        <span>Ler seleção</span>
                    </button>

                    <button
                        type="button"
                        class="a11y-leitor-botao"
                        data-leitor="pausar"
                        disabled
                    >
                        ${svg("pausar")}
                        <span>Pausar</span>
                    </button>

                    <button
                        type="button"
                        class="a11y-leitor-botao"
                        data-leitor="continuar"
                        disabled
                    >
                        ${svg("reproduzir")}
                        <span>Continuar</span>
                    </button>

                    <button
                        type="button"
                        class="a11y-leitor-botao"
                        data-leitor="parar"
                        disabled
                    >
                        ${svg("parar")}
                        <span>Parar</span>
                    </button>
                </div>

                <label
                    class="a11y-leitor-velocidade"
                    for="a11y-velocidade"
                >
                    Velocidade da leitura:
                    <output id="a11y-velocidade-valor">1,00x</output>
                </label>

                <input
                    type="range"
                    id="a11y-velocidade"
                    min="0.5"
                    max="2"
                    step="0.25"
                    value="1"
                >

                <p
                    class="a11y-leitor-status"
                    id="a11y-leitor-status"
                    role="status"
                    aria-live="polite"
                >
                    Leitor pronto para utilização.
                </p>
            </div>

            <button
                type="button"
                class="a11y-restaurar"
                id="a11y-restaurar"
            >
                Restaurar configurações
            </button>
        </div>
    `;

    // ==========================================
    // NOVO: CONTROLE FLUTUANTE DO LEITOR
    // ==========================================

    const leitorFlutuante = document.createElement("aside");
    leitorFlutuante.id = "a11y-leitor-flutuante";
    leitorFlutuante.className = "a11y-leitor-flutuante";
    leitorFlutuante.hidden = true;
    leitorFlutuante.setAttribute(
        "aria-label",
        "Controles da leitura de texto"
    );

    leitorFlutuante.innerHTML = `
        <div class="a11y-flutuante-cabecalho">
            <div class="a11y-flutuante-identificacao">
                ${svg("volume")}

                <div>
                    <strong>Leitor de texto</strong>
                    <span id="a11y-flutuante-status">
                        Leitura em andamento
                    </span>
                </div>
            </div>
        </div>

        <div class="a11y-flutuante-acoes">
            <button
                type="button"
                id="a11y-flutuante-pausar"
                aria-label="Pausar leitura"
            >
                ${svg("pausar")}
                <span>Pausar</span>
            </button>

            <button
                type="button"
                id="a11y-flutuante-continuar"
                aria-label="Continuar leitura"
                hidden
            >
                ${svg("reproduzir")}
                <span>Continuar</span>
            </button>

            <button
                type="button"
                id="a11y-flutuante-parar"
                class="a11y-flutuante-parar"
                aria-label="Parar leitura"
            >
                ${svg("parar")}
                <span>Parar</span>
            </button>
        </div>
    `;

    document.body.append(
        barra,
        fundo,
        painel,
        leitorFlutuante
    );

    const abrirBotao = document.getElementById("a11y-abrir");
    const fecharBotao = document.getElementById("a11y-fechar");
    const restaurarBotao = document.getElementById("a11y-restaurar");

    const flutuantePausar = document.getElementById(
        "a11y-flutuante-pausar"
    );

    const flutuanteContinuar = document.getElementById(
        "a11y-flutuante-continuar"
    );

    const flutuanteParar = document.getElementById(
        "a11y-flutuante-parar"
    );

    const flutuanteStatus = document.getElementById(
        "a11y-flutuante-status"
    );

    // ==========================================
    // CURSOR DESTACADO
    // ==========================================

    const cursorDestaque = document.createElement("div");
    cursorDestaque.className = "a11y-cursor-destaque";
    cursorDestaque.setAttribute("aria-hidden", "true");

    document.body.appendChild(cursorDestaque);

    let mouseNaPagina = false;

    function atualizarCursor() {
        cursorDestaque.style.visibility =
            config.cursor && mouseNaPagina
                ? "visible"
                : "hidden";
    }

    document.addEventListener("pointermove", evento => {
        if (evento.pointerType !== "mouse") return;

        mouseNaPagina = true;

        cursorDestaque.style.left = `${evento.clientX}px`;
        cursorDestaque.style.top = `${evento.clientY}px`;

        atualizarCursor();
    }, { passive: true });

    document.addEventListener("pointerout", evento => {
        if (!evento.relatedTarget) {
            mouseNaPagina = false;
            atualizarCursor();
        }
    });

    window.addEventListener("blur", () => {
        mouseNaPagina = false;
        atualizarCursor();
    });

    // ==========================================
    // LEITOR DE TEXTO
    // ==========================================

    const sintetizador = window.speechSynthesis;

    const leitorDisponivel =
        "speechSynthesis" in window &&
        "SpeechSynthesisUtterance" in window;

    const statusLeitor = document.getElementById(
        "a11y-leitor-status"
    );

    const velocidadeInput = document.getElementById(
        "a11y-velocidade"
    );

    const velocidadeValor = document.getElementById(
        "a11y-velocidade-valor"
    );

    let leituraAtual = null;
    let leituraPausada = false;
    let textoSelecionado = "";
    let geracaoLeitura = 0;

    const botoesLeitor = {};

    painel.querySelectorAll("[data-leitor]").forEach(botao => {
        botoesLeitor[botao.dataset.leitor] = botao;
    });

    function atualizarStatusLeitor(mensagem) {
        statusLeitor.textContent = mensagem;
    }

    // ==========================================
    // NOVO: SINCRONIZAÇÃO DO PAINEL FLUTUANTE
    // ==========================================

    function atualizarLeitorFlutuante() {
        const ativo = leitorDisponivel && leituraAtual !== null;

        leitorFlutuante.hidden = !ativo;

        if (!ativo) return;

        flutuantePausar.hidden = leituraPausada;
        flutuanteContinuar.hidden = !leituraPausada;

        flutuanteStatus.textContent = leituraPausada
            ? "Leitura pausada"
            : "Leitura em andamento";
    }

    function atualizarControlesLeitor() {
        const ativo = leituraAtual !== null;

        botoesLeitor.pausar.disabled =
            !leitorDisponivel || !ativo || leituraPausada;

        botoesLeitor.continuar.disabled =
            !leitorDisponivel || !ativo || !leituraPausada;

        botoesLeitor.parar.disabled =
            !leitorDisponivel || !ativo;

        atualizarLeitorFlutuante();
    }

    function obterVozPortugues() {
        if (!leitorDisponivel) return null;

        const vozes = sintetizador.getVoices();

        return (
            vozes.find(voz =>
                voz.lang.toLowerCase() === "pt-br"
            ) ||
            vozes.find(voz =>
                voz.lang.toLowerCase().startsWith("pt")
            ) ||
            null
        );
    }

    function obterTextoPrincipal() {
        const principal = document.querySelector("main");

        if (!principal) return "";

        const copia = principal.cloneNode(true);

        copia.querySelectorAll(
            "script, style, noscript, svg, button, " +
            "input, select, textarea, nav, " +
            "[hidden], [aria-hidden='true'], " +
            "[inert], [data-a11y-ignorar]"
        ).forEach(elemento => elemento.remove());

        return copia.innerText
            ? copia.innerText.trim()
            : copia.textContent.replace(/\s+/g, " ").trim();
    }

    function pararLeitura(mostrarStatus = true) {
        geracaoLeitura++;

        leituraAtual = null;
        leituraPausada = false;

        if (leitorDisponivel) {
            sintetizador.cancel();
        }

        atualizarControlesLeitor();

        if (mostrarStatus) {
            atualizarStatusLeitor("Leitura interrompida.");
        }
    }

    // ==========================================
    // NOVO: FUNÇÕES COMPARTILHADAS
    // ==========================================

    function pausarLeitura() {
        if (!leitorDisponivel || !leituraAtual || leituraPausada) {
            return;
        }

        leituraPausada = true;
        sintetizador.pause();

        atualizarStatusLeitor("Leitura pausada.");
        atualizarControlesLeitor();
    }

    function continuarLeitura() {
        if (!leitorDisponivel || !leituraAtual || !leituraPausada) {
            return;
        }

        sintetizador.resume();
        leituraPausada = false;

        atualizarStatusLeitor("Leitura em andamento.");
        atualizarControlesLeitor();
    }

    function iniciarLeitura(texto) {
        if (!leitorDisponivel) {
            atualizarStatusLeitor(
                "Seu navegador não oferece suporte à leitura de texto."
            );
            return;
        }

        const conteudo = texto.replace(/\s+/g, " ").trim();

        if (!conteudo) {
            atualizarStatusLeitor(
                "Nenhum texto disponível para leitura."
            );
            return;
        }

        pararLeitura(false);

        const geracao = geracaoLeitura;
        const fala = new SpeechSynthesisUtterance(conteudo);

        fala.lang = "pt-BR";
        fala.rate = Number(velocidadeInput.value);
        fala.pitch = 1;
        fala.volume = 1;

        const voz = obterVozPortugues();

        if (voz) {
            fala.voice = voz;
        }

        leituraAtual = fala;
        leituraPausada = false;

        fala.onstart = () => {
            if (geracao !== geracaoLeitura) return;

            atualizarStatusLeitor("Leitura em andamento.");
            atualizarControlesLeitor();
        };

        fala.onend = () => {
            if (geracao !== geracaoLeitura) return;

            if (leituraPausada) return;

            leituraAtual = null;
            leituraPausada = false;

            atualizarStatusLeitor("Leitura concluída.");
            atualizarControlesLeitor();
        };

        fala.onerror = evento => {
            if (geracao !== geracaoLeitura) return;

            if (leituraPausada) {
                atualizarControlesLeitor();
                return;
            }

            leituraAtual = null;
            leituraPausada = false;

            if (
                evento.error !== "canceled" &&
                evento.error !== "interrupted"
            ) {
                atualizarStatusLeitor(
                    "Não foi possível reproduzir a leitura."
                );
            }

            atualizarControlesLeitor();
        };

        atualizarStatusLeitor("Preparando leitura...");
        atualizarControlesLeitor();

        sintetizador.speak(fala);
    }

    // ==========================================
    // SELEÇÃO DE TEXTO
    // ==========================================

    document.addEventListener("selectionchange", () => {
        if (!painel.hidden) return;

        const selecao = window.getSelection();

        if (selecao && !selecao.isCollapsed) {
            textoSelecionado = selecao.toString().trim();
        }
    });

    // ==========================================
    // EVENTOS DO LEITOR NO MODAL
    // ==========================================

    painel.addEventListener("click", evento => {
        const botao = evento.target.closest("[data-leitor]");

        if (!botao) return;

        switch (botao.dataset.leitor) {
            case "pagina":
                iniciarLeitura(obterTextoPrincipal());
                break;

            case "selecao":
                iniciarLeitura(textoSelecionado);
                break;

            case "pausar":
                pausarLeitura();
                break;

            case "continuar":
                continuarLeitura();
                break;

            case "parar":
                pararLeitura();
                break;
        }
    });

    // ==========================================
    // NOVO: EVENTOS DO CONTROLE FLUTUANTE
    // ==========================================

    flutuantePausar.addEventListener(
        "click",
        pausarLeitura
    );

    flutuanteContinuar.addEventListener(
        "click",
        continuarLeitura
    );

    flutuanteParar.addEventListener(
        "click",
        () => pararLeitura()
    );

    // ==========================================
    // VELOCIDADE DA LEITURA
    // ==========================================

    velocidadeInput.addEventListener("input", () => {
        velocidadeValor.textContent =
            `${Number(velocidadeInput.value)
                .toFixed(2)
                .replace(".", ",")}x`;
    });

    if (!leitorDisponivel) {
        painel.querySelectorAll("[data-leitor]").forEach(botao => {
            botao.disabled = true;
        });

        atualizarStatusLeitor(
            "Leitura de texto indisponível neste navegador."
        );
    }

    atualizarControlesLeitor();

    window.addEventListener("pagehide", () => {
        pararLeitura(false);
    });

    // ==========================================
    // ABRIR E FECHAR O PAINEL
    // ==========================================

    let focoAnterior = null;
    let elementosInertes = [];

    function abrir() {
        if (!painel.hidden) return;

        focoAnterior = document.activeElement;

        fundo.hidden = false;
        painel.hidden = false;

        document.body.classList.add("a11y-modal-aberto");
        abrirBotao.setAttribute("aria-expanded", "true");

        elementosInertes = [];

        for (const filho of document.body.children) {
            if (
                filho !== painel &&
                filho !== fundo &&
                filho !== cursorDestaque
            ) {
                elementosInertes.push({
                    elemento: filho,
                    anterior: filho.inert
                });

                filho.inert = true;
            }
        }

        fecharBotao.focus();
    }

    function fechar() {
        if (painel.hidden) return;

        painel.hidden = true;
        fundo.hidden = true;

        document.body.classList.remove("a11y-modal-aberto");
        abrirBotao.setAttribute("aria-expanded", "false");

        elementosInertes.forEach(item => {
            item.elemento.inert = item.anterior;
        });

        elementosInertes = [];

        if (focoAnterior && focoAnterior.isConnected) {
            focoAnterior.focus();
        }
    }

    abrirBotao.addEventListener("click", abrir);
    fecharBotao.addEventListener("click", fechar);
    fundo.addEventListener("click", fechar);

    // ==========================================
    // NAVEGAÇÃO POR TECLADO
    // ==========================================

    document.addEventListener("keydown", evento => {
        if (painel.hidden) return;

        if (evento.key === "Escape") {
            evento.preventDefault();
            fechar();
            return;
        }

        if (evento.key !== "Tab") return;

        const elementos = [
            ...painel.querySelectorAll(
                "button:not([disabled]), input:not([disabled])"
            )
        ];

        if (!elementos.length) return;

        const primeiro = elementos[0];
        const ultimo = elementos[elementos.length - 1];

        if (evento.shiftKey) {
            if (
                document.activeElement === primeiro ||
                !painel.contains(document.activeElement)
            ) {
                evento.preventDefault();
                ultimo.focus();
            }
        } else {
            if (
                document.activeElement === ultimo ||
                !painel.contains(document.activeElement)
            ) {
                evento.preventDefault();
                primeiro.focus();
            }
        }
    });

    // ==========================================
    // ARMAZENAMENTO
    // ==========================================

    function salvar() {
        try {
            localStorage.setItem(
                STORAGE,
                JSON.stringify(config)
            );
        } catch (erro) {
            console.warn(
                "Não foi possível salvar as preferências.",
                erro
            );
        }
    }

    // ==========================================
    // APLICAR CONFIGURAÇÕES
    // ==========================================

    function aplicar() {
        const html = document.documentElement;

        if (config.fonte === 0) {
            html.style.removeProperty("font-size");
        } else {
            html.style.fontSize =
                `${100 + config.fonte * 10}%`;
        }

        if (config.letras === 0) {
            html.style.removeProperty("letter-spacing");
        } else {
            html.style.letterSpacing =
                `${config.letras * 0.04}em`;
        }

        if (config.linhas === 0) {
            html.style.removeProperty("--a11y-altura-linha");
        } else {
            html.style.setProperty(
                "--a11y-altura-linha",
                String(1.6 + config.linhas * 0.2)
            );
        }

        html.classList.toggle(
            "a11y-contraste",
            config.contraste
        );

        html.classList.toggle(
            "a11y-links",
            config.links
        );

        html.classList.toggle(
            "a11y-sem-imagens",
            config.imagens
        );

        html.classList.toggle(
            "a11y-sem-animacoes",
            config.animacoes
        );

        html.classList.toggle(
            "a11y-cursor",
            config.cursor
        );

        atualizarCursor();

        painel.querySelectorAll(".a11y-opcao").forEach(botao => {
            const acao = botao.dataset.acao;

            if (
                acao === "fonteMais" ||
                acao === "fonteMenos"
            ) {
                botao.removeAttribute("aria-pressed");
                return;
            }

            const ativo = (
                acao === "letras" ||
                acao === "linhas"
            )
                ? config[acao] > 0
                : Boolean(config[acao]);

            botao.setAttribute(
                "aria-pressed",
                String(ativo)
            );
        });

        salvar();
    }

    // ==========================================
    // EVENTOS DAS FERRAMENTAS
    // ==========================================

    painel.addEventListener("click", evento => {
        const botao = evento.target.closest("[data-acao]");

        if (!botao) return;

        const acao = botao.dataset.acao;

        switch (acao) {
            case "fonteMais":
                config.fonte = Math.min(config.fonte + 1, 5);
                break;

            case "fonteMenos":
                config.fonte = Math.max(config.fonte - 1, -2);
                break;

            case "letras":
                config.letras = (config.letras + 1) % 4;
                break;

            case "linhas":
                config.linhas = (config.linhas + 1) % 4;
                break;

            case "contraste":
            case "links":
            case "imagens":
            case "animacoes":
            case "cursor":
                config[acao] = !config[acao];
                break;

            default:
                return;
        }

        aplicar();
    });

    // ==========================================
    // RESTAURAR CONFIGURAÇÕES
    // ==========================================

    restaurarBotao.addEventListener("click", () => {
        config = { ...padrao };

        pararLeitura(false);

        velocidadeInput.value = "1";
        velocidadeValor.textContent = "1,00x";

        atualizarStatusLeitor(
            "Leitor pronto para utilização."
        );

        aplicar();
    });

    // ==========================================
    // POSICIONAMENTO DO VLIBRAS
    // ==========================================

    function posicionarVLibras() {
        const wrapper = document.getElementById(
            "vlibras-access-wrapper"
        );

        if (!wrapper || !wrapper.shadowRoot) {
            return false;
        }

        const raiz = wrapper.shadowRoot;

        if (raiz.getElementById("praca-vlibras-posicao")) {
            return true;
        }

        const estilo = document.createElement("style");
        estilo.id = "praca-vlibras-posicao";

        estilo.textContent = `
            #vlibras-access {
                position: fixed !important;
                top: auto !important;
                left: auto !important;
                right: 20px !important;
                bottom: 20px !important;
                margin: 0 !important;
                transform: none !important;
            }

            @media (max-width: 600px) {
                #vlibras-access {
                    right: 12px !important;
                    bottom: 12px !important;
                }
            }
        `;

        raiz.appendChild(estilo);

        return true;
    }

    if (!posicionarVLibras()) {
        const observador = new MutationObserver(() => {
            if (posicionarVLibras()) {
                observador.disconnect();
            }
        });

        observador.observe(document.documentElement, {
            childList: true,
            subtree: true
        });

        window.addEventListener(
            "pagehide",
            () => observador.disconnect(),
            { once: true }
        );
    }

    // ==========================================
    // INICIALIZAÇÃO
    // ==========================================

    aplicar();
})();
