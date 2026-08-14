CREATE PROCEDURE "informix".sp_paseahist_movimientos_con_mc(psCve_Usuario VARCHAR(10))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(90);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(90);
	define  vdfechafin       date;	
    define  iDias            integer;	
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define vconsecutivo integer;
	define vnombrearchivo char(30);
	define varchivo_origen char(3);
	define vid_procesador varchar(5);
	define vfechacarga datetime year to fraction(3);
	define vintegridad char(1);
	define vintegridad_error char(20);
	define vnumtarjeta char(16);
	define vban_bin char(3);
	define vsecuencia325 char(6);
	define vmonto325 decimal(12,2);
	define vmontocashback325 char(13);
	define vmontosurcharge325 char(13);
	define vnumcuenta char(20);
	define vestransfer char(1);
	define vidcomercio325 char(15);
	define vnomcomercio325 char(30);
	define vtipotransaccion325 char(15);
	define vreferencia23_325 char(23);
	define vrfc325 char(15);
	define vdivisa325 char(3);
	define vmonto_divisa325 decimal(12,2);
	define viso323 char(2);
	define vmovrev325 char(1);
	define vconciliacion char(1);
	define vsecuencia char(7);
	define vsecuencia_extendida char(15);
	define vcodgironeg char(4);
	define vmontointercard money(16,2);
	define vmontocashback money(16,2);
	define vfechatransaccion datetime year to fraction(5);
	define vinfreceptor char(40);
	define vidterminal char(16);
	define vmetodocaptura char(2);
	define vmovconciliado char(1);
	define vmovreversado char(1);
	define vtipo_mov char(1);
	define vfolio_mov char(16);
	define vfechaconcilia datetime year to fraction(5);
	define vtipo_conciliacion integer;
	define vdesc_conciliacion char(60);
	define vb_aplica char(1);
	define vaplicacion char(1);
	define vtransaccion_aplica char(4);
	define vbandera_proceso char(1);
	define vcod_retorno char(5);
	define vfechaaplica datetime year to fraction(5);
	define vcve_usuario char(10);
	define vfinalizado char(1);
	define vsec_extendida_archivo char(15);
    define vres CHAR(5);	
    --SET DEBUG FILE TO "/RESPALDOSNEW/case/ss_conciliacionautomatica_mc/trans_mov_mc_to_hist.out";
    --TRACE ON; 
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
	
        EXECUTE PROCEDURE sp_bit_conc_hist_mc(51,P_COD_RET||'-'||P_MENSAJE,psCve_usuario) INTO vres;
        RETURN   P_COD_RET,P_MENSAJE;
    END EXCEPTION;

