CREATE PROCEDURE "informix".sp_consul_atm(eEmpresa    CHAR(3),
                                          eFecha      DATE,
                                          eFecFin     DATE,
                                          eFolioOper  CHAR(8),
                                          eSucursal   CHAR(4),
                                          eCodTras    CHAR(4),
                                          eTipo       CHAR(1)) --S = Sucursal C = Cajero

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
          FLOAT,               --Cantidad8
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
          CHAR(40),            --CodTrans
          DATE,		       -- Fecha Recepcion
          CHAR(5),	       -- Hora Recepcion
          CHAR(8);	       -- Usuario Recepcion

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
 DEFINE vFecRecep     DATE;
 DEFINE vHoraRecep    CHAR(5);
 DEFINE vUserRecep    CHAR(8);

 SET LOCK MODE TO WAIT 3;
 SET ISOLATION TO DIRTY READ; 

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
 LET vFecRecep     = ''; 
 LET vHoraRecep    = '';
 LET vUserRecep    = '';
 LET eFecha   = eFecha;
 LET eFecFin  = eFecFin;
 LET eFolioOper= eFolioOper;
 LET eSucursal = eSucursal;
 LET eCodTras = eCodTras;
 LET eTipo    =eTipo;

 --SET DEBUG FILE TO "/tmp/sp_consul_atm.out";
 --TRACE ON;

 IF (eCodTras IS NOT NULL OR eCodTras <> '') AND (eSucursal IS NOT NULL OR eSucursal <> '') THEN
    FOREACH
        SELECT sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
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
		  AND fecha_operacion between eFecha AND eFecFin 
          AND sucursal = eSucursal
          AND reversado IN ('0','1','S','N')
        ORDER BY fecha_operacion desc,sucursal,cod_trans desc

        SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
        SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;
        SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;
        SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;
        SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;
    
        SELECT fecha_recepcion,hora_recepcion,usuario_recepcion
        INTO   vFecRecep,vHoraRecep,vUserRecep
        FROM   bdisuc:"informix".ss_mae_entradasalida
        WHERE  folio_oper = vFolOper;

        IF vFecRecep IS NULL THEN
            LET vFecRecep = '';
            LET vHoraRecep = '';
            LET vUserRecep = '';
        END IF;

        RETURN vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
               vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
               vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
               vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
               vFolOper      , vProcedencia  , vNomProv      ,vDesTran       , vFecRecep     , vHoraRecep    , vUserRecep WITH RESUME;
     END FOREACH;
 END IF;

END PROCEDURE;