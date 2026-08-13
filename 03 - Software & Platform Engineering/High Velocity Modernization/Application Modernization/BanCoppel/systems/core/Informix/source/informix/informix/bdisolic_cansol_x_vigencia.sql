CREATE PROCEDURE "informix".cansol_x_vigencia(o_empresa  CHAR(3))

RETURNING CHAR(6);		--Codigo de Retorno

-- DEFINICION DE VARIABLES
DEFINE scod_ret			CHAR(6);
DEFINE vsqlerr			INTEGER;
DEFINE s_numsol			CHAR(20);
DEFINE cNumSolMov		CHAR(20);
DEFINE s_numcte			CHAR(20);
DEFINE s_fechaaut		DATE;
DEFINE s_status			CHAR(2);
DEFINE vfecha_hoy		DATE;
DEFINE sDias_Vigencia	SMALLINT;
DEFINE idias_v_causa	INTEGER;
DEFINE vAuxMensaje		VARCHAR(255,1);
DEFINE vAuxMensajeEVEN	VARCHAR(255,1);
DEFINE vAuxNuevoStatus	CHAR(2);
DEFINE iHuboErrores		INTEGER;
DEFINE iCuantos			INTEGER;
DEFINE iBanderaMarcar	INTEGER;
DEFINE dFechaInsert		DATE;
DEFINE cCausa_sol		CHAR(3);
DEFINE cProducto		CHAR(4);
DEFINE cStatusFinal		CHAR(2);
DEFINE cDescripcionCausa CHAR(100);
DEFINE cCausa_sol1		CHAR(3);
DEFINE sDias_Vigencia90	SMALLINT;
DEFINE sDias_VigenciaATGerente	SMALLINT;
DEFINE cDescrCausaCOA	CHAR(100);
DEFINE iCantOA 			INTEGER;
DEFINE cNumcte_pros		CHAR(20);
DEFINE cStatus_cte		CHAR(2);
DEFINE dFecha_Ent		DATE;
DEFINE sDias_Vig		SMALLINT;
DEFINE cStatus_Fin		CHAR(2);
DEFINE cCausa_Pros		CHAR(3);
DEFINE cComentario		CHAR(100);
DEFINE cEjecutivo		CHAR(8);
DEFINE scod_ret2		CHAR(6);

DEFINE 	sRelanParam    	SMALLINT;
DEFINE 	sRelanSol    	SMALLINT;
DEFINE 	sSumRelanSol 	SMALLINT;
DEFINE 	sRelanSolProsp 	SMALLINT;
DEFINE 	cCteProsp		CHAR(20);
DEFINE 	cNumCteBco		CHAR(20);
DEFINE  s_numsol_pros	CHAR(20);


DEFINE pcod_ret			CHAR(6);

-- ASIGNACION DE VARIABLES
LET scod_ret	= "000000";
LET vsqlerr		= 0;
LET s_numcte		= "??????????";
LET s_fechaaut		= "";
LET s_status		= "??";
LET s_numsol		= "??????????";
LET cNumSolMov		= "";
LET vfecha_hoy		= "";
LET sDias_Vigencia	= 0;
LET cCausa_sol		= '';
LET idias_v_causa	= 0;
LET vAuxMensaje		= '';
LET vAuxNuevoStatus	= '';
LET cProducto		= '';
LET iCuantos = 0;
LET cStatusFinal		= '';
LET cDescripcionCausa	= '';
LET cCausa_sol1			= '';
LET dFechaInsert		= DATE(1);
LET vAuxMensajeEVEN		= 'Cancelada por Vigencia de Cancelacion';
LET iHuboErrores		= 0;
LET iBanderaMarcar		= 0;
LET sDias_Vigencia90	= 0;
LET sDias_VigenciaATGerente	= 0;
LET cDescrCausaCOA		= '';
LET iCantOA				= 0;
LET cNumcte_pros	= "";
LET cStatus_cte		= "";
LET dFecha_Ent		=DATE(1);
LET sDias_Vig		= 0;
LET cStatus_Fin		= "";
LET cCausa_Pros		= "";
LET cComentario		= "";
LET cEjecutivo		= "";
LET scod_ret2		= "";

