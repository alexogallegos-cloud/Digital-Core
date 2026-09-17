CREATE PROCEDURE "informix".sp_gen_his_mc() RETURNING CHAR (5), CHAR(500);

/*
##############################################################################
#   Autor: ACCB                                                              #
#   Fecha: 08/01/2015                                                        #
#   Modificación: Ejecución del proceso diario de MC para Crédito  y Débito  #
#                 de Tablas Históricas                                       #
#                                                                            #
##############################################################################
*/

--MANEJO DE ERRORES
DEFINE iSqlErr                    INTEGER;
DEFINE cVarDataErr                CHAR(500);
DEFINE cVarDataErr1               CHAR(500);
DEFINE vFecha_hoy                 DATE;
DEFINE MesI                       CHAR(02);
DEFINE Mes_Ini                    SMALLINT;
DEFINE vAnio                      CHAR(04);
DEFINE vTrim                      CHAR(05);
DEFINE iContErr                   SMALLINT;
DEFINE cCodret1, cCodret2         CHAR(100);
DEFINE cError                     CHAR(50);
DEFINE cCodret                    CHAR(5);

ON EXCEPTION SET iSqlErr

SET DEBUG FILE TO "/home/sysdecli/sp_gen_his_mc.err";

LET iContErr = 0;
LET cCodret = '00000';
LET cCodret2 = '';
LET cVarDataErr = '';

--- MANEJO DE LOS ERRORES ---
   IF iSqlErr <> 0 THEN
      LET cVarDataErr = 'aa';
      LET cVarDataErr = cVarDataErr||'ERROR NO CONTROLADO (' || iSqlErr || ').';
      LET cCodret='-1';
      RETURN  cVarDataErr,cCodret;
   END IF;

END EXCEPTION;

---SET DEBUG FILE TO "/INFORMIXDUMP/acamargo/MASTERCARD/CCAMBIOS/SPs/sp_gen_his_mc.out";
---TRACE ON;


--- SELECCIÓN DEL DÍA PARA EJECUCIÓN
--SELECT fecha_hoy INTO vFecha_hoy FROM bdinteg:si_fechas;
LET vFecha_hoy = TODAY-1;
LET vAnio = YEAR(vFecha_hoy);
LET MesI = MONTH(vFecha_hoy);
LET Mes_Ini = MesI;

IF Mes_Ini = 1 OR Mes_Ini = 2 OR Mes_Ini = 3 THEN
   LET vTrim = Vanio||'1';
END IF;

IF Mes_Ini = 4 OR Mes_Ini = 5 OR Mes_Ini = 6 THEN
   LET vTrim = Vanio||'2';
END IF;

IF Mes_Ini = 7 OR Mes_Ini = 8 OR Mes_Ini = 9 THEN
   LET vTrim = Vanio||'3';
END IF;

IF Mes_Ini = 10 OR Mes_Ini = 11 OR Mes_Ini = 12 THEN
   LET vTrim = Vanio||'1';
END IF;


--- EJECUCIÓN DEL PROCEDIMIENTO ALMACENADO PARA CRÉDITO HISTÓRICO --
EXECUTE PROCEDURE "informix".sp_mc_cal_dia_ch (vFecha_hoy, vTrim, Mes_Ini)
                                              INTO cCodret,cVarDataErr;

IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_dia_ch'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;
   
--- EJECUCIÓN DEL PROCEDIMIENTO ALMACENADO PARA DÉBITO HISTÓRICO--
EXECUTE PROCEDURE "informix".sp_mc_cal_dia_dh (vFecha_hoy, vTrim, Mes_Ini)
                                              INTO cCodret,cVarDataErr;

IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_dia_dh'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;


RETURN cError, cVarDataErr1;

END PROCEDURE;