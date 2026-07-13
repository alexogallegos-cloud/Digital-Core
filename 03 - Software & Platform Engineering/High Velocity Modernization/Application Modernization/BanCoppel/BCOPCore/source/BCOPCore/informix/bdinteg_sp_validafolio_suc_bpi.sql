CREATE PROCEDURE "informix".sp_validafolio_suc_bpi(pEmpresa char(3),pFolio char(55),pSucursal char(4), pNumCte char (16), pFecha DATE)
		RETURNING char(5), char(9);

--Define variables
define sql_err integer;
define cod_ret char (5);
define vNumcte char(9);
define vFolio char(12);
define vSuc char(4);
define vTipo char (1);
define vNumcteTar char (9);

define vcCondDesEnc char(12);
define vc_folioact  char(55);
define vn_tamanio  smallint;
define vc_folio_contrato char(55);
define vc_folio_contrato_alterno char(55);

--Inicializa Variables
LET sql_err = 0;
LET cod_ret = '000';
LET vNumcte = '';
LET vFolio = '';
LET vSuc = '';
LET vTipo = '';
LET vNumcteTar = '';

LET vcCondDesEnc = '';
LET vc_folioact = '';
LET vn_tamanio = 0;
LET vc_folio_contrato = '';
LET vc_folio_contrato_alterno = '';

--RealizÃ?: Javier A. ChÃÂ¡vez Trujillo
--Fecha: 22/12/08
--SolicitÃ?: Mauricio LeÃ?n
--Actividad: Valida el folio y numero de sucursal, y obtiene el numero del cliente
---------------------------------------
--ModificÃ?: Javier A. ChÃÂ¡vez Trujillo
--Fecha: 19/08/09
--Actividad: Se agregÃ? la fecha de nac como parÃÂ¡metro para validarla.
---------------------------------------
--ModificÃ?: Javier A. ChÃÂ¡vez Trujillo
--Fecha: 24/09/09
--Actividad: Se agregÃ? validaciÃ?n de tipo de tarjeta.
-----------------------------------------------------------
-- Se agrega cÃ?digo de retorno de error cuando se captura nÃÂºmero de tarjeta y algun otro dato capturado es incorrecto.
-- Fecha: 15/01/2016
-- Bibiana Gaxiola Verdugo
--------------------------------------------------------

    --SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_validafolio_suc_bpi.out';
    --TRACE ON;

