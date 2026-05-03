require_relative '../estado'
require_relative '../regra'

# O Analisador (Parser) de Earley propriamente dito
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

    # PASSO INICIAL: Criamos uma regra "mágica" para começar a análise
    regra_inicial = Regra.new('START', [@simbolo_inicial])
    adicionar_estado(Estado.new(regra_inicial, 0, 0), 0)

    # Percorremos cada posição da frase (de 0 até o final)
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
          predizer(estado, i)
        else
          # Se o próximo símbolo é um caractere fixo (ex: '+', '1'), tentamos ler da entrada
          escannear(estado, i)
        end

        indice_estado += 1
      end
    end

    # VEREDITO: Se encontrarmos a regra mágica completa no final, a frase é válida!
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

  # PREDIZER: Para um símbolo não-terminal (como 'S'), adiciona todas as suas regras à lista
  def predizer(estado, i)
    nao_terminal = estado.proximo_simbolo
    @gramatica.each do |regra|
      if regra.lado_esquerdo == nao_terminal
        adicionar_estado(Estado.new(regra, 0, i), i)
      end
    end
  end

  # ESCANNEAR: Se o símbolo atual da frase bate com o que a regra espera, avançamos o ponto
  def escannear(estado, i)
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
