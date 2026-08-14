CREATE PROCEDURE "informix".ins_buro_credito( pInstitucion CHAR(2),pempresa CHAR(3), 
pnum_solicitud CHAR(20), pnum_cliente CHAR(20),pfecha DATE, pfecha_hoy DATE, pcadena CHAR(250), pitem_cadena INT, ppaso VARCHAR(10), pRelanzar SMALLINT)
RETURNING CHAR(1); -- Bandera si continua o espera a Buro
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo.
-- Modificacion: Al enviarse una solicitud de cliente a consulta a una segunda
--               institucion, se actualzia el nuevo estatus a todas la solicitudes
--               que el cliente tenga en el estatus anterior.
-- Fecha de modificaciÃÂ?ÃÂÃÂ³n: 13-03-2009
--------------------------------------------------------------------------------
-- Modificacion: Maria Elena Angulo Aispuro.
-- Proyecto: Caja Unica. 
-- Fecha de Modificacion: 28-08-2018
-- Descripcion: Se inhabilita el bloque de FICO Extended
-- RQ: RQI27201
-- CC Rational: 26072
--------------------------------------------------------------------------------
-- Autor:  Francisco Javier Peraza.
-- Modifica: Se modifica orden de consulta a las instituciones de credito
-- Fecha: 15-04-2020.
-- Peticion: RQM 09 554 - Consulta a las SICs.
------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Autor: Luis AÂngel Juarez Vazquez, Gustavo Fuentes Lopez
-- Modificacion: Se ha agregado la validacion de producto para realizar nueva evaluacion de parametros .
-- Fecha de Modificacion: 20-08-2022.
-- Peticion: Prestamo Personal
---------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Autor:  Felix Ignacio Leyva Gamez.
-- Modifica: Se agrega consulta aleatoria a las SICs, ,con las banderas de fallosic y vigencia
-- Fecha: 06-01-2023.
-- Peticion: RQM 09 606 - Consulta aleatoria a las SIC's cadena 2x1 - Originacion
------------------------------------------------------------------------------------
-- Cambio
DEFINE mIngresoMensual money(14,2);
DEFINE dCompromisos DECIMAL(14,2);
DEFINE vMensaje     VARCHAR(255);
DEFINE cCalifica    CHAR(1);
DEFINE sql_err      INT;
DEFINE cod_ret      CHAR(6);
DEFINE s_regreso    CHAR(1);
DEFINE iMontoBuro   INT;
DEFINE usuario_cir  VARCHAR(50);
DEFINE passwd_cir   VARCHAR(50);
DEFINE usuario_bur  VARCHAR(50);
DEFINE passwd_bur   VARCHAR(50);
DEFINE usu_orden1   CHAR(10);
DEFINE usu_orden2   CHAR(10);
DEFINE pass_orden1  CHAR(8);
DEFINE pass_orden2  CHAR(8);
DEFINE status_1      CHAR(2);
DEFINE status_2      CHAR(2);
DEFINE mensaje_orden VARCHAR(255,1);
DEFINE Relanzar SMALLINT;
DEFINE cuenta_solproc INTEGER;
-- ini caja unica. Viridiana
DEFINE csolicitud    CHAR(20);
DEFINE corigen       CHAR(1);
DEFINE cEnvio        CHAR(1);
DEFINE v_mod_parame  CHAR(1);

-- fin caja unica. Viridiana
-- JOM INI BCSCORE
DEFINE tipo_acceso_bc CHAR (03);
-- JOM FIN BCSCORE
DEFINE iDiasVigencia  INTEGER;
DEFINE iRenviar  INTEGER;
DEFINE cNumSolSIC  CHAR(20);
DEFINE cNumSolSIC2  CHAR(20);
DEFINE sSolincremento SMALLINT;
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE Se requiere el grupo
DEFINE cgrupo       CHAR(1);
DEFINE v_valor_1s   DECIMAL(14,2);
DEFINE v_valor_2s   DECIMAL(14,2);
DEFINE v_tpsol                CHAR(1);
DEFINE v_bcs_min,v_bcs_max  INTEGER;
DEFINE tipo_acceso_cc  CHAR (03);
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
DEFINE v_scor_prop_min DECIMAL(14,2);
DEFINE v_meses                SMALLINT;
DEFINE vAntiguedad            CHAR(1);
DEFINE v_cuantos              SMALLINT;
DEFINE v_lineaban             DECIMAL(14,2);
DEFINE v_capacidad_pago        MONEY(14,2);
DEFINE iPlazo                  INTEGER;
DEFINE v_producto			  CHAR(4);
DEFINE v_sol_sic    CHAR(20);
--RQM 09 554
DEFINE cFlujo_cc CHAR(1);
DEFINE status_consul           	CHAR(2);
DEFINE cCanalSol	CHAR (2);

