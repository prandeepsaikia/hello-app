package k8s.resources

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  not c.resources.requests.cpu
  msg := sprintf("Container %s must define cpu request", [c.name])
}

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  not c.resources.limits.cpu
  msg := sprintf("Container %s must define cpu limit", [c.name])
}

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  not c.resources.requests.memory
  msg := sprintf("Container %s must define memory request", [c.name])
}

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  not c.resources.limits.memory
  msg := sprintf("Container %s must define memory limit", [c.name])
}
