CREATE PROCEDURE "informix".sp_consulta_datos_emp_bei(pNumCliente CHAR(9))
   returning char(5), char(13),char(40),char(60),char(60),char(60);


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE sTelefono char(13);
    DEFINE sCalle  char(40);
    DEFINE sColonia char(60);
    DEFINE sCiudad char(60);
    DEFINE sEstado char(60);

    LET cod_ret     ="00000";
    LET sTelefono   ="";
    LET sCalle      ="";
    LET sColonia    ="";
    LET sCiudad     ="";
    LET sEstado     ="";
       

--****************************************************************************************************
-- DESCRIPCION: Consulta direccion y telefono de la empresa
-- AUTOR : Jesus Ferruzca Luan
-- FECHA : 23/02/2015
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret, sTelefono,sCalle, sColonia, sCiudad, sEstado;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA Existencia de Nombre de Usuario
--**************************************************************************************************************

     IF NVL(pNumCliente,'') == '' THEN
          LET cod_ret = '00001'; -- No mando Num de Cliente
          RETURN cod_ret, sTelefono,sCalle, sColonia, sCiudad, sEstado;
     END IF ;

 Select first 1  t.telefono
    Into   sTelefono
    From   (
        Select nvl(telefono,'') telefono
        From   bdinteg:si_telefonos_actual
        WHERE  numcte = pNumCliente
        Order by fecha_hora desc
    ) as t;


    Select nvl(d.calle,''), nvl(d.colonia,''),nvl(c.nombre,''), nvl(e.nombre,'')
    Into   sCalle, sColonia, sCiudad, sEstado
    From   bdinteg:si_direcciones_actual d
    Inner Join bdinteg:si_ciudades c On(d.ciudad = c.ciudad And d.pais = c.pais And d.estado = c.estado)
    Inner Join bdinteg:si_estados e On(d.estado = e.estado And d.pais = e.pais)
    Where  d.numcte = pNumCliente
    And    d.tipo_dir = 1;

let sCalle = 'calle';
let sColonia = 'colonia';
   RETURN cod_ret, sTelefono,sCalle, sColonia, sCiudad, sEstado;

END
END PROCEDURE;