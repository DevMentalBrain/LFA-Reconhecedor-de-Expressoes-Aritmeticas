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
