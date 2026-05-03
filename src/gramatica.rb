require_relative './utils/regra'

# Definição da Gramática para Expressões Matemáticas
$gramatica = [
  # S = Sentença (Início)
  Regra.new('S', ['S', '+', 'A']),
  Regra.new('S', ['S', '-', 'A']),
  Regra.new('S', ['A']),

  # A = Termos de Multiplicação/Divisão
  Regra.new('A', ['A', '*', 'B']),
  Regra.new('A', ['A', '/', 'B']),
  Regra.new('A', ['B']),

  # B = Negação ou Expoente
  Regra.new('B', ['-', 'B']),
  Regra.new('B', ['C']),

  # C = Expoente
  Regra.new('C', ['D', '^', 'B']),
  Regra.new('C', ['D']),

  # D = Parênteses ou Números
  Regra.new('D', ['(', 'S', ')']),
  Regra.new('D', ['N']),

  # N = Números com múltiplos dígitos
  Regra.new('N', ['O', 'N']),
  Regra.new('N', ['O']),

  # O = Dígitos únicos
  Regra.new('O', ['0']),
  Regra.new('O', ['1']),
  Regra.new('O', ['2']),
  Regra.new('O', ['3']),
  Regra.new('O', ['4']),
  Regra.new('O', ['5']),
  Regra.new('O', ['6']),
  Regra.new('O', ['7']),
  Regra.new('O', ['8']),
  Regra.new('O', ['9']),
]
