CREATE PROCEDURE "informix".sp_cons_presenta2_totales(pempresa char(3),pfechapre date)
            RETURNING char(5),
                      INTEGER;

   DEFINE v_codret      char(5);
   DEFINE v_banco       char(100);
   DEFINE v_cuenta      char(11);
   DEFINE v_numcheque   char(7);
   DEFINE v_monto       decimal(16,2);
   DEFINE v_sucursal    char(45);
   DEFINE v_ctadeposito char(20);
   DEFINE v_nombrecte   char(100);
   DEFINE v_presentado  char(1);
   DEFINE v_numcte      char(20);
   DEFINE v_rfc         char(1);
   DEFINE v_curp        char(1);
   DEFINE v_fechapaso   date;

   DEFINE sql_err,isam_err  int;   

   DEFINE v_transacc    char(4);
   
   DEFINE v_trancheques char(4);
   DEFINE v_trancredito char(4);
   DEFINE vnoregistros  INTEGER;
   DEFINE vnoregistros_mae INTEGER;
   DEFINE vnoregistros_tar INTEGER;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET vnoregistros = 0;
   LET vnoregistros_mae = 0;
   LET vnoregistros_tar = 0;

-- Permite ver los cheques presentados
-- Grupo PISA - Eduardo Espinosa Dic 07

-- v1.1 se agrega el manejo de SBC para TC LALO Ago 08


BEGIN
   on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
        let v_codret = sql_err;
    RETURN  v_codret,vnoregistros;
      end if;
   end exception;


   	--SET DEBUG FILE TO '/informix/cons_presenta.out';
	--TRACE ON;
	--SET DEBUG FILE TO '/tmp/mfinis/cons_presenta2_totales.out';
	--TRACE ON;

    	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa is null or
            pfechapre is null then

        -- datos de entrada incompletos
        LET v_codret = 110;

        RETURN  v_codret,vnoregistros;
    END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************

    let v_banco         = " ";
    let v_cuenta        = " ";
    let v_numcheque     = " ";
    let v_monto         = 0;
    let v_sucursal      = " ";
    let v_ctadeposito   = " ";
    let v_nombrecte     = " ";
    let v_presentado    = " ";


    -- obtener transacciones
    -- cheques

    select  {+INDEX(bdinteg:si_transacc idx_transacc1)} numero
    into    v_trancheques
    from    bdinteg:si_transacc
    where   empresa = pempresa
	and     numero > "0000"
    and     abreviatura = "DEPLOCALREGCC";

    IF v_trancheques is null THEN
        -- no existe el cliente
        LET v_codret = 193;
        RETURN  v_codret,vnoregistros;
    END IF;

    -- credito
    select  {+INDEX(bdinteg:si_transacc idx_transacc1)} numero
    into    v_trancredito
    from    bdinteg:si_transacc
    where   empresa = pempresa
	and     numero > "0000"
    and     abreviatura = "PAGOTCSBC";

    IF v_trancredito is null THEN
        -- no existe el cliente
        LET v_codret = 194;
        RETURN  v_codret,vnoregistros;
    END IF;





-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

	FOREACH

        -- consulta principal

        SELECT  unique c.cvebanco || ' ' || b.descripcion,
                c.numcuenta,c.numcheque,c.monto,
                d.sucursal || " " || s.nombre, d.cuenta,
                c.presentado,d.transacc
        INTO    v_banco,v_cuenta,v_numcheque,v_monto,v_sucursal,
                v_ctadeposito,v_presentado, v_transacc
        FROM    cce_cheques_det c, bdinteg:si_bancos b,
                bdicheq:sc_docret_sbc d, bdinteg:si_sucursales s   --MOHA
        WHERE   c.empresa = pempresa
                and c.fechapresenta = pfechapre
                and c.cvebanco = b.banco
                and d.numcuenta::INT8 = c.numcuenta::INT8
                and d.num_chq = c.numcheque::INTEGER
                and d.fecha_alta=c.fecha_alta
                and d.monto_ori=c.monto
                and d.sucursal=s.sucursal
                and d.transacc in
                (select transacc from bditef:cce_mapeo_cecoban)

        -- obtener el nro de cliente segun transaccion sc_docret

        -- de cheques 0250
        IF v_transacc = v_trancheques THEN
            select  num_cte
            into    v_numcte
            from    bdicheq:sc_maechq
            where   empresa = pempresa
            and     cuenta = v_ctadeposito;
        END IF;


        -- de credito 6250
        IF v_transacc = v_trancredito THEN
            select  numcte
            into    v_numcte
            from    bdicred:sd_tarjeta
            where   empresa     = pempresa
            and     num_tarjeta = v_ctadeposito;
        END IF;



        IF v_numcte is null or v_numcte = "" THEN
            -- no existe el cliente
            LET v_codret = 195;
            RETURN  v_codret,vnoregistros;
        END IF;


        -- obtener el nombre o razon social del cliente

        call consnomcte(pempresa,v_numcte)
              returning v_codret,v_nombrecte,v_rfc,v_curp;

		LET vnoregistros = vnoregistros + 1;

    END FOREACH;

	RETURN  v_codret,vnoregistros;

