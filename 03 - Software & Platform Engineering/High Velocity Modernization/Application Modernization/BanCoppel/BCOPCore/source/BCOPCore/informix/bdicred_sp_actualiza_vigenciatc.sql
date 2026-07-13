CREATE PROCEDURE "informix".sp_actualiza_vigenciatc() 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cCod_ret		CHAR(6);

DEFINE	vlnum_credito	CHAR(20);
DEFINE	vlFechaExpira	DATE;
DEFINE vlNumTarjeta		CHAR(20);

------------------------------------------------

------------------------------------------------

--SET DEBUG FILE TO '/temp/vigencia.out';
--TRACE ON;

    LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
--		insert into bdicobranza:cb_bitacora (mensaje) values( vlnum_credito);
            LET cCod_ret = sql_err;            
            RETURN cCod_ret;
        END EXCEPTION;

		set isolation to dirty read;
		SET LOCK MODE TO WAIT 3;						
				
		foreach with hold   
		  select num_credito, expiracion, num_tarjeta		         
             into 	vlnum_credito, vlFechaExpira,vlNumTarjeta
		  from "informix".sd_tarjeta
		  where empresa = '001'		    
		    and status_tar ='A'
		 	 
		 LET vlFechaExpira = date(mdy(month(vlFechaExpira), '01',year(vlFechaExpira))  + 1 units month) - 1;
		 
		 BEGIN WORK;
		  UPDATE "informix".sd_tarjeta
		    SET expiracion =vlFechaExpira						   
		where empresa = '001'
		 and num_credito = vlnum_credito
		 and num_tarjeta = vlNumTarjeta;
		COMMIT WORK;
		
		END Foreach;		
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se actualiza la vigencia de la TC',
'AUTOR : Faviola Martínez Juárez',
'FECHA : Enero 2012',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".sp_consultaempleadocancelarcredito(pEmpresa CHAR(3), pNum_empleado CHAR(20), pAplicativo CHAR(20))
	RETURNING
		CHAR(6)		AS CODRET,
		CHAR(65) 	AS MENSAJE_EJECUCION,
		CHAR(20) 	AS EMPLEADO,
		CHAR(45) 	AS NOMBRE_EMPLEADO,
		CHAR(3) 	AS PUESTO,
		SMALLINT 	AS STATUS,
		CHAR(20) 	AS APLICATIVO;

	--DECLARACION DE VARIABLES.
	DEFINE cCodRet 			CHAR(6);
	DEFINE cMensaje			CHAR(65);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iNRows 			INTEGER;
	DEFINE cEmpleado 		CHAR(20);
	DEFINE cNombreEmpleado 	CHAR(45);
	DEFINE cPuesto 			CHAR(3);
	DEFINE sStatus 			SMALLINT;
	DEFINE cAplicativo 		CHAR(20);

	--INICIALIZACION DE VARIABLES.
	LET cCodRet 			= '000000';
	LET cMensaje 			= 'CONSULTA REALIZADA EXITOSAMENTE';
	LET iSqlErr          	= 0;
	LET iNRows          	= 0;
	LET cEmpleado 			= '';
	LET cNombreEmpleado 	= '';
	LET cPuesto 			= '';
	LET sStatus 			= 0;
	LET cAplicativo 		= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'ERROR NO CONTROLADO';
				RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(NVL(cEmpleado, '')), TRIM(NVL(cNombreEmpleado, '')),
					   TRIM(NVL(cPuesto, '')), NVL(sStatus, 0), TRIM(NVL(cAplicativo, ''));
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/home/sysifx/SPsPAYAN/sp_consultaempleadocancelarcredito.out";
		--TRACE ON;	 

		IF NVL(pEmpresa, '') = '' AND NVL(pNum_empleado, '') = '' AND NVL(pAplicativo, '') = ''THEN
		    LET cCodRet  = '000001'; -- FALTA PROPORCIONAR AL MENOS UN PARAMETRO.
		    LET cMensaje = 'NO SE ENVIO NINGUN PARAMETRO PARA REALIZAR LA CONSULTA';			                
			RETURN cCodRet, TRIM(cMensaje), TRIM(cEmpleado), TRIM(cNombreEmpleado),
				   TRIM(cPuesto), sStatus, TRIM(cAplicativo);
		END IF;

		--SI VIENEN NULL UN PARAMETRO SE COMVIERTE HA VACIO.
		IF pEmpresa IS NULL THEN
		   LET pEmpresa = '';
		END IF;

		IF pNum_empleado IS NULL THEN
			LET pNum_empleado = '';
		END IF;

		IF pAplicativo IS NULL THEN
			LET pAplicativo = '';
		END IF;

		FOREACH
			-- OBTENGO LAS CARACTERISTICAS DEL EMPLEADO CON PERMISO PARA CANCELAR CREDITOS.
			SELECT TRIM(empleado), TRIM(nombre_empleado), TRIM(puesto), status, TRIM(aplicativo)
			  INTO cEmpleado, cNombreEmpleado, cPuesto, sStatus, cAplicativo
			  FROM bdicred:'informix'.sd_super_cancred
			 WHERE empresa 	  = (CASE WHEN pEmpresa 	 = '' THEN empresa 	  ELSE pEmpresa 	 END)
			   AND empleado   = (CASE WHEN pNum_empleado = '' THEN empleado   ELSE pNum_empleado END)
			   AND aplicativo = (CASE WHEN pAplicativo 	 = '' THEN aplicativo ELSE UPPER(pAplicativo) 	 END)
			   AND status = 1
			   ORDER BY empleado

			-- SE RETORNA CADA REGISTRO;
			RETURN cCodRet, TRIM(cMensaje), TRIM(cEmpleado), TRIM(cNombreEmpleado), TRIM(cPuesto), sStatus, TRIM(cAplicativo) WITH RESUME;

		END FOREACH;

		-- SE VALIDA QUE REGRESE INFORMACION EL PROCEDIMIENTO.
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		IF iNRows = 0 THEN
			LET cCodRet = '000002'; -- NO SE OBTUVO INFORMACION.
			LET cMensaje = 'NO SE ENCONTRO INFORMACION PARA LOS PARAMETROS RECIBIDOS';
			RETURN cCodRet, TRIM(cMensaje), TRIM(NVL(cEmpleado, '')), TRIM(NVL(cNombreEmpleado, '')), TRIM(NVL(cPuesto, '')),
				   NVL(sStatus, 0), TRIM(NVL(cAplicativo, ''));
		END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que consulta las caracteristicas de un empleado con permisos para cancelar créditos.',
