require_relative '../utils/regra'

# Estrutura auxiliar para representar um nó na árvore de derivação do CYK
class NoFNC
  attr_reader :regra, :esq, :dir, :valor_terminal

  def initialize(regra, esq: nil, dir: nil, valor_terminal: nil)
    @regra = regra
    @esq = esq            # Filho da esquerda (outro NoFNC)
    @dir = dir            # Filho da direita (outro NoFNC)
    @valor_terminal = valor_terminal
  end

  def simbolo
    @regra.lado_esquerdo
  end
end

# O Algoritmo CYK (Cocke-Younger-Kasami)
class AnalisadorCYK
  def initialize(gramatica, simbolo_inicial)
    @gramatica = gramatica
    @simbolo_inicial = simbolo_inicial
  end

  def analisar(tokens)
    n = tokens.length
    return false if n == 0

    # A Matriz CYK agora guarda objetos NoFNC
    matriz = Array.new(n) { Array.new(n) { [] } }

    # PASSO 1: BASE DA PIRÂMIDE
    (0...n).each do |i|
      token_atual = tokens[i]
      @gramatica.each do |regra|
        if regra.lado_direito.length == 1 && regra.lado_direito[0] == token_atual
          no = NoFNC.new(regra, valor_terminal: token_atual)
          matriz[i][i] << no unless matriz[i][i].any? { |m| m.simbolo == regra.lado_esquerdo }
        end
      end
    end

    # PASSO 2: COMBINAÇÕES
    (2..n).each do |camada|
      (0..n - camada).each do |inicio|
        fim = inicio + camada - 1
        (inicio...fim).each do |corte|
          nos_esq = matriz[inicio][corte]
          nos_dir = matriz[corte + 1][fim]

          next if nos_esq.empty? || nos_dir.empty?

          nos_esq.each do |no_esq|
            nos_dir.each do |no_dir|
              @gramatica.each do |regra|
                if regra.lado_direito.length == 2 && 
                   regra.lado_direito[0] == no_esq.simbolo && 
                   regra.lado_direito[1] == no_dir.simbolo
                  
                  no = NoFNC.new(regra, esq: no_esq, dir: no_dir)
                  matriz[inicio][fim] << no unless matriz[inicio][fim].any? { |m| m.simbolo == regra.lado_esquerdo }
                end
              end
            end
          end
        end
      end
    end

    no_sucesso = matriz[0][n - 1].find { |no| no.simbolo == @simbolo_inicial }
    
    if no_sucesso
      return extrair_ast(no_sucesso)
    else
      return "Erro de Sintaxe!"
    end
  end

  private

  def extrair_ast(no)
    # Se a regra tem um rótulo AST (ex: 'soma', 'multiplicacao')
    if no.regra.rotulo_ast
      if no.regra.rotulo_ast == 'numero'
        return achatar_numero(no).to_i
      else
        argumentos = coletar_argumentos(no)
        return [no.regra.rotulo_ast, *argumentos]
      end
    end

    # Se for um terminal puro (sem rótulo)
    return no.valor_terminal if no.valor_terminal

    # Se for uma regra ponte ou variável auxiliar sem rótulo (FNC)
    filhos = [no.esq, no.dir].compact
    resultados = filhos.map { |f| extrair_ast(f) }.compact
    
    if resultados.length == 1
      return resultados[0]
    else
      return resultados
    end
  end

  def achatar_numero(no)
    return no.valor_terminal if no.valor_terminal
    
    res = ""
    res += achatar_numero(no.esq) if no.esq
    res += achatar_numero(no.dir) if no.dir
    res
  end

  def coletar_argumentos(no)
    args = []
    
    # Percorre a árvore procurando por sub-nós que tenham rótulo AST
    # ou que sejam terminais úteis (números)
    processar = [no.esq, no.dir].compact
    while !processar.empty?
      atual = processar.shift
      
      if atual.regra.rotulo_ast
        args << extrair_ast(atual)
      elsif atual.valor_terminal
        # Ignora pontuação (+, *, (, ) ) mas mantém se for algo importante
        # Na verdade, os rótulos já cobrem o que é importante.
      else
        # Se for uma variável auxiliar FNC (ex: S_PLUS), continua descendo
        processar.unshift(atual.dir) if atual.dir
        processar.unshift(atual.esq) if atual.esq
      end
    end
    args
  end
end
