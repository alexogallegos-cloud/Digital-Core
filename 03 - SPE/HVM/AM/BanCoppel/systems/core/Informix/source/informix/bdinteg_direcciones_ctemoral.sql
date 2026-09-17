create procedure "informix".direcciones_ctemoral( pempresa char(3),
                                                  pfuncion char(1),
                                                  pnumcte char(20),
                                                  psecuencia smallint,
                                                  ptipodir char(1),
                                                  pcalle char(40),
                                                  pcolonia char(60),
                                                  pmunicipio char(5),
                                                  pentre_calles char(40),
                                                  ppais char(3),
                                                  pentidad char(2),
                                                  plocalidad char(3),
                                                  pcodpostal char(5),
                                                  ptipotel1 char(1),
                                                  ptelefono1 char(13),
                                                  ptipotel2 char(1),
                                                  ptelefono2 char(13),
                                                  ptipotel3 char(1),
                                                  ptelefono3 char(13),
                                                  pextension char(5),
                                                  pestado_inegi char(2),
                                                  pmunicipio_inegi char(3),
                                                  plocalidad_inegi char(4),
                                                  pnociudad smallint,
                                                  pnoext char(10),
                                                  pnoint char(10),
                                                  pdepto char(6),
                                                  pnocalle integer,
                                                  pnocolonia integer,
                                                  ppuntocar char(1),
                                                  punihabi char(1),
                                                  pmanz smallint,
                                                  ppotros smallint,
                                                  pandador smallint,
                                                  petapa smallint,
                                                  plote smallint,
                                                  pedif smallint,
                                                  pentrada smallint,
                                                  pobserva char(80),
                                                  puser_insert char(8),
                                                  pfecha_insert date,
                                                  pSucursal CHAR(4) )
 returning char(5);

    define v_codret char(5);
    define v_rowid integer;
    define v_tipodir char(1);
    define v_calle char(40);
    define v_colonia char(60);
    define v_delegacion char(20);
    define v_entre_calles char(40);
    define v_pais char(3);
    define v_entidad char(2);
    define v_localidad char(3);
    define v_codpostal char(5);
    define v_telefono1 char(20);
    define v_telefono2 char(20);
    define v_estado_inegi char(2);
    define v_municipio_inegi char(3);
    define v_localidad_inegi char(4);
    define v_fax char(20);
    define v_nombre char(40);
    define v_longitud, v_longcte, v_secuencia smallint;
    define v_numcte char(20);
    define v_existe char(1);
    define v_sqlerr, v_isamerr integer;
    DEFINE v_CodRetTel CHAR(5);

    --- SET DEBUG FILE TO "/tmp/direcciones_ctemoral.out";
    --- TRACE ON;

    begin
    
    on exception set v_sqlerr, v_isamerr
        if v_sqlerr != 0 then
            let v_codret=v_sqlerr;
            return v_codret;
        end if;
    end exception;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    let v_codret = "000";
    LET v_CodRetTel = '';

    select numcte 
      into v_numcte 
      from si_cliente
     where numcte = pnumcte;

    if v_numcte is null then
        let v_codret = "104";
        return v_codret;
    end if

    if pfuncion = "C" then
        delete from si_direcciones
         where numcte = pnumcte 
           and secuencia = psecuencia;
           
        delete from si_direcciones_actual
         where numcte = pnumcte 
           and secuencia = psecuencia;
           
        let pfuncion = "A";
    end if

    if pfuncion = "A" then

        /* #########################
        select nombre 
          into v_nombre
          from si_paises
         where pais = ppais;
         
        if v_nombre is null then
            let v_codret="121";
            return v_codret;
        end if;

        select nombre 
          into v_nombre
          from si_estados
         where pais=ppais 
           and estado=pentidad;

        if v_nombre is null then
            let v_codret="122";
            return v_codret;
        end if;

        select nombre 
          into v_nombre
          from si_ciudades
         where pais=ppais 
           and estado=pentidad 
           and ciudad=plocalidad;
           
        if v_nombre is null then
            let v_codret="123";
            return v_codret;
        end if;
        ######################### */

        select max(secuencia) 
          into psecuencia
          from si_direcciones_actual
         where numcte = pnumcte;

        if psecuencia is null then
            let psecuencia = 1;
        else
            let psecuencia = psecuencia + 1;
        end if;
    
        insert into si_direcciones
        ( numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
          pais,estado,ciudad,municipio,cod_postal,apart_postal,
          /* tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension, */
          estado_inegi,municipio_inegi,localidad_inegi,
          numerociudad,numeroextcalle,numerointcalle,departamento,
          numerocalle,numerocolonia,puntocardinal,unidadhabitac,
          manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
          user_insert,fecha_insert )
        values
        ( pnumcte, psecuencia, ptipodir, pcalle, pcolonia, pentre_calles,
          ppais,pentidad,plocalidad, pmunicipio, pcodpostal,"",
          /* ptipotel1,ptelefono1,ptipotel2,ptelefono2,ptipotel3,ptelefono3,pextension, */
          pestado_inegi,pmunicipio_inegi,plocalidad_inegi,
          pnociudad,pnoext,pnoint,pdepto,
          pnocalle,pnocolonia,ppuntocar,punihabi,
          pmanz,ppotros,pandador,petapa,plote,pedif,pentrada,pobserva,
          puser_insert,pfecha_insert );
          
        IF ( ( ptipotel1 is not null AND ptipotel1 <> '' ) AND ( ptelefono1 is not null AND ptelefono1 <> '' ) ) THEN
            CALL sp_registra_telefonos(pempresa, pnumcte, ptelefono1, 1, '', 0, 7, puser_insert)
            RETURNING v_CodRetTel;
        END IF;
        
        IF ( ( ptipotel2 is not null AND ptipotel2 <> '' ) AND ( ptelefono2 is not null AND ptelefono2 <> '' ) ) THEN
            CALL sp_registra_telefonos(pempresa, pnumcte, ptelefono2, 2, '', 0, 7, puser_insert)
            RETURNING v_CodRetTel;
        END IF;
        
        IF ( ( ptipotel3 is not null AND ptipotel3 <> '' ) AND ( ptelefono3 is not null AND ptelefono3 <> '' ) ) THEN
            CALL sp_registra_telefonos(pempresa, pnumcte, ptelefono3, 3, pextension, 0, 7, puser_insert)
            RETURNING v_CodRetTel;
        END IF;
          
        return v_codret;
        
    end if;
    
    end;
    
end procedure

DOCUMENT
"Alta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hernandez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".consnombrenumctepm(pEmpresa CHAR(3),
						pNombre1 CHAR(26),
						pNombre2 CHAR(26),
                        pApellPaterno CHAR(26),
                        pApellMaterno CHAR(26),
						pFechaNac DATE,
						pRfc CHAR(13),
						pRazonSocial CHAR(60),
                        pSecuencia SMALLINT)

