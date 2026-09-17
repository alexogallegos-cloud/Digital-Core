CREATE PROCEDURE "informix".sp_conciliarcatalogozonas()

RETURNING CHAR(6), CHAR(80);
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     	CHAR(6);
DEFINE cMensaje                     	CHAR(80);
DEFINE vfechahoy                        DATE;
-----------------------------------------------------------
DEFINE vnumerociudad                    INTEGER;
DEFINE vnumerocolonia                   INTEGER;
DEFINE vnombrezona                      CHAR(32);
DEFINE vpoblacionzona                   CHAR(27);
DEFINE vmunicipiozona                   CHAR(27);
DEFINE vcodigopostalzona                INTEGER;  
DEFINE vsupervisorzona                  INTEGER;
DEFINE vchoferzona                      INTEGER;
DEFINE vjefegrupozona                   INTEGER;
DEFINE vgerentezona                     INTEGER;
DEFINE vabogadozona                     INTEGER;
DEFINE vcentro                          INTEGER;
DEFINE vciudadcobranzas                 INTEGER;
DEFINE vnumerocobranzas                 INTEGER;
DEFINE vnumerociudadcoppel              INTEGER;
DEFINE vnumerocoloniacoppel             INTEGER;
DEFINE vnombrezonacoppel                CHAR(32);

DEFINE v_numerociudad                    INTEGER;
DEFINE v_numerocolonia                   INTEGER;
DEFINE v_nombrezona                      CHAR(32);
DEFINE v_poblacionzona                   CHAR(27);
DEFINE v_municipiozona                   CHAR(27);
DEFINE v_codigopostalzona                INTEGER;  
DEFINE v_supervisorzona                  INTEGER;
DEFINE v_choferzona                      INTEGER;
DEFINE v_jefegrupozona                   INTEGER;
DEFINE v_gerentezona                     INTEGER;
DEFINE v_abogadozona                     INTEGER;
DEFINE v_centro                          INTEGER;
DEFINE v_ciudadcobranzas                 INTEGER;
DEFINE v_numerocobranzas                 INTEGER;
DEFINE v_numerociudadcoppel              INTEGER;
DEFINE v_numerocoloniacoppel             INTEGER;
DEFINE v_nombrezonacoppel                CHAR(32);

DEFINE vdia                             DATE;
DEFINE vHora                            CHAR(8);
DEFINE vEmpresa                         CHAR(3);
DEFINE vProceso                         CHAR(30);
DEFINE vProcesoinicio                   CHAR(30);
DEFINE cUSRCOPPEL                       CHAR(10);

DEFINE vErroneas						INTEGER;
DEFINE vTotalzonasrelacionadas          INTEGER;
DEFINE vTotalRegBcpl					INTEGER;
DEFINE vTotalRegCop 					INTEGER;
DEFINE csql                 			CHAR(500);
DEFINE vTotalRegErr						INTEGER;
DEFINE vTotalRegDup						INTEGER;
DEFINE vTotalRegIns						INTEGER;
DEFINE vTotalRegMod						INTEGER;
DEFINE vRuta							CHAR(100);
DEFINE iResult_upd                      INTEGER;

---------------------------------------------------------
LET vnumerociudad                    = 0;
LET vnumerocolonia                   = 0;
LET vnombrezona                      = '';
LET vpoblacionzona                   = '';
LET vmunicipiozona                   = '';
LET vcodigopostalzona                = 0;  
LET vsupervisorzona                  = 0;
LET vchoferzona                      = 0;
LET vjefegrupozona                   = 0;
LET vgerentezona                     = 0;
LET vabogadozona                     = 0;
LET vcentro                          = 0;
LET vciudadcobranzas                 = 0;
LET vnumerocobranzas                 = 0;
LET vnumerociudadcoppel              = 0;
LET vnumerocoloniacoppel             = 0;
LET vnombrezonacoppel                = '';

