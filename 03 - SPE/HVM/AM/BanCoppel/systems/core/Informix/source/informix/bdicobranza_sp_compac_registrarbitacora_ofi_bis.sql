CREATE PROCEDURE "informix".sp_compac_registrarbitacora_ofi_bis(pEmpresa CHAR(3),
                                              pEjecutivo CHAR(8),
                                              pSucursal CHAR(4),
                                              pOrigen   SMALLINT,
                                              pNumCred  CHAR(20),
                                              pEjecut_Convenio CHAR(15),
                                              pRespCte  CHAR(30),--Se cambio x30 'VPR
                                              pMotivo   SMALLINT
                                              )

RETURNING CHAR(5)   AS retorno,
          CHAR(100) AS mensaje_ret;

--definicion de variables
DEFINE sSqlErr                  SMALLINT;
DEFINE sIsamErr                 SMALLINT;
DEFINE cErrorInfo               CHAR(100);

DEFINE cCodRet                  CHAR(5);
DEFINE cMensaje_ret             CHAR(100);

--inicializacion de variables	  
LET sSqlErr     = 0;
LET sIsamErr    = 0;
LET cErrorInfo  = "";


LET cCodRet         = "";
LET cMensaje_ret    = "";


--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_registrarbitacoraconvenio.out";
--TRACE ON;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

	ON EXCEPTION SET sSqlErr, sIsamErr, cErrorInfo
            LET cCodRet = sSqlErr;
            LET cMensaje_ret = cErrorInfo;		
            RETURN cCodRet, cMensaje_ret;
	END EXCEPTION;

	
	
		EXECUTE PROCEDURE sp_compac_registrarbitacora_bis(pEmpresa,
                                                      pEjecutivo,
                                                      pSucursal,
                                                      pOrigen,
                                                      pNumCred,
                                                      pEjecut_Convenio,
                                                      pRespCte,
                                                      pMotivo
                                                      )
					INTO cCodRet, cMensaje_ret;
					
		RETURN cCodRet, cMensaje_ret;

END 
END PROCEDURE
DOCUMENT
"Descripción: Se modifico el tipo de dato del campo pRespCte por un char(30)",
"Base de datos: bdicobranza",
"Fecha: 18-Ago-2015",
"Autor:Viridiana Paredes Romero";

CREATE PROCEDURE "informix".sp_consultacuentascliente_ofi_bis(
                                            pEmpresa char (3),
                                            pTipoBusqueda char(1),
                                            pNumero char (20),
                                            pIndice char (3),
                                            pFecha date
                                            )

RETURNING
            char(5) AS retorno, --cod retorno
            char(20) AS numero_cte,
            char(26) AS apellido_pat,
            char(26) AS apellido_mat,
            char(26) AS nombre1,
            char(26) AS nombre2,
            char(20) AS numero_refCte,
            char(13) AS numero_tel,
            char(20) AS numero_cto,
            char(40) AS descripcion_cto,
            char(30) AS situacion_especial,
            char(30) AS causa,
            char(30) AS saldo_actual,
            char(30) AS tipo_convenio,

            char(30) AS numero_dias_venc,
            char(30) AS numero_pagos_venc,
            char(30) AS pago_mini_venc,
			char(1) AS estatus_tarj,
			decimal(18,2) AS total_liquidar,
            char(30) AS prox_pago_vencer,
            char(30) AS fecha_ulti_abono,
            char(30) AS import_ulti_abono,
            char(30) AS fecha_ulti_conven,
            char(30) AS import_convenio,
            char(3) AS cumplio_convenio,
            char(3) AS origen_convenio,
            decimal(14,2) AS monto_mini_negociar; 


DEFINE v_codret char(5);
DEFINE v_numcte char(20);
DEFINE v_apaterno char (26);
DEFINE v_amaterno char (26);
DEFINE v_nombre1 char (26);
DEFINE v_nombre2 char (26);
DEFINE v_numcteref char(20);
DEFINE v_telefono char(13);
DEFINE v_numcredito char (20);
DEFINE v_descripcioncred char(40);
DEFINE v_situacionespecial char(30);
DEFINE v_causa char(30);
DEFINE v_saldoactual decimal (16,2);
DEFINE v_tipoconvenio char (30);

DEFINE v_numdiasvencidos char(30);
DEFINE v_numpagovencidos char(30);
DEFINE v_pagominvencido char(30);
DEFINE v_proxpagoporvencer char(30);
DEFINE v_fechaultabono char(30);
DEFINE v_importeultabono char(30);
DEFINE v_fechaultconvenio date;
DEFINE v_importeconvenio decimal(14);
DEFINE v_cumplioconvenio char(3);
DEFINE v_origenconvenio smallint;
DEFINE dMtoNegociar DECIMAL(14,2);
DEFINE cStatus_tar char(1);
DEFINE dTotal_liquidacion decimal(18,2);

DEFINE v_sqlerr integer;
DEFINE v_isamerr integer;


