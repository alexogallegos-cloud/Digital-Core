CREATE PROCEDURE "informix".sp_consultarclientebpi2_web(pTipo CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20), pCveOperacion CHAR (12),pSucursal CHAR(5),pIdusuario CHAR(10),pIpusu CHAR(16))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(10), -- Fecha Registro
	CHAR(10), -- Fecha Nacimiento
    CHAR(20), -- Numero de Cliente
    CHAR(26), -- Apellido Paterno
    CHAR(26), -- Apellido Materno
    CHAR(26), -- Nombre1
    CHAR(26), -- Nombre2
    CHAR(4),  -- Id Status
    CHAR(5), -- suc Registro
	CHAR(40), -- Nom Suc
    CHAR(12), -- Folio Contrato
    CHAR(250), -- DescriciÃ³n ValidaciÃ³n
    SMALLINT, --Tipo Servicio
    CHAR(6),  --Status token
	char(15), --Num Sol Token
	money(16,2); --Costo Token
	
    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE vCodRet      CHAR(5);
    DEFINE vFechaReg    CHAR(10);
	DEFINE vFechaNac    CHAR(10);
    DEFINE vNumCte      CHAR(20);
    DEFINE vApePat      CHAR(26);
    DEFINE vApeMat      CHAR(26);
    DEFINE vNombre1     CHAR(26);
    DEFINE vNombre2     CHAR(26);
    DEFINE vStatus      SMALLINT;
    DEFINE vSucReg      CHAR(5);
	DEFINE vSucNom      CHAR(40);
    DEFINE vMensValid   CHAR(250);
    DEFINE vTipoPersona CHAR(2);
    DEFINE vFolio       CHAR(12);
    DEFINE vF_status    DATE;
    DEFINE vF_registro  DATE;
    DEFINE vFecha_Hoy   DATE;
    DEFINE vTipoServicio SMALLINT;
    DEFINE vStatusToken CHAR(6);
    DEFINE vIdStatusAnterior SMALLINT;
	DEFINE vSolicitud CHAR(15);
	
	--Variables de Retorno del Stored sp_cons_detenvios_token2	
	DEFINE vFolioSuc char(16);
	DEFINE vCuenta char(20); 
	DEFINE vFecha date;
	DEFINE vSucursal char(4); 
	DEFINE vCargoTot money(16,2);
	
    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;
    LET vCodRet =   '00000';
    LET vFechaReg = '01/01/1900';
	LET vFechaNac = '01/01/1900';
    LET vNumCte =   '';
    LET vApePat =   '';
    LET vApeMat =   '';
    LET vNombre1 =  '';
    LET vNombre2 =  '';
    LET vStatus = 0;
    LET vSucReg = '';
	LET vSucNom = '';
    LET vMensValid = '';
    LET vTipoPersona = '';
    LET vFolio = '';
    LET vF_status  =  '01/01/1900';
    LET vF_registro = '01/01/1900';
    LET vTipoServicio = 0;
    LET vStatusToken = '';
    LET vIdStatusAnterior = 0;
	LET vSolicitud= '';
	LET vFolioSuc= '';
	LET vCuenta= '';
	LET vFecha= '';
	LET vSucursal= '';
	LET vCargoTot = 0;

     --SET DEBUG FILE TO "/tmp/SP_ConsultarClienteBPI2.out";
     --TRACE ON;
	
	--**************************************************************
	-- Creado por: Manuel Osuna Valencia 
	-- Fecha: 2010-09-03                                
	-- Solicito: Ismael Hernandez
	-- Stored de Consulta de Cliente y Registro de Bitacora para la
	-- ReimpresiÃ³n de documentos.
	--**************************************************************

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            RETURN vCodRet, vFechaReg, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vMensValid, vTipoServicio, vStatusToken,vSolicitud,vCargoTot;
        END IF;
    END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
		IF pTipo = '2' THEN 
			IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte and tpo_persona = '01') THEN
					IF (SELECT count(id_status) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte ) > 0 THEN
								SELECT bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1,
									 bdi_sicte.nombre2, bdi_sibpi.id_status, bdi_sibpi.suc_registro, bdi_sisuc.nombre, bdi_sibpi.folio_contrato, bdi_sibpi.f_registro::date,
									 bdi_sictepf.fecha_nac, bdi_sibpi.servicio
								INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vFechaReg, vFechaNac,vTipoServicio 
								FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf, bdinteg:si_bpiusuarios bdi_sibpi, bdinteg:si_sucursales bdi_sisuc
								WHERE bdi_sicte.numcte = pNumCte
									AND bdi_sicte.empresa = pEmpresa
									AND bdi_sicte.tpo_persona = '01'
									AND bdi_sicte.numcte = bdi_sictepf.numcte
									AND bdi_sicte.numcte = bdi_sibpi.numcte
									AND bdi_sibpi.suc_registro = bdi_sisuc.sucursal;
								 
								IF vStatus = '0' OR  vStatus = '88' OR  vStatus = '99' THEN 
									LET vCodRet =  '00003';
									LET vMensValid = 'Este cliente tiene el servicio de banca por Internet cancelado, bloqueado o pre-activaciÃ³n incompleta';
								ELIF (SELECT count(status_destino) FROM si_bpicatcambiostatus WHERE Proceso = pTipo AND status_origen = vStatus ) = 0  THEN
									IF  EXISTS (SELECT mensaje FROM bdinteg:si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus) 										THEN
										SELECT mensaje INTO vMensValid FROM bdinteg:si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = 										vStatus;
								ELSE
									LET vCodRet = '00002';
									LET vMensValid = 'El cliente tiene un estatus invÃ¡lido para el servicio';
								END IF;

							END IF;	 
					ELSE
							SELECT mensaje INTO vMensValid FROM bdinteg:si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
							LET vCodRet = '00004';
					END IF		
									  
			ELSE
					SELECT tpo_persona INTO vTipoPersona FROM bdinteg:si_cliente WHERE numcte = pNumcte AND empresa = pEmpresa;
					IF vTipoPersona = '02' THEN
							LET vCodRet = '00002';						
							LET vMensValid = 'Cliente Moral, verifique';
						
					ELSE
							LET vCodRet =   '00001';
    						LET vMensValid = 'Cliente no Existe';							

				   END IF;
			END IF;
		ELIF pTipo = '1' THEN
		
			select solicitud into vSolicitud from bdibpi:bpi_tokensolicitud  where numcte = pNumCte and f_solicitud = 
           (select max(f_solicitud) from bdibpi:bpi_tokensolicitud  where numcte = pNumCte);
		   
		   IF vSolicitud <> ""  THEN
				EXECUTE PROCEDURE  bdibpi:sp_cons_detenvios_token2(pEmpresa,vSolicitud) INTO vCodRet,vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot; 
				
		   END IF;	
		ELIF pTipo = '3' THEN	
			
		--Registra Datos en la bitacora
			insert into si_bpibitacora(fecha_oper,id_operacion,sucursal,id_usuario,ipusuario,fecha_aplic,cuenta_origen)
			values(current,'1024',pSucursal,pIdusuario,pIpusu,date(current),pNumCte);	
		END IF;	

    RETURN vCodRet, vFechaReg, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vSucReg, vSucNom, vFolio, vMensValid, vTipoServicio, vStatusToken,vSolicitud,vCargoTot;
