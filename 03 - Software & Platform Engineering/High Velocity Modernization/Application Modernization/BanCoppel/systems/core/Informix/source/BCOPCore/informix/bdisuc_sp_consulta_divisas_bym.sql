CREATE PROCEDURE "informix".sp_consulta_divisas_bym(pEmpresa CHAR(3), pCodDivisa CHAR(2))
RETURNING   CHAR(6)  AS CodRet,
			CHAR(4)  AS Sigla,
			CHAR(3)  AS Cve_intl,
			CHAR(3)  AS Cve_oficial,
			CHAR(30) AS Descripcion;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err       INTEGER;
DEFINE cCodRet        CHAR(6);
DEFINE cSigla         CHAR(4);
DEFINE cCve_intl      CHAR(3);
DEFINE cCve_oficial   CHAR(3);
DEFINE cDescripcion   CHAR(30);
DEFINE iBandera       INTEGER;

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err		 = 0;
LET cCodRet          = '000000';
LET cSigla		     = '';
LET cCve_intl        = '';
LET cCve_oficial     = '';
LET cDescripcion     = '';
LET iBandera         = 0;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consulta_divisas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, cSigla, cCve_intl, cCve_oficial, cDescripcion WITH RESUME;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pCodDivisa,'')) <> '' THEN 
		
			SELECT sigla, cve_intl, cve_oficial, descripcion
			INTO cSigla, cCve_intl, cCve_oficial, cDescripcion 
			FROM bdinteg:"informix".si_divisas
			WHERE divisa = pCodDivisa 
			AND	empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002';
			END IF;			
			
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	RETURN cCodRet, cSigla, cCve_intl, cCve_oficial, cDescripcion WITH RESUME;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION:Consulta los registros de la tabla si_divisas de acuerdo a un cÃ³digo en espeÃ­fico.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultapiezas_bym_web(pNumRecibo CHAR(10))
RETURNING CHAR(5) AS cCodRet,INTEGER AS iImporteFinal;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE iImporte INTEGER;
DEFINE iImporteFinal INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodRet	= "00000";
LET iSqlErr = 0;
LET iImporte=0;
LET iImporteFinal=0;

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultapiezas_bym.out';
	--TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN  cCodRet,iImporte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF TRIM(NVL(pNumRecibo,''))='' THEN
			LET cCodRet = '00001'; --Parametros de entrada vacios
		ELSE
			IF(SELECT COUNT(num_recibo) FROM bdisuc:"informix".ss_piezas_bym_falsos WHERE num_recibo=pNumRecibo)>0 THEN
				FOREACH
				
					SELECT (NVL(pzs.num_piezas,0) * NVL(denom.denominacion,0)) 
					INTO iImporte
					FROM bdisuc:"informix".ss_piezas_bym_falsos pzs INNER JOIN bdisuc:"informix".ss_denominacion_bym_falsos denom ON denom.id_denominacion = pzs.id_denominacion
					WHERE num_recibo=TRIM(NVL(pNumRecibo,''))
					AND pzs.estatus= 3
					AND pzs.dictamen_banxico= 1
					AND pzs.empresa=denom.empresa
					
					LET iImporteFinal = iImporte + iImporteFinal ;
					
				END FOREACH;
			ELSE
				LET cCodRet = '00002'; --No se encontraron registros
			END IF;
			IF iImporteFinal = 0 THEN						
				LET cCodRet = '00003'; --No se encontraron registros
			END IF;
		END IF;
	
	RETURN  cCodRet,iImporteFinal;
END;
END PROCEDURE
DOCUMENT
"Descripcion: Consulta de importe a pagar de elementos dictaminados como autenticos.",
"Autor : Leslie Rendon",
"FECHA : 06/03/2015",
"BD    : bdisuc";

CREATE PROCEDURE "informix".sp_consultacat_piezas_bym_web(pOpcion CHAR(1), pDato CHAR(1))
RETURNING   CHAR(5) AS CodRet,
			INTEGER AS IdTipoPieza,
			CHAR(1) AS CveTipoPieza,
			CHAR(7) AS TipoPieza;
			
			

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE iIdTipoPieza         INTEGER;
DEFINE cCveTipoPieza        CHAR(1);
DEFINE cTipoPieza           CHAR(7);
DEFINE iBandera             INTEGER;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '00000';
LET iIdTipoPieza		= 0;
LET cCveTipoPieza       = '';
LET cTipoPieza          = '';
LET iBandera            = 0;


SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consultacat_piezas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(5));
			RETURN cCodRet, iIdTipoPieza, cCveTipoPieza, cTipoPieza WITH RESUME;
		END IF;
	END EXCEPTION;
	        
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' THEN
		IF pOpcion= '2' AND TRIM(NVL(pDato,'' )) = '' THEN
			LET cCodRet = '00001';
		ELSE
			FOREACH	
				SELECT  id_tipo_pieza, clave_tipo_pieza, tipo_pieza 
				INTO iIdTipoPieza, cCveTipoPieza, cTipoPieza
				FROM bdisuc:"informix".ss_cat_tipo_pieza_bym_falsos
				WHERE empresa = '001' 
				AND clave_tipo_pieza = CASE WHEN pOpcion= '2' THEN NVL(pDato,'') ELSE clave_tipo_pieza END
			
				LET iBandera =  1;
				
				RETURN cCodRet, iIdTipoPieza, cCveTipoPieza, cTipoPieza WITH RESUME;
				
			END FOREACH;
		
			IF iBandera = 0 THEN
				LET cCodRet = '00002';
			END IF;
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, iIdTipoPieza, cCveTipoPieza, cTipoPieza WITH RESUME;
	END IF;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: 98640909 - LUIS BELTRAN',
'FECHA: 13-11-2019',
'DESCRIPCION: SE CREA CLON DEL sp_consultacat_piezas_bym MODIFICANDO EL CODRET A CHAR(5)',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_grabardoctosadmon_web(p_sEmpresa CHAR(3), p_sNumeroCaja CHAR(10), p_iTipoCarpeta SMALLINT,
				 p_iNumeroCarpeta CHAR(4), p_sFechaInicio DATE, p_sFechaFinal DATE, p_sSucursal CHAR(4),
				 p_sEstatus CHAR(1), p_iTipoGrabacion SMALLINT, p_sUsuarioRegistra CHAR(8), p_sUsuarioAutoriza CHAR(8),
				 p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_dFechaNuevaIni DATE,p_dFechaNuevaFin DATE)

	RETURNING CHAR(5) AS retorno;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(5);
	DEFINE v_dFechaInsercion				DATE;

	--*****************************************************************************************************************************	
	--SET DEBUG FILE TO "/informix/Cristian/sps/Subir/sp_grabardoctosadmon_web.out";                                                                          --*
	--TRACE ON;                                                                                                                   --*
	--*****************************************************************************************************************************
	
	LET v_sValRetorno = '00001';
	LET v_dFechaInsercion = CURRENT::DATE;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumeroCaja,'') = '' OR NVL(p_iTipoCarpeta,'') = '' OR NVL(p_iNumeroCarpeta,'') = '' 
		OR NVL(p_sFechaInicio,'') = '' OR NVL(p_sFechaFinal,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_sEstatus,'') = ''
		OR NVL(p_iTipoGrabacion,'') = '' THEN
			RETURN v_sValRetorno;
		END IF;		
		
		IF NVL(p_sUsuarioRegistra,'') = '' THEN 
			LET p_sUsuarioRegistra = NULL;
		END IF
		IF NVL(p_sUsuarioAutoriza,'') = '' THEN 
			LET p_sUsuarioAutoriza = NULL;
		END IF
		IF NVL(p_sUsuarioSolicita,'') = '' THEN  
			LET p_sUsuarioSolicita = NULL;
		END IF
		IF NVL(p_sComentario,'') = '' THEN
			LET p_sComentario = NULL;
		END IF
		
		LET v_sValRetorno = '00001';
		--SI NO EXISTE GUARDA, SI EXISTE ACTUALIZA
		IF (SELECT 1 FROM bdisuc:"informix".ss_documentosadmon WHERE empresa = p_sEmpresa AND tipodocumento = p_iTipoCarpeta 
		AND ((p_sFechaInicio BETWEEN fechainicio AND fechafinal) OR (p_sFechaFinal BETWEEN fechainicio AND fechafinal)) 
		AND sucursal = p_sSucursal) = 0 THEN

			INSERT INTO bdisuc:"informix".ss_documentosadmon(empresa, numerocaja, tipodocumento, numerocarpeta, fechainicio, fechafinal, 
			sucursal, estatus, usuarioregistra, usuarioautoriza, usuariosolicita, comentario, fecha_insert)
			VALUES(p_sEmpresa, p_sNumeroCaja, p_iTipoCarpeta, p_iNumeroCarpeta, p_sFechaInicio, p_sFechaFinal,
			p_sSucursal, p_sEstatus, p_sUsuarioRegistra, p_sUsuarioAutoriza, p_sUsuarioSolicita, p_sComentario, v_dFechaInsercion);			
			
			LET v_sValRetorno = '00000';
		ELSE
			IF (SELECT 1 FROM bdisuc:"informix".ss_documentosadmon WHERE empresa = p_sEmpresa AND tipodocumento = p_iTipoCarpeta 
			AND fechainicio = p_sFechaInicio AND fechafinal = p_sFechaFinal AND sucursal = p_sSucursal) > 0 THEN
				--SI ES UNA ACTUALIZACION
				IF p_iTipoGrabacion = 2 THEN
					--ACTUALIZA SOLAMENTE EL ESTATUS
					UPDATE bdisuc:"informix".ss_documentosadmon 
					SET estatus = p_sEstatus, usuarioregistra = p_sUsuarioRegistra,
					usuarioautoriza = p_sUsuarioAutoriza, 
					usuariosolicita = p_sUsuarioSolicita,
					comentario = p_sComentario,
					fechainicio = p_dFechaNuevaIni,
					fechafinal = p_dFechaNuevaFin
					WHERE empresa = p_sEmpresa AND tipodocumento = p_iTipoCarpeta AND fechainicio = p_sFechaInicio 
					AND fechafinal = p_sFechaFinal AND sucursal = p_sSucursal;
					
					LET v_sValRetorno = '00000';
				ELSE
					LET v_sValRetorno = '00003';
				END IF;
			ELSE 
				LET v_sValRetorno = '00002';
			END IF			
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Fabiola Corrales',
'FECHA:       13-Agosto-2009',
'CASO DE USO: Caso de uso asociado: PCU-bdisuc\CU-0007-GrabarDoctosAdmon-SPL',
'DESCRIPCION: Guarda o actualiza la informacion de los documentos Adminitrativos',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar el usuarioregistra, usuarioautoriza, usuariosolicita y comentario',
'MODIFICO: Josue Zepeda',  
'FECHA:       28/Febrero/2013',
'BD: bdisuc',
'DESCRIPCION: se agrega parametro p_dFechaNuevaIni y p_dFechaNuevaFin para la actualizacion';

