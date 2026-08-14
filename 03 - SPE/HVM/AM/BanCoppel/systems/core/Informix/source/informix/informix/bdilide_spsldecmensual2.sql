CREATE PROCEDURE "informix".spsldecmensual2(p_dfechaproceso DATE,
								p_susuario CHAR(8),
								pTipoDecl CHAR(1),
								pFechaPresentacion DATE,
								pNumFolio CHAR(16))
	RETURNING CHAR(6), CHAR(80);

	DEFINE v_scodret 			  	VARCHAR(5);
	DEFINE v_smensaje 			  	VARCHAR(80);

	DEFINE sql_err                	INTEGER;
    DEFINE isam_err               	INTEGER;
    DEFINE error_info             	VARCHAR(40);

	DEFINE v_icount					INTEGER;
	DEFINE v_sstatus                VARCHAR(1);
	DEFINE v_dfech_proceso			DATE;
	DEFINE v_snum_operacion         VARCHAR(20);
	DEFINE v_dfech_operacion        DATE;

	DEFINE v_snum_cte				VARCHAR(20);
	DEFINE v_dfecha_ret				DATE;
	DEFINE v_dfecha_ret_pas			DATE; --dsb -15/05/2013
	DEFINE v_mimp_gravado 			MONEY(16,2);
	DEFINE v_mimp_arecaudar         MONEY(16,2);
	DEFINE v_mimp_recaudado         MONEY(16,2);
	DEFINE v_mimp_remanente			MONEY(16,2);

	DEFINE v_stpo_persona 			VARCHAR(2);
	DEFINE v_sapell_paterno         VARCHAR(26);
	DEFINE v_sapell_materno         VARCHAR(26);
	DEFINE v_snombre1               VARCHAR(26);
	DEFINE v_snombre2               VARCHAR(26);
	DEFINE v_srazon_social          VARCHAR(60);
	DEFINE v_srfc					VARCHAR(13);
	DEFINE v_scurp					VARCHAR(20);
	--DEFINE v_isecuencia 			INTEGER;
	DEFINE v_snombrecalle           VARCHAR(30);
	DEFINE v_snumeroextcalle        VARCHAR(10);
	DEFINE v_snumerointcalle        VARCHAR(10);
	DEFINE v_snombrezona            VARCHAR(30);
	DEFINE v_scod_postal            VARCHAR(5);

	DEFINE mRecPendiente		    MONEY(16,2);

	--DEFINE v_snum_ctedep			CHAR(20);
	DEFINE v_itotoperaciones		INTEGER;
	DEFINE v_montoentero			MONEY(16,2);
	DEFINE v_mtotexcedente          MONEY(16,2);
	DEFINE v_mtotdeterminado        MONEY(16,2);
	DEFINE v_mtotrecaudado          MONEY(16,2);
	DEFINE v_mtotpendiente          MONEY(16,2);
	DEFINE v_mtotremanente          MONEY(16,2);
	DEFINE v_sfecha_char            VARCHAR(10);
	DEFINE v_dfecha_hoy				DATE;
	DEFINE v_imes					INTEGER;
	DEFINE v_ianio					INTEGER;
	DEFINE v_saniomes				VARCHAR(6);
	DEFINE v_smesenero				VARCHAR(6);
	DEFINE v_sretorno 				VARCHAR(6);
	DEFINE v_sleyenda               VARCHAR(30);
	--DEFINE v_numero 				INTEGER;
    DEFINE viNumComple              int;
	DEFINE nCont					INT8;

	--DSB 25/03/2013
	DEFINE v_msaldopenrec			MONEY(16,2);
	DEFINE v_msdopenrecrest			MONEY(16,2);
	DEFINE v_saniomesant			VARCHAR(6);
	DEFINE v_mtotsaldopenrec        MONEY(16,2);
	--DSB-05/07/2013
	DEFINE sNumCteTemp				VARCHAR(20);
	
	--VARIABLES TABLAS FISICAS TEMPORALES
	DEFINE v_tpo_persona VARCHAR(2);
	DEFINE v_apell_paterno VARCHAR(26);
	DEFINE v_apell_materno VARCHAR(26);
	DEFINE v_nombre1 VARCHAR(26); 
	DEFINE v_nombre2 VARCHAR(26);
	DEFINE v_razon_social VARCHAR(60);
	DEFINE v_rfc VARCHAR(13); 
	DEFINE v_curp VARCHAR(20);
	DEFINE v_cliente VARCHAR(20);	
	DEFINE v_ctnum_cte VARCHAR(20);
	DEFINE v_mtimp_gravado MONEY(16,2);
	DEFINE v_mtimp_arecaudar MONEY(16,2); 
	DEFINE v_mtimp_recaudado MONEY(16,2);
	DEFINE v_dtfecha_ret DATE;
	DEFINE v_cnombrecalle VARCHAR(10);
	DEFINE v_cnumeroextcalle VARCHAR(10);
	DEFINE v_cnumerointcalle VARCHAR(5);
	DEFINE v_cnombrezona VARCHAR(30);
	DEFINE v_ccod_postal VARCHAR(32);
	DEFINE vccliente VARCHAR(20);
	DEFINE vValidatmp INTEGER;
	DEFINE fech_ret DATE;
	DEFINE iContBloque INTEGER;
	DEFINE dFormatoFechaPeriodo DATE;
	DEFINE dFecha_primer_dia_anterior DATE;
	DEFINE dFecha_ultimo_dia_anterior DATE;
	DEFINE bTransaccion BOOLEAN;

	LET v_scodret 				= '00001';
	LET v_smensaje 				= 'EL REPORTE SE GENERO CON ERRORES, NO GENERAR XML';
	LET mRecPendiente		 	= 0.00;
	LET v_montoentero 			= 0.00;
	LET v_mtotexcedente   		= 0.00;
	LET v_mtotdeterminado       = 0.00;
	LET v_mtotrecaudado         = 0.00;
	LET v_mtotpendiente        	= 0.00;
	LET v_mtotremanente         = 0.00;
	LET v_sfecha_char 			= DATE(1);
	LET v_dfecha_hoy 			= CURRENT::DATE;
	LET v_sretorno 				= '';
	LET v_sleyenda 				= '';
    LET v_dfech_proceso 		= p_dfechaproceso;
    LET viNumComple 			= 0;
    LET v_icount                = 0;
    LET v_sstatus               = '';
    LET v_snum_cte 				= '';
    LET v_stpo_persona 			= '';
    LET v_dfech_operacion       = '';
    LET v_dfecha_ret 			= '';
	LET v_dfecha_ret_pas		= '';    
	LET v_snum_operacion        = 0.00;
    LET v_mimp_gravado          = 0.00;
    LET v_mimp_arecaudar        = 0.00;
    LET v_mimp_recaudado 		= 0.00;
    LET v_mimp_remanente        = 0.00;
	LET nCont 					= 0;
    LET v_sapell_paterno 	    = '';
    LET v_sapell_materno 	    = '';
    LET v_snombre1 	    	    = '';
    LET v_snombre2 	    	    = '';
    LET v_srazon_social 	    = '';
    LET v_srfc 	    	        = '';
    LET v_scurp 	    	    = '';
    LET v_snombrecalle 	    	= '';
    LET v_snumeroextcalle 	    = 0;
    LET v_snumerointcalle 	    = 0;
    LET v_snombrezona 	    	= '';
    LET v_scod_postal 	    	= 0;

	--DSB 25/03/2013
	LET v_msaldopenrec		= 0.00;
	LET v_msdopenrecrest	= 0.00;
	LET v_mtotsaldopenrec	= 0.00;
	--DSB-05/07/2013
	LET sNumCteTemp			= '';
	--VARIABLES TABLAS FISICAS TEMPORALES
	LET v_tpo_persona = ''; 
	LET v_apell_paterno = '';
	LET v_apell_materno = ''; 
	LET v_nombre1 = ''; 
	LET v_nombre2 = ''; 
	LET v_razon_social = '';
	LET v_rfc = ''; 
	LET v_curp = '';  
	LET v_cliente = ''; 
	LET v_ctnum_cte = '';
	LET v_mtimp_gravado = 0.00;
	LET v_mtimp_arecaudar = 0.00; 
	LET v_mtimp_recaudado = 0.00;
	LET v_dtfecha_ret = '';	
	LET v_cnombrecalle = '';	
	LET v_cnumeroextcalle = '';	
	LET v_cnumerointcalle = '';	
	LET v_cnombrezona = '';	
	LET v_ccod_postal = '';	
	LET vccliente = '';
	LET vValidatmp=0;
	LET fech_ret='';
	LET iContBloque='0';
	LET v_imes=0;
	LET v_ianio=0;
	LET v_saniomes='';
	LET v_smesenero='';
	LET dFormatoFechaPeriodo='';
	LET dFecha_primer_dia_anterior='';
	LET dFecha_ultimo_dia_anterior='';
	LET bTransaccion = 'f';
	


	BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, error_info
			LET v_scodret = sql_err;
			--LET v_smensaje = sql_err||" * "||isam_err|| " * "||error_info;
			LET v_smensaje = v_snum_cte || " * " || v_dfecha_ret || " * " || v_smensaje;
			RETURN v_scodret, v_smensaje;
		END EXCEPTION;
			
		-- TRATAMIETO DE TRANSACCION
		ON EXCEPTION IN (-668,-535, -255,-556,-206)
			LET bTransaccion = 't';
			COMMIT;
			BEGIN;
		END EXCEPTION WITH RESUME;
		-- TRATAMIETO DE TRANSACCION
	
		BEGIN;

		IF bTransaccion = 'f' THEN
			COMMIT;
		END IF;
	
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
		
		--SET DEBUG FILE TO "/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/spsldecmensual2.out";
		--TRACE ON;
	
		--IF EXISTS(SELECT tabname FROM bdilide:"informix".systables WHERE tabname = 'tmp_ideRecaudacionescteMensual')THEN
				DROP TABLE IF EXISTS tmp_ideRecaudacionescteMensual;
		--END IF;
							/* SE COMENTA YA NO SE UTILIZA LA RECAUDACIÓN DEL IMPUESTO
							IF EXISTS(SELECT tabname FROM bdilide:"informix".systables WHERE tabname = 'tmp_sl_detlideRecAnt')THEN
								DROP TABLE tmp_sl_detlideRecAnt;
						
							END IF;	*/	
		
		--IF EXISTS(SELECT tabname FROM bdilide:"informix".systables WHERE tabname = 'tmp_DatosClientesIde')THEN
			DROP TABLE IF EXISTS tmp_DatosClientesIde;
		--END IF;
		--IF EXISTS(SELECT tabname FROM bdilide:"informix".systables WHERE tabname = 'tmp_DireccionesClientesIde')THEN
			DROP TABLE IF EXISTS tmp_DireccionesClientesIde;
		--END IF;
		
		--IF EXISTS(SELECT tabname FROM bdilide:"informix".systables WHERE tabname = 'tmp_CteIDE')THEN
			DROP TABLE IF EXISTS tmp_CteIDE;
		--END IF;

		LET v_imes = MONTH(p_dfechaproceso);
		LET v_ianio = YEAR(p_dfechaproceso);
		LET v_saniomes = v_ianio || LPAD(v_imes,2,0);
		LET v_smesenero = v_ianio || '01';
		LET v_itotoperaciones = 0;
		--LET v_saniomesant = v_ianio || LPAD((v_imes - 1),2,0); --DSB 25/03/2013


		--CALCULAR PERIODO ANTERIOR
			LET dFormatoFechaPeriodo=MONTH(TODAY)||'/'||'01'||'/'||YEAR(TODAY);
			LET dFecha_primer_dia_anterior=dFormatoFechaPeriodo - 1 UNITS MONTH;
			LET dFecha_ultimo_dia_anterior=LPAD(MONTH(dFecha_primer_dia_anterior),2,0)||DAY(LAST_DAY(dFecha_primer_dia_anterior))||YEAR(dFecha_primer_dia_anterior);
		

        --SI EL TIPO DE DECLARACIÓN ES COMPLEMENTARIA ENTONCES SE OBTIENE EL NÚMERO DE FOLIO.
        IF pTipoDecl = 'C' THEN
            --SELECT (nvl(MAX(no_compl),0) + 1) INTO viNumComple  FROM bdilide:"informix".sl_declinfor WHERE aniomes= v_saniomes AND normal = 'C';
			--QUITAR
			--Se obtiene el num del SAT complementario
			LET viNumComple=pNumFolio;
            IF NOT EXISTS (SELECT aniomes FROM bdilide:"informix".sl_declinfor WHERE aniomes = v_saniomes AND normal = 'N' and no_compl = '0' ) THEN
                LET v_scodret = '00007';
                LET v_smensaje = 'No se puede generar Declaración complementaria sin hacer primero la Normal';
                RETURN v_scodret, v_smensaje;
             END IF;
        ELSE
            LET pFechaPresentacion = '';
            LET pNumFolio = '';
        END IF;

         --QUITAR
		 --IF viNumComple > 9 THEN
            --LET v_scodret = '00006';
            --LET v_smensaje = 'Se han generado el número de  Declaracines informativas complementarias permitidas.';
            --RETURN v_scodret, v_smensaje;
         --END IF;

		-- Valida que el proceso de la declaración mensual no haya sido generado.
		SELECT --{+INDEX(bdilide:sl_procesos 109_70 )}
		status INTO v_sstatus FROM bdilide:"informix".sl_procesos WHERE proceso = 'decmensual' AND MONTH(fech_proceso) =  v_imes
		AND YEAR(fech_proceso) = v_ianio;

		IF v_sstatus IS NULL THEN
			INSERT INTO bdilide:"informix".sl_procesos (proceso, fech_proceso, status, user_insert, fecha_insert) VALUES ('decmensual', p_dfechaproceso, '0', p_susuario, v_dfecha_hoy);
			DELETE bdilide:"informix".sl_menxml WHERE fechaxml = v_saniomes;
			--DELETE bdilide:"informix".sl_declinfor WHERE normal = pTipoDecl AND no_compl = viNumComple AND aniomes = v_saniomes;
			DELETE bdilide:"informix".sl_declinfor WHERE normal = pTipoDecl AND aniomes = v_saniomes;
		ELSE
			IF v_sstatus = "0" THEN
				DELETE bdilide:"informix".sl_menxml WHERE fechaxml = v_saniomes;
				--DELETE bdilide:"informix".sl_declinfor WHERE normal = pTipoDecl AND no_compl = viNumComple AND aniomes = v_saniomes;
				DELETE bdilide:"informix".sl_declinfor WHERE normal = pTipoDecl AND aniomes = v_saniomes;
			ELIF v_sstatus = "1" THEN
				SELECT {+INDEX(bdilide: sl_menxml idx_sl_menxml02)} COUNT(*) INTO v_icount FROM bdilide:"informix".sl_menxml WHERE fechaxml = v_saniomes;
				IF v_icount <> 0 THEN
					--IF EXISTS (SELECT aniomes FROM bdilide:"informix".sl_declinfor WHERE normal = pTipoDecl AND no_compl = viNumComple AND aniomes = v_saniomes) THEN
					IF EXISTS (SELECT aniomes FROM bdilide:"informix".sl_declinfor WHERE normal = pTipoDecl AND aniomes = v_saniomes) THEN
						--DELETE bdilide:"informix".sl_declinfor WHERE aniomes = v_saniomes AND normal = pTipoDecl AND no_compl = viNumComple;
						DELETE bdilide:"informix".sl_declinfor WHERE aniomes = v_saniomes AND normal = pTipoDecl;
						DELETE bdilide:"informix".sl_menxml WHERE fechaxml = v_saniomes;
						UPDATE bdilide:"informix".sl_procesos SET status = 0 WHERE proceso = 'decmensual' AND fech_proceso = p_dfechaproceso;
						--LET v_scodret = '00000';
						--LET v_smensaje = 'REPORTE EXITOSO EL ARCHIVO XML PUEDE SER GENERADO';
						--RETURN v_scodret, v_smensaje;
					ELSE
						DELETE bdilide:"informix".sl_menxml WHERE fechaxml = v_saniomes;
						UPDATE bdilide:"informix".sl_procesos SET status = 0 WHERE proceso = 'decmensual' AND fech_proceso = p_dfechaproceso;
					END IF
				ELSE
					DELETE bdilide:"informix".sl_declinfor WHERE aniomes = v_saniomes AND normal = pTipoDecl AND no_compl = viNumComple;
					UPDATE bdilide:"informix".sl_procesos SET status = 0 WHERE proceso = 'decmensual' AND fech_proceso = p_dfechaproceso;
				END IF
			END IF
		END IF

		---Valida que se haya enterado la cifra total de recaudación para TESOFE para continuar generando la declaracion mensual.
		--FOREACH
		--	SELECT num_operacion, fech_operacion INTO v_snum_operacion, v_dfech_operacion
		--	FROM bdilide:"informix".sl_enteros WHERE MONTH(fech_entero) = v_imes AND YEAR(fech_entero) = v_ianio AND monto > 0

		--	IF v_snum_operacion IS NULL OR v_dfech_operacion IS NULL THEN
		--		LET v_scodret = '00004';
		--		LET v_sfecha_char = (LPAD(DAY(v_dfech_proceso),2,0))||'/'||(LPAD(MONTH(v_dfech_proceso),2,0))||'/'||(YEAR(v_dfech_proceso));
		--		LET v_smensaje = 'FALTA CAPTURAR EL NUMERO DE OPERACION Y FECHA DEL REPORTE ENTERO DEL: '||v_sfecha_char;
		--		RETURN v_scodret, v_smensaje;
		--	END IF
		--END FOREACH
			--Selecciona y guarda en tabla temporal los clientes con su respectiva sdumatoria de imp_gravado e a imp_arecaudar del aniomes
			
			--SE CREA TABLA FISICA TEMPORAL
			CREATE TABLE "informix".tmp_ideRecaudacionescteMensual
			(
				cliente char(20) NOT NULL,
				imp_gravado money(16,2) NOT NULL,
				imp_arecaudar money(16,2) NOT NULL,
				imp_recaudado money(16,2),
				fecha_ret DATE
			);
			BEGIN;
			CREATE INDEX "informix".idx_tmp_iderecmen_cte ON "informix".tmp_ideRecaudacionescteMensual(cliente);
				UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_ideRecaudacionescteMensual;
			COMMIT;
			--EJECUCIÓN DE PROCEDIMIENTO PARA OBTENER LA FECHA RETENCIÓN	
			EXECUTE PROCEDURE bdicheq:"informix".sp_dia_primero_ultimo_mes_anio(v_imes,v_ianio) INTO v_scodret,v_dfecha_ret_pas, v_dfecha_ret;
		
		
		
		FOREACH 
			--SE COMENTA YA QUE SE ENCONTRABA FIJA LA fecha_ret
			--
			SELECT {+INDEX(bdilide:sl_retlide 172_362)}
			num_cte as cliente, NVL(ROUND(imp_gravado,0),0) AS imp_gravado,
			NVL(ROUND(imp_arecaudar,0),0) AS imp_arecaudar,
			--0 as imp_recaudado, '01-01-1900' as fecha_ret
			0 as imp_recaudado, v_dfecha_ret as fecha_ret
			INTO v_ctnum_cte, v_mtimp_gravado, v_mtimp_arecaudar, v_mtimp_recaudado, v_dtfecha_ret
			FROM bdilide:"informix".sl_retlide
			WHERE  aniomes = v_saniomes
			GROUP BY num_cte,imp_gravado,imp_arecaudar
			
	
			INSERT INTO bdilide:"informix".tmp_ideRecaudacionescteMensual(cliente,imp_gravado,imp_arecaudar,
			imp_recaudado,fecha_ret)
			VALUES(v_ctnum_cte, v_mtimp_gravado, v_mtimp_arecaudar, v_mtimp_recaudado, v_dtfecha_ret);
			
	
		
		END FOREACH
		
			LET v_smensaje = 'SE GUARDO EN tmp_ideRecaudacionescteMensual';
			
			--SE COMENTA YA QUE LA CONSULTA TOMA TODO EL AÑO Y SE FILTRA PARA SOLO EL MES A GENERAR
			SELECT {+INDEX(bdilide:sl_retlide 172_362)}
			num_cte as cliente
			FROM bdilide:"informix".sl_retlide
			--WHERE  aniomes >= v_smesenero  and aniomes <= v_saniomes
			WHERE aniomes = v_saniomes
			GROUP BY num_cte 
			INTO TEMP tmp_CteIDE WITH NO LOG;			
			LET v_smensaje = 'SE GUARDO EN tmp_CteIDE';
			
			--SE CREA TABLA FISICA TEMPORAL
			CREATE TABLE "informix".tmp_DatosClientesIde
			(
				tpo_persona char(2),
				apell_paterno char(26),
				apell_materno char(26),
				nombre1 char(26),
				nombre2 char(26) NOT NULL,
				razon_social char(60) NOT NULL,
				rfc char(13),
				curp char(20),
				cliente char(20) NOT NULL
			);
			BEGIN;
			CREATE INDEX "informix".idx_tmp_si_cte ON "informix".tmp_DatosClientesIde(cliente);
				UPDATE STATISTICS MEDIUM FOR TABLE  "informix".tmp_DatosClientesIde;
			COMMIT;
		
		
		FOREACH	
	
			--Selecciona los dato personales de los clientes y los guarda en tabla temporal
			SELECT {+INDEX(bdinteg:si_cliente 224_479 )}
			a.tpo_persona as tpo_persona, a.apell_paterno as apell_paterno,
			a.apell_materno as apell_materno, a.nombre1 as nombre1, a.nombre2 as nombre2,
			a.razon_social as razon_social, a.rfc as rfc, b.curp as curp, c.cliente as cliente
			INTO v_tpo_persona, v_apell_paterno, v_apell_materno, v_nombre1, v_nombre2, v_razon_social, v_rfc, v_curp, v_cliente 
			FROM bdinteg:"informix".si_cliente as a, bdinteg:"informix".si_ctepf as b , tmp_CteIDE as c
			WHERE a.numcte = c.cliente
			AND a.numcte = b.numcte
					
			
			INSERT INTO bdilide:"informix".tmp_DatosClientesIde(tpo_persona,apell_paterno,apell_materno,
			nombre1,nombre2,razon_social,rfc,curp, cliente)
			VALUES(v_tpo_persona, v_apell_paterno, v_apell_materno, v_nombre1, v_nombre2, v_razon_social, v_rfc, v_curp, v_cliente);
	
	
			
		END FOREACH	
			
			LET v_smensaje = 'SE GUARDO EN tmp_DatosClientesIde';

			INSERT INTO tmp_DatosClientesIde
			SELECT {+INDEX(bdinteg:si_cliente 224_479 )}
			a.tpo_persona as tpo_persona, a.apell_paterno as apell_paterno,
			a.apell_materno as apell_materno, a.nombre1 as nombre1, a.nombre2 as nombre2,
			a.razon_social as razon_social, a.rfc as rfc, '' as curp, c.cliente as cliente
			FROM bdinteg:"informix".si_cliente as a, bdinteg:"informix".si_ctepm as b , tmp_CteIDE as c
			WHERE a.numcte = c.cliente
			AND a.numcte = b.numcte;
			
			LET v_smensaje = 'SE GUARDO EN tmp_DatosClientesIde';
			
			--SE CREA TABLA FISICA TEMPORAL
			CREATE TABLE "informix".tmp_DireccionesClientesIde
			(
			nombrecalle char(30),
			numeroextcalle char(10),
			numerointcalle char(10),
			nombrezona char(32),
			cod_postal char(5),
			cliente char(20) NOT NULL
			);
			
			BEGIN;
			
			CREATE INDEX "informix".idx_tmp_dircli_cte ON "informix".tmp_DireccionesClientesIde(cliente);
				UPDATE STATISTICS MEDIUM FOR TABLE tmp_DireccionesClientesIde;
			
			COMMIT;
		
		
		FOREACH 
			
			SELECT {+INDEX(bdinteg:si_direcciones_actual idx_diract_cte3)}
			c.nombrecalle as nombrecalle, d.numeroextcalle as numeroextcalle, d.numerointcalle as numerointcalle,
			z.nombrezona as nombrezona, d.cod_postal as cod_postal, tmpIde.cliente as cliente
			INTO v_cnombrecalle,v_cnumeroextcalle, v_cnumerointcalle, v_cnombrezona, v_ccod_postal, vccliente
	 		FROM bdinteg:"informix".si_direcciones_actual d, bdinteg:"informix".si_catcalles c, bdinteg:"informix".si_catzonas z, tmp_CteIDE as tmpIde
			WHERE d.numcte = tmpIde.cliente AND d.tipo_dir = 1 AND c.numerocalle = d.numerocalle
			AND d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia
			AND d.secuencia IN (SELECT MAX(secuencia)
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = tmpIde.cliente
			AND tipo_dir = 1)
			
		
			
			INSERT INTO bdilide:"informix".tmp_DireccionesClientesIde(nombrecalle,numeroextcalle,numerointcalle,nombrezona,cod_postal,cliente)
			VALUES(v_cnombrecalle,v_cnumeroextcalle, v_cnumerointcalle, v_cnombrezona, v_ccod_postal, vccliente);
		
	
		
		END FOREACH
			
			LET v_smensaje = 'SE GUARDO EN tmp_DireccionesClientesIde';
		

		FOREACH 
		
		
		
			SELECT {+INDEX(bdilide:tmp_ideRecaudacionescteMensual idx_tmp_iderecmen_cte)}--LLAMADO DE NUEVO INDEX  
			cliente, round(NVL(imp_gravado,0),0), round(NVL(imp_arecaudar,0),0),round(NVL(imp_recaudado,0),0) , fecha_ret
			INTO v_snum_cte, v_mimp_gravado, v_mimp_arecaudar, v_mimp_recaudado, v_dfecha_ret
			FROM tmp_ideRecaudacionescteMensual
			WHERE cliente IS NOT NULL
	
			--Selecciona todos los clientes con su respectivo impuesto gravado e impuesto a recaudar.
			
			IF v_dfecha_ret IS NULL THEN
				LET v_dfecha_ret = p_dfechaproceso;
			END IF

			LET v_mimp_remanente = 0;
			LET mRecPendiente = ROUND(NVL(v_mimp_arecaudar,0)) - ROUND(NVL(v_mimp_recaudado,0));

            -- Se hace este condicional para truncar a cero cuando resultan pendientes negativos.
            IF mRecPendiente < 0 THEN
				LET mRecPendiente = 0;
			END IF;
			--Selecciona los datos de cliente
			SELECT {+INDEX(bdilide:tmp_DatosClientesIde idx_tmp_si_cte)} NVL(tpo_persona,'01'), apell_paterno, apell_materno, nombre1, nombre2, NVL(razon_social,''), NVL(rfc,''), NVL(curp,'')
			INTO v_stpo_persona, v_sapell_paterno, v_sapell_materno, v_snombre1, v_snombre2, v_srazon_social, v_srfc,v_scurp
			FROM tmp_DatosClientesIde
			WHERE cliente = v_snum_cte;

		   	IF v_scurp IS NOT NULL AND v_scurp <> '' THEN
				EXECUTE PROCEDURE bdilide:"informix".sp_checacurp (v_scurp, v_srfc) INTO v_sretorno, v_sleyenda;
				IF v_sretorno <> '000000' THEN
					LET v_scurp = '';
				END IF
			ELSE
				LET v_scurp = '';
			END IF
			-- Selecciona el domicilio de cliente
			SELECT {+INDEX(bdilide:tmp_DireccionesClientesIde idx_tmp_dircli_cte)}
			nombrecalle, numeroextcalle, numerointcalle,nombrezona, cod_postal
			INTO v_snombrecalle, v_snumeroextcalle, v_snumerointcalle, v_snombrezona, v_scod_postal
			FROM tmp_DireccionesClientesIde
			WHERE cliente = v_snum_cte;

			IF v_snumerointcalle IS NULL AND v_snombrezona IS NULL THEN
				LET v_snombrezona = 'DOMICILIO NO REGISTRADO';
			END IF

			INSERT INTO bdilide:"informix".sl_menxml (num_cte, tpo_persona, rfc, curp, razon_soc, apell_pat, apell_mat, nombre1, nombre2,
			nom_calle, num_ext, num_int, nom_colonia, cod_post, fecha_ret, montoexcedente, impdeterminado, imprecaudado, recpendiente, remrecaudado, fechaxml)
			VALUES(v_snum_cte, v_stpo_persona, v_srfc, v_scurp, v_srazon_social, v_sapell_paterno, v_sapell_materno, v_snombre1, v_snombre2,
			v_snombrecalle, v_snumeroextcalle, v_snumerointcalle, v_snombrezona, v_scod_postal, v_dfecha_ret, v_mimp_gravado,
			v_mimp_arecaudar,v_mimp_recaudado, mRecPendiente , v_mimp_remanente, v_saniomes);

				LET nCont = nCont + 1;
				IF nCont =  5000 THEN	--DSB 01-11-2011
				    UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_menxml;
					LET nCont= 0;
				END IF;
				
					
		END FOREACH

		LET v_smensaje = 'INSERTO LOS CALCULOS sl_menxml';
		
		--DSB 25/03/2013
		LET v_snum_cte = '';

		--DSB-12/08/2013
		IF v_imes = '01' THEN 
			LET v_smensaje = 'INICIO CALCULO MES DE ENERO';
			FOREACH
				SELECT {+INDEX(bdilide: sl_menxml 116_375)}
				DISTINCT num_cte
				INTO v_snum_cte
				FROM bdilide:"informix".sl_menxml
				WHERE num_cte IS NOT NULL AND fechaxml = v_saniomes
				
				SELECT {+INDEX(bdilide: sl_menxml 116_375)}
				SUM(NVL(ROUND(impdeterminado,0),0)) - SUM(NVL(ROUND(imprecaudado,0),0))--dsb-30/04/2013
				INTO v_msaldopenrec
				FROM bdilide:"informix".sl_menxml
				WHERE num_cte = v_snum_cte AND fechaxml = v_saniomes;
				
				UPDATE bdilide:"informix".sl_menxml
				SET saldopenrec = NVL(v_msaldopenrec,0)
				WHERE num_cte = v_snum_cte AND fechaxml = v_saniomes;
			END FOREACH;
			
			-- Genera los totales de los montos recaudados
			

			FOREACH
			
			
			SELECT {+INDEX(bdilide: sl_menxml 116_375)}
			SUM(NVL(ROUND(imprecaudado,0),0)), SUM(NVL(ROUND(remrecaudado,0),0)), SUM(NVL(ROUND(saldopenrec,0),0))
			INTO v_mtotrecaudado, v_mtotremanente, v_mtotsaldopenrec 
			FROM bdilide:"informix".sl_menxml 
			WHERE fecha_ret =v_dfecha_ret
			
			END FOREACH;
			
			LET v_smensaje = 'TERMINA CALCULO DE ENERO';
		ELSE
			LET v_smensaje = 'INICIO CALCULO DEL MES';
			
			--Se obtiene el mes base a buscar
			IF v_saniomes = '201306' THEN --En caso del primer año se realiza una busqueda desde el inicio 
				LET v_saniomesant = v_ianio || '01';
			ELSE
				LET v_saniomesant =  v_ianio || LPAD((v_imes - 1),2,0); --DSB 25/03/2013
			END IF;
			
			FOREACH
			SELECT {+INDEX(bdilide: sl_menxml 116_375)} num_cte
			INTO v_snum_cte
			FROM bdilide:"informix".sl_menxml
			WHERE num_cte IS NOT NULL AND fechaxml BETWEEN v_saniomesant AND v_saniomes
			GROUP BY num_cte
				LET nCont = 0;
				LET v_msaldopenrec = 0;
				LET v_mimp_recaudado = 0;
				LET v_mimp_remanente = 0;
			
				IF v_saniomes = '201306' THEN 
					--Para el mes de junio se buscara los meses de enero a mayo el ultimo registro desde el cual se obtendra el saldo pendiente por recaudar
					LET v_dfecha_ret_pas = '01-01-2013'::DATE;
					LET v_dfecha_ret = '05-31-2013'::DATE;
					LET v_smensaje = 'SALDO JUNIO';
					
					--Se obtiene el saldo pendiente por recaudar
					SELECT {+INDEX(bdilide: sl_menxml 116_375)} 
					NVL(SUM(ROUND(impdeterminado,0)),0) - NVL(SUM(ROUND(imprecaudado,0)),0) - NVL(SUM(ROUND(remrecaudado,0)),0)
					INTO v_msaldopenrec
					FROM bdilide:"informix".sl_menxml 
					WHERE num_cte = v_snum_cte  
					AND fecha_ret BETWEEN v_dfecha_ret_pas AND v_dfecha_ret;
					
				ELSE
					LET v_smensaje = 'SALDO CUALQUIER MES';
					--Se obtiene la fecha de cierre del mes pasado
					EXECUTE PROCEDURE bdicheq:"informix".sp_dia_primero_ultimo_mes_anio(LPAD((v_imes - 1),2,0),v_ianio) INTO v_scodret,v_dfecha_ret_pas, v_dfecha_ret;
					
					SELECT {+INDEX(bdilide: sl_menxml 116_375)} NVL(saldopenrec,0)
					INTO v_msaldopenrec
					FROM bdilide:"informix".sl_menxml 
					WHERE num_cte = v_snum_cte  
					AND fecha_ret = (SELECT MAX(fecha_ret) FROM bdilide:"informix".sl_menxml WHERE num_cte = v_snum_cte AND fecha_ret BETWEEN v_dfecha_ret_pas AND v_dfecha_ret);
					
				END IF;
				
				LET v_smensaje = 'TERMINA SALDO ANTERIOR';

				--Si tiene algun registro del mes actual
				IF EXISTS(SELECT {+INDEX(bdilide: sl_menxml 116_375)} 1 FROM bdilide:"informix".sl_menxml WHERE num_cte = v_snum_cte AND fechaxml = v_saniomes) THEN
					
					FOREACH 
					SELECT {+INDEX(bdilide: sl_menxml 116_375)} fecha_ret
					INTO v_dfecha_ret
					FROM bdilide:"informix".sl_menxml
					WHERE num_cte = v_snum_cte AND fechaxml = v_saniomes
					ORDER BY fecha_ret ASC
						
						--Si es el primer registro
						IF nCont == 0 THEN
							UPDATE bdilide:"informix".sl_menxml
							SET saldopenrec = (NVL(ROUND(impdeterminado,0),0) - NVL(ROUND(imprecaudado,0),0) - NVL(ROUND(remrecaudado,0),0) + v_msaldopenrec)
							WHERE num_cte = v_snum_cte AND fecha_ret = v_dfecha_ret AND fechaxml = v_saniomes;
							
							SELECT {+INDEX(bdilide: sl_menxml 116_375)}
							saldopenrec, imprecaudado, remrecaudado
							INTO v_msaldopenrec, v_mimp_recaudado, v_mimp_remanente
							FROM bdilide:"informix".sl_menxml
							WHERE num_cte = v_snum_cte AND fecha_ret = v_dfecha_ret AND fechaxml = v_saniomes;
							
							LET nCont = 1;
						ELSE
							--Se actualiza por fecha_ret
							UPDATE bdilide:"informix".sl_menxml
							SET saldopenrec = (NVL(ROUND(impdeterminado,0),0) - NVL(ROUND(imprecaudado,0),0) - NVL(ROUND(remrecaudado,0),0) + v_msaldopenrec)
							WHERE num_cte = v_snum_cte AND fechaxml = v_saniomes
							AND fecha_ret = v_dfecha_ret;
							
							SELECT {+INDEX(bdilide: sl_menxml 116_375)}
							saldopenrec, imprecaudado, remrecaudado
							INTO v_msaldopenrec, v_mimp_recaudado, v_mimp_remanente
							FROM bdilide:"informix".sl_menxml
							WHERE num_cte = v_snum_cte AND fecha_ret = v_dfecha_ret AND fechaxml = v_saniomes;
						END IF;
						
					END FOREACH;
				
				END IF;
				--Agrega al monto total de montos recaudados
				LET v_mtotrecaudado = v_mtotrecaudado + ROUND(v_mimp_recaudado,0);
				--LET v_mtotremanente = v_mtotremanente + ROUND(v_mimp_remanente,0);
				LET v_mtotsaldopenrec = v_mtotsaldopenrec + ROUND(v_msaldopenrec,0);
			END FOREACH;
			LET v_smensaje = 'TERMINA CALCULO DEL MES';
		END IF;

		-- Genera los total del remanente de los montos recaudados
		SELECT {+INDEX(bdilide: sl_menxml idx_sl_menxml02)}
		SUM(NVL(ROUND(remrecaudado,0),0))	--DSB 25/03/2013
		INTO  v_mtotremanente 
		FROM bdilide:"informix".sl_menxml
		WHERE fechaxml = v_saniomes;

		LET v_smensaje = 'GENERA LOS TOTALES DE LOS MONTOS RECAUDADOS';

		SELECT {+INDEX(bdilide:sl_retlide 172_362)}
		SUM(NVL(ROUND(imp_gravado,0),0)), SUM(NVL(ROUND(imp_arecaudar,0),0))
		INTO v_mtotexcedente, v_mtotdeterminado 
		FROM bdilide:"informix".sl_retlide
		WHERE aniomes = v_saniomes;

		LET v_mtotpendiente = v_mtotdeterminado - v_mtotrecaudado;

		SELECT {+INDEX(bdilide:sl_menxml idx_sl_menxml02)}
		COUNT(num_cte)
		INTO v_itotoperaciones
		FROM bdilide:"informix".sl_menxml
		WHERE fechaxml = v_saniomes;

		
		SELECT {+INDEX(bdilide:sl_enteros 102_23)}
		SUM(NVL(ROUND(monto,0),0))	
		INTO v_montoentero 
		FROM bdilide:"informix".sl_enteros WHERE fech_entero BETWEEN dFecha_primer_dia_anterior
		AND dFecha_ultimo_dia_anterior AND monto > 0;
		

		LET v_smensaje = 'GENERA EL TOTAL DEL ENTERO';

		INSERT INTO bdilide:"informix".sl_declinfor (aniomes, normal, no_compl, total_oper, total_depositos, total_ide, total_rec, total_pend, total_reman,
		total_entero, fecha_genera, fecha_pres, no_folio_ant, pend_generar, user_insert, fecha_insert, total_saldopenrec)
		VALUES (v_saniomes, pTipoDecl, viNumComple, NVL(v_itotoperaciones,0), NVL(ROUND(v_mtotexcedente),0), NVL(ROUND(v_mtotdeterminado),0), NVL(ROUND(v_mtotrecaudado),0),
		NVL(ROUND(v_mtotpendiente),0), NVL(ROUND(v_mtotremanente),0),NVL(ROUND(v_montoentero),0), p_dfechaproceso, pFechaPresentacion, pNumFolio, 'N', p_susuario, v_dfecha_hoy, NVL(ROUND(v_mtotsaldopenrec),0) );	--DSB 25/03/2013

		UPDATE bdilide:"informix".sl_procesos SET status = 1, fecha_insert = CURRENT::DATE WHERE proceso = 'decmensual' AND fech_proceso = p_dfechaproceso;
		LET v_scodret = '00000';
		LET v_smensaje = 'REPORTE EXITOSO EL ARCHIVO XML PUEDE SER GENERADO';

	END
	DROP TABLE tmp_ideRecaudacionescteMensual;
	--DROP TABLE tmp_sl_detlideRecAnt; SE COMENTA YA NO SE UTILIZA LA RECAUDACIÓN DEL IMPUESTO 
	DROP TABLE tmp_DatosClientesIde;
	DROP TABLE tmp_DireccionesClientesIde;
	DROP TABLE tmp_CteIDE;
	
		IF bTransaccion = 't' THEN
			BEGIN;
		END IF;
  
	RETURN v_scodret, v_smensaje;
	
END PROCEDURE
