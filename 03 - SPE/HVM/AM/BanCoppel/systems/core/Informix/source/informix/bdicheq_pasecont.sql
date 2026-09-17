CREATE PROCEDURE "informix".pasecont(pempresa      CHAR(3),
                                     pfecha_hoy    DATE,
									 pfecha_valida DATE,
									 pusuario      CHAR(8))
returning char(5);

DEFINE cod_ret 		 VARCHAR(5);
DEFINE vmca_aplic 	 CHAR(1);
DEFINE vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector VARCHAR(10);
DEFINE vmoneda,moneda_ant CHAR(2);
DEFINE vsucursal,vsuccta,vsuc_usuario VARCHAR(4);
DEFINE vciudad,vempresa CHAR(3);
DEFINE vccmayor      VARCHAR(4);
DEFINE vusuario      VARCHAR(8);
DEFINE vusuar        VARCHAR(8);
DEFINE vauxiliar     VARCHAR(9);
DEFINE vdescripcion  VARCHAR(50);
DEFINE vtotcar,vtotabo,vvalor_cambio,vvalor_div,
       vcapt_cargo,vcapt_abono,
       vcifra_control MONEY(14,2);
DEFINE vvalor        MONEY(14,7);
DEFINE vcontrol_poliza,vsecuencia INTEGER;
DEFINE vfecha_hoy    DATE;
DEFINE vfecha_valida DATE;
DEFINE sql_err       INTEGER;
DEFINE vmensaje      VARCHAR(80);
DEFINE vUser 	     VARCHAR(9);
DEFINE vcomienza1    SMALLINT;
DEFINE ven_transacc1 SMALLINT;
DEFINE vconta        INTEGER;


-- Inicializa variables
LET cod_ret       = "000";
LET vsecuencia    = 0;
LET vdescripcion  = "Movimientos de Cheques";
LET vvalor_cambio = 0;
LET vvalor_div    = 0;
LET vmca_aplic    = "0";
LET moneda_ant    = "  ";
LET vUser         ='informix';
LET vcomienza1 	  = -1;
LET ven_transacc1  = 0;
LET vconta         = 0;

BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
			  LET cod_ret = sql_err;
			  RETURN cod_ret;
			END IF;
		end exception;

	IF pusuario = '' THEN
		--Extrae el usuario a asignar en el Pase Contable
		--Se quita Directiva, no es necesaria.
		--select {+INDEX(bdinteg:si_ejecut idx_si_ejecut)} 
		SELECT ejecutivo,sucursal 
		INTO vusuario,vsuc_usuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = user
		--WHERE ejecutivo = vUser --para pruebas de ejecuciÃ³n
		AND empresa = pempresa;

		IF vusuario IS NULL OR vsuc_usuario IS NULL THEN
			LET cod_ret = "158";
			RETURN cod_ret;
		END IF

		LET vusuario = "chq"||vusuario[1,5];
	ELSE
		LET vusuario = pusuario ;
	END IF

	-- Asigna la fecha de hoy dada como parametro
	LET vfecha_hoy = pfecha_hoy;
	LET vfecha_valida = pfecha_valida;


		-- Cada registro de la Tabla Contable de Cheques lo graba en Detalle de Poliza
		--delete {+INDEX(bdicont:co_poldet ix_copoldet2new)} 
		DELETE 
		FROM bdicont:co_poldet
		WHERE empresa = pempresa AND usuario = vusuario AND
		fecha_captura = vfecha_hoy;

		FOREACH cursor_pasecont WITH HOLD FOR
		---select {+INDEX(sc_contab idx_sc_contab) +INDEX(sc_contab idx_sc_contab2)} sucursal,succta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
		----select {+INDEX(sc_contab idx_sc_contab)} sucursal,succta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
		--Se elimina el Where con el campo empresa
		SELECT {+INDEX(sc_contab idx_sc_contab2)} 
		sucursal,succta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
		SUM(tot_cargo),SUM(tot_abono),moneda,empresa,auxiliar,descripcion
		INTO vsucursal,vsuccta,vccmayor,vccsub,vccsubsub,vccssubsub,
			   vccsssubsub,vsector,vtotcar,vtotabo,vmoneda,
			   vempresa,vauxiliar,vdescripcion
		FROM bdicheq:sc_contab
		--where empresa = pempresa and sucursal <> "TOT"
		WHERE sucursal <> "TOT"
		GROUP BY 1,2,3,4,5,6,7,8,11,12,13,14
		ORDER BY moneda,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector

		SELECT regional INTO vciudad
		FROM bdinteg:si_sucursales su,bdinteg:si_plazas pl
		WHERE su.empresa = pempresa AND sucursal = vsucursal AND
			 pl.empresa = su.empresa AND pl.plaza = su.plaza;
	
		-- Abre la transaccion
		   IF (vcomienza1 = -1) THEN
			  LET vcomienza1 = 0;
			  LET ven_transacc1 = 1;
			  BEGIN WORK;
		   END IF;

		IF vtotcar > 0 THEN
		  let vsecuencia = vsecuencia + 1;
		  INSERT INTO bdicont:co_poldet
			 VALUES(vusuario,vfecha_hoy,vsecuencia,
				vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,
				vccsssubsub,vsector,vciudad,vsuccta,vauxiliar,
				"D",vtotcar,vdescripcion,vfecha_valida,vmoneda,vsucursal);
		END IF
		
		IF vtotabo > 0 THEN
		  let vsecuencia = vsecuencia + 1;
		  INSERT INTO bdicont:co_poldet
			 VALUES(vusuario,vfecha_hoy,vsecuencia,
				vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,
				vccsssubsub,vsector,vciudad,vsuccta,vauxiliar,
				"C",vtotabo,vdescripcion,vfecha_valida,vmoneda,vsucursal);
		END IF
		
		LET vmca_aplic = "1";
		
		LET vconta = vconta + 1;
		--Commit cada 10000 registros
		   IF (vconta >= 10000) THEN
			  LET vconta = 0;
			  COMMIT WORK;
			  BEGIN WORK;
		   END IF;
		
		END FOREACH;

		IF (ven_transacc1 = 1) THEN
		  LET ven_transacc1 = 0;
		  COMMIT WORK;
	    END IF;

		IF vmca_aplic = "1" THEN
			EXECUTE PROCEDURE bdicont:auditapase(vfecha_hoy,vempresa,vusuario)
			INTO cod_ret;
		END IF

RETURN cod_ret;
END
END PROCEDURE;