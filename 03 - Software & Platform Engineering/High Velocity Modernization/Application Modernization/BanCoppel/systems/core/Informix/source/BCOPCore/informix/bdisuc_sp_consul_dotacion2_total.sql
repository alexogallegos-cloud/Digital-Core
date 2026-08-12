CREATE PROCEDURE "informix".sp_consul_dotacion2_total(eEmpresa    CHAR(3), 
                                               eTipo       CHAR(1), 
                                               eProveedor  CHAR(4),
                                               eSucursal   CHAR(4),
                                               eFecInicio  DATE,
                                               eFecFin     DATE,
                                               eStatus     CHAR(2))
RETURNING CHAR(5),
          INTEGER;

DEFINE vCodRet   CHAR(5);
DEFINE vWHERE    CHAR(300);
DEFINE vSucursal CHAR(4);
DEFINE vNomSuc   CHAR(50);
DEFINE vFecOpera DATE;
DEFINE vStatus   CHAR(50);
DEFINE vFolio    CHAR(16);
DEFINE vMonto    DECIMAL(14,2);
DEFINE vUsuario  CHAR(50);
DEFINE vUser     CHAR(16);
DEFINE vPlaza    CHAR(50);
DEFINE vPSuc     char(4);
DEFINE vTotRegs  INTEGER;

LET vCodRet  = "000";
LET vWHERE   = '';
LET vPSuc    = "";
LET eTipo = eTipo;
LET eFecInicio = eFecInicio;
LET eFecFin = eFecFin;
LET vPlaza = "";
LET vTotRegs = 0;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consul_dotacion2_total.out';
        --TRACE ON;

    IF eProveedor <> '' and eSucursal = '' THEN   --** Por proveedor

                IF eFecInicio = '' OR eFecInicio IS NULL  THEN
                        LET eFecInicio = MDY(1,1,2007);
                END IF

                  SELECT COUNT(*)
                    INTO vTotRegs
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                     AND a.sucursal IN (SELECT sucursal 
                                                                              FROM bdinteg:"informix".si_sucursales  
                                                                             WHERE sucursal != '0' 
                                                                               AND empresa = eEmpresa 
                                                                                   AND tpo_sucursal = eTipo)
                                        AND a.reversado IN ('0')
                                    AND a.folio_oper = b.folio_oper                 
                                    AND b.cod_proveedor = eProveedor               
                                    AND b.status = eStatus;                   

                  RETURN vcodret, vTotRegs;

    ELIF eProveedor <> '' and eSucursal <> ''  THEN   --** Por Sucursal

                IF eFecInicio = '' OR eFecInicio IS NULL  THEN
                        LET eFecInicio = MDY(1,1,2007);
                END IF

                  SELECT COUNT(*)
                    INTO vTotRegs
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                                     AND a.sucursal = eSucursal 
                                         AND a.reversado IN ('0')
                     AND a.folio_oper = b.folio_oper                 
                     AND b.status = eStatus;                 
                  RETURN vcodret, vTotRegs;

    ELSE  --** Todos

                IF eFecInicio = '' OR eFecInicio IS NULL  THEN
                        LET eFecInicio = MDY(1,1,2007);
                END IF

                  SELECT COUNT(*)
                    INTO vTotRegs
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                                         AND a.sucursal IN (SELECT sucursal 
                                                                  FROM bdinteg:"informix".si_sucursales  
                                                                  WHERE sucursal != '0' 
                                                                    AND empresa = eEmpresa 
                                                                        AND tpo_sucursal = eTipo)
                                         AND a.reversado IN ('0')
                     AND a.folio_oper = b.folio_oper                 
                     AND b.status = eStatus;                 

                  RETURN vcodret, vTotRegs;
    END IF;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/02/2015',
'DESCRIPCION: Clon del spl bdisuc:sp_consul_dotacion para el conteo de registros que devolvera la consulta';

CREATE PROCEDURE "informix".sp_consul_operaciones2(eEmpresa    CHAR(3),
                                                  eFecha      DATE,
                                                  eFecFin     DATE,
                                                  eFolioOper  CHAR(8),
                                                  eSucursal   CHAR(4),
                                                  eCodTras    CHAR(4),
                                                  eTpConsul   CHAR(1),
                                                  eRegional   CHAR(5),
                                                  eTipo       CHAR(1),
												  eRegistros  INTEGER,
												  eRecupera   INTEGER) --S = Sucursal C = Cajero
