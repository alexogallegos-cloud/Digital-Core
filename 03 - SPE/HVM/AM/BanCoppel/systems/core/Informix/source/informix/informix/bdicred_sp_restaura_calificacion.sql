CREATE PROCEDURE "informix".sp_restaura_calificacion(pEmpresa CHAR(3))

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);

DEFINE cBegin                 CHAR(1);
DEFINE vcontador_insert       INTEGER;
DEFINE cNumeroCredito        CHAR(20);
DEFINE auxNumeroCredito      CHAR(20);
DEFINE dtFechaCalculo        DATE;
DEFINE dtFechaUltMes         DATE;
DEFINE dFechaPeriodoAnterior        DATE;
DEFINE dfechaini             DATE;
DEFINE dEndeudamientoTot     DECIMAL(18,5);
DEFINE dtFechaApertura       DATE;
DEFINE dPagoRealizado        DECIMAL(18,5);
DEFINE cPeriodicidad         CHAR(1);
DEFINE iACT                  INTEGER;
DEFINE iHIST                 INTEGER;
DEFINE iANT                  DECIMAL(18,5);
DEFINE dQuincenal            DECIMAL(18,5);
DEFINE dSemanal              DECIMAL(18,5);
DEFINE dIncumplimiento       DECIMAL(18,5);
DEFINE cStatusCred           CHAR(2);  
DEFINE iBanderaConc          INTEGER;  
DEFINE i                     INTEGER;
DEFINE vcuotasvenc           INTEGER;
DEFINE dReservaCalificacion              DECIMAL(18,2);
DEFINE dReservaCalificacionGradual       DECIMAL(18,2);
DEFINE dReservaBuro              DECIMAL(18,2);
DEFINE dFechaCierre             DATE;
DEFINE dFechaCorte             DATE;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
--      LET cMensajeRet = cErrorInfo;
      IF cBegin= 'S' THEN
         ROLLBACK WORK;
      END IF;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_calculo_reserva_corte.out";
--TRACE ON;
 
LET iSqlErr=0;
LET iIsamErr=0;
LET cErrorInfo="";
LET cCodRet= '000000';
LET cMensajeRet= 'El proceso de CALIFICACION DEL CORTE se realizó correctamente';
LET cBegin= 'F';
LET vcontador_insert= 0;
LET cNumeroCredito="";
LET auxNumeroCredito="";
LET dtFechaCalculo= DATE(1);
LET dtFechaUltMes= DATE(1);
LET dFechaPeriodoAnterior=DATE(1);
LET dfechaini=DATE(1);
LET dEndeudamientoTot=0;
LET dtFechaApertura= DATE(1);
LET dPagoRealizado=0;
LET cPeriodicidad='';
LET iACT=0;
LET iHIST=0;
LET iANT=0;
LET dQuincenal=0;
LET dSemanal=0;
LET dIncumplimiento=0;
LET cStatusCred='';
LET iBanderaConc=0;
LET i=0;
LET dFechaCorte= DATE(1);
LET dFechaCierre= DATE(1);

-- Se obtiene la fecha hoy del sistema.
/*
    SELECT fecha_hoy,ult_dia_mes
      INTO dtFechaCalculo,dtFechaUltMes
      FROM bdicred:sd_fechas
	 WHERE empresa = pEmpresa;
*/
--rss
--let dtFechaCalculo = mdy('08','20','2011');
--let dtFechaUltMes = mdy('08','31','2011');
   

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    select * from sd_hist_reserva
    where empresa='001' and fecha_cierre='09-30-2011'
    and reserva_calificacion_gradual is null 
    INTO temp calificacion;

    CREATE INDEX idx_calificacion on calificacion (empresa, num_credito);

    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".calificacion;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_hist_reserva;
	
-- Se obtienen los datos del crédito.
FOREACH WITH HOLD
   SELECT num_credito,reserva_calificacion,reserva_calificacion_gradual,reserva_buro,fecha_corte,fecha_cierre
     INTO cNumeroCredito,dReservaCalificacion,dReservaCalificacionGradual,dReservaBuro,dFechaCorte,dFechaCierre
     FROM bdicred:"informix".calificacion

     LET cMensajeRet = cNumeroCredito;

     IF (vcontador_insert = 0) THEN
       LET cBegin= 'S';
       BEGIN WORK;
     END IF;
 
     if dReservaCalificacionGradual is null and dReservaBuro is null then
         update bdicred:sd_hist_reserva
            set reserva_calificacion_gradual = dReservaCalificacion,
                reserva_buro = (reserva_calificacion * 0.15)::dec(18,2)
         where empresa = '001'
           and num_credito = cNumeroCredito
           and fecha_corte = dFechaCorte
           and fecha_cierre = dFechaCierre;
      elif dReservaCalificacionGradual is null then
         update bdicred:sd_hist_reserva
            set reserva_calificacion_gradual = dReservaCalificacion
         where empresa = '001'
           and num_credito = cNumeroCredito
           and fecha_corte = dFechaCorte
           and fecha_cierre = dFechaCierre;
      elif dReservaBuro is null then
         update bdicred:sd_hist_reserva
            set reserva_buro = (reserva_calificacion * 0.15)::dec(18,2)
         where empresa = '001'
           and num_credito = cNumeroCredito
           and fecha_corte = dFechaCorte
           and fecha_cierre = dFechaCierre;
      end if;

   LET vcontador_insert = vcontador_insert + 1;

   IF (vcontador_insert >= 30000) THEN
      COMMIT WORK;
      LET vcontador_insert = 0;
