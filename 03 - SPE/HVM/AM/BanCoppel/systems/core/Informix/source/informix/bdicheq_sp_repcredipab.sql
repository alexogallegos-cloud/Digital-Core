CREATE PROCEDURE "informix".sp_repcredipab(pFechaIni DATE, pFechaFin DATE,  pNumCliente CHAR(20) )
RETURNING CHAR  (5);

	-- ElaborÃ³: Aymme Osuna
	-- ExtraciÃ³n de la informaciÃ³n de las cuentas de credito
        --necesaria para complementar el reporte solicitado por el IPAB.

---DECLARACION DE VARIABLES
DEFINE cNumCredito      CHAR(20);
DEFINE cNumCliente      CHAR(20);
DEFINE cTpoCuenta       CHAR(2);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  CHAR(40);
DEFINE cDivisa                  CHAR(2);
DEFINE dFechaCorte      DATE;
DEFINE dFechaContratacion DATE;
DEFINE dporcentaje_tit	DECIMAL(9,6);
DEFINE cTipoPersona     CHAR(2);
DEFINE cPais            CHAR(20);

--DECLARACION DE VARIABLES DAT PERSONALES CTE
DEFINE  sCauRev          SMALLINT;
DEFINE  cSucursal       CHAR(4);
DEFINE  cNombre1      CHAR(26);
DEFINE cNombre2       CHAR(26);
DEFINE cApellido1       CHAR(26);
DEFINE cApellido2       CHAR(26);
DEFINE cRfc                  CHAR(13);
DEFINE cNombreCalle    CHAR(30);
DEFINE cNumInterio        CHAR(10);
DEFINE cNumExterior      CHAR(10);
DEFINE cColonia              CHAR(30);
DEFINE cCodPostal         CHAR(5);
DEFINE cDelegacionMunicipio CHAR(25);
DEFINE cEstado                        CHAR(25);
DEFINE cTelefonoCasa           CHAR(13);
DEFINE cTelefonoTrabajo       CHAR(13);
DEFINE cExtensionTrabajo     CHAR(5);
DEFINE cCelular                        CHAR(13);
DEFINE cNomCiudadCte         CHAR(4);
DEFINE cNumCiudadCte         CHAR(4);
DEFINE cNumColoniacte         CHAR(4);
DEFINE cCurp                  CHAR(18);
DEFINE cCorreo                CHAR(50);
DEFINE cNumCalleCte             CHAR(6);
--DECLARACION DE VARIABLES PARA SALDO
DEFINE  mSaldoActual    MONEY(18,2);
--DEFINE mSaldo                MONEY(18,2);
DEFINE  mSaldoInsol    MONEY(18,2);
DEFINE dFechaCal        DATE;
DEFINE mSaldoProm       MONEY(18,2);
DEFINE cRegFiscal       CHAR(1);
DEFINE dPorRetencion DECIMAL(14,2);
DEFINE cTipoTasa        CHAR(1);
DEFINE dtasa            DECIMAL(9, 6);
DEFINE dSobreTasa            DECIMAL(9, 6);
DEFINE sDiasMes           smallint;
DEFINE mPorRetencion   MONEY(18,2);
DEFINE sTransacc        SMALLINT;
DEFINE mMontoTot        MONEY;
DEFINE cNaturaleza      CHAR(1);
DEFINE sMes                 SMALLINT;
DEFINE dFecCal              DATE;
DEFINE dFecCal_prom	    DATETIME YEAR TO MONTH;
DEFINE cCodFun		CHAR(3);
DEFINE iCodRef		INTEGER;
--VARIABLES GENERALES
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO   VARCHAR(80);
DEFINE P_COD_RET     VARCHAR(5);
DEFINE P_MENSAJE      VARCHAR(80);
DEFINE vTotalRegistros INTEGER;
DEFINE cPrueba	            CHAR(10);

--SET DEBUG FILE TO '/tmp/sp_RepCredIpab.out';
--TRACE ON;

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        --ROLLBACK WORK;
        RETURN P_COD_RET;
    END EXCEPTION;

--BEGIN WORK;

