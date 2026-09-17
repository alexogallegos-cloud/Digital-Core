CREATE PROCEDURE "informix".sp_obtenerparametro(pCodigoParametro CHAR(20))
RETURNING CHAR(5),CHAR(60),CHAR(60);

	DEFINE	cCodRet 			CHAR(5);
	DEFINE	cDescripcionParam 	CHAR(60);
	DEFINE	cValorParam			CHAR(60);
	DEFINE	iSQLerr				INTEGER;
	DEFINE	iExiste				INTEGER;

        LET cCodRet 			= '00000';
	LET cDescripcionParam	= '';
	LET cValorParam			= '';
	LET iSQLerr				= 0;
	LET iExiste				= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
       ON EXCEPTION SET iSQLerr
	      IF iSQLerr <> 0 THEN
	          LET cCodRet = iSQLerr;
	          RETURN cCodRet,cValorParam,cDescripcionParam;
	     END IF;
        END EXCEPTION;

         --SET DEBUG FILE TO "/respaldosbd/saul/sp_obtenerparametro.out";
         --TRACE ON;	
    	
       CALL sp_ConsultaValorParametro(pCodigoParametro)
       RETURNING cCodRet, cValorParam, cDescripcionParam;
       
	RETURN cCodRet,cValorParam,cDescripcionParam;
  END