--      UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_hist_reserva;
   END IF;

END FOREACH;

IF (vcontador_insert > 0) THEN
   COMMIT WORK;
END IF;

UPDATE statistics medium FOR TABLE bdicred:"informix".sd_hist_reserva;
    
--  DROP TABLE cr_sucursales3;
  LET cMensajeRet= 'El proceso de RESTAURA CALIFICACION  se realizó correctamente';

  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'el calculo de la reserva',
'AUTOR : Roque Enrique Solis',
'FECHA : 05/MARZO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_carga_primer_indicador(pEmpresa char(3))
RETURNING CHAR(6)        AS Cod_Ret,   CHAR(80)       AS Mens_Ret;

--Creado por: Abrham Lopez L
--05/08/2011
--Proceso para la generación del archivo de Cartera en Linea

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE vdia				    DATE;
DEFINE vhora				CHAR(8);
DEFINE ctipocampania        CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pFecha               DATE;
DEFINE vnomProceso			CHAR(20);
DEFINE vStProc         		CHAR(1);
DEFINE cMensajeRet          CHAR(125);
DEFINE credcontproc 	    char(1);
DEFINE intecontproc 	    char(1);
DEFINE vlNum_Credito 	    char(20);
DEFINE vlfecha 	    date;
DEFINE vltransaccion CHAR(4);
DEFINE vlmonto DECIMAL(18,3);
DEFINE vlTipo CHAR(1);
DEFINE vlfechaD 	    date;
DEFINE vltransaccionD CHAR(4);
DEFINE vlmontoD DECIMAL(18,3);


--SET DEBUG FILE TO "/home/informix/ALL/CarteraLinea.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0020';
LET vempresa				= '001';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnumcte                 = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET vdia				    = DATE(1);
LET vhora				    = "";
LET ctipocampania           = "";
LET cCod_RetIB              = "000000";
LET cMensajeRet				= "";

LET vlNum_Credito 	="";
LET vlfecha 	    =DATE(1);
LET vltransaccion ="";
LET vlmonto =0;
LET vlTipo ="";

LET vlfechaD 	    =DATE(1);
LET vltransaccionD  ="";
LET vlmontoD        ="";



BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;            

        RETURN cCod_ret,cMensajeRet;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --Sacar la fecha del dia de hoy
        Select Fecha_Hoy
        Into pFecha
        From bdicred:sd_fechas
        Where empresa = '001';
    
    foreach with hold
        select a.num_credito  , b.monto, nvl(b.fecha,date(1)), b.transaccion,
                        d.monto, nvl(d.fecha,date(1)), d.transaccion
          into vlnum_credito,  vlmonto, vlfecha, vltransaccion ,vlmontoD,  vlfechaD, vltransaccionD 
          from bdicred:sd_indicador_cred a  
          left outer join sd_primer_transaccion b  on (a.num_credito = b.num_credito and b.tipo= 'C' )
          left outer join sd_primer_transaccion d  on (a.num_credito = d.num_credito and d.tipo= 'D' )
         --where ( a.f_primer_disp is null  or a.f_primer_compra is null )
   
       BEGIN WORK;
        UPDATE  bdicred:sd_indicador_cred
        set
            f_primer_compra      =vlfecha,
            monto_primer_compra  =vlmonto,
            trans_primer_compra  =vltransaccion ,
            f_primer_disp      =vlfechaD,
            monto_primer_disp  =vlmontoD,
            trans_primer_disp  =vltransaccionD 
         WHERE EMPRESA ='001'
          AND NUM_CREDITO = VLNUM_CREDITO;
         let vlfecha =date(1);
       COMMIT WORK;    
    end foreach; 
/*
 foreach with hold
        select a.num_credito  , --b.monto, nvl(b.fecha,date(1)), b.transaccion--,
                        d.monto, nvl(d.fecha,date(1)), d.transaccion
          into vlnum_credito, -- vlmonto, vlfecha, vltransaccion --,
               vlmontoD,  vlfechaD, vltransaccionD 
          from bdicred:sd_indicador_cred a  
          --left outer join sd_primer_transaccion b  on (a.num_credito = b.num_credito and b.tipo= 'C' )
          left outer join sd_primer_transaccion d  on (a.num_credito = d.num_credito and d.tipo= 'D' )
         where (a.f_primer_compra is null )
   
       BEGIN WORK;
        UPDATE  bdicred:sd_indicador_cred
        set
          /*  f_primer_compra      =vlfecha,
            monto_primer_compra  =vlmonto,
            trans_primer_compra  =vltransaccion-- ,
            f_primer_disp      =vlfechaD,
            monto_primer_disp  =vlmontoD,
            trans_primer_disp  =vltransaccionD 
         WHERE EMPRESA ='001'
          AND NUM_CREDITO = VLNUM_CREDITO;
       COMMIT WORK;    
    end foreach; */
	RETURN cCod_ret,cMensajeRet; 
END;
END PROCEDURE;