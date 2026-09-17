CREATE PROCEDURE "informix".sp_consultarautoguardadopaquete(pEmpresa CHAR(3),pTipoPaquete CHAR(1))

	RETURNING CHAR(6) AS Cod_Retorno,
			  INTEGER AS TotalRegAutoguardado;
			  
--DEFINICION DE VARIABLES
	DEFINE cCod_Ret CHAR(6);
	DEFINE iNumReg	INTEGER;
	DEFINE iSqlErr	INTEGER;
	
--INICIALIZACION DE VARIABLES
	LET cCod_Ret = '';
	LET iNumReg	 = 0;
	
	
BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN NVL(cCod_Ret,''),iNumReg;
        END IF;
    END  EXCEPTION;

	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarautoguardadopaquete.out";
	--TRACE ON;
	-----------------------------------------------------------------------


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		IF NVL(pEmpresa,'') = '' OR NVL(pTipoPaquete,'') = '' THEN
		
			LET  cCod_Ret  = '000001';
			
		ELSE
	
			SELECT NVL(num_registros_autoguardado,0) INTO iNumReg 
			FROM "informix".ss_cattipopaquetes
			WHERE empresa = pEmpresa AND tipopaquete = pTipoPaquete;
		
		
			LET  cCod_Ret  = '000000';
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCod_Ret = '000002';
				
			END IF;
			
		END IF;	
		
		RETURN NVL(cCod_Ret,''),NVL(iNumReg,0);
		
END
END PROCEDURE
DOCUMENT 
'ELABORO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA CONSULTAR EL NUMERO DE REGISTROS QUE PERMITE DEL AUTOGUARDADO DEPENDIENDO DEL TIPO DE PAQUETE',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_sesioncaja(pEmpresa CHAR(3),pCaja CHAR(14),pUsuario CHAR(8),pTipo CHAR(1),pTiempo INTEGER)

	RETURNING CHAR(6) AS Cod_Retorno, CHAR(53) AS Empleado;
			  