RETURNING CHAR(5),             --CodRet
          CHAR(50),            --Sucursal
          DATE,                --Fec.Operacion
          CHAR(4),             --CodTran
          CHAR(1),             --Reversado
          CHAR(40),            --Usuario
          CHAR(40),            --Divisa
          MONEY(14,2),         --Monto
          FLOAT,               --Cantidad1
          FLOAT,               --Cantidad2
          FLOAT,               --Cantidad3
          FLOAT,               --Cantidad4
          FLOAT,               --Cantidad5
          FLOAT,               --Cantidad6
          FLOAT,               --Cantidad7
          fLOAT,               --Cantidad8
          FLOAT,               --Cantidad9
          FLOAT,               --Cantidad10
          FLOAT,               --Cantidad11
          FLOAT,               --Cantidad12
          FLOAT,               --Cantidad13
          FLOAT,               --Cantidad14
          FLOAT,               --Cantidad15
          CHAR(16),            --Folio Sucursal
          CHAR(8),             --Folio Oper
          CHAR(4),             --Procedencia
          CHAR(40),            --Proveedor
          CHAR(40);            --CodTrans

 DEFINE vCodRet       CHAR(5);
 DEFINE vSucursal     CHAR(4);
 DEFINE vFecOperacion DATE;
 DEFINE vCodTrans     CHAR(4);
 DEFINE vReversado    CHAR(1);
 DEFINE vUsuario      CHAR(8);
 DEFINE vDivisa       CHAR(2);
 DEFINE vMonto        MONEY(14,2);
 DEFINE vCant1        FLOAT;
 DEFINE vCant2        FLOAT;
 DEFINE vCant3        FLOAT;
 DEFINE vCant4        FLOAT;
 DEFINE vCant5        FLOAT;
 DEFINE vCant6        FLOAT;
 DEFINE vCant7        FLOAT;
 DEFINE vCant8        FLOAT;
 DEFINE vCant9        FLOAT;
 DEFINE vCant10       FLOAT;
 DEFINE vCant11       FLOAT;
 DEFINE vCant12       FLOAT;
 DEFINE vCant13       FLOAT;
 DEFINE vCant14       FLOAT;
 DEFINE vCant15       FLOAT;
 DEFINE vFolSuc       CHAR(16);
 DEFINE vFolOper      CHAR(8);
 DEFINE vProcedencia  CHAR(4);
 DEFINE vNomSuc       CHAR(40);
 DEFINE vNomProv      CHAR(40);
 DEFINE vNomUsuario   CHAR(40);
 DEFINE vDesDivisa    CHAR(40);
 DEFINE vPlazaGen     CHAR(3);
 DEFINE vDesTran      CHAR(40);
 DEFINE vPlaza        CHAR(3);
 DEFINE vFolioSrv     CHAR(16);
 DEFINE vCajGen       CHAR(1);


 LET vCodRet       = "000";
 LET vSucursal     = '';
 LET vFecOperacion = '';
 LET vCodTrans     = '';
 LET vReversado    = '';
 LET vUsuario      = '';
 LET vDivisa       = '';
 LET vMonto        = 0;
 LET vCant1        = 0;
 LET vCant2        = 0;
 LET vCant3        = 0;
 LET vCant4        = 0;
 LET vCant5        = 0;
 LET vCant6        = 0;
 LET vCant7        = 0;
 LET vCant8        = 0;
 LET vCant9        = 0;
 LET vCant10       = 0;
 LET vCant11       = 0;
 LET vCant12       = 0;
 LET vCant13       = 0;
 LET vCant14       = 0;
 LET vCant15       = 0;
 LET vFolSuc       = '';
 LET vFolOper      = '';
 LET vProcedencia  = '';
 LET vNomSuc       = '';
 LET vNomProv      = '';
 LET vNomUsuario   = '';
 LET vDesDivisa    = '';
 LET vPlazaGen     = '';
 LET vDesTran      = '';
 LET vPlaza        = '';
 LET vFolioSrv     = '';
 LET vCajGen       = 'N';


 SET LOCK MODE TO WAIT 4;
 SET ISOLATION TO DIRTY READ;

 IF eRegional != '0000' THEN
    SELECT plaza INTO vPlaza FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = eRegional;    
 END IF;

 IF eTipo = 'C' THEN
    LET vCajGen =  'C';
 END IF;

 IF eTpConsul = '1' THEN    --Todos
    IF eRegional != '0000' THEN    
        FOREACH
            SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                   divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                   cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                   cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                   cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
            INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                  vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia
            FROM  bdisuc:"informix".ss_operaciones
            WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND (sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                   WHERE sucursal != '0'
                                     AND empresa = eEmpresa
                                     AND plaza_cajagen = vPlaza 
                                     AND tpo_sucursal = eTipo)
                  OR sucursal IN (SELECT cod_proveedor 
                                             FROM bdisuc:ss_proveedores 
                                             WHERE cod_proveedor = eRegional))
                 AND reversado IN ('0','1')
             ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

             SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

             SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

             SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

             SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

             SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;

             SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
             INTO vFolioSrv 
             FROM bdisuc:"informix".ss_mae_entradasalida 
             WHERE folio_oper = vFolOper;

             IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                LET vFolSuc = vFolioSrv;
             END IF;

             Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;
         END FOREACH;
    ELSE
        FOREACH
               SELECT SKIP eRegistros FIRST eRecupera  {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                      divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                      cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                      cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                      cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
               INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                     vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                     vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                     vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                     vFolOper      , vProcedencia
               FROM  bdisuc:"informix".ss_operaciones
               WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                   WHERE sucursal != '0'
                                     AND empresa = eEmpresa
                                     AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                 AND reversado IN ('0','1')
            ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;

               SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
               INTO vFolioSrv 
               FROM bdisuc:"informix".ss_mae_entradasalida 
               WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;
         END FOREACH;
    END IF;         

 ELIF eTpConsul = '2' THEN    --Reversado
    IF eRegional != '0000' THEN
        FOREACH
               SELECT SKIP eRegistros FIRST eRecupera  {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                      divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                      cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                      cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                      cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
               INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                     vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                     vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                     vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                     vFolOper      , vProcedencia
               FROM  bdisuc:"informix".ss_operaciones
               WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                   WHERE sucursal != '0'
                                     AND empresa = eEmpresa
                                     AND plaza_cajagen = vPlaza 
                                     AND tpo_sucursal = eTipo)
                 AND reversado IN ('1')
            ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

               SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
               INTO vFolioSrv 
               FROM bdisuc:"informix".ss_mae_entradasalida 
               WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans,  vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;
    ELSE
         FOREACH
               SELECT SKIP eRegistros FIRST eRecupera  {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                      divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                      cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                      cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                      cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
               INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                     vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                     vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                     vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                     vFolOper      , vProcedencia
               FROM  bdisuc:"informix".ss_operaciones
               WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                    WHERE empresa = eEmpresa
                                     AND sucursal != '0' 
                                     AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                 AND reversado IN ('1')
            ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

             SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
             INTO vFolioSrv 
             FROM bdisuc:"informix".ss_mae_entradasalida 
             WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans,  vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;
    END IF;        

 ELIF eTpConsul = '3' THEN    --Folio Operacion
    FOREACH
           SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx02ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                  divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                  cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                  cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                  cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
           INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                 vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                 vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                 vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                 vFolOper      , vProcedencia
           FROM  bdisuc:"informix".ss_operaciones
           WHERE folio_oper = eFolioOper
           ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

             --** Descripcion Sucursal
           SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

             --** Nombre proveeedor
           SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

             --** Usuario
           SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

             --** Divisa
           SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

             --** Transaccion
           SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

	     SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
		 INTO vFolioSrv 
		 FROM bdisuc:"informix".ss_mae_entradasalida 
		 WHERE folio_oper = vFolOper;

           IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
              LET vFolSuc = vFolioSrv;
           END IF;

           Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion ,  vCodTrans, vReversado    , vNomUsuario   ,
                  vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

     END FOREACH;
 
 ELIF eTpConsul = '4' THEN    --Fecha
    IF eFecha Is Null Or eFecha = '' THEN
       LET vCodRet  = "001";
           Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                  vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;
    ELSE
       IF eRegional != '0000' THEN
           FOREACH
                  SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                         divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                         cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                         cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                         cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
                  INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                        vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                        vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                        vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                        vFolOper      , vProcedencia
                  FROM  bdisuc:"informix".ss_operaciones
                  WHERE cod_trans IN ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                    AND fecha_operacion between eFecha  and eFecFin
                    AND (sucursal IN( SELECT sucursal 
                                       FROM bdinteg:"informix".si_sucursales 
                                      WHERE sucursal != '0'
                                        AND empresa = eEmpresa
                                        AND plaza_cajagen = vPlaza 
                                        AND tpo_sucursal = eTipo)
                          OR sucursal IN (SELECT cod_proveedor 
                                              FROM bdisuc:"informix".ss_proveedores 
                                             WHERE cod_proveedor = eRegional))
                    AND reversado IN ('0','1')
              ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

           SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
             INTO vFolioSrv 
             FROM bdisuc:"informix".ss_mae_entradasalida 
            WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;
       ELSE
         FOREACH
                  SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                         divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                         cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                         cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                         cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
                  INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                        vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                        vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                        vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                        vFolOper      , vProcedencia
                  FROM  bdisuc:"informix".ss_operaciones
                  WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                    AND fecha_operacion between eFecha  and eFecFin
                    AND sucursal in( SELECT sucursal 
                                       FROM bdinteg:"informix".si_sucursales 
                                      WHERE sucursal != '0' 
                                        AND empresa = eEmpresa
                                        AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                    AND reversado IN ('0','1')
              ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

               SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
               INTO vFolioSrv 
               FROM bdisuc:"informix".ss_mae_entradasalida 
               WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;   
       END IF;
    END IF;

 ELIF eTpConsul = '5' THEN    --Sucursal
       FOREACH
              SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                     divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                     cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                     cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                     cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
              INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                    vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                    vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                    vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                    vFolOper      , vProcedencia
              FROM  bdisuc:"informix".ss_operaciones
              WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
			    AND fecha_operacion between eFecha  and eFecFin
                AND sucursal = eSucursal
                AND reversado IN ('0','1')
           ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

             --** Descripcion Sucursal
           SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

             --** Nombre proveeedor
           SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

             --** Usuario
           SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

             --** Divisa
           SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

             --** Transaccion
           SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;
	
            SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
            INTO vFolioSrv 
            FROM bdisuc:"informix".ss_mae_entradasalida 
            WHERE folio_oper = vFolOper;

           IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
              LET vFolSuc = vFolioSrv;
           END IF;

           Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                  vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

     END FOREACH;

 ELIF eTpConsul = '6' THEN    --Transaccion
    IF eRegional != '0000' THEN
       FOREACH
              SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                     divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                     cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                     cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                     cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
              INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                    vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                    vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                    vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                    vFolOper      , vProcedencia
              FROM  bdisuc:"informix".ss_operaciones
              WHERE cod_trans = eCodTras
			    AND fecha_operacion between eFecha  and eFecFin
                AND (sucursal in( SELECT sucursal 
						           FROM bdinteg:"informix".si_sucursales 
						          WHERE sucursal != '0' 
                                    AND empresa = eEmpresa
						            AND plaza_cajagen = vPlaza 
						            AND tpo_sucursal = eTipo)
			  OR sucursal IN (SELECT cod_proveedor 
										  FROM bdisuc:ss_proveedores 
								         WHERE cod_proveedor = eRegional))
                AND reversado IN ('0','1')
                ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

                SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
                INTO vFolioSrv 
                FROM bdisuc:"informix".ss_mae_entradasalida 
                WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

        END FOREACH;
    ELSE
       FOREACH
              SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                     divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                     cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                     cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                     cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
              INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                    vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                    vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                    vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                    vFolOper      , vProcedencia
              FROM  bdisuc:"informix".ss_operaciones
              WHERE cod_trans = eCodTras
			    AND fecha_operacion between eFecha  and eFecFin
                AND sucursal in( SELECT sucursal 
						           FROM bdinteg:"informix".si_sucursales 
						          WHERE sucursal != '0'
                                    AND empresa = eEmpresa
						            AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                AND reversado IN ('0','1')
                ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

                SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
                INTO vFolioSrv 
                FROM bdisuc:"informix".ss_mae_entradasalida 
                WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

        END FOREACH;
    END IF;

 END IF;

END PROCEDURE;