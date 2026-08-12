CREATE PROCEDURE "informix".sp_consultarcatdocumentos(p_sEmpresa CHAR(3), p_iCveDocumento SMALLINT, p_iCantRegistros INTEGER)
	RETURNING	CHAR(6) AS retorno, 
				CHAR(3) AS empresa, 
				SMALLINT AS cvedocumento,
				CHAR(80) AS descripcion,
				CHAR(1) AS tipodocumento,
				CHAR(1) AS bloqueado,
				DATE AS fecha_insert,
				CHAR(1) AS cantidad;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_iCveDocumento					SMALLINT;
	DEFINE v_sDescripcion					CHAR(80);
	DEFINE v_sTipoDocumento					CHAR(1);
	DEFINE v_dFechaInsercion				DATE;
	DEFINE v_sBloqueado						CHAR(1);
	DEFINE v_iNumRegistro					INTEGER;
	DEFINE v_sCantidad						CHAR(1);
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarCatDocumentos.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	LET v_sValRetorno = '000001';
	LET v_iNumRegistro = 0;
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','';
			END IF;
		END EXCEPTION;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' THEN
			RETURN v_sValRetorno,'','','','','','','';
		END IF;
		
		IF p_iCveDocumento = '' THEN
			LET p_iCveDocumento = NULL;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--OBTIENE EL CATALOGO DE DOCUMENTOS
		FOREACH
			SELECT empresa, cvedocumento, descripcion, tipodocumento, bloqueado, fecha_insert,cantidad
			INTO v_sEmpresa, v_iCveDocumento, v_sDescripcion, v_sTipoDocumento, v_sBloqueado, v_dFechaInsercion,v_sCantidad
			FROM bdisuc:"informix".ss_catdocumentos
			WHERE empresa = p_sEmpresa AND cvedocumento = NVL(p_iCveDocumento, cvedocumento)
			
			LET v_iNumRegistro = v_iNumRegistro + 1;
			IF v_iNumRegistro <= p_iCantRegistros THEN
				CONTINUE FOREACH;
			END IF;
			
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno,  v_sEmpresa, v_iCveDocumento, v_sDescripcion, v_sTipoDocumento, v_sBloqueado, v_dFechaInsercion,v_sCantidad WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora', 
'FECHA: 05/Agosto/2009',
'DESCRIPCION: Consulta el catalogo de documentos',
'CASO DE USO: PCU-bdisuc\CU-0016-ConsultarCatDocumentos-SPL',
'MODIFICO: Josue Zepeda', 
'FECHA: 27/Febrero/2013',
'DESCRIPCION: Se agrega variable de retorno v_sCantidad';

