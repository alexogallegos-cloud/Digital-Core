CREATE PROCEDURE "informix".direcciones_cajcapt( pEmpresa         CHAR(3),
                                         pFuncion         CHAR(1),
                                         pNumCte          CHAR(20),
                                         pSecuencia       SMALLINT,
                                         pTipoDir         CHAR(1),
                                         pCalle           CHAR(40),
                                         pColonia         CHAR(60),
                                         pMunicipio       CHAR(5),
                                         pEntre_Calles    CHAR(40),
                                         pPais            CHAR(3),
                                         pEntidad         CHAR(2),
                                         pLocalidad       CHAR(3),
                                         pCodPostal       CHAR(5),
                                         pTipoTel1        CHAR(1),
                                         pTelefono1       CHAR(13),
                                         pTipoTel2        CHAR(1),
                                         pTelefono2       CHAR(13),
                                         pTipoTel3        CHAR(1),
                                         pTelefono3       CHAR(13),
                                         pExtension       CHAR(5),
                                         pEstado_Inegi    CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad        SMALLINT,
                                         pNoExt           CHAR(10),
                                         pNoInt           CHAR(10),
                                         pDepto           CHAR(6),
                                         pNoCalle         INTEGER,
                                         pNoColonia       INTEGER,
                                         pPuntoCar        CHAR(1),
                                         pUniHabi         CHAR(1),
                                         pManz            SMALLINT,
                                         pPOtros          SMALLINT,
                                         pAndador         SMALLINT,
                                         pEtapa           SMALLINT,
                                         pLote            SMALLINT,
                                         pEdif            SMALLINT,
                                         pEntrada         SMALLINT,
                                         pObserva         CHAR(80),
                                         pUser_Insert     CHAR(8),
                                         pFecha_Insert    DATE,
                                         cSucursal        CHAR(4),
                                         pCarrier         SMALLINT )
