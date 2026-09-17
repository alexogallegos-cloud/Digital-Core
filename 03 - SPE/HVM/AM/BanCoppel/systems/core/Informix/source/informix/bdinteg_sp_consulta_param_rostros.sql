CREATE PROCEDURE "informix".sp_consulta_param_rostros(pEmpresa CHAR(3), pSucursal CHAR(4), pCodigo CHAR(20),pOpcion CHAR(1),pEjecucion SMALLINT)
RETURNING CHAR(6) AS cCodRet, CHAR(3) AS cEmpresa, CHAR(4) AS cSucursal, CHAR(20) AS cCodigo, VARCHAR(100) AS cValor, CHAR(30) AS cDescripcion;
--DECLARACION DE VARIABLES
DEFINE cCodRet       	CHAR(6);
DEFINE iSqlErr        INTEGER;
DEFINE cCodigo        CHAR(20);
DEFINE cValor         VARCHAR(100);
DEFINE cDescripcion   CHAR(30);
DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE vcont  SMALLINT;

--INICIALIZACION DE VARIABLES
LET cCodRet="000000"; --CÃ³digo exitoso
LET iSqlErr=0;
LET cCodigo='';
LET cValor ='';
LET cDescripcion='';
LET cEmpresa='';
LET cSucursal='';
LET vcont  = 0;

  BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			LET cCodigo='';
			LET cValor ='';
			LET cDescripcion='';
			LET cEmpresa='';
			LET cSucursal='';
            RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO wait 3;
	
	--SET DEBUG FILE TO '/respaldosbd/Leslie/08022016/sp2.out';
	--TRACE ON;
	
		IF TRIM(NVL(pEmpresa,''))<>'' AND TRIM(NVL(pSucursal,''))<>''  AND TRIM(NVL(pOpcion,''))<>'' THEN
			IF TRIM(NVL(pOpcion,''))='1'  THEN
				IF TRIM(NVL(pCodigo,''))<>'' THEN
					SELECT empresa,sucursal,codigo,valor, descripcion 
					INTO   cEmpresa,cSucursal,cCodigo,cValor, cDescripcion
					FROM bdinteg:"informix".si_sucservicios_rostro
					WHERE empresa=pEmpresa
					AND sucursal=pSucursal 
					AND codigo=pCodigo;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '000002'; --No se encontraron registros
						RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
					ELSE
						RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
					END IF
				ELSE
					LET cCodret = '000001'; --ParÃ¡metros de entrada vacÃ­os
					RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
				END IF
			ELSE 
				FOREACH
					SELECT {+INDEX ( bdinteg:"informix".si_sucservicios_rostro idx_si_sucservicios_rostro)}  empresa,sucursal,codigo,valor, descripcion 
					INTO   cEmpresa,cSucursal,cCodigo,cValor, cDescripcion
					FROM bdinteg:"informix".si_sucservicios_rostro
					WHERE empresa=pEmpresa
					AND sucursal=pSucursal
					
	    			if vcont < pEjecucion then
						 LET vcont = vcont + 1;
						 continue foreach;
					end if
     				LET vcont = vcont + 1;
					  
					RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion) WITH RESUME;
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '000002'; --No se encontraron registros
					RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
				END IF
			END IF;
		ELSE
			LET cCodret = '000001'; --ParÃ¡metros de entrada vacÃ­os
			RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
		END IF;
	END;
END PROCEDURE
DOCUMENT
' DESCRIPCION:	Se crea procedimiento para realizar consultas a la tabla si_sucservicios_rostro', 
' PROYECTO: 77.1 Biometria facial bancoppel alta de rostro', 
' MODIFICO : Leslie RendÃ³n',			
' FECHA : 2016/06/30',
' BD:  bdinteg ';

CREATE PROCEDURE "informix".sp_genera_archivosbatch_situaciones(pEmpresa CHAR(3), pFechaAct DATE) 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumTienda CHAR(4);
DEFINE cCveMov CHAR(1);
DEFINE cNumCte CHAR(20);
DEFINE cNumcteCoppel CHAR(20);
DEFINE cNumSol CHAR(20);
DEFINE cCveStatusSolicitante CHAR(1);
DEFINE iIdSituacion INTEGER;
DEFINE iNumEmp INTEGER;
DEFINE dFechaMov DATE;
DEFINE iNumCentro SMALLINT;
DEFINE iCveOrigen SMALLINT;
DEFINE cCvePuntualidadCte CHAR(1);
DEFINE iNumMotivoResp SMALLINT;
DEFINE iNumPersonaResp SMALLINT;
DEFINE cDesCtas CHAR(1);
DEFINE sSQL LVARCHAR (32000);
DEFINE iNumSec INTEGER;
DEFINE dFechaHoy DATE;
DEFINE cStatus CHAR(2);
DEFINE dtFechaHoraMax DATETIME  YEAR TO SECOND;
DEFINE dtFechaHora DATETIME  YEAR TO SECOND;
DEFINE cSitEsp CHAR(1);
DEFINE iCausaSitEsp SMALLINT;
DEFINE cFecha CHAR(10);

