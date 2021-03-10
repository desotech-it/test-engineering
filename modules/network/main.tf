# Ottieni le availibility zone attualmente disponibili su AWS

# Recupera le prime due availability zone dalla lista sopra

# Crea una VPC con var.vpc_cidr_block come suo CIDR block

# Crea due subnet pubbliche e due subnet private, sulle due availibility zone

# Crea un internet gateway collegato alla VPC

# Crea una public route table collegata all'internet gateway, con relativa
# route table association

# Crea due elastic IP, uno per ciascuna subnet pubblica

# Crea due nat gateway, uno per Elastic IP

# Crea due route table (con route table association) - ciascuna per NAT gateway