DEFINE vTipoHit  			INTEGER;	
DEFINE iNewMPP  			INTEGER;	
DEFINE vCuentasPF 			SMALLINT;
--RQM 09 606
DEFINE vFalloSIC	INTEGER;


--set debug file to "/informix/Malena/ins_buro_credito.unl";
--trace on;
LET s_regreso = '0';
LET status_1='00';
LET status_2='00';
LET Relanzar=pRelanzar;
-- ini caja unica. Viridiana
LET csolicitud = "";
LET corigen    = "";
LET cEnvio     = "0";
-- fin caja unica. Viridiana
LET v_mod_parame="";

-- JOM INI BCSCORE
LET tipo_acceso_bc = "";
-- JOM FIN BCSCORE
LET cuenta_solproc = 0;
LET iDiasVigencia = 0;
LET cNumSolSIC = "";
LET cNumSolSIC2 = "";
LET iRenviar = 0;
LET sSolincremento = 0;
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE
LET cgrupo     = "";
LET v_valor_1s = 0;
LET v_valor_2s = 0;
LET v_tpsol    = "";
LET v_bcs_min  = 0;
LET v_bcs_max  = 0;
LET tipo_acceso_cc = "";
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
LET v_scor_prop_min = 0;
LET v_meses=0;
LET vAntiguedad  = "?";
LET v_cuantos    = 0;
LET v_lineaban   = 0;	 
LET v_capacidad_pago        = 0; 
LET iPlazo                  = 0;
LET v_producto  ="";
LET v_sol_sic = "";
--RQM 09 554
LET cFlujo_cc = '1';
LET status_consul = '';
LET cCanalSol = '';
--RQM 09 613
LET vTipoHit  = 0;	
LET vCuentasPF =0;
LET iNewMPP =0;
--RQM 09 606
LET vFalloSIC	= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SELECT count(*)
	INTO cuenta_solproc
	FROM bdisolic:"informix".ss_solicitudes
	WHERE empresa = pEmpresa
	AND num_solicitud = pnum_solicitud
	AND status_solicitud  IN (SELECT status_solicitud FROM bdisolic:"informix".ss_status_sol WHERE tipo_auto IN (1,2));
	
  	--RQM 09 308 Se agrega validacion para identificar si se trata de un incremento o solicitud normal.
	IF cuenta_solproc = 0 THEN		
		SELECT COUNT(*)
		INTO cuenta_solproc
		FROM bdicred:"informix".sd_bitacora_aumlincred 
		WHERE empresa = '001'
		AND num_solicitud = pnum_solicitud
		AND status  IN (SELECT status_solicitud FROM bdisolic:"informix".ss_status_sol WHERE tipo_auto IN (1,2));
		
		LET sSolincremento = 1;
		
	END IF;
	
       IF cuenta_solproc=0 THEN
          RETURN '9';
       END IF;
	   
   
---clave de circulo
SELECT valor
INTO usuario_cir  
FROM "informix".br_param
WHERE cod_param=1;

SELECT valor
INTO passwd_cir 
FROM "informix".br_param
WHERE cod_param=2;

--FJPR
SELECT canal_sol INTO cCanalSol FROM bdisolic:"informix".ss_solicitudes 
WHERE numcte = pnum_cliente AND num_solicitud = pnum_solicitud;

