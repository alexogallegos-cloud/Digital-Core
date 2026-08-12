CREATE PROCEDURE "informix".sp_generarptcancel
(
pEmpresa	CHAR(3),
pEjecutivo	CHAR(8),
pGerente	CHAR(8),
pCliente	CHAR(20),
pCuenta 	CHAR(20) 
)
RETURNING
	CHAR(5) 		AS cod_ret,
	CHAR(80) 		AS descripcion,
	CHAR(10)		AS fecha,
	CHAR(45)		AS sucursal,
	CHAR(107)		AS nombre_cte,
	CHAR(20)		AS num_cte,
	CHAR(1)			AS tipo_cta,
	CHAR(20)		AS num_cta,
	CHAR(30)		AS num_identif,
	CHAR(40)		AS motivo_cancel,
	CHAR(22)		AS folio_cancel,
	CHAR(107)		AS nombre_firma_cte,
	CHAR(8)			AS codigo_firma_prom,
	CHAR(45)		AS nombre_firma_prom,
	CHAR(8)			AS codigo_firma_gte,
	CHAR(40)		AS nombre_firma_gte;
	

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(5);
    DEFINE cMensajeRet		CHAR(80);
	DEFINE cFecha			CHAR(10);
	DEFINE cSucursal		CHAR(45);
	DEFINE cNombreCte		CHAR(107);
	DEFINE cTipoCta			CHAR(1);
	DEFINE cNumCta			CHAR(20);
	DEFINE cNumIdentif		CHAR(30);
	DEFINE cMotivoCancel	CHAR(40);
	DEFINE cFolioCancel		CHAR(22);
	DEFINE cNombreFirmaCte	CHAR(107);
	DEFINE cCodigoFirmaProm	CHAR(8);
	DEFINE cNombreFirmaProm	CHAR(45);
	DEFINE cCodigoFirmaGte	CHAR(8);
	DEFINE cNombreFirmaGte	CHAR(40);
	DEFINE vtipopersona	    CHAR(2);
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
	LET cCodRet				= "00000";
	LET cMensajeRet			= "PROCESO EXITOSO";
	LET cFecha				= "";
	LET cSucursal			= "";
	LET cNombreCte			= "";
	LET cTipoCta			= "";
	LET cNumCta				= "";
	LET cNumIdentif			= "";
	LET cMotivoCancel		= "";
	LET cFolioCancel		= "";
	LET cNombreFirmaCte		= "";
	LET cCodigoFirmaProm	= "";
	LET cNombreFirmaProm	= "";
	LET cCodigoFirmaGte		= "";
	LET cNombreFirmaGte		= "";
	LET vtipopersona		= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, cFecha, cSucursal, cNombreCte, pCliente, cTipoCta, cNumCta, cNumIdentif, cMotivoCancel, cFolioCancel, cNombreFirmaCte, cCodigoFirmaProm, cNombreFirmaProm, cCodigoFirmaGte, cNombreFirmaGte;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	/*SET DEBUG FILE TO "/resplogifx/conciliachq/sp_generarptcancel.out";
	TRACE ON;*/

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pEmpresa,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pCliente,'') = '' OR NVL(pCuenta,'') = '' THEN
		LET cCodRet = '00007';
				
		SELECT descripcion
		INTO cMensajeRet
		FROM bdinteg:"informix".si_codret
		WHERE codigo_retorno = '007'
		AND sistema = '20';
	ELSE		
		-- VALIDA QUE SE ENCUENTRE EN EL CATALOGO DE CTAS CANCELADAS E OBTIENE LA DESCRIPCION DEL MOTIVO Y EL FOLIO
		SELECT t1.descripcion, t2.folio_cancelacion
		INTO cMotivoCancel, cFolioCancel
		FROM bdicheq: "informix".sc_motivocancel t1, bdicheq: "informix".sc_ctacancelada t2
		WHERE t1.clave = t2.motivo
		AND t2.cuenta = pCuenta;
	
		IF NVL(cFolioCancel,"") = "" THEN
			LET cCodRet = '00080';
			
			SELECT descripcion
			INTO cMensajeRet
			FROM bdinteg:"informix".si_codret
			WHERE codigo_retorno = '80';
		ELSE
			-- OBTIENE LA FECHA DE HOY DEL SISTEMA
			SELECT LPAD(DAY(fecha_hoy),2,"0") || "/" || LPAD(MONTH(fecha_hoy),2,"0")|| "/" || YEAR(fecha_hoy)
			INTO cFecha
			FROM bdicheq: "informix".sc_fechas;
			
			-- OBTIENE LA CLAVE Y EL NOMBRE DE LA SUCURSAL, Y EL NOMBRE DEL GERENTE
			SELECT t1.sucursal || " " || t2.nombre, t1.nombre, t2.gerente
			INTO cSucursal, cNombreFirmaProm, cNombreFirmaGte
			FROM bdinteg: "informix".si_ejecut t1, bdinteg: "informix".si_sucursales t2
			WHERE t1.ejecutivo = pEjecutivo
			AND t1.sucursal = t2.sucursal;
			
			-- OBTIENE EL NOMBRE DEL CLIENTE
			SELECT TRIM(nombre1) || " " || TRIM(nombre2) || " " || TRIM(apell_paterno) || " " || TRIM(apell_materno), tpo_persona
			INTO cNombreCte, vtipopersona
			FROM bdinteg: "informix".si_cliente WHERE empresa = pEmpresa AND numcte = pCliente;
			
			IF vtipopersona = '02' THEN
			SELECT TRIM (pm.nombre_corto) || " " || TRIM (su.descripcion)
				INTO  cNombreCte
				FROM bdinteg:"informix".si_ctepm pm,
				bdinteg:"informix".si_sufijos su
				WHERE pm.numcte = pCliente
				AND su.codigo =pm.sufijo;
								
			END IF

			LET cNombreFirmaCte = cNombreCte;
			
			--  OBTIENE EL TIPO DE PRODUCTO
			SELECT "1"
			INTO cTipoCta
			FROM bdicheq: "informix".sc_maechq t1,  bdicheq: "informix".sc_producto t2
			WHERE t1.cuenta = pCuenta
			AND t1.producto = t2.producto;
			
			LET cTipoCta = NVL(cTipoCta,"0");
			
			LET cNumCta = pCuenta;
			
			-- OBTIENE LA IDENTIFICACION
			SELECT numidentifi
			INTO cNumIdentif
			FROM bdinteg: "informix".si_ctepf 
			WHERE empresa = pEmpresa AND numcte = pCliente;
			
			LET cCodigoFirmaProm = pEjecutivo;
			
			-- VALIDA SI VIENE VACIO SU ORIGEN ES DE CENTRAL
			IF NVL(pGerente,"") = "" THEN
				LET cCodigoFirmaGte = "";
			-- VALIDA SI TRAE DATO SU ORIGEN ES DE SUCURSAL
			ELSE
				LET cCodigoFirmaGte = pGerente;
				LET cNombreFirmaGte = "";
			END IF
			
		END IF
	END IF	
	
	RETURN cCodRet, cMensajeRet, NVL(cFecha,""), NVL(cSucursal,""), NVL(cNombreCte,""), NVL(pCliente,""), NVL(cTipoCta,""), NVL(cNumCta,""), NVL(cNumIdentif,""), NVL(cMotivoCancel,""), NVL(cFolioCancel,""), NVL(cNombreFirmaCte,""), NVL(cCodigoFirmaProm,""),  NVL(cNombreFirmaProm,""), NVL(cCodigoFirmaGte,""), NVL(cNombreFirmaGte,"");

	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener la informacion de la cuenta cancelada de captacion', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2012',
