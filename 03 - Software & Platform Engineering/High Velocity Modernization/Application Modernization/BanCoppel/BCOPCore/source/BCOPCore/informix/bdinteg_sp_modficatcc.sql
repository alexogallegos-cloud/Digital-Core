CREATE PROCEDURE "informix".sp_modficatcc(pEmpresa CHAR(3),pAccion INTEGER,pIdcatalogo INTEGER,pIdorigen INTEGER,pIddestino INTEGER,pDescripcion CHAR (30))
RETURNING 	CHAR(5)  AS CodRet,
			CHAR(50)  AS Mensaje;			
			
---DECLARACIONES
DEFINE iSqlErr	INTEGER;
DEFINE iIsamErr	INTEGER;
DEFINE cCod_ret	CHAR(5);
DEFINE cMensaje	CHAR(50);

LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCod_ret	= '00000';
LET cMensaje	= 'Actualizaci'||CHR(243) ||'n Exitosa';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
		  ROLLBACK WORK;
          LET cCod_ret = iSqlErr;
		  LET cMensaje = 'Ocurri'||CHR(243) ||' un error de informix';
          RETURN cCod_ret,NVL(cMensaje,'');
       END IF;
    END EXCEPTION;
	
	ON EXCEPTION IN (-535)
      COMMIT WORK;
      BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/respaldosbd/josue/sp_modficatcc.out";
	--TRACE ON;
	
	-- pIdcatalogo 	1 = REGIÓN, 2 = GCB, 	  3 = ESTATUS
	-- pAccion 		1 = EDITAR, 2 = AGREGAR,  3 = REEMPLEZAR
	
	BEGIN WORK;
	
		IF (NVL(pEmpresa,'')= '') OR (NVL(pAccion,0) = 0) OR (NVL(pIdcatalogo,0) = 0) OR (NVL(pDescripcion,'') = '') THEN					
			LET cCod_ret	= '00002';
			LET cMensaje	= 'Par'||CHR(225) ||'metros incompletos';	
		ELIF NVL(pAccion,0) NOT IN (1,2,3) THEN
			LET cCod_ret	= '00002';
			LET cMensaje	= 'Par'||CHR(225) ||'metros incompletos';
		ELIF  NVL(pIdcatalogo,0) NOT IN (1,2,3,4) THEN /*JMMO AGREGAR 4*/	
			LET cCod_ret	= '00001';
			LET cMensaje	= 'El cat'||CHR(225) ||'logo consultado no existe';
		ELSE	
			IF NVL(pAccion,0) IN(1,3) AND ((NVL(pIdorigen,0) = 0)) THEN
					LET cCod_ret	= '00002';
					LET cMensaje	= 'Par'||CHR(225) ||'metros incompletos';
			ELSE		
				-- SE EDITAN LOS CATALOGOS
				IF NVL(pAccion,0) = 1 THEN 
					
					IF NVL(pIdcatalogo,0) = 1 THEN			
						UPDATE "informix".si_catregion_rh SET region = pDescripcion WHERE id_region = pIdorigen;
					ELIF NVL(pIdcatalogo,0) = 2 THEN		
						UPDATE "informix".si_catgcb_rh SET gerencia_comercial = pDescripcion WHERE id_gerencia = pIdorigen;	
					ELIF NVL(pIdcatalogo,0) = 3 THEN
						UPDATE "informix".si_catstatus_rh SET status = pDescripcion WHERE id_status = pIdorigen;
					/*JMMO*/	
					ELIF NVL(pIdcatalogo,0) = 4 THEN
						UPDATE "informix".si_catczb_rh SET Nom_coordinacion = pDescripcion WHERE id_coordinacion = pIdorigen;
					/*JMMO*/	
					END IF;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret	= '00003';
						LET cMensaje	= 'No se pudo actualizar el registro';						
					END IF;
					
				-- SE AGREGAN REGISTROS A LOS CATALOGOS
				ELIF NVL(pAccion,0) = 2 THEN 
					IF NVL(pIdcatalogo,0) = 1 THEN			
						INSERT INTO "informix".si_catregion_rh (region) VALUES (pDescripcion);	
					ELIF NVL(pIdcatalogo,0) = 2 THEN		
						INSERT INTO "informix".si_catgcb_rh (gerencia_comercial) VALUES (pDescripcion);
					ELIF NVL(pIdcatalogo,0) = 3 THEN
						INSERT INTO "informix".si_catstatus_rh (status) VALUES (pDescripcion);
					/*JMMO*/	
					ELIF NVL(pIdcatalogo,0) = 4 THEN
						INSERT INTO "informix".si_catczb_rh (Nom_coordinacion) VALUES (pDescripcion);
					/*JMMO*/			
					END IF;					
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret	= '00004';
						LET cMensaje	= 'No se pudo crear el registro';						
					END IF;
					
				-- SE REEMPLAZA UNA DESCRIPCION POR OTRA EN LOS CATALOGOS
				ELIF NVL(pAccion,0) = 3 THEN
					IF (NVL(pIdorigen,0) = 0) OR (NVL(pIddestino,0) = 0) THEN
						LET cCod_ret	= '00002';
						LET cMensaje	='Par'||CHR(225) ||'metros incompletos';
					ELSE
						IF NVL(pIdcatalogo,0) = 1 THEN			
							DELETE FROM "informix".si_catregion_rh WHERE id_region = pIddestino;
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
								LET cCod_ret	= '00005';
								LET cMensaje	= 'No se pudo reemplazar el registro';	
							ELSE
								UPDATE "informix".si_catregion_rh SET region = pDescripcion WHERE id_region = pIdorigen;
								IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
									ROLLBACK WORK;
									BEGIN WORK;
									LET cCod_ret	= '00005';
									LET cMensaje	= 'No se pudo reemplazar el registro';
								ELSE
									UPDATE  "informix".si_sucursales SET id_region_rh = pIdorigen WHERE id_region_rh = pIddestino;
								END IF;
							END IF;							
							
						ELIF NVL(pIdcatalogo,0) = 2 THEN		
							DELETE FROM "informix".si_catgcb_rh WHERE id_gerencia = pIddestino;
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
								LET cCod_ret	= '00005';
								LET cMensaje	= 'No se pudo reemplazar el registro';	
							ELSE								
								UPDATE "informix".si_catgcb_rh SET gerencia_comercial = pDescripcion WHERE id_gerencia = pIdorigen;
								IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
									ROLLBACK WORK;
									BEGIN WORK;
									LET cCod_ret	= '00005';
									LET cMensaje	= 'No se pudo reemplazar el registro';
								ELSE
									UPDATE  "informix".si_sucursales SET id_gerencia_rh = pIdorigen WHERE id_gerencia_rh = pIddestino;
								END IF;
							END IF;
						ELIF NVL(pIdcatalogo,0) = 3 THEN
							DELETE FROM "informix".si_catstatus_rh WHERE id_status = pIddestino;
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
								LET cCod_ret	= '00005';
								LET cMensaje	= 'No se pudo reemplazar el registro';	
							ELSE								
								UPDATE "informix".si_catstatus_rh SET status = pDescripcion WHERE id_status = pIdorigen;
								IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
									ROLLBACK WORK;
									BEGIN WORK;
									LET cCod_ret	= '00005';
									LET cMensaje	= 'No se pudo reemplazar el registro';
								ELSE
									UPDATE  "informix".si_sucursales SET id_status_rh = pIdorigen WHERE id_status_rh = pIddestino;
								END IF;
							END IF;
						/*JMMO*/	
						ELIF NVL(pIdcatalogo,0) = 4 THEN		
							DELETE FROM "informix".si_catczb_rh WHERE id_coordinacion = pIddestino;
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
								LET cCod_ret	= '00005';
								LET cMensaje	= 'No se pudo reemplazar el registro';	
							ELSE								
								UPDATE "informix".si_catczb_rh SET Nom_coordinacion = pDescripcion WHERE id_coordinacion = pIdorigen;
								IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
									ROLLBACK WORK;
									BEGIN WORK;
									LET cCod_ret	= '00005';
									LET cMensaje	= 'No se pudo reemplazar el registro';
								ELSE
									UPDATE  "informix".si_sucursales SET id_czb_rh = pIdorigen WHERE id_czb_rh = pIddestino;
								END IF;
							END IF;			
						/*JMMO*/	
						END IF;		
					END IF;
				END IF;
			END IF;
		END IF;
	COMMIT WORK;
		RETURN cCod_ret,NVL(cMensaje,'');
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'FOLIO:1604',
'AUTOR:94912599', 
'FECHA:26/10/2015',
'DESCRIPCIÓN: Procedimiento para modificar la descripción o ID de los catálagos de regiones,Estatus o gcb banco',
'SUSTENTO:9005- RQM 02 060 Modulo de mantenimiento al catalogo de CC-20151009_0101241.pdf',
'SOLICITA: Fernando Fernández Gómez',
'*******************************************',
'MANTENIMIENTO: Se modifica procedimiento para agrega el mantenimiento del nuevo catálogo ZONA, se agrega el nuevo ID 4',
'AUTOR: 95564047',
'FECHA: 2019/09/20',
'SUSTENTO: RQI 12 425 Nueva forma de reporte de planta activa en BancoN',
'FOLIO: 612',
'SOLICITA: Ricardo Recendiz';

