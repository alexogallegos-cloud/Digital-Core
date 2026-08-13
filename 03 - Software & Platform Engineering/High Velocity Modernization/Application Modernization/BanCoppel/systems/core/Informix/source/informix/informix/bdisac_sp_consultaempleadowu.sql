CREATE PROCEDURE "informix".sp_consultaempleadowu
(
	pSucursal CHAR(4), 	pEmpleado CHAR(8), pCategoria CHAR(2), 	pConvenio CHAR(3), pModo SMALLINT, pFlag char(1)
)
--		pSucursal		CHAR(4);  ? Parámetro obligatorio.
--		pEmpleado		CHAR(8);  ? Parámetro obligatorio.
--		pCategoria		CHAR(2);  ? Parámetro Obligatorio para modalidad 2.
--		pConvenio 		CHAR(3);  ? Parámetro obligatorio para modalidad 2.
--		pModo			SMALLINT; ? Parámetro obligatorio.
		
RETURNING
	CHAR(5)  AS cCodRet,	    	
	SMALLINT AS sValor,	
	CHAR(100) AS cDescripcion,   
	CHAR(1)  AS cMsg;

DEFINE cCodRet		  CHAR(5);
DEFINE iSqlErr  	  INTEGER;
DEFINE sValor		  SMALLINT;
DEFINE cDescripcion   CHAR(100);
DEFINE cMsg			  CHAR(1);
DEFINE cEdoFronterizo CHAR(2); --Estado fronterizo.
DEFINE dFecha_hoy	  DATETIME YEAR TO FRACTION;

--VPR
DEFINE cCod_err CHAR(5);
DEFINE cNom_convenio CHAR(40);
DEFINE cFlg_ref1 CHAR(1);
DEFINE cFlg_ref2 CHAR(1);
DEFINE iLong_ref1 INTEGER;
DEFINE cFlg_calculoref1 CHAR(1);
DEFINE cFlg_calculoref2 CHAR(1);
DEFINE iLong_ref2 INTEGER;
DEFINE cStatus_convenio CHAR(1);
--
DEFINE cSPCodRet CHAR(5); 
DEFINE iMensaje CHAR(50);
DEFINE cid_ptf CHAR(5); 
DEFINE ccve_pais CHAR(3);
DEFINE cnompais CHAR(20);
DEFINE ccalle VARCHAR(100); 
DEFINE cnum_ext VARCHAR(6); 
DEFINE cnum_int VARCHAR(5); 
DEFINE ccve_col CHAR(8);
DEFINE cnomcol VARCHAR(100);
DEFINE ccve_mun CHAR(3);
DEFINE cnommunicipio VARCHAR(60);
DEFINE ccve_localidad CHAR(14);
DEFINE cnomlocalidad VARCHAR(60);
DEFINE ccp CHAR(5); 
DEFINE ccve_ciudad CHAR(3);
DEFINE cnomciudad VARCHAR(60);
DEFINE ccve_estado CHAR(2); 
DEFINE cnomestado VARCHAR(30);
DEFINE ctel1 VARCHAR(14); 
DEFINE ctel2 VARCHAR(14);
DEFINE ctipo VARCHAR(5);

LET cCodRet		   = '00005'; --Inicializado como código de error en caso de no entrar al cuerpo del sp.
LET iSqlErr  	   = 0;
LET sValor		   = 0;
LET cDescripcion   = 'Error en sp sac_registraempleadowu';   
LET cMsg		   = '';	
LET cEdoFronterizo = '';
LET dFecha_hoy	   = CURRENT;

