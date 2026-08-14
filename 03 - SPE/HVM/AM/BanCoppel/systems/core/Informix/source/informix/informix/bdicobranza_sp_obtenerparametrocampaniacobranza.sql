CREATE PROCEDURE "informix".sp_obtenerparametrocampaniacobranza(pEmpresa CHAR(3), pTipoCampania SMALLINT, pNumParam INTEGER, pGrupoParam CHAR(10))
RETURNING
	CHAR(6) AS COD_RET, ---cod_ret
	CHAR(100) AS DESCRIPCION, ---descripcion
    CHAR(100) AS VALOR_ALFAB,
    DECIMAL(18,2) AS VALOR_NUM;

	---DECLARACIONES
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cErrorInfo           CHAR(80);
    DEFINE cCodRet              CHAR(6);
    DEFINE cMensajeRet          CHAR(100);
    DEFINE iRows                INTEGER;
    DEFINE cValorAlfabetico     CHAR(100);
    DEFINE dValorNumerico       DECIMAL(18,2);

	---INICIALIZACIONES
    LET iSqlErr                 = 0;
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";
    LET cCodRet                 = "000000";
    LET cMensajeRet             = "";
    LET iRows                   = 0;
    LET cValorAlfabetico        = "";
    LET dValorNumerico          = 0.0;

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet, cValorAlfabetico, dValorNumerico;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	---SET DEBUG FILE TO "/tmp/has/sp_ObtenerParametroCampaniaCobranza.out";
	---TRACE ON;
    IF NVL(pEmpresa,"") = "" OR NVL(pTipoCampania,"") = "" OR NVL(pNumParam,"") = "" OR NVL(pGrupoParam,"") = "" THEN
        LET cCodRet = "000001";
        LET cMensajeRet = "INVALIDOS PARAMETROS DE ENTRADA";
        RETURN cCodRet, cMensajeRet, cValorAlfabetico, dValorNumerico;
    END IF
    
    SELECT NVL(valor_alfabetico,""), NVL(valor_numerico,0)
    INTO cValorAlfabetico, dValorNumerico
    FROM bdicobranza: cb_param_campania
    WHERE empresa = pEmpresa
    AND tipo_campania = pTipoCampania
    AND num_parametro = pNumParam
    AND grupo_parametro = pGrupoParam;

    LET iRows = dbinfo("sqlca.sqlerrd2");
    
    IF iRows = 0 THEN
        LET cCodRet = "000002";
        LET cMensajeRet = "NO HAY DATOS CON LOS PARAMETROS RECIBIDOS";
        RETURN cCodRet, cMensajeRet, cValorAlfabetico, dValorNumerico;
    END IF

    RETURN cCodRet, cMensajeRet, cValorAlfabetico, dValorNumerico;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta con información standar para las aplicaciones de Cobranzas', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 201018.0941';

CREATE PROCEDURE "informix".sp_grabarparametroencriptadocobranza (
        pEmpresa CHAR(3),
        pValor CHAR(1),
        pTipo_campania SMALLINT,
        pGrupo_parametro CHAR (10),
        pNumero_parametro INT,
        pDescripcion CHAR (100),        
        pValor_alfabetico CHAR (100),
        pValor_numerico DECIMAL (20),        
        pUsuario CHAR (8))          
        --Bandera (1 para verificar si existe el registro, 2 para guardar el registro, si existe se reemplaza)
        RETURNING CHAR (6) AS COD_RET;
                  
                  
        DEFINE cCod_ret         CHAR (6);
        DEFINE cMensaje         CHAR (80);
        DEFINE cSql_Err         INTEGER;
        DEFINE cEmpresa         CHAR(3);
        DEFINE dFechahoy        DATE;
        
        LET cCod_ret = '';
        LET cMensaje = 'El procedimiento a resultado exitoso.';
        LET cSql_Err = 0;
        LET cEmpresa = '';
        LET dFechahoy = '';
        
        
       -- SET DEBUG FILE TO "/tmp/enrique/sp_GrabarParametroEncriptadoCobranza.out";
        --TRACE ON;
        
        