END
END PROCEDURE
DOCUMENT
"Modificado: Hector Juan Casanova Edeza",
"Proyecto: BPI",
"Solicito: Ismael Hernandez",
"Descripcion: se modifica el formato de casteo del campo fecha registro al formato  MM/DD/AAAA.",
"Fecha: 2010/10/15",
"Version: 20101015.1642",
'',
"Modificado: Edgar Ivan Rochin Rocha",
"Proyecto: BPI",
"Solicito: Ismael Hernandez",
"Descripcion: se modifico para que regrese el nombre de la sucursal.",
"Fecha: 2010/11/04",
"Version: 2010/11/04.1648";

CREATE PROCEDURE "informix".sp_altasolicitudmovil_mib()
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
SET DEBUG FILE TO '/RESPALDOSNEW/mbucio/Vobos/23012020/sp_altasolicitudmovil.out';
TRACE ON;

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
 FOREACH
	SELECT {+INDEX (bdinteg:si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert,firma_cc,firma_bc,firma_buro,
			ejecutivo,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,rfc,numcte_coppel,ap_fecha_nac,edo_civil,
			actividad,sexo,curp,ocr,email,escolaridad,tipo_residencia,pais_nac
	INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert,IfirmaCop,IfirmaBan,IBuro,
			sejecutivo,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,srfc,snumcte_coppel,sAP_fecha_nac,sedo_civil,
			sactividad,ssexo,scurp,socr,semail,sescolaridad,stipo_residencia,spais_nacimiento
	FROM bdinteg:si_solicitud_movil
	WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
	AND bdinteg:si_solicitud_movil.status_valua = 0
	AND bdinteg:si_solicitud_movil.fecha_insert = TODAY
	ORDER BY id
	
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
		IF TRIM(svt_year) IN ('00','01','02','03','04','05','06','07','08','09','10') THEN
			LET svt_year="20"||svt_year;
		ELSE
			LET svt_year="19"||svt_year;
		END IF
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
	
	IF sRetCod<>'000' THEN
		INSERT INTO si_valida_folio_detalle VALUES (sfolio,'ctefisico',snumcte,sRetCod,svt_fecha_hoy);
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

CREATE PROCEDURE "informix".sp_cnsif_pasesucursal2_totales(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Num_Sucursal CHAR(4))
	RETURNING CHAR(5) AS Cod_Retorno,
		INTEGER AS num_registros;

	DEFINE cCodRet        CHAR(5);
	DEFINE iSql_err       INT;
	DEFINE Id_Plaza       CHAR(3);
	DEFINE No_Sucursal    CHAR(4);
	DEFINE Nom_Sucursal   CHAR(40);
	DEFINE Gte_Sucursal   CHAR(40);
	DEFINE Tel_Sucursal   CHAR(14);
	DEFINE Estat_Suc      CHAR(8);
	DEFINE fechadia       DATE;
	DEFINE Flag_abrio     INTEGER;
	DEFINE Flag_cerro     INTEGER;
	--DEFINE cUsuario       CHAR(8);
	DEFINE Poliza_Suc     CHAR(2);
	DEFINE dFechaHora 	  DATETIME YEAR TO FRACTION(5);
	DEFINE iNumRegistros  INTEGER;
    DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador      INTEGER;
	DEFINE iMaxCommit 	  INTEGER;
	DEFINE cSucAbrio 	  CHAR(1);
	DEFINE cSucCerro 	  CHAR(1);
	DEFINE cPlaza         CHAR(3);
	DEFINE cSucursal 	  CHAR(4);
	DEFINE cNombre        CHAR(40);
	DEFINE cGerente       CHAR(40);
	DEFINE cTelefono1     CHAR(14);
	DEFINE cSuc_abrio     CHAR(1);
	DEFINE cSuc_cerro     CHAR(1);
	DEFINE cUsuario       CHAR(8);
	DEFINE iExistsUs      INTEGER;
	
	LET cCodRet          = "00000";
	LET iSql_err         = 0;
	LET Id_Plaza         = '';
	LET No_Sucursal      = '0000';
	LET Nom_Sucursal     = '';
	LET Gte_Sucursal     = '';
	LET Tel_Sucursal     = '';
	LET Estat_Suc        = '';
	LET fechadia         = '01-01-1900';
	LET Flag_abrio       = 0;
	LET Flag_cerro       = 0;
	--LET cUsuario         = '';
	LET Poliza_Suc       = '';
	LET dFechaHora	 	 = CURRENT YEAR TO FRACTION(5);
	LET iNumRegistros 	 = 0;
	LET bEnTransaccion   = 'f';
	LET iContador        = 0;
	LET iMaxCommit       = 1000;
	LET cSucAbrio 		 = '';
	LET cSucCerro 		 = '';
	LET cPlaza           = '';
	LET cSucursal 	     = '';
	LET cNombre          = '';
	LET cGerente         = '';
	LET cTelefono1       = '';
	LET cSuc_abrio       = '';
	LET cSuc_cerro       = '';
	LET cUsuario         = '';
	LET iExistsUs        = 0;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = iSql_err;
				UPDATE bdinteg:"informix".sw_statusmonitorps
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = cID_USUARIOC;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdinteg:"informix".sw_statusmonitorps
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = cID_USUARIOC;
			RETURN cCodRet, iNumRegistros;
		END IF;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_pasesucursal2_totales.out";
		--TRACE ON;

		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdinteg:"informix".sw_statusmonitorps WHERE usuario = cID_USUARIOC;
		DELETE FROM bdinteg:"informix".sw_detallemonitorps WHERE ps_usuario_insert = cID_USUARIOC;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdinteg:"informix".sw_statusmonitorps(usuario,status,num_registros,error_proceso,error)
		VALUES(cID_USUARIOC,'I',0,'',cCodRet); 
		
		SELECT fecha_hoy INTO fechadia FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdisuc:"informix".ss_pase_sucursal 113_444)} {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal)}
			A.plaza, A.sucursal, A.nombre, A.gerente, A.telefono1,
			B.suc_abrio, B.suc_cerro, B.usuario
			INTO cPlaza,cSucursal,cNombre,cGerente,cTelefono1,cSuc_abrio,cSuc_cerro,cUsuario
			FROM bdinteg:"informix".si_sucursales A, bdisuc:"informix".ss_pase_sucursal B
			WHERE B.sucursal = A.sucursal AND B.fecha_pase = fechadia AND A.sucursal = Num_Sucursal 
			ORDER BY A.sucursal
			
			IF cSuc_abrio = '1' AND cSuc_cerro = '0' THEN
				LET Estat_Suc = 'ABIERTA';
			ELSE
				IF cSuc_abrio = '1' AND cSuc_cerro = '1' THEN
					LET Estat_Suc = 'CERRADA';
				ELSE
					LET Estat_Suc = 'NO ABRIO';
				END IF;
			END IF;
			
			SELECT COUNT(*) INTO iExistsUs FROM bdicont@coppelcont_tcp:"informix".co_poliza WHERE fecha_captura = fechadia AND usuario = cSucursal;
			--SELECT COUNT(*) INTO iExistsUs FROM bdicont:"informix".co_poliza WHERE fecha_captura = fechadia AND usuario = cSucursal; 
			IF NVL(iExistsUs,0) > 0 THEN
				LET Poliza_Suc = 'SI';
			ELSE
				LET Poliza_Suc = 'NO';
			END IF;
			
			LET iExistsUs = 0;
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdinteg:"informix".sw_detallemonitorps(ps_usuario_insert,ps_fecha_hora_insert,
			ps_idplaza,ps_no_sucursal,ps_nom_sucursal,ps_gte_sucursal,ps_tel_sucursal,ps_suc_abrio,ps_suc_cerro,ps_estat_suc,ps_usuario_suc,ps_poliza_suc,ps_fecha_pase)
			VALUES(cID_USUARIOC,dFechaHora,cPlaza,cSucursal,cNombre,cGerente,cTelefono1,cSuc_abrio,cSuc_cerro,Estat_Suc,cUsuario,Poliza_Suc,fechadia);
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00105'; 
			UPDATE bdinteg:"informix".sw_statusmonitorps
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = cID_USUARIOC;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		UPDATE bdinteg:"informix".sw_statusmonitorps
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = cID_USUARIOC;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT  'AUTOR: L. Montserrat León Amador',
'FECHA: 05/03/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Se implementa el tratado de la información en segundo plano (spl encargado de consultar el número total de registros).',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/01/2020',
'DESCRIPCION: Se aplica optimización de querys.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_numcte(pId CHAR(12), pIdDocto CHAR(1))
   RETURNING CHAR(5) as CodRet, CHAR(9) as NumCte, CHAR(4) as cod_docto, CHAR(5) as secuencia, CHAR(3) as formato;
DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(5);
DEFINE cNumCte      CHAR(9);
DEFINE iStatusValua	INTEGER;
DEFINE sCodRetImg   CHAR(3);
DEFINE sCodRetExp   CHAR(3);
DEFINE iSecuencia   SMALLINT;
DEFINE pIdDoctoAux  CHAR(1);
DEFINE sCodDocto    CHAR(4);
DEFINE sFormato     CHAR(3);
DEFINE iExiste     INTEGER;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET iSqlErr         = 0;
LET cCodRet         = '00000';
LET sCodRetExp      ='000';
LET cNumCte         = '';
LET sCodRetImg      = '';
LET iSecuencia      = 0;
LET sCodDocto       = '';
LET sFormato        = '';
LET pIdDoctoAux     ='';
LET iExiste			=0;
LET iStatusValua	=-1;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet,'', '', 0, '';
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/VH/movil/sp_numcte.out';
--TRACE ON;

IF pIdDocto='0' THEN
    LET sCodDocto = '0001';
    LET sFormato='JPG';
ELIF pIdDocto='1' THEN
    LET sCodDocto = '0001';
    LET sFormato='JPG';
ELIF pIdDocto='3' THEN
    LET sCodDocto = '0600';
    LET sFormato='PNG';    
ELIF pIdDocto='4' THEN
    LET sCodDocto = '0601';
    LET sFormato='PNG';