RETURNING CHAR(5);
    
    DEFINE v_CodRet             CHAR(5);
    DEFINE v_CodRet2            CHAR(5);
    DEFINE v_CodRet3            CHAR(50);
    DEFINE v_SqlErr             INTEGER;
    DEFINE v_IsamErr            INTEGER;
    DEFINE v_DescErr            CHAR(50);
    DEFINE v_NumCte             CHAR(20);
    DEFINE pcoincide_dir        SMALLINT;
    DEFINE o_tipo_dir       	CHAR(1);
    DEFINE o_calle          	CHAR(40);
    DEFINE o_colonia        	CHAR(60);
    DEFINE o_entre_calles   	CHAR(40);
    DEFINE o_pais           	CHAR(3);
    DEFINE o_estado         	CHAR(2);
    DEFINE o_ciudad         	CHAR(3);
    DEFINE o_municipio      	CHAR(5);
    DEFINE o_cod_postal     	CHAR(5);
    DEFINE o_apart_postal   	CHAR(11);
    DEFINE o_telefono1      	CHAR(13);
    DEFINE o_telefono2      	CHAR(13);
    DEFINE o_telefono3      	CHAR(13);
    DEFINE o_extension      	CHAR(5);
    DEFINE o_estado_inegi   	CHAR(2);
    DEFINE o_municipio_inegi	CHAR(3);
    DEFINE o_localidad_inegi    CHAR(4);
    DEFINE o_numerociudad   	SMALLINT;
    DEFINE o_numeroextcalle 	CHAR(10);
    DEFINE o_numerointcalle 	CHAR(10);
    DEFINE o_departamento   	CHAR(6);
    DEFINE o_numerocalle    	INTEGER;
    DEFINE o_numerocolonia  	INTEGER;
    DEFINE o_puntocardinal  	CHAR(1);
    DEFINE o_unidadhabitac  	CHAR(1);
    DEFINE o_manzana        	SMALLINT;
    DEFINE o_otros          	SMALLINT;
    DEFINE o_andador        	SMALLINT;
    DEFINE o_etapa          	SMALLINT;
    DEFINE o_lote           	SMALLINT;
    DEFINE o_edificio       	SMALLINT;
    DEFINE o_entrada        	SMALLINT;
    DEFINE o_observaciones  	CHAR(80);
    DEFINE v_CodRetTel          CHAR(5);
    DEFINE vTipoTel             SMALLINT;
    DEFINE vCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACIÓN ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACIÓN ESPECIAL
	DEFINE vCantReg             SMALLINT;
    DEFINE vSecuencia_dirs_actual SMALLINT;
	
    LET v_CodRet          = '';
    LET v_CodRet2         = '';
    LET v_CodRet3         = '';
    LET v_SqlErr          = 0;
    LET v_IsamErr         = 0;
    LET v_DescErr         = '';
    LET v_NumCte          = '';
    LET pcoincide_dir     = 0;
    LET o_tipo_dir        = '';
    LET o_calle           = '';
    LET o_colonia         = '';
    LET o_entre_calles    = '';
    LET o_pais            = '';
    LET o_estado          = '';
    LET o_ciudad          = '';
    LET o_municipio       = '';
    LET o_cod_postal      = '';
    LET o_apart_postal    = '';
    LET o_telefono1       = '';
    LET o_telefono2       = '';
    LET o_telefono3       = '';
    LET o_extension       = '';
    LET o_estado_inegi    = '';
    LET o_municipio_inegi = '';
    LET o_localidad_inegi = '';
    LET o_numerociudad    = 0;
    LET o_numeroextcalle  = '';
    LET o_numerointcalle  = '';
    LET o_departamento    = '';
    LET o_numerocalle     = 0;
    LET o_numerocolonia   = 0;
    LET o_puntocardinal   = '';
    LET o_unidadhabitac   = '';
    LET o_manzana         = 0;
    LET o_otros           = 0;
    LET o_andador         = 0;
    LET o_etapa           = 0;
    LET o_lote            = 0;
    LET o_edificio        = 0;
    LET o_entrada         = 0;
    LET o_observaciones   = '';
    LET v_CodRetTel       = '';
    LET vTipoTel          = 0;
    LET vCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACIÓN ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACIÓN ESPECIAL
	LET vCantReg          = 0;
	LET vSecuencia_dirs_actual = 0;
    
     --SET DEBUG FILE TO "/informix/macf/direcciones_cajcapt.trc";
     --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        SET DEBUG FILE TO "/tmp/direcciones_cajacapt.err";
        TRACE ON;
        IF v_SqlErr != 0 THEN
            LET v_CodRet = v_SqlErr;
            LET v_CodRet2 = v_IsamErr;
            LET v_CodRet3 = v_DescErr;
            RETURN v_CodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET v_CodRet = "000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO v_NumCte 
      FROM "informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF v_NumCte IS NULL THEN
        LET v_CodRet = "104";
        RETURN v_CodRet;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM "informix".si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM "informix".si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
		-- // CGP SE TOMA LA SECUENCIA DE LA TABLA MAESTRA si_direcciones
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM "informix".si_direcciones 
         WHERE numcte = pNumCte;
         
		
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;
        
        -- // SE AGREGA VALIDACIÓN PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, o_apart_postal,
               o_estado_inegi, o_municipio_inegi, o_localidad_inegi, o_numerociudad, 
               o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, 
               o_puntocardinal, o_unidadhabitac, o_manzana, o_otros, o_andador, o_etapa, o_lote, o_edificio, o_entrada, o_observaciones
          FROM "informix".si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
           
        IF ( o_tipo_dir is not null 
             AND o_calle = pCalle 
             AND o_colonia = pColonia 
             AND o_entre_calles = pEntre_Calles 
             AND o_pais = pPais 
             AND o_estado = pEntidad  
             AND o_ciudad = pLocalidad  
             AND o_municipio = pMunicipio  
             AND o_cod_postal = pCodPostal 
             AND o_estado_inegi = pEstado_Inegi
             AND o_municipio_inegi = pMunicipio_Inegi
             AND o_localidad_inegi = pLocalidad_Inegi
             AND o_numerociudad = pNoCiudad
             AND o_numeroextcalle = pNoExt
             AND o_numerointcalle = pNoInt
             AND o_departamento = pDepto
             AND o_numerocalle = pNoCalle
             AND o_numerocolonia = pNoColonia
             AND o_puntocardinal = pPuntoCar
             AND o_unidadhabitac = pUniHabi
             AND o_manzana = pManz
             AND o_otros = pPOtros
             AND o_andador  = pAndador
             AND o_etapa = pEtapa
             AND o_lote = pLote
             AND o_edificio = pEdif
             AND o_entrada = pEntrada
             AND o_observaciones = pObserva ) THEN
            LET pcoincide_dir = 1;
        ELSE
            LET pcoincide_dir = 0;
        END IF;

        IF ( pcoincide_dir <= 0 ) THEN
            INSERT INTO "informix".si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );

        ELSE
           LET v_CodRet = "105";
           RETURN v_CodRet;		
        END IF;

        RETURN v_CodRet;
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
"Alta de direcciones del cliente Cajera Capturista",
"Autor : Marco A. Campos",
"FECHA : 2018-10-31",
"Ver.  : 1.1",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_insertadireccioncajera(
                             pModo SMALLINT,--1:GRABA DIRECCION PERSONAL,2:GRABA DIRECCION TRABAJO
                             pEmpresa CHAR(3),
                             pNumcte CHAR(20),
                             pEntre_calles CHAR(40),
                             pEstado CHAR(2),
                             pCiudad CHAR(3),
                             pCodpostal CHAR(5),
                             pTipotel1 CHAR(1),
                             pTelefono1 CHAR(13),--9  PARTICULAR
                             pTipotel2 CHAR(1),
                             pTelefono2 CHAR(13),--11 CELULAR
                             pTipotel3 CHAR(1),
                             pTelefono3 CHAR(13),--13 REFERENCIA
                             pTelefono4 CHAR(13),--14 TRABAJO
                             pExtension CHAR(5),
                             pNoext CHAR(10),
                             pNoint CHAR(10),
                             pDepto CHAR(6),
                             pNocalle INTEGER,
                             pNocolonia INTEGER,
                             pPuntocar CHAR(1),
                             pUnihabi CHAR(1),
                             pManz SMALLINT,
                             pPotros SMALLINT,
                             pAndador SMALLINT,
                             pEtapa SMALLINT,
                             pLote SMALLINT,
                             pEdif SMALLINT,
                             pEntrada SMALLINT,
                             pObserva CHAR(80),
                             pUser_insert CHAR(8),
                             pLugartrabajo CHAR(60),
                             pTienda CHAR(5),
                             pEmpleado CHAR(20),
							 pEmail CHAR(100))
 RETURNING CHAR(5);

