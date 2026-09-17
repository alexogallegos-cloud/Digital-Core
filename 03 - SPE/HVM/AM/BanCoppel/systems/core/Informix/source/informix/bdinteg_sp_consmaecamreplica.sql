CREATE PROCEDURE "informix".sp_consmaecamreplica (cSucursalParam CHAR(5), iNumRegistros INTEGER)

RETURNING
CHAR(5)  AS codigo_retorno,
CHAR(5)  AS codigo_retorno2,
CHAR(3)  AS cEmpresa,
CHAR(5)  AS cSucursal,
CHAR(5)  AS cNum_Producto,
CHAR(2)  AS cSistem,
CHAR(1)  AS cEstatus,
SMALLINT AS sIdCamp,
SMALLINT AS sIdJerarquia,
SMALLINT AS sIdNivel,
SMALLINT AS sIdZona,
SMALLINT AS sActiva,
SMALLINT AS sAct_Zona,
SMALLINT AS sCombinable,
SMALLINT AS sIdMensaje,
SMALLINT AS sTran_nro;

--DEFINICION DE VARIABLES--
DEFINE iSqlErr       INTEGER;
DEFINE cCodRet       CHAR(5);	
DEFINE cCodRet2      CHAR(5);
DEFINE iRows         INTEGER;
---------------------------
DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(5);
DEFINE cNum_Producto  CHAR(5);
DEFINE cSistema       CHAR(2);
DEFINE cEstatus       CHAR(1);
DEFINE sIdCamp        SMALLINT;
DEFINE sIdJerarquia   SMALLINT;
DEFINE sIdNivel       SMALLINT;
DEFINE sIdZona        SMALLINT;
DEFINE sActiva        SMALLINT;
DEFINE sAct_Zona      SMALLINT;
DEFINE sCombinable    SMALLINT;
DEFINE sIdMensaje     SMALLINT;
DEFINE sTran_nro      SMALLINT;
DEFINE iContador      INTEGER;
DEFINE cPlaza         CHAR(3);

