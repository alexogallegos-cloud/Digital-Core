CREATE PROCEDURE "informix".sp_archivo_respuesta_tel(pFechaHoy DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;           
          
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cSql              CHAR(2024);
DEFINE cRuta			 CHAR(100);
DEFINE cNombre           CHAR(100);
DEFINE cNum_cte          CHAR(20);
DEFINE cNumeroTelefono   CHAR(10);
DEFINE cTipoTelefono     CHAR(1);

LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cSql                 = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "Se realizó la actualización correctamente";
LET cRuta				 = "";
LET cNombre			     = "";
LET cNum_cte          	 = '';
LET cNumeroTelefono   	 = '';
LET cTipoTelefono     	 = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN 
     LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_archivo_respuesta_tel.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- obtener el nombre con el que se encuentra el archivo de respuesta de Telefonos
	SELECT valor 
	INTO cNombre 
	FROM bdisolic:ss_param 
	WHERE secuencia = 379;
-- obtener la ruta donde se almacenará el archivo de respuesta de Telefonos	
	SELECT valor 
	INTO cRuta
	FROM bdisolic:ss_param 
	WHERE secuencia = 380;

	LET pFechaHoy = pFechaHoy-1;
	LET cNombre = TRIM(cNombre) || lpad(day(pFechaHoy),2,'0') || lpad(month(pFechaHoy),2,'0') || year(pFechaHoy) ||'.txt';

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM SYSTABLES WHERE tabname = 'busca_archivo') THEN	
		DROP TABLE "informix".busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE "informix".busca_archivo
	( archivo CHAR(50));	

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.unl
	LET cSql = "";
	LET cSql = 'ls ' || TRIM(cRuta) || ' > ' || TRIM(cRuta) || 'buscar.unl';
	SYSTEM cSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET cSql = "";
	LET cSql = 'echo "LOAD FROM ' || TRIM(cRuta) || 'buscar.unl' || ' INSERT INTO busca_archivo" > '|| TRIM(cRuta) || 'Ejecuta_BuscarArchivo.sql';
	SYSTEM cSql;	

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET cSql = "";
	LET cSql = 'dbaccess bdinteg ' || TRIM(cRuta) || 'Ejecuta_BuscarArchivo.sql';
	SYSTEM cSql;	

	LET cSql = "";
	LET cSQL = "rm " ||TRIM(cRuta)||'Ejecuta_BuscarArchivo.sql';		
	SYSTEM cSql; 
	
	LET cSql = "";
	LET cSQL = "rm " ||TRIM(cRuta)||'buscar.unl';		
	SYSTEM cSql; 
			
	IF EXISTS (SELECT archivo FROM "informix".busca_archivo where archivo = TRIM(cNombre)) THEN
			-- para cargar el archivo insertandolo en la tabla bdinteg:si_respuesta_tel
			-- delete from bdinteg:si_respuesta_tel;
			LET cSql = "";
			LET cSql = 'echo "load from ' || TRIM(cRuta)||TRIM(cNombre)|| ' INSERT INTO si_respuesta_tel (cliente,telefono,estatus ,tipotelefono ,tipored ,horainicio ,numempleado ,flagenviado)  " > '|| TRIM(cRuta)||'archivoinsert.sql';
			SYSTEM cSql;	  
			LET cSql = '';
			LET cSql = "dbaccess bdinteg " ||TRIM(cRuta)||'archivoinsert.sql';
		    SYSTEM cSql;
			--falta borrar los temporales
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||'archivoinsert.sql';		
	        SYSTEM cSql; 
			
		    LET cCodRet = "000000";
		    LET cSql    = "";
			
			UPDATE "informix".si_respuesta_tel
			SET nombre_archivo = cNombre
			WHERE nombre_archivo is null;
			
			FOREACH
				--Se actualiza la información del archivo de respuesta de Telefonos a la tabla de respuestas
				SELECT LPAD(TRIM(cliente),9,'0'),telefono,tipotelefono 
				INTO cNum_cte,cNumeroTelefono,cTipoTelefono
				FROM "informix".si_respuesta_tel
				WHERE nombre_archivo = TRIM(cNombre)
					
				IF EXISTS (select numcte from bdinteg:"informix".si_telefonos where numcte = cNum_cte AND telefono = cNumeroTelefono AND tipo_tel=cTipoTelefono AND status_tel='A') THEN 
					--update a bdinteg:si_telefonos 
					UPDATE bdinteg:"informix".si_telefonos 
					   SET verificado  = 'V'
					 WHERE numcte = cNum_cte
					 AND telefono = cNumeroTelefono
					 AND tipo_tel = cTipoTelefono
					 AND status_tel ='A';
				END IF;
			END FOREACH;
					
			DROP TABLE "informix".busca_archivo;
	ELSE
			DROP TABLE "informix".busca_archivo;
	--Se elimina por si tiene que procesar varios archivos y si alguno no existe, no se pare el proceso
			LET cCodRet     = "000015";
		    LET cMensajeRet = "No se encontro el archivo en la ruta indicada";
			RETURN cCodRet, cMensajeRet;
	END IF	
    IF cNombre IS NULL OR cNombre = '' THEN
        LET cCodRet     = "000001";
		LET cMensajeRet = "No se tiene archivo de respuesta a procesar";
		RETURN cCodRet, cMensajeRet;
	END IF
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para actualizar a la tabla',
'bdinteg:si_telefonos el campo verificado a "V" de los ',
'telefonos que se recibieron en el archivo de respuesta ',
' /respaldos/',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 11/DICIEMBRE/2015',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_actualiza_clubproteccion(pCliente CHAR(20))

