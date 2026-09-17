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