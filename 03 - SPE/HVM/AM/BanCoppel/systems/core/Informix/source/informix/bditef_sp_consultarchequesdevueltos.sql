CREATE PROCEDURE "informix".sp_consultarchequesdevueltos( cNumCte CHAR(9),
                                                          dFechaInicial DATE, 
                                                          dFechaFinal DATE, 
                                                          p_Registros SMALLINT )
--- DATOS A REGRESAR ---
RETURNING CHAR(5) AS CodRet,            --- Codigo de Retorno
          CHAR(2) AS MotivoDevolucion,  --- Motivo Devolucion
          CHAR(35) AS Descripcion,      --- Descripcion
          CHAR(3) AS Empresa,           --- Empresa
          CHAR(3) AS ClaveBanco,        --- Clave Banco
          CHAR(40) AS DescripcionBanco, --- Descripcion Banco
          CHAR(20) AS Cuenta,           --- Cuenta
          CHAR(7) AS NumChq,            --- Numero de Cheque
          DATE AS FechaPresenta,        --- Fecha Presenta
          MONEY(16,2) AS Monto,         --- Monto
          MONEY(16,2) AS MontoAplica,   --- Monto Aplica
          MONEY(16,2) AS SumaComision,  --- Suma Comision
          CHAR(3) AS ImagenFormato,     --- Imagen Formato
          INT AS ImagenTamanoA,         --- Imagen TamaÃ±o A
          INT AS ImagenTamanoB          --- Imagen TamaÃ±o B
    
    -------------------------------------------------------------
    ---                  DOCUMENTACION:                       ---
    ---                                                       ---
    ---  CREADO: Frank Gaxiola Gaxiola                        ---
    ---  FECHA: 22/Agosto/2008                                ---
    ---  OBJETIVO: Regresa los Cheques Devueltos del Cliente  ---
    -------------------------------------------------------------

    --- DEFINICION DE VARIABLES ---
    DEFINE iSqlErr         INT;
    DEFINE cCodRet         CHAR(5);
    DEFINE cMotivoDev      CHAR(2);
    DEFINE cDescriDev      CHAR(35);
    DEFINE cEmpresa        CHAR(3);
    DEFINE cCveBanco       CHAR(3);
    DEFINE cDesBanco       CHAR(40);
    DEFINE cCuenta	       CHAR(20);
    DEFINE cNumCheque 	   CHAR(7);
    DEFINE dFechaDev       DATE;
    DEFINE mComision       MONEY(16,2);
    DEFINE mMontoCom   	   MONEY(16,2);
    DEFINE mIvaCom	       MONEY(16,2);
    DEFINE mSumaCom	  	   MONEY(16,2);
    DEFINE cImgFormato     CHAR(3);
    DEFINE iTamanoImgA 	   INT;
    DEFINE iTamanoImgB 	   INT;
	DEFINE vCliente 	   INT;
    
    --- INICIALIZACION DE VARIABLES ---
    LET iSqlErr 	= 	     0;
    LET cCodRet 	= 	 	'000';
    LET cMotivoDev 	=      	'';
    LET cDescriDev 	=      	'';
    LET cEmpresa 	=      	'';
    LET cCveBanco 	=      	'';
    LET cDesBanco 	=     	'';
    LET cCuenta 	= 		'';
    LET cNumCheque 	= 		'';
    LET dFechaDev 	=      	mdy(1,1,1900);
    LET mComision 	=      	0.00;
    LET mMontoCom 	=    	0.00;
    LET mIvaCom 	=       0.15;
    LET mSumaCom 	=    	0.00;
    LET cImgFormato =    	'';
    LET iTamanoImgA =  		0;
    LET iTamanoImgB =  		0;
	LET vCliente    =  		0;

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_ConsultarChequesDevueltos.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Pregunto si existe un cliente con cheques en un rango de fechas determinado 
	
	LET vCliente = (SELECT count(1) FROM bditef:"informix".cce_cheques_dev WHERE empresa = '001'
                  AND (cvebanco is not null OR cvebanco <> '')
                  AND (numcuenta is not null OR numcuenta <> '')
                  AND (numcheque is not null OR numcheque <> '')
                  AND fechapresenta BETWEEN dFechaInicial AND dFechaFinal
                  AND numcte = cNumCte);
    --IF EXISTS( SELECT 1 FROM bditef:"informix".cce_cheques_dev WHERE empresa = '001' AND (cvebanco is not null OR cvebanco <> '')
                  --AND (numcuenta is not null OR numcuenta <> '') AND (numcheque is not null OR numcheque <> '') AND fechapresenta BETWEEN dFechaInicial AND dFechaFinal AND numcte = cNumCte ) THEN
	IF (vCliente > 0) THEN 			  
                  
        -- // Empieza el ciclo donde saca los cheques que tenga el cliente
        FOREACH  -- // Se seleccionan los cheques devueltos del cliente
            SELECT { +INDEX(bditef:"informix".cce_cheques_dev idx_numcte_fp) 
					 +INDEX(bditef:"informix".cce_cheques_dev idx_chqdev),
                     +INDEX(bditef:"informix".cce_cheques_det idx_chqdet),
                     +INDEX(bditef:"informix".cce_cheques_img idx_cce_cheques_img),
                     +INDEX(bdicheq:"informix".sc_comisiones idx_comision1),
                     +INDEX(bdinteg:"informix".si_bancos idx_banco) 
					 +INDEX(bdinteg:"informix".si_coddevcam 109_29)}
                   SKIP p_Registros chedev.motivo, coddev.descripcion, chedev.empresa, chedev.cvebanco,  bancos.descripcion,
                   cheimgA.numcuenta, cheimgA.numcheque, cheimgA.fechapresenta, chedev.monto,
                   totcom.monto_aplica, cheimgA.imagen_formato, cheimgA.imagen_tam as tamano_a,
                   cheimgB.imagen_tam as tamano_b
              INTO cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision,
                   mMontoCom, cImgFormato, iTamanoImgA, iTamanoImgB
              FROM bditef:"informix".cce_cheques_dev chedev, 
                   bditef:"informix".cce_cheques_det chedet, 
             OUTER bdinteg:"informix".si_coddevcam coddev,
                   bditef:"informix".cce_cheques_img cheimgA, 
                   bditef:"informix".cce_cheques_img cheimgB, 
                   bdicheq:"informix".sc_comisiones totcom,
             OUTER bdinteg:"informix".si_bancos bancos
             WHERE chedev.numcte = cNumCte
               AND chedev.empresa = chedet.empresa
               AND chedev.empresa = cheimgA.empresa
               AND chedev.empresa = cheimgB.empresa 
               AND totcom.empresa = chedev.empresa               
			   AND chedev.cvebanco = bancos.banco 
               AND chedev.cvebanco = cheimgA.cvebanco
			   AND chedev.cvebanco = cheimgB.cvebanco
			   AND chedev.numcuenta = chedet.numcuenta
			   AND (chedev.numcuenta = cheimgA.numcuenta AND cheimgA.lado_ft = 'A')
			   AND (chedev.numcuenta = cheimgB.numcuenta AND cheimgB.lado_ft = 'B')
			   AND chedev.numcheque = chedet.numcheque
               AND chedev.numcheque = cheimgA.numcheque
			   AND chedev.numcheque = cheimgB.numcheque
			   AND chedev.fechapresenta = chedet.fechapresenta
               AND chedev.fechapresenta = cheimgA.fechapresenta                     
               AND chedev.fechapresenta = cheimgB.fechapresenta
               AND chedev.fechapresenta BETWEEN dFechaInicial AND dFechaFinal        
			   AND totcom.comision = '0232'
               AND cheimgA.imagen_formato = 'jpg'
               AND (coddev.sistema_rel is not null OR coddev.sistema_rel <> '')
               AND (coddev.cod_ret_rel is not null OR coddev.cod_ret_rel <> '')
			   AND chedev.motivo = coddev.codigo
             ORDER BY cheimgA.numcheque, cheimgA.lado_ft

            LET mSumaCom = mComision + mMontoCom + (mMontoCom * mIvaCom);
            
            -- // Regresa los registros de cheques encontrados
            RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB WITH RESUME;
        END FOREACH;

    ELSE
        LET cCodRet = '001';  -- // No existen cheques en la fechas solicitadas.
		LET dFechaDev = '';
        RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB WITH RESUME;
    END IF;

    END;