LET v_numerociudad                    = 0;
LET v_numerocolonia                   = 0;
LET v_nombrezona                      = '';
LET v_poblacionzona                   = '';
LET v_municipiozona                   = '';
LET v_codigopostalzona                = 0;  
LET v_supervisorzona                  = 0;
LET v_choferzona                      = 0;
LET v_jefegrupozona                   = 0;
LET v_gerentezona                     = 0;
LET v_abogadozona                     = 0;
LET v_centro                          = 0;
LET v_ciudadcobranzas                 = 0;
LET v_numerocobranzas                 = 0;
LET v_numerociudadcoppel              = 0;
LET v_numerocoloniacoppel             = 0;
LET v_nombrezonacoppel                = '';
LET vEmpresa                          = '001';
LET cUSRCOPPEL                        = 'SYSCARTERA';
LET iResult_upd                       = 0;
-----------------------------------------------------------
LET cCod_ret      	= '00000';
LET sql_err       	= 0;
LET cMensaje     	= 'Proceso Exitoso';
LET vProceso      	= 'sp_conciliarcatalogozonas';
LET vProcesoinicio 	= 'PROCESO INICIALIZADO';
-----------------------------------------------------------
    BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
           
            INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 
          
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------       
--Creado por José Almeida
--Fecha de creacion 22 de octubre de 2009
--Deberá instalarse en BDINTEG
--Se creo para el conciliamiento de datos de las zonas que existen en el catalogo de coppelcon los de bancoopel, aquellas zonas que existen en
--coppel y no bancoppel seran insertadas en el catalogo y aquellas que tienen diferencia entre sus campos
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Marco A. Campos 
--Fecha: 20100614
--Para que actualice en tabla si_catzonas         
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Marco A. Campos el 20110328
--Se modifica la estructura de tabla si_catzonas_bcpl_cpl y se guarda la fecha inserción o fecha modificación en si_catzonas, dependiendo del caso.
--Modificado por Marco A. Campos el 20110407
--Agregar dato para usr_modifica (SYSCARTERA) en si_catzonas. 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Abrham Lopez L.
--Fecha 24-04-2012
--Se le metio validación para que no inserte ciudades en cero.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Abrham Lopez L.
--Fecha 25-07-2012
--Se modifica para generar archivo de cifras control y archivo de detallescon zonas Erroneas, Duplicadas, Modificadas y Insertadas
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     --SET DEBUG FILE TO "/informix/ALL/SP_ConciliarCatalogoZonas.out";
     --TRACE ON;
       
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	   
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
        VALUES (vProceso,'11111' , vProcesoinicio, user, vdia, vHora, null); 
       
        ---------------Obtenemos la fecha de Hoy-----------------
        SELECT prox_fecha--fecha_hoy 
        INTO   vfechahoy
        FROM   bdinteg:si_fechas WHERE empresa = '001';        
		
		--LET vfechahoy = mdy('02','04','2022');   --- SOLO TEST MACF

        ---------------Borramos los datos de la tabla para insertar nuevos conciliados--------
        --DELETE si_catzonas_bcpl_cpl; ALL se inive esta opcion en este sp para ponerlo en el sp_importarcatalogozonas
        
        UPDATE statistics medium FOR TABLE bdinteg:"informix".si_catzonas_coppel;
        --------------Obtenemos los datos de las dos tablas y cuando no existan en bancoopel-----
        --------------se insertaran en el catalogo de bancoopel-----------------------------------       
         FOREACH
			SELECT  a.numerociudad,a.numerocolonia,a.nombrezona,a.poblacionzona,a.municipiozona,a.codigopostalzona
				   ,a.supervisorzona,a.choferzona,a.jefegrupozona,a.gerentezona,a.abogadozona,a.centro,a.ciudadcobranzas,a.numerocobranzas,a.numerociudadcoppel
				   ,a.numerocoloniacoppel,a.nombrezonacoppel,
					b.numerociudad,b.numerocolonia,b.nombrezona,b.poblacionzona,b.municipiozona,b.codigopostalzona
				   ,b.supervisorzona,b.choferzona,b.jefegrupozona,b.gerentezona,b.abogadozona,b.centro,b.ciudadcobranzas,b.numerocobranzas,b.numerociudadcoppel
				   ,b.numerocoloniacoppel,b.nombrezonacoppel
			 INTO   vnumerociudad,vnumerocolonia,vnombrezona,vpoblacionzona,vmunicipiozona,vcodigopostalzona
				   ,vsupervisorzona,vchoferzona,vjefegrupozona,vgerentezona,vabogadozona,vcentro,vciudadcobranzas,vnumerocobranzas,vnumerociudadcoppel
				   ,vnumerocoloniacoppel,vnombrezonacoppel,
					v_numerociudad,v_numerocolonia,v_nombrezona,v_poblacionzona,v_municipiozona,v_codigopostalzona
				   ,v_supervisorzona,v_choferzona,v_jefegrupozona,v_gerentezona,v_abogadozona,v_centro,v_ciudadcobranzas,v_numerocobranzas,v_numerociudadcoppel
				   ,v_numerocoloniacoppel,v_nombrezonacoppel
			  FROM  bdinteg:si_catzonas_coppel a
			  LEFT OUTER JOIN bdinteg:si_catzonas b ON (a.numerociudad = b.numerociudad AND a.numerocolonia = b.numerocolonia) 
	
		            
                              --IF ( v_numerociudad IS NULL )  THEN
							  
	--A.L.L. SE MODIFICA VALIDACION PARA QUE NO PERMITA INSERTAR CIUDADES IGUAL A CERO.
		IF ( NVL(v_numerociudad,'') ='' )  AND (Nvl(vnumerociudad,0) <> 0) THEN 
                    
          INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad, fecha_conciliacion, numerocolonia, numerociudadcoppel, numerocoloniacoppel,nombrezonacoppel,tipo_actualizacion)                                         
                                           VALUES (vnumerociudad, vfechaHoy, vnumerocolonia, vnumerociudadcoppel, vnumerocoloniacoppel, vnombrezonacoppel, 'I' );
                                                   
          INSERT INTO BDINTEG:si_catzonas(numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, supervisorzona, choferzona, 
										  jefegrupozona, gerentezona, abogadozona, centro,ciudadcobranzas, numerocobranzas, f_inserta, usr_modifica, numerociudadcoppel,
										  numerocoloniacoppel,nombrezonacoppel)
                                   VALUES (vnumerociudad, vnumerocolonia, vnombrezona, vpoblacionzona, vmunicipiozona, vcodigopostalzona, vsupervisorzona, vchoferzona,
										  vjefegrupozona, vgerentezona, vabogadozona, vcentro, vciudadcobranzas, vnumerocobranzas, vfechahoy,cUSRCOPPEL, vnumerociudadcoppel,
										  vnumerocoloniacoppel, vnombrezonacoppel);

		  UPDATE BDINTEG:si_catzonas_coppel SET b_conciliado = 'V' WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia;             
