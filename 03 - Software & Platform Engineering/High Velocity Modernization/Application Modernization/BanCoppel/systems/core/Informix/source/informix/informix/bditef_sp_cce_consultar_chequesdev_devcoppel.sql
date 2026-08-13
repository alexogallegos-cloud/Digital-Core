CREATE PROCEDURE "informix".sp_cce_consultar_chequesdev_devcoppel
(
pEmpresa    CHAR(3),
pFecha      CHAR(10),
cCtaDev		CHAR(20)
)
RETURNING
	CHAR(6) 		AS cod_ret,
    CHAR(3) 		AS banco,
	CHAR(20) 		AS num_cuenta,
	CHAR(7) 		AS num_cheque,
    DECIMAL(16,2) 	AS monto,
	CHAR(20) 		AS cta_deposito,
	CHAR(5) 		AS cod_ret_dev,
    CHAR(2) 		AS motivo,
	CHAR(35) 		AS desc_motivo,
	CHAR(4)			AS sucursal,
	CHAR(40)		AS nom_sucursal

	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
	
    DEFINE cBanco			CHAR(3);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cNumCheque		CHAR(7);
    DEFINE dMonto			DECIMAL(16,2);
	DEFINE cCta_Deposito	CHAR(20);
	DEFINE cCodigoRetDev	CHAR(5);
    DEFINE cMotivo			CHAR(2);
	DEFINE cDescMotivo		CHAR(35);
    DEFINE cSucursal		CHAR(4);
	DEFINE cNomSucursal		CHAR(40);

	

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	
    LET cBanco				= "";
	LET cNumCuenta			= "";
	LET cNumCheque			= "";
    LET dMonto				= 0.0;
	LET cCta_Deposito		= "";
	LET cCodigoRetDev		= "";
    LET cMotivo				= "";
	LET cDescMotivo			= "";
    LET cSucursal			= "";
	LET cNomSucursal		= "";




BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal WITH RESUME;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_chequesdev_devcoppel.out';
--	TRACE ON;



	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" OR  NVL(cCtaDev,"") = "" THEN
        -- FALTA UNO O MAS PARAMETROS
        LET cCodRet = "000001";
        RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal WITH RESUME;
	ELSE
        FOREACH WITH HOLD			
			SELECT c.cvebanco,c.numcuenta,c.numcheque,c.monto,c.cta_deposito,c.codigo_retorno,c.motivo,cdev.descripcion, c.sucursal, s.nombre
			INTO cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal
			FROM bditef:cce_cheques_dev c, bdinteg:si_coddevcam cdev, bdinteg:si_sucursales s
			WHERE c.empresa = pEmpresa
			AND fecha_alta = pFecha
			AND cdev.codigo = c.motivo
			AND c.sucursal = s.sucursal
			AND cta_deposito = cCtaDev
			ORDER BY c.sucursal,c.cvebanco

            RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal WITH RESUME;
        END FOREACH 	
    
	END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que consulta los cheques devueltos de la cce en el aplicativo cce_devcoppel.exe',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_guardar_detalle
