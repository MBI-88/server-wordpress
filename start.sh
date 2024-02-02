#!/bin/bash

# Asegurarse de que MySQL esté corriendo
mysqld_safe &

# Esperar a que MySQL esté completamente arriba (ajustar el tiempo según sea necesario)
sleep 10

# Iniciar Apache en primer plano
apache2ctl -D FOREGROUND