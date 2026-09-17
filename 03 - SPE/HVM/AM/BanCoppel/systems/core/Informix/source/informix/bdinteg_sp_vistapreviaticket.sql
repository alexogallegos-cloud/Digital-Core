CREATE PROCEDURE "informix".sp_vistapreviaticket (cEmpresa CHAR(3), sTran SMALLINT)

--DATOS A REGRESAR---
RETURNING
CHAR(5)   AS cCodRet, 
INTEGER   AS iSecTicket,
INTEGER   AS iPosDesc,
CHAR(100) AS cDescrip,
INTEGER   AS iPosCampo,
CHAR(20)  AS cCampo,
CHAR(1)   AS Estatus;

--DEFINICION DE VARIABLES--
DEFINE iSql_err     INT;
DEFINE cCodRet      CHAR(5);
DEFINE sFormatCert  SMALLINT;
DEFINE iSec         INTEGER;
DEFINE iCont        INTEGER;
DEFINE iCont2       INTEGER;

--VARIABLES PARA TICKET--
DEFINE iSecTicket   INTEGER; 
DEFINE iPosDesc     INTEGER;
DEFINE cDescrip     CHAR(100);
DEFINE cDescrip2    CHAR(100);
DEFINE iPosCampo    INTEGER;
DEFINE iPosCampo2   INTEGER;
DEFINE cCampo       CHAR(20);
DEFINE cEstatus     CHAR(1);
DEFINE cEstatus2    CHAR(1);

--INICIALIZACION DE VARIABLES--
LET iSql_err      = 0;
LET cCodRet      = '00000';
LET sFormatCert  = 0;
LET iSec         = 0;
LET iCont        = 1;
LET iCont2       = 0;

--VARIABLES PARA TICKET--
LET iSecTicket   = 0;
LET iPosDesc     = 0;
LET cDescrip     = '';
LET cDescrip2    = '';
LET iPosCampo    = 0;
LET iPosCampo2   = 0;
LET cCampo       = '';
LET cEstatus     = '';
LET cEstatus2    = '';

   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_vistapreviaticket.out";
   --TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, iSecTicket, iPosDesc, cDescrip, iPosCampo, cCampo, cEstatus;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF NVL(cEmpresa, '') = '' OR NVL(sTran, 0) = 0 THEN
		
		LET cCodRet = '00001';
		RETURN cCodRet, iSecTicket, iPosDesc, cDescrip, iPosCampo, cCampo, cEstatus;
		
	ELSE
				
		SELECT formato_certifica INTO sFormatCert FROM bdinteg:"informix".itran WHERE numero = sTran AND empresa = cEmpresa;
		
		IF DBINFO("sqlca.sqlerrd2") > 0 THEN
				
			SELECT MAX (secuencia) INTO iSec FROM bdinteg:"informix".vcertif_det WHERE cod_documento = sFormatCert AND empresa = cEmpresa;

			IF DBINFO("sqlca.sqlerrd2") > 0 THEN
			
				WHILE iCont <= iSec 
																					
					SELECT secuencia,posdesc,descripcion,poscampo,campo,estatus
					INTO   iSecTicket,iPosDesc,cDescrip,iPosCampo,cCampo,cEstatus
					FROM   bdinteg:"informix".vcertif_det 
					WHERE  cod_documento = sFormatCert
					AND    secuencia = iCont
					AND    empresa = cEmpresa;
																	
					IF DBINFO("sqlca.sqlerrd2") > 0 THEN
					
							IF iPosDesc > 0 THEN
								FOR iCont2 = 1 TO iPosDesc
									LET cDescrip = ' ' || cDescrip ;
								END FOR
							END IF;
							
							IF cCampo = "" THEN
								LET cDescrip = "";
							END IF;

							SELECT estatus, descripcion, poscampo
							INTO   cEstatus2,cDescrip2,iPosCampo2
							FROM   bdinteg:"informix".vcertif_det 
							WHERE  cod_documento = sFormatCert
							AND    secuencia = iCont + 1 
							AND    empresa = cEmpresa;
							
							IF TRIM(cEstatus2) = 'M' THEN
								FOR iCont2 = 1 TO iPosCampo2
									LET cDescrip2 = ' ' || cDescrip2 ;
								END FOR
								LET cDescrip = cDescrip || cDescrip2;
								LET iCont = iCont + 1;
							END IF;
							
							RETURN cCodRet, iSecTicket, iPosDesc, cDescrip, iPosCampo, cCampo, cEstatus WITH RESUME;
										
					END IF;
					
						LET iCont = iCont + 1;	
					
				END WHILE;
			
			ELSE
			
				LET cCodRet = '00003';
				RETURN cCodRet, iSecTicket, iPosDesc, cDescrip, iPosCampo, cCampo, cEstatus;
				
			END IF;
			
		ELSE
		
			LET cCodRet = '00002';
			RETURN cCodRet, iSecTicket, iPosDesc, cDescrip, iPosCampo, cCampo, cEstatus;
			
		END IF;
		
	END IF;

