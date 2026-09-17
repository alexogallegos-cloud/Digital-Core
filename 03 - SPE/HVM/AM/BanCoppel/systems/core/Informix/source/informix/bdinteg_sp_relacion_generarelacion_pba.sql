CREATE PROCEDURE "informix".sp_relacion_generarelacion_pba (pNumCte CHAR(20), pNumCteRef CHAR(20),pNumEmpleado CHAR(10),pTipoRel CHAR(1),pOrigen CHAR(1))
	RETURNING
	CHAR(6)  AS COD_RET, 
	CHAR(80) AS MENSAJE_RETORNO;

-- Modificado por Maria Elena Angulo (AAME). 30 Agosto 2013 Se modifica para comentar la validación que indica que 
--las relaciones por Alta Unica no pueden separarse.	
	
---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet     	CHAR(80);

DEFINE cValor     		CHAR(100);
DEFINE iFiltro     		INTEGER;
DEFINE iTipoRel    		INTEGER;
DEFINE iRelacion    	INTEGER;
DEFINE sBanderaAct      SMALLINT;
DEFINE iContador        INTEGER;
DEFINE iSecuencia       INTEGER;

DEFINE cEmpresa         CHAR(3);
DEFINE cNumCteBanco     CHAR(20);  
DEFINE cClienteCoppel   CHAR(20); 
DEFINE cNumEmpleado     CHAR(8);
DEFINE sTipoRelacion    SMALLINT; 
DEFINE cDefinicion      CHAR(10); 
DEFINE cStatus          CHAR(10); 
DEFINE sTipoReIni       SMALLINT; 
DEFINE dFechaInsert     DATE; 
DEFINE cClienteProsp    CHAR(1);
DEFINE cMensaje         CHAR(50);


---INICIALIZACIONES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet        	= "PROCESO EXITOSO";   

LET cValor        	= "";   
LET iFiltro        	= 0;   
LET iTipoRel        = 0;   
LET iRelacion       = 0;   
LET sBanderaAct     = 0;
LET iContador       = 0;
LET iSecuencia      = 0;

