CREATE PROCEDURE "informix".sp_genera_folio_portabilidad(pEmpresa CHAR(3),pSucursal CHAR(4),pTipoOperacion CHAR(2),pIdentificador CHAR(1))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet,
			CHAR(30) AS cFolio;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 		CHAR(6);
DEFINE  cSucursal		CHAR(8);
DEFINE  cFolio			CHAR(30);
DEFINE  cCveSPEI		CHAR(5);
DEFINE  cHoraUno		CHAR(8);
DEFINE  cHora			CHAR(6);
DEFINE  cFecha			CHAR(8);
DEFINE  cFechaNormal	CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 		= '000000';
LET cSucursal		= '';
LET cFolio			= '';
LET cCveSPEI		= '';
LET cHoraUno		= '';
LET cHora			= '';
LET cFecha			= '';
LET cFechaNormal	= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cFolio;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_genera_folio_portabilidad.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pTipoOperacion,'') <> '' AND NVL(pIdentificador,'') <> '' THEN
		SELECT fecha_hoy INTO cFechaNormal FROM bdicheq:"informix".sc_fechas
		WHERE empresa = pEmpresa;

		LET cFecha = TRIM(SUBSTR(cFechaNormal,7,4) || SUBSTR(cFechaNormal,1,2) || SUBSTR(cFechaNormal,4,2));

		SELECT FIRST 1 CURRENT HOUR TO SECOND INTO cHoraUno FROM "informix".systables;
		LET cHora =  REPLACE(cHoraUno,':','');

		SELECT cvecesif INTO cCveSPEI FROM bdinteg:"informix".si_bancos
		WHERE banco = '137';

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001289';
		END IF;

		SELECT clave_tipo INTO cFechaNormal
		FROM bdicheq:"informix".sc_portacec_tipo_operacion
		WHERE clave_tipo = pTipoOperacion;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001289';
		ELSE
			LET cSucursal = LPAD(pSucursal,8,"0");
			LET cFolio = TRIM(cFecha||cHora||cCveSPEI||pTipoOperacion||pIdentificador||cSucursal);
		END IF;

	ELSE
		LET cCodRet ='001288';
	END IF
	RETURN cCodRet,cFolio;
END;
END PROCEDURE
DOCUMENT
'000000 - Se genera el folio',
'001289 - No existe el banco o tipo operacion',
'001288 - Parametros incompletos',
'DESCRIPCION: Genera el folio de solicitud de portabilidad de nomina',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo Gómez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_obten_info_cancelacion(pEmpresa CHAR(3),pNumCta CHAR(20),pNumCte CHAR(20))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet,
			CHAR(40) AS cBancoOrdenante,
			CHAR(18) AS cCuentaCLABEOrdenante,
			CHAR(40) AS cBancoReceptor,
			CHAR(18) AS cCuentaCLAVEReceptor,
			CHAR(30) AS cFolioSolicitud;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 				CHAR(6);
DEFINE  cBancoOrdenante			CHAR(40);
DEFINE  cCuentaCLABEOrdenante	CHAR(18);
DEFINE  cBancoReceptor			CHAR(40);
DEFINE  cCuentaCLAVEReceptor	CHAR(18);
DEFINE  cFolioSolicitud			CHAR(30);
DEFINE  iSqlErr					INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 				= '000000';
LET cBancoOrdenante			= '';
LET cCuentaCLABEOrdenante	= '';
LET cBancoReceptor			= '';
LET cCuentaCLAVEReceptor	= '';
LET cFolioSolicitud			= '';
LET iSqlErr					= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cBancoOrdenante,cCuentaCLABEOrdenante,cBancoReceptor,cCuentaCLAVEReceptor,cFolioSolicitud;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_obten_info_cancelacion.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCta,'') <> '' AND NVL(pNumCte,'') <> '' THEN

	SELECT cta_ordenante, bco_ordenante, cta_receptora, bco_receptor, folio_solicitud
		INTO cCuentaCLABEOrdenante,cBancoOrdenante,cCuentaCLAVEReceptor,cBancoReceptor,cFolioSolicitud
		FROM bdicheq:"informix".sc_portacec_solicitud
		WHERE empresa = pEmpresa AND num_cte = pNumCte AND cta_ordenante = pNumCta
            and folio_solicitud = (SELECT max(folio_solicitud)
                                               FROM bdicheq:"informix".sc_portacec_solicitud
                                               WHERE empresa = pEmpresa 
                                                 AND num_cte = pNumCte
                                                 AND cta_ordenante = pNumCta
                                                  AND clave_sentido in ('1', '0')
                                                   And estatus_portabilidad = '1');

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001289';
		ELSE
			SELECT descripcion INTO cBancoOrdenante FROM bdinteg:"informix".si_bancos
			WHERE cvecesif = cBancoOrdenante;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '001289';
			ELSE
				SELECT descripcion INTO cBancoReceptor FROM bdinteg:"informix".si_bancos
				WHERE cvecesif = cBancoReceptor;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '001289';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001288';
	END IF
	RETURN cCodRet,cBancoOrdenante,cCuentaCLABEOrdenante,cBancoReceptor,cCuentaCLAVEReceptor,cFolioSolicitud;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Datos',
