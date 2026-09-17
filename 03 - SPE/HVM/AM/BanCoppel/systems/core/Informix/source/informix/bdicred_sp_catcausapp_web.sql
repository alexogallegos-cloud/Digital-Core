CREATE PROCEDURE "informix".sp_catcausapp_web(pSecuencia INTEGER)
	RETURNING 	CHAR(5) 	AS cCodRet,
				CHAR(11)	AS cID,
	            CHAR(1)		AS cCausa,
	            CHAR(25)	AS cDescripcion;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cID					CHAR(11);
DEFINE cCausa 				CHAR(1);
DEFINE cDescripcion 		CHAR(25);

LET sql_err					= 0;
LET cCodRet 				= "00000";
LET cID						= "";
LET cCausa 					= "";
LET cDescripcion 			= "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_catcausapp.out";
	--TRACE ON;

	FOREACH 
		SELECT SKIP pSecuencia 
				id_causa, causa, descripcion
			INTO
				cID, cCausa, cDescripcion
		FROM "informix".catcausapp
		ORDER BY id_causa ASC
		
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'') WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "00002";
	END IF;

	IF cCodRet <> "00000" THEN
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 Adrian Eduardo Lizarraga Cazares',
'BD: bdicred',
'Fecha: 2019-11-26',
'Descripcion: Se genera procedimiento almacenado para consultar los motivos de cancelacion para las tarjetas Priority Pass',
'SolicitoÂ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_consulta_accesos_ppass_web(pNumTarjeta VARCHAR(20), pMesAcceso VARCHAR(7), pSecuencia INTEGER)
	
	RETURNING CHAR(5)  AS cCodRet,
			  CHAR(10) AS cFechaVisita,
			  CHAR(20) AS cNumTarjetaPPas,
			  CHAR(69) AS cPaisSalon,
			  CHAR(11) AS cTotalVisistasTi,
		      CHAR(11) AS cTotalVisitasAdic,
			  CHAR(11) AS cTotalvisitas,
			  CHAR(11) AS cNumVisitasSCost,
			  CHAR(11) AS cNumVisFact,
			  CHAR(25) AS dTotalAPagar;
	
	DEFINE sql_err 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cCategoria 			CHAR(1);
	DEFINE iAccGratis 			INTEGER;
	DEFINE cFechaVisita 		CHAR(10);
	DEFINE cNumTarjetaPPass 	CHAR(20);
	DEFINE cPaisSalon 			CHAR(69);
	DEFINE cTotalVisistasTi 	CHAR(11);
	DEFINE cTotalVisitasAdic	CHAR(11);
	DEFINE cTotalvisitas		CHAR(11);
	DEFINE cNumVisitasSCost 	CHAR(11);
	DEFINE cNumVisFact 			CHAR(11);
	DEFINE dTotalAPagar 		DECIMAL(18,4);
	DEFINE cCostoAcceso 		CHAR(3);

	LET sql_err				= 0;
	LET cCodRet 			= '00000';
	LET cCategoria 			= '';
	LET iAccGratis 			= 0;
	LET cFechaVisita 		= '';
	LET cNumTarjetaPPass 	= '';
	LET cPaisSalon 			= '';
	LET cTotalVisistasTi 	= '';
	LET cTotalVisitasAdic 	= '';
	LET cTotalvisitas 		= '';
	LET cNumVisitasSCost 	= '';
	LET cNumVisFact 		= '';
	LET dTotalAPagar 		= 0.0;
	LET cCostoAcceso 		= '';


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN		

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/sp_consulta_movimientos_ppass.out';
		--TRACE ON;
		
		SELECT FIRST 1 categoria 
		INTO cCategoria
		FROM "informix".sd_tarjeta_ppass
		WHERE numtarjeta_ppass = pNumTarjeta; 	

		SELECT acceso_gratis 
		INTO iAccGratis
		FROM "informix".catcategoriappass
		WHERE id_categoria = cCategoria;		
		
		IF  dbinfo("sqlca.sqlerrd2") = 0 THEN			
			LET cCodRet = '00003';
		ELSE
		
			SELECT valor 
			INTO cCostoAcceso
			FROM "informix".sd_param 
			WHERE cod_param = '074';
			
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN				
				LET cCodRet = '00004';				
			END IF;
		END IF;
		
		IF TRIM(pNumTarjeta) <> "" AND TRIM(pMesAcceso) <> "" THEN
			
			FOREACH
					SELECT SKIP pSecuencia
					TO_CHAR(A.fecha_visita, '%d/%m/%Y') AS fecha_visita,
					TO_CHAR(numtarjeta_ppass) AS num_tarjeta,
					TO_CHAR(id_pais_visita || '  ' || nombre_lounge) AS pais_salon, 
					TO_CHAR(A.totalpp_deslizada) AS vis_titular,
					TO_CHAR(A.total_invitados) AS vis_Adic,
					TO_CHAR(A.total_visitas) AS vis_total, 
					TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE iAccGratis END)) AS vi_sinc,
					TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END)) AS vi_fact, 
					TO_CHAR(((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END) * 
					NVL((SELECT precio_venta FROM bdinteg: "informix".si_histdiv WHERE fecha_tc = A.fecha_visita AND divisa = '02' 
					AND hora_tc = (SELECT MAX(hora_tc) FROM bdinteg: "informix".si_histdiv 
					WHERE fecha_tc = A.fecha_visita AND divisa = '02')), 0) * cCostoAcceso )) AS total_facturable
					
					INTO cFechaVisita, cNumTarjetaPPass, cPaisSalon, cTotalVisistasTi, cTotalVisitasAdic,
					cTotalvisitas, cNumVisitasSCost, cNumVisFact, dTotalAPagar
					
					FROM "informix".sd_movmes_ppass AS A 
					WHERE A.numtarjeta_ppass = pNumTarjeta 
					AND MONTH(A.fecha_visita) = SUBSTRB(pMesAcceso, 1, 2) AND YEAR(A.fecha_visita) = SUBSTRB(pMesAcceso, 4, 4)
					ORDER BY A.fecha_visita ASC
				
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'') WITH RESUME;

			END FOREACH;

		ELSE 
			LET cCodRet = '00001';
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '000000' THEN
			LET cCodRet = "00002";
		END IF;

		IF TRIM(cCodRet) <> "00000" THEN
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
		END IF;


	END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-18',