'AUTOR: Guadalupe Payan',
'FECHA DE CREACION: 15 de Noviembre del 2011',
'VERSION: 20111115.1921',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_consultamotivosnocancelacioncredito (pEmpresa CHAR(3), pCodigo CHAR(3))

RETURNING
        CHAR(6)  AS RETORNO,
		CHAR(60) AS MENSAJE,
        CHAR(3)  AS ESTATUS,
        CHAR(60) AS DESCRIPCION;
    
  --DECLARACION DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE iNRows               INTEGER;
    DEFINE cCodRet              CHAR(6);
    DEFINE cCodigoNoCancel      CHAR(3);
    DEFINE cDescripcion         CHAR(60);
    DEFINE cMensaje             CHAR(60);
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
  --INICIALIZAR VARIABLES
	LET iSqlErr 			= 0;
	LET iNRows  			= 0;
    LET cCodRet 		  	= '000000';
    LET cCodigoNoCancel	    = '';
    LET cDescripcion		= '';
    LET cMensaje			= 'CONSULTA REALIZADA EXITOSAMENTE';
    
    -- SET DEBUG FILE TO "/home/sysifx/vlv/sp_consultamotivosnocancelacioncredito.out";
	-- TRACE ON;
    
BEGIN
	 -- CREA EL CONTROL DE ERRORES
        ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'ERROR NO CONTROLADO';
				RETURN cCodRet, TRIM(cMensaje), TRIM(NVL(cCodigoNoCancel, '')), TRIM(NVL(cDescripcion, ''));
			END IF;
		END EXCEPTION;        
	
	IF NVL(pEmpresa, '') = '' AND NVL(pCodigo, '') = '' THEN
		LET cCodRet = '000001'; -- FALTAN PARAMETROS PARA SU EJECUCION.
		LET cCodigoNoCancel = '';
		LET cMensaje = 'DEBE DE ENVIAR POR LO MENOS UNO DE LOS PARAMETROS';
		RETURN cCodRet, TRIM(cMensaje), TRIM(cCodigoNoCancel), TRIM(cDescripcion);
	END IF

	FOREACH 
	
	 -- SE REALIZA CONSULTA DEL CATALOGO DE MOTIVOS DE NO CANCELACION
		SELECT codigo, descripcion
		INTO cCodigoNoCancel, cDescripcion
		FROM bdicred: "informix".sd_cat_nocancred
		WHERE empresa = DECODE(pEmpresa, '', empresa, pEmpresa)
		AND codigo    = DECODE(pCodigo, '', codigo, pCodigo)
		
		RETURN cCodRet, TRIM(cMensaje), TRIM(cCodigoNoCancel), TRIM(cDescripcion) WITH RESUME;
	
	END FOREACH
	
  --SE VALIDA QUE REGRESE INFORMACION EL PROCEDIMIENTO.
	LET iNRows = dbinfo("sqlca.sqlerrd2");
	IF iNRows = 0 THEN
		LET cCodRet = '000002'; -- NO SE OBTUVO INFORMACION.
		LET cMensaje = 'NO SE ENCONTRARON REGISTROS';
		RETURN cCodRet, TRIM(cMensaje), TRIM(NVL(cCodigoNoCancel, '')), TRIM(NVL(cDescripcion, ''));
	END IF;	
