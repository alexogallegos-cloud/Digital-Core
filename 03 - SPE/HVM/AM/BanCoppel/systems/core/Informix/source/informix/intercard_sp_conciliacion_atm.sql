CREATE PROCEDURE "informix".sp_conciliacion_atm( psNumEmpleado CHAR (8), psArchivoOrigen CHAR (3), psActividad CHAR (25), piRastreo INTEGER )

RETURNING INTEGER ;

--****************************************************************************************************
-- DESCRIPCION: CONCILIACION  ATM (STAT 07)
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 15/12/2007
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : 09/04/2008   
-- MODIFICADO : : 15/04/2010 Casanova Edeza Hector Juan  --Se agregan lectura de los campos Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para pasarlos por parametro al sp_Conciliacion_ATM_Registro y que se guarden en la tabla Log_ATM .',
--***************************************************************************************************

--CHECAR LO DE LA REFRENCIA
DEFINE vsmensajeError CHAR (500) ;
DEFINE vsmTmpError CHAR (500) ;

/*  DEFINICION DE VARIABLES */

--DATOS DE LA TABLA CONCILIACION _ATM_IN
DEFINE viKeyx INTEGER ;
DEFINE vsSecuenciaAuth CHAR (6) ;
DEFINE vsNumTarjeta CHAR (16) ;
DEFINE vsFecha CHAR (8) ;
DEFINE vsHora CHAR (8) ;
DEFINE vsConciliado BOOLEAN ; 
DEFINE vsAdquiriente CHAR (4) ;
DEFINE vsNumCuenta CHAR (13) ;
DEFINE vsDescripcion CHAR (15) ;
DEFINE vsIndicadordeReversa CHAR (19) ;
DEFINE vsCodigoISO CHAR (2)  ;
DEFINE vsSecuenciaCajero CHAR (12) ;
DEFINE vmMonto MONEY ;
DEFINE vsNumCajero CHAR (14) ;

DEFINE vsNombreComercio CHAR (30) ;
DEFINE vsReferenciaTransaccion  CHAR (23) ;
DEFINE vsRFC CHAR (16) ;
DEFINE vsUsuarioParametros CHAR (8) ;

DEFINE vsResp CHAR(6);  --nuevo
DEFINE vsOrden CHAR(6); 
DEFINE vsRed CHAR(7);
DEFINE vsDolares CHAR(7);
DEFINE vsNumAutorizacion CHAR(6);
DEFINE vsCodPais CHAR(2);
DEFINE vsMontoOrigen CHAR(13);
DEFINE vsCodMoneda CHAR(3);
DEFINE vmMontoSurcharge MONEY(16,2);
DEFINE vmDonativo MONEY(16,2);
DEFINE vsEmpresa CHAR(4);
DEFINE vsCompania CHAR(10);
DEFINE vmMonto_LoyaltyFee MONEY(16,2);
DEFINE vmMonto_UsoLinea MONEY(16,2);
DEFINE vsNomBancoEmisor CHAR(20);
DEFINE vsBanderaAdquiriente CHAR(1);  --nuevo
--VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr   INTEGER ;
DEFINE viCodRet   INTEGER ;

DEFINE viRegNumero INTEGER ;

DEFINE  viContReintento INTEGER ;
DEFINE vsFlagReintento CHAR (1) ;

/* INICIALIZACION DE VARIABLES */
LET vsmensajeError  = '' ;


--DATOS DE LA TABLA CONCILIACION _ATM_IN
LET viKeyx = 0 ;
LET vsSecuenciaAuth = ''  ;
LET vsNumTarjeta = '';
LET vsFecha = '';
LET vsHora = '';
LET vsConciliado = 'F' ;
LET vsAdquiriente = '';     --IDRECEPTOR
LET vsNumCuenta = '';    --NumCtaChequesAfectada 
LET vsDescripcion = '';
LET vsIndicadordeReversa = '';
LET vsCodigoISO = '' ;
LET vsSecuenciaCajero = '';   --Referencia
LET vmMonto = 0;
LET vsNumCajero = '' ;

LET vsNombreComercio  = '' ;
LET vsReferenciaTransaccion = '' ;
LET vsRFC  = '' ;

LET vsUsuarioParametros = '' ;

LET vsResp = '';  --nuevo
LET vsOrden = '';
LET vsRed  = '';
LET vsDolares = '';
LET vsNumAutorizacion = '';
LET vsCodPais = '';
LET vsMontoOrigen = '';
LET vsCodMoneda = '';
LET vmMontoSurcharge = 0.0; 
LET vmDonativo = 0.0;
LET vsEmpresa = '';
LET vsCompania = '';
LET vmMonto_LoyaltyFee = 0.0;
LET vmMonto_UsoLinea = 0.0;
LET vsNomBancoEmisor = '';
LET vsBanderaAdquiriente  = '';LET viCodRet = "0";
LET visqlerr = 0;

LET viRegNumero = 0 ;
LET vsmTmpError = '' ;

LET viContReintento = 0 ;
LET vsFlagReintento = 'V' ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN             

            LET vsmTmpError = ' ('|| visqlerr || ') ' || 'Registro Num: ' || viRegNumero || ' -- ' ||  vsmensajeError ;

            IF ( ( visqlerr  = -244 )  AND ( viContReintento >= 9 ) ) THEN --EN CASO DE ERROR DE CONCURRENCIA
                LET vsmTmpError = vsmTmpError || 'SE REINTENTO 9 VECES LA LECTURA DEL REGISTRO BLOQUEADO'  ;
            END IF ;
            
            -- GUARDA UN REGISTRO DEL ERROR OCURRIDO JUNTO CUNA CLAVE  DE ESTE Y EL PROCESO EN EL QUE OCURRIO     
            EXECUTE PROCEDURE sp_Insertar_Bitacora ( psNumEmpleado, psArchivoOrigen, psActividad,  vsmTmpError ) INTO viCodRet ;

             --REVERSA 
            EXECUTE PROCEDURE sp_reversa_mov (psNumEmpleado, psArchivoOrigen, 0 ) INTO vsSecuenciaAuth ;

           RETURN visqlerr ;

        END IF; 
    END EXCEPTION;


    IF ( piRastreo > 0  ) THEN
        --SET DEBUG FILE TO '/tmp/TraceConciliacionATM_' || psArchivoOrigen || '.out';
        --TRACE ON ;
    END IF ;

    SET LOCK MODE TO WAIT  ;
    SET ISOLATION DIRTY READ ;
    SELECT Usuario INTO vsUsuarioParametros FROM Parametros ;
    LET visqlerr = 0;
    --RECORRE LA TABLA DE CONCILIACION_ATM_IN  EN BUSCA DE MOVIMIENTOS SIN CONCILIAR
    LET vsmensajeError = 'Recorrer tabla CONCILIACION_ATM_IN - Archivo Origen '  || psArchivoOrigen ;

    SET LOCK MODE TO WAIT  ;
    SET ISOLATION DIRTY READ ;

    FOREACH  SELECT  Keyx, SecuenciaAuth, NumTarjeta, Fecha, Hora, Conciliado, Adquiriente, 
        NumCuenta, Descripcion, IndicadordeReversa, CodigoISO, SecuenciaCajero, Monto, NumCajero, 
		Resp, Orden, Red, Dolares, NumAutorizacion, CodPais,  MontoOrigen, CodMoneda, MontoSurcharge,  --nuevo
		Donativo, Empresa, Compania, Monto_LoyaltyFee, Monto_UsoLinea, NomBancoEmisor, BanderaAdquiriente  --nuevo
        INTO viKeyx, vsSecuenciaAuth, vsNumTarjeta, vsFecha, vsHora, vsConciliado, vsAdquiriente, 
        vsNumCuenta, vsDescripcion, vsIndicadordeReversa, vsCodigoISO, vsSecuenciaCajero, vmMonto, vsNumCajero, 
		vsResp, vsOrden, vsRed, vsDolares, vsNumAutorizacion, vsCodPais, vsMontoOrigen, vsCodMoneda, vmMontoSurcharge, --nuevo
		vmDonativo, vsEmpresa, vsCompania, vmMonto_LoyaltyFee, vmMonto_UsoLinea, vsNomBancoEmisor, vsBanderaAdquiriente --nuevo
        FROM CONCILIACION_ATM_IN WHERE Conciliado = 'F' AND ArchivoOrigen = psArchivoOrigen ORDER  BY KeyX ASC --WITH HOLD

            LET viRegNumero = viRegNumero + 1 ;

            LET viContReintento = 0 ;
            LET vsFlagReintento = 'V' ;

            WHILE ( ( vsFlagReintento = 'V' ) AND ( viContReintento < 10 ) )

                LET viContReintento = viContReintento +1 ;

                LET vsmensajeError = 'sp_Conciliacion_ATM_Registro -- Reistro Num: '  || viRegNumero ;
                EXECUTE PROCEDURE sp_Conciliacion_ATM_Registro( 
                psNumEmpleado,
                psArchivoOrigen ,
                psActividad ,
                vsUsuarioParametros ,
                vsSecuenciaAuth ,
                vsNumTarjeta ,
                vsFecha ,
                vsHora ,
                vsAdquiriente ,
                vsNumCuenta ,
                vsDescripcion ,
                vsIndicadordeReversa ,
                vsCodigoISO ,
                vsSecuenciaCajero ,
                vmMonto ,
                vsNombreComercio ,
                vsReferenciaTransaccion,  --''
                vsRFC ,  -- ''
                vsNumCajero ,
                viRegNumero,
				vsResp,  --nuevo
				vsOrden, 
				vsRed, 
				vsDolares,
				vsNumAutorizacion,
				vsCodPais, 
				vsMontoOrigen, 
				vsCodMoneda, 
				vmMontoSurcharge, 
				vmDonativo, 
				vsEmpresa, 
				vsCompania, 
				vmMonto_LoyaltyFee, 
				vmMonto_UsoLinea, 
				vsNomBancoEmisor, 
				vsBanderaAdquiriente --nuevo
                 ) INTO visqlerr, vsmensajeError ;

                IF ( visqlerr = -244 ) THEN --ERROR DE CONCURRENCIA
                    LET vsFlagReintento = 'V' ;
                ELSE
                    LET vsFlagReintento = 'F' ;
                END IF ;

            END WHILE ; 

            IF ( visqlerr <> 0 ) THEN --EN CASO DE ERROR

                --REVERSA 
                EXECUTE PROCEDURE sp_reversa_mov (psNumEmpleado, psArchivoOrigen, 0 ) INTO vsSecuenciaAuth ;

                RETURN visqlerr ;

            ELSE  -- OK

                LET vsmensajeError = 'Actualizacion del registro de la transaccion en Movimiento -- ' ||
                    'UPDATE Conciliacion_ATM_IN SET Conciliado = "T"  WHERE ArchivoOrigen =  ' || psArchivoOrigen || ' AND SecuenciaAuth = ' 
                    || vsSecuenciaAuth || 'AND NumTarjeta = ' || vsNumTarjeta || ' AND NumCuenta = ' || vsNumCuenta || ' AND Fecha = ' || vsFecha || ';' ; 
                    --MARCA EL REGISTRO COMO CONCILIADO PARA UE NO SE REVISE DE NUEVO EN CASO DE UN ERROR

                UPDATE Conciliacion_ATM_IN  SET Conciliado = 'T'  WHERE Keyx = viKeyx ;

            END IF ;
      
    END FOREACH ;
    
    RETURN viRegNumero ;
   
