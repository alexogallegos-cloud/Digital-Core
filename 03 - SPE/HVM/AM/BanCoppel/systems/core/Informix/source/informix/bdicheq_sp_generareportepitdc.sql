CREATE PROCEDURE "informix".sp_generareportepitdc(pdFecha DATE,pcSucursal CHAR(4),pcTipo CHAR(1),piRegistro INTEGER)
RETURNING CHAR(5),CHAR(40),CHAR(40),CHAR(25),CHAR(16),CHAR(16),MONEY(16,2),CHAR(4),CHAR(20),MONEY(16,2),MONEY(16,2),INTEGER;
--Definicion de variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cSucursal CHAR(40);
DEFINE cRegion CHAR(40);
DEFINE cBanco CHAR(25);
DEFINE cNumTarjeta CHAR(16);
DEFINE cSecuencia CHAR(16);
DEFINE mImporte MONEY(16,2);
DEFINE mImpCargo MONEY(16,2);
DEFINE mImpEfectivo MONEY(16,2);
DEFINE cTransaccion CHAR(4);
DEFINE cCuenta CHAR(20);
DEFINE iContEfec INTEGER;
DEFINE iContCargo INTEGER;
DEFINE iContador INTEGER;
DEFINE cReferencia CHAR(6);
DEFINE vconsmovhis      CHAR(10);
DEFINE vconsmovhisold   CHAR(10);

--Inicializacion de variables
LET iSqlErr = 0;
LET cCodRet = '00001';
LET cSucursal = '';
LET cRegion = '';
LET cBanco = '';
LET cNumTarjeta = '';
LET cSecuencia = '';
LET mImporte = 0;
LET mImpCargo = 0;
LET mImpEfectivo = 0;
LET cTransaccion = '';
LET cCuenta = '';
LET iContEfec = 0;
LET iContCargo = 0;
LET iContador = 0;
LET cReferencia = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','','',0,'','',0,0,0;
		END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_GeneraReportePITDC.out";
