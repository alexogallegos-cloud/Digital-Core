CREATE PROCEDURE "informix".sp_consulta_refclientes(
                                                    sEmpresa    CHAR(3),
                                                    sNumCte     CHAR(20),
                                                    sNumSol     CHAR(20),
                                                    sParentesco CHAR(2),
                                                    sTelefono   CHAR(13),
                                                    sSecuencia  INTEGER
                                                    )
               RETURNING CHAR(5), CHAR(3), CHAR(20), CHAR(20), CHAR(4), INTEGER, CHAR(26), CHAR(26), CHAR(26),
                         CHAR(26), CHAR(13), DATE, CHAR(20), CHAR(1), CHAR(2), CHAR(3), CHAR(18), CHAR(2), CHAR(30), CHAR(2),
                         CHAR(60), CHAR(2), CHAR(26), CHAR(20), CHAR(20), CHAR(8), DATE, CHAR(13), CHAR(13), CHAR(13), CHAR(5);

--DOCUMENTACION:
--Realizó: Daniela Ramírez
--Fecha: 02/06/2011
--Funcionalidad: Consulta la tabla si_refcliente la cual regresa los datos de la referencia del cliente.

-- Se definen variables
DEFINE cCodRet     CHAR(5);
DEFINE iSqlErr     INTEGER;

--Se definen variables de la tabla si_refclientes
DEFINE cEmpresa CHAR(3);
DEFINE cNum_solicitud CHAR(20);
DEFINE cNumcte CHAR(20);
DEFINE cSucursal CHAR(4);
DEFINE iSecuencia INTEGER;
DEFINE cApell_paterno CHAR(26);
DEFINE cApell_materno CHAR(26);
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cRfc CHAR(13);
DEFINE cFecha_nac DATE;
DEFINE cCurp CHAR(20);
DEFINE cSexo CHAR(1);
DEFINE cEstado_civil CHAR(2);
DEFINE cNacionalidad CHAR(3);
DEFINE cNo_fm3 CHAR(18);
DEFINE cCodidentifi CHAR(2);
DEFINE cNumidentifi CHAR(30);
DEFINE cPers_domicilio CHAR(2);
DEFINE cEmail CHAR(60);
DEFINE cParentesco CHAR(2);
DEFINE cApellido_cas CHAR(26);
DEFINE cNumcte_ref CHAR(20);
DEFINE cNumcte_banco CHAR(20);
DEFINE cUser_insert CHAR(8);
DEFINE cFecha_insert DATE;
--Se declaran variables tabla si_refdirecciones
DEFINE cTelefono1 CHAR(13);
DEFINE cTelefono2 CHAR(13);
DEFINE cTelefono3 CHAR(13);
DEFINE cExtension CHAR(5);

-- Se inicializan variables
LET cCodRet = "00000";
LET iSqlErr = 0;
--Se inicializan variables tabla si_refclientes
LET cEmpresa = ' '; 
LET cNum_solicitud = ' ';
LET cNumcte = ' '; 
LET cSucursal = ' '; 
LET iSecuencia = 0;
LET cApell_paterno = ' '; 
LET cApell_materno = ' '; 
LET cNombre1 = ' '; 
LET cNombre2 = ' '; 
LET cRfc = ' '; 
LET cFecha_nac = DATE(1);
LET cCurp = ' '; 
LET cSexo = ' '; 
LET cEstado_civil = ' '; 
LET cNacionalidad = ' '; 
LET cNo_fm3 = ' '; 
LET cCodidentifi = ' '; 
LET cNumidentifi = ' '; 
LET cPers_domicilio = ' '; 
LET cEmail = ' '; 
LET cParentesco = ' '; 
LET cApellido_cas = ' '; 
LET cNumcte_ref = ' '; 
LET cNumcte_banco = ' '; 
LET cUser_insert = ' '; 
LET cFecha_insert = DATE(1);
--Se inicializan variables tabla si_refdirecciones
LET cTelefono1 = " ";
LET cTelefono2 = " ";
LET cTelefono3 = " ";
LET cExtension = " ";

--        SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consulta_refclientes.out";
--        TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cEmpresa, cNum_solicitud, cNumcte, cSucursal, iSecuencia, cApell_paterno, cApell_materno, cNombre1, cNombre2, 
                            cRfc, cFecha_nac, cCurp, cSexo, cEstado_civil, cNacionalidad, cNo_fm3, cCodidentifi, cNumidentifi, cPers_domicilio, cEmail, 
                            cParentesco, cApellido_cas, cNumcte_ref, cNumcte_banco, cUser_insert, cFecha_insert, cTelefono1, cTelefono2, cTelefono3, 
                            cExtension;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF (sNumCte <> ' ' AND sNumCte IS NOT NULL) THEN

            SELECT ref.empresa, ref.num_solicitud, ref.numcte, ref.sucursal, ref.secuencia, ref.apell_paterno, ref.apell_materno, ref.nombre1, 
                   ref.nombre2, ref.rfc, ref.fecha_nac, ref.curp, ref.sexo, ref.estado_civil, ref.nacionalidad, ref.no_fm3, ref.codidentifi, ref.numidentifi, 
                   ref.pers_domicilio, ref.email, ref.parentesco, ref.apellido_cas, ref.numcte_ref, ref.numcte_banco, ref.user_insert, ref.fecha_insert, 
                   refdir.telefono1, refdir.telefono2, refdir.telefono3, refdir.extension
            INTO cEmpresa, cNum_solicitud, cNumcte, cSucursal, iSecuencia, cApell_paterno, cApell_materno, cNombre1, cNombre2, 
                 cRfc, cFecha_nac, cCurp, cSexo, cEstado_civil, cNacionalidad, cNo_fm3, cCodidentifi, cNumidentifi, cPers_domicilio, cEmail, 
                 cParentesco, cApellido_cas, cNumcte_ref, cNumcte_banco, cUser_insert, cFecha_insert, cTelefono1, cTelefono2,
                 cTelefono3, cExtension
            FROM bdinteg:"informix".si_refclientes ref 
            LEFT OUTER JOIN bdinteg:"informix".si_refdirecciones refdir 
                 ON (refdir.numcte = ref.numcte
                 AND refdir.secuencia = ref.secuencia)
            WHERE (refdir.telefono1 = sTelefono OR refdir.telefono2 = sTelefono OR refdir.telefono3 = sTelefono)
                 AND ref.empresa = sEmpresa
                 AND ref.numcte = sNumCte 
                 AND ref.num_solicitud = sNumSol
                 AND ref.parentesco = sParentesco
                 AND ref.secuencia = sSecuencia;

           LET cCodRet = "00000"; -- Realiza consulta

   ELSE
            LET cCodRet = "00001";  -- Los parametros que se mandaron son incorrectos
   END IF;

        RETURN cCodRet, cEmpresa, cNum_solicitud, cNumcte, cSucursal, iSecuencia, cApell_paterno, cApell_materno, cNombre1, cNombre2, 
                        cRfc, cFecha_nac, cCurp, cSexo, cEstado_civil, cNacionalidad, cNo_fm3, cCodidentifi, cNumidentifi, cPers_domicilio, cEmail, 
                        cParentesco, cApellido_cas, cNumcte_ref, cNumcte_banco, cUser_insert, cFecha_insert, cTelefono1, cTelefono2, cTelefono3, 
                        cExtension;

END;
END PROCEDURE;