print("My firt code in Python")

"""
Esse é um modelo de comentário em multiplas linhas

"""
#Esse é um modelo de comentário em uma linha
#Declaração de variáveis
x = 7
X = "Texto"
y = 'Texto'

#Em Python não é necessário declarar o tipo de variável
#Ele diferencia entre letras maiúsculas e minúsculas

#Esse é um modelo de print com end=" " para imprimir na mesma linha
print(x, end=" ")
print(X)

#Esse é um modelo de print para imprimir mais de uma variável
print(x, X, y, "simples")
print(X + "simples") #O + em variáveis do tipo int irá realizar a soma dos valores
#print("texto" + 2) #Isso irá causar um erro, pois não é possível concatenar uma string com um int

#Se quiser expecificar o tipo de variavel que será impressa
a = str(2) #a será uma string '2'
b = int(2) #b será um inteiro 2
c = float(2) #c será um float 2.0

#Para saber o tipo de uma variável, use a função type()
print(type(a))
print(type(b))
print(type(c))

#Podemos declarar multiplas variáveis de uma só vez
d, e, f = "Texto", 2, 2.0
#OU
g = h = i = "Texto" #Todas as variáveis serão do tipo string 'Texto'
#OU dessa forma, fazendo o unpacking de uma lista:
fruits = ["apple", "banana", "cherry"]
x, y, z = fruits #x será 'apple', y será 'banana' e z será 'cherry'

print(fruits[2])

#
# while
#
count = 0
while count <= 5:
    print(count)
    count += 1
else:
    print('após iteração')

#
# for
#
for i in range(5):
    print(i)
else:
    print('após iteração')