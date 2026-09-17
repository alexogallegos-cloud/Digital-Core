CREATE PROCEDURE "informix".sp_reportecred(pindica VARCHAR (1))--Parametro "C" indica que es reporte mensual y semanal de Crédito.
                                                                                 

RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  iSqlErr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  cCodret                 varchar(6);
DEFINE  cVarDataErr             varchar(26);
DEFINE  p_mensaje               varchar(80);
DEFINE  vfecha_hoy              DATE;
DEFINE  vfecha_hoy_dia          DATE;
DEFINE  vfech_alt               DATE;
DEFINE  vsql                    char(1150);
DEFINE  vindica                 varchar(1);
DEFINE  vperiodo                VARCHAR(8);
DEFINE  vano                    VARCHAR(4);
DEFINE  vanodos                 VARCHAR(4);
DEFINE  vmes                    VARCHAR(2);
DEFINE  vmesdos                 VARCHAR(2);
DEFINE  vdia                    VARCHAR(3);
DEFINE  vdia2                   VARCHAR(3);
DEFINE  vdia3                   VARCHAR(3);
DEFINE  vdia4                   VARCHAR(3);
DEFINE  vanomes                 VARCHAR(8);
DEFINE  vanomesdos              VARCHAR(8);
DEFINE  vanomesdiaini           VARCHAR(8);
DEFINE  vanomesdiafin           VARCHAR(8);
DEFINE  sql_err                 integer;
DEFINE  vperiodofinal           DATE;
DEFINE  vperiodoini             DATE;
DEFINE  vperiodofin             DATE;
DEFINE  vperiodini              DATE;
DEFINE  vaniomes                char(6);
DEFINE  vdia_lunes              integer;
DEFINE  vcuenta                 VARCHAR(13);
DEFINE  nrows                   SMALLINT;




 
--------------FECHAS-------------------------------------

DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);

--SET DEBUG FILE TO "/informix/c94796696/acumuladocred.out";
--TRACE ON;
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET vcodret    = SQL_ERR;
	LET p_mensaje  = error_info;
	
    RETURN 	vcodret,p_mensaje;
		
   END EXCEPTION;
   
	 
-------------------------------  CÁLCULO DE FECHAS----------------------------------------------------------------------------
SET ISOLATION TO DIRTY READ;
SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas;
--SET ISOLATION TO DIRTY READ;
--select max (fecha_mov) INTO vfech_alt from bditarjeta:tmp_txcredsem;--Extraemos la fecha máxima de la tabla tmp_movhis
--let vfech_alt = 06/28/2013 

SET ISOLATION TO DIRTY READ;
SELECT weekday(fecha_hoy) into vdia_lunes
FROM bdinteg:si_fechas;

SET ISOLATION TO DIRTY READ;
SELECT fecha_hoy INTO vfecha_hoy_dia FROM  bdinteg:si_fechas;

LET vdia3 = SUBSTR(vfecha_hoy_dia,3,4);
LET vdia4 = SUBSTR(vdia3,2,5);

LET vano = SUBSTR(vfecha_hoy,7,10);
LET vmes = SUBSTR(vfecha_hoy,1,2);
LET vdia = SUBSTR(vfecha_hoy,3,4);
LET vdia2 = SUBSTR(vdia,2,5);
LET vanomes =  vano||vmes;


-------------------------------  CÁLCULO DE FECHAS-----------------------------------------

	LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    let primer_dia_mes= primer_dia_mes;
	let vanodos =SUBSTR(primer_dia_mes,7,10);
	LET vmesdos = SUBSTR(primer_dia_mes,1,2);
	let vanomesdos =vanodos||vmesdos;
	




SET ISOLATION TO DIRTY READ;
SELECT  fecha_hoy-7  INTO vperiodoini FROM bdinteg:si_fechas;  
LET vperiodoini = vperiodoini;
--expression:vperiodoini
--evaluates to 08/26/2013 
LET vano = SUBSTR(vperiodoini,7,10);
LET vmes = SUBSTR(vperiodoini,1,2);
LET vdia = SUBSTR(vperiodoini,3,4);
LET vdia2 = SUBSTR(vdia,2,5);
LET vanomesdiaini =  vmes||vdia2||vano;

