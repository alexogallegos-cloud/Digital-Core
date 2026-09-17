CREATE PROCEDURE "informix".sp_consultaderechosvariosgdf_bpi(pId CHAR(2))
-- DESCRIPCION: CONSULTA TRAMITE
-- AUTOR: ING. CRUZ
-- FECHA: 10-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cTramite CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cTramite =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consultaderechosvariosgdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cTramite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT concepto
	INTO cTramite
	FROM bdisac:"informix".sac_catderechosvariosgdf
	WHERE id = pId;
	
	IF (cTramite is NULL) OR (TRIM(cTramite)=='') THEN
		LET cCodRet = '00001';
		--EL TRAMITE NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cTramite;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 10-05-2013",
"Descripcion: Consulta el campo tramite del catalogo de trÃ¡mites.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_bitacora_proceso(p_tipo VARCHAR(10), p_id_proceso INTEGER, p_id_subproceso INTEGER, p_nombre_proceso VARCHAR(100),
												p_nombre_subproceso VARCHAR(100), p_usuario CHAR(8))
												RETURNING INTEGER AS v_id_proceso, INTEGER AS v_id_subproceso;
												
	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE iCuenta					INTEGER;
	DEFINE iCuenta2					INTEGER;
	DEFINE iIdProceso				INTEGER;
	DEFINE cSubproceso				CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE v_id_proceso				INTEGER;
	DEFINE v_id_subproceso			INTEGER;
	DEFINE v_sql					CHAR(1000);
	DEFINE vstmt					CHAR(250);
	
	LET iCuenta						= 0;
	LET iCuenta2					= 0;
	LET v_id_proceso				= 0;
	LET v_sql						= '';
	LET vstmt						= '';
	
	--SET DEBUG FILE TO "/tmp/adrian/sp_bitacora_proceso.out";
	--TRACE ON;
	
	BEGIN
		
		ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
			IF isqlerr <> 0 THEN
				LET cCodRet = isqlerr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sp_bitacoraspj");
			END IF;
		END EXCEPTION;
		
		IF p_tipo = 'ACTUALIZA' THEN
		
			IF NOT ((p_id_proceso <= 0 OR p_id_proceso IS NULL) OR (p_nombre_proceso = '' OR p_nombre_proceso IS NULL)
			OR (p_nombre_subproceso = '' OR p_nombre_subproceso IS NULL) OR (p_usuario = '' OR p_usuario IS NULL)) THEN
			
				IF p_id_subproceso = 0 THEN
					
					SELECT NVL(MAX(id_subproceso),0)+1
					INTO   iCuenta2
					FROM   bdisac:"informix".sac_monitor
					WHERE  id_proceso  = p_id_proceso;
					
					LET p_id_subproceso = iCuenta2;
				
					--INSERT INTO bdisac:"informix".sac_monitor (id_proceso, id_subproceso, nombre_proceso, nombre_subproceso, usuario, fecha_ini_corrida)
					--VALUES (p_id_proceso, p_id_subproceso, p_nombre_proceso, p_nombre_subproceso, p_usuario, CURRENT);
					
					LET v_sql = 'echo " INSERT INTO bdisac:sac_monitor (id_proceso,  id_subproceso, nombre_proceso, nombre_subproceso, ' || 
				    'usuario, fecha_ini_corrida) VALUES '||
                    '('''||p_id_proceso||''', '''||p_id_subproceso||''', '''||TRIM(p_nombre_proceso)||''', '''||TRIM(p_nombre_subproceso)||''', '''||p_usuario||''','||
                    '(SELECT CURRENT FROM bdisac:sac_fechas));" > /tmp/inserta_bitacora_proceso_1.sql';
					SYSTEM v_sql;
					
					LET vstmt = 'dbaccess bdisac /tmp/inserta_bitacora_proceso_1.sql';
					SYSTEM vstmt;
				
				ELSE
				
					--UPDATE bdisac:"informix".sac_monitor
					--SET    fecha_fin_corrida = CURRENT
					--WHERE  id_proceso        = p_id_proceso
					--AND    id_subproceso     = p_id_subproceso;
					
					LET v_sql = 'echo " UPDATE bdisac:sac_monitor ' ||
					' SET fecha_fin_corrida = (SELECT CURRENT FROM bdisac:sac_fechas) ' || 
				    ' WHERE id_proceso = '''||p_id_proceso||''' '||
					' AND   id_subproceso = '''||p_id_subproceso||''';" > /tmp/inserta_bitacora_proceso_2.sql';
					SYSTEM v_sql;
					
					LET vstmt = 'dbaccess bdisac /tmp/inserta_bitacora_proceso_2.sql';
					SYSTEM vstmt;
				
				END IF;
			
			END IF;
			
		ELIF p_tipo = 'ALTA' THEN
			
			IF NOT ((p_nombre_proceso = '' OR p_nombre_proceso IS NULL) OR (p_usuario = '' OR p_usuario IS NULL)) THEN
		
				SELECT NVL(MAX(id_proceso)+1,1)
				INTO   iIdProceso
				FROM   bdisac:"informix".sac_monitor;
				
				LET cSubproceso = 'INICIA PROCESO';
				LET p_id_subproceso = 1;
				
				--INSERT INTO sac_monitor (id_proceso,  id_subproceso, nombre_proceso, nombre_subproceso, usuario, fecha_ini_corrida, fecha_fin_corrida)
				--VALUES (iIdProceso, p_id_subproceso, p_nombre_proceso, cSubproceso, p_usuario, CURRENT, CURRENT);
				
				LET v_sql = 'echo " INSERT INTO bdisac:sac_monitor (id_proceso,  id_subproceso, nombre_proceso, nombre_subproceso, ' || 
				'usuario, fecha_ini_corrida, fecha_fin_corrida) VALUES '||
                '('''||iIdProceso||''', '''||p_id_subproceso||''', '''||TRIM(p_nombre_proceso)||''', '''||TRIM(cSubproceso)||''', '''||p_usuario||''','||
                '(SELECT CURRENT FROM bdisac:sac_fechas), (SELECT CURRENT FROM bdisac:sac_fechas));" > /tmp/inserta_bitacora_proceso.sql';
				SYSTEM v_sql;
				
				LET vstmt = 'dbaccess bdisac /tmp/inserta_bitacora_proceso.sql';
				SYSTEM vstmt;
				
				LET p_id_proceso = iIdProceso;
					
			END IF;
		
		END IF;
		
		LET v_id_proceso    = p_id_proceso;
		LET v_id_subproceso = p_id_subproceso;
		
		RETURN v_id_proceso, p_id_subproceso;

	END;
END PROCEDURE;