CREATE PROCEDURE "informix".sp_reportevencimientoporsucursal(pSucursal CHAR(4),pRegistro INTEGER)
RETURNING
	CHAR(5) AS RETORNO,			--Codigo de Retorno
	CHAR (60) AS MENSAJE,		--Mensaje
	CHAR (4) AS SUCURSAL,		--Sucursal
	CHAR (4) AS SUCURSALCLIENTE,--SucCte
	CHAR (9) AS NUMEROCLIENTE,	--NumCte
	CHAR (26) AS NOMBRE1,		--Nombre 1
	CHAR (26) AS NOMBRE2,		--Nombre 2
	CHAR (26) AS PATERNO,		--Apellido paterno
	CHAR (26) AS MATERNO,		--Apellido materno
	CHAR (20) AS CUENTA,		--Cuenta
	MONEY(15,2) AS MONTO,		--Monto
	DATE AS FECHAVENCIMIENTO,	--Fecha de Vencimiento
	DATE AS FECHAAPERTURA,		--Fecha Apertura
	CHAR (8) AS PROMOTOR,		--Promotor
	CHAR (2) AS InstVentoCapital,--InstVentoCapital
	CHAR (2) AS InstVentoInteres;DEFINE vSqlError 			SMALLINT;
DEFINE cCodRet  			CHAR (5);
DEFINE dFechaHoy  			DATE;
DEFINE cDiasXVencer 		CHAR (5);
DEFINE cMensaje 			CHAR (60);
DEFINE cSucursal 			CHAR (4);
DEFINE dFecha_vencimiento 	DATE;
DEFINE cPromotor 			CHAR (8);
DEFINE cNombre1 			CHAR (30);
DEFINE cNombre2 			CHAR (30);
DEFINE cApell_paterno 		CHAR (30);
DEFINE cApell_materno 		CHAR (30);
DEFINE mMonto 				MONEY (15,2);
DEFINE dFecha_apertura 		DATE;
DEFINE cCuenta 				CHAR (20);
DEFINE vciclo				SMALLINT;
DEFINE iDias 				INTEGER;
DEFINE cNumCte				CHAR (9);
DEFINE cSucCte 				CHAR (4);
DEFINE cInstVentoCapital 	CHAR (2);
DEFINE cInstVentoInteres 	CHAR (2);
--Inicializacion de Variables
LET vSqlError				= 0;
LET cCodRet					='00000';
LET dFechaHoy 				= '01-01-1900';
LET cDiasXVencer 			= '';
LET cMensaje 				= 'EL PROCESO SE EJECUTO EXITOSAMENTE';
LET cSucursal				= "";
LET dFecha_vencimiento		= '01-01-1900';
LET cPromotor				= "";
LET cNombre1				= "";
LET cNombre2				= "";
LET cApell_paterno			= "";
LET cApell_materno			= "";
LET mMonto					= 0;
LET dFecha_apertura			= '01-01-1900';
LET cCuenta					= "";
LET vciclo					= 0;
LET iDias					= 0;
LET cNumCte				= "";
LET cSucCte				= "";
LET cInstVentoCapital		= "";
LET cInstVentoInteres		= "";

BEGIN

	ON EXCEPTION SET vSqlError
		IF vSqlError <> 0 THEN
			LET cCodRet = vSqlError;
			LET cMensaje = 'Ocurrio un Error Durante La Ejecucion Del Procedimiento';
			RETURN cCodRet,cMensaje,cSucursal,cSucCte,cNumCte,cNombre1,cNombre2,cApell_materno,cApell_paterno,cCuenta,mMonto,dFecha_vencimiento,
				dFecha_apertura,cPromotor,cInstVentoCapital,cInstVentoInteres;
		END IF;
	END EXCEPTION;

	--crea un archivo temporal en el servidor
	--SET debug file to "/tmp/Antonio/sp_ReporteVencimientoPorSucursal.out";
	--trace on;

	IF NOT EXISTS (SELECT sucursal FROM bdinteg:si_sucursales where sucursal= pSucursal) THEN
		LET cCodRet = '00001';
		LET cMensaje = 'La Sucursal No Existe';
	ELSE
		---Obtener  fecha  de hoy
		SELECT fecha_hoy INTO dFechaHoy FROM bdicheq:sc_fechas;

		--Obtiene los datos de las sucursales, regresa sus valores y los ordena por sucursal
		FOREACH WITH HOLD
			SELECT TRIM(numcta),sucursal,fecha_vencimiento,promotor,numcte,suc_cte,TRIM(nombre1),TRIM(nombre2),TRIM(apell_paterno),
			TRIM(apell_materno),monto,fecha_apertura,inst_vento_capital,inst_vento_interes
			INTO cCuenta,cSucursal,dFecha_vencimiento,cPromotor,cNumCte,cSucCte,cNombre1,cNombre2,cApell_paterno,cApell_materno,mMonto, 
			dFecha_apertura,cInstVentoCapital,cInstVentoInteres
			FROM bdicheq:sc_vencinvpag
			WHERE sucursal = pSucursal 
			AND fecha_vencimiento >= dFechaHoy 
			AND promotor > '00000000'
			AND numcta > '00000000000'
			ORDER BY fecha_vencimiento ASC, promotor ASC, numcta ASC

			LET vCiclo = vCiclo + 1;

			--Paginacion
			IF vciclo <= pRegistro THEN
				CONTINUE FOREACH;
			END IF; 

			RETURN cCodRet,cMensaje,cSucursal,cSucCte,cNumCte,cNombre1,cNombre2,cApell_paterno,cApell_materno,cCuenta,mMonto,dFecha_vencimiento,
				dFecha_apertura,cPromotor,cInstVentoCapital,cInstVentoInteres WITH RESUME;
		END FOREACH;

		IF vciclo = 0 THEN
			LET cCodRet = '00002';
			LET cMensaje = 'No Se Encontraron Datos';
		END IF;
	END IF;

	IF cCodRet <> '00000' THEN
		RETURN cCodRet,cMensaje,cSucursal,cSucCte,cNumCte,cNombre1,cNombre2,cApell_materno,cApell_paterno,cCuenta,mMonto,dFecha_vencimiento,
			dFecha_apertura, cPromotor,cInstVentoCapital,cInstVentoInteres;
	END IF;