--	TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

	--Se obtiene el nombre de la sucursal y de la region.
	
	SELECT suc.nombre,reg.nombre
	INTO cSucursal,cRegion
	FROM bdinteg:"informix".si_sucursales suc
	INNER JOIN bdinteg:"informix".si_plazas plz ON plz.plaza = suc.plaza
	INNER JOIN bdinteg:"informix".si_regional reg ON reg.regional = plz.regional
	WHERE suc.sucursal = pcSucursal;

    SELECT valor
      INTO vconsmovhis
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vconsmovhisold
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';

	--Se valida el tipo de busqueda
	IF pcTipo = 1 THEN
		--Se obtiene el importe y cantidad de movimientos de efectivo
		
		SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
		INTO mImpEfectivo,iContEfec
		FROM bdicheq:"informix".sc_movdia
		WHERE empresa = '001' AND transacc = '1193'
		AND fech_alt = pdFecha
		AND sucursal = pcSucursal;

		--Se obtiene el importe y cantidad de movimientos de cargo
		
		SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
		INTO mImpCargo,iContCargo
		FROM bdicheq:"informix".sc_movdia
		WHERE empresa = '001' AND transacc = '1194'
		AND fech_alt = pdFecha
		AND sucursal = pcSucursal;

		--Contador de movimientos
		LET iContador = iContEfec + iContCargo;

		--Se obtiene la informacion diaria.
		
		FOREACH
			SELECT SKIP piRegistro referencia,folio_suc,monto_tot,transacc,cuenta,SUBSTR(referencia,1,6)
			INTO cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,cReferencia
			FROM bdicheq:"informix".sc_movdia
			WHERE empresa = '001' AND transacc IN ('1193','1194')
			AND fech_alt = pdFecha
			AND sucursal = pcSucursal
			ORDER BY folio_suc

			--Se obtiene el banco
			IF LENGTH (cNumTarjeta) = 15 THEN
				LET cReferencia = SUBSTR(cNumTarjeta,1,2);
				IF EXISTS (SELECT valor FROM bdisac:sac_param WHERE cod_param = cReferencia) THEN
					SELECT valor INTO cBanco FROM bdisac:sac_param WHERE cod_param = cReferencia;
				ELSE
					LET cCodRet = "00058";
				END IF;
			ELSE
			
			SELECT NVL(banco_prosa,'')
			INTO cBanco
			FROM bdicheq:"informix".sc_bines
			WHERE bin = cReferencia;
			end if;
			LET cCodRet = '00000';
			RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador WITH RESUME;
		END FOREACH;
	ELIF pcTipo = 2 THEN
			--Se obtiene el importe y cantidad de movimientos de efectivo
		if pdFecha >= vconsmovhis then
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpEfectivo,iContEfec
			FROM bdicheq:"informix".sc_movhis
			WHERE empresa = '001' AND transacc = '1193'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Se obtiene el importe y cantidad de movimientos de cargo
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpCargo,iContCargo
			FROM bdicheq:"informix".sc_movhis
			WHERE empresa = '001' AND transacc = '1194'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Contador de movimientos
			LET iContador = iContEfec + iContCargo;

		--Se obtiene la informacion historica.
		
		FOREACH
			SELECT SKIP piRegistro referencia,folio_suc,monto_tot,transacc,cuenta,SUBSTR(referencia,1,6)
			INTO cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,cReferencia
			FROM bdicheq:"informix".sc_movhis
			WHERE empresa = '001' AND transacc IN ('1193','1194')
			AND fech_alt = pdFecha
			AND sucursal = pcSucursal
			AND CANCELAD <> 'S'
			ORDER BY folio_suc

			--Se obtiene el banco
			
			IF LENGTH (cNumTarjeta) = 15 THEN
				LET cReferencia = SUBSTR(cNumTarjeta,1,2);
				IF EXISTS (SELECT valor FROM bdisac:sac_param WHERE cod_param = cReferencia) THEN
					SELECT valor INTO cBanco FROM bdisac:sac_param WHERE cod_param = cReferencia;
				ELSE
					LET cCodRet = "00058";
				END IF;
			ELSE
			SELECT NVL(banco_prosa,'')
			INTO cBanco
			FROM bdicheq:"informix".sc_bines
			WHERE bin = cReferencia;
			end if
			LET cCodRet = '00000';
			RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador WITH RESUME;
		END FOREACH;
		ELSE
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpEfectivo,iContEfec
			FROM bdicheq:"informix".sc_movhis_old
			WHERE empresa = '001' AND transacc = '1193'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Se obtiene el importe y cantidad de movimientos de cargo
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpCargo,iContCargo
			FROM bdicheq:"informix".sc_movhis_old
			WHERE empresa = '001' AND transacc = '1194'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Contador de movimientos
			LET iContador = iContEfec + iContCargo;

		--Se obtiene la informacion historica.
		
		FOREACH
			SELECT SKIP piRegistro referencia,folio_suc,monto_tot,transacc,cuenta,SUBSTR(referencia,1,6)
			INTO cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,cReferencia
			FROM bdicheq:"informix".sc_movhis_old
			WHERE empresa = '001' AND transacc IN ('1193','1194')
			AND fech_alt = pdFecha
			AND sucursal = pcSucursal
			AND CANCELAD <> 'S'
			ORDER BY folio_suc

			--Se obtiene el banco
			
			IF LENGTH (cNumTarjeta) = 15 THEN
				LET cReferencia = SUBSTR(cNumTarjeta,1,2);
				IF EXISTS (SELECT valor FROM bdisac:sac_param WHERE cod_param = cReferencia) THEN
					SELECT valor INTO cBanco FROM bdisac:sac_param WHERE cod_param = cReferencia;
				ELSE
					LET cCodRet = "00058";
				END IF;
			ELSE
			SELECT NVL(banco_prosa,'')
			INTO cBanco
			FROM bdicheq:"informix".sc_bines
			WHERE bin = cReferencia;
			end if
			LET cCodRet = '00000';
			RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador WITH RESUME;
		END FOREACH;
		END IF;
	END IF;
END;
END PROCEDURE
DOCUMENT
'Creado: Marcos Cuevas',
'Fecha: 10/Marzo/2011',
'Descripcion: Se crea para obtener la informacion para el reporte del PITDC';

CREATE PROCEDURE "informix".sp_obtenerdatos_edomovtos(	pNumCte CHAR(20), 
														pNumCta CHAR(20), 
														pProducto CHAR(4))
