CREATE PROCEDURE  "informix".sp_sdodiacap(pEmpresa CHAR(3))
RETURNING
    CHAR(20), --1
    CHAR(4), --2
    CHAR(3), --3
    CHAR(4), --4
    CHAR(20), --5
    MONEY, --6
    MONEY, --7
    MONEY, --8
    CHAR(40), --9
    CHAR(104), --10
    CHAR(4), --11
    CHAR(40), --12
    CHAR(2), --13
    CHAR(3), --14
    CHAR(30), --15
    MONEY, --16
    CHAR(40), --17
    CHAR(3), --18
    CHAR(30), --19
    CHAR(40) --20

--DEFINICION DE VARIABLES
DEFINE v_cnumcuenta    CHAR(20); --1
DEFINE v_cSucursal          CHAR(4); --2
DEFINE v_cPlaza                 CHAR(3); --3
DEFINE v_cProducto          CHAR(4); --4
DEFINE v_cNumCte            CHAR(20); --5
DEFINE  v_mSdoRetenido  MONEY; --6
DEFINE  v_mSdoCongelado MONEY; --7
DEFINE v_mSdoActual             MONEY; --8
DEFINE v_cSucNombre         CHAR(40); --9
DEFINE v_cCteNombre         CHAR(104); --10
DEFINE v_cProd_producto     CHAR(4); --11
DEFINE v_cNomProducto       CHAR(40); --12
DEFINE v_cDivisa                    CHAR(2); --13
DEFINE v_cEmpresa               CHAR(3); --14
DEFINE v_cRazonSocial       CHAR(30); --15
DEFINE v_mMontoTotSBC     MONEY; --16
DEFINE v_cNombrePlaza       CHAR(40); --17
DEFINE v_cRegionPlaza           CHAR(3); --18
DEFINE v_cDescDivisa            CHAR(30); --19
DEFINE v_cRegionNombre      CHAR(40); --20

--INICIALIZACION DE VARIABLES

LET v_cnumcuenta = "";
LET v_cSucursal  = "";
LET  v_cPlaza = "";
LET  v_cProducto = "";
LET  v_cNumCte  = "";
LET v_mSdoRetenido = 0;
LET  v_mSdoCongelado = 0;
LET  v_mSdoActual = 0;
LET  v_cSucNombre = "";
LET v_cCteNombre  = "";
LET v_cProd_producto = "";
LET v_cNomProducto = "";
LET v_cDivisa = "";
LET v_cEmpresa  = "";
LET v_cRazonSocial  = "";
LET v_mMontoTotSBC = 0;
LET v_cNombrePlaza = "";
LET v_cRegionPlaza  = "";
LET v_cDescDivisa   = "";
LET v_cRegionNombre   = "";




 --**************************************************
--Creado por Aymme Osuna Peraza
--FECHA:29 Febrero 2008

--**************************************************
--SET DEBUG FILE TO "/tmp/sp_sdodiacap.out";
 --TRACE ON;

BEGIN
IF pEmpresa = "001" THEN
        FOREACH

            SELECT    sc_maechq.cuenta,  sc_maechq.sucursal,  sc_maechq.plaza,   sc_maechq.producto,   sc_maechq.num_cte,
                               sc_maechq.sdo_retenido,   sc_maechq.sdo_cong,  sc_maechq.sdo_actual,    si_sucursales.nombre,
                               si_cliente.nombre, sc_producto.producto, sc_producto.nombre,  sc_producto.divisa, si_empresas.empresa,
                                si_empresas.razon_social,
                                 (select  sum(sc_docret.monto_ori) from bdicheq:sc_docret sc_docret
                                  where sc_maechq.cuenta = sc_docret.cuenta   and sc_docret.transacc = "0250" AND sc_docret.cancelado = "T")  AS monto_ori,
                                si_plazas.nombre,  si_plazas.regional, si_divisas.descripcion, si_regional.nombre

               INTO   v_cnumcuenta, v_cSucursal,  v_cPlaza, v_cProducto, v_cNumCte,
                           v_mSdoRetenido,  v_mSdoCongelado, v_mSdoActual, v_cSucNombre,
                           v_cCteNombre, v_cProd_producto,  v_cNomProducto,  v_cDivisa , v_cEmpresa ,
                           v_cRazonSocial ,  v_mMontoTotSBC,
                           v_cNombrePlaza , v_cRegionPlaza,  v_cDescDivisa,  v_cRegionNombre

              FROM    sc_maechq sc_maechq

               INNER  JOIN si_cliente si_cliente ON          sc_maechq.num_cte = si_cliente.numcte
               INNER  JOIN sc_producto sc_producto ON          sc_maechq.empresa = sc_producto.empresa AND      sc_maechq.producto = sc_producto.producto
               INNER  JOIN si_empresas si_empresas ON          sc_maechq.empresa = si_empresas.empresa
               INNER  JOIN si_sucursales si_sucursales ON          sc_maechq.empresa = si_sucursales.empresa AND      sc_maechq.sucursal = si_sucursales.sucursal
               INNER  JOIN si_divisas si_divisas ON          sc_producto.divisa = si_divisas.divisa AND      sc_producto.empresa = si_divisas.empresa
               INNER  JOIN si_plazas si_plazas ON          si_sucursales.empresa = si_plazas.empresa AND      si_sucursales.plaza = si_plazas.plaza
               INNER  JOIN si_regional si_regional ON          si_plazas.empresa = si_regional.empresa AND      si_plazas.regional = si_regional.regional
               ORDER BY
                    sc_producto.divisa ASC,
                    sc_maechq.sucursal ASC,
                    sc_producto.producto ASC,
                    sc_maechq.cuenta ASC

                 RETURN  TRIM( v_cnumcuenta),TRIM( v_cSucursal), TRIM( v_cPlaza), TRIM(v_cProducto), TRIM(v_cNumCte),
                                   v_mSdoRetenido,  v_mSdoCongelado, v_mSdoActual, TRIM(v_cSucNombre),
                                   TRIM(v_cCteNombre), TRIM(v_cProd_producto),  TRIM(v_cNomProducto),  TRIM(v_cDivisa) ,TRIM( v_cEmpresa) ,
                                   TRIM(v_cRazonSocial) ,  v_mMontoTotSBC,
                                   TRIM(v_cNombrePlaza) ,TRIM( v_cRegionPlaza), TRIM( v_cDescDivisa),  TRIM(v_cRegionNombre) WITH RESUME;
                END FOREACH;
