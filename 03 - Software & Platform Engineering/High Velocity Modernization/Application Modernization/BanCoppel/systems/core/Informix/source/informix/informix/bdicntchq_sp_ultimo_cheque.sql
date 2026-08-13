CREATE PROCEDURE "informix".sp_ultimo_cheque(pempresa char(3),
                                             pcuenta char(20),
                                             pconsec integer,
                                             pstatus char(1))

RETURNING char(5),integer, date, money(14,2), integer;

define vcodret      CHAR(5);
define vfecha_mov   DATE;
define vimporte     MONEY(14,2);
define vnumero      INTEGER;
define vsqlerr      INTEGER;
define icuantos     INTEGER;



let vcodret = "000";
LET icuantos = 0;
LET vnumero  = 0;
LET vimporte = 0;

begin

   on exception set vsqlerr
      IF vsqlerr <> 0 then
         let vcodret = vsqlerr;
         RETURN vcodret, 0, null, 0,0;
      END IF
   END exception;

   --SET DEBUG FILE TO "/tmp/sp_ultimo_cheque.out";
   --TRACE ON;

   --//Busca el maximo cheque con las caracteristicas deseadas
--   SELECT MAX(numero),COUNT(*)
--     INTO vnumero,icuantos
   SELECT MAX(numero)
     INTO vnumero
     FROM bdicheq:sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta
      AND consec = pconsec
      AND estado = DECODE(pstatus,"",estado,pstatus);

   SELECT COUNT(*)
     INTO icuantos
     FROM bdicheq:sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta
      AND consec = pconsec
      AND estado IN ('A','E','S');

   SELECT fecha_alta, importe
     INTO vfecha_mov, vimporte
     FROM bdicheq:sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta
      AND consec = pconsec
      AND estado = DECODE(pstatus,"",estado,pstatus)
      AND numero = vnumero;

   LET vnumero = nvl(vnumero,0);
   RETURN vcodret, vnumero, vfecha_mov, vimporte,icuantos;
END
END procedure;