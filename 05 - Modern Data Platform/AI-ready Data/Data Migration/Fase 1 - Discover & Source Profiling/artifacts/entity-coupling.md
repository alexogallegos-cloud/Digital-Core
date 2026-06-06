# Cross-System Entity Coupling (el acoplamiento OCULTO)

> Analogo del copybook coupling de Mainframe: el cliente es la MISMA entidad en SAP
> (BUT000) y CRM (crm_account), y ningun FK lo muestra. Esto dispara MDM/entity resolution.

| Metrica | Valor |
|---|---|
| Clientes SAP (BUT000) | 300 |
| Cuentas CRM totales | 275 |
| CRM con sap_partner_ref (match exacto) | 116 |
| CRM sin ref (requieren fuzzy) | 159 |
| Fuzzy hits por nombre+pais (descubierto) | 136 |
| Nombres CRM duplicados (problema MDM) | 107 |

`[HALLAZGO]` El cliente requiere **Master/Consolidate**: resolver SAP<->CRM (ref exacto + fuzzy nombre+pais) y mergear duplicados a un golden record. Es el trabajo no obvio que un plan basado solo en FK no ve.
