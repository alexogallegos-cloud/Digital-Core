CREATE PROCEDURE "informix".sp_reversa_soldocta(pEmpresa CHAR(3),pSucursal CHAR(4),pFolio_ope char(8))

 --DATOS A REGRESAR---	
	RETURNING CHAR(5) AS CodRetorno 	--codret
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE tIniciada CHAR(1);
    ---------------------------

	LET cCodRet = '00000';
	LET tIniciada = '0';
	
	--SET DEBUG FILE TO "/tmp/Cris/sp_reversa_soldocta.out";
	--TRACE ON;	

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			IF (tIniciada = '1') THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;	
			
			RETURN cCodRet; 			
		
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
		   LET tIniciada = '1';
		END EXCEPTION WITH RESUME;
				
		LET tIniciada = '1';
		BEGIN WORK;
		
			IF (pEmpresa = '' OR pEmpresa IS NULL) OR (pSucursal = '' OR pSucursal IS NULL) OR (pFolio_ope = '' OR pFolio_ope IS NULL) THEN
				LET cCodRet = '00001'; --ParÃ¡metros incorrectos
			ELSE
				DELETE FROM ss_operaciones 
				WHERE empresa = pEmpresa
				AND folio_oper = pFolio_ope
				AND sucursal = pSucursal;
				
				DELETE FROM ss_mae_entradasalida
				WHERE empresa = pEmpresa
				AND folio_oper = pFolio_ope
				AND sucursal = pSucursal; 	--Se borra registro ss_mae_entradasalida			
			END IF;
			
		COMMIT WORK;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:DotaCG.exe',