END

END PROCEDURE 
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONCILIACION (INTERCARD) DE TRANSACCIONES DE ATM (STAT 07).',
'Fecha: 2007/12/15',
'Version: 20071215.1025',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregan lectura de los campos Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para pasarlos por parametro al sp_Conciliacion_ATM_Registro y que se guarden en la tabla Log_ATM .',
'Fecha: 2010/04/15',
'Version: 20100415.1913',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_insertar_log_atm ( psArchivoOrigen CHAR (3), psAdquiriente CHAR (4), psNumTarjeta CHAR (16), psNumCuenta CHAR (13), 
psDescripcion1 CHAR (15), psIndicadordeReversa CHAR (19), psCodigoRespuesta CHAR (2), psSecuenciaCajero CHAR (14), psFecha CHAR (8), 
psHora CHAR (8), pmMonto MONEY, 
psCajero CHAR(14),
psSecuenciaAuth CHAR(6),
psResp CHAR(6), psOrden CHAR(6), psRed CHAR(7), psDolares CHAR(7), psNumAutorizacion CHAR(6), psCodPais CHAR(2), psMontoOrigen CHAR(13), 
psCodMoneda CHAR(3), pmMontoSurcharge MONEY(16,2), pmDonativo MONEY(16,2), psEmpresa CHAR(4), psCompania CHAR(10), pmMonto_LoyaltyFee MONEY(16,2), 
pmMonto_UsoLinea MONEY(16,2), psNomBancoEmisor CHAR(20), psBanderaAdquiriente CHAR(1),
psQUERY1 CHAR (1000), psCodigoISO CHAR (2), psSecuencia CHAR (7), 
psSecuenciaOrig CHAR (7), psCodReversa CHAR (3), psComisionEnLinea CHAR (1), psPermiteComisionPendiente CHAR (1), 
psGenerocomisionPendiente CHAR (1), psSecComision CHAR (7), pmMontoComision MONEY,  psCodigoRetComision CHAR (5), pmMontoMov MONEY,
pmMontoRealRevFzda MONEY,psMovConciliado CHAR (1), psFechaMov CHAR (4), psHoraMov CHAR (6), psMovReversado CHAR (1), psEnLinea CHAR (1), 
psIdTerminal CHAR (16), psDescripccion2 CHAR (100), psDescripccion3 CHAR (100), 
psRegistrocentral1 CHAR (300), psRegistrocentral2 CHAR (300), psQUERY2 CHAR (2000), piEstado INTEGER, psTipoConciliacion CHAR (2) )


RETURNING INTEGER ;


--****************************************************************************************************
-- DESCRIPCION: GUARDA LA TRAYECTORIA COMPLETA DEL REGISTRO CONCILIADO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : : 15/04/2010 Casanova Edeza Hector Juan  --se agregan los parametros Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para que se guarden en la tabla Log_ATM . 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */ 
DEFINE vsEstado CHAR(60) ;
DEFINE vsNombreArchivo CHAR(23);

DEFINE viCodRet INTEGER ;
DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsEstado = '' ;
LET vsNombreArchivo = '';

LET viCodRet = 0 ;
LET visqlerr = 0 ;
BEGIN 
/*    
    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN 
            LET viCodRet = visqlerr;
            ROLLBACK WORK;
            RETURN viCodRet ;
        END IF; 
    END EXCEPTION;
*/
--    BEGIN WORK ;
        
        IF ( piEstado > 0 ) THEN 

            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT Descripcion INTO vsEstado FROM StatusCon WHERE Estado = piEstado ;
            LET vsEstado = '[' || piEstado || ']: ' || vsEstado ;
			
			SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 valor INTO vsNombreArchivo FROM intercard:param_conciliacionauto WHERE descripcion = 'NOMBRE_ARCHIVO';

        END IF ;

        INSERT INTO LOG_ATM (
            FechaConciliacion,
            ArchivoOrigen ,
			SecuenciaAuth,
            Adquiriente,
            NumTarjeta,
            NumCuenta,
            Descripcion1,
            IndicadordeReversa,
            CodigoRespuesta,
			Cajero,
            SecuenciaCajero,
            Fecha,
            Hora,
            Monto,
			Resp,				---nuevo
			Orden,
			Red,
			Dolares,
			NumAutorizacion,
			CodPais, 
			MontoOrigen,
			CodMoneda,
			MontoSurcharge,
			Donativo,
			Empresa,
			Compania,
			Monto_LoyaltyFee,
			Monto_UsoLinea,
			NomBancoEmisor,
			BanderaAdquiriente,  --nuevo
            QUERY1,
            CodigoISO,
            Secuencia,
            SecuenciaOrig,
            CodReversa,
            ComisionEnLinea,
            PermiteComisionPendiente,
            GenerocomisionPendiente,
            SecComision,
            MontoComision,
            CodigoRetComision,
            MontoMov,
            MontoRealRevFzda,
            MovConciliado,
            FechaMov,
            HoraMov,
            MovReversado,
            EnLinea,
            IdTerminal,
            Descripccion2,
            Descripccion3,
            Registrocentral1,
            Registrocentral2,
            QUERY2,
            Estado,
            TipoConciliacion,
			NombreArchivo
        )
        VALUES (
            CURRENT,
            NVL (psArchivoOrigen, '' ),
			NVL (psSecuenciaAuth, '' ),
            NVL (psAdquiriente, '' ),
            NVL (psNumTarjeta, '' ),
            NVL (psNumCuenta, '' ),
            NVL (psDescripcion1, '' ),
            NVL (psIndicadordeReversa, '' ),
            NVL (psCodigoRespuesta, '' ),
			NVL (psCajero, '' ),
            NVL (psSecuenciaCajero, '' ),
            NVL (psFecha, '' ),
            NVL (psHora, '' ),
            NVL (pmMonto, 0 ),
			NVL (psResp, '' ),  ---nuevo
			NVL (psOrden, '' ),
			NVL (psRed, '' ),
			NVL (psDolares, '' ),
			NVL (psNumAutorizacion, '' ),
			NVL (psCodPais,  '' ),
			NVL (psMontoOrigen, '' ),
			NVL (psCodMoneda, '' ),
			NVL (pmMontoSurcharge, 0.0 ),
			NVL (pmDonativo, 0.0 ),
			NVL (psEmpresa, '' ),
			NVL (psCompania, '' ),
			NVL (pmMonto_LoyaltyFee, 0.0 ),
			NVL (pmMonto_UsoLinea, 0.0 ),
			NVL (psNomBancoEmisor, '' ),
			NVL (psBanderaAdquiriente, '' ),   ---nuevo
            NVL (psQUERY1, '' ),
            NVL (psCodigoISO, '' ),
            SUBSTRING (NVL (psSecuencia, '' ) FROM 2 FOR 6 ),
            NVL (psSecuenciaOrig, '' ),
            NVL (psCodReversa, '' ),
            NVL (psComisionEnLinea, '' ),
            NVL (psPermiteComisionPendiente, '' ),
            NVL (psGenerocomisionPendiente, '' ),
            NVL (psSecComision, '' ),
            NVL (pmMontoComision, 0),
            NVL (psCodigoRetComision, '' ),
            NVL (pmMontoMov, 0 ), 
            NVL (pmMontoRealRevFzda, 0 ),
            NVL (psMovConciliado, '' ),
            NVL (psFechaMov, '' ),
            NVL (psHoraMov, '' ),
            NVL (psMovReversado, '' ),
            NVL (psEnLinea, '' ),
            NVL (psIdTerminal, '' ),
            NVL (psDescripccion2, '' ),
            NVL (psDescripccion3, '' ),
            NVL (psRegistrocentral1, '' ),
            NVL (psRegistrocentral2, '' ),
            NVL (psQUERY2, '' ),
            NVL (vsEstado, '' ),
            NVL (psTipoConciliacion, '' ),
			TRIM(NVL (vsNombreArchivo, ''))
        ) ;

