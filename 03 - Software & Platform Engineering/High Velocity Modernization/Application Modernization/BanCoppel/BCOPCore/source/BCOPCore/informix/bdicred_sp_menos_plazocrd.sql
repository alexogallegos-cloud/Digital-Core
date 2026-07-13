CREATE PROCEDURE "informix".sp_menos_plazocrd(p_Empresa     CHAR(3),
                                           p_NumCredito  CHAR(20),
                                           p_Monto       MONEY(14,2))

   RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2); -- Remanente

   DEFINE GLOBAL g_SdoRetenido     MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_StCred          CHAR(2)       DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Cubre_Cuota     CHAR(1)       DEFAULT ' ';

   DEFINE  CodRet            CHAR(5);
   DEFINE  v_fcuota          DATE;
   DEFINE  vMtoPagado        MONEY(14,2);
   DEFINE  vMtoInteres       MONEY(14,2);
   DEFINE  vFechaHoy         date;
   DEFINE  vNumPag           INTEGER;
   DEFINE   vStatus           CHAR(1);

   --SET DEBUG FILE TO "/tmp/menosplazo.out";
   --TRACE ON;

   LET CodRet     = "000";
   let vFechaHoy  = '';
   LET vNumPag    = 0;
   LET vStatus    = '';
   LET g_Cubre_Cuota = '0';

   SELECT fecha_hoy INTO vFechaHoy FROM sd_fechas WHERE empresa = p_Empresa;
   FOREACH
         SELECT fecha_cuota INTO v_fcuota FROM sd_amortiza_creditocrd
         WHERE empresa = p_Empresa and num_credito = p_NumCredito and
               capital_status  IN ("1","2","3","6") 
         Order by fecha_cuota  DESC
         IF g_Remanente > 0 THEN
            IF g_StCred IN ("VP","BT","E3") THEN
               CALL cobracapvencidocrd(v_fcuota) RETURNING CodRet;
            ELSE
               CALL cobracapvigentecrd (v_fcuota) RETURNING CodRet;
            END IF;
            IF CodRet <> '000' THEn
               Return CodRet,g_Remanente;
{            ELSE
               Let vNumPag  = vNumPag + 1;
               UPDATE sd_amortiza_creditocrd set capital_status = '5',
                                           capital_status_ant = '3'
               wHERE num_credito = p_Numcredito and empresa = p_Empresa and fecha_cuota = v_fcuota;}
            END IF;
         END IF;
    END FOREACH;
 return CodRet,g_Remanente;

END PROCEDURE
;