/*SELECT insti1 INTO status_consul FROM bdisolic:"informix".ss_canales_solic 
WHERE canal_solic = cCanalSol;*/
------------------------------------------------------------------------------------------------------------------------------------------------
--Inicio: RQM 09 606 consulta sic aleatorio y Fallo de SIC
--Tomar la ultima solicitud de la SIC
SELECT institucion, NVL(FalloSIC,0)
	INTO status_consul, vFalloSIC
	FROM bdisolic:"informix".ss_solicitudes_sic
	WHERE ROWID = (SELECT MAX(rowid)
				   FROM bdisolic:"informix".ss_solicitudes_sic
				   WHERE numcte= pnum_cliente
					AND num_solicitud = pnum_solicitud);

IF status_consul IS NULL THEN  --Valida que se tenga registro de la solicitud
	LET s_regreso = '1';	RETURN s_regreso;
	
END IF;
--Validar si la solicitud no trae fallo por ser BCScore
/*IF status_consul = 'CC' AND vFalloSIC = 0 THEN
	--Validar si en el historial tiene envio a BC
	IF EXISTS (SELECT status_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = pnum_solicitud AND status_solicitud = 'BC') THEN
		LET status_consul = 'BC';--Es respuesta de BCScore
	END IF;
END IF;*/
--Fin: RQM 09 606 consulta sic aleatorio y Fallo de SIC
------------------------------------------------------------------------------------------------------------------------------------------------

IF status_consul = 'CC' THEN
	LET cflujo_cc = '1';
ELSE
	LET cflujo_cc = '0';
END IF;

-- FJPR fin

--ini CAS se adapta para hacer un cambio de orden entre buro y circulo.
	IF cflujo_cc = '1' THEN
        SELECT status_solicitud
        INTO status_1
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='2';  --Status_1 = CC

        SELECT status_solicitud
        INTO status_2
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='1';   --status_2 = BC
		
		---clave de buro Prospector
		SELECT valor
		INTO usuario_bur
		FROM "informix".br_param
		WHERE cod_param=154;

		SELECT valor
		INTO passwd_bur  
		FROM "informix".br_param
		WHERE cod_param=155;
		
	ELSE
	    SELECT status_solicitud
        INTO status_1
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='1';   --Status_1 = BC

        SELECT status_solicitud
        INTO status_2
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='2';   ----status_2 = CC
		
		---clave de buro consulta consolidada (2x1)
		SELECT valor
		INTO usuario_bur
		FROM "informix".br_param
		WHERE cod_param=124;

		SELECT valor
		INTO passwd_bur  
		FROM "informix".br_param
		WHERE cod_param=125;
	END IF;

        IF status_1='BC' THEN
            LET usu_orden1=usuario_bur;
            LET usu_orden2=usuario_cir;
            LET pass_orden1=passwd_bur;
            LET pass_orden2=passwd_cir;
			--Numero de producto, consulta consolidada Buro 007
			select trim(valor) into tipo_acceso_bc
			from bdiburo:br_param
			where cod_param = 126;  
        ELSE
            LET usu_orden1=usuario_cir;
            LET usu_orden2=usuario_bur;
            LET pass_orden1=passwd_cir;
            LET pass_orden2=passwd_bur;
			--Numero de producto, prospector 107
			select trim(valor) into tipo_acceso_bc
			from bdiburo:br_param
			where cod_param = 153;  
       END IF;
--ini CAS se adapta para hacer un cambio de orden entre buro y circulo.
BEGIN
    ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
          INSERT INTO "informix".br_cadena_error VALUES (pInstitucion,pnum_cliente,pfecha, sql_err,ppaso,
          pitem_cadena,SUBSTR(pcadena,1,pitem_cadena + 10),pfecha_hoy);
          RETURN '9';
       END IF
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/ins_buro_credito.out";
	--TRACE ON;

	
    IF pRelanzar = 0 AND pInstitucion = status_1 THEN

        SELECT NVL(ingreso_mensual,0) INTO mIngresoMensual
        FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = pnum_solicitud;

        SELECT valor::int  INTO iMontoBuro  FROM bdisolic:"informix".ss_param WHERE secuencia = '326';

        IF NVL(mIngresoMensual,0) >= iMontoBuro AND pInstitucion = status_1 THEN  

