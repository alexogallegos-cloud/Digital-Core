CREATE PROCEDURE "informix".sp_telcargararchivotelefonico (pArchTelefonos CHAR(50))
RETURNING CHAR( 6) AS CodRet,
          CHAR(200) AS Mensaje,
          INTEGER AS contador;
        
-- DECLARACION DE VARIABLES

	DEFINE cSql_Err                 INTEGER;
	DEFINE cCod_ret                 CHAR(  6);
	DEFINE cCod_ret1                 SMALLINT; -- 
	DEFINE cNum_solicitud           CHAR( 12); 
	DEFINE cNumcte                  CHAR(  9);
	DEFINE cStatus_solicitud        CHAR(  2);
	DEFINE cFecha                   CHAR (10); 
	DEFINE cTelefono                CHAR( 10); 
	DEFINE cTipo_telefono           CHAR(  1);
	DEFINE cExtension               CHAR( 10); 
	DEFINE cResultado_gestion       CHAR(  1);
	DEFINE cMensaje                 CHAR( 200);
	DEFINE iExiste                    INTEGER;
	DEFINE iIndicador                 INTEGER;
	DEFINE vSql                     CHAR(200);
	DEFINE cDia                     CHAR (2);
	DEFINE cMes                     CHAR(2);
	DEFINE iAnio                    CHAR(4);
    DEFINE iContador                 INTEGER;
    DEFINE iBandera                  INTEGER;
    DEFINE cStatus                  CHAR (2);
    DEFINE dfechahoy                    DATE;
    DEFINE dPrimerdiames                DATE;
    DEFINE dUltimodiames                DATE;
    DEFINE cRuta                   CHAR(100);
    DEFINE cDir                      CHAR(1);
    DEFINE cExisteSol               CHAR(10);
    DEFINE dFechaAux                DATE;
    
