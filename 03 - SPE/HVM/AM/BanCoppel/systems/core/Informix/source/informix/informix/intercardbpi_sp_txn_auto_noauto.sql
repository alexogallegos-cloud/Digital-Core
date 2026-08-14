CREATE PROCEDURE "informix".sp_txn_auto_noauto
(
   pindica VARCHAR (1),---'1','2','3' descarga de transacciones autorizadas y '4' no autorizadas.
   primer_dia_mes_hora DATETIME YEAR TO FRACTION(5), ---parametro calculado el el SP sp_txrechazo
   ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5), ---parametro calculado el el SP sp_txrechazo
   vaniomes2 CHAR(6)---periodo al que pertenece la información aaaamm, parametro calculado el el SP sp_txrechazo
)
RETURNING VARCHAR(6), VARCHAR(80);
--------------------------------------
DEFINE vindica      VARCHAR(1);
DEFINE vcodret      VARCHAR(6);
DEFINE p_mensaje    VARCHAR(80);
DEFINE vsql         CHAR(8000); 
DEFINE vsqlerr		INTEGER;
DEFINE isam_err		INTEGER;
DEFINE error_info	VARCHAR(80);
DEFINE  vfecha_hoy  DATE;
DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;

--SET DEBUG FILE TO "/resplogifx/txn_auto.sql";
--TRACE ON;	
 

	BEGIN
       ON EXCEPTION SET vsqlerr, isam_err, error_info
            IF vsqlerr <> 0   THEN
                LET vcodret = vsqlerr;
                LET p_mensaje = error_info;
                RETURN vcodret, p_mensaje;
            END IF;
		END EXCEPTION;
        LET vindica =   pindica;
		IF (vindica IN('1','2','3','4'))
			THEN
			
			SET ISOLATION to dirty read;
SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechas;
let vfecha_hoy = vfecha_hoy;

--let vfecha_hoy = '09/02/2015'; 
			

					IF (vindica = '1') THEN
					
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
                       LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
                       LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
                       LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
					   
					   LET ultimo_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 9 units DAY;
                       LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 9 units DAY;
                       LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 23:59:59';
					
			           let primer_dia_mes_hora = primer_dia_mes_hora;
                       let ultimo_dia_mes_hora= ultimo_dia_mes_hora;
					
							/***********************************************************/
							-----Primera descarga de Transacciones Autorizadas
							/***********************************************************/
							LET vsql	=	'';
							LET vsql    =   'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/movs_aut_'||vaniomes2||'a.txt '||
											/*'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato, '||
											 '     codtran, fechaexptarj, codreversa, referencia, monto, infreceptor, '||
											 '     idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '|| 
											 '     metodocaptura, motivo, trancajeropropio, fechahorainauth, '||
											 '     DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
											 '     idretailer, secuenciaextendida '||
											'FROM intercard:movimiento '||
											'WHERE fechahorainauth  BETWEEN SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10)||''"'||' 00:00:00.0'||'"'' AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+9 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'    AND codigoiso = ''"'||'00'||'"'' '||
											'    AND formato NOT IN (''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'') '|| ---(0221)respuesta de compra forzada, (0420)reverso, (0421)respuesta de reverso---incluir 0200
											'    AND codtran NOT IN (''"'||'94'||'"'',''"'||'95'||'"'') '|| ---(94)Cambio de NIP, (95)Asignación de NIP
											'    AND codreversa = 0 '||
											' UNION ALL '||
											'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato, '||
											 '     codtran, fechaexptarj, codreversa, referencia, monto, infreceptor, '||
											 '     idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '|| 
											 '     metodocaptura, motivo, trancajeropropio, fechahorainauth, '||
											 '     DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
											 '     idretailer, secuenciaextendida '||
											'FROM intercard:movimientohistorico '||
											'WHERE fechahorainauth  BETWEEN SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10)||''"'||' 00:00:00.0'||'"'' AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+9 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'    AND codigoiso = ''"'||'00'||'"'' '||
											'    AND formato NOT IN (''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'') '|| ---(0221)respuesta de compra forzada, (0420)reverso, (0421)respuesta de reverso---incluir 0200
											'    AND codtran NOT IN (''"'||'94'||'"'',''"'||'95'||'"'') '|| ---(94)Cambio de NIP, (95)Asignación de NIP
											'    AND codreversa = 0; " >/resplogifx/txn_autorizadas.sql';*/