-- Se obtienen las solicitudes que el cliente tiene en espera de ser calificada con la respuesta de Buro y/o Circulo
-- de credito y se evalua cada una respecto al producto de credito que se trate y continua su flujo una solicitud 
-- independiente de la otra. 
   FOREACH
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE- Se modifica Query para extraer el tipo de solicitud y validar la puntuacion conforme a esto.   
            SELECT num_solicitud,TRIM(tipo_calculo),tipo_solicitud,num_producto
              INTO csolicitud,v_mod_parame,v_tpsol,v_producto
              FROM bdisolic:"informix".ss_solicitudes
             WHERE empresa = pEmpresa
--               AND numcte = pnum_cliente
                 and num_solicitud = pnum_solicitud
               AND status_solicitud = pInstitucion
             ORDER BY num_producto

--IPCB Marzo2015 RQM 09 384-0 FICO SCORE  Se modifica query para extraer el grupo
--IPCB Marzo2016 RQM 09 398-0 FICO Extended Se incluye la extraccion de los meses de historia para el Fico Extended
           SELECT origen,grupo,meses_historia
             INTO corigen, cgrupo, v_meses
             FROM bdisolic:"informix".ss_resum_scor_fin
            WHERE empresa = pempresa
              AND num_solicitud = csolicitud;

            IF nvl(corigen,'') = "" THEN
				LET corigen = '0';
            END IF

			IF corigen = '1' THEN
				EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pempresa, pnum_cliente,csolicitud)
				INTO cod_ret, cCalifica, dCompromisos, vMensaje;
			ELSE
				EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito(pempresa, pnum_cliente, pnum_solicitud)
				INTO cod_ret, cCalifica, dCompromisos, vMensaje;
			END IF

            IF cod_ret <> "000" THEN
				RETURN '9';
			END IF 		
			
			--RQM 09 554 y RQM 09 606 FalloSIC
			IF cflujo_cc = '1' AND cCalifica <> 'X' AND vFalloSIC = 0 THEN
				
			--buenos antecedentes o malos antecedentes
				--Numero de producto
				select trim(valor) into tipo_acceso_bc
				from bdiburo:br_param
				where cod_param = 153;  

				--Usuario Prospector
				select trim(valor) into usu_orden2
				from bdiburo:br_param
				where cod_param = 154;   
				
				--Password Prospector
				select trim(valor) into pass_orden2
				from bdiburo:br_param
				where cod_param = 155;                           

				INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
				SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
				num_solicitud = pnum_solicitud;
				
				IF v_producto <> '6500' THEN
				
					LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
						INTO cod_ret;
					
				END IF;	
				
					IF csolicitud = pnum_solicitud THEN
						let s_regreso = '1';
					ELSE
						let s_regreso = '0';
					END IF;

			END IF			
		--REM Inicio para Inhabilitar todo el bloque de FICO SCORE Y FICO EXTEND
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE Grupo 3 y 5 Hit--  se cambia condicion y se activa bloque para Fico Score	
--IPCB Octubre2015 RQM 09 384-3 FICO SCORE--Incluir grupos 1,A,2, Hit. --Se incluyen en el cgrupo
        /* IF (v_mod_parame in('2') AND  cCalifica = "0"  AND cgrupo in ('1','2','3','5','A','8') AND v_tpsol IN ( 'T','P') ) AND cflujo_cc = '0' THEN
			SELECT sc01::INTEGER INTO v_valor_1s
			  FROM bdiburo:"informix".br_sc a
			 WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= pnum_cliente AND sc00 <> "004")
              AND institucion = 'BC'
			  AND num_cliente=pnum_cliente
			  AND sc00 <> "004";
			  
			SELECT unique bc_scoremin, bc_scoremax
			  INTO v_bcs_min,v_bcs_max
			  FROM bdisolic:ss_scoring_modelo2
			 WHERE tp_solicitud IN ( 'T','P')
			   AND tp_solicitud = v_tpsol
			   AND grupo = cgrupo
			   AND grupo in ('1','2','3','5','A','8') 
			   AND fc_score_max > 0
			   AND status_sol = 'RT'
			   and num_producto = v_producto;

         --END IF;
			 		
			IF(v_valor_1s >= v_bcs_min and v_valor_1s <= v_bcs_max) THEN
                    IF s_regreso = '0' THEN            

-- JOM INI BCSCORE
                        if (status_2='BC') THEN
                            select trim(valor) into tipo_acceso_bc
                              from bdiburo:br_param
                              where cod_param = 126;                            

                            INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
                            SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
                            num_solicitud = pnum_solicitud;
                        else
						     select trim(valor) into tipo_acceso_cc
                              from bdiburo:br_param
                              where cod_param = 141; 
							  
							select num_solicitud_sic   INTO v_sol_sic  from bdisolic:"informix".ss_solicitudes_sic 
                            where numcte = pnum_cliente
							and num_solicitud = pnum_solicitud; 
							
							IF (pnum_solicitud = v_sol_sic ) then							
								INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
								SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
								num_solicitud = pnum_solicitud;
							ELSE
							   INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
							   SELECT status_2, pnum_cliente,csolicitud,  replace(substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)),trim(v_sol_sic),trim(pnum_solicitud)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
							   num_solicitud = v_sol_sic;   
							END IF;
                        end if;
-- JOM FIN BCSCORE

                       IF status_2='CC' THEN
                         LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO';
                       ELSE 
                         LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
                       END IF;

                        EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
                        INTO cod_ret;

                        IF csolicitud = pnum_solicitud THEN
                            let s_regreso = '1';
                        ELSE
                            let s_regreso = '0';
                        END IF;
					
                    ELIF s_regreso = '1' THEN
		
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
							INTO cod_ret;
					END IF
			END IF


--IPCB Marzo2016 --RQM 09 398 FICO Extended  --INICIO 
-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{ 			  	
		 
		 ELIF  (v_mod_parame in('2') AND  cCalifica = "X"   AND cgrupo in ('1','2','3','5','A','8') AND v_tpsol IN ( 'T','P') ) AND cflujo_cc = '0' THEN
		 
			EXECUTE PROCEDURE bdisolic:"informix".sp_calculo_scpropietario(pempresa,csolicitud,cgrupo,v_tpsol,cCalifica,v_meses,v_producto) 	
			INTO v_valor_2s;
			
			SELECT unique NVL(pro_scormin,0)  --Extrae el valor minimo pra ser aprobado por score propietario
				 INTO v_scor_prop_min
			   FROM bdisolic:"informix".ss_scoring_modelo2
			WHERE tp_solicitud IN ( 'T','P')
				  AND tp_solicitud = v_tpsol
				  AND respuesta_sic = DECODE(cCalifica,"X","X","0","0","2","1","3","1","4","1","1")
				  AND grupo = cgrupo
				  AND grupo in ('1','2','3','5','A','8') 
				  AND status_sol = 'AT'



				  and num_producto= v_producto AND tp_parametrico=v_mod_parame;
				  
			IF(v_valor_2s <  v_scor_prop_min) THEN
				IF s_regreso = '0' THEN            
					IF(status_2='BC') THEN
						select trim(valor) into tipo_acceso_bc
						  from bdiburo:br_param
						 where cod_param = 126;                            

						INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
						num_solicitud = pnum_solicitud;
					--ELSE -- AAME 20180828 [RQI27201] INI
						--select trim(valor) into tipo_acceso_cc
                        --  from bdiburo:br_param
                        -- where cod_param = 142; 
					
						--select num_solicitud_sic   INTO v_sol_sic  from bdisolic:"informix".ss_solicitudes_sic 
                        --    where numcte = pnum_cliente
						--	and num_solicitud = pnum_solicitud;
							 
					    --IF (pnum_solicitud = v_sol_sic ) then
						--   INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						--   SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
						--   num_solicitud = pnum_solicitud;
						--ELSE
						--   INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						--   SELECT status_2, pnum_cliente,csolicitud,  replace(substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)),trim(v_sol_sic),trim(pnum_solicitud)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
						--   num_solicitud = v_sol_sic;

						   
						--END IF;   -- AAME 20180828 [RQI27201] 
					END IF;

					IF status_2='CC' THEN
						--LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO'; -- AAME 20180828 [RQI27201] Se comenta para que no mande a Circulo para FICO EXTEND cuando sea No HIT
						let s_regreso = '0';
					ELSE 
						LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					--END IF;-- AAME 20180828 [RQI27201]

						EXECUTE PROCEDURE bdisolic:sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
						INTO cod_ret;
					

						IF csolicitud = pnum_solicitud THEN
							let s_regreso = '1';
						ELSE
							let s_regreso = '0';
						END IF;
					END IF;				ELIF s_regreso = '1' THEN
		
					EXECUTE PROCEDURE bdisolic:sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
					INTO cod_ret;
				END IF;
			END IF; 
			
-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended
--IPCB Marzo2016 --RQM 09 398 FICO Extended  --FIN	

        END IF;	*/	-- REM Fin para Inhabilitar todo el bloque de FICO SCORE Y FICO EXTEND		
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE  cierre bloque para Fico Score
     END FOREACH

