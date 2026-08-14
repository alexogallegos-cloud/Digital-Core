CREATE PROCEDURE "informix".sp_sac_wu_validanombre(pPrimerNomRem CHAR(40),pSegunNomRem CHAR(40), pApePatRem CHAR(40), pApeMatRem CHAR(40), pPrimerNomBenef CHAR(40), pSegunNomBenef CHAR(40), pApePatBenef CHAR(40), pApeMatBenef CHAR(40), pMonto CHAR(40), pNumReferencia CHAR(10), pFolioSuc CHAR(16))

RETURNING
CHAR(5)      As CodRet,  
DECIMAL(6,1) As Porcentaje, 
CHAR(1)  As TipoBenef, 
CHAR(40) As PrimerNomRem,
CHAR(40) As SegundoNomRem,
CHAR(40) As ApePatRem,  
CHAR(40) As ApeMatRem,
CHAR(40) As PrimerNomBenef,
CHAR(40) As SegundoNomBenef,
CHAR(40) As ApePatBenef,
CHAR(40) As ApeMatBenef,
CHAR(40) As Monto, 
CHAR(16) As new_mtcn, 
CHAR(10) As MontoTransferKey; 


--DEFINICION DE VARIABLES--
	DEFINE iSql_err                  INTEGER;
	DEFINE iNumCoincidencias         INTEGER;
	DEFINE cCodRet                   CHAR(5);
	DEFINE dPorcentaje               DECIMAL(6,1);
	DEFINE dPorcentajeAnt            DECIMAL(6,1);
	DEFINE dPorcentajeMinimo         DECIMAL(6,1);
	DEFINE iCoicidencia              INTEGER;
	DEFINE iCantidad                 INTEGER;
	DEFINE iSuma                     INTEGER;
	DEFINE cPrimerNomRem             CHAR(40);
	DEFINE cSegunNomRem				 CHAR(40);
	DEFINE cApePatRem                CHAR(40);
	DEFINE cApeMatRem				 CHAR(40);
	DEFINE cPrimerNomBenef           CHAR(40);
	DEFINE cSegunNomBenef            CHAR(40);
	DEFINE cApePatBenef              CHAR(40);
	DEFINE cApeMatBenef              CHAR(40);
	DEFINE cMonto   				 CHAR(40);
	DEFINE cMontoTransferKey   		 CHAR(10);
	DEFINE cMontoTransferKeyAux      CHAR(10);
	DEFINE cForeign_Rs_Refnum_Rq     CHAR (16);
	DEFINE cNew_mtcn                 CHAR (16);
	DEFINE cForeign_Rs_Refnum_Rq_Aux CHAR (16);
	DEFINE cTipoBenef                CHAR(1);
	DEFINE iNum_coincidencias        INTEGER;
	DEFINE iBandera                  INTEGER;
	DEFINE cNew_mtcnAnt              CHAR(16);

