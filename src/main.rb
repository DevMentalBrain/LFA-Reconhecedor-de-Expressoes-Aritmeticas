require_relative 'parser/early'
require_relative 'gramatica'

if ARGV.empty?
  puts "Uso: ruby src/main.rb \"expressao\""
  exit
end

expressao = ARGV[0]
tokens = expressao.gsub(/\s+/, '').split('')

analisador_earley = AnalisadorEarley.new(Gramatica.new, tokens[0])
analisador_earley.analisar(tokens)

# analisador_chumsky = AnalisadorChumsky.new(Gramatica.new, tokens[0])
# analisador_chumsky.analisar(tokens)

