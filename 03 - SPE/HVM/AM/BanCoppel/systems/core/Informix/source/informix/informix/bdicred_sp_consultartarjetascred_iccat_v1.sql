CREATE PROCEDURE "informix".sp_consultartarjetascred_iccat_v1(pNumCliente CHAR(9))
--DATOS A REGRESAR---
RETURNING CHAR(5),CHAR(20), CHAR(4), CHAR(40), CHAR(20),CHAR(1),CHAR(4),CHAR(100),CHAR(1),DATE,CHAR(3), CHAR(60);
--DEFINICION DE VARIABLES--
DEFINE  cCodRet    	CHAR(5);
DEFINE  cCodRetCred    	CHAR(5);
DEFINE cProducto 	CHAR(4);
DEFINE cNombreProducto 	CHAR(40);
DEFINE cNumCredito 	CHAR(20);
DEFINE cNumTarjeta 	CHAR(20);
DEFINE sEstatus    	CHAR(1);
DEFINE cFechaExp   	CHAR(4);
DEFINE cNomCompleto CHAR(100);
DEFINE cTitular    	CHAR(1);
DEFINE dFechaNacimiento DATE;
DEFINE cEstatusTarjeta CHAR(3);
DEFINE cDescripcion CHAR(60);
DEFINE  iSqlErr		INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 	= '00000';
LET cCodRetCred='00000';
LET cProducto = "";
LET cNombreProducto = "";
LET cNumCredito='';
LET cNumTarjeta='';
LET sEstatus='';
LET cFechaExp='';
LET cNomCompleto='';
LET cTitular='';
LET dFechaNacimiento='01-01-1900';
LET cEstatusTarjeta='';
LET cDescripcion = '';
LET iSqlErr		= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
	RETURN cCodRet,cNumCredito,cProducto,cNombreProducto,cNumTarjeta,NVL(sEstatus,''),NVL(cFechaExp,''),NVL(cNomCompleto,''),NVL(cTitular,''),NVL(dFechaNacimiento,'01-01-1900'),NVL(cEstatusTarjeta,''), cDescripcion;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/sp_consultartarjetascred_iccat.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_obtenercredito_iccat(pNumCliente)
	INTO cCodRetCred,cNumCredito,cNumTarjeta;
	
	IF cCodRetCred='000' THEN
			
		SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)} 
			def.num_producto, def.nombre_prod
			INTO cProducto, cNombreProducto
		FROM bdicred:'informix'.sd_maecred cta, bdicred:"informix".sd_definicion def
		WHERE  cta.numcte = pNumCliente and cta.num_credito = cNumCredito AND cta.num_producto = def.num_producto;

		--SE OBTIENE EL ESTATUS
		SELECT sdlp.indicador 
		INTO sEstatus
		FROM bdicred:"informix".sd_disminucion_linea_precan sdlp
		WHERE num_credito=cNumCredito;
		
		--SE OBTIENE FECHA EXPIRACION,TITULAR,NOMBRE Y FECHA NAC
		SELECT fechaexp,nombre,titular,fechanacimiento,codstatustarjeta 
		INTO cFechaExp,cNomCompleto,cTitular,dFechaNacimiento,cEstatusTarjeta
		FROM intercard:"informix".tarjeta 
		WHERE numtarjeta=cNumTarjeta;

		SELECT sdTipoC.descripcion
		INTO cDescripcion
		FROM BDICRED: "informix".sd_tipocartera sdTipoC, BDICRED: "informix".sd_maecred sdmaecred
		WHERE sdmaecred.num_credito  = cNumCredito
		AND sdmaecred.status_cred = sdTipoC.status_cred;
	
	ELSE
		LET cCodRet='00001';
	END IF;

	RETURN cCodRet,cNumCredito,cProducto,cNombreProducto,cNumTarjeta,NVL(sEstatus,''),NVL(cFechaExp,''),NVL(cNomCompleto,''),NVL(cTitular,''),NVL(dFechaNacimiento,'01-01-1900'),NVL(cEstatusTarjeta,''), cDescripcion;
END;
END PROCEDURE
;