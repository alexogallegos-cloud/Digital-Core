CREATE PROCEDURE "informix".sp_monitor_numctemovil()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret            CHAR(5);
DEFINE vcodretdet         CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE sid                INTEGER;
DEFINE snumcte            CHAR(20);
DEFINE sfolio             CHAR(12);
DEFINE sstatus_valua      INTEGER;
DEFINE sfecha_insert      DATE;
DEFINE vt_status_valua    INTEGER;
DEFINE iexiste_imagen0602 INTEGER;
DEFINE iexiste_imagen0601 INTEGER;
DEFINE iexiste_imagen0600 INTEGER;
DEFINE iexiste_imagen0001 INTEGER;
DEFINE IfirmaCop		  INT;
DEFINE IfirmaBan		  INT;
DEFINE IBuro     		  INT;
--Valida numero cliente
DEFINE svt_empresa        CHAR(3);
DEFINE svt_sucursal       CHAR(4);
DEFINE sejecutivo         CHAR(8);
DEFINE sAP_paterno        CHAR(26);
DEFINE sAP_materno        CHAR(26);
DEFINE sAP_nombre1        CHAR(26);
DEFINE sAP_nombre2        CHAR(26);
DEFINE srfc               CHAR(13);
DEFINE snumcte_coppel     CHAR(20);
DEFINE sAP_fecha_nac      CHAR(10);
DEFINE svt_dia            CHAR(2);
DEFINE svt_mes            CHAR(2);
DEFINE svt_year           CHAR(4);
DEFINE scve_elector       CHAR(18);
DEFINE sedo_civil         CHAR(1);
DEFINE sactividad         CHAR(2);
DEFINE ssexo              CHAR(1);
DEFINE scurp              CHAR(18);
DEFINE socr               CHAR(13);
DEFINE semail             CHAR(100);
DEFINE sescolaridad       CHAR(2);
DEFINE stipo_residencia   CHAR(1);
DEFINE spers_domicilio    CHAR(2);
DEFINE sRetCod            CHAR(5);
DEFINE lenScve_elector    CHAR(18);
DEFINE subScve_elector    CHAR(2);
DEFINE iTotal 			  INTEGER;
DEFINE sAP_rfc            CHAR(13);
DEFINE svt_fecha_hoy      DATE;
DEFINE spais_nacimiento	  CHAR(3);
DEFINE svt_numcte         CHAR(20);

--Inicializacion de variables
LET vcodret              = '000';
LET vcodretdet           = "000";
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sfecha_insert        = "";
LET vt_status_valua      = 0;
LET iexiste_imagen0602   = 0;
LET iexiste_imagen0601   = 0;
LET iexiste_imagen0600   = 0;
LET iexiste_imagen0001   = 0;
LET IfirmaCop			 = 0;
LET IfirmaBan            = 0;
LET IBuro                = 0;
--Valida numero cliente
LET svt_empresa          = "001";
LET svt_sucursal         = "";
LET sejecutivo           = "";
LET sAP_paterno          = '';
LET sAP_materno          = '';
LET sAP_nombre1          = '';
LET sAP_nombre2          = '';
LET srfc                 = "";
LET snumcte_coppel       = "";
LET sAP_fecha_nac        = '';
LET svt_dia              = "";
LET svt_mes              = "";
LET svt_year             = "";
LET scve_elector         = "";
LET sedo_civil           = "";
LET sactividad           = "";
LET ssexo                = "";
LET scurp                = "";
LET socr                 = "";
LET semail               = "";
LET sescolaridad         = "";
LET stipo_residencia     = "";
LET spers_domicilio      = "";
LET sRetCod              = "";
LET lenScve_elector      = "";
LET subScve_elector      = "";
LET iTotal               = 0;
LET sAP_rfc              = '';
LET svt_fecha_hoy        = "";
LET spais_nacimiento     = "";
LET svt_numcte           = "";

--SET DEBUG FILE TO '/informix/VH/sp_monitor_numctemovil.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

