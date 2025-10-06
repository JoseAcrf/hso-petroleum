from odoo import models, fields

class CredencialGestion(models.Model):
    _name = "credencial.gestion.v2"
    _description = "Gestión de Credenciales V2"

    nombre = fields.Char(string="Plataforma", required=True)
    usuario = fields.Char(string="Usuario")
    clave_acceso = fields.Char(string="Clave de acceso")
    link = fields.Char(string="Link")
    service_type = fields.Char(string="Service Type")
    email = fields.Char(string="Email")
    departamento = fields.Char(string="Departamento")
    ciclo_pago = fields.Char(string="Ciclo de Pago")
    fecha_expiracion = fields.Date(string="Fecha de Expiración")
    costo = fields.Float(string="Costo")
    tag_ids = fields.Many2many("ir.tags", string="Etiquetas")
    status = fields.Selection([
        ("activo", "Activo"),
        ("inactivo", "Inactivo"),
        ("por_confirmar", "Por confirmar")
    ], string="Status", default="activo")
    descripcion = fields.Text(string="Descripción")
    activo = fields.Boolean(default=True)
