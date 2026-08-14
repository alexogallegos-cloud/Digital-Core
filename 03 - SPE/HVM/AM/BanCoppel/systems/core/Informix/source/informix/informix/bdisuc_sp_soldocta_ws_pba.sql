CREATE PROCEDURE "informix".sp_soldocta_ws_pba(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
		pfolio_suc CHAR(16),
  		ptransaccion CHAR(4),
		pdivisa CHAR(2),
		pmonto_dot money(14,2),
		pfecha date,
		pdeno1 CHAR(18),
		pdeno2 CHAR(18),
		pdeno3 CHAR(18),
		pdeno4 CHAR(18),
		pdeno5 CHAR(18),
		pdeno6 CHAR(18),
		pdeno7 CHAR(18),
		pdeno8 CHAR(18),
		pdeno9 CHAR(18),
		pdeno10 CHAR(18),
		pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1 FLOAT(8),
		pcant2 FLOAT(8),
		pcant3 FLOAT(8),
		pcant4 FLOAT(8),
		pcant5 FLOAT(8),
		pcant6 FLOAT(8),
		pcant7 FLOAT(8),
		pcant8 FLOAT(8),
		pcant9 FLOAT(8),	
		pcant10 FLOAT(8),
		pcant11 FLOAT(8),
		pcant12 FLOAT(8),
		pcant13 FLOAT(8),
		pcant14 FLOAT(8),
		pcant15 FLOAT(8),
		pFlagActivaServicio CHAR(1))
		
		RETURNING CHAR(5) AS Retorno,CHAR(8) AS folio_oper,CHAR(25)AS id_servicio,CHAR(521) AS trama;
		
		
DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vplaza CHAR(3);
DEFINE vnum INTEGER;
DEFINE vFecha_formato,vFechaInsert CHAR(25);
DEFINE vidsolicitud,vidsolicitud1 CHAR(25);
DEFINE cId_servicio				VARCHAR(28);
DEFINE cMisc1					VARCHAR(40);
DEFINE cMisc2					VARCHAR(40);
DEFINE cMisc3					VARCHAR(40);
DEFINE cMisc4					VARCHAR(40);
DEFINE cMisc5					VARCHAR(40);
DEFINE cId_banco				VARCHAR(5);
DEFINE cTrama					CHAR(521);
DEFINE cConsecutivo				INTEGER;
DEFINE cAuxCons					CHAR(3);
DEFINE cMontoAnt 				CHAR(20);
DEFINE cHoraAParam				CHAR(5);	
DEFINE cproveedor				CHAR(4);
DEFINE cpanamericano 			CHAR(4);


LET vcodret = "000";
LET vplaza = "";
LET vhora = SUBSTR(CURRENT,12,5);
LET vnum = 0;
LET vfolio = "";
LET vsqlerr = 0;
LET visamerr = 0;
LET vFecha_formato = "";
LET vFechaInsert = "";
LET vidsolicitud = "";
LET vidsolicitud1 = "";
LET cId_servicio = '0                            ';	
LET cMisc1 = psucursal;	
LET cMisc2 = '0                                       ';			
LET cMisc3 = '0                                       ';					
LET cMisc4 = '0                                       ';					
LET cMisc5 = '0                                       ';
LET cId_banco	= '67   ';	
LET cTrama = '';
LET cConsecutivo = 1;
LET cAuxCons = '001';
LET cMontoAnt = '';
LET cHoraAParam = '';
LET cproveedor = '';
LET cpanamericano = '';

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio,vidsolicitud,cTrama;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

--SET DEBUG FILE TO "/tem/soldocta.out";
--TRACE ON;

--- Verifica recepcion correcta de datos
IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR
   pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' OR pcajeroprincipal = ''
   OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = ''
   OR pmonto_dot = 0 THEN
   LET vcodret = "110";