--INICIALIZACION DE VARIABLES--
	LET iSql_err                  = 0;
	LET cCodRet                   = '00000';
	LET dPorcentaje               = 0;
	LET dPorcentajeAnt            = 0;
	LET dPorcentajeMinimo         = 0;
	LET iCoicidencia              = 0;
	LET iCantidad                 = 0;
	LET iSuma                     = 0;
	LET cPrimerNomRem             = '';
	LET cSegunNomRem			  = '';
	LET cApePatRem                = '';
	LET cApeMatRem                = '';
	LET cPrimerNomBenef           = '';
	LET cSegunNomBenef            = '';
	LET cApePatBenef              = '';
	LET cApeMatBenef              = '';
	LET cMonto                    = '';
	LET cMontoTransferKey         = '';
	LET cMontoTransferKeyAux      = '';
	LET cForeign_Rs_Refnum_Rq     = '';
	LET cNew_mtcn                 = '';
	LET cForeign_Rs_Refnum_Rq_Aux = '';
	LET cTipoBenef                = '';
	LET iNumCoincidencias         = 0;
	LET iNum_coincidencias        = 0;
	LET iBandera                  = 0;
	LET cNew_mtcnAnt              = '';

	--SET DEBUG FILE TO "/informix/Elvia/sp_sac_wu_validanombre.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet, dPorcentaje,cTipoBenef,cPrimerNomRem ,cSegunNomRem,cApePatRem, cApeMatRem,cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef,cMonto  ,cNew_mtcn,cMontoTransferKey ;
        END IF;
    END EXCEPTION;
	
	IF  NVL(pPrimerNomBenef,'') = '' OR NVL(pApePatBenef,'') = '' OR NVL(pNumReferencia,'') = '' OR NVL(pMonto,'') = '' THEN
		LET cCodRet =   '00001'; --Faltan parámetros
		RETURN cCodRet, dPorcentaje,cTipoBenef,cPrimerNomRem ,cSegunNomRem,cApePatRem, cApeMatRem,cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef,cMonto  ,cNew_mtcn,cMontoTransferKey ;
	END IF;
	
	SELECT valor INTO dPorcentajeMinimo FROM "informix".sac_param WHERE cod_param = 87077;
	
	LET pNumReferencia = TRIM(pNumReferencia);
	LET pMonto = TRIM(pMonto);
	LET pFolioSuc = TRIM(pFolioSuc);
	
	SELECT FIRST 1 DISTINCT num_coincidencias INTO iNum_coincidencias  
	FROM  "informix".sac_wu_search 
	WHERE mtcn = pNumReferencia 
	AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".sac_wu_search WHERE mtcn = pNumReferencia)
	AND estatus_remesa = 'W/C'  
	AND num_coincidencias <> '';
	
	IF NVL(iNum_coincidencias ,'') <> ''  THEN
		IF EXISTS (SELECT 1   FROM  "informix".sac_wu_select WHERE mtcn = pNumReferencia AND foreign_rs_refnum_rq = pFolioSuc) THEN
			LET iBandera = 1;
		END IF;
	END IF;	
	
	IF iBandera = 1 THEN			
		FOREACH 	
			SELECT a.emisor_nombre1,a.emisor_nombre2, a.emisor_appaterno, a.emisor_apmaterno,a.benef_nombre1,a.benef_nombre2,a.benef_appaterno,a.benef_apmaterno,b.money_transfer_key_rp,a.monto_total_destino,a.foreign_rs_refnum_rq,b.new_mtcn  
			INTO cPrimerNomRem,cSegunNomRem,cApePatRem,cApeMatRem, cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef, cMontoTransferKey, cMonto,cForeign_Rs_Refnum_Rq,cNew_mtcn  			  
			FROM "informix".sac_wu_search a, "informix".sac_wu_select b 
			WHERE a.mtcn = pNumReferencia 
			AND a.estatus_remesa = 'W/C'  
			AND a.monto_total_destino = pMonto 
			AND b.mtcn = a.mtcn 
			AND a.foreign_rs_refnum_rq = pFolioSuc
			AND a.foreign_rs_refnum_rq = b.foreign_rs_refnum_rq
			
			EXECUTE PROCEDURE "informix".sp_validanombenefbts(pPrimerNomBenef, pSegunNomBenef, pApePatBenef, pApeMatBenef, cPrimerNomBenef, cSegunNomBenef, cApePatBenef, cApeMatBenef)
			INTO cCodRet, iCoicidencia;
			
			IF cCodRet = '00000' THEN
				LET dPorcentaje = iCoicidencia;
			ELSE
				RETURN cCodRet, dPorcentaje,cTipoBenef,cPrimerNomRem ,cSegunNomRem,cApePatRem, cApeMatRem,cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef,cMonto  ,cNew_mtcn,cMontoTransferKey ;
			END IF;	
			
			IF dPorcentaje < dPorcentajeMinimo THEN
				CONTINUE FOREACH;
			ELIF  dPorcentaje  > dPorcentajeAnt THEN
				LET  dPorcentajeAnt= dPorcentaje;
				LET cMontoTransferKeyAux = cMontoTransferKey;
				LET dPorcentaje =  0;
				LET cForeign_Rs_Refnum_Rq_Aux = cForeign_Rs_Refnum_Rq;
				LET  cNew_mtcnAnt = cNew_mtcn;
			ELSE
				CONTINUE FOREACH;
			END IF;		
		END FOREACH;	
		
	ELIF NVL(iNum_coincidencias ,'') = '' OR iBandera = 0 THEN 
		FOREACH 	
			SELECT emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,money_transfer_key,monto_total_destino,foreign_rs_refnum_rq,new_mtcn  
			INTO cPrimerNomRem,cSegunNomRem,cApePatRem,cApeMatRem, cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef, cMontoTransferKey, cMonto,cForeign_Rs_Refnum_Rq,cNew_mtcn  
			FROM "informix".sac_wu_search 
			WHERE mtcn = pNumReferencia 
			AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".sac_wu_search WHERE mtcn = pNumReferencia)
			AND estatus_remesa = 'W/C'  
			AND monto_total_destino =  pMonto 
			AND foreign_rs_refnum_rq = pFolioSuc
			   
			EXECUTE PROCEDURE "informix".sp_validanombenefbts(pPrimerNomBenef, pSegunNomBenef, pApePatBenef, pApeMatBenef, cPrimerNomBenef, cSegunNomBenef, cApePatBenef, cApeMatBenef)
			INTO cCodRet, iCoicidencia;

			IF cCodRet = '00000' THEN
				LET dPorcentaje = iCoicidencia;
			ELSE
				RETURN cCodRet, dPorcentaje,cTipoBenef,cPrimerNomRem ,cSegunNomRem,cApePatRem, cApeMatRem,cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef,cMonto  ,cNew_mtcn,cMontoTransferKey ;
				
			END IF;	
			
			IF dPorcentaje < dPorcentajeMinimo THEN
				CONTINUE FOREACH;
			ELIF  dPorcentaje  > dPorcentajeAnt THEN
				LET  dPorcentajeAnt= dPorcentaje;
				LET cMontoTransferKeyAux = cMontoTransferKey;
				LET dPorcentaje =  0;
				LET cForeign_Rs_Refnum_Rq_Aux = cForeign_Rs_Refnum_Rq;
				LET  cNew_mtcnAnt = cNew_mtcn;
			ELSE
				CONTINUE FOREACH;
			END IF;		
		END FOREACH;	
	END IF;
	
	LET  dPorcentaje = dPorcentajeAnt;
	LET cMontoTransferKey = cMontoTransferKeyAux;
	LET cForeign_Rs_Refnum_Rq = cForeign_Rs_Refnum_Rq_Aux;	
	LET cNew_mtcn = cNew_mtcnAnt;
	
	IF dPorcentaje < dPorcentajeMinimo THEN
		LET cCodRet            = '00002';
		LET dPorcentaje        = dPorcentajeAnt;
		LET cPrimerNomRem      = '';
		LET cApePatRem         = '';
		LET cPrimerNomBenef    = '';
		LET  cApePatBenef      = '';
		LET  cMonto            = '';
		LET  cNew_mtcn         = '';
		LET  cMontoTransferKey = '';
	ELSE
		SELECT COUNT(*) INTO iCantidad  FROM "informix".sac_wu_search 
		WHERE mtcn = pNumReferencia
		AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".sac_wu_search WHERE mtcn = pNumReferencia)
		AND money_transfer_key = cMontoTransferKey 
		AND foreign_rs_refnum_rq = cForeign_Rs_Refnum_Rq;
		   
		IF iCantidad > 1 THEN
			LET cCodRet            ='00003';
			LET dPorcentaje        = 0;
			LET cPrimerNomRem      = '';
			LET cApePatRem         = '';
			LET cPrimerNomBenef    = '';
			LET  cApePatBenef      = '';
			LET  cMonto            = '';
			LET  cNew_mtcn         = '';
			LET  cMontoTransferKey = '';
			LET cTipoBenef         = '';
		ELSE
			SELECT benef_nametype,emisor_nombre1,emisor_appaterno,benef_nombre1,benef_appaterno, new_mtcn, monto_total_destino, num_coincidencias 
			INTO  cTipoBenef, cPrimerNomRem ,cApePatRem ,cPrimerNomBenef ,cApePatBenef  ,cNew_mtcn, cMonto,iNumCoincidencias  
			FROM  "informix".sac_wu_search 
			WHERE mtcn = pNumReferencia 
			AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".sac_wu_search WHERE mtcn = pNumReferencia)			 
			AND foreign_rs_refnum_rq = cForeign_Rs_Refnum_Rq 
			AND new_mtcn = cNew_mtcn;

			IF TRIM(pMonto) <> TRIM(cMonto) THEN
				LET cCodRet            = '00004';
				LET dPorcentaje        = 0;
				LET cPrimerNomRem      = '';
				LET cApePatRem         = '';
				LET cPrimerNomBenef    = '';
				LET  cApePatBenef      = '';
				LET  cMonto            = '';
				LET  cNew_mtcn         = '';
				LET  cMontoTransferKey = '';			
				LET cTipoBenef         = '';
			END IF;
		END IF;
	END IF;
	RETURN cCodRet, dPorcentaje,cTipoBenef,cPrimerNomRem ,cSegunNomRem,cApePatRem, cApeMatRem,cPrimerNomBenef,cSegunNomBenef, cApePatBenef,cApeMatBenef,cMonto  ,cNew_mtcn,cMontoTransferKey ;