CREATE PROCEDURE "informix".sp_guarda_reclamo_bym_web(pOpcion CHAR(1), pNumRecibo CHAR(10), pEmpresa CHAR(3), pTipoOperReclamo CHAR(10), pFechaOperacion DATE, pCodEmpReclamo CHAR(3), pDescEmpReclamo CHAR(40), pDescSucReclamo CHAR(40), pNumSucReclamo CHAR(6), pDomSucReclamo CHAR(40),  pTelSucReclamo CHAR(10), pTipoRecibo CHAR(15), pIdTenedor INTEGER, pNumSucRetencion CHAR(4), pObservaciones CHAR(200), pEjecutivo CHAR(8))
RETURNING   CHAR(5) AS CodRet,
            CHAR(10) AS NumRecibo ;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cNumRecibo           CHAR(10);
DEFINE cRecibo              CHAR(10);
DEFINE cConRecibo           CHAR(8);

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '00000';
LET cNumRecibo          = '';
LET cRecibo             = '';
LET cConRecibo          = '';

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/informix/sp_guarda_reclamo_bym_web.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(5));
			RETURN cCodRet, cNumRecibo;
		END IF;
	END EXCEPTION; 
	
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' THEN
		IF TRIM(NVL(pOpcion,'')) = '1' THEN
			IF TRIM(NVL(pEmpresa,'')) <>'' AND TRIM(NVL(pTipoRecibo,'')) <>'' AND NVL(pIdTenedor,0) > 0 AND TRIM(NVL(pNumSucRetencion,'')) <>'' AND TRIM(NVL(pEjecutivo,'')) <>'' THEN
				
				LET cConRecibo = LPAD(pNumSucRetencion,4,'0000') || LPAD(DAY(CURRENT),2,'00') || LPAD(MONTH(CURRENT),2,'00') ;
				
				SELECT MAX(num_recibo)
				INTO cRecibo
				FROM bdisuc:"informix".ss_recibo_bym_falsos
				WHERE  num_sucursal_retencion = pNumSucRetencion
				AND num_recibo LIKE cConRecibo || '%' ;
				
				IF NVL(cRecibo,"0") = "0" THEN
					LET cNumRecibo = cConRecibo || '01';
				ELSE	
					LET cNumRecibo = cConRecibo || LPAD(CAST(SUBSTR(cRecibo,9,2) AS INTEGER)+1,2,'00');
				END IF;
				
				INSERT INTO  bdisuc:"informix".ss_recibo_bym_falsos(num_recibo,empresa_retiene,tipo_recibo,id_tenedor,num_sucursal_retencion,fecha_insert,ejecutivo_insert)
				VALUES(cNumRecibo, pEmpresa, pTipoRecibo, pIdTenedor, pNumSucRetencion, CURRENT, pEjecutivo);
			ELSE
				LET cCodRet  = '00001';
			END IF;
			
		ELIF TRIM(NVL(pOpcion,'')) = '2' THEN
			
			IF  TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pFechaOperacion,'')) <> '' AND TRIM(NVL(pTipoOperReclamo,'')) <> '' AND TRIM(NVL(pCodEmpReclamo,'')) <> '' AND TRIM(NVL(pDescEmpReclamo,'')) <> '' AND TRIM(NVL(pTipoRecibo,'')) <> ''  AND NVL(pIdTenedor,0) > 0  THEN
	
                LET pDescSucReclamo = TRIM(pDescSucReclamo);
				LET pNumSucReclamo = TRIM(pNumSucReclamo);
				LET pDomSucReclamo = TRIM(pDomSucReclamo);
				LET pTelSucReclamo = TRIM(pTelSucReclamo);
				LET pObservaciones = TRIM(pObservaciones);
				
				UPDATE bdisuc:"informix".ss_recibo_bym_falsos
				SET tipo_oper_reclamo = pTipoOperReclamo, fecha_operacion = pFechaOperacion,  cod_empresa_reclamo = pCodEmpReclamo, desc_empresa_reclamo = pDescEmpReclamo, desc_suc_reclamo = NVL(pDescSucReclamo,''), 
					num_suc_reclamo = NVL(pNumSucReclamo,''), domicilio_suc_reclamo = NVL(pDomSucReclamo,''), tel_suc_reclamo = NVL(pTelSucReclamo,''), tipo_recibo = pTipoRecibo, observaciones = NVL(pObservaciones,'')
                WHERE num_recibo = pNumRecibo;
				
				LET cNumRecibo = pNumRecibo;
				
			ELSE
				LET cCodRet  = '00001';
			END IF;
		
		END IF;
	
	ELSE
		LET cCodRet  = '00001';
	END IF;
	
	RETURN cCodRet, cNumRecibo;

