create procedure "informix".connumclte(p_empresa char(3),
                            p_numero char(20))
   	returning char(5), char(2), char(3), char(8), char(2), char(1), 
	char(12), char(12), char(12), char(12), char(42),
	char(13), char(2), char(3), char(3), char(3), char(3), char(1),
	date, char(40), char(48), char(20), date, date, date, char(30), char(3),
	char(18), char(2), char(1), char(3), char(1), char(45), char(2),
	char(20), char(30), money(10,2);

define v_codret    char(5);
define v_status char(2);
define v_sucursal  char(4);
define v_ejecutivo char(8);
define v_tpo_persona  char(2);
define v_esfisica, v_tipo_cliente char(1);
define v_paterno   char(12);
define v_materno   char(12);
define v_nombre1   char(12);
define v_nombre2   char(12);
define v_razon_social     char(42);
define v_rfc	   char(13);
define v_sector    char(2);
define v_segmento  char(3);
define v_actividad char(3);
define v_grupo	   char(3);
define v_subgrupo  char(3);
define v_residencia char(1);
define v_fecha_alta date;
define v_nombre_comercial char(40);
define v_nombre_titular char(48);
define v_giro char(20);
define v_fecha_inscrip date;
define v_fecha_constit date;
define v_fecha_nac date;
define v_lugar_nac char(30);
define v_nacionalidad char(3);
define v_no_fm3 char(18);
define v_estado_civil char(2);
define v_reg_matrimonio char(1);
define v_profesion char(3); 
define v_sexo char(1);
define v_nom_empresa char(45);
define v_antiguedad char(2);
define v_nom_depto char(20);
define v_puesto char(30);
define v_ingreso_mensual money(10,2);
define v_long_cte smallint;
define v_longitud smallint;
define sql_err	   integer;
define v_rfc_alterno char(13);

let v_nombre_titular=" ";
let v_giro=" ";
let v_fecha_inscrip="";
let v_fecha_constit="";
let v_fecha_nac="";
let v_lugar_nac=" ";
let v_nacionalidad=" ";
let v_no_fm3=" ";
let v_estado_civil=" ";
let v_reg_matrimonio=" ";
let v_profesion=" ";
let v_sexo=" ";
let v_nom_empresa=" ";
let v_antiguedad=" ";
let v_nom_depto=" ";
let v_puesto=" ";
let v_ingreso_mensual=0;
let v_paterno = " ";
let v_materno = " ";
let v_nombre1 = " ";
let v_nombre2 = " ";
let v_razon_social = " ";

begin
   	on exception set sql_err
      		if sql_err <> 0 then
	 		let v_codret = sql_err;
         		return v_codret, v_status, v_sucursal, v_ejecutivo, 
			v_tpo_persona, v_tipo_cliente, v_paterno, v_materno, 
			v_nombre1, v_nombre2, v_razon_social, v_rfc, v_sector, 
			v_segmento, v_actividad, 
			v_grupo, v_subgrupo, v_residencia, v_fecha_alta, 
			v_nombre_comercial, v_nombre_titular, v_giro, 
			v_fecha_inscrip, v_fecha_constit, v_fecha_nac, 
			v_lugar_nac, v_nacionalidad, v_no_fm3, v_estado_civil, 
			v_reg_matrimonio, v_profesion, v_sexo,
			v_nom_empresa, v_antiguedad, v_nom_depto, v_puesto,
			v_ingreso_mensual;
      		end if
   	end exception;

	let v_codret = "00000";

	select status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, 
		apell_paterno, apell_materno, nombre1, nombre2, razon_social, 
		rfc, sector, segmento, actividad_princ, 
		grupo, subgrupo, residencia, fecha_alta, nombre_comercial, 
		nombre_titular, giro, fecha_inscrip, fecha_constit, fecha_nac, 
		lugar_nac, nacionalidad, no_fm3, estado_civil, 
		regim_matrimonio, profesion, sexo, nombre_empresa, antiguedad, 
		nombre_depto, puesto, ingreso_mensual, rfc_alterno
	into v_status, v_sucursal, v_ejecutivo, v_tpo_persona, v_tipo_cliente, 
		v_paterno, v_materno, v_nombre1, v_nombre2, v_razon_social, 
		v_rfc, v_sector, v_segmento, 
		v_actividad, v_grupo, v_subgrupo, v_residencia,
		v_fecha_alta, v_nombre_comercial, v_nombre_titular, v_giro, 
		v_fecha_inscrip, v_fecha_constit, v_fecha_nac, v_lugar_nac,
		v_nacionalidad, v_no_fm3, v_estado_civil, v_reg_matrimonio,
		v_profesion, v_sexo, v_nom_empresa, v_antiguedad, v_nom_depto, 
		v_puesto, v_ingreso_mensual, v_rfc_alterno
      from si_cliente, outer si_ctepf, outer si_ctepm, outer si_ingresos
      where si_cliente.numcte = p_numero and
	    si_ctepf.numcte = si_cliente.numcte and
	    si_ctepm.numcte = si_cliente.numcte and
            si_cliente.numcte = si_ingresos.numcte and sec_ingreso = 1;

      if v_tpo_persona = " " or v_tpo_persona is null then
         	let v_codret = "800";
         	return v_codret, v_status, v_sucursal, v_ejecutivo, 
			v_tpo_persona, v_tipo_cliente, v_paterno, v_materno, 
			v_nombre1, v_nombre2, v_razon_social, 
			v_rfc, v_sector, v_segmento, v_actividad, 
			v_grupo, v_subgrupo, v_residencia, v_fecha_alta, 
			v_nombre_comercial, v_nombre_titular, v_giro, 
			v_fecha_inscrip, v_fecha_constit, v_fecha_nac, 
			v_lugar_nac, v_nacionalidad, v_no_fm3, v_estado_civil, 
			v_reg_matrimonio, v_profesion, v_sexo,
			v_nom_empresa, v_antiguedad, v_nom_depto, v_puesto,
			v_ingreso_mensual;
	else
	   select es_fisica into v_esfisica from bdinteg:si_tipper
	      where tpo_persona = v_tpo_persona;
	   if v_esfisica <> "S" then
	      let v_paterno = " ";
	      let v_materno = " ";
              let v_nombre1 = " ";
	      let v_nombre2 = " ";
	   else
              let v_razon_social = " ";
 	   end if;
	   IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
          LET v_rfc = v_rfc_alterno;
       END IF;	
         	return v_codret, v_status, v_sucursal, v_ejecutivo, 
			v_tpo_persona, v_tipo_cliente, v_paterno, v_materno, 
			v_nombre1, v_nombre2, v_razon_social, 
			v_rfc, v_sector, v_segmento, v_actividad, 
			v_grupo, v_subgrupo, v_residencia, v_fecha_alta, 
			v_nombre_comercial, v_nombre_titular, v_giro, 
			v_fecha_inscrip, v_fecha_constit, v_fecha_nac, 
			v_lugar_nac, v_nacionalidad, v_no_fm3, v_estado_civil, 
			v_reg_matrimonio, v_profesion, v_sexo,
			v_nom_empresa, v_antiguedad, v_nom_depto, v_puesto,
			v_ingreso_mensual;

      end if;