'001289 - No existe el Cliente',
'001288 - Parametros incompletos',
'DESCRIPCION: obtener la información de la orden de cancelación de transferencia',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo Gómez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_verificatarjetaotrosbancos(pClaveBanco CHAR(3),pNumtarjeta CHAR(16))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 		CHAR(6);
DEFINE  cCve_banco		CHAR(3);
DEFINE  cbin			CHAR(6);
DEFINE  cCreditodebito	CHAR(1);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 		= '000000';
LET cCve_banco		= '';
LET cbin			= '';
LET cCreditodebito	= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_verificatarjetaotrosbancos.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pClaveBanco,'') <> '' AND NVL(pNumtarjeta,'') <> '' THEN

		LET cbin = TRIM(SUBSTR(pNumtarjeta,1,6));

		SELECT creditodebito,cve_banco INTO cCreditodebito,cCve_banco
		FROM bdicheq:"informix".sc_bines
		WHERE bin = cbin;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000245';
		ELSE
			IF NVL(cCreditodebito,'') <> 'd' THEN
				LET cCodret = '000245';			
			ELSE
				IF NVL(cCve_banco,'') <> NVL(pClaveBanco,'') THEN
					LET cCodret = '001270';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001288';
	END IF
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'000000 - Exito',
'000245 - Tarjeta de credito o no existe el bin',
'001270 - claves de bancos distintos',
'001288 - Parametros incompletos',
'DESCRIPCION: Verifica la tarjeta de otros bancos',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo Gómez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_valida_portabilidad(pEmpresa CHAR(3),pNumCte CHAR(20),pNumCtaOrd CHAR(20))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet,
			CHAR(20) AS cCuentaOrd;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 	CHAR(6);
DEFINE  cCuentaOrd	CHAR(20);
DEFINE  iSqlErr		INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 	= '000000';
LET cCuentaOrd	= '';
LET iSqlErr		= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cCuentaOrd;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_valida_portabilidad.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pNumCtaOrd,'') <> '' THEN
		SELECT numcte INTO cCuentaOrd FROM bdinteg:"informix".si_cliente
		WHERE empresa = pEmpresa AND numcte = pNumCte;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001289';
		ELSE
			SELECT cta_receptora INTO cCuentaOrd FROM bdicheq:"informix".sc_portacec_solicitud
			WHERE empresa = pEmpresa AND num_cte = pNumCte AND cta_ordenante = pNumCtaOrd
			AND estatus_portabilidad = '1';

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '000000';
			ELSE
				LET cCodret = '000001';
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001288';
	END IF
	RETURN cCodRet,cCuentaOrd;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Cuenta',
