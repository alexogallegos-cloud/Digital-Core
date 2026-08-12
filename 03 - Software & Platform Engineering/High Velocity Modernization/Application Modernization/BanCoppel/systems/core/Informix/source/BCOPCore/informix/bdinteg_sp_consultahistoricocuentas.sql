CREATE PROCEDURE "informix".sp_consultahistoricocuentas( psNumCuenta CHAR(12), psNumTarjeta CHAR(16), piTipoBusqueda SMALLINT, psEmpresa CHAR(3) )
	RETURNING 
		CHAR(5) AS CodigoRetorno, 
		CHAR(25) AS Estatus, CHAR(10) AS FechaStatus, CHAR(10) AS HoraStatus, CHAR(4) AS Sucursal, CHAR(8) AS Empleado, CHAR(100) AS NombreEmpleado;
	
	--Declaración de variables.
	DEFINE sCodigoRetorno 	CHAR(5);	-- Código de retorno.
	DEFINE sSqlErr			INTEGER;	-- Código de error controlado por INFORMIX.	
	DEFINE iCont			INTEGER;
	
	--Datos generales de la cuenta.
	DEFINE sProducto			CHAR(25);	-- Nombre del producto al cual pertenece la cuenta.
	DEFINE sFechaStatusUltMod	CHAR(10);	-- Fecha de la última modificación de la cuenta.
	DEFINE sHoraStatusUltMod  	CHAR(10); 	-- Hora de la última modificación de la cuenta.
	DEFINE sEmpleadoModifico	CHAR(8);	-- Empleado que realizó la última modificación.
	DEFINE sNombreEmpMod 		CHAR(100);	-- Nombre del empleado que realizó la última modificación.
		
	--Datos de la apertura de la cuenta.
	DEFINE sFechaStatusAperturaCuenta	CHAR(10); 	-- Fecha de la apertura de la cuenta.
	DEFINE sHoraStatusAperturaCuenta	CHAR(10); 	-- Hora de la apertura de la cuenta.
	DEFINE sSucursalAperturaCuenta 		CHAR(4);  	-- Número de la sucursal donde se realizó la apertura.
	DEFINE sEmpleadoAperturo 			CHAR(8);  	-- Empleado que realizó la apertura.
	DEFINE sNombreEmpAperturo 			CHAR(100);	-- Nombre del empleado que realizó la apertura.
		
	--Datos histórico de la cuenta.
	DEFINE sEstatusHistorico 		CHAR(25);	-- Estatus de histórico de la cuenta.
	DEFINE sFechaEstatusHistorico 	CHAR(10);	-- Fecha del estatus de histórico de la cuenta.
	DEFINE sHoraStatusHistorico 	CHAR(10);	-- Hora del estatus de histórico de la cuenta
	DEFINE sEmpleadoHistorico 		CHAR(8);	-- Empleado histórico de la cuenta.
	DEFINE sNombreEmpleadoHistorico	CHAR(100);	-- Nombre de empleado de histórico de la cuenta.
		
	DEFINE sNumTarjeta		CHAR(16);
	DEFINE sNumCuenta		CHAR(12);
    DEFINE sCuentaPagare    CHAR(12);    
    DEFINE sCuentaInversion CHAR(12);
	
	DEFINE vDia INTEGER;
	DEFINE vMes INTEGER;
	DEFINE vAnio INTEGER;
	DEFINE  vfechamttoaux DATE;
	
	LET vDia = 0;
	LET vMes = 0;
	LET vAnio = 0;
	LET vfechamttoaux = MDY( 1,1,1900);
	-- Asignación de valores por defecto a variables.
	LET sCodigoRetorno = '00000';
	LET sSqlErr = 0;
	LET iCont = 0;	
	
	LET sFechaStatusUltMod = '';
	LET sHoraStatusUltMod = '';	
	LET sEmpleadoModifico = '';
	LET sNombreEmpMod = '';
	
	LET sFechaStatusAperturaCuenta = '';
	LET sHoraStatusAperturaCuenta = '';
	LET sSucursalAperturaCuenta = '';
	LET sEmpleadoAperturo = '';
	LET sNombreEmpAperturo = '';
	
	LET sEstatusHistorico = '';
	LET sFechaEstatusHistorico = '';
	LET sHoraStatusHistorico = '';
	LET sEmpleadoHistorico = '';
	LET sNombreEmpleadoHistorico = '';
    
	LET sNumTarjeta = '';
	LET sNumCuenta = '';		
    LET sCuentaPagare = '';
    LET sCuentaInversion = '';	
	
	---SET DEBUG FILE TO "/informix/SIA/sp_consultahistoricocuentas.out";
	---TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET sSqlErr
		
	      IF sSqlErr <> 0 THEN

	            LET sCodigoRetorno = sSqlErr;
				
	            RETURN sCodigoRetorno, 
					NULL, NULL, NULL, NULL, NULL, NULL;
				
	      END IF;
		
		END EXCEPTION;
	
		SET ISOLATION DIRTY READ;
		
		IF ( NVL( psNumCuenta, '' ) <> '' AND 
			( NVL( piTipoBusqueda, 0 ) > 0 AND NVL( piTipoBusqueda, 0 ) < 10 ) AND 
			NVL( psEmpresa, '' ) <> '' ) THEN

			-- Datos generales para la cuenta de crédito.
			IF ( piTipoBusqueda = 1 ) THEN
			
				SELECT a.numtarjeta, TO_CHAR( a.fechaultmodif, '%d/%m/%Y' ), SUBSTR( a.fechaultmodif, 12, 8 ), a.usuarioultmodif, e.nombre_prod
					INTO sNumTarjeta, sFechaStatusUltMod, sHoraStatusUltMod, sEmpleadoModifico, sProducto
				FROM intercard:tarjeta a
					LEFT OUTER JOIN intercard:tarjetacuenta b ON ( a.numtarjeta = b.numtarjeta )
					LEFT OUTER JOIN bdicred:sd_maecred c ON ( c.num_credito = b.numcuenta )
					JOIN bdicred:sd_definicion e ON ( e.num_producto = c.num_producto )
				WHERE c.num_credito = psNumCuenta
					AND b.numtarjeta = psNumTarjeta;
					
				SELECT ejecutivo, UPPER( nombre )
					INTO sEmpleadoModifico, sNombreEmpMod
				FROM bdinteg:si_ejecut
				WHERE ejecutivo = sEmpleadoModifico;
				
				IF ( NVL( sNumTarjeta, '' ) = '' OR NVL( sEmpleadoModifico, '' ) = '' OR NVL( sNombreEmpMod, '' ) = '' ) THEN

					LET sCodigoRetorno = '00001'; -- Error al tratar de obtener los datos generales de la cuenta de crédito.

				END IF;
				
				RETURN sCodigoRetorno, 
					sProducto, sFechaStatusUltMod, sHoraStatusUltMod, NULL, sEmpleadoModifico, sNombreEmpMod;
			
			-- Histórico de la cuenta de crédito, apertura de cuenta.
			ELIF ( piTipoBusqueda = 8 ) THEN
				
				SELECT a.num_credito, TO_CHAR( a.fecha_apertura, '%d/%m/%Y' ), a.sucursal, b.ejecutivo_auto
					INTO sNumCuenta, sFechaStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo
				FROM bdicred:sd_maecred a
					LEFT OUTER JOIN bdisolic:ss_autorizacion b ON ( a.num_credito = b.num_solicitud AND a.empresa = b.empresa )
				WHERE b.empresa = psEmpresa AND b.num_solicitud = psNumCuenta
					AND b.status_solicitud = 'AP';
				
				-- Se obtiene nombre de ejecutivo.
				SELECT ejecutivo, UPPER( nombre )
					INTO sEmpleadoAperturo, sNombreEmpAperturo
				FROM bdinteg:si_ejecut
				WHERE ejecutivo = sEmpleadoAperturo;
				
				IF ( NVL( sNumCuenta, '' ) <> '' AND NVL( sEmpleadoAperturo, '' ) <> '' ) THEN 
				
					SELECT num_credito, hora_mov::DATETIME HOUR TO SECOND
						INTO sNumCuenta, sHoraStatusAperturaCuenta
					FROM bdicred:sd_movhis
					WHERE empresa = psEmpresa AND num_credito = psNumCuenta AND codigo_fun = '001' AND codigo_ref = 1 AND reversado = 'N';
					
					IF ( sNumCuenta IS NULL ) THEN
					
						SELECT num_credito, hora_mov::DATETIME HOUR TO SECOND
							INTO sNumCuenta, sHoraStatusAperturaCuenta
						FROM bdicred:sd_movdia
						WHERE num_credito = psNumCuenta AND codigo_fun = '001' AND codigo_ref = 1 AND reversado = 'N';
					
					END IF;
										
				END IF;
				
				IF ( sNumCuenta IS NULL ) THEN 
						
					LET sCodigoRetorno = '00002'; -- Error al tratar de obtener los datos de Cuenta Crédito.
						
				END IF;
				
				RETURN sCodigoRetorno, 
					NULL, sFechaStatusAperturaCuenta, sHoraStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo, sNombreEmpAperturo;
			
			--Histórico de las cuentas de crédito, Cancelación de crédito.
			ELIF ( piTipoBusqueda = 9 ) THEN
				
				SELECT a.num_credito, a.status_cred, TO_CHAR( b.fecha_ult_mov, '%d/%m/%Y' )
					INTO sNumCuenta, sEstatusHistorico, sFechaEstatusHistorico
				FROM bdicred:sd_maecred a 
					LEFT OUTER JOIN bdicred:sd_maesdos b ON ( b.num_credito = a.num_credito )
					LEFT OUTER JOIN bdicred:sd_tipocartera c ON ( c.status_cred = a.status_cred AND c.empresa = psEmpresa )
				WHERE b.empresa = psEmpresa AND b.num_credito = psNumCuenta
					AND c.status_cred IN ( 'FF', 'FC', 'CV', 'CE' );
					
				IF ( NVL( sNumCuenta, '' ) = '' ) THEN 
				
					LET sCodigoRetorno = '00009'; -- No tiene cancelación.
					
				END IF;
				
				RETURN sCodigoRetorno, 
					sEstatusHistorico, sFechaEstatusHistorico, NULL, NULL, NULL, NULL;			

			-- Datos generales para la cuentas de débito.
			ELIF ( piTipoBusqueda = 2 ) THEN
			
				LET psNumCuenta = TRIM( psNumCuenta );
			
				-- Se busca la cuenta en el maestro de cheques.
				SELECT a.cuenta, c.nombre
					INTO sNumCuenta, sProducto
				FROM bdicheq:sc_maechq a
					JOIN bdicheq:sc_maenoc b ON ( a.cuenta = b.cuenta )
					JOIN bdicheq:sc_producto c ON ( a.producto = c.producto )				
				WHERE a.cuenta = psNumCuenta;
								
				IF ( NVL( sNumCuenta , '' ) <> '' ) THEN				

					SELECT a.numtarjeta, TO_CHAR( a.fechaultmodif, '%d/%m/%Y' ), a.fechaultmodif::DATETIME HOUR TO SECOND, NVL( a.usuarioultmodif, '' )
						INTO sNumTarjeta, sFechaStatusUltMod, sHoraStatusUltMod, sEmpleadoModifico
					FROM intercard:tarjeta a
						JOIN intercard:tarjetacuenta b ON ( a.numtarjeta = b.numtarjeta )
					WHERE a.numtarjeta = psNumTarjeta;

				ELSE
				
					-- Se busca la cuenta en el maestro de pagarés.
					SELECT NVL( a.cuenta, '' ), b.nombre, a.promotor
						INTO sNumCuenta, sProducto, sEmpleadoModifico
					FROM bdinvers:sv_maeinv a
						LEFT OUTER JOIN bdinvers:sv_instrum b ON ( b.cod_instrum = a.cod_instrum )
					WHERE a.empresa = psEmpresa AND a.cuenta = psNumCuenta 
						AND a.secuencia = ( 
							SELECT MAX( secuencia )
							FROM bdinvers:sv_maeinv
							WHERE empresa = psEmpresa AND cuenta = psNumCuenta );
							
					IF ( sNumCuenta <> '' ) THEN
					
						SELECT NVL( cuenta, '' ), TO_CHAR( fech_alt, '%d/%m/%Y' ), fech_hor::DATETIME HOUR TO SECOND
							INTO sNumCuenta, sFechaStatusUltMod, sHoraStatusUltMod
						FROM bdinvers:sv_movdia
						WHERE cuenta = psNumCuenta AND num_serial = (
							SELECT MAX( num_serial ) 
							FROM bdinvers:sv_movdia
							WHERE cuenta = psNumCuenta );
					
					END IF;
				END IF;
				
				-- Se obtiene nombre de ejecutivo.
				SELECT ejecutivo, UPPER( nombre )
					INTO sEmpleadoModifico, sNombreEmpMod
				FROM bdinteg:si_ejecut
				WHERE ejecutivo = sEmpleadoModifico;
				
				IF ( NVL( sNumCuenta, '' ) = '' OR NVL( sProducto, '' ) = '' OR NVL( sNombreEmpMod, '' ) = '' ) THEN

					LET sCodigoRetorno = '00004'; -- Error al tratar de obtener los datos generales de la cuenta de débito.

				END IF;
				
				RETURN sCodigoRetorno, 
					sProducto, sFechaStatusUltMod, sHoraStatusUltMod, NULL, sEmpleadoModifico, sNombreEmpMod;
						
			-- Datos de la apertura de la cuenta de débito.
			ELIF ( piTipoBusqueda = 3 ) THEN
			
				SELECT a.cuenta, TO_CHAR( b.fecha_alta, '%d/%m/%Y' ), a.sucursal
					INTO sNumCuenta, sFechaStatusAperturaCuenta, sSucursalAperturaCuenta
				FROM bdicheq:sc_maechq a    
					INNER JOIN bdicheq:sc_maenoc b ON ( a.cuenta = b.cuenta )
				WHERE b.empresa = psEmpresa
					AND b.cuenta = psNumCuenta;
				
				IF ( NVL( sNumCuenta, '' ) <> '' ) THEN					
					
					SELECT LIMIT 1 numtarjeta, fechahorainauth::DATETIME HOUR TO SECOND, SUBSTR( idterminal, 5, 8 )
						INTO sNumTarjeta, sHoraStatusAperturaCuenta, sEmpleadoAperturo
					FROM intercard:movimientohistorico 
					WHERE codtran = 95 AND numtarjeta = psNumTarjeta;
					
										
									
						IF ( sNumTarjeta IS NULL ) THEN
					
							SELECT LIMIT 1 numtarjeta, fechahorainauth::DATETIME HOUR TO SECOND, NVL( SUBSTR( idterminal, 5, 8 ), '' )
							INTO sNumTarjeta, sHoraStatusAperturaCuenta, sEmpleadoAperturo
							FROM intercard:movimiento
							WHERE codtran = 95 AND numtarjeta = psNumTarjeta;
					
						END IF;	
				
				ELSE	

					SELECT a.cuenta, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.usuario
						INTO sNumCuenta, sFechaStatusAperturaCuenta, sHoraStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo
					FROM bdinvers:sv_movhis a
					WHERE a.transacc = '0500' AND a.cuenta = psNumCuenta;
					
					IF ( NVL( sNumCuenta, '' ) = '' ) THEN
					
						SELECT a.cuenta, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.usuario
							INTO sNumCuenta, sFechaStatusAperturaCuenta, sHoraStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo
						FROM bdinvers:sv_movdia a
						WHERE a.transacc = '0500' AND a.cuenta = psNumCuenta;
						
					END IF;
				END IF;
				
				-- Se obtiene nombre de ejecutivo.
				SELECT ejecutivo, UPPER( nombre )
					INTO sEmpleadoAperturo, sNombreEmpAperturo
				FROM bdinteg:si_ejecut
				WHERE ejecutivo = sEmpleadoAperturo;
				
				IF ( NVL( sNombreEmpAperturo, '' ) = '' OR NVL( sNumCuenta, '' ) = '' ) THEN
				
					LET sCodigoRetorno = '00005'; --Error al tratar de obtener los datos de la apertura de la cuenta de débito.
					
				END IF;
				
				RETURN sCodigoRetorno, 
					NULL, sFechaStatusAperturaCuenta, sHoraStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo, sNombreEmpAperturo;			
			
			--Histórico de las cuentas, opción pagarés.
			/*ELIF ( piTipoBusqueda = 4 ) THEN
			
                FOREACH
                    SELECT b.cuenta 
						INTO sCuentaPagare 
                    FROM bdicheq:sc_maechq a 
						LEFT OUTER JOIN bdinvers:sv_maeinv b ON ( a.empresa = b.empresa AND a.cuenta = b.cta_cheques )
                    WHERE a.empresa = psEmpresa AND b.cta_cheques = psNumCuenta

                    IF ( sCuentaPagare <> "" OR sCuentaPagare IS NOT NULL ) THEN

                        FOREACH
                            SELECT a.cuenta, a.status_cta, b.fech_alt, SUBSTR( b.fech_hor, 1, 8 ) AS hora, a.promotor, c.nombre
								INTO sNumCuenta, sEstatusHistorico, vfechamttoaux, sHoraStatusHistorico, sEmpleadoHistorico, sNombreEmpleadoHistorico
                            FROM bdinvers:sv_maeinv a
                                LEFT OUTER JOIN bdinvers:sv_movdia b ON ( b.cuenta = a.cuenta )
                                LEFT OUTER JOIN bdinteg:si_ejecut c ON ( c.ejecutivo = a.promotor )
                            WHERE a.cuenta = sCuentaPagare 
                                AND ( b.transacc = '0500' OR a.status_cta = 4 OR a.status_cta = 2 )

                            LET sFechaEstatusHistorico = '1900-01-01';

                            IF ( vfechamttoaux IS NOT NULL ) THEN

                                LET vDia = LPAD( DAY( vfechamttoaux ), 2, '0' );
                                LET vMes = LPAD( MONTH( vfechamttoaux ), 2, '0' );
                                LET vAnio = YEAR( vfechamttoaux );
                                LET sFechaEstatusHistorico = vAnio || '-' || vMes || '-' || vDia;

                            END IF                                

                            RETURN sCodigoRetorno, 
								sEstatusHistorico, sFechaEstatusHistorico, sHoraStatusHistorico, NULL, sEmpleadoHistorico, sNombreEmpleadoHistorico WITH RESUME;
								
                        END FOREACH
                    END IF;
                END FOREACH;		
						
			--Histórico de las cuentas, opción inversión.
			ELIF ( piTipoBusqueda = 5 ) THEN          
			
                FOREACH
                    SELECT b.cuenta 
						INTO sCuentaInversion 
                    FROM bdicheq:sc_maechq a 
                        LEFT OUTER JOIN bdicheq:sc_maeinstrucc b ON ( a.cuenta = b.cuentadep )                         
                    WHERE a.empresa = psEmpresa AND a.cuenta = psNumCuenta

                    IF ( sCuentaInversion <> "" OR sCuentaInversion IS NOT NULL ) THEN
                        FOREACH
                            SELECT a.cuenta, a.status_cta AS estatus, a.fecha_proceso AS fecha_estatus_can,
                                SUBSTR( a.fecha_proceso, 11, 9 ) AS hora_status_can, a.num_cte, b.nombre 
								INTO sNumCuenta, sEstatusHistorico, vfechamttoaux, sHoraStatusHistorico, sEmpleadoHistorico, sNombreEmpleadoHistorico
                            FROM bdicheq:sc_maechq a 
                                LEFT OUTER JOIN bdicheq:sc_producto b on ( a.producto = b.producto )							
                            WHERE a.empresa = psEmpresa
                                AND a.cuenta  = sCuentaInversion
                                AND ( a.status_cta = 2 OR a.status_cta = 3 )

                            IF ( vfechamttoaux IS NOT NULL ) THEN
							
								LET vDia = LPAD( DAY(vfechamttoaux ), 2, '0' );
                                LET vMes = LPAD( MONTH(vfechamttoaux ), 2, '0' );
								LET vAnio = YEAR( vfechamttoaux );
								LET sFechaEstatusHistorico = vAnio || '-' || vMes || '-' || vDia;

                            END IF;     

                           RETURN sCodigoRetorno, 
							sEstatusHistorico, sFechaEstatusHistorico, sHoraStatusHistorico, NULL, sEmpleadoHistorico, sNombreEmpleadoHistorico WITH RESUME;
							
                        END FOREACH;						
                    END IF;
               END FOREACH;*/
						
			-- Histórico de las cuentas, Cancelación de cuentas débito.
			ELIF ( piTipoBusqueda = 7 ) THEN
			
				SELECT a.cuenta, a.status_cta, TO_CHAR( a.fec_cancelac, '%d/%m/%Y' )
					INTO sNumCuenta, sEstatusHistorico, sFechaEstatusHistorico
				FROM bdicheq:sc_maechq a 
					LEFT OUTER JOIN bdicheq:sc_producto b ON (a.producto = b.producto)
				WHERE status_cta = 3 AND a.cuenta = psNumCuenta;
				
				IF ( sNumCuenta IS NULL ) THEN
				
					FOREACH
						SELECT cuenta, status_cta, TO_CHAR( fec_cancelac, '%d/%m/%Y' )
							INTO sNumCuenta, sEstatusHistorico, sFechaEstatusHistorico
						FROM bdinvers:sv_maeinv
						WHERE cuenta = psNumCuenta AND status_cta IN ( 2, 4 )
						
						RETURN sCodigoRetorno, 
							sEstatusHistorico, sFechaEstatusHistorico, NULL, NULL, NULL, NULL;
							
					END FOREACH;
				
				ELSE
					
					RETURN sCodigoRetorno, 
						sEstatusHistorico, sFechaEstatusHistorico, NULL, NULL, NULL, NULL;
					
				END IF;
				
				IF ( NVL( sFechaEstatusHistorico, '' ) = '' ) THEN
					
					LET sCodigoRetorno = '00007'; -- No tiene cancelación.
					
					RETURN sCodigoRetorno, 
						NULL, NULL, NULL, NULL, NULL, NULL;
				
				END IF;				
						
			END IF;
		ELSE
		
			LET sCodigoRetorno = '00010'; --Error en parámetros de entrada.
			
			RETURN sCodigoRetorno, 
				NULL, NULL, NULL, NULL, NULL, NULL;
			
		END IF;		
	END;
