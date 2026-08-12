CREATE PROCEDURE "informix".sp_sac_actualizastatusarch(pcEmpleado CHAR(20), pdFechaArch date)
  
RETURNING char(5),char(90);
  
DEFINE cCodRet char(5); 
DEFINE cDescripcion char(90);
DEFINE cEstatus char(1);
DEFINE cArchivo char (20);
DEFINE iSqlErr integer;
define vsFechaUltimoArchivo date;
  
LET cCodRet = "00000";
LET cDescripcion = " ";
LET cEstatus = " ";
LET cArchivo = " ";
LET iSqlErr = 0;
LET vsFechaUltimoArchivo = current::DATE;
    
	--SET DEBUG FILE TO "/tmp/sp_sac_actualizastatusarch.out";
	--TRACE ON;

BEGIN
ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET cCodRet=iSqlErr;
      RETURN cCodRet,cDescripcion;
   END IF;
END EXCEPTION;

--Valida que el empleado no venga en blanco o nulo  
	IF (pcEmpleado = " ") OR (pcEmpleado IS NULL) THEN
		LET cCodRet = "04001";

                SELECT TRIM (descripcion) INTO cDescripcion
                FROM bdisac:sac_eglobal_mensajes_error 
                WHERE  cod_ret = '04001';
				
		RETURN cCodRet,cDescripcion;           
	END IF;
	
	SELECT FIRST 1 NVL(Fecha_Hoy, CURRENT::DATE) -1 INTO vsFechaUltimoArchivo FROM BdiCheq:Sc_Fechas;
	
--Valida que exista un archivo con la fecha indicada

	IF EXISTS (SELECT nombre_archivo FROM bdisac:sac_eglobal_archivos WHERE fecha_archivo = pdFechaArch) THEN
            
            SELECT nombre_archivo INTO cArchivo FROM bdisac:sac_eglobal_archivos WHERE fecha_archivo = pdFechaArch;

        ELSE
            LET cCodRet = "04002";
            SELECT TRIM (descripcion) INTO cDescripcion
            FROM bdisac:sac_eglobal_mensajes_error 
            WHERE  cod_ret = '04002';

            RETURN cCodRet,cDescripcion;           
	END IF;
	
	
--Valida que el archivo tenga estatus de enviado y sea el ultimo enviado

	IF EXISTS(SELECT estatus
                    FROM bdisac:sac_eglobal_archivos
                    WHERE nombre_archivo = cArchivo 
                    AND fecha_archivo = pdFechaArch 
                    AND estatus = '1')  AND pdFechaArch = vsFechaUltimoArchivo THEN
--				SELECT max(fecha_archivo) 
--				INTO vsFechaUltimoArchivo
--				FROM bdisac:sac_eglobal_archivos WHERE estatus = '1'

                    
                    --Actualiza el estatus del archivo a enviado
	
                    UPDATE bdisac:sac_eglobal_archivos 
                    SET estatus = 0, user_insert = pcEmpleado, fecha_insert= current
                    WHERE nombre_archivo = cArchivo AND fecha_archivo = pdFechaArch;
        ELSE
            
            LET cCodRet = "04003";
            SELECT TRIM (descripcion) INTO cDescripcion
            FROM bdisac:sac_eglobal_mensajes_error 
            WHERE  cod_ret = '04003';

            RETURN cCodRet,cDescripcion; 
        END IF;
	
	
	LET cCodRet = "00000";
	SELECT TRIM (descripcion) INTO cDescripcion
        FROM bdisac:sac_eglobal_mensajes_error 
        WHERE  cod_ret = '00000';

        RETURN cCodRet,cDescripcion;    
	
END

END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: Actualiza el estatus del archivo a NO enviado',
'AUTOR : JGP',
'FECHA : 20/08/2010',
'DESCRIPCIÓN: Actualiza el estatus del archivo a enviado',
'AUTOR : Priscilla Mercado',
'FECHA : 22/03/2010',
'BD: Bdisac',
'SISTEMA : PagoTDCInter', 
'VERSION: 20100316.1000';

CREATE PROCEDURE "informix".sp_consulta_convenio_bpi(pCategoria VARCHAR(2),pConvenio VARCHAR(3))
returning CHAR(5),CHAR(20),CHAR(4),CHAR(4), CHAR(4);
	--***************************************************************************--
	--**	Elaboró: Javier Calderón                                           **--
	--**	Actividad: Obtiene parametros para pago de servicios (DISH y MASTV)**--
	--**	Solicito: Mauricio León						                       **--
	--**	Fecha: 06/12/10								                       **--
	--***************************************************************************--
	DEFINE sql_err			INTEGER;
	DEFINE vCodRet			CHAR(5);
	DEFINE vCtaConv			CHAR(20);
	DEFINE vTransCargo		CHAR(4);
	DEFINE vTransAbono		CHAR(4);
	DEFINE vStatusConv		CHAR(1);
	DEFINE vTransCargoSuc	CHAR(4);

	LET vCodRet				= "00000";
	LET vCtaConv			= "";
	LET vTransCargo			= "";
	LET vTransAbono			= "";
	LET vStatusConv			= "";
	LET vTransCargoSuc		= "";

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet, vCtaConv, vTransCargo, vTransAbono, vTransCargoSuc;
			END IF ;
		END EXCEPTION;


		SELECT cuenta_prestadora, trans_cen_cargo_cliente, trans_cen_abono_convenio, statusconvenio, trans_suc_cargo
		INTO vCtaConv, vTransCargo, vTransAbono, vStatusConv, vTransCargoSuc
		FROM bdisac:sac_convenios
		WHERE numcategoria = pCategoria 
		AND numconvenio = pConvenio;
	
		IF NVL(vStatusConv, '') = '' OR vStatusConv <> 'A' THEN
			LET vCodRet = '00001'; /*00001 = el convenio no está activo*/
		END IF;

		RETURN vCodRet, vCtaConv, vTransCargo, vTransAbono, vTransCargoSuc;
	 END;
END PROCEDURE;