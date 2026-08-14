CREATE PROCEDURE "informix".sp_get_indicadores_idbox_manual(dFechaini DATE, dFechafin DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE iNomErr			INTEGER;
DEFINE iNanErr			INTEGER;
DEFINE iEnTransaccion   SMALLINT;
DEFINE dFechaProceso	DATE;
DEFINE bTablatmp		BOOLEAN;


--ASIGNACION DE VARIABLES
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO SE A GENERADO CORRECTAMENTE';
LET iEnTransaccion = 0;
LET bTablatmp = 'f';

--SET DEBUG FILE TO "/tmp/ALAN/SOC/sp_indicadores_manual_idbox.out";
--TRACE ON;

BEGIN

	--MANEJO DEL ERROR
		ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
			IF iNomErr <> 0 THEN
			LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN
					ROLLBACK;
					
					LET iEnTransaccion = 0;
					
					IF bTablatmp = 't' THEN
						LET bTablatmp = 'f';	
					END IF;
                END IF;
				
				IF bTablatmp = 't' THEN
					DROP TABLE si_tmp_ctes_titulares_idbox;
					LET bTablatmp = 'f';
				END IF;
				
				RETURN vCodRet, cMensCodRet;
			END IF;
		END EXCEPTION;	
		
		IF NVL(dFechaIni,'') = '' OR  NVL(dFechaFin,'') = ''  THEN 		
			LET vCodRet = '000001';
			LET cMensCodRet = 'PARAMETRO INCORRECTO';
			RETURN vCodRet, cMensCodRet;
		ELIF dFechaIni > dFechaFin THEN
			LET vCodRet = '000002';
			LET cMensCodRet = 'PARAMETROS INCORRECTOS, FECHA INCIAL MAYOR A FECHA FINAL';
			RETURN vCodRet, cMensCodRet;
		END IF;
			
		LET dFechaProceso = dFechaIni;
		
		WHILE (dFechaProceso <= dFechaFin)
			BEGIN WORK;
			
				LET iEnTransaccion = 1;
					
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;	
				SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, a.ejecutivo AS numemp, a.fecha_insert
				FROM bdinteg:"informix".si_cliente a INNER JOIN bdinteg:"informix".si_ctepf b
				ON a.numcte = b.numcte	
				WHERE a.fecha_insert = dFechaProceso
				AND a.tipo_cliente='1'
				INTO TEMP si_tmp_ctes_titulares_idbox WITH NO LOG;
				
				LET bTablatmp = 't';
					
				IF  EXISTS (SELECT 1 FROM si_indicadores_idbox WHERE fecha_proceso = dFechaProceso) THEN
					DELETE FROM si_indicadores_idbox
					WHERE fecha_proceso = dFechaProceso;
				END IF;	
				
				INSERT INTO si_indicadores_idbox (fecha_proceso,sucursal,altas_total,total_idb,user_insert,fecha_insert)
				SELECT NVL(b.fecha_insert,dFechaProceso) AS fecha_insert,a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb,user as usuer_insert,(SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals) as fecha_insert
					FROM si_sucursales a
					LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE si_tmp_ctes_titulares_idbox
									SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total, clientes.fecha_insert FROM 
									(SELECT numcte, sucursal,fecha_insert 
									FROM si_tmp_ctes_titulares_idbox
									WHERE fecha_insert = dFechaProceso) clientes
									INNER JOIN
								--OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
									(SELECT DISTINCT(numcte), sucursal, fecha
									FROM si_bitacora_ife
									WHERE date(fecha) = dFechaProceso) bitacora
									ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
									GROUP BY clientes.sucursal,clientes.fecha_insert
							 ) b 	ON a.sucursal=b.sucursal
					LEFT JOIN (--OBTENIENDO ALTAS POR SUCURSAL
									SELECT sucursal, COUNT(DISTINCT (numcte)) AS total
									FROM si_tmp_ctes_titulares_idbox
									WHERE fecha_insert = dFechaProceso
									GROUP BY sucursal
							  )C 	ON a.sucursal=C.sucursal	
					WHERE a.sucursal IN (SELECT DISTINCT(sucursal) FROM si_bitacora_ife);
					
				IF bTablatmp = 't' THEN
					DROP TABLE si_tmp_ctes_titulares_idbox;
					LET bTablatmp = 'f';
				END IF;

			COMMIT WORK;
				LET iEnTransaccion = 0;
				LET dFechaProceso = dFechaProceso + 1 UNITS DAY; 
		END WHILE;
		
		RETURN vCodRet, cMensCodRet;	
END;
		
END PROCEDURE		
;