CREATE PROCEDURE "informix".sp_obtieneultimadotacion_atm(
	pempresa CHAR(3),
	psucursal CHAR(4))
RETURNING 
	CHAR(5) as cCodRet,
	CHAR(18) as vcant_1,
	CHAR(18) as vcant_2,
	CHAR(18) as vcant_3,
	CHAR(18) as vcant_4,
	CHAR(18) as vcant_5,
	CHAR(18) as vcant_6,
	CHAR(18) as vcant_7,
	CHAR(18) as vcant_8,
	CHAR(18) as vcant_9,
	CHAR(18) as vcant_10,
	CHAR(18) as vcant_11,
	CHAR(18) as vcant_12,
	CHAR(18) as vcant_13,
	CHAR(18) as vcant_14,
	CHAR(18) as vcant_15;
	

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vcant_1 INTEGER;
DEFINE vcant_2 INTEGER;
DEFINE vcant_3 INTEGER;
DEFINE vcant_4 INTEGER;
DEFINE vcant_5 INTEGER;
DEFINE vcant_6 INTEGER;
DEFINE vcant_7 INTEGER;
DEFINE vcant_8 INTEGER;
DEFINE vcant_9 INTEGER;
DEFINE vcant_10 INTEGER;
DEFINE vcant_11 INTEGER;
DEFINE vcant_12 INTEGER;
DEFINE vcant_13 INTEGER;
DEFINE vcant_14 INTEGER;
DEFINE vcant_15 INTEGER;

LET vcodret = "00000";
LET vsqlerr = 0;
LET vcant_1 = 0;
LET vcant_2 = 0;
LET vcant_3 = 0;
LET vcant_4 = 0;
LET vcant_5 = 0;
LET vcant_6 = 0;
LET vcant_7 = 0;
LET vcant_8 = 0;
LET vcant_9 = 0;
LET vcant_10 = 0;
LET vcant_11 = 0;
LET vcant_12 = 0;
LET vcant_13 = 0;
LET vcant_14 = 0;
LET vcant_15 = 0;

--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/spl/sp_obtieneultimadotacion_atm.out";
--trace on;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret, vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vcant_11,vcant_12,vcant_13,vcant_14,vcant_15;

      END IF;
   END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pempresa,'') <> '' AND NVL(psucursal,'') <> '' THEN
		SELECT cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15
		INTO vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vcant_11,vcant_12,vcant_13,vcant_14,vcant_15
		FROM bdisuc:"informix".ss_operaciones 
		WHERE folio_oper IN (SELECT folio_oper 
							 FROM bdisuc:"informix".ss_mae_entradasalida WHERE sucursal = psucursal
							 AND fecha_recepcion = (SELECT MAX(fecha_recepcion)
													FROM bdisuc:"informix".ss_mae_entradasalida
													WHERE sucursal = psucursal
													AND empresa = pempresa)
							AND hora_recepcion = (SELECT MAX(hora_recepcion)
												  FROM bdisuc:"informix".ss_mae_entradasalida
												  WHERE sucursal = psucursal
												  AND empresa = pempresa
												  AND fecha_recepcion = (SELECT MAX(fecha_recepcion)
														FROM ss_mae_entradasalida
														WHERE sucursal = psucursal
														AND empresa = pempresa)
												  )
							AND status = 5)
		 
		AND empresa = pempresa;

	ELSE
		LET vcodret = "00002";
	END IF;
	
	RETURN vcodret, vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vcant_11,vcant_12,vcant_13,vcant_14,vcant_15;

END
END PROCEDURE
DOCUMENT
'MODIFICÃ: Jorge Rivas',
'FECHA: 28/09/2021',
'DESCRIPCIÃN: Se modifica para que la hora de recepciÃ³n maxima sea del Ãºltimo dÃ­a que se recepciono',
'BASE DE DATOS: bdisuc';

CREATE PROCEDURE "informix".sp_traemontosdota_web(pEmpresa CHAR(3), 
								pFolio CHAR(20),
								pCaj CHAR(5))
								
	RETURNING CHAR(5),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),MONEY;

	DEFINE vcodret 			CHAR(5);
	DEFINE vsqlerr,visamerr INTEGER;
	Define vCant1 			CHAR(18); --float(0,8);
	Define vCant2 			CHAR(18);
	Define vCant3 			CHAR(18);
	Define vCant4 			CHAR(18);
	Define vCant5 			CHAR(18);
	Define vCant6 			CHAR(18);
	Define vCant7 			CHAR(18);
	Define vCant8 			CHAR(18);
	Define vCant9 			CHAR(18);
	Define vCant10 			CHAR(18);
	define vMonto  			MONEY;
	define svstatus 		CHAR(2);

	LET vcodret = '00000';
	LET vCant1 = '';
	LET vCant2 = '';
	LET vCant3 = '';
	LET vCant4 = '';
	LET vCant5 = '';
	LET vCant6 = '';
	LET vCant7 = '';
	LET vCant8 = '';
	LET vCant9 = '';
	LET vCant10 = '';
	LET vMonto = 0;
	LET svstatus = '';

BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
	   IF vsqlerr != 0 THEN	  --
		  LET vcodret = vsqlerr;
		  RETURN vcodret, vCant1, vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	IF pEmpresa='' OR pEmpresa IS NULL OR pFolio ='' OR pFolio IS NULL OR pCaj='' OR pCaj IS NULL THEN
		LET vcodret='00001';
		RETURN vcodret, vCant1, vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto;
	END IF;


	SELECT a.cantidad_1,a.cantidad_2,a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.cantidad_8,a.cantidad_9,a.cantidad_10,a.monto,b.status
	INTO vCant1 , vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto,svstatus
	FROM ss_operaciones a, ss_mae_entradasalida b
	WHERE a.empresa = pEmpresa
	AND a.folio_oper = pFolio
	AND a.folio_oper = b.folio_oper
	AND a.sucursal = pCaj;


	LET svstatus = NVL(svstatus,'');

	IF dbinfo("sqlca.sqlerrd2") = 0 or svstatus <> '11' THEN
		LET vcodret = '00002'; -- No existe
	END IF;

	IF svstatus = '05' THEN
		LET vcodret = '00005'; -- Ya recibido
	END IF;

	RETURN vcodret, vCant1 , vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto;

END 
END PROCEDURE;