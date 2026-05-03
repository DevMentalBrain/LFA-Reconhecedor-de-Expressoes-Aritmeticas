# Representa uma regra de produção da gramática (ex: E -> E + T)
class Regra
  attr_reader :lado_esquerdo, :lado_direito

  def initialize(lado_esquerdo, lado_direito)
    @lado_esquerdo = lado_esquerdo  # String: O símbolo que será expandido (Ex: 'E')
    @lado_direito = lado_direito    # Array de Strings: O que o símbolo se torna (Ex: ['E', '+', 'T'])
  end

  def to_s
    "#{@lado_esquerdo} -> #{@lado_direito.join(' ')}"
  end
end
