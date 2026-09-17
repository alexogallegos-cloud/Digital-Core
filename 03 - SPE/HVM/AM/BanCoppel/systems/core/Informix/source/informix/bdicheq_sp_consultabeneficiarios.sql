CREATE PROCEDURE "informix".sp_consultabeneficiarios(pCuenta CHAR(20),pTarjeta CHAR(20))
RETURNING  CHAR(5),INTEGER,CHAR(20),CHAR(20),CHAR(20),CHAR(20),MONEY(9,2),CHAR(40),CHAR(1),CHAR(20);

DEFINE cCodRet 			CHAR(5);
DEFINE cIdentParentesco	CHAR(1);
DEFINE cCuenta 			CHAR(20);
DEFINE cNumCte 			CHAR(20);
DEFINE cTarjeta			CHAR(20);
DEFINE cParentDescrip	CHAR(41);
DEFINE mPorcentaje		MONEY(9,2);

DEFINE cNombreCompleto	CHAR(40);
DEFINE cDescripcion		CHAR(20);
DEFINE iSecuencia		INTEGER;
DEFINE iSqlErr			INTEGER;

LET cCodRet 			= '00000';
LET cNumCte 			= '';
LET cIdentParentesco	= '';
LET cCuenta 			= '';
LET cTarjeta			= '';
LET cParentDescrip		= '';
LET mPorcentaje			= '';
LET cNombreCompleto		= '';
LET cDescripcion		= '';
LET iSqlErr				= 0;
LET iSecuencia			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet,iSecuencia,cCuenta,cNumCte,cTarjeta,cParentDescrip,mPorcentaje,cNombreCompleto,cIdentParentesco,cDescripcion ;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/Antonio/sp_ConsultaBeneficiarios.out";
	--TRACE ON;

	set isolation to dirty read;

	IF pCuenta = '' AND pTarjeta = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet,iSecuencia,cCuenta,cNumCte,cTarjeta,cParentDescrip,mPorcentaje,cNombreCompleto,cIdentParentesco,cDescripcion ;
	END IF;

	IF pCuenta <> '' THEN

		LET pTarjeta = '';

		SELECT cuenta
		INTO cCuenta
		FROM bdicheq:sc_maechq
		WHERE empresa = '001'
		AND cuenta = pCuenta;

			IF cCuenta = '' OR cCuenta IS NULL THEN
				LET cCodRet = '00002';
				RETURN cCodRet,iSecuencia,cCuenta,cNumCte,cTarjeta,cParentDescrip,mPorcentaje,cNombreCompleto,cIdentParentesco,cDescripcion ;
			ELSE
				SELECT num_tarjeta
				INTO cTarjeta
				FROM bdicheq:sc_tarjeta
				WHERE empresa = '001'
				AND cuenta = cCuenta
				AND secuencia = (SELECT MAX(secuencia)
				                   FROM bdicheq:sc_tarjeta
								  WHERE empresa = '001'
								    AND cuenta = cCuenta
									AND tipo_tarjeta = 'T');
			END IF;
	ELIF pTarjeta <> '' THEN

		LET pCuenta = '';

		SELECT cuenta,num_tarjeta
		INTO cCuenta,cTarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = '001'
		AND num_tarjeta = pTarjeta;

		IF cCuenta = '' OR cCuenta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iSecuencia,cCuenta,cNumCte,cTarjeta,cParentDescrip,mPorcentaje,cNombreCompleto,cIdentParentesco,cDescripcion ;
		ENd IF;
	END IF;

	FOREACH
		SELECT secuencia,NVL(TRIM(cte.nombre1),'')||' '||NVL(TRIM(cte.nombre2),'')||' '||NVL(TRIM(cte.apell_paterno),'')||' '||NVL(TRIM(cte.apell_materno),''),
			             NVL(TRIM(bene.parentesco),'')||' '||NVL(TRIM(paren.descripcion),''),porcentaje,cte.numcte,NVL(TRIM(bene.parentesco),''),NVL(TRIM(paren.descripcion),'')
		INTO iSecuencia,cNombreCompleto,cParentDescrip,mPorcentaje,cNumCte,cIdentParentesco,cDescripcion
		FROM bdicheq:sc_beneficiario AS bene
        INNER JOIN bdinteg:si_cliente AS cte ON (bene.numcte = cte.numcte)
		INNER JOIN bdinteg:si_parentesco AS paren ON (bene.parentesco = paren.parentesco)
		WHERE bene.empresa = '001'
			AND bene.cuenta = cCuenta
			AND bene.secuencia = secuencia
		ORDER BY bene.secuencia

		RETURN cCodRet,iSecuencia,cCuenta,cNumCte,cTarjeta,cParentDescrip,mPorcentaje,cNombreCompleto,cIdentParentesco,cDescripcion WITH RESUME;

	END FOREACH;