end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".consnombrenumctecrd(pEmpresa CHAR(3),
						pNombre1 CHAR(26),
						pNombre2 CHAR(26),
                        pPaterno CHAR(26),
                        pMaterno CHAR(26),
						pFechaNac DATE,
						pNo_Rfc CHAR(13),
						pRazon CHAR(60),
                        pSecuencia SMALLINT)

RETURNING CHAR(5),CHAR(60),CHAR(20),CHAR(13);

DEFINE sql_err 									  INTEGER;
DEFINE v_longitud,v_ciclo 					      SMALLINT;
DEFINE v_nombre_completo 						  CHAR(63);
DEFINE v_nombre1, v_nombre2, v_paterno, v_materno CHAR(26);
DEFINE v_numcte 								  CHAR(20);
DEFINE v_cod_ret 								  CHAR(5);
DEFINE v_razon_soc 								  CHAR(60);
DEFINE v_rfc 									  CHAR(13);
DEFINE v_rfc_alterno                              CHAR(13);

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";
LET v_numcte = "0000000000";
LET v_rfc = "";
LET v_rfc_alterno = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET v_cod_ret = "00001";
	LET v_nombre_completo = 'Parámetros incompletos';
	RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
END IF;

SET ISOLATION TO DIRTY READ;

IF pRazon IS NOT NULL AND pRazon !="" THEN
    FOREACH
        SELECT skip pSecuencia limit 21
             razon_social,numcte,rfc, rfc_alterno
 	    INTO v_razon_soc,v_numcte,v_rfc, v_rfc_alterno
        FROM si_cliente
        WHERE razon_social = prazon
           and apell_paterno = ''
	       and apell_materno = ''
        ORDER BY numcte
--        LET v_ciclo = v_ciclo+1;
--        IF v_ciclo <= psecuencia THEN
-- 	        CONTINUE FOREACH;
--        END IF;
        LET v_nombre_completo = v_razon_soc;
		IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
           LET v_rfc = v_rfc_alterno;
        END IF;	
        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
    END FOREACH;
ELSE

    IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
        FOREACH
            SELECT skip pSecuencia limit 21 
                 nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc, rfc_alterno
	        INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
      	    FROM si_ctepf pf, si_cliente cl
      	    WHERE rfc = pno_rfc AND cl.numcte = pf.numcte
      	    ORDER BY pf.numcte
--      	    LET v_ciclo = v_ciclo+1;
--      	    IF v_ciclo <= psecuencia THEN
--                 CONTINUE FOREACH;
--      	    END IF;
	        LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
             || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
			IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
               LET v_rfc = v_rfc_alterno;
            END IF;	 
	        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
        END FOREACH;
    ELSE

   ---VALIDA PARAMETROS

--	IF NVL(pPaterno,'') = '' AND NVL(pMaterno,'') = '' THEN
	IF NVL(pPaterno,'') = ''  THEN
		LET v_cod_ret = "00002";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
		RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
--	ELIF NVL(pNombre1,'') = '' AND NVL(pNombre2,'') = '' THEN
	ELIF NVL(pNombre1,'') = '' THEN
		LET v_cod_ret = "00003";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
		RETURN v_cod_ret, v_nombre_completo, v_numcte,v_rfc;
	ELSE
        if ( pPaterno is null or pPaterno = "" ) then
           let pPaterno = "";
        else
--           let pPaterno = trim(pPaterno)||"*";
           let pPaterno = trim(pPaterno);
        end if;  

        if ( pMaterno is null or pMaterno = "" ) then
           let pMaterno = "";
        else
--           let pMaterno = trim(pMaterno)||"*";
           let pMaterno = trim(pMaterno);
        end if;  

        if ( pNombre1 is null or pNombre1 = "" ) then
           let pNombre1 = "";
        else
           let pNombre1 = trim(pNombre1)||"*";
        end if;  

        if ( pNombre2 is null or pNombre2 = "" ) then
           let pNombre2 = "";
        else
           let pNombre2 = trim(pNombre2)||"*";
        end if;  

--		LET pPaterno = TRIM(pPaterno)||"*";
--		LET pMaterno = TRIM(pMaterno)||"*";
--		LET pNombre1 = TRIM(pNombre1)||"*";
--		LET pNombre2 = TRIM(pNombre2)||"*";

		IF NVL(pFechaNac,'') <> '' THEN
			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc, rfc_alterno
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
				FROM si_ctepf pf, si_cliente cl
				WHERE cl.apell_paterno = ppaterno
				AND cl.apell_materno = pmaterno
				AND cl.nombre1 matches pNombre1
				AND cl.nombre2 matches pNombre2
				AND pf.fecha_nac = pFechaNac
				AND cl.numcte = pf.numcte
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo + 1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
                   LET v_rfc = v_rfc_alterno;
                END IF;			
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;

		ELSE

			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc, rfc_alterno
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
				FROM si_cliente
				WHERE apell_paterno = ppaterno
				AND apell_materno = pmaterno
				AND nombre1 matches pNombre1
				AND nombre2 matches pNombre2
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo+1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(UPPER(v_materno))
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
                   LET v_rfc = v_rfc_alterno;
                END IF;			
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE
DOCUMENT
'Consulta clientes por nombre(s) y apellido(s) y por fecha de nacimiento si asi se requiere',
'AUTOR : Dulce Ramirez',
'FECHA : 01/Junio/2009',
'Ver.  : 1.1',
'BD    : bdinteg',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_consultactexcta(pNumcte CHAR(20), pCuenta CHAR(20))
RETURNING VARCHAR(5), CHAR(60), CHAR(40), CHAR(40), CHAR(25);