END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 30/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Consulta Documentos Presentados', 
'DESCRIPCION: SPL que se encarga de consultar el nï¿½mero total de los cheques presentados.',
'BD: bditef';

CREATE PROCEDURE "informix".sp_consultarchequesdevueltos2(cNumCte CHAR(9),dFechaInicial DATE, dFechaFinal DATE, pRegistros INTEGER, pRecuperacion INTEGER)

	-- DATOS A REGRESAR --
    RETURNING
	CHAR(5),         	-- Codigo de Retorno
	CHAR(2),         	-- Motivo Devolucion
	CHAR(35),       	-- Descripcion
	CHAR(3),         	-- Empresa
	CHAR(3),         	-- Clave Banco
	CHAR(40),       	-- Descripcion Banco
	CHAR(20),   	    -- Cuenta
	CHAR(7),	        -- Numero de Cheque
	DATE,               -- Fecha Presenta
	MONEY(16,2), 		-- Monto
	MONEY(16,2), 		-- Monto Aplica
	MONEY(16,2), 		-- Suma Comision
	CHAR(3),          	-- Imagen Formato
	INT,		        -- Imagen Tamaï¿½o A
	INT			        -- Imagen Tamaï¿½o B

        -- DEFINICION DE VARIABLES --
	DEFINE iSqlErr          INT;
	DEFINE cCodRet          CHAR(5);
	DEFINE cMotivoDev       CHAR(2);
	DEFINE cDescriDev      	CHAR(35);
	DEFINE cEmpresa        	CHAR(3);
	DEFINE cCveBanco      	CHAR(3);
	DEFINE cDesBanco     	CHAR(40);
	DEFINE cCuenta	        CHAR(20);
	DEFINE cNumCheque 		CHAR(7);
	DEFINE dFechaDev      	DATE;
	DEFINE mComision     	MONEY(16,2);
	DEFINE mMontoCom   		MONEY(16,2);
	DEFINE mIvaCom	       	MONEY(16,2);
	DEFINE mSumaCom	  		MONEY(16,2);
	DEFINE cImgFormato  	CHAR(3);
	DEFINE iTamanoImgA 		INT;
	DEFINE iTamanoImgB 		INT;
	--INICIALIZACION DE VARIABLES--
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
	
--SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB;
        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--pregunto si existe un cliente con cheques en un rango de fechas determinado
	IF EXISTS(SELECT 1 FROM bditef:cce_cheques_dev WHERE numcte = cNumCte AND fechapresenta BETWEEN dFechaInicial AND dFechaFinal) THEN
		--empieza el ciclo donde saca los cheques que tenga el cliente
		FOREACH
			--Se seleccionan los cheques devueltos del cliente
			SELECT SKIP pRegistros FIRST pRecuperacion chedev.motivo, coddev.descripcion, chedev.empresa, chedev.cvebanco,  bancos.descripcion,
									cheimgA.numcuenta, cheimgA.numcheque, cheimgA.fechapresenta, chedev.monto,
									totcom.monto_aplica, cheimgA.imagen_formato, cheimgA.imagen_tam as tamano_a,
									cheimgB.imagen_tam as tamano_b
			INTO cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision,
					mMontoCom, cImgFormato, iTamanoImgA, iTamanoImgB
			FROM bditef:cce_cheques_dev chedev, bditef:cce_cheques_det chedet, OUTER bdinteg:si_coddevcam coddev,
								bditef:cce_cheques_img cheimgA, bditef:cce_cheques_img cheimgB, bdicheq:sc_comisiones totcom,
								OUTER bdinteg:si_bancos bancos
			WHERE chedev.numcte = cNumCte
				AND (chedev.empresa = chedet.empresa)
				AND (chedev.empresa = cheimgA.empresa)
				AND (chedev.empresa = cheimgB.empresa)
				AND totcom.comision = '0232'
				AND (chedev.cvebanco = cheimgA.cvebanco)
				AND (chedev.numcheque = cheimgA.numcheque)
				AND (chedev.fechapresenta = cheimgA.fechapresenta)
				AND (chedev.numcuenta = cheimgA.numcuenta AND cheimgA.lado_ft = 'A')
				AND (chedev.cvebanco = cheimgB.cvebanco)
				AND (chedev.numcheque = cheimgB.numcheque)
				AND (chedev.fechapresenta = cheimgB.fechapresenta)
				AND (chedev.numcuenta = cheimgB.numcuenta AND cheimgB.lado_ft = 'B')
				AND (chedev.numcheque = chedet.numcheque)
				AND (chedev.fechapresenta = chedet.fechapresenta)
				AND (chedev.motivo = coddev.codigo)
				AND (chedev.cvebanco = bancos.banco)
				AND (chedev.numcuenta = chedet.numcuenta)
				AND (chedev.fechapresenta BETWEEN dFechaInicial AND dFechaFinal)
				ORDER BY cheimgA.numcheque, cheimgA.lado_ft

			LET mSumaCom = mComision + mMontoCom + (mMontoCom * mIvaCom);
			--regresa los registros de cheques encontrados
			RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB WITH RESUME;
		--termina el ciclo
		END FOREACH;
	--si no existen cheques regresa un codigo de retorno
	ELSE
		LET cCodRet = '001';
		RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB WITH RESUME;
	--fin del if exists
	END IF;

--fin del begin
END;
--fin del SP
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leï¿½n Amador',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CAMARA DE COMPENSACIï¿½N', 
'DESCRIPCION: SPL CLON que obtiene el detalle de los cheques devueltos del cliente consultado',
'BD: bditef';

CREATE PROCEDURE "informix".sp_consultarchequesdevueltos2_totales(cNumCte CHAR(9),dFechaInicial DATE, dFechaFinal DATE)
    RETURNING CHAR(5),         	
		INTEGER;

    -- DEFINICION DE VARIABLES --
	DEFINE iSqlErr          INT;
	DEFINE cCodRet          CHAR(5);
	DEFINE iNoRegistros     INTEGER;

	LET iSqlErr 	= 	     0;
	LET cCodRet 	= 	 	'000';
	LET iNoRegistros = 		0;
	
--SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, iNoRegistros;
        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--pregunto si existe un cliente con cheques en un rango de fechas determinado
	IF EXISTS(SELECT 1 FROM bditef:cce_cheques_dev WHERE numcte = cNumCte AND fechapresenta BETWEEN dFechaInicial AND dFechaFinal) THEN
		
			
			SELECT COUNT(*)
			INTO iNoRegistros 
			FROM bditef:cce_cheques_dev chedev, bditef:cce_cheques_det chedet, OUTER bdinteg:si_coddevcam coddev,
								bditef:cce_cheques_img cheimgA, bditef:cce_cheques_img cheimgB, bdicheq:sc_comisiones totcom,
								OUTER bdinteg:si_bancos bancos
			WHERE chedev.numcte = cNumCte
				AND (chedev.empresa = chedet.empresa)
				AND (chedev.empresa = cheimgA.empresa)
				AND (chedev.empresa = cheimgB.empresa)
				AND totcom.comision = '0232'
				AND (chedev.cvebanco = cheimgA.cvebanco)
				AND (chedev.numcheque = cheimgA.numcheque)
				AND (chedev.fechapresenta = cheimgA.fechapresenta)
				AND (chedev.numcuenta = cheimgA.numcuenta AND cheimgA.lado_ft = 'A')
				AND (chedev.cvebanco = cheimgB.cvebanco)
				AND (chedev.numcheque = cheimgB.numcheque)
				AND (chedev.fechapresenta = cheimgB.fechapresenta)
				AND (chedev.numcuenta = cheimgB.numcuenta AND cheimgB.lado_ft = 'B')
				AND (chedev.numcheque = chedet.numcheque)
				AND (chedev.fechapresenta = chedet.fechapresenta)
				AND (chedev.motivo = coddev.codigo)
				AND (chedev.cvebanco = bancos.banco)
				AND (chedev.numcuenta = chedet.numcuenta)
				AND (chedev.fechapresenta BETWEEN dFechaInicial AND dFechaFinal);

			--RETURN cCodRet, NVL(iNoRegistros,0);
		
	--si no existen cheques regresa un codigo de retorno
	ELSE
		LET cCodRet = '001';
		--RETURN cCodRet, iNoRegistros;
	--fin del if exists
	END IF;

	RETURN cCodRet, NVL(iNoRegistros,0);

END;

END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat LeÃ³n Amador',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CAMARA DE COMPENSACIÃN', 
'DESCRIPCION: SPL que obtiene el numero total de cheques devueltos del cliente consultado',
'BD: bditef';

CREATE PROCEDURE "informix".sp_consultarchequesdevueltos3(cNumCte CHAR(9),dFechaInicial DATE, dFechaFinal DATE, pRegistros INTEGER, pRecuperacion INTEGER)

	-- DATOS A REGRESAR --
    RETURNING
	CHAR(5),         	-- Codigo de Retorno
	CHAR(2),         	-- Motivo Devolucion
	CHAR(35),       	-- Descripcion
	CHAR(3),         	-- Empresa
	CHAR(3),         	-- Clave Banco
	CHAR(40),       	-- Descripcion Banco
	CHAR(20),   	    -- Cuenta
	CHAR(7),	        -- Numero de Cheque
	DATE,               -- Fecha Presenta
	MONEY(16,2), 		-- Monto
	MONEY(16,2), 		-- Monto Aplica
	MONEY(16,2), 		-- Suma Comision
	CHAR(3),          	-- Imagen Formato
	INT,		        -- Imagen TamaÃ±o A
	INT			        -- Imagen TamaÃ±o B

        -- DEFINICION DE VARIABLES --
	DEFINE iSqlErr          INT;
	DEFINE cCodRet          CHAR(5);
	DEFINE cMotivoDev       CHAR(2);
	DEFINE cDescriDev      	CHAR(35);
	DEFINE cEmpresa        	CHAR(3);
	DEFINE cCveBanco      	CHAR(3);
	DEFINE cDesBanco     	CHAR(40);
	DEFINE cCuenta	        CHAR(20);
	DEFINE cNumCheque 		CHAR(7);
	DEFINE dFechaDev      	DATE;
	DEFINE mComision     	MONEY(16,2);
	DEFINE mMontoCom   		MONEY(16,2);
	DEFINE mIvaCom	       	MONEY(16,2);
	DEFINE mSumaCom	  		MONEY(16,2);
	DEFINE cImgFormato  	CHAR(3);
	DEFINE iTamanoImgA 		INT;
	DEFINE iTamanoImgB 		INT;
	--INICIALIZACION DE VARIABLES--
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

--SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB;
        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--pregunto si existe un cliente con cheques en un rango de fechas determinado
	IF EXISTS(SELECT 1 FROM bditef:cce_cheques_dev WHERE numcte = cNumCte AND fechapresenta BETWEEN dFechaInicial AND dFechaFinal) THEN
		--empieza el ciclo donde saca los cheques que tenga el cliente
		FOREACH
			--Se seleccionan los cheques devueltos del cliente
			SELECT SKIP pRegistros FIRST pRecuperacion chedev.motivo, coddev.descripcion, chedev.empresa, chedev.cvebanco,  bancos.descripcion,
									cheimgA.numcuenta, cheimgA.numcheque, cheimgA.fechapresenta, chedev.monto,
									totcom.monto_aplica, cheimgA.imagen_formato, cheimgA.imagen_tam as tamano_a,
									cheimgB.imagen_tam as tamano_b
			INTO cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision,
					mMontoCom, cImgFormato, iTamanoImgA, iTamanoImgB
			FROM bditef:cce_cheques_dev chedev, bditef:cce_cheques_det chedet, OUTER bdinteg:si_coddevcam coddev,
								bditef:cce_cheques_img cheimgA, bditef:cce_cheques_img cheimgB, bdicheq:sc_comisiones totcom,
								OUTER bdinteg:si_bancos bancos
			WHERE chedev.numcte = cNumCte
				AND (chedev.empresa = chedet.empresa)
				AND (chedev.empresa = cheimgA.empresa)
				AND (chedev.empresa = cheimgB.empresa)
				AND totcom.comision = '0232'
				AND (chedev.cvebanco = cheimgA.cvebanco)
				AND (chedev.numcheque = cheimgA.numcheque)
				AND (chedev.fechapresenta = cheimgA.fechapresenta)
				AND (chedev.numcuenta = cheimgA.numcuenta AND cheimgA.lado_ft = 'A')
				AND (chedev.cvebanco = cheimgB.cvebanco)
				AND (chedev.numcheque = cheimgB.numcheque)
				AND (chedev.fechapresenta = cheimgB.fechapresenta)
				AND (chedev.numcuenta = cheimgB.numcuenta AND cheimgB.lado_ft = 'B')
				AND (chedev.numcheque = chedet.numcheque)
				AND (chedev.fechapresenta = chedet.fechapresenta)
				AND (chedev.motivo = coddev.codigo)
				AND (chedev.cvebanco = bancos.banco)
				AND (chedev.numcuenta = chedet.numcuenta)
				AND (chedev.fechapresenta BETWEEN dFechaInicial AND dFechaFinal)
				ORDER BY cheimgA.numcheque, cheimgA.lado_ft

			LET mSumaCom = mComision + mMontoCom + (mMontoCom * mIvaCom);
			--regresa los registros de cheques encontrados
			RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB WITH RESUME;
		--termina el ciclo
		END FOREACH;
	--si no existen cheques regresa un codigo de retorno
	ELSE
		LET cCodRet = '001';
		RETURN cCodRet, cMotivoDev, cDescriDev, cEmpresa, cCveBanco, cDesBanco, cCuenta, cNumCheque, dFechaDev, mComision, mMontoCom, mSumaCom, cImgFormato, iTamanoImgA, iTamanoImgB WITH RESUME;
	--fin del if exists
	END IF;

--fin del begin
END;
--fin del SP
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat LeÃ³n Amador',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CAMARA DE COMPENSACIÃN', 
'DESCRIPCION: SPL CLON que obtiene el detalle de los cheques devueltos del cliente consultado',
'SPL CLONADO',
'BD: bditef';

CREATE PROCEDURE "informix".sp_consultarchequesdevueltos3_totales(cNumCte CHAR(9),dFechaInicial DATE, dFechaFinal DATE)
    RETURNING CHAR(5),         	
		INTEGER;

    -- DEFINICION DE VARIABLES --
	DEFINE iSqlErr          INT;
	DEFINE cCodRet          CHAR(5);
	DEFINE iNoRegistros     INTEGER;

	LET iSqlErr 	= 	     0;
	LET cCodRet 	= 	 	'000';
	LET iNoRegistros = 		0;
	
--SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, iNoRegistros;
        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--pregunto si existe un cliente con cheques en un rango de fechas determinado
	IF EXISTS(SELECT 1 FROM bditef:cce_cheques_dev WHERE numcte = cNumCte AND fechapresenta BETWEEN dFechaInicial AND dFechaFinal) THEN
		
			
			SELECT COUNT(*)
			INTO iNoRegistros 
			FROM bditef:cce_cheques_dev chedev, bditef:cce_cheques_det chedet, OUTER bdinteg:si_coddevcam coddev,
								bditef:cce_cheques_img cheimgA, bditef:cce_cheques_img cheimgB, bdicheq:sc_comisiones totcom,
								OUTER bdinteg:si_bancos bancos
			WHERE chedev.numcte = cNumCte
				AND (chedev.empresa = chedet.empresa)
				AND (chedev.empresa = cheimgA.empresa)
				AND (chedev.empresa = cheimgB.empresa)
				AND totcom.comision = '0232'
				AND (chedev.cvebanco = cheimgA.cvebanco)
				AND (chedev.numcheque = cheimgA.numcheque)
				AND (chedev.fechapresenta = cheimgA.fechapresenta)
				AND (chedev.numcuenta = cheimgA.numcuenta AND cheimgA.lado_ft = 'A')
				AND (chedev.cvebanco = cheimgB.cvebanco)
				AND (chedev.numcheque = cheimgB.numcheque)
				AND (chedev.fechapresenta = cheimgB.fechapresenta)
				AND (chedev.numcuenta = cheimgB.numcuenta AND cheimgB.lado_ft = 'B')
				AND (chedev.numcheque = chedet.numcheque)
				AND (chedev.fechapresenta = chedet.fechapresenta)
				AND (chedev.motivo = coddev.codigo)
				AND (chedev.cvebanco = bancos.banco)
				AND (chedev.numcuenta = chedet.numcuenta)
				AND (chedev.fechapresenta BETWEEN dFechaInicial AND dFechaFinal);

			--RETURN cCodRet, NVL(iNoRegistros,0);
		
	--si no existen cheques regresa un codigo de retorno
	ELSE
		LET cCodRet = '001';
		--RETURN cCodRet, iNoRegistros;
	--fin del if exists
	END IF;

	RETURN cCodRet, NVL(iNoRegistros,0);

END;

END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat LeÃ³n Amador',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CAMARA DE COMPENSACIÃN', 
'DESCRIPCION: SPL que obtiene el numero total de cheques devueltos del cliente consultado',
'SPL CLONADO',
'BD: bditef';

create procedure "informix".ins_reg_devo2(
                       pempresa         char(3),
                       pcvebanco        char(3),
                       pnumcuenta       char(20),
                       pnumcheque       char(7), 
                       pmotdevo         char(2), 
                       puser_insert     char(8),
                       pfecha_insert    date)
                       RETURNING char(5),char(50);  
-- version 1.1
-- manejo del pago de TC con SBC

   DEFINE v_codret  char(5);
   DEFINE v_codretdescrip char(50);
   
   DEFINE v_fechapre    date;
   DEFINE v_numcte      char(20);
   DEFINE v_ctadepo     char(20);
   DEFINE v_monto       decimal(16,2);
   DEFINE v_sucursal    char(4);   
   DEFINE v_transacc    char(4);
   DEFINE v_ctacheq     decimal(16,0);
   DEFINE v_folio       char(16);
   DEFINE v_trans_dev   char(4);
   
   DEFINE v_trancheques char(4);
   DEFINE v_trancredito char(4);
   
   
   DEFINE sql_err,isam_err int;   
   DEFINE vrowid int;

   DEFINE vstatus_cta  char(1); 	-- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009 
   DEFINE vcolateral, vmotivo CHAR(4);  -- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
   DEFINE vcta_col Integer;
   DEFINE vfecha_alta date;
   DEFINE vreferencia CHAR(40); 
   DEFINE vd_numcuenta decimal(20,0);
   DEFINE vnumcuenta char(20);

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET v_codretdescrip  = " ";
   LET vstatus_cta = " ";
   LET vcolateral= " ";
   LET vmotivo= " ";

	--set debug file to "/tmp/ins_reg_devo2.out";
	--trace on;

-- ****************************************************************************
-- ins_reg_devo_bditefv2 JYDG 
-- ****************************************************************************

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa        is null or
            pcvebanco       is null or
            pnumcuenta      is null or
            pnumcheque      is null or
            pmotdevo        is null or
            puser_insert    is null or 
            pfecha_insert   is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 190; 
       RETURN v_codret,v_codretdescrip; 
    END IF;

BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_codretdescrip; 
      end if;
   end exception;

    -- obtener transacciones
    -- cheques
    
    select  numero
    into    v_trancheques
    from    bdinteg:si_transacc
    where   empresa = pempresa
    and     abreviatura = "DEPLOCALREGCC";
    
    IF v_trancheques is null THEN
        -- no existe el cliente
        LET v_codret = 195; 
        LET v_codretdescrip = "NO EXISTE TRAN CHEQUES";
        RETURN v_codret,v_codretdescrip; 
    END IF;        
   
    -- credito
    select  numero
    into    v_trancredito
    from    bdinteg:si_transacc
    where   empresa = pempresa
    and     abreviatura = "PAGOTCSBC";
    
    IF v_trancredito is null THEN
        -- no existe el cliente
        LET v_codret = 196; 
        LET v_codretdescrip = "NO EXISTE TRAN CREDITO";
        RETURN v_codret,v_codretdescrip; 
    END IF;      
	
	-- obtener la transaccion devolucion cheque de otro banco
    select  valor
    into    v_trans_dev
    from    bdicheq:sc_param
    where   empresa = pempresa
    and     codparam = "trandevobco";

    IF v_trans_dev is null or v_trans_dev = "" THEN
        LET v_codret = 198; 
        LET v_codretdescrip = "NO EXISTE TRAN DEVOTROBCO";
        RETURN v_codret,v_codretdescrip; 
    END IF; 
      
    -- obtener la fecha de presentacion mas
    -- reciente del cheque
    
    LET v_ctacheq = pnumcuenta;

    select  max(fechapresenta)
    into    v_fechapre
    from    bditef:cce_cheques_det
    where   empresa = pempresa
    and     cvebanco = pcvebanco
    and     numcuenta = v_ctacheq
    and     numcheque = pnumcheque;

    IF v_fechapre IS NULL THEN
       -- no existe en cheques_det
       LET v_codret = 191;
       LET v_codretdescrip = "NO EXISTE EL REGISTRO";
       RETURN v_codret,v_codretdescrip;     
    END IF;

    -- obtener los demas datos desde 
    -- sc_docret

	LET vd_numcuenta = pnumcuenta::decimal(20,0);
	LET vnumcuenta = vd_numcuenta;
	LET vnumcuenta = trim(vnumcuenta);
	
    select  fecha_alta,referencia,cuenta,monto_ori,sucursal,transacc
    into    vfecha_alta,vreferencia,v_ctadepo,v_monto,v_sucursal,v_transacc
    from    bdicheq:sc_docret_sbc   --MOHA
    where   empresa = pempresa
    and     banco = pcvebanco
    and     numcuenta = vnumcuenta
	and     num_chq = pnumcheque
	and     cancelado = "T";
    
    IF v_ctadepo is null or v_sucursal is null THEN
        -- no existe el cheque en sc_docret
        LET v_codret = 192; 
        LET v_codretdescrip = "NO EXISTE EL REGISTRO SC_DOCRET";
        RETURN v_codret,v_codretdescrip; 
    END IF;     

    -- obtener el nro de cliente

    -- de cheques
    IF v_transacc = v_trancheques THEN
        select  num_cte, colateral, status_cta, motivo     -- JYDG SE AGREGA 3ULTIMOS CAMPOS PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
        into    v_numcte, vcolateral, vstatus_cta, vmotivo -- JYDG SE AGREGA 3ULTIMOS CAMPOS PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
        from    bdicheq:sc_maechq
        where   empresa = pempresa
        and     cuenta = v_ctadepo;
    END IF;
 
-- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009   
   IF vcolateral = 'S' and  vstatus_cta = 3 and vmotivo = '99' THEN
	LET vcta_col = 1;
   ELSE
	LET vcta_col = 0;
   END IF;
-- FIN JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
 
    -- de credito
    IF v_transacc = v_trancredito THEN
        select  numcte
        into    v_numcte
        from    bdicred:sd_tarjeta
        where   empresa     = pempresa
        and     num_tarjeta = v_ctadepo;
    END IF;    
  
    

    IF v_numcte is null or v_numcte = "" THEN
        -- no existe el cliente
        LET v_codret = 193; 
        LET v_codretdescrip = "NO EXISTE EL CLIENTE";
        RETURN v_codret,v_codretdescrip;  
    END IF;
     

    -- inserta el registro en la tabla de control para consulta
    -- de devoluciones desde la sucursal
    
    
