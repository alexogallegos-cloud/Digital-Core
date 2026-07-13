CREATE PROCEDURE "informix".sp_generararchivoplanobatch(cTipoMov CHAR(2), pFechaAct DATE)
RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vsSQL1 				CHAR (150);
	DEFINE vsSQL2 				CHAR (750) ;
	DEFINE vsSQL3 				CHAR (150) ;
	--DEFINE v_NomArchivo  VARCHAR(50);
	DEFINE vRuta CHAR (90);
	DEFINE vsSQL CHAR (1050) ;
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	-- AAME RQI 27 067 SE AGREGA VARIABLE PARA EL NUEVO ARCHIVO
	DEFINE sAntNomArchivoFinal VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE iCountMovTO INTEGER;
	DEFINE v_TipoMov VARCHAR (20);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	DEFINE vAux VARCHAR(50,1);
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET  v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	LET sPreNomArchivoFinal ='';
	LET sNombreArchivoFinal ='';
	-- AAME RQI 27 067 SE INICIALIZA VARIABLE PARA EL NUEVO ARCHIVO
	LET sAntNomArchivoFinal ='';
	LET sAnterNomArchivoFinal='';
    LET vAux = "||'||'||'|'||1||'||'||-99999||'|'||99999";
	
SET ISOLATION TO COMMITTED READ LAST COMMITTED;	
	---SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE  "informix".sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/sp_GenerarArchivoPlano.out";
	--SET DEBUG FILE TO "/informix/Malena/sp_GenerarArchivoPlano.out";
	--TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = '';
	
	SELECT TRIM(valor)
	INTO vRuta
	FROM "informix".si_param
	WHERE cod_param='193';

	--LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
	LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunicabatch';
	-- INC 27 047 Se cambia el nombrado de los archivos generados a como se encontraban los productivos.
	
	IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
		LET v_cod_ret = '000001';
		RETURN v_cod_ret;
	END IF;
	
	SELECT COUNT(tipomovto) INTO iCountMovTO FROM "informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct;
	
	SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas;
    
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		IF iCountMovTO > 0 THEN
			IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
					
				IF EXISTS (SELECT DISTINCT tipomovto FROM "informix".si_archivoscopdiario WHERE tipomovto <> 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					--AAME RQI 27 047 Se renombra el archivo para movimientos alta unica para que no se tome como el productivo
					LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunicabatch'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica3.unl';
					--
					LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(vRuta)|| 'movimientosaltaunicax.unl' || ' DELIMITER ' || '''|''' || 
								' SELECT trama ' || TRIM(vAux) ||
								' FROM "informix".si_archivoscopdiario '||
								' WHERE tipomovto <> '||'''TO'''||
								' AND fecha_insert = '||''''||pFechaAct||''''||
								' " > ' || TRIM(vRuta)|| 'Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutamovimientosaltaunica.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg ' || TRIM(vRuta)|| 'Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "movimientosaltaunicax.unl > " || sPreNomArchivoFinal;
					SYSTEM vsSQL;					
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "movimientosaltaunica.unl > " || sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica2.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;				
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica3.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO "informix".si_archivoscophist(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario
					WHERE tipomovto <> 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM "informix".si_archivoscopdiario
					WHERE tipomovto <> 'TO' 
					AND fecha_insert = pFechaAct;					
									
				END IF;
			ELIF cTipoMov = 'TO'  THEN --Valida el tipo de movimiento para generar el archivo de totales
				LET v_cod_ret = '000000';
				IF EXISTS (SELECT DISTINCT tipomovto FROM "informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					--AAME RQI 27 047 Se renombra el archivo para cifras alta unica para que no se tome como el productivo
					LET sNombreArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunicabatch'|| cFecha_hoy || '.txt';
					LET sPreNomArchivoFinal =  TRIM(vRuta)|| 'cifrasaltaunica.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica3.unl';
					--
					---	GENERA EL ARCHIVO PLANO
					LET vsSQL1 = ' echo "UNLOAD TO ' || TRIM(vRuta)||'cifrasaltaunicax.unl' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT  trama FROM  bdinteg:si_archivoscopdiario WHERE  tipomovto = '"||cTipoMov||"' AND fecha_insert ='"||pFechaAct||"';";
					LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'Ejecutacifrasaltaunica.sql'; 
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
					SYSTEM vsSQL;
				    LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutacifrasaltaunica.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg '|| TRIM(vRuta)|| 'Ejecutacifrasaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "cifrasaltaunicax.unl > "|| sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "cifrasaltaunica.unl > "|| sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "cifrasaltaunica2.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;	
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "cifrasaltaunica3.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| TRIM(vRuta)|| "cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm "|| TRIM(vRuta)|| "cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;
				
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO "informix".si_archivoscophist(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario
					WHERE tipomovto = 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM "informix".si_archivoscopdiario
					WHERE tipomovto = 'TO' 
					AND fecha_insert = pFechaAct;							

				END IF;
			END IF;
		ELSE
			LET v_cod_ret = '000002';
		END IF;
	ELSE
		LET v_cod_ret = '000003';
	END IF;
	RETURN v_cod_ret;
END;
--##############################################################################
--## Procedimiento   : "informix".sp_GenerarArchivoPlanobatch
--## Version         : 1.0
--## Creado por      : Maria Elena Angulo
--## Fecha creacion  : Diciembre de 2008
--## Descripcion     : Espejo del procedimiento sp_GenerarArchivoPlano que Realiza la generacion del archivo plano con las 
--## adecuaciones para los nuevos procesos que realizan la generación de archivos batch.
--##############################################################################
END PROCEDURE;