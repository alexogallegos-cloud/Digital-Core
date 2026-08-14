CREATE PROCEDURE "informix".sp_asignacion_usuarios_autorizados(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2), pOperacion INTEGER,pNumEjecut INTEGER,pNombreEjecut CHAR(100),pFecha DATE)

		RETURNING CHAR(5) AS codret;	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_asignacion_usuarios_autorizados.out';
		--TRACE ON;
		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pOperacion IS NULL OR pNumEjecut IS NULL OR pNombreEjecut =  ''  OR pFecha IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
		END IF;
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF pBandera = '1' THEN
			EXECUTE PROCEDURE bditef:"informix".sp_cce_controlusuariosaut(pOperacion ,pNumEjecut,pNombreEjecut,pFecha)
				INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_controlusuariosaut';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00776'; --EL USUARIO CAPTURADO YA ESTÃ REGISTRADO EN EL SISTEMA.
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00716'; --NO EXISTE EL EJECUTIVO QUE DESEA ELIMINAR
			END IF;		
		END IF;
		 
		
			RETURN cCodRet;	
		END ;
END PROCEDURE
DOCUMENT
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - asignaciÃ³n de usuarios autorizados",
"FECHA : 03-03-2023",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_sw_ro_guardaparamsedocta(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pTipoOperacion int,
                        pNumCliente char(20), pNumCuenta char(20), pTipoCuenta char(2), pFechaInicio char(10), pFechaFin char(10), pIp char(15), pMacAddress char(12))
        returning char(5) as codret
        
        DEFINE iSqlErr int;
        DEFINE cCodRet char(5);
        DEFINE iRegistros int;
        DEFINE cDiaCorte char(2);
        DEFINE pFechaInicio1 date;
        DEFINE pFechaFin1 date;
		DEFINE iAnioMesApertura INTEGER;
		DEFINE iAnioMesInicio INTEGER;
		DEFINE iExiste SMALLINT;
		DEFINE cProducto CHAR(4);
        
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET iRegistros = 0;
		LET cDiaCorte = '';
        LET pFechaInicio1 ='';
        LET pFechaFin1 ='';
		LET iAnioMesApertura = 0;
		LET iAnioMesInicio = 0;
		LET iExiste = 0;
		LET cProducto = '';
        
        begin
			on exception set iSqlErr
				if iSqlErr <> 0 then
						let cCodRet = iSqlErr;
						return cCodRet;
				end if;
			end exception;
							
			--set debug file to '/tmp/mfinis/sp_sw_ro_guardaparamsedocta.out';
			--trace on;
	
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
			
			if cCodRet <> '00000' then
				return cCodRet;
			end if;
	
			if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
				pTipoOperacion = '' or pNumCliente = '' or pNumCuenta = '' or pTipoCuenta = '' or 
				pFechaInicio = '' or pFechaFin = '' or pIp = '' or pMacAddress = '' then
				
				let cCodRet = '00003';
				return cCodRet;
			end if;
			
			if pTipoOperacion not in('1', '2') then
				let cCodRet = '00005';
				return cCodRet;
			end if;
			
			if pTipoCuenta not in('01', '03', '06') then
				let cCodRet = '00048';
				return cCodRet;
			end if;
			
			-- VALIDACION DE LA FECHA DE APERTURA
			IF pTipoCuenta = '01' THEN
				LET iAnioMesInicio = (SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2))::INTEGER;
				
				SELECT TO_CHAR(fecha_alta, '%Y%m')::INTEGER
				INTO iAnioMesApertura
				FROM bdicheq:sc_maenoc
				WHERE cuenta = pNumCuenta;
				
				IF iAnioMesInicio < iAnioMesApertura THEN
					--LET cCodRet = '00246'; -- LA FECHA DE INICIO DEL PERIODO DE CONSULTA NO PUEDE SER MENOR A LA FECHA DE APERTURA DE LA CUENTA
					--RETURN cCodRet;
				END IF;
			
			ELIF pTipoCuenta = '06' THEN -- CUENTAS DE CREDITO
				LET iAnioMesInicio = (SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2))::INTEGER;
				
				SELECT producto
				INTO cProducto
				FROM sw_ro_ctecta
				WHERE cuenta = pNumCuenta
					AND numcte = pNumCliente
					AND id_oficio = pIdOficio
					AND id_busqueda = pIdBusqueda
					AND id_resulcte = pIdCliente;
					
				IF cProducto = '6001' THEN -- TARJETA DE CREDITO
					SELECT TO_CHAR(fecha_apertura, '%Y%m')::INTEGER
					INTO iAnioMesApertura
					FROM bdicred:sd_maecred
					WHERE num_credito = pNumCuenta and numcte = pNumCliente;
					
					IF iAnioMesInicio < iAnioMesApertura THEN
						--LET cCodRet = '00246'; -- LA FECHA DE INICIO DEL PERIODO DE CONSULTA NO PUEDE SER MENOR A LA FECHA DE APERTURA DE LA CUENTA
						--RETURN cCodRet;
					END IF;
				ELSE
					SELECT TO_CHAR(fecha_apertura, '%Y%m')::INTEGER
					INTO iAnioMesApertura
					FROM bdicred:sd_maecredcrd
					WHERE num_credito = pNumCuenta and numcte = pNumCliente;
					
					IF iAnioMesInicio < iAnioMesApertura THEN
						--LET cCodRet = '00246'; -- LA FECHA DE INICIO DEL PERIODO DE CONSULTA NO PUEDE SER MENOR A LA FECHA DE APERTURA DE LA CUENTA
						--RETURN cCodRet;
					END IF;
				END IF;
				
			END IF;
			
			
			IF pTipoCuenta IN ('03', '06') THEN
			-- Se obtiene el dÃÂ­a de corte de la cuenta
				select 
					case when 
						length(cast(dia_corte as char(2))) = 1 
							then '0' || cast(dia_corte as char(2))
							else cast(dia_corte as char(2))
					end as diaCorte
				into cDiaCorte
				from sw_ro_ctecta
				where id_oficio = pIdOficio
					and id_busqueda = pIdBusqueda
					and id_resulcte = pIdCliente
					and cuenta = pNumCuenta
					and numcte = pNumCliente;
					
				IF pTipoCuenta = '06' THEN

					SELECT producto
					INTO cProducto
					FROM sw_ro_ctecta
					WHERE cuenta = pNumCuenta
						AND numcte = pNumCliente
						AND id_oficio = pIdOficio
						AND id_busqueda = pIdBusqueda
						AND id_resulcte = pIdCliente;
					
					IF cProducto = '6001' THEN -- TARJETA DE CREDITO
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edocta
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
						
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de inicio
							--LET cCodRet = '00247'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE INICIO DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edocta
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaFin,1,4)||SUBSTR(pFechaFin,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
							
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de fin
							--LET cCodRet = '00248'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE FIN DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
					ELSE -- OTROS PRODUCTOS DE CREDITO
						
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edoctacrd
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
						
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de inicio
							--LET cCodRet = '00247'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE INICIO DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edoctacrd
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaFin,1,4)||SUBSTR(pFechaFin,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
							
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de fin
							--LET cCodRet = '00248'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE FIN DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
					END IF;
				
				END IF;
			ELIF pTipoCuenta = '01' THEN
			
				/*SELECT COUNT(aniomes)
				INTO iExiste
				FROM bdicheq:sc_maehis_factelect
				WHERE aniomes = SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2)
					and cuenta = pNumCuenta;*/
				
				/*IF iExiste = 0 THEN
					-- No existe informaciÃÂ³n con la fecha de inicio
					--LET cCodRet = '00247'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE INICIO DEL PERIODO DE CONSULTA
					RETURN cCodRet;
				END IF;*/
					
				/*SELECT COUNT(aniomes)
				INTO iExiste
				FROM bdicheq:sc_maehis_factelect
				WHERE aniomes = SUBSTR(pFechaFin,1,4)||SUBSTR(pFechaFin,6,2)
					and cuenta = pNumCuenta;*/
					
				/*IF iExiste = 0 THEN
					-- No existe informaciÃÂ³n con la fecha de fin
					--LET cCodRet = '00248'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE FIN DEL PERIODO DE CONSULTA
					RETURN cCodRet;
				END IF;*/
				
				LET cDiaCorte = '01';

			END IF;
			
			let pFechaInicio = substr(pFechaInicio, 1, 8)||cDiaCorte;
			let pFechaFin = substr(pFechaFin, 1, 8)||cDiaCorte;
			
			let pFechaInicio1 = EXTEND(MDY(SUBSTR(pFechaInicio,6,2),SUBSTR(pFechaInicio,9,2),SUBSTR(pFechaInicio,1,4)), YEAR TO SECOND);
			let pFechaFin = SUBSTR(pFechaFin,6,2)||'-'||SUBSTR(pFechaFin,9,2)||'-'||SUBSTR(pFechaFin,1,4);
			EXECUTE PROCEDURE sp_sw_ro_evalua_fecha(pFechaFin) INTO pFechaFin1;
			
			if pTipoOperacion = 1 then -- InserciÃÂ³n de datos
					insert into sw_ro_edocta(id_resulcte, id_busqueda, id_oficio, numcte, cuenta, tipo_cuenta, fecha_inicio, fecha_fin, user_insert, ip_insert, mac_insert)
					values(pIdCliente, pIdBusqueda, pIdOficio, pNumCliente, pNumCuenta, pTipoCuenta, pFechaInicio1, pfechafin1, pUsuario, pIp, pMacAddress);
			elif pTipoOperacion = 2 then -- ActializaciÃÂ³n de datos
					update sw_ro_edocta
					set fecha_inicio = pFechaInicio1,
							fecha_fin = pFechaFin1
					where id_busqueda = pIdBusqueda
							and id_oficio = pIdOficio
							and id_resulcte = pIdCliente
							and numcte = pNumCliente
							and cuenta = pNumCuenta
							and tipo_cuenta = pTipoCuenta
							and user_insert = pUsuario
							and ip_insert = pIp
							and mac_insert = pMacAddress;
			end if;
			
			-- ActualizaciÃÂ³n de las banderas de estatus
			-- En la cuenta
			update sw_ro_ctecta
			set certifica_edocuenta = '1'
			where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente and cuenta = pNumCuenta;
			
			update sw_ro_resulcte
			set certifica_edocuenta = '1'
			where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente;
			
			update sw_ro_maeoficios
			set certifica_edocuenta = '1'
			where id_oficio = pIdOficio;

			return cCodRet;
        end;
end procedure;