Create database Bodega
go

use Bodega
go 

--TABLA DE PRODUCTO
create table PRODUCTO
(
idprod char(7) primary key,
descripcion varchar(25),
existencias int,
precio decimal (10,2) not null,
preciov decimal(10,2) not null,
ganancia as preciov - precio,
check (preciov>precio)
)
go

--FIN DE TABLA PRODUCTO


--TABLA PEDIDO
 create table PEDIDO 
 (
 idpedido char(7),
 idprod char(7),
 cantidad int 
 foreign key (idprod) references PRODUCTO(idprod)
 )
 go
--FIN DE TABLA PEDIDO


--TABLA DE BITACORA
create table BITACORA
(
idbitacora INT IDENTITY primary key,
Descripcion varchar (25),
accion varchar(15),
usuario varchar(100),
fecha datetime
)
go
--FIN DE TABLA BITACORA


----------------------------------------------------------------------------------------------------------------------------------------------------


 --PRIMER PROCEDIMIENTO ALMACENADO
create procedure registrar_producto
 @IDp char(7),
 @descrip varchar(25),
 @existencia int,
 @precio1 decimal(10,2),
 @precio2 decimal(10,2)

 As
 --si  ya existe el producto
if exists (select * from PRODUCTO where idprod=@IDp or descripcion=@descrip)
begin 
print('ESTE PRODUCTO YA HA SIDO INGRESADO ' + @IDP)
return
end

-- si no existe el producto
begin
insert into PRODUCTO values(@IDp,@descrip,@existencia,@precio1,@precio2)
print('SE AÑADIO CORRECTAMENTE EL NUEVO PRODUCTO')

end



execute registrar_producto 'P17', 'Jeans ',  10 , 20, 25

select *from PRODUCTO

--FIN DE PRIMER PROCEDIMIENTO ALMACENADO


-------------------------------------------------------------------------------------------------------------------------------------------------

--SEGUNDO PROCEDIMIENTO ALMACENADO 
create procedure pedido_1
@idpedi char (7),
@idprodu char (7),
@cantida int


AS
if not exists (select * from PRODUCTO where idprod=@idprodu)
begin
print('NO EXISTE EL PRODUCTO')
return
end

else if exists (select * from PRODUCTO where idprod=@idprodu and existencias<@cantida)
begin
print('EXISTENCIA DEL PRODUCTO INSUFICIENTE')
return
end

Begin
update PRODUCTO
SET existencias=existencias-@cantida
where idprod=@idprodu and  existencias>=@cantida 
insert into PEDIDO values (@idpedi,@idprodu,@cantida)
print('SE REALIZO EL PEDIDO')
end


EXECute pedido_1 'PD1','P14',5


select* from PRODUCTO
 
select * from PEDIDO
-- FIN DE SEGUNDO PROCEDIMIENTO ALMACENADO
  
-------------------------------------------------------------------------------------


--TRIGGER DE BITACORA
create trigger BITACORA_PRODUCTO on PRODUCTO
After insert, update, delete

AS
BEGIN
IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
begin 
  insert into BITACORA (descripcion,accion,usuario,fecha) 
 
 select D.descripcion,'ELIMINADO' as accion,SYSTEM_USER,GETDATE()
  from deleted D
  end

Else IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
begin 
insert into BITACORA (descripcion,accion,usuario,fecha)
select I.descripcion,'INSERTADO' as accion,SYSTEM_USER,GETDATE()
from inserted I


end
ELSE 
 IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
begin
   insert into BITACORA (descripcion,accion,usuario,fecha)
select I.descripcion,'ACTUALIZADO' as accion,SYSTEM_USER,GETDATE()
from inserted I
join deleted D on D.descripcion=I.descripcion
end

end
-- FIN TRIGGER DE BITACORA

--CODIGO PARA PROBAR EL DISPARADOR O TRIGGER
INSERT into PRODUCTO values ('P19','ZAPATOS',10,10,15)

update PRODUCTO
set existencias=26
where idprod='P19'


delete from PRODUCTO
where idprod='P19'

select* from BITACORA

select * from PRODUCTO
-- FIN DE CODIGO DE PRUEBA