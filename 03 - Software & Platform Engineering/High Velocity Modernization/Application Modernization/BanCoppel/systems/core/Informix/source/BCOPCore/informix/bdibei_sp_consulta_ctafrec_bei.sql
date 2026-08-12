CREATE PROCEDURE "informix".sp_consulta_ctafrec_bei(
	pNumCte CHAR(20), 
    pCvePago CHAR(2), --SPEI 03 o TERCEROS 02
    pNumCta CHAR(20),
    pCveBanco CHAR(3)
	)
	
RETURNING
     CHAR(6) as cod_ret, ---cod_ret
	 CHAR(20) as cuenta, ---cuenta
	 CHAR(100) as nombre, ---nombre
	 CHAR(50) as banco, ---banco
	 CHAR(2) as compania_cel, ---compania celular
	 CHAR(10) as celular, ---numero celular
	 CHAR(40) as correo_elec, ---correo electronico
	 CHAR(2) as cve_cuenta, ---clave cuenta
     CHAR(20) as desc_cuenta, ---descripcion cuenta
     CHAR(13) as rfc , ---rfc
	 MONEY(16,2) as monto_maximo, ---monto maximo
	 CHAR(1) as cve_caducidad, -- tipo de caducidad
 	 SMALLINT as status_habilitado; -- 1 Habilitado 2 Deshabilitado

 
--##################################################################################################
--##Creo		 : Solser
--##Fecha        : 12/Marzo/2019
--##Descripcion  : Se crea para consulta de cuenta frecuente
--###################################################################################################

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(40);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_CveCaducidad		INTEGER;
	DEFINE v_StatusHabilitado	SMALLINT;
    DEFINE v_descripcion        CHAR(40); 
    DEFINE v_vchrnombrecorto    VARCHAR(20);

	--Set Debug File To '/home/informix/BereniceOut/sp_consulta_ctasfrec_bei.out';
	--Trace On;
 
	LET v_cod_ret  				= '00000';
	LET v_CodDesc			    = "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_CveCaducidad			= "";
	LET v_StatusHabilitado		= 1;
    LET v_descripcion           = ""; 
    LET v_vchrnombrecorto       = "";

	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

		
    --*** VALIDAR DATOS DE ENTRADA ************************************************
    IF (NVL(pNumCte,'')=='' OR NVL(pCvePago,'')=='' OR NVL(pNumCta,'')=='') THEN
        LET v_cod_ret = '00002'; --Parametro requerido es nulo
        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF;
 --*************************************************************************************************
  
	
    SELECT 
        ct2.cuenta, 
        ct2.nombre, 
        ct2.cve_banco, 
        ct2.cve_compania, 
        ct2.no_celular, 
        ct2.direc_correo, 
        ct2.cve_cuenta,
        ct2.descrip_cta, 
        ct2.rfc, 
        ct2.canal_alta, 
        ct2.fecha_insert, 
        ct2.hora_insert, 
        NVL(ct2.monto_maximo,0),
        ct2.cve_caducidad
    INTO 
        v_CtaDestino,
        v_Nombre,
        v_Banco,
        v_CompCel,
        v_NumCel,
        v_CorreoE,
        v_CveCuenta,
        v_DescCta, 
        v_Rfc, 
        v_Canal, 
        v_FechaInsert, 
        v_HoraInsert, 
        v_MontoMaximo, 
        v_CveCaducidad
    FROM (
     SELECT
        ct.cuenta, 
        ct.nombre, 
        ct.cve_banco, 
        ct.cve_compania, 
        ct.no_celular, 
        ct.direc_correo, 
        ct.cve_cuenta,
        ct.descrip_cta, 
        ct.rfc, 
        ct.canal_alta, 
        ct.fecha_insert, 
        ct.hora_insert, 
        ct.monto_maximo,
        ct.cve_caducidad
      FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
        WHERE ct.num_cte = pNumCte
         AND ct.cve_cuenta = cp.cve_cuenta
         AND ct.cve_estado = '01'
         AND cp.cve_pago = pCvePago 
         AND ct.cuenta LIKE CONCAT(pNumCta, '%')
        -- AND ct.cve_banco = pCveBanco
     ) ct2 ;


    -- Si el canal es de internet, distingira entre habilitados y no habilitados (registros que tengan menos de 30 minutos transcurridos despues de su alta)
    IF (v_Canal = '03') OR (v_Canal = '15') THEN
        LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
        IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
            LET v_StatusHabilitado=2; --deshabilitado 
        ELSE 
            LET v_StatusHabilitado=1;  --habilitado
        END IF;
    END IF;


    SELECT descripcion, vchrnombrecorto 
    INTO v_descripcion, v_vchrnombrecorto
    FROM bdinteg:"informix".si_bancos WHERE banco=v_Banco;

    IF (v_vchrnombrecorto is not null) OR (v_descripcion is not null) THEN
        IF TRIM(v_vchrnombrecorto)  = ''  THEN
            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_descripcion);
        ELSE
            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_vchrnombrecorto);
        END IF;
    END IF;

    RETURN v_cod_ret,v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad,v_StatusHabilitado  WITH RESUME;
     
END;

END PROCEDURE;