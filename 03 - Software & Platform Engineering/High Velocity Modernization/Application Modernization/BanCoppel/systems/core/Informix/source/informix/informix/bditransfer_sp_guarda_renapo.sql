CREATE PROCEDURE "informix".sp_guarda_renapo( 	pcCodigoError        CHAR(4),
												pcTipoError		     CHAR(2),
												pcErrorDescripcion   CHAR(100),
												pcStatusOpe          CHAR(8),
												pcSessionIDRenapo	 CHAR(100),
												pcCurp               CHAR(18),
												pcApePat             CHAR(50),
												pcApeMat             CHAR(50),
												pcNombre             CHAR(50),
												pcSexo               CHAR(1),
												pcFecNac        	 CHAR(10),--<fechNac>18/10/1989</fechNac>
												pcNacionalidad       CHAR(5),
												pcdocProbatorio      CHAR(1),
												pcAnioReg            CHAR(4),
												pcFoja               CHAR(10),
												pctomo		         CHAR(10),
												pcLibro              CHAR(10),
												pcNumActa            CHAR(10),
												pcCrip               CHAR(15),
												pcNumEntidadReg	   	 CHAR(5),
												pcCveMunicipioReg    CHAR(10),
												pcNumRegExtranjeros	 CHAR(10),
												pcFolioCarta	 	 CHAR(20),
												pcCveEntidadNac      CHAR(5),
												pcCveEntidadEmisora  CHAR(8),
												pcStatusCurp		 CHAR(2))
RETURNING
		CHAR (5) AS cCodigoError,
		CHAR (100)AS cErrorDescription,
		CHAR (50) AS cApellidoPaterno,
		CHAR (50) AS cApellidoMaterno,
		CHAR (50) AS cNombre,
		CHAR (15) AS cfechaNacimiento,
		CHAR (12) AS cNumCelular,
		CHAR (16) AS cNumeroTarjeta,
		CHAR (18) AS cCurp,
		CHAR (10) AS cFechaValidacionRenapo,
		CHAR (3)  AS cStatusRenapo;


	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  			INTEGER;
	DEFINE cPCodRet 			CHAR(5);
	DEFINE cCodigoError	 		CHAR (5);
	DEFINE cErrorDescription 	CHAR (100);
	DEFINE cApellidoPaterno 	CHAR (50);
	DEFINE cApellidoMaterno 	CHAR (50);
	DEFINE cNombre 				CHAR (50);
	DEFINE cfechaNacimiento 	CHAR (15);
	DEFINE cNumCelular 			CHAR (12);
	DEFINE cNumeroTarjeta	 	CHAR (16);
	DEFINE cCurp 				CHAR (18);
	DEFINE cFechaValidacionRenapo CHAR (10);
	DEFINE cStatusRenapo 		CHAR (3);
	DEFINE cUsuario				CHAR(12);
	DEFINE cIpRenapo			CHAR(15);
	DEFINE cPassword			CHAR(8);
	DEFINE cTipoTransaccion		CHAR(1);
	DEFINE cAgent_cd			CHAR(3);
	DEFINE cIp_origen			CHAR(15);
	DEFINE cId_sesion_act		CHAR(30);
	DEFINE dtFecha_dia			DATE;
	DEFINE dFechaNueva 	 		CHAR(10);
	DEFINE cFecNac				CHAR(10);
	DEFINE cDia         		CHAR(2);
	DEFINE cMes         		CHAR(2);
	DEFINE cAnio        		CHAR(4);
	DEFINE cDiaNac				CHAR(2);
	DEFINE cMesNac              CHAR(2);
	DEFINE cAnioNac             CHAR(4);
	DEFINE CCLAVE 				CHAR(2);
	DEFINE cEntidadEmisora 		CHAR(2);
	DEFINE maxid				INTEGER;
	---INICIALIZACION DE VARIABLES
	LET cAgent_cd ='';
	LET CCLAVE='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET dFechaNueva   = DATE(1); --  01/01/1900
	LET cFecNac = DATE(1);
	LET cTipoTransaccion='6';
	LET cIpRenapo='201.158.207.46';
	LET cEntidadEmisora='30';
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCodigoError = 0;
	LET cErrorDescription = 'Consulta exitosa';
	LET cApellidoPaterno=pcApePat;
    LET cApellidoMaterno=pcApeMat;
	LET cNombre=pcNombre;
	LET cNumCelular='';
	LET cNumeroTarjeta='';
	LET cCurp=pcCurp;
	LET cFechaValidacionRenapo=CURRENT::DATE;
	LET cfechaNacimiento=date(1); --  01/01/1900
	LET cStatusRenapo=pcStatusCurp;
	LET	cDiaNac='';
	LET	cMesNac='';
	LET	cAnioNac='';
	LET	cDia='';
	LET	cMes='';
	LET	cAnio='';
	LET maxid=0;

