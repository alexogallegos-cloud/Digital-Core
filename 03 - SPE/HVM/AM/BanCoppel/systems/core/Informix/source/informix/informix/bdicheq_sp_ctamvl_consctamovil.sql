CREATE PROCEDURE "informix".sp_ctamvl_consctamovil
(
	pModo		CHAR(1),
	pTipo		CHAR(1),
	pCte		CHAR(20),
	pCta		CHAR(20),
	pTelefono	CHAR(10),
	pTarjeta	CHAR(20)	
)

RETURNING
	CHAR(5) 	AS cCodRet,
	CHAR(20)	AS Cliente,
	VARCHAR(80) AS producto,
	CHAR(20) 	AS cuenta,
	CHAR(1) 	AS estatus,
	CHAR(10) 	AS telefono,
	DATE 		AS fecha_alta; 
	
	-- DECLARAR E INICIALIZAR TODAS LA VARIABLES.	
	DEFINE cCodRet		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	
	DEFINE cNumCte		CHAR(20);
	DEFINE vProducto	VARCHAR(80);
	DEFINE cCuenta		CHAR(20);
	DEFINE cStatus		CHAR(1);
	DEFINE cTel			CHAR(10);
	DEFINE dFecha		DATE;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cNumCte 		= '';
	LET vProducto 		= '';
	LET cCuenta			= '';
	LET cStatus			= '';
	LET cTel		    = '';
	LET dFecha			= DATE(1);
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
				NVL(dFecha, DATE(1));
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1463/sp_ctamvl_consctamovil.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  	

		-- validar el parametro de tipo modo.
		IF NVL (pModo, '') = '' OR pModo NOT IN ('1','2') THEN
			LET cCodRet = '00001';
			RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
					NVL(dFecha, DATE(1));
		END IF;
		
		--VALIDAR PARÃMETROS OBLIGATORIOS	
		IF pTipo NOT IN('1', '2', '3', '4') THEN
			LET cCodRet = '00001';
			RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
				NVL(dFecha, DATE(1));
		END IF
		
		IF pTipo = '1' THEN --CONSULTA POR CLIENTE 
				IF NVL(pCte, '') = ''  THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF; 
		ELIF pTipo = '2' THEN --CONSULTA POR CUENTA 
				IF NVL(pCta, '') = '' THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF; 
		ELIF pTipo = '3' THEN --CONSULTA POR TELEFONO 
				IF NVL(pTelefono, '') = ''  THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF; 
		ELIF pTipo = '4' THEN --CONSULTA POR TARJETA 
				IF NVL(pTarjeta, '') = ''  THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF; 
		END IF; 
		--TERMINA DE VALIDAR PARÃMETROS OBLIGATORIOS
		
		IF pModo = '1' THEN -- MODO ASOCIACION CUENTA MOVIL.
		--MOSTRAR SÓO LAS CUENTAS DEL CLIENTE QUE NO TENGAN UN NÚERO ASOCIADO	
			--FUNCIONALIDAD DE CONSULTAS			
			IF pTipo = '1' THEN	--POR CLIENTE (TIPO 1)				
				FOREACH 							
					SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
					INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
					FROM "informix".sc_maechq AS maechq
					INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
					INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
					LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.cuenta = maechq.cuenta AND ctamvl.num_cte = ctepf.numcte) 
					INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400') )
					WHERE maechq.num_cte = pCte
					AND maechq.status_cta = '1'	
					

					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;
				END FOREACH;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00002';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''), NVL(dFecha, '');
				END IF;			
			END IF;
							
			IF pTipo = '2' THEN --POR CUENTA (TIPO 2)
				FOREACH						
					SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
					INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
					FROM "informix".sc_maechq AS maechq
					INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
					INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
					LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.cuenta = maechq.cuenta AND ctamvl.num_cte = ctepf.numcte) 
					INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400') ) 
					WHERE maechq.cuenta = pCta
					AND maechq.status_cta = '1'
					
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;
				END FOREACH;
			
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;	
			END IF;	
				
			IF pTipo = '3' THEN--POR TELEFONO (TIPO 3)
				FOREACH
					SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
					INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
					FROM bdinteg:"informix".si_telefonos_actual AS tel
					INNER JOIN "informix".sc_maechq AS maechq ON (maechq.num_cte = tel.numcte AND maechq.status_cta = '1')
					INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
					INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
					LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.cuenta = maechq.cuenta AND ctamvl.num_cte = ctepf.numcte) 
					INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400')  ) 
					WHERE tel.telefono = pTelefono
					
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;		
				END FOREACH;
			
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00004';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;					
			END IF;
			
			IF pTipo = '4' THEN --POR TARJETA (TIPO 4)
				FOREACH
					SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
					INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
					FROM "informix".sc_tarjeta AS trjt
					INNER JOIN "informix".sc_maechq AS maechq ON (trjt.cuenta = maechq.cuenta AND maechq.status_cta = '1')
					INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
					INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
					LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.cuenta = maechq.cuenta AND ctamvl.num_cte = ctepf.numcte) 
					INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400')) 
					WHERE trjt.num_tarjeta = pTarjeta
				
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;		
				END FOREACH;	
			
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00005';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;		
			END IF;
		--TERMINA FUNCIONALIDAD
		END IF

		IF pModo = '2' THEN -- DESASOCIACION Y CAMBIO DE NUMERO MOVIL.
		--MOSTRAR SÓO LAS CUENTAS QUE TENGAN UN NÚERO TELEFONICO ASOCIADO (DISPONIBLES PARA BAJAS Y CAMBIOS)
					--FUNCIONALIDAD DE CONSULTAS
			IF pTipo = '1' THEN	--POR CLIENTE (TIPO 1)	
				FOREACH 							
					SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
					INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
					FROM "informix".sc_maechq AS maechq
					INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
					INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
					LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.num_cte = maechq.num_cte and ctamvl.cuenta = maechq.cuenta) 
					INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400') ) 
					WHERE maechq.num_cte = pCte
					AND maechq.status_cta = '1'
					

					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;
				END FOREACH;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00002';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;			
			END IF;
							
			IF pTipo = '2' THEN --POR CUENTA (TIPO 2)
				FOREACH						
					SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
					INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
					FROM "informix".sc_maechq AS maechq
					INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
					INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
					LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.cuenta = maechq.cuenta) 
					INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400') ) 
					WHERE maechq.cuenta = pCta 
					AND maechq.status_cta = '1'
					
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;
				END FOREACH;
			
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;	
			END IF;	
				
			IF pTipo = '3' THEN--POR TELEFONO (TIPO 3)				
				FOREACH
						SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
						INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
						FROM "informix".sc_cuenta_telefono AS ctamvl
						INNER JOIN "informix".sc_maechq AS maechq ON (ctamvl.cuenta = maechq.cuenta AND maechq.status_cta = '1')
						INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
						INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
						INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2500','2400')) 
						WHERE ctamvl.telefono = pTelefono
					
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;		
				END FOREACH;	
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00004';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;	
			END IF
				
				
			IF pTipo = '4' THEN --POR TARJETA (TIPO 4)
				FOREACH
						SELECT maechq.num_cte, TRIM(maechq.producto)||" "||TRIM(prod.nombre) AS Producto, maechq.cuenta, maechq.status_cta, NVL(ctamvl.telefono, "") AS Telefono, maenoc.fecha_alta
						INTO cNumCte, vProducto, cCuenta, cStatus, cTel, dFecha
						FROM "informix".sc_tarjeta AS trjt
						INNER JOIN "informix".sc_maechq AS maechq ON (trjt.cuenta = maechq.cuenta AND maechq.status_cta = '1')
						INNER JOIN "informix".sc_maenoc AS maenoc ON (maenoc.cuenta = maechq.cuenta) 
						INNER JOIN bdinteg:"informix".si_ctepf AS ctepf ON (ctepf.numcte = maechq.num_cte) 
						LEFT JOIN "informix".sc_cuenta_telefono AS ctamvl ON (ctamvl.cuenta = trjt.cuenta) 
						INNER JOIN "informix".sc_producto AS prod ON (prod.producto = maechq.producto AND prod.producto IN ( '1300','1400','1500','1700','1800','1900','2000','2100','2500','2400')) 
						WHERE trjt.num_tarjeta = pTarjeta
						
						RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1)) WITH RESUME;		
				END FOREACH;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00005';
					RETURN cCodRet, NVL(cNumCte, ''), NVL(vProducto, ''), NVL(cCuenta, ''), NVL(cStatus, ''), NVL(cTel, ''),
							NVL(dFecha, DATE(1));
				END IF;	
			END IF;
			--TERMINA FUNCIONALIDAD
		END IF
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que consultara todas la cuentas activas que tiene el cliente previa validació® ¤e los pará­¥tros de entrada ',
'AUTOR: Antonio Cebreros Perez',
'FECHA DE CREACION: 10 de Octubre del 2014',
'VERSION: 20141030.1600',
'BD: bdicheq',
'Folio: 1463 - NumMovilCtasSPEI',
'-----------------------------------------------------------------------------------------------------------------------',
'DESCRIPCION: Se agrega producto 2100 en las consultas a tablas de captacion',
'AUTOR: Mario Gallardo',
'FECHA DE CREACION: 08 de agosto del 2023',
'BD: bdicheq',
'Folio: 2023-08-08 RQI 13 855 Cuenta de Nomina',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_actparamcierre(pempresa CHAR(3)) 
RETURNING CHAR(5); 
     
    --- ################################################################################
    --- ##  Nombre:              sp_actparamcierre                                    ##
    --- ##  Version:             1.0.1                                                ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion      ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIficado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Julio 2013                                           ##
    --- ################################################################################
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(50);
    DEFINE vfecha_hoy       DATE;
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vdia             SMALLINT;
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = " ";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfecha_hoy = ' ';    
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vcuenta    = '';
    LET vdia       = -1;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamcierre.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vdia = WEEKDAY(vfecha_hoy);
    
    IF vdia = 0 THEN
        SELECT ROUND(COUNT(*)/14)
          INTO vpromedio
          FROM sc_maechq
         WHERE producto = '2000'
           AND status_cta NOT IN("2","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy);
           
        LET vcont = 1;  
        
        WHILE vcont <= 13         
            IF vcont = 1 THEN
                LET vbrinca = vpromedio;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp1';
                END FOREACH;
            ELIF vcont = 2 THEN
                LET vbrinca = vpromedio * 2;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp2';
                END FOREACH;
            ELIF vcont = 3 THEN
                LET vbrinca = vpromedio * 3;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp3';
                END FOREACH;
            ELIF vcont = 4 THEN
                LET vbrinca = vpromedio * 4;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp4';
                END FOREACH;
            ELIF vcont = 5 THEN
                LET vbrinca = vpromedio * 5;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp5';
                END FOREACH;
            ELIF vcont = 6 THEN
                LET vbrinca = vpromedio * 6;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp6';
                END FOREACH;
            ELIF vcont = 7 THEN
                LET vbrinca = vpromedio * 7;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp7';
                END FOREACH;
            ELIF vcont = 8 THEN
                LET vbrinca = vpromedio * 8;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp8';
                END FOREACH;
            ELIF vcont = 9 THEN
                LET vbrinca = vpromedio * 9;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCierreCapComp9';
                END FOREACH;
            ELIF vcont = 10 THEN
                LET vbrinca = vpromedio * 10;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp10';
                END FOREACH;
            ELIF vcont = 11 THEN
                LET vbrinca = vpromedio * 11;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp11';
                END FOREACH;
            ELIF vcont = 12 THEN
                LET vbrinca = vpromedio * 12;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp12';
                END FOREACH;
            ELIF vcont = 13 THEN
                LET vbrinca = vpromedio * 13;
                FOREACH
                    SELECT SKIP vbrinca FIRST 1 cuenta
                      INTO vcuenta
                      FROM sc_maechq
                     WHERE producto = '2000'
                       AND status_cta not in("2","7","8")
                       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vfecha_hoy)
                     ORDER BY cuenta
                     
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniCiereCapComp13';
                END FOREACH;
            END IF;
            
            LET vcont = vcont + 1;  
            LET vcuenta = '';
        END WHILE;    
    END IF;
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;