LET iSqlErr = 0;
LET cCodRet = '00005';
LET cNumTienda = '';
LET cCveMov = 'M';
LET cNumCte = '0';
LET cNumcteCoppel = '0';
LET cNumSol = '0';
LET cCveStatusSolicitante = '';
LET iIdSituacion = 0;
LET iNumEmp = 0;
LET dFechaMov  = DATE(1);
LET iNumCentro = 0;
LET iCveOrigen = 9;
LET cCvePuntualidadCte = '';
LET iNumMotivoResp = 0;
LET iNumPersonaResp = 0;
LET cDesCtas = '';
LET sSQL = '';
LET iNumSec = 0;
LET dFechaHoy  = DATE(1);
LET cStatus = '';
LET dtFechaHoraMax = CURRENT;
LET dtFechaHora = CURRENT;
LET cSitEsp = '';
LET iCausaSitEsp = 0;
LET cFecha = '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		rollback work;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
--  SET DEBUG FILE TO '/RESPALDOS/sp_genera_archivosbatch_situaciones_pba.out';
--  TRACE ON;

	IF NVL(pFechaAct,MDY(1,1,1900)) <> MDY(1,1,1900) AND NVL(pEmpresa,'') <> ''THEN
		SELECT fecha_hoy INTO dFechaHoy FROM "informix".si_fechas;
		IF NVL(dFechaHoy,MDY(1,1,1900)) <> MDY(1,1,1900) THEN
			UPDATE STATISTICS MEDIUM FOR TABLE si_archivoscopdiario_sitesp;
			SELECT NVL(secuencia_max,0) INTO iNumSec FROM "informix".si_archivosecuenciamax_sitesp;		
			--LET iNumSec = iNumSec + 1;
		
			FOREACH WITH HOLD

				SELECT DISTINCT NVL(sss.num_solicitud,''),NVL(sss.numcte,''),NVL(ssa.fecha_entrada,DATE(1)),
				NVL(sss.sucursal,'0'),NVL(sss.user_insert,0),NVL(ssa.status_solicitud,''),NVL(ssa.fecha_hora,'')
				INTO cNumSol,cNumCte,dFechaMov,cNumTienda,iNumEmp,cStatus,dtFechaHora
				FROM bdisolic:"informix".ss_autorizacion ssa,
				bdisolic:"informix".ss_solicitudes sss
				WHERE sss.num_solicitud = ssa.num_solicitud
				AND sss.empresa = ssa.empresa			
				AND ssa.status_solicitud = sss.status_solicitud
				AND ssa.fecha_entrada = pFechaAct
				AND sss.num_producto = '6500'
				AND ssa.status_solicitud IN('RT','AP')
				AND sss.sucursal=sss.sucursal
				AND sss.fecha_insert=sss.fecha_insert

				SELECT cliente
				INTO cNumcteCoppel
				FROM bdinteg:"informix".si_relacion_ctebcplcpl 
				WHERE  empresa = pEmpresa AND numcte_banco = cNumCte AND tipo_relacion <> 0 AND cliente_prosp <> '1';
				
				IF cStatus = 'RT' THEN
					LET cCveStatusSolicitante = 'R';
					LET cCvePuntualidadCte = '';
					LET iCveOrigen = 12;
					SELECT NVL(situacion_especial,''),NVL(causa_sitesp,0) INTO cSitEsp,iCausaSitEsp FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = cNumSol;
					IF (NVL(cSitEsp,'') = '' AND NVL(iCausaSitEsp,0) = 0) THEN
						CONTINUE FOREACH;
					ELSE
						SELECT {+INDEX (bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl idx_relsitespbcpl_cpl)} NVL(relsit.idu_situacion,0) INTO iIdSituacion 
						FROM bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl relsit, bdisolic:"informix".ss_nuevo_parametrico ctesup
						WHERE relsit.clv_situacion = ctesup.situacion_especial
						AND relsit.num_causasituacion = ctesup.causa_sitesp
						AND ctesup.num_solicitud = cNumSol;
					END IF;
				ELSE
					IF cStatus = 'AP' THEN
						LET cCveStatusSolicitante = '';
					ELSE
						LET cCveStatusSolicitante = '';
						LET iCveOrigen = 9;
					END IF;
					
					LET cCvePuntualidadCte = 'N';
					
					SELECT NVL(relsit.idu_situacion,0) INTO iIdSituacion 
					FROM bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl relsit, bdisolic:"informix".ss_os_solautdirecta solaut
					WHERE relsit.clv_situacion = solaut.situacionespecial
					AND relsit.num_causasituacion = solaut.causa
					AND solaut.situacionespecial='S' 
					AND solaut.causa=50 
					AND solaut.status='S'
					AND solaut.num_solicitud = cNumSol;
					
					
			END IF;
			
				IF cNumcteCoppel <> '' THEN
					LET cNumSol = '0';
				END IF;
			
				LET cFecha = YEAR(dFechaMov) || "/" || LPAD(MONTH(dFechaMov),2,'0') || "/" || LPAD(DAY(dFechaMov),2,'0');
				
				LET sSQL = TRIM(NVL(cNumTienda,'0'))||"|"||TRIM(cCveMov)||"|"||TRIM(NVL(cNumcteCoppel,'0'))||"|"||TRIM(NVL(cNumSol,'0'))||"|"||
				TRIM(NVL(cCveStatusSolicitante,''))||"|"||NVL(iIdSituacion,0)||"|"||NVL(iNumEmp,0)||"|"||cFecha||"|"||
				iNumCentro||"|"||iCveOrigen||"|"||TRIM(NVL(cCvePuntualidadCte,''))||"|"||iNumMotivoResp||"|"||iNumPersonaResp||"|"||TRIM(cDesCtas);
	
				begin work;
				
					INSERT INTO "informix".si_archivoscopdiario_sitesp(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
					VALUES (pEmpresa, iNumSec, cNumTienda, sSQL, cCveMov, pFechaAct);
					
					LET iNumSec = iNumSec + 1;
				
					UPDATE "informix".si_archivosecuenciamax_sitesp SET secuencia_max = iNumSec;
						
				commit work;
				
			END FOREACH;
			
			LET cCodRet = '00000';
		ELSE
			LET cCodRet = '00002';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'AUTOR: MIREYA REYES',
'FOLIO: 1739',
'DESCRIPCION: Se crea procedimiento almacenado para que inserte los movimientos de situaciones en la tabla: si_archivoscopdiario_sitesp',
'FECHA: 06/07/2015',
'VERSION: 20150706.1740',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_total_bitsmstelsms_bpi(pNumCliente CHAR(9))
   returning CHAR(5);
   
	-- Se clona stored procedure sp_total_bitsmstelsms para contabilizar las oportunidades de solicitud de clave nueva por sms pero en la tabla si_bitsmstelsms_bpi
	-- AUTOR : Keevyn Adrian Gil Valenzuela
	-- FECHA : 20/12/2016
	-- BD    : bdinteg

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE iContador INTEGER;
	
	LET cCodRet='00000';
	
  --SET DEBUG FILE TO "/tmp/sp_total_bitsmstelsms_bpi.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte) 
	INTO iContador 
	FROM bdinteg:"informix".si_bitsmstelsms_bpi 
	WHERE numcte =pNumCliente AND DATE(fecha)=DATE(CURRENT);
	IF iContador>=10 THEN
		LET cCodRet='00001';
	ELSE
		LET cCodRet='00000';
	END IF;

	RETURN cCodRet;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1616?BPI-ValidaNumeroCelular',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 30-11-2015',
'MODIFICACIÓN..: Se crea stored procedure para contabilizar las oportunidades de solicitud de clave nueva por sms',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG',
'FOLIO.........: 1631-BPILogin',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 12-02-2016',
'MODIFICACIÓN..: Se verifica si es id de usuario o numero de cliente',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sp_claveasocia_cta_cel(pNumCel CHAR(10))
											  
-- Genera una clave de confirmación para validar el número de celular que se desea asociar a una cuenta.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 16/11/2016
-- BD    : bdinteg

RETURNING
    CHAR(6);        -- CodigoRetorno
	

	-- Declarar variables 
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSql_err 	INTEGER;
	
	DEFINE cUno			CHAR(2);
	DEFINE cDos			CHAR(2);
	DEFINE cTres		CHAR(2);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	
	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_claveasocia_cta_cel.out";
	--TRACE ON;
	
	LET dHora = current hour to fraction;
	LET cUno = SUBSTR(pNumCel,3,2);
	LET cDos = SUBSTR(pNumCel,7,2);
	LET cTres = SUBSTR(dHora, 7,2);
	LET cCodRet = cUno || cDos || cTres;
	
		
	RETURN cCodRet;
	
END 
END PROCEDURE;