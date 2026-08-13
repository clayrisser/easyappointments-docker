variable "BAKE_OUTPUT" {}
variable "DOCKER_REGISTRY" {}
variable "DOCKER_TAG" {}
variable "GIT_COMMIT" {}
variable "EASYAPPOINTMENTS_VERSION" {}

group "default" {
  targets = ["easyappointments"]
}

target "_common" {
  context = ".."
  output  = ["type=${BAKE_OUTPUT}"]
}

target "easyappointments" {
  inherits   = ["_common"]
  dockerfile = "docker/Dockerfile"
  args = {
    EASYAPPOINTMENTS_VERSION = EASYAPPOINTMENTS_VERSION
  }
  tags = [
    "${DOCKER_REGISTRY}/easyappointments:${DOCKER_TAG}",
    "${DOCKER_REGISTRY}/easyappointments:${GIT_COMMIT}",
    "${DOCKER_REGISTRY}/easyappointments:${EASYAPPOINTMENTS_VERSION}",
  ]
}