-- Declaracion de Variables
DEFINE cCliente CHAR(20);
DEFINE cNombre CHAR(60);
DEFINE cApell_pat CHAR(40);
DEFINE cApell_mat CHAR(40);
DEFINE cRfc CHAR(25);
DEFINE codret VARCHAR(5);
DEFINE csql_err INTEGER;
DEFINE cRfc_alterno CHAR(25);

    --Set debug file to '/tmp/sp_consultactexcta.out';
    --trace on;

--Inicializacion de Variables
LET cCliente = "";
LET cNombre = "";
LET cApell_pat = "";
LET cApell_mat = "";
LET cRfc = "";
LET codret = "00000";
LET csql_err = "100";
LET cRfc_alterno = "";

BEGIN
	ON EXCEPTION SET csql_err
		LET codret = csql_err;
		RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;
	END EXCEPTION;	

      SET ISOLATION TO DIRTY READ;
	
	IF (pNumcte <> "" AND pCuenta <> "") OR (pNumcte <> "" AND pCuenta = "") THEN
		SELECT
			TRIM(nombre1)||' '||TRIM(nombre2) || Trim(razon_social),
			TRIM(apell_paterno),
			TRIM(apell_materno),
			TRIM(rfc),
			TRIM(rfc_alterno)
		INTO cNombre, cApell_pat, cApell_mat, cRfc, cRfc_alterno
		FROM bdinteg:si_cliente
		WHERE numcte = pNumcte	;	
		
	ELIF pNumcte = "" AND pCuenta <> "" THEN
		SELECT num_cte
		INTO cCliente
		FROM bdicheq:sc_maechq
		WHERE empresa = '001'
		AND cuenta = pCuenta;
		
		IF cCliente IS NULL THEN
			LET codret = "120";
			RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;			
		END IF;
		
		SELECT
			TRIM(nombre1)||' '||TRIM(nombre2) || Trim(razon_social),
			TRIM(apell_paterno),
			TRIM(apell_materno),
			TRIM(rfc),
			TRIM(rfc_alterno)
		INTO cNombre, cApell_pat, cApell_mat, cRfc, cRfc_alterno
		FROM bdinteg:si_cliente
		WHERE numcte = cCliente;
		
	ELIF (pNumcte = "" AND pCuenta = "") OR (pNumcte IS NULL AND pCuenta IS NULL) THEN
		LET codret = "100";
		RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;		
	END IF;
	
	IF (cNombre IS NULL) OR (cNombre = "") THEN
		LET codret = "110";
	END IF;
	
	IF cRFC_alterno is not null and cRFC_alterno <> "" THEN
       LET cRFC = cRFC_alterno;
    END IF;	
	
	RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;
END
END PROCEDURE
DOCUMENT
	'AUTOR: Clemente Angulo Ballardo',
	'DESCRIPCION: Proceso que obtiene informacion personal de cliente Bancoppel: nombre(s), apellido(s) y RFC', 
	'             o en caso de ser persona moral trae su razon social y el RFC.',
	'VERSION: 20090408.1635';

CREATE PROCEDURE "informix".sp_cnsif_bloqueoctascred(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)  AS Cod_Retorno,  
						  DATE     AS Fecha_Bloqueo,
						  CHAR(30) AS Tipo_Bloqueo, 
						  CHAR(50) AS Descripcion_Bloqueo,
						  CHAR(50) AS Status_Credito,          
						  CHAR(4)  AS Sucursal, 
						  CHAR(8)  AS Usuario,
						  CHAR(45) AS Nombre_Usuario;					
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE cCodRetS 	  CHAR(6);
DEFINE cMensaje       CHAR(80);
DEFINE vSucursal      CHAR(4);
DEFINE vDescripcion   CHAR(30);
DEFINE vStatusCredito CHAR(2);
DEFINE vFechaApertura DATE;
DEFINE vCodSP         CHAR(6);
DEFINE cCausa         CHAR(50);
DEFINE vID            INTEGER;
DEFINE cCodCausa      CHAR(2);
DEFINE cNombre        CHAR(50);
DEFINE cCredBitacora  CHAR(20);

DEFINE dFecha_Bloqueo       DATE; 
DEFINE cTipo_Bloqueo        CHAR(30); 
DEFINE cDescripcion_Bloqueo CHAR(50); 
DEFINE cStatus_Credito      CHAR(50); 
DEFINE cSucursal            CHAR(4); 
DEFINE cUsuario             CHAR(8); 
DEFINE cNombre_Usuario      CHAR(45); 
DEFINE pEmpresa             CHAR(3);
DEFINE pNumCuenta           CHAR(20);
DEFINE vNumCte              CHAR(16);


DEFINE iCont          INTEGER;

--INICIALIZA VARIABLES
LET vSucursal      = '';
LET vDescripcion   = '';
LET vStatusCredito = '';
LET vFechaApertura = '';
LET vID            = 0;
LET cCausa         = '';
LET cCodCausa      = '';
LET cNombre        = '';
LET cCredBitacora  = '';
LET iCont          = 0;
LET cCodRetS       = "";