CONTINUE FOREACH;     
                              
	END IF;
          
          IF    (  (nvl(vcodigopostalzona,0) <> nvl(v_codigopostalzona,0))
                OR (nvl(vsupervisorzona,0) <> nvl(v_supervisorzona,0))    
                OR (nvl(vchoferzona,0) <> nvl(v_choferzona,0)) 
                OR (nvl(vjefegrupozona,0) <> nvl(v_jefegrupozona,0))
                OR (nvl(vgerentezona,0) <> nvl(v_gerentezona,0)) 
                OR (nvl(vabogadozona,0) <> nvl(v_abogadozona,0))
                OR (nvl(vcentro,0) <> nvl(v_centro,0))
                OR (nvl(vciudadcobranzas,0) <> nvl(v_ciudadcobranzas,0))
                OR (nvl(vnumerocobranzas,0) <> nvl(v_numerocobranzas,0))
                OR (nvl(vnumerociudadcoppel,0) <> nvl(v_numerociudadcoppel,0))
                OR (nvl(vnumerocoloniacoppel,0) <> nvl(v_numerocoloniacoppel,0))
                 ) THEN 
                                                                 
                INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad, fecha_conciliacion, numerocolonia, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel,tipo_actualizacion)                                         
                                                 VALUES (vnumerociudad, vfechaHoy, vnumerocolonia, vnumerociudadcoppel, vnumerocoloniacoppel, vnombrezonacoppel, 'M' );
     
                UPDATE BDINTEG:si_catzonas SET codigopostalzona = vcodigopostalzona, supervisorzona = vsupervisorzona, choferzona = vchoferzona,
                                               jefegrupozona = vjefegrupozona, gerentezona = vgerentezona, abogadozona = vabogadozona, centro = vcentro,
                                               ciudadcobranzas = vciudadcobranzas, numerocobranzas = vnumerocobranzas, numerociudadcoppel = vnumerociudadcoppel,
                                               numerocoloniacoppel = vnumerocoloniacoppel, nombrezonacoppel = vnombrezonacoppel, f_modifica = vfechaHoy,
                                               usr_modifica = cUSRCOPPEL WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia
											   AND (NVL(nomzona_spmx,'') = '' and nvl(mnpio_spmx,'') = '' and nvl(pobzona_spmx,'') = '');
                
                LET iResult_upd = DBINFO("sqlca.sqlerrd2"); 
		
		        IF iResult_upd = 0 THEN
				   -- Si no lo actualizó arriba por no encontrarlo, dejar que lo actualice menos el CP
				   UPDATE BDINTEG:si_catzonas SET supervisorzona = vsupervisorzona, choferzona = vchoferzona,
                                               jefegrupozona = vjefegrupozona, gerentezona = vgerentezona, abogadozona = vabogadozona, centro = vcentro,
                                               ciudadcobranzas = vciudadcobranzas, numerocobranzas = vnumerocobranzas, numerociudadcoppel = vnumerociudadcoppel,
                                               numerocoloniacoppel = vnumerocoloniacoppel, nombrezonacoppel = vnombrezonacoppel, f_modifica = vfechaHoy,
                                               usr_modifica = cUSRCOPPEL WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia;
				END IF;
				
				UPDATE BDINTEG:si_catzonas_coppel SET b_conciliado = 'V' WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia;
			--A.L.L. SE INSERTAN ZONAS RELACIONADAS EN LA TABLA si_catzonas_bcpl_cpl		
				IF (nvl(vnumerociudadcoppel,0) > 0
					and nvl(vnumerocoloniacoppel,0) > 0 
					and nvl(vnumerociudadcoppel,0) <> nvl(v_numerociudadcoppel,0)
					and nvl(vnumerocoloniacoppel,0) <> nvl(v_numerocoloniacoppel,0)) THEN
				
					INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad, fecha_conciliacion, numerocolonia, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel,tipo_actualizacion)                                         
													 VALUES (vnumerociudad, vfechaHoy, vnumerocolonia, vnumerociudadcoppel, vnumerocoloniacoppel, vnombrezonacoppel, 'R' );
			END IF;
             
      END IF;        
    END FOREACH;
   
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
		