BEGIN   

	ON EXCEPTION
        SET cSql_Err
        IF cSql_Err <> 0 THEN
            LET cCod_ret = cSql_Err;
        END IF;
        RETURN cCod_ret;
	END EXCEPTION        
        
        IF NVL(pEmpresa,'') = '' OR NVL(pValor,'') = '' OR  NVL(pTipo_campania,0) = '' 
        OR NVL(pGrupo_parametro,'') = '' OR NVL(pNumero_parametro,'') = '' OR NVL(pDescripcion,'') = '' 
        OR NVL(pUsuario,'') = '' THEN
            LET cCod_ret = '000099';
            RETURN cCod_ret;
        END IF
        
        
            --Sacar la fecha de hoy.
            SELECT fecha_hoy
            INTO dFechahoy
            FROM Bdicred:sd_fechas
            WHERE empresa = pEmpresa;
        
        IF  pValor = '1' THEN
           
            SELECT empresa
            INTO cEmpresa
            FROM  bdicobranza: cb_param_campania
            WHERE empresa = pEmpresa AND tipo_campania = pTipo_campania AND grupo_parametro = pGrupo_parametro AND num_parametro = pNumero_parametro;
            
            IF NVL(cEmpresa,'') = ''  THEN
                LET cEmpresa = NVL(cEmpresa,'');
            END IF
            
            --regresa un 1 cundo encuentra registros
            IF pEmpresa = cEmpresa THEN
                LET cCod_ret = '000001';
                RETURN cCod_ret;
            END IF
            --regrasa 2 cuando no encontro registros 
            IF pEmpresa <> cEmpresa THEN
                LET cCod_ret = '000002';
                RETURN cCod_ret;
            END IF
            
        END IF       


        IF pValor = '2' THEN
            
            IF EXISTS (SELECT empresa
                
                FROM bdicobranza: cb_param_campania
                WHERE empresa = pEmpresa
                AND tipo_campania = pTipo_campania
                AND grupo_parametro = pGrupo_parametro
                AND num_parametro = pNumero_parametro) THEN  
                    
                UPDATE bdicobranza: cb_param_campania
                SET descripcion = pDescripcion, 
                valor_alfabetico = pValor_alfabetico, 
                valor_numerico = pValor_numerico, 
                fecha_insert = dFechahoy, 
                user_insert = pUsuario
                WHERE empresa = pEmpresa 
                AND tipo_campania = pTipo_campania 
                AND grupo_parametro = pGrupo_parametro 
                AND num_parametro = pNumero_parametro;                  
               
            ELSE  
            
                INSERT INTO bdicobranza: cb_param_campania
                (empresa, tipo_campania, grupo_parametro, num_parametro, descripcion, valor_alfabetico, valor_numerico, fecha_insert, user_insert)
                VALUES (pEmpresa, pTipo_campania, pGrupo_parametro, pNumero_parametro, pDescripcion, pValor_alfabetico, pValor_numerico, dFechahoy, pUsuario);
                
            END IF
            
            LET cCod_ret = '000003';
            RETURN cCod_ret;
        END IF      

         RETURN cCod_ret;
        
END;
END PROCEDURE
DOCUMENT
'CREACION     : ENRIQUE FRANCISCO LÓPEZ GODOY',
'DESCRIPCION  : ESTE SP ES LLAMADO POR ENCPASS.EXE Y VALIDA SI HAY REGISTROS EN LA TABLA, SI ENCUENTRA REGISTROS LOS ACTUALIZA Y SI NO LOS AGREGA',
'FECHA    	  : AGOSTO 2010',
'VERSION  	  : 20100823.1630';

CREATE PROCEDURE "informix".sp_ejecuta_cat(p_proceso INTEGER, pEmpresa char(3), cfecha_insert DATE, vtipo_cobranza CHAR(1), pSeparador CHAR(1))
                                                            RETURNING char(6), char(150);

DEFINE v_concepto           CHAR(3);
DEFINE vCodRet              CHAR(6);
DEFINE vMensaje             CHAR(150);
DEFINE sql_err              INTEGER;
DEFINE ISAM_ERR             INTEGER;
DEFINE error_info           CHAR(150);
DEFINE ptipo_cobranza       CHAR(1);
DEFINE vvCodRet             CHAR(6);
DEFINE vvMensaje            CHAR(150);

    --SET DEBUG FILE TO "/tmp/sp_ejecuta_monitor.out";
    --TRACE ON; 

    LET vCodRet             =   "11111";
    LET vMensaje            =   "PROCESO INICIALIZADO";
    LET ptipo_cobranza      =   vtipo_cobranza;

BEGIN

    ON EXCEPTION SET Sql_err, isam_err, error_info
        LET vcodret  = sql_err;
        LET vmensaje  = error_info;        
        RETURN vCodRet, vMensaje;
    END EXCEPTION;
  
    IF (p_proceso = 1) THEN
       
        CALL bdicobranza:"informix".sp_cat_gen_info_admin()
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 2) THEN

        CALL bdicobranza:"informix".sp_cat_arch_cartbase(pSeparador)
        RETURNING vvCodRet, vvMensaje;
        
    ELIF (p_proceso = 3) THEN

        CALL bdicobranza:"informix".sp_cat_gen_info_prev()
        RETURNING vvCodRet, vvMensaje;
       
    ELIF (p_proceso = 4) THEN
    
        CALL bdicobranza:"informix".sp_cat_traspasodirectorio_cte(cfecha_insert, vtipo_cobranza)
        RETURNING vvCodRet, vvMensaje;
                
    ELIF (p_proceso = 5) THEN

        CALL bdicobranza:"informix".sp_cat_auronix_target_phone()
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 6) THEN

        CALL bdicobranza:"informix".sp_cat_tipologicacte(pEmpresa, ptipo_cobranza)
        RETURNING vvCodRet, vvMensaje;

    /*ELIF (p_proceso = 7) THEN

        CALL bdimonitorcob:sp_pagos_monto_prom_mes(v_anio, v_mes, p_num_credito, p_origen)
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 8) THEN

        CALL bdimonitorcob:sp_generaconsumo(pMes, pAnio)
        RETURNING vv_codret, vv_mensaje;

    ELIF (p_proceso = 9) THEN

        CALL bdimonitorcob:sp_generacomportamiento(pMess, pAnios, p_num_credito, p_origen)
        RETURNING vv_codret, vv_mensaje;*/

    END IF

    LET vCodRet = '00000';
    LET vMensaje = 'PROCESO EXITOSO';

END

RETURN vCodRet, vMensaje;

END PROCEDURE;