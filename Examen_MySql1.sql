	
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


-- Consultas
USE MediSistema;

-- 1. Número de pacientes atendidos por cada médico
SELECT m.id_medico, m.nombre, m.apellido,
       COUNT(p.id_paciente) AS total_pacientes
FROM medicos m
LEFT JOIN paciente p ON m.id_medico = p.id_medico_asignado
GROUP BY m.id_medico;

-- 2. Total de días de vacaciones planificadas y disfrutadas por cada empleado
SELECT e.id_empleado, e.nombre, e.apellido,
       SUM(CASE WHEN v.estado = 'planificada' THEN v.dias ELSE 0 END) AS dias_planificados,
       SUM(CASE WHEN v.estado = 'disfrutada' THEN v.dias ELSE 0 END) AS dias_disfrutados
FROM empleados e
LEFT JOIN vacaciones v 
       ON e.id_empleado = v.id_persona 
       AND v.tipo_persona = 'empleado'
GROUP BY e.id_empleado;

-- 3. Médicos con mayor cantidad de horas de consulta en la semana
SELECT m.id_medico, m.nombre, m.apellido,
       SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS total_horas
FROM medicos m
JOIN horarios_consulta h ON m.id_medico = h.id_medico
GROUP BY m.id_medico
ORDER BY total_horas DESC;

-- 4. Número de sustituciones realizadas por cada médico sustituto
SELECT m.id_medico, m.nombre, m.apellido,
       COUNT(s.id_sustitucion) AS total_sustituciones
FROM medicos m
LEFT JOIN sustituciones s 
       ON m.id_medico = s.id_medico_sustituto
GROUP BY m.id_medico;

-- 5. Número de médicos que están actualmente en sustitución
SELECT COUNT(DISTINCT id_medico_sustituto) AS medicos_en_sustitucion
FROM sustituciones
WHERE CURDATE() BETWEEN fecha_inicio AND fecha_fin;

-- 6. Horas totales de consulta por médico por día de la semana
SELECT m.id_medico, m.nombre, h.dia_semana,
       SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS total_horas
FROM medicos m
JOIN horarios_consulta h ON m.id_medico = h.id_medico
GROUP BY m.id_medico, h.dia_semana;

-- 7. Médico con mayor cantidad de pacientes asignados
SELECT m.id_medico, m.nombre, m.apellido,
       COUNT(p.id_paciente) AS total_pacientes
FROM medicos m
LEFT JOIN paciente p ON m.id_medico = p.id_medico_asignado
GROUP BY m.id_medico
ORDER BY total_pacientes DESC
LIMIT 1;

-- 8. Empleados con más de 10 días de vacaciones disfrutadas
SELECT e.id_empleado, e.nombre, e.apellido,
       SUM(v.dias) AS dias_disfrutados
FROM empleados e
JOIN vacaciones v 
     ON e.id_empleado = v.id_persona
WHERE v.tipo_persona = 'empleado'
  AND v.estado = 'disfrutada'
GROUP BY e.id_empleado
HAVING SUM(v.dias) > 10;

-- 9. Médicos que actualmente están realizando una sustitución
SELECT DISTINCT m.id_medico, m.nombre, m.apellido
FROM medicos m
JOIN sustituciones s 
     ON m.id_medico = s.id_medico_sustituto
WHERE CURDATE() BETWEEN s.fecha_inicio AND s.fecha_fin;

-- 10. Promedio de horas de consulta por médico por día
SELECT m.id_medico, h.dia_semana,
       AVG(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS promedio_horas
FROM medicos m
JOIN horarios_consulta h ON m.id_medico = h.id_medico
GROUP BY m.id_medico, h.dia_semana;

-- 11. Empleados con mayor número de pacientes atendidos por los médicos bajo su supervisión
SELECT e.id_empleado, e.nombre, e.apellido,
       COUNT(p.id_paciente) AS total_pacientes
FROM empleados e
JOIN medicos m ON e.id_empleado = m.id_empleado_supervisor
LEFT JOIN paciente p ON m.id_medico = p.id_medico_asignado
GROUP BY e.id_empleado
ORDER BY total_pacientes DESC;

-- 12. Médicos con más de 5 pacientes y total de horas en la semana
SELECT m.id_medico, m.nombre, m.apellido,
       COUNT(DISTINCT p.id_paciente) AS total_pacientes,
       SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS total_horas
FROM medicos m
LEFT JOIN paciente p ON m.id_medico = p.id_medico_asignado
LEFT JOIN horarios_consulta h ON m.id_medico = h.id_medico
GROUP BY m.id_medico
HAVING COUNT(DISTINCT p.id_paciente) > 5;

-- 13. Total de días de vacaciones por tipo de empleado
SELECT tipo_persona,
       SUM(CASE WHEN estado = 'planificada' THEN dias ELSE 0 END) AS dias_planificados,
       SUM(CASE WHEN estado = 'disfrutada' THEN dias ELSE 0 END) AS dias_disfrutados
FROM vacaciones
GROUP BY tipo_persona;

-- 14. Total de pacientes por cada tipo de médico
SELECT m.tipo,
       COUNT(p.id_paciente) AS total_pacientes
FROM medicos m
LEFT JOIN paciente p ON m.id_medico = p.id_medico_asignado
GROUP BY m.tipo;

-- 15. Total de horas por médico y día de la semana
SELECT m.id_medico, m.nombre, h.dia_semana,
       SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS total_horas
FROM medicos m
JOIN horarios_consulta h ON m.id_medico = h.id_medico
GROUP BY m.id_medico, h.dia_semana;

-- 16. Número de sustituciones por tipo de médico
SELECT m.tipo,
       COUNT(s.id_sustitucion) AS total_sustituciones
FROM medicos m
LEFT JOIN sustituciones s 
       ON m.id_medico = s.id_medico_sustituto
GROUP BY m.tipo;

-- 17. Total de pacientes por médico y especialidad
SELECT m.id_medico, m.especialidad,
       COUNT(p.id_paciente) AS total_pacientes
FROM medicos m
LEFT JOIN paciente p ON m.id_medico = p.id_medico_asignado
GROUP BY m.id_medico, m.especialidad;

-- 18. Empleados y médicos con más de 20 días planificados
SELECT id_persona, tipo_persona,
       SUM(dias) AS total_dias
FROM vacaciones
WHERE estado = 'planificada'
GROUP BY id_persona, tipo_persona
HAVING SUM(dias) > 20;

-- 19. Médicos con mayor número de pacientes actualmente en sustitución
SELECT m.id_medico, m.nombre,
       COUNT(p.id_paciente) AS total_pacientes
FROM medicos m
JOIN sustituciones s 
     ON m.id_medico = s.id_medico_sustituto
LEFT JOIN paciente p 
     ON m.id_medico = p.id_medico_asignado
WHERE CURDATE() BETWEEN s.fecha_inicio AND s.fecha_fin
GROUP BY m.id_medico
ORDER BY total_pacientes DESC;

-- 20. Total de horas por especialidad y día
SELECT m.especialidad, h.dia_semana,
       SUM(TIMESTAMPDIFF(HOUR, h.hora_inicio, h.hora_fin)) AS total_horas
FROM medicos m
JOIN horarios_consulta h ON m.id_medico = h.id_medico
GROUP BY m.especialidad, h.dia_semana;
