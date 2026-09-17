CREATE PROCEDURE "informix".sp_extraectassot(vdatefecoper DATE)
RETURNING VARCHAR(5), VARCHAR(50);
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
--//Variables de Proceso
DEFINE vcodret1         	VARCHAR(5);
DEFINE vcodret2         	VARCHAR(5);
DEFINE error_info			VARCHAR(50);
DEFINE sql_err          	INTEGER;
DEFINE isam_err         	INTEGER;
DEFINE vcontador1       	INTEGER;
DEFINE vcontador2       	INTEGER;
--//Variables de Opereaciones
DEFINE var_fecha_ant     	DATE;
DEFINE var_fecha_hoy     	DATE;
DEFINE var_num_cte       	VARCHAR(20);
DEFINE var_cuenta        	VARCHAR(20);
DEFINE var_num_tarjeta   	VARCHAR(20);
DEFINE var_sucursal    		VARCHAR(4);
DEFINE var_fecha_alta    	DATE;
DEFINE var_cred          	VARCHAR(2);
DEFINE var_saldo_promedio	MONEY;
---------------------------
--Inicializando variables--
---------------------------
--SET DEBUG FILE TO "/informix/ifg/sp_extraectassot.out"; --Se genera log en un archivo .out
--TRACE ON;
LET error_info		= 'INICIA PROCESO, SE CARGAN VARIABLES';
LET vcodret1        = '00000';
LET vcodret2        = '00000';
LET sql_err	        = 0;
LET isam_err        = 0;
LET vcontador1      = -1;
LET vcontador2      = 0;
-------------
--Inicia SP--
-------------
	BEGIN
		-------------------------
		--MAnejo de excepciones--
		-------------------------
		ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET isam_err = isam_err;
				LET error_info = error_info;
				COMMIT WORK;
				RETURN vcodret1, error_info;
			END IF;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--//Inicia SPL
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		--//CREA TABLA TEMPORAL PARA DISCRIMINAR CLIENTES CON PRODUCTOS '1300'Y '1800'
		SELECT DISTINCT(num_cte) FROM bdicheq:sc_maechq
			WHERE producto IN('1300', '1800')
			INTO temp tmp_prod_emp WITH NO LOG;

		
		FOREACH WITH HOLD
							SELECT
									vdatefecoper,
									vdatefecoper +1,
									a.num_cte,
									a.cuenta,
									c.num_tarjeta,
									a.sucursal,
									d.fecha_alta,
									'99', --creditos no evaluados
									ROUND((a.acum_sdo_pos / a.dia_sdo_pos), 2) saldo_promedio
									INTO var_fecha_ant, var_fecha_hoy, var_num_cte, var_cuenta, var_num_tarjeta, var_sucursal,
										 var_fecha_alta, var_cred, var_saldo_promedio
									FROM bdicheq:sc_maehis a, OUTER bdicheq:sc_tarjeta c, bdicheq:sc_maenoc d
									WHERE a.fechafin = vdatefecoper
									  AND a.producto IN('2000', '1900', '2400', '1700', '1400')
									  AND a.status_cta IN('1', '3', '4')
									  AND (a.acum_sdo_pos / a.dia_sdo_pos) >= 300.00
									  AND a.cuenta = c.cuenta
									  AND c.tipo_tarjeta = 'T'
									  AND c.status_tar = 'A'
									  AND c.expiracion > vdatefecoper --/se agrega para validar que la tarjeta no este expirada
									  AND C.secuencia = (SELECT {INDEX ix_tarjeta4} MAX(c.secuencia)
																FROM bdicheq:sc_tarjeta C WHERE c.cuenta = a.cuenta AND c.tipo_tarjeta = 'T'
																			AND c.status_tar = 'A')--/se agrega para traer la maxima secuencua de las tarjetas
									  AND a.cuenta = d.cuenta
									  AND a.dia_sdo_pos > 0
									  AND a.num_cte NOT IN(SELECT num_cte FROM tmp_prod_emp)
									  AND a.num_cte NOT IN(SELECT numcte FROM bdinteg:si_empleado_cliente_coppel
															WHERE status = '1')
							--/SE ACTIVA CONTADOR 1 	
							IF vcontador1 = -1 THEN
										LET vcontador1 = 0;
									BEGIN WORK;
							END IF;
							--//INSERTA REGISTRO 
							INSERT INTO "informix".si_sorteo_efectivo_temp(fecha_info, fecha_carga, num_cliente, num_cuenta, num_tarjeta, num_tienda, fec_fecha, cred_valid, saldo)
								VALUES(var_fecha_ant, var_fecha_hoy, var_num_cte, var_cuenta, var_num_tarjeta, var_sucursal, var_fecha_alta, var_cred, var_saldo_promedio);
							 --/incrementea contadores
						   LET vcontador1 = vcontador1 + 1;
						   LET vcontador2 = vcontador2 + 1; 
						   --/CADA 1000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
							IF vcontador2 >= 1000 THEN
										LET vcontador2 = 0;
										COMMIT WORK;
										BEGIN WORK;
							 END IF;
		END FOREACH;
		IF (vcontador1 > 0) THEN
		LET error_info = 'TOTAL DE CUENTAS CARGADAS DEL DIA '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||': '||vcontador1;
		END IF;
		IF (vcontador1 = -1) THEN
		LET error_info = 'TOTAL DE CUENTAS CARGADAS DEL DIA '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||': 0';
		END IF;
		IF (vcontador2 > 0) THEN		
			COMMIT WORK;
		END IF;
		DROP TABLE tmp_prod_emp;
		RETURN vcodret1, error_info;
	END;