'000001 - Sin Cuenta',
'001289 - No existe el Cliente',
'001288 - Parametros incompletos',
'DESCRIPCION: Validar si la cuenta ordenante a la que se desea generar una solicitud de portabilidad ya tiene una cuenta con portabilidad Activa',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo Gómez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".cargo_retenido_comp_pba(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER;
     
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE nComit           INTEGER;
    DEFINE vcuantos         INTEGER;
    
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vsql             CHAR(200);
    DEFINE vfolio           CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vimporte         MONEY(14,2);
    DEFINE vimport          MONEY(14,2);
    DEFINE vdisp            MONEY(14,2);
    DEFINE vmaxsec          SMALLINT;
    DEFINE vtarjeta         CHAR(16);
    DEFINE vsucursal        CHAR(4);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           MONEY(14,2);
    DEFINE vcargo           MONEY(14,2);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vexiste          INTEGER;
    DEFINE vfechades        CHAR(10);
    DEFINE vfechadescarga   CHAR(6);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(2);
    DEFINE vnombre          VARCHAR(50);
    DEFINE vcargado         MONEY(14,2);
    DEFINE whora1           CHAR(5);
    DEFINE whora2           CHAR(2);
    DEFINE whora3           CHAR(2);
    DEFINE whora            CHAR(4);
    DEFINE vfecha_mov       DATE;
    DEFINE vfecha1          CHAR(10);

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_comp.out";
    -- TRACE ON;

    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET nComit      = 0;
    LET vcuantos    = -1;
    
    LET vfecha       = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = ''; 
    LET vimporte     = 0.00; 
    LET vdescripcion = ''; 
    LET vfecha_mov   = '';  
    LET vdisp        = 0.00; 
    LET vsucursal    = ''; 
    LET vstatus      = '';  
    LET vmaxsec      = '';  
    LET vtarjeta     = '';  
    LET vexiste      = '';  
    LET vtransacc    = '';  
    LET vfecha_cargo = '';  
    LET vdispo       = 0.00; 
    LET vcargo       = 0.00; 
    LET vimport      = 0.00;

    SET ISOLATION TO DIRTY READ;

    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    TRUNCATE TABLE "informix".cargos;

    FOREACH WITH HOLD
        SELECT cuenta, importe, descripcion, fecha
          INTO vcuenta, vimporte, vdescripcion, vfecha_mov
          FROM cuentas

        SELECT sdo_actual - sdo_cong - sdo_retenido, sucursal, status_cta
          INTO vdisp, vsucursal, vstatus
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        IF vcuantos = -1 THEN
            BEGIN WORK;
            LET nComit = 1;
            LET vcuantos = 0;
        END IF

        IF vdisp > 0.00 THEN
        
            SELECT MAX(secuencia)
              INTO vmaxsec
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tarjeta = "T";

            SELECT num_tarjeta
              INTO vtarjeta
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND secuencia = vmaxsec;

            IF vstatus = 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "1",
                       motivo = " "
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste <> 0 THEN
                    DELETE FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                END IF

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = "B"
                   AND tipo_mov = "B"
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                     INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
					 VALUES(pempresa, vcuenta, "D", "00", " ",0.00, "informix", vfecha,current hour to fraction,"1111", "D", vfolio, " ");
                END IF

            END IF

            IF vdisp >= vimporte THEN

                CALL cargo_ref(pempresa, vsucursal, "informix", "0270", 
                               "0270", vfolio, vcuenta, 0, vimporte, "01", 
                               vdescripcion, vtarjeta, "informix")
                RETURNING vcodret1, vtransacc, vfecha_cargo, vdispo, vcargo;
				
                IF vcodret1 = "000" THEN

                    LET vcargo = vcargo;

                ELSE

                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo (cuenta,clave,opcion) VALUES(vcuenta, "09", "3");
                    ELSE
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                    INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
					VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, current hour to fraction,"1111","B",vfolio," ");

                    LET vcargo = 0;

                END IF

                INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, " ", vfecha_mov);

            ELSE

                LET vimport = vdisp;

                CALL cargo_ref(pempresa, vsucursal, "informix", "0270", 
                               "0270", vfolio, vcuenta, 0, vimport, "01",
                               vdescripcion, vtarjeta, "informix")
                RETURNING vcodret1, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret1 = "000" THEN

                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo (cuenta,clave,opcion) VALUES (vcuenta, "09", "3");
                    ELSE 
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                     INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
					 VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha,current hour to fraction,"1111","B",vfolio," ");

                    LET vcargo = vcargo;

                ELSE

                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo (cuenta,clave,opcion) VALUES (vcuenta, "09", "3");
                    ELSE 
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                     INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
					 VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, current hour to fraction,"1111","B",vfolio," ");

                    LET vcargo = 0;

                END IF

                INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, " ", vfecha_mov);

            END IF

        ELSE
        
            IF vstatus <> 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "3",
                       motivo = "09"
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste = 0 THEN
                    INSERT INTO sc_ctabloqueo (cuenta,clave,opcion) VALUES (vcuenta, "09", "3");
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = "09",
                           opcion = "3"
                     WHERE cuenta = vcuenta;
                END IF

                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                 INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
				 VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha,current hour to fraction,"1111","B",vfolio," ");

            END IF
            
            LET vcargo = 0;

            INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, " ", vfecha_mov);
            
            LET vcuantos = vcuantos + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            
            LET vcuenta      = ''; 
            LET vimporte     = 0.00; 
            LET vdescripcion = ''; 
            LET vfecha_mov   = '';  
            LET vdisp        = 0.00; 
            LET vsucursal    = ''; 
            LET vstatus      = '';  
            LET vmaxsec      = '';  
            LET vtarjeta     = '';  
            LET vexiste      = '';  
            LET vtransacc    = '';  
            LET vfecha_cargo = '';  
            LET vdispo       = 0.00; 
            LET vcargo       = 0.00; 
            LET vimport      = 0.00;

            CONTINUE FOREACH;

        END IF;
        
        LET vcuantos = vcuantos + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta      = ''; 
        LET vimporte     = 0.00; 
        LET vdescripcion = ''; 
        LET vfecha_mov   = '';  
        LET vdisp        = 0.00; 
        LET vsucursal    = ''; 
        LET vstatus      = '';  
        LET vmaxsec      = '';  
        LET vtarjeta     = '';  
        LET vexiste      = '';  
        LET vtransacc    = '';  
        LET vfecha_cargo = '';  
        LET vdispo       = 0.00; 
        LET vcargo       = 0.00; 
        LET vimport      = 0.00;
    END FOREACH

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE cargos;

    LET whora1 = CURRENT HOUR TO MINUTE;
    LET whora2 = whora1[1,2];
    LET whora3 = whora1[4,5];
    LET whora = whora2||whora3;
    LET vfechades = TO_CHAR(vfecha, '%Y/%m/%d');
    LET vdia = vfechades[9,10];
    LET vmes = vfechades[6,7];
    LET vanio = vfechades[3,4];
    LET vfechadescarga = vdia||vmes||vanio;
    LET vnombre = 'aplicados_'||vfechadescarga||'_'||whora||'.txt';

    LET vsql = "";
    -- LET vsql = 'echo "UNLOAD TO ./'||vnombre||' SELECT * FROM cargos " > ./cargos.sql';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cargos WHERE cargado > 0" > /resplogifx/conciliachq/cargos.sql';
    SYSTEM vsql;
    LET vsql = "";
    -- LET vsql = "dbaccess bdicheq ./cargos.sql";
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    SYSTEM vsql;
    LET vsql = "";
    -- LET vsql = 'chmod 664 ./'||vnombre;
    LET vsql = '/usr/bin/chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";
    
    TRUNCATE TABLE "informix".cuentas;
    
    LET vcuenta      = '';
    LET vcargo       = 0.00;
    LET vcargado     = 0.00;
    LET vdescripcion = '';
    LET vfecha_mov   = '';
    
    FOREACH WITH HOLD
        SELECT cuenta, cargo, cargado, descripcion, fecha
          INTO vcuenta, vcargo, vcargado, vdescripcion, vfecha_mov
          FROM cargos
        
        BEGIN WORK;
        
        LET vcargo = vcargo - vcargado;
          
        IF vcargo > 0 THEN
            INSERT INTO cuentas VALUES(vcuenta, vcargo, vdescripcion, vfecha_mov);
        END IF;
        
        COMMIT WORK;
        
        LET vcuenta      = '';
        LET vcargo       = 0.00;
        LET vcargado     = 0.00;
        LET vdescripcion = '';
        LET vfecha_mov   = '';
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentas;

    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE
DOCUMENT 
'Se realiza modificacion al procedimiento en los inserts a la tablas sc_ctabloqueo y sc_histbloq ',
'Modifico : Jesús Manuel Aguilar Heredia',
'FECHA : 13/SEPTIEMBRE/2010',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_inserta_portabilidad(pEmpresa CHAR(3), 
													  pNumCte CHAR(20), 
													  pCuentaAbono CHAR(20),
													  pCuentaCLABERef CHAR(18),
													  pTarjetaRef CHAR(20),													  
													  pFechaDeposito CHAR(60), 
													  pEstatus CHAR(2), 
													  pOrigenAlta CHAR(20), 
													  pSucursalAlta CHAR(4),
													  pUserInsert CHAR(8),
													  pBancoRec CHAR(3))
--DATOS A REGRESAR---												 
	RETURNING
	CHAR(6) AS cCodRet;

---DECLARACIONES
DEFINE iSqlErr  	INTEGER;
DEFINE cCodRet  	CHAR(6);
DEFINE cProducto  	CHAR(4);
DEFINE cStatusCta  	CHAR(1);
DEFINE cValor	  	CHAR(60);
DEFINE cStatusPorta	CHAR(2);
DEFINE sClaveDest	CHAR(3);
DEFINE cCuenta		CHAR(20);
DEFINE iTransaccion INTEGER;
DEFINE iSecuencia   INTEGER;
DEFINE dFecha		DATE;

