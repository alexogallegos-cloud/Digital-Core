CREATE PROCEDURE "informix".sp_exportarcatalogozonas_web(pCatalogo CHAR(1), pFechaAct DATE, pSeparador CHAR(1), pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (3000);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(30);
DEFINE vNomArchAux                      CHAR(40);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: Josï¿½ de Jesï¿½s Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de exportar el total o una parcialidad de las zonas del catalogo

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parï¿½metro pEjecucion para determinar si es Autmï¿½tica o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catzonas_web';
LET vNomArchAux   = 'si_catzonas_web_Aux';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/informix/Roberto/sp_ExportarCatalogoZonasWeb.out";
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas WHERE empresa = '001';
    
    if pEjecucion = 'A' then
        select trim(valor) into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    else
        select trim(valor) || '/tmp/' into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    end if;
    LET vPath = TRIM(vPath);

    LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);

IF (pCatalogo = 1) THEN
        
          				
		  LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerociudad, a.numerocolonia, '
                || 'upper(limpia_cadenaweb(a.nombrezona)), upper(limpia_cadenaweb(a.poblacionzona)), upper(limpia_cadenaweb(a.municipiozona)), nvl(a.codigopostalzona,0) codigopostalzona, '
                || 'a.planozona, upper(limpia_cadenaweb(nvl(a.rumbozona,''''))), '
                || 'nvl(a.supervisorzona,0) supervisorzona, nvl(a.choferzona,0) choferzona, nvl(a.jefegrupozona,0) jefegrupozona, nvl(a.gerentezona,0) gerentezona, '
                || 'nvl(a.abogadozona,0) abogadozona, a.marcaencuesta30dias, nvl(a.numerocalle,0) numerocalle, nvl(a.numerocasa,0) numerocasa, '
                || 'a.marcaunidadhabitacional, nvl(a.numerodivisioncobranzas,0) numerodivisioncobranzas, nvl(a.claveabogado,0) claveabogado, '
                || 'nvl(a.ciudadcobranzas,0) ciudadcobranzas, nvl(a.numerocobranzas,0) numerocobranzas,''1'' clavearagon, nvl(a.centro,0) centro '
                || ' FROM BDINTEG:si_catzonas a '
                --|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' --VALIDACION SEPOMEX
                || ' where nvl(a.mnpio_spmx,'''') <>'''' '
		    	|| '" >' || trim(vPath) ||'corre_si_catzonas_web.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 
    
    
ELIF (pCatalogo = 0) THEN
     
LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerociudad, a.numerocolonia, '
                || 'upper(limpia_cadenaweb(a.nombrezona)), upper(limpia_cadenaweb(a.poblacionzona)), upper(limpia_cadenaweb(a.municipiozona)), nvl(a.codigopostalzona,0) codigopostalzona, '
                || 'a.planozona, upper(limpia_cadenaweb(nvl(a.rumbozona,''''))), '
                || 'nvl(a.supervisorzona,0) supervisorzona, nvl(a.choferzona,0) choferzona, nvl(a.jefegrupozona,0) jefegrupozona, nvl(a.gerentezona,0) gerentezona, '
                || 'nvl(a.abogadozona,0) abogadozona, a.marcaencuesta30dias, nvl(a.numerocalle,0) numerocalle, nvl(a.numerocasa,0) numerocasa, '
                || 'a.marcaunidadhabitacional, nvl(a.numerodivisioncobranzas,0) numerodivisioncobranzas, nvl(a.claveabogado,0) claveabogado, '
                || 'nvl(a.ciudadcobranzas,0) ciudadcobranzas, nvl(a.numerocobranzas,0) numerocobranzas, ''1'' clavearagon, nvl(a.centro,0) centro '                
				|| ' FROM BDINTEG:si_catzonas a '
				--|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' --VALIDACION SEPOMEX
                || ' where nvl(a.mnpio_spmx,'''') <>'''' '
                || ' and f_inserta >= ''' || pFechaAct || ''' '
				|| '" >' || trim(vPath) ||'corre_si_catzonas_web.sql'; 
				
				
          --System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          --System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          --SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          --System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          --System cCadena; 

   
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parï¿½metro de Catï¿½logo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Victor D. Vazquez',
'FECHA: 2023/04/04',
'DESCRIPCION: Se modifica para agregar la depuraciï¿½n de caracteres especiales en algunos campos para SIWEB',
'BD: bdinteg',
'VERSION:202300404.100';

CREATE PROCEDURE "informix".sp_consulta_datos()
	returning CHAR(5) AS cCodRet;

DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE IidErr           INTEGER; 
DEFINE pArchDeclarga1	CHAR(100);
DEFINE pArchDeclarga2   CHAR(100);
DEFINE pArchDeclarga3   CHAR(100);
DEFINE cQuery1          CHAR(10000);
DEFINE cSentencia       CHAR(200);
DEFINE sMes         	CHAR(2);
DEFINE sYear        	CHAR(4);
DEFINE sFechaArch   	CHAR(10);
DEFINE cNum   	   		CHAR(20);
DEFINE csicliente   	CHAR(20);
DEFINE cSecuencia       INTEGER;
DEFINE cCodpostal       CHAR(5);
DEFINE cSexo       		CHAR(1);
DEFINE cFecha_nac       DATE;
DEFINE vsql             CHAR(3000);
DEFINE cDescripcion     CHAR(40);
DEFINE cTipoP           CHAR(2);
DEFINE iCont			SMALLINT;
DEFINE iMaxCommit		INTEGER;

LET cCodRet 			= "00000";
LET IidErr				=0;
LET pArchDeclarga1   	= '';
LET sMes            	= '';
LET sYear           	= '';
LET sFechaArch      	= '';
LET cNum                = '';
LET csicliente 			= '';
LET cSecuencia			= '';
LET cCodpostal          = '';
LET cSexo				= '';
LET cFecha_nac          = '';
LET vsql				= '';
LET cDescripcion        = '';
LET cTipoP 				= '';
LET iCont				= 0;
LET iMaxCommit			= 5000;

	--SET DEBUG FILE TO "/ifxsif01/machavez/salidasp.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE LIMPIA LA TABLAS
	TRUNCATE TABLE td_numCliente;
	TRUNCATE TABLE td_descarga_datos;
	
	LET sMes= month(TODAY);	LET sYear= year(TODAY);	LET sFechaArch=sYear||sMes;
	
	LET pArchDeclarga2='"/RESPALDOSNEW/NumeroCliente'||TRIM(sFechaArch)||'.unl"';
	LET pArchDeclarga3='"/RESPALDOSNEW/"';
		
	LET cSentencia = 'echo "load from ' || TRIM(pArchDeclarga2)|| ' INSERT INTO td_numCliente  " > '|| TRIM(pArchDeclarga3)||'archivoinsert.sql';
	SYSTEM cSentencia;	  
	LET cSentencia = '';
	LET cSentencia = "dbaccess bdinteg " ||TRIM(pArchDeclarga3)||'archivoinsert.sql';
	SYSTEM cSentencia;
	
		BEGIN WORK;
			--create temp table descarga_datos_tmp (numcte char(20), Fecha_nacimiento date, sexo char(1), cod_postal char(5))WITH NO LOG;
			FOREACH WITH HOLD
				SELECT numcte INTO cNum FROM td_numCliente
		
				SELECT numcte, tpo_persona INTO csicliente, cTipoP FROM si_cliente WHERE  numcte = cNum;   
		
				IF (cNum = csicliente ) THEN
					
					LET cDescripcion = '';
					
					SELECT cod_postal, secuencia
					INTO cCodpostal, cSecuencia FROM si_direcciones
					WHERE numcte = csicliente and secuencia =(Select max(secuencia) FROM si_direcciones
															WHERE numcte = csicliente and tipo_dir = '1' group by numcte);
					
					IF ( cTipoP = '01' ) THEN
					
						SELECT  sexo, fecha_nac INTO cSexo, cFecha_nac FROM si_ctepf WHERE numcte = csicliente;
					
					END IF;
				ELSE
					LET cDescripcion = 'No se encontro el numero de cliente';
					LET cCodpostal = '';
					LET cSexo = '';
					LET cFecha_nac = '';
					
					IF (length(cNum) <> 9) THEN
					    LET cDescripcion = 'No corresponde a un numero de cliente';
					END IF;
					
				END IF;
				
				--Inserta los registros obtenidos en la tabla si_detalle_rpt_idbox
				INSERT INTO "informix".td_descarga_datos(numcte,fecha_nac,sexo,cod_postal,descripcion)
				VALUES (cNum,cFecha_nac,cSexo,cCodpostal,cDescripcion);
				
				LET iCont=iCont+1;
				IF iCont >= iMaxCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;
	
		COMMIT WORK;
		
		BEGIN WORK;
			--generacion de reporte 
			let vsql ='echo "No_cliente|Fecha_nacimiento|Sexo|Codigo_postal|Descripcion">/RESPALDOSNEW/RPT_Datoscliente'||TRIM(sFechaArch)||'.txt';
			system vsql;
			let vsql='echo "UNLOAD TO /RESPALDOSNEW/TmpDatosCL.txt '||
			'SELECT numcte,fecha_nac,sexo,cod_postal,descripcion '|| 
			'FROM informix.td_descarga_datos;">/RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			system vsql;
			let vsql='dbaccess bdinteg /RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			let vsql ='rm /RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			let vsql ="sed 's/|$//g' /RESPALDOSNEW/TmpDatosCL.txt >>/RESPALDOSNEW/RPT_Datoscliente'"||TRIM(sFechaArch)||"'.txt";
			system vsql;
			let vsql ='rm /RESPALDOSNEW/TmpDatosCL.txt';
			system vsql;
			let cCodRet ='00000';
		COMMIT WORK;
		
		--SE LIMPIA LA TABLAS
		TRUNCATE TABLE td_numCliente;
		TRUNCATE TABLE td_descarga_datos;
	
	RETURN cCodRet;
END;
END PROCEDURE;