LET sRelanParam    	 = 0;
LET sRelanSol    	 = 0;
LET sSumRelanSol 	    = 0;
LET sRelanSolProsp 		= 0;
LET cCteProsp			="";
LET cNumCteBco			="";
LET s_numsol_pros		="";
LET pcod_ret	= "100000"; -- codigo de error cuando fecha_sic sea nula

--Set debug file to '/informix/Malena/cansol_x_vigencia.out';
--trace on;

--SET DEBUG file to '/RESPALDOS/ipcb/pbas2/cansol_x_vigencia_NVO.out';   TRACE ON;
--SET DEBUG file to '/home/e10000315/aldo/trace/cansol_x_vigencia.out';
--trace on;
BEGIN
	ON EXCEPTION SET vsqlerr 
		LET scod_ret = vsqlerr;
		RETURN scod_ret;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	--Carga la Fecha del Dia
	SELECT fecha_hoy
	INTO vfecha_hoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = o_empresa;

	--Obtenemos los dias de vigencia de la solicitud para Estatus OA
	SELECT NVL(dias_vigencia_sol,0) 
	INTO sDias_Vigencia90
	FROM bdisolic:"informix".ss_status_sol
	WHERE status_solicitud = 'OA';
	
	--Obtenemos descripcion de causa COA
	SELECT descripcion
			INTO cDescrCausaCOA
			FROM bdisolic:"informix".ss_causas_sol
			WHERE causa_solicitud = 'COA';

		--Obtenemos descripcion de causa COA
		SELECT valor
			INTO sDias_VigenciaATGerente
		FROM bdisolic:"informix".ss_param
		WHERE secuencia = 377;

	FOREACH WITH HOLD
		SELECT trim(a.num_solicitud)
		INTO s_numsol_pros
		FROM bdisolic:"informix".ss_solicitudes a, 
			bdisolic:"informix".ss_anexosol b, 
            bdisolic:"informix".ss_prospecteo_solicitudes c
		WHERE a.status_solicitud = 'PA'
		AND a.empresa = o_empresa
		AND b.empresa = a.empresa
		AND b.num_solicitud = a.num_solicitud
		and a.num_solicitud = c.num_solicitud
        AND a.num_producto = c.num_producto
		and a.num_producto in('6001','6300','6400','6800','7600','7700','7800','8500','8100')
        AND c.canal_sol = 0
		and c.fecha < vfecha_hoy

		IF 	NVL(s_numsol_pros,"") <> ""  THEN
			LET vAuxNuevoStatus = 'CN';
			LET cCausa_sol = 'CV';
			LET vAuxMensaje = 'Cancelada por vigencia terminada en estatus PA /AT';
			
			BEGIN WORK;
			
			EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema', s_numsol_pros, vAuxNuevoStatus, cCausa_sol,vAuxMensaje) Into scod_ret;
			
			
				IF scod_ret = '000000' THEN
					UPDATE bdisolic:"informix".ss_prospecteo_solicitudes SET estatus='C', status_solicitud= vAuxNuevoStatus  WHERE num_solicitud=s_numsol_pros;
					COMMIT WORK;
				
				ELSE
					ROLLBACK WORK;

					BEGIN WORK;
					INSERT INTO bdisolic:"informix".ax_paso (NOM_SPL, ERROR, INFO) VALUES ("cansol_x_vigencia", scod_ret, CURRENT ||" Solicitud "||TRIM(s_numsol_pros));
					COMMIT WORK;

					--LET iHuboErrores = '1';
					--- OBTIENE ERROR DE DUPLICADOS PARA CONTINUAR CON LA EJECUCION DEL PROCESO
					IF scod_ret = '-284' THEN
						LET scod_ret = '000000';
						CONTINUE FOREACH;
					ELSE 
						ROLLBACK WORK;
						LET iHuboErrores = '1';
					END IF;
				END IF;		
		END IF;
	END FOREACH;

	FOREACH WITH HOLD
		SELECT trim(a.num_solicitud), a.numcte, b.fecha_ult_mod,a.status_solicitud, a.fecha_insert , a.num_producto
		INTO s_numsol, s_numcte, s_fechaaut, s_status, dFechaInsert, cProducto
		FROM bdisolic:"informix".ss_solicitudes a, 
			bdisolic:"informix".ss_anexosol b, 
            bdisolic:"informix".ss_vigencia_sol_productos c
		WHERE a.status_solicitud IN ('AT','RT','CE','EE','OS','BC','CC','EC','PA','IN','CP','TC') --se agregan status BC y CC -JMAH/RQM 18 023 -- Se agrega estatus IN (MACF RQI 21 256, 20210820)
		AND a.empresa = o_empresa
		AND b.empresa = a.empresa
		AND a.empresa = c.empresa
		AND b.num_solicitud = a.num_solicitud
        AND a.num_producto = c.num_producto
        AND a.status_solicitud = c.status_solicitud
        AND b.fecha_ult_mod < vfecha_hoy - dias_vigencia
        union all
		SELECT trim(a.num_solicitud) num_solicitud, a.numcte, b.fecha_ult_mod,a.status_solicitud, a.fecha_insert , a.num_producto
		FROM bdisolic:"informix".ss_solicitudes a, 
			 bdisolic:"informix".ss_anexosol b
		WHERE a.status_solicitud in ('CM','OA')
		AND a.empresa = o_empresa
		AND b.empresa = a.empresa
		AND b.num_solicitud = a.num_solicitud

		
		LET iBanderaMarcar = 0;
		LET vAuxNuevoStatus = '';
		LET scod_ret = '000000';

		IF s_fechaaut IS NULL THEN
			SELECT MAX(fecha_entrada), COUNT(empresa)
			INTO s_fechaaut, iCuantos
			FROM bdisolic:"informix".ss_autorizacion
			WHERE empresa = o_empresa
			AND num_solicitud = s_numsol
			AND status_solicitud = s_status;

			IF iCuantos = 0 THEN
				LET s_fechaaut = dFechaInsert;
			END IF;
			
			LET iBanderaMarcar = 1;
		END IF;
		
		SELECT NVL(dias_vigencia, 0), status_solicitud_final, causa_solicitud, descripcion
			INTO sDias_Vigencia, cStatusFinal, cCausa_sol1, cDescripcionCausa
			FROM bdisolic:"informix".ss_vigencia_sol_productos
			WHERE status_solicitud = s_status
			AND num_producto= cProducto;
		
		IF s_status = "CM" THEN
			SELECT NVL(a.causa_solicitud,''), NVL(b.dias_vigencia,0) 
			INTO cCausa_sol, idias_v_causa
			FROM bdisolic:"informix".ss_autorizacion a, bdisolic:"informix".ss_causas_sol b
			WHERE a.empresa = o_empresa
			AND a.empresa = b.empresa 
			AND a.num_solicitud = s_numsol 
			AND a.status_solicitud = s_status 
			AND a.status_solicitud = b.status_solicitud
			AND a.causa_solicitud = b.causa_solicitud
			AND a.ROWID = ( SELECT MAX(ROWID) FROM bdisolic:"informix".ss_autorizacion 
							WHERE empresa = a.empresa
							AND num_solicitud = a.num_solicitud
							AND status_solicitud = a.status_solicitud);

			IF cCausa_sol IN ( "CMC","CVE", "CME", "CEV" ) AND (s_fechaaut < vfecha_hoy - idias_v_causa) THEN
				LET vAuxMensaje     = vAuxMensajeEVEN;
				LET vAuxNuevoStatus = 'CN';
				LET cCausa_sol = 'CVC';
				
			END IF;
		
		ELIF s_status = "RT" THEN
			SELECT NVL(a.causa_solicitud,''), NVL(b.dias_vigencia,0) 
			INTO cCausa_sol, idias_v_causa
			FROM bdisolic:"informix".ss_autorizacion a, bdisolic:"informix".ss_causas_sol b
			WHERE a.empresa = o_empresa
			AND a.empresa = b.empresa 
			AND a.num_solicitud = s_numsol 
			AND a.status_solicitud = s_status 
			AND a.status_solicitud = b.status_solicitud
			AND a.causa_solicitud = b.causa_solicitud
			AND a.ROWID = ( SELECT MAX(ROWID) FROM bdisolic:"informix".ss_autorizacion 
							WHERE empresa = a.empresa
							AND num_solicitud = a.num_solicitud
							AND status_solicitud = a.status_solicitud);

			IF cCausa_sol IN ('RCB') AND (s_fechaaut <= vfecha_hoy - idias_v_causa) THEN
				LET vAuxMensaje     = cDescripcionCausa;
				LET vAuxNuevoStatus = cStatusFinal;
				LET cCausa_sol = cCausa_sol1;
			ELIF cCausa_sol <> 'RCB' AND (s_fechaaut < vfecha_hoy - sDias_Vigencia) THEN
				LET vAuxMensaje     = cDescripcionCausa;
				LET vAuxNuevoStatus = cStatusFinal;
				LET cCausa_sol = cCausa_sol1;
				
			END IF;
			
		ELSE
		
			IF s_status = "OA" THEN

				--Para obtener los reenvios en OA
				SELECT COUNT(*) 
				INTO iCantOA
				FROM bdisolic:"informix".ss_autorizacion
				WHERE num_solicitud = s_numsol
				AND status_solicitud = s_status;
				
				LET sRelanSolProsp 		= 0; -- LIMPIA VARIABLE 

                --OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
                SELECT numcte
                INTO cNumCteBco					
                FROM "informix".ss_solicitudes
                WHERE num_solicitud = s_numsol;

                IF 	NVL(cNumCteBco,"") <> ""  THEN

                    SELECT numcte_pros
                    INTO cCteProsp
                    FROM bdiprospectos:"informix".pr_cliente 
                    WHERE empresa = o_empresa 
                        AND numcte = cNumCteBco
                        AND tipo_cliente = 3;

                    IF NVL(cCteProsp,"") <> "" THEN

                        SELECT COUNT(num_solicitud)
                        INTO sRelanSolProsp
                        FROM bdiprospectos:"informix".pr_autorizacion
                        WHERE empresa = o_empresa 
                        AND num_solicitud = cCteProsp
                        AND status_solicitud = 'OA';
                    END IF;	
                END IF;	
                
                LET sSumRelanSol = iCantOA + NVL(sRelanSolProsp ,0) ;

				IF (sSumRelanSol >= 3) OR (dFechaInsert < vfecha_hoy - sDias_Vigencia90) OR (s_fechaaut < vfecha_hoy - sDias_Vigencia) THEN
					LET vAuxMensaje = cDescrCausaCOA;
					LET vAuxNuevoStatus = 'CN';
					LET cCausa_sol = 'COA';	
				END IF;
			ELSE
				
				IF s_status  = "AT" THEN 
					SELECT NVL(a.causa_solicitud,'')
						INTO cCausa_sol
					FROM bdisolic:"informix".ss_autorizacion a, 
					bdisolic:"informix".ss_causas_sol b
					WHERE a.empresa = o_empresa
					AND a.empresa = b.empresa 
					AND a.num_solicitud = s_numsol 
					AND a.status_solicitud = s_status 
					AND a.status_solicitud = b.status_solicitud
					AND a.causa_solicitud = b.causa_solicitud
					AND b.tipo_auto ='3'
					AND a.ROWID = ( SELECT MAX(ROWID) FROM bdisolic:"informix".ss_autorizacion 
							WHERE empresa = a.empresa
							AND num_solicitud = a.num_solicitud
							AND status_solicitud = a.status_solicitud);

					IF (SELECT COUNT(*)
						FROM bdinteg:"informix".si_telefonos
						WHERE numcte = s_numcte
						AND tipo_tel in (1,2) 
						AND status_tel = 'A' 
						AND NVL(verificado,'F') = 'V') >= 1 THEN				
				
						IF NVL(cCausa_sol,"") <> "" THEN
							LET sDias_Vigencia = sDias_VigenciaATGerente;
						ELSE 							
							LET sDias_Vigencia = sDias_Vigencia;
						END IF;
					ELSE
						LET sDias_Vigencia=sDias_VigenciaATGerente;
				    END IF;
					
				END IF;
				
			
			
					--IF DBINFO("sqlca.sqlerrd2") > 0 AND (s_fechaaut < vfecha_hoy - sDias_Vigencia) THEN
				IF s_status = "CE" THEN
					 UPDATE "informix".ss_solicitud_os SET status='C' WHERE  num_solicitud = s_numsol;
				END IF
				
				--IPCB / Para las solicitudes BC y CC con la fecha_Sic null, se cierra con date(1)=1/01/1900
				IF s_status = 'BC' OR s_status = 'CC' THEN			
					IF EXISTS (SELECT fecha_sic  FROM "informix".ss_solicitudes_sic WHERE numcte = s_numcte and num_Solicitud = s_numsol and fecha_sic is null) THEN
						UPDATE "informix".ss_solicitudes_sic set fecha_sic = date (1) WHERE numcte = s_numcte and num_Solicitud = s_numsol and fecha_sic is null;					
					END IF
				END IF
				
				
				IF s_fechaaut < vfecha_hoy - sDias_Vigencia THEN
					LET vAuxMensaje     = cDescripcionCausa;
					LET vAuxNuevoStatus = cStatusFinal;
					LET cCausa_sol = cCausa_sol1;
				END IF;
			END IF;	

		END IF;

		IF vAuxNuevoStatus <> '' OR iBanderaMarcar > 0 THEN

			BEGIN WORK;
			IF vAuxNuevoStatus <> '' THEN --dar prioridad al cambio de status
				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema', s_numsol, vAuxNuevoStatus, cCausa_sol,vAuxMensaje) Into scod_ret;
				
				INSERT INTO "informix".ss_detalle_scoring_hist(empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor,fecha_insert)
					SELECT empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor,vfecha_hoy from bdisolic:ss_detalle_scoring where empresa = o_empresa and num_solicitud = s_numsol;
		 
				DELETE bdisolic:ss_detalle_scoring  where empresa = o_empresa and num_solicitud = s_numsol;
				--VVVF
					IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = s_numcte and num_Solicitud = s_numsol and fecha_sic is null) THEN
						UPDATE bdisolic:"informix".ss_solicitudes_sic set fecha_sic = date (1) WHERE numcte = s_numcte and num_Solicitud = s_numsol and fecha_sic is null;
						 
						INSERT INTO bdisolic:"informix".ax_paso (NOM_SPL, ERROR, INFO) VALUES ("cansol_x_vigencia", pcod_ret, CURRENT ||" Fch SIC null "||TRIM(s_numsol));
 						
					END IF
				
			ELSE --entonces iBanderaMarcar > 0
				UPDATE bdisolic:"informix".ss_anexosol
				SET fecha_ult_mod = s_fechaaut
				WHERE empresa = o_empresa
				AND num_solicitud = s_numsol;
			END IF;
			
            SELECT num_solicitud
            INTO cNumSolMov
            FROM bdisolic:"informix".ss_solicitudes_movil 
            WHERE empresa = o_empresa
            and num_solicitud = s_numsol
			group by 1;

			IF NVL(cNumSolMov,'') <> '' THEN 
				UPDATE bdisolic:"informix".ss_solicitudes_movil
				SET status = '3'
				WHERE empresa = o_empresa
				AND num_solicitud = s_numsol;
			END IF;
			
			IF SUBSTR(s_numsol,1,2)=  '78' THEN 
				UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
				SET num_solicitud = '',linea=0, frecuencia_pgo=0 ,dia_pago=0
				WHERE empresa = o_empresa
				AND num_solicitud = s_numsol;
			END IF;
			
			
			IF scod_ret = '000000' THEN
				--LET scod_ret = '000';
				COMMIT WORK;
			ELSE

				ROLLBACK WORK;

				BEGIN WORK;
				INSERT INTO bdisolic:"informix".ax_paso (NOM_SPL, ERROR, INFO) VALUES ("cansol_x_vigencia", scod_ret, CURRENT ||" Solicitud "||TRIM(s_numsol));
				COMMIT WORK;

				--LET iHuboErrores = '1';
				--- OBTIENE ERROR DE DUPLICADOS PARA CONTINUAR CON LA EJECUCION DEL PROCESO
				IF scod_ret = '-284' THEN
					LET scod_ret = '000000';
					CONTINUE FOREACH;
				ELSE 
					ROLLBACK WORK;
					LET iHuboErrores = '1';
				END IF;
			END IF;
		END IF;
	END FOREACH;


   --PROSPECTOS
    FOREACH WITH HOLD
		-- SE OBTIENE EL CLIENTE, ESTATUS,LA FECHA EN QUE ENTRÃ?Â?Ã?Â?Ã?Â?Ã?Â? EN ESE ESTATUS EL CLIENTE Y EL EJECUTIVO QUE REALIZÃ?Â?Ã?Â?Ã?Â?Ã?Â? EL REGISTRO
        -- Y DIAS DE VIGENCIA QUE CUENTE CON UN ESTATUS DE ss_vigencia_sol_productos
		
        SELECT FIRST 50000 trim(a.numcte_pros),a.status_numcte_pros, b.dias_vigencia, d.fecha_entrada, d.ejecutivo_auto, b.status_solicitud_final, b.causa_solicitud,b.descripcion
		INTO cNumcte_pros,cStatus_cte, sDias_Vig, dFecha_Ent,cEjecutivo,cStatus_Fin, cCausa_Pros, cComentario
		FROM bdiprospectos:"informix".pr_cliente a
		INNER JOIN bdisolic:"informix".ss_vigencia_sol_productos b ON (a.status_numcte_pros = b.status_solicitud)
        INNER JOIN bdiprospectos:"informix".pr_autorizacion d ON (d.num_solicitud=a.numcte_pros AND b.status_solicitud=d.status_solicitud)
        WHERE b.num_producto='PROS' AND a.status_numcte_pros in('AT','RT','EC','EE','CE','OA','OS')
        AND d.fecha_entrada =	(SELECT MAX(fecha_entrada) 
									FROM bdiprospectos:"informix".pr_autorizacion 
									WHERE num_solicitud = a.numcte_pros
									AND status_solicitud = a.status_numcte_pros)
        AND d.fecha_entrada < (vfecha_hoy - b.dias_vigencia)     
       

        -- SI EL ESTATUS CUENTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
        IF NVL(sDias_Vig,0) > 0 THEN            
           
            BEGIN WORK;
            -- SE CAMBIA EL ESTATUS DENTRO DE pr_autorizacion Y pr_cliente, SE REUTILIZA PRODECIMIENTO 
            EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus('sistema', cNumcte_pros, cStatus_Fin, cCausa_Pros,cComentario)
            INTO scod_ret2;

            IF scod_ret2 = '000000' THEN
				LET scod_ret = scod_ret2;
				COMMIT WORK;
			ELSE

				ROLLBACK WORK;

				BEGIN WORK;
				INSERT INTO bdisolic:"informix".ax_paso (NOM_SPL, ERROR, INFO) VALUES ("cansol_x_vigencia PR", scod_ret2, CURRENT ||" Solicitud "||TRIM(cNumcte_pros));
				COMMIT WORK;

				--LET iHuboErrores = '1';
			END IF;

        ELSE
            -- SI EL ESTATUS DE EL CLIENTE NO EXISTE EN EL CATÃ?Â?Ã?Â?Ã?Â?Ã?Â?LAGO DE VIGENCIA SE PASA AL SIGUIENTE REGISTRO
            CONTINUE FOREACH;
        END IF;
		
	END FOREACH;

	IF iHuboErrores = 0 THEN
		RETURN scod_ret;
	ELSE
		RETURN '1';
	END IF; 
END;
END PROCEDURE