DEFINE cCodret CHAR(5);
DEFINE cPais CHAR(3);
DEFINE sCiudadcoppel SMALLINT;
DEFINE cMunicipio CHAR(3);
DEFINE iSecuencia INTEGER;
DEFINE iSecuencia2 INTEGER;
DEFINE iSqlerr INTEGER;
DEFINE iIsamerr INTEGER;
DEFINE sCambio SMALLINT;
DEFINE cTeltrabajo CHAR(13);
DEFINE cExtension CHAR(5);
--DSB 12/04/2011
DEFINE sOrigen SMALLINT;
--MACF 2011-09-05
DEFINE cCodret_tel CHAR(5);
-- 2013-08-27
DEFINE cUserInsertEmail CHAR(8);
DEFINE cCodret_Email CHAR(5);
define iNumciudad    smallint;
define iNumcolonia   smallint;
define cNombrezona   char(32);

define v_numcte              	CHAR(20);
-- define v_sec_ingreso         	SMALLINT;
define v_tipo_ingreso        	CHAR(1);
--define v_nombre_empresa      	CHAR(60);
define v_puesto              	CHAR(3);
define v_puesto_esp          	CHAR(2);
define v_antiguedad          	DECIMAL(4,2);
define v_nombre_depto        	CHAR(40);
define v_jefe_inmediato      	CHAR(60);
define v_ingreso_mensual     	money;
--define v_user_insert         	CHAR(8),
--define fecha_insert        	DATE,

