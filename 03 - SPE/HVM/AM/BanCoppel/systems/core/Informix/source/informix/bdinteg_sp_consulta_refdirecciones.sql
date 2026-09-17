CREATE PROCEDURE "informix".sp_consulta_refdirecciones(
                                                            sNumCte       CHAR(20),
                                                            sSecuencia    INTEGER
                                                            )
               RETURNING CHAR(5), CHAR(20), INTEGER, CHAR(1), CHAR(40), CHAR(60), CHAR(40), CHAR(3), CHAR(2), CHAR(3), 
                                        CHAR(5), CHAR(5), CHAR(11), CHAR(1), CHAR(13), CHAR(1), CHAR(13), CHAR(1), CHAR(13), CHAR(5), 
                                        CHAR(2), CHAR(3), CHAR(4), INTEGER, CHAR(10), CHAR(10), CHAR(6), INTEGER, INTEGER, CHAR(1), 
                                        CHAR(1), INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, CHAR(80), CHAR(20),
                                        CHAR(8), DATE, CHAR(1), CHAR(1), CHAR(1);

--DOCUMENTACION:
--Realizó: Daniela Ramírez
--Fecha: 02/06/2011
--Funcionalidad: Consulta la tabla si_refdirecciones la cual regresa los datos de la direccion de la referencia.

-- Se definen variables
DEFINE cCodRet     CHAR(5);
DEFINE iSqlErr     INTEGER;

--Se definen variables de la tabla si_refdirecciones
DEFINE cNumcte CHAR(20);
DEFINE iSecuencia INTEGER;
DEFINE cTipo_dir CHAR(1);
DEFINE cCalle CHAR(40);
DEFINE cColonia CHAR(60);
DEFINE cEntre_calles CHAR(40);
DEFINE cPais CHAR(3);
DEFINE cEstado CHAR(2);
DEFINE cCiudad CHAR(3);
DEFINE cMunicipio CHAR(5);
DEFINE cCod_postal CHAR(5);
DEFINE cApart_postal CHAR(11);
DEFINE cTipo_telef1 CHAR(1);
DEFINE cTelefono1 CHAR(13);
DEFINE cTipo_telef2 CHAR(1);
DEFINE cTelefono2 CHAR(13);
DEFINE cTipo_telef3 CHAR(1);
DEFINE cTelefono3 CHAR(13);
DEFINE cExtension CHAR(5);
DEFINE cEstado_inegi CHAR(2);
DEFINE cMunicipio_inegi CHAR(3);
DEFINE cLocalidad_inegi CHAR(4);
DEFINE iNumerociudad INTEGER;
DEFINE cNumeroextcalle CHAR(10);
DEFINE cNumerointcalle CHAR(10);
DEFINE cDepartamento CHAR(6);
DEFINE iNumerocalle INTEGER;
DEFINE iNumerocolonia INTEGER;
DEFINE cPuntocardinal CHAR(1);
DEFINE cUnidadhabitac CHAR(1);
DEFINE iManzana INTEGER;
DEFINE iOtros INTEGER;
DEFINE iAndador INTEGER;
DEFINE iEtapa INTEGER;
DEFINE iLote INTEGER;
DEFINE iEdificio INTEGER;
DEFINE iEntrada INTEGER;
DEFINE cObservaciones CHAR(80);
DEFINE cNumcte_banco CHAR(20);
DEFINE cUser_insert CHAR(8);
DEFINE cFecha_insert DATE;
DEFINE cInd_cofeteltel1 CHAR(1);
DEFINE cInd_cofeteltel2 CHAR(1);
DEFINE cInd_cofeteltel3 CHAR(1);