RETURNING 
CHAR(5)  AS COD_RET,
CHAR(60) AS NOMBRE_COMPLETO,
CHAR(20) AS NUM_CTE,
CHAR(13) AS RFC;

--DECLARACIONES
DEFINE ISqlErr 				INTEGER;
DEFINE cRfc 				CHAR(13);
DEFINE cNombreCompleto 		CHAR(63);
DEFINE cNombre1             CHAR(26);
DEFINE cNombre2             CHAR(26); 
DEFINE cApellPaterno        CHAR(26);        
DEFINE cApellMaterno        CHAR(26);
DEFINE cNumcte 				CHAR(20);
DEFINE cCodRet 				CHAR(5);
DEFINE cRazonSocial 		CHAR(60);
DEFINE cRfcAlterno          CHAR(13);

--INICIALIZACIONES
LET ISqlErr                 = 0;
LET cCodRet                 = '00000';
LET cNombreCompleto         = '';
LET cNombre1                = '';
LET cNombre2                = '';
LET cApellPaterno           = '';
LET cApellMaterno           = '';
LET cNumcte                 = '0000000000';
LET cRfc                    = '';
LET cRazonSocial            = '';
LET cRfcAlterno             = '';

BEGIN
  ON EXCEPTION SET ISqlErr
     IF ISqlErr <> 0 THEN
   	     LET cCodRet = ISqlErr;
	     RETURN cCodRet, cNombreCompleto, cNumcte, cRfc;
     END IF;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;   

   --SET DEBUG FILE TO '/home/tmp/MireyaR/sp_consultarctemoral_02.out';
   --TRACE ON;
   
IF NVL(pEmpresa,'') = ''  THEN
	LET cCodRet = '00001';
	LET cNombreCompleto = 'parametros incompletos';
	RETURN cCodRet, cNombreCompleto, cNumcte, cRfc;
END IF;


IF pRazonSocial IS NOT NULL AND pRazonSocial !="" THEN
    FOREACH
        SELECT skip pSecuencia LIMIT 21
             razon_social,numcte,rfc
 	    INTO cRazonSocial,cNumcte,cRfc
        FROM "informix".si_cliente
        WHERE razon_social = pRazonSocial
           AND apell_paterno = ''
	       AND apell_materno = ''
        ORDER BY numcte

        LET cNombreCompleto = cRazonSocial;
        RETURN cCodRet,cNombreCompleto,cNumcte,cRfc WITH RESUME;
    END FOREACH;
ELSE
    --REALIZA LA CONSULTA DE NOMBRE Y RFC DEL CLIENTE POR RFC
    IF pRfc IS NOT NULL AND pRfc != "" THEN
        FOREACH
            SELECT skip pSecuencia LIMIT 21 
                 nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc, rfc_alterno
	        INTO cNombre1,cNombre2,cApellPaterno,cApellMaterno,cNumcte,cRfc, cRfcAlterno
      	    FROM "informix".si_ctepf pf, "informix".si_cliente cl
      	    WHERE rfc = pRfc AND cl.numcte = pf.numcte
      	    ORDER BY pf.numcte

	        LET cNombreCompleto = TRIM(cApellPaterno) || " " || TRIM(cApellMaterno)
             || " " || TRIM(cNombre1) || " " || TRIM(cNombre2);
			 
			IF cRfcAlterno IS NOT NULL AND cRfcAlterno <> "" THEN
               LET cRfc = cRfcAlterno;
            END IF;
			
	        RETURN cCodRet,cNombreCompleto,cNumcte,cRfc WITH RESUME;
        END FOREACH;
    ELSE

   ---VALIDA PARAMETROS
	IF NVL(pApellPaterno,'') = ''  THEN
		LET cCodRet = "00002";
		LET cNombreCompleto = 'Debe capturar al menos uno de los dos apellidos';
		RETURN cCodRet, cNombreCompleto, cNumcte, cRfc;

	ELIF NVL(pNombre1,'') = '' THEN
		LET cCodRet = "00003";
		LET cNombreCompleto = 'Debe capturar al menos uno de los dos nombres';
		RETURN cCodRet, cNombreCompleto, cNumcte,cRfc;
	ELSE
        IF ( pApellPaterno IS NULL OR pApellPaterno = "" ) THEN
           LET pApellPaterno = "";
        ELSE
            LET pApellPaterno = TRIM(pApellPaterno)||"*";

        END IF;  

        IF ( pApellMaterno IS NULL OR pApellMaterno = "" ) THEN
           LET pApellMaterno = "";
        ELSE
           LET pApellMaterno = TRIM(pApellMaterno)||"*";

        END IF;  

        IF ( pNombre1 IS NULL OR pNombre1 = "" ) THEN
           LET pNombre1 = "";
        ELSE
           LET pNombre1 = TRIM(pNombre1)||"*";
        END IF;  

        IF ( pNombre2 IS NULL OR pNombre2 = "" ) THEN
           LET pNombre2 = "";
        ELSE
           LET pNombre2 = TRIM(pNombre2)||"*";
        END IF;  

        --SE REALIZA UNA CONSULTA DEL NOMBRE Y RFC DEL CLIENTE POR FECHA DE NACIMIENTO
		IF NVL(pFechaNac,'') <> '' THEN
			FOREACH
				SELECT skip pSecuencia LIMIT 21
                     nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc, rfc_alterno
				INTO cNombre1,cNombre2,cApellPaterno,cApellMaterno,cNumcte,cRfc, cRfcAlterno
				FROM "informix".si_ctepf pf, "informix".si_cliente cl
				WHERE cl.apell_paterno matches pApellPaterno
				AND cl.apell_materno matches pApellMaterno
				AND cl.nombre1 matches pNombre1
				AND cl.nombre2 matches pNombre2
				AND pf.fecha_nac = pFechaNac
				AND cl.numcte = pf.numcte
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2


				LET cNombreCompleto = TRIM(cApellPaterno) || " " || TRIM(cApellMaterno)
						|| " " || TRIM(cNombre1) || " " || TRIM(cNombre2);
						
				IF cRfcAlterno IS NOT NULL AND cRfcAlterno <> "" THEN
                   LET cRfc = cRfcAlterno;
                END IF;
				
				RETURN cCodRet,cNombreCompleto,cNumcte,cRfc WITH RESUME;
			END FOREACH;

		ELSE
            --SE REALIZA LA CONSULTA DEL NOMBRE Y RFC
			FOREACH
				SELECT skip pSecuencia LIMIT 21
                     nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc, rfc_alterno
				INTO cNombre1,cNombre2,cApellPaterno,cApellMaterno,cNumcte,cRfc, cRfcAlterno
				FROM "informix".si_cliente
				WHERE apell_paterno matches pApellPaterno
				AND apell_materno matches pApellMaterno
				AND nombre1 matches pNombre1
				AND nombre2 matches pNombre2
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2


				LET cNombreCompleto = TRIM(cApellPaterno) || " " || TRIM(UPPER(cApellMaterno))
						|| " " || TRIM(cNombre1) || " " || TRIM(cNombre2);
						
				IF cRfcAlterno IS NOT NULL AND cRfcAlterno <> "" THEN
                   LET cRfc = cRfcAlterno;
                END IF;		
						
				RETURN cCodRet,cNombreCompleto,cNumcte,cRfc WITH RESUME;
			END FOREACH;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta clientes por nombre(s) y apellido(s) y',
