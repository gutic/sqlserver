CREATE DATABASE PARCIALDML_Terlaak

GO

use PARCIALDML_Terlaak

GO


CREATE TABLE Provincias(
Id_provincia tinyint identity,
Nombre varchar(30) not null,
CONSTRAINT ck_Provincias_Nombre CHECK(nombre like'___%'),
CONSTRAINT pk_Provincias_Id_provincias PRIMARY KEY(Id_provincia)
)

GO

CREATE TABLE Localidades (
CP CHAR(4) UNIQUE not null,
Nombre VARCHAR(50) not null,
Id_provincia TINYINT,
CONSTRAINT pk_CP_Localidades PRIMARY KEY(CP),
CONSTRAINT fk_Localidades_Id_Provincia FOREIGN KEY(Id_provincia) REFERENCES Provincias(Id_provincia)
)

go

CREATE INDEX ix_Localidades_CP ON Localidades(CP)

GO

CREATE TABLE Empresas (
Id_empresa INT IDENTITY,
Nombre VARCHAR(50) NOT NULL,
Id_provincia TINYINT,
CONSTRAINT pk_Empresas_Id_empresa PRIMARY KEY(ID_empresa),
CONSTRAINT fk_Empresas_Id_provincia FOREIGN KEY(Id_provincia) REFERENCES Provincias(Id_provincia),
CONSTRAINT ck_Empresas_Nombre CHECK(Nombre like'___%')
)

go

CREATE INDEX ix_Empresas_nombre ON Empresas(nombre)

go

CREATE TABLE Lineas(
Id_empresa INT,
CP char(4),
encomiendas bit not null default(0),
hora tinyint not null,
id_linea smallint identity,
minuto tinyint not null,
transito char(1) default 'I',
CONSTRAINT fk_Lineas_Destino FOREIGN KEY(CP) REFERENCES Localidades(CP),
CONSTRAINT fk_Lineas_Origen FOREIGN KEY(CP) REFERENCES Localidades(CP),
CONSTRAINT fk_Lineas_Id_empresa FOREIGN KEY(Id_empresa) REFERENCES Empresas(Id_empresa),
CONSTRAINT ck_Lineas_transito CHECK(transito like '[I,E,P]'), 
CONSTRAINT ck_Lineas_minuto CHECK (minuto < 60 and minuto >=0 ),
CONSTRAINT ck_Lineas_hora CHECK(hora < 24 AND hora >= 0),
CONSTRAINT pk_Lineas_ID PRIMARY KEY (CP,ID_empresa)
)

go

CREATE INDEX ix_Lineas_hora_minuto on Lineas(hora,minuto)

go

CREATE TABLE Facturas (
fecha SMALLDATETIME NOT NULL DEFAULT (getdate()),
numero INT UNIQUE NOT NULL,
sucursal smallint UNIQUE not null,
Monto smallmoney not null,
constraint ck_Facturas_Monto CHECK(monto >= 0),
CONSTRAINT ck_Facturas_sucursal CHECK(sucursal > 0),
CONSTRAINT ck_Facturas_numero CHECK(numero > 0),
CONSTRAINT PK_Facturas_Id Primary Key (numero, sucursal),
)

go


CREATE TABLE ToquesDeAnden(
Id_empresa INT,
CP char(4),
Fecha_Hora smalldatetime not null default(getdate()),
Interno Smallint not null default(1),
Id_ToqueDeAnden int unique not null,
Tarifa smallmoney not null,
CONSTRAINT fk_ToquesDeAnden_LineasID foreign key (CP,Id_empresa) References Lineas(CP,Id_empresa),
CONSTRAINT pk_ToquesDeAnden_Id_ToqueDeAnden Primary Key (Id_ToqueDeAnden),
CONSTRAINT ck_ToquesDeAnden_Interno CHECK(Interno >=0),
CONSTRAINT ck_ToquesDeAnden_Tarifa CHECK(Tarifa >=0),
CONSTRAINT ck_ToquesDeAnden_ID_ToqueDeAnden check(ID_ToqueDeAnden > 0)
) 
go

CREATE INDEX ix_ToquesDeAnden_Interno on ToquesDeAnden(Interno)

go

CREATE TABLE Facturas_ToqueDeAnden (
numero INT UNIQUE,
sucursal SMALLINT UNIQUE,
Id_toqueDeAnden INT UNIQUE,
CONSTRAINT fk_Facturas_ToqueDeAnden_numero Foreign Key (numero) REFERENCES Facturas(numero),
CONSTRAINT fk_Facturas_ToqueDeAnden_sucursal Foreign Key (sucursal) REFERENCES Facturas(sucursal),
CONSTRAINT fk_Facturas_ToqueDeAnden_Id_ToqueDeAnden foreign key(Id_ToqueDeAnden) REFERENCES ToquesDeAnden(Id_ToqueDeAnden)
)