LET cPais = "000";
LET iSecuencia = 0;
LET iSecuencia2 = 0;
LET sCiudadcoppel = 0;
--LET cMunicipio = "000";
LET cMunicipio = "00000";
LET iSqlerr = 0;
LET iIsamerr = 0;
LET cCodret = "000";
LET sCambio = 0;
LET cTeltrabajo = "";
LET cExtension = "";
--DSB 12/04/2011
LET sOrigen = 0;
--MACF 2011-09-05
LET cCodret_tel = '00000';
LET cCodret_Email = '00000';
let iNumciudad   = 0;
let iNumcolonia  = 0; 
let cNombrezona = '';

let v_numcte              	= '';
let v_tipo_ingreso        	= '';
let v_puesto              	= '';
let v_puesto_esp          	= '';
let v_antiguedad          	= 0;
let v_nombre_depto        	= '';
let v_jefe_inmediato      	= '';
let v_ingreso_mensual     	= 0;

 --SET DEBUG FILE TO "/informix/macf/sp_insertadireccioncajera.trc";
 --TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET iSqlerr, iIsamerr
      IF iSqlerr != 0 THEN
         LET cCodret=iSqlerr;
         ROLLBACK WORK;
         RETURN cCodret;
      END IF;
   END EXCEPTION;

BEGIN WORK;

 --Se modifica para que no realice nada hasta nuevo aviso siempre retornara 000
 --RETURN cCodret;
 --fin del bloque


	-- DSB 12/04/2011
	-- Se llena variable con el tipo de origen -> 1 = Tienda, 2 = Sucursal, 3 = CAT
	--*************************************************************************************************************************
	-- 2013-08-27 Se modifica para aÃ±adir email de cte ---- Hugo G. Vazquez
    --*************************************************************************************************************************
	
	LET sOrigen = 1;

--TOMA EL PAIS Y LA CIUDAD COPPEL DE CATALOGO DE CIUDADES DEL BANCO PARA SU INSERCION EN EL SI_DIRECCIONES
        /*SELECT pais,ciudad_coppel
        INTO cPais,sCiudadcoppel
        FROM "informix".si_ciudades
        WHERE ciudad = pCiudad AND estado = pEstado;
		*/
		
		--MACF en lugar del query anterior se usarÃ¡ Ã©ste
		select numerociudad 
        into sCiudadcoppel
        from bdinteg:si_ciudades_suc
		where codigo_ciudad = pciudad and codigo_estado = pestado;
        
		
		--2018-10-30 ValidaciÃ³n que exista ciudad_coppel y sea mayor a cero 
		if sCiudadcoppel is null or sCiudadcoppel <= 0 then
           let cCodret = '001';
		   ROLLBACK WORK;
		   return cCodret;
		end if;
		--2018-10-30 ValidaciÃ³n que exista ciudad_coppel y sea mayor a cero

		--2018-10-30 ValidaciÃ³n que exista colonia en Sepomex antes de dar de alta domicilio 
		select numerociudad, numerocolonia, nombrezona
		  into iNumciudad, iNumcolonia, cNombrezona
		  from bdinteg:si_catzonas_suc
		 where numerociudad = sCiudadcoppel
           and numerocolonia = pnocolonia;		 
		
		if sCiudadcoppel <= 0 or nvl(cNombrezona,'') = '' then
           let cCodret = '002';
		   ROLLBACK WORK;
		   return cCodret;
		end if;
		
		