END
END PROCEDURE
DOCUMENT
'AUTOR : Mario Gallardo',
'FECHA : 18/07/2010',
'Compara el nombre capturado en Bancoppel contra el que envía WU',
'por medio de los tres ciclos, y obtiene el porcentaje máximo de coincidencia',
'AUTOR : Mario Gallardo',
'FECHA : 03/10/2010',
'Se agrega  funcionalidad para que en caso de tener mas de una coincidencia',
'el campo money_transfer_key lo tome de la tabla sac_wu_select (money_transfer_key_rp)',
'BD    : bdisac',
'AUTOR : Pedro Jimenez',
'FECHA : 26/02/2015',
'se agregan nuevos parametros para validar la coincidencia de los nombres',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_obtienefoliocoppel()
RETURNING CHAR(5), CHAR(10);

	DEFINE cCodRet          CHAR(5);
	DEFINE cInfoErr         CHAR(100);
	DEFINE iIsamErr         INTEGER;
	DEFINE iSqlErr          INTEGER;
	DEFINE cFolioCoppel     CHAR(50);
	DEFINE bBegin 	     	BOOLEAN;

	--SET DEBUG FILE TO "/respaldosbd/hugovaz/1900/sp_obtieneFolioCoppel.out";
	--TRACE ON;

	LET cCodRet = '00000';
	LET cFolioCoppel = '';
	LET bBegin = 'F';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_obtieneFolioCoppel");
				IF (bBegin = 'F') THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, -1;
			END IF;
		END EXCEPTION;


		--EXCEPTION CIERRA SI LA TRANSACION ESTA ABIERTA.
		ON EXCEPTION IN (-535)
			LET bBegin = 'T';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		BEGIN WORK;

			--UPDATE QUE COMPARA SI EL CAMPO VALOR DE LA COLUMNA 1 Y 2 SON IGUALES O DIFERENTES, EN CASO DE SER IGUALES ACTUALIZA EL CAMPO VALOR A '1'. SI ES DIFERENTE TOMA EL VALOR LE SUMA +1 Y ACTUALIZA EL CAMPO VALOR.
			UPDATE "informix".sac_recibo_coppel
			SET valor = (CASE WHEN (SELECT valor FROM "informix".sac_recibo_coppel WHERE cod_param = 2) <> (SELECT valor FROM "informix".sac_recibo_coppel WHERE cod_param = 1) THEN (SELECT CAST (CAST(valor AS INTEGER) + 1 AS CHAR(10)) AS INTEGER FROM "informix".sac_recibo_coppel WHERE cod_param = 1) ELSE '1' END)
			WHERE cod_param = 1;

			--SELECT QUE TOMA EL CAMPO VALOR DE LA COLUMNA COD_PARAM = 1, SI ES = 1 TOMA EL VALOR DE COD_PARAM = 2, SI ES DIFERENTE DE '1' TOMA EL VALOR DE COD_PARAM = 1 Y RESTA 1.
			SELECT (CASE WHEN valor = 1 THEN (SELECT valor FROM "informix".sac_recibo_coppel WHERE cod_param = 2) ELSE CAST((valor:: INTEGER - 1) AS CHAR(10)) END)
			INTO cFolioCoppel
			FROM "informix".sac_recibo_coppel
			WHERE cod_param = 1;

		COMMIT WORK;
		IF bBegin = 'T' THEN
			BEGIN WORK;
		END IF
		RETURN cCodRet, cFolioCoppel;
	END;
 END PROCEDURE
 DOCUMENT
 'AUTOR: Vazquez Herrera Hugo Guadalupe',
 'DESCRIPCION: Procedimiento que compara el campo valor de los campos cod_param igual a 1 y 2, se ser iguales se realiza update en el valor campo = 1  del cod_param = 1. se ser diferentes incrementa en 1 el campo valor del cod_param = 1',
 'FECHA: 20141218',
 'Folio: 1476',
 'BD: bdisac';

