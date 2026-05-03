class Rule
  attr_reader :left, :right

  def initialize(left, right)
    @left = left  # String: Lado esquerdo (Ex: 'E')
    @right = right  # Array de Strings: Lado direito (Ex: ['E', '+', 'T'])
  end

  def to_s
    "#{@left} -> #{@right.join(' ')}"
  end
end

# Estado específico da gramática
class State
  attr_reader :rule, :dot, :origin

  def initialize(rule, dot, origin)
    @rule = rule
    @dot = dot          # Posição do '•' no array right
    @origin = origin    # De qual conjunto S[k] essa regra nasceu
  end

  # O ponto chegou no final da regra?
  def complete?
    @dot >= @rule.right.length
  end

  # Qual é o símbolo depois do ponto?
  def next_symbol
    @rule.right[@dot]
  end

  # Sobrescrita de igualdade para evitar regras duplicadas no Array
  def ==(other)
    @rule == other.rule && @dot == other.dot && @origin == other.origin
  end

  def to_s
    right_str = @rule.right.dup
    right_str.insert(@dot, "•")
    "#{@rule.left} -> #{right_str.join(' ')} | [#{@origin}]"
  end
end

class EarleyParser
  def initialize(grammar, start_symbol)
    @grammar = grammar
    @start_symbol = start_symbol
  end

  def parse(tokens)
    @tokens = tokens
    @S = Array.new(tokens.length + 1) { [] } # Nossa matriz de estados S

    # 1. Cria uma regra falsa para iniciar o parser
    dummy_rule = Rule.new('START', [@start_symbol])
    enqueue(State.new(dummy_rule, 0, 0), 0)

    # 2. Loop Principal
    (0..tokens.length).each do |i|
      state_idx = 0
      puts "\n\n--- PASSO #{i} ---"
      
      # Usamos um while pq o tamanho de @S[i] cresce dinamicamente durante a execução
      while state_idx < @S[i].length
        state = @S[i][state_idx]

        if state.complete?
          completer(state, i)
          puts "[COMPLETAR] #{state}"
        elsif non_terminal?(state.next_symbol)
          predictor(state, i)
          puts "[PREDIÇÃO] #{state}"
        else
          scanner(state, i)
          puts "[LEITURA] #{state}"
        end

        state_idx += 1
      end
    end

    # 3. A regra falsa inicial conseguiu fechar até o último conjunto?
    success_state = State.new(dummy_rule, 1, 0)
    
    puts "\n--- RESULTADO ---"
    if @S[tokens.length].any? { |s| s == success_state }
      puts "Expressão Válida!"
      return true
    else
      puts "Erro de Sintaxe!"
      return false
    end
  end

  private

  def predictor(state, i)
    non_terminal = state.next_symbol
    @grammar.each do |rule|
      if rule.left == non_terminal
        enqueue(State.new(rule, 0, i), i)
      end
    end
  end

  def scanner(state, i)
    if i < @tokens.length && state.next_symbol == @tokens[i]
      enqueue(State.new(state.rule, state.dot + 1, state.origin), i + 1)
    end
  end

  def completer(state, i)
    origin = state.origin
    @S[origin].each do |old_state|
      if !old_state.complete? && old_state.next_symbol == state.rule.left
        enqueue(State.new(old_state.rule, old_state.dot + 1, old_state.origin), i)
      end
    end
  end

  # --- UTILITÁRIOS ---

  def enqueue(state, chart_index)
    unless @S[chart_index].any? { |s| s == state }
      @S[chart_index] << state
    end
  end

  def non_terminal?(symbol)
    symbol.match?(/^[A-Z]/) || symbol == 'START'
  end
end