END PROCEDURE

DOCUMENT
'CREADO POR: ISRAEL FLORES GONZALEZ',
'FECHA DE CREACION: 14 SEPTIEMBRE DE 2017',
'OBJETIVO: SE CREA PROCESO PARA CARGAR AUTOMATICAMENTE',
'          LAS CUENTAS QUE PARTICIPAN EN EL SORTEO',
'          EFECTUVO BANCOPPEL, DISCRIMINANDO A LOC CLIENTES',
'          CON PRODUCTOS 1800, 1300 Y EMPLEADOS DE GRUPO COPPEL',
'BD: BDICHEQ',
'    BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZALEZ',
'FECHA DE MODIFICACION: 27 SEPTIEMBRE DE 2017',
'OBJETIVO: SE TOMA LA FECHA AHHORA DEL PARAMETRO DE',
'          ENTRADA EN VEZ DE TOMARLO DE LA TABLA',
'          SC_FECHAS',
'BD: BDICHEQ',
'    BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZALEZ',
'FECHA DE MODIFICACION: 09 NOVIEMBRE DE 2017',
'OBJETIVO: SE VERIFICA QUE LA EXPIRACION DE LA',
'          TARJETA SEA MENOR A LA FECHA DE OPERACION',
'BD: BDICHEQ',
'    BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZALEZ',
'FECHA DE MODIFICACION: 22 NOVIEMBRE DE 2017',
'OBJETIVO: SE TOMA LA MAXIMA SECUENTA DE LAS',
'          TARJETAS, PARA QUE SOLO SE TOME UN REGISTRO',
'          CORRESPONDIENTE A LA CUENTA DE CAPTACION',
'BD: BDICHEQ',
'    BDINTEG';

CREATE PROCEDURE "informix".sp_conhuella(pempresa CHAR(3),
                                         psucursal CHAR(4),
                                         pejecutivo CHAR(8),
                                         pnumcte CHAR(20))
  RETURNING CHAR(5),char(942),char(942);

define vcodret CHAR(5);
define vexiste CHAR(1);
define vsqlerr INTEGER;
define visamerr INTEGER;
define vmapad  CHAR(942);
define vmapai  CHAR(942);



LET vcodret = "000";
LET vexiste = 0;
LET vmapad = "";
LET vmapai = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vmapad,vmapai;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--- Verifica recepcion correcta de datos
IF pnumcte IS NULL OR Trim(pnumcte) = "" THEN
   LET vcodret = "110";
   RETURN vcodret,vmapad,vmapai;
END IF;

SELECT 1 INTO vexiste
   FROM si_ejecut
   WHERE ejecutivo=pejecutivo;
IF vexiste IS NULL THEN
   LET vcodret="112";
   RETURN vcodret,vmapad,vmapai;