END
END PROCEDURE
DOCUMENT
'CREACION     : VALENTIN LÓPEZ VALENZUELA',
'DESCRIPCION: Procedimiento que consulta los diversos estatus a los que son sometidos los créditos', 
'FECHA DE MODIFICACIÓN: 22 de Noviembre del 2011',
'VERSION: 20111122.1726',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_parametroscredito (pEmpresa CHAR(3), pNumEmpleado CHAR(8))

RETURNING
        CHAR( 5) AS RETORNO,            -- CODIGO DE RETORNO
        CHAR( 2) AS LONGITUDCLIENTE,    -- LONGITUD DEL CLIENTE
        CHAR( 2) AS CODMONNAC,          -- CODIGO DE LA MONEDA NACIONAL
       CHAR(100) AS CODPATHREP,         -- VALOR PATH DEL REPORTE
        CHAR(45) AS NOMUSUARIO,         -- NOMBRE DEL USUARIO
        CHAR(30) AS NOMEMPRESA,         -- NOMBRE DE LA EMPRESA   
            DATE AS FECHAHOY,           -- FECHA HOY
        CHAR( 2) AS SISTEMA,            -- CODIGO DEL SISTEMA
        CHAR(11) AS LONGITUDCTA,        -- LONGITUD DE LA CUENTA
            DATE AS FECHAANT,           -- FECHA ANTERIOR
            DATE AS PROXFECHA,          -- FECHA PROXIMA
            DATE AS PRIDIAMES,          -- PRIMER DIA DEL MES
            DATE AS PRIMHABMES,         -- PRIMER DIA HABIL MES
            DATE AS ULTDIAMES,          -- ULTIMO DIA DEL MES
            DATE AS ULTHABMES;          -- ULTIMO DIA HABIL DEL MES
    
  --DECLARACION DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE cLongitudCliente     CHAR(2);
    DEFINE cCodMonNac           CHAR(2);
    DEFINE cPathRep             CHAR(100);
    DEFINE cNombreUsuario       CHAR(45);
    DEFINE cNombreEmpresa       CHAR(30);
    DEFINE dFecha_Hoy           DATE;
    DEFINE cSistema             CHAR(2);
    DEFINE cLongCta             CHAR(11);
    DEFINE dFecha_ant           DATE;
    DEFINE dProx_fecha          DATE;
    DEFINE dPri_dia_mes         DATE;
    DEFINE dPri_hab_mes         DATE;
    DEFINE dUlt_dia_mes         DATE;
    DEFINE dUlt_hab_mes         DATE;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
  --INICIALIZAR VARIABLES
    LET cCodRet 		  	= '00000';
    LET cLongitudCliente	= '';
    LET cCodMonNac			= '';
    LET cPathRep			= '';
    LET cNombreUsuario		= '';
    LET cNombreEmpresa 		= '';
    LET dFecha_Hoy 			= DATE(1);
    LET cSistema 			= '';
    LET cLongCta			= '';
    LET dFecha_ant			= DATE(1);
    LET dProx_fecha 		= DATE(1);
    LET dPri_dia_mes		= DATE(1);
    LET dPri_hab_mes		= DATE(1);
    LET dUlt_dia_mes		= DATE(1);
    LET dUlt_hab_mes		= DATE(1);
    
    --SET DEBUG FILE TO "/home/sysifx/vlv/sp_parametroscredito.out";
	--TRACE ON;
    
