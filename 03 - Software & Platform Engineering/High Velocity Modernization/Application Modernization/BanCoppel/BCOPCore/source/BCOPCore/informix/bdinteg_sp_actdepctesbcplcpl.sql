CREATE PROCEDURE "informix".sp_actdepctesbcplcpl(pEmpresa CHAR(3))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno;

	DEFINE iSql_err	  	INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE cNumCte		CHAR(20);
	DEFINE cValorCte	CHAR(1);
	DEFINE cValorLimpio	CHAR(1);
	
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cNumCte		= '';
	LET cValorCte	= '';
	LET cValorLimpio = '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_actdepctesbcplcpl.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet WITH RESUME;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet WITH RESUME;
		ELSE
			FOREACH
				--NOTA:
				--bctecoppel = 0: El cliente coppel no se encuentra en la base de datos de Coppel
				--bctecoppel = 1: El cliente coppel se encuentra en la base de datos de Coppel
				--bctecoppel = 2: Se actualizó registros a cValorLimpio para borrar relacion entre clientes BCPL-CPL
			
				SELECT TRIM(numcte), TRIM(bctecoppel)
				INTO cNumCte, cValorCte 
				FROM "informix".si_ctes_coppel 
				WHERE empresa = pEmpresa 
				AND bctecoppel = "0"
				
				IF cValorCte = "0" THEN
					
					IF EXISTS (SELECT numcte FROM "informix".si_cliente WHERE empresa = pEmpresa AND numcte = cNumCte) THEN
						UPDATE "informix".si_cliente 
						SET numcte_ref = cValorLimpio 
						WHERE empresa = pEmpresa
						AND numcte = cNumCte;
						/*
						IF EXISTS (SELECT numcte_banco FROM "informix".si_relacion_ctebcplcpl WHERE empresa = pEmpresa AND numcte_banco = cNumCte) THEN
							UPDATE "informix".si_relacion_ctebcplcpl
							SET cliente = cValorLimpio
							WHERE empresa = pEmpresa
							AND numcte_banco = cNumCte;
						END IF
						
						IF EXISTS (SELECT numcte FROM "informix".si_ctes_coppel WHERE empresa = pEmpresa AND numcte = cNumCte AND bctecoppel = "0") THEN
							UPDATE "informix".si_ctes_coppel
							SET bctecoppel = "2"
							WHERE empresa = pEmpresa
							AND numcte = cNumCte
							AND bctecoppel = "0";
						END IF
						*/
					END IF
				END IF;
				
				CONTINUE FOREACH;
				
			END FOREACH;

			RETURN cCodRet WITH RESUME;
			
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'Conocer si el cliente coppel registrado como referencia de un cliente Bancoppel',
'se encuentra o no en la base de datos de Coppel',
'Autor :Daniela Ramírez',
'FECHA : 25/Septiembre/2012',
'BD: bdinteg';

CREATE PROCEDURE "informix".cteppes(pempresa 	      CHAR(3),
                                    pfuncion 	      CHAR(1),
					                pnumcte           CHAR(20),
					                ptipo_ppes        CHAR(1),
					                ppuesto_ppes      CHAR(2),
					                papell_paterno    CHAR(26),
					                papell_materno    CHAR(26),
					                pnombre1          CHAR(26),
					                pnombre2          CHAR(26),
					                pparticipacion    DECIMAL(14,2),
					                pdomicilio        CHAR(80),
					                ptelefono         CHAR(20),
					                puser_insert      CHAR(8),
					                pfecha_insert     DATE,
                                    pasociacion       CHAR(40),
					                pnumeroregistro   INTEGER)
RETURNING CHAR(5);

