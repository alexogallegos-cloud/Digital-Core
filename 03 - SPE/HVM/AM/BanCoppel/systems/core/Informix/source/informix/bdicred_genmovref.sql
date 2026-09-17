CREATE PROCEDURE "informix".genmovref(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_monto                  MONEY(14,2),
   p_folio                  VARCHAR(16),
   p_sucursal               CHAR(4),
   p_tarjeta                CHAR(20),
   p_referencia             VARCHAR(40))

RETURNING VARCHAR(5);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vFecHoy     DATE;
DEFINE vDivisa     CHAR(2);


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET vDivisa        = '';

  Select fecha_hoy Into vFecHoy From sd_fechas where empresa = p_empresa;
  Select divisa Into vDivisa From sd_maecred where empresa = p_empresa and num_credito = p_num_credito;

   CALL GenMov(p_empresa, p_num_credito, p_num_producto,20,
                  '336', vFecHoy, p_monto, p_folio,
                  p_sucursal, vDivisa, '0000') RETURNING
                  P_COD_RET, P_MENSAJE;
   IF (P_COD_RET <> "00000") THEN
         RETURN P_COD_RET;
   ELSE
         LET P_COD_RET = "000";
         UPDATE sd_movdia SET referencia23 = p_referencia,
                nro_tarjeta = p_Tarjeta 
         WHERE empresa = p_empresa and fecha_mov = vFecHoy and num_credito = p_num_credito and
               folio_suc = p_folio;
   END IF;
   RETURN P_COD_RET;

END;
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".act_amoiva(pempresa char(3))
returning char(5);



DEFINE vcodret       char(5);
DEFINE vsqlerr       smallint;
DEFINE vNumCredito   char(20);
DEFINE vSdoNoExig    decimal(14,2);
DEFINE vIva          decimal(14,2);





-- CONTROL DE ERRORES
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vcodret=vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

   --set debug file to "act_amoiva.out";
   --trace on;

   let vcodret       = "000";
   let vNumCredito   = '';
   let  vSdoNoExig   = 0;
   let  vIva         = 0;


   FOREACH
           SELECT interes_debe,num_credito INTO vSdoNoExig, vNumCredito FROM sd_amortiza_credito
           WHERE empresa = '001'  and fecha_cuota = '08/20/2008'
                 and iva_debe = 0 and interes_debe > 0

           Let vIva = vSdoNoExig * 0.132742;
           UPDATE sd_amortiza_credito set iva_debe = vIva
           WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '08/20/2008';

  END FOREACH;

  return vcodret;
END
END PROCEDURE;