CREATE PROCEDURE "informix".sp_gen_dia_mc() RETURNING CHAR (5), CHAR(500);
/*
####################################################################################################
#                                                                            #
#   Modificación: Ejecución del proceso diario, mensual y trimestral de MC para Crédito  y Débito  #
#                                                                                                  #
####################################################################################################
*/

--MANEJO DE ERRORES
DEFINE iSqlErr                    INTEGER;
DEFINE cVarDataErr                CHAR(500);
DEFINE cVarDataErr1               CHAR(500);
DEFINE vFecha_hoy                 DATE;
DEFINE vFecha_mes                 DATE;
DEFINE vFecha_trim                DATE;
DEFINE MesI                       CHAR(02);
DEFINE Mes_Ini                    SMALLINT;
DEFINE vAnio                      CHAR(04);
DEFINE vTrim                      CHAR(05);
DEFINE iContErr                   SMALLINT;
DEFINE cCodret1, cCodret2         CHAR(100);
DEFINE cError                     CHAR(50);
DEFINE cCodret                    CHAR(5);

ON EXCEPTION SET iSqlErr

SET DEBUG FILE TO "/respaldos/sp_gen_dia_mc.err";

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

--SET DEBUG FILE TO "/informix/ilopez/MASTERCARD/sp_gen_dia_mc.out";
--TRACE ON;

--- SELECCIÓN DEL DÍA PARA EJECUCIÓN
LET vFecha_hoy = TODAY - 1 UNITS DAY; 
LET vAnio = YEAR(vFecha_hoy);
LET MesI = MONTH(vFecha_hoy);
LET Mes_Ini = MesI;
LET vFecha_mes = DATE(MDY(MONTH(TODAY),01,YEAR(TODAY)));


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
   LET vTrim = Vanio||'4';
END IF;



----- DECLARAR FECHAS PARA EJECUTAR LOS SP`s TRIMESTRALES
IF vTrim = Vanio||'1' THEN 
   LET vFecha_trim = DATE(MDY(4,01,YEAR(TODAY)));
  
END IF;

IF vTrim = Vanio||'2' THEN 
   LET vFecha_trim = DATE(MDY(7,01,YEAR(TODAY)));
 
END IF;

IF vTrim = Vanio||'3' THEN 
   LET vFecha_trim = DATE(MDY(10,01,YEAR(TODAY)));

END IF;

IF vTrim = Vanio||'4' THEN 	
   LET vFecha_trim = DATE(MDY(1,01,YEAR(TODAY)));
END IF;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--- EJECUCIÓN DEL PROCEDIMIENTO ALMACENADO PARA CRÉDITO --
--PROCEDIMIENTO DIARIO
EXECUTE PROCEDURE "informix".sp_mc_cal_dia_c (vFecha_hoy, vTrim, Mes_Ini)
                                              INTO cCodret,cVarDataErr;


IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_dia_c'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;
 
--PROCEDIMIENTO MENSUAL
IF vFecha_mes=TODAY THEN
EXECUTE PROCEDURE "informix".sp_mc_cal_men_c (vTrim,Mes_Ini)
                                    INTO cCodret,cVarDataErr;
END IF;  

IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_men_c'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;


--PROCEDIMIENTO TRIMESTRAL
IF vFecha_trim=TODAY THEN
EXECUTE PROCEDURE "informix".sp_mc_cal_tri_c (vTrim,Mes_Ini)
                                    INTO cCodret,cVarDataErr;
END IF;  

IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_tri_c'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;

--- EJECUCIÓN DEL PROCEDIMIENTO ALMACENADO PARA DÉBITO --
--PROCEDIMIENTO DIARIO
EXECUTE PROCEDURE "informix".sp_mc_cal_dia_d (vFecha_hoy, vTrim, Mes_Ini)
                                              INTO cCodret,cVarDataErr;

IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_dia_d'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;

--PROCEDIMIENTO MENSUAL
IF vFecha_mes=TODAY THEN
EXECUTE PROCEDURE "informix".sp_mc_cal_men_d (vTrim,Mes_Ini)
                                    INTO cCodret,cVarDataErr;
END IF;


IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_men_d'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;


--PROCEDIMIENTO TRIMESTRAL
IF vFecha_trim = TODAY THEN
EXECUTE PROCEDURE "informix".sp_mc_cal_tri_d (vTrim,Mes_Ini)
                                    INTO cCodret,cVarDataErr;
END IF;


IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN: sp_mc_cal_tri_d'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;



--CALCULO DE CUENTAS TRIMESTRAL PRODUCTO 7000,8100 Y 2400---

IF vFecha_trim = TODAY THEN
EXECUTE PROCEDURE "informix".sp_mc_cie_tri (vFecha_hoy,vTrim,Mes_Ini)
                                    INTO cCodret,cVarDataErr;
END IF;


IF cCodret <> '-1' THEN
   LET cError = '00000';
   LET cVarDataErr1 = 'PROCESO EXITOSO';
ELSE
    LET cError = '00001';
    LET cVarDataErr1 = 'FALLO EN:sp_mc_cie_tri'||trim(cVarDataErr)||
                        trim(cVarDataErr1);
END IF;

RETURN cError, cVarDataErr1;

END PROCEDURE;