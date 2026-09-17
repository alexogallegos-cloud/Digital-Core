CREATE PROCEDURE "informix".reverprov(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1),
				      pcuenta   char(20))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wcompend            money(14,2);
   DEFINE wtiptran            char(2);
   DEFINE wnum_serial         integer;
   DEFINE wtransacc           char(4);
   DEFINE wcuenta             char(20);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wmonto_tot1         money(14,2);
   DEFINE montoaux            money(14,2);
   DEFINE wfirme              money(14,2);
   DEFINE wen_sbc             money(14,2);
   DEFINE wremesas            money(14,2);
   DEFINE wdias_ret           smallint;
   DEFINE wnum_cheq           integer;
   DEFINE wimp_sbg_ccc        money(14,2);
   DEFINE wimp_chq_sbg        money(14,2);
   DEFINE wimp_int_ccc        money(14,2);
   DEFINE wimp_int_sbg        money(14,2);
   DEFINE wchq_exp_mes        smallint;
   DEFINE wnaturaleza         char(1);
   DEFINE wvalida_docto       char(1);
   DEFINE wtipo               char(1);
   DEFINE wsaldo_cuenta       money(14,2);
   DEFINE wsdo_actual         money(14,2);
   DEFINE wsdo_retenido       money(14,2);
   DEFINE wsdo_cong           money(14,2);
   DEFINE wmontoaux           money(14,2);
   DEFINE wlim_chq_sbc        money(14,2);
   DEFINE wimp_chq_sbc        money(14,2);
   DEFINE wlim_chq_rem        money(14,2);
   DEFINE wimp_chq_rem        money(14,2);
   DEFINE wreferencia         char(40);
   DEFINE wstatus_envio       char(1);
   DEFINE wrowid              integer;
   DEFINE wfechoy             date;
   DEFINE pfolio1             char(16);
   DEFINE wtpcheque           char(2);
   DEFINE wfechahora          datetime hour to fraction(3);
   DEFINE vtranusoccc         char(4);
   DEFINE vtrancancta         char(4);
   DEFINE vtranintccc         char(4);
   DEFINE vtranusosbg         char(4);
   DEFINE vtranintsbg         char(4);
   DEFINE wcomision           char(4);
   DEFINE wsuc_cuen           char(4);
   DEFINE wproducto           char(4);
   define vnum_tarjeta        char(16);
   define vmaxsec             smallint;
   DEFINE vProdCrec           CHAR(4);
   define vanio               char(6);
   --RQM 09 704. Se agregan las siguientes variable DFTL 
   define mSaldoSbc       MONEY(14,2);
   define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
   define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
   

   LET sql_err = 0;
   LET cod_ret = "000";
   --RQM 09 704. Se agregan las siguientes variable DFTL
   LET mSaldoSbc           = 0;
   LET cCodRetConsSdo      = '00000';
   LET cMensajeRetConsSdo  = '';


   BEGIN
      ON EXCEPTION
         SET sql_err, isam_err
         IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            RETURN cod_ret;
         END IF;
      END EXCEPTION;

      SELECT fecha_hoy into wfechoy
         FROM sc_fechas where empresa = pempresa;

      SELECT TRIM(valor)
        INTO vProdCrec
        FROM sc_param
       WHERE empresa = pempresa
         AND codparam ="PRODCREC";


      SELECT COUNT(*) INTO contador
         FROM sc_movhis m, bdinteg:si_transacc t
         WHERE m.empresa = pempresa and m.cuenta = pcuenta
	       and fech_alt ="01/02/2008"
	       and folio_suc = pfolio and
	       m.cuenta = pcuenta and
               m.empresa = t.empresa and m.transacc = t.numero and
               reversable = "S" and cancelad <> "S";

      IF (contador = 0) THEN
         SELECT COUNT(*) INTO contador
            FROM  sc_docret
            WHERE empresa = pempresa and folio_suc = pfolio and
                  fecha_alta = wfechoy;
         IF (contador = 0) THEN
            RETURN cod_ret;
         ELSE
            update sc_docret
               set cancelado = "S"
               WHERE empresa = pempresa and folio_suc = pfolio and
                     fecha_alta = wfechoy;
            RETURN cod_ret;
         end if
      end if

      select valor into vtrancancta
         from sc_param
         where empresa = pempresa and codparam = "trancancta";

      select valor into vtranusoccc
         from sc_param
         where empresa = pempresa and codparam = "tranusoccc";

      select valor into vtranintccc
         from sc_param
         where empresa = pempresa and codparam = "tranintccc";

      select valor into vtranusosbg
         from sc_param
         where empresa = pempresa and codparam = "tranusosbg";

      select valor into vtranintsbg
         from sc_param
         where empresa = pempresa and codparam = "tranintsbg";

      FOREACH
         select num_serial,transacc,cuenta,monto_tot,firme,en_sbc,remesas,
                md.dias_ret,num_cheq,naturaleza,valida_docto,tr.tipo_tran,
                referencia,suc_cuen,producto, aniomes
            into wnum_serial,wtransacc,wcuenta,wmonto_tot,wfirme,wen_sbc,
                 wremesas,wdias_ret,wnum_cheq,wnaturaleza,wvalida_docto,
                 wtiptran,wreferencia,wsuc_cuen,wproducto, vanio
            FROM sc_movhis md, bdinteg:si_transacc tr
            WHERE md.empresa = pempresa and folio_suc = pfolio and
		  md.cuenta = pcuenta
                  AND cancelad <> "S" and reversable = "S"
                  AND md.empresa = tr.empresa and numero = transacc
	--	  and transacc in ("3276", "3381")
            ORDER BY naturaleza desc
         select max(secuencia) into vmaxsec
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  tipo_tarjeta = "T";
         select num_tarjeta into vnum_tarjeta
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  secuencia = vmaxsec;
         LET wimp_sbg_ccc = 0;
         LET wimp_chq_sbg = 0;
         LET wimp_int_ccc = 0;
         LET wimp_int_sbg = 0;
         LET wchq_exp_mes = 0;
         let wcompend = 0;

         IF wtiptran = "01" THEN
            LET wchq_exp_mes  = 1;
         ELIF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
         ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
         ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
         ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
         ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            let wcomision = trim(wreferencia);
         END IF;
         select sdo_actual into wsdo_actual
            from sc_maechq
            where empresa = pempresa and cuenta = wcuenta;

         IF wnaturaleza = "C" THEN
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + wmonto_tot,
                   imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                   num_cgos_mes = num_cgos_mes - 1,
                   chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                   imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                   imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                   imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                   imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                   com_pendiente = com_pendiente + wcompend
               WHERE empresa = pempresa and cuenta = wcuenta;
            if wtransacc = vtrancancta then
               update sc_maechq
                  set status_cta = "1",
                      fec_cancelac = "",
                      motivo = " "
                  WHERE empresa = pempresa and cuenta = wcuenta;
            end if
            if wtiptran = "05" then
               update sc_detcomis
                  set pago_com = pago_com - wmonto_tot,
                      estado_com = "P"
                  where empresa = pempresa and cuenta = wcuenta and
                        comision = wcomision and fecult_pago = wfechoy;
            end if;
            if ptiporev = "A" then
               delete from sc_movhis
                  where num_serial = wnum_serial;
            else
               UPDATE sc_movhis
                  SET cancelad = "S"
                  WHERE num_serial = wnum_serial;
               INSERT INTO sc_movhis
                  VALUES(0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                      current hour to fraction(3),wtransacc,wsuc_cuen,
                      wproducto,pempresa,wcuenta," ",wnum_cheq,
                      wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                      "REV",0,vnum_tarjeta,"","");
            end if
            IF wtiptran = "01" THEN
               UPDATE sc_contch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
               UPDATE sc_histch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
            END IF;
         ELSE
            IF (wnaturaleza = "A") THEN
               LET wsaldo_cuenta       = 0;
               LET wsdo_actual         = 0;
               LET wsdo_retenido       = 0;
               LET wsdo_cong           = 0;

               SELECT sdo_actual, sdo_retenido, sdo_cong, saldo_sbc
                  INTO wsdo_actual,wsdo_retenido,wsdo_cong, mSaldoSbc
                  FROM sc_maechq
                  WHERE empresa = pempresa and cuenta = wcuenta;

               --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
               EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', wsdo_actual, wsdo_retenido, null, mSaldoSbc, null, null, null, 'F', 3)     
               INTO cCodRetConsSdo, cMensajeRetConsSdo, wsaldo_cuenta;

               IF wsaldo_cuenta < wfirme THEN
                  LET cod_ret = "413";
                  RETURN cod_ret;
               END IF;
               UPDATE sc_maechq
                  SET sdo_actual = sdo_actual - wmonto_tot,
                      sdo_retenido= sdo_retenido - wen_sbc,
                      imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                      imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                      num_abonos_mes = num_abonos_mes - 1,
                      imp_abonos_mes = imp_abonos_mes - wmonto_tot
                  WHERE  empresa = pempresa and cuenta = wcuenta;
               if wen_sbc > 0 then
                  update sc_docret
                     set cancelado = "S"
                     where empresa = pempresa and cuenta = wcuenta
                           and folio_suc = pfolio
                           and fecha_alta = wfechoy;
               end if;

	       IF vProdCrec = wproducto THEN
		 UPDATE sc_maechq
		    SET marca_ret = "0"
		  WHERE empresa = pempresa
		    AND cuenta = wcuenta;
	       END IF

               IF (cod_ret = "000") THEN
                  if ptiporev = "A" then
                     delete from sc_movhis
                        where num_serial = wnum_serial;
                  else
                     {UPDATE sc_movhis
                        SET cancelad = "S"
			WHERE cuenta = pcuenta
			  AND fech_alt = "01/02/2008"
                          AND num_serial = wnum_serial;}
                     INSERT INTO sc_movhistmp
                        VALUES(vanio, 0,pfolio,psucursal,pusuario,wfechoy,
			       wfechoy,
                           current hour to fraction(3),wtransacc,wsuc_cuen,
                           wproducto,pempresa,wcuenta," ",wnum_cheq,
                           wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                           "REV",0,vnum_tarjeta,"");
                  end if
               END IF;
            END IF;
         END IF;
      END FOREACH;
   END;
   RETURN cod_ret;
