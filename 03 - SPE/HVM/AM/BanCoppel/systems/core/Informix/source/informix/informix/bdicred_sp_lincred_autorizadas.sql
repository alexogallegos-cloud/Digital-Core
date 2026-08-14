create procedure "informix".sp_lincred_autorizadas(
    pempresa        char(3),
    pSucursal       char(4),
    pNumSolicitud   char(20),
    pNumCliente     char(20),
    pBan            char(1),
	pFechaInicial   Date,
	pFechaFinal     Date)

returning
    char(6),  -- Cod Error
    char(4),  -- Sucursal
    char(20), -- Numero Cliente
    Char(20), -- Numero Solicitud
    date, -- Fecha Apertura
    date, -- Fecha Entrada
    integer,  -- Monto Solicitado
    integer,  -- Monto Otorgado
    integer,  -- Monto Actual
    char(50), -- Ultimo Movimiento
    char(104);


--30-01-2008
--Walber Castro
--SP para listar las Líneas de Crédito Autorizadas, basado en RQM 09-023
--Devuelve las Líneas de Crédito Autorizadas por sucursal del crédito.
--Recibe la sucursal que se desea consultar.
--Enviar sucursal vacía si se desea todas las sucursales.

--04-11-2008
--David Uriel Prieto Hurtado
--SP para listar las Lineas de Crédito Autorizadas basadas en el RQM 09-022
--Se modifico con 2 campos  mas las cuales devuelven el monto actual y la ultima operacion realizada
--Recibe el  numero de cliente del que se desea saber su situacion actual.

-- Fecha: 05-12-2008
-- Nombre: Paul Ivan Quintero Varela
-- Observaciones: Se modifico lo siguiente:
--                1.- Se agrega en el retorno el numero de solicitud del cliente,
--                2.- Se omiten aquellos credito que no hayan sufrido un cambio ya
--                    sea aumento o disminucion en su linea de credito.
--                3.- Se modifica la obtencion de la fecha tanto de la solicitud como del ultimo movimiento
--                4.- Se modifica select principal para optimizar la consulta.

-- Fecha: 20-12/2008
-- Nombre: David Uriel Prieto Hurtado
-- Observaciones: Se modifico lo siguiente:
--                1.- Se modifica query principal para contemplar rango de fechas, en caso de realizar
--                    la consulta por sucursal.


DEFINE SQL_ERR         INTEGER;
DEFINE P_COD_RET       VARCHAR(6);
define cSucursal       char(4);
define cNumcte         char(20);
define dFechaApertura  date;
define dFechaEntrada   date;
define iMontoSolic     Integer;
define iMontoOtor      Integer;
define iMontoAct       Integer;
define cUltimoMOv      char(50);
define cNombre        char(104);
define cNumSolic       char (20);

define iMonto_aumento           integer;
define iMonto_Disminucion       integer;
define iMonto_apertura          integer;
define iSecuenciaMayorAum_His   integer;
define iSecuenciaMayorDism_His  integer;

define iMonto_aumento_dia       integer;
define iMonto_Disminucion_dia   integer;
define iMonto_apertura_dia      integer;
define iSecuenciaMayorAum_dia   integer;
define iSecuenciaMayorDism_dia  integer;

define iMonto_aumento_dia_1       integer;
define iMonto_Disminucion_dia_1   integer;
define iMonto_apertura_dia_1      integer;
define iSecuenciaMayorAum_dia_1   integer;
define iSecuenciaMayorDism_dia_1  integer;

define iMonto_aumento_dia_2       integer;
define iMonto_Disminucion_dia_2   integer;
define iMonto_apertura_dia_2      integer;
define iSecuenciaMayorAum_dia_2   integer;
define iSecuenciaMayorDism_dia_2  integer;

