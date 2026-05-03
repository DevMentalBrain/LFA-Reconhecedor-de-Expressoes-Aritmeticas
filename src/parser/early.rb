# Estrutura base para as regras de produção da Gramática
class Rule
  attr_reader :lhs, :rhs

  def initialize(lhs, rhs)
    @lhs = lhs  # String: Lado esquerdo (Ex: 'E')
    @rhs = rhs  # Array de Strings: Lado direito (Ex: ['E', '+', 'T'])
  end

  def to_s
    "#{@lhs} -> #{@rhs.join(' ')}"
  end
end

# Representa uma "Linha do Tempo" / Hipótese no conjunto S
class State
  attr_reader :rule, :dot, :origin

  def initialize(rule, dot, origin)
    @rule = rule
    @dot = dot          # Posição do '•' no array rhs
    @origin = origin    # De qual conjunto S[k] essa regra nasceu
  end

  # O ponto chegou no final da regra?
  def complete?
    @dot >= @rule.rhs.length
  end

  # Qual é o símbolo imediatamente após o ponto?
  def next_symbol
    @rule.rhs[@dot]
  end

  # Sobrescrita de igualdade para evitar regras duplicadas no Array
  def ==(other)
    @rule == other.rule && @dot == other.dot && @origin == other.origin
  end

  def to_s
    rhs_str = @rule.rhs.dup
    rhs_str.insert(@dot, "•")
    "#{@rule.lhs} -> #{rhs_str.join(' ')} | [#{@origin}]"
  end
end

# O Tanque de Guerra
class EarleyParser
  def initialize(grammar, start_symbol)
    @grammar = grammar
    @start_symbol = start_symbol
  end

  def parse(tokens)
    @tokens = tokens
    @S = Array.new(tokens.length + 1) { [] } # Nossa matriz de estados S

    # 1. Ignição: Cria uma regra falsa "Start -> E" para iniciar a máquina
    dummy_rule = Rule.new('^', [@start_symbol])
    enqueue(State.new(dummy_rule, 0, 0), 0)

    # 2. O Loop Principal do Motor
    (0..tokens.length).each do |i|
      state_idx = 0
      
      # Usamos um while pq o tamanho de @S[i] cresce dinamicamente durante a execução
      while state_idx < @S[i].length
        state = @S[i][state_idx]

        if state.complete?
          completer(state, i)
        elsif non_terminal?(state.next_symbol)
          predictor(state, i)
        else
          scanner(state, i)
        end

        state_idx += 1
      end
    end

    # 3. O Veredito: A regra falsa inicial conseguiu fechar até o último conjunto?
    success_state = State.new(dummy_rule, 1, 0)
    
    puts "\n--- VEREDITO ---"
    if @S[tokens.length].any? { |s| s == success_state }
      puts "Expressão Válida!"
      return true
    else
      puts "Erro de Sintaxe!"
      return false
    end
  end

  # --- AS 3 ENGRENAGENS ---

  private

  # O Estrategista
  def predictor(state, i)
    non_terminal = state.next_symbol
    @grammar.each do |rule|
      if rule.lhs == non_terminal
        enqueue(State.new(rule, 0, i), i)
      end
    end
  end

  # O Batedor de Frente (O único que arremessa pro próximo array S[i+1])
  def scanner(state, i)
    if i < @tokens.length && state.next_symbol == @tokens[i]
      enqueue(State.new(state.rule, state.dot + 1, state.origin), i + 1)
    end
  end

  # O Mensageiro da Vitória (Volta no tempo)
  def completer(state, i)
    origin = state.origin
    @S[origin].each do |old_state|
      if !old_state.complete? && old_state.next_symbol == state.rule.lhs
        enqueue(State.new(old_state.rule, old_state.dot + 1, old_state.origin), i)
      end
    end
  end

  # --- UTILITÁRIOS ---

  def enqueue(state, chart_index)
    # A blindagem anti-loop infinito
    unless @S[chart_index].any? { |s| s == state }
      @S[chart_index] << state
    end
  end

  def non_terminal?(symbol)
    # Convenção clássica: Letras maiúsculas são variáveis.
    symbol.match?(/^[A-Z]/) || symbol == '^'
  end
end

# ==========================================
# TESTE DE FOGO COM A NOSSA GRAMÁTICA 
# ==========================================

grammar = [
  Rule.new('E', ['E', '+', 'T']),
  Rule.new('E', ['T']),
  Rule.new('T', ['3']),
  Rule.new('T', ['4'])
]

parser = EarleyParser.new(grammar, 'E')

# A fita léxica (Já fatiada, como o scanner léxico entregaria)
tokens = ['3', '+', '4']

puts "Processando a fita: #{tokens.inspect}"
parser.parse(tokens)
