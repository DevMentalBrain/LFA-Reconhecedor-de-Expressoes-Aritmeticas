# Reconhecedor de Expressões Aritméticas (Earley & CYK)

Este projeto implementa dois algoritmos clássicos de análise sintática (parsing) para validar e processar expressões matemáticas, gerando uma Árvore de Sintaxe Abstrata (AST).

## 🚀 Como Executar

O ponto de entrada principal é o arquivo `src/main.rb`. Ele aceita uma expressão matemática como argumento e exibe a AST gerada por ambos os algoritmos.

```bash
ruby src/main.rb "(1 + 4) * 2^4"
```

**Exemplo de Saída:**
`["multiplicacao", ["soma", 1, 4], ["potencia", 2, 4]]`

---

## 🧪 Como Rodar os Testes

Existem suítes de testes separadas para validar cada algoritmo contra um conjunto compartilhado de expressões.

### Testar Analisador de Earley:
```bash
ruby tests/earley_test.rb
```

### Testar Analisador CYK:
```bash
ruby tests/cyk_test.rb
```

---

## 📚 Documentação dos Algoritmos

Implementação de cada analisador em uma expressão de exemplo:

- [Gramática de Earley](./docs/earley.md)
- [Gramática na Forma Normal de Chomsky](./docs/chomsky.md)

---

## 📁 Estrutura do Projeto

- `src/parser/`: Implementação dos algoritmos `earley.rb` e `cyk.rb`.
- `src/utils/`: Utilitários como a definição de `Regra`.
- `src/gramatica.rb`: Definições das gramáticas.
- `tests/`: Casos de teste compartilhados e scripts de validação.
- `docs/`: Documentação teórica.
