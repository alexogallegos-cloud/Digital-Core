# Ground Truth — Ciclos / SCCs · openpay-gateway

> Las dependencias circulares entre `@Service` rompen el orden topologico: no hay
> "orden de migracion" obvio. En Spring suelen aparecer como circular bean
> dependencies parcheadas con `@Lazy` o setter injection. Detectarlas es critico
> para el wave planning.

## Ciclos plantados (6)
- Ciclo plantado 1 (7): SecService181 -> MerService155 -> ChnService051 -> CmpService213 -> TrmService074 -> TrmService242 -> CmpService298 -> SecService181
- Ciclo plantado 2 (6): RskService147 -> InfService257 -> PayService229 -> CmpService235 -> RskService232 -> TrmService202 -> RskService147
- Ciclo plantado 3 (6): ChnService126 -> FinService010 -> SecService244 -> FinService262 -> TrmService182 -> InfService214 -> ChnService126
- Ciclo plantado 4 (4): FinService292 -> FinService151 -> MerService120 -> RskService131 -> FinService292
- Ciclo plantado 5 (6): InfService167 -> MerService011 -> ChnService208 -> FinService140 -> CmpService215 -> CmpService117 -> InfService167
- Ciclo plantado 6 (7): InfService019 -> ChnService083 -> SecService199 -> CmpService197 -> CmpService112 -> TrmService148 -> SecService096 -> InfService019

## SCCs no triviales detectados en el grafo final (12)
- SCC 1 (tamano 43): ChnService083, ChnService126, ChnService208, CmpService112, CmpService117, CmpService197, CmpService215, CmpService235, FinService002, FinService010, FinService068, FinService127, FinService140, FinService151, FinService192, FinService262, FinService275, FinService277, FinService292, InfService019, InfService065, InfService167, InfService185, InfService209, InfService214, InfService257, MerService011, MerService120, PayService229, RskService032, RskService129, RskService131, RskService147, RskService173, RskService216, RskService232, SecService096, SecService199, SecService244, TrmService103, TrmService148, TrmService182, TrmService202
- SCC 2 (tamano 16): LegacyReport000, LegacyReport001, LegacyReport002, LegacyReport003, LegacyReport004, LegacyReport008, LegacyReport009, LegacyReport010, LegacyReport011, LegacyReport012, LegacyReport013, LegacyReport015, LegacyReport017, LegacyReport018, LegacyReport019, LegacyReport021
- SCC 3 (tamano 7): ChnService051, CmpService213, CmpService298, MerService155, SecService181, TrmService074, TrmService242
- SCC 4 (tamano 5): RskService073, RskService231, RskService251, RskService258, RskService297
- SCC 5 (tamano 5): TrmService037, TrmService054, TrmService149, TrmService154, TrmService236
- SCC 6 (tamano 4): InfService006, InfService028, InfService063, InfService195
- SCC 7 (tamano 4): MerService086, MerService142, MerService146, MerService234
- SCC 8 (tamano 2): SecService092, SecService130
- SCC 9 (tamano 2): InfService091, InfService271
- SCC 10 (tamano 2): PayService102, PayService200
- SCC 11 (tamano 2): PayService056, PayService159
- SCC 12 (tamano 2): InfService108, PayService084

`[BENCHMARK]` El nro de SCCs detectados puede exceder los plantados: el preferential
attachment + leakage pueden crear ciclos emergentes. Ambos cuentan como verdad.