-- INICIALIZACION DE VARIABLES

	LET cSql_Err 			= 0;
	LET cCod_ret 			= '000000';
	LET cCod_ret1 			= '000';
	LET cNum_solicitud 		= '';
	LET cNumcte 			= '';
	LET cStatus_solicitud 	= 'NP';
	LET cFecha 				= '';
	LET cTelefono 			= '';
	LET cTipo_telefono 		= '';
	LET cExtension 			= '';
	LET cResultado_gestion 	= '';
	LET cMensaje 			= 'El Procedimiento se ha ejecutado Exitosamente';
	LET iExiste 			= 0;
	LET iIndicador 			= 0;
	LET vSql 				= '';
	LET cDia 				= '';
	LET cMes 				= '';
	LET iAnio 				= '';
    LET iContador           = 0;
    LET iBandera            = 0;
    LET cStatus             = 'NP';
    LET dfechahoy           = '';
    LET dPrimerdiames       = '';
    LET dUltimodiames       = '';
    LET cRuta               = '';
    LET cDir                = '';
    LET cExisteSol          = '';
    LET dFechaAux           = '';

	--SET DEBUG FILE TO "/dbexportb/vlv/sp_telCargarArchivoTelefonico.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET cSql_Err
		LET  cCod_ret = cSql_Err;
        LET cMensaje = 'Surgio un error imprevisto durante la ejecución del procedimiento';
        
        --Error de que el registro ya fue cargado con esa solicitud
        IF cCod_ret = '-268' THEN
            LET cMensaje = 'El numero solicitud ' ||  cNum_solicitud  || ' ya fue cargado, esta intentando duplicar una llave primaria.';
        END IF;
        --Error de que el archivo no existe en la direccion especificada
        IF cCod_ret = '-668' THEN
            LET cMensaje = 'EL archivo no existe en la direccion. Favor de verificar.';
        END IF;        
        
		RETURN cCod_ret,cMensaje, iContador;
	END EXCEPTION
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
       
        --OBTIENE LA RUTA DE LA BD PARA EL ARCHIVO
       SELECT TRIM(valor_alfabetico)
            INTO cRuta 
            FROM  bdicobranza: cb_param_campania
            WHERE empresa = '001' 
            AND tipo_campania = '11'
            AND grupo_parametro = 'RUTAS'
            AND num_parametro = '1';
        
    
        --Validar parametro de entrada pArchTelefonos
        IF LENGTH(pArchTelefonos) < 5 THEN
            LET cCod_ret = '000023';
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. Error en el nombre del archivo';
            RETURN cCod_ret, cMensaje, iContador;
        END IF;        
        
        -- SE LIMPIA LA TABLA "TEMPORAL" PARA CARGAR ACHIVO NUEVO
        DELETE FROM Bdicobranza:cb_GestionTelefonicaTemp;
						
        -- SE OBTIENE EL ARCHIVO Y SE CARGAR EN TABLA "TEMPORAL" DE TELEFONOS A ACTUALIZAR
        LET vSql = 'echo "LOAD FROM '|| TRIM(cRuta) || '' || TRIM(pArchTelefonos) || ' '
        || 'INSERT INTO cb_GestionTelefonicaTemp" > '|| TRIM(cRuta) ||'ejecuto.sql';
        SYSTEM vSql;
    
        -- SE EJECUTA LA SENTENCIA PARA LA OBTENCION DEL ARCHIVO
        LET vSql = 'dbaccess Bdicobranza '|| TRIM(cRuta) ||'ejecuto.sql';
        SYSTEM vSql;
        
        --Sacar la fecha de hoy.
        SELECT fecha_hoy
            INTO dFechahoy
            FROM Bdicred:sd_fechas
            WHERE empresa = '001';
	
	FOREACH
    
        --SELECCIONA LOS REGISTROS DE LA TABLA TEMPORAL Y LOS METE EN VARIABLES
		SELECT num_solicitud, numcte, status_solicitud, fecha, telefono, tipo_telefono, extension, resultado_gestion
		INTO cNum_solicitud, cNumcte, cStatus_solicitud, cFecha,cTelefono, cTipo_telefono, cExtension, cResultado_gestion
		FROM Bdicobranza:cb_GestionTelefonicaTemp
        
       LET iContador = iContador + 1;

        --ACTUALIZA EL CAMPO ESTATUS SI ES UN REGISTRO DEL MISMO TIPO DE TELEFONO
        IF EXISTS (SELECT numcte
					FROM Bdicobranza:cb_gestion_telefonica
					WHERE numcte = cNumcte
					AND tipo_telefono = cTipo_telefono
					AND status = 'NP') THEN         
					
                    -- iBandera = 2;
            UPDATE Bdicobranza:cb_gestion_telefonica
			SET status = 'CA', fecha_cancelacion = dFechahoy
			WHERE numcte = cNumcte
			AND tipo_telefono = cTipo_telefono
			AND status = 'NP';
           
        END IF;
        
        -- SE VALIDA QUE LOS DATOS DEL ARCHIVO NO VENGAN CON 0
        IF NVL(cNum_solicitud,'0') = '' OR  NVL(cNumcte,'0') = '' THEN 
			
			LET cCod_ret = '000024';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea: ' || iContador || '; ' || ' Campo Con Ceros';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
         
                
      	-- SE VALIDA QUE LOS DATOS DEL ARCHIVO NO VENGAN NULOS
		IF NVL(cNum_solicitud,'') = '' OR  NVL(cNumcte,'') = '' OR NVL(cStatus_solicitud,'') = '' OR NVL(cFecha,'') = '' OR
		   NVL(cTelefono,'') = '' OR NVL(cTipo_telefono,'') = '' THEN 
			
			LET cCod_ret = '000001';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea: ' || iContador || '; ' || ' Campo Vacio';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
         
		-- SE VALIDA QUE EL NUMERO DE SOLICITUD TENGA EL NUMERO DE CARACTERES PERMITIDOS
		IF LENGTH(cNum_solicitud) <> 12 THEN
			LET cCod_ret = '000002';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea: ' || iContador || '; ' || ' Numero de Solicitud';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;

		-- SE EJECUTA FUNCION PARA LA VALIDACION DE NUMEROS EN EL NUMERO DE SOLICITUD
		IF bdiprog:isnumeric(cNum_solicitud) = 0 THEN
			LET cCod_ret = '000003';
			LEt cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Numero de solicitud';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
        
        IF cNum_solicitud::int8 = 0 THEN
			LET cCod_ret = '0000025';
			LEt cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Numero de solicitud';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		 
		-- SE VALIDA QUE EL NUMERO DE CLIENTE TENGA EL NUMERO DE CARACTERES PERMITIDOS
		IF LENGTH(cNumcte) <> 9 THEN
			LET cCod_ret = '000004';                         
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Numero de cliente';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;

		-- SE EJECUTA FUNCION PARA LA VALIDACION DE NUMEROS EN EL NUMERO DE CLIENTE		
		IF Bdiprog:isnumeric(cNumcte) = 0 THEN 
			LET cCod_ret = '000005';
			LEt cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Numero de cliente';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
        
        IF cNumcte::int8 = 0 THEN 
			LET cCod_ret = '000026';
			LEt cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Numero de cliente';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		 
		-- SE VALIDA QUE EL ESTATUS DE LA SOLICITUD TENGA EL NUMERO DE CARACTERES PERMITIDOS
		IF LENGTH(cStatus_solicitud) <> 2 THEN
			LET cCod_ret = '000006';                                
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Estatus de solicitud';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;

		-- SE EJECUTA FUNCION PARA LA VALIDACION DE LETRAS EN EL ESTATUS DE LA SOLICITUD
		IF cStatus_solicitud NOT IN (SELECT status_solicitud FROM bdisolic:ss_status_sol) THEN
			LET cCod_ret = '000007';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Estatus de solicitud';
			RETURN cCod_ret, cMensaje, iContador;
		END IF
		 
         
        LET cMes = substr(cfecha,1,2); 
        if cMes::INT > 12 or cMes::INT < 1 then
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Mes de la fecha';
			LET cCod_ret = '000010';
			RETURN cCod_ret, cMensaje, iContador;
        end if
         
        LET cDia = SUBSTR(cfecha,4,2);
        if cDia::INT > 31 or cDia::INT < 1 then
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Mes de la fecha';
			LET cCod_ret = '000010';
			RETURN cCod_ret, cMensaje, iContador;
        end if    
        
        LET iAnio = SUBSTR(cFecha, 7, 4);
		-- SE VALIDA QUE EL AÑO CUMPLA CON EL VALOR PERMITIDO
		IF iAnio::INT < 2000 OR iAnio::INT > YEAR(dfechahoy)  THEN
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Año de la fecha';
			LET cCod_ret = '000012';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		
		-- SE OBTIENE EL PRIMER DIA Y EL ULTIMO DIA DEL MES
		EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio((cMes),(iAnio))   --day(dFechaCosecha0)
		INTO cCod_ret, dPrimerdiames, dUltimodiames;
					 
		-- SE VALIDA QUE EL RANGO DEL DIA CUMPLA CON LOS VALORES PERMITIDOS
		IF cDia < DAY(dPrimerdiames) OR cDia > DAY(dUltimodiames) THEN
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Dia de la fecha';
			LET cCod_ret = '000008';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		-- SE EJECUTA FUNCION PARA LA VALIDACION DE LETRAS EN EL DIA DE LA FECHA
		IF Bdiprog:isnumeric(cDia) = 0 THEN
			LET cCod_ret = '000009';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Dia de la fecha';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		-- SE VALIDA QUE EL RANGO DEL MES CUMPLA CON LOS VALORES PERMITIDOS
		IF cMes < 0 OR cMes > 12 THEN
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Mes de la fecha';
			LET cCod_ret = '000010';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		-- SE EJECUTA FUNCION PARA LA VALIDACION DE LETRAS EN EL MES
		IF Bdiprog:isnumeric(cMes) = 0 THEN
			LET cCod_ret = '000011';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Mes de la fecha';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		-- SE VALIDA QUE EL AÑO CUMPLA CON EL VALOR PERMITIDO
		IF iAnio < 2000 OR iAnio > YEAR(dfechahoy)  THEN
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Año de la fecha';
			LET cCod_ret = '000012';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;

		-- SE EJECUTA FUNCION PARA LA VALIDACION DE LETRAS EN EL AÑO
		IF Bdiprog:isnumeric(iAnio) = 0 THEN
			LET cCod_ret = '000013';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Año de la fecha';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		-- SE VALIDA QUE EL TELEFONO CUMPLA CON EL VALOR PERMITIDO
		IF LENGTH(cTelefono) <> 10 THEN
			LET cCod_ret = '000014';                       
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Telefono';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
		-- SE EJECUTA FUNCION PARA LA VALIDACION DE LETRAS EN EL AÑO
	    IF Bdiprog:isnumeric(cTelefono) = 0 THEN
			LET cCod_ret = '000015';
			LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Telefono';
			RETURN cCod_ret, cMensaje, iContador;
		END IF;
		
       

        -- SE VALIDA QUE EN EL TIPO TELEFONO NO SE ENCUENTREN LETRAS
        IF cTipo_telefono NOT IN ('C','P','T','I','A') THEN --= 1 THEN
            LET cCod_ret = '000017';
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Tipo telefono';
            RETURN cCod_ret, cMensaje, iContador;
        END IF;

        -- SE VALIDA QUE LA EXTENCION CUMPLA CON EL VALOR PERMITIDO
        IF cExtension < 0  THEN 
            LET cCod_ret = '000018';        
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Extensión';
            RETURN cCod_ret, cMensaje, iContador;
        END IF        
     
        
        IF NVL(cExtension,"") <> "" THEN
        -- SE EJECUTA FUNCION PARA LA VALIDACION DE EXTENSION
        IF Bdiprog:isnumeric(cExtension) = 0 OR LENGTH(cExtension) > 10  THEN -- OR  
            LET cCod_ret = '000019';
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Extensión';
            RETURN cCod_ret, cMensaje, iContador;
        END IF;
        
        END IF
        
        -- SE VALIDA QUE EN EL RESULTADO GESTION NO SE ENCUENTREN LETRAS Y QUE PUEDA ESTAR VACIO O CON CERO
        IF Bdiprog:isnumeric(cResultado_gestion) = 0 THEN
            LET cCod_ret = '000021';
            LET cMensaje = 'El archivo no cumple con las especificaciones para ser cargado. Favor de revisar y corregír. ' || 'Error En Linea ' || iContador || ';' || ' Resultado de gestion';
            RETURN cCod_ret, cMensaje, iContador;
        END IF;
        
        
        LET iBandera = iBandera + 1;
       
    END FOREACH
        
        --VALIDACION PARA CUANDO EL ARCHIVO NO CONTIENE INFORMACION PARA CARGARSE.
        IF iBandera = 0 THEN
            LET cCod_ret = '000022';
            LET cMensaje = 'Archivo no contiene información para cargarse a la base de datos';
        ELSE
            --INSERTA LOS REGISTROS DE LA TABLA TEMPORAL YA VALIDADOS A LA TABLA PRINCIPAL
            INSERT INTO Bdicobranza:cb_gestion_telefonica 
            (num_solicitud,  numcte, secuencia, status_solicitud, fecha_insert, telefono, tipo_telefono, extension, resultado_gestion, status, fecha_ejecucion, fecha_cancelacion)
            SELECT num_solicitud, numcte, '0',  status_solicitud, dfechahoy, telefono, tipo_telefono, extension, resultado_gestion, 'NP','','' 
            FROM Bdicobranza:cb_GestionTelefonicaTemp;     
        END IF  
            
           
            LET vSql = 'rm -rf ' || TRIM(cRuta) ||  TRIM(pArchTelefonos) ;
            SYSTEM vSql;   
          
            RETURN cCod_ret,cMensaje, iContador;
       