CREATE PROCEDURE "informix".sp_grabarcatdocumentos(p_sempresa CHAR(3), p_icvedocumento SMALLINT, p_sDescripcion CHAR(80), p_sTipoDocto CHAR(1), p_sBloqueado CHAR(1),p_sCantidad CHAR(1))

	RETURNING CHAR(6) AS retorno;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_dFechaInsercion				DATE;
	DEFINE v_iCveDocumento					SMALLINT;

	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/vladi/sp_grabarcatdocumentos.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '000001';
	LET v_dFechaInsercion = CURRENT::DATE;
	LET v_iCveDocumento = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		 
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sDescripcion,'') = '' OR NVL(p_sTipoDocto,'') = '' OR NVL(p_sBloqueado,'') = '' THEN
			RETURN v_sValRetorno;
		END IF;

		--SI LA CLAVE DEL DOCUMENTO ES NULA, SE BUSCA EL NUMERO CONSECUTIVO SIGUIENTE
		IF NVL(p_icvedocumento,'') = '' THEN
			--OBTIENE EL SIGUIENTE NUMERO CONSECUTIVO
			SELECT NVL(MAX(cvedocumento),0) INTO v_iCveDocumento FROM bdisuc:"informix".ss_catdocumentos;
			LET v_iCveDocumento = v_iCveDocumento + 1;
			
			--GUARDA UN TIPO NUEVO TIPO DE CARPETA
			INSERT INTO bdisuc:"informix".ss_catdocumentos(empresa, cvedocumento, descripcion, tipodocumento, bloqueado, fecha_insert,cantidad)
			VALUES (p_sEmpresa, v_iCveDocumento, p_sDescripcion, p_sTipoDocto, p_sBloqueado, v_dFechaInsercion,p_sCantidad);
			LET v_sValRetorno = '000000';	
		ELSE
			LET v_iCveDocumento = p_icvedocumento;
			--SI NO EXISTE GUARDA, SI EXISTE ACTUALIZA
			IF NOT EXISTS (SELECT 1 FROM bdisuc:"informix".ss_catdocumentos WHERE empresa = p_sEmpresa	AND cvedocumento = v_iCveDocumento) THEN
				
				INSERT INTO bdisuc:"informix".ss_catdocumentos(empresa, cvedocumento, descripcion, tipodocumento, bloqueado, fecha_insert,cantidad)
				VALUES (p_sEmpresa, v_iCveDocumento, p_sDescripcion, p_sTipoDocto, p_sBloqueado, v_dFechaInsercion,p_sCantidad);
				
				LET v_sValRetorno = '000000';
			ELSE
				UPDATE bdisuc:"informix".ss_catdocumentos 
				SET    descripcion = p_sDescripcion, bloqueado = p_sBloqueado,cantidad = p_sCantidad
				WHERE  empresa = p_sEmpresa
				AND    cvedocumento = v_iCveDocumento;
				
				LET v_sValRetorno = '000000';
			END IF;
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Vladimir Félix Gálvez',
'FECHA: 04-Agosto-2009',
'CASO DE USO: PCU-bdisuc\CU-0013-GrabarCatDocumentos-SPL',
'DESCRIPCION: Guarda o actualiza la informacion de los documentos de las sucursales.',
'MODIFICO: Josue Zepeda', 
'FECHA: 27/Febrero/2013',
'DESCRIPCION: Se agrega parametro p_sCantidad y se agrega al insert y update';

