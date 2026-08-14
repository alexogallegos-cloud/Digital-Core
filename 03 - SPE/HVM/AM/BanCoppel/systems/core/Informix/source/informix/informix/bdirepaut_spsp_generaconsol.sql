CREATE PROCEDURE "informix".spsp_generaconsol(p_identautoridad    varchar(9),
                                   p_empresa           char(3),
                                   p_clavereporte      varchar(10),
                                   p_fechadia          date,
                                   p_fechaproyec       date,
                                   p_fechamesant       date,
                                   p_fechadicant       date,
                                   p_fechaanioant      date,
                                   p_fechadiaanterior  date
                                  )
					
RETURNING char(3), varchar(255);
   --********** Definicion de Variables **********
   --Variables de Retorno
   DEFINE r_codret           char(3);
   DEFINE r_mensaje          varchar(255);
   -- Variables para inicializar
   DEFINE v_auxiliar         char(9);
   DEFINE v_autoridad_ant    char(8);
   DEFINE v_empresa_ant      char(3);
   DEFINE v_reporte_ant      char(10);
   DEFINE v_columna_ant      smallint;
   DEFINE v_moneda_mn        char(2);
   DEFINE v_moneda_dll       char(2);
   DEFINE v_moneda_udi       char(2);
   DEFINE v_aniocontable     smallint;
   DEFINE v_mescontable      smallint;
   DEFINE v_precio_contable  decimal(9,6);
   DEFINE v_precio_dolar     decimal(9,6);
   DEFINE v_naturaleza_cta   char(1);
   --Variables del Filtro
   DEFINE v_ccmayor          char(4);
   DEFINE v_ccsub            char(2);
   DEFINE v_ccsubsub         char(2);
   DEFINE v_ccssubsub        char(2);
   DEFINE v_ccsssubsub       char(2);
   DEFINE v_sector           char(2);
   --DEFINE v_numerorenglon    smallint;
   DEFINE v_numerorenglon     integer;
   DEFINE v_numerocolumna    smallint;
   DEFINE v_moneda           char(2);
   DEFINE v_opernacional     char(1);
   DEFINE v_naturaleza       char(1);
   DEFINE v_fechasaldo       smallint;
   DEFINE v_tiposaldo        varchar(3);
   DEFINE v_nivelobtencion   smallint;
   DEFINE v_signo			 char(1);
   DEFINE v_unicatotal       char(1);
   DEFINE v_codigoporcentaje smallint;
   --Variables para Fechas
   DEFINE v_fecha01          date;
   DEFINE v_fecha02          date;
   DEFINE v_fecha03          date;
   DEFINE v_fecha04          date;
   DEFINE v_fecha05          date;
   DEFINE v_fecha06          date;
   DEFINE v_fecha07          date;
   DEFINE v_fecha08          date;
   DEFINE v_fecha09          date;
   DEFINE v_fecha10          date;
   DEFINE v_fecha11          date;
   DEFINE v_fecha12          date;
   DEFINE v_fecinicial       date;
   DEFINE v_fecha            date;
   DEFINE v_fecha_hab		 date;
   --Variables Complemeto Fecha
   DEFINE v_anioreporte      smallint;
   DEFINE v_mesreporte       smallint;
   DEFINE v_proyecfecha      date;
   DEFINE v_mesantfecha      date;
   DEFINE v_mes              smallint;
   DEFINE v_anio             smallint;
   --Variables de Renglones
   DEFINE v_grupo            char(3);
   DEFINE v_estado           char(2);
   --Variables de Columnas
   DEFINE v_valoriza         smallint;
   DEFINE v_valorizacionmone char(2);
   --Variable de Cifras
   DEFINE v_divisioncifra    decimal(9,2);
   DEFINE v_claveredondeo    varchar(1);
   --Variable de Porcentajes
   DEFINE v_porcenriesgo     decimal(8,4);
   --Variables de Reportes
   DEFINE v_naturalezacuenta smallint;
   DEFINE v_claveperiodicida varchar(2);
   DEFINE v_clavetiporep     varchar(2);
   DEFINE v_clavecifras      smallint;
   --Variables del Proceso 2
   DEFINE v_saldocontable    decimal(18,4);
   DEFINE v_saldonacional    decimal(18,4);
   DEFINE v_saldocifra       decimal(18,4);

   --Inicializacion de Variables
   LET r_codret = '000';
   LET r_mensaje = 'PROCESO SATISFACTORIO';
   LET v_auxiliar = '000000000';
   LET v_autoridad_ant = 'XXXXXXXX';
   LET v_empresa_ant = 'XXX';
   LET v_reporte_ant = 'XXXXXXXXXX';
   LET v_columna_ant = 999;
   LET v_codigoporcentaje = 0;
   LET v_clavecifras = 0;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	
   -- Generar tabla de fecha habiles en una tabla fisica
   --- debe obtener el ultimo dia del ,es a generar 	
   
    --set debug file to "/INFORMIXDUMP/raldana/RQM04060Anexo43/bdirepaut/sp/spsp_generaconsol.out";
    --trace on;
					
   --Valores de las Monedas
   SELECT valor INTO v_moneda_mn  FROM bdinteg:si_param WHERE cod_param = 15
          and empresa=p_empresa;
   SELECT valor INTO v_moneda_udi FROM bdinteg:si_param WHERE cod_param = 16
          and empresa=p_empresa;
   SELECT valor INTO v_moneda_dll FROM bdinteg:si_param WHERE cod_param = 17
          and empresa=p_empresa;

   --Fecha Contable
   SELECT year(fecha_hoy), month(fecha_hoy)
   INTO   v_aniocontable, v_mescontable
   FROM   bdicont:co_fechas
   WHERE  empresa = p_empresa;

   --Obtiene las 12 Fechas con la fecha del dia
   EXECUTE PROCEDURE SPSP_FECHAS(p_fechadia)
           INTO v_fecha01, v_fecha02, v_fecha03,
                v_fecha04, v_fecha05, v_fecha06,
                v_fecha07, v_fecha08, v_fecha09,
                v_fecha10, v_fecha11, v_fecha12;
				
		
	
		
   --Para Cada Filtro del Reporte
   FOREACH SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector,
                  numerorenglon, numerocolumna, moneda,
                  opernacional, naturaleza, fechasaldo, tiposaldo,
                  nivelobtencion, signo, unicatotal, codigoporcentaje
           INTO   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector,
                  v_numerorenglon, v_numerocolumna, v_moneda,
                  v_opernacional, v_naturaleza, v_fechasaldo, v_tiposaldo,
                  v_nivelobtencion, v_signo, v_unicatotal, v_codigoporcentaje
           FROM   bdirepaut:sp_filtroreporte
           WHERE  identautoridad   = p_identautoridad
           AND    empresa          = p_empresa
           AND    clavereporte     = p_clavereporte
           AND    unicatotal       IN ("E", "G", "S")
           AND    ccmayor NOT IN ('','0000') 

           SELECT grupo
           INTO   v_grupo
           FROM   bdirepaut:sp_renglones
           WHERE  identautoridad   = p_identautoridad
           AND    empresa          = p_empresa
           AND    clavereporte     = p_clavereporte
           AND    numerorenglon    = v_numerorenglon
           AND    naturaleza       = v_naturaleza;

           SELECT naturalezacuenta, claveperiodicidad, clavetiporep, clavecifras
           INTO   v_naturalezacuenta, v_claveperiodicida, v_clavetiporep, v_clavecifras
           FROM   bdirepaut:sp_clavesreportes
           WHERE  identautoridad   = p_identautoridad
           AND    empresa          = p_empresa
           AND    clavereporte     = p_clavereporte;

           SELECT divisioncifra, claveredondeo
           INTO   v_divisioncifra, v_claveredondeo
           FROM   bdirepaut:sp_clavecifras
           WHERE  empresa          = p_empresa
           AND    clavecifras      = v_clavecifras;

           SELECT porcenriesgo
           INTO   v_porcenriesgo
           FROM   bdirepaut:sp_porcentajes
           WHERE  codigoporcentaje = v_codigoporcentaje
           AND    empresa = p_empresa;

           SELECT valorizacionmoneda, valoriza
           INTO   v_valorizacionmone, v_valoriza
           FROM   bdirepaut:sp_columnas
           WHERE  identautoridad   = p_identautoridad
           AND    empresa          = p_empresa
           AND    clavereporte     = p_clavereporte
           AND    numerocolumna    = v_numerocolumna;

      --Coloca Fecha y Fecha Inicial
      IF v_fechasaldo = 1 OR v_fechasaldo = 8 THEN
         LET v_fecha = p_fechadia;
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 2 THEN
         LET v_fecha = p_fechaproyec;
         LET v_fecinicial = mdy( 1, 1, year(p_fechaproyec));
      END IF;
      IF v_fechasaldo = 3 THEN
         LET v_fecha = p_fechamesant;
         LET v_fecinicial = mdy( 1, 1, year(p_fechamesant));
      END IF;
      IF v_fechasaldo = 4 THEN
         LET v_fecha = p_fechadicant;
         LET v_fecinicial = mdy( 1, 1, year(p_fechadicant));
      END IF;
      IF v_fechasaldo = 5 OR v_fechasaldo = 7 OR v_fechasaldo = 9 THEN
         LET v_fecha = p_fechaanioant;
         LET v_fecinicial = mdy( 1, 1, year(p_fechaanioant));
      END IF;
      IF v_fechasaldo = 10 OR v_fechasaldo = 13 THEN
         LET v_fecha = mdy( 3, 31, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 11 OR v_fechasaldo = 14 THEN
         LET v_fecha = mdy( 6, 30, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 12 OR v_fechasaldo = 15 THEN
         LET v_fecha = mdy( 9, 30, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 17 OR v_fechasaldo = 16 THEN
         LET v_fecha = mdy( 12, 31, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 18 THEN
         LET v_fecha = mdy( 12, 31, year(p_fechadicant));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadicant));
      END IF;
      IF v_fechasaldo = 19 THEN
         LET v_fecha = mdy( 01, 31, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 20 THEN
         LET v_fecha = mdy( 02, 28, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 21 THEN
         LET v_fecha = mdy( 03, 31, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 22 THEN
         LET v_fecha = mdy( 04, 30, year(p_fechadia));
         LET v_fecinicial = mdy( 1, 1, year(p_fechadia));
      END IF;
      IF v_fechasaldo = 6 THEN
         LET v_fecha = p_fechadiaanterior;
         LET v_fecinicial = mdy( 1, 1, year(p_fechadiaanterior));
      END IF;
      IF v_fechasaldo = 31 THEN
         LET v_fecha = v_fecha01;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha01));
      END IF;
      IF v_fechasaldo = 32 THEN
         LET v_fecha = v_fecha02;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha02));
      END IF;
      IF v_fechasaldo = 33 THEN
         LET v_fecha = v_fecha03;
        LET v_fecinicial = mdy( 1, 1, year(v_fecha03));

      END IF;
      IF v_fechasaldo = 34 THEN
         LET v_fecha = v_fecha04;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha04));
      END IF;
      IF v_fechasaldo = 35 THEN
         LET v_fecha = v_fecha05;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha05));
      END IF;
      IF v_fechasaldo = 36 THEN
         LET v_fecha = v_fecha06;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha06));
      END IF;
      IF v_fechasaldo = 37 THEN
         LET v_fecha = v_fecha07;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha07));
      END IF;
      IF v_fechasaldo = 38 THEN
         LET v_fecha = v_fecha08;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha08));
      END IF;
      IF v_fechasaldo = 39 THEN
         LET v_fecha = v_fecha09;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha09));
      END IF;
      IF v_fechasaldo = 40 THEN
         LET v_fecha = v_fecha10;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha10));
      END IF;
      IF v_fechasaldo = 41 THEN
         LET v_fecha = v_fecha11;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha11));
      END IF;
      IF v_fechasaldo = 42 THEN
         LET v_fecha = v_fecha12;
         LET v_fecinicial = mdy( 1, 1, year(v_fecha12));
      END IF;

      --Colocar el estado deacuerdo al Grupo
      IF v_grupo = "01" OR v_grupo = "02" OR v_grupo = "03"
      OR v_grupo = "04" OR v_grupo = "05" OR v_grupo = "06"
      OR v_grupo = "07" OR v_grupo = "08" OR v_grupo = "09"
      OR v_grupo = "10" OR v_grupo = "11" OR v_grupo = "12"
      OR v_grupo = "13" OR v_grupo = "14" OR v_grupo = "15"
      OR v_grupo = "16" OR v_grupo = "17" OR v_grupo = "18"
      OR v_grupo = "19" OR v_grupo = "20" OR v_grupo = "21"
      OR v_grupo = "22" OR v_grupo = "23" OR v_grupo = "24"
      OR v_grupo = "25" OR v_grupo = "26" OR v_grupo = "27"
      OR v_grupo = "28" OR v_grupo = "29" OR v_grupo = "30"
      OR v_grupo = "31" OR v_grupo = "32" THEN
         LET v_estado = v_grupo;
      ELSE
         LET v_estado = '00';
      END IF;

      --Coloca Fechas Reporte
      LET v_anioreporte = year(v_fecha);
      LET v_mesreporte = month(v_fecha);
      LET v_mesantfecha = p_fechamesant;
      LET v_proyecfecha = p_fechaproyec;

      --Cambio de Fecha
      IF v_fecha <= p_fechamesant THEN
         LET v_proyecfecha = v_fecha;
         LET v_mes = month(v_fecha);
         LET v_anio = year(v_fecha);
         LET v_mesantfecha = mdy(v_mes, 1, v_anio);
         LET v_mesantfecha = p_fechamesant - 1;
      END IF;

      --Asigna El Saldo Contable
      LET v_saldocontable = 0;
	-- si son reportes anexo. obtiene el saldo por cada fecha del filtro
	IF  p_clavereporte = 'ANEXO43' OR  p_clavereporte =  'ANEX43PREV'THEN
	--IF  p_clavereporte = 'ANEXO43' THEN	
      
	 FOREACH WITH HOLD
 	  SELECT fechacaptura 
	    INTO v_fecha_hab
	    FROM tmp_weekday
	   ORDER BY fechacaptura
	  			 
				 
				 
		EXECUTE PROCEDURE SPSP_OBTENSDOCONT(
							v_naturaleza,       v_fecha,          v_mesantfecha,
							v_claveperiodicida, v_aniocontable,   v_mescontable,
							v_anioreporte,      v_mesreporte,     v_auxiliar,
							v_clavetiporep,     v_tiposaldo,      v_proyecfecha,
							p_empresa,          v_estado,         v_opernacional,
							v_ccmayor,          v_ccsub,          v_ccsubsub,
							v_ccssubsub,        v_ccsssubsub,     v_sector,
							v_moneda,           v_nivelobtencion, v_fecha_hab,
							v_unicatotal,       v_fechasaldo)
		INTO v_saldocontable;
					
				
		INSERT INTO sp_generaconsol_log (clavereporte,parametros) 
		VALUES ('SPSP_OBTENSDOCONT', v_naturaleza || ' ' || v_fecha || ' ' || v_mesantfecha || ' ' ||
									v_claveperiodicida || ' ' || v_aniocontable|| ' ' || v_mescontable || ' ' ||
									v_anioreporte || ' ' || v_mesreporte || ' ' || v_auxiliar || ' ' ||
									v_clavetiporep || ' ' || v_tiposaldo || ' ' || v_proyecfecha || ' ' ||
									p_empresa || ' ' || v_estado || ' ' || v_opernacional || ' ' ||
									v_ccmayor || ' ' || v_ccsub || ' ' || v_ccsubsub || ' ' ||
									v_ccssubsub || ' ' || v_ccsssubsub || ' ' || v_sector || ' ' ||
									v_moneda || ' ' || v_nivelobtencion || ' ' || v_fecha_hab || ' ' ||
									v_unicatotal || ' ' || v_fechasaldo || "saldo =" || v_saldocontable);
		
		IF v_saldocontable IS NULL THEN
			LET v_saldocontable = 0;
		END IF;
	
		--Calcula El porcentaje de Riesgo
		LET v_saldocontable = v_saldocontable * (v_porcenriesgo / 100);
	
		--Si la Division de las Cifras es cero corrige
		IF v_divisioncifra = 0 THEN
			LET v_divisioncifra = 1;
		END IF;
	
		--Tipos de Cambio
		LET v_precio_contable = NULL;
		LET v_precio_dolar = NULL;
	
		--Moneda Origen
	
		SELECT preciocontable
		INTO   v_precio_contable
		FROM   bdirepaut:sp_preciocontable
		WHERE  moneda = v_moneda
		AND    fecha  = v_fecha;
	
		--Moneda DLLS
		
		SELECT preciocontable
		INTO   v_precio_dolar
		FROM   bdirepaut:sp_preciocontable
		WHERE  moneda = v_moneda_dll
		AND    fecha  = v_fecha;
	
		--Si Son Nulos, Avisa solo para dolares
		IF v_precio_contable IS NULL THEN
			LET v_precio_contable = 0;
		END IF;
		IF v_precio_dolar IS NULL THEN
			LET r_codret = '001';
			LET r_mensaje = 'NO EXISTE TIPO DE CAMBIO DE DOLARES ' ||
							'PARA ESTA FECHA, VERIFIQUE!';
			RETURN r_codret, r_mensaje;
		END IF;
	
		--Calcula El Saldo Nacional
		IF v_saldocontable != 0 THEN
			IF v_moneda != v_moneda_mn THEN
				LET v_saldonacional = v_saldocontable * v_precio_contable;
				IF v_moneda != v_moneda_dll AND v_moneda != v_moneda_udi THEN
				LET v_saldonacional = v_saldonacional * v_precio_dolar;
				END IF;
			ELSE
				LET v_saldonacional = v_saldocontable;
			END IF;
		ELSE
			LET v_saldonacional = 0;
		END IF;
		{--Si Valoriza y Coloca Cifras
		IF v_valoriza = 1 THEN
			IF v_valorizacionmone != v_moneda_mn THEN
				LET v_precio_contable = NULL;
				SELECT precio_compra
				INTO   v_precio_contable
				FROM   bdinteg:si_histdiv
				WHERE  divisa = v_valorizacionmone
				AND    fecha_tc = v_fecha;
				SELECT preciocontable
				INTO   v_precio_contable
				FROM   bdirepaut:sp_preciocontable
				WHERE  moneda = v_valorizacionmone
				AND    fecha  = v_fecha;
				IF v_precio_contable IS NULL THEN
				LET v_precio_contable = 0;
				END IF;
				IF v_precio_contable > 0 THEN
				IF v_claveredondeo = 'R' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = round(((v_saldonacional/v_precio_contable)
												/v_divisioncifra), 0);
					ELSE
						LET v_saldocifra = round((
									(v_saldonacional/v_precio_dolar/v_precio_contable)
												/v_divisioncifra), 0);
					END IF;
				END IF;
				IF v_claveredondeo = 'T' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = trunc(((v_saldonacional/v_precio_contable)
												/v_divisioncifra), 0);
					ELSE
						LET v_saldocifra = trunc((
									(v_saldonacional/v_precio_dolar/v_precio_contable)
												/v_divisioncifra), 0);
					END IF;
				END IF;
				IF v_claveredondeo = 'N' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = ((v_saldonacional/v_precio_contable)
											/v_divisioncifra);
					ELSE
						LET v_saldocifra = (
									(v_saldonacional/v_precio_dolar/v_precio_contable)
											/v_divisioncifra);
					END IF;
				END IF;
				ELSE
				LET v_saldocifra = 0;
				END IF;
			ELSE
				IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = round((v_saldonacional/v_divisioncifra), 0);
				END IF;
				IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = trunc((v_saldonacional/v_divisioncifra), 0);
				END IF;
				IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = (v_saldonacional/v_divisioncifra);
				END IF;
			END IF;
		ELSE
			IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = round((v_saldocontable/v_divisioncifra), 0);
			END IF;
			IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = trunc((v_saldocontable/v_divisioncifra), 0);
			END IF;
			IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = (v_saldocontable/v_divisioncifra);
			END IF;
		END IF;}
	
		--Si Valoriza y Coloca Cifras
		IF v_valoriza = 1 THEN
			IF v_valorizacionmone != v_moneda_mn THEN
				LET v_precio_contable = NULL;
	
				SELECT preciocontable
				INTO   v_precio_contable
				FROM   bdirepaut:sp_preciocontable
				WHERE  moneda = v_valorizacionmone
				AND    fecha  = v_fecha;
				IF v_precio_contable IS NULL THEN
				LET v_precio_contable = 0;
				END IF;
				IF v_precio_contable > 0 THEN
				IF v_claveredondeo = 'R' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = v_saldonacional;
					ELSE
						LET v_saldocifra = v_saldonacional;
					END IF;
				END IF;
				IF v_claveredondeo = 'T' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = v_saldonacional;
					ELSE
						LET v_saldocifra = v_saldonacional;
					END IF;
				END IF;
				IF v_claveredondeo = 'N' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = v_saldonacional;
					ELSE
						LET v_saldocifra = v_saldonacional;
					END IF;
				END IF;
				ELSE
				LET v_saldocifra = 0;
				END IF;
			ELSE
				IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = v_saldonacional;
				END IF;
				IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = v_saldonacional;
				END IF;
				IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = v_saldonacional;
				END IF;
			END IF;
		ELSE
			IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = v_saldocontable;
			END IF;
			IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = v_saldocontable;
			END IF;
			IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = v_saldocontable;
			END IF;
		END IF;
	
	    --Si la Naturaleza es 1 la verifica
		IF v_naturalezacuenta = 1 THEN
			LET v_naturaleza_cta = NULL;
			SELECT naturaleza_cta
			INTO   v_naturaleza_cta
			FROM   bdinteg:si_catalog
			WHERE  ccmayor    = v_ccmayor
			AND    ccsub      = v_ccsub
			AND    ccsubsub   = v_ccsubsub
			AND    ccssubsub  = v_ccssubsub
			AND    ccsssubsub = v_ccsssubsub
			AND    naturaleza_cta = 'A'
			AND    empresa        = p_empresa
			GROUP  BY naturaleza_cta;
			IF v_naturaleza_cta = 'A' THEN
				LET v_saldocifra = v_saldocifra * -1;
			END IF;
		END IF;
	
		IF v_valoriza = 1 THEN
			IF v_valorizacionmone != v_moneda_mn THEN
				LET v_precio_contable = NULL;
	
				SELECT preciocontable
				INTO   v_precio_contable
				FROM   bdirepaut:sp_preciocontable
				WHERE  moneda = v_valorizacionmone
				AND    fecha  = v_fecha;
				IF v_precio_contable IS NULL THEN
				LET v_precio_contable = 0;
				END IF;
				IF v_precio_contable > 0 THEN
				IF v_claveredondeo = 'R' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = round(((v_saldocifra/v_precio_contable)
												/v_divisioncifra), 0);
					ELSE
						LET v_saldocifra = round((
									(v_saldocifra/v_precio_dolar/v_precio_contable)
												/v_divisioncifra), 0);
					END IF;
				END IF;
				IF v_claveredondeo = 'T' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = trunc(((v_saldocifra/v_precio_contable)
												/v_divisioncifra), 0);
					ELSE
						LET v_saldocifra = trunc((
									(v_saldocifra/v_precio_dolar/v_precio_contable)
												/v_divisioncifra), 0);
					END IF;
				END IF;
				IF v_claveredondeo = 'N' THEN
					IF v_valorizacionmone = v_moneda_dll OR
						v_valorizacionmone = v_moneda_udi THEN
						LET v_saldocifra = ((v_saldocifra/v_precio_contable)
											/v_divisioncifra);
					ELSE
						LET v_saldocifra = (
									(v_saldocifra/v_precio_dolar/v_precio_contable)
											/v_divisioncifra);
					END IF;
				END IF;
				ELSE
				LET v_saldocifra = 0;
				END IF;
			ELSE
				IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = round((v_saldocifra/v_divisioncifra), 0);
				END IF;
				IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = trunc((v_saldocifra/v_divisioncifra), 0);
				END IF;
				IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = (v_saldocifra/v_divisioncifra);
				END IF;
			END IF;
		ELSE
			IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = round((v_saldocifra/v_divisioncifra), 0);
			END IF;
			IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = trunc((v_saldocifra/v_divisioncifra), 0);
			END IF;
			IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = (v_saldocifra/v_divisioncifra);
			END IF;
		END IF;
	
		LET v_saldocontable = v_saldocontable;
		LET v_saldonacional = v_saldonacional;
		LET v_saldocifra    = v_saldocifra;
		LET p_identautoridad = p_identautoridad;
		LET p_empresa        = p_empresa;
		LET p_clavereporte   = p_clavereporte;
		LET v_ccmayor        = v_ccmayor;
		LET v_ccsub          = v_ccsub;
		LET v_ccsubsub       = v_ccsubsub;
		LET v_ccssubsub      = v_ccssubsub;
		LET v_ccsssubsub     = v_ccsssubsub;
		LET v_sector         = v_sector;
		LET v_numerorenglon  = v_numerorenglon;
		LET v_numerocolumna  = v_numerocolumna;
		LET v_moneda         = v_moneda;
		LET v_opernacional   = v_opernacional;
		LET v_naturaleza     = v_naturaleza;
		LET v_tiposaldo      = v_tiposaldo;
		
		IF EXISTS (SELECT fecha FROM bdirepaut:sp_filtroreporte_anexo 
					WHERE identautoridad  = p_identautoridad 
					AND    empresa        = p_empresa 
					AND    clavereporte   = p_clavereporte
					AND    ccmayor        = v_ccmayor		AND    ccsub          = v_ccsub	
					AND    ccsubsub       = v_ccsubsub 		AND    ccssubsub      = v_ccssubsub
					AND    ccsssubsub     = v_ccsssubsub 	AND    sector         = v_sector 
					AND    numerorenglon  = v_numerorenglon AND    numerocolumna  = v_numerocolumna 
					AND    moneda         = v_moneda     	AND    opernacional   = v_opernacional 
					AND    naturaleza     = v_naturaleza 	AND    tiposaldo      = v_tiposaldo 
					AND    fecha          = v_fecha_hab) THEN
	
	
				UPDATE bdirepaut:sp_filtroreporte_anexo
				SET    saldocontable  =  v_saldocontable,
						saldonacional  = v_saldonacional,
						saldocifra     = v_saldocifra
				WHERE  identautoridad = p_identautoridad
				AND    empresa        = p_empresa
				AND    clavereporte   = p_clavereporte
				AND    ccmayor        = v_ccmayor
				AND    ccsub          = v_ccsub
				AND    ccsubsub       = v_ccsubsub
				AND    ccssubsub      = v_ccssubsub
				AND    ccsssubsub     = v_ccsssubsub
				AND    sector         = v_sector
				AND    numerorenglon  = v_numerorenglon
				AND    numerocolumna  = v_numerocolumna
				AND    moneda         = v_moneda
				AND    opernacional   = v_opernacional
				AND    naturaleza     = v_naturaleza
				AND    tiposaldo      = v_tiposaldo
				AND    fecha		  = v_fecha_hab;	  
	   ELSE 
					
				INSERT INTO bdirepaut:sp_filtroreporte_anexo(identautoridad, empresa, clavereporte, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, numerorenglon, numerocolumna, moneda, opernacional, naturaleza, tiposaldo, fechasaldo, codigoporcentaje, nivelobtencion, signo, unicatotal, saldocontable, saldonacional, saldocifra,fecha)
				--VALUES(            'CNBV',    '001',  'ANEX43PREV',   '2101',   '01',      '00',       '00',        '00',    '00',             30,              3,    '09',           'A',         'I',      'PDM',           1,                 9,               2,'+',         'S',           0.0000,          0.0000,       0.0000,     FECHA);
				VALUES(    p_identautoridad,p_empresa,p_clavereporte,v_ccmayor,v_ccsub,v_ccsubsub,v_ccssubsub,v_ccsssubsub,v_sector,v_numerorenglon,v_numerocolumna,v_moneda,v_opernacional,v_naturaleza,v_tiposaldo,v_fechasaldo,v_codigoporcentaje,v_nivelobtencion,v_signo,v_unicatotal,  v_saldocontable, v_saldonacional, v_saldocifra,v_fecha_hab);
				
			
	   END IF;
			
		IF NOT EXISTS (SELECT numerocolumna FROM bdirepaut:sp_filtroreporte_anexo WHERE identautoridad   = p_identautoridad
						  AND empresa  = p_empresa AND clavereporte = p_clavereporte AND numerocolumna = v_numerocolumna
						  AND ccmayor IN ('','0000') AND fecha = v_fecha_hab) THEN
			INSERT INTO bdirepaut:sp_filtroreporte_anexo
			SELECT p_identautoridad,p_empresa,p_clavereporte,ccmayor  ,ccsub  ,ccsubsub  ,ccssubsub  ,ccsssubsub  ,sector,
				   numerorenglon   ,numerocolumna  ,moneda  ,opernacional  ,naturaleza  ,tiposaldo  ,fechasaldo  ,codigoporcentaje,
				   nivelobtencion  ,signo,unicatotal,0.0,0.0, 0.0,v_fecha_hab
			  FROM bdirepaut:sp_filtroreporte
			  WHERE identautoridad   = p_identautoridad
				AND empresa          = p_empresa
				AND clavereporte     = p_clavereporte
				AND numerocolumna = v_numerocolumna
				--AND unicatotal      NOT  IN ("E", "G", "S")
				AND ccmayor IN ('','0000') ;	
		END IF;
	  END FOREACH;		
	
	ELSE 
			EXECUTE PROCEDURE SPSP_OBTENSDOCONT(
                        v_naturaleza,       v_fecha,          v_mesantfecha,
                        v_claveperiodicida, v_aniocontable,   v_mescontable,
                        v_anioreporte,      v_mesreporte,     v_auxiliar,
                        v_clavetiporep,     v_tiposaldo,      v_proyecfecha,
                        p_empresa,          v_estado,         v_opernacional,
                        v_ccmayor,          v_ccsub,          v_ccsubsub,
                        v_ccssubsub,        v_ccsssubsub,     v_sector,
                        v_moneda,           v_nivelobtencion, v_fecinicial,
                        v_unicatotal,       v_fechasaldo
                                         )
              INTO v_saldocontable;
                 
			 
			INSERT INTO sp_generaconsol_log (clavereporte,parametros) 
			VALUES ('SPSP_OBTENSDOCONT', v_naturaleza || ' ' || v_fecha || ' ' || v_mesantfecha || ' ' ||
										v_claveperiodicida || ' ' || v_aniocontable|| ' ' || v_mescontable || ' ' ||
										v_anioreporte || ' ' || v_mesreporte || ' ' || v_auxiliar || ' ' ||
										v_clavetiporep || ' ' || v_tiposaldo || ' ' || v_proyecfecha || ' ' ||
										p_empresa || ' ' || v_estado || ' ' || v_opernacional || ' ' ||
										v_ccmayor || ' ' || v_ccsub || ' ' || v_ccsubsub || ' ' ||
										v_ccssubsub || ' ' || v_ccsssubsub || ' ' || v_sector || ' ' ||
										v_moneda || ' ' || v_nivelobtencion || ' ' || v_fecinicial || ' ' ||
										v_unicatotal || ' ' || v_fechasaldo || "saldo =" || v_saldocontable);
			
			IF v_saldocontable IS NULL THEN
				LET v_saldocontable = 0;
			END IF;
	
			--Calcula El porcentaje de Riesgo
			LET v_saldocontable = v_saldocontable * (v_porcenriesgo / 100);
	
			--Si la Division de las Cifras es cero corrige
			IF v_divisioncifra = 0 THEN
				LET v_divisioncifra = 1;
			END IF;
	
			--Tipos de Cambio
			LET v_precio_contable = NULL;
			LET v_precio_dolar = NULL;
	
			--Moneda Origen
		
			SELECT preciocontable
			INTO   v_precio_contable
			FROM   bdirepaut:sp_preciocontable
			WHERE  moneda = v_moneda
			AND    fecha  = v_fecha;
		
			--Moneda DLLS
			
			SELECT preciocontable
			INTO   v_precio_dolar
			FROM   bdirepaut:sp_preciocontable
			WHERE  moneda = v_moneda_dll
			AND    fecha  = v_fecha;
		
			--Si Son Nulos, Avisa solo para dolares
			IF v_precio_contable IS NULL THEN
				LET v_precio_contable = 0;
			END IF;
			IF v_precio_dolar IS NULL THEN
				LET r_codret = '001';
				LET r_mensaje = 'NO EXISTE TIPO DE CAMBIO DE DOLARES ' ||
								'PARA ESTA FECHA, VERIFIQUE!';
				RETURN r_codret, r_mensaje;
			END IF;
		
			--Calcula El Saldo Nacional
			IF v_saldocontable != 0 THEN
				IF v_moneda != v_moneda_mn THEN
					LET v_saldonacional = v_saldocontable * v_precio_contable;
					IF v_moneda != v_moneda_dll AND v_moneda != v_moneda_udi THEN
					LET v_saldonacional = v_saldonacional * v_precio_dolar;
					END IF;
				ELSE
					LET v_saldonacional = v_saldocontable;
				END IF;
			ELSE
				LET v_saldonacional = 0;
			END IF;
		{--Si Valoriza y Coloca Cifras
		IF v_valoriza = 1 THEN
         IF v_valorizacionmone != v_moneda_mn THEN
            LET v_precio_contable = NULL;
            SELECT precio_compra
            INTO   v_precio_contable
            FROM   bdinteg:si_histdiv
            WHERE  divisa = v_valorizacionmone
            AND    fecha_tc = v_fecha;
            SELECT preciocontable
            INTO   v_precio_contable
            FROM   bdirepaut:sp_preciocontable
            WHERE  moneda = v_valorizacionmone
            AND    fecha  = v_fecha;
            IF v_precio_contable IS NULL THEN
               LET v_precio_contable = 0;
          END IF;
          IF v_precio_contable > 0 THEN
               IF v_claveredondeo = 'R' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = round(((v_saldonacional/v_precio_contable)
                                               /v_divisioncifra), 0);
                  ELSE
                     LET v_saldocifra = round((
                                (v_saldonacional/v_precio_dolar/v_precio_contable)
                                               /v_divisioncifra), 0);
                  END IF;
               END IF;
               IF v_claveredondeo = 'T' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = trunc(((v_saldonacional/v_precio_contable)
                                               /v_divisioncifra), 0);
                  ELSE
                     LET v_saldocifra = trunc((
                                (v_saldonacional/v_precio_dolar/v_precio_contable)
                                               /v_divisioncifra), 0);
                  END IF;
               END IF;
               IF v_claveredondeo = 'N' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = ((v_saldonacional/v_precio_contable)
                                         /v_divisioncifra);
                  ELSE
                     LET v_saldocifra = (
                                (v_saldonacional/v_precio_dolar/v_precio_contable)
                                         /v_divisioncifra);
                  END IF;
               END IF;
            ELSE
               LET v_saldocifra = 0;
            END IF;
         ELSE
            IF v_claveredondeo = 'R' THEN
               LET v_saldocifra = round((v_saldonacional/v_divisioncifra), 0);
            END IF;
            IF v_claveredondeo = 'T' THEN
               LET v_saldocifra = trunc((v_saldonacional/v_divisioncifra), 0);
            END IF;
            IF v_claveredondeo = 'N' THEN
               LET v_saldocifra = (v_saldonacional/v_divisioncifra);
            END IF;
         END IF;
		ELSE
         IF v_claveredondeo = 'R' THEN
            LET v_saldocifra = round((v_saldocontable/v_divisioncifra), 0);
         END IF;
         IF v_claveredondeo = 'T' THEN
            LET v_saldocifra = trunc((v_saldocontable/v_divisioncifra), 0);
         END IF;
         IF v_claveredondeo = 'N' THEN
            LET v_saldocifra = (v_saldocontable/v_divisioncifra);
         END IF;
		END IF;}

      --Si Valoriza y Coloca Cifras
      IF v_valoriza = 1 THEN
         IF v_valorizacionmone != v_moneda_mn THEN
            LET v_precio_contable = NULL;

            SELECT preciocontable
            INTO   v_precio_contable
            FROM   bdirepaut:sp_preciocontable
            WHERE  moneda = v_valorizacionmone
            AND    fecha  = v_fecha;
            IF v_precio_contable IS NULL THEN
               LET v_precio_contable = 0;
            END IF;
            IF v_precio_contable > 0 THEN
               IF v_claveredondeo = 'R' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = v_saldonacional;
                  ELSE
                     LET v_saldocifra = v_saldonacional;
                  END IF;
               END IF;
               IF v_claveredondeo = 'T' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = v_saldonacional;
                  ELSE
                     LET v_saldocifra = v_saldonacional;
                  END IF;
               END IF;
               IF v_claveredondeo = 'N' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = v_saldonacional;
                  ELSE
                     LET v_saldocifra = v_saldonacional;
                  END IF;
               END IF;
            ELSE
               LET v_saldocifra = 0;
            END IF;
         ELSE
            IF v_claveredondeo = 'R' THEN
               LET v_saldocifra = v_saldonacional;
            END IF;
            IF v_claveredondeo = 'T' THEN
               LET v_saldocifra = v_saldonacional;
            END IF;
            IF v_claveredondeo = 'N' THEN
               LET v_saldocifra = v_saldonacional;
            END IF;
         END IF;
		ELSE
			IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = v_saldocontable;
			END IF;
			IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = v_saldocontable;
			END IF;
			IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = v_saldocontable;
			END IF;
		END IF;

      --Si la Naturaleza es 1 la verifica
      IF v_naturalezacuenta = 1 THEN
         LET v_naturaleza_cta = NULL;
         SELECT naturaleza_cta
         INTO   v_naturaleza_cta
         FROM   bdinteg:si_catalog
         WHERE  ccmayor    = v_ccmayor
         AND    ccsub      = v_ccsub
         AND    ccsubsub   = v_ccsubsub
         AND    ccssubsub  = v_ccssubsub
         AND    ccsssubsub = v_ccsssubsub
         AND    naturaleza_cta = 'A'
         AND    empresa        = p_empresa
         GROUP  BY naturaleza_cta;
         IF v_naturaleza_cta = 'A' THEN
            LET v_saldocifra = v_saldocifra * -1;
         END IF;
      END IF;

      IF v_valoriza = 1 THEN
         IF v_valorizacionmone != v_moneda_mn THEN
            LET v_precio_contable = NULL;

            SELECT preciocontable
            INTO   v_precio_contable
            FROM   bdirepaut:sp_preciocontable
            WHERE  moneda = v_valorizacionmone
            AND    fecha  = v_fecha;
            IF v_precio_contable IS NULL THEN
               LET v_precio_contable = 0;
            END IF;
            IF v_precio_contable > 0 THEN
               IF v_claveredondeo = 'R' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = round(((v_saldocifra/v_precio_contable)
                                               /v_divisioncifra), 0);
                  ELSE
                     LET v_saldocifra = round((
                                (v_saldocifra/v_precio_dolar/v_precio_contable)
                                               /v_divisioncifra), 0);
                  END IF;
               END IF;
               IF v_claveredondeo = 'T' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = trunc(((v_saldocifra/v_precio_contable)
                                               /v_divisioncifra), 0);
                  ELSE
                     LET v_saldocifra = trunc((
                                (v_saldocifra/v_precio_dolar/v_precio_contable)
                                               /v_divisioncifra), 0);
                  END IF;
               END IF;
               IF v_claveredondeo = 'N' THEN
                  IF v_valorizacionmone = v_moneda_dll OR
                     v_valorizacionmone = v_moneda_udi THEN
                     LET v_saldocifra = ((v_saldocifra/v_precio_contable)
                                         /v_divisioncifra);
                  ELSE
                     LET v_saldocifra = (
                                (v_saldocifra/v_precio_dolar/v_precio_contable)
                                         /v_divisioncifra);
                  END IF;
               END IF;
            ELSE
               LET v_saldocifra = 0;
            END IF;
          ELSE
            IF v_claveredondeo = 'R' THEN
               LET v_saldocifra = round((v_saldocifra/v_divisioncifra), 0);
            END IF;
            IF v_claveredondeo = 'T' THEN
               LET v_saldocifra = trunc((v_saldocifra/v_divisioncifra), 0);
            END IF;
            IF v_claveredondeo = 'N' THEN
               LET v_saldocifra = (v_saldocifra/v_divisioncifra);
            END IF;
          END IF;
		ELSE
			IF v_claveredondeo = 'R' THEN
				LET v_saldocifra = round((v_saldocifra/v_divisioncifra), 0);
			END IF;
			IF v_claveredondeo = 'T' THEN
				LET v_saldocifra = trunc((v_saldocifra/v_divisioncifra), 0);
			END IF;
			IF v_claveredondeo = 'N' THEN
				LET v_saldocifra = (v_saldocifra/v_divisioncifra);
			END IF;
		END IF;

      LET v_saldocontable = v_saldocontable;
      LET v_saldonacional = v_saldonacional;
      LET v_saldocifra    = v_saldocifra;
      LET p_identautoridad = p_identautoridad;
      LET p_empresa        = p_empresa;
      LET p_clavereporte   = p_clavereporte;
      LET v_ccmayor        = v_ccmayor;
      LET v_ccsub          = v_ccsub;
      LET v_ccsubsub       = v_ccsubsub;
      LET v_ccssubsub      = v_ccssubsub;
      LET v_ccsssubsub     = v_ccsssubsub;
      LET v_sector         = v_sector;
      LET v_numerorenglon  = v_numerorenglon;
      LET v_numerocolumna  = v_numerocolumna;
      LET v_moneda         = v_moneda;
      LET v_opernacional   = v_opernacional;
      LET v_naturaleza     = v_naturaleza;
      LET v_tiposaldo      = v_tiposaldo;

      --Actualiza Filtros
      UPDATE bdirepaut:sp_filtroreporte
      SET    saldocontable  = v_saldocontable,
             saldonacional  = v_saldonacional,
             saldocifra     = v_saldocifra
      WHERE  identautoridad = p_identautoridad
      AND    empresa        = p_empresa
      AND    clavereporte   = p_clavereporte
      AND    ccmayor        = v_ccmayor
      AND    ccsub          = v_ccsub
      AND    ccsubsub       = v_ccsubsub
      AND    ccssubsub      = v_ccssubsub
      AND    ccsssubsub     = v_ccsssubsub
      AND    sector         = v_sector
      AND    numerorenglon  = v_numerorenglon
      AND    numerocolumna  = v_numerocolumna
      AND    moneda         = v_moneda
      AND    opernacional   = v_opernacional
      AND    naturaleza     = v_naturaleza
      AND    tiposaldo      = v_tiposaldo;

     END IF;      
   	 CONTINUE FOREACH;
	END FOREACH;	
   --Fin del Proceso                                                                                                                                                                                                                                              
   LET r_codret = '000';
   LET r_mensaje = 'PROCESO SATISFACTORIO';
   RETURN r_codret, r_mensaje;
END PROCEDURE;