-- Se inicializan variables
LET cCodRet = "00000";
LET iSqlErr = 0;
-- Se inicializan variables tabla si_refdirecciones
LET cNumcte = ' ';
LET iSecuencia = 0;
LET cTipo_dir = ' ';
LET cCalle = ' ';
LET cColonia = ' ';
LET cEntre_calles = ' ';
LET cPais = ' ';
LET cEstado = ' ';
LET cCiudad = ' ';
LET cMunicipio = ' ';
LET cCod_postal = ' ';
LET cApart_postal = ' ';
LET cTipo_telef1 = ' ';
LET cTelefono1 = ' ';
LET cTipo_telef2 = ' ';
LET cTelefono2 = ' ';
LET cTipo_telef3 = ' ';
LET cTelefono3 = ' ';
LET cExtension = ' ';
LET cEstado_inegi = ' ';
LET cMunicipio_inegi = ' ';
LET cLocalidad_inegi = ' ';
LET iNumerociudad = 0;
LET cNumeroextcalle = ' ';
LET cNumerointcalle = ' ';
LET cDepartamento = ' ';
LET iNumerocalle = 0;
LET iNumerocolonia = 0;
LET cPuntocardinal = ' ';
LET cUnidadhabitac = ' ';
LET iManzana = 0;
LET iOtros = 0;
LET iAndador = 0;
LET iEtapa = 0;
LET iLote = 0;
LET iEdificio = 0;
LET iEntrada = 0;
LET cObservaciones = ' ';
LET cNumcte_banco = ' ';
LET cUser_insert  = ' ';
LET cFecha_insert = DATE(1);
LET cInd_cofeteltel1 = ' ';
LET cInd_cofeteltel2 = ' ';
LET cInd_cofeteltel3 = ' ';

--        SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consulta_refdirecciones.out";
--        TRACE ON;
		
BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNumcte, iSecuencia, cTipo_dir, cCalle, cColonia, cEntre_calles, cPais, cEstado, cCiudad, cMunicipio, cCod_postal, 
                            cApart_postal, cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, cExtension, cEstado_inegi, 
                            cMunicipio_inegi, cLocalidad_inegi, iNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, iNumerocalle, 
                            iNumerocolonia, cPuntocardinal, cUnidadhabitac, iManzana, iOtros, iAndador, iEtapa, iLote,iEdificio, iEntrada, cObservaciones, 
                            cNumcte_banco, cUser_insert, cFecha_insert , cInd_cofeteltel1, cInd_cofeteltel2, cInd_cofeteltel3;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;

    IF (sNumCte <> ' ' AND sNumCte IS NOT NULL) THEN

            SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, tipo_telef1, 
                           telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
                           numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
                           andador, etapa, lote, edificio, entrada, observaciones, numcte_banco, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, 
                           ind_cofeteltel3
                 INTO cNumcte, iSecuencia, cTipo_dir, cCalle, cColonia, cEntre_calles, cPais, cEstado, cCiudad, cMunicipio, cCod_postal, cApart_postal, 
                           cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, cExtension, cEstado_inegi, cMunicipio_inegi, 
                           cLocalidad_inegi, iNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, iNumerocalle, iNumerocolonia, 
                           cPuntocardinal, cUnidadhabitac, iManzana, iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones, cNumcte_banco,
                           cUser_insert, cFecha_insert , cInd_cofeteltel1, cInd_cofeteltel2, cInd_cofeteltel3
               FROM bdinteg:"informix".si_refdirecciones
            WHERE numcte = sNumCte 
                 AND  secuencia = sSecuencia;

           LET cCodRet = "00000"; -- Realiza consulta

   ELSE

            LET cCodRet = "00001";  -- Los parametros que se mandaron son incorrectos

   END IF;

        RETURN cCodRet, cNumcte, iSecuencia, cTipo_dir, cCalle, cColonia, cEntre_calles, cPais, cEstado, cCiudad, cMunicipio, cCod_postal, 
                        cApart_postal, cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, cExtension, cEstado_inegi, 
                        cMunicipio_inegi, cLocalidad_inegi, iNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, iNumerocalle, 
                        iNumerocolonia, cPuntocardinal, cUnidadhabitac, iManzana, iOtros, iAndador, iEtapa, iLote,iEdificio, iEntrada, cObservaciones, 
                        cNumcte_banco, cUser_insert, cFecha_insert , cInd_cofeteltel1, cInd_cofeteltel2, cInd_cofeteltel3;

END;
END PROCEDURE;