'por fecha de nacimiento si asi se requiere',
'AUTOR : Mireya Reyes',
'FECHA DE CREACION: 02/08/2013',
'VERSION: 20130802.0938',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultaactividadsocial(pEmpresa CHAR(3), pCodigo CHAR(3), pOrder SMALLINT)

	RETURNING

		CHAR(6)	AS CodRet,
		CHAR(80) AS MensajeErr,
		CHAR(3)	AS Actividadgiro,
		CHAR(40) AS DescActivgiro;
--------------------------DECLARACION DE VARIABLES
		DEFINE iSqlErr			INTEGER;
		DEFINE iSam_Err   		INTEGER;
		DEFINE cError_Info 		CHAR(200);
		DEFINE cCodRet         	CHAR(6);
		DEFINE cMensajeErr		CHAR(80);
		DEFINE cCodActiv		CHAR(3);
		DEFINE cDescActiv		CHAR(30);
		DEFINE sBandera			SMALLINT;
--------------------------INICIALIZACION DE VARIABLES
		LET iSqlErr				= 0;
		LET iSam_Err			= 0;
		LET cError_Info			= '';
		LET cCodRet         	= '000000';
		LET cMensajeErr			= 'PROCESO EXITOSO';
		LET cCodActiv			= '';
		LET cDescActiv			= '';
		LET sBandera			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iSam_Err, cError_Info
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeErr = 'ERROR EN EL PROCEDIMIENTO PRINCIPAL';
			RETURN 	TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,''));

		END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

-------------SET DEBUG FILE TO '/dbexportb/Hugo/sp_consultaactividadsocial.out';
-------------TRACE ON;
		IF NVL(pEmpresa, '') = '' THEN  ----NO SE RECIBIO PARAMETRO DE EMPRESA
			LET cCodRet		= '000001';
			LET cMensajeErr	= 'ERROR EN EL PARAMETRO DE EMPRESA';

			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,''));

		END IF

		IF  NVL(pCodigo, '') = '' THEN  ---CONSULTA GENERAL, REGRESA TODOS LOS REGISTROS

			IF pOrder = 0 THEN	--MUESTRA LOS REGISTROS ORDENADOS POR EL CODIGO

				FOREACH

					SELECT codigo, descripcion
					INTO cCodActiv, cDescActiv
					FROM "informix".si_actividadsocial
					WHERE empresa = pEmpresa
					ORDER BY codigo

					RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,'')) WITH RESUME;

				END FOREACH;

			ELIF pOrder = 1 THEN	--MUESTRA LOS REGISTROS ORDENADOS POR LA DESCRIPCION

				FOREACH

					SELECT codigo, descripcion
					INTO cCodActiv, cDescActiv
					FROM "informix".si_actividadsocial
					WHERE empresa = pEmpresa
					ORDER BY descripcion

					RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,'')) WITH RESUME;

				END FOREACH;

			ELSE
				LET cCodRet		= '000002';
				LET cMensajeErr    = 'ERROR EN EL PARAMETRO ORDENAR';

				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,''));

			END IF

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	--NO EXISTEN DATOS EN LA TABLA
				LET cCodRet		= '000003';
				LET cMensajeErr    = 'ERROR NO HAY DATOS EN LA TABLA';

				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,''));

			END IF

		ELSE  	 --CONSULTA CON UN CODIGO EN ESPECIFICO

			SELECT codigo, descripcion
			INTO cCodActiv, cDescActiv
			FROM "informix".si_actividadsocial
			WHERE empresa = pEmpresa
			AND codigo =  pCodigo;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	 --NO HAY REGISTROS EN LA TABLA
				LET cCodRet		= '000004';
				LET cMensajeErr    = 'ERROR NO HAY REGISTROS EN LA TABLA';

			END IF

			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodActiv,'')), TRIM(NVL(cDescActiv,''));

		END IF

	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta catalogo consultaactividadsocial',
'Modificó: Hugo Vazquez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.0120',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultagiromercantil(pCodGiro CHAR(3))

	RETURNING

		CHAR(6)	AS cCodret,
		CHAR(80) AS MensajeErr,
		CHAR(3)	AS cActividadGiro,
		CHAR(40) AS cDescActivGiro;
--------------------------DECLARACION DE VARIABLES
		DEFINE iSqlErr			INTEGER;
		DEFINE iSam_Err   		INTEGER;
		DEFINE cError_Info 		CHAR(200);

		DEFINE cCodRet         	CHAR(6);
		DEFINE cMensajeErr		CHAR(80);
		DEFINE cActividadGiro	CHAR(3);
		DEFINE cDescActivGiro	CHAR(40);
--------------------------INICIALIZACION DE VARIABLES
		LET iSqlErr				= 0;
		LET iSam_Err			= 0;
		LET cError_Info			= '';
		LET cCodRet         	= '000000';
		LET cMensajeErr			= 'PROCESO EXITOSO';
		LET cActividadGiro		= '';
		LET cDescActivGiro		= '';

	BEGIN

		ON EXCEPTION SET iSqlErr, iSam_Err, cError_Info
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeErr = 'ERROR EN EL PROCEDIMIENTO PRINCIPAL';
			RETURN 	TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cActividadGiro,'')), TRIM(NVL(cDescActivGiro,''));
		END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

--------------------------SET DEBUG FILE TO '/dbexportb/Hugo/sp_consultagiromercantil.out';
--------------------------TRACE ON;

		IF  NVL(pCodGiro, '') = '' THEN ---CONSULTA GENERAL, REGRESA TODOS LOS REGISTROS

			FOREACH

					SELECT TRIM(actividad), TRIM(nombre)
					INTO cActividadGiro, cDescActivGiro
					FROM "informix".si_actecon
					WHERE actividad = actividad
					ORDER BY actividad

				RETURN 	TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cActividadGiro,'')), TRIM(NVL(cDescActivGiro,'')) WITH RESUME;

			END FOREACH;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	--NO EXISTEN DATOS EN LA TABLA
				LET cCodRet	= '000001';
				LET cMensajeErr    = 'ERROR NO EXISTEN DATOS EN LA TABLA';

				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cActividadGiro,'')), TRIM(NVL(cDescActivGiro,''));

			END IF

		ELSE	--CONSULTA CON UN CODIGO EN ESPECIFICO

			SELECT TRIM(actividad), TRIM(nombre)
			INTO cActividadGiro, cDescActivGiro
			FROM "informix".si_actecon
			WHERE actividad =  pCodGiro;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	 --NO HAY REGISTROS EN LA TABLA
				LET cCodRet = '000002';
				LET cMensajeErr = 'ERROR NO HAY REGISTROS EN LA TABLA';

			END IF

			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cActividadGiro,'')), TRIM(NVL(cDescActivGiro,''));

		END IF

	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta catalogo giromercantil',
