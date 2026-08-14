CREATE PROCEDURE "informix".sp_refrescabonos(pFechaValor date,
                                             pStatus1 CHAR(1),
                                             pStatus2 CHAR(1),
                                             pStatus3 CHAR(1),
                                             pStatus4 CHAR(1),
                                             pStatus5 CHAR(1),
                                             pStatus6 CHAR(1),
                                             pStatus7 CHAR(1))

RETURNING INTEGER ,CHAR(1),CHAR(1), INTEGER, INTEGER, 
          INTEGER, VARCHAR(20), decimal(19,2), VARCHAR(30), INTEGER,
          VARCHAR(100), INTEGER, VARCHAR(100), INTEGER, INTEGER,
          VARCHAR(100), varchar(255), CHAR(1);

-- ***************************************************************************
-- sp_refrescabonos
-- Version              1.0.0
-- Obejtivo:            Abono Automatico Ordenes de pago a SPEI
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima Modificacion: Octubre - 2008
--                      Creación de SPL
-- ***************************************************************************

--//Definicion de variables
DEFINE v_codret          char(5);
DEFINE v_monto_abo       money(16,2);
DEFINE sql_err 	         integer;
DEFINE vintPkPago        integer;
DEFINE vcausadev         INTEGER;
DEFINE vmotivo           CHAR(40);

DEFINE vt_intpkpago	    INTEGER;
DEFINE vt_intfoliopago      INTEGER;
DEFINE vt_cvecesifbcoord    INTEGER;
DEFINE vt_vchrnombrecorto   VARCHAR(20);
DEFINE vt_intcvetpooperacion CHAR(2);
DEFINE vt_vchrdesctipooper  VARCHAR(100);
DEFINE vt_mnyimporte	    decimal(19,2);
DEFINE vt_intcvetipoctaord  INTEGER;
DEFINE vt_vchrdesctipoctaord VARCHAR(100);
DEFINE vt_intcvetipopago    INTEGER;
DEFINE vt_vchrdesctipopago  VARCHAR(100);
DEFINE vt_chrestatusenvio   char(1);
DEFINE vt_vchrnombreord	    VARCHAR(40);
DEFINE vt_vchrcuentaord	    VARCHAR(20);
DEFINE vt_vchrrfcord	    VARCHAR(18);
DEFINE vt_vchrnombrebenef   VARCHAR(40);
DEFINE vt_intcvetipoctabene INTEGER;
DEFINE vt_intcvetipoctaben  INTEGER;
DEFINE vt_vchrdesctipoctaben VARCHAR(100);
DEFINE vt_vchrcuentabenef   VARCHAR(20);
DEFINE vt_vchrrfcbenef	    VARCHAR(18);
DEFINE vt_vchrnombrebenef2  VARCHAR(40);
DEFINE vt_intcvetipoctabene2 INTEGER;
DEFINE vt_vchrcuentabenef2  VARCHAR(20);
DEFINE vt_vchrrfcbenef2	    VARCHAR(18);
DEFINE vt_vchrconceptopago  VARCHAR(210);
DEFINE vt_mnyiva	    decimal(16,2);
DEFINE vt_intrefnumerica    decimal(7);
DEFINE vt_vchrrefcobranza   VARCHAR(40);
DEFINE vt_vchrclavepago	    VARCHAR(10);
DEFINE vt_vchrconceptopago2 VARCHAR(40);
DEFINE vt_dtfechavalor      DATE;
DEFINE vt_dtfechacaptura    date;
DEFINE vt_vchrclaverastreo  VARCHAR(30);
DEFINE vt_chrusuarioprom    VARCHAR(20);
DEFINE vt_chrfolioprom	    char(16);
DEFINE vt_chrusuariovent    VARCHAR(20);
DEFINE vt_chrfolioliqu	    char(16);
DEFINE vt_intfoliopaquete   INTEGER;
DEFINE vt_chrtopologia	    char(1);
DEFINE vt_chrprioridad	    char(1);
DEFINE vt_intfoliocargo	    INTEGER;
DEFINE vt_dtmhoracargo	    date;
DEFINE vt_intcvecausadev    INTEGER;
DEFINE vt_vchrdescripcion   varchar(100);
DEFINE vt_vchrcverastreodev varchar	(30);
DEFINE vt_vchrmotivodev	    varchar(255);



    --SET debug file to "/tmp/sp_refrescabonos.out";
    --TRACE on;