CREATE PROCEDURE "informix".sp_obtienezonasbpl()
	RETURNING 	CHAR(5) 	AS CodigodeRetorno,
				CHAR(3) 	AS id_zona,
				CHAR(50)  	AS Nombre_zona;

---DECLARACIONES
DEFINE iSqlErr		INTEGER;
DEFINE iIsamErr		INTEGER;
DEFINE cCod_ret		CHAR(5);
DEFINE cId_zona		CHAR(3);
DEFINE cNombreZona	CHAR(50);


LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCod_ret	= '00000';
LET cId_zona	= '';
LET cNombreZona	= '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCod_ret = iSqlErr;
          RETURN cCod_ret,cId_zona,cNombreZona;
       END IF;
    END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/tmp/Cris/sp_obtienezonasbpl.out";
	--TRACE ON;
	
		FOREACH WITH HOLD		
			
			SELECT id_coordinacion, Nom_coordinacion
			INTO cId_zona,cNombreZona
			FROM  bdinteg:"informix".si_catczb_rh
			ORDER BY Nom_coordinacion
		
			RETURN cCod_ret,TRIM(cId_zona),TRIM(cNombreZona) WITH RESUME;
			
		END FOREACH
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCod_ret = "00002";			
		END IF;
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'FOLIO:612',
'AUTOR:Cristian Valentina Aguilar ', 
'FECHA:2019-09-03',
'DESCRIPCIÔ: Se genera procedimiento que regresa las zonas de Bancoppel, este procedimiento serÃ¡ utilizador por',
'			 Bancon0005.exe en el dialogo de administraciÃ³n de centros de costos.',
'SOLICITA: Ricardo Resendiz';

