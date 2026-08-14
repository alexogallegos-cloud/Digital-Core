CREATE PROCEDURE "informix".sp_cnsif_scoringsolic(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMSOL CHAR(20))

				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(80) AS Categoria,
						  CHAR(80) AS Respuesta,
						  DECIMAL(5,2) AS Puntuacion;
								

DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;
--CLIENTES VARIABLES
DEFINE cCategoria	   CHAR(80);
DEFINE cRespuesta	   CHAR(80);
DEFINE dPuntuacion	   DECIMAL(5,2);


--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;
LET cCategoria	 		= "";
LET cRespuesta 			= "";
LET dPuntuacion			=  0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion;
		END IF;
	END EXCEPTION;
	-- SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_scoringsolic.out";
	-- TRACE ON;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMSOL  = ''	THEN
		LET cCodRet = "00045";
		RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion;
	END IF;

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMSOL,'06','5')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cCategoria,cRespuesta,dPuntuacion;
	END IF;
	-- TERMINA VALIDACION

		SELECT NVL(COUNT(num_solicitud),0) into iexiste FROM bdisolic:ss_detalle_scoring WHERE num_solicitud  = cNUMSOL;
		IF iexiste  = 0 THEN
			LET cCodRet = "00071";
			RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion;
		END IF;
		set isolation to dirty read;
		FOREACH
			Select --+AVOID_FULL (bdisolic:"informix".ss_detalle_scoring) 
			trim(a.descripcion) as CATEGORIA, trim(c.descripcion) as respuesta, nvl(b.valor,0) as valor
			INTO cCategoria,cRespuesta,dPuntuacion
			From bdisolic:ss_scoring_grupo a, bdisolic:ss_detalle_scoring b, bdisolic:ss_scoring_element c
			Where a.empresa = '001'
			and a.empresa = c.empresa
			and a.empresa = b.empresa
			and a.seccion = '2'
			and a.seccion = b.seccion
			and a.grupo = b.grupo
			and b.tpo_persona='01'
			and b.num_solicitud = cNUMSOL
			and a.seccion = c.seccion
			and a.grupo = c.grupo
			and b.elemento = c.elemento
			and b.tpo_persona = c.tpo_persona
			order by b.seccion, b.grupo, b.elemento

			RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion WITH RESUME;

		END FOREACH;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del Scoring para las Solicitudes de Crédito. El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Solicitud",
"FECHA : 10-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_sitespecial(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cNUMCUENTA CHAR(20),cTIPOBUSQUEDA CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)
            
			RETURNING   CHAR(5)  AS Cod_Retorno,
						CHAR(1)  AS Tipo_Movimiento,
						CHAR(20) AS Movimiento,
						CHAR(1)  AS Cve_Situacion,
						SMALLINT AS Cve_Causa,
						CHAR(75) AS Desc_Situacion_Especial,
						CHAR(12) AS Cve_Situacion_Origen, 
						CHAR(20) AS Situacion_Origen,
						CHAR(4)  AS Sucursal,
						CHAR(8)  AS Numero_Ejecutivo,
						CHAR(45) AS Nombre_Ejecutivo,
						CHAR(8)  AS Usuario_Alta,
						DATETIME YEAR TO SECOND AS Fecha_Alta,
						CHAR(8)  AS Usuario_Modifica,
						DATETIME YEAR TO SECOND AS Fecha_Modifica;
											

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;

-- SEGUN LAYOUT DE SALIDA 
DEFINE cTipoMovimiento   CHAR(1);
DEFINE cMovimiento       CHAR(20);
DEFINE cClaveSituacion   CHAR(1);
DEFINE smallCveCausa     SMALLINT;
DEFINE cDescSitEspecial  CHAR(75);
DEFINE cCveSitOrigen     CHAR(12);
DEFINE cSituacionOrigen  CHAR(20);
DEFINE cSucursal         CHAR(4);
DEFINE cNoEjecutivo      CHAR(8);
DEFINE cNombreEjecutivo  CHAR(45);   
DEFINE cUsuarioAlta      CHAR(8);
DEFINE dFechaAlta        DATETIME YEAR TO SECOND;
DEFINE cUsuarioModifica  CHAR(8);
DEFINE dFechaModifica    DATETIME YEAR TO SECOND;

--VARIABLES DE PAGINACION
DEFINE iCont            INT;

--INICIALIZACION DE VARIABLES
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0;
LET iCont            = 0;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
LET cTipoMovimiento    = " ";
LET cMovimiento        = 0;
LET cClaveSituacion    = " ";
LET smallCveCausa      = " ";        
LET cDescSitEspecial   = " ";  
LET cCveSitOrigen      = " ";
LET cSituacionOrigen   = " ";
LET cSucursal          = " ";
LET cNoEjecutivo       = " ";
LET cNombreEjecutivo   = " ";
LET cUsuarioAlta       = 0;
LET dFechaAlta         = " ";
LET cUsuarioModifica   = " ";
LET dFechaModifica     = " "; 


