# Regras da Gramática - Forma Normal de Chomsky (FNC)

As regras abaixo representam a gramática matemática convertida para a Forma Normal de Chomsky, utilizada pelo algoritmo CYK:

```bnf
S      -> S S_PLUS | S S_MINUS | A A_MULT | A A_DIV | MINUS B | D C_POW | LPAR D_RPAR | O N | 0..9
A      -> A A_MULT | A A_DIV | MINUS B | D C_POW | LPAR D_RPAR | O N | 0..9
B      -> MINUS B | D C_POW | LPAR D_RPAR | O N | 0..9
C      -> D C_POW | LPAR D_RPAR | O N | 0..9
D      -> LPAR D_RPAR | O N | 0..9
N      -> O N | 0..9
O      -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
S_PLUS -> PLUS A
S_MINUS-> MINUS A
A_MULT -> TIMES B
A_DIV  -> DIV B
C_POW  -> POW B
D_RPAR -> S RPAR
PLUS   -> +
MINUS  -> -
TIMES  -> *
DIV    -> /
POW    -> ^
LPAR   -> (
RPAR   -> )
```

![CYK Algorithm](grammars.png)