END IF;

   SELECT dmapa,imapa  INTO vmapad,vmapai
   FROM   si_cte_huella
   WHERE  numcte = pnumcte
   AND    estado ="A";
   IF vmapad is null or vmapai is null THEN
      let vcodret = "132";
      RETURN vcodret,vmapad,vmapai;
   END IF

   RETURN vcodret,vmapad,vmapai;
END;
END PROCEDURE
DOCUMENT
"Consulta de Huella de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Mario Escobar",
"FECHA : 06/Enero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_act_sucursalsorteo()
RETURNING CHAR (5);


--Declaracion de variables
DEFINE cCodRet        CHAR(5);
DEFINE iSqlErr        INTEGER;
DEFINE cParam107	  CHAR(5);
DEFINE cParam117	  CHAR(5);
DEFINE cValor118	  CHAR(5);
DEFINE cValor136	  CHAR(5);
DEFINE cSucursal	  CHAR(5);

--Asignacion de variables
LET cCodRet           = '00001';
LET iSqlErr           = 0;
LET cParam107		  ='';
LET cParam117		  ='';
LET cValor118		  ='';
LET cValor136		  ='';
LET cSucursal		  ='';

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_Act_SucursalSorteo.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
		
				
	SELECT valor INTO cParam107
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 107;

	SELECT valor  INTO cParam117
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 117;

	SELECT valor INTO cValor118
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 118;

	SELECT valor  INTO cValor136
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 136;

	
	FOREACH
	-- 27/11/2017.-INI.-(Patricia Del Razo): Se quita la condicion de <AND sucursal::INTEGER <= 2000> para dejar pasar nuevas sucursales.
		SELECT sucursal INTO cSucursal
		FROM bdinteg:"informix".si_sucursales
		WHERE  tpo_sucursal = 'S'  ---RRG SE AGREGA CONDICION PARA TRAER SOLO SUCURSALES ACTIVAS
		  AND (sucursal != '' AND sucursal IS NOT NULL)
         --    AND sucursal::INTEGER <= 2000
    -- 27/11/2017.-FIN.-(Patricia Del Razo): Se quita la condicion de <AND sucursal::INTEGER <= 2000> para dejar pasar nuevas sucu
		
		IF NOT EXISTS (SELECT sucursal FROM bdinteg:"informix".si_sucursales_sorteo WHERE sucursal = cSucursal) THEN	
			
			IF cParam107 = '1' AND cParam117 = '1'  THEN  -- Sorteo Normal e InstantÃ¡neo Vigentes
			
				INSERT INTO bdinteg:"informix".si_sucursales_sorteo (empresa,sucursal,cve_sorteo_normal,cve_sorteo_inst,flag_sorteo_normal
				,flag_imprime_normal,flag_sorteo_inst,flag_imprime_inst,fecha_insert,user_insert)
				VALUES('001',cSucursal,cValor118,cValor136,1,1,1,1,CURRENT,'informix');
				
				LET cCodRet = '00000';
							
			ELIF cParam107 = '0' AND cParam117 = '1'  THEN	-- Sorteo Normal no Vigente y Sorteo InstantÃ¡neo Vigente
				
				INSERT INTO bdinteg:"informix".si_sucursales_sorteo (empresa,sucursal,cve_sorteo_normal,cve_sorteo_inst,flag_sorteo_normal
				,flag_imprime_normal,flag_sorteo_inst,flag_imprime_inst,fecha_insert,user_insert)
				VALUES('001',cSucursal,cValor118,cValor136,0,0,1,1,CURRENT,'informix');
				
				LET cCodRet = '00000';
						
			ELIF cParam107 = '1' AND cParam117 = '0'  THEN	-- Sorteo Normal Vigente y Sorteo InstantÃ¡neo no Vigente
				
				INSERT INTO bdinteg:"informix".si_sucursales_sorteo (empresa,sucursal,cve_sorteo_normal,cve_sorteo_inst,flag_sorteo_normal
				,flag_imprime_normal,flag_sorteo_inst,flag_imprime_inst,fecha_insert,user_insert)
				VALUES('001',cSucursal,cValor118,cValor136,1,1,0,0,CURRENT,'informix');
				
				LET cCodRet = '00000';
				
			ELIF cParam107 = '0' AND cParam117 = '0'  THEN	 -- Sorteo Normal no Vigente y Sorteo InstantÃ¡neo no Vigente

				INSERT INTO bdinteg:"informix".si_sucursales_sorteo (empresa,sucursal,cve_sorteo_normal,cve_sorteo_inst,flag_sorteo_normal
				,flag_imprime_normal,flag_sorteo_inst,flag_imprime_inst,fecha_insert,user_insert)
				VALUES('001',cSucursal,cValor118,cValor136,0,0,0,0,CURRENT,'informix');

				LET cCodRet = '00000';
				
			ELSE
			
				LET cCodRet = '00002';
			END IF		
		
		END IF	
		
	END FOREACH;
		
		
	RETURN cCodRet;	
		
