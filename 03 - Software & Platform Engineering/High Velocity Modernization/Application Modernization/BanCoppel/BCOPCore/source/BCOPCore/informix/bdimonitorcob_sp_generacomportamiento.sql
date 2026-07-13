CREATE PROCEDURE "informix".sp_generacomportamiento(p_anio INTEGER, p_mes INTEGER, p_origen INTEGER)
	RETURNING CHAR (5), CHAR(80)

	--Declaracion de variables
	DEFINE v_codret             CHAR(5);
	DEFINE v_sqlerr             INTEGER;
    DEFINE v_isam_err           INTEGER;
    DEFINE v_error_info         CHAR(80);
    DEFINE v_mensaje            CHAR(80);
    DEFINE v_Empresa            CHAR(3);
    DEFINE v_NumCredito         CHAR(20);
    DEFINE iMesANterior         INTEGER;
    DEFINE iAnio                INTEGER;
    DEFINE iMesAux              INTEGER;
    DEFINE iAnioAux             INTEGER;
    DEFINE iResultadoIndicador  INTEGER;
    DEFINE cId_conceptom        CHAR(3);
    DEFINE cStatusCredito       CHAR(2);
    DEFINE dSaldoActual         DECIMAL(18,2);
    DEFINE v_capital_status     CHAR(1);
    DEFINE iMesesAtraso         INTEGER;
    DEFINE iCreditoUsado        INTEGER;
    DEFINE iRetraso             INTEGER;
    DEFINE dFechaCorte          DATE;
    DEFINE dFechaVenta          DATE;
    DEFINE cNombreProceso       CHAR(30);
    DEFINE cMesAnioEjecucion    CHAR(20);
    DEFINE fecha_fin            DATE;
    DEFINE v_pri_dia_mes        DATE;
    DEFINE vv_pri_dia_mes       DATE;
    DEFINE pMes                 smallint;
    DEFINE pAnio                smallint;
    
    

    IF p_origen = 1 THEN

        LET pMes    = pMes;
        LET pAnio   = pAnio;
    ELSE
        SELECT pri_dia_mes INTO vv_pri_dia_mes FROM bdinteg:si_fechas;

        LET v_pri_dia_mes   = vv_pri_dia_mes - 1 UNITS MONTH;
        LET pMes            = month (v_pri_dia_mes);
        LET pAnio           = year  (v_pri_dia_mes);

    END IF;
    
	--Inicializacion de variables
	LET v_codret 			= '11111';
	LET v_sqlerr 			= 0;
    LET v_isam_err 			= 0;
    LET v_error_info 		= '';
    LET v_mensaje 			= 'PROCESO INICIALIZADO';
    LET v_Empresa           = '001';
    LET v_NumCredito       = '';
    LET iMesANterior        = 0;
    LET iAnio               = 0;
    LET iResultadoIndicador = 0;
    LET cId_conceptom 		= '230';
    LET cStatusCredito 		= '';
    LET dSaldoActual        = 0;
    LET v_capital_status    = '';
    LET iCreditoUsado       = 0;
    LET dFechaCorte         = pMes || '-' || '20' || '-' || pAnio;
    LET dFechaVenta         = NULL;
    
    LET cNombreProceso = 'Genera Comportamiento';
    LET cMesAnioEjecucion = TO_CHAR(dFechaCorte, '%m-%Y');
    
	--------------------------------------------------------
	--06-04-2009
	--Realizo:
	--Lorenzo Ibarra Garcia
    	--Obtener el indicador de comportamiento de los créditos de un mes y año
	--------------------------------------------------------
	--16-06-2009
	--modifico:Bernardo Carlos Baez Gonzalez
    --Se modifica para que se marquen sin exepcion todos los indicadores
    --Se adapta al esquema de BD que esta en produccion
    --Se elimina validacion para insercion o actualizacion ahora solo se debera actualizar a peticion del cliente
	--------------------------------------------------------       
    --Modificó: Lorenzo Ibarra Garcia
    --Fecha: 08-10-2009
    --Se agregó la inserción a la tabla de la bitacora.
    -------------------------------------------------------- 
    --Modificó: José Almeida
    --Fecha: 18/11/2009
    --Se forzan los select para que tomen un indice a exepcion del select a sd_maecred ya que toma el indice creado por las llaves
    --y no es necesario forzarlo

	BEGIN
	    ON EXCEPTION SET v_sqlerr, v_isam_err, v_error_info
			IF v_sqlerr <> 0 THEN
				ROLLBACK WORK;
				LET v_codret = v_sqlerr;
				LET v_mensaje = v_error_info;
                
                --insertar control de procesos
                INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
                VALUES(cNombreProceso, v_codret, v_mensaje, USER, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
                cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
                
				RETURN v_codret, v_mensaje;
			END IF;
		END EXCEPTION;
        
        --validar que los parametros se hayan pasado correctamente
		IF pMes < 1 OR pMes > 12 OR pMes IS NULL OR pMes = '' OR pAnio IS NULL OR pAnio = '' THEN
			LET v_codret = '99999';
			LET v_mensaje = 'Parametros no validos';
			RETURN v_codret, v_mensaje;
		END IF;
        
        --insertar control de procesos
        INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
        VALUES(cNombreProceso, v_codret, v_mensaje, USER, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

		--SET ISOLATION DIRTY READ;
       -- set explain on;
		BEGIN WORK;
       
         --validar el mes y el anio para cuando sea de un año anterior
        IF pMes = 1 THEN
            LET iMesAnterior = 12;
            LET iAnio = pAnio - 1;
        ELSE
            LET iMesAnterior = pMes - 1;
            LET iAnio = pAnio;
        END IF;

        --recuperar cada credito con indicador de comportamiento generado
		FOREACH
			SELECT num_credito
			INTO  v_NumCredito
            FROM bdimonitorcob:mc_masterestad
			GROUP BY num_credito
            
            -- se obtiene status del credito
            LET cStatusCredito = '';
              SELECT status_cred
                INTO cStatusCredito
                FROM bdicred:sd_maecred
                WHERE empresa = v_Empresa
                AND num_credito = v_NumCredito;

            IF cStatusCredito = 'CV' THEN
                -- se obtiene fecha de venta del credito
                SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(max(fecha_mov),'01/01/1900'::date) INTO dFechaVenta
                        FROM bdicred:sd_movhis WHERE empresa = v_Empresa and num_credito = v_NumCredito
                        AND codigo_fun IN ('444', '041');
                 LET fecha_fin = dFechaVenta;
            --se valida si el credito ya fue vendido (status CV)
            END IF;
            IF cStatusCredito = 'CV' AND dFechaCorte >= dFechaVenta THEN
                LET iResultadoIndicador = 94;
            ELSE
            
                -- validar si existen meses de atraso
                LET iMesAux             = pMes;
                LET iAnioAux            = pAnio;
                LET iRetraso            = 1;
                LET iMesesAtraso        = 0;

                WHILE iRetraso = 1
                    IF EXISTS(SELECT {+INDEX( bdicred:sd_amortiza_credito amorst)} num_credito FROM bdicred:sd_amortiza_credito WHERE empresa = v_Empresa
                              AND num_credito = v_NumCredito AND capital_status in(7,2,6)
                              AND fecha_cuota = iMesAux || '-' || '20' || '-' || iAnioAux) THEN
                              
                          LET iMesesAtraso = iMesesAtraso + 1;

                          IF iMesAux = 1 THEN
                                LET iMesAux = 12;
                                LET iAnioAux = iAnioAux - 1;
                          ELSE
                                LET iMesAux = iMesAux - 1;
                                LET iAnioAux = iAnioAux;
                          END IF;
                    ELSE
                        LET iRetraso = 0;
                    END IF;
                END WHILE;

                IF iMesesAtraso > 0 then
                    LET iResultadoIndicador = iMesesAtraso;
                ELSE

                    --obtener el saldo del credito del mes
                    SELECT {+INDEX(bdicred:sd_maesdoshist idx_maesdishist1)} NVL(SUM(sdo_capital) +
                        SUM(monto_vencido) +
                        SUM(mto_venc_trasp) +
                        SUM(cap_tras_no_venci), 0)
                        INTO dSaldoActual
                        FROM bdicred:sd_maesdoshist
                        WHERE empresa = v_Empresa
                        AND num_credito = v_NumCredito
                        and fecha= pMes || '-' || '20' || '-' || pAnio;


                    --validar que se haya usado el credito en el mes
                    SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(num_credito)
                        into iCreditoUsado
                        FROM bdicred:sd_movhis 
                        WHERE num_credito = v_NumCredito
                        AND empresa = v_Empresa
                        AND codigo_fun = '002'
                        AND reversado = 'N'
                        and fecha_mov > iMesAnterior || '-' || '20' || '-' || iAnio
                        and fecha_mov <= pMes || '-' || '20' || '-' || pAnio;

                    IF dSaldoActual <= 0 THEN

                        IF iCreditoUsado = 0 THEN
                            LET iResultadoIndicador = 0;
                        ELSE
                            LET iResultadoIndicador = 92;
                        END IF;

                    ELSE
                        IF iCreditoUsado = 0 THEN
                            LET iResultadoIndicador = 93;
                        ELSE
                            LET iResultadoIndicador = 91;
                        END IF;

                    END IF;

                END IF
            END IF;            
            
            
            
            IF pMes = 1 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET ene = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 2 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET feb = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 3 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET mar = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 4 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET abr = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 5 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET may = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 6 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET jun = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 7 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET jul = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 8 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET ago = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 9 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET sep = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 10 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET oct = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 11 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET nov = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            ELIF pMes = 12 THEN
                UPDATE bdimonitorcob:mc_detestadmes SET dic = iResultadoIndicador, fecha_ejecucion = current WHERE empresa = v_Empresa
                    AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = v_NumCredito;
            END IF;
			
		END FOREACH;

        COMMIT WORK;
        
        LET v_codret = '00000';
        LET v_mensaje = 'PROCESO EXITOSO';
        --insertar control de procesos
        INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
        VALUES(cNombreProceso, v_codret, v_mensaje, USER, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
        
        RETURN v_codret, v_mensaje;
        
	END
END PROCEDURE;