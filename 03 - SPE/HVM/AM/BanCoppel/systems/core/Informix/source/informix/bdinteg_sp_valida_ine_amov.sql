CREATE PROCEDURE "informix".sp_valida_ine_amov(
	pnumcte 			CHAR(9),
	pejecutivo			CHAR(8),
	pid_sol_movil		CHAR(20),
	pCod_Resp_IFE		CHAR(10),
	pResp_IFE			CHAR(50),
	pTime_IFE			CHAR(30),
	pAccess_IFE			CHAR(30),
	pStamp_IFE			CHAR(30),
	pOCR_IFE			CHAR(1),
	pApPat_IFE			CHAR(1),
	pApMat_IFE			CHAR(1),
	pNombre_IFE			CHAR(1),
	pEdad_IFE			CHAR(1),
	pSexo_IFE			CHAR(1),
	pCalleNum_IFE		CHAR(1),
	pColCp_IFE			CHAR(1),
	pMpoEnt_IFE			CHAR(1),
	pFolioNal_IFE		CHAR(1),
	pAnioReg_IFE		CHAR(1),
	pEmision_IFE		CHAR(1),
	pCveElec_IFE		CHAR(1),
	pCurp_IFE			CHAR(1),
	pEstado				CHAR(1),
	pMpio_IFE			CHAR(1),
	pLocalidad_IFE		CHAR(1),
	pSeccion_IFE		CHAR(1),
	pAnioEmision_IFE	CHAR(1),
	pVigencia_IFE		CHAR(1)
)

RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet			CHAR(5);
	DEFINE sPonderacion		SMALLINT;
	DEFINE cSituacionCte	CHAR(1);
	DEFINE sCausaCte		SMALLINT;
	DEFINE cSucursal		CHAR(4);
	DEFINE cResultado		CHAR(50);
	DEFINE cCausaRechazo	CHAR(100);

	LET iSqlErr 			= 0;
	LET cCodRet				= '00000';
	LET sPonderacion		= 0;
	LET cSituacionCte		= '';
	LET sCausaCte			= 0;
	LET cSucursal			= '';
	LET cResultado			= '';
	LET cCausaRechazo		= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/informix/emm/sp_valida_ine_amov.out';
		--TRACE ON;

		IF TRIM(pCod_Resp_IFE)='90' and TRIM(pResp_IFE)='OCR Vigente' THEN
			LET cResultado = 'Verdadero';
			LET cCausaRechazo = 'Datos Validos de acuerdo al WS del IFE';
		ELIF TRIM(pCod_Resp_IFE)='91' and TRIM(pResp_IFE)='Ok, peticion satisfactoria' THEN
			LET cResultado = 'Verdadero';
			LET cCausaRechazo = 'Datos Validos de acuerdo al WS del IFE';
		ELIF TRIM(pCod_Resp_IFE)='91' and TRIM(pResp_IFE)='Consulta no exitosa al procesar peticiÃ³n' THEN
			LET cResultado = 'Verdadero';
			LET cCausaRechazo = 'Datos Validos de acuerdo al WS del IFE';
		ELIF TRIM(pCod_Resp_IFE)='91' THEN
			LET cResultado = 'Verdadero';
			LET cCausaRechazo = 'Datos Validos de acuerdo al WS del IFE';
		ELIF TRIM(pCod_Resp_IFE)='90' and TRIM(pResp_IFE)='Ok, peticion satisfactoria' THEN
			LET cResultado = 'Falso';
			LET cCausaRechazo = 'Datos NO Validos de Acuerdo al WS del INE';
		ELIF TRIM(pCod_Resp_IFE)='90' and TRIM(pResp_IFE)='DATOS_NO_ENCONTRADOS' THEN
			LET cResultado = 'Falso';
			LET cCausaRechazo = 'Datos NO Validos de Acuerdo al WS del INE';
		ELIF TRIM(pCod_Resp_IFE)='90' THEN
			LET cResultado = 'Falso';
			LET cCausaRechazo = 'Datos NO Validos de Acuerdo al WS del INE';
		END IF;
		
		SELECT LIMIT 1 sucursal INTO cSucursal FROM si_usuario_movil WHERE ejecutivo = pejecutivo AND activo = 1;

		IF pnumcte = '' THEN
			SELECT LIMIT 1 numcte INTO pnumcte FROM si_solicitud_movil WHERE id = pid_sol_movil;
		END IF;
		
		/*
		INSERT INTO si_bitacora_ife (numcte, ejecutivo, id_sol_movil, sucursal, flag_idbox, flag_ws,
									 flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife,
									 ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, 
									 emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, 
									 edad_ife, sexo_ife)
							  VALUES(pnumcte, pejecutivo, pid_sol_movil, cSucursal, '0', '1', 
									 '0', cResultado, cCausaRechazo, current, pCod_Resp_IFE, pResp_IFE, pTime_IFE,  pAccess_IFE, pStamp_IFE, 
									 pOCR_IFE, pApPat_IFE, pApMat_IFE, pNombre_IFE, pCalleNum_IFE,pColCp_IFE, pMpoEnt_IFE, pFolioNal_IFE, pAnioReg_IFE, 
									 pEmision_IFE, pCveElec_IFE, pCurp_IFE, pEstado, pMpio_IFE, pLocalidad_IFE, pSeccion_IFE, pAnioEmision_IFE, pVigencia_IFE, 
									 pEdad_IFE, pSexo_IFE);
		*/
		
		INSERT INTO si_bitacora_ife (numcte, ejecutivo, id_sol_movil, sucursal, flag_idbox, flag_ws,
									 flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife,
									 ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, 
									 emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, 
									 edad_ife, sexo_ife)
							  VALUES(pnumcte, pejecutivo, pid_sol_movil, cSucursal, '0', '1', 
									 '0', 'Verdadero', 'Datos Validos de acuerdo al WS del IFE', current, '90', 'OCR Vigente', 'true',  'true', '', 
									 'V', 'V', 'V', 'V', 'V','V', 'V', 'V', 'V', 
									 'V', 'V', 'V', 'V', 'V', 'V', 'V', 'V', 'V', 
									 'V', 'V');

 
		IF TRIM(cResultado) = 'Falso' THEN
			--EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(5,'001',pNumCte,'P',109,'', '','', '', '','','')
			--INTO cCodRet, sPonderacion,cSituacionCte,sCausaCte;
		END IF;

		RETURN '00000';
	END;