--    COMMIT WORK ;

    RETURN viCodRet ;

END

END PROCEDURE 
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA LA TRAYECTORIA COMPLETA DEL REGISTRO CONCILIADO.',
'Fecha: 2008/03/10',
'Version: 20080310.0933',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO LA LOGICA PARA QUE GUARDE EL CAMPO NOMBRE ARCHIVO EN LA TABLA DE LOG_ATM.',
'Fecha: 2010/01/19',
'Version: 20100119.0933',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1238',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregan los parametros Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para que se guarden en la tabla Log_ATM .',
'Fecha: 2010/04/15',
'Version: 20100415.1849',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_insertar_log_pos( psArchivoOrigen CHAR (3), psNumTarjeta CHAR (16), psTipoTransaccion CHAR (2), pmMonto MONEY, 
pmMontoCashBack MONEY, psIdComercio CHAR (9), psNomComercio CHAR (30), psSecuencia CHAR (6), psRefTransaccion CHAR (23), psRFC CHAR (16), 
psFuenteId CHAR (3), psNumCuenta CHAR (16), psQUERY1 CHAR (800), psCodigoISO CHAR (2), psFormato CHAR (4), psMovConciliado CHAR (1), 
psFechaMov CHAR (4), psHoraMov CHAR (6), psCodigoAplicCentral CHAR (5), psSecuenciaOrig CHAR (7), psHoraLocalTransaccion CHAR (6),
pmMontoRealFzda MONEY, psCodTran CHAR (2), psEnLinea CHAR (1), psIdTerminal CHAR (8), psProdInd CHAR (2), psSecuenciaCashBack CHAR (7),
psSecuenciaComisionCashBack CHAR (10),pmMontoComisionCashBack MONEY, psComisionEnLinea CHAR (1), psPermiteComisionPendiente CHAR (1), 
psGeneraComisionPendiente CHAR (1), psSecComision CHAR (7), pmMontoComision MONEY, psCodigoRetComision CHAR (5), psIdReceptor CHAR (4), 
psQUERY2 CHAR (350), psRFCodigoISO CHAR (2), pmRFMonto MONEY, psRFSecuencia CHAR (7), psRFFechaMov CHAR (4), psRFEnLinea CHAR (1), 
psRFIdTerminal CHAR (8), psRFHoraLocalTransaccion CHAR (6), psDESCRIPCION1 CHAR (100), psDESCRIPCION2 CHAR (100), psDESCRIPCION3 CHAR (200), 
psREGISTROCENTRAL1 CHAR (300), psREGISTROCENTRAL2 CHAR (300), psQUERY3 CHAR (2000), piEstado INTEGER, vsTipoConciliacion CHAR (2) ) 


RETURNING INTEGER ;

--****************************************************************************************************
-- DESCRIPCION: GUARDA LA TRAYECTORIA COMPLETA DEL REGISTRO CONCILIADO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */ 
DEFINE vsEstado CHAR(60) ;
DEFINE vsNombreArchivo CHAR(23);

DEFINE viCodRet INTEGER ;
DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsEstado = '' ;
LET vsNombreArchivo = '';

LET viCodRet = 0 ;
LET visqlerr = 0 ;
BEGIN 
        
        IF ( piEstado > 0 ) THEN 

            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT Descripcion INTO vsEstado FROM StatusCon WHERE Estado = piEstado ;
            LET vsEstado = '[' || piEstado || ']: ' || vsEstado ;
			
			SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 valor INTO vsNombreArchivo FROM intercard:param_conciliacionauto WHERE descripcion = 'NOMBRE_ARCHIVO';

        END IF ;

        INSERT INTO LOG_POS (
            FechaConciliacion,
            ArchivoOrigen,
            NumTarjeta,
            TipoTransaccion,
            Monto,
            MontoCashBack,
            IdComercio,
            NomComercio,
            Secuencia,
            RefTransaccion,
            RFC,
            FuenteId,
            NumCuenta,
            QUERY1,
            CodigoIso,
            Formato,
            MovConciliado,
            FechaMov,
            HoraMov,
            CodigoAplicCentral,
            SecuenciaOrig,
            HoraLocalTransaccion,
            MontoRealFzda,
            CodTran,
            EnLinea,
            IdTerminal,
            ProdInd,
            SecuenciaCashBack,
            SecuenciaComisionCashBack,
            MontoComisionCashBack,
            ComisionEnLinea,
            PermiteComisionPendiente,
            GeneraComisionPendiente,
            SecComision,
            MontoComision,
            CodigoRetComision,
            IdReceptor,
            QUERY2,
            RFCodigoISO, 
            RFMonto, 
            RFSecuencia, 
            RFFechaMov, 
            RFEnLinea, 
            RFIdTerminal, 
            RFHoraLocalTransaccion,
            DESCRIPCION1,
            DESCRIPCION2,
            DESCRIPCION3,
            REGISTROCENTRAL1,
            REGISTROCENTRAL2,
            QUERY3,
            Estado,
            TipoConciliacion,
			NombreArchivo
        )
        VALUES (

            CURRENT,
            NVL ( psArchivoOrigen, '' ),
            NVL ( psNumTarjeta, '' ),
            NVL ( psTipoTransaccion, '' ),
            NVL ( pmMonto, 0 ),
            NVL ( pmMontoCashBack, 0 ),
            NVL ( psIdComercio, '' ),
            NVL ( psNomComercio, '' ),
            NVL ( psSecuencia, '' ),
            NVL ( psRefTransaccion, '' ),
            NVL ( psRFC, '' ),
            NVL ( psFuenteId, '' ),
            NVL ( psNumCuenta, '' ),
            NVL ( psQUERY1, '' ),
            NVL ( psCodigoIso, '' ),
            NVL ( psFormato, '' ),
            NVL ( psMovConciliado, '' ),
            NVL ( psFechaMov, '' ),
            NVL ( psHoraMov, '' ),
            NVL ( psCodigoAplicCentral, '' ),
            NVL ( psSecuenciaOrig, '' ),
            NVL ( psHoraLocalTransaccion, '' ),
            NVL ( pmMontoRealFzda, 0 ),
            NVL ( psCodTran, '' ),
            NVL ( psEnLinea, '' ),
            NVL ( psIdTerminal, '' ),
            NVL ( psProdInd, '' ),
            NVL ( psSecuenciaCashBack, '' ),
            NVL ( psSecuenciaComisionCashBack, '' ),
            NVL ( pmMontoComisionCashBack, 0 ),
            NVL ( psComisionEnLinea, '' ),
            NVL ( psPermiteComisionPendiente, '' ),
            NVL ( psGeneraComisionPendiente, '' ),
            NVL ( psSecComision, '' ),
            NVL ( pmMontoComision, 0 ),
            NVL ( psCodigoRetComision, '' ),
            NVL ( psIdReceptor, '' ),
            NVL ( psQUERY2, '' ),
            NVL ( psRFCodigoISO, '' ),
            NVL ( pmRFMonto, 0 ), 
            NVL ( psRFSecuencia, '' ), 
            NVL ( psRFFechaMov, '' ),
            NVL ( psRFEnLinea, '' ),
            NVL ( psRFIdTerminal, '' ),
            NVL ( psRFHoraLocalTransaccion, '' ),
            NVL ( psDESCRIPCION1, '' ),
            NVL ( psDESCRIPCION2, '' ),
            NVL ( psDESCRIPCION3, '' ),
            NVL ( psREGISTROCENTRAL1, '' ),
            NVL ( psREGISTROCENTRAL2, '' ),
            NVL ( psQUERY3, '' ),
            NVL ( vsEstado, '' ),
            NVL ( vsTipoConciliacion, '' ),
			TRIM(NVL ( vsNombreArchivo, '' ))
        ) ;


    RETURN viCodRet ;

END

END PROCEDURE 
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA LA TRAYECTORIA COMPLETA DEL REGISTRO CONCILIADO.',
'Fecha: 2008/03/10',
'Version: 20080310.1233',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO LA LOGICA PARA QUE GUARDE EL CAMPO NOMBRE ARCHIVO EN LA TABLA DE LOG_POS.',
'Fecha: 2010/01/19',
'Version: 20100119.1000',
'BD: Intercard''',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1239',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_insertarcentral ( 
psArchivoOrigen CHAR (3),
psTipoMov CHAR (1), 
psTipoTransaccionConciliacion CHAR (4), 
psFolioSucursal CHAR (16), 
psTipoTransaccionSucursal CHAR (4), 
psNumTarjeta CHAR (16 ), 
psDocumento CHAR (15),  
pmImporte MONEY, 
psMoneda CHAR (3),  
psReferencia CHAR (40), 
psFolioOrig CHAR (15), 
psDocumentoOrig CHAR (7), 
psTransaccionOrig CHAR (4), 
pmMontoOrig MONEY, 
pmCashBackMonto MONEY, 
psRFC CHAR (16), 
psReferenciaTransaccion CHAR (23),
--
psDivisa CHAR (3),
pmMontoDivisa MONEY,
psFormadePago CHAR (1),
--
psNumCajero CHAR (14),
psTipoTransInterEmpresa CHAR (4),
pmMontoComInterEmpresa MONEY,
psConvenioInterEmpresa CHAR (10)
)
   
RETURNING CHAR (250) ;

--****************************************************************************************************
-- DESCRIPCION: GUARDA EL REGISTRO QUE SE ENVIA A CENTRAL  (ATM POS)
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */ 
DEFINE vsFolioOrig CHAR (15) ;
DEFINE vsDocumentoOrig CHAR (7) ;
DEFINE vsTransaccionOrig char (4) ;
DEFINE vsNombreArchivo CHAR(23);
DEFINE vsControl CHAR(1);

