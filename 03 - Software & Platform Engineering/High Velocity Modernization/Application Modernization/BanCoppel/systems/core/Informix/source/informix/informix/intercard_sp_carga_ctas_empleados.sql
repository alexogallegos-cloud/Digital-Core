CREATE PROCEDURE "informix".sp_carga_ctas_empleados()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	--DefiniciÃ³n de variables
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE vNombreArchivo 		VARCHAR(50);
	DEFINE vFecha		 		DATE;
	DEFINE vDia		 			CHAR(2);
	DEFINE vMes					CHAR(2);
	DEFINE vAnio				CHAR(4);
	DEFINE vFechaInicial		DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaFinal			DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaIntegral		DATE;
	DEFINE vCodigoRetornoPeriodos	CHAR(5);
	DEFINE vMensajePeriodos			CHAR(160);
	DEFINE RUTA					VARCHAR(50);
	DEFINE vArchivoDBLOAD		VARCHAR(30);
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vArchivoEjecLog		VARCHAR(50);
    DEFINE vArchivoLOG			VARCHAR(50);
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
    DEFINE ERROR_INFO 			VARCHAR(80);
	
	--InicializaciÃ³n de variables
	LET vCodigoRetorno = '';
	LET vMensaje = '';
	LET vNombreArchivo = 'colaboradores_';
	LET vFecha=TODAY;
	LET vDia='';
	LET vMes ='';
	LET vAnio='';
	LET vFechaInicial='';
	LET vFechaFinal ='';
	LET vFechaIntegral ='';
	LET vCodigoRetornoPeriodos= '';
	LET vMensajePeriodos = '';	
	LET RUTA = '/RESPALDOSNEW/';
	LET vIntervaloCommit = 1000;
	LET vArchivoEjecLog = 'ejec_colaboradores.log';
	LET vArchivoDBLOAD = 'dbload_carga_archivo.txt';
    LET vArchivoLOG = 'colaboradores.log';
	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/carga_ctas_empleados.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA || "carga_colaboradores.err.out";
				TRACE ON;
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Obtiene el rango de fechas del dÃ­a anterior
		EXECUTE PROCEDURE "informix".sp_intercard_calcular_periodos('D', 1)
		INTO vCodigoRetornoPeriodos, vMensajePeriodos, vFechaInicial, vFechaFinal, vFechaIntegral;
		
		IF (vCodigoRetornoPeriodos <> '00000') THEN 
			LET vCodigoRetorno = '00001';
			LET vMensaje = 'Proceso no exitoso';
			RETURN vCodigoRetorno, vMensaje;
		
		END IF
		
		--Obtenemos la fecha
		LET vMes = SUBSTR(vFechaInicial,6,2); 
		LET vDia = SUBSTR(vFechaInicial,9,2); 
		LET vAnio = SUBSTR(vFechaInicial,1,4); 
		LET vNombreArchivo = vNombreArchivo||vDia||vMes||vAnio||".txt";
		
					
		TRUNCATE TABLE "informix".ctas_nomina_empleado DROP STORAGE; 
				
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "FILE '||RUTA||vNombreArchivo||' DELIMITER ''|'' 2; INSERT INTO "informix".ctas_nomina_empleado;" >' ||RUTA||vArchivoDBLOAD;
		SYSTEM vExecuteSQL;
		
		
	    LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbload -d intercard -c '||RUTA||vArchivoDBLOAD||' -l '||RUTA||vArchivoLOG||' -n '||vIntervaloCommit||' -r >' ||RUTA||vArchivoEjecLog;
	   	SYSTEM vExecuteSQL;
		
	
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vArchivoLOG||' '||RUTA||vArchivoEjecLog||' '||RUTA||vArchivoDBLOAD;
	   	SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vNombreArchivo||'*';
	   	SYSTEM vExecuteSQL;
				
		
      	UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_nomina_empleado;
		
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
	
	RETURN vCodigoRetorno, vMensaje;
	END
END PROCEDURE;