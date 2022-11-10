create schema if not exists proyecto_final;
use proyecto_final;
create table if not exists Cliente(
id_cliente int auto_increment,
nombre_cliente varchar (50),
direccion_cliente varchar (50),
telefono_cliente varchar(20),
primary key (id_cliente)
);
create table if not exists Proveedores(
id_proveedor int auto_increment,
proveedor varchar (50),
cond_venta varchar (10),
direccion_proveedor varchar (50),
telefono_proveedor varchar (20),
primary key (id_proveedor)
);
create table if not exists Productos(
id_art int,
precio_publico float,
stock int,
descripcion_art varchar (100),
id_proveedor int,
id_producto int,
primary key (id_art),
foreign key (id_proveedor) references proveedores (id_proveedor) 
);
create table if not exists Pedidos(
id_pedido int,
fecha datetime,
id_art int,
id_cliente int,
primary key (id_pedido),
foreign key (id_cliente) references cliente(id_cliente),
foreign key (id_art) references productos(id_art)
);
create table if not exists Catalogo(
id_producto int,
precio_mayorista float,
id_proveedor int,
primary key (id_producto),
foreign key (id_proveedor) references proveedores (id_proveedor)
);

create or replace view stock_bajo as 
(select id_producto, descripcion_art, stock from productos where stock<=10);
select * from stock_bajo;

create or replace view nombre_cliente_pedido as 
(select id_pedido, nombre_cliente from pedidos p 
join cliente c on p.id_cliente= c.id_cliente);
select * from nombre_cliente_pedido;

create or replace view min_compra as
(select s.id_producto, c.id_proveedor, pro.cond_venta from stock_bajo s 
join catalogo c on s.id_producto = c.id_producto 
join proveedores pro on c.id_proveedor = pro.id_proveedor
where s.stock < 10);
select * from min_compra;

create or replace view tel_cliente as
(select nombre_cliente, telefono_cliente from cliente 
where nombre_cliente like ('Jose Perez'));
select * from tel_cliente;

create or replace view precio_productos as
(select descripcion_art, precio_publico from productos
order by precio_publico asc);
select * from precio_productos;

create or replace view pedidos_por_fecha as
(select id_pedido, fecha, ped.id_art, descripcion_art from pedidos ped 
join productos prod on ped.id_art= prod.id_art
where fecha between '2022-06-08' and '2022-09-18'
order by fecha desc);
select * from pedidos_por_fecha;

USE `proyecto_final`;
DROP function IF EXISTS `cant_productos`;
USE `proyecto_final`;
DROP function IF EXISTS `proyecto_final`.`cant_productos`;
;
DELIMITER $$
USE `proyecto_final`$$
CREATE FUNCTION `cant_productos`() RETURNS int
DETERMINISTIC
BEGIN
declare cantidad int;
set cantidad= (SELECT count(id_producto) as cantidad from productos);
RETURN cantidad;
END$$
DELIMITER ;

USE `proyecto_final`;
DROP function IF EXISTS `art_proveedor_mas_caro`;
USE `proyecto_final`;
DROP function IF EXISTS `proyecto_final`.`art_proveedor_mas_caro`;
;
DELIMITER $$
CREATE FUNCTION `art_proveedor_mas_caro`() RETURNS int
DETERMINISTIC
BEGIN
declare art_mas_caro int;
set art_mas_caro=(select id_art from productos p join catalogo c on p.id_producto= c.id_producto
where precio_mayorista=(select max(precio_mayorista) from catalogo));
RETURN art_mas_caro;
END$$
DELIMITER ;

DROP procedure IF EXISTS `sp_ordenar_tabla`;
DELIMITER $$
CREATE PROCEDURE `sp_ordenar_tabla` (in columna varchar (32), in orden varchar (32))
BEGIN
set @texto=concat('select * from cliente order by', ' ', columna, ' ', orden);
prepare ejec from @texto;
execute ejec;
deallocate prepare ejec;
END$$
DELIMITER ;
set @columna = 'id_cliente';
set @orden = 'desc';
call sp_ordenar_tabla (@columna,  @orden);

DROP procedure IF EXISTS `sp_modificar_pedidos`;
DROP procedure IF EXISTS `proyecto_final`.`sp_modificar_pedidos`;
DELIMITER $$
CREATE PROCEDURE `sp_modificar_pedidos`(in agregar varchar(32), in borrar varchar(32), in nro_pedido int)
BEGIN
if agregar='si' then
insert into pedidos 
values (8389, curdate(), 9073, 4);
end if;
if borrar='si' then
delete from pedidos where id_pedido= nro_pedido;
end if;
END$$
DELIMITER ;
set @agregar='no';
set @borrar= 'si';
set @nro_pedido= 8389;
call sp_modificar_pedidos (@agregar, @borrar, @nro_pedido);

drop table if exists log_pedidos;
create table log_pedidos(
id_log int auto_increment primary key,
tipo_accion varchar (32),
nombre_tabla varchar (32),
nombre_usuario varchar (100),
fecha date,
hora time
);
drop trigger if exists trg_log_pedidos; /* El trigger guarda información de lo que se inserte en la tabla Pedidos, antes de agregarla*/
delimiter $$
create trigger trg_log_pedidos before insert on pedidos
for each row
begin
insert into log_pedidos values (null, 'Insert', 'Pedidos', current_user(), curdate(), curtime() );
end;
select * from log_pedidos;

drop table if exists log_pedidos;
create table log_pedidos(
id_log int auto_increment primary key,
tipo_accion varchar (32),
nombre_tabla varchar (32),
nombre_usuario varchar (100),
fecha date,
hora time
);
drop trigger if exists trg_log_pedidos;/* El trigger guarda información de lo que se elimine de la tabla Pedidos, después de eliminado*/
delimiter $$
create trigger trg_log_pedidos after delete on pedidos
for each row
begin
insert into log_pedidos values (null, 'Delete', 'Pedidos', current_user(), curdate(), curtime() );
end;
select * from log_pedidos;

drop table if exists log_productos;
create table log_productos(
id_log int auto_increment primary key,
tipo_accion varchar (32),
nombre_tabla varchar (32),
nombre_usuario varchar (100),
fecha date,
hora time
);
drop trigger if exists trg_log_productos; /* El trigger guarda información de lo que se inserte en la tabla Productos, luego de la inserción*/
delimiter $$
create trigger trg_log_productos after insert on productos
for each row
begin
insert into log_productos values (null, 'Update', 'Productos', current_user(), curdate(), curtime() );
end;
select * from log_productos;

drop table if exists log_productos;
create table log_productos(
id_log int auto_increment primary key,
tipo_accion varchar (32),
nombre_tabla varchar (32),
nombre_usuario varchar (100),
fecha date,
hora time
);
drop trigger if exists trg_log_productos; /* El trigger guarda información de lo que se elimine de la tabla Productos, antres de la eliminación*/
delimiter $$
create trigger trg_log_productos before insert on productos
for each row
begin
insert into log_productos values (null, 'Insert', 'Productos', current_user(), curdate(), curtime() );
end;
select * from log_productos;