END
END PROCEDURE
DOCUMENT
'Autor: Edith Maribel Armenta Sánchez',
'Descripción: Crea un sp para consultar los vencimientos de los proximos 7 dias de la sucursal que ejecuta el proceso.',
'Captación',
'Fecha: Junio de 2010',
'Version:20100618.1116',
'BD: DBICHEQ',
'Autor: Marcos Antonio Cuevas Rodriguez',
'Descripción: Se modifica el sp encargado de consultar los vencimientos de los proximos 7 dias de la sucursal que ejecuta el proceso debido a que se añadieron nuevos campos a la consulta.',
'Incidencias',
'Fecha: 08 de Septiembre de 2010',
'Version:20100908.1440',
'BD: bdicheq';

CREATE PROCEDURE "informix".arreg_maehis(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), CHAR(11), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza1       SMALLINT;
    DEFINE vcomienza2       SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vprimero         SMALLINT;
    DEFINE vsql             CHAR(200);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE wcuenta          CHAR(20);
    DEFINE vaniomestmp      CHAR(6);
    DEFINE vaniomes         CHAR(6);
    DEFINE vaniomesok       CHAR(6);
    DEFINE vfechaini        DATE;
    DEFINE vfechafin        DATE;
    DEFINE vdifdias         SMALLINT;
    DEFINE vultfechafin     DATE;
    DEFINE vexiste_aniomes  CHAR(6);
    DEFINE vmax_aniomes     CHAR(6);
    DEFINE vnumero          SMALLINT;
    DEFINE vnumero2         CHAR(2);
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcomienza1      = -1;
    LET vcomienza2      = -1;
    LET vcontador1      = -1;
    LET vcontador2      = 0;
    LET ven_transacc    = 0; 
    LET vprimero        = 0;
    LET vsql            = '';
    
    LET vcuenta         = ''; 
    LET wcuenta         = '';
    LET vnumero         = 0;
    LET vnumero2        = '';
    LET vaniomestmp     = '';
    LET vaniomes        = '';
    LET vaniomesok      = '';
    LET vfechaini       = '';
    LET vfechafin       = '';
    LET vdifdias        = 0;
    LET vultfechafin    = '';
    LET vexiste_aniomes = '';
    LET vmax_aniomes    = '';
    LET vmincta         = '';
    LET vmaxcta         = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/ids10_uc8/jivan/cierrechq/arreg_maehis.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuenta, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/ids10_uc8/jivan/cierrechq/arreg_maehis.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ctasxcorreg') THEN
        DROP TABLE "informix".ctasxcorreg;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcorreg
      (
        cuenta      char(20)    not null,
        aniomes     char(6)     not null,
        fechaini    date        not null,
        fechafin    date        not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxcorreg ON "informix".ctasxcorreg(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/maehis.unl INSERT INTO ctasxcorreg" > /resplogifx/conciliachq/ctas4.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctas4.sql';
    --- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctas4.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcorreg;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vcuenta
          FROM ctasxcorreg
          
        IF (vcontador1 = -1) THEN
            BEGIN WORK;
            LET vcontador1 = 0;
            LET ven_transacc = 1;
        END IF;
        
        LET vnumero = 1;
        
        FOREACH
            SELECT aniomes, fechaini, fechafin
              INTO vaniomes, vfechaini, vfechafin
              FROM sc_maehis
             WHERE empresa = pempresa
               AND cuenta = vcuenta
             ORDER BY fechaini
             
            LET vnumero2 = LPAD(vnumero, 2, '0');
            LET vaniomestmp = '0000' || vnumero2;
            
            UPDATE sc_maehis
               SET aniomes = vaniomestmp
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND aniomes = vaniomes
               AND fechaini = vfechaini
               AND fechafin = vfechafin;
            
            LET vnumero = vnumero + 1;
        END FOREACH;
        
        FOREACH
            SELECT cuenta, aniomes, fechaini, fechafin
              INTO wcuenta, vaniomes, vfechaini, vfechafin
              FROM ctasxcorreg
             WHERE cuenta = vcuenta
             ORDER BY fechaini
                    
            UPDATE sc_maehis
               SET aniomes = vaniomes
             WHERE empresa = pempresa
               AND cuenta = wcuenta
               AND fechaini = vfechaini
               AND fechafin = vfechafin;
            
            LET vcontador2 = vcontador2 + 1;
            
            LET vaniomes        = '';
            LET vfechaini       = '';
            LET vfechafin       = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcuenta, vcontador1, vcontador2;

END PROCEDURE;