LET cEmpresa         = "";
LET cNumCteBanco     = "";  
LET cClienteCoppel   = ""; 
LET cNumEmpleado     = ""; 
LET sTipoRelacion    = 0; 
LET cDefinicion      = ""; 
LET cStatus          = ""; 
LET sTipoReIni       = 0; 
LET dFechaInsert     = DATE(1); 
LET cClienteProsp    = "";
LET cMensaje	     = "";
BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeRet,''));
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/respaldosbd/felipe/sp_relacion_generarelacion.out";				 
	--TRACE ON;
	
	-- VALIDA LOS PARAMETROS DE ENTRADA  
	IF NVL(pNumCteRef,"") =  "" AND pTipoRel NOT IN('0','1') THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
	ELSE
		    IF pTipoRel = '1' AND  pOrigen <> '0' THEN --para obtener si es una relacion 
				LET iFiltro = 43;
				LET iTipoRel = 3;
			ELSE -- o separacion
				LET iFiltro = 44;
				LET iTipoRel = 0;
			END IF;
			IF pOrigen =1 THEN
				LET iTipoRel = 1;
			ELIF pOrigen =3 AND pTipoRel = '1' THEN
				
				SELECT COUNT(cliente)
				INTO iContador
				FROM bdinteg:"informix".si_relacion_ctebcplcpl
				WHERE cliente = pNumCteRef;
				
			END IF;
			IF NVL(iContador,0) = 0 THEN
				
				SELECT  valor 
				INTO cValor
				FROM bdicobranza:"informix".cb_param 
				WHERE empresa = '001' AND descripcion = 'REP_TIPO_RELACION'
				AND cod_param = iFiltro;
			
				SELECT tipo_relacion INTO iRelacion FROM bdinteg:"informix".si_relacion_ctebcplcpl
				WHERE empresa = '001' AND numcte_banco = pNumCte;		
			
				--
				IF iRelacion IS NULL THEN --VALIDACION DEL TIPO DE RELACION SI ES NULA O NO
							INSERT INTO bdinteg:"informix".si_relacion_ctebcplcpl 
							(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
							VALUES ('001',pNumCte,pNumCteRef,pNumEmpleado,pOrigen,cValor,pTipoRel,0,TODAY);
							LET sBanderaAct = 1;
				ELSE	
						--SE VALIDA SI EL STATUS ES VALIDO PARA REALIZAR LA RELACION
						IF (pTipoRel = '1' AND iRelacion IN (1,2,3))  OR (pTipoRel = '0' AND iRelacion NOT IN (1,2,3)) THEN 
								LET cCodRet = "000002";
								LET cMensajeRet = "Estatus inválido para realizar la consulta";
						ELSE 
							
							/*IF (iRelacion =1) THEN
								LET cCodRet = "000003";
								LET cMensajeRet = "Las relaciones por alta unica no se pueden separar";
							ELSE */ -- AAME. RQM 09 333 Se comenta condicion de que no se pueden separar las relaciones por alta unica 
								IF pOrigen =0 THEN	
									LET pTipoRel = 0;
								END IF;
								
								SELECT MAX(secuencia)
								INTO iSecuencia
								FROM bdinteg:"informix".si_relacion_ctebcplcpl_hist
								WHERE empresa = '001'
								AND numcte_banco = pNumCte;
								
								LET iSecuencia =  NVL(iSecuencia,0) + 1;
								
								SELECT  empresa, numcte_banco,  cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp
								INTO cEmpresa , cNumCteBanco, cClienteCoppel, cNumEmpleado, sTipoRelacion, cDefinicion, cStatus, sTipoReIni, dFechaInsert, cClienteProsp
								FROM bdinteg:"informix".si_relacion_ctebcplcpl
								WHERE empresa = '001'
								AND numcte_banco = pNumCte;
								
								INSERT INTO bdinteg:"informix".si_relacion_ctebcplcpl_hist (empresa, numcte_banco, secuencia, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp)
								VALUES (cEmpresa , cNumCteBanco, iSecuencia, cClienteCoppel, cNumEmpleado, sTipoRelacion, cDefinicion, cStatus, sTipoReIni, dFechaInsert, cClienteProsp);
								
								UPDATE  bdinteg:"informix".si_relacion_ctebcplcpl 
									SET numempleado = pNumEmpleado,	
										definicion = cValor,
										status = pTipoRel,
										tipo_re_ini = tipo_relacion,
										tipo_relacion = iTipoRel,
										fecha_insert = TODAY,
										cliente = CASE WHEN pTipoRel = '1' THEN pNumCteRef ELSE "" END
									WHERE empresa = '001'
									AND numcte_banco = pNumCte;	
									LET sBanderaAct = 1;
						  --END IF;	-- AAME. RQM 09 333 Se comenta condicion de que no se pueden separar las relaciones por alta unica 
						END IF;	-- FIN DE VALIDACION DE SI EL STATUS ES VALIDO PARA REALIZAR LA RELACION
				END IF;	--FIN VALIDACION DEL TIPO DE RELACION SI ES NULA O NO
			ELSE
				LET cCodRet = '000003';
				SELECT descripcion INTO cMensaje FROM bdinteg:"informix".si_codret WHERE codigo_retorno = '612' AND sistema = '06'; 
				LET cMensajeRet = TRIM(NVL(cMensaje,''));
			END IF;
	END IF;	--FIN DEL VALIDA LOS PARAMETROS DE ENTRADA
	
	IF sBanderaAct = 1 AND  pOrigen = 3 THEN
		UPDATE bdinteg:"informix".si_cliente SET numcte_ref= CASE WHEN pTipoRel = '1' THEN pNumCteRef ELSE "" END WHERE numcte = pNumCte;	
	END IF;
	
	RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeRet,''));

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Realiza la Relacion o Separacion de Clientes Coppel con Bancoppel', 
'AUTOR: Jesús Aguilar ',
'FECHA: 26 ABRIL 2012',
'BD: BDINTEG',
'VERSION: 20120426.1641',