'Modificó: Hugo Vazquez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_tipo_admin_pm_gobierno(pEmpresa CHAR(3),pCodigo CHAR(3),pOrden CHAR(1))
	RETURNING
	CHAR(6) AS 	CODRET,
	CHAR(3) AS 	EMPRESA,
	CHAR(3) AS 	CODIGO,
	CHAR(20) AS DESCRIPCION;

	--DEFINICION DE VARIABLES.
	DEFINE cEmpresa 	CHAR(3);
	DEFINE cCodigo 		CHAR(3);
	DEFINE cDescripcion CHAR(20);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(6);

	--INICIALIZACION DE VARIABLES.
	LET cEmpresa 		= '';
	LET cCodigo 		= '';
	LET cDescripcion 	='';
	LET iSqlErr 		= 0;
	LET cCodRet 		= '000000';

	--SET DEBUG FILE TO '/respaldosbd/josue/sp_tipo_admin_pm_gobierno.out';
	--TRACE ON;

	BEGIN
		-- CONTROL DE ERRORES.
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- SE VALIDA SI LA EMPRESA VIENE VACIA.
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '000001';
			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;

		--SE VALIDA EL TIPO DE ORDENAMIENTO DE LA INFORMACIÓN.
		IF (NVL(pOrden,'') NOT IN ('1','2')) THEN
			LET cCodRet = '000002'; --PARAMETRO ORDEN INVALIDO.
			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;

		IF pOrden = '1' THEN --ORDEN DE LA INFORMACIÓN POR CODIGO DEL TIPO DE ADMINISTRACIÓN.
			IF (NVL(pCodigo,'')) = '' THEN
				FOREACH
					--OBTIENE EL CODIGO Y DESCRIPCION DEL TIPO DE ADMINISTRACIÓN, YA SEA UNO SI SE ESPECIFÍCA EL CODIGO O BARRE TODO EL CATALOGO.
					SELECT empresa,codigo,descripcion
					INTO cEmpresa,cCodigo,cDescripcion
					FROM "informix".si_tipo_admin_pm
					WHERE empresa = pEmpresa
					ORDER BY codigo
					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,'')) WITH RESUME;
				END FOREACH
			ELSE
				--OBTIENE EL CODIGO Y DESCRIPCION DEL TIPO DE ADMINISTRACIÓN, YA SEA UNO SI SE ESPECIFÍCA EL CODIGO O BARRE TODO EL CATALOGO.
				SELECT empresa,codigo,descripcion
				INTO cEmpresa,cCodigo,cDescripcion
				FROM "informix".si_tipo_admin_pm
				WHERE empresa = pEmpresa
				AND codigo = pCodigo;

				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cCodRet = '000003';					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				END IF

				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));

			END IF

		ELIF pOrden = '2' THEN --ORDEN DE LA INFORMACIÓN POR DESCRIPCION DEL TIPO DE ADMINISTRACIÓN.
			IF (NVL(pCodigo,'')) = '' THEN
				FOREACH
					--OBTIENE EL CODIGO Y DESCRIPCION DEL TIPO DE ADMINISTRACIÓN, YA SEA UNO SI SE ESPECIFÍCA EL CODIGO O BARRE TODO EL CATALOGO.
					SELECT empresa,codigo,descripcion
					INTO cEmpresa,cCodigo,cDescripcion
					FROM "informix".si_tipo_admin_pm
					WHERE empresa = pEmpresa
					ORDER BY descripcion
					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,'')) WITH RESUME;
				END FOREACH
			ELSE
				--OBTIENE EL CODIGO Y DESCRIPCION DEL TIPO DE ADMINISTRACIÓN, YA SEA UNO SI SE ESPECIFÍCA EL CODIGO O BARRE TODO EL CATALOGO.
				SELECT empresa,codigo,descripcion
				INTO cEmpresa,cCodigo,cDescripcion
				FROM "informix".si_tipo_admin_pm
				WHERE empresa = pEmpresa
				AND codigo = pCodigo;

				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cCodRet = '000003';					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				END IF;

				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				
			END IF	
		END IF;
		IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
			LET cCodRet = '000003';			RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;
	END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener el tipo de administración de persona moral de gobierno',
'AUTOR : Josué remberto zazueta acosta',
'FECHA : 24/06/2013',
'VERSION:20130624.1630',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_tipo_org_pm_gobierno(pEmpresa CHAR(3),pCodigo CHAR(3),pOrden CHAR(1))
	RETURNING
	CHAR(6) 	AS cCodRet,
	CHAR(3) 	AS cEmpresa,
	CHAR(3) 	AS cCodigo,
	CHAR(40) 	AS cDescripcion;

	--DEFINICION DE VARIABLES.
	DEFINE cEmpresa 	CHAR(3);
	DEFINE cCodigo 		CHAR(3);
	DEFINE cDescripcion CHAR(40);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(6);

	--INICIALIZACION DE VARIABLES.
	LET cEmpresa 		= '';
	LET cCodigo 		= '';
	LET cDescripcion 	='';
	LET iSqlErr 		= 0;
	LET cCodRet 		= '000000';

	--SET DEBUG FILE TO '/respaldosbd/josue/sp_tipo_org_pm_gobierno.out';
	--TRACE ON;

	BEGIN
		--CONTROL DE ERRORES.
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- SE VALIDA SI LA EMPRESA VIENE VACIA.
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '000001';
			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;

		--SE VALIDA EL TIPO DE ORDENAMIENTO DE LA INFORMACIÓN.
		IF (NVL(pOrden,'') NOT IN ('1','2')) THEN
			LET cCodRet = '000002';			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;

		IF pOrden = '1' THEN --ORDEN DE LA INFORMACIÓN POR CODIGO DEL TIPO DE ORGANIZACION.
			IF (NVL(pCodigo,'')) = '' THEN
				FOREACH
					-- SI EL CÓDIGO TRAE VALOR SE OBTIENE SOLO EL TIPO DE ORGANIZACIÓN QUE SE ESPECIFÍCA Y SI NO BARRE TODO EL CATALOGO.
					SELECT empresa,codigo,descripcion
					INTO cEmpresa,cCodigo,cDescripcion
					FROM "informix".si_tipo_org_pm
					WHERE empresa = pEmpresa
					ORDER BY codigo
					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,'')) WITH RESUME;
				END FOREACH 
			ELSE
				-- SI EL CÓDIGO TRAE VALOR SE OBTIENE SOLO EL TIPO DE ORGANIZACIÓN QUE SE ESPECIFÍCA Y SI NO BARRE TODO EL CATALOGO.
				SELECT empresa,codigo,descripcion
				INTO cEmpresa,cCodigo,cDescripcion
				FROM "informix".si_tipo_org_pm
				WHERE empresa = pEmpresa
				AND codigo = pCodigo;
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cCodRet = '000003';					RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				END IF;
				
				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
			END IF


		ELIF pOrden = '2' THEN --ORDEN DE LA INFORMACIÓN POR DESCRIPCION DEL TIPO DE ORGANIZACION.
			IF (NVL(pCodigo,'')) = '' THEN
				FOREACH
					-- SI EL CÓDIGO TRAE VALOR SE OBTIENE SOLO EL TIPO DE ORGANIZACIÓN QUE SE ESPECIFÍCA Y SI NO BARRE TODO EL CATALOGO.
					SELECT empresa,codigo,descripcion
					INTO cEmpresa,cCodigo,cDescripcion
					FROM "informix".si_tipo_org_pm
					WHERE empresa = pEmpresa
					ORDER BY descripcion
					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,'')) WITH RESUME;
				END FOREACH

			ELSE
				-- SI EL CÓDIGO TRAE VALOR SE OBTIENE SOLO EL TIPO DE ORGANIZACIÓN QUE SE ESPECIFÍCA Y SI NO BARRE TODO EL CATALOGO.
				SELECT empresa,codigo,descripcion
				INTO cEmpresa,cCodigo,cDescripcion
				FROM "informix".si_tipo_org_pm
				WHERE empresa = pEmpresa
				AND codigo = pCodigo;
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cCodRet = '000003';					RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				END IF;
				
				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
			END IF
		END IF;
		IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
			LET cCodRet = '000003';			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;
	END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener el tipo de organización de persona moral de gobierno.',
