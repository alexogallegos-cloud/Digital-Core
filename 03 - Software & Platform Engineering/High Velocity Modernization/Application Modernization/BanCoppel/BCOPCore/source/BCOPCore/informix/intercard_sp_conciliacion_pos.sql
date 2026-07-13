CREATE PROCEDURE "informix".sp_conciliacion_pos( psNumEmpleado CHAR (8), psArchivoOrigen CHAR (3), psActividad CHAR (25), piRastreo INTEGER )

RETURNING INTEGER ;


--****************************************************************************************************
-- DESCRIPCION: CONCILIACION  POS(325)
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 01/07/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO :  ROCHIN ROCHA EDGAR IVAN  19-08-2008  
--***************************************************************************************************

DEFINE vsmensajeError CHAR (500) ;
DEFINE vsmTmpError CHAR (500) ;
--CHECAR LO DE LA REFRENCIA

/*  DEFINICION DE VARIABLES */
DEFINE viKeyx INTEGER ;
DEFINE vsFecha CHAR (8) ;
DEFINE vsFuenteId CHAR (3) ;
DEFINE vsIdComercio CHAR (9) ;
DEFINE vsMoneda CHAR (3) ;
DEFINE vmMonto MONEY ;
DEFINE vmMontoCashBack MONEY ;
DEFINE vsNomComercio CHAR (30) ;
DEFINE vsNumTarjeta CHAR (16) ;
DEFINE vsRefTransaccion CHAR (23) ;
DEFINE vsRFC CHAR (16) ;
DEFINE vsSecuenciaAuth CHAR (6) ;
DEFINE vsTipoTransaccion CHAR (2) ;  

DEFINE vsGiroNegocio CHAR (4) ;

DEFINE vsDivisa CHAR (3) ;
DEFINE vmMontoDivisa MONEY ;
DEFINE vsFormadePago CHAR (1) ;

DEFINE vsUsuarioParametros CHAR (8) ;

--VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr   INTEGER ;
DEFINE viCodRet   INTEGER ;

DEFINE viRegNumero INTEGER ;

DEFINE  viContReintento INTEGER ;
DEFINE vsFlagReintento CHAR (1) ;

/* INICIALIZACION DE VARIABLES */

LET vsmensajeError = '' ;

--DATOS DE LA TABLA CONCILIACION _POS_IN

LET viKeyx = 0;
LET vsFecha = '' ;
LET vsFuenteId = '' ;
LET vsIdComercio = '' ;
LET vsMoneda = '' ;
LET vmMonto = 0 ;
LET vmMontoCashBack = 0 ;
LET vsNomComercio = '' ;
LET vsNumTarjeta = '' ;
LET vsRefTransaccion = '' ;
LET vsRFC = '' ;
LET vsSecuenciaAuth = '' ;
LET vsTipoTransaccion = '' ;

LET vsGiroNegocio = '' ;

LET vsDivisa = '' ;
LET vmMontoDivisa = 0 ;
LET vsFormadePago = '' ;

LET vsUsuarioParametros = '' ;

