
resource null_resource output_bin_dir {
  provisioner "local-exec" {
    command = "echo '${module.setup_clis.bin_dir}' > .bin_dir"
  }
}