'AUTOR : Josué remberto zazueta acosta.',
'FECHA : 24/06/2013.',
'VERSION:20130624.1630.',
'BD: bdinteg.';

CREATE PROCEDURE "informix".sp_tipo_poder_pm_gobierno(pEmpresa CHAR(3),pCodigo CHAR(3),pOrden CHAR(1))
	RETURNING
	CHAR(6) AS CODRET,
	CHAR(3) AS EMPRESA,
	CHAR(3) AS CODIGO,
	CHAR(20)AS DESCRIPCION;

	--DEFINICION DE VARIABLES.
	DEFINE cEmpresa 	CHAR(3);
	DEFINE cCodigo 		CHAR(3);
	DEFINE cDescripcion CHAR(20);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(6);

	--INICIALIZACION DE VARIABLES.
	LET cEmpresa 		= '';
	LET cCodigo 		= '';
	LET cDescripcion 	='';
	LET iSqlErr 		= 0;
	LET cCodRet 		= '000000';

	--SET DEBUG FILE TO '/respaldosbd/josue/sp_tipo_poder_pm_gobierno.out';
	--TRACE ON;

	BEGIN
		-- CONTROL DE ERRORES.
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- SE VALIDA SI LA EMPRESA VIENE VACIA.
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '000001';
			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;

		--SE VALIDA EL TIPO DE ORDENAMIENTO DE LA INFORMACIÓN.
		IF (NVL(pOrden,'') NOT IN ('1','2')) THEN
			LET cCodRet = '000002'; --PARAMETRO ORDEN INVALIDO.
			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;

		IF pOrden = '1' THEN --ORDEN DE LA INFORMACIÓN POR CODIGO DEL TIPO DE PODER.
			IF (NVL(pCodigo,'')) = '' THEN
				-- SI EL CÓDIGO NO TRAE VALOR SE OBTIENEN TODOS LOS TIPOS DE PODER DEL CATALOGO Y SI NO SE TRAE EL ESPECIFICO.
				FOREACH
					SELECT empresa,codigo,descripcion
					INTO cEmpresa,cCodigo,cDescripcion
					FROM "informix".si_tipo_poder_pm
					WHERE empresa = pEmpresa
					ORDER BY codigo
					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,'')) WITH RESUME;
				END FOREACH
			ELSE
				-- SI EL CÓDIGO NO TRAE VALOR SE OBTIENEN TODOS LOS TIPOS DE PODER DEL CATALOGO Y SI NO SE TRAE EL ESPECIFICO.
				SELECT empresa,codigo,descripcion
				INTO cEmpresa,cCodigo,cDescripcion
				FROM "informix".si_tipo_poder_pm
				WHERE empresa = pEmpresa
				AND codigo = pCodigo;

				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cCodRet = '000003';					RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				END IF;

				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
			END IF

		ELIF pOrden = '2' THEN--ORDEN DE LA INFORMACIÓN POR DESCRIPCION DEL TIPO DE PODER.
			IF (NVL(pCodigo,'')) = '' THEN
				-- SI EL CÓDIGO NO TRAE VALOR SE OBTIENEN TODOS LOS TIPOS DE PODER DEL CATALOGO Y SI NO SE TRAE EL ESPECIFICO.
				FOREACH
					SELECT empresa,codigo,descripcion
					INTO cEmpresa,cCodigo,cDescripcion
					FROM "informix".si_tipo_poder_pm
					WHERE empresa = pEmpresa
					ORDER BY descripcion
					RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,'')) WITH RESUME;
				END FOREACH
			ELSE
				-- SI EL CÓDIGO NO TRAE VALOR SE OBTIENEN TODOS LOS TIPOS DE PODER DEL CATALOGO Y SI NO SE TRAE EL ESPECIFICO.
				SELECT empresa,codigo,descripcion
				INTO cEmpresa,cCodigo,cDescripcion
				FROM "informix".si_tipo_poder_pm
				WHERE empresa = pEmpresa
				AND codigo = pCodigo;

				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cCodRet = '000003';					RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
				END IF;

				RETURN TRIM(cCodRet),TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));

			END IF
		END IF;
		IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
			LET cCodRet = '000003';			RETURN TRIM(cCodRet), TRIM(NVL(cEmpresa,'')),TRIM(NVL(cCodigo,'')),TRIM(NVL(cDescripcion,''));
		END IF;
	END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener el tipo de poder de persona moral de gobierno.',
'AUTOR : Josué remberto zazueta acosta.',
'FECHA : 24/06/2013.',
'VERSION:20130624.1630.',
'BD: bdinteg.';

CREATE PROCEDURE "informix".sp_desbctasfus(pNumeroCliente CHAR(20), pCuentaOcredito CHAR(20), pUsuario CHAR(10))
RETURNING CHAR(5);


--DEFINICION DE VARIABLES
DEFINE cCodRet        	CHAR(5);
DEFINE iSqlErr        	INTEGER;
DEFINE dFecha         	DATE;
DEFINE cTemp		  	CHAR(80);		--DSB20130806
DEFINE cTmpCod		  	CHAR(6);		--DSB20130806
DEFINE cValidaNumCte	CHAR(20);		--DSB20130911
DEFINE iValidaIdUniPro	INTEGER;		--DSB20130911
DEFINE iNumRows			INTEGER;		--DSB20130911
DEFINE cTotalCta        CHAR(20);
DEFINE sdoc_w			MONEY(14,2);