DEFINE vcuenta      CHAR(20);

---INICIALIZACIONES
LET iSqlErr      = 0;
LET cCodRet      = "000000";
LET cProducto    = "";
LET cStatusCta   = "";
LET cValor	     = "";
LET cStatusPorta = "";
LET sClaveDest	 = "";
LET cCuenta	 	 = "";
LET iTransaccion = 0;
LET iSecuencia	 = 0;
LET dFecha		 = DATE(1);

LET vcuenta      = ''; 

BEGIN	

	ON EXCEPTION SET iSqlErr --Manejador de Errores	
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			IF iTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                
				 BEGIN WORK;
            END IF;
		DELETE bdicheq:"informix".sc_portacec_solicitud 
		WHERE empresa = pEmpresa
		AND num_cte = pNumCte 
		AND cta_ordenante = pCuentaAbono
		AND cta_receptora = CASE WHEN pCuentaCLABERef = '' THEN pTarjetaRef ELSE pCuentaCLABERef END;
		
		LET cCodRet = "001272";
		RETURN cCodRet;
			
        END IF;		
    END EXCEPTION;
	
	ON EXCEPTION IN (-535)
        LET iTransaccion = 1;
    END EXCEPTION WITH RESUME;
	
    IF iTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/martin/sp_inserta_portabilidad.out";
	--TRACE ON;
		
	IF NVL(pEmpresa,"") = "" OR NVL(pNumCte,"") = "" OR NVL(pCuentaAbono,"") = "" OR NVL(pFechaDeposito,"") = "" OR NVL(pEstatus,"") = "" OR NVL(pOrigenAlta,"") = "" OR NVL(pSucursalAlta,"") = "" OR NVL(pUserInsert,"") = "" THEN			
		LET cCodRet = "001288"; --PARAMETROS VACIOS		
		RETURN cCodRet;												  
	ELSE			
				
		SELECT fecha_hoy
		INTO dFecha
		FROM bdicheq:"informix".sc_fechas 
		WHERE empresa = pEmpresa;
					
					
		LET vcuenta = substr(pCuentaAbono, 7, 11);			
					
					
		SELECT producto, status_cta,cuenta
		INTO cProducto, cStatusCta,cCuenta
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = pEmpresa
		AND cuenta = vcuenta;
		--AND cuenta_clabe = pCuentaAbono;
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			LET cCodRet = "001289";			
			RETURN cCodRet;	
		END IF;
	
		IF (SELECT COUNT(valor) FROM bdicheq:"informix".sc_param WHERE empresa = pEmpresa AND codparam = "PORTAPRODPERM" AND valor LIKE '%'||cProducto||'%') = 1 THEN			
	
		ELSE			
			LET cCodRet = "001285";			
			RETURN cCodRet;	
		END IF;
		
		IF cStatusCta = "2" OR cStatusCta = "6" OR cStatusCta = "7" OR cStatusCta = "8" THEN		
			LET cCodRet = "001290";			
			RETURN cCodRet;			
		END IF;
				
		SELECT NVL(MAX(secuencia),0)
		INTO iSecuencia
		FROM bdicheq:"informix".sc_portabilidadnomina 
		WHERE empresa = pEmpresa
		AND cliente = pNumCte
		AND cuenta_abono = pCuentaAbono;
		

		SELECT estatus
		INTO cStatusPorta
		FROM bdicheq:"informix".sc_portabilidadnomina 
		WHERE empresa = pEmpresa
		AND cliente = pNumCte
		AND cuenta_abono = pCuentaAbono
		AND secuencia = iSecuencia;
		
		IF NVL(cStatusPorta,"") = "01" THEN		
			LET cCodRet = "001291"; --"LA CUENTA BANCOPPEL YA CUENTA CON EL SERVICIO DE PORTABILIDAD ACTIVO"				
			RETURN cCodRet;				
		END IF;
		
		IF iSecuencia IS NULL THEN
			LET iSecuencia = 1;
		ELSE
			LET iSecuencia = iSecuencia+1;
		END IF;
		
		LET sClaveDest = pBancoRec; 
		
		IF EXISTS (SELECT banco FROM bdinteg:"informix".si_bancos WHERE banco = sClaveDest) THEN
						
		ELSE
			LET cCodRet = "001289"; --Codigo del BancoDestino no valido; No existe en el catálogo de Bancos.		
			RETURN cCodRet;			
			
		END IF;
		
		INSERT INTO bdicheq:"informix".sc_portabilidadnomina (empresa,cliente,cuenta_abono,secuencia,banco_ref,cuenta_ref,tarjeta_ref,fecha_deposito,estatus,user_cancel,fecha_cancel,origen_alta,sucursal_alta,origen_cancel,sucursal_cancel,user_insert,fecha_insert) 
		VALUES (pEmpresa,pNumCte,cCuenta,iSecuencia,sClaveDest,pCuentaCLABERef,pTarjetaRef,pFechaDeposito,pEstatus,USER,dFecha,pOrigenAlta,pSucursalAlta,'OFI','0002',pUserInsert,CURRENT);
		
		RETURN cCodRet;
	
	END IF;