--SE TOMA EL TELEFONO DEL TRABAJO Y LA EXTENSION ACTUAL SI ES CAMBIO DE DOMICILIO DEL CTE
--O LOS NUEVOS PARAMETROS SI ES CAMBIO DE DOMICILIO DEL TRABAJO
        /*IF pModo = 1 THEN
            --SELECT MAX(secuencia)
            --INTO iSecuencia
            --FROM bdinteg:si_direcciones
            --WHERE numcte = pNumcte AND tipo_dir = 2;

            --SELECT telefono3,extension
            --INTO cTeltrabajo,cExtension
            --FROM bdinteg:si_direcciones
            --WHERE numcte = pNumcte AND tipo_dir = 2 AND secuencia = iSecuencia;

            --tomar directamente el dato de direcciones_actual
            --SELECT telefono3, extension
            --INTO cTeltrabajo, cExtension
            --FROM bdinteg:si_direcciones_actual
            --WHERE numcte = pNumcte AND tipo_dir = 2;

		-- Ya no se actualizarÃ¡ telÃ©fono
		SELECT telefono, extension INTO cTeltrabajo, cExtension  --2012/09/25 MACF
		FROM "informix".si_telefonos_actual
		WHERE numcte = pNumcte AND tipo_tel = 3;

        ELSE
            LET cTeltrabajo = pTelefono4;
            LET cExtension = pExtension;
        END IF;
        */
		
        --SELECT MAX(secuencia)
        --INTO iSecuencia
        --FROM bdinteg:si_direcciones
        --WHERE numcte = pNumcte;

        SELECT MAX(secuencia)
        INTO iSecuencia
        FROM "informix".si_direcciones_actual
        WHERE numcte = pNumcte;

		/* Ya no se actualizarÃ¡ telÃ©fono
        --Validar que los telÃ©fonos no tengan caractÃ©res diferentes a nÃºmeros. MACF

        IF NVL(pTelefono1, '') <> '' THEN
            CALL "informix".sp_validar_telefono(pTelefono1) RETURNING cCodret_tel;
            IF cCodret_tel <> '00000' THEN LET pTelefono1 = '';  END IF;
        END IF;

        IF NVL(pTelefono2, '') <> '' THEN
            CALL "informix".sp_validar_telefono(pTelefono2) RETURNING cCodret_tel;
            IF cCodret_tel <> '00000' THEN LET pTelefono2 = '';  END IF;
        END IF;

        IF NVL(pTelefono3, '') <> '' THEN
            CALL "informix".sp_validar_telefono(pTelefono3) RETURNING cCodret_tel;
            IF cCodret_tel <> '00000' THEN LET pTelefono3 = ''; END IF;
        END IF;

        IF pModo <> 1 THEN
            IF NVL(pTelefono4,'') <> '' THEN
              CALL "informix".sp_validar_telefono(cTeltrabajo) RETURNING cCodret_tel;
              IF cCodret_tel <> '00000' THEN LET cTeltrabajo = ''; END IF;
            END IF;
        END IF;
        --Validar que los telÃ©fonos no tengan caractÃ©res diferentes a nÃºmeros. MACF
	    */
		
		-- CGP: 15102015
		-- Validar CP para no ser 0 - Null o vacio
		
		if (pCodpostal = '0') or (pCodpostal = '00') or (pCodpostal = '000') or (pCodpostal = '0000') or (pCodpostal = '00000') 
		 or (pCodpostal = '') or (pCodpostal = ' ')  or (pCodpostal is Null) then
		
		    let cCodret = '003';
		    ROLLBACK WORK;
			RETURN cCodret;
			
		end if;
		
        IF pModo = 1 THEN

            IF iSecuencia IS NULL THEN
                LET iSecuencia = 1;
            ELSE
                LET iSecuencia = iSecuencia + 1;
            END IF;
/*
            INSERT INTO bdinteg:si_direcciones
                (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
                pais,estado,ciudad,municipio,cod_postal,apart_postal,
                tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
                telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
                numerociudad,numeroextcalle,numerointcalle,departamento,
                numerocalle,numerocolonia,puntocardinal,unidadhabitac,
                manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
                user_insert,fecha_insert)
            values
                (pNumcte, iSecuencia, "1", "", "", pEntre_calles,
                cPais,pEstado,pCiudad, cMunicipio, pCodpostal,"",
                pTipotel1,pTelefono1,pTipotel2,pTelefono2,pTipotel3,
                cTeltrabajo, cExtension ,"","","",
                sCiudadcoppel,pNoext,pNoint,pDepto,
                pNocalle,pNocolonia,pPuntocar,pUnihabi,
                pManz,pPotros,pAndador,pEtapa,pLote,pEdif,pEntrada,pObserva,
                pUser_insert,CURRENT); */



			 CALL "informix".direcciones_cajcapt( pEmpresa, 'A', 	pNumcte ,iSecuencia,  	1,		  "",         "",       cMunicipio, pEntre_calles,
                                     cPais,   pEstado, pCiudad, pCodpostal,	pTipotel1,pTelefono1, pTipotel2,pTelefono2,  pTipotel3,
								     cTeltrabajo, 		cExtension, "",        "",       "",		  sCiudadcoppel,pNoext,pNoint,
									 pDepto,   pNocalle,pNocolonia,pPuntocar,	pUnihabi, pManz,	  pPotros,	pAndador,	pEtapa,
									 pLote,    pEdif,	pEntrada,	pObserva,	pUser_insert, CURRENT, SUBSTR(pTienda,1,4), 1) --43
             RETURNING cCodret;
		 
		     if cCodret = '000' then let cCodret = ''; end if;
			/* Ya no se actualizarÃ¡ correo
			IF cCodret::INTEGER = 0 THEN

				CALL "informix".sp_registra_correos( pEmpresa, pNumcte, pEmail, pModo, 1, pUser_insert)

				RETURNING cCodret_Email;

			END IF
            */
			