CREATE PROCEDURE "informix".sp_ctedigital_actualizaestatus(pNumCte CHAR(20), pConsecutivo INTEGER, pEstatus_Envio INTEGER, pDescEstatus CHAR(200))

--RETORNOS-
RETURNING
CHAR(6)     AS codret;

--DECLARACION DE VARIABLES--
DEFINE iSql_err		    INTEGER; 
DEFINE cCodret		    CHAR(6);
DEFINE iConsecutivo     INTEGER;

--INICIALIZACION DE VARIABLES--
LET iSql_err		     = 0;
LET cCodret		         = '000000';
LET iConsecutivo         = 9;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/cyrv/sp_ctedigital_actualizaestatus.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	    
	/*
	ESTATUS_ENVIO:
		pEstatus_Envio = 0 --NO SE ENVIO LA TRAMA
		pEstatus_Envio = 2 --TRAMA RECIBIDA
		pEstatus_Envio = 3 --ERROR EN ENVIO/RECEPCION DE TRAMA
		pEstatus_Envio = 4 --TRAMA RECIBIDA CON no.CTE COPPEL
	*/
	  
	IF NVL(pNumCte,'') = '' OR NVL(pEstatus_Envio,9) NOT IN (0,2,3,4) OR NVL(pConsecutivo,0) = 0 THEN
		LET cCodret = '000001'; --ERROR EN LOS PARAMETROS
		RETURN TRIM(cCodret);
	END IF;
	  
	--************************************************************************************
	---------------****************BLOQUE DE CONSULTA*************************************
	--************************************************************************************
	
	--Se quitan espacios en blanco a variable entrada
	LET pNumCte = TRIM(pNumCte);
	
	--CAMBIA EL ESTATUS AL QUE HAYA SIDO INDICADO POR EL SERVICIO
	UPDATE "informix".si_clientes_digital 
	SET estatus_envio = pEstatus_Envio, error = pDescEstatus
	WHERE  num_cte_banco = pNumCte; --consecutivo = pConsecutivo AND
	
	RETURN TRIM(cCodret);	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO QUE ACTUALIZA EL ESTATUS_ENVIO DEL REGISTRO A COMO EL SERVICIO LO INDIQUE DEPENDIENDO SI HUBO EXITO O NO EN EL ENVIO DE LA TRAMA A E-COMMERCE.',
