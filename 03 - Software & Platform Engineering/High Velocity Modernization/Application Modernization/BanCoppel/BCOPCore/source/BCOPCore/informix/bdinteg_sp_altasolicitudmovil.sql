CREATE PROCEDURE "informix".sp_altasolicitudmovil()
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
DEFINE iNumCte			  CHAR(9);
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

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

--SET DEBUG FILE TO '/informix/jagl/sp_altasolicitudmovil/sp_altasolicitudmovil.out';
--TRACE ON;

BEGIN
 ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
		LET vcodret = iSqlErr;
		RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF TRIM(vcodret)!="000" THEN
    INSERT INTO "informix".si_valida_folio_detalle(folio, rutina, numcte, cod_ret, fecha)
        VALUES('','sp_altasolicitudmovil','',vcodret,current);
 END IF;

 SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
 FROM bdinteg:si_fechas
 WHERE empresa = '001';

 ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH WITH HOLD
	SELECT {+INDEX (bdinteg:si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert,firma_cc,firma_bc,firma_buro,
			ejecutivo,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,rfc,numcte_coppel,ap_fecha_nac,edo_civil,
			actividad,ap_sexo,curp,ocr,email,escolaridad,tipo_residencia,pais_nac
	INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert,IfirmaCop,IfirmaBan,IBuro,
			sejecutivo,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,srfc,snumcte_coppel,sAP_fecha_nac,sedo_civil,
			sactividad,ssexo,scurp,socr,semail,sescolaridad,stipo_residencia,spais_nacimiento
	FROM bdinteg:si_solicitud_movil
	WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
	AND bdinteg:si_solicitud_movil.status_valua = 0
	AND bdinteg:si_solicitud_movil.fecha_insert = TODAY
	ORDER BY id
	
	--LET sAP_paterno      = TRIM(sAP_paterno);
	--LET sAP_materno      = TRIM(sAP_materno);
	--LET sAP_nombre1      = TRIM(sAP_nombre1);
	--LET sAP_nombre2      = TRIM(sAP_nombre2);
	LET ssexo            = TRIM(ssexo);
	LET snumcte          = TRIM(snumcte);
	--Valida formato de la fecha de nacimiento
	--LET svt_dia          = sAP_fecha_nac[1,2];
	--LET svt_mes          = sAP_fecha_nac[4,5];
	--LET svt_year         = sAP_fecha_nac[7,10];
	
	--IF LENGTH(svt_year)<=2 THEN	
	--	IF TRIM(svt_year) IN ('00','01','02','03','04','05','06','07','08','09','10') THEN
	--		LET svt_year="20"||svt_year;
	--	ELSE
	--		LET svt_year="19"||svt_year;
	--	END IF
	--END IF;

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
	
	--LET sAP_fecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);
	
	--CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecha_nac)
	--RETURNING sRetCod, sAP_rfc;
	
	--LET sAP_rfc = trim(sAP_rfc);

	--IF sRetCod<>'00000' THEN
		--INSERT INTO si_valida_folio_detalle VALUES (sfolio,'RFC',snumcte,sRetCod,svt_fecha_hoy);
		
		--UPDATE si_solicitud_movil SET status_valua=2 WHERE folio = sfolio;
		
	--	CONTINUE FOREACH;
	--END IF;
	
	--UPDATE si_solicitud_movil SET ap_rfc=sAP_rfc WHERE folio=sfolio; 
	
	--LET sRetCod = "000";
	
	--IF snumcte IS NULL OR snumcte = "" THEN
		
	--	SELECT numcte INTO snumcte FROM si_cliente WHERE rfc = sAP_rfc;
	--	
	--	IF snumcte IS NULL OR snumcte = "" THEN
		
		--	CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_rfc,
		--				  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
		--				  sAP_fecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
		--				 sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
		--	RETURNING sRetCod,snumcte;
		
	--	END IF;
		
	--END IF;
	
	--IF sRetCod<>'000' THEN
	--	INSERT INTO si_valida_folio_detalle VALUES (sfolio,'ctefisico',snumcte,sRetCod,svt_fecha_hoy);
	--END IF;
	
	IF (snumcte IS NULL) OR (snumcte = "")  THEN
		
		CONTINUE FOREACH;
		
	END IF;
	
	--UPDATE si_solicitud_movil SET numcte=snumcte WHERE id=sid;
	
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
			ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.secuencia = b.secuencia
		WHERE 
			a.cliente = snumcte AND a.imagen IS NOT NULL AND a.cod_docto='0001';
	
		IF iexiste_imagen0001 = 0 THEN
			SELECT
				COUNT(*) INTO iexiste_imagen0001
			FROM bdidigital@coppelimg_tcp:dg_expediente_img2 a
			JOIN bdidigital@coppelimg_tcp:dg_expediente b 
				ON a.cliente = b.cliente AND a.cod_docto = b.cod_docto AND a.secuencia = b.secuencia
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

		CALL sp_alta_ctemovil(sfolio)
		RETURNING vcodretdet,snumcte;

		IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

		    UPDATE "informix".si_solicitud_movil
		    SET(status_valua)=(1)
		    WHERE folio = sfolio;
		ELSE		
			INSERT INTO si_valida_folio_detalle VALUES (sfolio,'sp_alta_ctemovil',snumcte,sRetCod,svt_fecha_hoy);
		END IF;
	END IF;
		
 END FOREACH;


RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 09/04/2015",
"Version    : 1.0",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_graba_telefonos_verificado(  pNumCte      CHAR(20),  -- NO. CLIENTE
														    pTelefono    CHAR(13),  -- TELEFONO
															pTipoTel     SMALLINT,  -- TIPO TELEFONO
															pExtension   CHAR(5),   -- EXTENSION
															pCarrier     SMALLINT,  -- CARRIER
															pCanal       SMALLINT,  -- CANAL
															pUserInsert  CHAR(8),   -- USUARIO
															pSucursal    CHAR(4),   -- Sucursal
															pVerificador CHAR(1))  -- Verificador de celular
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE cCodret1  CHAR(5);
    DEFINE cCodret2  CHAR(5);
    DEFINE cCodret3  CHAR(50);
    DEFINE iSql_err  INTEGER;
    DEFINE iSam_err  INTEGER;
    DEFINE cDesc_err CHAR(50);
    
    DEFINE iExisteCte       INTEGER;
    DEFINE iExisteCanal     INTEGER;
    DEFINE cCofetel         CHAR(1);
    DEFINE iExisteCarrier   INTEGER;
    DEFINE dfecha_insert    DATE;
    DEFINE sMaxSecTel       SMALLINT;
    DEFINE sContacto        SMALLINT;
    DEFINE iExisteTelefono  INTEGER;
    DEFINE iTelInvalido     INTEGER;
	DEFINE cMovilFijo       CHAR(1);
    DEFINE cStatusTel       CHAR(1);
	DEFINE cVerificado      CHAR(1);
	DEFINE cMarcatel        CHAR(1);
	DEFINE dFechaActualiza  DATE; 
	DEFINE cTelConfirmado   CHAR(1);
	DEFINE dFechCconfirmado DATE;
	
	DEFINE cCodRetSp2  CHAR(5); --EPG 021621
	DEFINE celularCli  CHAR(13);
	DEFINE nrows       SMALLINT;    
    LET cCodret1  = '000';
    LET cCodret2  = '000';
    LET cCodret3  = '';
    LET iSql_err  = 0;
    LET iSam_err  = 0;
    LET cDesc_err = '';
    
    LET iExisteCte       = 0;
    LET iExisteCanal     = 0;
    LET cCofetel         = 'V';
    LET iExisteCarrier   = 0;
    LET dfecha_insert    = '';
    LET sMaxSecTel       = 0;
    LET sContacto        = 0;
    LET iExisteTelefono  = 0;
    LET iTelInvalido     = 0;
	LET cMovilFijo 	     = '0';
    LET cStatusTel 	     = '';
    LET cVerificado      = pVerificador;
	LET cMarcatel        = '';
	LET dFechaActualiza  = ''; 
	LET cTelConfirmado   = '';
	LET dFechCconfirmado = '';
	
    LET cCodRetSp2     = '00000'; --EPG 021621
	LET celularCli     = '';
	LET nrows          = 0;       --EPG 021621
    
    BEGIN
    
     ON EXCEPTION SET iSql_err, iSam_err, cDesc_err
        IF iSql_err <> 0 THEN
            LET cCodret1 = iSql_err;
            LET cCodret2 = iSam_err;
            LET cCodret3 = cDesc_err;
            RETURN cCodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/tmp/sp_graba_telefonos_verificado.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pNumCte is null OR pNumCte = '') OR (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) OR (pCarrier is null) OR (pCanal is null OR pCanal = 0 ) OR
       (pUserInsert is null OR pUserInsert = '') OR (pVerificador is null OR pVerificador = '') THEN
        LET cCodret1 = '110'; -- DATOS INSUFICIENTES
        RETURN cCodret1;
    END IF;

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
	SELECT COUNT(*)
	INTO iExisteCte
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCte;
     
    IF iExisteCte = 0 THEN
        LET cCodret1 = '104'; -- NUM DE CLIENTE NO EXISTE
        RETURN cCodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
	SELECT COUNT(*)
	INTO iExisteTelefono
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = pNumCte
	AND tipo_tel = pTipoTel
	AND telefono = pTelefono
	AND carrier   = pCarrier
	AND extension = pExtension;
       
    IF iExisteTelefono > 0 THEN
        LET cCodret1 = '160'; -- TELEFONO EXISTE PARA TIPO INDICADO
        RETURN cCodret1;
    END IF;
    
    -- // VALIDA EL CANAL DE PROCEDENCIA
	SELECT COUNT(*)
	INTO iExisteCanal
	FROM bdinteg:"informix".si_canal
	WHERE cve_canal = pCanal;
     
    IF iExisteCanal = 0 THEN
        LET cCodret1 = '161'; -- CANAL DE PROCEDENCIA INVALIDO
        RETURN cCodret1;
    END IF;
    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
		SELECT COUNT(*)
		INTO iExisteCarrier
		FROM bdinteg:"informix".si_carriers
		WHERE cve_carrier = pCarrier;
         
        IF iExisteCarrier = 0 THEN
            LET cCodret1 = '162'; -- CARRIER DE CELULAR INVALIDO
            RETURN cCodret1;
        END IF;
    END IF;

    
	-- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
	SELECT COUNT(*)
	INTO iTelInvalido
	FROM bdinteg:"informix".si_telefonos_invalidos
	WHERE telefono = pTelefono;
     
    IF iTelInvalido > 0 THEN
        LET cCodret1 = '164'; -- TELEFONO INVALIDO
        RETURN cCodret1;
    END IF;
	
    SELECT telefono  --Obtiene el numero viejo del celular del cliente --EPG 021621 
	INTO celularCli 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte = pNumCte	AND tipo_tel='2' AND status_tel='A'; 
	
	LET nrows = dbinfo("sqlca.sqlerrd2");  --EPG 021621
    
    -- // OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dfecha_insert
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';
    
    -- // INSERTA EN TABLA DE TELEFONOS
	SELECT MAX(secuencia)
	INTO sMaxSecTel
	FROM bdinteg:"informix".si_telefonos
	WHERE numcte = pNumCte;
             
    IF sMaxSecTel is null OR sMaxSecTel = '' THEN
        LET sMaxSecTel = 0;
    END IF;
    
    LET sMaxSecTel = sMaxSecTel + 1;
    
	UPDATE bdinteg:"informix".si_telefonos
	SET status_tel = 'C'
	WHERE numcte = pNumCte
	AND tipo_tel = pTipoTel;
    
    INSERT INTO bdinteg:"informix".si_telefonos
    (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza, tel_confirmado, fech_confirmado)
    VALUES
    ('001', pNumCte, pTelefono, pTipoTel, 'A', sMaxSecTel, pExtension, pCarrier, pCanal, sContacto, cCofetel, current, pUserInsert, cMovilFijo, cStatusTel, cVerificado, cMarcatel, dFechaActualiza, cTelConfirmado, dFechCconfirmado);
    
	--INFORMAMOS ACTUALIZACION DE TELEFONO AL TELEFONO ACTUAL --EPG 021621
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
	--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_verificado_cub', pTelefono,'Nuevo') INTO cCodRetSp2;
	
	IF (nrows > 0) THEN
		--INFORMAMOS ACTUALIZACION DE TELEFONO SI TIENE UN TELEFONO VIEJO
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(celularCli),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
		--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_verificado_cub', celularCli,'Viejo') INTO cCodRetSp2;	
	END IF; --EPG 021621	
	
	SELECT COUNT(*)
	INTO iExisteCte
	FROM bdinteg:"informix".si_bitacora_tel
	WHERE numcte = pNumCte;
     
    IF iExisteCte = 0 THEN
        INSERT INTO bdinteg:"informix".si_bitacora_tel
        (numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper)
        VALUES
        (pNumCte, '0', '0', pCanal, pSucursal, pUserInsert, CURRENT);
    ELSE 
        UPDATE bdinteg:"informix".si_bitacora_tel
           SET ind_telefono = '0',
               ind_correo   = '0',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
    
    END;
    
    RETURN cCodret1;
    
