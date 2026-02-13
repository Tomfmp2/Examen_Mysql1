

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
