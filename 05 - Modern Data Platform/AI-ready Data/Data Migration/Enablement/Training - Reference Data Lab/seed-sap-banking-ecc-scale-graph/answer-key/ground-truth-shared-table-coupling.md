# Ground Truth - Shared-Table Coupling (el acoplamiento OCULTO)

> Analogo del copybook coupling de Mainframe. Tablas referenciadas por FK desde >=3
> modulos: acoplan modulos que 'deberian' estar separados. Un plan de waves basado solo
> en el call/FK graph por-modulo NO ve este acoplamiento -> causa #1 de fallo del Strangler.

| Tabla compartida | # modulos | modulos | rol |
|---|---|---|---|
| T001 | 9 | am_deposits, bp, cards, channels, cml_loans, co, collateral, dmee, payments | Company codes — referenced by every posting |
| TCURX | 9 | am_deposits, bp, cards, channels, cml_loans, co, collateral, dmee, payments | Decimal places per currency (amount conversion) |
| SKB1 | 9 | am_deposits, bp, cards, channels, cml_loans, co, collateral, dmee, payments | G/L account master (company-code level) |
| TCURC | 9 | am_deposits, bp, cards, channels, cml_loans, co, collateral, dmee, payments | Currency codes |
| VDBEPK | 9 | am_deposits, bp, cards, channels, co, collateral, dmee, fi_gl, payments | (generada) |
| BUT000 | 9 | am_deposits, cards, channels, cml_loans, co, collateral, dmee, fi_gl, payments | Business Partner — the customer, shared by all modules |
| SKA1 | 8 | am_deposits, bp, cards, channels, cml_loans, co, collateral, payments | G/L account master (chart of accounts) |
| CMS101 | 8 | bp, cards, channels, cml_loans, co, dmee, fi_gl, payments | (generada) |
| COKA | 6 | bp, cards, collateral, dmee, fi_gl, payments | (generada) |
| COBK | 6 | am_deposits, bp, cards, channels, fi_gl, payments | (generada) |
| BKK_CARD | 6 | channels, cml_loans, co, collateral, dmee, payments | (generada) |
| BKKC | 4 | bp, cards, cml_loans, collateral | (generada) |
| T042 | 4 | am_deposits, channels, dmee, fi_gl | (generada) |
| BKKA | 4 | channels, cml_loans, co, collateral | (generada) |
| FEB107 | 4 | am_deposits, cml_loans, dmee, payments | (generada) |
| T042Z | 4 | am_deposits, bp, channels, collateral | (generada) |
| FPAYP | 4 | cards, cml_loans, co, collateral | (generada) |
| CCARD101 | 4 | bp, cml_loans, dmee, fi_gl | (generada) |
| CCARD241 | 3 | co, collateral, dmee | (generada) |
| FEB110 | 3 | am_deposits, cards, fi_gl | (generada) |
| FPAYH | 3 | am_deposits, cards, collateral | (generada) |
| VTBBEWE | 3 | am_deposits, bp, collateral | (generada) |
| CCARDEC | 3 | channels, co, fi_gl | (generada) |
| DMEE_TREE_NODE | 3 | cml_loans, co, fi_gl | (generada) |