LET v_codret = "";
LET v_numcte = "";
LET v_apaterno = "";
LET v_amaterno = "";
LET v_nombre1 = "";
LET v_nombre2 = "";
LET v_numcteref = "";
LET v_telefono = "";
LET v_numcredito = "";
LET v_descripcioncred = "";
LET v_situacionespecial = "";
LET v_causa = "";
LET v_saldoactual = "";
LET v_tipoconvenio = "";

LET v_numdiasvencidos = "";
LET v_numpagovencidos = "";
LET v_pagominvencido = "";
LET v_proxpagoporvencer = "";
LET v_fechaultabono = "";
LET v_importeultabono = "";
LET v_fechaultconvenio = "";
LET v_importeconvenio = "";
LET v_cumplioconvenio = "";
LET v_origenconvenio = "";
LET dMtoNegociar  = 0;
LET cStatus_tar = "";
LET dTotal_liquidacion = 0;

LET v_sqlerr = 0;
LET v_isamerr = 0;


--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_consultacuentascliente_ofi.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET v_sqlerr, v_isamerr
        IF v_sqlerr != 0 THEN
            LET v_codret=v_sqlerr;
            --ROLLBACK WORK;
			
            RETURN TRIM(NVL (v_codret,"")), TRIM(NVL(v_numcte,"")),TRIM(NVL(v_apaterno,"")), TRIM(NVL(v_amaterno,"")), TRIM(NVL(v_nombre1,"")),TRIM(NVL(v_nombre2,"")),
				   TRIM(NVL(v_numcteref,"")), TRIM(NVL(v_telefono,"")), TRIM(NVL(v_numcredito,"")), TRIM(NVL(v_descripcioncred,"")),TRIM(NVL(v_situacionespecial,"")), 
			       TRIM(NVL(v_causa,"")), TRIM(NVL(v_saldoactual,"")), TRIM(NVL(v_tipoconvenio,"")),TRIM(NVL(v_numdiasvencidos,"")), TRIM(NVL(v_numpagovencidos,"")),
				   TRIM(NVL(v_pagominvencido,"")),TRIM(NVL(cStatus_tar,"")), TRIM(NVL(dTotal_liquidacion,"0")),TRIM(NVL(v_proxpagoporvencer,"")),TRIM(NVL( v_fechaultabono,"")),
				   TRIM(NVL(v_importeultabono,"")),TRIM(NVL(v_fechaultconvenio,"")), TRIM(NVL(v_importeconvenio,"")), TRIM(NVL(v_cumplioconvenio,"")), TRIM(NVL(v_origenconvenio,"")),TRIM(NVL(dMtoNegociar,"0")) ;
        END IF;
    END EXCEPTION;

	FOREACH EXECUTE PROCEDURE sp_consultacuentascliente_bis(
                                                pEmpresa,
                                                pTipoBusqueda,  
                                                pNumero,
                                                pIndice,
                                                pFecha
                                                )
												
     INTO  v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
          v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, cStatus_tar, dTotal_liquidacion,
		  v_proxpagoporvencer, v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar
		  
		IF v_codret = '000' THEN		  
			RETURN TRIM(NVL (v_codret,"")), TRIM(NVL(v_numcte,"")),TRIM(NVL(v_apaterno,"")), TRIM(NVL(v_amaterno,"")), TRIM(NVL(v_nombre1,"")),TRIM(NVL(v_nombre2,"")),
			TRIM(NVL(v_numcteref,"")), TRIM(NVL(v_telefono,"")), TRIM(NVL(v_numcredito,"")), TRIM(NVL(v_descripcioncred,"")),TRIM(NVL(v_situacionespecial,"")),
			TRIM(NVL(v_causa,"")), TRIM(NVL(v_saldoactual,"")), TRIM(NVL(v_tipoconvenio,"")),TRIM(NVL(v_numdiasvencidos,"")), TRIM(NVL(v_numpagovencidos,"")),
			TRIM(NVL(v_pagominvencido,"")),TRIM(NVL(cStatus_tar,"")), TRIM(NVL(dTotal_liquidacion,"0")),TRIM(NVL(v_proxpagoporvencer,"")),TRIM(NVL( v_fechaultabono,"")),
			TRIM(NVL(v_importeultabono,"")),TRIM(NVL(v_fechaultconvenio,"")), TRIM(NVL(v_importeconvenio,"")), TRIM(NVL(v_cumplioconvenio,"")),
			TRIM(NVL(v_origenconvenio,"")),TRIM(NVL(dMtoNegociar,"0")) WITH RESUME;			
		END IF;
    
	END FOREACH;		  
	
	FOREACH EXECUTE PROCEDURE bdicobranza:"informix".sp_consultacuentascliente_crd(
													pEmpresa,
													pTipoBusqueda,  
													pNumero,
													pIndice ,
													pFecha
													)
													
	 INTO v_codret, v_numcte,  v_apaterno, v_amaterno,v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred, 
            v_situacionespecial, v_causa, v_saldoactual,v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido,cStatus_tar,dTotal_liquidacion,
            v_proxpagoporvencer, v_fechaultabono,v_importeultabono, v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio, dMtoNegociar 
			
			
		IF v_codret = '000' THEN		  
			RETURN TRIM(NVL (v_codret,"")), TRIM(NVL(v_numcte,"")),TRIM(NVL(v_apaterno,"")), TRIM(NVL(v_amaterno,"")), TRIM(NVL(v_nombre1,"")),TRIM(NVL(v_nombre2,"")),
			TRIM(NVL(v_numcteref,"")), TRIM(NVL(v_telefono,"")), TRIM(NVL(v_numcredito,"")), TRIM(NVL(v_descripcioncred,"")),TRIM(NVL(v_situacionespecial,"")),
			TRIM(NVL(v_causa,"")), TRIM(NVL(v_saldoactual,"")), TRIM(NVL(v_tipoconvenio,"")),TRIM(NVL(v_numdiasvencidos,"")), TRIM(NVL(v_numpagovencidos,"")),
			TRIM(NVL(v_pagominvencido,"")),TRIM(NVL(cStatus_tar,"")), TRIM(NVL(dTotal_liquidacion,"0")),TRIM(NVL(v_proxpagoporvencer,"")),TRIM(NVL( v_fechaultabono,"")),
			TRIM(NVL(v_importeultabono,"")),TRIM(NVL(v_fechaultconvenio,"")), TRIM(NVL(v_importeconvenio,"")), TRIM(NVL(v_cumplioconvenio,"")),
			TRIM(NVL(v_origenconvenio,"")),TRIM(NVL(dMtoNegociar,"0")) WITH RESUME;			
		END IF;
				  
	END FOREACH;
