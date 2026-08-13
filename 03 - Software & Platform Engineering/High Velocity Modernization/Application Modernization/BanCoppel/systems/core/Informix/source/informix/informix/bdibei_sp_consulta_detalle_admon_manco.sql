CREATE PROCEDURE "informix".sp_consulta_detalle_admon_manco(pIdMancomunidad INTEGER,pNum_cliente CHAR(9))
   returning char(5), char(2),char(20),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2);

-- Definicion de variables
   Define vCodRet               char(5);
   Define sql_err               integer;
   Define Monto03			DECIMAL(16,2);
   Define Monto05			DECIMAL(16,2);
   Define Monto08			DECIMAL(16,2);
   Define vIdOper	char(4);
   Define sIdRest  char(2);
   Define sNumCta  char(20);

--- Inicializa Variables de Salida
    Let vCodRet   = "00000";
	LET Monto03=0;
	LET Monto05=0;
	LET Monto08=0;	
	LET vIdOper='';
    LET sIdRest='';
    LET sNumCta ='';
    
	--****************************************************************************************************
	-- DESCRIPCION: Consulta la administración de montos
	-- AUTOR:  SOLSER
	-- FECHA:
	-- BD: bdibei
	-- SOLICITO:BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************
    
    
    
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet,sIdRest,sNumCta,Monto03,Monto05,Monto08;
      END IF ;
   END EXCEPTION ;

--- Valida que el cliente no sea Blanco
   IF NVL(pIdMancomunidad,0) = 0 THEN
      Let vCodRet = "00001";
       RETURN vCodRet,sIdRest,sNumCta,Monto03,Monto05,Monto08;
   END IF ;


    SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
		
    Select MAX(tmp.restricc), MAX(tmp.num_cta),
    MAX(CASE WHEN tmp.operacion = '03' THEN tmp.limite  END) ,
    MAX(CASE WHEN tmp.operacion = '05' THEN tmp.limite END) , 
    MAX(CASE WHEN tmp.operacion = '08' THEN tmp.limite  END) 
    INTO  sIdRest,sNumCta,Monto03,Monto05,Monto08
    From   bdibei:"informix".bei_admin_manco_temp b
    Inner Join bdibei:"informix".bei_admin_manco_montos_temp tmp On(b.id_admin_manco = tmp.id_admin_manco)
    Where  b.tipo_oper = 3
    And    b.num_cliente_admin = pNum_cliente
    And    b.id_admin_manco = pIdMancomunidad;
    
	RETURN vCodRet,NVL(sIdRest,''),NVL(sNumCta,''),NVL(Monto03,0),NVL(Monto05,0),NVL(Monto08,0);

END
END PROCEDURE ;