'AUTOR:Cristian Valentina Aguilar ', 
'FECHA:2019-09-20',
'DESCRIPCIÃ?N: Se genera procedimiento para realizar el reverso a la dotaciÃ³n, para eliminar la transacciÃ³n en caso de algÃºn error en sucursal se de reverso en el servidor central.' ,
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_reversafaltsob(psucursal CHAR(4),
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
LET vcodret = "000";
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
LET pencontro = '001';
	
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
	   LET vcodret = "110";
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
					let pencontro = "000";
				ELSE
					let vcodret = "115";
					return vcodret,pencontro;
				END IF;
			ELSE
			   let vcodret = "105";
			   return vcodret, pencontro;
			END IF;
		ELSE 
			IF (popcion = '2') THEN
			
				SELECT COUNT(*) INTO variable2 FROM ss_atm_rec WHERE cod_atm = psucursal;
				IF (variable2 = 0) THEN
						let pencontro = "000";
						return vcodret,pencontro;
				END IF;
			ELSE
				DELETE FROM ss_atm_rec WHERE cod_atm = psucursal;
				let pencontro = "000";
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
'DESCRIPCIÓN: Se crea procedimiento para realizar rollback a la tabla ss_atm cuando ocurra un error en el servidor de la sucursal',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_soldocta(
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
	pCant15   FLOAT(8))
	
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
		
		--SET DEBUG FILE TO '/tmp/Ricardo/log_soldocta.out';
		--TRACE ON;
		
		BEGIN WORK;
	
		--VALIDA LA RECEPCION DE LOS DATOS
		IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
			pSucursal = '0' OR pSucursal = '' OR
			pDivisa   = '0' OR pDivisa   = '' OR 
			pEmpleado = '0' OR pEmpleado = '' OR 
			pFolioSuc = '0' OR pFolioSuc = '' OR 
			pTransacc = '0' OR pTransacc = '' OR 
			pMonto    = 0                     THEN 
			LET cCodRet = '110';
		
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
			
			SELECT plaza_cajagen INTO cPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;

			SELECT cod_proveedor INTO cProveedor FROM bdisuc:"informix".ss_proveedores WHERE plaza = cPlaza;
		
			IF cProveedor IS NOT NULL THEN
				
				SELECT valor INTO iValor FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = '0005';

				UPDATE bdisuc:"informix".ss_param_cajagen SET valor = valor + 1 WHERE codigo = '0005';
				
				LET cFolio = LPAD(iValor, 8, '0');
				
				INSERT INTO bdisuc:"informix".ss_operaciones (empresa, cod_trans, fecha_operacion, sucursal, folio_sucursal, folio_oper, reversado, usuario, divisa, monto,
				denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15, 
				cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14, cantidad_15)
				VALUES (pEmpresa, pTransacc, pFecha, pSucursal, pFolioSuc, cFolio, '0', pEmpleado, pDivisa, pMonto,
				pDenom1, pDenom2, pDenom3, pDenom4, pDenom5, pDenom6, pDenom7, pDenom8, pDenom9, pDenom10, pDenom11, pDenom12, pDenom13, pDenom14, pDenom15, 
				pCant1, pCant2, pCant3, pCant4, pCant5, pCant6, pCant7, pCant8, pCant9, pCant10, pCant11, pCant12, pCant13, pCant14, pCant15);
				
				INSERT INTO bdisuc:"informix".ss_mae_entradasalida (empresa, cod_proveedor, folio_oper, sucursal, folio_sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, status, monto)
				VALUES (pEmpresa, cProveedor, cFolio, pSucursal, pFolioSuc, pFecha, cHora, pEmpleado, '01', pMonto);
				
			ELSE
				LET cCodRet = '105';
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
'DESCRIPCIÃ?N: Se modifica procedimiento para realiza rollback',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_atms2(pempresa   CHAR(3),
                                    psucursal  CHAR(4),
                                    pregistro  SMALLINT,
									pRegistros INTEGER, 
									pRecuperacion INTEGER)

RETURNING CHAR(5),CHAR(4),CHAR(100);

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vnumatm          CHAR(4);
DEFINE vnombreatm       CHAR(100);
 
LET vcodret    = "000";
LET vnumatm    = "";
LET vnombreatm = "";

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vnumatm,vnombreatm;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_atms2.out";
--trace on;

    IF pempresa = '0' or pempresa = '' or  psucursal = '0' or psucursal = '' then
          LET vcodret = "110";
    END IF;

    FOREACH
        SELECT SKIP pRegistros FIRST pRecuperacion s.sucursal,s.nombre
        INTO vnumatm, vnombreatm
        FROM bdisuc:"informix".ss_atms_sucursal a, bdinteg:"informix".si_sucursales s
        WHERE s.sucursal = a.cod_atm  
          AND s.empresa = pempresa
          /*AND a.sucursal = psucursal    */       
        ORDER BY s.nombre

        RETURN vCodRet,vnumatm,vnombreatm  WITH resume;

    END FOREACH;
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 27/10/2016',
'DESCRIPCION: Se crea SPL clon para el tratado de la paginación.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consul_atm2(eEmpresa    CHAR(3),
                                          eFecha      DATE,
                                          eFecFin     DATE,
                                          eFolioOper  CHAR(8),
                                          eSucursal   CHAR(4),
                                          eCodTras    CHAR(4),
                                          eTipo       CHAR(1), --S = Sucursal C = Cajero
										  pRegistros INTEGER, 
										  pRecuperacion INTEGER) 