--INICIALIZACION DE VARIABLES--
LET iSqlErr        = 0;
LET cCodRet        = '00000';
LET cCodRet2        = '00000';
LET iRows          = 0;
-------------------------------
LET cEmpresa       = '';
LET cSucursal      = '';
LET cNum_Producto  = '';
LET cSistema       = '';
LET cEstatus       = '';
LET sIdCamp        = 0;
LET sIdJerarquia   = 0;
LET sIdNivel       = 0;
LET sIdZona        = '';
LET sActiva        = 0;
LET sAct_Zona      = 0;
LET sCombinable    = 0;
LET sIdMensaje     = 0;
LET sTran_nro      = 0;
LET iContador      = 0;
LET cPlaza         = '';

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_consmaecamreplica.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			   RETURN cCodRet, 
			         cCodRet2, 
					 cEmpresa,     
					 cSucursal,    
					 cNum_Producto,
					 cSistema,     
					 cEstatus,     
					 NVL(sIdCamp,0),      
					 NVL(sIdJerarquia,0), 
					 NVL(sIdNivel,0),     
					 NVL(sIdZona,0),      
					 NVL(sActiva,0),     
					 NVL(sAct_Zona,0), 
					 NVL(sCombinable,0),  
					 NVL(sIdMensaje,0),      	  
					 NVL(sTran_nro,0);
			END IF;
		END EXCEPTION;	
		
		--Valida parámetros de entrada
		IF NVL(cSucursalParam,'') = '' OR iNumRegistros IS NULL THEN	

			-- Parámetro de entrada vacío
			LET cCodRet2 = '00001';
			
		   RETURN cCodRet, 
		         cCodRet2,
				 cEmpresa,     
				 cSucursal,    
				 cNum_Producto,
				 cSistema,     
				 cEstatus,     
				 sIdCamp,      
				 sIdJerarquia, 
				 sIdNivel,     
				 sIdZona,      
				 sActiva,     
				 sAct_Zona, 
				 sCombinable,  
				 sIdMensaje,  				 
				 sTran_nro
			WITH RESUME;

		ELSE		

			-- Se consulta si la zona de la sucursal asignada está activa
			SELECT plaza
			  INTO cPlaza
			  FROM bdinteg:"informix".si_sucursales
			 WHERE sucursal = cSucursalParam;
			 
			IF NVL(cPlaza,'') <> '' THEN
			 
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_maecamp WHERE idzona = cPlaza AND activa = 1 AND act_zona = 1 ) THEN
				
					FOREACH
					
						SELECT  empresa,     			  			
								num_producto,			
								sistema,     			
								estatus,     			
								idcamp,      			
								idjerarquia, 			
								idnivel,     			
								idzona,      			
								activa,      			
								act_zona,    			
								combinable,  			
								idmensaje,   			
								tran_nro    			
						   INTO cEmpresa,        
								cNum_Producto,
								cSistema,     
								cEstatus,     
								sIdCamp,      
								sIdJerarquia, 
								sIdNivel,     
								sIdZona,      
								sActiva,      
								sAct_Zona,    
								sCombinable,  
								sIdMensaje,   
								sTran_nro    			   
						   FROM bdinteg:"informix".si_maecamp
						  WHERE idzona = cPlaza
						    AND	activa = 1	
							AND	act_zona = 1
							
							LET iContador = iContador + 1;

							IF iContador <= iNumRegistros THEN
								CONTINUE FOREACH;
							END IF; 							

						   RETURN cCodRet, 
								 cCodRet2,
								 cEmpresa,     
								 cSucursal,    
								 cNum_Producto,
								 cSistema,     
								 cEstatus,     
								 sIdCamp,      
								 sIdJerarquia, 
								 sIdNivel,     
								 sIdZona,      
								 sActiva,     
								 sAct_Zona, 
								 sCombinable,  
								 sIdMensaje,  				 
								 sTran_nro
							WITH RESUME;	

					END FOREACH;
				
				END IF;

			END IF; 
			
			FOREACH		
			
				--Se seleccionan los datos de central
				SELECT  empresa,     			
						sucursal,    			
						num_producto,			
						sistema,     			
						estatus,     			
						idcamp,      			
						idjerarquia, 			
						idnivel,     			
						idzona,      			
						activa,      			
						act_zona,    			
						combinable,  			
						idmensaje,   			
						tran_nro    			
				   INTO cEmpresa,     
						cSucursal,    
						cNum_Producto,
						cSistema,     
						cEstatus,     
						sIdCamp,      
						sIdJerarquia, 
						sIdNivel,     
						sIdZona,      
						sActiva,      
						sAct_Zona,    
						sCombinable,  
						sIdMensaje,   
						sTran_nro    			   
				   FROM bdinteg:"informix".si_maecamp
				  WHERE empresa='001' and (sucursal = cSucursalParam  OR sucursal = 'T')
					AND	activa = 1	
					
				IF NVL(cEmpresa,"") <> "" OR NVL(cSucursal,"") <> "" OR NVL(cNum_Producto,"") <> "" OR NVL(cSistema,"") <> "" THEN
													
					LET iContador = iContador + 1;

					IF iContador <= iNumRegistros THEN --DSB 11/10/2013 Christian Echavarria se agrega =
						CONTINUE FOREACH;
					END IF; 
					
				   RETURN cCodRet, 
				         cCodRet2,
						 cEmpresa,     
						 cSucursal,    
						 cNum_Producto,
						 cSistema,     
						 cEstatus,     
						 sIdCamp,      
						 sIdJerarquia, 
						 sIdNivel,     
						 sIdZona,      
						 sActiva,     
						 sAct_Zona, 
						 sCombinable,  
						 sIdMensaje,  				 
						 sTran_nro
					WITH RESUME;					
				
				ELSE	

					--No se encontraron datos
					LET cCodRet2 = '00002';

				  RETURN cCodRet, 
				         cCodRet2,
						 cEmpresa,     
						 cSucursal,    
						 cNum_Producto,
						 cSistema,     
						 cEstatus,     
						 sIdCamp,      
						 sIdJerarquia, 
						 sIdNivel,     
						 sIdZona,      
						 sActiva,     
						 sAct_Zona, 
						 sCombinable,  
						 sIdMensaje,  				 
						 sTran_nro
					WITH RESUME;
				  					
				END IF;

			END FOREACH; 
																--1711
			IF NVL(cEmpresa,"") = "" OR (NVL(cSucursal,"") = "" AND NVL(cPlaza,"") = "" ) OR NVL(cNum_Producto,"") = "" OR NVL(cSistema,"") = "" THEN		
				LET cCodRet2 = '00003';

				  RETURN cCodRet, 
				         cCodRet2,
						 cEmpresa,     
						 cSucursal,    
						 cNum_Producto,
						 cSistema,     
						 cEstatus,     
						 sIdCamp,      
						 sIdJerarquia, 
						 sIdNivel,     
						 sIdZona,      
						 sActiva,     
						 sAct_Zona, 
						 sCombinable,  
						 sIdMensaje,  				 
						 sTran_nro;
			END IF;
			
		END IF;

	END
END PROCEDURE
DOCUMENT
'Se consultan los datos de la tabla si_maecamp para replicarlos en sucursal',
'Realizó: Nancy Sevilla Camacho',
'Fecha: 03/05/2012  ',
'Se modifica el foreach para la paginación',
'Realizó: Christian Echavarria',
'Fecha: 11/10/2013',
'BD    : bdinteg',
'FECHA: 27/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA VALIDAR SI EL NUMERO DE ZONA O DE SUCURSAL ESTAN VACIAS RETORNE EL CODIGO 3',
'AUTOR: 95358897-ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_generararchivoplanobatch_pba(cTipoMov CHAR(2), pFechaAct DATE)
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
	LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunica';
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
					
				IF EXISTS (SELECT  {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} DISTINCT tipomovto FROM "informix".si_archivoscopdiario WHERE tipomovto <> 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunica'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica3.unl';
					--
					LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(vRuta)|| 'movimientosaltaunicax.unl' || ' DELIMITER ' || '''|''' || 
								' SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} trama ' || TRIM(vAux) ||
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
					SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
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
				IF EXISTS (SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)}DISTINCT tipomovto FROM "informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica'|| cFecha_hoy || '.txt';
					LET sPreNomArchivoFinal =  TRIM(vRuta)|| 'cifrasaltaunica.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica3.unl';
					--
					---	GENERA EL ARCHIVO PLANO
					LET vsSQL1 = ' echo "UNLOAD TO ' || TRIM(vRuta)||'cifrasaltaunicax.unl' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} trama FROM  bdinteg:si_archivoscopdiario WHERE  tipomovto = '"||cTipoMov||"' AND fecha_insert ='"||pFechaAct||"';";
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
					SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario
					WHERE tipomovto = 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} FROM "informix".si_archivoscopdiario
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