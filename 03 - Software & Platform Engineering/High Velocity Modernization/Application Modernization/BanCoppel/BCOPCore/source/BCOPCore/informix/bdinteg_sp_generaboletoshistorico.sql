CREATE PROCEDURE "informix".sp_generaboletoshistorico	(cEmpresa CHAR(3),
											cCve_Sorteo CHAR(5),
											iTipoOperacion CHAR(1),
											cFolioSucursal CHAR(16),
											dFechaMovimiento DATE,
											cNumCuenta CHAR(12),
											cNumCliente CHAR(9),
											cTipoSistema CHAR(1),
											siRegistros SMALLINT)
	RETURNING
	CHAR(5) AS CodRetorno, INTEGER AS Boleto, DATE AS Fecha, CHAR(9) AS NumCliente, CHAR(16) AS FolioSuc, INTEGER AS Importe;

--Definicion de Variables
DEFINE cCodRet    CHAR(5);
DEFINE cInfoErr   CHAR(200);
DEFINE cFolioSuc  CHAR(16);
DEFINE cNumCte    CHAR(9);
DEFINE dFecha_hoy DATE;
DEFINE dFecha_Reg DATE;
DEFINE iTipoOper  INTEGER;
DEFINE iSqlErr    INTEGER;
DEFINE iIsamErr   INTEGER;
DEFINE iMonto     INTEGER;
DEFINE siCiclo    SMALLINT;
DEFINE iBoletos_ini INTEGER;
DEFINE iBoletos_fin INTEGER;
DEFINE bFlag CHAR(1);
DEFINE dtFechaIni DATE;
DEFINE dtFechaFin DATE;
DEFINE sCve_Sorteo CHAR(5);
DEFINE dtFechaAux DATE;
DEFINE sCodRetAux CHAR(3);

DEFINE dtfecha_mov DATE;
DEFINE csucursal CHAR(4);
DEFINE mmonto DECIMAL (16,2);
DEFINE cfolio_suc CHAR(16);
DEFINE cnum_producto CHAR(4);

DEFINE cCodRet2 CHAR(5);
DEFINE cMensaje CHAR(80);
DEFINE iRangoIni INTEGER;
DEFINE iRangoFin INTEGER;



-- Inicializa variables
LET cCodRet = "00000";
LET cInfoErr = "";
LET cFolioSuc = "";
LET cNumCte = "";
LET dFecha_hoy = '01-01-1900';
LET dFecha_Reg = '01-01-1900';
LET iTipoOper = 0;
LET iSqlErr = 0;
LET iIsamErr = 0;
LET iMonto = 0;
LET siCiclo = 0;
LET iBoletos_ini = 0;
LET iBoletos_fin = 0;
LET bFlag = 'F';
LET dtFechaIni = CURRENT;
LET dtFechaFin = CURRENT;
LET sCve_Sorteo = '';
LET dtFechaAux = CURRENT;
LET sCodRetAux = '';

LET dtfecha_mov = '01/01/1900';
LET csucursal = '';
LET mmonto = 0.0;
LET cfolio_suc = '';
LET cnum_producto = '';