SET ISOLATION TO DIRTY READ;
SELECT fecha_hoy-1  INTO vperiodofinal FROM bdinteg:si_fechas;
LET vperiodofinal = vperiodofinal;
--evaluates to 09/01/2013 
--let vperiodofinal = 09/01/2013 
LET vano = SUBSTR(vperiodofinal,7,10);
LET vmes = SUBSTR(vperiodofinal,1,2);
LET vdia = SUBSTR(vperiodofinal,3,4);
LET vdia2 = SUBSTR(vdia,2,5);
LET vanomesdiafin =  vmes||vdia2||vano;
--LET vanomes = vanomes;
LET vindica = pindica;
--LET vfech_alt = vfech_alt;




    IF(vindica = 'C' AND vindica <> '') THEN 
	
		/*
		IF 	(vdia4 = '02' OR vdia_lunes = '1') THEN
				ELSE 
			    LET vcodret = '0003';
			    LET  p_mensaje  = 'No es día Lunes ó No es día 2 de cada mes';
			    return vcodret, p_mensaje;
	    END IF;
		*/
	
		IF ((NOT EXISTS (SELECT Status_Proc FROM BdiCred:"informix".Sd_ContProc WHERE Proceso = 'Trasl_Dia' AND Fecha = (TODAY-1) AND Cod_Ret = '000' AND Status_Proc = 'F')) ) THEN --VALIDA ESTATUS DEL PASE DE MOVIMIENTOS HITORICOS DE CREDITO
			LET vcodret = '00006'; --NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HISTÓRICOS DE CRÉDITO
			LET p_mensaje = 'NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HISTORICOS DE CREDITO';
			return vcodret, p_mensaje;	
		END IF;
    
		SET ISOLATION TO DIRTY READ;
		SELECT fecha_hoy INTO vfecha_hoy_dia FROM  bdinteg:si_fechas;

		LET vdia3 = SUBSTR(vfecha_hoy_dia,3,4);
		LET vdia4 = SUBSTR(vdia3,2,5);			
		SELECT weekday(fecha_hoy) into vdia_lunes
		FROM bdinteg:si_fechas;

            IF(vdia4 = '02' AND vdia_lunes = '1')THEN --Validamos si el día de ejecución es el "02" del mes para extrear la información mensual y semanal
							
						---Genera Reporte Semanal-------------
						let vsql = ''; 	   
						let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/trancred'||vanomesdiafin||'.txt '||
                                       'SELECT fecha_mov,trim(num_credito) as num_credito,sucursal,transacc_suc,codigo_fun,codigo_ref,monto FROM bdicred:sd_movhis WHERE fecha_mov >='''||vanomesdiaini||''' AND  fecha_mov <='''||vanomesdiafin||''' '||
									   'and num_credito is not null and reversado <> ''"'||'S'||'"'' '||
									   'and transacc_suc || codigo_fun || codigo_ref in(select llave from tmp_txcred) and empresa = ''"'||'001'||'"'''||
                                       'ORDER BY fecha_mov;" >/resplogifx/reban.sql';
						system vsql;
						let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess bditarjeta /resplogifx/reban.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/reban.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/trancred'||vanomesdiafin||'.txt';
						system vsql;	
						
				set isolation to dirty read;
                Select (extend(pri_dia_mes, year to month) -0 units month)::date - 1 into vperiodofinal
				from bdinteg:si_fechas;
				LET vperiodofinal=vperiodofinal;
				LET vano = SUBSTR(vperiodofinal,7,10);
				LET vmes = SUBSTR(vperiodofinal,1,2);
				LET vdia = SUBSTR(vperiodofinal,3,4);
				LET vdia2 = SUBSTR(vdia,2,5);
				LET vperiodofinal =  vmes||vdia2||vano;
				LET vperiodofinal=vperiodofinal;
				
				LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
                let primer_dia_mes= primer_dia_mes;
	            LET vano = SUBSTR(primer_dia_mes,7,10);
				LET vmes = SUBSTR(primer_dia_mes,1,2);
				LET vdia = SUBSTR(primer_dia_mes,3,4);
				LET vdia2 = SUBSTR(vdia,2,5);
				LET vperiodoini =  vmes||vdia2||vano;
				LET vperiodoini= vperiodoini;
				
				
				let vsql = ''; 	   
			    let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/finan_tdc'||vanomesdiafin||'.txt '||
                                       'SELECT b.transacc,a.codigo_fun, a.codigo_ref,b.descripcion, count(*) as cantidad,sum (monto) as importe FROM bdicred:sd_movhis a,bdicred:sd_transfun b,bdinteg:si_transacc c '||
									   'WHERE a.empresa = ''"'||'001'||'"'' and  a.num_credito is not null and a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref and  c.numero= b.transacc and fecha_mov >='''||vperiodoini||''' AND  fecha_mov <='''||vperiodofinal||''' and  reversado <> ''"'||'S'||'"'''||
									   'and a.transacc_suc ||a.codigo_fun ||a.codigo_ref in(select llave from bditarjeta:tmp_txcred) group by 1,2,3,4;">/resplogifx/rebandos.sql';
				   
		        	    system vsql;
					    let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess bditarjeta /resplogifx/rebandos.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/rebandos.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/finan_tdc'||vanomesdiafin||'.txt';
						system vsql;
			

							LET vcodret = '0000';
							LET  p_mensaje  = 'Reporte Semanal y Mensual  Generado 01';
							return vcodret, p_mensaje;	
	
			END IF;
			
			
			   IF 	(vdia4 = '02') THEN
			
                
				set isolation to dirty read;
                Select (extend(pri_dia_mes, year to month) -0 units month)::date - 1 into vperiodofinal
				from bdinteg:si_fechas;
				LET vperiodofinal=vperiodofinal;
				LET vano = SUBSTR(vperiodofinal,7,10);
				LET vmes = SUBSTR(vperiodofinal,1,2);
				LET vdia = SUBSTR(vperiodofinal,3,4);
				LET vdia2 = SUBSTR(vdia,2,5);
				LET vperiodofinal =  vmes||vdia2||vano;
				LET vperiodofinal=vperiodofinal;
				
				LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
                let primer_dia_mes= primer_dia_mes;
	            LET vano = SUBSTR(primer_dia_mes,7,10);
				LET vmes = SUBSTR(primer_dia_mes,1,2);
				LET vdia = SUBSTR(primer_dia_mes,3,4);
				LET vdia2 = SUBSTR(vdia,2,5);
				LET vperiodoini =  vmes||vdia2||vano;
				LET vperiodoini= vperiodoini;
					---Genera Reporte Mensual-------------
				let vsql = ''; 	   
			    let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/finan_tdc'||vanomesdiafin||'.txt '||
                                       'SELECT b.transacc,a.codigo_fun, a.codigo_ref,b.descripcion, count(*) as cantidad,sum (monto) as importe FROM bdicred:sd_movhis a,bdicred:sd_transfun b,bdinteg:si_transacc c '||
									   'WHERE a.empresa = ''"'||'001'||'"'' and  a.num_credito is not null and a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref and  c.numero= b.transacc and fecha_mov >='''||vperiodoini||''' AND  fecha_mov <='''||vperiodofinal||''' and  reversado <> ''"'||'S'||'"'''||
									   'and a.transacc_suc ||a.codigo_fun ||a.codigo_ref in(select llave from bditarjeta:tmp_txcred) group by 1,2,3,4;">/resplogifx/rebandos.sql';
		        	    system vsql;
					    let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess bditarjeta /resplogifx/rebandos.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/rebandos.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/finan_tdc'||vanomesdiafin||'.txt';
						system vsql;
				
							
							 LET vcodret = '0000';
							 LET  p_mensaje  = 'Reporte Mensual  Generado 01 ';
							 return vcodret, p_mensaje;
				END IF;
		
		
						IF (vdia_lunes = '1') THEN

							---Genera Reporte Semanal-------------
						let vsql = ''; 	   
						let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/trancred'||vanomesdiafin||'.txt '||
                                       'SELECT fecha_mov,trim(num_credito) as num_credito,sucursal,transacc_suc,codigo_fun,codigo_ref,monto FROM bdicred:sd_movhis WHERE fecha_mov >='''||vanomesdiaini||''' AND  fecha_mov <='''||vanomesdiafin||''' '||
									   'and num_credito is not null and reversado <> ''"'||'S'||'"'' '||
									   'and transacc_suc || codigo_fun || codigo_ref in(select llave from tmp_txcred) and empresa = ''"'||'001'||'"'''||
                                       'ORDER BY fecha_mov;" >/resplogifx/reban.sql';
						system vsql;
						let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess bditarjeta /resplogifx/reban.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/reban.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/trancred'||vanomesdiafin||'.txt';
						system vsql;	
			
									
									
										LET vcodret = '0000';
										LET  p_mensaje  = 'Reporte Semanal Generado 02 ';
										return vcodret, p_mensaje;
															
						END IF;
						IF(vdia4 <> '02' AND vdia_lunes <> '1')THEN --Situación en la que se ejecuta en un día que es diferente de 2 y no es Lunes
							
							---Genera Reporte Semanal-------------
							let vsql = ''; 	   
							let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/trancred'||vanomesdiafin||'.txt '||
										   'SELECT fecha_mov,trim(num_credito) as num_credito,sucursal,transacc_suc,codigo_fun,codigo_ref,monto FROM bdicred:sd_movhis WHERE fecha_mov >='''||vanomesdiaini||''' AND  fecha_mov <='''||vanomesdiafin||''' '||
										   'and num_credito is not null and reversado <> ''"'||'S'||'"'' '||
										   'and transacc_suc || codigo_fun || codigo_ref in(select llave from tmp_txcred) and empresa = ''"'||'001'||'"'''||
										   'ORDER BY fecha_mov;" >/resplogifx/reban.sql';
							system vsql;
							let vsql = '';
							let vsql = '';
							system vsql;
							let vsql= "dbaccess bditarjeta /resplogifx/reban.sql";
							system vsql;
							let vsql = '';
							let vsql ='rm /resplogifx/reban.sql';
							system vsql;
							let vsql = '';
							let vsql ='gzip -9 /resplogifx/trancred'||vanomesdiafin||'.txt';
							system vsql;	
						
				set isolation to dirty read;
                Select (extend(pri_dia_mes, year to month) -0 units month)::date - 1 into vperiodofinal
				from bdinteg:si_fechas;
				LET vperiodofinal=vperiodofinal;
				LET vano = SUBSTR(vperiodofinal,7,10);
				LET vmes = SUBSTR(vperiodofinal,1,2);
				LET vdia = SUBSTR(vperiodofinal,3,4);
				LET vdia2 = SUBSTR(vdia,2,5);
				LET vperiodofinal =  vmes||vdia2||vano;
				LET vperiodofinal=vperiodofinal;
				
				LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
                let primer_dia_mes= primer_dia_mes;
	            LET vano = SUBSTR(primer_dia_mes,7,10);
				LET vmes = SUBSTR(primer_dia_mes,1,2);
				LET vdia = SUBSTR(primer_dia_mes,3,4);
				LET vdia2 = SUBSTR(vdia,2,5);
				LET vperiodoini =  vmes||vdia2||vano;
				LET vperiodoini= vperiodoini;
				
				
				let vsql = ''; 	   
			    let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/finan_tdc'||vanomesdiafin||'.txt '||
                                       'SELECT b.transacc,a.codigo_fun, a.codigo_ref,b.descripcion, count(*) as cantidad,sum (monto) as importe FROM bdicred:sd_movhis a,bdicred:sd_transfun b,bdinteg:si_transacc c '||
									   'WHERE a.empresa = ''"'||'001'||'"'' and  a.num_credito is not null and a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref and  c.numero= b.transacc and fecha_mov >='''||vperiodoini||''' AND  fecha_mov <='''||vperiodofinal||''' and  reversado <> ''"'||'S'||'"'''||
									   'and a.transacc_suc ||a.codigo_fun ||a.codigo_ref in(select llave from bditarjeta:tmp_txcred) group by 1,2,3,4;">/resplogifx/rebandos.sql';
				   
		        	    system vsql;
					    let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess bditarjeta /resplogifx/rebandos.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/rebandos.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/finan_tdc'||vanomesdiafin||'.txt';
						system vsql;
			

							LET vcodret = '0000';
							LET  p_mensaje  = 'Reporte Semanal y Mensual  Generado 01';
							return vcodret, p_mensaje;	
	
			END IF;
			
		ELSE
			LET vcodret = '0002';
			LET  p_mensaje  = 'El paremetro no es el correcto, deberá ser C';
			return vcodret, p_mensaje;
	END IF;	

		return vcodret, p_mensaje;	 	
 
		 	
END;
end procedure;