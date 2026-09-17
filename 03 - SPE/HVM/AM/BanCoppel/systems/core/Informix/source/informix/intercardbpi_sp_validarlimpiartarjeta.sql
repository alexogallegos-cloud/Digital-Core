CREATE PROCEDURE "informix".sp_validarlimpiartarjeta(pcNumTarjetaAnterior CHAR(16),pcNumTarjetaNuevo CHAR(16),pcTipoTarjeta CHAR (1))
RETURNING CHAR(5);
--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
--Asignacion de Variables.
LET cCodRet = "00000";
LET iSqlErr = 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

--- SET DEBUG FILE /INFORMIXDUMP/nombre-spl.trc;
--- TRACE ON; 




	IF pcTipoTarjeta = '1' THEN
	--Validacion para verificar si la tarjeta a asignar no este asignada a otro cliente.
		IF EXISTS(SELECT tardeb.num_tarjeta FROM bdicheq:sc_tarjeta tardeb
				INNER JOIN intercard:tarjeta tar ON tardeb.num_tarjeta = tar.numtarjeta
				INNER JOIN intercard:tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
				WHERE empresa = '001' and tardeb.num_tarjeta = pcNumTarjetaNuevo AND tar.codstatustarjeta = 'ACT') THEN
			LET cCodRet = "00001";
		ELIF EXISTS(SELECT numtarjeta FROM intercard:tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND codstatustarjeta <> 'ACT')THEN
			IF EXISTS(SELECT num_tarjeta FROM bdicheq:sc_tarjeta WHERE empresa = '001' and num_tarjeta = pcNumTarjetaNuevo)THEN
                --Verifica si la tarjeta se des - asigno en inetercard y des-asigna en Cheques
                 IF EXISTS( SELECT numtarjeta FROM intercard:tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND codstatustarjeta='INA' AND codstatusasignada = 'NOA') THEN
                        DELETE FROM bdicheq:sc_tarjeta WHERE empresa = '001'and num_tarjeta = pcNumTarjetaNuevo and prodtarjeta='8000';
                  END IF
                        LET cCodRet = "00002";
			END IF
		END IF
	ELSE
		IF EXISTS(SELECT tarcred.num_tarjeta FROM bdicred:sd_tarjeta tarcred
				INNER JOIN intercard:tarjeta tar ON tarcred.num_tarjeta = tar.numtarjeta
				INNER JOIN intercard:tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
				WHERE empresa = '001' and tarcred.num_tarjeta = pcNumTarjetaNuevo AND tar.codstatustarjeta = 'ACT') THEN
			LET cCodRet = "00001";
		ELIF EXISTS(SELECT numtarjeta FROM intercard:tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND codstatustarjeta <> 'ACT')THEN
			IF EXISTS(SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE empresa = '001' and num_tarjeta = pcNumTarjetaNuevo)THEN
				LET cCodRet = "00002";
			END IF
		END IF
	END IF

	IF cCodRet = "00000" THEN
	--Validacion para verificar si la tarjeta anterior esta completamente cancelada.
		IF EXISTS(SELECT num_tarjeta FROM bdicheq:sc_tarjeta WHERE empresa = '001' and num_tarjeta = pcNumTarjetaAnterior) THEN
			UPDATE bdicheq:sc_tarjeta SET status_tar = 'C' WHERE empresa = '001' and num_tarjeta = pcNumTarjetaAnterior;
		ELIF EXISTS(SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE empresa = '001' and num_tarjeta = pcNumTarjetaAnterior) THEN
			UPDATE bdicred:sd_tarjeta SET status_tar = 'C' WHERE empresa = '001' and num_tarjeta = pcNumTarjetaAnterior;
		END IF

		IF EXISTS(SELECT fechaasignacion FROM intercard:tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND fechaasignacion IS NOT NULL) THEN
			UPDATE intercard:tarjeta
			SET codproductotarjeta = NULL,numcliente = NULL,titular = NULL,nombre = NULL,usuarioultmodif = NULL,
				fechaultmodif = NULL,fechanacimiento = NULL,numtarjetasustituta = NULL,codstatustarjeta = 'INA',
				codstatusasignada = 'NOA',fechaasignacion = NULL
			WHERE numtarjeta = pcNumTarjetaNuevo;

			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pcNumTarjetaNuevo;
		END IF
	END IF