-- DSB 11/04/2011
-- Se comenta cÃ³digo debido a que no se insertarÃ¡ el nuevo domicilio en la tabla
-- cb_cambiosdomicilio, en lugar de Ã©sto se mandarÃ¡ llamar el sp_registramodifdomicilio
-- que insertarÃ¡ en la tabla si_bitacora_cambiosdom
--SE GRABA LA MISMA INFORMACION EN LA NUEVA TABLA CB_CAMBIOSDOMICILIO
--            INSERT INTO bdicobranza:cb_cambiosdomicilio
--                (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
--                pais,estado,ciudad,municipio,cod_postal,apart_postal,
--                tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--                telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
--                numerociudad,numeroextcalle,numerointcalle,departamento,
--                numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--                manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--                user_insert,fecha_insert,tienda,empleado)
--            values
--                (pNumcte, iSecuencia, "1", "", "", pEntre_calles,
--                cPais,pEstado,pCiudad, cMunicipio, pCodpostal,"",
--               pTipotel1,pTelefono1,pTipotel2,pTelefono2,pTipotel3,
--                cTeltrabajo, cExtension ,"","","",
--                sCiudadcoppel,pNoext,pNoint,pDepto,
--                pNocalle,pNocolonia,pPuntocar,pUnihabi,
--                pManz,pPotros,pAndador,pEtapa,pLote,pEdif,pEntrada,pObserva,
--                pUser_insert,CURRENT,pTienda,pEmpleado);

			call "informix".sp_registramodifdomicilio(pNumcte, sOrigen, pModo, iSecuencia, pTienda,
														           CURRENT, pUser_insert, pEmpleado)
						 RETURNING cCodret;

        END IF;

--SI ES CAMBIO DE DOMICILIO DEL TRABAJO (pModo = 2) ENTONCES

        IF pModo = 2 THEN

           IF iSecuencia IS NULL THEN
               LET iSecuencia = 1;
           ELSE
               LET iSecuencia = iSecuencia + 1;
           END IF;

        /*
           INSERT INTO bdinteg:si_direcciones
             (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
	      pais,estado,ciudad,municipio,cod_postal,apart_postal,
	      tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
	      telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
	      numerociudad,numeroextcalle,numerointcalle,departamento,
	      numerocalle,numerocolonia,puntocardinal,unidadhabitac,
	      manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
	      user_insert,fecha_insert)
           values
             (pNumcte, iSecuencia, "2", "", "", pEntre_calles,
              cPais,pEstado,pCiudad, cMunicipio, pCodpostal,"",
              pTipotel1,pTelefono1,pTipotel2,pTelefono2,pTipotel3,
              cTeltrabajo, cExtension ,"","","",
              sCiudadcoppel,pNoext,pNoint,pDepto,
              pNocalle,pNocolonia,pPuntocar,pUnihabi,
              pManz,pPotros,pAndador,pEtapa,pLote,pEdif,pEntrada,pObserva,
              pUser_insert,CURRENT);*/

			CALL "informix".direcciones_cajcapt( pEmpresa, 'A', 	pNumcte ,iSecuencia,  	2,		  "",         "",       cMunicipio, pEntre_calles,
                                     cPais,   pEstado, pCiudad, pCodpostal,	pTipotel1,pTelefono1, pTipotel2,pTelefono2,  pTipotel3,
								     cTeltrabajo, 		cExtension, "",        "",       "",		  sCiudadcoppel,pNoext,pNoint,
									 pDepto,   pNocalle,pNocolonia,pPuntocar,	pUnihabi, pManz,	  pPotros,	pAndador,	pEtapa,
									 pLote,    pEdif,	pEntrada,	pObserva,	pUser_insert, CURRENT, SUBSTR(pTienda,1,4), 1) --43
             RETURNING cCodret;

			 if cCodret = '000' then let cCodret = ''; end if;
			 
			/* Ya no se actualizarÃ¡ correo 
			IF cCodret::INTEGER = 0 THEN

				CALL "informix".sp_registra_correos( pEmpresa, pNumcte, pEmail, pModo, 1, pUser_insert)

				RETURNING cCodret_Email;
			END IF 	
            */
			
			
