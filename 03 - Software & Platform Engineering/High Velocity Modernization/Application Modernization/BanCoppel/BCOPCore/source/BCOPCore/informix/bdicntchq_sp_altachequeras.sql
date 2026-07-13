CREATE PROCEDURE "informix".sp_altachequeras( pempresa CHAR(3),  --Empresa
                                              pcuenta  CHAR(20), -- Cuenta
                                              pcanal   SMALLINT, --Canal 1 NUEVA, 2 CAT , 3  Internet, 4 CENTRAL
                                              ptipo    CHAR(2),  -- Tipo de Chequera
                                              pusuario CHAR(8)   --Usuario
                                            )
       RETURNING     CHAR(5) AS CODRET;   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              sp_altachequeras
   --
   -- Version              1.0.2
   -- Objetivo:            Alta de  chequeras.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- Modificado por:      Alejandro Rueda Sanchez
   -- Ultima Modificacion: Febrero  - 2010
   --
   --                      Reingenieria de SPL
   -- Modificado por: 	   Berenice Noriega
   -- Fecha:			   Febrero - 2013
   -- Modificación:		   Validar si es producto 2200, si es, 
   --                      trae número de cheques para chequera tipo 03	
   --					   y parametros para EmpresaNet.
   --
   -- Modificado por: 	   Berenice Noriega
   -- Fecha:			   Diciembre - 2013
   -- Modificación:		   Validar si es producto 2700, si es, 
   --                      trae número de cheques para chequera tipo 03	
   --					   y parametros para EmpresaNet.
 
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         CHAR(5);
   DEFINE vcodreterr      CHAR(5);
   DEFINE vsqlerr         INTEGER;
   DEFINE vno_cheques     SMALLINT;
   DEFINE vconsec         INTEGER;
   DEFINE v_hoy           DATE;
   DEFINE v_sucursal      CHAR(4);
   DEFINE v_status        CHAR(1);
   DEFINE v_valor         CHAR(1);
   DEFINE v_inicial       INTEGER;
   DEFINE v_final         INTEGER;
   DEFINE a               SMALLINT;
   DEFINE i               SMALLINT;
   DEFINE vnumchq         INTEGER;
   DEFINE vnumactivos     INTEGER;
   DEFINE vmaxpermite     INTEGER;
   DEFINE vdummy          CHAR(100);
   DEFINE vdummy1         CHAR(100);
   DEFINE vfecha       	  DATETIME HOUR TO SECOND;
   DEFINE vfecha1 	      CHAR(8);
   DEFINE vhora           CHAR(10);
   DEFINE vult_chq        INTEGER;
   DEFINE vult_chqcont    INTEGER;
   DEFINE vsdopromant     DECIMAL(12,2);
   DEFINE vsdopromant_parm DECIMAL(12,2);
   DEFINE vfecha_alta 	  DATE;
   DEFINE vfechames  	  DATE;
   DEFINE vproducto  	  CHAR(4);
   DEFINE vval_chequeras  CHAR(1);
   DEFINE vproductoe_parm CHAR(4);
   DEFINE vproductoe_parm2 CHAR(4);


   DEFINE iChqSolic		  	INTEGER;
   DEFINE iCheques_activos  INTEGER;   

   LET vcodret      = " ";
   LET vno_cheques  = " ";
   LET vsqlerr      = 0;
   LET v_status     = " ";
   LET vno_cheques  = 0;
   LET vconsec      = 0;
   LET v_sucursal   = " ";
   LET v_status     = " ";
   LET v_inicial    = 0;
   LET v_final      = 0;
   LET a            = 0;
   LET i            = 0;
   LET v_valor      = " ";
   LET vnumchq      = 0;
   LET vmaxpermite  = 0;
   LET vdummy      = " ";
   LET vdummy1     = " ";
   LET vfecha1     = CURRENT HOUR TO SECOND;
   --LET vfecha1    = vfecha;
   LET vhora       = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);
   LET vsdopromant_parm = 0;
   LET vproducto   = "0000";
   LET vval_chequeras =  "N";
   LET vproductoe_parm = "0000";
   LET vproductoe_parm2 = "0000";

   
   LET iChqSolic		  = 1;
   LET iCheques_activos   = 0;
   LET vult_chqcont		  = 0;	
      
    --SET DEBUG FILE TO "/informix/VH/chequeras/sp_altachequeras.out";
    --TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
       IF vsqlerr <> 0 THEN
          LET vcodret = vsqlerr;
          RETURN vcodret;
       END IF;
    END EXCEPTION;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

   --Validaciones de nulos en parametros de entrada
   IF pempresa = " " OR pcuenta = " " OR pcanal = 0 THEN
      LET vcodret = "001";
      CALL sp_errores( v_hoy, vhora, pcuenta, "001","sp_altachequeras","Error en Parametros de Entrada Nulos",pusuario);
      RETURN vcodret;
   END IF

   --- Selecciona el numero de cheques por tipo de chequera.
   IF ptipo = " " THEN
       SELECT valor INTO ptipo
       FROM sq_param
       WHERE cod_param = 2;
   END IF

   --- Selecciona el numero de cheques por tipo de chequera.
   SELECT valor INTO vmaxpermite
     FROM sq_param
    WHERE cod_param = 3;
  
   --//Selecciona el monto minimo saldo promedio mes anterior
   SELECT valor INTO vsdopromant_parm
     FROM sq_param
    WHERE cod_param = 21;

   --//Selecciona el numero de cheques del tipo de chequera 
   SELECT no_cheques
     INTO vno_cheques
     FROM bdicntchq:sq_chequera
    WHERE chequera = ptipo;

   IF vno_cheques IS NULL  THEN
      LET vcodret = "002";
      CALL sp_errores( v_hoy, vhora, pcuenta, "002","sp_altachequeras","Error al Consultar el Tipo de Chequera",pusuario);
      RETURN vcodret;
   END IF

   --- Selecciona el numero maximo de cheques.
   SELECT MAX(numero)
     INTO vnumchq
     FROM bdicheq:"informix".sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta;

   IF vnumchq IS NULL THEN
      LET vnumchq = 1;
   else
      LET vnumchq =  vnumchq + 1;
   END IF

   --validacion de chequera maxima
   SELECT MAX(consec)
   INTO vconsec
   FROM bdicntchq:sq_maechqra
   WHERE cuenta = pcuenta;

   --Si la chequera es mayor o igual a 1 y el canal es OFI Regreso codigo de error
   IF (vconsec >= 1 AND pcanal = 1) OR (vconsec IS NULL AND pcanal = 2) THEN
      LET vcodret = "004";
      CALL sp_errores( v_hoy, vhora, pcuenta, "004","sp_altachequeras","Error Existen Chequeras Asignadas a esta Cuenta, No Puede Darse de Alta Como Nueva",pusuario);
      RETURN vcodret;
   END IF

   IF vconsec IS NULL THEN
      LET vconsec = 1;
   else
      LET vconsec =  vconsec + 1;
   END IF

   --Se trae el numero de sucursal y producto
   SELECT sucursal, status_cta, producto
     INTO v_sucursal, v_status, vproducto
    FROM bdicheq:"informix".sc_maechq
   WHERE empresa = pempresa
     AND cuenta = pcuenta;

   --Valida el status de la cuenta
   IF v_status <> "1" THEN
      LET vcodret = "005";
      CALL sp_errores( v_hoy, vhora, pcuenta, "005","sp_altachequeras","Error la Cuenta no Esta Activa",pusuario);
      RETURN vcodret;
   END IF

   --//Valida sea un producto de chequeras
   SELECT val_chequeras     
     INTO vval_chequeras
     FROM bdicheq:"informix".sc_producto
    WHERE empresa = pempresa 
      AND producto = vproducto;

   IF vval_chequeras <> "S" THEN
      LET vcodret = "007";
      CALL sp_errores( v_hoy, vhora, pcuenta, "007","sp_altachequeras","Error producto no acepta de chequeras",pusuario);
      RETURN vcodret;
   END IF
   
   -----------------------------------------------------------------------------------------------------------
   --Validar que sea producto de Empresa y traer datos correspondientes.
    SELECT valor INTO vproductoe_parm
     FROM sq_param
    WHERE cod_param = 25;
	
	--trae el otro producto empresarial de chques
	SELECT valor INTO vproductoe_parm2
     FROM sq_param
    WHERE cod_param = 30;
	
	IF (vproducto = vproductoe_parm) OR (vproducto = vproductoe_parm2) THEN
	
	   --- Selecciona el numero de cheques por tipo de chequera.
	   SELECT valor INTO vmaxpermite
		 FROM sq_param
		WHERE cod_param = 27;
	  
	   --//Selecciona el monto minimo saldo promedio mes anterior
	   SELECT valor INTO vsdopromant_parm
		 FROM sq_param
		WHERE cod_param = 28;

	   --//Selecciona el numero de cheques del tipo de chequera 
	   SELECT no_cheques
		 INTO vno_cheques
		 FROM bdicntchq:sq_chequera
		WHERE chequera = 03; -- ptipo-- 
							 
	
	END IF
   -----------------------------------------------------------------------------------------------------------
   

   --Inicia proceso de actualizacion de Datos

   LET v_inicial = vnumchq;
   LET v_final   = vnumchq + vno_cheques -1;

   IF pcanal = 1 THEN --Apertura nueva


      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario, origen)
      VALUES (pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario, pcanal);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:"informix".sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
         
       --/Actualiza el maestro de cheques con el numero de cheques emitidos
       UPDATE bdicheq:"informix".sc_maechq
            SET ult_chq = v_final
          WHERE empresa = pempresa
            AND cuenta = pcuenta;

       LET vcodret = "000";
       RETURN vcodret;
	   
    ELIF pcanal <> 1 THEN

        IF (SELECT COUNT(*) FROM bdicntchq:sq_maechqra WHERE empresa = pempresa AND cuenta = pcuenta AND status IN ('S','P','G','E','N','D')) > 0 THEN
             LET vcodret = "992";
             CALL sp_errores( v_hoy, vhora, pcuenta, "992","sp_altachequeras","Ya existe una chequera en curso",pusuario);
            RETURN vcodret;
        END IF    		
    --//Valida que el saldo promedio mes anterior, sea mayor ó igual al requerido en el parametro 21
      SELECT sdo_prom_mesant, fecha_alta
        INTO vsdopromant, vfecha_alta
        FROM bdicheq:"informix".sc_maenoc
       WHERE empresa = pempresa
         AND cuenta = pcuenta;

      --//Si tiene saldo promedio mayor a 0, no es apertura reciente
      IF vsdopromant > 0 THEN
         IF vsdopromant < vsdopromant_parm THEN 
              LET vcodret = "006";
              CALL sp_errores( v_hoy, vhora, pcuenta, "006","sp_altachequeras","Error el Saldo promedio mes anterior, es menor al necesario", pusuario);
              RETURN vcodret;
         END IF
      ELSE --//Verifica que no sea cuenta reciente para saldo promedio = 0
         EXECUTE PROCEDURE bdicheq:"informix".sp_mes_siguiente(vfecha_alta,1,DAY(vfecha_alta))
         INTO vdummy, vfechames, vdummy;

         IF v_hoy > vfechames THEN
            IF vsdopromant < vsdopromant_parm THEN 
               LET vcodret = "006";
               CALL sp_errores( v_hoy, vhora, pcuenta, "006","sp_altachequeras","Error el Saldo promedio mes anterior, es menor al necesario", pusuario);
               RETURN vcodret;
            END IF
         END IF
      END IF

      --- Validacion de Cheque Activo.
       SELECT COUNT(numero)
         INTO vnumactivos
         FROM bdicheq:"informix".sc_contch
        WHERE cuenta = pcuenta
          AND empresa = pempresa
          AND estado = "A";
		  
	   SELECT chequeras_sol,cheques_activos
	   INTO iChqSolic, iCheques_activos
	   FROM bdicntchq:"informix".sq_ctealtconsumo
	   WHERE cuenta = pcuenta	
	   AND alt_consumo = '1';
	   
	   IF NVL(iCheques_activos,0) <> 0 THEN  --si no entra significa que no es de alto consumo
			IF vnumactivos > iCheques_activos THEN
			   LET vcodret = "003";
			   CALL sp_errores( v_hoy, vhora, pcuenta, "003","sp_altachequeras","Error el Numero de Cheques Activos, Supera los Permitidos",pusuario);
			   RETURN vcodret;
			END IF
	   ELSE
		   IF vnumactivos > vmaxpermite THEN
			   LET vcodret = "003";
			   CALL sp_errores( v_hoy, vhora, pcuenta, "003","sp_altachequeras","Error el Numero de Cheques Activos, Supera los Permitidos",pusuario);
			   RETURN vcodret;
		   END IF
	  END IF;
       
	   
	-- CONSULTAMOS SI EXITE LA CUENTA EN LA TABLA DE ALTA CONSUMO CHEQUERAS.
	   
	
		-- SE INSERTA UN REGISTRO POR CADA CHEQUERA SOLICITADA.
		FOR a = 1 TO NVL(iChqSolic,1)
		   
		   -- VALIDACION DE CHEQUERA MAXIMA
		   INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario, origen)
		   VALUES		 				   (pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",'S', '000', v_sucursal, pusuario, pcanal);
			
			LET v_inicial = v_final + 1;
			
		   -- INSERTA REQUERIMIENTO DE CHEQUERAS
		   FOR i = vnumchq TO v_final
			   
			   INSERT INTO bdicheq:"informix".sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
			   VALUES								   (pempresa, pcuenta, i, "S", v_hoy, 0, vconsec);

		   END FOR
		   
  		   LET vconsec = vconsec + 1;
		   
		   LET vnumchq = v_final + 1;
		   LET v_final = v_final + vno_cheques;
		   
		END FOR
	  LET vult_chqcont= vnumchq - 1;
  
      -- Actualiza el maestro de cuentas de cheques
      LET vult_chq = 0;
      SELECT ult_chq 
        INTO vult_chq
        FROM bdicheq:"informix".sc_maechq
       WHERE empresa = pempresa
         AND cuenta = pcuenta;

      IF vult_chqcont > vult_chq THEN
         UPDATE bdicheq:"informix".sc_maechq
            SET ult_chq = vult_chqcont
          WHERE empresa = pempresa
            AND cuenta = pcuenta;
      END IF


       LET vcodret = "000";
       RETURN vcodret;
   END IF    
END
END PROCEDURE
DOCUMENT
"DESCRIPCION: Agregamos una consulta a la tabla bdicntchq:sq_ctealtconsum para cuando exista el registro en la tabla ",
"             obtengamos el numero de cheques solicitados e insertar un registros por cada cheque en las tablas:  ",
"             bdicntchq:sq_maechqra ,bdicheq:sc_contch. El cambio aplica solamente para el pcanal = 4 CENTRAL ",
"REALIZÓ: Valentin López",
"FECHA: 24/Agosto/2012",
"BD: bdicntchq ",
'VERSION: 20120824.1046';

CREATE PROCEDURE "informix".sp_cambincompleta_solicitarchqra( pempresa char(3),   --Empresa             
                                   pcuenta  char(20),   -- Cuenta                                       
                                   pconsec  integer,    -- Cosecutivo de la chequera                    
                                   pusuario char(8)                                                     
								   )                                    
       returning    char(5),	-- vcodret                                                              
					char(20), 	-- direccion                                    
					integer;   	-- num. chequera                                
                                                                                                        
	-- Realizo   : Javier Humberto Calderon Zazueta                                                 
    -- Actividad : Cambiar estados a incompletos tanto a chequeras como sus cheques y                   
	--			   realizar la solicitud de una nueva chequera para la cuenta           
    -- Solicitó  : Mauricio Leon Ibarra                                                                 
    -- Fecha     : 25/03/2010   
	--	
	-- Modificó  : Berenice Noriega
	-- Fecha	 : 13/02/2013
	-- Actividad : valida si el producto es de empresa para mandar el sp  
	--			   con el parametro correspondiente.
 
	-- Modificado por: 	   Berenice Noriega
	-- Fecha:			   Diciembre - 2013
	-- Modificación:	   Validar si es producto 2700 parametro 30 en el catalogo
	-- 						si lo es manda el parametro correspondiente para la chequera.
 
                                                                                                        
   -- // Definicion de variables                                                                        
   DEFINE vcodret         char(5);                                                                      
   DEFINE vsqlerr         integer;                                                                      
   DEFINE vDireccion	  char(20);                                                                     
   DEFINE vNumChequera    integer;       
   DEFINE vproducto  	  CHAR(4); 
   DEFINE vproductoe_parm CHAR(4);	  
   DEFINE vproductoe_parm2 CHAR(4);	   
   
                                                                                                        
                                                                                                        
   LET vcodret      = '';                                                                               
   LET vsqlerr      = 0;                                                                                
   LET vDireccion   = '';                                                                               
   LET vNumChequera = 0;     
   LET vproducto   = "0000";
   LET vproductoe_parm = "0000";   
   LET vproductoe_parm2 = "0000";   


    --*********************************************
	--SET debug FILE TO "/home/informix/BereniceOut/sp_cambincompleta_solicitarchqra.out";
	--Trace ON;
	--*********************************************                                                                             
   
BEGIN                                                                                                   
    ON EXCEPTION SET vsqlerr                                                                            
       IF vsqlerr <> 0 THEN                                                                             
          LET vcodret = vsqlerr;                                                                        
          RETURN vcodret, vDireccion, vNumChequera;                                                     
       END IF;                                                                                          
    END EXCEPTION;                                                                                      

	--- Actualizacion de Status de Chequera a incompleta                                            
	UPDATE bdicntchq:sq_maechqra                                                                    
	SET status= 'I'                                                                                 
	WHERE empresa = pempresa                                                                        
	AND cuenta = pcuenta                                                                            
	AND consec = pconsec                                                                            
	AND status = 'N';                                                                               
                                                                                                                                                            
	--- Actualizacion de Status de Cheques a incompletos                                            
	UPDATE bdicheq:sc_contch                                                                        
	SET estado= 'I'                                                                                 
	WHERE empresa = pempresa                                                                        
	AND cuenta = pcuenta                                                                            
	AND consec = pconsec                                                                            
	AND estado = 'E';                                     
	                                                                                                
	SELECT desc_tipo_dir                                                                            
	INTO vDireccion                                                                                 
	FROM bdicheq:sc_maechq AS m                                                                     
	INNER JOIN bdinteg:si_cat_tipo_direcciones AS tdr ON m.direcc_envio = tdr.tipo_dir              
	WHERE empresa = pempresa AND cuenta = pcuenta;                                                  
	 
	---------------------------------------------------------------------------------------------------------
	--Se trae el producto de la cuenta
    SELECT producto
    INTO  vproducto
    FROM bdicheq:"informix".sc_maechq
    WHERE empresa = pempresa
    AND cuenta = pcuenta;
	
	--Va por el producto correspondiente a empresas
    SELECT valor INTO vproductoe_parm
     FROM sq_param
    WHERE cod_param = 25;
	
	--Va por el otro producto de empresas de cheques
	SELECT valor INTO vproductoe_parm2
     FROM sq_param
    WHERE cod_param = 30;
	
	--compara si el producto de la cuenta es un producto de empresa
	IF (vproducto = vproductoe_parm) OR  (vproducto = vproductoe_parm2) THEN
		EXECUTE PROCEDURE sp_altachequeras(pempresa, pcuenta, 3, '03', pusuario) INTO vcodret;          
																										
		IF (vcodret = '000') THEN                                                                       
			EXECUTE PROCEDURE sp_obtener_num_chequera(pempresa, pcuenta) INTO vcodret, vNumChequera;
		ELSE                                                                                            
			RETURN vcodret, vDireccion, vNumChequera;                                               
		END IF; 
	
	else 
		EXECUTE PROCEDURE sp_altachequeras(pempresa, pcuenta, 3, '01', pusuario) INTO vcodret;          
																										
		IF (vcodret = '000') THEN                                                                       
			EXECUTE PROCEDURE sp_obtener_num_chequera(pempresa, pcuenta) INTO vcodret, vNumChequera;
		ELSE                                                                                            
			RETURN vcodret, vDireccion, vNumChequera;                                               
		END IF; 
		
	END IF
	 
	---------------------------------------------------------------------------------------------------------
	                                                                                        
	                                                                                                                                                                                                
	LET vcodret = '000';                                                                            
	RETURN vcodret, vDireccion, vNumChequera;                                                       
                                                                                                        
END                                                                                                     
END PROCEDURE;