CREATE PROCEDURE "informix".sp_calcula_comisiones(pcategoria CHAR(2),pconvenio CHAR(3),ppago MONEY(16,2))
returning CHAR(5),MONEY(14,2), MONEY(14,2), MONEY(14,2),MONEY(14,2);
	--************************************************************--
		--**	Elaboró: Ramon Octavio Romero Mascareño		**--
		--**	Actividad: Calcula Comisiones				**--
		--**	Solicito: Mauricio León						**--
		--**	Fecha: 10/07/09								**--
	--************************************************************--
		--**	Modificó: Manuel Osuna Valencia                 				**--
		--**	Actividad: Se modifica el tipo de dato de las variables de salida	**--
		--**	Solicito: Mauricio León								**--
		--**	Fecha: 05/08/09									**--
	--************************************************************--
DEFINE sql_err					INTEGER;
DEFINE cod_err					CHAR(5);
DEFINE vimpcomconvenio			MONEY(14,2);
DEFINE vIVAimpconvenio			MONEY(14,2);
DEFINE vimpcomcte				MONEY(14,2);
DEFINE vIVAimpcomcte			MONEY(14,2);
DEFINE vFlgporccomtrans_conv	CHAR(1);
DEFINE vPorc_com_trans_conv		MONEY(16,2);
DEFINE vFlgporccomtotal_conv	CHAR(1);
DEFINE vPorc_com_total_conv		MONEY(16,2);
DEFINE vFlgimpcomtrans_conv		CHAR(1);
DEFINE vImp_com_trans_conv		MONEY(16,2);
DEFINE vFlgimpcomtotal_conv		CHAR(1);
DEFINE vImp_com_total_conv		MONEY(16,2);
DEFINE vFlgivaincluido_conv		CHAR(1);
DEFINE vIva_convenio			INTEGER;
DEFINE vFlgporccomtrans_cte		CHAR(1);
DEFINE vPorc_com_trans_cte		MONEY(16,2);
DEFINE vFlgimpcomtrans_cte		CHAR(1);
DEFINE vImp_com_trans_cte		MONEY(16,2);

