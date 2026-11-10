
/* ==========================================
   JavaScript Global
========================================== */


/* ==========================================
   Menu navegação mobile
========================================== */

const botaoMenu = document.querySelector('.botao-menu');
const menuPrincipal = document.querySelector('#menu-principal');

// Verifica se os elementos existem na página
if (botaoMenu && menuPrincipal) {

    // Abrir e fechar o menu ao clicar no botão
    botaoMenu.addEventListener('click', () => {
        const aberto = menuPrincipal.classList.toggle('aberto');

        botaoMenu.setAttribute('aria-expanded', String(aberto));

        botaoMenu.setAttribute(
            'aria-label',
            aberto ? 'Fechar menu' : 'Abrir menu'
        );
    });

    // Fechar o menu ao pressionar a tecla Escape
    document.addEventListener('keydown', (evento) => {

        if (
            evento.key === 'Escape' &&
            menuPrincipal.classList.contains('aberto')
        ) {
            menuPrincipal.classList.remove('aberto');

            botaoMenu.setAttribute('aria-expanded', 'false');
            botaoMenu.setAttribute('aria-label', 'Abrir menu');

            // Devolve o foco ao botão do menu
            botaoMenu.focus();
        }
    });

}
