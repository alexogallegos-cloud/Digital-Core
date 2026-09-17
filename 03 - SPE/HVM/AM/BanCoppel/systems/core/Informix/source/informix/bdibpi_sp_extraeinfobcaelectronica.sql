CREATE PROCEDURE "informix".sp_extraeinfobcaelectronica( pAnioMes CHAR(6))

RETURNING CHAR(5) AS CodRet,
		  CHAR(100) AS Mensaje;

--DEFINICIONES
DEFINE iSql_Err                INTEGER;
DEFINE cCodRet         		   CHAR(6);
DEFINE cMensaje                CHAR(50);

DEFINE vid_usuario             INTEGER;
DEFINE vnumcliente             CHAR(9);
DEFINE vf_ultimo_acceso        DATETIME YEAR to SECOND;
DEFINE vst_portal              CHAR(9);

DEFINE vApellidoPater          CHAR(30);
DEFINE vApellidoMater          CHAR(30);
DEFINE vNombre1                CHAR(30);
DEFINE vNombre2                CHAR(30);
DEFINE vNombreCte              CHAR(90);

DEFINE vcodret1                CHAR(5);
DEFINE vTelefono               CHAR(13);
DEFINE vTipoTel                SMALLINT;
DEFINE vSecuencia              SMALLINT;
DEFINE vStatus_Tel             CHAR(1);
DEFINE vExtension              CHAR(5);
DEFINE vCarrier                SMALLINT;
DEFINE vNombreCarrier          CHAR(20);
DEFINE vStatusValidacion       SMALLINT;
DEFINE vTelefonoCasa           CHAR(13);
DEFINE vTelefonoCelular        CHAR(13);
DEFINE vTelefonoTrabajo        CHAR(13);
DEFINE vTelefonoTrabajoExt     CHAR(13);
DEFINE vTelefonoRecados        CHAR(13);

DEFINE vcodret2                CHAR(5);
DEFINE vCorreoElec             CHAR(100);
DEFINE vTipoCorreo             SMALLINT;
DEFINE vStatusCorreo           CHAR(1);

DEFINE vimagen1                CHAR(10);
DEFINE vimagen2                CHAR(10);

DEFINE vf_tmp                  CHAR(8);
DEFINE vf_mes                  CHAR(2);
DEFINE vf_anio                 CHAR(4);
DEFINE vf_ini                  CHAR(10);
DEFINE vf_fin                  CHAR(10);

DEFINE vnum_accesos_portal     INTEGER;
DEFINE vnum_accesos_movil      INTEGER;
DEFINE vnum_transacc_periodo   INTEGER;

DEFINE vsuc_registro           CHAR(4);
DEFINE vservicio               SMALLINT;
DEFINE vservicio2              CHAR(8);
DEFINE vf_unico_reg            DATETIME YEAR to SECOND;
DEFINE vfec_primer_acceso      DATETIME YEAR to SECOND;

