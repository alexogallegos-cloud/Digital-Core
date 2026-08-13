CREATE PROCEDURE "informix".sp_obtenerhomoclave(pNombre LVARCHAR)
	RETURNING CHAR(2) AS homoclave;

	DEFINE i INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE cNombreNumerico LVARCHAR;
	DEFINE iCodigoLetra SMALLINT;
	DEFINE bBoolValue BOOLEAN;
	DEFINE iSuma INTEGER;
	DEFINE iValor1 INTEGER;
	DEFINE iValor2 INTEGER;
	DEFINE iValor3 INTEGER;
	DEFINE iDiv1 INTEGER;
	DEFINE iDiv2 INTEGER;

	LET cCaracter = '';
	LET cNombreNumerico = '0';
	LET bBoolValue = 'f';
	LET iSuma = 0;
	LET iValor1 = 0;
	LET iValor2 = 0;
	LET iValor3 = 0;
	LET iDiv1 = 0;
	LET iDiv2 = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenerhomoclave.out';
		--TRACE ON;

		FOR i = 1 TO LENGTH(TRIM(pNombre))
			LET cCaracter = UPPER(SUBSTR(TRIM(pNombre), i, 1));

			SELECT {+INDEX(bdinteg:letras_rfc idx_letrarfc)} codigo_letra
			INTO iCodigoLetra
			FROM "informix".letras_rfc
			WHERE UPPER(letra) = cCaracter;

			IF iCodigoLetra IS NULL THEN
				LET bBoolValue = 'f';
			ELSE
				LET cNombreNumerico = TRIM(cNombreNumerico)||iCodigoLetra;
				LET bBoolValue = 't';
			END IF;

			IF NOT bBoolValue THEN

				IF ASCII(cCaracter) = 209 THEN -- Ã
					LET cNombreNumerico = TRIM(cNombreNumerico)||40;
				ELIF ASCII(cCaracter) = 38 THEN -- &
					LET cNombreNumerico = TRIM(cNombreNumerico)||10;
				ELSE
					IF cCaracter = ' ' THEN
						LET cNombreNumerico = TRIM(cNombreNumerico)||'00';
					ELIF cCaracter::SMALLINT >= 0 AND cCaracter::SMALLINT <= 9 THEN
						LET cNombreNumerico = TRIM(cNombreNumerico)||LPAD(cCaracter, 2, '0');
					END IF;
				END IF;

			END IF;

		END FOR;


		FOR i = 1 TO LENGTH(TRIM(cNombreNumerico)) - 1
			LET iValor1 = SUBSTR(TRIM(cNombreNumerico), i, 2)::INTEGER;
			LET iValor2 = SUBSTR(TRIM(cNombreNumerico), (i + 1), 1)::INTEGER;
			LET iValor3 = iValor1 * iValor2;
			LET iSuma = iSuma + iValor3;
		END FOR;

		LET iDiv1 = MOD(iSuma, 1000);
		LET iDiv2 = MOD(iDiv1, 34);
		LET iDiv1 = (iDiv1 - iDiv2) / 34;

		SELECT digito
		INTO cCaracter
		FROM "informix".homoclaves_rfc
		WHERE id_dverificador = (iDiv1 + 1);

		LET cNombreNumerico = cCaracter;

		SELECT digito
		INTO cCaracter
		FROM "informix".homoclaves_rfc
		WHERE id_dverificador = (iDiv2 + 1);

		LET cNombreNumerico = TRIM(cNombreNumerico)||cCaracter;

		RETURN TRIM(cNombreNumerico);

	END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 05/12/2013",
"DESCRIPCION: Funcion que separa una cadena de acuerdo a un delimitador indicado";

