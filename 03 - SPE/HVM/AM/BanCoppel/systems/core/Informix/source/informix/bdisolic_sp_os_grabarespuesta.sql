CREATE PROCEDURE "informix".sp_os_grabarespuesta(
    psecuencia integer, pnum_solicitud varchar(20), pfechaimpresion date,
    pfecharespuesta date, pusuariogestor char(40), pclave char(1), psituacionespecial char(1),
    pcausasituacionespecial smallint, pfechasolicitud date, ptiendaimpresion integer
)
RETURNING CHAR(5);

--Procedimiento usado para guardar las respuestas de OS devueltas por Coppel a BanCoppel
--Fecha: 15-01-2007  Autor: Juan A. Coronel M.

--ModificaciÃÂ³n: 28-03-2007  ModificÃÂ³    : Juan A. Coronel M.
--Cambio      : Aplicar conversiones de estatus, segun causa y situacion especial, solicitado por BanCoppel.

--ModificaciÃÂ³n: 07-06-2007 ModificÃÂ³    : Juan A. Coronel M.
--Cambio      : Que reciba como parametro la tiENDa donde se imprime la OS. Se almacena en campo estatusOs de ss_osclientesupervisar.

--ModificaciÃÂ³n: 21-06-2007 ModificÃÂ³    : Juan A. Coronel M.
--Cambio      : Que la OS cuya respuesta tenga situacion 'P' con causa 46, pase de ser Ratificada a ser No ratificada, a peticiÃÂ³n de Tomas Gutierrez.

--ModificaciÃÂ³n: 07-08-2007 ModificÃÂ³    : Aymme Osuna
--Cambio      : CuANDo como respuesta de la OS se reciba una causa 25 ÃÂ³ 26 se debe hacer caso omiso al tipo de causa es decir, 'P'

--ModificaciÃÂ³n: 13-08-2007 ModificÃÂ³    : Juan A. Coronel M.
--Cambio      : Que haga commit al actualizar la tabla ss_osclientesupervisar, y maneje en trans indepnte la actualizaciÃÂ³n de ss_solcitud_os.
--Juan A. Coronel M 21-08-2007  Almacenar situacion y causa en ss_solicitud_os, campos recien creados en esas tabla.

--ModificaciÃÂ³n: 21-09-2009 ModificÃÂ³    : JosÃÂ© Almeida.
--Cambio      : Que guarde en bdisolic:ss_os_errores cuANDo ocurra una exception.

--ModificaciÃÂ³n: 19/oct/2010 ModificÃÂ³:     Enrique LizÃÂ¡rraga Lugo
--Cambio:       Se agrega consulta para que haga el cambio pertinente de clave Coppel a Bancoppel segÃÂºn la situaciÃÂ³n especial.
--              Se agregÃÂ³ variable para identificar la clave Bancoppel (vclave) y la clave Coppel (vclave_orig)

--ModificaciÃÂ³n:	15/Feb/2011 ModificÃÂ³:		Enrique LizÃÂ¡rraga Lugo
--Cambio:		Se agrega variable para identificar situacion de Bancoppel (vsituacionbanco).
--				Se agrega a consulta de cambio anterior el campo "situacionbanco", y se guarda la situacion original en complementoreferencia.

--ModificaciÃÂ³n:	10/Jun/2011 ModificÃÂ³:		JesÃÂºs Manuel Aguilar Heredia
--Cambio:		Se realiza homologacion del proceso productivo con la version para contemplar el producto coppel, se modifica para que guarde el valor original recibido 
--en la situacion especial y causa situacion especial de la respuesta de coppel, lo cual se guardara en la tabla ss_solicitud_os

--Modificacion: DSB 21/Abril/2017 Modifica: Edwin S Castro.
--Cambio: Se agrega un par de consultas a la tabla "informix".ss_os_secoppel , para obtener informacion que se puede ir en vacio.