'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '2' ||'"'') then '||
'(montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
'idretailer, secuenciaextendida '||
'FROM intercard:movimiento '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
    'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
    'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
    'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
    'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
    'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
    'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
    'AND movreversado = ''"'||'F'||'"'' '||                                                 
    'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||
    'AND codigoiso = ''"'||'00'||'"'' '||
	
	'UNION ALL '||

	'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420' ||'"'' '||
'and codreversa = ''"'||'2' ||'"'') then '||
'(montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
'idretailer, secuenciaextendida '||
'FROM intercard:movimientohistorico '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
    'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
    'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
    'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
    'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
    'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
    'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
    'AND movreversado = ''"'||'F'||'"'' '||                                                 
    'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||
    'AND codigoiso = ''"'||'00'||'"'' '|| 
	'" >/resplogifx/txn_autorizadas.sql';
	
											
							SYSTEM vsql;
							LET vsql   =   '';
							LET vsql   =   'dbaccess intercard /resplogifx/txn_autorizadas.sql';
							SYSTEM vsql;
							LET vsql   = '';
							LET vsql   =	'rm /resplogifx/txn_autorizadas.sql';
							SYSTEM vsql; 
							LET vsql   =   '';
							LET vsql   =   'gzip -9 /resplogifx/movs_aut_'||vaniomes2||'a.txt';
							SYSTEM vsql;
							
							LET vcodret = '00000';
							LET p_mensaje = 'Descarga de movs_aut_'||vaniomes2||'a.txt (transacciones autorizadas) completada.';
							RETURN vcodret, p_mensaje;
							
					ELIF (vindica = '2') THEN	
					     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
                       LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 10 units DAY;
                       LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 10 units DAY;
                       LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
					   
					   LET ultimo_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 20 units DAY;
                       LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 20 units DAY;
                       LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 23:59:59';
					
			   let primer_dia_mes_hora = primer_dia_mes_hora;
               let ultimo_dia_mes_hora= ultimo_dia_mes_hora;
						
							/***********************************************************/
							-----Segunda descarga de autorizadas
							/***********************************************************/
							LET vsql	=	'';
							LET vsql	=	'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/movs_aut_'||vaniomes2||'b.txt '||
											/*'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,   '||   
											'	codtran, fechaexptarj, codreversa, referencia, monto, infreceptor,   '||
											'	idreceptor, idterminal, secuenciaorig, movreversado, esnacional,    '|| 
											'	metodocaptura, motivo, trancajeropropio, fechahorainauth,      '|| 
											'	DATE(fechahorainauth) AS fechaoperacion, transaccionorigen,   '|| 
											'	idretailer, secuenciaextendida  '||
											'FROM intercard:movimiento  '||
											'WHERE fechahorainauth  BETWEEN SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+10 UNITS DAY),1,10)||''"'||' 00:00:00.0'||'"'' '||
											'	AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+19 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'	AND codigoiso = ''"'||'00'||'"'' '||
											'	AND formato NOT IN (''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'' ) '||   ---(0221)respuesta de compra forzada, (0420)reverso, (0421)respuesta de reverso---incluir 0200 
											'	AND codtran NOT IN (''"'||'94'||'"'',''"'||'95'||'"'') '||   ---(94)Cambio de NIP, (95)Asignación de NIP 
											'	AND codreversa = 0 '||
											'UNION ALL '||
											'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,   '||   
											'	codtran, fechaexptarj, codreversa, referencia, monto, infreceptor,   '||
											'	idreceptor, idterminal, secuenciaorig, movreversado, esnacional,    '|| 
											'	metodocaptura, motivo, trancajeropropio, fechahorainauth,      '|| 
											'	DATE(fechahorainauth) AS fechaoperacion, transaccionorigen,   '|| 
											'	idretailer, secuenciaextendida  '||
											'FROM intercard:movimientohistorico  '||
											'WHERE fechahorainauth  BETWEEN SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+10 UNITS DAY),1,10)||''"'||' 00:00:00.0'||'"'' '||
											'	AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+19 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'	AND codigoiso = ''"'||'00'||'"'' '||
											'	AND formato NOT IN (''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'' ) '||   ---(0221)respuesta de compra forzada, (0420)reverso, (0421)respuesta de reverso---incluir 0200 
											'	AND codtran NOT IN (''"'||'94'||'"'',''"'||'95'||'"'') '||  ---(94)Cambio de NIP, (95)Asignación de NIP  
											'	AND codreversa = 0; " >/resplogifx/txn_autorizadas.sql';*/
											