DEFINE vParBitacora            CHAR(1);

    --INICIALIZACIONES
	LET vParBitacora        = 'N';
	
    LET iSql_Err           	= 0;
    LET cCodRet           	= '000000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';

    LET vid_usuario         = 0;
    LET vnumcliente         = '';
    LET vf_ultimo_acceso    = CURRENT;
    LET vst_portal          = '';

    LET vApellidoPater      = '';
    LET vApellidoMater      = '';
    LET vNombre1            = '';
    LET vNombre2            = '';
    LET vNombreCte          = '';

    LET vcodret1            = '';
    LET vTelefono           = '';
    LET vTipoTel            = 0;
    LET vSecuencia          = 0;
    LET vStatus_Tel         = '';
    LET vExtension          = '';
    LET vCarrier            = 0;
    LET vNombreCarrier      = '';
    LET vStatusValidacion   = 0;
    LET vTelefonoCasa       = '';
    LET vTelefonoCelular    = '';
    LET vTelefonoTrabajo    = '';
    LET vTelefonoTrabajoExt = '';
    LET vTelefonoRecados    = '';

    LET vcodret2            = '';
    LET vCorreoElec         = '';
    LET vTipoCorreo         = 0;
    LET vStatusCorreo       = '';

    LET vimagen1            = '';
    LET vimagen2            = '';

    LET vf_tmp              = '';
    LET vf_mes              = '';
    LET vf_anio             = '';
    LET vf_ini              = '';
    LET vf_fin              = '';

    LET vnum_accesos_portal = 0;
    LET vnum_accesos_movil  = 0;
    LET vnum_transacc_periodo = 0;

    LET vsuc_registro       = '';
    LET vservicio           = 0;
    LET vservicio2          = '';
    LET vf_unico_reg        = CURRENT;
    LET vfec_primer_acceso  = CURRENT;



	
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = 'ERROR EN LA EJECUCION.';
        RETURN cCodRet, cMensaje;
    END EXCEPTION;

    --SET DEBUG FILE TO "/home/informix/rosa/sp_extraeinfobcaelectronica.out";
   --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	-- Valida el Anio-Mes de ejecucion
	IF TRIM(pAnioMes) = '' THEN
        LET cCodRet = '000104';
        LET cMensaje = 'ERROR. NO HAY PARAMETRO DE EJECUCION.';
        RETURN cCodRet, cMensaje;
	END IF;
	
	LET vf_mes = TRIM(SUBSTRING(pAnioMes FROM 5 FOR 2));
	LET vf_anio = TRIM(SUBSTRING(pAnioMes FROM 1 FOR 4));
	LET vf_tmp = vf_anio || '-' || vf_mes || '-';
    LET vf_ini = vf_tmp || '01';

    IF (vf_mes = '01' OR vf_mes = '03' OR vf_mes = '05' OR
	   vf_mes = '07' OR vf_mes = '08' OR vf_mes = '10' OR vf_mes = '12') THEN
       LET vf_fin = vf_tmp || '31';
	ELSE
       IF vf_mes = '02' THEN
          IF vf_anio = '2016' THEN
             LET vf_fin = vf_tmp || '29';
		  ELSE
             LET vf_fin = vf_tmp || '28';
		  END IF;
	   ELSE
          LET vf_fin = vf_tmp || '30';
	   END IF;
	END IF;
    -- Bitacora de errores para seguimiento
	IF vParBitacora = 'S' THEN
	   INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 1,
	                     'PERIODO: ' ||  vf_ini || ' AL ' || vf_fin,
	                     CURRENT);
	END IF;
	
	 -- Comienza el proceso
    FOREACH
        SELECT id_usuario, numcliente, f_ultimo_acceso, st_portal
		  INTO vid_usuario, vnumcliente, vf_ultimo_acceso, vst_portal
          FROM bdibpi:"informix".bpi_usuario

		-- Nombre del Cliente
	    SELECT TRIM(apell_paterno), TRIM(apell_materno),
		       TRIM(nombre1), TRIM(nombre2)
		INTO vApellidoPater, vApellidoMater, vNombre1, vNombre2
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = vnumcliente;
		LET vNombreCte = TRIM(vNombre1) || ' ' || TRIM(vNombre2) || ' ' || 
		                 TRIM(vApellidoPater) || ' ' || TRIM(vApellidoMater);
        -- Bitacora de errores para seguimiento
	   	IF vParBitacora = 'S' THEN
		    INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 2,
	                     'CLIENTE: ' ||  vnumcliente || ' nombre',
	                     CURRENT);
		END IF;
						 
        -- Obtiene los telefonos
		-- Casa
        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos(
		                                     '001', vnumcliente, 1, '0')
        INTO vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension,
             vCarrier, vNombreCarrier, vStatusValidacion;
		LET vTelefonoCasa = vTelefono;
        -- Bitacora de errores para seguimiento
		IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 3,
	                     'Telefonos: ' ||  vnumcliente || ' casa',
	                     CURRENT);
		END IF;

		-- Celular
        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos(
		                                     '001', vnumcliente, 2, '0')
        INTO vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension,
             vCarrier, vNombreCarrier, vStatusValidacion;
		LET vTelefonoCelular = vTelefono;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 4,
	                     'Telefonos: ' ||  vnumcliente || ' celular',
	                     CURRENT);
		END IF;

		-- Trabajo
        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos(
		                                     '001', vnumcliente, 3, '0')
        INTO vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension,
             vCarrier, vNombreCarrier, vStatusValidacion;
        LET vTelefonoTrabajo = vTelefono;
        LET vTelefonoTrabajoExt = vExtension;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 5,
	                     'Telefonos: ' ||  vnumcliente || ' trabajo',
	                     CURRENT);
		END IF;

		-- Recados
        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos(
		                                     '001', vnumcliente, 4, '0')
        INTO vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension,
             vCarrier, vNombreCarrier, vStatusValidacion;
		LET vTelefonoRecados = vTelefono;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 6,
	                     'Telefonos: ' ||  vnumcliente || ' recados',
	                     CURRENT);
		END IF;

        -- Obtiene el email personal
        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos(
		                                     '001', vnumcliente, 1, '0')
        INTO vcodret2, vCorreoElec, vTipoCorreo, vStatusCorreo;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 7,
	                     'eMail: ' ||  vnumcliente || ' personal',
	                     CURRENT);
		END IF;
		
        -- Obtiene el avatar
		SELECT NVL(imagen, "")
		  INTO vimagen1
          FROM bdibpi:"informix".bpi_avatar
         WHERE num_cte = vnumcliente;
		IF TRIM(vimagen1) = '' THEN
		   LET vimagen2 = 'NO';
		ELSE
		   IF TRIM(SUBSTRING(vimagen1 FROM 1 FOR 6)) = 'avatar' THEN
              LET vimagen2 = 'SI';
           ELSE
              LET vimagen2 = 'NO MIGRADO';
		   END IF;
		END IF;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 8,
	                     'Avatar: ' ||  vnumcliente || ' ',
	                     CURRENT);
		END IF;

        -- Ultimo acceso
		SELECT MAX(fecha_oper)
		  INTO vf_ultimo_acceso
          FROM bdinteg:si_bpibitacora
         WHERE EXTEND(fecha_oper, YEAR TO DAY) BETWEEN vf_ini AND vf_fin
           AND id_usuario = vid_usuario
           AND id_operacion = 1000
         GROUP BY id_usuario;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 9,
	                     'Ultimo acceso: ' ||  vnumcliente || ' ',
	                     CURRENT);
		END IF;

		 -- Numero de accesos Portal
		SELECT COUNT(id_operacion)
		  INTO vnum_accesos_portal
          FROM bdinteg:si_bpibitacora
         WHERE EXTEND(fecha_oper, YEAR TO DAY) BETWEEN vf_ini AND vf_fin
           AND id_usuario = vid_usuario
           AND id_operacion = 1000
		   AND sucursal = '5003'
         GROUP BY id_usuario;
		IF vnum_accesos_portal IS NULL THEN
           LET vnum_accesos_portal = 0;
		END IF;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 10,
	                     'Acceso al portal: ' ||  vnumcliente || ' numero en el periodo',
	                     CURRENT);
		END IF;

        -- Numero de accesos desde el movil
		SELECT COUNT(id_operacion)
		  INTO vnum_accesos_movil
          FROM bdinteg:si_bpibitacora
         WHERE EXTEND(fecha_oper, YEAR TO DAY) BETWEEN vf_ini AND vf_fin
           AND id_usuario = vid_usuario
           AND id_operacion = 1000
		   AND sucursal = '5007'
         GROUP BY id_usuario;
		IF vnum_accesos_movil IS NULL THEN
		    LET vnum_accesos_movil = 0;
		END IF;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 11,
	                     'Acceso desde el movil: ' ||  vnumcliente || ' ',
	                     CURRENT);
		END IF;

        -- Numero de transacciones en el periodo
		SELECT COUNT(id_operacion)
		  INTO vnum_transacc_periodo
          FROM bdinteg:si_bpibitacora
         WHERE EXTEND(fecha_oper, YEAR TO DAY) BETWEEN vf_ini AND vf_fin
           AND id_usuario = vid_usuario
         GROUP BY id_usuario;
		IF vnum_transacc_periodo IS NULL THEN
           LET vnum_transacc_periodo = 0;
		END IF;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 12,
	                     'Transacciones: ' ||  vnumcliente || ' en el periodo',
	                     CURRENT);
		END IF;

        -- Ultimos indicadores
        SELECT suc_registro, servicio, f_unico_reg, fec_primer_acceso
		  INTO vsuc_registro, vservicio, vf_unico_reg, vfec_primer_acceso
          FROM bdinteg:si_bpiusuarios
         WHERE empresa = '001'
           AND numcte = vnumcliente;
        IF vservicio = 1 THEN
		   LET vservicio2 = 'BASICO';
		END IF;
        IF vservicio = 2 THEN
		   LET vservicio2 = 'AVANZADO';
		END IF;
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 13,
	                     'Ultimos indicadores: ' ||  vnumcliente || ' ',
	                     CURRENT);
		END IF;

		-- Inserta el registro
        INSERT INTO bdinteg:"informix".bpi_reporte (mesanio, id_usuario, numcliente,
                                 nombre_cte, suc_registro, e_mail_personal,
	                             tel_casa, tel_celular, tel_trabajo,
	                             tel_extension, tel_recados, st_portal,
                                 f_ultimo_acceso, tiene_avatar, f_contratacion_serv,
	                             fec_primer_acceso, tipo_serv, num_trx_mes,
	                             num_accesos_portal, num_accesos_movil)
                        VALUES (pAnioMes, vid_usuario, vnumcliente,
						        vNombreCte, vsuc_registro, vCorreoElec,
								vTelefonoCasa, vTelefonoCelular, vTelefonoTrabajo,
								vTelefonoTrabajoExt, vTelefonoRecados, vst_portal,
								vf_ultimo_acceso, vimagen2, vf_unico_reg,
								vfec_primer_acceso, vservicio2, vnum_transacc_periodo,
								vnum_accesos_portal, vnum_accesos_movil);
        -- Bitacora de errores para seguimiento
	    IF vParBitacora = 'S' THEN
	        INSERT INTO bdinteg:"informix".bpi_reporte_bit_err ( mesanio, paso,
                         mensaje,
                         f_registro)
                 VALUES (pAnioMes, 14,
	                     'Insercion en reporte: ' ||  vnumcliente || ' ',
	                     CURRENT);
		END IF;

    END FOREACH; 	

