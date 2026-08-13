CREATE PROCEDURE "informix".spsp_obtensdocont(
       p_naturaleza CHAR(1),      p_fecha DATE,
       p_fec_mes_ant DATE,        p_claveperiodicida VARCHAR(2),
       p_aniocontable SMALLINT,   p_mescontable SMALLINT,
       p_anioreporte SMALLINT,    p_mesreporte SMALLINT,
       p_auxiliar CHAR(9),        p_clavetiporep VARCHAR(2),
       p_tiposaldo VARCHAR(3),    p_fec_proyec DATE,
       p_empresa CHAR(3),         p_estado CHAR(2),
       p_opernacional CHAR(1),    p_ccmayor CHAR(4),
       p_ccsub CHAR(2),           p_ccsubsub CHAR(2),
       p_ccssubsub CHAR(2),       p_ccsssubsub CHAR(2),
       p_sector CHAR(2),          p_moneda CHAR(2),
       p_nivelobtencion SMALLINT, p_fechainicial DATE,
       p_unicatotal CHAR(1),      p_fechasaldo SMALLINT)
       RETURNING DECIMAL(18,4);
	   
	   
   --Declaracion de Variables
   --De Retorno
   DEFINE r_saldocontable DECIMAL(18,4);
   --Del QRY Meastro
   DEFINE v_cargos        DECIMAL(18,4);
   DEFINE v_abonos        DECIMAL(18,4);
   DEFINE v_acumulado     DECIMAL(18,4);
   DEFINE v_promedio      DECIMAL(18,4);
   DEFINE v_inicio        DECIMAL(18,4);
   DEFINE v_fin           DECIMAL(18,4);
   DEFINE v_dias          INTEGER;
   DEFINE v_clavereporte  varchar(10);
   DEFINE v_fechacal      date;
   --De Condicion
   DEFINE v_tabla         SMALLINT;
   DEFINE v_pais          CHAR(3);
   DEFINE v_encini        SMALLINT;
   DEFINE v_encfin        SMALLINT;
   DEFINE v_gpoini        SMALLINT;
   DEFINE v_gpofin        SMALLINT;
   DEFINE v_myrini        SMALLINT;
   DEFINE v_myrfin        SMALLINT;

   --Inicializa Variables
   LET r_saldocontable = 0;
   LET v_dias = day(p_fecha) - 1;
   --Obtiene grupo o encabezaso para cta mayor
   LET v_encini = 2 ;
   LET v_encfin = 2 ;
   LET v_gpoini = 2 ;
   LET v_gpofin = 3 ;
   LET v_myrini = 1 ;
   LET v_myrfin = 4 ;
   LET v_fechacal = p_fechainicial;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

     IF p_nivelobtencion = 0 OR p_nivelobtencion = 1 THEN
      IF p_unicatotal = 'G' OR p_unicatotal = 'E' THEN
         IF p_unicatotal = 'G' THEN
            LET v_myrini = 1 ;
            LET v_myrfin = 2 ;
         ELSE --entonces es 'E'
            LET v_myrini = 1 ;
            LET v_myrfin = 1 ;
         END IF;
      END IF;
   END IF;
   
   --Cambia la fecha inicial en caso de ser igual a la fecha del dia
   IF p_claveperiodicida = 'D' OR
      p_claveperiodicida = 'S' OR
      p_claveperiodicida = 'Q' THEN
      LET p_fechainicial = p_fecha;
   ELSE
      IF p_fechasaldo <> 13 AND
         p_fechasaldo <> 14 AND
         p_fechasaldo <> 15 AND
         p_fechasaldo <> 16 AND
         p_fechasaldo <> 18 THEN
         LET p_fechainicial = p_fecha;
      END IF;
      IF p_tiposaldo='AAA' OR p_tiposaldo='CAA' THEN
         LET p_fechainicial = v_fechacal;
      END IF;
   END IF;
   
   --Selecciona la tabla de acceso
   IF p_claveperiodicida = 'D' OR p_claveperiodicida = 'S' OR p_claveperiodicida = 'Q' THEN
      IF p_aniocontable != p_anioreporte OR p_mescontable != p_mesreporte THEN
         IF p_auxiliar = '000000000' THEN
            IF p_clavetiporep = 'C' THEN
               LET v_tabla = 1;
            ELSE
               LET v_tabla = 2;
            END IF;
         ELSE
            IF p_clavetiporep = 'C' THEN
               LET v_tabla = 3;
            ELSE
               LET v_tabla = 4;
            END IF;
         END IF;
      ELSE
         IF p_auxiliar = '000000000' THEN
            IF p_clavetiporep = 'C' THEN
               LET v_tabla = 1;
            ELSE
               LET v_tabla = 2;
            END IF;
         ELSE
            IF p_clavetiporep = 'C' THEN
               LET v_tabla = 3;
            ELSE
               LET v_tabla = 4;
            END IF;
         END IF;
      END IF;
   ELSE
      IF p_auxiliar = '000000000' THEN
         IF p_clavetiporep = 'C' THEN
            LET v_tabla = 1;
         ELSE
            LET v_tabla = 2;
         END IF;
      ELSE
         IF p_clavetiporep = 'C' THEN
            LET v_tabla = 3;
         ELSE
            LET v_tabla = 4;
         END IF;
      END IF;	  
      --Coloca la fecha a dias iniciales si es en meses por la fecha
		LET p_fecha 	     = p_fecha - day(p_fechainicial) + 1;
		LET p_fechainicial   = p_fechainicial - day(p_fechainicial) + 1;	      
   END IF;
   
   --Obtiene el Pais
   LET v_pais = '001';
   -- modificado para el Anexo 43
   --valida si es quincenal para el reporte Anexo 43 pueda ir al primer dia del mes que se quiere generar M
		SELECT r.clavereporte               
        INTO   v_clavereporte               
        FROM   bdirepaut:sp_controlproceso p, bdirepaut:sp_clavesreportes r
        WHERE  r.identautoridad = p.identautoridad
        AND    r.empresa = p.empresa
        AND    r.clavereporte = p.clavereporte
        AND    p.statusproceso IN ('P','R')
       -- AND    MONTH(p.fechacontroldia) = MONTH(v_fechacal)
        AND   (r.claveperiodicidad = p_claveperiodicida OR p_claveperiodicida = '')
        AND    r.clavetiporep IN ('C', 'N');   
   
   	--IF p_claveperiodicida = 'M' AND v_clavereporte = 'ANEXO43' OR v_clavereporte = 'ANEX43PREV'THEN			
   	IF  v_clavereporte = 'ANEXO43' OR  v_clavereporte = 'ANEX43PREV' THEN				
		    SELECT sum(SPSP_VERIFICA(s.cargos_dia, p_naturaleza )),
				   sum(SPSP_VERIFICA(s.abonos_dia, p_naturaleza )),
				   sum(SPSP_VERIFICA(s.saldo_acumulado, p_naturaleza )),
				   --sum(SPSP_VERIFICA(s.saldo_acumulado, p_naturaleza ) / v_dias ),
				   sum(SPSP_VERIFICA(s.saldo_fin_de_dia, p_naturaleza ) / v_dias ),
				   sum(SPSP_VERIFICA(s.saldo_inicio_dia, p_naturaleza )),
				   sum(SPSP_VERIFICA(s.saldo_fin_de_dia, p_naturaleza ))
			 INTO  v_cargos,v_abonos,v_acumulado,v_promedio,v_inicio, v_fin
			 FROM  sp_saldos_anexo s
		    WHERE  s.TBL   = v_tabla
			  AND  s.fecha = v_fechacal
			  AND  ((s.ccmayor    = p_ccmayor    AND p_nivelobtencion >= 2) OR (substr(s.ccmayor,v_myrini,v_myrfin) =substr(p_ccmayor,v_myrini,v_myrfin) AND p_nivelobtencion < 2))
			  AND  ((s.ccsub      = p_ccsub      AND p_nivelobtencion >= 2) OR (2 > p_nivelobtencion))
			  AND  ((s.ccsubsub   = p_ccsubsub   AND p_nivelobtencion >= 3) OR (3 > p_nivelobtencion))
			  AND  ((s.ccssubsub  = p_ccssubsub  AND p_nivelobtencion >= 4) OR (4 > p_nivelobtencion))
			  AND  ((s.ccsssubsub = p_ccsssubsub AND p_nivelobtencion >= 5) OR (5 > p_nivelobtencion))
			  AND  (s.sector      = p_sector     OR '00' = p_sector) 
			  AND  (s.moneda      = p_moneda)
			  AND  (s.auxiliar    = p_auxiliar   OR '000000000' = p_auxiliar);		
        INSERT INTO sp_generaconsol_log (clavereporte,parametros) 
		VALUES (v_clavereporte, p_naturaleza || ' ' || v_dias || ' ' || v_tabla || ' ' ||  p_empresa || ' ' ||  p_nivelobtencion || ' ' ||  p_ccmayor || ' ' ||  v_myrini || ' ' ||  v_myrfin || ' ' ||  p_ccsub || ' ' ||  p_ccsubsub || ' ' ||  p_ccssubsub || ' ' ||  p_ccsssubsub || ' ' ||  p_sector || ' ' ||  p_moneda || ' ' ||  p_fechainicial || ' ' ||  p_fecha || ' ' || p_auxiliar );
			  
	ELSE 	
		--Query Principal
		select sum(SPSP_VERIFICA(s.cargos_dia, p_naturaleza )),
				sum(SPSP_VERIFICA(s.abonos_dia, p_naturaleza )),
				sum(SPSP_VERIFICA(s.saldo_acumulado, p_naturaleza )),
				--sum(SPSP_VERIFICA(s.saldo_acumulado, p_naturaleza ) / v_dias ),
				sum(SPSP_VERIFICA(s.saldo_fin_de_dia, p_naturaleza ) / v_dias ),
				sum(SPSP_VERIFICA(s.saldo_inicio_dia, p_naturaleza )),
				sum(SPSP_VERIFICA(s.saldo_fin_de_dia, p_naturaleza ))
		INTO   v_cargos,   v_abonos, v_acumulado,
				v_promedio, v_inicio, v_fin
		FROM   sp_saldos s
		WHERE  s.TBL         = v_tabla
		AND    s.fecha BETWEEN p_fechainicial AND p_fecha
		AND   ((s.ccmayor    = p_ccmayor    AND p_nivelobtencion >= 2) OR (substr(s.ccmayor,v_myrini,v_myrfin) =substr(p_ccmayor,v_myrini,v_myrfin) AND p_nivelobtencion < 2))
		AND   ((s.ccsub      = p_ccsub      AND p_nivelobtencion >= 2) OR (2 > p_nivelobtencion))
		AND   ((s.ccsubsub   = p_ccsubsub   AND p_nivelobtencion >= 3) OR (3 > p_nivelobtencion))
		AND   ((s.ccssubsub  = p_ccssubsub  AND p_nivelobtencion >= 4) OR (4 > p_nivelobtencion))
		AND   ((s.ccsssubsub = p_ccsssubsub AND p_nivelobtencion >= 5) OR (5 > p_nivelobtencion))
		AND   (s.sector      = p_sector     OR '00' = p_sector) 
		AND   (s.moneda      = p_moneda)
		AND   (s.auxiliar    = p_auxiliar   OR '000000000' = p_auxiliar);
		
		INSERT INTO sp_generaconsol_log (clavereporte,parametros) 
		VALUES ('R01', p_naturaleza || ' ' || v_dias || ' ' || v_tabla || ' ' ||  p_empresa || ' ' ||  p_nivelobtencion || ' ' ||  p_ccmayor || ' ' ||  v_myrini || ' ' ||  v_myrfin || ' ' ||  p_ccsub || ' ' ||  p_ccsubsub || ' ' ||  p_ccssubsub || ' ' ||  p_ccsssubsub || ' ' ||  p_sector || ' ' ||  p_moneda || ' ' ||  p_fechainicial || ' ' ||  p_fecha || ' ' || p_auxiliar );
   End if 	
   --Asigna El Saldo Contable
   IF p_tiposaldo = "SIM" THEN
      LET r_saldocontable = v_inicio;
   
   ELIF p_tiposaldo = "SD " THEN
      LET r_saldocontable = v_fin;
   
   ELIF p_tiposaldo = "VSM" THEN
      LET r_saldocontable = v_inicio - v_fin;
   
   ELIF p_tiposaldo = "PDM" OR p_tiposaldo = "PMA" THEN
      LET r_saldocontable = v_promedio;
   
   ELIF p_tiposaldo = "SAD" OR p_tiposaldo = "SAM" THEN
      LET r_saldocontable = v_acumulado;
   
   ELIF p_tiposaldo = "AAM" OR p_tiposaldo = "AAA" THEN
      LET r_saldocontable = v_abonos;
   
   ELIF p_tiposaldo = "CAM" OR p_tiposaldo = "CAA" THEN
      LET r_saldocontable = v_cargos;
   
   ELIF p_tiposaldo = "MM " THEN
      LET r_saldocontable = v_cargos - v_abonos;
   
   ELIF p_tiposaldo = "SPM" THEN
      LET r_saldocontable = (v_fin * (p_fec_proyec - p_fecha) +
                             v_acumulado
                            ) / (p_fec_proyec - p_fec_mes_ant);
   END IF;
   
   IF p_naturaleza = "C" AND r_saldocontable > 0 THEN
      LET r_saldocontable = 0;
   END IF;
   
   IF p_naturaleza = "F" AND r_saldocontable < 0 THEN
      LET r_saldocontable = 0;
   END IF;
   
   --Fin del Proceso
   IF r_saldocontable IS NULL THEN
      LET r_saldocontable = 0;
   END IF;
   
   RETURN r_saldocontable;
END PROCEDURE;