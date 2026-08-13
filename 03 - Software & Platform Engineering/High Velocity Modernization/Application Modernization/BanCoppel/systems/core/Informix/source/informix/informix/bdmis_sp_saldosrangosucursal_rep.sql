CREATE PROCEDURE "informix".sp_saldosrangosucursal_rep(pFecha date) 
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha1          char(8);  
DEFINE  dFecha           Date;  

DEFINE lranini1   money(14,2);
DEFINE lranfin1   money(14,2);
DEFINE lranini2   money(14,2);
DEFINE lranfin2   money(14,2);
DEFINE lranini3   money(14,2);
DEFINE lranfin3   money(14,2);
DEFINE lranini4   money(14,2);
DEFINE lranfin4   money(14,2);
DEFINE lranini5   money(14,2);
DEFINE lranfin5   money(14,2);
DEFINE lranini6   money(14,2);

/*Variables para formateo de pFecha*/
DEFINE v_iAnio INTEGER;
DEFINE v_iMes INTEGER;
DEFINE v_idia CHAR(2);
DEFINE v_iMesc CHAR(2);
/***********************************/

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

--SET DEBUG FILE TO "/home/informix/jydg/sp_saldosrangosucursal_rep.out";
--TRACE ON;

    
	LET lranini2 = 0;
	LET lranfin2 = 0;
	LET lranini3 = 0;
	LET lranfin3 = 0;
	LET lranini4 = 0;
	LET lranfin4 = 0;
	LET lranini5 = 0;
	LET lranfin5 = 0;
	LET lranini6 = 0;
   
   	--fecha del sistema   	
   	--select fecha_ant into dFecha  from bdmis:mi_fechas;
    /*Formateo de pFecha*/
    set isolation to dirty read;
    LET v_iAnio = 0;
    LET v_iMes = 0;
    LET v_idia = 0;
    LET v_iMesc = '01';

    LET v_iAnio = YEAR(pFecha);
    LET v_iMes = LPAD(MONTH(pFecha),2,0);
    LET v_idia = LPAD(DAY(pFecha),2,0);

    if v_iMes < 10 then 
        LET v_iMesc= 0||v_iMes;
    else 
        LET v_iMesc= v_iMes;
    end if;

    LET dFecha1 = v_iMesc||v_idia||v_iAnio;
    LET dFecha = dFecha1::date;

    /********************/
   	
   	--Delete from bdmis:mi_saldosrango;
  
   	--Tomar Valores de Rango de Captacion
	SELECT sum(A), sum(B),sum(C),sum(D),sum(E),sum(F),sum(G),sum(H),sum(I)
	into lranini2,lranfin2,lranini3,lranfin3,lranini4,lranfin4,lranini5,lranfin5,lranini6 
	FROM TABLE
	(MULTISET(
	select  
	case when tipo = 2 then rangoini  end as A,
	case when tipo = 2 then rangofin end AS B,
	case when tipo = 3 then rangoini end AS C,
	case when tipo = 3 then rangofin end AS D,
	case when tipo = 4 then rangoini end AS E,
	case when tipo = 4 then rangofin end AS F,
	case when tipo = 5 then rangoini end AS G,
	case when tipo = 5 then rangofin end AS H,
	case when tipo = 6 then rangoini  end AS I
	from bdmis:mi_catrangos
	where sistema = '01'  ));
   	
   	--Sacar Rangos de Saldos en Captacion	
	insert into bdmis:mi_saldosrango(num_sucursal,producto,cuentas,saldo,tipo_rango,fecha,sistema)
	select sucursal,producto,count(*) as cuentas,sum(sdo_dia_ant) as importe,
	case 
	when sdo_dia_ant < 0 then -1
	when sdo_dia_ant = 0 then 1
	when sdo_dia_ant >= lranini2 and sdo_dia_ant <= lranfin2 then 2
	when sdo_dia_ant >= lranini3  and sdo_dia_ant <= lranfin3 then 3
	when sdo_dia_ant >= lranini4  and sdo_dia_ant <= lranfin4 then 4
	when sdo_dia_ant >= lranini5  and sdo_dia_ant <= lranfin5 then 5
	when sdo_dia_ant >= lranini6 then 6
	end as tipo,dFecha,'01'
	from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
    where chq.cuenta = noc.cuenta and noc.fecha_alta <= dFecha /*'2009-11-16'  */--LAGS
	group by sucursal,producto,5;
	
	--Tomar Valores de Rango de Colocacion
	SELECT sum(A), sum(B),sum(C),sum(D),sum(E),sum(F),sum(G),sum(H),sum(I)
	into lranini2,lranfin2,lranini3,lranfin3,lranini4,lranfin4,lranini5,lranfin5,lranini6 
	FROM TABLE
	(MULTISET(
	select  
	case when tipo = 2 then rangoini  end as A,
	case when tipo = 2 then rangofin end AS B,
	case when tipo = 3 then rangoini end AS C,
	case when tipo = 3 then rangofin end AS D,
	case when tipo = 4 then rangoini end AS E,
	case when tipo = 4 then rangofin end AS F,
	case when tipo = 5 then rangoini end AS G,
	case when tipo = 5 then rangofin end AS H,
	case when tipo = 6 then rangoini  end AS I
	from bdmis:mi_catrangos
	where sistema = '06'  ));
	
	--Sacar Rangos de Saldos en Colocacion
	insert into bdmis:mi_saldosrango(num_sucursal,producto,cuentas,saldo,tipo_rango,fecha,sistema)
	select sucursal,cred.num_producto,count(*) as cuentas,sum(dos.sdo_cap_insoluto) as importe,
	case 
	when dos.sdo_cap_insoluto < 0 then -1
	when dos.sdo_cap_insoluto = 0 then 1
	when dos.sdo_cap_insoluto >= lranini2 and dos.sdo_cap_insoluto <= lranfin2 then 2
	when dos.sdo_cap_insoluto >= lranini3  and dos.sdo_cap_insoluto <= lranfin3 then 3
	when dos.sdo_cap_insoluto >= lranini4  and dos.sdo_cap_insoluto <= lranfin4 then 4
	when dos.sdo_cap_insoluto >= lranini5  and dos.sdo_cap_insoluto <= lranfin5 then 5
	when dos.sdo_cap_insoluto >= lranini6 then 6
	end as tipo,dFecha,'06'
	from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
	where dos.num_credito = cred.num_credito
    and cred.fecha_apertura <= dFecha /*'2009-11-16'*/   --LAGS
	group by sucursal,num_producto,5;
				
	--Respaldar Datos a Historial
	/*insert into bdmis:mi_saldosrangosucursalhis(num_sucursal,producto,sistema,
	ctas_neg,sdo_neg,ctas_cero,sdo_cero,cta_ran2 ,sdo_ran2,cta_ran3 ,sdo_ran3,
	cta_ran4 ,sdo_ran4,cta_ran5,sdo_ran5,cta_ran6,sdo_ran6,fecha)
	select num_sucursal,producto,sistema,
	ctas_neg,sdo_neg,ctas_cero,sdo_cero,cta_ran2 ,sdo_ran2,cta_ran3 ,sdo_ran3,
	cta_ran4 ,sdo_ran4,cta_ran5,sdo_ran5,cta_ran6,sdo_ran6,fecha
	from bdmis:mi_saldosrangosucursal;*/
    
        --Limpia tabla para almacenar lo del dia
   --delete from bdmis:mi_saldosrangosucursal;
	
    --Respaldar Datos a Historial	
	--Ordenar Datos Para Su Almacenamiento
	insert into bdmis:mi_saldosrangosucursalhis(num_sucursal,producto,sistema,
	ctas_neg,sdo_neg,ctas_cero,sdo_cero,cta_ran2 ,sdo_ran2,cta_ran3 ,sdo_ran3,
	cta_ran4 ,sdo_ran4,cta_ran5,sdo_ran5,cta_ran6,sdo_ran6,fecha)
	select suc,prod,sis,nvl( sum(A1),0),nvl(sum(A2),0),nvl(sum(B1),0),nvl(sum(B2),0),
	nvl(sum(C1),0),nvl(sum(C2),0),nvl(sum(D1),0),nvl(sum(D2),0),nvl(sum(E1),0),
	nvl(sum(E2),0),nvl(sum(F1),0),nvl(sum(F2),0),nvl(sum(G1),0),nvl(sum(G2),0),fec        
	from table (multiset(
	select num_sucursal as suc,producto as prod,sistema as sis,
	case when tipo_rango = -1 then cuentas end as A1,
	case when tipo_rango = -1 then saldo end as A2,
	case when tipo_rango = 1 then cuentas end as B1,
	case when tipo_rango = 1 then saldo end AS B2,
	case when tipo_rango = 2 then cuentas end AS C1,
	case when tipo_rango = 2 then saldo end AS C2,
	case when tipo_rango = 3 then cuentas end AS D1,
	case when tipo_rango = 3 then saldo end AS D2,
	case when tipo_rango = 4 then cuentas end AS E1,
	case when tipo_rango = 4 then saldo end AS E2,
	case when tipo_rango = 5 then cuentas  end AS F1,
	case when tipo_rango = 5 then saldo end AS F2,
	case when tipo_rango = 6 then cuentas  end AS G1,
	case when tipo_rango = 6 then saldo end AS G2,fecha as fec     
	from bdmis:mi_saldosrango 
    where fecha = dFecha
    order by num_sucursal))
	GROUP BY suc,prod,sis,fec;
	
    /*Borra de la tabla de paso la fecha cargada sólo en la ejecución del complemento*/
    Delete from bdmis:mi_saldosrango where fecha = dFecha;

    RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;