BEGIN
	  --CREA EL CONTROL DE ERRORES
        ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN TRIM(cCodRet), TRIM(NVL(cLongitudCliente, '')), TRIM(NVL(cCodMonNac, '')), TRIM(NVL(cPathRep, '')), 
					   TRIM(NVL(cNombreUsuario, '')), TRIM(NVL(cNombreEmpresa, '')), NVL(dFecha_Hoy, DATE(1)), 
					   TRIM(NVL(cSistema, '')), cLongCta, NVL(dFecha_ant, DATE(1)), NVL(dProx_fecha, DATE(1)), 
					   NVL(dPri_dia_mes, DATE(1)), NVL(dPri_hab_mes, DATE(1)), NVL(dUlt_dia_mes, DATE(1)), NVL(dUlt_hab_mes, DATE(1));
			END IF;
		END EXCEPTION;        
	
	IF pEmpresa = '' AND pNumEmpleado = '' THEN
		LET cCodRet = '00001'; -- FALTAN PARAMETROS PARA SU EJECUCION.
		RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
			   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, 
			   dUlt_hab_mes;
	END IF
	
    -- OBTENGO EL VALOR LONGITUD DEL NUMERO DE CLIENTE		
	SELECT TRIM(valor)
	INTO cLongitudCliente 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 
	
	IF cLongitudCliente IS NULL THEN
		LET cLongitudCliente = '';
	END IF
	
    -- OBTENGO EL VALOR CODIGO DE LA MONEDA NACIONAL
	SELECT TRIM(valor)
	INTO cCodMonNac 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('codigo mn');
	
	IF cCodMonNac IS NULL THEN
	   LET cCodMonNac = '';
	END IF
	
    -- OBTENGO EL VALOR PATH DE REPORTES
	SELECT NVL(TRIM(valor), '')
    INTO cPathRep
	FROM bdicred:"informix".sd_param 
	WHERE empresa = pEmpresa AND cod_param = '50';
	
	IF cPathRep IS NULL THEN
  	   LET cPathRep = '';
	END IF
	
	-- OBTENGO EL NOMBRE DEL USUARIO O EJECUTIVO
	SELECT NVL(nombre, '')
	INTO cNombreUsuario
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	
	IF cNombreUsuario IS NULL THEN
	   LET cNombreUsuario = '';
	END IF
	
    -- OBTENGO EL NOMBRE DE LA EMPRESA
	SELECT NVL(razon_social, '')
	INTO cNombreEmpresa
	FROM bdinteg:"informix".si_empresas 
	WHERE empresa = pEmpresa;
	
	IF cNombreEmpresa IS NULL THEN
		LET cNombreEmpresa = '';
	END IF
    
	-- OBTIENE EL VALOR DE LA LONGITUD DE LA CUENTA.
	SELECT TRIM(NVL(valor, ''))
	INTO cLongCta
	FROM bdicred:"informix".sd_param 
	WHERE cod_param = '8';
	
	IF cLongCta IS NULL THEN
		LET cLongCta = '';
	END IF
	
    -- OBTENGO FECHA DE CREDITO PARA LA CAPTURA DE PARAMETROS
	SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes  
	INTO dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes
	FROM bdicred:"informix".sd_fechas;
	
	IF dFecha_Hoy IS NULL THEN
		LET dFecha_Hoy   = DATE(1);
		LET dFecha_ant   = DATE(1);
		LET dProx_fecha  = DATE(1);
		LET dPri_dia_mes = DATE(1);
		LET dPri_hab_mes = DATE(1);
		LET dUlt_dia_mes = DATE(1);
		LET dUlt_hab_mes = DATE(1);
	END IF
	
    -- OBTENGO CODIGO DEL SISTEMA
	SELECT TRIM(NVL(sistema, ''))
	INTO cSistema
	FROM bdinteg:"informix".si_sistema 
	WHERE siglas = 'SD';
	
	IF cSistema IS NULL THEN
		LET cSistema = '';
	END IF
	
	RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
		   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes,
		   dUlt_hab_mes;	