END;

	RETURN cCodRet, cMensaje;

END PROCEDURE
DOCUMENT
"DESCRIPCION: Genera archivo con informacion de Clientes con servicio de Banca Electronica.",
"AUTOR:  Alfonso Velazquez Capuleño",
"FECHA DE CREACION: 17 de Agosto del 2013",
"BD: bdibpi";

CREATE PROCEDURE "informix".sp_consulta_solicitud_numcteiccat(pNumCliente CHAR(9))
	RETURNING CHAR(5),CHAR(10),CHAR(10),CHAR(9),CHAR(3),CHAR(30),CHAR(3);
	
	--// ***************************************************************************
	--//FUNCIONALIDAD:   Sp utilizado para consultar la solicitud del cliente para la opcion de entrega de token
	--// Autor: Francisco Rodriguez Ibarra
	--//Fecha:18 Marzo 2010
	
	--03-12-2013
	--Realizo:  Jose Ruben Lopez
	--Se Agrego validacion de para las solicitudes que no tengan estatus 1 o 2
	--Solicito: Jose de Jesus Nevarez
	--BD: bdibpi
	--// ***************************************************************************
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vNumSolicitud	CHAR(10);
	DEFINE vNumSerieToken  	CHAR(9);
	DEFINE vFecSolicitud	CHAR(10);
	DEFINE vNumGuia			CHAR(30);
	DEFINE vNumEnvio		SMALLINT;
	DEFINE vStatusToken       SMALLINT;
	DEFINE vTipoSolicitud  CHAR(1);
	--SET DEBUG FILE TO "/tmp/sp_consulta_solicitud";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumSerieToken = '';
	LET vFecSolicitud = '';
	LET vNumSolicitud = '';
	LET vNumGuia='';
	LET vNumEnvio=0;
	LET vStatusToken = 0;
	LET vTipoSolicitud='';
	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet ,vNumSolicitud,vFecSolicitud , vNumSerieToken,vStatusToken,vNumGuia,vNumEnvio;
	      END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT  TS.solicitud,date(TS.f_solicitud)::char(10),TS.ns_token,TS.tipo,TK.id_status,TE.num_guia,TE.num_envio
		INTO vNumSolicitud,vFecSolicitud,vNumSerieToken,vTipoSolicitud,vStatusToken,vNumGuia,vNumEnvio
		FROM bdibpi:"informix".bpi_tokensolicitud AS ts, bdibpi:"informix".tkn_nseries AS TK, bdibpi:"informix".tkn_envios AS TE
		WHERE  TK.ns_token=TS.ns_token
		AND TE.numcte = TS.numcte
		AND TS.solicitud = (select max(solicitud) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte= pNumCliente)
		AND TE.solicitud = TS.solicitud
        	AND TS.numcte=TRIM(pNumCliente)
        	AND ts.id_status <> '199';
	
		IF (vNumSolicitud IS NULL OR vNumSolicitud='') THEN
			LET vsCodRet='00001';
		ELSE
			IF(vTipoSolicitud <> 1 AND vTipoSolicitud <> 2) THEN
				LET vsCodRet='00004';
			ELIF(vStatusToken<120)THEN
				LET vsCodRet='00002';
			ELIF (vStatusToken>120) THEN
				LET vsCodRet='00003';
			END IF
		END IF
		
		RETURN vsCodRet ,vNumSolicitud,vFecSolicitud , vNumSerieToken,vStatusToken,vNumGuia,vNumEnvio;
	END
END PROCEDURE;