ELSE

    SELECT plaza_cajagen INTO vplaza
    FROM   bdinteg: "informix".si_sucursales
    WHERE  sucursal = psucursal;
	
	SELECT p.cod_proveedor
	INTO cproveedor
	FROM  "informix".ss_proveedores p, bdinteg: "informix".si_sucursales s
	WHERE p.plaza = s.plaza_cajagen
	AND s.empresa = pempresa
	AND s.sucursal = psucursal;
			
	SELECT sucursal
	INTO cpanamericano
	FROM  "informix".ss_sucursales_panamericano
	WHERE centro_costos = cproveedor;	
	
	
	
	SELECT valor INTO cHoraAParam
	FROM  "informix".ss_param_cajagen
	WHERE codigo = '0044';
		
	
 
	IF TO_CHAR(current, "%H:%M:%S") <= cHoraAParam THEN
    
		SELECT  ent.monto
		INTO cMontoAnt
		FROM  "informix".ss_mae_entradasalida ent,  "informix".ss_operaciones op
		WHERE SUBSTRING (ent.id_solicitud  FROM 0 FOR 4 ) = 'DOT' 
		AND DATE(ent.fecha_solicitud) = DATE(CURRENT)
		AND ent.id_solicitud = op.id_solicitud
		AND ent.monto = op.monto	
		AND op.reversado <> '1' 
		AND ent.sucursal = psucursal
		AND ent.monto IN 
		(
			SELECT  ent.monto
			--INTO cMontoAnt
			FROM  "informix".ss_mae_entradasalida ent,  "informix".ss_operaciones op
			WHERE SUBSTRING (ent.id_solicitud  FROM 0 FOR 4 ) = 'DOT' 
			AND DATE(ent.fecha_solicitud) = DATE(CURRENT)
			AND ent.id_solicitud = op.id_solicitud
			AND ent.monto = pmonto_dot
			AND ent.sucursal = psucursal
			AND op.reversado <> '1' 
		)
		GROUP BY ent.monto;
			
	
	IF NVL(cMontoAnt,'') = '' THEN
		LET cMontoAnt = '0';
	END IF;
	
		--IF cMontoAnt <> pmonto_dot::CHAR(20)  THEN
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN --<-- si la Ãºltima sentencia trae registros entonces ya existe el monto en la dotaciÃ³n del dÃ­a.
		   IF  (SELECT COUNT(*) FROM  "informix".ss_proveedores WHERE cod_proveedor = cproveedor) > 0 THEN

				SELECT valor INTO vnum
				FROM    "informix".ss_param_cajagen
				WHERE  codigo = '0005';

				UPDATE  "informix".ss_param_cajagen
				SET    valor = valor + 1
				WHERE  codigo = '0005';
				
				--SELECT NVL(MAX (SUBSTRING (ent.id_solicitud  FROM 16 FOR 3 )), '')
				--INTO cAuxCons
				--FROM  "informix".ss_mae_entradasalida ent,  "informix".ss_operaciones op
				--WHERE SUBSTRING (ent.id_solicitud  FROM 0 FOR 4 ) = 'DOT'  --right
				--AND  ent.id_solicitud <> ''
				--AND DATE(ent.fecha_solicitud) = DATE(CURRENT)
				--AND ent.id_solicitud = op.id_solicitud;	
				
				
				 SELECT  right(trim(max(ent.id_solicitud)),3) 
				 INTO cAuxCons
				 FROM  "informix".ss_mae_entradasalida ent,  "informix".ss_operaciones op
				 WHERE ent.id_solicitud <> ''
				 AND left(trim(ent.id_solicitud),3) = 'DOT'
				 AND DATE(ent.fecha_solicitud) = DATE(CURRENT)
				 AND ent.id_solicitud = op.id_solicitud
				 AND op.reversado <> '1' 
				 AND ent.sucursal = psucursal;	--'0002'
 
							
				IF  NVL(cAuxCons,'') <> '' THEN
				
					LET cConsecutivo = cAuxCons + 1;	
					
				END IF;

				LET vfolio = LPAD(vnum,8,"0");
				LET vFecha_formato = LPAD(DAY(pfecha),2,0) ||'/'|| LPAD(MONTH(pfecha),2,0) ||'/'|| YEAR(pfecha);		   
				
				IF pFlagActivaServicio = '0' THEN
				
				   LET vidsolicitud1 = '';
				   LET vidsolicitud = '';
				   
                Else		
					--LET vidsolicitud1 = "DOT" || psucursal ||TRIM(REPLACE(vFecha_formato,"/","")) || LPAD(cConsecutivo,3,'0');
					LET vidsolicitud1 = "DOT" ||"|"|| psucursal ||"|" || TRIM(REPLACE(vFecha_formato,"/",""))  ||"|"|| LPAD(cConsecutivo,3,'0');
					LET vidsolicitud = "DOT" ||"|"|| psucursal::int ||"|" ||TRIM(REPLACE(vFecha_formato,"/","")) ||"|"|| LPAD(cConsecutivo,3,'0') ;
									
				END IF;
				
				LET vFechaInsert = current;
				
			   INSERT INTO  "informix".ss_operaciones
				  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,id_solicitud,folio_oper,reversado,usuario,divisa,monto,
				   denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
				   denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
				   denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
				   cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
				   cantidad_13,cantidad_14,cantidad_15)
			   VALUES
				  (pempresa,ptransaccion,pfecha,lpad(psucursal,4, "0"),pfolio_suc,vidsolicitud1,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
				   pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
			   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
			   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

			   INSERT INTO  "informix".ss_mae_entradasalida
				   (empresa,cod_proveedor,id_solicitud,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
					status,monto)
			   VALUES (pempresa,cproveedor,vidsolicitud1,vfolio,lpad(psucursal,4, "0"),pfolio_suc,pfecha,vhora,pcajeroprincipal,'01',pmonto_dot);

			    
				
			    LET cTrama = RPAD('0', 8 , " ") || RPAD('0', 8 , " ") || RPAD(pcant4::INT, 8 , " ") || RPAD(pcant1::INT,8, " ") || RPAD('0'::INT,8, " ") || 
							RPAD(pcant6::INT,8, " ") || RPAD(pcant3::INT,8, " ")  || RPAD('0'::INT,8, " ")  || RPAD(pcant5::INT,8, " ")  || RPAD(pcant2::INT,8, " ") || 
							RPAD('MXN',3, " ") || RPAD( TO_CHAR(current + 1 UNITS DAY, "%d/%m/%Y %H:%M:%S"),19, " ") || RPAD( TO_CHAR(current, "%d/%m/%Y %H:%M:%S"),19, " ") ||
							RPAD(cId_banco,5, " ")|| RPAD(psucursal::INT,8, " ") ||RPAD(cId_servicio,28, " ") || RPAD(vidsolicitud ,25, " ") || RPAD(cMisc1::INT,40, " ") || 
							RPAD(cMisc2,40, " ") || RPAD(cMisc3,40, " ") || RPAD(cMisc4,40, " ") || RPAD(cMisc5,40, " ") || RPAD('0',8, " ") || RPAD('0',8, " ") || 
							RPAD(pcant15::INT,8, " ") || RPAD(pcant14::INT,8, " ")|| RPAD('0'::INT,8, " ") || RPAD(pcant13::INT,8, " ") || RPAD(pcant12::INT,8, " ") || 
							RPAD(pcant9::INT,8, " ") || RPAD(pcant8::INT,8, " ") || RPAD(pcant11::INT ,8, " ") || RPAD('0'::INT,8, " ") || RPAD(pcant10::INT,8, " ") || 
							RPAD('0'::INT,8, " ") || RPAD(pmonto_dot::decimal(14,2),15, " ") || RPAD(cpanamericano,3, " ")|| RPAD('S',1, " ")|| RPAD('S',1, " ");
				
				
		   ELSE

				LET vcodret = "105";
		   
		   END IF;
		ELSE
			LET vcodret = '1050';
		END IF;
	ELSE
		LET vcodret = '1051';
	END IF;
END IF;

RETURN vcodret,vfolio,replace(vidsolicitud1, "|",""),cTrama;
END;
END PROCEDURE
DOCUMENT
'FOLIO: 380.1 - Adendum RQI 14 322 Monitor de efectivo BanCoppel',
'AUTOR: Irma Ureta',
'FECHA: 02/03/2018',
'MODIFICACIÃ?N: Se clona sp_soldocta con nombre sp_soldocta_ws para guardar el id de solicitud de dotaciÃ³n',
'SOLICITA: Abraham Nervaez',
'DB: bdisuc',
'FOLIO: 421.1 - Adendum - Monitor de efectivo BanCoppel',
'AUTOR: Veronica Rodriguez',
'FECHA: 17/07/2018',
'MODIFICACIÃ?N: Se agrega un nuevo parametro de entrada, si el parametro viene en 0 no deberÃ¡ de insertar valor en el campo id_solicitud, si viene en 1 si deberÃ¡ de insertar valor en el campo id_solicitud.',
'SOLICITA: Alejandro Sanchez',
'DB: bdisuc'
;

CREATE PROCEDURE "informix".sp_soldocta_ws(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
		pfolio_suc CHAR(16),
  		ptransaccion CHAR(4),
		pdivisa CHAR(2),
		pmonto_dot money(14,2),
		pfecha date,
		pdeno1 CHAR(18),
		pdeno2 CHAR(18),
		pdeno3 CHAR(18),
		pdeno4 CHAR(18),
		pdeno5 CHAR(18),
		pdeno6 CHAR(18),
		pdeno7 CHAR(18),
		pdeno8 CHAR(18),
		pdeno9 CHAR(18),
		pdeno10 CHAR(18),
		pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1 FLOAT(8),
		pcant2 FLOAT(8),
		pcant3 FLOAT(8),
		pcant4 FLOAT(8),
		pcant5 FLOAT(8),
		pcant6 FLOAT(8),
		pcant7 FLOAT(8),
		pcant8 FLOAT(8),
		pcant9 FLOAT(8),	
		pcant10 FLOAT(8),
		pcant11 FLOAT(8),
		pcant12 FLOAT(8),
		pcant13 FLOAT(8),
		pcant14 FLOAT(8),
		pcant15 FLOAT(8),
		pFlagActivaServicio CHAR(1))
		
		RETURNING CHAR(5) AS Retorno,CHAR(8) AS folio_oper,CHAR(25)AS id_servicio,CHAR(521) AS trama;
		
		
DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vnum INTEGER;
DEFINE vFecha_formato,vFechaInsert CHAR(25);
DEFINE vidsolicitud,vidsolicitud1 CHAR(25);
DEFINE cId_servicio				VARCHAR(28);
DEFINE cMisc1					VARCHAR(40);
DEFINE cMisc2					VARCHAR(40);
DEFINE cMisc3					VARCHAR(40);
DEFINE cMisc4					VARCHAR(40);
DEFINE cMisc5					VARCHAR(40);
DEFINE cId_banco				VARCHAR(5);
DEFINE cTrama					CHAR(521);
DEFINE cConsecutivo				INTEGER;
DEFINE cAuxCons					CHAR(3);
DEFINE cMontoAnt 				CHAR(20);
DEFINE cHoraAParam				CHAR(5);	
DEFINE cproveedor				CHAR(4);
DEFINE cpanamericano 			CHAR(4);


LET vcodret = "000";
LET vhora = SUBSTR(CURRENT,12,5);
LET vnum = 0;
LET vfolio = "";
LET vsqlerr = 0;
LET visamerr = 0;
LET vFecha_formato = "";
LET vFechaInsert = "";
LET vidsolicitud = "";
LET vidsolicitud1 = "";
LET cId_servicio = '0                            ';	
LET cMisc1 = psucursal;	
LET cMisc2 = '0                                       ';			
LET cMisc3 = '0                                       ';					
LET cMisc4 = '0                                       ';					
LET cMisc5 = '0                                       ';
LET cId_banco	= '67   ';	
LET cTrama = '';
LET cConsecutivo = 1;
LET cAuxCons = '001';
LET cMontoAnt = '';
LET cHoraAParam = '';
LET cproveedor = '';
LET cpanamericano = '';

BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
	   IF vsqlerr != 0 THEN
		  LET vcodret=vsqlerr;
		  RETURN vcodret,vfolio,vidsolicitud,cTrama;
	   END IF;
	END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

	--SET DEBUG FILE TO "/tmp/sp_soldocta_ws.out";
	--TRACE ON;

	--- Verifica recepcion correcta de datos
	IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR
	   pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' OR pcajeroprincipal = ''
	   OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = ''
	   OR pmonto_dot = 0 THEN
	   LET vcodret = "110";
	ELSE
		
		SELECT p.cod_proveedor
		INTO cproveedor
		FROM  "informix".ss_proveedores p, bdinteg: "informix".si_sucursales s
		WHERE p.plaza = s.plaza_cajagen
		AND s.empresa = pempresa
		AND s.sucursal = psucursal;
				
		SELECT sucursal
		INTO cpanamericano
		FROM  "informix".ss_sucursales_panamericano
		WHERE centro_costos = cproveedor;	
			
		SELECT valor INTO cHoraAParam
		FROM  "informix".ss_param_cajagen
		WHERE codigo = '0044';
					 
		IF TO_CHAR(current, "%H:%M:%S") <= cHoraAParam THEN
		
			SELECT  limit 1 ent.monto
			INTO cMontoAnt
			FROM  "informix".ss_mae_entradasalida ent,  "informix".ss_operaciones op
			WHERE ent.cod_proveedor = cproveedor
			AND ent.sucursal = psucursal
			AND ent.fecha_solicitud = DATE(CURRENT)
			AND ent.id_solicitud <> ''
			--AND SUBSTRING (ent.id_solicitud  FROM 0 FOR 4 ) = 'DOT' --Se comenta porque de esta manera se rompen indices
			AND LEFT(TRIM(ent.id_solicitud),3) = 'DOT'
			AND ent.folio_oper = op.folio_oper
			AND ent.monto = pmonto_dot
			AND op.reversado <> '1';
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN --<-- si la ÃÂºltima sentencia trae registros entonces ya existe el monto en la dotaciÃÂ³n del dÃÂ­a.
			   --IF  (SELECT 1 FROM  "informix".ss_proveedores WHERE cod_proveedor = cproveedor) > 0 THEN
			   
			   LET cproveedor = TRIM(NVL(cproveedor,''));
			   
			   IF  (cproveedor != '') THEN

					SELECT valor INTO vnum
					FROM    "informix".ss_param_cajagen
					WHERE  codigo = '0005';

					UPDATE  "informix".ss_param_cajagen
					SET    valor = valor + 1
					WHERE  codigo = '0005';
									
					SELECT  RIGHT(TRIM(MAX(ent.id_solicitud)),3) 
					INTO cAuxCons
					FROM  "informix".ss_mae_entradasalida ent , "informix".ss_operaciones op
					WHERE ent.cod_proveedor = cproveedor
					AND ent.sucursal = psucursal
					AND ent.fecha_solicitud = DATE(CURRENT)
					AND ent.id_solicitud <> ''
					AND LEFT(TRIM(ent.id_solicitud),3) = 'DOT'
					AND ent.folio_oper = op.folio_oper
					AND op.reversado <> '1';
								
					IF  NVL(cAuxCons,'') <> '' THEN
					
						LET cConsecutivo = cAuxCons + 1;	
						
					END IF;

					LET vfolio = LPAD(vnum,8,"0");
					LET vFecha_formato = LPAD(DAY(pfecha),2,0) ||'/'|| LPAD(MONTH(pfecha),2,0) ||'/'|| YEAR(pfecha);		   
					
					IF pFlagActivaServicio = '0' THEN
					
					   LET vidsolicitud1 = '';
					   LET vidsolicitud = '';
					   
					Else		
						--LET vidsolicitud1 = "DOT" || psucursal ||TRIM(REPLACE(vFecha_formato,"/","")) || LPAD(cConsecutivo,3,'0');
						LET vidsolicitud1 = "DOT" ||"|"|| psucursal ||"|" || TRIM(REPLACE(vFecha_formato,"/",""))  ||"|"|| LPAD(cConsecutivo,3,'0');
						LET vidsolicitud = "DOT" ||"|"|| psucursal::int ||"|" ||TRIM(REPLACE(vFecha_formato,"/","")) ||"|"|| LPAD(cConsecutivo,3,'0') ;
										
					END IF;
					
					LET vFechaInsert = current;
					
				   INSERT INTO  "informix".ss_operaciones
					  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,id_solicitud,folio_oper,reversado,usuario,divisa,monto,
					   denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
					   denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
					   denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
					   cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
					   cantidad_13,cantidad_14,cantidad_15)
				   VALUES
					  (pempresa,ptransaccion,pfecha,lpad(psucursal,4, "0"),pfolio_suc,vidsolicitud1,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
					   pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
				   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
				   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

				   INSERT INTO  "informix".ss_mae_entradasalida
					   (empresa,cod_proveedor,id_solicitud,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
						status,monto)
				   VALUES (pempresa,cproveedor,vidsolicitud1,vfolio,lpad(psucursal,4, "0"),pfolio_suc,pfecha,vhora,pcajeroprincipal,'01',pmonto_dot);
					
					LET cTrama = RPAD('0', 8 , " ") || RPAD('0', 8 , " ") || RPAD(pcant4::INT, 8 , " ") || RPAD(pcant1::INT,8, " ") || RPAD('0'::INT,8, " ") || 
								RPAD(pcant6::INT,8, " ") || RPAD(pcant3::INT,8, " ")  || RPAD('0'::INT,8, " ")  || RPAD(pcant5::INT,8, " ")  || RPAD(pcant2::INT,8, " ") || 
								RPAD('MXN',3, " ") || RPAD( TO_CHAR(current + 1 UNITS DAY, "%d/%m/%Y %H:%M:%S"),19, " ") || RPAD( TO_CHAR(current, "%d/%m/%Y %H:%M:%S"),19, " ") ||
								RPAD(cId_banco,5, " ")|| RPAD(psucursal::INT,8, " ") ||RPAD(cId_servicio,28, " ") || RPAD(vidsolicitud ,25, " ") || RPAD(cMisc1::INT,40, " ") || 
								RPAD(cMisc2,40, " ") || RPAD(cMisc3,40, " ") || RPAD(cMisc4,40, " ") || RPAD(cMisc5,40, " ") || RPAD('0',8, " ") || RPAD('0',8, " ") || 
								RPAD(pcant15::INT,8, " ") || RPAD(pcant14::INT,8, " ")|| RPAD('0'::INT,8, " ") || RPAD(pcant13::INT,8, " ") || RPAD(pcant12::INT,8, " ") || 
								RPAD(pcant9::INT,8, " ") || RPAD(pcant8::INT,8, " ") || RPAD(pcant11::INT ,8, " ") || RPAD('0'::INT,8, " ") || RPAD(pcant10::INT,8, " ") || 
								RPAD('0'::INT,8, " ") || RPAD(pmonto_dot::decimal(14,2),15, " ") || RPAD(cpanamericano,3, " ")|| RPAD('S',1, " ")|| RPAD('S',1, " ");
					
					
			   ELSE

					LET vcodret = "105";
			   
			   END IF;
			ELSE
				LET vcodret = '1050';
			END IF;
		ELSE
			LET vcodret = '1051';
		END IF;
	END IF;

	RETURN vcodret,vfolio,replace(vidsolicitud1, "|",""),cTrama;
END;
END PROCEDURE
DOCUMENT
'FOLIO: 380.1 - Adendum RQI 14 322 Monitor de efectivo BanCoppel',
'AUTOR: Irma Ureta',
'FECHA: 02/03/2018',
'MODIFICACIÃ?N: Se clona sp_soldocta con nombre sp_soldocta_ws para guardar el id de solicitud de dotaciÃÂ³n',
'SOLICITA: Abraham Nervaez',
'DB: bdisuc',
'FOLIO: 421.1 - Adendum - Monitor de efectivo BanCoppel',
'AUTOR: Veronica Rodriguez',
'FECHA: 17/07/2018',
'MODIFICACIÃ?N: Se agrega un nuevo parametro de entrada, si el parametro viene en 0 no deberÃÂ¡ de insertar valor en el campo id_solicitud, si viene en 1 si deberÃÂ¡ de insertar valor en el campo id_solicitud.',
'SOLICITA: Alejandro Sanchez',
'DB: bdisuc'
;

CREATE PROCEDURE "informix".sp_act_solicitud_recoleccion()

RETURNING CHAR(5) as cod_ret,CHAR(40) as descripcion;

DEFINE cCodRet CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE iContador INTEGER;
DEFINE cMsjRet CHAR(40);



LET cCodRet = "00000";
LET icontador = '';  
LET cMsjRet = '';



BEGIN

ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET cCodRet=vsqlerr;
      RETURN cCodRet,cMsjRet;
   END IF;
   
END EXCEPTION;

		--SET DEBUG FILE TO '/informix/calizarraga/sp_act_solicitud_recoleccion.out';
		--TRACE ON;
		

LET cCodRet = '00000';

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

SELECT {+INDEX (bdisuc:ss_mae_entradasalida idx_mae_entradasalida02)} COUNT(*) INTO iContador FROM bdisuc:"informix".ss_mae_entradasalida WHERE status = '16';

IF iContador > 0 THEN
UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1' WHERE folio_oper IN (SELECT folio_oper FROM bdisuc:"informix".ss_mae_entradasalida WHERE status = '16');
UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '08' WHERE status = '16';

LET cMsjRet = 'ACTUALIZACION EXITOSA';
ELSE
LET cMsjRet = 'NO HAY REGISTROS PARA ACTUALIZAR';
END IF;

RETURN cCodRet, cMsjRet;


END;

END PROCEDURE;