END PROCEDURE
DOCUMENT
'CREADO:		Francisco Rodríguez Ibarra.',
'FECHA:			30 de abril de 2010.',
'DESCRIPCIÓN:	Consulta los datos de la cuenta, ademas que trae el histórico',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			Lunes, 03 de Enero de 2011.',
'MODIFICACIÓN:	Se reestructuran y optimizan las búsquedas para consultar cuentas de crédito, cheques, inversiones y pagarés.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			Miércoles, 26 de Enero de 2011.',
'MODIFICACIÓN:	condición de cuenta existente en la consulta de apertura de cuenta de crédito y agregar filtro de empresa ', 
'				en la consulta de horastatus sobre la tabla bdicred:sd_movhis./mod',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		23/01/2014',
'MODIFICACIÓN: 	Se elimina referencia a tabla intercard:movimientohistorico_old.'

;

CREATE PROCEDURE "informix".spconsultarmvtosnip( psEmpresa CHAR(3), psNumTarjeta CHAR(16) )

	RETURNING CHAR(5) AS CodigoRetorno, 
		CHAR(10) AS Fecha, CHAR(9) AS Hora, CHAR(4) AS Sucursal, CHAR(8) AS Empleado, CHAR(45) AS Nombre;

	DEFINE iSqlErr          	INTEGER;
	DEFINE sCodigoRetorno        CHAR(5);
	
	DEFINE sFecha		CHAR(10);
	DEFINE sHora		CHAR(9);
	DEFINE sSucursal	CHAR(4);
	DEFINE sEmpleado	CHAR(8);
	DEFINE sNombre		CHAR(45);
	
	--SET DEBUG FILE TO  "/respaldosbd/ulises/spConsultarMvtosNIP.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			
			IF iSqlErr <> 0 THEN
			
				LET sCodigoRetorno = iSqlErr;
				
				RETURN sCodigoRetorno, NULL, NULL, NULL, NULL, NULL;
				
			END IF;
		END EXCEPTION;

		--VALIDA PARÁMETROS DE ENTRADA.
		IF ( NVL( psEmpresa, '' ) = '' AND NVL( psNumTarjeta, '' ) ) THEN

			LET sCodigoRetorno = '00001';
			
			RETURN sCodigoRetorno, NULL, NULL, NULL, NULL, NULL;

		END IF;

		LET sFecha 		= '';
		LET sHora 		= '';
		LET sSucursal	= '';
		LET sEmpleado  	= '';
		LET sNombre   	= '';

		FOREACH
			SELECT TO_CHAR( a.fechahorainauth, '%d/%m/%Y' ), a.fechahorainauth::DATETIME HOUR TO SECOND, SUBSTR( a.idterminal, 1, 4 ), 
					SUBSTR( a.idterminal, 5, 8 ), b.nombre
				INTO sFecha, sHora, sSucursal, sEmpleado, sNombre
			FROM intercard:movimientohistorico a
				LEFT OUTER JOIN bdinteg:si_ejecut b ON ( SUBSTR( a.idterminal, 5, 8 ) = b.ejecutivo )
			WHERE a.codtran = 95 AND empresa = psEmpresa AND a.numtarjeta = psNumTarjeta

			LET sCodigoRetorno = '00000';			

			RETURN sCodigoRetorno, sFecha, sHora, sSucursal, sEmpleado, sNombre WITH RESUME;

		END FOREACH;

		FOREACH
			SELECT TO_CHAR( a.fechahorainauth, '%d/%m/%Y' ), a.fechahorainauth::DATETIME HOUR TO SECOND, SUBSTR( a.idterminal, 1, 4 ), SUBSTR( a.idterminal, 5, 8 ), b.nombre
				INTO sFecha, sHora, sSucursal, sEmpleado, sNombre
			FROM intercard:movimiento a
				LEFT OUTER JOIN bdinteg:si_ejecut b ON ( SUBSTR( a.idterminal, 5, 8 ) = b.ejecutivo )
			WHERE a.codtran = 95 AND empresa = psEmpresa AND a.numtarjeta = psNumTarjeta

			LET sCodigoRetorno = '00000';			

			RETURN sCodigoRetorno, sFecha, sHora, sSucursal, sEmpleado, sNombre WITH RESUME;

		END FOREACH;
		
	END