--VPR
LET cCod_err = '';
LET cNom_convenio = '';
LET cFlg_ref1 = '';
LET cFlg_ref2 = '';
LET iLong_ref1 = 0;
LET cFlg_calculoref1 = '';
LET cFlg_calculoref2 = '';
LET iLong_ref2 = 0;
LET cStatus_convenio = '';
--
LET cSPCodRet = '00000';
LET iMensaje = '';
LET cid_ptf = '';
LET ccve_pais = '';
LET cnompais = '';
LET ccalle = '';
LET cnum_ext = ''; 
LET cnum_int = '';
LET ccve_col = '';
LET cnomcol = '';
LET ccve_mun = '';
LET cnommunicipio = '';
LET ccve_localidad = '';
LET cnomlocalidad = '';
LET ccp = '';
LET ccve_ciudad = '';
LET cnomciudad = '';
LET ccve_estado = ''; 
LET cnomestado = '';
LET ctel1 = '';
LET ctel2 = '';
LET ctipo = '';

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescripcion = 'Código y mensaje de error no controlado';
			RETURN cCodRet, sValor, cDescripcion, cMsg;	
		END IF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1508/sp_consultaempleadowu_aia.out';
		--TRACE ON;
			 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  

		--Validamos parámetros obligatorios
		IF NVL(pSucursal, '') = '' OR NVL(pEmpleado, '') = '' OR NVL(pModo, '') = '' THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'Faltan parámetros de entrada';  
			RETURN cCodRet, sValor, cDescripcion, cMsg;			
		ELSE
			--Obtenemos la fecha de bdinteg:"informix".si_fechas (campo fecha_hoy) y la guardamos en la variable dFecha_hoy para uso posterior.
			SELECT fecha_hoy
			INTO dFecha_hoy
			FROM bdinteg:"informix".si_fechas;
			
			IF pModo = '1' THEN	
			
				--Mandamos executar sp para saber si el servicio esta activo  -VPR
				EXECUTE PROCEDURE "informix".sp_consulta_convenio(pCategoria,pConvenio)
				INTO cCod_err,cNom_convenio,cFlg_ref1,cFlg_ref2,iLong_ref1,cFlg_calculoref1,cFlg_calculoref2,iLong_ref2,cStatus_convenio;
					
				IF cCod_err = '001' THEN
					LET cCodRet = '00504';
					LET cDescripcion = 'Por el momento, el servicio de Western Union no esta operando, inténtelo más tarde'; 
					
					RETURN cCodRet, sValor, cDescripcion, cMsg;	
				END IF;
				
				--Validamos que la sucursal recibida como parámetro exista en bdinteg:"informix".si_sucursales.
				/*IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal) THEN
					LET cCodRet = '00002';
					LET cDescripcion = 'No existe la sucursal'; 
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE
					
					SELECT estado 
					INTO cEdoFronterizo
					FROM bdinteg:"informix".si_sucursales 
					WHERE sucursal = pSucursal;
					*/
					execute procedure bdisac:"informix".sp_sac_consucursales(TRIM(pSucursal)) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
					IF cSPCodRet <> '00000' THEN
						LET cCodRet = '00002';
						LET cDescripcion = 'No existe la sucursal'; 
						RETURN cCodRet, sValor, cDescripcion, cMsg;
					ELSE
						LET cEdoFronterizo = ccve_estado;
					END IF;
						
					--Validamos si la sucursal está o no en un estado fronterizo
					------------------------------------------------------------------------------------------------------------------
					IF EXISTS 
					(SELECT descripcion FROM "informix".sac_param WHERE  TRIM(valor) LIKE '%' || TRIM(cEdoFronterizo) || '%' AND cod_param = '87084' ) THEN
						--Sí es estado fronterizo
						--Validamos si el empleado ha aceptado los términos de WU (Western Union) antes de la transacción actual.
						IF EXISTS( SELECT usuario FROM "informix".sac_registraempleadowu WHERE usuario = pEmpleado AND sucursal = pSucursal 
								   AND fecha = dFecha_hoy
								 ) THEN
							--Si ha aceptado los términos.
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 1;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;					
						ELSE
							--No ha aceptado los términos (primer pago de remesa extranjera del empleado actual)
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 0;
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;						
					ELSE
						--No es estado fronterizo
						LET cCodRet = '00000';
						LET sValor = 0;
						LET cDescripcion = 'Sucursal no fronteriza';
						LET cMsg = 0;				
						RETURN cCodRet, sValor, cDescripcion, cMsg;	
					END IF;
				--END IF;
					------------------------------------------------------------------------------------------------------------------
			ELIF pModo = '2' THEN
				--En esta modalidad se registrará al empleado en la nueva tabla bdisac:"informix".sac_registraempleadowu.
				IF NVL(pCategoria,'') = '' OR NVL(pConvenio,'') = '' THEN
					LET cCodRet = '00001';
					LET cDescripcion = 'Faltan parámetros de entrada';		
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE					
					INSERT INTO "informix".sac_registraempleadowu (numcategoria, numconvenio, usuario, sucursal, fecha, fecha_hora, status)
					VALUES (pCategoria, pConvenio, pEmpleado, pSucursal, dFecha_hoy, CURRENT, 0);
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '00003'; --NO INSERTÓ EL REGISTRO.
							LET  cDescripcion = 'No se pudo insertar el registro en la tabla bdisac:sac_registraempleadowu';
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						ELSE
							LET cCodRet = '00000';
							LET sValor = 0;
							LET cDescripcion = 'Empleado Registrado correctamente.';
							LET cMsg = 0;
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;					
				END IF;
			ELSE
				LET cCodRet = '00004';
				LET cDescripcion = 'El valor del parámetro de entrada pModo no es válido';
				RETURN cCodRet, sValor, cDescripcion, cMsg;
			END IF;
		END IF;		
	END;
END PROCEDURE;