--VARIABLE DE MANEJO DE ERRORES
LET viCodRet = '0' ;
LET visqlerr = 0 ;

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
            EXECUTE PROCEDURE intercard:sp_insertar_bitacora ( psNumEmpleado, psArchivoOrigen, psActividad,  vsmTmpError ) INTO viCodRet ;
            
            --REVERSA 
            EXECUTE PROCEDURE intercard:sp_reversa_mov (psNumEmpleado, psArchivoOrigen, 0 ) INTO vsSecuenciaAuth ;        

            RETURN visqlerr ;

        END IF; 
    END EXCEPTION;
    
    IF ( piRastreo > 0  ) THEN
        --SET DEBUG FILE TO '/tmp/conciliacion/TraceConciliacionPOS_' || psArchivoOrigen || '.txt';
        --TRACE ON ;
    END IF ;

     LET vsmensajeError = 'SELECT Usuario FROM Parametros'  ;

	SET LOCK MODE TO WAIT 5;
	SET ISOLATION TO DIRTY READ ;
    SELECT Usuario INTO vsUsuarioParametros FROM intercard:Parametros ;
    LET visqlerr = 0;

    LET vsmensajeError = 'SELECT Keyx, Fecha, GiroNegocio, FuenteId, IdComercio, Moneda, Monto, MontoCashBack, '
        || 'NomComercio, NumTarjeta, RefTransaccion, RFC, SecuenciaAuth, TipoTransaccion, '
        || 'Divisa, MontoDivisa, FormadePago '
        || 'FROM CONCILIACION_POS_IN WHERE Conciliado = "F" AND ArchivoOrigen = "' ||  psArchivoOrigen || '" ORDER  BY KeyX ASC  ' ;


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
    --RECORRE LA TABLA DE CONCILIACION_POS_IN  EN BUSCA DE MOVIMIENTOS SIN CONCILIAR
	
    FOREACH  SELECT Keyx, Fecha, GiroNegocio, FuenteId, IdComercio, Moneda, Monto, MontoCashBack, 
        NomComercio, NumTarjeta, RefTransaccion, RFC, SecuenciaAuth, TipoTransaccion,
        Divisa, MontoDivisa, FormadePago 
        INTO viKeyx, vsFecha, vsGiroNegocio, vsFuenteId, vsIdComercio, vsMoneda, vmMonto, vmMontoCashBack, 
        vsNomComercio, vsNumTarjeta, vsRefTransaccion, vsRFC, vsSecuenciaAuth, vsTipoTransaccion, 
        vsDivisa, vmMontoDivisa, vsFormadePago 
        FROM intercard:CONCILIACION_POS_IN WHERE Conciliado = 'F' AND ArchivoOrigen = psArchivoOrigen ORDER  BY KeyX ASC  

        LET viRegNumero = viRegNumero + 1 ;

        LET viContReintento = 0 ;
        LET vsFlagReintento = 'V' ;

        --NO SE REQUIEREN ESTOS DATOS EN LOS SIGUIENTES ARCHIVOS. 
        IF ( ( psArchivoOrigen = 'VNC' ) OR ( psArchivoOrigen = 'VND' ) OR ( psArchivoOrigen = 'TCC' ) OR ( psArchivoOrigen = 'TCD' ) ) THEN 
            LET vsDivisa = '' ;
            LET vmMontoDivisa = 0.0 ;
            LET vsFormadePago =  '' ;
        ELIF ( psArchivoOrigen = 'PNC' ) THEN 
            LET vsDivisa = '' ;
            LET vmMontoDivisa = 0.0 ;
        ELIF ( psArchivoOrigen = 'VIC' ) OR ( psArchivoOrigen = 'VID' ) THEN 
            IF ( TRIM (vsDivisa) <> '' ) THEN 
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				IF EXISTS (SELECT Abrev_Divisa FROM intercard:Cat_PaisDivisa WHERE Cod_divisa = vsDivisa)  THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ ;
					SELECT LIMIT 1 Abrev_Divisa INTO vsDivisa FROM intercard:Cat_PaisDivisa WHERE Cod_divisa = vsDivisa ;
				END IF ;
            END IF ;
        END IF ;
		
		--SI VIENE ARCHIVO TIENDAS COPPEL CREDITO O DEBITO LA VARIABLE NomComercio TENDRA EL CADENA "COPPEL" CONCATENANDOLE EL VALOR
		IF ( ( psArchivoOrigen = 'TCC' ) OR ( psArchivoOrigen = 'TCD' ) ) THEN
			LET vsNomComercio = 'COPPEL ' || TRIM (vsNomComercio);
		END IF ;
		
		
        WHILE ( ( vsFlagReintento = 'V' ) AND ( viContReintento < 10 ) )

            LET viContReintento = viContReintento +1 ;

            LET vsmensajeError = 'sp_Conciliacion_POS_Registro -- Reistro Num: '  || viRegNumero ;
            EXECUTE PROCEDURE intercard:sp_conciliacion_pos_registro( 
                psNumEmpleado, 
                psArchivoOrigen ,
                psActividad ,
                vsUsuarioParametros ,
                vsFecha ,
                vsGiroNegocio , 
                vsFuenteId ,
                vsIdComercio ,
                vsMoneda ,
                vmMonto ,
                vmMontoCashBack ,
                vsNomComercio ,
                vsNumTarjeta ,
                vsRefTransaccion ,
                vsRFC ,
                vsSecuenciaAuth ,
                vsTipoTransaccion,
                vsDivisa, 
                vmMontoDivisa, 
                vsFormadePago 
            ) INTO visqlerr, vsmensajeError ;

            IF ( visqlerr = -244 ) THEN --ERROR DE CONCURRENCIA
                LET vsFlagReintento = 'V' ;
            ELSE
                LET vsFlagReintento = 'F' ;
            END IF ;

        END WHILE ; 

        IF ( visqlerr <> 0 ) THEN --EN CASO DE ERROR

            LET vsmTmpError = '('|| visqlerr || ') ' || 'Registro Num: ' || viRegNumero || ' -- ' || vsmensajeError ;
            EXECUTE PROCEDURE intercard:sp_insertar_bitacora ( psNumEmpleado, psArchivoOrigen, psActividad, vsmTmpError  ) INTO viCodRet ;

            --REVERSA 
            EXECUTE PROCEDURE intercard:sp_reversa_mov (psNumEmpleado, psArchivoOrigen, 0 ) INTO vsSecuenciaAuth ;

            RETURN visqlerr ;

        ELSE  -- OK

            LET vsmensajeError = 'Actualizacion del registro de la transaccion en Movimiento -- ' ||
            'UPDATE Conciliacion_POS_IN SET Conciliado = "T"  WHERE ArchivoOrigen =  ' || psArchivoOrigen || ' AND SecuenciaAuth = ' || vsSecuenciaAuth ||
            'AND NumTarjeta = ' || vsNumTarjeta ; 
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
            UPDATE intercard:Conciliacion_POS_IN SET Conciliado = 'T'  WHERE Keyx = viKeyx  ;

        END IF ;

    END FOREACH ;

    RETURN viRegNumero ;

END

END PROCEDURE 
;