---------------------------------A.L.L. GENERAMOS EL ARCHIVO DE CIFRAS CONTROL----------------------------------------------------------		
--A.L.L. SACAMOS EL TOTAL DE LAS DOS TABLAS PARA SUMAR Y QUE NOS DE EL TOTAL DE NUEROS DE REGISTROS RECIBIDOS

	--A.L.L. SACAMOS LA RUTA DONDE DEPOSITAREMOS EL ARCHIVO
		SELECT trim(valor) into vRuta
		  FROM bdinteg:si_param_dom
         WHERE empresa = '001' AND cod_param = 11;    --11;productivo,  24 pruevas
		 
		  --LET vRuta = '/ifxsif01/macf/';   -- SOLO TEST MACF
		 
	--A.L.L SACAMOS EL TOTAL DE ZONAS.
		SELECT COUNT(*)total
		INTO vTotalRegCop
		FROM bdinteg:si_catzonas_coppel;	
		
	--A.L.L. SACAMOS EL TOTAL DE ZONAS ERRONEAS Y DUPLICADAS
		SELECT COUNT(*)total 
		INTO vTotalRegBcpl
		FROM bdinteg:si_catzonas_bcpl_cpl 
		WHERE tipo_actualizacion  in ('E', 'D');
		
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS ERRONEOS    
		SELECT count(*) E
		INTO vTotalRegErr
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'E';
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS DUPLICADAS    
		SELECT count(*) D
		INTO vTotalRegDup
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'D';
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS INSERTADAS    
		SELECT count(*) I
		INTO vTotalRegIns
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'I';
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS MODIFICADAS    
		SELECT count(*) M
		INTO vTotalRegMod
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'M';
			
	--A.L.L. GENERAMOS EL ARCHIVO DE CIFRAS CONTROL	  
		LET cSql='';
		LET csql = 'echo "Fecha, Totalzonasrecibidas, Totalzonaserroneas, Totalzonasduplicadas, Totalzonasinsertadas, Totalzonasmodificadas, Totalzonasrelacionadas" >'||TRIM(vRuta)||'Cifrasrcatzonas'||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||'.txt';		 
		SYSTEM csql; 
	--A.L.L. SACAMOS LOS DATOS A INSERTAR EN EL ARCHIVO    
		LET csql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vRuta)||'Cifrasrcatzonas_1.unl'|| ' DELIMITER ' || ''','''|| 
		' select '''||vfechaHoy||''',' ||(vTotalRegCop + vTotalRegBcpl)||','||vTotalRegErr||','||vTotalRegDup||','||vTotalRegIns||','||vTotalRegMod||','||'round(count(*))::integer total_rel from si_catzonas_bcpl_cpl where tipo_actualizacion = ''R'' ;'|| 
		' " > '''||TRIM(vRuta)||'''Cifrasrcatzonas_1.sql';
		SYSTEM csql;
		
		LET csql = '';
		LET csql= 'dbaccess bdinteg  '||TRIM(vRuta)||'Cifrasrcatzonas_1.sql';
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS
		LET csql ='';
		LET csql ='rm  '||TRIM(vRuta)||'Cifrasrcatzonas_1.sql';
		SYSTEM csql;
		
		LET csql ='';
		LET csql = "sed 's/|$//g' "||TRIM(vRuta)||"Cifrasrcatzonas_1.unl >>"||TRIM(vRuta)||"Cifrasrcatzonas"||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||".txt";
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS		
		LET csql ='rm  '||TRIM(vRuta)||'Cifrasrcatzonas_1.unl';
		SYSTEM csql; 	
		
------------------------------------------------A.L.L. GENERAMOS EL ARCHIVO DE ZONAS ERRONEAS Y DUPLICADAS-----------------------------------------------------------------

	--A.L.L. GENERAMOS EL ARCHIVO DE ZONAS ERRONEAS Y DUPLICADAS	  
		LET cSql='';
		LET csql = 'echo "numerociudad, numerocolonia, fecha_conciliacion, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel, tipo_actualizacion" >'||TRIM(vRuta)||'Detallercatzonas'||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||'.txt';
		SYSTEM csql; 
	--A.L.L. SACAMOS LOS DATOS A INSERTAR EN EL ARCHIVO	 
		LET csql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vRuta)||'cifrasrcatzonas_1.unl'|| ' DELIMITER ' || '''|'''||
		' select numerociudad, numerocolonia, fecha_conciliacion, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel, tipo_actualizacion from si_catzonas_bcpl_cpl where tipo_actualizacion in (''E'',''D'',''I'',''M'',''R'') order by tipo_actualizacion; '||
		' " > '''||TRIM(vRuta)||'''cifrasrcatzonas_1.sql';
		SYSTEM csql;
		
		LET csql = '';
		LET csql= 'dbaccess bdinteg  '||TRIM(vRuta)||'cifrasrcatzonas_1.sql'; 
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS
		LET csql ='';
		LET csql ='rm  '||TRIM(vRuta)||'cifrasrcatzonas_1.sql';
		SYSTEM csql;
	
		LET csql ='';                                                 
		LET csql = "sed 's/|$//g' "||TRIM(vRuta)||"cifrasrcatzonas_1.unl >>"||TRIM(vRuta)||"Detallercatzonas"||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||".txt";
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS		
		LET csql ='rm  '||TRIM(vRuta)||'cifrasrcatzonas_1.unl';
		SYSTEM csql; 
       
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 
           
                 RETURN cCod_ret, cMensaje;
        END;
        END PROCEDURE;