RETURN cCodRet;
END
END PROCEDURE

DOCUMENT
"Especificacion: Valida si la tarjeta este mal asignada, si es asi limpia los datos de la tarjeta",
"                para que se pueda volver a asignar",
"Base de Datos : intercard",
"Autor : Jesus Manuel Perea Heredia",
"Fecha : 19/Nov/2010",
"Descripcion: Valida si la tarjeta a asignar no cuente con una cuenta asignada,",
"asi como tambien que la tarjeta anterior se encuentre correctamente cancelada",
"finalmente valida si la tarjeta este mal asignada, si es asi limpia los datos de la tarjeta para que se pueda volver a asignar",
"Base de Datos : intercard",
"Autor : Marcos Cuevas",
"Fecha : 31/Dic/2010",
"Descripcion: Se elimina validacion debido a que estaba de mas.",
"Base de Datos : intercard",
"Autor : Marcos Cuevas",
"Fecha : 13/Enero/2011",
"Descripcion: Se actualiza a la nueva version de reglas.",
"Base de Datos : intercard",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011";

CREATE PROCEDURE "informix".sp_verifica_cancelacion(p_tarjeta varchar(16)) -- Numero de la tarjeta 
  RETURNING varchar(3) AS Codigo_Respuesta, varchar(100) AS Resultado,varchar(10) AS Usuario_cancela,
            varchar(8) AS Num_Empleado ,varchar(45) AS Nombre,char (3) As Departamento,
			char (30) AS Desc_Departamento,char (4) AS Sucursal_AREA,char (40) AS  Desc_Sucursal_Area,
			DATETIME YEAR TO FRACTION(5) AS Fecha_cancelacion, varchar(8) AS Ultimo_Usuario;

---------------------------------------------------
DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(3);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(100);
DEFINE  w_reg_count                 integer;
DEFINE  v_estatus                   varchar(3);
DEFINE  v_usuario                   varchar (10);
DEFINE  v_usuario2                  varchar (10);

DEFINE r_usuario                    varchar(10);
DEFINE r_empleado                   varchar(8);
DEFINE r_nombre                     varchar(45);
DEFINE r_depa                       char (3);
DEFINE r_desc_depa                  char (30);
DEFINE r_suc                        char (4);
DEFINE r_nomsuc                     char (40);
DEFINE r_fechacanc                  DATETIME YEAR TO FRACTION(5);
DEFINE r_usertarj                   varchar(8);
---------------------------------------------------

 --SET DEBUG FILE TO "/resplogifx/cvtarjeta.out";
 --TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0  THEN
                    LET vcodret = vsqlerr;
                    LET p_mensaje  = error_info;
                    RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 
            END IF;
			
	END EXCEPTION;
---------------------------------------------------

LET r_usuario                 =    '';
LET r_empleado                =    '';
LET r_nombre                  =    '';
LET r_depa                    =    '';
LET r_desc_depa               =    '';
LET r_suc                     =    '';
LET r_nomsuc                  =    '';
LET r_fechacanc               =    '1900-01-01 00:00:00';
LET r_usertarj                =    '';

