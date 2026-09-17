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