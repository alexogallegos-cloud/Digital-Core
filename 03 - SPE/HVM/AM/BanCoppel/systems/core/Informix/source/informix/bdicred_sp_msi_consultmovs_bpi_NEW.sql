-- BD bdicred

DROP PROCEDURE "informix".sp_msi_consultmovs_bpi(
    CHAR(3),
    CHAR(20),
    DATE,
    DATE,
    INTEGER
);


CREATE PROCEDURE "informix".sp_msi_consultmovs_bpi(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro INTEGER)
RETURNING CHAR(5),DATE,CHAR(40),CHAR(60),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(4),CHAR(1);

--Variables auxiliares
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE vcodret         CHAR(6);
DEFINE cMensajeRet     CHAR(80);


--Definicion de variables
DEFINE vserial       INTEGER;
DEFINE vfecha        DATE;
DEFINE vRefTotal CHAR(100);
DEFINE cDescripcion     CHAR(60);
DEFINE vnaturaleza   CHAR(1);
DEFINE vmonto        MONEY(14,2);
DEFINE vReferencia23  CHAR(23);
DEFINE vRfcComer     CHAR(15);
DEFINE vTrans     CHAR(4);
DEFINE vTarjeta   CHAR(20);
DEFINE vTipo         CHAR(1);
DEFINE cFolioSuc                CHAR(16);
DEFINE iNumPago                 INTEGER;
DEFINE iPlazo           INTEGER;
DEFINE vComercio        VARCHAR(40);
DEFINE vReferencia    CHAR(40);
DEFINE vTerminacion CHAR(4);
DEFINE vSdoDeudorMSI    DECIMAL(14,2);
DEFINE vMotivoCancel            CHAR(80);
DEFINE dtmFechaCancela DATETIME YEAR TO SECOND;


LET vcodret             = "000";
LET cMensajeRet         = "Se realizo la consulta correctamente";
LET vserial = 0;
LET vfecha = '01/01/1900';
LET vRefTotal = "";
LET cDescripcion = " ";
LET vnaturaleza = '';
LET vmonto = 0;
LET vReferencia23 = '';
LET vRfcComer = '';
LET vTrans = '';
LET vTarjeta ='';
LET vTipo ='';
LET cFolioSuc = "";
LET iNumPago    = 0;
LET iPlazo = 0;
LET vComercio = "";
LET vReferencia = '';
LET vTerminacion ='';
LET vSdoDeudorMSI = 0;
LET vMotivoCancel = "";
LET dtmFechaCancela = '';


 -- *****************************************************************************************************
   -- Obejtivo:                 Consulta de Movimietos MSI
   -- Creado por:               Roque Heras
   -- Solicitado por:   Gabriela Aguilar
   -- Fecha:                    29/04/2022
   -- *****************************************************************************************************
   -- Modificado ORP AMS 2.0 Sep2026 / se cambian consultas a intercard:movimiento y se consulta directo a intercard:movimiento_dia y intercard:movimiento_all
BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
           IF iSqlErr != 0 THEN
                  LET vcodret = iSqlErr;
                  LET cMensajeRet = cErrorInfo;
                  RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo;
           END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        --SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_msi_consultmovs_bpi.out';
        --TRACE ON;

        -- Productos permitidos:
        -- 8900 - MESES SIN INTERESES

		FOREACH
				(
				SELECT SKIP pRegistro FIRST 10
					movd.secuencia, movd.fecha_mov,
					CASE WHEN NVL(TRIM(movd.referencia),'') = '' THEN tfun.transacc ELSE TRIM(movd.referencia) END CASE,
					tfun.descripcion, tcc.naturaleza, movd.monto, movd.referencia23, movd.rfc_comer, tcc.numero, '' AS num_tarjeta, 'S' AS tipo_tarjeta, movd.folio_suc,
					ac.num_pago AS numpago, mae.plazo, imov.infreceptor, mccm.fecha_cancela, mccm.motivo_de_cancelacion
					INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto,vReferencia23,vRfcComer,vTrans,vTarjeta,vTipo,cFolioSuc,iNumPago,iPlazo,vComercio,dtmFechaCancela,vMotivoCancel
				FROM bdicred:sd_promocion_credito pm
				INNER JOIN bdicred:sd_maecredcrd mae ON (pm.num_sol_prestamo = mae.num_credito)
				INNER JOIN bdicred:sd_movdiacrd movd ON (movd.num_credito = pm.num_sol_prestamo)
				INNER JOIN bdicred:sd_transfun tfun ON (tfun.codigo_fun = movd.codigo_fun AND tfun.codigo_ref = movd.codigo_ref)
				INNER JOIN bdinteg:si_transacc tcc ON (tcc.numero = tfun.transacc)
				LEFT OUTER JOIN bdicred:sd_msi_cancela_credito_msi mccm ON (mccm.num_credito = pm.num_sol_prestamo)
				LEFT JOIN bdicred:sd_amortiza_creditocrd ac ON (ac.num_credito = pm.num_sol_prestamo AND ac.fecha_cuota = movd.fecha_mov)
				LEFT JOIN intercard:movimiento_dia imov ON (imov.secuenciaextendida = pm.folio_movto) -- Movimientos del día con sd_movdiacrd
				WHERE pm.empresa = pEmpresa
					AND pm.num_credito = pNumCredito
					AND pm.num_pro_prestamo = 8900
					AND movd.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
					AND tcc.se_emite_edocta = "S"
					AND movd.reversado = "N"

				UNION ALL

				SELECT movd.secuencia, movd.fecha_mov,
					CASE WHEN NVL(TRIM(movd.referencia),'') = '' THEN tfun.transacc ELSE TRIM(movd.referencia) END CASE,
					tfun.descripcion, tcc.naturaleza, movd.monto, movd.referencia23, movd.rfc_comer, tcc.numero, '' AS num_tarjeta, 'S' AS tipo_tarjeta, movd.folio_suc,
					ac.num_pago AS numpago, mae.plazo, imov.infreceptor, mccm.fecha_cancela, mccm.motivo_de_cancelacion
				FROM bdicred:sd_promocion_credito pm
				INNER JOIN bdicred:sd_maecredcrd mae ON (pm.num_sol_prestamo = mae.num_credito)
				INNER JOIN bdicred:sd_movhiscrd movd ON (movd.num_credito = pm.num_sol_prestamo)
				INNER JOIN bdicred:sd_transfun tfun ON (tfun.codigo_fun = movd.codigo_fun AND tfun.codigo_ref = movd.codigo_ref)
				INNER JOIN bdinteg:si_transacc tcc ON (tcc.numero = tfun.transacc)
				LEFT OUTER JOIN bdicred:sd_msi_cancela_credito_msi mccm ON (mccm.num_credito = pm.num_sol_prestamo)
				LEFT JOIN bdicred:sd_amortiza_creditocrd ac ON (ac.num_credito = pm.num_sol_prestamo AND ac.fecha_cuota = movd.fecha_mov)
				LEFT JOIN intercard:movimiento_all imov ON (imov.secuenciaextendida = pm.folio_movto) -- Movimientos históricos con bdicred:sd_movhiscrd
				WHERE pm.empresa = pEmpresa
					AND pm.num_credito = pNumCredito
					AND pm.num_pro_prestamo = 8900
					AND movd.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
					AND tcc.se_emite_edocta = "S"
					AND movd.reversado = "N"
				) ORDER BY tipo_tarjeta DESC, num_tarjeta ASC, fecha_mov DESC, secuencia DESC

                LET iNumPago = NVL(iNumPago, 0);
                LET vComercio = TRIM(NVL(vComercio, ''));
                LET vReferencia = vComercio; /*TRIM(vRefTotal);*/
                LET cDescripcion = TRIM(cDescripcion);

        IF vnaturaleza = "C" THEN
           LET vmonto = (vmonto*(-1));
        END IF;

                CASE vTrans
                        WHEN "4265" THEN --Compras MSI
                                LET cDescripcion = "COMPRA MESES SIN INTERESES " || iPlazo || " MESES";

                        WHEN "4250" THEN --Cancelacion: A SOLICITUD DEL CLIENTE
                                LET cDescripcion = "Cancela MSI";

                        WHEN "4260" THEN --Cancelacion: CANCELACION AUTOMATICA
                                LET cDescripcion = "Cancel-atraso MSI";

                        WHEN "4266" THEN --Pagos MSI
                                LET cDescripcion = "SU PAGO TDC - MESES SIN INTERESES " || iNumPago || " de " || iPlazo;

                        ELSE
                                --Resto de transacciones a MSI: (4264, 4267, 4253, 4261)
                END CASE;


                RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo WITH RESUME;

        END FOREACH;

        IF DBINFO("sqlca.sqlerrd2") <=  0 THEN
           LET vcodret = "002"; --No existen registros con el filtro de consulta indicado.
           RETURN vcodret, vfecha, vReferencia, cDescripcion, vnaturaleza, vmonto,vSdoDeudorMSI, vTerminacion, vTipo;
        END IF;

END
END PROCEDURE;