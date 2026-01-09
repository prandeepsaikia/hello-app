package k8s.images

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  endswith(c.image, ":latest")
  msg := sprintf("Container %s must not use :latest tag", [c.name])
}