--INICIALIZACION DE VARIABLES
LET cPais = "";
LET cNumCredito = "";
LET cNumCliente = "";
LET cTpoCuenta = "CI";
LET cNumProducto  = "";
LET cNomProducto = "";
LET cDivisa  = "";
LET dFechaCorte = "01-01-1900";
LET dFechaContratacion = "01-01-1900";
LET dporcentaje_tit = 100.00;
LET cTipoPersona   = "";
--INICIALIZACION DE VARIABLES PARA SALDO
LET   mSaldoActual = 0.00;
--LET   mSaldo = 0.00;
LET cRegFiscal  = "N";
LET dPorRetencion = "0.00";
LET		cTipoTasa = "1";
LET		dtasa = 0;
LET mPorRetencion = 0.00;
LET mSaldoInsol = 0.00;
LET sTransacc = 0;
LET mMontoTot = 0.00;
LET cNaturaleza = "";
LET sMes = 0;
LET dFecCal = "";
LET dFecCal_prom = "";
--VARIABLES DAT PERSONALES CTE
LET sCauRev = 0;
LET  cSucursal  = "";
LET  cNombre1 = "";
LET cNombre2  = "";
LET cApellido1  = "";
LET cApellido2  = "";
LET cRfc             = "";
LET cNombreCalle  = "";
LET cNumInterio      = "";
LET cNumExterior    = "";
LET cColonia            = "";
LET cCodPostal       = "";
LET cDelegacionMunicipio   = "";
LET cEstado             = "";
LET cTelefonoCasa   = "";
LET cTelefonoTrabajo   = "";
LET cExtensionTrabajo  = "";
LET cCelular                     = "";
LET cNomCiudadCte      = "";
LET cNumCiudadCte	     = "";
LET cNumColoniacte      = "";
LET cCurp                       = "";
LET cCorreo                     = "";
LET cNumCalleCte          = "";
--VARIABLES GENERALES
LET		SQL_ERR = 0;
LET		ISAM_ERR = 0;
LET		ERROR_INFO = "";
LET		P_MENSAJE = "";
LET		vTotalRegistros = 0;
LET		P_cod_ret = "00000";
LET		cPrueba = "";

LET dFecCal = (MONTH(pFechaIni) UNITS MONTH || 20 UNITS DAY || YEAR(pFechaIni) UNITS YEAR )::DATE - 1 UNITS MONTH;
LET dFecCal_prom = (pFechaFin)::DATETIME YEAR TO MONTH;

 --OBTIENE EL PORCENTAJE DE RETENCION

IF YEAR(dFecCal) = "2007" THEN
      LET mPorRetencion = 0.50;
ELSE
      LET mPorRetencion = 0.85;
