CREATE PROCEDURE "informix".sp_guarda_cons_mov(pEmpresa CHAR(3), pNum_cliente CHAR(9), pId_usuario CHAR(20), pCuenta CHAR(20), pF_inicial CHAR(12), pF_final CHAR(12))
RETURNING CHAR(5) AS cod_ret, CHAR(25) AS folio;

--****************************************************************************************************
-- DESCRIPCION: Guardar la informacion para solicitud de generacion de archivo de movimientos
-- AUTOR : Jose Leon Arellano 
-- FECHA : 08/Julio/2016
-- BD: bdibei
-- FECHA DE LIBERACIÃN: 
--****************************************************************************************************

-- Definicion de variables
    DEFINE vCount INTEGER;
    DEFINE vNumCliente CHAR(9);
    DEFINE vConsecutivo CHAR(7);
    DEFINE vFolio CHAR(25);
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
	LET cod_ret  = '00000';
	
   --set debug file to "/informix/gaby/ArchivosOut/sp_guarda_cons_mov.out";
   --Trace on;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret, '';
      END IF ;
	END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    -- Validar datos de entrada
	IF NVL(pNum_cliente,'')=='' OR NVL(pId_usuario,'')=='' OR NVL(pCuenta,'')=='' OR NVL(pF_inicial,'')=='' OR NVL(pF_final,'')=='' THEN
		LET cod_ret = '00001';
		RETURN cod_ret, '';
	END IF;
    -- Validar que la cuenta esta asignada al nÃºmero de cliente recibido
    SELECT COUNT(cuenta) INTO vCount FROM bdicheq:informix.sc_maechq 
    WHERE num_cte = pNum_cliente AND cuenta = pCuenta;
    IF vCount == 0 THEN
        LET cod_ret = '00002';
        RETURN cod_ret, '';
    END IF;
    -- Validar que el id de usuario este asignado al nÃºmero de cliente recibido
    SELECT num_cliente INTO vNumCliente FROM informix.bei_usuario 
    WHERE id_usuario = pId_usuario;
    IF vNumCliente != pNum_cliente THEN
        LET cod_ret = '00003';
        RETURN cod_ret, '';
    END IF;
    -- Validar que no exista ya una consulta con las mismas fechas de inicio y fin 
    -- y estatus En Proceso.
    IF EXISTS (SELECT status_arch FROM informix.bei_consulta_mov
    WHERE f_inicial = to_date(pF_inicial,'%d/%m/%Y') 
    AND f_final = to_date(pF_final,'%d/%m/%Y')
    AND status_arch ='02') THEN
        LET cod_ret = '00004';
        RETURN cod_ret, '';
    END IF;
    
    -- Generar consecutivo
    --SELECT LPAD(cast(COUNT(num_cliente)+1 as integer),6,0) INTO vConsecutivo
	SELECT LPAD(cast(COUNT(num_cliente)+1 as integer),7,0) INTO vConsecutivo
    FROM informix.bei_consulta_mov
    WHERE num_cliente = pNum_cliente;
    -- Generar folio
    --LET vFolio = TO_CHAR(SYSDATE,'%d%m%Y')||pNum_cliente||vConsecutivo;
	LET vFolio = TO_CHAR(SYSDATE,'%d%m%Y%H%M%S%M')||vConsecutivo;

    -- Guardar la informacion en la tabla de bei_consulta_mov
    INSERT INTO informix.bei_consulta_mov (empresa,num_cliente, id_usuario, cuenta, folio, f_inicial, f_final, status_arch, f_solicitud_arch, h_solicitud_arch)
	VALUES (pEmpresa,pNum_cliente,pId_usuario,pCuenta,vFolio,to_date(pF_inicial,'%d/%m/%Y'),to_date(pF_final,'%d/%m/%Y'),'01',TO_CHAR(SYSDATE,'%d/%m/%Y'),TO_CHAR(SYSDATE,'%H:%M:%S'));

    RETURN cod_ret, vFolio;
END
END PROCEDURE;