-- DSB 11/04/2011
-- Se comenta cÃ³digo debido a que no se insertarÃ¡ el nuevo domicilio en la tabla
-- cb_cambiosdomicilio, en lugar de Ã©sto se mandarÃ¡ llamar el sp_registramodifdomicilio
-- que insertarÃ¡ en la tabla si_bitacora_cambiosdom
--SE GRABA LA MISMA INFORMACION EN LA NUEVA TABLA CB_CAMBIOSDOMICILIO
--            INSERT INTO bdicobranza:cb_cambiosdomicilio
--             (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
--	      pais,estado,ciudad,municipio,cod_postal,apart_postal,
--	      tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--	      telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
--	      numerociudad,numeroextcalle,numerointcalle,departamento,
--	      numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--	      manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--	      user_insert,fecha_insert,tienda,empleado)
--          values
--             (pNumcte, iSecuencia, "2", "", "", pEntre_calles,
--              cPais,pEstado,pCiudad, cMunicipio, pCodpostal,"",
--              pTipotel1,pTelefono1,pTipotel2,pTelefono2,pTipotel3,
--              cTeltrabajo, cExtension ,"","","",
--              sCiudadcoppel,pNoext,pNoint,pDepto,
--              pNocalle,pNocolonia,pPuntocar,pUnihabi,
--              pManz,pPotros,pAndador,pEtapa,pLote,pEdif,pEntrada,pObserva,
--              pUser_insert,CURRENT,pTienda,pEmpleado);

			call "informix".sp_registramodifdomicilio(pNumcte, sOrigen, pModo, iSecuencia, pTienda,
														           CURRENT, pUser_insert, pEmpleado)
						RETURNING cCodret;