END PROCEDURE
DOCUMENT
'AUTOR: Saúl Ivanhoe Valdespino Hernández',
'Descripcion: Ejecuta sp que Consulta los parametros encontrados en la sc_param,',
'Fecha: 2010/07/21',
'Version: 20100721.1215',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_mini21(pEmpresa CHAR(3), pUsuario CHAR(8),pSucursal CHAR(4), pFoliosuc CHAR(16))

		  
RETURNING CHAR(5) 	  AS Cod_Ret,
		  CHAR(2) 	  AS Moneda,
		  MONEY(16,2) AS Monto_Serv,
		  MONEY(16,2) AS Monto_cargoserv,
		  CHAR(40)    AS Descripcion,
          INTEGER	  AS Movto_serv,
		  INTEGER	  AS Movto_cargoserv;
	
	DEFINE mMontoServ       MONEY(16,2);
	DEFINE mMontoCargoServ  MONEY(16,2);	
	DEFINE iMovtoServ       INTEGER;
	DEFINE iMovtoCargoServ  INTEGER;
    DEFINE cDescripcion     CHAR(40); 
    DEFINE cCodRet          CHAR(5);  	
    DEFINE cMoneda          CHAR(2);   
    DEFINE iSqlErr          INTEGER;  	
    DEFINE dFecha           DATE;
	DEFINE mMontoCargoCred  MONEY(16,2);	
	DEFINE iMovtoCargoCred  INTEGER;
	DEFINE cTransaccSuc 	CHAR(4);
	--2013.08.09 FRG-I.
	DEFINE cTransaccSdoFav 	CHAR(4);
	--2013.08.09 FRG-F.
	DEFINE mMontoAbonoSer   MONEY(16,2);
	--20130529 
	DEFINE cNumCategoria 	CHAR(2);
	DEFINE cNumConvenio		CHAR(3);
	DEFINE cFormaPago		CHAR(1);
	
    LET mMontoServ = 0;
	LET mMontoCargoServ =0;
	LET iMovtoServ=0;
	LET iMovtoCargoServ=0;
	LET cDescripcion="";
	LET cCodRet= "00000";
	LET cMoneda= "";
	LET iSqlErr=0;
	LET dFecha= DATE(1);
	LET mMontoCargoCred=0;
	LET iMovtoCargoCred=0;
	LET cTransaccSuc="";
	--2013.08.09 FRG-I.
	LET cTransaccSdoFav="";
	--2013.08.09 FRG-F.
	LET mMontoAbonoSer=0;
	--20130529 
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cFormaPago = '';


    BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/respaldosbd/rigoberto/sp_mini21.out";
		--TRACE ON;
			
		IF NVL(pEmpresa,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pFoliosuc,'') <> '' THEN
		
			SELECT fecha_hoy {+INDEX(sc_fechas idx_fechas1)}
			INTO dFecha
			FROM bdicheq:"informix".sc_fechas
			WHERE empresa = pEmpresa;
			
			--20130529 -->
			SELECT numcategoria, numconvenio, forma_pago
			INTO cNumCategoria, cNumConvenio, cFormaPago
			FROM bdisac:"informix".sac_movimientos
			WHERE id_sucursal = pSucursal
            AND folio_suc = pFoliosuc;
			
			IF ((NVL(cNumCategoria,'') ='' OR (cNumCategoria IS NULL )) OR (NVL(cNumConvenio,'') ='' OR (cNumConvenio IS NULL )) OR (NVL(cFormaPago,'') ='' OR (cFormaPago IS NULL ))) THEN
				LET cCodRet ='00003';
				RETURN cCodRet, cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ, iMovtoCargoServ;
			ELSE 
			--20130529 <--				
				
				-- Para cuando se trata del convenio pagos GDF
				SELECT TRIM(valor)
				INTO cTransaccSuc
				FROM bdisac:"informix".sac_param
				WHERE cod_param='87033';
				
				IF NVL(cTransaccSuc,'') = '' THEN
					LET cCodRet ='00002';
					RETURN cCodRet, cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ, iMovtoCargoServ;
				ELSE 
					FOREACH
						SELECT {+INDEX(sc_movdia idx_movdia4a)} pr.divisa,
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN 1 END),0),
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN md.monto_tot END),0), --v_monto_serv
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "A" AND md.transacc_suc IN(SELECT NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN (md.monto_tot ) END),0),
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio
																													UNION SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN 1 END),0), --v_movto_cargoserv
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio
																													UNION SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN md.monto_tot END),0),-- v_monto_cargoserv 
							   (SELECT descripcion FROM bdinteg:"informix".si_divisas WHERE pr.divisa = divisa  AND empresa = pEmpresa)
						INTO  cMoneda,
							   iMovtoServ,
							   mMontoServ,
							   mMontoAbonoSer,
							   iMovtoCargoServ,
							   mMontoCargoServ,
							   cDescripcion
						  FROM bdicheq:"informix".sc_movdia md,
							   bdicheq:"informix".sc_maechq mc,
							   bdicheq:"informix".sc_producto pr,
							   bdinteg:"informix".si_transacc tr
						   WHERE md.folio_suc = pFoliosuc
						   and md.empresa = pEmpresa
						   AND md.usuario = pUsuario
						   AND md.cancelad <> "S"
						   AND md.fech_alt = dFecha
						   AND md.sucursal = pSucursal
						   AND mc.empresa = md.empresa
						   AND mc.cuenta = md.cuenta
						   AND pr.empresa = md.empresa
						   AND pr.producto = md.producto
						   AND tr.empresa = md.empresa
						   AND tr.numero = md.transacc
						   AND tr.naturaleza IN ("A","C")
						   AND tr.realizada_por = "1"
						 GROUP BY pr.divisa
						 
						--20130529						 
							IF TRIM(cFormaPago) = '5' THEN 
								--	2013.08.09 FRG-I.
								
								IF cNumCategoria = '01' AND cNumConvenio = '002' THEN
									-- Transaccion del saldo a favor TDC en pagos Club de proteccion coppel, Para cuando se trata del convenio club de proteccion coppel
									LET cTransaccSuc = "";
									
									SELECT TRIM(valor)
									INTO cTransaccSuc
									FROM bdisac:"informix".sac_param
									WHERE cod_param=80;								
									
									SELECT TRIM(valor) 
									INTO cTransaccSdoFav
									FROM bdisac:"informix".sac_param 
									WHERE cod_param=81;
								
								-- Transacción para el EDOMEX 
								ELIF cNumCategoria = '08' AND cNumConvenio = '002' THEN
									-- Transaccion del saldo a favor TDC en pagos de servicio EDOMEX.
									SELECT TRIM(valor)
									INTO cTransaccSuc
									FROM bdisac:"informix".sac_param
									WHERE cod_param=23;
									
									SELECT TRIM(valor) 
									INTO cTransaccSdoFav
									FROM bdisac:"informix".sac_param 
									WHERE cod_param=24;		
								ELSE
									-- Transacción para pago TAE (Homologación TEA-EdoMex)
									IF cNumCategoria = '03' AND cNumConvenio = '001' THEN
										SELECT TRIM(valor)
										INTO cTransaccSuc
										FROM bdisac:"informix".sac_param
										WHERE cod_param=20;
										
										SELECT TRIM(valor) 
										INTO cTransaccSdoFav
										FROM bdisac:"informix".sac_param 
										WHERE cod_param=22;
									ELSE
										-- Flujo normal, transaccion del saldo a favor TDC en pagos GDF
										SELECT TRIM(valor) 
										INTO cTransaccSdoFav
										FROM bdisac:"informix".sac_param 
										WHERE cod_param='87041';
									END IF;
							END IF;
							
						IF NVL(cTransaccSdoFav,'') = '' THEN 
							LET cCodRet ='00002';
							RETURN cCodRet,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ, iMovtoCargoServ;
						ELSE 
						--	2013.08.09 FRG-F.
						  SELECT 
							NVL(SUM( monto), 0),
							NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
							INTO mMontoCargoCred, iMovtoCargoCred
							FROM bdicred:"informix".sd_movdia a
							WHERE folio_suc = pFoliosuc		 
							--	2013.08.09 FRG-I.
								--	AND transacc_suc = cTransaccSuc 
							AND transacc_suc in (cTransaccSuc, cTransaccSdoFav)
							--	2013.08.09 FRG-F.
							AND usuario = pUsuario
							AND sucursal = pSucursal
							AND reversado <> "S"
							AND fecha_mov = dFecha
							AND divisa = cMoneda
							AND empresa = pEmpresa;
							
						END IF;
					
							SELECT 
							NVL(SUM( monto), 0),
							NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
							INTO mMontoCargoCred, iMovtoCargoCred
							FROM bdicred:"informix".sd_movdia a
							WHERE folio_suc = pFoliosuc		 
							--	2013.08.09 FRG-I.
								--	AND transacc_suc = cTransaccSuc 
							AND transacc_suc in (cTransaccSuc, cTransaccSdoFav)
							--	2013.08.09 FRG-F.
							AND usuario = pUsuario
							AND sucursal = pSucursal
							AND reversado <> "S"
							AND fecha_mov = dFecha
							AND divisa = cMoneda
							AND empresa = pEmpresa;
					
						END IF;

						RETURN 	cCodRet,
								cMoneda,
								mMontoServ + mMontoAbonoSer,
								mMontoCargoServ + mMontoCargoCred,
								cDescripcion,
								iMovtoServ,
								iMovtoCargoServ + iMovtoCargoCred WITH RESUME;
								
								--20130529
								LET mMontoCargoCred = 0;
								LET iMovtoCargoCred = 0;
					END FOREACH;				
				END IF;
			END IF;			
		ELSE 
			LET cCodRet ='00001';
			RETURN 	cCodRet,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ;
		END IF;	
    END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener el total de la transaccion base al folio suc',
