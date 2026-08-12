Create Procedure "informix".sp_generareporte(pProducto char(4))

    Returning char(5)

    Define sql_err INTEGER;
    Define cNumSuc 	CHAR(5);
    Define cNumProducto CHAR(5);
    Define mSaldoAcumuladoD1 MONEY(18,2);
    Define iTotalClientesD1 INT;
    Define iTotalCuentasActiD1 INT;
    Define tFechaD1 DATE;
    Define mSaldoAcumuladoD2 MONEY(18,2);
    Define iTotalClientesD2 INT;
    Define iTotalCuentasActiD2 INT;
    Define tFechaD2 DATE;
    Define mSaldoAcumuladoD3 MONEY(18,2);
    Define iTotalClientesD3 INT;
    Define iTotalCuentasActiD3 INT;
    Define tFechaD3 DATE;
    Define mSaldoAcumuladoD4 MONEY(18,2);
    Define iTotalClientesD4 INT;
    Define iTotalCuentasActiD4 INT;
    Define tFechaD4 DATE;
    Define mSaldoAcumuladoD5 MONEY(18,2);
    Define iTotalClientesD5 INT;
    Define iTotalCuentasActiD5 INT;
    Define tFechaD5 DATE;
    Define mSaldoAcumuladoD6 MONEY(18,2);
    Define iTotalClientesD6 INT;
    Define iTotalCuentasActiD6 INT;
    Define tFechaD6 DATE;
    Define mSaldoAcumuladoD0 MONEY(18,2);
    Define iTotalClientesD0 INT;
    Define iTotalCuentasActiD0 INT;
    Define nCont INT;
    Define tFechaD0 DATE;
    Define cNombreArchivo CHAR(20);
    Define vsql CHAR(250);
    Define vcodret CHAR(5);
    Define tFecha_hoy DATE;

    Let vcodret='00000';
    Let sql_err=0;
    Let cNumSuc ='';
    Let cNumProducto ='';
    Let mSaldoAcumuladoD1 =0;
    Let iTotalClientesD1 =0;
    Let iTotalCuentasActiD1 =0;
    Let tFechaD1 = '';
    Let mSaldoAcumuladoD2 =0;
    Let iTotalClientesD2 =0;
    Let iTotalCuentasActiD2 =0;
    Let tFechaD2 = '';
    Let mSaldoAcumuladoD3 =0;
    Let iTotalClientesD3 =0;
    Let iTotalCuentasActiD3 =0;
    Let tFechaD3 = '';
    Let mSaldoAcumuladoD4 =0;
    Let iTotalClientesD4 =0;
    Let iTotalCuentasActiD4 =0;
    Let tFechaD4 = '';
    Let mSaldoAcumuladoD5 =0;
    Let iTotalClientesD5 =0;
    Let iTotalCuentasActiD5 =0;
    Let tFechaD5 = '';
    Let mSaldoAcumuladoD6 =0;
    Let iTotalClientesD6 =0;
    Let iTotalCuentasActiD6 =0;
    Let tFechaD6 = '';
    Let mSaldoAcumuladoD0 =0;
    Let iTotalClientesD0 =0;
    Let iTotalCuentasactiD0 =0;
    Let nCont = 0;
    Let tFechaD0 = '';
    Let vsql = '';
    Let tFecha_hoy='';

    BEGIN
    
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			let vcodret = sql_err;
			RETURN vcodret;
		END IF;
	END EXCEPTION;
	
	-- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_GeneraReporte.out";
	-- TRACE ON;  
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
	
	-- Valido que el producto exista en el catalogo
	IF NOT EXISTS (SELECT producto FROM sc_producto WHERE producto = pProducto) OR (pProducto = '') THEN
		IF NOT EXISTS(SELECT cod_instrum FROM bdinvers:sv_instrum WHERE cod_instrum = pProducto) THEN
			Let vcodret = '100'; --Producto no existe
			RETURN vcodret;
		END IF;
	END IF;
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'sc_datosrepriesgos') THEN
        DROP TABLE sc_datosrepriesgos;
        CREATE RAW TABLE sc_datosrepriesgos(
            sucursal CHAR(4),  
            fecha DATE, 
            producto CHAR(4), 
            sdoacum MONEY (18,2),
            totcte INTEGER, 
            totcta INTEGER);
    ELSE
        CREATE RAW TABLE sc_datosrepriesgos(
            sucursal CHAR(4),  
            fecha DATE, 
            producto CHAR(4), 
            sdoacum MONEY (18,2),
            totcte INTEGER, 
            totcta INTEGER);
    END IF;

	SELECT fecha_hoy 
	  INTO tFecha_hoy
	  FROM sc_fechas
     WHERE empresa = '001';
	
    FOREACH
        SELECT numsuc,numproducto,saldoacumuladod1,totalclientesd1,
               totalcuentasactid1,fechad1,saldoacumuladod2,totalclientesd2,
               totalcuentasactid2,fechad2,saldoacumuladod3,totalclientesd3,
               totalcuentasactid3,fechad3,saldoacumuladod4,totalclientesd4,
               totalcuentasactid4,fechad4,saldoacumuladod5,totalclientesd5,
               totalcuentasactid5,fechad5,saldoacumuladod6,totalclientesd6,
               totalcuentasactid6,fechad6,saldoacumuladod0,totalclientesd0,
               totalcuentasactid0,fechad0 
          INTO cNumSuc,cNumProducto,mSaldoAcumuladoD1,iTotalClientesD1,
               iTotalCuentasActiD1,tFechaD1,mSaldoAcumuladoD2,iTotalClientesD2,
               iTotalCuentasActiD2,tFechaD2,mSaldoAcumuladoD3,iTotalClientesD3,
               iTotalCuentasActiD3,tFechaD3,mSaldoAcumuladoD4,iTotalClientesD4,
               iTotalCuentasActiD4,tFechaD4,mSaldoAcumuladoD5,iTotalClientesD5,
               iTotalCuentasActiD5,tFechaD5,mSaldoAcumuladoD6,iTotalClientesD6,
               iTotalCuentasActiD6,tFechaD6,mSaldoAcumuladoD0,iTotalClientesD0,
               iTotalCuentasActiD0,tFechaD0 				
          FROM sc_tblinfdiariesgos 
         WHERE numproducto = pProducto
                        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD1,cNumProducto,mSaldoAcumuladoD1,iTotalClientesD1,iTotalCuentasActiD1);
        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD2,cNumProducto,mSaldoAcumuladoD2,iTotalClientesD2,iTotalCuentasActiD2);
        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD3,cNumProducto,mSaldoAcumuladoD3,iTotalClientesD3,iTotalCuentasActiD3);
        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD4,cNumProducto,mSaldoAcumuladoD4,iTotalClientesD4,iTotalCuentasActiD4);
        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD5,cNumProducto,mSaldoAcumuladoD5,iTotalClientesD5,iTotalCuentasActiD5);
        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD6,cNumProducto,mSaldoAcumuladoD6,iTotalClientesD6,iTotalCuentasActiD6);
        
        INSERT INTO sc_datosrepriesgos(sucursal,fecha,producto,sdoacum,totcte,totcta)
        VALUES (cNumSuc,tFechaD0,cNumProducto,mSaldoAcumuladoD0,iTotalClientesD0,iTotalCuentasActiD0);
        
        LET nCont = nCont + 1;
        
        -- Realiza un statistics cada 50000 registros 
        IF nCont = 50000 THEN
            UPDATE STATISTICS MEDIUM FOR TABLE sc_datosrepriesgos;
            LET nCont = 0;
        END IF;
        
    END FOREACH;
		
    -- ALTER TABLE bdicheq:sc_datosrepriesgos TYPE (STANDARD);
    UPDATE STATISTICS MEDIUM FOR TABLE sc_datosrepriesgos;
    
    -- Formo nombre de archivo
    LET cNombreArchivo = TRIM(pProducto)||NVL( YEAR(tFecha_hoy)||LPAD(MONTH(tFecha_hoy),2,'0')||LPAD(DAY(tFecha_hoy),2,'0'),'')||'.txt';
    
    LET vsql = ''; -- Genero archivo con Unload
    LET  vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/temporal.unl '||
                'SELECT sucursal,fecha,producto,sdoacum,totcte,totcta ' ||
                'FROM sc_datosrepriesgos ORDER BY sucursal, fecha;" > /resplogifx/conciliachq/query2.sql';						
    SYSTEM vsql;
            
    Let vsql = ''; -- Ejecuto el unload
    Let vsql = 'dbaccess bdicheq /resplogifx/conciliachq/query2.sql';
    SYSTEM vsql;
    
    -- Le quita el ultimo | al archivo .txt y se renombra con estandar del nombre
    Let vsql = '';
    LET vsql = "sed 's/|$//g' /resplogifx/conciliachq/temporal.unl > /resplogifx/conciliachq/" || cNombreArchivo;
    SYSTEM vsql;
    
    LET vsql = '';  -- Se borra archivo temp una vez generado
    LET vsql = "rm -rf /resplogifx/conciliachq/temporal.unl";
    SYSTEM vsql;
    LET vsql = '';	
    
    -- Elimino la tabla de trabajo
    -- DROP TABLE sc_datosrepriesgos;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_tblinfdiariesgos_his;
		
    INSERT INTO sc_tblinfdiariesgos_his 
       (numsuc,aniosemana,numproducto,saldoacumuladod1,totalclientesd1,
        totalcuentasactid1,fechad1,saldoacumuladod2,totalclientesd2,
        totalcuentasactid2,fechad2,saldoacumuladod3,totalclientesd3,
        totalcuentasactid3,fechad3,saldoacumuladod4,totalclientesd4,
        totalcuentasactid4,fechad4,saldoacumuladod5,totalclientesd5,
        totalcuentasactid5,fechad5,saldoacumuladod6,totalclientesd6,
        totalcuentasactid6,fechad6,saldoacumuladod0,totalclientesd0,
        totalcuentasactid0,fechad0)
    SELECT numsuc,aniosemana,numproducto,saldoacumuladod1,totalclientesd1,
           totalcuentasactid1,fechad1,saldoacumuladod2,totalclientesd2,
           totalcuentasactid2,fechad2,saldoacumuladod3,totalclientesd3,
           totalcuentasactid3,fechad3,saldoacumuladod4,totalclientesd4,
           totalcuentasactid4,fechad4,saldoacumuladod5,totalclientesd5,
           totalcuentasactid5,fechad5,saldoacumuladod6,totalclientesd6,
           totalcuentasactid6,fechad6,saldoacumuladod0,totalclientesd0,
           totalcuentasactid0,fechad0 			
      FROM sc_tblinfdiariesgos 
     WHERE numproducto = pProducto;
    
    DELETE sc_tblinfdiariesgos 
     WHERE numproducto = pProducto;
		
	RETURN vcodret;
    
    END;
    
