CREATE PROCEDURE "informix".sp_txn_forzadas
(
	pvindica				VARCHAR(1),-------(F) Transacciones forzadas
	vdfecha_inicio 			VARCHAR(10)---Fecha inicio del periodo que abarca el reporte. Putty(dd-mm-yyyy).
)
RETURNING VARCHAR(6), VARCHAR(80)
/*
#####################################################################################
#   Descripcion: Reporte de transacciones forzadas. 								#
#   Creado por: María del Rosario Montes Villa.										#
#   Fecha: 26/08/2014																#
#####################################################################################
#   Modificado por: 	                            								#
#   Fecha de modificacion: 															#
#   Motivo:																			#
#####################################################################################
*/
	DEFINE	visqlerr		INTEGER;
	DEFINE	visam_err		INTEGER;
	DEFINE  vverror_info  	VARCHAR(80);
	DEFINE  vvcodret        VARCHAR(6);
	DEFINE  vvmensaje       VARCHAR(80);
	DEFINE  vvfecha_inicio	VARCHAR(10);
	DEFINE  vcsql			CHAR(8000);

	
	/*i: integer
	v: varchar
	c: char*/
	
	--SET DEBUG FILE TO "/resplogifx/txsforzadas_1.sql";
    --TRACE ON;
	
	BEGIN
		 ON EXCEPTION SET visqlerr,visam_err, vverror_info
            IF visqlerr <> 0 AND visqlerr <> -958  THEN
                LET vvcodret = visqlerr;
                LET vvmensaje = vverror_info;
                  RETURN vvcodret, vvmensaje;
            END IF;
		END EXCEPTION;
		
		LET	vvfecha_inicio = SUBSTR(vdfecha_inicio,4,2)||'-'||SUBSTR(vdfecha_inicio,1,2)||'-'||SUBSTR(vdfecha_inicio,7,4);
		
		IF ((NOT EXISTS (SELECT Fecha FROM BdiCheq:"informix".sc_ContProc WHERE Proceso = 'pasomovshist' AND Fecha = (TODAY-1))) ) THEN --VALIDA ESTATUS DEL PASE DE MOVIMIENTOS HITORICOS DE CHEQUES
			LET vvcodret = '00007'; --NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HITORICOS DE DEBITO
			LET  vvmensaje  = 'NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HITORICOS DE DEBITO';
			return vvcodret, vvmensaje;	
	    END IF;
		
		IF (pvindica = 'F') THEN
				LET vcsql	=	'';
				LET vcsql	=	'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/forzadas_'||SUBSTR(vdfecha_inicio,1,2)||SUBSTR(vdfecha_inicio,4,2)||SUBSTR(vdfecha_inicio,7,4)||'.txt' ||
								' SELECT nombrearchivo AS NombreArchivo, '||
								'	   numtarjeta AS NumeroTarjeta,	'||
								'	   numcuenta AS Cuenta,	'||
								'	   secuencia325 AS Secuencia, '||
								'	   idcomercio325 AS IdComercio, '||
								'	   metodocaptura AS MetodoCaptura, '||
								'	   nomcomercio325 AS NombreComercio, '||
								'	   referencia23_325 AS Referencia23, '||
								'	   fechatransaccion AS FechaTransaccion, '||
								'	   fechaconcilia AS FechaConciliacion, '||
								'	   (tipo_conciliacion || ''"'||' '||'"'' || desc_conciliacion) AS DescripcionConciliacion, '||
								'	   (monto325 / 100) AS MontoConciliacion, '||
								'	   montointercard AS MontoInterCard, '||
								'	   ((monto325 / 100)  - montointercard) AS DiferenciaMonto, '||
								'	   CASE '||
								'		   WHEN montointercard = 0 THEN 0 '||
								'		   ELSE  ROUND((((((monto325 / 100)  - montointercard) * 100)) / montointercard),2) '||
								'	   END AS Porcentaje, '||
								'	   CASE '||
								'			WHEN SUBSTRING(numtarjeta FROM 1 FOR 6) IN (SELECT bin FROM intercard:bines WHERE creditodebito=''"'||'D'||'"'' ) THEN '||
								'				 (SELECT SUM(monto_tot) FROM bdicheq:sc_movhis B '||
								'				 WHERE empresa = ''"'||'001'||'"'' AND '||
								'					   B.cuenta = A.numcuenta AND '||
								'					   B.num_tarjeta = A.numtarjeta AND '||
								'					   B.fech_alt::DATE = A.fechaconcilia::DATE AND '||
								'					   B.folio_suc = A.folio_mov AND '||
								'					   B.referencia_23 = A.referencia23_325 AND '||
								'					   B.transacc = ''"'||'3357'||'"'' ) '|| ---USO DE SOBREGIRO(bdinteg:si_transacc,sistema='01', numero = '3357')               
								'			ELSE 0 '||
								'	   END AS Sobregiro   '||
								' FROM Bditarjeta:td_movimientos_conciliacion A '||
								' WHERE fechaconcilia::DATE = ''"'||vvfecha_inicio||'"'' AND '||
								'	  tipo_conciliacion IN  (5,6,8,13,24,28,31,33,35,44,45,46) AND '||---- (5)Conciliado con monto mayor,(8)Forzado (sin movimiento en Intercard), (6)Movimiento previamente conciliad, (31)Forzado con Cash Back(sin movimiento en Intercard)  
								'	  archivo_origen IN(''"'||'VND'||'"'',''"'||'VNC'||'"'',''"'||'VIC'||'"'', ''"'||'VID'||'"'', ''"'||'MCC'||'"'', ''"'||'MCD'||'"'',''"'||'TCD'||'"'',''"'||'TCC'||'"'') '||								
								' ORDER BY consecutivo; ">/resplogifx/txn_forzadas.sql ';
				SYSTEM vcsql;
				LET vcsql	=	'';
				LET vcsql	=	'dbaccess intercard /resplogifx/txn_forzadas.sql';
				SYSTEM vcsql;
				LET vcsql	=	'rm /resplogifx/txn_forzadas.sql';
				SYSTEM vcsql;
				
				
				LET	vvcodret 	=	'00000';
				LET vvmensaje	=	'Reporte de transacciones forzadas generado.';
				RETURN vvcodret, vvmensaje;
		END IF;	
		LET vvcodret = '200';
		LET vvmensaje = 'Carácter invalido';
		RETURN vvcodret, vvmensaje;
	END;
END PROCEDURE;