'AUTOR :Eduardo López',
'FECHA : 08/01/2013',
'Ver.  : 1.0',
'BD    : bdicheq',
'MODIFICACION:Se modifica para que obtenga los totales de pagos referenciados (CAMINEMOS)',
'MODIFICÓ:Eduardo lópez ',
'FECHA:29/05/2013',
'BD    : bdicheq',
'MODIFICACION:Se modifica para pagos de WU/OV/VG para que se consultan las transacciones de abono a cuenta',
'MODIFICO:Eduardo Lopez Cuevas',
'FECHA:08/0/2013',
'BD: bdicheq',
'MODIFICACION:Se modifica para que busque la transacción de pago con TDC cuando hay saldo a favor.',
'MODIFICÓ: FRG',
'FECHA:09/Ago/2013',
'BD    : bdicheq',
'MODIFICACION:Se homologa para pagos de WU/OV/VG',
'MODIFICO:Christian Echavarria',
'FECHA:12/09/2013',
'BD: bdicheq',
'MODIFICACION:Se actualiza para que en base al convenio del folio sucursal, se consulte la transaccion parametro para el saldo a favor en pagos con tarjeta de credito.',
'SUSTENTO: 230202-1448-RQI 62 038 VentaClubdeProteccionCppl-BCP_Ver1 2.doc',
'MODIFICO:Rigoberto Gonzalez Llanes',
'FECHA:29/07/2014',
'BD: bdicheq',
'MODIFICACION:Se actualiza para que tome los totales de pago con TDC de la transaccion de pago de servicio EDOMEX.',
'MODIFICO:Jesus Isaias Bueno ',
'FECHA:17/02/2015',
'BD: bdicheq',
'MODIFICACION: Se actualiza para que tome los totales del saldo a favor del pago con TDC para EDOMEX .',
'MODIFICO:Jesus Isaias Bueno ',
'FECHA:09/03/2015',
'BD: bdicheq',
'MODIFICACION: Se actualiza para Homologación TEA-EdoMex.',
'MODIFICO: Trinidad Hernández ',
'FECHA:11/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".consctestar(pEmpresa char(3), pNumeroCuenta char(26), pNumeroCliente char(20))
        -- DATOS A REGRESAR --
        RETURNING
        char(5),    -- Codigo de retorno
        char(20),   -- # Cliente
        char(26),   -- Apellido paterno
        char(26),   -- Apellido materno
        char(26),   -- Nombre 1
        char(26),   -- Nombre 2
        char(13),   -- RFC
        char(16),   -- # Tarjeta
        date   ,    --  Expiracion
        char(4),    -- Producto tarjeta
        money(14,2), -- Limite de retiro maximo por mes
        char(1),    -- Status tarjeta
        char(8),    -- Tipo de cliente
        char(10),   --Fecha de Nacimiento
        char(4);    --Producto de la cuenta

        -- VARIABLES --
        DEFINE vCodRet  char(5);
        DEFINE vTipCte  char(1);
        DEFINE vNumCte  char(20);
        DEFINE vApePat  char(26);
        DEFINE vApeMat  char(26);
        DEFINE vNombre1 char(26);
        DEFINE vNombre2 char(26);
        DEFINE vRFC     char(13);
        DEFINE vNumTarj char(16);
        DEFINE Vexpiracion date;
        DEFINE Vprodtarjeta char(4);
        DEFINE vLimTar  money(14,2);
        DEFINE vTipoCte char(8);
        DEFINE vStatTjt char(1);
        DEFINE vFechaNac char(10);
        DEFINE vProductoCuenta char(4);
        DEFINE vCantReg smallint;




        -- INICIALIZACION DE VARIABLES --
        LET vCodRet  = "000";
        LET vCantReg = 0;
        LET vTipCte = "";
        LET vNumCte = "";
        LET vApePat = "";
        LET vApeMat = "";
        LET vNombre1 = "";
        LET vNombre2 = "";
        LET vRFC = "";
        LET vNumTarj = "";
        LET Vexpiracion = "";
        LET Vprodtarjeta = "";
        LET vLimTar = 0;
        LET vTipoCte = "";
        LET vStatTjt = "";
        LET vFechaNac = "";
        LET vProductoCuenta = "";





        -- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
        LET     vTipCte = "";



SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;


      /*  SELECT
                'T' AS tipo_cliente, sc_mcq.num_cte
        INTO
                vTipCte, vNumCte
        FROM
                bdicheq:sc_maechq AS sc_mcq
        WHERE
                sc_mcq.empresa = pEmpresa AND
                sc_mcq.cuenta  = pNumeroCuenta AND
                sc_mcq.num_cte = pNumeroCliente;*/

   -- SET DEBUG FILE TO '/tmp/consctestar.out';
	--TRACE ON;

       -- IF vTipCte = 'T' THEN
                -- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
                FOREACH
                        SELECT 
                                si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Titular' AS tipo_cliente, si_pf.fecha_nac, sc_mcq.producto
						INTO
                                vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta		
                        FROM
                                bdicheq:sc_maechq AS sc_mcq,
                                bdinteg:si_cliente AS si_cte,
                                bdinteg:si_ctepf AS si_pf
                        WHERE
                                sc_mcq.empresa = pEmpresa 
								AND sc_mcq.cuenta =  pNumeroCuenta 
								AND sc_mcq.num_cte = pNumeroCliente 
								AND sc_mcq.num_cte = si_cte.numcte 
								AND si_cte.empresa = pEmpresa 
								AND sc_mcq.num_cte = si_pf.numcte

                        SELECT
                                sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
                        INTO
                                Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
                        FROM
                                bdicheq:sc_tarjeta AS sc_tjt
                        WHERE
                                sc_tjt.empresa = pEmpresa AND
                                sc_tjt.cuenta = pNumeroCuenta AND
                                sc_tjt.numcte = vNumCte AND
                               -- sc_tjt.status_tar != 'C' AND
                                sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.cuenta = pNumeroCuenta AND sc_tjt.numcte = vNumCte);


                        IF vNumTarj IS NULL  THEN
								LET vNumTarj = "Sin tarjeta";
                                LET vLimTar = 0;
                                LET vStatTjt = "";
                        END IF

                        LET vCantReg = vCantReg + 1;

                        RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta WITH RESUME;

               END FOREACH;
       
   

        IF vCantReg = 0 THEN
                LET vCodRet  = "252";
                LET vNumCte  = "";
                LET vApePat  = "";
                LET vApeMat  = "";
                LET vNombre1 = "";
                LET vNombre2 = "";
                LET vRFC     = "";
                LET vNumTarj = "";
                LET Vexpiracion = "";
                LET Vprodtarjeta = "";
                LET vLimTar  = 0;
                LET vStatTjt = "";
                LET vTipoCte = "";
                LET vFechaNac = "";

                RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta;
        END IF
		