RETURNING
	CHAR(5) AS CodRetorno,
	CHAR(62) AS CampoSuc,
	CHAR(40) AS Gerente,
	VARCHAR(255) AS Mensaje1,
	VARCHAR(255) AS Mensaje2,
	VARCHAR(255) AS Mensaje3,
	VARCHAR(255) AS Mensaje4,
	VARCHAR(255) AS Mensaje5,
	VARCHAR(255) AS Mensaje6,
	VARCHAR(255) AS Avisos,
	VARCHAR(255) AS Informacion,
	VARCHAR(255) AS Mensaje7;

	-- DEFINICION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombreSuc CHAR(40);
	DEFINE cSiglasEstado CHAR(4);
	DEFINE cTelefonoSuc CHAR(14);
	DEFINE cGerenteSuc CHAR(40);
	DEFINE cMensaje1 VARCHAR(255);
	DEFINE cMensaje2 VARCHAR(255);
	DEFINE cMensaje3 VARCHAR(255);
	DEFINE cMensaje4 VARCHAR(255);
	DEFINE cMensaje5 VARCHAR(255);
	DEFINE cMensaje6 VARCHAR(255);
	DEFINE cMensaje7 VARCHAR(255);	
	DEFINE cCampoSucursal CHAR(62);
	DEFINE cAvisos VARCHAR(255);
	DEFINE cInformacion VARCHAR(255);

	-- INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cCodRet = "00000";
	LET cSucursal = "";
	LET cNombreSuc = "";
	LET cSiglasEstado = "";
	LET cTelefonoSuc = "";
	LET cGerenteSuc = "";
	LET cMensaje1 = "";
	LET cMensaje2 = "";
	LET cMensaje3 = "";
	LET cMensaje4 = "";
	LET cMensaje5 = "";
	LET cMensaje6 = "";
	LET cMensaje7 = "";
	LET cCampoSucursal = "";
	LET cAvisos = "";
	LET cInformacion = "";

	--SET DEBUG FILE TO "/respaldosbd/ceav/sp_obtenerdatos_edomovtos.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cCampoSucursal,""),	NVL(cGerenteSuc,""), NVL(cMensaje1,""), NVL(cMensaje2,""), NVL(cMensaje3,""),
					NVL(cMensaje4,""), NVL(cMensaje5,""), NVL(cMensaje6,""), NVL(cAvisos,""), NVL(cInformacion,""), NVL(cMensaje7,"");
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pNumCte,"") = "" OR NVL(pNumCta,"") = "" OR NVL(pProducto,"") = "" THEN
			LET cCodRet = "00001"; -- PARAMETROS INVALIDOS
			RETURN cCodRet, NVL(cCampoSucursal,""),	NVL(cGerenteSuc,""), NVL(cMensaje1,""), NVL(cMensaje2,""), NVL(cMensaje3,""),
				NVL(cMensaje4,""), NVL(cMensaje5,""), NVL(cMensaje6,""), NVL(cAvisos,""), NVL(cInformacion,""), NVL(cMensaje7,"");
		END IF;
		
		IF pProducto = '2900' THEN
		
			SELECT cheq.sucursal, suc.nombre
				   INTO cSucursal, cNombreSuc
			FROM "informix".sc_maechq cheq, 
				bdinteg:"informix".si_sucursales suc 
			WHERE cheq.empresa = suc.empresa
				AND cheq.sucursal = suc.sucursal
				AND cheq.num_cte = TRIM(pNumCte)
				AND cheq.cuenta = TRIM(pNumCta);
			
			SELECT est.siglas 
				INTO cSiglasEstado
			FROM "informix".sc_maechq cheq, 
				bdinteg:"informix".si_sucursales suc, 
				bdinteg:"informix".si_estados est,
				bdinteg:"informix".si_ptf ptf
			WHERE cheq.empresa = suc.empresa
				AND cheq.sucursal = suc.sucursal
				AND cheq.sucursal = ptf.id_ptf
				AND ptf.tipo = "O"			
				AND ptf.cve_estado = est.estado
				AND cheq.num_cte = TRIM(pNumCte)
				AND cheq.cuenta = TRIM(pNumCta);
		
		ELSE
		
			SELECT cheq.sucursal, suc.nombre
				INTO cSucursal, cNombreSuc
			FROM "informix".sc_maechq cheq, 
				bdinteg:"informix".si_sucursales suc, 
				bdinteg:"informix".si_ciudades ciu,
				bdinteg:"informix".si_ptf ptf
			WHERE cheq.empresa = suc.empresa
				AND cheq.sucursal = suc.sucursal
				AND cheq.sucursal = ptf.id_ptf
				AND ptf.tipo = "S"
				AND ptf.cve_ciudad = ciu.ciudad
				AND ptf.cve_estado = ciu.estado
				AND cheq.num_cte = TRIM(pNumCte)
				AND cheq.cuenta = TRIM(pNumCta);
			
			SELECT est.siglas 
				INTO cSiglasEstado
			FROM "informix".sc_maechq cheq, 
				bdinteg:"informix".si_sucursales suc, 
				bdinteg:"informix".si_estados est,
				bdinteg:"informix".si_ptf ptf
			WHERE cheq.empresa = suc.empresa
				AND cheq.sucursal = suc.sucursal
				AND cheq.sucursal = ptf.id_ptf
				AND ptf.tipo = "S"			
				AND ptf.cve_estado = est.estado
				AND cheq.num_cte = TRIM(pNumCte)
				AND cheq.cuenta = TRIM(pNumCta);
			
		END IF;
		
		
		
		SELECT suc.telefono1, suc.gerente
			INTO cTelefonoSuc, cGerenteSuc
		FROM "informix".sc_maechq cheq, 
			bdinteg:"informix".si_sucursales suc
		WHERE cheq.empresa = suc.empresa
			AND cheq.sucursal = suc.sucursal
			AND cheq.num_cte = TRIM(pNumCte)
			AND cheq.cuenta = TRIM(pNumCta);
		
		SELECT mensaje INTO cMensaje1 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 1 AND producto = TRIM(pProducto);
		
		SELECT mensaje INTO cMensaje2 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 2 AND producto = TRIM(pProducto);
		
		SELECT mensaje INTO cMensaje3 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 3 AND producto = TRIM(pProducto);
		
		SELECT mensaje INTO cMensaje4 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 4 AND producto = TRIM(pProducto);
		
		SELECT mensaje INTO cMensaje5 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 5 AND producto = TRIM(pProducto);
			
		SELECT mensaje INTO cMensaje6 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 6 AND producto = TRIM(pProducto);
		
		SELECT mensaje INTO cAvisos 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 7 AND producto = TRIM(pProducto);

		SELECT mensaje INTO cInformacion 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 8 AND producto = TRIM(pProducto);
			
		SELECT mensaje INTO cMensaje7 
		FROM "informix".sc_mensajes_producto 
		WHERE secuencia = 9 AND producto = TRIM(pProducto);
			
			
		-- FORMAR DATOS DE SALIDA
		LET cCampoSucursal = TRIM(cSucursal) || " " || TRIM(cNombreSuc) || ", " || TRIM(cSiglasEstado) || ", Tel. " || TRIM(cTelefonoSuc);
		-- 0002 SUC. ANGEL, CULIACAN, SIN, Tel. 6677158466
		
		IF NVL(cCampoSucursal,"") = "" OR NVL(cGerenteSuc,"") = "" THEN
			LET cCodRet = "00002"; -- NO ENCONTRO INFORMACION DEL CLIENTE
		END IF;
		
		RETURN cCodRet, NVL(cCampoSucursal,""),	NVL(cGerenteSuc,""), NVL(cMensaje1,""), NVL(cMensaje2,""), NVL(cMensaje3,""),
			NVL(cMensaje4,""), NVL(cMensaje5,""), NVL(cMensaje6,""), NVL(cAvisos,""), NVL(cInformacion,""), NVL(cMensaje7,"");

	END;

