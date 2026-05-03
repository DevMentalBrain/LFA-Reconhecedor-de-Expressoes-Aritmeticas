require_relative 'gramatica'

if ARGV.empty?
  puts "Uso: ruby src/main.rb \"expressao\""
  exit
end

expressao = ARGV[0]
tokens = expressao.gsub(/\s+/, '').split('')
analisador = AnalisadorEarley.new($gramatica, 'S')
analisador.analisar(tokens)