--INICIALIZACION DE VARIABLES
LET cCodRet   			= '00000';
LET iSqlErr   			= 0;
LET dFecha    			= '';
LET cTemp	  			= '';			--DSB20130806
LET cTmpCod				= '000000';		--DSB20130806
LET cValidaNumCte		= '';			--DSB20130911
LET iValidaIdUniPro 	= 0;			--DSB20130911
LET iNumRows			= 0;			--DSB20130911
LET cTotalCta           = '';
LET sdoc_w				=0;

	--SET DEBUG FILE TO '/informix/ArmandoM/sp_desbctasfus.out';
	--TRACE ON;
	
BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	--SET LOCK MODE TO WAIT 3;
	--SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_hoy INTO dFecha
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';


	-- Débito
    SELECT FIRST 1 num_cte, sdo_cong 
	INTO cValidaNumCte, sdoc_w															
    FROM bdicheq:"informix".sc_maechq																	
    WHERE num_cte = pNumeroCliente AND cuenta = pCuentaOcredito AND status_cta =3 AND motivo = '09';	
    LET iNumRows = DBINFO("sqlca.sqlerrd2");
    IF(iNumRows > 0) THEN	
		
		IF  sdoc_w=0  THEN
			EXECUTE PROCEDURE bdicheq:bloqueo_cta('001',pCuentaOcredito,000.00,'00','0',dFecha,pUsuario,'', '11','S','12','Z')							--DSB20130806
			INTO cTmpCod, cTemp;

			IF TRIM(cTmpCod) = '000' THEN
				SELECT cuenta  INTO cTotalCta FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = pCuentaOcredito;		
				LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF iNumRows = 0 THEN
						INSERT INTO bdinteg:"informix".si_fusbitacoradesbloqueo (id_log,cuenta,usuario,fecha,hora) VALUES (0,pCuentaOcredito,pUsuario,dFecha,CURRENT);
						LET cCodRet = '00000';
					END IF;
			ELSE
				LET cCodRet = '00002';
			END IF;
			
		ELSE
			LET cCodRet = '00004';
		END IF;	
		
	ELSE
		SELECT FIRST 1 num_cte INTO cValidaNumCte															--DSB20130911{
		FROM bdicheq:"informix".sc_maechq																	
		WHERE num_cte = pNumeroCliente AND cuenta = pCuentaOcredito AND status_cta =3 AND (motivo <> '09' OR motivo IS NULL OR motivo='');	
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows > 0) THEN	
			LET cCodRet= '00005';	
			ELSE
			LET cCodRet= '00001';
		END IF;
    END IF;
	
	--Crédito
	SELECT FIRST 1 id_unidad_prod INTO cValidaNumCte																		--DSB20130911{
	FROM bdicred:"informix".sd_maecred																				
	WHERE numcte = pNumeroCliente AND num_credito = pCuentaOcredito AND id_unidad_prod = 3 AND cod_caract_2 = '09';	
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows > 0) THEN																									--DSB20130911}
		EXECUTE PROCEDURE bdicred:"informix".sp_desbloqueocuenta ('001', pCuentaOcredito,pUsuario,1)												--DSB20130806
		INTO cTmpCod, cTemp;
		
		IF TRIM(cTmpCod) = '000000' THEN
			SELECT cuenta  INTO cTotalCta FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = pCuentaOcredito;		
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
				IF iNumRows = 0 THEN
					INSERT INTO bdinteg:"informix".si_fusbitacoradesbloqueo (id_log,cuenta,usuario,fecha,hora) VALUES (0,pCuentaOcredito,pUsuario,dFecha,CURRENT);
					LET cCodRet = '00000';
				END IF;
		ELSE
			LET cCodRet = '00003';
		END IF;
	END IF;


RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'ELABORO: Josue Zepeda',
'FECHA: 14/05/2013',
'DESCRIPCION: PROCESO QUE SE ENCARGA DE DESBLOQUEAR LAS CUENTAS QUE LE PERTENECEN A UN DETERMINADO CLIENTE',
'BD: bdinteg',
'Fecha:			06-08-2013	DSB20130806',
'Modifico:		Jesus Horacio Lopez Gonzalez - 95526749',
'Modificacion:	Se modifica para que ejecute los procedimientos para desbloquear cuentas de clientes bloqueadas por fusion dependiendo si es de debito o de credito.',
'ASUNTO:		Modificación',
'ELABORÓ: 		95579737 José Ernesto Raygoza Villa',
'DESCRIPCIÓN: 	Se genera algunas variables en donde se les asigna la consulta que tienen la instrucción IF EXIST para validarlo con el número de registros que arroja el dbinfo.',
'FECHA: 		11/09/2013 DSB20130911',
'Folio:1302',
'Autor:92474934-Marcos Cuevas',
'Fecha: 26/09/2013',
'Modificación:Se añade validacion para que no guarde dos veces en la tabla de log',
'Sustento: comentarios 02-09-2013 RQM 06 246',
'Solicita:Armando Morales',
'BD:bdinteg';

CREATE PROCEDURE "informix".sp_desbctasfus_conscte(pNumCte CHAR(20),pAnalista CHAR(20))
RETURNING   CHAR(5)   AS CodigoRetorno,
			CHAR(26)  AS  ApellPaterno,
			CHAR(26)  AS ApellMaterno,
			CHAR(26)  AS Nombre,
			CHAR(26)  AS Nombre2 ,
			CHAR(4)   AS Sucursal,
			CHAR(13)  AS RFC,
			CHAR(2)   AS StatusCte,
			DATE      AS FechaAlta,
			DATE      AS FechaNac,
			CHAR(1)   AS Sexo,
			CHAR(26)  AS ApellPaternoCteI,
			CHAR(26)  AS ApellMaternoCteI,
			CHAR(26)  AS NombreCteI,
			CHAR(26)  AS Nombre2CteI ,
			CHAR(4)   AS SucursalCteI,
			CHAR(13)  AS RFCCteI,
			CHAR(2)   AS StatusCteCteI,
			DATE      AS FechaAltaCteI,
			DATE      AS FechaNacCteI,
			CHAR(1)   AS SexoCteI,
			CHAR(20)  AS NumCteI;

