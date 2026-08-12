CREATE PROCEDURE "informix".sp_consulta_datos_rep_dop(
													pRegIni integer,
													pNumCliente char(9),
													pTipoDisp char(4),
													pFecha varchar(10),
                                                    pArchivo varchar(12)
													)
    returning char(5),char(20),char(104),char(30),money(12,2),char(12),char(12);

    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    DEFINE sAlias char(20);
    DEFINE sNombre char(104);
    DEFINE sConcepto char(100);
    DEFINE mImporte money(12,2);
    DEFINE sClave char(12);
    DEFINE sArchivo CHAR(12);
    
    LET cod_ret  = "00000";
    LET sql_err = "";
    LET sAlias ="";
    LET sNombre = "";
    LET sConcepto = "";
    LET mImporte = 0.0;
    LET sClave= "";
    LET sArchivo = "";
   

	--****************************************************************************************************
	-- DESCRIPCION:  Consulta Beneficiarios por Dispersion
	-- AUTOR : Jesus Ferruzca Luna
	-- FECHA : 24/02/2015
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

	If NVL(pNumCliente,0) == 0 Then
		Let cod_ret="00001";
		return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo;
	End If;
	
	If NVL(pTipoDisp,0) == 0 Then
		Let cod_ret="00002";
		return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo;
	End If;

	If NVL(pFecha,'') == '' Then
		Let cod_ret="00003";
		return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo;
	End If;
 
     IF NVL(pArchivo,'') == '' THEN

     IF (pTipoDisp == '3004') THEN
        FOREACH
           Select SKIP pRegIni FIRST 10   concepto,sum(importe) AS importe, archivo
           Into sConcepto,mImporte, sArchivo
           From   bei_dispersiones_odp
           Where  num_cliente = pNumCliente
           And    tipo_dispersion = pTipoDisp
           And    fecha = TO_DATE(pFecha,'%d/%m/%Y')
           Group by concepto, archivo
           Order by archivo asc

           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo WITH RESUME;
          END FOREACH;
     ELSE 
        FOREACH
           Select SKIP pRegIni FIRST 10   alias,nombre_completo,concepto,importe, clave_envio,archivo
           Into sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo
            From   bei_dispersiones_odp
            Where  num_cliente = pNumCliente
            And    tipo_dispersion = pTipoDisp
            And    fecha = TO_DATE(pFecha,'%d/%m/%Y')

           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo WITH RESUME;
         END FOREACH;
     END IF;
     
    ELSE

     FOREACH
           Select SKIP pRegIni FIRST 10   alias,nombre_completo,concepto,importe, clave_envio,archivo
           Into sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo
            From   bei_dispersiones_odp
            Where  num_cliente = pNumCliente
            And    tipo_dispersion = pTipoDisp
            And    fecha = TO_DATE(pFecha,'%d/%m/%Y')
            And    archivo=pArchivo

           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo WITH RESUME;
    END FOREACH;
END IF;


END
END PROCEDURE;