END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 23/04/2012",
"Descripcion: Consulta datos para la vista previa del ticket inteligente",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_validaestatuspersonal (pEmpresa CHAR(3),pSucursal CHAR(4),pCodUsuario CHAR(8))

--DATOS A REGRESAR---
RETURNING
CHAR    (5)   AS cCodRet,
CHAR    (6)   AS sEstatus;


--DEFINICION DE VARIABLES--
DEFINE iSql_err       INTEGER;
DEFINE cCodRet        CHAR(5);
DEFINE cEmpleado      CHAR(8);
DEFINE vPassword      VARCHAR (200);
DEFINE cSucursal      CHAR(4);
DEFINE cStatus        CHAR(6);

--INICIALIZACION DE VARIABLES--
LET iSql_err           = 0;
LET cCodRet           = '00000';
LET cEmpleado         = '';
LET vPassword         = '';
LET cSucursal         = '';
LET cStatus           = '';

   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_validaestatuspersonal.out";
   --TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cStatus;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pCodUsuario,'') = '' THEN
		
		LET cCodRet = '00001';
		
	ELSE

		SELECT ejecutivo, password, sucursal 
		INTO cEmpleado, vPassword, cSucursal
		FROM bdinteg:"informix".si_ejecut 
		WHERE empresa = pEmpresa
		AND ejecutivo = pCodUsuario;
					
		IF DBINFO("sqlca.sqlerrd2") > 0 THEN
		
			IF TRIM (UPPER(vPassword)) <> "BAJA" THEN
				IF cSucursal = pSucursal THEN
					LET cStatus = 'ACTIVO'; 
				ELSE
					LET cStatus = 'CAMBIO';
				END IF;
			ELSE
				LET cStatus = 'BAJA';
			END IF;
		
		ELSE
			LET cStatus = 'BAJA';
		END IF;
		
	END IF;

	RETURN cCodRet,cStatus;
	
