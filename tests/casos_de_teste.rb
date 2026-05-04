# Lista de expressões matemáticas e seus respectivos ASTs esperados

CASOS_VALIDOS = {
  "(1 + 4) * 2^4"     => ["multiplicacao", ["soma", 1, 4], ["potencia", 2, 4]],
  "7 / ( 1 - 3 )"     => ["divisao", 7, ["subtracao", 1, 3]],
  "9^(1 * 6 / 2 + 4)" => ["potencia", 9, ["soma", ["divisao", ["multiplicacao", 1, 6], 2], 4]],
  "2 + 4 ^ -4 / 4"    => ["soma", 2, ["divisao", ["potencia", 4, ["negacao", 4]], 4]]
}

EXPRESSOES_INVALIDAS = [
  "^ 2 + 4",
  "9 * 2 +",
  "9 + + 3",
  "( ) * 3",
  "( 3 + 3"
]