DEFINE vcodret            CHAR(5);
DEFINE vfecha             DATE;
--DEFINE vsignumcte         INT;
DEFINE vexiste            CHAR(1);
--DEFINE vempresa           CHAR(3);
--DEFINE vsucursal          CHAR(4);
--DEFINE vejecutivo         CHAR(8);
--DEFINE vejecut_autoriza   CHAR(8);
--DEFINE vtp_persona        CHAR(2);
--DEFINE vtp_cliente        CHAR(1);
DEFINE vnumcte 		      CHAR(20);
--DEFINE vtipo_ppes         CHAR(1);
--DEFINE vpuesto_ppes       CHAR(2);
--DEFINE vpaterno 	        CHAR(26);
--DEFINE vmaterno 	        CHAR(26);
--DEFINE vnombre1 	        CHAR(26);
--DEFINE vnombre2 	        CHAR(26);
--DEFINE vparticipacion     DECIMAL(14,2);
--DEFINE vdomicilio         CHAR(80);
--DEFINE vtelefono          CHAR(20);
--DEFINE vuser_insert       CHAR(8);
--DEFINE vfecha_insert      DATE;
DEFINE vnumeroregistro    INTEGER;
DEFINE vsqlerr,visamerr   INTEGER;

LET vfecha           = "";
--LET vsignumcte       = 0;
LET vexiste          = "";
--LET vempresa         = "";
--LET vsucursal        = "";
--LET vejecutivo       = "";
--LET vejecut_autoriza = "";
--LET vtp_persona      = "";
--LET vtp_cliente      = "";
LET vnumcte          = "";
--LET vtipo_ppes       = "";
--LET vpuesto_ppes     = "";
--LET vpaterno         = "";
--LET vmaterno         = "";
--LET vnombre1         = "";
--LET vnombre2         = "";
--LET vparticipacion   = "";
--LET vdomicilio       = "";
--LET vtelefono        = "";
--LET vuser_insert     = "";
--LET vfecha_insert    = "";
LET vnumeroregistro  = 0;


LET vcodret          = "000";
--LET vempresa = pempresa;
--LET vexiste = "";


	-- SET DEBUG FILE TO "/tmp/cteppes.out";
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

SELECT fecha_hoy INTO vfecha
   FROM bdinteg:"informix".si_fechas
   WHERE empresa = pempresa;

   --alida datos Nulos
   IF pnumcte IS NULL OR pnumcte = " " THEN
      LET vcodret = "104";
      RETURN vcodret;
   END IF


   SELECT 1 INTO vexiste FROM bdinteg:"informix".si_cliente
      WHERE numcte = pnumcte AND empresa = pempresa;
   IF vexiste IS NULL THEN
      LET vcodret="104";
      RETURN vcodret;
   END IF;

   IF ptipo_ppes IS NULL OR ptipo_ppes = " " THEN
      LET vcodret = "302";
      RETURN vcodret;
   END IF

   IF ppuesto_ppes IS NULL OR ppuesto_ppes = " " THEN
      LET vcodret = "300";
      RETURN vcodret;
   END IF

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_puestosppes
    WHERE empresa=pempresa AND puesto_ppes = ppuesto_ppes;
   IF vexiste IS NULL THEN
      LET vcodret="300";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_empresas
    WHERE empresa=pempresa;
   IF vexiste IS NULL THEN
      LET vcodret="301";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_ejecut
    WHERE empresa= pempresa AND ejecutivo = puser_insert;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret;
   END IF;

-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN

   SELECT MAX(numeroregistro) + 1
     INTO vnumeroregistro
     FROM bdinteg:"informix".si_cteppes
    WHERE empresa = pempresa AND numcte = pnumcte;

   IF vnumeroregistro IS NULL THEN
      LET vnumeroregistro = 1;
   END IF


   BEGIN
      INSERT INTO bdinteg:"informix".si_cteppes
         (empresa,		numcte,		tipo_ppes, 	puesto_ppes,
	  apell_paterno, 	apell_materno,	nombre1,	nombre2,
	  participacion,	domicilio,	telefono,	user_insert,
	  fecha_insert,		numeroregistro,  asociacion_civil)
      VALUES
         (pempresa,		pnumcte,	ptipo_ppes, 	ppuesto_ppes,
	  papell_paterno, 	papell_materno,	pnombre1,	pnombre2,
	  pparticipacion,	pdomicilio,	ptelefono,	puser_insert,
	  pfecha_insert, vnumeroregistro,  pasociacion);
   END;
   RETURN vcodret;

