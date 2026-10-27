const botaoMenu = document.querySelector('.botao-menu');
const menuPrincipal = document.querySelector('#menu-principal');

botaoMenu.addEventListener('click', () => {
    const aberto = menuPrincipal.classList.toggle('aberto');

    botaoMenu.setAttribute('aria-expanded', String(aberto));
    botaoMenu.setAttribute(
        'aria-label',
        aberto ? 'Fechar menu' : 'Abrir menu'
    );
}); 

document.addEventListener('keydown', (evento) => {
    if (evento.key === 'Escape' && menuPrincipal.classList.contains('aberto')){
        menuPrincipal.classList.remove('aberto');

        botaoMenu.setAttribute('aria-expanded', 'false');
        botaoMenu.setAttribute('aria-label', 'Abrir menu');

        botaoMenu.focus();
    }
});