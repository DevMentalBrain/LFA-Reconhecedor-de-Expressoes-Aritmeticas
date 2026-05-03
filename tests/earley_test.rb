require_relative '../src/parser/early'
require_relative '../src/grammar'

def assert_parse(parser, tokens_str, expected)
  tokens = tokens_str.gsub(/\s+/, '').split('')
  
  puts "\nTeste: \"#{tokens_str}\""
  result = parser.parse(tokens)
  
  if result == expected
    puts "✅ PASSOU: #{tokens_str} foi #{expected ? 'aceito' : 'rejeitado'} como esperado."
  else
    puts "❌ FALHOU: #{tokens_str} deveria ter sido #{expected ? 'aceito' : 'rejeitado'}."
    exit 1
  end
end

parser = EarleyParser.new($grammar, 'S')

puts "=== EXECUTANDO TESTES DO PARSER EARLEY ==="

# Valid expressions
valid_expressions = [
  "(1 + 4) * 2^4",
  "7 / ( 1 - 3 )",
  "9^(1 * 6 / 2 + 4)",
  "2 + 4 ^ -4 / 4"
]

# Invalid expressions
invalid_expressions = [
  "^ 2 + 4",
  "9 * 2 +",
  "9 + + 3",
  "( ) * 3",
  "( 3 + 3"
]

valid_expressions.each do |expr|
  assert_parse(parser, expr, true)
end

invalid_expressions.each do |expr|
  assert_parse(parser, expr, false)
end

puts "\n✨ Todos os testes foram executados com sucesso! ✨"