(
pNomArchivo			CHAR(22), 		
pTipoRegistro		CHAR(2), 
pNumSecuencia		CHAR(7), 
pCodOperacion		CHAR(2), 
pFechaTransfer		CHAR(8), 
pBancoCedente		CHAR(3), 
pBancoLibrado		CHAR(3), 
pImporte			DECIMAL(19,2), 
pLoteEntrada		CHAR(7), 
pSecEntrada			CHAR(4), 
pLoteSalida			CHAR(7),
pSecSalida			CHAR(4),	 
pCveTrans			CHAR(2),
pPlazaCompensa		CHAR(3),
pNumCuenta			CHAR(13),
pNumCheque			CHAR(10),
pDigInter			CHAR(1),
pDigPremar			CHAR(1),
pCodSegur			CHAR(3),
pUbicFis			CHAR(8),
pTruncam			CHAR(1),
pMotivoDevol		CHAR(2),
pFechapPresIni		CHAR(8),
pPlazaIntercam		CHAR(2),
pRFCBen				CHAR(13),
pCURPBen			CHAR(18),
pTipoCtaDeb			CHAR(2),
pCtaDeb				CHAR(20),
pNombreBen			CHAR(40),
pAlertamiento		CHAR(2),
pFolioSegur			CHAR(12)
)
RETURNING
	CHAR(6) 		AS cod_ret
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_guardar_detalle.out';
--	TRACE ON;

	INSERT INTO 
	bditef:cce_detalle 
	(
	nombrearchivo, tipo_registro, num_bloque, num_secuencia, cod_operacion, fecha_transfer, bco_presenta,
	bco_receptor, importe, lote_entrada, sec_entrada, lote_salida, sec_salida, cve_transacc, plaza_compensa,
	num_cuenta, num_cheque, dig_inter, dig_premar, cod_seguridad, ubicacion_fisica, truncamiento, mot_devol,
	fecha_presini, plaza_inter, rfc_ben, curp_ben, tipo_ctadep, cuenta_dep, nombre_ben, alertamiento, folio_segur
	) 
	VALUES
	(
	pNomArchivo, pTipoRegistro, "00001", pNumSecuencia, pCodOperacion, pFechaTransfer, pBancoCedente, 
	pBancoLibrado, pImporte, pLoteEntrada, pSecEntrada, pLoteSalida, pSecSalida, pCveTrans, pPlazaCompensa, 
	pNumCuenta, pNumCheque, pDigInter, pDigPremar, pCodSegur, pUbicFis, pTruncam, pMotivoDevol, 
	pFechapPresIni, pPlazaIntercam, pRFCBen, pCURPBen, pTipoCtaDeb, pCtaDeb, pNombreBen, pAlertamiento, pFolioSegur
	);
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que guarda datos del detalle para código 40, 46 y 47',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_guardar_encabezado
(
pNomArchivo			CHAR(22),
pTipoRegistro		CHAR(2),
pNumSecuencia		CHAR(7),
pNumBanco			CHAR(3),
pSenntidoTransfer	CHAR(1),
pPlazaCecoban		CHAR(2),
pServicioTEI		CHAR(1),
pDiaMesTransfer		CHAR(2),
pNumBloque			CHAR(5),
pFechaPresenta		CHAR(8),
pTipoArchivo		CHAR(1),
pUsuario			CHAR(8),
pFechaHoy			DATE
) 
RETURNING
	CHAR(6) 		AS cod_ret;
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_guardar_encabezado.out';
--	TRACE ON;

	INSERT INTO bditef:cce_encabezado 
	(
	nombrearchivo, tipo_registro, num_secuencia, num_banco, sentido, plaza_cce, servicio_tei, dia_transferencia, num_bloque,
	fecha_presenta, tipo_archivo, procesado, usuario_alta, fecha_alta
	) 
	VALUES
	(
	pNomArchivo, pTipoRegistro, pNumSecuencia, pNumBanco, pSenntidoTransfer, pPlazaCecoban, pServicioTEI,
	pDiaMesTransfer, pNumBloque, pFechaPresenta, pTipoArchivo, "1", pUsuario, pFechaHoy
	);
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que guarda datos del encabezado para código 40, 46 y 47',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_guardar_gransumario
(
pNumArchivo			CHAR(22), 
pTipoRegistro		CHAR(2), 
pSentido			CHAR(1), 
pCodOperacion		CHAR(2), 
pNumOperaciones		CHAR(7), 
pNumBloques			CHAR(2), 
pNroBanco			CHAR(3), 
pFolio				CHAR(9), 
pFecha				CHAR(8), 
pImporteTotal		DECIMAL(19,2),
pTotRegTruncIMG		CHAR(7)
) 
RETURNING
	CHAR(6) 		AS cod_ret;
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_guardar_gransumario.out';
--	TRACE ON;


	INSERT INTO bditef:cce_gransumario 
	(nombrearchivo, tipo_registro, sentido, cod_operacion, num_operaciones, num_bloques, num_banco, folio,fecha, importe_total, total_reg_ti) 
	VALUES
	(
	pNumArchivo, 
	pTipoRegistro, 
	pSentido, 
	pCodOperacion, 
	pNumOperaciones, 
	pNumBloques, 
	pNroBanco, 
	pFolio, 
	pFecha, 
	pImporteTotal, 
	pTotRegTruncIMG
	);
		
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que guarda datos del gran sumario para código 40, 46 y 47',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_guardar_sumario
(
pNomArchivo 		CHAR(22), 
pTipoRegistro		CHAR(2), 
pNumSecuencia		CHAR(7), 
pCodOperacion		CHAR(2), 
pTotRegs			CHAR(7), 
pImporte			DECIMAL(19,2), 
pTotRegTrunImg		CHAR(7)
) 
RETURNING
	CHAR(6) 		AS cod_ret;
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_guardar_sumario.out';
--	TRACE ON;


	INSERT INTO bditef:cce_sumario 
	(
	nombrearchivo, tipo_registro, num_bloque, num_secuencia, cod_operacion, total_registros, importe, total_reg_trunc)
	VALUES
	(
	pNomArchivo, pTipoRegistro, "00001", pNumSecuencia, pCodOperacion, pTotRegs, pImporte, pTotRegTrunImg
	);

		
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que guarda datos del sumario para código 40, 46 y 47',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