END PROCEDURE

DOCUMENT
'AUTOR : JosÃ© Ãngel RodrÃ­guez',
'MODIFICACION: Se modifica para que puede consultar a un cliente por un rango de fechas',
'			   y si no se tiene un rango de fechas que lo pueda consultar por el numero del cliente como se ha estado realizando',
'EQUIPO DE TRABAJO: Incidencias',
'EJECUTADO O LLAMADO POR: SUCHEDEV.EXE Y ITCHEDEV.EXE',
'FECHA : 11/NOV/2009',
'VERSION: 20091111.1636',
'BD    : bditef',
'MODIFICACION: Se Agrega un parametro de entrada para controlar la paginacion',
'MODIFICÃ: Valentina Aguilar',
'FECHA : 25/11/NOV/2009',
'VERSION: 20091125.1648',
'MODIFICÃ: Valentin Lopez',
'DESCRIPCIÃ³N: Se agrega una nueva condicion para que solamente consulte los formatos de archivos ".jpg" ',
'FECHA : 19/JUL/2011',
'VERSION: 20110719.1030',
'BD    : bditef';

CREATE PROCEDURE "informix".ins_img_det_web(
                       pempresa         CHAR(3),
                       pcvebanco   	    CHAR(3),
                       pnumcuenta   	CHAR(20),
                       pnumcheque   	CHAR(7),
                       plado_ft         CHAR(1),
                       pfechapresenta   CHAR(10),
                       pimagen_formato 	CHAR(3),
                       pimagen_tam	    INTEGER, 
                       puser_insert     CHAR(8),
                       pfecha_insert    CHAR(10))
					   
	RETURNING CHAR(5);  

	DEFINE v_codret CHAR(5);
	DEFINE sql_err,isam_err INT;   
	DEFINE v_existe CHAR(1);
	DEFINE v_fechapre CHAR(10);						  
   
	--set debug file to "/tmp/ins_img_det.out";
	--trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "00000";
   LET v_existe    = "0";
   

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  pempresa    	is null or
		pcvebanco       is null or
		pnumcuenta      is null or
		pnumcheque      is null or
        plado_ft        is null or
		pfechapresenta  is null or
		pimagen_formato is null or
		pimagen_tam     is null or
	    puser_insert    is null or 
        pfecha_insert   is null THEN
	
	   -- datos de entrada incompletos
	   
	   LET v_codret = "00110"; 
	   RETURN v_codret; 
	END IF;

