data "archive_file" "layer_archiver" {
  type        = "zip"
  source_dir = "${path.module}/../../../code/requirements/"
  output_path = "${path.module}/../../../code/requirements/requirements.zip"

  depends_on = [null_resource.install_requirements]
}

resource "null_resource" "install_requirements" {
  triggers = {
    requirements = filesha256("${path.module}/../../../code/requirements/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ${path.module}/../../../code/requirements/ && \
      python3 -m pip install -r ./requirements.txt -t .
    EOF
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "${var.project_name}-lambda-layer"

  compatible_runtimes = ["python3.13"]

  filename = "${path.module}/../../../code/requirements/requirements.zip"

  source_code_hash = filebase64sha256("${path.module}/../../../code/requirements/requirements.zip")

  depends_on = [data.archive_file.layer_archiver]
}