END PROCEDURE
DOCUMENT
'CREADO:		Ulises Rodríguez Márquez.',
'FECHA:			05 de Mayo de 2010.',
'DESCRIPCIÓN:	Consulta los movimientos del mantenimiento de NIP de una tarjeta.',
'RETORNO:		00000 Datos obtenidos satisfactoriamente',
'				00001 Parametros insuficientes.',

'MODIFICÓ: 		Ulises Rodríguez Márquez',
'FECHA: 		06/01/2011',
'MODIFICACIÓN: 	Se agrega la búsqueda sobre la intercard:movimiento.',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		24/10/2012',
'MODIFICACIÓN: 	Se agrega la búsqueda sobre la intercard:movimientohistorico_old.',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		23/01/2014',
'MODIFICACIÓN: 	Se elimina referencia a la tabla intercard:movimientohistorico_old.'

;

CREATE PROCEDURE "informix".sp_actualiza_gerentes( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER; 
    
    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viTrxAbierta SMALLINT;
    DEFINE viContador   INTEGER;
    DEFINE vdFechaHoy   DATE;
    DEFINE vcSucAnt     CHAR(4);
    DEFINE vcSucursal   CHAR(4);
    DEFINE vcEjecutivo  CHAR(8);
    DEFINE vcNombreGte  CHAR(45);
    DEFINE vdFechaIns   DATE;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO REALIZADO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viTrxAbierta = 0;
    LET viContador   = 0;    
    LET vdFechaHoy   = '';
    LET vcSucAnt     = '';
    LET vcSucursal   = '';
    LET vcEjecutivo  = '';
    LET vcNombreGte  = '';
    LET vdFechaIns   = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_actualiza_gerentes.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualiza_gerentes.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM si_fechas
     WHERE empresa = pEmpresa;
     
    LET vcSucAnt = '0000';
    
    FOREACH WITH HOLD
        SELECT sucursal, ejecutivo, nombre, fecha_insert
          INTO vcSucursal, vcEjecutivo, vcNombreGte, vdFechaIns
          FROM si_ejecut 
         WHERE sucursal IN ( SELECT sucursal FROM si_sucursales WHERE tpo_sucursal = 'S' )
           AND ejecutivo LIKE '9%'
           AND password NOT IN('BAJA', 'baja')
           AND vigencia > vdFechaHoy
           AND puesto = '001'
         ORDER BY sucursal, fecha_insert
           
        BEGIN WORK;
        LET viTrxAbierta = 1;
        
        IF vcSucursal <> vcSucAnt THEN
            UPDATE si_sucursales
               SET gerente = vcNombreGte
             WHERE sucursal = vcSucursal;
        END IF;
        
        LET vcSucAnt = vcSucursal;
        
        LET viContador = viContador + 1;        
        
        COMMIT WORK;
        LET viTrxAbierta = 0;
        
        LET vcSucursal  = '';
        LET vcEjecutivo = '';
        LET vcNombreGte = '';
        LET vdFechaIns  = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador;
    
END PROCEDURE;