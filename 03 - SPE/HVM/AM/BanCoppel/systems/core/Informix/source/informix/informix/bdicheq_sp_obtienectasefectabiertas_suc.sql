CREATE PROCEDURE "informix".sp_obtienectasefectabiertas_suc(pEmpresa CHAR(3))
--DATOS A REGRESAR--
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret                    CHAR(5);
DEFINE iSqlErr, iIsamErr         INTEGER;
DEFINE cNombreArchivo            CHAR(50);
DEFINE cSql                        CHAR(3000);
DEFINE cRuta                    CHAR(50);
DEFINE cEncabezado                CHAR(2000);
DEFINE dFechaHoy                DATE;
DEFINE iDias                    INTEGER;
DEFINE iDia                        INTEGER;
DEFINE iMes                        INTEGER;
DEFINE cMes                        CHAR(2);
DEFINE cNomMes                     CHAR(20);
DEFINE iAnio                    INTEGER;
DEFINE iBiciesto                INTEGER;
DEFINE dFechaIni                DATE;
DEFINE dFechaFin                DATE;
DEFINE dtFechaIni                DATETIME YEAR TO SECOND;
DEFINE dtFechaFin                DATETIME YEAR TO SECOND;
DEFINE dFechaArchivo            DATE;
DEFINE dFecIniAcumulado            DATE;
DEFINE cSucursal                CHAR(4);
DEFINE cClaveSuc                CHAR(5);
DEFINE cProducto                CHAR(4);
DEFINE cNombreProd                CHAR(40);
DEFINE cNumTarjeta                CHAR(20);
DEFINE dFechaAsignacion            DATE;
DEFINE cTipoTarjeta                CHAR(1);
DEFINE cTipoAsignacion            CHAR(1);
DEFINE cCobroComision            CHAR(1);
DEFINE cCuenta                    CHAR(20);
DEFINE iTarjetasEntregadas         INTEGER;
DEFINE iTarjetasEntregadastot         INTEGER;
DEFINE iTarjSuceptibleCobro        INTEGER;
DEFINE iTarjSuceptibleCobrotot        INTEGER;
DEFINE iTarjetasCobradas         INTEGER;
DEFINE iTarjetasCobradastot         INTEGER;
DEFINE iTarjCondonadasGte         INTEGER;
DEFINE iTarjCondonadasGtetot         INTEGER;
DEFINE mMtoTotalSuceptibleCobro DECIMAL(14,2);
DEFINE mMtoTotalSuceptibleCobrotot DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradas     DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradastot     DECIMAL(14,2);
DEFINE dcCostoPromedioComision     DECIMAL(14,2);
DEFINE dcCostoPromedioComisiontot     DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobro DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobrotot DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGte     DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGtetot     DECIMAL(14,2);
DEFINE iTarjetasEntregadasMes    INTEGER;
DEFINE iTarjSuceptibleCobroMes    INTEGER;
DEFINE iTarjetasCobradasMes        INTEGER;
DEFINE iTarjCondonadasGteMes    INTEGER;
DEFINE mMtoTotalSuceptibleCobroMes DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradasMes    DECIMAL(14,2);
DEFINE dcCostoPromedioComisionMes DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobroMes DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGteMes DECIMAL(14,2);
DEFINE iTarjetasEntregadasAcum    INTEGER;
DEFINE iTarjSuceptibleCobroAcum    INTEGER;
DEFINE iTarjetasCobradasAcum    INTEGER;
DEFINE iTarjCondonadasGteAcum    INTEGER;
DEFINE mMtoTotalSuceptibleCobroAcum DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradasAcum DECIMAL(14,2);
DEFINE dcCostoPromedioComisionAcum DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobroAcum DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGteAcum DECIMAL(14,2);
DEFINE cIva                        CHAR(100);
DEFINE mMontoTot                MONEY(14,2);
DEFINE mMtoTot                    MONEY(14,2);
DEFINE mMontoCom                MONEY(14,2);
DEFINE cEstadoCom                CHAR(1);
DEFINE iCobrada                 INTEGER;
DEFINE cEtiqueta                 CHAR(40);
DEFINE iBanRegs                    INTEGER;
DEFINE cSucursales                CHAR(5);
DEFINE cSucursalant                CHAR(5);
DEFINE cSucursalexist            CHAR(5);
DEFINE cBandera		    INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodret                    = '00000';
LET iSqlErr                 = 0;
LET iIsamErr                 = 0;
LET cNombreArchivo            = '';
LET cSql                    = '';
LET cRuta                    = '';
LET cEncabezado                = '';
LET dFechaHoy                = '';
LET iDias                    = 0;
LET iDia                    = 0;
LET iMes                    = 0;
LET cMes                    = '';
LET cNomMes                 = '';
LET iAnio                    = 0;
LET iBiciesto                = 0;
LET dFechaIni                = '';
LET dFechaFin                = '';
LET dtFechaIni                = '';
LET dtFechaFin                = '';
LET dFechaArchivo            = '';
LET dFecIniAcumulado         = '';
LET cSucursal                = '';
LET cClaveSuc                = '';
LET cProducto                = '';
LET cNombreProd                = '';
LET cNumTarjeta                = '';
LET dFechaAsignacion        = '';
LET cTipoTarjeta            = '';
LET cTipoAsignacion            = '';
LET cCobroComision            = '';
LET cCuenta                    = '';
LET iTarjetasEntregadas     = 0;
LET iTarjetasEntregadastot     = 0;
LET iTarjSuceptibleCobro     = 0;
LET iTarjSuceptibleCobrotot     = 0;
LET iTarjetasCobradas         = 0;
LET iTarjetasCobradastot         = 0;
LET iTarjCondonadasGte         = 0;
LET iTarjCondonadasGtetot         = 0;
LET mMtoTotalSuceptibleCobro = 0;
LET mMtoTotalSuceptibleCobrotot = 0;
LET mMtoTotalTarjCobradas     = 0;
LET mMtoTotalTarjCobradastot     = 0;
LET dcCostoPromedioComision = 0;
LET dcCostoPromedioComisiontot = 0;
LET dcPorcTarjSuceptibleCobro = 0;
LET dcPorcTarjSuceptibleCobrotot = 0;
LET dcPorcTarjCondonadasGte = 0;
LET dcPorcTarjCondonadasGtetot = 0;
LET iTarjetasEntregadasMes    = 0;
LET iTarjSuceptibleCobroMes    = 0;
LET iTarjetasCobradasMes    = 0;
LET iTarjCondonadasGteMes    = 0;
LET mMtoTotalSuceptibleCobroMes = 0;
LET mMtoTotalTarjCobradasMes = 0;
LET dcCostoPromedioComisionMes = 0;
LET dcPorcTarjSuceptibleCobroMes = 0;
LET dcPorcTarjCondonadasGteMes = 0;
LET iTarjetasEntregadasAcum    = 0;
LET iTarjSuceptibleCobroAcum = 0;
LET iTarjetasCobradasAcum     = 0;
LET iTarjCondonadasGteAcum    = 0;
LET mMtoTotalSuceptibleCobroAcum = 0;
LET mMtoTotalTarjCobradasAcum = 0;
LET dcCostoPromedioComisionAcum = 0;
LET dcPorcTarjSuceptibleCobroAcum = 0;
LET dcPorcTarjCondonadasGteAcum = 0;
LET cIva                    = 0;
LET mMontoTot                = 0;
LET mMtoTot                    = 0;
LET mMontoCom                = 0;
LET cEstadoCom                 = '';
LET iCobrada                 = 0;
LET cEtiqueta                 = 0;
LET iBanRegs                = 0;
LET cSucursales                = '';
LET cSucursalant            = '';
LET cSucursalexist          = '';
LET cBandera                = 0;

