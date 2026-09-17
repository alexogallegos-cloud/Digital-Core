CREATE PROCEDURE "informix".sp_online_hist()
RETURNING 
CHAR(6) AS CodigoRet, 
CHAR(60) AS Mensaje;
-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(6);
DEFINE cMensaje		CHAR(60);
DEFINE iSqlErr		INTEGER;
DEFINE dFechaHoy	DATE;
DEFINE cParamDias	CHAR(2);
DEFINE dFechaHist	DATE;

-- INICIALIZACION DE VARIABLES.
LET cCodRet 	= '000000';
LET cMensaje 	= 'PROCESO EJECUTADO EXITOSAMENTE';
LET iSqlErr 	= 0;
LET dFechaHoy 	= DATE(1);
LET cParamDias 	= '';
LET dFechaHist 	= DATE(1);

--SET DEBUG FILE TO '/informix/andrescrespo/sp_online_hist.out';
--TRACE ON;
BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'OCURRIO UN ERROR DE INFORMIX';
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION;

	-- OBTENER FECHA HOY.
	SELECT fecha_hoy 
	INTO dFechaHoy	
	FROM bdinteg:'informix'.si_fechas;
	
	-- OBTENER EL PARAMETRO DEL VALOR MES PARA RESTARLO A LA FECHA HOY.
	SELECT TRIM(valor) 
	INTO cParamDias 
	FROM 'informix'.tf_param 
	WHERE cod_param = 3;
	
	-- CALCULAR LA FECHA DE CONSULTA, SE RESTA EL MES PARAMETRIZADO (valor = 2).
	LET dFechaHist = dFechaHoy - cParamDias UNITS DAY;
	
	-- INSERTAR EN LA TABLA HISTORICA LOS REGISTROS DE LA TABLA PRINCIPAL
	-- TOMANDO LOS REGISTROS QUE ESTEN CON LA fec_sistema ANTES DE LOS ULTIMOS DOS MESES
	-- Y QUE EL CAMPO cte_conciliado = 1.
	INSERT INTO 'informix'.tf_online_hist		
	SELECT id,nom_servicio,codigo_ciudad,cliente_mps,cuenta_tf,id_banco,	
	nombre1,nombre2,apell_paterno,apell_materno,
	calle,num_exterior,num_interno,num_depto,colonia,municipio,estado,cod_postal,
	fecha_nac,telefono,correo,esregistro,rfc,met_notificacion,metodo_acceso,fec_sistema,num_tarjeta,
	id_persona,identificacion,num_identificacion,genero,entidad_nac,curp,status_cta,fec_valrenapo,
	comentarios,num_confronta,cta_clabe,cte_conciliado,cte_fusionado,cod_error,desc_error,err_conciliacion,
	MSISDNrecepcion,Telefonica,TipoAsociacion
	FROM 'informix'.tf_cte_online		                                                                    
	WHERE cte_conciliado = '1'                                                                         
	AND fec_sistema < dFechaHist;
	
	-- SI HUBO REGISTROS SE BORRAN LOS REGISTROS QUE SE INSERTARON EN TABLA HISTORICA
	IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
		-- BORRAR LOS REGISTROS CONCILIADOS DE LA TABLA PRINCIPAL 
		DELETE FROM 'informix'.tf_cte_online
		WHERE cte_conciliado = '1' 
			AND fec_sistema < dFechaHist;
	ELSE
		LET cCodRet = '000001';
		LET cMensaje = 'NO HAY REGISTROS POR PROCESAR';
	END IF;
	
	RETURN cCodRet, cMensaje;

END
END PROCEDURE
DOCUMENT
'AUTOR: 93928475 - Guadalupe Payan Camacho',
'FOLIO: 1440',
'DESCRIPCION: Generar historial de registros de la tabla tf_cte_online a la tabla tf_online_hist todos aquellos que su fec_sistema sea antes de los dos ultimos meses en comparacion a la fecha_hoy',
'FECHA: 20/05/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_transfer_bono_alta( pEmpresa CHAR(3) )
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE vActivo      CHAR(8);
    DEFINE vFechaHoy    DATE;
    DEFINE vFechaAnt    DATE;
    DEFINE vMonto       MONEY(14,2);
    DEFINE vHora        CHAR(15);
    DEFINE vFolio       CHAR(16);
    DEFINE vCuenta      CHAR(20);
    DEFINE vFechaAlta   DATE;
    DEFINE cCodRetAbono CHAR(5);
    
    LET cCodRet      = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr      = 0;
    LET iSamErr      = 0;
    LET cDesErr      = 0;
    LET vActivo      = '0';
    LET vFechaHoy    = '';
    LET vFechaAnt    = '';
    LET vMonto       = 0.00;
    LET vHora        = '';
    LET vFolio       = '';
    LET vCuenta      = '';
    LET vFechaAlta   = '';
    LET cCodRetAbono = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_bono_alta.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_bono_alta.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO vActivo
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'VigBonoAltaTransfer';
       
    IF vActivo = '1' THEN
        SELECT fecha_hoy, fecha_ant
          INTO vFechaHoy, vFechaAnt
          FROM bdicheq:sc_fechas
         WHERE empresa = pEmpresa;
        
        SELECT valor
          INTO vMonto
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'MtoBonoAltaTransfer';
         
        LET vHora = CURRENT HOUR TO FRACTION;
        LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
         
        FOREACH WITH HOLD
            SELECT cuenta_tf, fec_alta
              INTO vCuenta, vFechaAlta
              FROM tf_maecte
             WHERE status_cta = '1'
               AND fec_alta = vFechaAnt
            
            EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa,'9250','informix','0327','0000',vFolio,vCuenta,0,vMonto,vMonto,0,0,0,'01','BONO DE BIENVENIDA TRANSFER','','')
            INTO cCodRetAbono;
            
            IF cCodRetAbono = '000' THEN
                INSERT INTO tf_bonos_transfer VALUES( vFechaHoy, 'BONO DE BIENVENIDA', vCuenta, vFechaAlta, vMonto, cCodRetAbono, 'BONO APLICADO' );
            ELSE
                INSERT INTO tf_bonos_transfer VALUES( vFechaHoy, 'BONO DE BIENVENIDA', vCuenta, vFechaAlta, vMonto, cCodRetAbono, 'BONO NO APLICADO' );
            END IF;
        END FOREACH;
    END IF;
    
    END;
    
    RETURN cCodRet; 
    
END PROCEDURE;