END;
END PROCEDURE
DOCUMENT
'AUTOR: Josue Zepeda',
'FECHA: 12/07/2012',
'BD: bdinteg',
'Objetivo: Actualizar sucursales en tabla si_sucursales_sorteo para Sorteo';

CREATE PROCEDURE "informix".sp_insert_aut_privacidad_usuarios (pempresa CHAR(3), pnumcte CHAR(20), psucursal CHAR(4),
															   prespuesta CHAR(1), pmensaje VARCHAR(200))
--DATOS DE SALIDA
Returning CHAR (5) AS cCodRet;
	
--DECLARACION DE VARIABLES
DEFINE iSqlErr     INTEGER;
DEFINE iIsamErr    INTEGER;
DEFINE cCodRet	   CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr       	   = 0;
LET iIsamErr           = 0;
LET cCodRet			   = '00000';

SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/Anayeli.out";
--TRACE ON;

BEGIN
	--CONTROL DE ERRORES 'INFORMIX' NO CONTROLADOS
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
	LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
		IF (pempresa = '') OR (pempresa IS NULL) OR (pnumcte = '') OR (pnumcte IS NULL) OR (psucursal = '') OR (psucursal IS NULL)
			OR (prespuesta = '') OR (prespuesta IS NULL) OR (pmensaje = '') OR (pmensaje IS NULL) THEN
			LET cCodRet = '00001'; --PARAMETROS VACIOS.
			RETURN cCodRet;
        END IF;
		
		IF EXISTS (SELECT respuesta FROM bdinteg:"informix".si_aut_privacidad_usuarios WHERE numcte = pnumcte) THEN
			UPDATE bdinteg:"informix".si_aut_privacidad_usuarios SET respuesta = prespuesta, mensaje = pmensaje WHERE numcte = pnumcte;
			LET cCodRet = '00000'; -- LA RESPUESTA DEL CLIENTE YA EXISTE EN LA TABLA.
			RETURN cCodRet;

		ELSE
			INSERT INTO bdinteg:"informix".si_aut_privacidad_usuarios (empresa, numcte, sucursal, respuesta, mensaje, fecha) 
			VALUES (pempresa, pnumcte, psucursal, prespuesta, pmensaje, current);
			LET cCodret = '00000'; --SE INSERTARON LOS DATOS CORRECTAMENTE.
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
--'DOCUMENT',
--'FOLIO: 197',
--'DESCRIPCION: INSERTA LA AUTORIZACION DEL CLIENTE DE REMESAS AL AVISO DE PRIVACIDAD EN LA TABLA DE AVISO DE PRIVACIDAD..',
--'..TAMBIEN SIRVE PARA CONSULTAR SI EL USUARIO YA HABIA VALIDADO EL AVISO ANTERIORMENTE.',
--'AUTOR: ANAYELI CAMACHO GUTIERRÃZ',
--'SUSTENTO: RQI 63 266 ALTA DE USUARIOS DE REMESA OFI',
--'FECHA DE CREACION: 21/03/2017',
--'SOLICITA: JAIME GONZALEZ',
--'VERSION: 1.0 20170321',
--'BD: BDINTEG',
--'------------------------------------------------------------------------------------------------------------------------';;