RETURNING CHAR(5),             --CodRet
          CHAR(50),            --Sucursal
          DATE,                --Fec.Operacion
          CHAR(4),             --CodTran
          CHAR(1),             --Reversado
          CHAR(40),            --Usuario
          CHAR(40),            --Divisa
          MONEY(14,2),         --Monto
          FLOAT,               --Cantidad1
          FLOAT,               --Cantidad2
          FLOAT,               --Cantidad3
          FLOAT,               --Cantidad4
          FLOAT,               --Cantidad5
          FLOAT,               --Cantidad6
          FLOAT,               --Cantidad7
          FLOAT,               --Cantidad8
          FLOAT,               --Cantidad9
          FLOAT,               --Cantidad10
          FLOAT,               --Cantidad11
          FLOAT,               --Cantidad12
          FLOAT,               --Cantidad13
          FLOAT,               --Cantidad14
          FLOAT,               --Cantidad15
          CHAR(16),            --Folio Sucursal
          CHAR(8),             --Folio Oper
          CHAR(4),             --Procedencia
          CHAR(40),            --Proveedor
          CHAR(40),            --CodTrans
          DATE,		       -- Fecha Recepcion
          CHAR(5),	       -- Hora Recepcion
          CHAR(8);	       -- Usuario Recepcion

 DEFINE vCodRet       CHAR(5);
 DEFINE vSucursal     CHAR(4);
 DEFINE vFecOperacion DATE;
 DEFINE vCodTrans     CHAR(4);
 DEFINE vReversado    CHAR(1);
 DEFINE vUsuario      CHAR(8);
 DEFINE vDivisa       CHAR(2);
 DEFINE vMonto        MONEY(14,2);
 DEFINE vCant1        FLOAT;
 DEFINE vCant2        FLOAT;
 DEFINE vCant3        FLOAT;
 DEFINE vCant4        FLOAT;
 DEFINE vCant5        FLOAT;
 DEFINE vCant6        FLOAT;
 DEFINE vCant7        FLOAT;
 DEFINE vCant8        FLOAT;
 DEFINE vCant9        FLOAT;
 DEFINE vCant10       FLOAT;
 DEFINE vCant11       FLOAT;
 DEFINE vCant12       FLOAT;
 DEFINE vCant13       FLOAT;
 DEFINE vCant14       FLOAT;
 DEFINE vCant15       FLOAT;
 DEFINE vFolSuc       CHAR(16);
 DEFINE vFolOper      CHAR(8);
 DEFINE vProcedencia  CHAR(4);
 DEFINE vNomSuc       CHAR(40);
 DEFINE vNomProv      CHAR(40);
 DEFINE vNomUsuario   CHAR(40);
 DEFINE vDesDivisa    CHAR(40);
 DEFINE vPlazaGen     CHAR(3);
 DEFINE vDesTran      CHAR(40);
 DEFINE vPlaza        CHAR(3);
 DEFINE vFecRecep     DATE;
 DEFINE vHoraRecep    CHAR(5);
 DEFINE vUserRecep    CHAR(8);

 SET LOCK MODE TO WAIT 3;
 SET ISOLATION TO DIRTY READ; 

 LET vCodRet       = "000";
 LET vSucursal     = '';
 LET vFecOperacion = '';
 LET vCodTrans     = '';
 LET vReversado    = '';
 LET vUsuario      = '';
 LET vDivisa       = '';
 LET vMonto        = 0;
 LET vCant1        = 0;
 LET vCant2        = 0;
 LET vCant3        = 0;
 LET vCant4        = 0;
 LET vCant5        = 0;
 LET vCant6        = 0;
 LET vCant7        = 0;
 LET vCant8        = 0;
 LET vCant9        = 0;
 LET vCant10       = 0;
 LET vCant11       = 0;
 LET vCant12       = 0;
 LET vCant13       = 0;
 LET vCant14       = 0;
 LET vCant15       = 0;
 LET vFolSuc       = '';
 LET vFolOper      = '';
 LET vProcedencia  = '';
 LET vNomSuc       = '';
 LET vNomProv      = '';
 LET vNomUsuario   = '';
 LET vDesDivisa    = '';
 LET vPlazaGen     = '';
 LET vDesTran      = '';
 LET vPlaza        = '';
 LET vFecRecep     = ''; 
 LET vHoraRecep    = '';
 LET vUserRecep    = '';
 LET eFecha   = eFecha;
 LET eFecFin  = eFecFin;
 LET eFolioOper= eFolioOper;
 LET eSucursal = eSucursal;
 LET eCodTras = eCodTras;
 LET eTipo    =eTipo;

 --SET DEBUG FILE TO "/tmp/mfinis/sp_consul_atm2.out";
 --TRACE ON;

 IF (eCodTras IS NOT NULL OR eCodTras <> '') AND (eSucursal IS NOT NULL OR eSucursal <> '') THEN
 
	IF eSucursal='0000' THEN
		FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion sucursal, fecha_operacion , cod_trans     , reversado  , usuario     ,
					   divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
					   cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
					   cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
					   cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
				INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
					  vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
					  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
					  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
					  vFolOper      , vProcedencia
				FROM  bdisuc:"informix".ss_operaciones
				WHERE cod_trans = eCodTras
				  AND fecha_operacion between eFecha AND eFecFin 
				  AND reversado IN ('0','1','S','N')
				ORDER BY fecha_operacion desc,sucursal,cod_trans desc

				SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
				SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;
				SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;
				SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;
				SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;
			
				SELECT fecha_recepcion,hora_recepcion,usuario_recepcion
				INTO   vFecRecep,vHoraRecep,vUserRecep
				FROM   bdisuc:"informix".ss_mae_entradasalida
				WHERE  folio_oper = vFolOper;

				IF vFecRecep IS NULL THEN
					LET vFecRecep = '';
					LET vHoraRecep = '';
					LET vUserRecep = '';
				END IF;

				RETURN vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
					   vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
					   vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
					   vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
					   vFolOper      , vProcedencia  , vNomProv      ,vDesTran       , vFecRecep     , vHoraRecep    , vUserRecep WITH RESUME;
		END FOREACH;
					
			
	ELSE	
		
		FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
					   divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
					   cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
					   cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
					   cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
				INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
					  vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
					  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
					  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
					  vFolOper      , vProcedencia
				FROM  bdisuc:"informix".ss_operaciones
				WHERE cod_trans = eCodTras
				  AND fecha_operacion between eFecha AND eFecFin 
				  AND sucursal = eSucursal
				  AND reversado IN ('0','1','S','N')
				ORDER BY fecha_operacion desc,sucursal,cod_trans desc

				SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
				SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;
				SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;
				SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;
				SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;
			
				SELECT fecha_recepcion,hora_recepcion,usuario_recepcion
				INTO   vFecRecep,vHoraRecep,vUserRecep
				FROM   bdisuc:"informix".ss_mae_entradasalida
				WHERE  folio_oper = vFolOper;

				IF vFecRecep IS NULL THEN
					LET vFecRecep = '';
					LET vHoraRecep = '';
					LET vUserRecep = '';
				END IF;

				RETURN vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
					   vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
					   vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
					   vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
					   vFolOper      , vProcedencia  , vNomProv      ,vDesTran       , vFecRecep     , vHoraRecep    , vUserRecep WITH RESUME;
		 END FOREACH;
	 END IF;		 
 END IF;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 27/10/2016',