END;
END PROCEDURE
DOCUMENT
'Descripción: Se agrego la ejecucion del nuevo sp_consultacuentascliente_crd, se agrego para que reciba los nuevos campos',
'que se agregaron al procedimiento sp_consultacuentascliente',
'Fecha: 21-Ago-2015',
'Base de datos: bdicobranza',
'Autor:Viridiana Paredes Romero';

create procedure "informix".sp_validavencidos_bis(pEmpresa char(3), pNumCredito char(20), pFechaConsulta Date)

    RETURNING VARCHAR(6), INTEGER, INTEGER;

--15/07/2008
--Creado por:
--Abraham Ayala Aguilar
--Valida que el cliente no tenga creditos vencidos

--10-10-2008
--Modifico:
--Abraham Ayala
--Se sustituyo la manera de consultar si el cliente tiene cuentas vencidas, ahora se calcula conforme a la fecha de vencido, atraves del SP_dias_vencido



--DEFINICION DE VARIABLES--
    DEFINE vCod_Ret       VARCHAR(6);
    DEFINE iSqlErr        INTEGER;
    DEFINE vDifDias       INTEGER;
    DEFINE vFecha2        CHAR(10);
    DEFINE vEstadoCuenta  INTEGER;
    DEFINE vStatus        INTEGER;

	--Set debug file to '/tmp/sp_validavencidos_funciondiasvenc.out';
	--trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret, vDifDias, vEstadoCuenta;
            END IF;
        END EXCEPTION;

--INICIALIZACION DE VARIABLES--
        LET vCod_Ret = "999";   --No tiene cuentas vencidas
        LET vDifDias = 0;
        LET vEstadoCuenta = 3;  -- Para cuando No tiene cuentas vencidas

        IF pEmpresa IS NOT NULL AND TRIM(pEmpresa) <> '' AND pNumCredito IS NOT NULL AND TRIM(pNumCredito) <> '' AND pFechaConsulta IS NOT NULL THEN

            Execute procedure bdicred:sp_dias_vencido_bis(pEmpresa, pNumCredito) into vCod_Ret, vStatus;

            IF vCod_Ret = '000' THEN
                IF vStatus > 0 THEN
                    LET vDifDias = vStatus;

                    IF vDifDias > 0 AND vDifDias < 61 THEN
                        LET vEstadoCuenta = 1;      --Compromiso de pago
                    ELIF vDifDias > 60 THEN ---AND vDifDias < 166 THEN
                        LET vEstadoCuenta = 2;      --Acuerdo de pago
                    --ELIF vDifDias > 165 THEN
                      --  LET vEstadoCuenta = 0;      --No se elaboran compromisos ni acuerdos
                    END IF;
                END IF;
            ELSE
                LET vCod_Ret = '002';   --Error al calcular dias vencidos
                RETURN vCod_Ret, vDifDias, vEstadoCuenta;
            END IF;
        ELSE
            LET vCod_Ret = "001";   --Faltan valores
        END IF;

        RETURN vCod_Ret, vDifDias, vEstadoCuenta;
    END;
END PROCEDURE;