'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '2' ||'"'') then '||
'(montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
'idretailer, secuenciaextendida '||
'FROM intercard:movimiento '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
    'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
    'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
    'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
    'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
    'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
    'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
    'AND movreversado = ''"'||'F'||'"'' '||                                                 
    'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||
    'AND codigoiso = ''"'||'00'||'"'' '||
	
	'UNION ALL '||

	'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420' ||'"'' '||
'and codreversa = ''"'||'2' ||'"'') then '||
'(montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
'idretailer, secuenciaextendida '||
'FROM intercard:movimientohistorico '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
    'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
    'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
    'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
    'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
    'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
    'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
    'AND movreversado = ''"'||'F'||'"'' '||                                                 
    'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||
    'AND codigoiso = ''"'||'00'||'"'' '|| 
	'" >/resplogifx/txn_autorizadas.sql';
	
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'dbaccess intercard /resplogifx/txn_autorizadas.sql';
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'rm /resplogifx/txn_autorizadas.sql';
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'gzip -9 /resplogifx/movs_aut_'||vaniomes2||'b.txt';
							SYSTEM vsql;
							
							LET vcodret = '00000';
							LET p_mensaje = 'Descarga de movs_aut_'||vaniomes2||'b.txt (transacciones autorizadas) completada.';
							RETURN vcodret, p_mensaje;
							
					ELIF (vindica = '3') THEN
							/***********************************************************/
							-----Tercera descarga de Transacciones Autorizadas
							/***********************************************************/
					 LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 21 units DAY;
                       LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY)+ 21 units DAY;
                       LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
					   
					   LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
                       LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
                       LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
							
						let primer_dia_mes_hora = primer_dia_mes_hora;
                        let ultimo_dia_mes_hora= ultimo_dia_mes_hora;
							
							LET vsql	=	'';
							LET vsql	=	'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/movs_aut_'||vaniomes2||'c.txt '||
											/*'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,  '||    
											'	codtran, fechaexptarj, codreversa, referencia, monto, infreceptor,  '||  
											'	idreceptor, idterminal, secuenciaorig, movreversado, esnacional,   '||  
											'	metodocaptura, motivo, trancajeropropio, fechahorainauth, '||      
											'	DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||    
											'	idretailer, secuenciaextendida '||
											'FROM intercard:movimiento '||
											'WHERE fechahorainauth  BETWEEN SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+20 UNITS DAY),1,10)||''"'||' 00:00:00.0'||'"'' '||
											'	AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||ultimo_dia_mes_hora||'"'',1,10), YEAR TO DAY)-1 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'	AND codigoiso = ''"'||'00'||'"'' '||
											'	AND formato NOT IN (''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'' ) '||
											'	AND codtran NOT IN (''"'||'94'||'"'',''"'||'95'||'"'') '||   
											'	AND codreversa = 0 '||
											'UNION ALL '||
											'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,  '||    
											'	codtran, fechaexptarj, codreversa, referencia, monto, infreceptor,  '||  
											'	idreceptor, idterminal, secuenciaorig, movreversado, esnacional,   '||  
											'	metodocaptura, motivo, trancajeropropio, fechahorainauth, '||      
											'	DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||    
											'	idretailer, secuenciaextendida '||
											'FROM intercard:movimientohistorico '||
											'WHERE fechahorainauth  BETWEEN SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10), YEAR TO DAY)+20 UNITS DAY),1,10)||''"'||' 00:00:00.0'||'"'' '||
											'	AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||ultimo_dia_mes_hora||'"'',1,10), YEAR TO DAY)-1 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'	AND codigoiso = ''"'||'00'||'"'' '||
											'	AND formato NOT IN (''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'' ) '||
											'	AND codtran NOT IN (''"'||'94'||'"'',''"'||'95'||'"'') '||   
											'	AND codreversa = 0; " >/resplogifx/txn_autorizadas.sql';*/