CREATE PROCEDURE "informix".sp_pais_nacimiento()
RETURNING CHAR(5) AS CodRet,CHAR(8539) AS Paisnac;
--DEFINE VARIABLES
DEFINE	iSqlErr 	INTEGER;
DEFINE	cCodRet 	CHAR(5);
DEFINE 	cParamCat 	CHAR(8539);
DEFINE cId			CHAR(3);
DEFINE cDescripcion	CHAR(30);
DEFINE cNombre 		CHAR(8539);
DEFINE cNombre1		CHAR(34);
--INICIALIZA VARIABLES
LET iSqlErr			= 0;
LET cCodRet			= '00000';
LET cParamCat 		= '';
LET cId				='';
LET cDescripcion	='';
LET cNombre			='';
LET cNombre1		='';

BEGIN
	-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cParamCat;	
		END IF;
	END EXCEPTION;

--SET DEBUG FILE TO '/informix/gaby/paisnac.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
			
			FOREACH
			    SELECT 
				{+INDEX (bdinteg:si_paisnacion 20518_156187)}
				id_pais,nombre 
				INTO cId, cDescripcion
				FROM "informix".si_paisnacion 
				ORDER BY nombre DESC
			
				LET cNombre1 = cId||';'||cDescripcion;
				LET cNombre = cNombre1||'|'||cNombre;
			END FOREACH;
			LET cParamCat = cNombre;
	RETURN cCodret,cParamCat;
END
END PROCEDURE
DOCUMENT
'AUTOR: GABRIELA GUDIÑO LOPEZ',
'FOLIO: ',
'DESCRIPCION: OBTIENE EL CATALOGO DE PAIS DE NACIMIENTO',
'FECHA: 23/08/2016',
'VERSION:1.0',
'SUSTENTO: SE DEFINIO CON VICTOR HUGO SÁNCHEZ MENDOZA ',
'RQI 61 375 Almacenamiento de país de nacimiento en alta de solicitudes móviles',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_situacionesclientescoppelporenviar_pbas4 (pEmpresa CHAR(3), pNumCte CHAR(20), pCliente CHAR(20), pIduSituacion INTEGER,pResultados INTEGER,
															pStatus CHAR(3), pMensaje CHAR(150), pCtl_Enviado CHAR(1), pOpcion INTEGER, pEmpleado CHAR(8))
															
															
															
	RETURNING CHAR (6) AS rCodRet 	

	/* 
	
				CodRet  = '000000' : 'Se realizo con exito'
						= '000003' :	'Parametros Vacios'
						= '000004' : 'No se encontro el cliente'
	
	*/
		
	--DECLARACION DE VARIABLES 
	DEFINe	dFecha_Modificacion		DATETIME YEAR TO SECOND;
	DEFINE 	cCodRet					CHAR(6);
	DEFINE  iSqlErr					INTEGER;
	DEFINE	cNumCte					CHAR(20);
	
	--INICIALIZACIÒN DE VARIABLES 
	LET		dFecha_Modificacion	=		CURRENT;
	LET		cCodRet				=		'000000';
	LET     iSqlErr				=		0;
	LET		cNumCte				= 		'';
	

