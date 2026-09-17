CREATE PROCEDURE "informix".sp_abono_ref(pUsuario     char(10),
                                         pIdFuncion   char(10),
                                         pTransacc    CHAR(4),
                                         pCuenta      CHAR(20),
                                         pDocto       INTEGER,
                                         pMto_tot     MONEY(14,2),
                                         pReferencia  CHAR(40))
        RETURNING CHAR(5) as codret,
                  CHAR(16) as Folio_usu;

DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE cUsuario       CHAR(8);
DEFINE cTransuc       CHAR(4);
DEFINE cFolio_suc     CHAR(16);
DEFINE mMto_firme     MONEY(14,2);
DEFINE mMto_sbc       MONEY(14,2);
DEFINE mMto_rem       MONEY(14,2);
DEFINE sDias_ret      SMALLINT;
DEFINE cDivisa        CHAR(2);
DEFINE cNum_tarjeta   CHAR(16);
DEFINE cUsuautoriza   CHAR(8);

DEFINE dHora          DATETIME HOUR TO SECOND;
DEFINE cHora          CHAR(6);

LET cCodRet = '00000';
LET iSqlErr = 0;

LET cEmpresa = '001';
LET cTransuc = "0000";
LET cFolio_suc = pUsuario;

LET mMto_firme = pMto_tot;
LET mMto_sbc = 0;
LET mMto_rem = 0;
LET sDias_ret = 0;
LET cDivisa = "01";
LET cNum_tarjeta = "";
LET cUsuautoriza = "";

LET cHora = CAST(SUBSTR(CURRENT,12,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,15,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,18,2) AS CHAR(2));
LET cFolio_suc = TRIM(cFolio_suc) || cHora;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFolio_suc;
                END IF;
        END EXCEPTION;

        IF  pDocto = ''
        THEN
                LET pDocto = 0;
        END IF;
        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR ptransacc = ''
         OR pCuenta = ''
---------OR pDocto = ''
         OR pMto_tot = 0
---------OR pReferencia = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cFolio_suc;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cFolio_suc;
        END IF;

	SET ISOLATION TO DIRTY READ;
        SELECT sucursal
          INTO cSucursal
          FROM bdinteg:"informix".si_ejecut
         WHERE ejecutivo = pUsuario;

        SELECT divisa
          INTO cDivisa
          FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
         WHERE mc.empresa = cEmpresa
           AND cuenta = pCuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        EXECUTE PROCEDURE bdicheq:"informix".abono_ref(cEmpresa,
                                                        cSucursal,
                                                        pUsuario,
                                                        pTransacc,
                                                        cTransuc,
                                                        cFolio_suc,
                                                        pCuenta,
                                                        pDocto,
                                                        pMto_tot,
                                                        mMto_firme,
                                                        mMto_sbc,
                                                        mMto_rem,
                                                        sDias_ret,
                                                        cDivisa,
                                                        pReferencia,
                                                        cNum_tarjeta,
                                                        cUsuautoriza)
                INTO cCodRet;

        IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '110' THEN
                LET cCodRet = '00003';
        END IF;
        IF cCodRet = '301' THEN
                LET cCodRet = '00389'; --  La cuenta esta bloqueada no permite realizar abonos. Favor de verificar
        END IF;

        RETURN cCodRet, cFolio_suc;

END;

END PROCEDURE
DOCUMENT 'MODIFICO: Rodolfo Conde Flores',
'FECHA: 13/10/2014',
'DESCRIPCION: Se anexa mapeo de codigos de retorno para la aplicaciÃ³n SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargo_ref(pUsuario     char(10),
                                         pIdFuncion   char(10),
                                         pTransacc    CHAR(4),
                                         pCuenta      CHAR(20),
                                         pCheque      INTEGER,
                                         pMto_tot     MONEY(14,2),
                                         pReferencia  CHAR(40))
        RETURNING CHAR(5) as codret,
                  CHAR(16) as Folio_usu;

DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE cUsuario       CHAR(8);
DEFINE cTransuc       CHAR(4);
DEFINE cFolio_suc     CHAR(16);
DEFINE mMto_firme     MONEY(14,2);
DEFINE mMto_sbc       MONEY(14,2);
DEFINE mMto_rem       MONEY(14,2);
DEFINE sDias_ret      SMALLINT;
DEFINE cDivisa        CHAR(2);
DEFINE cNum_tarjeta   CHAR(16);
DEFINE cUsuautoriza   CHAR(8);

DEFINE dHora          DATETIME HOUR TO SECOND;
DEFINE cHora          CHAR(6);

DEFINE vTranret         CHAR(4);
DEFINE vFechoy          DATE;
DEFINE vSdodisp         MONEY(14,2);
DEFINE vMontoret        MONEY(14,2);

LET vTranret = "";
LET vFechoy = TODAY;
LET vSdodisp = 0;
LET vMontoret = 0;

LET cCodRet = '00000';
LET iSqlErr = 0;

LET cEmpresa = '001';
LET cTransuc = "0000";
LET cFolio_suc = pUsuario;

LET mMto_firme = pMto_tot;
LET mMto_sbc = 0;
LET mMto_rem = 0;
LET sDias_ret = 0;
LET cDivisa = "01";
LET cNum_tarjeta = "";
LET cUsuautoriza = "";