BEGIN

	ON EXCEPTION SET sql_err,isam_err
		IF sql_err <> 0 OR isam_err <> 0 THEN
			LET v_codret = sql_err;
			RETURN v_codret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 
-- ****************************************************************************
-- insertar registro en cce_cheques_img 
-- ****************************************************************************

-- ASH 17/12/2019

	CALL cal_fechapre(pempresa,pcvebanco,lpad(trim(pnumcuenta),20,"0"), pnumcheque, today)
		RETURNING v_codret,v_fechapre;
		LET v_codret = '00'||v_codret;
		 
	IF v_fechapre IS NULL OR v_fechapre = " " THEN
		LET v_fechapre = today;
	END IF;
		 
-- ASH 17/12/2019
	-- validacion no exista el registro
	
	SELECT  "1"
	INTO   v_existe
	FROM   cce_cheques_img
	WHERE  empresa = pempresa
	AND    cvebanco = pcvebanco
	AND    numcuenta = pnumcuenta
	AND    numcheque = pnumcheque
	AND    lado_ft = plado_ft
	AND    fechapresenta = v_fechapre;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		INSERT INTO cce_cheques_img (empresa,cvebanco,numcuenta,
					numcheque,lado_ft,fechapresenta,imagen_formato,
					imagen_tam,usuario_alta,fecha_alta) 
		VALUES (pempresa,pcvebanco,pnumcuenta,pnumcheque,
				plado_ft,v_fechapre,pimagen_formato,pimagen_tam,
				puser_insert,today);
	END IF;                 
END;
RETURN v_codret;
END PROCEDURE;