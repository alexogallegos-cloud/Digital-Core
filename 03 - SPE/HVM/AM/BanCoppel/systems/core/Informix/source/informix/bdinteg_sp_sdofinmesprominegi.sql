CREATE PROCEDURE "informix".sp_sdofinmesprominegi(pEmpresa CHAR(3), pCmayor CHAR(4), pCsub CHAR(2),
                                                      pCsubsub CHAR(2), pCssubsub CHAR(2), pCsssubsub CHAR(2),
                                                      pNivelObt SMALLINT, pSigno CHAR(1), pMoneda CHAR(2), pFecha DATE,
                                                      pLocalidadInegi CHAR(12))
        RETURNING CHAR(5),  --Codigo de retorno
        MONEY(18,2),        --Saldo a fin de mes
        MONEY(18,2);        --Saldo promedio del mes

		--VARIABLES DE ERROR
		DEFINE iCodRet				SMALLINT;
		DEFINE cCodRet          	CHAR(5);

		--VARIABLES DE SALDOS
		DEFINE v_mSaldo           	MONEY(18,2);
		DEFINE v_mTotalSdo        	MONEY(18,2);
		DEFINE v_mSdoProm         	MONEY(18,2);
		DEFINE v_mTotalSdoProm    	MONEY(18,2);
		DEFINE v_dPrecioMoneda    	DECIMAL(9,6);

		--VARIABLES DE FECHA
		DEFINE v_cvano           	CHAR(4);
		DEFINE v_cmes				CHAR(2);
		DEFINE v_cmesinicio 		CHAR(2);
		DEFINE v_iclavesucursal 	INTEGER;

		--------------------------------------------------------------------------
		--AUTOR: Vladimir Felix Galvez
		--FECHA: 14-10-2008
		--MODIFICACION:18-11-2008
		--ACTIVIDAD: Obtiene el saldo a fin de mes y el promedio de la cuenta
		--contable enviada, por moneda valorizada en moneda nacional apoyado del sp_saldo_fin_mes_promedio
		--SET DEBUG FILE TO "/tmp/repaut/sp_sdofinmesprominegi.out";
		--SET DEBUG FILE TO '/informix/PRISCILLA/sp_sdofinmesprominegi.out';
		--TRACE ON;
		--------------------------------------------------------------------------
	BEGIN
		--Manejo del error
		ON EXCEPTION SET iCodRet
			IF iCodRet <> 0 THEN
				LET cCodRet = iCodRet;
				RETURN cCodRet, v_mTotalSdo, v_mTotalSdoProm;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

        --Inicializacion de Variables
        LET iCodRet           = 0;
        LET cCodRet           = '000';
		LET v_mSaldo          = 0;
		LET v_mTotalSdo       = 0;
		LET v_mSdoProm        = 0;
		LET v_mTotalSdoProm   = 0;
        LET v_dPrecioMoneda   = 0;

        LET v_cvano = LPAD(YEAR(pFecha),4,"0");
		LET v_cmes = LPAD(MONTH(pFecha),2,"0");

		IF v_cmes == "03" THEN
			LET v_cmesinicio = '01';
        ELIF v_cmes == "06" THEN
			LET v_cmesinicio='04';
        ELIF v_cmes == "10" THEN
			LET v_cmesinicio='07';
        ELIF v_cmes == "12" THEN
			LET v_cmesinicio='10';
        END IF

		--Se obtiene el precio de la moneda
		IF pMoneda <> '01' THEN
			SELECT NVL(preciocontable,0) INTO v_dPrecioMoneda
			FROM bdirepaut:sp_preciocontable WHERE moneda = pMoneda AND fecha = pFecha;

			IF v_dPrecioMoneda IS NULL THEN
				RETURN '001', 0, 0; --Error, no existe precio de la moneda consultada
			END IF
		END IF

	    IF pNivelObt = 1 THEN
			IF pMoneda = '01' THEN
				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
                AND ccsub <> '00'
                AND ccsubsub <> '00'
                AND ccssubsub <> '00'
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,
						 bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + v_mSaldo;
				LET v_mTotalSdoProm = v_mTotalSdoProm + v_mSdoProm;
			ELSE
				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
                AND ccsub <> '00'
                AND ccsubsub <> '00'
                AND ccssubsub <> '00'
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + ( v_mSaldo * v_dPrecioMoneda );
				LET v_mTotalSdoProm = v_mTotalSdoProm + ( v_mSdoProm * v_dPrecioMoneda );
			END IF

	    ELIF pNivelObt = 2 THEN

			IF pMoneda = '01' THEN

				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
                AND ccsubsub <> '00'
                AND ccssubsub <> '00'
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;
				LET v_mTotalSdo = v_mTotalSdo + v_mSaldo;
				LET v_mTotalSdoProm = v_mTotalSdoProm + v_mSdoProm;

			ELSE
				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
                AND ccsubsub <> '00'
                AND ccssubsub <> '00'
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + ( v_mSaldo * v_dPrecioMoneda );
				LET v_mTotalSdoProm = v_mTotalSdoProm + ( v_mSdoProm * v_dPrecioMoneda );
			END IF

	    ELIF pNivelObt = 3 THEN

			IF pMoneda = '01' THEN

				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
				AND ccsubsub = pCsubsub
                AND ccssubsub <> '00'
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
				AND moneda = pMoneda
                AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + v_mSaldo;
				LET v_mTotalSdoProm = v_mTotalSdoProm + v_mSdoProm;
			ELSE
				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
				AND ccsubsub = pCsubsub
                AND ccssubsub <> '00'
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + ( v_mSaldo * v_dPrecioMoneda );
				LET v_mTotalSdoProm = v_mTotalSdoProm + ( v_mSdoProm * v_dPrecioMoneda );
			END IF

	    ELIF pNivelObt = 4 THEN

			IF pMoneda = '01' THEN

				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
				AND ccsubsub = pCsubsub
				AND ccssubsub = pCssubsub
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + v_mSaldo;
				LET v_mTotalSdoProm = v_mTotalSdoProm + v_mSdoProm;
			ELSE
				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
				AND ccsubsub = pCsubsub
				AND ccssubsub = pCssubsub
                AND ccsssubsub <> '00'
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + ( v_mSaldo * v_dPrecioMoneda );
				LET v_mTotalSdoProm = v_mTotalSdoProm + ( v_mSdoProm * v_dPrecioMoneda );
			END IF

	    ELIF pNivelObt = 5 THEN

			IF pMoneda = '01' THEN

				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
				AND ccsubsub = pCsubsub
				AND ccssubsub = pCssubsub
				AND ccsssubsub = pCsssubsub
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + v_mSaldo;
				LET v_mTotalSdoProm = v_mTotalSdoProm + v_mSdoProm;
			ELSE
				SELECT NVL(SUM(saldo_fin_de_mes),0), ROUND(NVL(SUM(saldo_acumulado/dias_acumulado),0),2)
				INTO v_mSaldo, v_mSdoProm
				FROM bdicont:co_sdomes
				WHERE empresa = pEmpresa
				AND ccmayor = pCmayor
				AND ccsub = pCsub
				AND ccsubsub = pCsubsub
				AND ccssubsub = pCssubsub
				AND ccsssubsub = pCsssubsub
                AND sector <> '00'
                AND ciudad IS NOT NULL
				AND sucursal IN (
					SELECT ptf.id_ptf
					FROM bdinteg:si_ptf ptf,
						 bdinteg:si_sucursales suc,bdinteg:si_ciudades ciu
					WHERE ptf.cve_pais = ciu.pais
					AND ptf.cve_estado = ciu.estado
					AND ptf.cve_ciudad = ciu.ciudad
					AND ptf.id_ptf = suc.sucursal
					AND ptf.tipo = suc.tipo
					AND ptf.tipo <> 'C'
                    AND suc.tpo_sucursal = 'S'
					AND ciu.localidad_inegi = pLocalidadInegi)
					/*SELECT a.sucursal
					FROM bdinteg:si_sucursales a,bdinteg:si_ciudades b
					WHERE a.pais = b.pais
					AND a.estado = b.estado
					AND a.ciudad = b.ciudad
                    AND a.tpo_sucursal = 'S'
					AND b.localidad_inegi = pLocalidadInegi
					)*/
                AND moneda = pMoneda
				AND YEAR(ano_mes) = YEAR(pFecha)
				AND MONTH(ano_mes) BETWEEN v_cmesinicio AND v_cmes;

				LET v_mTotalSdo = v_mTotalSdo + ( v_mSaldo * v_dPrecioMoneda );
				LET v_mTotalSdoProm = v_mTotalSdoProm + ( v_mSdoProm * v_dPrecioMoneda );
			END IF
	    END IF;

		IF pSigno = '-' THEN
			LET v_mTotalSdo = v_mTotalSdo * -1;
		END IF;

		RETURN cCodRet, v_mTotalSdo, v_mTotalSdoProm;

	END;
END PROCEDURE;