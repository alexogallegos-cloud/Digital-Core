CREATE PROCEDURE "informix".sp_status_ctas_act_tjt(vfechacarga DATE)
	 RETURNING CHAR(5), CHAR(60);
	    
		/*Definicion de variables del proceso y manejo de errores*/
		DEFINE error_info 		CHAR(60);
		DEFINE vcodret    		CHAR(5);
		DEFINE vsqlerr    		INTEGER;
		DEFINE isam_err   		SMALLINT;
		DEFINE vpaso      		DECIMAL(17,0);
		DEFINE sumtotal   		DECIMAL(17,0);
		DEFINE vsArchTemporal 	CHAR (15);
		DEFINE vsNomArchivo 	CHAR (40);
		DEFINE vsSQL 			CHAR (2100);
		DEFINE vsSQL1 			CHAR (200);
		DEFINE vsSQL2 			CHAR (700);
		DEFINE vsSQL3 			CHAR (200);
		DEFINE vfechames        DATE;
		DEFINE feculmesant      DATE;
		DEFINE vaniomes			CHAR(6);
		DEFINE vcuenta			CHAR(11);
		DEFINE vtarjeta 		CHAR(16);
		--SET DEBUG FILE TO "/informix/ifg/sp_status_ctas_act_tjt.out"; --Se genera log en un archivo .out
		--TRACE ON;
		
		
		
		/*Inicializando variables de manejo de errores*/

		LET vcodret       	= '00000';
		LET error_info    	= 'Iniciando ejecucion';
		LET vcuenta 		= '';
		LET vtarjeta		= '';
		LET isam_err      	= 0;
		LET vsqlerr       	= 0;
		LET vpaso 		  	= 0;
		LET sumtotal      	= 0;
		LET vsArchTemporal 	= '';
		LET vsNomArchivo 	= '';
		LET vsSQL 			= '';
		LET vsSQL1 			= '';
		LET vsSQL2 			= '';
		LET vsSQL3 			= '';
		LET vfechames 		= (EXTEND(vfechacarga, YEAR TO MONTH) -1 UNITS MONTH)::DATE;
		LET vaniomes 		= SUBSTRING (vfechames FROM 7 FOR 4)||SUBSTRING (vfechames FROM 1 FOR 2);
		LET feculmesant		= LAST_DAY((EXTEND(vfechacarga, YEAR TO MONTH) -1 UNITS MONTH)::DATE);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		/*Incia SP*/
		BEGIN
			/*Excepciones*/
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0 THEN
					 LET vcodret = vsqlerr;
					 LET isam_err = isam_err;
					 LET error_info = error_info;
					 RETURN vcodret, error_info;
				END IF;
			END EXCEPTION;
			IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'ctas_act_tjt')
			THEN 	
						DROP TABLE "informix".ctas_act_tjt;
						LET error_info = 'Se borro tabla ctas_act_tjt';
			END IF;
			
			CREATE TABLE "informix".ctas_act_tjt(
													aniomes     CHAR(6),
													producto    CHAR(12),
													uso  		CHAR(80),
													total decimal(17,0)
													)
													EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
			LET error_info = 'Se creo tabla ctas_act_tjt';
		/*BUSQUEDA DE INFORMACION INTERCARD:MOVIMIENTO*/
		/*se bucan todas las tajetas de debito con movimento ATM en el ultimo mes*/
		SELECT {+INDEX numtarjeta movimiento} numtarjeta, count(*) AS contador FROM intercard:movimiento
			WHERE SUBSTR (numtarjeta,0,6) IN (SELECT {+index (141_86)} bin FROM intercard:bines WHERE creditodebito = 'D')
			 AND prodind = '01' AND codtran IN ('01', '31') AND codreversa = '0'
			  AND DATE(fechahorainauth) BETWEEN vfechames AND feculmesant
		GROUP BY numtarjeta
		INTO TEMP tbltmpatm;
		LET error_info = 'Se creo tabla temporal mov ATM';
		CREATE UNIQUE INDEX numtjtatm ON tbltmpatm( numtarjeta);
		LET error_info = 'Se creo indice tabla temporal mov ATM';
		/*se bucan todas las tajetas de debito con movimento POS en el ultimo mes*/
		SELECT {+INDEX numtarjeta movimiento} numtarjeta, count(*) AS contador FROM intercard:movimiento
			WHERE SUBSTR (numtarjeta,0,6) IN (SELECT {+index (141_86)} bin FROM intercard:bines WHERE creditodebito = 'D')
			 AND prodind = '02' AND metodocaptura IN('05', '90') 
			  AND DATE(fechahorainauth) BETWEEN vfechames AND feculmesant
		GROUP BY numtarjeta
		INTO TEMP tbltmppos;
		LET error_info = 'Se creo tabla temporal mov POS';
		CREATE UNIQUE INDEX numtjtpos ON tbltmppos( numtarjeta);
		LET error_info = 'Se creo indice tabla temporal mov POS';
		/*se bucan todas las tajetas de debito con movimento TAG en el ultimo mes*/
		SELECT {+INDEX numtarjeta movimiento} numtarjeta, count(*) AS contador FROM intercard:movimiento
			WHERE SUBSTR (numtarjeta,0,6) IN (SELECT {+index (141_86)} bin FROM intercard:bines WHERE creditodebito = 'D')
			 AND prodind = '02' AND metodocaptura = '01' AND tipotransaccionposdigitada = 'TG'
			  AND DATE(fechahorainauth)  BETWEEN vfechames AND feculmesant
		GROUP BY numtarjeta
		INTO TEMP tbltmptag;
		LET error_info = 'Se creo tabla temporal mov TAG';
		CREATE UNIQUE INDEX numtjttag ON tbltmptag(numtarjeta);
		LET error_info = 'Se creo indice tabla temporal mov TAG';
		/*se bucan todas las tajetas de debito con movimento TNP en el ultimo mes*/
		SELECT {+INDEX numtarjeta movimiento} numtarjeta, count(*) AS contador FROM intercard:movimiento
			WHERE SUBSTR (numtarjeta,0,6) IN (SELECT {+index (141_86)} bin FROM intercard:bines WHERE creditodebito = 'D')
			 AND prodind = '02' AND metodocaptura = '01' AND tipotransaccionposdigitada != 'TG'
			  AND DATE(fechahorainauth)  BETWEEN vfechames AND feculmesant
		GROUP BY numtarjeta
		INTO TEMP tbltmptnp;
		LET error_info = 'Se creo tabla temporal mov tnp';
		CREATE UNIQUE INDEX numtjttnp ON tbltmptnp(numtarjeta);
		LET error_info = 'Se creo indice tabla temporal mov tnp';
		/*BUSQUEDA DE INFORMACION BDICHEQ:SC_MAECHQ*/
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 2000 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '2000'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov  BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_2000;
		LET error_info = 'Se creo tabla temporal para el producto 2000';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_2000 ON tbltjt_2000(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 2000';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 2000';
		/*ACTUALIZACION DE LA TABLA tbltjt_2000*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_2000 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 2000';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_2000 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 2000';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_2000 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 2000';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_2000 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 2000';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 1900 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '1900'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov  BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_1900;
		LET error_info = 'Se creo tabla temporal para el producto 1900';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_1900 ON tbltjt_1900(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 1900';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 1900';
		/*ACTUALIZACION DE LA TABLA tbltjt_1900*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_1900 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 1900';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_1900 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 1900';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_1900 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 1900';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_1900 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 1900';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 1800 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '1800'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_1800;
		LET error_info = 'Se creo tabla temporal para el producto 1800';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_1800 ON tbltjt_1800(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 1800';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 1800';
		/*ACTUALIZACION DE LA TABLA tbltjt_1800*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_1800 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 1800';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_1800 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 1800';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_1800 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 1800';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_1800 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 1800';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 2400 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '2400'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_2400;
		LET error_info = 'Se creo tabla temporal para el producto 2400';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_2400 ON tbltjt_2400(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 2400';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 2400';
		/*ACTUALIZACION DE LA TABLA tbltjt_2400*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_2400 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 2400';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_2400 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 2400';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_2400 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 2400';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_2400 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 2400';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 1500 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '1500'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_1500;
		LET error_info = 'Se creo tabla temporal para el producto 1500';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_1500 ON tbltjt_1500(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 1500';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 1500';
		/*ACTUALIZACION DE LA TABLA tbltjt_1500*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_1500 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 1500';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_1500 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 1500';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_1500 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 1500';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_1500 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 1500';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 2500 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '2500'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_2500;
		LET error_info = 'Se creo tabla temporal para el producto 2500';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_2500 ON tbltjt_2500(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 2500';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 2500';
		/*ACTUALIZACION DE LA TABLA tbltjt_2500*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_2500 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 2500';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_2500 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 2500';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_2500 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 2500';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_2500 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 2500';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 1400 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '1400'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_1400;
		LET error_info = 'Se creo tabla temporal para el producto 1400';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_1400 ON tbltjt_1400(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 1400';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 1400';
		/*ACTUALIZACION DE LA TABLA tbltjt_1400*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_1400 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 1400';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_1400 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 1400';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_1400 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 1400';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_1400 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 1400';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 1700 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '1700'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_1700;
		LET error_info = 'Se creo tabla temporal para el producto 1700';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_1700 ON tbltjt_1700(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 1700';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 1700';
		/*ACTUALIZACION DE LA TABLA tbltjt_1700*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_1700 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 1700';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_1700 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 1700';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_1700 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 1700';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_1700 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 1700';
		/*SE EXTRAE INFORMACION DE CUENTAS PRODUCTO 1300 CON ULTIMO MOVIMIENTO EN EL MES PASADO*/
		SELECT A.cuenta, A.producto, B.num_tarjeta, b.tipo_tarjeta, b.status_tar, 0 AS atm, 0 AS pos, 0 AS tag, 0 AS tnp
				FROM bdicheq:sc_maechq A LEFT OUTER JOIN bdicheq:sc_tarjeta B ON (A.cuenta =  B.cuenta)
					WHERE A.empresa = '001'
					  AND A.producto = '1300'
                      AND A.status_cta = 1  
                      AND A.fec_ult_mov BETWEEN vfechames AND feculmesant
			INTO TEMP tbltjt_1300;
		LET error_info = 'Se creo tabla temporal para el producto 1300';
		/*SE CREA INDICE PARA LA NUEVA TABLA TEMPORAL*/
		CREATE INDEX  pritjt_1300 ON tbltjt_1300(num_tarjeta);
		LET error_info = 'Se creo indice para tabla temporal para el producto 1300';
		/*se eliman tarjetas no titulres y no activas*/
		DELETE FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL AND tipo_tarjeta != 'T';
		DELETE FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL AND status_tar != 'A';
		LET error_info = 'Se depura tabla temporal 1300';
		/*ACTUALIZACION DE LA TABLA tbltjt_1300*/
		/*Se actualizan los registros en los cueles coincedan los numeros de tarjeta*/
		/*se actualizan movimeintos ATM*/
		UPDATE tbltjt_1300 SET atm = 1
			WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmpatm);
		LET error_info = 'Se actualizan tjt atm 1300';
		/*se actualizan movimeintos POS*/
		UPDATE tbltjt_1300 SET pos = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmppos);
		 LET error_info = 'Se actualizan tjt pos 1300';
		/*se actualizan movimeintos TAG*/
		UPDATE tbltjt_1300 SET tag = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptag);
		 LET error_info = 'Se actualizan tjt tag 1300';
		/*se actualizan movimeintos TNTP*/
		UPDATE tbltjt_1300 SET tnp = 1
		 WHERE num_tarjeta IN (SELECT numtarjeta FROM tbltmptnp);
		 LET error_info = 'Se actualizan tjt tnp 1300';
		/*SE INICIA CON LAS OPERACIONES PARA LLENADO DE LA TABLA TEMPORAL tblmaster*/
			/*operaciones para el producto 2000*/
			SELECT 'aniomes' as aniomes, producto, 'Sin tarjeta de debito                                                      ' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NULL
			GROUP BY producto
			INTO TEMP tblmaster; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2000 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 2000*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 2000' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '2000'
			GROUP BY producto;
			/*operaciones para el producto 1900*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
	
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes  as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1900 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 1900*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 1900' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '1900'
			GROUP BY producto;
			/*operaciones para el producto 1800*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes  as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1800 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 1800*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 1800' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '1800'
			GROUP BY producto;
			/*operaciones para el producto 2400*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes  as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2400 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 2400*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 2400' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '2400'
			GROUP BY producto;
			/*operaciones para el producto 1500*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1500 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 1500*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 1500' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '1500'
			GROUP BY producto;
			/*operaciones para el producto 2500*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_2500 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 2500*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 2500' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '2500'
			GROUP BY producto;
			/*operaciones para el producto 1400*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1400 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 1400*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 1400' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '1400'
			GROUP BY producto;
			/*operaciones para el producto 1700*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1700 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 1700*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 1700' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '1700'
			GROUP BY producto;
			/*operaciones para el producto 1300*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Sin tarjeta de debito' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NULL
			GROUP BY producto; --260124
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,count(*) AS TOTAL-- INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --858501
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --44921
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --177884
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --20616
								AND atm = 0
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y POS' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --26843
								AND atm = 1
								AND pos = 1 
								AND tag = 0
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --1886
								AND atm = 1
								AND pos = 0 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en ATM y TAG' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --1
								AND atm = 1
								AND pos = 0 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --7955
								AND atm = 0
								AND pos = 1 
								AND tag = 0
								AND tnp = 1
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en POS y Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --2
								AND atm = 0
								AND pos = 1 
								AND tag = 1
								AND tnp = 0
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,count(*) AS TOTAL --INTO sumtotal 
							FROM tbltjt_1300 WHERE num_tarjeta IS NOT NULL  --3
								AND atm = 0
								AND pos = 0 
								AND tag = 1
								AND tnp = 1
			GROUP BY producto;
			/*se optiene el subtotal del producto 1300*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, producto, 'Subotal Producto 1300' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE PRODUCTO = '1300'
			GROUP BY producto;
			/*Se optinen totales por uso*/
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'No usan la tarjeta de dÃ©bito en atm, pos(tp), moto internet y voz(tnp), tag'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Sin tarjeta de debito' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Sin tarjeta de debito'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en ATM' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en ATM'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en ATM y Internet y Voz' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en ATM y Internet y Voz'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en ATM y POS' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en ATM y POS'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en Inrernet y Voz & Tag' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en Inrernet y Voz & Tag'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en Internet y Voz' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en Internet y Voz'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en POS' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en POS'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en POS y Internet y voz' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en POS y Internet y voz'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en POS y Tag' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en POS y Tag'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Solo usan tarjeta de debito en TAG' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE uso = 'Solo usan tarjeta de debito en TAG'
			GROUP BY producto;
			INSERT INTO tblmaster
			SELECT vaniomes as aniomes, 'total', 'Gran Total' AS uso,SUM(total) AS TOTAL FROM tblmaster
			 WHERE producto = 'tota'
			GROUP BY producto;
			/*se pasa la infomacion de tabla temporal tblmaster a tabla fisica ctas_act_tjt*/
			INSERT INTO ctas_act_tjt
				SELECT * FROM tblmaster ORDER BY 2;
			/*Se eliminan las tablas temporales ocupadas*/
			DROP TABLE tbltjt_2000;
			DROP TABLE tbltjt_1900;
			DROP TABLE tbltjt_1800;
			DROP TABLE tbltjt_2400;
			DROP TABLE tbltjt_1500;
			DROP TABLE tbltjt_2500;
			DROP TABLE tbltjt_1400;
			DROP TABLE tbltjt_1700;
			DROP TABLE tbltjt_1300;
			DROP TABLE tblmaster;
			/*MANEJO DE ARCHIVOS*/
			LET vsArchTemporal = 'temporal.txt';
			LET vsNomArchivo = 'status_ctas_act_tjt' || TRIM(vaniomes) || '.txt' ;

			/*GENERA EL ARCHIVO DE INTERCAMBIO*/
			LET vsSQL1 = 'echo "UNLOAD TO /resplogifx/conciliachq/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''|''';

			LET vsSQL2 = " SELECT producto, uso, total from ctas_act_tjt;";

			LET vsSQL3 = '" > /resplogifx/conciliachq/control_reporte.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL2 = TRIM(vsSQL2);
			LET vsSQL3 = TRIM(vsSQL3);
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			
			SYSTEM vsSQL;
			/*Permiso para la creacion de archivo.*/
			LET vsSQL = '' ;
			LET vsSQL = 'chmod 666 /resplogifx/conciliachq/control_reporte.sql' ;
			SYSTEM vsSQL;
			LET vsSQL = '' ;
			LET vsSQL = 'dbaccess bdicheq /resplogifx/conciliachq/control_reporte.sql';
			SYSTEM vsSQL;
			/*Borra el archivo de control.*/
			LET vsSQL = '' ;
			LET vsSQL = 'rm /resplogifx/conciliachq/control_reporte.sql';
			SYSTEM vsSQL ;
			/*Se pasa la informaciÃ³n al archivo final quitando el Ãºlimo pipe*/
			LET vsSQL = '' ;
			LET vsSQL =  "sed 's/|$//g' /resplogifx/conciliachq/" || TRIM (vsArchTemporal) || " >  /resplogifx/conciliachq/" ||TRIM (vsNomArchivo);
			SYSTEM vsSQL;
			/*Borra el archivo de control.*/
			LET vsSQL = '' ;
			LET vsSQL = 'rm /resplogifx/conciliachq/' || TRIM (vsArchTemporal);
			SYSTEM vsSQL ;
			
			LET vcodret = '00000';
			LET error_info = 'PROCESO EXITOSO';
			RETURN vcodret, error_info;
		END;
END PROCEDURE;