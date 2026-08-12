CREATE PROCEDURE "informix".sp_obt_beneficiarios_bei(pRegIni integer,
													pNumCliente char(9),
													pTipoConsulta integer,
													pAlias CHAR(20),
													pNombre CHAR(50),
													pApellidoPaterno CHAR(50),
													pApellidoMaterno CHAR(50)
													)
    returning char(5),char(20),char(50),char(50),char(50),char(50),char(100), char(50),decimal(16,2);
   
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    DEFINE iTotalReg integer ;
    DEFINE sAlias char(20);
    DEFINE sPrimerNombre char(50);
    DEFINE sSegundoNombre char(50);
    DEFINE sApellidoPaterno char(50);
    DEFINE sApellidoMaterno char(50);
    DEFINE sDomicilio char(100);
    DEFINE sTelefono char(50);
    DEFINE sMontoMaximo decimal(16,2);
    
    LET cod_ret  = "000";
    LET sql_err = "";
    LET iTotalReg=0;
    LET sAlias ="";
    LET sPrimerNombre="";
    LET sSegundoNombre="";
    LET sApellidoPaterno="";
    LET sApellidoMaterno="";
    LET sDomicilio ="";
    LET sTelefono="";
    LET sMontoMaximo=0;

	
	--****************************************************************************************************
	-- DESCRIPCION:  Consulta Beneficiarios por filtro
	-- AUTOR : Jesus Ferruzca Luna
	-- FECHA : 10/02/2015
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	--***************************************************************************************************
	-- MODIFICACION:  Se ajusta para que no tome encuenta aquellos registrso que tienen menos de 30 min.
	-- AUTOR : Berenice Noriega Guevara
	-- FECHA : 12/Noviembre/2015
	-- BD: bdibei
	-- SOLICITO : Alejandro Vazquez - BanCoppel
	-- FECHA DE LIBERACIÓN A PRODUCCION: 17-Noviembre-2015
	--***************************************************************************************************

	
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

	If NVL(pNumCliente,0) == 0 Then
		Let cod_ret="00001";
		return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo;
	End If;
	
	If NVL(pTipoConsulta,0) == 0 Then
		Let cod_ret="00002";
		return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo;
	End If;
 
	
   		IF pTipoConsulta == 1 THEN --Consulta Todos los Beneficiarios

           Select count(*) total
           Into   iTotalReg
		   From   bdiprog:pp_beneficiariosfrec_bpi
		   Where  cve_estado <> '02'
           And    canal_baja <> '03'
	       And    num_cte = pNumCliente
		   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' );

		   				

		   
		   
        ELIF pTipoConsulta  == 2 THEN  --Consulta Beneficiarios por Alias
           If NVL(pAlias,'') = '' Then
		 		Let cod_ret="00003";
		 		return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo;
		   End If;  

		   Select count(*) total
		   Into   iTotalReg
		   From   bdiprog:pp_beneficiariosfrec_bpi
		   Where  cve_estado <> '02'
           And    canal_baja <> '03'
	       And    num_cte = pNumCliente
	       And    alias = upper(pAlias)
		   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' );
	       
        ELSE --Consulta por nombre 
        	If NVL(pNombre,'') == '' And NVL(pApellidoPaterno,'') == ''  And NVL(pApellidoMaterno,'') == '' Then
				Let cod_ret="00004";
				return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo;
			End If;
		
            IF NVL(pNombre,'') <> '' And NVL(pApellidoPaterno,'') <>''  And NVL(pApellidoMaterno,'')<> '' Then
               Select count(*) total
               Into   iTotalReg 
               From   bdiprog:pp_beneficiariosfrec_bpi
               Where  cve_estado <> '02'
               And    canal_baja <> '03'
               And    num_cte = pNumCliente
               And    primer_nombre = upper(pNombre) 
               And    apellido_paterno = upper(pApellidoPaterno) 
               And    apellido_materno = upper(pApellidoMaterno)
			   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' );
           
		   ELSE
               Select count(*) total
               Into   iTotalReg 
               From   bdiprog:pp_beneficiariosfrec_bpi
               Where  cve_estado <> '02'
               And    canal_baja <> '03'
               And    num_cte = pNumCliente
               And    primer_nombre = upper(pNombre) 
               And    apellido_paterno = upper(pApellidoPaterno)
			   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' );
			   
            END IF;

        END IF;

     SET LOCK MODE TO WAIT 4;

     IF iTotalReg == 0 THEN
          LET cod_ret = '005'; -- No ay Registros
          return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo;
     END IF;