--VARIABLES DE PAGINACION
LET iCont               = 0;
   
BEGIN
   ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;					
		END IF;
	END EXCEPTION;	

	  --    SET debug FILE TO "/tmp/CNSIF/sp_cnsif_sitespecial.out";
	  --    TRACE ON;
-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  cID_USUARIOC = '' OR
	    cID_FUNCIONC ='' THEN
       LET cCodRet = "00045";
       RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
    END IF;
	
    IF cTIPOBUSQUEDA='1' THEN
        IF cNUMCLIENTE = '' THEN
           LET cCodRet = "00045";
           RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
        END IF;
    ELSE
        IF cNUMCUENTA = '' THEN
           LET cCodRet = "00045";
           RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
        END IF;
    END IF;
	IF cTIPOBUSQUEDA <> '1' AND cTIPOBUSQUEDA <> '2' THEN 
		LET cCodRet = "00049";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
                   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
        END IF;
    END IF;   
	
    IF cTIPOBUSQUEDA = '1' THEN
		SELECT NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE empresa = '001' AND  numcte = cNUMCLIENTE; 
		IF iexiste  = 0 THEN 
		LET cCodRet = "00050";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	 
	--VALIDACION 
	IF cTIPOBUSQUEDA = '1' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'06','2')
		INTO
		cCodRet;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO
		cCodRet;
	END IF
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;					
	END IF;
	-- TERMINA VALIDACION	

	-- ****************************************************************************
	-- obtener registros
	-- ****************************************************************************

        FOREACH
			SELECT LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
			FROM bdisitesp:se_ctessitespcte
            WHERE numcte = cNUMCLIENTE
            UNION
			SELECT NVL(COUNT(*),0) AS CONT
			FROM bdisitesp:se_ctessitespcte_his 
			WHERE numcte = cNUMCLIENTE ORDER BY CONT DESC
       END FOREACH;     

		IF iexiste  = 0 THEN 
		LET cCodRet = "00100";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;

		SET ISOLATION TO DIRTY READ;

		FOREACH

			SELECT SKIP pNumRegistro FIRST pRecuperacion  
			   a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   WHEN a.tipomovto = 'E' THEN 
				'ELIMINACION'
			   ELSE 
				' '
			   END AS tipo_movimiento,a.situacion,a.causa,b.descripcion,a.cvesitesporigen,csit.descripcion,
			        a.empleadoefectuo ,	a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica
			INTO    cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cNoEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica
			FROM bdisitesp:se_ctessitespcte a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcte = cNUMCLIENTE
		UNION
			SELECT --+AVOID_FULL(bdisitesp:"informix".se_sitesporigen)
			a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   WHEN a.tipomovto = 'E' THEN 
				'ELIMINACION'
			   ELSE 
				' '
			   END AS tipo_movimiento,a.situacion,a.causa,b.descripcion,cast(a.cvesitesporigen as char(2)),csit.descripcion,
			       NVL(a.empleadoefectuo,''), a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica 
			FROM bdisitesp:se_ctessitespcte_his a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcte = cNUMCLIENTE
			
			--para sacar el nombre del usuario
			IF cNoEjecutivo <> '' THEN
				SELECT nombre
				INTO
				cNombreEjecutivo
				FROM si_ejecut
				WHERE ejecutivo = cNoEjecutivo;
			END IF;

			
			IF cCodRet = '000' THEN
				LET cCodRet = '00000';
			END IF

			LET iCont = iCont +1;
						  
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica  WITH resume;

		END FOREACH;
		
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
	    END IF;
		
	ELIF cTIPOBUSQUEDA = '2' THEN
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CANT INTO iexiste FROM bdicred:sd_maecred WHERE empresa = '001' AND  num_credito = cNUMCUENTA 
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CANT FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND  num_credito = cNUMCUENTA ORDER BY CANT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
		LET cCodRet = "00046";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	 
        FOREACH
			SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
			LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
			FROM bdisitesp:se_ctessitespcred
            WHERE numcred =  cNUMCUENTA
			AND empresa = '001'
            UNION
			SELECT NVL(COUNT(*),0) AS CONT
			FROM bdisitesp:se_ctessitespcred_his 
			WHERE numcred =  cNUMCUENTA ORDER BY CONT DESC
       END FOREACH;     

		IF iexiste  = 0 THEN 
		LET cCodRet = "00090";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	-- ****************************************************************************
	-- obtener registros
	-- ****************************************************************************

		SET ISOLATION TO DIRTY READ;

		FOREACH

			SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
			SKIP pNumRegistro FIRST pRecuperacion  
			a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   WHEN a.tipomovto = 'E' THEN 
				'ELIMINACION'
			   ELSE 
				' '
			   END AS tipo_movimiento,
			   a.situacion,a.causa,b.descripcion,a.cvesitesporigen,csit.descripcion,a.sucursal,
			   a.nombreefectuo,a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica
			INTO    
			   cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,cSucursal,
			   cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica
			FROM bdisitesp:se_ctessitespcred a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcred =  cNUMCUENTA
		UNION
			SELECT --+AVOID_FULL(bdisitesp:"informix".se_sitesporigen)
			a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   ELSE 
				'ELIMINACION'
			   END AS tipo_movimiento,
			   a.situacion,a.causa,b.descripcion,cast(a.cvesitesporigen as char(2)),csit.descripcion,a.sucursal,
			   a.nombreefectuo,a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica 
			FROM bdisitesp:se_ctessitespcred_his a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcred = cNUMCUENTA
			
			
			IF cCodRet = '000' THEN
				LET cCodRet = '00000';
			END IF

			LET iCont = iCont +1;
						  
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica  WITH resume;

		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			        cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	END IF	
	


