CREATE PROCEDURE "informix".sp_domi_consultaarchivoorigenproveedor(pNum_Cliente CHAR(20))
	RETURNING CHAR(5),CHAR(20);


---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(5);
DEFINE cNombreArchivo    CHAR(20);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET cNombreArchivo = '';

--SET debug FILE TO "/tmp/Sp_Domi_ConsultaArchivoOrigenProveedor.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret,cNombreArchivo;
        END IF;
	END EXCEPTION;
	--validar si por lomenos existe un archivo para ese proveedor 
	IF EXISTS(SELECT nombre_arch FROM dom_cte_archivos WHERE num_cte = pNum_Cliente)THEN
		----OBTENER LOS ARCHIVOS PARA PROVEEDOR (POR  SU NUMERO DE CLIENTE)  
		FOREACH
			SELECT nombre_arch INTO cNombreArchivo FROM dom_cte_archivos WHERE num_cte = pNum_Cliente
			--retornar en nombre del archivo
			RETURN cCodRet,cNombreArchivo with resume;
		END FOREACH;
	ELSE		
		--SI NO PUES HO HAY ARCHIVOPS PARA ESE PROVEEDOR
		LET cCodRet = '99905';
		RETURN cCodRet,cNombreArchivo ;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Este procediento regresa los archivos origen de un determinado proveedor',
'FECHA : Agosto de 2009',
'BD    : BDIDOMI',
'VERSION: 20090810.0500';

CREATE PROCEDURE "informix".sp_domi_consultarcliente(pApell_Paterno CHAR(40),pApell_Materno CHAR(40),pRasonSocial CHAR(40))
	RETURNING CHAR(5),CHAR(20),CHAR(18),CHAR(200);

---- VARIABLES  GENERALES---
DEFINE  cSqlerr					INTEGER;
DEFINE  cCodret     			CHAR(5);
DEFINE  cNumCte					CHAR(20);
DEFINE  cRFC     				CHAR(18);
DEFINE  cNombreCte_RazonSocial	CHAR(200);
DEFINE  cConcatena	CHAR(40);

--VALORES INICIALES
LET cSqlerr 				= 0;
LET cCodret 				= '00000';
LET cNombreCte_RazonSocial 	= '';
LET cRFC 					= '';
LET cNumCte					= '';
LET cConcatena				= '';

--SET debug FILE TO "/tmp/sp_Domi_ConsultarCliente.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret,cNumCte,cRFC,cNombreCte_RazonSocial;
        END IF;
	END EXCEPTION;
	--validar que no esten los parametros en blanco
	IF TRIM(pApell_Paterno) = '' AND TRIM(pApell_Materno) = '' AND TRIM(pRasonSocial) = '' THEN
		--Los parametros estan en blanco
		LET cCodret = '99910';
		RETURN cCodret,cNumCte,cRFC,cNombreCte_RazonSocial;
	END IF;
	--Buscar por razon Social
	IF TRIM(pRasonSocial) <> "" THEN
		LET cConcatena = TRIM(pRasonSocial) || "%";
		FOREACH	
			SELECT numcte,razon_social,rfc INTO cNumCte,cNombreCte_RazonSocial,cRFC 
			FROM bdinteg:si_cliente WHERE razon_social LIKE cConcatena ORDER BY razon_social
			RETURN cCodret,cNumCte,cRFC,cNombreCte_RazonSocial WITH resume;
		END FOREACH;
	END IF;
	--Buscar por apellidos 
	--Si los dos apellidos bienen por parametro
	IF pApell_Paterno <> '' THEN
		FOREACH	
			SELECT numcte,TRIM(nombre1)|| ' ' || TRIM(nombre2 )|| ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno),rfc 
			INTO cNumCte,cNombreCte_RazonSocial,cRFC FROM bdinteg:si_cliente WHERE TRIM(apell_paterno) = TRIM(pApell_Paterno)
			AND TRIM(apell_materno) = TRIM(pApell_Materno) ORDER BY nombre1
			RETURN cCodret,cNumCte,cRFC,cNombreCte_RazonSocial WITH resume;
		END FOREACH;
	END IF;
	IF cNumCte IS NULL OR cNumCte = '' THEN
		--No existen registros con los parametros que se envian
		LET cCodret = '99911';
		RETURN cCodret,cNumCte,cRFC,cNombreCte_RazonSocial WITH resume;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Este procediento consulta la informacion del cliente, nombre, rfc, razon_social filtrado por apellidos o por razon social',
'FECHA : Agosto de 2009',
'BD    : BDIDOMI',
'VERSION: 20090811.1121';

CREATE PROCEDURE "informix".sp_domi_guardarccearchivos(p_Usuario CHAR(8), p_NomArchivo VARCHAR(20), p_FechaPres CHAR(8), p_CveStatus CHAR(2))

RETURNING

	CHAR(5); ---cod_ret

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescMensajeError	VARCHAR(95);
	DEFINE iTotReg				INTEGER;
	DEFINE sFechaAplicacion		CHAR(8);


	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET sDescMensajeError	= "";
	LET sFechaAplicacion	="";

	LET iTotReg				= 0;

BEGIN
	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_Domi_GuardarCCEArchivos.out";
	---TRACE ON;

	IF p_CveStatus <> "11" THEN
		IF p_CveStatus = "02" THEN
			SELECT num_operaciones::INTEGER 
			INTO iTotReg
			FROM bdidomi: dom_cce_sumario
			WHERE nombre_arch = p_NomArchivo;
			
			SELECT  LIMIT 1 SUBSTR(fecha_aplica,5,2)||SUBSTR(fecha_aplica,7,2)||SUBSTR(fecha_aplica,1,4)
			INTO sFechaAplicacion
			FROM bdidomi: dom_cce_detalle  
			WHERE nombre_arch = p_NomArchivo;
		ELSE
			SELECT num_operaciones::INTEGER 
			INTO iTotReg
			FROM bdidomi: dom_cce_sumario_paso 
			WHERE nombre_arch = p_NomArchivo;
			
			SELECT  LIMIT 1 SUBSTR(fecha_aplica,5,2)||SUBSTR(fecha_aplica,7,2)||SUBSTR(fecha_aplica,1,4)
			INTO sFechaAplicacion
			FROM bdidomi: dom_cce_detalle_paso
			WHERE nombre_arch = p_NomArchivo;
		END IF

		IF iTotReg IS NULL THEN
			LET iTotReg = 0;
		END IF

		IF NOT EXISTS(SELECT nombre_arch FROM bdidomi: dom_cce_archivos WHERE nombre_arch = p_NomArchivo   AND fecha_presentacion = p_FechaPres) THEN
			INSERT INTO bdidomi: dom_cce_archivos(nombre_arch,fecha_presentacion,fecha_aplicacion,cve_status,tot_registros,user_insert,fecha_insert)
			VALUES (p_NomArchivo,p_FechaPres,sFechaAplicacion,p_CveStatus,iTotReg,p_Usuario,CURRENT);
		ELSE
			UPDATE bdidomi: dom_cce_archivos
			SET cve_status = p_CveStatus, fecha_aplicacion = sFechaAplicacion, user_insert = p_Usuario, tot_registros = iTotReg
			WHERE nombre_arch = p_NomArchivo   AND fecha_presentacion = p_FechaPres;
		END IF
	END IF

	RETURN v_cod_ret;

END;

--##############################################################################
--## Procedimiento   : sp_Domi_GuardarCCEArchivos
--## Version         : 1.0
--## Creado por      : Mohamed Carreón 
--## Fecha creacion  : Agosto de 2009
--##Descripcion :  
--##############################################################################
END PROCEDURE;