END PROCEDURE
DOCUMENT
"AUTOR: 95337997 - Carlos Aguirre Vega",
"FOLIO: 1428",
"DESCRIPCION: Consulta los datos para el bloque 2, 3, 7 y 8 del reporte edo_movimientos_sif.rpt",
"y para el reporte de sucursal edo_movimientos_ofi.rpt",
"FECHA: 17-07-2014",
"SUSTENTO: Se definio con Daniel Mayen Rivas en el requerimiento",
"RQM-10 460 Edo cta y edo movim ctas SIF OFI.pdf",
"BD: BDICHEQ",
"-------------------------------------------------------------------------------------------------------------------------",
"AUTOR: 95337997 - Carlos Aguirre Vega",
"FOLIO: 1443 - EdoMovCambio",
"DESCRIPCION: Se agregan nuevos mensajes parametrizados secuencia 4, 5, y 6",
"para el bloque 8 de los estados de movimientos central y sucursal.",
"FECHA: 01/09/2014",
"SUSTENTO: Definio cambios Daniel Mayen en el documento Parametrizacion mensajes_edocta.doc",
"RQM-10 460 Edo cta y edo movim ctas SIF OFI.pdf",
"BD: BDICHEQ";

CREATE PROCEDURE "informix".sp_control_cts_n2()
RETURNING CHAR(5);

    DEFINE vcodret1                         CHAR(5);
    DEFINE vcodret2                         CHAR(5);
    DEFINE vcodret3                         CHAR(50);
    DEFINE sql_err                          INTEGER;
    DEFINE isam_err                         INTEGER;
    DEFINE desc_err                         CHAR(50);
    DEFINE vfec_alta_cuenta                 CHAR(10);
    DEFINE vnum_cte                         CHAR(20);
    DEFINE vtipo_cliente                    CHAR(10);
    DEFINE vfec_alta_cliente                CHAR(10);
    DEFINE vsql                             CHAR(400);
    DEFINE vstmt                            CHAR(200);
    DEFINE vcontador                        INTEGER;
    DEFINE vacumulado                       INTEGER;
    DEFINE vsdo_dia_ant                     MONEY (18,2);
    DEFINE vsaldo_actual                    MONEY (18,2);
    DEFINE vfecha_ant                       DATE;
    DEFINE vfecha_antier                    DATE;
    DEFINE vfechades                        CHAR(8);
    DEFINE vdia                             CHAR(2);
    DEFINE vmes                             CHAR(2);
    DEFINE vanio                            CHAR(4);
    DEFINE valt_ctes_nuevos_dia             SMALLINT;
    DEFINE valt_ctes_exist_dia              SMALLINT;
    DEFINE valtas_del_dia                   SMALLINT;
    DEFINE vsaldo_dia                       MONEY (18,2);
    DEFINE vacum_ctes_exist                 INTEGER;
    DEFINE vacum_ctes_nuevo                 INTEGER;
    DEFINE vacum_altas                      INTEGER;
    DEFINE vmonto_acum                      MONEY (18,2);
	DEFINE vfech_proc                       DATE;
	DEFINE vExiTable                        INTEGER;
	
	
    LET vcodret1                             = '00000';
    LET vcodret2                             = '000';
    LET vcodret3                             = '';
    LET sql_err                              = 0;
    LET isam_err                             = 0;
    LET desc_err                             = '';
    LET vfec_alta_cuenta                     = '';
    LET vnum_cte                             = '';
    LET vtipo_cliente                        = '';
    LET vfec_alta_cliente                    = '';
    LET vacumulado                           = 0;
    LET vsdo_dia_ant                         = 0.00;
    LET vsaldo_actual                        = 0.00;
    LET vfecha_antier                        = '';
    LET vfecha_ant                           = '';
    LET vstmt                                = '';
    LET vsql                          	     = '';
    LET vcontador                            = 0;
    LET vfechades                            = '';
    LET vdia                                 = '';
    LET vmes                                 = '';
    LET vanio                                = '';
    LET valt_ctes_nuevos_dia                 = '';
    LET valt_ctes_exist_dia                  = '';
    LET vsaldo_dia                           = 0.00;
    LET vacum_ctes_exist                     = '';
    LET vacum_ctes_nuevo                     = '';
    LET vacum_altas                          = '';
    LET vmonto_acum                          = 0.00;
    LET valtas_del_dia                       = '';
	LET vfech_proc                           = TODAY-1;
	LET vExiTable                            = 0;
	
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_control_cts_n2.err";
        TRACE ON;
        IF  sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/informix/rsv/n2/sp_control_cts_n2.out';
    --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*)
	INTO   vExiTable
	FROM   sysmaster:systabnames 
	WHERE  partnum > 0 AND tabname = 'altas_cuenta_n2';
	
	IF  vExiTable = 1 THEN 
	    TRUNCATE TABLE altas_cuenta_n2; 
	END IF; 
	 	
    SELECT fecha_ant 
	INTO   vfecha_ant
    FROM   bdicheq:sc_fechas;
		
    FOREACH WITH HOLD
            SELECT a.num_cte, b.fecha_alta,     d.fecha_insert,    a.sdo_dia_ant
            INTO   vnum_cte,  vfec_alta_cuenta, vfec_alta_cliente, vsdo_dia_ant
            FROM   bdicheq:sc_maenoc b,
                   bdicheq:sc_maechq a,
                   bdinteg:si_cliente d,
                   bdicheq:sc_fechas c
            WHERE  b.cuenta = a.cuenta
            AND    a.num_cte = d.numcte
            AND    a.producto="2900"
            AND    a.status_cta <> '2'
            AND    c.fecha_ant = b.fecha_alta        
            
            IF  vfec_alta_cliente = vfecha_ant THEN
                LET vtipo_cliente = 'NUEVO';	
            ELSE
                LET vtipo_cliente = 'EXISTENTE';
            END IF;
	        
			--DETALLE DE LOS CLIENTES CON PRODUCTO 2900
            INSERT INTO altas_cuenta_n2 VALUES(vnum_cte, vfec_alta_cliente, vfec_alta_cuenta, vtipo_cliente, vsdo_dia_ant,vfech_proc);
    END FOREACH;

    -- ACUMULADO DE CLIENTES NUEVOS DEL DIA ANTERIOR 
    SELECT COUNT(*) 
    INTO   valt_ctes_nuevos_dia
    FROM   altas_cuenta_n2
    WHERE  tipo_cte = "NUEVO"
	AND    fech_pro = vfech_proc;

	-- ACUMULADO DE CLIENTES EXISTENTES DEL DIA ANTERIOR
    SELECT COUNT(*) 
    INTO   valt_ctes_exist_dia
    FROM   altas_cuenta_n2
    WHERE  tipo_cte = "EXISTENTE"
	AND    fech_pro = vfech_proc;
	 
	-- TOTAL DE ALTAS DEL DIA Y TOTAL DE SALDO DEL DIA 
    SELECT COUNT (*), NVL(sum(saldos), 0)  
    INTO   valtas_del_dia, vsaldo_dia
    FROM   altas_cuenta_n2
	WHERE  fech_pro = vfech_proc;
		
  	
	-- SE ACTUALIZA VALORES ACUMULADOS Y POR DIA. 
	UPDATE control_altas_cta_n2
	SET    alt_ctes_nuevos_dia = valt_ctes_nuevos_dia,
	       alt_ctes_exist_dia  = valt_ctes_exist_dia,
		   altas_del_dia       = valtas_del_dia,
		   saldo_dia           = vsaldo_dia,
		   acum_ctes_exist     = acum_ctes_exist     + valt_ctes_exist_dia,
		   acum_ctes_nuevo     = acum_ctes_nuevo     + valt_ctes_nuevos_dia,
		   acum_altas          = acum_altas          + valtas_del_dia,
		   monto_acum          = monto_acum          + vsaldo_dia
    WHERE  monto_acum > 0; 
	
	LET vfecha_ant = vfecha_ant;
    LET vdia  = SUBSTR(vfecha_ant, 4, 2);
    LET vmes  = SUBSTR(vfecha_ant, 1, 2);
    LET vanio = SUBSTR(vfecha_ant, 7, 4);
    LET vdia  = TRIM(vdia);
    LET vmes  = TRIM(vmes);
    LET vanio = TRIM(vanio);
    LET vfechades = vmes||vdia||vanio;

    LET vsql = 'echo "set isolation to dirty read; unload to /RESPALDOSNEW/altas_cuenta_n2_'||vfechades||'.txt '||
               'select num_cte, fecha_alta_cliente, fecha_alta_cuenta, tipo_cte, saldos FROM altas_cuenta_n2 WHERE fecha_alta_cuenta = ''' ||vfecha_ant||''' " >/RESPALDOSNEW/altas_cuenta_n2.sql';
    SYSTEM vsql;
    LET vsql = '';

    LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/altas_cuenta_n2.sql";
    SYSTEM vstmt;
    LET vstmt = '';
	
	
    LET vsql = 'echo "set isolation to dirty read; unload to /RESPALDOSNEW/control_altas_cta_n2_'||vfechades||'.txt '||
               'select alt_ctes_nuevos_dia, alt_ctes_exist_dia, altas_del_dia, saldo_dia, acum_ctes_nuevo,acum_ctes_exist, acum_altas, monto_acum  FROM control_altas_cta_n2 "  >/RESPALDOSNEW/control_altas_cta_n2.sql';
    SYSTEM vsql;
    LET vsql = '';
	
    LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/control_altas_cta_n2.sql";
    SYSTEM vstmt;
    LET vstmt = '';
	
    END;

    RETURN vcodret1;
END PROCEDURE;