require_relative '../src/parser/early'
require_relative '../src/gramatica'

# Função auxiliar para rodar um teste e verificar se o resultado foi o esperado
def validar_expressao(analisador, texto_expressao, esperado_valido)
  # Tokenizador simples: Remove espaços e quebra a string em caracteres individuais
  tokens = texto_expressao.gsub(/\s+/, '').split('')
  
  puts "\nTestando: \"#{texto_expressao}\""
  resultado = analisador.analisar(tokens)
  
  if resultado == esperado_valido
    status = esperado_valido ? "aceita" : "rejeitada"
    puts "✅ SUCESSO: A expressão foi #{status} como esperado."
  else
    status_errado = resultado ? "aceita" : "rejeitada"
    status_esperado = esperado_valido ? "aceita" : "rejeitada"
    puts "❌ FALHA: A expressão foi #{status_errado}, mas deveria ser #{status_esperado}."
    exit 1
  end
end

# Criamos o analisador com a nossa gramática começando pelo símbolo 'S'
analisador = AnalisadorEarley.new($gramatica, 'S')

puts "=== INICIANDO TESTES DO ANALISADOR DE EARLEY ==="

# Exemplos de expressões válidas
expressoes_validas = [
  "(1 + 4) * 2^4",
  "7 / ( 1 - 3 )",
  "9^(1 * 6 / 2 + 4)",
  "2 + 4 ^ -4 / 4"
]

# Exemplos de expressões inválidas
expressoes_invalidas = [
  "^ 2 + 4",
  "9 * 2 +",
  "9 + + 3",
  "( ) * 3",
  "( 3 + 3"
]

puts "\n--- Verificando expressões que DEVEM ser aceitas ---"
expressoes_validas.each do |expr|
  validar_expressao(analisador, expr, true)
end

puts "\n--- Verificando expressões que DEVEM ser rejeitadas ---"
expressoes_invalidas.each do |expr|
  validar_expressao(analisador, expr, false)
end

puts "\n✨ Todos os testes passaram com sucesso!"
