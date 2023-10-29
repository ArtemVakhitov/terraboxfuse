terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-b"
}

resource "yandex_compute_instance" "terra-build" {

  name = "terra-build"

  zone = "ru-central1-b"
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8q5m87s3v0hmp06i5c"
    }
  }

  network_interface {
    subnet_id = "e2lgv5mqm56n8fjkt37q"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

    provisioner "remote-exec" {
    
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y git maven"
    ]

    connection {
      host = yandex_compute_instance.terra-build.network_interface.0.nat_ip_address
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/devops-eng-yandex-kp.pem")
    }
  }
}

resource "yandex_compute_instance" "terra-prod" {

  name = "terra-prod"

  zone = "ru-central1-b"
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8q5m87s3v0hmp06i5c"
    }
  }

  network_interface {
    subnet_id = "e2lgv5mqm56n8fjkt37q"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  provisioner "remote-exec" {
    
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y tomcat9"
    ]

    connection {
      host = yandex_compute_instance.terra-prod.network_interface.0.nat_ip_address
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/devops-eng-yandex-kp.pem")
    }
  }

  depends-on = [yandex_compute_instance.terra-build]

}