ELSE

   SELECT 1 INTO vexiste FROM bdinteg:"informix".si_cteppes
      WHERE numcte = vnumcte AND empresa = pempresa AND numeroregistro = pnumeroregistro;
   IF vexiste IS NULL THEN
      --LET vcodret="303";
      --RETURN vcodret;
	  SELECT MAX(numeroregistro) + 1
      INTO vnumeroregistro
      FROM bdinteg:"informix".si_cteppes
      WHERE empresa = pempresa AND numcte = pnumcte;

	   IF vnumeroregistro IS NULL THEN
		  LET vnumeroregistro = 1;
	   END IF

	   BEGIN
		  INSERT INTO bdinteg:"informix".si_cteppes
			(empresa,		numcte,		tipo_ppes, 	puesto_ppes,
		  apell_paterno, 	apell_materno,	nombre1,	nombre2,
		  participacion,	domicilio,	telefono,	user_insert,
		  fecha_insert,		numeroregistro,  asociacion_civil)
		  VALUES
			 (pempresa,		pnumcte,	ptipo_ppes, 	ppuesto_ppes,
		  papell_paterno, 	papell_materno,	pnombre1,	pnombre2,
		  pparticipacion,	pdomicilio,	ptelefono,	puser_insert,
		  pfecha_insert, vnumeroregistro,  pasociacion);
	   END;
	   RETURN vcodret;
	  
   END IF;

   BEGIN
      UPDATE bdinteg:"informix".si_cteppes
 	 SET(tipo_ppes,		puesto_ppes,	apell_paterno,	apell_materno,
 	     nombre1,		nombre2,   	participacion,	domicilio,
 	     telefono,	 	user_insert,	fecha_insert,  asociacion_civil)
	   =
 	    (ptipo_ppes,	ppuesto_ppes,	papell_paterno,	papell_materno,
 	     pnombre1,		pnombre2,   	pparticipacion,	pdomicilio,
 	     ptelefono,	 	puser_insert,		pfecha_insert,   pasociacion)
       WHERE empresa = pempresa AND numcte = pnumcte AND numeroregistro = pnumeroregistro;
   END;

END IF;
RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Alta y Cambio de Personas Politicamente",
"AutOR : Procesamiento Interactivo S.A. de C..",
"MODIFICO : Victor Luna",
"FECHA : 17/Octubre/2006",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Felipe Urias",
"FECHA : 30/Agosto/2012",
"Se Agregan Reglas de Informix, se agrega insert en caso",
"De Realizar un mantenimiento que no tubiese registro de",
"ppes";

CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_his2(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento;
	-- Definicion de variables	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
    DEFINE resultado_nombre             CHAR(30);
    DEFINE resultado_claveTipo          CHAR(5);
    DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_reversado   		CHAR(1);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
	 
     -- InicializaciÃ³n de las variables.
	LET resultado_fechaMovimiento 		= '';
	LET resultado_monto 				= '';
	LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 				= '';
    LET resultado_sucursal 				= '';
    LET resultado_nombre 				= '';
    LET resultado_claveTipo 			= '';
	LET resultado_tipo 					= '';
	LET resultado_reversado 			= '';
	LET transacciones 					= 'LIST{' || ids_transacciones || '}';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones OptimizaciÃ³n de SPÂ´s II 05/03/2013
-- Cambio para que en un sÃ³lo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificaciÃ³n correcta de los SPÂ´s del sistema.
-- SADVC 
	
-- SET DEBUG FILE TO "/informix/SD/Optimizacion_sps_root_II/sp_buscar_movimientos_inversion_his2.out";
-- TRACE ON;

    RETURN resultado_fechaMovimiento;
END PROCEDURE;