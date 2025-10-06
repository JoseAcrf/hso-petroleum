# Odoo 19 Dockerizado para Producción

Entorno modular y seguro para desplegar Odoo 19 con monitoreo completo, persistencia, y configuración multi-worker.

## 📦 Servicios
- Odoo 19
- PostgreSQL 15
- Redis
- Prometheus + cAdvisor
- Grafana
- NGINX externo

## 📁 Estructura
Ver `docker-compose.yml`, `Dockerfile`, `config/`, `monitoring/`, `addons/`.

## 🛡 Seguridad
- Redis y PostgreSQL en red interna
- `.env` para credenciales
- `.gitignore` excluye secretos y logs

## 📊 Monitoreo
- Dashboards automáticos en Grafana
- Métricas de contenedores y PostgreSQL

## ✅ Checklist
Ver sección de verificación pre-producción en documentación técnica.

## 📄 Licencia
MIT – libre uso y modificación.