ELIF pIdDocto='5' THEN
    LET sCodDocto = '0602';
    LET sFormato='PNG';
ELIF pIdDocto='6' THEN
    LET sCodDocto = '0603';
    LET sFormato='JPG';
END IF;




	SET ISOLATION TO DIRTY READ;
    SELECT numcte,status_valua INTO cNumCte, iStatusValua FROM bdinteg:"informix".si_solicitud_movil WHERE id=pId;
	
	IF iStatusValua IS NOT NULL AND iStatusValua=2 THEN
		LET cCodRet='00005';
		RETURN cCodRet,'', '', 0, '';
	END IF;
	

	IF sCodDocto = '0001' THEN
		--SELECT COUNT(*) INTO iExiste FROM bdidigital@coppelimg_crx:dg_expediente WHERE empresa='001' and cliente=cNumCte and cod_docto='0001';
		SELECT COUNT(*) INTO iExiste FROM bdidigital@coppelimg_crx:"informix".dg_expediente ex INNER JOIN bdidigital@coppelimg_crx:"informix".dg_expediente_img1 img1 ON ex.cliente=img1.cliente AND img1.cod_docto=ex.cod_docto AND ex.secuencia=img1.secuencia WHERE ex.cliente=cNumCte and ex.cod_docto='0001' AND img1.imagen IS NOT NULL;
		IF iExiste>=2 THEN
             LET cCodRet='00004';
             RETURN cCodRet,'', '', 0, '';
		END IF;
		SELECT COUNT(*) INTO iExiste FROM bdidigital@coppelimg_crx:"informix".dg_expediente ex INNER JOIN bdidigital@coppelimg_crx:"informix".dg_expediente_img2 img2 ON ex.cliente=img2.cliente AND img2.cod_docto=ex.cod_docto AND ex.secuencia=img2.secuencia WHERE ex.cliente=cNumCte and ex.cod_docto='0001';
		IF iExiste>=2 THEN
             LET cCodRet='00004';
             RETURN cCodRet,'', '', 0, '';
		END IF;
	END IF;

    IF cNumCte IS NULL OR 
	(cNumCte)='' THEN
        LET cCodRet='00001';
        RETURN cCodRet,'', '', 0, '';
    ELSE
      --EJECUTANDO SP INSERTA_IMG_PREVIO
       execute procedure bdidigital@coppelimg_crx:"informix".inserta_img_previo('001', cNumCte, sCodDocto, sFormato, 'informix')
        INTO sCodRetImg, iSecuencia;

       IF sCodRetImg<>'000' THEN
          LET cCodRet='00002';
          RETURN cCodRet,'', '', 0, '';
       ELSE
          EXECUTE PROCEDURE bdidigital:"informix".inserta_reg_expediente('001', cNumCte, '99999999999', '9999', sCodDocto, iSecuencia, 'ALTA CLIENTES', '','informix')
            INTO sCodRetExp;
          IF sCodRetExp<>'000' THEN
             LET cCodRet='00003';
             RETURN cCodRet,'', '', 0, '';
          END IF;
       END IF;

    END IF

