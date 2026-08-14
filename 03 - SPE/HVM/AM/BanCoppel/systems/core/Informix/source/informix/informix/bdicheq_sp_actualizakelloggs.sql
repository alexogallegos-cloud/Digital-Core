CREATE PROCEDURE "informix".sp_actualizakelloggs(pEmpresa CHAR(3), pNumFolio CHAR(7), pEntregado CHAR(1), pNumCuenta CHAR(11),
												pSucursal CHAR(4), pUsuario CHAR(8), pMontoPremio DECIMAL(16,8))

RETURNING CHAR(5) AS CodRet,CHAR(5) As CodRet2;

--Definicion de Variables
DEFINE cEntregado	CHAR(1);
DEFINE cCodRet		CHAR(5);
DEFINE cCodRet2		CHAR(5);
DEFINE iSqlErr 		INTEGER;

--Inicializacion de Variables
LET cCodRet    = '00000';
LET cCodRet2   = '00000';
LET cEntregado = '';

--SET DEBUG FILE TO '/tmp/sp_actualizakelloggs.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		RETURN cCodRet, cCodRet2;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	IF (pEmpresa IS NULL OR pEmpresa = '') OR (pNumFolio IS NULL OR pNumFolio = '')
		OR (pSucursal IS NULL OR pSucursal = '') OR (pUsuario IS NULL OR pUsuario = '') OR
		(pEntregado IS NULL OR pEntregado = '')  OR (pMontoPremio IS NULL OR pMontoPremio = '') THEN
		LET cCodRet2 = '00001';
	ELSE
		SELECT entregado INTO cEntregado
		FROM "informix".sc_promocion_kelloggs 
		WHERE folio = pNumFolio AND empresa = pEmpresa;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet2 = '00002';
		ELSE
			IF cEntregado = '1' THEN
				LET cCodRet2 = '00003';
			ELSE
				UPDATE "informix".sc_promocion_kelloggs
				SET entregado = pEntregado, cuenta_abono = pNumCuenta, folio = pNumFolio,
				sucursal = pSucursal, usuario_entrega = pUsuario, monto_premio = pMontoPremio, fecha_entrega = CURRENT	
				WHERE folio = pNumFolio AND empresa = pEmpresa;
			END IF;
		END IF;
	END IF;

	RETURN cCodRet, cCodRet2;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP que actualice el folio ingresado cuando sea ganador en la tabla sc_promocion_kelloggs ',