DEFINE vdtFechaConciliacion DATETIME DAY TO FRACTION ;
DEFINE vsSalida CHAR (250) ;
/* INICIALIZACION DE VARIABLES */
LET vdtFechaConciliacion = CURRENT ; 
LET vsSalida = '' ;
LET vsNombreArchivo = '';
LET vsControl ='';


BEGIN 

    LET vsFolioOrig = LPAD (psFolioOrig, 15, '0' ) ;
    LET vsDocumentoOrig = LPAD (psDocumentoOrig, 7, '0') ;
    LET vsTransaccionOrig = LPAD (psTransaccionOrig, 4, '0' ) ;

    IF ( ( psArchivoOrigen = 'PNC' ) AND ( psFormadePago = '' ) ) THEN 
        LET psFormadePago = '0' ;
    END IF ;
	

	SET LOCK MODE TO WAIT  ;
    SET ISOLATION TO DIRTY READ ;
	SELECT FIRST 1 valor INTO vsNombreArchivo FROM intercard:param_conciliacionauto WHERE descripcion = 'NOMBRE_ARCHIVO';

    IF psTipoMov ='D' THEN
        LET vsControl='D';
    ELSE
        LET vsControl='0';
    END IF; 

    INSERT INTO CENTRAL (
        ArchivoOrigen, --TMC, TMD, VNC, VND, VIC, VID, VPN
        DoctoOrig, 
        Documento, 
        FechaConciliacion, 
        FolioOrig, 
        FolioSucursal, 
        Ident_Det, -- D
        Importe, 
        Moneda, 
        MontoOriginal, 
        NumTarjeta, 
        Referencia, 
        RefTransaccion, 
        RFC, 
        Sucursal, 
        TipoMov,  -- C, A, R
        Transaccion, 
        TransaccionOrig,
        Divisa,
        MontoDivisa,
        NumCajero,
        Convenio,
        TipoTransInterEmpresa,
        MontoComInterEmpresa,
        FormadePago,
        Control,
		NombreArchivo,
		IdArchivoCental
    )
    VALUES (
        NVL( psArchivoOrigen, '' ), 
        NVL( vsDocumentoOrig, '' ), 
        NVL( psDocumento, '' ), 
        NVL( vdtFechaConciliacion , CURRENT ), 
        NVL( vsFolioOrig, '' ), 
        NVL( psFolioSucursal, '' ), 
        'D', 
        NVL( pmImporte, 0.0 ),
        NVL( psMoneda, '' ),
        NVL( pmMontoOrig, 0.0 ),
        NVL( psNumTarjeta, '' ),
        NVL( psReferencia, '' ), 
        NVL( psReferenciaTransaccion, '' ), 
        NVL( psRFC, '' ),
        NVL( psTipoTransaccionSucursal, '' ), 
        NVL( psTipoMov, '' ),
        NVL( psTipoTransaccionConciliacion, '' ),
        NVL( vsTransaccionOrig, '' ),
        NVL( psDivisa, '' ),
        NVL( pmMontoDivisa, 0.0 ),
        NVL( psNumCajero, '' ),
        NVL( psConvenioInterEmpresa, '' ),
        NVL( psTipoTransInterEmpresa, '' ),
        NVL( pmMontoComInterEmpresa, 0.0 ),
        NVL( psFormadePago, '' ),
        vsControl,
		TRIM(NVL( vsNombreArchivo, '' )),
		''
    ) ;

    LET vsSalida = 'D|' 
    || NVL( TRIM (psTipoMov), '' ) || '|' 
    || NVL( TRIM(psTipoTransaccionConciliacion), '' ) || '|' 
    || NVL( TRIM(psTipoTransaccionSucursal), '' ) || '|'  
    || NVL( TRIM(psFolioSucursal), '' ) || '|' 
    || NVL( TRIM(psNumTarjeta), '' ) || '|' 
    || NVL( TRIM(psDocumento), '' ) || '|' 
    || REPLACE ( NVL( pmImporte, 0 ), '$', '' ) || '|' 
    || NVL( TRIM(psMoneda), '' ) || '|' 
    || NVL( TRIM(psReferencia), '' ) || '|' 
    || NVL( TRIM(vsFolioOrig), '' ) || '|' ||  NVL( vsDocumentoOrig , '' ) || '|' 
    || NVL( TRIM(vsTransaccionOrig), '' ) || '|' 
    || REPLACE ( NVL( pmMontoOrig, 0 ), '$', '' ) || '|' 
    || NVL( TRIM(psRFC), '' ) || '|' 
    || NVL( TRIM(psReferenciaTransaccion), '' ) || '|' 
    || NVL( TRIM(psDivisa), '' ) || '|' 
    || REPLACE ( NVL( pmMontoDivisa, 0 ), '$', '' ) || '|' 
    || NVL( TRIM(psNumCajero), '' ) || '|'        
    || NVL( TRIM(psTipoTransInterEmpresa), '' ) || '|' 
    || NVL( TRIM(psConvenioInterEmpresa), '' ) || '|' 
    || REPLACE ( NVL( pmMontoComInterEmpresa, 0 ), '$', '' ) || '|' 
    || NVL( TRIM(psFormadePago), '' )
    || '|0'  ;

    RETURN vsSalida  ;

END

END PROCEDURE 
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA EL REGISTRO QUE SE ENVIA A CENTRAL  (ATM POS).',
'Fecha: 2008/03/10',
'Version: 20080310.1233',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO LA LOGICA PARA QUE GUARDE EL CAMPO NOMBRE ARCHIVO  Y EL ID CON EL QUE SE PASA A LA APLICACION DE SALTDOS EN LA TABLA DE CENTRAL.',
'Fecha: 2010/01/19',
'Version: 20100119.01533',
'BD: Intercard''',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1241',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_conciliacion_atm_registro( 
psNumEmpleado CHAR (8), 
psArchivoOrigen CHAR (3), 
psActividad CHAR (25),
psUsuarioParametros CHAR (8),
psSecuenciaAuth CHAR (6) ,
psNumTarjeta CHAR (16) ,
psFecha CHAR (8) ,
psHora CHAR (8) ,
psAdquiriente CHAR (4) ,
psNumCuenta CHAR (13) ,
psDescripcion CHAR (15) ,
psIndicadordeReversa CHAR (19) ,
psCodigoISO CHAR (2)  ,
psSecuenciaCajero CHAR (12) ,
pmMonto MONEY ,
psNombreComercio CHAR (30) ,
psReferenciaTransaccion  CHAR (23) , --''
psRFC CHAR (16) , --''
psNumCajero CHAR (14),
piNumRegistro INTEGER,
psResp CHAR(6),  --nuevo
psOrden CHAR(6), 
psRed CHAR(7), 
psDolares CHAR(7), 
psNumAutorizacion CHAR(6), 
psCodPais CHAR(2), 
psMontoOrigen CHAR(13), 
psCodMoneda CHAR(3), 
pmMontoSurcharge MONEY(16,2), 
pmDonativo MONEY(16,2), 
psEmpresa CHAR(4), 
psCompania CHAR(10), 
pmMonto_LoyaltyFee MONEY(16,2), 
pmMonto_UsoLinea MONEY(16,2), 
psNomBancoEmisor CHAR(20), 
psBanderaAdquiriente CHAR(1)  --nuevo
)

RETURNING INTEGER, CHAR (500) ;

--****************************************************************************************************
-- DESCRIPCION: PROCEDO DE CONCILIACION A UN REGISTRO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 01/07/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO :  : 15/04/2010 Casanova Edeza Hector Juan  --se agregan los parametros Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para que se guarden en la tabla Log_ATM .
-- MODIFICADO :  : 11/05/2010 Casanova Edeza Hector Juan  --Se modifico la logica para que el monto representado en el archivo se le reste el monto surcharge debido a que se reporta el monto del retiro + la comision surcharge.
-- MODIFICADO :  : 14/05/2010 Casanova Edeza Hector Juan  --Se pasa el parametro del monto surcharge al sp de tipo conciliacion para relizar validaciones extras de la transaccion.
--***************************************************************************************************

--CHECAR LO DE LA REFRENCIA
DEFINE vsmensajeError CHAR (500) ;
DEFINE vsReferencia CHAR (40) ;

DEFINE vsDESCRIPCION2 CHAR (100) ;
DEFINE vsDESCRIPCION3 CHAR (100) ;

DEFINE vsQUERY1 CHAR (1000) ;   --SELECT DE MOVIMIENTO
DEFINE vsQUERY2 CHAR (2000) ;    --INSERT DE MOVCONCILIADOS

DEFINE vsREGISTROCENTRAL1 CHAR (250) ;
DEFINE vsREGISTROCENTRAL2 CHAR (250) ;

/*  DEFINICION DE VARIABLES */