END PROCEDURE

DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Crea un informe en un archivo .txt apartir de la tabla sc_tblinfdiariesgos, la información se pasa a la tabla sc_tblinfdiariesgos_his y se elimina de sc_tblinfdiariesgos',
'Captacion',
'FECHA      : Marzo 2009',
'VERSION    : 20090312.1346',
'BD         : BDICHEQ',
'LLAMADO    : Se ejecuta a partir del sp_reporteriesgos ',
'**********************************************',
'MODIFICO   : ANTONIO BASTIDAS',
'DESCRIPCION: optimizar la duración del proceso',
'FECHA      : Noviembre 2009',
'VERSION    : 20091124.1832';

CREATE PROCEDURE "informix".sp_consultainfocteretieneisr ( pNumCte CHAR(20), pCuenta CHAR(20), pAnio SMALLINT, pTipo SMALLINT )
RETURNING
	CHAR(6)        AS CodRet,
	CHAR(60)       AS Mensaje,
	CHAR(2)        AS TipoPersona,
	CHAR(104)      AS Nombre,
	CHAR(20)       AS Cuenta,
	CHAR(13)       AS RFC,
	CHAR(20)       AS CURP,
	DECIMAL(16, 2) AS InteresNomTotal,
	DECIMAL(16, 2) AS InteresReal,
	DECIMAL(16, 2) AS Perdida,
	DECIMAL(16, 2) AS InteresNomExento,
	DECIMAL(16, 2) AS RetenInteres,
	CHAR(60)       AS RazonSocialRetenedor,
	CHAR(13)       AS RFCRetenedor,
	CHAR(104)      AS NombreRepLegal,
	CHAR(13)       AS RepLegalISR,
	CHAR(20)       AS CURPRepLegal;

	-- DECLARACION DE VARIABLES
	DEFINE cCodRet				CHAR(6);
	DEFINE cTipPer				CHAR(2);
	DEFINE cNumCte				CHAR(20);
	DEFINE cCuenta				CHAR(20);
	DEFINE dIntNominalTot		DECIMAL(16, 2);
	DEFINE dInteresReal			DECIMAL(16, 2);
	DEFINE dPerdida				DECIMAL(16, 2);
	DEFINE dIntNomExento		DECIMAL(16, 2);
	DEFINE dRetenInteres		DECIMAL(16, 2);
	DEFINE cNombreCliente 		CHAR(104);	
	DEFINE cRazonSocialReten	CHAR(60);
	DEFINE cRfcAlterno	 		CHAR(13);
	DEFINE cRfc			 		CHAR(13);
	DEFINE cCurp				CHAR(20);
	DEFINE cRfcRetenedor		CHAR(13);
	DEFINE cNomRepLegalISR		CHAR(104);
	DEFINE cRfcRepLegalISR		CHAR(13);
	DEFINE cCurpRepLegalISR		CHAR(20);
	
	DEFINE iNRows 				INTEGER;
	DEFINE iSqlErr 				INTEGER;
	DEFINE cMensaje 			CHAR(60);
	
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet 			= '000000';
	LET cTipPer 			= '';
	LET cNumCte				= '';
	LET cCuenta				= '';
	LET dIntNominalTot		= 0.00;
	LET dInteresReal		= 0.00;
	LET dPerdida			= 0.00;
	LET dIntNomExento		= 0.00;
	LET dRetenInteres		= 0.00;
	LET iNRows 				= 0;
	LET cMensaje			= 'EJECUCIÓN REALIZADA EXITOSAMENTE';
	LET cNombreCliente		= '';
	LET cRfcAlterno			= '';
	LET cRfc				= '';
	LET cCurp				= '';
	LET cRfcRetenedor		= '';
	LET cNomRepLegalISR		= '';
	LET cRfcRepLegalISR		= '';
	LET cCurpRepLegalISR	= '';
	LET iSqlErr 			= 0;
	LET cRazonSocialReten	= '';
	
	SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

	 -- SET DEBUG FILE TO "/home/sysifx/vlv/sp_consultainfocteretieneisr.out";
	 -- TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'ERROR NO CONTROLADO, VERIFIQUE';
			RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(NVL(cTipPer, '')), TRIM(NVL(cNombreCliente, '')), TRIM(NVL(cCuenta, '')),
			       TRIM(NVL(cRfcAlterno, '')), TRIM(NVL(cCurp, '')), NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00),
				   NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00), NVL(dRetenInteres, 0.00), TRIM(NVL(cRazonSocialReten, '')),
				   TRIM(NVL(cRfcRetenedor, '')), TRIM(NVL(cNomRepLegalISR, '')), TRIM(NVL(cRfcRepLegalISR, '')),
				   TRIM(NVL(cCurpRepLegalISR, ''));
		END IF;
	END EXCEPTION;
    
    IF pTipo = 1 THEN
   
		--  SE VALIDAN LOS PARAMETROS DE ENTRADA
		IF NVL(pNumCte, '') = '' OR NVL(pAnio, 0) = 0 THEN
			LET cCodRet = '000002';
			LET cMensaje = 'FALTAN PARAMETROS PARA LA EJECUCIÓN DEL MODO: CUENTAS';

			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       dIntNominalTot, dInteresReal, dPerdida, dIntNomExento, dRetenInteres, TRIM(cRazonSocialReten),
				   TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR), TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
		END IF
		
		--  SE CONSULTAN LAS CUENTAS RETENIDAS DEL CLIENTE EN UN AÑO ESPECIFICO
		FOREACH
			SELECT TRIM(cuenta),interes_nominal_total, interes_real, perdida, interes_nominal_exento, reten_interes
			INTO cCuenta, dIntNominalTot, dInteresReal, dPerdida, dIntNomExento, dRetenInteres
			FROM bdicheq: 'informix'.sc_retenisr
			WHERE num_cte = TRIM(pNumCte)
			AND ejercicio = pAnio
			
			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       dIntNominalTot, dInteresReal, dPerdida, dIntNomExento, dRetenInteres, TRIM(cRazonSocialReten),
				   TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR), TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR) WITH RESUME;
			
		END FOREACH
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000005'; -- NO SE OBTUVO INFORMACION.
			LET cMensaje = 'CLIENTE NO TIENE CUENTAS RETENIDAS PARA EL AÑO RECIBIDO';

			RETURN cCodRet, TRIM(cMensaje), TRIM(NVL(cTipPer, '')), TRIM(NVL(cNombreCliente, '')), TRIM(NVL(cCuenta, '')),
				   TRIM(NVL(cRfcAlterno, '')), TRIM(NVL(cCurp, '')), NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00),
				   NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00), NVL(dRetenInteres, 0.00), TRIM(NVL(cRazonSocialReten, '')),
				   TRIM(NVL(cRfcRetenedor, '')), TRIM(NVL(cNomRepLegalISR, '')), TRIM(NVL(cRfcRepLegalISR, '')),
				   TRIM(NVL(cCurpRepLegalISR, ''));
		END IF;
		
	ELIF pTipo = 2 THEN
	
		--  SE VALIDAN LOS PARAMETROS DE ENTRADA
		IF NVL(pNumCte, '') = '' OR NVL(pCuenta, '') = '' OR NVL(pAnio, 0) = 0 THEN
			LET cCodRet = '000002';
			LET cMensaje = 'FALTAN PARAMETROS PARA LA EJECUCIÓN DEL MODO: REPORTE';
			
			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       dIntNominalTot, dInteresReal, dPerdida, dIntNomExento, dRetenInteres, TRIM(cRazonSocialReten),
				   TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR), TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
		END IF		
		
		SELECT TRIM(numcte), TRIM(tpo_persona), TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) || ' ' || TRIM(razon_social), TRIM(rfc), TRIM(rfc_alterno)
		INTO cNumCte, cTipPer, cNombreCliente, cRfc, cRfcAlterno
		FROM bdinteg: 'informix'.si_cliente
		WHERE empresa = '001'
		AND numcte = pNumCte;
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000004';
			LET cMensaje = 'CLIENTE NO EXISTE';
			
			RETURN cCodRet, TRIM(cMensaje), TRIM(NVL(cTipPer, '')), TRIM(NVL(cNombreCliente, '')), TRIM(NVL(cCuenta, '')),
				   TRIM(NVL(cRfcAlterno, '')), TRIM(NVL(cCurp, '')), NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00),
				   NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00), NVL(dRetenInteres, 0.00), TRIM(NVL(cRazonSocialReten, '')),
				   TRIM(NVL(cRfcRetenedor, '')), TRIM(NVL(cNomRepLegalISR, '')), TRIM(NVL(cRfcRepLegalISR, '')),
				   TRIM(NVL(cCurpRepLegalISR, ''));
		END IF
		
		IF NVL(cRfcAlterno, '') = '' THEN
			LET cRfcAlterno = cRfc;
		END IF
		
		IF cTipPer = '01' THEN
			
			SELECT NVL(curp, '') INTO cCurp
			FROM bdinteg: 'informix'.si_ctepf
			WHERE numcte = cNumCte;
			
		END IF
		
	 -- PARA GENERAR EL REPORTE-CONSTANCIA.
		SELECT TRIM(cuenta), interes_nominal_total, interes_real, perdida, interes_nominal_exento, reten_interes
		INTO cCuenta, dIntNominalTot, dInteresReal, dPerdida, dIntNomExento, dRetenInteres
		FROM bdicheq: 'informix'.sc_retenisr
		WHERE num_cte = pNumCte
		AND cuenta = pCuenta
		AND ejercicio = pAnio;
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000005'; -- NO SE OBTUVO INFORMACION.
			LET cMensaje = 'CLIENTE NO TIENE CUENTAS RETENIDAS PARA EL AÑO RECIBIDO';

			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(NVL(cCuenta, '')), TRIM(cRfcAlterno), TRIM(cCurp),
			       NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00), NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00),
				   NVL(dRetenInteres, 0.00), TRIM(cRazonSocialReten), TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR),
				   TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
		END IF
		
		-- CONSULTAMOS LA RAZON SOCIAL DEL RETENEDOR Y EL RFC DEL RETENEDOR.
		SELECT TRIM(razon_social), TRIM(rfc) INTO cRazonSocialReten, cRfcRetenedor
		FROM  bdinteg: 'informix'.si_empresas
		WHERE empresa = '001';
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'NO EXISTE LA INFORMACION PARA LA EMPRESA RETENEDORA';

			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00), NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00),
				   NVL(dRetenInteres, 0.00), TRIM(NVL(cRazonSocialReten, '')), TRIM(NVL(cRfcRetenedor, '')), 
				   TRIM(NVL(cNomRepLegalISR, '')), TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
		END IF
		
		SELECT TRIM(valor) INTO cNomRepLegalISR 
		FROM bdinteg: 'informix'.si_param 
		WHERE cod_param = '131';
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'NO EXISTE LA INFORMACION PARA EL REPRESENTANTE LEGAL';

			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00), NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00),
				   NVL(dRetenInteres, 0.00), TRIM(cRazonSocialReten), TRIM(cRfcRetenedor), TRIM(NVL(cNomRepLegalISR, '')),
				   TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
		END IF
		
		SELECT TRIM(valor) INTO cRfcRepLegalISR 
		FROM bdinteg: 'informix'.si_param 
		WHERE cod_param = '132';
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'NO EXISTE LA INFORMACION PARA EL REPRESENTANTE LEGAL';

			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00), NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00),
				   NVL(dRetenInteres, 0.00), TRIM(cRazonSocialReten), TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR),
				   TRIM(NVL(cRfcRepLegalISR, '')), TRIM(cCurpRepLegalISR);
		END IF
		
		SELECT TRIM(valor) INTO cCurpRepLegalISR 
		FROM bdinteg: 'informix'.si_param 
		WHERE cod_param = '133';
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'NO EXISTE LA INFORMACION PARA EL REPRESENTANTE LEGAL';

			RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			       NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00), NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00),
				   NVL(dRetenInteres, 0.00), TRIM(cRazonSocialReten), TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR),
				   TRIM(cRfcRepLegalISR), TRIM(NVL(cCurpRepLegalISR, ''));
		END IF
		
		RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			   NVL(dIntNominalTot, 0.00), NVL(dInteresReal, 0.00), NVL(dPerdida, 0.00), NVL(dIntNomExento, 0.00),
			   NVL(dRetenInteres, 0.00), TRIM(cRazonSocialReten), TRIM(cRfcRetenedor), TRIM(cNomRepLegalISR),
			   TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
	ELSE
	
		LET cCodRet = '000001';
		LET cMensaje = 'TIPO DE EJECUCIÓN DESCONOCIDA';
		
		RETURN cCodRet, TRIM(cMensaje), TRIM(cTipPer), TRIM(cNombreCliente), TRIM(cCuenta), TRIM(cRfcAlterno), TRIM(cCurp),
			   dIntNominalTot, dInteresReal, dPerdida, dIntNomExento, dRetenInteres, TRIM(cRazonSocialReten), TRIM(cRfcRetenedor),
			   TRIM(cNomRepLegalISR), TRIM(cRfcRepLegalISR), TRIM(cCurpRepLegalISR);
	END IF
