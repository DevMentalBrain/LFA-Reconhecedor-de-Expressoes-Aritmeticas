require_relative './utils/regra'

# Gramática para o Analisador de Earley
# Esta gramática é "Livre de Contexto", permitindo regras mais naturais.
$gramatica_earley = [
  # S = Sentença (O ponto de partida da nossa análise)
  Regra.new('S', ['S', '+', 'A'], rotulo_ast: 'soma'),
  Regra.new('S', ['S', '-', 'A'], rotulo_ast: 'subtracao'),
  Regra.new('S', ['A']),

  # A = Termos de Multiplicação e Divisão
  Regra.new('A', ['A', '*', 'B'], rotulo_ast: 'multiplicacao'),
  Regra.new('A', ['A', '/', 'B'], rotulo_ast: 'divisao'),
  Regra.new('A', ['B']),

  # B = Negação (números negativos) ou Expoente
  Regra.new('B', ['-', 'B'], rotulo_ast: 'negacao'),
  Regra.new('B', ['C']),

  # C = Operação de Potência (Exponenciação)
  Regra.new('C', ['D', '^', 'B'], rotulo_ast: 'potencia'),
  Regra.new('C', ['D']),

  # D = Parênteses ou Números isolados
  Regra.new('D', ['(', 'S', ')']),
  Regra.new('D', ['N']),

  # N = Números com um ou mais dígitos (Recursividade para formar números grandes)
  Regra.new('N', ['O', 'N'], rotulo_ast: 'numero'),
  Regra.new('N', ['O'], rotulo_ast: 'numero'),

  # O = Dígitos individuais de 0 a 9
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

# Gramática na Forma Normal de Chomsky (FNC)
# Necessária para o funcionamento do algoritmo CYK.
# Aqui, cada regra só pode resultar em EXATAMENTE dois não-terminais ou um terminal.
$gramatica_fnc = [
  # 1. Transformação de Símbolos Terminais em Variáveis
  Regra.new('PLUS',  ['+']),
  Regra.new('MINUS', ['-']),
  Regra.new('TIMES', ['*']),
  Regra.new('DIV',   ['/']),
  Regra.new('POW',   ['^']),
  Regra.new('LPAR',  ['(']),
  Regra.new('RPAR',  [')']),

  # 2. Variáveis Auxiliares
  # Como a FNC só aceita duplas (A -> B C), precisamos quebrar regras longas.
  Regra.new('S_PLUS',  ['PLUS', 'A']),
  Regra.new('S_MINUS', ['MINUS', 'A']),
  Regra.new('A_MULT',  ['TIMES', 'B']),
  Regra.new('A_DIV',   ['DIV', 'B']),
  Regra.new('C_POW',   ['POW', 'B']),
  Regra.new('D_RPAR',  ['S', 'RPAR']),
]

# 3. Adicionando os dígitos básicos como terminais
(0..9).each do |d|
  $gramatica_fnc << Regra.new('O', [d.to_s])
end

# =============================================================================
# 4. PROCESSO DE HERANÇA (Resolvendo Regras Unitárias)
# =============================================================================
# O algoritmo CYK não lida bem com regras do tipo A -> B (regras unitárias).
# Para resolver isso, fazemos com que a variável de cima "herde" as produções da de baixo.

# Definimos as produções básicas (que já estão em conformidade com a FNC)
# Cada par aqui é [lado_direito, rotulo_ast]
regras_base_N = [[['O', 'N'], 'numero']] + (0..9).map { |d| [[d.to_s], 'numero'] }
regras_base_D = [[['LPAR', 'D_RPAR'], nil]]
regras_base_C = [[['D', 'C_POW'], 'potencia']]
regras_base_B = [[['MINUS', 'B'], 'negacao']]
regras_base_A = [[['A', 'A_MULT'], 'multiplicacao'], [['A', 'A_DIV'], 'divisao']]
regras_base_S = [[['S', 'S_PLUS'], 'soma'], [['S', 'S_MINUS'], 'subtracao']]

# Cascata de Herança: Cada nível herda as possibilidades do nível inferior.
todas_regras_N = regras_base_N
todas_regras_D = regras_base_D + todas_regras_N
todas_regras_C = regras_base_C + todas_regras_D
todas_regras_B = regras_base_B + todas_regras_C
todas_regras_A = regras_base_A + todas_regras_B
todas_regras_S = regras_base_S + todas_regras_A

# Finalizando a montagem da gramática FNC para os Analisadores
todas_regras_N.each { |dir, rot| $gramatica_fnc << Regra.new('N', dir, rotulo_ast: rot) }
todas_regras_D.each { |dir, rot| $gramatica_fnc << Regra.new('D', dir, rotulo_ast: rot) }
todas_regras_C.each { |dir, rot| $gramatica_fnc << Regra.new('C', dir, rotulo_ast: rot) }
todas_regras_B.each { |dir, rot| $gramatica_fnc << Regra.new('B', dir, rotulo_ast: rot) }
todas_regras_A.each { |dir, rot| $gramatica_fnc << Regra.new('A', dir, rotulo_ast: rot) }
todas_regras_S.each { |dir, rot| $gramatica_fnc << Regra.new('S', dir, rotulo_ast: rot) }
