CREATE PROCEDURE "informix".sp_exportarcatalogozonas(pCatalogo CHAR(1), pFechaAct DATE, pSeparador CHAR(1), pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (800);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(30);
DEFINE vNomArchAux                      CHAR(40);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: José de Jesús Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de exportar el total o una parcialidad de las zonas del catalogo

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parámetro pEjecucion para determinar si es Autmática o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catzonas_';
LET vNomArchAux   = 'si_catzonas_Aux';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/favmartinez/sp_ExportarCatalogoZonas.out";
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas WHERE empresa = '001';
    
    if pEjecucion = 'A' then
          select trim(valor) into vPath 
          from bdinteg:si_param_dom 
          where cod_param = 11;
    end if;
    LET vPath = TRIM(vPath);

    LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);

IF (pCatalogo = 1) THEN
     if pEjecucion = 'A' then               
          
          /*LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, numerocolonia, '
                || 'nombrezona, poblacionzona, municipiozona, codigopostalzona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona,   '
                || 'centro,ciudadcobranzas, numerocobranzas, numerociudadcoppel, '
                || ' numerocoloniacoppel, nombrezonacoppel FROM BDINTEG:si_catzonas" >' || trim(vPath) ||'corre_si_catzonas.sql';*/
				
		  LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, numerocolonia, '
                || 'limpia_cadena(nombrezona), limpia_cadena(poblacionzona), limpia_cadena(municipiozona), codigopostalzona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona, '
                || 'centro,ciudadcobranzas, numerocobranzas, numerociudadcoppel, '
                || ' numerocoloniacoppel, '
				|| ' case when nvl(nombrezonacoppel,''' || ''') <> ''' || ''' then limpia_cadena(nombrezonacoppel)||chr(13) else ''' || '''||chr(13) end '
				|| ' FROM BDINTEG:si_catzonas" >' || trim(vPath) ||'corre_si_catzonas.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catzonas.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catzonas.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 

  
    else /*
     LET cCadena = 'echo " unload to ' || '''/tmp/' || SUBSTR(vNomArchAux,1,LENGTH(vNomArchAux)) || '''' || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, numerocolonia, '
                || 'nombrezona, poblacionzona, municipiozona, codigopostalzona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona,   '
                || 'centro,ciudadcobranzas, numerocobranzas, numerociudadcoppel, '
                || ' numerocoloniacoppel, nombrezonacoppel FROM BDINTEG:si_catzonas" > /tmp/corre_si_catzonas.sql';                                                 
    System cCadena;

    let cCadena = 'dbaccess bdinteg /tmp/corre_si_catzonas.sql';
    System cCadena;

    LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| TRIM('/tmp/') || vNomArchAux || " >> " || TRIM('/tmp/') || vNomArch;
    SYSTEM cCadena;

    let cCadena = 'rm /tmp/corre_si_catzonas.sql';
    System cCadena;    
    */
    let cCadena = 'rm ' || '/tmp/' || vNomArchAux;
    --System cCadena;    

    end if;

ELIF (pCatalogo = 0) THEN
     if pEjecucion = 'A' then
      /*             
         LET cCadena = 'echo "unload to ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(vNomArch,1,LENGTH(vNomArch))  || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, numerocolonia, '
                    || 'nombrezona, poblacionzona, municipiozona, codigopostalzona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona,   '
                    || 'centro,ciudadcobranzas, numerocobranzas, numerociudadcoppel, '
                    || ' numerocoloniacoppel, nombrezonacoppel FROM BDINTEG:si_catzonas where f_ult_actualiza >= ''' || pFechaAct || '''">' || SUBSTR(vPath,1,LENGTH(vPath)) || 'corre_si_catzonas.sql';
        System cCadena;
        
        let cCadena = 'dbaccess bdinteg ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'corre_si_catzonas.sql';
        System cCadena;
*/
        let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'corre_si_catzonas.sql';
 --       System cCadena;
    else 
    /*
    LET cCadena = 'echo "unload to ' || '''/tmp/' || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || '''' || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, numerocolonia, '
                || 'nombrezona, poblacionzona, municipiozona, codigopostalzona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona,   '
                || 'centro,ciudadcobranzas, numerocobranzas, numerociudadcoppel, '
                || ' numerocoloniacoppel, nombrezonacoppel FROM BDINTEG:si_catzonas where f_ult_actualiza >= ''' || pFechaAct || '''"> /tmp/corre_si_catzonas.sql';
                 
    System cCadena;

    let cCadena = 'dbaccess bdinteg /tmp/corre_si_catzonas.sql';
    System cCadena;
*/
    let cCadena = 'rm /tmp/corre_si_catzonas.sql';
  --  System cCadena;            
    end if;
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parámetro de Catálogo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Marco A. Campos',
'FECHA: 2023/01/12',
'DESCRIPCION: Se modifica para agregar la depuración de caracteres especiales en algunos campos',
'BD: bdinteg',
'VERSION:20230112.100';

CREATE PROCEDURE "informix".sp_ctedigital_generaxml(pNumCte CHAR(20))
    --RETORNOS-
    RETURNING   CHAR(6)    AS cod_ret,
                CHAR(2000) AS trama;

    --DECLARACION DE VARIABLES--
    DEFINE iSql_err		    				INTEGER; 
    DEFINE cCodret		    				CHAR(6);
    DEFINE cNumcte          				CHAR(20);
    DEFINE iIdentificador   				INTEGER;
    DEFINE cNombre1         				CHAR(26);
    DEFINE cNombre2         				CHAR(26);
    DEFINE cApellPat        				CHAR(26);
    DEFINE cApellMat        				CHAR(26);
    DEFINE cSucursal        				CHAR(4);
    DEFINE cClienteRelacion 				CHAR(20);
    DEFINE cNumEmp          				CHAR(8);
    DEFINE dtFechaNac       				DATE;
    DEFINE cSexo            				CHAR(1);
    DEFINE cCelular        					CHAR(13);
    DEFINE sCarrier         				SMALLINT;
    DEFINE sMaxSecuencia    				SMALLINT;
    DEFINE cEmail           				CHAR(100);
    DEFINE cTelefonoCasa    				CHAR(13);
    DEFINE iConsecutivo     				INTEGER;
    DEFINE cSistema         				CHAR(1);

    --VARIABLES PARA EL ARMADO DE LA TRAMA
    DEFINE cEncabezado                     	CHAR(320);
    DEFINE cCuerpo                         	CHAR(1300);
    DEFINE cCola                           	CHAR(40);
    DEFINE cSalida                         	CHAR(2000);

    ---VARIABLES RESERVADAS PARA USO FUTURO
    DEFINE cVariable1                     	CHAR(50);
    DEFINE cVariable2                     	CHAR(50);
    DEFINE cVariable3                     	CHAR(50);
    DEFINE cVariable4                     	CHAR(50);
    DEFINE cVariable5                     	CHAR(50);
    DEFINE iVariable6                     	INTEGER;
    DEFINE iVariable7                     	INTEGER;
    DEFINE iVariable8                     	INTEGER;
    DEFINE iVariable9                     	INTEGER;
    DEFINE iVariable10                    	INTEGER;
    DEFINE cCodRetActualiza               	CHAR(6);
    DEFINE cFechaNac                      	CHAR(10);
    DEFINE dtFechaHoy       				DATE;
    DEFINE vFecsolic                        date;  

    --INICIALIZACION DE VARIABLES--
    LET iSql_err		    				= 0;
    LET cCodret		        				= '000000';
    LET cNumcte             				= '';
    LET iIdentificador      				= 0;
    LET cNombre1            				= '';
    LET cNombre2            				= '';
    LET cApellPat           				= '';
    LET cApellMat           				= '';
    LET cSucursal           				= '';
    LET cClienteRelacion    				= '';
    LET cNumEmp             				= '';
    LET dtFechaNac          				= DATE(1);
    LET cSexo               				= '';
    LET cCelular            				= '';
    LET sCarrier            				= 0;
    LET sMaxSecuencia       				= 0;
    LET cEmail              				= '';
    LET cTelefonoCasa       				= '';
    LET iConsecutivo        				= 0;
    LET cSistema							= '';

    --VARIABLES PARA EL ARMADO DE LA TRAMA
    LET cEncabezado                     	= '';
    LET cCuerpo                         	= '';
    LET cCola                           	= '';
    LET cSalida                         	= '';

    ---VARIABLES RESERVADAS PARA USO FUTURO
    LET cVariable1                      	= '0';
    LET cVariable2                      	= '0';
    LET cVariable3                      	= '0';
    LET cVariable4                      	= '0';
    LET cVariable5                      	= '0';
    LET iVariable6                      	= 0;
    LET iVariable7                      	= 0;
    LET iVariable8                      	= 0;
    LET iVariable9                      	= 0;
    LET iVariable10                     	= 0;
    LET cCodRetActualiza                	= '';
    LET cFechaNac                       	= '';
    LET dtFechaHoy           				= DATE(1);
    LET vFecsolic                           ='';

/*
-DESCRIPCIÃN: IDENTIFICARA EL ORIGEN DE ASIGNACION Y CON ESE CRITERIO BUSCARA EL DATO DEL PROMOTOR EJECUTIVO
-FECHA DE MODIFICACION: 20 DE ENERO DE 2014',
-BASE DE DATOS: BDINTEG
-MODIFICA: RIGOBERTO GONZALEZ
*/

    BEGIN
        --CONTROL DE ERRORES--
        ON EXCEPTION SET iSql_err 
            IF iSql_err <> 0 THEN
                LET cCodret = iSql_err;
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
            END IF;
        END EXCEPTION;
            
        --SET DEBUG FILE TO '/tmp/cyrv/sp_ctedigital_generaxml.out';
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --Se quitan espacios en blanco a variable entrada
        LET pNumCte = TRIM(pNumCte);
        
        ----------------CONTROL DE ERRORES POR PARAMETRO----------
        IF NVL(pNumCte,'') = '' THEN
            LET cCodret = '000001';
            RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        END IF;
    
        --************************************************************************************
        ---------------****************BLOQUE DE CONSULTA*************************************
        --************************************************************************************	

        --BARRE LOS DIFERENTES CLIENTES DE LA TABLA CON SU MAXIMO CONSECUTIVO CORRESPONDIENTE Y EL IDENTIFICADOR QUE LES CORRESPONDE
        SELECT a.num_cte_banco, a.consecutivo, a.identificador, a.sistema, a.fecha_insert
          INTO cNumcte, iConsecutivo, iIdentificador, cSistema, dtFechaHoy 
          FROM "informix".si_clientes_digital a
         WHERE a.consecutivo = (SELECT MAX(b.consecutivo) 
                                  FROM "informix".si_clientes_digital b 
                                 WHERE b.num_cte_banco = pNumCte
                                   AND (b.estatus_envio IN (0,5) OR b.estatus_envio IS NULL))
           AND a.num_cte_banco = pNumCte
           AND a.num_cte_coppel = a.num_cte_coppel
           AND (a.estatus_envio IN (0,5) OR a.estatus_envio IS NULL);


        IF DBINFO('sqlca.sqlerrd2') = 0   
            THEN
                LET cCodret = '000002'; --NO HAY REGISTROS DEL CLIENTE POR BARRER
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        END IF;	
        
        --Se quitan espacios en blanco a variable entrada
        LET cNumcte = TRIM(cNumcte);
        
        --NOMBRE CLIENTE BANCO OBTENIDO
        SELECT nombre1, NVL(nombre2,''), apell_paterno, NVL(apell_materno,''), sucursal
          INTO cNombre1, cNombre2, cApellPat, cApellMat, cSucursal
          FROM "informix".si_cliente
         WHERE empresa = '001'
           AND numcte = cNumcte;

        -- PARA OBTENER EL NUMERO DE CLIENTE COPPEL
        SELECT cliente
          INTO cClienteRelacion
          FROM "informix".si_relacion_ctebcplcpl
         WHERE empresa = '001'
           AND tipo_relacion = tipo_relacion
           AND numcte_banco =  cNumcte;
        
        LET cClienteRelacion = nvl(cClienteRelacion,'');
        
        IF DBINFO('sqlca.sqlerrd2') = 0 or cClienteRelacion =''
            THEN
                LET cClienteRelacion= '90001';
        END IF;

        IF SUBSTR(cClienteRelacion,1,1 )='9'
            THEN 
                LET cClienteRelacion= '90001';
        END IF;

        IF SUBSTR(cClienteRelacion,1,1 )='P' 
            THEN 
                LET cClienteRelacion= '90001';
        END IF;

        -- PARA OBTENER EL DATO DEL PROMOTOR QUE ASIGNO LA TARJETA
        IF cSistema = '1' 
            THEN	
                -- SE ASIGNO TARJETA COPPEL
                FOREACH

                    SELECT FIRST 1 NVL(b.user_insert,'') AS numempleado
                      INTO cNumEmp
                      FROM "informix".si_relacion_ctebcplcpl a, "informix".si_adiccoppel b
                     WHERE a.empresa = '001'
                       AND a.tipo_relacion = a.tipo_relacion
                       AND a.numcte_banco = b.numcte
                       AND b.numcte =  cNumcte
                       AND b.tipotar = '1'
                       AND b.secuencia = (SELECT MAX(secuencia) 
                                            FROM "informix".si_adiccoppel
                                           WHERE numcte = cNumcte) 
                  ORDER BY fecha_insert DESC

                END FOREACH;
        
            ELIF cSistema = '2' 
                THEN
                    -- SE ASIGNO TARJETA DE CREDITO BANCOPPEL
                    FOREACH

                    -- Se tomarÃ¡n los registros de las solicitudes que se originen en Tienda (canal 1)
                        SELECT FIRST 1 A.ejecutivo
                          INTO cNumEmp
                          FROM BDICRED:SD_MAECRED A
                    INNER JOIN BDISOLIC:SS_SOLICITUDES B 
                            ON A.numcte = B.numcte 
                           AND A.num_producto = B.num_producto
                         WHERE A.num_producto = '6001'
                           AND B.canal_sol = 1
                           AND A.numcte = cNumcte
                           AND A.fecha_apertura = dtFechaHoy
                      ORDER BY A.fecha_apertura DESC

                        /*
                        SELECT FIRST 1 ejecutivo
                          INTO cNumEmp
                          FROM bdicred:"informix".sd_maecred
                         WHERE empresa = '001'
                           AND numcte = cNumcte
                           --AND fecha_apertura = dtFechaHoy
                           AND num_producto = '6001'
                      ORDER BY fecha_apertura
                        */                      

                    END FOREACH;
        
                ELIF cSistema = '3'
                    THEN
                        -- SE ASIGNO TARJETA DE CAPTACION
                        FOREACH
            
                            SELECT FIRST 1 b.ejecutivo
                              INTO cNumEmp		
                              FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_maenoc b
                             WHERE a.cuenta = b.cuenta
                               AND a.cuenta = (SELECT max (a.cuenta)
                                                 FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_maenoc b
                                                WHERE a.cuenta = b.cuenta
                                                  AND a.num_cte = cNumcte
                                                  AND b.fecha_alta = dtFechaHoy)
                               AND a.num_cte = cNumcte
                               AND b.fecha_alta = dtFechaHoy 
                          ORDER BY fecha_alta DESC

                        END FOREACH;
        END IF;
        
        -- No se enviarÃ¡n los usuario syssiweb y sys_cred
        IF cNumEmp IN ('syssiweb','sys_cred')
            THEN 
                LET cCodret = '000003'; --NO SE GENERO LA TRAMA

                UPDATE "informix".si_clientes_digital 
                   SET estatus_envio = '3',
                       error = 'Error al generar XML: El valor '||cNumEmp||' no corresponde a un nÃºmero de empleado.'
                 WHERE num_cte_banco = cNumcte 
                   --AND consecutivo = iConsecutivo
                   AND identificador = iIdentificador
                   AND sistema = csistema
                   AND fecha_insert = dtFechaHoy;
                
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        END IF;



        IF NVL(cNumEmp,'') = ''
            THEN
        
                LET cCodret = '000003'; --NO SE GENERO LA TRAMA
            
                UPDATE "informix".si_clientes_digital 
                   SET estatus_envio = '3',
                       error = 'Error al generar XML: NÃºmero de Empleado Faltante.'
                 WHERE num_cte_banco = cNumcte 
                   --AND consecutivo = iConsecutivo
                   AND identificador = iIdentificador
                   AND sistema = csistema
                   AND fecha_insert = dtFechaHoy;
                
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        
        END IF;			
                
        SELECT fecha_nac, sexo
          INTO dtFechaNac, cSexo
          FROM "informix".si_ctepf
         WHERE empresa = '001'
           AND numcte = cNumcte;
        
        --LA FECHA DE NACIMIENTO Y EL SEXO DEL CLIENTE SON OBLIGATORIOS
        IF NVL(dtFechaNac,DATE(1)) = DATE(1) OR NVL(cSexo,'') = ''
            THEN
                LET cCodret = '000003'; --NO SE GENERO LA TRAMA

                UPDATE "informix".si_clientes_digital 
                   SET estatus_envio = '3',
                       error = 'Error al generar XML: Fecha de Nacimiento o Sexo Faltantes.'
                 WHERE num_cte_banco = cNumcte 
                   AND identificador = iIdentificador 
                   AND sistema = csistema 
                   AND fecha_insert = dtFechaHoy;
                   --AND consecutivo = iConsecutivo
                
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        
        END IF;

        LET cFechaNac = YEAR(dtFechaNac)||'-'||LPAD(MONTH(dtFechaNac),2,0)||'-'||LPAD(DAY(dtFechaNac),2,0);
        
        --SE SACA LA OBTENCION DE LA MAXIMA SECUENCIA PARA NO METERLO COMO SUBQUERY Y CARGAR LA CONSULTA
        SELECT MAX(secuencia) AS max_secuencia
          INTO sMaxSecuencia 
          FROM "informix".si_correos
         WHERE empresa = '001'
           AND numcte = cNumcte
           AND status_correo = 'A'
           AND tipo_correo = 1
           AND valido=1; --Ebh
                
        SELECT correo_elec
          INTO cEmail
          FROM "informix".si_correos
         WHERE empresa = '001'
           AND numcte = cNumcte
           AND status_correo = 'A'
           AND tipo_correo = 1
           AND valido=1 --ebh
           AND secuencia = sMaxSecuencia;
        
        SELECT telefono, carrier
          INTO cCelular, sCarrier
          FROM "informix".si_telefonos_actual
         WHERE empresa = '001'
           AND numcte = cNumcte
           AND tipo_tel = 2
           AND cofetel = 'V';
                
        --SOLO TERMINA LA EJECUCION EL SP EN CASO QUE EL CLIENTE NO TENGA NI CORREO NI CELULAR VALIDO
        IF NVL(cEmail,'') = '' OR NVL(cCelular,'') = '' 
            THEN
                LET cCodret = '000003'; --NO SE GENERO LA TRAMA
                
                UPDATE "informix".si_clientes_digital 
                   SET estatus_envio = '3',
                       error = 'Error al generar XML: El cliente no tiene correo o celular valido.'
                 WHERE num_cte_banco = cNumcte 
                   AND identificador = iIdentificador 
                   AND sistema = csistema 
                   AND fecha_insert = dtFechaHoy;
                   --AND consecutivo = iConsecutivo 
                
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        END IF;
        
        SELECT NVL(telefono,'')
          INTO cTelefonoCasa
          FROM "informix".si_telefonos_actual
         WHERE empresa = '001'
           AND numcte = cNumcte
           AND tipo_tel = 1
           AND cofetel = 'V';
                
        /*  IF cClienteRelacion = '' OR  cClienteRelacion = '90001'  THEN  
                FOREACH
                    SELECT  num_solicitud
                    INTO cVariable1
                    FROM bdisolic:ss_solicitudes 
                    WHERE numcte=cNumcte 
                    AND num_producto='6500'
                    ORDER BY fecha_insert DESC LIMIT 1
                END FOREACH;

            IF DBINFO('sqlca.sqlerrd2') = 0   THEN
                    FOREACH
                    SELECT  num_solicitud
                    INTO cVariable1
                    FROM bdisolic:ss_solicitudes 
                    WHERE numcte=cNumcte 
                    AND num_producto='6001'
                    ORDER BY fecha_insert DESC LIMIT 1
                    END FOREACH;
                END IF;	
        END IF;	
        */		
        ---------------****************ARMADO DE TRAMA*************************************

        -- ARMADO DE ENCABEZADO DE XML
        LET cEncabezado = "<WSValidacionCorreosElectronicos xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns='https://wsecommerce.coppel.com:8443/EcommerceValidacionDeCorreos/services/EcommerceValidacionDeCorreos?wsdl'>";
        --ARMADO DE COLA DE XML
        LET cCola = "</WSValidacionCorreosElectronicos>";
        --SE INICIALIZAN LAS VARIABLES QUE CONTENDRAN EL CUERPO Y LA SALIDA DEL SP
        LET cCuerpo = "";
        LET cSalida="";
        
        --CAMPO OBLIGATORIO = YA SE VALIDO QUE VIENE Y QUE ESTA CORRECTO POR ESO SOLO SE APLICA TRIM
        --CAMPO OPCIONAL/DEPENDIENTE = YA SE VALIDO DE NULO/VACIO A VACIO, PERO SE AMARRA CON NVL Y TRIM
        LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<Cliente>" ;
        
        ------NUMERO DE CLIENTE BANCOPPEL (obligatorio)
        LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<NUMERO_CTE_BAN>" || TRIM(cNumcte) || "</NUMERO_CTE_BAN>";	
        
        ------NUMERO DE CLIENTE COPPEL
        IF NVL(cClienteRelacion,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo,1,LENGTH(cCuerpo)) || "<NUMERO_CTE_COP>" || "0" || "</NUMERO_CTE_COP>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo,1,LENGTH(cCuerpo)) || "<NUMERO_CTE_COP>" || TRIM(cClienteRelacion) || "</NUMERO_CTE_COP>"; 
        END IF;	
        
        ------PRIMER NOMBRE
        IF NVL(cNombre1,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<PRIM_NOMBRE>" || " " || "</PRIM_NOMBRE>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<PRIM_NOMBRE>" || TRIM(cNombre1) || "</PRIM_NOMBRE>"; 
        END IF;
        
        ------SEGUNDO NOMBRE
        IF NVL(cNombre2,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<SEG_NOMBRE>" || " " || "</SEG_NOMBRE>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<SEG_NOMBRE>" || TRIM(cNombre2) || "</SEG_NOMBRE>"; 
        END IF;
        
        ------PRIMER APELLIDO
        IF NVL(cApellPat,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<PRIM_APELLIDO>" || " " || "</PRIM_APELLIDO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<PRIM_APELLIDO>" || TRIM(cApellPat) || "</PRIM_APELLIDO>"; 
        END IF;
        
        ------SEGUNDO APELLIDO
        IF NVL(cApellMat,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<SEG_APELLIDO>" || " " || "</SEG_APELLIDO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<SEG_APELLIDO>" || TRIM(cApellMat) || "</SEG_APELLIDO>"; 
        END IF;	
        
        ------FECHA DE NACIMIENTO (obligatorio)
        LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<FEC_NACIMIENTO>" || cFechaNac || "</FEC_NACIMIENTO>";
        
        ------SEXO (obligatorio)
        LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<SEXO>" || TRIM(cSexo) || "</SEXO>";
        
        ------E-MAIL (dependiente)
        IF NVL(cEmail,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<EMAIL>" || " " || "</EMAIL>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<EMAIL>" || TRIM(cEmail) || "</EMAIL>"; 
        END IF;	
        
        ------CARRIER (opcional)
        IF NVL(sCarrier,0) = 0 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<CARRIER>" || "0" || "</CARRIER>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<CARRIER>" || sCarrier || "</CARRIER>"; 
        END IF;
        
        ------TELEFONO CELULAR (dependiente)
        IF NVL(cCelular,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<TEL_CELULAR>" || "0" || "</TEL_CELULAR>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<TEL_CELULAR>" || TRIM(cCelular) || "</TEL_CELULAR>"; 
        END IF;	
        
        ------TELEFONO DE CASA (opcional)
        IF NVL(cTelefonoCasa,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<TEL_CASA>" || "0" || "</TEL_CASA>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<TEL_CASA>" || TRIM(cTelefonoCasa) || "</TEL_CASA>"; 
        END IF;	
        
        ------NUMERO DE EMPLEADO QUE ASIGNA LA TARJETA (obligatorio)
        LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<NUM_EMPLEADO>" || NVL(TRIM(cNumEmp),'0') || "</NUM_EMPLEADO>";
        
        ------NUMERO DE SUCURSAL
        IF NVL(cSucursal,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<NUM_SUCURSAL>" || "0" || "</NUM_SUCURSAL>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<NUM_SUCURSAL>" || TRIM(cSucursal) || "</NUM_SUCURSAL>"; END IF;	IF NVL(iIdentificador,0) = 0 THEN LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<ID_PROCESO>" || "0" || "</ID_PROCESO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<ID_PROCESO>" || iIdentificador || "</ID_PROCESO>"; 
        END IF;
        
        ----------------------------------------------------------------	
        ------ ESPACIO PARA VARIABLES RESERVADAS PARA USO FUTURO -------
        ----------------------------------------------------------------
        --cVariable1
        IF NVL(cVariable1,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_UNO>" || "0" || "</VAL_UNO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_UNO>" || TRIM(cVariable1) || "</VAL_UNO>"; 
        END IF;
        
        --cVariable2
        IF NVL(cVariable2,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_DOS>" || "0" || "</VAL_DOS>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_DOS>" || TRIM(cVariable2) || "</VAL_DOS>"; 
        END IF;
        
        --cVariable3
        IF NVL(cVariable3,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_TRES>" || "0" || "</VAL_TRES>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_TRES>" || TRIM(cVariable3) || "</VAL_TRES>"; 
        END IF;	
        
        --cVariable4
        IF NVL(cVariable4,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_CUATRO>" || "0" || "</VAL_CUATRO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_CUATRO>" || TRIM(cVariable4) || "</VAL_CUATRO>"; 
        END IF;
        
        --cVariable5
        IF NVL(cVariable5,'') = '' 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_CINCO>" || "0" || "</VAL_CINCO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_CINCO>" || TRIM(cVariable5) || "</VAL_CINCO>"; 
        END IF;

        --iVariable6
        IF NVL(iVariable6,0) = 0 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_SEIS>" || "0" || "</VAL_SEIS>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_SEIS>" || iVariable6 || "</VAL_SEIS>"; 
        END IF;
        
        --iVariable7
        IF NVL(iVariable7,0) = 0 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_SIETE>" || "0" || "</VAL_SIETE>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_SIETE>" || iVariable7 || "</VAL_SIETE>"; 
        END IF;	
        
        --iVariable8
        IF NVL(iVariable8,0) = 0 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_OCHO>" || "0" || "</VAL_OCHO>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_OCHO>" || iVariable8 || "</VAL_OCHO>"; 
        END IF;
        
        --iVariable9
        IF NVL(iVariable9,0) = 0 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_NUEVE>" || "0" || "</VAL_NUEVE>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_NUEVE>" || iVariable9 || "</VAL_NUEVE>"; 
        END IF;
        
        --iVariable10
        IF NVL(iVariable10,0) = 0 
            THEN 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_DIEZ>" || "0" || "</VAL_DIEZ>";
            ELSE 
                LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "<VAL_DIEZ>" || iVariable10 || "</VAL_DIEZ>"; 
        END IF;	
        
        LET cCuerpo = SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || "</Cliente>" ;
        -------------------------------------------------------------------------------------------------------------------------------
        -------------------------------------------------------------------------------------------------------------------------------
        LET cSalida = TRIM(cEncabezado) || SUBSTR(cCuerpo, 1, LENGTH(cCuerpo)) || TRIM(cCola); 
        LET cSalida = TRIM(cSalida);
        
        ---------------****************GENERACION Y GUARDADO DE TRAMA *************************************
        --GUARDAR LA TRAMA XML EN LA SI_CLIENTES_DIGITAL CON LA SECUENCIA QUE SE ESTUVO TRABAJANDO	
        UPDATE "informix".si_clientes_digital 
        SET xml = cSalida
        WHERE consecutivo = iConsecutivo 
        AND num_cte_banco = cNumcte 
        AND identificador = iIdentificador;
        
        --SE HACE UPDATE AL ESTATUS DE ENVIO PARA INDICAR QUE LA TRAMA SE GENERO MAS NO SE HA ENVIADO
        EXECUTE PROCEDURE "informix".sp_ctedigital_actualizaestatus(cNumcte, iConsecutivo, 0, '') INTO cCodRetActualiza;	
        
        IF DBINFO('sqlca.sqlerrd2') = 0 OR cCodRetActualiza <> '000000' 
            THEN
                LET cCodret = '000004'; --PROBLEMAS EN UPDATE NO SE GUARDO LA TRAMA O NO SE ACTUALIZO SU ESTATUS A 0
                RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
        END IF;			
            
        --TRAMA GENERADA CORRECTAMENTE	
        RETURN TRIM(cCodret), TRIM(NVL(cSalida,''));
 
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO QUE GENERA LA TRAMA XML DE LOS CLIENTES REGISTRADOS EN SI_CLIENTES_DIGITAL.',
'FECHA DE CREACIÃN: 04 DE DICIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131201.1630',
'MODIFICA: CARLOS OCHOA',
'FECHA: 24 de DICIEMBRE DE 2013',
'DESCRIPCION: SE ELIMINA PARTE DEL ENCABEZADO Y SE OBTIENE EL NUMERO DE EMPLEADO QUE ASIGNA TARJETA DE LA TABLA SI_ADICCOPPEL.',
'VERSION: 20131224.1630',
'MODIFICA: EDGAR BARRERA',
'FECHA: 18 de Septiembre 2019',
'DESCRIPCION: Se agrega validacion de correos validos se corrige el barrido de clientes duplicados, envio de num de cte coppel 90001';

CREATE PROCEDURE "informix".sp_gen_report_articulo_51()
	returning CHAR(5) AS Cod_Retorno;

	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE sFechaArch   	CHAR(10);
	DEFINE cCmd1        	CHAR(10000);
	DEFINE cCmd2        	CHAR(10000);
	DEFINE cCmd3        	CHAR(10000);
	DEFINE cCmd4        	CHAR(10000);
	DEFINE cCmd5        	CHAR(10000);
	DEFINE cQuery1        	CHAR(10000);
	DEFINE cQuery2        	CHAR(10000);
	DEFINE cQuery3        	CHAR(10000);
	DEFINE cQuery4        	CHAR(10000);
	DEFINE cQuery5        	CHAR(10000);
	DEFINE pArchDeclarga1	CHAR(100);
	DEFINE pArchDeclarga2	CHAR(100);
	DEFINE pArchDeclarga3	CHAR(100);
	DEFINE pRuta1			CHAR(100);
	DEFINE pRuta2			CHAR(100);
	DEFINE pRuta3			CHAR(100);
	DEFINE pRuta4			CHAR(100);
	DEFINE sMes         	CHAR(2);
	DEFINE sYear        	CHAR(4);
	DEFINE cSentencia		CHAR(200);
	DEFINE sMesAnt			CHAR(2);


	LET cCodRet 			= '00000';
	LET iSql_err       		= 0;
	LET cCmd1           	= '';
	LET cCmd2           	= '';
	LET cCmd3           	= '';
	LET cCmd4           	= '';
	LET cCmd5           	= '';
	LET pArchDeclarga1   	= '';
	LET pArchDeclarga2   	= '';
	LET pArchDeclarga3   	= '';
	LET pRuta1			   	= '';
	LET sFechaArch      	= '';
	LET sMes            	= '';
	LET sYear           	= '';
	LET cQuery1				= '';
	LET cQuery2				= '';
	LET cQuery3				= '';
	LET cQuery4				= '';
	LET cQuery5				= '';
	LET cSentencia 			= '';
	LET pRuta1				= '';
	LET pRuta2				= '';
	LET pRuta3				= '';
	LET pRuta4				= '';
	LET sMesAnt				= '';
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
        --SET DEBUG FILE TO '/informix/LMendoza/art/sp_gen_report_articulo_51.out';
		--TRACE ON;
		
		--SE ELIMINA LA INFORMACIÃN DE LA TABLA
		TRUNCATE TABLE si_cliente_report_articulo_51;
		
		LET sMesAnt= MONTH(TODAY);
		
		--VALIDA QUE NO SEA EL MES DE ENERO Y OBTIENE EL PRIMERO Y ULTIMO DIA DEL MES ANTERIOR
		IF sMesAnt= 1 THEN
			LET cCmd1 = 'SELECT {+AVOID_FULL ("informix".si_cliente), AVOID_FULL("informix".si_ctepf)} cl.numcte, cl.tipo_cliente, cl.nombre1, nombre2, cl.apell_paterno, cl.apell_materno, cl.rfc, cl.fecha_insert, cl.sucursal, ct.codidentifi, ct.fecha_nac  FROM bdinteg:si_cliente cl LEFT JOIN bdinteg:si_ctepf ct ON (ct.numcte= cl.numcte) WHERE cl.fecha_insert BETWEEN MDY(12,1,YEAR(TODAY)-1) AND MDY(12,31,YEAR(TODAY)-1);';
			LET sMes= 12;			LET sYear= year(TODAY)-1;		ELSE
			LET cCmd1 = 'SELECT {+AVOID_FULL ("informix".si_cliente), AVOID_FULL("informix".si_ctepf)} cl.numcte, cl.tipo_cliente, cl.nombre1, nombre2, cl.apell_paterno, cl.apell_materno, cl.rfc, cl.fecha_insert, cl.sucursal, ct.codidentifi, ct.fecha_nac  FROM bdinteg:si_cliente cl LEFT JOIN bdinteg:si_ctepf ct ON (ct.numcte= cl.numcte) WHERE cl.fecha_insert BETWEEN MDY(MONTH(TODAY)-1, 1,YEAR(TODAY)) AND ADD_MONTHS(LAST_DAY(TODAY),-1);';
			LET sMes= LPAD(month(TODAY)-1,2,'0');			LET sYear= year(TODAY);		END IF;
		
		LET sFechaArch=sYear||sMes;
		--SE ASIGNA LA RUTA DE LOS REPORTES GENERADOS
		LET pArchDeclarga1='"/RESPALDOSNEW/cliente_articulo_51_'||TRIM(sFechaArch)||'.unl" delimiter "|" ';
		LET pArchDeclarga2='"/RESPALDOSNEW/cliente_articulo_51_'||TRIM(sFechaArch)||'.unl"';
		LET pArchDeclarga3='"/RESPALDOSNEW/"';
		
		--DESCARGAR LOS DATOS DE LA CONSULTA EN EL ARCHIVO SI_CLIENTE_AAAAMM.UNL
		LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		SYSTEM TRIM(cQuery1);
		
		LET cSentencia = 'echo "load from ' || TRIM(pArchDeclarga2)|| ' INSERT INTO si_cliente_report_articulo_51  " > '|| TRIM(pArchDeclarga3)||'archivoinsert.sql';
		SYSTEM cSentencia;	  
		LET cSentencia = '';
		LET cSentencia = "dbaccess bdinteg " ||TRIM(pArchDeclarga3)||'archivoinsert.sql';
		SYSTEM cSentencia;
		
		--falta borrar los temporales
		LET cSentencia = '';
		LET cSentencia = "rm " ||TRIM(pArchDeclarga3)||'archivoinsert.sql';		
		SYSTEM cSentencia; 
		LET cSentencia = '';
		LET cSentencia = "rm " ||TRIM(pArchDeclarga3)||'cliente_articulo_51_'||TRIM(sFechaArch)||'.unl';		
		SYSTEM cSentencia; 
		
		--SE GENERAN LOS REPORTES
		LET pRuta1='"/RESPALDOSNEW/reporte_cliente_'||TRIM(sFechaArch)||'.unl" delimiter "|" ';
		LET cCmd2 = 'SELECT "numcte", "tipo_identificacion", "status_cte", "nombre", "apell_paterno", "apell_materno", "fecha_nac", "rfc", "fecha_alta", "sucursal", "situacion_especial" FROM systables WHERE tabid = 1 UNION ALL SELECT {+AVOID_FULL("informix".si_cliente_report_articulo_51), AVOID_FULL("informix".si_tipoidentif)), AVOID_FULL(bdisitesp:"informix".se_ctessitespcte)} TRIM(cl.numcte) AS numcte, case when (ti.descripcion  IS NOT NULL AND ti.descripcion  != "") THEN TRIM(ti.descripcion) ELSE " " END tipo_identificacion, TRIM(cl.status_cte) as status_cte, CASE WHEN (cl.nombre2 IS NOT NULL AND cl.nombre2 != " ") THEN (trim(cl.nombre1) || " " || trim(cl.nombre2)) ELSE trim(cl.nombre1) END as nombre, TRIM(cl.apell_paterno) as apell_paterno, CASE WHEN (apell_materno IS NOT NULL AND apell_materno != " ") THEN trim(apell_materno) ELSE " " END as apell_materno, TO_CHAR(cl.fecha_nac,"%d/%m/%Y"), cl.rfc as rfc, TO_CHAR(cl.fecha_alta,"%d/%m/%Y"), cl.sucursal as sucursal, (trim(esp.situacion)||esp.causa) as situacion_especial FROM bdinteg:si_cliente_report_articulo_51 cl LEFT JOIN bdinteg:si_tipoidentif ti ON (cl.tipo_identificacion=ti.codidentif) LEFT JOIN bdisitesp:se_ctessitespcte esp ON (cl.numcte = esp.numcte) WHERE cl.nombre1 != "" AND cl.nombre1 IS NOT NULL AND cl.apell_paterno !="" AND cl.apell_paterno IS NOT NULL AND cl.rfc !="" AND cl.rfc IS NOT NULL AND cl.sucursal != "" AND cl.sucursal IS NOT NULL;';
		LET cQuery2 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pRuta1)||"  "||TRIM(cCmd2)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		SYSTEM TRIM(cQuery2);
		
		LET pRuta2='"/RESPALDOSNEW/reporte_bitacora_renapob_'||TRIM(sFechaArch)||'.unl" delimiter "|" ';
		LET cCmd3 = 'SELECT "numcte", "mensaje_resp", "fecha" FROM systables  WHERE tabid = 1 UNION ALL SELECT {+AVOID_FULL("informix".si_cliente_report_articulo_51), AVOID_FULL ("informix".si_bitacora_renapob)} bi.numcte, bi.mensaje_resp, TO_CHAR(bi.fecha_insert,"%d/%m/%Y %R") FROM bdinteg:si_bitacora_renapob bi INNER JOIN bdinteg:si_cliente_report_articulo_51 ct ON bi.numcte = ct.numcte WHERE (bi.mensaje_resp != "" AND bi.mensaje_resp IS NOT NULL);';
		LET cQuery3 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pRuta2)||"  "||TRIM(cCmd3)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		SYSTEM TRIM(cQuery3);
		
		LET pRuta3 = '"/RESPALDOSNEW/reporte_bitacora_ife_'||TRIM(sFechaArch)||'.unl" delimiter "|" ';
		LET cCmd4 = 'SELECT "numcte", "test_uv_reflec_anv", "test_ir_ink_anv", "test_ir_ink_rev", "test_uv_reflectance_rev", "test_uv_shape_anv", "appat_ife", "apmat_ife", "nombre_ife", "anioreg_ife", "emision_ife", "cveelec_ife", "ocr_ife", "huella_der", "huella_izq", "fecha" FROM systables WHERE tabid = 1 UNION ALL SELECT {++AVOID_FULL("informix".si_cliente_report_articulo_51), AVOID_FULL ("informix".si_bitacora_ife), AVOID_FULL(bdisitesp:"informix".se_ctessitespcte)} ife.numcte, case when test_uv_reflec_anv="0" then "NA" else test_uv_reflec_anv end test_uv_reflec_anv, case when test_ir_ink_anv="0" then "NA" else test_ir_ink_anv end test_ir_ink_anv, case when test_ir_ink_rev="0" then "NA" else test_ir_ink_rev end test_ir_ink_rev, case when test_uv_reflectance_rev="0" then "NA" else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_uv_shape_anv="0" then "NA" else test_uv_shape_anv end test_uv_shape_anv, appat_ife,  apmat_ife, nombre_ife, anioreg_ife, emision_ife, cveelec_ife, ocr_ife, case when (ife.tmpansi2_ife ="" OR ife.resultado = "Falso" OR esp.numcte is not null ) then "F" else "V" end huella_der, case when (ife.tmpansi7_ife ="" OR ife.resultado = "Falso" OR esp.numcte is not null ) then "F" else "V" end huella_izq, TO_CHAR(ife.fecha,"%d/%m/%Y %R") FROM bdinteg:si_bitacora_ife ife left join bdisitesp:se_ctessitespcte esp on ife.numcte = esp.numcte and esp.situacion = "P" and esp.causa = "111" WHERE ife.numcte in(SELECT numcte FROM bdinteg:si_cliente_report_articulo_51) AND ((length(trim(causa_rechazo))=0 and resultado = "Verdadero") or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> "IDMEXG1") OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = "IDMEXG1")) and resp_ife not in("Consulta no exitosa al procesar peticion","Desconectado","No se ha enviado OCR") AND ((cod_resp_ife not in ("          ","00") and trim(modelo_ife) <> "IDMEXG1") OR (cod_resp_ife in ("          ","00") and trim(modelo_ife) = "IDMEXG1")) AND ((resp_ife not in ("") and trim(modelo_ife) <> "IDMEXG1") OR (resp_ife in ("") and trim(modelo_ife) = "IDMEXG1")) AND ((trim(resultado)="Falso" and (trim(resp_ife)="El OCR no tiene formato adecuado" or trim(resp_ife)="OCR No Vigente" or trim(resp_ife)="OCR Vigente" or trim(resp_ife)="Consulta no exitosa al procesar peticion" or trim(resp_ife)="DATOS_NO_ENCONTRADOS" or trim(resp_ife)="Ok, peticion satisfactoria" or trim(resp_ife)="VALIDACION DUMMY" or trim(resp_ife)="La transaccion fue atendida con exito.")) OR (trim(resultado)="Verdadero" and (trim(resp_ife)="OCR Vigente" or trim(resp_ife)="Ok, peticion satisfactoria" or trim(resp_ife)="Consulta no exitosa al procesar peticion" or trim(resp_ife)="Consulta no exitosa al procesar peticion" or trim(resp_ife)="VALIDACION DUMMY" or trim(resp_ife)="La transaccion fue atendida con exito.")) OR (trim(resultado)="Falso" and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = "IDMEXG1")) OR (trim(resultado)="Verdadero" and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = "IDMEXG1")));';
		LET cQuery4 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pRuta3)||"  "||TRIM(cCmd4)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		SYSTEM TRIM(cQuery4);
		
		IF sMesAnt= 1 THEN
			LET cCmd5 = 'SELECT "numcte", "ocr_ife", "sucursal", "ejecutivo", "fecha", "cic" FROM systables WHERE tabid = 1 UNION ALL SELECT {+AVOID_FULL("informix".si_bitacora_huella_ine)} * FROM (     SELECT         numcte,         case             when ocr_ife = cic THEN " "             when LENGTH(ocr_ife) = 13 THEN TRIM(ocr_ife)             when LENGTH(ocr_ife) > 13 THEN " " ELSE " " END ocr,         sucursal,         ejecutivo,         TO_CHAR(fecha_insert, "%d/%m/%Y %R"),         cic     FROM         bdinteg:si_bitacora_huella_ine     WHERE         fecha_insert BETWEEN EXTEND(MDY(12, 1,YEAR(TODAY)-1),         YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND              AND EXTEND (MDY(12,31,YEAR(TODAY)-1),         YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND ORDER BY fecha_insert ) c WHERE     (c.ocr <> "" AND c.ocr IS NOT NULL AND LENGTH(c.ocr) = 13)     OR  (c.cic <> "" AND c.cic IS NOT NULL AND LENGTH(c.cic) = 12);';
		ELSE
			LET cCmd5 = 'SELECT "numcte", "ocr_ife", "sucursal", "ejecutivo", "fecha", "cic"  FROM systables WHERE tabid = 1 UNION ALL SELECT {+AVOID_FULL("informix".si_bitacora_huella_ine)} * FROM (     SELECT         numcte,         case             when ocr_ife = cic THEN " "             when LENGTH(ocr_ife) = 13 THEN TRIM(ocr_ife)             when LENGTH(ocr_ife) > 13 THEN " " ELSE " " END ocr,         sucursal,         ejecutivo,         TO_CHAR(fecha_insert, "%d/%m/%Y %R"),         cic     FROM         bdinteg:si_bitacora_huella_ine     WHERE         fecha_insert BETWEEN EXTEND(MDY(MONTH(TODAY)-1, 1,YEAR(TODAY)),         YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND   AND EXTEND(ADD_MONTHS(LAST_DAY(TODAY),-1),    YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND ORDER BY fecha_insert  ) c WHERE     (c.ocr <> "" AND c.ocr IS NOT NULL AND LENGTH(c.ocr) = 13)     OR  (c.cic <> "" AND c.cic IS NOT NULL AND LENGTH(c.cic) = 12);';
		END IF;
		LET pRuta4 = '"/RESPALDOSNEW/reporte_bitacora_huella_ife_'||TRIM(sFechaArch)||'.unl" delimiter "|" ';
		LET cQuery5 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pRuta4)||"  "||TRIM(cCmd5)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		SYSTEM TRIM(cQuery5);
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: JOSEFINA ALVARADO GARCIA',
'FECHA 05/04/2022',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: EXTRACCION DE REPORTES',
'DESCRIPCION: GENERA LOS REPORTES DE ARTICULO 51 PARA EL AREA DE AUDITORIA, nombre de los reportes: reporte_cliente_AAAAMM.unl, reporte_bitacora_renapob_AAAAMM.unl, reporte_bitacora_ife_AAAAMM.unl, reporte_bitacora_huella_ife_AAAAMM.unl',
'AUTOR: JOSEFINA ALVARADO GARCIA',
'FECHA 21/04/2022',
'MODIFICACION: SE RENOMBRA EL NOMBRE DEL ARCHIVO si_cliente_AAAAMM POR cliente_articulo_51_AAAAMM,  SE MODIFICA EL SPL PARA QUITAR \ Y SE MODIFICA LA LOGICA PARA SACAR EL INTERVALO DE FECHA DEL MES ANTERIOR DE LA ULTIMA CONSULTA',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_recalcula_indicadores_ctes(dFechaIni DATE, dFechaFin DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE cCodRetSP        CHAR(6);
DEFINE cVarDataErrSP    CHAR(100);
DEFINE cVarDataErr      CHAR(100);
DEFINE iEnTransaccion   SMALLINT;
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE iFlag			INTEGER;
DEFINE bT1, bT2, bT3, bT4, bT5, bT6, bT7, bT8, bT9, bT10 BOOLEAN;
DEFINE iTemporal		SMALLINT;
DEFINE iBorrandoTmp		SMALLINT;
DEFINE dFechaProceso	DATE;
DEFINE dFechahoy	    DATE;
DEFINE cProceso			CHAR(100);
DEFINE cEvento			CHAR(100);
DEFINE cContador		INTEGER;
DEFINE cFechaProceso    CHAR(11);


--ASIGNACION DE VARIABLES
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO SE REALIZO CORRECTAMENTE';
LET iEnTransaccion = 0;
LET iFlag = 0;
LET cProceso = '';
LET cEvento = '';
LET dFechahoy = CURRENT::DATE;
LET bT1 = 'f';
LET bT2 = 'f';
LET bT3 = 'f';
LET bT4 = 'f';
LET bT5 = 'f';
LET bT6 = 'f';
LET bT7 = 'f';
LET bT8 = 'f';
LET bT9 = 'f';
LET bT10 = 'f';
LET iTemporal = 0;
LET iBorrandoTmp = 0;
LET cContador = 0;
LET cFechaProceso = '';

--SET DEBUG FILE TO "/tmp/masv/monitor/sp_recalcula_indicadores_ctes.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cMensCodRet
		IF iSqlErr <> 0 THEN
			LET vCodRet=iSqlErr;

			IF iEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;

			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaProceso, cProceso, cEvento, vCodret, cMensCodRet);

			RETURN vCodRet, cMensCodRet;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN(-206) SET iSqlErr, iSamErr, cMensCodRet
		IF iBorrandoTmp = 0 THEN
			IF iEnTransaccion = 1 THEN
				ROLLBACK;
				LET iEnTransaccion = 0;
			END IF;

			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaProceso, cProceso, cEvento, vCodret, cMensCodRet);

			LET vCodRet = iSqlErr;
			RETURN vCodRet, cMensCodRet;
		END IF;
	END EXCEPTION WITH RESUME;

	IF NVL(dFechaIni,'') = '' OR  NVL(dFechaFin,'') = ''  THEN
		LET vCodRet = '000001';
		LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
		RETURN vCodRet, cMensCodRet;
	ELIF dFechaIni > dFechaFin THEN
		LET vCodRet = '000002';
		LET cMensCodRet = 'PARAMETROS INCORRECTOS, FECHA INCIAL MAYOR A FECHA FINAL';
		RETURN vCodRet, cMensCodRet;

	END IF;

	LET dFechaProceso = dFechaIni;
	LET cFechaProceso = (TO_CHAR(dFechaproceso, '%Y-%m-%d')) || '%';

	LET cProceso = 'GENERACION DE INDICADORES DE SUCURSAL';
	WHILE (dFechaProceso <= dFechaFin)
		BEGIN WORK;
			LET iEnTransaccion = 1;
			LET iTemporal = 1;
			LET cEvento	= 'GENERACION TABLA TEMPORAL TMP_ALTA_CTES_TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b
			WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta = dFechaproceso
			AND a.tipo_cliente='1'
			INTO TEMP tmp_alta_ctes_titulares
			WITH NO LOG;
			
			LET bT1 = 't';

			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_alta_ctes_titulares';
			CREATE INDEX "informix".tmp_idx_alta_ctes_titulares ON tmp_alta_ctes_titulares (numcte, fecha_alta, sucursal);

			LET iTemporal = 2;
			LET cEvento = 'GENERACION TABLA TEMPORAL TMP_SI_TELEFONOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} *, dFechaproceso::DATE AS fecha
			FROM si_telefonos
			WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
			INTO TEMP tmp_si_telefonos WITH NO LOG;
			
			

			LET bT2 = 't';

			LET iTemporal = 3;
			LET cEvento = 'GENERACION TABLA TEMPORAL TMP_MANTTO_CTES_TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT a.numcte, a.user_insert AS numemp, c.sucursal, a.fecha  AS fecha_alta
			FROM TABLE(MULTISET(SELECT DISTINCT user_insert, numcte, fecha_hora::DATE AS fecha FROM tmp_si_telefonos WHERE fecha = dFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
							UNION ALL
							SELECT DISTINCT user_insert, numcte, dFechaproceso AS fecha 
							FROM si_correos WHERE fecha_hora like cFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI'))) a,
			si_cliente b, si_ejecut c, si_cte_huella d
			WHERE a.numcte = b.numcte
			AND b.numcte = d.numcte
			AND b.tipo_cliente = '1'
			AND a.user_insert = c.ejecutivo
			AND d.secuencia = 1
			AND a.fecha > d.fecha_alta
			AND c.password IN ('bancoppel2007','informix')
			INTO TEMP tmp_mantto_ctes_titulares
			WITH NO LOG;
			
		
			LET bT3 = 't';

			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_mantto_ctes_titulares';
			CREATE INDEX "informix".tmp_idx_mantto_ctes_titulares ON tmp_mantto_ctes_titulares (numcte, fecha_alta, sucursal);

			LET iTemporal = 4;
			LET cEvento	= 'GENERACION DE TABLA TEMPORAL tmp_sucursal_ejecut';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
			FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_alta_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
			INTO TEMP tmp_sucursal_ejecut
			WITH NO LOG;

			LET bT4 = 't';

			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_sucursal_ejecut';
			CREATE INDEX "informix".idx_tmp_suc_ejecut ON tmp_sucursal_ejecut (ejecutivo, sucursal);

			LET iTemporal = 5;
			LET cEvento	= 'GENERACION DE INDICADORES DE CORREOS DE NUEVOS CLIENTES TITULARES';

			SELECT '1' AS tipo_movto, dFechaproceso AS fecha, b.sucursal AS sucursal, a.numemp AS ejecutivo, a.altas AS altas_ctes, a.total_correos AS correo_cap, a.validos AS correo_val, a.invalidos AS correo_inval, a.sin_validar AS correo_pen, a.repetidos AS correo_rep,
					0 AS telcasa_cap,0 AS telcasa_val,0 AS telcasa_inval,0 AS telcasa_pen,0 AS telcasa_rep,
					0 AS telcel_cap,0 AS telcel_val,0 AS telcel_inval,0 AS telcel_pen,0 AS telcel_ver,0 AS telcel_rep,
					0 AS telotro_cap,0 AS telotro_val,0 AS telotro_inval,0 AS telotro_pen,0 AS telotro_rep
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
			FROM
			TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
						   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
											   FROM tmp_alta_ctes_titulares a
											   LEFT JOIN
											   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
											   FROM TABLE(MULTISET(SELECT {+AVOID_FULL (bdinteg:"informix".si_correos)} user_insert,numcte,
																	   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																	   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																	   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																	FROM bdinteg:"informix".si_correos
																	WHERE fecha_hora like cFechaproceso
																	AND secuencia = 1
																	AND status_correo = 'A'
																	GROUP BY user_insert, numcte, valido ))
																	GROUP BY user_insert, numcte)) b
											   ON a.numcte = b.numcte
											   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
						   GROUP BY numemp)) a
						   LEFT JOIN
						   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
										  FROM bdinteg:"informix".si_correos a, tmp_alta_ctes_titulares b
										  WHERE a.numcte=b.numcte
										  AND fecha_valida::DATE = dFechaproceso
										  GROUP BY 1,2
										  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
						   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut b
			WHERE a.numemp = b.ejecutivo
			INTO TEMP tmp_indicadores_ctes_det WITH NO LOG;

			LET bT5 = 't';

			LET iTemporal = 6;
			LET cEvento	= 'OBTENCION DE INDICADORES DE TELEFONOS DE NUEVOS CLIENTES TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT '1' AS tipo_movto, dFechaproceso AS fecha, a.numemp,
				   NVL(SUM(a.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(a.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(a.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(a.total_tel_casa_pen),0) AS total_tel_casa_pen, NVL(b.tel_casa_rep,0) AS total_tel_casa_rep,
				   NVL(SUM(a.total_celular), 0) AS total_celular, NVL(SUM(a.total_celular_val),0) AS total_celular_val, NVL(SUM(a.total_celular_inval),0) AS total_celular_inval, NVL(SUM(a.total_celular_pen),0) AS total_celular_pen, NVL(SUM(a.verificados),0) AS verificados, NVL(b.tel_cel_rep,0) AS total_tel_cel_rep,
				   NVL(SUM(a.total_otro), 0) AS total_otro, NVL(SUM(a.total_otro_val),0) AS total_otro_val, NVL(SUM(a.total_otro_inval),0) AS total_otro_inval, NVL(SUM(a.total_otro_pen),0) AS total_otro_pen, NVL(b.tel_otro_rep,0) AS total_tel_otro_rep
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.numcte, NVL(SUM(b.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(b.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(b.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(b.total_tel_casa_pen),0) AS total_tel_casa_pen,
				   NVL(SUM(b.total_celular), 0) AS total_celular, NVL(SUM(b.total_celular_val),0) AS total_celular_val, NVL(SUM(b.total_celular_inval),0) AS total_celular_inval, NVL(SUM(b.total_celular_pen),0) AS total_celular_pen, NVL(SUM(b.verificados),0) AS verificados,
				   NVL(SUM(b.total_otro), 0) AS total_otro, NVL(SUM(b.total_otro_val),0) AS total_otro_val, NVL(SUM(b.total_otro_inval),0) AS total_otro_inval, NVL(SUM(b.total_otro_pen),0) AS total_otro_pen
			FROM tmp_alta_ctes_titulares a
			LEFT JOIN
			TABLE(MULTISET(SELECT user_insert, numcte,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0) ELSE 0 END AS total_tel_casa_val,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_tel_casa_inval,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa_pen,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_celular_inval,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular_pen,
									NVL(SUM(verificado),0) AS verificados,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0) ELSE 0 END AS total_otro_val,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_otro_inval,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro_pen
									FROM TABLE(MULTISET(SELECT a.user_insert, a.numcte, a.tipo_tel, a.validos, a.invalidos, a.sin_validar, b.verificado
														FROM
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel,
															   CASE WHEN cofetel = 'V' THEN COUNT(telefono) ELSE 0 END AS validos,
															   CASE WHEN cofetel = 'F' THEN COUNT(telefono) ELSE 0 END AS invalidos,
															   CASE WHEN cofetel IS NULL THEN COUNT(telefono)ELSE 0  END AS sin_validar
														FROM bdinteg:"informix".tmp_si_telefonos
														WHERE fecha = dFechaproceso
														GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																	   FROM bdinteg:"informix".tmp_si_telefonos
																	   WHERE fecha = dFechaproceso
																	   AND verificado = 'V'
																	   AND tipo_tel = '2'
																	   GROUP BY user_insert, numcte, tipo_tel)) b
														ON a.user_insert = b.user_insert AND a.numcte = b.numcte AND a.tipo_tel = b.tipo_tel
												))
									GROUP BY user_insert, numcte, tipo_tel))b
			ON a.numcte = b.numcte GROUP BY 1,2)) a
			LEFT JOIN
			TABLE(MULTISET(SELECT numemp, SUM(NVL(tel_casa_rep,0)) AS tel_casa_rep, SUM(NVL(tel_cel_rep,0)) AS tel_cel_rep, SUM(NVL(tel_otro_rep,0)) AS tel_otro_rep
							   FROM
							   TABLE(MULTISET(SELECT b.numemp AS numemp, a.telefono,
													 CASE WHEN a.tipo_tel = '1' THEN COUNT(a.telefono) ELSE 0 END AS tel_casa_rep,
													 CASE WHEN a.tipo_tel = '2' THEN COUNT(a.telefono) ELSE 0 END AS tel_cel_rep,
													 CASE WHEN a.tipo_tel NOT IN('1','2') THEN COUNT(a.telefono) ELSE 0 END AS tel_otro_rep
											  FROM bdinteg:"informix".tmp_si_telefonos a, tmp_alta_ctes_titulares b
											  WHERE a.numcte=b.numcte
											  AND a.user_insert = b.numemp
											  AND a.fecha = dFechaproceso
											  GROUP BY b.numemp, a.telefono, a.tipo_tel
											  HAVING COUNT(a.telefono) >1))
							   GROUP BY 1)) b
			ON a.numemp = b.numemp
			GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
			INTO TEMP tmp_telefonos_ctenvos WITH NO LOG;

			LET bT6 = 't';

			LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES TITULARES';
			MERGE INTO bdinteg:tmp_indicadores_ctes_det AS a
			USING tmp_telefonos_ctenvos AS b
			ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
			SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep,
				telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
				telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;

			LET iTemporal = 7;
			LET cEvento	= 'GENERACION DE TABLA TEMPORAL tmp_sucursal_ejecut_mantto';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
			FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_mantto_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
			INTO TEMP tmp_sucursal_ejecut_mantto
			WITH NO LOG;

			LET bT7 = 't';

			LET cEvento	= 'ACTUALIZACION DE TABLA TEMPORAL tmp_sucursal_ejecut';
			MERGE INTO tmp_sucursal_ejecut a
				USING tmp_sucursal_ejecut_mantto b
				ON a.ejecutivo= b.ejecutivo
				AND a.sucursal = b.sucursal
			WHEN NOT MATCHED THEN
				INSERT (a.sucursal, a.nom_suc, a.ejecutivo, a.nom_emp)
					VALUES
						(b.sucursal, b.nom_suc, b.ejecutivo, b.nom_emp);

			LET cEvento	= 'OBTENCION DE INDICADORES DE CORREOS CLIENTES TITULARES CON MANTENIMIENTO';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdinteg:tmp_indicadores_ctes_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep,
												  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep,
												  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep,
												  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
			SELECT DISTINCT '2' AS tipo_mov, dFechaproceso, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos,
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
			FROM
			TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
						   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
											   FROM tmp_mantto_ctes_titulares a
											   LEFT JOIN
											   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
											   FROM TABLE(MULTISET(SELECT {+AVOID_FULL (bdinteg:"informix".si_correos)} user_insert,numcte,
																	   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																	   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																	   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																	FROM bdinteg:"informix".si_correos
																	WHERE fecha_hora like cFechaproceso
																	AND status_correo = 'A'
																	GROUP BY user_insert, numcte, valido ))
																	GROUP BY user_insert, numcte)) b
											   ON a.numcte = b.numcte
											   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
						   GROUP BY numemp)) a
						   LEFT JOIN
						   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
										  FROM bdinteg:"informix".si_correos a, tmp_mantto_ctes_titulares b
										  WHERE a.numcte=b.numcte
										  AND fecha_valida::DATE = dFechaproceso
										  GROUP BY 1,2
										  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
						   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut_mantto b
			WHERE a.numemp = b.ejecutivo;

			LET iTemporal = 8;
			LET cEvento	= 'OBTENCION DE INDICADORES DE TELEFONOS CLIENTES TITULARES CON MANTENIMIENTO';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT '2' AS tipo_movto, dFechaproceso AS fecha, a.numemp,
				   NVL(SUM(a.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(a.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(a.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(a.total_tel_casa_pen),0) AS total_tel_casa_pen, NVL(b.tel_casa_rep,0) AS total_tel_casa_rep,
				   NVL(SUM(a.total_celular), 0) AS total_celular, NVL(SUM(a.total_celular_val),0) AS total_celular_val, NVL(SUM(a.total_celular_inval),0) AS total_celular_inval, NVL(SUM(a.total_celular_pen),0) AS total_celular_pen, NVL(SUM(a.verificados),0) AS verificados, NVL(b.tel_cel_rep,0) AS total_tel_cel_rep,
				   NVL(SUM(a.total_otro), 0) AS total_otro, NVL(SUM(a.total_otro_val),0) AS total_otro_val, NVL(SUM(a.total_otro_inval),0) AS total_otro_inval, NVL(SUM(a.total_otro_pen),0) AS total_otro_pen, NVL(b.tel_otro_rep,0) AS total_tel_otro_rep
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.numcte, NVL(SUM(b.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(b.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(b.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(b.total_tel_casa_pen),0) AS total_tel_casa_pen,
				   NVL(SUM(b.total_celular), 0) AS total_celular, NVL(SUM(b.total_celular_val),0) AS total_celular_val, NVL(SUM(b.total_celular_inval),0) AS total_celular_inval, NVL(SUM(b.total_celular_pen),0) AS total_celular_pen, NVL(SUM(b.verificados),0) AS verificados,
				   NVL(SUM(b.total_otro), 0) AS total_otro, NVL(SUM(b.total_otro_val),0) AS total_otro_val, NVL(SUM(b.total_otro_inval),0) AS total_otro_inval, NVL(SUM(b.total_otro_pen),0) AS total_otro_pen
			FROM tmp_mantto_ctes_titulares a
			LEFT JOIN
			TABLE(MULTISET(SELECT user_insert, numcte,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0) ELSE 0 END AS total_tel_casa_val,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_tel_casa_inval,
									CASE WHEN tipo_tel = '1' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa_pen,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_celular_inval,
									CASE WHEN tipo_tel = '2' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular_pen,
									NVL(SUM(verificado),0) AS verificados,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0) ELSE 0 END AS total_otro_val,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_otro_inval,
									CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro_pen
									FROM TABLE(MULTISET(SELECT a.user_insert, a.numcte, a.tipo_tel, a.validos, a.invalidos, a.sin_validar, b.verificado
														FROM
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel,
															   CASE WHEN cofetel = 'V' THEN COUNT(telefono) ELSE 0 END AS validos,
															   CASE WHEN cofetel = 'F' THEN COUNT(telefono) ELSE 0 END AS invalidos,
															   CASE WHEN cofetel IS NULL THEN COUNT(telefono)ELSE 0  END AS sin_validar
														FROM bdinteg:"informix".tmp_si_telefonos
														--WHERE fecha_hora::DATE = dFechaproceso
														WHERE fecha = dFechaproceso
														GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																	   FROM bdinteg:"informix".tmp_si_telefonos
																	   --WHERE fecha_hora::DATE = dFechaproceso
																	   WHERE fecha = dFechaproceso
																	   AND verificado = 'V'
																	   AND tipo_tel = '2'
																	   GROUP BY user_insert, numcte, tipo_tel)) b
														ON a.user_insert = b.user_insert AND a.numcte = b.numcte AND a.tipo_tel = b.tipo_tel
												))
									GROUP BY user_insert, numcte, tipo_tel))b
			ON a.numcte = b.numcte GROUP BY 1,2)) a
			LEFT JOIN
			TABLE(MULTISET(SELECT numemp, SUM(NVL(tel_casa_rep,0)) AS tel_casa_rep, SUM(NVL(tel_cel_rep,0)) AS tel_cel_rep, SUM(NVL(tel_otro_rep,0)) AS tel_otro_rep
							   FROM
							   TABLE(MULTISET(SELECT b.numemp AS numemp, a.telefono,
													 CASE WHEN a.tipo_tel = '1' THEN COUNT(a.telefono) ELSE 0 END AS tel_casa_rep,
													 CASE WHEN a.tipo_tel = '2' THEN COUNT(a.telefono) ELSE 0 END AS tel_cel_rep,
													 CASE WHEN a.tipo_tel NOT IN('1','2') THEN COUNT(a.telefono) ELSE 0 END AS tel_otro_rep
											  FROM bdinteg:"informix".tmp_si_telefonos a, tmp_mantto_ctes_titulares b
											  WHERE a.numcte=b.numcte
											  AND a.user_insert = b.numemp
											  AND a.fecha = dFechaproceso
											  GROUP BY b.numemp, a.telefono, a.tipo_tel
											  HAVING COUNT(a.telefono) >1))
							   GROUP BY 1)) b
			ON a.numemp = b.numemp
			GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
			INTO TEMP tmp_telefonos_ctesmantto WITH NO LOG;

			LET bT8 = 't';

			LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES CON MANTENIMIENTO';
			MERGE INTO bdinteg:tmp_indicadores_ctes_det AS a
			USING tmp_telefonos_ctesmantto AS b
			ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
			SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep,
				telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
				telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;

			LET cEvento	= 'ACTUALIZACION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES';
			MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a
			USING tmp_indicadores_ctes_det AS b
			ON a.tipo_movto = b.tipo_movto AND a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.ejecutivo = b.ejecutivo
			WHEN MATCHED THEN UPDATE
				SET a.altas_ctes = b.altas_ctes, a.correo_cap = b.correo_cap, a.correo_val = b.correo_val, a.correo_inval = b.correo_inval, a.correo_pen = b.correo_pen, a.correo_rep = b.correo_rep,
					a.telcasa_cap = b.telcasa_cap, a.telcasa_val = b.telcasa_val, a.telcasa_inval = b.telcasa_inval, a.telcasa_pen = b.telcasa_pen, a.telcasa_rep = b.telcasa_rep,
					a.telcel_cap = b.telcel_cap, a.telcel_val = b.telcel_val, a.telcel_inval = b.telcel_inval, a.telcel_pen = b.telcel_pen, a.telcel_ver = b.telcel_ver, a.telcel_rep = b.telcel_rep,
					a.telotro_cap = b.telotro_cap, a.telotro_val = b.telotro_val, a.telotro_inval = b.telotro_inval, a.telotro_pen = b.telotro_pen, a.telotro_rep = b.telotro_rep
			WHEN NOT MATCHED THEN INSERT
						(a.tipo_movto, a.fecha, a.sucursal, a.ejecutivo,
						a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
						a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
						a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
						a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep)
				VALUES( b.tipo_movto, b.fecha, b.sucursal, b.ejecutivo,
						b.altas_ctes, b.correo_cap, b.correo_val, b.correo_inval, b.correo_pen, b.correo_rep,
						b.telcasa_cap, b.telcasa_val, b.telcasa_inval, b.telcasa_pen, b.telcasa_rep,
						b.telcel_cap, b.telcel_val, b.telcel_inval, b.telcel_pen, b.telcel_ver, b.telcel_rep,
						b.telotro_cap, b.telotro_val, b.telotro_inval, b.telotro_pen, b.telotro_rep);

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			LET cEvento	= 'OBTENCION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES/MANTENIMIENTOS';

			LET iTemporal = 9;
			SELECT tipo_movto, fecha, NVL(SUM(altas_ctes),0) AS altas_ctes, NVL(SUM(correo_cap),0) AS correo_cap, NVL(SUM(correo_val),0) AS correo_val,  NVL(SUM(correo_inval),0) AS correo_inval, NVL(SUM(correo_pen),0) AS correo_pen, NVL(SUM(correo_rep),0) correo_rep,
				   NVL(SUM(telcasa_cap),0) AS telcasa_cap, NVL(SUM(telcasa_val),0) AS telcasa_val, NVL(SUM(telcasa_inval),0) AS telcasa_inval, NVL(SUM(telcasa_pen),0) AS telcasa_pen, NVL(SUM(telcasa_rep),0) AS telcasa_rep,
				   NVL(SUM(telcel_cap),0) AS telcel_cap, NVL(SUM(telcel_val),0) AS telcel_val, NVL(SUM(telcel_inval),0) AS telcel_inval, NVL(SUM(telcel_pen),0) AS telcel_pen, NVL(SUM(telcel_ver),0) AS telcel_ver, NVL(SUM(telcel_rep),0) AS telcel_rep,
				   NVL(SUM(telotro_cap),0) AS telotro_cap, NVL(SUM(telotro_val),0) AS telotro_val, NVL(SUM(telotro_inval),0) AS telotro_inval, NVL(SUM(telotro_pen),0) AS telotro_pen, NVL(SUM(telotro_rep),0) AS telotro_rep
			FROM si_indicadores_ctes_nvos_det
			WHERE fecha = dFechaproceso
			GROUP BY 1,2
			INTO TEMP tmp_indicadores_ctes WITH NO LOG;

			LET bT9 = 't';

			LET cEvento	= 'ACTUALIZACION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES';
			MERGE INTO bdinteg:si_indicadores_ctes_nvos AS a
			USING tmp_indicadores_ctes AS b
			ON a.tipo_movto = b.tipo_movto AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
				SET a.altas_ctes = b.altas_ctes, a.correo_cap = b.correo_cap, a.correo_val = b.correo_val, a.correo_inval = b.correo_inval, a.correo_pen = b.correo_pen, a.correo_rep = b.correo_rep,
					a.telcasa_cap = b.telcasa_cap, a.telcasa_val = b.telcasa_val, a.telcasa_inval = b.telcasa_inval, a.telcasa_pen = b.telcasa_pen, a.telcasa_rep = b.telcasa_rep,
					a.telcel_cap = b.telcel_cap, a.telcel_val = b.telcel_val, a.telcel_inval = b.telcel_inval, a.telcel_pen = b.telcel_pen, a.telcel_ver = b.telcel_ver, a.telcel_rep = b.telcel_rep,
					a.telotro_cap = b.telotro_cap, a.telotro_val = b.telotro_val, a.telotro_inval = b.telotro_inval, a.telotro_pen = b.telotro_pen, a.telotro_rep = b.telotro_rep
			WHEN NOT MATCHED THEN INSERT
						(a.tipo_movto, a.fecha,
						a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
						a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
						a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
						a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep)
				VALUES( b.tipo_movto, b.fecha,
						b.altas_ctes, b.correo_cap, b.correo_val, b.correo_inval, b.correo_pen, b.correo_rep,
						b.telcasa_cap, b.telcasa_val, b.telcasa_inval, b.telcasa_pen, b.telcasa_rep,
						b.telcel_cap, b.telcel_val, b.telcel_inval, b.telcel_pen, b.telcel_ver, b.telcel_rep,
						b.telotro_cap, b.telotro_val, b.telotro_inval, b.telotro_pen, b.telotro_rep);

			LET iBorrandoTmp = 1;

			IF bT1 = 't' THEN
				DROP TABLE tmp_alta_ctes_titulares;
				LET bT1 = 'f';
			END IF;

			IF bT2 = 't' THEN
				DROP TABLE tmp_si_telefonos;
				LET bT2 = 'f';
			END IF;

			IF bT3 = 't' THEN
				DROP TABLE tmp_mantto_ctes_titulares;
				LET bT3 = 'f';
			END IF;

			IF bT4 = 't' THEN
				DROP TABLE tmp_sucursal_ejecut;
				LET bT4 = 'f';
			END IF;

			IF bT5 = 't' THEN
				DROP TABLE tmp_indicadores_ctes_det;
				LET bT5 = 'f';
			END IF;

			IF bT6 = 't' THEN
				DROP TABLE tmp_telefonos_ctenvos;
				LET bT6 = 'f';
			END IF;

			IF bT7 = 't' THEN
				DROP TABLE tmp_sucursal_ejecut_mantto;
				LET bT7 = 'f';
			END IF;

			IF bT8 = 't' THEN
				DROP TABLE tmp_telefonos_ctesmantto;
				LET bT8 = 'f';
			END IF;

			IF bT9 = 't' THEN
				DROP TABLE tmp_indicadores_ctes;
				LET bT9 = 'f';
			END IF;
			LET iBorrandoTmp = 0;

		COMMIT WORK;
		LET iEnTransaccion = 0;
		LET dFechaProceso = dFechaProceso + 1 UNITS DAY;

	END WHILE;

	LET cProceso = 'REPLICA DE INFORMACION A BDIBI';
	LET cEvento	= 'OBTIENE VALOR FLAG PARA GRABAR BDIBI';

	SELECT NVL(valor,0)::INTEGER
	INTO iFlag
	FROM bdinteg:si_param
	WHERE cod_param = 343;

	IF iFlag = 1 THEN
	LET cEvento	= 'EJECUCION DE SP sp_replica_manual_indicadores_ctes_bi';

		EXECUTE PROCEDURE bdinteg:"informix".sp_replica_manual_indicadores_ctes_bi(2,dFechaIni, dFechaFin, '')
		INTO cCodRetSP, cVarDataErrSP;

			IF cCodRetSP <> '000000' THEN
				INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaHoy, cProceso, cEvento, cCodRetSP, cVarDataErrSP);

				LET vCodRet = cCodRetSP;
				LET cVarDataErr = cVarDataErrSP;
			END IF;
	END IF;
	LET iBorrandoTmp = 1;

	IF bT1 = 't' THEN
		DROP TABLE tmp_alta_ctes_titulares;
		LET bT1 = 'f';
	END IF;

	IF bT2 = 't' THEN
		DROP TABLE tmp_si_telefonos;
		LET bT2 = 'f';
	END IF;

	IF bT3 = 't' THEN
		DROP TABLE tmp_mantto_ctes_titulares;
		LET bT3 = 'f';
	END IF;

	IF bT4 = 't' THEN
		DROP TABLE tmp_sucursal_ejecut;
		LET bT4 = 'f';
	END IF;

	IF bT5 = 't' THEN
		DROP TABLE tmp_indicadores_ctes_det;
		LET bT5 = 'f';
	END IF;

	IF bT6 = 't' THEN
		DROP TABLE tmp_telefonos_ctenvos;
		LET bT6 = 'f';
	END IF;

	IF bT7 = 't' THEN
		DROP TABLE tmp_sucursal_ejecut_mantto;
		LET bT7 = 'f';
	END IF;

	IF bT8 = 't' THEN
		DROP TABLE tmp_telefonos_ctesmantto;
		LET bT8 = 'f';
	END IF;

	IF bT9 = 't' THEN
		DROP TABLE tmp_indicadores_ctes;
		LET bT9 = 'f';
	END IF;
	LET iBorrandoTmp = 0;

	RETURN vCodRet, cMensCodRet;
END;
END PROCEDURE
DOCUMENT
'FECHA:09/09/2015',
'VERSION:20150909.1515',
'REALIZO: JOSE ANGEL LOPEZ ADAMS',
'DESCRIPCION: Se realiza el recalculo de los indicadores de telefonos y correos de un rango de fechas establecido',
'			  Si esta encendida la replica a BI actualizara/insertara los registros generados',
'FECHA: 24/10/2017',
'VERSION: 20171024',
'RELIZO: Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica proceso para hacer llamado al sp_replica_manual_indicadores_ctes_bi correctamente (4 parÃÂ¡metros)',
'FECHA: 29/09/2021',
'REALIZ: Miguel Angel Solano Valdez',
'DESCRIPCION: Se corrige consulta para tomar correctmente el valor de fecha_hora de la tabla si_correos',
'FECHA: 07/11/2022',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se corrige consulta para validar el valor sobre fecha_hora de la tabla si_correos',
'FECHA: 11/01/2023',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se agrega validaciÃ³n sobre el status de correo (A/C), para solo obtener los correos con status "A" (Alta)';

CREATE PROCEDURE "informix".sp_inserta_msjafore(pNumcte CHAR(20), pCuenta_tarjeta CHAR(20), pSucursal CHAR(4), pDebito CHAR(8))

RETURNING CHAR(5)  AS cCodRet;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr 			INTEGER;

DEFINE cCurp			CHAR(20);
DEFINE cApell_paterno	CHAR(26);
DEFINE cApell_materno	CHAR(26);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cFecha_nac		DATE;
DEFINE cLugar_nac		CHAR(2);
DEFINE cSexo			CHAR(1);
DEFINE cNroCta_tarj		CHAR(20);

--Inicializacion de Variables
LET cCodRet    		= '00000';
LET iSqlErr 		= 0;

LET cCurp			= '';
LET cApell_paterno	= '';
LET cApell_materno	= '';
LET cNombre1		= '';
LET cNombre2		= '';
LET cFecha_nac		= NULL;
LET cLugar_nac		= '';
LET cSexo			= '';
LET cNroCta_tarj 	= '';


--SET DEBUG FILE TO '/ifxsif01/LIP/sp_inserta_msjafore.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--Sucursal y empleado
	IF ((pSucursal IS NOT NULL AND pSucursal <> '') AND (pDebito IS NOT NULL AND pDebito <> '')) THEN


		--Numero de cliente
		IF (pNumcte IS NOT NULL AND pNumcte <> '') THEN
		
			SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
			INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
			FROM bdinteg:si_cliente cte
					INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
			WHERE cte.numcte = pNumcte;


			INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
			VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
					
			RETURN cCodRet;
		
		END IF;
		
		--Numero de cuenta o tarjeta
		IF (pCuenta_tarjeta IS NOT NULL AND pCuenta_tarjeta <> '') THEN
			--Tarjeta
			IF(LENGTH(TRIM(pCuenta_tarjeta)) = 16) THEN
				
				
					--debito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicheq:sc_tarjeta 
					WHERE num_tarjeta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						

						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
								
						RETURN cCodRet;
					
					END IF;
				
				
					--credito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicred:sd_tarjeta 
					WHERE num_tarjeta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						
				
						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
							
						RETURN cCodRet;
				
					END IF;
				
			
			--Cuenta
			ELSE
			
				
					--debito
					SELECT FIRST 1 num_cte
					INTO pNumcte
					FROM bdicheq:sc_maechq 
					WHERE cuenta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						

						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
								
						RETURN cCodRet;
					
					END IF;
				
				
					--credito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicred:sd_maecred 
					WHERE num_credito = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
					
				
						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
							
						RETURN cCodRet;
					
					END IF;
				
			
			END IF;
			
		
		END IF;

	END IF;

	RETURN cCodRet;
END;

END PROCEDURE;