END;
END PROCEDURE
DOCUMENT
'CREACION     : ENRIQUE FRANCISCO LÓPEZ GODOY',
'DESCRIPCION  : SE CARGAR EL ARCHIVO DEL SERVIDOR A UNA BASE DE DATOS TEMPORAL Y DE AHI SE VALIDA QUE LOS CAMPOS SEAN CORRECTOS Y SE GUARDA EN LA BASE DE DATOS Bdicobranza:cb_gestion_telefonica.',
'FECHA    	  : AGOSTO 2010',
'VERSION  	  : 20100817.1210';

CREATE PROCEDURE "informix".sp_parametroscobranzas 
(
    pEmpresa CHAR(3),
    pNumEmpleado CHAR(8)
)
RETURNING 
    CHAR(6) AS COD_RET,
    CHAR(2) AS LONG_CTE,
    CHAR(2) AS MON_NACIONAL,
    CHAR(100) AS RUTA_REP,
    CHAR(45) AS NOM_USUARIO,
    CHAR(30) AS NOM_EMPRESA,
    DATE AS FECHA_HOY,
    DATE AS FECHA_ANT,
    DATE AS PROX_FECHA,
    DATE AS PRI_DIA_MES,
    DATE AS PRI_HAB_MES,
    DATE AS ULT_DIA_MES,
    DATE AS ULT_HAB_MES;

	--Declaracion de variables		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(6);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);
	DEFINE dFecha_ant           DATE;
	DEFINE dProx_fecha           DATE;
	DEFINE dPri_dia_mes          DATE;
	DEFINE dPri_hab_mes          DATE;
	DEFINE dUlt_dia_mes          DATE;
	DEFINE dUlt_hab_mes          DATE;

	--SET DEBUG FILE TO "/tmp/hass/sp_ParametrosCobranzas.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet= '000000';
	LET cLongitudCliente= '';
	LET cCodMonNac= '';
	LET cPathRep= '';
	LET cNombreUsuario= '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';
	
	LET dFecha_ant = '';
	LET dProx_fecha = '';
	LET dPri_dia_mes  = '';
	LET dPri_hab_mes  = '';
	LET dUlt_dia_mes ='';
	LET dUlt_hab_mes ='';