'DescripciÃ³n: Se genera procedimiento almacenado para consultar las visitas que el Cliente ha realizado con su tarjeta Priority Pass en un plazo',
'			  no mayor a 12 meses y con un rango de bÃºsqueda de 32 dÃ­as',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_valiexisttarjcctdebcred_web(pEmpresa CHAR(3), pRFC CHAR(13))

RETURNING CHAR(5), CHAR(1);

   DEFINE cNumCte      VARCHAR(20);
   DEFINE cNumTarjeta  VARCHAR(20);
   DEFINE cTipoCta     CHAR(1);
   DEFINE v_codret     CHAR(5);
   DEFINE sqlerr       INTEGER; 
   
   LET v_codret     = "00000";
   LET sqlerr       = 0;
   LET cNumCte      = "0";
   LET cNumTarjeta  = "0";
   LET cTipoCta     = "";
   
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   BEGIN
	  ON EXCEPTION
		  SET sqlerr
		  LET v_codret = sqlerr;
		  RETURN v_codret, cTipoCta;
	  END EXCEPTION;
	   --SET DEBUG FILE TO  '/home/sysifx/Oscar/sp_valiexisttarjcctdebcred_web.out';
       --TRACE ON;
	 IF TRIM(pRFC) = '' OR pRFC IS NULL THEN
		LET v_codret = '00002';
		RETURN v_codret, cTipoCta;
	 END IF
	
	SELECT numcte INTO cNumCte FROM bdinteg:"informix".si_cliente WHERE rfc = pRFC AND empresa = pEmpresa;
	
	IF TRIM(cNumCte) <> '' AND cNumCte IS NOT NULL THEN
			
		SELECT LIMIT 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		WHERE numcte = cNumCte
		AND status_tar = 'A'; -->> Credito
		
		IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
			LET cTipoCta = "C"; 
		ELSE
			SELECT LIMIT 1 num_tarjeta INTO cNumTarjeta FROM bdicheq:"informix".sc_tarjeta 
			WHERE numcte = cNumCte
			AND status_tar = 'A'; -->> Debito
			
			IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
				LET cTipoCta = "D";
			ELSE
				LET v_codret = '00001';
			END IF
		END IF;
	ELSE
		LET v_codret = '00001';
    END IF;
    RETURN v_codret, cTipoCta;
   END;