END;
END PROCEDURE
DOCUMENT
"Descripcion: Se crea procedimiento para insertar en la tabla sc_portabilidadnomina la informacion cuando el proceso de alta.",
"			  sea de BanCoppel a otro banco u Otro Banco a BanCoppel.",
"Codigos de Error: ",
"",
"			cCodRet = 001272 El proceso de Activacion de Portabilidad de Nomina de Bancoppel a Otro Banco no fue satisfactorio.",
"			cCodRet = 001285 La persona no tiene una cuenta de captacion valida.",
"			cCodRet = 001288 Parametros de Entrada vacios, verifique.",
"			cCodRet = 001289 No existe informacion. Favor de verificar.",
"			cCodRet = 001290 La cuenta BanCoppel se encuentra cancelada.",
"			cCodRet = 001291 La cuenta Bancoppel ya cuenta con el Servicio de Portabilidad activo.",
"			cCodRet = ",	
"Autor  : Jairo Valdez Gonzalez",
"Solicito: Ivan Castillo Montalvo",
"Folio: 1748",
"Sustento: RQM 10 610 Cambios en el Servicio de Portabilidad",
"Fecha  : 31/08/2015",
"BD     : bdicheq";

create procedure "informix".sp_registra_evento (
					pTipoMsj char(1), pIdMsj char(10),pIdPlantilla char(12), pNumclt char(20),
					pNumcta char(20), pNumTarjeta char(16),pTipoproc char(1), pStr1 char(30), 
					pStr2 char(30), pStr3 char(30), pStr4 char (30), 
					pStr5 char(150), pStr6 char(100), pStr7 char(60), pStr8 char(60), 
					pStr9 char(15), pStr10 char(100), pcorreo_alterno char(100), pcelular_alterno char(10), 
					pImporte1 money (16,2), pImporte2 money (16,2),
					pImporte3 money (16,2), pImporte4 money (16,2), pImporte5 money (16,2), 
					pfecha1 datetime year to fraction(3), pfecha2 datetime year to fraction(3)
				    )

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.


    --*******************************************************************************************************
    -- Realizo   :Angel Rene de la Llave
    -- Proyecto : Latinia registro de eventos.
    -- Actividad : Se registran los eventos para el envÃÆÃÂ­o de mnsjr y emails a un cliente
    --                  basados en las transacciones que haya efectuado.
    -- Fecha     : 26/03/2012
    -- ModificaciÃÆÃÂ³n: Incluir campos string adicionales. JGP-19/09/2012
    -- Fecha:       19/09/2012
    -- ModificaciÃÆÃÂ³n: Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean 
    --               confirmados por Intercard. JGP-09/11/2012
    -- Fecha:       09/11/2012
	-- Realizo  : Manuel Osuna V.  
	-- ModificaciÃÂ³n: Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta
	-- pueda manejar multiples plantillas.
    -- Fecha:       15/10/2013
	-- Realizo  : Cristo Lugo  
	-- ModificaciÃÂ³n: Se agrega validaciÃÂ³n pIdMsj,para que evitar enviar la misma alerta durante el dia.
    -- Fecha:       28/08/2014
    --*******************************************************************************************************
 
--DefiniciÃÆÃÂ³n de Variables
DEFINE cCodRet CHAR(5);
DEFINE iexiste INTEGER;
DEFINE iexiste2 INTEGER;
DEFINE iexiste3 INTEGER;
DEFINE iexistec INTEGER;
DEFINE vnumcte CHAR(20);
DEFINE vsqlerr INTEGER;
DEFINE vtransaction_id CHAR(10);
DEFINE cDia CHAR (2);
DEFINE cAnio CHAR (4);
DEFINE cMes CHAR(2);
DEFINE cMes1 CHAR (10);
DEFINE cFechaH CHAR (10);