LET cCodRet2 = '';
LET cMensaje = '';
LET iRangoIni = 0;
LET iRangoFin = 0;


	--SET DEBUG FILE TO "/tmp/sp_GeneraBoletosHistorico.out";
	--TRACE ON;
	
	--Optimización al proceso de Reimpresión de Boletos se elimina la busqueda
	--en tablas de movimientos al dia(sc_movdia y sd_movdia), así como la
	--busqueda a la tabla si_boleto.   Raúl Ramírez

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN

				LET cCodRet = iSqlErr;
				-- verifica que tablas temporales se crearon para borrarlas
				IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'si_dispercionboletostmp') THEN
					DROP TABLE BdInteg:si_dispercionboletostmp;
				END IF;

				RETURN cCodRet, 0, '01/01/1900', '', '', 0;

			END IF;
		END EXCEPTION;

		IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'si_dispercionboletostmp') THEN
			DROP TABLE BdInteg:si_dispercionboletostmp;
		END IF;

		--CREA TABLA DE TRABAJO PARA LA DISPERCION DE LOS BOLETOS.
		CREATE TABLE BdInteg:si_dispercionboletostmp(
			Boleto INT8,
			F_Registro DATE,
			Numcte CHAR(9),
			FolioSuc CHAR(16),
			Importe MONEY(16,2));

		--OBTIENE LA FECHA DEL SISTEMA
		SELECT FIRST 1 fecha_hoy
          INTO dFecha_hoy
          FROM bdinteg:si_fechas;

		--OBTIENE LA FECHA DEL SORTEO REGISTRADO CON FECHA MAS RECIENTE DE INICIO
		SELECT FIRST 1 F_Ini::DATE, F_Fin::DATE, Cve_Sorteo
		  INTO dtFechaIni, dtFechaFin, sCve_Sorteo
		  FROM BdInteg:Si_Sorteo
		 WHERE Cve_Sorteo = cCve_Sorteo;

			IF (iTipoOperacion = '1') THEN -- FOLIO SUCURSAL

            --OBTIENE LOS REGISTROS DE LOS BOLETOS.
            FOREACH

				SELECT {INDEX (BdInteg:si_boleto_hist_index3)} boleto_ini, boleto_fin, f_registro::DATE, numcte,
                       foliosuc, importe
				  INTO iBoletos_ini, iBoletos_fin, dFecha_Reg, cNumCte, cFolioSuc, iMonto
				  FROM BdInteg:si_boleto_hist
				 WHERE cve_sorteo = sCve_Sorteo -- AND f_registro::DATE = dFechaMovimiento
				   AND numcte = cNumCliente AND estado = 2 AND foliosuc = cFolioSucursal
				ORDER BY boleto_ini

					WHILE (iBoletos_ini <= iBoletos_fin)
						--INSERTA BOLETO DISPERSADO
						INSERT INTO BdInteg:si_dispercionboletostmp (boleto, f_registro, numcte, foliosuc, importe)
							VALUES (iBoletos_ini, dFecha_Reg, cNumCte, cFolioSuc, iMonto);

						LET iBoletos_ini = iBoletos_ini + 1;
						LET bFlag = 'V';
					END WHILE;

			END FOREACH;

			ELIF (iTipoOperacion = '2') THEN -- NUM CUENTA / CREDITO

				IF (cTipoSistema = 'D') THEN --DEBITO
					SELECT FIRST 1 Num_Cte
                      INTO cNumCliente
                      FROM BdiCheq:SC_Maechq
                     WHERE Cuenta = cNumCuenta;
				ELIF (cTipoSistema = 'C') THEN --CREDITO
					SELECT FIRST 1 NumCte 
                      INTO cNumCliente 
                      FROM BdiCred:Sd_Maecred  
                     WHERE num_credito = cNumCuenta;
				END IF;

				LET dtFechaIni = NVL (dFechaMovimiento, dtFechaIni);

				--OBTIENE LOS REGISTROS DE LOS BOLETOS.
				FOREACH

    				SELECT {INDEX (BdInteg:si_boleto_hist_index3)} boleto_ini, boleto_fin, f_registro::DATE,
                            numcte, foliosuc, importe
				      INTO iBoletos_ini, iBoletos_fin, dFecha_Reg, cNumCte, cFolioSuc, iMonto
					  FROM BdInteg:si_boleto_hist
					 WHERE cve_sorteo = sCve_Sorteo -- AND f_registro::DATE = dtFechaIni
					   AND numcte = cNumCliente AND estado = 2 AND foliosuc <> ''
				     ORDER BY boleto_ini

					WHILE (iBoletos_ini <= iBoletos_fin)
						--INSERTA BOLETO DISPERSADO
						INSERT INTO BdInteg:si_dispercionboletostmp (boleto, f_registro, numcte, foliosuc, importe)
							VALUES (iBoletos_ini, dFecha_Reg, cNumCte, cFolioSuc, iMonto);

						LET iBoletos_ini = iBoletos_ini + 1;
						LET bFlag = 'V';
					END WHILE;

				END FOREACH;
			END IF;

			IF (bFlag = 'V') THEN --VALIDA KE LA TABLA CONTENGA REGISTROS DE BOLETOS

				--SKIP
				FOREACH SELECT boleto, f_registro, numcte, foliosuc, importe
					      INTO iBoletos_ini, dFecha_Reg, cNumCte, cFolioSuc, iMonto
                          FROM BdInteg:si_dispercionboletostmp
					     WHERE boleto >= 0 AND foliosuc > 0
					     ORDER BY boleto

					LET siCiclo = siCiclo + 1;
					IF siCiclo <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;

					RETURN cCodRet, iBoletos_ini, dFecha_Reg, cNumCte, cFolioSuc, iMonto WITH RESUME;

				END FOREACH;

			ELIF (bFlag = 'F') THEN -- NO EXISTEN REG PARA LA CONSULTA
				RETURN '00004', 0, '01/01/1900', '', '', 0 WITH RESUME;
			END IF;

		-- BORRA LA TABLA DE TRABAJO
		IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'si_dispercionboletostmp') THEN
			DROP TABLE BdInteg:si_dispercionboletostmp;
		END IF;

	END;
END PROCEDURE;