RETURN cCodRet, cNumCte,sCodDocto, iSecuencia, sFormato;

END
END PROCEDURE
DOCUMENT
'Descripcion: consulta el identificador de solicitudes movil.',
'BD: BDINTEG';

CREATE PROCEDURE "informix".consdirec_web(pempresa char(3), pnumcte char(20), pnum_direc smallint)
returning char(5),int,char(1),char(40),char(60),char(40),
          char(3),char(2),char(3),char(5),char(5),char(11),char(1),
          char(13),char(1),char(13),char(1),char(13),char(5),char(2),char(3),
          char(4),smallint,char(10),char(10),char(6),int,int,char(1),
          char(1),smallint,smallint,smallint,smallint,smallint,smallint,
          smallint,char(80);

    DEFINE vcodret char(5);
    DEFINE vciclo smallint;
    DEFINE vsqlerr integer;

    DEFINE vsecuencia int ;
    DEFINE vtipo_dir char(1);
    DEFINE vcalle char(40);
    DEFINE vcolonia char(60);
    DEFINE ventre_calles char(40);
    DEFINE vpais char(3);
    DEFINE vestado char(2);
    DEFINE vciudad char(3);
    DEFINE vmunicipio char(5);
    DEFINE vcod_postal char(5);
    DEFINE vapart_postal char(11);
    DEFINE vtipo_telef1  char(1);
    DEFINE vtelefono1 char(13);
    DEFINE vtipo_telef2  char(1);
    DEFINE vtelefono2  char(13);
    DEFINE vtipo_telef3  char(1);
    DEFINE vtelefono3  char(13);
    DEFINE vextension char(5);
    DEFINE vestado_inegi  char(2);
    DEFINE vmunicipio_inegi char(3);
    DEFINE vlocalidad_inegi  char(4);
    DEFINE vnumerociudad smallint ;
    DEFINE vnumeroextcalle  char(10);
    DEFINE vnumerointcalle  char(10);
    DEFINE vdepartamento  char(6);
    DEFINE vnumerocalle int ;
    DEFINE vnumerocolonia int ;
    DEFINE vpuntocardinal  char(1);
    DEFINE vunidadhabitac  char(1);
    DEFINE vmanzana smallint ;
    DEFINE votros  smallint ;
    DEFINE vandador smallint ;
    DEFINE vetapa smallint ;
    DEFINE vlote  smallint ;
    DEFINE vedificio  smallint ;
    DEFINE ventrada  smallint ;
    DEFINE vobservaciones char(80);
	DEFINE vsecuenciamax int ;
	DEFINE vsecuenciamin int ;

    LET vciclo = 0;
    LET vcodret = "00000";
    LET  vsqlerr = 0;

    LET vsecuencia = 0;
	LET vsecuenciamax = 0;
	LET vsecuenciamin = 0;
    LET vtipo_dir = "";
    LET vcalle = "";
    LET vcolonia = "";
    LET ventre_calles = "";
    LET vpais = "";
    LET vestado = "";
    LET vciudad = "";
    LET vmunicipio = "";
    LET vcod_postal = "";
    LET vapart_postal = "";
    LET vtipo_telef1 = "";
    LET vtelefono1 = "";
    LET vtipo_telef2 = "";
    LET vtelefono2 = "";
    LET vtipo_telef3 = "";
    LET vtelefono3 = "";
    LET vextension = "";
    LET vestado_inegi = "";
    LET vmunicipio_inegi = "";
    LET vlocalidad_inegi = "";
    LET vnumerociudad = 0;
    LET vnumeroextcalle = "";
    LET vnumerointcalle = "";
    LET vdepartamento = "";
    LET vnumerocalle = 0;
    LET vnumerocolonia = 0;
    LET vpuntocardinal = "";
    LET vunidadhabitac = "";
    LET vmanzana = 0;
    LET votros  = 0;
    LET vandador  = 0;
    LET vetapa = 0;
    LET vlote = 0;
    LET vedificio  = 0;
    LET ventrada = 0;
    LET vobservaciones = "";

    BEGIN

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,
            vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,vtelefono1,
            vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,
            vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
            vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,
            votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones;
        end if;
    end exception;

	-- Bloque modificacion

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		select max(secuencia) 
		INTO  vsecuenciamax
		from "informix".si_direcciones 		
		where numcte = pnumcte;

		if vsecuenciamax > 20 THEN

			let vsecuenciamin = vsecuenciamax - 20;

		end if;
	-- Termina modificacion

    FOREACH
        SELECT dir.secuencia,dir.tipo_dir,dir.calle,dir.colonia,dir.entre_calles,dir.pais,dir.estado,dir.ciudad,dir.municipio,dir.cod_postal,dir.apart_postal,
                nvl(tel1.tipo_tel,''),nvl(tel1.telefono,''),nvl(tel2.tipo_tel,''),nvl(trim(tel2.telefono),''),nvl(tel3.tipo_tel,''),nvl(tel3.telefono,''),nvl(tel3.extension,''),
                dir.estado_inegi,dir.municipio_inegi,dir.localidad_inegi,dir.numerociudad,dir.numeroextcalle,dir.numerointcalle,dir.departamento,
                dir.numerocalle,dir.numerocolonia,dir.puntocardinal,dir.unidadhabitac,dir.manzana,dir.otros,dir.andador,dir.etapa,dir.lote,dir.edificio,dir.entrada,dir.observaciones
          INTO  vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,
                vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
                vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones
          FROM "informix".si_direcciones dir
          LEFT OUTER JOIN "informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          LEFT OUTER JOIN "informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
          LEFT OUTER JOIN "informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
         WHERE dir.numcte = pnumcte
		 and dir.secuencia > vsecuenciamin
		 and dir.secuencia <= vsecuenciamax
         ORDER BY dir.secuencia

        let vciclo = vciclo+1;

        if vciclo <= pnum_direc then
            continue foreach;
        end if

        IF LENGTH(vtelefono2) = 13 THEN
            LET vtelefono2 = SUBSTRING(vtelefono2 FROM 4 FOR 13);
        ELIF LENGTH(vtelefono2) = 12 THEN
            LET vtelefono2 = SUBSTRING(vtelefono2 FROM 3 FOR 12);
        ELIF LENGTH(vtelefono2) = 11 THEN
            LET vtelefono2 = SUBSTRING(vtelefono2 FROM 2 FOR 11);
        END IF;

        return  vcodret,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,
                vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,vtelefono1,
                vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,
                vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
                vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,
                votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones  with resume;
    END FOREACH;
    
    END
    