--Inicializa Variables
LET cCodRet = '00000';
LET iexiste = 0;
LET iexiste2 = 0;
LET iexiste3 = 0;
LET iexistec = 0;
LET vsqlerr = 0;
LET vnumcte = '';
LET cDia ='';
LET cAnio  ='';
LET cMes  ='';
LET cMes1 ='';
LET cFechaH ='';


BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
	--SET DEBUG FILE TO "/informix/cristo/sp_registra_evento.out";
	--TRACE ON;

-- VERIFICA QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS O NULLS
	IF (pTipoMsj IS NULL OR pTipoMsj = '') OR
	   (pIdMsj IS NULL OR pIdMsj = '') OR
	   (pTipoproc IS NULL OR pTipoproc = '') OR
	   (pIdPlantilla IS NULL OR pIdPlantilla = '') THEN	   
	   LET cCodRet = '00005';
	   RETURN cCodRet;
	END IF;
	
--VERIFICA SI SE TRATA DE UN PROCESO VALIDO
	IF pTipoproc > '2' OR pTipoproc = '0'THEN
	   LET cCodRet = '00020';
	   RETURN cCodRet;
	END IF;
	
-- VERIFICA QUE SE UN TIPO DE MENSAJE VALIDO
	IF pTipoMsj > '3' OR pTipoMsj = '0' THEN
		LET cCodRet = '00103';
	    RETURN cCodRet;
	END IF;
--VARIFICA QUE UNO DE ESTOS TRES DATOS OBLIGATORIOS DEL CLIENTE VENGA INFORMACION	
	IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL OR pNumTarjeta = '') THEN
	   LET cCodRet = '00110';
	   RETURN cCodRet;
	END IF;
	
--VALIDACION DE FECHA FORMATO DE MES NOMBRE COMPLETO
        
IF pIdMsj = 'POS_CREDE' OR pIdMsj = 'ATM_CREDE'THEN

	select DAY(fecha_hoy),MONTH(fecha_hoy),YEAR(fecha_hoy) into cDia,cMes,cAnio
    from bdinteg:"informix".si_fechas where empresa ='001';

	IF (cMes ='1') THEN LET cMes1 = 'ENERO';  
		ELIF (cMes ='2') THEN LET cMes1 = 'FEBRERO';
		ELIF (cMes ='3') THEN LET cMes1 = 'MARZO';
		ELIF (cMes ='4') THEN LET cMes1 = 'ABRIL';
		ELIF (cMes ='5') THEN LET cMes1 = 'MAYO';
		ELIF (cMes ='6') THEN LET cMes1 = 'JUNIO';
		ELIF (cMes ='7') THEN LET cMes1 = 'JULIO';
		ELIF (cMes ='8') THEN LET cMes1 = 'AGOSTO';
		ELIF (cMes ='9') THEN LET cMes1 = 'SEPTIEMBRE';
		ELIF (cMes ='10') THEN LET cMes1 = 'OCTUBRE';
		ELIF (cMes ='11') THEN LET cMes1 = 'NOVIEMBRE';
		ELIF (cMes ='12') THEN LET cMes1 = 'DICIEMBRE';
	END IF;
		
		LET pStr5 = trim(cDia)||'-'||trim(cMes1)||'-'||trim(cAnio);
END IF;	