'FECHA: 15 DE NOVIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131115.1630';

CREATE PROCEDURE "informix".sp_upd_emp_gc3_exp()
				returning CHAR(5) AS Cod_Retorno;


DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cTicket			CHAR(20);
DEFINE cEmpleado		CHAR(10);
DEFINE cEmpresa			CHAR(4);
DEFINE cNumcte			CHAR(20);
DEFINE cParam			CHAR(50);
DEFINE cRuta			CHAR(100);
DEFINE cCmd1 			CHAR(500);
DEFINE cCmd2 			CHAR(500);
DEFINE dFecha			CHAR(100);
DEFINE dHora			CHAR(100);

--inicializando variables
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTicket = "" ;
LET cEmpleado = "" ;
LET cEmpresa = "" ;
LET cNumcte="";
LET cParam = "" ;
LET cCmd1 	 = '';
LET cCmd2 	 = '';
LET cRuta	 = '/RESPALDOSNEW/procesomasivo/';
LET dFecha	 ='date="$(date +"%x")"';
LET dHora	 ='hora="$(date +"%T")"';



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/CHVN/tmp/sp_upd_emp_gc.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO cParam
	FROM "informix".si_param
	WHERE cod_param = 308;		

	
--COMPARACION NOMBRES
		
	LET cCmd1 = "/usr/bin/echo '" || "SET ISOLATION TO DIRTY READ; UNLOAD TO '"|| TRIM(cRuta) ||"tmp_funciones.unl' "||" SELECT emp, nombre FROM si_funciones;" ||
	"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd1);

	LET cCmd1 = 'SELECT {+INDEX (si_cliente idx_si_cliente), AVOID_FULL(si_cliente)} numcte, apell_paterno ||" "|| apell_materno ||" "|| nombre1 ||" "|| nombre2 FROM si_cliente';
	LET cCmd1 = TRIM(cCmd1)|| ' WHERE tpo_persona = "01" AND tipo_cliente = 1 AND fecha_alta >= "'||TRIM(cParam)||'";';

	LET cCmd2 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO '"||TRIM(cRuta)||"tmp_clientes.unl' "
	||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd2);
	
	LET cCmd1 = "/usr/bin/awk -v "||TRIM(dFecha)||" -v "||TRIM(dHora)||" -v OFS='|' -F '|' 'NR==FNR{a[$2]=$1;next } $2 in a {print $1,a[$2],'3','0',date,hora,'1'}";
	LET cCmd2 = "' "||TRIM(cRuta)||"tmp_funciones.unl "||TRIM(cRuta)||"tmp_clientes.unl > "||TRIM(cRuta)||"tmp_compara.unl";
	SYSTEM TRIM(cCmd1)||TRIM(cCmd2);

	
	LET cCmd1 = "/usr/bin/echo '" || "SET ISOLATION TO DIRTY READ; DBLOAD FROM '"|| TRIM(cRuta) ||"tmp_compara.unl' "||
	" INSERT INTO si_empleado_cliente_coppel;" || "' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1"; 
	SYSTEM TRIM(cCmd1);

	
	SYSTEM '/usr/bin/rm -rf '||TRIM(cRuta)||'tmp_funciones.unl ' ||TRIM(cRuta)||'tmp_clientes.unl ' ||TRIM(cRuta)||'tmp_compara.unl';
				
	UPDATE si_param set valor = TODAY WHERE cod_param = 308;

	RETURN cCodRet;
END
END PROCEDURE;