LET cod_err					="000";	
LET vimpcomconvenio 		= 0;
LET vIVAimpconvenio	 		= 0;
LET vimpcomcte 				= 0;
LET vIVAimpcomcte 			= 0;
LET vFlgporccomtrans_conv	="";
LET vPorc_com_trans_conv	= 0;
LET vFlgporccomtotal_conv	="";
LET vPorc_com_total_conv	= 0;
LET vFlgimpcomtrans_conv	="";
LET vImp_com_trans_conv		= 0;
LET vFlgimpcomtotal_conv	="";
LET vImp_com_total_conv		= 0;
LET vFlgivaincluido_conv	="";
LET vIva_convenio			= 0;
LET vFlgporccomtrans_cte	="";
LET vPorc_com_trans_cte		= 0;
LET vFlgimpcomtrans_cte		="";
LET vImp_com_trans_cte		= 0;


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
      END IF ;
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;


SELECT 
    flgporccomtrans_conv,porc_com_trans_conv,   
    flgporccomtotal_conv,porc_com_total_conv,   /* comisiones por % o por monto pero total por día*/
    flgimpcomtrans_conv, imp_com_trans_conv,    
    flgimpcomtotal_conv, imp_com_total_conv,    /* comisiones por % o por monto pero total por día*/
    flgivaincluido_conv, iva_convenio,  		/* = 1 incluye IVA la comision (quitar el IVA del monto de comisión)*/
												/* = 0 calcular IVA de la comision (no se altera el monto de comisión)*/
												/* y el valor para cálculo del IVA esta en el campo iva_convenio */
    flgporccomtrans_cte, porc_com_trans_cte,    /*comisión al cliente en % por transacción*/
                                                /*se toma el monto del pago y se calcula la comisión*/
    flgimpcomtrans_cte, imp_com_trans_cte       /*comisión al cliente en monto fijo por transacción*/