--- VARIABLES DEL SELECT DE MOVIMIENTOS
DEFINE vsMovSecuencia CHAR (7) ;    --ClaveAutorizacionDeTransaccion
DEFINE vsMovSecuenciaExtendida CHAR (16) ;    --ClaveAutorizacionDeTransaccion
DEFINE vsMovCodigoISO CHAR (2) ;
DEFINE vmMovMonto  MONEY ;
DEFINE vsMovMovConciliado  CHAR (1) ;
DEFINE vsMovMovReversado CHAR (1) ;
DEFINE vsMovFechaMov CHAR (4) ;
DEFINE vsMovCodigoCentral CHAR (5) ;
DEFINE vsMovSecuenciaOrig CHAR (7) ;
DEFINE vsMovHoraMov CHAR (6) ;
DEFINE vsMovCodReversa CHAR (1) ;
DEFINE vmMovMontoRealRevFzda MONEY ;
DEFINE vsMovIdTerminal CHAR (16) ;
DEFINE vsMovEnLinea CHAR (1) ;
DEFINE vsMovEsNacional CHAR (1) ;
DEFINE vsMovFechaLocalTransaccion CHAR (4) ;
DEFINE vsMovHoraLocalTransaccion CHAR (6) ;
--DEFINE vdtMovFechaHoraInAuthorizer CHAR (25) ;
DEFINE vdtMovFechaHoraInAuthorizer DATETIME YEAR TO FRACTION ;
DEFINE vsMovPermiteComisionPendiente CHAR (1) ;
DEFINE vsMovGeneroComisionPendiente CHAR (1) ;
DEFINE vsMovSecComision CHAR (7) ;
DEFINE vsMovComisionEnLinea CHAR (1) ;
DEFINE vmMovMontoComision MONEY ;
DEFINE vsMovCodigoRetComision CHAR (5) ;
DEFINE vmMovMontoSurcharge MONEY ;
DEFINE vsMovSecSurcharge CHAR (7) ;
DEFINE vsMovIdComercio CHAR (10) ;
DEFINE vmMovMontoCashBack  MONEY ;
DEFINE vmMovMontoComCashBack  MONEY ;
DEFINE vmMovMontoRetenido MONEY ;
DEFINE vsMovMoneda CHAR (3) ;
DEFINE vsMovSecuenciaCashBack  CHAR (7) ;
DEFINE vsMonvSecuenciaComCashBack CHAR (7) ;
DEFINE viStatusConSurcharge     INTEGER ;
DEFINE vsStatusComision CHAR (1) ;

--VARIABLES DE ENTORNO
DEFINE vsCodTran  CHAR (2) ;
DEFINE vsProdInd CHAR (2) ;
DEFINE vsFormato CHAR (4) ;
DEFINE vsRegistrado CHAR (1) ;
DEFINE vsCodRespBASE24 CHAR (3) ;
DEFINE vsFuenteId CHAR (3) ;
DEFINE vsNacional  CHAR (1) ;
DEFINE vsTarjetaNoRelacionada CHAR (1) ;
DEFINE vsEsPropio CHAR (1) ;
DEFINE vsEsConvenio CHAR (1) ;

DEFINE vsCodAux1 CHAR (2) ;
DEFINE vsCodAux2 CHAR (2) ;
DEFINE viContador INTEGER ;

DEFINE vmMontoTran MONEY ;

DEFINE viTipodeTransaccion INTEGER ;
DEFINE viStatusTarjeta INTEGER ;

DEFINE viStatusConciliacion  INTEGER ;

DEFINE vsSecEnviadaCentral CHAR (7) ;
DEFINE vsTipoEnviadaCentral CHAR (1) ;

DEFINE vsTipoRecibidaCentral     CHAR (1) ;
DEFINE vsTnrCobroComisionCtaIndividual  CHAR (1) ;
DEFINE vmTnrMontoComisionCtaIndividual MONEY ;

DEFINE vsCodRet CHAR (5) ;
DEFINE vsCodRetSurcharge CHAR (5) ;
DEFINE vsFechaAplib DATETIME YEAR TO FRACTION ;
DEFINE vsFechaReporteBreve DATETIME YEAR TO FRACTION ;
DEFINE vsFechaLocalTransaccion CHAR (4) ;
DEFINE vsFechaLocalTransaccionMMDD CHAR (4) ;
DEFINE vsHoraLocalTransaccion CHAR (6) ;

DEFINE vsTipoTransaccionConciliacion CHAR (4) ;
DEFINE vsFolioSucursal CHAR (16) ; /* de 15 a 16 No se usa*/
DEFINE vsDocumento CHAR (16) ; /* de 15 a 16*/
DEFINE vsTipoTransaccionSucursal CHAR (4) ;

DEFINE viGenRefTipoMovimiento INTEGER ;
DEFINE vsReferenciaComision CHAR (20) ;
DEFINE vsClaveAutorizacionDeTransaccion CHAR (7) ;
DEFINE vmMontoReversa MONEY ;

DEFINE viExisteEnMovimiento INTEGER ;
DEFINE vsCobrable CHAR (1) ;
DEFINE vsTransConciliado CHAR (1) ;
DEFINE vsStatusTarjeta CHAR (3) ;

DEFINE vsTipoConciliacion CHAR (2) ;
DEFINE vsTipoCajero CHAR (1) ;

--VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr   INTEGER ;
DEFINE viCodRet   INTEGER ;


DEFINE vsTemp CHAR (8) ;
/* INICIALIZACION DE VARIABLES */
LET vsmensajeError  = '' ;

LET vsReferencia = '' ;

--VARIABLES LOG 
LET vsDESCRIPCION2 = '' ;
LET vsDESCRIPCION3 = '' ;

LET vsQUERY1 = '' ;
LET vsQUERY2 = '' ;

LET vsREGISTROCENTRAL1 = '' ;
LET vsREGISTROCENTRAL2 = '' ;

--- VARIABLES DEL SELECT DE MOVIMIENTOS
LET vsMovSecuencia = '' ;
LET vsMovCodigoISO = '' ;
LET vmMovMonto = 0 ;
LET vsMovMovConciliado = '' ;
LET vsMovMovReversado = '' ;
LET vsMovFechaMov = '' ;
LET vsMovCodigoCentral = '' ;
LET vsMovSecuenciaOrig = '' ;
LET vsMovHoraMov = '' ;
LET vsMovCodReversa = '' ;
LET vmMovMontoRealRevFzda =  0 ;
LET vsMovIdTerminal = '' ;
LET vsMovEnLinea = '' ;
LET vsMovEsNacional = '' ;
LET vsMovFechaLocalTransaccion = '' ;
LET vsMovHoraLocalTransaccion = '' ;
LET vdtMovFechaHoraInAuthorizer = NULL ;
LET vsMovPermiteComisionPendiente = '' ;
LET vsMovGeneroComisionPendiente = '' ;
LET vsMovSecComision = '' ;
LET vsMovComisionEnLinea = '' ; 
LET vmMovMontoComision = 0 ;
LET vsMovCodigoRetComision = '' ;
LET vmMovMontoSurcharge = 0 ;
LET vsMovSecSurcharge = '' ;
LET vsMovIdComercio = '' ;
LET  vmMovMontoCashBack  = 0 ;
LET  vmMovMontoComCashBack  = 0 ;
LET vmMovMontoRetenido = 0 ;
LET vsMovSecuenciaCashBack = '' ;
LET vsMonvSecuenciaComCashBack  = '' ;
LET vsMovSecComision   = '' ;
LET viStatusConSurcharge = 0 ;
LET vsStatusComision = '' ;

-- VARIABLES DE ENTORNO

LET vsCodTran  = '00' ;
LET vsProdInd = '01' ;
LET vsFormato = '0200' ;
LET vsRegistrado = 'F' ;
LET vsFuenteId = '000' ;
LET vsNacional = 'v' ;
LET vsTarjetaNoRelacionada = 'F' ;
LET vsEsPropio = 'V' ;
LET vsEsConvenio = 'V' ;

LET vsCodAux1 = '00' ;
LET vsCodAux2 = '00' ;
LET viContador = 0 ;
LET vmMontoTran = 0 ;

LET viTipodeTransaccion  = 0 ;
LET viStatusTarjeta  = 0 ;

LET viStatusConciliacion = 0 ;
LET vsSecEnviadaCentral = '' ;
LET vsTipoEnviadaCentral  = '' ;

LET vsTipoRecibidaCentral = '' ;
LET vsTnrCobroComisionCtaIndividual  = '' ;
LET vmTnrMontoComisionCtaIndividual = 0 ;

LET vsCodRet  = NULL ;
LET vsCodRetSurcharge = NULL ;
LET vsFechaAplib = NULL ;
LET vsFechaReporteBreve = NULL ;
LET vsFechaLocalTransaccion = '' ;
LET vsFechaLocalTransaccionMMDD = '';
LET vsHoraLocalTransaccion = '' ;

LET vsTipoTransaccionConciliacion  = '' ;
LET vsFolioSucursal = '' ;
LET vsDocumento = '' ;
LET vsTipoTransaccionSucursal = '' ;

LET viGenRefTipoMovimiento  = 0 ; 
LET  vsReferenciaComision = '' ;
LET vsClaveAutorizacionDeTransaccion  = '' ;
LET vmMontoReversa = 0;
LET viExisteEnMovimiento  = 0 ;
LET vsTransConciliado  = 'F' ;
LET vsCobrable = 'F' ;

LET vsStatusTarjeta = '' ;

LET vsMovMoneda = '01' ;
LET vsCodRespBASE24 = '' ;

LET vsTipoCajero = '' ;

--VARIABLE DE MANEJO DE ERRORES
LET viCodRet = "0";
LET visqlerr = 0;

LET vsTemp = '' ;