--JYDG SE COMENTA EL INSERT YA QUE LO REALIZA DENTRO DEL SP bdicheq:devotrobco QUE LLAMA ABAJO MOD 20080116_1120
--    insert into cce_cheques_dev 
--            (empresa,cvebanco,numcuenta,numcheque,
--           fechapresenta,numcte,cta_deposito,
--            monto,sucursal,motivo,codigo_retorno,usuario_alta,
--            fecha_alta)
--    values  (pempresa,pcvebanco,v_ctacheq,pnumcheque,
--            v_fechapre,v_numcte,v_ctadepo,v_monto,
--            v_sucursal,pmotdevo,"000",puser_insert,
--            pfecha_insert); 
--FIN JYDG SE COMENTA EL INSERT YA QUE LO REALIZA DENTRO DEL SP bdicheq:devotrobco QUE LLAMA ABAJO MOD 20080116_1120

    -- proceso del documento y
    -- generar el cargo por comision
    
    
    LET     v_folio = puser_insert || 
            to_char(current hour to fraction,"%H%M%S") || "00";    
    
    
    -- de cheques
    IF v_transacc = v_trancheques THEN
    
        CALL    bdicheq:devotrobco2(pempresa,v_sucursal,puser_insert,
                trim(v_trans_dev),trim(v_folio),trim(v_ctadepo),
                trim(pnumcheque), pmotdevo,v_monto,pcvebanco,
                "01") -- 01 moneda nacional
        RETURNING v_codret;
    
    END IF;    
    
    -- de credito
    IF v_transacc = v_trancredito THEN
    
        CALL    bdicred:devchqsbc(pempresa,trim(v_ctadepo),
                v_sucursal,puser_insert,trim(v_folio),pmotdevo,
                v_monto,pcvebanco,
                "01") -- 01 moneda nacional
        RETURNING v_codret;

	--JYDG SE AGREGA EL INSERT YA QUE NO REALIZA LA INSERCIï¿½N A bditef::cce_cheques_dev PARA CREDITO 20090401_1800
	insert into bditef:cce_cheques_dev 
          		(empresa,cvebanco,numcuenta,numcheque,
           		fechapresenta,numcte,cta_deposito,
           		monto,sucursal,motivo,codigo_retorno,usuario_alta,
           		fecha_alta)
		values  (pempresa,pcvebanco,v_ctacheq,pnumcheque,
		         v_fechapre,v_numcte,v_ctadepo,v_monto,
            		 v_sucursal,pmotdevo,"000",puser_insert,
            pfecha_insert); 
	--FIN JYDG SE AGREGA EL INSERT YA QUE NO REALIZA LA INSERCIï¿½N A bditef::cce_cheques_dev PARA CREDITO 20090401_1800
    END IF;     
    


    -- actualizar el codigo de retorno si no fue 000
    -- cuando la cuenta tiene problemas
    IF trim(v_codret) <> "000" THEN
        update  cce_cheques_dev 
        set     codigo_retorno = v_codret
        where   empresa = pempresa
        and     cvebanco = pcvebanco
        and     numcuenta = v_ctacheq
        and     numcheque = pnumcheque
        and     fechapresenta = v_fechapre;
        
        
        -- buscar la descripcion del codigo_retorno
        select  descripcion
        into    v_codretdescrip
        from    bdinteg:si_codret
        where   codigo_retorno = trim(v_codret)
        and     sistema="01";

    ELSE
-- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
	  IF vcta_col = 0 THEN
		-- marcar el cheque como D evuelto SOLO CUANDO NO ES CUENTA COLATERAL en otro caso la deja como esta
        	update  bdicheq:sc_docret_sbc   --MOHA
		set     cancelado = "D",
	        monto = 0
        	where cuenta = v_ctadepo
			  and fecha_alta = vfecha_alta
			  and banco = pcvebanco
			  and numcuenta = vnumcuenta
			  and num_chq = pnumcheque
			  and monto_ori = v_monto;
   	  END IF;
-- FIN JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
    END IF;



END;    
RETURN v_codret,v_codretdescrip; 

END PROCEDURE;