END PROCEDURE

DOCUMENT
"Spl para saber si el cliente tiene tarjetas activas de credito o debito ",
"obtener la fecha de fechrero por ejemplo",
"base de datos: bdicred",
"AUTOR : Oscar Marquez 98681011",
"FECHA : 25/09/2019";

CREATE PROCEDURE "informix".asigna_numsol_web(o_empresa CHAR(3), o_num_producto CHAR(4), o_numcte CHAR(20))

RETURNING CHAR(5), CHAR(20);
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificion: Se modifica el sp para que calcule el siguiente num de solicitud 
--             de la tarjeta de credito Coppel".
-- Fecha de modificaciÃ³n: 07-01-2009
-- Proyecto: Caja Unica.
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se modifica para que asigne un consecutivo de solicitud para el 
--                producto PrÃ©stamo Personal.
--Fecha de modificaciÃ³n: 09-09-2009
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se modifica para parametrizar las consultas que se realizan
--              para generar el nÃºmero de solicitud correspondiente al producto 
--              recibido como parÃ¡metro.
--Fecha de modificaciÃ³n: 03-11-2009
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se renombra para que se unifique con el spl productivo.
--		     Se tomÃ³ el spl asigna_numsol_cjunk versiÃ³n que se
--		     tomÃ³ para alta Ãºnica, misma que ahora reemplazarÃ¡
--		     al spl que actualmente existe en producciÃ³n.
--Fecha de modificaciÃ³n: 05-01-2010
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------

-- DEFINICION DE VARIABLES
DEFINE vsqlerr INTEGER;
DEFINE vcod_ret CHAR(5);
DEFINE vnum_solicitud CHAR(20);
DEFINE vcuantas SMALLINT;

-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET vcod_ret = "00000";
LET vnum_solicitud ="???????????????";
LET vcuantas = 0;

BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET vcod_ret=vsqlerr;
		  RETURN vcod_ret,vnum_solicitud;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
-- *********** INICIA PROCESO DE ASIGNACION ******************
	
	SELECT COUNT(*) INTO vcuantas FROM bdisolic:ss_solicitudes
	 WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	IF vcuantas > 0 THEN
		LET vcod_ret = "00500";
		RETURN vcod_ret, vnum_solicitud;
	END IF
	
  	CREATE TEMP TABLE signumero
  		(numero CHAR(20));

	INSERT INTO signumero
	SELECT num_credito FROM bdicred:sd_maecred
	WHERE numcte = o_numcte
	   AND num_producto = o_num_producto;

	INSERT INTO signumero
	SELECT num_solicitud FROM bdisolic:ss_solicitudes
	WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	SELECT MAX(numero) INTO vnum_solicitud
	  FROM signumero;

	IF vnum_solicitud IS NULL THEN
		LET vnum_solicitud = "000";
		LET vnum_solicitud = TRIM(o_numcte) || TRIM(o_num_producto) || 
			             vnum_solicitud;
	ELSE
		LET vnum_solicitud = SUBSTR(vnum_solicitud, -3) + 1;
		LET vnum_solicitud = TRIM(o_numcte) || TRIM(o_num_producto) || 
			             vnum_solicitud;
	END IF

END

	RETURN vcod_ret, vnum_solicitud;

END PROCEDURE;