'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '2' ||'"'') then '||
'(montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
'idretailer, secuenciaextendida '||
'FROM intercard:movimiento '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
    'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
    'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
    'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
    'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
    'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
    'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
    'AND movreversado = ''"'||'F'||'"'' '||                                                 
    'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||
    'AND codigoiso = ''"'||'00'||'"'' '||
	
	'UNION ALL '||

	'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato,'||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420' ||'"'' '||
'and codreversa = ''"'||'2' ||'"'') then '||
'(montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420' ||'"'' '||
'and codreversa = ''"'|| '0' ||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth,  '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
'idretailer, secuenciaextendida '||
'FROM intercard:movimientohistorico '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
    'AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||      
    'AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'' ) and codigoiso <> ''"'|| '' ||'"'' '||
    'AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                              
    'AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
    'AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                
    'AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                
    'AND movreversado = ''"'||'F'||'"'' '||                                                 
    'AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'')  '||
    'AND codigoiso = ''"'||'00'||'"'' '|| 
	'" >/resplogifx/txn_autorizadas.sql';		
	
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'dbaccess intercard	/resplogifx/txn_autorizadas.sql';
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'rm /resplogifx/txn_autorizadas.sql';
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'gzip -9 /resplogifx/movs_aut_'||vaniomes2||'c.txt';
							SYSTEM vsql;
							
							LET vcodret = '00000';
							LET p_mensaje = 'Descarga de movs_aut_'||vaniomes2||'c.txt (transacciones autorizadas) completada';
							RETURN vcodret, p_mensaje;
							
					ELIF (vindica = '4') THEN	
						
							/***********************************************************/
							-----Descarga de Transacciones No Autorizadas
							/***********************************************************/
						LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
                        LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
                        LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
						--OBTIENE EL PRIMER DIA DEL MES DE CORTE
						LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
						LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
						LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
						
						let primer_dia_mes_hora = primer_dia_mes_hora;
                        let ultimo_dia_mes_hora= ultimo_dia_mes_hora;
											
						
							LET vsql	=	'';
							LET vsql	=	'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/movs_noaut_'||vaniomes2||'.txt '||
										/*	'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato, '||
											'	   codtran, fechaexptarj, codreversa, referencia, monto, infreceptor, '||
											'	   idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
											'	   metodocaptura, motivo, trancajeropropio, fechahorainauth, '||
											'	   DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
											'	   idretailer, secuenciaextendida '||
											'FROM intercard:movimiento '||
											'WHERE fechahorainauth BETWEEN  SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10)||''"'||' 00:00:00.0'||'"'' '||
											'	AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||ultimo_dia_mes_hora||'"'',1,10), YEAR TO DAY)-1 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'	AND codigoiso <> ''"'||'00'||'"'' '||
											'UNION ALL '||
											'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato, '||
											'	   codtran, fechaexptarj, codreversa, referencia, monto, infreceptor, '||
											'	   idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
											'	   metodocaptura, motivo, trancajeropropio, fechahorainauth, '||
											'	   DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, '||
											'	   idretailer, secuenciaextendida '||
											'FROM intercard:movimientohistorico '||
											'WHERE fechahorainauth BETWEEN  SUBSTR(''"'||primer_dia_mes_hora||'"'',1,10)||''"'||' 00:00:00.0'||'"'' '||
											'	AND SUBSTR(EXTEND(EXTEND(SUBSTR(''"'||ultimo_dia_mes_hora||'"'',1,10), YEAR TO DAY)-1 UNITS DAY),1,10)||''"'||' 23:59:59.9'||'"'' '||
											'	AND codigoiso <> ''"'||'00'||'"'' ;" >/resplogifx/txn_no_autorizadas.sql';*/
											