-- fin caja unica
	END IF
	END IF;
    IF pRelanzar = 1 THEN --se valida si ya tiene un envio con vigencia a la espera de la respuesta de las SIC's

--set debug file to "/RESPALDOS/ipcb/pruebas/ins_buro_credito.unl";trace on; 

------consultas SIC --JMAH --se valida si el cliente tiene una respuesta pendiente.
	
		SELECT num_solicitud_sic
			INTO cNumSolSIC
		FROM bdisolic:"informix".ss_solicitudes_sic
		WHERE numcte= pnum_cliente	
		AND num_solicitud = pnum_solicitud
		AND fecha_sic IS NULL;		
			
			
		IF cNumSolSIC IS NULL  THEN--Cuando no tenga un envio pendiente
			LET iRenviar = 1;
		ELIF cNumSolSIC = pnum_solicitud  THEN --cuando la solicitud sea la misma que tengo pendiente
			LET iRenviar = 1;
		ELIF cNumSolSIC <>  pnum_solicitud THEN		
			--se valida que la solicitud se encuentre todavia en estatus de consulta
			SELECT count(*)
			INTO cuenta_solproc
			FROM bdisolic:ss_solicitudes
			WHERE empresa = pempresa
			AND num_solicitud = cNumSolSIC
			AND status_solicitud  IN (select status_solicitud from bdisolic:ss_status_sol where tipo_auto in (1,2));

			IF cuenta_solproc=0 THEN --cuando la solicitud sea diferente a la que esta pendiente, pero esta ya no se encuenta en estatus valido de consulta se reenvia
				LET iRenviar = 1;				
			ELIF cuenta_solproc = 1 THEN ----cuando la solicitud sea diferente a la que esta pendiente, pero esta se encuenta en estatus valido de consulta no se reenvia
				LET iRenviar = 0;	
			END IF;
		END IF


		IF iRenviar = 1  THEN