END PROCEDURE

DOCUMENT
"Consulta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Daniel Zambada",
"FECHA : 30/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".consppes_n_web (pempresa char(3), pnumcte char(20), pnum_direc smallint)
            RETURNING CHAR(5), -- Codigo Retorno
                                     CHAR(3), -- Empresa
                                     CHAR(20), -- NumCte
                                     CHAR(1), -- Tipo_ppes
                                     CHAR(2), -- puesto_ppes
                                     CHAR(26), -- Apell_paterno
                                     CHAR(26), -- Apell_materno
                                     CHAR(26), -- Nombre1
                                     CHAR(26), -- Nombre2
                                     DECIMAL(14,2), --Participacion
                                     CHAR(80), -- Domicilio
                                     CHAR(20), -- Telefono
                                     CHAR(8), -- User_insert
                                     DATE, -- Fecha_insert
                                     INTEGER, -- NumeroRegistro
                                     CHAR(40); -- Asociacion_civil

-- Definicion de Variables
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;
-- si_cteppes
DEFINE vempresa CHAR(3);
DEFINE vnumcte CHAR(20);
DEFINE vtipo_ppes CHAR(1);
DEFINE vpuesto_ppes  CHAR(2);
DEFINE vapell_paterno  CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vnombre1  CHAR(26);
DEFINE vnombre2  CHAR(26);
DEFINE vparticipacion DECIMAL(14,2);
DEFINE vdomicilio  CHAR(80);
DEFINE vtelefono  CHAR(20);
DEFINE vuser_insert CHAR(8);
DEFINE vfecha_insert DATE;
DEFINE vnumeroregistro  INTEGER ;
DEFINE vasociacioncivil CHAR(40);

-- Inicializacion de Variables
LET vciclo = 0;
LET vcodret = "00000";
LET  vsqlerr = 0;
-- si_cteppes
LET vempresa = "";
LET vnumcte = "";
LET vtipo_ppes = "";
LET vpuesto_ppes = "";
LET vapell_paterno = "";
LET vapell_materno = "";
LET vnombre1 = "";
LET vnombre2 = "";
LET vparticipacion = 0;
LET vdomicilio = "";
LET vtelefono = "";
LET vuser_insert = "";
LET vfecha_insert = "";
LET vnumeroregistro = 0;
LET vasociacioncivil = "";

   -- SET DEBUG FILE TO "/informix/JesusBueno/servicios/SpsModificados/consppes_n.out";
   -- TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                            vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
        END IF;
    END EXCEPTION;

    SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT empresa, numcte,tipo_ppes,puesto_ppes,apell_paterno,apell_materno,nombre1,nombre2,
                        participacion,domicilio,telefono,user_insert,fecha_insert,numeroregistro,asociacion_civil
             INTO  vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil
           FROM bdinteg:"informix".si_cteppes
        WHERE numcte = pnumcte AND empresa = pempresa
        ORDER BY numeroregistro
        
        LET vciclo = vciclo+1;
        
        IF vciclo <= pnum_direc THEN
            CONTINUE FOREACH;
        END IF
        
        RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil WITH RESUME;
	
    END FOREACH;
	
	IF vciclo = 0 THEN
		LET vcodret = '00001';
		 RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
		
	END IF 
