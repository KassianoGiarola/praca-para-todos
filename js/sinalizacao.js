
/* ==========================================
   SINALIZAÇÃO - PRAÇA PARA TODOS
   Animações complementares
========================================== */

document.documentElement.classList.add("js");


/* ------------------------------------------
   1. ANIMAÇÕES DE ENTRADA
------------------------------------------ */

function iniciarAnimacoes() {

    const elementos = document.querySelectorAll(
        ".sinalizacao-hero .container, " +
        ".sinalizacoes-section .section-heading, " +
        ".diagnosticos-section .section-heading, " +
        ".sinalizacoes-section .sinalizacao-card, " +
        ".diagnosticos-section .diagnostico-card"
    );

    // Verifica a preferência de movimento do usuário
    const movimentoReduzido = window.matchMedia(
        "(prefers-reduced-motion: reduce)"
    ).matches;

    // Se o usuário prefere movimento reduzido,
    // os elementos aparecem imediatamente.
    if (movimentoReduzido) {
        elementos.forEach(elemento => {
            elemento.classList.add("js-reveal", "is-visible");
        });

        return;
    }

    // Adiciona as classes e o intervalo
    // entre as animações dos cards.
    elementos.forEach((elemento, index) => {

        elemento.classList.add("js-reveal");

        if (
            elemento.classList.contains("sinalizacao-card") ||
            elemento.classList.contains("diagnostico-card")
        ) {
            const atraso = (index % 2) * 120;

            elemento.style.setProperty(
                "--reveal-delay",
                `${atraso}ms`
            );
        }

    });


    /* --------------------------------------
       2. OBSERVADOR DE ROLAGEM
    -------------------------------------- */

    if ("IntersectionObserver" in window) {

        const observador = new IntersectionObserver(
            (entradas, observer) => {

                entradas.forEach(entrada => {

                    if (entrada.isIntersecting) {

                        entrada.target.classList.add("is-visible");

                        // Não repete a animação
                        observer.unobserve(entrada.target);

                    }

                });

            },
            {
                threshold: 0.12,
                rootMargin: "0px 0px -40px 0px"
            }
        );

        elementos.forEach(elemento => {
            observador.observe(elemento);
        });

    } else {

        // Compatibilidade com navegadores
        // que não possuem IntersectionObserver.

        elementos.forEach(elemento => {
            elemento.classList.add("is-visible");
        });

    }

}


/* ------------------------------------------
   3. INICIALIZAÇÃO
------------------------------------------ */

if (document.readyState === "loading") {

    document.addEventListener(
        "DOMContentLoaded",
        iniciarAnimacoes
    );

} else {

    iniciarAnimacoes();

}
