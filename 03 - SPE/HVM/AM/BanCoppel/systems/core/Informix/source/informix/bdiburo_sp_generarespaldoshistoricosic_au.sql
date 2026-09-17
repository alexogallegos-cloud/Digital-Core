CREATE PROCEDURE "informix".sp_generarespaldoshistoricosic_au(pNumCte        VARCHAR(25),
                                                           pInstitucion   CHAR(2))
RETURNING CHAR(6)  AS COD_RET,
		  CHAR(80) AS MENSAJE_EJEC;

--EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic_au('','BC')

--DECLARACIÃ?ÃÂ¯Ã?ÃÂ¿Ã?ÃÂ½N DE VARIABLES
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE iCantReg        		INTEGER;
DEFINE iCantReg2        	INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet          CHAR(80);

--INICIALIZACIÃ?ÃÂ¯Ã?ÃÂ¿Ã?ÃÂ½N DE VARIABLES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET iCantReg           	= 0;
LET iCantReg2           = 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet         = "RESPALDO REALIZADO EXITOSAMENTE";

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN TRIM(cCodRet), TRIM(cMensajeRet);
	   END IF;
	END EXCEPTION;

	 --SET DEBUG FILE TO "/RESPALDOS/Aldo/sp_generarespaldoshistoricosic_today.out";
	 --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;



		-- SE VALIDA SI EL NUMERO DE CLIENTE SE RECIBE VACIO
		IF NVL(pNumCte, "") = "" THEN
			LET cCodRet = "000003";
			LET cMensajeRet = "EL NÃ?ÃÂ¯Ã?ÃÂ¿Ã?ÃÂ½MERO DE CLIENTE RECIBIDO ES INCORRECTO";
			RETURN cCodRet, TRIM(cMensajeRet);
		END IF;
		
		-- /* PIQV
		-- SE VALIDA SI EL NUMERO DE SOLICITUD SE RECIBE VACIO
--IPCB Mayo2016 Reingenieria de Demonios. Se cambia el insert a la br_respuesta_hist

         

          INSERT INTO "informix".br_respuesta_hist(idrespuesta,institucion,numcte,num_solicitud,fecha_insert,secuencia,regreso) 
            SELECT 0,institucion,numcte,num_solicitud,fecha_insert,secuencia,regreso
			   FROM "informix".br_respuesta
			  WHERE institucion = pInstitucion
			    AND numcte = pNumCte;

--Se implementa el respaldo de br_respuesta_aprocesar
          INSERT INTO "informix".br_respuesta_aprocesar_hist(idrespuesta,institucion,numcte,num_solicitud,fecha_insert,status)
            SELECT 0,institucion,numcte,num_solicitud,fecha_insert,status
			   FROM "informix".br_respuesta_aprocesar
			  WHERE institucion = pInstitucion 
			    AND numcte = pNumCte;

--IPCB Mayo2016 Reingenieria de Demonios. 
				
		INSERT INTO "informix".br_traslado_hist(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
		     SELECT institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert
			   FROM "informix".br_traslado
		      WHERE institucion = pInstitucion
			    AND numcte = pNumCte;
				
--IPCB Mayo2016 Reingenieria de Demonios. Se elimina de la br_respuesta y br_respuesta_aprocesar
		DELETE FROM "informix".br_respuesta
			  WHERE institucion = pInstitucion
			    AND numcte = pNumCte;

		DELETE FROM "informix".br_respuesta_aprocesar
			  WHERE institucion = pInstitucion 
			    AND numcte = pNumCte;
                                         
		DELETE FROM "informix".br_respuesta_aprocesar_aux
			  WHERE institucion = pInstitucion 
			    AND numcte = pNumCte;

--IPCB Mayo2016 Reingenieria de Demonios. Se elimina de la br_respuesta y br_respuesta_aprocesar
		
		DELETE FROM "informix".br_traslado
              WHERE institucion = pInstitucion
  			    AND numcte = pNumCte;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_pn_hist
			(institucion, num_cliente, fecha_consulta, pnpn, pn00, pn01, pn02, pn03, pn04, pn05, pn06, pn07, pn08, pn09, pn10, pn11, pn12, pn13,
			pn14, pn15, pn16, pn17, pn18, pn19, pn20)	
		SELECT institucion, num_cliente, fecha_consulta, pnpn, pn00, pn01, pn02, pn03, pn04, pn05, pn06, pn07, pn08, pn09, pn10, pn11, pn12, pn13,
			pn14, pn15, pn16, pn17, pn18, pn19, pn20	
		FROM bdiburo:"informix".br_pn
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
		LET iCantReg = DBINFO("sqlca.sqlerrd2");

		-- SE VALIDA SI EXISTEN REGISTROS PARA CONTINUAR CON EL RESPALDO
		IF iCantReg = 0 THEN

			-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
			INSERT INTO bdiburo:"informix".br_error_hist
				(institucion,num_cliente,ar,ur,fecha)	 
			SELECT institucion,num_cliente,ar,ur,fecha
			FROM bdiburo:"informix".br_error
			WHERE num_cliente = pNumCte
			AND institucion = pInstitucion;

			LET iCantReg2 = DBINFO("sqlca.sqlerrd2");

			IF iCantReg2 = 0 THEN	
				LET cCodRet = "000002";
				LET cMensajeRet = "NO SE ENCONTRARON REGISTROS PARA RESPALDAR";
				RETURN cCodRet, TRIM(cMensajeRet);
			END IF

		END IF

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_tl_hist
			(institucion, num_cliente, tltl, tl00, tl01, tl02, tl03, tl04, tl05, tl06, tl07, tl08, tl09, tl10, tl11, tl12, tl13,
			tl14, tl15, tl16, tl17, tl18, tl19, tl20, tl21, tl22, tl23, tl24, tl25, tl26, tl27, tl28, tl29, tl30, tl31, tl32,
			tl33, tl34, tl35, tl36, tl37, tl38, tl42, fecha, tl45)	 
		SELECT institucion, num_cliente, tltl, tl00, tl01, tl02, tl03, tl04, tl05, tl06, tl07, tl08, tl09, tl10, tl11, tl12, tl13,
			   tl14, tl15, tl16, tl17, tl18, tl19, tl20, tl21, tl22, tl23, tl24, tl25, tl26, tl27, tl28, tl29, tl30, tl31, tl32,
			   tl33, tl34, tl35, tl36, tl37, tl38, tl42, fecha, tl45	 
		FROM bdiburo:"informix".br_tl
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
		-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
		DELETE FROM bdiburo:"informix".br_tl
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;

		-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_error
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_cr_hist
			(institucion, num_cliente, crcr, cr00, fecha)
		SELECT institucion, num_cliente, crcr, cr00, fecha
		FROM bdiburo:"informix".br_cr
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_cr
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_hi_hist
			(institucion, num_cliente, hihi, hi00, hi01, hi02, fecha)
		SELECT institucion, num_cliente, hihi, hi00, hi01, hi02, fecha
		FROM bdiburo:"informix".br_hi
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_hi
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_hr_hist
			(institucion, num_cliente, hrhr, hr00, hr01, hr02, fecha)
		SELECT institucion, num_cliente, hrhr, hr00, hr01, hr02, fecha
		FROM bdiburo:"informix".br_hr
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_hr
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_iq_hist
			(institucion, num_cliente, iqiq, iq00, iq01, iq02, iq03, iq04, iq05, iq06, iq07, iq08, iq09, fecha)
		SELECT institucion, num_cliente, iqiq, iq00, iq01, iq02, iq03, iq04, iq05, iq06, iq07, iq08, iq09, fecha
		FROM bdiburo:"informix".br_iq
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_iq
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_pa_hist
			(institucion, num_cliente, papa, pa00, pa01, pa02, pa03, pa04, pa05, pa06, pa07, pa08, pa09, pa10, pa11, pa12, fecha, codpais )
		SELECT institucion, num_cliente, papa, pa00, pa01, pa02, pa03, pa04, pa05, pa06, pa07, pa08, pa09, pa10, pa11, pa12, fecha, codpais 
		FROM bdiburo:"informix".br_pa
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_pa
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_pe_hist
			(institucion, num_cliente, pepe, pe00, pe01, pe02, pe03, pe04, pe05, pe06, pe07, pe08, pe09, pe10,  pe11, pe12, pe13, pe14, pe15,
			pe16, pe17, pe18, pe19, fecha, codpais )
		SELECT institucion, num_cliente, pepe, pe00, pe01, pe02, pe03, pe04, pe05, pe06, pe07, pe08, pe09, pe10,  pe11, pe12, pe13, pe14, pe15,
			pe16, pe17, pe18, pe19, fecha, codpais
		FROM bdiburo:"informix".br_pe
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_pe
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;

		
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_pn
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_rs_hist
			(institucion, num_cliente, rsrs, rs00, rs01, rs02, rs03, rs04, rs05, rs06, rs07, rs08, rs09, rs10, rs11, rs12, rs13, rs14, rs15, rs16, rs17,
			rs18, rs19, rs20, rs21, rs22, rs23, rs24, rs25, rs26, rs27, rs28, rs29, rs30, rs31, rs32, rs33, rs34,  rs35, rs36, rs37, rs38, rs39,
			rs40, rs41, fecha)	
		SELECT institucion, num_cliente, rsrs, rs00, rs01, rs02, rs03, rs04, rs05, rs06, rs07, rs08, rs09, rs10, rs11, rs12, rs13, rs14, rs15, rs16, rs17,
			rs18, rs19, rs20, rs21, rs22, rs23, rs24, rs25, rs26, rs27, rs28, rs29, rs30, rs31, rs32, rs33, rs34,  rs35, rs36, rs37, rs38, rs39,
			rs40, rs41, fecha
		FROM bdiburo:"informix".br_rs
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_rs
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_sc_hist
			(institucion, num_cliente, scsc, sc00, sc01, sc02, sc03, sc04, sc06, fecha)	 
		SELECT institucion, num_cliente, scsc, sc00, sc01, sc02, sc03, sc04, sc06, fecha
		FROM bdiburo:"informix".br_sc
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_sc
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_es_hist
			(institucion,num_cliente,es01,es02,es03,es04,fecha)	 
		SELECT institucion,num_cliente,es01,es02,es03,es04,fecha
		FROM bdiburo:"informix".br_es
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_es
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_ar_hist
			(institucion,num_cliente,arar,ar00,ar01,ar02,ar03,ar04,ar05,fecha)	 
		SELECT institucion,num_cliente,arar,ar00,ar01,ar02,ar03,ar04,ar05,fecha
		FROM bdiburo:"informix".br_ar
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_ar
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO bdiburo:"informix".br_ur_hist
			(institucion,num_cliente,urur,ur00,ur01,ur02,ur03,ur04,ur05,ur06,ur07,ur08,ur09,ur10,ur11,ur12,ur13,ur14,fecha )	 
		SELECT institucion,num_cliente,urur,ur00,ur01,ur02,ur03,ur04,ur05,ur06,ur07,ur08,ur09,ur10,ur11,ur12,ur13,ur14,fecha 
		FROM bdiburo:"informix".br_ur
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion;
		
        -- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
        DELETE FROM bdiburo:"informix".br_ur
        WHERE num_cliente = pNumCte
        AND institucion = pInstitucion;

	
	RETURN cCodRet, TRIM(cMensajeRet);
END
END PROCEDURE 
DOCUMENT
'Realiza el respaldo de las tablas donde se registra la informacion de las SIC',
'AUTOR : Aldo E Hernandez',
'FECHA : 08/Noviembre/2019',
'BD    : BDIBURO';

CREATE PROCEDURE "informix".sp_descarga_arch_vartdc(ptipoproducto CHAR(03), pfecha DATE)
       RETURNING CHAR(6) AS codigo, CHAR(200) AS mensaje;

--EXECUTE PROCEDURE "informix".sp_descarga_arch_vartdc('CRV', today);
--EXECUTE PROCEDURE "informix".sp_descarga_arch_vartdc('CNR', today);

DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(200);
DEFINE	cCod_ret		CHAR(6);

DEFINE vnum_cuenta		CHAR(20);
DEFINE vapellido_p		CHAR(30);
DEFINE vapellido_m		CHAR(30);
DEFINE vp_nombre		CHAR(25);
DEFINE vs_nombre		CHAR(25);
DEFINE vfecha_nac		DATE;
DEFINE vrfc				CHAR(13);
DEFINE vdireccion		CHAR(160);
DEFINE vdireccion1		CHAR(80);
DEFINE vdireccion2		CHAR(80);
DEFINE vnombrecalle		CHAR(100);
DEFINE vnumeroextcalle	CHAR(100);
DEFINE vnumerointcalle	CHAR(100);
DEFINE vcolon_pobla		CHAR(65);
DEFINE vdeleg_munic		CHAR(65);
DEFINE vciudad			CHAR(65);
DEFINE vestado			CHAR(4);
DEFINE vcp				CHAR(5);
DEFINE vfecha_proc		DATE;

DEFINE vpaso			INTEGER;
DEFINE vnum_arch		CHAR(4);
DEFINE vfecha_arch		CHAR(6);
DEFINE vfec_com			CHAR(6);
DEFINE vnom_archivo		CHAR(100);
DEFINE cnomarchivo1		CHAR(100);
DEFINE vmonth			CHAR(2);
DEFINE vyear			CHAR(2);
DEFINE cruta			CHAR(100);
DEFINE vnombre			CHAR(100);

DEFINE cSql				CHAR(30000);
DEFINE cSql1 			CHAR(200);
DEFINE cSql2 			CHAR(30000);
DEFINE cConsulta		CHAR(30000);

DEFINE sNumParametro	SMALLINT;
DEFINE cTipoContrato	CHAR(2);
DEFINE cTipoProducto	CHAR(3);
DEFINE vreincio			CHAR(1);
DEFINE cnum_credito		CHAR(20);
DEFINE cnum_producto 	CHAR (4);


LET sql_err				= 0;
LET isam_err			= 0;
LET error_info			= '';
LET cMensaje			= '';
LET cCod_ret			= '000000';
LET vnum_cuenta			= '';
LET vapellido_p			= '';
LET vapellido_m			= '';
LET vp_nombre			= '';
LET vs_nombre			= '';
LET vfecha_nac			= DATE(1);
LET vrfc				= '';
LET vdireccion			= '';
LET vdireccion1			= '';
LET vdireccion2			= '';
LET vnombrecalle		= '';
LET vnumeroextcalle		= '';
LET vnumerointcalle		= '';
LET vcolon_pobla		= '';
LET vdeleg_munic		= '';
LET vciudad				= '';
LET vestado				= '';
LET vcp					= '';
LET vfecha_proc			= DATE(1);

LET vpaso				= 0;
LET vnum_arch			= '';
LET vfecha_arch			= '';
LET vfec_com			= '';
LET vnom_archivo		= '';
LET cnomarchivo1   		='';
LET vmonth				= '';
LET vyear				= '';
LET cruta				= '';
LET vnombre				= '';

LET cSql				= '';
LET cSql1 				='';
LET cSql2				='';
LET cConsulta			= '';

LET sNumParametro		= 0;
LET cTipoContrato		= '';
LET cTipoProducto		= '';
LET vreincio			= '';
LET cnum_credito 		= '';
LET cnum_producto		= '';
												  

--  SET DEBUG FILE TO "sp_descarga_arch_vartdc.out";
--  TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = TRIM(error_info) || "     ERROR EN EL PASO: " || vpaso;
		IF vnum_cuenta <> "" THEN
			LET cMensaje = TRIM(cMensaje) || "   EN LA CUENTA: " || TRIM(vnum_cuenta);
		END IF;
		RETURN cCod_ret, TRIM(cMensaje);
	END EXCEPTION;

	IF ptipoproducto IS NULL OR ptipoproducto = '' THEN
		LET cCod_ret = '000100';
		LET cMensaje = 'PARAMETRO TIPO DE PRODUCTO INVALIDO';
		RETURN cCod_ret, TRIM(cMensaje);
	END IF;

	IF pfecha IS NULL OR pfecha = '' THEN
		LET cCod_ret = '000150';
		LET cMensaje = 'PARAMETRO FECHA INVALIDO';
		RETURN cCod_ret, TRIM(cMensaje);
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--OBTENER FECHA DEL ARCHIVO CON EL QUE SE TRABAJARA
	IF ptipoproducto = 'CRV' THEN
		LET sNumParametro = 144;
	ELSE
		LET sNumParametro = 149;
	END IF;

	SELECT valor INTO vfecha_arch 
	FROM "informix".br_param 
	WHERE cod_param = sNumParametro; LET vpaso = 1;

	IF vfecha_arch IS NULL THEN LET vfecha_arch = ""; END IF;

	--OBTENER RUTA DEL ARCHIVO
	SELECT valor INTO cruta 
	FROM bdicobranza:"informix".cb_param 
	WHERE empresa = "001"
	AND cod_param = 87; LET vpaso = 2;
	
	LET vfecha_proc = MDY(MONTH(pfecha), 1, YEAR(pfecha)) - 1 UNITS DAY;

	LET vfec_com = LPAD(MONTH(pfecha),2,0) || YEAR(pfecha); 

	IF ptipoproducto = 'CRV' THEN
		LET sNumParametro = 143;
	ELSE
		LET sNumParametro = 148;
	END IF;

	--SE COMPARAN LAS FECHAS PARA VER SI SON DISTINTAS, SI LO SON SE REINICIA LA VARIABLE DE LA NUMERACION DEL ARCHIVO
	IF vfecha_arch <> vfec_com THEN
		BEGIN WORK; 
			UPDATE "informix".br_param
			SET valor = "01"
			WHERE cod_param = sNumParametro; LET vpaso = 3;
		COMMIT WORK; 
	END IF;
	
	--OBTENER NUMERO DEL ARCHIVO CON EL QUE SE TRABAJARA
	SELECT valor INTO vnum_arch 
	FROM "informix".br_param 
	WHERE cod_param = sNumParametro; LET vpaso = 4;
	
	IF vnum_arch = "" OR vnum_arch IS NULL THEN LET vnum_arch = "01"; END IF;

	LET vyear = SUBSTR(YEAR(vfecha_proc),3,2);
	LET vmonth = LPAD(MONTH(vfecha_proc),2,0);

	IF ptipoproducto = 'CRV' THEN
		SELECT valor INTO vnombre		
		FROM "informix".br_param 
		WHERE cod_param = 150;

		LET vnom_archivo = TRIM(vnombre) || vyear || vmonth || "_" || TRIM(vnum_arch) || "_S.txt";
	ELSE
		SELECT valor INTO vnombre		
		FROM "informix".br_param 
		WHERE cod_param = 151;

		LET vnom_archivo = TRIM(vnombre) || vyear || vmonth || "_" || TRIM(vnum_arch) || "_S.txt";
	END IF; LET vpaso = 5;

	SELECT FIRST 1 "1" INTO vreincio 
	FROM "informix".br_arch_vartdc_proc
	WHERE fecha_proceso = vfecha_proc;

	IF vreincio IS NULL OR vreincio = '' THEN
		TRUNCATE TABLE "informix".br_arch_vartdc_proc DROP STORAGE;
	END IF;

	IF ptipoproducto = 'CRV' THEN
		SELECT mcc.num_credito, 
		cte.apell_paterno apellido_paterno,
		cte.apell_materno apellido_materno,
		cte.nombre1 primer_nombre,
		cte.nombre2 segundo_nombre,
		ctf.fecha_nac,
		cte.rfc,
		cll.nombrecalle,
		dir.numeroextcalle,
		dir.numerointcalle,
		czn.nombrezona colonia,
		czn.municipiozona municipio,
		czn.poblacionzona ciudad,
		cir.estado,
		dir.cod_postal,
		'CC' tipo_contrato,
		'CRV' tipo_producto,
		mcc.fecha fecha_cierre,
		mcc.num_producto
		FROM bdicred:"informix".sd_maecredcont mcc
			INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.numcte = mcc.numcte)
			INNER JOIN bdinteg:"informix".si_ctepf ctf ON (ctf.numcte = mcc.numcte)
			LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual dir ON (dir.numcte = mcc.numcte AND dir.tipo_dir = '1')
			LEFT OUTER JOIN bdinteg:"informix".si_catcalles cll ON (cll.numerocalle = dir.numerocalle)
			LEFT OUTER JOIN bdisolic:"informix".ss_circulo_edos cir ON (cir.empresa = mcc.empresa AND cir.clave = dir.estado)
			LEFT OUTER JOIN bdinteg:"informix".si_catzonas czn ON (czn.numerociudad = dir.numerociudad and czn.numerocolonia = dir.numerocolonia)
		WHERE mcc.empresa = "001"
		AND mcc.num_credito NOT IN(SELECT var.numero_cuenta FROM bdiburo:"informix".br_arch_vartdc_proc var WHERE var.numero_cuenta = mcc.num_credito AND var.fecha_proceso = vfecha_proc)
		AND mcc.status_cred IN ('AA','BA','BT','E1','E2','E3')  -- IFRS MACF
		AND mcc.num_producto NOT IN ('7800')
		AND mcc.fecha = vfecha_proc
		INTO TEMP paso_reserva WITH NO LOG;
	ELIF ptipoproducto = 'CNR' THEN  --RQM 10 1177 Se agrega nuevos prÃ©stamos 9100,9300
		SELECT mcd.num_credito, 
		cte.apell_paterno apellido_paterno,
		cte.apell_materno apellido_materno,
		cte.nombre1 primer_nombre,
		cte.nombre2 segundo_nombre,
		ctf.fecha_nac,
		cte.rfc,
		cll.nombrecalle,
		dir.numeroextcalle,
		dir.numerointcalle,
		czn.nombrezona colonia,
		czn.municipiozona municipio,
		czn.poblacionzona ciudad,
		cir.estado,
		dir.cod_postal,
		'PP' tipo_contrato,
		'CNR' tipo_producto,
		mcd.fecha fecha_cierre,
		mcd.num_producto
		FROM bdicred:"informix".sd_maecredcontcrd mcd
			INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.numcte = mcd.numcte)
			INNER JOIN bdinteg:"informix".si_ctepf ctf ON (ctf.numcte = mcd.numcte)
			LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual dir ON (dir.numcte = mcd.numcte AND dir.tipo_dir = '1')
			LEFT OUTER JOIN bdinteg:"informix".si_catcalles cll ON (cll.numerocalle = dir.numerocalle)
			LEFT OUTER JOIN bdisolic:"informix".ss_circulo_edos cir ON (cir.empresa = mcd.empresa AND cir.clave = dir.estado)
			LEFT OUTER JOIN bdinteg:"informix".si_catzonas czn ON (czn.numerociudad = dir.numerociudad and czn.numerocolonia = dir.numerocolonia)
		WHERE mcd.empresa = "001"
		AND mcd.num_credito NOT IN(SELECT var.numero_cuenta FROM "informix".br_arch_vartdc_proc var WHERE var.numero_cuenta = mcd.num_credito 
		AND var.fecha_proceso = vfecha_proc)
		AND mcd.status_cred IN ('AA','BA','BT','VP','E1','E2','E3')  -- IFRS MACF
        AND mcd.num_producto IN ('6400','6011','6300','6800','7600','7700','9100','9300')
		AND mcd.fecha = vfecha_proc
		INTO TEMP paso_reserva WITH NO LOG;
		
		FOREACH WITH HOLD
			SELECT mcc.num_credito, 
			cte.apell_paterno apellido_paterno,
			cte.apell_materno apellido_materno,
			cte.nombre1 primer_nombre,
			cte.nombre2 segundo_nombre,
			ctf.fecha_nac,
			cte.rfc,
			cll.nombrecalle,
			dir.numeroextcalle,
			dir.numerointcalle,
			czn.nombrezona colonia,
			czn.municipiozona municipio,
			czn.poblacionzona ciudad,
			cir.estado,
			dir.cod_postal,
			'PN' tipo_contrato,
			'CNR' tipo_producto,
			mcc.fecha fecha_cierre,
			mcc.num_producto
			INTO vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre,
				 vfecha_nac, vrfc, vnombrecalle, vnumeroextcalle, vnumerointcalle,
				 vcolon_pobla, vdeleg_munic, vciudad, vestado, vcp, cTipoContrato, cTipoProducto,vfecha_proc,cnum_producto
			FROM bdicred:"informix".sd_maecredcont mcc
				INNER JOIN bdinteg:"informix".si_cliente cte ON (cte.numcte = mcc.numcte)
				INNER JOIN bdinteg:"informix".si_ctepf ctf ON (ctf.numcte = mcc.numcte)
				LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual dir ON (dir.numcte = mcc.numcte AND dir.tipo_dir = '1')
				LEFT OUTER JOIN bdinteg:"informix".si_catcalles cll ON (cll.numerocalle = dir.numerocalle)
				LEFT OUTER JOIN bdisolic:"informix".ss_circulo_edos cir ON (cir.empresa = mcc.empresa AND cir.clave = dir.estado)
				LEFT OUTER JOIN bdinteg:"informix".si_catzonas czn ON (czn.numerociudad = dir.numerociudad and czn.numerocolonia = dir.numerocolonia)
			WHERE mcc.empresa = "001"
			AND mcc.num_credito NOT IN(SELECT var.numero_cuenta FROM "informix".br_arch_vartdc_proc var WHERE var.numero_cuenta = mcc.num_credito 
			AND var.fecha_proceso = vfecha_proc)
			AND mcc.status_cred IN ('AA','BA','BT','E1','E2','E3')  -- IFRS MACF
			AND mcc.num_producto IN('7800')															   
			AND mcc.fecha = vfecha_proc	

			BEGIN WORK;
				INSERT INTO paso_reserva
						(num_credito, apellido_paterno, apellido_materno, primer_nombre, segundo_nombre,
						fecha_nac, rfc, nombrecalle, numeroextcalle, numerointcalle, 
						colonia, municipio, ciudad, estado, cod_postal, tipo_contrato, tipo_producto,fecha_cierre,num_producto)
				VALUES (vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre,
						vfecha_nac, vrfc, vnombrecalle, vnumeroextcalle, vnumerointcalle,
						vcolon_pobla, vdeleg_munic, vciudad, vestado, vcp, cTipoContrato, cTipoProducto,vfecha_proc,cnum_producto);
			COMMIT WORK;
		END FOREACH;	
	ELSE
		LET cCod_ret = '000200';
		LET cMensaje = 'PARAMETRO TIPO DE PRODUCTO INVALIDO';
		RETURN cCod_ret, TRIM(cMensaje);
	END IF; LET vpaso = 6;

	CREATE INDEX indx_paso_reserva ON paso_reserva(fecha_cierre);
	IF ptipoproducto = 'CNR' THEN
		CREATE INDEX indx_paso_res_produc ON paso_reserva(num_producto);
	END IF;
	UPDATE statistics medium FOR TABLE paso_reserva; LET vpaso = 7;

--	SET DEBUG FILE TO "sp_descarga_arch_vartdc.out";
--  TRACE OFF;

	FOREACH WITH HOLD
		SELECT num_credito, apellido_paterno, apellido_materno, primer_nombre, segundo_nombre,
			fecha_nac, rfc, REPLACE(nombrecalle, "|", ""), REPLACE(numeroextcalle, "|", ""), REPLACE(numerointcalle, "|", ""),
			REPLACE(colonia, "|", ""), REPLACE(municipio, "|", ""), REPLACE(ciudad, "|", ""), REPLACE(estado, "|", ""), cod_postal, tipo_contrato, tipo_producto
		INTO vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre,
			vfecha_nac, vrfc, vnombrecalle, vnumeroextcalle, vnumerointcalle,
			vcolon_pobla, vdeleg_munic, vciudad, vestado, vcp, cTipoContrato, cTipoProducto
		FROM "informix".paso_reserva
		WHERE fecha_cierre = vfecha_proc

		LET vdireccion = TRIM(vnombrecalle) || ' ' || TRIM(vnumeroextcalle) || ' ' || TRIM(vnumerointcalle);

		LET vpaso = 8;

		IF vcp = 0 OR vcp IS NULL OR vcp = '' OR vdeleg_munic IS NULL OR vdeleg_munic = '' OR vciudad IS NULL OR vciudad = '' OR vcolon_pobla IS NULL OR vcolon_pobla = '' THEN
			IF ptipoproducto = 'CRV' THEN
				SELECT LIMIT 1 cod_postal,delegacion,ciudad,colonia INTO vcp,vdeleg_munic,vciudad,vcolon_pobla 
				  FROM bdiburo:br_burofisicas_describe 
				 WHERE num_credito = vnum_cuenta;
			ELSE
				SELECT LIMIT 1 cod_postal,delegacion,ciudad,colonia INTO vcp,vdeleg_munic,vciudad,vcolon_pobla 
				  FROM bdiburo:br_burofisicas_describe_cnr 
				 WHERE num_credito = vnum_cuenta;
			END IF;
		END IF; LET vpaso = 9;

		IF TRIM(vapellido_m) = '' OR vapellido_m IS NULL THEN
			LET vapellido_m = "NO PROPORCIONADO";
		END IF; LET vpaso = 10;

		IF LENGTH(TRIM(vdireccion)) > 80 THEN
			LET vdireccion1 = vdireccion;
			LET vdireccion2 = SUBSTR(vdireccion,81,80);
		ELSE
			LET vdireccion1 = TRIM(vdireccion);
		END IF; LET vpaso = 11;

		BEGIN WORK; 
			INSERT INTO "informix".br_arch_vartdc_proc (numero_cuenta, apellido_paterno, apellido_materno, primer_nombre, segundo_nombre,
				fecha_nacimiento, rfc, direccion1, direccion2, colonia_poblacion,
				delegacion_municipio, ciudad, estado, cp, tipo_contrato, tipo_producto, fecha_proceso)
			VALUES (vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre,
				vfecha_nac, vrfc, vdireccion1, vdireccion2, vcolon_pobla,
				vdeleg_munic, vciudad, vestado, vcp, cTipoContrato, cTipoProducto, vfecha_proc);

		COMMIT WORK; LET vpaso = 12;

		LET vnum_cuenta, vapellido_p, vapellido_m, vp_nombre, vs_nombre = "", "", "", "", "";
		LET vfecha_nac, vrfc, vdireccion, vcolon_pobla, vdeleg_munic = DATE(1), "", "", "", "";
		LET vciudad, vestado, vcp, vdireccion1, vdireccion2 = "", "", "", "", "";
		LET cTipoContrato, cTipoProducto, vnombrecalle, vnumeroextcalle, vnumerointcalle = "", "", "", "", "";
	END FOREACH; LET vpaso = 13;
	
	IF ptipoproducto = 'CNR' THEN
		
		FOREACH WITH HOLD
			SELECT num_credito 
				INTO cnum_credito 
				FROM paso_reserva
				WHERE num_producto = '6400'
				BEGIN WORK;
					UPDATE "informix".br_arch_vartdc_proc SET tipo_contrato = 'PN' WHERE numero_cuenta = cnum_credito AND fecha_proceso = vfecha_proc;
				COMMIT WORK;
		END FOREACH;
	END IF;
	
	DROP TABLE paso_reserva;

    UPDATE statistics medium FOR TABLE "informix".br_arch_vartdc_proc;
	
	LET cnomarchivo1 = "Aux_" || vnom_archivo; LET vpaso = 14;

	--VALIDA SI EXISTE EL MISMO ARCHIVO Y LO BORRA
	LET cSql = 'if [ -f ' || TRIM(cruta) || TRIM(vnom_archivo) || ' ]; then nice nice -n -30 rm -f ' || TRIM(cruta) || TRIM(vnom_archivo) || '; fi';
	SYSTEM cSql;

	LET cSql = "";

	--SE INSERTE LAYOUT SOLICITADO EN EL ARCHIVO
	LET cSql = 'echo "numero_cuenta|apellido_paterno|apellido_materno|primer_nombre|segundo_nombre|fecha_nacimiento|rfc|direccion1|direccion2|colonia_poblacion|delegacion_municipio|ciudad|estado|cp|tipo_contrato|" >' || TRIM(cruta) || "querylayout.txt";
	SYSTEM (cSql); LET vpaso = 15;
	
	--SE PASA LAYOUT AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "sed 's/$//g' "|| TRIM(cruta) || "querylayout.txt >> " || TRIM(cruta) || vnom_archivo;
	SYSTEM TRIM(cSql); LET vpaso = 16;

	LET cSql1 = 'echo "' || "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;" || '" > ' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql1);

	--SE ARMA SCRIPT QUE CONTENDRA EL QUERY DE LA DESCARGA DE LA INFORMACION
	LET cSql1 = '';
	LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '">>' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql1); LET vpaso = 17;

	LET cSql2 = 'echo "' || "SELECT numero_cuenta, apellido_paterno, apellido_materno,primer_nombre, segundo_nombre," || '" >> ' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql2); LET vpaso = 18;

	LET cSql2 = "";
	LET cSql2 = 'echo "' || "fecha_nacimiento, rfc ,direccion1, direccion2, colonia_poblacion, delegacion_municipio," || '" >> ' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql2); LET vpaso = 19;

	LET cSql2 = "";
	LET cSql2 = 'echo "' || "ciudad, estado, cp, tipo_contrato" || '">>' || TRIM(cruta) || 'querycc.sql';
	SYSTEM TRIM(cSql2); LET vpaso = 20;
	
	LET cSql2 = "";
	LET cSql2 = 'echo "' || "FROM br_arch_vartdc_proc WHERE fecha_proceso = MDY(" ||MONTH(vfecha_proc)|| "," ||DAY(vfecha_proc)|| "," ||YEAR(vfecha_proc)|| ") AND tipo_producto = '" || ptipoproducto ||"';" || '">>' || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql2); LET vpaso = 21;
	
	--ASIGNACION DE PERMISO AL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql); LET vpaso = 22;

	--EJCUCION DEL ARCHIVO TEMPORAL QUE CONTIENE EL QUERY DE LA DESCARGA
	LET cSql = "";
	LET cSql = "dbaccess bdiburo " || TRIM(cruta) || "querycc.sql";
	SYSTEM TRIM(cSql); LET vpaso = 23;
	
	--SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "sed 's/$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || vnom_archivo;
	SYSTEM cSql; LET vpaso = 24;

	--ASIGNACION DE PERMISO AL ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo);
	SYSTEM cSql; LET vpaso = 25;

	--BORRADO DE ARCHIVOS TEMPORALES
	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || "querycc.sql";		
	SYSTEM TRIM(cSql); LET vpaso = 26;

	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || "querylayout.txt";
	SYSTEM TRIM(cSql); LET vpaso = 27;

	LET cSql = "";
	LET cSql = "rm " || TRIM(cruta) || TRIM(cnomarchivo1);
	SYSTEM TRIM(cSql); LET vpaso = 28;

	--SE COMPACTA ARCHIVO FINAL
	LET cSql = "";
	LET cSql = "gzip " || TRIM(cruta) || TRIM(vnom_archivo);
	SYSTEM cSql; LET vpaso = 29;

	--ASIGNACION DE PERMISO AL ARCHIVO COMPACTADO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(cruta) || TRIM(vnom_archivo)||".gz";
	SYSTEM cSql; LET vpaso = 30;
	
	IF ptipoproducto = 'CRV' AND vnum_arch = '01' THEN
		--MODIFICACION PARA INSERTAR CREDITO Y FECHA 
		LET cSql1 = '';
		LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cruta) || "descarga_rees.txt" ||'">>' || TRIM(cruta) || "descargacargaree.sql";
		SYSTEM TRIM(cSql1); 

		LET cSql2 = 'echo "' || "SELECT num_credito,fecha" || '" >> ' || TRIM(cruta) || "descargacargaree.sql";
		SYSTEM TRIM(cSql2);
		
		LET cSql2 = "";
		LET cSql2 = 'echo "' || "FROM sd_maecredcontcrd  WHERE fecha = MDY(" ||MONTH(vfecha_proc)|| "," ||DAY(vfecha_proc)|| "," ||YEAR(vfecha_proc)|| ") AND num_producto = '6011';" || '">>' || TRIM(cruta) || "descargacargaree.sql";
		SYSTEM TRIM(cSql2); LET vpaso = 31;
		
		--SE ENVIA EL NOMBRE DEL ARCHIVO A CARGAR AL SCRIPT
		LET cSql = "";
		LET cSql = "dbaccess bdicred " || TRIM(cruta) || "descargacargaree.sql";
		SYSTEM TRIM(cSql); LET vpaso = 32; 

		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cSql = "";
		LET cSql = 'dbload -d bdiburo -c ' || TRIM(cruta) || 'cargaarch_rees.sql -l ' || TRIM(cruta) || 'cargaarch_rees.log -n 1000 -k';
		SYSTEM TRIM(cSql);
		
		LET cSql = 'rm ' || TRIM(cruta) || 'descarga_rees.txt';
		SYSTEM TRIM(cSql);
		LET vpaso = 33;
		
		LET cSql = 'rm ' || TRIM(cruta) || 'descargacargaree.sql';
		SYSTEM TRIM(cSql);
		LET vpaso = 34;
	--TERMINO DE MODIFICACION
	END IF;
	
	LET vnum_arch = vnum_arch::INTEGER + 1;

	LET vnum_arch = LPAD(TRIM(vnum_arch),2,"0");

	BEGIN WORK;
		IF ptipoproducto = 'CRV' THEN
		--ACTUALIZACION DEL VALOR NUMERICO DEL ARCHIVO
			UPDATE "informix".br_param
			SET valor = vnum_arch
			WHERE cod_param = 143;

		--ACTUALIZACION PARA EL VALOR DE LA FECHA DEL ARCHIVO
			UPDATE "informix".br_param
			SET valor = vfec_com
			WHERE cod_param = 144;
		ELSE
		--ACTUALIZACION DEL VALOR NUMERICO DEL ARCHIVO
			UPDATE "informix".br_param
			SET valor = vnum_arch
			WHERE cod_param = 148;

		--ACTUALIZACION PARA EL VALOR DE LA FECHA DEL ARCHIVO
			UPDATE "informix".br_param
			SET valor = vfec_com
			WHERE cod_param = 149;
		END IF;
	COMMIT WORK; LET vpaso = 35;

    LET cMensaje = "PROCESO EXITOSO.";
																   
    RETURN cCod_ret, TRIM(cMensaje);
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DESCARGA DEL ARCHIVO VARTDC PARA CC.',
'AUTOR: Carlos Valenzuela',
'CREACION: 04/10/2016',
'BD: bdiburo';

create procedure "informix".sp_val_conciliacion_cnr()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE v_fechaproceso       DATE;
DEFINE v_primero_mes        DATE;
DEFINE v_fechaproceso_ant    DATE;
DEFINE vano                 CHAR(04);
DEFINE vmes                 CHAR(02);
DEFINE vdia                 CHAR(02);
DEFINE vfecha_reporte        CHAR(08); 

DEFINE cnum_credito		CHAR(12);
DEFINE cNumProducto         CHAR(04);
DEFINE v_tipocred           CHAR(02);
DEFINE vclave_obs           CHAR(02);
DEFINE vstatus_cred         CHAR(02);
DEFINE cNumProducto_app     CHAR(04);
DEFINE vclave_obs_app       CHAR(02);
DEFINE vstatus_cred_app     CHAR(02);
DEFINE cNumProducto_d     CHAR(04);
DEFINE vclave_obs_d       CHAR(02);
DEFINE vstatus_cred_d     CHAR(02);


DEFINE vsaldo_actual_en      DECIMAL(18,2);
DEFINE vsaldo_venc_en        DECIMAL(18,2);
DEFINE vmonto_insoluto_en    DECIMAL(18,2);
DEFINE vtotal_en             integer;
DEFINE vsaldo_actual_ex      DECIMAL(18,2);
DEFINE vsaldo_venc_ex        DECIMAL(18,2);
DEFINE vmonto_insoluto_ex    DECIMAL(18,2);
DEFINE vtotal_ex             integer;
DEFINE vsaldo_actual_app      DECIMAL(18,2);
DEFINE vsaldo_venc_app        DECIMAL(18,2);
DEFINE vsaldo_venc_app_cv     DECIMAL(18,2);
DEFINE vmonto_insoluto_app    DECIMAL(18,2);
DEFINE vtotal_app             integer;
DEFINE vcred_diferencia		integer;	
DEFINE vsdo_actual_dif     DECIMAL(18,2);
DEFINE vsdo_vencido_dif    DECIMAL(18,2);
DEFINE vsdo_insoluto_dif    DECIMAL(18,2);
DEFINE v_valfecha            SMALLINT;
DEFINE v_valcinta            SMALLINT;

DEFINE vflag                 CHAR(1);
DEFINE b_diferencia		     CHAR(1); 

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET v_valfecha           = 0;
LET v_valcinta           = 0;
LET vtotal_en  = 0;
LET vtotal_ex  = 0;
LET vtotal_app  = 0;
LET vcred_diferencia = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;


--SET DEBUG FILE TO "sp_val_conciliacion_cnr.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

select pri_dia_mes -1, pri_dia_mes -  1 units month
into v_fechaproceso,v_primero_mes
from bdicred:sd_fechas
where empresa = '001';

--temporal para pruebas
   --let v_fechaproceso = mdy('07','31','2021');
   --let v_primero_mes  = mdy('07','01','2021');
--temporal para pruebas

let v_fechaproceso_ant = v_primero_mes - 1;

SELECT valor 
INTO vflag
FROM bdiburo:br_param
WHERE cod_param = 132;


   let vano = year(v_fechaproceso);
   let vmes = lpad(month(v_fechaproceso),2,"0");
   let vdia = lpad(day(v_fechaproceso),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

--Valida existencia
select count(*) INTO v_valcinta from  br_concil_consolidado_cnr where fecha_proceso = v_fechaproceso;

IF v_valcinta > 0 and vflag = 0 then
  LET cCodRet     = "007777";
  LET cMensajeRet = "CONCILIACIÓN CNR YA PROCESADA "||vfecha_reporte;
  RETURN cCodRet, cMensajeRet; 

ELSE

 IF  vflag = 8 then
  DROP TABLE tot_creditos_cintas_cnr;
  DELETE br_concil_consolidado_cnr where fecha_proceso = v_fechaproceso;
  DELETE br_fechas_Concil  where fecha_proceso = v_fechaproceso and num_producto in ('6300','6400');
  UPDATE bdiburo:br_param  SET valor = '0'  WHERE cod_param = 132;
  LET vflag = '0';
 END IF;

IF vflag = 0 then
--Informcación Cinta
SELECT num_producto, clave_obs, status_cred,NVL(count(*),0) total, 'EN' ETIQUETA,
NVL(sum(saldo_actual),0) saldo_actual,  NVL(sum(saldo_venc),0) saldo_venc,  NVL(sum(monto_insoluto),0)  monto_insoluto
FROM bdiburo:br_burofisicas_describe_cnr 
WHERE fecha_reporte = vfecha_reporte
and num_producto in ('6300','6400')
GROUP BY  1,2,3
union all
SELECT num_producto, clave_obs, status_cred,NVL(count(*),0) total, 'EX' ETIQUETA,
NVL(sum(saldo_actual),0) saldo_actual,  NVL(sum(saldo_venc),0) saldo_venc,  NVL(sum(monto_insoluto),0)  monto_insoluto
FROM bdiburo:br_burofisicas_concilia_cnr 
where fecha_cinta = v_fechaproceso
and motivo = 'CSS'
and num_producto in ('6300','6400')
GROUP BY  1,2,3
INTO temp tot_creditos_cintas_cnr WITH NO LOG;

  begin;
  UPDATE bdiburo:br_param
  SET valor = '8'
  WHERE cod_param = 132;
  commit;

 foreach with hold

    select a.num_producto,a.clave_obs,a.status_cred,NVL(a.saldo_actual,0) sa_Env,NVL(a.saldo_venc,0)sv_env,NVL(a.monto_insoluto,0) mi_env
           ,NVL(b.saldo_actual,0) sa_Exc, NVL(b.saldo_venc,0) sv_exc,NVL(b.monto_insoluto,0) mi_exc,NVL(a.total,0) cred_env, NVL(b.total,0) cred_exc
      INTO cNumProducto,vclave_obs,vstatus_cred,vsaldo_actual_en,vsaldo_venc_en,vmonto_insoluto_en,
            vsaldo_actual_ex,vsaldo_venc_ex,vmonto_insoluto_ex,vtotal_en, vtotal_ex
      from tot_creditos_cintas_cnr a left join tot_creditos_cintas_cnr b
        on a.num_producto = b.num_producto and a.clave_obs = b.clave_obs
        and a.status_Cred = b.status_Cred
        and a.etiqueta <> b.etiqueta
      where a.Etiqueta = 'EN'

    --IF vclave_obs in ('','EL','PC') and vstatus_cred in ('AA','BA','BT','VP') THEN
	IF vclave_obs in ('','EL','PC') and vstatus_cred in ('AA','BA','BT','VP','E1','E2','E3') THEN   -- IFRS
      LET v_tipocred  = 'AC';
    ELIF vclave_obs = 'CC' and vstatus_cred = 'FF' THEN
      LET v_tipocred  = 'CA';
    ELIF vclave_obs = 'CV' and vstatus_cred = 'CV' THEN
      LET v_tipocred  = 'VE';
    ELSE
      LET v_tipocred  = 'XX';
    END IF;
   
   begin;
    INSERT INTO br_concil_consolidado_cnr (fecha_proceso,num_producto,tipo_cred,clave_obs,status_cred,sdo_actual_sicenv, sdo_vencido_sicenv,sdo_insoluto_sicenv,
                                       sdo_actual_sicexc, sdo_vencido_sicexc,sdo_insoluto_sicexc,cred_enviados,cred_excluidos)
	VALUES (v_fechaproceso,cNumProducto,v_tipocred,vclave_obs,vstatus_cred,vsaldo_actual_en,vsaldo_venc_en,vmonto_insoluto_en,
            vsaldo_actual_ex,vsaldo_venc_ex,vmonto_insoluto_ex,vtotal_en, vtotal_ex);
   commit;				

    select count(*) INTO v_valfecha
    from bdiburo:br_fechas_Concil
    where fecha_proceso = v_fechaproceso
    and num_producto = cNumProducto;

    IF v_valfecha = 0 then
	   begin;
        INSERT INTO br_fechas_concil (empresa,fecha_proceso,num_producto)
        VALUES ('001',v_fechaproceso,cNumProducto);
	   commit;	
    END IF;

 end foreach

 begin;
  UPDATE bdiburo:br_param
  SET valor = '1'
  WHERE cod_param = 132;
 commit;

LET vflag = '1';
DROP TABLE tot_creditos_cintas_cnr;
END IF;

--Información Operativa
IF vflag = 1 then
  --Creditos a plazo - Activas
select a.num_producto,a.num_credito, a.status_cred ,nvl(dias_atraso,0) vdiasatraso, NVL(monto_vencido + mto_venc_trasp,0) cMtoVen
FROM bdicred:sd_maecredcontcrd a 
INNER JOIN bdicred:sd_indicador_cred_crd b ON a.empresa = b.empresa and a.num_credito = b.num_credito
INNER JOIN bdicred:sd_maesdoscontcrd c ON a.empresa = c.empresa and a.num_credito = c.num_credito and a.fecha = c.fecha
WHERE a.fecha =   v_fechaproceso
AND a.empresa = '001'
AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr where fecha_proceso =  v_fechaproceso)
AND a.num_producto in ('6300','6400')
--Suc para pruebas
	--AND (sucursal in (SELECT sucursal from bdiburo:suc_pro where des_suc = 'CNR'))-- OR a.num_credito  in (SELECT num_credito from creditos_err))
into temp crds_central_cnr1 WITH NO LOG; 

SELECT a.*,b.status_cred  vstatus_credAnt,
CASE WHEN (vdiasatraso >=  1 ) THEN 'PC'
--WHEN b.status_cred IN ('BT','BA') AND a.status_cred ='AA' THEN 'EL'
 WHEN (b.status_cred IN ('BT','BA','E1','E2','E3') AND NVL(c.monto_vencido + c.mto_venc_trasp,0) > 0) AND (a.status_cred  IN ('AA','E1') AND cMtoVen = 0) THEN 'EL'  --IFRS MACF
ELSE '' END clave_obs
FROM crds_central_cnr1 a 
LEFT JOIN  bdicred:sd_maecredcontcrd b ON empresa = '001' AND a.num_credito = b.num_credito  AND b.fecha = v_fechaproceso_ant
INNER JOIN bdicred:sd_maesdoscontcrd c ON b.empresa = c.empresa and b.num_credito = c.num_credito and b.fecha = c.fecha
into temp crds_central_cnr  WITH NO LOG; 

DROP TABLE crds_central_cnr1;

   foreach with hold
SELECT num_producto, status_cred,clave_obs, count(b.num_credito) total,
 sum(case 
     when ((nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0))+ 
case
when nvl(sdo_no_exig,0) is null then 0
when nvl(sdo_no_exig,0) <= 0 then 0 
else nvl(sdo_no_exig,0) end) >0 
      and (nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0)+ 
case
when nvl(sdo_no_exig,0) is null then 0
when nvl(sdo_no_exig,0) <= 0 then 0 
else nvl(sdo_no_exig,0) end) <1 then 1
     else round ((nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0))+ 
case
when nvl(sdo_no_exig,0) is null then 0
when nvl(sdo_no_exig,0) <= 0 then 0 
else nvl(sdo_no_exig,0) end
)end) saldo_actual,
 sum(case 
     when (nvl(monto_vencido + mto_venc_trasp,0)) >0 
      and (nvl(monto_vencido + mto_venc_trasp,0)) <1 then 1
     else round (nvl(monto_vencido + mto_venc_trasp,0))end)
saldo_vencido,
 sum(case 
     when (nvl(sdo_cap_insoluto,0)) >0 
      and (nvl(sdo_cap_insoluto,0)) <1 then 1
     else round (nvl(sdo_cap_insoluto,0))end)
saldo_insoluto
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
from bdicred:sd_maesdoscontcrd a inner join crds_central_cnr  b
on  a.num_credito = b.num_credito
where  a.fecha =  v_fechaproceso --mdy('02','28','2014')
and a.num_credito >= ''
and b.num_producto  in ('6300','6400')
group by 1,2,3

   begin;
    UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = vsaldo_actual_app,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = vmonto_insoluto_app,
	cred_central = vtotal_app
	WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_app
      and status_cred = vstatus_cred_app
      and clave_obs = vclave_obs_app
      and (sdo_actual_app is null);
   commit;	  
   end foreach  

  begin;
  UPDATE bdiburo:br_param
  SET valor = '2'
  WHERE cod_param = 132;
 commit;

LET vflag = '2';
DROP TABLE crds_central_cnr;
END IF;

IF vflag = 2 then    

 --Créditos a Plazo - Canceladas
foreach with hold  
select num_producto, a.status_cred,'CC' clave_obs,count(a.NUM_CREDITO),  0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto	
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maecredanexocrd b
on b.empresa = '001' and a.num_credito = b.num_credito  and fecha_proceso  between  v_primero_mes and v_fechaproceso
where a.empresa = '001'
and a.num_Credito >= ''
and num_producto  in ('6300','6400')
and status_cred = 'FF'
--Suc para pruebas
	--AND (sucursal IN (SELECT sucursal FROM bdiburo:suc_pro WHERE des_suc = 'CNR'))-- OR a.num_credito  in (SELECT num_credito FROM creditos_err))
group by 1,2

   begin;	  
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = vsaldo_actual_app,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = vmonto_insoluto_app,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_app
      and status_cred = vstatus_cred_app
      and clave_obs = vclave_obs_app
      and (sdo_actual_app is null);
   commit;	  

  end foreach 
  
 begin;
  UPDATE bdiburo:br_param
  SET valor = '3'
  WHERE cod_param = 132;
 commit;

LET vflag = '3';
END IF;

IF vflag = 3 then
--Cambio Redondeo saldos vencidos IPCB 23 enero 2015 PP 
 --Creditos a Plazo- Prestamo Personal- Vendidas /separación de PP y CN enero2015
select a.num_credito,num_producto, 
case 
    when (nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0))  between 0.0000001 and 1 then 1 
    else 
    nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0)
    end saldo_vencido
--INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maesdoscrd_vendida b
--on fecha  between mdy('12','01','2014') and  mdy('12','31','2014') 
on fecha  between v_primero_mes and v_fechaproceso
and a.empresa = b.empresa and a.num_credito = b.num_credito
where a.empresa = '001'
and a.num_credito >= ''
and num_producto  in ('6300')

into temp creds_cv with no log;

LET vtotal_app = 0;
LET vsaldo_venc_app = 0;

 foreach with hold 		
   select  num_credito,saldo_vencido
      into cnum_credito,vsaldo_venc_app_cv
      from creds_cv

   LET vtotal_app = vtotal_app+1;	
   LET vsaldo_venc_app_cv = round(vsaldo_venc_app_cv,0); 	  
   LET vsaldo_venc_app = vsaldo_venc_app +vsaldo_venc_app_cv;

   LET vsaldo_venc_app_cv = 0;
 end foreach  

   begin;	
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = 0,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = 0,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = '6300'
      and status_cred = 'CV'
      and clave_obs = 'CV'
      and (sdo_actual_app is null);
   commit; 
 --Cambio Redondeo saldos vencidos IPCB 23 enero 2015

 begin;
  UPDATE bdiburo:br_param
  SET valor = '4'
  WHERE cod_param = 132;
 commit;

drop table creds_cv;

LET vflag = '4';
END IF;

IF vflag = 4 then
  --Creditos a Plazo-Credinomina - Vendidas  /separación de PP y CN enero2015
select a.num_credito,num_producto, 
case 
    when (nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0))  between 0.0000001 and 1 then 1 
    else 
    nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0)
    end saldo_vencido
--INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maesdoscrd_vendida b
--on fecha  between mdy('12','01','2014') and  mdy('12','31','2014') 
on fecha  between v_primero_mes and v_fechaproceso
and a.empresa = b.empresa and a.num_credito = b.num_credito
where a.empresa = '001'
and a.num_credito >= ''
and num_producto  in ('6400')

into temp creds_cv with no log;

LET vtotal_app = 0;
LET vsaldo_venc_app = 0;

 foreach with hold 		
   select  num_credito,saldo_vencido
      into cnum_credito,vsaldo_venc_app_cv
      from creds_cv

   LET vtotal_app = vtotal_app+1;	
   LET vsaldo_venc_app_cv = round(vsaldo_venc_app_cv,0); 	  
   LET vsaldo_venc_app = vsaldo_venc_app +vsaldo_venc_app_cv;

   LET vsaldo_venc_app_cv = 0;
 end foreach  

   begin;	
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = 0,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = 0,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = '6400'
      and status_cred = 'CV'
      and clave_obs = 'CV'
      and (sdo_actual_app is null);
   commit; 

 begin;
  UPDATE bdiburo:br_param
  SET valor = '5'
  WHERE cod_param = 132;
 commit;

LET vflag = '5';
END IF;
  
IF vflag = 5 then
 --Cálculo de diferencias.
 foreach with hold 
 
 	select num_producto,status_cred,clave_obs,
     NVL((sdo_actual_sicenv + sdo_actual_sicexc) - sdo_actual_app,0),
	  NVL ((sdo_vencido_sicenv + sdo_vencido_sicexc) - sdo_vencido_app,0),
	   NVL((sdo_insoluto_sicenv + sdo_insoluto_sicexc) - sdo_insoluto_app ,0),
	   NVL((cred_enviados + cred_excluidos) - cred_central ,0)
	INTO cNumProducto_d,vstatus_cred_d,vclave_obs_d,vsdo_actual_dif,vsdo_vencido_dif,vsdo_insoluto_dif,vcred_diferencia 
    FROM br_concil_consolidado_cnr	
	where fecha_proceso = v_fechaproceso
	
	IF vsdo_actual_dif < 0 then
	LET vsdo_actual_dif = vsdo_actual_dif * (-1);
	end if;
	
	IF vsdo_vencido_dif < 0 then
	LET vsdo_vencido_dif = vsdo_vencido_dif * (-1);
	end if;
	
	IF vsdo_insoluto_dif < 0 then
	LET vsdo_insoluto_dif = vsdo_insoluto_dif * (-1);
	end if;
	
	IF vcred_diferencia < 0 then
	LET vcred_diferencia = vcred_diferencia * (-1);
	end if;

   begin;	
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_dif = vsdo_actual_dif,
	sdo_vencido_dif = vsdo_vencido_dif,
	sdo_insoluto_dif  = vsdo_insoluto_dif,
	cred_diferencia =  vcred_diferencia
	WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_d
      and status_cred = vstatus_cred_d
      and clave_obs = vclave_obs_d
      and sdo_actual_dif is null ;
   commit;	
 
   select diferencia
   Into b_diferencia
   from  br_fechas_concil
   where fecha_proceso = v_fechaproceso
   and num_producto = cNumProducto_d;
   
   If (vsdo_actual_dif > 0 or vsdo_vencido_dif > 0 or vsdo_insoluto_dif  > 0 or vcred_diferencia >0) and b_diferencia is null then
    begin;
	update bdiburo:br_fechas_concil set diferencia = 'D'
    where fecha_proceso = v_fechaproceso
    and num_producto = cNumProducto_d;
	commit;
   ELIF (vsdo_actual_dif = 0 and vsdo_vencido_dif = 0 and vsdo_insoluto_dif  = 0 and vcred_diferencia =0) then
    begin;
	update bdiburo:br_fechas_concil set diferencia = ''
    where fecha_proceso = v_fechaproceso
    and num_producto = cNumProducto_d;
	commit;
   End if;
  If (vsdo_actual_dif > 0 or vsdo_vencido_dif > 0 or vsdo_insoluto_dif  > 0 or vcred_diferencia >0) then
    begin;	
	UPDATE br_concil_consolidado_cnr set b_difprocesa ='D'       
	WHERE fecha_proceso = v_fechaproceso
	and num_producto = cNumProducto_d
	and status_cred = vstatus_cred_d
	and clave_obs = vclave_obs_d;
	commit;
   ELSE
    begin;
	UPDATE br_concil_consolidado_cnr set b_difprocesa =''       
	WHERE fecha_proceso = v_fechaproceso
	and num_producto = cNumProducto_d
	and status_cred = vstatus_cred_d
	and clave_obs = vclave_obs_d;
	commit;
   End If
   
 end foreach 	  

 begin;
  UPDATE bdiburo:br_param
  SET valor = '0'
  WHERE cod_param = 132;
 commit;

END IF;

LET cCodRet     = "000000";
LET cMensajeRet = "CONCILIACIÓN CNR "||vfecha_reporte|| " Ok.";

	RETURN cCodRet, cMensajeRet; 
END IF;
END;
END PROCEDURE;