--Modificacion: 06/03/2024 Modifica: Equipo 17 de Credito y Cobranza
--Cambio: se agregan validaciones para autorizar solicitudes por motivods de rechazo por cobranza  REQ 09637

    DEFINE SQL_ERR     		INTEGER;
    DEFINE ISAM_ERR    		INTEGER;
    DEFINE ERROR_INFO  		VARCHAR(80);
    DEFINE P_COD_RET   		VARCHAR(5);
    DEFINE P_MENSAJE   		VARCHAR(80);
    DEFINE vclave      		CHAR(1); 
    DEFINE vclaveorig  		CHAR(1);
	DEFINE vsituacionbanco	CHAR(1);
    DEFINE cTpSol           CHAR(1);
    DEFINE cnum_solicitud   varchar(20);
    DEFINE dfechasolicitud  date;
	DEFINE cNumcte          CHAR(20);
	DEFINE cStatus          CHAR(1); 
	DEFINE cStatus_sol      CHAR(2);
	DEFINE cCausa 			CHAR(3);
	DEFINE cDesc			CHAR(100);
	DEFINE cCod_ret2		VARCHAR(5);
	DEFINE cNumCteOrgBco    CHAR(20);
	DEFINE cNumSolOrgBco    CHAR(20);
	DEFINE sCantReg    		SMALLINT;
	DEFINE sTotSolOrgBco 	SMALLINT;
    DEFINE cNumeroLinea 	CHAR(150);
    DEFINE cNum_producto    CHAR(4);
    DEFINE cCanal_sol       CHAR(1);
    DEFINE cGpoEvaluacion   CHAR(1);
    DEFINE cNuevoStatus     CHAR(2);
    DEFINE pclaveAux        CHAR(1);
	
	DEFINE cNumcteSi		CHAR(20);

    LET P_COD_RET 			= '00000';
    LET P_MENSAJE 			= 'PROCESO EXITOSO';
    Let pclave             	= upper(pclave);
    Let psituacionespecial 	= upper(psituacionespecial);
    LET vclave 				= '';
    LET vclaveorig 			= pclave;
    LET SQL_ERR 			= 0;
    LET ISAM_ERR 			= '';
    LET ERROR_INFO 			= '';
    LET vsituacionbanco  	= '';
    LET cTpSol  			= '';
    LET cnum_solicitud  	= '';
    LET dfechasolicitud  	= DATE(1);
	LET cNumcte            	= '';
	LET cStatus 		   	= '';
	LET cStatus_sol 	   	= '';
	LET cCausa 		   	   	= '';
	LET cDesc	 	   	   	= '';	
	LET cCod_ret2	 	   	= '';	
	LET cNumCteOrgBco	   	= '';	
	LET cNumSolOrgBco	   	= '';	
	LET sCantReg		   	= 0;	
	LET sTotSolOrgBco	   	= 0;
	LET cNumeroLinea 		= '';
    LET cNum_producto       ='';
    LET cCanal_sol          ='';
    LET cGpoEvaluacion      ='';
    LET cNuevoStatus        ='';
    LET pclaveAux           ='';
	
	LET cNumcteSi          	= '';
	
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	
		SET DEBUG FILE TO "sp_os_grabarespuesta.err";
		TRACE SQL_ERR||" * "||ISAM_ERR||" * "||" num_solicitud "||TRIM(pnum_solicitud)||" * "||" cNumeroLinea "||TRIM(cNumeroLinea)||" * "||TRIM(ERROR_INFO);
		
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;       
       -- ROLLBACK; 
        INSERT INTO bdisolic:"informix".ss_os_errores(num_solicitud,  fechasolicitud,  codigo_error, descripcion_error, fechaproceso )
        VALUES                            (pnum_solicitud, pfechasolicitud, P_COD_RET,    P_MENSAJE,         CURRENT::DATE); 
		
        RETURN P_COD_RET;
    END EXCEPTION;
	
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/Mariela/sp_os_grabarespuesta.out";
	--TRACE ON;

	IF (pclave = '')THEN
		LET pclave = '0';
	END IF;
    
    IF (psituacionespecial = '')THEN
       LET psituacionespecial = 0;
    END IF;

	
	IF SUBSTR(TRIM(pnum_solicitud),1,1) <> 'P' THEN
		LET cNumeroLinea = 'SELECT LINE 132';
		FOREACH WITH HOLD
			--Foreach Extraer Solicitudes del Cliente
            SELECT a.NUM_SOLICITUD, tipo_solicitud, fecha_solicitud, a.num_producto, a.canal_sol
            INTO cnum_solicitud , cTpSol, dfechasolicitud, cNum_producto, cCanal_sol
			FROM "informix".ss_solicitudes a,
				"informix".ss_solicitud_os b
			WHERE a.empresa ='001'
				and numcte in ( SELECT  numcte
							FROM "informix".ss_solicitudes
							WHERE a.empresa = empresa
							  AND num_solicitud = pnum_solicitud)
				--AND a.num_solicitud = pnum_solicitud
				and status_solicitud = 'OS'
				and a.empresa = b.empresa 
				and a.num_solicitud = b.num_solicitud
				and b.fecha_solicitud = pfechasolicitud
			
			IF cTpSol <> 'C' THEN
				LET cTpSol = 'T';
			END IF;
			
			-- INC --
			SELECT a.numcte
			INTO cNumcteSi
			FROM bdinteg:'informix'.si_cliente a INNER JOIN bdisolic:"informix".ss_solicitudes b ON a.numcte=b.numcte
			WHERE b.empresa = '001'
			AND num_solicitud = pnum_solicitud;
								
			IF cNumcteSi IS NULL or cNumcteSi = '' THEN
				
				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol('001','sistema',pnum_solicitud,'CN','CV','Cancelada por error en cte')
				INTO P_COD_RET;
				
				INSERT INTO bdisolic:"informix".ss_os_errores(num_solicitud,  fechasolicitud,  codigo_error, descripcion_error, fechaproceso )
				VALUES (pnum_solicitud, pfechasolicitud, '-391', 'Error Cte Inexistente si_cte '||pnum_solicitud||'', CURRENT::DATE);
				RETURN P_COD_RET;
				
			END IF;
			-- INC --
            -- Bloque para Autorizar por RQM 09 637
            IF pclave IN ('R', 'D') and cNum_producto = '6500' THEN
                LET cStatus_sol= '';

                IF pclave = 'R' THEN
                    LET cNuevoStatus = 'RT';
                    LET cCausa       = 'ROS';
                ELIF pclave = 'D' THEN
                    LET cNuevoStatus = 'OA';
                    LET cCausa       = '';
                END IF;

                SELECT NVL(grupo_eval,'')
                INTO cGpoEvaluacion
                FROM bdisolic:"informix".ss_nuevo_parametrico
                WHERE num_solicitud = cnum_solicitud
                and empresa = '001';

                IF cGpoEvaluacion IS NOT NULL THEN
                    SELECT estatus_sol_salida
                    INTO cStatus_sol
                    FROM bdisolic:"informix".ss_os_params
                    WHERE num_producto = cNum_producto
                    AND canal_sol = cCanal_sol
                    AND situacion_especial = psituacionespecial
                    AND causa_sit_esp = pcausasituacionespecial
                    AND grupo_eval = cGpoEvaluacion
                    AND estatus_sol_entrada = cNuevoStatus
                    AND estatus_sol_salida in ('AT', 'PA');

                    IF cStatus_sol IS NOT NULL THEN
                        LET cDesc = 'Politica grupo evaluacion '|| cGpoEvaluacion;

                        CALL "informix".sp_actualiza_status_sol(
                            '001',
                            'sistema' ,
                            cnum_solicitud,
                            cNuevoStatus,
                            cCausa,
                            trim(cDesc) ) returning P_COD_RET;

                        -- Se manda cNuevoStatus, el que quedarÃ­a con la OS, solo para efectos de bitacora, el cambio a AT o AP, lo harÃ¡ el trigger de ss_solcitud_os

                        UPDATE "informix".ss_solicitudes
                        SET status_solicitud = 'OS'
                        WHERE num_solicitud = cnum_solicitud
                        AND empresa = '001';
                        -- permitirÃ¡ que el sp actualiza_solos avance, no dejamos registro en bitacora

                        -- SE RESPALDA LA PCLAVE PARA
                        -- LA SIGUIENTE ITERACION
                        LET pclaveAux = pclave;
                        LET pclave = 'A';

                    END IF;
                END IF;
            END IF;
            -- Bloque para Autorizar por RQM 09 637


			LET cNumeroLinea = 'SELECT LINE 152';
			SELECT  NVL(clave_final,''), NVL(situacionbanco,'')
			INTO    vclave, vsituacionbanco
			FROM   "informix".ss_os_secoppel 
			WHERE empresa = '001'
				AND clave = NVL(pclave,0)
				AND situacion = NVL(psituacionespecial,0)
				AND causa = pcausasituacionespecial
				AND tipo_solic  = cTpSol;

			IF vclave <> '' THEN
                LET pclaveAux = pclave;
				LET pclave = vclave;
			END IF;

			IF pclave IN ('A', 'R', 'D') THEN
				--BEGIN WORK
				UPDATE "informix".ss_osclientesupervisar
					SET fechaimpresion= NVL(pfechaimpresion,''),
						fecharespuesta = NVL(pfecharespuesta,''), usuariogestor = NVL(pusuariogestor, ''), clave = NVL(pclave, ''),
						situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
						estatusos = NVL(ptiendaimpresion,0), complementoreferencia = vclaveorig||'-'||psituacionespecial 
				WHERE empresa = '001' AND secuencia = psecuencia AND num_solicitud = cnum_solicitud AND fechasolicitud = dfechasolicitud;

				UPDATE "informix".ss_solicitud_os
					SET fecha_respuesta = NVL(pfecharespuesta,''), status = NVL(pclave, ''), usuario_gestor = NVL(pusuariogestor, ''),
						situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
						situacionespecialrespuesta  =  NVL(psituacionespecial,''),
						causasituacionespecialrespuesta  = NVL(pcausasituacionespecial,0)
				WHERE empresa = '001' 
					AND num_solicitud = cnum_solicitud 
					AND fecha_solicitud = dfechasolicitud 
					AND ( secuenciaos = 0 or secuenciaos = psecuencia) ;

                IF cStatus_sol IS NOT NULL AND cStatus_sol <> '' AND cNum_producto = '6500' THEN
                    UPDATE bdisolic:"informix".ss_autorizacion
                    SET comentario='Politica grupo evaluacion ' || cGpoEvaluacion,
                        causa_solicitud = 'GE5'
                    WHERE empresa = '001'
                        AND num_solicitud = cnum_solicitud
                        AND status_solicitud IN ('AT', 'PA')
                        AND fecha_hora = (
                            SELECT MAX(fecha_hora)
                            FROM bdisolic:"informix".ss_autorizacion a
                            WHERE a.empresa = '001'
                            AND a.num_solicitud = cnum_solicitud
                            AND a.status_solicitud IN ('AT', 'PA')
                        );
                END IF;

				UPDATE "informix".ss_os_solautdirecta 
					SET status = NVL(pclave, '')
				WHERE empresa = '001' and  num_solicitud = cnum_solicitud;
				--COMMIT WORK;
			ELSE
				UPDATE "informix".ss_osclientesupervisar
					SET fechaimpresion= NVL(pfechaimpresion,''), estatusos = NVL(ptiendaimpresion,0)
				WHERE empresa = '001' AND secuencia = psecuencia AND num_solicitud = cnum_solicitud AND fechasolicitud = dfechasolicitud;
			END IF;
			
			--SELECCIONA SI EL CLIENTE FUE MARCADO CON DOMICILIO DIFERENTE A SU IFE Y FUE ENVIADA A ORDEN DE SUPERVISION,ENTONCES SE DESMARCARA   
			/*SELECT a.clave, b.status,c.status_solicitud, c.numcte
			INTO vclave,cStatus,cStatus_sol,cNumcte
			FROM "informix".ss_osclientesupervisar a,
				 "informix".ss_solicitud_os b,
				 "informix".ss_solicitudes c
			WHERE a.num_solicitud = b.num_solicitud
				AND a.num_solicitud =  c.num_solicitud
				AND a.num_solicitud = pnum_solicitud
				AND a.clave = 'A'
				AND b.status = 'A'
				AND c.status_solicitud = 'AT';*/
			
			LET cNumeroLinea = 'SELECT LINE 208';
			SELECT a.clave, b.status, c.status_solicitud, c.numcte
			INTO    vclave, cStatus , cStatus_sol       , cNumcte
			FROM bdisolic:"informix".ss_osclientesupervisar a, 
				 bdisolic:"informix".ss_solicitud_os b,
				 bdisolic:"informix".ss_solicitudes c
			WHERE a.num_solicitud = b.num_solicitud
				AND a.num_solicitud =  c.num_solicitud
				AND a.num_solicitud = pnum_solicitud
				AND a.clave = 'A'
				AND b.status = 'A'
				AND a.fechasolicitud = b.fecha_solicitud
				AND a.fechasolicitud = dfechasolicitud
				AND c.status_solicitud = 'AT';    

			
			IF vclave = 'A' AND cStatus = 'A' AND cStatus_sol = 'AT' THEN
				
				-- SE DESMARCA AL CLIENTE CUANDO SE AUTORIZA LA SOLICITUD
				-- SE CAMBIO EN NOMBRE DEL CAMPO respuesta_os POR EL NUEVO CAMPO
				--fecha_respuesta_os DE LA TABLA si_ctes_manttodomife.
				UPDATE bdinteg:"informix".si_ctes_manttodomife 
				SET flag_envia_os = '0', 
				fecha_respuesta_os = (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)  
				WHERE empresa = '001' 
				AND numcte = cNumcte;

			END IF;			
            IF pclaveAux <> '' THEN
                LET pclave = pclaveAux;
                LET pclaveAux = '';
            END IF;
            LET cStatus_sol = '';
		END FOREACH;
	ELSE
		LET cNumeroLinea = 'SELECT LINE 240';
		--SE VERIFICA QUE EXISTA LA SOLICITUD EN LA TABLA DE PROSPECTOS Y SE OBTIENE EL NUMERO DE CLIENTE BANCO.
		SELECT COUNT(numcte),NVL(numcte,'')
		INTO sCantReg,cNumCteOrgBco
		FROM bdiprospectos:"informix".pr_cliente 
		WHERE numcte_pros = pnum_solicitud
		GROUP BY 2;
		
		LET sTotSolOrgBco = 0;
		
		IF sCantReg > 0 AND NVL(cNumCteOrgBco,'') <> '' THEN 			
			LET cNumeroLinea = 'SELECT LINE 250';
			SELECT COUNT(num_solicitud)
			INTO sTotSolOrgBco
			FROM "informix".ss_solicitudes 
			WHERE empresa ='001'
				AND numcte = cNumCteOrgBco
				AND status_solicitud = 'OS';
		END IF
				
			IF sTotSolOrgBco > 0 THEN 
				LET cNumeroLinea = 'SELECT LINE 262';
				FOREACH
					--EN CASO DE EXISTIR EL CLIENTE BANCO SE OBTIENE LAS SOLICITUDES DE DICHO CLIENTE EN LA TABLA DE SOLICITUDES.		
					SELECT num_solicitud
					INTO cNumSolOrgBco
					FROM "informix".ss_solicitudes 
					WHERE empresa ='001'
						AND numcte = cNumCteOrgBco
						AND status_solicitud = 'OS'			
					
					IF NVL(cNumSolOrgBco,'') <> '' THEN 
						LET cNumSolOrgBco = cNumSolOrgBco;			
						
						--MAJF OCTUBRE 20,2011
						IF SUBSTR(TRIM(cNumSolOrgBco),1,1) <> 'P' THEN	
							LET cNumeroLinea = 'SELECT LINE 276';
							--Foreach Extraer Solicitudes del Cliente
							SELECT a.NUM_SOLICITUD, tipo_solicitud, fecha_solicitud
							INTO cnum_solicitud , cTpSol, dfechasolicitud
							FROM "informix".ss_solicitudes a,
								"informix".ss_solicitud_os b
							WHERE a.empresa ='001'							
								AND a.num_solicitud = cNumSolOrgBco
								and status_solicitud = 'OS'
								and a.empresa = b.empresa 
                                and a.num_solicitud = b.num_solicitud
                                and b.status = 'P';
								--and b.fecha_solicitud = pfechasolicitud;

							IF cTpSol <> 'C' THEN
								LET cTpSol = 'T';
							END IF;

							LET cNumeroLinea = 'SELECT LINE 293';
							SELECT  NVL(clave_final,''), NVL(situacionbanco,'')
							INTO    vclave, vsituacionbanco
							FROM   "informix".ss_os_secoppel 
							WHERE empresa = '001'
								AND clave = NVL(pclave,0)
								AND situacion = NVL(psituacionespecial,0)
								AND causa = pcausasituacionespecial
								AND tipo_solic  = cTpSol;

							IF vclave <> '' THEN
								LET pclave = vclave;
							END IF;

							IF pclave IN ('A', 'R', 'D') THEN
								--BEGIN WORK
								UPDATE "informix".ss_osclientesupervisar
									SET fechaimpresion= NVL(pfechaimpresion,''),
										fecharespuesta = NVL(pfecharespuesta,''), usuariogestor = NVL(pusuariogestor, ''), clave = NVL(pclave, ''),
										situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
										estatusos = NVL(ptiendaimpresion,0), complementoreferencia = vclaveorig||'-'||psituacionespecial 
								WHERE empresa = '001' AND secuencia = psecuencia AND num_solicitud = pnum_solicitud AND fechasolicitud = pfechasolicitud;

								UPDATE "informix".ss_solicitud_os
									SET fecha_respuesta = NVL(pfecharespuesta,''), status = NVL(pclave, ''), usuario_gestor = NVL(pusuariogestor, ''),
										situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
										situacionespecialrespuesta  =  NVL(psituacionespecial,''),
										causasituacionespecialrespuesta  = NVL(pcausasituacionespecial,0)
								WHERE empresa = '001' 
									AND num_solicitud = cnum_solicitud 
									AND fecha_solicitud = dfechasolicitud 
									AND ( secuenciaos = 0 or secuenciaos = psecuencia) ;
										
								UPDATE "informix".ss_os_solautdirecta 
									SET status = NVL(pclave, '')
								WHERE empresa = '001' and  num_solicitud = cnum_solicitud;
								
								----------
								--SE REALIZA ACTUALIZACION DE LA RESPUESTA DE LA OS.
								UPDATE bdiprospectos:"informix".pr_solicitud_os
									SET fecha_respuesta = NVL(pfecharespuesta,''), status = NVL(pclave, ''), usuario_gestor = NVL(pusuariogestor, ''),
										situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
										situacionespecialrespuesta  =  NVL(psituacionespecial,''),
										causasituacionespecialrespuesta  = NVL(pcausasituacionespecial,0)
								WHERE empresa = '001' 
									AND num_solicitud = pnum_solicitud 
									AND fecha_solicitud = pfechasolicitud 
									AND ( secuenciaos = 0 or secuenciaos = psecuencia) ;
								
								--COMMIT WORK;
							ELSE
								UPDATE "informix".ss_osclientesupervisar
									SET fechaimpresion= NVL(pfechaimpresion,''), estatusos = NVL(ptiendaimpresion,0)
								WHERE empresa = '001' AND secuencia = psecuencia AND num_solicitud = cnum_solicitud AND fechasolicitud = dfechasolicitud;
							END IF;
							
							LET cNumeroLinea = 'SELECT LINE 350';
							--SELECCIONA SI EL CLIENTE FUE MARCADO CON DOMICILIO DIFERENTE A SU IFE Y FUE ENVIADA A ORDEN DE SUPERVISION,ENTONCES SE DESMARCARA   
							SELECT a.clave, b.status,c.status_solicitud, c.numcte
							INTO vclave,cStatus,cStatus_sol,cNumcte
							FROM "informix".ss_osclientesupervisar a,
								 "informix".ss_solicitud_os b,
								 "informix".ss_solicitudes c
							WHERE a.num_solicitud = b.num_solicitud
								AND a.num_solicitud =  c.num_solicitud
								AND a.num_solicitud = cNumSolOrgBco
								AND a.clave = 'A'
								AND b.status = 'A'
								AND c.status_solicitud = 'AT';
							
							IF vclave = 'A' AND cStatus = 'A' AND cStatus_sol = 'AT' THEN
								
								-- SE DESMARCA AL CLIENTE CUANDO SE AUTORIZA LA SOLICITUD
								-- SE CAMBIO EN NOMBRE DEL CAMPO respuesta_os POR EL NUEVO CAMPO
								--fecha_respuesta_os DE LA TABLA si_ctes_manttodomife.
								UPDATE bdinteg:"informix".si_ctes_manttodomife 
								SET flag_envia_os = '0', 
								fecha_respuesta_os = (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)  
								WHERE empresa = '001' 
								AND numcte = cNumcte;

							END IF;								
						END IF; --
					END IF;
																	
				END FOREACH;
				
		ELSE --NO TIENE REGISTROS EL CLIENTE PROSPECTO EN TITULAR.
			--DSB 24/04/2017
			LET cNumeroLinea = 'SELECT LINE 382';
			SELECT  NVL(clave_final,''), NVL(situacionbanco,'')
			INTO vclave, vsituacionbanco
			FROM "informix".ss_os_secoppel 
			WHERE empresa = '001'
			AND clave = NVL(pclave,0)
			AND situacion = NVL(psituacionespecial,0)
			AND causa = pcausasituacionespecial
			AND tipo_solic  = 'C'; --Se establece ya que es una solicitud de tarjeta Coppel
			
			IF vclave <> '' THEN
				LET pclave = vclave;
			END IF;
			
			LET cNumeroLinea = 'SELECT LINE 396';
			--FOREACH WITH HOLD
			SELECT a.NUM_SOLICITUD
			INTO cnum_solicitud 
			FROM "informix".ss_osclientesupervisar a ,           
				bdiprospectos:"informix".pr_cliente pr
			WHERE a.empresa ='001'       
				and  a.num_solicitud = pr.numcte_pros
				and  pr.numcte_pros = pnum_solicitud
				and  pr.status_numcte_pros = 'OS'
				AND  a.secuencia = psecuencia;			
				--and  pr.estado_os = 1; se elimina filtro de estado_os 

			IF pclave IN ('A', 'R', 'D') THEN
				--BEGIN WORK
				UPDATE "informix".ss_osclientesupervisar
				SET fechaimpresion= NVL(pfechaimpresion,''),
					fecharespuesta = NVL(pfecharespuesta,''), usuariogestor = NVL(pusuariogestor, ''), clave = NVL(pclave, ''),
					situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
					estatusos = NVL(ptiendaimpresion,0), complementoreferencia = vclaveorig||'-'||psituacionespecial 
				WHERE empresa = '001' AND secuencia = psecuencia 
					AND num_solicitud = cnum_solicitud 
					AND fechasolicitud = pfechasolicitud;
								
				--SE REALIZA ACTUALIZACION DE LA RESPUESTA DE LA OS.
				UPDATE bdiprospectos:"informix".pr_solicitud_os
					SET fecha_respuesta = NVL(pfecharespuesta,''), status = NVL(pclave, ''), usuario_gestor = NVL(pusuariogestor, ''),
						situacionespecial = NVL(vsituacionbanco, ''), causasituacionespecial = NVL(pcausasituacionespecial,0),
						situacionespecialrespuesta  =  NVL(psituacionespecial,''),
						causasituacionespecialrespuesta  = NVL(pcausasituacionespecial,0)
				WHERE empresa = '001' 
					AND num_solicitud = pnum_solicitud 
					AND fecha_solicitud = pfechasolicitud 
					AND ( secuenciaos = 0 or secuenciaos = psecuencia) ;

				update bdiprospectos:pr_cliente  		
				set estado_os  = 2
				where numcte_pros = cnum_solicitud;  

				IF pclave = 'R' THEN	
					LET cNumeroLinea = 'SELECT LINE 436';
					SELECT FIRST 1 cau.causa_solicitud, cau.descripcion
					INTO cCausa, cDesc
					FROM  bdisolic: "informix".ss_osclientesupervisar nuv, bdiprospectos:"informix".pr_causas_sol cau
					WHERE nuv.num_solicitud = pnum_solicitud 
						AND cau.situacion_especial = nuv.situacionespecial
						AND cau.causa_situacion = nuv.causasituacionespecial
						AND nuv.secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud = pnum_solicitud);
					
					-- SE CAMBIA EL ESTATUS DENTRO DE pr_autorizacion Y pr_cliente, SE REUTILIZA PRODECIMIENTO 
					EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus('sistema', pnum_solicitud,'RT',cCausa,cDesc)
					INTO cCod_ret2;
					
					--Se valida la ejecucion del procedimiento.
					IF CAST(cCod_ret2 AS INTEGER) <> 0 THEN					
						LET P_COD_RET = '00001';
					END IF ;
				END IF
			
				IF pclave = 'A' THEN		
					-- SE CAMBIA EL ESTATUS DENTRO DE pr_autorizacion Y pr_cliente, SE REUTILIZA PRODECIMIENTO 
					EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus('sistema', pnum_solicitud,'AT',cCausa,cDesc)
					INTO cCod_ret2;	
					
					--Se valida la ejecucion del procedimiento.
					IF CAST(cCod_ret2 AS INTEGER) <> 0 THEN					
						LET P_COD_RET = '00001';
					END IF ;
					
				END IF;					
			
				IF pclave = 'D' THEN		
					-- SE CAMBIA EL ESTATUS DENTRO DE pr_autorizacion Y pr_cliente, SE REUTILIZA PRODECIMIENTO 
					EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus('sistema', pnum_solicitud,'OA',cCausa,cDesc)
					INTO cCod_ret2;	
					
					--Se valida la ejecucion del procedimiento.
					IF CAST(cCod_ret2 AS INTEGER) <> 0 THEN					
						LET P_COD_RET = '00001';
					END IF ;
					
				END IF;        
			ELSE
				UPDATE "informix".ss_osclientesupervisar
				SET fechaimpresion= NVL(pfechaimpresion,''), estatusos = NVL(ptiendaimpresion,0)
				WHERE empresa = '001' AND secuencia = psecuencia AND num_solicitud = cnum_solicitud AND fechasolicitud = pfechasolicitud;
			END IF;	
		--END FOREACH;
		END IF;				
			
	END IF ;				
		
	--RETURN PRINCIPAL    
	RETURN P_COD_RET;
END;
--TRACE OFF;

END PROCEDURE