--DECLARACION DE VARIABLES
DEFINE cCodRet        		CHAR(5);
DEFINE cApellPaterno  		CHAR(26);
DEFINE cApellMaterno  		CHAR(26);
DEFINE cNombre1       		CHAR(26);
DEFINE cNombre2       		CHAR(26);
DEFINE cSucursal      		CHAR(4);
DEFINE cRFC          		CHAR(13);
DEFINE cStatusCte     		CHAR(2);
DEFINE dFechaAlta     		DATE;
DEFINE dFechaNac     		DATE;
DEFINE iSqlErr       		INTEGER;
DEFINE iIsamErr       		INTEGER;
DEFINE iCont         		INTEGER;
DEFINE cSexo         		CHAR(1);
DEFINE cTpoPers      		CHAR(2);
DEFINE cNumCteTras	  		CHAR(20);
DEFINE cApellPaternoCteI  	CHAR(26);
DEFINE cApellMaternoCteI  	CHAR(26);
DEFINE cNombre1CteI      	CHAR(26);
DEFINE cNombre2CteI      	CHAR(26);
DEFINE cSucursalCteI    	CHAR(4);
DEFINE cRFCCteI         	CHAR(13);
DEFINE cStatusCteCteI   	CHAR(2);
DEFINE dFechaAltaCteI   	DATE;
DEFINE dFechaNacCteI    	DATE;
DEFINE cSexoCteI        	CHAR(1);
DEFINE cTpoPersCteI     	CHAR(2);
DEFINE cValidaCteTit		CHAR(20);		--DSB20130911
DEFINE iNumRows				INTEGER;		--DSB20130911
DEFINE dFechaInsert			DATE;
DEFINE dtHora				DATETIME YEAR TO FRACTION(3);

--INICIALIZACION DE VARIABLES
LET cCodRet       			= '00000';
LET cApellPaterno 			= '';
LET cApellMaterno			= '';
LET cNombre1     			= '';
LET cNombre2     			= '';
LET cSucursal    			= '';
LET cRFC         			= '';
LET cStatusCte    			= '';
LET dFechaAlta    			= DATE(1);
LET dFechaNac    			= DATE(1);
LET iSqlErr      			= 0;
LET iIsamErr      			= 0 ;
LET cSexo         			= '';
LET cTpoPers      			= '';

LET cApellPaternoCteI 		= '';
LET cApellMaternoCteI 		= '';
LET cNombre1CteI      		= '';
LET cNombre2CteI      		= '';
LET cSucursalCteI     		= '';
LET cRFCCteI          		= '';
LET cStatusCteCteI    		= '';
LET dFechaAltaCteI    		= DATE(1);
LET dFechaNacCteI     		= DATE(1);
LET cSexoCteI         		= '';
LET cTpoPersCteI      		= '';
LET cNumCteTras 	  		= '';
LET cValidaCteTit	  		= '';			--DSB20130911
LET iNumRows				= 0;			--DSB20130911
LET dFechaInsert			= DATE(1);
LET dtHora					= CURRENT;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(NVL(cApellPaterno, '')), TRIM(NVL(cApellMaterno, '')), TRIM(NVL(cNombre1, '')),
			TRIM(NVL(cNombre2, '')), TRIM(NVL(cSucursal, '')), TRIM(NVL(cRFC, '')), TRIM(NVL(cStatusCte,'')), NVL(dFechaAlta, DATE(1)),
			NVL(dFechaNac, DATE(1)), TRIM(NVL(cSexo, '')), TRIM(NVL(cApellPaternoCteI, '')), TRIM(NVL(cApellMaternoCteI, '')), TRIM(NVL(cNombre1CteI, '')), TRIM(NVL(cNombre2CteI, '')), TRIM(NVL(cSucursalCteI, '')), TRIM(NVL(cRFCCteI, '')), TRIM(NVL(cStatusCteCteI,'')), NVL(dFechaAltaCteI, DATE(1)), NVL(dFechaNacCteI, DATE(1)), TRIM(NVL(cSexoCteI, '')), TRIM(NVL(cNumCteTras, ''));
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--SET DEBUG FILE TO '/informix/ArmandoM/sp_desbctasfus_conscte.out';
	--TRACE ON;

	IF NVL(pNumCte, '') = '' THEN  	--VALIDAMOS QUE EL PARAMETRO NO VENGA EN BLANCO
		LET cCodRet = '00100'; 		--PARAMETRO DE ENTRADA INVALIDO
	ELIF LENGTH(pNumCte)<> 9 THEN 	--VALIDAMOS QUE EL NO. DE CLIENTE VENGA CON EL FORMATO
		LET cCodRet = '00200'; 		--LONGITUD INVALIDA PARA EL PARAMETRO DE ENTRADA
	ELSE
		SELECT FIRST 1 cliente_tit INTO cValidaCteTit							--DSB20130911{
		FROM bdinteg:"informix".log_fusionclientes
		WHERE cliente_tit = pNumCte;
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows > 0) THEN
			SELECT FIRST 1 cliente_tit INTO cValidaCteTit
			FROM bdinteg:"informix".log_fusionclientes
			WHERE cliente_tit = pNumCte AND user_insert = pAnalista;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows = 0) THEN												--DSB20130911}
				LET cCodRet = '00001';
			ELSE
				SELECT tpo_persona, apell_paterno, apell_materno, nombre1, nombre2, sucursal, rfc, status_cte, fecha_alta
				INTO cTpoPers, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cSucursal, cRFC, cStatusCte, dFechaAlta
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = pNumCte;
				LET iNumRows = DBINFO("sqlca.sqlerrd2");						--DSB20130911
				IF(iNumRows = 0) THEN											--DSB20130911
					LET cCodRet = '00300'; 		--NUMERO DE CLIENTE NO EXISTE
				ELSE
					IF cStatusCte = 'BA' THEN
						LET cCodRet = '00400'; 	--EL STATUS DEL CLIENTE INDICA QUE EL CLIENTE SE HA DADO DE BAJA O ESTA CANCELADO
					ELSE
						IF cTpoPers = '01' THEN
							SELECT fecha_nac, sexo
							INTO dFechaNac, cSexo
							FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumCte;
							LET iNumRows = DBINFO("sqlca.sqlerrd2");														--DSB20130911
							IF(iNumRows = 0) THEN																			--DSB20130911
									LET cCodRet = '00500'; 	--INCONGRUENCIA DE DATOS
								END IF
						ELSE
							LET cCodRet = '00700'; 			--PERSONA MORAL
						END IF;
					END IF;

					SELECT DISTINCT(cliente_tras) INTO cNumCteTras FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte 
					AND fecha_insert =(SELECT MAX(fecha_insert )FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte)
					AND fecha_hora =(SELECT MAX(fecha_hora )FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte);
					LET iNumRows = DBINFO("sqlca.sqlerrd2");	
					IF iNumRows=0 THEN
						SELECT DISTINCT(cliente_tras) INTO cNumCteTras FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte 
						AND fecha_insert =(SELECT MAX(fecha_insert )FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte);
					END IF;

					SELECT tpo_persona, apell_paterno, apell_materno, nombre1, nombre2, sucursal, rfc, status_cte, fecha_alta
					INTO cTpoPers, cApellPaternoCteI, cApellMaternoCteI, cNombre1CteI, cNombre2CteI, cSucursalCteI, cRFCCteI, cStatusCteCteI, dFechaAltaCteI
					FROM bdinteg:"informix".si_fuscliente
					WHERE numcte = cNumCteTras;
					LET iNumRows = DBINFO("sqlca.sqlerrd2");																	--DSB20130911
					IF(iNumRows = 0) THEN																						--DSB20130911
						LET cCodRet = '00300'; 				--NUMERO DE CLIENTE NO EXISTE
					ELSE
						IF cStatusCte = 'BA' THEN
							LET cCodRet = '00400'; 			--EL STATUS DEL CLIENTE INDICA QUE EL CLIENTE SE HA DADO DE BAJA O ESTA CANCELADO
						ELSE
							IF cTpoPers = '01' THEN
								SELECT fecha_nac, sexo
								INTO dFechaNacCteI, cSexoCteI
								FROM bdinteg:"informix".si_fusctepf WHERE numcte = cNumCteTras;
								LET iNumRows = DBINFO("sqlca.sqlerrd2");														--DSB20130911
								IF(iNumRows = 0) THEN																			--DSB20130911
									LET cCodRet = '00500'; 	--INCONGRUENCIA DE DATOS
								END IF
							ELSE
								LET cCodRet = '00700'; 		--PERSONA MORAL
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '00300';
		END IF;
	END IF;
	RETURN TRIM(cCodRet), TRIM(NVL(cApellPaterno, '')), TRIM(NVL(cApellMaterno, '')), TRIM(NVL(cNombre1, '')),
	TRIM(NVL(cNombre2, '')), TRIM(NVL(cSucursal, '')), TRIM(NVL(cRFC, '')), TRIM(NVL(cStatusCte,'')), NVL(dFechaAlta, DATE(1)),
	NVL(dFechaNac, DATE(1)), TRIM(NVL(cSexo, '')), TRIM(NVL(cApellPaternoCteI, '')), TRIM(NVL(cApellMaternoCteI, '')), TRIM(NVL(cNombre1CteI, '')), TRIM(NVL(cNombre2CteI, '')), TRIM(NVL(cSucursalCteI, '')), TRIM(NVL(cRFCCteI, '')), TRIM(NVL(cStatusCteCteI,'')), NVL(dFechaAltaCteI, DATE(1)), NVL(dFechaNacCteI, DATE(1)), TRIM(NVL(cSexoCteI, '')), TRIM(NVL(cNumCteTras, ''));