'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato, '||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420'||'"'' and codreversa = ''"'||'2'||'"'') then '||
'   (montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420'||'"'' and codreversa = ''"'||'0'||'"'') then '||
'  (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth, '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen,idretailer, secuenciaextendida '||
'FROM intercard:movimiento '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
'    AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||       
'    AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'') and codigoiso <> ''"'||''||'"''  '||
'    AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                                
'    AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
'    AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                  
'    AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                  
'    AND movreversado = ''"'||'F'||'"''  '||                                                  
'    AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'') '|| 
'    AND codigoiso <> ''"'||'00'||'"'' '||         
                                           
' union all '||

'SELECT secuencia, codigoiso, codgironeg, numtarjeta, prodind, formato, '||
'codtran, fechaexptarj, codreversa, referencia, '||
'case when (formato = ''"'||'0420'||'"'' and codreversa = ''"'||'2'||'"'') then (montorealrevfzda + montocashback) '||
'when (formato <> ''"'||'0420'||'"'' and codreversa = ''"'||'0'||'"'') then (monto + montocashback) end as monto, '||
'infreceptor, idreceptor, idterminal, secuenciaorig, movreversado, esnacional, '||
'metodocaptura, motivo, trancajeropropio, fechahorainauth, '||
'DATE(fechahorainauth) AS fechaoperacion, transaccionorigen, idretailer, secuenciaextendida '||
'FROM intercard:movimientohistorico  '||
'WHERE fechahorainauth  BETWEEN '''||primer_dia_mes_hora||''' AND '''||ultimo_dia_mes_hora||''' '||
'    AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines) '||       
'    AND codigoiso is not null AND codigoiso != (''"'||'null'||'"'') and codigoiso <> ''"'||''||'"''  '||
'    AND prodind in(''"'||'01'||'"'',''"'||'02'||'"'') '||                                                
'    AND formato in (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'') '||                            
'    AND codtran not in (''"'||'91'||'"'',''"'||'92'||'"'',''"'||'93'||'"'',''"'||'94'||'"'',''"'||'95'||'"'',''"'||'96'||'"'',''"'||'97'||'"'') '||                  
'    AND ( codreversa = ''"'||'0'||'"'' or codreversa = ''"'||'2'||'"'') '||                                  
'    AND movreversado = ''"'||'F'||'"''  '||                                                  
'    AND metodocaptura is not null AND metodocaptura != (''"'||'null'||'"'') '|| 
'    AND codigoiso <> ''"'||'00'||'"'' '||   
'    ;" >/resplogifx/txn_no_autorizadas.sql';


							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'dbaccess intercard	/resplogifx/txn_no_autorizadas.sql';
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'rm /resplogifx/txn_no_autorizadas.sql';
							SYSTEM vsql;
							LET vsql	=	'';
							LET vsql	=	'gzip -9 /resplogifx/movs_noaut_'||vaniomes2||'.txt';
							SYSTEM vsql;
							
							LET vcodret = '00000';
							LET p_mensaje = 'Descarga de movs_noaut_'||vaniomes2||'.txt (transacciones no autorizadas) completada.';
							RETURN vcodret, p_mensaje;
					END IF;
			 ELSE
				LET vcodret = '200';
				LET p_mensaje = 'Carácter invalido';
				RETURN vcodret, p_mensaje;
        END IF;
	END;
END PROCEDURE;