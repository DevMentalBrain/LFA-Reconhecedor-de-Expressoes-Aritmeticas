require_relative '../utils/regra'

# Representa um "Estado" ou hipótese dentro do algoritmo de Earley
# Um estado é uma regra com um "ponto" (•) que indica o quanto já processamos dela.
class Estado
  attr_reader :regra, :ponto, :origem

  def initialize(regra, ponto, origem)
    @regra = regra
    @ponto = ponto      # Inteiro: Posição do '•' no array lado_direito
    @origem = origem    # Inteiro: Em qual posição da frase essa regra começou (S[k])
  end

  # Verifica se o ponto chegou ao fim da regra (regra totalmente processada)
  def completo?
    @ponto >= @regra.lado_direito.length
  end

  # Retorna o símbolo que está logo após o ponto (o que esperamos encontrar agora)
  def proximo_simbolo
    @regra.lado_direito[@ponto]
  end

  # Comparação de igualdade para evitar estados duplicados na nossa lista
  def ==(outro)
    @regra == outro.regra && @ponto == outro.ponto && @origem == outro.origem
  end

  def to_s
    # Cria uma visualização da regra com o ponto, ex: "E -> E • + T | [0]"
    copia_dir = @regra.lado_direito.dup
    copia_dir.insert(@ponto, "•")
    "#{@regra.lado_esquerdo} -> #{copia_dir.join(' ')} | [#{@origem}]"
  end
end

class AnalisadorEarley
  def initialize(gramatica, simbolo_inicial)
    @gramatica = gramatica
    @simbolo_inicial = simbolo_inicial
  end

  # Função principal que tenta validar uma lista de tokens (palavras/símbolos)
  def analisar(tokens)
    @tokens = tokens
    # Criamos uma tabela (Chart) onde cada entrada S[i] guarda os estados possíveis no passo i
    @S = Array.new(tokens.length + 1) { [] }

    # 1. Criamos uma regra inicial para começar a análise
    regra_inicial = Regra.new('START', [@simbolo_inicial])
    adicionar_estado(Estado.new(regra_inicial, 0, 0), 0)

    # Percorremos cada posição da expressão (do primeiro caractere até o final)
    (0..tokens.length).each do |i|
      indice_estado = 0
      
      # Processamos todos os estados encontrados para esta posição i
      # O loop 'while' é usado porque novos estados podem ser adicionados enquanto rodamos
      while indice_estado < @S[i].length
        estado = @S[i][indice_estado]

        if estado.completo?
          # Se a regra terminou, avisamos quem estava esperando por ela
          completar(estado, i)
        elsif nao_terminal?(estado.proximo_simbolo)
          # Se o próximo símbolo é uma variável (ex: S, A), expandimos suas possibilidades
          predicao(estado, i)
        else
          # Se o próximo símbolo é um caractere fixo (ex: '+', '1'), tentamos ler da entrada
          leitura(estado, i)
        end

        indice_estado += 1
      end
    end

    # Se encontrarmos a regra mágica completa no final, a expressão é válida!
    estado_sucesso = Estado.new(regra_inicial, 1, 0)
    
    if @S[tokens.length].any? { |s| s == estado_sucesso }
      puts "Resultado: Expressão Válida!"
      return true
    else
      puts "Resultado: Erro de Sintaxe!"
      return false
    end
  end

  private

  # PREDIÇÃO: Para um símbolo não-terminal (como 'S'), adiciona todas as suas regras à lista
  def predicao(estado, i)
    nao_terminal = estado.proximo_simbolo
    @gramatica.each do |regra|
      if regra.lado_esquerdo == nao_terminal
        adicionar_estado(Estado.new(regra, 0, i), i)
      end
    end
  end

  # LEITURA: Se o símbolo atual da frase bate com o que a regra espera, avançamos o ponto
  def leitura(estado, i)
    if i < @tokens.length && estado.proximo_simbolo == @tokens[i]
      # Movemos o ponto uma posição para a frente e jogamos para o próximo conjunto S[i+1]
      adicionar_estado(Estado.new(estado.regra, estado.ponto + 1, estado.origem), i + 1)
    end
  end

  # COMPLETAR: Quando uma regra termina, voltamos na origem para ver quem estava esperando esse símbolo
  def completar(estado, i)
    origem = estado.origem
    simbolo_concluido = estado.regra.lado_esquerdo

    @S[origem].each do |estado_antigo|
      if !estado_antigo.completo? && estado_antigo.proximo_simbolo == simbolo_concluido
        # Avançamos o ponto de quem estava esperando
        adicionar_estado(Estado.new(estado_antigo.regra, estado_antigo.ponto + 1, estado_antigo.origem), i)
      end
    end
  end

  # Adiciona um estado à lista, mas apenas se ele já não estiver lá (evita loops infinitos)
  def adicionar_estado(estado, indice_tabela)
    unless @S[indice_tabela].any? { |s| s == estado }
      @S[indice_tabela] << estado
    end
  end

  # Verifica se um símbolo é um "Não-Terminal" (Variável)
  # Por convenção, usamos letras MAIÚSCULAS para variáveis.
  def nao_terminal?(simbolo)
    simbolo.match?(/^[A-Z]/) || simbolo == 'START'
  end
end
