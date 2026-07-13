CREATE PROCEDURE "informix".sp_opers_por_cte_bei(pNumCliente char(9))
 returning char(5),   INTEGER ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE iCountUsuario INTEGER ;
    DEFINE iCountManco INTEGER ;
    
    DEFINE iTotalTokensEmpresa Integer;
    DEFINE iTokensolicitud Integer;
    DEFINE iTkn_nseries Integer;
    DEFINE iCantAdmons Integer;
    DEFINE iTotalOpersPuedeCrear Integer;
    DEFINE iOpersCreados Integer;
    DEFINE iTotalOpersDisp Integer;


    LET iCountUsuario=0;
    LET iCountManco=0;
    LET cod_ret  = "00000";
    LET iTotalTokensEmpresa = 0;
    LET iCantAdmons = 0;
    LET iTotalOpersDisp = 0;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LA CANTIDAD DE USUARIOS QUE PUEDEN SER CREADOS POR CUENTA
-- AUTOR : Jesus Ferruzca Luna
-- FECHA : 04/03/2014
-- BD: bdibei
-- SOLICITO :
-- MODIFICACION: Se modifica para que no tome en cuenta los administradores con estatus cancelado 99
-- Cuando se solicita un cambio de roll administrador, el administrador anterior se CACELA junto con con token 
-- y se borrra de la bdibei:bei_token. y el operador pasa a ser Administrador, se crea registro en al bei_servicio. 
-- por lo que el que esta cancelado ya no debe contar para permitir crear operadores.
-- FECHA MOD: 03-Nov- 2014
-- MODIFICO: Berenice Noriega Guevara - BanCoppel
--***************************************************************************************************
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret, iCountUsuario;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************
     SET LOCK MODE TO WAIT 4;
	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No ay Registros
          RETURN cod_ret, iCountUsuario;
	END IF;

		IF NOT EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_contratacion WHERE num_cliente=pNumCliente) THEN
			LET cod_ret = '00002'; -- No existe el Cliente
          	RETURN cod_ret, iCountUsuario;
		END IF;

--Cantidad de Tokens disponibles para la empresa
Select count(*)
Into iTokensolicitud
From "informix".bei_tokensolicitud
Where numcte = pNumCliente;

Select count(*)
Into iTkn_nseries
From bdibpi:"informix".tkn_nseries
Where ns_token in(
    Select ns_token
    From bei_tokensolicitud
    Where numcte = pNumCliente
)
And id_status = 199; --que sean distintos a cancelado

LET iTotalTokensEmpresa  = iTokensolicitud - iTkn_nseries;


--Cantidad de administradores que puede crear la empresa
Select count(*)
Into iCantAdmons
From bdibei:"informix".bei_servicio
Where num_cliente = pNumCliente
and id_status <> 99 ; --Que no esten cancelados.


--Total de operadores que puede crear la empresa
LET iTotalOpersPuedeCrear = iTotalTokensEmpresa - iCantAdmons;


--Cantidad de operadores creados
Select count(*)
Into iOpersCreados
From bdibei:"informix".bei_usuario 
Where num_cliente = pNumCliente
And id_tipo_usuario = 2;

--Cantidad de operadores pendientes por autorizar
SELECT COUNT(*)
INTO iCountManco
FROM bdibei:"informix".bei_admin_manco_temp
WHERE num_cliente_admin=pNumCliente
AND tipo_oper=1
AND tipo_mov=1;


--Calcular la cantidad de operadores que puede crear la empresa
LET iTotalOpersDisp = iTotalOpersPuedeCrear - (iOpersCreados + iCountManco);


     IF (iTotalOpersDisp > 0) THEN
         LET cod_ret = '00000'; -- Aun se pueden crear Usuarios
     ELSE
     	 LET cod_ret = '00003'; -- No se pueden crear mas Usuarios
     END IF ;

        RETURN cod_ret, iTotalOpersDisp;
END
END PROCEDURE;