'AUTOR : Oscar Valenzuela',
'FECHA : 9/07/2013',
'VERSION: 20130808.1209',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_bitacorakelloggs(pEmpresa CHAR(3), pNumFolio CHAR(7), pSucursal CHAR(4), pUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet,CHAR(5) As CodRet2;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE cCodRet2			CHAR(5);
DEFINE iSqlErr 			INTEGER;

--Inicializacion de Variables
LET cCodRet    = '00000';
LET cCodRet2   = '00000';

--SET DEBUG FILE TO '/tmp/sp_bitacorakelloggs.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodRet2;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	IF (pEmpresa IS NULL OR pEmpresa = '') OR (pNumFolio IS NULL OR pNumFolio = '') 
		OR (pSucursal IS NULL OR pSucursal = '') OR (pUsuario IS NULL OR pUsuario = '') THEN
		LET cCodRet2 = '00001';
	ELSE
		INSERT INTO "informix".sc_bitacora_intentos_kelloggs(empresa, folio_ingresado,sucursal,usuario,fecha_intento)
		VALUES	(pEmpresa, pNumFolio, pSucursal, pUsuario,CURRENT);
	END IF;

	RETURN cCodRet, cCodRet2;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP que registre bitacora de folios exitentes o inexistentes en la tabla sc_bitacora_intentos_kelloggs',
'AUTOR : Oscar Valenzuela',
'FECHA : 9/07/2013',
'VERSION: 20130808.1522',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consfoliokelloggs(pEmpresa CHAR(3), pNumFolio CHAR(7))
RETURNING CHAR(5) AS CodRet, CHAR(5) As CodRet2;

--Definicion de Variables
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2		CHAR(5);
DEFINE iSqlErr 		INTEGER;
DEFINE cEntregado	CHAR(1);

--Inicializacion de Variables
LET cCodRet    = '00000';
LET cCodRet2   = '00000';
LET cEntregado = '';

--SET DEBUG FILE TO '/tmp/sp_consfoliokelloggs.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		RETURN cCodRet, cCodRet2;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	IF (pEmpresa IS NULL OR pEmpresa = '') OR (pNumFolio IS NULL OR pNumFolio = '') THEN
		LET cCodRet2 = '00001';
	ELSE
		SELECT entregado INTO cEntregado 
		FROM "informix".sc_promocion_kelloggs
		WHERE empresa = pEmpresa AND folio = pNumFolio;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet2 = '00002';
		ELSE
			IF cEntregado = '1' THEN
				LET cCodRet2  = '00003';
			END IF;
		END IF;
	END IF;

	RETURN cCodRet, cCodRet2;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP que valide si el folio ingresado por el cajero es un folio ganador en la tabla ',
'			  sc_promocion_kelloggs ',
'AUTOR : Oscar Valenzuela',
'FECHA : 8/07/2013',
'VERSION: 20130708.1726',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_valmayoedadctaefecjovenes()
RETURNING char(5);
    
    DEFINE cCodret          char(5);
    DEFINE cVar             char(5);
    DEFINE cEmpresa         char(3);
    DEFINE cCuenta          char(20);
    DEFINE cNumcte          char(9);
    DEFINE cCliente         char(70);
    DEFINE dFecha_nac       char(10);
    DEFINE cEdad            char(5);
    DEFINE cTelefono1       char(13);
    DEFINE cTelefono2       char(13);
    DEFINE cEmail           char(60);
    DEFINE mSdo_actual      money;
    DEFINE iSQL_ERR         integer;
    DEFINE iBandera         integer;
    DEFINE cDescripcion     char(35);
    DEFINE cFecha           char(10);
    DEFINE vabierto         CHAR(1);
    DEFINE vcomienza        INTEGER;
    DEFINE vexiste_ctabloq  CHAR(20);
    DEFINE vexiste_invcrec  SMALLINT;
    DEFINE vexiste_pagare   SMALLINT;
    DEFINE vdFechaHoy       DATE;
    DEFINE mSdoSBC          MONEY(14,2);
    DEFINE mSdoRet          MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mSdoSBG          MONEY(14,2);
    DEFINE mComPend         MONEY(14,2);
    
    LET cCuenta     = "";		
    LET cNumcte     = "";		
    LET cCliente    = "";		
    LET cEdad       = 0.0;	
    LET cTelefono1  = "";		
    LET cTelefono2  = "";		
    LET cEmail      = "";		
    LET mSdo_actual = 000.00;	
    LET iSQL_ERR    = 100 ;
    LET cCodret     = "000";
    LET dFecha_nac  = "";
    LET iBandera    = 1;
    LET cEmpresa    = "";
    LET cVar        = "";
    LET vabierto    = "0";
    LET vcomienza   = -1;
    LET vexiste_ctabloq = '';
    LET vexiste_invcrec = 0;
    LET vexiste_pagare = 0;
    LET vdFechaHoy  = '';
    LET mSdoSBC = 0;
    LET mSdoRet = 0;
    LET mSdoCong = 0;
    LET mSdoSBG = 0;
    LET mComPend = 0;
    
    --- SET DEBUG FILE TO '/tmp/sp_valmayoedadctaefecjovenes.out';
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSQL_ERR
        LET cCodret = iSQL_ERR;
        IF vabierto = "1" THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodret;
    END EXCEPTION;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM sc_fechas
     WHERE empresa = '001';
    
    FOREACH WITH HOLD
        SELECT mae.empresa, mae.cuenta, sicte.numcte, 
               TRIM(sicte.apell_paterno)||' '||TRIM(sicte.apell_materno)||' '||TRIM(sicte.nombre1)||' '||TRIM(sicte.nombre2) AS cliente, 
               ctepf.fecha_nac, 
               SUBSTR( ( YEAR(fecha.fecha_hoy) + MONTH(fecha.fecha_hoy)/12 + DAY(fecha.fecha_hoy)/30/12 ) - 
                       ( YEAR(ctepf.fecha_nac) + MONTH(ctepf.fecha_nac)/12 + DAY(ctepf.fecha_nac)/30/12 ), 0, 4 ) AS edad,
               tel1.telefono, tel2.telefono, core.correo_elec, mae.sdo_actual, fecha.fecha_hoy,
               mae.imp_chq_sbc, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.com_pendiente
          INTO cEmpresa, cCuenta, cNumcte, cCliente, dFecha_nac, cEdad, cTelefono1, cTelefono2, cEmail, mSdo_actual, cFecha,
               mSdoSBC, mSdoRet, mSdoCong, mSdoSBG, mComPend
          FROM bdicheq:sc_maechq mae
         INNER JOIN bdinteg:si_cliente sicte ON sicte.numcte = mae.num_cte
         INNER JOIN bdinteg:si_ctepf ctepf ON ctepf.numcte = mae.num_cte
         INNER JOIN bdicheq:sc_fechas fecha ON (fecha.fecha_hoy > ctepf.fecha_nac AND fecha.empresa = mae.empresa)
          left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = mae.num_cte and tel1.tipo_tel = 1)
          left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = mae.num_cte and tel2.tipo_tel = 2)
          left outer join bdinteg:si_correos core on (core.numcte = mae.num_cte and core.tipo_correo = 1 and core.status_correo ='A')
         WHERE mae.producto = '2500'
           AND mae.status_cta IN('1','4')
           AND ( ( YEAR(fecha.fecha_hoy) + MONTH(fecha.fecha_hoy)/12 + DAY(fecha.fecha_hoy)/30/12 ) - 
                 ( YEAR(ctepf.fecha_nac) + MONTH(ctepf.fecha_nac)/12 + DAY(ctepf.fecha_nac)/30/12 ) >= 18.5 )
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET vabierto = "1";
        END IF;
        
        SELECT COUNT(*)
          INTO vexiste_invcrec
          FROM bdicheq:sc_maeinstrucc ins,
               bdicheq:sc_maechq mae
         WHERE ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.cuentadep = cCuenta
           AND mae.status_cta <> '2';
           
        SELECT COUNT(*)
          INTO vexiste_pagare
          FROM bdinvers:sv_maeinv
         WHERE status_cta = '1'
           AND cta_cheques = cCuenta;
           
        IF vexiste_invcrec = 0 AND vexiste_pagare = 0 THEN
            IF ( mSdo_actual = 0 AND mSdoSBC = 0 AND mSdoSBG = 0 AND mComPend = 0 ) THEN
                UPDATE bdicheq:sc_maechq 
                   SET status_cta = '2', 
                       motivo = "00",
                       fec_cancelac = vdFechaHoy
                 WHERE empresa = '001'
                   AND cuenta = cCuenta;
            ELSE
                CALL bloqueo_cta(cEmpresa, cCuenta, 0, '02', '2', cFecha, 'informix', '', '', '','','') 
                RETURNING cCodret, cVar;
                
                SELECT UNIQUE cuenta
                  INTO vexiste_ctabloq
                  FROM bdicheq:sc_ctabloqueo
                 WHERE cuenta = cCuenta;
                 
                IF vexiste_ctabloq is null OR vexiste_ctabloq = '' THEN            
                    INSERT INTO bdicheq:sc_ctabloqueo 
                    (cuenta, clave, opcion, cve_area,cod_area, cve_tipobloq, cod_tipobloq ) 
                    VALUES 
                    (cCuenta, '02', '2', '', '', '', '' );
                    
                    INSERT INTO bdicheq:sc_ctabloqueohist 
                    (cuenta, clave, opcion) 
                    VALUES 
                    (cCuenta, '02', '2');
                END IF
            END IF
        END IF;

        LET iBandera = cCodret;
        
        IF vabierto = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    IF iBandera <> 000 THEN
        LET cCodret = '000';
        LET cCliente = 'No se encontraron registros';
        RETURN cCodret;
    ELSE
        RETURN cCodret;
    END IF
    
    END;
    
END PROCEDURE;