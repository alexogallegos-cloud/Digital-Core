CREATE PROCEDURE "informix".sp_cnsif_consultaperfil(cID_USUARIOC char(8),cID_FUNCIONC char(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
 
    RETURNING CHAR(5),CHAR(10),CHAR(100),CHAR(1);
													
	DEFINE iexiste 		INT;
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSql_err 	INT;
	DEFINE cId_perfil 	CHAR(10);
	DEFINE cD_perfil	CHAR(100);
	DEFINE cStatus		CHAR(1);
    DEFINE iCont        INTEGER;
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET	cId_perfil ="00";
	LET cD_perfil = "00";
	LET cStatus = "0";
    LET iCont=0;

	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaperfil.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
		END IF;

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
		END IF;
		
		SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles where id_perfil is not null;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
		END IF;
		set isolation to dirty read;
        FOREACH
			SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} SKIP pNumRegistro FIRST pRecuperacion Id_perfil, D_perfil,Status INTO cId_perfil,cD_perfil,cStatus FROM si_seg_perfiles 
            where id_perfil is not null order by 2

            LET iCont=iCont+1;

			RETURN cCodRet,cId_perfil,cD_perfil,cStatus with resume;
		END FOREACH;
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
        END IF 		
    END
END PROCEDURE	
DOCUMENT	
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este sp consultara y regresara los resultados de todos los perfiles creados dentro de la base", 
"FECHA : 23-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_consultaperfilfuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_PERFIL CHAR(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5),CHAR(10),CHAR(100),CHAR(6),CHAR(20),INTEGER,CHAR(60), CHAR(1),INTEGER, CHAR(1);
													
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cID_FUNCION			CHAR(10);
	DEFINE cD_FUNCION			CHAR(100);
	DEFINE cID_MODULO			CHAR(6);
	DEFINE cD_MODULO			CHAR(20);
	DEFINE iID_SUBMODULO		INTEGER;
	DEFINE cD_SUBMODULO			CHAR(60);
	DEFINE cSTATUS_FUNCION		CHAR(1);
	DEFINE iORDEN				INTEGER;
	DEFINE cSTATUS_FUNCIONP		CHAR(1);
	DEFINE iCont            INTEGER;
	
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET cID_FUNCION = " ";
	LET cD_FUNCION	= " ";
	LET cID_MODULO = " ";	
	LET cD_MODULO	= " ";	
	LET iID_SUBMODULO = 0	;
	LET cD_SUBMODULO =  " ";
	LET cSTATUS_FUNCION = " ";
	LET iORDEN	= 0;
	LET cSTATUS_FUNCIONP = " ";
    LET iCont=0;
	
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaperfilfuncion.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' 	OR
		cID_PERFIL = ''	THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
		END IF;		
	
        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
            END IF;
        END IF; 
	
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
		END IF;		
		
		SELECT {+INDEX (bdinteg:si_seg_perfiles_funciones idxidperfu)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles_funciones WHERE id_perfil= cID_PERFIL;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
		END IF;
		set isolation to dirty read;
		FOREACH
			SELECT {+INDEX (bdinteg:si_seg_perfiles_funciones idxidperfu)} SKIP pNumRegistro FIRST pRecuperacion PF.id_funcion, FU.d_funcion, FU.id_modulo,MO.d_modulo, FU.id_submodulo, SU.d_submodulo,  Fu.status, FU.orden,PF.status 
			INTO
			cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP
			FROM  si_seg_perfiles_funciones  PF
			LEFT JOIN si_seg_funciones FU
			ON PF.id_funcion  = FU.id_funcion 
			LEFT JOIN si_seg_modulos MO
			ON MO.id_modulo = FU.Id_modulo
			LEFT JOIN si_seg_submodulo SU
			ON SU.id_submodulo = FU.id_submodulo
			WHERE id_perfil= cID_PERFIL
            order by orden,id_submodulo

            LET iCont=iCont+1;
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP with resume;
		END FOREACH
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
        END IF 
    END
END PROCEDURE	
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP regresara el  perfil de funciones que se encuentra registrado en la base de la tabla si_seg_funciones", 
"dependiendo del Id_perfil que envie al SP, se regresaran datos como el id_funcion, la descripcion , el id_modulo, la descripcion del modulo,", 
"el id_submodulo, la descripcion del submodulo, el orden y el status ",
"FECHA : 26-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_detalleburo(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMSOL CHAR(20),cInstitucion CHAR(03))
							
				returning CHAR(5)   AS Cod_Retorno,
						  CHAR(255) AS Datos_Personales,
						  CHAR(257) AS Direccion,
						  CHAR(510) AS Tipo_Rechazo;
				
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cDatosPersonales	   CHAR(255);
DEFINE cDireccion	       CHAR(255);
DEFINE cTiporechazo	       CHAR(500);
--VARIABLE PARA CACHAR CAMPOS DEL PROCEDIMIENTO
DEFINE vCcod_Ret   CHAR(5);
DEFINE vMensaje1 CHAR(255);
DEFINE vMensaje2 CHAR(255);


--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	
LET cDatosPersonales	= "";
LET cDireccion 			= "";
LET cTiporechazo		= "";
LET vCcod_Ret	   = "00000";
LET vMensaje1		    = "";
LET vMensaje2		    = "";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_detalleburo_2.out";
	--TRACE ON;
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMSOL,'22','6')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
	END IF;
	-- TERMINA VALIDACION
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMSOL  = ''	THEN 
		LET cCodRet = "00059";
		RETURN
			cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
	END IF;	

		SELECT NVL(COUNT(num_solicitud),0) into iexiste FROM bdiburo:br_traslado WHERE num_solicitud  = cNUMSOL;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00073";
			RETURN 
			cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
		END IF;
		 
		select envio[89,250],'PA' || trim(envio1)
		INTO cDatosPersonales,cDireccion
		from bdiburo:br_traslado  
		Where  num_solicitud = cNUMSOL	
		AND    institucion   = cInstitucion;
		
		set isolation to dirty read;
		FOREACH
			execute procedure bdiburo:sp_consulta_error(cInstitucion,cNUMSOL)
			INTO vCcod_Ret,vMensaje1,vMensaje2 
		END FOREACH;
		
		IF LENGTH(vCcod_Ret) = 3 THEN
			LET  cCodRet = '00' || vCcod_Ret;
		ELIF LENGTH(vCcod_Ret) = 5 THEN
			LET  cCodRet = vCcod_Ret;
		END IF
		
		LET cTiporechazo = vMensaje1 || vMensaje2;
		
		RETURN 
		cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
			
		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del detalle de la Consulta al Buró de Crédito. El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el No. de Solicitud",
"FECHA : 13-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_empcli(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(3)  AS Cve_Empresa,
						  CHAR(60) AS Nombre,
						  CHAR(30) AS Puesto,
						  CHAR(02) AS Puesto_Especial,
						  DECIMAL(4,2) AS Antiguedad,
						  CHAR(40) AS Nombre_Departamento,
						  MONEY(14,2) AS Ingreso_Mensual;
									
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--CLIENTES VARIABLES
DEFINE cEmpresa		        CHAR(3);
DEFINE cNombre	           CHAR(60);
DEFINE cPuesto	           CHAR(30);
DEFINE cPuestoEsp		   CHAR(02);
DEFINE dAntiguedad	   DECIMAL(4,2);
DEFINE cNombreDepto		   CHAR(40);
DEFINE mIngresoMensual	MONEY(14,2);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	
LET cEmpresa	 		= "";
LET cNombre 			= "";
LET cPuesto				= "";
LET cPuestoEsp			= "";
LET dAntiguedad			=  0;
LET cNombreDepto		= "";
LET mIngresoMensual 	=  0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_empcli.out";
	--	TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCLIENTE  = ''	THEN 
		LET cCodRet = "00054";
		RETURN
			cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
	END IF;	
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'06','2')
	INTO
	cCodRet;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
	END IF;
	-- TERMINA VALIDACION		