CREATE PROCEDURE "informix".sp_altaserv_edoctamov(pempresa CHAR(3), pnumcte CHAR(20),pcuenta CHAR(20),pproducto CHAR(4),pusuario CHAR(10),ptipo SMALLINT )
	RETURNING CHAR(6) AS CodRet,CHAR(20) AS Cuenta;

	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetorno		CHAR(6);
	DEFINE sCuenta			CHAR(20);
	DEFINE iCantReg		INTEGER;
	 
	LET iSqlErr	 = 	0;
	LET cCodRetorno	 = 	'000000';
	LET sCuenta	 = '';
	LET iCantReg = 0;
	
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/OmarLerma/sp_altaserv_edoctamov.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'';
			END IF;
		END EXCEPTION;	
	
		
		IF TRIM(pempresa) = '' AND TRIM(pnumcte) = '' AND TRIM(pproducto) = '' AND TRIM(pusuario) = '' AND TRIM(pcuenta) = '' THEN
		
			LET cCodRetorno = '00002';				
			RETURN cCodRetorno,'';
			
		ELSE
		
			IF ptipo = 0 THEN		
												
				
				SELECT  DISTINCT(cuenta)
				INTO sCuenta
				FROM bdinteg: "informix".si_altaserv_edoctamov 
				WHERE empresa = pempresa AND cuenta = pcuenta;
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				
				IF iCantReg = 0 THEN
			
					LET sCuenta = '';	
					
				END IF;
				
				RETURN cCodRetorno,sCuenta;
	
			
				
			ELIF ptipo = 1 THEN
				
				INSERT INTO bdinteg: "informix".si_altaserv_edoctamov (empresa,numcte,cuenta,producto,fecha_cancel_servicio,user_modif) 
				VALUES (pempresa,pnumcte,pcuenta,pproducto,current,pusuario);
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				IF iCantReg = 0 THEN
	
					LET sCuenta = '';	
					LET cCodRetorno = '000004';
				END IF;
				
				RETURN cCodRetorno,'';
				
			ELIF ptipo = 2 THEN
			
				DELETE FROM bdinteg: "informix".si_altaserv_edoctamov 
				WHERE empresa = pempresa 
				AND numcte = pnumcte 
				AND cuenta = pcuenta;
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				IF iCantReg = 0 THEN
	
					LET sCuenta = '';	
					LET cCodRetorno = '000005';
				END IF;
						
				RETURN cCodRetorno,'';
				
			END IF;
			
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT
'FOLIO: 301-RQM 10 943 - ActivaciÃ³n y CancelaciÃ³n de envÃ­o por correo electrÃ³nico del Estado de Movimientos',
'AUTOR: Omar Lerma',
'FECHA: 22/09/2017',
'MODIFICACIÃN: SE CREA PROCEDIMIENTO PARA INSERTAR A LOS CLIENTES QUE CANCELEN EL SERVICIO',
'SOLICITA: CUTBERTO',
'DB:BDINTEG';

CREATE PROCEDURE "informix".sp_repejecutivo_db2()

RETURNING CHAR(5)     		AS CodRet,
		  VARCHAR(3)  		AS Empresa,
		  VARCHAR(4)  		AS Sucursal,
		  VARCHAR(8)  		AS Ejecutivo,
		  VARCHAR(1)  		AS Perfil,
		  CHAR(10)        	AS Fecha_alta,
		  CHAR(10)     		AS Fecha_ult_cambio,
		  VARCHAR(50) 	  	AS Nombre_usuario,
		  SMALLINT    		AS Cajero_certifi,
		  SMALLINT    		AS Cajero_en_linea,
		  SMALLINT    		AS Cajero_privilegio,
		  SMALLINT   		AS Cajero_apertura,
		  SMALLINT    		AS Sesion,
		  DECIMAL(16,2)     AS Cajero_monto_min,
		  DECIMAL(16,2)     AS Cajero_monto_max,
		  SMALLINT    		AS Cajero_cierre_est,
		  SMALLINT    		AS Cajero_cierre_dia,
		  VARCHAR(12)   	AS Mac_address,
		  VARCHAR(16)     	AS Ipmicro,
		  VARCHAR(20)    	AS Edo_usuario,
		  VARCHAR(20)    	AS Nombramiento,
		  CHAR(10)			AS Fecha_insert,
		  CHAR(10)        	AS Fecha_modif,
		  VARCHAR(5)    	AS Tipo_evento,
		  INTEGER			AS TotalReg;
		  