END    
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las Situaciones Especiales que presente un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Cliente.",
"FECHA : 28-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cons_conc_efect_aud( pTipo     INTEGER,
													pFechaIni CHAR(10),
													pFechaFin CHAR(10),
													pEmpresa  CHAR(3),
													pSucursal CHAR(4),
													pCodigo   CHAR(4),
													pUsuario  CHAR(8),
													pSkip     INTEGER,
													pLimite   INTEGER)
RETURNING CHAR(5)   AS  CodRet,
		  CHAR(10)	AS	Fecha,
		  CHAR(12)  AS 	Hora,
		  CHAR(16)  AS  Folio,
		  CHAR(8)	AS	Usuario,
		  CHAR(4)   AS	Sucursal,
		  CHAR(17)  AS  Importe,
		  CHAR(4)	AS	Transaccion,
		  CHAR(17)  AS	Folio_Papeleta,
		  INTEGER   AS  TotRows;
			  			  
DEFINE cCodRet				CHAR(5);
DEFINE cFecha               CHAR(10);
DEFINE cHora                CHAR(12);
DEFINE cFolio               CHAR(16);
DEFINE cUsuario             CHAR(8);
DEFINE cSucursal            CHAR(4);
DEFINE cImporte             CHAR(17);
DEFINE cTransaccion         CHAR(4);
DEFINE cFolio_Pap           CHAR(10);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iRango 		     	INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE iSqlErr              INTEGER;
DEFINE iLinea               INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE dFecha               DATE;
DEFINE dFechaActual			DATE;


LET cCodRet              = '';
LET cFecha               = '';
LET cHora                = '';
LET cFolio               = '';
LET cUsuario             = '';
LET cSucursal            = '';
LET cImporte             = '';
LET cTransaccion         = '';
LET cFolio_Pap           = '';
LET dFechaIni 			 = '';
LET dFechaFin 			 = '';
LET dFechaHoy 			 = '';
LET dFechaParaMovhisOld  = '';
LET dFechaParaMovhisOld2 = '';
LET cFechaParaMovhisOld  = '';
LET cFechaParaMovhisOld2 = '';
LET iRango  			 = 0;
LET cFechaIni 			 = '';
LET cFechaFin 			 = '';
LET cDia 				 = '';
LET cMes 				 = '';
LET cAnio 				 = '';
LET iLinea               = 0;
LET iTotalRows 			 = 0;
LET dFecha               = DATE(1);
LET dFechaActual         = DATE(1);
 
/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Concentracion de Efectivo" desde la tabla si_rptcaja_aud                         /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 25/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

--SET DEBUG FILE TO '/informix/sp_cons_conc_efect_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cFecha        = '';
			LET cHora         = '';
			LET cFolio        = '';
			LET cUsuario      = '';
			LET cSucursal     = '';
			LET cImporte      = '';
			LET cTransaccion  = '';
			LET cFolio_Pap    = '';
			LET dFecha        = '';
			LET iTotalRows    = 0;
				
			RETURN  cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap,iTotalRows;
			
		END IF;
	END EXCEPTION;
		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
				LET cFechaIni = pFechaIni;
				LET cDia  = SUBSTRING(cFechaIni FROM 1 FOR 2);
				LET cMes  = SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaIni FROM 7 FOR 10);
				LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));

				LET cFechaFin = pFechaFin;
				LET cDia  = SUBSTRING(cFechaFin FROM 1 FOR 2);
				LET cMes  = SUBSTRING(SUBSTRING(cFechaFin FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaFin FROM 7 FOR 10);
				LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
				
				SELECT DISTINCT(COUNT(folio))
				INTO iTotalRows
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND  fecha BETWEEN 	dFechaIni AND dFechaFin
				AND reversado = '0';
				
			FOREACH
				SELECT SKIP pSkip LIMIT  pLimite  DISTINCT fecha,hora,folio,usuario,sucursal,monto,cod_transacc,folio_oper
				INTO cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN 	dFechaIni AND dFechaFin
				AND reversado = '0'
				ORDER BY fecha,hora ASC
				
				LET cCodRet = '00000';
				
				RETURN  cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap,iTotalRows WITH RESUME;         
			END FOREACH;
			
			LET pSkip = pSkip + pLimite ;

END

END PROCEDURE;