INTO vFlgporccomtrans_conv,vPorc_com_trans_conv,   
    vFlgporccomtotal_conv,vPorc_com_total_conv, vFlgimpcomtrans_conv, vImp_com_trans_conv,    
    vFlgimpcomtotal_conv, vImp_com_total_conv, vFlgivaincluido_conv, vIva_convenio, 
    vFlgporccomtrans_cte, vPorc_com_trans_cte, vFlgimpcomtrans_cte, vImp_com_trans_cte  	
FROM BDISAC:sac_convenios
where numcategoria = pcategoria
and numconvenio = pconvenio;

    /*comisión del convenio*/
    IF vFlgporccomtotal_conv = 1 OR vFlgimpcomtotal_conv = 1 THEN 		/* comisiones por % o por monto pero total por día*/
        LET vimpcomconvenio = 0;                                        /* no debe grabar nada en linea (ceros)*/
    ELIF vFlgporccomtrans_conv = 1 THEN                       			/*comision es % por monto de transacción*/
        LET vimpcomconvenio = ppago * (vPorc_com_trans_conv/100);
    ELIF vFlgimpcomtrans_conv = 1 THEN                        			/*comision en monto por transacción*/ 
        LET vimpcomconvenio = vImp_com_trans_conv;
    ELSE 
        LET vimpcomconvenio = 0 ;                                      	/*no debe grabar nada en linea (ceros)*/
    END IF;
          
    /*comisíón a cliente QUE SE DEBE SUMAR AL IMPORTE DE CARGO POR PAGO ADEMAS DE REGISTRARSE EN SAC_MOVIMIENTOS*/
    IF vFlgporccomtrans_cte = 1 THEN                         			/*comisión al cliente en % por transacción*/
        LET vimpcomcte = ppago * (vPorc_com_trans_cte/100);
    ELIF vFlgimpcomtrans_cte = vImp_com_trans_cte THEN     				/*comisión al cliente en monto fijo por transacción*/
        LET vimpcomcte = vImp_com_trans_cte;
    ELSE
        LET vimpcomcte = 0;
    END IF;

    /*CALCULA IVA DE COMISIONES*/
    LET vIVAimpconvenio = vimpcomconvenio * (vIva_convenio/100);    	/*calculo iva de convenio*/
    LET vIVAimpcomcte = vimpcomcte * (vIva_convenio/100);        		/*calculo iva de cliente*/

    IF vFlgivaincluido_conv = 1 THEN     /*SE EXTRAE IVA DE LA COMISION*/      
        LET vimpcomconvenio = vimpcomconvenio - vIVAimpconvenio;
        LET vimpcomcte = vimpcomcte - vIVAimpcomcte;
    END IF;

	RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
END;
END PROCEDURE;