ELSE
        FOREACH

            SELECT    sc_maechq.cuenta,  sc_maechq.sucursal,  sc_maechq.plaza,   sc_maechq.producto,   sc_maechq.num_cte,
                               sc_maechq.sdo_retenido,   sc_maechq.sdo_cong,  sc_maechq.sdo_actual,    si_sucursales.nombre,
                               si_cliente.nombre, sc_producto.producto, sc_producto.nombre,  sc_producto.divisa, si_empresas.empresa,
                                si_empresas.razon_social,
                                 (select  sum(sc_docret.monto_ori) from bdicheq:sc_docret sc_docret
                                  where sc_maechq.cuenta = sc_docret.cuenta   and sc_docret.transacc = "0250" AND sc_docret.cancelado = "T")  AS monto_ori,
                                si_plazas.nombre,  si_plazas.regional, si_divisas.descripcion, si_regional.nombre

               INTO   v_cnumcuenta, v_cSucursal,  v_cPlaza, v_cProducto, v_cNumCte,
                           v_mSdoRetenido,  v_mSdoCongelado, v_mSdoActual, v_cSucNombre,
                           v_cCteNombre, v_cProd_producto,  v_cNomProducto,  v_cDivisa , v_cEmpresa ,
                           v_cRazonSocial ,  v_mMontoTotSBC,
                           v_cNombrePlaza , v_cRegionPlaza,  v_cDescDivisa,  v_cRegionNombre

              FROM    sc_maechq sc_maechq

               INNER  JOIN si_cliente si_cliente ON          sc_maechq.num_cte = si_cliente.numcte
               INNER  JOIN sc_producto sc_producto ON          sc_maechq.empresa = sc_producto.empresa AND      sc_maechq.producto = sc_producto.producto
               INNER  JOIN si_empresas si_empresas ON          sc_maechq.empresa = si_empresas.empresa
               INNER  JOIN si_sucursales si_sucursales ON          sc_maechq.empresa = si_sucursales.empresa AND      sc_maechq.sucursal = si_sucursales.sucursal
               INNER  JOIN si_divisas si_divisas ON          sc_producto.divisa = si_divisas.divisa AND      sc_producto.empresa = si_divisas.empresa
               INNER  JOIN si_plazas si_plazas ON          si_sucursales.empresa = si_plazas.empresa AND      si_sucursales.plaza = si_plazas.plaza
               INNER  JOIN si_regional si_regional ON          si_plazas.empresa = si_regional.empresa AND      si_plazas.regional = si_regional.regional
               ORDER BY
                       sc_producto.divisa ASC,
                       sc_maechq.sucursal ASC,
                       sc_producto.producto ASC


                 RETURN  TRIM( v_cnumcuenta),TRIM( v_cSucursal), TRIM( v_cPlaza), TRIM(v_cProducto), TRIM(v_cNumCte),
                                   v_mSdoRetenido,  v_mSdoCongelado, v_mSdoActual, TRIM(v_cSucNombre),
                                   TRIM(v_cCteNombre), TRIM(v_cProd_producto),  TRIM(v_cNomProducto),  TRIM(v_cDivisa) ,TRIM( v_cEmpresa) ,
                                   TRIM(v_cRazonSocial) ,  v_mMontoTotSBC,
                                   TRIM(v_cNombrePlaza) ,TRIM( v_cRegionPlaza), TRIM( v_cDescDivisa),  TRIM(v_cRegionNombre) WITH RESUME;
            END FOREACH;
END IF;

  END
END PROCEDURE;