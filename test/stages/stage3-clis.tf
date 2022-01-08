
module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource output_bin_dir {
  provisioner "local-exec" {
    command = "echo '${module.setup_clis.bin_dir}' > .bin_dir"
  }
}