LET vsTipoConciliacion = '' ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN             

  --SET DEBUG FILE TO "/home/informix/jydg/sp_conciliacion_atm_registro.out";
  --TRACE ON;

            
            --GUARDA EL REGISTRO DEL LOG DE LA TRANSACCION ACTUAL

            EXECUTE PROCEDURE sp_Insertar_Bitacora ( psNumEmpleado, psArchivoOrigen, psActividad, ' ('|| visqlerr || ')  ' || vsmensajeError ||  '-- Registro Num: ' 
                    || piNumRegistro ) INTO viCodRet ;
					
			--SE AGREGA EL MONTO DE LAS TRANSACCIONES CON SURCHARGE AL MONTO TOTAL DE LA TRANSACCION (MONTO ORIGINAL DEL ARCHIVO)
			IF ((pmMonto > 0) AND (pmMontoSurcharge > 0)) THEN -- OPERACION DE RETIRO
				LET pmMonto = pmMonto + pmMontoSurcharge;
			END IF;
			
            EXECUTE PROCEDURE sp_Insertar_LOG_ATM ( psArchivoOrigen, psAdquiriente, psNumTarjeta, psNumCuenta, 
            psDescripcion, psIndicadordeReversa, psCodigoISO, psSecuenciaCajero, psFecha, psHora, pmMonto,  psNumCajero, psSecuenciaAuth,
			psResp, psOrden, psRed, psDolares, psNumAutorizacion, psCodPais,  psMontoOrigen,  --nuevo
			psCodMoneda, pmMontoSurcharge, pmDonativo, psEmpresa, psCompania,  --nuevo
			pmMonto_LoyaltyFee, pmMonto_UsoLinea, psNomBancoEmisor, psBanderaAdquiriente, --nuevo
            vsQUERY1 , vsMovCodigoISO, vsMovSecuencia, vsMovSecuenciaOrig, vsMovCodReversa, 
            vsMovComisionEnLinea, vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision, 
            vmMovMontoComision,  vsMovCodigoRetComision, vmMovMonto, vmMovMontoRealRevFzda, vsMovMovConciliado , vsMovFechaMov, 
            vsMovHoraMov,vsMovMovReversado, vsMovEnLinea, vsMovIdTerminal, vsDESCRIPCION2 , vsDESCRIPCION3, 
            vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vsQUERY2 , viStatusConciliacion, vsTipoConciliacion ) INTO viCodRet  ;

           RETURN visqlerr, vsmensajeError ;

        END IF; 
    END EXCEPTION;

	
		--SE RESTA EL MONTO DE LAS TRANSACCIONES CON SURCHARGE AL MONTO TOTAL DE LA TRANSACCION
		IF ((pmMonto > 0) AND (pmMontoSurcharge > 0)) THEN -- OPERACION DE RETIRO
			LET pmMonto = pmMonto - pmMontoSurcharge;
		END IF;
		
        -- VALORES PREDETERMINADOS PARA ESTOS CAMPOS 

        LET vsReferencia = psSecuenciaCajero ;

        --ASIGNA EL CODIGO DE TRANSACCION CORRSPONDIENTE A LA DESCRIPCION DE LA TRANSACCION
        IF ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'RETIRO'  OR SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'VTA_ELEC' ) THEN 
            LET vsCodTran = '01' ;
            IF ( SUBSTRING (psIndicadordeReversa FROM 1 FOR 8 ) = 'REVERSAL') THEN 
                LET vsFormato = '0420' ;    --SI ES REVERSA CAMBIA EL CODIGO DEL FORMIATO
            END IF ;
        ELIF ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'CONSULTA' ) THEN 
            LET vsCodTran = '31';
        ELIF ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'CAMB_NIP' ) THEN 
            LET vsCodTran = '81' ;
        END IF ; 

        IF ( SUBSTRING ( psAdquiriente FROM 1 FOR 8  ) = 'VISA' )  THEN --TRANSACCION INTERNACIONAL
            LET vsNacional = 'F' ;
        ELSE  --TRANSACCION NACIONAL
            LET vsNacional = 'V' ;
        END IF ;

        LET  vsCodRespBASE24  = LPAD ( TRIM ( psCodigoISO ), 3, "0" ) ;
        
        IF ( psCodigoISO = '00' ) THEN -- CHECA QUE LA TRANSACCION ESTE APROVADA
               
            IF (psAdquiriente = 'VISA' )  AND  ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) <> 'CONSULTA'  AND  SUBSTRING (psDescripcion FROM 1 FOR 8 ) <> 'RETIRO'  ) THEN
                 --ES UNA TRANSACCION INTERNACIONAL Y NO ES CONSULTA NI RETIRO Y SERA IGNORADA
                LET vsDESCRIPCION3 = 'Aviso. Transaccion VISA Ignorada' ;
                LET vsTipoConciliacion = 'B' ;

            ELSE    --TRANSACCION NACIONAL O INTERNACIONAL (CONSULTA O RETIRO)
                LET vsmensajeError = 'Obtiene Informacion del adquiriente de la transaccion -- sp_EsPropio( ' || 
                psAdquiriente || ' ) INTO vsEsPropio ;'   ;
                --REGRESA UN V O F INDICANDO SI LA TRANS SE REALIZO EN UN CAJERO PROPIO (COPPEL)
                EXECUTE PROCEDURE sp_EsPropio( psAdquiriente ) INTO vsEsPropio ;
                LET vsmensajeError = 'Obtiene Informacion del adquiriente de la transaccion -- sp_EsConvenio( ' 
                || psAdquiriente || ' ) INTO vsEsConvenio;'   ;
                EXECUTE PROCEDURE sp_EsConvenio( psAdquiriente ) INTO vsEsConvenio ;
                
                LET vsmensajeError = 'Obtiene datos de la transaccion de la tabla de movimientos -- ' ||
                'sp_ObtenerDatosTransaccionDBMovimiento_ATM ( ' || psDescripcion || ', ' || psNumTarjeta|| ', ' || 
                vsFormato|| ', ' || vsProdInd|| ', ' || vsCodTran || ', ' || psFecha || ', ' || psHora || ', ' || psSecuenciaCajero || ', ' || 
                psAdquiriente || ', ' || psSecuenciaAuth  || ') ' ;

                EXECUTE PROCEDURE sp_ObtenerDatosTransaccionDBMovimiento_ATM
                ( psDescripcion,  psNumTarjeta,  vsFormato, vsProdInd,  vsCodTran, psFecha, psHora, psSecuenciaCajero, 
                psAdquiriente, psSecuenciaAuth ) 
                INTO  viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, 
                vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral, vsMovSecuenciaOrig, vsMovHoraMov, 
                vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional, 
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, 
                vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision, 
                vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision, vmMovMontoSurcharge, 
                vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack, 
                vsMonvSecuenciaComCashBack, vsQUERY1 ; 
                
                LET vsFechaLocalTransaccion = SUBSTRING ( psFecha FROM 1 FOR 2 ) || SUBSTRING ( psFecha FROM 4 FOR 2 ) ;
                LET vsFechaLocalTransaccionMMDD = SUBSTRING ( psFecha FROM 4 FOR 2 ) || SUBSTRING ( psFecha FROM 1 FOR 2 );
                LET vsHoraLocalTransaccion =  REPLACE (psHora, ':', '' ) ;

                --Si la bandera indica que si se generó una comisión pendiente, se verifica si efectivamente 
                --existe un registro para la comisión pendiente, dado que si el movimiento fue reversado totalmente, 
                --dicho registro se debió haber eliminado y por lo tanto, se debería considerar como si no se hubiera generado la
                --comisión pendiente.
                IF ( viExisteEnMovimiento = 1 ) THEN 
                    LET vsRegistrado = 'V' ;
                ELSE
                    LET vsRegistrado = 'F' ;
                END IF ;

                LET vmMontoTran  = vmMovMonto ;       -- ESTE MONTO VA EN EL LOG. EN EL MONTO
                
                EXECUTE PROCEDURE sp_GetTypeOfTransaction( vsProdInd, vsFormato , vsCodTran , 0 ,  0 ) INTO viTipodeTransaccion  ;

                EXECUTE PROCEDURE sp_EstaBloqueadaoCancelada( psNumTarjeta, SUBSTRING ( psFecha FROM 4 FOR 2) || '/' || 
                SUBSTRING ( psFecha FROM 1 FOR 2) || '/' ||  SUBSTRING ( psFecha FROM 7 FOR 2), psHora ) INTO  viStatusTarjeta, vsStatusTarjeta ;

                IF ( vsEsPropio = 'V' ) THEN -- CAJEROS PROPIOS
                    LET vsTipoCajero = '1' ;
                ELIF ( vsEsConvenio = 'V' ) THEN --CAJEROS EN CONVENIO
                    LET vsTipoCajero = '2' ;
                ELIF ( vsMovEsNacional = 'F' ) THEN  --CAJEROS INTERNACIONALES
                    LET vsTipoCajero = '3' ;
                ELSE -- CAJEROS EN RED  
                    LET vsTipoCajero = '4' ;
                END IF ;

                LET vsmensajeError = 'Clasificacion de Conciliacion --  sp_Tipo_Conciliacion_ATM ' ;

		--Se cambio vsFolioSucursal X vsMovSecuenciaExtendida  
                EXECUTE PROCEDURE sp_Tipo_Conciliacion_ATM ( viExisteEnMovimiento, vsTipoCajero, viStatusTarjeta, SUBSTRING (psDescripcion FROM 1 FOR 8 ), 
                vsMovMovConciliado, psCodigoISO, vsMovCodigoISO, vsMovCodigoCentral, pmMonto, vmMovMonto,
                SUBSTRING (psIndicadordeReversa FROM 1 FOR 8 ), vsMovCodReversa, vsMovMovReversado, vsMovSecuenciaOrig, vsNacional, 
                viGenRefTipoMovimiento, psAdquiriente, vsMovSecuencia,  psUsuarioParametros, psArchivoOrigen, 
                psNumTarjeta, vsDocumento, vsMovSecuenciaExtendida , vsFolioSucursal, vsMovMoneda, vsReferencia, 
                vmMovMontoCashBack, psRFC, psReferenciaTransaccion, vmMovMontoComision, vmMovMontoRealRevFzda, 
                vmMontoTran, psNumCajero, vsMovSecComision, vsFechaLocalTransaccionMMDD, vsHoraLocalTransaccion, pmMontoSurcharge)  
                INTO vsClaveAutorizacionDeTransaccion, vsMovSecComision, viStatusConciliacion, vsDESCRIPCION2, vsDESCRIPCION3, 
                vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vmMontoReversa, viTipodeTransaccion, vsSecEnviadaCentral, vsTipoEnviadaCentral,
                vsTipoConciliacion ;

            END IF ;  --IF (psAdquiriente = 'VISA' )  AND  (psDescripcion =! 'CONSULTA'  AND  psDescripcion =! 'RETIRO'  ) 

        ELSE --SI ES DISTINTO DE 00
            --LET vsDESCRIPCION2 = 'Aviso. Transaccion con numero de Cuenta no asociada. NumTarjeta:[' || psNumTarjeta || ']' ;
            LET vsDESCRIPCION2 = 'Aviso. Transaccion Rechazada  CodigoISo: [' || psCodigoISO || ']' ;
            LET viStatusConciliacion = 17 ;
            LET vsTipoConciliacion = 'A' ;
            LET vsmensajeError = 'sp_ActualizaMovimiento ( "1' || psSecuenciaAuth || '", "' || psNumTarjeta || '", "01")' ;
            --EXECUTE PROCEDURE sp_ActualizaMovimiento ( psSecuenciaAuth, psNumTarjeta, '01' ) INTO vsmensajeError ;
        END IF ; -- ---IF ( psCodigoISO = '00' ) 

        IF ( viStatusConciliacion <> 0) THEN 
         -- ESCRIBE EN LA TABLA DE MOVCONCILIADOS
            LET vsmensajeError = 'Guarda en la Tabla de MovConciliados --  sp_InsertaMovConciliados ' ;  

            EXECUTE PROCEDURE sp_InsertaMovConciliados (
                vsClaveAutorizacionDeTransaccion , 
                psCodigoISO ,
                vsCodRespBASE24 , 
                vsCodRet  ,    
                vsCodRetSurcharge ,
                vsMovCodReversa , 
                vsCodTran , 
                vsEsConvenio ,   
                vsEspropio , 
                vsFechaAplib ,	
                SUBSTRING (REPLACE ( REPLACE ( REPLACE (CURRENT, '-', ''  ), ':', '' ), ' ', '' ) FROM 1 FOR 14 ),  --fechadeconciliacion  '20071205133103',
                vsFechaReporteBreve,    
                SUBSTRING ( psFecha FROM 4 FOR 2 ) ||  '/' || SUBSTRING ( psFecha FROM 1 FOR 2 ) || '/' || SUBSTRING ( psFecha FROM 7 FOR 2 ),
                vdtMovFechaHoraInAuthorizer,  
                vsFechaLocalTransaccion ,  
                vsFormato , 
                vsFuenteId , 
                psHora,
                vsHoraLocalTransaccion,  
                vsMovIdComercio , 
                psAdquiriente, 
                vmMovMontoCashBack , 
                vmMovMontoComCashBack , 
                vmMovMontoComision ,
                pmMonto ,
                vmMovMontoRealRevFzda ,
                vmMontoTran ,
                vmMovMontoSurcharge ,
                vsMovMovReversado , 
                vsNacional , 
                psNombreComercio  , 
                psNumCuenta , 
                psNumTarjeta , 
                vsProdInd , 
                vsReferencia , 
                psReferenciaTransaccion , 
                vsRegistrado , 
                psRFC  , 
                vsSecEnviadaCentral , 
                vsMovSecSurcharge , 
                vsMovSecuenciaCashBack , 
                vsMonvSecuenciaComCashBack  , 
                vsMovSecComision , 
                viStatusConSurcharge  ,
                vsMovCodigoCentral, 
                vsStatusComision , 
                viStatusConciliacion ,
                vsStatusTarjeta, --viStatusTarjeta , 
                vsTipoEnviadaCentral , 
                psArchivoOrigen , 
                vsTipoRecibidaCentral,
                vsTnrCobroComisionCtaIndividual,
                vmTnrMontoComisionCtaIndividual
                ) 
                INTO vsQUERY2 ;   

        END IF ;

   
         IF ( ( viExisteEnMovimiento > 0 ) AND ( viStatusConciliacion <> 0) ) THEN
            --actualizar el movimiento en la tabla como conciliado
            LET vsmensajeError = 'sp_ActualizaMovimiento ( "1' || psSecuenciaAuth || '", "' || psNumTarjeta || '", "01", "' || vdtMovFechaHoraInAuthorizer || '")' ;
            EXECUTE PROCEDURE sp_ActualizaMovimiento ( psSecuenciaAuth, psNumTarjeta, '01',  vdtMovFechaHoraInAuthorizer ) INTO vsmensajeError ;
        END IF ;        

        --GUARDA EL REGISTRO DEL LOG DE LA TRANSACCION ACTUAL
        LET vsmensajeError = 'Guarda el recorrido de la transaccion en LOG_ATM -- sp_Insertar_LOG_ATM ( ) ' ;

		--SE AGREGA EL MONTO DE LAS TRANSACCIONES CON SURCHARGE AL MONTO TOTAL DE LA TRANSACCION (MONTO ORIGINAL DEL ARCHIVO)
		IF ((pmMonto > 0) AND (pmMontoSurcharge > 0)) THEN -- OPERACION DE RETIRO
			LET pmMonto = pmMonto + pmMontoSurcharge;
		END IF;
			
        EXECUTE PROCEDURE sp_Insertar_LOG_ATM ( psArchivoOrigen, psAdquiriente, psNumTarjeta, psNumCuenta, 
        psDescripcion, psIndicadordeReversa, psCodigoISO, psSecuenciaCajero, psFecha, psHora, pmMonto, psNumCajero, psSecuenciaAuth,
		psResp, psOrden, psRed, psDolares, psNumAutorizacion, psCodPais,  psMontoOrigen,  --nuevo
		psCodMoneda, pmMontoSurcharge, pmDonativo, psEmpresa, psCompania,  --nuevo
		pmMonto_LoyaltyFee, pmMonto_UsoLinea, psNomBancoEmisor, psBanderaAdquiriente, --nuevo
        vsQUERY1 , vsMovCodigoISO, vsMovSecuencia, vsMovSecuenciaOrig, vsMovCodReversa, 
        vsMovComisionEnLinea, vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision, 
        vmMovMontoComision,  vsMovCodigoRetComision, vmMovMonto, vmMovMontoRealRevFzda, vsMovMovConciliado , vsMovFechaMov, 
        vsMovHoraMov,vsMovMovReversado, vsMovEnLinea, vsMovIdTerminal, vsDESCRIPCION2 , vsDESCRIPCION3, 
        vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vsQUERY2 , viStatusConciliacion, vsTipoConciliacion ) INTO viCodRet  ;

    
    RETURN visqlerr, vsmensajeError ;
   
