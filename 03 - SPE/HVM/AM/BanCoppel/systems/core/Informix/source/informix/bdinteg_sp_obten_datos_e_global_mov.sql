CREATE PROCEDURE "informix".sp_obten_datos_e_global_mov(p_tarjeta CHAR(20), p_secuenciaExtendida CHAR(20), p_debito CHAR(1), p_cuenta CHAR(20), p_empresa CHAR(3))

     RETURNING	DATETIME YEAR TO SECOND AS fechaMovimiento, CHAR(20) AS iso41, CHAR (20) AS iso37, CHAR(4) AS idReceptor, CHAR(6) AS horaMovimiento, money(16,2) AS resultado_monto_comision, CHAR(1) AS resultado_codigo, CHAR(7) AS secuencia;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento    DATETIME YEAR TO SECOND;
    DEFINE resultado_iso41              CHAR(20);
    DEFINE resultado_iso37              CHAR(20);
    DEFINE resultado_idReceptor         CHAR(4);
    DEFINE resultado_horaMovimiento     CHAR(6);
	DEFINE resultado_monto_comision		money(16,2);
    DEFINE resultado_codigo             CHAR(1);
    DEFINE var_secuencia                CHAR(7);
    DEFINE var_fechaAut                 DATETIME YEAR TO SECOND;
	DEFINE var_fechaAnt					DATE;
	DEFINE var_fechapost				DATE;
	DEFINE tipo_producto				CHAR(2);
    DEFINE iSqlErr                      INTEGER;
     
     -- Inicialización de las variables.
    LET resultado_fechaMovimiento = null;
	LET resultado_iso41  = '';
    LET resultado_iso37  = '';
    LET resultado_idReceptor = '';
    LET resultado_horaMovimiento = '';
    LET resultado_monto_comision = '';
    LET resultado_codigo = '';
    LET var_secuencia = '';
	LET var_fechaAnt = null;
	LET var_fechapost = null;
	LET tipo_producto ='';
    LET var_fechaAut = null;
	
   --SET DEBUG FILE TO "../informix/BB/eglobal/sp_obten_datos_e_global_mov.out";
   --TRACE ON;

    SET ISOLATION TO DIRTY READ;

	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_fechaMovimiento = '';
                LET resultado_iso41  = '';
                LET resultado_iso37  = '';
                LET resultado_idReceptor = '';
                LET resultado_horaMovimiento = '';
                LET resultado_monto_comision = '';
                LET resultado_codigo = '';
                LET var_secuencia = '';
				LET var_fechaAnt = '';
				LET var_fechapost = '';
                LET var_fechaAut = '';
            RETURN resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, resultado_codigo, var_secuencia;
            END IF;
        END EXCEPTION;
		
		/*Se busca la información en la tabla de movimiento*/
		SELECT DISTINCT fechahorainauth, idterminal, referencia, idreceptor, horalocaltransaccion, montosurcharge, secuencia
			INTO resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, 
				resultado_monto_comision, var_secuencia
		FROM intercard:movimiento
		WHERE numtarjeta = p_tarjeta
            AND secuenciaextendida LIKE (SUBSTRING (p_secuenciaExtendida FROM 1 FOR 8) || '_' || SUBSTRING(p_secuenciaExtendida FROM 10 FOR 15));
            					   
		SELECT DISTINCT codreversa
            INTO resultado_codigo
		FROM intercard:movimiento
		WHERE numtarjeta = p_tarjeta
            AND secuenciaorig = var_secuencia;            
		
		/*De no encontrar la información en las tabla anterior, se realiza la búsqueda sobre movimientohistorico*/
		IF (resultado_iso41 is null OR resultado_iso41 =='') THEN 
			SELECT DISTINCT fechahorainauth, idterminal, referencia, idreceptor, horalocaltransaccion, montosurcharge, secuencia
				INTO resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, 
					resultado_monto_comision, var_secuencia
			FROM intercard:movimientohistorico
			WHERE numtarjeta = p_tarjeta
				AND secuenciaextendida LIKE (SUBSTRING (p_secuenciaExtendida FROM 1 FOR 8) || '_' || SUBSTRING(p_secuenciaExtendida FROM 10 FOR 15));
            					   
            SELECT DISTINCT codreversa
				INTO resultado_codigo
            FROM intercard:movimientohistorico
            WHERE numtarjeta = p_tarjeta
				AND secuenciaorig = var_secuencia;            
		END IF;
		
        RETURN resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, resultado_codigo, var_secuencia;
    END 
END PROCEDURE
DOCUMENT
'Sp para generación de datos para archivos ATM´s para solicitar a Eglobal por sistema',
'Aclaraciones',
'AUTOR : Bernardo Beltrán Herrera',
'MODIFICADO POR : Víctor Jesús Mendoza Pérez',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Marzo/2013',
'FECHA MODIFICACIÓN: 06/Julio/2017',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_desasocia_ctapbn_emp( pEmpresa CHAR(3), prfc CHAR(15), pnumcte CHAR(10), pnumcta CHAR(30) )
RETURNING CHAR(6), CHAR(60), CHAR(1);

	/*Definicion de variables del proceso y manejo de errores*/
		DEFINE error_info 		CHAR(60);
		DEFINE vcodret    		CHAR(6);
		DEFINE vsqlerr    		INTEGER;
		DEFINE isam_err   		SMALLINT;
		DEFINE vstscta			CHAR(1);
		DEFINE vbcta			INT;
		--SET DEBUG FILE TO "/informix/ifg/sp_desasocia_ctapbn_emp.out";
		--TRACE ON;

		LET vcodret       	= '00000';
		LET error_info    	= 'Iniciando ejecucion';
		LET isam_err      	= 0;
		LET vsqlerr       	= 0;
		LET vstscta			= '';
		LET vbcta			= 0;




		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		/*Incia SP*/
		BEGIN
			--//Excepciones
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0 THEN
					 LET vcodret = vsqlerr;
					 LET isam_err = isam_err;
					 LET error_info = error_info;
					 RETURN vcodret, error_info, vstscta;
				END IF;
			END EXCEPTION;
			
			--// Valida la informacion de entrada
		   IF pEmpresa       = "" OR
			  prfc      = "" OR
			  pnumcte      = "" OR
			  pnumcta       = "" THEN
						  LET vcodret = "00001";
						  LET error_info = 'ERROR PARAMETROS VACIOS'; 
						
			ELSE
						  SELECT COUNT(*) INTO vbcta FROM bdinteg:si_ctepf WHERE numcte =  pnumcte;
						  SELECT status_cta INTO vstscta FROM bdicheq:sc_maechq WHERE num_cte =  pnumcte AND cuenta = pnumcta;
						  IF (vbcta != 0) AND (vstscta = 1) THEN	
								UPDATE bdinteg:si_ctepf SET numeric1 = '', 
															numeric2 = '' 
											WHERE numcte =  pnumcte;
											
								UPDATE bdinteg:si_altamasivaempnet_det SET cod_empresa = '' 															
											WHERE cod_empresa =  pEmpresa
											  AND numcte = pnumcte
											  AND cuenta = pnumcta;				
												
								LET vcodret = '00000';
								LET error_info = 'PROCESO EJECUTADO EXITOSAMENTE';
						  ELSE 
								
								LET vcodret = "00002";
								LET error_info = 'NO SE ENCONTRARON DATOS';
						  END IF;
		   END IF;
	 RETURN vcodret,error_info,vstscta;
	    
    END;
    
END PROCEDURE;