END
END PROCEDURE
DOCUMENT
'ELABORO: Marcos Cuevas',
'FECHA: 20/06/2013',
'DESCRIPCIÓN: ESTE PROCEDIMIENTO SE ENCARGA DE OBTENER LOS DATOS PERSONALES DEL CLIENTES,LOS CUALES SON REQUERIDOS PARA EL LLENADO DE LA PANTALLA DE DESBLOQUEO DE CLIENTES',
'BD: bdinteg',
'MODIFICO: Josue Zepeda',
'FECHA: 23/08/2013',
'DESCRIPCIÓN: se modifica para que tome de log_fusionclientes el cliente_tras con la fecha_insert maxima',
'BD: bdinteg',
'ASUNTO:		Modificación',
'ELABORÓ: 		José Ernesto Raygoza Villa',
'DESCRIPCIÓN: 	Se genera algunas variables en donde se les asigna la consulta que tienen la instrucción IF EXIST para validarlo directamente de la variable y no de la instucción IF EXIST',
'FECHA: 		04/09/2013 DSB20130911';

CREATE PROCEDURE "informix".sp_altamasivaempnet_alta( pCodEmpresa CHAR(3), pNombreArchivo CHAR(18), pRegistros INTEGER, pStatus CHAR(1))
RETURNING CHAR(5) as vCodRet1,
		  CHAR(100) as vMensaje,
		  CHAR(20) as vnombre_archivo,
		  CHAR(1) as vstatus;

    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2			CHAR(5);
	DEFINE vMensaje			CHAR(100);
	
	DEFINE vNomArchivo		CHAR(20);
	DEFINE vStatus			CHAR(1);
	DEFINE vNumEmp			CHAR(3);
	
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
	LET vCodRet2 = '';
	LET vMensaje = '';

    LET vNomArchivo	= '';
	LET vStatus		= '';
	LET vNumEmp		= '';
    
  BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_consecutivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vMensaje = Desc_Err;
            RETURN vCodRet1, vMensaje, vNomArchivo,vstatus;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_carga.out";
    --- TRACE ON;
    
    SET LOCK MODE TO WAIT 5;
    
	---/// VALIDA QUE LOS CAMPOS NO VENGAN VACIOS
	IF TRIM(pCodEmpresa) = '' OR TRIM(pNombreArchivo) = '' OR NVL(pRegistros,0) = 0 OR TRIM(pStatus) = '' THEN
	    LET vCodRet1 = '00001';
		LET vMensaje = 'FALTAN DATOS DE ENTRADA';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	END IF;
	
	    -- // VALIDA EL NUMERO DE EMPRESA
    LET vNumEmp  = SUBSTR(pNombreArchivo, 2, 3);
        
    IF pCodEmpresa <> vNumEmp THEN
        LET vCodRet1 = '00002';
		LET vMensaje = 'EL CODIGO DE EMPRESA NO COINCIDE CON EL NOMBRE DEL ARCHIVO';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
    END IF;
	
	---/// VALIDA LONGITUD DEL NOMBRE DEL ARCHIVO
	IF LENGTH( TRIM(pNombreArchivo) ) <> 18 THEN
        LET vCodRet1 = '00003';
		LET vMensaje = 'LA LONGITUD DEL NOMBRE DEL ARCHIVO ES INCORRECTA, DEBE SER DE 18 CARACTERES';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	END IF;
	
	--- /// VALIDA QUE EL ARCHIVO NO ESTE CARGADO
	--LET vNomArchivo = "%" || SUBSTR(pNombreArchivo,1,12) || "%";
	
	SELECT TRIM(NVL(nombre_archivo,'')), status INTO vNomArchivo, vStatus
	FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
	WHERE cod_empresa = pCodEmpresa AND nombre_archivo = TRIM(pNombreArchivo);
	
	IF vNomArchivo <> '' THEN 
		LET vCodRet1 = '00004';
		LET vMensaje = 'EL ARCHIVO YA ESTA REGISTRADO';
	ELSE
		INSERT INTO bdinteg:"informix".si_altamasivaempnet_ctrl 
		(cod_empresa,nombre_archivo,fecha_genera,hora_genera,total_registros,status)
		VALUES(pCodEmpresa,pNombreArchivo,TODAY,CURRENT,pRegistros, pStatus);
		
		SELECT TRIM(NVL(nombre_archivo,'')), status INTO vNomArchivo, vStatus
		FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
		WHERE cod_empresa = pCodEmpresa AND nombre_archivo = TRIM(pNombreArchivo);
		
		LET vCodRet1 = '00000';
		LET vMensaje = 'ARCHIVO REGISTRADO';
	END IF;	
	
	RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	
  END;
    
END PROCEDURE;