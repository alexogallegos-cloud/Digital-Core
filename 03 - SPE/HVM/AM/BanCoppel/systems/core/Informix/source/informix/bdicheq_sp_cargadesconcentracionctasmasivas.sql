CREATE PROCEDURE "informix".sp_cargadesconcentracionctasmasivas(pUsuario CHAR(8), pIdFuncion CHAR(10), pBloqueInf CHAR(2500), pIteracion CHAR(1))
	RETURNING CHAR(5) AS codret; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE cRegistro LVARCHAR;
	DEFINE cBloqueInf2 LVARCHAR;
	DEFINE iContador INTEGER;
	DEFINE dFecha CHAR(10);
	DEFINE cFolio_csuac CHAR(10);
	DEFINE cNomAsignado_a CHAR(45);
	DEFINE cProducto CHAR(50);
	DEFINE cOrigen CHAR(50);
	DEFINE cEvento CHAR(50);
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNum_cuenta CHAR(20);
	DEFINE cEstatus_corp CHAR(20);
	DEFINE cEstatus_analisis CHAR(20);
	DEFINE cNum_tarjeta CHAR(20);
	DEFINE cVencimiento_en CHAR(20);
	DEFINE cId_semaforo CHAR(20);
	DEFINE dFecha_insert DATE;
	DEFINE iExiste INTEGER;
	DEFINE iIdx INTEGER;
	DEFINE iCont INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cEmpresa = '001';
	LET cRegistro = '';
	LET cBloqueInf2 = '';
	LET iContador = 0;
	LET dFecha = '';
	LET cFolio_csuac = '';
	LET cNomAsignado_a = '';
	LET cProducto = '';
	LET cOrigen = '';
	LET cEvento = '';
	LET cNum_cliente = '';
	LET cNum_cuenta = '';
	LET cEstatus_corp = '';
	LET cEstatus_analisis = '';
	LET cNum_tarjeta = '';
	LET cVencimiento_en = '';
	LET cId_semaforo = '';
	LET dFecha_insert = '';
	LET iExiste = 0;
	LET iIdx = 0;
	LET iCont = 0;
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				RETURN cCodRet; 
			END IF;
		END EXCEPTION;
		
		---SET DEBUG FILE TO '/tmp/mfinis/sp_cargadesconcentracionctasmasivas.out';
		--SET DEBUG FILE TO '/informix/rsv/ART61/TASF/bdichq/sp_cargadesconcentracionctasmasivas.out';
		--TRACE ON;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBloqueInf = '' OR pIteracion = '' THEN
			LET cCodRet = '00003';			
			RETURN cCodRet; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA DE PASO
		IF pIteracion = '0' THEN
			
			FOREACH WITH HOLD
				
				SELECT id_registro INTO iIdx 
				FROM "informix".sw_det_desconcentracionmasiva 
				WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
				
				DELETE FROM "informix".sw_det_desconcentracionmasiva WHERE usuario_insert = pUsuario AND id_registro = iIdx;

				LET iCont = iCont + 1;

				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
		END IF;
		
		FOREACH
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pBloqueInf, '|')
			INTO cBloqueInf2
			
			LET cBloqueInf2 = TRIM(cBloqueInf2)||'+';
			LET cRegistro = '';
			LET iContador = 0;
			
			FOREACH
			
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(cBloqueInf2, '+')
				INTO cRegistro
			
				LET iContador = iContador + 1;
				
				IF iContador = 1 THEN
					LET dFecha = TRIM(cRegistro);
				ELIF iContador = 2 THEN
					LET cFolio_csuac = TRIM(cRegistro);
				ELIF iContador = 3 THEN
					LET cNomAsignado_a = TRIM(cRegistro);
				ELIF iContador = 4 THEN
					LET cProducto = TRIM(cRegistro);
				ELIF iContador = 5 THEN
					LET cOrigen = TRIM(cRegistro);
				ELIF iContador = 6 THEN
					LET cEvento = TRIM(cRegistro);
				ELIF iContador = 7 THEN
					LET cNum_cliente = TRIM(cRegistro);
				ELIF iContador = 8 THEN
					LET cNum_cuenta = TRIM(cRegistro);
				ELIF iContador = 9 THEN
					LET cEstatus_corp = TRIM(cRegistro);
				ELIF iContador = 10 THEN
					LET cEstatus_analisis = TRIM(cRegistro);
				ELIF iContador = 11 THEN
					LET cNum_tarjeta = TRIM(cRegistro);
				ELIF iContador = 12 THEN
					LET cVencimiento_en = TRIM(cRegistro);
				ELIF iContador = 13 THEN
					LET cId_semaforo = TRIM(cRegistro);
				END IF;
			
			END FOREACH;

			INSERT INTO "informix".sw_det_desconcentracionmasiva(fecha,folio_csuac,asignado_a,producto,origen,evento,num_cliente,num_cuenta,estatus_corp,estatus_analisis,num_tarjeta,vencimiento_en,id_semaforo,importe_conc,importe_desc,resultado,estatus,fechahr_insert,usuario_insert) 
			VALUES(dFecha,cFolio_csuac,cNomAsignado_a,cProducto,cOrigen,cEvento,cNum_cliente,cNum_cuenta,cEstatus_corp,REPLACE(cEstatus_analisis,'-',''),cNum_tarjeta,cVencimiento_en,cId_semaforo,0.00,0.00,'','',CURRENT,pUsuario);			
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;
			
		END FOREACH;
		
		-- VALIDA REGISTROS DUPLICADOS
		SELECT COUNT(DISTINCT(num_cuenta))
		INTO iExiste
		FROM "informix".sw_det_desconcentracionmasiva
		WHERE usuario_insert = pUsuario
		AND num_cuenta IN(SELECT num_cuenta
						  FROM "informix".sw_det_desconcentracionmasiva
						  WHERE usuario_insert = pUsuario
						  GROUP BY 1
						  HAVING COUNT(*) > 1);
		
		IF NVL(iExiste,0) > 0 THEN
			LET cCodRet = '01117'; --EL ARCHIVO SELECCIONADO PRESENTA CUENTAS DUPLICADAS
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 15/01/2019',
'MODULO: TRANSACCIONES',
'FUNCIONALIDAD: DESCONCENTRACIÓN DE CUENTAS CARGA MASIVA',
'DESCRIPCION: SPL encargado de hacer la carga del contenido del archivo a la tabla de paso y validar si existen cuentas duplicadas.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_procsdesconcentracionctasmasivas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(50);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE dFecha CHAR(10);
	DEFINE cFolio_csuac CHAR(10);
	DEFINE cNomAsignado_a CHAR(45);
	DEFINE cProducto CHAR(50);
	DEFINE cOrigen CHAR(50);
	DEFINE cEvento CHAR(50);
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNum_cuenta CHAR(20);
	DEFINE cEstatus_corp CHAR(20);
	DEFINE cEstatus_analisis CHAR(20);
	DEFINE cNum_tarjeta CHAR(20);
	DEFINE cVencimiento_en CHAR(20);
	DEFINE cId_semaforo CHAR(20);
	DEFINE dImporte_conc DECIMAL(14,2);
	DEFINE dImporte_desc DECIMAL(14,2);
	DEFINE cResultado CHAR(15);
	DEFINE cEstatus CHAR(15);
	DEFINE dFecha_insert DATE;
	DEFINE cIdEstatus CHAR(1);
	DEFINE cMotivo CHAR(2);
	DEFINE iEntrada INTEGER;
	DEFINE iCont INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET bInTransaction = 'f';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET dFecha = '';
	LET cFolio_csuac = '';
	LET cNomAsignado_a = '';
	LET cProducto = '';
	LET cOrigen = '';
	LET cEvento = '';
	LET cNum_cliente = '';
	LET cNum_cuenta = '';
	LET cEstatus_corp = '';
	LET cEstatus_analisis = '';
	LET cNum_tarjeta = '';
	LET cVencimiento_en = '';
	LET cId_semaforo = '';
	LET dImporte_conc = 0.00;
	LET dImporte_desc = 0.00;
	LET cResultado = '';
	LET cEstatus = '';
	LET dFecha_insert = '';
	LET cIdEstatus = '';
	LET cMotivo = '';
	LET iEntrada = 0;
	LET iCont = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_procsdesconcentracionctasmasivas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE INICIALIZA TABLA PARA CARGAR NUEVA INFORMACIÃN
		--BEGIN;
			TRUNCATE TABLE "informix".sc_detalle_ctasdesconcetradas;
		--COMMIT;
		
		BEGIN WORK;
		FOREACH WITH HOLD
			
			SELECT id_registro,fecha,folio_csuac,asignado_a,producto,origen,evento,num_cliente,num_cuenta,estatus_corp,estatus_analisis,num_tarjeta,vencimiento_en,id_semaforo
			INTO iIdRegistro,dFecha,cFolio_csuac,cNomAsignado_a,cProducto,cOrigen,cEvento,cNum_cliente,cNum_cuenta,cEstatus_corp,cEstatus_analisis,cNum_tarjeta,cVencimiento_en,cId_semaforo
			FROM "informix".sw_det_desconcentracionmasiva
			WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
			
			LET iEntrada = iEntrada + 1;
			LET iCont = iCont + 1;
			
			INSERT INTO "informix".sc_detalle_ctasdesconcetradas(fecha,folio,asignado,producto,origen,evento,num_cte,cuenta,estatus_corp,estatus_anali,num_tarjeta,vencimiento,indicador,importe_conc,importe_desc,resultado,estatus,fecha_proceso)
			VALUES(TO_DATE((dFecha),'%d/%m/%Y'),cFolio_csuac,cNomAsignado_a,cProducto,cOrigen,cEvento,cNum_cliente,cNum_cuenta,cEstatus_corp,cEstatus_analisis,cNum_tarjeta,cVencimiento_en,cId_semaforo,0.00,0.00,'','',CURRENT);
					
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				ROLLBACK WORK;
				LET cCodRet = '01118'; --OCURRIÃ UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO. INTENTE NUEVAMENTE
				RETURN cCodRet;
			ELSE 
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END IF;
			COMMIT WORK;
			
			EXECUTE PROCEDURE "informix".sp_blqdesconcentractasinactivas(cEmpresa, cNum_cuenta) 
			INTO cCodRetSp, cDescCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_blqdesconcentractasinactivas';
			--RESULTADO
			ELIF iCodRetSp > 0 THEN
				--LET cCodRet = '01118'; --OCURRIÃ UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO. INTENTE NUEVAMENTE
				--RETURN cCodRet;
				LET cResultado = 'NO EXITOSO';
				
				LET dImporte_conc = 0.00;
				LET dImporte_desc = 0.00;
			ELIF iCodRetSp = 0 THEN
				LET cResultado = 'EXITOSO';			
				
				--IMPORTE CONCENTRADO
				FOREACH
					SELECT FIRST 1 sdo_concentrado INTO dImporte_conc
					FROM "informix".sc_cuentas_concentradas
					WHERE cuenta = cNum_cuenta ORDER BY fecha_concentra DESC
				END FOREACH;
				
				--IMPORTE DESCONCENTRADO
				FOREACH
					SELECT FIRST 1 pago_sdo_concentra INTO dImporte_desc
					FROM "informix".sc_cuentas_concentradas
					WHERE cuenta = cNum_cuenta ORDER BY fecha_pago_concentra DESC
				END FOREACH;
			END IF;
			
			--ESTATUS
			SELECT status_cta, motivo INTO cIdEstatus, cMotivo 
			FROM "informix".sc_maechq 
			WHERE cuenta = cNum_cuenta;
			
			IF cIdEstatus = '1' THEN
				LET cEstatus = 'ACTIVA';
			ELIF cIdEstatus = '2' THEN
				IF cMotivo = '14' THEN
					LET cEstatus = 'BENEFICENCIA';
				ELSE
					LET cEstatus = 'CANCELADA';
				END IF;
			ELIF cIdEstatus = '3' THEN
				LET cEstatus = 'BLOQUEADA';
			ELIF cIdEstatus = '4' THEN
				LET cEstatus = 'INACTIVA';
			ELIF cIdEstatus = '5' THEN
				LET cEstatus = 'INFORMADA';
			ELIF cIdEstatus = '6' THEN
				LET cEstatus = 'CONCENTRADA';
			--ELIF cIdEstatus = '7' THEN
			--	LET cEstatus = 'BENEFICENCIA';
			ELIF cIdEstatus = '8' THEN
				LET cEstatus = 'DESCONCENTRADA';
			END IF;
			
			UPDATE "informix".sc_detalle_ctasdesconcetradas 
			SET importe_conc = dImporte_conc, importe_desc = dImporte_desc, resultado = cResultado, estatus = cEstatus
			WHERE cuenta = cNum_cuenta;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '01118'; --OCURRIÃ UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO. INTENTE NUEVAMENTE
				RETURN cCodRet;
			ELSE
				UPDATE "informix".sw_det_desconcentracionmasiva 
				SET importe_conc = dImporte_conc, importe_desc = dImporte_desc, resultado = cResultado, estatus = cEstatus
				WHERE id_registro = iIdRegistro AND num_cuenta = cNum_cuenta AND usuario_insert = pUsuario;
				
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '01118'; --OCURRIÃ UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO. INTENTE NUEVAMENTE
						RETURN cCodRet;
					END IF;
			END IF;
			
			LET dImporte_conc = 0.00;
			LET dImporte_desc = 0.00;
			LET cResultado = '';
			LET cEstatus = '';
			
			BEGIN WORK;
			
		END FOREACH;
		
		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;
		
		IF (iEntrada = 0 OR iCont = 0) AND bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 15/01/2019',