/*
	SELECT NVL(COUNT(numcte),0) into iexiste FROM bdisolic:ss_solicitudes WHERE numcte  = cNUMCLIENTE;
	
	IF iexiste  = 0 THEN 
		LET cCodRet = "00022";
		RETURN 
		cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
	END IF;
*/		
	SELECT  LIMIT 1 nvl(ing.empresa,'') as Empresa,rpad(TRIM(nvl(ing.nombre_empresa,'')),25,' ') AS nombre_empresa, 
			rpad(TRIM(nvl(puest.descripcion,'')),30,' ') as puesto, nvl(puesto_esp,'') as puestoEsp,nvl(antiguedad,0) as antiguedad,
			nvl(nombre_depto,'') as nombreDepto,nvl(ing.ingreso_mensual, 0) AS ingresomensual
	INTO 		
	cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual		
	FROM  bdisolic:ss_solicitudes cte 
	LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.empresa=cte.empresa 
	AND ing.numcte = cte.numcte AND ing.sec_ingreso= (SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos ing1 
	WHERE ing1.empresa=cte.empresa AND ing1.numcte = cte.numcte)) 
	LEFT OUTER JOIN bdinteg:si_puestos  puest  ON (puest.puesto = ing.puesto) 
	WHERE cte.empresa= '001' AND cte.numcte= cNUMCLIENTE;
	
	RETURN 
	cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual ;

END

