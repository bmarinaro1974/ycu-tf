variable "value" {
  description = "The value that you wish to pass thru"
  type = "string"
}

output "value" {
  value = "${var.value}"
}