'VERSION: 20120801.1139';

CREATE PROCEDURE "informix".sp_cargosideesp(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcodret_cargo    CHAR(5);
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vaniomes         CHAR(6);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vusuario         CHAR(8);
    DEFINE vmoneda          CHAR(2);
    DEFINE vtranret         CHAR(4);
    DEFINE vfechoy          DATE;
    DEFINE vsdodisp         DECIMAL(18,2);
    DEFINE vmontoret        DECIMAL(18,2);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vcodret_cargo = '';
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vaniomes     = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '';
    LET vusuario     = 'informix';
    LET vmoneda      = '01';
    LET vtranret     = '';
    LET vfechoy      = '';
    LET vsdodisp     = 0.00;
    LET vmontoret    = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cargosideesp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cargosideesp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxcargaride') THEN
        DROP TABLE "informix".ctasxcargaride;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcargaride
      (
        aniomes     char(4)     not null,
        cuenta      char(20)    not null,
        sucursal    char(4)     not null,
        monto       money(18,2) not null,
        transacc    char(4)     not null,
        descripcion char(40)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxcargaride ON "informix".ctasxcargaride(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cargos_esp_ide.unl DELIMITER ''","'' INSERT INTO ctasxcargaride" > /resplogifx/conciliachq/cargoside.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargoside.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcargaride;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT aniomes, cuenta, sucursal, monto, transacc, descripcion
          INTO vaniomes, vcuenta, vsucursal, vmonto, vtransacc, vdescripcion
          FROM ctasxcargaride
         ORDER BY aniomes, cuenta
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        CALL cargo_ref( pempresa,       -- empresa
                        vsucursal,      -- sucursal
                        vusuario,       -- usuario
                        vtransacc,      -- transaccion
                        '0000',         -- transacc suc
                        vfolio,         -- folio
                        vcuenta,        -- cuenta
                        0,              -- cheque
                        vmonto,         -- monto
                        vmoneda,        -- divisa
                        vdescripcion,   -- referencia
                        ' ',            -- num tarjeta
                        vusuario )      -- autoriza
        RETURNING vcodret_cargo, vtranret, vfechoy, vsdodisp, vmontoret;
        
        IF vcodret_cargo = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            BEGIN WORK;
        ELSE 
            ROLLBACK WORK;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vaniomes      = '';
        LET vcuenta       = '';
        LET vsucursal     = '';
        LET vmonto        = 0.00;
        LET vtransacc     = '';
        LET vdescripcion  = '';
        LET vcodret_cargo = '';
        LET vtranret      = '';
        LET vfechoy       = '';
        LET vsdodisp      = 0.00;
        LET vmontoret     = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;