--SET DEBUG FILE TO "/informix/1170/german/sp_obtienectasefectabiertasucursal.out";
--TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
            LET cCodret = iSqlErr;
            RETURN cCodret;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

    SELECT fecha_hoy INTO dFechaHoy FROM "informix".sc_fechas WHERE empresa = pEmpresa;

    IF NVL(dFechaHoy,'') <> '' THEN
        LET iDia = DAY(dFechaHoy);
        LET iMes = MONTH(dFechaHoy);
        LET iAnio = YEAR(dFechaHoy);

        IF iMes = 1 THEN
            LET iMes = 12;
            LET iAnio = iAnio -1;
        ELSE
            LET iMes = iMes -1;
        END IF;

        LET cMes = LPAD(iMes,2,'0');
        LET iBiciesto= MOD(iAnio,4);

        IF iMes = 1 OR iMes = 3 OR iMes = 5 OR iMes = 7 OR iMes = 8 OR iMes = 10 OR iMes = 12 THEN
            LET iDias = 31;
        ELIF iMes = 2 THEN
            LET iDias = 28;
            IF iBiciesto = 0 THEN
                LET iDias = iDias + 1;
            END IF;
        ELIF iMes = 4 OR iMes = 6 OR iMes = 9 OR iMes = 11 THEN
            LET iDias = 30;
        END IF;

        IF iMes = 1  THEN LET cNomMes = 'ENERO';      END IF;
        IF iMes = 2  THEN LET cNomMes = 'FEBRERO';    END IF;
        IF iMes = 3  THEN LET cNomMes = 'MARZO';      END IF;
        IF iMes = 4  THEN LET cNomMes = 'ABRIL';      END IF;
        IF iMes = 5  THEN LET cNomMes = 'MAYO';       END IF;
        IF iMes = 6  THEN LET cNomMes = 'JUNIO';      END IF;
        IF iMes = 7  THEN LET cNomMes = 'JULIO';      END IF;
        IF iMes = 8  THEN LET cNomMes = 'AGOSTO';     END IF;
        IF iMes = 9  THEN LET cNomMes = 'SEPTIEMBRE'; END IF;
        IF iMes = 10 THEN LET cNomMes = 'OCTUBRE';    END IF;
        IF iMes = 11 THEN LET cNomMes = 'NOVIEMBRE';  END IF;
        IF iMes = 12 THEN LET cNomMes = 'DICIEMBRE';  END IF;

        LET cNombreArchivo = "Tdentregadasporsuc" || LPAD(iDia,2,'0') || cMes || iAnio;

        SELECT valor INTO cRuta FROM bdinteg:"informix".si_param WHERE empresa = pEmpresa AND cod_param = 141;

        LET dFechaIni = cMes || '/01/' || TO_CHAR(iAnio);
        LET dFechaFin = cMes || '/' || TO_CHAR(iDias) || '/' || TO_CHAR(iAnio);
        LET dFechaArchivo = cMes || '/' || '02' || '/' || iAnio;
        LET dFecIniAcumulado = '01/01/' || TO_CHAR(iAnio);

        LET dtFechaIni = dFechaIni::DATETIME YEAR TO SECOND;
        LET dtFechaFin = (dFechaFin + 1 UNITS DAY)::DATETIME YEAR TO SECOND;

        IF NVL(cRuta,'') <> '' THEN
            LET cEncabezado = "SUCURSAL|PRODUCTO|ENTREGADAS|SUCEPTIBLES DE COBRO|$|COBRADAS|$|COSTO PROMEDIO COMISION|%|CONDONADAS POR GERENTE|%";

            LET cSql = 'echo "' || TRIM(cEncabezado) || '" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
            SYSTEM cSql;

            SELECT valor INTO cIva FROM bdinteg:"informix".si_param WHERE empresa = pEmpresa AND cod_param = 47;

			
            FOREACH
              
                SELECT sucursal INTO cSucursal
                FROM bdinteg:"informix".si_sucursales
                WHERE empresa = pEmpresa AND tpo_sucursal = 'S'
                ORDER BY sucursal

                LET cClaveSuc = cSucursal;

                FOREACH
                    --PRODUCTO
                    SELECT producto INTO cProducto
                    FROM "informix".sc_producto
                    WHERE empresa = pEmpresa AND producto IN('1500','1900','2000','2500')
                    ORDER BY producto

                    FOREACH
                        SELECT {+MULTI_INDEX(bdicheq:"informix".sc_maechq)} tarj.numtarjeta, DATE(tarj.fechaasignacion), cheq.cuenta, cheq.tipo_tarjeta, cheq.tipo_asignacion, cheq.cobro_comision
                        INTO cNumTarjeta, dFechaAsignacion, cCuenta, cTipoTarjeta, cTipoAsignacion, cCobroComision
                        FROM intercard:"informix".tarjeta tarj, "informix".sc_tarjeta cheq , bdicheq:"informix".sc_maechq mae
                        WHERE tarj.fechaasignacion >= dtFechaIni AND tarj.fechaasignacion < dtFechaFin
                        AND SUBSTR(tarj.numtarjeta,1,6) IN(SELECT {+INDEX(intercard:"informix".tipotarjeta idx_tipotarjeta)} bin
                            FROM intercard:"informix".tipotarjeta WHERE chip = 'V'
							  AND tipo = 'D')
                        AND tarj.numtarjeta = cheq.num_tarjeta AND cheq.empresa = '001'
						AND cheq.cuenta = mae.cuenta AND mae.sucursal = cClaveSuc
						AND mae.producto = cProducto

                        IF NVL(cNumTarjeta,'') <> '' THEN
                            LET iBanRegs = 1;

                            IF (NVL(cTipoAsignacion,'') = 'N' OR NVL(cTipoAsignacion,'') = 'R') AND (NVL(cCobroComision,'') = 'S' OR NVL(cCobroComision,'') = 'N') THEN
                                --TARJETAS ENTREGADAS
                                LET iTarjetasEntregadas = iTarjetasEntregadas + 1;

                                IF NVL(cCobroComision,'') = 'S' THEN
                                    --TARJETAS SUCEPTIBLES DE COBRO
                                    LET iTarjSuceptibleCobro = iTarjSuceptibleCobro + 1;

                                    IF NVL(cTipoAsignacion,'') = 'N' THEN
                                        SELECT SUM(monto_tot) INTO mMtoTot
                                        FROM "informix".sc_movhis
                                        WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362')
                                        AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
                                    ELIF NVL(cTipoAsignacion,'') = 'R' THEN
                                        SELECT SUM(monto_tot) INTO mMtoTot
                                        FROM "informix".sc_movhis
                                        WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363')
                                        AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
                                    END IF;

                                    IF NVL(mMtoTot,0) = 0 THEN
                                        IF NVL(cTipoAsignacion,'') = 'N' THEN
                                            SELECT SUM(monto_tot) INTO mMtoTot
                                            FROM "informix".sc_movhis_old
                                            WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362')
                                            AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
                                        ELIF NVL(cTipoAsignacion,'') = 'R' THEN
                                            SELECT SUM(monto_tot) INTO mMtoTot
                                            FROM "informix".sc_movhis_old
                                            WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363')
                                            AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
                                        END IF;
                                    END IF;

                                    IF NVL(mMtoTot,0) = 0 THEN
                                        IF NVL(cTipoAsignacion,'') = 'N' THEN
                                            SELECT FIRST 1 monto_com, estado_com INTO mMontoTot, cEstadoCom
                                            FROM "informix".sc_detcomis
                                            WHERE empresa = pEmpresa AND cuenta = cCuenta
                                            AND comision = '3260' AND fecha_alta = dFechaAsignacion;
                                        ELIF NVL(cTipoAsignacion,'') = 'R' THEN
                                            SELECT FIRST 1 monto_com, estado_com INTO mMontoTot, cEstadoCom
                                            FROM "informix".sc_detcomis
                                            WHERE empresa = pEmpresa AND cuenta = cCuenta
                                            AND comision = '3261' AND fecha_alta = dFechaAsignacion;
                                        END IF;

                                        LET mMontoCom = TRUNC((NVL(mMontoTot,0) * cIVA),2);
                                        LET mMtoTot = NVL(mMontoTot,0) + NVL(mMontoCom,0);
                                        LET mMontoTot = 0;
                                        LET mMontoCom = 0;
                                    ELSE
                                        LET iTarjetasCobradas = iTarjetasCobradas + 1;
                                        LET iCobrada = 1;
                                    END IF;

                                    IF iCobrada = 1 THEN
                                        --MONTO TOTAL DE TARJETAS COBRADAS
                                        LET mMtoTotalTarjCobradas = mMtoTotalTarjCobradas + NVL(mMtoTot,0);
                                    END IF;

                                    --MONTO TOTAL DE TARJETAS SUCEPTIBRES DE COBRO
                                    LET mMtoTotalSuceptibleCobro = mMtoTotalSuceptibleCobro + NVL(mMtoTot,0);
                                    LET mMtoTot = 0;
                                    LET iCobrada = 0;
                                  
                                ELIF NVL(cCobroComision,'') = 'N' THEN
                                    --TARJETAS CONDONADAS POR GERENTE
                                    LET iTarjCondonadasGte = iTarjCondonadasGte + 1;
                                END IF;
                            END IF;
                        END IF;
                    END FOREACH;

                    IF NVL(iTarjSuceptibleCobro,0) > 0 THEN
                        --COSTO PROMEDIO COMISION
                        LET dcCostoPromedioComision = NVL(mMtoTotalSuceptibleCobro,0) / iTarjSuceptibleCobro;
                    END IF;

                    IF NVL(iTarjetasEntregadas,0) > 0 THEN
                        --PORCENTAJE TARJETAS SUCEPTIBLES DE COBRO
                        LET dcPorcTarjSuceptibleCobro = (NVL(iTarjSuceptibleCobro,0) * 100) / iTarjetasEntregadas;

                        --PORCENTAJE TARJETAS CONDONADAS POR GERENTE
                        LET dcPorcTarjCondonadasGte = (NVL(iTarjCondonadasGte,0) * 100) / iTarjetasEntregadas;
                    END IF;

                    IF iBanRegs = 1  OR iTarjetasEntregadas <> 0  THEN
                        INSERT INTO "informix".sc_acumuladostddentregadas_suc(sucursal,producto,tarjetasentregadas,tarjsuceptiblecobro,mtototalsuceptiblecobro,
                            tarjetascobradas,mtototaltarjcobradas,costopromediocomision,porctarjsuceptiblecobro,tarjcondonadasgte,porctarjcondonadasgte,
                            fechainsert)
                        VALUES(TRIM(cSucursal),TRIM(cProducto),iTarjetasEntregadas,iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,
                            iTarjetasCobradas,mMtoTotalTarjCobradas,dcCostoPromedioComision,dcPorcTarjSuceptibleCobro,iTarjCondonadasGte,dcPorcTarjCondonadasGte,
                            dFechaArchivo);
                      
                        LET iBanRegs = 0;
                      
                      
                        ELSE
                  
                                                              
                    LET iTarjetasEntregadas     = 0;
                    LET iTarjSuceptibleCobro     = 0;
                    LET mMtoTotalSuceptibleCobro = 0;
                    LET iTarjetasCobradas         = 0;
                    LET mMtoTotalTarjCobradas     = 0;
                    LET dcCostoPromedioComision = 0;
                    LET dcPorcTarjSuceptibleCobro = 0;
                    LET iTarjCondonadasGte         = 0;
                    LET dcPorcTarjCondonadasGte = 0;
                  
                        INSERT INTO "informix".sc_acumuladostddentregadas_suc(sucursal,producto,tarjetasentregadas,tarjsuceptiblecobro,mtototalsuceptiblecobro,
                            tarjetascobradas,mtototaltarjcobradas,costopromediocomision,porctarjsuceptiblecobro,tarjcondonadasgte,porctarjcondonadasgte,
                            fechainsert)
                        VALUES(TRIM(cSucursal),TRIM(cProducto),iTarjetasEntregadas,iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,
                            iTarjetasCobradas,mMtoTotalTarjCobradas,dcCostoPromedioComision,dcPorcTarjSuceptibleCobro,iTarjCondonadasGte,dcPorcTarjCondonadasGte,
                            dFechaArchivo);
                          
                    END IF;

                    LET iTarjetasEntregadas     = 0;
                    LET iTarjSuceptibleCobro     = 0;
                    LET mMtoTotalSuceptibleCobro = 0;
                    LET iTarjetasCobradas         = 0;
                    LET mMtoTotalTarjCobradas     = 0;
                    LET dcCostoPromedioComision = 0;
                    LET dcPorcTarjSuceptibleCobro = 0;
                    LET iTarjCondonadasGte         = 0;
                    LET dcPorcTarjCondonadasGte = 0;
                END FOREACH;
            END FOREACH;
          
                    
                 LET cSucursalant = '';
                 
                              
              FOREACH
            

                SELECT acum.sucursal, prod.producto, prod.nombre,SUM(tarjetasentregadas),SUM(tarjsuceptiblecobro),SUM(mtototalsuceptiblecobro),SUM(tarjetascobradas),SUM(mtototaltarjcobradas),
                    SUM(costopromediocomision),SUM(porctarjsuceptiblecobro),SUM(tarjcondonadasgte),SUM(porctarjcondonadasgte)
                INTO cSucursales,cProducto,cNombreProd,iTarjetasEntregadas,iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,iTarjetasCobradas,mMtoTotalTarjCobradas,
                    dcCostoPromedioComision,dcPorcTarjSuceptibleCobro,iTarjCondonadasGte,dcPorcTarjCondonadasGte
                FROM bdicheq:sc_acumuladostddentregadas_suc acum inner join bdicheq:sc_producto prod on acum.producto=prod.producto
                WHERE  acum.fechainsert = dFechaArchivo AND prod.empresa = pEmpresa     
                GROUP BY acum.sucursal,prod.producto,prod.nombre
                        ORDER BY sucursal,producto
                                      
                            

                  
                    IF cSucursales <> cSucursalant AND cSucursalant <> '' THEN
              
                    SELECT SUM(tarjetasentregadas),SUM(tarjsuceptiblecobro),SUM(mtototalsuceptiblecobro),SUM(tarjetascobradas),SUM(mtototaltarjcobradas),
                    SUM(costopromediocomision),SUM(porctarjsuceptiblecobro),SUM(tarjcondonadasgte),SUM(porctarjcondonadasgte)
                    INTO iTarjetasEntregadastot,iTarjSuceptibleCobrotot,mMtoTotalSuceptibleCobrotot,iTarjetasCobradastot,mMtoTotalTarjCobradastot,
                    dcCostoPromedioComisiontot,dcPorcTarjSuceptibleCobrotot,iTarjCondonadasGtetot,dcPorcTarjCondonadasGtetot
                    FROM bdicheq:sc_acumuladostddentregadas_suc where sucursal = cSucursalant AND fechainsert = dFechaArchivo;

                  
                    LET cSql = '';
                    LET cEtiqueta = 'TOTAL SUC' || cSucursalant || 'MES' ||'|'||cNomMes;
                    LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadastot,0) || '|' || NVL(iTarjSuceptibleCobrotot,0) || '|' || NVL(mMtoTotalSuceptibleCobrotot,0) || '|' || NVL(iTarjetasCobradastot,0) || '|' || NVL(mMtoTotalTarjCobradastot,0) || '|' || NVL(dcCostoPromedioComisiontot,0) || '|' || NVL(dcPorcTarjSuceptibleCobrotot,0) || '|' || NVL(iTarjCondonadasGtetot,0) || '|' || NVL(dcPorcTarjCondonadasGtetot,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
                    SYSTEM cSql;  
                  
					LET iTarjetasEntregadastot     = 0;
					LET iTarjSuceptibleCobrotot     = 0;
					LET mMtoTotalSuceptibleCobrotot = 0;
					LET iTarjetasCobradastot         = 0;
					LET mMtoTotalTarjCobradastot     = 0;
					LET dcCostoPromedioComisiontot = 0;
					LET dcPorcTarjSuceptibleCobrotot = 0;
					LET iTarjCondonadasGtetot         = 0;
					LET dcPorcTarjCondonadasGtetot = 0;
					LET cBandera                =1;

                    END IF;
                              
                   IF cBandera=0 OR (cSucursales <> cSucursalant AND cSucursalant <> '') THEN

                    LET cSql = 'echo "'||TRIM  (NVL(cSucursales,0)) ||'|'|| TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(iTarjSuceptibleCobro,0) || '|' || NVL(mMtoTotalSuceptibleCobro,0) || '|' || NVL(iTarjetasCobradas,0) || '|' || NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(dcCostoPromedioComision,0) || '|' || NVL(dcPorcTarjSuceptibleCobro,0) || '|' || NVL(iTarjCondonadasGte,0) || '|' || NVL(dcPorcTarjCondonadasGte,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
                    SYSTEM cSql;
                  
		           END IF;
              
             
                          
                LET iTarjetasEntregadas     = 0;
                LET iTarjSuceptibleCobro     = 0;
                LET mMtoTotalSuceptibleCobro = 0;
                LET iTarjetasCobradas         = 0;
                LET mMtoTotalTarjCobradas     = 0;
                LET dcCostoPromedioComision = 0;
                LET dcPorcTarjSuceptibleCobro = 0;
                LET iTarjCondonadasGte         = 0;
                LET dcPorcTarjCondonadasGte = 0;
                LET cSucursalant = cSucursales;
				LET cNombreProd        	   =0;
				LET cProducto 				= 0;
       	        LET cBandera                =0;

              END FOREACH;
            
            
                              
            FOREACH
                --RENGLON DEL DETALLE POR PRODUCTO
                SELECT producto, nombre               
                INTO cProducto, cNombreProd
                FROM "informix".sc_producto
                WHERE empresa = pEmpresa AND producto IN('1500','1900','2000','2500')
                ORDER BY producto
          
          
                SELECT SUM(tarjetasentregadas),SUM(tarjsuceptiblecobro),SUM(mtototalsuceptiblecobro),SUM(tarjetascobradas),SUM(mtototaltarjcobradas),
                    SUM(costopromediocomision),SUM(porctarjsuceptiblecobro),SUM(tarjcondonadasgte),SUM(porctarjcondonadasgte)
                INTO iTarjetasEntregadas,iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,iTarjetasCobradas,mMtoTotalTarjCobradas,
                    dcCostoPromedioComision,dcPorcTarjSuceptibleCobro,iTarjCondonadasGte,dcPorcTarjCondonadasGte
                FROM "informix".sc_acumuladostddentregadas_suc
                WHERE producto = cProducto AND fechainsert = dFechaArchivo;
              
              
                LET cSql = 'echo "'|| TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(iTarjSuceptibleCobro,0) || '|' || NVL(mMtoTotalSuceptibleCobro,0) || '|' || NVL(iTarjetasCobradas,0) || '|' || NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(dcCostoPromedioComision,0) || '|' || NVL(dcPorcTarjSuceptibleCobro,0) || '|' || NVL(iTarjCondonadasGte,0) || '|' || NVL(dcPorcTarjCondonadasGte,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
                SYSTEM cSql;
              
                -- RENGLON DEL DETALLE POR MES
                LET iTarjetasEntregadasMes = iTarjetasEntregadasMes + iTarjetasEntregadas;
                LET iTarjSuceptibleCobroMes = iTarjSuceptibleCobroMes + iTarjSuceptibleCobro;
                LET iTarjetasCobradasMes = iTarjetasCobradasMes + iTarjetasCobradas;
                LET iTarjCondonadasGteMes = iTarjCondonadasGteMes + iTarjCondonadasGte;
                LET mMtoTotalSuceptibleCobroMes = mMtoTotalSuceptibleCobroMes + mMtoTotalSuceptibleCobro;
                LET mMtoTotalTarjCobradasMes = mMtoTotalTarjCobradasMes + mMtoTotalTarjCobradas;

                LET iTarjetasEntregadas     = 0;
                LET iTarjSuceptibleCobro     = 0;
                LET mMtoTotalSuceptibleCobro = 0;
                LET iTarjetasCobradas         = 0;
                LET mMtoTotalTarjCobradas     = 0;
                LET dcCostoPromedioComision = 0;
                LET dcPorcTarjSuceptibleCobro = 0;
                LET iTarjCondonadasGte         = 0;
                LET dcPorcTarjCondonadasGte = 0;
              
            END FOREACH;  
              
                          
              
          
            IF NVL(iTarjSuceptibleCobroMes,0) > 0 THEN
                --COSTO PROMEDIO COMISION POR MES
                LET dcCostoPromedioComisionMes = NVL(mMtoTotalSuceptibleCobroMes,0) / iTarjSuceptibleCobroMes;
            END IF;

            IF NVL(iTarjetasEntregadasMes,0) > 0 THEN
                --PORCENTAJE TARJETAS SUCEPTIBLES DE COBRO POR MES
                LET dcPorcTarjSuceptibleCobroMes = (NVL(iTarjSuceptibleCobroMes,0) * 100) / iTarjetasEntregadasMes;

                --PORCENTAJE TARJETAS CONDONADAS POR GERENTE POR MES
                LET dcPorcTarjCondonadasGteMes = (NVL(iTarjCondonadasGteMes,0) * 100) / iTarjetasEntregadasMes;
            END IF;

            LET cSql = '';
            LET cEtiqueta = 'TOTAL MES ' || cNomMes;
            LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasMes,0) || '|' || NVL(iTarjSuceptibleCobroMes,0) || '|' || NVL(mMtoTotalSuceptibleCobroMes,0) || '|' || NVL(iTarjetasCobradasMes,0) || '|' || NVL(mMtoTotalTarjCobradasMes,0) || '|' || NVL(dcCostoPromedioComisionMes,0) || '|' || NVL(dcPorcTarjSuceptibleCobroMes,0) || '|' || NVL(iTarjCondonadasGteMes,0) || '|' || NVL(dcPorcTarjCondonadasGteMes,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
            SYSTEM cSql;

            -- FILA DEL DETALLE DEL ACUMULADO DEL AÃâO
            SELECT SUM(tarjetasentregadas),SUM(tarjsuceptiblecobro),SUM(mtototalsuceptiblecobro),SUM(tarjetascobradas),SUM(mtototaltarjcobradas),SUM(tarjcondonadasgte)
            INTO iTarjetasEntregadasAcum,iTarjSuceptibleCobroAcum,mMtoTotalSuceptibleCobroAcum,iTarjetasCobradasAcum,mMtoTotalTarjCobradasAcum,iTarjCondonadasGteAcum
            FROM "informix".sc_acumuladostddentregadas_suc
            WHERE fechainsert >= dFecIniAcumulado AND fechainsert <= dFechaArchivo;

            IF NVL(iTarjSuceptibleCobroAcum,0) > 0 THEN
                --COSTO PROMEDIO COMISION DEL ACUMULADO DEL AÃâO
                LET dcCostoPromedioComisionAcum = NVL(mMtoTotalSuceptibleCobroAcum,0) / iTarjSuceptibleCobroAcum;
            END IF;

            IF NVL(iTarjetasEntregadasAcum,0) > 0 THEN
                --PORCENTAJE TARJETAS SUCEPTIBLES DE COBRO DEL ACUMULADO DEL AÃâO
                LET dcPorcTarjSuceptibleCobroAcum = (NVL(iTarjSuceptibleCobroAcum,0) * 100) / iTarjetasEntregadasAcum;

                --PORCENTAJE TARJETAS CONDONADAS POR GERENTE DEL ACUMULADO DEL AÃâO
                LET dcPorcTarjCondonadasGteAcum = (NVL(iTarjCondonadasGteAcum,0) * 100) / iTarjetasEntregadasAcum;
            END IF;

            LET cSql = '';
            LET cEtiqueta = 'ACUMULADO ' || TO_CHAR(iAnio);
            LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasAcum,0) || '|' || NVL(iTarjSuceptibleCobroAcum,0) || '|' || NVL(mMtoTotalSuceptibleCobroAcum,0) || '|' || NVL(iTarjetasCobradasAcum,0) || '|' || NVL(mMtoTotalTarjCobradasAcum,0) || '|' || NVL(dcCostoPromedioComisionAcum,0) || '|' || NVL(dcPorcTarjSuceptibleCobroAcum,0) || '|' || NVL(iTarjCondonadasGteAcum,0) || '|' || NVL(dcPorcTarjCondonadasGteAcum,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
            SYSTEM cSql;
        ELSE
            LET cCodret = "00002"; --Ruta sin Definir
        END IF;
    ELSE
        LET cCodret = "00001"; --Fecha Vacia
    END IF;

    RETURN cCodret;
END;
END PROCEDURE;