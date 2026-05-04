require_relative '../src/parser/cyk'
require_relative '../src/gramatica'
require_relative 'casos_de_teste'

def validar_cyk(analisador, texto_expressao, esperado)
  tokens = texto_expressao.gsub(/\s+/, '').split('')
  
  puts "\nTestando: \"#{texto_expressao}\""
  resultado = analisador.analisar(tokens)
  
  if resultado == esperado
    puts "✅ SUCESSO"
    p resultado if esperado.is_a?(Array)
  else
    puts "❌ FALHA"
    puts "Esperado: #{esperado.inspect}"
    puts "Obtido:   #{resultado.inspect}"
    exit 1
  end
end

analisador = AnalisadorCYK.new($gramatica_fnc, 'S')

puts "=== INICIANDO TESTES DO ANALISADOR CYK (AST) ==="

puts "\n--- Verificando expressões válidas (AST) ---"
CASOS_VALIDOS.each do |expr, ast_esperado|
  validar_cyk(analisador, expr, ast_esperado)
end

puts "\n--- Verificando expressões inválidas ---"
EXPRESSOES_INVALIDAS.each do |expr|
  validar_cyk(analisador, expr, "Erro de Sintaxe!")
end

puts "\n✨ Todos os testes do CYK (AST) passaram com sucesso!"
