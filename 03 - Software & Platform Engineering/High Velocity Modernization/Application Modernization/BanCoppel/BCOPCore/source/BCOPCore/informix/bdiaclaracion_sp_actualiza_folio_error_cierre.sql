CREATE PROCEDURE "informix".sp_actualiza_folio_error_cierre(p_pky_aclaracion INTEGER)

	RETURNING
		VARCHAR (3) AS sCodRet, --Salida de codigo de retorno
		VARCHAR(10) AS sfolio_csuac, -- Salida de folio csuac procesado
		INTEGER  AS sPkyaclaracion; -- Clave de Procesamiento del folio

	--Definicion de variables
	DEFINE v_fky_estatus_corp_analisis INTEGER;
	DEFINE v_fky_estatus_corp_general INTEGER;
	DEFINE v_nombre_estatus_corporativo LVARCHAR;
	DEFINE v_folio_csuac VARCHAR(10);

	DEFINE wBegin CHAR(1);

	--SALIDAS DE CODIGO DE ERROR DE SPS DE AFECTACIONES
	DEFINE cCodRet CHAR(3); --OUT CODE ERROR CREDITO
	DEFINE v_CodRet CHAR(3);
	DEFINE iSqlErr INTEGER;

	--VARIABLES DE DICTAMEN
	DEFINE v_observaciones LVARCHAR;
	DEFINE v_procede SMALLINT;
	DEFINE v_cod_resolucion INTEGER;
	DEFINE v_estatus_aclaracion INTEGER;
	DEFINE v_estatus_aclaracion_no_realizado INTEGER;
	DEFINE v_mensaje_error_bitacora LVARCHAR;
	DEFINE v_dias_conclusion INTEGER;
	DEFINE v_importereclamado MONEY;

	--VARIABLES DE CIERRES PREVENTIVOS
	DEFINE v_cierreAutomaticoNoRealizadoAfectacion VARCHAR (50);
	DEFINE v_resolucion INTEGER;


	--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplica_cierre_preventivo"||CURRENT||"_34.out"; --> TRACE DESDE APP
	--SET DEBUG FILE TO "/informix/VJMP/sp_a_34.out";
	--TRACE ON;

	--SET ISOLATION TO DIRTY READ;
	-- SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
            LET v_CodRet = '003';
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN v_CodRet,iSqlErr,p_pky_aclaracion;
        END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET wBegin = "S";
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		LET cCodRet = '000'; -- CODE ERROR AFECTACION EXITO SET

        LET v_cierreAutomaticoNoRealizadoAfectacion = 'cierreAutomaticoNoRealizadoAfectacion';
		LET v_nombre_estatus_corporativo = 'CIERRE_PREVENTIVO_NO_REALIZADO';

        ---seteo de valores para dictamen a cierre preventivo
        LET v_observaciones ='SOLICITUD SI PROCEDE SE BONIFICA LA CANTIDAD CORRESPONDIENTE AL IMPORTE RECLAMADO';
        LET v_procede =NULL;
        LET v_cod_resolucion=NULL; -- Politica Interna
        LET v_estatus_aclaracion_no_realizado = '2';
		LET v_mensaje_error_bitacora = 'Ocurrio un error al realizar el cierre del Folio';
		LET wBegin = 'N';

		--Se obtiene el estatus corporativo a actualizar
		SELECT pky_estatus_corporativo INTO v_fky_estatus_corp_general
			FROM "informix".acl_estatus_corporativo WHERE nombre = v_nombre_estatus_corporativo;


		--Se obtiene la accion para la bitacora
		SELECT pky_resolucion INTO v_resolucion
			FROM "informix".acl_resolucion WHERE nombre = v_cierreAutomaticoNoRealizadoAfectacion;

	--Se Obtienen valores correspondientes a la aclaracion

			SELECT ((today+ 1) - fechacaptura), importereclamado, fky_estatus_corp_analisis, folio_csuac
				INTO v_dias_conclusion, v_importereclamado, v_fky_estatus_corp_analisis, v_folio_csuac
			FROM "informix".acl_aclaracion WHERE pky_aclaracion = p_pky_aclaracion;

		BEGIN WORK;
			UPDATE "informix".acl_aclaracion
				SET fecha_dictamen = NULL,
					montoprocedente=v_importereclamado,
					predictamen=v_observaciones,
					procede=v_procede,
					fky_estatus_aclaracion=v_estatus_aclaracion_no_realizado,
					fky_estatus_corp_general=v_fky_estatus_corp_general,
					fky_tipo_codigo_resolucion=NULL,
					dias_conclusion= NULL
				WHERE pky_aclaracion = p_pky_aclaracion;


			INSERT INTO "informix".acl_entrada_bitacora
				VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
					v_mensaje_error_bitacora, -- descripcion
					CURRENT,                      -- fechaHOra
					v_folio_csuac,                -- folio_csuac
					v_resolucion,                    -- accion/acl_resolucion
					p_pky_aclaracion,             -- pky_aclaracion
					NULL,                     -- fky_area
					v_estatus_aclaracion_no_realizado,        -- fky_estatus_aclaracion
					v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
					v_fky_estatus_corp_general,   -- fky_estatus_corp_general
					'0');
		COMMIT WORK;

		RETURN cCodRet,v_folio_csuac,p_pky_aclaracion;
	END;
END PROCEDURE -- PROCEDURE

DOCUMENT
'Sistema: Aclaraciones',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 27/Abril/2017',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_busqueda_sucursal_parapdf(n_Sucursal CHAR(10))


 RETURNING  CHAR(11) AS numero_sucursal, CHAR(76) AS nombre_sucursal;
 
DEFINE resultado_nombre_sucursal        CHAR(75);
DEFINE resultado_numero_sucursal        CHAR(10);  


BEGIN
      

    SELECT suc.sucursal as numero, suc.nombre as nombre
    INTO resultado_numero_sucursal, resultado_nombre_sucursal

    FROM bdinteg:si_sucursales suc 

    WHERE suc.sucursal = n_Sucursal;                       

    return resultado_numero_sucursal || '*'  , resultado_nombre_sucursal;
END

end procedure;