create schema if not exists proyecto_final;
use proyecto_final;
create table if not exists Cliente(
id_cliente int auto_increment,
nombre_cliente varchar (30),
direccion_cliente varchar (30),
telefono_cliente int,
primary key (id_cliente)
);
create table if not exists Pedidos(
id_pedido int auto_increment,
fecha datetime,
id_art int,
id_cliente int,
primary key (id_pedido),
foreign key (id_cliente) references cliente(id_cliente),
foreign key (id_art) references productos(id_art)
);
create table if not exists Proveedores(
id_proveedor int auto_increment,
proveedor varchar (50),
cond_venta varchar (100),
direccion_proveedor varchar (50),
telefono_proveedor int,
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
create table if not exists catalogo(
id_producto int auto_increment,
precio_mayorista float,
id_proveedor int,
primary key (id_producto),
foreign key (id_proveedor) references proveedores (id_proveedor)
);