define dFechaMax_his            date;
define dFechaMax_dia            date;
define dFechaMax_dia_1          date;
define dFechaMax_dia_2          date;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    Begin
      ON EXCEPTION SET SQL_ERR--, ISAM_ERR, ERROR_INFO
        LET P_COD_RET    = SQL_ERR;
        RETURN P_COD_RET,'','','','','01/01/1900',0,0,0,'01/01/1900','';
      END EXCEPTION;

    let P_COD_RET = '00000';
    let cSucursal = '';
    let cNumcte = '';
    let iMontoSolic = 0;
    let iMontoOtor = 0;
    let imontoAct = 0;
    let cUltimoMov = '';
    let cNombre = '';
    let iMonto_aumento= 0;
    let imonto_Disminucion= 0;
	let cNumSolic ='';

   --Set debug file to '/informix/paulq/sp_lincred_autorizadas.out';
   --trace on;

    If nvl(pSucursal,'') = '' then
        Let pSucursal = null;
    End if;
    If nvl(pNumSolicitud,'') = '' then
        Let pNumSolicitud = null;
    End if;
    If nvl(pNumCliente,'') = '' then
        Let pNumCliente = null;
    End if;

    If pFechaInicial = '' then
        Let pFechaInicial = date(1);
    End if;
    If pFechaFinal = '' then
        Let pFechaFinal = current;
    End if;
    
    ForEach
        Select t1.sucursal, t1.numcte, nvl(t4.fecha_insert, '01/01/1900'),
               nvl(t4.monto_solicitado,0),
               Trim(nvl(t5.apell_paterno,'')) || ' ' || trim(nvl(t5.apell_materno,'')) || ' ' || trim(nvl(t5.nombre1,'')) || ' ' || trim(nvl(t5.nombre2,'')),
               t1.num_credito
        Into cSucursal, cNumcte ,dFechaApertura,
             iMontoSolic,
             cNombre,
             cNumSolic
        From bdicred:sd_maecred t1
        Left join bdisolic:ss_solicitudes t4 on t1.empresa = t4.empresa and t1.num_credito = t4.num_solicitud
        Left join bdisolic:ss_autorizacion t3 on t1.empresa = t3.empresa and t1.num_credito = t3.num_solicitud and t3.status_solicitud = 'AT'
        Left join bdinteg:si_cliente t5 on t1.empresa = t5.empresa and t1.numcte = t5.numcte
        Where t1.empresa       = pempresa
        and   t4.sucursal      = (case when pSucursal is null then t4.sucursal else pSucursal end)
        and   t4.status_solicitud = 'AP'
        and   t4.numcte        = (case when pNumCliente is null then t4.numcte else pNumCliente end)
        and   t4.num_solicitud = (case when pNumSolicitud is null then t4.num_solicitud else pNumSolicitud end)
        and   (t4.fecha_insert >= (case when pFechaInicial is null then t4.fecha_insert else pFechaInicial end) 
        and   t4.fecha_insert <= (case when pFechaFinal is null then t4.fecha_insert else pFechaFinal end))

	   Select NVL(sum(case when codigo_fun = '008' and codigo_ref = 1 then NVL(monto, 0) else 0 end), 0) as aumentos,
			   NVL(sum(case when codigo_fun = '008' and codigo_ref = 2 then NVL(monto, 0) else 0 end), 0) as disminucion,
			   nvl(sum(case when codigo_fun = '001' and codigo_ref = 1 then nvl(monto, 0) else 0 end), 0) as apertura,
			   nvl(max(case when codigo_fun = '008' and codigo_ref = 1 then nvl(secuencia,0) else 0 end), 0) as secuenciaUltimoMovimientoAum,
			   nvl(max(case when codigo_fun = '008' and codigo_ref = 2 then nvl(secuencia,0) else 0 end), 0) as secuenciaUltimoMovimientoDism,
			   nvl(max(fecha_mov),date(1)) as fecha_max_his
        Into iMonto_aumento_dia_1, iMonto_Disminucion_dia_1, iMonto_apertura_dia_1,
		     iSecuenciaMayorAum_dia_1, iSecuenciaMayorDism_dia_1, dFechaMax_dia_1
		From sd_movhis
		Where empresa   = pEmpresa
		and fecha_mov > date(1)
		and num_credito = cNumSolic
		and (
				( codigo_fun  = '008' and codigo_ref in (1,2) ) or
				( codigo_fun  = '001' and codigo_ref in (1)   )
			)
		and reversado   = 'N';
		
	 Select NVL(sum(case when codigo_fun = '008' and codigo_ref = 1 then NVL(monto, 0) else 0 end), 0) as aumentos,
			NVL(sum(case when codigo_fun = '008' and codigo_ref = 2 then NVL(monto, 0) else 0 end), 0) as disminucion,
			nvl(sum(case when codigo_fun = '001' and codigo_ref = 1 then nvl(monto, 0) else 0 end), 0) as apertura,
			nvl(max(case when codigo_fun = '008' and codigo_ref = 1 then nvl(secuencia,0) else 0 end), 0) as secuenciaUltimoMovimientoAum,
			nvl(max(case when codigo_fun = '008' and codigo_ref = 2 then nvl(secuencia,0) else 0 end), 0) as secuenciaUltimoMovimientoDism,
			nvl(max(fecha_mov),date(1)) as fecha_max_his
        Into iMonto_aumento_dia_2, iMonto_Disminucion_dia_2, iMonto_apertura_dia_2,
		     iSecuenciaMayorAum_dia_2, iSecuenciaMayorDism_dia_2, dFechaMax_dia_2
		From sd_movhis_new
	   Where empresa   = pEmpresa
		 and fecha_mov > date(1)
		 and num_credito = cNumSolic
		 and (
				( codigo_fun  = '008' and codigo_ref in (1,2) ) or
				( codigo_fun  = '001' and codigo_ref in (1)   )
			)
		and reversado   = 'N';
		
		LET iMonto_aumento = iMonto_aumento_dia_1 + iMonto_aumento_dia_2;
		LET iMonto_Disminucion = iMonto_Disminucion_dia_1 + iMonto_Disminucion_dia_2;
        LET iMonto_apertura  = iMonto_apertura_dia_1 + iMonto_apertura_dia_2;
		
		IF iSecuenciaMayorAum_dia_1 > iSecuenciaMayorAum_dia_2 THEN
		    LET iSecuenciaMayorAum_His = iSecuenciaMayorAum_dia_1;
		ELSE
			LET iSecuenciaMayorAum_His = iSecuenciaMayorAum_dia_2;
		END IF;
		
		IF iSecuenciaMayorDism_dia_1 > iSecuenciaMayorDism_dia_2 THEN
			LET iSecuenciaMayorDism_His = iSecuenciaMayorDism_dia_1;
		ELSE
			LET iSecuenciaMayorDism_His = iSecuenciaMayorDism_dia_2;
		END IF;
		
		IF dFechaMax_dia_1 > dFechaMax_dia_2 THEN
			LET dFechaMax_his = dFechaMax_dia_1;
		ELSE
			LET dFechaMax_his = dFechaMax_dia_2;		
		END IF;		
		
        Select NVL(sum(case when codigo_fun = '008' and codigo_ref = 1 then NVL(monto, 0) else 0 end), 0) as aumentos,
               NVL(sum(case when codigo_fun = '008' and codigo_ref = 2 then NVL(monto, 0) else 0 end), 0) as disminucion,
               nvl(sum(case when codigo_fun = '001' and codigo_ref = 1 then nvl(monto, 0) else 0 end), 0) as apertura,
               nvl(max(case when codigo_fun = '008' and codigo_ref = 1 then nvl(secuencia,0) else 0 end), 0) as secuenciaUltimoMovimientoAum,
               nvl(max(case when codigo_fun = '008' and codigo_ref = 2 then nvl(secuencia,0) else 0 end), 0) as secuenciaUltimoMovimientoDism,
               nvl(max(fecha_mov),date(1)) as fecha_max_dia
        Into iMonto_aumento_dia, iMonto_Disminucion_dia, iMonto_apertura_dia, iSecuenciaMayorAum_dia, iSecuenciaMayorDism_dia, dFechaMax_dia
        From sd_movdia
        Where empresa   = pEmpresa
        and fecha_mov > date(1)
        and num_credito = cNumSolic
        and (
                ( codigo_fun  = '008' and codigo_ref in (1,2) ) or
                ( codigo_fun  = '001' and codigo_ref in (1)   )
            )
		and reversado   = 'N';

        Let iMonto_aumento     = iMonto_aumento     + iMonto_aumento_dia;
        Let iMonto_Disminucion = iMonto_Disminucion + iMonto_Disminucion_dia;
        Let iMontoAct          = iMontoSolic + iMonto_aumento - iMonto_Disminucion;

        Let cUltimoMov = "";
        If (iSecuenciaMayorAum_His > iSecuenciaMayorDism_His and iSecuenciaMayorAum_His > iSecuenciaMayorDism_dia) or
           (iSecuenciaMayorAum_dia > iSecuenciaMayorDism_dia) then
            let cUltimoMov ="AUMENTO";
        End if;
        If (iSecuenciaMayorDism_His > iSecuenciaMayorAum_His and iSecuenciaMayorDism_His > iSecuenciaMayorAum_dia) or
           (iSecuenciaMayorDism_dia > iSecuenciaMayorAum_dia) then
           Let cUltimoMov="DISMINUCION";
        End if;

        If dFechaMax_dia > dFechaMax_his Then
            Let dFechaEntrada= dFechaMax_dia;
        Else
            Let dFechaEntrada= dFechaMax_his;
        End if;

        If iMonto_apertura > iMonto_apertura_dia then
            Let iMontoOtor = iMonto_apertura;
        Else
            Let iMontoOtor = iMonto_apertura_dia;
        End if;

        IF cUltimoMov <> "" THEN
            return P_COD_RET, cSucursal, cNumcte, cNumSolic, dFechaApertura, dFechaEntrada, iMontoSolic, iMontoOtor, iMontoAct, cUltimoMOv, cNombre with resume;
        END IF;

    End ForEach;

end;
end procedure;