END PROCEDURE
DOCUMENT
'AUTOR: 96591307-Viridiana Paredes Romero',
'CENTRO: 230142',
'FOLIO: 289',
'DESCRIPCION: Se crea sp para grabar el numero de celular verificado',
'RQM: RQM 10 747-2 Adendum Actualizacion de Telefonos o Correo a Solicitud del Cliente en el CAT',
'FECHA: 14/Agosto/2017',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_graba_telefonos_web( pNumCte     CHAR(20),  -- NO. CLIENTE
                                                pTelefono   CHAR(13),  -- TELEFONO
                                                pTipoTel    SMALLINT,  -- TIPO TELEFONO
                                                pExtension  CHAR(5),   -- EXTENSION
                                                pCarrier    SMALLINT,  -- CARRIER
                                                pCanal      SMALLINT,  -- CANAL
                                                pUserInsert CHAR(8),   -- USUARIO
                                                pSucursal   CHAR(4) )  -- SUCURSAL
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vExisteCanal     INTEGER;
    DEFINE vCodRetValTel    CHAR(5);
    DEFINE vValCasa         CHAR(1);
    DEFINE vValCelular      CHAR(1);
    DEFINE vValOficina      CHAR(1);
    DEFINE vCofetel         CHAR(1);
    DEFINE vExisteCarrier   INTEGER;
    DEFINE vfecha_insert    DATE;
    DEFINE vMaxSecTel       SMALLINT;
    DEFINE vContacto        SMALLINT;
    DEFINE vSecMaxDir       INTEGER;
    DEFINE vExisteTelefono  INTEGER;
    DEFINE vTelInvalido     INTEGER;
	DEFINE cMovilFijo       CHAR(1);
    DEFINE cStatusTel       CHAR(1);
	DEFINE vverificado      CHAR(1);
	DEFINE vmarcatel        CHAR(1);
	DEFINE vfecha_actualiza DATE; 
	DEFINE v_tel_confirmado CHAR(1);
	DEFINE vfech_confirmado DATE;
	
	DEFINE cCodRetSp2  CHAR(5);  --EPG 021621
	DEFINE celularCli  CHAR(13);
	DEFINE nrows       SMALLINT; --EPG 021621
    
    LET vcodret1 = '00000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte       = 0;
    LET vExisteCanal     = 0;
    LET vCodRetValTel    = '';
    LET vValCasa         = '';
    LET vValCelular      = '';
    LET vValOficina      = '';
    LET vCofetel         = '';
    LET vExisteCarrier   = 0;
    LET vfecha_insert    = '';
    LET vMaxSecTel       = 0;
    LET vContacto        = 0;
    LET vSecMaxDir       = 0;
    LET vExisteTelefono  = 0;
    LET vTelInvalido     = 0;
	LET cMovilFijo 	     = '0';
    LET cStatusTel 	     = '';
    LET vverificado      = '';
	LET vmarcatel        = '';
	LET vfecha_actualiza = ''; 
	LET v_tel_confirmado = '';
	LET vfech_confirmado = '';
	
    LET cCodRetSp2     = '00000'; --EPG 021621
	LET celularCli     = '';
	LET nrows          = 0;       --EPG 021621
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_telefonos.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_telefonos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) OR
       ( pTelefono is null OR pTelefono = '' ) OR
       ( pTipoTel is null OR pTipoTel = 0 ) OR
       ( pCarrier is null ) OR
       ( pCanal is null OR pCanal = 0 ) OR
       ( pUserInsert is null OR pUserInsert = '' ) THEN
        LET vcodret1 = '00110'; -- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM si_cliente
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104'; -- NUM DE CLIENTE NO EXISTE
        RETURN vcodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
    SELECT COUNT(*)
      INTO vExisteTelefono
      FROM si_telefonos_actual
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel
       AND telefono = pTelefono
       AND carrier   = pCarrier
       AND extension = pExtension;
       
    IF vExisteTelefono > 0 THEN
        LET vcodret1 = '00160'; -- TELEFONO EXISTE PARA TIPO INDICADO
        RETURN vcodret1;
    END IF;
    
    -- // VALIDA EL CANAL DE PROCEDENCIA
    SELECT COUNT(*)
      INTO vExisteCanal
      FROM si_canal
     WHERE cve_canal = pCanal;
     
    IF vExisteCanal = 0 THEN
        LET vcodret1 = '00161'; -- CANAL DE PROCEDENCIA INVALIDO
        RETURN vcodret1;
    END IF;
    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
        SELECT COUNT(*)
          INTO vExisteCarrier
          FROM si_carriers
         WHERE cve_carrier = pCarrier;
         
        IF vExisteCarrier = 0 THEN
            LET vcodret1 = '00162'; -- CARRIER DE CELULAR INVALIDO
            RETURN vcodret1;
        END IF;
    END IF;
    
    -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
    EXECUTE PROCEDURE sp_validatelefono('001', pTelefono, pTelefono, pTelefono)
    INTO vCodRetValTel, vValCasa, vValCelular, vValOficina;
    
    IF vValCasa = '1' OR vValCelular = '1' OR vValOficina = '1' THEN
        LET vCofetel = 'V';
    ELSE
        --- LET vCofetel = 'F';
        LET vcodret1 = '00163'; -- TELEFONO NO VALIDO PARA COFETEL
        RETURN vcodret1;
    END IF; 
    
    -- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
    SELECT COUNT(*)
      INTO vTelInvalido
      FROM si_telefonos_invalidos
     WHERE telefono = pTelefono;
     
    IF vTelInvalido > 0 THEN
        LET vcodret1 = '00164'; -- TELEFONO INVALIDO
        RETURN vcodret1;
    END IF;
	             
    SELECT telefono  --Obtiene el numero viejo del celular del cliente --EPG 021621 
	INTO celularCli 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte = pNumCte	AND tipo_tel='2' AND status_tel='A'; 
	
	LET nrows = dbinfo("sqlca.sqlerrd2");  --EPG 021621
    
    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM si_fechas
     WHERE empresa = '001';
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO vMaxSecTel
      FROM si_telefonos
     WHERE numcte = pNumCte;
	
	IF vMaxSecTel is null OR vMaxSecTel = '' THEN
        LET vMaxSecTel = 0;
    END IF;
    
    LET vMaxSecTel = vMaxSecTel + 1;
    
    UPDATE si_telefonos
       SET status_tel = 'C'
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel;
    
    INSERT INTO si_telefonos
    (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza, tel_confirmado, fech_confirmado)
    VALUES
    ('001', pNumCte, pTelefono, pTipoTel, 'A', vMaxSecTel, pExtension, pCarrier, pCanal, vContacto, vCofetel, current, pUserInsert, cMovilFijo, cStatusTel, vverificado, vmarcatel, vfecha_actualiza, v_tel_confirmado, vfech_confirmado);
    
	--INFORMAMOS ACTUALIZACION DE TELEFONO AL TELEFONO ACTUAL --EPG 021621
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2; 
	--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_web_cub', pTelefono,'Nuevo') INTO cCodRetSp2;
	
	IF (nrows > 0) THEN
		--INFORMAMOS ACTUALIZACION DE TELEFONO SI TIENE UN TELEFONO VIEJO
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(celularCli),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2; 
		--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_graba_telefonos_web_cub', celularCli,'Viejo') INTO cCodRetSp2;
	END IF; --EPG 021621
	
    SELECT COUNT(*)
      INTO vExisteCte
      FROM si_bitacora_tel
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        INSERT INTO si_bitacora_tel
        ( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
        VALUES
        ( pNumCte, '0', '0', pCanal, pSucursal, pUserInsert, CURRENT );
    ELSE 
        UPDATE si_bitacora_tel
           SET ind_telefono = '0',
               ind_correo   = '0',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;