--SET DEBUG FILE TO '/informix/andrescrespo/sp_guarda_renapo.out';
--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
       IF iSqlErr <> 0 THEN--manejador de errores
			if iSqlErr='-1204' then
			let cCodigoError='0';
			LET cErrorDescription = 'servicio no activo';
			else 			
			LET cCodigoError = iSqlErr;
			LET cErrorDescription = 'Error desconocido';
			end if;
			
			RETURN cCodigoError, trim(cErrorDescription),cApellidoPaterno, cApellidoMaterno, cNombre, cfechaNacimiento, cNumCelular, cNumeroTarjeta, cCurp, cFechaValidacionRenapo, cStatusRenapo;

        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;


			--IF pcFecNac is null OR pcFecNac='' THEN pcFecNac='01/01/1900';
			--END IF;
--or (pcCodigoError!='9996')
		IF (pcCodigoError)='9996' THEN
			LET cCodigoError="9996";
			LET cErrorDescription = "Parametro de entrada invalido.";

			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
		
		ELIF (pcCodigoError)='20' THEN
			LET cCodigoError="0";
			LET cErrorDescription = "Consulta Exitosa";
		
			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
		
		ELIF (pcCodigoError)='9975' THEN
			LET cCodigoError="9975";
			LET cErrorDescription = "Error id session";
		
			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
			

        ELIF (pcCodigoError::int!=0 or pcCodigoError!='')
			THEN
			LET cCodigoError ="9"||SUBSTR(pcCodigoError,1,2)||pcTipoError;
			LET cErrorDescription = TRIM(pcErrorDescripcion);

			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
		
		

		ELIF (pcCodigoError='' OR pcCodigoError::int=0) THEN
			--  01/01/1900
			LET cDiaNac=SUBSTR(pcFecNac,1,2);
			LET cMesNac=SUBSTR(pcFecNac,4,2);
			LET cAnioNac=SUBSTR(pcFecNac,7,4);
			LET cFecNac=mdy(cMesNac,cDiaNac,cAnioNac); --ddmmyyyy se necesita dmy para el wsdl renapo
			LET cfechaNacimiento=(cDiaNac||'/'||cMesNac||'/'||cAnioNac);

			select max(id)
			into maxid
			from "informix".tf_renapo;

			UPDATE "informix".tf_renapo set Nacionalidad=pcNacionalidad,Num_Registro_Extranjero=nvl(pcNumRegExtranjeros,''),CURP=pcCurp,cStatusRenapo=cStatusRenapo,fecha_validacion=cFechaValidacionRenapo
			where Apellido_paterno=trim(cApellidoPaterno) and Apellido_materno=trim(cApellidoMaterno) and Nombre=trim(cNombre) and Fecha_nacimiento=cFecNac and id=maxid;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

				IF EXISTS (SELECT telefono FROM "informix".tf_maecte
				WHERE empresa = '001' AND telefono = cNumCelular AND status_cta=1) THEN
						LET cCodigoError = '955';
						LET cErrorDescription = "Cliente Transfer existente con el mismo teléfono ingresado";
				END IF;
				
			LET cNumCelular='52'||cNumCelular;

			RETURN cCodigoError, trim(cErrorDescription),cApellidoPaterno, cApellidoMaterno, cNombre, cfechaNacimiento, cNumCelular, cNumeroTarjeta, cCurp, cFechaValidacionRenapo, cStatusRenapo;

		END IF;
	RETURN cCodigoError, trim(cErrorDescription),cApellidoPaterno, cApellidoMaterno, cNombre, cfechaNacimiento, cNumCelular, cNumeroTarjeta, cCurp, cFechaValidacionRenapo, cStatusRenapo;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Servicio OT que recibe datos de transfer y ejecuta un web service RENAPO para validar la curp. ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

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