END

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: PROCEDO DE CONCILIACION A UN REGISTRO DE ATM.',
'Fecha: 2008/01/07',
'Version: 20080107.1025',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregan los parametros Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para que se guarden en la tabla Log_ATM .',
'Fecha: 2010/04/15',
'Version: 20100415.1859',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Modificacion',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico la logica para que el monto representado en el archivo se le reste el monto surcharge debido a que se reporta el monto del retiro + la comision surcharge.',
'Fecha: 2010/05/11',
'Version: 20100511.1854',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Modificacion',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se pasa el parametro del monto surcharge al sp de tipo conciliacion para relizar validaciones extras de la transaccion.',
'Fecha: 2010/05/14',
'Version: 20100514.1854',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_borrararchconaut(
psNumeroEmpleado CHAR(8)
)

RETURNING INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  BORRA ARCHIVOS DEL SERVIDOR
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 29/09/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
--***************************************************************************************************

/* DEFINICION DE VARIABLES*/
DEFINE viSqlErr INTEGER;
DEFINE viContador INTEGER;
DEFINE vsNomArchivo CHAR (25);
DEFINE vsRuta_Repositorio_AIX CHAR(90);
DEFINE vsArchivoOrigen CHAR(3);
DEFINE vsRuta_Repositorio_WIN CHAR(90);
DEFINE viDias INTEGER;
DEFINE vsSQLC CHAR(100);
DEFINE vdFecha DATE;
DEFINE vsActividad CHAR(25);


/* INICIALIZACION DE VARIABLES */
LET viSqlErr = 0;
LET viContador = 0;
LET vsNomArchivo = '';
LET vsRuta_Repositorio_AIX = '';
LET vsArchivoOrigen = '';
LET vsRuta_Repositorio_WIN = '';
LET viDias = 0;
LET vsSQLC = ''; 
LET vdFecha = CURRENT;
LET vsActividad = '';


-- set debug file to "/tmp/conciliacion/pruebaborrado.txt";
-- Trace on;

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	
	END IF;
