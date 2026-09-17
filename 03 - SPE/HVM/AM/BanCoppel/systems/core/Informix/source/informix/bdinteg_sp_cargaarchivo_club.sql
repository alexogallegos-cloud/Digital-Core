CREATE PROCEDURE "informix".sp_cargaarchivo_club()
--DATOS A REGRESAR--
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE VARIABLES--

DEFINE cCodret CHAR(5);
DEFINE cCodRetorno CHAR(5);
DEFINE vMensajeRet VARCHAR(80);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE vErrorInfo VARCHAR(80);
DEFINE vProceso VARCHAR(30);
DEFINE dFechaHoy DATE;
DEFINE cRuta CHAR(100);
DEFINE N_banco CHAR(10);
DEFINE N_numero CHAR(10);
DEFINE N_fecha_vencimiento CHAR(10);
DEFINE N_pagado CHAR(1);
DEFINE N_fecha_pago DATETIME YEAR TO SECOND;
DEFINE csql VARCHAR(200);
DEFINE VNomArch VARCHAR(50);
DEFINE Ext VARCHAR(10);
DEFINE Vfecha1 DATE;


 --INICIALIZACION DE VARIABLES--

LET cCodret = '00000';
LET cCodRetorno = '00000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET dFechaHoy = '';
LET cRuta = '';
LET N_banco='';
LET N_numero='';
LET N_fecha_vencimiento='';
LET N_pagado=0;
LET N_fecha_pago='';
LET csql='';
LET Vfecha1= TODAY ;
LET VNomArch='clientesavencer';
LET Ext='.txt';

--SET DEBUG FILE TO "/informix/c94082707/sp_cargaarchivo_club.out";
--TRACE ON;

BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo

                               IF iSqlErr <> 0 OR iIsamErr <> 0 THEN

                                               LET cCodret = iSqlErr;

                                               LET vMensajeRet = vErrorInfo;


                                               RETURN cCodret;

                               END IF;

                END EXCEPTION;
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				TRUNCATE TABLE bdinteg:"informix".si_ctesavencer;
				TRUNCATE TABLE bdinteg:"informix".si_temp_clientes;

                SELECT (fecha_hoy)-1 INTO dFechaHoy

                FROM "informix".si_fechas WHERE empresa = '001';
				
                IF TRIM(NVL(dFechaHoy,'')) <> '' THEN

                               SELECT valor INTO cRuta

                               FROM "informix".si_param

                               WHERE empresa = '001' AND cod_param = 395; 
							   
                               IF TRIM(NVL(cRuta,'')) <> '' THEN

												LET cSql = 'echo "LOAD FROM '|| TRIM(cRuta) || VNomArch||LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy) || Ext || ' INSERT INTO si_temp_clientes;" > ' || TRIM(cRuta) || 'instruccion.sql';
												SYSTEM cSql;

												LET cSql = '';
												LET cSql = 'dbaccess bdinteg '|| TRIM(cRuta) || 'instruccion.sql';
												SYSTEM cSql;
												 
											   --Obtener el numero de banco del cliente e inserta en la tabla si_ctesavencer 

                                               FOREACH  SELECT numcte_coppel, fecha_vencimiento 
														INTO N_numero, N_fecha_vencimiento
														FROM bdinteg:"informix".si_temp_clientes
											   
													    --SELECT DISTINCT (numcte_banco)
                                                        SELECT first 1 numcte_banco
														INTO N_banco 
														FROM bdinteg:"informix".si_relacion_ctebcplcpl
														WHERE cliente=N_numero
                                                        AND tipo_relacion='1' and status='1';
															   
														INSERT INTO bdinteg:"informix".si_ctesavencer(numcte_coppel, numcte_banco, fecha_vencimiento, pagado, fecha_pago)
														VALUES(N_numero, N_banco, mdy(N_fecha_vencimiento[6,7],N_fecha_vencimiento[9,10],N_fecha_vencimiento[1,4]),0, NULL);
														
														LET N_numero, N_fecha_vencimiento, N_banco = '','','';

                                               END FOREACH;
                                ELSE
								LET cCodret = '00002';

                                LET vMensajeRet = 'No Existe Ruta';
                                                       
								END IF
				ELSE

                  LET cCodret = '00001';

                  LET vMensajeRet = 'No Existe Fecha';

                END IF;				
								
			RETURN cCodret;

END;

END PROCEDURE;