--SET DEBUG FILE TO '/respaldosbd/Carolina/sp_.out';
--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then 
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcion = 1 THEN 
		
				IF NVL(pEmpresa, '')<> '' AND NVL(pNumCte, '')<> ''  AND  NVL( pOpcion , '') <> ''  AND NVL(pCliente, '')<> ''  THEN
			
									
				    SELECT numcte
					INTO  cNumCte
					FROM  bdinteg: "informix".si_clientescoppelporenviar
					WHERE numcte = TRIM(pNumCte) AND status = 3;
					
					
					UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
					SET cliente = pCliente
					WHERE numcte = TRIM(pNumCte) AND status = 0; 	
						
					IF NVL(cNumCte, '') ='' THEN 
					
					
						UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
						SET ctl_enviado = 2, empleado = pEmpleado, fecha_modificacion = CURRENT, idusituacion = pIduSituacion
						WHERE numcte = TRIM(pNumCte) AND status = 0;
						
						LET cCodRet = '000004';	
			
					END IF;												
			
						
				ELSE 				
					LET cCodRet ='000003';	
					
				END IF; 
				
		ELIF pOpcion = 2 THEN	

					IF   NVL( pCtl_Enviado , '') <> '' AND NVL(pCliente, '')<> ''THEN 	
					
						IF pCtl_Enviado = '1' THEN 	
							
							UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							SET  resultados = pResultados, idusituacion =pIduSituacion, status = pStatus, mensaje = pMensaje, ctl_enviado = pCtl_Enviado, fecha_modificacion = CURRENT, empleado = pEmpleado
							WHERE empresa = pEmpresa AND  cliente = TRIM(pCliente); 
							
							--Se Borra registro, porque ya se movio a tabla historica 
							DELETE  bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							WHERE  cliente = TRIM(pCliente); 
							
						ELSE 
							
							UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							SET  resultados = pResultados,idusituacion =pIduSituacion, status = pStatus, mensaje = pMensaje, ctl_enviado = pCtl_Enviado, fecha_modificacion = CURRENT, empleado = pEmpleado
							WHERE empresa = pEmpresa AND cliente = TRIM(pCliente); 
						END IF;
						
					ELSE 
						LET cCodRet = '000003';
					END IF;	
				
			       
		END IF;
	
		RETURN cCodRet;	
	END
END	PROCEDURE
DOCUMENT
"Folio: 1743",
"Autor: 96674555 Carolina E. Verdugo",
"Fecha: 05/08/2015", 
"Detalle: Se crea procedimiento para actualizar el status de los Clientes que se daran de alta en la tabla si_situaciones_clientescoppel_porenviar.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_situacionesclientescoppelporenviar (pEmpresa CHAR(3), pNumCte CHAR(20), pCliente CHAR(20), pIduSituacion INTEGER,pResultados INTEGER,
															pStatus CHAR(3), pMensaje CHAR(150), pCtl_Enviado CHAR(1), pOpcion INTEGER, pEmpleado CHAR(8))
															
															
															
	RETURNING CHAR (6) AS rCodRet 	

	/* 
	
				CodRet  = '000000' : 'Se realizo con exito'
						= '000003' :	'Parametros Vacios'
						= '000004' : 'No se encontro el cliente'
	
	*/
		
	--DECLARACION DE VARIABLES 
	DEFINe	dFecha_Modificacion		DATETIME YEAR TO SECOND;
	DEFINE 	cCodRet					CHAR(6);
	DEFINE  iSqlErr					INTEGER;
	DEFINE	cNumCte					CHAR(20);
	
	--INICIALIZACIÒN DE VARIABLES 
	LET		dFecha_Modificacion	=		CURRENT;
	LET		cCodRet				=		'000000';
	LET     iSqlErr				=		0;
	LET		cNumCte				= 		'';
	