--IPCB agosto 2015 // Se quita el insert a la solicitudes sic por que en algunos casos genera registro duplicado en dicha tabla		
			IF cNumSolSIC IS NOT NULL THEN			
				UPDATE bdisolic:"informix".ss_solicitudes_sic
					SET num_solicitud_sic = pnum_solicitud					
				WHERE numcte= pnum_cliente				
				AND fecha_sic IS NULL
				AND num_solicitud = pnum_solicitud;				
			END IF;

			IF pInstitucion = status_1 THEN
				CALL "informix".burocred (pempresa, "0000", USER, pnum_solicitud, 0)
				RETURNING cod_ret;
					IF status_1='CC' THEN
					 LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO';
					ELSE 
					 LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					END IF;
					--RQM 09 308 Se agrega validacion para que no se ejecute el procedimiento que actualiza el estatus.
					IF sSolincremento = 0 THEN					
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', pnum_solicitud, status_1, "", mensaje_orden)
						INTO cod_ret;
					END IF;

				LET s_regreso = '1';
			ELSE 
			   IF pRelanzar = 1 AND pInstitucion = status_2 THEN
					DELETE FROM "informix".br_traslado WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
					DELETE FROM "informix".sb_regreso WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
--IPCB Mayo2016 Reingenieria de Demonios.
                    DELETE FROM "informix".br_respuesta WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
                    DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;    
					DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;  
