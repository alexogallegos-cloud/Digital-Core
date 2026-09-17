CREATE PROCEDURE "informix".sp_parametroscheques_pba (pEmpresa CHAR(3),pNumEmpleado CHAR(8))
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

CREATE PROCEDURE "informix".sp_rptdepefectivo( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
     
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vContador1   INTEGER;
    DEFINE vAbierto     CHAR(1);
    DEFINE vComienza    SMALLINT;
    DEFINE vFechaAnt    DATE;
    DEFINE vFechaHoy    DATE;
    DEFINE vLimDepEfec  DECIMAL(18,2);
    DEFINE vFechaIni    DATE;
    DEFINE vFechaFin    DATE;
    DEFINE vNumCte      CHAR(20);
    DEFINE vMontoAcum   DECIMAL(18,2);
    DEFINE vFecha1      CHAR(8);
    DEFINE vFecha2      CHAR(8);
    DEFINE vstmt        CHAR(600);
    DEFINE vsql         CHAR(200);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '';
    LET vCodRet2     = '';
    LET vCodRet3     = '';  
    LET vContador1   = 0;
    LET vAbierto     = '0';
    LET vComienza    = -1;
    LET vFechaAnt    = '';
    LET vFechaHoy    = '';
    LET vLimDepEfec  = 0.00;
    LET vFechaIni    = '';
    LET vFechaFin    = '';
    LET vNumCte      = '';
    LET vMontoAcum   = 0.00;
    LET vFecha1      = '';
    LET vFecha2      = '';
    LET vstmt        = '';
    LET vsql         = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptdepefectivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptdepefectivo.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES
    SELECT fecha_ant, fecha_hoy
      INTO vFechaAnt, vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    -- // OBTIENE PARAMETRO 
    SELECT valor
      INTO vLimDepEfec
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'LimDepositosEfetivo';
    
    -- // GENERA REPORTE SEMANAL 
    IF WEEKDAY(vFechaHoy) = 0 THEN
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_cteslimdepefec') THEN
            DROP TABLE "informix".sc_cteslimdepefec;        
        END IF;
        
        CREATE RAW TABLE "informix".sc_cteslimdepefec
          (
            num_cte char(20) not null
          )
        EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
        CREATE INDEX "informix".idx_cteslimdepefec_cte ON "informix".sc_cteslimdepefec(num_cte) ONLINE;
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_cteslimdepefec;
           
        LET vFechaIni = vFechaHoy - 7 UNITS DAY;
        LET vFechaFin = vFechaAnt;
    
        FOREACH WITH HOLD
            SELECT UNIQUE num_cte
              INTO vNumCte
              FROM sc_depositosefectivo
             WHERE fecha BETWEEN vFechaIni AND vFechaFin
             
            IF vComienza = -1 THEN
                LET vComienza = 0;
                BEGIN WORK;
                LET vAbierto = '1';
            END IF;
             
            SELECT SUM(monto)
              INTO vMontoAcum
              FROM sc_depositosefectivo
             WHERE num_cte = vNumCte
               AND fecha BETWEEN vFechaIni AND vFechaFin;
               
            IF vMontoAcum = vLimDepEfec THEN
                INSERT INTO sc_cteslimdepefec(num_cte)
                VALUES(vNumCte);
            END IF;
              
            LET vcontador1 = vcontador1 + 1;
            
            IF vcontador1 >= 10000 THEN
                COMMIT WORK;
                BEGIN WORK;
                LET vcontador1 = 0;
            END IF;
            
            LET vNumCte = '';
            LET vMontoAcum = '';
        END FOREACH;
        
        IF vAbierto = '1' THEN
            LET vAbierto = '0';
            COMMIT WORK;
        END IF;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_cteslimdepefec;
    
        LET vFecha1 = TO_CHAR(vFechaIni, '%d%m%Y');
        LET vFecha2 = TO_CHAR(vFechaFin, '%d%m%Y');
    
        LET vstmt = '';
        LET vstmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/MovsLimDepEfectivo_'||vFecha1||'_'||vFecha2||'.txt '||
                    'SELECT dep.num_cte, dep.cuenta, dep.monto, dep.sucursal, dep.fecha, dep.suc_cuenta, 0.00 '||
                    'FROM bdicheq:sc_depositosefectivo dep, bdicheq:sc_cteslimdepefec ctes '||
                    'WHERE dep.fecha BETWEEN '''||vFechaIni||''' AND '''||vFechaFin||''' '||
                    'AND dep.num_cte = ctes.num_cte;" > /resplogifx/conciliachq/movdepefe.sql';
        SYSTEM vstmt;
        LET vstmt = '';
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movdepefe.sql"; 
        SYSTEM vsql;
        LET vsql = '';
    END IF; 
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';  
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;