--//INICIA LA FUNCIONALIDAD
BEGIN

        --//Manejo de excepciones
        ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
	       LET v_codret = sql_err;
	           RETURN  null ,null ,null ,null ,null
                        ,null ,null ,null ,null ,null	
                        ,null ,null ,null ,null ,null
                        ,null ,null ,null;
		END IF;
        END EXCEPTION;
        -- Establece Modo de Lectura
        SET isolation to dirty read;
        
        LET v_codret = "000";

	--//Envia los pagos 
        FOREACH
            SELECT x0.intpkpago ,x0.intfoliopago ,x0.cvecesifbcoord ,x7.vchrnombrecorto ,x1.intcvetpooperacion ,
                   x1.vchrdescripcion ,x0.mnyimporte ,x3.intcvetipocuenta ,x3.vchrdescripcion ,x5.intcvetipopago ,
                   x5.vchrdescripcion ,x0.chrestatusenvio ,x0.vchrnombreord ,x0.vchrcuentaord ,x0.vchrrfcord ,
                   x0.vchrnombrebenef ,x0.intcvetipoctabene ,x4.intcvetipocuenta ,x4.vchrdescripcion ,x0.vchrcuentabenef ,
                   x0.vchrrfcbenef ,x0.vchrnombrebenef2 ,x0.intcvetipoctabene2 ,x0.vchrcuentabenef2 ,x0.vchrrfcbenef2 ,
                   x0.vchrconceptopago ,x0.mnyiva ,x0.intrefnumerica ,x0.vchrrefcobranza ,x0.vchrclavepago ,
                   x0.vchrconceptopago2 ,x0.dtfechavalor ,x0.dtfechacaptura ,x0.vchrclaverastreo ,x0.chrusuarioprom ,
                   x0.chrfolioprom ,x0.chrusuariovent ,x0.chrfolioliqu ,x2.intfoliopaquete ,x0.chrtopologia ,x2.chrprioridad ,
                   x0.intfoliocargo ,x0.dtmhoracargo ,x0.intcvecausadev ,x6.vchrdescripcion ,x0.vchrcverastreodev ,
                   x0.vchrmotivodev 
	      INTO vt_intpkpago ,vt_intfoliopago ,vt_cvecesifbcoord ,vt_vchrnombrecorto ,vt_intcvetpooperacion
                  ,vt_vchrdesctipooper ,vt_mnyimporte ,vt_intcvetipoctaord ,vt_vchrdesctipoctaord ,vt_intcvetipopago
                  ,vt_vchrdesctipopago ,vt_chrestatusenvio ,vt_vchrnombreord ,vt_vchrcuentaord ,vt_vchrrfcord	
                  ,vt_vchrnombrebenef ,vt_intcvetipoctabene ,vt_intcvetipoctaben ,vt_vchrdesctipoctaben ,vt_vchrcuentabenef
                  ,vt_vchrrfcbenef ,vt_vchrnombrebenef2 ,vt_intcvetipoctabene2 ,vt_vchrcuentabenef2 ,vt_vchrrfcbenef2
                  ,vt_vchrconceptopago ,vt_mnyiva	   ,vt_intrefnumerica ,vt_vchrrefcobranza ,vt_vchrclavepago
                  ,vt_vchrconceptopago2 ,vt_dtfechavalor     ,vt_dtfechacaptura  ,vt_vchrclaverastreo ,vt_chrusuarioprom  
                  ,vt_chrfolioprom ,vt_chrusuariovent  ,vt_chrfolioliqu ,vt_intfoliopaquete  ,vt_chrtopologia
                  ,vt_chrprioridad ,vt_intfoliocargo ,vt_dtmhoracargo ,vt_intcvecausadev ,vt_vchrdescripcion 
                  ,vt_vchrcverastreodev ,vt_vchrmotivodev 
             FROM "informix".tblpago x0 ,outer("informix".tbltipooperacion x1 ) ,
                   outer("informix".tblpaqueteenv x2 ) ,outer("informix".tbltipocuenta x3 ) 
                   ,outer("informix".tbltipocuenta x4 ) ,outer("informix".tbltipopago x5 ) ,
                   outer("informix".tblcausadev x6 ) ,outer("informix".tblbanco x7 )
             WHERE (((((((((x0.intcvetpooperacion ::integer = x1.intcvetpooperacion ::integer ) 
               AND (x0.intcvetipoctaord = x3.intcvetipocuenta ) ) AND (x0.intcvetipopago = x5.intcvetipopago ) ) 
               AND (x0.intcvetipoctabene = x4.intcvetipocuenta ) ) AND (x0.intpkpaqueteenv = x2.intpkpaqueteenv ) ) 
               AND (x0.intcvecausadev = x6.intcvecausadev ) ) AND (x0.chrsentidopago = 'R' ) ) 
               AND (x0.cvecesifbcoord = x7.cvecesif ))
               AND x0.dtfechavalor = pFechaValor) 
               AND (x0.chrestatusenvio = DECODE(pStatus1,'R',pStatus1,pStatus1) 
                     OR x0.chrestatusenvio = DECODE(pStatus2,'Y',pStatus2,pStatus2)
                     OR x0.chrestatusenvio = DECODE(pStatus3,'A',pStatus3,pStatus3)
                     OR x0.chrestatusenvio = DECODE(pStatus4,'I',pStatus4,pStatus4)
                     OR x0.chrestatusenvio = DECODE(pStatus5,'E',pStatus5,pStatus5)
                     OR x0.chrestatusenvio = DECODE(pStatus6,'M',pStatus6,pStatus6)
                     OR x0.chrestatusenvio = DECODE(pStatus7,'D',pStatus7,pStatus7))


	     RETURN vt_intpkpago ,vt_chrprioridad,vt_chrtopologia, vt_intfoliopago, vt_intfoliopaquete, 
                    vt_cvecesifbcoord, vt_vchrnombrecorto, vt_mnyImporte, vt_vchrclaverastreo, vt_intcvetipopago,
                    vt_vchrdesctipopago, vt_intcvetpooperacion, vt_vchrdesctipooper, vt_intfoliocargo, vt_intcvecausadev,
                    vt_vchrdescripcion, vt_vchrmotivodev, vt_chrestatusenvio WITH RESUME;

        END FOREACH;

END
END PROCEDURE;