CREATE PROCEDURE "informix".sp_obtenercajasrelacionadas(pInumsucursal INTEGER, pIopcion INTEGER, pItipopaquete INTEGER, pSecuencia INTEGER)
    RETURNING   CHAR(5) AS retorno,
				CHAR(20) AS sucursalrelacionada,
				CHAR(10) AS cajanueva,
				CHAR(10) AS cajaanterior;
	
	DEFINE iSqlErr       	 INTEGER;
    DEFINE cCodRet    	 	 CHAR(5);
    DEFINE cCaja 		 	 CHAR(20);
	DEFINE cCajaSuc 	 	 CHAR(20);
	DEFINE cConsecutivoCaja	 CHAR(7);
	DEFINE cCajaNueva    	 CHAR(10);
	DEFINE sMes			 	 SMALLINT;
	DEFINE sAnio		 	 SMALLINT;
	DEFINE sConsecutivoMayor SMALLINT;
	DEFINE cSucursal	 	 CHAR(4);
	DEFINE cCajaAnterior 	 CHAR(10);
	DEFINE cFecha            CHAR(10);
	
	LET cCodRet = '00001';
	LET cCaja = '';
	LET cCajaSuc = '';
	LET cConsecutivoCaja = '';
	LET cCajaNueva = '';
	LET sMes = '';
	LET sAnio = ''; 
	LET sConsecutivoMayor = '';
	LET cSucursal = '';
	LET cCajaAnterior = '';
	LET cFecha = '';
	
	--SET DEBUG FILE TO "/tmp/sp_obtenercajasrelacionadas.out";
	--TRACE ON;
	
	    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
					RETURN cCodRet,cCajaSuc,cCajaNueva,cCajaAnterior;
                END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF NVL(pInumsucursal,'') = '' OR NVL(pItipopaquete,'') = '' THEN
			RETURN cCodRet,cCajaSuc,cCajaNueva,cCajaAnterior;
		END IF;
		
		
		IF pIopcion = 1 THEN 
		
			SELECT fecha_hoy INTO cFecha FROM bdinteg:si_fechas;

			LET sMes = LPAD(MONTH(cFecha),2,'0');
			LET sAnio = SUBSTR(YEAR(cFecha),3,2);
			
		
			IF EXISTS(SELECT 1 FROM bdisuc:"informix".ss_numcajas WHERE numsucursal = pInumsucursal AND SUBSTR(numerocaja,7,2) = sAnio
				AND SUBSTR(numerocaja,5,2) = sMes ) THEN
		
				--SE OBTIENE EL NUMERO DE CAJA CONSECUTIVO - se crea caja nueva.
				SELECT NVL(MAX(SUBSTR(numerocaja,9,2)::INT),'00') + 1
				INTO cConsecutivoCaja
				FROM bdisuc:"informix".ss_numcajas WHERE numsucursal = pInumsucursal
				AND SUBSTR(numerocaja,7,2) = sAnio
				AND SUBSTR(numerocaja,5,2) = sMes;
				
				LET cSucursal = LPAD(pInumsucursal,4,'0');
				LET sConsecutivoMayor = LPAD(cConsecutivoCaja,2,'0');
				
				LET cCajaNueva = LPAD(sAnio,2,'0') || LPAD(sMes,2,'0') || LPAD(sConsecutivoMayor,2,'0');
				LET cCajaAnterior = cSucursal || LPAD(sMes,2,'0') || LPAD(sAnio,2,'0') || LPAD(sConsecutivoMayor - 1,2,'0');
				
				LET cCodRet = '00000';
			
				IF EXISTS(SELECT 1 FROM bdisuc:"informix".ss_numcajas WHERE numerocaja = cCajaAnterior AND estatus = 'Activa' AND tipopaquete = pItipopaquete) THEN
					
					IF pItipopaquete = 1 THEN --EXP_CLIENTES
						IF NOT EXISTS(SELECT 1 FROM bdisuc:"informix".ss_expedientesclientes WHERE numerocaja = cCajaAnterior) THEN
							LET cCodRet = '00002'; --EXISTE CAJA ABIERTA SIN INFORMACION
						END IF;
					elif pItipopaquete = 2 THEN --PAQ_OPERATIVO
						IF NOT EXISTS(SELECT 1 FROM bdisuc:"informix".ss_paquetesoperativos WHERE numerocaja = cCajaAnterior) THEN
							LET cCodRet = '00002'; --EXISTE CAJA ABIERTA SIN INFORMACION 
						END IF;
					elif pItipopaquete = 3 THEN --DOCTOS_ADMIN
						IF NOT EXISTS(SELECT 1 FROM bdisuc:"informix".ss_documentosadmon WHERE numerocaja = cCajaAnterior) THEN
							LET cCodRet = '00002'; --EXISTE CAJA ABIERTA SIN INFORMACION 
						END IF;
					elif pItipopaquete = 4 THEN --CARD_CARRIERS
						IF NOT EXISTS(SELECT 1 FROM bdisuc:"informix".ss_cardcarriers WHERE numerocaja = cCajaAnterior) THEN
							LET cCodRet = '00002'; --EXISTE CAJA ABIERTA SIN INFORMACION 
						END IF;
					elif pItipopaquete = 5 THEN --PAQ_CHEQUES
						IF NOT EXISTS(SELECT 1 FROM bdisuc:"informix".ss_paquetescheques WHERE numerocaja = cCajaAnterior) THEN
							LET cCodRet = '00002'; --EXISTE CAJA ABIERTA SIN INFORMACION 
						END IF;
					END IF;
				END IF;
				
			ELSE --no existe - se crea caja nueva
				
				LET sConsecutivoMayor = '01';
				LET cCajaNueva = LPAD(sAnio,2,'0') || LPAD(sMes,2,'0') || LPAD(sConsecutivoMayor,2,'0');
				
				LET cCodRet = '00000';
				
			END IF;
			
			RETURN cCodRet,cCajaSuc,cCajaNueva,cCajaAnterior;
			
		ELSE  --pIopcion
		
			IF NOT EXISTS(SELECT sucursal_relacionada FROM bdisuc:"informix".ss_sucursalesrelacionadas WHERE sucursal_matriz = pInumsucursal AND status_relacion  ='A') THEN
				LET cCodRet = '00001';
				RETURN cCodRet,cCajaSuc,cCajaNueva,cCajaAnterior;
			ELSE
				
				CREATE TABLE bdisuc:"informix".tme_sucursalesrelacionadas(sucursal_matriz CHAR(5),sucursal_relacionada CHAR(5));
				
				
				INSERT INTO bdisuc:"informix".tme_sucursalesrelacionadas(sucursal_matriz,sucursal_relacionada)
				SELECT sucursal_matriz,sucursal_relacionada FROM bdisuc:"informix".ss_sucursalesrelacionadas WHERE sucursal_matriz = pInumsucursal AND status_relacion  ='A';
			
				IF NOT EXISTS(SELECT sucursal_relacionada FROM bdisuc:"informix".ss_sucursalesrelacionadas WHERE sucursal_relacionada = pInumsucursal AND status_relacion  ='A') THEN
					INSERT INTO bdisuc:"informix".tme_sucursalesrelacionadas(sucursal_matriz,sucursal_relacionada) VALUES(LPAD(pInumsucursal,4,'0'),LPAD(pInumsucursal,4,'0'));
				END IF;
				
				
				FOREACH
					SELECT skip pSecuencia sucursal_relacionada INTO cCaja FROM bdisuc:"informix".tme_sucursalesrelacionadas WHERE sucursal_matriz = pInumsucursal ORDER BY sucursal_relacionada = pInumsucursal
					
					LET cCajaSuc = TRIM(cCaja);

						IF TRIM(cCaja) = pInumsucursal THEN
							LET cCajaSuc = TRIM(cCaja) || " " || "(Matriz)";
						END IF
					
					LET cCodRet = '00000';
					
					RETURN cCodRet,cCajaSuc,cCajaNueva,cCajaAnterior WITH RESUME;
				END FOREACH;
			END IF;
			
			DROP TABLE bdisuc:"informix".tme_sucursalesrelacionadas;
		END IF;
    END;
