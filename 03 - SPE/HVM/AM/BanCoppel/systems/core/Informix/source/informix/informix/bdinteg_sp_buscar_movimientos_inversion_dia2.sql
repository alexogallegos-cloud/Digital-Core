CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_dia2(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(1) AS reversado;

	-- Definición de variables	    
	DEFINE resultado_fechaMovimiento 		DATE;
	DEFINE resultado_monto					money(16,2);
	DEFINE resultado_horaMovimiento			DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc				CHAR(30);
    DEFINE resultado_sucursal				CHAR(4);
    DEFINE resultado_nombre            		CHAR(30);
    DEFINE resultado_claveTipo         		CHAR(5);
    DEFINE resultado_tipo   				CHAR(40);
    DEFINE resultado_reversado				CHAR(1);
    DEFINE transacciones 					LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      	INTEGER;
	DEFINE v_tabla							CHAR(4);
	
    -- Inicialización de las variables.
	LET resultado_fechaMovimiento 	= '';
	LET resultado_monto 			= '';
	LET resultado_horaMovimiento 	= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 			= '';
    LET resultado_sucursal 			= '';
    LET resultado_nombre 			= '';
   	LET resultado_claveTipo 		= '';
	LET resultado_tipo 				= '';
    LET resultado_reversado 		= '';
	LET transacciones 				= 'LIST{' || ids_transacciones || '}';
	LET v_tabla 					= '';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones Optimización de SP´s II 05/03/2013
-- Cambio para que en un sólo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificación correcta de los SP´s del sistema.
-- SADVC 
	
    SET ISOLATION TO DIRTY READ;
-- SET DEBUG FILE TO "/informix/SD/Optimizacion_sps_root_II/sp_buscar_movimientos_inversion_dia2.out";
-- TRACE ON;

	BEGIN

        ON EXCEPTION
                
				SET iSqlErr
        
				IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_sucursal = '';
                    LET resultado_nombre = '';
                    LET resultado_claveTipo = '';
                    LET resultado_tipo = '';
					LET resultado_reversado = '';
                    
					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado;
                
				END IF;
        
		END EXCEPTION;

        IF(ids_transacciones IS NOT NULL) THEN
        
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
			
				FOREACH
					SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
					INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
					FROM ( SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'D'
			          FROM bdinvers:sv_movdia 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
				     WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial
                       AND bdinvers:sv_movdia.transacc <> '0801'
                       AND bdinvers:sv_movdia.transacc_suc <> '6801'
                       AND bdinvers:sv_movdia.transacc IN transacciones
            
					UNION ALL 
				
					SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'H'
			          FROM bdinvers:sv_movhis 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			         WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial
                       AND bdinvers:sv_movhis.transacc <> '0801'
                       AND bdinvers:sv_movhis.transacc_suc <> '6801'
                       AND bdinvers:sv_movhis.transacc IN transacciones
                       AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
					)
					ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			ELSE
			
				FOREACH
					SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
					INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
					FROM ( SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'D'
			          FROM bdinvers:sv_movdia 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
			          WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial 
                        AND monto_tot = p_sMonto
                        AND bdinvers:sv_movdia.transacc <> '0801'
                        AND bdinvers:sv_movdia.transacc_suc <> '6801'
                        AND bdinvers:sv_movdia.transacc IN transacciones
            
					UNION ALL
					
				    SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'H'
			          FROM bdinvers:sv_movhis 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			          WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial 
                        AND monto_tot = p_sMonto
                        AND bdinvers:sv_movhis.transacc <> '0801'
                        AND bdinvers:sv_movhis.transacc_suc <> '6801'
                        AND bdinvers:sv_movhis.transacc IN transacciones
                        AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
						)
					  ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			END IF;
		
		ELSE
		
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
			
				FOREACH
				SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
				INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
			    FROM ( 	SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			           FROM bdinvers:sv_movdia 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
						WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial
                        AND bdinvers:sv_movdia.transacc <> '0801'
                        AND bdinvers:sv_movdia.transacc_suc <> '6801'
           
					UNION ALL
					  
					SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			          FROM bdinvers:sv_movhis 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			         WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial
                       AND bdinvers:sv_movhis.transacc <> '0801'
                       AND bdinvers:sv_movhis.transacc_suc <> '6801'
                       AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
					  )
					  ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			ELSE
				
				FOREACH
			     	SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
				INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
					FROM (SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			          FROM bdinvers:sv_movdia 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
						WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial 
                        AND monto_tot = p_sMonto
                        AND bdinvers:sv_movdia.transacc <> '0801'
                        AND bdinvers:sv_movdia.transacc_suc <> '6801'
                      
					UNION ALL
					
					SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			           FROM bdinvers:sv_movhis 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			         WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial 
                       AND monto_tot = p_sMonto
                       AND bdinvers:sv_movhis.transacc <> '0801'
                       AND bdinvers:sv_movhis.transacc_suc <> '6801'
                       AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
					  )
					  ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			END IF;
		
		END IF;
	
	END 
	
END PROCEDURE;