LET dFecha_Bloqueo       = ''; 
LET cTipo_Bloqueo        = ''; 
LET cDescripcion_Bloqueo = ''; 
LET cStatus_Credito      = ''; 
LET cSucursal            = ''; 
LET cUsuario             = ''; 
LET cNombre_Usuario      = ''; 
LET pEmpresa             ='001';
LET pNumCuenta           = ''; 
LET vNumCte              = ''; 

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_bloqueoctascred.out";
	--TRACE ON;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
    END IF

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
		RETURN
			cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
        END IF;
    END IF;    
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
	END IF;
	-- TERMINA VALIDACION	
    FOREACH
        SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
        UNION
        SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
    END FOREACH;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00046";
		RETURN 
		cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
	END IF;
	
	IF pNumRegistro = 0 THEN
		DELETE FROM si_tempobloqctascred WHERE cuenta = cNUMCUENTA AND ejecutivosif=cID_USUARIOC;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			EXECUTE PROCEDURE bdicred:sp_consultacuenta('001', cNUMCUENTA)
			INTO
			cCodRetS,cMensaje,pEmpresa,pNumCuenta, vNumCte,cNombre, vSucursal, 
			vDescripcion, cCausa , vStatusCredito,vFechaApertura
			
            LET cCodRet = '00000';
		/*	LET cCodRet = SUBSTR(cCodRetS,2,6);
			IF cCodRet='00003' THEN
				LET cCodRet='00018';
			ELIF cCodRet='00004' THEN
				LET cCodRet='00019';
			ELIF cCodRet='00006' THEN
				LET cCodRet='00032';
			ELIF cCodRet='00002' THEN
				LET cCodRet='00033';
			END IF;
			IF cCodRet<>'00000' THEN
				RETURN 
				cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
			END IF;*/
			SELECT LIMIT 1 ejecutivo
			INTO
			cUsuario
			FROM bdicred:sd_bitacorabloqueocta
			WHERE cuenta = cNUMCUENTA;			
			
			SELECT nombre
			INTO
			cNombre_Usuario
			FROM si_ejecut
			WHERE ejecutivo = cUsuario;
			
			SELECT descripcion
			INTO
			cStatus_Credito
			FROM bdicred:sd_tipocartera
			WHERE status_cred = vStatusCredito;
			
        --    IF vFechaApertura="01/01/1900" THEN
        --        LET dFecha_Bloqueo ="";
         --   ELSE
                LET dFecha_Bloqueo = vFechaApertura;
           -- END IF;    
			
			LET cTipo_Bloqueo = vDescripcion;
			
			LET cDescripcion_Bloqueo = cCausa;
			
			LET cSucursal = vSucursal;
				
			INSERT INTO si_tempobloqctascred(cod_ret,fecha,tipo_bloqueo,descripcion,status,sucursal,usuario,nombre_usuario,cuenta,ejecutivosif) 
			VALUES(cCodRet, dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario,cNUMCUENTA,cID_USUARIOC);
		END FOREACH;

	END IF
	
	SELECT NVL(COUNT(cod_ret),0) into iexiste FROM si_tempobloqctascred WHERE cuenta = cNUMCUENTA AND ejecutivosif=cID_USUARIOC;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00090";
		RETURN 
		cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
	END IF;

	SET ISOLATION TO DIRTY READ;
	FOREACH
        SELECT SKIP pNumRegistro FIRST pRecuperacion
        cod_ret,fecha,tipo_bloqueo,descripcion,status,sucursal,usuario,nombre_usuario
        INTO
        cCodRetS, dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario
        FROM si_tempobloqctascred
        WHERE cuenta = cNUMCUENTA AND ejecutivosif=cID_USUARIOC ORDER BY fecha desc

        --LET cCodRet = SUBSTR(cCodRetS,2,6);
        LET iCont=iCont + 1;

        RETURN 
        cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario WITH RESUME;
	END FOREACH;
	
	IF iCont = 0 THEN
		DELETE FROM si_tempobloqctascred WHERE cuenta = cNUMCUENTA AND ejecutivosif=cID_USUARIOC;
		LET cCodRet = '1001'; 
		RETURN  
		cCodRet,dFecha_Bloqueo,cTipo_Bloqueo, cDescripcion_Bloqueo,cStatus_Credito,cSucursal,cUsuario,cNombre_Usuario;
	END IF; 	

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del Histórico de Bloqueo de Cuentas de Crédito. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Cuenta.",
"FECHA : 06-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consulta_pagos_recibidos_general(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)       AS Codigo_Retorno,       
						  DATE          AS dfecha_movimientoimiento,
						  DECIMAL(18,2) AS deccapital_vigenteente,
						  DECIMAL(18,2) AS deccapital_vencidodo,
						  DECIMAL(18,2) AS decinteres_vigenteente,
						  DECIMAL(18,2) AS iva_decinteres_vigente,
						  DECIMAL(18,2) AS interes_vencido,
						  DECIMAL(18,2) AS iva_interes_vencido,
						  DECIMAL(18,2) AS interes_mora,
						  DECIMAL(18,2) AS iva_mora,
						  DECIMAL(18,2) AS total_pagado,
						  CHAR(16)      AS folio_sucursal;					
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE cCodRetS 		      CHAR(6);
DEFINE cMensaje               CHAR(80);
DEFINE cnum_credito	      	  CHAR(20);      
DEFINE dfecha_movimiento	  DATE;          
DEFINE deccapital_vigente	  DECIMAL(18,2); 
DEFINE deccapital_vencido	  DECIMAL(18,2); 
DEFINE decinteres_vigente	  DECIMAL(18,2); 
DEFINE deciva_interes_vig     DECIMAL(18,2); 
DEFINE decinteres_orden_abono DECIMAL(18,2); 
DEFINE deciva_orden_abono	  DECIMAL(18,2); 
DEFINE decinteres_mora		  DECIMAL(18,2); 
DEFINE deciva_mora		      DECIMAL(18,2);
DEFINE dectotal_pagado	      DECIMAL(18,2); 
DEFINE cfolio_sucursal	      CHAR(16);  
DEFINE iCont                  INTEGER;

