output "rds_address" {
    value = aws_db_instance.daedong.address
}
output "rds_db_name" {
    value = aws_db_instance.daedong.db_name
}
output "rds_username" {
    value = aws_db_instance.daedong.username
}
output "rds_password" {
    value = aws_db_instance.daedong.password
}
output "rds_identifier" {
    value = aws_db_instance.daedong.identifier
}