create procedure "informix".cons_dir_cte( pcliente char(20), pnum_regs smallint )
RETURNING char(5), char(30), char(10), char(10), char(6), char(30), char(60), char(30), char(80),
          char(40), char(5), char(13), char(13), char(13), char(10), char(10), char(10);
    
    DEFINE v_codret         char(5);
    DEFINE v_calle		    char(30);
    DEFINE v_numext	    	char(10);
    DEFINE v_numint       	char(10);
    DEFINE v_depto	      	char(6);
    DEFINE v_colonia       	char(30);
    DEFINE v_ciudad	     	char(60);
    DEFINE v_estado	   	    char(30);
    DEFINE v_obs	   	    char(80);   
    DEFINE v_entrecalles   	char(40);   
    DEFINE v_cp	   	        char(5);   
    DEFINE v_tel1   	    char(13);   
    DEFINE v_tel2   	    char(13);   
    DEFINE v_tel3   	    char(13);   
    DEFINE v_ext 	  	    char(10);
    DEFINE v_tpdir 	  	    char(1);
    DEFINE v_tipodir  	    char(10);
    DEFINE v_fechacap  	    char(10);
    DEFINE v_contador       smallint;
    DEFINE sql_err          int;    
    DEFINE isam_err         int;   
    
    LET v_codret = "000";
    LET v_calle  = '  ';
    LET v_numext = '';
    LET v_numint = ' ';
    LET v_depto	 = ' ';
    LET v_colonia = ' ';
    LET v_ciudad = ' ';
    LET v_estado = ' ';
    LET v_obs = ' ';
    LET v_entrecalles = ' ';
    LET v_cp = ' ';
    LET v_tel1 = ' ';
    LET v_tel2 = ' ';
    LET v_tel3 = ' ';
    LET v_ext = ' ';
    LET v_tpdir = ' ';
    LET v_tipodir = ' ';
    LET v_fechacap = ' ';
    LET v_contador = 0;
    LET sql_err = 0;
    LET isam_err = 0;
    
    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, v_obs,
                   v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
        end if;
    end exception;
    
    -- // Valida la informacion de entrada
    IF pcliente is null then
        LET v_codret = 110; 
        RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, v_obs,
               v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // direcciones completas del cliente
    FOREACH
        select cal.nombrecalle as calle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zon.nombrezona as colonia,
               nvl(cds.nombre," ") as cd, edo.nombre as edo, dir.observaciones, dir.entre_calles, dir.cod_postal,
               tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension,
               dir.fecha_insert, decode(dir.tipo_dir, '1', 'Particular', '2', 'Oficina')
          into v_calle, v_numext, v_numint, v_depto, v_colonia,
               v_ciudad, v_estado, v_obs, v_entrecalles, v_cp,
               v_tel1, v_tel2, v_tel3, v_ext,
               v_fechacap, v_tipodir
          from bdinteg:si_direcciones dir
          left outer join bdinteg:si_estados edo on(edo.estado=dir.estado)
          left outer join bdinteg:si_ciudades cds on(cds.ciudad=dir.ciudad and cds.estado = dir.estado and cds.pais = 1)
          left outer join bdinteg:si_catzonas zon on (zon.numerociudad=dir.numerociudad and zon.numerocolonia = dir.numerocolonia)
          left outer join bdinteg:si_catcalles cal on(cal.numerocalle=dir.numerocalle)
          left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = dir.numcte and tel1.tipo_tel = 1)
          left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = dir.numcte and tel2.tipo_tel = 2)
          left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = dir.numcte and tel3.tipo_tel = 3)
         where dir.numcte = pcliente
         order by dir.secuencia 
        
        LET v_contador = v_contador + 1;
        
        IF v_contador < pnum_regs then
            CONTINUE FOREACH;
        END IF;    
        
        RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, v_obs,
               v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir WITH resume;
    END FOREACH		
    
    END; 
    
END PROCEDURE;