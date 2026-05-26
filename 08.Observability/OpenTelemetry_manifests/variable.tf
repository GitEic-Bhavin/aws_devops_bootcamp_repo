variable "aws_region" {
    type        = string
    default     = "ap-south-1"
}

variable "environment_name" {
    type        = string
    default     = "test"
}

variable "tags" {
    type = map(string)
}