END PROCEDURE DOCUMENT "Version 1.00.000",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_prog_cierre()
    RETURNING CHAR(5) AS vCodRet1, CHAR(1000) AS vCodRet2, CHAR(1000) AS vCodRet3;

    DEFINE Sql_Err         INTEGER;
    DEFINE Isam_Err        INTEGER;
    DEFINE vCodRet1        CHAR(5);
    DEFINE vCodRet2        CHAR(1000);
    DEFINE vCodRet3        CHAR(1000);
    DEFINE vFechaHoy       DATE;
    DEFINE vTotal          INTEGER;
    DEFINE vOrigen         CHAR(4);
    DEFINE vDestino        CHAR(4);
	DEFINE vOrigen_c       CHAR(4);
    DEFINE vDestino_c      CHAR(4);
    DEFINE vestatus1       INTEGER;
    DEFINE vestatus0       INTEGER;
    DEFINE v_contador      INT;
    DEFINE v_contador2      INT;
    DEFINE iIsamErr        SMALLINT;
    DEFINE cDescErr        CHAR(80);
    DEFINE vsqlerr         INTEGER;
	DEFINE vErrorInfo      CHAR(80);
	DEFINE vstatus		   INTEGER;

    -- Retorno de SP interno
    DEFINE vRetCod         CHAR(5);
    DEFINE vRetMsg         CHAR(1000);
    DEFINE vRetDetalle     CHAR(1000);
    DEFINE vLog            CHAR(1000);
    DEFINE cErrorInfo      CHAR(80);
	DEFINE vstatus_maximo  CHAR(1);

    -- Acumulador de mensajes
    LET Sql_Err    = 0;
    LET Isam_Err   = 0;
    LET vCodRet1   = '00000';
    LET vCodRet2   = 'OPERACION EXITOSA';
    LET vCodRet3   = '';
    LET vLog       = 'No hay sucursales por procesar No hay registros con estatus 0 ni 1.';
    LET vestatus0  = 0;
    LET vestatus1  = 1;
    LET v_contador = 0;
    LET v_contador2 = 0;
    LET iIsamErr   = 0; 
    LET vsqlerr    = 0; 
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET cErrorInfo = "";   


    BEGIN


        ON EXCEPTION SET vsqlerr, iIsamErr, cDescErr
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_control_cierre_sucursal.err";
            TRACE ON;
            IF vsqlerr <> 0 THEN
                LET vCodRet1   = vsqlerr;
                LET vErrorInfo = cErrorInfo;
             RETURN vCodRet1, vCodRet2, vCodRet3;
            END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/RESPALDOSNEW/sp_cierre_reproceso.out";
		--TRACE ON;

   
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO vFechaHoy
        FROM informix.sc_fechas
        WHERE empresa = '001';
		
		--LET vFechaHoy = '07082025';

        -- Validar si hay registros con estatus 0 o 1
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus IN (0,1);

        IF vTotal = 0 THEN
            LET vCodRet3 = vLog;
			RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;

        -- Procesar estatus 0 y fecha = hoy
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 0 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
            FOREACH c0 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 0 AND fecha_proceso = vFechaHoy

                CALL sp_control_cierre_sucursal(vOrigen, vDestino)
                RETURNING vRetCod,vRetDetalle;
                
                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN
					
					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;
						
						
						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
				
				
					LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION  cierres con estatus 0 ' || vRetDetalle;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
					
                END IF;
                 LET v_contador = v_contador + 1;
            END FOREACH;
            LET vLog =   'Procesados cierres con estatus 0. ' || v_contador;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
        END IF;

        -- Procesar estatus 1 y fecha = hoy (reproceso)
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 1 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
 
			SELECT origen, destino
            INTO vOrigen, vDestino
            FROM sc_prog_cierre
            WHERE estatus = 1 AND fecha_proceso = vFechaHoy;
				
			SELECT 
				MAX(GREATEST(
					NVL(extrae_cuentas, 0),
					NVL(ejecuta_bdicheq, 0),
					NVL(ejecuta_bdibpi, 0),
					NVL(ejecuta_bdicred, 0),
					NVL(ejecuta_bdicred_crd, 0),
					NVL(ejecuta_bdinteg, 0),
					NVL(ejecuta_bdinvers, 0),
					NVL(ejecuta_bdisolic, 0),
					NVL(ejecuta_bdicheq_comp, 0)
				))  AS status_maximo
			INTO vstatus_maximo
			FROM sc_ctrl_cierre_suc
			WHERE sucursal_origen = vOrigen 
    		AND sucursal_destino = vDestino;

			
            LET v_contador = 0;
			
            FOREACH c1 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 1 AND fecha_proceso = vFechaHoy
				
                CALL sp_cierre_reproceso(vOrigen, vDestino,vstatus_maximo)
                RETURNING vRetCod, vRetMsg, vRetDetalle, vstatus;

                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN

					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;

						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
					
                    LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION Reprocesados cierres con estatus 1' || vRetDetalle;
                    LET vCodRet3 = 'Error en el bloque: ' || vstatus;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
                END IF;
                LET v_contador = v_contador + 1;
            END FOREACH;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente 
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
            LET vLog =  'Reprocesados cierres con estatus 1 : ' || v_contador;
        END IF;

        
        -- Resultado final
        LET vCodRet1 = '00000';
        LET vCodRet2 = 'EJECUCION COMPLETA';
        LET vCodRet3 = vLog;

        RETURN vCodRet1, vCodRet2, vCodRet3;

    END;

END PROCEDURE;