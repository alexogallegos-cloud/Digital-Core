CREATE PROCEDURE "informix".sp_consultatargetphone(pVencido_min  INTEGER,
								pVencido_max  INTEGER, 
								pImporte_min  DECIMAL(18,2),
								pImporte_max  DECIMAL(18,2),
								pRegistros    INTEGER,
								pFecha_Ejec   DATE)
	RETURNING
		CHAR(5)  	AS CodRetorno,
		CHAR(20)	AS Cliente,
		CHAR(20)	AS Credito,
		CHAR(20)	AS Ciudad,
		CHAR(20)	AS Estado,
		CHAR(13)	AS Celular,
		CHAR(26)	AS Nombre1,
		CHAR(26)	AS Nombre2,
		CHAR(26)	AS ApellidoP,
		CHAR(26)	AS ApellidoM,
		DECIMAL(18,2) AS SaldVenInt,
		DECIMAL(18,2) AS PagoMini,
		DECIMAL(18,2) AS PagoMinSin,
		DECIMAL(18,2) AS PagoVenc;			
	
		--DECLARARACION DE VARIBLES
		DEFINE cSqlErr		INTEGER;
		DEFINE vCodRet 		CHAR(5);
		DEFINE vCliente 	CHAR(20);
		DEFINE vCredito 	CHAR(20);
		DEFINE vCiudad		CHAR(20);
		DEFINE vEstado		CHAR(20);
		DEFINE vCelular		CHAR(13);
		DEFINE vNombre1		CHAR(26);
		DEFINE vNombre2		CHAR(26);
		DEFINE vApellidoP	CHAR(26);
		DEFINE vApellidoM	CHAR(26);
		DEFINE deSaldVenInt	DECIMAL(18,2);
		DEFINE dePagoMini	DECIMAL(18,2);
		DEFINE dePagoMinSin	DECIMAL(18,2);
		DEFINE dePagoVenc	DECIMAL(18,2);
		DEFINE icontador 	INTEGER;
	
		--DEFINICION DE VARIABLES
		LET cSqlErr 		= 	0;
		LET vCodRet 		= 	"000";
		LET vCliente  		=   "";
		LET vCredito		=   "";
		LET vCiudad			=   "";
		LET vEstado 		=   "";
		LET vCelular		=   "";
		LET vNombre1		=   "";
		LET vNombre2		=   "";
		LET vApellidoP		=   "";
		LET vApellidoM		=   "";
		LET deSaldVenInt	= 	0.00;
		LET dePagoMini		= 	0.00;
		LET dePagoMinSin	= 	0.00;
		LET dePagoVenc		= 	0.00;
		LET icontador		=	0;
		
		--SET DEBUG FILE TO "/home/sysifx/SPs PAYAN/"informix".sp_consultatargetphone.out";
		--TRACE ON;
		BEGIN
			 ON EXCEPTION SET cSqlErr
		        IF cSqlerr <> 0 THEN
		            Let vCodRet = cSqlErr;
					RETURN vCodRet, NVL(vCliente,''), NVL(vCredito,''), NVL(vCiudad,''), NVL(vEstado,''), NVL(vCelular,''), NVL(vNombre1,''), NVL(vNombre2,''), NVL(vApellidoP,''), NVL(vApellidoM,''),
							NVL(deSaldVenInt,0), NVL(dePagoMini,0), NVL(dePagoMinSin,0), NVL(dePagoVenc,0);
				END IF;
			END EXCEPTION;
			
			SET LOCK MODE TO WAIT 3;
			
			--se valida la integridad de los datos de entrada
			IF (pVencido_min IS NULL) OR ( pVencido_max IS NULL) OR (pImporte_min IS NULL) OR 
				(pImporte_max IS NULL) OR (pRegistros IS NULL)OR (pFecha_Ejec IS NULL) THEN
				Let vCodRet = "001";
					RETURN vCodRet, NVL(vCliente,''), NVL(vCredito,''), NVL(vCiudad,''), NVL(vEstado,''), NVL(vCelular,''), NVL(vNombre1,''), NVL(vNombre2,''), NVL(vApellidoP,''), NVL(vApellidoM,''),
							NVL(deSaldVenInt,0), NVL(dePagoMini,0), NVL(dePagoMinSin,0), NVL(dePagoVenc,0);
			ELSE
				IF (pVencido_min < 0) OR ( pVencido_max < 0) OR (pImporte_min < 0) OR 
					(pImporte_max < 0) OR (pRegistros < 0)THEN
					Let vCodRet = "002";
					RETURN vCodRet,vCliente,vCredito,vCiudad,vEstado,vCelular,NVL(vNombre1,''),NVL(vNombre2,''),NVL(vApellidoP,''),NVL(vApellidoM,''),
							NVL(deSaldVenInt,0),NVL(dePagoMini,0),NVL(dePagoMinSin,0),NVL(dePagoVenc,0);
				END IF;
			END IF;
			
			IF pRegistros = 0 THEN
				FOREACH
					--se obtiene los datos necesarios completos para  la generacion del archivo
					--SELECT cliente,credito,ciudad,estado,t_celular,sdo_venc_int_mora,pago_min,pago_min_sin_vdo,pago_venc  --original
					SELECT first pRegistros cliente,credito,ciudad,estado,t_celular,sdo_venc_int_mora,pago_min,pago_min_sin_vdo,pago_venc 
					INTO  vCliente,vCredito,vCiudad,vEstado,vCelular,deSaldVenInt,dePagoMini,dePagoMinSin,dePagoVenc
					FROM bdicobranza:"informix".cb_info_administrativa 
					WHERE fecha_ejecucion = pFecha_Ejec
					--AND t_celular IS not NULL
					AND pago_venc BETWEEN pVencido_min AND pVencido_max 
					AND pago_min BETWEEN  pImporte_min AND pImporte_max
					AND t_celular <> "0"
					AND NOT t_celular IS NULL
					AND TRIM(t_celular) <> ''	
					AND num_campania = 5 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 5. 
					
					IF LENGTH(vCelular) = 13 THEN
						LET vCelular = SUBSTR(vCelular,4,10);
					ELIF LENGTH(vCelular) = 12 THEN
						LET vCelular = SUBSTR(vCelular,3,10);
					ELIF LENGTH(vCelular) = 11 THEN
						LET vCelular = SUBSTR(vCelular,2,10);
					END IF;
					
					SELECT nombre1,nombre2,apell_paterno,apell_materno 
					INTO vNombre1,vNombre2,vApellidoP,vApellidoM
					FROM bdinteg:"informix".si_cliente 
					WHERE numcte = vCliente;
					
					LET icontador = icontador + 1;
					
					RETURN vCodRet, NVL(vCliente,''), NVL(vCredito,''), NVL(vCiudad,''), NVL(vEstado,''), NVL(vCelular,''), NVL(vNombre1,''), NVL(vNombre2,''), NVL(vApellidoP,''), NVL(vApellidoM,''),
							NVL(deSaldVenInt,0), NVL(dePagoMini,0), NVL(dePagoMinSin,0), NVL(dePagoVenc,0)WITH RESUME;
				END FOREACH
			ELSE
				FOREACH
					--se obtiene los datos necesarios completos para  el grid
					SELECT FIRST pRegistros cliente,credito,ciudad,estado,t_celular,sdo_venc_int_mora,pago_min,pago_min_sin_vdo,pago_venc 
					INTO  vCliente,vCredito,vCiudad,vEstado,vCelular,deSaldVenInt,dePagoMini,dePagoMinSin,dePagoVenc
					FROM bdicobranza:"informix".cb_info_administrativa
					WHERE fecha_ejecucion = pFecha_Ejec
					--AND t_celular IS not NULL
					AND pago_venc BETWEEN pVencido_min AND pVencido_max 
					AND pago_min BETWEEN  pImporte_min AND pImporte_max
					AND t_celular <> "0"
					AND NOT t_celular IS NULL
					AND TRIM(t_celular) <> '' 
					AND num_campania = 5 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 5. 
					
					IF LENGTH(vCelular) = 13 THEN
						LET vCelular = SUBSTR(vCelular,4,10);
					ELIF LENGTH(vCelular) = 12 THEN
						LET vCelular = SUBSTR(vCelular,3,10);
					ELIF  LENGTH(vCelular) = 11 THEN
						LET vCelular = SUBSTR(vCelular,2,10);
					END IF;
					
					SELECT nombre1,nombre2,apell_paterno,apell_materno 
					INTO vNombre1,vNombre2,vApellidoP,vApellidoM
					FROM bdinteg:"informix".si_cliente 
					WHERE numcte = vCliente;
					
					LET icontador = icontador + 1;
					
					RETURN vCodRet, NVL(vCliente,''), NVL(vCredito,''), NVL(vCiudad,''), NVL(vEstado,''), NVL(vCelular,''), NVL(vNombre1,''), NVL(vNombre2,''), NVL(vApellidoP,''), NVL(vApellidoM,''),
							NVL(deSaldVenInt,0), NVL(dePagoMini,0), NVL(dePagoMinSin,0), NVL(dePagoVenc,0)WITH RESUME;
				END FOREACH
			END IF;
			IF icontador  = 0 THEN
				Let vCodRet = "003";
				RETURN vCodRet, NVL(vCliente,''), NVL(vCredito,''), NVL(vCiudad,''), NVL(vEstado,''), NVL(vCelular,''), NVL(vNombre1,''), NVL(vNombre2,''), NVL(vApellidoP,''), NVL(vApellidoM,''),
							NVL(deSaldVenInt,0), NVL(dePagoMini,0), NVL(dePagoMinSin,0), NVL(dePagoVenc,0);
			END IF;			
								
		END;
END PROCEDURE
 DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Proyecto: Mtto-AdminComapañas',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Extrae la informacion necesaria para la generacion de archivo y el llenado del grid',
'Fecha: 2010/06/24',
'Version: 20100624.0847',
'BD: bdicobranza',