--**************************************************************************************************************
--OBTIENES DATOS DE BENEFICIARIOS
--**************************************************************************************************************

    IF pTipoConsulta == 1 THEN

          FOREACH
           Select SKIP pRegIni FIRST 10  alias, nvl(primer_nombre,''),nvl(segundo_nombre,''),nvl(apellido_paterno,''),nvl(apellido_materno,'') ,nvl(domicilio_ben,''),nvl(no_celular,''), nvl(monto_maximo,0)
           Into    sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo
		   From   bdiprog:pp_beneficiariosfrec_bpi
		   Where  cve_estado <> '02'
           And    canal_baja <> '03'
	       And    num_cte = pNumCliente
		   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' )
           Order By alias asc

           return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo WITH RESUME;
         END FOREACH;
	ELIF pTipoConsulta  == 2  THEN
	      FOREACH
           Select SKIP pRegIni FIRST 10  alias, nvl(primer_nombre,''),nvl(segundo_nombre,''),nvl(apellido_paterno,''),nvl(apellido_materno,'') ,nvl(domicilio_ben,''),nvl(no_celular,''), nvl(monto_maximo,0)
		   Into    sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo
		   From   bdiprog:pp_beneficiariosfrec_bpi
		   Where  cve_estado <> '02'
           And    canal_baja <> '03'
	       And    num_cte = pNumCliente
	       And    alias = upper(pAlias)
		   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' )
           Order By alias asc
			
            return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo WITH RESUME;
          END FOREACH;
     ELSE

        IF NVL(pNombre,'') <> '' And NVL(pApellidoPaterno,'') <> ''  And NVL(pApellidoMaterno,'') <> '' Then
          FOREACH
           Select SKIP pRegIni FIRST 10  alias, nvl(primer_nombre,''),nvl(segundo_nombre,''),nvl(apellido_paterno,''),nvl(apellido_materno,'') ,nvl(domicilio_ben,''),nvl(no_celular,''), nvl(monto_maximo,0)
		   Into    sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo
		   From   bdiprog:pp_beneficiariosfrec_bpi
		   Where  cve_estado <> '02'
           And    canal_baja <> '03'
	       And    num_cte = pNumCliente
	       And    primer_nombre = upper(pNombre) 
           And    apellido_paterno = upper(pApellidoPaterno) 
           And    apellido_materno = upper(pApellidoMaterno)
		   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' )
           Order By alias asc

            return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo WITH RESUME;
          END FOREACH;
        ELSE
          FOREACH
           Select SKIP pRegIni FIRST 10  alias, nvl(primer_nombre,''),nvl(segundo_nombre,''),nvl(apellido_paterno,''),nvl(apellido_materno,'') ,nvl(domicilio_ben,''),nvl(no_celular,''), nvl(monto_maximo,0)
		   Into    sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo
		   From   bdiprog:pp_beneficiariosfrec_bpi
		   Where  cve_estado <> '02'
           And    canal_baja <> '03'
	       And    num_cte = pNumCliente
	       And    primer_nombre = upper(pNombre) 
           And    apellido_paterno = upper(pApellidoPaterno)
		   And 	  ((current-(YEAR(fecha_insert)||'-'||MONTH(fecha_insert)||'-'||DAY(fecha_insert)||' '||hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00' ) 
           Order By alias asc

            return cod_ret, sAlias,sPrimerNombre, sSegundoNombre,sApellidoPaterno, sApellidoMaterno,sDomicilio,sTelefono, sMontoMaximo WITH RESUME;
          END FOREACH;
        END IF;

    END IF;

END
END PROCEDURE;