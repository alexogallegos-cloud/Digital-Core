CREATE PROCEDURE "informix".sp_valida_montos_definidos_bei(pNumCte CHAR(9),pIdRest CHAR(4),pNum_cta CHAR(20), pMontoCtaPropias DECIMAL(16,2), pMontoMismoBanco DECIMAL(16,2), pMontoSpei DECIMAL(16,2) )
   returning char(5),char(2);

-- Definicion de variables
   Define vCodRet               char(5);
   Define sql_err               integer;
   Define sIdOper				char(20);
   Define dMontoMaximo			decimal(16,2);
   Define dRegistros            Integer;


--- Inicializa Variables de Salida
    Let vCodRet   = "00000";
    Let sIdOper = "00";
    Let dMontoMaximo=0;
    Let dRegistros = 0;
    
	--****************************************************************************************************
	-- DESCRIPCION: Valida los montos
	-- AUTOR: Irving Guzman Salas - SOLSER
	-- FECHA: 
	-- BD: bdibei
	-- SOLICITO:BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	-- MODIFICADO: Se ajusta para el manejo correcto de operacion 03 y 08
	-- MODIFICO:SOLSER
	-- FECHA: 30-ENERO-2015
	--***************************************************************************************************


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet, sIdOper;
      END IF ;
   END EXCEPTION ;

--- Valida que el cliente no sea Blanco
   IF NVL(TRIM(pNumCte),'') = '' THEN
      Let vCodRet = "00001";
       RETURN vCodRet, sIdOper;
   END IF ;
   
   IF NVL(TRIM(pIdRest),'') = '' THEN
      Let vCodRet = "00002";
        RETURN vCodRet, sIdOper;
   END IF ;


    SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;

		
	IF(pIdRest=='01') THEN

        IF NVL(TRIM(pNum_cta),'') = '' THEN
            Let vCodRet = "00003";
             RETURN vCodRet, sIdOper;
        END IF ;
        
        
        FOREACH
            Select distinct catop.id_cat_oper, max(op.monto_max) monto_max
            Into   sIdOper, dMontoMaximo
          	From   "informix".bei_cat_operaciones catop
			Inner Join "informix".bei_menu_oper mop On(catop.id_cat_oper = mop.id_cat_oper)
			Inner Join "informix".bei_operaciones op On(op.id_menu_oper = mop.id_menu_oper)
			Inner Join "informix".bei_usuario_perfil up On(up.id_perfil = op.id_perfil)
			Inner Join "informix".bei_usuario u On(u.id_usuario = up.id_usuario)
			Where  catop.id_cat_padre = 200
			And    op.num_cta = pNum_cta
			And    u.num_cliente=pNumCte
			Group by  catop.id_cat_oper

            Let dRegistros = 1;

           If(sIdOper == 1008 And dMontoMaximo > pMontoCtaPropias And pMontoCtaPropias > 0) Then
				 Let  vCodRet="00005";
                 Let  sIdOper = "08";
			ElIf (sIdOper == 1015 And dMontoMaximo > pMontoSpei And pMontoSpei > 0) Then
				 Let  vCodRet="00005";
                 Let  sIdOper = "03";
			ElIf (sIdOper == 1016 And dMontoMaximo > pMontoMismoBanco And pMontoMismoBanco > 0) Then
			     Let  vCodRet="00005";
                 Let  sIdOper = "05";
			Else 
                 Let  vCodRet="00000";
                 Let  sIdOper = "00";
            End If;
            
            RETURN vCodRet, sIdOper WITH RESUME;
        END FOREACH;

        --No existe un Limite definido en los perfiles por lo tanto debe de permitir 
        If(dRegistros == 0) Then
            Let  vCodRet="00000";
            Let  sIdOper = "00";
            RETURN vCodRet, sIdOper;
        End If;
       

	END IF;
	
	IF(pIdRest=='02') THEN
	
	
	 FOREACH
            Select distinct catop.id_cat_oper, max(op.monto_max)
            Into   sIdOper, dMontoMaximo
			From   "informix".bei_cat_operaciones catop
			Inner Join "informix".bei_menu_oper mop On(catop.id_cat_oper = mop.id_cat_oper)
			Inner Join "informix".bei_operaciones op On(op.id_menu_oper = mop.id_menu_oper)
			Inner Join "informix".bei_usuario_perfil up On(up.id_perfil = op.id_perfil)
			Inner Join "informix".bei_usuario u On(u.id_usuario = up.id_usuario)
			Where  catop.id_cat_padre = 200
			And    u.num_cliente = pNumCte
			Group by  catop.id_cat_oper

            Let dRegistros = 1;

            If(sIdOper == 1008 And dMontoMaximo > pMontoCtaPropias And pMontoCtaPropias > 0) Then
				 Let  vCodRet="00005";
                 Let  sIdOper = "08";
			ElIf (sIdOper == 1015 And dMontoMaximo > pMontoSpei And pMontoSpei > 0) Then
				 Let  vCodRet="00005";
                 Let  sIdOper = "03";
			ElIf (sIdOper == 1016 And dMontoMaximo > pMontoMismoBanco And pMontoMismoBanco > 0) Then
			     Let  vCodRet="00005";
                 Let  sIdOper = "05";
			Else 
                 Let  vCodRet="00000";
                 Let  sIdOper = "00";
            End If;

            
             RETURN vCodRet, sIdOper WITH RESUME;
     END FOREACH;

      If(dRegistros == 0) Then
             Let  vCodRet="00000";
             Let  sIdOper = "00";
            RETURN vCodRet, sIdOper;
      End If;
		
	END IF;

END
END PROCEDURE ;