--IPCB Mayo2016 Reingenieria de Demonios.
					--ini cas
					   DELETE FROM "informix".br_cr WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_hi WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_hr WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_iq WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_pa WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_pe WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_pn WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_rs WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_sc WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_tl WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					--fin cas
					UPDATE "informix".br_auditor SET comentario = "" WHERE institucion = status_2 AND solicitud = pnum_solicitud;
					--IPCB 12Abr21 Se corrige insert para el reenvio de BC con producto prospector
					--INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					--SELECT status_2, pnum_cliente,num_solicitud,  TRIM(SUBSTR(envio,1,40))||TRIM(usu_orden2)||TRIM(pass_orden2)||TRIM(SUBSTR(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM "informix".br_traslado WHERE institucion = status_1 AND
					--num_solicitud = pnum_solicitud;
					
					
					INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						SELECT status_2, pnum_cliente,num_solicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM "informix".br_traslado WHERE institucion = status_1 AND
						num_solicitud = pnum_solicitud;

					   IF status_2='CC' THEN
						 LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO';
					   ELSE 
						 LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					   END IF;
						--RQM 09 308 Se agrega validacion para que no se ejecute el procedimiento que actualiza el estatus.
					   IF sSolincremento = 0 THEN					   
						 EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', pnum_solicitud, status_2, "", mensaje_orden)
						INTO cod_ret;
					   END IF;
						LET s_regreso = '1';
			   END IF
			END IF
		ELSE			
		let s_regreso = '1';
		END IF;	
	END IF;
RETURN s_regreso;
END;
END PROCEDURE DOCUMENT "Version 1.00.000",
"MODIFICO: CARLOS OCHOA",
"DESCRIPCION: SE AGREGAN VALIDACIONES PARA QUE TRABAJE CON SOLICITUDES DE INCREMENTO DE LINEA";

create procedure "informix".burofisicas_concilia_cnr()
--EXECUTE PROCEDURE burofisicas_concilia_cnr();
       returning char(5);


   define vcodret                   char(5);
   define vsql                      char(1500);
   define iTotalProcesados          integer;
   define iSqlErr                   integer;
   define tb_total_sdo_actual       decimal(20,2);
   define tb_total_sdo_vencido      decimal(20,2);
   define tb_total_seg_tl           decimal(20);
   define tb_total_sdo_actual_bc    decimal(20,2);
   define tb_total_sdo_vencido_bc   decimal(20,2);
   define tb_total_seg_tl_bc        decimal(20);
   define tb_total_cps_bc           integer;
   define tb_total_cns              integer;
   define tb_total_no_procesados    integer;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vfecha_cinta              date;
   define vfecha_reporte 			char(08);   
   define vclave_usu                char(10);
   define vclave_usu_bc             char(10);

BEGIN

   on exception set iSqlErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   let vsql = "";
   let iTotalProcesados = 0;
   let tb_total_sdo_actual     = 0;
   let tb_total_sdo_vencido    = 0;
   let tb_total_seg_tl         = 0;
   let tb_total_seg_tl_bc      = 0;
   let tb_total_sdo_actual_bc  = 0;
   let tb_total_sdo_vencido_bc = 0;
   let tb_total_cps_bc         = 0;
   let tb_total_cns         = 0;
   let tb_total_no_procesados  = 0;
   let vdia  = '';
   let vmes  = '';
   let vanio = '';
   let vfecha_cinta = date(0);
   let vfecha_reporte = '';
   let vclave_usu   = '';
   let vclave_usu_bc    = '';

--SET DEBUG FILE TO "burofisicas_concilia_cnr.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 128;

	select  first 1 fecha_reporte  INTO vfecha_reporte
	from br_burofisicas_describe_cnr;

   let vdia  = substr(vfecha_reporte,1,2);
   let vmes  = substr(vfecha_reporte,3,2);
   let vanio = substr(vfecha_reporte,5,4);
   let vfecha_cinta = mdy(vmes,vdia,vanio);



-- Extracción Círculo de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofiscnr.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofiscnr.sql';
  system vsql;

  let vsql = 'echo "'||
             ' select registro from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''BY30560001'''||','||'''TGD0924BAN'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' ||
--                 ' trim(replace(registro,'||'''BY30560001'''||','||'''TGD0924BAN'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
			 ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' from bdiburo:br_burofisicas_describe_cnr where fecha_reporte = '''|| vfecha_reporte ||''';' ||
             ' " >> /resplogifx/burodecredito/genburofiscnr.sql';
 system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofiscnr.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofiscnr.unl > /resplogifx/burodecredito/xburofis1cnr.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1cnr.unl > /resplogifx/burodecredito/xburofis2cnr.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2cnr.unl > /resplogifx/burodecredito/xburofis1cnr.unl ";
  system vsql;

  LET vsql = "cat  /resplogifx/burodecredito/xburofis1cnr.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulocnr"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "gzip /resplogifx/burodecredito/cinta_circulocnr"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofiscnr.unl /resplogifx/burodecredito/xburofis1cnr.unl /resplogifx/burodecredito/xburofis2cnr.unl";    
  system vsql;   

  let vsql = '';


-- Extracción Buró de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis_bccnr.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis_bccnr.sql';
  system vsql;

  let vsql = 'echo "'||
--             ' select replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||') from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' select replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||''') from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' union ' ||
/*
             ' select case when a.registro matches '||'''*0208CONOCIDO*'''||' ' ||  
                   ' THEN trim(replace(registro,'||'''0208CONOCIDO'''||','||''''''||'))::lvarchar ' ||  
             ' else a.registro END ' ||
             '   from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''PA'''||' ' ||  
             ' union ' ||
*/
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''3002CV9903FIN'''||','||'''3002CV9903FIN'''||'))::lvarchar ' ||  
--                 ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' ||  
--                 ' trim(registro)::lvarchar' ||  
--                 ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             ' from bdiburo:br_burofisicas_describe_cnr where fecha_reporte = '''|| vfecha_reporte ||'''' ||
             ' " >> /resplogifx/burodecredito/genburofis_bccnr.sql';
 system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis_bccnr.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis_bccnr.unl > /resplogifx/burodecredito/xburofis1_bccnr.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1_bccnr.unl > /resplogifx/burodecredito/xburofis2_bccnr.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2_bccnr.unl > /resplogifx/burodecredito/xburofis1_bccnr.unl ";
  system vsql;

  LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bccnr.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_burocnr"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis_bccnr.unl /resplogifx/burodecredito/xburofis1_bccnr.unl /resplogifx/burodecredito/xburofis2_bccnr.unl";   
  system vsql;    

  let vsql = "gzip /resplogifx/burodecredito/cinta_burocnr"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = 'echo "------ CIFRAS GENERALES ------" > /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cns from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CNS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_no_procesados from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CNP' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select int_calculo into iTotalProcesados from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'TCP' and fecha_cinta = vfecha_cinta;
  
  let vsql = 'echo " TOTAL créditos procesados = => '||iTotalProcesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS BURO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

	

	SELECT --{+INDEX(br_burofisicas_cnr idx_burofisicas_cnr_reg)} 
		registro FROM bdiburo:br_burofisicas_cnr INTO TEMP reg_tl WITH NO LOG; -- ** RQI 21 331 

--  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)='BY30560001');
  --select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from reg_tl where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);

  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cps_bc from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CPS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por error en CÃ?Â³digo Postal = => '||tb_total_cps_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cps_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Buró de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  --select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  --from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from reg_tl where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
--  from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)='BY30560001');

  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS CIRCULO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl from bdiburo:br_burofisicas_describe_cnr; 

--  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl_bc + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Círculo de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual,tb_total_sdo_vencido
--  from bdiburo:br_burofisicas_describe_cnr;

--  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;
  
	BEGIN;
		DROP INDEX "informix".idx_burofisicas_cnr_reg;
	COMMIT;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cnr;

  return vcodret;

END;
end procedure;