'DESCRIPCION: Se crea SPL clon para el tratado de la paginación.',
'AUTOR: Humberto Lizarraga',
'FECHA 06/03/2017',
'DESCRIPCION: Se modificaron los procedimientos almacenados para la consulta de las operaciones donde sucursal sea igual a "Todos" donde se envía por parámetro el valor "0000" a los mismos.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consul_atm2_totales(eEmpresa    CHAR(3),
                                          eFecha      DATE,
                                          eFecFin     DATE,
                                          eFolioOper  CHAR(8),
                                          eSucursal   CHAR(4),
                                          eCodTras    CHAR(4),
                                          eTipo       CHAR(1)) --S = Sucursal C = Cajero
										  
RETURNING CHAR(5),         --CodRet
          INTEGER;	       -- Numero de registros

 DEFINE vCodRet       CHAR(5);
 DEFINE iNumRegistros INTEGER;

 --SET LOCK MODE TO WAIT 3;
 --SET ISOLATION TO DIRTY READ; 

 LET vCodRet       = "000";
 LET iNumRegistros = 0;

 --SET DEBUG FILE TO "/tmp/mfinis/sp_consul_atm2_totales.out";
 --TRACE ON;

 IF (eCodTras IS NOT NULL OR eCodTras <> '') AND (eSucursal IS NOT NULL OR eSucursal <> '') THEN
 
   IF eSucursal='0000' THEN
			SELECT COUNT(*)
			INTO  iNumRegistros
			FROM  bdisuc:"informix".ss_operaciones
			WHERE cod_trans = eCodTras
			  AND fecha_operacion between eFecha AND eFecFin 
			  AND reversado IN ('0','1','S','N');

		RETURN vCodRet, iNumRegistros;
   
   
   ELSE
			SELECT COUNT(*)
			INTO  iNumRegistros
			FROM  bdisuc:"informix".ss_operaciones
			WHERE cod_trans = eCodTras
			  AND fecha_operacion between eFecha AND eFecFin 
			  AND sucursal = eSucursal
			  AND reversado IN ('0','1','S','N');

		RETURN vCodRet, iNumRegistros;
	END IF;
 END IF;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 27/10/2016',
'DESCRIPCION: Se crea SPL clon para consultar el número total de registros.',
'AUTOR: Humberto Lizarraga',
'FECHA 06/03/2017',
'DESCRIPCION: Se modificaron los procedimientos almacenados para la consulta de las operaciones donde sucursal sea igual a "Todos" donde se envía por parámetro el valor "0000" a los mismos.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_reversadotacg(folioOper CHAR (8),cSucursal CHAR(4),Cantidad MONEY (14,2))
RETURNING
CHAR(5) AS cCodRet;