END
END PROCEDURE
DOCUMENT
"Consulta de personas politicas",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 15/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".direcciones_web( pEmpresa         CHAR(3),  
                                         pFuncion         CHAR(1),   
                                         pNumCte          CHAR(20), 
                                         pSecuencia       SMALLINT, 
                                         pTipoDir         CHAR(1), 
                                         pCalle           CHAR(40),
                                         pColonia         CHAR(60), 
                                         pMunicipio       CHAR(5), 
                                         pEntre_Calles    CHAR(40),
                                         pPais            CHAR(3),
                                         pEntidad         CHAR(2),
                                         pLocalidad       CHAR(3),
                                         pCodPostal       CHAR(5),
                                         pTipoTel1        CHAR(1),
                                         pTelefono1       CHAR(13),
                                         pTipoTel2        CHAR(1),
                                         pTelefono2       CHAR(13),
                                         pTipoTel3        CHAR(1),
                                         pTelefono3       CHAR(13),
                                         pExtension       CHAR(5),
                                         pEstado_Inegi    CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad        SMALLINT,
                                         pNoExt           CHAR(10),
                                         pNoInt           CHAR(10),
                                         pDepto           CHAR(6),
                                         pNoCalle         INTEGER,
                                         pNoColonia       INTEGER,
                                         pPuntoCar        CHAR(1),
                                         pUniHabi         CHAR(1),
                                         pManz            SMALLINT,
                                         pPOtros          SMALLINT,
                                         pAndador         SMALLINT,
                                         pEtapa           SMALLINT,
                                         pLote            SMALLINT,
                                         pEdif            SMALLINT,
                                         pEntrada         SMALLINT,
                                         pObserva         CHAR(80),
                                         pUser_Insert     CHAR(8),
                                         pFecha_Insert    DATE,
                                         cSucursal        CHAR(4) )