BEGIN
    --Crea el control de errores
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,
                   dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    IF (pEmpresa = "" OR pEmpresa IS NULL) OR (pNumEmpleado = "" OR pNumEmpleado IS NULL)THEN
        LET cCodRet = "000001";
        RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,
                dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;
    END IF
        
    --Obtengo el valor longitud del numero de cliente
    SELECT Trim(valor)
    INTO cLongitudCliente 
    FROM bdinteg:si_param 
    WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 

    --Obtengo el valor codigo de la moneda nacional
    SELECT Trim(valor)
    INTO cCodMonNac 
    FROM bdinteg:si_param 
    WHERE empresa = pEmpresa AND descripcion = ('codigo mn');
	
	--Obtengo la ruta de los reportes de cobranza
	--pendiente asignar parametro --c:/cobranza/reportes    

    --Obtengo el nombre del usuario o ejecutivo
    SELECT nombre 
    INTO cNombreUsuario
    FROM bdinteg:si_ejecut
    WHERE ejecutivo = pNumEmpleado;
     
    -- Obtengo el nombre de la empresa
    SELECT razon_social
    INTO cNombreEmpresa
    FROM bdinteg:si_empresas 
    WHERE empresa = pEmpresa;
    
    -- Obtengo Fecha de integral para la Captura de Parametros
    SELECT fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes  
    INTO dFecha_Hoy,dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes
    FROM bdicred:sd_fechas;
    
    RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,
            dFecha_ant,dProx_fecha,dPri_dia_mes,dPri_hab_mes,dUlt_dia_mes,dUlt_hab_mes;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta con información standar para las aplicaciones de Cobranzas', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 20100813.1700';

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