END IF;




    FOREACH
        SELECT
            nvl(mcr.num_credito, '0000'),    -- numero de credito
            nvl(mcr.numcte,' '),     --  numero de cliente
            nvl(mcr.sucursal, ' '), -- Sucursal
            (select def.nombre_prod
               from bdicred:sd_definicion def
              where def.num_producto = mcr.num_producto
                and def.empresa = mcr.empresa),
		substring (nvl(mcr.divisa, ' ') from 2 for 1), --codigo de la moneda
            nvl(mcr.fecha_apertura,'01-01-1900'), --fecha contratacion
            nvl(mcr.tasa_interes, 0), --tasa de interes
            nvl(mcr.sobretasa, 0),
	    nvl(maeshist.sdo_capital + maeshist.monto_vencido + maeshist.mto_venc_trasp + maeshist.cap_tras_no_venci, 0),
	    maeshist.fecha + 1
        INTO cNumCredito, cNumCliente, cSucursal, cNomProducto, cDivisa, dFechaContratacion, dtasa, dSobreTasa,
	     mSaldoInsol,  dFechaCal
        FROM bdicred:sd_maecred mcr, bdicred:sd_maesdoshist maeshist
        WHERE mcr.empresa = '001' AND mcr.status_cred IN ('BT','AA','BA','E1','E2','E3') AND
	      mcr.empresa = maeshist.empresa AND  mcr.num_credito = maeshist.num_credito AND
	      maeshist.fecha = dFecCal AND mcr.numcte= CASE WHEN pNumCliente = "" THEN mcr.numcte  ELSE pNumCliente END



        IF cNumCredito <> "" AND cNumCliente <> "" THEN
            	SELECT
                    TRIM(cte.rfc) AS rfc,
                    CASE WHEN cte.tpo_persona = "01" THEN "F"
			WHEN cte.tpo_persona = "02" THEN "M"
		    ELSE cte.tpo_persona END,
                    rpad(TRIM(cte.nombre1)||'  '||TRIM(cte.nombre2),100,'') AS nombre,      -- nombre
                    rpad(TRIM(cte.apell_paterno),40,'') AS apellpaterno,       --apellido 1
                    rpad(TRIM(cte.apell_materno),40,'') AS apellmaterno,     --apellido 2
                    nvl(cte.numeric1, 0)  AS causalrev,  --Causal de Revision
                    rpad(TRIM(calle.nombrecalle)||' '||TRIM(dir.numeroextcalle),75,'') AS calle,      -- nombre de calle
                    rpad(TRIM(zon.nombrezona),30,'') AS colonia,   -- colonia
                    lpad(TRIM(dir.cod_postal),5,'0') AS cod_postal,     -- codigo postal
                    rpad(TRIM(pai.nombre),50, '') AS nom_pais,
                    rpad(TRIM(zon.municipiozona),30,'') AS municipio,    -- delegacion / municipio
                    rpad(TRIM(edo.siglas), 5,'') AS estado,    -- estado
			  rpad(TRIM(dir.telefono1),13,'') AS tel_casa,   -- telefono casa
			  rpad(TRIM(dir.telefono3),13,'') AS tel_trabajo, -- telefono trabajo
			  rpad(TRIM(dir.extension),5,'') AS ext_trabajo,     -- extension trabajo
			  rpad(TRIM(dir.telefono2),13,'') AS celular,    -- celular
			  rpad(TRIM(ciudad.nombreciudad),30,'') AS nomciudad, -- ciudad
                    rpad(TRIM(ctepf.curp),'') AS curp,
   			  rpad(TRIM(ctepf.email),'') AS correo_electronico
			  INTO cRfc, cTipoPersona, cNombre1, cApellido1, cApellido2, sCauRev, cNombreCalle, cColonia,
			  cCodPostal, cPais, cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,
			  cNomCiudadCte, cCurp, cCorreo
		   FROM bdinteg:si_cliente cte
		        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
			  LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
			  LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
			  LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
			  LEFT OUTER JOIN bdinteg:si_estadosipab edo ON (edo.estado = dir.estado)
			  LEFT OUTER JOIN bdinteg:si_paises pai ON (pai.pais = edo.pais)
                    LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
                    WHERE cte.numcte = cNumCliente
                    and cte.numcte = dir.numcte
                    AND dir.tipo_dir = '1'
                    AND dir.secuencia = ( Select max(secuencia)
                                            FROM bdinteg:si_direcciones dir1
                                           WHERE cte.numcte = dir1.numcte
                                             and dir1.tipo_dir = '1');

                    IF nvl(cNombre1, "") <> "" AND nvl(cApellido1, "")  <> "" AND nvl(cApellido2, "") <> "" THEN



					SELECT nvl(SUM(CASE WHEN transacc.naturaleza = "C" THEN
						movhis.monto
						ELSE
						movhis.monto * -1
						END), 0)
					--movhis.monto, transacc.naturaleza
					INTO mMontoTot
					FROM bdicred:sd_movhis movhis,
                                             bdicred:sd_transfun transfun,
                                             bdinteg:si_transacc transacc
					WHERE movhis.empresa = '001'
					AND movhis.num_credito = cNumCredito
                                        AND movhis.fecha_mov BETWEEN dFechaCal AND pFechafin
                                        AND movhis.reversado = 'N'
                                        and movhis.codigo_fun = transfun.codigo_fun
                                        and transacc.se_emite_edocta = 'S'
                                        and transacc.sistema = '06'
                                        and movhis.codigo_ref = transfun.codigo_ref
                                        and transfun.transacc not in ("6700", "6300", "6999")
                                        and transfun.transacc = transacc.numero;

					LET  mSaldoInsol =   mSaldoInsol + mMontoTot;

                            --CALCULO DEL SALDO PROMEDIO DIARIO
                            LET sDiasMes = pFechaFin - pFechaIni;
                              SELECT NVL(SUM(s.acum_insoluto)/sDiasMes,0)
                                        INTO mSaldoProm
			    FROM bdicred:sd_salpro s
                            WHERE s.num_credito = cNumCredito  AND s.fecha = dFecCal_prom;

                             --INSERCION EN TABLAS
                            INSERT INTO  si_infpertit VALUES(UPPER(cNumCliente), UPPER(cTipoPersona), UPPER(cNombre1), UPPER(cApellido1), UPPER(cApellido2), UPPER(cNombreCalle),
                                                      UPPER(cColonia), UPPER(cDelegacionMunicipio), UPPER(cNumCiudadCte), UPPER(cCodPostal), UPPER(cPais), UPPER(cEstado), "S", mPorRetencion, sCauRev, UPPER(cRfc),UPPER(cCurp), UPPER(cTelefonoCasa), cCorreo);

                            INSERT INTO si_infpattit  VALUES(UPPER(cNumCredito), 0, UPPER(cTpoCuenta), UPPER(cRegFiscal), dPorRetencion, sCauRev, UPPER(cNomProducto), UPPER(cSucursal), mSaldoInsol, UPPER(cDivisa), "",
                                                      dFechaContratacion, 0,  UPPER(cTipoTasa),  dtasa, "",  dSobreTasa, "", "", mSaldoProm);

                            INSERT INTO si_ctaasotit  VALUES(UPPER(cNumCredito), "", UPPER(cNumCliente), 100.00);

                    ELSE
                        CONTINUE FOREACH;
                    END IF;

        ELSE
            CONTINUE FOREACH;
        END IF;

   END FOREACH;
  RETURN P_COD_RET;
END;
   END PROCEDURE;