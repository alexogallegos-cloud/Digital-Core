CREATE PROCEDURE "informix".sp_cat_actualiza_resultado_gestion_his(pempresa CHAR(3), ptipo_campania CHAR(1))
RETURNING CHAR(5);

--Fecha de Creación: 1/Febrero/2011
--Creado por: Enrique Lizárraga Lugo
--Proceso para la actualización del resultado de la gestión y la fecha de último contacto en cb_cat_directorio_cte_his

--Definición de variables de bitácora
DEFINE cCodRet 				CHAR(5);
DEFINE isqlerr 				INTEGER;
DEFINE isam_err	 			INTEGER;
DEFINE vProceso				CHAR(5);
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE vempresa				CHAR(3);
--Definición de variables de trabajo
DEFINE vcodigo_resultado 	SMALLINT;
DEFINE vnumcte				CHAR(20);
DEFINE vtipo_llamada		CHAR(1);
DEFINE vfh_movimiento		DATETIME YEAR TO FRACTION;

--Inicialización de variables
LET cCodRet = '00000';
LET isqlerr = 0;
LET isam_err = 0;
LET vProceso = 'argh';
LET error_info = '';
LET cMensaje = 'PROCESO EXITOSO';
LET vempresa = '001';
LET vcodigo_resultado = 0;
LET vnumcte = '';
LET vtipo_llamada = '';
LET vfh_movimiento = '';

BEGIN    
        ON EXCEPTION SET isqlerr, isam_err, error_info
            LET cCodret = isqlerr;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vProceso, cCodRet, cMensaje, '02');
			RETURN cCodRet;            
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/ids10_uc9/elizarraga/resgestion.out";
		--TRACE ON; 
		
	SET ISOLATION TO DIRTY READ;
	
		CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vProceso, cCodRet, cMensaje, '01');
		
	FOREACH
	SELECT {+INDEX(bdicobranza:cb_cat_resultado_llamada_his idx_resul_llamada_his)}{+INDEX(bdicobranza:cb_cat_tipo_resultado idx_tipo)} min(a.codigo_resultado), a.numcte, b.tipo_llamada 
	INTO vcodigo_resultado, vnumcte, vtipo_llamada
	FROM cb_cat_resultado_llamada_his a, cb_cat_tipo_resultado b 
	WHERE a.codigo_resultado = b.codigo_resultado
	AND a.empresa = pempresa
	and a.numcte <> ''
	AND a.tipo_campania = ptipo_campania
	AND b.tipo_llamada <> ''
	group by a.numcte, b.tipo_llamada
	order by a.numcte
	
	IF vtipo_llamada = 'C' THEN
		SELECT {+INDEX(bdicobranza:cb_cat_resultado_llamada_his idx_resul_llamada_his)}{+INDEX(bdicobranza:cb_cat_tipo_resultado idx_tipo)} max(a.fh_movimiento)
		INTO vfh_movimiento
		FROM cb_cat_resultado_llamada_his a, cb_cat_tipo_resultado b
		WHERE a.codigo_resultado = b.codigo_resultado
		AND a.empresa = pempresa
		AND a.numcte = vnumcte
		AND a.tipo_campania = ptipo_campania
		AND a.codigo_resultado = vcodigo_resultado
		AND b.tipo_llamada = 'C';
		
		UPDATE {+INDEX(bdicobranza:idx_directorio_his)} bdicobranza:cb_cat_directorio_cte_his set codigo_resultado = vcodigo_resultado, fecha_ultimo_contacto = vfh_movimiento
		WHERE empresa = pempresa and numcte = vnumcte and tipo_cobranza = ptipo_campania and fecha_insert <= vfh_movimiento and fecha_insert+30 > vfh_movimiento;
		
	ELSE
		UPDATE {+INDEX(bdicobranza:idx_directorio_his)} bdicobranza:cb_cat_directorio_cte_his SET codigo_resultado = vcodigo_resultado
		WHERE empresa = pempresa and numcte = vnumcte and tipo_cobranza = ptipo_campania and fecha_insert <= vfh_movimiento and fecha_insert+30 > vfh_movimiento;
	END IF;
	
	END FOREACH;
	
	CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vProceso, cCodRet, cMensaje, '03');
	RETURN cCodRet;
		
END;
END PROCEDURE;