END
END PROCEDURE
Document
'DESCRIPCION: Procedimiento que consulta los beneficiarios relacionados con una tarjeta o una cuenta',
'Se corrige el proceso direccionando a consultar el nombre del cliente del catalogo de clientes (si_cliente)',
'AUTOR: Antonio Bastidas',
'FECHA: 06 de enero de 2010',
'VERSION: 20100303.192',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_parametroscheques (pEmpresa CHAR(3),pNumEmpleado CHAR(8))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2),CHAR(11),DATE,DATE,DATE,DATE,DATE,DATE;

	--Declaracion de variables		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);
	DEFINE cLongCta             CHAR(11);
	DEFINE dFecha_ant           DATE;
	DEFINE dProx_fecha           DATE;
	DEFINE dPri_dia_mes          DATE;
	DEFINE dPri_hab_mes          DATE;
	DEFINE dUlt_dia_mes          DATE;
	DEFINE dUlt_hab_mes          DATE;

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ParametrosCheques.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet= '00000';
	LET cLongitudCliente= '';
	LET cCodMonNac= '';
	LET cPathRep= '';
	LET cNombreUsuario= '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';

	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,
					   cLongCta,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;
			END IF;
		END EXCEPTION;
		
		--Obtengo el valor longitud del numero de cliente		
		SELECT Trim(valor)
		INTO cLongitudCliente 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 

		--Obtengo el valor codigo de la moneda nacional
		SELECT Trim(valor)
		INTO cCodMonNac 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND descripcion = ('codigo mn');

		 --Obtengo el valor path de reportes
		SELECT Trim(valor) 
		INTO cPathRep
		FROM sc_param 
		WHERE empresa = pEmpresa AND codparam = ('path_rpt');

		--Obtengo el nombre del usuario o ejecutivo
		SELECT nombre 
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = pNumEmpleado;
		 
		-- Obtengo el nombre de la empresa
		SELECT razon_social
		INTO cNombreEmpresa
		FROM bdinteg:si_empresas 
		WHERE empresa = pEmpresa;
		
		
		SELECT valor 
		INTO cLongCta
		FROM bdicheq:sc_param 
		WHERE codparam = 'longcta';
		
		-- Obtengo Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes  
		INTO dFecha_Hoy,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes
		FROM bdicheq:sc_fechas;

		--Obtengo codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema 
		WHERE siglas = 'SI';
		
		RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,
					   cLongCta,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;
		
	END
	END PROCEDURE
	DOCUMENT
	'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema', 
	'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
	'Solicito : Armando Mercado',	
	'AUTOR: Yeimi Adelaida Valdez Haro ',
	'FECHA: Abril 2009',
	'VERSION: 200904',
	'DESCRIPCION: Se añadió el llamado a la longitud de la cuenta, ademas el llamado a las fechas proximas y habiles del mes', 
	'Modifico: Antonio Bastidas ',
	'FECHA: 06/01/2010',
	'VERSION: 20100106.1140',
	'BD: BDICHEQ';

CREATE PROCEDURE "informix".bloquea_ctas_inactivas(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vtransaccion     INTEGER;
    DEFINE vcuenta          CHAR(20);
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcontador    = -1;
    LET vcuantos     = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    
    --- SET DEBUG FILE TO "bloquea_ctas_inactivas.out"
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
            END IF
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;
    
    SELECT cuenta
      FROM sc_ctabloqueo
     WHERE cuenta BETWEEN (SELECT MIN(cuenta) FROM sc_ctabloqueo) AND (SELECT MAX(cuenta) FROM sc_ctabloqueo)
      INTO TEMP tmp_ctasbloq WITH NO LOG;
    CREATE INDEX idx_tmpctasbloq ON tmp_ctasbloq(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasbloq;
        
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '4'
           AND producto IN('1400','1500','1700','2000')
           AND cuenta IN(SELECT cuenta FROM tmp_ctasbloq)
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF
        
        UPDATE sc_maechq
           SET status_cta = '3'
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
    END FOREACH;
    
    LET vcuantos = vcuantos + vcontador;
    COMMIT WORK;
    
    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;