END
END PROCEDURE
DOCUMENT
'CREACION     : VALENTIN LÓPEZ VALENZUELA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL FUNCIONAMIENTO DEL MODULO DE CREDITO CON REGLAS DE PROGRAMACION',
'FECHA    	  : NOVIEMBRE 2010',
'BASE DE DATOS: BDICRED',
'VERSION  	  : 20111130.1529';

CREATE PROCEDURE "informix".sp_obtienetpoproducto()
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(7)  AS NumeroProd,
			CHAR(40) AS DescripcionProd;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cNumProducto		CHAR(7);
DEFINE cDescProducto	CHAR(40);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cNumProducto			= '';
LET cDescProducto			= '';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto);
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/sp_obtienetpoproducto.out';
--TRACE ON;

	FOREACH
	
		SELECT abrevia_prod, descrip_prod
		INTO cNumProducto, cDescProducto
		FROM bdicred:"informix".sd_tipprod
		ORDER BY abrevia_prod
		
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto) WITH RESUME;
		
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto);
    END IF;
	
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Obtiene los productos de crédito y su descripción ',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 01/Dic/2011',
'BD    : BDICRED',
'Version: 20111201.1614';

CREATE PROCEDURE "informix".updtraspcred800(fecha_inicial date)
     RETURNING CHAR(5);

--// ***************************************************************************
--// Actualiza registros de transparencia
--// ***************************************************************************

--//Definicion de variables
--DEFINE cVarDataErr      CHAR(100);
DEFINE vchrcodret 	CHAR(5);
DEFINE vintcodret	INTEGER;
DEFINE vcuantos 	INTEGER;
DEFINE vactualizados 	INTEGER;
DEFINE vleidos   	INTEGER;
DEFINE vreferencia	CHAR(30);
DEFINE vchrfolio        CHAR(16);
DEFINE vfolio           CHAR(16);
DEFINE vtransaccion     CHAR(4);
DEFINE vusuario         CHAR(4);
DEFINE vchrtransuc      CHAR(4);
DEFINE vsucursal        CHAR(4);
DEFINE vdivisa          CHAR(2);
DEFINE vhora            CHAR(15);
DEFINE vnum_credito          CHAR(20);
DEFINE vchrTarjeta      CHAR(16);
DEFINE vimporte_abono   MONEY(14,2);
DEFINE vempresa         CHAR(3);
--DEFINE v_codigo_fun     CHAR(3);
--DEFINE v_codigo_ref     INTEGER;

