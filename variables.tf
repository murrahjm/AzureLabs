variable "subscription_id" {
    type = string
    description = "Azure Subscription ID"
    sensitive = true
}
variable "client_secret" {
    type = string
    description = "Azure service principal client secret"
    sensitive = true
}
variable "client_id" {
    type = string
    description = "Azure service principal client id"
    sensitive = true
}
variable "tenant_id" {
    type = string
    description = "Azure tenant ID"
    sensitive = true
}
