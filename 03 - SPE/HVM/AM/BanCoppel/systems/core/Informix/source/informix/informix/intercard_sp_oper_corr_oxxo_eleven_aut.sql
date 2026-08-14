CREATE PROCEDURE "informix".sp_oper_corr_oxxo_eleven_aut()
RETURNING CHAR(5) as cod_ret, VARCHAR(50) as mensaje;

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         VARCHAR(50);
    DEFINE vcodret1         VARCHAR(5);
    DEFINE vcodret2         VARCHAR(65);
    DEFINE vcodret3         VARCHAR(50);
	DEFINE dFecha_inicio_extendida DATETIME YEAR TO FRACTION(5);
	DEFINE dFecha_fin_extendida DATETIME YEAR TO FRACTION(5);
	DEFINE CONTADOR_TRANSACCIONES INTEGER;

	DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(20);

	DEFINE NOMBRE_ARCHIVO_MCO_CONCI_APLI VARCHAR(29);
	DEFINE NOMBRE_ARCHIVO_MOVIMIENTOS VARCHAR(29);
	DEFINE NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN VARCHAR(31);
	DEFINE NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE VARCHAR(36);
	DEFINE RUTA_ORIGEN 		VARCHAR(70);
	DEFINE SCRIPT_EJECUCION_MCO_CONCI_APLI VARCHAR(35);
	DEFINE SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN VARCHAR(37);
	DEFINE SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE VARCHAR(42);
	DEFINE SCRIPT_EJECUCION_MOVIMIENTOS VARCHAR(35);
	DEFINE cRutaInformix 	VARCHAR(100);
	DEFINE PREFIJO_ARCHIVO  VARCHAR(9);
	DEFINE vRutadbload 		VARCHAR (21);
	DEFINE vsql		        LVARCHAR(4000);
	DEFINE vMes_actual 		VARCHAR(2);
	DEFINE iNum_trama		INTEGER;
	DEFINE vUltimo_dia_mes  VARCHAR(2);
	DEFINE dRango_dias_inicio DATE;
	DEFINE dRango_dias_inicio_ext DATETIME YEAR TO FRACTION(5);
	DEFINE dRango_dias_fin DATE;
	DEFINE dRango_dias_fin_ext DATETIME YEAR TO FRACTION(5);
	DEFINE dUltimo_dia_mes DATE;
	DEFINE dUltimo_dia_mes_acum DATE;
	DEFINE dUltimo_dia_mes_acum_ext DATETIME YEAR TO FRACTION(5);
	
	
	DEFINE RUTA_DESTINO 	VARCHAR(14);
	DEFINE TIPO_PLANTILLA   VARCHAR(30);
	DEFINE vExecuteSQL      LVARCHAR(5000);
	
	LET dFecha_inicio_extendida ='';
	LET dFecha_fin_extendida ='';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '00000';
    LET vcodret2 = '';
    LET vcodret3 = 'Se generaron archivos corresponsal OXXO y 7Eleven';
	LET CONTADOR_TRANSACCIONES = 1000;
	
	LET RUTA_ORIGEN = '/RESPALDOSNEW/';
	LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
	LET NOMBRE_ARCHIVO_MCO_CONCI_APLI = 'file_registros_mco_conci_apli';
	LET NOMBRE_ARCHIVO_MOVIMIENTOS = 'file_registros_movimientos';
	LET NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN = 'file_registros_cruce_oxxo_seven';
	LET NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE ='file_registros_descuadre_num_cliente';
	LET SCRIPT_EJECUCION_MCO_CONCI_APLI = 'script_registros_mco_conci_apli.sql';
	LET SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN = 'script_registros_cruce_oxxo_seven.sql';
	LET SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE ='script_registros_descuadre_num_cliente.sql';
	LET SCRIPT_EJECUCION_MOVIMIENTOS = 'script_registros_movimientos.sql';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET PREFIJO_ARCHIVO = 'movs_reg_';
	LET vRutadbload = '/ifxsif01/bin/dbload';
	LET iNum_trama = 1;
	LET vUltimo_dia_mes ='';
	LET dRango_dias_inicio ='';
	LET dRango_dias_fin = '';
	LET vsql ='';
    LET RUTA_DESTINO   = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA = 'corr_oxxo_eleven';
	LET dUltimo_dia_mes_acum ='';
	LET dUltimo_dia_mes_acum_ext ='';
	LET vExecuteSQL = '';
	
	
	BEGIN

				ON EXCEPTION SET sql_err, isam_err, desc_err
					SET DEBUG FILE TO RUTA_ORIGEN || "sp_oper_corr_oxxo_eleven.err.out";
					--TRACE ON;
					IF sql_err <> 0 THEN
						LET vcodret1 = sql_err;
						LET vcodret2 = isam_err;
						--LET vcodret3 = desc_err;
						RETURN vcodret1, vcodret2;
					END IF;
				END EXCEPTION;
				
		--SET DEBUG FILE TO "/ifxsif01/ilopez/Corresponsales_OXXO_7ELEVEN/SPL/sp_oper_corr_oxxo_eleven.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	--ARCHIVOS OXXO--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_fin = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_fin = dRango_dias_fin -1 UNITS MONTH;
	LET dRango_dias_fin = LPAD(MONTH(dRango_dias_fin),2,0)||'/'||'05'||'/'||YEAR(dRango_dias_fin);
	
	
	
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) ||'-'|| LPAD ( MONTH(dRango_dias_fin), 2, '0')||'-'||LPAD(DAY(dRango_dias_fin), 2, '0')||' 23:59:59.99999';
			
	
	LET dUltimo_dia_mes = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes = dUltimo_dia_mes -1 UNITS MONTH;
	LET dUltimo_dia_mes = LPAD(MONTH(dUltimo_dia_mes),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes))||'/'||YEAR(dUltimo_dia_mes);
	
	--Para probar otros meses
	--LET dRango_dias_inicio ='10012022';
	--LET dRango_dias_inicio_ext = '2022-10-01 00:00:00.00000';
	--LET dRango_dias_fin_ext = '2022-10-05 23:59:59.99999';
	--LET dRango_dias_fin = '10052022';

	LET iNum_trama = 1;
	WHILE (iNum_trama <= 6) LOOP
		
		    IF iNum_trama < 6 THEN 
				
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_oxxo'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_oxxo'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"02\" '||

					   '" >'||RUTA_DESTINO||'script_oxxo_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_oxxo_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_oxxo'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_oxxo'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_oxxo'||'.txt';
		    system vsql;
			
			
			LET dRango_dias_inicio = dRango_dias_fin +1 UNITS DAY;
			LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio) || '-' || LPAD ( MONTH(dRango_dias_inicio), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_inicio), 2, '0') || ' 00:00:00.00000';

			LET dRango_dias_fin = dRango_dias_inicio +4 UNITS DAY;
			LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) || '-' || LPAD ( MONTH(dRango_dias_fin), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_fin), 2, '0') || ' 23:59:59.99999';

			ELSE 
			
			LET dRango_dias_inicio = dRango_dias_inicio;
			LET dRango_dias_fin = dRango_dias_fin;
			LET dRango_dias_inicio_ext = dRango_dias_inicio_ext;
			LET dRango_dias_fin_ext = YEAR(dUltimo_dia_mes) || '-' || LPAD ( MONTH(dUltimo_dia_mes), 2, '0') || '-' ||DAY(dUltimo_dia_mes)|| ' 23:59:59.99999';
			
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_oxxo'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_oxxo'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"02\" '||

					   '" >'||RUTA_DESTINO||'script_oxxo_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_oxxo_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_oxxo'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_oxxo'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_oxxo'||'.txt';
		    system vsql;
			
				
			END IF;
			
			LET iNum_trama = iNum_trama + 1;
			LET iNum_trama = iNum_trama ;
			
	END LOOP;
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--ARCHIVOS 7ELEVEN--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LET dRango_dias_inicio ='';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_fin = '';
	LET dRango_dias_fin = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_fin = dRango_dias_fin -1 UNITS MONTH;
	LET dRango_dias_fin = LPAD(MONTH(dRango_dias_fin),2,0)||'/'||'05'||'/'||YEAR(dRango_dias_fin);
	
	
	LET dRango_dias_inicio_ext ='';
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dRango_dias_fin_ext = '';
	LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) ||'-'|| LPAD ( MONTH(dRango_dias_fin), 2, '0')||'-'||LPAD(DAY(dRango_dias_fin), 2, '0')||' 23:59:59.99999';
	
	LET dUltimo_dia_mes = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes = dUltimo_dia_mes -1 UNITS MONTH;
	LET dUltimo_dia_mes = LPAD(MONTH(dUltimo_dia_mes),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes))||'/'||YEAR(dUltimo_dia_mes);
	--Para probar otros meses
	--LET dRango_dias_inicio ='10012022';
	--LET dRango_dias_inicio_ext = '2022-10-01 00:00:00.00000';
	--LET dRango_dias_fin_ext = '2022-10-05 23:59:59.99999';
	--LET dRango_dias_fin = '10052022';
	
	
	LET iNum_trama = 1;
	WHILE (iNum_trama <= 6) LOOP
		
		    IF iNum_trama < 6 THEN 
				
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_eleven'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_eleven'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"03\" '||

					   '" >'||RUTA_DESTINO||'script_eleven_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_eleven_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_eleven'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_eleven'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_eleven'||'.txt';
		    system vsql;
			
			
			LET dRango_dias_inicio = dRango_dias_fin +1 UNITS DAY;
			LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio) || '-' || LPAD ( MONTH(dRango_dias_inicio), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_inicio), 2, '0') || ' 00:00:00.00000';

			LET dRango_dias_fin = dRango_dias_inicio +4 UNITS DAY;
			LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) || '-' || LPAD ( MONTH(dRango_dias_fin), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_fin), 2, '0') || ' 23:59:59.99999';

			ELSE 
			
			LET dRango_dias_inicio = dRango_dias_inicio;
			LET dRango_dias_fin = dRango_dias_fin;
			LET dRango_dias_inicio_ext = dRango_dias_inicio_ext;
			LET dRango_dias_fin_ext = YEAR(dUltimo_dia_mes) || '-' || LPAD ( MONTH(dUltimo_dia_mes), 2, '0') || '-' ||DAY(dUltimo_dia_mes)|| ' 23:59:59.99999';
			
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_eleven'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_eleven'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"03\" '||

					   '" >'||RUTA_DESTINO||'script_eleven_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_eleven_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_eleven'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_eleven'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_eleven'||'.txt';
		    system vsql;
			
				
			END IF;
			
			LET iNum_trama = iNum_trama + 1;
			LET iNum_trama = iNum_trama ;
			
	END LOOP;
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_inicio_ext = '';
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';

	--ACUMULADO OXXO
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	--Para probar otros meses
	--LET dRango_dias_inicio ='11012022';
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';
	
	
	
			let vsql = ''; 	   
			let vsql = 'echo "Fecha_Archivo|Fecha_txn|Total_txn|Monto_total|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_oxxo_acumulado'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_acumulado_oxxo'||'.txt   '||
			           ' SELECT fecha_archivo,SUBSTR(fechahorainauth,1,10),COUNT(*),SUM(montomov)'||
					   ' FROM intercard:mco_conciliacion_aplicativos '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
					   ' AND idreceptor = \"02\" '||
					   ' GROUP BY 1,2 ORDER BY fecha_archivo '||

					   '" >'||RUTA_DESTINO||'script_reg_oxxo_acum.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_reg_oxxo_acum.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_reg_oxxo_acum.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_acumulado_oxxo'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_oxxo_acumulado'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_reg_oxxo_acum.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_acumulado_oxxo'||'.txt';
		    system vsql;
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';

	--ACUMULADO ELEVEN
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	
	
	--Para probar otros meses
	--LET dRango_dias_inicio ='11012022';
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';
	
			let vsql = ''; 	   
			let vsql = 'echo "Fecha_Archivo|Fecha_txn|Total_txn|Monto_total|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_eleven_acumulado'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_acumulado_eleven'||'.txt   '||
			           ' SELECT fecha_archivo,SUBSTR(fechahorainauth,1,10),COUNT(*),SUM(montomov)'||
					   ' FROM intercard:mco_conciliacion_aplicativos '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
					   ' AND idreceptor = \"03\" '||
					   ' GROUP BY 1,2 ORDER BY fecha_archivo '||

					   '" >'||RUTA_DESTINO||'script_reg_eleven_acum.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_reg_eleven_acum.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_reg_eleven_acum.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_acumulado_eleven'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_eleven_acumulado'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_reg_eleven_acum.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_acumulado_eleven'||'.txt';
		    system vsql;
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--CREAR INFORMACIÃN DE ACLARACIÃN PARA OPERACIONES
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
		
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	
	--Para probar otros meses
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';
	
	--Cargar tabla tmp_mco_oxxo_seven
	TRUNCATE TABLE tmp_mco_oxxo_seven;
	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MCO_CONCI_APLI||'.unl'||
			' SELECT fecha_archivo,id_procesador,secuencia,autorizacion,numtarjeta,numcuenta,montomov,monto_mco,monto_cheq_cred,secuenciaextendida,montorealrevfzda,codreversa,tipo_txn,prodind,formato,codtran,'||
			' metodocaptura,idterminal,infreceptor,esnacional,pais,fechahorainauth,fechaconciliacion,fecha,hora,producto,tbl_mov,tbl_mco,tbl_movhis,resultado_final,cobro_comision,idreceptor'||
			' FROM intercard:mco_conciliacion_aplicativos   ' ||            
			' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||

			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MCO_CONCI_APLI||'.unl'|| "' delimiter '|' "|| '32'||                          
						  "; INSERT INTO tmp_mco_oxxo_seven" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_mco_conci_apli.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_mco_conci_apli.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_mco_conci_apli.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MCO_CONCI_APLI||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
		
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --Cargar Tabla tmp_mov_oxxo_seven
	
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
		
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	
	--Para probar otros meses
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';

	TRUNCATE TABLE tmp_mov_oxxo_seven;
	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MOVIMIENTOS||'.unl'||
			' SELECT secuencia, numtarjeta, monto, secuenciaextendida, montorealrevfzda, codreversa, prodind, formato,'||
			' codtran, metodocaptura, idterminal, infreceptor, esnacional, pais, fechahorainauth, idreceptor,'||
			' CASE WHEN idreceptor = ''02'' THEN SUBSTR(infreceptor, 17, 6)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' WHEN idreceptor =''03'' THEN SUBSTR(idterminal, 1, 5)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' END folio_suc_mov'||
			' FROM intercard:movimientohistorico   ' ||            
			' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
			' AND prodind = \"02\" '||
			' AND formato = \"0200\" '||
			' AND codigoiso = \"00\" '||
			' AND codtran = \"28\" '||
			' AND transaccionorigen = \"2345\" '||
			' AND codreversa = \"0\" '||
			' AND movreversado = \"F\" '||
			
			'UNION ALL '||
			
			' SELECT secuencia, numtarjeta, monto, secuenciaextendida, montorealrevfzda, codreversa, prodind, formato,'||
			' codtran, metodocaptura, idterminal, infreceptor, esnacional, pais, fechahorainauth, idreceptor,'||
			' CASE WHEN idreceptor = ''02'' THEN SUBSTR(infreceptor, 17, 6)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' WHEN idreceptor =''03'' THEN SUBSTR(idterminal, 1, 5)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' END folio_suc_mov'||
			' FROM intercard:movimiento   ' ||            
			' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
			' AND prodind = \"02\" '||
			' AND formato = \"0200\" '||
			' AND codigoiso = \"00\" '||
			' AND codtran = \"28\" '||
			' AND transaccionorigen = \"2345\" '||
			' AND codreversa = \"0\" '||
			' AND movreversado = \"F\" '||
		
			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MOVIMIENTOS||'.unl'|| "' delimiter '|' "|| '17'||                          
						  "; INSERT INTO tmp_mov_oxxo_seven " || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_movimientos.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_movimientos.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_registrar_movimientos.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MOVIMIENTOS||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---Realizar el cruce entre tmp_mov_oxxo_seven vs tmp_mco_oxxo_seven.
	---El resultado obtenido meterlo en una tabla temporal.
	
	TRUNCATE TABLE descuadre_oxxo_seven;

	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN||'.unl'||
			' SELECT a.secuencia, a.numtarjeta,a.monto,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.prodind,a.formato,'||
			' a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.idreceptor,a.folio_suc_mov'||
			' FROM intercard:tmp_mov_oxxo_seven a LEFT JOIN tmp_mco_oxxo_seven b   ' ||            
			' ON a.numtarjeta = b.numtarjeta   ' ||
			' AND a.monto = b.montomov   ' ||
			' AND a.secuenciaextendida = b.secuenciaextendida  ' ||
			' WHERE b.secuenciaextendida IS NULL'||
					
			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN||'.unl'|| "' delimiter '|' "|| '17'||                          
						  "; INSERT INTO descuadre_oxxo_seven" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_cruce_oxxo_seven.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_cruce_oxxo_seven.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_registrar_cruce_oxxo_seven.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
		
	--Se obtiene el nÃºmero de cliente-----------------------------------------------------------------------------------------------------------------------------------
	
	TRUNCATE TABLE descuadre_oxxo_seven_num_cliente;

	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE||'.unl'||
			' SELECT a.numcliente,b.secuencia,b.numtarjeta,b.monto,b.secuenciaextendida,b.montorealrevfzda,b.codreversa,b.prodind,b.formato,'||
				   ' b.codtran,b.metodocaptura,b.idterminal,b.infreceptor,b.esnacional,b.pais,b.fechahorainauth,b.idreceptor,b.folio_suc_mov'||
				   ' FROM descuadre_oxxo_seven b, intercard:tarjeta a '||
				   ' WHERE a.numtarjeta=b.numtarjeta '||
					
			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE||'.unl'|| "' delimiter '|' "|| '18'||                          
						  "; INSERT INTO descuadre_oxxo_seven_num_cliente" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_descuadre_num_cliente.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_descuadre_num_cliente.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_registrar_descuadre_num_cliente.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	--Para probar otro mes
	--LET dRango_dias_inicio = '11012022';
	------------------------------------------------------------------------------------------------------------------------
	--Se genera el archivo de aclaraciÃ³n de descuadre OXXO 7ELEVEN
	 ----------------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Secuencia|Num_tarjeta|Num_cuenta|Monto|Secuencia_extendida|Montorealrevfzda|Codreversa|Proind|Formato|Cod_tran|Metodo_captura|Id_terminal|Inf_receptor|Esnacional|Pais|Fechahorainauth|Idreceptor|Folio_suc_mov|  ">'||RUTA_DESTINO||'Aclaracion_oxxo_eleven_'||TO_CHAR(dRango_dias_inicio,"%b")||YEAR(dRango_dias_inicio)||'.txt';
			system vsql;
			
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_aclaracion'||'.txt   '||
			           ' SELECT DISTINCT(a.num_cliente),a.secuencia,a.numtarjeta,b.numcuenta,a.monto,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.prodind,a.formato, '||
					   ' a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.idreceptor,a.folio_suc_mov '||
					   ' FROM descuadre_oxxo_seven_num_cliente a LEFT JOIN  intercard:mco_conciliacion_aplicativos b '||
					   ' on a.numtarjeta=b.numtarjeta '||
			
					   '" >'||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';
            system vsql;	 
            -----------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_aclaracion'||".txt >> "||RUTA_DESTINO||'Aclaracion_oxxo_eleven_'||TO_CHAR(dRango_dias_inicio,"%b")||YEAR(dRango_dias_inicio)||'.txt';
            system vsql; 
            -----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_aclaracion'||'.txt';
		    system vsql;
	
	
	
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	END;

	RETURN vcodret1, vcodret3;

END PROCEDURE;