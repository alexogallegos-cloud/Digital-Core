CREATE PROCEDURE "informix".sp_limites_empresas_historico(pNum_cliente CHAR(9), pNum_cta CHAR(20), pIdRest CHAR(4), pIdBitacoraAdmin INTEGER)
   returning char(5),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2);

-- Definicion de variables
   Define vCodRet               char(5);
   Define sql_err               integer;
   Define Monto03			DECIMAL(16,2);
   Define Monto05			DECIMAL(16,2);
   Define Monto08			DECIMAL(16,2);
   Define vIdOper	char(4);

--- Inicializa Variables de Salida
    Let vCodRet   = "00000";
	LET Monto03=0;
	LET Monto05=0;
	LET Monto08=0;	
	LET vIdOper='';
	
	--****************************************************************************************************
	-- DESCRIPCION:  Para manejo de los limites de las empresas
	-- AUTOR :  SOLSER
	-- FECHA : 
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************
		
	
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet,Monto03,Monto05,Monto08;
      END IF ;
   END EXCEPTION ;

--- Valida que el cliente no sea Blanco
   IF NVL(pNum_cliente,"000000000") = "000000000" THEN
      Let vCodRet = "00001";
     RETURN vCodRet,Monto03,Monto05,Monto08;
   END IF ;
   
   IF NVL(pIdRest,"0") = "0" THEN
      Let vCodRet = "00002";
       RETURN vCodRet,Monto03,Monto05,Monto08;
   END IF ;


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;

		
	IF(pIdRest='01') THEN

        IF NVL(pNum_cta,"0") = "0" THEN
            Let vCodRet = "00003";
            RETURN vCodRet,Monto03,Monto05,Monto08;
        END IF ;

		SELECT MAX(tope_max_pesos)
		INTO  Monto03
		FROM bdinteg:"informix".si_plimites_empresas_historico 
		WHERE num_cliente =pNum_cliente
        AND num_cta=pNum_cta
		AND id_restriccion=pIdRest
        AND id_bitacora_admin = pIdBitacoraAdmin
		AND id_operacion = '03';
		
		SELECT MAX(tope_max_pesos)
		INTO  Monto05
		FROM bdinteg:"informix".si_plimites_empresas_historico 
		WHERE num_cliente =pNum_cliente
        AND num_cta=pNum_cta
		AND id_restriccion=pIdRest
        AND id_bitacora_admin = pIdBitacoraAdmin
		AND id_operacion = '05';
		
		SELECT MAX(tope_max_pesos)
		INTO  Monto08
		FROM bdinteg:"informix".si_plimites_empresas_historico 
		WHERE num_cliente =pNum_cliente
        AND num_cta=pNum_cta
		AND id_restriccion=pIdRest
        AND id_bitacora_admin = pIdBitacoraAdmin
		AND id_operacion = '08';
	END IF;
	
	
	IF(pIdRest='02') THEN
		SELECT MAX(tope_max_pesos)  
		INTO  Monto03
		FROM bdinteg:"informix".si_plimites_empresas_historico 
		WHERE num_cliente =pNum_cliente
		AND id_restriccion=pIdRest
        AND id_bitacora_admin = pIdBitacoraAdmin
		AND id_operacion = '03' ;
		
	    SELECT MAX(tope_max_pesos)  
		INTO  Monto05
		FROM bdinteg:"informix".si_plimites_empresas_historico 
		WHERE num_cliente =pNum_cliente
		AND id_restriccion=pIdRest
        AND id_bitacora_admin = pIdBitacoraAdmin
		AND id_operacion = '05' ;
		
	    SELECT MAX(tope_max_pesos)  
		INTO  Monto08
		FROM bdinteg:"informix".si_plimites_empresas_historico 
		WHERE num_cliente =pNum_cliente
		AND id_restriccion=pIdRest
        AND id_bitacora_admin = pIdBitacoraAdmin
		AND id_operacion = '08' ;
		
	END IF;


    
	  RETURN vCodRet,NVL(Monto03,0),NVL(Monto05,0),NVL(Monto08,0);

END
END PROCEDURE ;