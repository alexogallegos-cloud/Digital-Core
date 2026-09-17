CREATE PROCEDURE "informix".sp_recepdota_rec_web(pEmpresa       CHAR(3),
										  pSucursal      CHAR(4),
										  pFolioDota     CHAR(8),
										  pCodAtm        CHAR(4),
										  pOpt           CHAR(1))
RETURNING CHAR(5);

DEFINE vcodret            CHAR(5);
DEFINE vsqlerr,visamerr   INTEGER;
DEFINE cPlaza             CHAR(3);
DEFINE cProveedor         CHAR(4);
DEFINE dtFechaRec         DATE;
DEFINE cHoraRec           CHAR(5);
DEFINE cUserRec           CHAR(8);
DEFINE cStatus            CHAR(2);
DEFINE mSdoAsig           MONEY(14,2);
DEFINE fCantidad_1        FLOAT;
DEFINE fCantidad_2        FLOAT;
DEFINE fCantidad_3        FLOAT;
DEFINE fCantidad_4        FLOAT;
DEFINE fCantidad_5        FLOAT;
DEFINE fCantidad_6        FLOAT;
DEFINE fCantidad_7        FLOAT;
DEFINE fCantidad_8        FLOAT;
DEFINE fCantidad_9        FLOAT;
DEFINE fCantidad_10       FLOAT;
DEFINE mSdoAnt            MONEY(14,2);
DEFINE mSdoAsig2          MONEY(14,2);
DEFINE mSdoTotal          MONEY(14,2);
DEFINE bTransacInterAct	  CHAR(1);
DEFINE bEnTransac         CHAR(1);

LET vcodret              = "00000";
LET vsqlerr              = 0;
LET visamerr             = 0;
LET cPlaza               = "";
LET cProveedor           = "";
LET dtFechaRec           = DATE(1);
LET cHoraRec             = "";
LET cUserRec             = "";
LET cStatus              = "";
LET mSdoAsig             = 0;
LET fCantidad_1          = 0;
LET fCantidad_2          = 0;
LET fCantidad_3          = 0;
LET fCantidad_4          = 0;
LET fCantidad_5          = 0;
LET fCantidad_6          = 0;
LET fCantidad_7          =0;
LET fCantidad_8          =0;
LET fCantidad_9          =0;
LET fCantidad_10         =0;
LET mSdoAnt              = 0;
LET mSdoAsig2            = 0;
LET mSdoTotal            = 0;
LET bTransacInterAct     = 'F';
LET bEnTransac           = 'F';

BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
			IF vsqlerr <> 0 THEN
				IF bTransacInterAct = 'T' THEN		--DSB20150429 {
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						BEGIN WORK;
					END IF;
				ELSE
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
					ELSE
						ROLLBACK WORK;
					END IF;							
				END IF;	

				LET vcodret = vsqlerr;
				RETURN vcodret;
			END IF;
		END EXCEPTION;

	ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		LET bEnTransac = 'T';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN WORK;

	--Creado por: PAUL IVAN QUINTERO VARELA
	--25-09-2019
	--Se crea procedimiento para recuperar la informacion a su estado original de la transaccion en caso de ocurrir
	--un error o incosistencia en el problema para recuperarla.


	-- SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/sucursal/sp_recepdota_rec.out";
	-- TRACE ON;

	IF ( NVL(pEmpresa,'') = '')  OR ( NVL(pFolioDota,'') = '') OR (NVL(pOpt,'') = '') THEN

		LET vcodret = "00110";
		
	ELSE

		SELECT plaza_cajagen 
		  INTO cPlaza
		  FROM bdinteg:si_sucursales
		 WHERE sucursal = pSucursal;
		 
		IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
			SELECT cod_proveedor 
			  INTO cProveedor
			  FROM ss_proveedores
			 WHERE plaza = cPlaza;
		END IF;

		IF pCodAtm = 0 OR (NVL(pCodAtm,'') = '') OR (NVL(pSucursal,'') = '') THEN
			SELECT sucursal 
				INTO pCodAtm 
				FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota;
				
			let pSucursal = pCodAtm;
		END IF;
				
		IF pOpt IN ('1','3') THEN
		-- Recuperacion funcion envia_dota OPCION 1
		   SELECT fecha_recepcion, hora_recepcion, usuario_recepcion, status
			 INTO dtFechaRec, cHoraRec, cUserRec, cStatus
			 FROM ss_mae_entradasalida_rec
			WHERE folio_oper = pFolioDota;
			
			IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
			   UPDATE ss_mae_entradasalida
				  SET fecha_recepcion = dtFechaRec,
					  hora_recepcion = cHoraRec,
					  usuario_recepcion = cUserRec,
					  status = cStatus
				WHERE folio_oper = pFolioDota;
			END IF;
			
			/*SELECT saldo_asignado
			  INTO mSdoAsig
			  FROM ss_cajageneral_rec
			 WHERE cod_proveedor = cProveedor;
			 
			 IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
				UPDATE ss_cajageneral
				   SET saldo_asignado = mSdoAsig
				 WHERE cod_proveedor = cProveedor;
				 
			 END IF;*/
			 
			 DELETE FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota;
			 
		END IF;


		IF pOpt IN ('2','3') THEN	 
		-- Recuperacion funcio envia_OPERACION OPCION 2
			SELECT cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10, saldo_anterior, saldo_asignado, saldo_total
			  INTO fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6,fCantidad_7,fCantidad_8,fCantidad_9,fCantidad_10, mSdoAnt, mSdoAsig2, mSdoTotal
			  FROM bdisuc:"informix".ss_atm_rec
			 WHERE empresa = pEmpresa 
			   AND cod_atm = pCodAtm;

			IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
			
				UPDATE bdisuc:"informix".ss_atm 
				   SET cantidad_1 = fCantidad_1,
					   cantidad_2 = fCantidad_2,
					   cantidad_3 = fCantidad_3,
					   cantidad_4 = fCantidad_4,
					   cantidad_5 = fCantidad_5,
					   cantidad_6 = fCantidad_6,
						cantidad_7 = fCantidad_7,
						cantidad_8 = fCantidad_8,
						cantidad_9 = fCantidad_9,
						cantidad_10 = fCantidad_10,
					   saldo_anterior = mSdoAnt,
					   saldo_total = mSdoTotal					  
				WHERE empresa = pEmpresa AND cod_atm = pCodAtm;

				
			   DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
				
			ELSE
				
				DELETE FROM  bdisuc:"informix".ss_atm WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
				DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
			END IF;
		END IF;
		
		IF pOpt IN ('4') THEN	 
		-- Recuperacion funcion envia_OPERACION OPCION 4
			DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
			DELETE FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota;
		END IF;
		
		IF pOpt IN ('5') THEN	 
		-- Valida si quedo alguna operacion inclonclusa
			IF (SELECT folio_oper FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota) > 0 THEN
				LET vcodret = "00200";
			END IF;
		END IF;
		
	END IF;
	COMMIT WORK;

	IF bTransacInterAct = 'T' THEN
		BEGIN WORK;
	END IF;

	RETURN vcodret;

END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:RecepDota.exe',
'AUTOR:Cristian Valentina Aguilar ', 
'FECHA:2019-11-11',
'DESCRIPCION: Se genera procedimiento para realizar el reverso a la recepcion de la dotacion, para eliminar la transaccion en caso de algun error en sucursal se de reverso en el servidor central.' ,
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE  "informix".sp_reiniciapaseatm_web(pusuario char(4), pfecha_sucursal  date)
RETURNING CHAR(5);

   DEFINE cod_ret CHAR(5);
   DEFINE sql_err INTEGER;

   LET cod_ret  = "00000";

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   DELETE FROM bdicont:"informix".co_poldet WHERE fecha_captura = pfecha_sucursal AND usuario = pusuario;
   DELETE FROM bdicont:"informix".co_auditpase WHERE fecha_captura = pfecha_sucursal AND usuario = pusuario;
   DELETE FROM bdisuc:"informix".ss_contproc WHERE fecha =pfecha_sucursal AND sucursal = pusuario;
   DELETE FROM bdisuc:"informix".ss_saldossuc  WHERE fecha = pfecha_sucursal AND sucursal = pusuario;
    
   RETURN cod_ret;
END
END PROCEDURE
DOCUMENT
'CREO: Mario Gallardo',
'FECHA: 15/06/2020',
'DESCRIPCIÃN: se crea sp para reeiniciar tablas para pase ATM',
'BASE DE DATOS: bdisuc',
'FOLIO:674';

CREATE PROCEDURE "informix".sp_reversafaltsob_web(psucursal CHAR(4),
		pfolio_suc CHAR(16),
  		ptransaccion CHAR(4),
		popcion CHAR(1))

RETURNING CHAR(5),CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr integer;
DEFINE visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vproveedor CHAR(4);
DEFINE vplaza CHAR(3);
DEFINE vnum CHAR(8);
DEFINE bTransacInterAct	CHAR(1);
DEFINE bEnTransac CHAR(1);
DEFINE psaldo_anterior FLOAT(8);
DEFINE psaldo_total FLOAT(8);
DEFINE pcantidad_1 FLOAT(8);
DEFINE pcantidad_2 FLOAT(8);
DEFINE pcantidad_3 FLOAT(8);
DEFINE pcantidad_4 FLOAT(8);
DEFINE pcantidad_5 FLOAT(8);
DEFINE pcantidad_6 FLOAT(8);
DEFINE pencontro   CHAR(5);
DEFINE variable INTEGER;
DEFINE variable1 INTEGER;
DEFINE variable2 INTEGER;
LET vcodret = "00000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
--LET vfolio = "";
LET vsqlerr = 0;
LET visamerr = 0;
LET bTransacInterAct = 'F';
LET bEnTransac = 'F';

LET psaldo_anterior = 0;
LET psaldo_total = 0;
LET pcantidad_1 = 0;
LET pcantidad_2 = 0;
LET pcantidad_3 = 0;
LET pcantidad_4 = 0;
LET pcantidad_5 = 0;
LET pcantidad_6 = 0;
LET pencontro = '00001';
	
BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
		IF vsqlerr <> 0 THEN
			IF bTransacInterAct = 'T' THEN		--DSB20150429 {
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					BEGIN WORK;
				END IF;
			ELSE
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
				ELSE
					ROLLBACK WORK;
				END IF;							
			END IF;	

			LET vcodret = vsqlerr;
			RETURN vcodret, pencontro;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		LET bEnTransac = 'T';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET debug file to "/tmp/Ricardo/sp_reversafaltsob.out";
	--trace on;
	
	BEGIN WORK;
	--- Verifica recepcion correcta de datos
	IF  psucursal = '0' or psucursal = '' or pfolio_suc = '0' or pfolio_suc = '' 
	    or ptransaccion = '0' or ptransaccion = ''
	   then
	   LET vcodret = "00110";
	ELSE
		IF popcion = '1' THEN
			select plaza_cajagen into vplaza
			from   bdinteg:si_sucursales
			where  sucursal = psucursal;

			select cod_proveedor into vproveedor
			from   ss_proveedores
			where  plaza = vplaza;
			
			select COUNT(*) INTO variable from ss_proveedores where cod_proveedor = vproveedor;
			IF (variable > 0) THEN
				SELECT COUNT(*) INTO variable1 FROM ss_atm_rec WHERE cod_atm = psucursal;
				IF (variable1 > 0) THEN
					DELETE FROM ss_operaciones WHERE cod_trans = ptransaccion AND sucursal = psucursal AND folio_sucursal = pfolio_suc;
					
					SELECT saldo_anterior, saldo_total, cantidad_1, cantidad_2,cantidad_3,cantidad_4, cantidad_5, cantidad_6 
					INTO psaldo_anterior, psaldo_total, pcantidad_1, pcantidad_2, pcantidad_3, pcantidad_4, pcantidad_5, pcantidad_6
					FROM ss_atm_rec WHERE cod_atm = psucursal;
					
					UPDATE ss_atm SET saldo_anterior = psaldo_anterior, saldo_total = psaldo_total, cantidad_1 = pcantidad_1, cantidad_2 = pcantidad_2,cantidad_3 = pcantidad_3,cantidad_4 = pcantidad_4, cantidad_5 = pcantidad_5, cantidad_6 = pcantidad_6 WHERE cod_atm = psucursal;
					
					DELETE FROM ss_atm_rec WHERE cod_atm = psucursal;
					let pencontro = "00000";
				ELSE
					let vcodret = "00115";
					return vcodret,pencontro;
				END IF;
			ELSE
			   let vcodret = "00105";
			   return vcodret, pencontro;
			END IF;
		ELSE 
			IF (popcion = '2') THEN
			
				SELECT COUNT(*) INTO variable2 FROM ss_atm_rec WHERE cod_atm = psucursal;
				IF (variable2 = 0) THEN
						let pencontro = "00000";
						return vcodret,pencontro;
				END IF;
			ELSE
				DELETE FROM ss_atm_rec WHERE cod_atm = psucursal;
				let pencontro = "00000";
			END IF;
		END IF;
	END IF;

	COMMIT WORK;
	IF bTransacInterAct = 'T' THEN
		BEGIN WORK;
	END IF;

	RETURN vcodret, pencontro;
END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:FaltaATM.exe',
'AUTOR:Jesus Moreno', 
'FECHA:2019-09-24',
'DESCRIPCION: Se crea procedimiento para realizar rollback a la tabla ss_atm cuando ocurra un error en el servidor de la sucursal',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_soldocta_atm_ofi_web(
	pEmpresa  CHAR(3),
	pSucursal CHAR(4), 
	pEmpleado CHAR(8),
	pFolioSuc CHAR(16),
	pTransacc CHAR(4),
	pDivisa   CHAR(2),
	pMonto 	  MONEY(14,2),
	pFecha 	  DATE,
	pDenom1   CHAR(18),
	pDenom2   CHAR(18),
	pDenom3   CHAR(18),
	pDenom4   CHAR(18),
	pDenom5   CHAR(18),
	pDenom6   CHAR(18),
	pDenom7   CHAR(18),
	pDenom8   CHAR(18),
	pDenom9   CHAR(18),
	pDenom10  CHAR(18),
	pDenom11  CHAR(18),
	pDenom12  CHAR(18),
	pDenom13  CHAR(18),
	pDenom14  CHAR(18),
	pDenom15  CHAR(18),
	pCant1 	  FLOAT(8),
	pCant2 	  FLOAT(8),
	pCant3 	  FLOAT(8),
	pCant4 	  FLOAT(8),
	pCant5 	  FLOAT(8),
	pCant6 	  FLOAT(8),
	pCant7 	  FLOAT(8),
	pCant8 	  FLOAT(8),
	pCant9 	  FLOAT(8),
	pCant10   FLOAT(8),
	pCant11   FLOAT(8),
	pCant12   FLOAT(8),
	pCant13   FLOAT(8),
	pCant14   FLOAT(8),
	pCant15   FLOAT(8),
    pFechaEnt DATE)
RETURNING CHAR(5), CHAR(8);

	DEFINE cCodRet 	  CHAR(5);
	DEFINE cFolio 	  CHAR(8);
	DEFINE iSqlErr 	  INTEGER; 
	DEFINE iIsamErr   INTEGER;
	DEFINE cHora 	  CHAR(5);
	DEFINE cProveedor CHAR(4);
	DEFINE cPlaza 	  CHAR(3);
	DEFINE iValor 	  INTEGER;
	DEFINE iDenom1    INTEGER;
	DEFINE iDenom2    INTEGER;
	DEFINE iDenom3    INTEGER;
	DEFINE iDenom4    INTEGER;
	DEFINE iDenom5    INTEGER;
	DEFINE iDenom6    INTEGER;
	DEFINE iDenom7    INTEGER;
	DEFINE iDenom8    INTEGER;
	DEFINE iDenom9    INTEGER;
	DEFINE iDenom10   INTEGER;
	DEFINE iDenom11   INTEGER;
	DEFINE iDenom12   INTEGER;
	DEFINE iDenom13   INTEGER;
	DEFINE iDenom14   INTEGER;
	DEFINE iDenom15   INTEGER;	
	DEFINE iTotal1    INTEGER;
	DEFINE iTotal2    INTEGER;
	DEFINE iTotal3    INTEGER;
	DEFINE iTotal4    INTEGER;
	DEFINE iTotal5    INTEGER;
	DEFINE iTotal6    INTEGER;
	DEFINE iTotal7    INTEGER;
	DEFINE iTotal8    INTEGER;
	DEFINE iTotal9    INTEGER;
	DEFINE iTotal10   INTEGER;
	DEFINE iTotal11   INTEGER;
	DEFINE iTotal12   INTEGER;
	DEFINE iTotal13   INTEGER;
	DEFINE iTotal14   INTEGER;
	DEFINE iTotal15   INTEGER;
	DEFINE iSumTotal  INTEGER;
	DEFINE bTransacInterAct	CHAR(1);
	DEFINE bEnTransac CHAR(1);
    DEFINE vv  CHAR(10);
	
	LET cHora 	   = SUBSTR(CURRENT, 12, 5);
	LET cCodRet    = '00000';
	LET cProveedor = '';
	LEt cPlaza 	   = '';
	LET cFolio     = '';
	LET iValor 	   = 0;
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	LET iDenom1    = pDenom1;
	LET iDenom2    = pDenom2;
	LET iDenom3    = pDenom3;
	LET iDenom4    = pDenom4;
	LET iDenom5    = pDenom5;
	LET iDenom6    = pDenom6;
	LET iDenom7    = pDenom7;
	LET iDenom8    = pDenom8;
	LET iDenom9    = pDenom9;
	LET iDenom10   = pDenom10;
	LET iDenom11   = pDenom11;
	LET iDenom12   = pDenom12;
	LET iDenom13   = pDenom13;
	LET iDenom14   = pDenom14;
	LET iDenom15   = pDenom15;
	LET iTotal1    = 0;
	LET iTotal2    = 0;
	LET iTotal3    = 0;
	LET iTotal4    = 0;
	LET iTotal5    = 0;
	LET iTotal6    = 0;
	LET iTotal7    = 0;
	LET iTotal8    = 0;
	LET iTotal9    = 0;
	LET iTotal10   = 0;
	LET iTotal11   = 0;
	LET iTotal12   = 0;
	LET iTotal13   = 0;
	LET iTotal14   = 0;
	LET iTotal15   = 0;
	LET iSumTotal  = 0;
	LET bTransacInterAct = 'F';
	LET bEnTransac = 'F';
    LET vv = '';

	BEGIN	
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				IF bTransacInterAct = 'T' THEN		--DSB20150429 {
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						BEGIN WORK;
					END IF;
				ELSE
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
					END IF;							
				END IF;	
				LET cCodRet = iSqlErr;
				--ROLLBACK;
				RETURN cCodRet, cFolio;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		COMMIT WORK;
		BEGIN WORK;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	--	SET DEBUG FILE TO '/tmp/log_soldocta.out';
	--	TRACE ON;
		
		BEGIN WORK;
	
		--VALIDA LA RECEPCION DE LOS DATOS
		IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
			pSucursal = '0' OR pSucursal = '' OR
			pDivisa   = '0' OR pDivisa   = '' OR 
			pEmpleado = '0' OR pEmpleado = '' OR 
			pFolioSuc = '0' OR pFolioSuc = '' OR 
			pTransacc = '0' OR pTransacc = '' OR 
			pMonto    = 0                     THEN 
			LET cCodRet = '00110';
		
		ELSE
			
			IF iDenom1 IS NULL OR iDenom1 = '' THEN
				LET iDenom1 = 0;
			END IF;
			IF iDenom2 IS NULL OR iDenom2 = '' THEN
				LET iDenom2 = 0;
			END IF;
			IF iDenom3 IS NULL OR iDenom3 = '' THEN
				LET iDenom3 = 0;
			END IF;
			IF iDenom4 IS NULL OR iDenom4 = '' THEN
				LET iDenom4 = 0;
			END IF;
			IF iDenom5 IS NULL OR iDenom5 = '' THEN
				LET iDenom5 = 0;
			END IF;
			IF iDenom6 IS NULL OR iDenom6 = '' THEN
				LET iDenom6 = 0;
			END IF;
			IF iDenom7 IS NULL OR iDenom7 = '' THEN
				LET iDenom7 = 0;
			END IF;
			IF iDenom8 IS NULL OR iDenom8 = '' THEN
				LET iDenom8 = 0;
			END IF;
			IF iDenom9 IS NULL OR iDenom9 = '' THEN
				LET iDenom9 = 0;
			END IF;
			IF iDenom10 IS NULL OR iDenom10 = '' THEN
				LET iDenom10 = 0;
			END IF;
			IF iDenom11 IS NULL OR iDenom11 = '' THEN
				LET iDenom11 = 0;
			END IF;
			IF iDenom12 IS NULL OR iDenom12 = '' THEN
				LET iDenom12 = 0;
			END IF;
			IF iDenom13 IS NULL OR iDenom13 = '' THEN
				LET iDenom13 = 0;
			END IF;
			IF iDenom14 IS NULL OR iDenom14 = '' THEN
				LET iDenom14 = 0;
			END IF;
			IF iDenom15 IS NULL OR iDenom15 = '' THEN
				LET iDenom15 = 0;
			END IF;
			
			LET iTotal1	   = iDenom1  * pCant1;
			LET iTotal2	   = iDenom2  * pCant2;
			LET iTotal3	   = iDenom3  * pCant3;
			LET iTotal4	   = iDenom4  * pCant4;
			LET iTotal5	   = iDenom5  * pCant5;
			LET iTotal6	   = iDenom6  * pCant6;
			LET iTotal7	   = iDenom7  * pCant7;
			LET iTotal8	   = iDenom8  * pCant8;
			LET iTotal9	   = iDenom9  * pCant9;
			LET iTotal10   = iDenom10 * pCant10;
			LET iTotal11   = iDenom11 * pCant11;
			LET iTotal12   = iDenom12 * pCant12;
			LET iTotal13   = iDenom13 * pCant13;
			LET iTotal14   = iDenom14 * pCant14;
			LET iTotal15   = iDenom15 * pCant15;
			LET iSumTotal  = iTotal1  + iTotal2  +
							 iTotal3  + iTotal4  +
							 iTotal5  + iTotal6  +
							 iTotal7  + iTotal8  +
							 iTotal9  + iTotal10 +
							 iTotal11 + iTotal12 +
							 iTotal13 + iTotal14 +
							 iTotal15;
							 
			--VALIDA MONTO VS DESGLOSE DENOMINACIONES
			IF pMonto <> iSumTotal THEN
				LET cCodRet = '00115';
				RETURN cCodRet, cFolio;
			END IF;
			
            

    SELECT LIMIT 1 cod_trans 
    INTO vv FROM ss_operaciones a , ss_mae_entradasalida b
    WHERE a.sucursal=pSucursal 
    AND a.folio_oper=b.folio_oper
    --and folio_sucursal=pfolio_suc
    AND a.fecha_entrega=pFechaEnt
    AND b.status IN ('01','11');

    LET vv= NVL(vv,'');

    IF NOT vv = '' THEN
        Let cCodRet='00001';
        --let vfolio='';
       RETURN cCodRet, cFolio;
    END IF;

			SELECT plaza_cajagen INTO cPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
			SELECT cod_proveedor INTO cProveedor FROM bdisuc:"informix".ss_proveedores WHERE plaza = cPlaza;
		
			IF cProveedor IS NOT NULL THEN
	
				SELECT valor INTO iValor FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = '0005';

				UPDATE bdisuc:"informix".ss_param_cajagen SET valor = valor + 1 WHERE codigo = '0005';
				
				LET cFolio = LPAD(iValor, 8, '0');
				
				INSERT INTO bdisuc:"informix".ss_operaciones (empresa, cod_trans, fecha_operacion, sucursal, folio_sucursal, folio_oper, reversado, usuario, divisa, monto,
				denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15, 
				cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14, cantidad_15,fecha_entrega)
				VALUES (pEmpresa, pTransacc, pFecha, pSucursal, pFolioSuc, cFolio, '0', pEmpleado, pDivisa, pMonto,
				pDenom1, pDenom2, pDenom3, pDenom4, pDenom5, pDenom6, pDenom7, pDenom8, pDenom9, pDenom10, pDenom11, pDenom12, pDenom13, pDenom14, pDenom15, 
				pCant1, pCant2, pCant3, pCant4, pCant5, pCant6, pCant7, pCant8, pCant9, pCant10, pCant11, pCant12, pCant13, pCant14, pCant15,pFechaEnt);
				
				INSERT INTO bdisuc:"informix".ss_mae_entradasalida (empresa, cod_proveedor, folio_oper, sucursal, folio_sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, status, monto)
				VALUES (pEmpresa, cProveedor, cFolio, pSucursal, pFolioSuc, pFecha, cHora, pEmpleado, '01', pMonto);
				
			ELSE
				LET cCodRet = '00105';
				RETURN cCodRet, cFolio;
			END IF;
		END IF;
		
		COMMIT WORK;
		IF bTransacInterAct = 'T' THEN
			BEGIN WORK;
		END IF;
	
		RETURN cCodRet, cFolio;
	END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:DotaCG.exe',
'AUTOR:Jesus Moreno', 
'FECHA:2019-09-20',
'DESCRIPCION: Se modifica procedimiento para realiza rollback',
'SOLICITA: Gabriela Angulo',
'Modificado Por: DR Rorro';

CREATE PROCEDURE "informix".sp_traeinffolio_web(pempresa CHAR(3), pFolio CHAR(20))

	RETURNING CHAR(5), CHAR(20), CHAR(20), DATE;

	DEFINE vcodret 		CHAR(5);
	DEFINE vsqlerr 		INTEGER;
	DEFINE cOperador 	CHAR(20);
	DEFINE cMonto 		CHAR(20);
	DEFINE cfecha 		DATE;

	LET vcodret = "000";
	LET vsqlerr = 0;
	LET cOperador='';
	LET cMonto='';
	LET cfecha='';

BEGIN
	ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret='00001';
				Return vcodret, cOperador,cMonto,cfecha;
			END IF;	
	END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT usuario_recepcion, monto , fecha_recepcion 
	INTO cOperador,cMonto,cfecha
	FROM bdisuc:ss_mae_entradasalida 
	WHERE folio_oper = pFolio;

	LET cOperador = NVL(cOperador,'');

	IF cOperador='' THEN
		Let vcodret = '00002';
		RETURN vcodret, cOperador,cMonto,cfecha;
	END IF;

	RETURN vcodret, cOperador,cMonto,cfecha;

END
END PROCEDURE;