END;    
END PROCEDURE
DOCUMENT
'REALIZO: 98640909 - LUIS BELTRAN',
'FECHA: 13-11-2019',
'DESCRIPCION: SE CREA CLON DEL sp_guarda_reclamo_bym MODIFICANDO EL CODRET A CHAR(5)',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_guarda_tenedor_bym_web(pAp_paterno CHAR(40), pAp_materno CHAR(40), pNombre_1 CHAR(40) ,pNombre_2 CHAR(40), pFecha_nac CHAR(10), pRfc CHAR(13), pIdentificacion CHAR(20), pNum_identificacion CHAR(40), pCalle CHAR(40), pNumero_calle CHAR(10), pColonia CHAR(6), pDelegacion_poblacion  CHAR(3), pCod_postal  CHAR(5), pCiudad  CHAR(3), pEstado CHAR(2),  pTelefono CHAR(13), pTipo_tel CHAR(10), pEmail CHAR(30), pEjecutivo_insert CHAR(8))
RETURNING   CHAR(5) AS CodRet,
            INTEGER AS IdTenedor ;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE iIdTenedor           INTEGER;

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '00000';
LET iIdTenedor          = 0;



SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_guarda_tenedor_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(5));
			RETURN cCodRet, iIdTenedor;
		END IF;
	END EXCEPTION; 
	
	IF TRIM(NVL(pAp_paterno,'')) <> '' AND TRIM(NVL(pNombre_1,'')) <> '' AND TRIM(NVL(pFecha_nac,'')) <> ''  AND  TRIM(NVL(pRfc,'')) <> '' AND TRIM(NVL(pCalle,'')) <> '' AND TRIM(NVL(pNumero_calle,'')) <> '' AND TRIM(NVL(pColonia,'')) <> '' AND TRIM(NVL(pCod_postal,'')) <> '' AND TRIM(NVL(pEstado,'')) <> '' AND TRIM(NVL(pTelefono,'')) <> '' AND  TRIM(NVL(pTipo_tel,'')) <> '' AND TRIM(NVL(pEjecutivo_insert,'')) <> '' THEN 
		IF CAST(TRIM(pEstado) AS INTEGER) = 9 THEN 
			IF TRIM(NVL(pDelegacion_poblacion,'')) = '' THEN  	
				LET cCodRet  = '00001';
			ELSE
				IF TRIM(NVL(pCiudad,'')) = '' THEN  	
					LET pCiudad  = ' ';
				END IF;
			END IF;
		ELSE
			IF TRIM(NVL(pCiudad,'')) = '' THEN  	
				LET cCodRet  = '00001';
			ELSE
				IF TRIM(NVL(pDelegacion_poblacion,'')) = '' THEN  	
					LET pDelegacion_poblacion  = ' ';
				END IF;
			END IF;
			
		END IF;
		
		IF cCodRet  = '00000' THEN
		
			INSERT INTO bdisuc:"informix".ss_tenedor_pieza(ap_paterno,ap_materno,nombre_1,nombre_2,fecha_nac,rfc,identificacion,num_identificacion,calle,numero_calle,colonia,delegacion_poblacion,cod_postal,ciudad,estado,telefono,tipo_tel,email,ejecutivo_insert,fecha_insert) 
			VALUES(pAp_paterno,pAp_materno,pNombre_1,pNombre_2,pFecha_nac,pRfc,pIdentificacion,pNum_identificacion,pCalle,pNumero_calle,pColonia,pDelegacion_poblacion,pCod_postal,pCiudad,pEstado,pTelefono,pTipo_tel,pEmail,pEjecutivo_insert,CURRENT);
			
			SELECT MAX(id_tenedor)
			INTO iIdTenedor
			FROM bdisuc:"informix".ss_tenedor_pieza
			WHERE ap_paterno = pAp_paterno
			AND ap_materno = pAp_materno
			AND nombre_1 = pNombre_1
			AND nombre_2 = pNombre_2
			AND fecha_nac = pFecha_nac
			AND rfc = pRfc;
			
			IF NVL(iIdTenedor,0) = 0 THEN
				LET cCodRet  = '00001'; -- luego pregunto
			END IF;
			
		END IF;
	
	ELSE
		LET cCodRet  = '00001';
	END IF;
	
	RETURN cCodRet, iIdTenedor;