END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 07/09/2012",
"Descripcion: Realiza consulta para validar que el usuario",
"se encuentre activo en la sucursal",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_higienedatos_pba( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50); 
     
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaHoy        DATE;
    DEFINE vPriDiaMes       DATE;
    DEFINE vFechaIni        DATE;
    DEFINE vFechaFin        DATE;
    DEFINE vCteMin          CHAR(20);
    DEFINE vCteMax          CHAR(20);
    DEFINE vNumCte          CHAR(20);
    DEFINE vTipoDir         CHAR(1);
    DEFINE vSecuencia       SMALLINT;
    DEFINE vCalle           CHAR(50);
    DEFINE vNumero          CHAR(20);
    DEFINE vColonia         CHAR(50);
    DEFINE vMunicipio       CHAR(50);
    DEFINE vCodPos          CHAR(5);
    DEFINE vCiudad          CHAR(50);
    DEFINE vEstado          CHAR(30);
    DEFINE vCuenta          CHAR(20);
    DEFINE vNumCredito      CHAR(20);
    DEFINE vExisteIdent     SMALLINT;
    DEFINE vExisteCompDom   SMALLINT;
    DEFINE vExisteContrato  SMALLINT;
    DEFINE vExistePortada   SMALLINT;
    DEFINE vFecha           CHAR(6);
    DEFINE vsql             CHAR(300);
    DEFINE vstmt            CHAR(100);
    DEFINE vCuentas         INTEGER;
    DEFINE vCreditos        INTEGER;
    
    LET Sql_Err	        = 0;
    LET Isam_Err        = 0;
    LET Desc_Err        = '';
    LET vCodRet1        = '';
    LET vCodRet2        = '';
    LET vCodRet3        = '';  
    LET vAbierto        = '0';
    LET vFechaHoy       = '';
    LET vPriDiaMes      = '';
    LET vFechaIni       = '';
    LET vFechaFin       = '';
    LET vCteMin         = '';
    LET vCteMax         = '';
    LET vNumCte         = '';
    LET vTipoDir        = '';
    LET vSecuencia      = 0;
    LET vCalle          = '';
    LET vNumero         = '';
    LET vColonia        = '';
    LET vMunicipio      = '';
    LET vCodPos         = '';
    LET vCiudad         = '';
    LET vEstado         = '';
    LET vCuenta         = '';
    LET vNumCredito     = '';
    LET vExisteIdent    = 0;
    LET vExisteCompDom  = 0;
    LET vExisteContrato = 0;
    LET vExistePortada  = 0;
    LET vFecha          = '';
    LET vsql            = '';
    LET vstmt           = '';
    LET vCuentas        = 0;
    LET vCreditos       = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_higienedatos_pba.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_higienedatos_pba.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, pri_dia_mes
      INTO vFechaHoy, vPriDiaMes
      FROM bdinteg:si_fechas
     WHERE empresa = pEmpresa;
     
    LET vFechaIni = vPriDiaMes - 1 UNITS MONTH;
    LET vFechaFin = vPriDiaMes - 1 UNITS DAY;
     
    TRUNCATE TABLE si_documentos_faltantes;
     
    FOREACH WITH HOLD
        SELECT {+INDEX(bdinteg:si_cliente idx_fecha_insert)} numcte
          INTO vNumCte
          FROM bdinteg:si_cliente
         WHERE fecha_insert BETWEEN vFechaIni AND vFechaFin
           AND tipo_cliente = '1'
           
        BEGIN WORK;
        LET vAbierto = '1';
        
        SELECT COUNT(*)
          INTO vCuentas
          FROM bdicheq:sc_maechq
         WHERE num_cte = vNumCte
           AND status_cta IN('1','3','4','5');
           
        SELECT COUNT(*)
          INTO vCreditos
          FROM bdicred:sd_maecred
         WHERE numcte = vNumCte
           AND status_cred IN('AA','BA','BT');
           
        IF vCuentas > 0 OR vCreditos > 0 THEN
            FOREACH
                SELECT dir.tipo_dir, dir.secuencia, 
                       TRIM(NVL(calle.nombrecalle,  ' ')), 
                       TRIM(NVL(dir.numeroextcalle, ' ')), 
                       TRIM(NVL(zona.nombrezona,    ' ')),
                       TRIM(NVL(zona.municipiozona, ' ')), 
                       TRIM(NVL(dir.cod_postal,     ' ')), 
                       TRIM(NVL(ciu.nombreciudad,   ' ')),
                       TRIM(NVL(edo.nombre,         ' '))
                  INTO vTipoDir, vSecuencia, vCalle, vNumero, vColonia, vMunicipio, vCodPos, vCiudad, vEstado
                  FROM bdinteg:si_direcciones_actual dir
                  LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                  LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                  LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                  LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
                 WHERE dir.numcte = vNumCte
                 
                IF ( vCalle is null     OR vCalle = '' )     OR
                   ( vNumero is null    OR vNumero = '' )    OR
                   ( vColonia is null   OR vColonia = '' )   OR 
                   ( vMunicipio is null OR vMunicipio = '' ) OR
                   ( vCodPos is null    OR vCodPos = '' )    OR
                   ( vCiudad is null    OR vCiudad = '' )    OR
                   ( vEstado is null    OR vEstado = '' )    THEN
                    INSERT INTO bdinteg:si_documentos_faltantes VALUES
                    (vNumCte, 'A la secuencia '||vSecuencia||' de las direcciones del cliente le faltan datos', vFechaHoy);
                END IF;
            END FOREACH;
               
            -- // VERIFICA DOCUMENTOS DIGITALIZADOS - IDENTIFICACIONES
            SELECT COUNT(*)
              INTO vExisteIdent
              FROM bdidigital@coppelimg_tcp:dg_expediente a,
                   bdidigital@coppelimg_tcp:dg_tipodocumento b
             WHERE a.cliente = vNumCte
               AND b.cod_docto = a.cod_docto
               AND b.cod_grupo = '001';
            
            IF vExisteIdent = 0 THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'El cliente no tiene identificaciones digitalizadas', vFechaHoy);
            END IF;
               
            -- // VERIFICA DOCUMENTOS DIGITALIZADOS - COMPROBANTES DOMICILIO
            SELECT COUNT(*)
              INTO vExisteCompDom
              FROM bdidigital@coppelimg_tcp:dg_expediente a,
                   bdidigital@coppelimg_tcp:dg_tipodocumento b
             WHERE a.cliente = vNumCte
               AND b.cod_docto = a.cod_docto
               AND b.cod_grupo = '002';
            
            IF vExisteCompDom = 0 THEN
                INSERT INTO bdinteg:si_documentos_faltantes VALUES
                (vNumCte, 'El cliente no tiene comprobantes digitalizados', vFechaHoy);
            END IF;
                
            -- // VERIFICA SI EL CLIENTE TIENE CUENTAS DE CAPTACION
            FOREACH
                SELECT cuenta
                  INTO vCuenta
                  FROM bdicheq:sc_maechq
                 WHERE num_cte = vNumCte
                   AND status_cta IN('1','3','4','5')
                   
                -- // VERIFICA SI LA CUENTA TIENE CONTRATO DIGITALIZADO
                SELECT COUNT(*)
                  INTO vExisteContrato
                  FROM bdidigital@coppelimg_tcp:dg_expediente
                 WHERE cliente = vNumCte
                   AND cuenta = vCuenta
                   AND cod_docto = '0037';
                
                IF vExisteContrato = 0 THEN
                    INSERT INTO bdinteg:si_documentos_faltantes VALUES
                    (vNumCte, 'La cuenta '||TRIM(vCuenta)||' no tiene contrato digitalizado', vFechaHoy);
                END IF;
                   
                -- // VERIFICA SI LA CUENTA TIENE PORTADA DIGITALIZADA
                SELECT COUNT(*)
                  INTO vExistePortada
                  FROM bdidigital@coppelimg_tcp:dg_expediente
                 WHERE cliente = vNumCte
                   AND cuenta = vCuenta
                   AND cod_docto = '0039';
                
                IF vExistePortada = 0 THEN
                    INSERT INTO bdinteg:si_documentos_faltantes VALUES
                    (vNumCte, 'La cuenta '||TRIM(vCuenta)||' no tiene portada digitalizada', vFechaHoy);
                END IF;
            END FOREACH;
                
            -- // VERIFICA SI EL CLIENTE TIENE CREDITOS VIGENTES
            FOREACH
                SELECT num_credito
                  INTO vNumCredito
                  FROM bdicred:sd_maecred
                 WHERE numcte = vNumCte
                   AND status_cred IN('AA','BA','BT')
                   
                -- // VERIFICA SI EL CREDITO TIENE CONTRATO DIGITALIZADO
                SELECT COUNT(*)
                  INTO vExisteContrato
                  FROM bdidigital@coppelimg_tcp:dg_expediente
                 WHERE cliente = vNumCte
                   AND cuenta = vNumCredito
                   AND cod_docto = '0036';
                
                IF vExisteContrato = 0 THEN
                    INSERT INTO bdinteg:si_documentos_faltantes VALUES
                    (vNumCte, 'El credito '||TRIM(vNumCredito)||' no tiene contrato digitalizado', vFechaHoy);
                END IF;
                   
                -- // VERIFICA SI EL CREDITO TIENE PORTADA DIGITALIZADA
                SELECT COUNT(*)
                  INTO vExistePortada
                  FROM bdidigital@coppelimg_tcp:dg_expediente
                 WHERE cliente = vNumCte
                   AND cuenta = vNumCredito
                   AND cod_docto = '0040';
                
                IF vExistePortada = 0 THEN
                    INSERT INTO bdinteg:si_documentos_faltantes VALUES
                    (vNumCte, 'El credito '||TRIM(vNumCredito)||' no tiene portada digitalizada', vFechaHoy);
                END IF;
            END FOREACH;
        END IF;
        
        COMMIT WORK;
        LET vAbierto = '0';
    END FOREACH;
    
    LET vFecha = TO_CHAR(vFechaHoy, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/HigieneDatosClientes_'||vFecha||'.txt '||
               'SELECT numcte, descripcion '||
               'FROM bdinteg:si_documentos_faltantes '||
               'WHERE fecha_con = '''||vFechaHoy||'''; " > /resplogifx/conciliachq/higdatos.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/higdatos.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';
    
    END; 
    
    RETURN vCodRet1, vCodRet2, vCodRet3;
    
END PROCEDURE;