---------------------------------------------------	
	
	LET w_reg_count = 0;
	SET ISOLATION TO DIRTY READ;
    SELECT  count(*) INTO w_reg_count
    FROM intercard:tarjeta
    WHERE numtarjeta = p_tarjeta;
	
    IF w_reg_count <= 0  THEN
	LET vcodret = '001';
	LET p_mensaje = 'LA TARJETA NO EXISTE';
	RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 
	END IF;
	

	LET v_estatus =  '';
	SET ISOLATION TO DIRTY READ;
	SELECT  codstatustarjeta INTO v_estatus
    FROM intercard:tarjeta
    WHERE numtarjeta = p_tarjeta;
	
	   IF 
	    
		(v_estatus = 'ACT')  THEN
		LET vcodret = '002';
		LET p_mensaje = 'La tarjeta se encuentra ACTIVA';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 	
						
	    elif 
		(v_estatus = 'BLT')  THEN
		LET vcodret = '003';
		LET p_mensaje = 'La tarjeta se encuentra con un BLOQUEO TEMPORAL';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 	
			
        elif 
		(v_estatus = 'DAN')  THEN
		LET vcodret = '004';
		LET p_mensaje = 'La tarjeta se reportó como DAÑADA';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 	

        elif 
		(v_estatus = 'DES')  THEN
		LET vcodret = '005';
		LET p_mensaje = 'La tarjeta fué DESTRUIDA';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 		
		
	    elif 
		(v_estatus = 'EXT')  THEN
		LET vcodret = '006';
		LET p_mensaje = 'La tarjeta se reportó como EXTRAVIADA';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 	 	
			
	    elif 
		(v_estatus = 'FAL')  THEN
		LET vcodret = '007';
		LET p_mensaje = 'La tarjeta se reportó con FALLA POR DETERIORO';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 		
		
        elif 
		(v_estatus = 'INA')  THEN
		LET vcodret = '008';
		LET p_mensaje = 'La tarjeta se encuentra INACTIVA';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 			
			
        elif 
		(v_estatus = 'BLO')  THEN
		LET vcodret = '009';
		LET p_mensaje = 'La tarjeta se encuentra con un BLOQUEO';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 			
			
	    elif 
		(v_estatus = 'ROB')  THEN
		LET vcodret = '010';
		LET p_mensaje = 'La tarjeta se reportó como ROBADA';
		RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 			
								
	 ELSE
	 LET p_mensaje = 'Termina proceso de verificacion de estatus';
						 
	END IF;
	
	
		LET w_reg_count = 0;
	    SET ISOLATION TO DIRTY READ;
        SELECT  count(*) INTO w_reg_count
        FROM intercard:bitacoracambiostarjeta
        WHERE tarjeta = p_tarjeta AND valornuevo = 'CAN';
	
        IF w_reg_count = 0  THEN
	    LET vcodret = '011';
	    LET p_mensaje = 'LA TARJETA NO SE CANCELO CORRECTAMENTE';
	    RETURN vcodret, p_mensaje,'','','','','','','','1900-01-01 00:00:00',''; 
	    END IF;
	

	   LET v_usuario =  '';
	   SELECT usuario INTO  v_usuario
       FROM intercard:bitacoracambiosstatustarjeta
       WHERE tarjeta = p_tarjeta AND codstatustarjetanvo = 'CAN';
	
	   LET v_usuario2 =  '';
	   SELECT usuariocambio INTO  v_usuario2
       FROM intercard:bitacoracambiostarjeta
       WHERE tarjeta = p_tarjeta AND valornuevo = 'CAN';
	
	
	IF   (SUBSTR (v_usuario,1,1) = 'c') THEN  
	
	    SET ISOLATION TO DIRTY READ;
	    SELECT LIMIT 1 bita.usuariocambio AS Usuario,NVL(emp.ejecutivo,'') AS Num_Empleado, NVL(emp.nombre,''),
        NVL(depa.departamento,''),NVL(depa.descripcion,''), NVL(suc.sucursal,''), NVL(suc.nombre,''), MAX(bita.fechacambio)
		INTO r_usuario,r_empleado,r_nombre,r_depa,r_desc_depa,r_suc,r_nomsuc,r_fechacanc
        FROM intercard:bitacoracambiostarjeta AS bita INNER JOIN  intercard:tarjeta as tar  
        ON bita.tarjeta=tar.numtarjeta   
        LEFT JOIN bdinteg:si_ejecut AS emp ON  ((SUBSTR(bita.usuariocambio,2,9)) = (emp.ejecutivo))
        LEFT JOIN bdinteg:si_departamentos AS depa ON  emp.departamento=depa.departamento  
        LEFT JOIN bdinteg:si_sucursales  AS suc ON  emp.sucursal=suc.sucursal  
        WHERE numtarjeta = p_tarjeta AND  bita.valornuevo = 'CAN'  AND tar.codstatustarjeta = 'CAN'
        GROUP BY 1,2,3,4,5,6,7;
		  
	      LET vcodret = '000';
	      LET p_mensaje = 'La Tarjeta esta CANCELADA por el siguiente usuario:';
	      RETURN vcodret, p_mensaje, r_usuario,r_empleado,r_nombre,r_depa,r_desc_depa,r_suc,r_nomsuc,r_fechacanc,r_usertarj;

	
	    ELIF  (SUBSTR (v_usuario,1,1) = '9') THEN 
	     
		  SET ISOLATION TO DIRTY READ;
		  SELECT LIMIT 1 bita.usuario AS Usuario,NVL(emp.ejecutivo,'') AS Num_Empleado, NVL(emp.nombre,''),
          NVL(suc.sucursal,''), NVL(suc.nombre,''), MAX(bita.fechahora)
		  INTO r_usuario,r_empleado,r_nombre,r_suc,r_nomsuc,r_fechacanc
          FROM intercard:bitacoracambiosstatustarjeta AS bita INNER JOIN  intercard:tarjeta as tar  
          ON bita.tarjeta=tar.numtarjeta   
          LEFT JOIN bdinteg:si_ejecut AS emp ON  (bita.usuario = emp.ejecutivo)          
          LEFT JOIN bdinteg:si_sucursales  AS suc ON  emp.sucursal=suc.sucursal  
          WHERE numtarjeta = p_tarjeta AND  bita.codstatustarjetanvo = 'CAN'  AND tar.codstatustarjeta = 'CAN'
          GROUP BY 1,2,3,4,5; 
	
	      LET vcodret = '000';
	      LET p_mensaje = 'La Tarjeta esta CANCELADA por el usuario de SUCURSAL:';
	      RETURN vcodret, p_mensaje, r_usuario,r_empleado,r_nombre,r_depa,r_desc_depa,r_suc,r_nomsuc,r_fechacanc,r_usertarj;
	
	
	    ELIF  (SUBSTR (v_usuario2,1,1) = 'i') OR  (SUBSTR(v_usuario2,1,1) = 'a') OR  (SUBSTR (v_usuario2,1,1) = 'p') THEN 
			
	      SET ISOLATION TO DIRTY READ;
	      SELECT LIMIT 1 tar.usuarioultmodif,NVL(emp.ejecutivo,'') AS Num_Empleado, NVL(emp.nombre,''),
          NVL(suc.sucursal,''), NVL(suc.nombre,''), MAX(bita.fechacambio)
		  INTO  r_usertarj,r_empleado,r_nombre,r_suc,r_nomsuc,r_fechacanc
          FROM intercard:bitacoracambiostarjeta AS bita INNER JOIN  intercard:tarjeta as tar 
          ON bita.tarjeta=tar.numtarjeta 
          LEFT JOIN bdinteg:si_ejecut AS emp ON  
		  ((tar.usuarioultmodif = emp.ejecutivo) OR ((SUBSTR (tar.usuarioultmodif,2,8)) =  (SUBSTR (emp.ejecutivo,1,7))))
          LEFT JOIN bdinteg:si_sucursales  AS suc ON  emp.sucursal=suc.sucursal     
          WHERE numtarjeta = p_tarjeta AND  bita.valornuevo =  'CAN'   AND tar.codstatustarjeta = 'CAN' 
          GROUP BY 1,2,3,4,5;
		  
	      LET vcodret = '000';
	      LET p_mensaje = 'Tarjeta CANCELADA por Usuario de Sistema. Se muestra último usuario que modificó la tarjeta:';
	      RETURN vcodret, p_mensaje, r_usuario,r_empleado,r_nombre,r_depa,r_desc_depa,r_suc,r_nomsuc,r_fechacanc,r_usertarj;

	   
	   ELSE  
	   LET p_mensaje = 'Tarjeta esta CANCELADA, pero no se registró correctamente el Usuario';
	   
	
	END IF;
	
		
		  
END;
END PROCEDURE;