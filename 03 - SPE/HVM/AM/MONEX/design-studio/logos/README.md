# Logos MONEX

Deja aquí los logotipos de MONEX. El generador de portales (`monex-brain/generators/build-panorama.py`)
los busca por nombre y los embebe automáticamente en base64 al regenerar.

## Nombres canónicos esperados

| Archivo | Uso |
|---------|-----|
| `monex-logo-white.png` | Logo blanco para fondos oscuros (hero navy). **Preferido por el portal.** |
| `monex-logo.png` | Logo a color para fondos claros. |
| `monex-logo.svg` | Versión vectorial (opcional, ideal para escalado). |

## Orden de preferencia del generador

Para el hero (fondo navy) el generador intenta, en orden:
`monex-logo-white.png` → `monex-logo.svg` → `monex-logo.png` → `Monex_logo.png`.

Si no encuentra ninguno, cae a un wordmark de texto "MONEX" y avisa en consola.
Después de dejar el archivo aquí, regenera:

```bash
cd monex-brain
python generators/build-panorama.py
```
