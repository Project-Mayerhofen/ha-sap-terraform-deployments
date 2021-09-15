resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    hana_id = join(",", openstack_compute_instance_v2.hana.*.id)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.hana]
  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]

  }
}

resource "null_resource" "hana_node_provisioner" {

  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    hana_id = join(",", openstack_compute_instance_v2.hana.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]

  }

  provisioner "file" {
    content     = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
${var.common_variables["hana_grains_output"]}
name_prefix: ${var.common_variables["deployment_name"]}-hana
hostname: ${var.common_variables["deployment_name"]}-hana${format("%02d", count.index + 1)}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
sbd_lun_index: 0
hana_disk_device: /dev/sdc
hana_backup_device: /dev/sdb
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
}

module "hana_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids        = null_resource.hana_node_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  background          = var.common_variables["background"]
}
