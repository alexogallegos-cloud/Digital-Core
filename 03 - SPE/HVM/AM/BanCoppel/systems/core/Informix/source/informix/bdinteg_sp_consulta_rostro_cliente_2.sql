CREATE PROCEDURE "informix".sp_consulta_rostro_cliente_2(pOpcion SMALLINT,pIdCte CHAR(9),pSecuencia SMALLINT, pVuelta SMALLINT)
	RETURNING CHAR(5) AS CodigoRetorno,
			  CHAR(9) AS IdCte,
			  CHAR(9000) AS Template;

-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet			CHAR(5);
	DEFINE cTemplate		CHAR(9000);	
	DEFINE cNumCte			CHAR(9);
	DEFINE sFila			SMALLINT;
	DEFINE sCuantos			SMALLINT;
		
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET cTemplate		= '';
	LET cNumCte			= '';
	LET sFila			= 0;
	LET sCuantos		= 0;	
	
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet,cNumCte,cTemplate;
	    END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/Braulio/sp_consulta_rostro_cliente.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--VALIDAR PARÃMETROS VACÃOS O NULOS
	IF pOpcion IS NULL OR NVL(TRIM(pIdCte),'') = '' or NVL(pVuelta,0) = 0 THEN
		LET cCodRet = '00002';
	ELSE
		IF pOpcion = 1 THEN
			SELECT COUNT(*),numcte
			INTO sCuantos,cNumCte
			FROM bdinteg:"informix".si_cte_rostro 
			WHERE numcte = pIdCte
			AND  estado = 'A'
			GROUP BY numcte;
			
			IF sCuantos > 0 AND pVuelta > 0 THEN
				SELECT CASE 
				WHEN pVuelta = 1 THEN rmapa 
				WHEN pVuelta = 2 THEN rmapa2
				WHEN pVuelta = 3 THEN rmapa3
				WHEN pVuelta = 4 THEN rmapa
				END
				INTO cTemplate
				FROM bdinteg:"informix".si_cte_rostro 
				WHERE numcte = pIdCte
				AND estado = 'A'
				AND secuencia = pSecuencia;

			END IF;	
			
			IF NVL(cTemplate,'') = '' THEN
				LET cCodRet = '00001';
			END IF;
			
		END IF;
	END IF;
	
	RETURN cCodRet,cNumCte,cTemplate;
	
END;
END PROCEDURE
DOCUMENT
'Peticion: 271.1-Solicitud consulta biometria ws por interact y agregar ip a bitacora',
'Autor: 94206041 - Jesus Rosario Lopez Castro',
'Fecha: 11/08/2017',
'Descripcion...: Se crea procedimiento para Consultar el template del cliente y retornarlo',
'Solicita......: Abraham Narvaez',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_ctehuellatemp(cEmpresa CHAR(3), cNumCte CHAR(20), cOperador CHAR (8), cEmpleado CHAR(8),
                                    cUsuario3 CHAR(8), cSucursal CHAR(4), cNueva_Ident CHAR(20), cNum_Refer CHAR (20),
                                    dFecha_Alta DATE, cTipo CHAR(1), cMapad CHAR(942), cMapai CHAR(942), 
									pcIP CHAR(15), pcVerificacion CHAR(2), pcSensor CHAR(2), pcComponente CHAR(16))		--DSB20150429 {
    --RETURNING CHAR(5), SMALLINT;
	RETURNING CHAR(6), CHAR(1), CHAR(2000);

    --DEFINE cCodRet          CHAR(5);
	--DEFINE cCodRet2         CHAR(5);
	--DEFINE smSigSec         SMALLINT;
	DEFINE cCodRet			CHAR(6);
    DEFINE cCodRet2			CHAR(6);
    DEFINE smSigSec			CHAR(1);	--DSB20150429 }
    DEFINE cExiste          SMALLINT;
    DEFINE cTp_Persona      CHAR(2);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cEsFisica        CHAR(1);
    DEFINE smSecuencia      SMALLINT;
    DEFINE cPromotor        CHAR(8);
    DEFINE cGerente         CHAR(8);
    DEFINE cNombramiento    CHAR(20);
	DEFINE bTransacInterAct	BOOLEAN;	--DSB20150429 {
	DEFINE bEnTransac		BOOLEAN;
	DEFINE cNomSP			CHAR(50);
	DEFINE cTrama			CHAR(2000); 
	DEFINE iTmp				INTEGER;
	DEFINE cnumctehtemp		CHAR(20);  -- GRLL 23-10-18
	DEFINE cvalorparam		CHAR(100);  -- GRLL 23-10-18

    --LET cCodRet = "000";
	--LET smSigSec = 0;
	LET cCodRet = '000000';
	LET smSigSec = '0';					--DSB20150429 }
    LET cCodRet2 = "";
    LET cExiste = 0;
    LET cTp_Persona = "";
    LET smSecuencia = 0;
    LET cPromotor = "";
    LET cGerente  = "";
	LET bTransacInterAct = 'F';			--DSB20150429 {
	LET bEnTransac = 'F';
	LET cNomSP = '';
	LET cTrama = '';					
	LET iTmp = 0;						--DSB20150429 }
	LET cnumctehtemp = '';   -- GRLL 23-10-18
	LET cvalorparam = '';    -- GRLL 23-10-18