--*DEFINICION DE VARIABLES*--
DEFINE cCodRet				  CHAR (5);
DEFINE cSqlErr				  SMALLINT;
DEFINE valStatus        	  CHAR (2);

--*ASIGNACION DE VARIABLES*--
LET cSqlErr					= 0;
LET valStatus               ='';

BEGIN
	------------------------
	--*CONTROL DE ERRORES*--
	------------------------
	ON EXCEPTION SET cSqlErr
		IF cSqlErr <> 0 THEN
			let cCodRet = cSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET debug file to "/tmp/hector/sp_reversadotacg.out";
	--trace on;
	
		--*SE VALIDA LOS PARAMETROS DE ENTRADA*--
		IF NVL(TRIM(folioOper),'')= '' OR NVL(TRIM(cSucursal),'')= '' OR Cantidad  IS NULL OR Cantidad <= 0.00 OR Cantidad = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;
			--*SE OBTIENE EL FOLIO DE LA DOTACION*--
			SELECT status INTO valStatus
			FROM bdisuc:ss_mae_entradasalida 
			WHERE folio_oper = folioOper 
			AND sucursal = cSucursal 
			AND monto = Cantidad;
					   
		
		--*SE VALIDA SI EXISTE REGISTRO COMO PAGADO
		IF valStatus = '05' THEN
		   
				UPDATE bdisuc:ss_mae_entradasalida 
				SET status = '11'  
				WHERE folio_oper = folioOper 
				AND sucursal = cSucursal 
				AND monto = Cantidad 
				AND status = '05';
				
				LET cCodRet = '00000'; 
		ELIF valStatus = '11' THEN
				LET cCodRet = '00000'; 
		ELSE
			LET cCodRet = '00002'; --*OCURRIO UN ERROR AL OBTENER EL FOLIO DE OPERACION*--
		END IF;
		RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR:			98467379-Hector Hazael Aguilar Arteaga',
'PROCEDIMIENTO: Procedimiento realizara una actualizacion del status 5 "PAGADA" a status 11 "LISTA PARA PAGARSE" en la tabla ss_mae_entradasalida',
'				debido a la incidencia que ocurria cuando por algun error no controlado como por ejemplo el error "24 TimeOut" quedan descuadrados los datos',
'				en sucursal y central provocando no poder realizar el flujo de la dotacion correctamente',				
'SOLICITO: 		Cutberto GonzÃ¡lez PÃ©rez',
'BD:            bdisuc',
'FOLIO:			1918-INC_DOTACION_CAJA_GENERAL';

CREATE PROCEDURE "informix".sp_dotatm_2(pempresa CHAR(3),
        	          	              pfolio   CHAR(8)) 

RETURNING CHAR(5),CHAR(4),MONEY(14,2);

DEFINE vcodret           CHAR(5);
DEFINE vsqlerr,visamerr  INTEGER;
DEFINE vstatus           CHAR(2);
DEFINE vsucursal	 CHAR(4);
DEFINE vmonto		 MONEY(14,2);
DEFINE vreversado	 CHAR(1);

LET vcodret    = "000";
LET vsucursal  = "";
LET vmonto	   = 0;
LET vreversado = "";
LET vstatus    = "";

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ; 

BEGIN

    ON EXCEPTION SET vsqlerr,visamerr
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            RETURN vCodRet,vsucursal,vmonto;
        END IF;
    END EXCEPTION;

    --SET debug file to "/tmp/sp_dotatm_2.out";
    --trace on;

    --- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR pfolio = '0' OR pfolio = '' THEN 
        LET vcodret = "110";
    ELSE
        SELECT m.status,o.sucursal,o.monto,o.reversado
          INTO vstatus,vsucursal,vmonto,vreversado
          FROM bdisuc:"informix".ss_operaciones as o, bdisuc:"informix".ss_mae_entradasalida as m
         WHERE o.folio_oper = pfolio
		   AND o.folio_oper = m.folio_oper 
           AND o.reversado = 0;

		IF vstatus IS NULL THEN
            LET vCodRet = "100";
		ELSE
	        IF vstatus != "11" THEN
	            LET vCodRet = "104";
	        END IF

	        IF vstatus IN ("05","13") THEN
	            LET vCodRet = "107";
	        END IF;
		END IF

        RETURN vCodRet,vsucursal,vmonto;

    END IF;
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/12/2019',
'DESCRIPCION: Se realiza clonación del procedimiento productivo sp_dotatm para mantener versión anterior.';