DEFINE cCodRet 				CHAR(5);
DEFINE iSqlError    	 	INTEGER;
DEFINE vEmpresa				VARCHAR(3);
DEFINE vSucursal			VARCHAR(4); 
DEFINE vEjecutivo			VARCHAR(8);  
DEFINE vPerfil				VARCHAR(1); 
DEFINE dFecha_alta			CHAR(10);
DEFINE dFecha_ult_cambio	CHAR(10);
DEFINE vNombre_usuario		VARCHAR(50); 
DEFINE sCajero_certifi		SMALLINT;
DEFINE sCajero_en_linea		SMALLINT;
DEFINE sCajero_privilegio	SMALLINT;
DEFINE sCajero_apertura		SMALLINT;
DEFINE sSesion				SMALLINT;
DEFINE dCajero_monto_min	DECIMAL(16,2);
DEFINE dCajero_monto_max	DECIMAL(16,2);
DEFINE sCajero_cierre_est	SMALLINT;
DEFINE sCajero_cierre_dia	SMALLINT;
DEFINE vMac_address			VARCHAR(12);
DEFINE vIpmicro				VARCHAR(16);
DEFINE vEdo_usuario			VARCHAR(20);
DEFINE vNombramiento		VARCHAR(20);
DEFINE dFecha_insert		CHAR(10);
DEFINE dFecha_modif			CHAR(10);
DEFINE vTipo_evento			VARCHAR(5);
DEFINE iTotalReg			INTEGER;

LET cCodRet     	       = '00001';
LET iSqlError   	       = 0;
LET vTipo_evento    	   = '';
LET vMac_address     	   = '';
LET vNombramiento          = '';
LET dFecha_modif           = '';
LET vEdo_usuario           = '';
LET dFecha_insert          = '';
LET vIpmicro               = '';
LET sCajero_cierre_dia     = '';
LET sCajero_cierre_est     = '';
LET dCajero_monto_max      = '';
LET dCajero_monto_min      = '';
LET sSesion                = '';
LET sCajero_apertura       = '';
LET sCajero_privilegio     = '';
LET sCajero_en_linea       = '';
LET sCajero_certifi        = '';
LET vNombre_usuario        = '';
LET dFecha_ult_cambio      = '';
LET dFecha_alta            = '';
LET vPerfil                = '';
LET vEjecutivo             = '';
LET vSucursal              = '';
LET vEmpresa               = '';
LET iTotalReg              = 0;

	--******************************************************* 
	--SET DEBUG FILE TO "/informix/sp_repejecutivo_db2.out";
	--TRACE ON;                                          
	--*******************************************************
BEGIN	
	ON EXCEPTION SET iSqlError
		IF iSqlError <> 0 THEN
			LET cCodRet = iSqlError;
			RETURN cCodRet,vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento,iTotalReg;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT;
		
		SELECT COUNT (ejecutivo) 
		INTO iTotalReg  
		FROM bdinteg:"informix".si_ejecut_replica_db2;
		
	    IF iTotalReg > 0 THEN
			FOREACH	
				SELECT empresa,sucursal,ejecutivo,perfil,fecha_alta,fecha_ult_cambio,nombre_usuario,cajero_certifi,cajero_en_linea,cajero_privilegio,cajero_apertura,sesion,cajero_monto_min,
				cajero_monto_max,cajero_cierre_est,cajero_cierre_dia,mac_address,ipmicro,edo_usuario,nombramiento,fecha_insert,fecha_modif,tipo_evento
				INTO vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento
				FROM bdinteg:"informix".si_ejecut_replica_db2
				
				LET cCodRet = '00000';
			
				RETURN cCodRet,vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento,iTotalReg WITH RESUME;		
			END FOREACH;
		ELSE		
			RETURN cCodRet,vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento,iTotalReg;
		END IF;
END;
END PROCEDURE
DOCUMENT
'Procedimiento   : sp_repejecutivo_db2',
'Folio           : 282',
'Creado por      : Hever Barraza',
'Fecha creaciÃÂ³n  : 28/07/2017',
'DescripciÃ³n     : Realiza la recopilaciÃ³n del catÃ¡logo de empleados que se encuentran en la tabla SI_EJECUT_REPLICA_DB2';