'MODIFICO: Guadalupe Payan',
'Proyecto: Mensajes SMS',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Se le agrego el filtro (num_campania = 5),a los Query de Consulta',
'Fecha: 2011/05/12',
'Version: 20110512.1256',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_obtienecobranzaadministrativa(pVencido_min  INTEGER,
													pVencido_max  INTEGER, 
													pImporte_min  DECIMAL(18,2),
													pImporte_max  DECIMAL(18,2),
													pRegistros    INTEGER,
													pFecha_Ejec   DATE,
													pSituacion    CHAR(7),
													pCausa        SMALLINT)

	RETURNING 	CHAR(6),
				CHAR(20),
				CHAR(20),
				CHAR(20),
				CHAR(20),
				CHAR(20),	          
				CHAR(50),
				CHAR(50),
				CHAR(50),			  
				CHAR(50),				
				CHAR(13),				
				DECIMAL(18,2),
				DECIMAL(18,2),
				DECIMAL(18,2),				
				SMALLINT;

	---Elaborado por: Lorenzo Ibarra Garcia
	--Fecha: 05-10-2009
	--Objetivo: Obtener registros para la campaña administrativa del CAT filtrando por los parámetros.

	-- Modifico: José Almeida.
	-- Fecha: 28 de enero de 2010.
	-- Se modifico para que reciba la fecha de ejecucion y filtre por esta.

	--Modifico: Adilene Lara                                          
	--Fecha: 03-03-2010                         
	--Se modifica para que el filtro se realice por el campo pago_min 
	--Se agregan los campos situacion y causa como parametros de entrada
	--Se excluye cualquier cliente con apellido o nombre Coppel
	--Si el campo f_ult_pago_monto tiene un valor nulo o esta en blanco se inserta la palabra 'GOL'
	--Se modifica para que ademas de generar el archivo correspondiente en la ruta actual, se guarde en el servidor.

	--Fecha: 15-04-2010
	--Se modifica para que inserte la palabra GOL en el archivo generado, si el campo f_ult_pago_monto tiene un valor nulo o esta en blanco.
	--Se modifica para recibir como valor "Todas" para el parametro situacion y mostrar los registros sin importar si tienen o no una situacion especial y causa.

	-- Modificación: Paul Ivan Quintero Varela
	-- Fecha: 02-06-2010
	-- Comentarios: Se modifica con la finalidad de que se genere el archivo de salida al servidor ya que se reporta por el usuario
	--              que actualmente el archivo se genera en 0.

	 --SE DEFINEN VARIABLES.
	DEFINE vcodret                 CHAR(6);
	DEFINE vsqlerr                 INTEGER;
	DEFINE v_cliente               CHAR(20);
	DEFINE v_credito               CHAR(20);
	DEFINE v_tarjeta               CHAR(20);
	DEFINE v_ciudad                CHAR(20);
	DEFINE v_estado                CHAR(20);				
	DEFINE v_t_celular             CHAR(13);				
	DEFINE v_sdo_total             DECIMAL(18,2);
	DEFINE v_pago_min              DECIMAL(18,2);
	DEFINE v_sdo_venc_int_mora     DECIMAL(18,2);	
	DEFINE v_pago_venc             SMALLINT;
	DEFINE v_situacion             CHAR(7);
	DEFINE v_causa                 SMALLINT;
	DEFINE cCausa                  CHAR(5);
	DEFINE cSql                    CHAR(2024);
	DEFINE cRuta                   CHAR(100);
	DEFINE Nsituacion              CHAR(7);

	DEFINE Ndia                    CHAR(2);
	DEFINE Nmes                    CHAR(2);
	DEFINE Nyear                   CHAR(4);
	---se definen nuevas variables para aguardar el nombre y el apellido por separado.
	DEFINE cNombre1 				CHAR(50);
	DEFINE cNombre2 				CHAR(50);
	DEFINE cApellidoP 				CHAR(50);
	DEFINE cApellidoM 				CHAR(50);

	--SE INICIALIZAN VARIABLES.
	LET vcodret                    = '000';
	LET vsqlerr                    = 0;
	LET v_cliente                  = '';
	LET v_credito                  = '';
	LET v_tarjeta                  = '';
	LET v_ciudad                   = '';
	LET v_estado                   = '';		
	LET v_t_celular                = '';				
	LET v_sdo_total                = 0;
	LET v_pago_min                 = 0;
	LET v_sdo_venc_int_mora        = 0;	
	LET v_pago_venc                = 0;
	LET v_situacion                = '';
	LET v_causa                    = 0;
	LET cSql                       = '';
	LET cRuta                      = '';
	LET cCausa                     = '';
	--se inicializan nuevas variables para aguardar el nombre y el apellido por separado.
	LET cNombre1 		= '';
	LET cNombre2 		= '';
	LET cApellidoP 		= ''; 
	LET cApellidoM 		= ''; 

	IF DAY(pFecha_Ejec) < 10 THEN
	    LET Ndia = '0' || DAY(pFecha_Ejec);
	ELSE
	    LET Ndia = DAY(pFecha_Ejec);
	END IF;

	IF MONTH(pFecha_Ejec) < 10 THEN
	    LET Nmes = '0' || MONTH(pFecha_Ejec);
	ELSE
	    LET Nmes = MONTH(pFecha_Ejec);
	END IF;

	LET Nyear = YEAR(pFecha_Ejec);

	--SET DEBUG FILE TO '/home/sysifx/SPs PAYAN/"informix".sp_obtienecobranzaadministrativa.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET vsqlerr
		 
		 	LET vcodret = vsqlerr;
		
			IF vcodret = '-668' THEN
				LET vcodret = '001'; --'No se encuentra archivo para cargar o no cumple con la validación para ser cargado.'
			  --LET cMensajeRet ='No se encuentra archivo para cargar o no cumple con la validación para ser cargado.';
			END IF;

			IF vsqlerr <> 0 THEN
				RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0);				
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

		IF pVencido_min IS NULL OR pVencido_max IS NULL OR pImporte_min IS NULL OR pImporte_max IS NULL OR pRegistros IS NULL THEN
			LET vcodret = '002'; -- Parametros no validos
			RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0);									
		END IF;

		IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 OR pRegistros < 0 THEN
			LET vcodret = '003'; -- los parametros numericos recibidos deben ser positivos
			RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0);							
		END IF;

		IF (pSituacion = "Ninguna") THEN
			LET pSituacion = NULL;
		END IF;

		IF (pCausa = 0) THEN
			LET pCausa = NULL;
		END IF;

		IF psituacion = "Todas" AND pCausa IS NULL THEN
			IF NOT EXISTS(SELECT cliente 
							FROM bdicobranza:"informix".cb_info_administrativa 
							WHERE num_campania = 1
							    AND pago_venc >= pVencido_min AND pago_venc <= pVencido_max
								AND pago_min >= pImporte_min AND pago_min <= pImporte_max
								AND fecha_ejecucion = pFecha_Ejec								
								AND UPPER (TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) NOT LIKE "%COPPEL%") THEN      
				LET vcodret = '004'; -- no hay registros para los criterios pasados como parametros
				RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0);								
			END IF;

			IF pSituacion IS NULL THEN
				LET pSituacion = ' ';
			ELSE
				LET Nsituacion = pSituacion;
			END IF;

			IF pCausa IS NULL THEN
				LET cCausa = ' ';
			ELSE
				LET cCausa = pCausa;
			END IF;

			SELECT valor 
			INTO cRuta 
			FROM bdicobranza:"informix".cb_param 
			WHERE cod_param = 1;

			LET cSql = 'echo "unload to ' || TRIM(NVL(cRuta,' ')) || 'administrativa_' || TRIM(NVL(pSituacion,' ')) || TRIM(NVL(cCausa,' ')) || '_' || Ndia || Nmes || Nyear || '.txt';
			LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) ||
						' select cliente, credito,tarjeta, ciudad,'
						|| ' estado, nombre1, nombre2, apell_paterno, apell_materno, t_celular'
						|| ' sdo_total, pago_min, sdo_venc_int_mora, pago_venc, situacion, causa' ||
						' from bdicobranza:"informix".cb_info_administrativa where pago_venc >= ' || pVencido_min || ' and pago_venc <= ' || pVencido_max
						|| ' and pago_min >= ' || pImporte_min || ' and pago_min <= ' || pImporte_max ||
						' and fecha_ejecucion =''' || pFecha_Ejec || '''' ;

			IF (TRIM(pSituacion) = "Todas") THEN
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion is not null or situacion <> ' || '''" "''';
				ELIF (TRIM(pSituacion) = "Ninguna" OR TRIM(pSituacion) = '') THEN	
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion is null or situacion = ' || '''" "''';
			ELSE
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion = ' || pSituacion::CHAR(7);
			END IF;

			IF (NVL(pCausa,"") = "") THEN
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa is ' || 'null';
			ELSE
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa = ' || pCausa;
			END IF; 

			LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' and upper(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) not like ''%COPPEL%''" > /tmp/muestra_cartera.sql';

			SYSTEM SUBSTR(cSql,1,LENGTH(cSql));             
			SYSTEM 'dbaccess bdicobranza /tmp/muestra_cartera.sql';

			IF pRegistros = 0 THEN
			
				FOREACH
					SELECT cliente, credito, tarjeta, ciudad, estado, nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
						sdo_total, pago_min, sdo_venc_int_mora, pago_venc, situacion, causa
					INTO v_cliente, v_credito, v_tarjeta, v_ciudad, v_estado, cNombre1, cNombre2, cApellidoP, cApellidoM, v_t_celular, 
						v_sdo_total, v_pago_min, v_sdo_venc_int_mora, v_pago_venc, v_situacion, v_causa
					FROM bdicobranza:"informix".cb_info_administrativa
					WHERE pago_venc >= pVencido_min AND pago_venc <= pVencido_max
						AND pago_min  >= pImporte_min AND pago_min  <= pImporte_max
						AND fecha_ejecucion = pFecha_Ejec
						AND UPPER(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) NOT LIKE "%COPPEL%"
						AND num_campania = 1 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 1. 

				
					RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0)  WITH RESUME;
				END FOREACH;
				
			ELSE
			
				FOREACH
					SELECT FIRST pRegistros cliente, credito, tarjeta, ciudad, estado, nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
						sdo_total, pago_min, sdo_venc_int_mora, pago_venc, situacion, causa
					INTO v_cliente, v_credito, v_tarjeta, v_ciudad, v_estado, cNombre1, cNombre2, cApellidoP, cApellidoM, v_t_celular, 
						v_sdo_total, v_pago_min, v_sdo_venc_int_mora, v_pago_venc, v_situacion, v_causa
					FROM bdicobranza:"informix".cb_info_administrativa
					WHERE pago_venc >= pVencido_min AND pago_venc <= pVencido_max
						AND pago_min >= pImporte_min AND pago_min <= pImporte_max
						AND fecha_ejecucion = pFecha_Ejec
						AND UPPER(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) NOT LIKE "%COPPEL%"
						AND num_campania = 1 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 1. 
					
					RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
						NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
						NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0) WITH RESUME;
				END FOREACH;
				
			END IF;

			--Si ha seleccionado en el combo situacion "Ninguna" o una opcion del listado de situaciones
		ELSE
			IF NOT EXISTS(SELECT cliente 
							FROM bdicobranza:"informix".cb_info_administrativa 
							WHERE num_campania = 1
								AND pago_venc >= pVencido_min AND pago_venc <= pVencido_max
								AND pago_min >= pImporte_min AND pago_min <= pImporte_max
								AND fecha_ejecucion = pFecha_Ejec
								AND NVL(situacion,'') = NVL(pSituacion,'')
								AND NVL(causa,0) = NVL(pCausa,0)								
								AND UPPER(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) NOT LIKE "%COPPEL%") THEN
				LET vcodret = '004'; -- no hay registros para los criterios pasados como parametros
				RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0);								
			END IF;

			IF pSituacion IS NULL THEN
				LET pSituacion = ' ';
			ELSE
				LET Nsituacion = pSituacion;
			END IF;

			IF pCausa IS NULL THEN
				LET cCausa = ' ';
			ELSE
				LET cCausa = pCausa;
			END IF;

			SELECT valor 
			INTO cRuta 
			FROM bdicobranza:"informix".cb_param 
			WHERE cod_param = 1;

			LET cSql = 'echo "unload to ' || TRIM(NVL(cRuta,' ')) || 'administrativa_' || TRIM(NVL(pSituacion,' ')) || TRIM(NVL(cCausa,' ')) || '_' || Ndia || Nmes || Nyear || '.txt';
			LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) ||
						' select cliente, credito,tarjeta, ciudad,'
						|| ' estado, nombre1, nombre2, apell_paterno, apell_materno, t_celular'
						|| ' sdo_total, pago_min, sdo_venc_int_mora, pago_venc, situacion, causa' ||
						' from bdicobranza:"informix".cb_info_administrativa where pago_venc >= ' || pVencido_min || ' and pago_venc <= ' || pVencido_max
						|| ' and pago_min >= ' || pImporte_min || ' and pago_min <= ' || pImporte_max ||
						' and fecha_ejecucion =''' || pFecha_Ejec || '''' ;

			IF  NVL(pSituacion,'') <> '' THEN
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion = ''' || pSituacion ::CHAR(7) || '''';
			END IF;

			IF pCausa IS NOT NULL THEN
				LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa = ''' || pCausa || '''';				
			END IF;

			LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' and upper(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) not like ''%COPPEL%''" > /tmp/muestra_cartera.sql';

			SYSTEM SUBSTR(cSql,1,LENGTH(cSql));             
			SYSTEM 'dbaccess bdicobranza /tmp/muestra_cartera.sql';
						

			IF pRegistros = 0 THEN
			
				FOREACH
					SELECT cliente, credito, tarjeta, ciudad, estado, nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
						sdo_total, pago_min, sdo_venc_int_mora, pago_venc, situacion, causa
					INTO v_cliente, v_credito, v_tarjeta, v_ciudad, v_estado, cNombre1, cNombre2, cApellidoP, cApellidoM, v_t_celular, 
						v_sdo_total, v_pago_min, v_sdo_venc_int_mora, v_pago_venc, v_situacion, v_causa
					FROM bdicobranza:"informix".cb_info_administrativa
					WHERE pago_venc >= pVencido_min AND pago_venc <= pVencido_max
						AND pago_min >= pImporte_min AND pago_min <= pImporte_max
						AND fecha_ejecucion = pFecha_Ejec
						AND NVL(situacion,'') = NVL(pSituacion,'')
						AND NVL(causa,0) = NVL(pCausa,0)
						AND UPPER(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) NOT LIKE "%COPPEL%"
						AND num_campania = 1 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 1. 

					RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0) WITH RESUME;
				END FOREACH;
				
			ELSE
			
				FOREACH
					SELECT FIRST pRegistros cliente, credito, tarjeta, ciudad, estado, nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
						sdo_total, pago_min, sdo_venc_int_mora, pago_venc, situacion, causa  
					INTO v_cliente, v_credito, v_tarjeta, v_ciudad, v_estado, cNombre1, cNombre2, cApellidoP, cApellidoM, v_t_celular, 
						v_sdo_total, v_pago_min, v_sdo_venc_int_mora, v_pago_venc, v_situacion, v_causa
					FROM bdicobranza:"informix".cb_info_administrativa
					WHERE pago_venc >= pVencido_min AND pago_venc <= pVencido_max
						AND pago_min >= pImporte_min AND pago_min <= pImporte_max
						AND fecha_ejecucion = pFecha_Ejec
						AND NVL(situacion,'') = NVL(pSituacion,'')
						AND NVL(causa,0) = NVL(pCausa,0)
						AND UPPER(TRIM (nombre1)|| TRIM (nombre2)|| TRIM (apell_paterno)|| TRIM (apell_materno)) NOT LIKE "%COPPEL%"
						AND num_campania = 1 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 1. 

					RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_tarjeta,''), NVL(v_ciudad,''), NVL(v_estado,''), 
					NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellidoP,''),NVL(cApellidoM,''), NVL(v_t_celular,''),
					NVL(v_sdo_total,0), NVL(v_pago_min,0), NVL(v_sdo_venc_int_mora,0), NVL(v_pago_venc,0) WITH RESUME;
				END FOREACH;
				
			END IF;
		END IF;
	END;
END PROCEDURE

DOCUMENT
'MODIFICO: Guadalupe Payan',
'Proyecto: Mensajes SMS',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Se le agrego el filtro (num_campania = 1),a los Query de Consulta y',
'             Se obtuvo el nombre del cliente por separado los nombres y el apellido',
'Fecha: 2011/05/24',
'Version: 20110524.1200',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_generapagominincompleto()
	RETURNING
		CHAR(6) AS CodRetorno;			

	--DECLARARACION DE VARIBLES
	DEFINE iSqlErr						INTEGER;
	DEFINE cCodRet 						CHAR(6);
	DEFINE cCodRetPrimUlt				CHAR(6);
	DEFINE cEmpresa     				CHAR(3);
	DEFINE cNumCredito  				CHAR(20);
	DEFINE cNumCte  					CHAR(20);
    DEFINE cCiudad 						CHAR(20);
	DEFINE cEstado 						CHAR(20);
	DEFINE cCelular			 			CHAR(13);
	DEFINE dtFechaHoy					DATE;	
	DEFINE sDiaCorte                 	SMALLINT;
	DEFINE dtFechaUltpago 				DATE;
	DEFINE dtFechaCorte                 DATE;
	DEFINE dtFechaPrimeroMes            DATE;
	DEFINE dtFechaUltimoMes             DATE;	
    DEFINE dMonto                       DECIMAL(18,2);
	---Se definen nuevas variables para aguardar el nombre y el apellido por separado.
	DEFINE cNombre1 					CHAR(50);
	DEFINE cNombre2 					CHAR(50);
	DEFINE cApellidoP 					CHAR(50);
	DEFINE cApellidoM 					CHAR(50);    
    DEFINE cNumProducto 				CHAR(4);	
	DEFINE sNumCampania     			SMALLINT;
	DEFINE cSituacion                   CHAR(1);
	DEFINE sCausa                       SMALLINT;
	DEFINE sMes                         SMALLINT;
	--Declaracion de Variables del sp_consulta_saldos_general
	DEFINE cCodRetSalGral 				CHAR(6);
	DEFINE cMensajeRet 					CHAR(80);
	DEFINE cNumCreditoSalGral			CHAR(20);
	DEFINE cCodTipCred 					CHAR(2);
	DEFINE dtFechaOrigen 				DATE;
	DEFINE dtFechaProxPago 				DATE;
	DEFINE  dPagoMinimo					DECIMAL(18,2);
	DEFINE  dtFechaUltPagoSalGral		DATE;
	DEFINE  iPlazo						INTEGER;
	DEFINE  iPagosRealizados			INTEGER;
	DEFINE  dLineaOtorgada				DECIMAL(18,2);
	DEFINE  dTasaInteres				DECIMAL(9,6);
	DEFINE  dTasaMoratorios				DECIMAL(9,6);
	DEFINE  dMontoSBC					DECIMAL(14,2);
	DEFINE  dCapVig						DECIMAL(18,2);
	DEFINE  dCapTrans					DECIMAL(18,2);
	DEFINE  dCapVdoExig					DECIMAL(18,2);
	DEFINE  dCapVdoNoExig				DECIMAL(18,2);
	DEFINE  dSdoActCap					DECIMAL(18,2);
	DEFINE  dIntVig						DECIMAL(18,2);
	DEFINE  dIntVdo						DECIMAL(18,2);
	DEFINE  dIntMoratorio				DECIMAL(18,2); 
	DEFINE  dIntMes						DECIMAL(18,2);
	DEFINE  dSdoActInt					DECIMAL(18,2);
	DEFINE  dIvaIntVig					DECIMAL(18,2);	
	DEFINE  dIvaIntVdo					DECIMAL(18,2); 
	DEFINE  dIvaIntMoratorio			DECIMAL(18,2);
	DEFINE  dIvaIntMes					DECIMAL(18,2);
	DEFINE  dSdoActIvaInt				DECIMAL(18,2);
	DEFINE  dComPend					DECIMAL(18,2);
	DEFINE  dIvaCom						DECIMAL(18,2);
    DEFINE  dSdoRetenido				DECIMAL(18,2);
	DEFINE  dSdoTotalLiq				DECIMAL(18,2);
	DEFINE  dIntDevengado				DECIMAL(18,2);
	DEFINE  dIvaIntDevengado			DECIMAL(18,2);
	DEFINE  dLineaDisponible			DECIMAL(18,2);
	DEFINE  dPagosVdos					DECIMAL(18,2);
	DEFINE  cDescStatusCred				CHAR(60);
	DEFINE  iIdUnidadProd				INTEGER;
	DEFINE  cDescBloqueoCta				CHAR(60);
	DEFINE  cCodCaract2					CHAR(3);
	DEFINE  cDescCausaBloqueoCta		CHAR(50);
	DEFINE  cSitCte						CHAR(1);
	DEFINE  cCausaCte					INTEGER;
	DEFINE  cDescSitEspCte				CHAR(75);
	DEFINE  cSitCred					CHAR(1);
	DEFINE  cCausaCred					INTEGER;
	DEFINE  cDescSitEspCred				CHAR(75);
	DEFINE  cDiasValidados				CHAR(2);
	
	--INICIALIZACION DE VARIABLES 
	LET iSqlErr 				= 0;
	LET cCodRet 				= "000";
	LET cCodRetPrimUlt 			= "";
	LET cEmpresa     			= '';
	LET cNumCredito  			= '';
	LET cNumCte  				= '';
	LET cCiudad  				= '';
	LET cEstado 				= '';
	LET cCelular 				= '';
	LET dtFechaHoy      		= '';
	LET dtFechaCorte    		='';
	LET sDiaCorte       		= 20;
	LET dtFechaUltpago 			= '';	
    LET dMonto         			= 0;	
	--Se Inicializan nuevas variables para aguardar el nombre y el apellido por separado.
	LET cNombre1 				= '';
	LET cNombre2 				= '';
	LET cApellidoP 				= ''; 
	LET cApellidoM 				= ''; 	
	LET cNumProducto            = '';
	LET sNumCampania            = 0;
	LET cSituacion              = '';
	LET sCausa                  = 0;
	LET sMes                    = 0;
	LET  dtFechaPrimeroMes		= DATE(1);
	LET  dtFechaUltimoMes		= DATE(1);
	LET  cDiasValidados			= "";
		--Variables del sp_consulta_saldos_general
	LET  cCodRetSalGral			= "";
	LET  cMensajeRet			= "";
	LET  cNumCreditoSalGral		= "";
	LET  cCodTipCred			= "";
	LET  dtFechaOrigen			= DATE(1);
	LET  dtFechaProxPago		= DATE(1);
	LET  dPagoMinimo			= 0;
	LET  dtFechaUltPagoSalGral	= DATE(1);
	LET  iPlazo					= 0;
	LET  iPagosRealizados		= 0;
	LET  dLineaOtorgada			= 0;
	LET  dTasaInteres			= 0;
	LET  dTasaMoratorios		= 0;
	LET  dMontoSBC				= 0;
	LET  dCapVig				= 0;
	LET  dCapTrans				= 0;
	LET  dCapVdoExig			= 0;
	LET  dCapVdoNoExig			= 0;
	LET  dSdoActCap				= 0;
	LET  dIntVig				= 0;
	LET  dIntVdo				= 0;
	LET  dIntMoratorio			= 0;
	LET  dIntMes				= 0;
	LET  dSdoActInt				= 0;
	LET  dIvaIntVig				= 0;
	LET  dIvaIntVdo				= 0;
	LET  dIvaIntMoratorio		= 0;
	LET  dIvaIntMes				= 0;
	LET  dSdoActIvaInt			= 0;
	LET  dComPend				= 0;
	LET  dIvaCom				= 0;
    LET  dSdoRetenido			= 0;
	LET  dSdoTotalLiq			= 0;
	LET  dIntDevengado			= 0;
	LET  dIvaIntDevengado		= 0;
	LET  dLineaDisponible		= 0;
	LET  dPagosVdos				= 0;
	LET  cDescStatusCred		= "";
	LET  iIdUnidadProd			= 0;
	LET  cDescBloqueoCta		= "";
	LET  cCodCaract2			= "";
	LET  cDescCausaBloqueoCta	= "";
	LET  cSitCte				= "";
	LET  cCausaCte				= 0;
	LET  cDescSitEspCte			= "";
	LET  cSitCred				= "";
	LET  cCausaCred				= 0;
	LET  cDescSitEspCred		= "";
	
	--SET DEBUG FILE TO "/home/sysifx/Antonio/sp_generapagominincompleto.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				Let cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		SET ISOLATIon TO dirty READ; 
		DELETE bdicobranza:"informix".cb_info_administrativa WHERE num_campania = 7;
		
		--obtengo el numero de producto de la campaña 7
		SELECT num_campania,num_producto
		INTO sNumCampania,cNumProducto
		FROM bdicobranza:"informix".cb_cat_campania
		WHERE num_campania = 7
		  AND empresa = '001';
		
		--obtengo la fecha de hoy.
		SELECT NVL(fecha_hoy,'')
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';
		LET sMes = MONTH(dtFechaHoy);
		
		IF sMes = 1 THEN 
			EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (12,YEAR(dtFechaHoy - 1)) INTO cCodRetPrimUlt,dtFechaPrimeroMes,dtFechaUltimoMes;
		ELSE 
			EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (sMes - 1 ,YEAR(dtFechaHoy)) INTO cCodRetPrimUlt,dtFechaPrimeroMes,dtFechaUltimoMes;
		END IF;
		
		
		IF DAY(dtFechaHoy) >= DAY (dtFechaUltimoMes) THEN
			LET cDiasValidados = DAY (dtFechaUltimoMes);
		ELSE
			LET cDiasValidados = DAY(dtFechaHoy);
		END IF;
		
		--obtengo la fecha de corte inmediato anterior.							
		LET dtFechaCorte  = MDY(MONTH(dtFechaPrimeroMes),LPAD(cDiasValidados,2,'0'),YEAR(dtFechaPrimeroMes));	
		LET dtFechaCorte  = dtFechaCorte::DATE;
		insert into cb_bitacora (mensaje) values (dtFechaCorte); 
		FOREACH	 		   				
			 --obtengo el credito, ciudad y estado del cliente			
			SELECT NVL(a.empresa,''), NVL(a.credito,''), NVL(a.cliente,''), NVL(a.ciudad,''),NVL(a.estado,''), 
					NVL(b.fecha_ult_pago,''),NVL(situacion,''),NVL(causa,0)
			INTO cEmpresa, cNumCredito, cNumCte, cCiudad, cEstado, dtFechaUltpago,cSituacion,sCausa				
			FROM bdicobranza:"informix".cb_ctes_mensajes a, bdicred:"informix".sd_maecredanexo b
			WHERE a.empresa = '001'
        AND a.empresa = b.empresa
				AND a.credito = b.num_credito
				AND b.fecha_ult_pago::DATE > dtFechaCorte::DATE
				AND a.producto = '6001'			

			FOREACH	
				
				---obtengo el nombre del cliente por separado
				SELECT NVL(TRIM(nombre1),''), NVL(TRIM(nombre2),''), NVL(TRIM(apell_paterno),''), NVL(TRIM(apell_materno),'')
				INTO cNombre1,cNombre2,cApellidoP,cApellidoM
				FROM bdinteg:"informix".si_cliente
				WHERE empresa = cEmpresa
					AND numcte = cNumCte

				--obtengo el celular del cliente.
				SELECT NVL(a.telefono2,'')
				INTO cCelular
				FROM bdinteg:"informix".si_direcciones a
				WHERE a.numcte = cNumCte
				AND a.secuencia = (SELECT NVL(MAX(b.secuencia),0) 
									FROM bdinteg:"informix".si_direcciones b 
									WHERE b.numcte = a.numcte);
				
				--obtengo el pago minimo.			
				EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general (cEmpresa,cNumCredito)
				INTO 	cCodRetSalGral, cMensajeRet, cNumCreditoSalGral, cCodTipCred, dtFechaOrigen, dtFechaProxPago,
						dPagoMinimo, dtFechaUltPagoSalGral, iPlazo,iPagosRealizados, dLineaOtorgada,
						dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
						dCapVdoNoExig,dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
						dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt,
						dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado, dIvaIntDevengado, dLineaDisponible,
						dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2, 
						cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred,
						cCausaCred, cDescSitEspCred;
						
				--valido si truena el sp por un error controlado o un error de informix.		
				IF cCodRetSalGral > "000000" THEN				 				  	
					CONTINUE FOREACH;
				ELIF cCodRetSalGral < "000000" THEN 
						LET cCodRet =  '001'; ---error informix de sp_consulta_saldos_general 
						EXIT FOREACH;							
				END IF ;
			
				--obtengo el monto.
				SELECT NVL(sum (a.monto),0)
				INTO dMonto
				FROM bdicred:"informix".sd_movhiscrd a
				WHERE a.empresa = cEmpresa
				AND a.fecha_mov = dtFechaUltpago
				AND a.num_credito = cNumCredito
				AND a.secuencia = ( SELECT NVL(MAX(b.secuencia),0) 
									FROM bdicred:"informix".sd_movhiscrd b 
									WHERE a.empresa = b.empresa 				
										AND a.num_credito = b.num_credito)
				AND a.codigo_fun IN ('033','334','335','336','901','337')
				AND a.codigo_ref IN ( 1, 901)
				AND a.reversado = 'N';
				
				IF dMonto = '' OR dMonto IS NULL THEN 
				   CONTINUE FOREACH;
				END IF;
				
				--valido el monto 
				IF dMonto < dPagoMinimo THEN 					
					--inserta informacion recabada 							
					INSERT INTO bdicobranza:"informix".cb_info_administrativa(empresa,num_campania,producto,fecha_ejecucion,cliente,credito,cuenta,tarjeta,ciudad,estado,nombre1,nombre2,
																	apell_paterno,apell_materno,t_celular,sdo_total,pago_min,fecha_pago,sdo_venc_int_mora,pago_venc,
																	pago_min_sin_vdo,situacion,causa)
																	VALUES(cEmpresa,sNumCampania,cNumProducto,dtFechaHoy,cNumCte,cNumCredito,'', '',cCiudad, cEstado,cNombre1,
																	cNombre2,cApellidoP,cApellidoM,cCelular,0,dPagoMinimo,'',0,0,0,cSituacion,sCausa);
				END IF ;												
				
			END FOREACH;
			
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '002';  --No hay informacion
			RETURN cCodRet;			
		END IF;	
		
		RETURN cCodRet;			
	END;
END PROCEDURE
 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Mensajes SMS',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Obtiene a los clientes y credito con pago minimo incompleto e inserta en la tabla cb_info_administrativa y',
'             Se obtuvo el nombre del cliente por separado los nombres y el apellido y se insertan con el numero de campania 7',
'Fecha: 2011/05/11',
'Version: 20110511.1056',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_consultapagoincompleto(	pVencido_min INTEGER, pVencido_max INTEGER, 
												pImporte_min DECIMAL(18,2), pImporte_max DECIMAL(18,2), 
												pSituacion CHAR(1), pCausa SMALLINT, pFecha_consulta DATE)
	RETURNING CHAR(6) AS CodRetorno, CHAR(20) AS  NumCte, CHAR(20) AS NumCredito,
	          CHAR(20) AS Ciudad, CHAR(20) AS Estado, CHAR(13) AS Celular,
			  CHAR(50) AS Nombre1, CHAR(50) AS Nombre2,CHAR(50) AS ApellidoPaterno, CHAR(50) AS ApellidoMaterno, 
			  DECIMAL(18,2) AS PagoMinimo;
              								 
	--DECLARARACION DE VARIBLES
	DEFINE iSqlErr					INTEGER;
	DEFINE cCodRet 					CHAR(6);	
    DEFINE cNumCredito  			CHAR(20);
	DEFINE cNumCte  				CHAR(20);
    DEFINE cCiudad                 	CHAR(20);
	DEFINE cEstado                 	CHAR(20);	
	DEFINE cNombre1 				CHAR(50);
	DEFINE cNombre2 				CHAR(50);
	DEFINE cApellidoP 				CHAR(50);
	DEFINE cApellidoM 				CHAR(50);
	DEFINE cCelular              	CHAR(13);
	DEFINE dPagoMinimo              DECIMAL(18,2);
	
	
	--INICIALIZACION DE VARIBLES
	LET iSqlErr 		= 	0;
	LET cCodRet 		= 	"000";	
	LET cNumCredito  	= '';
	LET cNumCte  		= '';	
    LET cCiudad         = '';    
	LET cEstado         = '';
	LET cNombre1 		= '';
	LET cNombre2 		= '';
	LET cApellidoP 		= ''; 
	LET cApellidoM 		= '';     
	LET cCelular        = '';
	LET dPagoMinimo     = 0;
	
	--SET DEBUG FILE TO "/home/sysifx/SPs PAYAN/"informix".sp_consultapagoincompleto.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				Let cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''), 
						NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dPagoMinimo,0);
			END IF;
		END EXCEPTION;
			
	    SET LOCK MODE TO WAIT 3;
		
		IF pVencido_min IS NULL OR pVencido_max IS NULL OR pImporte_min IS NULL OR pImporte_max IS NULL OR pFecha_consulta IS NULL 
			OR pSituacion IS NULL OR pCausa IS NULL THEN
	        LET cCodRet = '001'; -- Parametros no validos
	        RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''), 
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dPagoMinimo,0);
	    END IF;

	    IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 OR pCausa <0 THEN		
	        LET cCodRet = '002'; -- los parametros numericos recibidos deben ser positivos
			RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''), 
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dPagoMinimo,0);					
	    END IF;   
	    
		FOREACH			
					SELECT cliente,credito,ciudad,estado,nombre1,nombre2,apell_paterno,apell_materno,t_celular,pago_min
					INTO cNumCte,cNumCredito,cCiudad,cEstado,cNombre1,cNombre2,cApellidoP,cApellidoM,cCelular,dPagoMinimo
					FROM bdicobranza:"informix".cb_info_administrativa
					WHERE num_campania = 7 --Se agrego este Filtro para traer solo los Cliente/Credito que pertenescan a la campania 7. 
					AND pago_venc >= pVencido_min AND pago_venc <= pVencido_max
		            AND pago_min >= pImporte_min AND pago_min <= pImporte_max		           
		            AND situacion= CASE WHEN pSituacion <> "" THEN pSituacion ELSE situacion END 
					AND causa = CASE WHEN pCausa <> 0 THEN pCausa ELSE causa END 
					AND NVL(fecha_ejecucion,'01/01/1900') = pFecha_consulta
					AND NVL(t_celular,'') <> ''                                 --Modif. MACF
										
				    RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''), 
							NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dPagoMinimo,0) WITH resume;
									
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '003';  --No hay informacion
			RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''), 
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dPagoMinimo,0);
		END IF;	
				
	END;
END PROCEDURE
 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Mensajes SMS',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Obtiene a los clientes y credito con pago minimo incompleto',
'Fecha: 2011/05/11',
'Version: 20110511.1056',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_consultainfofechreestructura(
								pVencido_min  INTEGER,
								pVencido_max  INTEGER, 
								pImporte_min  DECIMAL(18,2),
								pImporte_max  DECIMAL(18,2),
								pSituacion CHAR(1), 
								pCausa SMALLINT,								
								pFecha_Ejec   DATE)
RETURNING
			char(5)  	AS CodRetorno,
			CHAR(20)	AS Cliente,
			CHAR(20)	AS Credito,
			CHAR(20)    AS Cuenta,
			CHAR(20)	AS Ciudad,
			CHAR(20)	AS Estado,
			CHAR(13)	AS Celular,
			CHAR(26)	AS Nombre1,
			CHAR(26)	AS Nombre2,
			CHAR(26)	AS ApellidoP,
			CHAR(26)	AS ApellidoM,
			DATE 		AS FechaPago;
	
		--Declararacion de Varibles
		DEFINE cSqlErr		INTEGER;
		DEFINE cCodRet 		CHAR(5);
		DEFINE cCliente 	CHAR(20);
		DEFINE cCredito 	CHAR(20);
		DEFINE cCuenta      CHAR(20);
		DEFINE cCiudad		CHAR(20);
		DEFINE cEstado		CHAR(20);
		DEFINE cCelular		CHAR(13);
		DEFINE cNombre1		CHAR(26);
		DEFINE cNombre2		CHAR(26);
		DEFINE cApellidoP	CHAR(26);
		DEFINE cApellidoM	CHAR(26);
		DEFINE dFechaPago	DATE;
	
		--Inicializacion de variables
		LET cSqlErr 		= 	0;
		LET cCodRet 		= 	"00000";
		LET cCliente  		=   "";
		LET cCredito		=   "";
		LET cCuenta         =   "";
		LET cCiudad			=   "";
		LET cEstado 		=   "";
		LET cCelular		=   "";
		LET cNombre1		=   "";
		LET cNombre2		=   "";
		LET cApellidoP		=   "";
		LET cApellidoM		=   "";
		LET dFechaPago      =   DATE(1);
		
		--SET DEBUG FILE TO "/home/sysifx/sp_consultainfofechreestructura.out";
		--TRACE ON;
		BEGIN
			 ON EXCEPTION SET cSqlErr
		        IF cSqlerr <> 0 THEN
		            Let cCodRet = cSqlErr;
					RETURN cCodRet, NVL(cCliente,''), NVL(cCredito,''), NVL(cCuenta,''), NVL(cCiudad,''), NVL(cEstado,''), NVL(cCelular,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dFechaPago,'');
				END IF;
			END EXCEPTION;
			SET LOCK MODE TO WAIT 3;
			
			--Se valida la integridad de los datos de entrada
			IF (pVencido_min IS NULL) OR ( pVencido_max IS NULL) OR (pImporte_min IS NULL) OR 
				(pImporte_max IS NULL) OR (pFecha_Ejec IS NULL) OR (pSituacion IS NULL) OR (pCausa IS NULL) THEN
				Let cCodRet = "00001";
				RETURN cCodRet, NVL(cCliente,''), NVL(cCredito,''), NVL(cCuenta,''), NVL(cCiudad,''), NVL(cEstado,''), NVL(cCelular,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dFechaPago,'');
			ELSE
				IF (pVencido_min < 0) OR ( pVencido_max < 0) OR (pImporte_min < 0) OR (pImporte_max < 0) THEN
					Let cCodRet = "00002";
				RETURN cCodRet, NVL(cCliente,''), NVL(cCredito,''),NVL(cCuenta,''), NVL(cCiudad,''), NVL(cEstado,''), NVL(cCelular,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dFechaPago,'');
				END IF;
			END IF;
				FOREACH
					--se obtiene los datos necesarios completos para  la generacion del archivo
						SELECT cliente,credito,cuenta,ciudad,estado,t_celular,nombre1,nombre2,apell_paterno,apell_materno,fecha_pago 
						INTO  cCliente,cCredito,cCuenta,cCiudad,cEstado,cCelular,cNombre1,cNombre2,cApellidoP,cApellidoM,dFechaPago
						FROM bdicobranza:"informix".cb_info_administrativa
						WHERE pago_venc BETWEEN NVL(pVencido_min,0) AND NVL(pVencido_max,0) 
						AND pago_min BETWEEN  NVL(pImporte_min,0) AND NVL(pImporte_max,0)
						AND NVL(fecha_ejecucion,'01/01/1900') = pFecha_Ejec
						AND nvl(situacion,'') = CASE WHEN pSituacion ='' THEN nvl(situacion,'') ELSE pSituacion END
						AND nvl(causa,0) = CASE WHEN pCausa=0 THEN nvl(causa,0)	ELSE pCausa	END								
						AND num_campania=9		
						
					
					RETURN cCodRet, NVL(cCliente,''), NVL(cCredito,''),NVL(cCuenta,''), NVL(cCiudad,''), NVL(cEstado,''), NVL(cCelular,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dFechaPago,'') WITH RESUME;
				END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00003';  --No hay informacion
		RETURN cCodRet, NVL(cCliente,''), NVL(cCredito,''),NVL(cCuenta,''), NVL(cCiudad,''), NVL(cEstado,''), NVL(cCelular,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,''), NVL(dFechaPago,'');
    END IF;					
								
		END
END PROCEDURE
DOCUMENT 
'DESCRIPCION: Se realiza procedimiento para obtener la informacion de la campaña 9 de la tabla cb_info_administrativa',
'AUTOR : Maria Elena Angulo Aispuro ',
'FECHA : 12/05/2011',
'BD    : BDICOBRANZA',
'Version: 20110512.1745';

CREATE PROCEDURE "informix".sp_obtienetdcporentregar(pVencido_min INTEGER, pVencido_max INTEGER, 
											pImporte_min DECIMAL(18,2), pImporte_max DECIMAL(18,2), 
											pSituacion CHAR(1), pCausa SMALLINT,pFecha_consulta DATE)
	RETURNING
			CHAR(6)	AS CodRetorno, CHAR(20) AS  NumCte, CHAR(20) AS NumCredito,CHAR(20) AS NumeroTarjeta,
	        CHAR(20) AS Ciudad, CHAR(20) AS Estado, CHAR(13) AS Celular,
			CHAR(50) AS Nombre1, CHAR(50) AS Nombre2, CHAR(50) AS ApellidoPaterno, CHAR(50) AS ApellidoMaterno;
		
	--DECLARARACION DE VARIBLES
	DEFINE iSqlErr					INTEGER;
	DEFINE cCodRet 					CHAR(6);
    DEFINE cNumCte 					CHAR(20);
	DEFINE cNumCredito 				CHAR(20);
	DEFINE cNumeroTarjeta 			CHAR(20);	
	DEFINE cCiudad 					CHAR(20);
	DEFINE cEstado 					CHAR(20);
	DEFINE cNombre1 				CHAR(50);
	DEFINE cNombre2 				CHAR(50);
	DEFINE cApellidoP 				CHAR(50);
	DEFINE cApellidoM 				CHAR(50);	
	DEFINE cCelular 				CHAR(13);
	
	
	--INICIALIZACION DE VARIBLES
	LET iSqlErr 		= 	0;
	LET cCodRet 		= "000";
	LET cNumCte 		= '';
	LET cNumCredito 	= '';
	LET cNumeroTarjeta 	= '';
	LET cCiudad 		= '';
	LET cEstado 		= '';
	LET cNombre1 		= '';
	LET cNombre2 		= '';
	LET cApellidoP 		= '';
	LET cApellidoM 		= '';	
	LET cCelular 		= '';
	
	
	--SET DEBUG FILE TO "/home/informix/macf/sp_obtienetdcporentregar.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				Let cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''),NVL(cNumeroTarjeta,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''),
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,'');
			END IF;
		END EXCEPTION;
	
	    SET LOCK MODE TO WAIT 3;
		
		IF pVencido_min IS NULL OR pVencido_max IS NULL OR pImporte_min IS NULL OR pImporte_max IS NULL OR pFecha_consulta IS NULL 
			OR pFecha_consulta IS NULL OR pSituacion IS NULL OR pCausa IS NULL THEN
	        LET cCodRet = '001'; -- Parametros no validos
			RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''),NVL(cNumeroTarjeta,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''),
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,'');
	    END IF;

	    IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 OR pCausa <0 THEN
	        LET cCodRet = '002'; -- los parametros numericos recibidos deben ser positivos
			RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''),NVL(cNumeroTarjeta,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''),
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,'');
	    END IF;
		
		FOREACH
		
			SELECT cliente,credito,tarjeta,ciudad,estado,nombre1,nombre2,apell_paterno,apell_materno,t_celular
			INTO cNumCte,cNumCredito,cNumeroTarjeta,cCiudad,cEstado,cNombre1,cNombre2,cApellidoP,cApellidoM,cCelular
			FROM bdicobranza:"informix".cb_info_administrativa
			WHERE num_campania = 8
				AND pago_venc >= pVencido_min AND pago_venc <= pVencido_max
				AND pago_min >= pImporte_min AND pago_min <= pImporte_max	
				AND situacion= CASE WHEN pSituacion <> '' THEN pSituacion ELSE situacion END 
				AND causa = CASE WHEN pCausa <> 0 THEN pCausa ELSE causa END 
				AND NVL(fecha_ejecucion,'01-01-1900') = pFecha_consulta
				
				RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''),NVL(cNumeroTarjeta,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''),
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,'') WITH resume;
						
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '003';  --No hay informacion
			RETURN cCodRet, NVL(cNumCte,''), NVL(cNumCredito,''),NVL(cNumeroTarjeta,''), NVL(cCiudad,''), NVL(cEstado,''),NVL(cCelular,''),
					NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidoP,''), NVL(cApellidoM,'');
		END IF;	
		
	END;
END PROCEDURE
 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Mensajes SMS',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Obtiene a los clientes y credito con TDC por Entregar',
'			  Se le agrego el filtro (num_campania = 8),a al Query de Consulta',
'Fecha: 2011/05/11',
'Version: 20110511.1056',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_consultareestructuravencidos(pVencido_min integer, pVencido_max integer, pImporte_min decimal(18,2), 
																	pImporte_max decimal(18,2), pSituacion CHAR(7), pCausa SMALLINT,
																	pFecha_consulta DATE)
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(20) AS Cliente,
			CHAR(20) AS Credito,
			CHAR(20) AS Cuenta,
			CHAR(20) AS Ciudad,
			CHAR(20) AS Estado,
			CHAR(13) AS Celular,
			CHAR(50) AS nombre1,
			CHAR(50) AS nombre2,
			CHAR(50) AS apell_pat,
			CHAR(50) AS apell_mat,
			DECIMAL(18,2) AS dPagoMin;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cCredito			CHAR(20);
DEFINE cCliente			CHAR(20);
DEFINE cCiudad			CHAR(20);
DEFINE cEstado			CHAR(20);
DEFINE cNombre			CHAR(110);
DEFINE cCelular			CHAR(13);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE dPagoMin			DECIMAL(18,2);
DEFINE cNumCta			CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "000000";
LET cCredito			= '';
LET cCliente			= '';
LET cCiudad				= '';
LET cEstado				= '';
LET cNombre				= '';
LET cCelular			= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cCelular			= '';
LET dPagoMin   			= 0;
LET cNumCta				= '';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_consultareestructuravencidos.out';
--TRACE ON;


	IF pVencido_min IS NULL OR pVencido_max IS NULL OR pImporte_min IS NULL OR pImporte_max IS NULL OR 
	pSituacion IS NULL OR pCausa IS NULL OR pFecha_consulta IS NULL THEN
		LET cCodRet = '00001';  --Parametros no validos
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);	
	END IF;

	IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 THEN
		LET cCodRet = '00002';  -- Los parametros numericos deben ser positivos
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);	
	END IF;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;
	
	FOREACH 
	
		SELECT  cliente, credito, cuenta, ciudad, estado, t_celular, nombre1, nombre2, apell_paterno, apell_materno,  pago_min
		INTO cCliente, cCredito, cNumCta, cCiudad, cEstado, cCelular, cNombre1, cNombre2, cApellPat, cApellMat, dPagoMin
		FROM bdicobranza:"informix".cb_info_administrativa
		WHERE num_campania =11	
		--AND situacion= CASE WHEN pSituacion <> "" THEN pSituacion ELSE situacion END  --quitar para que muestre todos aunque no tengan Sit. y Causa 
		--AND causa = CASE WHEN pCausa <> 0 THEN pCausa ELSE causa END
		AND pago_venc >= pVencido_min AND pago_venc <= pVencido_max
		AND pago_min >= pImporte_min AND pago_min <= pImporte_max				
		AND NVL(fecha_ejecucion,'01/01/1900') = pFecha_consulta
		
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0) WITH RESUME;
		
	END FOREACH;	
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00003';  --No hay informacion
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);
    END IF;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Se realiza procedimiento para la obtencion de la informacion de campaña 17 de la tabla cb_info_administrativa',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 10/05/2011',
'BD    : BDICOBRANZA',
'Version: 20110523.1254',
'20110922 Modificar query principal. Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_cat_obtentpscampania()
		RETURNING CHAR(6),SMALLINT,CHAR(50);

	DEFINE cCodRet 			CHAR(6);
	DEFINE iCont			INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE sTipoCampania		SMALLINT;
	DEFINE cDescripcion		CHAR(50);

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont=0;
	LET sTipoCampania = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/hector/sp_cat_obtentpscampania.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDescripcion = 'Error de Informix';
			RETURN cCodRet,sTipoCampania,cDescripcion;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT num_campania, descripcion
			INTO  sTipoCampania,cDescripcion
			FROM bdicobranza:"informix".cb_cat_campania
			WHERE modulo_cob=3
			LET icont=icont+1;
            RETURN cCodret,sTipoCampania,cDescripcion WITH RESUME;
		END FOREACH;

        IF icont == 0 THEN
			LET cCodret='000001';
			LET cDescripcion='No hay Informacion en la tabla';
            RETURN cCodret,sTipoCampania,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION : Devuelve un listado de las Campañas existentes en la tabla cb_cat_campania',
'FECHA       : 30 de Septiembre de 2010',
'MODIFICA    : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se actualiza para agregar a la consulta el filtro por modulo_cob que se igual a 3',
'FECHA       : 08 de junio de 2011',
'VERSION     : 20110608.1152',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_modstadocte(pOpHabiInha SMALLINT, --Bandera de opciones 1.- Habilitar,  2.- Inhabilitar
												pUsuario CHAR(8),
												pEmpresa CHAR(3),
												pCampania CHAR(1),
												pCliente CHAR(20),
												pPagosVencMin INTEGER,
												pPagosVencMax INTEGER,
												pMontoMin DECIMAL(18,2),
												pMontoMax DECIMAL(18,2),
												pEstado  CHAR (2),
												pNumCiudad CHAR (3),
												pRegion   SMALLINT ,
												pSitEsp   CHAR (1),
												pCausa	  SMALLINT,
												pStatus   CHAR(2),
												pTipoMov  INTEGER,
												pTipoResul SMALLINT,
												pExepcion  CHAR(5),
												pRegistros INTEGER,
												pLogica		SMALLINT,
												pSaldos		INTEGER)
		RETURNING   
					CHAR(6) AS Codigo,	--codret
					CHAR(80) AS Descripcioncodigo, --Descripcion del codigo
					INTEGER AS Total; --Total de registros afectados
	
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE cCodRet2			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE cDesCod			CHAR(80);
	DEFINE cMensaje         CHAR(80);
	DEFINE cNumCte          CHAR(20);
	DEFINE cNum_credito 	CHAR(20);
	DEFINE cEstado 			CHAR(30);
	DEFINE dPago_Minimo 	DECIMAL(18,2);
	DEFINE dSaldo_Total 	DECIMAL(18,2);
	DEFINE iTotal 			INTEGER;
	DEFINE CCobranza		CHAR(1);
	--Se agregan campos nuevos del procedimiento sp_cat_consulta_ctes
	DEFINE sTpoLogica		SMALLINT;
	DEFINE cTarjeta			CHAR(20);
	DEFINE cNombre1       	CHAR(26);
	DEFINE cNombre2         CHAR(26);
	DEFINE cApell_pat       CHAR(26);
	DEFINE cApell_mat       CHAR(26);
	DEFINE cSexo			CHAR(1);
	DEFINE cEdoCivil		CHAR(1);
	DEFINE dtFechaUltPago   DATE;
	DEFINE dMontoUltPag     DECIMAL(18,2);
	DEFINE dCapVdoExig      DECIMAL(18,2);
	DEFINE dPagoMinSinVdo   DECIMAL(14,2);
	DEFINE dtFechaRep       DATE;
	DEFINE dFechaGestion    DATE;
	DEFINE OrigenGestion	INTEGER;
	
	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET cCodRet2='';
	LET iSqlErr = 0;
	LET cDesCod='PROCESO EXITOSO';
	LET cMensaje='';
	LET cNumCte='';
	LET cNum_credito='';
	LET cEstado='';
	LET dPago_Minimo=0;
	LET dSaldo_Total=0;
	LET iTotal=0;	
	LET CCobranza='';
	--Se agregan campos nuevos del procedimiento sp_cat_consulta_ctes
	LET sTpoLogica	=0;
	LET cTarjeta	='';	
	LET cNombre1='';
	LET cNombre2='';
	LET cApell_pat='';
	LET cApell_mat='';	
	LET cSexo		='';
	LET cEdoCivil 	='';
	LET dtFechaUltPago =DATE(1);
	LET dMontoUltPag =0;
	LET dCapVdoExig =0;
	LET dPagoMinSinVdo=0;
	LET dtFechaRep= DATE(1);
	LET dFechaGestion = DATE(1);
	LET OrigenGestion = 0;
	
	
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_modstadocte.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDesCod='Error de Informix';
			RETURN cCodRet,cDesCod,itotal;
		END EXCEPTION;		
	
	SET ISOLATION TO DIRTY READ; -- Lectura de tablas bloqueadas.
	SET LOCK MODE TO WAIT 5;
	
	IF pOpHabiInha NOT IN (1,2) THEN
			LET cCodRet='000001';
			LET cDesCod='DEBE INGRESAR UNA OPCION DE 1.HABILITAR O 2.DESHABILITAR';
			RETURN cCodRet,cDesCod,itotal;
	END IF;
	FOREACH
	EXECUTE PROCEDURE bdicobranza:"informix".sp_cat_consulta_ctes(pEmpresa,pCampania,pCliente,pPagosVencMin,pPagosVencMax,pMontoMin,pMontoMax,pEstado,pNumCiudad,pRegion,pSitEsp,
	pCausa,pStatus,pTipoMov,pTipoResul,pExepcion,pRegistros,pLogica,pSaldos) 
	INTO cCodRet2,CCobranza,sTpoLogica,cNumCte,cNum_credito,cTarjeta,cEstado,cNombre1,cNombre2,cApell_pat,cApell_mat,cSexo,cEdoCivil,dPago_Minimo,iTotal,dSaldo_Total,
	dtFechaUltPago,dMontoUltPag,dCapVdoExig,dPagoMinSinVdo,dtFechaRep,dFechaGestion,OrigenGestion
											
			IF cCodRet2='000000' THEN 
					IF pOpHabiInha=1 THEN 
							IF pStatus IN ('IN','PR') THEN
								EXECUTE PROCEDURE bdicobranza:"informix".sp_cat_cambia_estatus_cte(cNumCte,'AC',pTipoMov,pCampania,pEmpresa,pUsuario)
								INTO cCodRet2,cMensaje;
								IF cCodRet2 <> 0 THEN
									LET cCodRet=cCodRet2;
									LET cDesCod=cMensaje;
									RETURN cCodRet,cDesCod,itotal;	
								END IF;
							END IF;												
					ELIF pOpHabiInha=2 THEN 	
							IF pStatus = 'AC' THEN
								EXECUTE PROCEDURE bdicobranza:"informix".sp_cat_cambia_estatus_cte(cNumCte,'IN',pTipoMov,pCampania,pEmpresa,pUsuario)
								INTO cCodRet2,cMensaje;
								IF cCodRet2 <> 0 THEN
									LET cCodRet=cCodRet2;
									LET cDesCod=cMensaje;									
									RETURN cCodRet,cDesCod,itotal;	
								END IF;
							END IF;
					END IF;
			ELIF cCodRet2='105008' THEN
					LET cCodRet='000002';
					LET cDesCod='NO HAY REGISTROS PARA EL CAMBIO DE ESTATUS';			
			ELSE 
					LET cCodRet= cCodRet2;
					LET cDesCod='OCURRIO UN ERROR EN LA EJECUCION DEL sp_cat_consulta_ctes';			
			END IF;
	END FOREACH;
		RETURN cCodRet,cDesCod,itotal;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se actualiza el estatus del cliente para habilitar o inhabilitarlo para que se les realice cobranza',
'FECHA       : 10 de Noviembre de 2010',
'VERSION     : 20101110.1047',
'MODIFICÓ       : Maria Elena Angulo Aispuro',
'CAMBIO: Se actualiza el llamado al procedimiento sp_cat_consulta_ctes, debido a que el proceso devuelve mas campos correspondientes a los saldos',
'FECHA       : 26 de Agosto de 2011',
'VERSION     : 20101110.1047',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_ctbcpl_gen_arcctesexcluidos(pEmpresa  CHAR(3),
                                                           pFecha_ex DATE, 
														   pTipCobranza char(1) )
RETURNING CHAR(6) AS codigo_retorno;
          
DEFINE cCodRet             CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cSql                CHAR(2204);
DEFINE cNombreArchivo1     CHAR(50);
DEFINE cNombreArchivo      CHAR(50);
DEFINE cRuta               CHAR(100);
DEFINE iNumreg             INTEGER;
DEFINE iDatos              INTEGER;
DEFINE cEmpresa            CHAR(3);
DEFINE cNombre             CHAR(100);
DEFINE cSeparador          CHAR(1);
DEFINE cValor_status       CHAR(20);
DEFINE cHora               CHAR(8);
DEFINE cUsuario            CHAR(8);
DEFINE cSql1               CHAR(100);
DEFINE cSql2               CHAR(2004);
DEFINE cSql3               CHAR(100);
DEFINE dDia                DATE;
DEFINE cFechaGenArchivo    CHAR(8);
DEFINE cCodRetIB           CHAR(6);
DEFINE cMensaje            CHAR(80);

LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cCodRet                = "000000";
LET cRuta                  = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET iNumreg                = 0;
LET iDatos                 = 0;
LET cEmpresa               = "";
LET cNombre                = '';
LET cSeparador             = '';
LET cSql                   = "";
LET cValor_status          = "";
LET cHora                  = "";
LET dDia                   = DATE(1);
LET cMensajeRet            = 'PROCESO EXITOSO';
LET cUsuario               = USER;
LET cSql1                  = "";
LET cSql2                  = "";
LET cSql3                  = "";
LET cFechaGenArchivo       = "";
LET cCodRetIB              = "000000";
LET cMensaje               = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
        LET cCodRet     = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensajeRet,"02")
                     INTO cCodRetIB;
       RETURN cCodRet; 
    END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/home/syscobra/cat/envios/sp_ctbcpl_gen_arcctesexcluidos.out';
--TRACE ON;

-- Inserta bitacora de procesos
EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029","","","01")
             INTO cCodRetIB;
        
-- Validacion de los datos de entrada
IF NVL(pEmpresa,"") = "" THEN
    LET cCodRet     = "104007";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;
    
SELECT empresa
  INTO cEmpresa 
  FROM bdinteg:si_empresas
 WHERE empresa = pEmpresa;

IF NVL(cEmpresa,"")= "" then
    LET cCodRet = "104002";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;

IF NVL(pFecha_ex,"") = "" THEN
    LET cCodRet     = "104008";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;

-- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
SELECT valor_alfabetico 
  INTO cRuta
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = pEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 3;

IF NVL(cRuta,"")    = "" THEN
    LET cCodRet     = "104005";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                  INTO cCodRetIB;
    RETURN cCodRet;
END IF;

-- Se obtiene del nombre del archivo
SELECT valor_alfabetico 
  INTO cNombre
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = pEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 5;

    IF NVL(cNombre,"") = "" THEN
        LET cCodRet = "104006";
     SELECT descripcion
       INTO cMensaje
       FROM bdicobranza:"informix".cb_errores
      WHERE origen       = 3
        AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

-- Se obtiene el separador de los campos
SELECT valor_alfabetico 
  INTO cSeparador
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = pEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 2;
    
	IF NVL(cSeparador,"") = "" THEN
        LET cCodRet     = "104004";
     SELECT descripcion
       INTO cMensaje
       FROM bdicobranza:"informix".cb_errores
      WHERE origen       = 3
        AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
     
	LET cNombreArchivo1 = 'prueba.txt';
    LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
   
FOREACH
     	SELECT trim(valor_alfabetico)
	      INTO cValor_status
		  FROM bdicobranza:cb_param_campania
		 WHERE empresa         = pEmpresa
		   AND tipo_campania   = '1'
		   AND grupo_parametro = 'STATARCHCE'
     
			SELECT COUNT (numcte)
			  INTO iNumreg
			  FROM bdicobranza:cb_cat_directorio_cte
			 WHERE status_cliente 		= cValor_status
			   AND fecha_modificacion   = pFecha_ex
			   AND tipo_cobranza  = pTipCobranza
		       AND empresa        = pEmpresa;

			LET cNombreArchivo1 = 'prueba.txt';
            LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
   
			IF iNumreg = 0 THEN
				CONTINUE FOREACH;
			END IF;

			LET iDatos = iDatos + 1;

            -- para generar el archivo 
		    LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM (cNombreArchivo1) || " DELIMITER '" || cSeparador || "'";
            
                LET cSql2 = " SELECT tipo_cobranza, numcte, "  
                        || " (select  ''||round(valor_numerico) FROM cb_param_campania WHERE  tipo_campania = 1 "
                        || "   AND grupo_parametro ='STATUSCTE'"
                        || "   AND TRIM(valor_alfabetico)=status_cliente) status_cliente, "
                        || " tipo_movto, "
                        || " fecha_modificacion "
                        || " FROM bdicobranza:cb_cat_directorio_cte "
						|| " WHERE "
						|| " tipo_cobranza  ='" ||pTipCobranza||  "' AND  status_cliente = '"||cValor_status||"' AND  fecha_modificacion = '"||pFecha_ex||"';";
						
			    						
						
            LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql';
            
            LET cSql1 = TRIM(cSql1);
            LET cSql3 = TRIM(cSql3);
            
            LET cSql = cSql1 || cSql2 || cSql3;
			
			SYSTEM cSQL;
			--Permiso para la creacion de archivo.
			LET cSQL = '' ;
			LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql' ;
			LET cSQL = '' ;
			LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql';
			SYSTEM cSQL;
			
			LET cSql = "sed 's/"||cSeparador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
            SYSTEM cSql;

			--Borra el archivo de control.
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql';
			SYSTEM cSQL;

			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
			SYSTEM cSQL;
      ------------------------------------------------------------------------------------------------------------------------
	  LET cNombreArchivo1 = 'pruebaC.txt';    
	  LET cNombreArchivo  = TRIM(Replace(cNombre,'_','')) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
      LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM (cNombreArchivo1) || " DELIMITER '" || cSeparador || "'";
            
                LET cSql2 = " SELECT a.tipo_cobranza, a.numcte, "  
                        || " (select  ''||round(valor_numerico) FROM cb_param_campania WHERE  tipo_campania = 1 "
                        || "   AND grupo_parametro ='STATUSCTE'"
                        || "   AND TRIM(valor_alfabetico)=a.status_cliente) status_cliente, "
                        || " a.tipo_movto, "
                        || " to_char(a.fecha_modificacion, '%Y-%m-%d'), (to_char(fecha_insert,'%Y-%m-')|| b.dia_corte ) fechacorte "
                        || " FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maecredanexo b  "
						|| " WHERE  a.empresa = b.empresa  and a.num_credito = b.num_credito and a.empresa = '001' and " 
						|| " a.tipo_cobranza  ='" ||pTipCobranza||  "' and a.status_cliente = '"||cValor_status||"' AND  a.fecha_modificacion = '"||pFecha_ex||"';";
						
            LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql';
            
            LET cSql1 = TRIM(cSql1);
            LET cSql3 = TRIM(cSql3);
            
            LET cSql = cSql1 || cSql2 || cSql3;
			
			SYSTEM cSQL;
			--Permiso para la creacion de archivo.
			LET cSQL = '' ;
			LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql' ;
			LET cSQL = '' ;
			LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql';
			SYSTEM cSQL;
			
			LET cSql = "sed 's/"||cSeparador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
            SYSTEM cSql;

			--Borra el archivo de control.
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql';
			SYSTEM cSQL;

			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
			SYSTEM cSQL;
END FOREACH;

-- Por si el archivo no  se genera 
IF iDatos = 0 THEN
    LET cCodRet = '104009';
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;

EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensajeRet,"03")
             INTO cCodRetIB;

RETURN cCodRet;

END
END PROCEDURE
DOCUMENT 
'El SP genera un archivo que extrae información de los clientes excluidos de cobranza',
'AUTOR : Leonardo Arellano M.',
'FECHA : 01/OCTUBRE/2010',
'VERSION:201000927.1500',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_catobtenstpslogica()
		RETURNING CHAR(6),SMALLINT,CHAR(50);

	--Declaracion de variables
	DEFINE cCodRet 			CHAR(6);
	DEFINE iCont			INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE sTipoLogica		SMALLINT;
	DEFINE cDescripcion		CHAR(50);

	--Inicializacion de variables
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont=0;
	LET sTipoLogica = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/respaldosbd/Malena/sp_catobtenstpslogica.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDescripcion = 'Error de Informix';
			RETURN cCodRet,sTipoLogica,cDescripcion;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT num_parametro,descripcion 
			INTO  sTipoLogica,cDescripcion
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE grupo_parametro='LOGICA' 
			AND tipo_campania=1		
            RETURN cCodret,sTipoLogica,cDescripcion WITH RESUME;
		END FOREACH;

		LET iCont = dbinfo("sqlca.sqlerrd2");
		IF iCont = 0 THEN
			LET cCodRet='000001'; 
			LET cDescripcion='No Hay Datos';
			RETURN cCodRet,sTipoLogica,cDescripcion;	
		END IF;
	END;
END PROCEDURE

DOCUMENT
'AUTOR    : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado de los diferentes tipos de logica.',
'FECHA       : 14 de junio de 2011',
'VERSION     : 20110614.1152',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_depura_cte_tel_inactivo()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cTel				CHAR(13);
DEFINE cNumCte			CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumCte				= '';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_cat_depura_cte_tel_inactivo.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;	
	
	FOREACH 		
		
		SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} DISTINCT(telefono), numcte
		INTO cTel, cNumCte
		FROM bdicobranza:cb_telefonos
		WHERE estatus= 'IN'
      AND fecha_insert >= '01-01-1900'  	
		
		IF EXISTS( SELECT 1 FROM bdicobranza:"informix".cb_telefonos WHERE numcte= cNumCte AND
					estatus <> 'IN' ) THEN
			CONTINUE FOREACH;			
		ELSE
			INSERT INTO bdisitesp:"informix".se_ctessitespcred (numcte, empresa, numcred, situacion, causa,
				cvesitesporigen,	 sucursal, tipomovto, nombreefectuo, usralta, fchalta, usrmodifica, fchmodifica)
			VALUES ( cNumCte, '001', '', 'T', 1, '', '', '', '', 'informix', CURRENT, '', '');
		END IF;
		
	END FOREACH;	
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Marca los telefonos inactivo con situacion especial T causa 1',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110622.0914';

CREATE PROCEDURE "informix".sp_cat_depura_tel_inactivo()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cTel				CHAR(13);
DEFINE cNumcte    CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumcte = '';


BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_cat_depura_tel_inactivo.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH 		
    
    SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} DISTINCT(telefono)
		INTO cTel
		FROM bdicobranza:cb_telefonos
		WHERE estatus = 'AC'
     AND fecha_insert >= '01-01-1900'  	
     

		IF EXISTS( SELECT 1 FROM bdicobranza:"informix".cb_registro_llamadas a	INNER	JOIN 
					bdicobranza:"informix".cb_cat_tipo_resultado b ON (a.codigo_resultado = b.codigo_resultado) 
					WHERE a.telefono= cTel AND b.genera_inactivacion = 'V' AND a.veces_marcado >= b.num_marca_inactiva) 
					THEN

						UPDATE bdicobranza:"informix".cb_telefonos SET estatus = 'IN' WHERE telefono = TRIM(cTel);
	
		ELSE
			CONTINUE FOREACH;
		END IF;
		
	END FOREACH;	
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Marca los telefonos como inactivos',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110608.1851';

CREATE PROCEDURE "informix".sp_generatelinactivos()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        		CHAR(5); 
DEFINE iSqlErr      		INTEGER;
DEFINE cTel					CHAR(13);
DEFINE cNumCte				CHAR(20);
DEFINE cFechaHoy			CHAR(10);
DEFINE cRuta				CHAR(100);
DEFINE cNombreCtes			CHAR(100);
DEFINE cNombreTels			CHAR(100);			
DEFINE cStatus				CHAR(2);
DEFINE cDescripcionStatus	CHAR(100);
DEFINE cDescTpoTel			CHAR(30);
DEFINE cDescripcionResult	CHAR(50);
DEFINE sTpoTel				SMALLINT;
DEFINE sNumMarcados			SMALLINT;
DEFINE cEstatus				CHAR(2); 
DEFINE sCodResultado		SMALLINT;
DEFINE vsSQL1 				CHAR(300);
DEFINE cSql3 				CHAR(900);
DEFINE vsSQL2				CHAR(300);
DEFINE cSql					CHAR(1500);
DEFINE DescContac			CHAR(14);
DEFINE cNombreTels2			CHAR(100);
DEFINE cNombreCtes2			CHAR(100);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumCte				= '';
LET cFechaHoy			= '';
LET  cRuta				= '';
LET cNombreCtes			= '';
LET cNombreTels			= '';	
LET cStatus				= '';
LET cDescripcionStatus	= '';
LET cDescTpoTel			= '';
LET cDescripcionResult	= '';
LET sTpoTel				= 0;
LET sNumMarcados		= 0;
LET cEstatus			= '';
LET sCodResultado		= 0;
LET vsSQL1  = '';
LET cSql	= '';
LET vsSQL2	= '';
LET cSql3	= '';
LET DescContac = '';
LET cNombreTels2	= '';
LET cNombreCtes2	= '';
		
BEGIN

ON EXCEPTION SET iSqlErr
	IF EXISTS (SELECT tabname  FROM sysmaster:"informix".systabnames where tabname = 'tmpctescat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmpctescat;
    END IF;
	
	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmptelscat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmptelscat;
    END IF;
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_generatelinactivos.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;	

	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmpctescat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmpctescat;
    END IF;
	
	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmptelscat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmptelscat;
    END IF;

	
	CREATE TABLE "informix".tmpctescat
	( cliente   CHAR(20),
	  Status	CHAR(14));
	 
	CREATE TABLE "informix".tmptelscat
	( cliente   CHAR(20),
	  telefono	CHAR(13),
	  tipo_tel	CHAR(30),
	  resultado	CHAR(40),
	  veces_marcado	SMALLINT,
	  status	CHAR(10));	 	  

	--Ruta archivo
	SELECT valor_alfabetico
	INTO	cRuta
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 21;
	
	--Nombre para el archivo de Clientes
	SELECT valor_alfabetico
	INTO cNombreCtes
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 22;
	
	--Nombre para el archivo de Telefonos
	SELECT valor_alfabetico
	INTO cNombreTels
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 23;
	
	SELECT fecha_hoy
	INTO cFechaHoy
	FROM bdicred:"informix".sd_fechas
  WHERE empresa = '001';	
	
	--Para clientes	
	--Inactivo		
	LET DescContac= 'NO CONTACTABLE';
	
	INSERT INTO  "informix".tmpctescat 
	SELECT distinct (tel.numcte), DescContac FROM bdicobranza:"informix".cb_telefonos tel
	INNER JOIN  bdisitesp:"informix".se_ctessitespcred  esp	ON ( tel.numcte = esp.numcte) WHERE esp.situacion= 'T'
	AND esp.causa = 1 AND tel.estatus= 'IN';			
	LET DescContac= '';
		
	
	--Activo
	LET DescContac= 'CONTACTABLE';
	INSERT INTO  "informix".tmpctescat 
	SELECT distinct(numcte), DescContac FROM bdicobranza:"informix".cb_telefonos WHERE estatus= 'AC';
		
	
	--Para Telefonos
	FOREACH 
		
		SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} distinct (numcte), telefono, tipo_telefono, numvecesmarcado, estatus, codigo_resultado
		INTO cNumCte, cTel, sTpoTel, sNumMarcados, cEstatus, sCodResultado
		FROM bdicobranza:"informix".cb_telefonos
		WHERE empresa = '001'
     AND estatus in('AC','IN', 'CA')
     AND fecha_insert >= '01-01-1900'	
     	
		
		SELECT descripcion
		INTO	cDescTpoTel
		FROM bdicobranza:"informix".cb_tipo_telefono
		WHERE empresa = '001'
      AND tipo_telefono = sTpoTel;
		
		SELECT  descripcion  
		INTO cDescripcionResult
		FROM bdicobranza:"informix".cb_cat_tipo_resultado
		WHERE codigo_resultado =NVL(sCodResultado,0);
		
		IF cEstatus = 'AC' THEN
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 1;
		
		ELIF cEstatus = 'IN' THEN
			
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 2;
		ELIF cEstatus = 'CA'	THEN
		
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 3;
			
		END IF;		
		
		INSERT INTO "informix".tmptelscat (cliente, telefono, tipo_tel, resultado, veces_marcado, status)
		VALUES (cNumCte, cTel, cDescTpoTel, cDescripcionResult, sNumMarcados, cDescripcionStatus);
		
	END FOREACH; 
	
	LET cNombreCtes =  TRIM(cNombreCtes)||lpad(DAY(cFechaHoy),2,0)||lpad(MONTH(cFechaHoy),2,0)||lpad(YEAR(cFechaHoy),4,0);
	LET cNombreTels =  TRIM(cNombreTels)||lpad(DAY(cFechaHoy),2,0)||lpad(MONTH(cFechaHoy),2,0)||lpad(YEAR(cFechaHoy),4,0);	
	
	--GENERA ARCHIVO CLIENTES
	let cRuta = TRIM(cRuta);
	let vsSQL1 = 	'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreCtes) ||"Temporal.sql" ;
	LET vsSQL1 = TRIM(vsSQL1);
	let cSql3 = ' SELECT cliente, status  FROM bdicobranza:"informix".tmpctescat;  '  ;
	LET vsSQL2 = ' " >' || TRIM(cRuta ) || 'ConsultaCtesCAT.sql';
	LET cSql = TRIM(vsSQL1) ||" "|| TRIM(cSql3) || "" || vsSQL2;
	SYSTEM cSql;
	LET vsSQL1 = "";
	LET vsSQL1 = "dbaccess bdicobranza " || trim(cRuta) ||  "ConsultaCtesCAT.sql";
	SYSTEM vsSQL1;
	LET cNombreCtes2 = "ConsultaCtesCAT.sql";
	
	LET vsSQL1 = "";
	LET vsSQL1 = "sed 's/|$//g' " || trim(cRuta) || TRIM(cNombreCtes) ||"Temporal.sql" || " > " || trim(cRuta) || TRIM(cNombreCtes) ||".xls" ;
	SYSTEM vsSQL1;	

	LET vsSQL1 = '';
	LET vsSQL1 = "rm -rf " || trim(cRuta) || "*.sql";
	SYSTEM vsSQL1;
	
	LET vsSQL1  = '';
	LET cSql	= '';
	LET vsSQL2	= '';
	LET cSql3	= '';	
	
	--GENERA ARCHIVO TELEFONOS
	
	let cRuta = TRIM(cRuta);
	let vsSQL1 = 	'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreTels) ||"Temporal.sql" ;
	LET vsSQL1 = TRIM(vsSQL1);
	let cSql3 = ' SELECT cliente, telefono, tipo_tel, resultado, veces_marcado, status FROM bdicobranza:"informix".tmptelscat;  '  ;
	LET vsSQL2 = ' " >' || TRIM(cRuta ) || 'ConsultaTelCAT.sql';
	LET cSql = TRIM(vsSQL1) ||" "|| TRIM(cSql3) || "" || vsSQL2;
	SYSTEM cSql;
	LET vsSQL1 = "";
	LET vsSQL1 = "dbaccess bdicobranza " || trim(cRuta) ||  "ConsultaTelCAT.sql";
	SYSTEM vsSQL1;
	LET cNombreTels2 = "ConsultaTelCAT.sql";
	
	LET vsSQL1 = "";
	LET vsSQL1 = "sed 's/|$//g' " || trim(cRuta) || TRIM(cNombreTels) ||"Temporal.sql" || " > " || trim(cRuta) || TRIM(cNombreTels) ||".xls" ;
	SYSTEM vsSQL1;	

	LET vsSQL1 = '';
	LET vsSQL1 = "rm -rf " || trim(cRuta) || "*.sql";
	SYSTEM vsSQL1;

	--ELIMINA TABLAS
	DROP TABLE bdicobranza:"informix".tmptelscat;
	DROP TABLE bdicobranza:"informix".tmpctescat;
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Genera 2 archivos, uno de clientes con los numeros de ctes y status, y otro de telefonos, con ctes, tel, tpo tel, resultado, veces marcado y estatus',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110620.1755';

create procedure "informix".sp_inserta_mensaje(pempresa  char(3), ptipomensaje smallint, pnumvencido  smallint, ptipomail smallint)
returning VARCHAR(6);
-- execute procedure "informix".sp_inserta_mensaje('001',5,2,0)

DEFINE pidtipomensaje	char (2);
DEFINE pnumvencidos     smallint;
DEFINE pnumcte          char(20);
DEFINE pnumcredito      char(20);
DEFINE pnombre          char(60);
DEFINE pemail           char (60);
DEFINE pmonto           decimal(18,2);
DEFINE psaldototal      decimal(18,2);
DEFINE ppagominimo      decimal(18,2);
DEFINE pmontoconvenio   decimal(18,2);
DEFINE pfechahoy		date;
DEFINE pvalor			smallint;
DEFINE vfecha			datetime year to second;
DEFINE pfecha			datetime year to second;
DEFINE pfechaprimercons datetime year to second;
DEFINE pfreestructu datetime year to second;
DEFINE cProceso  		char(4);
DEFINE cCod_ret  		smallint;
DEFINE cMensaje  		char (100);
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET        VARCHAR(6);
DEFINE P_MENSAJE        VARCHAR(80);
DEFINE v_longitud       INTEGER;  
DEFINE v_cuenta			INTEGER;  
DEFINE v_subcadena		CHAR(1);  
DEFINE v_mail_incorrecto CHAR(1);  
LET v_longitud          = 0;  
LET v_cuenta            = 1;   
LET v_subcadena         = ''; 

BEGIN

    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
            RETURNING P_COD_RET;
        RETURN P_COD_RET;
    END exception;
	
 --SET DEBUG FILE TO "/informix/Elizabeth/inserta_mensaje.out";
 --TRACE ON;

  let P_COD_RET = '111111';
  let cCod_ret = '';
  let cMensaje = '';
  let cProceso = '2030';
  let pmonto = 0;
  let vfecha = to_char(today, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S');
 
  --valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomensaje, '') = '' THEN
        LET cCod_Ret= '106007';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (pnumvencido, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomail, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING P_COD_RET;
			
	Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa;
	
    select id_tipo_mensaje
    into pidtipomensaje
    from bdicobranza:cb_mail_configuracion
    where tipo_mensaje = ptipomensaje
    and num_vencidos = pnumvencido
	and tipo_mail = ptipomail;

    DELETE FROM bdinteg:si_mensajes_enviar WHERE date(f_mensaje) = pfechahoy and id_tipo_mensaje = pidtipomensaje;
	
	--valida el tipo de mensaje para la busqueda  en el where del select mas adelante
	if (ptipomensaje = 1 and pnumvencido <=5) then -- obtiene los meses de vencidos para mensajes de mora
		let pvalor=pnumvencido;
	end if;
	if (ptipomensaje = 1 and ptipomail >= 30) then --obtiene el valor para tipo de mensaje para mensajes de remanente y compra mayor a $5,000
		let pvalor=ptipomail;
	end if;
	if (ptipomensaje = 3) then--obtiene el valor para tipo de mensaje para convenios
		let pvalor = ptipomail;
	end if;
	if (ptipomensaje = 2) then--obtiene el valor para mensajes a venta de cartera
		let pvalor = 5;
	end if;
	if (ptipomensaje = 4 and pnumvencido > 0 ) then --valor para mensajes en reestructura moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 4 and pnumvencido = 0  and ptipomail = 0) then --valor para mensajes en reestructura preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido <= 2 and ptipomail = 0) then --valor para mensajes en prestamo P moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then --valor para mensajes en prestamo P preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then --valor para mensajes en prestamo P autorizacion
		let pvalor = ptipomail;
	end if;
	
foreach
			
    select a.numcte, a.num_credito, a.email,a.pago_minimo,a.saldo_total
		, a.monto_convenio,
		to_char(a.fecha_convenio, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_convenio ,
		to_char(a.fecha_compac, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_compac , to_char(a.fecha_primercons, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_primercons,
		trim (e.apell_paterno) || ' ' || trim ( e.apell_materno) || ' ' || trim (e.nombre1) || ' ' || trim (e.nombre2) as nombre_cliente 
    into pnumcte,pnumcredito,pemail,ppagominimo,psaldototal,pmontoconvenio,pfreestructu,
		 pfecha,pfechaprimercons ,pnombre  
    from bdicobranza:cb_mail_cliente a, bdinteg:si_cliente  e 
    where a.empresa = e.empresa
		and a.numcte = e.numcte
		and a.tipo_mensaje = ptipomensaje
		and a.pagos_vencidos = pvalor --se obtine de las validaciones anteriores
		and  a.fecha_insert = pfechahoy
	--montos
	if (ptipomensaje = 1) then let pmonto = ppagominimo; end if;
    if (ptipomensaje = 3) then let pmonto = pmontoconvenio; end if;
	if (ptipomensaje = 2) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 4) then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0)  then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10)  then let pmonto = psaldototal; end if;
	--fechas
	if (ptipomensaje = 3) then let vfecha = pfecha; end if;
	if (ptipomensaje = 1 and ptipomail = 30) then let vfecha = pfechaprimercons; END IF;
	if (ptipomensaje = 4 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then let vfecha = pfreestructu; end if;
	
	LET v_longitud = length(pemail);
			FOR v_cuenta = 1 to v_longitud
				  LET v_subcadena = SUBSTR(pemail,v_cuenta,1);
					IF v_subcadena  in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',
                                 'U','V','W','X','Y','Z',
                                 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
                                 'u','v','w','x','y','z',
                                 '1','2','3','4','5','6','7','8','9','0','@','_','-','.') THEN
						LET v_mail_incorrecto = 'F'; 
					-- INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					--	VALUES(current, pnumcte, pnumcredito, pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
					
						CONTINUE FOR;
					ELSE
						LET v_mail_incorrecto   = 'T';
				    EXIT FOR;
				    END IF;
			END FOR
			
				IF v_mail_incorrecto = 'T' THEN
					INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					VALUES(current, pnumcte, pnumcredito,/* null,null,*/pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
				else
					insert into bdinteg:"informix".si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente,
																	  monto_reportar, id_tipo_mensaje, enviado )
					values(vfecha, pnumcte, pnumcredito,/*null,null,*/ pnombre,pemail, pmonto,pidtipomensaje,'F');
				END IF;
			
end foreach
   let P_COD_RET = '000000';

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
end
RETURN P_COD_RET;
END PROCEDURE;