END PROCEDURE
DOCUMENT
'CREADO: Josue Zepeda',
'FECHA: 20/Febrero/2013',
'BD: BDISUC',
'DESCRIPCION: Consulta sucursales relacionadas, obtiene el consecutivo de caja y valida si existe caja abierta sin documentos';

create procedure "informix".sp_listaview(pfecha date,patm char(4))
RETURNING char(03),
		  char(10),
		  char(4) ,
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(16),
		  char(16);
		  
		  
		  
		--variables retorno   
DEFINE	  rfecha        char(10);
DEFINE    rsucursal     char(4) ;
DEFINE    rdeno1        char(30);
DEFINE    rdeno2        char(18);
DEFINE    rdeno3        char(18);
DEFINE    rdeno4        char(18);
DEFINE    radeno1       char(18);
DEFINE    radeno2       char(18);
DEFINE    radeno3       char(18);
DEFINE    radeno4       char(18);
DEFINE    rmonto        char(16);
DEFINE    ramonto       char(16);
define	cont			integer;
		  
		  
		  
		  
		  
		  
		  
		  
		   
	DEFINE cod_ret 	char(03);
	DEFINE	mensaje	char(50);
	
    DEFINE iSqlErr                integer;
    DEFINE iSamErr             integer;
    DEFINE vDesErr             VARCHAR(50);
	
 


begin	
 ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;    
			LET mensaje =  vDesErr;
        END IF;
        RETURN cod_ret,rfecha,rsucursal ,rdeno1,rdeno2,rdeno3 ,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  ; 
	
 END EXCEPTION;
 
	let cod_ret = '000'; 
	let rfecha   ='';
	let rsucursal='';
	let rdeno1   ='';
	let rdeno2   ='';
	let rdeno3   ='';
	let rdeno4   ='';
	let radeno1  ='';
	let radeno2  ='';
	let radeno3  ='';
	let radeno4  ='';
	let rmonto   ='';
	let ramonto  ='';	
	let cont =0;
	
	SELECT count(*)  
	into cont
	FROM bdisuc:ss_corteadminview WHERE atm = patm and fecha = pfecha;
	
	if cont <> 0 THEN
			SELECT *  
			into rfecha,rsucursal,rdeno1,rdeno2,rdeno3,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  
			FROM bdisuc:ss_corteadminview WHERE atm = patm and fecha = pfecha;
			
			RETURN cod_ret,rfecha,rsucursal,rdeno1,rdeno2,rdeno3,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  ;
	else
		let cod_ret= '007';
		let rdeno1='no se encontraron registros';
		let rdeno2=cont;
	end if ;
	
	 RETURN cod_ret,rfecha,rsucursal,rdeno1,rdeno2,rdeno3,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  ;
end	
end procedure;