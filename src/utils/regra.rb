# Representa uma regra de produção da gramática (ex: E -> E + T)
class Regra
  attr_reader :lado_esquerdo, :lado_direito, :rotulo_ast

  def initialize(lado_esquerdo, lado_direito, rotulo_ast: nil)
    @lado_esquerdo = lado_esquerdo  # String: O símbolo que será expandido (Ex: 'E')
    @lado_direito = lado_direito    # Array de Strings: O que o símbolo se torna (Ex: ['E', '+', 'T'])
    @rotulo_ast = rotulo_ast        # String: Nome do nó na árvore (Ex: 'soma')
  end

  def to_s
    "#{@lado_esquerdo} -> #{@lado_direito.join(' ')}"
  end
end