BEGIN

     ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET cod_ret = sql_err;
                    RETURN cod_ret, vNumcte;
            END IF;
     END EXCEPTION;
     
     Select folio_contrato into vc_folio_contrato 
       from bdinteg:si_bpiusuarios a
      Where a.numcte = pNumCte;
      
      -- Buscar folio contrato por TDC o TDD
      IF length(vc_folio_contrato) = 0 OR NVL(vc_folio_contrato,'') = '' OR vc_folio_contrato IS NULL THEN
        -- Busca numero de cliente a partir de TDC
        SELECT numcte INTO vNumcteTar FROM bdicheq:sc_tarjeta 
         WHERE num_tarjeta = pNumCte;
         
        IF length(vNumcteTar) = 0 OR NVL(vNumcteTar,'') = '' OR vNumcteTar IS NULL THEN
            -- Busca numero de cliente a partir de TDC
            SELECT numcte INTO vNumcteTar FROM bdicred:sd_tarjeta 
            WHERE num_tarjeta = pNumCte; 
                                                      
        END IF;
        
        LET pNumCte = vNumcteTar;
        
        -- Se obtiene el numero de contrato encriptado del cliente 
        Select folio_contrato into vc_folio_contrato from bdinteg:si_bpiusuarios a
         Where a.numcte = vNumcteTar;  
               
      END IF;
       
     LET vn_tamanio = length(TRIM(vc_folio_contrato));
      
     IF  vn_tamanio > 12 THEN
         Select folio_contrato into vc_folioact 
           from bdinteg:si_bpiusuarios a
          Where a.numcte = pNumCte;
      
         -- Desencripta el folio
         EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vc_folioact) INTO cod_ret, vcCondDesEnc;

        IF pFolio = vcCondDesEnc THEN
            LET pFolio = TRIM(vc_folioact);
            LET cod_ret = '000';
        ELSE
            SELECT folio_contrato_suc, folio_contrato_alterno  INTO vc_folioact, vc_folio_contrato_alterno  FROM bdinteg:si_bpiusuarios_folioalterno a WHERE a.numcte = pNumCte;
             -- Desencripta el folio
             EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vc_folioact) INTO cod_ret, vcCondDesEnc;
             IF pFolio = vcCondDesEnc THEN
                LET pFolio = TRIM(vc_folio_contrato_alterno);
                LET cod_ret = '000';
             ELSE
                LET cod_ret = '002';
             END IF;
        END IF;
        
     END IF;

     IF(LENGTH(TRIM(pNumCte)) = 9 ) THEN
     
			SELECT a.numcte INTO vNumcte
            FROM bdinteg:si_bpiusuarios a
			INNER JOIN  bdinteg:si_ctepf f ON a.numcte = f.numcte
            WHERE a.empresa = pEmpresa 
			  AND a.folio_contrato = pFolio
			  AND a.suc_registro = pSucursal 
			  AND a.numcte = pNumCte 
			  AND f.fecha_nac = pFecha;

			IF NVL(vNumcte,'') = '' THEN
				LET cod_ret = '002'; --El cliente no existe
			END IF;

	ELIF (LENGTH(TRIM(pNumCte)) = 16 ) THEN

		SELECT creditodebito INTO vTipo FROM intercard:bines  where bin = substring(pNumCte FROM 1 FOR 6);

		IF(vTipo=='D') THEN
			SELECT numcte INTO vNumcteTar FROM bdicheq:sc_tarjeta WHERE num_tarjeta = pNumCte;

			IF NVL(vNumcteTar,'') = '' THEN
				LET cod_ret = '002'; --El Cliente no existe con esa tarjeta
			ELSE
				SELECT a.numcte INTO vNumcte
				FROM bdinteg:si_bpiusuarios a
				INNER JOIN  bdinteg:si_ctepf f ON a.numcte = f.numcte
				WHERE a.empresa = pEmpresa 
				  AND a.folio_contrato = pFolio 
				  AND a.suc_registro = pSucursal 
				  AND a.numcte = vNumcteTar 
				  AND f.fecha_nac = pFecha;

				IF NVL(vNumcte,'') = '' THEN
					LET cod_ret = '002'; --El Cliente no existe con los datos capturados
				END IF;

			END IF;

		ELIF (vTipo == 'C') THEN

			SELECT numcte INTO vNumcteTar FROM bdicred:sd_tarjeta WHERE num_tarjeta = pNumCte;

			IF NVL(vNumcteTar,'') = '' THEN
				LET cod_ret = '002'; --El Cliente no existe con esa tarjeta
			ELSE
				SELECT a.numcte INTO vNumcte
				FROM bdinteg:si_bpiusuarios a
				INNER JOIN  bdinteg:si_ctepf f ON a.numcte = f.numcte
				WHERE a.empresa = pEmpresa 
				AND a.folio_contrato = pFolio 
				AND a.suc_registro = pSucursal 
				AND a.numcte = vNumcteTar 
				AND f.fecha_nac = pFecha;

				IF NVL(vNumcte,'') = '' THEN
					LET cod_ret = '002'; --El Cliente no existe con los datos capturados
				END IF;

			END IF;

		ELSE
			LET cod_ret = '003'; --El tipo de tarjeta no existe
		END IF;

	 ELSE
        LET cod_ret = '001'; --El nÃ?mero introducido es incorrecto
     END IF ;


    RETURN cod_ret, vNumcte;

END;
END PROCEDURE;