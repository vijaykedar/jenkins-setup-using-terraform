output "public_ip" {
  value = "Your Jenkins URL is : ${aws_instance.Jenkins_server.public_ip}:8080"
}

output "public_key" {
  value = "Your public key is : ${aws_key_pair.jenkins_key.public_key}"

}