'MODULO: TRANSACCIONES',
'FUNCIONALIDAD: DESCONCENTRACIÃN DE CUENTAS CARGA MASIVA',
'DESCRIPCION: SPL encargado de procesar la informaciÃ³n correspondiente a las cuentas de desconcentraciÃ³n cargadas en la tabla de paso a la tabla sc_detalle_ctasdesconcetradas.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/02/2019',
'DESCRIPCION: Se modifica SPL para tratado de transacciones.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/03/2019',
'DESCRIPCION: Se modifica SPL para validar el envio del importe concentrado y desconcentrado.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_dskrgactasinform3anios3meses( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    
    DEFINE vFechaHoy        DATE;
    DEFINE vDiasConcentrada INTEGER;
    DEFINE vCuenta          CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vSdoActual       DECIMAL(18,2);
    DEFINE vFechaUltimoDep  DATE;
    DEFINE vFechaUltimoRet  DATE;
    DEFINE vFechaAlta       DATE;
    DEFINE vFechaCompara    DATE;
    DEFINE vDiasSinTransacc INTEGER;    
    DEFINE vNomProducto     CHAR(40);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vNumTarjeta      CHAR(16);
    DEFINE vNombreCliente   CHAR(104);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(8);
    DEFINE vDireccion       CHAR(200);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    
    LET vFechaHoy        = '';
    LET vDiasConcentrada = 0;
    LET vCuenta          = '';   
    LET vStatusCta       = '';
    LET vSdoActual       = 0.00;
    LET vFechaUltimoDep  = '';
    LET vFechaUltimoRet  = '';
    LET vFechaAlta       = '';
    LET vFechaCompara    = '';
    LET vDiasSinTransacc = 0;
    LET vNomProducto     = '';
    LET vNumCliente      = '';
    LET vNumTarjeta      = '';
    LET vNombreCliente   = '';
    LET vsql             = '';
    LET vstmt            = '';
    LET vfecha           = '';
    LET vDireccion       = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrgactasinform3anios3meses.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrgactasinform3anios3meses.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NUMERO DE DIAS PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasConcentrada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaConcentrad';
     
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.sdo_actual, mae.fecultdep, mae.fecultret, noc.fecha_alta, mae.producto||' '||TRIM(NVL(pro.nombre,' ')),
               NVL(tar.num_tarjeta, ' '), TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)
          INTO vCuenta, vNumCliente, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta, vNomProducto, vNumTarjeta, vNombreCliente
          FROM bdicheq:"informix".sc_maechq mae
         INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
         INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
         INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
         LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND 
                                                                 tar.cuenta = mae.cuenta AND 
                                                                 tar.tipo_tarjeta = 'T' AND
                                                                 tar.status_tar = 'A' AND 
                                                                 tar.secuencia = ( SELECT MAX(secuencia)
                                                                                     FROM bdicheq:"informix".sc_tarjeta
                                                                                    WHERE empresa = pEmpresa
                                                                                      AND cuenta = mae.cuenta
                                                                                      AND tipo_tarjeta = 'T'
                                                                                      AND status_tar = 'A' ) )
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta is not null
           AND mae.status_cta = '5'
		   AND mae.producto <> '1100'
           AND mae.sdo_actual > 0.00
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;    
        
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        -- // OBTIENE FECHA DE ULTIMO DEPOSITO
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA DE ULTIMO RETIRO
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA MAS RECIENTE SIN TRANSACCIONAR
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaCompara = vFechaUltimoRet;
        ELSE
            LET vFechaCompara = vFechaUltimoDep;
        END IF;
        
        LET vDiasSinTransacc = vFechaHoy - vFechaCompara;
        
        IF ( vDiasSinTransacc > vDiasConcentrada ) THEN    --------RSV SE MODIFICA ANTERIORMENTE FUE >= AHORA NECESITAMOS QUE AL DIA 1097 CAMBIE EL ESTATUS 
            SELECT TRIM(NVL(calle.nombrecalle,  ' ')) ||' '|| 
                   TRIM(NVL(dir.numeroextcalle, ' ')) ||' '|| 
                   TRIM(NVL(dir.numerointcalle, ' ')) ||' '|| 
                   TRIM(NVL(dir.departamento,   ' ')) ||' '||
                   TRIM(NVL(zona.nombrezona,    ' ')) ||' '||
                   TRIM(NVL(zona.municipiozona, ' ')) ||' '||
                   TRIM(NVL(ciu.nombreciudad,   ' ')) ||' '||
                   TRIM(NVL(ciu.inicialestado,  ' ')) ||' '||
                   TRIM(NVL(dir.cod_postal,     ' '))     
              INTO vDireccion
              FROM bdinteg:si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
              LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
              LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
             WHERE dir.numcte = vNumCliente
               AND dir.tipo_dir = '1';
               
            IF vDireccion is null OR vDireccion = '' THEN
                SELECT TRIM(calle.nombrecalle)  ||' '|| 
                       TRIM(dir.numeroextcalle) ||' '|| 
                       TRIM(dir.numerointcalle) ||' '|| 
                       TRIM(dir.departamento)   ||' '||
                       TRIM(zona.nombrezona)    ||' '||
                       TRIM(zona.municipiozona) ||' '||
                       TRIM(ciu.nombreciudad)   ||' '||
                       TRIM(ciu.inicialestado)  ||' '||
                       TRIM(dir.cod_postal)     
                  INTO vDireccion
                  FROM bdinteg:si_direcciones_actual dir
                  LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                  LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                  LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                 WHERE dir.numcte = vNumCliente
                   AND dir.tipo_dir = '2';
                   
                IF vDireccion is null OR vDireccion = '' THEN
                    SELECT TRIM(calle.nombrecalle)  ||' '|| 
                           TRIM(dir.numeroextcalle) ||' '|| 
                           TRIM(dir.numerointcalle) ||' '|| 
                           TRIM(dir.departamento)   ||' '||
                           TRIM(zona.nombrezona)    ||' '||
                           TRIM(zona.municipiozona) ||' '||
                           TRIM(ciu.nombreciudad)   ||' '||
                           TRIM(ciu.inicialestado)  ||' '||
                           TRIM(dir.cod_postal)     
                      INTO vDireccion
                      FROM bdinteg:si_direcciones_actual dir
                      LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                      LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                      LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                     WHERE dir.numcte = vNumCliente
                       AND dir.tipo_dir = '3';
                    
                    IF vDireccion is null OR vDireccion = '' THEN
                        LET vDireccion = 'DIRECCION NO ENCONTRADA';
                    END IF;
                END IF;
            END IF;
             
            INSERT INTO sc_ctasinactinfor3anios3meses 
            ( num_cte, cliente, producto, cuenta, status_cta, sdo_actual, num_tarjeta, fech_ult_dep, fech_ult_ret, fech_inactividad, domicilio, fecha_rep )
            VALUES
            ( vNumCliente, vNombreCliente, vNomProducto, vCuenta, vStatusCta, vSdoActual, vNumTarjeta, vFechaUltimoDep, vFechaUltimoRet, vFechaCompara, vDireccion, vFechaHoy );
            
            LET vContador2 = vContador2 + 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
    END FOREACH;
	
	--RSV YA NO TIENE QUE DESCARGAR EL ARCHIVO  NUEVA FUNCIONALIDAD 
 /*
    LET vfecha = TO_CHAR(vFechaHoy, '%d%m%Y');
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/CtasInactivas3anios3meses_'||vfecha||'.txt '||
               'SELECT producto, num_cte, num_tarjeta, cuenta, cliente, sdo_actual, to_char(fech_ult_dep,'''||'%d/%m/%Y'||'''), to_char(fech_ult_ret,'''||'%d/%m/%Y'||'''), status_cta '||
               'FROM sc_ctasinactinfor3anios3meses WHERE fecha_rep = '''||vFechaHoy||''' " > /resplogifx/conciliachq/ctasinact33.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasinact33.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
 */
    END; 
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
    
END PROCEDURE;