--LET cVarDataErr = '';
LET vchrTarjeta = '';
LET vnum_credito = '';

BEGIN
    ON EXCEPTION SET vintcodret
    	IF vintcodret <> 0 THEN
    	   LET vchrcodret = vintcodret;
           rollback work;
           RETURN vchrcodret;
    	END IF;
    END EXCEPTION;

    --//DEBUG FLAG
    --SET debug file to "/tmp/updtraspcred800.out";
    --TRACE ON;

    --//Inicializacion de variables
    LET vchrcodret = '000';
    LET vempresa = '001';
    LET vtransaccion = '6800';
    LET vactualizados = 0;
    LET vleidos = 0;

    set isolation to dirty read;
    truncate table temporalcred800;

--    SELECT codigo_fun, codigo_ref 
--      INTO v_codigo_fun, v_codigo_ref
--      FROM sd_transfun 
--     WHERE transacc  = vtransaccion;
    
       SELECT secuenciaextendida, numtarjeta, idterminal, 0 as status
         FROM intercard:movimiento 
        WHERE fechahorainauth >= fecha_inicial
          AND numtarjeta matches '426807*'
          AND prodind = '01' 
          AND codtran = '01' 
          AND monto > 0 
          AND movreversado = 'F' 
          AND codigoiso = '00'
       union all
       SELECT secuenciaextendida, numtarjeta, idterminal, 0 as status
         FROM intercard:movimientohistorico
        WHERE fechalocaltransaccion >= lpad(month(date(fecha_inicial)),2,0)||lpad(day(date(fecha_inicial)),2,0) 
          and fechahorainauth >= fecha_inicial
          AND numtarjeta matches '426807*'
          AND prodind = '01' 
          AND codtran = '01' 
          AND monto > 0 
          AND movreversado = 'F' 
          AND codigoiso = '00' into temp resol with no log;


     create index temp1 on resol(secuenciaextendida, numtarjeta, idterminal, status);
     update statistics medium for table resol;


     INSERT INTO temporalcred800
     select secuenciaextendida, numtarjeta, idterminal, status from resol
     group by 1,2,3,4;

     update statistics medium for table bdicred:temporalcred800;

        FOREACH WITH HOLD
        
        SELECT trim(folio),tarjeta, trim(refer)
          INTO vfolio, vchrTarjeta, vreferencia
          FROM temporalcred800 
         WHERE status = 0

	begin work;

        SELECT limit 1 num_credito 
          INTO vnum_credito
          FROM sd_tarjeta
         WHERE empresa = vempresa
           AND num_tarjeta = vchrTarjeta;

        LET vcuantos = 0;
        LET vchrfolio = 'i'||trim(vfolio);

	UPDATE bdicred:sd_movhisedocta SET referencia = trim(referencia)||' '||vreferencia
	 WHERE empresa = vempresa 
       AND num_credito = vnum_credito
	   AND codigo_fun = '002' AND codigo_ref in (30,40,41,42)
	   AND fecha_mov >= fecha_inicial 
	   AND reversado = "N"
       AND folio_suc = trim(vchrfolio);

        LET vcuantos = DBINFO("sqlca.sqlerrd2");

        IF vcuantos > 0 then
           UPDATE temporalcred800
              SET status = 1
            WHERE folio = vfolio
              AND tarjeta = vchrTarjeta
              AND refer = vreferencia;
           LET vactualizados = vactualizados + 1;
        END IF
        LET vleidos = vleidos + 1;
        commit work;
    END FOREACH

    --//Entrega el codigo de retorno 
--  RETURN vchrcodret, "Registros leidos: " ||vleidos, "Registros Actualizados: " ||vactualizados;
    RETURN vchrcodret;

END
END PROCEDURE;