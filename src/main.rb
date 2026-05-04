require_relative 'parser/earley'
require_relative 'parser/cyk'
require_relative 'gramatica'

if ARGV.empty?
  puts "Uso: ruby src/main.rb \"expressao\""
  exit
end

expressao = ARGV[0]
tokens = expressao.gsub(/\s+/, '').split('')

puts "--- ANALISANDO COM EARLEY ---"
analisador_earley = AnalisadorEarley.new($gramatica_earley, 'S')
resultado_earley = analisador_earley.analisar(tokens)
p resultado_earley

puts "\n--- ANALISANDO COM CYK ---"
analisador_cyk = AnalisadorCYK.new($gramatica_fnc, 'S')
resultado_cyk = analisador_cyk.analisar(tokens)
p resultado_cyk