END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Datos del Empleo de un Cliente.  El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el No. de Cliente",
"FECHA : 10-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_maxedocta(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMEMPLEADO CHAR(20))

				returning CHAR(5)  AS Cod_Retorno,
						  INTEGER  AS Consulta;
								
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;
--CLIENTES VARIABLES
DEFINE iConsulta	   INTEGER;

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;
LET iConsulta	 		= 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,iConsulta;
		END IF;
	END EXCEPTION;
	
	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_maxedocta.out";
	--	TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMEMPLEADO  = ''	THEN
		LET cCodRet = "00036";
		RETURN
			cCodRet,iConsulta;
	END IF;
	
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

		IF cCodRet = '00028' THEN 
			RETURN cCodRet,iConsulta;
		END IF;			

	SET ISOLATION TO DIRTY READ;
	
	SELECT max(consulta)
	INTO iConsulta
	FROM bdicheq:vedocta
	WHERE empresa = '001'
	AND cod_usuario = cNUMEMPLEADO;

	RETURN
	cCodRet,iConsulta;

		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la consulta Máxima para ejecutar el SP de Movimiento al Detalle. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Empleado.",
"FECHA : 12-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_validaipmacejecutivo(cIDUSUARIO CHAR(8),cIP CHAR(16), cMAC CHAR(18))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(8)  AS Numero_Empleado,
						  CHAR(45) AS Nombre;
				
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
-- VARIABLES
DEFINE cNumeroEmpleado   	CHAR(8);
DEFINE cNombre	   		    CHAR(45);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	

LET cNumeroEmpleado	 	= "";
LET cNombre		        =  "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
	END EXCEPTION;
	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_validaipmacejecutivo.out";
	--	TRACE ON;
	IF 	cIDUSUARIO   = ''   OR
		cIP          = ''   OR
		cMAC         = '' THEN 
		LET cCodRet = "00003";
		RETURN
			cCodRet, cNumeroEmpleado, cNombre;
	END IF;	

		SELECT NVL(COUNT(ejecutivo),0) into iexiste FROM si_ejecut WHERE ejecutivo  = cIDUSUARIO;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00025";
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
		SELECT NVL(COUNT(mac),0) into iexiste FROM si_macejecutivo WHERE mac  = cMAC;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00026";
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
		SELECT NVL(COUNT(ipmaquina),0) into iexiste FROM si_sucursalesmaquina WHERE ipmaquina  = cIP;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00027";
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
		set isolation to dirty read;
		FOREACH 			
			SELECT si.ejecutivo,si.nombre
			INTO 
			cNumeroEmpleado, cNombre
			FROM si_ejecut si
			LEFT JOIN si_macejecutivo mac
			ON si.ejecutivo = mac.ejecutivo
			LEFT JOIN si_sucursalesmaquina sm
			ON mac.mac = sm.mac
			WHERE si.ejecutivo = cIDUSUARIO
			AND mac.mac = cMAC
			AND sm.ipmaquina = cIP
			
			
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre with resume;
			
		END FOREACH;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Realizar la validación de los Ejecutivos BanCoppel existentes en la Base de Datos central de Informix.",
"FECHA : 08-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_actualizastatususuario_bei(pEmpresa char(3), pNumCliente char(20), pUsuario char(50), 
pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
   returning char(5);

   --Modificó: Manuel Ramos Figueroa
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Fecha: 01-09-2011
--
   --Modificó: Ing. Alfonso Cruz
   --Actividad: INSERTA EL CAMBIO DEL ESTATUS DEL CLIENTE EN bdinteg:si_cambiostctepm
   --Fecha: 01-09-2011
   
   DEFINE cCod_ret char(5);
   DEFINE sql_err integer;
   DEFINE iStatus integer;

   LET cCod_ret       = "000";
   LET iStatus = "0";

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    IF pNumCliente <> "" THEN

        IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa AND num_cliente = pNumCliente ) THEN

			SELECT id_status INTO iStatus FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa and num_cliente = pNumCliente;
				
				
				INSERT INTO bdinteg:"informix".si_cambiostctepm (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  
				VALUES (pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);

				UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND num_cliente = pNumCliente;

				LET cCod_ret = '000';  -- Usuario bloqueado
        ELSE

            LET cCod_ret = '001';  -- No existe el Cliente
        END IF ;

    ELSE

        IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

			SELECT id_status INTO iStatus FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa and usuario = pUsuario;

				INSERT INTO bdinteg:"informix".si_cambiostctepm (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  
				VALUES (pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);

				 UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND usuario = pUsuario;

				LET cCod_ret = '000';  -- Usuario bloqueado
        ELSE

            LET cCod_ret = '002';  -- No existe el Usuario
        END IF ;
    END IF ;

    RETURN cCod_ret;

END

END PROCEDURE ;