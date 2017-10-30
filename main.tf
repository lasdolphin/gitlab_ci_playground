terraform {
  backend "gcs" {
    bucket  = "tf-otus-gitlab"
    path    = "terraform.tfstate"
    project = "docker-181817"
    region  = "europe-west1-b"
  }
}

provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "gitlab_host" {
  name         = "${var.name}"
  machine_type = "${var.type}"
  zone         = "${var.zone}"
  tags =  ["${var.name}-tag"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
      size = "50"
    }
    auto_delete = "false"
  }

  metadata {
    sshKeys = "gitlab:${file(var.public_key_path)}"
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {
      nat_ip = "${google_compute_address.gitlab_host_ip.address}"
    }
  }
}

resource "google_compute_address" "gitlab_host_ip" {
  name = "external-ip"
}

resource "google_compute_firewall" "firewall_gitlab_host" {
  name = "gitlab-firewall"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["22","2376", "80", "443", "2222"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с тегом ...
  target_tags = ["${var.name}-tag"]
}
