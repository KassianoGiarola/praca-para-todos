continuar = 'S'
qtd = [0] * 500

while continuar == 'S' or 's':

    a = input("Insira o tamanho do chinelo vendido: ")
    i = int(a)

    qtd[i] = qtd[i] + 1

    for tamanho in range(len(qtd)):
        if qtd[tamanho] > 0:
            print(f"Tamanho {tamanho}: {qtd[tamanho]} vendido(s)")

    continuar = input("Deseja continuar? ")