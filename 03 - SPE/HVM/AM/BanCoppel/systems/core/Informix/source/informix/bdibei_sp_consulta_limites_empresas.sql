CREATE PROCEDURE "informix".sp_consulta_limites_empresas(pNum_cliente CHAR(9), pNum_cta CHAR(20), pIdOper CHAR(4),pMonto DECIMAL(16,2))
   returning char(5);

-- Definicion de variables
   Define vCodRet               char(5);
   Define sql_err               integer;
   Define vOpeMaxPesos			DECIMAL(16,2);
   Define vMontoOper			DECIMAL(16,2);
   Define vMontoOperManco			DECIMAL(16,2);
   Define vTotalMontoOper			DECIMAL(16,2);
   Define vIdOper	char(4);    
   Define  vIdOperProg char(4);

--- Inicializa Variables de Salida
    Let vCodRet   = "00000";
	LET vOpeMaxPesos=0;
	LET vMontoOper=0;
	LET vIdOper='';
    LET vIdOperProg='';
	
	
	--****************************************************************************************************
	-- DESCRIPCION: Consulta limites personalisados de las empresas
	-- AUTOR: SOLSER
	-- FECHA: 
	-- BD: bdibei
	-- SOLICITO:BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	-- MODIFICADO: para manejo de SPEI.
	-- MODIFICO: SOLSER
	-- FECHA: 30-ENERO-2015
	--***************************************************************************************************

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet;
      END IF ;
   END EXCEPTION ;

--- Valida que el cliente no sea Blanco
   IF NVL(TRIM(pNum_cliente),"000000000") = "000000000" THEN
      Let vCodRet = "00001";
       RETURN vCodRet;
   END IF ;

   IF NVL(TRIM(pNum_cta),"0") = "0" THEN
      Let vCodRet = "00002";
       RETURN vCodRet;
   END IF 
   
   IF NVL(TRIM(pIdOper),"0") = "0" THEN
      Let vCodRet = "00003";
       RETURN vCodRet;
   END IF ;

	IF NVL(pMonto,0) = 0 THEN
      Let vCodRet = "00004";
       RETURN vCodRet;
   END IF ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		IF(pIdOper=='03')THEN	
			LET vIdOper='1015';
            LET vIdOperProg='2015';
		END IF ;
		IF(pIdOper=='05')THEN	
			LET vIdOper='1016';
		END IF ;
		IF(pIdOper=='08')THEN	
			LET vIdOper='1008';
		END IF ;

        SELECT  tope_max_pesos 
		INTO vOpeMaxPesos
		FROM bdinteg:"informix".si_plimites_empresas 
		WHERE num_cliente =pNum_cliente
		AND id_restriccion='01'
		AND num_cta=pNum_cta
		AND id_operacion =pIdOper;

IF(pIdOper=='03')THEN
        SELECT SUM(monto_oper)  
		INTO vMontoOper
		FROM bdibei:"informix".bei_bitacora 
		WHERE num_cliente=pNum_cliente
		AND cuenta_origen=pNum_cta
		AND (id_operacion=vIdOper OR id_operacion=vIdOperProg ) 
		AND DATE(fecha_oper)= DATE(CURRENT) ;

        
ELSE 
        SELECT SUM(monto_oper)  
		INTO vMontoOper
		FROM bdibei:"informix".bei_bitacora 
		WHERE num_cliente=pNum_cliente
		AND cuenta_origen=pNum_cta
		AND id_operacion=vIdOper  
		AND DATE(fecha_oper)= DATE(CURRENT) ;

END IF;

        SELECT SUM(montototal)  
        INTO vMontoOperManco
		FROM bdibei:"informix".bei_operacionesmancomunadasoperadorresumen 
		WHERE id_cliente=pNum_cliente
		AND cuenta_origen=pNum_cta
		AND id_catoperacion=vIdOper
        AND statusoperacion ='P'  
		AND DATE(f_aplicacion)= DATE(CURRENT) ;


        IF( NVL(vOpeMaxPesos,0)!=0  )THEN
			LET vTotalMontoOper=NVL(vMontoOper,0)+NVL(vMontoOperManco,0)+pMonto;
            
			IF(vTotalMontoOper>vOpeMaxPesos)THEN
				LET vCodRet='00010';
				RETURN vCodRet;
			END IF;
		END IF;

        -----Inicia Validacion por X Opearcion	

		LET vOpeMaxPesos=0.00;
		LET vMontoOper=0.00;
		LET vTotalMontoOper=0.00;
        LET vMontoOperManco=0.00;

		SELECT  tope_max_pesos 
		INTO vOpeMaxPesos
		FROM bdinteg:"informix".si_plimites_empresas 
		WHERE num_cliente =pNum_cliente
		AND id_restriccion='02'
		AND id_operacion =pIdOper;
		
IF(pIdOper=='03')THEN
	SELECT SUM(monto_oper)  
		INTO vMontoOper
		FROM bdibei:"informix".bei_bitacora 
		WHERE num_cliente=pNum_cliente
		AND (id_operacion=vIdOper OR id_operacion=vIdOperProg ) 
		AND DATE(fecha_oper)= DATE(CURRENT) ;

ELSE
		SELECT SUM(monto_oper)  
		INTO vMontoOper
		FROM bdibei:"informix".bei_bitacora 
		WHERE num_cliente=pNum_cliente
		AND id_operacion=vIdOper  
		AND DATE(fecha_oper)= DATE(CURRENT) ;
END IF;

        SELECT SUM(montototal)  
        INTO vMontoOperManco
		FROM bdibei:"informix".bei_operacionesmancomunadasoperadorresumen 
		WHERE id_cliente=pNum_cliente
		AND id_catoperacion=vIdOper
        AND statusoperacion ='P'
		AND DATE(f_aplicacion)= DATE(CURRENT) ;
		
		IF(NVL(vOpeMaxPesos,0)!=0  )THEN
		
			LET vTotalMontoOper=NVL(vMontoOper,0)+NVL(vMontoOperManco,0)+pMonto;
			
			IF(vTotalMontoOper>vOpeMaxPesos)THEN
				LET vCodRet='00020';

				RETURN vCodRet;
			END IF;

		END IF;
		
		RETURN vCodRet;

END
END PROCEDURE ;