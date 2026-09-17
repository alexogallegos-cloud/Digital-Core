CREATE PROCEDURE "informix".sp_generarptcancel_web
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
	
	RETURN cCodRet, NVL(cMensajeRet,''), NVL(cFecha,""), NVL(cSucursal,""), NVL(cNombreCte,""), NVL(pCliente,""), NVL(cTipoCta,""), NVL(cNumCta,""), NVL(cNumIdentif,""), NVL(cMotivoCancel,""), NVL(cFolioCancel,""), NVL(cNombreFirmaCte,""), NVL(cCodigoFirmaProm,""),  NVL(cNombreFirmaProm,""), NVL(cCodigoFirmaGte,""), NVL(cNombreFirmaGte,"");
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener la informacion de la cuenta cancelada de captacion', 
'AUTOR: Mohamed Carreon ',
'FECHA: Agosto 2012',
'VERSION: 20120801.1139';

CREATE PROCEDURE "informix".sp_ctaportabilidadbancoppel_web( pCuenta CHAR(11))
RETURNING CHAR(5)    AS  cCodRet,
CHAR(2)    AS  ESTATUS_PORTABILIDAD;

    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5); 
    DEFINE cEstatusPorta    CHAR(2);

    LET cCodRet			= '00000';
    LET cCodRet2		= '00000';
    LET cEstatusPorta   ='';

    BEGIN
    
    --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
    --- TRACE ON;    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 
    
    SELECT  ESTATUS
    INTO cEstatusPorta
    FROM  bdicheq:"informix".sc_portabilidadnomina 
    WHERE cuenta_abono = pCuenta 
    AND SECUENCIA=(SELECT MAX(SECUENCIA) 
                    FROM bdicheq:"informix".sc_portabilidadnomina 
                     WHERE cuenta_abono = pCuenta);
    
    RETURN cCodRet,NVL(cEstatusPorta,'00');
   END
END PROCEDURE;