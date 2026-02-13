	
CREATE DATABASE IF NOT EXISTS MediSistema;
USE MediSistema;

DROP TABLE IF EXISTS horarios_consulta;
DROP TABLE IF EXISTS vacaciones;
DROP TABLE IF EXISTS sustituciones;
DROP TABLE IF EXISTS paciente;
DROP TABLE IF EXISTS medicos;
DROP TABLE IF EXISTS empleados;

CREATE TABLE empleados(
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    apellido VARCHAR(200) NOT NULL,
    celular VARCHAR(15) NOT NULL,
    correo VARCHAR(200) NOT NULL,
    tipo ENUM('ATS','auxiliar_enfermeria','celador','administrativo') NOT NULL
);

CREATE TABLE medicos (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    apellido VARCHAR(200) NOT NULL,
    celular VARCHAR(15) NOT NULL,
    correo VARCHAR(200) NOT NULL,
    tipo ENUM('titular', 'interino', 'sustituto') NOT NULL,
    especialidad VARCHAR(200),
    id_empleado_supervisor INT,
    FOREIGN KEY (id_empleado_supervisor) REFERENCES empleados(id_empleado)
);

CREATE TABLE paciente(
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    apellido VARCHAR(200) NOT NULL,
    celular VARCHAR(15) NOT NULL,
    correo VARCHAR(200) NOT NULL,
    id_medico_asignado INT NOT NULL,
    FOREIGN KEY (id_medico_asignado) REFERENCES medicos(id_medico)
);

CREATE TABLE sustituciones (
    id_sustitucion INT AUTO_INCREMENT PRIMARY KEY,
    id_medico_titular INT NOT NULL,
    id_medico_sustituto INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    motivo VARCHAR(255),
    FOREIGN KEY (id_medico_titular) REFERENCES medicos(id_medico),
    FOREIGN KEY (id_medico_sustituto) REFERENCES medicos(id_medico)
);

CREATE TABLE vacaciones(
    id_vacacion INT AUTO_INCREMENT PRIMARY KEY,
    id_persona INT NOT NULL,
    tipo_persona ENUM('medico', 'empleado') NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('planificada', 'disfrutada', 'cancelada') DEFAULT 'planificada',
    dias INT GENERATED ALWAYS AS (DATEDIFF(fecha_fin, fecha_inicio) + 1) STORED
);

CREATE TABLE horarios_consulta (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_medico INT NOT NULL,
    dia_semana ENUM('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
);

-- Datos ingresados

USE MediSistema;

INSERT INTO empleados (nombre, apellido, celular, correo, tipo) VALUES
('Carlos','Ramirez','3001111111','carlos@mail.com','administrativo'),
('Laura','Gomez','3002222222','laura@mail.com','ATS'),
('Andres','Torres','3003333333','andres@mail.com','auxiliar_enfermeria');

INSERT INTO medicos (nombre, apellido, celular, correo, tipo, especialidad, id_empleado_supervisor) VALUES
('Juan','Perez','3011111111','juan@mail.com','titular','Cardiologia',1),
('Maria','Lopez','3012222222','maria@mail.com','interino','Pediatria',1),
('Pedro','Diaz','3013333333','pedro@mail.com','sustituto','Cardiologia',2);

INSERT INTO paciente (nombre, apellido, celular, correo, id_medico_asignado) VALUES
('Ana','Martinez','3021111111','ana@mail.com',1),
('Luis','Garcia','3022222222','luis@mail.com',1),
('Sofia','Hernandez','3023333333','sofia@mail.com',2),
('Miguel','Rojas','3024444444','miguel@mail.com',3);

INSERT INTO horarios_consulta (id_medico, dia_semana, hora_inicio, hora_fin) VALUES
(1,'Lunes','08:00:00','12:00:00'),
(1,'Martes','09:00:00','13:00:00'),
(2,'Lunes','10:00:00','14:00:00'),
(3,'Miercoles','08:00:00','11:00:00');

INSERT INTO sustituciones (id_medico_titular, id_medico_sustituto, fecha_inicio, fecha_fin, motivo) VALUES
(1,3,'2025-01-01','2025-12-31','Vacaciones');

INSERT INTO vacaciones (id_persona, tipo_persona, fecha_inicio, fecha_fin, estado) VALUES
(1,'empleado','2025-02-01','2025-02-10','disfrutada'),
(1,'medico','2025-03-01','2025-03-15','planificada');


