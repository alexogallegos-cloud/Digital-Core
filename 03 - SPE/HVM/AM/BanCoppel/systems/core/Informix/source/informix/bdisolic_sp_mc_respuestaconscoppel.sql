CREATE PROCEDURE "informix".sp_mc_respuestaconscoppel(  pEmpresa CHAR(3), 
														pNumCte CHAR(20),															
														pNumcte_ref CHAR(20),
														pPuntualidad CHAR(3),
														pEficiencia DECIMAL(5,2),
														pLimitecredito INTEGER,
														pMeseshist INTEGER,
														pSdoropa INTEGER,
														pSdomuebles INTEGER,
														pSdoprestamos INTEGER,
														pVdoropa INTEGER,
														pVdomuebles INTEGER,
														pVdoprestamos INTEGER,
														pAbonomesropa INTEGER,
														pAbonomesmuebles INTEGER,
														pAbonomesprestamos INTEGER,
														pSdotiempoaire INTEGER,
														pSdonegociosafi INTEGER,
														pSdotiemporeestruc INTEGER,
														pVdotiempoaire INTEGER,
														pVdonegociosafi INTEGER,
														pVdotiemporeestruc INTEGER,
														pAbonomestiempoaire INTEGER,
														pAbonomesnegociosafi INTEGER,
														pAbonomestiemporeestruc INTEGER,
														pSitespecial CHAR(2),
														pCausa SMALLINT,
														pCreditoaut INTEGER,	
														pFecha_ult_compra DATE,
														pNombreCop CHAR(104),
														pFechaNacCop DATE)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION,
	DECIMAL(14,6) AS vencido,
	CHAR(100) AS des_sitesp,
	DECIMAL(14,6) AS abono_mes;	--AAME RQM 09 333 Se agrega nuevo retorno para el abono mensual del cliente.

-- Modificado por Maria Elena Angulo (AAME). 30 Agosto 2013 Se modifica para sumar los valores abonos del cliente 
-- recibidos como respuesta de la consulta a coppel, para devolvernos en un nuevo retorno "abono_mes".		
	
---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cMensajeRet		CHAR(80);
DEFINE iSecuencia       SMALLINT;
DEFINE dabonbase        DECIMAL(14,6);
DEFINE dAbonosVen       DECIMAL(14,6);
DEFINE dAbonoMes        DECIMAL(14,6); --AAME RQM 09 333 Se define nueva variable para el abono mensual del cliente.
DEFINE cDesCausa   		CHAR(100);
DEFINE dVencidocoppel   DECIMAL(14,6);
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cDesCausa			= '000000';
LET cMensajeRet			= 'Proceso Exitoso';
LET iSecuencia     		= 0;
LET dabonbase     		= 0;
LET dAbonosVen       	= 0;
LET dAbonoMes           = 0; --AAME RQM 09 333 Se inicializa nueva variable para el abono mensual del cliente.
LET dVencidocoppel      = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
		  --AAME RQM 09 333 Se agrega la nueva variable a retornar.
          RETURN cCodRet, cMensajeRet,dAbonosVen,cDesCausa,NVL(dAbonoMes,0.00);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO "/informix/jesus/sp_mc_respuestaconscoppel.out";
	--TRACE ON;
	--SI EL ESTADO DEVUELTO FUE ESTADO CORRECTO SE GRABA LA INFORMACION RECIBIDA POR EL SERVICIO EN LA TABLA QUE GRABA LA RESPUESTA.
	
	SELECT  NVL(MAX(secuencia),0) + 1
	INTO iSecuencia
	FROM "informix".ss_respuesta_conscoppel	
	WHERE empresa = pEmpresa AND numcte = pNumCte AND  numcte_ref = pNumcte_ref;
	
	IF iSecuencia > 1 THEN	
		INSERT INTO "informix".ss_respuesta_conscoppel_hist
		SELECT *  FROM "informix".ss_respuesta_conscoppel
		WHERE empresa = pEmpresa
		AND numcte = pNumCte 
		AND  numcte_ref = pNumcte_ref;
		
		DELETE  FROM "informix".ss_respuesta_conscoppel WHERE empresa = pEmpresa AND numcte = pNumCte AND  numcte_ref = pNumcte_ref;
	END IF;
	
	INSERT INTO "informix".ss_respuesta_conscoppel(secuencia,empresa,numcte,numcte_ref,puntualidad,eficiencia,limitecredito,meseshist,sdoropa,sdomuebles,sdoprestamos,vdoropa,vdomuebles,vdoprestamos,abonomesropa,abonomesmuebles, abonomesprestamos,sitespecial,causa,creditoaut,fecha_ult_compra,fecha_insert,nombrecop,fechanaccop,fecha_consulta,sdotiempoaire,sdonegociosafi,sdotiemporeestruc,vdotiempoaire,vdonegociosafi,vdotiemporeestruc,abonomestiempoaire,abonomesnegociosafi,abonomestiemporeestruc) 
	VALUES(iSecuencia,pEmpresa,pNumCte,pNumcte_ref,pPuntualidad,pEficiencia,pLimitecredito,pMeseshist,pSdoropa,pSdomuebles,pSdoprestamos,pVdoropa,pVdomuebles,pVdoprestamos,pAbonomesropa,pAbonomesmuebles,pAbonomesprestamos,pSitespecial,pCausa,pCreditoaut,pFecha_ult_compra::DATE ,today,pNombreCop,pFechaNacCop::DATE,today,pSdotiempoaire,pSdonegociosafi,pSdotiemporeestruc,pVdotiempoaire,pVdonegociosafi,pVdotiemporeestruc,pAbonomestiempoaire,pAbonomesnegociosafi,pAbonomestiemporeestruc);	

	LET dVencidocoppel = (pVdoropa + pVdomuebles + pVdoprestamos + pVdotiempoaire + pVdonegociosafi + pVdotiemporeestruc);
	LET dabonbase = (pAbonomesropa + pAbonomesmuebles + pAbonomesprestamos + pAbonomestiempoaire + pAbonomesnegociosafi + pAbonomestiemporeestruc);
	LET dAbonosVen = CASE WHEN dabonbase <= 0 THEN 0 ELSE dVencidocoppel / dabonbase END;
	
	IF NVL(pSitespecial,'' ) <> '' AND NVL(pCausa,0) <> 0 THEN
	--obtiene la descripcion de la causa 
		SELECT {+INDEX(bdisitesp:se_catsitesp idx_catsitesp)} descripcion
			INTO  cDesCausa
		FROM bdisitesp:"informix".se_catsitesp
		WHERE situacion = TRIM(pSitespecial)
		AND causa = pCausa;						
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			SELECT descripcion 
				INTO cDesCausa 
			FROM bdicred:"informix".sd_situacion_cred 
			WHERE situacion = TRIM(pSitespecial);		
		END IF;
	END IF;
	--AAME RQM 09 333 Se agrega a la nueva variable la sumatoria del total de abonos que tuvo en coppel el cliente.
	--LET dAbonoMes = (pAbonomesropa + pAbonomesmuebles + pAbonomesprestamos); 
	  LET dAbonoMes = (pAbonomesropa + pAbonomesmuebles + pAbonomesprestamos + pAbonomestiempoaire + pAbonomesnegociosafi + pAbonomestiemporeestruc);
	--AAME RQM 09 333 Se agrega la nueva variable a retornar.
	RETURN cCodRet, cMensajeRet,dAbonosVen,cDesCausa,NVL(dAbonoMes,0.00);
END
END PROCEDURE