--INSERTA NUEVO REGISTRO DE DIRECCION DEL CLIENTE SI ES QUE CAMBIO EL TEL DEL TRABAJO Y/O LA EXT
            --SELECT MAX(secuencia)
            --INTO iSecuencia2
            --FROM bdinteg:si_direcciones
            --WHERE numcte = pNumcte AND tipo_dir = 1
			/*
            SELECT secuencia
            INTO iSecuencia2
            FROM bdinteg:si_direcciones_actual
            WHERE numcte = pNumcte AND tipo_dir = 1;

            LET sCambio = 0;

            SELECT 1 as sicambio
            INTO sCambio
            --FROM bdinteg:si_direcciones
            FROM bdinteg:si_direcciones_actual
            WHERE numcte = pNumcte AND secuencia = iSecuencia2 AND ( TRIM(telefono3) != TRIM(cTeltrabajo) or TRIM(extension) != TRIM(cExtension) );

            IF sCambio = 1 THEN

                IF iSecuencia IS NULL THEN
                    LET iSecuencia = 1;
                ELSE
                    LET iSecuencia = iSecuencia + 1;
                END IF;

                INSERT INTO bdinteg:si_direcciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
                    telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
                    numerociudad,numeroextcalle,numerointcalle,departamento,
                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
                    user_insert,fecha_insert)
                SELECT numcte,iSecuencia,tipo_dir,calle,colonia,entre_calles,
                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
                    cTeltrabajo,cExtension,estado_inegi,municipio_inegi,localidad_inegi,
                    numerociudad,numeroextcalle,numerointcalle,departamento,
                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
                    pUser_insert,CURRENT
                FROM bdinteg:si_direcciones WHERE numcte = pNumcte AND secuencia = iSecuencia2 AND tipo_dir = 1;
-- DSB 11/04/2011
-- Se comenta cÃ³digo debido a que no se insertarÃ¡ el nuevo domicilio en la tabla
-- cb_cambiosdomicilio, en lugar de Ã©sto se mandarÃ¡ llamar el sp_registramodifdomicilio
-- que insertarÃ¡ en la tabla si_bitacora_cambiosdom
--SE GRABA LA MISMA INFORMACION EN LA NUEVA TABLA CB_CAMBIOSDOMICILIO
--                INSERT INTO bdicobranza:cb_cambiosdomicilio(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
--                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
--                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--                    telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
--                    numerociudad,numeroextcalle,numerointcalle,departamento,
--                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--                   user_insert,fecha_insert,tienda,empleado)
--                SELECT numcte,iSecuencia,tipo_dir,calle,colonia,entre_calles,
--                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
--                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--                    cTeltrabajo,cExtension,estado_inegi,municipio_inegi,localidad_inegi,
--                    numerociudad,numeroextcalle,numerointcalle,departamento,
--                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--                    pUser_insert,CURRENT,pTienda,pEmpleado
--                FROM bdinteg:si_direcciones WHERE numcte = pNumcte AND secuencia = iSecuencia2 AND tipo_dir = 1;

			EXECUTE PROCEDURE "informix".sp_registramodifdomicilio(pNumcte, sOrigen, pModo, iSecuencia, pTienda,
														           CURRENT, pUser_insert, pEmpleado)
						 INTO cCodret;

            END IF;*/

			
--AQUI SE INSERTA EL NUEVO REGISTRO DE SI_INGRESOS POR EL CAMPO LUGAR DE TRABAJO (NOMBRE_EMPRESA) SI ES QUE HUBO ALGUN CAMBIO
            SELECT MAX(sec_ingreso)
            INTO iSecuencia
            FROM "informix".si_ingresos
            WHERE numcte = pNumcte AND empresa = pEmpresa;

            IF iSecuencia IS NULL THEN
                LET iSecuencia = 1;
            ELSE
                LET iSecuencia = iSecuencia + 1;
            END IF;	

            LET sCambio = 0;

            SELECT 1 as sicambio
            INTO sCambio
            FROM "informix".si_ingresos
            WHERE numcte = pNumcte AND empresa = pEmpresa AND sec_ingreso = iSecuencia - 1 AND TRIM(nombre_empresa) != TRIM(pLugartrabajo);

            IF sCambio = 1 THEN
                SELECT numcte, tipo_ingreso, puesto,puesto_esp,
                    antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual --,pUser_insert,CURRENT
                    into v_numcte, v_tipo_ingreso, v_puesto, v_puesto_esp, v_antiguedad, v_nombre_depto, v_jefe_inmediato, v_ingreso_mensual
                    FROM "informix".si_ingresos WHERE numcte = pNumcte AND empresa = pEmpresa AND sec_ingreso = iSecuencia - 1;
			
                INSERT INTO bdinteg:si_ingresos(empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,
                    antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert)
					VALUES(pEmpresa, v_numcte, iSecuencia, v_tipo_ingreso, pLugartrabajo, v_puesto, v_puesto_esp, v_antiguedad, v_nombre_depto,
					       v_jefe_inmediato, v_ingreso_mensual, pUser_insert, current);
					
                --SELECT empresa,numcte,iSecuencia,tipo_ingreso,pLugartrabajo,puesto,puesto_esp,
                --    antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,pUser_insert,CURRENT
                --    FROM "informix".si_ingresos WHERE numcte = pNumcte AND empresa = pEmpresa AND sec_ingreso = iSecuencia - 1;

            END IF;
        END IF;

      IF cCodret = "00000" THEN
            COMMIT WORK;
      ELSE
            ROLLBACK WORK;
      END IF;

      RETURN cCodret;
END;
END PROCEDURE;