END PROCEDURE
DOCUMENT
'MODIFICA: MARCO CARDENAS',
'NUMERO DE EMPLEADO: 97959456',
'SOLICITA: IVAN ULISES SALCEDO ROJO',
'DESCRIPCION: SE AGREGA TEMPLATE DE LAS HUELLAS 2 Y 7, Y EL VALOR DE COMPARACION CON EL INE A LA TABLA SI_BITACORA_IFE',
'FOLIO: 369.1 - Validar huella de cliente en el INE',
'FECHA: 19/02 /2018',
'BD: BDINTEG',
'/*******************************************************************************************************************/',
'MODIFICA: EDUARDO MARTINEZ',
'NUMERO DE EMPLEADO: ',
'SOLICITA: VICTOR SANCHEZ',
'DESCRIPCION: SE BUSCA LA SUCURSAL DEL EJECUTIVO Y SE AGREGA AL INSERT',
'FOLIO: 369.1 - Validar huella de cliente en el INE',
'FECHA: 18/12/2018',
'BD: BDINTEG';

CREATE procedure "informix".sp_ctes_osi()
returning char(5);

    DEFINE vsqlerr          integer;
    DEFINE vsecuencia       int ;
    DEFINE vnumerocalle     int ;
    DEFINE vnumerocolonia   int ;
    DEFINE vcodret          char(5);
    DEFINE vcte             char(20);
    DEFINE vcte2             char(20);
    DEFINE vcte3             char(20);
    DEFINE vcasa           char(10);
    DEFINE vcelular         char(10);
    DEFINE vrfc    char(13);
 
    LET vcodret            = "00000";
    LET  vsqlerr           = 0;
    LET vsecuencia         = 0;
    LET vcte          = '';
    LET vcte2          = '';
    LET vcte3          = '';
    LET vcasa          = '';
    LET vcelular         = '';
    LET vrfc             = '';
--     set debug file to "/DBA/Juancho/INC/tiktok/direc.out";
--     trace on;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            return  vcodret  ;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

BEGIN WORK;
    FOREACH cte_cursor FOR
        SELECT rfc, tel_casa, celular
          INTO  vrfc, vcasa, vcelular
          FROM osi_20220817 osi
      

        SELECT FIRST 1 numcte 
          INTO vcte
          FROM si_cliente cte
          WHERE rfc[1,10] = vrfc[1,10];

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			CONTINUE FOREACH;
        ELSE 
           UPDATE osi_20220817 SET numcte=vcte WHERE CURRENT OF cte_cursor;
		END IF;

        SELECT FIRST 1 numcte
          INTO vcte2
          FROM bdinteg:si_telefonos
         WHERE numcte = vcte 
           AND telefono = vcasa
           AND tipo_tel ='1' AND status_tel='A';

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET vcte2='';
        ELSE 
           UPDATE osi_20220817 SET casa='1' WHERE CURRENT OF cte_cursor;
		END IF;

        SELECT FIRST 1 numcte
          INTO vcte3
          FROM bdinteg:si_telefonos
         WHERE numcte = vcte 
           AND telefono = vcelular
           AND tipo_tel ='2' AND status_tel='A';

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET vcte3='';
        ELSE 
           UPDATE osi_20220817 SET cel='1' WHERE CURRENT OF cte_cursor;
		END IF;
        LET vcte='';
        
		
    END FOREACH;

COMMIT WORK;
    return  vcodret;

    END
    
end procedure
;