--INICIALIZA VARIABLES
LET cnum_credito	       = "";
LET dfecha_movimiento	   = "";
LET deccapital_vigente	   = 0;
LET deccapital_vencido	   = 0;
LET decinteres_vigente	   = 0;
LET deciva_interes_vig     = 0;
LET decinteres_orden_abono = 0;
LET deciva_orden_abono	   = 0;
LET decinteres_mora	       = 0;
LET deciva_mora	           = 0;
LET dectotal_pagado	       = 0;
LET cfolio_sucursal	       = "";
LET iCont                  = 0;
LET cCodRetS               = "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consulta_pagos_recibidos_general.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN
                cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
                deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
        END IF;
    END IF;    
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF;
	-- TERMINA VALIDACION	
    FOREACH
	SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
    UNION
    SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
    END FOREACH;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00046";
		RETURN 
		cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
		deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF;
	
	IF pNumRegistro = 0 THEN
		DELETE FROM si_tempopagosrecibidos WHERE ejecutivosif= cID_USUARIOC;
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:sp_consulta_pagos_recibidos_general  ('001',cNUMCUENTA)
			INTO
			cCodRetS,cMensaje,cnum_credito,dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
		    deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal
			
			LET cCodRet = SUBSTR(cCodRetS,2,6);
	
			IF cCodRet  != '00000' THEN	   
                IF cCodRet='00002' THEN
                    LET cCodRet ='00017';
                END IF;
                IF LENGTH(cCodRet)=3 THEN
                    LET cCodRet='00'||cCodRet;
                END IF;
				RETURN  
					cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
					deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
			END IF;
				
			INSERT INTO si_tempopagosrecibidos(cod_ret, fecha_movimiento, capital_vigente, capital_vencido, interes_vigente, iva_interes_vigente, interes_orden_abono, 
			                                   iva_orden_abono, interes_mora, iva_mora, total_pagado, folio_sucursal, cuenta, ejecutivosif) 
			VALUES(cCodRetS,dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
				   deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal,cNUMCUENTA,cID_USUARIOC);
			
		END FOREACH;

	END IF
	
	SET ISOLATION TO DIRTY READ;
		
	FOREACH
		SELECT SKIP pNumRegistro FIRST pRecuperacion
		cod_ret, fecha_movimiento, capital_vigente, capital_vencido, interes_vigente, iva_interes_vigente, interes_orden_abono, iva_orden_abono,
		interes_mora, iva_mora, total_pagado, folio_sucursal
		INTO
		cCodRetS,dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
		deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal
		FROM si_tempopagosrecibidos
		WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY fecha_movimiento DESC
		
		LET cCodRet = SUBSTR(cCodRetS,2,6);
		
		LET iCont=iCont + 1;
		
		RETURN 
				cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
				deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal WITH RESUME;
	END FOREACH;
	
	IF iCont = 0 THEN
		DELETE FROM si_tempopagosrecibidos WHERE ejecutivosif= cID_USUARIOC;
		LET cCodRet = 1001; 
		RETURN  
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF 	

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Pagos Recibidos asociados a una Cuenta de Crédito. ",
"El SP obtendrá los datos de la Base de Datos central de Informix, enviando como parámetro el  No. de Cuenta.",
"FECHA : 05-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE  "informix".sp_cnsif_consultamovtosgeneraldomi(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),pNumcte CHAR(20),pTipoConsulta CHAR(1),pFechaInicio CHAR(10),pFechaFin CHAR(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
	
	RETURNING CHAR(5)        AS Cod_Retorno,
			  DATE			 AS Fecha_Cargo, 
			  CHAR(20)		 AS Numero_Cuenta, 
			  MONEY(16,2)    AS Importe,
			  CHAR(40)		 AS Referencia,
			  CHAR(50)		 AS BancoRec_BancoPres,
			  CHAR(20)		 AS Status,
			  CHAR(02)       AS Causa_Rechazo,
			  CHAR(60)		 AS Desc_Causa_Rechazo,
			  CHAR(04)		 AS Sucursal;

---- VARIABLES  GENERALES---
DEFINE  cSqlerr				INTEGER;
DEFINE 	iExiste				INTEGER;
DEFINE 	dFecha_Ini			DATE;
DEFINE 	dFecha_Fin			DATE;
DEFINE 	dFechaCargo			DATE;
DEFINE	cEsFisica			CHAR(1);
DEFINE	cServicioDomi		CHAR(1);
DEFINE	cAutorizadoCteDomi	CHAR(1);
DEFINE	cTipper				CHAR(2);
DEFINE	cBancoPresentador	CHAR(3);
DEFINE	cBancoReceptor		CHAR(3);
DEFINE	cClaVeBancaria		CHAR(3);
DEFINE  cCodret     		CHAR(5);
DEFINE  cFechaFormarINI		CHAR(8);
DEFINE  cFechaFormarFIN		CHAR(8);
DEFINE  cFechaNac			CHAR(10);
DEFINE  cNumCte				CHAR(20);
DEFINE  cCuenta				CHAR(20);
DEFINE  cCuenta_clabe		CHAR(20);
DEFINE  cTarjeta			CHAR(20);
DEFINE 	cDescripcionEstatus CHAR(20);
DEFINE  cBanRecDescrip		CHAR(20);
DEFINE  cBanPresDescrip 	CHAR(20);
DEFINE  cRFC     			CHAR(18);
DEFINE  cRazon_social		CHAR(60);
DEFINE 	cDescripcionRechazo	CHAR(60);
DEFINE  cNombreCte     		CHAR(200);

DEFINE  cFecha_cargo		CHAR(8);
DEFINE 	cNCuenta			CHAR(20);
DEFINE  mImporte			MONEY(16,2);
DEFINE	cReferencia			CHAR(40);
DEFINE 	cBancosParticipantes CHAR(7);
DEFINE 	cEstatus			CHAR(20);
DEFINE 	cCausaRechazo		CHAR(20);
DEFINE  cTarjetaAux			CHAR(20);

DEFINE iCont            INTEGER;
DEFINE cSucursal        CHAR(04);
DEFINE cCuentaAux		CHAR(20);


--VALORES INICIALES
LET cSqlerr 		= 0;
LET iExiste			= 0;
LET cCodret 		= '00000';
LET cNombreCte 		= '';
LET cRFC 			= '';
LET cRazon_social	= '';
LET cFechaNac		= '';
LET cTipper			= '';
LET cEsFisica		= '';
LET cServicioDomi 	= '';
LET cAutorizadoCteDomi	= '';
LET cDescripcionEstatus = '';
LET cDescripcionRechazo = '';
LET cBanPresDescrip	= '';
LET cBanRecDescrip	= '';
LET dFechaCargo		= '';
LET cClaVeBancaria	= '';
LET dFecha_Ini		= '';
LET dFecha_Fin		= '';
LET cBancoPresentador	= '';
LET cBancoReceptor	= '';
LET cFecha_cargo	= '';
LET cNCuenta		= '';
LET mImporte		= '';
LET cReferencia		= '';
LET cBancosParticipantes	= '';
LET cEstatus		= '';
LET cCausaRechazo	= '';

LET iCont            = 0;
LET cSucursal        = '';
LET cCuentaAux       = '';
LET cTarjetaAux      = '';

	--  SET debug FILE TO "/tmp/CNSIF/sp_cnsif_consultamovtosgeneraldomi.out";
    --  Trace ON;

BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
        END IF;
    END EXCEPTION;
	IF cID_USUARIOC='' OR cID_FUNCIONC='' OR pTipoConsulta = '' OR pNumcte = '' OR pFechaInicio = '' OR pFechaFin = ''  THEN
		LET cCodret = '00083';
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	END IF

    IF pNumRegistro<0 THEN
        LET cCodret='00098';
        RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodret='00098';
            RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
        END IF;
    END IF;   	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, pNumcte,'28','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	END IF;
	-- TERMINA VALIDACION	
	
		LET dFecha_Ini = pFechaInicio;
		LET dFecha_Fin = pFechaFin;
		LET cFechaFormarINI = YEAR(dFecha_Ini)||LPAD(MONTH(dFecha_Ini),2,'0')||LPAD(DAY(dFecha_Ini),2,'0');
		LET cFechaFormarFIN = YEAR(dFecha_Fin)||LPAD(MONTH(dFecha_Fin),2,'0')||LPAD(DAY(dFecha_Fin),2,'0');
	
		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
	SELECT valor INTO cClaVeBancaria FROM bdidomi:dom_parametros WHERE cod_param = '05';

	--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
	IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
		LET cCodRet = '00084';
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	END IF;
		
	  FOREACH WITH HOLD
	  
		SELECT LPAD(TRIM(cuenta),20,'0'), LPAD(TRIM(cuenta_clabe),20,'0') , TRIM(cuenta) 
		INTO cCuenta,cCuenta_clabe,cCuentaAux  
		FROM bdicheq:sc_maechq 
		WHERE num_cte = pNumcte
		
		SELECT LPAD(TRIM(num_tarjeta),20,'0'),TRIM(num_tarjeta) 
		INTO cTarjeta,cTarjetaAux 
		FROM bdicheq:sc_tarjeta 
		WHERE cuenta = cCuentaAux 
		AND numcte = pNumcte AND status_tar='A';
		
		/*SELECT TRIM(num_tarjeta)
		INTO cTarjetaAux 
		FROM bdicheq:sc_tarjeta 
		WHERE cuenta = cCuentaAux 
		AND numcte = pNumcte;*/
		
		IF pTipoConsulta = 'P' THEN
		  FOREACH WITH HOLD
			SELECT {+INDEX (bdidomi:dom_status_pago 133_356)}  SKIP pNumRegistro FIRST pRecuperacion
			--Det.fecha_presentacion,Det.num_cta_ord,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
            Det.fecha_presentacion,cCuentaAux,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
			INTO cFecha_cargo,cNCuenta,mImporte,cReferencia,cBancoReceptor,cBancoPresentador,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo
			FROM bdidomi:dom_cce_detalle AS Det
			INNER JOIN bdidomi:dom_status_pago AS sTatPago ON (Det.cve_estatus = sTatPago.cve_status)
			INNER JOIN bdidomi:dom_cat_devoluciones AS Dev ON (Det.motivo_dev = Dev.motivo_dev)
			WHERE Det.num_cta_ord IN (cCuenta,cCuenta_clabe,cTarjeta)
			AND Det.fecha_presentacion >= cFechaFormarINI
			AND Det.fecha_presentacion <= cFechaFormarFIN
			AND Det.banco_presentador = cClaVeBancaria
			ORDER BY Det.fecha_presentacion DESC
			
			
			SELECT vchrnombrecorto INTO cBanRecDescrip FROM bdinteg:si_bancos WHERE banco = cBancoReceptor;
			SELECT vchrnombrecorto INTO cBanPresDescrip FROM bdinteg:si_bancos WHERE banco = cBancoPresentador;
			LET dFechaCargo = SUBSTR(cFecha_cargo,5,2)||'/'|| SUBSTR(cFecha_cargo,7,2) ||'/'|| SUBSTR(cFecha_cargo,1,4);
			
			SELECT cve_sucursal
			INTO cSucursal
			FROM bdidomi:dom_autorizaciones
			WHERE cuenta IN(cCuentaAux,cTarjetaAux);
			
			LET iCont = iCont + 1;
			
			RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal WITH RESUME;		
			
  		  END FOREACH;
		  
		END IF;
		
		IF pTipoConsulta = 'R' THEN
		  FOREACH WITH HOLD
			SELECT {+INDEX (bdidomi:dom_status_pago 133_356)} SKIP pNumRegistro FIRST pRecuperacion
			--Det.fecha_presentacion,Det.num_cta_rec,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
            Det.fecha_presentacion,cCuentaAux,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
			INTO cFecha_cargo,cNCuenta,mImporte,cReferencia,cBancoReceptor,cBancoPresentador,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo
			FROM bdidomi:dom_cce_detalle AS Det
			INNER JOIN bdidomi:dom_status_pago AS sTatPago ON (Det.cve_estatus = sTatPago.cve_status)
			INNER JOIN bdidomi:dom_cat_devoluciones AS Dev ON (Det.motivo_dev = Dev.motivo_dev)
			WHERE Det.num_cta_rec IN (cCuenta,cCuenta_clabe,cTarjeta)
			AND Det.fecha_presentacion >= cFechaFormarINI
			AND Det.fecha_presentacion <= cFechaFormarFIN
			AND Det.banco_receptor = cClaVeBancaria
            ORDER BY Det.fecha_presentacion DESC
			
			
			SELECT vchrnombrecorto INTO cBanRecDescrip FROM bdinteg:si_bancos WHERE banco = cBancoReceptor;
			SELECT vchrnombrecorto INTO cBanPresDescrip FROM bdinteg:si_bancos WHERE banco = cBancoPresentador;
			LET dFechaCargo = SUBSTR(cFecha_cargo,5,2)||'/'|| SUBSTR(cFecha_cargo,7,2) ||'/'|| SUBSTR(cFecha_cargo,1,4);
			
			SELECT cve_sucursal
			INTO cSucursal
			FROM bdidomi:dom_autorizaciones
			WHERE cuenta IN(cCuentaAux,cTarjetaAux);
						
			LET iCont = iCont + 1;
			
			RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal WITH RESUME;		
			
		  END FOREACH;
		  
		END IF;
		
	  END FOREACH;
      IF pNumRegistro=0 AND iCont = 0 THEN
		LET cCodret = '00091'; 
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
      END IF;

	  IF iCont = 0 THEN
		LET cCodret = '1001'; 
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	  END IF
END
END PROCEDURE
DOCUMENT
"AUTOR :Arturo Cervantes Peña",
"DESCRIPCION:Obtener la información de los Movimientos de Cargo de las Domiciliaciones asociadas a un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cliente.",
"FECHA : 02 ABRIL DEL 2012",
"BD    : BDINTEG",
"VERSION: 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultausuariofuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO CHAR(8),pNumRegistro INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5),CHAR(8),CHAR(10),CHAR(100),CHAR(6),CHAR(20),INTEGER,CHAR(60),INTEGER, CHAR(1), CHAR(1);
													
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cID_USUARIO_2 		CHAR(8);
	DEFINE cID_FUNCION			CHAR(10);
	DEFINE cD_FUNCION			CHAR(100);
	DEFINE cID_MODULO			CHAR(6);
	DEFINE cD_MODULO			CHAR(20);
	DEFINE iID_SUBMODULO		INTEGER;
	DEFINE cD_SUBMODULO			CHAR(60);
	DEFINE iORDEN				INTEGER;
	DEFINE cSTATUS_FUNCION		CHAR(1);
	DEFINE cSTATUS_FUNCIONU		CHAR(1);
    DEFINE iCont            INTEGER;
	
	
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET cID_USUARIO_2 = " ";
	LET cID_FUNCION = " ";
	LET cD_FUNCION	= " ";
	LET cID_MODULO = " ";	
	LET cD_MODULO	= " ";	
	LET iID_SUBMODULO = 0	;
	LET cD_SUBMODULO =  " ";
	LET iORDEN	= 0;
	LET cSTATUS_FUNCION = " ";
	LET cSTATUS_FUNCIONU = " ";
    LET iCont=0;
	
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultausuariofuncion.out";
		--TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' 	OR
		cID_USUARIO = ''	THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;		

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;		
		
		SELECT nvl(COUNT(id_usuario),0) INTO iexiste  FROM si_seg_usuarios_funciones WHERE id_usuario= cID_USUARIO;
		IF iexiste = 0 THEN
			LET cCodRet = "00074";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;

        SELECT NVL(COUNT(UF.id_funcion),0) INTO iexiste
        FROM  si_seg_usuarios_funciones UF
        LEFT JOIN si_seg_funciones FU
        ON UF.id_funcion  = FU.id_funcion 
        LEFT JOIN si_seg_modulos MO
        ON MO.id_modulo = FU.Id_modulo
        LEFT JOIN si_seg_submodulo SU
        ON SU.id_submodulo = FU.id_submodulo
        WHERE id_usuario= cID_USUARIO;

		IF iexiste = 0 THEN
			LET cCodRet = "00074";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;

		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion UF.id_usuario, UF.id_funcion, FU.d_funcion, FU.id_modulo,MO.d_modulo, FU.id_submodulo, SU.d_submodulo, FU.orden, FU.status, UF.status 
			INTO
			cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU
			FROM  si_seg_usuarios_funciones UF
			LEFT JOIN si_seg_funciones FU
			ON UF.id_funcion  = FU.id_funcion 
			LEFT JOIN si_seg_modulos MO
			ON MO.id_modulo = FU.Id_modulo
			LEFT JOIN si_seg_submodulo SU
			ON SU.id_submodulo = FU.id_submodulo
			WHERE id_usuario= cID_USUARIO
            ORDER BY id_submodulo,orden

            LET iCont=iCont+1;
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU with resume;
		END FOREACH
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
        END IF 
    END
