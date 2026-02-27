variable "db_username" {
  description = "Database username"
  default     = "appuser"
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}