--************************************************************
-- Creado por Softtek case3 
-- fecha :Marzo/2024 
-- Funcion: Borrado de registros de tablas productivas MasterdCard  
--************************************************************
	
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	
	
	let p_cod_ret = '00000';
	let p_mensaje = 'PROCESO EXITOSO TRANSFERENCIA DE MOVIMIENTOS DE CONCILIACION MASTERCARD A HISTORICOS';

    EXECUTE PROCEDURE sp_bit_conc_hist_mc(51,'Inicia proceso de pase de movimientos de concilicaciÃ³n MC a historico',psCve_usuario) into vres;

    SELECT valor INTO iDias FROM bditarjeta:"informix".td_param_conciliacion_mc WHERE codigo = '356';


    IF (iDias == 0) THEN
       LET P_COD_RET = '00000';
       LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';
    ELSE

	set isolation to dirty read;
		foreach cusor1 with hold
				for    
            SELECT  
				consecutivo,
				nombrearchivo,
				archivo_origen,
				id_procesador,
				fechacarga,
				integridad,
				integridad_error,
				numtarjeta,
				ban_bin,
				secuencia325,
				monto325,
				montocashback325,
				montosurcharge325,
				numcuenta,
				estransfer,
				idcomercio325,
				nomcomercio325,
				tipotransaccion325,
				referencia23_325,
				rfc325,
				divisa325,
				monto_divisa325,
				iso323,
				movrev325,
				conciliacion,
				secuencia,
				secuencia_extendida,
				codgironeg,
				montointercard,
				montocashback,
				fechatransaccion,
				infreceptor,
				idterminal,
				metodocaptura,
				movconciliado,
				movreversado,
				tipo_mov,
				folio_mov,
				fechaconcilia,
				tipo_conciliacion,
				desc_conciliacion,
				b_aplica,
				aplicacion,
				transaccion_aplica,
				bandera_proceso,
				cod_retorno,
				fechaaplica,
				cve_usuario,
				finalizado,
				sec_extendida_archivo
            INTO 
       			vconsecutivo,
			    vnombrearchivo,
     		    varchivo_origen,
			    vid_procesador,
    			vfechacarga,
    			vintegridad,
    			vintegridad_error,
    			vnumtarjeta,
    			vban_bin,
    			vsecuencia325,
    			vmonto325,
    			vmontocashback325,
    			vmontosurcharge325,
    			vnumcuenta,
    			vestransfer,
    			vidcomercio325,
    			vnomcomercio325,
    			vtipotransaccion325,
    			vreferencia23_325,
    			vrfc325,
    			vdivisa325,
    			vmonto_divisa325,
    			viso323,
    			vmovrev325, 
    			vconciliacion,
    			vsecuencia,
    			vsecuencia_extendida,
    			vcodgironeg,
    			vmontointercard,
    			vmontocashback,
    			vfechatransaccion,
    			vinfreceptor,
    			vidterminal,
    			vmetodocaptura,
    			vmovconciliado,
    			vmovreversado,
    			vtipo_mov,
    			vfolio_mov,
    			vfechaconcilia,
    			vtipo_conciliacion,
    			vdesc_conciliacion,
    			vb_aplica,
    			vaplicacion,
    			vtransaccion_aplica,
   				vbandera_proceso,
  			    vcod_retorno,
  			    vfechaaplica,
    			vcve_usuario,
   				vfinalizado,
    			vsec_extendida_archivo
            FROM BdiTarjeta:td_movimientos_conciliacion_mc
                WHERE date(fechacarga) <= TODAY -iDias 
			
			if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
			--  Inserta datos en la tabla historica
            INSERT INTO BdiTarjeta:td_movimientos_conciliacion_hist_mc
				(consecutivo,
				nombrearchivo,
				archivo_origen,
				id_procesador,
				fechacarga,
				integridad,
				integridad_error,
				numtarjeta,
				ban_bin,
				secuencia325,
				monto325,
				montocashback325,
				montosurcharge325,
				numcuenta,
				estransfer,
				idcomercio325,
				nomcomercio325,
				tipotransaccion325,
				referencia23_325,
				rfc325,
				divisa325,
				monto_divisa325,
				iso323,
				movrev325,
				conciliacion,
				secuencia,
				secuencia_extendida,
				codgironeg,
				montointercard,
				montocashback,
				fechatransaccion,
				infreceptor,
				idterminal,
				metodocaptura,
				movconciliado,
				movreversado,
				tipo_mov,
				folio_mov,
				fechaconcilia,
				tipo_conciliacion,
				desc_conciliacion,
				b_aplica,
				aplicacion,
				transaccion_aplica,
				bandera_proceso,
				cod_retorno,
				fechaaplica,
				cve_usuario,
				finalizado,
				sec_extendida_archivo)
		 values(
				vconsecutivo,
				vnombrearchivo,
				varchivo_origen,
				vid_procesador,
				vfechacarga,
				vintegridad,
				vintegridad_error,
				vnumtarjeta,
				vban_bin,
				vsecuencia325,
				vmonto325,
				vmontocashback325,
				vmontosurcharge325,
				vnumcuenta,
				vestransfer,
				vidcomercio325,
				vnomcomercio325,
				vtipotransaccion325,
				vreferencia23_325,
				vrfc325,
				vdivisa325,
				vmonto_divisa325,
				viso323,
				vmovrev325,
				vconciliacion,
				vsecuencia,
				vsecuencia_extendida,
				vcodgironeg,
				vmontointercard,
				vmontocashback,
				vfechatransaccion,
				vinfreceptor,
				vidterminal,
				vmetodocaptura,
				vmovconciliado,
				vmovreversado,
				vtipo_mov,
				vfolio_mov,
				vfechaconcilia,
				vtipo_conciliacion,
				vdesc_conciliacion,
				vb_aplica,
				vaplicacion,
				vtransaccion_aplica,
				vbandera_proceso,
				vcod_retorno,
				vfechaaplica,
				vcve_usuario,
				vfinalizado,
				vsec_extendida_archivo
            );	
  
            --  Borra registro de la Tabla de Movimientos		
            DELETE FROM BdiTarjeta:td_movimientos_conciliacion_mc 
			where 	consecutivo = vconsecutivo   and
					nombrearchivo = vnombrearchivo and 
					archivo_origen = varchivo_origen and 
					fechacarga = vfechacarga;
				
			let vicontadorregistros = vicontadorregistros + 1;
			let vicontadorregistros2 = vicontadorregistros2 + 1;

			if (vicontadorregistros2 = 100000) then 
				update statistics medium for table bditarjeta:"informix".td_movimientos_conciliacion_hist_mc;           
				let vicontadorregistros2 = 0;
			end if;

			if (vicontadorregistros = 1000) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table bditarjeta:"informix".td_movimientos_conciliacion_hist_mc;      
				let vsflagentransaccion = 'F';
		end if;
		
    END IF;  	
    
	EXECUTE PROCEDURE sp_bit_conc_hist_mc(51,P_COD_RET||'-'||P_MENSAJE,psCve_usuario) INTO vres; 
    RETURN    P_COD_RET,P_MENSAJE;
END;

END PROCEDURE


;