--SET DEBUG FILE TO '/respaldosbd/Carolina/sp_.out';
--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then 
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcion = 1 THEN 
		
				IF NVL(pEmpresa, '')<> '' AND NVL(pNumCte, '')<> ''  AND  NVL( pOpcion , '') <> ''  AND NVL(pCliente, '')<> ''  THEN
			
									
				    SELECT numcte
					INTO  cNumCte
					FROM  bdinteg: "informix".si_clientescoppelporenviar
					WHERE numcte = TRIM(pNumCte) AND status = 3;
					
					
					UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
					SET cliente = pCliente
					WHERE numcte = TRIM(pNumCte) AND status = 0; 	
						
					IF NVL(cNumCte, '') ='' THEN 
					
					
						UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
						SET ctl_enviado = 2, empleado = pEmpleado, fecha_modificacion = CURRENT, idusituacion = pIduSituacion
						WHERE numcte = TRIM(pNumCte) AND status = 0;
						
						LET cCodRet = '000004';	
			
					END IF;												
			
						
				ELSE 				
					LET cCodRet ='000003';	
					
				END IF; 
				
		ELIF pOpcion = 2 THEN	

					IF   NVL( pCtl_Enviado , '') <> '' AND NVL(pCliente, '')<> ''THEN 	
					
						IF pCtl_Enviado = '1' THEN 	
							
							UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							SET  resultados = pResultados, idusituacion =pIduSituacion, status = pStatus, mensaje = pMensaje, ctl_enviado = pCtl_Enviado, fecha_modificacion = CURRENT, empleado = pEmpleado
							WHERE empresa = pEmpresa AND  cliente = TRIM(pCliente); 
							
							--Se Borra registro, porque ya se movio a tabla historica 
							DELETE  bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							WHERE  cliente = TRIM(pCliente); 
							
						ELSE 
							
							UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							SET  resultados = pResultados,idusituacion =pIduSituacion, status = pStatus, mensaje = pMensaje, ctl_enviado = pCtl_Enviado, fecha_modificacion = CURRENT, empleado = pEmpleado
							WHERE empresa = pEmpresa AND cliente = TRIM(pCliente); 
						END IF;
						
					ELSE 
						LET cCodRet = '000003';
					END IF;	
				
			       
		END IF;
	
		RETURN cCodRet;	
	END
END	PROCEDURE
DOCUMENT
"Folio: 1743",
"Autor: 96674555 Carolina E. Verdugo",
"Fecha: 05/08/2015", 
"Detalle: Se crea procedimiento para actualizar el status de los Clientes que se daran de alta en la tabla si_situaciones_clientescoppel_porenviar.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_cifra_archivo_pba4(pCodigo char(20)) 
returning 
          char(06) as resultado,
          char(80) as mensaje;

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define vEmpresa             char(3);
define iCodRet              integer;
define cCodRet              char(06);
define isam_err             integer;
define visam_err            integer;
define error_info	          char(150);
define verror_info	        char(150);
define vUsuario             char(20);
define vCodigo              char(20);
define vLLave               char(200);
define vNomarch             char(100);
define vRutaOrigen          char(100);
define vRutaDestino         char(100);
define vNomarchSalida       char(100);
define vRutaOriginales      char(100);
define vNomarch_salida      char(100);
define vArmaShellExt        char(5000);
define v_ext_entrada          char(10);
define v_ext_salida           char(10);
define v_retorno_linea        char(1);


define vfecha_hoy           DATE;
define vPri_dia_mes         DATE;
define vDia, vMes           char(2);
define vAnio                char(4);
define vBlinda              char(50);

let cMensajeRet             = 'Proceso Exitoso';
let cMensajeRet2            = '';
let vEmpresa                = '001';
let iCodRet                 = 0;
let cCodRet                 = '000000';
let isam_err                = 0;
let visam_err               = 0;
let error_info              = '';
let verror_info             = '';
let vUsuario                = '';
let vCodigo                 = '';
let vLLave                  = '';
let vNomarch                = '';
let vRutaOrigen             = '';
let vRutaDestino            = '';
let vNomarchSalida          = '';
let vfecha_hoy              = date(1);
let vPri_dia_mes            = date(1);
let vDia                    = '';
let vMes                    = '';
let vAnio                   = '';
let vRutaOriginales         = '';
let vNomarch_salida         = '';
let vBlinda                 = '';
let vArmaShellExt		        = '';
let v_ext_entrada           = '';
let v_ext_salida            = '';
let v_retorno_linea         = '';

