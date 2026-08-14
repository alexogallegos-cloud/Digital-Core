CREATE PROCEDURE "informix".sp_consulta_datos()
	returning CHAR(5) AS cCodRet;

DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE IidErr           INTEGER; 
DEFINE pArchDeclarga1	CHAR(100);
DEFINE pArchDeclarga2   CHAR(100);
DEFINE pArchDeclarga3   CHAR(100);
DEFINE cQuery1          CHAR(10000);
DEFINE cSentencia       CHAR(200);
DEFINE sMes         	CHAR(2);
DEFINE sYear        	CHAR(4);
DEFINE sFechaArch   	CHAR(10);
DEFINE cNum   	   		CHAR(20);
DEFINE csicliente   	CHAR(20);
DEFINE cSecuencia       INTEGER;
DEFINE cCodpostal       CHAR(5);
DEFINE cSexo       		CHAR(1);
DEFINE cFecha_nac       DATE;
DEFINE vsql             CHAR(3000);
DEFINE cDescripcion     CHAR(40);
DEFINE cTipoP           CHAR(2);
DEFINE iCont			SMALLINT;
DEFINE iMaxCommit		INTEGER;

LET cCodRet 			= "00000";
LET IidErr				=0;
LET pArchDeclarga1   	= '';
LET sMes            	= '';
LET sYear           	= '';
LET sFechaArch      	= '';
LET cNum                = '';
LET csicliente 			= '';
LET cSecuencia			= '';
LET cCodpostal          = '';
LET cSexo				= '';
LET cFecha_nac          = '';
LET vsql				= '';
LET cDescripcion        = '';
LET cTipoP 				= '';
LET iCont				= 0;
LET iMaxCommit			= 5000;

	--SET DEBUG FILE TO "/ifxsif01/machavez/salidasp.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE LIMPIA LA TABLAS
	TRUNCATE TABLE td_numCliente;
	TRUNCATE TABLE td_descarga_datos;
	
	LET sMes= month(TODAY);	LET sYear= year(TODAY);	LET sFechaArch=sYear||sMes;
	
	LET pArchDeclarga2='"/RESPALDOSNEW/NumeroCliente'||TRIM(sFechaArch)||'.unl"';
	LET pArchDeclarga3='"/RESPALDOSNEW/"';
		
	LET cSentencia = 'echo "load from ' || TRIM(pArchDeclarga2)|| ' INSERT INTO td_numCliente  " > '|| TRIM(pArchDeclarga3)||'archivoinsert.sql';
	SYSTEM cSentencia;	  
	LET cSentencia = '';
	LET cSentencia = "dbaccess bdinteg " ||TRIM(pArchDeclarga3)||'archivoinsert.sql';
	SYSTEM cSentencia;
	
		BEGIN WORK;
			--create temp table descarga_datos_tmp (numcte char(20), Fecha_nacimiento date, sexo char(1), cod_postal char(5))WITH NO LOG;
			FOREACH WITH HOLD
				SELECT numcte INTO cNum FROM td_numCliente
		
				SELECT numcte, tpo_persona INTO csicliente, cTipoP FROM si_cliente WHERE  numcte = cNum;   
		
				IF (cNum = csicliente ) THEN
					
					LET cDescripcion = '';
					
					SELECT cod_postal, secuencia
					INTO cCodpostal, cSecuencia FROM si_direcciones
					WHERE numcte = csicliente and secuencia =(Select max(secuencia) FROM si_direcciones
															WHERE numcte = csicliente and tipo_dir = '1' group by numcte);
					
					IF ( cTipoP = '01' ) THEN
					
						SELECT  sexo, fecha_nac INTO cSexo, cFecha_nac FROM si_ctepf WHERE numcte = csicliente;
					
					END IF;
				ELSE
					LET cDescripcion = 'No se encontro el numero de cliente';
					LET cCodpostal = '';
					LET cSexo = '';
					LET cFecha_nac = '';
					
					IF (length(cNum) <> 9) THEN
					    LET cDescripcion = 'No corresponde a un numero de cliente';
					END IF;
					
				END IF;
				
				--Inserta los registros obtenidos en la tabla si_detalle_rpt_idbox
				INSERT INTO "informix".td_descarga_datos(numcte,fecha_nac,sexo,cod_postal,descripcion)
				VALUES (cNum,cFecha_nac,cSexo,cCodpostal,cDescripcion);
				
				LET iCont=iCont+1;
				IF iCont >= iMaxCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;
	
		COMMIT WORK;
		
		BEGIN WORK;
			--generacion de reporte 
			let vsql ='echo "No_cliente|Fecha_nacimiento|Sexo|Codigo_postal|Descripcion">/RESPALDOSNEW/RPT_Datoscliente'||TRIM(sFechaArch)||'.txt';
			system vsql;
			let vsql='echo "UNLOAD TO /RESPALDOSNEW/TmpDatosCL.txt '||
			'SELECT numcte,fecha_nac,sexo,cod_postal,descripcion '|| 
			'FROM informix.td_descarga_datos;">/RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			system vsql;
			let vsql='dbaccess bdinteg /RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			let vsql ='rm /RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			let vsql ="sed 's/|$//g' /RESPALDOSNEW/TmpDatosCL.txt >>/RESPALDOSNEW/RPT_Datoscliente'"||TRIM(sFechaArch)||"'.txt";
			system vsql;
			let vsql ='rm /RESPALDOSNEW/TmpDatosCL.txt';
			system vsql;
			let cCodRet ='00000';
		COMMIT WORK;
		
		--SE LIMPIA LA TABLAS
		TRUNCATE TABLE td_numCliente;
		TRUNCATE TABLE td_descarga_datos;
	
	RETURN cCodRet;
END;
END PROCEDURE;