--set debug file to "/tmp/sp_CteHuellaTemp.out";
--trace on;

BEGIN
    ON EXCEPTION SET iSqlErr,iIsamErr
        IF iSqlErr != 0 THEN
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
			END IF;								--DSB20150429 }
            LET cCodRet=iSqlErr;
            RETURN cCodRet,smSigSec,cTrama;	--cCodRet,smSigSec;	DSB20150429
        END IF;
    END EXCEPTION;
	
	ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;			--DSB20150429 }

--    LET cCodRet = "741";
--    RETURN cCodRet,smSigSec;

	SET ISOLATION TO dirty READ;		--DSB20150429
	SET LOCK MODE TO WAIT 3;			--DSB20150429

    SELECT tpo_persona INTO cTp_Persona
    FROM si_cliente
    WHERE numcte = cNumCte;

    SELECT es_fisica INTO cEsFisica
    FROM si_tipper
    WHERE tpo_persona = cTp_Persona;
    IF UPPER(cEsFisica) != "S" THEN
        LET cCodRet = "120";
    END IF;
	
	IF cCodRet = '000000' THEN				--DSB20150429 {
		IF TRIM(NVL(pcVerificacion, '')) = '' OR TRIM(NVL(pcSensor, '')) = '' THEN
			LET cCodRet = '001140';
		END IF;
	END IF;
	
	IF cCodRet = '000000' THEN				--DSB20150429 }

		SELECT 1 INTO cExiste
		FROM si_sucursales
		WHERE sucursal=cSucursal;
		IF cExiste IS NULL THEN
			LET cCodRet="111";
		END IF;
		
		IF cCodRet = '000000' THEN			--DSB20150429

			--Inicio de Proceso en Plataforma
			IF cTipo = 1 THEN
				--- Verifica recepcion correcta de datos
				IF cNumCte IS NULL OR Trim(cNumCte) = ""
					OR cMapad IS NULL OR cMapad = ""
					OR cMapai IS NULL OR cMapai = "" then
					LET cCodRet = "110";
				END IF;

				SELECT 1 INTO cExiste
				   FROM si_ejecut
				   WHERE ejecutivo=cOperador;
				IF cExiste IS NULL THEN
				   LET cCodRet="112";
				END IF;

				IF TRIM(cEmpleado)<> "" then
					SELECT 1 INTO cExiste
					FROM si_ejecut
					WHERE ejecutivo=cEmpleado;
					IF cExiste IS NULL THEN
						LET cCodRet="112";
					END IF;
				END IF;
		--RGH
				SELECT nombramiento
				INTO cNombramiento
				FROM si_ejecut
				WHERE ejecutivo=cEmpleado;

				--IF cNombramiento IS NULL or TRIM(UPPER(cNombramiento))<> "GERENTE TITULAR" THEN
				-- Se agrego la validacion para el nuevo perfil SUB-GERENTE
				IF TRIM(UPPER(cNombramiento)) in ('GERENTE TITULAR','JEFE OP. Y SERV') AND cNombramiento IS NOT NULL THEN
				ELSE
					LET cCodRet="119";
					RETURN cCodRet,smSigSec,cTrama;	--cCodRet,smSigSec;	DSB20150429
				END IF;
				
							
				SELECT count(numcte) 
				INTO cnumctehtemp 
				FROM si_huella_temp WHERE numcte = cNumCte; -- GRLL 20-11-18
				
				--IF EXISTS (SELECT numcte FROM si_huella_temp WHERE numcte = cNumCte) THEN -- GRLL 20-11-18
				IF cnumctehtemp > 0 THEN  -- GRLL 20-11-18
					LET cExiste = 1;
				ELSE
					LET cExiste = 0;
				END IF;
				
				
				IF cExiste = 1 THEN
				   SELECT MAX(secuencia) + 1 INTO smSigSec
				   FROM si_huella_temp
				   WHERE numcte = cNumCte;
				ELSE
				   --LET smSigSec = 1;		
				   LET smSigSec = '1';		--DSB20150429
				END IF;

				INSERT INTO si_huella_temp
					(empresa, numcte, secuencia, status, operador, empleado, usuario3, sucursal, nueva_ident, num_refer, fecha_alta, dmapa, imapa)
				VALUES
					(cEmpresa, cNumCte, smSigSec, "M", cOperador, cEmpleado, cUsuario3, cSucursal, cNueva_Ident, cNum_Refer, CURRENT, cMapad, cMapai);
			END IF;

			--Fin de Proceso en Caja
			IF cTipo = 2 THEN
				SELECT 1 INTO cExiste
					 FROM si_ejecut
					 WHERE ejecutivo=cUsuario3;
				IF cExiste IS NULL THEN
					 LET cCodRet="112";
				END IF;
				
				IF cCodRet = '000000' THEN
		--RGH
					SELECT nombramiento
					INTO cNombramiento
					FROM si_ejecut
					WHERE ejecutivo=cEmpleado;

					--IF cNombramiento IS NULL or TRIM(UPPER(cNombramiento))<> "GERENTE TITULAR" THEN
					-- Se agrego la validacion para el nuevo perfil SUB-GERENTE
					IF TRIM(UPPER(cNombramiento)) in ('GERENTE TITULAR','JEFE OP. Y SERV') AND cNombramiento IS NOT NULL THEN
					ELSE
						LET cCodRet="119";
						RETURN cCodRet,smSigSec,cTrama;	--cCodRet,smSigSec;	DSB20150429
					END IF;
		--RGH

					SELECT MAX(secuencia) INTO smSecuencia FROM si_huella_temp WHERE numcte = cNumCte;
					
					BEGIN WORK;										--DSB20150429
					LET bEnTransac = 'T';							--DSB20150429
					
					UPDATE si_huella_temp
					SET status = "A", usuario3 = cUsuario3, nueva_ident = cNueva_Ident, num_refer = cNum_Refer
					WHERE  numcte = cNumCte AND status = "M" AND secuencia = smSecuencia;

					SELECT operador, empleado INTO cPromotor, cGerente FROM si_huella_temp WHERE numcte = cNumCte AND secuencia = smSecuencia;
					
					EXECUTE PROCEDURE sp_ctehuella(cEmpresa, cSucursal, cPromotor, cEmpleado, CURRENT, "C", cNumCte, cMapad, cMapai) INTO cCodRet2,iTmp; --cCodRet2,smSigSec;	DSB20150429
					
					IF CAST(cCodRet2 AS INTEGER) = 0 THEN			--DSB20150429 {
					
						SELECT valor INTO cvalorparam FROM "informix".si_param WHERE cod_param = '135' AND valor = '1'; -- GRLL 23-10-18
						
						-- IF EXISTS (SELECT valor FROM "informix".si_param WHERE cod_param = '135' AND valor = '1') THEN -- GRLL 23-10-18
						-- IF EXISTS (cvalorparam) THEN   -- GRLL 23-10-18
						IF cvalorparam <> "" OR cvalorparam IS NOT NULL THEN
						
							EXECUTE PROCEDURE "informix".sp_generahuellalinea_chl(cNumCte, pcIP, cTipo, cEmpleado, pcVerificacion, pcSensor) 
							INTO cCodRet2, cTrama;

							IF CAST(cCodRet2 AS INTEGER) = 0 THEN
								LET smSigSec = '1';
								
								EXECUTE PROCEDURE bdisitesp:"informix".sp_mttositespalterna(cEmpresa, cNumCte, cSucursal, cUsuario3) 
								INTO cCodRet2;
								
								IF CAST(cCodRet2 AS INTEGER) = 0 THEN
									COMMIT WORK;
									LET bEnTransac = 'F';
								ELSE
									LET cNomSP = 'sp_mttositespalterna';
								END IF;
							ELSE
								LET cNomSP = 'sp_generahuellalinea_chl';
							END IF;
						END IF;
					ELSE
						LET cNomSP = 'sp_ctehuella';
					END IF;											
					
					IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
						ROLLBACK WORK;
						LET bEnTransac = 'F';
						LET cCodRet = cCodRet2;
						
						EXECUTE PROCEDURE "informix".sp_graba_bitacora_registro_huellas(cTipo, cNumCte, cSucursal, cUsuario3, pcIP, pcComponente, cCodRet, cNomSP) 
						INTO cCodRet2;
						
					END IF;											--DSB20150429 }
					
					--IF TRIM(cCodRet2) <> "000" THEN
					--LET cCodRet = cCodRet2;						--DSB20150429 Se comenta solo esta linea.
					--END IF
				END IF;												--DSB20150429
			END IF;
		END IF;														--DSB20150429 {
	END IF;
	
	IF bTransacInterAct = 'T' THEN
		BEGIN WORK;
	END IF;

RETURN cCodRet,smSigSec,cTrama;	--cCodRet,smSigSec;					--DSB20150429 }
END;
END PROCEDURE
DOCUMENT
"Alta de Huella de cliente persona fisica temporal",
"AutOR : Priscilla Mercado CampaÃ±a.",
"FECHA : 15-11-2008",
"BD    : bdinteg",
"VER   : 1.1",
"-- Folio.........: 1585 - MttoComparacionHuellasLinea",
"-- Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez",
"-- Fecha.........: 29/04/2015 - DSB20150429",
"-- ModificaciÃ³n..: Se modifica para que ejecute todos los SPs dentro de este mismo y en caso de que falle alguno no se afecte ninguna tabla.",
"-- Sustento......: RQI 64 086_Mantenimiento_comparacion_de_huellas_en_linea_v1.0",
"-- Solicita......: Jose Angel LÃ³pez Adams",
"-- BD............: bdinteg";

CREATE PROCEDURE "informix".sp_valida_gerente(pempresa CHAR(3), cEmpleado CHAR(20))
   returning char(5);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNombramiento CHAR(25);

LET iSqlErr = 0;
LET cCodRet = "00000";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

    IF pempresa = '' OR pempresa IS NULL THEN
       LET cCodRet = "110";
       RETURN cCodRet;
    END IF;

    IF cEmpleado = '' OR cEmpleado IS NULL THEN
       LET cCodRet = "110";
       RETURN cCodRet;
    END IF;

    SELECT nombramiento
        INTO cNombramiento
      FROM si_ejecut
        WHERE ejecutivo=cEmpleado;

    --IF cNombramiento IS NULL or TRIM(UPPER(cNombramiento))<> "GERENTE TITULAR" THEN
	-- Se agrego la validacion para el nuevo perfil SUB-GERENTE
	IF TRIM(UPPER(cNombramiento)) in ('GERENTE TITULAR','JEFE OP. Y SERV') AND cNombramiento IS NOT NULL THEN
	ELSE
		LET cCodRet="119";
		RETURN cCodRet;
    END IF;


RETURN cCodRet;

END
END PROCEDURE;