RETURNING CHAR(5) AS codRet;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE dtFechaHoy DATE;

--INICIALIZACION DE VARIABLES
LET cCodret	= "00000";
LET iSqlErr = 0;

--SET DEBUG FILE TO '/home/sysifx/Bryan/137/sp_actualiza_clubproteccion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	IF TRIM(NVL(pCliente,''))='' THEN
		LET cCodret	= "00001";
	ELSE
		SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas;
		
		UPDATE  bdinteg: "informix".si_ctesavencer SET pagado = 1, fecha_pago = CURRENT WHERE numcte_banco = TRIM(pCliente) AND pagado = 0;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 then
            LET cCodret	= "00002";
            RETURN cCodret;
		END IF
		
	END IF;
	
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
'Folio: 137 Consulta saldos para Club de proteccion familiar.',
'Autor: Bryan Limon',
'BD: bdinteg',
'Fecha: 03/11/2016',
'DescripciÃ³n: ACTUALIZARA LA BANDERA DE PAGADO Y LA FECHA EN QUE SE PAGO EN LA TABLA SI_CTESAVENCER'
;

CREATE PROCEDURE "informix".sp_cons_correo_celular(pempresa char(3), pnumcte char(20))
--DATOS A REGRESAR---
RETURNING
CHAR(5),     -- Código de retorno
CHAR(100),   -- Cuenta de Correo
CHAR(13),    -- Telefono Celular
CHAR(02);    -- Carrier

--DEFINICION DE VARIABLES--
DEFINE iSql_Err 		INTEGER;
DEFINE iLongitud        SMALLINT;
DEFINE iCarrier         SMALLINT;
DEFINE iTipo            SMALLINT;
DEFINE cSecuencia 		SMALLINT;
DEFINE iStatusValidacion SMALLINT;
DEFINE cCorreo          CHAR(100);
DEFINE cCelular         CHAR(13);
DEFINE cCarrier         CHAR(2);
DEFINE cCod_Ret 		CHAR(5);
DEFINE cStatus  		CHAR(1);
DEFINE cTipoTel 		CHAR(1);
DEFINE cStatus_Tel 		CHAR(1);
DEFINE cExtension 		CHAR(5);
DEFINE cNombreCarrier 	CHAR(20);