'MODIFICACIÓN: Se agregó un UPDATE para que cada vez que se ejecute se actualize la tabla de si_relacion_ctebcplcpl', 'asi como tambien el origen para saber de donde proviene', 
'Modificó: Josué zazueta ',
'FECHA: 11 Junio 2012',
'BD: BDINTEG',
'VERSION: 20120611.1700',

'Modificación',
'DESCRIPCION: Se modifíca para que no regrese nombre del empleado,fecha de relación y numero de referencia en caso', 'de que la el tipo de relacion sea = 0, además  se omite la separación en caso de ser una relación hecha por Alta Única', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 27  de Julio 2012',
'BD: BDINTEG',
'VERSION: 20120727.0518',

'Modificación',
'DESCRIPCION: se agrego consulta de datos del cliente antes de realizar una actualizacion  para guardar un historico de datos del cliente', 
'AUTOR: Felipe Urias ',
'FECHA: 07  de Enero 2015',
'BD: BDINTEG',
'VERSION: 20150107.1538';

CREATE PROCEDURE "informix".sp_reprocesa_cadena_ife() RETURNING	 VARCHAR(5); --Codigo de Retorno

	DEFINE iSqlErr              INTEGER;
    DEFINE sErrParseo           CHAR(5);
    DEFINE iCantReg             INTEGER;
    DEFINE sNumCte              CHAR(9);    
    DEFINE sFecha               DATETIME YEAR TO FRACTION;
    DEFINE sResultado           CHAR(10);
    DEFINE UV_REFLECTANCE       CHAR(4); 
    DEFINE UV_SHAPE             CHAR(4); 
    DEFINE IR_INK               CHAR(4); 
    DEFINE UV_REFLECTANCE_REV   CHAR(4); 
    DEFINE IR_INK_REV           CHAR(4);

    LET iSqlErr             =  0;
    LET sErrParseo          = '';
    LET iCantReg            =  0;
    LET sNumCte             = '';
    LET sFecha              = '';
    LET sResultado          = '';
    LET UV_REFLECTANCE      = '';
    LET UV_SHAPE            = '';
    LET IR_INK              = '';
    LET UV_REFLECTANCE_REV  = '';
    LET IR_INK_REV          = '';

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
        --SET DEBUG FILE TO '/tmp/anj/sp_reprocesa_cadena_ife.sql';
		--TRACE OFF;

        SELECT trim(valor) INTO iCantReg 
            FROM si_param 
                WHERE cod_param='380';

        FOREACH 
            SELECT LIMIT iCantReg numcte, Fecha 
              INTO sNumCte, sFecha
                FROM si_bitacora_ife
                 where cod_resp_ife='' 
                 --WHERE numcte='038878773'--000001511'
                
--TRACE ON; sp_parsea_cadena_idbx_2
            EXECUTE PROCEDURE sp_parsea_cadena_idbx(sNumCte, sFecha) 
                INTO sErrParseo, sResultado, UV_REFLECTANCE, UV_SHAPE, IR_INK, UV_REFLECTANCE_REV, IR_INK_REV;
--TRACE OFF;
                IF sResultado='Verdadero' THEN
                    UPDATE si_bitacora_ife set cod_resp_ife='1', resultado='Verdadero', causa_rechazo='', test_uv_reflec_anv=UV_REFLECTANCE,
                        test_uv_shape_anv=UV_SHAPE,
                        test_ir_ink_anv=IR_INK,
                        test_uv_reflectance_rev=UV_REFLECTANCE_REV,
                        test_ir_ink_rev=IR_INK_REV
                        WHERE numcte=sNumCte and fecha=sFecha;
                ELIF sResultado='Falso' THEN
                    UPDATE si_bitacora_ife set cod_resp_ife='1', resultado='Falso', causa_rechazo='Menor cantidad de campos en OK', test_uv_reflec_anv=UV_REFLECTANCE,
                        test_uv_shape_anv=UV_SHAPE,
                        test_ir_ink_anv=IR_INK,
                        test_uv_reflectance_rev=UV_REFLECTANCE_REV,
                        test_ir_ink_rev=IR_INK_REV
                        WHERE numcte=sNumCte and fecha=sFecha;
                END IF;
            
        END FOREACH

	RETURN '00000';
END
END PROCEDURE;