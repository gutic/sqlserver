create procedure ClientesGetAll
as
select * from cliente
go

create procedure ClienteAdd
@nombre as varchar(30),
@domicilio as varchar(30)
as
insert into cliente (nombre,Domicilio) values (@nombre,@domicilio)
go

create procedure ClienteUpdate
@id_cliente as int,
@nombre as varchar(30),
@domicilio as varchar(30)
as
update cliente
set nombre = @nombre, Domicilio = @domicilio
where id_cliente = @id_cliente
go

create procedure ClienteDelete
@id_cliente as int
as
delete cliente
where id_cliente = @id_cliente
go

create procedure ClienteGetOne
@id_cliente as int
as
select *
from Cliente
where id_cliente = @id_cliente
go