BEGIN
 ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
		LET vcodret = iSqlErr;
		RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF vcodret != "000" THEN

    LET vcodret = "999";
    --RETURN vCodret;

 END IF;
 
 SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
 FROM bdinteg:si_fechas
 WHERE empresa = '001';

 ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH
	SELECT {+INDEX (bdinteg:si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert,firma_cc,firma_bc,firma_buro,
			ejecutivo,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,rfc,numcte_coppel,ap_fecha_nac,edo_civil,
			actividad,ap_sexo,curp,ocr,email,escolaridad,tipo_residencia,pais_nac
	INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert,IfirmaCop,IfirmaBan,IBuro,
			sejecutivo,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,srfc,snumcte_coppel,sAP_fecha_nac,sedo_civil,
			sactividad,ssexo,scurp,socr,semail,sescolaridad,stipo_residencia,spais_nacimiento
	FROM bdinteg:si_solicitud_movil
	WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
	AND bdinteg:si_solicitud_movil.status_valua = 0
	ORDER BY folio
	
	LET sAP_paterno      = TRIM(sAP_paterno);
	LET sAP_materno      = TRIM(sAP_materno);
	LET sAP_nombre1      = TRIM(sAP_nombre1);
	LET sAP_nombre2      = TRIM(sAP_nombre2);
	LET ssexo            = TRIM(ssexo);
	LET snumcte          = TRIM(snumcte);
	--Valida formato de la fecha de nacimiento
	LET svt_dia          = sAP_fecha_nac[1,2];
	LET svt_mes          = sAP_fecha_nac[4,5];
	LET svt_year         = sAP_fecha_nac[7,10];
	
	IF LENGTH(svt_year)<=2 THEN
		LET svt_year="19"||svt_year;
	END IF;

	IF ssexo="H" THEN
		LET ssexo="M";
	ELIF ssexo="M" THEN
		LET ssexo="F";
	END IF;
	
	FOREACH
		SELECT sucursal INTO svt_sucursal FROM si_usuario_movil WHERE ejecutivo = sejecutivo AND activo = "1"
	END FOREACH;

	IF svt_sucursal IS NULL OR svt_sucursal = "" THEN
		LET sRetCod = "00015";
		
		INSERT INTO si_valida_folio_detalle VALUES (sfolio,"nohayejecutivo",snumcte,sRetCod,svt_fecha_hoy);
		
		UPDATE si_solicitud_movil SET status_valua = 2 WHERE folio = sfolio;
		  
		CONTINUE FOREACH;
	END IF;
	
	LET sAP_fecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);
	
	CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecha_nac)
	RETURNING sRetCod, sAP_rfc;
	
	LET sAP_rfc = trim(sAP_rfc);

	IF sRetCod<>'00000' THEN
		INSERT INTO si_valida_folio_detalle VALUES (sfolio,'RFC',snumcte,sRetCod,svt_fecha_hoy);
		
		UPDATE si_solicitud_movil SET status_valua=2 WHERE folio = sfolio;
		
		CONTINUE FOREACH;
	END IF;
	
	UPDATE si_solicitud_movil SET ap_rfc=sAP_rfc WHERE folio=sfolio; 
	
	LET sRetCod = "000";
	
	IF snumcte IS NULL OR snumcte = "" THEN
		
		SELECT numcte INTO snumcte FROM si_cliente WHERE rfc = sAP_rfc;
		
		IF snumcte IS NULL OR snumcte = "" THEN
		
			CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_rfc,
						  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
						  sAP_fecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
						 sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
			RETURNING sRetCod,snumcte;
		
		END IF;
		
	END IF;
	
	IF (snumcte IS NULL) OR (snumcte = "")  THEN
		
		CONTINUE FOREACH;
		
	END IF;
	
	UPDATE si_solicitud_movil SET numcte=snumcte WHERE id=sid; 

	--Validacion en bdidigital@coppelimg_tcp:dg_expediente_img1
	LET IfirmaCop        = NVL(IfirmaCop,0);
	LET IfirmaBan        = NVL(IfirmaBan,0);
	LET IBuro            = NVL(IBuro,0);
	
	SELECT
		COUNT(*) INTO iexiste_imagen0001
	FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
	JOIN bdidigital@coppelimg_tcp:dg_expediente b 
		ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
	WHERE 
		a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0001';
	
	IF iexiste_imagen0001 = 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0001
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.cod_docto='0001';
	
		IF iexiste_imagen0001 = 0 THEN
			SELECT
				COUNT(*) INTO iexiste_imagen0001
			FROM bdidigital@coppelimg_tcp:dg_expediente_img2 a
			JOIN bdidigital@coppelimg_tcp:dg_expediente b 
				ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta AND a.secuencia = b.secuencia
			WHERE 
				a.cliente = snumcte AND a.cod_docto='0001';
			
			IF iexiste_imagen0001 = 0 THEN
				CONTINUE FOREACH;
			END IF;
		END IF;
	END IF;
	
	IF IfirmaCop > 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0600
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0600';
			
		IF iexiste_imagen0600 = 0 THEN
			CONTINUE FOREACH;
		END IF;
	END IF;
	
	IF IfirmaBan > 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0601
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0601';
			
		IF iexiste_imagen0601 = 0 THEN
			CONTINUE FOREACH;
		END IF;
	END IF;
	
	IF IBuro > 0 THEN
		SELECT
			COUNT(*) INTO iexiste_imagen0602
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1 a
		JOIN bdidigital@coppelimg_tcp:dg_expediente b 
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.fecha_alta = b.fecha_alta
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.fecha_alta = TODAY AND a.cod_docto='0602';
			
		IF iexiste_imagen0602 = 0 THEN
			CONTINUE FOREACH;
		END IF;
	END IF;
		
	--Ejecuta rutina de alta de solicitud por folio
	IF sfolio IS NOT NULL THEN

		CALL sp_ALTA_CTEMOVIL(sfolio)
		RETURNING vcodretdet,snumcte;

		IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

		   LET vt_status_valua = 0;

		   SELECT status_valua INTO vt_status_valua
		   FROM si_solicitud_movil
		   WHERE folio = sfolio;
	   
		   IF vt_status_valua = 1 THEN

			  UPDATE si_solicitud_movil
			  SET(status_valua)=(1)
			  WHERE folio = sfolio;
		   END IF;

		END IF;
		
	END IF;
			
		
		
 END FOREACH;

RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 11/03/2015",
"Version    : 1.2",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_valida_cel_repetido(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;
DEFINE iValidaDiasTu    INTEGER;
DEFINE sTelefonoAct CHAR(13);

LET sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;
LET iValidaDiasTu    = 0;
LET sTelefonoAct     = 0;

BEGIN
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LMendoza/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;  
    SET LOCK MODE TO WAIT 3;
	
	SELECT telefono INTO sTelefonoAct FROM bdinteg:"informix".si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel=2;
		IF (TRIM(sTelefonoAct) == TRIM(pNumCel)) THEN RETURN sCodRet, iCantRep;
			END IF;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel IN ('A','C') AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
	

		
	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;