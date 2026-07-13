CREATE PROCEDURE "informix".sp_detalle_boletos_pba (pClaveSort CHAR(5),
                                                pFechaActual DATE)

RETURNING CHAR (5) AS Codigo, CHAR(5) AS Clave_Sorteo, CHAR (80) AS Mensaje;

--- DECLARACION DE VARIABLES

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vCodret          CHAR(5);
    DEFINE vCveSorteo       CHAR(5);
    DEFINE vMensaje         CHAR(80);

    DEFINE vF_Proceso       DATE;
    DEFINE vEmpresa         CHAR(3);
    DEFINE vCve_Sorteo      CHAR(5);
    DEFINE vF_ini           DATE;
    DEFINE vF_Fin           DATE;

    DEFINE vNumcte          CHAR(10);
	  DEFINE iNumcte          INTEGER;

    DEFINE vCve_Sort        CHAR(5);
    DEFINE vBoleto_ini      INT8;
    DEFINE vBoleto_Fin      INT8;
    DEFINE vF_registro      DATETIME YEAR TO SECOND;
    DEFINE vNumCliente      CHAR(10);
    DEFINE vEstado          INTEGER;
    DEFINE vSucursal        CHAR(4);
    DEFINE vArea            CHAR(1);
    DEFINE vCaja            INTEGER;
    DEFINE vTipomov         CHAR(10);
    DEFINE vFoliosuc        CHAR(16);
    DEFINE vImporte         MONEY;
    DEFINE vTel1            CHAR(10);
    DEFINE vTel2            CHAR(13);
    DEFINE vNombre          CHAR(45);
    DEFINE vCiudad          CHAR(20);
    DEFINE vDomicilio       CHAR(50);
    DEFINE vFecha           DATE;
    DEFINE vOrigen          CHAR(10);
    DEFINE vSecuencia       INTEGER;
    DEFINE vLimite          INTEGER;
    DEFINE vContador        INTEGER;
    DEFINE vContSecuencia   INTEGER;

    DEFINE cCodRet          CHAR(3);
    DEFINE v_Valor          CHAR(5);
	  --DEFINE vrowid       	  INTEGER;
	  DEFINE vCuentaBoletos   INTEGER;
	  DEFINE vCuentaEmpleados INTEGER;


--- INICIALIZACION DE VARIABLES

    LET sql_err         = 0;
    LET isam_err        = 0;
    LET vCodret         = '00000';
    LET vCveSorteo      = pClaveSort;
    LET vMensaje        = 'El proceso concluyó exitosamente';

    LET vF_Proceso      = '';
    LET vEmpresa        = '001';
    LET vCve_Sorteo     = '0';
    LET vF_ini          = '';
    LET vF_Fin          = '';

    LET vNumcte         = '';

    LET vCve_Sort       = '';
    LET vBoleto_ini     = '';
    LET vBoleto_Fin     = '';
    LET vF_registro     = '';
    LET vNumCliente     = '';
    LET vEstado         = '';
    LET vSucursal       = '';
    LET vArea           = '';
    LET vCaja           = '';
    LET vTipomov        = '';
    LET vFoliosuc       = '';
    LET vImporte        = 0.00;
    LET vTel1           = '';
    LET vTel2           = '';
    LET vNombre         = '';
    LET vCiudad         = '';
    LET vDomicilio      = '';
    LET vFecha          = '';
    LET vOrigen         = '';
    LET vSecuencia      = '';
    LET vLimite         = 0;
    LET vContador       = 0;
    LET vContSecuencia  = 1;

    LET cCodRet          = '';
    LET v_Valor          = '';
	  --LET vrowid      	   = 0;
	  LET iNumcte      	   = 0;
	  LET vCuentaBoletos   = 0;
	  LET vCuentaEmpleados = 0;



     --****************************************************************
     -- Creado por Raúl Ramírez    01/Septiembre/2010
     -- Proceso para traducir rangos de boletos a un detalle de boletos
     --****************************************************************