--DEFINICION DE VARIABLES
	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr	INTEGER;
	DEFINE iActualizar	INTEGER;
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cDescripcion CHAR(45);
	DEFINE dHoraOcupada DATETIME YEAR TO MINUTE;
	DEFINE dHoraActual  DATETIME YEAR TO MINUTE;
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet = '000000';
	LET iActualizar = 0;
	LET cNumEmpleado	= '';
	LET cDescripcion = '';
	LET dHoraOcupada	= '';
	LET dHoraActual = '';
	
	------------------------------------------------------------
			--	CODIGOS DE RETORNO
			--	000000	=	EJECUCION CORRECTA
			--	000001	=	PARAMETROS DE ENTRADA VACIOS O NULOS
			--	000002	=	CAJA ABIERTA
			--	000003	=	SESION EXPIRADA
			--	000004	=	SESION ACTIVA
			--	000005	=	CAJA DISPONIBLE
			--	000006	=	NO SE ENCONTRO REGISTRO
	------------------------------------------------------------
	
	BEGIN
		
		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN cCodRet,cNumEmpleado||' '||cDescripcion;
			END IF;
		END  EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_sesioncaja.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pCaja,'') = '' OR NVL(pUsuario,'') = '' OR NVL(pTipo,'') = '' OR NVL(pTiempo,0) = 0 THEN	
			LET  cCodRet  = '000001';			
		ELSE			
			--SELECCIONA LA FECHA DEL SERVIDOR
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO MINUTE
			INTO dHoraActual
			FROM sysmaster:"informix".sysshmvals;		
			
			SELECT numempleado_cajaocupada,fecha_cajaocupada
			INTO cNumEmpleado, dHoraOcupada
			FROM "informix".ss_numcajas
			WHERE empresa = pEmpresa
			AND numerocaja = pCaja;		

			IF NVL(cNumEmpleado,'') <> '' THEN
				LET dHoraOcupada  = dHoraOcupada::DATETIME YEAR TO MINUTE +  (pTiempo) UNITS MINUTE;
			END IF;		
			
			IF pTipo = '0' THEN						--EL USUARIO QUEIRE ABRIR LA CAJA	(BLOQUEAR)
				IF NVL(cNumEmpleado,'') = '' THEN	--EL NUMERO DE EMPLEADO ESTA VACIO
					LET iActualizar = 1;			--SE PUEDE ABRIR LA CAJA CORRECTAMENTE
				ELSE
					IF pUsuario = cNumEmpleado AND dHoraOcupada > dHoraActual THEN
						LET cCodRet = '000004';
						LET cNumEmpleado = '';
					ELIF dHoraOcupada > dHoraActual THEN	--EL NUMERO DE EMPLEADO TIENE DATOS Y LA FECHA-HORA OCUPADA ES MAYOR A LA HORA ACTUAL
						LET cCodRet = '000002';			--REGRESA EL NOMBRE Y NUMERO DEL EMPLEADO QUE LA ESTA USANDO
						SELECT nombre				
						INTO cDescripcion
						FROM bdinteg:"informix".si_ejecut
						WHERE empresa = pEmpresa
						AND ejecutivo = cNumEmpleado;
					ELIF dHoraOcupada <= dHoraActual THEN	--LA FECHA-HORA ES MENOR O IGUAL A LA HORA ACTUAL
						LET iActualizar = 1;				--SE ACTUALIZA PARA PODER ABRIR LA CAJA
					END IF;
				END IF;
			ELIF pTipo = '1' THEN					--EL USUARIO QUIERE CERRAR LA CAJA	(DESBLOQUEAR)		
				IF cNumEmpleado = pUsuario THEN		--EL NUMERO DE EMPLEADO REGISTRADO ES IGUAL AL DEL PARAMETRO
					LET pUsuario = NULL;			--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
					LET dHoraActual = NULL;			--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
					LET iActualizar = 1;				--SE ACTUALIZARA SEGUN SEA LA SIGUIENTE VALIDACION
				END IF;
			ELIF pTipo = '2' THEN					--SE CONSULTA LA SESION
				IF cNumEmpleado = pUsuario THEN			--EL NUMERO DE EMPLEADO ES IGUAL AL PARAMETRO
					IF dHoraOcupada > dHoraActual THEN	--LA FECHA-HORA OCUPADA ES MAYOR A LA HORA
						LET cCodRet = '000004';
						LET cNumEmpleado = '';
					ELIF dHoraOcupada <= dHoraActual THEN	--LA FECHA-HORA ES MENOR O IGUAL A LA HORA ACTUAL (CAJA DISPONIBLE)
						LET cCodRet = '000003';				
						LET pUsuario = NULL;                --VARIABLES EN NULL PARA PODER CERRAR LA CAJA
						LET dHoraActual = NULL;				--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
						LET iActualizar = 1;	            
					END IF;
				ELSE
					IF cNumEmpleado <> pUsuario THEN	--EL NUMERO DE EMPLEADO ES DIFERENTE AL PARAMETRO
						IF NVL(cNumEmpleado,'') = '' THEN	-- --EL NUMERO DE EMPLEADO ESTA EN NULL
							LET cCodRet = '000005';
							LET cNumEmpleado = '';
						ELSE
							LET cCodRet = '000002';		--EL NUMERO DE EMPLEADO ES DIFERENTE AL PARAMETRO Y DIFERENTE DE NULL
							SELECT nombre
							INTO cDescripcion
							FROM bdinteg:"informix".si_ejecut
							WHERE empresa = pEmpresa
							AND ejecutivo = cNumEmpleado;
						END IF;	
					END IF;
				END IF;
			END IF;
			
			IF iActualizar = 1 THEN				
				UPDATE "informix".ss_numcajas
				SET numempleado_cajaocupada = pUsuario,
				fecha_cajaocupada= dHoraActual
				WHERE empresa = pEmpresa
				AND numerocaja = pCaja;
			END IF;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCodRet = '000006';				
			END IF;
		END IF;
		
		RETURN cCodRet,cNumEmpleado||' '||cDescripcion;
			
	END
END PROCEDURE
DOCUMENT 
'ELABORO: 95281495-ERNESTO AGUILERA',
'FECHA CREACION: 27/02/2015',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA VALIDAR CUANDO UNA CAJA ESTA ABIERTA Y CUANDO ESTA CERRADA.',
'			ADEMAS DE VALIDAR LA SESION DEL USUARIO',
'VERSION: 27022015.1610',
'BD: BDISUC';

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