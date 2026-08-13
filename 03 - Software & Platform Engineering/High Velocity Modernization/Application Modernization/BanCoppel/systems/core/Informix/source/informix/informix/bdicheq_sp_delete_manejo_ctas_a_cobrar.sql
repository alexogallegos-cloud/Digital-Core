Create Procedure "informix".sp_delete_manejo_ctas_a_cobrar()
RETURNING char(5) as codRet;

DEFINE vcodret      varchar(5);
DEFINE vsqlerr      int;
DEFINE visamerr     int;
DEFINE vErrorInfo   varchar(50);
DEFINE vContador	int;
DEFINE vCommit		int;
DEFINE vCuenta 		char(20);
DEFINE vCantMovHis  smallint;
DEFINE vNumCte      char(20);

LET vcodret     = '00000';
LET vsqlerr     = 0;
LET visamerr    = 0;
LET vErrorInfo 	= '';
LET vContador	= 0;
LET vCommit		= 500;
LET vCuenta 	= '';
LET vCantMovHis = 0;
LET vNumCte		= '';

Begin

	On Exception Set vsqlerr, visamerr, vErrorInfo

		If vsqlerr <> 0 Then 
			Set Debug File to "/resplogifx/conciliachq/updatemaehis.err";
			Trace on;
			LET vCodRet     = vSQLErr;
			LET vIsamErr    = vIsamErr;
			LET vErrorInfo 	= vErrorInfo;
			LET vCuenta     = vCuenta;
			Return vcodret;
		End if;
	End Exception;

	--Set Debug File to "/RESPALDOSNEW/RFonseca/CFDI/sp_updatemaehis.out";
	--Trace on;

	Set Isolation Dirty Read;
	Set Lock Mode To Wait 3;

	Foreach WITH HOLD
		Select count(*), CC.cliente
		Into vCantMovHis, vNumCte
		From bdicheq:sc_com_manejo_ctas_a_cobrar CC Inner Join bdicheq:sc_movhis MOV on CC.cuenta = MOV.cuenta
		Where MOV.fech_alt Between '01012026' and '01312026' and MOV.cancelad <> 'S'
		and MOV.transacc = '1141' and MOV.monto_tot >= 150
		Group By CC.cliente
		Having count(*) > 1

		If vContador = 0 Then
			BEGIN WORK;
		End If;

		LET vContador = vContador + 1;

		Delete From bdicheq:sc_com_manejo_ctas_a_cobrar
		Where cliente = vNumCte;

		If vContador >= vCommit Then
			COMMIT WORK;
			LET vContador = 0;
		End If;

	End Foreach;

	COMMIT WORK;

	LET vcodret = '0000';
	Return vcodret;
	End;
End Procedure;