END;
END PROCEDURE
DOCUMENT
'AUTOR: Valentin López',
'FECHA: 12 de Diciembre del 2011',
'DESCRIPCION: .Procedimiento que consulta la informacion del cliente, ya sea cliente fisico o moral que cuente con retención del ISR.',
'VERSION: 20111212.0904',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_validaautorizados( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    
    DEFINE vFechaHoy        DATE;
    DEFINE vFechaAnt        DATE;
    DEFINE vpri_dia_mes     DATE;
    DEFINE vfecha_ini       DATE;
    DEFINE vfecha_fin       DATE;
    DEFINE vCuenta          CHAR(20);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vProducto        CHAR(4);   
    DEFINE vfechaalta       DATE;
    DEFINE vNoFirmantes     SMALLINT;
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(6);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    
    LET vFechaHoy      = '';
    LET vFechaAnt      = '';
    LET vpri_dia_mes   = '';
    LET vfecha_ini     = '';
    LET vfecha_fin     = '';
    LET vCuenta        = '';   
    LET vNumCliente    = '';
    LET vStatusCta     = '';
    LET vProducto      = '';
    LET vFechaAlta     = '';
    LET vNoFirmantes   = 0;
    LET vsql           = '';
    LET vstmt          = '';
    LET vfecha         = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validaautorizados.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validaautorizados.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vFechaHoy, vFechaAnt, vpri_dia_mes
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
     
    -- // OBTIENE LAS CUENTAS APERTURADAS EL DIA ANTERIOR
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.producto, noc.fecha_alta 
          INTO vCuenta, vNumCliente, vStatusCta, vProducto, vFechaAlta 
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta = noc.cuenta
           AND mae.status_cta NOT IN('2','7')
           AND mae.producto NOT IN('1200','1600','2200','2300','9900','9901')
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta 
           AND noc.fecha_alta BETWEEN vfecha_ini AND vfecha_fin
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
            LET vEnTransacc = 1;
            BEGIN WORK;
        END IF;    
        
        SELECT COUNT(*)
          INTO vNoFirmantes
          FROM bdicheq:"informix".sc_firmantes
         WHERE cuenta = vCuenta;
         
        IF vNoFirmantes > 2 OR vNoFirmantes < 1 THEN
            INSERT INTO sc_ctasfirmantes(numcte, producto, cuenta, status_cta, no_firmantes, fecha_alta)
            VALUES(vNumCliente, vProducto, vCuenta, vStatusCta, vNoFirmantes, vFechaAlta);
            
            LET vContador2 = vContador2 + 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF vEnTransacc = 1 THEN
        LET vEnTransacc = 0;
        COMMIT WORK;
    END IF;
    
    IF vContador2 > 0 THEN
        LET vfecha = TO_CHAR(vfecha_fin, '%Y%m');
        
        -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/AutorizadosCaptacion_'||vfecha||'.txt '||
                   'SELECT numcte, producto, cuenta, status_cta, no_firmantes, fecha_alta '||
                   'FROM sc_ctasfirmantes WHERE fecha_alta BETWEEN '''||vfecha_ini||''' AND '''||vfecha_fin||''' " > /resplogifx/conciliachq/autorizados.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/autorizados.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
    END IF;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
    
END PROCEDURE;