--VALIDA QUE SI NO CONTIENE COMO PARAMETRO DE ENTRADA EL NUMERO DE CLIENTE, BÃÆÃÂ¡SQUE POR TARJETA O CUENTA.

	IF SUBSTR(pIdMsj,1,3)<>"WEB" THEN	
		IF trim(pNumclt) <> ''  THEN
			IF (trim(pNumclt) <> '000000000') THEN
				SELECT {+index (bdinteg:si_cliente,  224_479)} nvl(count(numcte),0) INTO iexistec FROM bdinteg:"informix".si_cliente WHERE numcte = pNumclt;
				IF (iexistec = 0 or iexistec is null) then
					LET cCodRet = '00100';
					RETURN cCodRet;
				END IF;
			END IF;	
		ELSE -- SE BUSCA EL CLIENTE
			IF TRIM(pNumcta) <> '' THEN
				SELECT {+index (bdicheq:sc_maechq, 174_183)} NVL(COUNT(CUENTA),0),NVL(num_cte, 0) INTO iexiste, vnumcte FROM bdicheq:"informix".sc_maechq WHERE CUENTA = pNumcta group by num_cte;
				IF (iexiste = 0 or iexiste is null) THEN
					SELECT {+index (bdicred:sd_maecred, idx_idx_maecredb)} NVL(COUNT(num_credito),0), NVL(numcte,0) INTO iexiste2, vnumcte FROM bdicred:"informix".sd_maecred WHERE num_credito = pNumcta group by numcte;
					IF (iexiste2 = 0 or iexiste2 is null) THEN
						IF TRIM(pNumTarjeta) <> '' THEN
							select {+index (intercard:tarjeta, 144_89)} nvl(count(numtarjeta),0), nvl(numcliente,0) into iexiste3, vnumcte from intercard:tarjeta where numtarjeta = pNumTarjeta group by numcliente;
							IF (iexiste3 = 0 or iexiste3 is null) then
								LET cCodRet = '00115';
								RETURN cCodRet;
							END IF;
						ELSE
							LET cCodRet = '00100';
							RETURN cCodRet;
						END IF;	
					END IF;
				END IF;
			ELIF TRIM(pNumTarjeta) <> '' THEN
				select {+index (intercard:tarjeta, 144_89)} nvl(count(numtarjeta),0), nvl(numcliente,0) into iexiste3, vnumcte from intercard:tarjeta where numtarjeta = pNumTarjeta group by numcliente;
				IF (iexiste3 = 0 or iexiste3 is null) then
					LET cCodRet = '00115';
					RETURN cCodRet;
				END IF;
			END IF;
			IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexiste3 is null) THEN
				LET cCodRet = '00112';
				RETURN cCodRet;
			END IF;		
		END IF;
	END IF;		
	if vnumcte = '' or vnumcte is null  then
		LET vnumcte  = pNumclt;
	END IF;

	-- Eventos que requieren confirmaciÃÆÃÂ³n se registran como temporales. JGP-17/09/2012
	IF pIdMsj IN ('POS_DEBS','POS_CREDS','ATM_DEBS','ATM_CREDS','POS_DEBE','POS_CREDE','ATM_DEBE','ATM_CREDE') THEN -- Posible MigraciÃÆÃÂ³n a Tabla
		LET vtransaction_id ='PENDIENTE';
	ELSE
		LET vtransaction_id = NULL;
	END IF;	

	IF pTipoproc = '1' THEN
		IF pIdMsj = 'OFI_AVSMS' THEN
		
			IF NOT EXISTS(SELECT  {+AVOID_FULL(bdimnsj:"informix".mnsjr_trx_online)} cliente FROM bdimnsj:"informix".mnsjr_trx_online WHERE cliente = vnumcte AND id_mensaje = pIdMsj AND celular_alterno = pcelular_alterno AND fecha_hora_registro >= today) THEN
				INSERT INTO bdimnsj:"informix".mnsjr_trx_online
				(tipo_mensaje, id_mensaje,id_plantilla,cliente, cuenta, tarjeta, transaction_id, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,		
				string4, string5, string6, string7, string8, string9, string10, correo_alterno, celular_alterno, 
				importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
				VALUES
				(pTipoMsj, pIdMsj,pIdPlantilla,vnumcte, pNumcta, pNumTarjeta, vtransaction_id, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10,
				pcorreo_alterno, pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2 );
			END IF;
		ELSE
			INSERT INTO bdimnsj:"informix".mnsjr_trx_online
				(tipo_mensaje, id_mensaje,id_plantilla,cliente, cuenta, tarjeta, transaction_id, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,		
				string4, string5, string6, string7, string8, string9, string10, correo_alterno, celular_alterno, 
				importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
				VALUES
				(pTipoMsj, pIdMsj,pIdPlantilla,vnumcte, pNumcta, pNumTarjeta, vtransaction_id, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10,
				pcorreo_alterno, pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2 );
		END IF;
	ELSE
		
		INSERT INTO bdimnsj:"informix".mnsjr_trx_batch
		(tipo_mensaje, id_mensaje,id_plantilla,cliente, cuenta, tarjeta, transaction_id, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,	
		string4, string5, string6, string7, string8, string9, string10, correo_alterno, celular_alterno, 
		importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
		VALUES
		(pTipoMsj, pIdMsj,pIdPlantilla, vnumcte, pNumcta, pNumTarjeta, vtransaction_id, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10,
		pcorreo_alterno, pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2 );
	 
	END IF;
		
END;	
RETURN 	cCodRet;
END PROCEDURE;