BEGIN

    ON EXCEPTION SET sql_err

        IF sql_err <> 0  THEN
            LET vCodret   = sql_err;
            LET vCodret   = '00045';
            LET vMensaje  = 'ERROR EN LA EJECUCION';
            RETURN vCodret, vCveSorteo, vMensaje;        -- Termina proceso del SP
        END IF;
    END EXCEPTION;

        --SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_detalle_boletos.out";
        --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    LET vF_Proceso = pFechaActual -1;

	SELECT {+INDEX(si_param ix_si_param)} valor
	INTO v_Valor
	FROM bdinteg:si_param
	WHERE empresa = vEmpresa
	AND cod_param = 118;

	SELECT {+INDEX (si_sorteo idx_si_sorteo2)} cve_sorteo, f_ini, f_fin
	INTO vCve_Sorteo, vF_ini, vF_Fin
	FROM bdinteg:si_sorteo
	WHERE cve_sorteo = v_Valor;


	IF (v_Valor IS NULL OR v_Valor = '') OR -- Valida clave sorteo vigente
	   (v_Valor <> pClaveSort) THEN
		 LET vCodret = '00040';
		 LET vMensaje = 'NO EXISTE SORTEO';
			RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
	ELSE
		IF (vF_ini IS NULL OR vF_ini = '') OR      -- Valida fecha sorteo vigente
		   (vF_Fin IS NULL OR vF_Fin = '') OR
		   (vF_Proceso NOT BETWEEN vF_ini AND vF_Fin) THEN
			  LET vCodret = '00042';
			  LET vMensaje = 'SORTEO NO ESTA VIGENTE?';
			RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
		END IF;
	END IF;

	-- BGM 11-Nov-2010: Se agrega depuración de tabla si_boleto_temp
	TRUNCATE si_boleto_temp;
	
	EXECUTE PROCEDURE "informix".sp_movtos_reversados ('001')
			INTO cCodRet;
	
    FOREACH

		---SELECT {+INDEX (si_movreversados idx_si_movrever)} empresa, fecha_mov, folio_suc
		SELECT {+FULL} empresa, fecha_mov, folio_suc
		INTO vEmpresa, vFecha, vFoliosuc
		FROM bdinteg:si_movreversados
		WHERE empresa = vEmpresa
		AND folio_suc <> ''
		
		IF EXISTS (SELECT {INDEX (bdinteg:si_boleto idx_si_boleto)} foliosuc 
		           FROM bdinteg:si_boleto 
			         WHERE cve_sorteo = vCve_Sorteo
               AND foliosuc = vFoliosuc
               AND fecha = vFecha) THEN
			
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist2)} bdinteg:si_boleto_hist
				SET estado = '101'
				WHERE cve_sorteo = vCveSorteo
				AND   foliosuc = vFoliosuc
				AND   fecha = vFecha;

				--DELETE {+INDEX (si_boleto idx_si_boleto)} FROM bdinteg:si_boleto
				--WHERE cve_sorteo = vCveSorteo
				--AND   foliosuc = vFoliosuc
				--AND   fecha = vFecha;
		END IF;
		
	END FOREACH;
	
	SELECT {+FULL} COUNT(*) into vCuentaBoletos FROM si_boleto;
	SELECT {+FULL} COUNT(*) into vCuentaEmpleados FROM si_syssorteo_emp;

	IF vCuentaBoletos <= vCuentaEmpleados THEN
	
		FOREACH
		
			SELECT {+FULL} numcte
			INTO iNumcte
			FROM bdinteg:si_boleto
			
			IF EXISTS (SELECT {+INDEX (si_syssorteo_emp idx_si_syssorteo_emp)} numcte
					FROM si_syssorteo_emp
					WHERE tipo IN (2 , 4) 
                                        AND status = 'A'
                                        AND numcte = iNumcte) THEN
					
					UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist4)} si_boleto_hist
					SET estado = '101'
					---WHERE numcte::INT = iNumcte;
					WHERE numcte = iNumcte;
			END IF;
		
		END FOREACH;
		
	ELIF vCuentaBoletos > vCuentaEmpleados THEN
	
		FOREACH
	
			SELECT {+FULL} numcte
			INTO iNumcte  
			FROM si_syssorteo_emp
			
			IF EXISTS (SELECT {INDEX (bdinteg:si_boleto idx_idx_si_boleto6)} numcte 
					FROM bdinteg:si_boleto 
					WHERE numcte::INT = iNumcte) THEN
				
					UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist4)} bdinteg:si_boleto_hist
					SET estado = '101'
					---WHERE numcte::INT = iNumcte;
					WHERE numcte = iNumcte;
			END IF;
				
		END FOREACH;
		
	END IF;
	
	FOREACH cursor_inserta WITH HOLD FOR
					
			SELECT {+INDEX (si_boleto_hist idx_si_boleto_hist2)}
					cve_sorteo, boleto_ini, boleto_fin, f_registro, numcte, estado, sucursal, area, caja, tipomov,
					foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia
			INTO  vCve_Sort, vBoleto_Ini, vBoleto_Fin, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
              vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vSecuencia
			FROM bdinteg:si_boleto_hist
			WHERE cve_sorteo =  vCveSorteo
			AND foliosuc <> ''
			AND fecha = vF_Proceso
			AND estado = 2
			
			LET vLimite = vBoleto_Fin;
            BEGIN WORK;
                FOR vContador = vBoleto_Ini TO vLimite
					INSERT INTO si_boleto_temp(cve_sorteo, boleto, f_registro, numcte, estado, sucursal, area, caja, tipomov,
                                foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia)
					VALUES (vCve_Sort, vContador, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
                            vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vContSecuencia);
					LET vContSecuencia = vContSecuencia + 1;
				END FOR

				LET vContSecuencia = 1;
            COMMIT WORK;                           
               
    END FOREACH;

  -- BGM 11-Nov-2010: Se agrega depuración de tabla si_boleto;
	TRUNCATE si_boleto;
	TRUNCATE si_movreversados;
		  
END
    RETURN vCodret, vCveSorteo, vMensaje;

END PROCEDURE;