LET cHora = CAST(SUBSTR(CURRENT,12,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,15,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,18,2) AS CHAR(2));
LET cFolio_suc = TRIM(cFolio_suc) || cHora;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFolio_suc;
                END IF;
        END EXCEPTION;

        IF  pCheque = ''
        THEN
                LET pCheque = 0;
        END IF;
        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR ptransacc = ''
         OR pCuenta = ''
---------OR pCheque = ''
         OR pMto_tot = 0
---------OR pReferencia = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cFolio_suc;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cFolio_suc;
        END IF;

        SELECT sucursal
          INTO cSucursal
          FROM bdinteg:"informix".si_ejecut
         WHERE ejecutivo = pUsuario;

        SELECT divisa
          INTO cDivisa
          FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
         WHERE mc.empresa = cEmpresa
           AND cuenta = pCuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa,
                                                        cSucursal,
                                                        pUsuario,
                                                        pTransacc,
                                                        cTransuc,
                                                        cFolio_suc,
                                                        pCuenta,
                                                        pCheque,
                                                        pMto_tot,
                                                        cDivisa,
                                                        pReferencia,
                                                        cNum_tarjeta,
                                                        cUsuautoriza)
                INTO    cCodRet,
                        vTranret,
                        vFechoy,
                        vSdodisp,
                        vMontoret;

        IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '110' THEN
                LET cCodRet = '00003';
        END IF;
		IF cCodRet = '200' THEN
                LET cCodRet = '00390'; -- LA CUENTA NO PERMITE REALIZAR CARGOS. FAVOR DE VERIFICAR
        END IF;
		IF cCodRet = '400' THEN
                LET cCodRet = '00391'; -- LA CUENTA TIENE FONDOS INSUFICIENTES
        END IF;
		IF cCodRet = '300' THEN
                LET cCodRet = '00392'; -- LA CUENTA ESTA BLOQUEADA NO PERMITE REALIZAR CARGOS. FAVOR DE VERIFICAR
        END IF;

        RETURN cCodRet, cFolio_suc;

END;

END PROCEDURE
DOCUMENT 'MODIFICO: Rodolfo Conde Flores',
'FECHA: 13/10/2014',
'DESCRIPCION: Se anexa mapeo de codigos de retorno para la aplicaciÃ³n SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_borraimagenes(pUsuarioC CHAR(8),
                                                                                pIdFuncionC CHAR(10), 
                                                                                pIdOficio INT,
                                                                                pIdBusqueda INT,
                                                                                pIdCte INT, 
                                                                                pNumCliente CHAR(20), 
                                                                                pTipoCuenta CHAR(2),
                                                                                pNumCuenta CHAR(20))
        RETURNING CHAR(5) AS codret,
                INT AS regs_borrados
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iNoRegistros INT;
        DEFINE cStatus CHAR(1);
        DEFINE cStatus2 CHAR(1);
		DEFINE cNumCtaAux CHAR(20);
		DEFINE iNoRegistrosAux INT;
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = -1;
		LET cNumCtaAux = '';
		LET iNoRegistrosAux = -1;
		
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, iNoRegistros;
                        END IF;
                END EXCEPTION;
				
				--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_borraimagenes.sql';
				--TRACE ON;
				
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                --VALIDACION DE CAMPOS REQUERIDOS
                IF pUsuarioC = ''OR 
                        pIdFuncionC = ''OR 
                        pIdOficio = ''OR 
                        pIdBusqueda = ''OR 
                        pIdCte = ''OR 
                        pTipoCuenta = ''OR 
                        pNumCliente = ''OR 
                        pNumCuenta = '' 
                        then LET cCodRet = '00003';
                                RETURN cCodRet, iNoRegistros;
                END IF;
				
                IF pTipoCuenta NOT IN('01', '03', '06', '00') THEN
                        LET cCodRet = '00048'; -- El tipo de sistema busqueda es incorrecto
                        RETURN cCodRet, iNoRegistros;
                END IF;
				
				DELETE FROM sw_ro_cteexp
				WHERE id_oficio = pIdOficio
					AND id_busqueda = pIdBusqueda
					AND id_resulcte = pIdCte
					AND tipo_cuenta = pTipoCuenta
					AND numcte = pNumCliente
					AND cuenta = pNumCuenta;
						
                IF pNumCuenta = '99999999999' THEN
					UPDATE sw_ro_resulcte SET ind_expdig = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio 
							AND id_busqueda = pIdBusqueda 
							AND id_resulcte = pIdCte 
							AND certifica_imagenes = '1';
				   
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte 
							AND id_busqueda = pIdBusqueda 
							AND id_oficio = pIdOficio;              
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio 
							AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                ELSE
					-- Se actualiza en estatus en la tabla de cuentas
					UPDATE sw_ro_ctecta SET certifica_imagenes = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio AND cuenta = pNumCuenta;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio AND id_busqueda = pIdBusqueda AND id_resulcte = pIdCte AND certifica_imagenes = '1';
					
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;             
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' END 
					INTO cStatus
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND certifica_imagenes = '1';
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                END IF;
                LET iNoRegistros = dbinfo('sqlca.sqlerrd2');
                RETURN cCodRet, iNoRegistros;
        END
END PROCEDURE;