CREATE PROCEDURE "informix".sp_get_indicadores_idbox_manual(dFechaini DATE, dFechafin DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE iNomErr			INTEGER;
DEFINE iNanErr			INTEGER;
DEFINE iEnTransaccion   SMALLINT;
DEFINE dFechaProceso	DATE;
DEFINE bTablatmp		BOOLEAN;


--ASIGNACION DE VARIABLES
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO SE A GENERADO CORRECTAMENTE';
LET iEnTransaccion = 0;
LET bTablatmp = 'f';

--SET DEBUG FILE TO "/tmp/ALAN/SOC/sp_indicadores_manual_idbox.out";
--TRACE ON;

BEGIN

	--MANEJO DEL ERROR
		ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
			IF iNomErr <> 0 THEN
			LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN
					ROLLBACK;
					
					LET iEnTransaccion = 0;
					
					IF bTablatmp = 't' THEN
						LET bTablatmp = 'f';	
					END IF;
                END IF;
				
				IF bTablatmp = 't' THEN
					DROP TABLE si_tmp_ctes_titulares_idbox;
					LET bTablatmp = 'f';
				END IF;
				
				RETURN vCodRet, cMensCodRet;
			END IF;
		END EXCEPTION;	
		
		IF NVL(dFechaIni,'') = '' OR  NVL(dFechaFin,'') = ''  THEN 		
			LET vCodRet = '000001';
			LET cMensCodRet = 'PARAMETRO INCORRECTO';
			RETURN vCodRet, cMensCodRet;
		ELIF dFechaIni > dFechaFin THEN
			LET vCodRet = '000002';
			LET cMensCodRet = 'PARAMETROS INCORRECTOS, FECHA INCIAL MAYOR A FECHA FINAL';
			RETURN vCodRet, cMensCodRet;
		END IF;
			
		LET dFechaProceso = dFechaIni;
		
		WHILE (dFechaProceso <= dFechaFin)
			BEGIN WORK;
			
				LET iEnTransaccion = 1;
					
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;	
				SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, a.ejecutivo AS numemp, a.fecha_insert
				FROM bdinteg:"informix".si_cliente a INNER JOIN bdinteg:"informix".si_ctepf b
				ON a.numcte = b.numcte	
				WHERE a.fecha_insert = dFechaProceso
				AND a.tipo_cliente='1'
				INTO TEMP si_tmp_ctes_titulares_idbox WITH NO LOG;
				
				LET bTablatmp = 't';
					
				IF  EXISTS (SELECT 1 FROM si_indicadores_idbox WHERE fecha_proceso = dFechaProceso) THEN
					DELETE FROM si_indicadores_idbox
					WHERE fecha_proceso = dFechaProceso;
				END IF;	
				
				INSERT INTO si_indicadores_idbox (fecha_proceso,sucursal,altas_total,total_idb,user_insert,fecha_insert)
				SELECT NVL(b.fecha_insert,dFechaProceso) AS fecha_insert,a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb,user as usuer_insert,(SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals) as fecha_insert
					FROM si_sucursales a
					LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE si_tmp_ctes_titulares_idbox
									SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total, clientes.fecha_insert FROM 
									(SELECT numcte, sucursal,fecha_insert 
									FROM si_tmp_ctes_titulares_idbox
									WHERE fecha_insert = dFechaProceso) clientes
									INNER JOIN
								--OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
									(SELECT DISTINCT(numcte), sucursal, fecha
									FROM si_bitacora_ife
									WHERE date(fecha) = dFechaProceso) bitacora
									ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
									GROUP BY clientes.sucursal,clientes.fecha_insert
							 ) b 	ON a.sucursal=b.sucursal
					LEFT JOIN (--OBTENIENDO ALTAS POR SUCURSAL
									SELECT sucursal, COUNT(DISTINCT (numcte)) AS total
									FROM si_tmp_ctes_titulares_idbox
									WHERE fecha_insert = dFechaProceso
									GROUP BY sucursal
							  )C 	ON a.sucursal=C.sucursal	
					WHERE a.sucursal IN (SELECT DISTINCT(sucursal) FROM si_bitacora_ife);
					
				IF bTablatmp = 't' THEN
					DROP TABLE si_tmp_ctes_titulares_idbox;
					LET bTablatmp = 'f';
				END IF;

			COMMIT WORK;
				LET iEnTransaccion = 0;
				LET dFechaProceso = dFechaProceso + 1 UNITS DAY; 
		END WHILE;
		
		RETURN vCodRet, cMensCodRet;	
END;
		
END PROCEDURE		
;