END EXCEPTION;

		LET viContador = 0 ;		
		WHILE (viContador < 11) --VERIFICA LA EXISTENCIA DE LOS 11 TIPOS DE ARCHIVO A CONCILIAR
				
			LET viContador = viContador + 1 ;			LET vsNomArchivo = '';
						
			--SE OBTIENE EL NOMBRE DEL ARCHIVO 			
			EXECUTE PROCEDURE sp_obtenernombrearchivo  ( viContador ) INTO vsNomArchivo, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			--OBTENEMOS LA CANTIDAD DE DIAS QUE LSO ARCHIVOS PODRAN ESTAR EN EL SERVIDOR			
			SET ISOLATION TO DIRTY READ ;
			SELECT valor INTO viDias FROM intercard:param_conciliacionauto WHERE descripcion = vsArchivoOrigen;
			--LOS DIAS TIENEN QUE SER MAYOR A CERO PARA PODER PROCEDER CON EL BORRADO DE ARCHIVOS 	
			IF(viDias > 0) THEN
				LET vsSQLC ='';				
				IF( viContador >= 5 ) AND ( viContador <= 8 ) THEN--EN ESTE RANGO SE ENCUENTRAN LOS ARCHIVOS ATM
					LET	vdFecha = CURRENT::DATE -(1) - viDias;					LET vsNomArchivo = SUBSTRING(vsNomArchivo FROM 1 FOR 10);					--LE AGREGAMOS LA NUEVA FECHA PARA QUE BORRE LOS ARCHIVOS INDICADOS					
					LET vsNomArchivo = TRIM(vsNomArchivo) || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 9 FOR 2 ) || '.txt' ;
											
				ELIF (( viContador >= 1 ) AND ( viContador <= 4 )) OR (( viContador >= 9 ) AND ( viContador <= 13 )) THEN--EN ESTE RANGO SE ENCUENTRAN LOS ARCHIVOS POS , INTERREDES Y CORRESPONSALES
					IF ( viContador = 13 ) THEN--SOLO SI ES ARCHIVO PNC 
						LET	vdFecha = CURRENT::DATE -(1) - viDias;
						LET vsNomArchivo = SUBSTRING(vsNomArchivo FROM 1 FOR 8);						
						LET vsNomArchivo = TRIM(vsNomArchivo) || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 7 FOR 4 ) || '.txt' ;
					ELSE --POS NORMALES
						LET vsNomArchivo = SUBSTRING(vsNomArchivo FROM 1 FOR 8);	
						LET	vdFecha = CURRENT::DATE - viDias;
						LET vsNomArchivo = TRIM(vsNomArchivo) || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 7 FOR 4 ) || '.txt' ;		
					END IF;
				END IF;
				
				--SE ARMA EL NOMBRE DEL ARCHIVO BORRADO ES DECIR UNA DESCRIPCION QUE SE INSERTARA EN LA TABLA DE BITACORA_CONCILIACION
				LET vsActividad = 'ARCH ' || TRIM(vsArchivoOrigen) || '_' || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 9 FOR 2 ) || ' BORRADO';	
				--SI NO EXISTE EL NOMBRE ARMADO ANTERIORMENTE EN LA TABLA BITACORA CONCILIACION SE PROCEDERA A BORRAR EL ARCHIVO DEL SERVIDOR Y SE INSERTA INFORMACION EN BITACORA CONCILIACION
				SET ISOLATION TO DIRTY READ ;
				IF NOT EXISTS(SELECT actividad FROM bitacora_conciliacion WHERE actividad = vsActividad) THEN					
					LET vsSQLC = 'rm -f ' || TRIM(vsRuta_Repositorio_AIX) || '/' || TRIM(vsNomArchivo); 
					SYSTEM vsSQLC;
					EXECUTE PROCEDURE sp_insertar_bitacora ( psNumeroEmpleado, vsArchivoOrigen, vsActividad, '') INTO viSQlErr ;	
				END IF;				
				
			END IF;
			
		END WHILE;		
	RETURN viSqlErr;	
					
END

END PROCEDURE
/*DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: BORRA ARCHIVOS DE CONCILIACION DEL SERVIDOR.',
'Fecha: 2008/09/29',
'Version: 20090829.0933',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple los nuevos archivos archivos de corresponsales de pagos(CCP), depositos(CCD) se manejan como archivos de POS durante el proceso de borrado de archivos en el servidor.',
'Fecha: 2010/04/26',
'Version: 20100426.0920',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_consultaconadmincorr(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
			CHAR(12) AS cuenta, CHAR(1) AS tipomov, CHAR(4) AS tran_central, CHAR(16) AS folio325, MONEY(16,6) AS monto325, CHAR(1) AS estatus, CHAR(4) AS txnliberacion, CHAR(19) AS cuentac,
			CHAR(19) AS cuentaa, CHAR(16) AS foliosif, MONEY(16,6) AS montosif, CHAR(8) AS usuario;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsnomarchivo325		CHAR(23);
DEFINE vsnomarchivocom		CHAR(23);
DEFINE vdfecharegistro		DATE;
DEFINE vdfecha				DATE;
DEFINE vsprodtarjeta		CHAR(4);
DEFINE vstarjeta			CHAR(16);
DEFINE vscuenta				CHAR(12);
DEFINE vstipomov			CHAR(1);
DEFINE vstran_central		CHAR(4);
DEFINE vsfolio325			CHAR(16);
DEFINE vmmonto325			MONEY(16,6);
DEFINE vsestatus			CHAR(1);
DEFINE vstxnliberacion		CHAR(4);
DEFINE vscuentac			CHAR(19);
DEFINE vscuentaa			CHAR(19);
DEFINE vsfoliosif			CHAR(16);
DEFINE vmmontosif			MONEY(16,6);
DEFINE vsusuario			CHAR(8);

DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsnomarchivo325 = '';
LET vsnomarchivocom = '';
LET vdfecharegistro = CURRENT;
LET vdfecha = CURRENT;
LET vsprodtarjeta = '';
LET vstarjeta = '';
LET vscuenta = '';
LET vstipomov = '';
LET vstran_central = '';
LET vsfolio325 = '';
LET vmmonto325 = 0.0;
LET vsestatus = '';
LET vstxnliberacion = '';
LET vscuentac = '';
LET vscuentaa = '';
LET vsfoliosif = '';
LET vmmontosif = 0.0;
LET vsusuario = '';

LET viSqlErr = 0;

--SET debug file to "/home/sysifx/conciliacion/Corresponsales/_consultaconadmincorr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
	END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
ELSE
	--Devuelve los registros de tabla conadmin correspondientes al tipo de archivoorigen.
	FOREACH
	SELECT archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
		   cuentac, cuentaa, foliosif, montosif, usuario
	INTO   vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario
	FROM   intercard:conadmin
	WHERE  archivoorigen = psArchivoOrigen AND pdFecha BETWEEN fecha AND fecha ORDER BY keyx ASC

	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
	END FOREACH
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_regeneracion_movimientohistorico
(
pdFechaInicial DATETIME YEAR TO FRACTION (5),
pdFechaFinal DATETIME YEAR TO FRACTION (5)
)
RETURNING INTEGER AS X, CHAR(500) AS DescripcionError, DATETIME YEAR TO FRACTION (5) AS InicioT, DATETIME YEAR TO FRACTION (5) AS FinT,
          INTEGER AS NUMREG;

--****************************************************************************************************
-- DESCRIPCION: Regenera secuencias extendidas y Surcharge de los movimientos históricos Intercard
-- AUTOR : Luis Antonio Gómez Santiago
-- FECHA : 13/07/2010
-- BD: Intercard
-- SISTEMA : SIF
--***************************************************************************************************

DEFINE vsDecripcionError CHAR(500);
DEFINE viSqlErr INTEGER;

DEFINE vsFlagEnTransaccion CHAR(1);
DEFINE viContadorRegistros INTEGER;
DEFINE viContadorRegistrosTot INTEGER;

DEFINE v_secuencia VARCHAR(7);
DEFINE v_numtarjeta VARCHAR(16);
DEFINE v_fechahorainauth DATETIME YEAR TO FRACTION (5);
DEFINE v_prodind VARCHAR(2);
DEFINE v_montosurcharge DECIMAL(19,4);
DEFINE v_fechalocaltransaccion VARCHAR(4);
DEFINE v_horalocaltransaccion VARCHAR(6);
DEFINE vdInicio DATETIME YEAR TO FRACTION (5);
DEFINE vdFin DATETIME YEAR TO FRACTION (5);

LET vsDecripcionError = "";
LET viSqlErr = 0;
LET v_secuencia = "";
LET v_numtarjeta = "";
LET v_fechahorainauth = CURRENT;
LET v_prodind = "";
LET v_montosurcharge = 0.0;
LET vdInicio = CURRENT;
LET vdFin = CURRENT;
LET v_fechalocaltransaccion = "";
LET v_horalocaltransaccion = "";

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN 
		RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/secuencia.out";
--TRACE ON;

IF(pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 1 ;	
    RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END IF;

IF (pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 2;	
    RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END IF;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
LET viContadorRegistrosTot = 0;

FOREACH WITH HOLD                  
           select {+INDEX(intercard:movimientohistorico idx_movimiento3)}                         
                secuencia, numtarjeta, fechahorainauth, prodind, montosurcharge 
           into v_secuencia, v_numtarjeta, v_fechahorainauth, v_prodind, v_montosurcharge 
           from intercard:movimientohistorico
           where fechahorainauth between pdFechaInicial and pdFechaFinal      
           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           IF (v_prodind = '01' AND v_montosurcharge > 0.0) THEN
               update {+INDEX(intercard:movimientohistorico idx_movimiento3)}         
                         intercard:movimientohistorico
                     set secuenciaextendida = 
                             (fechalocaltransaccion || substring(horalocaltransaccion from 1 for 4)  || secuencia),
                         surcharge = 'V'
                     where fechahorainauth = v_fechahorainauth and
                           numtarjeta = v_numtarjeta and
                           secuencia = v_secuencia; 
           ELSE
               update {+INDEX(intercard:movimientohistorico idx_movimiento3)}         
                         intercard:movimientohistorico
                     set secuenciaextendida = 
                         (fechalocaltransaccion || substring(horalocaltransaccion from 1 for 4)  || secuencia) 
                     where fechahorainauth = v_fechahorainauth and
                           numtarjeta = v_numtarjeta and
                           secuencia = v_secuencia; 
           END IF;

           LET viContadorRegistros = viContadorRegistros + 1;           

           IF (viContadorRegistros = 10000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistrosTot = viContadorRegistrosTot + viContadorRegistros;
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;           
           LET vsFlagEnTransaccion = 'F';
           LET viContadorRegistrosTot = viContadorRegistrosTot + viContadorRegistros;
        END IF;
END
LET vdFin = current;
RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END PROCEDURE;