RETURNING CHAR(5);

    DEFINE cCodRet             CHAR(5);
    DEFINE cCodRet2            CHAR(5);
    DEFINE cCodRet3            CHAR(50);
    DEFINE iSqlErr             INTEGER;
    DEFINE iIsamErr            INTEGER;
    DEFINE cDescErr            CHAR(50);
    DEFINE cNumCte             CHAR(20);
    DEFINE iCoincide_dir        SMALLINT;
    DEFINE cTipoDir         	CHAR(1);
    DEFINE cCalle            	CHAR(40);
    DEFINE cColonia         	CHAR(60);
    DEFINE cEntreCalles     	CHAR(40);
    DEFINE cPais           	CHAR(3);
    DEFINE cEstado         	CHAR(2);
    DEFINE cCiudad         	CHAR(3);
    DEFINE cMunicipio      	CHAR(5);
    DEFINE cCodPostal     	CHAR(5);
    DEFINE cApartPostal   	CHAR(11);
    DEFINE cTelefono1      	CHAR(13);
    DEFINE cTelefono2      	CHAR(13);
    DEFINE cTelefono3      	CHAR(13);
    DEFINE cExtension      	CHAR(5);
    DEFINE cEstadoInegi   	CHAR(2);
    DEFINE cMunicipioInegi	CHAR(3);
    DEFINE cLocalidadInegi    CHAR(4);
    DEFINE iNumeroCiudad   	SMALLINT;
    DEFINE cNumeroExtCalle 	CHAR(10);
    DEFINE cNumeroIntCalle 	CHAR(10);
    DEFINE cDepartamento   	CHAR(6);
    DEFINE iNumeroCalle    	INTEGER;
    DEFINE iNumeroColonia  	INTEGER;
    DEFINE cPuntoCardinal  	CHAR(1);
    DEFINE cUnidadHabitac  	CHAR(1);
    DEFINE iManzana        	SMALLINT;
    DEFINE iOtros          	SMALLINT;
    DEFINE iAndador        	SMALLINT;
    DEFINE iEtapa          	SMALLINT;
    DEFINE iLote           	SMALLINT;
    DEFINE iEdificio       	SMALLINT;
    DEFINE iEntrada        	SMALLINT;
    DEFINE cObservaciones  	CHAR(80);
    DEFINE cCodRetTel          CHAR(5);
    DEFINE iTipoTel             SMALLINT;
    DEFINE iCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACION ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACION ESPECIAL

    LET cCodRet          = '';
    LET cCodRet2         = '';
    LET cCodRet3         = '';
    LET iSqlErr          = 0;
    LET iIsamErr         = 0;
    LET cDescErr         = '';
    LET cNumCte          = '';
    LET iCoincide_dir     = 0;
    LET cTipoDir        = '';
    LET cCalle           = '';
    LET cColonia         = '';
    LET cEntreCalles    = '';
    LET cPais            = '';
    LET cEstado          = '';
    LET cCiudad          = '';
    LET cMunicipio       = '';
    LET cCodPostal      = '';
    LET cApartPostal    = '';
    LET cTelefono1       = '';
    LET cTelefono2       = '';
    LET cTelefono3       = '';
    LET cExtension       = '';
    LET cEstadoInegi    = '';
    LET cMunicipioInegi = '';
    LET cLocalidadInegi = '';
    LET iNumeroCiudad    = 0;
    LET cNumeroExtCalle  = '';
    LET cNumeroIntCalle  = '';
    LET cDepartamento    = '';
    LET iNumeroCalle     = 0;
    LET iNumeroColonia   = 0;
    LET cPuntoCardinal   = '';
    LET cUnidadHabitac   = '';
    LET iManzana         = 0;
    LET iOtros           = 0;
    LET iAndador         = 0;
    LET iEtapa           = 0;
    LET iLote            = 0;
    LET iEdificio        = 0;
    LET iEntrada         = 0;
    LET cObservaciones   = '';
    LET cCodRetTel       = '';
    LET iTipoTel          = 0;
    LET iCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACION ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACION ESPECIAL

     --SET DEBUG FILE TO "/informix/tmp/direcciones.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        --SET DEBUG FILE TO "/tmp/direcciones.err";
        --TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET cCodRet = "00000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO cNumCte 
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF cNumCte IS NULL THEN
        LET cCodRet = "00104";
        RETURN cCodRet;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM bdinteg:"informix".si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;

        -- // SE AGREGA VALIDACION PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null  THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO cTipoDir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal,
               cEstadoInegi, cMunicipioInegi, cLocalidadInegi, iNumeroCiudad, 
               cNumeroExtCalle, cNumeroIntCalle, cDepartamento, iNumeroCalle, iNumeroColonia, 
               cPuntoCardinal, cUnidadHabitac, iManzana, iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
        
        IF ( cTipoDir is not null               
             AND cCalle = pCalle                     
             AND cColonia = pColonia                 
             AND cEntreCalles = pEntre_Calles       
             AND cPais = pPais                       
             AND cEstado = pEntidad                  
             AND cCiudad = pLocalidad                
             AND cMunicipio = pMunicipio             
             AND cCodPostal = pCodPostal            
             AND cEstadoInegi = pEstado_Inegi       
             AND cMunicipioInegi = pMunicipio_Inegi 
             AND cLocalidadInegi = pLocalidad_Inegi 
             AND iNumeroCiudad = pNoCiudad           
             AND cNumeroExtCalle = pNoExt            
             AND cNumeroIntCalle = pNoInt            
             AND cDepartamento = pDepto              
             AND iNumeroCalle = pNoCalle             
             AND iNumeroColonia = pNoColonia         
             AND cPuntoCardinal = pPuntoCar          
             AND cUnidadHabitac = pUniHabi           
             AND iManzana = pManz                    
             AND iOtros = pPOtros                    
             AND iAndador  = pAndador                
             AND iEtapa = pEtapa                     
             AND iLote = pLote                       
             AND iEdificio = pEdif                   
             AND iEntrada = pEntrada                 
             AND cObservaciones = pObserva ) THEN
            LET iCoincide_dir = 1;
			LET cCodRet = "00001";
        ELSE
            LET iCoincide_dir = 0;
        END IF;
        
        IF ( iCoincide_dir <= 0 ) THEN
			INSERT INTO bdinteg:"informix".si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
        END IF;
        
        -- // VALIDA LA INFORMACION DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO cTelefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        IF cTelefono1 is null THEN
            LET cTelefono1 = ' ';
        END IF;
           
        IF cTelefono1 <> pTelefono1 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel1 is not null AND pTipoTel1 <> '' ) AND ( pTelefono1 is not null AND pTelefono1 <> '' ) ) THEN
                LET iTipoTel = 1;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, iTipoTel, '', 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
           
        SELECT telefono
          INTO cTelefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        IF cTelefono2 is null THEN
            LET cTelefono2 = ' ';
        END IF;
           
        IF cTelefono2 <> pTelefono2 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                LET iTipoTel = 2;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, iTipoTel, '', 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
           
        SELECT telefono, extension
          INTO cTelefono3, cExtension
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        IF cTelefono3 is null THEN
            LET cTelefono3 = ' ';
        END IF;
           
        IF cTelefono3 <> pTelefono3 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel3 is not null AND pTipoTel3 <> '' ) AND ( pTelefono3 is not null AND pTelefono3 <> '' ) ) THEN
                LET iTipoTel = 3;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, iTipoTel, pExtension, 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
        
        -- // VALIDACION DE SITUACION ESPECIAL
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN
            SELECT LIMIT 1 NVL(situacion,''), causa
              INTO cSituacionEsp, iCausa
              FROM bdisitesp:"informix".se_ctessitespcte
             WHERE numcte = pNumCte;
			
            IF cSituacionEsp = 'L' THEN			 
                DELETE FROM bdisitesp:"informix".se_ctessitespcte 
                 WHERE numcte = pNumCte 
                   AND situacion = 'L';
            
                INSERT INTO bdisitesp:"informix".se_ctessitespcte_his
                (empresa, sucursal, numcte, situacion, causa, tipomovto, empleadoefectuo, usralta, fchmodifica)
                VALUES
                (pEmpresa, cSucursal, pNumCte, cSituacionEsp, iCausa, 'B', pUser_Insert, pUser_Insert, pFecha_Insert);
            END IF;
        END IF;
        RETURN cCodRet;
    END IF;
    END;
END PROCEDURE;