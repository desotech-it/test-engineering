# Usa il modulo aws/module/http-80 di AWS per creare automaticamente un security group
# che permette la porta 80

# Crea un load balancer con le security group di sopra

# Crea un load balancer target group per la porta 80

# Crea un load balancer listener sulla porta 80 con default_action "forward"

# Recupera l'AMI di Amazon Linux 2

# Crea un AWS key pair chiamata ssh
# (genera una chiave localmente)

# Crea un launch configuration con l'AMI recuperata da sopra
# e i security group ottenuti dal modulo di AWS
# Il tipo di istanza dev'essere t2.micro
# Ricorda di includere la chiave SSH generata prima
# Inoltre, inserisci lo startup script contenuto in questa cartella come userdata

# Crea un autoscaling group con
# min_aize 1
# desired_capacity 2
# max_size 4

# Crea un autoscaling policy con
# scaling adjustment 1
# adjustment_type ChangeInCapacity
# cooldown 300
resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = # tuo autoscaling group
}

# Crea un autoscaling policy con
# scaling adjustment -1
# adjustment_type ChangeInCapacity
# cooldown 300
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = # tuo autoscaling group
}
