/* 
This file is used with Jenkins.
ATTR and CONST placeholders are replaced with
chef attributes and cookbook constraints, respectively,
using Jenkins script.
To run terraform for testing outside this file,
delete this file locally beforehand.
*/

variable "chefenv" { }
variable "environment" { }
variable "workspace" { }

provider "chef" {
server_url = "https://chef.yourcareuniverse.net/organizations/ycu/"
client_name = "jenkins"
private_key_pem = "${file(\"/etc/chef/jenkins.pem\")}"
}

resource "chef_environment" "example" {
name = "${var.chefenv}"
default_attributes_json = <<EOF
<ATTR>
EOF
override_attributes_json = <<EOF
<ATTR>
EOF
cookbook_constraints = <CONST>
}
