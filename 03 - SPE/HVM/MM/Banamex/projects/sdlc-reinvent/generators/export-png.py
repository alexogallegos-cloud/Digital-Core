"""Exporta a PNG cualquier HTML del proyecto, recortando el fondo sobrante.

Uso:
    PYTHONUTF8=1 python generators/export-png.py propuesta/infografia-sdlc.html
    PYTHONUTF8=1 python generators/export-png.py propuesta/slide-enfoque-sdlc.html --alto 950
    PYTHONUTF8=1 python generators/export-png.py propuesta/infografia-sdlc.html --pdf

El lienzo se da con --alto. Si el contenido llega al borde inferior, el script
avisa: en ese caso hay que subir el alto y volver a correr. Con --pdf escribe
tambien un PDF imprimible del mismo HTML.

Requiere Chrome y Pillow. No depende del servidor local: lee el archivo directo.
"""
import argparse
import os
import subprocess
import sys

CHROME_CANDIDATOS = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]

ANCHO_POR_DEFECTO = 1600
ALTO_POR_DEFECTO = 3800


def localizar_navegador():
    for ruta in CHROME_CANDIDATOS:
        if os.path.isfile(ruta):
            return ruta
    sys.exit("No encontre Chrome ni Edge en las rutas conocidas.")


def correr(navegador, html, extra):
    url = "file:///" + os.path.abspath(html).replace("\\", "/")
    cmd = [navegador, "--headless", "--disable-gpu", "--hide-scrollbars",
           "--virtual-time-budget=4000"] + extra + [url]
    subprocess.run(cmd, check=False, capture_output=True)


def recortar(origen, destino):
    """Quita el fondo del navegador por los cuatro lados.

    Sirve igual para una pieza vertical que crece hacia abajo y para una lamina
    16 por 9 que se centra en la ventana. Devuelve el tamano final y si el
    contenido toca algun borde del lienzo, que es la senal de que quedo cortado.
    """
    from PIL import Image, ImageChops
    im = Image.open(origen).convert("RGB")
    ancho, alto = im.size
    fondo = im.getpixel((ancho - 2, alto - 2))
    caja = ImageChops.difference(im, Image.new("RGB", im.size, fondo)).getbbox()
    if caja is None:                       # lienzo entero del color de fondo
        return (ancho, alto), True
    izq, arr, der, aba = caja
    al_borde = izq == 0 and arr == 0 and der == ancho and aba == alto
    im.crop(caja).save(destino)
    return (der - izq, aba - arr), al_borde


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("html", help="Ruta del HTML a exportar")
    ap.add_argument("--ancho", type=int, default=ANCHO_POR_DEFECTO)
    ap.add_argument("--alto", type=int, default=ALTO_POR_DEFECTO,
                    help="Alto del lienzo. Subelo si el aviso dice que quedo recortado")
    ap.add_argument("--salida", help="PNG de salida. Por defecto, junto al HTML")
    ap.add_argument("--pdf", action="store_true", help="Escribe tambien un PDF imprimible")
    args = ap.parse_args()

    if not os.path.isfile(args.html):
        sys.exit("No existe: %s" % args.html)

    navegador = localizar_navegador()
    base = os.path.splitext(os.path.abspath(args.html))[0]
    destino = args.salida or (base + ".png")
    crudo = base + ".__crudo.png"

    correr(navegador, args.html,
           ["--window-size=%d,%d" % (args.ancho, args.alto),
            "--screenshot=%s" % crudo])

    if not os.path.isfile(crudo):
        sys.exit("El navegador no escribio la captura.")

    (w, h), al_borde = recortar(crudo, destino)
    os.remove(crudo)
    print("PNG: %s  %dx%d" % (destino, w, h))
    if al_borde:
        print("AVISO: el contenido toca los cuatro bordes del lienzo y es probable")
        print("       que quedara cortado. Vuelve a correr con --alto mayor que %d" % args.alto)
        print("       o --ancho mayor que %d." % args.ancho)

    if args.pdf:
        pdf = base + ".pdf"
        correr(navegador, args.html,
               ["--print-to-pdf=%s" % pdf, "--no-pdf-header-footer"])
        print("PDF: %s" % pdf)


if __name__ == "__main__":
    main()