CREATE PROCEDURE "informix".sp_inserta_atm_2(pempresa CHAR(3),
                                           pcod_atm CHAR(4), 
                                           pdivisa  CHAR(2), 
                                           pcant_1  FLOAT,
                                           pcant_2  FLOAT,
                                           pcant_3  FLOAT,
                                           pcant_4  FLOAT,
                                           pcant_5  FLOAT,
                                           pcant_6  FLOAT,
                                           pmonto   DECIMAL(14,2))
RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;

DEFINE vden01 CHAR(5);
DEFINE vden02 CHAR(5);
DEFINE vden03 CHAR(5);
DEFINE vden04 CHAR(5);
DEFINE vden05 CHAR(5);
DEFINE vden06 CHAR(5);
DEFINE vden07 CHAR(5);
DEFINE vSaldo_ant MONEY (14,2);
DEFINE vSaldo_asi MONEY (14,2);
DEFINE vSaldo_tot MONEY (14,2);

LET vcodret = "000";
LET vsqlerr = 0;
LET vden01 = "";
LET vden02 = "";
LET vden03 = "";
LET vden04 = "";
LET vden05 = "";
LET vden06 = "";
LET vden07 = "";
LET vSaldo_ant = "";
LET vSaldo_asi = "";
LET vSaldo_tot = "";

SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;


    --SET debug file to "/tmp/sp_inserta_atm_2.out";
    --trace on;

    IF EXISTS (SELECT cod_atm FROM bdisuc:"informix".ss_atm WHERE cod_atm = pcod_atm) THEN

        UPDATE bdisuc:"informix".ss_atm SET cantidad_1 = cantidad_1 + pcant_1,cantidad_2 = cantidad_2 + pcant_2,cantidad_3 = cantidad_3 + pcant_3,
                          cantidad_4 = cantidad_4 + pcant_4,cantidad_5 = cantidad_5 + pcant_5,cantidad_6 = cantidad_6 + pcant_6,
                          saldo_anterior = saldo_total,saldo_asignado = 0,saldo_total = saldo_total + pmonto
        WHERE empresa = pempresa AND cod_atm = pcod_atm;

    ELSE
		LET vden01 = '1000';
        LET vden02 = '500';
        LET vden03 = '200';
        LET vden04 = '100';
        LET vden05 = '50';
        LET vden06 = '20';
        LET vden07 = '-1';
        
        INSERT INTO bdisuc:"informix".ss_atm (empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,
                            denominacion_4,denominacion_5,denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,
                            denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,
                            cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
                            cantidad_13,cantidad_14,cantidad_15)
        VALUES (pempresa, pcod_atm, pdivisa, 0, 0,pmonto,vden01, vden02, vden03, vden04, vden05, vden06,vden07,0,0,0,0,0,0,0,0,pcant_1,
                pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,'0','0','0','0','0','0','0','0','0');
    END IF;

    RETURN vcodret;

END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/12/2019',
'DESCRIPCION: Se realiza clonación del procedimiento productivo sp_inserta_atm para mantener versión anterior.';

CREATE PROCEDURE "informix".sp_concensuc_web(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto_dot money(14,2),
        pfecha  date,
		pdeno1  CHAR(18),
		pdeno2  CHAR(18),
		pdeno3  CHAR(18),
		pdeno4  CHAR(18),
        pdeno5  CHAR(18),
		pdeno6  CHAR(18),
		pdeno7  CHAR(18),
		pdeno8  CHAR(18),
		pdeno9  CHAR(18),
		pdeno10 CHAR(18),
        pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1  float(8),
		pcant2  float(8),
		pcant3  float(8),
		pcant4  float(8),
		pcant5  float(8),
		pcant6  float(8),
		pcant7  float(8),
		pcant8  float(8),
		pcant9  float(8),
        pcant10 float(8),
		pcant11 float(8),
		pcant12 float(8),
		pcant13 float(8),
		pcant14 float(8),
		pcant15 float(8),
        pfolio char(16))


RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum INTEGER;
DEFINE vmonto money(14,2);

LET vcodret = "00000";
LET vfolio = "";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vmonto = 0;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/informix/c96105143/concensuc.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio = '' then
   LET vcodret = "00110";
ELSE

   set isolation to dirty read; 
   SET LOCK MODE TO WAIT 3;

   
   select FIRST 1 o.folio_oper,o.monto
     into vfolio, vmonto
   	from bdisuc:ss_operaciones o, bdisuc:ss_mae_entradasalida m
  	where o.folio_oper = m.folio_oper
    AND o.fecha_operacion = pfecha
    AND o.sucursal = psucursal
    AND o.cod_trans = ptransaccion
    AND o.reversado = 0
    AND m.folio_servicio = pfolio;

    if (vmonto is null) then let vmonto = 0; end if; 

    IF vfolio IS NOT NULL AND vmonto <> pmonto_dot THEN
         LET vcodret = "00109";
        RETURN vcodret,vfolio;
    END IF;

    IF vfolio IS NOT NULL AND vmonto = pmonto_dot AND pmonto_dot > 0 THEN
        UPDATE bdisuc:"informix".ss_operaciones
        SET  cod_trans = ptransaccion,
             folio_sucursal = pfolio_suc,
             denominacion_1 = pdeno1, denominacion_2 = pdeno2, denominacion_3 = pdeno3,
             denominacion_4 = pdeno4, denominacion_5 = pdeno5, denominacion_6 = pdeno6,
             denominacion_7 = pdeno7, denominacion_8 = pdeno8, denominacion_9 = pdeno9,
             denominacion_10= pdeno10,denominacion_11= pdeno11,denominacion_12= pdeno12,
             denominacion_13= pdeno13,denominacion_14= pdeno14,denominacion_15= pdeno15,
             cantidad_1 = pcant1, cantidad_2 = pcant2, cantidad_3 = pcant3,
             cantidad_4 = pcant4, cantidad_5 = pcant5, cantidad_6 = pcant6,
             cantidad_7 = pcant7, cantidad_8 = pcant8, cantidad_9 = pcant9,
             cantidad_10 = pcant10,cantidad_11 = pcant11,cantidad_12 = pcant12,
             cantidad_13 = pcant13,cantidad_14 = pcant14,cantidad_15 = pcant15
	WHERE   empresa = pempresa 
    	and     folio_oper= vfolio;

        UPDATE bdisuc:"informix".ss_mae_entradasalida
        SET  folio_sucursal = pfolio_suc,
             fecha_solicitud = pfecha,
             hora_solicitud = vhora,
             usuario_solicitud = pcajeroprincipal,
             hora_envio = vhora,
             usuario_envio = pcajeroprincipal
	WHERE empresa = pempresa
    	and   folio_oper = vfolio;
        RETURN vcodret,vfolio;

    ELSE

   	select s.plaza_cajagen,p.cod_proveedor
 	into vplaza, vproveedor
	from bdisuc:ss_proveedores p, bdinteg:si_sucursales s
	where p.plaza = s.plaza_cajagen
	and s.empresa = pempresa
	and s.sucursal = psucursal;


    	if ( vmonto = 0 ) then
        select valor into vnum
        from   ss_param_cajagen
        where  codigo = '0005';

        update ss_param_cajagen
        set    valor = valor + 1
        where  codigo = '0005';

        let vfolio = lpad(vnum,8,"0");

        INSERT INTO bdisuc:"informix".ss_operaciones
          (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
               denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
               denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
               denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
               cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
               cantidad_13,cantidad_14,cantidad_15)
        VALUES
              (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
               pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
           pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
           pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

        INSERT INTO bdisuc:"informix".ss_mae_entradasalida
               (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,
                fecha_solicitud,hora_solicitud,usuario_solicitud,
                fecha_envio,hora_envio,usuario_envio,
                status,monto,folio_servicio)
        VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,
                pfecha,vhora,pcajeroprincipal,
                pfecha,vhora,pcajeroprincipal,
                '06',pmonto_dot,pfolio);

    end if;

    END IF;

END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;