END PROCEDURE
DOCUMENT
'AUTOR ULTIMA MODIFICACION: Dulce Ramirez',
'DESCRIPCION ULTIMA MODIFICACION: Se modifica para que contemple únicamente las tarjetas del Titular ',        
'FECHA: Junio/2010',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cons_datcta(pempresa CHAR(3),
                                        pcuenta char(20))
RETURNING CHAR(5),CHAR(18),
          CHAR(4),CHAR(4),
          CHAR(20),
          CHAR(1),CHAR(8),
          CHAR(1),SMALLINT,SMALLINT,
          CHAR(100),
          date;

DEFINE vsqlerr INTEGER;
DEFINE vcodret        CHAR(5);
DEFINE vctaclabe      CHAR(18);
DEFINE psucursal      CHAR(4);
DEFINE pproducto      CHAR(4);
DEFINE pnum_cte       CHAR(20);
DEFINE pclase_cta     CHAR(1);
DEFINE preg_firmas    CHAR(1);
DEFINE pejecutivo     CHAR(8);
DEFINE penvio_direcc  CHAR(1);
DEFINE pdirecc_envio  SMALLINT;
DEFINE pnofirmas      SMALLINT;
DEFINE vexiste        SMALLINT;
DEFINE vcombinacion   CHAR(100);
DEFINE vfecha_alta    CHAR(100);

begin
   on exception set vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
                penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;
      END IF;
   END exception;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;


--     SET DEBUG FILE TO "/tmp/cons_datcta.out";
--     TRACE ON;

-- Inicializa variables
LET vcodret        = "000";
LET vctaclabe      = "";
LET psucursal      = "";
LET pproducto      = "";
LET pnum_cte       = "";
LET pclase_cta     = "";
LET preg_firmas    = "";
LET pejecutivo     = "";
LET penvio_direcc  = "";
LET pdirecc_envio  = 0;
LET vexiste        = 0;
LET pnofirmas      = 0;
LET vcombinacion   = "";
LET vfecha_alta    = "";

-- Valida la informacion de entrada
   IF pempresa       = "" OR
      pcuenta      = ""  THEN
      LET vcodret = "110";
      RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
             penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;
   END IF;

   SELECT 1 INTO vexiste
      FROM sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta;
   IF vexiste IS NULL THEN
      LET vcodret = "405";
      RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
             penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;
   END IF;

   SELECT cuenta_clabe,sucursal,producto,num_cte,reg_firmas,ejecutivo,envio_direcc,
          direcc_envio, fecha_alta
   INTO   vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
             penvio_direcc,pdirecc_envio, vfecha_alta
   FROM   sc_maechq a, sc_maenoc b
   WHERE  a.empresa = pempresa
   AND    a.cuenta = pcuenta
   AND    b.empresa = a.empresa
   AND    b.cuenta = a.cuenta;
   -- Saca las Firmas Registradas
   SELECT count(secuencia)
   INTO   pnofirmas
   FROM   sc_firmantes
   WHERE  empresa = pempresa
   AND    cuenta = pcuenta;

   SELECT combinacion
   INTO   vcombinacion
   FROM   sc_firmantes
   WHERE  empresa = pempresa
   AND    cuenta = pcuenta
   AND    secuencia = 1;

   RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
          penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;

END
END procedure
;