--**************************** Control de errores ******************************
begin
    on exception set iCodRet, isam_err, error_info
    	if iCodRet <> 0 then
          	let cCodRet = iCodRet;
            --let cMensajeRet ='Error al blindar archivo >> '|| vNomarch;
            let visam_err = isam_err;
            let verror_info = error_info;
            let cMensajeRet =  visam_err || ' - ' || trim(verror_info);
                	
  			return cCodRet,cMensajeRet ;
      end if;
    end exception;

  Set debug file to "/tmp/sp_cifra_archivoHOY.out";
  trace on;

    let vCodigo = trim(pCodigo);
    let vBlinda = 'blinda_archivo_' || trim(vCodigo) || '.sh'; 

    FOREACH
      SELECT trim(usuario), trim(llave), trim(nomarch), trim(ruta_origen), trim(nomarch_salida),trim(ruta_destino), trim(ruta_originales), trim(ext_entrada),
             trim(ext_salida), trim(retorno_linea)
        INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales, v_ext_entrada, v_ext_salida, v_retorno_linea
        FROM bdinteg:si_configura_pgp
       WHERE codigo = vCodigo
        order by secuencia
  
      IF vUsuario <>  user THEN
          LET cCodRet = '00200';
          LET cMensajeRet = 'Usuario para cifrado incorrecto';
          return cCodRet,cMensajeRet;
      END IF;
     
      IF TRIM(v_ext_salida) = '' or TRIM(v_ext_salida) IS NULL THEN let v_ext_salida = 'pgp'; END IF;  

      IF TRIM(v_retorno_linea) = 'S' THEN
        --SYSTEM ' echo " for file in '|| trim(vRutaOrigen) || '*.txt; " > ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';  ---MACF  
        --system ' echo " for file in '|| trim(vRutaOrigen) || '*.' || trim(v_ext_entrada) || '; " > ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system ' echo " for file in '|| trim(vRutaOrigen) || trim(vNomarch) || '.' || trim(v_ext_entrada) || '; " > ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system ' echo "  do mv '|| '\$file'||' \$file''.TX''" >> ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh'; 
        system ' echo "  sed ''s/$/\r/g''' ||' \$file''.TX'' >> \$file " >> ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh'; 
        system ' echo "  rm ' || '\$file''.TX'' " >> ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';     
        system ' echo " done' || '">>' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system 'chmod 777 ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
        system '/usr/bin/sh ' || trim(vRutaOrigen) || 'inserta_cr_' || trim(vCodigo) || '.sh';
      END IF;
    
   
      SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || trim(vUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin">' || trim(vRutaOrigen) || trim(vBlinda);
      SYSTEM 'echo "export HOME=/home/' || trim(vUsuario) || '">>' || trim(vRutaOrigen) || trim(vBlinda); 
      SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i ' || trim(vRutaOrigen) || trim(vNomarch) || ' -r ' || '''' || trim(vLLave) || '''' ||" --armor --compression --output " || trim(vRutaDestino) || trim(vNomarch_salida) || '">>' || trim(vRutaOrigen) || trim(vBlinda) ;
      SYSTEM 'chmod 777 ' || trim(vRutaOrigen) || trim(vBlinda);   
      SYSTEM '/usr/bin/sh ' || trim(vRutaOrigen) || trim(vBlinda);
      SYSTEM 'mv ' || trim(vRutaOrigen) || trim(vNomarch) || ' ' || vRutaOriginales;
     
      
      system ' echo " for file in '|| trim(vRutaDestino) || '*.asc; " > ' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh';  
      --SYSTEM ' echo "  do mv '|| '\$file'||' \`echo \$file | sed ''s/\(.*\.\)asc/\1pgp/''\`;' || ' " >> ' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh'; 
      system ' echo "  do mv '|| '\$file'||' \`echo \$file | sed ''s/\(.*\.\)asc/\1' || trim(v_ext_salida) || '/''\`;' || ' " >> ' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh';
      system ' echo " done' || '">>' || trim(vRutaDestino) || 'cambia_ext_' || trim(vCodigo) || '.sh';
      system '/usr/bin/sh ' || trim(vRutaDestino)  || 'cambia_ext_' || trim(vCodigo) || '.sh';
    
         
    END FOREACH
    
    return cCodRet,cMensajeRet;

end;
end procedure;