END;    
END PROCEDURE
DOCUMENT
'REALIZO: 98640909 - LUIS BELTRAN',
'FECHA: 13-11-2019',
'DESCRIPCION: SE CREA CLON DEL sp_guarda_tenedor_bym MODIFICANDO EL CODRET A CHAR(5)',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_recepdota_web(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
                pfolio_suc char(16),
                pfolio_dota char(8),
  		ptransaccion char(4),
		pdivisa CHAR(2),
                pfecha date,
		pmonto_dot money(14,2))
RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum smallint;
DEFINE vmontodot money(14,2);
DEFINE vstatus char(2);


LET vcodret = "00000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vmontodot = 0;
LET vstatus  = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/recepdota.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio_dota = '' then
   LET vcodret = "00110";
ELSE

    select plaza_cajagen into vplaza
    from   bdinteg:si_sucursales
    where  sucursal = psucursal;

    select cod_proveedor into vproveedor
    from   ss_proveedores
    where  plaza = vplaza;

    select 1,monto,status into vnum,vmontodot,vstatus
    from   ss_mae_entradasalida
    where  folio_oper = pfolio_dota;
    if vnum is null then
       LET vcodret = "00100";
       return vcodret;
    else
       if vmontodot != pmonto_dot then
          LET vcodret = "00102";
          return vcodret;
       end if
       if Trim(vstatus) = "08" then
          LET vcodret = "00103";
          return vcodret;
       end if
       if Trim(vstatus) != "11" then
          LET vcodret = "00104";
          return vcodret;
       end if
    end if

    UPDATE ss_mae_entradasalida
    SET    fecha_recepcion = pfecha,
           hora_recepcion = vhora,
           usuario_recepcion = pcajeroprincipal,
           status = '05'
    WHERE  folio_oper = pfolio_dota;
    UPDATE ss_cajageneral
    SET    saldo_asignado = saldo_asignado - pmonto_dot
    WHERE  cod_proveedor = vproveedor;

  {  INSERT INTO ss_operaciones
	  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
           denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
           denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
           denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
           cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
           cantidad_13,cantidad_14,cantidad_15)
    VALUES
          (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
           pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
	   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
	   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

    INSERT INTO ss_mae_entradasalida
           (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
            status,monto)
    VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,pfecha,vhora,pcajeroprincipal,'01',pmonto_dot);
}

END IF;

RETURN vcodret;
END;
END PROCEDURE;