--INICIALIZACION DE VARIABLES--
LET cCod_Ret         = "00000";
LET cCorreo          = "";
LET cCelular         = "";
LET cCarrier         = "";
LET iCarrier         = 0;

--  SET DEBUG FILE TO "/tmp/sp_cons_correo_celular.out";
--  TRACE ON;

set isolation to dirty read;
SET LOCK MODE TO WAIT 3;

-- INICIO DEL PROCEDIMIENTO
BEGIN
  -- MANEJADOR DE ERRORES
  ON EXCEPTION SET iSql_Err
     IF iSql_Err <> 0 THEN
   	     LET cCod_Ret = iSql_Err;
	     RETURN cCod_Ret, cCorreo, cCelular, cCarrier;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET cCod_Ret = "00001";
	LET cCorreo = 'Parámetros incompletos';
	RETURN cCod_Ret, cCorreo, cCelular, cCarrier;
END IF;

SET ISOLATION TO DIRTY READ;
-- Recupera Cuenat de Correo Actual
EXECUTE FUNCTION bdinteg:"informix".sp_consulta_correos(pEmpresa, pNumCte, 1, 0)
INTO cCod_Ret, cCorreo, iTipo, cStatus;
-- Recupera Telefono Celular Actual
EXECUTE FUNCTION bdinteg:"informix".sp_consulta_telefonos(pEmpresa, pNumCte, 2, 0)
INTO cCod_Ret, cCelular, cTipoTel, cSecuencia, cStatus_Tel, cExtension, iCarrier, cNombreCarrier, iStatusValidacion;

LET cCarrier =  LPAD(NVL(iCarrier,0),2,'0');

RETURN LPAD(TRIM(cCod_Ret), 5,'0'), cCorreo, cCelular, cCarrier;
END;
END PROCEDURE
DOCUMENT
'Consulta Cuenta de Correo y Telefono Celular',
'AUTOR : Jaime González',
'FECHA : 02/Marzo/2012',
'Ver.  : 1.0',
'BD    : bdinteg';

CREATE PROCEDURE  "informix".sp_llena_ctes_infosat()
       returning CHAR(5)  AS Cod_Retorno;

DEFINE vcodret     CHAR(5);
DEFINE vsqlerr     INTEGER;
DEFINE ultcte      CHAR(9);
DEFINE iContador   INTEGER;
DEFINE sCommit     SMALLINT;
DEFINE sEmpresa    CHAR(3);
DEFINE sNumcte     CHAR(20); 


BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

LET vcodret="00000";
LET ultcte='';
LET iContador = 0;
LET sCommit = 0;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "/informix/OMC/sp_llena_ctes_infosat.out";
--TRACE ON;

            --Obteniendo el ultimo cliente generado con la info para el SAT
			  SELECT valor INTO ultcte
			  FROM si_param WHERE empresa='001' AND cod_param='139';	
			  
            --Obteniendo los registros de clientes ordenados
            SET ISOLATION TO DIRTY READ;
            FOREACH WITH HOLD
                SELECT LIMIT 1000000  empresa, numcte
				INTO sEmpresa, sNumcte
                FROM bdinteg:si_cliente
                WHERE empresa='001' AND tpo_persona='01'
                AND tipo_cliente='1' AND numcte >ultcte ORDER BY numcte
                

            --Llenando la tabla de control
                
                IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iContador = 0;
					LET sCommit = -1;
                END IF;
                
                INSERT INTO si_ctessat(empresa, numcte,estatus_proc)
                VALUES(sEmpresa, sNumcte, 0);

				LET iContador = iContador  + 1;	
				
                --Ejecutar un commit cada 10000 registros.
                IF (iContador >= 10000) THEN
                    COMMIT WORK;	
                    LET iContador = 0;				
                    BEGIN WORK;
                END IF;	
			END FOREACH;

            IF sCommit = -1 THEN
            	COMMIT WORK;                
            END IF;
            LET sCommit = 0;
			
END;
return vcodret;   
END PROCEDURE;