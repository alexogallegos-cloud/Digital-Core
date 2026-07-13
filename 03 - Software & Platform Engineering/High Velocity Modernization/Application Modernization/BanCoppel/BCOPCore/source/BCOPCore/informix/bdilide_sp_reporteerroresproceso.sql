CREATE PROCEDURE "informix".sp_reporteerroresproceso(pFechaReporte DATE)
    RETURNING CHAR(6) as codRet,DATE as fechaInicial,CHAR(16) as archivo,DATE as fecha_error, CHAR(5) as cod_error,CHAR(1) as tipo_error,CHAR(40) as sp_llamado ,CHAR(200) as mensaje_error;
       --RETORNO,fInic,ARCHIVO,fError,cod_err,tpoErr,sp_llama, mens_err,
                                        --*************************************************
                                        --Creado por: Anselmo Verdugo                   --*
                                        -- Actividad: Obtiene registros de los últimos treintas sobre la tabla sl_errores.
                                        --  Solicitó: Aymme Osuna                       --*
                                        --     Fecha: 03/SEP/2008                       --*
                                        --*************************************************


--DEFINICIÓN DE VARIABLES
DEFINE  vcCodRet    CHAR(3);
DEFINE  vdFechaInicial DATE;
DEFINE  sql_err     INTEGER;
DEFINE  vcArchivo   CHAR(16);
DEFINE  vmFechaErr  DATE;
DEFINE  vcCodErr    CHAR(5);
DEFINE  vcTpoErr    CHAR(16);
DEFINE  vcSP_llamado CHAR(40);
DEFINE  vcMensajeErr   CHAR(200);
DEFINE  vINumRegistros SMALLINT;




       ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;
            RETURN vcCodRet,'','', '', '', '', '', '';
        END EXCEPTION;


    --SET DEBUG FILE TO "/home/informix/reporteErrores.out";
	--TRACE ON;

--INICIALIZACIÓN DE VARIABLES
LET vcCodRet    = '000';
LET sql_err     = 0;
LET  vcArchivo  = '';
LET  vmFechaErr = '';
LET  vcCodErr   = '';
LET  vcTpoErr   = '';
LET  vcSP_llamado = '';
LET  vcMensajeErr  = '';
LET vINumRegistros = 0;


       IF pFechaReporte IS NULL THEN
          LET vcCodRet    = '001';
		  RETURN vcCodRet,'fecha nula','', '', '', '', '', '';
       END IF;


       Let vdFechaInicial = pFechaReporte - interval(30) day to day;

      FOREACH
       SELECT nombre_arch,  fecha_error, cod_error, tipo_error, sp_llamado, mensaje_error 
       INTO   vcArchivo, vmFechaErr, vcCodErr,  vcTpoErr  , vcSP_llamado,vcMensajeErr
       FROM bdilide:sl_errores
       WHERE fecha_error BETWEEN vdFechaInicial AND pFechaReporte

     --  LET vINumRegistros = 1;
      RETURN vcCodRet,vdFechaInicial,vcArchivo, vmFechaErr, vcCodErr,  vcTpoErr  , vcSP_llamado,vcMensajeErr WITH RESUME;
      END FOREACH;


   -- IF vINumRegistros = 0 THEN
       -- RETURN '000','1900-01-01','', '', '', '', '', '';
   -- END IF;

END PROCEDURE;