END PROCEDURE	
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP devolvera las funciones del usuarios dependiendo del id_usuario que ingresen para la consulta",
"FECHA : 26-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_extrae_telefonos_comp( pcEmpresa CHAR(3) )
RETURNING CHAR(5)  AS vcCodRet1,
          CHAR(5)  AS vcCodRet2,
          CHAR(50) AS vcCodRet3,
          INTEGER  AS viContador1,
          INTEGER  AS viContador2;
    
    DEFINE vcCodRet1        CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE viComienza       SMALLINT;
    DEFINE viComienza2      SMALLINT;
    DEFINE viEnTransacc     SMALLINT;
    DEFINE viContador1      INTEGER;
    DEFINE viContador2      INTEGER;
    
    DEFINE vcCteMin         CHAR(20);
    DEFINE vcCteMax         CHAR(20);
    DEFINE vcCteMini        CHAR(20);
    DEFINE vcCteMaxi        CHAR(20);
    DEFINE vcNumCte         CHAR(20);
    DEFINE viSecuencia      SMALLINT;
    DEFINE vcTipoDir        CHAR(1);
    DEFINE vcTipoTelef1     CHAR(1);
    DEFINE vcTelefono1      CHAR(50);
    DEFINE vcTipoTelef2     CHAR(1);
    DEFINE vcTelefono2      CHAR(50);
    DEFINE vcTipoTelef3     CHAR(1);
    DEFINE vcTelefono3      CHAR(50);
    DEFINE vcExtension      CHAR(50);
    DEFINE vcUserInsert     CHAR(50);
    DEFINE vdFechaInsert    CHAR(50);
    DEFINE vCodRetValTel    CHAR(5);
    DEFINE vcValCasa        CHAR(1);
    DEFINE vcValCelular     CHAR(1);
    DEFINE vcValOficina     CHAR(1);
    DEFINE viCofetel        CHAR(1);    
    DEFINE vExisteTel       INTEGER;
    DEFINE vExisteTelAct    INTEGER;
    DEFINE vcTipoTelefono   CHAR(1);
    DEFINE vcTelefono       CHAR(50);
    DEFINE viTipoTel        SMALLINT;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO CONCLUIDO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viComienza   = -1;
    LET viComienza2  = -1;
    LET viEnTransacc = 0;
    LET viContador1  = 0;
    LET viContador2  = 0;
    
    LET vcCteMin       = '';
    LET vcCteMax       = '';
    LET vcCteMini      = '';
    LET vcCteMaxi      = '';
    LET vcNumCte       = '';
    LET viSecuencia    = 0;
    LET vcTipoDir      = '';
    LET vcTipoTelef1   = '';
    LET vcTelefono1    = '';
    LET vcTipoTelef2   = '';
    LET vcTelefono2    = '';
    LET vcTipoTelef3   = '';
    LET vcTelefono3    = '';
    LET vcExtension    = '';
    LET vcUserInsert   = '';
    LET vdFechaInsert  = '';
    LET vCodRetValTel  = '';
    LET vcValCasa      = '';
    LET vcValCelular   = '';
    LET vcValOficina   = '';
    LET viCofetel      = 'F';
    LET vExisteTel     = 0;
    LET vExisteTelAct  = 0;
    LET vcTipoTelefono = '';
    LET vcTelefono     = '';
    LET viTipoTel      = 0;
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/informix/jivan/sp_extrae_telefonos_comp.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2 ;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_extrae_telefonos_comp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pcEmpresa is null OR pcEmpresa = '' ) THEN
        LET vcCodRet1 = '110';
        RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;
    END IF;
    
    -- // TABLA PARA TODAS LAS CUENTAS
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_telefonos_tmp_comp') THEN
        DROP TABLE si_telefonos_tmp_comp;        
    END IF;
    
    CREATE TABLE si_telefonos_tmp_comp
      (
        numcte          CHAR(20),
        tipo_dir        CHAR(1), 
        secuencia       SMALLINT, 
        tipo_telefono   CHAR(1), 
        telefono        CHAR(13), 
        extension       CHAR(5), 
        user_insert     CHAR(8), 
        fecha_insert    DATE
      )
    EXTENT SIZE 10000 NEXT SIZE 1000 LOCK MODE ROW;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMin, vcCteMax
      FROM bdinteg:"informix".si_cliente;
      
    SELECT numcte
      FROM bdinteg:"informix".si_direcciones
     WHERE numcte BETWEEN vcCteMin AND vcCteMax
       AND fecha_insert >= '06/15/2012'
    INTO TEMP tmp_ctes WITH NO LOG;
    CREATE INDEX idx_cte_tmp ON tmp_ctes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMin, vcCteMax
      FROM tmp_ctes;
    
    FOREACH WITH HOLD
        SELECT numcte
          INTO vcNumCte
          FROM tmp_ctes   
         WHERE numcte BETWEEN vcCteMin AND vcCteMax
         
        IF viComienza = -1 THEN
            LET viComienza = 0;
        END IF;
         
        BEGIN WORK;
        LET viEnTransacc = 1;
        
        FOREACH
            SELECT secuencia, tipo_dir, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, user_insert, fecha_insert
              INTO viSecuencia, vcTipoDir, vcTipoTelef1, vcTelefono1, vcTipoTelef2, vcTelefono2, vcTipoTelef3, vcTelefono3, vcExtension, vcUserInsert, vdFechaInsert
              FROM bdinteg:"informix".si_direcciones
             WHERE numcte = vcNumCte
               AND fecha_insert >= '06/15/2012'
             ORDER BY secuencia DESC
             
            IF ( vcTipoTelef1 is not null AND vcTipoTelef1 <> '' ) AND ( vcTelefono1 is not null AND vcTelefono1 <> '' AND LENGTH(vcTelefono1) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef1, vcTelefono1, '', vcUserInsert, vdFechaInsert);
            END IF;
            
            IF ( vcTipoTelef2 is not null AND vcTipoTelef2 <> '' ) AND ( vcTelefono2 is not null AND vcTelefono2 <> '' AND LENGTH(vcTelefono2) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef2, vcTelefono2, '', vcUserInsert, vdFechaInsert);
            END IF;
            
            IF ( vcTipoTelef3 is not null AND vcTipoTelef3 <> '' ) AND ( vcTelefono3 is not null AND vcTelefono3 <> '' AND LENGTH(vcTelefono3) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef3, vcTelefono3, vcExtension, vcUserInsert, vdFechaInsert);
            END IF;
            
            LET viSecuencia   = 0;
            LET vcTipoDir     = '';
            LET vcTipoTelef1  = '';
            LET vcTelefono1   = '';
            LET vcTipoTelef2  = '';
            LET vcTelefono2   = '';
            LET vcTipoTelef3  = '';
            LET vcTelefono3   = '';
            LET vcExtension   = '';
            LET vcUserInsert  = '';
            LET vdFechaInsert = '';
        END FOREACH;
        
        LET viContador1 = viContador1 + 1;
        
        COMMIT WORK;
        LET viEnTransacc = 0;
        
        LET vcNumCte = '';
    END FOREACH;
    
    CREATE INDEX idx_teltmp_ctecomp ON si_telefonos_tmp_comp(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE si_telefonos_tmp_comp;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMini, vcCteMaxi
      FROM bdinteg:"informix".si_telefonos_tmp_comp;
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vcNumCte
          FROM bdinteg:"informix".si_telefonos_tmp_comp
         WHERE numcte BETWEEN vcCteMini AND vcCteMaxi
           
        IF viComienza2 = -1 THEN
            LET viComienza2 = 0;
        END IF;
         
        BEGIN WORK;
        LET viEnTransacc = 1;
            
        FOREACH
            SELECT tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert
              INTO vcTipoDir, viSecuencia, vcTipoTelefono, vcTelefono, vcExtension, vcUserInsert, vdFechaInsert
              FROM bdinteg:"informix".si_telefonos_tmp_comp
             WHERE numcte = vcNumCte
             ORDER BY secuencia
            
            IF   vcTipoDir = '1' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 1; --- CASA
            ELIF vcTipoDir = '1' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '1' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 3; --- TRABAJO
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 3; --- TRABAJO
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            END IF;
            
            -- // VALIDA SI YA EXISTE EL TELEFONO
            SELECT COUNT(*)
              INTO vExisteTel
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = vcNumCte
               AND tipo_tel = viTipoTel
               AND telefono = vcTelefono;
            
            IF vExisteTel = 0 THEN
                -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
                EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono(pcEmpresa, vcTelefono, vcTelefono, vcTelefono)
                INTO vCodRetValTel, vcValCasa, vcValCelular, vcValOficina;
                
                IF vcValCasa = '1' OR vcValCelular = '1' OR vcValOficina = '1' THEN
                    LET viCofetel = 'V';
                END IF;
                
                UPDATE bdinteg:"informix".si_telefonos
                   SET status_tel = 'C'
                 WHERE numcte = vcNumCte
                   AND tipo_tel = viTipoTel;
                   
                -- // OBTIENE EL NUMERO DE SECUENCIA
                SELECT MAX(secuencia)
                  INTO viSecuencia
                  FROM bdinteg:"informix".si_telefonos
                 WHERE numcte = vcNumCte;
                         
                IF viSecuencia is null OR viSecuencia = '' THEN
                    LET viSecuencia = 0;
                END IF;
                
                LET viSecuencia = viSecuencia + 1;
                
                INSERT INTO bdinteg:"informix".si_telefonos
                (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert)
                VALUES
                (pcEmpresa, vcNumCte, vcTelefono, viTipoTel, 'A', viSecuencia, vcExtension, 0, 1, 0, viCofetel, vdFechaInsert, vcUserInsert);
            END IF;
            
            LET vcTipoDir      = '';
            LET viSecuencia    = 0;
            LET vcTipoTelefono = '';
            LET vcTelefono     = '';
            LET vcExtension    = '';
            LET vcUserInsert   = '';
            LET vdFechaInsert  = '';
            LET viTipoTel      = 0;
            LET vCodRetValTel  = '';
            LET vcValCasa      = '';
            LET vcValCelular   = '';
            LET vcValOficina   = '';
            LET viCofetel      = 'F';
            LET vExisteTel     = 0;
            LET vExisteTelAct  = 0;
        END FOREACH;  
            
        LET viContador2 = viContador2 + 1;
        
        COMMIT WORK;
        LET viEnTransacc = 0;
        
        LET vcNumCte = '';
    END FOREACH;
    
    END;

    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;

END PROCEDURE;