CREATE PROCEDURE "informix".sp_obtener_longitudes_bpi(pEmpresa char(3))
        RETURNING char(5), char(5), char(5);

---------------------------------------------------------------------------------------------------
-- Realizó   : Javier Humberto Calderon Zazueta
-- Actividad : Pago Tarjeta Credito Bancoppel
-- Solicitó  : Diana Castellanos
-- Fecha     :  26/05/2008
---------------------------------------------------------------------------------------------------
-- Realizó   : Alfredo Avena
-- Actividad : Pago Tarjeta Credito Bancoppel, se modifica el nombre del sp
-- Solicitó  : Mauricio León
-- Fecha     :  20/09/2008
---------------------------------------------------------------------------------------------------

       DEFINE vcodret   char(5);
       DEFINE vLongDebito   char(5);
       DEFINE vLongCredito   char(5);
       DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vLongDebito, vLongCredito;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vLongDebito = '0';
LET vLongCredito = '0';

--Set debug file to '/tmp/traspasobanco/bpi_trasacciones.out';
--trace on;
BEGIN
    SELECT valor INTO vLongCredito FROM bdicred:sd_param WHERE empresa = pEmpresa AND cod_param = '8';

    SELECT valor INTO vLongDebito FROM bdicheq:sc_param WHERE empresa = pEmpresa AND codparam = 'longcta';

END;
RETURN vcodret, vLongDebito, vLongCredito;

END PROCEDURE ;